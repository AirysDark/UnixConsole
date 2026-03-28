#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# properties.sh - Global variables and metadata for Unix_* build system
# =============================================================================

# -----------------------------
# Directories
# -----------------------------
export UNIX_TMPDIR="${UNIX_TMPDIR:-/tmp/unix_build}"        # Temporary build/storage/log directory
export UNIX_PREFIX="${UNIX_PREFIX:-/usr/local/unix-build}" # Installation prefix for built packages
export UNIX_BUILD_DIR="${UNIX_PREFIX}/build"               # Main build output directory
export UNIX_OUTPUT_DIR="${UNIX_PREFIX}/output"             # Final package output directory
export UNIX_CACHE_DIR="${UNIX_TMPDIR}/cache"               # Cache for downloaded sources
export UNIX_LOG_DIR="${UNIX_TMPDIR}/logs"                  # Logs
export UNIX_SRC_DIR="${UNIX_TMPDIR}/src"                   # Extracted sources
export UNIX_DEPS_DIR="${UNIX_TMPDIR}/deps"                 # Dependency build directory

# -----------------------------
# Architecture
# -----------------------------
export BUILD_ARCH="${BUILD_ARCH:-$(uname -m)}"             # Host architecture
case "$BUILD_ARCH" in
    x86_64) export BUILD_ARCH_32="i686";;
    aarch64) export BUILD_ARCH_32="arm";;
    *) export BUILD_ARCH_32="$BUILD_ARCH";;
esac
export MULTIARCH_ENABLED="${MULTIARCH_ENABLED:-true}"      # Enable 32-bit multilib builds

# -----------------------------
# Build options
# -----------------------------
export UNIX_DEBUG_BUILD="${UNIX_DEBUG_BUILD:-false}"       # Build with debug symbols
export UNIX_FORCE_BUILD="${UNIX_FORCE_BUILD:-false}"       # Force rebuild even if cached
export UNIX_CONTINUE_BUILD="${UNIX_CONTINUE_BUILD:-false}" # Continue from previous incomplete build
export UNIX_SKIP_DEPCHECK="${UNIX_SKIP_DEPCHECK:-false}"   # Skip dependency checks

# -----------------------------
# Package metadata
# -----------------------------
export UNIX_REPO_JSON="${UNIX_PREFIX}/repo.json"           # Repo metadata file
export UNIX_PKG_FORMAT="${UNIX_PKG_FORMAT:-deb}"           # Package format: deb or pacman
export UNIX_PKG_LIBRARY="${UNIX_PKG_LIBRARY:-glibc}"      # Library target: glibc or bionic (Linux only glibc)

# -----------------------------
# Logging
# -----------------------------
export UNIX_BUILD_LOG="${UNIX_LOG_DIR}/unix_build.log"    # Main build log
mkdir -p "$UNIX_LOG_DIR"
touch "$UNIX_BUILD_LOG"

# -----------------------------
# Temporary files for tracking built packages
# -----------------------------
export UNIX_BUILT_PACKAGES_FILE="${UNIX_TMPDIR}/built-packages.txt"
export UNIX_BUILDING_PACKAGES_FILE="${UNIX_TMPDIR}/building-packages.txt"
touch "$UNIX_BUILT_PACKAGES_FILE"
touch "$UNIX_BUILDING_PACKAGES_FILE"

# -----------------------------
# System information
# -----------------------------
export HOST_OS="$(uname -s)"                               # Host operating system
export HOST_KERNEL="$(uname -r)"                           # Kernel version
export HOST_PROCESSOR="$(uname -p)"                        # Processor
export HOST_NUM_CPUS="$(nproc)"                             # Number of CPUs
export HOST_USER="$(whoami)"                                # Current user

# -----------------------------
# Miscellaneous environment
# -----------------------------
export PATH="$UNIX_PREFIX/bin:$PATH"
export LANG="${LANG:-en_US.UTF-8}"
export LC_ALL="${LC_ALL:-en_US.UTF-8}"

# -----------------------------
# Debug output
# -----------------------------
echo "✅ Unix_* properties loaded:"
echo "   UNIX_TMPDIR=$UNIX_TMPDIR"
echo "   UNIX_PREFIX=$UNIX_PREFIX"
echo "   UNIX_BUILD_DIR=$UNIX_BUILD_DIR"
echo "   UNIX_OUTPUT_DIR=$UNIX_OUTPUT_DIR"
echo "   BUILD_ARCH=$BUILD_ARCH"
echo "   BUILD_ARCH_32=$BUILD_ARCH_32"
echo "   MULTIARCH_ENABLED=$MULTIARCH_ENABLED"
echo "   UNIX_PKG_FORMAT=$UNIX_PKG_FORMAT"
echo "   UNIX_PKG_LIBRARY=$UNIX_PKG_LIBRARY"
echo "   HOST_OS=$HOST_OS"
echo "   HOST_KERNEL=$HOST_KERNEL"
echo "   HOST_PROCESSOR=$HOST_PROCESSOR"
echo "   HOST_NUM_CPUS=$HOST_NUM_CPUS"
echo "   HOST_USER=$HOST_USER"