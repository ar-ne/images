ARG MINICONDA_VER=24.7.1-0
FROM continuumio/miniconda3:${MINICONDA_VER} AS base
RUN apt update && apt upgrade -y && \
    apt install -y curl wget zsh git \
    jq micro sudo ffmpeg libsm6 libxext6 \
    unzip p7zip unar file build-essential \
    make cmake htop
RUN curl -fsSL https://code-server.dev/install.sh | sh
RUN ln -s $(which code-server) /usr/bin/code
RUN groupadd -g 1000 coder && \
    useradd -u 1000 -g coder -m coder && \
    passwd -d coder && \
    passwd -d root && \
    usermod -aG sudo coder && \
    sudo sed -i "s|\(^coder:.*:\)/bin/[^:]*$|\1$(which zsh)|" /etc/passwd && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

RUN conda install -y nvidia/label/cuda-12.4.0::cuda-nvcc conda-forge::nvitop pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia

# install omz
WORKDIR /home/coder
USER coder
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN sed -i "1i unsetopt PROMPT_SP" /home/coder/.zshrc
RUN sed -i "1i zstyle ':omz:update' mode disabled" /home/coder/.zshrc
RUN conda init zsh
RUN sudo apt-get clean

# compress for different JB ide
FROM scratch AS pre-jb-ide
COPY --from=base / /

# install jetbrain ide backend
FROM pre-jb-ide
ARG IDE_CODE=PCP
COPY jbdl /usr/bin
RUN chmod +x /usr/bin/jbdl && \
    mkdir -p /opt/jetbrains && \
    chown coder /opt/jetbrains

USER coder
RUN jbdl install ${IDE_CODE} && \
    jbdl local '*' reg && \
    rm -rf /tmp/jb

ENV DISABLE_AUTO_UPDATE=true
WORKDIR /home/coder
