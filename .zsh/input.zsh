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

rationalise-dot() {
    if [[ $LBUFFER = *.. ]]; then
        LBUFFER+=/.
    fi
    zle self-insert
}
zle -N rationalise-dot
bindkey . rationalise-dot

# vim editing mode in terminal
bindkey -v
# reduced lag after pressing <ESC>
KEYTIMEOUT=1

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^R' history-incremental-search-backward
bindkey '^F' history-incremental-search-forward
# fix backspace in vi-mode
bindkey '^?' backward-delete-char
bindkey '^W' backward-kill-word
