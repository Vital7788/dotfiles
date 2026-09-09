# Set up fzf key bindings and fuzzy completion

# Check if fzf and fd are installed
if [[ -v commands[fzf] && -v commands[fd] ]]
then
  source <(fzf --zsh)

  export FZF_DEFAULT_COMMAND='fd --hidden --follow --type f'
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#3d2b5a,fg+:#3d2b5a,bg:#f6f2ee,bg+:#d3c7bb,gutter:#f6f2ee
    --color=hl:#a5222f,hl+:#a5222f,info:#955f61,marker:#396847
    --color=prompt:#287980,spinner:#6e33ce,pointer:#6e33ce,header:#2848a9
    --color=border:#aab0ad,label:#643f61,query:#303b5d'

  export FZF_CTRL_R_OPTS="
    --no-sort --exact
    --header 'Press CTRL-F to edit the command'"

  # Ctrl+R immediately runs the command after selection
  # Ctrl+F puts it on the command line
  fzf-history-run-widget() {
    local FZF_CTRL_R_OPTS="${FZF_CTRL_R_OPTS-}
      --bind=\"enter:become(printf '%s\n' {+}; exit 10)\"
      --bind=ctrl-f:accept"
    zle fzf-history-widget
    local ret=$?
    if (( ret == 10 )); then
      zle accept-line
      ret=0
    fi
    return $ret
  }
  zle -N fzf-history-run-widget
  bindkey -M emacs '^R' fzf-history-run-widget
  bindkey -M vicmd '^R' fzf-history-run-widget
  bindkey -M viins '^R' fzf-history-run-widget

  export FZF_CTRL_T_COMMAND="fd --hidden --follow"
  export FZF_CTRL_T_OPTS="
    --style full
    --preview '(cat {} || tree -C {}) 2> /dev/null | head -200'"

  export FZF_ALT_C_COMMAND="fd --type d --hidden --follow"
  export FZF_ALT_C_OPTS="
    --style full
    --preview 'tree -C {} | head -200'"

  export FZF_COMPLETION_TRIGGER=''
  bindkey '^ ' fzf-completion
  bindkey '^I' $fzf_default_completion

  # Use fd to generate the list for path completion
  # The first argument to the function ($1) is the base path to start traversal
  _fzf_compgen_path() {
    fd --hidden --follow . "$1"
  }

  # Use fd to generate the list for directory completion
  _fzf_compgen_dir() {
    fd --type d --hidden --follow . "$1"
  }

fi
