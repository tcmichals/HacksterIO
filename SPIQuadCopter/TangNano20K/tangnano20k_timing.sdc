# Tang Nano 20K (Gowin GW2AR-18) Timing Constraints
# Generated for SPI Quadcopter project with VexRiscv
# Note: nextpnr-himbaechel has limited SDC support

# -----------------------------------------------------------------------------
# Input Clock: 27 MHz crystal oscillator
# -----------------------------------------------------------------------------
create_clock -name clk_27mhz -period 37.037 [get_ports {clk_27mhz}]

# -----------------------------------------------------------------------------
# SPI Interface (from external master)
# -----------------------------------------------------------------------------
# SPI clock from master - assume up to 10 MHz
create_clock -name spi_clk -period 100.0 [get_ports {spi_sck}]
# set_multicycle_path 1 -hold -from [get_pins {u_system/u_ram/*}]
