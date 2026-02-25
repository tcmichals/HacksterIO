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
SPI_WB_MASTER = ../spi_wb_master.sv
PWM_DECODER = ../../pwmDecoder/pwmdecoder.v
PWM_DECODER_WB = ../../pwmDecoder/pwmdecoder_wb.v
NEOPX_WB = ../../neoPXStrip/wb_neoPx.v
NEOPX_SENDPX = ../../neoPXStrip/sendPx_axis_flexible.sv

.PHONY: all clean help
.PHONY: tb-spi-wb tb-spi-pwm tb-spi-neopx tb-all

all: tb-all

# ============================================================================
# SPI-WB Master Testbench
# Tests: single read, single write, burst read, invalid command
# ============================================================================
tb-spi-wb: spi_wb_master_tb.vvp
	@echo "=== Running SPI-WB Master Testbench ==="
	$(VVP) $<
	@echo ""

spi_wb_master_tb.vvp: spi_wb_master_tb.sv $(SPI_WB_MASTER) $(SPI_SLAVE)
	@echo "=== Compiling SPI-WB Master Testbench ==="
	$(IVERILOG) $(IVERILOG_FLAGS) $(INCLUDE_PATHS) -o $@ $^

# ============================================================================
# SPI-PWM Integration Testbench
# Tests: Generate PWM waveforms, read via SPI, verify values
# ============================================================================
tb-spi-pwm: spi_pwm_integration_tb.vvp
	@echo "=== Running SPI-PWM Integration Testbench ==="
	$(VVP) $<
	@echo ""

spi_pwm_integration_tb.vvp: spi_pwm_integration_tb.sv $(SPI_WB_MASTER) $(SPI_SLAVE) $(PWM_DECODER) $(PWM_DECODER_WB)
	@echo "=== Compiling SPI-PWM Integration Testbench ==="
	$(IVERILOG) $(IVERILOG_FLAGS) $(INCLUDE_PATHS) -o $@ $^

# ============================================================================
# SPI-NeoPixel Integration Testbench (uses existing wb_neoPx_tb as reference)
# ============================================================================
tb-spi-neopx: spi_neopx_integration_tb.vvp
	@echo "=== Running SPI-NeoPixel Integration Testbench ==="
	$(VVP) $<
	@echo ""

spi_neopx_integration_tb.vvp: spi_neopx_integration_tb.sv $(SPI_WB_MASTER) $(SPI_SLAVE) $(NEOPX_WB) $(NEOPX_SENDPX)
	@echo "=== Compiling SPI-NeoPixel Integration Testbench ==="
	$(IVERILOG) $(IVERILOG_FLAGS) $(INCLUDE_PATHS) -o $@ $^

# ============================================================================
# Run all SPI testbenches
# ============================================================================
tb-all: tb-spi-wb tb-spi-pwm
	@echo "=== All SPI Testbenches Complete ==="

# ============================================================================
# Waveform viewing
# ============================================================================
wave-spi-wb: spi_wb_master_tb.vcd
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
	@echo "  make tb-spi-wb    - Run SPI-WB Master testbench (read/write/burst)"
	@echo "  make tb-spi-pwm   - Run SPI-PWM integration test (PWM waveform → SPI read)"
	@echo "  make tb-spi-neopx - Run SPI-NeoPixel integration test"
	@echo "  make tb-all       - Run all SPI testbenches"
	@echo ""
	@echo "  make wave-spi-wb  - View SPI-WB Master waveform"
	@echo "  make wave-spi-pwm - View SPI-PWM waveform"
	@echo ""
	@echo "  make clean        - Remove generated files"
	@echo "  make help         - Show this message"
