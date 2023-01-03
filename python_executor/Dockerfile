#!/usr/bin/env -S bash -c "docker run --rm --cap-drop=all -i \${PWD##*/} \$@"
FROM ubuntu:18.04

WORKDIR /app

# install
RUN apt update \
	&& apt install -y python3 \
	&& apt autoclean \
	&& apt autoremove \
	&& apt clean

# safety measure to drop privileges to lowly user
RUN useradd -ms /bin/bash python_runuser
USER python_runuser



