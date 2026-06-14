#!/bin/sh

# Make sure ~/.local/bin/hotplug-monitor.sh can be executed without password
#
# Example sudoers entry:
# vital ALL=(ALL:ALL) NOPASSWD: /home/vital/.local/bin/hotplug-monitor.sh

MONITOR="$1"

if ! wlr-randr --output "$1" &> /dev/null
then
    sudo ~/.local/bin/hotplug-monitor.sh "$1"

    # Start mmsg in the background, since the read loop hangs otherwise
    exec 3< <(mmsg watch all-monitors)
    mmsg_pid=$!

    while read -r output <&3; do
        if echo "$output" | jq -e ".monitors | any(.name == \"$1\")" >/dev/null; then
            # Reload kanshi, since it can't handle the monitor being forcefully enabled
            pkill --signal SIGHUP -x kanshi

            # Also restart waybar, since workspaces get messed up
            # Simply reloading with SIGUSR2 causes weird bugs unfortunately
            killall waybar
            waybar --config ~/.config/mango/waybar/config.jsonc

            kill "$mmsg_pid"
            break
        fi
    done

    exec 3<&- # Close the file descriptor
fi
