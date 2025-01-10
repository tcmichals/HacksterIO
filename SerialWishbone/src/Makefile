all: tb_mux tb_middle tb_mux

tb_middle: Makefile tb_middle.sv middle.v gen_mux_wb.sv ../tang9kleds/wb_leds.sv ../verilog-wishbone/rtl/axis_wb_master.v ../blinktLEDBar/blinktLEDBar.sv  ../blinktLEDBar/sendRegAXIS.sv  ../neoPXStrip/wb_neoPx.v ../neoPXStrip/sendPx.v

	iverilog -g2012 -o tb_middle  middle.v tb_middle.sv gen_mux_wb.sv ../tang9kleds/wb_leds.sv ../verilog-wishbone/rtl/axis_wb_master.v ../blinktLEDBar/blinktLEDBar.sv ../blinktLEDBar/sendRegAXIS.sv  ../neoPXStrip/wb_neoPx.v ../neoPXStrip/sendPx.v
	vvp tb_middle

tb_mux: Makefile tb_mux.v 

	iverilog -g2012 -o tb_mux  tb_mux.v 
	vvp tb_mux

clean:
	rm -f tb_middle *.vcd tb_mux
