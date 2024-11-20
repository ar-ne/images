ARG cuda=12.6.0
ARG distro=ubuntu24.04
FROM nvidia/cuda:${cuda}-cudnn-devel-${distro} AS base
RUN apt update && \
    apt install -y wget curl sudo zsh git build-essential && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* \

RUN apt update && apt upgrade -y && \
    apt install -y curl wget zsh git \
    jq micro sudo ffmpeg libsm6 libxext6 \
    unzip p7zip unar file build-essential \
    make cmake htop
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN ln -s $(which code-server) /usr/bin/code

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN sed -i "s/ubuntu/coder/g" /etc/passwd && \
    sed -i "s/Ubuntu/coder/g" /etc/passwd && \
    sudo sed -i "s|\(^coder:.*:\)/bin/[^:]*$|\1$(which zsh)|" /etc/passwd && \
    mv /home/ubuntu /home/coder && \
    chown -R 1000:1000 /home/coder && \
    passwd -d coder && \
    passwd -d root && \
    usermod -aG sudo coder

# install omz
WORKDIR /home/coder
USER coder
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sed -i "1i unsetopt PROMPT_SP" /home/coder/.zshrc
RUN sed -i "1i zstyle ':omz:update' mode disabled" /home/coder/.zshrc
RUN conda init zsh
RUN sudo apt-get clean

FROM scratch
COPY --from=base / /

USER coder
WORKDIR /home/coder