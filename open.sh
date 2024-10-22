#!/usr/bin/env sh

get_mime() {
  echo $(file --mime-type "$1" | rev | cut -d ':' -f1 | rev | cut -c2-)
}

file="$1"
mime="$(get_mime "$file")"
if [ "$mime" = "inode/symlink" ]; then
  # resolve the symlink
  file=$(readlink -f "$file")
  mime="$(get_mime "$file")"
fi

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
