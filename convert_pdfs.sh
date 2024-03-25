mkdir -p "$BRAIN_DIR/resources/epubs" 2>/dev/null
N=10
for file in "$BRAIN_DIR/resources/"*.pdf; do
  ((i=i%N)); ((i++==0)) && wait
  # export -f handle_file
  timeout 500s bash -c '
    handle_file() {
      file="$1"
      newfile="$(basename "$file")"
      newfile="${newfile%.pdf}.epub"
      newfile_fullpath="$BRAIN_DIR/resources/epubs/$newfile"
      [ ! -f "$newfile_fullpath" ] && (
        ebook-convert "$file" hu_"$newfile_fullpath" --enable-heuristics && echo "$newfile"
        ebook-convert "$file" nohu_"$newfile_fullpath" && echo "$newfile"
      )
    }
    handle_file '"\"$file\"" &
done
