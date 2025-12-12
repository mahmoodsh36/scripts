#!/usr/bin/env sh

[ -z "$1" ] && exit 1

find "$1" -type d -exec chmod 0755 {} +
find "$1" -type f -exec chmod 0644 {} +
