#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# SPI Quadcopter Development Tools Installer
# =============================================================================
# Installs all required tools for building and simulating the project:
#   - OSS CAD Suite (yosys, nextpnr, openFPGALoader)
#   - xpack RISC-V GCC toolchain
#   - Verilator (for simulation)
#
# Usage:
#   ./scripts/install_dev_tools.sh [OPTIONS]
#
# Options:
#   --all           Install all tools (default)
#   --oss-cad       Install OSS CAD Suite only
#   --riscv         Install RISC-V toolchain only
#   --verilator     Install Verilator only
#   --check         Check installed versions only
#   --yes           Non-interactive mode
#   --install-dir   Base directory for tools (default: ~/.local/tools)
# =============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default install directory
DEFAULT_INSTALL_DIR="$HOME/.local/tools"
INSTALL_DIR="${INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"

# Tool versions (updated periodically)
RISCV_VERSION="14.2.0-3"

# Flags
INSTALL_ALL=0
INSTALL_OSS_CAD=0
INSTALL_RISCV=0
INSTALL_VERILATOR=0
CHECK_ONLY=0
NON_INTERACTIVE=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Install development tools for SPI Quadcopter project.

Options:
  --all           Install all tools (default if no option specified)
  --oss-cad       Install OSS CAD Suite (yosys, nextpnr, openFPGALoader)
  --riscv         Install xpack RISC-V GCC toolchain
  --verilator     Install Verilator simulator
  --check         Check installed versions only (no install)
  --yes           Non-interactive mode (auto-confirm)
  --install-dir   Base directory for tools (default: $DEFAULT_INSTALL_DIR)
  -h, --help      Show this help

Examples:
  $0                    # Install all tools
  $0 --check            # Show what's installed
  $0 --riscv --yes      # Install RISC-V toolchain non-interactively
EOF
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --all)
            INSTALL_ALL=1; shift;;
        --oss-cad)
            INSTALL_OSS_CAD=1; shift;;
        --riscv)
            INSTALL_RISCV=1; shift;;
        --verilator)
            INSTALL_VERILATOR=1; shift;;
        --check)
            CHECK_ONLY=1; shift;;
        --yes)
            NON_INTERACTIVE=1; shift;;
        --install-dir)
            INSTALL_DIR="$2"; shift 2;;
        -h|--help)
            usage; exit 0;;
        *)
            echo "Unknown option: $1"; usage; exit 2;;
    esac
done

# Default to all if nothing specified
if [[ $INSTALL_OSS_CAD -eq 0 && $INSTALL_RISCV -eq 0 && $INSTALL_VERILATOR -eq 0 ]]; then
    INSTALL_ALL=1
fi

if [[ $INSTALL_ALL -eq 1 ]]; then
    INSTALL_OSS_CAD=1
    INSTALL_RISCV=1
    INSTALL_VERILATOR=1
fi

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64)  ARCH_SUFFIX="x64" ;;
    aarch64) ARCH_SUFFIX="arm64" ;;
    armv7l)  ARCH_SUFFIX="arm" ;;
    *)
        echo -e "${RED}Unsupported architecture: $ARCH${NC}"
        exit 1
        ;;
esac

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}  SPI Quadcopter Development Tools Installer${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
echo "Install directory: $INSTALL_DIR"
echo "Architecture: $ARCH ($ARCH_SUFFIX)"
echo ""

# -----------------------------------------------------------------------------
# Check Functions
# -----------------------------------------------------------------------------

check_oss_cad() {
    local found=0
    local version=""
    
    # Check common locations
    for dir in "$INSTALL_DIR/oss-cad-suite" "$HOME/.tools/oss-cad-suite" "$HOME/.local/oss-cad-suite"; do
        if [[ -x "$dir/bin/yosys" ]]; then
            version=$("$dir/bin/yosys" --version 2>/dev/null | head -1 || echo "unknown")
            echo -e "${GREEN}✓ OSS CAD Suite${NC}: $version"
            echo "  Location: $dir"
            found=1
            break
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        if command -v yosys &>/dev/null; then
            version=$(yosys --version 2>/dev/null | head -1 || echo "unknown")
            echo -e "${GREEN}✓ OSS CAD Suite${NC}: $version (system)"
            found=1
        else
            echo -e "${YELLOW}✗ OSS CAD Suite${NC}: Not installed"
        fi
    fi
    
    return $((1 - found))
}

check_riscv() {
    local found=0
    local version=""
    
    # Check common locations
    for dir in "$INSTALL_DIR"/xpack-riscv-none-elf-gcc-*/bin "$HOME/.local/tools"/xpack-riscv-none-elf-gcc-*/bin "$HOME/.local/xpack-riscv/bin"; do
        if [[ -x "$dir/riscv-none-elf-gcc" ]]; then
            version=$("$dir/riscv-none-elf-gcc" --version 2>/dev/null | head -1 || echo "unknown")
            echo -e "${GREEN}✓ RISC-V GCC${NC}: $version"
            echo "  Location: $dir"
            found=1
            break
        fi
    done
    
    if [[ $found -eq 0 ]]; then
        if command -v riscv-none-elf-gcc &>/dev/null; then
            version=$(riscv-none-elf-gcc --version 2>/dev/null | head -1 || echo "unknown")
            echo -e "${GREEN}✓ RISC-V GCC${NC}: $version (in PATH)"
            found=1
        elif command -v riscv32-unknown-elf-gcc &>/dev/null; then
            version=$(riscv32-unknown-elf-gcc --version 2>/dev/null | head -1 || echo "unknown")
            echo -e "${GREEN}✓ RISC-V GCC${NC}: $version (in PATH)"
            found=1
        else
            echo -e "${YELLOW}✗ RISC-V GCC${NC}: Not installed"
        fi
    fi
    
    return $((1 - found))
}

check_verilator() {
    local found=0
    local version=""
    
    if command -v verilator &>/dev/null; then
        version=$(verilator --version 2>/dev/null | head -1 || echo "unknown")
        echo -e "${GREEN}✓ Verilator${NC}: $version"
        found=1
    else
        echo -e "${YELLOW}✗ Verilator${NC}: Not installed"
    fi
    
    return $((1 - found))
}

# -----------------------------------------------------------------------------
# Install Functions
# -----------------------------------------------------------------------------

install_oss_cad() {
    echo ""
    echo -e "${BLUE}Installing OSS CAD Suite...${NC}"
    
    local OSS_DIR="$INSTALL_DIR/oss-cad-suite"
    local API_URL="https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest"
    
    # Get latest release info
    echo "Fetching latest release info..."
    local RELEASE_JSON=$(curl -s "$API_URL")
    local LATEST_TAG=$(echo "$RELEASE_JSON" | grep -m1 '"tag_name"' | cut -d '"' -f4 || true)
    local DOWNLOAD_URL=$(echo "$RELEASE_JSON" | grep -m1 "browser_download_url.*linux-${ARCH_SUFFIX}" | cut -d '"' -f4 || true)
    
    if [[ -z "$DOWNLOAD_URL" ]]; then
        echo -e "${RED}Error: Could not find download URL for linux-${ARCH_SUFFIX}${NC}"
        return 1
    fi
    
    echo "Latest release: $LATEST_TAG"
    
    # Check if already installed with same version
    if [[ -f "$OSS_DIR/VERSION" ]]; then
        local INSTALLED=$(cat "$OSS_DIR/VERSION" | tr -d " \n\r")
        if [[ "$INSTALLED" == "$LATEST_TAG" ]]; then
            echo -e "${GREEN}Already up to date ($LATEST_TAG)${NC}"
            return 0
        fi
        echo "Upgrading $INSTALLED -> $LATEST_TAG"
    fi
    
    # Confirm
    if [[ $NON_INTERACTIVE -eq 0 && -d "$OSS_DIR" ]]; then
        read -p "Replace existing installation? (y/N): " confirm
        [[ ! "$confirm" =~ ^[Yy] ]] && { echo "Skipped."; return 0; }
    fi
    
    # Download and extract
    local TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" RETURN
    
    echo "Downloading OSS CAD Suite..."
    curl -L --progress-bar -o "$TMPDIR/oss-cad-suite.tgz" "$DOWNLOAD_URL"
    
    echo "Extracting..."
    rm -rf "$OSS_DIR"
    mkdir -p "$INSTALL_DIR"
    tar -xzf "$TMPDIR/oss-cad-suite.tgz" -C "$INSTALL_DIR"
    
    # Write version file
    echo "$LATEST_TAG" > "$OSS_DIR/VERSION"
    
    echo -e "${GREEN}OSS CAD Suite installed successfully${NC}"
}

install_riscv() {
    echo ""
    echo -e "${BLUE}Installing xpack RISC-V GCC toolchain...${NC}"
    
    local RISCV_DIR="$INSTALL_DIR/xpack-riscv-none-elf-gcc-${RISCV_VERSION}"
    local API_URL="https://api.github.com/repos/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/latest"
    
    # Get latest release info
    echo "Fetching latest release info..."
    local RELEASE_JSON=$(curl -s "$API_URL")
    local LATEST_TAG=$(echo "$RELEASE_JSON" | grep -m1 '"tag_name"' | cut -d '"' -f4 | sed 's/^v//' || true)
    
    if [[ -z "$LATEST_TAG" ]]; then
        echo -e "${RED}Error: Could not fetch release info${NC}"
        return 1
    fi
    
    local TARBALL="xpack-riscv-none-elf-gcc-${LATEST_TAG}-linux-${ARCH_SUFFIX}.tar.gz"
    local DOWNLOAD_URL="https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v${LATEST_TAG}/${TARBALL}"
    local TARGET_DIR="$INSTALL_DIR/xpack-riscv-none-elf-gcc-${LATEST_TAG}"
    
    echo "Latest release: $LATEST_TAG"
    
    # Check if already installed
    if [[ -x "$TARGET_DIR/bin/riscv-none-elf-gcc" ]]; then
        echo -e "${GREEN}Already installed ($LATEST_TAG)${NC}"
        return 0
    fi
    
    # Download and extract
    local TMPDIR=$(mktemp -d)
    trap "rm -rf $TMPDIR" RETURN
    
    echo "Downloading RISC-V toolchain..."
    curl -L --progress-bar -o "$TMPDIR/$TARBALL" "$DOWNLOAD_URL"
    
    echo "Extracting..."
    mkdir -p "$TARGET_DIR"
    tar -xzf "$TMPDIR/$TARBALL" -C "$TARGET_DIR" --strip-components=1
    
    echo -e "${GREEN}RISC-V toolchain installed successfully${NC}"
}

install_verilator() {
    echo ""
    echo -e "${BLUE}Installing Verilator...${NC}"
    
    # Verilator is best installed via package manager
    if command -v verilator &>/dev/null; then
        local version=$(verilator --version 2>/dev/null | head -1)
        echo -e "${GREEN}Verilator already installed: $version${NC}"
        return 0
    fi
    
    # Detect package manager and install
    if command -v apt &>/dev/null; then
        echo "Installing via apt..."
        if [[ $NON_INTERACTIVE -eq 1 ]]; then
            sudo apt update && sudo apt install -y verilator
        else
            sudo apt update && sudo apt install verilator
        fi
    elif command -v dnf &>/dev/null; then
        echo "Installing via dnf..."
        sudo dnf install -y verilator
    elif command -v pacman &>/dev/null; then
        echo "Installing via pacman..."
        sudo pacman -S --noconfirm verilator
    elif command -v brew &>/dev/null; then
        echo "Installing via homebrew..."
        brew install verilator
    else
        echo -e "${YELLOW}No supported package manager found.${NC}"
        echo "Please install Verilator manually:"
        echo "  - Ubuntu/Debian: sudo apt install verilator"
        echo "  - Fedora: sudo dnf install verilator"
        echo "  - Arch: sudo pacman -S verilator"
        echo "  - macOS: brew install verilator"
        echo "  - From source: https://verilator.org/guide/latest/install.html"
        return 1
    fi
    
    echo -e "${GREEN}Verilator installed successfully${NC}"
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

echo -e "${BLUE}Checking installed tools...${NC}"
echo ""
check_oss_cad || true
check_riscv || true
check_verilator || true
echo ""

if [[ $CHECK_ONLY -eq 1 ]]; then
    exit 0
fi

# Install requested tools
mkdir -p "$INSTALL_DIR"

if [[ $INSTALL_OSS_CAD -eq 1 ]]; then
    install_oss_cad
fi

if [[ $INSTALL_RISCV -eq 1 ]]; then
    install_riscv
fi

if [[ $INSTALL_VERILATOR -eq 1 ]]; then
    install_verilator
fi

# Final summary
echo ""
echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}  Installation Complete${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
check_oss_cad || true
check_riscv || true
check_verilator || true
echo ""

# PATH setup instructions
echo -e "${YELLOW}To use these tools, add to your ~/.bashrc:${NC}"
echo ""
echo "  # OSS CAD Suite"
echo "  export PATH=\"$INSTALL_DIR/oss-cad-suite/bin:\$PATH\""
echo ""
echo "  # RISC-V toolchain"
echo "  export PATH=\"\$(ls -d $INSTALL_DIR/xpack-riscv-none-elf-gcc-*/bin 2>/dev/null | tail -1):\$PATH\""
echo ""
echo "Then run: source ~/.bashrc"
echo ""
