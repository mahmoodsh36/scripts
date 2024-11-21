#!/usr/bin/env sh
cd ~/work/ags/; nix develop --command sh -c 'ags run -d $PWD' > ~/test 2>&1
