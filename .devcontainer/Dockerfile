# +-----------------------------+
# | Downloader                  |
# +-----------------------------+

FROM debian:bookworm-slim as downloader

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates curl
#ENV CURL_OPTIONS "--silent --show-error --retry 5 --connect-timeout 20 --max-time 10"
ENV CURL_OPTIONS_BAR "--progress-bar"
WORKDIR /tmp
RUN curl $CURL_OPTIONS_BAR -o gcc.xz "http://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz"
RUN curl $CURL_OPTIONS_BAR -o vulkansdk.xz "https://sdk.lunarg.com/sdk/download/1.3.261.1/linux/vulkansdk-linux-x86_64-1.3.261.1.tar.xz"

# +-----------------------------+
# | BASE IMAGE                  |        See https://hub.docker.com/_/debian
# +-----------------------------+

FROM debian:bookworm-slim as cpp-devbox-base

# +-----------------------------+
# | ARGS                        |
# +-----------------------------+

ARG DEBIAN_VERSION=12
ARG DEBIAN_VERSION_NAME=bookworm
ARG GCC_VERSION=13
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
    org.opencontainers.image.description="C++ DevBox (Debian ${DEBIAN_VERSION}-${DEBIAN_VERSION_NAME} with LLVM ${LLVM_VERSION} & GCC ${GCC_VERSION}, CMake, VCPKG, zsh)" \
    org.opencontainers.image.licenses=MIT

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

# +-----------------------------+
# | LLVM                        |
# +-----------------------------+

# llvm.sh is constantly broken, see https://github.com/llvm/llvm-project/issues/62475
#RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh ${LLVM_VERSION} all && rm ./llvm.sh

RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc && \
    add-apt-repository -y "deb http://apt.llvm.org/$DEBIAN_VERSION_NAME/ llvm-toolchain main" && \
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
    libfuzzer-$LLVM_VERSION-dev \
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
# | GCC                         |
# +-----------------------------+

RUN apt-get install -y --no-install-recommends libmpfr-dev libgmp3-dev libmpc-dev

COPY --from=downloader /tmp/gcc.xz /tmp/gcc.xz
RUN tar xf /tmp/gcc.xz && rm /tmp/gcc.xz

# installing into /usr instead of /usr/local to have consistent paths in CMakePresets:
# /usr/bin/g++-12
# /usr/bin/g++-13
WORKDIR /gcc-13.2.0
RUN ./configure -v \
    --prefix=/usr \
    --program-suffix=-13 \
    --build=x86_64-linux-gnu \
    --host=x86_64-linux-gnu \
    --target=x86_64-linux-gnu \
    --disable-multilib \
    --enable-cet \
    --enable-checking=release \
    --enable-clocale=gnu \
    --enable-default-pie \
    --enable-gnu-unique-object \
    --enable-languages=c,c++ \
    --enable-libstdcxx-debug \
    --enable-libstdcxx-time=yes \
    --enable-linker-build-id \
    --enable-plugin \
    --enable-shared \
    --enable-threads=posix \
    --with-default-libstdcxx-abi=new \
    --with-gcc-major-version-only \
    --with-system-zlib > /dev/null 2>&1 && \
    make -s -j$(nproc) > /dev/null 2>&1 && \
    make install

 RUN rm -rf /gcc-13.2.0 && \
    apt-get autoremove -y libmpfr-dev libgmp3-dev libmpc-dev

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
    update-locale LANG=de_DE.UTF-8 && \
    echo "export PATH=$PATH" > /etc/environment

#ENV LANG=de_DE.UTF-8
#ENV LC_ALL=de_DE.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# +----------------------------------+
# | Stage: cpp-devbox-with-vulkansdk |
# +----------------------------------+

FROM cpp-devbox-base as cpp-devbox-with-vulkansdk

ENV VULKAN_SDK_VERSION=1.3.261.1

# +-----------------------------+
# | METADATA                    |
# +-----------------------------+

LABEL \
    maintainer="Jens A. Koch <jakoch@web.de>" \
    org.opencontainers.image.authors='Jens A. Koch <jakoch@web.de>' \
    org.opencontainers.image.url='https://github.com/jakoch/cpp-devbox/tree/main' \
    org.opencontainers.image.source='https://github.com/jakoch/cpp-devbox'\
    org.opencontainers.image.title='ghcr.io/jakoch/cpp-devbox'\
    org.opencontainers.image.description="C++ DevBox (Debian ${DEBIAN_VERSION}-${DEBIAN_VERSION_NAME} with LLVM ${LLVM_VERSION} & GCC ${GCC_VERSION}, VulkanSDK ${VULKAN_SDK_VERSION}, CMake, VCPKG, zsh)" \
    org.opencontainers.image.licenses=MIT

# +-----------------------------+
# | Vulkan SDK                  |
# +-----------------------------+

COPY --from=downloader /tmp/vulkansdk.xz /tmp/vulkansdk.xz

RUN mkdir -p /opt/vulkan && \
    tar xf /tmp/vulkansdk.xz -C /opt/vulkan && \
    rm /tmp/vulkansdk.xz

ENV VULKAN_SDK=/opt/vulkan/${VULKAN_SDK_VERSION}/x86_64 \
    PATH="$VULKAN_SDK/bin:$PATH" \
    LD_LIBRARY_PATH="$VULKAN_SDK/lib:${LD_LIBRARY_PATH:-}" \
    VK_LAYER_PATH="$VULKAN_SDK/etc/vulkan/explicit_layer.d"
