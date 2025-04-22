# Set up fzf key bindings and fuzzy completion

# Check if fzf and patch are installed
if command -v fzf 2>&1 >/dev/null && command -v patch 2>&1 >/dev/null
then
  source <(patch -i ~/.zsh/fzf.patch -r - -o - =(fzf --zsh) 2>/dev/null)
  source ~/.zsh/fzf-git.sh
fi

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
