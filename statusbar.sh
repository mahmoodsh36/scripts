#!/usr/bin/sh
# dwm_statusbar.sh - statusbar script

VOL() {
    amixer get Master | awk 'END {print $4}' | tr -d '[]'
}

BATTERY() {
    cat /sys/class/power_supply/BAT0/capacity | tr -d '\n'
    echo -n '%'
}

LAYOUT() {
    setxkbmap -query | awk '/layout/ {print $2}'
}

STORAGE() {
    df -h | awk '/\/$/ {print $3 " / " $2}'
}

MEM() {
    free -h | awk '/Mem/ {print $3 "/" $2}'
}

#MUSIC() {
#    current_song=$(pmus -r current)
#    [ "$current_song" = "" ] && echo NO MUSIC && return
#    is_liked=$(pmus -r "is_liked $(echo $current_song | cut -d ' ' -f1)")
#    [ "$(pmus -r mode)" = "LOOP_SONG" ] && echo -n '🔂'
#    $is_liked && echo -n "💕"
#    echo -n '🤘 '
#    echo -n "$current_song" | cut -d ' ' -f2- | tr -d '\n'
#    echo -n ' '
#    pmus -r progress
#}

MUSIC() {
    song=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep 'title' -A1 | tail -1 | tr -s ' ' | cut -d ' ' -f4- | sed 's/^"//; s/"$//')
    artist=$(dbus-send --print-reply --session --dest=org.mpris.MediaPlayer2.spotify /org/mpris/MediaPlayer2 org.freedesktop.DBus.Properties.Get string:'org.mpris.MediaPlayer2.Player' string:'Metadata' | grep ':artist' -A2 | tail -1 | tr -s ' ' | cut -d ' ' -f3- | sed 's/^"//; s/"$//')
    echo $song - $artist
}

#status=$(python -c 'import json; f = open("whatsapp.json"); data = json.loads(f.read()); print(data[-1]["new_status"]); f.close()')

date=$(date "+%H:%M:%S (%a) %d/%m/%y")
echo "$(LAYOUT)|🤘 $(MUSIC)|💻 $(MEM)|🔊 $(VOL)|🕒 $date"