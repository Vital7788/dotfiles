#!/bin/bash

volume=1
sink_bus=$(pactl list sinks | grep $(pactl get-default-sink) -B4 -A55 | grep "device.bus =")
active_port=$(pactl list sinks | grep $(pactl get-default-sink) -B4 -A55 | grep "Active Port:")
if [[ $sink_bus =~ pci && $active_port =~ speaker ]]; then
    volume=5
fi

mod=+
if [[ $1 = dec ]]; then
    mod=-
fi;


pactl set-sink-volume @DEFAULT_SINK@ $mod${volume}%
