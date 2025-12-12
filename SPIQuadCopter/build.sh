#!/bin/bash
# Tang9K Build and Program Script
# This script automates the complete build and programming workflow
# 
# Prerequisites: OSS CAD Suite toolchain (yosys, nextpnr-himbaechel, gowin_pack)
# Install toolchain with: make install-tools (or make install-tools-local)

set -e  # Exit on any error

# =====================================
# Configuration
# =====================================
PROJECT_DIR="/media/tcmichals/projects/Tang9K/hacksterio/HacksterIO/SPIQuadCopter"
BUILD_DIR="$PROJECT_DIR/build"
LOG_FILE="$BUILD_DIR/build_$(date +%Y%m%d_%H%M%S).log"
COLORS_ENABLED=true

# =====================================
# Color definitions
# =====================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =====================================
# Helper Functions
# =====================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_status() {
    echo -e "${BLUE}[*] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}[!] $1${NC}"
}

log_output() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =====================================
# Step 1: Verify Prerequisites
# =====================================
step_verify_prerequisites() {
    print_header "Step 1: Verifying Prerequisites"
    
    log_output "Starting prerequisite verification"
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        print_error "Python 3 not found. Install with: apt-get install python3"
        exit 1
    fi
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    print_success "Python 3 found: $PYTHON_VERSION"
    log_output "Python version: $PYTHON_VERSION"
    
    # Check pip
    if ! command -v pip &> /dev/null; then
        print_error "pip not found. Install with: apt-get install python3-pip"
        exit 1
    fi
    print_success "pip found"
    
    # Check Make
    if ! command -v make &> /dev/null; then
        print_warning "make not found. Some targets won't work."
    else
        print_success "make found"
    fi
    
    # Check iverilog (optional)
    if command -v iverilog &> /dev/null; then
        print_success "iverilog found (for simulation)"
    else
        print_warning "iverilog not found (optional, needed for simulation)"
    fi
    
    log_output "Prerequisites verification complete"
}

# =====================================
# Step 2: Verify Toolchain
# =====================================
step_verify_toolchain() {
    print_header "Step 2: Verifying FPGA Toolchain"
    
    local missing_tools=0
    
    # Check for yosys
    if command -v yosys &> /dev/null; then
        YOSYS_VERSION=$(yosys -V 2>&1 | head -n1)
        print_success "yosys found: $YOSYS_VERSION"
        log_output "yosys version: $YOSYS_VERSION"
    else
        print_error "yosys not found"
        missing_tools=1
    fi
    
    # Check for nextpnr-himbaechel
    if command -v nextpnr-himbaechel &> /dev/null; then
        print_success "nextpnr-himbaechel found"
        log_output "nextpnr-himbaechel found"
    else
        print_error "nextpnr-himbaechel not found"
        missing_tools=1
    fi
    
    # Check for gowin_pack
    if command -v gowin_pack &> /dev/null; then
        print_success "gowin_pack found"
        log_output "gowin_pack found"
    else
        print_error "gowin_pack not found"
        missing_tools=1
    fi
    
    # Check for openFPGALoader
    if command -v openFPGALoader &> /dev/null; then
        print_success "openFPGALoader found"
        log_output "openFPGALoader found"
    else
        print_warning "openFPGALoader not found (needed for programming)"
    fi
    
    if [ $missing_tools -eq 1 ]; then
        print_error "Missing required tools. Install with: make install-tools"
        return 1
    fi
}

# =====================================
# Step 4: Syntax Check
# =====================================
step_syntax_check() {
    print_header "Step 4: Checking Verilog Syntax"
    
    cd "$PROJECT_DIR"
    
    print_status "Checking syntax of main modules..."
    log_output "Running syntax check"
    
    if command -v iverilog &> /dev/null; then
    if iverilog -g2009 -t null src/tang9k_top.sv src/pll.sv spiSlave/spi_slave.sv 2>&1 | tee -a "$LOG_FILE"; then
            print_success "Syntax check passed!"
            log_output "Syntax check: PASSED"
        else
            print_error "Syntax check failed!"
            log_output "Syntax check: FAILED"
            exit 1
        fi
    else
        print_warning "iverilog not available, skipping syntax check"
        print_warning "Install with: apt-get install iverilog"
        log_output "Syntax check skipped (iverilog not found)"
    fi
}

# =====================================
# Step 3: Verify Project Files
# =====================================
step_verify_project() {
    print_header "Step 3: Verifying Project Files"
    
    cd "$PROJECT_DIR"
    
    # Check tang9k.cst exists
    if [ ! -f "tang9k.cst" ]; then
        print_error "tang9k.cst not found!"
        exit 1
    fi
    
    print_success "Constraint file verified: tang9k.cst"
    log_output "Constraint file found: tang9k.cst"
}

# =====================================
# Step 4: Build Project
# =====================================
step_build_project() {
    print_header "Step 4: Building FPGA Design"
    
    cd "$PROJECT_DIR"
    
    print_status "Starting build using Makefile (this may take 1-3 minutes)..."
    log_output "Starting make build"
    
    if make build 2>&1 | tee -a "$LOG_FILE"; then
        print_success "Build completed successfully!"
        log_output "Build: SUCCESS"
    else
        print_error "Build failed!"
        log_output "Build: FAILED"
        print_error "Check build log: $LOG_FILE"
        exit 1
    fi
    
    # Verify bitstream generated
    if [ -f "_build/default/hardware.fs" ]; then
        BITSTREAM_SIZE=$(ls -lh "_build/default/hardware.fs" | awk '{print $5}')
        print_success "Bitstream created: $BITSTREAM_SIZE"
        log_output "Bitstream size: $BITSTREAM_SIZE"
    else
        print_error "Bitstream not generated!"
        exit 1
    fi
}

# =====================================
# Step 5: Check USB Connection
# =====================================
step_check_usb() {
    print_header "Step 5: Checking USB Connection"
    
    print_status "Scanning for USB devices..."
    
    if lsusb | grep -q -i "gowin\|tang"; then
        print_success "Tang9K found on USB!"
        lsusb | grep -i "gowin\|tang\|fpga\|usb"
        log_output "Tang9K USB device found"
    else
        print_warning "Tang9K not found on USB"
        print_warning "Checking for serial devices..."
        if ls -la /dev/ttyUSB* 2>/dev/null; then
            print_status "Serial devices found:"
            ls -la /dev/ttyUSB*
            log_output "Serial devices found"
        else
            print_error "No USB devices found!"
            print_warning "Please connect Tang9K via USB"
            log_output "USB device not found - user needs to connect board"
            return 1
        fi
    fi
    
    return 0
}

# =====================================
# Step 6: Program Device
# =====================================
step_program_device() {
    print_header "Step 6: Programming FPGA"
    
    cd "$PROJECT_DIR"
    
    # Ask for confirmation
    print_warning "This will program the Tang9K FPGA"
    read -p "Continue? (y/n) " -n 1 -r
    echo
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_status "Programming cancelled"
        log_output "Programming cancelled by user"
        return 1
    fi
    
    print_status "Starting programming process..."
    log_output "Starting make upload"
    
    if make upload 2>&1 | tee -a "$LOG_FILE"; then
        print_success "Programming completed successfully!"
        log_output "Programming: SUCCESS"
    else
        print_error "Programming failed!"
        log_output "Programming: FAILED"
        
        # Provide troubleshooting
        print_warning "Troubleshooting:"
        print_warning "1. Verify USB connection: lsusb | grep -i gowin"
        print_warning "2. Check permissions: sudo chmod 666 /dev/ttyUSB*"
        print_warning "3. Try manual upload: make upload"
        
        return 1
    fi
}

# =====================================
# Step 7: Verification
# =====================================
step_verification() {
    print_header "Step 7: Verification"
    
    print_status "Post-programming verification:"
    print_status "1. Check LED behavior:"
    print_status "   - LED0: Slow blink (~0.5 Hz)"
    print_status "   - LED1: Medium blink (~1 Hz)"
    print_status "   - LED2: Fast blink (~2 Hz)"
    print_status "   - LED3: Breathing pattern (PWM)"
    
    echo ""
    read -p "Do you see LEDs blinking? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_success "Verification PASSED!"
        log_output "Verification: PASSED - LEDs blinking correctly"
    else
        print_warning "Verification may have failed"
        print_warning "Check board connections and try again"
        log_output "Verification: FAILED or SKIPPED"
    fi
}

# =====================================
# Generate Report
# =====================================
generate_report() {
    print_header "Build Summary"
    
    echo ""
    echo "Build Information:"
    echo "  Project: Tang9K SPI Slave with LED Blinker"
    echo "  Location: $PROJECT_DIR"
    echo "  Build Log: $LOG_FILE"
    echo ""
    
    if [ -f "$BUILD_DIR/project.gw" ]; then
        echo "Build Artifacts:"
        ls -lh "$BUILD_DIR/project."* | awk '{print "  " $9 " (" $5 ")"}'
    fi
    
    echo ""
    echo "Next Steps:"
    echo "  1. Monitor LEDs on the Tang9K board"
    echo "  2. Test SPI interface with master device"
    echo "  3. Check documentation: README.md"
    echo ""
    
    log_output "Build process completed"
}

# =====================================
# Error Handler
# =====================================
error_handler() {
    print_error "Build process failed at step: $1"
    print_error "Check log file: $LOG_FILE"
    log_output "Build process FAILED at step: $1"
    exit 1
}

# =====================================
# Main Execution
# =====================================
main() {
    print_header "Tang9K FPGA Build & Program System"
    echo "Start time: $(date)"
    echo "Log file: $LOG_FILE"
    echo ""
    
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Run steps
    step_verify_prerequisites || error_handler "Prerequisites"
    echo ""
    
    step_verify_toolchain || error_handler "Toolchain Verification"
    echo ""
    
    step_syntax_check || error_handler "Syntax Check"
    echo ""
    
    step_verify_project || error_handler "Project Verification"
    echo ""
    
    step_build_project || error_handler "Build"
    echo ""
    
    step_check_usb || print_warning "USB check failed (continuing anyway)"
    echo ""
    
    step_program_device || error_handler "Programming"
    echo ""
    
    step_verification
    echo ""
    
    generate_report
    
    print_success "All steps completed!"
    echo "End time: $(date)"
}

# =====================================
# Execute Main
# =====================================
main "$@"
