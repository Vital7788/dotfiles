#!/bin/sh

# Script to force re-enable a monitor after disabling it in the kernel
#
# Example grub config entry to disable DP-2 during boot:
# GRUB_CMDLINE_LINUX_DEFAULT="video=DP-2:d"

MONITOR="$1"

echo on > "/sys/kernel/debug/dri/0/$1/force"
echo 1 > "/sys/kernel/debug/dri/0/$1/trigger_hotplug"
