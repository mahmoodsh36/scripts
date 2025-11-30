#+/bin/env sh
# [ -S ~/data/mpv_data/sockets/mpv.socket ] && (name=$(echo "{ \"command\": [\"get_property\", \"metadata\"] }" | socat - ~/data/mpv_data/sockets/mpv.socket | jq -j ".data | .title + \" - \" + .artist + \" \" + .track + \" \" + .disc"); subtitles=$(echo '{ "command": ["get_property", "sub-text"] }' | socat - ~/data/mpv_data/sockets/mpv.socket | jq -j '.data?'); echo -n "$name $subtitles")

# exit if the mpv socket doesn't exist
[ ! -S ~/data/mpv_data/sockets/mpv.socket ] && exit

# the maximum total character length for the music info (title, artist, track, etc.)
MAX_LEN=60

# get data from mpv
# Get the entire metadata object once to be more efficient
metadata_json=$(echo '{ "command": ["get_property", "metadata"] }' | socat - ~/data/mpv_data/sockets/mpv.socket | jq -c ".data")

# Extract individual pieces
title=$(echo "$metadata_json" | jq -j '.title // ""')
artist=$(echo "$metadata_json" | jq -j '.artist // ""')
track=$(echo "$metadata_json" | jq -j '.track // ""')
disc=$(echo "$metadata_json" | jq -j '.disc // ""')

subtitles=$(echo '{ "command": ["get_property", "sub-text"] }' | socat - ~/data/mpv_data/sockets/mpv.socket | jq -j '.data? // ""')

# --- Assemble and Truncate ---
# Part 1: The long string that we might truncate
main_info="$title - $artist"

# Part 2: The short string that we will always show
track_info=""
[ -n "$track" ] && track_info=" $track"
[ -n "$disc" ] && track_info="$track_info $disc"

# Calculate the length of the track info (the part we will NOT truncate)
track_info_len=$(echo -n "$track_info" | wc -c)
main_info_len=$(echo -n "$main_info" | wc -c)

# Calculate the maximum allowed length for the main_info part
max_main_len=$((MAX_LEN - track_info_len))

# Truncate the main_info if it's longer than the space available for it
if [ "$main_info_len" -gt "$max_main_len" ]; then
  trunc_len=$((max_main_len - 3)) # Reserve 3 chars for "..."
  # Ensure we don't try to cut a negative length
  [ "$trunc_len" -lt 1 ] && trunc_len=1

  truncated_main_info=$(echo "$main_info" | cut -c1-"$trunc_len")...
else
  truncated_main_info="$main_info"
fi

# Combine the truncated main part and the track part
final_music_info="$truncated_main_info$track_info"

# --- Final Output ---
if [ -n "$final_music_info" ] && [ -n "$subtitles" ]; then
  echo -n "$final_music_info $subtitles"
else
  echo -n "$final_music_info$subtitles"
fi