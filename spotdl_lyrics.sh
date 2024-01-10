#!/usr/bin/env sh

# download lyrics/metadata using spotdl for an audio file

mp3file="$1"
lrcfile=${1%.*}.lrc
[ -f "$lrcfile" ] && exit
spotdl meta "$1" --lyrics --generate-lrc --overwrite skip # --scan-for-songs