FROM python:3.12.4-slim-bullseye

ARG LLVM_VERSION="13.0.0"
ARG LLVM_SHA256="9680c841b5ceffa51f21d0d2ddd7573447b659d1889b83c153b7473342b22a49"


# hadolint ignore=DL3013,DL4006
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    cmake \
    g++ \
    gawk \
    gdb \
    git \
    graphviz \
    libfmt-dev \
    make \
    p7zip-full \
    pandoc \
    python3 \
    python3-pip \
    python3-pygments \
    wget && \
    rm -rf /var/lib/apt/lists/* && \
    wget -nv -O /clang+llvm.7z https://github.com/thomasfaingnaert/llvm-builds/releases/download/${LLVM_VERSION}/clang+llvm-Release+Asserts-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-20.04.7z && \
    echo "${LLVM_SHA256} /clang+llvm.7z" | sha256sum --check && \
    7z x /clang+llvm.7z -o/opt && \
    rm /clang+llvm.7z && \
    pip3 --no-cache-dir install lit psutil

ENV LLVM_ROOT=/opt/clang+llvm-Release+Asserts-${LLVM_VERSION}-x86_64-linux-gnu-ubuntu-20.04
ENV PATH="${LLVM_ROOT}/bin:${PATH}"

# Dodona-specific config
RUN chmod 711 /mnt && useradd -m runner
USER runner
RUN ["mkdir", "/home/runner/workdir"]
WORKDIR /home/runner/workdir

# Copy main.sh file for Dodona
COPY main.sh /
