FROM ubuntu:16.04

ENV GCCVERSION=8
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
# also python2 - because of pymod
# - use --enable-unicode=ucs4 because of amazon lambda
# RUN wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz -q -O /tmp/openssl.tgz && \
# hack - /opt/openssl/

RUN cp /tmp/assets/os.specific.sh /mazoea/ci/build/os.specific.sh && \
    cp /tmp/assets/apt-requirements.txt /mazoea/ci/apt-requirements.txt && \
    cp /tmp/assets/apt-requirements-full.txt /mazoea/ci/apt-requirements-full.txt && \
    cp /tmp/assets/requirements.txt /mazoea/ci/requirements.txt && \
    \
    apt-get -q update && \
    apt-get -q install -y locales && \
    locale-gen en_US.UTF-8 && \
    \
    GIT_CONFIGURE=true GITDEPTH="--depth 3" ./os.specific.sh && \
    apt-get -q install -y zlib1g-dev liblzma-dev libffi-dev libssl-dev libsqlite3-dev libbz2-dev && \
    \
    cd /tmp/assets/local && tar -xf ./Python-2.7.18.tgz && \
    cd Python-2.7.18 && \
    ./configure  --with-cxx-main=/usr/bin/g++ --enable-unicode=ucs4 && \
    make -j4 && \
    make install && \
    \
    cd /tmp/assets/local && tar -xf ./openssl-1.0.2u.tar.gz && \
    cd openssl-1.0.2u && \
    ./config -fPIC -shared  --prefix=/usr --openssldir=/usr && \
    make && mkdir lib && \
    cp -av ./*.so* ./lib && \
    cp -av ./*.a ./lib && \
    cp -av ./*.pc ./lib && \
    \
    mv /tmp/assets/local/openssl-1.0.2u/ /opt/openssl/ && \
    make install && \
    cp /opt/openssl/libssl.so.1.0.0 /lib/x86_64-linux-gnu/libssl.so.1.0.0 && \
    cp /opt/openssl/libssl.a /usr/lib/x86_64-linux-gnu/libssl.a && \
    cp /opt/openssl/libcrypto.so.1.0.0 /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 && \
    cp /opt/openssl/libcrypto.a /usr/lib/x86_64-linux-gnu/libcrypto.a && \
    \
    cd /tmp/assets/local && tar -xf ./Python-3.8.7.tgz && \
    cd Python-3.8.7 && \
    ./configure  --enable-optimizations --with-openssl=/opt/openssl/ --enable-unicode=ucs4 && \
    make -j4 && \
    make install && \
    \
    rm -rf /tmp/assets/local && \
    \
    ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip && \
    \
    PYTHONWARNINGS=once pip3 install -U --ignore-installed -r /mazoea/ci/requirements.txt && \
    python3 -c "import ssl ; print(ssl.OPENSSL_VERSION)"

RUN xargs apt-get -q install -y < /mazoea/ci/apt-requirements-full.txt

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
