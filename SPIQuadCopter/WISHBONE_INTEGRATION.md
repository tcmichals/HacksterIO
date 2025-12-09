# Wishbone Integration Summary

## Files Added

### SystemVerilog Modules

1. **`src/wb_led_controller.sv`**
   - Wishbone B3 slave for LED control
   - Register-based interface for LED outputs and modes
   - 2 registers: LED_OUT (0x00) and LED_MODE (0x04)

2. **`src/wb_ttl_serial.sv`**
   - Wishbone B3 slave for TTL Serial UART
   - Complete UART register interface (TX, RX, Status, Control)
   - 4 registers: TX_DATA (0x00), RX_DATA (0x04), STATUS (0x08), CTRL (0x0C)
   - Instantiates the ttl_serial core module

### Documentation

1. **`WISHBONE_BUS.md`**
   - Complete Wishbone integration guide
   - Address maps for all slave modules
   - Timing characteristics
   - Example usage patterns
   - Future extension ideas

## Architecture

```
┌────────────────────────────────────┐
│        Tang9K Top Module           │
│                                    │
│  ┌───────────────────────────────┐ │
│  │   Clock Generation (PLL)      │ │
│  │   - 27 MHz (input)            │ │
│  │   - 72 MHz (output)           │ │
│  └───────────────────────────────┘ │
│                                    │
│  Peripherals:                      │
│  ┌─────────────────────────────────────────┐
│  │  Wishbone Devices (Future Integration)  │
│  │  ├─ wb_led_controller (address: 0x00)  │
│  │  └─ wb_ttl_serial (address: 0x04)      │
│  │                                         │
│  │  Traditional Interfaces (Current):      │
│  │  ├─ LED Blinker (27 MHz)               │
│  │  ├─ SPI Slave                          │
│  │  └─ UART (pins)                        │
│  └─────────────────────────────────────────┘
└────────────────────────────────────┘
```

## Wishbone Features

### LED Controller
- **Address Base**: 0x00 (configurable)
- **Registers**: 2 (LED_OUT, LED_MODE)
- **Access**: Read/Write
- **Data Width**: 32 bits
- **Latency**: 1 cycle

### TTL Serial Controller
- **Address Base**: 0x04 (configurable)
- **Registers**: 4 (TX_DATA, RX_DATA, STATUS, CTRL)
- **Access**: TX/RX read/write, Status read-only, Control read/write
- **Data Width**: 32 bits
- **Baud Rate**: Configurable (default 115,200)
- **Clock**: 72 MHz (default)
- **Latency**: 1 cycle

## Next Steps for Full Integration

To fully integrate the Wishbone bus:

1. **Create Wishbone Multiplexer**
   ```verilog
   wb_mux_2 u_wb_mux (
       .wbm_* (from SPI master),
       .wbs0_* (to LED controller),
       .wbs1_* (to UART controller)
   );
   ```

2. **Implement SPI to Wishbone Bridge**
   - Convert SPI commands to Wishbone cycles
   - Or use existing SPI slave as Wishbone master

3. **Address Mapping**
   - 0x0000_0000: LED Controller
   - 0x0000_0004: TTL Serial Controller
   - Additional devices as needed

4. **Testing**
   - Simulation testbenches for each Wishbone slave
   - Integration tests via SPI interface

## Compilation

The new modules are included in the main Makefile:

```makefile
SRCS := ... src/wb_led_controller.sv src/wb_ttl_serial.sv ...
```

Build normally:
```bash
make build
```

## Register Interface Details

### LED Controller Registers

**0x00 - LED Output Register**
```
[3:0] LED output control (1=on, 0=off)
[31:4] Reserved
```

**0x04 - LED Mode Register**
```
[3:0] LED mode (0=manual, 1=blink, 2-15=reserved)
[31:4] Reserved
```

### TTL Serial Registers

**0x00 - TX Data Register (Write Only)**
```
[7:0] Data byte to transmit
[31:8] Ignored on write
```

**0x04 - RX Data Register (Read Only)**
```
[7:0] Last received byte
[31:8] Reserved
```

**0x08 - Status Register (Read Only)**
```
[0] rx_valid (1=data ready)
[1] tx_ready (1=can transmit)
[31:2] Reserved
```

**0x0C - Control Register (Read/Write)**
```
[0] half_duplex_en (1=TX mode, 0=RX mode)
[1] baud_rate_sel (reserved)
[31:2] Reserved
```

## Performance

- **Wishbone Cycle Time**: 1 clock (@72 MHz = 13.9 ns)
- **LED Update Latency**: <15 ns
- **UART TX Latency**: <15 ns + serial transmission time
- **UART RX Latency**: Serial reception time + <15 ns capture

## Future Enhancements

- [ ] Add SPI-to-Wishbone master bridge
- [ ] Implement Wishbone multiplexer with address decode
- [ ] Add RX/TX FIFOs to UART
- [ ] Interrupt support
- [ ] GPIO port with configurable I/O
- [ ] ADC/DAC integration
- [ ] Memory bus interconnect
