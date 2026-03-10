//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
//Date        : Mon Mar  9 22:39:26 2026
//Host        : hp running 64-bit Ubuntu 24.04.3 LTS
//Command     : generate_target riscv_54mhz_wrapper.bd
//Design      : riscv_54mhz_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module riscv_54mhz_wrapper
   (ck_io10_ss,
    ck_io11_mosi,
    ck_io12_miso,
    ck_io13_sck,
    ja_0,
    ja_1,
    ja_2,
    ja_3,
    ja_4,
    ja_5,
    jb_0,
    jb_1,
    jb_2,
    jb_3,
    led_0,
    led_1,
    led_3,
    led_4,
    reset,
    sys_clock,
    usb_uart_rxd,
    usb_uart_txd);
  input ck_io10_ss;
  input ck_io11_mosi;
  output ck_io12_miso;
  input ck_io13_sck;
  input ja_0;
  input ja_1;
  input ja_2;
  input ja_3;
  input ja_4;
  input ja_5;
  inout jb_0;
  inout jb_1;
  inout jb_2;
  inout jb_3;
  output led_0;
  output led_1;
  output led_3;
  output led_4;
  input reset;
  input sys_clock;
  input usb_uart_rxd;
  output usb_uart_txd;

  wire ck_io10_ss;
  wire ck_io11_mosi;
  wire ck_io12_miso;
  wire ck_io13_sck;
  wire ja_0;
  wire ja_1;
  wire ja_2;
  wire ja_3;
  wire ja_4;
  wire ja_5;
  wire jb_0;
  wire jb_1;
  wire jb_2;
  wire jb_3;
  wire led_0;
  wire led_1;
  wire led_3;
  wire led_4;
  wire reset;
  wire sys_clock;
  wire usb_uart_rxd;
  wire usb_uart_txd;

  riscv_54mhz riscv_54mhz_i
       (.ck_io10_ss(ck_io10_ss),
        .ck_io11_mosi(ck_io11_mosi),
        .ck_io12_miso(ck_io12_miso),
        .ck_io13_sck(ck_io13_sck),
        .ja_0(ja_0),
        .ja_1(ja_1),
        .ja_2(ja_2),
        .ja_3(ja_3),
        .ja_4(ja_4),
        .ja_5(ja_5),
        .jb_0(jb_0),
        .jb_1(jb_1),
        .jb_2(jb_2),
        .jb_3(jb_3),
        .led_0(led_0),
        .led_1(led_1),
        .led_3(led_3),
        .led_4(led_4),
        .reset(reset),
        .sys_clock(sys_clock),
        .usb_uart_rxd(usb_uart_rxd),
        .usb_uart_txd(usb_uart_txd));
endmodule
