FROM debian:12.4-slim

ARG ANKICONNECT_VERSION=25.9.6.0
ARG ANKI_VERSION=25.09

RUN apt-get update && \
    apt-get install -y \
        wget \
        expect \
        sqlite3 \
        zstd \
        ca-certificates \
        xdg-utils \
        libxcb-xinerama0 \
        libxcb-cursor0 \
        libglib2.0-0 \
        libxkbcommon0 \
        libatomic1 \
        libnss3 \
        libxdamage1 \
        libasound2 \
        python3-xdg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN ls -la

WORKDIR /build/launcher

RUN wget https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-launcher-${ANKI_VERSION}-linux.tar.zst -O - | \
    tar --zstd -xvf - -C . --strip-components=1

RUN ls -la

RUN cat install.sh | sed 's/xdg-mime/#/' | sh -

COPY ./launcher.exp launcher.exp
RUN expect launcher.exp ${ANKI_VERSION}

WORKDIR /build/anki-connect

RUN wget https://git.sr.ht/~foosoft/anki-connect/archive/${ANKICONNECT_VERSION}.tar.gz -O - | \
    tar -xzvf - -C . --strip-components=1

RUN ls -la

WORKDIR /config/addons21
RUN mv /build/anki-connect AnkiConnectDev

WORKDIR /config
RUN rm -rf /build

VOLUME /config
EXPOSE 5900 8765

ENV QT_QPA_PLATFORM="vnc"
CMD ["anki"]
