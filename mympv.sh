#!/usr/bin/env sh
# a wrapper for mpv
[ ! -f /tmp/mpv_socket ] && mpv --input-ipc-server=/tmp/mpv_socket $@ || mpv $@
