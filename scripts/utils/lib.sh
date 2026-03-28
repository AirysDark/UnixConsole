#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# lib.sh — Libraries & Development Headers for Unix_* package builds
# =============================================================================

# -----------------------------
# Helper function: safe apt install
# -----------------------------
apt_install() {
    packages="$*"
    echo "🔹 Installing libraries/development headers: $packages"
    if ! sudo apt-get install -y $packages; then
        echo "⚠️ WARNING: Failed to install libraries: $packages"
        echo "You may need to install them manually."
    fi
}

# -----------------------------
# Install required libraries and headers
# -----------------------------
apt_install \
    libc6-dev libstdc++6-dev libglib2.0-dev libltdl-dev libncurses5-dev \
    libwxgtk3.0-gtk3-dev libicu-dev libffi-dev libxml2-dev libxslt-dev \
    libc6-dev:i386 libstdc++6:i386

# -----------------------------
# Summary
# -----------------------------
echo "✅ Libraries and development headers installed successfully"