ARG cuda=12.6.0
ARG distro=ubuntu24.04
FROM nvidia/cuda:${cuda}-cudnn-devel-${distro} AS base
RUN apt update && \
    apt install -y wget curl sudo zsh git build-essential && \
    apt clean && \
    rm -rf /var/lib/apt/lists/* \

RUN curl -fsSL https://code-server.dev/install.sh | sh

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN sed -i "s/ubuntu/coder/g" /etc/passwd && \
    sed -i "s/Ubuntu/coder/g" /etc/passwd && \
    mv /home/ubuntu /home/coder && \
    chown -R 1000:1000 /home/coder && \
    passwd -d coder && \
    passwd -d root && \
    usermod -aG sudo coder

FROM scratch
COPY --from=base / /
USER coder
WORKDIR /home/coder