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

SRCS := spiSlave/spi_slave.sv src/pll.sv src/coredesign.sv src/uart_passthrough_bridge.sv \
	src/msp_v2/msp_rx.sv src/msp_v2/msp_responder.sv src/msp_v2/msp_tx.sv src/msp_v2/msp_handler_v2.sv \
	src/four_way_handler.sv src/shared_buffer_ram.sv src/wb_dshot_controller.sv src/wb_serial_dshot_mux.sv src/wb_led_controller.sv src/tang9k_top.sv \
	pwmDecoder/pwmdecoder.v pwmDecoder/pwmdecoder_wb.v \
	neoPXStrip/sendPx_axis_flexible.sv neoPXStrip/wb_neoPx.v \
	version/wb_version.sv \
	verilog-wishbone/rtl/axis_wb_master.v \
     		src/wb_mux_7.v \
		src/wb_uart_wrapper.sv \
		src/spi_axis_adapter.sv \
		dshot/dshot_out.v \
		src/uart_tx.sv src/uart_rx.sv \
		verilog-uart/rtl/uart_tx.v verilog-uart/rtl/uart_rx.v \

CST := tang9k.cst

# Tools: YOSYS/NEXTPNR/GOWIN_PACK are set above using LOCAL_BIN_DIR discovery (fall back to system PATH)

# P&R seed - override with: make build SEED=123
SEED ?= 42

YOSYS_FLAGS := -m slang -Q -p "synth_gowin -top $(TOP) -json $(BUILD_DIR)/hardware.json"
NEXTPNR_FLAGS := --device GW1NR-LV9QN88PC6/I5 --json $(BUILD_DIR)/hardware.json \
				 --write $(BUILD_DIR)/hardware.pnr.json --report $(BUILD_DIR)/hardware.pnr \
				 --vopt family=GW1N-9C --vopt cst=$(CST) --sdc tang9k_timing.sdc --seed $(SEED)
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
	@echo "  make build      - Run full build (synth + place & route + pack)"
	@echo "  make synth      - Run yosys synthesis (generates hardware.json)"
	@echo "  make place      - Run nextpnr (generates hardware.pnr.json)"
	@echo "  make pack       - Run gowin_pack (generates hardware.fs)"
	@echo "  make upload     - Program board using openFPGALoader"
	@echo "  make install-tools - Attempt to install oss-cad-suite / openFPGALoader via system package manager"
	@echo "  ./scripts/install_local_tools.sh - Install prebuilt OSS CAD Suite (default: $HOME/.local/oss-cad-suite or use --install-dir)"
	@echo "  make oss-version - Check local tools VERSION vs latest GitHub release (checks $$OSS_CAD_INSTALL_DIR, $HOME/.tools/oss-cad-suite, $HOME/tools then project/oss-cad-suite)"
	@echo "  make simulate   - Run SPI slave simulation (delegates to spiSlave/Makefile)"
	@echo "  make -C neoPXStrip help - List NeoPixel (sendPx) testbench and simulation targets in neoPXStrip/Makefile"
	@echo ""
	@echo "Testbench / simulation targets (testbenches live under src/tb):"
	@echo "  make tb-design       - Compile & run src/tb/design_tb.sv."
	@echo "  make tb-msp-proto    - Compile & run src/tb/msp_protocol_tb.sv (MSP protocol handler testbench)."
	@echo "  make tb-msp-v2       - Compile & run MSP Handler V2 testbench (pipelined packet processor)."
	@echo "  make tb-version      - Compile & run version/wb_version_tb.sv."
	@echo "  make tb-bridge       - Compile & run UART bridge testbench."
	@echo "  make tb-msp-mux      - Compile & run MSP / Motor Mux testbench."
	@echo "  make test-tb         - Run all consolidated system testbenches."
	@echo "Passing plusargs / runtime options to testbenches:"
	@echo "  The tb targets invoke vvp and accept simulator plusargs via the VVP_ARGS make variable."
	@echo "  Example: make tb-design VVP_ARGS=\"+TEST_VERSION +VERBOSE\""
	@echo "  You can also ask for testbench-specific help defined in tools/Makefile: make tools-help"
	@echo ""
	@echo "Supported test plusargs (use with VVP_ARGS):"
	@echo "  +TEST_LED       - Run LED controller tests"
	@echo "  +TEST_MUX       - Run Mux controller tests"
	@echo "  +TEST_DSHOT     - Run DSHOT controller tests"
	@echo "  +TEST_PWM       - Run PWM decoder tests"
	@echo "  +TEST_VERSION   - Run Version readback test"
	@echo "  +TEST_NEOPIXEL  - Run NeoPixel controller test"
	@echo "Note: running 'make' will no longer automatically reinstall tools; to force reinstall run: 'make install-tools-local REINSTALL=1'"
	@echo ""
	# If tools/Makefile is present, show its help too so all options appear together
	@if [ -f tools/Makefile ]; then \
		$(MAKE) -s -f tools/Makefile tools-help; \
	fi
	@echo "  make clean      - Remove build artifacts"
	@echo "  make lint       - Syntax check with iverilog"

all: build

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

# Testbench targets (run testbenches located under src/tb)
.PHONY: tb-design tb-version test-tb
.PHONY: tb-msp-proto msp-proto-compile
.PHONY: tb-msp-v2

# MSP Handler V2 Testbench (pipelined packet processor)
MSP_V2_TB_SRC := src/msp_v2/msp_handler_v2_tb.sv
MSP_V2_SRCS := src/msp_v2/msp_rx.sv src/msp_v2/msp_responder.sv src/msp_v2/msp_tx.sv src/msp_v2/msp_handler_v2.sv
MSP_V2_VVP := src/build/msp_handler_v2_tb.vvp
MSP_V2_VCD := src/msp_v2/msp_handler_v2_tb.vcd

tb-msp-v2: | src/build
	@echo "Compiling MSP Handler V2 testbench..."
	$(IVERILOG) -g2012 -Wall -o $(MSP_V2_VVP) $(MSP_V2_TB_SRC) $(MSP_V2_SRCS)
	@echo "Running MSP Handler V2 simulation..."
	$(VVP) $(MSP_V2_VVP) || { echo 'Simulation failed!'; exit 1; }
	@echo "Simulation complete. VCD file: $(MSP_V2_VCD)"

# MSP Protocol Testbench (legacy)
MSP_PROTO_TB_SRC := src/tb/msp_protocol_tb.sv
MSP_PROTO_VVP := src/build/msp_protocol_tb.vvp
MSP_PROTO_VCD := src/tb/msp_protocol_tb.vcd

tb-msp-proto: msp-proto-compile
	@echo "Running MSP protocol handler simulation..."
	$(VVP) $(MSP_PROTO_VVP) || { echo 'Simulation failed!'; exit 1; }
	@echo "Simulation complete. VCD file: $(MSP_PROTO_VCD)"

msp-proto-compile: | src/build
	@echo "Compiling MSP protocol handler testbench..."
	$(IVERILOG) -g2012 -Wall -Wno-timescale -o $(MSP_PROTO_VVP) \
		$(MSP_PROTO_TB_SRC) src/msp_handler.sv src/shared_buffer_ram.sv

# Streamlined core testbenches
test-tb: tb-design tb-msp-mux tb-bridge tb-version


# MSP Serial / Motor Mux testbench (formerly tb-wb-mux)
# -----------------------------------------------------------------------------
TB_BUILD_DIR := src/build
MSP_MUX_TB_SRC  := src/tb/wb_serial_dshot_mux_tb.sv
MSP_MUX_DUT_SRC  := src/wb_serial_dshot_mux.sv
MSP_MUX_VVP      := $(TB_BUILD_DIR)/wb_serial_dshot_mux_tb.vvp
MSP_MUX_VCD      := src/tb/wb_serial_dshot_mux_tb.vcd
MSP_MUX_GTKW     := src/tb/wb_serial_dshot_mux_tb.gtkw
MSP_MUX_DIR      := src

MSP_MUX_UART_WRAPPERS := src/uart_rx.sv src/uart_tx.sv
MSP_MUX_UART_CORE_DIR := verilog-uart/rtl
MSP_MUX_UART_CORE     := $(MSP_MUX_UART_CORE_DIR)/uart_rx.v $(MSP_MUX_UART_CORE_DIR)/uart_tx.v

TB_BUILD_DIR := src/build

MSP_MUX_IVERILOG_FLAGS := -g2012 -Wall -Wno-timescale -D SIM_CONTROL

.PHONY: msp-mux-compile tb-msp-mux msp-mux-view msp-mux-clean

$(TB_BUILD_DIR):
	mkdir -p $(TB_BUILD_DIR)

msp-mux-compile: $(TB_BUILD_DIR)
	@echo "Compiling MSP mux testbench..."
	@rm -f $(MSP_MUX_VVP)
	$(IVERILOG) $(MSP_MUX_IVERILOG_FLAGS) -o $(MSP_MUX_VVP) \
		$(MSP_MUX_TB_SRC) \
		$(MSP_MUX_DUT_SRC) \
		$(MSP_MUX_UART_WRAPPERS) \
		$(MSP_MUX_UART_CORE)

tb-msp-mux: msp-mux-compile
	@echo "Running MSP mux simulation..."
	$(VVP) $(MSP_MUX_VVP)
	@echo "MSP mux simulation complete. VCD file: $(MSP_MUX_VCD)"

msp-mux-view: $(MSP_MUX_VCD)
	@echo "Opening MSP mux waveform..."
	@if [ -f $(MSP_MUX_GTKW) ]; then \
		gtkwave $(MSP_MUX_VCD) $(MSP_MUX_GTKW) &; \
	else \
		gtkwave $(MSP_MUX_VCD) &; \
	fi

msp-mux-clean:
	@rm -rf $(TB_BUILD_DIR)
	@rm -f $(MSP_MUX_DIR)/*.vcd $(MSP_MUX_DIR)/*.vvp


# -----------------------------------------------------------------------------
# UART Passthrough Bridge testbench (migrated from src/Makefile.passthrough_tb)
# -----------------------------------------------------------------------------
PASSTHROUGH_DIR := src
PASSTHROUGH_BUILD := $(PASSTHROUGH_DIR)/build

PASSTHROUGH_TB_SRC := src/tb/uart_passthrough_bridge_tb.sv
PASSTHROUGH_DUT_SRC := src/uart_passthrough_bridge.sv
PASSTHROUGH_UART_WRAPPERS := src/uart_rx.sv src/uart_tx.sv
PASSTHROUGH_VERILOG_UART_DIR := verilog-uart/rtl
PASSTHROUGH_UART_CORE := $(PASSTHROUGH_VERILOG_UART_DIR)/uart_rx.v $(PASSTHROUGH_VERILOG_UART_DIR)/uart_tx.v

PASSTHROUGH_VVP := $(TB_BUILD_DIR)/uart_passthrough_bridge_tb.vvp
PASSTHROUGH_VCD := src/tb/uart_passthrough_bridge_tb.vcd
PASSTHROUGH_GTKW := src/tb/uart_passthrough_bridge_tb.gtkw

PASSTHROUGH_IVERILOG_FLAGS := -g2012 -Wall -Wno-timescale

bridge-compile: $(TB_BUILD_DIR)
	@echo "Compiling passthrough testbench..."
	@rm -f $(PASSTHROUGH_VVP)
	$(IVERILOG) $(PASSTHROUGH_IVERILOG_FLAGS) -o $(PASSTHROUGH_VVP) \
		$(PASSTHROUGH_TB_SRC) \
		$(PASSTHROUGH_DUT_SRC) \
		$(PASSTHROUGH_UART_WRAPPERS) \
		$(PASSTHROUGH_UART_CORE)

tb-bridge: bridge-compile
	@echo "Running bridge simulation..."
	$(VVP) $(PASSTHROUGH_VVP)
	@echo "Simulation complete. VCD file: $(PASSTHROUGH_VCD)"

bridge-view: $(PASSTHROUGH_VCD)
	@echo "Opening passthrough waveform..."
	@if [ -f $(PASSTHROUGH_GTKW) ]; then \
		gtkwave $(PASSTHROUGH_VCD) $(PASSTHROUGH_GTKW) &; \
	else \
		gtkwave $(PASSTHROUGH_VCD) &; \
	fi

bridge-clean:
	@rm -rf $(TB_BUILD_DIR)
	@rm -f $(PASSTHROUGH_DIR)/*.vcd $(PASSTHROUGH_DIR)/*.vvp


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

