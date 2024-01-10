#!/bin/sh
# music_blog.sh - write my music diaries/blog

date=`date "+%H:%M:%S %d/%m/%y"`
notify-send "writing music diaries for $date" -t 10000

vim /tmp/music_diary

if [ -f /tmp/music_diary ]; then
    if [ ! -d "$HOME/music_diary" ]; then mkdir "$HOME/music_diary"; fi
    if [ ! "`cat /tmp/music_diary`" = "" ]; then
        diary_file="$HOME/music_diary/`echo $date | tr "/" "_"`"
        echo "$date" > "$diary_file"
        cat /tmp/music_diary >> "$diary_file"
        echo `date "+%H:%M:%S %d/%m/%y" | tr "/" "_"` >> "$diary_file"
        notify-send "saved music diary for $date" -t 10000
    fi
    rm /tmp/music_diary
fi
