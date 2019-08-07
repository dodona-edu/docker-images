FROM continuumio/anaconda3

USER root
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        zip \
        unzip \
        bc \
        cowsay \
        fortune-mod \
        figlet \
        toilet \
        ed \
        imagemagick \
        vim \
        tree \
        poppler-utils \
        binutils && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    chmod 711 /mnt && \
    useradd -m runner && \
    mkdir /home/runner/workdir && \
    chown runner:runner /home/runner/workdir
ENV PATH="/home/runner/workdir:/usr/games:/opt/conda/bin/:${PATH}"

USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
