#!/usr/bin/env python3
"""
setup-build-sh.py - Generates per-package build.sh scripts for Unix root-packages
"""

import os
from pathlib import Path
import stat

# Base directories
BASE_DIR = Path(__file__).resolve().parent.parent.parent
ROOT_PACKAGES_DIR = BASE_DIR / "root-packages"
BUILD_SCRIPT_TEMPLATE = """#!/usr/bin/env bash
##
## build.sh - Package build script for {pkg_name}
##

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export SCRIPT_DIR

# Source core utilities
source "$SCRIPT_DIR/../../utils/setup-native-unix.sh"
source "$SCRIPT_DIR/../../utils/Unix_packages.sh"
source "$SCRIPT_DIR/../build/Unix_error_exit.sh"
source "$SCRIPT_DIR/../build/Unix_download.sh"

# Optional language/tool setup scripts
# Uncomment or add any needed
# source "$SCRIPT_DIR/../build/setup/Unix_setup_proot.sh"
# source "$SCRIPT_DIR/../build/setup/Unix_setup_python_pip.sh"

# Build steps
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

echo "✅ Package {pkg_name} built successfully."
"""

def generate_build_sh(pkg_name: str, pkg_dir: Path):
    """
    Generate build.sh for a package
    """
    build_file = pkg_dir / "build.sh"
    content = BUILD_SCRIPT_TEMPLATE.format(pkg_name=pkg_name)
    with open(build_file, "w") as f:
        f.write(content)
    # Make executable
    st = os.stat(build_file)
    os.chmod(build_file, st.st_mode | stat.S_IEXEC)
    print(f"Generated build.sh for package: {pkg_name}")

def main():
    if not ROOT_PACKAGES_DIR.exists():
        print(f"❌ Root packages directory not found: {ROOT_PACKAGES_DIR}")
        return 1

    for pkg_dir in ROOT_PACKAGES_DIR.iterdir():
        if pkg_dir.is_dir():
            pkg_name = pkg_dir.name
            generate_build_sh(pkg_name, pkg_dir)

    print("🎉 All build.sh files generated successfully.")

if __name__ == "__main__":
    exit(main() or 0)
