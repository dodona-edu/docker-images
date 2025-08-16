FROM r-base:4.5.1

ARG DEBIAN_FRONTEND=noninteractive

RUN <<'EOF'
  set -eux
  
  # Detect the base suite (e.g., trixie, bookworm, sid)
  . /etc/os-release
  CODENAME="${VERSION_CODENAME:-trixie}"
  
  # Tell apt to prefer the base suite and de-prefer unstable
  printf 'APT::Default-Release "%s";\n' "$CODENAME" \
    > /etc/apt/apt.conf.d/99defaultrelease
  
  cat > /etc/apt/preferences.d/00-pin <<PREF
  Package: *
  Pin: release n=${CODENAME}
  Pin-Priority: 990
  
  Package: *
  Pin: release a=unstable
  Pin-Priority: 100
PREF

  apt-get update
  
  # Install build deps; let APT resolve matching runtimes from the same suite
  # Note: correct package names for current Debian: libfontconfig1-dev, libfreetype6-dev
  apt-get install -y --no-install-recommends \
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
    libxml2-dev
  
  apt-get clean
  rm -rf /var/lib/apt/lists/*

  chmod 711 /mnt
  groupmod -n runner docker
  usermod -l runner -d /home/runner docker
  mkdir -p /home/runner/workdir
  chown -R runner:runner /home/runner
  chown -R runner:runner /mnt

  Rscript -e "withCallingHandlers(install.packages(c( \
    'AUC' \
    , 'BART' \
    , 'BiocManager' \
    , 'GGally' \
    , 'HistData' \
    , 'ISLR2' \
    , 'ISwR' \
    , 'MASS' \
    , 'Matrix' \
    , 'NHANES' \
    , 'R6' \
    , 'RColorBrewer' \
    , 'ROCR' \
    , 'RWeka' \
    , 'Rtsne' \
    , 'SnowballC' \
    , 'base64enc' \
    , 'car' \
    , 'caret' \
    , 'clickstream' \
    , 'coin' \
    , 'coxed' \
    , 'data.table' \
    , 'devtools' \
    , 'dplyr' \
    , 'dummy' \
    , 'dslabs' \
    , 'e1071' \
    , 'ergm' \
    , 'gam' \
    , 'gbm' \
    , 'ggplot2' \
    , 'ggplotify' \
    , 'ggrepel' \
    , 'ggridges' \
    , 'ggthemes' \
    , 'glmnet' \
    , 'gridBase' \
    , 'gridGraphics' \
    , 'gridExtra' \
    , 'httr2' \
    , 'igraph' \
    , 'iml' \
    , 'intergraph' \
    , 'irlba' \
    , 'jsonlite' \
    , 'kableExtra' \
    , 'lattice' \
    , 'latticeExtra' \
    , 'leaps' \
    , 'lexicon' \
    , 'lubridate' \
    , 'multcomp' \
    , 'node2vec' \
    , 'plotrix' \
    , 'pls' \
    , 'polite' \
    , 'qdap' \
    , 'randomForest' \
    , 'reshape2' \
    , 'rtweet' \
    , 'rvest' \
    , 'scales' \
    , 'scatterplot3d' \
    , 'sentimentr' \
    , 'skimr' \
    , 'slam' \
    , 'sna' \
    , 'sp' \
    , 'statnet' \
    , 'survival' \
    , 'text2vec' \
    , 'textclean' \
    , 'textstem' \
    , 'tictoc' \
    , 'tidytext' \
    , 'tidyverse' \
    , 'tm' \
    , 'topicdoc' \
    , 'topicmodels' \
    , 'tree' \
    , 'udpipe' \
    , 'vader' \
    , 'wordcloud' \
    , 'wordcloud2' \
    )), warning = function(w) stop(w))" \
    -e "library(devtools)" \
    -e "devtools::install_github('DougLuke/UserNetR')"
EOF

USER runner

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
