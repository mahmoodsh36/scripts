#!/usr/bin/env sh
# record from webcam
ffmpeg -f v4l2 -video_size 1280x720 -i /dev/video0 -f alsa -i default -c:v libx265 -crf 28 -c:a aac -b 300k $(date | tr ' ' '_')_webcam.mp4