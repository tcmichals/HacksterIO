# DSHOT Module Makefile
# Compiles and simulates the DSHOT output module

IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Source files
SRCS = dshot_out.v dshot_tb.v

# Output files
VVP_OUT = dshot_tb.vvp
VCD_OUT = dshot_tb.vcd

# Verilog standard and defines
VERILOG_STD = -g2005
VERILOG_DEFINES = -DSIMULATION

.PHONY: all clean simulate view

all: simulate

compile: $(VVP_OUT)

$(VVP_OUT): $(SRCS)
	@echo "Compiling DSHOT testbench..."
	$(IVERILOG) $(VERILOG_STD) $(VERILOG_DEFINES) -o $(VVP_OUT) $(SRCS)
	@echo "Compilation complete!"

simulate: $(VVP_OUT)
	@echo "Running DSHOT simulation..."
	$(VVP) -n $(VVP_OUT)

view: $(VCD_OUT)
	@echo "Opening waveform viewer..."
	$(GTKWAVE) $(VCD_OUT) &

clean:
	@echo "Cleaning DSHOT build artifacts..."
	rm -f $(VVP_OUT) $(VCD_OUT)
	@echo "Cleanup complete!"
