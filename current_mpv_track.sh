#!/usr/bin/env sh

sh -c 'out=$(echo "{ \"command\": [\"get_property\", \"metadata\"] }" | socat - unix:~/data/mpv_data/sockets/mpv.socket); [ $? -eq 0 ] && echo "$out" | jq -j ".data | .title + \" - \" + .artist" || echo -n'
