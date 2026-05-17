#!/usr/bin/env bash
set -euo pipefail

GCC16_VERSION=16.1.0

# Compile GCC with the distro GCC (not Clang)
export CC=/usr/bin/gcc-14
export CXX=/usr/bin/g++-14
TARBALL="gcc16.xz"

# Download
if [ ! -f "$TARBALL" ]; then
  echo "Downloading GCC $GCC16_VERSION ..."
  curl --silent --show-error --location --retry 5 --retry-all-errors --retry-delay 3 --retry-max-time 30 --fail \
    -o "$TARBALL" \
    "http://ftp.gnu.org/gnu/gcc/gcc-${GCC16_VERSION}/gcc-${GCC16_VERSION}.tar.xz"
fi

echo "Setup required packages..."
apt-get update && apt-get install --no-install-recommends --assume-yes \
  libmpfr-dev libgmp3-dev libmpc-dev \
  gawk m4 flex bison texinfo libisl-dev

echo "Extracting GCC $GCC16_VERSION ..."
tar xf "$TARBALL" && rm "$TARBALL"

cd "gcc-${GCC16_VERSION}"

echo "Configuring GCC $GCC16_VERSION ..."
./configure \
  --libdir=/usr/lib \
  --libexecdir=/usr/lib \
  --prefix=/usr \
  --program-suffix=-16 \
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
  --with-system-zlib

echo "Building GCC $GCC16_VERSION ..."
make -j"$(nproc)" all-gcc

echo "Building libgcc ..."
make -j"$(nproc)" all-target-libgcc

# This libatomic must be built before libsanitizer, which depends on it via libgomp.
echo "Building libatomic..."
make -j"$(nproc)" all-target-libatomic

# libatomic installs to $builddir/gcc/
# but xgcc's -B points to $builddir/host-x86_64-linux-gnu/gcc/
# We need to copy libatomic artifacts
# so xgcc can link test programs during configure of other targets
GCC_BUILD_DIR="gcc-${GCC16_VERSION}"
HOST_GCC_DIR="${GCC_BUILD_DIR}/host-x86_64-linux-gnu/gcc"
if [ -d "${GCC_BUILD_DIR}/gcc" ] && [ -d "${HOST_GCC_DIR}" ]; then
  for f in "${GCC_BUILD_DIR}"/gcc/libatomic*; do
    [ -f "$f" ] && cp -a "$f" "${HOST_GCC_DIR}/"
  done
fi

echo "Building libsanitizer ..."
make -j"$(nproc)" all-target-libsanitizer

echo "Installing GCC $GCC16_VERSION ..."
make install-gcc
make install-target-libgcc
make install-target-libsanitizer
make install-target-libatomic

cd /
rm -rf "gcc-${GCC16_VERSION}"

echo "Cleaning up packages ..."
apt-get autoremove -y \
  libmpfr-dev libgmp3-dev libmpc-dev \
  gawk m4 flex bison texinfo libisl-dev

apt-get clean autoclean
rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

echo "GCC $GCC16_VERSION build completed successfully."
gcc-16 --version
g++-16 --version

echo "Done."
