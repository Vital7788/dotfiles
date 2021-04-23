HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
#HISTORY_IGNORE="(ls|cd|fg|bg)"
setopt appendhistory sharehistory histignorealldups
setopt extendedglob
unsetopt beep

function zshaddhistory() {
    emulate -L zsh
    # strip newline
    1=${1%%$'\n'}
    if [[ "$1" =~ "^(ls|cd)[^\|]*$" || "$1" == "fg" || "$1" == "bg" ]]; then
        # if return is 1, the history line won't be saved
        # if return is 2, the history line will be saved to internal history list,
        # but not written to history file
        return 1
    fi
}

# ctrl-z backgrounds the current job if line is empty
# this way the foreground job can be backgrounded using ctrl-z ctrl-z
# when line is not empty "suspend" current input line
fancy-ctrl-z () {
  if [[ $#BUFFER -eq 0 ]]; then
    bg
    zle redisplay
  else
    zle push-input
  fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

zstyle :compinstall filename '/home/vital/.zshrc'
# load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
# git-completion.zsh is a function file, not designed to be sourced
# this command appends the ~/.zsh directory onto the shell's function lookup list
fpath=(~/.zsh $fpath)

# autoload scans each path within fpath for files starting with underscore
# and appends to corresponding script as a function file
autoload -Uz compinit promptinit vcs_info
compinit
promptinit

zstyle ':completion:*' menu select
# activate approximate completion, but only after regular completion (_complete)
zstyle ':completion:::::' completer _complete _approximate
# limit to 2 errors
zstyle ':completion:*:approximate:*' max-errors 2
#autocomplete ignore certain extensions for vim
zstyle ':completion:*:*:vim:*' file-patterns '^*.(class|pdf):source-files' '*:all-files'
#autocomplete case insensitive
#partial completion before '.', '_' or '-' e.g. f.b -> foo.bar
#completion on left side of text e.g. bar -> foobar
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

#vim editing mode in terminal
bindkey -v
#reduced lag after pressing <ESC>
KEYTIMEOUT=1

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^R' history-incremental-search-backward
bindkey '^F' history-incremental-search-forward
#fix backspace in vi-mode
bindkey '^?' backward-delete-char
bindkey '^W' backward-kill-word

#show vi mode in prompt
function zle-line-init zle-keymap-select {
    VIM_PROMPT_NORMAL="%F{green} [% NORMAL]% %f"
    VIM_PROMPT_INSERT="%F{cyan} [% INSERT]% %f"
    PROMPT="[%j]${${KEYMAP/vicmd/$VIM_PROMPT_NORMAL}/(main|viins)/$VIM_PROMPT_INSERT} %B%F{blue}%3~%b %B%F{green}$ %f%b"

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
test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
alias ls='ls --color=auto -h'

alias open=xdg-open

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

eval $(keychain --eval --quiet --noask ~/.ssh/id_rsa)
alias keychain='keychain ~/.ssh/id_rsa'
