#!/usr/bin/env sh

change="$1"

sink=$(pacmd list-sinks | grep 'name:' | grep bluez | grep -o '<.*>' | tr -d '<>')

if [ -z "$change" ]; then
    volume=$(pacmd list-sinks | grep "$sink" -A10 | grep '^\svolume:' | awk '{print $5}')
    echo "$volume"
    exit 0
fi

pactl set-sink-volume $sink $change