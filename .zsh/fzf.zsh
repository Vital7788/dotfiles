# Set up fzf key bindings and fuzzy completion

# Check if fzf and patch are installed
if command -v fzf &>/dev/null && command -v patch &>/dev/null
then
  source <(patch -i ~/.zsh/fzf.patch -r - -o - =(fzf --zsh) 2>/dev/null)
  source ~/.zsh/fzf-git.sh

  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
    --color=fg:#3d2b5a,fg+:#3d2b5a,bg:#f6f2ee,bg+:#d3c7bb,gutter:#f6f2ee
    --color=hl:#a5222f,hl+:#a5222f,info:#955f61,marker:#396847
    --color=prompt:#287980,spinner:#6e33ce,pointer:#6e33ce,header:#2848a9
    --color=border:#aab0ad,label:#643f61,query:#303b5d'

  export FZF_CTRL_T_OPTS="
    --style full
    --preview '(cat {} || tree -C {}) 2> /dev/null | head -200'"
  export FZF_CTRL_R_OPTS="
    --no-sort --exact
    --header 'Press CTRL-F to edit the command'"
  export FZF_ALT_C_OPTS="
    --style full
    --preview 'tree -C {} | head -200'"

  # Use fd (https://github.com/sharkdp/fd) for listing path candidates.
  # - The first argument to the function ($1) is the base path to start traversal
  # - See the source code (completion.{bash,zsh}) for the details.
  _fzf_compgen_path() {
    fd --hidden --follow --exclude ".git" . "$1"
  }

  # Use fd to generate the list for directory completion
  _fzf_compgen_dir() {
    fd --type d --hidden --follow --exclude ".git" . "$1"
  }

  _fzf_complete_git() {
    # split command line into array
    args=( ${(z)LBUFFER} )
    # shift once, since first arg is 'git'
    shift args

    case "$args[1]" in
      (switch|diff|show)
        _fzf_complete \
          --bind "start:become(zsh \"$__fzf_git\" --run branches)" \
          -- "$@"
        ;;
      (add)
        _fzf_complete \
          --bind "start:become(zsh \"$__fzf_git\" --run files)" \
          -- "$@"
        ;;
      (*)
        ;;
    esac
  }

fi
