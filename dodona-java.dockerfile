FROM scratch AS judge-java
ARG JUDGE_JAVA_REPO=https://github.com/dodona-edu/judge-java.git#master
# DL3020: hadolint does not see that this ARG is a URL.
# hadolint ignore=DL3020
ADD ${JUDGE_JAVA_REPO} /

FROM eclipse-temurin:25-jdk-alpine

# Install jq for json querying in bash
RUN apk add --no-cache jq \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && adduser -u 1000 -S runner \
 && rm -rf /var/cache/apk/*

# javac AOT cache; the -J flags must match those in judge-java's run.
RUN --mount=type=bind,from=judge-java,target=/tmp/judge-java <<EOF
    set -eux
    mkdir -p /usr/local/share/judge-java /tmp/aot-out
    find /tmp/judge-java/src -name '*.java' -exec javac -J-XX:AOTCacheOutput=/usr/local/share/judge-java/javac.aot -J-XX:TieredStopAtLevel=1 -J-XX:+UseSerialGC -Xlint:all -classpath '/tmp/judge-java/lib/*' -sourcepath /tmp/judge-java/src -d /tmp/aot-out {} + > /dev/null
    test -s /usr/local/share/judge-java/javac.aot
    chmod 644 /usr/local/share/judge-java/javac.aot
    rm -rf /tmp/aot-out
EOF

# As the runner user
USER runner
RUN ["mkdir", "/home/runner/workdir"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
