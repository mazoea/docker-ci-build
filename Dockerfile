FROM ghcr.io/mazoea/docker-ci-build:u22g12py312

# Fail build on any RUN command error (including pipelines).
SHELL ["/bin/bash", "-euo", "pipefail", "-c"]

COPY assets/requirements.txt /tmp/assets/requirements.txt
COPY assets/apt-requirements.txt /tmp/assets/apt-requirements.txt

ENV LLVM_VERSION=22

RUN apt-get -q update && \
    xargs -r apt-get -q install -y < /tmp/assets/apt-requirements.txt && \
    \
    cd / && \
    install -d -m 0755 /etc/apt/keyrings && \
    wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /etc/apt/keyrings/apt.llvm.org.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/apt.llvm.org.gpg] http://apt.llvm.org/jammy/ llvm-toolchain-jammy main" > /etc/apt/sources.list.d/llvm.list && \
    apt-get update -y && \
    apt-get install -y clang-${LLVM_VERSION} clang-tidy-${LLVM_VERSION} llvm-${LLVM_VERSION} libc++-dev libc++abi-dev && \
    \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-${LLVM_VERSION} 100 \
        --slave /usr/bin/clang++ clang++ /usr/bin/clang++-${LLVM_VERSION} && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-${LLVM_VERSION} 100 && \
    \
    rm -rf /tmp/assets/ && \
    rm -rf /var/lib/apt/lists/* && \
    \
    clang --version && \
    clang-tidy --version && \
    llvm-readelf-${LLVM_VERSION} --version && \
    git --version && \
    g++ --version && \
    gcc --version && \
    cmake --version && \
    python --version && \
    python3 --version

WORKDIR /te
