FROM python:3.10.1-slim-buster

RUN chmod 711 /mnt && \
  useradd -m runner && \
  apt-get update && \
  apt-get -y install --no-install-recommends \
     emboss=6.6.0+dfsg-7+b1 \
     gcc=4:8.3.0-1 \
     g++=4:8.3.0-1 \
     fontconfig=2.13.1-2 \
     libc6-dev=2.28-10 \
     make=4.2.1-1.2 \
     wget=1.20.1-1.1 \
     zlib1g-dev=1:1.2.11.dfsg-1 && \
  rm -rf /var/lib/apt/lists/* && \
  apt-get clean && \
  # Judge dependencies
  pip install --no-cache-dir --upgrade pylint==2.6.0 jsonschema==3.2.0 pyshp==2.1.2 psutil==5.7.3 mako==1.1.3 pydantic==1.5.1 pyhumps==1.6.1 typing_inspect==0.6.0 && \
  # Exercise dependencies
  pip install --no-cache-dir --upgrade numpy==1.19.4 biopython==1.78 sortedcontainers==2.2.2 pandas==1.1.4

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
