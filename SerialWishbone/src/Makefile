

tb_middle: Makefile tb_middle.sv middle.v gen_mux_wb.v ../tang9kleds/wb_leds.v ../verilog-wishbone/rtl/axis_wb_master.v ../blinktLEDBar/blinktLEDBar.sv  ../blinktLEDBar/sendRegAXIS.sv mux_wrapper.v ../neoPXStrip/wb_neoPx.v

	iverilog -g2012 -o tb_middle  middle.v tb_middle.sv gen_mux_wb.v ../tang9kleds/wb_leds.v ../verilog-wishbone/rtl/axis_wb_master.v ../blinktLEDBar/blinktLEDBar.sv ../blinktLEDBar/sendRegAXIS.sv mux_wrapper.v ../neoPXStrip/wb_neoPx.v
	vvp tb_middle



clean:
	rm -f tb_middle *.vcd 
