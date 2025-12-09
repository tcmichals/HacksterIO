# Makefile for SPI Slave Module Testing
# Uses iverilog for compilation and simulation

# Tools
IVERILOG = iverilog
VVP = vvp
GTK = gtkwave

# File names
RTL_FILES = spi_slave.sv
TB_FILES = spi_slave_tb.sv
VVP_FILE = spi_slave_tb.vvp
VCD_FILE = spi_slave_tb.vcd

# Compilation flags
IVERILOG_FLAGS = -g2009 -o $(VVP_FILE)

# Default target
.PHONY: all
all: compile simulate

# Compile design and testbench
.PHONY: compile
compile:
	@echo "Compiling SPI Slave module and testbench..."
	$(IVERILOG) $(IVERILOG_FLAGS) $(RTL_FILES) $(TB_FILES)
	@echo "Compilation complete!"

# Run simulation
.PHONY: simulate
simulate: compile
	@echo "Running simulation..."
	$(VVP) $(VVP_FILE)
	@echo "Simulation complete!"

# View waveform with GTKWave
.PHONY: wave
wave: simulate
	@echo "Opening GTKWave..."
	@if [ -f $(VCD_FILE) ]; then \
		$(GTK) $(VCD_FILE) & \
	else \
		echo "Error: $(VCD_FILE) not found!"; \
	fi

# View waveform only (assuming it already exists)
.PHONY: view
view:
	@if [ -f $(VCD_FILE) ]; then \
		$(GTK) $(VCD_FILE) & \
	else \
		echo "Error: $(VCD_FILE) not found! Run 'make simulate' first."; \
	fi

# Clean up generated files
.PHONY: clean
clean:
	@echo "Cleaning up generated files..."
	rm -f $(VVP_FILE) $(VCD_FILE) *.vcd *.vvp
	@echo "Cleanup complete!"

# Help target
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  make all       - Compile and run simulation"
	@echo "  make compile   - Compile design and testbench"
	@echo "  make simulate  - Run simulation (includes compile)"
	@echo "  make wave      - Run simulation and open waveform in GTKWave"
	@echo "  make view      - View existing waveform in GTKWave"
	@echo "  make clean     - Remove generated files"
	@echo "  make help      - Show this help message"

.PHONY: debug
debug: compile
	@echo "Running simulation with verbose output..."
	$(VVP) -v $(VVP_FILE)
