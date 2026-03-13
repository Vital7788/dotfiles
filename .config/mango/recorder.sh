#!/bin/bash

STATUS_FILE="/tmp/waybar-recorder-status"
SIGNAL=1

case "$1" in
    start)
        shift
        if pgrep -x "wf-recorder" > /dev/null; then
            notify-send "Recorder" "Already recording!"
            exit 1
        fi

        file=$(xdg-user-dir VIDEOS)/$(date +'recording_%Y-%m-%d_%H-%M-%S.mp4')
        wf-recorder -f "$file" "$@" &

        echo -e "Recording\n$file" > "$STATUS_FILE"
        pkill -RTMIN+$SIGNAL waybar
        ;;

    stop)
        shift

        pid=`pgrep -x wf-recorder`
        status=$?

        if [ $status == 0 ]; then
            pkill --signal SIGINT -x wf-recorder
            file=$(tail -n1 "$STATUS_FILE" 2>/dev/null || echo $(xdg-user-dir VIDEOS))
            notify-send "Recorder" "Recording saved to $(tail -n1 $STATUS_FILE)"
        fi

        rm "$STATUS_FILE" 2>/dev/null
        pkill -RTMIN+$SIGNAL waybar

        if [ $status != 0 ]; then
            exit 1
        fi
        ;;

    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
