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
