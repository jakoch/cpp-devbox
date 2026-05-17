#!/bin/bash

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --codename <name> --debian-version <ver> --version <tag> --commit <sha> --date <date>
         --base-json <file> --vulkan-json <file> --output <file>

Merges per-variant version JSON arrays (from show-tool-versions.sh json)
with release metadata into a single aggregated release JSON.

Input JSON format (base and vulkan): a flat array of [name, version] pairs.
  e.g. [["GCC 12","12.2.0"],["Clang 20","20.1.0"]]

Output JSON format:
  {
    "version": "...", "codename": "...", "debian_version": "...",
    "commit": "...", "date": "...",
    "images": {
      "base": [...],
      "with-vulkansdk": [...]
    }
  }
EOF
  exit 1
}

# defaults
CODENAME=""
DEBIAN_VERSION=""
VERSION=""
COMMIT=""
DATE=""
BASE_JSON=""
VULKAN_JSON=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --codename)       CODENAME="$2";       shift 2 ;;
    --debian-version) DEBIAN_VERSION="$2"; shift 2 ;;
    --version)        VERSION="$2";        shift 2 ;;
    --commit)         COMMIT="$2";         shift 2 ;;
    --date)           DATE="$2";           shift 2 ;;
    --base-json)      BASE_JSON="$2";      shift 2 ;;
    --vulkan-json)    VULKAN_JSON="$2";    shift 2 ;;
    --output)         OUTPUT="$2";         shift 2 ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$CODENAME" || -z "$DEBIAN_VERSION" || -z "$VERSION" || -z "$COMMIT" || -z "$DATE" || -z "$BASE_JSON" || -z "$VULKAN_JSON" || -z "$OUTPUT" ]]; then
  echo "Error: all arguments are required"
  usage
fi

if [[ ! -f "$BASE_JSON" ]]; then
  echo "Error: base JSON file not found: $BASE_JSON"
  exit 1
fi

if [[ ! -f "$VULKAN_JSON" ]]; then
  echo "Error: vulkan JSON file not found: $VULKAN_JSON"
  exit 1
fi

jq -n \
  --arg version "$VERSION" \
  --arg codename "$CODENAME" \
  --arg debian_version "$DEBIAN_VERSION" \
  --arg commit "$COMMIT" \
  --arg date "$DATE" \
  --slurpfile base "$BASE_JSON" \
  --slurpfile vulkan "$VULKAN_JSON" \
  '{
    version: $version,
    codename: $codename,
    debian_version: $debian_version,
    commit: $commit,
    date: $date,
    images: {
      base: $base[0],
      "with-vulkansdk": $vulkan[0]
    }
  }' > "$OUTPUT"

echo "Written: $OUTPUT"
