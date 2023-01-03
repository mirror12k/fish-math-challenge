#!/usr/bin/env -S bash -c "docker run --rm --cap-drop=all -i \${PWD##*/} \$@"
FROM ubuntu:18.04

WORKDIR /app

# install
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update \
	&& apt install -y chromium-browser \
	&& apt install -y python3 \
	&& apt install -y xvfb xterm \
	&& apt install -y expect \
	&& apt autoclean \
	&& apt autoremove \
	&& apt clean

# copy in executor files
COPY . /app
# move the flag to root of directory
RUN mv flag.txt /

# safety measure to drop privileges to lowly user
RUN useradd -ms /bin/bash chrome_runuser
RUN chown -R chrome_runuser:chrome_runuser /app
USER chrome_runuser



