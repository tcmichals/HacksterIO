# System Block Diagram (Mermaid)

This file contains a Mermaid diagram for the SPIQuadCopter system. You can preview this in VS Code (Mermaid extension) or on GitHub (if Mermaid is enabled).

```mermaid
flowchart TB
  subgraph EXTERNAL["External Interfaces"]
    SPI_MASTER["SPI Master\n(Flight Controller)"]
    USB["USB UART\n(PC/Configurator)"]
    ESC["ESCs\n(Motor 0-3)"]
    RC["RC Receiver"]
  end

  subgraph FPGA["Tang Nano 9K FPGA (72 MHz)"]

    subgraph SPI_BUS["SPI Bus (wb_mux_6)"]
      direction TB
      SPI_SLAVE["SPI Slave"]
      SPI_WB["spi_wb_master"]
      VER["Version\n(0x0000)"]
      LED["LED Controller\n(0x0100)"]
      PWM["PWM Decoder\n(0x0200)"]
      NEOPX["NeoPixel\n(0x0400)"]
      MUX_MIRROR["Mux Mirror\n(0x0500)"]
    end

    subgraph ARBITER["Shared Resource"]
      DSHOT["DSHOT Controller\n(0x0300)\nwb_arbiter_2"]
    end

    subgraph SERV_BUS["SERV Bus (wb_mux_5)"]
      direction TB
      SERV["SERV RISC-V\n(Bit-serial RV32I)"]
      DEBUG_GPIO["Debug GPIO\n(0x100)"]
      MUX_REG["Mux Register\n(0x700)"]
      USB_UART["USB UART\n(0x800)\n115200 baud"]
      ESC_UART["ESC UART\n(0x900)\n19200 baud"]
    end

  end

  %% SPI Bus connections
  SPI_MASTER -->|SPI| SPI_SLAVE
  SPI_SLAVE --> SPI_WB
  SPI_WB --> VER
  SPI_WB --> LED
  SPI_WB --> PWM
  SPI_WB --> NEOPX
  SPI_WB --> MUX_MIRROR
  SPI_WB --> DSHOT

  %% SERV Bus connections
  SERV --> DEBUG_GPIO
  SERV --> MUX_REG
  SERV --> USB_UART
  SERV --> ESC_UART
  SERV --> DSHOT

  %% External connections
  USB <-->|115200| USB_UART
  ESC_UART <-->|19200| ESC
  RC --> PWM
  DSHOT --> ESC

  %% Mux register -> motor pin selection
  MUX_REG -.->|channel select| ESC_UART
```

## Architecture Notes

### Dual Wishbone Bus
- **SPI Bus**: Flight controller access to peripherals
- **SERV Bus**: CPU handles protocol processing

### Shared DSHOT
- `wb_arbiter_2` allows both buses to access DSHOT controller
- Priority: Round-robin arbitration

### ESC Configuration Flow
1. PC connects via USB UART (115200 baud)
2. SERV firmware detects MSP/4-Way protocol
3. Mux register selects ESC channel (0-3)
4. SERV bridges USB ↔ ESC UART (19200 baud)

