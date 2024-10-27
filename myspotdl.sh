#!/usr/bin/env sh

cd "$HOME/music/"
spotdl --overwrite skip --threads 4 download "$@" \
  --output '{artist}/{album}/{title}--{track-id}' \
  --print-errors --save-errors "$(unique_file.sh "$@" errors.spotdl)" \
  --save-file "$(unique_file.sh "$@" spotdl)" \
  --client-id "$SPOTIFY_CLIENT_ID"\
  --client-secret "$SPOTIFY_CLIENT_SECRET"\
  --user-auth\
  --lyrics --add-unavailable --generate-lrc --fetch-albums --config
  # --yt-dlp-args '--cookies-from-browser firefox'
  # --cookie-file "$HOME/dl/cookies.txt"
  # --cookie-file '~/.mozilla/firefox/17f1v26k.default-release/cookies.sqlite'
# --scan-for-songs
# --audio youtube-music\
# --only-verified-results\
# --ytm-data\
#--max-retries 10\
