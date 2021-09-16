HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
#HISTORY_IGNORE="(ls|cd|fg|bg)"
setopt sharehistory         # share history file between all sessions
setopt appendhistory        # immediately add commands to history file
setopt histignorealldups    # delete old record when new event is duplicate

function zshaddhistory() {
    # if return is 1, the history line won't be saved
    # if return is 2, the history line will be saved to internal history list,
    # but not written to history file
    emulate -L zsh
    # strip newline
    1=${1%%$'\n'}
    if [[ "$1" =~ "^(ls|cd) *\/(.*\/){2,}" ]]; then
        return 0
    fi
    if [[ "$1" =~ "^ls[^\|]*$" || "$1" =~ "^cd" || "$1" == "fg" || "$1" == "bg" ]]; then
        return 1
    fi
}

