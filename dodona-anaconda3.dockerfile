FROM continuumio/anaconda3:2019.10

RUN ["chmod", "711", "/mnt"]

RUN ["useradd", "-m", "runner"]

RUN ["apt-get", "update"]
RUN ["apt-get", "-y", "install", "gcc"]
RUN ["apt-get", "-y", "install", "g++"]
RUN ["apt-get", "-y", "install", "fontconfig"]
# Fix for latest version, but needs activation in runner
# RUN . /opt/conda/etc/profile.d/conda.sh && \
#    conda activate base && \
#    pip install --upgrade pylint jsonschema pyshp
RUN pip install --upgrade pylint jsonschema pyshp

RUN ["fc-cache", "-f"]

USER runner
RUN ["mkdir", "/home/runner/workdir"]
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
