#!/bin/bash
brightness=$(cat /sys/class/backlight/*/brightness)
max_brightness=$(cat /sys/class/backlight/*/max_brightness)
new_brightness=$(echo "$max_brightness * ${1:-5}/100 + $brightness" | bc)
echo $new_brightness
if [[ $new_brightness -gt $max_brightness ]]; then
    new_brightness=$max_brightness
elif [[ $new_brightness -lt 0 ]]; then
    new_brightness=0
fi
echo $new_brightness | tee /sys/class/backlight/*/brightness
