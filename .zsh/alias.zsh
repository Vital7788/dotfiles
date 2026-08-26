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

alias vswatch="vs && yarn install && yarn build:dep && { yarn compile:watch & yarn watch:packages & }"
# alias vswatch='yarn install && yarn build:dep && setsid --fork yarn watch:packages >/dev/null 2>&1; setsid --fork yarn compile:watch 2>&1 | ( status=1; while IFS= read -r line; do case $line in *"Watching for file changes"*) status=0; break;; esac; done; cat >/dev/null & exit $status )'
# Only kills process group leaders. Watchers started in scripts need setsid
alias vswatchstop="pgrep -f 'bin/yarn (compile:watch|watch:packages)$' | xargs -r -I{} kill -INT -{}"
alias vsdev='RELOAD_ON_WATCH=true code --extensionDevelopmentPath="$VSCODE_EXTENSION_PATH" --user-data-dir="$VSCODE_DATA_DIR/user-data" --extensions-dir="$VSCODE_DATA_DIR/extensions"'
# Swap in --inspect-extensions=9229 for a host that starts without waiting.
alias vsdebug='vsdev --inspect-brk-extensions=9229'
