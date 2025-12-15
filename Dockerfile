FROM ghcr.io/mazoea/docker-ci-build:u22g12

COPY assets/apt-requirements.txt /tmp/assets/apt-requirements.txt
COPY assets/local/Python-3.12.12.tgz /tmp/assets/Python-3.12.12.tgz
ENV PYTHONVERSION=3.12.12


RUN apt-get -q update && \
    xargs apt-get -q install -y < /tmp/assets/apt-requirements.txt \
    \
    cd /tmp/assets/ && tar -xf ./Python-${PYTHONVERSION}.tgz && \
    cd Python-${PYTHONVERSION} && \
    ./configure  --enable-optimizations --with-ssl-default-suites=openssl && \
    make -j4 && \
    make install && \
    \
    cd / && \
    rm -rf /tmp/assets/local && \
    rm -rf /var/lib/apt/lists/* && \
    \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip \
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
