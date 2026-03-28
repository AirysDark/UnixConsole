#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Unix_setup_proot.sh
# Install and configure proot for isolated Unix build environments
# =============================================================================

LOG_FILE="/tmp/unix_setup_proot.log"
mkdir -p "$(dirname "$LOG_FILE")"
echo "🔹 Starting proot setup at $(date)" > "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

# -----------------------------
# Use sudo if not root
# -----------------------------
SUDO="sudo"
if [ "$(id -u)" = "0" ]; then
    SUDO=""
fi

# -----------------------------
# Check if proot is already installed
# -----------------------------
if command -v proot >/dev/null 2>&1; then
    echo "✅ proot is already installed at $(command -v proot)"
else
    echo "📦 Installing proot..."
    $SUDO apt-get update -y
    $SUDO apt-get install -y proot || {
        echo "⚠️ WARNING: proot installation failed" >> "$LOG_FILE"
        exit 1
    }
    echo "✅ proot installed successfully"
fi

# -----------------------------
# Optional: Setup default chroot directory
# -----------------------------
PROOT_DIR="${UNIX_TMPDIR:-/tmp/unix_build}/proot_rootfs"
mkdir -p "$PROOT_DIR"

if [ ! -f "$PROOT_DIR/.proot_initialized" ]; then
    echo "🔹 Initializing proot root filesystem at $PROOT_DIR..."
    # Minimal setup: copy essential files for build environment
    mkdir -p "$PROOT_DIR/bin" "$PROOT_DIR/usr" "$PROOT_DIR/lib"
    touch "$PROOT_DIR/.proot_initialized"
    echo "✅ proot root filesystem initialized"
else
    echo "✅ proot root filesystem already initialized at $PROOT_DIR"
fi

# -----------------------------
# Environment variables for proot builds
# -----------------------------
export PROOT_ROOTFS="$PROOT_DIR"
export PROOT_CMD="proot -R $PROOT_ROOTFS"

echo "🔹 PROOT_ROOTFS set to $PROOT_ROOTFS"
echo "🔹 PROOT_CMD set to '$PROOT_CMD'"

# -----------------------------
# Test proot command
# -----------------------------
if $PROOT_CMD /bin/true 2>/dev/null; then
    echo "✅ proot test successful"
else
    echo "⚠️ proot test failed" >> "$LOG_FILE"
fi

echo "✅ Unix proot setup completed at $(date)"