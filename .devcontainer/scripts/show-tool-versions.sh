#!/bin/sh

# SPDX-FileCopyrightText: 2023,2024 Jens A. Koch
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

# This info script shows the version of tools, compilers and libc.
# Output format is markdown.

# Function to print a table row in Markdown format
print_row() {
    printf "| %-13s | %-19s |\n" "$1" "$2"
}

# Function to check and print GCC versions if installed
print_row_gcc() {
    for version in 12 13 14; do
        gcc_path="/usr/bin/g++-$version"
        if [ -x "$gcc_path" ]; then
            gcc_version=$("$gcc_path" --version | awk 'NR==1 {print $NF}')
            print_row "GCC $version" "$gcc_version"
        fi
    done
}

# Function to check and print GCC versions if installed
print_row_clang() {
    for version in 16 17 18 19; do
        clang_path="/usr/bin/clang++-$version"
        if [ -x "$clang_path" ]; then
            clang_version=$("$clang_path" --version | head -n1 | awk '{print $4}')
            print_row "Clang $version" "$clang_version"
        fi
    done
}

# Function to check if a package is installed
is_installed() {
  package=$1
  if dpkg -l | grep "$package" > /dev/null; then
    return 0
  else
    return 1
  fi
}

# Function to check if mesa-vulkan-drivers is installed
is_installed_mesa() {
  is_installed "mesa-vulkan-drivers"
}

# Function to check if Vulkan SDK is installed
is_installed_vulkan_sdk() {
    is_installed "libvulkan1"
}

# Function to print the tool versions in a table
show_tool_versions() {
    # Assign versions to variables
    clang_version=$(clang --version | head -n1 | awk '{print $4}')
    cmake_version=$(cmake --version | head -n1 | awk '{print $3}')
    ninja_version=$(ninja --version)
    ccache_version=$(ccache --version | head -n1 | awk '{print $3}')
    mold_version=$(mold --version | awk '{print $2}')
    vcpkg_version=$(vcpkg --version | head -n1 | awk '{print substr($6, 0, 19)}')
    lldb_version=$(lldb --version | awk '{print $3}')
    valgrind_version=$(valgrind --version | cut -c 10-)
    gdb_version=$(gdb --version | head -n1 | awk '{print $5}')
    clang_tidy_version=$(clang-tidy --version | head -n1 | awk '{print $4}')
    clang_format_version=$(clang-format --version | head -n1 | awk '{print $4}')
    cppcheck_version=$(cppcheck --version | awk '{print $2}')
    gprof_version=$(gprof --version | head -n1 | awk '{print $7}')
    perf_version=$(perf --version | awk '{print $3}')
    strace_version=$(strace --version | awk '{print $4}')
    ltrace_version=$(ltrace --version | head -n1 | awk '{print $2}')
    doxygen_version=$(doxygen -v | awk '{print $1}')
    sphinx_version=$(sphinx-build --version | awk '{print $2}')
    git_version=$(git --version | cut -c 13-)
    github_cli_version=$(gh --version | awk '{print $3}')
    mesa_version=$(dpkg -l | grep "mesa-vulkan-drivers" | awk '{print $3}')
    vulkan_version=$(echo $VULKAN_SDK | awk -F '/' '{print $4}')

    printf "## Version Overview\n\n"

    # Print table header in Markdown format
    printf "| Tool          | Version             |\n"
    printf "|:--------------|:--------------------|\n"

    # Print each row of the table in Markdown format
    print_row_gcc
    print_row_clang
    print_row "CMake" "$cmake_version"
    print_row "Ninja" "$ninja_version"
    print_row "ccache" "$ccache_version"
    print_row "mold" "$mold_version"
    print_row "vcpkg" "$vcpkg_version"
    print_row "lldb" "$lldb_version"
    print_row "Valgrind" "$valgrind_version"
    print_row "cppcheck" "$cppcheck_version"
    print_row "gprof" "$gprof_version"
    print_row "perf" "$perf_version"
    print_row "strace" "$strace_version"
    print_row "ltrace" "$ltrace_version"
    print_row "Doxygen" "$doxygen_version"
    print_row "sphinx" "$sphinx_version"
    print_row "git" "$git_version"
    print_row "gh cli" "$github_cli_version"
    if is_installed_mesa; then
        print_row "Mesa" "$mesa_version"
    fi
    if is_installed_vulkan_sdk; then
        print_row "Vulkan SDK" "$vulkan_version"
    fi
}

# Call the function to show the tool versions
show_tool_versions
