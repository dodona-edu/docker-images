FROM eclipse-temurin:8-jdk-noble

# Install jq for json querying in bash
RUN <<EOF
  set -eux

  apt-get update
  apt-get install -y --no-install-recommends jshon

  rm -rf /var/lib/apt/lists/*
  apt-get clean

  # Make sure the students can't find our secret path, which is mounted in
  # /mnt with a secure random name.
  chmod 711 /mnt
  # Add the user which will run the student's code and the judge.
  useradd -m runner
EOF

# As the runner user
USER runner
RUN ["mkdir", "/home/runner/workdir"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
