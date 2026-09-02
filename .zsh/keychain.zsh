if (( $+commands[keychain] )); then
    keychain() {
        command keychain --theme legacy --absolute --dir $XDG_RUNTIME_DIR/keychain "$@"
    }

    () {
        local pidfile=$XDG_RUNTIME_DIR/keychain/$HOST-sh
        [[ -r $pidfile ]] && source $pidfile
        [[ -S ${SSH_AUTH_SOCK-} ]] || eval "$(keychain agent start --eval --quiet)"
    }
fi
