#!/usr/bin/env bash
##
## Unix_packages.sh - Manage and download Unix_* package sources
##

set -euo pipefail

# -----------------------------
# Base directories
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UNIX_TMPDIR="${UNIX_TMPDIR:-/tmp/unix_build}"
UNIX_SRC_DIR="$UNIX_TMPDIR/sources"
PACKAGES_JSON="$SCRIPT_DIR/root-packages/root-packages-sha256.json"

mkdir -p "$UNIX_SRC_DIR"

# -----------------------------
# Check dependencies
# -----------------------------
for cmd in jq curl sha256sum mkdir; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "❌ Required command not found: $cmd"
        exit 1
    fi
done

# -----------------------------
# Load packages from JSON
# -----------------------------
declare -A UNIX_PACKAGES

while IFS= read -r pkg; do
    versions=$(jq -c ".\"$pkg\".versions[]" "$PACKAGES_JSON")
    for v in $versions; do
        SRC_URL=$(echo "$v" | jq -r '.src_url')
        SHA256=$(echo "$v" | jq -r '.sha256 // empty')
        VERSION=$(echo "$v" | jq -r '.version')
        UNIX_PACKAGES["$pkg|$VERSION"]="$SRC_URL|$SHA256|$VERSION"
    done
done < <(jq -r 'keys[]' "$PACKAGES_JSON")

# -----------------------------
# List available packages
# -----------------------------
unix_list_packages() {
    echo "📦 Available Unix_* packages:"
    for key in "${!UNIX_PACKAGES[@]}"; do
        pkg="${key%%|*}"
        ver="${key##*|}"
        echo " - $pkg (version $ver)"
    done
}

# -----------------------------
# Fetch a package
# -----------------------------
unix_fetch_package() {
    local pkg="$1"
    local version="${2:-}"

    if [[ -z "$version" ]]; then
        # Pick latest if version not provided
        version=$(jq -r ".\"$pkg\".versions[-1].version" "$PACKAGES_JSON")
    fi

    key="$pkg|$version"
    if [[ -z "${UNIX_PACKAGES[$key]+x}" ]]; then
        echo "❌ Package '$pkg' version '$version' not found"
        return 1
    fi

    IFS='|' read -r SRC_URL SHA256 VERSION <<< "${UNIX_PACKAGES[$key]}"
    FILE_NAME="${SRC_URL##*/}"
    DEST_DIR="$UNIX_SRC_DIR/$pkg/$VERSION"
    mkdir -p "$DEST_DIR"

    echo "⬇️ Downloading $pkg version $VERSION..."
    curl -L -o "$DEST_DIR/$FILE_NAME" "$SRC_URL"

    if [[ -n "$SHA256" ]]; then
        echo "🔍 Verifying SHA256..."
        echo "$SHA256  $DEST_DIR/$FILE_NAME" | sha256sum -c -
    fi

    echo "✅ $pkg downloaded successfully to $DEST_DIR/$FILE_NAME"
}

# -----------------------------
# Fetch all packages
# -----------------------------
unix_fetch_all() {
    for key in "${!UNIX_PACKAGES[@]}"; do
        pkg="${key%%|*}"
        ver="${key##*|}"
        unix_fetch_package "$pkg" "$ver"
    done
}

# -----------------------------
# Show package info
# -----------------------------
unix_package_info() {
    local pkg="$1"
    local version="${2:-}"

    if [[ -z "$version" ]]; then
        version=$(jq -r ".\"$pkg\".versions[-1].version" "$PACKAGES_JSON")
    fi

    key="$pkg|$version"
    if [[ -z "${UNIX_PACKAGES[$key]+x}" ]]; then
        echo "❌ Package '$pkg' version '$version' not found"
        return 1
    fi

    IFS='|' read -r SRC_URL SHA256 VERSION <<< "${UNIX_PACKAGES[$key]}"
    echo "Package: $pkg"
    echo "  Version: $VERSION"
    echo "  Source URL: $SRC_URL"
    [[ -n "$SHA256" ]] && echo "  SHA256: $SHA256"
}

# -----------------------------
# CLI interface
# -----------------------------
COMMAND="${1:-list}"
PACKAGE="${2:-}"
VERSION="${3:-}"

case "$COMMAND" in
    list)
        unix_list_packages
        ;;
    fetch)
        if [[ -z "$PACKAGE" ]]; then
            echo "❌ Usage: $0 fetch PACKAGE_NAME [VERSION]"
            exit 1
        fi
        unix_fetch_package "$PACKAGE" "$VERSION"
        ;;
    fetch-all)
        unix_fetch_all
        ;;
    info)
        if [[ -z "$PACKAGE" ]]; then
            echo "❌ Usage: $0 info PACKAGE_NAME [VERSION]"
            exit 1
        fi
        unix_package_info "$PACKAGE" "$VERSION"
        ;;
    *)
        echo "❌ Unknown command '$COMMAND'"
        echo "Usage: $0 [list|fetch|fetch-all|info] PACKAGE_NAME [VERSION]"
        exit 1
        ;;
esac