mkdir -p "$BRAIN_DIR/resources/epubs" 2>/dev/null
for file in "$BRAIN_DIR/resources/"*.pdf; do
  newfile="$(basename "$file")"
  newfile="${newfile%.pdf}.epub"
  [ ! -f "$newfile" ] &&\
      ebook-convert "$file" "$BRAIN_DIR/resources/epubs/$newfile" --enable-heuristics && echo "$newfile"
done
