#!/usr/bin/env bash
##
## build.sh - Unix-native package build orchestrator
##
## This script initializes the environment, fetches sources, and runs package builds
##

set -euo pipefail

# ----------------------------
# Environment Setup
# ----------------------------
: "${TMPDIR:=/tmp}"
export TMPDIR

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SCRIPT_DIR

# Root output/build directories
OUTPUT_DIR="${SCRIPT_DIR}/output"
SRC_DIR="${TMPDIR}/unix_sources"
mkdir -p "$OUTPUT_DIR" "$SRC_DIR"

# ----------------------------
# Load Core Environment & Utilities
# ----------------------------
source "$SCRIPT_DIR/scripts/utils/setup-native-unix.sh"
source "$SCRIPT_DIR/scripts/utils/Unix_packages.sh"

source "$SCRIPT_DIR/scripts/build/Unix_error_exit.sh"
source "$SCRIPT_DIR/scripts/build/Unix_download.sh"

# ----------------------------
# Load Optional Language / Tool Setup Scripts
# Only load scripts required for your packages
# ----------------------------
SETUP_SCRIPTS=(
    "Unix_setup_proot.sh"
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

# ----------------------------
# Load Build Step Utilities
# ----------------------------
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

# ----------------------------
# Load properties
# ----------------------------
[ -f "$SCRIPT_DIR/scripts/properties.sh" ] && source "$SCRIPT_DIR/scripts/properties.sh"

# ----------------------------
# Generate per-package build.sh (optional helper)
# ----------------------------
generate_package_build_sh() {
    local pkg_name="$1"
    local pkg_dir="$OUTPUT_DIR/$pkg_name"
    mkdir -p "$pkg_dir"

    cat > "$pkg_dir/build.sh" <<EOL
#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../scripts/utils/setup-native-unix.sh"
source "$SCRIPT_DIR/../../scripts/utils/Unix_packages.sh"
EOL

    for script in "${SETUP_SCRIPTS[@]}"; do
        echo "source \"$SCRIPT_DIR/../../scripts/build/setup/$script\"" >> "$pkg_dir/build.sh"
    done
    for script in "${BUILD_STEP_SCRIPTS[@]}"; do
        echo "source \"$SCRIPT_DIR/../../scripts/build/$script\"" >> "$pkg_dir/build.sh"
    done

    cat >> "$pkg_dir/build.sh" <<EOL

# Main build
echo "🔹 Building package: $pkg_name"
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
echo "✅ Finished building package: $pkg_name"
EOL

    chmod +x "$pkg_dir/build.sh"
    echo "Generated build.sh for package: $pkg_name"
}

# ----------------------------
# Build Loop
# ----------------------------
if [ "$#" -eq 0 ]; then
    echo "❌ No packages specified. Provide package names as arguments."
    echo "Available packages:"
    unix_list_packages
    exit 1
fi

for pkg in "$@"; do
    echo "🛠️ Preparing build for package: $pkg"

    # Generate package-specific build.sh
    generate_package_build_sh "$pkg"

    # Run the package build
    "$OUTPUT_DIR/$pkg/build.sh"
done

echo "🎉 All requested packages built successfully."