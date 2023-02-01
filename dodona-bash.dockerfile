FROM python:3.11.1-slim-bullseye

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        bc=1.07.1-2+b2 \
        binutils=2.35.2-2 \
        bsdmainutils=12.1.7+nmu3 \
        cowsay=3.03+dfsg2-8 \
        curl=7.74.0-1.3+deb11u5 \
        ed=1.17-1 \
        figlet=2.2.5-3+b1 \
        file=1:5.39-3 \
        fortune-mod=1:1.99.1-7.1 \
        git=1:2.30.2-1 \
        gcc=4:10.2.1-1 \
        gcc-multilib=4:10.2.1-1 \
        imagemagick=8:6.9.11.60+dfsg-1.3 \
        inkscape=1.0.2-4 \
        librsvg2-bin=2.50.3+dfsg-1 \
        poppler-utils=20.09.0-3.1+deb11u1 \
        strace=5.10-1 \
        toilet=0.3-1.3 \
        tree=1.8.0-1+b1 \
        unzip=6.0-26+deb11u1 \
        vim=2:8.2.2434-3+deb11u1 \
        wget=1.21-1+deb11u1 \
        zip=3.0-12 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    # Judge dependencies
    pip install --no-cache-dir --upgrade pygments==2.11.2 && \
    chmod 711 /mnt && \
    useradd -m runner && \
    mkdir /home/runner/workdir && \
    chown runner:runner /home/runner/workdir
ENV PATH="/home/runner/workdir:/usr/games:${PATH}"

USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
