FROM python:3.11.1-slim-bullseye

# Environment Kotlin
ENV SDKMAN_DIR /usr/local/sdkman
ENV PATH $SDKMAN_DIR/candidates/kotlin/current/bin:$PATH
ENV NODE_PATH /usr/lib/node_modules
# Add manual directory for default-jdk
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1 \
 && apt-get update \
 # Install additional dependencies
 && apt-get install -y --no-install-recommends \
       procps=2:3.3.17-5 \
       dos2unix=7.4.1-1 \
       curl=7.74.0-1.3+deb11u5 \
       zip=3.0-12 \
       unzip=6.0-26+deb11u1 \
 && curl https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb --output packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb \
 # Add nodejs v18
 && bash -c 'set -o pipefail && curl -fsSL https://deb.nodesource.com/setup_18.x | bash -' \
 # Install programming languages
 && apt-get install -y --no-install-recommends \
       # TESTed Java and Kotlin judge dependency
       openjdk-17-jdk=17.0.4+8-1~deb11u1 \
       checkstyle=8.36.1-1 \
       # TESTed Haskell judge dependency
       haskell-platform=2014.2.0.0.debian8 \
       hlint=3.1.6-1 \
       # TESTed C judge dependency
       gcc=4:10.2.1-1 \
       cppcheck=2.3-1 \
       # TESTed Javascript judge dependency
       nodejs=18.13.0-deb-1nodesource1 \
       # TESTed bash judge dependency
       shellcheck=0.7.1-1+deb11u1 \
       # C# dependency
       dotnet-sdk-6.0=6.0.405-1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # TESTed Judge depencencies
 && pip install --no-cache-dir --upgrade jsonschema==4.4.0 psutil==5.9.0 mako==1.1.6 pydantic==1.9.0 typing_inspect==0.7.1 pylint==2.6.0 lark==0.10.1 pyyaml==6.0 Pygments==2.11.2 python-i18n==0.3.9 \
 # TESTed Kotlin judge dependencies
 && bash -c 'set -o pipefail && curl -s "https://get.sdkman.io?rcupdate=false" | bash' \
 && chmod a+x "$SDKMAN_DIR/bin/sdkman-init.sh" \
 && bash -c "source \"$SDKMAN_DIR/bin/sdkman-init.sh\" && sdk install kotlin 1.6.10" \
 && curl -sSLO https://github.com/pinterest/ktlint/releases/download/0.43.2/ktlint \
 && chmod a+x ktlint \
 && mv ktlint /usr/local/bin \
 # JavaScript dependencies
 && npm install -g eslint@8.7 abstract-syntax-tree@2.17.6 \
 # Haskell dependencies
 && cabal update \
 && cabal v1-install --global aeson \
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
