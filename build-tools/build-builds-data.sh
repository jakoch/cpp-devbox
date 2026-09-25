#!/bin/bash

# Builds website/_data/builds.json, the list of scheduled image builds.
#
# The release workflow also runs on a schedule (every Sunday) and publishes the
# images under a date tag (<codename>-20260920). Those builds are no git tags,
# so they are collected from the registry tag list instead, which has the added
# benefit that the history of past builds shows up without any bookkeeping.
#
# The tags of the build that is currently being published are passed in as well
# (build-tags-<codename>.json). They win over the registry, because a registry
# listing can lag behind the push by a few seconds.
#
# The builds.json of the previous publish can be passed in as a fallback, so a
# DockerHub API outage does not empty the table.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --data-dir <dir> [--input-dir <dir>] [--repository <ns/name>]
         [--max <n>] [--fallback <file>]

Writes \$DATA_DIR/builds.json, newest build first:
  [{ "date": "2026-09-20",
     "tags": { "bookworm": { "base": "bookworm-20260920",
                             "with-vulkansdk": "bookworm-with-vulkansdk-20260920" },
                "trixie": { "base": "trixie-20260920", ... } } }, ...]

  --input-dir  dir holding the build-tags-<codename>.json of the current build
  --repository DockerHub repository to read the tag list from
  --max        keep the n newest build dates (default 12)
  --fallback   builds.json of the previous publish, used for build dates that
               are missing from the registry tag list
EOF
  exit 1
}

DATA_DIR=""
INPUT_DIR=""
REPOSITORY="jakoch/cpp-devbox"
MAX_BUILDS="12"
FALLBACK=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --data-dir)   DATA_DIR="$2";   shift 2 ;;
    --input-dir)  INPUT_DIR="$2";  shift 2 ;;
    --repository) REPOSITORY="$2"; shift 2 ;;
    --max)        MAX_BUILDS="$2"; shift 2 ;;
    --fallback)   FALLBACK="$2";   shift 2 ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$DATA_DIR" ]]; then
  echo "Error: --data-dir is required"
  usage
fi

if [[ ! -d "$DATA_DIR" ]]; then
  echo "Error: data directory not found: $DATA_DIR"
  exit 1
fi

BUILDS_FILE="$DATA_DIR/builds.json"
TAGS_FILE="$DATA_DIR/registry-tags.json"

echo "=== Building builds data ==="
echo "  Data dir:     $DATA_DIR"
echo "  Repository:   $REPOSITORY"
echo "  Input dir:    ${INPUT_DIR:-<none>}"
echo "  Max builds:   $MAX_BUILDS"
echo "  Fallback:     ${FALLBACK:-<none>}"

# -----------------------------------------------------------------------------
# Read the tags of the current build from the artifacts
# -----------------------------------------------------------------------------

CURRENT_TAGS="[]"

if [[ -n "$INPUT_DIR" && -d "$INPUT_DIR" ]]; then
  CURRENT_TAGS="$(
    for f in "$INPUT_DIR"/build-tags-*.json; do
      [[ -f "$f" ]] || continue
      jq -c '[(.base // [])[], (.["with-vulkansdk"] // [])[]]' "$f"
    done | jq -s 'add // []'
  )"
fi

CURRENT_COUNT="$(jq 'length' <<< "$CURRENT_TAGS")"
echo "  Read $CURRENT_COUNT tags from the current build"

# -----------------------------------------------------------------------------
# Read all tags from the DockerHub API
# -----------------------------------------------------------------------------

REGISTRY_TAGS="[]"
API_URL="https://hub.docker.com/v2/repositories/${REPOSITORY}/tags?page_size=100"
PAGES=0

while [[ -n "$API_URL" ]]; do
  RESPONSE="$(curl -sf --retry 2 --max-time 60 "$API_URL" || true)"

  if [[ -z "$RESPONSE" ]] || ! jq -e . >/dev/null 2>&1 <<< "$RESPONSE"; then
    echo "  Warning: DockerHub API request failed, keeping the $PAGES pages read so far: $API_URL" >&2
    break
  fi

  REGISTRY_TAGS="$(jq -c --argjson tags "$REGISTRY_TAGS" \
    '$tags + [(.results // [])[].name]' <<< "$RESPONSE")"
  API_URL="$(jq -r '.next // ""' <<< "$RESPONSE")"
  PAGES=$(( PAGES + 1 ))
done

REGISTRY_COUNT="$(jq 'length' <<< "$REGISTRY_TAGS")"
echo "  Read $REGISTRY_COUNT tags from DockerHub in $PAGES pages"

if [[ "$REGISTRY_COUNT" -eq 0 && "$CURRENT_COUNT" -eq 0 && ! -f "${FALLBACK:-/nonexistent}" ]]; then
  echo "  Warning: no tag list available at all, the table stays empty" >&2
fi

# The full tag list tells build-release-tags.sh which releases still have their
# images published, the very first releases predate the per-codename version tags.
jq 'sort' <<< "$REGISTRY_TAGS" > "$TAGS_FILE"
echo "  Written: $TAGS_FILE"

# -----------------------------------------------------------------------------
# Assemble: dated tags -> one entry per build date
# -----------------------------------------------------------------------------

jq -n \
  --argjson registry "$REGISTRY_TAGS" \
  --argjson current "$CURRENT_TAGS" \
  --argjson fallback "$( [[ -f "${FALLBACK:-/nonexistent}" ]] && cat "$FALLBACK" || echo '[]' )" \
  --argjson max "$MAX_BUILDS" \
  '
  # a date tag is "<prefix>-<YYYYMMDD>" or "<prefix>-with-vulkansdk-<YYYYMMDD>"
  # the 20[0-9]{6} keeps the legacy "<codename>-<short sha>" tags out
  def dated($tag):
    ($tag | capture("^(?<prefix>[a-z][a-z0-9]*)(?<withvk>-with-vulkansdk)?-(?<date>20[0-9]{6})$")) as $m
    | { prefix: $m.prefix,
        variant: (if $m.withvk then "with-vulkansdk" else "base" end),
        date: $m.date,
        tag: $tag,
        prio: 0 };

  # "<prefix>-20260920" -> "2026-09-20"
  def iso8601: [ .[0:4], .[4:6], .[6:8] ] | join("-");

  # one build per date, its tags per <prefix>
  def to_builds:
    group_by(.date)
    | map({
        date: (.[0].date | iso8601),
        tags: (group_by(.prefix)
               | map({ key: .[0].prefix,
                       value: (map({ key: .variant, value: .tag }) | from_entries) })
               | from_entries)
      });

  # the current build wins over the registry, which can lag behind the push
  ([ $registry[] | dated(.) ] +
   [ $current[] | dated(.) | .prio = 1 ])
  | sort_by(.prio)
  | unique_by(.date, .prefix, .variant)
  | to_builds
  | . as $builds
  # build dates the registry did not report, e.g. because of an API outage
  | ([ $fallback[] | select(.date as $d | ($builds | map(.date) | index($d)) == null) ] + $builds)
  | unique_by(.date)
  | sort_by(.date)
  | reverse
  | .[0:$max]
  ' > "$BUILDS_FILE"

BUILD_COUNT="$(jq 'length' "$BUILDS_FILE")"
echo "  Written: $BUILDS_FILE ($BUILD_COUNT builds)"

echo "=== Done ==="
