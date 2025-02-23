#!/usr/bin/env sh
infile="$1"
if [ ! -z "$infile" ]; then
    filename="$(basename "$infile")"
    newfilename="${filename%.*}".tex
    scp "$infile" mahmooz2:/tmp/"$filename" && ssh mahmooz2 "cd work/models/got-ocr; ./run.sh /tmp/$filename" && scp mahmooz2:/tmp/got/"$newfilename" /tmp/out.tex && cat /tmp/out.tex
fi