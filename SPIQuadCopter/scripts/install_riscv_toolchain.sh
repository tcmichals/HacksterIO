#!/usr/bin/env bash
set -euo pipefail

# Install/update xpack RISC-V GCC toolchain (no npm required)
# Downloads directly from GitHub releases with version checking

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default install directory
DEFAULT_INSTALL_DIR="$HOME/.local/xpack-riscv"
INSTALL_DIR="${INSTALL_DIR:-${RISCV_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}}"
GITHUB_API_URL="https://api.github.com/repos/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/latest"

NON_INTERACTIVE=0
CHECK_ONLY=0
REQUESTED_TAG=""

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --yes            Non-interactive: overwrite existing installation without prompt
  --check          Check for updates only (do not install)
  --install-dir    Install to custom directory (default: $DEFAULT_INSTALL_DIR)
  --tag TAG        Install specific version (e.g. 14.2.0-3). Default: latest
  -h, --help       Show this help
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --yes)
            NON_INTERACTIVE=1; shift;;
        --check)
            CHECK_ONLY=1; shift;;
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

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)
        XPACK_ARCH="linux-x64"
        ;;
    aarch64)
        XPACK_ARCH="linux-arm64"
        ;;
    armv7l)
        XPACK_ARCH="linux-arm"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "-------------------------------------------------------"
echo "xpack RISC-V GCC Toolchain Installer"
echo "Install location: $INSTALL_DIR"
echo "Architecture: $XPACK_ARCH"
echo "-------------------------------------------------------"

# Get local installed version
LOCAL_VERSION=""
if [[ -x "${INSTALL_DIR}/bin/riscv-none-elf-gcc" ]]; then
    # Extract version like "14.2.0" from gcc output
    LOCAL_VERSION=$("${INSTALL_DIR}/bin/riscv-none-elf-gcc" --version | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1 || true)
    echo "Installed version: ${LOCAL_VERSION:-unknown}"
fi

# Fetch latest release info from GitHub
echo "Fetching latest release info from GitHub..."
RELEASE_JSON=$(curl -s "$GITHUB_API_URL")

if [ -z "$RELEASE_JSON" ]; then
    echo "Error: Could not fetch release information from GitHub."
    exit 1
fi

LATEST_TAG=$(echo "$RELEASE_JSON" | grep -m1 '"tag_name"' | cut -d '"' -f4 | sed 's/^v//' || true)
# Extract version number part (e.g., 14.2.0 from 14.2.0-3)
LATEST_VERSION=$(echo "$LATEST_TAG" | grep -oP '^\d+\.\d+\.\d+' || true)

if [ -z "$LATEST_TAG" ]; then
    echo "Error: Could not determine latest release tag."
    exit 1
fi

echo "Latest release: ${LATEST_TAG}"

# Use requested tag or latest
TARGET_TAG="${REQUESTED_TAG:-$LATEST_TAG}"
TARGET_VERSION=$(echo "$TARGET_TAG" | grep -oP '^\d+\.\d+\.\d+' || true)

# Compare versions
if [ -n "$LOCAL_VERSION" ] && [ "$LOCAL_VERSION" = "$TARGET_VERSION" ]; then
    echo ""
    echo "xpack RISC-V GCC is up to date (version: $LOCAL_VERSION)"
    exit 0
fi

if [ -n "$LOCAL_VERSION" ]; then
    echo ""
    echo "Update available: $LOCAL_VERSION -> $TARGET_TAG"
fi

# Check only mode
if [ "$CHECK_ONLY" -eq 1 ]; then
    if [ -z "$LOCAL_VERSION" ]; then
        echo "Not installed. Run without --check to install."
        exit 1
    else
        echo "To update, run: $0 --yes"
        exit 1
    fi
fi

# Build download URL
TARBALL="xpack-riscv-none-elf-gcc-${TARGET_TAG}-${XPACK_ARCH}.tar.gz"
URL="https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v${TARGET_TAG}/${TARBALL}"

echo "Archive URL: $URL"

# If already installed, confirm or remove
if [ -d "$INSTALL_DIR" ] && [ -n "$LOCAL_VERSION" ]; then
    if [ "$NON_INTERACTIVE" -eq 1 ]; then
        echo "Non-interactive: removing existing installation at $INSTALL_DIR"
        rm -rf "$INSTALL_DIR"
    else
        read -p "Delete existing installation and upgrade? (y/N): " confirm
        if [[ "$confirm" =~ ^[Yy] ]]; then
            rm -rf "$INSTALL_DIR"
        else
            echo "Aborting."
            exit 0
        fi
    fi
fi

# Download
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo ""
echo "Downloading ${TARBALL}..."
curl -L --progress-bar -o "${TMPDIR}/${TARBALL}" "${URL}"

# Extract
echo "Extracting to ${INSTALL_DIR}..."
mkdir -p "${INSTALL_DIR}"
tar -xzf "${TMPDIR}/${TARBALL}" -C "${INSTALL_DIR}" --strip-components=1

# Write version file for future checks
echo "$TARGET_TAG" > "${INSTALL_DIR}/VERSION"

# Verify
if [[ -x "${INSTALL_DIR}/bin/riscv-none-elf-gcc" ]]; then
    echo ""
    echo "=== Installation successful ==="
    "${INSTALL_DIR}/bin/riscv-none-elf-gcc" --version | head -1
    echo ""
    
    # Check if already in PATH
    if command -v riscv-none-elf-gcc &>/dev/null; then
        echo "riscv-none-elf-gcc is already in PATH"
    else
        echo "Add to your PATH by adding this line to ~/.bashrc:"
        echo ""
        echo "  export PATH=\"${INSTALL_DIR}/bin:\$PATH\""
        echo ""
        echo "Then run: source ~/.bashrc"
    fi
else
    echo "ERROR: Installation failed"
    exit 1
fi
