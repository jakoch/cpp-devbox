#!/bin/bash

# Builds website/_data/release-tags.json from the git tags of the repository.
#
# Two kinds of entries are produced:
#   rolling  the build of the default branch, whose images carry the floating
#            "-latest" tags. It is always listed first, because it is the
#            newest thing a user can pull.
#   release  every semantic version tag (v1.2.3), sorted newest first. Each one
#            gets its own page under /releases/.
#
# The scheduled (weekly) image builds are not git tags, they are listed
# separately by build-builds-data.sh.

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --data-dir <dir> --repo-dir <dir> --ref-name <name> --ref-type <type>
         --date <date> --commit <sha> [--max-releases <n>] [--tags-file <file>]

Writes \$DATA_DIR/release-tags.json:
  [{ "version": "main", "kind": "rolling", "date": "...", "git-sha": "..." },
   { "version": "1.2.3", "kind": "release", "date": "...", "git-sha": "...",
     "tags": true }, ...]

  --ref-type  "tag" or "branch". The rolling entry is the branch build, so
              versioned builds (\$REF_NAME is a v1.2.3 tag) are listed as
              releases only.
  --max-releases  keep at most n releases (0 = keep all)
  --tags-file  registry-tags.json of build-builds-data.sh. The images of the
              oldest releases were never published per version, so it is used
              to flag the releases that still have their images.
EOF
  exit 1
}

DATA_DIR=""
REPO_DIR=""
REF_NAME=""
REF_TYPE="branch"
DATE=""
COMMIT=""
MAX_RELEASES="0"
TAGS_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --data-dir)     DATA_DIR="$2";     shift 2 ;;
    --repo-dir)     REPO_DIR="$2";     shift 2 ;;
    --ref-name)     REF_NAME="$2";     shift 2 ;;
    --ref-type)     REF_TYPE="$2";     shift 2 ;;
    --date)         DATE="$2";         shift 2 ;;
    --commit)       COMMIT="$2";       shift 2 ;;
    --max-releases) MAX_RELEASES="$2"; shift 2 ;;
    --tags-file)    TAGS_FILE="$2";    shift 2 ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$DATA_DIR" || -z "$REPO_DIR" || -z "$REF_NAME" || -z "$DATE" || -z "$COMMIT" ]]; then
  echo "Error: all arguments are required"
  usage
fi

if [[ ! -d "$DATA_DIR" ]]; then
  echo "Error: data directory not found: $DATA_DIR"
  exit 1
fi

if ! git -C "$REPO_DIR" rev-parse --git-dir >/dev/null 2>&1; then
  echo "Error: not a git repository: $REPO_DIR"
  exit 1
fi

# The rolling build is the build of the default branch. A versioned build
# (REF_TYPE=tag) does not produce a rolling build, so it keeps "main" as id.
ROLLING_VERSION="main"
if [[ "$REF_TYPE" != "tag" ]]; then
  ROLLING_VERSION="$REF_NAME"
fi

if [[ -n "$TAGS_FILE" && ! -f "$TAGS_FILE" ]]; then
  echo "Error: tag list not found: $TAGS_FILE"
  exit 1
fi

PUBLISHED_TAGS="[]"
if [[ -f "$TAGS_FILE" ]]; then
  PUBLISHED_TAGS="$(cat "$TAGS_FILE")"
  echo "  Read $(jq 'length' <<< "$PUBLISHED_TAGS") published image tags"
fi

RELEASE_TAGS_FILE="$DATA_DIR/release-tags.json"

echo "=== Building release tags ==="
echo "  Repo dir:     $REPO_DIR"
echo "  Data dir:     $DATA_DIR"
echo "  Ref:          $REF_NAME ($REF_TYPE)"
echo "  Rolling id:   $ROLLING_VERSION"
echo "  Date:         $DATE"
echo "  Commit:       $COMMIT"

# name|date|sha of every tag, as one JSON array
TAGS_JSON="$(
  git -C "$REPO_DIR" for-each-ref \
    --format='%(refname:short)|%(creatordate:short)|%(objectname)' \
    refs/tags | jq -R -s -c 'split("\n") | map(select(length > 0)) | map(split("|"))'
)"

TAG_COUNT="$(jq 'length' <<< "$TAGS_JSON")"
echo "  Found $TAG_COUNT tags"

jq -n \
  --argjson tags "$TAGS_JSON" \
  --argjson published "$PUBLISHED_TAGS" \
  --arg rolling "$ROLLING_VERSION" \
  --arg date "$DATE" \
  --arg sha "$COMMIT" \
  --argjson max "$MAX_RELEASES" \
  '
  def release:
    select(.ref | test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))
    | .ref as $ref
    | ($ref | capture("^v(?<major>[0-9]+)\\.(?<minor>[0-9]+)\\.(?<patch>[0-9]+)$")) as $semver
    | { version: ($ref | ltrimstr("v")),
        date: .date,
        "git-sha": .sha,
        # the images of a release are tagged "<codename>-<version>"
        tags: ([ $published[] | select(endswith("-" + $ref[1:])) ] | length > 0),
        major: ($semver.major | tonumber),
        minor: ($semver.minor | tonumber),
        patch: ($semver.patch | tonumber) };

  [ $tags[]
    | { ref: .[0], date: .[1], sha: .[2] }
    | release
  ]
  | sort_by(.major, .minor, .patch)
  | reverse
  | map({ version: .version, kind: "release", date: .date,
         "git-sha": ."git-sha", tags: .tags })
  | if $max > 0 then .[0:$max] else . end
  | ([{ version: $rolling, kind: "rolling", date: $date, "git-sha": $sha }] + .)
  ' > "$RELEASE_TAGS_FILE"

RELEASE_COUNT="$(jq '[.[] | select(.kind == "release")] | length' "$RELEASE_TAGS_FILE")"
echo "  Written: $RELEASE_TAGS_FILE ($RELEASE_COUNT releases + 1 rolling build)"

echo "=== Done ==="
