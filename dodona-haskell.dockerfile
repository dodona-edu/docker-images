FROM haskell:8.2

RUN apt-get update \
 # Install jq for json querying in bash
 # Install freeglut headers for gloss compilation
 && apt-get install -y --no-install-recommends \
        jshon=20131010-3+b1 \
        freeglut3-dev=2.8.1-3 \
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
 && cabal install happy-1.19.9 \
 && cabal install \
        hlint-2.1.10 \
        QuickCheck-2.10.1 \
        HUnit-1.6.0.0 \
        MissingH-1.4.0.1 \
        json-builder-0.3 \
        stm-2.4.5.0 \
        gloss-1.13.0.1 \
 # Create the working directory
 && mkdir workdir

WORKDIR /home/runner/workdir
COPY simple-main.sh /main.sh
