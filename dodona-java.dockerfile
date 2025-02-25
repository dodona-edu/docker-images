FROM amazoncorretto:8-alpine-jdk

# Install jq for json querying in bash
RUN <<EOF
  set -eux

  apk add --no-cache jq


  # Make sure the students can't find our secret path, which is mounted in
  # /mnt with a secure random name.
  chmod 711 /mnt

  # Add the user which will run the student's code and the judge.
  adduser -u 1000 -S runner
  rm -rf /var/cache/apk/*

EOF

# As the runner user
USER runner
RUN ["mkdir", "/home/runner/workdir"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
