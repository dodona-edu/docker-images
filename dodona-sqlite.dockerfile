FROM python:3.13.0-slim-bullseye

RUN apt-get update && \
    # install procps, otherwise pkill cannot be not found
    apt-get -y install --no-install-recommends \
        procps=2:3.3.17-5 \
        sqlite3=3.34.1-3 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean && \
    chmod 711 /mnt && \
    useradd -m runner && \
    mkdir -p /home/runner/workdir && \
    chown -R runner:runner /home/runner && \
    chown -R runner:runner /mnt && \
    pip install --no-cache-dir --upgrade \
        pandas==2.1.1 \
        sqlparse==0.4.4

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
