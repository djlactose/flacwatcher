# ---------------------------------------------------------------------------
#  flac2mp3‑watcher  •  minimal Alpine image that converts *.flac → *.mp3
# ---------------------------------------------------------------------------
    FROM alpine:3.19

    LABEL org.opencontainers.image.title="flac2mp3‑watcher"
    LABEL org.opencontainers.image.description="Watches a directory for *.flac, converts to MP3, and optionally deletes the source."
    LABEL maintainer="Nick Hernandez <nickhernandez@djlactose.com>"
    
    # ---- Runtime dependencies ---------------------------------------------------
    # ffmpeg (built with libmp3lame), inotifywait, bash, coreutils, tini (PID 1)
    RUN apk add --no-cache ffmpeg inotify-tools bash coreutils tini
    
    # ---- Copy watcher script ----------------------------------------------------
    COPY flacwatch.sh /usr/local/bin/flacwatch.sh
    RUN chmod +x /usr/local/bin/flacwatch.sh
    
    # ---- Environment defaults ---------------------------------------------------
    # (comments above the block keep the continuations legal)
    # MEDIA_DIR      where the host library is mounted inside the container
    # QUALITY        LAME VBR quality 0–9 (0 = best, 9 = smallest)
    # DELETE_SOURCE  if "true", remove the .flac after a successful encode
    # INITIAL_SCAN   if "true", convert any FLACs already present at startup
    ENV MEDIA_DIR=/media \
        QUALITY=2 \
        DELETE_SOURCE=true \
        INITIAL_SCAN=true
    
    # Document the mountpoint for users/tools
    VOLUME ["/media"]
    
    # tini gives us clean signal handling (docker stop, etc.)
    ENTRYPOINT ["/sbin/tini","--","/usr/local/bin/flacwatch.sh"]
    