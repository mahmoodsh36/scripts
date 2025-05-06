#!/usr/bin/env sh

while read line
do
  echo "$line"
done < "${1:-/dev/stdin}" | gtkpython $WORK_DIR/widgets/menu.py