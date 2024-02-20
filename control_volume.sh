#!/usr/bin/env sh
# set volume, e.g. ./control_volume +3%, sets volume for all sinks, with no arg simply prints volume of an arbitrary sink

get_volume() {
  pactl list sinks | grep '^[[:space:]]Volume:' | head -n $(( $SINK + 1 )) | tail -n 1 | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,'
}

change="$1"
[[ ! -z "$change" ]] && pactl list sinks | grep Name | cut -d ':' -f2 | cut -c2- | while read sinkname; do pactl set-sink-volume "$sinkname" "$change"; done
get_volume