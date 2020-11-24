FROM debian:stretch

RUN apt-get update && apt-get -y install git curl unzip

RUN apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /home/gitpod
WORKDIR /home/gitpod

ENV PUB_CACHE=/workspace/.pub_cache
ENV FLUTTER_HOME=/home/gitpod/flutter
RUN echo 'export PATH=${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PUB_CACHE}/bin:${FLUTTER_HOME}/.pub-cache/bin:$PATH' >>~/.bashrc

RUN git clone https://github.com/flutter/flutter -b beta && \
    cd flutter && \
    /home/gitpod/flutter/bin/flutter config --enable-web && \
    /home/gitpod/flutter/bin/flutter   --version