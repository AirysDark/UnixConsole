#!/usr/bin/env bash
##
## Unix_error_exit.sh - Error handling utility for Unix_* builds
##

set -euo pipefail

# -----------------------------------------------------------------------------
# Global log file for build errors (can be overridden)
# -----------------------------------------------------------------------------
: "${UNIX_BUILD_LOG:="/tmp/unix_build.log"}"

# -----------------------------------------------------------------------------
# Function: unix_error_exit
# Description:
#   Print an error message to stderr, log it, and exit with a non-zero status.
# Usage:
#   unix_error_exit "Failed to build package XYZ" 1
# -----------------------------------------------------------------------------
unix_error_exit() {
    local message="${1:-Unknown error occurred}"
    local exit_code="${2:-1}"

    # Timestamp for logging
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Print to stderr
    echo "❌ [ERROR] [$timestamp] $message" >&2

    # Append to build log
    if [[ -n "$UNIX_BUILD_LOG" ]]; then
        mkdir -p "$(dirname "$UNIX_BUILD_LOG")"
        echo "[ERROR] [$timestamp] $message" >> "$UNIX_BUILD_LOG"
    fi

    # Exit with specified code
    exit "$exit_code"
}

# -----------------------------------------------------------------------------
# Function: unix_warn
# Description:
#   Print a warning message to stderr and log it, but do NOT exit.
# Usage:
#   unix_warn "Package XYZ failed to download, continuing..."
# -----------------------------------------------------------------------------
unix_warn() {
    local message="${1:-Warning issued}"
    local timestamp
    timestamp=$(date +"%Y-%m-%d %H:%M:%S")

    # Print to stderr
    echo "⚠️ [WARN] [$timestamp] $message" >&2

    # Append to build log
    if [[ -n "$UNIX_BUILD_LOG" ]]; then
        echo "[WARN] [$timestamp] $message" >> "$UNIX_BUILD_LOG"
    fi
}

# -----------------------------------------------------------------------------
# Trap function to catch any unhandled errors
# -----------------------------------------------------------------------------
_unix_trap_error() {
    local exit_code=$?
    local line_no=$1
    local script_name="${BASH_SOURCE[1]}"
    unix_error_exit "Script $script_name exited unexpectedly at line $line_no with exit code $exit_code" "$exit_code"
}

# Set trap for ERR signal
trap '_unix_trap_error $LINENO' ERR

# -----------------------------------------------------------------------------
# Optional: Print a banner when sourced
# -----------------------------------------------------------------------------
echo "🛡️ Unix error handling enabled. Logging to: $UNIX_BUILD_LOG"