# IMPORTANT: kitty-scrollback.nvim only supports zsh 5.9 or greater for command-line editing,
# please check your version by running: zsh --version

# add the following environment variables to your zsh config (e.g., ~/.zshrc)

autoload -Uz edit-command-line
zle -N edit-command-line

function kitty_scrollback_edit_command_line() { 
  local VISUAL='/home/vital/.local/share/nvim/lazy/kitty-scrollback.nvim/scripts/edit_command_line.sh'
  zle edit-command-line
  zle kill-whole-line
}
zle -N kitty_scrollback_edit_command_line

# map insert to edit command using nvim
bindkey '^[[2~' kitty_scrollback_edit_command_line

# [optional] pass arguments to kitty-scrollback.nvim in command-line editing mode
# by using the environment variable KITTY_SCROLLBACK_NVIM_EDIT_ARGS
# export KITTY_SCROLLBACK_NVIM_EDIT_ARGS=''
