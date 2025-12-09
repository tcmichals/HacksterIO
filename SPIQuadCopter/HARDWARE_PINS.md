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
| 17  | i_uart_rx | Input | Debug UART RX | Optional console |
| 18  | o_uart_tx | Output | Debug UART TX | Optional console |
| **19** | **i_usb_uart_rx** | **Input** | **USB UART RX** | **USB adapter TX** |
| **20** | **o_usb_uart_tx** | **Output** | **USB UART TX** | **USB adapter RX** |
| **25** | **serial** | **Bidir** | **ESC Serial** | **ESC signal wire** |
| 26-29 | i_pwm_ch[0-3] | Input | PWM Inputs | RC receiver channels |
| 30-33 | o_motor[1-4] | Output | DSHOT Outputs | ESC control signals |
| 34  | o_neopixel | Output | NeoPixel Data | WS2812 LED strip |
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
                    │  Pin 25 (serial) ◄──► ESC Signal         │
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
| Signal      | Pin 25     | Half-duplex serial communication |
| GND         | GND        | Common ground with Tang9K and adapter |
| +5V (motor) | **DO NOT CONNECT** | ESC powered separately |

**Step 3: Power Connections**

- Tang9K: Powered via USB or separate 3.3V supply
- USB Adapter: Powered via USB connection to PC
- ESC: Powered via motor battery (LiPo)
- **All GNDs must be connected together**

## Hardware Passthrough Architecture

The Tang9K contains a hardware UART bridge that operates independently of the Wishbone bus:

```
FPGA Internal Architecture:
┌─────────────────────────────────────────────────────────────┐
│                        Tang9K FPGA                          │
│                                                             │
│  Pin 19 ──▶ UART RX ──┐                                    │
│                        │                                    │
│                        ├─▶ Passthrough  ──┐                │
│                        │   Bridge          │                │
│  Pin 20 ◄── UART TX ◄──┘   (mux_sel=0)   │                │
│                                            ▼                │
│                                    Half-Duplex Serial       │
│                                            │                │
│                                            ▼                │
│  Pin 25 ◄───────────────────── Tri-State Buffer           │
│                                                             │
│  Wishbone Bus ──▶ Mux Control Register (0x0400)           │
│                   └─▶ mux_sel signal                       │
└─────────────────────────────────────────────────────────────┘
```

### Operating Modes

**Passthrough Mode (mux_sel = 0)**
- Hardware bridge: USB UART ↔ ESC Serial
- Python TUI: Writes 0 to address 0x0400
- BLHeli Tool: Connects to /dev/ttyUSB0 (USB adapter)
- Data flow: Pure hardware, no software intervention
- Latency: Minimal (<1ms)

**DSHOT Mode (mux_sel = 1)**
- Passthrough bridge disabled (tri-stated)
- DSHOT controller drives motor outputs
- Python TUI: Writes 1 to address 0x0400
- Data flow: Wishbone → DSHOT → Motors
- Normal flight operations

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
