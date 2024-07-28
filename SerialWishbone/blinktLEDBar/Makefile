
all: tb_sendRegAXIS tb_blinktLEDBar


tb_sendRegAXIS: tb_sendRegAXIS.sv sendRegAXIS.sv Makefile
	iverilog -g2012 -o tb_sendRegAXIS tb_sendRegAXIS.sv sendRegAXIS.sv
	vvp tb_sendRegAXIS

tb_blinktLEDBar: tb_blinktLEDBar.sv blinktLEDBar.sv  Makefile
	iverilog -g2012 -o tb_blinktLEDBar tb_blinktLEDBar.sv blinktLEDBar.sv sendRegAXIS.sv
	echo "calling tb_blinktLEDBar"
	vvp tb_blinktLEDBar

clean:
	rm -rf  *.vcd  tb_sendRegAXIS tb_blinktLEDBar