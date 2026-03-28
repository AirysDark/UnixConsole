#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Native Unix build environment setup (Ubuntu/Debian x86_64)
# Focused on building Unix_* packages (pure Linux)
# =============================================================================

# -----------------------------
# Prepare logging
# -----------------------------
LOG_FILE="/tmp/unix_build_setup.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "🛠️ Starting native Unix build setup at $(date)" > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# -----------------------------
# Use sudo if not root
# -----------------------------
SUDO="sudo"
if [ "$(id -u)" = "0" ]; then
    SUDO=""
fi

# -----------------------------
# Environment variables
# -----------------------------
UNIX_PKG_TMPDIR="/tmp"
UNIX_PREFIX="/usr/local/unix-build"
TMP_UNIX="$UNIX_PKG_TMPDIR/unix_build"
BUILD_DIR="$UNIX_PREFIX/build"

mkdir -p "$TMP_UNIX" "$BUILD_DIR"

export UNIX_TMPDIR="$TMP_UNIX"
export UNIX_PREFIX="$UNIX_PREFIX"
export PATH="$UNIX_PREFIX/bin:$PATH"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export MULTIARCH_ENABLED=true
export BUILD_ARCH="$(uname -m)"
case "$BUILD_ARCH" in
    x86_64) export BUILD_ARCH_32=i686;;
    aarch64) export BUILD_ARCH_32=arm;;
    *) export BUILD_ARCH_32="$BUILD_ARCH";;
esac

echo "✅ Environment variables set:"
echo "   UNIX_TMPDIR=$UNIX_TMPDIR"
echo "   UNIX_PREFIX=$UNIX_PREFIX"
echo "   BUILD_DIR=$BUILD_DIR"
echo "   BUILD_ARCH=$BUILD_ARCH"
echo "   BUILD_ARCH_32=$BUILD_ARCH_32"
echo "   MULTIARCH_ENABLED=$MULTIARCH_ENABLED"

# -----------------------------
# Helper function: safe apt install
# -----------------------------
apt_install() {
    packages="$*"
    echo "📦 Installing packages: $packages"
    if ! $SUDO apt-get install -y $packages; then
        echo "⚠️ WARNING: Failed to install packages: $packages" >> "$LOG_FILE"
        echo "You may need to install them manually." >> "$LOG_FILE"
    fi
}

# -----------------------------
# Enable multiarch and update apt
# -----------------------------
echo "🔄 Updating system packages..."
$SUDO dpkg --add-architecture i386 || true
$SUDO apt-get update -y
$SUDO apt-get upgrade -y

# -----------------------------
# Source utility scripts
# -----------------------------
echo "🔹 Sourcing helper scripts..."
source ./Core.sh
source ./Env.sh
source ./Lib.sh
source ./Tools.sh
source ./utilities.sh

# -----------------------------
# Generate locale
# -----------------------------
echo "🌐 Generating locale..."
$SUDO locale-gen en_US.UTF-8
$SUDO update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# -----------------------------
# Final log entry
# -----------------------------
echo "✅ Native Unix build environment setup completed successfully at $(date)"
echo "Build directory: $BUILD_DIR"
echo "Temporary directory: $TMP_UNIX"