#!/usr/bin/env bash
##
## bootstrap-unix.sh - Initialize and run the Unix build environment
##

set -euo pipefail

# =============================================================================
# Detect OS and architecture
# =============================================================================
OS_NAME=$(uname -s)
ARCH_NAME=$(uname -m)
echo "Detected OS: $OS_NAME, Architecture: $ARCH_NAME"

# =============================================================================
# Set base directories
# =============================================================================
BASE_DIR=$(pwd)
SCRIPTS_DIR="$BASE_DIR/scripts"
UTILS_DIR="$SCRIPTS_DIR/utils"
BUILD_DIR="$SCRIPTS_DIR/build"
ROOT_PACKAGES_DIR="$BASE_DIR/root-packages"
OUTPUT_DIR="$BASE_DIR/output"

export BASE_DIR SCRIPTS_DIR UTILS_DIR BUILD_DIR ROOT_PACKAGES_DIR OUTPUT_DIR

# =============================================================================
# Check for essential scripts
# =============================================================================
BOOTSTRAP_REQUIRED_SCRIPTS=(
    "$UTILS_DIR/setup-native-unix.sh"
    "$UTILS_DIR/Unix_packages.sh"
    "$BUILD_DIR/Unix_step_setup_variables.sh"
    "$BUILD_DIR/Unix_error_exit.sh"
)

for script in "${BOOTSTRAP_REQUIRED_SCRIPTS[@]}"; do
    if [[ ! -f "$script" ]]; then
        echo "ERROR: Required script missing: $script"
        exit 1
    fi
done

# =============================================================================
# Load environment setup scripts
# =============================================================================
echo "Loading utility scripts..."
source "$UTILS_DIR/setup-native-unix.sh"
source "$UTILS_DIR/Unix_packages.sh" || true

# Load build utilities (minimal)
source "$BUILD_DIR/Unix_error_exit.sh"
source "$BUILD_DIR/Unix_download.sh" || true

# Load properties
if [[ -f "$SCRIPTS_DIR/properties.sh" ]]; then
    source "$SCRIPTS_DIR/properties.sh"
fi

# =============================================================================
# Command interface
# =============================================================================
echo
echo "Unix Build Environment Initialized"
echo "Usage: $0 [command] [options]"
echo "Commands:"
echo "  build PACKAGE_NAME    Build a package"
echo "  clean PACKAGE_NAME    Clean build directory for package"
echo "  list                  List available packages"
echo

COMMAND="${1:-list}"
PACKAGE="${2:-}"

case "$COMMAND" in
    build)
        if [[ -z "$PACKAGE" ]]; then
            echo "ERROR: No package specified for build"
            exit 1
        fi

        # Check if package directory exists
        if [[ ! -d "$ROOT_PACKAGES_DIR/$PACKAGE" ]]; then
            echo "ERROR: Package '$PACKAGE' does not exist in root-packages"
            exit 1
        fi

        echo "📦 Building package: $PACKAGE"
        # Call the Unix_* build script
        "$BUILD_DIR/Unix_step_start_build.sh" "$PACKAGE"
        ;;

    clean)
        if [[ -z "$PACKAGE" ]]; then
            echo "ERROR: No package specified for clean"
            exit 1
        fi

        CLEAN_DIR="$OUTPUT_DIR/$PACKAGE"
        if [[ -d "$CLEAN_DIR" ]]; then
            echo "🧹 Cleaning package: $PACKAGE"
            rm -rf "$CLEAN_DIR"
        else
            echo "⚠️ Nothing to clean for package: $PACKAGE"
        fi
        ;;

    list)
        echo "📂 Listing all packages in root-packages directory:"
        if [[ -d "$ROOT_PACKAGES_DIR" ]]; then
            find "$ROOT_PACKAGES_DIR" -maxdepth 1 -type d -not -path "$ROOT_PACKAGES_DIR" -exec basename {} \;
        else
            echo "⚠️ root-packages directory not found."
        fi
        ;;

    *)
        echo "ERROR: Unknown command '$COMMAND'"
        exit 1
        ;;
esac

echo "✅ Bootstrap finished."