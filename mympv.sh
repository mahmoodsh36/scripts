#!/usr/bin/env sh
# a wrapper for mpv
[ ! -S /tmp/mpv_socket ] && (mpv --input-ipc-server=/tmp/mpv_socket "$@"; rm /tmp/mpv_socket) || mpv "$@"
