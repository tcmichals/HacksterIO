#!/usr/bin/env bash
set -euo pipefail

# Check OSS CAD Suite version installed in project `oss-cad-suite` vs latest GitHub release

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# If OSS_CAD_INSTALL_DIR is set use it first, otherwise prefer common user-local locations, then check older ~/.tools, then fall back to project-local
if [ -n "${OSS_CAD_INSTALL_DIR:-}" ] && [ -d "${OSS_CAD_INSTALL_DIR}" ]; then
    INSTALL_DIR="$OSS_CAD_INSTALL_DIR"
elif [ -d "$HOME/.local/oss-cad-suite" ]; then
    INSTALL_DIR="$HOME/.local/oss-cad-suite"
elif [ -d "$HOME/.tools/oss-cad-suite" ]; then
    INSTALL_DIR="$HOME/.tools/oss-cad-suite"
elif [ -d "$HOME/tools" ]; then
    INSTALL_DIR="$HOME/tools"
else
    INSTALL_DIR="$PROJECT_ROOT/oss-cad-suite"
fi
GITHUB_API_URL="https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest"

if [ ! -d "$INSTALL_DIR" ]; then
    echo "No local OSS CAD Suite installation found (checked ${OSS_CAD_INSTALL_DIR:-$HOME/.local/oss-cad-suite}, $HOME/.tools/oss-cad-suite, $HOME/tools and project/oss-cad-suite)."
    echo "Run: ./scripts/install_local_tools.sh to install (default: ${OSS_CAD_INSTALL_DIR:-$HOME/.local/oss-cad-suite}) or use --install-dir to set a custom location."
    exit 2
fi

LOCAL_VERSION=""
if [ -f "$INSTALL_DIR/VERSION" ]; then
    LOCAL_VERSION=$(cat "$INSTALL_DIR/VERSION" | tr -d " \n\r")
fi

echo "Local install: $INSTALL_DIR"
if [ -n "$LOCAL_VERSION" ]; then
    echo "Local VERSION: $LOCAL_VERSION"
else
    echo "Local VERSION file not found or empty"
fi

echo "Fetching latest release info from GitHub..."
RELEASE_JSON=$(curl -s "$GITHUB_API_URL")
LATEST_TAG=$(echo "$RELEASE_JSON" | grep -m1 '"tag_name"' | cut -d '"' -f4 || true)
LATEST_URL=$(echo "$RELEASE_JSON" | grep -m1 'browser_download_url.*linux-x64' | cut -d '"' -f4 || true)

if [ -z "$LATEST_TAG" ]; then
    echo "Could not determine latest release tag from GitHub API."
    exit 3
fi

echo "Latest release: $LATEST_TAG"
if [ -n "$LATEST_URL" ]; then
    echo "Latest archive URL: $LATEST_URL"
fi

# Normalize versions by removing non-digit characters (so 2025-12-20 == 20251220)
norm() {
    echo "$1" | tr -cd '0-9'
}

NLOCAL=$(norm "$LOCAL_VERSION")
NLATEST=$(norm "$LATEST_TAG")

if [ -n "$NLOCAL" ] && [ "$NLOCAL" = "$NLATEST" ]; then
    echo "oss-cad-suite is up to date. (version: $LOCAL_VERSION / $LATEST_TAG)"
    exit 0
else
    echo "A newer OSS CAD Suite is available: $LATEST_TAG"
    echo "To update, run: ./scripts/install_local_tools.sh"
    exit 1
fi
