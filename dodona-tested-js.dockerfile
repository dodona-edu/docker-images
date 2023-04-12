FROM python:3.11.2-slim-bullseye

ENV NODE_PATH /usr/lib/node_modules
RUN apt-get update \
 # Install additional dependencies
 && apt-get install -y --no-install-recommends procps dos2unix curl zip unzip \
 # Add nodejs v18
 && bash -c 'set -o pipefail && curl -fsSL https://deb.nodesource.com/setup_18.x | bash -' \
 # Install programming languages
 && apt-get install -y --no-install-recommends \
       # TESTed Javascript judge dependency
       nodejs=18.16.0-deb-1nodesource1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # TESTed Judge depencencies
 && pip install --no-cache-dir --upgrade psutil==5.9.4 mako==1.1.6 pydantic==1.9.2 jsonschema==4.17.3 typing_inspect==0.8.0 pyyaml==6.0 Pygments==2.14.0 python-i18n==0.3.9 pylint==2.17.1 \
 # JavaScript dependencies
 && npm install -g eslint@8.36 abstract-syntax-tree@2.17.6 \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && useradd -m runner \
 && mkdir /home/runner/workdir \
 && chown -R runner:runner /home/runner/workdir

USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
