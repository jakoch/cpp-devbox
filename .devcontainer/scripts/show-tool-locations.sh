#!/bin/sh

# Copyright Jens A. Koch 2023.
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

# This info script shows the locations of tools, compilers and libc.

echo "\033[31mGit\033[0m"

type -a git

echo "\033[31mNinja\033[0m"

type -a ninja

echo "\033[31mCMake\033[0m"

type -a cmake

echo "\033[31mGCC\033[0m"

type -a gcc

echo "\033[31mClang\033[0m"

type -a clang

echo "\033[31mlldb Version\033[0m"

type -a lldb

echo "\033[31mValgrind Version\033[0m"

type -a valgrind

echo "\033[31mlibc Version\033[0m"

ldd --version | head -n1
ldd `which cat` | grep libc | awk '{printf ("%s %s %s %s\n", $1, $2, $3, $4)}'
ldd --verbose /lib/x86_64-linux-gnu/libc.so.6 | grep -E '=>|GLIBC_' | awk '{printf ("%s\t%s\n", $2, $1)}'

echo "\033[31mVCPKG\033[0m"

type -a vcpkg

echo "\033[31mcppcheck\033[0m"

type -a cppcheck

echo "\033[31mccache\033[0m"

type -a ccache | head -n1

echo "\033[31mVulkan-SDK Version\033[0m"

echo $VULKAN_SDK

echo "\033[31mPath\033[0m"

echo $PATH
