# djaydev/recordings-converter

FROM ubuntu:19.10

WORKDIR /tmp

RUN apt update && \
    apt install --no-install-recommends \
      coreutils findutils expect tcl8.6 \
      mediainfo libfreetype6 libutf8proc2 \
      libtesseract4 libpng16-16 expat \
      libva-drm2 i965-va-driver \
      libxcb-shape0 libssl1.1 -y && \
    useradd -u 911 -U -d /config -s /bin/false abc && \
    usermod -G users abc && \
    mkdir /config && \
# cleanup
    apt autoremove -y && \
    apt clean -y && \
    rm -rf /tmp/* /var/lib/apt/lists/*

# Copy ccextractor
COPY --from=djaydev/ccextractor /usr/local/bin /usr/local/bin
# Copy ffmpeg
COPY --from=djaydev/ffmpeg /usr/local/ /usr/local/
# Copy S6-Overlay
COPY --from=djaydev/baseimage-s6overlay:amd64 /tmp/ /
# Copy script for Intel iGPU permissions
COPY --from=linuxserver/plex /etc/cont-init.d/50-gid-video /etc/cont-init.d/50-gid-video

# Copy the start scripts.
COPY rootfs/ /

ENV ENCODER=software \
    SUBTITLES=1 \
    DELETE_TS=0 \
    PUID=99 \
    PGID=100 \
    UMASK=000 \
    AUTOMATED_CONVERSION_FORMAT="mp4" \
    NVIDIA_VISIBLE_DEVICES=all \
    NVIDIA_DRIVER_CAPABILITIES=all

ENTRYPOINT ["/init"]
