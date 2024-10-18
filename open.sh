#!/usr/bin/env sh

file="$1"
mime=$(file --mime-type "$1" | rev | cut -d ':' -f1 | rev | cut -c2-)

case "$mime" in
  application/pdf)
    zathura "$file"
    ;;
  application/*)
    notify-send 'launching zaread.. this might take a few seconds'
    zaread "$file"
    ;;
  video/*)
    mympv.sh "$file"
    ;;
  audio/*)
    mympv.sh "$file"
    ;;
  image/*)
    sxiv "$file"
    ;;
  *)
    emacsclient "$file"
    ;;
esac
