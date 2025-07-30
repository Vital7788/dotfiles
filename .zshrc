#zstyle :compinstall filename '/home/vital/.zshrc'

setopt extendedglob
unsetopt beep

# disable control flow (Ctrl-S and Ctrl-Q)
stty -ixon

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
source ~/.zsh/fzf.zsh
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [ -f /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh ]; then
    source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
fi
source ~/.zsh/wezterm.sh

# start keychain
if command -v keychain 2>&1 >/dev/null
then
    eval $(keychain --eval --quiet --noask ~/.ssh/id_ed25519)
fi

source ~/.zsh/local.zsh
