#!/usr/bin/env sh
# kill a running process using rofi

process_name="$1"
if [ -z "$process_name" ]; then
    process_name=$(ps -e | awk '{ print $4 }' | sort -u | rofi -dmenu -p program -i)
fi
if [ ! -z $process_name ]; then
    for process in $(ps -e | grep " $process_name$" | awk '{ print $1 }');
    do
        if [ ! -z $process ]; then
            sudo kill -9 $process
        fi
    done
    if [ -z "$(ps -e | grep " $process_name$")" ]; then
        notify-send "$process_name killed"
    fi
fi