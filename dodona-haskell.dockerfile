FROM haskell:9.12.4





RUN set -eux; \
 apt-get update; \
 # Install jq for json querying in bash
 # Install freeglut headers for gloss compilation
 # Install procps for pkill in main.sh
 apt-get install -y --no-install-recommends \
        jq \
        freeglut3-dev \
        procps \
 && rm -rf /var/lib/apt/lists/* \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && useradd -m runner

# As the runner user
WORKDIR /home/runner
USER runner
COPY dodona-haskell/packages.txt /packages.txt
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN cabal update \
 && grep -v '^#' /packages.txt | xargs cabal install \
 # Create the working directory
 && mkdir workdir

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
