# Protocol Testbench Suite for Tang9K

This document describes the protocol-level testbench for the Tang9K FPGA project, covering all MSP commands and BLHeli passthrough/ESC simulation.

## Running the Testbench

To run the full protocol test suite:

```
make tb-msp-proto
```

This will compile and run `src/tb/msp_protocol_tb.sv`, printing results for all tested commands and scenarios.

## What is Tested?

- **All MSP commands** handled by the FPGA, including:
  - MSP_IDENT
  - MSP_STATUS
  - MSP_API_VERSION
  - MSP_FC_VARIANT
  - MSP_FC_VERSION
  - MSP_BOARD_INFO
  - MSP_BUILD_INFO
  - MSP_NAME
  - MSP_SET_PASSTHROUGH
  - Edge cases: bad checksum, unknown command
- **BLHeli Passthrough/ESC simulation**
  - Simulates sending BLHeli commands from PC to ESC
  - Simulates ESC replies
  - Multi-byte frame and error case coverage

## Output

- Each test prints the command, the FPGA's reply, and any simulated ESC response.
- Timeouts and protocol errors are reported.
- The testbench will never lock up (global watchdog included).

## How to Interpret Results

- For each command, check that the reply matches the expected protocol (see `ESC_COMMUNICATION_PROTOCOL.md`).
- For passthrough, verify that sent and received bytes match the simulated scenario.
- Any `[TIMEOUT]` or `[EDGE CASE]` output indicates a protocol error or unhandled case.

## Extending the Suite

- Add new MSP commands or ESC scenarios by editing `src/tb/msp_protocol_tb.sv`.
- For new hardware features, add corresponding protocol tests here.

---

For more details, see:
- `docs/ESC_COMMUNICATION_PROTOCOL.md`
- `docs/BLHELI_PASSTHROUGH.md`
- `README.md`
