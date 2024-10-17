FROM gcr.io/kaniko-project/executor:v1.23.2-slim AS kaniko

FROM hadolint/hadolint:2.12.0-debian

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates=20210119 \
        jq=1.6-2.1 \
        sudo=1.9.5p2-3+deb11u1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=kaniko /kaniko/executor /kaniko/executor2

RUN chmod 777 /kaniko && \
    # kaniko requires root permissions to unpack the base image with proper permissions
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    printf '#!/bin/sh\nsudo /kaniko/executor2 "$@"' > /kaniko/executor && \
    chmod +x /kaniko/executor && \
    # Make sure the students can't find our secret path, which is mounted in
    # /mnt with a secure random name.
    chmod 711 /mnt && \
    # Add the user which will run the student's code and the judge.
    useradd -m runner --groups sudo

# As the runner user
USER runner
RUN mkdir /home/runner/workdir

WORKDIR /home/runner/workdir

COPY main.sh /main.sh
