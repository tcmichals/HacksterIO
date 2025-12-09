## PWM Decoder Module Build
## Supports simulation and testing

.PHONY: help simulate wave clean

help:
	@echo "PWM Decoder Module - Available Targets:"
	@echo ""
	@echo "  make simulate  - Run behavioral simulation (Iverilog/VVP)"
	@echo "  make wave      - View waveform dump (gtkwave)"
	@echo "  make clean     - Remove build artifacts"

.PHONY: simulate
simulate: pwmdecoder_tb.vvp
	@echo "Running PWM Decoder simulation..."
	vvp -n pwmdecoder_tb.vvp

pwmdecoder_tb.vvp: pwmdecoder.v pwmdecoder_tb.v
	@echo "Compiling PWM Decoder testbench..."
	iverilog -g2005 -o pwmdecoder_tb.vvp pwmdecoder.v pwmdecoder_tb.v

.PHONY: wave
wave: pwmdecoder_tb.vcd
	@if command -v gtkwave > /dev/null; then \
		gtkwave pwmdecoder_tb.vcd; \
	else \
		echo "Error: gtkwave not found. Install with: sudo apt-get install gtkwave"; \
		exit 1; \
	fi

pwmdecoder_tb.vcd: pwmdecoder_tb.vvp
	vvp -n pwmdecoder_tb.vvp

.PHONY: clean
clean:
	@echo "Cleaning PWM Decoder build artifacts..."
	@rm -f pwmdecoder_tb.vvp pwmdecoder_tb.vcd
	@echo "Cleanup complete!"
