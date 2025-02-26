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
    Pillow==10.0.1 \
    cairosvg==2.7.1 \
    jsonschema==4.19.1 \
    mako==1.2.4 \
    psutil==5.9.5 \
    pydantic==2.4.2 \
    pyhumps==3.8.0 \
    pylint==3.0.1 \
    pyshp==2.3.1 \
    setuptools \
    svg-turtle==0.4.2 \
    typing-inspect==0.9.0

  # Exercise dependencies
  pip install --no-cache-dir --upgrade numpy==1.26.0 biopython==1.81 sortedcontainers==2.4.0 pandas==2.1.1
  fc-cache -f

  rm -rf /var/lib/apt/lists/*
  apt-get clean

  chmod 711 /mnt
  useradd -m runner
  mkdir -p /home/runner/workdir
  chown -R runner:runner /home/runner
  chown -R runner:runner /mnt
EOF

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
