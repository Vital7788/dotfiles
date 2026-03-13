#!/bin/sh

# returns screenshots folder

for dir in ~/media/screenshots ~/Pictures/screenshots ~/downloads ~/Downloads
do
    if [ -d "$dir" ]; then
        echo $dir
        break
    fi
done
