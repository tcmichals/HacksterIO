# Makefile for MSP Handler V2 Testbench

IVERILOG = iverilog
VVP = vvp
GTKWAVE = gtkwave

# Source files
SRCS = msp_rx.sv msp_responder.sv msp_tx.sv msp_handler_v2.sv
TB = msp_handler_v2_tb.sv

# Output
OUT = msp_handler_v2_tb.vvp
VCD = msp_handler_v2_tb.vcd

.PHONY: all sim wave clean

all: sim

# Compile
$(OUT): $(SRCS) $(TB)
	$(IVERILOG) -g2012 -Wall -o $(OUT) $(TB) $(SRCS)

# Run simulation
sim: $(OUT)
	$(VVP) $(OUT)

# View waveforms
wave: $(VCD)
	$(GTKWAVE) $(VCD) &

# Clean
clean:
	rm -f $(OUT) $(VCD) *.vcd
