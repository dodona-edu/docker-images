FROM python:3.13.7-slim-bookworm

COPY dodona-html/requirements.txt /requirements.txt

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


  pip install --no-cache-dir --upgrade -r /requirements.txt
EOF

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
