## Tang9K Timing Constraints (SDC)
# Primary and generated clock constraints for the Tang9K project.
#
# Notes:
# - External board oscillator: i_sys_clk = 27 MHz
# - PLL generates clk_72m = 54 MHz (implemented in RTL as pll_27m_to_72m / u_pll_72m)

# Primary input clock: 27 MHz external oscillator
# Note: Not constraining i_sys_clk since all design logic runs on clk_72m
# and nextpnr-himbaechel doesn't support set_clock_groups for false paths

# Generated 54 MHz clock from PLL (54 MHz -> period = 18.518518 ns)
# Define clock on synthesized net `clk_72m` (seen in _build/default/hardware.json)
create_clock -name clk_72m -period 18.518518 [get_nets clk_72m]

# FALSE PATH DOCUMENTATION:
# nextpnr reports a cross-clock timing warning (u_pll_72m.clkin -> clk_72m).
# This is a FALSE PATH and can be safely ignored because:
# 1. All design logic runs exclusively on clk_72m (66 MHz PLL output)
# 2. No user logic operates on the raw 27 MHz input clock
# 3. The PLL handles clock domain crossing internally
# 4. nextpnr-himbaechel doesn't support set_clock_groups to mark as async
#
# The --timing-allow-fail flag allows bitstream generation despite this warning.

# (Note: some place-and-route tools do not support `get_clocks`/set_clock_uncertainty.
# If your tool supports clock uncertainty, re-add an appropriate constraint here.)

# I/O timing constraints (set_input_delay/set_output_delay) are not supported
# by this nextpnr build. If your toolchain supports I/O timing, add appropriate
# `set_input_delay`/`set_output_delay` constraints here or provide them via
# a tool-specific mechanism.

# End of file
