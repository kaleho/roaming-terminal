FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true	

ARG DEVSPACE_VERSION="5.18.1"
ARG DOCKER_COMPOSE_VERSION="2.1.1"
ARG DOCKER_VERSION="20.10.9"
ARG FZF_VERSION="0.23.1"
ARG KUBIE_VERSION="0.15.1"
ARG KUBECTX_VERSION="0.9.4"
ARG KUBENS_VERSION="0.9.4"
ARG LSDELUXE_VERSION="0.20.1"
ARG STERN_VERSION="1.11.0"
ARG TERRAFORM_VERSION="1.1.7"
ARG TERRAGRUNT_VERSION="0.36.6"
ARG VCLUSTER_VERSION="0.4.5"

ARG USER_NAME
ARG USER_UID
ARG USER_GID

RUN apt update; \
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

RUN wget -q https://packages.microsoft.com/config/debian/11/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
  && dpkg -i packages-microsoft-prod.deb \
  && rm packages-microsoft-prod.deb

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
  && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

RUN apt update; \
  apt install -y \
  dotnet-sdk-6.0 \
  gh

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

RUN groupadd --gid $USER_GID $USER_NAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USER_NAME \
  && echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME \
  && chmod 0440 /etc/sudoers.d/$USER_NAME \
  && groupadd docker \
  && usermod -aG docker $USER_NAME

COPY remote /usr/bin
COPY code /usr/bin
COPY zsh-in-docker.sh /tmp
COPY download-vs-code-server.sh /tmp

RUN \
  wget -q -O archive.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
  && tar zxvf archive.tgz --strip 1 -C /usr/local/bin docker/docker \
  && rm archive.tgz \
  \
  && wget -q -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/v${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  && chmod +x /usr/local/bin/docker-compose \
  \
  && wget -q -O - "https://raw.githubusercontent.com/rancher/k3d/main/install.sh" | bash \
  \
  && curl -sLS "https://get.k3sup.dev" | sh \
  \
  && curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash \
  && mv kustomize /usr/local/bin \
  \
  && wget -q -O /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$(wget -q https://storage.googleapis.com/kubernetes-release/release/stable.txt -q -O -)/bin/linux/amd64/kubectl" \
  && chmod +x /usr/local/bin/kubectl \
  \
  && wget -q -O archive.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip archive.zip -d /usr/local/bin \
  && rm archive.zip \
  \
  && wget -q -O /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
  && chmod +x /usr/local/bin/terragrunt \
  \
  && wget -q -O /usr/local/bin/kubie "https://github.com/sbstp/kubie/releases/download/v${KUBIE_VERSION}/kubie-linux-amd64" \
  && chmod +x /usr/local/bin/kubie \
  \
  && wget -q -O archive.tgz "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubectx_v${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
  && tar zxvf archive.tgz --directory /usr/local/bin \
  && rm archive.tgz \
  \
  && wget -q -O archive.tgz "https://github.com/ahmetb/kubectx/releases/download/v${KUBENS_VERSION}/kubens_v${KUBENS_VERSION}_linux_x86_64.tar.gz" \
  && tar zxvf archive.tgz --directory /usr/local/bin \
  && rm archive.tgz \
  \
  && wget -q -O /usr/local/bin/stern "https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64" \
  && chmod +x /usr/local/bin/stern \
  \
  && wget -q -O helm.sh "https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3" \
  && chmod +x helm.sh \
  && ./helm.sh \
  && rm helm.sh \
  \
  && wget -q -O fzf.tgz "https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz" \
  && tar zxvf fzf.tgz --directory /usr/local/bin \
  && rm fzf.tgz \
  \
  && wget -q -O lsdeluxe.deb "https://github.com/Peltoche/lsd/releases/download/${LSDELUXE_VERSION}/lsd_${LSDELUXE_VERSION}_amd64.deb" \
  && dpkg -i lsdeluxe.deb \
  && rm lsdeluxe.deb \
  \
  && wget -q -O /usr/local/bin/vcluster "https://github.com/loft-sh/vcluster/releases/download/v${VCLUSTER_VERSION}/vcluster-linux-amd64" \
  && chmod +x /usr/local/bin/vcluster \ 
  \
  && wget -q -O devspace "https://github.com/loft-sh/devspace/releases/download/v${DEVSPACE_VERSION}/devspace-linux-amd64" \
  && chmod +x devspace \
  && install devspace /usr/local/bin \
  \
  && wget -q -O f.sh https://sh.rustup.rs \
  && chmod +x f.sh \
  && ./f.sh -y \
  && rm f.sh \
  \
  && wget -q -O - "https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh" | bash \ 
  \
  && wget -q -O /usr/local/bin/liqoctl "https://get.liqo.io/liqoctl-$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" \
  && chmod +x /usr/local/bin/liqoctl

# Everything past this point is done in the user context
USER $USER_NAME

# Setup fancy zsh
RUN /tmp/zsh-in-docker.sh \
    -p git \ 
    -p colored-man-pages \
    -p colorize \
    -p command-not-found \
    -p cp \
    -p copypath \
    -p copyfile \
    -p dirhistory \
    -p extract \
    -p globalias \
    -p z \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions \
    -p https://github.com/zsh-users/zsh-history-substring-search \
    -p https://github.com/zsh-users/zsh-syntax-highlighting \
    -p 'history-substring-search' \
    -a 'bindkey "\$terminfo[kcuu1]" history-substring-search-up' \
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down' \
  && \
  export SHELL=/bin/zsh

# Installers that are contextual to the user
WORKDIR /home/$USER_NAME
RUN \
  curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash \
  && \
  echo 'export NVM_DIR="$HOME/.nvm"' >> /home/$USER_NAME/.zshrc \
  && \
  echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm' >> /home/$USER_NAME/.zshrc \
  && \
  echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> /home/$USER_NAME/.zshrc \
  && \
  export NVM_DIR="/home/$USER_NAME/.nvm" \
  && \
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" \
  && \
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" \
  && \
  nvm install --lts --latest-npm \
  && \
  curl -fsSL "https://get.pulumi.com" | sh \
  && \
  echo "export PATH=\$PATH:\$HOME/.pulumi/bin" >> /home/$USER_NAME/.zshrc \
  \
  && mkdir krew \
  && cd krew \
  && wget -q -O archive.tar.gz "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew-$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/').tar.gz" \
  && tar zxvf archive.tar.gz \
  && ./"krew-$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" install krew \
  && cd .. \
  && rm -r -f krew \
  && echo "export PATH=\"\${KREW_ROOT:-\$HOME/.krew}/bin:\$PATH\"" >> /home/$USER_NAME/.zshrc

RUN /tmp/download-vs-code-server.sh 

USER root

# Clean up 
RUN \  
  apt clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* *.deb

USER $USER_NAME

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
