#!/bin/sh

# returns screenshot filename

for dir in ~/media/screenshots $(xdg-user-dir PICTURES)/screenshots $(xdg-user-dir DOWNLOAD)
do
    if [ -d "$dir" ]; then
        echo "$dir/$(date +"screenshot_%Y-%m-%d_%H-%M-%S").png"
        break
    fi
done
