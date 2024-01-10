#!/usr/bin/env sh
song=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep 'title' -A1 | tail -1 | tr -s ' ' | cut -d ' ' -f4- | sed 's/^"//; s/"$//')
artist=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep ':artist' -A2 | tail -1 | tr -s ' ' | cut -d ' ' -f3- | sed 's/^"//; s/"$//')

song=$(echo $song | tr '/' '-')
artist=$(echo $artist | tr '/' '-')

lyrics_file=~/brain/lyrics/"$song - $artist"
[ -f "$lyrics_file" ] && notify-send -t 6000000 "$song - $artist" "\n$(cat "$lyrics_file")" || (\
    notify-send -t 5000 "fetching lyrics..";\
    lyrics="$(~/workspace/scripts/get_genius_lyrics.py "$song" "$artist")";\
    [ -z "$lyrics" ] && lyrics="$(clyrics "$song - $artist")";\
    [ ! -z "$lyrics" ] && echo "$lyrics" > "$lyrics_file" &&\
    notify-send -t 6000000 "$lyrics" || notify-send "couldnt get lyrics" )