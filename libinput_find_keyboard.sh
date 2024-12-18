#!/usr/bin/env sh
libinput list-devices | awk '/AT Translated/{found=1; next} found == 1 {print $2; exit}'
