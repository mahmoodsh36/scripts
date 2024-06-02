#!/usr/bin/env sh

out=$(echo '{ "command": ["get_property", "path"] }' | socat - ~/data/mpv_data/sockets/mpv.socket | jq -j .data);
spotdl_lyrics.sh "$out"
notify-send -t 6000000 "$(cat "${out%.mp3}.lrc")"|| notify-send "couldnt get lyrics"
