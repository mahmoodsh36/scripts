#!/usr/bin/env sh

cd ~/work/
sh -c "$(echo $PATH | tr ':' '\n' | while read the_dir; do ls --color=no "$the_dir"; done | sort -u | menu.py)"