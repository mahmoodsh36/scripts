#!/usr/bin/env sh

pgrep -x transmission-da || transmission-daemon && sleep 1

transmission-remote -a "$1" && notify-send "added torrent" || notify-send "couldnt add magnet"