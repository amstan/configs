#From https://github.com/xonsh/xonsh/issues/1614#issuecomment-483386184
import re
from xonsh.history.main import construct_history

# <command-number> <unix epoch> <command>
history_line_pat = re.compile(r'^\s*\d+  (?P<timestamp>\d{10})  (?P<command>.*)$')

# Query zsh's builtin `fc` (don't use zsh_history directly since it
# mangles unicode). To do that, we have to first force it to read the
# history (which it normally doesn't do with -c) and also force it to
# act in interactive mode (-i).
history_lines = $(zsh -i -c 'fc -R ~/.zsh_history; fc -l -t "%s" 0').splitlines()

hist = construct_history(
	gc=False,
	# exlictily set buffersize to prevent slowing down to a crawl because of excessive flushing
	buffersize=len(history_lines)
)

for line in history_lines:
    match = history_line_pat.match(line)
    command = match.group('command')
    timestamp = match.group('timestamp')
    command = command.replace(r'\\n', '\n')
    hist.append({'inp': command, 'rtn': 0, 'ts': (timestamp, timestamp)})
hist.flush()
print(hist.info().filename)
