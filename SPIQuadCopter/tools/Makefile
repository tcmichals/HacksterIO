# tools/Makefile - simulation / testbench targets (optionally included from top-level Makefile)
# This file contains the `tb-design` and `tb-passthrough` targets.

# Use SRCS from the including Makefile if present; fall back to empty list so standalone usage doesn't fail.
ifeq ($(origin SRCS), undefined)
SRCS :=
endif

ifeq ($(origin INC), undefined)
INC :=
endif

# Note: testbenches accept simulator plusargs via VVP_ARGS (see examples below)

.PHONY: tb-design tb-passthrough tools-help

tools-help:
	@echo "Testbench targets (from tools/Makefile):"
	@echo "  make tb-design       - Compile & run src/tb/design_tb.sv via iverilog (uses SRCS if set)"
	@echo "  make tb-passthrough  - Compile & run src/tb/tang9k_top_tb.sv via iverilog (uses SRCS if set)"
	@echo ""
	@echo "Usage examples:"
	@echo "  make tb-design VVP_ARGS=\"+TEST_VERSION\"  # run only the Version test"
	@echo "  make tb-design VVP_ARGS=\"+TEST_VERSION +VERBOSE\"  # add TB verbose logging"
	@echo "  make tb-passthrough VVP_ARGS=\"+HELP\"  # pass arbitrary plusargs to the simulation"

	@echo ""
	@echo "Pass plusargs to the simulator using VVP_ARGS. Example:"
	@echo "  make tb-design VVP_ARGS=\"+TEST_VERSION +VERBOSE\""
	@echo ""
	@echo "Supported test plusargs (use with VVP_ARGS):"
	@echo "  +TEST_LED       - Run LED controller tests"
	@echo "  +TEST_MUX       - Run Mux controller tests"
	@echo "  +TEST_DSHOT     - Run DSHOT controller tests"
	@echo "  +TEST_PWM       - Run PWM decoder tests"
	@echo "  +TEST_VERSION   - Run Version readback test"
	@echo "  +TEST_NEOPIXEL  - Run NeoPixel controller test"

# Keep the invocation pattern used by the root Makefile: iverilog -g2009 ...
# Use /tmp temporary vvp filenames (same as root Makefile) to preserve behaviour.

tb-design:
	@echo "Running design testbench (src/tb/design_tb.sv)"
	@if ! command -v iverilog > /dev/null; then \
		echo "Error: iverilog not found. Install iverilog to run testbenches."; exit 1; \
	fi
	iverilog -g2009 -o /tmp/tb_design.vvp src/tb/design_tb.sv $(SRCS)
	vvp /tmp/tb_design.vvp $(VVP_ARGS)

tb-passthrough:
	@echo "Running passthrough testbench (src/tb/tang9k_top_tb.sv)"
	@if ! command -v iverilog > /dev/null; then \
		echo "Error: iverilog not found. Install iverilog to run testbenches."; exit 1; \
	fi
	iverilog -g2009 -o /tmp/tb_passthrough.vvp src/tb/tang9k_top_tb.sv $(SRCS)
	vvp /tmp/tb_passthrough.vvp $(VVP_ARGS)
