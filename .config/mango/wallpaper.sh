#!/bin/sh

# search for files in wallpaper folders and get a random one

for dir in ~/media/wallpaper "$(xdg-user-dir PICTURES)/wallpaper" ~/Pictures/wallpaper
do
    [ -d "$dir" ] && find -L "$dir" -type f
done | sort -R | head -1
