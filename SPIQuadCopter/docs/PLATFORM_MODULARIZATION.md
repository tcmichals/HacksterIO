# Platform Modularization - Refactoring Summary

## Overview

The SPIQuadCopter system has been refactored to support multiple FPGA platforms (Tang9K, TangPrimer25k, Arty-S7-50) with a clean, modular architecture.

## ⚠️ Important: Toolchain Requirements

**OSS CAD Suite Build System (This Makefile):**
- ✅ **Tang Nano 9K** - Fully supported (Gowin GW1NR-9C, GW1N series)
- ❌ **TangPrimer25k** - Requires Gowin IDE (GW5A-25 NOT supported by OSS tools)
- ❌ **Arty-S7-50** - Requires Xilinx Vivado (proprietary, NOT OSS tools)

The `Makefile` in this project is configured exclusively for **Tang Nano 9K** using the open-source toolchain (yosys, nextpnr-himbaechel, gowin_pack). 

**Important:** The GW5A series used in TangPrimer25k is NOT supported by OSS CAD Suite - it requires Gowin's proprietary IDE, similar to how Xilinx FPGAs need Vivado. Only the older GW1N series (Tang Nano 9K) works with open-source tools.

## What Changed

### Before (Single-Platform)
- **src/wb_spisystem.sv** (now `src/system_top_legacy.sv`): Monolithic 880-line module with SERV processor, RAM, and all peripherals hard-coded together
- Only worked for Tang9K platform
- Difficult to port to other platforms

### After (Multi-Platform)

#### New Files Created:

1. **src/wb_spisystem.sv** (Parameterized Peripheral System)
   - Contains only peripherals and Wishbone buses
   - **NO** processor instantiation (processor-agnostic)
   - Exposes CPU Wishbone interface as input ports
   - Parameter `ENABLE_CPU_BUS`: Set to 1 for Tang platforms, 0 for Arty-S7
   - Shared across **all platforms**

2. **src/common_serv_spi_top.sv** (Tang Platform Wrapper)
   - Instantiates SERV processor + 8KB RAM
   - Instantiates wb_spisystem with ENABLE_CPU_BUS=1
   - Wires SERV to wb_spisystem CPU interface
   - Used by **Tang9K and TangPrimer25k only**

3. **src/tang9k_top.sv** (Tang9K Board Top)
   - PLL: 27 MHz → 72 MHz
   - Reset generation and synchronization
   - Heartbeat LED on LED6
   - Instantiates common_serv_spi_top
   - **FPGA-specific** (board pins, clock, reset)

4. **ArtS7-50/arty_s7_top_example.sv** (Arty-S7 Example Template)
   - Shows how to use wb_spisystem without SERV
   - ENABLE_CPU_BUS=0 (no CPU Wishbone bus)
   - External mux control via 3 GPIO signals
   - Template for integrating your own processor

## Architecture

### Dual Wishbone Bus System (Preserved)

Both buses remain fully functional after refactoring:

```
┌─────────────────────────────────────────────────────────────┐
│                     wb_spisystem.sv                          │
│            (Shared, Parameterized Module)                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  CPU Wishbone Bus (0x4000_xxxx)                     │   │
│  │  (enabled when ENABLE_CPU_BUS=1)                    │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  • Debug GPIO (0x40000100)                          │   │
│  │  • DSHOT Controller (0x40000400, via arbiter)       │   │
│  │  • Serial/DSHOT Mux (0x40000700)                    │   │
│  │  • USB UART (0x40000800, 115200 baud MSP)           │   │
│  │  • ESC UART (0x40000900, 19200 baud BLHeli)         │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  SPI Wishbone Bus (0x0000_xxxx)                     │   │
│  │  (always enabled for external SPI control)          │   │
│  ├─────────────────────────────────────────────────────┤   │
│  │  • Version Register (0x0000)                        │   │
│  │  • LED Controller (0x0100)                          │   │
│  │  • PWM Decoder (0x0200)                             │   │
│  │  • DSHOT Controller (0x0300, via arbiter)           │   │
│  │  • NeoPixel (0x0400)                                │   │
│  │  • Mux Mirror (0x0500, read-only status)            │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Tang Nano 9K Architecture (Current - OSS CAD Suite)

```
tang9k_top.sv (Board-specific)
└── PLL (27 MHz → 72 MHz)
└── Reset Logic
└── Heartbeat (LED6)
└── common_serv_spi_top.sv (Platform wrapper)
    ├── SERV Processor (bit-serial RISC-V)
    ├── 8KB RAM (firmware.mem)
    └── wb_spisystem.sv (ENABLE_CPU_BUS=1)
        ├── CPU Wishbone Bus (5 peripherals)
        └── SPI Wishbone Bus (6 peripherals)
```

### TangPrimer25k Architecture (Future - Gowin IDE)

```
tangprimer25k_top.sv (Board-specific, when implemented)
└── PLL (for GW5A-25)
└── Reset Logic
└── common_serv_spi_top.sv (Platform wrapper)
    ├── SERV Processor (bit-serial RISC-V)
    ├── RAM (firmware)
    └── wb_spisystem.sv (ENABLE_CPU_BUS=1)
        ├── CPU Wishbone Bus (5 peripherals)
        └── SPI Wishbone Bus (6 peripherals)

Note: Same RTL as Tang9K, different FPGA and toolchain
```

### Arty-S7-50 Architecture (Example)

```
arty_s7_top.sv (Board-specific)
└── Clock/Reset (your implementation)
└── Your Processor (AXI-based RISC-V)
    └── GPIO[3:0] → ext_mux_sel, ext_mux_ch, ext_msp_mode
└── wb_spisystem.sv (ENABLE_CPU_BUS=0)
    ├── No CPU Wishbone Bus
    ├── External mux control (from GPIO)
    └── SPI Wishbone Bus (6 peripherals)
```

## Platform Comparison

| Feature | Tang Nano 9K | TangPrimer25k | Arty-S7-50 |
|---------|--------------|---------------|------------|
| **Toolchain** | **OSS CAD Suite (Open Source)** | **Gowin IDE (Proprietary)** | **Xilinx Vivado (Proprietary)** |
| **FPGA** | GW1NR-9C (GW1N) | GW5A-25 (Arora) | XC7S50 (Spartan-7) |
| **Processor** | SERV (Wishbone) | SERV (Wishbone) | Your RISC-V (AXI) |
| **CPU Bus** | Enabled (ENABLE_CPU_BUS=1) | Enabled (ENABLE_CPU_BUS=1) | Disabled (ENABLE_CPU_BUS=0) |
| **Mux Control** | CPU Wishbone @ 0x40000700 | CPU Wishbone @ 0x40000700 | External GPIO (3 signals) |
| **USB UART** | Hardware @ 0x40000800 | Hardware @ 0x40000800 | Implement in processor |
| **ESC UART** | Hardware @ 0x40000900 | Hardware @ 0x40000900 | Implement in processor |
| **DSHOT Control** | CPU or SPI bus | CPU or SPI bus | SPI bus only |
| **Mux Status** | CPU @ 0x40000700 or SPI @ 0x0500 | CPU @ 0x40000700 or SPI @ 0x0500 | SPI @ 0x0500 |
| **This Makefile** | ✅ **Supported** | ❌ Use Gowin IDE | ❌ Use Vivado TCL/XDC |

## Parameter: ENABLE_CPU_BUS

Controls whether the CPU Wishbone bus and peripherals are instantiated:

### ENABLE_CPU_BUS = 1 (Tang Nano 9K, TangPrimer25k)
- CPU Wishbone bus **enabled**
- 5 CPU peripherals instantiated:
  - Debug GPIO
  - DSHOT (via arbiter)
  - Serial/DSHOT Mux control register
  - USB UART
  - ESC UART
- Mux control from internal Wishbone register
- External mux inputs ignored

### ENABLE_CPU_BUS = 0 (Arty-S7)
- CPU Wishbone bus **disabled**
- No CPU peripherals instantiated
- Mux control from external GPIO inputs:
  - `ext_mux_sel`: 0=UART mode, 1=DSHOT mode
  - `ext_mux_ch[1:0]`: Motor channel (0-3) for UART mode
  - `ext_msp_mode`: MSP mode indicator
- Saves FPGA resources
- Processor handles MSP/BLHeli in software

## External Mux Control (Arty-S7)

When ENABLE_CPU_BUS=0, connect your processor GPIO to these signals:

```systemverilog
module arty_s7_top (
    // Your processor GPIO outputs
    input logic gpio_mux_sel,      // GPIO[0]: 0=UART, 1=DSHOT
    input logic [1:0] gpio_mux_ch, // GPIO[2:1]: Motor channel
    input logic gpio_msp_mode,     // GPIO[3]: MSP mode
    ...
);

    wb_spisystem #(
        .CLK_FREQ_HZ(100_000_000),
        .ENABLE_CPU_BUS(0)  // No CPU bus
    ) u_wb_spisystem (
        // External mux control
        .ext_mux_sel(gpio_mux_sel),
        .ext_mux_ch(gpio_mux_ch),
        .ext_msp_mode(gpio_msp_mode),
        ...
    );
```

Your processor firmware can:
1. Control mux via 3 GPIO bits (no Wishbone needed!)
2. Read mux status via SPI at address 0x0500
3. Implement MSP protocol handler
4. Implement BLHeli UART passthrough

## Building

### Tang9K (Current Platform - OSS CAD Suite)

**This is the ONLY platform that works with the open-source toolchain.**

```bash
make build    # Synthesize for Tang9K using tang9k_top.sv
make upload   # Program FPGA via openFPGALoader
```

Build uses these files:
- `src/tang9k_top.sv` (board top)
- `src/common_serv_spi_top.sv` (platform wrapper)
- `src/wb_spisystem.sv` (peripherals, ENABLE_CPU_BUS=1)

**Toolchain:** OSS CAD Suite (yosys, nextpnr-himbaechel, gowin_pack)

### TangPrimer25k (Future - Requires Gowin IDE)

**NOT supported by OSS CAD Suite!** TangPrimer25k uses GW5A-25 (Arora family), which requires Gowin's proprietary IDE.

If/when implemented with Gowin IDE:
- Create `src/tangprimer25k_top.sv` (copy tang9k_top.sv)
- Update PLL for GW5A-25
- Create Gowin IDE project with .gprj file
- Add pin constraints

Would use same `common_serv_spi_top.sv` and `wb_spisystem.sv` RTL

**Toolchain:** Gowin EDA (proprietary, like Vivado for Xilinx)

### Arty-S7-50 (Future - Requires Proprietary Vivado)

**Requires Xilinx Vivado - NOT compatible with OSS CAD Suite!**

1. Copy `ArtS7-50/arty_s7_top_example.sv` → `arty_s7_top.sv`
2. Add your processor instantiation
3. Connect GPIO outputs to ext_mux_* inputs
4. Create XDC constraints file
5. Use Vivado for synthesis/implementation (not this Makefile)

Uses `wb_spisystem.sv` with ENABLE_CPU_BUS=0

**Toolchain:** Xilinx Vivado (proprietary)

## Files Changed

### Modified
- `Makefile`: Added new source files to SRCS list
- `src/wb_spisystem.sv`: Completely rewritten (parameterized, processor-agnostic)

### Created
- `src/common_serv_spi_top.sv`: Tang platform wrapper
- `src/tang9k_top.sv`: Tang9K board top-level
- `ArtS7-50/arty_s7_top_example.sv`: Arty-S7 integration example

### Preserved
- `src/system_top_legacy.sv`: Backup of original working implementation
- `src/wb_spisystem.sv.backup`: Safety backup

### Unchanged
All peripheral modules remain identical:
- `src/wb_dshot_controller.sv`
- `src/wb_serial_dshot_mux.sv`
- `src/wb_usb_uart.sv`
- `src/wb_esc_uart.sv`
- `src/wb_led_controller.sv`
- `neoPXStrip/wb_neoPx.v`
- `pwmDecoder/pwmdecoder_wb.v`
- `version/wb_version.sv`
- All Wishbone infrastructure (muxes, arbiters)
- SERV processor files

## Testing Checklist

### Tang9K Verification
- [ ] Build completes without errors: `make build`
- [ ] Upload to FPGA: `make upload`
- [ ] LED6 heartbeat blinks at 1 Hz (PLL working)
- [ ] SPI communication works (test LED controller @ 0x0100)
- [ ] DSHOT motors respond (test via SPI @ 0x0300)
- [ ] USB UART echo test (SERV MSP bridge)
- [ ] BLHeli ESC configuration via USB passthrough
- [ ] PWM decoder reads RC inputs correctly

### Code Quality
- [x] No syntax errors (verified with get_errors)
- [ ] No synthesis warnings
- [ ] No timing violations
- [ ] Functional equivalence with legacy implementation

## Migration Path

If issues occur during testing:

1. **Revert to working version:**
   ```bash
   mv src/wb_spisystem.sv src/wb_spisystem_new.sv
   mv src/system_top_legacy.sv src/wb_spisystem.sv
   mv src/tang9k_top.sv src/tang9k_top_new.sv
   # Update Makefile TOP to system_top
   make build upload
   ```

2. **Compare implementations:**
   - Check signal naming differences
   - Verify parameter values match
   - Review clock/reset synchronization

3. **Incremental debugging:**
   - Test SPI bus first (always enabled)
   - Then verify CPU bus (ENABLE_CPU_BUS=1)
   - Check DSHOT arbiter sharing

## Benefits of Refactoring

1. **Platform Independence**: wb_spisystem.sv works on any FPGA
2. **Code Reuse**: One peripheral system for all platforms
3. **Maintainability**: Fix bugs once, all platforms benefit
4. **Flexibility**: ENABLE_CPU_BUS parameter for different processor architectures
5. **Documentation**: Clear separation of concerns (board → platform → peripherals)
6. **Testing**: Can simulate wb_spisystem without board-specific code

## Next Steps

1. **Verify Tang9K build** (current priority)
2. Create TangPrimer25k variant when needed
3. Implement Arty-S7 integration when AXI processor ready
4. Consider adding more platforms (iCE40, ECP5, etc.)
5. Document processor firmware interface (GPIO, SPI registers)

## Questions?

- Architecture: See [docs/SYSTEM_OVERVIEW.md](docs/SYSTEM_OVERVIEW.md)
- Build process: See [docs/BUILD_AND_PROGRAM.md](docs/BUILD_AND_PROGRAM.md)
- SERV processor: See `serv/firmware/README.md`
- Dual-bus design: See [docs/SPI_SLAVE_WB_BRIDGE_DESIGN.md](docs/SPI_SLAVE_WB_BRIDGE_DESIGN.md)

---

**Last Updated:** 2025-01-26  
**Status:** Refactoring complete, ready for testing  
**Original Implementation:** Preserved in `src/system_top_legacy.sv`
