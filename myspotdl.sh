#!/usr/bin/env sh

cd "$HOME/music/"
for arg in "$@"; do
  spotdl --overwrite skip\
    --threads 36\
    download "$arg"\
    --output '{artist}/{album}/{title}--{track-id}'\
    --print-errors\
    --save-errors "$(unique_file.sh "$arg" errors.spotdl)"\
    --save-file "$(unique_file.sh "$arg" spotdl)"\
    --lyrics --max-retries 10 --add-unavailable\
    --generate-lrc --fetch-albums\
    --yt-dlp-args '--cookies-from-browser chrome' # --scan-for-songs
done