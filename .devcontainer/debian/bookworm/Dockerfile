# SPDX-FileCopyrightText: 2023,2024 Jens A. Koch
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

#
#
#   .d8888b.                        8888888b.                    888888b.
#  d88P  Y88b                       888  "Y88b                   888  "88b
#  888    888                       888    888                   888  .88P
#  888          888     888         888    888  .d88b.  888  888 8888888K.   .d88b.  888  888
#  888        8888888 8888888       888    888 d8P  Y8b 888  888 888  "Y88b d88""88b `Y8bd8P'
#  888    888   888     888         888    888 88888888 Y88  88P 888    888 888  888   X88K
#  Y88b  d88P                       888  .d88P Y8b.      Y8bd8P  888   d88P Y88..88P .d8""8b.
#   "Y8888P"                        8888888P"   "Y8888    Y88P   8888888P"   "Y88P"  888  888
#
#

# Debian Bookworm
#
# Package Versions
#
# LLVM:   https://packages.debian.org/bookworm/llvm                 14.0
# GCC:    https://packages.debian.org/bookworm/gcc                  12.2.0
# Vulkan: https://packages.debian.org/bookworm/libvulkan-dev        1.3.239.0
# MESA:   https://packages.debian.org/bookworm/mesa-vulkan-drivers  22.3.6

# +-----------------------------+
# | GLOBAL ARGS                 |
# +-----------------------------+
# The following global args need to be redeclared without a value inside each FROM section.
# For example, VULKAN_VERSION is used in the FROM sections of "downloader" and "cpp-devbox-with-vulkansdk".
ARG DEBIAN_VERSION=12
ARG DEBIAN_VERSION_NAME=bookworm
ARG GCC_VERSION=13
ARG LLVM_VERSION=19
ARG VULKAN_VERSION=1.3.296.0

# +-----------------------------+
# | Downloader                  |
# +-----------------------------+
# Download Stage is for caching:
# - /tmp/gcc.xz
# - /tmp/vulkansdk.xz

FROM debian:bookworm-slim AS downloader

# Reuse global arguments
ARG VULKAN_VERSION
ARG IKOS_VERSION=3.4

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NOWARNINGS="yes" \
    CURL_OPTIONS="--silent --show-error --retry 5 --location"

WORKDIR /tmp
RUN echo "Download Stage" && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
    ca-certificates curl jq && \
    curl $CURL_OPTIONS -o ikos.xz "https://github.com/NASA-SW-VnV/ikos/archive/refs/tags/v${IKOS_VERSION}.tar.gz" && \
    curl $CURL_OPTIONS -o gcc.xz "http://ftp.gnu.org/gnu/gcc/gcc-13.3.0/gcc-13.3.0.tar.xz" && \
    curl $CURL_OPTIONS -o vulkansdk.xz "https://sdk.lunarg.com/sdk/download/${VULKAN_VERSION}/linux/vulkansdk-linux-x86_64-${VULKAN_VERSION}.tar.xz" && \
	# Cleanup
	apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* && \
    # List downloaded files
    ls -la /tmp

# +-----------------------------+
# | IKOS Build Stage            |
# +-----------------------------+
## https://github.com/NASA-SW-VnV/ikos?tab=readme-ov-file#dependencies

# Well... IKOS is a bit of a pain to build.
# It requires LLVM 14, which is not available in the Debian 12 "bookworm" repositories.
# https://apt.llvm.org/buster/pool/main/l/   (7-19, snapshot)
# https://apt.llvm.org/bullseye/pool/main/l/ (11-19, snapshot)
# https://apt.llvm.org/bookworm/pool/main/l/ (15-19, snapshot) <- not available
# https://apt.llvm.org/unstable/pool/main/l/ (all versions)
# So we take a trixie/unstable slim image and install LLVM 14.

FROM debian:trixie-slim AS ikos-builder

ARG DEBIAN_VERSION=13
ARG DEBIAN_VERSION_NAME=trixie
ARG LLVM_VERSION=14

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NOWARNINGS="yes" \
    CURL_OPTIONS="--silent --show-error --retry 5 --location"

RUN echo "Packages" && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
        curl jq tar xz-utils sed perl \
        gcc g++ \
        cmake \
        make \
        libgmp-dev \
        libboost-dev libboost-filesystem-dev libboost-thread-dev libboost-test-dev \
        libsqlite3-dev \
        libtbb-dev \
        libz-dev \
        libzstd-dev \
        libedit-dev \
        libmpfr-dev \
        libppl-dev \
        libgmp-dev \
        python3 python3-pip python3-setuptools python3-wheel python3-build && \
    echo "Cleanup" && \
    apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "LLVM 14" && \
    if [ "$DEBIAN_VERSION_NAME" == "trixie" ]; then DEBIAN_VERSION_NAME="unstable"; fi && \
    if [ "$DEBIAN_VERSION_NAME" == "unstable" ]; then LINKNAME=""; else LINKNAME="-$DEBIAN_VERSION_NAME"; fi && \
    curl -s https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    echo "deb http://apt.llvm.org/$DEBIAN_VERSION_NAME/ llvm-toolchain$LINKNAME-$LLVM_VERSION main" >> /etc/apt/sources.list.d/llvm.list && \
    echo "deb http://httpredir.debian.org/debian sid main" >> /etc/apt/sources.list.d/sid.list && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
        llvm-14 llvm-14-dev llvm-14-tools clang-14 && \
    echo "Cleanup" && \
    apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# +-----------------------------+
# | APRON                       |
# +-----------------------------+
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "APRON" && \
    cd tmp && \
    # Download - Latest Version
    version="$(curl -s https://api.github.com/repos/antoinemine/apron/releases/latest | jq -r '.tag_name')"; echo "Latest Version: \"$version\"" && \
    url="https://github.com/antoinemine/apron/archive/refs/tags/$version.tar.gz"; echo "Download URL: \"$url\"" && \
    curl $CURL_OPTIONS -o apron.xz -O $url && \
    # Extract
    tar xzf apron.xz && \
    mv apron-* apron && \
    # Build
    cd apron && \
    ./configure && \
    make -j4 && \
    make install && \
    # Cleanup
    rm -rf /tmp/*

COPY --from=downloader /tmp/ikos.xz /tmp/ikos.xz

RUN echo "IKOS" && \
    echo "Extract" && \
    cd /tmp && \
    tar zxf ikos.xz && \
    # remove version from folder name
    mv ikos-* ikos && \
    cd /tmp/ikos && \
    echo "Build" && \
    mkdir build && cd build && \
    cmake \
    -DCMAKE_INSTALL_PREFIX="/opt/ikos" \
    -DCMAKE_BUILD_TYPE="Debug" \
    -DLLVM_CONFIG_EXECUTABLE="/usr/lib/llvm-$LLVM_VERSION/bin/llvm-config" \
    -DMPFR_ROOT=/usr \
    -DPPL_ROOT=/usr \
    -DAPRON_ROOT=/usr/local \
    -DINSTALL_PYTHON_VIRTUALENV=off \
    -DPYTHON_VENV_EXECUTABLE=/usr/bin/python3 \
    .. && \
    make -j4 && \
    make install && \
	echo "Build Python Module" && \
    cd /tmp/ikos/build && \
    python3 -m build --no-isolation --outdir "/opt/ikos/dist/" --wheel "analyzer/python" && \
    find /opt/ikos/dist -name "*.whl" -exec ls -la {} + && \
	echo "Install Python Module" && \
    python3 -m pip install --no-cache-dir "/opt/ikos/dist/ikos-3.4-py3-none-any.whl" --target "/opt/ikos/python-module" && \
    export PYTHONPATH="/opt/ikos/python-module" && \
    echo "Test" && \
    #ls -lahr /opt/ikos/bin && \
    /opt/ikos/bin/ikos --version && \
    echo "Cleanup" && \
    apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# +-----------------------------+
# | BASE IMAGE                  |        See https://hub.docker.com/_/debian
# +-----------------------------+

FROM debian:bookworm-slim AS cpp-devbox-base

# +-----------------------------+
# | REUSE GLOBAL ARGS           |
# +-----------------------------+

ARG DEBIAN_VERSION
ARG DEBIAN_VERSION_NAME
ARG GCC_VERSION
ARG LLVM_VERSION

# +-----------------------------+
# | METADATA                    |
# +-----------------------------+
# Standardized Docker Image Labels
# https://github.com/opencontainers/image-spec/blob/main/annotations.md

LABEL \
    maintainer="Jens A. Koch <jakoch@web.de>" \
    org.opencontainers.image.created="$(date --utc --iso-8601=seconds)" \
    org.opencontainers.image.authors='Jens A. Koch <jakoch@web.de>' \
    org.opencontainers.image.url='https://ghcr.io/jakoch/cpp-devbox' \
    org.opencontainers.image.source='https://github.com/jakoch/cpp-devbox'\
    org.opencontainers.image.title='ghcr.io/jakoch/cpp-devbox'\
    org.opencontainers.image.description="C++ DevBox (Debian ${DEBIAN_VERSION}-${DEBIAN_VERSION_NAME} with LLVM ${LLVM_VERSION%%.*} & GCC ${GCC_VERSION%%.*}, CMake, VCPKG, zsh)" \
    org.opencontainers.image.licenses=MIT


#
#  8888888b.                    888
#  888   Y88b                   888
#  888    888                   888
#  888   d88P  8888b.   .d8888b 888  888  8888b.   .d88b.   .d88b.  .d8888b
#  8888888P"      "88b d88P"    888 .88P     "88b d88P"88b d8P  Y8b 88K
#  888        .d888888 888      888888K  .d888888 888  888 88888888 "Y8888b.
#  888        888  888 Y88b.    888 "88b 888  888 Y88b 888 Y8b.          X88
#  888        "Y888888  "Y8888P 888  888 "Y888888  "Y88888  "Y8888   88888P'
#                                                      888
#                                                 Y8b d88P
#                                                  "Y88P"

ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NOWARNINGS="yes" \
    CURL_OPTIONS="--silent --show-error --retry 5 --location"

RUN echo "Packages" && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
    gnupg2 ca-certificates software-properties-common \
    build-essential \
    wget git nano jq \
    # code analysis
    cppcheck \
    valgrind \
    # profiling
    # gprof (is part of binutils and already installed)
    linux-perf \
    # code coverage (gcov is part of GCC)
    gcovr lcov \
    # tracing
    strace ltrace \
    # asm
    nasm fasm \
    # build tools
    meson \
    # required by Visual Studio
    g++ gdb make ninja-build rsync zip sudo \
    # required by VCPKG + optional downloader
    openssh-server tar curl unzip pkg-config bash-completion aria2 \
    # required by LLVM
    lsb-release zlib1g-dev \
    # locale
    locales \
    # shell
    zsh \
    # optional tools for Doxygen: Sphinx + Graphviz
    python3 python3-pip \
    python3-sphinx python3-sphinx-rtd-theme python3-defusedxml sphinx-common \
    graphviz && \
	# Cleanup
	apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
#   .d8888b.  d8b 888    888               888             .d8888b.  888      8888888
#  d88P  Y88b Y8P 888    888               888            d88P  Y88b 888        888
#  888    888     888    888               888            888    888 888        888
#  888        888 888888 88888b.  888  888 88888b.        888        888        888
#  888  88888 888 888    888 "88b 888  888 888 "88b       888        888        888
#  888    888 888 888    888  888 888  888 888  888       888    888 888        888
#  Y88b  d88P 888 Y88b.  888  888 Y88b 888 888 d88P       Y88b  d88P 888        888
#   "Y8888P88 888  "Y888 888  888  "Y88888 88888P"         "Y8888P"  88888888 8888888
#

# Website: https://cli.github.com/
# Installation Instructions: https://github.com/cli/cli/blob/trunk/docs/install_linux.md#official-sources

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "GITHUB CLI" && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
    gh && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
#   .d8888b.  888b     d888          888
#  d88P  Y88b 8888b   d8888          888
#  888    888 88888b.d88888          888
#  888        888Y88888P888  8888b.  888  888  .d88b.
#  888        888 Y888P 888     "88b 888 .88P d8P  Y8b
#  888    888 888  Y8P  888 .d888888 888888K  88888888
#  Y88b  d88P 888   "   888 888  888 888 "88b Y8b.
#   "Y8888P"  888       888 "Y888888 888  888  "Y8888
#

# Latest Release: https://github.com/Kitware/CMake/releases/latest

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "CMake" && \
    version="$(curl -s https://api.github.com/repos/Kitware/CMake/releases/latest | jq -r '.tag_name' | cut -c 2-)"; echo "Latest Version: \"$version\"" && \
    url="https://github.com/Kitware/CMake/releases/download/v$version/cmake-$version-linux-x86_64.sh"; echo "Download URL: \"$url\"" && \
    curl $CURL_OPTIONS -O $url && \
    mkdir /opt/cmake && \
    sh cmake-$version-linux-x86_64.sh --prefix=/opt/cmake --skip-license && \
    ln -s /opt/cmake/bin/cmake /usr/bin/cmake && \
    rm -rf cmake-$version-linux-x86_64.sh

#
#  888     888  .d8888b.  8888888b.  888    d8P   .d8888b.
#  888     888 d88P  Y88b 888   Y88b 888   d8P   d88P  Y88b
#  888     888 888    888 888    888 888  d8P    888    888
#  Y88b   d88P 888        888   d88P 888d88K     888
#   Y88b d88P  888        8888888P"  8888888b    888  88888
#    Y88o88P   888    888 888        888  Y88b   888    888
#     Y888P    Y88b  d88P 888        888   Y88b  Y88b  d88P
#      Y8P      "Y8888P"  888        888    Y88b  "Y8888P88
#

# vcpkg requires curl, unzip, tar, pkg-config (optional cmake).
# We use the installed binaries from the system.
# We do not download latest version of CMake and Ninja during vcpkg bootstrap.

ENV VCPKG_ROOT=/opt/vcpkg \
    VCPKG_TRIPLET=x64-linux \
    VCPKG_FORCE_SYSTEM_BINARIES=1 \
    VCPKG_USE_SYSTEM_BINARIES=1
ENV PATH="${PATH}:${VCPKG_ROOT}"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "VCPKG" && \
    git clone --depth=1 \
    -c core.eol=lf \
    -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    https://github.com/microsoft/vcpkg "${VCPKG_ROOT}" && \
    "${VCPKG_ROOT}"/bootstrap-vcpkg.sh -disableMetrics

#
#   .d8888b.   .d8888b.         d8888  .d8888b.  888    888 8888888888
#  d88P  Y88b d88P  Y88b       d88888 d88P  Y88b 888    888 888
#  888    888 888    888      d88P888 888    888 888    888 888
#  888        888            d88P 888 888        8888888888 8888888
#  888        888           d88P  888 888        888    888 888
#  888    888 888    888   d88P   888 888    888 888    888 888
#  Y88b  d88P Y88b  d88P  d8888888888 Y88b  d88P 888    888 888
#   "Y8888P"   "Y8888P"  d88P     888  "Y8888P"  888    888 8888888888
#

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "CCACHE" && \
    version="$(curl -s https://api.github.com/repos/ccache/ccache/releases/latest | jq -r '.tag_name' | cut -c 2-)"; echo "Latest Version: \"$version\"" && \
    url="https://github.com/ccache/ccache/releases/download/v$version/ccache-$version-linux-x86_64.tar.xz"; echo "Download URL: \"$url\"" && \
    curl $CURL_OPTIONS -sLO $url && \
    mkdir -p /opt/ccache/bin &&\
    tar xf ccache-$version-linux-x86_64.tar.xz --strip-components=1 -C /opt/ccache/bin && \
	ln -s /opt/ccache/bin/ccache /usr/bin && \
	rm ccache-$version-linux-x86_64.tar.xz

#
#  8888888b.   .d88888b.  Y88b   d88P Y88b   d88P  .d8888b.  8888888888 888b    888
#  888  "Y88b d88P" "Y88b  Y88b d88P   Y88b d88P  d88P  Y88b 888        8888b   888
#  888    888 888     888   Y88o88P     Y88o88P   888    888 888        88888b  888
#  888    888 888     888    Y888P       Y888P    888        8888888    888Y88b 888
#  888    888 888     888    d888b        888     888  88888 888        888 Y88b888
#  888    888 888     888   d88888b       888     888    888 888        888  Y88888
#  888  .d88P Y88b. .d88P  d88P Y88b      888     Y88b  d88P 888        888   Y8888
#  8888888P"   "Y88888P"  d88P   Y88b     888      "Y8888P88 8888888888 888    Y888
#

# +-----------------------------+
# | Doxygen - Latest Version    |
# +-----------------------------+
# We are using the prebuilt binaries for x64.

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "DOXYGEN" && \
    version_string="$(curl -s https://api.github.com/repos/doxygen/doxygen/releases/latest | jq -r '.tag_name')"; echo "Latest Version: \"$version_string\"" && \
    version_number="$(echo $version_string | cut -c 9- | sed 's/_/./g')" && \
    url="https://github.com/doxygen/doxygen/releases/download/$version_string/doxygen-$version_number.linux.bin.tar.gz"; echo "Download URL: \"$url\"" && \
    curl $CURL_OPTIONS -O $url && \
    mkdir /opt/doxygen && \
    tar xf doxygen-$version_number.linux.bin.tar.gz --strip-components=1 -C /opt/doxygen && \
	ln -s /opt/doxygen/bin/doxygen /usr/bin && \
	rm doxygen-$version_number.linux.bin.tar.gz

#
#  8888888 888    d8P   .d88888b.   .d8888b.
#    888   888   d8P   d88P" "Y88b d88P  Y88b
#    888   888  d8P    888     888 Y88b.
#    888   888d88K     888     888  "Y888b.
#    888   8888888b    888     888     "Y88b.
#    888   888  Y88b   888     888       "888
#    888   888   Y88b  Y88b. .d88P Y88b  d88P
#  8888888 888    Y88b  "Y88888P"   "Y8888P"
#

COPY --from=ikos-builder /opt/ikos /opt/ikos

ENV PATH="/opt/ikos/bin:${PATH}" \
	PYTHONPATH="/opt/ikos/python-module"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN apt-get update && apt-get install --no-install-recommends --assume-yes \
    python3 python3-pip python3-venv python3-pygments python3-setuptools && \
    # Cleanup
    apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    # Install IKOS Python module
	python3 -m pip install --no-cache-dir "/opt/ikos/dist/ikos-3.4-py3-none-any.whl" --target "/opt/ikos/python-module"
	# Test
	#ikos --version

#
#  888      888      888     888 888b     d888
#  888      888      888     888 8888b   d8888
#  888      888      888     888 88888b.d88888
#  888      888      Y88b   d88P 888Y88888P888
#  888      888       Y88b d88P  888 Y888P 888
#  888      888        Y88o88P   888  Y8P  888
#  888      888         Y888P    888   "   888
#  88888888 88888888     Y8P     888       888
#

# +-----------------------------+
# | LLVM                        |
# +-----------------------------+
# For an installation using the llvm.sh setup script:
# RUN curl -sLO https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh ${LLVM_VERSION} all && rm ./llvm.sh

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "LLVM" && \
    curl -s https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    add-apt-repository -y "deb http://apt.llvm.org/$DEBIAN_VERSION_NAME/ llvm-toolchain-$DEBIAN_VERSION_NAME-$LLVM_VERSION main" && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
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
    libclang-rt-$LLVM_VERSION-dev \
    libclang-common-$LLVM_VERSION-dev \
    libclang-$LLVM_VERSION-dev \
    libclang-cpp$LLVM_VERSION-dev \
    libfuzzer-$LLVM_VERSION-dev \
    libunwind-$LLVM_VERSION-dev \
    libclang-rt-$LLVM_VERSION-dev \
    libpolly-$LLVM_VERSION-dev && \
	# Cleanup
	apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# add llvm to path
ENV PATH="/usr/lib/llvm-${LLVM_VERSION}/bin:/usr/lib/llvm-${LLVM_VERSION}/include:${PATH}"

# first set LD_LIBRARY_PATH (Debian doesn't set LD_LIBRARY_PATH by default.) and then add LLVM lib folder
ENV LD_LIBRARY_PATH="/usr/lib:/usr/local/lib"
ENV LD_LIBRARY_PATH="/usr/lib/llvm-${LLVM_VERSION}/lib:${LD_LIBRARY_PATH:-}"

# remove version from binaries
RUN echo "LLVM symlink binaries" && \
    ln -s /usr/bin/clang-${LLVM_VERSION} /usr/bin/clang && \
    ln -s /usr/bin/clang++-${LLVM_VERSION} /usr/bin/clang++ && \
    ln -s /usr/bin/clang-format-${LLVM_VERSION} /usr/bin/clang-format

# update compiler environment vars
ENV CC=/usr/bin/clang \
    CXX=/usr/bin/clang++

# update alternatives
RUN echo "LLVM udate-alternatives" && \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 && \
    update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

#
#  888b     d888          888      888
#  8888b   d8888          888      888
#  88888b.d88888          888      888
#  888Y88888P888  .d88b.  888  .d88888
#  888 Y888P 888 d88""88b 888 d88" 888
#  888  Y8P  888 888  888 888 888  888
#  888   "   888 Y88..88P 888 Y88b 888
#  888       888  "Y88P"  888  "Y88888
#

# We are using Clang++ for compilation, so this download + compile step must happen after installing LLVM+Clang.
# We don't need to call mold's ./install-build-deps.sh, because all build dependencies are present.
# Note to overwrite ld: sudo ln -sf /opt/mold/bin/mold $(realpath /usr/bin/ld)

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "MOLD" && \
    version="$(curl -s https://api.github.com/repos/rui314/mold/releases/latest | jq -r '.tag_name' | cut -c 2-)"; echo "Latest Version: \"$version\"" && \
    git clone --depth=1 --branch "v$version" https://github.com/rui314/mold.git "/tmp/mold" && \
    cmake -S /tmp/mold -B /tmp/mold/build -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_COMPILER=clang++ && \
    cmake --build /tmp/mold/build -j "$(nproc)" && \
    cmake --install /tmp/mold/build --prefix=/opt/mold && \
    ln -s /opt/mold/bin/mold /usr/bin && \
    rm -rf /tmp/mold

#
#   .d8888b.   .d8888b.   .d8888b.
#  d88P  Y88b d88P  Y88b d88P  Y88b
#  888    888 888    888 888    888
#  888        888        888
#  888  88888 888        888
#  888    888 888    888 888    888
#  Y88b  d88P Y88b  d88P Y88b  d88P
#   "Y8888P88  "Y8888P"   "Y8888P"
#

# +-----------------------------+
# | GCC                         |
# +-----------------------------+

COPY --from=downloader /tmp/gcc.xz /tmp/gcc.xz
RUN echo "GCC - Extract" && \
    tar xf /tmp/gcc.xz && rm /tmp/gcc.xz && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
    libmpfr-dev libgmp3-dev libmpc-dev

# set default compiler to gcc
ENV CC=/usr/bin/gcc \
    CXX=/usr/bin/g++

# installing into /usr instead of /usr/local to have consistent paths in CMakePresets:
# /usr/bin/g++-12
# /usr/bin/g++-13
WORKDIR /gcc-13.3.0

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# https://gcc.gnu.org/install/configure.html
RUN echo "GCC - Compile" && \
    ./configure \
    --libdir=/usr/lib \
    --libexecdir=/usr/lib \
    --prefix=/usr \
    --program-suffix=-13 \
    --build=x86_64-linux-gnu \
    --host=x86_64-linux-gnu \
    --target=x86_64-linux-gnu \
    --disable-multilib \
    --disable-libquadmath \
    --disable-vtable-verify \
    --disable-werror \
    --enable-cet \
    --enable-lto \
    --enable-checking=release \
    --enable-clocale=gnu \
    --enable-default-pie \
    --enable-gnu-unique-object \
    --enable-languages=c,c++ \
    --enable-libstdcxx-debug \
    --enable-libstdcxx-time=yes \
    --enable-linker-build-id \
    --enable-nls \
    --enable-multiarch \
    --enable-plugin \
    --enable-shared \
    --enable-shared-libgcc \
    --enable-static \
    --enable-threads=posix \
    --enable-libsanitizer \
    --without-included-gettext \
    --without-cuda-driver \
    --with-arch-32=i686 \
    --with-abi=m64 \
    --with-tune=generic \
    --with-default-libstdcxx-abi=new \
    --with-gcc-major-version-only \
    --with-system-zlib && \
    make -s -j"$(nproc)" all-gcc > /dev/null 2>&1 && \
    make -s -j"$(nproc)" all-target-libgcc > /dev/null 2>&1 && \
    make -s -j"$(nproc)" all-target-libsanitizer > /dev/null 2>&1 && \
    make -s -j"$(nproc)" all-target-libatomic > /dev/null 2>&1 && \
    make install-gcc && \
    make install-target-libgcc && \
    make install-target-libsanitizer && \
    make install-target-libatomic

# return from /gcc-x.y.z folder
WORKDIR /

# remove gcc source folder and dependencies
RUN echo "GCC - Cleanup" && \
    rm -rf gcc-13.3.0 && \
    # Cleanup
    apt-get autoremove -y libmpfr-dev libgmp3-dev libmpc-dev && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# reset default compiler to clang
ENV CC=/usr/bin/clang \
    CXX=/usr/bin/clang++

#
#  8888888888P  .d8888b.  888    888
#        d88P  d88P  Y88b 888    888
#       d88P   Y88b.      888    888
#      d88P     "Y888b.   8888888888
#     d88P         "Y88b. 888    888
#    d88P            "888 888    888
#   d88P       Y88b  d88P 888    888
#  d8888888888  "Y8888P"  888    888
#

# +-----------------------------+
# | ZSH                         |
# +-----------------------------+
# Setup zsh, ohmyzsh, powerline fonts.
# Setup zsh plugins: autosuggestions, autocompletions, history search.

ENV TERM=xterm-256color \
    ZSH_THEME=agnoster

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN echo "ZSH" && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
    # Install fonts-powerline
    fontconfig fonts-powerline && \
    # Install Oh My Zsh
    curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh && \
    # Add Zsh plugins
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-completions && \
    git clone --depth=1 https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search && \
    # Update .zshrc
    sed -i "s/plugins=(git)/plugins=(git zsh-completions zsh-autosuggestions zsh-history-substring-search)/" /root/.zshrc && \
    sed -i "s/ZSH_THEME=\"agnoster\"/ZSH_THEME=\"robbyrussell\"/" /root/.zshrc  && \
	# Cleanup
	apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the default shell to zsh after it is installed
ENV SHELL=/bin/zsh

# +-----------------------------+
# | CLEANUP                     |
# +-----------------------------+

RUN echo "CLeanup" && \
    apt-get autoremove -y && \
    apt-get clean autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# +-----------------------------+
# | Set Locale + Timezone       |
# +-----------------------------+

ENV TZ=Europe/Berlin

# configure german locale
RUN echo "Locale & Timezone" && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    dpkg-reconfigure tzdata && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    sed -i -e 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="de_DE.UTF-8"' > /etc/default/locale && \
    dpkg-reconfigure locales && \
    update-locale LANG=de_DE.UTF-8 && \
    echo "export PATH=$PATH" > /etc/environment

#RUN localedef -i de_DE -c -f UTF-8 -A /usr/share/locale/locale.alias de_DE.UTF-8 \
#    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
# ENV LANG=de_DE.UTF-8 LC_ALL=de_DE.UTF-8

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# +----------------------------------+
# | Stage: cpp-devbox-with-vulkansdk |
# +----------------------------------+

FROM cpp-devbox-base AS cpp-devbox-with-vulkansdk

# Reuse global arguments
ARG DEBIAN_VERSION
ARG DEBIAN_VERSION_NAME
ARG LLVM_VERSION
ARG GCC_VERSION
ARG VULKAN_VERSION
ARG MESA_VERSION

# +-----------------------------+
# | METADATA                    |
# +-----------------------------+
# Standardized Docker Image Labels
# https://github.com/opencontainers/image-spec/blob/main/annotations.md

LABEL \
    maintainer="Jens A. Koch <jakoch@web.de>" \
    org.opencontainers.image.created="$(date --utc --iso-8601=seconds)" \
    org.opencontainers.image.authors='Jens A. Koch <jakoch@web.de>' \
    org.opencontainers.image.url='https://ghcr.io/jakoch/cpp-devbox' \
    org.opencontainers.image.source='https://github.com/jakoch/cpp-devbox'\
    org.opencontainers.image.title='ghcr.io/jakoch/cpp-devbox'\
    org.opencontainers.image.description="C++ DevBox (Debian ${DEBIAN_VERSION}-${DEBIAN_VERSION_NAME} with LLVM ${LLVM_VERSION%%.*} & GCC ${GCC_VERSION%%.*}, VulkanSDK ${VULKAN_VERSION%%.*}, Mesa ${MESA_VERSION%%.*}, CMake, VCPKG, zsh)" \
    org.opencontainers.image.licenses=MIT

#
#  888     888          888 888                               .d8888b.  8888888b.  888    d8P
#  888     888          888 888                              d88P  Y88b 888  "Y88b 888   d8P
#  888     888          888 888                              Y88b.      888    888 888  d8P
#  Y88b   d88P 888  888 888 888  888  8888b.  88888b.         "Y888b.   888    888 888d88K
#   Y88b d88P  888  888 888 888 .88P     "88b 888 "88b           "Y88b. 888    888 8888888b
#    Y88o88P   888  888 888 888888K  .d888888 888  888             "888 888    888 888  Y88b
#     Y888P    Y88b 888 888 888 "88b 888  888 888  888       Y88b  d88P 888  .d88P 888   Y88b
#      Y8P      "Y88888 888 888  888 "Y888888 888  888        "Y8888P"  8888888P"  888    Y88b
#

# +-----------------------------+
# | Vulkan SDK                  |
# +-----------------------------+

COPY --from=downloader /tmp/vulkansdk.xz /tmp/vulkansdk.xz

RUN mkdir -p /opt/vulkan && \
    tar xf /tmp/vulkansdk.xz -C /opt/vulkan && \
    rm /tmp/vulkansdk.xz

# Note: do not combine the 2 ENV statements.
# (do not refer to env var within the same statement where it is defined)
ENV VULKAN_SDK=/opt/vulkan/${VULKAN_VERSION}/x86_64
ENV PATH="$VULKAN_SDK/bin:$PATH" \
    LD_LIBRARY_PATH="$VULKAN_SDK/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}" \
    VK_LAYER_PATH="$VULKAN_SDK/etc/vulkan/explicit_layer.d"

# +-----------------------------+
# | Mesa                        |
# +-----------------------------+

# Mesa's software Vulkan implementation is called lavapipe (libvulkan_lvp).
#
# To setup Vulkan to use the CPU for rendering, you need to set the env var
# VK_ICD_FILENAMES to point to the software renderer.
# That JSON file points to the location of the driver (libvulkan_lvp.so).
#
# To test CPU rendering using the Mesa Vulkan drivers, you can use "vkcube",
# which is a simple spinning-cube app to demonstrate Vulkan functionality.
#
RUN echo "Mesa" && \
    apt-get update && apt-get install --no-install-recommends --assume-yes \
      libgl1-mesa-dri \
      mesa-vulkan-drivers && \
      # Cleanup
      apt-get autoremove -y && \
      apt-get clean autoclean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

#
# https://docs.mesa3d.org/envvars.html
# LIBGL_ALWAYS_SOFTWARE 1 = use software rendering
ENV VK_ICD_FILENAMES=/usr/share/vulkan/icd.d/lvp_icd.x86_64.json \
    LIBGL_ALWAYS_SOFTWARE=1

# The AsciiArt for the VSCode minimap is generated using
# shellcheck disable=SC2046
# https://patorjk.com/software/taag/#p=display&h=0&v=0&c=bash&f=Colossal&t=C%2B%2B%20DevBox%0APackages%0AGithub%20CLI%0ACMake%0ADOXYGEN%0AVCPKG%0ACCACHE%0ALLVM%0AGCC%0AZSH%0AVulkan%20SDK
