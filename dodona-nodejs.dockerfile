FROM node:14.4.0-buster-slim

RUN chmod 711 /mnt && \
    groupmod -n runner node && \
    usermod -l runner -d /home/runner node && \
    mkdir -p /home/runner/workdir && \
    chown -R runner:runner /home/runner && \
    chown -R runner:runner /mnt && \
    npm install -g deep-equal@1.1.0 eslint@6.6.0 --save-dev

ENV NODE_PATH="/usr/local/lib/node_modules"
USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
