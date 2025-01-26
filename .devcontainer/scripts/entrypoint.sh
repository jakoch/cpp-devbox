#!/bin/sh

# SPDX-FileCopyrightText: 2023-2025 Jens A. Koch
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

SCRIPT_DIR=$(dirname "$0")

# Docker Entrypoint

"$SCRIPT_DIR/show-tool-versions.sh"

# VCPKG - update library packages

echo "\n\033[31m[VCPKG] Updating Library Packages\033[0m"

cd "${VCPKG_ROOT}"
git pull --ff-only
