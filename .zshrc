# populate our path properly
[[ -f ~/.profile ]] && . ~/.profile

# reset as much as possible (mostly this is for when we are reloading).
# do NOT unset functions, zsh does some magic with them.
unhash -am '*' # aliases
trap -
zstyle -d
bindkey -d

# Ensure path only has unique entries.
typeset -gU PATH

# don't echo control characters (in particular don't echo ^C on the command line).
stty -ctlecho

# Enable colors
autoload -U colors && colors

# Turn caching on
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# allow me to use arrow keys to select items.
zstyle ':completion:*' menu select
# case-insensitive completion. Partial-word and then substring completion commented out
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' # \
     # 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# don't complete the same filenames again
zstyle ':completion:*:(rm|cp|mv|zmv|vim|git):*' ignore-line other

zstyle ':completion:*:*:*' ignore-parents parent pwd

# fuzzy matching of completions
zstyle ':completion:*' completer _complete _match _approximate
# zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Stop trying to complete things in the path which already match!
zstyle ':completion:*' accept-exact-dirs true

# tab through previous directories automatically
zstyle ':completion::complete:cd::directory-stack' menu yes select
# tab through fg process automatically
zstyle ':completion::complete:fg:*:*' menu yes select

# stop when reaching beginning/end of history (further attempts then wrap)
zstyle ':completion:*:history-words' stop yes
# remove all duplicate words
zstyle ':completion:*:history-words' remove-all-dups yes
# don't list all the options (will often get the "too many options" prompt)
zstyle ':completion:history-words:*' list no
# we want the options to be filled in immediatly.
zstyle ':completion:*:history-words' menu yes

# This stops completion if we paste text into the terminal which has tabs.
zstyle ':completion:*' insert-tab pending

# tab completion # -u avoid unnecessary security check.
autoload -U compinit && compinit -u
autoload -U bashcompinit && bashcompinit
source /usr/share/git/completion/git-completion.bash

# Completion is done from both ends.
setopt complete_in_word
# Show the type of each file with a trailing identifying mark.
setopt list_types
# if there are other completions, always show them
unsetopt rec_exact
# don't expand glob automatically when completing.
setopt glob_complete
# case insensitive globbing
setopt no_case_glob
# don't print an error when there are no glob matches
setopt no_nomatch
# More globbing stuff.
setopt extended_glob
# Allow for correction of inaccurate commands
setopt correct
# Don't offer values starting with _ as corrections.
CORRECT_IGNORE='_*'

# Other global aliases
alias -g C='| wc -l'
alias -g L='| less'
alias -g V='| vimless'
alias -g NO="&> /dev/null"
alias -g NE="2> /dev/null"
alias -g NS="> /dev/null"
alias -g G='| egrep --color=always'
alias -g GI='| egrep -i --color=always'
alias -g H='| head'

# history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=10000
setopt append_history
setopt bang_hist
setopt extended_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_lex_words
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history

# Show dots when the command line is completing so that
# we have some visual indication of when the shell is busy.
expand-or-complete-with-dots() {
    echo -n "$(tput setf 4)...$(tput sgr0)"
    zle expand-or-complete
    zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -A key

key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}

for k in ${(k)key} ; do
    # $terminfo[] entries are weird in ncurses application mode...
    [[ ${key[$k]} == $'\eO'* ]] && key[$k]=${key[$k]/O/[}
done
unset k

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

# move with control
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word

# delete with alt
bindkey "\ea" backward-kill-line
bindkey "\ee" kill-line
bindkey "\e[1;9C" kill-word
bindkey "\e[1;9D" backward-kill-word

# directory colors
eval $(dircolors -b)
# Comandline completion has colors
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
alias ls="ls --color=tty -hF"
alias ll="ls -l"
alias lt="ll -t"
alias la="ls -A"
alias lla="ll -A"
l.()  { ls  -d "$@" .* ; }
lth() { lla -t "$@" | head ; }
# TODO: allow lsd to take directory argument.
lsd() { command ls --color=tty -hd "$@" */ }

# allow comments in the shell
setopt interactive_comments

# fancy mv (mv with wildcards)
autoload -U zmv

# If a command is issued that can’t be executed as a normal command, and the
# command is the name of a directory, perform the cd command to that directory.
setopt auto_cd
# Make cd push the old directory onto the directory stack.
setopt auto_pushd
# Don’t push multiple copies of the same directory onto the directory stack.
setopt pushd_ignore_dups
# allow cd to variables
setopt cdable_vars

# empty input redirection goes to less
READNULLCMD=less
# Report timing stats for any command longer than 1 second
REPORTTIME=1
TIMEFMT="$fg[cyan]%E real  %U user  %S system  %P cpu  %MkB mem $reset_color$ %J"

# config for python interactive shell
export PYTHONSTARTUP="$HOME/.pystartup"

# editor setup
export EDITOR=vim
export VISUAL=kate

alias e=echo
alias g=git
alias p=python2.7

# This is mostly used to color man pages.
export LESS_TERMCAP_mb=$(tput setaf 3) # yellow
export LESS_TERMCAP_md=$(tput bold; tput setaf 1) # red
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput setaf 2) # green
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)

# Handy Extract Program.
extract()
{
     if [[ -f $1 ]] ; then
         case "$1" in
             *.tar.bz2)   tar xvjf "$1"     ;;
             *.tar.gz)    tar xvzf "$1"     ;;
             *.bz2)       bunzip2 "$1"      ;;
             *.rar)       7za x "$1"        ;;
             *.gz)        gunzip "$1"       ;;
             *.tar)       tar xvf "$1"      ;;
             *.tbz2)      tar xvjf "$1"     ;;
             *.tgz)       tar xvzf "$1"     ;;
             *.zip)       unzip "$1"        ;;
             *.Z)         uncompress "$1"   ;;
             *.7z)        7za x "$1"         ;;
             *)           echo "'$1' cannot be extracted via >extract<" 1>&2 ;;
         esac
     else
         echo "'$1' is not a valid file" 1>&2
     fi
}
zstyle ':completion:*:*:extract:*' file-patterns \
    '*.(tar|bz2|rar|gz|tbz2|tgz|zip|Z|7z):zip\ files *(-/):directories'

# open man page as a PDF in preview
pman() { command man -t "$@" | okular -; }
compdef _man pman

alias du="du -hc --max-depth=1"
alias dus="command du -hs"

# colorize search results for grep
alias zgr="zgrep -e --color=always"
alias zgi="zgrep -ei --color=always"
alias grep="egrep --color=always"
alias gr="grep"
alias gi="egrep -i --color=always"
gh() { gi "$@" "$HISTFILE" }

# Grep all files in the current directory recursively
#   ignoring any files and folders that start with a .
g.() {
    find . -name '.?*' -prune -o -exec egrep --color=always -H "$@" {} \; 2> /dev/null
}



autoload -Uz vcs_info
 
zstyle ':vcs_info:*' stagedstr '%F{green}●'
zstyle ':vcs_info:*' unstagedstr '%F{red}●'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git svn
precmd () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats ' (%F{yellow}%b%c%u%F{default})'
    } else {
        zstyle ':vcs_info:*' formats ' (%F{yellow}%b%c%u%B%F{green}●%%b%F{default})'
    }
 
    vcs_info
}
 
setopt prompt_subst

#PROMPT='%F{blue}%n@%m %c${vcs_info_msg_0_}%F{blue} %(?/%F{blue}/%F{red})%% %{$reset_color%}'

PROMPT='%{%B$fg[blue]%}%n@%m%{$reset_color%b%}:%{$fg[cyan]%}%~%{$reset_color%}${vcs_info_msg_0_}%#%\ '
