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
    ca-certificates && \
  echo "**** install Node.js say library for audiobook generation ****" && \
  npm install -g say && \
  echo "**** install calibre-web ****" && \
  mkdir -p \
    /app/calibre-web

# Copy local calibre-web source code
COPY calibre-web/ /app/calibre-web/

# Update version to match actual release from build args
RUN \
  cd /app/calibre-web && \
  if [ -n "${CALIBREWEB_RELEASE}" ]; then \
    python3 update_version.py "${CALIBREWEB_RELEASE}" && \
    echo "**** Version updated to ${CALIBREWEB_RELEASE} ****"; \
  else \
    echo "**** Warning: CALIBREWEB_RELEASE not set, keeping default version ****"; \
  fi

# Revert image sizes in caliBlur_override.css to original 150px
RUN \
  cd /app/calibre-web && \
  if [ -f revert_image_sizes.py ]; then \
    python3 revert_image_sizes.py && \
    echo "**** Image sizes reverted to 150px in caliBlur_override.css ****"; \
  else \
    echo "**** Warning: revert_image_sizes.py not found, skipping image size reversion ****"; \
  fi

# Install Node.js dependencies for audiobook generation
RUN \
  cd /app/calibre-web && \
  npm install && \
  echo "**** Node.js dependencies installed ****"

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
