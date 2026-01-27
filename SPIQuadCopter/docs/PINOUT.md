# Tang Nano 9K Pinout Reference

## 🗺️ Physical Board Layout

```text
                  USB-C Port
               ┌──────────────┐
               │    [====]    │
          GND ─┤ [1]      [48]├─ 5V
        VCC33 ─┤ [2]      [47]├─ GND
   (RST) P03  ─┤ [3]      [46]├─ P88
  (SCLK) P25  ─┤ [4]      [45]├─ P87
  (CS_N) P26  ─┤ [5]      [44]├─ P85
  (MOSI) P27  ─┤ [6]      [43]├─ P86
  (MISO) P28  ─┤ [7]      [42]├─ P42 (Motor 2)
   (L1)  P10  ─┤ [8]      [41]├─ P41 (Motor 3)
   (L2)  P11  ─┤ [9]      [40]├─ P40 (NeoPixel)
   (L3)  P13  ─┤[10]      [39]├─ P39
   (L4)  P14  ─┤[11]      [38]├─ P38
   (L5)  P15  ─┤[12]      [37]├─ P37
   (L6)  P16  ─┤[13]      [36]├─ P36
   (TX)  P20  ─┤[14]      [35]├─ P35 (Motor 4)
   (RX)  P19  ─┤[15]      [34]├─ P34
         P77  ─┤[16]      [33]├─ P33
         P76  ─┤[17]      [32]├─ P32 (Debug 0)
         P75  ─┤[18]      [31]├─ P31 (Debug 1)
  (PWM5) P53  ─┤[19]      [30]├─ P30
  (PWM4) P54  ─┤[20]      [29]├─ P29
  (PWM3) P56  ─┤[21]      [28]├─ P28
  (PWM2) P57  ─┤[22]      [27]├─ P27
  (PWM1) P68  ─┤[23]      [26]├─ P26
  (PWM0) P69  ─┤[24]      [25]├─ P51 (Motor 1)
               └──────────────┘
```

> [!NOTE]
> Pin numbers in square brackets `[XX]` refer to the physical header position.
> Pin numbers prefixed with `P` (e.g. `P42`) refer to the labels printed on the board.

## 🚁 Motor Connections (DSHOT & Serial Passthrough)

These pins are bidirectional and managed by the [wb_serial_dshot_mux](../../src/wb_serial_dshot_mux.sv).

| Signal | Tang9K Pin | Function | Notes |
|--------|------------|----------|-------|
| `o_motor1` | **51** | Motor 1 (Front Right) | LVCMOS33, Pull-up enabled |
| `o_motor2` | **42** | Motor 2 (Rear Right) | LVCMOS33, Pull-up enabled |
| `o_motor3` | **41** | Motor 3 (Rear Left)  | LVCMOS33, Pull-up enabled |
| `o_motor4` | **35** | Motor 4 (Front Left) | LVCMOS33, Pull-up enabled |

## 🎮 RC Receiver (PWM Inputs)

| Channel | Tang9K Pin | Function | Notes |
|---------|------------|----------|-------|
| `i_pwm_ch0` | **69** | Roll | Pull-down enabled |
| `i_pwm_ch1` | **68** | Pitch | Pull-down enabled |
| `i_pwm_ch2` | **57** | Throttle | Pull-down enabled |
| `i_pwm_ch3` | **56** | Yaw | Pull-down enabled |
| `i_pwm_ch4` | **54** | Aux 1 / Arm | Pull-down enabled |
| `i_pwm_ch5` | **53** | Aux 2 / Mode | Pull-down enabled |

## 💡 Visual Indicators & LEDs

| Signal | Tang9K Pin | Function | Notes |
|--------|------------|----------|-------|
| `o_neopixel` | **40** | NeoPixel Data Output | Connect to DIN on LED strip |
| `o_led_1` | **10** | On-board LED 1 | LVCMOS18 |
| `o_led_2` | **11** | On-board LED 2 | LVCMOS18 |
| `o_led_3` | **13** | On-board LED 3 | LVCMOS18 |
| `o_led_4` | **14** | On-board LED 4 | LVCMOS18 |
| `o_led_5` | **15** | On-board LED 5 | |
| `o_led_6` | **16** | On-board LED 6 | |

## 🖥️ Host Interface (SPI)

Used to connect to a Raspberry Pi or other host controller.

| Signal | Tang9K Pin | Raspberry Pi Pin | Function |
|--------|------------|------------------|----------|
| `i_spi_clk` | **25** | SCLK (23) | SPI Clock |
| `i_spi_cs_n` | **26** | CE0 (24) | Chip Select (Active Low) |
| `i_spi_mosi` | **27** | MOSI (19) | Master Out Slave In |
| `o_spi_miso` | **28** | MISO (21) | Master In Slave Out |

## 🔌 Serial Communication (USB UART)

Used for BLHeli passthrough and general debugging via a external USB-to-TTL adapter.

| Signal | Tang9K Pin | Function | Notes |
|--------|------------|----------|-------|
| `i_usb_uart_rx` | **19** | FPGA RX | Connect to Adapter TX |
| `o_usb_uart_tx` | **20** | FPGA TX | Connect to Adapter RX |

## ⚙️ System Controls

| Signal | Tang9K Pin | Function |
|--------|------------|----------|
| `i_clk` | **52** | 27MHz On-board Crystal |
| `i_rst_n` | **3** | Hard Reset (Active Low) |
| `o_debug_0` | **32** | General Debug Output |
| `o_debug_1` | **31** | General Debug Output |
| `o_debug_2` | **49** | General Debug Output |

---

*Verified against [tang9k.cst](../../tang9k.cst)*
