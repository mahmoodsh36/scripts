#!/usr/bin/env python
import os
import sys
import json
import subprocess
destdir = sys.argv[1] if sys.argv[1:] else '.'
tracks = []
def listdir_fullpath(d):
    return [os.path.join(d, f) for f in os.listdir(d)]
for myfile in listdir_fullpath(destdir):
    if not myfile.endswith('.mp3'):
        continue
    out = subprocess.check_output(['ffprobe',
                                   '-loglevel', 'error',
                                   '-show_entries', 'format_tags=track,disc',
                                   '-print_format', 'json',
                                   myfile])
    data = json.loads(out)
    tracks.append((myfile,
                   eval(data['format']['tags']['track']),
                   eval(data['format']['tags']['disc']),))
tracks.sort(key=lambda track: track[1])
tracks.sort(key=lambda track: track[2])
[print(track[0]) for track in tracks]
