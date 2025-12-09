all: tb_neopixels tb_wb

tb_neopixels: Makefile tb_neopixels.v sendPx.v 
	iverilog -g2012 -o  tb_neopixels tb_neopixels.v sendPx.v
	vvp tb_neopixels

tb_wb: Makefile tb_wb.sv wb_neoPx.v sendPx.v 
	iverilog -g2012 -o  tb_wb tb_wb.sv wb_neoPx.v sendPx.v 
	vvp tb_wb


clean:
	rm -f tb_neopixels *.vcd tb_wb