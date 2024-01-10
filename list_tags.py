#!/usr/bin/python3
import json
import pathlib
import os
import subprocess
import sys
import psutil
from concurrent.futures import ThreadPoolExecutor 
from signal import signal, SIGPIPE, SIG_DFL
signal(SIGPIPE,SIG_DFL)

music_dir = str(pathlib.Path.home()) + '/music/'
metadata_cmd = 'ffprobe -loglevel panic -show_entries format_tags'

AUDIO_FILE_EXTENSIONS = ['mp3', 'flac']

if len(sys.argv) > 1:
    music_dir = sys.argv[1]
else:
    print('you didnt specify a directory')
    sys.exit(1)
if len(sys.argv) > 2:
    tags_to_print = [tag.strip() for tag in sys.argv[2].split(',')]
else:
    tags_to_print = ['title', 'artist', 'album']

def get_tags(filepath):
    tags_map = json.loads(subprocess.check_output(
        ['ffprobe',
         '-loglevel',
         'panic',
         '-show_entries',
         'format_tags',
         '-of',
         'json',
         filepath]))['format']['tags']
    tags_map_lowercase = {k.lower():v for k,v in tags_map.items()}
    return tags_map_lowercase

def handle_filepath(filepath):
    tags = get_tags(filepath)
    try:
        txt = ''
        for i in range(len(tags_to_print)):
            if i == len(tags_to_print) - 1:
                txt += tags[tags_to_print[i]]
            else:
                txt += tags[tags_to_print[i]] + '\t'
        print(txt, flush=True)
    except Exception:
        print('tags not found', flush=True)

with ThreadPoolExecutor(max_workers=psutil.cpu_count()) as executor:
    for folder, subs, files in os.walk(music_dir):
        for filename in files:
            is_audio_file = False
            for audio_ext in AUDIO_FILE_EXTENSIONS:
                if filename.endswith('.' + audio_ext):
                    is_audio_file = True
            if not is_audio_file:
                continue
            filepath = os.path.join(folder, filename)
            executor.submit(handle_filepath, filepath)