#!/bin/bash

set -e

DEBUG_LEVEL=0
ARCH=$(dpkg --print-architecture)

apt update; \
  apt install --yes \
  sudo \
  apt-utils \
  apt-transport-https \
  ca-certificates \
  curl \
  dnsutils \
  git \
  gnupg \
  inetutils-traceroute \
  iputils-ping \
  jq \
  locales \
  lsb-release \
  neovim \
  net-tools \
  openssh-server \
  postgresql-client \
  python3-pip \
  rsync \
  tmux \
  unzip \
  wget \
  zsh

# Update the CA certificates for any that were imported into the container
update-ca-certificates

# Install dependencies for Playwright
sudo apt-get install -y libglib2.0-0 libnss3 libatk1.0-0 libatk-bridge2.0-0 libgbm-dev libgtk-3-0 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libasound2 libatspi2.0-0 libxshmfence1 libcups2 libdrm2 libpango-1.0-0 libcairo2

# Fix for warning message: bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen && update-locale LANG=en_US.UTF-8

wget -q https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | dd of=/usr/share/keyrings/hashicorp-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | dd of=/usr/share/keyrings/docker-archive-keyring.gpg \
  && echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(lsb_release -is | sed 's/[A-Z]/\L&/g') $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update; \
  apt install -y \
  docker-ce-cli \
  dotnet-sdk-7.0 \
  gh \
  terraform

# Install wasm-tools for .NET
dotnet workload install wasm-tools