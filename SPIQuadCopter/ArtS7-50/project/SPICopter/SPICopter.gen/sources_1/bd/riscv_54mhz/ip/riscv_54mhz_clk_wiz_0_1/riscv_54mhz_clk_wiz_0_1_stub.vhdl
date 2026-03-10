-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
-- Date        : Mon Mar  9 22:46:44 2026
-- Host        : hp running 64-bit Ubuntu 24.04.3 LTS
-- Command     : write_vhdl -force -mode synth_stub
--               /media/tcmichals/projects/Tang9K/HacksterIO/SPIQuadCopter/ArtS7-50/project/SPICopter/SPICopter.gen/sources_1/bd/riscv_54mhz/ip/riscv_54mhz_clk_wiz_0_1/riscv_54mhz_clk_wiz_0_1_stub.vhdl
-- Design      : riscv_54mhz_clk_wiz_0_1
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7s50csga324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity riscv_54mhz_clk_wiz_0_1 is
  Port ( 
    clk_out1 : out STD_LOGIC;
    reset : in STD_LOGIC;
    locked : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of riscv_54mhz_clk_wiz_0_1 : entity is "riscv_54mhz_clk_wiz_0_1,clk_wiz_v6_0_17_0_0,{component_name=riscv_54mhz_clk_wiz_0_1,use_phase_alignment=true,use_min_o_jitter=false,use_max_i_jitter=false,use_dyn_phase_shift=false,use_inclk_switchover=false,use_dyn_reconfig=false,enable_axi=0,feedback_source=FDBK_AUTO,PRIMITIVE=MMCM,num_out_clk=1,clkin1_period=83.333,clkin2_period=10.0,use_power_down=false,use_reset=true,use_locked=true,use_inclk_stopped=false,feedback_type=SINGLE,CLOCK_MGR_TYPE=NA,manual_override=false}";
end riscv_54mhz_clk_wiz_0_1;

architecture stub of riscv_54mhz_clk_wiz_0_1 is
  attribute syn_black_box : boolean;
  attribute black_box_pad_pin : string;
  attribute syn_black_box of stub : architecture is true;
  attribute black_box_pad_pin of stub : architecture is "clk_out1,reset,locked,clk_in1";
begin
end;
