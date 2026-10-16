FROM python:3.15.0-slim-bookworm

COPY dodona-assembly/requirements.txt /requirements.txt

ARG QEMU_VERSION="8.0.4"
ARG QEMU_SHA256="81c817dda38af958be5bef1a6cf55b658bb2d3fb87c1e6a571de6b7b2c44516c"
ARG VALGRIND_VERSION="3.21.0"
ARG VALGRIND_SHA256="10ce1618bb3e33fad16eb79552b0a3e1211762448a0d7fce11c8a6243b9ac971"

# Add architecture repositories for ARM32
# hadolint ignore=DL3003,DL4006
RUN dpkg --add-architecture armhf \
 && apt-get update \
 # Install additional dependencies for fetching and building packages
 && apt-get install -y --no-install-recommends curl \
 # Judge compilation dependencies
 && apt-get install -y --no-install-recommends gcc \
 # Runtime dependencies (x86 32-bit)
 && apt-get install -y --no-install-recommends libc6-dev-i386 lib32gcc-12-dev \
 # pkill for main.sh's trap
 && apt-get install -y --no-install-recommends procps \
 # Runtime dependencies (ARM 32-bit)
 && apt-get install -y --no-install-recommends libc6:armhf \
 # Added for compiling and running Assembly (x86, x64, ARM, AArch64)
 && apt-get install -y --no-install-recommends libc6-dev-arm64-cross gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu libglib2.0-0 \
 && apt-get install -y --no-install-recommends libc6-dev-armhf-cross gcc-arm-linux-gnueabihf binutils-arm-linux-gnueabihf \
 && apt-get install -y --no-install-recommends valgrind \
 # Build tools
 && apt-get install -y --no-install-recommends ninja-build bison flex libglib2.0-dev pkg-config build-essential \
 # Cleanup package manager files
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # Judge Python dependencies
 && pip install --no-cache-dir --upgrade -r /requirements.txt \
 # qemu 8.0's bundled Meson needs distutils, which Python 3.12+ only gets from setuptools
 && pip install --no-cache-dir setuptools==72.1.0 \
 # Fetch packages
 && curl -o qemu.tar.xz https://download.qemu.org/qemu-${QEMU_VERSION}.tar.xz \
 && echo "${QEMU_SHA256} qemu.tar.xz" | sha256sum --check \
 && curl -o valgrind.tar.bz2 https://sourceware.org/pub/valgrind/valgrind-${VALGRIND_VERSION}.tar.bz2 \
 && echo "${VALGRIND_SHA256} valgrind.tar.bz2" | sha256sum --check \
 && tar xJf qemu.tar.xz \
 && tar xf valgrind.tar.bz2 \
 # Compile qemu-user for both AArch64 & ARM32
 # Debian's qemu-user crashed with Valgrind on bullseye; --without-default-features keeps the install small.
 && cd /qemu-${QEMU_VERSION} \
 && ./configure --target-list=aarch64-linux-user,arm-linux-user --without-default-features \
 && make -j4 \
 && make install \
 && cd /valgrind-${VALGRIND_VERSION} \
 # Cross-compiling Valgrind for AArch64
 && ./configure --host=aarch64-unknown-linux --target=aarch64-unknown-linux --prefix=/opt/valgrind-aarch64 --enable-only64bit CC=aarch64-linux-gnu-gcc LD=aarch64-linux-gnu-ld CFLAGS="-static" LDFLAGS="-static" \
 && make -j4 \
 && make install \
 # Patch Valgrind for AArch64
 && mv /opt/valgrind-aarch64/libexec/valgrind/cachegrind-arm64-linux /opt/valgrind-aarch64/libexec/valgrind/cachegrind-arm64-linux-orig \
 && echo '#!/bin/sh' > /opt/valgrind-aarch64/libexec/valgrind/cachegrind-arm64-linux \
 && echo 'qemu-aarch64 /opt/valgrind-aarch64/libexec/valgrind/cachegrind-arm64-linux-orig $@' >> /opt/valgrind-aarch64/libexec/valgrind/cachegrind-arm64-linux \
 && chmod +x /opt/valgrind-aarch64/libexec/valgrind/cachegrind-arm64-linux \
 # Cross-compiling for ARM32
 && make distclean \
 && ./configure --host=armv7-linux-gnueabihf --target=armv7-linux-gnueabihf --prefix=/opt/valgrind-arm32 --enable-only32bit CC=arm-linux-gnueabihf-gcc LD=arm-linux-gnueabihf-ld CFLAGS="-fPIC" LDFLAGS="" CXXFLAGS="-fPIC" \
 && make -j4 \
 && make install \
 # Patch Valgrind for ARM32
 && mv /opt/valgrind-arm32/libexec/valgrind/cachegrind-arm-linux /opt/valgrind-arm32/libexec/valgrind/cachegrind-arm-linux-orig \
 && echo '#!/bin/sh' > /opt/valgrind-arm32/libexec/valgrind/cachegrind-arm-linux \
 && echo 'qemu-arm /opt/valgrind-arm32/libexec/valgrind/cachegrind-arm-linux-orig $@' >> /opt/valgrind-arm32/libexec/valgrind/cachegrind-arm-linux \
 && chmod +x /opt/valgrind-arm32/libexec/valgrind/cachegrind-arm-linux \
 && cd / \
 # Remove man pages and documentation
 && rm -r /opt/valgrind-aarch64/share /opt/valgrind-arm32/share /usr/share/man /usr/share/doc \
 # Remove build files
 && rm -r qemu-${QEMU_VERSION} valgrind-${VALGRIND_VERSION} qemu.tar.xz valgrind.tar.bz2 \
 # Remove build tools
 && apt-get remove --purge -y ninja-build make bison flex pkg-config libglib2.0-dev curl \
 && pip uninstall -y setuptools \
 && apt-get autoremove -y \
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
