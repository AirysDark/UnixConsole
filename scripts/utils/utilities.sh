#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# utilities.sh — Documentation & Build Utilities for Unix_* package builds
# =============================================================================

# -----------------------------
# Helper function: safe apt install
# -----------------------------
apt_install() {
    packages="$*"
    echo "🔹 Installing documentation/build utilities: $packages"
    if ! sudo apt-get install -y $packages; then
        echo "⚠️ WARNING: Failed to install packages: $packages"
        echo "You may need to install them manually."
    fi
}

# -----------------------------
# Documentation utilities
# -----------------------------
apt_install texinfo docbook-utils texlive-* doxygen jq lzip xz-utils tar gzip

# -----------------------------
# Optional modern build systems
# -----------------------------
apt_install scons meson ninja || true

# -----------------------------
# Optional isolation tools (commented for native Linux)
# -----------------------------
# sudo apt-get install -y proot      # For isolated chroot-like builds
# sudo apt-get install -y docker.io  # For fully isolated reproducible builds

# -----------------------------
# Summary
# -----------------------------
echo "✅ Documentation and build utilities installed successfully"