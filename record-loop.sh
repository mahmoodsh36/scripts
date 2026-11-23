# continuously record the webcam into gap-free segments (one file per
# RECORD_SEGMENT secs). meant to run 24/7 as a service.
# knobs: RECORD_DEVICE SIZE FPS SEGMENT OUT FALLBACK CRF PRESET
#        MODE (copy|vaapi|x264|x265) AUDIO (pulse source, "none" to disable).
set -euo pipefail

device="${RECORD_DEVICE:-/dev/video0}"
size="${RECORD_SIZE:-1280x720}"
fps="${RECORD_FPS:-30}"
segment="${RECORD_SEGMENT:-7200}"
datadir="${DATA_DIR:-/data}"
out="${RECORD_OUT:-$datadir/wc}"
fallback="${RECORD_FALLBACK:-${HOME:-/root}/wc}"
mode="${RECORD_MODE:-x265}"
crf="${RECORD_CRF:-28}"
preset="${RECORD_PRESET:-fast}"

on_array=0
case "$out" in "$datadir" | "$datadir"/*) on_array=1 ;; esac

# when writing into the array, require it mounted (else files land on the root
# fs unnoticed under an empty mountpoint). if it's not up, record to the
# fallback; whoever mounts it restarts us. a mount unit that is deactivating
# counts as down so we don't hold files open across its umount.
mounted() {
  mountpoint -q "$datadir" || return 1
  [ -z "${DATA_MOUNT_UNIT:-}" ] || systemctl is-active --quiet "$DATA_MOUNT_UNIT"
}
using_fallback=0
if [ "$on_array" = 1 ] && ! mounted; then
  if [ -z "$fallback" ]; then
    echo "record-loop: $datadir not mounted and no RECORD_FALLBACK, refusing" >&2
    exit 1
  fi
  echo "record-loop: $datadir not mounted, using fallback $fallback" >&2
  out="$fallback"
  using_fallback=1
fi

# only call while ffmpeg isn't writing to the fallback.
migrate() {
  [ -d "$fallback" ] || return 0
  local src dst tmp
  for src in "$fallback"/*.mkv; do
    [ -f "$src" ] || continue
    dst="$out/$(basename "$src")"
    if [ -e "$dst" ]; then
      if cmp -s "$src" "$dst"; then rm -f "$src"
      else echo "record-loop: $dst exists and differs, leaving $src" >&2; fi
      continue
    fi
    tmp="$dst.part"
    if cp --preserve=timestamps "$src" "$tmp" && sync "$tmp" && cmp -s "$src" "$tmp"; then
      mv -n "$tmp" "$dst" && sync "$out" && rm -f "$src" \
        && echo "record-loop: migrated $(basename "$src")" >&2 \
        || echo "record-loop: failed to finish migrating $src" >&2
    else
      echo "record-loop: copy of $src failed verification, keeping it" >&2
      rm -f "$tmp"
    fi
  done
  return 0
}

mkdir -p "$out"
# in the background so recording starts right away; a restart kills it
# mid-copy, which only leaves a .part behind (the source is kept).
[ "$using_fallback" = 0 ] && [ "$on_array" = 1 ] && [ -n "$fallback" ] && migrate &

audio="${RECORD_AUDIO:-default}"
ain=()
if [ "$audio" != none ]; then
  if ffmpeg -nostdin -hide_banner -loglevel error -f pulse -i "$audio" -t 0.2 -f null - ; then
    ain=(-thread_queue_size 1024 -f pulse -i "$audio")
  else
    echo "record-loop: pulse source $audio unusable, recording video only" >&2
  fi
fi
aenc=()
[ ${#ain[@]} -gt 0 ] && aenc=(-map 0:v -map 1:a -c:a libopus -b:a 64k)

case "$mode" in
  copy)  venc=(-c:v copy) ;;
  vaapi) venc=(-vaapi_device /dev/dri/renderD128
               -vf "format=nv12,hwupload" -c:v h264_vaapi -qp 24) ;;
  x264)  venc=(-c:v libx264 -preset "$preset" -crf "$crf" -pix_fmt yuv420p) ;;
  # hvc1 tag so players outside matroska accept the segments
  x265)  venc=(-c:v libx265 -preset "$preset" -crf "$crf" -pix_fmt yuv420p
               -tag:v hvc1 -x265-params log-level=error) ;;
  *) echo "record-loop: unknown RECORD_MODE=$mode" >&2; exit 1 ;;
esac

cmd=(ffmpeg -nostdin -hide_banner -loglevel warning
  -thread_queue_size 512 -f v4l2 -input_format mjpeg -framerate "$fps"
  -video_size "$size" -i "$device" "${ain[@]}"
  "${venc[@]}" "${aenc[@]}"
  -f segment -segment_time "$segment" -reset_timestamps 1
  -segment_format matroska -strftime 1
  "$out/%Y-%m-%d_%H-%M-%S.mkv")

exec "${cmd[@]}"
