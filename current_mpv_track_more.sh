#+/bin/env sh
[ -S /tmp/mpv_socket ] && (name=$(echo "{ \"command\": [\"get_property\", \"metadata\"] }" | socat - /tmp/mpv_socket | jq -j ".data | .title + \" - \" + .artist + \" \" + .track + \" \" + .disc"); subtitles=$(echo '{ "command": ["get_property", "sub-text"] }' | socat - /tmp/mpv_socket | jq -j '.data?'); echo -n "$name $subtitles")
