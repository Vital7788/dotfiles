#!/bin/bash

set -e -u -o pipefail

volume=1
active_sink=$(pactl list sinks | sed -n '/State: RUNNING/,/^$/p')
if [[ -z $active_sink ]]; then
    active_sink=$(pactl list sinks | sed -n "/$(pactl get-default-sink)/,/^$/p")
fi

sink_bus=$(echo "$active_sink" | grep "device.bus =")
active_port=$(echo "$active_sink" | grep "Active Port:")
if [[ $sink_bus =~ pci && $active_port =~ speaker ]]; then
    volume=5
fi

mod=+
if [[ $1 = dec ]]; then
    mod=-
fi;

sink_name=$(echo "$active_sink" | grep "Name:" | cut -d ' ' -f 2)
pactl set-sink-volume $sink_name $mod${volume}%
