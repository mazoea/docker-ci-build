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

# fix annoying git safety concerns
RUN GIT_CONFIGURE=true GITDEPTH="--depth 3" ./os.specific.sh

RUN DEBIAN_FRONTEND=noninteractive apt-get -q install -y zlib1g-dev liblzma-dev libffi-dev libssl-dev libsqlite3-dev libbz2-dev

# use locak packages instead of remote
# RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz -q -O /tmp/Python.tgz && \
COPY assets/local /tmp/packages/

# also python2 - because of pymod
# - use --enable-unicode=ucs4 because of amazon lambda
RUN cd /tmp/packages && tar -xf ./Python-2.7.18.tgz && \
    cd Python-2.7.18 && \
    ./configure  --with-cxx-main=/usr/bin/g++ --enable-unicode=ucs4 && \
    make -j4 && \
    make install

# RUN wget https://www.openssl.org/source/old/1.0.2/openssl-1.0.2u.tar.gz -q -O /tmp/openssl.tgz && \
# hack - /opt/openssl/
RUN cd /tmp/packages && tar -xf ./openssl-1.0.2u.tar.gz && \
    cd openssl-1.0.2u && \
    ./config -fPIC -shared  --prefix=/usr --openssldir=/usr && \
    make && mkdir lib && \
    cp -av ./*.so* ./lib && \
    cp -av ./*.a ./lib && \
    cp -av ./*.pc ./lib && \
    mv /tmp/packages/openssl-1.0.2u/ /opt/openssl/ && \
    make install && \
    cp /opt/openssl/libssl.so.1.0.0 /lib/x86_64-linux-gnu/libssl.so.1.0.0 && \
    cp /opt/openssl/libssl.a /usr/lib/x86_64-linux-gnu/libssl.a && \
    cp /opt/openssl/libcrypto.so.1.0.0 /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 && \
    cp /opt/openssl/libcrypto.a /usr/lib/x86_64-linux-gnu/libcrypto.a

RUN cd /tmp/packages && tar -xf ./Python-3.8.7.tgz && \
    cd Python-3.8.7 && \
    ./configure  --enable-optimizations --with-openssl=/opt/openssl/ --enable-unicode=ucs4 && \
    make -j4 && \
    make install

RUN ln -sf /usr/local/bin/python3 /usr/local/bin/python && \
    ln -sf /usr/local/bin/pip3 /usr/local/bin/pip

COPY assets/requirements.txt /mazoea/ci/requirements.txt
RUN PYTHONWARNINGS=once pip3 install -U --ignore-installed -r /mazoea/ci/requirements.txt
RUN python3 -c "import ssl ; print(ssl.OPENSSL_VERSION)"

RUN apt-get -q install -y docker.io

RUN rm -rf /tmp/packages

COPY assets/include $TE_LIBS/include
COPY assets/lib/ $TE_LIBS/lib/
RUN cd $TE_LIBS/lib/ && \
    ln -sf libleptonica1.so.1.78.0 libleptonica1.so && \
    ln -sf libtesseract3-maz.so.3.0.2 libtesseract3-maz.so && \
    ln -sf libtesseract4-maz.so.4.1.0 libtesseract4-maz.so

RUN mkdir -p ~/.ssh && chmod 0700 ~/.ssh

RUN python -c "import sys ; print('1114111 for UCS4, 65535 for UCS2: current value [%d]' % sys.maxunicode)"
RUN python3 -c "import sys ; print('1114111 for UCS4, 65535 for UCS2: current value [%d]' % sys.maxunicode)"

RUN git config --global --add safe.directory '*' && \
    git config --list

RUN git --version || true && \
    g++ --version || true && \
    gcc --version || true && \
    cmake --version || true && \
    python --version || true && \
    python3 --version || true

WORKDIR /te
