FROM mono:6.12.0.182

# Fix EOL buster repos + install packages
RUN set -eux; \
  # Rewrite to archive mirrors (primary mirrors dropped buster)
  sed -ri \
    -e 's#http://deb.debian.org/debian#http://archive.debian.org/debian#g' \
    -e 's#http://deb.debian.org/debian-security#http://archive.debian.org/debian-security#g' \
    -e 's#http://security.debian.org/debian-security#http://archive.debian.org/debian-security#g' \
    /etc/apt/sources.list; \
  # If there are extra list files, rewrite those too (no-op if none)
  find /etc/apt/sources.list.d -maxdepth 1 -type f -print0 2>/dev/null \
    | xargs -0 -r sed -ri \
      -e 's#http://deb.debian.org/debian#http://archive.debian.org/debian#g' \
      -e 's#http://deb.debian.org/debian-security#http://archive.debian.org/debian-security#g' \
      -e 's#http://security.debian.org/debian-security#http://archive.debian.org/debian-security#g'; \
  # Archived suites often have expired metadata; disable date check
  printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99no-check-valid-until; \
  apt-get update --allow-releaseinfo-change; \
  apt-get install -y --no-install-recommends jshon time; \
  apt-get clean; rm -rf /var/lib/apt/lists/*

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
