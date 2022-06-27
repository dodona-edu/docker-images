FROM python:3.10.5-slim-bullseye

RUN chmod 711 /mnt && \
  useradd -m runner && \
  apt-get update && \
  apt-get -y install --no-install-recommends \
     emboss=6.6.0+dfsg-9 \
     gcc=4:10.2.1-1 \
     g++=4:10.2.1-1 \
     fontconfig=2.13.1-4.2 \
     libc6-dev=2.31-13+deb11u3 \
     libcairo2=1.16.0-5 \
     make=4.3-4.1 \
     procps=2:3.3.17-5 \
     wget=1.21-1+deb11u1 \
     zlib1g-dev=1:1.2.11.dfsg-2+deb11u1 && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean && \
  # Judge dependencies
  pip install --no-cache-dir --upgrade \
    Pillow==9.1.1 \
    cairosvg==2.5.2 \
    jsonschema==4.6.0 \
    mako==1.2.0 \
    psutil==5.9.1 \
    pydantic==1.9.1 \
    pyhumps==3.7.2 \
    pylint==2.14.3 \
    pyshp==2.3.0 \
    svg-turtle==0.4.1 \
    typing_inspect==0.7.1 && \
  # Exercise dependencies
  pip install --no-cache-dir --upgrade numpy==1.23.0 biopython==1.79 sortedcontainers==2.4.0 pandas==1.4.3

WORKDIR /tmp

RUN wget --progress=dot:giga -O fasta-36.3.8h.tar.gz https://github.com/wrpearson/fasta36/archive/refs/tags/v36.3.8h_04-May-2020.tar.gz && \
  tar xzf fasta-36.3.8h.tar.gz

WORKDIR /tmp/fasta36-36.3.8h_04-May-2020/src

RUN make -f ../make/Makefile.linux64 all && \
  sed -i "/XDIR/s#= .*#= /usr/bin#" ../make/Makefile.linux64 && \
  make -f ../make/Makefile.linux64 install

WORKDIR /tmp

RUN rm fasta-36.3.8h.tar.gz fasta36-36.3.8h_04-May-2020 -r && \
  fc-cache -f && \
  apt-get -y purge --autoremove gcc g++ libc6-dev make wget zlib1g-dev && \
  mkdir -p /home/runner/workdir && \
  chown -R runner:runner /home/runner && \
  chown -R runner:runner /mnt

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
