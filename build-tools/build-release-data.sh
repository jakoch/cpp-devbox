#!/bin/bash

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --version <tag> --date <date> --commit <sha>
         --input-dir <dir> --data-dir <dir>

Merges per-codename version JSONs (versions-*.json from --input-dir)
into the website _data/ structure for Jekyll.

Steps:
  1. Merge into _data/releases/<version_sanitized>.json
     { images: { bookworm: { base: [...], "with-vulkansdk": [...] }, ... } }

  2. Prepend a new entry to _data/release-tags.json
     [{ "version": "...", "date": "...", "git-sha": "..." }, ...]

Input JSON format (per file):
  { "version": "v1.2.3", "codename": "bookworm", "debian_version": "12",
    "commit": "<sha>", "date": "2026-05-17",
    "images": { "base": [[...],[...]], "with-vulkansdk": [[...],[...]] } }
EOF
  exit 1
}

VERSION=""
DATE=""
COMMIT=""
INPUT_DIR=""
DATA_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --version)     VERSION="$2";    shift 2 ;;
    --date)        DATE="$2";       shift 2 ;;
    --commit)      COMMIT="$2";     shift 2 ;;
    --input-dir)   INPUT_DIR="$2";  shift 2 ;;
    --data-dir)    DATA_DIR="$2";   shift 2 ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$VERSION" || -z "$DATE" || -z "$COMMIT" || -z "$INPUT_DIR" || -z "$DATA_DIR" ]]; then
  echo "Error: all arguments are required"
  usage
fi

if [[ ! -d "$INPUT_DIR" ]]; then
  echo "Error: input directory not found: $INPUT_DIR"
  exit 1
fi

if [[ ! -d "$DATA_DIR" ]]; then
  echo "Error: data directory not found: $DATA_DIR"
  exit 1
fi

STRIP_V="${VERSION#v}"
VERSION_KEY="${STRIP_V//./_}"

echo "=== Building release data ==="
echo "  Version:      $VERSION"
echo "  Version key:  $VERSION_KEY"
echo "  Date:         $DATE"
echo "  Commit:       $COMMIT"
echo "  Input dir:    $INPUT_DIR"
echo "  Data dir:     $DATA_DIR"

# ---------------------------------------------------------------------------
# Step 1: Merge per-codename JSONs into per-release file
# ---------------------------------------------------------------------------
RELEASE_FILE="$DATA_DIR/releases/$VERSION_KEY.json"
mkdir -p "$DATA_DIR/releases"

# Collect all versions-*.json files
INPUT_FILES=("$INPUT_DIR"/versions-*.json)

if [[ ${#INPUT_FILES[@]} -eq 0 ]]; then
  echo "Error: no versions-*.json files found in $INPUT_DIR"
  exit 1
fi

echo "  Found ${#INPUT_FILES[@]} version files"

# Build a JSON document from all input files, then restructure into
# { images: { <codename>: { base: [...], "with-vulkansdk": [...] }, ... } }
jq -n \
  --argjson inputs "$(
    for f in "${INPUT_FILES[@]}"; do
      jq -c '{codename, images: (.images // {base: [], "with-vulkansdk": []})}' "$f"
    done | jq -s '.'
  )" \
  '{ images: ( $inputs | map( { (.codename): { base: .images.base, "with-vulkansdk": .images["with-vulkansdk"] } } ) | add ) }' \
  > "$RELEASE_FILE"

echo "  Written: $RELEASE_FILE"

# ---------------------------------------------------------------------------
# Step 2: Update release-tags.json (prepend new entry)
# ---------------------------------------------------------------------------
TAGS_FILE="$DATA_DIR/release-tags.json"

if [[ ! -f "$TAGS_FILE" ]]; then
  echo "[]" > "$TAGS_FILE"
fi

jq \
  --arg version "$STRIP_V" \
  --arg date "$DATE" \
  --arg sha "$COMMIT" \
  '[{version: $version, date: $date, "git-sha": $sha}] + .' \
  "$TAGS_FILE" > "${TAGS_FILE}.tmp"

mv "${TAGS_FILE}.tmp" "$TAGS_FILE"
echo "  Updated: $TAGS_FILE"

echo "=== Done ==="
