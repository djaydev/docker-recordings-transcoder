# djaydev/recordings-converter

FROM lsiobase/ubuntu:bionic
RUN apt update && \
apt install --no-install-recommends \
    coreutils findutils expect tcl8.6 \
    mediainfo libfreetype6 libc6 libutf8proc2 \
    libtesseract4 libpng16-16 liblept5 libva2 \
    libva-drm2 i965-va-driver expat libgomp1 \
    libxcb1 libxcb-shape0 -y && \
# cleanup
apt-get autoremove -y && \
apt-get clean && \
rm -rf \
  /tmp/* \
  /var/lib/apt/lists/*

# Copy ccextractor
COPY --from=djaydev/ccextractor:latest /usr/local/bin /usr/local/bin
# Copy ffmpeg
COPY --from=djaydev/ffmpeg /usr/local/ /usr/local/

# Copy the start scripts.
COPY rootfs/ /
COPY /scripts /scripts
RUN rm /etc/cont-init.d/10-adduser && curl -sL https://raw.githubusercontent.com/linuxserver/docker-plex/master/root/etc/cont-init.d/50-gid-video -o /etc/cont-init.d/50-gid-video
ENV ENCODER=software \
    SUBTITLES=1 \
    DELETE_TS=0 \
    PUID=99 \
    PGID=100 \
    UMASK=000 \
    AUTOMATED_CONVERSION_FORMAT="mp4"
