#!/usr/bin/env bash
##
## Unix_setup_proot.sh - Setup isolated PRoot environment for builds
##

set -euo pipefail

# -----------------------------
# Ensure PRoot is installed
# -----------------------------
if ! command -v proot &>/dev/null; then
    echo "📦 Installing PRoot..."
    sudo apt-get update
    sudo apt-get install -y proot
fi

# -----------------------------
# Rootfs setup
# -----------------------------
PROOT_ROOT="${UNIX_TMPDIR:-/tmp/unix_build}/proot"
mkdir -p "$PROOT_ROOT"

UBUNTU_VERSION="22.04"
ROOTFS_TAR="$PROOT_ROOT/ubuntu-${UBUNTU_VERSION}.tar.gz"
ROOTFS_DIR="$PROOT_ROOT/ubuntu-${UBUNTU_VERSION}"

if [ ! -d "$ROOTFS_DIR" ]; then
    echo "⬇️ Downloading Ubuntu $UBUNTU_VERSION minimal rootfs..."
    curl -L -o "$ROOTFS_TAR" "https://partner-images.canonical.com/core/$UBUNTU_VERSION/current/ubuntu-$UBUNTU_VERSION-core-cloudimg-amd64-root.tar.gz"
    echo "📦 Extracting rootfs..."
    mkdir -p "$ROOTFS_DIR"
    tar -xzf "$ROOTFS_TAR" -C "$ROOTFS_DIR"
    echo "✅ Ubuntu $UBUNTU_VERSION rootfs ready at $ROOTFS_DIR"
fi

# -----------------------------
# Export for build.sh
# -----------------------------
export PROOT_ROOT
export ROOTFS_DIR

echo "✅ PRoot environment configured."
echo "Rootfs directory: $ROOTFS_DIR"