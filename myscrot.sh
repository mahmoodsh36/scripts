#!/usr/bin/env sh

file="$(echo ~/data/images/scrots/`date | tr " " "_"`.png)"
arg="$1" # supply any value to make it select an area of the screen
if [ -z "$arg" ]; then
    notif_str="screenshot taken"; grim "$file" && echo -n "$file" | wl-copy && imv "$file" && notify-send "$notif_str"
else
    notif_str="image of selection taken"; sleep 0.2; slurp | grim -g - "$file" && echo -n "$file" | wl-copy && imv "$file" && notify-send "$notif_str"
fi
