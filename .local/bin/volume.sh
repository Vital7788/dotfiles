#!/bin/bash

volume=1
sink_bus=$(pactl list sinks  | grep $(pactl get-default-sink) -B4 -A55 | grep "device.bus =")
if [[ $sink_bus =~ pci ]]; then
    volume=5
fi

mod=+
if [[ $1 = dec ]]; then
    mod=-
fi;


pactl set-sink-volume @DEFAULT_SINK@ $mod${volume}%
