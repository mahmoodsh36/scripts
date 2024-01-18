#!/usr/bin/env sh

ffmpeg -f v4l2 -video_size 1280x720 -thread_queue_size 1024 -i /dev/video0 -f alsa -thread_queue_size 1024 -i default -c:v libx265 -crf 28 -c:a aac -b 300k ~/$(date | tr ' ' '_').mp4