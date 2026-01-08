# Set up fzf key bindings and fuzzy completion

# Check if fzf and patch are installed
if command -v fzf &>/dev/null && command -v patch &>/dev/null
then
  source <(patch -i ~/.zsh/fzf.patch -r - -o - =(fzf --zsh) 2>/dev/null)
  source ~/.zsh/fzf-git.sh

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
