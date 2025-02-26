FROM swipl:9.2.9

RUN <<EOF
  set -eux

  # Install python3 for processing (and procps for pkill)
  apt-get update
  apt-get install -y --no-install-recommends \
    python3 \
    procps

  rm -rf /var/lib/apt/lists/*
  apt-get clean

  chmod 711 /mnt
  useradd -u 1000 -m runner
  mkdir /home/runner/workdir
  chown runner:runner /home/runner/workdir
EOF

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
