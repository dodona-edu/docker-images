FROM python:3.13.3-slim-bullseye

# Add architecture repositories for ARM32
# hadolint ignore=DL3003
RUN dpkg --add-architecture armhf \
 && apt-get update \
 # Install additional dependencies for fetching and building packages
 && apt-get install -y --no-install-recommends curl \
 # Judge compilation dependencies
 && apt-get install -y --no-install-recommends gcc=4:10.2.1-1 \
 # Runtime dependencies (x86 32-bit)
 && apt-get install -y --no-install-recommends libc6-dev-i386 lib32gcc-10-dev=10.2.1-6 \
 # Runtime dependencies (ARM 32-bit)
 && apt-get install -y --no-install-recommends libc6:armhf \
 # Added for compiling and running Assembly (x86, x64, ARM, AArch64)
 && apt-get install -y --no-install-recommends libc6-dev-arm64-cross=2.31-9cross4 gcc-aarch64-linux-gnu=4:10.2.1-1 binutils-aarch64-linux-gnu=2.35.2-2 libglib2.0-0 \
 && apt-get install -y --no-install-recommends libc6-dev-armhf-cross=2.31-9cross4 gcc-arm-linux-gnueabihf=4:10.2.1-1 binutils-arm-linux-gnueabihf=2.35.2-2 \
 && apt-get install -y --no-install-recommends valgrind=1:3.16.1-1 \
 # Build tools
 && apt-get install -y --no-install-recommends ninja-build=1.10.1-1 bison=2:3.7.5+dfsg-1 flex=2.6.4-8 libglib2.0-dev pkg-config=0.29.2-1 build-essential=12.9 \
 # Remove conflict with Valgrind+qemu-user
 && apt-get remove -y binfmt-support \
 # Cleanup package manager files
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 # Judge Python dependencies
 && pip install --no-cache-dir --upgrade Mako==1.2.4 \
 # Fetch packages
 && curl -k -o qemu.tar.xz https://download.qemu.org/qemu-8.0.4.tar.xz \
 && curl -o valgrind.tar.bz2 https://sourceware.org/pub/valgrind/valgrind-3.21.0.tar.bz2 \
 && tar xJf qemu.tar.xz \
 && tar xf valgrind.tar.bz2 \
 # Compile qemu-user for both AArch64 & ARM32
 # This is necessary because the qemu package shipping with bullseye is outdated and contains
 # a bug causing crashes with Valgrind. Furthermore, --without-default-features allows for a
 # smaller install size.
 && cd /qemu-8.0.4 \
 && ./configure --target-list=aarch64-linux-user,arm-linux-user --without-default-features \
 && make -j4 \
 && make install \
 && cd /valgrind-3.21.0 \
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
 && rm -r qemu-8.0.4 valgrind-3.21.0 qemu.tar.xz valgrind.tar.bz2 \
 # Remove build tools
 && apt-get remove --purge -y ninja-build make bison flex pkg-config libglib2.0-dev curl \
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
