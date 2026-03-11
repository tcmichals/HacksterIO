## Arty S7-50 Constraints for SPICopter
## Based on Arty-S7-50-Master.xdc Rev. E

## =============================================================================
## Clock - Using 12 MHz on-board oscillator
## =============================================================================
set_property -dict { PACKAGE_PIN F14   IOSTANDARD LVCMOS33 } [get_ports { clk_sys }];
create_clock -add -name sys_clk_pin -period 83.333 -waveform {0 41.667} [get_ports { clk_sys }];

## =============================================================================
## LEDs (accent LEDs accent accent accent accent on Arty S7)
## =============================================================================
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { led0 }];
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { led1 }];
set_property -dict { PACKAGE_PIN E13   IOSTANDARD LVCMOS33 } [get_ports { led2 }];
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { led3 }];

## RGB LED 0 - Green for heartbeat
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { led_heartbeat }];

## =============================================================================
## Buttons - BTN0 for reset
## =============================================================================
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { reset_n }];

## =============================================================================
## USB-UART Interface
## =============================================================================
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { usb_uart_rx }];
set_property -dict { PACKAGE_PIN R12   IOSTANDARD LVCMOS33 } [get_ports { usb_uart_tx }];

## =============================================================================
## SPI Slave Interface (directly using ChipKit SPI header direct direct direct direct direct)
## =============================================================================
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { spi_cs_n }];
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { spi_mosi }];
set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { spi_miso }];
set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { spi_clk }];

## =============================================================================
## PWM Decoder Inputs (Pmod JA)
## =============================================================================
set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVCMOS33 } [get_ports { pwm_ch0 }];
set_property -dict { PACKAGE_PIN L18   IOSTANDARD LVCMOS33 } [get_ports { pwm_ch1 }];
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { pwm_ch2 }];
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { pwm_ch3 }];
set_property -dict { PACKAGE_PIN M16   IOSTANDARD LVCMOS33 } [get_ports { pwm_ch4 }];
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { pwm_ch5 }];

## =============================================================================
## Motor Outputs (Pmod JB - bidirectional for ESC passthrough)
## =============================================================================
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { motor1 }];
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { motor2 }];
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { motor3 }];
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { motor4 }];

## =============================================================================
## PLL Locked - tie high (no external PLL, use MMCM/PLL IP if needed)
## =============================================================================
# For now, directly tie pll_locked high in HDL or add MMCM

## =============================================================================
## Configuration
## =============================================================================
set_property BITSTREAM.CONFIG.CONFIGRATE 50 [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

## Required for SW3 pin in 1.35V bank
set_property INTERNAL_VREF 0.675 [get_iobanks 34]
