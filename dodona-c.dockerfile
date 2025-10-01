FROM python:3.13.7-slim-bookworm

RUN  <<EOF
  set -eux

  apt-get update
  apt-get install -y --no-install-recommends \
      jshon \
      libgtest-dev \
      g++ \
      make \
      cmake

  apt-get clean
  rm -rf /var/lib/apt/lists/*

  chmod 711 /mnt && \
  useradd -m runner
EOF

WORKDIR /usr/src/gtest

RUN  <<EOF
  set -eux

  cmake CMakeLists.txt
  make
  cp -- lib/*.a /usr/lib
  mkdir /usr/local/lib/gtest
  ln -s /usr/lib/libgtest.a /usr/local/lib/gtest
  ln -s /usr/lib/libgtest_main.a /usr/local/lib/gtest
EOF

# Switch to runner user
USER runner
RUN mkdir /home/runner/workdir
WORKDIR /home/runner/workdir

COPY main.sh /main.sh
