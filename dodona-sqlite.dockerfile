FROM python:3.13.2-slim-bookworm

RUN <<EOF
  set -eux

  apt-get update

  # install procps, otherwise pkill cannot be not found
  apt-get -y install --no-install-recommends \
    procps=2:4.0.2-3 \
    sqlite3=3.40.1-2+deb12u1

  rm -rf /var/lib/apt/lists/*
  apt-get clean

  chmod 711 /mnt
  useradd -m runner
  mkdir -p /home/runner/workdir
  chown -R runner:runner /home/runner
  chown -R runner:runner /mnt

  pip install --no-cache-dir --upgrade \
    pandas==2.1.1 \
    numpy==1.26.4 \
    sqlparse==0.4.4
EOF

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
