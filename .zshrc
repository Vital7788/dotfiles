#zstyle :compinstall filename '/home/vital/.zshrc'

setopt extendedglob
unsetopt beep

source ~/.zsh/env.zsh
source ~/.zsh/history.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/input.zsh
source ~/.zsh/navigation.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/alias.zsh
source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh

# set ls colors
#test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
eval $(dircolors ~/.dir_colors)

# start keychain
eval $(keychain --eval --quiet --noask ~/.ssh/id_rsa)
