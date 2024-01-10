#!/usr/bin/env sh
dir="$1"
[ -z "$dir" ] && dir="."
list_dir_as_album.py "$dir" | mpv --playlist=-
