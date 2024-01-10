#!/usr/bin/env sh
in="$1"
out=$(basename "$1").tex
headers_file=/tmp/org_to_html.tex
echo '\usepackage{\string~/.emacs.d/common}' > "$headers_file"
pandoc $1 -s --include-in-header "$headers_file" -o "$out"
lualatex "$out"