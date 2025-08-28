#!/bin/sh

# SPDX-FileCopyrightText: 2023-2025 Jens A. Koch
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

# This info script shows the locations of tools, compilers and libc.
# Output format is markdown.

# Function to get all paths of a command and format them comma-separated
get_command_paths() {
    commands=$(which -a "$1" | tr '\n' ',' | sed 's/,$//' | sed 's/,/, /g' | cut -c 1-)
    if [ -n "$commands" ]; then
      echo "$commands"
    fi
}

# Function to print the libc infos
print_libc_infos() {
  r1=$(ldd `which cat` | grep libc | awk '{printf ("%s %s %s %s\n", $1, $2, $3, $4)}')
  r2=$(ldd --verbose /lib/x86_64-linux-gnu/libc.so.6 | grep -E '=>|GLIBC_' | awk '{printf ("%s\t%s\n", $2, $1)}')
  echo "$r1\n$r2"
}

# Function to print the tool locations in a table
show_tool_locations() {
  printf "\n## Locations\n"
  echo "\n### \033[31mTools\033[0m"
  get_command_paths g++-12
  get_command_paths g++-13
  get_command_paths g++-14
  get_command_paths g++-15
  get_command_paths clang++-16
  get_command_paths clang++-17
  get_command_paths clang++-18
  get_command_paths clang++-19
  get_command_paths clang++-20
  get_command_paths clang++-21
  get_command_paths cmake
  get_command_paths meson
  get_command_paths ninja
  get_command_paths ccache
  get_command_paths mold
  get_command_paths vcpkg
  get_command_paths lldb
  get_command_paths valgrind
  get_command_paths gdb
  get_command_paths clang-tidy
  get_command_paths clang-format
  get_command_paths cppcheck
  get_command_paths gprof
  get_command_paths perf
  get_command_paths strace
  get_command_paths ltrace
  get_command_paths lcov
  get_command_paths gcov
  get_command_paths gcovr
  get_command_paths nasm
  get_command_paths fasm
  get_command_paths doxygen
  get_command_paths sphinx-build
  get_command_paths git
  get_command_paths gh

  echo "### \033[31mlibc\033[0m"
  print_libc_infos

  echo "### \033[31mVulkan-SDK Path\033[0m"
  echo $VULKAN_SDK

  echo "### \033[31mEnvironment Path\033[0m"
  echo $PATH | tr ':' '\n'
}

# Call the function to show the tool locations
show_tool_locations
