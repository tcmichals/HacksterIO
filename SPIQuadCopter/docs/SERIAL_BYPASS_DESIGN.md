# Serial Bypass (Passthrough) Mechanism

The Serial Bypass feature enables transparent communication between a PC (running ESC configurators) and the ESCs via the Tang9K FPGA. It uses a "Smart Bridge" architecture that separates the high-speed protocol logic from the low-speed physical interfaces.

## Architecture & Hierarchy

The design is organized into logical layers, moving from high-speed PC protocols down to the physical motor pins.

### System Data Flow
```text
       PC (115200)
           |
           v
+-----------------------+
|  USB UART Interface   | <--- PC Physical Layer (115200)
+-----------------------+
           |
           | Bytes (115200)
           v
+-------------------------------------------------------+
|                Smart Protocol Layer                   |
|  +-------------------+         +-------------------+  |
|  |   MSP Handler     | <-----> |   4-Way Handler   |  |
|  |  (Discovery/ID)   |         | (Binary/CRC/Strip)|  |
|  +-------------------+         +-------------------+  |
+-------------------------------------------------------+
           |                             |
           | 115200 Bytes (PC Side)      | 19200 Bytes (ESC Side)
           v                             v
+-------------------------------------------------------+
|                Baud Rate Dispatcher                   |
|        (FIFO Buffering & Clock Domain Muxing)         |
+-------------------------------------------------------+
           |
           v
+-----------------------+
|  ESC Serial Interface | <--- ESC Physical Layer (19200)
|  (Half-Duplex Logic)  |
+-----------------------+
           |
           v
      [ Motor Pad ]
      (1-Wire ESC)
```

## Functional Layers

### 1. Physical Layer (Lower Level)
*   **USB Transceiver (115200)**: Decodes incoming USB UART traffic into parallel bytes and encodes outgoing bytes for the PC.
*   **ESC Transceiver (19200)**: Handles the 1-wire half-duplex communication with the ESC. It manages the High-Z tri-state switching and includes echo-suppression logic.

### 2. Smart Protocol Layer (High Level)
*   **MSP Discovery**: Continuously monitors the 115200 baud stream for standard `$M<` headers. It responds to `MSP_IDENT` with the board ID ("T9K-FC") to tell the PC that a bridge is present.
*   **4-Way Management (`four_way_handler.sv`)**: Handles the complex Betaflight binary protocol. It receives high-speed frames (0x2F header), validates the CRC16-XMODEM checksum, strips the headers, and forwards the payload to the low-speed ESC bridge.

### 3. Dispatcher Layer (Middle Level)
*   **Mode Persistence**: Manages the `mux_sel` state. It automatically switches to Passthrough mode when protocol activity is detected and reverts to DSHOT via a 5-second inactivity watchdog.
*   **Rate Matching (FIFO)**: Buffers data to bridge the ~6:1 speed difference between USB (115200) and the ESC (19200).

## Hardware Safety & Robustness
*   **Default Safe**: Reverts to DSHOT mode on reset or watchdog timeout.
*   **Non-Target Gating**: When configuring ESC #1, motor pads 2-4 are held at a steady logic High (Idle) to prevent noise from being interpreted as motor commands.
*   **CRC Validation**: Firmware flashing via the 4-way protocol is protected by hardware CRC calculation, preventing corrupted data from reaching the ESC.

## Register Definitions (0x0400)
| Bits | Name | Description |
|:---:|:---|:---|
| 0 | `mux_sel` | 0=Passthrough, 1=DSHOT (Default) |
| 2:1| `mux_ch` | Target motor channel (0-3) |
| 3 | `msp_mode` | Enable standalone MSP discovery mode |
| 31:4| - | Reserved |
