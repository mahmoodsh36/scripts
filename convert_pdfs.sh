mkdir -p "$BRAIN_DIR/resources/epubs" 2>/dev/null
N=10
for file in "$BRAIN_DIR/resources/"*.pdf; do
  ((i=i%N)); ((i++==0)) && wait
  # export -f handle_file
  timeout 300s bash -c '
    handle_file() {
      file="$1"
      newfile="$(basename "$file")"
      newfile="${newfile%.pdf}.epub"
      [ ! -f "$BRAIN_DIR/resources/epubs/$newfile" ] && (
        ebook-convert "$file" "$BRAIN_DIR/resources/epubs/hu_$newfile" --enable-heuristics && echo "$newfile" &
        ebook-convert "$file" "$BRAIN_DIR/resources/epubs/nohu_$newfile" && echo "$newfile"
      )
    }
    handle_file '"\"$file\"" &
done
