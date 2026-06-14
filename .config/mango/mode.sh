#!/bin/sh

mmsg watch keymode | while read mode
do
    mode=$(echo $mode | jq -r .keymode)
    case $mode in
        exit)
            echo "exit: loc[k], [l]ogout, s[u]spend, [r]eboot, [s]hutdown"
            ;;
        layout)
            current_layout=$(mmsg get monitor "$WAYBAR_OUTPUT_NAME" | jq -r .layout_symbol)
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
