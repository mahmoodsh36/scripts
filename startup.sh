#!/usr/bin/env sh

run_program_if_not_running() {
  pgrep $1 >/dev/null || $@
}

while true; do setxkbmap -option caps:swapescape; sleep 5; done &
while true; do setxkbmap -option ctrl:ralt_rctrl; sleep 5; done &
xrdb -load ~/.Xresources &
run_program_if_not_running sxhkd &
run_program_if_not_running feh --bg-fill ~/.cache/wallpaper
#xrdb -load ~/.Xresources
run_program_if_not_running pulseaudio -D
run_program_if_not_running picom --config ~/.config/compton.conf &

#run_program_if_not_running firefox &
#run_program_if_not_running emacs &
#pgrep spotify || spotify || flatpak run com.spotify.Client