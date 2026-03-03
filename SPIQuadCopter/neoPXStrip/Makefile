help:
	@echo "Available targets in neoPXStrip Makefile:"
	@make -pRrq -C . : 2>/dev/null | awk -v RS= -F: '/^[-a-zA-Z0-9_.]+:/ {print $$1}' | grep -vE '^[.#]|^$@$$' | sort | uniq
	@echo
	@echo "Descriptions:"
	@echo "  run           - Build and run the Wishbone NeoPixel testbench (wb_neoPx_tb.v)"
	@echo "  clean         - Remove testbench outputs"

.PHONY: run clean

run: wb_neoPx_tb
	vvp wb_neoPx_tb

wb_neoPx_tb: wb_neoPx_tb.v wb_neoPx.v sendPx_axis_flexible.sv
	iverilog -g2012 -o wb_neoPx_tb wb_neoPx_tb.v wb_neoPx.v sendPx_axis_flexible.sv

clean:
	rm -f wb_neoPx_tb *.vcd