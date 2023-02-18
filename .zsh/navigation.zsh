setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

# auto ls when changing directory
function list_all() {
  emulate -L zsh
  ls --color=auto
}

# auto activate and deactivate python virtual environments
function python_venv() {
  MYVENV=./venv
  # when you cd into a folder that contains $MYVENV
  [[ -d $MYVENV ]] && source $MYVENV/bin/activate > /dev/null 2>&1
  # when you cd into a folder that doesn't
  [[ ! -d $MYVENV ]] && deactivate > /dev/null 2>&1
}

autoload -U add-zsh-hook
add-zsh-hook -Uz chpwd list_all
add-zsh-hook -Uz chpwd python_venv

python_venv
