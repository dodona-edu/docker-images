FROM python:3.9.3-slim-buster

# Environment Kotlin
ENV SDKMAN_DIR /usr/local/sdkman
ENV PATH $SDKMAN_DIR/candidates/kotlin/current/bin:$PATH
# Add manual directory for default-jdk
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1 \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
       # TESTed Java and Kotlin judge dependency
       openjdk-11-jdk=11.0.9.1+1-1~deb10u2 \
       # TESTed Haskell judge dependency
       haskell-platform=2014.2.0.0.debian8 \
       hlint=2.1.10-2+b1 \
       # TESTed C judge dependency
       gcc-8=8.3.0-6 \
       cppcheck=1.86-1 \
       # TESTed Javascript judge dependency
       nodejs=10.24.0~dfsg-1~deb10u1 \
       npm=5.8.0+ds6-4+deb10u2 \
       # Additional dependencies
       dos2unix=7.4.0-1 \
       curl=7.64.0-4+deb10u1 \
       zip=3.0-11+b1 \
       unzip=6.0-23+deb10u2 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # TESTed Judge depencencies
 && pip install jsonschema==3.2.0 psutil==5.7.0 mako==1.1.2 pydantic==1.7.3 toml==0.10.1 typing_inspect==0.6.0 pylint==2.6.0 esprima==4.0.1 lark==0.10.1 pyyaml==5.4 Pygments==2.7.4 python-i18n==0.3.9 \
 # TESTed Kotlin judge dependencies
 && bash -c 'set -o pipefail && curl -s "https://get.sdkman.io?rcupdate=false" | bash' \
 && chmod a+x "$SDKMAN_DIR/bin/sdkman-init.sh" \
 && bash -c "source \"$SDKMAN_DIR/bin/sdkman-init.sh\" && sdk install kotlin 1.4.10" \
 # JavaScript dependencies
 && npm install -g eslint@7.23.0 \
 # Haskell dependencies
 && cabal update \
 && cabal install aeson --global --force-reinstalls \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && useradd -m runner \
 && mkdir /home/runner/workdir \
 && chown -R runner:runner /home/runner/workdir

USER runner
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
