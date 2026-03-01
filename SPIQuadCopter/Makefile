## Main Makefile - direct toolchain (yosys → nextpnr → gowin_pack)
## This replaces the apio-managed build with explicit commands so the project
## only includes the RTL files we want to synthesize.

.PHONY: help all build synth place pack upload clean simulate wave view lint

# Ensure default make target is the full build (avoid running installer accidentally)
.DEFAULT_GOAL := all

TOP := tang9k_top
BUILD_DIR := _build/default

# Allow overriding the OSS CAD Suite install dir via environment variable
OSS_CAD_INSTALL_DIR ?= $(HOME)/.local/oss-cad-suite
OSS_CAD_BIN_DIR := $(abspath $(OSS_CAD_INSTALL_DIR)/bin)

# Prefer configured or common user-local locations, else project-local `oss-cad-suite/bin`
ifneq (,$(wildcard $(OSS_CAD_BIN_DIR)))
	export PATH := $(abspath $(OSS_CAD_BIN_DIR)):$(PATH)
else ifneq (,$(wildcard $(HOME)/.tools/oss-cad-suite/bin))
	export PATH := $(abspath $(HOME)/.tools/oss-cad-suite/bin):$(PATH)
else ifneq (,$(wildcard $(HOME)/tools/bin))
	export PATH := $(abspath $(HOME)/tools/bin):$(PATH)
else ifneq (,$(wildcard $(CURDIR)/oss-cad-suite/bin))
	export PATH := $(abspath $(CURDIR)/oss-cad-suite/bin):$(PATH)
endif

# Tool command names: prefer configured install dir, then user-local legacy locations, otherwise project-local
ifneq (,$(wildcard $(OSS_CAD_BIN_DIR)))
LOCAL_BIN_DIR := $(abspath $(OSS_CAD_BIN_DIR))
else ifneq (,$(wildcard $(HOME)/.tools/oss-cad-suite/bin))
LOCAL_BIN_DIR := $(abspath $(HOME)/.tools/oss-cad-suite/bin)
else ifneq (,$(wildcard $(HOME)/tools/bin))
LOCAL_BIN_DIR := $(abspath $(HOME)/tools/bin)
else ifneq (,$(wildcard $(CURDIR)/oss-cad-suite/bin))
LOCAL_BIN_DIR := $(abspath $(CURDIR)/oss-cad-suite/bin)
else
LOCAL_BIN_DIR := $(abspath oss-cad-suite/bin)
endif

ifeq ($(wildcard $(LOCAL_BIN_DIR)/yosys),)
YOSYS := yosys
else
YOSYS := $(LOCAL_BIN_DIR)/yosys
endif

ifeq ($(wildcard $(LOCAL_BIN_DIR)/nextpnr-himbaechel),)
NEXTPNR := nextpnr-himbaechel
else
NEXTPNR := $(LOCAL_BIN_DIR)/nextpnr-himbaechel
endif

ifeq ($(wildcard $(LOCAL_BIN_DIR)/gowin_pack),)
GOWIN_PACK := gowin_pack
else
GOWIN_PACK := $(LOCAL_BIN_DIR)/gowin_pack
endif

ifeq ($(wildcard $(LOCAL_BIN_DIR)/openFPGALoader),)
OPENFPGALOADER := openFPGALoader
else
OPENFPGALOADER := $(LOCAL_BIN_DIR)/openFPGALoader
endif

ifeq ($(wildcard $(LOCAL_BIN_DIR)/iverilog),)
IVERILOG := iverilog
else
IVERILOG := $(LOCAL_BIN_DIR)/iverilog
endif

ifeq ($(wildcard $(LOCAL_BIN_DIR)/vvp),)
VVP := vvp
else
VVP := $(LOCAL_BIN_DIR)/vvp
endif

export IVERILOG VVP

# Sources used for synthesis (exclude testbenches)

SRCS := spiSlave/spi_slave.sv src/pll.sv \
	src/spi_wb_master.sv \
	src/wb_dshot_controller.sv src/wb_serial_dshot_mux.sv src/wb_led_controller.sv src/tang9k_top.sv \
	pwmDecoder/pwmdecoder.v pwmDecoder/pwmdecoder_wb.v \
	neoPXStrip/sendPx_axis_flexible.sv neoPXStrip/wb_neoPx.v \
	version/wb_version.sv \
	src/wb_mux_5.v \
	src/wb_mux_6.v \
	src/wb_mux_8.v \
	src/wb_usb_uart.sv \
	src/wb_debug_gpio.sv \
	src/wb_esc_uart.sv \
	verilog-wishbone/rtl/priority_encoder.v \
	verilog-wishbone/rtl/arbiter.v \
	verilog-wishbone/rtl/wb_arbiter_2.v \
	dshot/dshot_out.v \
	verilog-uart/rtl/uart_tx.v verilog-uart/rtl/uart_rx.v \
serv/rtl/serv_wb_top.v \
serv/rtl/wb_ram.v \
serv/serv-core/servile/servile.v \
serv/serv-core/servile/servile_arbiter.v \
serv/serv-core/servile/servile_mux.v \
serv/serv-core/servile/servile_rf_mem_if.v \
serv/serv-core/rtl/serv_top.v \
serv/serv-core/rtl/serv_rf_ram_if.v \
serv/serv-core/rtl/serv_aligner.v \
serv/serv-core/rtl/serv_alu.v \
serv/serv-core/rtl/serv_bufreg.v \
serv/serv-core/rtl/serv_bufreg2.v \
serv/serv-core/rtl/serv_compdec.v \
serv/serv-core/rtl/serv_csr.v \
serv/serv-core/rtl/serv_ctrl.v \
serv/serv-core/rtl/serv_debug.v \
serv/serv-core/rtl/serv_decode.v \
serv/serv-core/rtl/serv_immdec.v \
serv/serv-core/rtl/serv_mem_if.v \
serv/serv-core/rtl/serv_rf_if.v \
serv/serv-core/rtl/serv_rf_ram.v \
serv/serv-core/rtl/serv_rf_top.v \
serv/serv-core/rtl/serv_state.v \
serv/serv-core/rtl/serv_synth_wrapper.v \

CST := tang9k.cst

# Tools: YOSYS/NEXTPNR/GOWIN_PACK are set above using LOCAL_BIN_DIR discovery (fall back to system PATH)

# P&R seed - override with: make build SEED=123
SEED ?= 42

YOSYS_FLAGS := -m slang -Q -p "synth_gowin -top $(TOP) -json $(BUILD_DIR)/hardware.json"
NEXTPNR_FLAGS := --device GW1NR-LV9QN88PC6/I5 --json $(BUILD_DIR)/hardware.json \
				 --write $(BUILD_DIR)/hardware.pnr.json --report $(BUILD_DIR)/hardware.pnr \
				 --vopt family=GW1N-9C --vopt cst=$(CST) --sdc tang9k_timing.sdc --seed $(SEED) \
				 --timing-allow-fail
GOWIN_PACK_FLAGS := -d GW1N-9C -o $(BUILD_DIR)/hardware.fs $(BUILD_DIR)/hardware.pnr.json

.PHONY: install-tools
install-tools:
	@echo "Installing OSS CAD Suite via project installer: ./scripts/install_local_tools.sh --yes"
	@if [ -x ./scripts/install_local_tools.sh ]; then \
		./scripts/install_local_tools.sh --yes; \
	else \
		echo "Error: ./scripts/install_local_tools.sh not found or not executable."; \
		echo "Please run: ./scripts/install_local_tools.sh --help"; \
		exit 1; \
	fi

.PHONY: install-tools-local
install-tools-local:
	@echo "Installing OSS CAD Suite into $(OSS_CAD_INSTALL_DIR) via installer"
	@if [ -d "$(OSS_CAD_INSTALL_DIR)" ] && [ -z "$$REINSTALL" ]; then \
		echo "Installation already exists at $(OSS_CAD_INSTALL_DIR). To force reinstall, run: make install-tools-local REINSTALL=1"; \
		echo "Or run: ./scripts/install_local_tools.sh --install-dir $(OSS_CAD_INSTALL_DIR) --help"; \
		exit 0; \
	elif [ -x ./scripts/install_local_tools.sh ]; then \
		./scripts/install_local_tools.sh --install-dir $(OSS_CAD_INSTALL_DIR); \
	else \
		echo "Error: ./scripts/install_local_tools.sh not found or not executable."; \
		echo "Please run: ./scripts/install_local_tools.sh --help"; \
		exit 1; \
	fi


help:
	@echo "Tang9K FPGA Project - Available Targets:"
	@echo ""
	@echo "Build targets:"
	@echo "  make build      - Run full build (firmware + synth + place & route + pack)"
	@echo "  make firmware   - Build SERV RISC-V firmware only (delegates to serv/Makefile)"
	@echo "  make synth      - Run yosys synthesis (generates hardware.json)"
	@echo "  make place      - Run nextpnr (generates hardware.pnr.json)"
	@echo "  make pack       - Run gowin_pack (generates hardware.fs)"
	@echo "  make upload     - Program board using openFPGALoader"
	@echo ""
	@echo "SPI Wishbone Testbenches (src/tb/):"
	@echo "  make tb-spi-wb       - SPI-WB Master protocol test (read/write/burst)"
	@echo "  make tb-spi-pwm      - SPI→PWM integration (generate waveforms, read via SPI)"
	@echo "  make tb-spi-all      - Run all SPI Wishbone testbenches"
	@echo ""
	@echo "Other Simulation / Testbench targets:"
	@echo "  make tb-serv         - Run SERV CPU Verilator simulation (delegates to serv/Makefile)"
	@echo "  make tb-design       - Compile & run src/tb/design_tb.sv (iverilog)"
	@echo "  make tb-version      - Compile & run version/wb_version_tb.sv (iverilog)"
	@echo "  make tb-neopx        - Run NeoPixel Wishbone testbench"
	@echo "  make simulate        - Run SPI slave simulation (delegates to spiSlave/Makefile)"
	@echo "  make -C neoPXStrip help - List NeoPixel testbench targets"
	@echo "  make -C dshot help   - List DSHOT testbench targets"
	@echo "  make -C pwmDecoder help - List PWM decoder testbench targets"
	@echo ""
	@echo "Testbench plusargs (use VVP_ARGS for iverilog tests):"
	@echo "  Example: make tb-design VVP_ARGS=\"+TEST_VERSION +VERBOSE\""
	@echo ""
	@echo "Tool management:"
	@echo "  make install-tools      - Install oss-cad-suite via system package manager"
	@echo "  make install-tools-local - Install prebuilt OSS CAD Suite locally"
	@echo "  make oss-version        - Check local tools version vs latest GitHub release"
	@echo ""
	@echo "  make clean      - Remove build artifacts"
	@echo "  make lint       - Syntax check with iverilog"

all: build

# Firmware build (delegates to serv/Makefile)
.PHONY: firmware
firmware:
	@echo "Building SERV firmware..."
	$(MAKE) -C serv firmware

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: synth
synth: $(BUILD_DIR)
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
build: firmware pack
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

wave:
	@cd spiSlave && make wave

.PHONY: oss-version
oss-version:
	@./scripts/check_oss_suite_version.sh || true

.PHONY: oss-update
oss-update:
	@echo "Updating OSS CAD Suite (default install: $HOME/.local/oss-cad-suite, falls back to $HOME/tools and project/oss-cad-suite) using GitHub release..."
	@./scripts/install_local_tools.sh --yes || { echo "Update failed"; exit 1; }

view:
	@cd spiSlave && make view

# SERV CPU simulation (delegates to serv/Makefile)
.PHONY: tb-serv
tb-serv:
	@echo "Running SERV CPU simulation..."
	$(MAKE) -C serv sim

# SPI Wishbone testbenches (in src/tb/)
.PHONY: tb-spi-wb tb-spi-pwm tb-spi-all
tb-spi-wb:
	@echo "Running SPI-WB Master testbench..."
	$(MAKE) -C src/tb tb-spi-wb

tb-spi-pwm:
	@echo "Running SPI-PWM integration testbench..."
	$(MAKE) -C src/tb tb-spi-pwm

tb-spi-all:
	@echo "Running all SPI testbenches..."
	$(MAKE) -C src/tb tb-all

# NeoPixel Wishbone testbench
.PHONY: tb-neopx
tb-neopx:
	@echo "Running NeoPixel Wishbone testbench..."
	$(MAKE) -C neoPXStrip test


lint:
	@echo "Checking Verilog syntax with iverilog..."
	@if ! command -v iverilog > /dev/null; then \
		echo "Error: iverilog not found."; exit 1; \
	fi
	iverilog -g2009 -t null src/tang9k_top.sv spiSlave/spi_slave.sv && echo "Syntax OK"

clean:
	@echo "Cleaning build artifacts..."
	@cd spiSlave && make clean || true
	# remove top-level build dir
	@rm -rf $(BUILD_DIR)
	# remove common simulation outputs
	@rm -f tb_design.vcd tb_design.vvp *.vcd *.vvp *.vpd || true
	# remove yosys/nextpnr/gowin intermediate outputs
	# remove yosys/nextpnr/gowin intermediate outputs (but preserve top-level .json files)
	@find . -type f \( -name "*.pnr" -o -name "*.pnr.json" -o -name "*.rpt" -o -name "*.edif" \) -maxdepth 4 -exec rm -f {} + || true
	# remove intermediate .json files but skip JSONs in the repository root
	@find . -mindepth 2 -type f -name "*.json" -maxdepth 4 -exec rm -f {} + || true
	# remove packed bitstreams and temporary files
	@find . -type f \( -name "*.fs" -o -name "*.bin" -o -name "*.bit" \) -maxdepth 4 -exec rm -f {} + || true
	# remove any local tool caches or temporary folders
	@rm -rf .cache .tmp .yosys* .nextpnr* || true
	@echo "Cleanup complete!"

# optionally include tools/Makefile (testbench targets)
-include tools/Makefile

