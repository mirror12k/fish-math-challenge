#!/usr/bin/env -S bash -c "docker run -v \${PWD}:/app -it \$(docker build -q infrastructure) \$@"
FROM ubuntu:22.04

WORKDIR /app

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y gnupg software-properties-common curl \
    && curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - \
    && apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    && apt-get update \
    && apt-get install -y nano jq zip make \
    && apt-get install -y terraform \
    && apt-get install -y awscli python3-venv \
    && apt-get install -y openssh-client \
    && apt autoclean \
    && apt autoremove \
    && apt clean

CMD make bash


