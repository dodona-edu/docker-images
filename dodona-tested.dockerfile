FROM python:3.12.1-slim-bullseye

# Environment Kotlin
ENV SDKMAN_DIR /usr/local/sdkman
ENV PATH $SDKMAN_DIR/candidates/kotlin/current/bin:$PATH
ENV NODE_PATH /usr/lib/node_modules
# Add manual directory for default-jdk
# hadolint ignore=DL3008
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1 \
 && apt-get update \
 # Install additional dependencies
 && apt-get install -y --no-install-recommends \
       procps \
       dos2unix \
       curl \
       zip \
       unzip \
       # Bash language dependencies
       bc binutils bsdmainutils cowsay ed figlet file toilet tree vim xxd \
 && curl https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb --output packages-microsoft-prod.deb \
 && dpkg -i packages-microsoft-prod.deb \
 && rm packages-microsoft-prod.deb \
 # Add nodejs v18
 && bash -c 'set -o pipefail && curl -fsSL https://deb.nodesource.com/setup_18.x | bash -' \
 # Install programming languages \
 && apt-get install -y --no-install-recommends \
       # TESTed Java and Kotlin judge dependency
       openjdk-17-jdk \
       checkstyle=8.36.1-1 \
       # TESTed Haskell judge dependency
       haskell-platform=2014.2.0.0.debian8 \
       hlint=3.1.6-1 \
       # TESTed C judge dependency
       gcc=4:10.2.1-1 \
       cppcheck=2.3-1 \
       # TESTed Javascript judge dependency
       nodejs \
       # TESTed bash judge dependency
       shellcheck=0.7.1-1+deb11u1 \
       # C# dependency
       dotnet-sdk-6.0=6.0.405-1 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # TESTed Judge depencencies
 && pip install --no-cache-dir --upgrade psutil==5.9.5 attrs==23.1.0 cattrs==23.1.2 jsonschema==4.19.1 typing_inspect==0.9.0 pyyaml==6.0.1 Pygments==2.16.1 python-i18n==0.3.9 pylint==3.0.1 \
 # TESTed Kotlin judge dependencies
 && bash -c 'set -o pipefail && curl -s "https://get.sdkman.io?rcupdate=false" | bash' \
 && chmod a+x "$SDKMAN_DIR/bin/sdkman-init.sh" \
 && bash -c "source \"$SDKMAN_DIR/bin/sdkman-init.sh\" && sdk install kotlin 1.8.0" \
 && curl -sSLO https://github.com/pinterest/ktlint/releases/download/0.48.2/ktlint \
 && chmod a+x ktlint \
 && mv ktlint /usr/local/bin \
 # JavaScript dependencies
 && npm install -g eslint@8.36 abstract-syntax-tree@2.17.6 \
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
