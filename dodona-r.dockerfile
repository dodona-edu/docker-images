# dodona-r/update-lock.R runs in this stage.
FROM r-base:4.5.1 AS renv

ARG RENV_VERSION=1.3.1

RUN <<'EOF'
  set -eux

  # CRAN moves a release under Archive/ once a newer one ships.
  wget -q -P /tmp "https://cloud.r-project.org/src/contrib/renv_${RENV_VERSION}.tar.gz" \
    || wget -q -P /tmp "https://cloud.r-project.org/src/contrib/Archive/renv/renv_${RENV_VERSION}.tar.gz"
  R CMD INSTALL "/tmp/renv_${RENV_VERSION}.tar.gz"
  rm "/tmp/renv_${RENV_VERSION}.tar.gz"
EOF

FROM renv

ARG DEBIAN_FRONTEND=noninteractive

RUN <<'EOF'
  set -eux
  
  . /etc/os-release
  CODENAME="${VERSION_CODENAME:-trixie}"
  
  # Prefer the base suite by default
  printf 'APT::Default-Release "%s";\n' "$CODENAME" > /etc/apt/apt.conf.d/99defaultrelease
  
  apt-get update
  
  # Install everything from unstable so *-dev matches already-installed runtimes
  # (one shot avoids mixed versions)
  apt-get install -y --no-install-recommends -t unstable \
    default-jdk \
    libcurl4-openssl-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libgit2-dev \
    libglpk-dev \
    libgsl-dev \
    libharfbuzz-dev \
    libnlopt-dev \
    libssl-dev \
    libtiff5-dev \
    libuv1-dev \
    libxml2-dev
  
  apt-get clean
  rm -rf /var/lib/apt/lists/*

  chmod 711 /mnt
  groupmod -n runner docker
  usermod -l runner -d /home/runner docker
  mkdir -p /home/runner/workdir
  chown -R runner:runner /home/runner
  chown -R runner:runner /mnt
EOF

COPY dodona-r/ /requirements/

RUN <<'EOF'
  set -eux

  # renv's cache would leave the packages symlinked into root's home, which runner cannot read.
  # R's own library already holds the recommended packages, so restore only fills the site library.
  # PPM has no binaries for this Debian release, so renv must not rewrite the snapshot URL to a binary one.
  RENV_CONFIG_PPM_ENABLED=FALSE RENV_CONFIG_CACHE_ENABLED=FALSE RENV_CONFIG_INSTALL_JOBS="$(nproc)" Rscript -e "renv::restore( \
    project = '/requirements', \
    library = c('/usr/local/lib/R/site-library', '/usr/lib/R/site-library', '/usr/lib/R/library'), \
    prompt = FALSE)"
  rm -rf /root/.cache/R

  # Fail when the image is out of step with the lock, renv itself included.
  Rscript -e "pkgs <- jsonlite::read_json('/requirements/renv.lock')\$Packages; \
    bad <- Filter(function(p) !identical(packageDescription(p\$Package, fields = 'Version'), p\$Version), pkgs); \
    for (p in bad) message(p\$Package, ': locked ', p\$Version); \
    if (length(bad)) stop('image does not match renv.lock')"
EOF

USER runner

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
