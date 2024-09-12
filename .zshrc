#zstyle :compinstall filename '/home/vital/.zshrc'

setopt extendedglob
unsetopt beep

# set ls colors
eval $(dircolors ~/.config/dir_colors)

source ~/.zsh/env.zsh
source ~/.zsh/history.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/input.zsh
source ~/.zsh/navigation.zsh
source ~/.zsh/completion.zsh
#source ~/.zsh/autocomplete.zsh
source ~/.zsh/alias.zsh
source ~/.zsh/command.zsh
source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh

# start keychain
eval $(keychain --eval --quiet --noask ~/.ssh/id_rsa)
