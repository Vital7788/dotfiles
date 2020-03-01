zstyle :compinstall filename '/home/vital/.zshrc'

autoload -Uz compinit promptinit vcs_info
compinit
promptinit

PROMPT='[%j] %B%F{blue}%2~ %F{green}$ %f%b' 
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory extendedglob
unsetopt beep

export EDITOR=vim
export VISUAL=vim
#vim editing mode in terminal
bindkey -v

eval $( dircolors -b $HOME/.LS_COLORS )
alias ls='ls --color=auto'
