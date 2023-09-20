FROM r-base:4.3.1

# hadolint ignore=DL3008
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
      default-jdk=2:1.17-74 \
      libcurl4-openssl-dev \
      libfontconfig-dev \
      libfreetype-dev \
      libfribidi-dev=1.0.13-3 \
      libgsl-dev=2.7.1+dfsg-5 \
      libharfbuzz-dev=8.0.1-1 \
      libnlopt-dev=2.7.1-5+b1 \
      libssl-dev=3.0.10-1 \
      libtiff5-dev=4.5.1+git230720-1 \
      libxml2-dev=2.9.14+dfsg-1.3 \
      procps=2:4.0.3-1 \
      && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  chmod 711 /mnt && \
  groupmod -n runner docker && \
  usermod -l runner -d /home/runner docker && \
  mkdir -p /home/runner/workdir && \
  chown -R runner:runner /home/runner && \
  chown -R runner:runner /mnt && \
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


USER runner

WORKDIR /home/runner/workdir
COPY main.sh /main.sh
