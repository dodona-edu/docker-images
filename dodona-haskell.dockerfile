FROM haskell:9.12.4 AS build

RUN set -eux; \
 apt-get update; \
 # Install freeglut headers for gloss compilation
 apt-get install -y --no-install-recommends freeglut3-dev; \
 rm -rf /var/lib/apt/lists/*; \
 # Drop GHC's profiling libraries and docs
 find /opt/ghc/9.12.4 \( -name '*_p.a' -o -name '*_p.so' -o -name '*_p-ghc*.so' \
        -o -name '*.p_hi' -o -name '*.p_dyn_hi' -o -name '*.p_o' -o -name 'ghc-iserv-prof*' \) -delete; \
 rm -rf /opt/ghc/9.12.4/share/doc; \
 useradd -m runner

# The store's package db holds absolute paths under runner's home.
USER runner
WORKDIR /home/runner
COPY dodona-haskell/packages.txt /packages.txt
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN cabal update \
 && grep -v '^#' /packages.txt | xargs cabal install \
 && rm -rf ~/.cache/cabal


# Same Debian release as haskell:9.12.4.
FROM debian:bookworm-slim

ENV LANG=C.UTF-8
ENV PATH=/root/.cabal/bin:/root/.local/bin:/opt/ghc/9.12.4/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN set -eux; \
 apt-get update; \
 # The toolchain and C libraries GHC compiles and links with, as in haskell:9.12.4
 # Install jq for json querying in bash
 # Install freeglut headers for gloss compilation
 # Install procps for pkill in main.sh
 apt-get install -y --no-install-recommends \
        gcc \
        g++ \
        libc6-dev \
        libffi-dev \
        libgmp-dev \
        libnuma-dev \
        libtinfo-dev \
        make \
        netbase \
        zlib1g-dev \
        jq \
        freeglut3-dev \
        procps \
 && rm -rf /var/lib/apt/lists/* \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && useradd -m runner

COPY --from=build /opt/ghc/9.12.4 /opt/ghc/9.12.4
COPY --from=build /usr/local/bin/cabal /usr/local/bin/cabal

# As the runner user
WORKDIR /home/runner
USER runner
COPY --from=build --chown=runner:runner /home/runner/.config /home/runner/.config
COPY --from=build --chown=runner:runner /home/runner/.local /home/runner/.local
COPY dodona-haskell/packages.txt /packages.txt

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
