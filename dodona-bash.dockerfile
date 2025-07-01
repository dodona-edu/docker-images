FROM python:3.13.5-slim-bookworm

RUN  <<EOF
  set -eux

  apt-get update

  apt-get -y install --no-install-recommends \
    bc \
    binutils \
    bsdmainutils \
    cowsay \
    chromium \
    curl \
    ed \
    figlet \
    file \
    fonts-noto-color-emoji \
    fortune-mod \
    git \
    gcc \
    imagemagick \
    inkscape \
    librsvg2-bin \
    poppler-utils \
    procps \
    strace \
    toilet \
    tree \
    unzip \
    vim \
    wget \
    zip

  rm -rf /var/lib/apt/lists/*
  apt-get clean

  # Judge dependencies
  pip install --no-cache-dir --upgrade pygments==2.11.2
  pip install --no-cache-dir --upgrade html2image==2.0.4.3

  chmod 711 /mnt
  useradd -m runner
  mkdir /home/runner/workdir
  chown runner:runner /home/runner/workdir
EOF

ENV PATH="/home/runner/workdir:/usr/games:${PATH}"

USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
