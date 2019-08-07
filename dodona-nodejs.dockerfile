FROM node

RUN ["npm", "install", "-g", "fs"]
RUN ["npm", "install", "-g", "deep-equal"]
RUN ["npm", "install", "-g",  "eslint", "--save-dev"]

RUN ["apt-get", "update"]
RUN ["apt-get", "-y", "install", "vim"]
ENV NODE_PATH="/usr/local/lib/node_modules"

RUN ["chmod", "711", "/mnt"]
RUN ["userdel", "node"]
RUN ["useradd", "-m", "runner"]


USER runner
RUN ["mkdir", "/home/runner/workdir"]
USER root

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
