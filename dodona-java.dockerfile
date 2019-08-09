FROM openjdk:8

# Install jq for json querying in bash
RUN apt-get update \
 && apt-get install -y --no-install-recommends jshon=20131010-3+b1 \
 && rm -rf /var/lib/apt/lists/* \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && useradd -m runner

# As the runner user
USER runner
RUN ["mkdir", "/home/runner/workdir"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
