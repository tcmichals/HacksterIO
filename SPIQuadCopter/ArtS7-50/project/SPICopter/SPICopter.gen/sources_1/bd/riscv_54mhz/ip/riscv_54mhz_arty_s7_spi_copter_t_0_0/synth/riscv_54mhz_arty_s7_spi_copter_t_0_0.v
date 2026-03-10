// (c) Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// (c) Copyright 2022-2026 Advanced Micro Devices, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of AMD and is protected under U.S. and international copyright
// and other intellectual property laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// AMD, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND AMD HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) AMD shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or AMD had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// AMD products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of AMD products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.


// IP VLNV: xilinx.com:module_ref:arty_s7_spi_copter_top:1.0
// IP Revision: 1

(* X_CORE_INFO = "arty_s7_spi_copter_top,Vivado 2025.2" *)
(* CHECK_LICENSE_TYPE = "riscv_54mhz_arty_s7_spi_copter_t_0_0,arty_s7_spi_copter_top,{}" *)
(* CORE_GENERATION_INFO = "riscv_54mhz_arty_s7_spi_copter_t_0_0,arty_s7_spi_copter_top,{x_ipProduct=Vivado 2025.2,x_ipVendor=xilinx.com,x_ipLibrary=module_ref,x_ipName=arty_s7_spi_copter_top,x_ipVersion=1.0,x_ipCoreRevision=1,x_ipLanguage=VERILOG,x_ipSimLanguage=MIXED,CLK_FREQ_HZ=54000000}" *)
(* IP_DEFINITION_SOURCE = "module_ref" *)
(* DowngradeIPIdentifiedWarnings = "yes" *)
module riscv_54mhz_arty_s7_spi_copter_t_0_0 (
  clk,
  reset_n,
  spi_clk,
  spi_cs_n,
  spi_mosi,
  spi_miso,
  esc_uart_tx,
  esc_uart_rx,
  esc_uart_tx_en,
  led0,
  led1,
  led2,
  led3,
  pwm_ch0,
  pwm_ch1,
  pwm_ch2,
  pwm_ch3,
  pwm_ch4,
  pwm_ch5,
  motor1,
  motor2,
  motor3,
  motor4,
  neopixel,
  debug0,
  debug1,
  debug2,
  mux_for_esc
);

(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 clk CLK" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME clk, FREQ_HZ 54000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *)
input wire clk;
(* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 reset_n RST" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME reset_n, POLARITY ACTIVE_HIGH, INSERT_VIP 0" *)
input wire reset_n;
(* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 spi_clk CLK" *)
(* X_INTERFACE_MODE = "slave" *)
(* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME spi_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN riscv_54mhz_spi_clk_0, INSERT_VIP 0" *)
input wire spi_clk;
input wire spi_cs_n;
input wire spi_mosi;
output wire spi_miso;
input wire esc_uart_tx;
output wire esc_uart_rx;
input wire esc_uart_tx_en;
output wire led0;
output wire led1;
output wire led2;
output wire led3;
input wire pwm_ch0;
input wire pwm_ch1;
input wire pwm_ch2;
input wire pwm_ch3;
input wire pwm_ch4;
input wire pwm_ch5;
inout wire motor1;
inout wire motor2;
inout wire motor3;
inout wire motor4;
output wire neopixel;
output wire debug0;
output wire debug1;
output wire debug2;
input wire [2 : 0] mux_for_esc;

  arty_s7_spi_copter_top #(
    .CLK_FREQ_HZ(54000000)
  ) inst (
    .clk(clk),
    .reset_n(reset_n),
    .spi_clk(spi_clk),
    .spi_cs_n(spi_cs_n),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .esc_uart_tx(esc_uart_tx),
    .esc_uart_rx(esc_uart_rx),
    .esc_uart_tx_en(esc_uart_tx_en),
    .led0(led0),
    .led1(led1),
    .led2(led2),
    .led3(led3),
    .pwm_ch0(pwm_ch0),
    .pwm_ch1(pwm_ch1),
    .pwm_ch2(pwm_ch2),
    .pwm_ch3(pwm_ch3),
    .pwm_ch4(pwm_ch4),
    .pwm_ch5(pwm_ch5),
    .motor1(motor1),
    .motor2(motor2),
    .motor3(motor3),
    .motor4(motor4),
    .neopixel(neopixel),
    .debug0(debug0),
    .debug1(debug1),
    .debug2(debug2),
    .mux_for_esc(mux_for_esc)
  );
endmodule
