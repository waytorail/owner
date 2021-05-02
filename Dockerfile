FROM ubuntu:20.04

#use help to debug and finding whats wrong with my Dockerfile not working properly on heroku
# https://github.com/ivang7/heroku-vscode
RUN apt-get update \
 && apt-get upgrade -y
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Moscow
RUN apt update
RUN apt-get install -y tzdata && \
    apt-get install -y \
    curl \
    wget \
    python3 \
    gcc \ 
    python3-pip \
    gnupg \
    dumb-init \
    htop \
    locales \
    man \
    nano \
    git \
    procps \
    ssh \
    sudo \
    vim \
    ffmpeg \
    jq \
    lsof \
    unzip \
    && rm -rf /var/lib/apt/lists/*

  RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
  && locale-gen
ENV LANG=en_US.UTF-8
RUN ln -s /usr/bin/python3 /usr/bin/python & \
    ln -s /usr/bin/pip3 /usr/bin/pip
RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml
    
RUN cd /tmp && \
  curl -L --silent \
  `curl --silent "https://api.github.com/repos/cdr/code-server/releases" \
    | grep '"browser_download_url":' \
    | grep "linux-x86_64" \
    | sed -E 's/.*"([^"]+)".*/\1/' \
    | head -n1 \
  `| tar -xzf - && \
  mv code-server* /usr/local/lib/code-server && \
  ln -s /usr/local/lib/code-server/code-server /usr/local/bin/code-server
  
# copy the dependencies file to the working directory
COPY requirements.txt .

# install dependencies
RUN pip3 install -r requirements.txt
RUN curl https://cli-assets.heroku.com/install-ubuntu.sh | sh

ENV PORT=8080
EXPOSE 8080
USER coder
RUN mkdir /sys/coder
WORKDIR /sys/coder
COPY run.sh /sys/coder
RUN code-server --install-extension liximomo.sftp --force
RUN code-server --install-extension ms-python.python --force
RUN code-server --install-extension formulahendry.code-runner --force

RUN mkdir -p /sys/coder/.vscode
COPY sftp.json /sys/coder/.vscode

CMD bash /sys/coder/run.sh ; /usr/local/bin/code-server --host 0.0.0.0 --port $PORT /sys/coder
