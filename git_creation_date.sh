#!/usr/bin/env sh

# get the file's first appearance from the git repo its in

myfile="$1"
cd "$(dirname "$myfile")"
myfilename=$(basename "$myfile")
git log --follow --name-status --format=%ad --date=unix -- "$myfile" | grep -E -i "^m\\s+.*$myfilename" -A1 | tail -1