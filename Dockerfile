FROM ghcr.io/mazoea/docker-ci-build:u22g12

COPY assets/apt-requirements.txt /tmp/assets/apt-requirements.txt

RUN apt-get -q update && \
    xargs -r apt-get -q install -y < /tmp/assets/apt-requirements.txt && \
    \
    cd / && \
    rm -rf /tmp/assets/ && \
    rm -rf /var/lib/apt/lists/* && \
    \
    mkdir -p ~/.ssh && chmod 0700 ~/.ssh &&  \
    \
    git config --system --add safe.directory '*' && \
    git config --list --show-origin && \
    \
    git --version && \
    g++ --version && \
    gcc --version && \
    cmake --version && \
    python3 --version

WORKDIR /te
