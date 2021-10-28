#LISTMAX=100

local list_completions=0

bindkey '^I' override-tab
bindkey '+' show-dirstack
bindkey '\-' show-dirstack
bindkey '%' show-processes

# Wrap existing widgets to provide auto-completion.
local widget
for widget in self-insert delete-char backward-delete-char kill-word backward-kill-word
do
    eval "zle -N $widget
    $widget() {
        zle .$widget
        if (( list_completions )); then
            zle list-choices
        fi
    }"
done

zle -N show-dirstack
show-dirstack() {
    if [[ $BUFFER == "cd " ]]; then
        BUFFER+="~"
        CURSOR=$CURSOR+1
        list_completions=1
    fi
    zle self-insert
}

zle -N show-processes
show-processes() {
    if [[ $BUFFER == "fg " || $BUFFER == "bg " ]]; then
        list_completions=1
    fi
    zle self-insert
}

# completion function that shows matches if there aren't too many
zle -C list-choices list-choices _list_choices
_list_choices() {
    _main_complete
    # check if amount of matches doesn't exceed screen or LISTMAX
    if (( (compstate[list_lines] + BUFFERLINES + 1) > LINES
        || ( compstate[list_max] != 0 && compstate[nmatches] > compstate[list_max] ) )); then
        compstate[list]=
    fi
    # clear previous matches if current doesn't get displayed
    if (( ${#compstate[list]} == 0 )); then
      zle -M 'Too many matches'
    fi
}

# workaround since _main_complete cannot be called directly
zle -C _complete_word complete-word _complete_word
_complete_word() {
    _main_complete
}

zle -N override-tab
override-tab() {
    if [[ $list_completions == 0 ]]; then
        list_completions=1
    fi
    local buffer=$BUFFER
    zle _complete_word
    if [[ $buffer != $BUFFER ]]
    then
        zle .auto-suffix-retain
        zle list-choices
    fi
}

autoload -U add-zsh-hook
add-zsh-hook -Uz precmd (){list_completions=0;}
