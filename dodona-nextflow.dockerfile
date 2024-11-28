FROM amazoncorretto:21-al2023-headless
ARG NXF_VER=24.10.2

RUN chmod 711 /mnt \
    && dnf install -y --setopt=install_weak_deps=False --best procps-ng shadow-utils which jq perl unzip \
    && dnf clean all \
    && useradd -m runner

USER runner

ENV PATH="/home/runner/bin:$PATH"
ENV NXF_VER=${NXF_VER}
ENV NXF_HOME="/home/runner/.nextflow"
ENV NXF_OFFLINE="true"
ENV FASTQC_HOME="/home/runner/.fastqc"

RUN mkdir ~/bin \
    && pushd ~/bin \
    && curl -fLO "https://github.com/nextflow-io/nextflow/releases/download/v$NXF_VER/nextflow" \
    && chmod +x nextflow \
    && mkdir -p "$NXF_HOME/framework/$NXF_VER" \
    && curl -fLo "$NXF_HOME/framework/$NXF_VER/nextflow-$NXF_VER-one.jar" "https://www.nextflow.io/releases/v$NXF_VER/nextflow-$NXF_VER-one.jar" \
    && curl -fLO 'https://repo1.maven.org/maven2/org/codenarc/CodeNarc/3.5.0-groovy-4.0/CodeNarc-3.5.0-groovy-4.0-all.jar' \
    && curl -fLO 'https://github.com/awslabs/linter-rules-for-nextflow/releases/download/v0.1.0/linter-rules-0.1.jar' \
    && curl -fLO 'https://repo1.maven.org/maven2/org/slf4j/slf4j-api/1.7.36/slf4j-api-1.7.36.jar' \
    && curl -fLO 'https://repo1.maven.org/maven2/org/slf4j/slf4j-simple/1.7.36/slf4j-simple-1.7.36.jar' \
    && printf 'java -Dorg.slf4j.simpleLogger.defaultLogLevel=error -classpath "$HOME/bin/linter-rules-0.1.jar:$HOME/bin/CodeNarc-3.5.0-groovy-4.0-all.jar:$HOME/bin/slf4j-api-1.7.36.jar:$HOME/bin/slf4j-simple-1.7.36.jar" "org.codenarc.CodeNarc" "$@"' > nextflow-linter \
    && chmod +x nextflow-linter \
    && popd \
    && TMPFILE=$(mktemp) \
    && curl -fLo "$TMPFILE" "https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.9.zip" \
    && mkdir "$FASTQC_HOME" \
    && ln -s "$FASTQC_HOME" "$FASTQC_HOME/FastQC" \
    && unzip "$TMPFILE" -d "$FASTQC_HOME" \
    && rm "$TMPFILE" "$FASTQC_HOME/FastQC" \
    && chmod +x "$FASTQC_HOME/fastqc" \
    && ln -s "$FASTQC_HOME/fastqc" "$HOME/bin/fastqc" \
    && mkdir -p "$HOME/workdir"

WORKDIR /home/runner/workdir

COPY main.sh /main.sh
