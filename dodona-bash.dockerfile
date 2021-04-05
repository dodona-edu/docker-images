FROM python:3.9.3-slim-buster

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        bc=1.07.1-2+b1 \
        binutils=2.31.1-16 \
        bsdmainutils=11.1.2+b1 \
        cowsay=3.03+dfsg2-6 \
        curl=7.64.0-4+deb10u1 \
        ed=1.15-1 \
        figlet=2.2.5-3 \
        file=1:5.35-4+deb10u2 \
        fortune-mod=1:1.99.1-7+b1 \
        git=1:2.20.1-2+deb10u3 \
        gcc=4:8.3.0-1 \
        gcc-multilib=4:8.3.0-1 \
        imagemagick=8:6.9.10.23+dfsg-2.1+deb10u1 \
        librsvg2-bin=2.44.10-2.1 \
        poppler-utils=0.71.0-5 \
        strace=4.26-0.2 \
        toilet=0.3-1.2 \
        tree=1.8.0-1 \
        unzip=6.0-23+deb10u2 \
        vim=2:8.1.0875-5 \
        wget=1.20.1-1.1 && \
        zip=3.0-11+b1 \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    # Judge dependencies
    pip install --upgrade pygments==2.4.2 && \
    chmod 711 /mnt && \
    useradd -m runner && \
    mkdir /home/runner/workdir && \
    chown runner:runner /home/runner/workdir
ENV PATH="/home/runner/workdir:/usr/games:${PATH}"

USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
