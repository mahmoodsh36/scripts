#!/bin/sh
# usrhandler.sh - basically xdg-open but for urls

url="$1"

handled=true
case "$url" in
    *youtube*|*pornhub*view_video*|*gfycat*)
        notify-send "streaming a video"
        mpv "$url"
        ;;
    *)
        handled=false
        ;;
esac

$handled && exit 0

url_from_last_slash=`echo "$url" | rev | cut -d "/" -f1 | rev | cut -d "?" -f1`
extension=`echo $url_from_last_slash | rev | cut -d "." -f1 | rev`

case $extension in
    jpg|png|jpeg|gif)
        curl -o /tmp/image "$url"
        sxiv -a /tmp/image
        ;;
    *)
        firefox "$url"
        ;;
esac