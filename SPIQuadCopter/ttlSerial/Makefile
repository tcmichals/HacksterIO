## TTL Serial Module Build
## Supports simulation and synthesis

.PHONY: help simulate wave clean

BAUD_RATE ?= 115200
CLK_FREQ ?= 27000000

help:
	@echo "TTL Serial Module - Available Targets:"
	@echo ""
	@echo "  make simulate  - Run behavioral simulation (Iverilog/VVP)"
	@echo "  make wave      - View waveform dump (gtkwave)"
	@echo "  make clean     - Remove build artifacts"
	@echo ""
	@echo "Parameters (can be overridden):"
	@echo "  BAUD_RATE=<bps>   (default: 115200)"
	@echo "  CLK_FREQ=<hz>     (default: 27000000)"
	@echo ""
	@echo "Examples:"
	@echo "  make simulate BAUD_RATE=9600"
	@echo "  make simulate CLK_FREQ=50000000 BAUD_RATE=115200"

.PHONY: simulate
simulate: ttl_serial_tb.vvp
	@echo "Running TTL Serial simulation..."
	vvp -n ttl_serial_tb.vvp

ttl_serial_tb.vvp: ttl_serial.sv ttl_serial_tb.sv
	@echo "Compiling TTL Serial testbench..."
	iverilog -g2012 -o ttl_serial_tb.vvp ttl_serial.sv ttl_serial_tb.sv

.PHONY: wave
wave: ttl_serial_tb.vcd
	@if command -v gtkwave > /dev/null; then \
		gtkwave ttl_serial_tb.vcd --vcd; \
	else \
		echo "Error: gtkwave not found. Install with: sudo apt-get install gtkwave"; \
		exit 1; \
	fi

ttl_serial_tb.vcd: ttl_serial_tb.vvp
	vvp -n ttl_serial_tb.vvp

.PHONY: clean
clean:
	@echo "Cleaning TTL Serial build artifacts..."
	@rm -f ttl_serial_tb.vvp ttl_serial_tb.vcd
	@echo "Cleanup complete!"
