FROM swipl:9.0.4

# Install python3 for processing (and procps for pkill)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3=3.9.2-3 \
        procps=2:3.3.17-5 \
        && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    chmod 711 /mnt && \
    useradd -u 1000 -m runner && \
    mkdir /home/runner/workdir && \
    chown runner:runner /home/runner/workdir

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
