#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# tools.sh — Compilers & Build Tools for Unix_* package builds
# =============================================================================

# -----------------------------
# Helper function: safe apt install
# -----------------------------
apt_install() {
    packages="$*"
    echo "🔹 Installing compilers/build tools: $packages"
    if ! sudo apt-get install -y $packages; then
        echo "⚠️ WARNING: Failed to install packages: $packages"
        echo "You may need to install them manually."
    fi
}

# -----------------------------
# Core C/C++ Build Tools
# -----------------------------
apt_install clang gcc g++ g++-multilib lld make ninja cmake pkg-config

# -----------------------------
# Autotools / Build Utilities
# -----------------------------
apt_install autoconf automake libtool-bin autopoint gettext

# -----------------------------
# Python
# -----------------------------
apt_install python3 python3-venv python3-pip python3-setuptools python3-wheel

# -----------------------------
# Ruby
# -----------------------------
apt_install ruby ruby-dev ruby-full

# -----------------------------
# Lua
# -----------------------------
apt_install lua5.2 lua5.3 lua5.4 lua-lpeg lua-mpack

# -----------------------------
# PHP
# -----------------------------
apt_install php php-xml composer

# -----------------------------
# Java
# -----------------------------
apt_install openjdk-17-jdk openjdk-21-jdk

# -----------------------------
# Rust
# -----------------------------
apt_install rustc cargo

# -----------------------------
# Go
# -----------------------------
apt_install golang

# -----------------------------
# Swift (optional)
# -----------------------------
apt_install swift || true

# -----------------------------
# Crystal (optional)
# -----------------------------
apt_install crystal || true

# -----------------------------
# Haskell / GHC
# -----------------------------
apt_install ghc cabal-install

# -----------------------------
# Flang / LLVM (optional)
# -----------------------------
apt_install flang || true

# -----------------------------
# Zig
# -----------------------------
apt_install zig

# -----------------------------
# Node.js / JavaScript tools
# -----------------------------
apt_install nodejs npm yarn

# -----------------------------
# Summary
# -----------------------------
echo "✅ Compiler and build tools installed successfully"