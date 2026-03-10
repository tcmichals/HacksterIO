# Makefile for SPI Wishbone testbenches

IVERILOG ?= iverilog
VVP ?= vvp
GTK ?= gtkwave

# Common flags
IVERILOG_FLAGS = -g2012 -Wall

# Include paths
INCLUDE_PATHS = -I.. -I../.. -I../../spiSlave -I../../pwmDecoder -I../../neoPXStrip

# Common source files
SPI_SLAVE = ../../spiSlave/spi_slave.sv
SPI_SLAVE_WB_BRIDGE = ../spi_slave_wb_bridge.sv
PWM_DECODER = ../../pwmDecoder/pwmdecoder.v
PWM_DECODER_WB = ../../pwmDecoder/pwmdecoder_wb.v
NEOPX_WB = ../../neoPXStrip/wb_neoPx.v
NEOPX_SENDPX = ../../neoPXStrip/sendPx_axis_flexible.sv
WB_USB_UART = ../wb_usb_uart.sv
UART_TX = ../../verilog-uart/rtl/uart_tx.v
UART_RX = ../../verilog-uart/rtl/uart_rx.v

.PHONY: all clean help
.PHONY: tb-spi-wb tb-spi-pwm tb-spi-neopx tb-all

all: tb-all

# ============================================================================
# SPI Slave to Wishbone Bridge Testbench
# Tests: single read, single write, burst read, invalid command
# ============================================================================
tb-spi-wb: spi_slave_wb_bridge_tb.vvp
	@echo "=== Running SPI Slave WB Bridge Testbench ==="
	$(VVP) $<
	@echo ""

spi_slave_wb_bridge_tb.vvp: spi_slave_wb_bridge_tb.sv $(SPI_SLAVE_WB_BRIDGE) $(SPI_SLAVE)
	@echo "=== Compiling SPI Slave WB Bridge Testbench ==="
	$(IVERILOG) $(IVERILOG_FLAGS) $(INCLUDE_PATHS) -o $@ $^

# ============================================================================
# SPI-PWM Integration Testbench
# Tests: Generate PWM waveforms, read via SPI, verify values
# ============================================================================
tb-spi-pwm: spi_pwm_integration_tb.vvp
	@echo "=== Running SPI-PWM Integration Testbench ==="
	$(VVP) $<
	@echo ""

spi_pwm_integration_tb.vvp: spi_pwm_integration_tb.sv $(SPI_SLAVE_WB_BRIDGE) $(SPI_SLAVE) $(PWM_DECODER) $(PWM_DECODER_WB)
	@echo "=== Compiling SPI-PWM Integration Testbench ==="
	$(IVERILOG) $(IVERILOG_FLAGS) $(INCLUDE_PATHS) -o $@ $^

# ============================================================================
# SPI-NeoPixel Integration Testbench (uses existing wb_neoPx_tb as reference)
# ============================================================================
tb-spi-neopx: spi_neopx_integration_tb.vvp
	@echo "=== Running SPI-NeoPixel Integration Testbench ==="
	$(VVP) $<
	@echo ""

spi_neopx_integration_tb.vvp: spi_neopx_integration_tb.sv $(SPI_SLAVE_WB_BRIDGE) $(SPI_SLAVE) $(NEOPX_WB) $(NEOPX_SENDPX)
	@echo "=== Compiling SPI-NeoPixel Integration Testbench ==="
	$(IVERILOG) $(IVERILOG_FLAGS) $(INCLUDE_PATHS) -o $@ $^

# ============================================================================
# USB UART Testbench
# Tests: TX ready/busy, send multiple bytes
# ============================================================================
tb-usb-uart: wb_usb_uart_tb.vvp
	@echo "=== Running USB UART Testbench ==="
	$(VVP) $<
	@echo ""

wb_usb_uart_tb.vvp: wb_usb_uart_tb.sv $(WB_USB_UART) $(UART_TX) $(UART_RX)
	@echo "=== Compiling USB UART Testbench ==="
	$(IVERILOG) $(IVERILOG_FLAGS) $(INCLUDE_PATHS) -o $@ $^

wave-usb-uart: wb_usb_uart_tb.vcd
	$(GTK) $< &

# ============================================================================
# USB UART + MUX Testbench (realistic SERV-like behavior)
# ============================================================================
tb-usb-uart-mux: wb_usb_uart_mux_tb.vvp
	@echo "=== Running USB UART+MUX Testbench ==="
	$(VVP) $<
	@echo ""

wb_usb_uart_mux_tb.vvp: wb_usb_uart_mux_tb.sv $(WB_USB_UART) $(UART_TX) $(UART_RX) ../wb_mux_6.v
	@echo "=== Compiling USB UART+MUX Testbench ==="
	$(IVERILOG) $(IVERILOG_FLAGS) $(INCLUDE_PATHS) -o $@ $^

wave-usb-uart-mux: wb_usb_uart_mux_tb.vcd
	$(GTK) $< &

# ============================================================================
# Run all SPI testbenches
# ============================================================================
tb-all: tb-spi-wb tb-spi-pwm
	@echo "=== All SPI Testbenches Complete ==="

# ============================================================================
# Waveform viewing
# ============================================================================
wave-spi-wb: spi_slave_wb_bridge_tb.vcd
	$(GTK) $< &

wave-spi-pwm: spi_pwm_integration_tb.vcd
	$(GTK) $< &

# ============================================================================
# Cleanup
# ============================================================================
clean:
	rm -f *.vvp *.vcd

help:
	@echo "SPI Wishbone Testbench Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make tb-spi-wb    - Run SPI Slave WB Bridge testbench (read/write/burst)"
	@echo "  make tb-spi-pwm   - Run SPI-PWM integration test (PWM waveform → SPI read)"
	@echo "  make tb-spi-neopx - Run SPI-NeoPixel integration test"
	@echo "  make tb-usb-uart  - Run USB UART TX/RX testbench"
	@echo "  make tb-all       - Run all SPI testbenches"
	@echo ""
	@echo "  make wave-spi-wb  - View SPI-WB Master waveform"
	@echo "  make wave-spi-pwm - View SPI-PWM waveform"
	@echo "  make wave-usb-uart - View USB UART waveform"
	@echo ""
	@echo "  make clean        - Remove generated files"
	@echo "  make help         - Show this message"
