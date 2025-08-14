FROM mono:6.12.0.182

RUN apt-get update && \
    apt-get install -y --no-install-recommends jshon && \
    apt-get install -y --no-install-recommends time && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Make sure the students can't find our secret path, which is mounted in
# /mnt with a secure random name.
RUN ["chmod", "711", "/mnt"]

# Add the user which will run the student's code and the judge.
RUN ["useradd", "-m", "runner"]

# As the runner user
USER runner
RUN ["mkdir", "/home/runner/workdir"]

WORKDIR /home/runner/workdir

COPY main.sh /main.sh
