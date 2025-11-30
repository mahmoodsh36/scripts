#!/usr/bin/env sh

percentage="$1"

brightness=$(cat /sys/class/backlight/intel_backlight/brightness)
max_brightness=$(cat /sys/class/backlight/intel_backlight/max_brightness)

new_brightness=$(echo $brightness + $percentage / 100 \* $max_brightness | bc -l | cut -d '.' -f1)
[ $new_brightness -gt 120000 ] && new_brightness=120000
[ $new_brightness -lt 0 ] && new_brightness=0
sudo sh -c "echo $new_brightness > /sys/class/backlight/intel_backlight/brightness"
