#!/usr/bin/env python3
import os

# -----------------------------
# Root of your Unix build scripts project
# -----------------------------
PROJECT_ROOT = os.path.abspath(".")  # change if needed

# -----------------------------
# List of scripts to delete
# -----------------------------
REMOVE_FILES = [
    # Setup scripts not needed
    "scripts/build/setup/Unix_setup_capnp.sh",
    "scripts/build/setup/Unix_setup_crystal.sh",
    "scripts/build/setup/Unix_setup_dotnet.sh",
    "scripts/build/setup/Unix_setup_flang.sh",
    "scripts/build/setup/Unix_setup_ghc_iserv.sh",
    "scripts/build/setup/Unix_setup_jailbreak_cabal.sh",
    "scripts/build/setup/Unix_setup_gir.sh",
    "scripts/build/setup/Unix_setup_gn.sh",
    "scripts/build/setup/Unix_setup_ldc.sh",
    "scripts/build/setup/Unix_setup_no_integrated_as.sh",
    "scripts/build/setup/Unix_setup_build_python.sh",
    "scripts/build/setup/Unix_setup_swift.sh",
    "scripts/build/setup/Unix_setup_xmake.sh",
    "scripts/build/setup/Unix_setup_zig.sh",
    "scripts/build/setup/Unix_setup_ninja.sh",
    "scripts/build/setup/Unix_setup_meson.sh",
    "scripts/build/setup/Unix_setup_cmake.sh",
    "scripts/build/setup/Unix_setup_protobuf.sh",
    "scripts/build/setup/Unix_setup_treesitter.sh",
    "scripts/build/Unix_step_setup_cgct_environment.sh",

    # Packaging / massage / deb / pacman scripts
    "scripts/build/Unix_step_install_pacman_hooks.sh",
    "scripts/build/Unix_step_install_service_scripts.sh",
    "scripts/build/Unix_step_install_license.sh",
    "scripts/build/Unix_step_copy_into_massagedir.sh",
    "scripts/build/Unix_step_create_subpkg_debscripts.sh",
    "scripts/build/Unix_create_debian_subpackages.sh",
    "scripts/build/Unix_create_pacman_subpackages.sh",
    "scripts/build/Unix_step_massage.sh",
    "scripts/build/Unix_step_strip_elf_symbols.sh",
    "scripts/build/Unix_step_elf_cleaner.sh",
    "scripts/build/Unix_step_pre_massage.sh",
    "scripts/build/Unix_step_post_massage.sh",
    "scripts/build/Unix_step_create_debscripts.sh",
    "scripts/build/Unix_step_create_python_debscripts.sh",
    "scripts/build/Unix_step_create_pacman_install_hook.sh",
    "scripts/build/Unix_step_create_debian_package.sh",
    "scripts/build/Unix_step_create_pacman_package.sh",
    "scripts/build/Unix_step_update_alternatives.sh",
    "scripts/build/Unix_step_finish_build.sh"
]

# -----------------------------
# Delete scripts
# -----------------------------
deleted_files = []
not_found_files = []

for rel_path in REMOVE_FILES:
    file_path = os.path.join(PROJECT_ROOT, rel_path)
    if os.path.isfile(file_path):
        os.remove(file_path)
        deleted_files.append(rel_path)
        print(f"Deleted: {rel_path}")
    else:
        not_found_files.append(rel_path)
        print(f"Not found (skipped): {rel_path}")

# -----------------------------
# Summary
# -----------------------------
print("\n--- Deletion Summary ---")
print(f"Deleted files: {len(deleted_files)}")
print(f"Files not found: {len(not_found_files)}")
if deleted_files:
    print("\nDeleted:")
    for f in deleted_files:
        print(f"  {f}")
if not_found_files:
    print("\nNot found:")
    for f in not_found_files:
        print(f"  {f}")

print("\n✅ Cleanup complete")