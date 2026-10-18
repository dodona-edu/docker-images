FROM python:3.15.0-slim-trixie

COPY dodona-bash/requirements.txt /requirements.txt

RUN  <<EOF
  set -eux

  apt-get update

  apt-get -y install --no-install-recommends \
    bc \
    binutils \
    bsdmainutils \
    cowsay \
    curl \
    ed \
    figlet \
    file \
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

  pip install --no-cache-dir --upgrade -r /requirements.txt

  chmod 711 /mnt
  useradd -m runner
  mkdir /home/runner/workdir
  chown runner:runner /home/runner/workdir
EOF

ENV PATH="/home/runner/workdir:/usr/games:${PATH}"

USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
