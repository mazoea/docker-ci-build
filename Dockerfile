FROM ubuntu:16.04

ENV GCCVERSION=8

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get install -y locales

RUN locale-gen en_US.UTF-8
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

RUN GIT_CONFIGURE=true GITDEPTH="--depth 3" ./os.specific.sh

RUN git --version || true && \
    g++ --version || true && \
    gcc --version || true && \
    cmake --version || true && \
    python --version || true && \
    python3 --version || true

WORKDIR /te
