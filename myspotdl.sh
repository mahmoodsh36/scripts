#!/usr/bin/env sh

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

cd "$HOME/music/"
for arg in "$@"; do
  spotdl --overwrite skip\
    --threads 36\
    download "$arg"\
    --output '{artist}/{album}/{title}--{track-id}'\
    --print-errors\
    --save-errors "$(unique_file "$arg" errors.spotdl)"\
    --save-file "$(unique_file "$arg" spotdl)"\
    --lyrics --max-retries 10 --add-unavailable\
    --generate-lrc --fetch-albums\
    --yt-dlp-args '--cookies-from-browser chrome' # --scan-for-songs
done
