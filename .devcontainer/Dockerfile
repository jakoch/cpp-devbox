# +-----------------------------+
# | BASE IMAGE                  |        See https://hub.docker.com/_/debian
# +-----------------------------+

# for GCC 12
FROM debian:bookworm-slim as cpp-devbox-base

# for GCC 13
#FROM gcc:13-bookworm

# +-----------------------------+
# | ARGS                        |
# +-----------------------------+

ARG DEBIAN_VERSION=12
ARG DEBIAN_VERSION_NAME=bookworm
ARG GCC_VERSION=12
ARG LLVM_VERSION=17

# +-----------------------------+
# | METADATA                    |
# +-----------------------------+

LABEL \
    maintainer="Jens A. Koch <jakoch@web.de>" \
    org.opencontainers.image.authors='Jens A. Koch <jakoch@web.de>' \
    org.opencontainers.image.url='https://github.com/jakoch/cpp-devbox/tree/main' \
    org.opencontainers.image.source='https://github.com/jakoch/cpp-devbox'\
    org.opencontainers.image.title='ghcr.io/jakoch/cpp-devbox'\
    org.opencontainers.image.description="C++ DevBox (Debian ${DEBIAN_VERSION}-${DEBIAN_VERSION_NAME} with LLVM ${LLVM_VERSION} & GCC ${GCC_VERSION}), CMake, VCPKG, zsh"

# +-----------------------------+
# | PRE-REQUISITE/INIT PACKAGES |
# +-----------------------------+

ENV DEBIAN_FRONTEND=noninteractive

# avoid debconf delaying package configuration, since apt-utils is not installed
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils dialog 2>&1

RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 ca-certificates software-properties-common \
    build-essential cppcheck valgrind ccache cmake wget git jq \
    # required by Visual Studio
    g++ gdb make ninja-build rsync zip sudo \
    # required by VCPKG
    openssh-server tar curl unzip pkg-config bash-completion \
    # optional downloader for VCPKG
    aria2 \
    # required by LLVM
    lsb-release zlib1g-dev \
    # locale
    locales \
    # shell
    zsh
    # iproute2 procps less gnupg

# +-----------------------------+
# | LLVM                        |
# +-----------------------------+

# llvm.sh is constantly broken, see https://github.com/llvm/llvm-project/issues/62475
#RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh ${LLVM_VERSION} all && rm ./llvm.sh

RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

RUN add-apt-repository -y "deb http://apt.llvm.org/$DEBIAN_VERSION_NAME/ llvm-toolchain main" && \
    add-apt-repository -y "deb http://apt.llvm.org/$DEBIAN_VERSION_NAME/ llvm-toolchain-$DEBIAN_VERSION_NAME-$LLVM_VERSION main"
RUN apt-get update && apt-get install -y --no-install-recommends \
    clang-$LLVM_VERSION \
    clangd-$LLVM_VERSION \
    clang-tidy-$LLVM_VERSION \
    clang-format-$LLVM_VERSION \
    clang-tools-$LLVM_VERSION \
    llvm-$LLVM_VERSION-dev \
    llvm-$LLVM_VERSION-runtime \
    llvm-$LLVM_VERSION-tools \
    lld-$LLVM_VERSION \
    lldb-$LLVM_VERSION \
    libomp-$LLVM_VERSION-dev \
    libc++-$LLVM_VERSION-dev \
    libc++abi-$LLVM_VERSION-dev \
    libclang-common-$LLVM_VERSION-dev \
    libclang-$LLVM_VERSION-dev \
    libclang-cpp$LLVM_VERSION-dev \
    libunwind-$LLVM_VERSION-dev \
    libclang-rt-$LLVM_VERSION-dev \
    libpolly-$LLVM_VERSION-dev

# add llvm to path
ENV PATH="/usr/lib/llvm-${LLVM_VERSION}/bin:/usr/lib/llvm-${LLVM_VERSION}/include:${PATH}"
ENV LD_LIBRARY_PATH="/usr/lib/llvm-${LLVM_VERSION}/lib:${LD_LIBRARY_PATH}"

# unversionize the binaries
RUN ln -s /usr/bin/clang-${LLVM_VERSION} /usr/bin/clang && \
    ln -s /usr/bin/clang++-${LLVM_VERSION} /usr/bin/clang++ && \
    ln -s /usr/bin/clang-format-${LLVM_VERSION} /usr/bin/clang-format

# update compiler environment vars
ENV CC=/usr/bin/clang
ENV CXX=/usr/bin/clang++

# update alternatives
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

# +-----------------------------+
# | CLEANUP                     |
# +-----------------------------+

RUN apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/*

# +-----------------------------+
# | Set Locale + Timezone       |
# +-----------------------------+

ENV TZ=Europe/Berlin

# configure german locale
RUN echo $TZ > /etc/timezone && \
    dpkg-reconfigure tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="de_DE.UTF-8"' > /etc/default/locale && \
    dpkg-reconfigure locales && \
    update-locale LANG=de_DE.UTF-8

#ENV LANG=de_DE.UTF-8
#ENV LC_ALL=de_DE.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

RUN echo "export PATH=$PATH" > /etc/environment

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# +----------------------------------+
# | Stage: cpp-devbox-with-vulkansdk |
# +----------------------------------+

FROM cpp-devbox-base as cpp-devbox-with-vulkansdk

ARG VULKAN_SDK_VERSION=1.3.261.1

# +-----------------------------+
# | METADATA                    |
# +-----------------------------+

LABEL \
    maintainer="Jens A. Koch <jakoch@web.de>" \
    org.opencontainers.image.authors='Jens A. Koch <jakoch@web.de>' \
    org.opencontainers.image.url='https://github.com/jakoch/cpp-devbox/tree/main' \
    org.opencontainers.image.source='https://github.com/jakoch/cpp-devbox'\
    org.opencontainers.image.title='ghcr.io/jakoch/cpp-devbox'\
    org.opencontainers.image.description="C++ DevBox (Debian ${DEBIAN_VERSION}-${DEBIAN_VERSION_NAME} with LLVM ${LLVM_VERSION} & GCC ${GCC_VERSION}), VulkanSDK ${VULKAN_SDK_VERSION}), CMake, VCPKG, zsh"

# +-----------------------------+
# | Vulkan SDK                  |
# +-----------------------------+

RUN wget -q --show-progress --progress=bar:force:noscroll \
      "https://sdk.lunarg.com/sdk/download/${VULKAN_SDK_VERSION}/linux/vulkansdk-linux-x86_64-${VULKAN_SDK_VERSION}.tar.xz" \
      -O /tmp/vulkansdk.xz && \
    mkdir -p /opt/vulkan && \
    tar xvf /tmp/vulkansdk.xz -C /opt/vulkan && \
    rm /tmp/vulkansdk.xz

ENV VULKAN_SDK=/opt/vulkan/${VULKAN_SDK_VERSION}/x86_64
ENV PATH="$VULKAN_SDK/bin:$PATH" \
    LD_LIBRARY_PATH="$VULKAN_SDK/lib:${LD_LIBRARY_PATH:-}" \
    VK_LAYER_PATH="$VULKAN_SDK/etc/vulkan/explicit_layer.d"
