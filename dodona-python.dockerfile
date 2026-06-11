FROM python:3.12.9-bookworm

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
    Pillow==12.2.0 \
    cairosvg==2.9.0 \
    jsonschema==4.26.0 \
    mako==1.3.12 \
    psutil==7.2.2 \
    pydantic==2.13.4 \
    pyhumps==3.8.0 \
    pylint==4.0.5 \
    pyshp==3.0.9 \
    setuptools==82.0.1 \
    svg-turtle==1.1.0 \
    typing-inspect==0.9.0

  # Exercise dependencies
  pip install --no-cache-dir --upgrade numpy==2.4.6 biopython==1.87 sortedcontainers==2.4.0 pandas==3.0.3 matplotlib==3.10.9
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
