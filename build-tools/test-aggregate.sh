#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
AGGREGATE="$SCRIPT_DIR/aggregate-versions.sh"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

# Mock base JSON for trixie (what show-tool-versions.sh json would produce)
cat > "$TMPDIR/mock-trixie-base.json" <<'JSON'
[
  ["GCC 14","14.1.0"],
  ["Clang 20","20.1.0"],
  ["Clang 22","22.1.0"],
  ["uv","0.6.0"],
  ["CMake","3.29.2"],
  ["Meson","1.7.2"],
  ["Ninja","1.12.1"],
  ["ccache","4.10.2"],
  ["mold","2.30.0"],
  ["vcpkg","2025.04.15"],
  ["lldb","20.1.0"],
  ["Valgrind","3.23.0"],
  ["cppcheck","2.15.0"],
  ["gprof","2.43.0"],
  ["perf","6.10.0"],
  ["strace","6.9.0"],
  ["ltrace","0.7.3"],
  ["lcov","2.1.0"],
  ["gcov","14.1.0"],
  ["gcovr","7.2.0"],
  ["nasm","2.16.3"],
  ["fasm","1.73.32"],
  ["Doxygen","1.12.0"],
  ["sphinx","8.1.3"],
  ["git","2.45.0"],
  ["gh cli","2.55.0"]
]
JSON

# Mock with-vulkan JSON for trixie
cat > "$TMPDIR/mock-trixie-vulkan.json" <<'JSON'
[
  ["GCC 14","14.1.0"],
  ["Clang 20","20.1.0"],
  ["Clang 22","22.1.0"],
  ["uv","0.6.0"],
  ["CMake","3.29.2"],
  ["Meson","1.7.2"],
  ["Ninja","1.12.1"],
  ["ccache","4.10.2"],
  ["mold","2.30.0"],
  ["vcpkg","2025.04.15"],
  ["lldb","20.1.0"],
  ["Valgrind","3.23.0"],
  ["cppcheck","2.15.0"],
  ["gprof","2.43.0"],
  ["perf","6.10.0"],
  ["strace","6.9.0"],
  ["ltrace","0.7.3"],
  ["lcov","2.1.0"],
  ["gcov","14.1.0"],
  ["gcovr","7.2.0"],
  ["nasm","2.16.3"],
  ["fasm","1.73.32"],
  ["Doxygen","1.12.0"],
  ["sphinx","8.1.3"],
  ["git","2.45.0"],
  ["gh cli","2.55.0"],
  ["Mesa","25.0.0"],
  ["Vulkan SDK","1.3.280.0"]
]
JSON

OUTPUT="$TMPDIR/versions-trixie.json"

echo "=== Running aggregate-versions.sh for trixie ==="
"$AGGREGATE" \
  --codename trixie \
  --debian-version 13 \
  --version v1.2.3 \
  --commit abcdef123456 \
  --date 2026-05-17 \
  --base-json "$TMPDIR/mock-trixie-base.json" \
  --vulkan-json "$TMPDIR/mock-trixie-vulkan.json" \
  --output "$OUTPUT"

echo ""
echo "=== Output ==="
cat "$OUTPUT"

echo ""
echo "=== Validation ==="
ERRORS=0

# Check top-level keys
for key in version codename debian_version commit date images; do
  if ! jq -e "has(\"$key\")" "$OUTPUT" > /dev/null 2>&1; then
    echo "FAIL: missing key '$key'"
    ERRORS=$((ERRORS + 1))
  fi
done

# Check images sub-keys
for key in base with-vulkansdk; do
  if ! jq -e ".images | has(\"$key\")" "$OUTPUT" > /dev/null 2>&1; then
    echo "FAIL: missing images.\"$key\""
    ERRORS=$((ERRORS + 1))
  fi
done

# Check values
VERSION_OK=$(jq -r '.version' "$OUTPUT")
CODENAME_OK=$(jq -r '.codename' "$OUTPUT")
DEBIAN_VER_OK=$(jq -r '.debian_version' "$OUTPUT")
COMMIT_OK=$(jq -r '.commit' "$OUTPUT")
DATE_OK=$(jq -r '.date' "$OUTPUT")
BASE_COUNT=$(jq '.images.base | length' "$OUTPUT")
VULKAN_COUNT=$(jq '.["images"]["with-vulkansdk"] | length' "$OUTPUT")

echo "  version:         $VERSION_OK"
echo "  codename:        $CODENAME_OK"
echo "  debian_version:  $DEBIAN_VER_OK"
echo "  commit:          $COMMIT_OK"
echo "  date:            $DATE_OK"
echo "  images.base count:            $BASE_COUNT"
echo "  images.with-vulkansdk count:  $VULKAN_COUNT"

if [[ "$VERSION_OK" != "v1.2.3" ]]; then
  echo "FAIL: version mismatch"
  ERRORS=$((ERRORS + 1))
fi
if [[ "$CODENAME_OK" != "trixie" ]]; then
  echo "FAIL: codename mismatch"
  ERRORS=$((ERRORS + 1))
fi
if [[ "$BASE_COUNT" -lt 1 ]]; then
  echo "FAIL: base array empty"
  ERRORS=$((ERRORS + 1))
fi
if [[ "$VULKAN_COUNT" -lt 1 ]]; then
  echo "FAIL: vulkan array empty"
  ERRORS=$((ERRORS + 1))
fi

if [[ "$ERRORS" -eq 0 ]]; then
  echo "PASS: all checks passed"
else
  echo "FAIL: $ERRORS error(s) found"
  exit 1
fi
