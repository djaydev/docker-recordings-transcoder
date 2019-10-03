# djaydev/recordings-converter

FROM ubuntu:18.04

WORKDIR /tmp

RUN apt update && \
    apt install --no-install-recommends \
      coreutils findutils expect tcl8.6 \
      mediainfo libfreetype6 libutf8proc2 \
      libtesseract4 libpng16-16 expat \
      libva-drm2 i965-va-driver \
      libxcb-shape0 libssl1.1 wget -y && \
    wget --no-check-certificate -O s6-overlay.tar.gz https://github.com/just-containers/s6-overlay/releases/download/v1.22.1.0/s6-overlay-amd64.tar.gz && \
    tar xzf s6-overlay.tar.gz -C / && \
    useradd -u 911 -U -d /config -s /bin/false abc && \
    usermod -G users abc && \
    mkdir /config && \
# cleanup
    apt-get remove wget -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/*

# Copy ccextractor
COPY --from=djaydev/ccextractor /usr/local/bin /usr/local/bin
# Copy ffmpeg
COPY --from=djaydev/ffmpeg /usr/local/ /usr/local/

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