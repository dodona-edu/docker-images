FROM alpine:3.24.2

# The judge builds its feedback with jq
RUN apk add --no-cache jq=1.8.2-r0 \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && adduser -u 1000 -S runner \
 && rm -rf /var/cache/apk/*

# As the runner user
USER runner
RUN ["mkdir", "/home/runner/workdir"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
