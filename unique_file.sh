#!/usr/bin/env sh

# generate a unique filename, doesnt create the file itself
# usage: ./<script> [filename] [extension]

unique_file() {
  name=$1
  ext=$2
  if [[ -e "$name.$ext" || -L "$name.$ext" ]]; then
    i=0
    while [[ -e "$name-$i.$ext" || -L "$name-$i.$ext" ]]; do
      let i++
    done
    name=$name-$i
  fi
  echo "$name.$ext"
}

# ext=""
# [ ! -z "$2" ] && ext="$2"
ext="$2"
filename="$1"
[ -z "$filename" ] && filename=$my_unique
unique_file "$filename" "$ext"
