## Main Makefile - direct toolchain (yosys → nextpnr → gowin_pack)
## This uses explicit commands so the project only includes the RTL files 
## we want to synthesize.

.PHONY: help all build synth place pack upload clean simulate wave view lint submodules

TOP := tang9k_top
BUILD_DIR := _build/default

# Sources used for synthesis (exclude testbenches)
SRCS := spiSlave/spi_slave.sv src/pll.sv src/tang9k_top.sv src/coredesign.sv \
        src/spi_axis_adapter.sv \
        src/uart_passthrough_bridge.sv src/uart_rx.sv src/uart_tx.sv \
        verilog-uart/rtl/uart_rx.v verilog-uart/rtl/uart_tx.v \
        src/wb_led_controller.sv \
        pwmDecoder/pwmdecoder.v pwmDecoder/pwmdecoder_wb.v \
        dshot/dshot_out.v src/wb_dshot_controller.sv \
        verilog-wishbone/rtl/arbiter.v verilog-wishbone/rtl/axis_wb_master.v \
        verilog-wishbone/rtl/priority_encoder.v verilog-wishbone/rtl/wb_adapter.v \
        verilog-wishbone/rtl/wb_arbiter_2.v verilog-wishbone/rtl/wb_async_reg.v \
        verilog-wishbone/rtl/wb_dp_ram.v src/wb_mux_6.v \
        verilog-wishbone/rtl/wb_ram.v verilog-wishbone/rtl/wb_reg.v \
		src/wb_serial_dshot_mux.sv \
		neoPXStrip/wb_neoPx.v neoPXStrip/sendPx.v src/wb_neoPxString.sv \
		version/wb_version.sv

CST := tang9k.cst

YOSYS := yosys
NEXTPNR := nextpnr-himbaechel
GOWIN_PACK := gowin_pack
OPENFPGALOADER := openFPGALoader

# If tools installed in ~/.tools/oss-cad-suite/bin, prepend to PATH
TOOLS_BIN := $(HOME)/.tools/oss-cad-suite/bin
ifneq (,$(wildcard $(TOOLS_BIN)))
export PATH := $(TOOLS_BIN):$(PATH)
endif

YOSYS_FLAGS := -p "synth_gowin -top $(TOP) -json $(BUILD_DIR)/hardware.json"
NEXTPNR_FLAGS := --device GW1NR-LV9QN88PC6/I5 --json $(BUILD_DIR)/hardware.json \
                 --write $(BUILD_DIR)/hardware.pnr.json --report $(BUILD_DIR)/hardware.pnr \
                 --vopt family=GW1N-9C --vopt cst=$(CST)
GOWIN_PACK_FLAGS := -d GW1N-9C -o $(BUILD_DIR)/hardware.fs $(BUILD_DIR)/hardware.pnr.json

.PHONY: install-tools
install-tools: install-tools-distro

.PHONY: install-tools-local
install-tools-local:
	@echo "Installing OSS-CAD-Suite to ~/.tools/oss-cad-suite with revision number..."
	@mkdir -p ~/.tools
	@bash -c ' \
		RELEASE_DATA=$$(curl -s https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest); \
		REV=$$(echo "$$RELEASE_DATA" | grep -oP "\"tag_name\":\s*\"\K[^\"]+"); \
		URL=$$(echo "$$RELEASE_DATA" | grep "linux-x64.*tgz" | grep -oP "\"browser_download_url\":\s*\"\K[^\"]+"); \
		if [ -z "$$REV" ] || [ -z "$$URL" ]; then \
			echo "Failed to fetch release info. Check your internet connection or visit:"; \
			echo "https://github.com/YosysHQ/oss-cad-suite-build/releases"; \
			exit 1; \
		fi; \
		INSTALL_DIR="$(HOME)/.tools/oss-cad-suite-$$REV"; \
		echo "Revision: $$REV"; \
		echo "Downloading: $$URL"; \
		echo "Installing to: $$INSTALL_DIR"; \
		curl -L -o /tmp/oss-cad.tgz "$$URL" && \
		tar -xzf /tmp/oss-cad.tgz -C ~/.tools && \
		if [ -d ~/.tools/oss-cad-suite ]; then \
			mv ~/.tools/oss-cad-suite "$$INSTALL_DIR"; \
		fi && \
		ln -sfn "$$INSTALL_DIR" ~/.tools/oss-cad-suite && \
		rm /tmp/oss-cad.tgz && \
		echo "Installation complete at: $$INSTALL_DIR" && \
		echo "Symlink: ~/.tools/oss-cad-suite -> $$INSTALL_DIR"; \
	'

.PHONY: install-tools-distro
install-tools-distro:
	@echo "Install FPGA toolchain (oss-cad-suite / nextpnr / yosys) and openFPGALoader"
	@echo "This target attempts to install packages for common distros. Review output for errors."
	@if command -v apt-get >/dev/null 2>&1; then \
		echo "Detected apt (Debian/Ubuntu). Installing packages..."; \
		sudo apt-get update && sudo apt-get install -y oss-cad-suite-full openfpgaloader || echo "Apt install failed or some packages unavailable; consider adding oss-cad-suite repository as per https://github.com/YosysHQ/oss-cad-suite"; \
	elif command -v pacman >/dev/null 2>&1; then \
		echo "Detected pacman (Arch). Install yosys/nextpnr/openfpgaloader manually or use AUR packages (oss-cad-suite-bin)."; \
		echo "Suggested: sudo pacman -S --needed yosys nextpnr-gowin openfpgaloader"; \
	elif command -v brew >/dev/null 2>&1; then \
		echo "Detected Homebrew (macOS). Installing via brew..."; \
		brew install yosys nextpnr openfpgaloader || echo "brew install failed; check package names (nextpnr may be 'nextpnr' or 'nextpnr-gowin' from taps)."; \
	else \
		echo "Unknown package manager. Please install the OSS CAD toolchain and openFPGALoader manually:"; \
		echo "  - oss-cad-suite: https://github.com/YosysHQ/oss-cad-suite"; \
		echo "  - openFPGALoader: https://github.com/trabucayre/openFPGALoader"; \
		exit 1; \
	fi

.PHONY: submodules
submodules:
	@echo "Initializing and updating git submodules..."
	@git submodule update --init --recursive
	@echo "Submodules ready!"

help:
	@echo "Tang9K FPGA Project - Available Targets:"
	@echo ""
	@echo "  make submodules           - Initialize and update git submodules (run this first!)"
	@echo "  make build                - Run full build (synth + place & route + pack)"
	@echo "  make synth                - Run yosys synthesis (generates hardware.json)"
	@echo "  make place                - Run nextpnr (generates hardware.pnr.json)"
	@echo "  make pack                 - Run gowin_pack (generates hardware.fs)"
	@echo "  make upload               - Program board using openFPGALoader"
	@echo "  make simulate             - Run SPI slave simulation (delegates to spiSlave/Makefile)"
	@echo "  make test-tb              - Run all testbenches (SPI, Serial, PWM, DSHOT, Passthrough)"
	@echo "  make test-all             - Alias for test-tb"
	@echo "  make clean                - Remove build artifacts and testbench files (*.vcd, *.vvp)"
	@echo "  make lint                 - Syntax check with iverilog"
	@echo ""
	@echo "Individual testbench targets:"
	@echo "  make tb-spi               - Run SPI slave testbench"
	@echo "  make tb-tang9k            - Run tang9k_top full integration testbench"
	@echo "  make tb-wb-mux            - Run wb_serial_dshot_mux directed testbench"
	@echo "  make tb-serial            - Run TTL Serial UART testbench"
	@echo "  make tb-pwm               - Run PWM decoder testbench"
	@echo "  make tb-dshot             - Run DSHOT motor controller testbench"
	@echo "  make tb-passthrough       - Run UART passthrough bridge testbench"
	@echo "  make tb-wb-mux            - Run wb_serial_dshot_mux directed testbench"
	@echo ""
	@echo "Legacy submodule simulation commands:"
	@echo "  cd spiSlave && make simulate   - Test SPI slave module"
	@echo "  cd ttlSerial && make simulate  - Test TTL Serial UART module"
	@echo "  cd pwmDecoder && make simulate - Test PWM decoder module"
	@echo "  cd dshot && make simulate      - Test DSHOT motor controller"
	@echo "  cd src && ./run_passthrough_tb.sh - Test UART passthrough bridge"
	@echo ""
	@echo "  make install-tools        - Install tools via distro package manager (apt/pacman/brew)"
	@echo "  make install-tools-local  - Download and install OSS-CAD-Suite to ~/.tools/oss-cad-suite-<REV>"
	@echo ""
	@echo "IMPORTANT: After installing tools with 'make install-tools-local', add to ~/.bashrc:"
	@echo "  export PATH=\"$$HOME/.tools/oss-cad-suite/bin:$$PATH\""
	@echo "Then run: source ~/.bashrc"

all: build

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: synth
synth: submodules $(BUILD_DIR)
	@echo "Running yosys synthesis..."
	@if ! command -v $(YOSYS) > /dev/null; then \
		echo "Error: $(YOSYS) not found. Install yosys."; exit 1; \
	fi
	$(YOSYS) $(YOSYS_FLAGS) $(SRCS)

.PHONY: place
place: $(BUILD_DIR)/hardware.json
	@echo "Running nextpnr..."
	@if ! command -v $(NEXTPNR) > /dev/null; then \
		echo "Error: $(NEXTPNR) not found. Install nextpnr-himbaechel."; exit 1; \
	fi
	$(NEXTPNR) $(NEXTPNR_FLAGS)

$(BUILD_DIR)/hardware.json: $(SRCS) | $(BUILD_DIR)
	$(YOSYS) $(YOSYS_FLAGS) $(SRCS)

$(BUILD_DIR)/hardware.pnr.json: $(BUILD_DIR)/hardware.json | $(BUILD_DIR)
	$(NEXTPNR) $(NEXTPNR_FLAGS)

.PHONY: pack
pack: $(BUILD_DIR)/hardware.pnr.json
	@echo "Running gowin_pack..."
	@if ! command -v $(GOWIN_PACK) > /dev/null; then \
		echo "Error: $(GOWIN_PACK) not found. Install gowin_pack."; exit 1; \
	fi
	$(GOWIN_PACK) $(GOWIN_PACK_FLAGS)

.PHONY: build
build: pack
	@echo "Build finished. Bitstream: $(BUILD_DIR)/hardware.fs"

.PHONY: upload
upload: $(BUILD_DIR)/hardware.fs
	@echo "Uploading bitstream to board..."
	@if ! command -v $(OPENFPGALOADER) > /dev/null; then \
		echo "Error: $(OPENFPGALOADER) not found. Install openFPGALoader."; exit 1; \
	fi
	$(OPENFPGALOADER) -v -f $(BUILD_DIR)/hardware.fs || { echo "Upload failed"; exit 1; }

# Simulation helpers (delegate to spiSlave/Makefile)
simulate:
	@echo "Running SPI slave simulation (in spiSlave/)"
	@cd spiSlave && make simulate

# Individual testbench targets
.PHONY: tb-spi tb-serial tb-pwm tb-dshot tb-passthrough

tb-spi:
	@echo "=========================================="
	@echo "Running SPI Slave Testbench"
	@echo "=========================================="
	@cd spiSlave && $(MAKE) simulate




tb-serial:
	@echo "=========================================="
	@echo "Running TTL Serial Testbench"
	@echo "=========================================="
	@cd ttlSerial && $(MAKE) simulate

tb-pwm:
	@echo "=========================================="
	@echo "Running PWM Decoder Testbench"
	@echo "=========================================="
	@cd pwmDecoder && $(MAKE) simulate

tb-dshot:
	@echo "=========================================="
	@echo "Running DSHOT Testbench"
	@echo "=========================================="
	@cd dshot && $(MAKE) simulate

tb-passthrough:
	@echo "=========================================="
	@echo "Running UART Passthrough Bridge Testbench"
	@echo "=========================================="
	@cd src && $(MAKE) -f Makefile.passthrough_tb sim

tb-wb-mux:
	@echo "=========================================="
	@echo "Running WB Serial/DSHOT Mux Directed Testbench"
	@echo "=========================================="
	@cd src && $(MAKE) -f Makefile.wb_mux_tb sim

.PHONY: tb-design
tb-design:
	@echo "=========================================="
	@echo "Running design-focused testbench"
	@echo "=========================================="
	# Ensure generated mux exists (6-port in `src`)
	@python3 verilog-wishbone/rtl/wb_mux.py -p 6 -o src/wb_mux_6.v || true
	@iverilog -g2012 -o tb_design.vvp \
		spiSlave/spi_slave.sv src/pll.sv src/coredesign.sv src/spi_axis_adapter.sv src/wb_led_controller.sv src/wb_serial_dshot_mux.sv \
		src/uart_passthrough_bridge.sv src/uart_rx.sv src/uart_tx.sv verilog-uart/rtl/uart_rx.v verilog-uart/rtl/uart_tx.v \
		pwmDecoder/pwmdecoder_wb.v pwmDecoder/pwmdecoder.v src/wb_dshot_controller.sv dshot/dshot_out.v neoPXStrip/wb_neoPx.v neoPXStrip/sendPx.v src/wb_neoPxString.sv \
		version/wb_version.sv \
		verilog-wishbone/rtl/axis_wb_master.v verilog-wishbone/rtl/wb_reg.v \
		verilog-wishbone/rtl/wb_ram.v verilog-wishbone/rtl/wb_dp_ram.v \
		verilog-wishbone/rtl/wb_async_reg.v verilog-wishbone/rtl/wb_arbiter_2.v \
		src/wb_mux_6.v \
		verilog-wishbone/rtl/wb_adapter.v verilog-wishbone/rtl/priority_encoder.v \
		verilog-wishbone/rtl/arbiter.v \
		tb/design_tb.sv -s design_tb || exit 1
	@vvp tb_design.vvp

# Run all testbenches
.PHONY: test-tb
test-tb:
	@echo "=========================================="
	@echo "Running all testbenches"
	@echo "=========================================="
	@echo ""
	@echo "=== 1/5: SPI Slave Testbench ==="
	@cd spiSlave && $(MAKE) simulate || exit 1
	@echo ""
	@echo "=== 2/5: TTL Serial Testbench ==="
	@cd ttlSerial && $(MAKE) simulate || exit 1
	@echo ""
	@echo "=== 3/5: PWM Decoder Testbench ==="
	@cd pwmDecoder && $(MAKE) simulate || exit 1
	@echo ""
	@echo "=== 4/5: DSHOT Testbench ==="
	@cd dshot && $(MAKE) simulate || exit 1
	@echo ""
	@echo "=== 5/5: UART Passthrough Bridge Testbench ==="
	@cd src && $(MAKE) -f Makefile.passthrough_tb sim || exit 1
	@echo ""
	@echo "=========================================="
	@echo "All testbenches passed!"
	@echo "=========================================="

.PHONY: test-all
test-all: test-tb

wave:
	@cd spiSlave && make wave

view:
	@cd spiSlave && make view

lint:
	@echo "Checking Verilog syntax with iverilog..."
	@if ! command -v iverilog > /dev/null; then \
		echo "Error: iverilog not found."; exit 1; \
	fi
	iverilog -g2009 -t null src/tang9k_top.sv spiSlave/spi_slave.sv && echo "Syntax OK"

clean:
	@echo "Cleaning build artifacts..."
	@cd spiSlave && make clean || true
	@cd ttlSerial && make clean || true
	@cd pwmDecoder && make clean || true
	@cd dshot && make clean || true
	@rm -rf $(BUILD_DIR)
	@rm -rf src/build
	@echo "Cleaning testbench artifacts..."
	@find . -name "*.vcd" -delete
	@find . -name "*.vvp" -delete
	@find . -name "*.fst" -delete
	@find . -name "*.out" -delete
	@rm -f tb_tang9k.vvp
	@echo "Cleanup complete!"

