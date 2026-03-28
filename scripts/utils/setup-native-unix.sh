#!/usr/bin/env bash
##
## setup-native-unix.sh - Native Unix build environment setup (Ubuntu/Debian x86_64)
##
## Prepares environment variables, directories, logging, locale, and core utilities
##

set -euo pipefail

# =============================================================================
# Logging
# =============================================================================
LOG_FILE="/tmp/unix_build_setup.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "🛠️ Starting native Unix build setup at $(date)" > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# =============================================================================
# Root / Sudo
# =============================================================================
SUDO="sudo"
if [ "$(id -u)" = "0" ]; then
    SUDO=""
fi

# =============================================================================
# Environment Variables & Directories
# =============================================================================
UNIX_PKG_TMPDIR="${UNIX_PKG_TMPDIR:-/tmp}"
UNIX_PREFIX="${UNIX_PREFIX:-/usr/local/unix-build}"
TMP_UNIX="$UNIX_PKG_TMPDIR/unix_build"
BUILD_DIR="$UNIX_PREFIX/build"

mkdir -p "$TMP_UNIX" "$BUILD_DIR"

export UNIX_TMPDIR="$TMP_UNIX"
export UNIX_PREFIX="$UNIX_PREFIX"
export PATH="$UNIX_PREFIX/bin:$PATH"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Multiarch support
export MULTIARCH_ENABLED=true
export BUILD_ARCH="$(uname -m)"
case "$BUILD_ARCH" in
    x86_64) export BUILD_ARCH_32=i686 ;;
    aarch64) export BUILD_ARCH_32=arm ;;
    *) export BUILD_ARCH_32="$BUILD_ARCH" ;;
esac

echo "✅ Environment variables set:"
echo "   UNIX_TMPDIR=$UNIX_TMPDIR"
echo "   UNIX_PREFIX=$UNIX_PREFIX"
echo "   BUILD_DIR=$BUILD_DIR"
echo "   BUILD_ARCH=$BUILD_ARCH"
echo "   BUILD_ARCH_32=$BUILD_ARCH_32"
echo "   MULTIARCH_ENABLED=$MULTIARCH_ENABLED"

# =============================================================================
# Helper: Safe apt install
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
# Enable multiarch & update system
# =============================================================================
echo "🔄 Updating system packages..."
$SUDO dpkg --add-architecture i386 || true
$SUDO apt-get update -y
$SUDO apt-get upgrade -y

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

# =============================================================================
# Generate locale
# =============================================================================
echo "🌐 Generating locale..."
$SUDO locale-gen en_US.UTF-8
$SUDO update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# =============================================================================
# Final log
# =============================================================================
echo "✅ Native Unix build environment setup completed successfully at $(date)"
echo "Build directory: $BUILD_DIR"
echo "Temporary directory: $TMP_UNIX"
