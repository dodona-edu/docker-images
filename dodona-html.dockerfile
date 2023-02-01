FROM python:3.11.1-slim-bullseye

RUN apt-get update && \
    # install procps, otherwise pkill cannot be not found
    apt-get -y install --no-install-recommends \
        procps=2:3.3.17-5 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    chmod 711 /mnt && \
    useradd -m runner && \
    mkdir -p /home/runner/workdir && \
    chown -R runner:runner /home/runner && \
    chown -R runner:runner /mnt && \
    pip install --no-cache-dir --upgrade \
        beautifulsoup4==4.10.0 \
        cssselect==1.1.0 \
        lxml==4.8.0 \
        tinycss2==1.1.1 \
        py-emmet==1.1.10 \
        html-similarity==0.3.3 \
        colour==0.1.5

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
