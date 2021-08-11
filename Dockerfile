FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

ARG DOCKER_COMPOSE_VERSION="1.29.2"
ARG DOCKER_VERSION="20.10.6"
ARG FZF_VERSION="0.21.1"
ARG KUBIE_VERSION="0.14.1"
ARG KUBECTX_VERSION="0.9.3"
ARG KUBENS_VERSION="0.9.3"
ARG LSDELUXE_VERSION="0.17.0"
ARG STERN_VERSION="1.11.0"
ARG TERRAFORM_VERSION="1.0.4"
ARG TERRAGRUNT_VERSION="0.29.0"

ARG USERNAME=user01
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && apt update \
  && apt install --yes \
  sudo \
  gettext libtool libtool-bin autoconf automake cmake g++ pkg-config build-essential \
  ca-certificates \
  curl \
  git \
  openssh-server \
  python3-pip \
  nodejs \
  npm \
  tmux \
  unzip \
  wget \
  zsh \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME

# Install tools
RUN \
  wget -q -O archive.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
  && tar zxvf archive.tgz --strip 1 -C /usr/local/bin docker/docker \
  && rm archive.tgz \
  \
  && wget -q -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  && chmod +x /usr/local/bin/docker-compose \
  \
  && wget -q -O /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$(wget https://storage.googleapis.com/kubernetes-release/release/stable.txt -q -O -)/bin/linux/amd64/kubectl" \
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
  && wget -q -O helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
  && chmod +x helm.sh \
  && ./helm.sh \
  && rm helm.sh \
  \
  && FZF_DOWNLOAD_SHA256="7d4e796bd46bcdea69e79a8f571be1da65ae9d9cc984b50bc4af5c0b5754fbd5" \
  && wget -O fzf.tgz https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz \
  && echo "$FZF_DOWNLOAD_SHA256  fzf.tgz" | sha256sum -c - \
  && tar zxvf fzf.tgz --directory /usr/local/bin \
  && rm fzf.tgz \
  \
  && LSDELUXE_DOWNLOAD_SHA256="ac85771d6195ef817c9d14f8a8a0d027461bfc290d46cb57e434af342a327bb2" \
  && wget -O lsdeluxe.deb https://github.com/Peltoche/lsd/releases/download/${LSDELUXE_VERSION}/lsd_${LSDELUXE_VERSION}_amd64.deb \
  && echo "$LSDELUXE_DOWNLOAD_SHA256  lsdeluxe.deb" | sha256sum -c - \
  && dpkg -i lsdeluxe.deb \
  && rm lsdeluxe.deb

# RUN \
#   add-apt-repository --yes ppa:neovim-ppa/stable \
#   && apt update \
#   && apt install --yes --no-install-recommends \
#   gettext libtool libtool-bin autoconf automake cmake g++ pkg-config build-essential \
  # neovim 
  # && bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh) \
  # && curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | bash

# Install neovim from source
# RUN \
#   git clone https://github.com/neovim/neovim && \
#   cd neovim && \
#   make CMAKE_BUILD_TYPE=RelWithDebInfo && \
#   make install && \
#   cd .. && \
#   rm -r neovim

RUN \
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage \
  && chmod u+x nvim.appimage \
  && ./nvim.appimage --appimage-extract \
  && ln -s /squashfs-root/AppRun /usr/bin/nvim

RUN \
  # bash <(curl -s https://raw.githubusercontent.com/lunarvim/LunarVim/rolling/utils/bin/install-latest-neovim)
  # curl -s https://raw.githubusercontent.com/lunarvim/LunarVim/rolling/utils/bin/install-latest-neovim | bash
  curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh | bash

USER $USERNAME

COPY zsh-in-docker.sh /tmp
RUN /tmp/zsh-in-docker.sh \
    -p git \
    -p colored-man-pages \
    -p colorize \
    -p command-not-found \
    -p cp \
    -p copydir \
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
    -a 'bindkey "\$terminfo[kcud1]" history-substring-search-down'

# Clean up 
RUN \  
  sudo apt clean && \
  sudo rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* *.deb

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
