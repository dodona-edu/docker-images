FROM python:3.12.9-slim-bookworm

COPY dodona-sqlite/requirements.txt /requirements.txt

RUN <<EOF
  set -eux

  apt-get update

  # install procps, otherwise pkill cannot be not found
  apt-get -y install --no-install-recommends \
    procps=2:4.0.2-3 \
    sqlite3=3.40.1-2+deb12u2

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
