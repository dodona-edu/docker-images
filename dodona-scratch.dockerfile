FROM buildkite/puppeteer

RUN ["npm", "install", "-g", "fs"]
RUN ["apt-get", "update"]

ENV NODE_PATH="/usr/local/lib/node_modules"

RUN ["chmod", "711", "/mnt"]
RUN ["userdel", "node"]
RUN ["useradd", "-m", "runner"]

USER runner
RUN ["mkdir", "/home/runner/workdir"]
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
