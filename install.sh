#!/bin/bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# vim
ln -s ${BASEDIR}/vim ~/.vim

# zsh
# https://github.com/trapd00r/LS_COLORS
ln -s ${BASEDIR}/zshrc ~/.zshrc

# i3
ln -s ${BASEDIR}/i3 ~/.config/i3
ln -s ${BASEDIR}/i3blocks ~/.config/i3blocks

# git
ln -s ${BASEDIR}/gitconfig ~/.gitconfig
