#!/bin/sh

# search for files in wallpaper folders and get a random one

for dir in ~/media/wallpaper ~/Pictures/wallpaper
do
    [ -d "$dir" ] && find -L "$dir" -type f
done | sort -R | head -1
