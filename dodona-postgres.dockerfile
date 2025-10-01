FROM eclipse-temurin:25-jdk-alpine

# Dodona-specific setup
RUN chmod 711 /mnt && \
    adduser -u 1000 -S runner && \
    mkdir -p /home/runner/workdir

USER runner
RUN mkdir -p /home/runner/workdir

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
