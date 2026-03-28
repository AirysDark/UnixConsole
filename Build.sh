#!/usr/bin/env bash
##
## build.sh - Unix-native root-package orchestrator using PRoot
##

set -euo pipefail

# -----------------------------
# Environment Setup
<<<<<<< Updated upstream
# ----------------------------
: "${TMPDIR:=/tmp/unix_build}"
=======
# -----------------------------
: "${TMPDIR:=/tmp}"
>>>>>>> Stashed changes
export TMPDIR

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SCRIPT_DIR

<<<<<<< Updated upstream
# User-writable root build/output directories
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/unix-build/output}"
SRC_DIR="${SRC_DIR:-$TMPDIR/unix_sources}"
=======
OUTPUT_DIR="$SCRIPT_DIR/output"
SRC_DIR="$TMPDIR/unix_sources"
>>>>>>> Stashed changes
mkdir -p "$OUTPUT_DIR" "$SRC_DIR"

# -----------------------------
# Load Utilities & Package Definitions
# -----------------------------
source "$SCRIPT_DIR/scripts/utils/setup-native-unix.sh"
source "$SCRIPT_DIR/scripts/utils/Unix_packages.sh"
source "$SCRIPT_DIR/scripts/build/Unix_error_exit.sh"
source "$SCRIPT_DIR/scripts/build/Unix_download.sh"
source "$SCRIPT_DIR/scripts/build/setup/Unix_setup_proot.sh"

# -----------------------------
# Language / Tool Setup Scripts
# -----------------------------
SETUP_SCRIPTS=(
    "Unix_setup_bpc.sh"
    "Unix_setup_cargo_c.sh"
    "Unix_setup_python_pip.sh"
    "Unix_setup_nodejs.sh"
    "Unix_setup_java.sh"
    "Unix_setup_rust.sh"
    "Unix_setup_golang.sh"
)

for script in "${SETUP_SCRIPTS[@]}"; do
    [ -f "$SCRIPT_DIR/scripts/build/setup/$script" ] && source "$SCRIPT_DIR/scripts/build/setup/$script"
done

# -----------------------------
# Build Step Scripts
# -----------------------------
BUILD_STEP_SCRIPTS=(
    "Unix_step_setup_variables.sh"
    "Unix_step_handle_buildarch.sh"
    "Unix_step_create_timestamp_file.sh"
    "Unix_step_get_dependencies.sh"
    "Unix_step_get_dependencies_python.sh"
    "Unix_step_override_config_scripts.sh"
    "Unix_step_setup_build_folders.sh"
    "Unix_step_start_build.sh"
    "Unix_step_cleanup_packages.sh"
    "Unix_step_patch_package.sh"
    "Unix_step_replace_guess_scripts.sh"
    "Unix_step_configure.sh"
    "Unix_step_make.sh"
    "Unix_step_make_install.sh"
)

for script in "${BUILD_STEP_SCRIPTS[@]}"; do
    [ -f "$SCRIPT_DIR/scripts/build/$script" ] && source "$SCRIPT_DIR/scripts/build/$script"
done

# -----------------------------
# Properties
# -----------------------------
[ -f "$SCRIPT_DIR/scripts/properties.sh" ] && source "$SCRIPT_DIR/scripts/properties.sh"

# -----------------------------
# Generate per-package build.sh inside PRoot
# -----------------------------
generate_package_build_sh() {
    local pkg="$1"
    local pkg_dir="$OUTPUT_DIR/$pkg"
    mkdir -p "$pkg_dir"

    cat > "$pkg_dir/build.sh" <<EOL
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/utils/setup-native-unix.sh"
source "$SCRIPT_DIR/../../scripts/utils/Unix_packages.sh"
EOL

    for s in "${SETUP_SCRIPTS[@]}"; do
        echo "source \"$SCRIPT_DIR/../../scripts/build/setup/$s\"" >> "$pkg_dir/build.sh"
    done
    for s in "${BUILD_STEP_SCRIPTS[@]}"; do
        echo "source \"$SCRIPT_DIR/../../scripts/build/$s\"" >> "$pkg_dir/build.sh"
    done

    cat >> "$pkg_dir/build.sh" <<EOL

# Main build inside PRoot
echo "🔹 Building package: $pkg"
unix_step_setup_variables
unix_step_handle_buildarch
unix_step_create_timestamp_file
unix_step_get_dependencies
unix_step_get_dependencies_python
unix_step_override_config_scripts
unix_step_setup_build_folders
unix_step_start_build
unix_step_cleanup_packages
unix_step_patch_package
unix_step_replace_guess_scripts
unix_step_configure
unix_step_make
unix_step_make_install
echo "✅ Finished building package: $pkg"
EOL

    chmod +x "$pkg_dir/build.sh"
}

# -----------------------------
# Build Loop
# -----------------------------
if [ "$#" -eq 0 ]; then
    echo "❌ No packages specified. Available packages:"
    unix_list_packages
    exit 1
fi

for pkg in "$@"; do
    echo "🛠️ Preparing build for package: $pkg"
    generate_package_build_sh "$pkg"
    proot -R "$ROOTFS_DIR" -b /proc -b /sys -b /dev -w "$OUTPUT_DIR/$pkg" /bin/bash -c "./build.sh"
done

echo "🎉 All requested packages built successfully."
