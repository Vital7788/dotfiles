zstyle :compinstall filename '/home/vital/.zshrc'

autoload -Uz compinit promptinit vcs_info
compinit
promptinit

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory extendedglob
unsetopt beep

#autocomplete ignore certain extensions for vim
zstyle ':completion:*:*:vim:*' file-patterns '^*.(class|pdf):source-files' '*:all-files'

export EDITOR=vim
export VISUAL=vim
#vim editing mode in terminal
bindkey -v
#reduced lag after pressing <ESC>
export KEYTIMEOUT=1

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^W' backward-kill-word
bindkey '^R' history-incremental-search-backward

#show vi mode in prompt
function zle-line-init zle-keymap-select {
    VIM_PROMPT_NORMAL="%F{green} [% NORMAL]% %f"
    VIM_PROMPT_INSERT="%F{cyan} [% INSERT]% %f"
    PROMPT="[%j]${${KEYMAP/vicmd/$VIM_PROMPT_NORMAL}/(main|viins)/$VIM_PROMPT_INSERT} %B%F{blue}%2~%b %B%F{green}$ %f%b"
    
    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select

#show git branch in prompt
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{240}(%b)%r%f'
zstyle ':vcs_info:*' enable git

#set ls colors
eval $( dircolors -b $HOME/.LS_COLORS )
alias ls='ls --color=auto'
