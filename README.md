# flac2mp3‑watcher 📻

A minimal container that **auto‑converts FLAC files to MP3** the moment they
land in a watched directory.

## Quick start

```bash
docker run -d \
  --name flac2mp3 \
  -e QUALITY=0 \               # optional: highest VBR quality
  -e DELETE_SOURCE=false \     # keep your FLAC masters
  -v /path/to/host/music:/media \
  djlactose/flacwatch:latest
