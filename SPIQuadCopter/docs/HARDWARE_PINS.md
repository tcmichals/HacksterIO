# Tang9K Hardware Pin Reference

## Pin Summary Table

| Pin | Signal Name | Direction | Function | Connection |
|-----|-------------|-----------|----------|------------|
| 3   | i_rst_n | Input | Reset (active low) | Reset button or pull-up |
| 4   | i_spi_clk | Input | SPI Clock | Raspberry Pi SCLK |
| 5   | i_spi_cs_n | Input | SPI Chip Select | Raspberry Pi CE0 |
| 6   | i_spi_mosi | Input | SPI MOSI | Raspberry Pi MOSI |
| 7   | o_spi_miso | Output | SPI MISO | Raspberry Pi MISO |
| 8-11 | o_led[0-3] | Output | Debug LEDs | LEDs with resistors |
| 15  | i_btn0 | Input | Button 0 | Push button |
| 16  | i_btn1 | Input | Button 1 | Push button |
| 17  | i_uart_rx | Input | Debug U ART RX | Optional console |
| 18  | o_uart_tx | Output | Debug UART TX | Optional console |
| 19 | i_usb_uart_rx | Input | USB UART RX | USB adapter TX |
| 20 | o_usb_uart_tx | Output | USB UART TX | USB adapter RX |
| ~~25~~ | ~~serial~~ | ~~Inout~~ | **REMOVED** - Serial passthrough now uses motor pins | ~~LVCMOS33~~ |
| 26-29 | i_pwm_ch[0-3] | Input | PWM Inputs | RC receiver channels |
| 30-31 | i_pwm_ch[4-5] | Input | PWM Inputs (Aux) | RC receiver aux channels |
| **32** | **o_motor1** | **Inout** | **DSHOT Motor 1 / Serial Passthrough** | **LVCMOS33 PULL_MODE=UP** |
| **33** | **o_motor2** | **Inout** | **DSHOT Motor 2 / Serial Passthrough** | **LVCMOS33 PULL_MODE=UP** |
| **34** | **o_motor3** | **Inout** | **DSHOT Motor 3 / Serial Passthrough** | **LVCMOS33 PULL_MODE=UP** |
| **35** | **o_motor4** | **Inout** | **DSHOT Motor 4 / Serial Passthrough** | **LVCMOS33 PULL_MODE=UP** |
| 51-54 | o_status_led[0-2] | Output | Status LEDs | Board status indicators |
| 52  | i_sys_clk | Input | System Clock | 27 MHz oscillator |

## BLHeli Passthrough Connections

### Required Hardware
- USB-to-TTL Serial Adapter (CP2102, FT232, CH340, or similar)
- 3.3V compatible (LVCMOS33)

### Wiring Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     BLHeli Configuration Setup                   │
└─────────────────────────────────────────────────────────────────┘

   ┌──────────┐                    ┌─────────────────┐
   │    PC    │                    │  USB-to-TTL     │
   │ (BLHeli) │────── USB ────────▶│  Adapter        │
   └──────────┘                    │  (CP2102/FT232) │
                                   └─────────────────┘
                                          │  │  │
                           ┌──────────────┘  │  └──────────────┐
                           │ TX              │ RX             │ GND
                           ▼                 ▼                ▼
                    ┌────────────────────────────────────────────┐
                    │           Tang9K FPGA Board               │
                    │                                            │
                    │  Pin 19 (i_usb_uart_rx) ◄── TX           │
                    │  Pin 20 (o_usb_uart_tx) ──► RX           │
                    │  GND ◄────────────────────── GND          │
                    │                                            │
                    │  **Pins 32-35 (o_motorX)** ◄──► **ESC Signal**    │
                    │  (Select ONE motor pin via mux_ch)       │
                    │  GND ◄───────────────► ESC GND            │
                    └────────────────────────────────────────────┘
                                   │
                                   ▼
                            ┌─────────────┐
                            │     ESC     │
                            │  (BLHeli)   │
                            └─────────────┘
```

### Step-by-Step Wiring

**Step 1: Connect USB-to-TTL Adapter to Tang9K**

| Adapter Pin | Tang9K Pin | Wire Color (typical) | Notes |
|-------------|------------|---------------------|--------|
| TX          | Pin 19     | Orange/Yellow       | Adapter transmits, Tang9K receives |
| RX          | Pin 20     | White/Green         | Tang9K transmits, adapter receives |
| GND         | GND        | Black               | Common ground essential |
| VCC/3.3V    | **DO NOT CONNECT** | Red      | Tang9K is self-powered |

**Step 2: Connect ESC to Tang9K**

| ESC Wire    | Tang9K Pin | Notes |
|-------------|------------|--------|
| Signal      | **Pin 32, 33, 34, or 35** | **Connect to ONE motor pin**. Select which pin via mux register (bits 2:1) |
| GND         | GND        | Common ground with Tang9K and adapter |
| +5V (motor) | **DO NOT CONNECT** | ESC powered separately |

**Mux Register Channel Selection (0x0400 bits 2:1)**:
- `0x00`: Motor 1 (Pin 32) - Front Right
- `0x02`: Motor 2 (Pin 33) - Rear Right
- `0x04`: Motor 3 (Pin 34) - Rear Left
- `0x06`: Motor 4 (Pin 35) - Front Left

**Step 3: Power Connections**

- Tang9K: Powered via USB or separate 3.3V supply
- USB Adapter: Powered via USB connection to PC
- ESC: Powered via motor battery (LiPo)
- **All GNDs must be connected together**

## Hardware Passthrough Architecture

The Tang9K routes serial passthrough through the motor pins using a mux:

```
FPGA Internal Architecture:
┌─────────────────────────────────────────────────────────────┐
│                        Tang9K FPGA                          │
│                                                             │
│  Pin 19 ──▶ UART RX ──┐                                    │
│                        │                                    │
│                        ├─▶ Passthrough  ──┐                │
│                        │   Bridge          │                │
│  Pin 20 ◄── UART TX ◄──┘   (enabled when │                │
│                            mux_sel=0)     │                │
│                                            ▼                │
│                                    Serial TX/RX             │
│                                            │                │
│                                            ▼                │
│  ┌────────────────────────────────────────────────┐        │
│  │        wb_serial_dshot_mux (0x0400)            │        │
│  │                                                 │        │
│  │   mux_sel (bit 0): 0=Passthrough, 1=DSHOT      │        │
│  │   mux_ch (bits 2:1): Which motor pin (0-3)     │        │
│  └────────────────────────────────────────────────┘        │
│                     │                │                      │
│  ┌──────────────────┴────────────────┴──────────┐          │
│  │                                                │          │
│  │  If mux_sel=0: Route serial to motor[mux_ch]  │          │
│  │  If mux_sel=1: Route DSHOT to all motors      │          │
│  └────────────────────────────────────────────────┘          │
│                     │           │                           │
│  Pin 32 (Motor1) ◄──┤           │◄── DSHOT 1                │
│  Pin 33 (Motor2) ◄──┤           │◄── DSHOT 2                │
│  Pin 34 (Motor3) ◄──┤           │◄── DSHOT 3                │
│  Pin 35 (Motor4) ◄──┴───────────┴◄── DSHOT 4                │
│                  (bidirectional inout)                       │
└─────────────────────────────────────────────────────────────┘
```

### Operating Modes

**Passthrough Mode (mux_sel = 0)**
- Hardware bridge: USB UART ↔ Motor Pin [mux_ch]
- Python TUI: Writes `0x00-0x06` to address 0x0400
- BLHeli Tool: Connects to /dev/ttyUSB0 (USB adapter)
- Selected motor pin becomes bidirectional (1-wire serial)
- Other motor pins are held low (idle)
- Data flow: Pure hardware, no software intervention
- Latency: Minimal (<1ms)

**DSHOT Mode (mux_sel = 1)**
- Passthrough bridge disabled
- DSHOT controller drives all motor outputs
- Python TUI: Writes `0x01` (or `0x03`, `0x05`, `0x07`) to address 0x0400
- All motor pins are outputs
- Data flow: Wishbone → DSHOT → Motors
- Normal flight operations

### Mux Register (0x0400) Format
```
Bit 31-3: Reserved (read as 0)
Bit 2:1 : mux_ch (Channel select)
Bit 0   : mux_sel (Mode select)

Examples:
  0x00 = Passthrough on Motor 1 (Pin 32)
  0x02 = Passthrough on Motor 2 (Pin 33)
  0x04 = Passthrough on Motor 3 (Pin 34)
  0x06 = Passthrough on Motor 4 (Pin 35)
  0x01 = DSHOT mode (normal flight)
```

## Pin Electrical Specifications

| Parameter | Value | Notes |
|-----------|-------|-------|
| Logic Level | LVCMOS33 | 3.3V compatible |
| Input High (VIH) | 2.0V min | |
| Input Low (VIL) | 0.8V max | |
| Output High (VOH) | 2.4V min @ 8mA | DRIVE=8 setting |
| Output Low (VOL) | 0.4V max @ 8mA | DRIVE=8 setting |
| Pull-up (serial) | Internal | ~50kΩ typical |
| Max Frequency | 72 MHz | System clock |

## Common Issues and Solutions

### Issue: BLHeli can't connect

**Check:**
1. ✓ Adapter TX → Tang9K Pin 19 (not reversed!)
2. ✓ Adapter RX → Tang9K Pin 20 (not reversed!)
3. ✓ ESC Signal → Tang9K Pin 25 (not pins 19/20!)
4. ✓ Common GND between adapter, Tang9K, and ESC
5. ✓ Passthrough enabled in TUI (mux_sel = 0)
6. ✓ Correct serial port selected in BLHeli (/dev/ttyUSB0)
7. ✓ Baud rate set to 115200

### Issue: Wrong pin connections

**Common Mistake:** Connecting ESC to pins 19/20 instead of pin 25
- Pins 19/20: USB UART (PC to FPGA)
- Pin 25: ESC Serial (FPGA to ESC)

**Correct Flow:** PC → USB Adapter → Pins 19/20 → FPGA Bridge → Pin 25 → ESC

### Issue: No ground connection

**Symptom:** Intermittent connections, garbage data, random resets

**Solution:** 
- Connect GND from USB adapter to Tang9K GND
- Connect GND from ESC to Tang9K GND
- Verify continuity with multimeter (should be <1Ω)

## Testing Your Wiring

### Test 1: Verify USB Adapter

```bash
# Plug in USB adapter
dmesg | tail -20

# Should see: USB Serial device detected
# Example: ttyUSB0: CP2102 USB to UART Bridge Controller
```

### Test 2: Verify FPGA Programming

```bash
cd python/test
python3 tang9k_tui.py --device /dev/spidev0.0

# Press 'p' to enable passthrough
# Status should show: Passthrough: ENABLED
```

### Test 3: Loopback Test (without ESC)

```bash
# Temporarily short pins 19 and 20 together
# Enable passthrough in TUI
# Open serial terminal:
screen /dev/ttyUSB0 115200

# Type characters - they should echo back
# If you see echo, FPGA bridge is working!
```

### Test 4: ESC Connection

```bash
# With ESC connected to pin 25
# Enable passthrough in TUI
# Open BLHeliSuite, select /dev/ttyUSB0, 115200 baud
# Click "Read Setup" - should connect to ESC
```

## See Also

- [BLHELI_PASSTHROUGH_SETUP.md](python/test/BLHELI_PASSTHROUGH_SETUP.md) - Software setup and usage
- [SYSTEM_OVERVIEW.md](SYSTEM_OVERVIEW.md) - Full system architecture
- [tang9k.cst](tang9k.cst) - Complete pin constraint file
- [tang9k_top.sv](src/tang9k_top.sv) - Top-level hardware module
