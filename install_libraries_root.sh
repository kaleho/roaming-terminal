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

github_install "/usr/local/bin/devspace" "loft-sh/devspace" "^devspace-linux-$ARCH$"
github_install "/usr/local/bin/docker-compose" "docker/compose" "^docker-compose-linux-x86_64$"
github_install "/usr/local/bin/kubectx" "ahmetb/kubectx" "^kubectx$"
github_install "/usr/local/bin/kubens" "ahmetb/kubectx" "^kubens$"
github_install "/usr/local/bin/kubie" "sbstp/kubie" "^kubie-linux-$ARCH$"
github_install "/usr/local/bin/rke" "rancher/rke" "^rke_linux-$ARCH$"
github_install "/usr/local/bin/terragrunt" "gruntwork-io/terragrunt" "^terragrunt_linux_$ARCH$"
github_install "/usr/local/bin/vcluster" "loft-sh/vcluster" "^vcluster-linux-$ARCH$"
github_install "/usr/local/bin/yq" "mikefarah/yq" "^yq_linux_$ARCH$"

github_install_tar "/usr/local/bin" "junegunn/fzf-bin" $(echo "$(uname -s | sed 's/[A-Z]/\L&/g')_$ARCH.tgz$")
github_install_tar "/usr/local/bin" "arttor/helmify" $(echo "Linux_64-bit.tar.gz$")

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
