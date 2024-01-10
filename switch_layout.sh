#!/bin/sh
# switch_layout.sh - switch between us, il, ar keyboard layouts on xorg

layouts="us\nil\nara"
layouts_count=$(echo "$layouts" | wc -l)

current_layout=$(setxkbmap -query | awk '/layout/ {print $2}')
i=1
while [ ! $i -gt $layouts_count ]; do
    layout=$(echo "$layouts" | sed -n "${i}p")
    if [ $layout = $current_layout ]; then
        if [ $i -eq $layouts_count ]; then
            next_layout=$(echo "$layouts" | head -1)
        else
            next_layout=$(echo "$layouts" | sed -n "$(expr $i + 1)p")
        fi
        setxkbmap $next_layout
        echo $next_layout
        exit
    fi
    i=$(expr $i + 1)
done