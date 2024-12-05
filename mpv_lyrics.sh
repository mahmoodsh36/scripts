#!/usr/bin/env sh

out=$(echo '{ "command": ["get_property", "path"] }' | socat - $MPV_MAIN_SOCKET_PATH | jq -j .data);
spotdl_lyrics.sh "$out" && echo "${out%.mp3}.lrc"
# notify-send -t 6000000 "$(cat "${out%.mp3}.lrc")" || notify-send "couldnt get lyrics"