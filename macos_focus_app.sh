#!/usr/bin/env bash

open -a "$1"
osascript -e "tell application \"System Events\" to tell process \"$1\"" \
  -e 'set frontmost to true' \
  -e 'end tell'