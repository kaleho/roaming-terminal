FROM ubuntu:latest

ARG DEBIAN_FRONTEND=noninteractive

ARG DOCKER_COMPOSE_VERSION="1.29.2"
ARG DOCKER_VERSION="20.10.6"
ARG FZF_VERSION="0.21.1"
ARG KUBIE_VERSION="0.14.1"
ARG KUBECTX_VERSION="0.9.3"
ARG KUBENS_VERSION="0.9.3"
ARG LSDELUXE_VERSION="0.17.0"
ARG NERDS_FONT_VERSION="2.1.0"
ARG STERN_VERSION="1.11.0"
ARG TERRAFORM_VERSION="0.15.0"
ARG TERRAGRUNT_VERSION="0.29.0"

# How to get the Ubuntu code name: lsb_release -c -s

RUN set -ex \
  && apt update \
  && apt install --yes --no-install-recommends \
  # following line is for building neovim from source
  gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip build-essential \
  ca-certificates \
  curl \
  git \
  openssh-server \
  tmux \
  unzip \
  wget \
  zsh

# Install Docker Engine
RUN \
  wget -q -O archive.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz" \
  && tar zxvf archive.tgz --strip 1 -C /usr/local/bin docker/docker \
  && rm archive.tgz

# Install Docker Compose
RUN \
  wget -q -O /usr/local/bin/docker-compose "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" \
  && chmod +x /usr/local/bin/docker-compose

# Install kubectl
RUN \
  wget -q -O /usr/local/bin/kubectl "https://storage.googleapis.com/kubernetes-release/release/$(wget https://storage.googleapis.com/kubernetes-release/release/stable.txt -q -O -)/bin/linux/amd64/kubectl" \
  && chmod +x /usr/local/bin/kubectl

# Install terraform
RUN \
  wget -q -O archive.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" \
  && unzip archive.zip -d /usr/local/bin \
  && rm archive.zip

# Install terragrunt
RUN \
  wget -q -O /usr/local/bin/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64" \
  && chmod +x /usr/local/bin/terragrunt

# Install kubie
RUN \
  wget -q -O /usr/local/bin/kubie "https://github.com/sbstp/kubie/releases/download/v${KUBIE_VERSION}/kubie-linux-amd64" \
  && chmod +x /usr/local/bin/kubie

# Install kubectx
RUN \
  wget -q -O archive.tgz "https://github.com/ahmetb/kubectx/releases/download/v${KUBECTX_VERSION}/kubectx_v${KUBECTX_VERSION}_linux_x86_64.tar.gz" \
  && tar zxvf archive.tgz --directory /usr/local/bin \
  && rm archive.tgz

# Install kubens
RUN \
  wget -q -O archive.tgz "https://github.com/ahmetb/kubectx/releases/download/v${KUBENS_VERSION}/kubens_v${KUBENS_VERSION}_linux_x86_64.tar.gz" \
  && tar zxvf archive.tgz --directory /usr/local/bin \
  && rm archive.tgz

# Install stern
RUN \
  wget -q -O /usr/local/bin/stern "https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64" \
  && chmod +x /usr/local/bin/stern

# Install helm3
RUN \
  wget -q -O helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
  && chmod +x helm.sh \
  && ./helm.sh \
  && rm helm.sh

# Install neovim from source
RUN \
  git clone https://github.com/neovim/neovim && \
  cd neovim && \
  make CMAKE_BUILD_TYPE=Release install && \
  cd .. && \
  rm -r neovim

# Install LunarVim
RUN \
  curl -s https://raw.githubusercontent.com/ChristianChiarulli/lunarvim/master/utils/installer/install.sh | bash

# Install Azure CLI && Azure AKS CLI
RUN \
  curl -sL https://aka.ms/InstallAzureCLIDeb | bash 
  # && \
  # az aks install-cli

# Clean up 
RUN \  
  apt clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* *.deb

# Install FZF - executable only (required for zsh-interactive-cd)
RUN \
  FZF_DOWNLOAD_SHA256="7d4e796bd46bcdea69e79a8f571be1da65ae9d9cc984b50bc4af5c0b5754fbd5" \
  && wget -O fzf.tgz https://github.com/junegunn/fzf-bin/releases/download/${FZF_VERSION}/fzf-${FZF_VERSION}-linux_amd64.tgz \
  && echo "$FZF_DOWNLOAD_SHA256  fzf.tgz" | sha256sum -c - \
  && tar zxvf fzf.tgz --directory /usr/local/bin \
  && rm fzf.tgz

# install LSDeluxe
RUN \
  LSDELUXE_DOWNLOAD_SHA256="ac85771d6195ef817c9d14f8a8a0d027461bfc290d46cb57e434af342a327bb2" \
  && wget -O lsdeluxe.deb https://github.com/Peltoche/lsd/releases/download/${LSDELUXE_VERSION}/lsd_${LSDELUXE_VERSION}_amd64.deb \
  && echo "$LSDELUXE_DOWNLOAD_SHA256  lsdeluxe.deb" | sha256sum -c - \
  && dpkg -i lsdeluxe.deb \
  && rm lsdeluxe.deb

# install Fira Code from Nerd fonts
RUN \
  FONT_DIR=/usr/local/share/fonts \
  && FIRA_CODE_URL=https://github.com/ryanoasis/nerd-fonts/raw/${NERDS_FONT_VERSION}/patched-fonts/FiraCode \
  && FIRA_CODE_LIGHT_DOWNLOAD_SHA256="5e0e3b18b99fc50361a93d7eb1bfe7ed7618769f4db279be0ef1f00c5b9607d6" \
  && FIRA_CODE_REGULAR_DOWNLOAD_SHA256="3771e47c48eb273c60337955f9b33d95bd874d60d52a1ba3dbed924f692403b3" \
  && FIRA_CODE_MEDIUM_DOWNLOAD_SHA256="42dc83c9173550804a8ba2346b13ee1baa72ab09a14826d1418d519d58cd6768" \
  && FIRA_CODE_BOLD_DOWNLOAD_SHA256="060d4572525972b6959899931b8685b89984f3b94f74c2c8c6c18dba5c98c2fe" \
  && FIRA_CODE_RETINA_DOWNLOAD_SHA256="e254b08798d59ac7d02000a3fda0eac1facad093685e705ac8dd4bd0f4961b0b" \
  && mkdir -p $FONT_DIR \
  && wget -P $FONT_DIR $FIRA_CODE_URL/Light/complete/Fura%20Code%20Light%20Nerd%20Font%20Complete.ttf \
  && wget -P $FONT_DIR $FIRA_CODE_URL/Regular/complete/Fura%20Code%20Regular%20Nerd%20Font%20Complete.ttf \
  && wget -P $FONT_DIR $FIRA_CODE_URL/Medium/complete/Fura%20Code%20Medium%20Nerd%20Font%20Complete.ttf \
  && wget -P $FONT_DIR $FIRA_CODE_URL/Bold/complete/Fura%20Code%20Bold%20Nerd%20Font%20Complete.ttf \
  && wget -P $FONT_DIR $FIRA_CODE_URL/Retina/complete/Fura%20Code%20Retina%20Nerd%20Font%20Complete.ttf \
  && echo "$FIRA_CODE_LIGHT_DOWNLOAD_SHA256  $FONT_DIR/Fura Code Light Nerd Font Complete.ttf" | sha256sum -c - \
  && echo "$FIRA_CODE_REGULAR_DOWNLOAD_SHA256  $FONT_DIR/Fura Code Regular Nerd Font Complete.ttf" | sha256sum -c - \
  && echo "$FIRA_CODE_MEDIUM_DOWNLOAD_SHA256  $FONT_DIR/Fura Code Medium Nerd Font Complete.ttf" | sha256sum -c - \
  && echo "$FIRA_CODE_BOLD_DOWNLOAD_SHA256  $FONT_DIR/Fura Code Bold Nerd Font Complete.ttf" | sha256sum -c - \
  && echo "$FIRA_CODE_RETINA_DOWNLOAD_SHA256  $FONT_DIR/Fura Code Retina Nerd Font Complete.ttf" | sha256sum -c -

ENV APP_USER=user01
ENV APP_USER_GROUP=www-data
ARG APP_USER_HOME=/home/$APP_USER

# create non root user
RUN \
  adduser --quiet --disabled-password \
  --shell /bin/bash \
  --gecos "user01" $APP_USER \
  --ingroup $APP_USER_GROUP

USER $APP_USER
WORKDIR $APP_USER_HOME

# install oh-my-zsh
RUN wget -qO- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | zsh || true

ARG ZSH_CUSTOM=$APP_USER_HOME/.oh-my-zsh/custom

# install oh-my-zsh plugins and theme
RUN \
  ZSH_PLUGINS=$ZSH_CUSTOM/plugins \
  && ZSH_THEMES=$ZSH_CUSTOM/themes \
  && git clone --single-branch --branch '0.7.1' --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_PLUGINS/zsh-syntax-highlighting \
  && git clone --single-branch --branch 'v0.6.4' --depth 1 https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_PLUGINS/zsh-autosuggestions \
  && git clone --single-branch --depth 1 https://github.com/romkatv/powerlevel10k.git $ZSH_THEMES/powerlevel10k

# install oh-my-zsh config files
COPY --chown=$APP_USER:$APP_USER_GROUP ./config/.zshrc ./config/.p10k.zsh $APP_USER_HOME/
COPY --chown=$APP_USER:$APP_USER_GROUP ./config/aliases.zsh $ZSH_CUSTOM

CMD ["zsh"]
