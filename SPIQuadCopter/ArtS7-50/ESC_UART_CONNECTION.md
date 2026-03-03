# ESC UART Connection Guide for Vivado

This guide shows how to connect your Vivado RISC-V processor's UART for ESC BLHeli passthrough.

## Architecture

```
PC (BLHeliSuite)
    ↓ USB
Vivado UART IP (115200 baud) ← Connect to PC via USB-UART
    ↓
RISC-V Processor (firmware bridges USB ↔ ESC)
    ↓
ESC UART (19200 baud) ← Connect to motor mux
    ↓
wb_spisystem_wrapper (motor pin mux with half-duplex)
    ↓
Motor pins (bidirectional)
    ↓
ESC (BLHeli firmware)
```

## Required Signals

The `wb_spisystem_wrapper` requires 3 signals from your ESC UART:

| Signal | Direction | Description |
|--------|-----------|-------------|
| `esc_uart_tx` | Input | UART TX from processor |
| `esc_uart_rx` | Output | UART RX to processor |
| `esc_uart_tx_en` | Input | TX enable (high when transmitting) |

## Connection Options

### Option 1: GPIO-Controlled TX_EN (RECOMMENDED)

The simplest approach - use a GPIO pin from your processor to control TX_EN:

```verilog
// In your Vivado block design or HDL:
arty_s7_spi_copter_top u_fpga_peripherals (
    .clk(clk),
    .reset_n(!rst),
    // ... other signals ...
    
    // ESC UART signals
    .esc_uart_tx(uart_tx_from_processor),
    .esc_uart_rx(uart_rx_to_processor),
    .esc_uart_tx_en(gpio_esc_tx_en)  // From processor GPIO
);
```

**Processor firmware:**
```c
// Before transmitting
gpio_set_esc_tx_en(1);    // Enable TX, disable RX

// Send data
esc_uart_write_byte(data);
esc_uart_wait_tx_complete();

// After transmission
gpio_set_esc_tx_en(0);    // Disable TX, enable RX

// Now can receive
uint8_t response = esc_uart_read_byte();
```

**Advantages:**
- Simple and reliable
- No additional hardware needed
- Full firmware control over direction
- Works with any UART IP

### Option 2: UART with Built-in TX_EN

### Option 2: UART with Built-in TX_EN

If your Vivado UART IP has a TX enable signal (check datasheet), you can connect it directly:

```verilog
// In your Vivado block design or top-level
axi_uartlite_0 u_esc_uart (
    .s_axi_aclk(clk),
    .s_axi_aresetn(!rst),
    // ... AXI interface to RISC-V ...
    .rx(esc_uart_rx_wire),
    .tx(esc_uart_tx_wire),
    .tx_enable(esc_uart_tx_en_wire)  // If available
);

// Connect to wb_spisystem_wrapper
arty_s7_spi_copter_top u_fpga_peripherals (
    .clk(clk),
    .reset_n(!rst),
    // ... other signals ...
    .esc_uart_tx(esc_uart_tx_wire),
    .esc_uart_rx(esc_uart_rx_wire),
    .esc_uart_tx_en(esc_uart_tx_en_wire)
);
```

### Option 2: UART without TX_EN (Use Helper Module)

If your UART doesn't provide TX_EN, use the provided helper module:

```verilog
// UART IP
axi_uartlite_0 u_esc_uart (
    .s_axi_aclk(clk),
    .s_axi_aresetn(!rst),
    // ... AXI interface ...
    .rx(esc_uart_rx_wire),
    .tx(esc_uart_tx_wire)
);

// Generate TX enable signal
uart_tx_enable_gen u_tx_en_gen (
    .clk(clk),
    .rst(rst),
    .uart_tx(esc_uart_tx_wire),
    .uart_tx_en(esc_uart_tx_en_wire)
);

// Connect to wb_spisystem_wrapper
arty_s7_spi_copter_top u_fpga_peripherals (
    .clk(clk),
    .reset_n(!rst),
    // ... other signals ...
    .esc_uart_tx(esc_uart_tx_wire),
    .esc_uart_rx(esc_uart_rx_wire),
    .esc_uart_tx_en(esc_uart_tx_en_wire)
);
```

### Option 3: Software-Controlled TX_EN

You can also use a GPIO pin from your processor to control TX_EN:

```verilog
// In processor firmware:
// Set GPIO high before transmitting
// Set GPIO low after transmitting

// In HDL:
arty_s7_spi_copter_top u_fpga_peripherals (
    // ... other signals ...
    .esc_uart_tx(esc_uart_tx_from_processor),
    .esc_uart_rx(esc_uart_rx_to_processor),
    .esc_uart_tx_en(gpio_esc_tx_en)  // From processor GPIO
);
```

## GPIO Mux Control Signals

Your processor also needs to control the motor mux mode via 3 GPIO pins:

| GPIO Pin | Signal | Description |
|----------|--------|-------------|
| GPIO[0] | `gpio_mux_sel` | 0=UART mode, 1=DSHOT mode |
| GPIO[1] | `gpio_mux_ch0` | Motor channel select bit 0 |
| GPIO[2] | `gpio_mux_ch1` | Motor channel select bit 1 |

Motor channel (0-3) selects which motor pin receives the ESC UART in UART mode.

## Complete Example (Vivado Block Design)

```tcl
# Create RISC-V processor block
# (Use your preferred RISC-V IP - VexRiscv, NEORV32, etc.)

# Create ESC UART (19200 baud)
create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite_esc
set_property -dict [list CONFIG.C_BAUDRATE {19200}] [get_bd_cells axi_uartlite_esc]

# Connect AXI interface to processor
connect_bd_intf_net [get_bd_intf_pins riscv/M_AXI] [get_bd_intf_pins axi_uartlite_esc/S_AXI]

# Add FPGA peripheral module
create_bd_cell -type module -reference arty_s7_spi_copter_top fpga_peripherals

# Connect ESC UART
connect_bd_net [get_bd_pins axi_uartlite_esc/tx] [get_bd_pins fpga_peripherals/esc_uart_tx]
connect_bd_net [get_bd_pins axi_uartlite_esc/rx] [get_bd_pins fpga_peripherals/esc_uart_rx]

# Connect GPIO for mux control (from processor GPIO IP)
connect_bd_net [get_bd_pins riscv_gpio/gpio_io_o[0]] [get_bd_pins fpga_peripherals/gpio_mux_sel]
connect_bd_net [get_bd_pins riscv_gpio/gpio_io_o[1]] [get_bd_pins fpga_peripherals/gpio_mux_ch0]
connect_bd_net [get_bd_pins riscv_gpio/gpio_io_o[2]] [get_bd_pins fpga_peripherals/gpio_mux_ch1]

# If UART has TX_EN:
connect_bd_net [get_bd_pins axi_uartlite_esc/tx_enable] [get_bd_pins fpga_peripherals/esc_uart_tx_en]

# OR use helper module:
create_bd_cell -type module -reference uart_tx_enable_gen tx_en_gen
connect_bd_net [get_bd_pins axi_uartlite_esc/tx] [get_bd_pins tx_en_gen/uart_tx]
connect_bd_net [get_bd_pins tx_en_gen/uart_tx_en] [get_bd_pins fpga_peripherals/esc_uart_tx_en]
```

## Processor Firmware Requirements

Your RISC-V firmware needs to:

1. **Receive BLHeli commands** from PC via USB UART (115200 baud)
2. **Set GPIO[0] = 0** to switch to UART mode
3. **Set GPIO[2:1]** to select motor channel (0-3)
4. **Forward commands** to ESC UART (19200 baud)
5. **Read ESC responses** from ESC UART
6. **Send responses** back to PC via USB UART
7. **Set GPIO[0] = 1** when done to return to DSHOT mode

Minimal example:
```c
// Switch to UART mode for motor 0
gpio_write(0x0);  // mux_sel=0 (UART), mux_ch=0

// Forward byte from USB to ESC
uint8_t data = usb_uart_read();
esc_uart_write(data);

// Read response
uint8_t response = esc_uart_read();
usb_uart_write(response);

// Return to DSHOT mode
gpio_write(0x1);  // mux_sel=1 (DSHOT)
```

## Files Needed

- `ArtS7-50/arty_s7_spi_copter_top.v` - Top-level module
- `ArtS7-50/wb_spisystem_wrapper.v` - Peripheral wrapper
- `ArtS7-50/uart_tx_enable_gen.v` - Helper for TX enable (optional)
- All source files from `src/`, `spiSlave/`, `pwmDecoder/`, `neoPXStrip/`, etc.

## Testing

1. Program FPGA with your design
2. Run BLHeliSuite on PC
3. Select "BLHeli 32" or "BLHeli_S" as appropriate
4. Connect via USB
5. Your RISC-V firmware should detect passthrough commands and enable bridge
6. BLHeliSuite should detect ESCs and allow configuration

See [README.md](../README.md) and [BLHELI_QUICKSTART.md](../docs/BLHELI_QUICKSTART.md) for more details.
