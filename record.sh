#!/usr/bin/env sh

mics=""
i=0

for mic in $(pactl list sources short | awk '!/bluez/ && !/monitor/ {print $2}'); do
  mics="$mics -f pulse -thread_queue_size 1024 -i $mic"
  filters="$filters[$i:0]"
  i=$((i + 1))
done

[ "$i" -eq 0 ] && { echo "No physical mics found."; exit 1; }

ffmpeg $mics \
  -f v4l2 -video_size 1280x720 -thread_queue_size 1024 -i /dev/video0 \
  -filter_complex "${filters}amix=inputs=$i:duration=longest[aout]" \
  -map $i:v -map "[aout]" \
  -c:v libx265 -crf 28 -c:a aac -b:a 300k \
  ~/"$(date | tr ' ' '_').mp4"