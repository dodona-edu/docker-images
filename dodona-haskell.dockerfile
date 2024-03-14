FROM haskell:9.8.2

# hadolint ignore=DL3008
RUN apt-get update \
 # Install jq for json querying in bash
 # Install freeglut headers for gloss compilation
 && apt-get install -y --no-install-recommends \
        jq \
        freeglut3-dev \
 && rm -rf /var/lib/apt/lists/* \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && useradd -m runner

# As the runner user
WORKDIR /home/runner
USER runner
RUN cabal update \
 # happy must be installed to install haskell-src-exts
 && cabal install happy-1.20.1.1 \
 && cabal install \
        HUnit-1.6.2.0 \
        MissingH-1.6.0.1 \
        QuickCheck-2.14.3 \
        ghc-lib-parser-9.8.2.20240223 \
        ghc-lib-parser-ex-9.8.0.2 \
        gloss-1.13.2.2 \
        hlint-3.8 \
        splitmix-0.1.0.5 \
        stm-2.5.2.1 \
 # Create the working directory
 && mkdir workdir

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
