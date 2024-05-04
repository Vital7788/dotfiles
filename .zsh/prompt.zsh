autoload -Uz promptinit vcs_info
promptinit

function zle-line-init zle-keymap-select {
    #show vi mode in prompt
    VIM_PROMPT_NORMAL="%F{green} [% NORMAL]% %f"
    VIM_PROMPT_INSERT="%F{cyan} [% INSERT]% %f"
    #show venv in prompt
    VENV_PROMPT=""
    if [[ -v VIRTUAL_ENV ]]; then
        VENV_PROMPT="%F{yellow}(${VIRTUAL_ENV:t:gs/%/%%}) %f"
    fi
    PROMPT="[%j]${${KEYMAP/vicmd/$VIM_PROMPT_NORMAL}/(main|viins)/$VIM_PROMPT_INSERT} $VENV_PROMPT%B%F{blue}%3~%b %B%(?.%F{green}.%F{red})$ %f%b"

    zle reset-prompt
}

zle -N zle-line-init
zle -N zle-keymap-select


#show git branch in prompt
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst
RPROMPT=\$vcs_info_msg_0_
zstyle ':vcs_info:git:*' formats '%F{black}(%b) %r%f'
zstyle ':vcs_info:*' enable git
