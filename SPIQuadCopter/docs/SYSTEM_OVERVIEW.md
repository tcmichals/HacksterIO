# Tang9K FPGA Quadcopter System Overview

## Architecture

The system has two independent Wishbone bus masters:

1. **SERV RISC-V CPU** - Handles MSP protocol, ESC configuration, motor control
2. **SPI-WB Master** - External host (Raspberry Pi) reads/writes flight control peripherals

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              Tang9K FPGA (72 MHz)                           │
│                                                                             │
│  ┌─────────────┐                                                            │
│  │ Raspberry Pi│                                                            │
│  │  SPI Master │                                                            │
│  └──────┬──────┘                                                            │
│         │ SPI                                                               │
│         ▼                                                                   │
│  ┌─────────────┐                                                            │
│  │  spi_slave  │                                                            │
│  └──────┬──────┘                                                            │
│         │                                                                   │
│         ▼                                                                   │
│  ┌──────────────┐                                                           │
│  │spi_wb_master │                                                           │
│  │ (Protocol:   │                                                           │
│  │  A1=Read     │                                                           │
│  │  A2=Write)   │                                                           │
│  └──────┬───────┘                                                           │
│         │                                                                   │
│         │ Wishbone                                                          │
│         ▼                                                                   │
│  ┌─────────────┐         ┌────────────────────────────────┐                 │
│  │  wb_mux_6   │         │      SERV RISC-V CPU           │                 │
│  │ (SPI Bus)   │         │   (bit-serial, ~2.25 MIPS)     │                 │
│  │             │         │                                │                 │
│  │ Peripherals:│         │   ┌──────────┐  ┌──────────┐   │                 │
│  │ - Version R │         │   │ 8KB RAM  │  │ Firmware │   │                 │
│  │ - LED    RW │         │   │ (I+D)    │  │ (.mem)   │   │                 │
│  │ - PWM    R  │         │   └──────────┘  └──────────┘   │                 │
│  │ - DSHOT  RW │◄──┐     └───────────┬────────────────────┘                 │
│  │ - NeoPixel  │   │                 │                                      │
│  │ - MuxMirror │   │                 │ Wishbone (External Bus)              │
│  └─────────────┘   │                 ▼                                      │
│                    │          ┌─────────────┐                               │
│   wb_arbiter_2 ────┤          │  wb_mux_5   │                               │
│   (DSHOT shared)   │          │ (SERV Bus)  │                               │
│                    │          └──────┬──────┘                               │
│                    │                 │                                      │
│                    │     ┌───────────┼───────────┬───────────┬──────────┐   │
│                    │     ▼           ▼           ▼           ▼          ▼   │
│                    │ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ │
│                    │ │ Debug  │ │ DSHOT  │ │  Mux   │ │  USB   │ │  ESC   │ │
│                    │ │ GPIO   │ │(arbiter│ │  Reg   │ │  UART  │ │  UART  │ │
│                    │ │0x100   │ │0x400   │ │0x700   │ │0x800   │ │0x900   │ │
│                    │ └───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘ └───┬────┘ │
│                    │     │          │          │          │          │      │
│                    └─────┼──────────┘          │          │          │      │
│                          │                     │          │          │      │
│                          ▼                     │          │          │      │
│                    o_debug[2:0]                │          │          │      │
│                                                │          │          │      │
│                                    mux_sel ◄───┘          │          │      │
│                                    mux_ch                 │          │      │
│                                       │                   │          │      │
│                                       ▼                   ▼          │      │
│                              ┌─────────────────────────────────┐     │      │
│                              │   Motor Pin Mux (4ch)           │     │      │
│                              │  mux_sel=0: ESC UART ◄──────────┼─────┘      │
│                              │  mux_sel=1: DSHOT output        │            │
│                              └─────────────┬───────────────────┘            │
│                                            │                                │
└────────────────────────────────────────────┼────────────────────────────────┘
                                             │
              ┌──────────────────────────────┼──────────────────────────────┐
              │                              │                              │
              ▼                              ▼                              │
       USB UART Pin                   Motor Pins [3:0]                      │
       (PC @ 115200)                  (Half-duplex to ESCs)                 │
```

## SERV RISC-V CPU

- **Core**: SERV bit-serial RISC-V (RV32I)
- **Clock**: 72 MHz
- **Performance**: ~2.25 MIPS (32 cycles/instruction)
- **Memory**: 8KB shared I/D RAM
- **Firmware**: Loaded from `serv/firmware/firmware.mem`

## Dual-Bus Architecture

### SERV Wishbone Bus (wb_mux_5)
SERV handles protocol bridging and ESC configuration:

| Address        | Peripheral     | Access | Description                           |
|----------------|----------------|--------|---------------------------------------|
| 0x4000_0100    | Debug GPIO     | RW     | 3-bit digital output for debugging    |
| 0x4000_0400    | DSHOT (arbiter)| RW     | Motor control (shared with SPI)       |
| 0x4000_0700    | Mux Register   | RW     | DSHOT vs UART mode select             |
| 0x4000_0800    | USB UART       | RW     | MSP from PC (115200 baud)             |
| 0x4000_0900    | ESC UART       | RW     | Half-duplex to ESC (19200 baud)       |

### SPI Wishbone Bus (wb_mux_6)
External flight controller accesses sensors and actuators:

| Address  | Peripheral     | Access | Description                    |
|----------|----------------|--------|--------------------------------|
| 0x0000   | Version        | R      | Hardware version register      |
| 0x0100   | LED Controller | RW     | 4 output LEDs                  |
| 0x0200   | PWM Decoder    | R      | 6-channel pulse widths (μs)    |
| 0x0300   | DSHOT (arbiter)| RW     | Motor control (shared with SERV)|
| 0x0400   | NeoPixel       | RW     | 8x WS2812 LEDs                 |
| 0x0500   | Mux Mirror     | R      | Read-only shadow of mux reg    |

### DSHOT Arbiter
Both SERV and SPI buses can access DSHOT controller via `wb_arbiter_2`:
- SERV has priority (for MSP_SET_MOTOR testing)
- SPI access for normal flight control

## Motor Pin Mux

Each motor pin can operate in two modes controlled by `WB_MUX_REG`:

| Mode | mux_sel | Motor Pin Function |
|------|---------|-------------------|
| UART | 0       | Half-duplex ESC UART (selected by mux_ch) |
| DSHOT| 1       | DSHOT motor output |

**mux_ch** (bits 2:1) selects which motor channel (0-3) to use for ESC UART when in UART mode.

## ESC Configuration Flow

SERV bridges BLHeli configuration from PC to ESC:

```
PC (BLHeliSuite)
    ↓ USB (115200)
USB UART → SERV CPU → ESC UART
                         ↓ (19200, half-duplex)
                    Motor Pin [mux_ch]
                         ↓
                       ESC
```

1. PC sends BLHeli packets via USB UART
2. SERV receives via `WB_USB_RX_DATA`
3. SERV sets mux to UART mode: `WB_MUX_REG = (channel << 1) | 0`
4. SERV forwards bytes to ESC via `WB_ESC_TX_DATA`
5. ESC responses read via `WB_ESC_RX_DATA`
6. SERV sends responses back via `WB_USB_TX_DATA`

## Debug GPIO

Fast 3-bit output for debugging with logic analyzer:

| Register Offset | Function |
|-----------------|----------|
| 0x00            | OUT - Direct write |
| 0x04            | SET - Set bits (OR) |
| 0x08            | CLR - Clear bits (AND NOT) |
| 0x0C            | TGL - Toggle bits (XOR) |

Debug values in firmware:
- 0 = Reset/idle
- 1 = Processor running
- 2 = Main loop
- 3 = USB RX received
- 4 = MSP frame start
- 5 = MSP frame complete
- 6 = TX done
- 7 = Error

---

## Module Summary

| Module | Purpose |
|--------|---------|
| tang9k_top.sv | Top-level: instantiates all buses, arbiters, peripherals |
| serv-core/ | SERV bit-serial RISC-V CPU |
| wb_mux_5.v | 5-port Wishbone mux for SERV bus |
| wb_mux_6.v | 6-port Wishbone mux for SPI bus |
| wb_arbiter_2.sv | 2-master arbiter for shared DSHOT |
| spi_slave.sv | SPI slave interface |
| spi_wb_master.sv | SPI-to-Wishbone protocol bridge |
| wb_debug_gpio.sv | 3-bit debug GPIO for SERV |
| wb_dshot_controller.sv | 4-channel DSHOT150 output |
| wb_led_controller.sv | 6-LED PWM controller |
| wb_usb_uart.sv | USB UART (115200 baud) |
| wb_esc_uart.sv | ESC half-duplex UART (19200 baud) |
| wb_neoPx.v | NeoPixel WS2812 controller |
| pwmdecoder_wb.v | 6-channel PWM input decoder |

## Timing Notes

- **System Clock**: 72 MHz from PLL (27 MHz crystal input)
- **SERV**: Bit-serial, ~2.25 MIPS at 72 MHz
- **USB UART**: 115200 baud, 8-N-1 (625 clocks/bit)
- **ESC UART**: 19200 baud, 8-N-1 (3750 clocks/bit)
- **DSHOT150**: 150 kbps, 480 clocks/bit
- **NeoPixel**: WS2812 timing (0.4/0.8 μs high, 0.85/0.45 μs low)

## Use Cases

### Normal Flight Operation (SPI Master)
1. Read PWM inputs from receiver (0x0200)
2. Write motor commands via DSHOT (0x0300)
3. Update NeoPixel status LEDs (0x0400)
4. Monitor LED indicators (0x0100)

### ESC Configuration (BLHeli via SERV)
1. PC sends MSP commands over USB UART
2. SERV detects 4-Way Interface protocol
3. SERV reads mux register to select ESC channel
4. SERV bridges USB ↔ ESC UART at 19200 baud
5. Configure ESC parameters via BLHeli tool

### Debugging
1. Set Debug GPIO pins from SERV firmware
2. Observe o_debug[2:0] on oscilloscope
3. Values 0-7 indicate program state

---
For more details, see individual module files and header comments.
