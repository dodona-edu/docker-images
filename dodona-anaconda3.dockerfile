FROM continuumio/anaconda3

RUN ["chmod", "711", "/mnt"]

RUN ["useradd", "-m", "runner"]

RUN ["apt-get", "update"]
RUN ["apt-get", "-y", "install", "gcc"]
RUN ["apt-get", "-y", "install", "g++"]
RUN ["pip", "install", "--upgrade", "pylint"]
RUN ["pip", "install", "--upgrade", "jsonschema"]
RUN ["pip", "install", "--upgrade", "pyshp"]

RUN ["fc-cache", "-f"]

USER runner
RUN ["mkdir", "/home/runner/workdir"]
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
