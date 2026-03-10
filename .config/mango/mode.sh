#!/bin/sh

# note: this is not accurate if not all monitors have the same mode
mmsg -w -b | while read monitor _ mode
do
    case $mode in
        exit)
            echo "exit: loc[k], [l]ogout, s[u]spend, [r]eboot, [s]hutdown"
            ;;
        default)
            echo ""
            ;;
        *)
            echo $mode
            ;;
    esac
done
