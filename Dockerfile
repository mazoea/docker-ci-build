FROM ghcr.io/mazoea/docker-ci-build:u22g12

COPY assets/apt-requirements.txt /tmp/assets/apt-requirements.txt

RUN apt-get -q update && \
    xargs apt-get -q install -y < /tmp/assets/apt-requirements.txt \
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
    git --version || true && \
    g++ --version || true && \
    gcc --version || true && \
    cmake --version || true && \
    python --version || true && \
    python3 --version || true

WORKDIR /te
