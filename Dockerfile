FROM ghcr.io/mazoea/docker-ci-build:u22g12py312

COPY assets/requirements.txt /tmp/assets/requirements.txt
COPY assets/apt-requirements.txt /tmp/assets/apt-requirements.txt


RUN apt-get -q update && \
    xargs -r apt-get -q install -y < /tmp/assets/apt-requirements.txt && \
    \
    cd / && \
    install -d -m 0755 /etc/apt/keyrings && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /etc/apt/keyrings/apt.llvm.org.gpg && \
    echo 'deb [signed-by=/etc/apt/keyrings/apt.llvm.org.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy main' > /etc/apt/sources.list.d/llvm.list && \
    apt-get update -y && \
    apt-get install -y clang clang-tidy libc++-dev libc++abi-dev && \
    \
    rm -rf /tmp/assets/ && \
    rm -rf /var/lib/apt/lists/* && \
    \
    clang-tidy --version && \
    git --version && \
    g++ --version && \
    gcc --version && \
    cmake --version && \
    python --version && \
    python3 --version

WORKDIR /te
