//Copyright (C)2014-2026 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//Tool Version: V1.9.11.03 Education 
//Created Time: 2026-03-01 12:56:29
create_clock -name i_clk -period 6.667 -waveform {0 3.333} [get_ports {i_clk}] -add
