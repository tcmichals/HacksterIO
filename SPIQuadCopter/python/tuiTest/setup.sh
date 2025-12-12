#!/bin/bash
# Setup script for Tang9K Python TUI and BLHeli Passthrough
# This script installs all required dependencies

set -e  # Exit on error

echo "====================================================================="
echo "Tang9K Python TUI - Dependency Installation"
echo "====================================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Error: Do not run this script as root (don't use sudo)${NC}"
    echo "The script will ask for sudo password when needed."
    exit 1
fi

echo "This script will install:"
echo "  1. Python packages (textual, spidev)"
echo "  2. System package: socat (for BLHeli passthrough)"
echo "  3. Optional: Configure Chromium for ESC Configurator web app"
echo ""

# Step 1: Install Python packages
echo -e "${YELLOW}Step 1: Installing Python packages...${NC}"
if [ -f "requirements.txt" ]; then
    pip3 install -r requirements.txt
    echo -e "${GREEN}✓ Python packages installed${NC}"
else
    echo -e "${RED}Error: requirements.txt not found${NC}"
    echo "Make sure you're in the python/test directory"
    exit 1
fi
echo ""

# Step 2: Install socat (system package)
echo -e "${YELLOW}Step 2: Installing socat (system package)...${NC}"
echo "This requires sudo privileges."

if command -v socat &> /dev/null; then
    echo -e "${GREEN}✓ socat is already installed${NC}"
    socat -V | head -n 1
else
    echo "Installing socat with apt-get..."
    sudo apt-get update
    sudo apt-get install -y socat
    echo -e "${GREEN}✓ socat installed successfully${NC}"
fi
echo ""

# Step 3: Optional Chromium setup for ESC Configurator web app
echo -e "${YELLOW}Step 3: Chromium setup for ESC Configurator web app (optional)${NC}"
echo ""
echo "The ESC Configurator web app (https://esc-configurator.com/) requires:"
echo "  - Chrome or Chromium browser"
echo "  - On Linux with snap Chromium: raw-usb access"
echo ""

# Check if chromium is installed via snap
if snap list chromium &> /dev/null; then
    echo "Detected snap-installed Chromium."
    
    # Check if raw-usb is already connected
    if snap connections chromium | grep -q "raw-usb.*:raw-usb.*manual"; then
        echo -e "${GREEN}✓ Chromium raw-usb already connected${NC}"
    else
        read -p "Enable raw-usb access for Chromium? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            sudo snap connect chromium:raw-usb
            echo -e "${GREEN}✓ Chromium raw-usb access enabled${NC}"
            echo "You can now use https://esc-configurator.com/ in Chromium"
        else
            echo "Skipped Chromium setup."
            echo "To enable later, run: sudo snap connect chromium:raw-usb"
        fi
    fi
else
    echo "Chromium (snap) not detected."
    echo "If you want to use the ESC Configurator web app:"
    echo "  1. Install Chromium: sudo snap install chromium"
    echo "  2. Enable USB: sudo snap connect chromium:raw-usb"
    echo ""
    echo "Alternatively, use Chrome browser (no special setup needed)."
fi
echo ""

# Summary
echo "====================================================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "====================================================================="
echo ""
echo "Installed:"
echo "  ✓ Python packages (textual, spidev)"
echo "  ✓ socat (system utility for /dev/ttyBLH0 device)"
if snap connections chromium 2>/dev/null | grep -q "raw-usb.*:raw-usb.*manual"; then
    echo "  ✓ Chromium raw-usb access (for ESC Configurator web app)"
fi
echo ""
echo "Next steps:"
echo "  1. Connect your SPI device (e.g., /dev/spidev0.0)"
echo "  2. Run: python3 tang9k_tui.py --device /dev/spidev0.0"
echo "  3. Press 'p' to enable BLHeli passthrough mode"
echo ""
echo "For BLHeli ESC configuration:"
echo "  - Desktop apps: Use BLHeliSuite/BLHeliConfigurator with /dev/ttyBLH0"
echo "  - Web app: Use https://esc-configurator.com/ in Chrome/Chromium"
echo ""
echo "Documentation:"
echo "  - SOCAT_SETUP.md - socat and device setup"
echo "  - ESC_CONFIGURATOR_WEBAPP.md - Web app usage guide"
echo "  - BLHELI_PASSTHROUGH.md - Complete passthrough guide"
echo ""
echo "====================================================================="
