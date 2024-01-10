#!/usr/bin/env sh

change="$1"

sink=$(pactl list | awk '/Name: bluez.*sink$/ {print $2}')

if [ -z "$change" ]; then
    volume=$(pactl list | grep 'bluez_sink.A0_DE_0F_CA_59_42.a2dp_sin' -A10 | grep '^\svolume:' -i | head -1 | awk '{print $5}')
    echo "$volume"
    exit 0
fi

pactl set-sink-volume $sink $change