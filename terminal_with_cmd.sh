#!/usr/bin/env sh

# [ -z "$*" ] || kitty sh -c "$*"
[ -z "$*" ] || wezterm blocking-start sh -c "$*"
