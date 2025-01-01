#!/usr/bin/env sh
sudo libinput debug-events --show-keycodes |\
  sed -u -n 's/.*KEYBOARD_KEY.*(\([0-9]\+\)) \(released\|pressed\)/\1 \2/p' |\
  while read key; do
    if [[ $key =~ "released" ]]; then
      keycode="$(echo "$key" | cut -d ' ' -f1):1"
    else
      keycode="$(echo "$key" | cut -d ' ' -f1):0"
    fi
    echo got: $keycode;
  done
