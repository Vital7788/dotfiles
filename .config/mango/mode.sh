#!/bin/sh

mmsg -o "$WAYBAR_OUTPUT_NAME" -w -b | while read _ mode
do
    case $mode in
        exit)
            echo "exit: loc[k], [l]ogout, s[u]spend, [r]eboot, [s]hutdown"
            ;;
        layout)
            current_layout=$(mmsg -o "$WAYBAR_OUTPUT_NAME" -g -l | awk '{ print $2 }')
            echo "layout [$current_layout]: [c]enter_tile, [t]ile, [r]ight_tile, [s]croller, [d]eck, [v]ertical_deck, [n]ext layout"
            ;;
        screencopy)
            echo "copy screen: a:󰹑 , s:󰩭 , d:✎󰹑 , f:✎󰩭 , g:✎󰖯 , e: 󰹑 , r: 󰩭 "
            ;;
        default)
            echo ""
            ;;
        *)
            echo $mode
            ;;
    esac
done
