FROM debian:bullseye-slim

LABEL description="SinusBot - TeamSpeak 3 and Discord music bot."
LABEL version="1.0.2"

# Install dependencies and clean up afterwards
RUN apt update && apt -y upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates bzip2 unzip curl python3 procps \
    libpci3 libxslt1.1 libxkbcommon0 locales x11vnc xvfb libevent-2.1-7 liblcms2-2 libatomic1 libxcursor1 libnss3 libegl1-mesa \
    libxcb-xinerama0 libxcb-icccm4 libxcb-image0 libxcb-keysyms1 libxcb-render-util0 libxcb-xkb1 libxkbcommon-x11-0\
    libasound2 libglib2.0-0 libxcomposite-dev less jq python-is-python3 && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
# hold back
# pulseaudio fontconfig

# Set locale
RUN sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LC_ALL de_DE.UTF-8
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE:de

WORKDIR /opt/sinusbot

ADD install.sh .
RUN chmod 755 install.sh

# Download/Install SinusBot
RUN bash install.sh sinusbot

# Download/Install youtube-dl
RUN bash install.sh youtube-dl

# Download/Install Text-to-Speech
RUN bash install.sh text-to-speech

# Download/Install Text-to-Speech
RUN bash install.sh teamspeak

ADD entrypoint.sh .
RUN chmod 755 entrypoint.sh

EXPOSE 8087

VOLUME ["/opt/sinusbot/data", "/opt/sinusbot/scripts"]

ENTRYPOINT ["/opt/sinusbot/entrypoint.sh"]

HEALTHCHECK --interval=1m --timeout=10s \
  CMD curl --no-keepalive -f http://localhost:8087/api/v1/botId || exit 1
