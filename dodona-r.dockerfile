FROM r-base:4.5.1

RUN <<EOF
  set -eux

  apt-get update
  apt-get install -y --no-install-recommends \
    default-jdk \
    libcurl4-openssl-dev \
    libfontconfig-dev \
    libfreetype-dev \
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
