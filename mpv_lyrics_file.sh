#!/usr/bin/env sh
# return the filepath of lyrics file for the currently playing mpv track

out=$(echo '{ "command": ["get_property", "path"] }' | socat - $MPV_MAIN_SOCKET_PATH | jq -j .data);
echo "${out%.mp3}.lrc"