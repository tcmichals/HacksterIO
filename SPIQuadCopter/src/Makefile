# Makefile for LED Blinker Testing

IVERILOG = iverilog
VVP = vvp
GTK = gtkwave

RTL_FILES = pll.sv
TB_FILES =
VVP_FILE = pll.vvp
VCD_FILE = pll.vcd

IVERILOG_FLAGS = -g2009 -o $(VVP_FILE)

.PHONY: all compile simulate wave view clean help

# Keep local compile helper, but delegate simulate/wave/view to top-level Makefile
all: compile

compile:
	@echo "Compiling RTL files..."
	$(IVERILOG) $(IVERILOG_FLAGS) $(RTL_FILES)
	@echo "Compilation complete!"

# Delegate simulate/wave/view to project root so users can run make from src/
.PHONY: simulate
simulate:
	@echo "Delegating simulate to project root: invoking 'make -C .. simulate'"
	@cd .. && $(MAKE) simulate

.PHONY: wave
wave:
	@echo "Delegating wave to project root: invoking 'make -C .. wave'"
	@cd .. && $(MAKE) wave

.PHONY: view
view:
	@echo "Delegating view to project root: invoking 'make -C .. view'"
	@cd .. && $(MAKE) view

clean:
	@echo "Cleaning up generated files..."
	rm -f $(VVP_FILE) $(VCD_FILE)
	@echo "Cleanup complete!"

help:
	@echo "Available targets:"
	@echo "  make all       - Compile and simulate"
	@echo "  make compile   - Compile only"
	@echo "  make simulate  - Compile and run simulation (delegates to project root)"
	@echo "  make wave      - Simulate and view waveform (delegates to project root)"
	@echo "  make view      - View existing waveform (delegates to project root)"
	@echo "  make clean     - Clean generated files"
	@echo "  make help      - Show this message"

# Convenience targets to run top-level testbenches from this subdirectory
.PHONY: tb-design tb-passthrough
tb-design:
	@echo "Forwarding tb-design to project root"
	@cd .. && $(MAKE) tb-design

tb-passthrough:
	@echo "Forwarding tb-passthrough to project root"
	@cd .. && $(MAKE) tb-passthrough
