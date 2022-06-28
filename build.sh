#!/bin/sh

docker_files=*.dockerfile
# use docker files passed by script parameter if provided
if [ $# -gt 0 ]; then
    docker_files=$@
fi

for dockerfile in $docker_files; do
    name="${dockerfile%.dockerfile}"

    docker build --pull --force-rm -t "$name" -f "$dockerfile" .
done
