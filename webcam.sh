#!/usr/bin/env sh
# record from webcam, use mkv because it can handle interruptions and still be playable, unlike mp4
ffmpeg -f v4l2 -video_size 1280x720 -i /dev/video0 -f alsa -i default -c:v libx265 -crf 28 -c:a aac -b 300k $(date | tr ' ' '_')_webcam.mkv
