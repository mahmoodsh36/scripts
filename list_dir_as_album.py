#!/usr/bin/env mypython
import os
import sys
import json
import subprocess
import magic

destdir = sys.argv[1] if sys.argv[1:] else '.'
tracks = []
to_sort = True
def listdir_fullpath(d):
    return [os.path.join(d, f) for f in os.listdir(d)]
for myfile in listdir_fullpath(destdir):
    mymagic = magic.Magic(mime=True)
    mymime = mymagic.from_file(myfile).lower()
    if mymime.find('video') == -1 and mymime.find('audio') == -1:
        continue
    try:
        out = subprocess.check_output(['ffprobe',
                                       '-loglevel', 'error',
                                       '-show_entries', 'format_tags=track,disc',
                                       '-print_format', 'json',
                                       myfile])
        data = json.loads(out)
    except:
        continue
    try:
        tracks.append((myfile,
                    eval(data['format']['tags']['track']),
                    eval(data['format']['tags']['disc']),))
    except:
        tracks.append((myfile,))
        to_sort = False
if to_sort:
    tracks.sort(key=lambda track: track[1])
    tracks.sort(key=lambda track: track[2])
[print(track[0]) for track in tracks]