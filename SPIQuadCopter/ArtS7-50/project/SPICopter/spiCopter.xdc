## ==============================================================================
## Simple Timing Constraints for SPI Copter
## ==============================================================================

## Clock Wizard IP automatically constrains the generated clocks
## No manual clock constraints needed here

## ==============================================================================
## Asynchronous Input Constraints - Mark as false paths
## ==============================================================================

## GPIO Mux Control - async from processor
set_false_path -from [get_ports {mux_for_esc[*]}]

## PWM Decoder Inputs - async from RC receiver
set_false_path -from [get_ports {pwm_ch*}]

## SPI Interface - async clock domain
set_false_path -from [get_ports {spi_clk}]
set_false_path -from [get_ports {spi_cs_n}]
set_false_path -from [get_ports {spi_mosi}]
set_false_path -to   [get_ports {spi_miso}]

## ESC UART - async from processor
set_false_path -from [get_ports {esc_uart_tx}]
set_false_path -from [get_ports {esc_uart_tx_en}]
set_false_path -to   [get_ports {esc_uart_rx}]

## ==============================================================================
## Output Constraints - No timing requirements
## ==============================================================================

## Motor outputs - DShot timing handled by internal logic
set_false_path -to [get_ports {motor*}]

## LED outputs - no timing requirement
set_false_path -to [get_ports {led*}]

## NeoPixel output - timing handled by internal logic
set_false_path -to [get_ports {neopixel}]

## Debug outputs - no timing requirement
set_false_path -to [get_ports {debug*}]

## ==============================================================================
## I/O Standards (if needed - uncomment and adjust pin locations)
## ==============================================================================
## set_property IOSTANDARD LVCMOS33 [get_ports {mux_for_esc[*]}]
## set_property IOSTANDARD LVCMOS33 [get_ports {pwm_ch*}]
## set_property IOSTANDARD LVCMOS33 [get_ports {motor*}]
## set_property IOSTANDARD LVCMOS33 [get_ports {led*}]
