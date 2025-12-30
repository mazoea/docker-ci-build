FROM ghcr.io/mazoea/docker-ci-build:u22g12py312

COPY assets/apt-requirements.txt /tmp/assets/apt-requirements.txt
COPY assets/requirements.txt /tmp/assets/requirements.txt

RUN apt-get -q update && \
    xargs -r apt-get -q install -y < /tmp/assets/apt-requirements.txt && \
    pip3 install --root-user-action=ignore -q --no-cache-dir --upgrade pip && \
    pip3 install -q --no-cache-dir --user -r /tmp/assets/requirements.txt && \
    \
    (rm -rf $SYSPYTHONCACHE/torch/include/ $SYSPYTHONCACHE/torch/test || true) && \
    \
    cd / && \
    rm -rf /tmp/assets/ && \
    rm -rf /var/lib/apt/lists/* && \
    \
    git --version && \
    g++ --version && \
    gcc --version && \
    cmake --version && \
    python --version && \
    python3 --version
