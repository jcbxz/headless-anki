FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbookworm

ARG ANKICONNECT_VERSION=25.9.6.0
ARG ANKI_VERSION=25.09

RUN apt update && apt install --no-install-recommends -y \
        wget zstd mpv locales curl git ca-certificates jq libxcb-xinerama0 libxcb-cursor0 libnss3 \
        libxcomposite-dev libxdamage-dev libxtst-dev libxkbcommon-dev libxkbfile-dev expect libatomic1

COPY ./root /

VOLUME /config
VOLUME /data
VOLUME /export

WORKDIR /app

RUN wget -O ANKI.tar.zst --no-check-certificate https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-launcher-${ANKI_VERSION}-linux.tar.zst && \
    zstd -d ANKI.tar.zst && rm ANKI.tar.zst && \
    tar xfv ANKI.tar && rm ANKI.tar

WORKDIR /app/anki-launcher-${ANKI_VERSION}-linux

# Run modified install.sh
RUN cat install.sh | sed 's/xdg-mime/#/' | sh -

# Post process
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8 \ LANGUAGE=en_US \ LC_ALL=en_US.UTF-8

RUN apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Run the anki launcher
RUN expect launcher.exp ${ANKI_VERSION}

# Plugin installation
RUN curl -L https://git.sr.ht/~foosoft/anki-connect/archive/${ANKICONNECT_VERSION}.tar.gz | \
    tar -xz && \
    mv anki-connect-${ANKICONNECT_VERSION} anki-connect

RUN ln -s -f /app/anki-connect/plugin /data/addons21/AnkiConnectDev

# Edit AnkiConnect config
RUN jq '.webBindAddress = "0.0.0.0"' /data/addons21/AnkiConnectDev/config.json > tmp_file && \
    mv tmp_file /data/addons21/AnkiConnectDev/config.json

ENV ANKICONNECT_WILDCARD_ORIGIN="0"
ENV FONTCONFIG_PATH=/etc/fonts
ENV QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb

EXPOSE 3000 8765
