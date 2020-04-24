FROM buildkite/puppeteer:v3.0.1

RUN chmod 711 /mnt && \
    groupmod -n runner node && \
    usermod -l runner -d /home/runner node && \
    mkdir -p /home/runner/workdir && \
    chown -R runner:runner /home/runner && \
    chown -R runner:runner /mnt

ENV NODE_PATH="/usr/local/lib/node_modules"
USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
