#!/usr/bin/env sh

cd ~/work/widgets/
while read line
do
  echo "$line"
done < "${1:-/dev/stdin}" | menu.py
