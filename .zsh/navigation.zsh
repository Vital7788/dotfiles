setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

# auto ls when changing directory
function list_all() {
  emulate -L zsh
  ls --color=auto
}
autoload -U add-zsh-hook
add-zsh-hook -Uz chpwd list_all

