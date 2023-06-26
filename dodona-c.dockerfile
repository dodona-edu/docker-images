FROM python:3.11.4-slim-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
                       jshon=20131010-3+b1 \
                       libgtest-dev=1.10.0.20201025-1.1 \
                       g++=4:10.2.1-1 \
                       make=4.3-4.1 \
                       cmake=3.18.4-2+deb11u1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    chmod 711 /mnt && \
    useradd -m runner

WORKDIR /usr/src/gtest

RUN cmake CMakeLists.txt && \
    make && \
    cp -- lib/*.a /usr/lib && \
    mkdir /usr/local/lib/gtest && \
    ln -s /usr/lib/libgtest.a /usr/local/lib/gtest && \
    ln -s /usr/lib/libgtest_main.a /usr/local/lib/gtest
    
# As the runner user
USER runner
RUN mkdir /home/runner/workdir
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
