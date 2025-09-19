FROM debian:12.4-slim

ARG ANKICONNECT_VERSION=25.9.6.0
ARG ANKI_VERSION=25.09

RUN apt-get update && apt-get install -y --no-install-recommends \
        wget \
        expect \
        sqlite3 \
        zstd \
        ca-certificates \
        xdg-utils \
        libgl1 \
        libegl1 \
        libfontconfig1 \
        libdbus-1-3 \
        libxcb-xinerama0 \
        libxcb-cursor0 \
        libglib2.0-0 \
        libxkbcommon0 \
        libatomic1 \
        libnss3 \
        libxdamage1 \
        libasound2 \
        libxcomposite1 \
        libxrender1 \
        libxrandr2 \
        libxtst6 \
        libxi6 \
        libxkbfile1 \
        python3-xdg \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m anki

WORKDIR /build

ADD https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-launcher-${ANKI_VERSION}-linux.tar.zst .
ADD https://git.sr.ht/~foosoft/anki-connect/archive/${ANKICONNECT_VERSION}.tar.gz .

RUN tar --zstd -xvf anki-launcher-${ANKI_VERSION}-linux.tar.zst

RUN mkdir -p /config/addons21/AnkiConnectDev
RUN tar -xzvf ${ANKICONNECT_VERSION}.tar.gz -C /config/addons21/AnkiConnectDev --strip-components=1

WORKDIR anki-launcher-${ANKI_VERSION}-linux

RUN cat install.sh | sed 's/xdg-mime/#/' | sh -

WORKDIR /config

RUN chown -R anki /config
RUN rm -rf /build

USER anki

COPY ./launcher.exp launcher.exp
RUN expect launcher.exp ${ANKI_VERSION}

ENV QT_QPA_PLATFORM=vnc

VOLUME /config
EXPOSE 8765 5900

CMD ["anki"]
