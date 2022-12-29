FROM debian:bullseye-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG DEBCONF_NONINTERACTIVE_SEEN=true	

ARG GH_TOKEN
ARG USER_NAME
ARG USER_UID
ARG USER_GID

COPY code /usr/bin/
COPY install_libraries*.sh /tmp/
COPY remote /usr/bin/
COPY zsh-in-docker.sh /tmp/

RUN groupadd --gid $USER_GID $USER_NAME; \
  useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USER_NAME; \
  echo $USER_NAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USER_NAME; \
  chmod 0440 /etc/sudoers.d/$USER_NAME; \
  groupadd docker; \
  usermod -aG docker $USER_NAME

RUN /tmp/install_libraries_root.sh

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
RUN USER=$USER_NAME /tmp/install_libraries_user.sh

#RUN /tmp/download-vs-code-server.sh 

USER root

# Clean up 
RUN \  
  apt clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* *.deb

USER $USER_NAME

ENTRYPOINT [ "/bin/zsh" ]
CMD ["-l"]
