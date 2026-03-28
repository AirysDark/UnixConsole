#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# env.sh — Environment Variables for Unix_* package builds
# =============================================================================

# -----------------------------
# Temporary storage for sources, builds, and logs
# -----------------------------
export UNIX_TMPDIR="/tmp/unix_build"

# -----------------------------
# Prefix for installed packages and build tools
# -----------------------------
export UNIX_PREFIX="/usr/local/unix-build"

# -----------------------------
# Update PATH to include local Unix build binaries
# -----------------------------
export PATH="$UNIX_PREFIX/bin:$PATH"

# -----------------------------
# Locale configuration
# -----------------------------
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# -----------------------------
# Build architecture
# -----------------------------
export BUILD_ARCH="$(uname -m)"       # Current architecture
export BUILD_ARCH_32="i686"          # 32-bit counterpart for x86_64 builds
export MULTIARCH_ENABLED=true         # Flag for multilib-aware build scripts

# -----------------------------
# Display environment summary
# -----------------------------
echo "✅ Environment variables set:"
echo "   UNIX_TMPDIR=$UNIX_TMPDIR"
echo "   UNIX_PREFIX=$UNIX_PREFIX"
echo "   PATH=$PATH"
echo "   LANG=$LANG"
echo "   LC_ALL=$LC_ALL"
echo "   BUILD_ARCH=$BUILD_ARCH"
echo "   BUILD_ARCH_32=$BUILD_ARCH_32"
echo "   MULTIARCH_ENABLED=$MULTIARCH_ENABLED"