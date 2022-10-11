FROM gitpod/workspace-full-vnc:2022-01-28-04-35-05
SHELL ["/bin/bash", "-c"]

# vnc resolution
USER root
RUN sed -i 's/1920x1080/500x800/g' /usr/bin/start-vnc-session.sh

# Install dart
USER root
RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && curl -fsSL https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list > /etc/apt/sources.list.d/dart_stable.list \
    && install-packages build-essential dart libkrb5-dev gcc make gradle

# Install flutter
USER gitpod
RUN cd /home/gitpod \
    && wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.0.2-stable.tar.xz \
    && tar -xvf flutter*.tar.xz \
    && rm -f flutter*.tar.xz

RUN flutter/bin/flutter precache
RUN echo 'export PATH="$PATH:/home/gitpod/flutter/bin"' >> /home/gitpod/.bashrc

# Install Google Chrome
USER root
RUN apt-get update \
  && apt-get install -y apt-transport-https \
  && curl -sSL https://dl.google.com/linux/linux_signing_key.pub | apt-key add - \
  && echo "deb [arch=amd64] https://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list \
  && apt-get update \
  && sudo apt-get install -y google-chrome-stable

# misc deps
RUN apt-get install -y \
  libasound2-dev \
  libgtk-3-dev \
  libnss3-dev \
  fonts-noto \
  fonts-noto-cjk \
  libsqlite3-0 \
  libsqlite3-dev

# For Qt WebEngine on docker
ENV QTWEBENGINE_DISABLE_SANDBOX 1
