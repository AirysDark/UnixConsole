#!/usr/bin/env bash
##
## Unix_download.sh - Download and verify source archives for Unix_* packages
##

set -euo pipefail

# -----------------------------------------------------------------------------
# Global log file (override if needed)
# -----------------------------------------------------------------------------
: "${UNIX_BUILD_LOG:="/tmp/unix_build.log"}"
: "${UNIX_TMPDIR:="/tmp/unix_build"}"

mkdir -p "$UNIX_TMPDIR"

# -----------------------------------------------------------------------------
# Function: unix_download
# Description:
#   Download a file from a URL, verify SHA256 checksum if provided, with retries.
# Usage:
#   unix_download <URL> <SHA256SUM> <OUTPUT_FILENAME>
#   SHA256SUM can be empty if no checksum is provided
# -----------------------------------------------------------------------------
unix_download() {
    local url="$1"
    local sha256sum_expected="${2:-}"
    local output_file="$3"

    mkdir -p "$(dirname "$output_file")"

    echo "📥 Downloading $url ..."
    if ! curl -L --retry 5 --retry-delay 3 -o "$output_file" "$url"; then
        echo "❌ Failed to download $url" | tee -a "$UNIX_BUILD_LOG" >&2
        return 1
    fi

    if [[ -n "$sha256sum_expected" ]]; then
        echo "🔍 Verifying SHA256 checksum for $output_file ..."
        local sha256_actual
        sha256_actual=$(sha256sum "$output_file" | awk '{print $1}')
        if [[ "$sha256_actual" != "$sha256sum_expected" ]]; then
            echo "❌ Checksum mismatch for $output_file" | tee -a "$UNIX_BUILD_LOG" >&2
            echo "    Expected: $sha256sum_expected" | tee -a "$UNIX_BUILD_LOG" >&2
            echo "    Actual  : $sha256_actual" | tee -a "$UNIX_BUILD_LOG" >&2
            return 1
        fi
        echo "✅ SHA256 checksum verified."
    fi
}

# -----------------------------------------------------------------------------
# Function: unix_fetch_versions
# Description:
#   Download multiple versions from a JSON manifest
# Usage:
#   unix_fetch_versions <PACKAGE_JSON> <PACKAGE_NAME>
#   Expects JSON like:
#     { "package": { "versions": [ { "src_url": "...", "sha256": "...", "version": "..." } ] } }
# -----------------------------------------------------------------------------
unix_fetch_versions() {
    local manifest="$1"
    local pkg="$2"

    local count
    count=$(jq ".\"$pkg\".versions | length" "$manifest")

    for ((i=0;i<count;i++)); do
        local url sha256 ver filename
        url=$(jq -r ".\"$pkg\".versions[$i].src_url" "$manifest")
        sha256=$(jq -r ".\"$pkg\".versions[$i].sha256 // empty" "$manifest")
        ver=$(jq -r ".\"$pkg\".versions[$i].version" "$manifest")
        filename="$UNIX_TMPDIR/${pkg}_${ver}.tar.gz"

        unix_download "$url" "$sha256" "$filename"
    done
}

# -----------------------------------------------------------------------------
# Banner
# -----------------------------------------------------------------------------
echo "🛠️ Unix download utility loaded. Temporary downloads directory: $UNIX_TMPDIR"