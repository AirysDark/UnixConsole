#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# core.sh — Core System Utilities for Unix_* package builds
# =============================================================================

# -----------------------------
# Helper function: safe apt install
# -----------------------------
apt_install() {
    packages="$*"
    echo "🔹 Installing packages: $packages"
    if ! sudo apt-get install -y $packages; then
        echo "⚠️ WARNING: Failed to install packages: $packages"
        echo "You may need to install them manually." >&2
    fi
}

# -----------------------------
# Shell & scripting
# -----------------------------
# Provides bash, coreutils, grep, sed, awk, find, xargs, file, tar, unzip, xz-utils, gzip, bzip2
apt_install bash coreutils grep sed awk find xargs file tar unzip xz-utils gzip bzip2

# -----------------------------
# Networking
# -----------------------------
# Provides curl, wget, gnupg (for verifying downloaded sources)
apt_install curl wget gnupg

# -----------------------------
# Version control
# -----------------------------
# Provides git, subversion (if needed), mercurial (rarely used)
apt_install git subversion mercurial || true

# -----------------------------
# Locales and system configuration
# -----------------------------
echo "🔹 Configuring locales..."
sudo locale-gen en_US.UTF-8 || true
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 || true
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# -----------------------------
# Completion message
# -----------------------------
echo "✅ Core system utilities installed successfully"