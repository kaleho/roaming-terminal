#!/bin/bash

set -e

DEBUG_LEVEL=0
ARCH=$(dpkg --print-architecture)

apt update; \
    apt install -y \
    apt-transport-https \
    apt-utils \
    build-essential \
    ca-certificates \
    cmake \
    curl \
    dnsutils \
    fuse \
    gettext \
    git \
    gnupg \
    inetutils-traceroute \
    iputils-ping \
    jq \
    libasound2-dev \
    locales \
    lsb-release \
    net-tools \
    ninja-build \
    openssh-server \
    pkg-config \
    postgresql-client \
    python3-pip \
    rsync \
    ssh \
    sudo \
    tmux \
    unzip \
    wget \
    zsh \
    libzstd1

# Install dependencies for Playwright
# apt update; \
#     apt install -y \
#     libglib2.0-0 \
#     libnss3 \
#     libatk1.0-0 \
#     libatk-bridge2.0-0 \
#     libgbm-dev \
#     libgtk-3-0 \
#     libxkbcommon0 \
#     libxcomposite1 \
#     libxdamage1 \
#     libxfixes3 \
#     libxrandr2 \
#     libasound2 \
#     libatspi2.0-0 \
#     libxshmfence1 \
#     libcups2 \
#     libdrm2 \
#     libpango-1.0-0 \
#     libcairo2

# Update the CA certificates for any that were imported into the container
update-ca-certificates

# Fix for warning message: bash: warning: setlocale: LC_ALL: cannot change locale (en_US.UTF-8)
echo 'en_US.UTF-8 UTF-8' >> /etc/locale.gen
locale-gen && update-locale LANG=en_US.UTF-8

# Convert to a float
OS_NAME=$(lsb_release -is)
OS_RELEASE_MAJOR=$(lsb_release -rs | awk '{print substr($0,0,4)+0}')

# If this is running on Ubuntu and OS_RELEASE_MAJOR is less than 22, skip this step
wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb
# if [ "$OS_NAME" == "Ubuntu" ] && [ $OS_RELEASE_MAJOR -lt 22 ]; then
# fi

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | dd of=/usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor | dd of=/usr/share/keyrings/docker-archive-keyring.gpg \
    && echo "deb [arch=$ARCH signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(lsb_release -is | sed 's/[A-Z]/\L&/g') $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | dd of=/usr/share/keyrings/cloud.google.asc \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null

apt update; \
    apt install -y \
    docker-ce-cli \
    dotnet-sdk-6.0 \
    dotnet-sdk-7.0 \
    gh \
    google-cloud-cli \
    terraform

# Install wasm-tools for .NET
# dotnet workload install wasm-tools

systemctl enable ssh
