FROM node

COPY scratch.package.json /package.json
RUN ["npm", "install"]
RUN ["apt-get", "update", "-y", "-q"]
RUN ["apt-get", "install", "-y", "-q", "xvfb", "libgtk2.0-0", "libxtst6", "libxss1", "libgconf-2-4", "libnss3", "libasound2", "gconf-service", "libasound2", "libatk1.0-0", "libc6", "libcairo2", "libcups2", "libdbus-1-3", "libexpat1", "libfontconfig1", "libgcc1", "libgconf-2-4", "libgdk-pixbuf2.0-0", "libglib2.0-0", "libgtk-3-0", "libnspr4", "libpango-1.0-0", "libpangocairo-1.0-0", "libstdc++6", "libx11-6", "libx11-xcb1", "libxcb1", "libxcomposite1", "libxcursor1", "libxdamage1", "libxext6", "libxfixes3", "libxi6", "libxrandr2", "libxrender1", "libxss1", "libxtst6", "ca-certificates", "fonts-liberation", "libappindicator1", "libnss3", "lsb-release", "xdg-utils", "wget"]


ENV NODE_PATH="/usr/local/lib/node_modules"

RUN ["chmod", "711", "/mnt"]
RUN ["userdel", "node"]
RUN ["useradd", "-m", "runner"]


USER runner
RUN ["mkdir", "/home/runner/workdir"]
USER root

RUN ["chown", "-R", "runner:runner", "/node_modules/"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
COPY logger.sh /logger.sh
