FROM ghcr.io/mazoea/docker-ci-build:u22g12py312

COPY assets/apt-requirements.txt /tmp/assets/apt-requirements.txt
COPY assets/include $TE_LIBS/include
COPY assets/lib/ $TE_LIBS/lib/

RUN apt-get -q update && \
    xargs -r apt-get -q install -y < /tmp/assets/apt-requirements.txt && \
    \
    cd / && \
    rm -rf /tmp/assets/ && \
    rm -rf /var/lib/apt/lists/* && \
    \
    cd $TE_LIBS/lib/ && \
    ln -sf libleptonica1.so.1.78.0 libleptonica1.so && \
    ln -sf libtesseract3-maz.so.3.0.2 libtesseract3-maz.so && \
    ln -sf libtesseract4-maz.so.4.1.0 libtesseract4-maz.so && \
    \
    git --version && \
    g++ --version && \
    gcc --version && \
    cmake --version && \
    python --version && \
    python3 --version

WORKDIR /te
