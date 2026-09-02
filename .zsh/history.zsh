HISTFILE="${XDG_STATE_HOME}/zsh/histfile"
HISTSIZE=100000
SAVEHIST=100000
setopt share_history        # share history file between all sessions
setopt append_history       # immediately add commands to history file
setopt hist_ignore_dups     # do not enter record when it's duplicate of previous event
setopt extended_history     # save timestamp of command

function zshaddhistory() {
    # if return is 1, the history line won't be saved
    # if return is 2, the history line will be saved to internal history list,
    # but not written to history file
    emulate -L zsh
    # strip newline
    1=${1%%$'\n'}
    # if [[ "$1" =~ "^(ls|cd) *\/(.*\/){2,}" ]]; then
    #     return 0
    # fi
    # if [[ "$1" =~ "^ls [^\|]*$" || "$1" =~ "^cd " || "$1" =~ "^(fg|bg|d|[0-9])$" ]]; then
    if [[ "$1" == "ls" || "$1" == "cd" || "$1" =~ "^(fg|bg|d|[0-9])$" ]]; then
        return 1
    fi
}

