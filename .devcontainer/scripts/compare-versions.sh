#!/bin/sh

# SPDX-FileCopyrightText: 2023-2025 Jens A. Koch
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

# This script compares the versions of packages between Debian releases.
# Default comparison is bookworm → trixie using apt-cache madison.
# Use --from <codename> --to <codename> to compare a different range
# (e.g. --from forky --to sid). Custom ranges auto-enable API mode,
# because apt-cache may not have all releases configured.
#
# Modes:
#   Local apt-cache:  default, requires sudo, only bookworm ↔ trixie
#   Debian Madison API:  --api flag or any non-default --from/--to range
#     (https://api.ftp-master.debian.org/madison)
#
# Release order (oldest → newest):
#   bullseye < bookworm < trixie < forky < sid
#
# The Source Upstream column fetches the latest release version from GitHub
# for known packages (cmake, ccache, doxygen, mold, jq, uv, gh, ninja).
# Unknown packages display "N/A".

# Requirements:
# apt install jq, apt-cache, sed, awk, tee, sudo
#
# Usage: ./compare-versions.sh [options] [--package|-p] <package1> <package2> ...
#
# Options:
#   --api                     Use Debian Madison API (supports any release range)
#   -f, --from <name>         Start release (default: bookworm)
#   -t, --to <name>           End release (default: trixie)
#   -p, --package, --packages Package names (also accepted as positional args)

# Global variables for managing the temporary source file
TEMP_SOURCE_FILE="/etc/apt/sources.list.d/bookworm-temp.list"

# Ordered list of Debian releases (oldest first)
RELEASES="bullseye bookworm trixie forky sid"

# Map codename to Debian Madison API suite name
codename_to_suite() {
    case "$1" in
        bullseye) echo "oldoldstable" ;;
        bookworm) echo "oldstable" ;;
        trixie)   echo "stable" ;;
        forky)    echo "testing" ;;
        sid)      echo "unstable" ;;
        *)        echo "" ;;
    esac
}

# Get index of a codename in the RELEASES list (0-based)
get_release_index() {
    local idx=0
    for r in $RELEASES; do
        if [ "$r" = "$1" ]; then
            echo "$idx"
            return
        fi
        idx=$((idx + 1))
    done
    echo "-1"
}

# Function to initialize apt update with the bookworm repository
add_temporary_apt_list() {
    echo "deb http://deb.debian.org/debian bookworm main" | \
    sudo tee $TEMP_SOURCE_FILE > /dev/null

    sudo apt-get update -o Dir::Etc::sourcelist=$TEMP_SOURCE_FILE \
                   -o Dir::Etc::sourceparts=/dev/null \
                   -o APT::Get::List-Cleanup=0 > /dev/null
}

# Function to remove the temporary apt source file
remove_temporary_apt_list() {
    sudo rm -f $TEMP_SOURCE_FILE
}

# Function to get versions for specific Debian releases using apt-cache madison
get_versions() {
    local result=$(apt-cache madison "$1" | awk '
        /bookworm/ {bookworm_version = $3}
        /trixie/ {trixie_version = $3}
        END {
            printf "{\"bookworm\": \"%s\", \"trixie\": \"%s\"}\n", bookworm_version, trixie_version
        }')

    echo "$result"
}

# Function to get versions using the Debian Madison API
# Supports arbitrary release lists via the SELECTED_RELEASES global
get_versions_api() {
    local pkg="$1"

    # Build jq filter dynamically from SELECTED_RELEASES
    local fields=""
    local first=true
    for rel in $SELECTED_RELEASES; do
        local suite=$(codename_to_suite "$rel")
        if [ "$first" = true ]; then
            first=false
        else
            fields="$fields, "
        fi
        fields="$fields\"$rel\": (\$data[\"$suite\"] | keys[0])"
    done

    local jq_filter='.[0][$pkg] as $data | {'"$fields"'} | @json'

    local result=$(curl -s "https://api.ftp-master.debian.org/madison?package=${pkg}&table=debian&f=json" | \
        jq -r --arg pkg "$pkg" "$jq_filter" 2>/dev/null)

    echo "$result"
}

# Function to fetch the latest upstream version for known packages
get_upstream_version() {
    local pkg="$1"
    local version=""

    case "$pkg" in
        cmake)
            version=$(curl -sL "https://api.github.com/repos/Kitware/CMake/releases/latest" | jq -r '.tag_name' 2>/dev/null)
            version=$(echo "$version" | sed 's/^v//')
            ;;
        ccache)
            version=$(curl -sL "https://api.github.com/repos/ccache/ccache/releases/latest" | jq -r '.tag_name' 2>/dev/null)
            version=$(echo "$version" | sed 's/^v//')
            ;;
        doxygen)
            version=$(curl -sL "https://api.github.com/repos/doxygen/doxygen/releases/latest" | jq -r '.tag_name' 2>/dev/null)
            version=$(echo "$version" | sed 's/^Release_//' | sed 's/_/./g')
            ;;
        mold)
            version=$(curl -sL "https://api.github.com/repos/rui314/mold/releases/latest" | jq -r '.tag_name' 2>/dev/null)
            version=$(echo "$version" | sed 's/^v//')
            ;;
        jq)
            version=$(curl -sL "https://api.github.com/repos/jqlang/jq/releases/latest" | jq -r '.tag_name' 2>/dev/null)
            version=$(echo "$version" | sed 's/^jq-//')
            ;;
        uv)
            version=$(curl -sL "https://api.github.com/repos/astral-sh/uv/releases/latest" | jq -r '.tag_name' 2>/dev/null)
            version=$(echo "$version" | sed 's/^v//')
            ;;
        gh|github-cli)
            version=$(curl -sL "https://api.github.com/repos/cli/cli/releases/latest" | jq -r '.tag_name' 2>/dev/null)
            version=$(echo "$version" | sed 's/^v//')
            ;;
        ninja|ninja-build)
            version=$(curl -sL "https://api.github.com/repos/ninja-build/ninja/releases/latest" | jq -r '.tag_name' 2>/dev/null)
            version=$(echo "$version" | sed 's/^v//')
            ;;
        *)
            echo "N/A"
            return
            ;;
    esac

    if [ -z "$version" ] || [ "$version" = "null" ]; then
        echo "N/A"
    else
        echo "$version"
    fi
}

# Function to normalize version strings (remove epoch, revision, suffix)
normalize_version() {
    version="$1"

    normalized_version=$(echo "$version" | sed 's/^[0-9]\+://')
    normalized_version=$(echo "$normalized_version" | sed 's/[~-][^ ]*$//')
    normalized_version=$(echo "$normalized_version" | sed 's/\+.*$//')

    echo "$normalized_version"
}

# Reverse a space-separated list
reverse_list() {
    local result=""
    for item in $1; do
        result="$item $result"
    done
    echo "$result"
}

# Get display name with version number for a codename
release_display_name() {
    case "$1" in
        bullseye) echo "Bullseye (11)" ;;
        bookworm) echo "Bookworm (12)" ;;
        trixie)   echo "Trixie (13)" ;;
        forky)    echo "Forky (14)" ;;
        sid)      echo "Sid (unstable)" ;;
        *)        echo "$1" ;;
    esac
}

# Function to print a table of package versions
print_version_table() {
    local DISPLAY_RELEASES=$(reverse_list "$SELECTED_RELEASES")

    local num_rels=0
    for rel in $DISPLAY_RELEASES; do
        num_rels=$((num_rels + 1))
    done

    # Header row 1: category labels
    printf "%-16s %-16s" "" "Source"
    for rel in $DISPLAY_RELEASES; do
        printf "%-16s" "Debian"
    done
    printf "\n"

    # Header row 2: column labels with version numbers
    printf "%-16s %-16s" "Package" "Upstream"
    for rel in $DISPLAY_RELEASES; do
        printf "%-16s" "$(release_display_name "$rel")"
    done
    printf "\n"

    # Separator
    printf "%-16s %-16s" "----------------" "----------------"
    for rel in $DISPLAY_RELEASES; do
        printf "%-16s" "----------------"
    done
    printf "\n"

    # Iterate over each package passed as argument
    for package in "$@"; do
        upstream_version=$(get_upstream_version "$package")

        if [ "$USE_API" = true ]; then
            versions=$(get_versions_api "$package")
        else
            versions=$(get_versions "$package")
        fi

        printf "%-16s %-16s" "$package" "$upstream_version"

        for rel in $DISPLAY_RELEASES; do
            local ver=$(echo "$versions" | jq -r ".[\"$rel\"]" 2>/dev/null)
            if [ "$ver" = "null" ] || [ -z "$ver" ]; then
                printf "%-16s" "N/A"
            else
                printf "%-16s" "$(normalize_version "$ver")"
            fi
        done
        printf "\n"
    done
}

# --- Main script execution ---

USE_API=false
FROM_RELEASE=bookworm
TO_RELEASE=trixie
FROM_TO_SET=false

# Parse flags
while true; do
    case "$1" in
        --api)
            USE_API=true
            shift
            ;;
        --from|-f)
            FROM_RELEASE="$2"
            FROM_TO_SET=true
            shift 2
            ;;
        --to|-t)
            TO_RELEASE="$2"
            FROM_TO_SET=true
            shift 2
            ;;
        --package|--packages|-p)
            shift
            # All remaining arguments are package names
            break
            ;;
        "")
            break
            ;;
        *)
            break
            ;;
    esac
done

if [ -z "$*" ]; then
    echo "Usage: $0 [options] [--package|-p] <package1> <package2> ..."
    echo ""
    echo "Options:"
    echo "  --api                     Use Debian Madison API (supports any release range)"
    echo "  -f, --from <name>         Start release (default: bookworm)"
    echo "  -t, --to <name>           End release (default: trixie)"
    echo "  -p, --package, --packages Package names (also accepted as positional args)"
    echo ""
    echo "Releases: $RELEASES"
    exit 1
fi

# Resolve release range
from_idx=$(get_release_index "$FROM_RELEASE")
to_idx=$(get_release_index "$TO_RELEASE")

if [ "$from_idx" = "-1" ]; then
    echo "Error: unknown release '$FROM_RELEASE'. Valid releases: $RELEASES"
    exit 1
fi
if [ "$to_idx" = "-1" ]; then
    echo "Error: unknown release '$TO_RELEASE'. Valid releases: $RELEASES"
    exit 1
fi
if [ "$from_idx" -gt "$to_idx" ]; then
    echo "Error: --from release must be older than --to release"
    exit 1
fi

# Build SELECTED_RELEASES list from range
SELECTED_RELEASES=""
idx=0
for r in $RELEASES; do
    if [ "$idx" -ge "$from_idx" ] && [ "$idx" -le "$to_idx" ]; then
        SELECTED_RELEASES="$SELECTED_RELEASES $r"
    fi
    idx=$((idx + 1))
done

# Strip leading space
SELECTED_RELEASES="${SELECTED_RELEASES# }"

# Auto-enable API mode for non-default ranges
if [ "$FROM_TO_SET" = true ] && [ "$USE_API" = false ]; then
    USE_API=true
fi

# Setup apt-cache mode (only when using default range without --api)
if [ "$USE_API" = false ]; then
    add_temporary_apt_list
    trap remove_temporary_apt_list EXIT
fi

print_version_table "$@"
