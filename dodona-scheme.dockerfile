FROM racket/racket:8.17

# add generic tools
RUN apt-get --allow-releaseinfo-change update \
    && apt-get install --no-install-recommends -y jq \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    # add racket dependencies
    && raco pkg install -i --auto --binary-lib --no-cache --no-docs rackunit r5rs \
    && raco pkg install -i --auto --no-cache --no-docs r7rs \
    # follow Dodona conventions
    && chmod 711 /mnt \
    && useradd -m runner \
    && mkdir /home/runner/workdir \
    && chown runner:runner /home/runner/workdir

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
