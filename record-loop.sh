# continuously record the webcam into gap-free segments (one file per
# RECORD_SEGMENT secs). meant to run 24/7 as a service.
# knobs: RECORD_DEVICE SIZE FPS SEGMENT OUT FALLBACK CRF PRESET
#        MODE (copy|vaapi|x264|x265).
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

# when writing into the array, require it mounted (else files land on the root
# fs unnoticed under an empty mountpoint). if it's not up, fall back to local
# disk now rather than wait; a later run re-checks and uses the array once back.
case "$out" in
  "$datadir" | "$datadir"/*)
    if ! mountpoint -q "$datadir"; then
      if [ -n "$fallback" ]; then
        echo "record-loop: $datadir not mounted, using fallback $fallback" >&2
        out="$fallback"
      else
        echo "record-loop: $datadir not mounted and no RECORD_FALLBACK, refusing" >&2
        exit 1
      fi
    fi
    ;;
esac

mkdir -p "$out"

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

exec ffmpeg -nostdin -hide_banner -loglevel warning \
  -f v4l2 -input_format mjpeg -framerate "$fps" -video_size "$size" \
  -i "$device" \
  "${venc[@]}" \
  -f segment -segment_time "$segment" -reset_timestamps 1 \
  -segment_format matroska -strftime 1 \
  "$out/%Y-%m-%d_%H-%M-%S.mkv"
