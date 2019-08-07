FROM mono

# Install jq for json querying in bash
RUN ["apt-get", "update"]
RUN ["apt-get", "-y", "install", "jshon"]
RUN ["apt-get", "-y", "install", "time"]

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