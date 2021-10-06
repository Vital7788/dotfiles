#zstyle :compinstall filename '/home/vital/.zshrc'

setopt extendedglob
unsetopt beep

setopt AUTO_PUSHD           # Push the old directory onto the stack on cd.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

source ~/.zsh/env.zsh
source ~/.zsh/history.zsh
source ~/.zsh/completion.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/alias.zsh
source ~/.zsh/input.zsh
source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh

# set ls colors
#test -r "~/.dir_colors" && eval $(dircolors ~/.dir_colors)
eval $(dircolors ~/.dir_colors)

# start keychain
eval $(keychain --eval --quiet --noask ~/.ssh/id_rsa)
