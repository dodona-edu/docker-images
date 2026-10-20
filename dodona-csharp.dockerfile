FROM debian:trixie-slim

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENV DOTNET_NOLOGO=1
ENV DOTNET_GENERATE_ASPNET_CERTIFICATE=false
ENV DOTNET_SKIP_WORKLOAD_INTEGRITY_CHECK=true
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DOTNET_RUNNING_IN_CONTAINER=true

# Bump the dotnet-sdk-10.0 pin by hand on .NET patch releases.
ADD --checksum=sha256:d0c2f69250c6ce0d4c6220b142f999d039a3c560af7f980b943687d106ca8e38 https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb /tmp/packages-microsoft-prod.deb
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && dpkg -i /tmp/packages-microsoft-prod.deb \
 && rm /tmp/packages-microsoft-prod.deb \
 && apt-get update \
 && apt-get install -y --no-install-recommends dotnet-sdk-10.0=10.0.402-1 jshon procps time \
 && rm -rf /var/lib/apt/lists/* \
 # Make sure the students can't find our secret path, which is mounted in
 # /mnt with a secure random name.
 && chmod 711 /mnt \
 # Add the user which will run the student's code and the judge.
 && useradd -m runner

# As the runner user
USER runner
RUN ["mkdir", "/home/runner/workdir"]

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
