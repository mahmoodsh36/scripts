#!/usr/bin/env sh

choice=$(cat ~/.config/bookmarks | wofi --dmenu)
if [ ! -z "$choice" ]; then
    url=$(echo $choice | cut -d ' ' -f1)
    $BROWSER "$url"
fi