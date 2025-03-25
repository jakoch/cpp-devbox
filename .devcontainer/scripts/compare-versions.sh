#!/bin/sh

# SPDX-FileCopyrightText: 2023-2025 Jens A. Koch
# SPDX-License-Identifier: MIT
# This file is part of https://github.com/jakoch/cpp-devbox

# This script compares the versions of packages between Debian releases.
# It uses the apt-cache madison command to fetch the versions for the bookworm and trixie releases.
# The versions are then normalized to remove any debian-specific revision or update information.
# The script prints a table with the package name, source version, and versions for trixie and bookworm.
# Output format is markdown.

# Requirements:
# apt install jq, apt-cache, sed, awk, tee, sudo
#
# Usage: ./compare-versions.sh <package1> <package2> ...
#

# Global variables for managing the temporary source file
TEMP_SOURCE_FILE="/etc/apt/sources.list.d/bookworm-temp.list"

# Function to initialize apt update with the bookworm repository
add_temporary_apt_list() {
    # Add bookworm repository temporarily
    echo "deb http://deb.debian.org/debian bookworm main" | \
    sudo tee $TEMP_SOURCE_FILE > /dev/null

    # Update package lists for bookworm only
    sudo apt-get update -o Dir::Etc::sourcelist=$TEMP_SOURCE_FILE \
                   -o Dir::Etc::sourceparts=/dev/null \
                   -o APT::Get::List-Cleanup=0 > /dev/null
}

# Function to remove the temporary apt source file
remove_temporary_apt_list() {
    sudo rm -f $TEMP_SOURCE_FILE
}

# Function to get versions for specific Debian releases and return JSON
get_versions() {
    # Fetch versions for bookworm and trixie using apt-cache madison
    local result=$(apt-cache madison "$1" | awk '
        /bookworm/ {bookworm_version = $3}
        /trixie/ {trixie_version = $3}
        END {
            printf "{\"bookworm\": \"%s\", \"trixie\": \"%s\"}\n", bookworm_version, trixie_version
        }')

    # Return JSON result
    echo "$result"
}

# Function to normalize version strings
normalize_version() {
    # Input: $1 is the version string
    version="$1"

    # Remove the epoch (if present)
    normalized_version=$(echo "$version" | sed 's/^[0-9]\+://')

    # Remove any revision or update information (anything after the first hyphen or tilde)
    normalized_version=$(echo "$normalized_version" | sed 's/[~-][^ ]*$//')

    # Remove any suffix like "+dfsg" after the version
    normalized_version=$(echo "$normalized_version" | sed 's/\+.*$//')

    # Output the normalized version
    echo "$normalized_version"
}

# Function to print a table of package versions
print_version_table() {
    # Print header
    printf "%-16s %-15s %-15s %-15s\n" "" "Source" "Debian" "Debian"
    printf "%-16s %-15s %-15s %-15s\n" "Package" "Upstream" "Trixie" "Bookworm"
    echo "-------------------------------------------------------------------------------"

    # Iterate over each package passed as argument
    for package in "$@"; do
        # Get the versions for the current package
        versions=$(get_versions "$package")

        # Parse the JSON result and extract the versions
        bookworm_version=$(echo "$versions" | jq -r '.bookworm')
        trixie_version=$(echo "$versions" | jq -r '.trixie')

        # Check if jq failed to parse the versions
        if [ "$bookworm_version" = "null" ]; then
            bookworm_version_raw=$(echo "$versions" | jq -r '.bookworm' || echo "$bookworm_version")
            normalized_bookworm="$bookworm_version_raw"
        else
            # Normalize the versions
            normalized_bookworm=$(normalize_version "$bookworm_version")
        fi

        if [ "$trixie_version" = "null" ]; then
            trixie_version_raw=$(echo "$versions" | jq -r '.trixie' || echo "$trixie_version")
            normalized_trixie="$trixie_version_raw"
        else
            # Normalize the versions
            normalized_trixie=$(normalize_version "$trixie_version")
        fi

        # Print the row for the current package
        printf "%-16s %-15s %-15s %-15s\n" "$package" "N/A" "$normalized_trixie" "$normalized_bookworm"
    done
}

# Main script execution
add_temporary_apt_list
trap remove_temporary_apt_list EXIT  # Ensure cleanup on script exit

# Call the print_version_table function with the desired package names
print_version_table "$@"
