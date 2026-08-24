alias ls='ls --color=auto -h'

# alias open=xdg-open

alias d='dirs -v'
alias dirs='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

alias vim='nvim'

alias config="/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME"

alias y='yazi_wrapper'

alias keychain="keychain --absolute --dir $XDG_RUNTIME_DIR/keychain $HOME/.ssh/id_*~$HOME/.ssh/id_*.pub"

alias wget="wget --hsts-file=$XDG_STATE_HOME/wget-hsts"
alias adb="HOME=$XDG_DATA_HOME/android adb"

# fractional scaling for VS Code
alias code="code --ozone-platform-hint=auto --enable-wayland-ime"

alias vswatch="yarn install && yarn build:dep && sh -c 'yarn compile:watch & yarn watch:packages & wait'"
alias vsdev='RELOAD_ON_WATCH=true code --extensionDevelopmentPath="$VSCODE_EXTENSION_PATH" --user-data-dir="$VSCODE_DATA_DIR/user-data" --extensions-dir="$VSCODE_DATA_DIR/extensions" --new-window'
# Swap in --inspect-extensions=9229 for a host that starts without waiting.
alias vsdebug='vsdev --inspect-brk-extensions=9229'
