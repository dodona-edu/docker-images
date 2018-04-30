FROM node

RUN ["npm", "install", "-g", "fs"]
RUN ["npm", "install", "-g", "deep-equal"]
RUN ["npm", "install", "-g",  "eslint", "--save-dev"]
RUN ["npm", "install", "-g", "babel-core"]
RUN ["npm", "install", "-g", "scratch-vm"]
RUN ["npm", "install", "-g", "scratch-storage"]
RUN ["npm", "install", "-g", "immutable"]
RUN ["npm", "install", "-g", "escape-html"]
RUN ["npm", "install", "-g", "htmlparser2"]
RUN ["npm", "install", "-g", "minilog"]
RUN ["npm", "install", "-g", "got"]
RUN ["npm", "install", "-g", "socket.io-client"]

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
