# Unified Makefile: Firmware, Simulation, FPGA

# === Toolchain settings ===
RISCV_PREFIX ?= riscv64-unknown-elf
RISCV_GCC    ?= $(RISCV_PREFIX)-g++
RISCV_OBJCOPY ?= $(RISCV_PREFIX)-objcopy

# === Firmware ===
FW_ASM := firmware/crt0.S
FW_SRC := firmware/main.cpp firmware/msp_bridge.cpp
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
.PHONY: all build
all: build
build: firmware sim fpga

# === Firmware build ===
$(FW_ELF): $(FW_ASM) $(FW_SRC) $(FW_LD)
	$(RISCV_GCC) -march=rv32i -mabi=ilp32 -nostdlib -T $(FW_LD) -g -o $@ $(FW_ASM) $(FW_SRC)

$(FW_HEX): $(FW_ELF)
	$(RISCV_OBJCOPY) -O verilog $< $@

$(FW_MEM): $(FW_HEX) firmware/hex2mem.py
	python3 firmware/hex2mem.py $(FW_HEX) $(FW_MEM)

firmware: $(FW_MEM)
	@echo "[OK] Firmware built: $(FW_MEM)"

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

# === Clean ===
clean:
	rm -rf $(OBJ_DIR) $(FW_ELF) $(FW_HEX) serv_tb.vcd

help:
	@echo "Unified build system:"
	@echo "  make build      - Build firmware, simulation, and FPGA (if set up)"
	@echo "  make firmware   - Build only firmware (RISC-V)"
	@echo "  make sim        - Build and run Verilator simulation"
	@echo "  make fpga       - Build FPGA bitstream (edit for your flow)"
	@echo "  make wave       - View simulation waveform"
	@echo "  make clean      - Clean all build artifacts"
