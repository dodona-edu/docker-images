FROM node

COPY scratch.package.json /package.json
RUN ["npm", "install"]
RUN apt-get update -y -q
RUN apt-get install -y -q xvfb libgtk2.0-0 libxtst6 libxss1 libgconf-2-4 libnss3 libasound2

ENV NODE_PATH="/usr/local/lib/node_modules"

RUN ["chmod", "711", "/mnt"]
RUN ["userdel", "node"]
RUN ["useradd", "-m", "runner"]


USER runner
RUN ["mkdir", "/home/runner/workdir"]
USER root

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
COPY logger.sh /logger.sh
