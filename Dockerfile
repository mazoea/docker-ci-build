FROM ghcr.io/mazoea/docker-ci-build:u22g12py312

COPY assets/apt-requirements.txt /tmp/assets/apt-requirements.txt
COPY assets/oclint-22.02-llvm-13.0.1-x86_64-linux-ubuntu-20.04.tar.gz /opt/

RUN apt-get -q update && \
    xargs -r apt-get -q install -y < /tmp/assets/apt-requirements.txt && \
    cd / && \
    rm -rf /tmp/assets/ && \
    rm -rf /var/lib/apt/lists/* && \
    cd /opt && \
    tar xvzf ./oclint-22.02-llvm-13.0.1-x86_64-linux-ubuntu-20.04.tar.gz && \
    rm -f ./oclint-22.02-llvm-13.0.1-x86_64-linux-ubuntu-20.04.tar.gz && \
        mv oclint-22.02 oclint && \
    \
    git --version && \
    g++ --version && \
    gcc --version && \
    cmake --version && \
    python --version && \
    python3 --version

WORKDIR /te
ENV PATH=/opt/oclint/bin:$PATH
RUN oclint --version
