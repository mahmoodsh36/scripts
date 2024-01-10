#!/usr/bin/env sh

outdir="$1"
[ -z "$outdir" ] && outdir="." || mkdir -p "$outdir"
notes_dir=~/brain/notes
out_format="$2"
[ -z "$out_format" ] && out_format="html"
tag="$3"
[ -z "$tag" ] && tag="public-archive"

do_parallel=true

cd "$outdir"
N=20
(
for note in $(grep -iR "^#+filetags:.*:$tag:.*" --color=never --files-with-matches --include "[^\.]*.org" "$notes_dir"); do
    if [ $do_parallel = true ]; then
        ((i=i%N)); ((i++==0)) && wait
        pandoc_org.sh "$note" "$out_format" &
    else
        pandoc_org.sh "$note" "$out_format"
    fi
done
)