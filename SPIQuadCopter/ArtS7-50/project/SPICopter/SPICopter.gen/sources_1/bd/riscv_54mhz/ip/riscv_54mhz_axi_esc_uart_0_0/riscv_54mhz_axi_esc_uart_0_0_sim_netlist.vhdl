-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
-- Date        : Mon Mar  9 22:47:50 2026
-- Host        : hp running 64-bit Ubuntu 24.04.3 LTS
-- Command     : write_vhdl -force -mode funcsim
--               /media/tcmichals/projects/Tang9K/HacksterIO/SPIQuadCopter/ArtS7-50/project/SPICopter/SPICopter.gen/sources_1/bd/riscv_54mhz/ip/riscv_54mhz_axi_esc_uart_0_0/riscv_54mhz_axi_esc_uart_0_0_sim_netlist.vhdl
-- Design      : riscv_54mhz_axi_esc_uart_0_0
-- Purpose     : This VHDL netlist is a functional simulation representation of the design and should not be modified or
--               synthesized. This netlist cannot be used for SDF annotated simulation.
-- Device      : xc7s50csga324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity riscv_54mhz_axi_esc_uart_0_0_axi_esc_uart is
  port (
    S_AXI_AWREADY : out STD_LOGIC;
    S_AXI_WREADY : out STD_LOGIC;
    axi_rvalid_reg_0 : out STD_LOGIC;
    S_AXI_ARREADY : out STD_LOGIC;
    tx_active_reg_reg_0 : out STD_LOGIC;
    irq_tx : out STD_LOGIC;
    irq_rx : out STD_LOGIC;
    S_AXI_RDATA : out STD_LOGIC_VECTOR ( 7 downto 0 );
    axi_bvalid_reg_0 : out STD_LOGIC;
    tx_out : out STD_LOGIC;
    S_AXI_AWADDR : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ARESETN : in STD_LOGIC;
    S_AXI_ARADDR : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ARVALID : in STD_LOGIC;
    S_AXI_ACLK : in STD_LOGIC;
    S_AXI_WDATA : in STD_LOGIC_VECTOR ( 7 downto 0 );
    rx_in : in STD_LOGIC;
    S_AXI_AWVALID : in STD_LOGIC;
    S_AXI_WVALID : in STD_LOGIC;
    S_AXI_BREADY : in STD_LOGIC;
    S_AXI_RREADY : in STD_LOGIC
  );
  attribute ORIG_REF_NAME : string;
  attribute ORIG_REF_NAME of riscv_54mhz_axi_esc_uart_0_0_axi_esc_uart : entity is "axi_esc_uart";
end riscv_54mhz_axi_esc_uart_0_0_axi_esc_uart;

architecture STRUCTURE of riscv_54mhz_axi_esc_uart_0_0_axi_esc_uart is
  signal \FSM_sequential_rx_state[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_rx_state[0]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_rx_state[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_rx_state[1]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_rx_state[1]_i_3_n_0\ : STD_LOGIC;
  signal \FSM_sequential_rx_state[1]_i_4_n_0\ : STD_LOGIC;
  signal \FSM_sequential_rx_state[1]_i_5_n_0\ : STD_LOGIC;
  signal \FSM_sequential_rx_state[1]_i_6_n_0\ : STD_LOGIC;
  signal \FSM_sequential_tx_state[0]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_tx_state[0]_i_2_n_0\ : STD_LOGIC;
  signal \FSM_sequential_tx_state[1]_i_1_n_0\ : STD_LOGIC;
  signal \FSM_sequential_tx_state[2]_i_1_n_0\ : STD_LOGIC;
  signal \^s_axi_arready\ : STD_LOGIC;
  signal \^s_axi_awready\ : STD_LOGIC;
  signal \^s_axi_wready\ : STD_LOGIC;
  signal axi_arready0 : STD_LOGIC;
  signal axi_awready0 : STD_LOGIC;
  signal axi_bvalid_i_1_n_0 : STD_LOGIC;
  signal \^axi_bvalid_reg_0\ : STD_LOGIC;
  signal axi_rdata : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \axi_rdata[0]_i_2_n_0\ : STD_LOGIC;
  signal \axi_rdata[1]_i_2_n_0\ : STD_LOGIC;
  signal axi_rvalid_i_1_n_0 : STD_LOGIC;
  signal \^axi_rvalid_reg_0\ : STD_LOGIC;
  signal axi_wready0 : STD_LOGIC;
  signal \^irq_rx\ : STD_LOGIC;
  signal \^irq_tx\ : STD_LOGIC;
  signal p_0_in : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal p_1_in : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal p_3_in : STD_LOGIC_VECTOR ( 3 to 3 );
  signal p_8_in : STD_LOGIC;
  signal rst : STD_LOGIC;
  signal \rx_bit_idx[0]_i_1_n_0\ : STD_LOGIC;
  signal \rx_bit_idx[1]_i_1_n_0\ : STD_LOGIC;
  signal \rx_bit_idx[1]_i_2_n_0\ : STD_LOGIC;
  signal \rx_bit_idx[1]_i_3_n_0\ : STD_LOGIC;
  signal \rx_bit_idx[2]_i_1_n_0\ : STD_LOGIC;
  signal \rx_bit_idx[2]_i_2_n_0\ : STD_LOGIC;
  signal \rx_bit_idx_reg_n_0_[0]\ : STD_LOGIC;
  signal \rx_bit_idx_reg_n_0_[1]\ : STD_LOGIC;
  signal \rx_bit_idx_reg_n_0_[2]\ : STD_LOGIC;
  signal rx_counter : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \rx_counter0_carry__0_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry__0_n_1\ : STD_LOGIC;
  signal \rx_counter0_carry__0_n_2\ : STD_LOGIC;
  signal \rx_counter0_carry__0_n_3\ : STD_LOGIC;
  signal \rx_counter0_carry__0_n_4\ : STD_LOGIC;
  signal \rx_counter0_carry__0_n_5\ : STD_LOGIC;
  signal \rx_counter0_carry__0_n_6\ : STD_LOGIC;
  signal \rx_counter0_carry__0_n_7\ : STD_LOGIC;
  signal \rx_counter0_carry__1_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry__1_n_1\ : STD_LOGIC;
  signal \rx_counter0_carry__1_n_2\ : STD_LOGIC;
  signal \rx_counter0_carry__1_n_3\ : STD_LOGIC;
  signal \rx_counter0_carry__1_n_4\ : STD_LOGIC;
  signal \rx_counter0_carry__1_n_5\ : STD_LOGIC;
  signal \rx_counter0_carry__1_n_6\ : STD_LOGIC;
  signal \rx_counter0_carry__1_n_7\ : STD_LOGIC;
  signal \rx_counter0_carry__2_n_2\ : STD_LOGIC;
  signal \rx_counter0_carry__2_n_3\ : STD_LOGIC;
  signal \rx_counter0_carry__2_n_5\ : STD_LOGIC;
  signal \rx_counter0_carry__2_n_6\ : STD_LOGIC;
  signal \rx_counter0_carry__2_n_7\ : STD_LOGIC;
  signal \rx_counter0_carry_i_1__0_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry_i_1__1_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry_i_1__2_n_0\ : STD_LOGIC;
  signal rx_counter0_carry_i_1_n_0 : STD_LOGIC;
  signal \rx_counter0_carry_i_2__0_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry_i_2__1_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry_i_2__2_n_0\ : STD_LOGIC;
  signal rx_counter0_carry_i_2_n_0 : STD_LOGIC;
  signal \rx_counter0_carry_i_3__0_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry_i_3__1_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry_i_3__2_n_0\ : STD_LOGIC;
  signal rx_counter0_carry_i_3_n_0 : STD_LOGIC;
  signal \rx_counter0_carry_i_4__0_n_0\ : STD_LOGIC;
  signal \rx_counter0_carry_i_4__1_n_0\ : STD_LOGIC;
  signal rx_counter0_carry_i_4_n_0 : STD_LOGIC;
  signal rx_counter0_carry_n_0 : STD_LOGIC;
  signal rx_counter0_carry_n_1 : STD_LOGIC;
  signal rx_counter0_carry_n_2 : STD_LOGIC;
  signal rx_counter0_carry_n_3 : STD_LOGIC;
  signal rx_counter0_carry_n_4 : STD_LOGIC;
  signal rx_counter0_carry_n_5 : STD_LOGIC;
  signal rx_counter0_carry_n_6 : STD_LOGIC;
  signal rx_counter0_carry_n_7 : STD_LOGIC;
  signal \rx_counter[11]_i_1_n_0\ : STD_LOGIC;
  signal \rx_counter[11]_i_2_n_0\ : STD_LOGIC;
  signal \rx_counter[15]_i_1_n_0\ : STD_LOGIC;
  signal \rx_counter[15]_i_4_n_0\ : STD_LOGIC;
  signal \rx_counter[1]_i_1_n_0\ : STD_LOGIC;
  signal \rx_counter[7]_i_1_n_0\ : STD_LOGIC;
  signal \rx_counter[9]_i_1_n_0\ : STD_LOGIC;
  signal rx_counter_1 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \rx_counter_reg_n_0_[0]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[10]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[11]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[12]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[13]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[14]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[15]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[1]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[2]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[3]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[4]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[5]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[6]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[7]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[8]\ : STD_LOGIC;
  signal \rx_counter_reg_n_0_[9]\ : STD_LOGIC;
  signal rx_data_reg : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal \rx_data_reg[7]_i_1_n_0\ : STD_LOGIC;
  signal rx_data_valid : STD_LOGIC;
  signal rx_data_valid_i_1_n_0 : STD_LOGIC;
  signal rx_data_valid_i_2_n_0 : STD_LOGIC;
  signal rx_done_reg_n_0 : STD_LOGIC;
  signal rx_in_sync1 : STD_LOGIC;
  signal rx_int_en_i_1_n_0 : STD_LOGIC;
  signal rx_int_flag1_out : STD_LOGIC;
  signal rx_int_flag_i_1_n_0 : STD_LOGIC;
  signal rx_int_flag_i_3_n_0 : STD_LOGIC;
  signal \rx_shift[7]_i_1_n_0\ : STD_LOGIC;
  signal \rx_shift_reg_n_0_[0]\ : STD_LOGIC;
  signal rx_state : STD_LOGIC_VECTOR ( 1 downto 0 );
  signal tx_active_reg_i_1_n_0 : STD_LOGIC;
  signal \^tx_active_reg_reg_0\ : STD_LOGIC;
  signal \tx_bit_idx[0]_i_1_n_0\ : STD_LOGIC;
  signal \tx_bit_idx[1]_i_1_n_0\ : STD_LOGIC;
  signal \tx_bit_idx[1]_i_2_n_0\ : STD_LOGIC;
  signal \tx_bit_idx[2]_i_1_n_0\ : STD_LOGIC;
  signal \tx_bit_idx[2]_i_2_n_0\ : STD_LOGIC;
  signal \tx_bit_idx_reg_n_0_[0]\ : STD_LOGIC;
  signal \tx_bit_idx_reg_n_0_[1]\ : STD_LOGIC;
  signal \tx_bit_idx_reg_n_0_[2]\ : STD_LOGIC;
  signal tx_counter : STD_LOGIC_VECTOR ( 15 downto 0 );
  signal \tx_counter0_carry__0_i_1_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__0_i_2_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__0_i_3_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__0_i_4_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__0_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__0_n_1\ : STD_LOGIC;
  signal \tx_counter0_carry__0_n_2\ : STD_LOGIC;
  signal \tx_counter0_carry__0_n_3\ : STD_LOGIC;
  signal \tx_counter0_carry__0_n_4\ : STD_LOGIC;
  signal \tx_counter0_carry__0_n_5\ : STD_LOGIC;
  signal \tx_counter0_carry__0_n_6\ : STD_LOGIC;
  signal \tx_counter0_carry__0_n_7\ : STD_LOGIC;
  signal \tx_counter0_carry__1_i_1_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__1_i_2_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__1_i_3_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__1_i_4_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__1_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__1_n_1\ : STD_LOGIC;
  signal \tx_counter0_carry__1_n_2\ : STD_LOGIC;
  signal \tx_counter0_carry__1_n_3\ : STD_LOGIC;
  signal \tx_counter0_carry__1_n_4\ : STD_LOGIC;
  signal \tx_counter0_carry__1_n_5\ : STD_LOGIC;
  signal \tx_counter0_carry__1_n_6\ : STD_LOGIC;
  signal \tx_counter0_carry__1_n_7\ : STD_LOGIC;
  signal \tx_counter0_carry__2_i_1_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__2_i_2_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__2_i_3_n_0\ : STD_LOGIC;
  signal \tx_counter0_carry__2_n_2\ : STD_LOGIC;
  signal \tx_counter0_carry__2_n_3\ : STD_LOGIC;
  signal \tx_counter0_carry__2_n_5\ : STD_LOGIC;
  signal \tx_counter0_carry__2_n_6\ : STD_LOGIC;
  signal \tx_counter0_carry__2_n_7\ : STD_LOGIC;
  signal tx_counter0_carry_i_1_n_0 : STD_LOGIC;
  signal tx_counter0_carry_i_2_n_0 : STD_LOGIC;
  signal tx_counter0_carry_i_3_n_0 : STD_LOGIC;
  signal tx_counter0_carry_i_4_n_0 : STD_LOGIC;
  signal tx_counter0_carry_n_0 : STD_LOGIC;
  signal tx_counter0_carry_n_1 : STD_LOGIC;
  signal tx_counter0_carry_n_2 : STD_LOGIC;
  signal tx_counter0_carry_n_3 : STD_LOGIC;
  signal tx_counter0_carry_n_4 : STD_LOGIC;
  signal tx_counter0_carry_n_5 : STD_LOGIC;
  signal tx_counter0_carry_n_6 : STD_LOGIC;
  signal tx_counter0_carry_n_7 : STD_LOGIC;
  signal \tx_counter[11]_i_2_n_0\ : STD_LOGIC;
  signal \tx_counter[11]_i_3_n_0\ : STD_LOGIC;
  signal tx_counter_3 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \tx_counter_reg_n_0_[0]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[10]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[11]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[12]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[13]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[14]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[15]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[1]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[2]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[3]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[4]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[5]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[6]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[7]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[8]\ : STD_LOGIC;
  signal \tx_counter_reg_n_0_[9]\ : STD_LOGIC;
  signal tx_data_reg : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal tx_data_reg_0 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal tx_data_valid_i_1_n_0 : STD_LOGIC;
  signal tx_data_valid_reg_n_0 : STD_LOGIC;
  signal tx_done_i_1_n_0 : STD_LOGIC;
  signal tx_int_en_i_1_n_0 : STD_LOGIC;
  signal tx_int_flag_i_1_n_0 : STD_LOGIC;
  signal tx_int_flag_i_2_n_0 : STD_LOGIC;
  signal tx_int_flag_i_3_n_0 : STD_LOGIC;
  signal \^tx_out\ : STD_LOGIC;
  signal tx_out_reg_i_1_n_0 : STD_LOGIC;
  signal tx_out_reg_i_2_n_0 : STD_LOGIC;
  signal tx_out_reg_i_3_n_0 : STD_LOGIC;
  signal tx_out_reg_i_4_n_0 : STD_LOGIC;
  signal tx_out_reg_i_5_n_0 : STD_LOGIC;
  signal tx_out_reg_i_6_n_0 : STD_LOGIC;
  signal tx_out_reg_i_7_n_0 : STD_LOGIC;
  signal tx_ready_reg : STD_LOGIC;
  signal tx_ready_reg_i_1_n_0 : STD_LOGIC;
  signal tx_shift : STD_LOGIC_VECTOR ( 7 downto 0 );
  signal tx_shift_2 : STD_LOGIC_VECTOR ( 0 to 0 );
  signal \tx_shift_reg_n_0_[0]\ : STD_LOGIC;
  signal \tx_shift_reg_n_0_[1]\ : STD_LOGIC;
  signal \tx_shift_reg_n_0_[2]\ : STD_LOGIC;
  signal \tx_shift_reg_n_0_[3]\ : STD_LOGIC;
  signal \tx_shift_reg_n_0_[4]\ : STD_LOGIC;
  signal \tx_shift_reg_n_0_[5]\ : STD_LOGIC;
  signal \tx_shift_reg_n_0_[6]\ : STD_LOGIC;
  signal \tx_shift_reg_n_0_[7]\ : STD_LOGIC;
  signal tx_state : STD_LOGIC_VECTOR ( 2 downto 0 );
  signal \NLW_rx_counter0_carry__2_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_rx_counter0_carry__2_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  signal \NLW_tx_counter0_carry__2_CO_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 downto 2 );
  signal \NLW_tx_counter0_carry__2_O_UNCONNECTED\ : STD_LOGIC_VECTOR ( 3 to 3 );
  attribute SOFT_HLUTNM : string;
  attribute SOFT_HLUTNM of \FSM_sequential_rx_state[0]_i_2\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \FSM_sequential_rx_state[1]_i_4\ : label is "soft_lutpair9";
  attribute FSM_ENCODED_STATES : string;
  attribute FSM_ENCODED_STATES of \FSM_sequential_rx_state_reg[0]\ : label is "RX_IDLE:00,RX_START:01,RX_DATA:10,RX_STOP:11,";
  attribute FSM_ENCODED_STATES of \FSM_sequential_rx_state_reg[1]\ : label is "RX_IDLE:00,RX_START:01,RX_DATA:10,RX_STOP:11,";
  attribute SOFT_HLUTNM of \FSM_sequential_tx_state[0]_i_2\ : label is "soft_lutpair12";
  attribute SOFT_HLUTNM of \FSM_sequential_tx_state[1]_i_1\ : label is "soft_lutpair5";
  attribute SOFT_HLUTNM of \FSM_sequential_tx_state[2]_i_1\ : label is "soft_lutpair5";
  attribute FSM_ENCODED_STATES of \FSM_sequential_tx_state_reg[0]\ : label is "TX_IDLE:000,TX_START:001,TX_DATA:010,TX_STOP:011,TX_GUARD:100,";
  attribute FSM_ENCODED_STATES of \FSM_sequential_tx_state_reg[1]\ : label is "TX_IDLE:000,TX_START:001,TX_DATA:010,TX_STOP:011,TX_GUARD:100,";
  attribute FSM_ENCODED_STATES of \FSM_sequential_tx_state_reg[2]\ : label is "TX_IDLE:000,TX_START:001,TX_DATA:010,TX_STOP:011,TX_GUARD:100,";
  attribute SOFT_HLUTNM of axi_arready_i_1 : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of axi_awready_i_2 : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of axi_bvalid_i_1 : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \axi_rdata[4]_i_1\ : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of axi_rvalid_i_1 : label is "soft_lutpair11";
  attribute SOFT_HLUTNM of axi_wready_i_1 : label is "soft_lutpair7";
  attribute SOFT_HLUTNM of \rx_bit_idx[1]_i_1\ : label is "soft_lutpair6";
  attribute SOFT_HLUTNM of \rx_bit_idx[1]_i_3\ : label is "soft_lutpair0";
  attribute SOFT_HLUTNM of \rx_bit_idx[2]_i_2\ : label is "soft_lutpair6";
  attribute ADDER_THRESHOLD : integer;
  attribute ADDER_THRESHOLD of rx_counter0_carry : label is 35;
  attribute ADDER_THRESHOLD of \rx_counter0_carry__0\ : label is 35;
  attribute ADDER_THRESHOLD of \rx_counter0_carry__1\ : label is 35;
  attribute ADDER_THRESHOLD of \rx_counter0_carry__2\ : label is 35;
  attribute SOFT_HLUTNM of \rx_counter[0]_i_1\ : label is "soft_lutpair9";
  attribute SOFT_HLUTNM of \rx_counter[11]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of \rx_counter[12]_i_1\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \rx_counter[13]_i_1\ : label is "soft_lutpair19";
  attribute SOFT_HLUTNM of \rx_counter[14]_i_1\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \rx_counter[15]_i_3\ : label is "soft_lutpair20";
  attribute SOFT_HLUTNM of \rx_counter[1]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \rx_counter[2]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \rx_counter[3]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \rx_counter[4]_i_1\ : label is "soft_lutpair17";
  attribute SOFT_HLUTNM of \rx_counter[5]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \rx_counter[6]_i_1\ : label is "soft_lutpair18";
  attribute SOFT_HLUTNM of \rx_counter[7]_i_1\ : label is "soft_lutpair3";
  attribute SOFT_HLUTNM of \rx_counter[8]_i_1\ : label is "soft_lutpair8";
  attribute SOFT_HLUTNM of \rx_counter[9]_i_1\ : label is "soft_lutpair4";
  attribute SOFT_HLUTNM of rx_data_valid_i_2 : label is "soft_lutpair1";
  attribute SOFT_HLUTNM of \tx_bit_idx[2]_i_2\ : label is "soft_lutpair12";
  attribute ADDER_THRESHOLD of tx_counter0_carry : label is 35;
  attribute ADDER_THRESHOLD of \tx_counter0_carry__0\ : label is 35;
  attribute ADDER_THRESHOLD of \tx_counter0_carry__1\ : label is 35;
  attribute ADDER_THRESHOLD of \tx_counter0_carry__2\ : label is 35;
  attribute SOFT_HLUTNM of \tx_counter[11]_i_3\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of \tx_counter[2]_i_1\ : label is "soft_lutpair2";
  attribute SOFT_HLUTNM of tx_int_flag_i_2 : label is "soft_lutpair10";
  attribute SOFT_HLUTNM of \tx_shift[0]_i_1\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \tx_shift[1]_i_1\ : label is "soft_lutpair16";
  attribute SOFT_HLUTNM of \tx_shift[2]_i_1\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \tx_shift[3]_i_1\ : label is "soft_lutpair15";
  attribute SOFT_HLUTNM of \tx_shift[4]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \tx_shift[5]_i_1\ : label is "soft_lutpair14";
  attribute SOFT_HLUTNM of \tx_shift[6]_i_1\ : label is "soft_lutpair13";
  attribute SOFT_HLUTNM of \tx_shift[7]_i_2\ : label is "soft_lutpair13";
begin
  S_AXI_ARREADY <= \^s_axi_arready\;
  S_AXI_AWREADY <= \^s_axi_awready\;
  S_AXI_WREADY <= \^s_axi_wready\;
  axi_bvalid_reg_0 <= \^axi_bvalid_reg_0\;
  axi_rvalid_reg_0 <= \^axi_rvalid_reg_0\;
  irq_rx <= \^irq_rx\;
  irq_tx <= \^irq_tx\;
  tx_active_reg_reg_0 <= \^tx_active_reg_reg_0\;
  tx_out <= \^tx_out\;
\FSM_sequential_rx_state[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000062226277"
    )
        port map (
      I0 => rx_state(0),
      I1 => \FSM_sequential_rx_state[1]_i_2_n_0\,
      I2 => \FSM_sequential_rx_state[0]_i_2_n_0\,
      I3 => rx_state(1),
      I4 => p_0_in(7),
      I5 => \rx_counter[15]_i_1_n_0\,
      O => \FSM_sequential_rx_state[0]_i_1_n_0\
    );
\FSM_sequential_rx_state[0]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"80"
    )
        port map (
      I0 => \rx_bit_idx_reg_n_0_[0]\,
      I1 => \rx_bit_idx_reg_n_0_[1]\,
      I2 => \rx_bit_idx_reg_n_0_[2]\,
      O => \FSM_sequential_rx_state[0]_i_2_n_0\
    );
\FSM_sequential_rx_state[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"006A"
    )
        port map (
      I0 => rx_state(1),
      I1 => rx_state(0),
      I2 => \FSM_sequential_rx_state[1]_i_2_n_0\,
      I3 => \rx_counter[15]_i_1_n_0\,
      O => \FSM_sequential_rx_state[1]_i_1_n_0\
    );
\FSM_sequential_rx_state[1]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0004"
    )
        port map (
      I0 => \FSM_sequential_rx_state[1]_i_3_n_0\,
      I1 => \FSM_sequential_rx_state[1]_i_4_n_0\,
      I2 => \FSM_sequential_rx_state[1]_i_5_n_0\,
      I3 => \FSM_sequential_rx_state[1]_i_6_n_0\,
      O => \FSM_sequential_rx_state[1]_i_2_n_0\
    );
\FSM_sequential_rx_state[1]_i_3\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[7]\,
      I1 => \rx_counter_reg_n_0_[6]\,
      I2 => \rx_counter_reg_n_0_[4]\,
      I3 => \rx_counter_reg_n_0_[5]\,
      O => \FSM_sequential_rx_state[1]_i_3_n_0\
    );
\FSM_sequential_rx_state[1]_i_4\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0001"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[1]\,
      I1 => \rx_counter_reg_n_0_[0]\,
      I2 => \rx_counter_reg_n_0_[2]\,
      I3 => \rx_counter_reg_n_0_[3]\,
      O => \FSM_sequential_rx_state[1]_i_4_n_0\
    );
\FSM_sequential_rx_state[1]_i_5\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[13]\,
      I1 => \rx_counter_reg_n_0_[12]\,
      I2 => \rx_counter_reg_n_0_[15]\,
      I3 => \rx_counter_reg_n_0_[14]\,
      O => \FSM_sequential_rx_state[1]_i_5_n_0\
    );
\FSM_sequential_rx_state[1]_i_6\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[10]\,
      I1 => \rx_counter_reg_n_0_[11]\,
      I2 => \rx_counter_reg_n_0_[8]\,
      I3 => \rx_counter_reg_n_0_[9]\,
      O => \FSM_sequential_rx_state[1]_i_6_n_0\
    );
\FSM_sequential_rx_state_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \FSM_sequential_rx_state[0]_i_1_n_0\,
      Q => rx_state(0),
      R => '0'
    );
\FSM_sequential_rx_state_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \FSM_sequential_rx_state[1]_i_1_n_0\,
      Q => rx_state(1),
      R => '0'
    );
\FSM_sequential_tx_state[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FF00003AFF00FF0A"
    )
        port map (
      I0 => tx_data_valid_reg_n_0,
      I1 => \FSM_sequential_tx_state[0]_i_2_n_0\,
      I2 => tx_state(1),
      I3 => tx_state(0),
      I4 => tx_state(2),
      I5 => tx_out_reg_i_3_n_0,
      O => \FSM_sequential_tx_state[0]_i_1_n_0\
    );
\FSM_sequential_tx_state[0]_i_2\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"7F"
    )
        port map (
      I0 => \tx_bit_idx_reg_n_0_[2]\,
      I1 => \tx_bit_idx_reg_n_0_[1]\,
      I2 => \tx_bit_idx_reg_n_0_[0]\,
      O => \FSM_sequential_tx_state[0]_i_2_n_0\
    );
\FSM_sequential_tx_state[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"A6AA"
    )
        port map (
      I0 => tx_state(1),
      I1 => tx_state(0),
      I2 => tx_state(2),
      I3 => tx_out_reg_i_3_n_0,
      O => \FSM_sequential_tx_state[1]_i_1_n_0\
    );
\FSM_sequential_tx_state[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"E8F0"
    )
        port map (
      I0 => tx_state(1),
      I1 => tx_state(0),
      I2 => tx_state(2),
      I3 => tx_out_reg_i_3_n_0,
      O => \FSM_sequential_tx_state[2]_i_1_n_0\
    );
\FSM_sequential_tx_state_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \FSM_sequential_tx_state[0]_i_1_n_0\,
      Q => tx_state(0),
      R => rst
    );
\FSM_sequential_tx_state_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \FSM_sequential_tx_state[1]_i_1_n_0\,
      Q => tx_state(1),
      R => rst
    );
\FSM_sequential_tx_state_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \FSM_sequential_tx_state[2]_i_1_n_0\,
      Q => tx_state(2),
      R => rst
    );
axi_arready_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"04"
    )
        port map (
      I0 => \^axi_rvalid_reg_0\,
      I1 => S_AXI_ARVALID,
      I2 => \^s_axi_arready\,
      O => axi_arready0
    );
axi_arready_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => axi_arready0,
      Q => \^s_axi_arready\,
      R => rst
    );
axi_awready_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => S_AXI_ARESETN,
      O => rst
    );
axi_awready_i_2: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0040"
    )
        port map (
      I0 => \^s_axi_awready\,
      I1 => S_AXI_AWVALID,
      I2 => S_AXI_WVALID,
      I3 => \^axi_bvalid_reg_0\,
      O => axi_awready0
    );
axi_awready_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => axi_awready0,
      Q => \^s_axi_awready\,
      R => rst
    );
axi_bvalid_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"8F88"
    )
        port map (
      I0 => \^s_axi_awready\,
      I1 => \^s_axi_wready\,
      I2 => S_AXI_BREADY,
      I3 => \^axi_bvalid_reg_0\,
      O => axi_bvalid_i_1_n_0
    );
axi_bvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => axi_bvalid_i_1_n_0,
      Q => \^axi_bvalid_reg_0\,
      R => rst
    );
\axi_rdata[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"33003B08"
    )
        port map (
      I0 => \^irq_tx\,
      I1 => S_AXI_ARADDR(2),
      I2 => S_AXI_ARADDR(1),
      I3 => \axi_rdata[0]_i_2_n_0\,
      I4 => S_AXI_ARADDR(0),
      O => axi_rdata(0)
    );
\axi_rdata[0]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => p_1_in(0),
      I1 => rx_data_reg(0),
      I2 => S_AXI_ARADDR(1),
      I3 => tx_ready_reg,
      I4 => S_AXI_ARADDR(0),
      I5 => tx_data_reg(0),
      O => \axi_rdata[0]_i_2_n_0\
    );
\axi_rdata[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"33003B08"
    )
        port map (
      I0 => \^irq_rx\,
      I1 => S_AXI_ARADDR(2),
      I2 => S_AXI_ARADDR(1),
      I3 => \axi_rdata[1]_i_2_n_0\,
      I4 => S_AXI_ARADDR(0),
      O => axi_rdata(1)
    );
\axi_rdata[1]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"AFA0CFCFAFA0C0C0"
    )
        port map (
      I0 => p_1_in(1),
      I1 => rx_data_reg(1),
      I2 => S_AXI_ARADDR(1),
      I3 => rx_data_valid,
      I4 => S_AXI_ARADDR(0),
      I5 => tx_data_reg(1),
      O => \axi_rdata[1]_i_2_n_0\
    );
\axi_rdata[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000033B800B8"
    )
        port map (
      I0 => rx_data_reg(2),
      I1 => S_AXI_ARADDR(1),
      I2 => tx_data_reg(2),
      I3 => S_AXI_ARADDR(0),
      I4 => \^tx_active_reg_reg_0\,
      I5 => S_AXI_ARADDR(2),
      O => axi_rdata(2)
    );
\axi_rdata[3]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000033B800B8"
    )
        port map (
      I0 => rx_data_reg(3),
      I1 => S_AXI_ARADDR(1),
      I2 => tx_data_reg(3),
      I3 => S_AXI_ARADDR(0),
      I4 => p_3_in(3),
      I5 => S_AXI_ARADDR(2),
      O => axi_rdata(3)
    );
\axi_rdata[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000000E2"
    )
        port map (
      I0 => tx_data_reg(4),
      I1 => S_AXI_ARADDR(1),
      I2 => rx_data_reg(4),
      I3 => S_AXI_ARADDR(2),
      I4 => S_AXI_ARADDR(0),
      O => axi_rdata(4)
    );
\axi_rdata[5]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000000E2"
    )
        port map (
      I0 => tx_data_reg(5),
      I1 => S_AXI_ARADDR(1),
      I2 => rx_data_reg(5),
      I3 => S_AXI_ARADDR(2),
      I4 => S_AXI_ARADDR(0),
      O => axi_rdata(5)
    );
\axi_rdata[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000000B8"
    )
        port map (
      I0 => rx_data_reg(6),
      I1 => S_AXI_ARADDR(1),
      I2 => tx_data_reg(6),
      I3 => S_AXI_ARADDR(2),
      I4 => S_AXI_ARADDR(0),
      O => axi_rdata(6)
    );
\axi_rdata[7]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => S_AXI_ARVALID,
      I1 => \^axi_rvalid_reg_0\,
      O => p_8_in
    );
\axi_rdata[7]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000000E2"
    )
        port map (
      I0 => tx_data_reg(7),
      I1 => S_AXI_ARADDR(1),
      I2 => rx_data_reg(7),
      I3 => S_AXI_ARADDR(2),
      I4 => S_AXI_ARADDR(0),
      O => axi_rdata(7)
    );
\axi_rdata_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => p_8_in,
      D => axi_rdata(0),
      Q => S_AXI_RDATA(0),
      R => '0'
    );
\axi_rdata_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => p_8_in,
      D => axi_rdata(1),
      Q => S_AXI_RDATA(1),
      R => '0'
    );
\axi_rdata_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => p_8_in,
      D => axi_rdata(2),
      Q => S_AXI_RDATA(2),
      R => '0'
    );
\axi_rdata_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => p_8_in,
      D => axi_rdata(3),
      Q => S_AXI_RDATA(3),
      R => '0'
    );
\axi_rdata_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => p_8_in,
      D => axi_rdata(4),
      Q => S_AXI_RDATA(4),
      R => '0'
    );
\axi_rdata_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => p_8_in,
      D => axi_rdata(5),
      Q => S_AXI_RDATA(5),
      R => '0'
    );
\axi_rdata_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => p_8_in,
      D => axi_rdata(6),
      Q => S_AXI_RDATA(6),
      R => '0'
    );
\axi_rdata_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => p_8_in,
      D => axi_rdata(7),
      Q => S_AXI_RDATA(7),
      R => '0'
    );
axi_rvalid_i_1: unisim.vcomponents.LUT3
    generic map(
      INIT => X"BA"
    )
        port map (
      I0 => \^s_axi_arready\,
      I1 => S_AXI_RREADY,
      I2 => \^axi_rvalid_reg_0\,
      O => axi_rvalid_i_1_n_0
    );
axi_rvalid_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => axi_rvalid_i_1_n_0,
      Q => \^axi_rvalid_reg_0\,
      R => rst
    );
axi_wready_i_1: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0040"
    )
        port map (
      I0 => \^s_axi_wready\,
      I1 => S_AXI_AWVALID,
      I2 => S_AXI_WVALID,
      I3 => \^axi_bvalid_reg_0\,
      O => axi_wready0
    );
axi_wready_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => axi_wready0,
      Q => \^s_axi_wready\,
      R => rst
    );
\rx_bit_idx[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FBFBFFBF00000040"
    )
        port map (
      I0 => \^tx_active_reg_reg_0\,
      I1 => \FSM_sequential_rx_state[1]_i_2_n_0\,
      I2 => rx_state(1),
      I3 => \FSM_sequential_rx_state[0]_i_2_n_0\,
      I4 => rx_state(0),
      I5 => \rx_bit_idx_reg_n_0_[0]\,
      O => \rx_bit_idx[0]_i_1_n_0\
    );
\rx_bit_idx[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"4F80"
    )
        port map (
      I0 => \rx_bit_idx_reg_n_0_[0]\,
      I1 => rx_state(1),
      I2 => \rx_bit_idx[1]_i_2_n_0\,
      I3 => \rx_bit_idx_reg_n_0_[1]\,
      O => \rx_bit_idx[1]_i_1_n_0\
    );
\rx_bit_idx[1]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000000000000010"
    )
        port map (
      I0 => \^tx_active_reg_reg_0\,
      I1 => \FSM_sequential_rx_state[1]_i_3_n_0\,
      I2 => \FSM_sequential_rx_state[1]_i_4_n_0\,
      I3 => \FSM_sequential_rx_state[1]_i_5_n_0\,
      I4 => \FSM_sequential_rx_state[1]_i_6_n_0\,
      I5 => \rx_bit_idx[1]_i_3_n_0\,
      O => \rx_bit_idx[1]_i_2_n_0\
    );
\rx_bit_idx[1]_i_3\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"EAAA5555"
    )
        port map (
      I0 => rx_state(0),
      I1 => \rx_bit_idx_reg_n_0_[2]\,
      I2 => \rx_bit_idx_reg_n_0_[1]\,
      I3 => \rx_bit_idx_reg_n_0_[0]\,
      I4 => rx_state(1),
      O => \rx_bit_idx[1]_i_3_n_0\
    );
\rx_bit_idx[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FBFB0000FFFF4000"
    )
        port map (
      I0 => \^tx_active_reg_reg_0\,
      I1 => \FSM_sequential_rx_state[1]_i_2_n_0\,
      I2 => rx_state(1),
      I3 => \rx_bit_idx[2]_i_2_n_0\,
      I4 => \rx_bit_idx_reg_n_0_[2]\,
      I5 => rx_state(0),
      O => \rx_bit_idx[2]_i_1_n_0\
    );
\rx_bit_idx[2]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \rx_bit_idx_reg_n_0_[1]\,
      I1 => \rx_bit_idx_reg_n_0_[0]\,
      O => \rx_bit_idx[2]_i_2_n_0\
    );
\rx_bit_idx_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \rx_bit_idx[0]_i_1_n_0\,
      Q => \rx_bit_idx_reg_n_0_[0]\,
      R => rst
    );
\rx_bit_idx_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \rx_bit_idx[1]_i_1_n_0\,
      Q => \rx_bit_idx_reg_n_0_[1]\,
      R => rst
    );
\rx_bit_idx_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \rx_bit_idx[2]_i_1_n_0\,
      Q => \rx_bit_idx_reg_n_0_[2]\,
      R => rst
    );
rx_counter0_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => rx_counter0_carry_n_0,
      CO(2) => rx_counter0_carry_n_1,
      CO(1) => rx_counter0_carry_n_2,
      CO(0) => rx_counter0_carry_n_3,
      CYINIT => \rx_counter_reg_n_0_[0]\,
      DI(3) => \rx_counter_reg_n_0_[4]\,
      DI(2) => \rx_counter_reg_n_0_[3]\,
      DI(1) => \rx_counter_reg_n_0_[2]\,
      DI(0) => \rx_counter_reg_n_0_[1]\,
      O(3) => rx_counter0_carry_n_4,
      O(2) => rx_counter0_carry_n_5,
      O(1) => rx_counter0_carry_n_6,
      O(0) => rx_counter0_carry_n_7,
      S(3) => \rx_counter0_carry_i_1__1_n_0\,
      S(2) => \rx_counter0_carry_i_2__1_n_0\,
      S(1) => \rx_counter0_carry_i_3__0_n_0\,
      S(0) => \rx_counter0_carry_i_4__1_n_0\
    );
\rx_counter0_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => rx_counter0_carry_n_0,
      CO(3) => \rx_counter0_carry__0_n_0\,
      CO(2) => \rx_counter0_carry__0_n_1\,
      CO(1) => \rx_counter0_carry__0_n_2\,
      CO(0) => \rx_counter0_carry__0_n_3\,
      CYINIT => '0',
      DI(3) => \rx_counter_reg_n_0_[8]\,
      DI(2) => \rx_counter_reg_n_0_[7]\,
      DI(1) => \rx_counter_reg_n_0_[6]\,
      DI(0) => \rx_counter_reg_n_0_[5]\,
      O(3) => \rx_counter0_carry__0_n_4\,
      O(2) => \rx_counter0_carry__0_n_5\,
      O(1) => \rx_counter0_carry__0_n_6\,
      O(0) => \rx_counter0_carry__0_n_7\,
      S(3) => \rx_counter0_carry_i_1__0_n_0\,
      S(2) => \rx_counter0_carry_i_2__2_n_0\,
      S(1) => rx_counter0_carry_i_3_n_0,
      S(0) => \rx_counter0_carry_i_4__0_n_0\
    );
\rx_counter0_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \rx_counter0_carry__0_n_0\,
      CO(3) => \rx_counter0_carry__1_n_0\,
      CO(2) => \rx_counter0_carry__1_n_1\,
      CO(1) => \rx_counter0_carry__1_n_2\,
      CO(0) => \rx_counter0_carry__1_n_3\,
      CYINIT => '0',
      DI(3) => \rx_counter_reg_n_0_[12]\,
      DI(2) => \rx_counter_reg_n_0_[11]\,
      DI(1) => \rx_counter_reg_n_0_[10]\,
      DI(0) => \rx_counter_reg_n_0_[9]\,
      O(3) => \rx_counter0_carry__1_n_4\,
      O(2) => \rx_counter0_carry__1_n_5\,
      O(1) => \rx_counter0_carry__1_n_6\,
      O(0) => \rx_counter0_carry__1_n_7\,
      S(3) => rx_counter0_carry_i_1_n_0,
      S(2) => \rx_counter0_carry_i_2__0_n_0\,
      S(1) => \rx_counter0_carry_i_3__1_n_0\,
      S(0) => rx_counter0_carry_i_4_n_0
    );
\rx_counter0_carry__2\: unisim.vcomponents.CARRY4
     port map (
      CI => \rx_counter0_carry__1_n_0\,
      CO(3 downto 2) => \NLW_rx_counter0_carry__2_CO_UNCONNECTED\(3 downto 2),
      CO(1) => \rx_counter0_carry__2_n_2\,
      CO(0) => \rx_counter0_carry__2_n_3\,
      CYINIT => '0',
      DI(3 downto 2) => B"00",
      DI(1) => \rx_counter_reg_n_0_[14]\,
      DI(0) => \rx_counter_reg_n_0_[13]\,
      O(3) => \NLW_rx_counter0_carry__2_O_UNCONNECTED\(3),
      O(2) => \rx_counter0_carry__2_n_5\,
      O(1) => \rx_counter0_carry__2_n_6\,
      O(0) => \rx_counter0_carry__2_n_7\,
      S(3) => '0',
      S(2) => \rx_counter0_carry_i_1__2_n_0\,
      S(1) => rx_counter0_carry_i_2_n_0,
      S(0) => \rx_counter0_carry_i_3__2_n_0\
    );
rx_counter0_carry_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[12]\,
      O => rx_counter0_carry_i_1_n_0
    );
\rx_counter0_carry_i_1__0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[8]\,
      O => \rx_counter0_carry_i_1__0_n_0\
    );
\rx_counter0_carry_i_1__1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[4]\,
      O => \rx_counter0_carry_i_1__1_n_0\
    );
\rx_counter0_carry_i_1__2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[15]\,
      O => \rx_counter0_carry_i_1__2_n_0\
    );
rx_counter0_carry_i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[14]\,
      O => rx_counter0_carry_i_2_n_0
    );
\rx_counter0_carry_i_2__0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[11]\,
      O => \rx_counter0_carry_i_2__0_n_0\
    );
\rx_counter0_carry_i_2__1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[3]\,
      O => \rx_counter0_carry_i_2__1_n_0\
    );
\rx_counter0_carry_i_2__2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[7]\,
      O => \rx_counter0_carry_i_2__2_n_0\
    );
rx_counter0_carry_i_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[6]\,
      O => rx_counter0_carry_i_3_n_0
    );
\rx_counter0_carry_i_3__0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[2]\,
      O => \rx_counter0_carry_i_3__0_n_0\
    );
\rx_counter0_carry_i_3__1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[10]\,
      O => \rx_counter0_carry_i_3__1_n_0\
    );
\rx_counter0_carry_i_3__2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[13]\,
      O => \rx_counter0_carry_i_3__2_n_0\
    );
rx_counter0_carry_i_4: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[9]\,
      O => rx_counter0_carry_i_4_n_0
    );
\rx_counter0_carry_i_4__0\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[5]\,
      O => \rx_counter0_carry_i_4__0_n_0\
    );
\rx_counter0_carry_i_4__1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \rx_counter_reg_n_0_[1]\,
      O => \rx_counter0_carry_i_4__1_n_0\
    );
\rx_counter[0]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => \rx_counter[15]_i_4_n_0\,
      I1 => \rx_counter_reg_n_0_[0]\,
      O => rx_counter(0)
    );
\rx_counter[10]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1F11"
    )
        port map (
      I0 => rx_state(1),
      I1 => rx_state(0),
      I2 => \rx_counter[11]_i_2_n_0\,
      I3 => \rx_counter0_carry__1_n_6\,
      O => rx_counter(10)
    );
\rx_counter[11]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"EEE0"
    )
        port map (
      I0 => rx_state(1),
      I1 => rx_state(0),
      I2 => \rx_counter[11]_i_2_n_0\,
      I3 => \rx_counter0_carry__1_n_5\,
      O => \rx_counter[11]_i_1_n_0\
    );
\rx_counter[11]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000001000100010"
    )
        port map (
      I0 => \FSM_sequential_rx_state[1]_i_6_n_0\,
      I1 => \FSM_sequential_rx_state[1]_i_5_n_0\,
      I2 => \FSM_sequential_rx_state[1]_i_4_n_0\,
      I3 => \FSM_sequential_rx_state[1]_i_3_n_0\,
      I4 => rx_state(1),
      I5 => rx_state(0),
      O => \rx_counter[11]_i_2_n_0\
    );
\rx_counter[12]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \rx_counter0_carry__1_n_4\,
      I1 => \rx_counter[15]_i_4_n_0\,
      O => rx_counter(12)
    );
\rx_counter[13]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \rx_counter0_carry__2_n_7\,
      I1 => \rx_counter[15]_i_4_n_0\,
      O => rx_counter(13)
    );
\rx_counter[14]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \rx_counter0_carry__2_n_6\,
      I1 => \rx_counter[15]_i_4_n_0\,
      O => rx_counter(14)
    );
\rx_counter[15]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"B"
    )
        port map (
      I0 => \^tx_active_reg_reg_0\,
      I1 => S_AXI_ARESETN,
      O => \rx_counter[15]_i_1_n_0\
    );
\rx_counter[15]_i_2\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"7C7F"
    )
        port map (
      I0 => \FSM_sequential_rx_state[1]_i_2_n_0\,
      I1 => rx_state(0),
      I2 => rx_state(1),
      I3 => p_0_in(7),
      O => rx_counter_1(0)
    );
\rx_counter[15]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => \rx_counter0_carry__2_n_5\,
      I1 => \rx_counter[15]_i_4_n_0\,
      O => rx_counter(15)
    );
\rx_counter[15]_i_4\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1111111111111711"
    )
        port map (
      I0 => rx_state(0),
      I1 => rx_state(1),
      I2 => \FSM_sequential_rx_state[1]_i_3_n_0\,
      I3 => \FSM_sequential_rx_state[1]_i_4_n_0\,
      I4 => \FSM_sequential_rx_state[1]_i_5_n_0\,
      I5 => \FSM_sequential_rx_state[1]_i_6_n_0\,
      O => \rx_counter[15]_i_4_n_0\
    );
\rx_counter[1]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"EEE0"
    )
        port map (
      I0 => rx_state(1),
      I1 => rx_state(0),
      I2 => \rx_counter[11]_i_2_n_0\,
      I3 => rx_counter0_carry_n_7,
      O => \rx_counter[1]_i_1_n_0\
    );
\rx_counter[2]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1F11"
    )
        port map (
      I0 => rx_state(1),
      I1 => rx_state(0),
      I2 => \rx_counter[11]_i_2_n_0\,
      I3 => rx_counter0_carry_n_6,
      O => rx_counter(2)
    );
\rx_counter[3]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => rx_counter0_carry_n_5,
      I1 => \rx_counter[15]_i_4_n_0\,
      O => rx_counter(3)
    );
\rx_counter[4]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => rx_counter0_carry_n_4,
      I1 => \rx_counter[15]_i_4_n_0\,
      O => rx_counter(4)
    );
\rx_counter[5]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \rx_counter0_carry__0_n_7\,
      I1 => \rx_counter[15]_i_4_n_0\,
      O => rx_counter(5)
    );
\rx_counter[6]_i_1\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => \rx_counter0_carry__0_n_6\,
      I1 => \rx_counter[15]_i_4_n_0\,
      O => rx_counter(6)
    );
\rx_counter[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"EEE0"
    )
        port map (
      I0 => rx_state(1),
      I1 => rx_state(0),
      I2 => \rx_counter[11]_i_2_n_0\,
      I3 => \rx_counter0_carry__0_n_5\,
      O => \rx_counter[7]_i_1_n_0\
    );
\rx_counter[8]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"1F11"
    )
        port map (
      I0 => rx_state(1),
      I1 => rx_state(0),
      I2 => \rx_counter[11]_i_2_n_0\,
      I3 => \rx_counter0_carry__0_n_4\,
      O => rx_counter(8)
    );
\rx_counter[9]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"EEE0"
    )
        port map (
      I0 => rx_state(1),
      I1 => rx_state(0),
      I2 => \rx_counter[11]_i_2_n_0\,
      I3 => \rx_counter0_carry__1_n_7\,
      O => \rx_counter[9]_i_1_n_0\
    );
\rx_counter_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(0),
      Q => \rx_counter_reg_n_0_[0]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(10),
      Q => \rx_counter_reg_n_0_[10]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => \rx_counter[11]_i_1_n_0\,
      Q => \rx_counter_reg_n_0_[11]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(12),
      Q => \rx_counter_reg_n_0_[12]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(13),
      Q => \rx_counter_reg_n_0_[13]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(14),
      Q => \rx_counter_reg_n_0_[14]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(15),
      Q => \rx_counter_reg_n_0_[15]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => \rx_counter[1]_i_1_n_0\,
      Q => \rx_counter_reg_n_0_[1]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(2),
      Q => \rx_counter_reg_n_0_[2]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(3),
      Q => \rx_counter_reg_n_0_[3]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(4),
      Q => \rx_counter_reg_n_0_[4]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(5),
      Q => \rx_counter_reg_n_0_[5]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(6),
      Q => \rx_counter_reg_n_0_[6]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => \rx_counter[7]_i_1_n_0\,
      Q => \rx_counter_reg_n_0_[7]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => rx_counter(8),
      Q => \rx_counter_reg_n_0_[8]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_counter_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => rx_counter_1(0),
      D => \rx_counter[9]_i_1_n_0\,
      Q => \rx_counter_reg_n_0_[9]\,
      R => \rx_counter[15]_i_1_n_0\
    );
\rx_data_reg[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"40000000"
    )
        port map (
      I0 => \^tx_active_reg_reg_0\,
      I1 => S_AXI_ARESETN,
      I2 => rx_state(0),
      I3 => rx_state(1),
      I4 => \FSM_sequential_rx_state[1]_i_2_n_0\,
      O => \rx_data_reg[7]_i_1_n_0\
    );
\rx_data_reg_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_data_reg[7]_i_1_n_0\,
      D => \rx_shift_reg_n_0_[0]\,
      Q => rx_data_reg(0),
      R => '0'
    );
\rx_data_reg_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_data_reg[7]_i_1_n_0\,
      D => p_0_in(0),
      Q => rx_data_reg(1),
      R => '0'
    );
\rx_data_reg_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_data_reg[7]_i_1_n_0\,
      D => p_0_in(1),
      Q => rx_data_reg(2),
      R => '0'
    );
\rx_data_reg_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_data_reg[7]_i_1_n_0\,
      D => p_0_in(2),
      Q => rx_data_reg(3),
      R => '0'
    );
\rx_data_reg_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_data_reg[7]_i_1_n_0\,
      D => p_0_in(3),
      Q => rx_data_reg(4),
      R => '0'
    );
\rx_data_reg_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_data_reg[7]_i_1_n_0\,
      D => p_0_in(4),
      Q => rx_data_reg(5),
      R => '0'
    );
\rx_data_reg_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_data_reg[7]_i_1_n_0\,
      D => p_0_in(5),
      Q => rx_data_reg(6),
      R => '0'
    );
\rx_data_reg_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_data_reg[7]_i_1_n_0\,
      D => p_0_in(6),
      Q => rx_data_reg(7),
      R => '0'
    );
rx_data_valid_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"E0E0E0E000E0E0E0"
    )
        port map (
      I0 => rx_data_valid,
      I1 => rx_done_reg_n_0,
      I2 => S_AXI_ARESETN,
      I3 => p_8_in,
      I4 => S_AXI_ARADDR(1),
      I5 => rx_data_valid_i_2_n_0,
      O => rx_data_valid_i_1_n_0
    );
rx_data_valid_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => S_AXI_ARADDR(2),
      I1 => S_AXI_ARADDR(0),
      O => rx_data_valid_i_2_n_0
    );
rx_data_valid_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => rx_data_valid_i_1_n_0,
      Q => rx_data_valid,
      R => '0'
    );
rx_done_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \rx_data_reg[7]_i_1_n_0\,
      Q => rx_done_reg_n_0,
      R => '0'
    );
rx_in_sync1_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => rx_in,
      Q => rx_in_sync1,
      R => '0'
    );
rx_in_sync2_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => rx_in_sync1,
      Q => p_0_in(7),
      R => '0'
    );
rx_int_en_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FEFFFFFF02000000"
    )
        port map (
      I0 => S_AXI_WDATA(1),
      I1 => tx_int_flag_i_2_n_0,
      I2 => S_AXI_AWADDR(2),
      I3 => S_AXI_AWADDR(1),
      I4 => S_AXI_AWADDR(0),
      I5 => p_1_in(1),
      O => rx_int_en_i_1_n_0
    );
rx_int_en_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => rx_int_en_i_1_n_0,
      Q => p_1_in(1),
      R => rst
    );
rx_int_flag_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"0000C0EA"
    )
        port map (
      I0 => \^irq_rx\,
      I1 => p_1_in(1),
      I2 => rx_done_reg_n_0,
      I3 => rx_int_flag1_out,
      I4 => rx_int_flag_i_3_n_0,
      O => rx_int_flag_i_1_n_0
    );
rx_int_flag_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"1000000000000000"
    )
        port map (
      I0 => S_AXI_AWADDR(0),
      I1 => S_AXI_AWADDR(1),
      I2 => S_AXI_AWADDR(2),
      I3 => S_AXI_WDATA(1),
      I4 => \^s_axi_wready\,
      I5 => \^s_axi_awready\,
      O => rx_int_flag1_out
    );
rx_int_flag_i_3: unisim.vcomponents.LUT6
    generic map(
      INIT => X"00001000FFFFFFFF"
    )
        port map (
      I0 => S_AXI_ARADDR(0),
      I1 => S_AXI_ARADDR(2),
      I2 => S_AXI_ARADDR(1),
      I3 => S_AXI_ARVALID,
      I4 => \^axi_rvalid_reg_0\,
      I5 => S_AXI_ARESETN,
      O => rx_int_flag_i_3_n_0
    );
rx_int_flag_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => rx_int_flag_i_1_n_0,
      Q => \^irq_rx\,
      R => '0'
    );
\rx_shift[7]_i_1\: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0040"
    )
        port map (
      I0 => \^tx_active_reg_reg_0\,
      I1 => \FSM_sequential_rx_state[1]_i_2_n_0\,
      I2 => rx_state(1),
      I3 => rx_state(0),
      O => \rx_shift[7]_i_1_n_0\
    );
\rx_shift_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_shift[7]_i_1_n_0\,
      D => p_0_in(0),
      Q => \rx_shift_reg_n_0_[0]\,
      R => rst
    );
\rx_shift_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_shift[7]_i_1_n_0\,
      D => p_0_in(1),
      Q => p_0_in(0),
      R => rst
    );
\rx_shift_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_shift[7]_i_1_n_0\,
      D => p_0_in(2),
      Q => p_0_in(1),
      R => rst
    );
\rx_shift_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_shift[7]_i_1_n_0\,
      D => p_0_in(3),
      Q => p_0_in(2),
      R => rst
    );
\rx_shift_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_shift[7]_i_1_n_0\,
      D => p_0_in(4),
      Q => p_0_in(3),
      R => rst
    );
\rx_shift_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_shift[7]_i_1_n_0\,
      D => p_0_in(5),
      Q => p_0_in(4),
      R => rst
    );
\rx_shift_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_shift[7]_i_1_n_0\,
      D => p_0_in(6),
      Q => p_0_in(5),
      R => rst
    );
\rx_shift_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => \rx_shift[7]_i_1_n_0\,
      D => p_0_in(7),
      Q => p_0_in(6),
      R => rst
    );
tx_active_reg_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FCFFFEFE00000202"
    )
        port map (
      I0 => tx_data_valid_reg_n_0,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_out_reg_i_3_n_0,
      I4 => tx_state(2),
      I5 => \^tx_active_reg_reg_0\,
      O => tx_active_reg_i_1_n_0
    );
tx_active_reg_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => tx_active_reg_i_1_n_0,
      Q => \^tx_active_reg_reg_0\,
      R => rst
    );
\tx_bit_idx[0]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFD7FFF700200000"
    )
        port map (
      I0 => tx_out_reg_i_3_n_0,
      I1 => tx_state(0),
      I2 => tx_state(1),
      I3 => tx_state(2),
      I4 => \FSM_sequential_tx_state[0]_i_2_n_0\,
      I5 => \tx_bit_idx_reg_n_0_[0]\,
      O => \tx_bit_idx[0]_i_1_n_0\
    );
\tx_bit_idx[1]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFF10FF00004000"
    )
        port map (
      I0 => tx_state(2),
      I1 => \tx_bit_idx_reg_n_0_[0]\,
      I2 => tx_state(1),
      I3 => tx_out_reg_i_3_n_0,
      I4 => \tx_bit_idx[1]_i_2_n_0\,
      I5 => \tx_bit_idx_reg_n_0_[1]\,
      O => \tx_bit_idx[1]_i_1_n_0\
    );
\tx_bit_idx[1]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFF00FF80FFFF"
    )
        port map (
      I0 => \tx_bit_idx_reg_n_0_[2]\,
      I1 => \tx_bit_idx_reg_n_0_[1]\,
      I2 => \tx_bit_idx_reg_n_0_[0]\,
      I3 => tx_state(2),
      I4 => tx_state(1),
      I5 => tx_state(0),
      O => \tx_bit_idx[1]_i_2_n_0\
    );
\tx_bit_idx[2]_i_1\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFF7FFF700200000"
    )
        port map (
      I0 => tx_out_reg_i_3_n_0,
      I1 => tx_state(0),
      I2 => tx_state(1),
      I3 => tx_state(2),
      I4 => \tx_bit_idx[2]_i_2_n_0\,
      I5 => \tx_bit_idx_reg_n_0_[2]\,
      O => \tx_bit_idx[2]_i_1_n_0\
    );
\tx_bit_idx[2]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"8"
    )
        port map (
      I0 => \tx_bit_idx_reg_n_0_[0]\,
      I1 => \tx_bit_idx_reg_n_0_[1]\,
      O => \tx_bit_idx[2]_i_2_n_0\
    );
\tx_bit_idx_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \tx_bit_idx[0]_i_1_n_0\,
      Q => \tx_bit_idx_reg_n_0_[0]\,
      R => rst
    );
\tx_bit_idx_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \tx_bit_idx[1]_i_1_n_0\,
      Q => \tx_bit_idx_reg_n_0_[1]\,
      R => rst
    );
\tx_bit_idx_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => \tx_bit_idx[2]_i_1_n_0\,
      Q => \tx_bit_idx_reg_n_0_[2]\,
      R => rst
    );
tx_counter0_carry: unisim.vcomponents.CARRY4
     port map (
      CI => '0',
      CO(3) => tx_counter0_carry_n_0,
      CO(2) => tx_counter0_carry_n_1,
      CO(1) => tx_counter0_carry_n_2,
      CO(0) => tx_counter0_carry_n_3,
      CYINIT => \tx_counter_reg_n_0_[0]\,
      DI(3) => \tx_counter_reg_n_0_[4]\,
      DI(2) => \tx_counter_reg_n_0_[3]\,
      DI(1) => \tx_counter_reg_n_0_[2]\,
      DI(0) => \tx_counter_reg_n_0_[1]\,
      O(3) => tx_counter0_carry_n_4,
      O(2) => tx_counter0_carry_n_5,
      O(1) => tx_counter0_carry_n_6,
      O(0) => tx_counter0_carry_n_7,
      S(3) => tx_counter0_carry_i_1_n_0,
      S(2) => tx_counter0_carry_i_2_n_0,
      S(1) => tx_counter0_carry_i_3_n_0,
      S(0) => tx_counter0_carry_i_4_n_0
    );
\tx_counter0_carry__0\: unisim.vcomponents.CARRY4
     port map (
      CI => tx_counter0_carry_n_0,
      CO(3) => \tx_counter0_carry__0_n_0\,
      CO(2) => \tx_counter0_carry__0_n_1\,
      CO(1) => \tx_counter0_carry__0_n_2\,
      CO(0) => \tx_counter0_carry__0_n_3\,
      CYINIT => '0',
      DI(3) => \tx_counter_reg_n_0_[8]\,
      DI(2) => \tx_counter_reg_n_0_[7]\,
      DI(1) => \tx_counter_reg_n_0_[6]\,
      DI(0) => \tx_counter_reg_n_0_[5]\,
      O(3) => \tx_counter0_carry__0_n_4\,
      O(2) => \tx_counter0_carry__0_n_5\,
      O(1) => \tx_counter0_carry__0_n_6\,
      O(0) => \tx_counter0_carry__0_n_7\,
      S(3) => \tx_counter0_carry__0_i_1_n_0\,
      S(2) => \tx_counter0_carry__0_i_2_n_0\,
      S(1) => \tx_counter0_carry__0_i_3_n_0\,
      S(0) => \tx_counter0_carry__0_i_4_n_0\
    );
\tx_counter0_carry__0_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[8]\,
      O => \tx_counter0_carry__0_i_1_n_0\
    );
\tx_counter0_carry__0_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[7]\,
      O => \tx_counter0_carry__0_i_2_n_0\
    );
\tx_counter0_carry__0_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[6]\,
      O => \tx_counter0_carry__0_i_3_n_0\
    );
\tx_counter0_carry__0_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[5]\,
      O => \tx_counter0_carry__0_i_4_n_0\
    );
\tx_counter0_carry__1\: unisim.vcomponents.CARRY4
     port map (
      CI => \tx_counter0_carry__0_n_0\,
      CO(3) => \tx_counter0_carry__1_n_0\,
      CO(2) => \tx_counter0_carry__1_n_1\,
      CO(1) => \tx_counter0_carry__1_n_2\,
      CO(0) => \tx_counter0_carry__1_n_3\,
      CYINIT => '0',
      DI(3) => \tx_counter_reg_n_0_[12]\,
      DI(2) => \tx_counter_reg_n_0_[11]\,
      DI(1) => \tx_counter_reg_n_0_[10]\,
      DI(0) => \tx_counter_reg_n_0_[9]\,
      O(3) => \tx_counter0_carry__1_n_4\,
      O(2) => \tx_counter0_carry__1_n_5\,
      O(1) => \tx_counter0_carry__1_n_6\,
      O(0) => \tx_counter0_carry__1_n_7\,
      S(3) => \tx_counter0_carry__1_i_1_n_0\,
      S(2) => \tx_counter0_carry__1_i_2_n_0\,
      S(1) => \tx_counter0_carry__1_i_3_n_0\,
      S(0) => \tx_counter0_carry__1_i_4_n_0\
    );
\tx_counter0_carry__1_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[12]\,
      O => \tx_counter0_carry__1_i_1_n_0\
    );
\tx_counter0_carry__1_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[11]\,
      O => \tx_counter0_carry__1_i_2_n_0\
    );
\tx_counter0_carry__1_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[10]\,
      O => \tx_counter0_carry__1_i_3_n_0\
    );
\tx_counter0_carry__1_i_4\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[9]\,
      O => \tx_counter0_carry__1_i_4_n_0\
    );
\tx_counter0_carry__2\: unisim.vcomponents.CARRY4
     port map (
      CI => \tx_counter0_carry__1_n_0\,
      CO(3 downto 2) => \NLW_tx_counter0_carry__2_CO_UNCONNECTED\(3 downto 2),
      CO(1) => \tx_counter0_carry__2_n_2\,
      CO(0) => \tx_counter0_carry__2_n_3\,
      CYINIT => '0',
      DI(3 downto 2) => B"00",
      DI(1) => \tx_counter_reg_n_0_[14]\,
      DI(0) => \tx_counter_reg_n_0_[13]\,
      O(3) => \NLW_tx_counter0_carry__2_O_UNCONNECTED\(3),
      O(2) => \tx_counter0_carry__2_n_5\,
      O(1) => \tx_counter0_carry__2_n_6\,
      O(0) => \tx_counter0_carry__2_n_7\,
      S(3) => '0',
      S(2) => \tx_counter0_carry__2_i_1_n_0\,
      S(1) => \tx_counter0_carry__2_i_2_n_0\,
      S(0) => \tx_counter0_carry__2_i_3_n_0\
    );
\tx_counter0_carry__2_i_1\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[15]\,
      O => \tx_counter0_carry__2_i_1_n_0\
    );
\tx_counter0_carry__2_i_2\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[14]\,
      O => \tx_counter0_carry__2_i_2_n_0\
    );
\tx_counter0_carry__2_i_3\: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[13]\,
      O => \tx_counter0_carry__2_i_3_n_0\
    );
tx_counter0_carry_i_1: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[4]\,
      O => tx_counter0_carry_i_1_n_0
    );
tx_counter0_carry_i_2: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[3]\,
      O => tx_counter0_carry_i_2_n_0
    );
tx_counter0_carry_i_3: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[2]\,
      O => tx_counter0_carry_i_3_n_0
    );
tx_counter0_carry_i_4: unisim.vcomponents.LUT1
    generic map(
      INIT => X"1"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[1]\,
      O => tx_counter0_carry_i_4_n_0
    );
\tx_counter[0]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"AAAAABFF"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => \tx_counter_reg_n_0_[0]\,
      O => tx_counter(0)
    );
\tx_counter[10]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000A2220"
    )
        port map (
      I0 => \tx_counter0_carry__1_n_6\,
      I1 => tx_out_reg_i_3_n_0,
      I2 => tx_state(0),
      I3 => tx_state(1),
      I4 => tx_state(2),
      O => tx_counter(10)
    );
\tx_counter[11]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"ABFFAAAA"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => \tx_counter0_carry__1_n_5\,
      O => tx_counter(11)
    );
\tx_counter[11]_i_2\: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0000001055555555"
    )
        port map (
      I0 => tx_state(2),
      I1 => tx_out_reg_i_4_n_0,
      I2 => tx_out_reg_i_5_n_0,
      I3 => tx_out_reg_i_6_n_0,
      I4 => tx_out_reg_i_7_n_0,
      I5 => \tx_counter[11]_i_3_n_0\,
      O => \tx_counter[11]_i_2_n_0\
    );
\tx_counter[11]_i_3\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"E"
    )
        port map (
      I0 => tx_state(0),
      I1 => tx_state(1),
      O => \tx_counter[11]_i_3_n_0\
    );
\tx_counter[12]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000A2220"
    )
        port map (
      I0 => \tx_counter0_carry__1_n_4\,
      I1 => tx_out_reg_i_3_n_0,
      I2 => tx_state(0),
      I3 => tx_state(1),
      I4 => tx_state(2),
      O => tx_counter(12)
    );
\tx_counter[13]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000A2220"
    )
        port map (
      I0 => \tx_counter0_carry__2_n_7\,
      I1 => tx_out_reg_i_3_n_0,
      I2 => tx_state(0),
      I3 => tx_state(1),
      I4 => tx_state(2),
      O => tx_counter(13)
    );
\tx_counter[14]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000A2220"
    )
        port map (
      I0 => \tx_counter0_carry__2_n_6\,
      I1 => tx_out_reg_i_3_n_0,
      I2 => tx_state(0),
      I3 => tx_state(1),
      I4 => tx_state(2),
      O => tx_counter(14)
    );
\tx_counter[15]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00FE03FE"
    )
        port map (
      I0 => tx_data_valid_reg_n_0,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => tx_out_reg_i_3_n_0,
      O => tx_counter_3(0)
    );
\tx_counter[15]_i_2\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000A2220"
    )
        port map (
      I0 => \tx_counter0_carry__2_n_5\,
      I1 => tx_out_reg_i_3_n_0,
      I2 => tx_state(0),
      I3 => tx_state(1),
      I4 => tx_state(2),
      O => tx_counter(15)
    );
\tx_counter[1]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"ABFFAAAA"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => tx_counter0_carry_n_7,
      O => tx_counter(1)
    );
\tx_counter[2]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000A2220"
    )
        port map (
      I0 => tx_counter0_carry_n_6,
      I1 => tx_out_reg_i_3_n_0,
      I2 => tx_state(0),
      I3 => tx_state(1),
      I4 => tx_state(2),
      O => tx_counter(2)
    );
\tx_counter[3]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"ABFFAAAA"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => tx_counter0_carry_n_5,
      O => tx_counter(3)
    );
\tx_counter[4]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"ABFFAAAA"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => tx_counter0_carry_n_4,
      O => tx_counter(4)
    );
\tx_counter[5]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"ABFFAAAA"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => \tx_counter0_carry__0_n_7\,
      O => tx_counter(5)
    );
\tx_counter[6]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"ABFFAAAA"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => \tx_counter0_carry__0_n_6\,
      O => tx_counter(6)
    );
\tx_counter[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"ABFFAAAA"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => \tx_counter0_carry__0_n_5\,
      O => tx_counter(7)
    );
\tx_counter[8]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"000A2220"
    )
        port map (
      I0 => \tx_counter0_carry__0_n_4\,
      I1 => tx_out_reg_i_3_n_0,
      I2 => tx_state(0),
      I3 => tx_state(1),
      I4 => tx_state(2),
      O => tx_counter(8)
    );
\tx_counter[9]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"ABFFAAAA"
    )
        port map (
      I0 => \tx_counter[11]_i_2_n_0\,
      I1 => tx_state(1),
      I2 => tx_state(0),
      I3 => tx_state(2),
      I4 => \tx_counter0_carry__1_n_7\,
      O => tx_counter(9)
    );
\tx_counter_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(0),
      Q => \tx_counter_reg_n_0_[0]\,
      R => rst
    );
\tx_counter_reg[10]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(10),
      Q => \tx_counter_reg_n_0_[10]\,
      R => rst
    );
\tx_counter_reg[11]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(11),
      Q => \tx_counter_reg_n_0_[11]\,
      R => rst
    );
\tx_counter_reg[12]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(12),
      Q => \tx_counter_reg_n_0_[12]\,
      R => rst
    );
\tx_counter_reg[13]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(13),
      Q => \tx_counter_reg_n_0_[13]\,
      R => rst
    );
\tx_counter_reg[14]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(14),
      Q => \tx_counter_reg_n_0_[14]\,
      R => rst
    );
\tx_counter_reg[15]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(15),
      Q => \tx_counter_reg_n_0_[15]\,
      R => rst
    );
\tx_counter_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(1),
      Q => \tx_counter_reg_n_0_[1]\,
      R => rst
    );
\tx_counter_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(2),
      Q => \tx_counter_reg_n_0_[2]\,
      R => rst
    );
\tx_counter_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(3),
      Q => \tx_counter_reg_n_0_[3]\,
      R => rst
    );
\tx_counter_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(4),
      Q => \tx_counter_reg_n_0_[4]\,
      R => rst
    );
\tx_counter_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(5),
      Q => \tx_counter_reg_n_0_[5]\,
      R => rst
    );
\tx_counter_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(6),
      Q => \tx_counter_reg_n_0_[6]\,
      R => rst
    );
\tx_counter_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(7),
      Q => \tx_counter_reg_n_0_[7]\,
      R => rst
    );
\tx_counter_reg[8]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(8),
      Q => \tx_counter_reg_n_0_[8]\,
      R => rst
    );
\tx_counter_reg[9]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_counter_3(0),
      D => tx_counter(9),
      Q => \tx_counter_reg_n_0_[9]\,
      R => rst
    );
\tx_data_reg[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00000008"
    )
        port map (
      I0 => \^s_axi_wready\,
      I1 => \^s_axi_awready\,
      I2 => S_AXI_AWADDR(2),
      I3 => S_AXI_AWADDR(1),
      I4 => S_AXI_AWADDR(0),
      O => tx_data_reg_0(0)
    );
\tx_data_reg_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_data_reg_0(0),
      D => S_AXI_WDATA(0),
      Q => tx_data_reg(0),
      R => rst
    );
\tx_data_reg_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_data_reg_0(0),
      D => S_AXI_WDATA(1),
      Q => tx_data_reg(1),
      R => rst
    );
\tx_data_reg_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_data_reg_0(0),
      D => S_AXI_WDATA(2),
      Q => tx_data_reg(2),
      R => rst
    );
\tx_data_reg_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_data_reg_0(0),
      D => S_AXI_WDATA(3),
      Q => tx_data_reg(3),
      R => rst
    );
\tx_data_reg_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_data_reg_0(0),
      D => S_AXI_WDATA(4),
      Q => tx_data_reg(4),
      R => rst
    );
\tx_data_reg_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_data_reg_0(0),
      D => S_AXI_WDATA(5),
      Q => tx_data_reg(5),
      R => rst
    );
\tx_data_reg_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_data_reg_0(0),
      D => S_AXI_WDATA(6),
      Q => tx_data_reg(6),
      R => rst
    );
\tx_data_reg_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_data_reg_0(0),
      D => S_AXI_WDATA(7),
      Q => tx_data_reg(7),
      R => rst
    );
tx_data_valid_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"0100000000000000"
    )
        port map (
      I0 => S_AXI_AWADDR(0),
      I1 => S_AXI_AWADDR(1),
      I2 => S_AXI_AWADDR(2),
      I3 => \^s_axi_awready\,
      I4 => \^s_axi_wready\,
      I5 => S_AXI_ARESETN,
      O => tx_data_valid_i_1_n_0
    );
tx_data_valid_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => tx_data_valid_i_1_n_0,
      Q => tx_data_valid_reg_n_0,
      R => '0'
    );
tx_done_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFFFFFF50000C000"
    )
        port map (
      I0 => tx_data_valid_reg_n_0,
      I1 => tx_out_reg_i_3_n_0,
      I2 => tx_state(0),
      I3 => tx_state(1),
      I4 => tx_state(2),
      I5 => p_3_in(3),
      O => tx_done_i_1_n_0
    );
tx_done_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => tx_done_i_1_n_0,
      Q => p_3_in(3),
      R => rst
    );
tx_int_en_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FEFFFFFF02000000"
    )
        port map (
      I0 => S_AXI_WDATA(0),
      I1 => tx_int_flag_i_2_n_0,
      I2 => S_AXI_AWADDR(2),
      I3 => S_AXI_AWADDR(1),
      I4 => S_AXI_AWADDR(0),
      I5 => p_1_in(0),
      O => tx_int_en_i_1_n_0
    );
tx_int_en_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => tx_int_en_i_1_n_0,
      Q => p_1_in(0),
      R => rst
    );
tx_int_flag_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFBFBFBFFF000000"
    )
        port map (
      I0 => tx_int_flag_i_2_n_0,
      I1 => S_AXI_WDATA(0),
      I2 => tx_int_flag_i_3_n_0,
      I3 => p_3_in(3),
      I4 => p_1_in(0),
      I5 => \^irq_tx\,
      O => tx_int_flag_i_1_n_0
    );
tx_int_flag_i_2: unisim.vcomponents.LUT2
    generic map(
      INIT => X"7"
    )
        port map (
      I0 => \^s_axi_wready\,
      I1 => \^s_axi_awready\,
      O => tx_int_flag_i_2_n_0
    );
tx_int_flag_i_3: unisim.vcomponents.LUT3
    generic map(
      INIT => X"02"
    )
        port map (
      I0 => S_AXI_AWADDR(2),
      I1 => S_AXI_AWADDR(1),
      I2 => S_AXI_AWADDR(0),
      O => tx_int_flag_i_3_n_0
    );
tx_int_flag_reg: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => tx_int_flag_i_1_n_0,
      Q => \^irq_tx\,
      R => rst
    );
tx_out_reg_i_1: unisim.vcomponents.LUT6
    generic map(
      INIT => X"FFEFEFEE00202022"
    )
        port map (
      I0 => tx_out_reg_i_2_n_0,
      I1 => tx_state(2),
      I2 => tx_out_reg_i_3_n_0,
      I3 => tx_state(0),
      I4 => tx_state(1),
      I5 => \^tx_out\,
      O => tx_out_reg_i_1_n_0
    );
tx_out_reg_i_2: unisim.vcomponents.LUT6
    generic map(
      INIT => X"BFB0B0B0BFB0BFBF"
    )
        port map (
      I0 => \tx_shift_reg_n_0_[1]\,
      I1 => \FSM_sequential_tx_state[0]_i_2_n_0\,
      I2 => tx_state(1),
      I3 => \tx_shift_reg_n_0_[0]\,
      I4 => tx_state(0),
      I5 => tx_data_valid_reg_n_0,
      O => tx_out_reg_i_2_n_0
    );
tx_out_reg_i_3: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0004"
    )
        port map (
      I0 => tx_out_reg_i_4_n_0,
      I1 => tx_out_reg_i_5_n_0,
      I2 => tx_out_reg_i_6_n_0,
      I3 => tx_out_reg_i_7_n_0,
      O => tx_out_reg_i_3_n_0
    );
tx_out_reg_i_4: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[3]\,
      I1 => \tx_counter_reg_n_0_[8]\,
      I2 => \tx_counter_reg_n_0_[7]\,
      I3 => \tx_counter_reg_n_0_[0]\,
      O => tx_out_reg_i_4_n_0
    );
tx_out_reg_i_5: unisim.vcomponents.LUT4
    generic map(
      INIT => X"0001"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[12]\,
      I1 => \tx_counter_reg_n_0_[14]\,
      I2 => \tx_counter_reg_n_0_[13]\,
      I3 => \tx_counter_reg_n_0_[5]\,
      O => tx_out_reg_i_5_n_0
    );
tx_out_reg_i_6: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[1]\,
      I1 => \tx_counter_reg_n_0_[2]\,
      I2 => \tx_counter_reg_n_0_[10]\,
      I3 => \tx_counter_reg_n_0_[11]\,
      O => tx_out_reg_i_6_n_0
    );
tx_out_reg_i_7: unisim.vcomponents.LUT4
    generic map(
      INIT => X"FFFE"
    )
        port map (
      I0 => \tx_counter_reg_n_0_[15]\,
      I1 => \tx_counter_reg_n_0_[9]\,
      I2 => \tx_counter_reg_n_0_[4]\,
      I3 => \tx_counter_reg_n_0_[6]\,
      O => tx_out_reg_i_7_n_0
    );
tx_out_reg_reg: unisim.vcomponents.FDSE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => tx_out_reg_i_1_n_0,
      Q => \^tx_out\,
      S => rst
    );
tx_ready_reg_i_1: unisim.vcomponents.LUT5
    generic map(
      INIT => X"FFFD0001"
    )
        port map (
      I0 => tx_data_valid_reg_n_0,
      I1 => tx_state(0),
      I2 => tx_state(1),
      I3 => tx_state(2),
      I4 => tx_ready_reg,
      O => tx_ready_reg_i_1_n_0
    );
tx_ready_reg_reg: unisim.vcomponents.FDSE
     port map (
      C => S_AXI_ACLK,
      CE => '1',
      D => tx_ready_reg_i_1_n_0,
      Q => tx_ready_reg,
      S => rst
    );
\tx_shift[0]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => tx_data_reg(0),
      I1 => tx_state(1),
      I2 => \tx_shift_reg_n_0_[1]\,
      O => tx_shift(0)
    );
\tx_shift[1]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => tx_data_reg(1),
      I1 => tx_state(1),
      I2 => \tx_shift_reg_n_0_[2]\,
      O => tx_shift(1)
    );
\tx_shift[2]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => tx_data_reg(2),
      I1 => tx_state(1),
      I2 => \tx_shift_reg_n_0_[3]\,
      O => tx_shift(2)
    );
\tx_shift[3]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => tx_data_reg(3),
      I1 => tx_state(1),
      I2 => \tx_shift_reg_n_0_[4]\,
      O => tx_shift(3)
    );
\tx_shift[4]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => tx_data_reg(4),
      I1 => tx_state(1),
      I2 => \tx_shift_reg_n_0_[5]\,
      O => tx_shift(4)
    );
\tx_shift[5]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => tx_data_reg(5),
      I1 => tx_state(1),
      I2 => \tx_shift_reg_n_0_[6]\,
      O => tx_shift(5)
    );
\tx_shift[6]_i_1\: unisim.vcomponents.LUT3
    generic map(
      INIT => X"E2"
    )
        port map (
      I0 => tx_data_reg(6),
      I1 => tx_state(1),
      I2 => \tx_shift_reg_n_0_[7]\,
      O => tx_shift(6)
    );
\tx_shift[7]_i_1\: unisim.vcomponents.LUT5
    generic map(
      INIT => X"00320002"
    )
        port map (
      I0 => tx_data_valid_reg_n_0,
      I1 => tx_state(0),
      I2 => tx_state(1),
      I3 => tx_state(2),
      I4 => tx_out_reg_i_3_n_0,
      O => tx_shift_2(0)
    );
\tx_shift[7]_i_2\: unisim.vcomponents.LUT2
    generic map(
      INIT => X"2"
    )
        port map (
      I0 => tx_data_reg(7),
      I1 => tx_state(1),
      O => tx_shift(7)
    );
\tx_shift_reg[0]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_shift_2(0),
      D => tx_shift(0),
      Q => \tx_shift_reg_n_0_[0]\,
      R => rst
    );
\tx_shift_reg[1]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_shift_2(0),
      D => tx_shift(1),
      Q => \tx_shift_reg_n_0_[1]\,
      R => rst
    );
\tx_shift_reg[2]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_shift_2(0),
      D => tx_shift(2),
      Q => \tx_shift_reg_n_0_[2]\,
      R => rst
    );
\tx_shift_reg[3]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_shift_2(0),
      D => tx_shift(3),
      Q => \tx_shift_reg_n_0_[3]\,
      R => rst
    );
\tx_shift_reg[4]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_shift_2(0),
      D => tx_shift(4),
      Q => \tx_shift_reg_n_0_[4]\,
      R => rst
    );
\tx_shift_reg[5]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_shift_2(0),
      D => tx_shift(5),
      Q => \tx_shift_reg_n_0_[5]\,
      R => rst
    );
\tx_shift_reg[6]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_shift_2(0),
      D => tx_shift(6),
      Q => \tx_shift_reg_n_0_[6]\,
      R => rst
    );
\tx_shift_reg[7]\: unisim.vcomponents.FDRE
     port map (
      C => S_AXI_ACLK,
      CE => tx_shift_2(0),
      D => tx_shift(7),
      Q => \tx_shift_reg_n_0_[7]\,
      R => rst
    );
end STRUCTURE;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VCOMPONENTS.ALL;
entity riscv_54mhz_axi_esc_uart_0_0 is
  port (
    S_AXI_ACLK : in STD_LOGIC;
    S_AXI_ARESETN : in STD_LOGIC;
    S_AXI_AWADDR : in STD_LOGIC_VECTOR ( 4 downto 0 );
    S_AXI_AWPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_AWVALID : in STD_LOGIC;
    S_AXI_AWREADY : out STD_LOGIC;
    S_AXI_WDATA : in STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_WSTRB : in STD_LOGIC_VECTOR ( 3 downto 0 );
    S_AXI_WVALID : in STD_LOGIC;
    S_AXI_WREADY : out STD_LOGIC;
    S_AXI_BRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_BVALID : out STD_LOGIC;
    S_AXI_BREADY : in STD_LOGIC;
    S_AXI_ARADDR : in STD_LOGIC_VECTOR ( 4 downto 0 );
    S_AXI_ARPROT : in STD_LOGIC_VECTOR ( 2 downto 0 );
    S_AXI_ARVALID : in STD_LOGIC;
    S_AXI_ARREADY : out STD_LOGIC;
    S_AXI_RDATA : out STD_LOGIC_VECTOR ( 31 downto 0 );
    S_AXI_RRESP : out STD_LOGIC_VECTOR ( 1 downto 0 );
    S_AXI_RVALID : out STD_LOGIC;
    S_AXI_RREADY : in STD_LOGIC;
    tx_out : out STD_LOGIC;
    rx_in : in STD_LOGIC;
    tx_active : out STD_LOGIC;
    irq_tx : out STD_LOGIC;
    irq_rx : out STD_LOGIC
  );
  attribute NotValidForBitStream : boolean;
  attribute NotValidForBitStream of riscv_54mhz_axi_esc_uart_0_0 : entity is true;
  attribute CHECK_LICENSE_TYPE : string;
  attribute CHECK_LICENSE_TYPE of riscv_54mhz_axi_esc_uart_0_0 : entity is "riscv_54mhz_axi_esc_uart_0_0,axi_esc_uart,{}";
  attribute DowngradeIPIdentifiedWarnings : string;
  attribute DowngradeIPIdentifiedWarnings of riscv_54mhz_axi_esc_uart_0_0 : entity is "yes";
  attribute IP_DEFINITION_SOURCE : string;
  attribute IP_DEFINITION_SOURCE of riscv_54mhz_axi_esc_uart_0_0 : entity is "module_ref";
  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of riscv_54mhz_axi_esc_uart_0_0 : entity is "axi_esc_uart,Vivado 2025.2";
end riscv_54mhz_axi_esc_uart_0_0;

architecture STRUCTURE of riscv_54mhz_axi_esc_uart_0_0 is
  signal \<const0>\ : STD_LOGIC;
  signal \^s_axi_rdata\ : STD_LOGIC_VECTOR ( 7 downto 0 );
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of S_AXI_ACLK : signal is "xilinx.com:signal:clock:1.0 S_AXI_ACLK CLK";
  attribute X_INTERFACE_MODE : string;
  attribute X_INTERFACE_MODE of S_AXI_ACLK : signal is "slave";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of S_AXI_ACLK : signal is "XIL_INTERFACENAME S_AXI_ACLK, ASSOCIATED_BUSIF S_AXI, ASSOCIATED_RESET S_AXI_ARESETN, FREQ_HZ 54000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of S_AXI_ARESETN : signal is "xilinx.com:signal:reset:1.0 S_AXI_ARESETN RST";
  attribute X_INTERFACE_MODE of S_AXI_ARESETN : signal is "slave";
  attribute X_INTERFACE_PARAMETER of S_AXI_ARESETN : signal is "XIL_INTERFACENAME S_AXI_ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of S_AXI_ARREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARREADY";
  attribute X_INTERFACE_INFO of S_AXI_ARVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARVALID";
  attribute X_INTERFACE_INFO of S_AXI_AWREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWREADY";
  attribute X_INTERFACE_INFO of S_AXI_AWVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWVALID";
  attribute X_INTERFACE_INFO of S_AXI_BREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI BREADY";
  attribute X_INTERFACE_INFO of S_AXI_BVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI BVALID";
  attribute X_INTERFACE_INFO of S_AXI_RREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI RREADY";
  attribute X_INTERFACE_INFO of S_AXI_RVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI RVALID";
  attribute X_INTERFACE_INFO of S_AXI_WREADY : signal is "xilinx.com:interface:aximm:1.0 S_AXI WREADY";
  attribute X_INTERFACE_INFO of S_AXI_WVALID : signal is "xilinx.com:interface:aximm:1.0 S_AXI WVALID";
  attribute X_INTERFACE_INFO of S_AXI_ARADDR : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARADDR";
  attribute X_INTERFACE_INFO of S_AXI_ARPROT : signal is "xilinx.com:interface:aximm:1.0 S_AXI ARPROT";
  attribute X_INTERFACE_INFO of S_AXI_AWADDR : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWADDR";
  attribute X_INTERFACE_MODE of S_AXI_AWADDR : signal is "slave";
  attribute X_INTERFACE_PARAMETER of S_AXI_AWADDR : signal is "XIL_INTERFACENAME S_AXI, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 54000000, ID_WIDTH 0, ADDR_WIDTH 5, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0";
  attribute X_INTERFACE_INFO of S_AXI_AWPROT : signal is "xilinx.com:interface:aximm:1.0 S_AXI AWPROT";
  attribute X_INTERFACE_INFO of S_AXI_BRESP : signal is "xilinx.com:interface:aximm:1.0 S_AXI BRESP";
  attribute X_INTERFACE_INFO of S_AXI_RDATA : signal is "xilinx.com:interface:aximm:1.0 S_AXI RDATA";
  attribute X_INTERFACE_INFO of S_AXI_RRESP : signal is "xilinx.com:interface:aximm:1.0 S_AXI RRESP";
  attribute X_INTERFACE_INFO of S_AXI_WDATA : signal is "xilinx.com:interface:aximm:1.0 S_AXI WDATA";
  attribute X_INTERFACE_INFO of S_AXI_WSTRB : signal is "xilinx.com:interface:aximm:1.0 S_AXI WSTRB";
begin
  S_AXI_BRESP(1) <= \<const0>\;
  S_AXI_BRESP(0) <= \<const0>\;
  S_AXI_RDATA(31) <= \<const0>\;
  S_AXI_RDATA(30) <= \<const0>\;
  S_AXI_RDATA(29) <= \<const0>\;
  S_AXI_RDATA(28) <= \<const0>\;
  S_AXI_RDATA(27) <= \<const0>\;
  S_AXI_RDATA(26) <= \<const0>\;
  S_AXI_RDATA(25) <= \<const0>\;
  S_AXI_RDATA(24) <= \<const0>\;
  S_AXI_RDATA(23) <= \<const0>\;
  S_AXI_RDATA(22) <= \<const0>\;
  S_AXI_RDATA(21) <= \<const0>\;
  S_AXI_RDATA(20) <= \<const0>\;
  S_AXI_RDATA(19) <= \<const0>\;
  S_AXI_RDATA(18) <= \<const0>\;
  S_AXI_RDATA(17) <= \<const0>\;
  S_AXI_RDATA(16) <= \<const0>\;
  S_AXI_RDATA(15) <= \<const0>\;
  S_AXI_RDATA(14) <= \<const0>\;
  S_AXI_RDATA(13) <= \<const0>\;
  S_AXI_RDATA(12) <= \<const0>\;
  S_AXI_RDATA(11) <= \<const0>\;
  S_AXI_RDATA(10) <= \<const0>\;
  S_AXI_RDATA(9) <= \<const0>\;
  S_AXI_RDATA(8) <= \<const0>\;
  S_AXI_RDATA(7 downto 0) <= \^s_axi_rdata\(7 downto 0);
  S_AXI_RRESP(1) <= \<const0>\;
  S_AXI_RRESP(0) <= \<const0>\;
GND: unisim.vcomponents.GND
     port map (
      G => \<const0>\
    );
inst: entity work.riscv_54mhz_axi_esc_uart_0_0_axi_esc_uart
     port map (
      S_AXI_ACLK => S_AXI_ACLK,
      S_AXI_ARADDR(2 downto 0) => S_AXI_ARADDR(4 downto 2),
      S_AXI_ARESETN => S_AXI_ARESETN,
      S_AXI_ARREADY => S_AXI_ARREADY,
      S_AXI_ARVALID => S_AXI_ARVALID,
      S_AXI_AWADDR(2 downto 0) => S_AXI_AWADDR(4 downto 2),
      S_AXI_AWREADY => S_AXI_AWREADY,
      S_AXI_AWVALID => S_AXI_AWVALID,
      S_AXI_BREADY => S_AXI_BREADY,
      S_AXI_RDATA(7 downto 0) => \^s_axi_rdata\(7 downto 0),
      S_AXI_RREADY => S_AXI_RREADY,
      S_AXI_WDATA(7 downto 0) => S_AXI_WDATA(7 downto 0),
      S_AXI_WREADY => S_AXI_WREADY,
      S_AXI_WVALID => S_AXI_WVALID,
      axi_bvalid_reg_0 => S_AXI_BVALID,
      axi_rvalid_reg_0 => S_AXI_RVALID,
      irq_rx => irq_rx,
      irq_tx => irq_tx,
      rx_in => rx_in,
      tx_active_reg_reg_0 => tx_active,
      tx_out => tx_out
    );
end STRUCTURE;
