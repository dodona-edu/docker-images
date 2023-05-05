FROM python:3.11.2-slim-bullseye

RUN chmod 711 /mnt && \
  useradd -m runner && \
  apt-get update && \
  apt-get -y install --no-install-recommends \
     emboss=6.6.0+dfsg-9 \
     gcc=4:10.2.1-1 \
     g++=4:10.2.1-1 \
     fontconfig=2.13.1-4.2 \
     libc6-dev=2.31-13+deb11u6 \
     libcairo2-dev=1.16.0-5 \
     make=4.3-4.1 \
     procps=2:3.3.17-5 \
     wget=1.21-1+deb11u1 \
     zlib1g-dev=1:1.2.11.dfsg-2+deb11u2 && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean && \
  # Judge dependencies
  pip install --no-cache-dir --upgrade \
    Pillow==9.4.0 \
    cairosvg==2.6.0 \
    jsonschema==4.17.3 \
    mako==1.2.4 \
    psutil==5.9.4 \
    pydantic==1.10.4 \
    pyhumps==3.8.0 \
    pylint==2.16.1 \
    pyshp==2.3.1 \
    svg-turtle==0.4.1 \
    typing-inspect==0.8.0 && \
  # Exercise dependencies
  pip install --no-cache-dir --upgrade numpy==1.24.2 biopython==1.81 sortedcontainers==2.4.0 pandas==1.5.3

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
  apt-get -y purge --autoremove gcc g++ make wget && \
  mkdir -p /home/runner/workdir && \
  chown -R runner:runner /home/runner && \
  chown -R runner:runner /mnt

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
