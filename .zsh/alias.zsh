alias ls='ls --color=auto -h'

alias open=xdg-open

alias d='dirs -v'
alias dirs='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'

alias keychain='keychain ~/.ssh/id_rsa'

alias vim='nvim'
