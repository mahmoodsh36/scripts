#!/usr/bin/env sh
# libinput list-devices | awk '/AT Translated/{found=1; next} found == 1 {print $2; exit}'
symlink="$(find /dev/input/by-path -maxdepth 1 -name '*event-kbd' | head -1)"
readlink -f "$symlink"