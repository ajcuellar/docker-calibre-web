# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CALIBREWEB_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="notdriz"

ENV \
  QTWEBENGINE_CHROMIUM_FLAGS="--no-sandbox"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    libldap2-dev \
    libsasl2-dev \
    python3-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install -y --no-install-recommends \
    imagemagick \
    ghostscript \
    libasound2t64 \
    libldap2 \
    libmagic1t64 \
    libsasl2-2 \
    libxi6 \
    libxslt1.1 \
    libxfixes3 \
    python3-venv \
    sqlite3 \
    xdg-utils \
    nodejs \
    npm \
    curl \
    ca-certificates \
    wget \
    espeak-ng \
    ffmpeg && \
  echo "**** install Node.js say library for audiobook generation ****" && \
  npm install -g say && \
  echo "**** install Piper TTS for high-quality voices ****" && \
  PIPER_VERSION="2023.11.14-2" && \
  wget "https://github.com/rhasspy/piper/releases/download/${PIPER_VERSION}/piper_linux_x86_64.tar.gz" -O /tmp/piper.tar.gz && \
  tar -xzf /tmp/piper.tar.gz -C /tmp && \
  cp /tmp/piper/piper /usr/local/bin/piper && \
  cp /tmp/piper/*.so* /usr/local/lib/ 2>/dev/null || true && \
  cp -r /tmp/piper/espeak-ng-data /usr/share/ 2>/dev/null || true && \
  chmod +x /usr/local/bin/piper && \
  ldconfig && \
  /usr/local/bin/piper --version && \
  rm -rf /tmp/piper /tmp/piper.tar.gz && \
  mkdir -p /app/piper-voices && \
  echo "**** install calibre-web ****" && \
  mkdir -p \
    /app/calibre-web

# Copy local calibre-web source code
COPY ../calibre-web/ /app/calibre-web/

# Update version to match actual release from build args
RUN \
  cd /app/calibre-web && \
  if [ -n "${CALIBREWEB_RELEASE}" ]; then \
    python3 update_version.py "${CALIBREWEB_RELEASE}" && \
    echo "**** Version updated to ${CALIBREWEB_RELEASE} ****"; \
  else \
    echo "**** Warning: CALIBREWEB_RELEASE not set, keeping default version ****"; \
  fi

# Fix book cover sizes in caliBlur.css
RUN \
  cd /app/calibre-web && \
  if [ -f fix_book_covers.py ]; then \
    python3 fix_book_covers.py && \
    echo "**** Book cover sizes fixed in caliBlur.css ****"; \
  else \
    echo "**** Warning: fix_book_covers.py not found ****"; \
  fi

# Add audiobook styles to caliBlur.css
RUN \
  cd /app/calibre-web && \
  if [ -f add_audiobook_styles.py ]; then \
    python3 add_audiobook_styles.py && \
    echo "**** Audiobook styles added to caliBlur.css ****"; \
  else \
    echo "**** Warning: add_audiobook_styles.py not found ****"; \
  fi

# Install Node.js dependencies for audiobook generation
RUN \
  cd /app/calibre-web && \
  npm install && \
  echo "**** Node.js dependencies installed ****"

# Download Piper voice models
RUN \
  echo "**** downloading Piper voice models ****" && \
  mkdir -p /app/piper-voices && \
  cd /app/piper-voices && \
  echo "Downloading Spanish (Spain) female voice - medium quality..." && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_ES/davefx/medium/es_ES-davefx-medium.onnx" && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_ES/davefx/medium/es_ES-davefx-medium.onnx.json" && \
  echo "Downloading Spanish (Spain) male voice - medium quality..." && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_ES/mls_10246/low/es_ES-mls_10246-low.onnx" && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_ES/mls_10246/low/es_ES-mls_10246-low.onnx.json" && \
  echo "Downloading Spanish (Latin America) voice..." && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_MX/ald/medium/es_MX-ald-medium.onnx" && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/es/es_MX/ald/medium/es_MX-ald-medium.onnx.json" && \
  echo "Downloading English (US) voices..." && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx" && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_US/lessac/medium/en_US-lessac-medium.onnx.json" && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_GB/alan/medium/en_GB-alan-medium.onnx" && \
  wget -q "https://huggingface.co/rhasspy/piper-voices/resolve/main/en/en_GB/alan/medium/en_GB-alan-medium.onnx.json" && \
  echo "**** Piper voice models downloaded ****"

# Continue with installation
RUN \
  cd /app/calibre-web && \
  python3 -m venv /lsiopy && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/ubuntu/ -r \
    requirements.txt -r \
    optional-requirements.txt && \
  echo "**** audiobook deps (ebooklib, pdfplumber, beautifulsoup4) installed from requirements.txt ****" && \
  echo "**** ensure babel is installed ****" && \
  pip install -U --no-cache-dir Babel && \
  echo "**** compile translations ****" && \
  pybabel compile -d /app/calibre-web/cps/translations && \
  echo "**** install kepubify ****" && \
  if [ -z ${KEPUBIFY_RELEASE+x} ]; then \
    KEPUBIFY_RELEASE=$(curl -sX GET "https://api.github.com/repos/pgaskin/kepubify/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /usr/bin/kepubify -L \
    https://github.com/pgaskin/kepubify/releases/download/${KEPUBIFY_RELEASE}/kepubify-linux-64bit && \
  echo "**** cleanup ****" && \
  apt-get -y purge \
    build-essential \
    libldap2-dev \
    libsasl2-dev \
    python3-dev && \
  apt-get -y autoremove && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /root/.cache

# add local files
COPY docker-calibre-web/root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-ubuntu /usr/bin/unrar

# ports and volumes
EXPOSE 8083
VOLUME /config
