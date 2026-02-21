# SPIQuadCopter Data Flow Architecture

```mermaid
graph TD
    A[PC/BLHeli Suite] --> B[USB UART 115200]

    B --> C{MSP Mode Enabled?}

    C -->|Yes| D[MSP Handler]
    D --> E[MSP Protocol Parser]
    E --> F[MSP Response Generator]
    F --> G[USB UART TX 115200]
    G --> H[PC Response]

    C -->|No| I[Passthrough Bridge]
    I --> J[Baud Converter<br/>115200 → 19200]
    J --> K[Serial TX/OE]
    K --> L[Mux<br/>Serial/DSHOT]
    L --> M[Motor Pins<br/>to ESC]

    M --> N[Serial RX<br/>from ESC]
    N --> L
    L --> O[Serial RX]
    O --> J
    J --> P[Baud Converter<br/>19200 → 115200]
    P --> Q[USB UART TX 115200]
    Q --> H

    R[SPI Master<br/>FC Software] --> S[SPI Slave]
    S --> T[Wishbone Bus]
    T --> U[Mux Register<br/>Control]
    U --> C
    U --> L
```

## Architecture Overview

The SPIQuadCopter FPGA has two mutually exclusive operating modes controlled by SPI register:

### MSP FC Protocol Mode (msp_mode = 1)
- Direct USB UART communication with PC
- MSP Handler parses FC commands and generates responses
- Bypasses motor pins and passthrough bridge
- Used for FC protocol testing and configuration

### BLHeli Passthrough Mode (msp_mode = 0)
- USB UART ↔ Serial baud conversion for ESC communication
- Routes through motor pins via mux
- Traditional BLHeli ESC configuration mode

### Control
- Mode selection via SPI register bit 3 (`msp_mode`)
- Motor channel selection via SPI register bits 2:1 (`mux_ch`)
- Serial/DSHOT selection via SPI register bit 0 (`mux_sel`)