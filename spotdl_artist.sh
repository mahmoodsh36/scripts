#!/usr/bin/env bash

unique_file() {
  name=$1
  ext=$2
  if [[ -e "$name.$ext" || -L "$name.$ext" ]] ; then
    i=0
    while [[ -e "$name-$i.$ext" || -L "$name-$i.$ext" ]] ; do
      let i++
    done
    name=$name-$i
  fi
  echo "$name.$ext"
}

artist=$1
cd "$HOME/music/"
echo fetching $artist with spotdl
spotdl --overwrite skip --threads 36 download "artist:$artist" --output '{artist}/{album}/{title}--{track-id}' --print-errors --save-errors "$(unique_file "$artist" errors.spotdl)" --save-file "$(unique_file "$artist" spotdl)" --lyrics --max-retries 10 --add-unavailable --generate-lrc --fetch-albums --yt-dlp-args '--cookies-from-browser chrome' # --scan-for-songs 