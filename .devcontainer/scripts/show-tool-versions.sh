#!/bin/sh

# Copyright Jens A. Koch 2023.
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

# This info script shows the version of tools, compilers and libc.

echo "\033[31mGit Version\033[0m"

git --version

echo "\033[31mNinja Version\033[0m"

ninja --version

echo "\033[31mCMake Version\033[0m"

cmake --version | head -n1

echo "\033[31mGCC Version\033[0m"

gcc --version | head -n1
command -v /usr/bin/g++-12 && /usr/bin/g++-12 --version | head -n1 || echo "g++-12 not found"
command -v /usr/bin/g++-13 && /usr/bin/g++-13 --version | head -n1 || echo "g++-13 not found"

echo "\033[31mClang Version\033[0m"

clang --version

echo "\033[31mMold Version\033[0m"

mold --version

echo "\033[31mlldb Version\033[0m"

lldb --version

echo "\033[31mValgrind Version\033[0m"

valgrind --version

echo "\033[31mlibc Version\033[0m"

ldd --version | head -n1
ldd `which cat` | grep libc | awk '{printf ("%s %s %s %s\n", $1, $2, $3, $4)}'
ldd --verbose /lib/x86_64-linux-gnu/libc.so.6 | grep -E '=>|GLIBC_' | awk '{printf ("%s\t%s\n", $2, $1)}'

echo "\033[31mVCPKG Version\033[0m"

vcpkg --version | head -n1

echo "\033[31mcppcheck Version\033[0m"

cppcheck --version

echo "\033[31mccache Version\033[0m"

ccache --version | head -n1

echo "\033[31mVulkan-SDK Version\033[0m"

echo $VULKAN_SDK

echo "\033[31mPath\033[0m"

echo $PATH
