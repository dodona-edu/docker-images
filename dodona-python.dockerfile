FROM python:3.13.7-bookworm

COPY dodona-python/ /requirements/

RUN <<EOF
  set -eux

  apt-get update
  apt-get -y install --no-install-recommends \
    emboss \
    fasta3 \
    fontconfig \
    libc6-dev \
    libcairo2-dev \
    procps \
    zlib1g-dev

  # Judge dependencies
  pip install --no-cache-dir --upgrade \
    -r /requirements/judge-pythia.txt \
    -r /requirements/judge-turtle.txt \
    -r /requirements/unclaimed.txt

  # Exercise dependencies
  pip install --no-cache-dir --upgrade -r /requirements/exercises.txt
  fc-cache -f

  rm -rf /var/lib/apt/lists/*
  apt-get clean

  chmod 711 /mnt
  useradd -m runner
  mkdir -p /home/runner/workdir
  chown -R runner:runner /home/runner
  # This is different from the other images, but no idea why. Might be removed.
  chown -R runner:runner /mnt
EOF

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
