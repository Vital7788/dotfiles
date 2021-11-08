#!/bin/zsh

#autoload -Uz add-zsh-hook
#add-zsh-hook precmd _autocomplete.async
zle -N _autocomplete.async

_autocomplete.async() {
    #(( KEYS_QUEUED_COUNT || PENDING )) && return
    local fd
    exec {fd}< <( _autocomplete.parse )
    zle -Fw "$fd" _autocomplete.callback
}

zle -N _autocomplete.callback
_autocomplete.callback() {
    local fd=$1 REPLY
    {
        zle -F "$fd"  # Unhook this callback to avoid being called repeatedly.

        [[ $2 == (|hup) ]] ||
            return  # Error occured.

        read -ru $fd
        _autocomplete.list "$REPLY"
    } always {
        exec {fd}<&-  # Close file descriptor.
    }
}

_autocomplete.list() {
    zle -M "$1"
}

_autocomplete.parse() {
    print $CURSOR
}

# Wrap existing widgets to provide auto-completion.
local widget
for widget in self-insert delete-char backward-delete-char kill-word backward-kill-word
do
    eval "zle -N $widget
    $widget() {
        zle .$widget
        zle _autocomplete.async
    }"
done

#    [[ -v 2 ]] && (( ($2 + BUFFERLINES + 1) > LINES || ( LISTMAX != 0 && $1 > LISTMAX ) )) && return;
