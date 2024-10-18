#!/usr/bin/env sh
# a wrapper for mpv
# [ ! -S /tmp/mpv_socket ] && (mpv --input-ipc-server=/tmp/mpv_socket "$@"; rm /tmp/mpv_socket) || mpv "$@"
socket_dir=$HOME/data/mpv_data/sockets
socket_file=$(cd "$socket_dir"; unique_file.sh "mpv" "socket")
notify-send $socket_file
full_socket_file_path="/$socket_dir/$socket_file"
mpv --input-ipc-server="$full_socket_file_path" "$@"; rm "$full_socket_file_path"