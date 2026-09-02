setopt extendedglob
unsetopt beep

if [[ -t 0 ]]; then
    # disable control flow (Ctrl-S and Ctrl-Q)
    stty -ixon

    # set ls colors
    eval $(dircolors -b ~/.config/dir_colors)
fi

for directory in "${XDG_STATE_HOME}/zsh" "${XDG_CACHE_HOME}/zsh"; do
    [[ -d "$directory" ]] || mkdir -p "$directory"
done

source ~/.zsh/history.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/input.zsh
source ~/.zsh/navigation.zsh
source ~/.zsh/completion.zsh
#source ~/.zsh/autocomplete.zsh
source ~/.zsh/alias.zsh
source ~/.zsh/command.zsh
source ~/.zsh/fzf.zsh
source ~/.zsh/kitty.zsh
source ~/.zsh/keychain.zsh
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
elif [[ -f /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh/site-functions/zsh-syntax-highlighting.zsh
fi
if [[ -f ~/.zsh/local.zsh ]]; then
    source ~/.zsh/local.zsh
fi
