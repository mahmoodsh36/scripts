#!/usr/bin/env sh

choice=$(cat ~/.config/bookmarks | dmenu.sh)
if [ ! -z "$choice" ]; then
    url=$(echo $choice | cut -d ' ' -f1)
    $BROWSER "$url"
fi