FROM ubuntu:22.04

ENV GCCVERSION=12

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV DEBIAN_FRONTEND=noninteractive 

ENV HD=/mazoea
ENV TE_LIBS=/mazoea/installation
ENV TE_LIBS_LOGS=$TE_LIBS/__logs

WORKDIR /mazoea/ci/build/
COPY assets/os.specific.sh /mazoea/ci/build/os.specific.sh
COPY assets/apt-requirements.txt /mazoea/ci/apt-requirements.txt

RUN apt-get -q update && \
    apt-get -q install -y locales && \
    locale-gen en_US.UTF-8 && \
    \
    GIT_CONFIGURE=true GITDEPTH="--depth 3" ./os.specific.sh && \
    apt-get -q install -y zlib1g-dev liblzma-dev libffi-dev libssl-dev libsqlite3-dev libbz2-dev docker.io && \
    \
    cd / && \
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
