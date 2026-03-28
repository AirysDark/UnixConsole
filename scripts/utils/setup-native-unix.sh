#!/usr/bin/env bash
##
<<<<<<< Updated upstream
## setup-native-unix.sh - Native Unix build environment setup (Ubuntu/Debian x86_64)
##
## Prepares environment variables, directories, logging, locale, and core utilities
=======
## setup-native-unix.sh - Native Unix build environment setup
## Supports multi-arch builds and isolated rootfs for Unix_* packages
>>>>>>> Stashed changes
##

set -euo pipefail

# =============================================================================
<<<<<<< Updated upstream
# Logging
=======
# Prepare logging
>>>>>>> Stashed changes
# =============================================================================
LOG_FILE="/tmp/unix_build_setup.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "🛠️ Starting native Unix build setup at $(date)" > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# =============================================================================
<<<<<<< Updated upstream
# Root / Sudo
=======
# Use sudo if not root
>>>>>>> Stashed changes
# =============================================================================
SUDO="sudo"
if [ "$(id -u)" = "0" ]; then
    SUDO=""
fi

# =============================================================================
<<<<<<< Updated upstream
# Environment Variables & Directories
# =============================================================================
UNIX_PKG_TMPDIR="${UNIX_PKG_TMPDIR:-/tmp}"
UNIX_PREFIX="${UNIX_PREFIX:-/usr/local/unix-build}"
=======
# Environment variables
# =============================================================================
UNIX_PKG_TMPDIR="/tmp"
UNIX_PREFIX="/usr/local/unix-build"
>>>>>>> Stashed changes
TMP_UNIX="$UNIX_PKG_TMPDIR/unix_build"
BUILD_DIR="$UNIX_PREFIX/build"
PROOT_DIR="$UNIX_PREFIX/proot"

mkdir -p "$TMP_UNIX" "$BUILD_DIR" "$PROOT_DIR"

export UNIX_TMPDIR="$TMP_UNIX"
export UNIX_PREFIX="$UNIX_PREFIX"
export PROOT_DIR="$PROOT_DIR"
export PATH="$UNIX_PREFIX/bin:$PATH"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Multiarch support
export MULTIARCH_ENABLED=true
export BUILD_ARCH="$(uname -m)"
case "$BUILD_ARCH" in
<<<<<<< Updated upstream
    x86_64) export BUILD_ARCH_32=i686 ;;
    aarch64) export BUILD_ARCH_32=arm ;;
    *) export BUILD_ARCH_32="$BUILD_ARCH" ;;
=======
    x86_64) export BUILD_ARCH_32=i686;;
    aarch64) export BUILD_ARCH_32=arm;;
    i686) export BUILD_ARCH_32=i386;;
    arm) export BUILD_ARCH_32=arm;;
    *) export BUILD_ARCH_32="$BUILD_ARCH";;
>>>>>>> Stashed changes
esac

echo "✅ Environment variables set:"
echo "   UNIX_TMPDIR=$UNIX_TMPDIR"
echo "   UNIX_PREFIX=$UNIX_PREFIX"
echo "   PROOT_DIR=$PROOT_DIR"
echo "   BUILD_DIR=$BUILD_DIR"
echo "   BUILD_ARCH=$BUILD_ARCH"
echo "   BUILD_ARCH_32=$BUILD_ARCH_32"
echo "   MULTIARCH_ENABLED=$MULTIARCH_ENABLED"

# =============================================================================
<<<<<<< Updated upstream
# Helper: Safe apt install
=======
# Helper function: safe apt install
>>>>>>> Stashed changes
# =============================================================================
apt_install() {
    local packages="$*"
    echo "📦 Installing packages: $packages"
    if ! $SUDO apt-get install -y $packages; then
        echo "⚠️ WARNING: Failed to install packages: $packages" >> "$LOG_FILE"
        echo "You may need to install them manually." >> "$LOG_FILE"
    fi
}

# =============================================================================
<<<<<<< Updated upstream
# Enable multiarch & update system
# =============================================================================
echo "🔄 Updating system packages..."
=======
# Update system and enable multiarch
# =============================================================================
echo "🔄 Updating system packages and enabling multiarch..."
>>>>>>> Stashed changes
$SUDO dpkg --add-architecture i386 || true
$SUDO apt-get update -y
$SUDO apt-get upgrade -y

<<<<<<< Updated upstream
# =============================================================================
# Install core packages for build environment
# =============================================================================
apt_install \
    locales python3 python3-venv python3-pip python3-setuptools python-wheel-common \
    curl gnupg git sudo lzip tar unzip xz-utils pkg-config clang lld \
    autoconf autogen automake autopoint bison flex g++ g++-multilib gawk gettext \
    gperf intltool libglib2.0-dev libltdl-dev libtool-bin m4 scons \
    libwxgtk3.0-gtk3-dev libncurses5-dev lua5.2 lua5.3 lua5.4 lua-lpeg lua-mpack \
    ruby ruby-dev ruby-full php php-xml composer openjdk-17-jdk openjdk-21-jdk \
    texlive-extra-utils texlive-metapost texinfo docbook-utils \
    jq libicu-dev libc6-dev:i386 libstdc++6:i386

# =============================================================================
# Source helper scripts
# =============================================================================
echo "🔹 Sourcing helper scripts..."
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
for script in Core.sh Env.sh Lib.sh Tools.sh utilities.sh; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        source "$SCRIPT_DIR/$script"
        echo "✅ Sourced $script"
    else
        echo "⚠️ WARNING: Helper script not found: $script"
    fi
done
=======
# Install essential build dependencies
apt_install curl wget tar gzip bzip2 xz-utils lzip unzip git proot qemu-user-static build-essential

# =============================================================================
# PRoot rootfs setup (Ubuntu 22.04 minimal)
# =============================================================================
ROOTFS_TAR="$PROOT_DIR/ubuntu-22.04-core.tar.gz"
ROOTFS_DIR="$PROOT_DIR/ubuntu-22.04"

if [ ! -d "$ROOTFS_DIR" ]; then
    echo "⬇️ Downloading Ubuntu 22.04 minimal rootfs..."
    curl -L -o "$ROOTFS_TAR" "https://partner-images.canonical.com/core/22.04/current/ubuntu-22.04-core-cloudimg-amd64-root.tar.gz"
    echo "📦 Extracting rootfs..."
    mkdir -p "$ROOTFS_DIR"
    tar -xzf "$ROOTFS_TAR" -C "$ROOTFS_DIR"
    echo "✅ Ubuntu 22.04 rootfs ready at $ROOTFS_DIR"
fi

export ROOTFS_DIR

# =============================================================================
# Source helper scripts (optional)
# =============================================================================
echo "🔹 Sourcing helper scripts if available..."
[ -f "./Core.sh" ] && source ./Core.sh
[ -f "./Env.sh" ] && source ./Env.sh
[ -f "./Lib.sh" ] && source ./Lib.sh
[ -f "./Tools.sh" ] && source ./Tools.sh
[ -f "./utilities.sh" ] && source ./utilities.sh
>>>>>>> Stashed changes

# =============================================================================
# Generate locale
# =============================================================================
echo "🌐 Generating locale..."
$SUDO locale-gen en_US.UTF-8
$SUDO update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# =============================================================================
<<<<<<< Updated upstream
# Final log
=======
# Final log entry
>>>>>>> Stashed changes
# =============================================================================
echo "✅ Native Unix build environment setup completed successfully at $(date)"
echo "Build directory: $BUILD_DIR"
echo "Temporary directory: $TMP_UNIX"
<<<<<<< Updated upstream
=======
echo "PRoot rootfs: $ROOTFS_DIR"
>>>>>>> Stashed changes
