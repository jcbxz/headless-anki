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
        mecab \
        mpv \
        locales \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m anki

WORKDIR /build

# Download Anki
ADD https://github.com/ankitects/anki/releases/download/${ANKI_VERSION}/anki-launcher-${ANKI_VERSION}-linux.tar.zst .
RUN tar --zstd -xvf anki-launcher-${ANKI_VERSION}-linux.tar.zst

# Download AnkiConnect
ADD https://git.sr.ht/~foosoft/anki-connect/archive/${ANKICONNECT_VERSION}.tar.gz .
RUN tar -xzvf ${ANKICONNECT_VERSION}.tar.gz

# Install Anki
WORKDIR anki-launcher-${ANKI_VERSION}-linux
RUN cat install.sh | sed 's/xdg-mime/#/' | sh -

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

WORKDIR /config

RUN mkdir -p addons21/AnkiConnect
RUN mv /build/anki-connect-${ANKICONNECT_VERSION}/plugin addons21/AnkiConnect

RUN chown -R anki .
RUN rm -rf /build

USER anki

ENV ANKI_BASE=/config
ENV QT_QPA_PLATFORM=vnc
ENV LANG=en_US.UTF-8 LANGUAGE=en_US LC_ALL=en_US.UTF-8
ENV FONTCONFIG_PATH=/etc/fonts

# Run the first time launcher
COPY ./launcher.exp launcher.exp
RUN expect launcher.exp ${ANKI_VERSION}

VOLUME /config
EXPOSE 8765 5900

CMD ["anki"]
