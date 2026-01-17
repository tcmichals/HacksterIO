## Tang9K Timing Constraints (SDC)
# Primary and generated clock constraints for the Tang9K project.
#
# Notes:
# - External board oscillator: i_sys_clk = 27 MHz
# - PLL generates clk_72m = 72 MHz (implemented in RTL as pll_27m_to_72m / u_pll_72m)
# - The generated-clock line below is a helpful placeholder; if your PLL instance
#   uses a different name/path, adjust the source pin accordingly.

# Primary input clock: 27 MHz external oscillator
create_clock -name i_sys_clk -period 37.037037 [get_ports i_sys_clk]

# Generated 72 MHz clock from PLL (72 MHz -> period = 13.888889 ns)
# Define clock on synthesized net `clk_72m` (seen in _build/default/hardware.json)
create_clock -name clk_72m -period 13.888889 [get_nets clk_72m]
# If the PLL instance in your top-level is named `u_pll_72m` and the output pin
# is `clk72`, the following generated clock will be picked up by tools.
# Adjust the instance/pin name to match your RTL if needed.

# (Note: some place-and-route tools do not support `get_clocks`/set_clock_uncertainty.
# If your tool supports clock uncertainty, re-add an appropriate constraint here.)

# I/O timing constraints (set_input_delay/set_output_delay) are not supported
# by this nextpnr build. If your toolchain supports I/O timing, add appropriate
# `set_input_delay`/`set_output_delay` constraints here or provide them via
# a tool-specific mechanism.

# End of file
