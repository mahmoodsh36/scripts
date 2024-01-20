#!/usr/bin/env sh

program=$(pacman -Ssq | rofi -dmenu -p 'program')
[ -z "$program" ] && exit
terminal_with_cmd.sh sudo pacman --needed --noconfirm -S $program
notify-send -t 20000 "installed $program"