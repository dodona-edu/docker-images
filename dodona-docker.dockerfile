FROM busybox:musl

COPY --from=ghcr.io/dodona-edu/dodona-containerfile-evaluator:v0.3.0 /bin/dodona-containerfile-evaluator /bin/dodona-containerfile-evaluator
COPY --from=hadolint/hadolint:2.12.0 /bin/hadolint /bin/hadolint
COPY --from=ghcr.io/jqlang/jq:1.7.1 /jq /bin/jq
COPY --from=gcr.io/kaniko-project/executor:v1.23.2-slim /kaniko /kaniko

ENV SSL_CERT_DIR=/kaniko/ssl/certs

# kaniko requires root permissions to unpack the base image with proper permissions
RUN printf 'runner:x:0:0:runner:/home/runner:/bin/sh' > /etc/passwd && \
    # Make sure the students can't find our secret path, which is mounted in
    # /mnt with a secure random name.
    mkdir /mnt && \
    chmod 711 /mnt

# As the runner user
USER runner
RUN mkdir -p /home/runner/workdir

WORKDIR /home/runner/workdir

COPY main.sh /main.sh
