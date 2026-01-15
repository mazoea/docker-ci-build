FROM amazon/aws-lambda-python:3.12-arm64

ENV GCCVERSION=12

ENV HD=/mazoea
ENV TE_LIBS=/mazoea/installation
ENV TE_LIBS_LOGS=$TE_LIBS/__logs

WORKDIR /mazoea/ci/build/
COPY assets/os.specific.sh /mazoea/ci/build/os.specific.sh
COPY assets/dnf-requirements.txt /mazoea/ci/dnf-requirements.txt

RUN chmod +x ./os.specific.sh && \
    GIT_CONFIGURE=true GITDEPTH="--depth 3" ./os.specific.sh && \
    dnf clean all && \
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

ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

WORKDIR /te
