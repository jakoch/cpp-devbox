#!/bin/bash

set -eou pipefail

# test that specific compiler versions exists
if ! /usr/bin/clang++-20 --version &>/dev/null; then
  echo -e "\e[31m ❌ Clang++20 not found!\e[0m"
  exit 1
fi

if ! /usr/bin/g++-14 --version &>/dev/null; then
  echo -e "\e[31m ❌ G++14 not found!\e[0m"
  exit 1
fi

echo -e "\e[33m== Building devbox-test ==\e[0m"

# create and switch to build dir (Build Tree)
mkdir -p build-gcc build-clang

echo -e "\e[33m== Build with GCC 14 ==\e[0m"

cd build-gcc
# configure
cmake -S .. -DCMAKE_CXX_COMPILER=/usr/bin/g++-14
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

echo -e "\e[33m== Build with Clang 20 ==\e[0m"

cd build-clang
cmake -S .. -DCMAKE_CXX_COMPILER=/usr/bin/clang++-20
cmake --build .
# test
if ctest; then
    echo -e "\e[32m ✅ [CLANG] Build and tests completed successfully!\e[0m"
else
    echo -e "\e[31m ❌ Tests failed!\e[0m"
    exit 1
fi
cd ..


