FROM swipl:8.0.3

# Install python3 for processing
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3=3.5.3-1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    chmod 711 /mnt && \
    useradd -u 1000 -m runner && \
    mkdir /home/runner/workdir && \
    chown runner:runner /home/runner/workdir

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
