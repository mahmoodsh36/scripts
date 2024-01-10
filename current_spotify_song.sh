#!/usr/bin/env sh
song=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep 'title' -A1 | tail -1 | tr -s ' ' | cut -d ' ' -f4- | sed 's/^"//; s/"$//')
artist=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep ':artist' -A2 | tail -1 | tr -s ' ' | cut -d ' ' -f3- | sed 's/^"//; s/"$//')
echo $song - $artist
