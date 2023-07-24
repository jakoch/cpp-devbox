#!/bin/sh

# This info script shows the version of tools, compilers and libc.

echo "\033[31mGit Version\033[0m"

git --version

echo "\033[31mNinja Version\033[0m"

ninja --version

echo "\033[31mCMake Version\033[0m"

cmake --version | head -n1

echo "\033[31mGCC Version\033[0m"

gcc --version | head -n1

echo "\033[31mClang Version\033[0m"

clang --version

echo "\033[31mlldb Version\033[0m"

lldb --version

echo "\033[31mValgrind Version\033[0m"

valgrind --version

echo "\033[31mlibc Version\033[0m"

ldd --version | head -n1
ldd `which cat` | grep libc | awk '{printf ("%s %s %s %s\n", $1, $2, $3, $4)}'
ldd --verbose /lib/x86_64-linux-gnu/libc.so.6 | grep -E '=>|GLIBC_' | awk '{printf ("%s\t%s\n", $2, $1)}'
#gcc --print-file-name=libc.a
#gcc --print-file-name=libc.so

echo "\033[31mVCPKG Version\033[0m"

vcpkg --version | head -n1

