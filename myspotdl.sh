#!/usr/bin/env sh

cd "$HOME/music/"
spotdl --overwrite skip\
       --threads 4\
       download "$@"\
       --output '{artist}/{album}/{title}--{track-id}'\
       --print-errors\
       --save-errors "$(unique_file.sh "$arg" errors.spotdl)"\
       --save-file "$(unique_file.sh "$arg" spotdl)"\
       --lyrics --add-unavailable\
       --generate-lrc\
       --fetch-albums\
       --config\
       --yt-dlp-args '--cookies-from-browser chrome'
# --scan-for-songs
# --audio youtube-music\
    # --only-verified-results\
    # --ytm-data\
    #--max-retries 10\