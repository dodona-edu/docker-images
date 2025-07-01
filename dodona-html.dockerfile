FROM python:3.13.5-slim-bookworm

RUN <<EOF
  set -eux

  apt-get update

  # install procps, otherwise pkill cannot be not found
  apt-get -y install --no-install-recommends \
    procps=2:4.0.2-3

  rm -rf /var/lib/apt/lists/*
  apt-get clean

  chmod 711 /mnt
  useradd -m runner
  mkdir -p /home/runner/workdir
  chown -R runner:runner /home/runner
  chown -R runner:runner /mnt


  pip install --no-cache-dir --upgrade \
    beautifulsoup4==4.13.3 \
    cssselect==1.2.0 \
    lxml==5.3.1 \
    tinycss2==1.4.0 \
    py-emmet==1.3.1 \
    html-similarity==0.3.3 \
    colour==0.1.5
EOF

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
