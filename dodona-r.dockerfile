FROM r-base:4.2.0

# Make sure the students can't find our secret path, which is mounted in
# /mnt with a secure random name.
RUN apt-get update && \
  apt-get install -y --no-install-recommends \
      default-jdk=2:1.11-72 \
      libcurl4-openssl-dev=7.81.0-1+b1 \
      libfontconfig-dev=2.13.1-4.4 \
      libfreetype-dev=2.11.1+dfsg-1 \
      libnlopt-dev=2.7.1-3 \
      libgsl-dev=2.7.1+dfsg-3 \
      libssl-dev=1.1.1n-1 \
      libxml2-dev=2.9.13+dfsg-1 \
      procps=2:3.3.17-7+b1 \
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
      , 'lift' \
      , 'lubridate' \
      , 'multcomp' \
      , 'node2vec' \
      , 'plotrix' \
      , 'pls' \
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
