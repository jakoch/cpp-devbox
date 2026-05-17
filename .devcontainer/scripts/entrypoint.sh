#!/bin/sh

# SPDX-FileCopyrightText: 2023-2025 Jens A. Koch
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd -P)"

# -----------------
# Docker Entrypoint
# -----------------

# VCPKG - update library packages

echo "\n\033[31m[VCPKG] Updating Library Packages\033[0m"

if [ -n "${VCPKG_ROOT:-}" ] && [ -d "${VCPKG_ROOT}" ]; then
    printf "\n\033[31m[VCPKG] Updating Library Packages\033[0m\n"
    git -C "${VCPKG_ROOT}" pull --ff-only
fi

# Show versions of installed tools

exec "$SCRIPT_DIR/show-tool-versions.sh"
