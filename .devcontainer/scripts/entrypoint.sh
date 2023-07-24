#!/bin/sh

SCRIPT_DIR=$(dirname "$0")

# Docker Entrypoint

"$SCRIPT_DIR/show-tool-versions.sh"

# VCPKG - update library packages

echo "\033[31m[VCPKG] Updating Library Packages\033[0m"

cd "${VCPKG_ROOT}"
git pull --ff-only

