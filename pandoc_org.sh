#!/usr/bin/env sh

infile="$1"
out_format="$2"
[ -z "$out_format" ] && out_format="html5"
[ -z "$infile" ] && echo 'usage: $0 <org file> <output format>' && exit 1
out_file=$(basename "$1")
out_file=${out_file%.*}.$out_format # get basename and replace extension with html

export infile
sed -e 's/^#+name:/#+attr_html: :id/'\
    -e 's/{equation}/{equation*}/'\
    -e 's/begin_src C++/begin_src Cpp/' "$infile" |\
    pandoc --from org\
           --to "$out_format"\
           --bibliography=$HOME/brain/bib.bib --biblatex --citeproc\
           --lua-filter $HOME/work/scripts/pandoc_links.lua\
           --lua-filter $HOME/work/scripts/pandoc_tex.lua\
           --filter $HOME/work/scripts/pandoc_roam_links.py\
           --lua-filter $HOME/work/scripts/pandoc_org_links.lua\
           --lua-filter $HOME/work/scripts/pandoc_highlight_code.lua\
           --output "$out_file"\
           --wrap=preserve\
           --metadata=suppress-bibliography:true\
           --no-highlight
#--extract-media ~/work/blog/static/\
# --self-contained\
# --include-in-header=$HOME/.emacs.d/org-head.html\
# --css=$HOME/.emacs.d/org.css\
title="$(grep '#+title' "$infile" -m 1 | cut -d ' ' -f2-)"
description="$(grep '#+description' "$infile" -m 1 | cut -d ' ' -f2-)"
date="$(timestamp_to_date.sh "$(git_creation_date.sh "$infile")")"
# append those to the beginning of the file
echo -n "+++title=\"$title\"
description=\"$description\"
date=\"$date\"
+++
$(cat "$out_file")" > "$out_file"
#[ ! -z "$description" ] &&\
#    echo -e "+++\ntitle=\"$title\"\ndescription=\"$description\"\ndate=\"$date\"\n+++\n$(cat "$out_file")" > "$out_file" ||\
#    echo -e "+++\ntitle=\"$title\"\n+++\n$(cat "$out_file")" > "$out_file"

echo "$out_file"
# keep block attrs: https://stackoverflow.com/questions/70733164/keep-custom-code-block-attributes-in-pandoc-when-converting-to-markdown