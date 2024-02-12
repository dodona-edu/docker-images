FROM eclipse-temurin:21-jdk-alpine

# Install jq for json querying in bash
RUN apk add --update-cache jq \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && adduser -S runner \
 && rm -rf /var/cache/apk/*

# As the runner user
USER runner
RUN ["mkdir", "/home/runner/workdir"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
