#!/usr/bin/env bash
set -euo pipefail

# install_local_tools.sh
# Downloads the OSS CAD Suite prebuilt release from GitHub and installs it
# into the user-local tools directory (default: $HOME/.local/oss-cad-suite) or a custom directory if provided.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# Default install directory: follow XDG/user conventions under ~/.local
DEFAULT_INSTALL_DIR="$HOME/.local/oss-cad-suite"
# Allow environment override: OSS_CAD_INSTALL_DIR, or CLI (--install-dir)
INSTALL_DIR="${INSTALL_DIR:-${OSS_CAD_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}}"
GITHUB_API_URL_LATEST="https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest"
GITHUB_API_URL_TAG="https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/tags"

NON_INTERACTIVE=0
REQUESTED_TAG=""

usage() {
    cat <<EOF
Usage: $0 [--yes] [--install-dir DIR] [--tag TAG]

Options:
  --yes            Non-interactive: overwrite existing installation without prompt
  --install-dir    Install into a custom directory (default: $DEFAULT_INSTALL_DIR). You can also set OSS_CAD_INSTALL_DIR env var to override the default.
  --tag TAG        Install a specific release tag (e.g. 2025-12-20). By default uses latest.
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes)
            NON_INTERACTIVE=1; shift;;
        --install-dir)
            INSTALL_DIR="$2"; shift 2;;
        --tag)
            REQUESTED_TAG="$2"; shift 2;;
        -h|--help)
            usage; exit 0;;
        *)
            echo "Unknown option: $1"; usage; exit 2;;
    esac
done

echo "-------------------------------------------------------"
echo "OSS CAD Suite Local Installer"
echo "Install location: $INSTALL_DIR"
echo "(default can be overridden with --install-dir $DEFAULT_INSTALL_DIR or --install-dir <path>)"
echo "-------------------------------------------------------"

# Determine release JSON URL
if [ -n "$REQUESTED_TAG" ]; then
    API_URL="$GITHUB_API_URL_TAG/$REQUESTED_TAG"
else
    API_URL="$GITHUB_API_URL_LATEST"
fi

echo "Fetching release information from GitHub..."
RELEASE_JSON=$(curl -s "$API_URL")

if [ -z "$RELEASE_JSON" ]; then
    echo "Error: Could not fetch release information from GitHub."
    exit 1
fi

LATEST_URL=$(echo "$RELEASE_JSON" | grep -m1 'browser_download_url.*linux-x64' | cut -d '"' -f4 || true)
LATEST_TAG=$(echo "$RELEASE_JSON" | grep -m1 '"tag_name"' | cut -d '"' -f4 || true)

if [ -z "$LATEST_URL" ]; then
    echo "Error: Could not determine a download URL for a linux-x64 tarball from the release metadata."
    exit 1
fi

echo "Detected release: ${LATEST_TAG:-(unknown)}"
echo "Archive URL: $LATEST_URL"

# Prepare tmp paths
TMP_ARCHIVE="/tmp/oss-cad-$$.tgz"
TMP_DIR="/tmp/oss-cad-install-$$"

# If already installed, confirm or remove
if [ -d "$INSTALL_DIR" ]; then
    if [ "$NON_INTERACTIVE" -eq 1 ]; then
        echo "Non-interactive: removing existing installation at $INSTALL_DIR"
        rm -rf "$INSTALL_DIR"
    else
        read -p "Existing installation found at $INSTALL_DIR. Delete and reinstall? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy] ]]; then
            rm -rf "$INSTALL_DIR"
        else
            echo "Aborting."
            exit 0
        fi
    fi
fi

echo "Downloading OSS CAD Suite archive..."
curl -L "$LATEST_URL" -o "$TMP_ARCHIVE"

echo "Extracting archive..."
mkdir -p "$TMP_DIR"
tar -xzf "$TMP_ARCHIVE" -C "$TMP_DIR"

# Move the extracted top-level directory to install location
EXTRACTED_DIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1 || true)
if [ -z "$EXTRACTED_DIR" ]; then
    echo "Error: extracted directory not found"
    rm -rf "$TMP_DIR" "$TMP_ARCHIVE"
    exit 1
fi

mkdir -p "$(dirname "$INSTALL_DIR")"
mv "$EXTRACTED_DIR" "$INSTALL_DIR"

echo "Cleaning up temporary files..."
rm -rf "$TMP_DIR" "$TMP_ARCHIVE"
sync

echo "==========================================================="
echo "SUCCESS: OSS CAD Suite installed at:"
echo "$INSTALL_DIR"
echo ""
echo "To activate the environment in your current shell, run:"
echo "  source $INSTALL_DIR/environment"
echo ""
echo "To add it to your PATH permanently, add this to your .bashrc:" 
echo "  export PATH=\"$INSTALL_DIR/bin:\$PATH\"" 
echo "If you installed into a different directory (for example: $OSS_CAD_INSTALL_DIR, $HOME/.tools/oss-cad-suite or $HOME/tools or $PROJECT_ROOT/oss-cad-suite), add that directory's bin to your PATH instead."
echo "==========================================================="
