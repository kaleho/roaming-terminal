#!/bin/bash

set -e

DEBUG_LEVEL=0
ARCH=$(dpkg --print-architecture)

function github_install() {
  if [[ "$DEBUG_LEVEL" == "1" ]]; then
    echo $1
    echo $2
    echo $3
  fi

  URL=$(gh release view --repo $2 --json assets --jq '.assets.[] | select(.name|test("'$3'")) | .url')
  echo Installing: $URL
  wget -q -O $1 ${URL}
  chmod +x $1
}

function github_install_deb() {
  if [[ "$DEBUG_LEVEL" == "1" ]]; then
    echo $1
    echo $2
  fi

  URL=$(gh release view --repo $1 --json assets --jq '.assets.[] | select(.name|test("'$2'")) | .url')
  echo Installing: $URL
  wget -q -O package.deb ${URL}
  dpkg -i package.deb
  rm package.deb
}

function github_install_tar() {
  if [[ "$DEBUG_LEVEL" == "1" ]]; then
    echo $1
    echo $2
    echo $3
  fi

  URL=$(gh release view --repo $2 --json assets --jq '.assets.[] | select(.name|test("'$3'")) | .url')
  echo Installing: $URL
  echo
  wget -q -O archive.tgz ${URL}
  tar zxvf archive.tgz --directory $1
  rm archive.tgz
}

function github_install_zip() {
  if [[ "$DEBUG_LEVEL" == "1" ]]; then
    echo $1
    echo $2
    echo $3
  fi

  URL=$(gh release view --repo $2 --json assets --jq '.assets.[] | select(.name|test("'$3'")) | .url')
  echo Installing: $URL
  wget -q -O archive.zip ${URL}
  unzip -j archive.zip -d $1
  rm archive.zip
}

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

github_install "/usr/local/bin/devspace" "loft-sh/devspace" "^devspace-linux-$ARCH$"
github_install "/usr/local/bin/docker-compose" "docker/compose" "^docker-compose-linux-x86_64$"
github_install "/usr/local/bin/kubectx" "ahmetb/kubectx" "^kubectx$"
github_install "/usr/local/bin/kubens" "ahmetb/kubectx" "^kubens$"
github_install "/usr/local/bin/kubie" "sbstp/kubie" "^kubie-linux-$ARCH$"
github_install "/usr/local/bin/rke" "rancher/rke" "^rke_linux-$ARCH$"
github_install "/usr/local/bin/terragrunt" "gruntwork-io/terragrunt" "^terragrunt_linux_$ARCH$"
github_install "/usr/local/bin/vcluster" "loft-sh/vcluster" "^vcluster-linux-$ARCH$"

github_install_tar "/usr/local/bin" "junegunn/fzf-bin" $(echo "$(uname -s | sed 's/[A-Z]/\L&/g')_$ARCH.tgz$")

github_install_zip "/usr/local/bin" "Azure/kubelogin" "kubelogin-linux-$ARCH.zip$"

github_install_deb "Peltoche/lsd" "^lsd_([0-9.]*)_$ARCH.deb$"

wget -q -O /usr/local/bin/kubectl \
  "https://storage.googleapis.com/kubernetes-release/release/$(wget -q https://storage.googleapis.com/kubernetes-release/release/stable.txt -q -O -)/bin/linux/amd64/kubectl" \
  && chmod +x /usr/local/bin/kubectl

curl -sL https://aka.ms/InstallAzureCLIDeb | bash

wget -q -O - "https://raw.githubusercontent.com/rancher/k3d/main/install.sh" | bash

curl -sLS "https://get.k3sup.dev" | sh

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash \
  && mv kustomize /usr/local/bin

wget -q -O helm.sh "https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3" \
  && chmod +x helm.sh \
  && ./helm.sh \
  && rm helm.sh

#wget -q -O f.sh https://sh.rustup.rs \
#  && chmod +x f.sh \
#  && ./f.sh -y \
#  && rm f.sh
#
#wget -q -O - "https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh" | bash 

# #\ 
# #\
# #&& wget -q -O /usr/local/bin/liqoctl "https://get.liqo.io/liqoctl-$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" \
# #&& chmod +x /usr/local/bin/liqoctl
