FROM python:3.15.2-slim-trixie AS run-as-student

COPY run-as-student.c /run-as-student.c

RUN <<EOF
  set -eux

  apt-get update
  apt-get install -y --no-install-recommends gcc libc6-dev
  gcc -O2 -Wall -Wextra -Werror -o /run-as-student /run-as-student.c
EOF

FROM python:3.15.2-slim-trixie

COPY dodona-python/ /requirements/

RUN <<EOF
  set -eux

  apt-get update
  apt-get -y install --no-install-recommends \
    emboss \
    fasta3 \
    fontconfig \
    libcairo2 \
    libtk8.6 \
    procps

  # Judge dependencies
  pip install --no-cache-dir --upgrade \
    -r /requirements/judge-pythia.txt \
    -r /requirements/judge-turtle.txt

  # Exercise dependencies
  pip install --no-cache-dir --upgrade -r /requirements/exercises.txt
  fc-cache -f

  rm -rf /var/lib/apt/lists/*
  apt-get clean

  chmod 711 /mnt
  useradd -m runner
  useradd -m -u 1001 student
  mkdir -p /home/runner/workdir
  chown -R runner:runner /home/runner
  # This is different from the other images, but no idea why. Might be removed.
  chown -R runner:runner /mnt
EOF

COPY --from=run-as-student --chown=root:runner --chmod=4750 /run-as-student /usr/local/bin/run-as-student

USER runner
WORKDIR /home/runner/workdir
COPY main.sh /main.sh
