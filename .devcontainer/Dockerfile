# +-----------------------------+
# | BASE IMAGE             ~30MB|        See https://hub.docker.com/_/debian
# +-----------------------------+

# GCC 12
FROM debian:bookworm-slim

 # GCC 13
#FROM gcc:13-bookworm

# https://github.com/devcontainers/images/tree/main/src/cpp
#FROM mcr.microsoft.com/devcontainers/cpp:debian-12

# +-----------------------------+
# | METADATA                    |
# +-----------------------------+

LABEL maintainer="Jens A. Koch <jakoch@web.de>"

# +-----------------------------+
# | ARGS                        |
# +-----------------------------+

ARG LLVM_VERSION=17

# +-----------------------------+
# | ENV                         |
# +-----------------------------+

ENV DEBIAN_FRONTEND=noninteractive

# +-----------------------------+
# | PRE-REQUISITE/INIT PACKAGES |
# +-----------------------------+

# avoid debconf delaying package configuration, since apt-utils is not installed
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils dialog 2>&1

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
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
RUN add-apt-repository "deb http://apt.llvm.org/bookworm/ llvm-toolchain main" && \
    add-apt-repository "deb http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-${LLVM_VERSION} main"
RUN apt-get update && \
    apt-get install -y \
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

RUN echo $TZ > /etc/timezone && \
    dpkg-reconfigure tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="de_DE.UTF-8"' > /etc/default/locale && \
    dpkg-reconfigure locales && \
    update-locale LANG=de_DE.UTF-8

ENV LANG=de_DE.UTF-8
ENV LC_ALL=de_DE.UTF-8

RUN echo "export PATH=$PATH" > /etc/environment

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog
