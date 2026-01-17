help:
	@echo "Available targets in neoPXStrip Makefile:"
	@make -pRrq -C . : 2>/dev/null | awk -v RS= -F: '/^[-a-zA-Z0-9_.]+:/ {print $$1}' | grep -vE '^[.#]|^$@$$' | sort | uniq
	@echo
	@echo "Descriptions:"
	@echo "  tb_neopixels  - Build and run the NeoPixel (sendPx) testbench (tb_neopixels.v + sendPx.v)"
	@echo "  tb_wb         - Build and run the Wishbone NeoPixel testbench (wb_neoPx_tb.v + wb_neoPx.v + sendPx_axis_flexible.sv)"
	@echo "  tb_sendPx     - Build and run the sendPx AXIS flexible testbench (tb_sendPX.sv)"
	@echo "  run           - Build and run wb_neoPx_tb (default integration test)"
	@echo "  clean         - Remove testbench outputs"
run: wb_neoPx_tb
all: wb_neoPx_tb tb_sendPx tb_neopixels tb_wb



wb_neoPx_tb:
	iverilog -g2012 -o wb_neoPx_tb wb_neoPx_tb.v wb_neoPx.v sendPx_axis_flexible.sv
	vvp wb_neoPx_tb


tb_sendPx: Makefile tb_sendPX.sv sendPx_axis_flexible.sv
	iverilog -g2012 -o tb_sendPx tb_sendPX.sv sendPx_axis_flexible.sv
	vvp tb_sendPx


tb_neopixels: Makefile tb_neopixels.v sendPx.v
	iverilog -g2012 -o tb_neopixels tb_neopixels.v sendPx.v
	vvp tb_neopixels


tb_wb: Makefile wb_neoPx_tb.v wb_neoPx.v sendPx_axis_flexible.sv
	iverilog -g2012 -o tb_wb wb_neoPx_tb.v wb_neoPx.v sendPx_axis_flexible.sv
	vvp tb_wb


clean:
	rm -f tb_sendPx tb_neopixels tb_wb tb_neoPx_tb *.vcd wb_neoPx_tb