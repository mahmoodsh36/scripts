#!/usr/bin/env sh
# generate cover.jpg for albums in a music directory, assumes that each album is in its own directory, and that files are in mp3, and that every one of those mp3 files has the cover embedded in it

musicdir="$1"
[ -z "$musicdir" ] && musicdir="$HOME/music"
find -mindepth 2 -type d | while read album;
do                                                  
    if [ ! -f "$album/cover.jpg" ]; then
        first_track="$album/$(ls --color=no "$album" | grep mp3 | head -1)"
        # cover_path="${first_track/\.mp3/.jpg}";
        cover_path="$album/cover.jpg"                        
        echo doing "$first_track"                            
        ffmpeg -nostdin -i "$first_track" -an -vcodec copy "$cover_path"
    fi
done 2&>1 > /dev/null