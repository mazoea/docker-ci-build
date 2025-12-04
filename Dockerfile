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

COPY assets /tmp/assets

# use local packages instead of remote
# RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz -q -O /tmp/Python.tgz && \


# RUN wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz -q -O /tmp/openssl.tgz && \
# hack - /opt/openssl/

RUN cp /tmp/assets/os.specific.sh /mazoea/ci/build/os.specific.sh && \
    cp /tmp/assets/apt-requirements.txt /mazoea/ci/apt-requirements.txt && \
    cp /tmp/assets/apt-requirements-full.txt /mazoea/ci/apt-requirements-full.txt && \
    cp /tmp/assets/requirements.txt /mazoea/ci/requirements.txt && \
    \
    apt-get -q update && \
    apt-get -q install -y locales build-essential && \
    locale-gen en_US.UTF-8 && \
    \
    GIT_CONFIGURE=true GITDEPTH="--depth 3" ./os.specific.sh && \
    apt-get -q install -y gcc-12 g++-12 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100 && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 100 && \
    \
    apt-get -q install -y zlib1g-dev liblzma-dev libffi-dev libssl-dev libsqlite3-dev libbz2-dev && \
    \
    cd /tmp/assets/local && tar -xf ./Python-3.13.0.tgz && \
    cd Python-3.13.0 && \
    ./configure  --enable-optimizations --with-ssl-default-suites=openssl && \
    make -j4 && \
    make install && \
    \
    cd / && \
    rm -rf /tmp/assets/local && \
    \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip

RUN apt-get -q update && \
    xargs apt-get -q install -y < /mazoea/ci/apt-requirements-full.txt

RUN PYTHONWARNINGS=once pip3 install -U --ignore-installed -r /mazoea/ci/requirements.txt && \
    python3 -c "import ssl ; print(ssl.OPENSSL_VERSION)"

RUN mkdir -p ~/.ssh && chmod 0700 ~/.ssh &&  \
    \
    python -c "import sys ; print('1114111 for UCS4, 65535 for UCS2: current value [%d]' % sys.maxunicode)" && \
    python3 -c "import sys ; print('1114111 for UCS4, 65535 for UCS2: current value [%d]' % sys.maxunicode)" && \
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
