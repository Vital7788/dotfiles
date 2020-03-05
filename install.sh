#!/bin/bash

BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# vim
if [ -d ~/.vim ]; then
    echo ".vim directory already exists"
else
    ln -s ${BASEDIR}/vim ~/.vim
fi

# zsh
# https://github.com/trapd00r/LS_COLORS
if [ -f  ~/.zshrc ]; then
    echo ".zshrc already exists"
else
    ln -s ${BASEDIR}/zshrc ~/.zshrc
fi

# i3
if [ -d  ~/.config/i3 ]; then
    echo "i3 directory already exists"
else
    ln -s ${BASEDIR}/i3 ~/.config/i3
fi

#i3blocks
if [ -d  ~/.config/i3blocks ]; then
    echo "i3blocks directory already exists"
else
    ln -s ${BASEDIR}/i3blocks ~/.config/i3blocks
fi

# git
if [ -f  ~/.gitconfig ]; then
    echo ".gitconfig already exists"
else
    ln -s ${BASEDIR}/gitconfig ~/.gitconfig
fi
