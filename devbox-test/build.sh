#!/bin/bash

set -eou pipefail

# Detect Debian codename
source /etc/os-release
case "$VERSION_CODENAME" in
  bookworm)
    CLANG_VERSION=20
    GCC_VERSION=14
    ;;
  trixie)
    CLANG_VERSION=21
    GCC_VERSION=14
    ;;
  *)
    echo -e "\e[33m ⚠ Unknown Debian release ($VERSION_CODENAME). Defaulting to clang++-21 & g++-14.\e[0m"
    CLANG_VERSION=21
    GCC_VERSION=14
    ;;
esac

# Test that specific compiler versions exist
if ! /usr/bin/clang++-"$CLANG_VERSION" --version &>/dev/null; then
  echo -e "\e[31m ❌ Clang++$CLANG_VERSION not found!\e[0m"
  exit 1
fi

if ! /usr/bin/g++-"$GCC_VERSION" --version &>/dev/null; then
  echo -e "\e[31m ❌ G++$GCC_VERSION not found!\e[0m"
  exit 1
fi

echo -e "\e[33m== Building devbox-test ==\e[0m"

# create and switch to build dir (Build Tree)
mkdir -p build-gcc build-clang

echo -e "\e[33m== Build with GCC $GCC_VERSION ==\e[0m"

cd build-gcc
# configure
cmake -S .. -DCMAKE_CXX_COMPILER=/usr/bin/g++-"$GCC_VERSION"
# verify configuration
#cmake -LAH ..
# build
cmake --build .
# test
# test
if ctest; then
    echo -e "\e[32m ✅ [GCC] Build and tests completed successfully!\e[0m"
else
    echo -e "\e[31m ❌ Tests failed!\e[0m"
    exit 1
fi
cd ..

echo -e "\e[33m== Build with Clang $CLANG_VERSION ==\e[0m"

cd build-clang
cmake -S .. -DCMAKE_CXX_COMPILER=/usr/bin/clang++-"$CLANG_VERSION"
cmake --build .
# test
if ctest; then
    echo -e "\e[32m ✅ [CLANG] Build and tests completed successfully!\e[0m"
else
    echo -e "\e[31m ❌ Tests failed!\e[0m"
    exit 1
fi
cd ..


