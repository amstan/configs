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

autoload -U compinit \
    edit-command-line
compinit
zmodload zsh/complist

eval $(dircolors -b)

# menu completion
zstyle ':completion:*' menu select

# colors for file completion
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# complete all processes
zstyle ':completion:*:processes' command 'ps -e'
zstyle ':completion:*:processes-names' command 'ps -eo comm'

# cache completion
zstyle ':completion:*' use-cache on

# don't complete working directory in parent
zstyle ':completion:*' ignore-parents parent pwd

# Other global aliases
alias -g C='| wc -l'
alias -g L='| less'
alias -g V='| vimless'
alias -g NO="&> /dev/null"
alias -g NE="2> /dev/null"
alias -g NS="> /dev/null"
alias -g G='| egrep --color=auto'
alias -g GI='| egrep -i --color=auto'
alias -g H='| head'

# history
export HISTFILE="$HOME/.zsh_history"
export HISTSIZE=10000000
export SAVEHIST=1000000
setopt append_history
setopt bang_hist
setopt extended_history
setopt hist_expire_dups_first
setopt hist_find_no_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt hist_save_no_dups
setopt inc_append_history
alias -g history="history 1"

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

# This is mostly used to color man pages.
export LESS_TERMCAP_mb=$(tput setaf 3) # yellow
export LESS_TERMCAP_md=$(tput bold; tput setaf 1) # red
export LESS_TERMCAP_me=$(tput sgr0)
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4) # yellow on blue
export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
export LESS_TERMCAP_us=$(tput smul; tput setaf 2) # green
export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)

# open man page as a PDF in preview
pman() { command man -t "$@" | okular -; }
compdef _man pman

alias du="du -hc --max-depth=1"

autoload -Uz vcs_info
 
zstyle ':vcs_info:*' stagedstr '%F{green}*'
zstyle ':vcs_info:*' unstagedstr '%F{red}*'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git svn
precmd () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats ' (%F{yellow}%b%c%u%F{default})'
    } else {
        zstyle ':vcs_info:*' formats ' (%F{yellow}%b%c%u%B%F{green}*%%b%F{default})'
    }
 
    vcs_info
}

setopt prompt_subst

PROMPT='%{%B$fg[blue]%}%n@%m%{$reset_color%b%}:%{$fg[cyan]%}%~%{$reset_color%}${vcs_info_msg_0_}%{$reset_color%}%#%\ '

zstyle ':completion:*' users ignored-patterns '*'
