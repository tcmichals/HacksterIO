# Vivado Source Files for Arty-S7 SPI Copter

This document lists all source files needed to build the SPI Copter system in Vivado.

## Required Files for Vivado Project

### Top-Level Files (Verilog)
```
ArtS7-50/arty_s7_spi_copter_top.v        # Top-level module (use this as top)
ArtS7-50/wb_spisystem_wrapper.v           # Verilog wrapper for wb_spisystem
ArtS7-50/spi_slave_wb_bridge_wrapper.v    # Verilog wrapper for SPI bridge
```

### Core System Files (SystemVerilog - Vivado supports these)
```
src/wb_spisystem.sv                       # Main peripheral system
src/spi_slave_wb_bridge.sv                # SPI to Wishbone protocol bridge
spiSlave/spi_slave.sv                     # SPI slave interface
```

### Peripheral Modules (SystemVerilog)
```
src/wb_led_controller.sv                  # LED controller peripheral
src/wb_dshot_controller.sv                # DSHOT motor controller
src/wb_serial_dshot_mux.sv                # Serial/DSHOT mux control
dshot/dshot_150.v                         # DSHOT150 protocol encoder
dshot/dshot_out.v                         # DSHOT output driver
```

### PWM Decoder (Verilog)
```
pwmDecoder/pwmdecoder.v                   # PWM pulse width decoder
pwmDecoder/pwmdecoder_wb.v                # Wishbone wrapper for PWM decoder
```

### NeoPixel Controller (SystemVerilog + Verilog)
```
neoPXStrip/sendPx_axis_flexible.sv        # NeoPixel bit encoder
neoPXStrip/wb_neoPx.v                     # Wishbone wrapper for NeoPixel
```

### Version Register
```
version/wb_version.sv                     # Hardware version register
```

### Wishbone Infrastructure (Verilog)
```
verilog-wishbone/rtl/wb_mux.v             # Wishbone multiplexer
verilog-wishbone/rtl/arbiter.v            # Wishbone arbiter (if needed)
```

## Adding Files to Vivado

### Method 1: GUI (Vivado Block Designer)

1. **Create New Project**:
   - File → Project → New...
   - Select Arty-S7-50 board (xc7s50csga324-1)

2. **Add Source Files**:
   - Add Sources (Alt+A)
   - Add or create design sources
   - Add all files listed above
   - **Check "Copy sources into project"** to avoid path issues

3. **Set Top Module**:
   - Right-click on `arty_s7_spi_copter_top.v`
   - Set as Top

4. **Add Constraints** (create XDC file):
   - See `arty_s7_pinout.xdc` example below

5. **Add to Block Design** (Optional):
   - Create Block Design
   - Right-click → Add Module
   - Select `wb_spisystem_wrapper`
   - Connect to your processor/logic

### Method 2: TCL Script

```tcl
# Create project
create_project spi_copter ./spi_copter_project -part xc7s50csga324-1

# Add source files
add_files {
    ../ArtS7-50/arty_s7_spi_copter_top.v
    ../ArtS7-50/wb_spisystem_wrapper.v
    ../ArtS7-50/spi_slave_wb_bridge_wrapper.v
    ../src/wb_spisystem.sv
    ../src/spi_slave_wb_bridge.sv
    ../spiSlave/spi_slave.sv
    ../src/wb_led_controller.sv
    ../src/wb_dshot_controller.sv
    ../src/wb_serial_dshot_mux.sv
    ../dshot/dshot_150.v
    ../dshot/dshot_out.v
    ../pwmDecoder/pwmdecoder.v
    ../pwmDecoder/pwmdecoder_wb.v
    ../neoPXStrip/sendPx_axis_flexible.sv
    ../neoPXStrip/wb_neoPx.v
    ../version/wb_version.sv
    ../verilog-wishbone/rtl/wb_mux.v
}

# Add constraints
add_files -fileset constrs_1 ../ArtS7-50/arty_s7_pinout.xdc

# Set top module
set_property top arty_s7_spi_copter_top [current_fileset]

# Update compile order
update_compile_order -fileset sources_1
```

## Example XDC Constraints File

Create `ArtS7-50/arty_s7_pinout.xdc`:

```tcl
## Clock (100 MHz)
set_property -dict {PACKAGE_PIN R2 IOSTANDARD SSTL135} [get_ports clk_100m]
create_clock -period 10.000 -name sys_clk [get_ports clk_100m]

## Reset Button (BTN0)
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS33} [get_ports reset_n]

## SPI Interface (example: use ChipKit connector)
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports spi_cs_n]
set_property -dict {PACKAGE_PIN V10 IOSTANDARD LVCMOS33} [get_ports spi_mosi]
set_property -dict {PACKAGE_PIN V11 IOSTANDARD LVCMOS33} [get_ports spi_miso]

## GPIO Mux Control (example: use ChipKit pins)
set_property -dict {PACKAGE_PIN T5 IOSTANDARD LVCMOS33} [get_ports gpio_mux_sel]
set_property -dict {PACKAGE_PIN U5 IOSTANDARD LVCMOS33} [get_ports gpio_mux_ch0]
set_property -dict {PACKAGE_PIN U2 IOSTANDARD LVCMOS33} [get_ports gpio_mux_ch1]
set_property -dict {PACKAGE_PIN U4 IOSTANDARD LVCMOS33} [get_ports gpio_msp_mode]

## LEDs
set_property -dict {PACKAGE_PIN E18 IOSTANDARD LVCMOS33} [get_ports led0]
set_property -dict {PACKAGE_PIN F13 IOSTANDARD LVCMOS33} [get_ports led1]
set_property -dict {PACKAGE_PIN E13 IOSTANDARD LVCMOS33} [get_ports led2]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports led3]

## PWM Inputs (example: Pmod JA)
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports pwm_ch0]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports pwm_ch1]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports pwm_ch2]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports pwm_ch3]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports pwm_ch4]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports pwm_ch5]

## Motor Outputs (example: Pmod JB - high-speed capable pins)
set_property -dict {PACKAGE_PIN E15 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports motor1]
set_property -dict {PACKAGE_PIN E16 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports motor2]
set_property -dict {PACKAGE_PIN D15 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports motor3]
set_property -dict {PACKAGE_PIN C15 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports motor4]

## NeoPixel Output
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33 SLEW FAST} [get_ports neopixel]

## Debug Outputs (example: Pmod JC)
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports debug0]
set_property -dict {PACKAGE_PIN V14 IOSTANDARD LVCMOS33} [get_ports debug1]
set_property -dict {PACKAGE_PIN T13 IOSTANDARD LVCMOS33} [get_ports debug2]
```

## Build Steps

1. **Open Vivado** (2020.1 or later)
2. **Create project** using TCL script or GUI
3. **Run Synthesis**:
   - Flow Navigator → Synthesis → Run Synthesis
4. **Run Implementation**:
   - Flow Navigator → Implementation → Run Implementation
5. **Generate Bitstream**:
   - Flow Navigator → Program and Debug → Generate Bitstream
6. **Program FPGA**:
   - Open Hardware Manager
   - Connect to Arty-S7 board
   - Program Device

## Notes

- **SystemVerilog Support**: Vivado fully supports SystemVerilog, so the .sv files will compile fine
- **Verilog Wrappers**: The .v wrapper files are provided for convenience in Block Designer
- **Clock Frequency**: Default is 100 MHz. Adjust `CLK_FREQ_HZ` parameter if using different clock
- **Pin Mapping**: The XDC example above uses arbitrary pins - adjust to your actual board connections
- **DSHOT Timing**: Ensure motor output pins are on high-speed capable banks for DSHOT150 (480 ns bit period)

## Verification

After programming:
1. Test SPI communication by reading version register (address 0x0000)
2. Write to LED controller (address 0x0100) to verify LED outputs
3. Test DSHOT motor control (address 0x0300)
4. Verify PWM decoder inputs (address 0x0200)

See [../docs/SYSTEM_OVERVIEW.md](../docs/SYSTEM_OVERVIEW.md) for peripheral register details.
