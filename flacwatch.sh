#!/usr/bin/env bash
set -Eeuo pipefail

# ── Config from ENV or defaults ──────────────────────────────────────────────
WATCH_DIR="${MEDIA_DIR:-/media}"
QUALITY="${QUALITY:-2}"
DELETE="${DELETE_SOURCE:-true}"
DO_INITIAL="${INITIAL_SCAN:-true}"

# Verify tools are on PATH
for cmd in ffmpeg inotifywait; do
  command -v "$cmd" >/dev/null || { echo >&2 "❌ $cmd not found"; exit 1; }
done

convert_flac () {
  local src=$1
  local dst=${src%.flac}.mp3

  echo "🎧  $src  →  ${dst##*/}"
  ffmpeg -nostdin -loglevel error -y -i "$src" \
         -c:a libmp3lame -q:a "$QUALITY" -map_metadata 0 "$dst"

  if [[ $? -eq 0 && $DELETE == true ]]; then
    rm -- "$src"
  fi
}


# ── Optional initial sweep ───────────────────────────────────────────────────
if [[ "$DO_INITIAL" == "true" ]]; then
  shopt -s globstar nullglob
  for f in "$WATCH_DIR"/**/*.flac; do
    convert_flac "$f"
  done
fi

# ── Live watcher ─────────────────────────────────────────────────────────────
echo "📡 Watching $WATCH_DIR for new/changed *.flac ..."
inotifywait -m -r -e close_write,create,move --format '%w%f' "$WATCH_DIR" |
while read -r path; do
  [[ "$path" == *.flac ]] && convert_flac "$path"
done
