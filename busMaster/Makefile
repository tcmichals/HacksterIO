# Makefile for Wishbone Master AXIS Bridge

# Sources
SRC = wishbone_master_axis.sv tb/tb_wishbone_master_axis.sv

# Tools
IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Flags
FLAGS = -g2012 -Wall

# Targets
all: sim

sim: tb_sim
	$(VVP) tb_sim

tb_sim: $(SRC)
	$(IVERILOG) $(FLAGS) -o tb_sim $(SRC)

wave: sim
	# Note: Testbench must have $dumpvars/dumpfile for this to work effectively.
	# I will add dump commands to TB if needed.
	@echo "Opening Waveform..."
	$(GTKWAVE) waveform.vcd &

clean:
	@echo "Cleaning up generated files..."
	rm -f tb_sim sim.vvp spi_tb.vvp serial_tb.vvp
	rm -f waveform.vcd *.vcd
	rm -f *.o *.a
	rm -rf obj_dir obj_dir_*
	rm -rf __pycache__ .pytest_cache
	rm -f .verilator_* verilator_*
	rm -f tb/*.vvp tb/*.vcd
	@echo "Clean complete!"

help:
	@echo "Available targets:"
	@echo "  make sim   : Compile and run simulation"
	@echo "  make wave  : Open waveform in GTKWave"
	@echo "  make clean : Remove simulation artifacts"
	@echo "  make help  : Show this help message"

.PHONY: all sim wave clean help
