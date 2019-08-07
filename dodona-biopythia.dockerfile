FROM continuumio/anaconda3

RUN ["chmod", "711", "/mnt"]

RUN ["useradd", "-m", "runner"]

USER runner
RUN ["mkdir", "/home/runner/workdir"]
USER root

RUN ["apt-get", "update"]
RUN ["apt-get", "-y", "install", "gcc"]
RUN ["apt-get", "-y", "install", "g++"]
RUN ["pip", "install", "--upgrade", "pylint"]
RUN ["pip", "install", "--upgrade", "jsonschema"]
RUN ["pip", "install", "--upgrade", "pyshp"]

RUN ["apt-get", "-y", "install", "emboss"]
RUN ["pip", "install", "--upgrade", "biopython"]

WORKDIR /tmp
RUN ["apt-get", "-y", "install", "build-essential"]
RUN ["apt-get", "-y", "install", "zlib1g-dev"]
RUN ["wget", "http://faculty.virginia.edu/wrpearson/fasta/fasta3/fasta-36.3.8e.tar.gz"]
RUN ["tar", "xzvf", "fasta-36.3.8e.tar.gz"]
WORKDIR fasta-36.3.8e/src
RUN ["make", "-f", "../make/Makefile.linux64", "all"]
RUN ["sed", "-i", "/XDIR/s_= .*_= /usr/bin_", "../make/Makefile.linux64"]
RUN ["make", "-f", "../make/Makefile.linux64", "install"]
WORKDIR /
RUN ["rm", "-rf", "/tmp/fasta-36.3.8e.tar.gz", "/tmp/fasta-36.3.8e"]

RUN ["fc-cache", "-f"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
