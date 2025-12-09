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

all: compile

compile:
	@echo "Compiling RTL files..."
	$(IVERILOG) $(IVERILOG_FLAGS) $(RTL_FILES)
	@echo "Compilation complete!"

wave: simulate
	@echo "Opening GTKWave..."
	@if [ -f $(VCD_FILE) ]; then \
		$(GTK) $(VCD_FILE) & \
	else \
		echo "Error: $(VCD_FILE) not found!"; \
	fi

view:
	@if [ -f $(VCD_FILE) ]; then \
		$(GTK) $(VCD_FILE) & \
	else \
		echo "Error: $(VCD_FILE) not found! Run 'make simulate' first."; \
	fi

clean:
	@echo "Cleaning up generated files..."
	rm -f $(VVP_FILE) $(VCD_FILE)
	@echo "Cleanup complete!"

help:
	@echo "Available targets:"
	@echo "  make all       - Compile and simulate"
	@echo "  make compile   - Compile only"
	@echo "  make simulate  - Compile and run simulation"
	@echo "  make wave      - Simulate and view waveform"
	@echo "  make view      - View existing waveform"
	@echo "  make clean     - Clean generated files"
	@echo "  make help      - Show this message"
