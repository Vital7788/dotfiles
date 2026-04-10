#!/bin/sh

# Rofi wrapper that picks a random color for the selected item

colors=("red" "green" "yellow" "blue" "purple" "cyan" "orange" "pink")
color=${colors[$((RANDOM % 8))]}

rofi -theme-str "*{ selected-fg: @$color; selected-bg: @$color-trans; }" $@
