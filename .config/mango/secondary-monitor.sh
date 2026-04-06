#!/bin/sh

# Make sure ~/.local/bin/hotplug-monitor.sh can be executed without password
#
# Example sudoers entry:
# vital ALL=(ALL:ALL) NOPASSWD: /home/vital/.local/bin/hotplug-monitor.sh

MONITOR="$1"

if ! wlr-randr --output "$1" &> /dev/null
then
    sudo ~/.local/bin/hotplug-monitor.sh "$1"

    # Reload kanshi after a small delay, since it can't handle the monitor being forcefully enabled
    sleep 3
    pkill --signal SIGHUP -x kanshi

    # Also reload waybar, since workspaces get messed up
    pkill --signal SIGUSR2 -x waybar
fi
