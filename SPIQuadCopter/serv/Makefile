# Unified Makefile: Firmware, Simulation, FPGA

# === Toolchain settings ===
# xPack RISC-V Embedded GCC toolchain
# Install with: make install-toolchain
XPACK_VERSION := 15.2.0-1
XPACK_NAME := xpack-riscv-none-elf-gcc-$(XPACK_VERSION)
XPACK_INSTALL_DIR := $(HOME)/.local/tools
XPACK_GCC_DIR := $(XPACK_INSTALL_DIR)/$(XPACK_NAME)
RISCV_PREFIX ?= $(XPACK_GCC_DIR)/bin/riscv-none-elf
RISCV_GCC    ?= $(RISCV_PREFIX)-g++
RISCV_OBJCOPY ?= $(RISCV_PREFIX)-objcopy

# xPack download URL (Linux x64)
XPACK_URL := https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/download/v$(XPACK_VERSION)/$(XPACK_NAME)-linux-x64.tar.gz

# === Firmware ===
FW_ASM := firmware/crt0.S
FW_SRC := firmware/main.cpp firmware/msp_bridge.cpp firmware/msp_loop.cpp firmware/fourway.cpp firmware/syscalls.c
FW_ELF := firmware/firmware.elf
FW_HEX := firmware/firmware.hex
FW_MEM := firmware/firmware.mem
FW_LD  := firmware/link.ld

# === Simulation ===
SERV_ROOT := serv-core
SERV_RTL := \
	$(SERV_ROOT)/rtl/serv_aligner.v \
	$(SERV_ROOT)/rtl/serv_alu.v \
	$(SERV_ROOT)/rtl/serv_bufreg.v \
	$(SERV_ROOT)/rtl/serv_bufreg2.v \
	$(SERV_ROOT)/rtl/serv_compdec.v \
	$(SERV_ROOT)/rtl/serv_csr.v \
	$(SERV_ROOT)/rtl/serv_ctrl.v \
	$(SERV_ROOT)/rtl/serv_decode.v \
	$(SERV_ROOT)/rtl/serv_immdec.v \
	$(SERV_ROOT)/rtl/serv_mem_if.v \
	$(SERV_ROOT)/rtl/serv_rf_if.v \
	$(SERV_ROOT)/rtl/serv_rf_ram.v \
	$(SERV_ROOT)/rtl/serv_rf_ram_if.v \
	$(SERV_ROOT)/rtl/serv_rf_top.v \
	$(SERV_ROOT)/rtl/serv_state.v \
	$(SERV_ROOT)/rtl/serv_top.v
SERVILE_RTL := \
	$(SERV_ROOT)/servile/servile.v \
	$(SERV_ROOT)/servile/servile_arbiter.v \
	$(SERV_ROOT)/servile/servile_mux.v \
	$(SERV_ROOT)/servile/servile_rf_mem_if.v
LOCAL_RTL := \
	rtl/serv_wb_top.v \
	rtl/wb_ram.v \
	rtl/simple_uart.v \
	rtl/mode_reg.v
TB_RTL := sim/serv_tb_top.v
TB_CPP := sim/serv_tb.cpp
ALL_RTL := $(SERV_RTL) $(SERVILE_RTL) $(LOCAL_RTL) $(TB_RTL)
OBJ_DIR := obj_dir
TOP_MODULE := serv_tb_top

# === FPGA (example, adjust for your flow) ===
FPGA_TOP := src/tang9k_top.sv
FPGA_BUILD := build/tang9k.bit

# === Default target ===
.PHONY: all build size
all: build
build: firmware sim fpga

# === Firmware build ===
# Small C++ flags: no exceptions, no RTTI, optimize for size
# Uses nano.specs for smaller newlib-nano library
# rv32ic: RV32I + Compressed instructions (smaller code)
RISCV_CFLAGS := -march=rv32ic -mabi=ilp32 -fno-exceptions -fno-rtti -ffunction-sections -fdata-sections -Os -g
RISCV_LDFLAGS := -T $(FW_LD) --specs=nano.specs -nostartfiles -Wl,--gc-sections

# Generate version.h from git (works without git repo too)
FW_VERSION_H := firmware/version.h
GIT_DEPS := $(wildcard ../.git/HEAD ../.git/index .git/HEAD .git/index)
.PHONY: version
version: $(FW_VERSION_H)

$(FW_VERSION_H): $(GIT_DEPS) firmware/version.h.in
	@echo "Generating $@"
	@GIT_VER=$$(git describe --tags --always --dirty 2>/dev/null || echo "unknown"); \
	GIT_HASH=$$(git rev-parse --short HEAD 2>/dev/null || echo "unknown"); \
	BUILD_DATE=$$(date +%Y-%m-%d); \
	sed -e "s/@GIT_VERSION@/$$GIT_VER/" \
	    -e "s/@GIT_HASH@/$$GIT_HASH/" \
	    -e "s/@BUILD_DATE@/$$BUILD_DATE/" \
	    firmware/version.h.in > $@

$(FW_ELF): $(FW_ASM) $(FW_SRC) $(FW_LD) $(FW_VERSION_H)
	$(RISCV_GCC) $(RISCV_CFLAGS) $(RISCV_LDFLAGS) -o $@ $(FW_ASM) $(FW_SRC)

$(FW_HEX): $(FW_ELF)
	$(RISCV_OBJCOPY) -O verilog $< $@

$(FW_MEM): $(FW_HEX) firmware/hex2mem.py
	python3 firmware/hex2mem.py $(FW_HEX) $(FW_MEM)

firmware: $(FW_MEM)
	@echo "[OK] Firmware built: $(FW_MEM)"
	@./elf-size.sh $(FW_ELF)

size: $(FW_ELF)
	@./elf-size.sh $(FW_ELF)

# === Simulation build/run ===
$(OBJ_DIR)/V$(TOP_MODULE): $(ALL_RTL) $(TB_CPP) $(FW_HEX)
	verilator --cc --exe --trace --top-module $(TOP_MODULE) \
		-Wno-fatal -Wno-WIDTHTRUNC -Wno-WIDTHEXPAND -Wno-UNUSEDSIGNAL -Wno-UNUSEDPARAM \
		-Wno-UNDRIVEN -Wno-CASEINCOMPLETE -Wno-CASEOVERLAP \
		-GMEMFILE=\"$(FW_HEX)\" \
		$(ALL_RTL) $(TB_CPP)
	$(MAKE) -C $(OBJ_DIR) -f V$(TOP_MODULE).mk

sim: $(OBJ_DIR)/V$(TOP_MODULE)
	@echo "[OK] Running SERV simulation..."
	./$(OBJ_DIR)/V$(TOP_MODULE) +cycles=100000

sim-long: $(OBJ_DIR)/V$(TOP_MODULE)
	@echo "[OK] Running SERV simulation (1M cycles)..."
	./$(OBJ_DIR)/V$(TOP_MODULE) +cycles=1000000

wave: serv_tb.vcd
	gtkwave serv_tb.vcd &

# === FPGA build (example, adjust for your toolchain) ===
fpga:
	@echo "[TODO] Add your FPGA synthesis/build commands here."
	@echo "E.g., gowin, yosys, nextpnr, openFPGALoader, etc."

# === Toolchain installation ===
.PHONY: install-toolchain check-toolchain check-updates

install-toolchain:
	@echo "=== Installing xPack RISC-V GCC $(XPACK_VERSION) ==="
	@mkdir -p $(XPACK_INSTALL_DIR)
	@if [ -d "$(XPACK_GCC_DIR)" ]; then \
		echo "Toolchain already installed at $(XPACK_GCC_DIR)"; \
	else \
		echo "Downloading from $(XPACK_URL)..."; \
		curl -L -o /tmp/$(XPACK_NAME).tar.gz $(XPACK_URL); \
		echo "Extracting to $(XPACK_INSTALL_DIR)..."; \
		tar -xzf /tmp/$(XPACK_NAME).tar.gz -C $(XPACK_INSTALL_DIR); \
		rm /tmp/$(XPACK_NAME).tar.gz; \
		echo "[OK] Toolchain installed to $(XPACK_GCC_DIR)"; \
	fi

check-toolchain:
	@if [ -x "$(RISCV_GCC)" ]; then \
		echo "[OK] Toolchain found: $(RISCV_GCC)"; \
		$(RISCV_GCC) --version | head -1; \
	else \
		echo "[ERROR] Toolchain not found. Run: make install-toolchain"; \
		exit 1; \
	fi

check-updates:
	@echo "=== Checking for xPack RISC-V GCC updates ==="
	@echo "Installed version: $(XPACK_VERSION)"
	@LATEST=$$(curl -s https://api.github.com/repos/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/'); \
	echo "Latest version:    $$LATEST"; \
	if [ "$(XPACK_VERSION)" = "$$LATEST" ]; then \
		echo "[OK] You have the latest version."; \
	else \
		echo "[UPDATE AVAILABLE] Edit XPACK_VERSION in Makefile to $$LATEST"; \
		echo "Then run: make install-toolchain"; \
	fi

# === Clean ===
clean:
	rm -rf $(OBJ_DIR) $(FW_ELF) $(FW_HEX) $(FW_VERSION_H) serv_tb.vcd

help:
	@echo "Unified build system:"
	@echo ""
	@echo "Toolchain:"
	@echo "  make install-toolchain  - Download and install xPack RISC-V GCC"
	@echo "  make check-toolchain    - Verify toolchain is installed"
	@echo "  make check-updates      - Check for newer toolchain versions"
	@echo ""
	@echo "Build:"
	@echo "  make build      - Build firmware, simulation, and FPGA (if set up)"
	@echo "  make firmware   - Build only firmware (RISC-V)"
	@echo "  make size       - Show firmware size report"
	@echo "  make sim        - Build and run Verilator simulation"
	@echo "  make fpga       - Build FPGA bitstream (edit for your flow)"
	@echo "  make wave       - View simulation waveform"
	@echo "  make clean      - Clean all build artifacts"
