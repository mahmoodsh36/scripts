#!/usr/bin/env sh
[ -z "$1" ] && exit
find "$1" -type d -print0 | xargs -0 chmod 0775
find "$1" -type f -print0 | xargs -0 chmod 0664