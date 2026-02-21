# tools/Makefile - simulation / testbench targets (optionally included from top-level Makefile)
# This file contains the `tb-design` and `tb-version` targets.

# Use SRCS from the including Makefile if present; fall back to empty list so standalone usage doesn't fail.
ifeq ($(origin SRCS), undefined)
SRCS :=
endif

ifeq ($(origin INC), undefined)
INC :=
endif

# Note: testbenches accept simulator plusargs via VVP_ARGS (see examples below)

.PHONY: tb-design tb-version tools-help

tools-help:
	@echo "Testbench targets (from tools/Makefile):"
	@echo "  make tb-design       - Compile & run src/tb/design_tb.sv via iverilog (uses SRCS if set)"
	@echo "  make tb-version      - Compile & run version/wb_version_tb.sv via iverilog"
	@echo ""
	@echo "Usage examples:"
	@echo "  make tb-design VVP_ARGS=\"+TEST_VERSION\"  # run only the Version test"
	@echo "  make tb-design VVP_ARGS=\"+TEST_VERSION +VERBOSE\"  # add TB verbose logging"

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
	@mkdir -p build
	@rm -f build/tb_design.vvp
	$(IVERILOG) -g2009 -o build/tb_design.vvp src/tb/design_tb.sv $(SRCS)
	$(VVP) build/tb_design.vvp $(VVP_ARGS)


tb-version:
	@echo "Running version testbench (version/wb_version_tb.sv)"
	@mkdir -p build
	@rm -f build/tb_version.vvp
	$(IVERILOG) -g2009 -o build/tb_version.vvp version/wb_version_tb.sv version/wb_version.sv
	$(VVP) build/tb_version.vvp $(VVP_ARGS)
