#!/usr/bin/env sh

mac=$(bluetoothctl info | grep 'Connected: yes' -B10 | head -1 | cut -d ' ' -f2)
[ -z $mac ] && exit 0
name=$(bluetoothctl info | grep 'Connected: yes' -B10 | grep 'Name:' | cut -d ' ' -f2-)
battery=$(bluetooth_battery $mac | cut -d ' ' -f6)
echo $name $battery
