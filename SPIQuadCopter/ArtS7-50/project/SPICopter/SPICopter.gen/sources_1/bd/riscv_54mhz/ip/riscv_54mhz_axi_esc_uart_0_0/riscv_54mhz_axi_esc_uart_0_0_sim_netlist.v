// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
// Date        : Mon Mar  9 22:47:50 2026
// Host        : hp running 64-bit Ubuntu 24.04.3 LTS
// Command     : write_verilog -force -mode funcsim
//               /media/tcmichals/projects/Tang9K/HacksterIO/SPIQuadCopter/ArtS7-50/project/SPICopter/SPICopter.gen/sources_1/bd/riscv_54mhz/ip/riscv_54mhz_axi_esc_uart_0_0/riscv_54mhz_axi_esc_uart_0_0_sim_netlist.v
// Design      : riscv_54mhz_axi_esc_uart_0_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7s50csga324-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "riscv_54mhz_axi_esc_uart_0_0,axi_esc_uart,{}" *) (* DowngradeIPIdentifiedWarnings = "yes" *) (* IP_DEFINITION_SOURCE = "module_ref" *) 
(* X_CORE_INFO = "axi_esc_uart,Vivado 2025.2" *) 
(* NotValidForBitStream *)
module riscv_54mhz_axi_esc_uart_0_0
   (S_AXI_ACLK,
    S_AXI_ARESETN,
    S_AXI_AWADDR,
    S_AXI_AWPROT,
    S_AXI_AWVALID,
    S_AXI_AWREADY,
    S_AXI_WDATA,
    S_AXI_WSTRB,
    S_AXI_WVALID,
    S_AXI_WREADY,
    S_AXI_BRESP,
    S_AXI_BVALID,
    S_AXI_BREADY,
    S_AXI_ARADDR,
    S_AXI_ARPROT,
    S_AXI_ARVALID,
    S_AXI_ARREADY,
    S_AXI_RDATA,
    S_AXI_RRESP,
    S_AXI_RVALID,
    S_AXI_RREADY,
    tx_out,
    rx_in,
    tx_active,
    irq_tx,
    irq_rx);
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 S_AXI_ACLK CLK" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_ACLK, ASSOCIATED_BUSIF S_AXI, ASSOCIATED_RESET S_AXI_ARESETN, FREQ_HZ 54000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, INSERT_VIP 0" *) input S_AXI_ACLK;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 S_AXI_ARESETN RST" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI_ARESETN, POLARITY ACTIVE_LOW, INSERT_VIP 0" *) input S_AXI_ARESETN;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWADDR" *) (* X_INTERFACE_MODE = "slave" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME S_AXI, DATA_WIDTH 32, PROTOCOL AXI4LITE, FREQ_HZ 54000000, ID_WIDTH 0, ADDR_WIDTH 5, AWUSER_WIDTH 0, ARUSER_WIDTH 0, WUSER_WIDTH 0, RUSER_WIDTH 0, BUSER_WIDTH 0, READ_WRITE_MODE READ_WRITE, HAS_BURST 0, HAS_LOCK 0, HAS_PROT 1, HAS_CACHE 0, HAS_QOS 0, HAS_REGION 0, HAS_WSTRB 1, HAS_BRESP 1, HAS_RRESP 1, SUPPORTS_NARROW_BURST 0, NUM_READ_OUTSTANDING 1, NUM_WRITE_OUTSTANDING 1, MAX_BURST_LENGTH 1, PHASE 0.0, CLK_DOMAIN /clk_wiz_0_clk_out1, NUM_READ_THREADS 1, NUM_WRITE_THREADS 1, RUSER_BITS_PER_BYTE 0, WUSER_BITS_PER_BYTE 0, INSERT_VIP 0" *) input [4:0]S_AXI_AWADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWPROT" *) input [2:0]S_AXI_AWPROT;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWVALID" *) input S_AXI_AWVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI AWREADY" *) output S_AXI_AWREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WDATA" *) input [31:0]S_AXI_WDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WSTRB" *) input [3:0]S_AXI_WSTRB;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WVALID" *) input S_AXI_WVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI WREADY" *) output S_AXI_WREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BRESP" *) output [1:0]S_AXI_BRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BVALID" *) output S_AXI_BVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI BREADY" *) input S_AXI_BREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARADDR" *) input [4:0]S_AXI_ARADDR;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARPROT" *) input [2:0]S_AXI_ARPROT;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARVALID" *) input S_AXI_ARVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI ARREADY" *) output S_AXI_ARREADY;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RDATA" *) output [31:0]S_AXI_RDATA;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RRESP" *) output [1:0]S_AXI_RRESP;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RVALID" *) output S_AXI_RVALID;
  (* X_INTERFACE_INFO = "xilinx.com:interface:aximm:1.0 S_AXI RREADY" *) input S_AXI_RREADY;
  output tx_out;
  input rx_in;
  output tx_active;
  output irq_tx;
  output irq_rx;

  wire \<const0> ;
  wire S_AXI_ACLK;
  wire [4:0]S_AXI_ARADDR;
  wire S_AXI_ARESETN;
  wire S_AXI_ARREADY;
  wire S_AXI_ARVALID;
  wire [4:0]S_AXI_AWADDR;
  wire S_AXI_AWREADY;
  wire S_AXI_AWVALID;
  wire S_AXI_BREADY;
  wire S_AXI_BVALID;
  wire [7:0]\^S_AXI_RDATA ;
  wire S_AXI_RREADY;
  wire S_AXI_RVALID;
  wire [31:0]S_AXI_WDATA;
  wire S_AXI_WREADY;
  wire S_AXI_WVALID;
  wire irq_rx;
  wire irq_tx;
  wire rx_in;
  wire tx_active;
  wire tx_out;

  assign S_AXI_BRESP[1] = \<const0> ;
  assign S_AXI_BRESP[0] = \<const0> ;
  assign S_AXI_RDATA[31] = \<const0> ;
  assign S_AXI_RDATA[30] = \<const0> ;
  assign S_AXI_RDATA[29] = \<const0> ;
  assign S_AXI_RDATA[28] = \<const0> ;
  assign S_AXI_RDATA[27] = \<const0> ;
  assign S_AXI_RDATA[26] = \<const0> ;
  assign S_AXI_RDATA[25] = \<const0> ;
  assign S_AXI_RDATA[24] = \<const0> ;
  assign S_AXI_RDATA[23] = \<const0> ;
  assign S_AXI_RDATA[22] = \<const0> ;
  assign S_AXI_RDATA[21] = \<const0> ;
  assign S_AXI_RDATA[20] = \<const0> ;
  assign S_AXI_RDATA[19] = \<const0> ;
  assign S_AXI_RDATA[18] = \<const0> ;
  assign S_AXI_RDATA[17] = \<const0> ;
  assign S_AXI_RDATA[16] = \<const0> ;
  assign S_AXI_RDATA[15] = \<const0> ;
  assign S_AXI_RDATA[14] = \<const0> ;
  assign S_AXI_RDATA[13] = \<const0> ;
  assign S_AXI_RDATA[12] = \<const0> ;
  assign S_AXI_RDATA[11] = \<const0> ;
  assign S_AXI_RDATA[10] = \<const0> ;
  assign S_AXI_RDATA[9] = \<const0> ;
  assign S_AXI_RDATA[8] = \<const0> ;
  assign S_AXI_RDATA[7:0] = \^S_AXI_RDATA [7:0];
  assign S_AXI_RRESP[1] = \<const0> ;
  assign S_AXI_RRESP[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  riscv_54mhz_axi_esc_uart_0_0_axi_esc_uart inst
       (.S_AXI_ACLK(S_AXI_ACLK),
        .S_AXI_ARADDR(S_AXI_ARADDR[4:2]),
        .S_AXI_ARESETN(S_AXI_ARESETN),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_AWADDR(S_AXI_AWADDR[4:2]),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_RDATA(\^S_AXI_RDATA ),
        .S_AXI_RREADY(S_AXI_RREADY),
        .S_AXI_WDATA(S_AXI_WDATA[7:0]),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_WVALID(S_AXI_WVALID),
        .axi_bvalid_reg_0(S_AXI_BVALID),
        .axi_rvalid_reg_0(S_AXI_RVALID),
        .irq_rx(irq_rx),
        .irq_tx(irq_tx),
        .rx_in(rx_in),
        .tx_active_reg_reg_0(tx_active),
        .tx_out(tx_out));
endmodule

(* ORIG_REF_NAME = "axi_esc_uart" *) 
module riscv_54mhz_axi_esc_uart_0_0_axi_esc_uart
   (S_AXI_AWREADY,
    S_AXI_WREADY,
    axi_rvalid_reg_0,
    S_AXI_ARREADY,
    tx_active_reg_reg_0,
    irq_tx,
    irq_rx,
    S_AXI_RDATA,
    axi_bvalid_reg_0,
    tx_out,
    S_AXI_AWADDR,
    S_AXI_ARESETN,
    S_AXI_ARADDR,
    S_AXI_ARVALID,
    S_AXI_ACLK,
    S_AXI_WDATA,
    rx_in,
    S_AXI_AWVALID,
    S_AXI_WVALID,
    S_AXI_BREADY,
    S_AXI_RREADY);
  output S_AXI_AWREADY;
  output S_AXI_WREADY;
  output axi_rvalid_reg_0;
  output S_AXI_ARREADY;
  output tx_active_reg_reg_0;
  output irq_tx;
  output irq_rx;
  output [7:0]S_AXI_RDATA;
  output axi_bvalid_reg_0;
  output tx_out;
  input [2:0]S_AXI_AWADDR;
  input S_AXI_ARESETN;
  input [2:0]S_AXI_ARADDR;
  input S_AXI_ARVALID;
  input S_AXI_ACLK;
  input [7:0]S_AXI_WDATA;
  input rx_in;
  input S_AXI_AWVALID;
  input S_AXI_WVALID;
  input S_AXI_BREADY;
  input S_AXI_RREADY;

  wire \FSM_sequential_rx_state[0]_i_1_n_0 ;
  wire \FSM_sequential_rx_state[0]_i_2_n_0 ;
  wire \FSM_sequential_rx_state[1]_i_1_n_0 ;
  wire \FSM_sequential_rx_state[1]_i_2_n_0 ;
  wire \FSM_sequential_rx_state[1]_i_3_n_0 ;
  wire \FSM_sequential_rx_state[1]_i_4_n_0 ;
  wire \FSM_sequential_rx_state[1]_i_5_n_0 ;
  wire \FSM_sequential_rx_state[1]_i_6_n_0 ;
  wire \FSM_sequential_tx_state[0]_i_1_n_0 ;
  wire \FSM_sequential_tx_state[0]_i_2_n_0 ;
  wire \FSM_sequential_tx_state[1]_i_1_n_0 ;
  wire \FSM_sequential_tx_state[2]_i_1_n_0 ;
  wire S_AXI_ACLK;
  wire [2:0]S_AXI_ARADDR;
  wire S_AXI_ARESETN;
  wire S_AXI_ARREADY;
  wire S_AXI_ARVALID;
  wire [2:0]S_AXI_AWADDR;
  wire S_AXI_AWREADY;
  wire S_AXI_AWVALID;
  wire S_AXI_BREADY;
  wire [7:0]S_AXI_RDATA;
  wire S_AXI_RREADY;
  wire [7:0]S_AXI_WDATA;
  wire S_AXI_WREADY;
  wire S_AXI_WVALID;
  wire axi_arready0;
  wire axi_awready0;
  wire axi_bvalid_i_1_n_0;
  wire axi_bvalid_reg_0;
  wire [7:0]axi_rdata;
  wire \axi_rdata[0]_i_2_n_0 ;
  wire \axi_rdata[1]_i_2_n_0 ;
  wire axi_rvalid_i_1_n_0;
  wire axi_rvalid_reg_0;
  wire axi_wready0;
  wire irq_rx;
  wire irq_tx;
  wire [7:0]p_0_in;
  wire [1:0]p_1_in;
  wire [3:3]p_3_in;
  wire p_8_in;
  wire rst;
  wire \rx_bit_idx[0]_i_1_n_0 ;
  wire \rx_bit_idx[1]_i_1_n_0 ;
  wire \rx_bit_idx[1]_i_2_n_0 ;
  wire \rx_bit_idx[1]_i_3_n_0 ;
  wire \rx_bit_idx[2]_i_1_n_0 ;
  wire \rx_bit_idx[2]_i_2_n_0 ;
  wire \rx_bit_idx_reg_n_0_[0] ;
  wire \rx_bit_idx_reg_n_0_[1] ;
  wire \rx_bit_idx_reg_n_0_[2] ;
  wire [15:0]rx_counter;
  wire rx_counter0_carry__0_n_0;
  wire rx_counter0_carry__0_n_1;
  wire rx_counter0_carry__0_n_2;
  wire rx_counter0_carry__0_n_3;
  wire rx_counter0_carry__0_n_4;
  wire rx_counter0_carry__0_n_5;
  wire rx_counter0_carry__0_n_6;
  wire rx_counter0_carry__0_n_7;
  wire rx_counter0_carry__1_n_0;
  wire rx_counter0_carry__1_n_1;
  wire rx_counter0_carry__1_n_2;
  wire rx_counter0_carry__1_n_3;
  wire rx_counter0_carry__1_n_4;
  wire rx_counter0_carry__1_n_5;
  wire rx_counter0_carry__1_n_6;
  wire rx_counter0_carry__1_n_7;
  wire rx_counter0_carry__2_n_2;
  wire rx_counter0_carry__2_n_3;
  wire rx_counter0_carry__2_n_5;
  wire rx_counter0_carry__2_n_6;
  wire rx_counter0_carry__2_n_7;
  wire rx_counter0_carry_i_1__0_n_0;
  wire rx_counter0_carry_i_1__1_n_0;
  wire rx_counter0_carry_i_1__2_n_0;
  wire rx_counter0_carry_i_1_n_0;
  wire rx_counter0_carry_i_2__0_n_0;
  wire rx_counter0_carry_i_2__1_n_0;
  wire rx_counter0_carry_i_2__2_n_0;
  wire rx_counter0_carry_i_2_n_0;
  wire rx_counter0_carry_i_3__0_n_0;
  wire rx_counter0_carry_i_3__1_n_0;
  wire rx_counter0_carry_i_3__2_n_0;
  wire rx_counter0_carry_i_3_n_0;
  wire rx_counter0_carry_i_4__0_n_0;
  wire rx_counter0_carry_i_4__1_n_0;
  wire rx_counter0_carry_i_4_n_0;
  wire rx_counter0_carry_n_0;
  wire rx_counter0_carry_n_1;
  wire rx_counter0_carry_n_2;
  wire rx_counter0_carry_n_3;
  wire rx_counter0_carry_n_4;
  wire rx_counter0_carry_n_5;
  wire rx_counter0_carry_n_6;
  wire rx_counter0_carry_n_7;
  wire \rx_counter[11]_i_1_n_0 ;
  wire \rx_counter[11]_i_2_n_0 ;
  wire \rx_counter[15]_i_1_n_0 ;
  wire \rx_counter[15]_i_4_n_0 ;
  wire \rx_counter[1]_i_1_n_0 ;
  wire \rx_counter[7]_i_1_n_0 ;
  wire \rx_counter[9]_i_1_n_0 ;
  wire [0:0]rx_counter_1;
  wire \rx_counter_reg_n_0_[0] ;
  wire \rx_counter_reg_n_0_[10] ;
  wire \rx_counter_reg_n_0_[11] ;
  wire \rx_counter_reg_n_0_[12] ;
  wire \rx_counter_reg_n_0_[13] ;
  wire \rx_counter_reg_n_0_[14] ;
  wire \rx_counter_reg_n_0_[15] ;
  wire \rx_counter_reg_n_0_[1] ;
  wire \rx_counter_reg_n_0_[2] ;
  wire \rx_counter_reg_n_0_[3] ;
  wire \rx_counter_reg_n_0_[4] ;
  wire \rx_counter_reg_n_0_[5] ;
  wire \rx_counter_reg_n_0_[6] ;
  wire \rx_counter_reg_n_0_[7] ;
  wire \rx_counter_reg_n_0_[8] ;
  wire \rx_counter_reg_n_0_[9] ;
  wire [7:0]rx_data_reg;
  wire \rx_data_reg[7]_i_1_n_0 ;
  wire rx_data_valid;
  wire rx_data_valid_i_1_n_0;
  wire rx_data_valid_i_2_n_0;
  wire rx_done_reg_n_0;
  wire rx_in;
  wire rx_in_sync1;
  wire rx_int_en_i_1_n_0;
  wire rx_int_flag1_out;
  wire rx_int_flag_i_1_n_0;
  wire rx_int_flag_i_3_n_0;
  wire \rx_shift[7]_i_1_n_0 ;
  wire \rx_shift_reg_n_0_[0] ;
  wire [1:0]rx_state;
  wire tx_active_reg_i_1_n_0;
  wire tx_active_reg_reg_0;
  wire \tx_bit_idx[0]_i_1_n_0 ;
  wire \tx_bit_idx[1]_i_1_n_0 ;
  wire \tx_bit_idx[1]_i_2_n_0 ;
  wire \tx_bit_idx[2]_i_1_n_0 ;
  wire \tx_bit_idx[2]_i_2_n_0 ;
  wire \tx_bit_idx_reg_n_0_[0] ;
  wire \tx_bit_idx_reg_n_0_[1] ;
  wire \tx_bit_idx_reg_n_0_[2] ;
  wire [15:0]tx_counter;
  wire tx_counter0_carry__0_i_1_n_0;
  wire tx_counter0_carry__0_i_2_n_0;
  wire tx_counter0_carry__0_i_3_n_0;
  wire tx_counter0_carry__0_i_4_n_0;
  wire tx_counter0_carry__0_n_0;
  wire tx_counter0_carry__0_n_1;
  wire tx_counter0_carry__0_n_2;
  wire tx_counter0_carry__0_n_3;
  wire tx_counter0_carry__0_n_4;
  wire tx_counter0_carry__0_n_5;
  wire tx_counter0_carry__0_n_6;
  wire tx_counter0_carry__0_n_7;
  wire tx_counter0_carry__1_i_1_n_0;
  wire tx_counter0_carry__1_i_2_n_0;
  wire tx_counter0_carry__1_i_3_n_0;
  wire tx_counter0_carry__1_i_4_n_0;
  wire tx_counter0_carry__1_n_0;
  wire tx_counter0_carry__1_n_1;
  wire tx_counter0_carry__1_n_2;
  wire tx_counter0_carry__1_n_3;
  wire tx_counter0_carry__1_n_4;
  wire tx_counter0_carry__1_n_5;
  wire tx_counter0_carry__1_n_6;
  wire tx_counter0_carry__1_n_7;
  wire tx_counter0_carry__2_i_1_n_0;
  wire tx_counter0_carry__2_i_2_n_0;
  wire tx_counter0_carry__2_i_3_n_0;
  wire tx_counter0_carry__2_n_2;
  wire tx_counter0_carry__2_n_3;
  wire tx_counter0_carry__2_n_5;
  wire tx_counter0_carry__2_n_6;
  wire tx_counter0_carry__2_n_7;
  wire tx_counter0_carry_i_1_n_0;
  wire tx_counter0_carry_i_2_n_0;
  wire tx_counter0_carry_i_3_n_0;
  wire tx_counter0_carry_i_4_n_0;
  wire tx_counter0_carry_n_0;
  wire tx_counter0_carry_n_1;
  wire tx_counter0_carry_n_2;
  wire tx_counter0_carry_n_3;
  wire tx_counter0_carry_n_4;
  wire tx_counter0_carry_n_5;
  wire tx_counter0_carry_n_6;
  wire tx_counter0_carry_n_7;
  wire \tx_counter[11]_i_2_n_0 ;
  wire \tx_counter[11]_i_3_n_0 ;
  wire [0:0]tx_counter_3;
  wire \tx_counter_reg_n_0_[0] ;
  wire \tx_counter_reg_n_0_[10] ;
  wire \tx_counter_reg_n_0_[11] ;
  wire \tx_counter_reg_n_0_[12] ;
  wire \tx_counter_reg_n_0_[13] ;
  wire \tx_counter_reg_n_0_[14] ;
  wire \tx_counter_reg_n_0_[15] ;
  wire \tx_counter_reg_n_0_[1] ;
  wire \tx_counter_reg_n_0_[2] ;
  wire \tx_counter_reg_n_0_[3] ;
  wire \tx_counter_reg_n_0_[4] ;
  wire \tx_counter_reg_n_0_[5] ;
  wire \tx_counter_reg_n_0_[6] ;
  wire \tx_counter_reg_n_0_[7] ;
  wire \tx_counter_reg_n_0_[8] ;
  wire \tx_counter_reg_n_0_[9] ;
  wire [7:0]tx_data_reg;
  wire [0:0]tx_data_reg_0;
  wire tx_data_valid_i_1_n_0;
  wire tx_data_valid_reg_n_0;
  wire tx_done_i_1_n_0;
  wire tx_int_en_i_1_n_0;
  wire tx_int_flag_i_1_n_0;
  wire tx_int_flag_i_2_n_0;
  wire tx_int_flag_i_3_n_0;
  wire tx_out;
  wire tx_out_reg_i_1_n_0;
  wire tx_out_reg_i_2_n_0;
  wire tx_out_reg_i_3_n_0;
  wire tx_out_reg_i_4_n_0;
  wire tx_out_reg_i_5_n_0;
  wire tx_out_reg_i_6_n_0;
  wire tx_out_reg_i_7_n_0;
  wire tx_ready_reg;
  wire tx_ready_reg_i_1_n_0;
  wire [7:0]tx_shift;
  wire [0:0]tx_shift_2;
  wire \tx_shift_reg_n_0_[0] ;
  wire \tx_shift_reg_n_0_[1] ;
  wire \tx_shift_reg_n_0_[2] ;
  wire \tx_shift_reg_n_0_[3] ;
  wire \tx_shift_reg_n_0_[4] ;
  wire \tx_shift_reg_n_0_[5] ;
  wire \tx_shift_reg_n_0_[6] ;
  wire \tx_shift_reg_n_0_[7] ;
  wire [2:0]tx_state;
  wire [3:2]NLW_rx_counter0_carry__2_CO_UNCONNECTED;
  wire [3:3]NLW_rx_counter0_carry__2_O_UNCONNECTED;
  wire [3:2]NLW_tx_counter0_carry__2_CO_UNCONNECTED;
  wire [3:3]NLW_tx_counter0_carry__2_O_UNCONNECTED;

  LUT6 #(
    .INIT(64'h0000000062226277)) 
    \FSM_sequential_rx_state[0]_i_1 
       (.I0(rx_state[0]),
        .I1(\FSM_sequential_rx_state[1]_i_2_n_0 ),
        .I2(\FSM_sequential_rx_state[0]_i_2_n_0 ),
        .I3(rx_state[1]),
        .I4(p_0_in[7]),
        .I5(\rx_counter[15]_i_1_n_0 ),
        .O(\FSM_sequential_rx_state[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h80)) 
    \FSM_sequential_rx_state[0]_i_2 
       (.I0(\rx_bit_idx_reg_n_0_[0] ),
        .I1(\rx_bit_idx_reg_n_0_[1] ),
        .I2(\rx_bit_idx_reg_n_0_[2] ),
        .O(\FSM_sequential_rx_state[0]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'h006A)) 
    \FSM_sequential_rx_state[1]_i_1 
       (.I0(rx_state[1]),
        .I1(rx_state[0]),
        .I2(\FSM_sequential_rx_state[1]_i_2_n_0 ),
        .I3(\rx_counter[15]_i_1_n_0 ),
        .O(\FSM_sequential_rx_state[1]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h0004)) 
    \FSM_sequential_rx_state[1]_i_2 
       (.I0(\FSM_sequential_rx_state[1]_i_3_n_0 ),
        .I1(\FSM_sequential_rx_state[1]_i_4_n_0 ),
        .I2(\FSM_sequential_rx_state[1]_i_5_n_0 ),
        .I3(\FSM_sequential_rx_state[1]_i_6_n_0 ),
        .O(\FSM_sequential_rx_state[1]_i_2_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \FSM_sequential_rx_state[1]_i_3 
       (.I0(\rx_counter_reg_n_0_[7] ),
        .I1(\rx_counter_reg_n_0_[6] ),
        .I2(\rx_counter_reg_n_0_[4] ),
        .I3(\rx_counter_reg_n_0_[5] ),
        .O(\FSM_sequential_rx_state[1]_i_3_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT4 #(
    .INIT(16'h0001)) 
    \FSM_sequential_rx_state[1]_i_4 
       (.I0(\rx_counter_reg_n_0_[1] ),
        .I1(\rx_counter_reg_n_0_[0] ),
        .I2(\rx_counter_reg_n_0_[2] ),
        .I3(\rx_counter_reg_n_0_[3] ),
        .O(\FSM_sequential_rx_state[1]_i_4_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \FSM_sequential_rx_state[1]_i_5 
       (.I0(\rx_counter_reg_n_0_[13] ),
        .I1(\rx_counter_reg_n_0_[12] ),
        .I2(\rx_counter_reg_n_0_[15] ),
        .I3(\rx_counter_reg_n_0_[14] ),
        .O(\FSM_sequential_rx_state[1]_i_5_n_0 ));
  LUT4 #(
    .INIT(16'hFFFE)) 
    \FSM_sequential_rx_state[1]_i_6 
       (.I0(\rx_counter_reg_n_0_[10] ),
        .I1(\rx_counter_reg_n_0_[11] ),
        .I2(\rx_counter_reg_n_0_[8] ),
        .I3(\rx_counter_reg_n_0_[9] ),
        .O(\FSM_sequential_rx_state[1]_i_6_n_0 ));
  (* FSM_ENCODED_STATES = "RX_IDLE:00,RX_START:01,RX_DATA:10,RX_STOP:11," *) 
  FDRE \FSM_sequential_rx_state_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\FSM_sequential_rx_state[0]_i_1_n_0 ),
        .Q(rx_state[0]),
        .R(1'b0));
  (* FSM_ENCODED_STATES = "RX_IDLE:00,RX_START:01,RX_DATA:10,RX_STOP:11," *) 
  FDRE \FSM_sequential_rx_state_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\FSM_sequential_rx_state[1]_i_1_n_0 ),
        .Q(rx_state[1]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFF00003AFF00FF0A)) 
    \FSM_sequential_tx_state[0]_i_1 
       (.I0(tx_data_valid_reg_n_0),
        .I1(\FSM_sequential_tx_state[0]_i_2_n_0 ),
        .I2(tx_state[1]),
        .I3(tx_state[0]),
        .I4(tx_state[2]),
        .I5(tx_out_reg_i_3_n_0),
        .O(\FSM_sequential_tx_state[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT3 #(
    .INIT(8'h7F)) 
    \FSM_sequential_tx_state[0]_i_2 
       (.I0(\tx_bit_idx_reg_n_0_[2] ),
        .I1(\tx_bit_idx_reg_n_0_[1] ),
        .I2(\tx_bit_idx_reg_n_0_[0] ),
        .O(\FSM_sequential_tx_state[0]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'hA6AA)) 
    \FSM_sequential_tx_state[1]_i_1 
       (.I0(tx_state[1]),
        .I1(tx_state[0]),
        .I2(tx_state[2]),
        .I3(tx_out_reg_i_3_n_0),
        .O(\FSM_sequential_tx_state[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair5" *) 
  LUT4 #(
    .INIT(16'hE8F0)) 
    \FSM_sequential_tx_state[2]_i_1 
       (.I0(tx_state[1]),
        .I1(tx_state[0]),
        .I2(tx_state[2]),
        .I3(tx_out_reg_i_3_n_0),
        .O(\FSM_sequential_tx_state[2]_i_1_n_0 ));
  (* FSM_ENCODED_STATES = "TX_IDLE:000,TX_START:001,TX_DATA:010,TX_STOP:011,TX_GUARD:100," *) 
  FDRE \FSM_sequential_tx_state_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\FSM_sequential_tx_state[0]_i_1_n_0 ),
        .Q(tx_state[0]),
        .R(rst));
  (* FSM_ENCODED_STATES = "TX_IDLE:000,TX_START:001,TX_DATA:010,TX_STOP:011,TX_GUARD:100," *) 
  FDRE \FSM_sequential_tx_state_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\FSM_sequential_tx_state[1]_i_1_n_0 ),
        .Q(tx_state[1]),
        .R(rst));
  (* FSM_ENCODED_STATES = "TX_IDLE:000,TX_START:001,TX_DATA:010,TX_STOP:011,TX_GUARD:100," *) 
  FDRE \FSM_sequential_tx_state_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\FSM_sequential_tx_state[2]_i_1_n_0 ),
        .Q(tx_state[2]),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'h04)) 
    axi_arready_i_1
       (.I0(axi_rvalid_reg_0),
        .I1(S_AXI_ARVALID),
        .I2(S_AXI_ARREADY),
        .O(axi_arready0));
  FDRE axi_arready_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(axi_arready0),
        .Q(S_AXI_ARREADY),
        .R(rst));
  LUT1 #(
    .INIT(2'h1)) 
    axi_awready_i_1
       (.I0(S_AXI_ARESETN),
        .O(rst));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h0040)) 
    axi_awready_i_2
       (.I0(S_AXI_AWREADY),
        .I1(S_AXI_AWVALID),
        .I2(S_AXI_WVALID),
        .I3(axi_bvalid_reg_0),
        .O(axi_awready0));
  FDRE axi_awready_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(axi_awready0),
        .Q(S_AXI_AWREADY),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT4 #(
    .INIT(16'h8F88)) 
    axi_bvalid_i_1
       (.I0(S_AXI_AWREADY),
        .I1(S_AXI_WREADY),
        .I2(S_AXI_BREADY),
        .I3(axi_bvalid_reg_0),
        .O(axi_bvalid_i_1_n_0));
  FDRE axi_bvalid_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(axi_bvalid_i_1_n_0),
        .Q(axi_bvalid_reg_0),
        .R(rst));
  LUT5 #(
    .INIT(32'h33003B08)) 
    \axi_rdata[0]_i_1 
       (.I0(irq_tx),
        .I1(S_AXI_ARADDR[2]),
        .I2(S_AXI_ARADDR[1]),
        .I3(\axi_rdata[0]_i_2_n_0 ),
        .I4(S_AXI_ARADDR[0]),
        .O(axi_rdata[0]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \axi_rdata[0]_i_2 
       (.I0(p_1_in[0]),
        .I1(rx_data_reg[0]),
        .I2(S_AXI_ARADDR[1]),
        .I3(tx_ready_reg),
        .I4(S_AXI_ARADDR[0]),
        .I5(tx_data_reg[0]),
        .O(\axi_rdata[0]_i_2_n_0 ));
  LUT5 #(
    .INIT(32'h33003B08)) 
    \axi_rdata[1]_i_1 
       (.I0(irq_rx),
        .I1(S_AXI_ARADDR[2]),
        .I2(S_AXI_ARADDR[1]),
        .I3(\axi_rdata[1]_i_2_n_0 ),
        .I4(S_AXI_ARADDR[0]),
        .O(axi_rdata[1]));
  LUT6 #(
    .INIT(64'hAFA0CFCFAFA0C0C0)) 
    \axi_rdata[1]_i_2 
       (.I0(p_1_in[1]),
        .I1(rx_data_reg[1]),
        .I2(S_AXI_ARADDR[1]),
        .I3(rx_data_valid),
        .I4(S_AXI_ARADDR[0]),
        .I5(tx_data_reg[1]),
        .O(\axi_rdata[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'h0000000033B800B8)) 
    \axi_rdata[2]_i_1 
       (.I0(rx_data_reg[2]),
        .I1(S_AXI_ARADDR[1]),
        .I2(tx_data_reg[2]),
        .I3(S_AXI_ARADDR[0]),
        .I4(tx_active_reg_reg_0),
        .I5(S_AXI_ARADDR[2]),
        .O(axi_rdata[2]));
  LUT6 #(
    .INIT(64'h0000000033B800B8)) 
    \axi_rdata[3]_i_1 
       (.I0(rx_data_reg[3]),
        .I1(S_AXI_ARADDR[1]),
        .I2(tx_data_reg[3]),
        .I3(S_AXI_ARADDR[0]),
        .I4(p_3_in),
        .I5(S_AXI_ARADDR[2]),
        .O(axi_rdata[3]));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT5 #(
    .INIT(32'h000000E2)) 
    \axi_rdata[4]_i_1 
       (.I0(tx_data_reg[4]),
        .I1(S_AXI_ARADDR[1]),
        .I2(rx_data_reg[4]),
        .I3(S_AXI_ARADDR[2]),
        .I4(S_AXI_ARADDR[0]),
        .O(axi_rdata[4]));
  LUT5 #(
    .INIT(32'h000000E2)) 
    \axi_rdata[5]_i_1 
       (.I0(tx_data_reg[5]),
        .I1(S_AXI_ARADDR[1]),
        .I2(rx_data_reg[5]),
        .I3(S_AXI_ARADDR[2]),
        .I4(S_AXI_ARADDR[0]),
        .O(axi_rdata[5]));
  LUT5 #(
    .INIT(32'h000000B8)) 
    \axi_rdata[6]_i_1 
       (.I0(rx_data_reg[6]),
        .I1(S_AXI_ARADDR[1]),
        .I2(tx_data_reg[6]),
        .I3(S_AXI_ARADDR[2]),
        .I4(S_AXI_ARADDR[0]),
        .O(axi_rdata[6]));
  LUT2 #(
    .INIT(4'h2)) 
    \axi_rdata[7]_i_1 
       (.I0(S_AXI_ARVALID),
        .I1(axi_rvalid_reg_0),
        .O(p_8_in));
  LUT5 #(
    .INIT(32'h000000E2)) 
    \axi_rdata[7]_i_2 
       (.I0(tx_data_reg[7]),
        .I1(S_AXI_ARADDR[1]),
        .I2(rx_data_reg[7]),
        .I3(S_AXI_ARADDR[2]),
        .I4(S_AXI_ARADDR[0]),
        .O(axi_rdata[7]));
  FDRE \axi_rdata_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(p_8_in),
        .D(axi_rdata[0]),
        .Q(S_AXI_RDATA[0]),
        .R(1'b0));
  FDRE \axi_rdata_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(p_8_in),
        .D(axi_rdata[1]),
        .Q(S_AXI_RDATA[1]),
        .R(1'b0));
  FDRE \axi_rdata_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(p_8_in),
        .D(axi_rdata[2]),
        .Q(S_AXI_RDATA[2]),
        .R(1'b0));
  FDRE \axi_rdata_reg[3] 
       (.C(S_AXI_ACLK),
        .CE(p_8_in),
        .D(axi_rdata[3]),
        .Q(S_AXI_RDATA[3]),
        .R(1'b0));
  FDRE \axi_rdata_reg[4] 
       (.C(S_AXI_ACLK),
        .CE(p_8_in),
        .D(axi_rdata[4]),
        .Q(S_AXI_RDATA[4]),
        .R(1'b0));
  FDRE \axi_rdata_reg[5] 
       (.C(S_AXI_ACLK),
        .CE(p_8_in),
        .D(axi_rdata[5]),
        .Q(S_AXI_RDATA[5]),
        .R(1'b0));
  FDRE \axi_rdata_reg[6] 
       (.C(S_AXI_ACLK),
        .CE(p_8_in),
        .D(axi_rdata[6]),
        .Q(S_AXI_RDATA[6]),
        .R(1'b0));
  FDRE \axi_rdata_reg[7] 
       (.C(S_AXI_ACLK),
        .CE(p_8_in),
        .D(axi_rdata[7]),
        .Q(S_AXI_RDATA[7]),
        .R(1'b0));
  (* SOFT_HLUTNM = "soft_lutpair11" *) 
  LUT3 #(
    .INIT(8'hBA)) 
    axi_rvalid_i_1
       (.I0(S_AXI_ARREADY),
        .I1(S_AXI_RREADY),
        .I2(axi_rvalid_reg_0),
        .O(axi_rvalid_i_1_n_0));
  FDRE axi_rvalid_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(axi_rvalid_i_1_n_0),
        .Q(axi_rvalid_reg_0),
        .R(rst));
  (* SOFT_HLUTNM = "soft_lutpair7" *) 
  LUT4 #(
    .INIT(16'h0040)) 
    axi_wready_i_1
       (.I0(S_AXI_WREADY),
        .I1(S_AXI_AWVALID),
        .I2(S_AXI_WVALID),
        .I3(axi_bvalid_reg_0),
        .O(axi_wready0));
  FDRE axi_wready_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(axi_wready0),
        .Q(S_AXI_WREADY),
        .R(rst));
  LUT6 #(
    .INIT(64'hFBFBFFBF00000040)) 
    \rx_bit_idx[0]_i_1 
       (.I0(tx_active_reg_reg_0),
        .I1(\FSM_sequential_rx_state[1]_i_2_n_0 ),
        .I2(rx_state[1]),
        .I3(\FSM_sequential_rx_state[0]_i_2_n_0 ),
        .I4(rx_state[0]),
        .I5(\rx_bit_idx_reg_n_0_[0] ),
        .O(\rx_bit_idx[0]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT4 #(
    .INIT(16'h4F80)) 
    \rx_bit_idx[1]_i_1 
       (.I0(\rx_bit_idx_reg_n_0_[0] ),
        .I1(rx_state[1]),
        .I2(\rx_bit_idx[1]_i_2_n_0 ),
        .I3(\rx_bit_idx_reg_n_0_[1] ),
        .O(\rx_bit_idx[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000000000000010)) 
    \rx_bit_idx[1]_i_2 
       (.I0(tx_active_reg_reg_0),
        .I1(\FSM_sequential_rx_state[1]_i_3_n_0 ),
        .I2(\FSM_sequential_rx_state[1]_i_4_n_0 ),
        .I3(\FSM_sequential_rx_state[1]_i_5_n_0 ),
        .I4(\FSM_sequential_rx_state[1]_i_6_n_0 ),
        .I5(\rx_bit_idx[1]_i_3_n_0 ),
        .O(\rx_bit_idx[1]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT5 #(
    .INIT(32'hEAAA5555)) 
    \rx_bit_idx[1]_i_3 
       (.I0(rx_state[0]),
        .I1(\rx_bit_idx_reg_n_0_[2] ),
        .I2(\rx_bit_idx_reg_n_0_[1] ),
        .I3(\rx_bit_idx_reg_n_0_[0] ),
        .I4(rx_state[1]),
        .O(\rx_bit_idx[1]_i_3_n_0 ));
  LUT6 #(
    .INIT(64'hFBFB0000FFFF4000)) 
    \rx_bit_idx[2]_i_1 
       (.I0(tx_active_reg_reg_0),
        .I1(\FSM_sequential_rx_state[1]_i_2_n_0 ),
        .I2(rx_state[1]),
        .I3(\rx_bit_idx[2]_i_2_n_0 ),
        .I4(\rx_bit_idx_reg_n_0_[2] ),
        .I5(rx_state[0]),
        .O(\rx_bit_idx[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair6" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \rx_bit_idx[2]_i_2 
       (.I0(\rx_bit_idx_reg_n_0_[1] ),
        .I1(\rx_bit_idx_reg_n_0_[0] ),
        .O(\rx_bit_idx[2]_i_2_n_0 ));
  FDRE \rx_bit_idx_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\rx_bit_idx[0]_i_1_n_0 ),
        .Q(\rx_bit_idx_reg_n_0_[0] ),
        .R(rst));
  FDRE \rx_bit_idx_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\rx_bit_idx[1]_i_1_n_0 ),
        .Q(\rx_bit_idx_reg_n_0_[1] ),
        .R(rst));
  FDRE \rx_bit_idx_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\rx_bit_idx[2]_i_1_n_0 ),
        .Q(\rx_bit_idx_reg_n_0_[2] ),
        .R(rst));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 rx_counter0_carry
       (.CI(1'b0),
        .CO({rx_counter0_carry_n_0,rx_counter0_carry_n_1,rx_counter0_carry_n_2,rx_counter0_carry_n_3}),
        .CYINIT(\rx_counter_reg_n_0_[0] ),
        .DI({\rx_counter_reg_n_0_[4] ,\rx_counter_reg_n_0_[3] ,\rx_counter_reg_n_0_[2] ,\rx_counter_reg_n_0_[1] }),
        .O({rx_counter0_carry_n_4,rx_counter0_carry_n_5,rx_counter0_carry_n_6,rx_counter0_carry_n_7}),
        .S({rx_counter0_carry_i_1__1_n_0,rx_counter0_carry_i_2__1_n_0,rx_counter0_carry_i_3__0_n_0,rx_counter0_carry_i_4__1_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 rx_counter0_carry__0
       (.CI(rx_counter0_carry_n_0),
        .CO({rx_counter0_carry__0_n_0,rx_counter0_carry__0_n_1,rx_counter0_carry__0_n_2,rx_counter0_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({\rx_counter_reg_n_0_[8] ,\rx_counter_reg_n_0_[7] ,\rx_counter_reg_n_0_[6] ,\rx_counter_reg_n_0_[5] }),
        .O({rx_counter0_carry__0_n_4,rx_counter0_carry__0_n_5,rx_counter0_carry__0_n_6,rx_counter0_carry__0_n_7}),
        .S({rx_counter0_carry_i_1__0_n_0,rx_counter0_carry_i_2__2_n_0,rx_counter0_carry_i_3_n_0,rx_counter0_carry_i_4__0_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 rx_counter0_carry__1
       (.CI(rx_counter0_carry__0_n_0),
        .CO({rx_counter0_carry__1_n_0,rx_counter0_carry__1_n_1,rx_counter0_carry__1_n_2,rx_counter0_carry__1_n_3}),
        .CYINIT(1'b0),
        .DI({\rx_counter_reg_n_0_[12] ,\rx_counter_reg_n_0_[11] ,\rx_counter_reg_n_0_[10] ,\rx_counter_reg_n_0_[9] }),
        .O({rx_counter0_carry__1_n_4,rx_counter0_carry__1_n_5,rx_counter0_carry__1_n_6,rx_counter0_carry__1_n_7}),
        .S({rx_counter0_carry_i_1_n_0,rx_counter0_carry_i_2__0_n_0,rx_counter0_carry_i_3__1_n_0,rx_counter0_carry_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 rx_counter0_carry__2
       (.CI(rx_counter0_carry__1_n_0),
        .CO({NLW_rx_counter0_carry__2_CO_UNCONNECTED[3:2],rx_counter0_carry__2_n_2,rx_counter0_carry__2_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,\rx_counter_reg_n_0_[14] ,\rx_counter_reg_n_0_[13] }),
        .O({NLW_rx_counter0_carry__2_O_UNCONNECTED[3],rx_counter0_carry__2_n_5,rx_counter0_carry__2_n_6,rx_counter0_carry__2_n_7}),
        .S({1'b0,rx_counter0_carry_i_1__2_n_0,rx_counter0_carry_i_2_n_0,rx_counter0_carry_i_3__2_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_1
       (.I0(\rx_counter_reg_n_0_[12] ),
        .O(rx_counter0_carry_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_1__0
       (.I0(\rx_counter_reg_n_0_[8] ),
        .O(rx_counter0_carry_i_1__0_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_1__1
       (.I0(\rx_counter_reg_n_0_[4] ),
        .O(rx_counter0_carry_i_1__1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_1__2
       (.I0(\rx_counter_reg_n_0_[15] ),
        .O(rx_counter0_carry_i_1__2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_2
       (.I0(\rx_counter_reg_n_0_[14] ),
        .O(rx_counter0_carry_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_2__0
       (.I0(\rx_counter_reg_n_0_[11] ),
        .O(rx_counter0_carry_i_2__0_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_2__1
       (.I0(\rx_counter_reg_n_0_[3] ),
        .O(rx_counter0_carry_i_2__1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_2__2
       (.I0(\rx_counter_reg_n_0_[7] ),
        .O(rx_counter0_carry_i_2__2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_3
       (.I0(\rx_counter_reg_n_0_[6] ),
        .O(rx_counter0_carry_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_3__0
       (.I0(\rx_counter_reg_n_0_[2] ),
        .O(rx_counter0_carry_i_3__0_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_3__1
       (.I0(\rx_counter_reg_n_0_[10] ),
        .O(rx_counter0_carry_i_3__1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_3__2
       (.I0(\rx_counter_reg_n_0_[13] ),
        .O(rx_counter0_carry_i_3__2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_4
       (.I0(\rx_counter_reg_n_0_[9] ),
        .O(rx_counter0_carry_i_4_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_4__0
       (.I0(\rx_counter_reg_n_0_[5] ),
        .O(rx_counter0_carry_i_4__0_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    rx_counter0_carry_i_4__1
       (.I0(\rx_counter_reg_n_0_[1] ),
        .O(rx_counter0_carry_i_4__1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair9" *) 
  LUT2 #(
    .INIT(4'hB)) 
    \rx_counter[0]_i_1 
       (.I0(\rx_counter[15]_i_4_n_0 ),
        .I1(\rx_counter_reg_n_0_[0] ),
        .O(rx_counter[0]));
  LUT4 #(
    .INIT(16'h1F11)) 
    \rx_counter[10]_i_1 
       (.I0(rx_state[1]),
        .I1(rx_state[0]),
        .I2(\rx_counter[11]_i_2_n_0 ),
        .I3(rx_counter0_carry__1_n_6),
        .O(rx_counter[10]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'hEEE0)) 
    \rx_counter[11]_i_1 
       (.I0(rx_state[1]),
        .I1(rx_state[0]),
        .I2(\rx_counter[11]_i_2_n_0 ),
        .I3(rx_counter0_carry__1_n_5),
        .O(\rx_counter[11]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'h0000001000100010)) 
    \rx_counter[11]_i_2 
       (.I0(\FSM_sequential_rx_state[1]_i_6_n_0 ),
        .I1(\FSM_sequential_rx_state[1]_i_5_n_0 ),
        .I2(\FSM_sequential_rx_state[1]_i_4_n_0 ),
        .I3(\FSM_sequential_rx_state[1]_i_3_n_0 ),
        .I4(rx_state[1]),
        .I5(rx_state[0]),
        .O(\rx_counter[11]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \rx_counter[12]_i_1 
       (.I0(rx_counter0_carry__1_n_4),
        .I1(\rx_counter[15]_i_4_n_0 ),
        .O(rx_counter[12]));
  (* SOFT_HLUTNM = "soft_lutpair19" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \rx_counter[13]_i_1 
       (.I0(rx_counter0_carry__2_n_7),
        .I1(\rx_counter[15]_i_4_n_0 ),
        .O(rx_counter[13]));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \rx_counter[14]_i_1 
       (.I0(rx_counter0_carry__2_n_6),
        .I1(\rx_counter[15]_i_4_n_0 ),
        .O(rx_counter[14]));
  LUT2 #(
    .INIT(4'hB)) 
    \rx_counter[15]_i_1 
       (.I0(tx_active_reg_reg_0),
        .I1(S_AXI_ARESETN),
        .O(\rx_counter[15]_i_1_n_0 ));
  LUT4 #(
    .INIT(16'h7C7F)) 
    \rx_counter[15]_i_2 
       (.I0(\FSM_sequential_rx_state[1]_i_2_n_0 ),
        .I1(rx_state[0]),
        .I2(rx_state[1]),
        .I3(p_0_in[7]),
        .O(rx_counter_1));
  (* SOFT_HLUTNM = "soft_lutpair20" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \rx_counter[15]_i_3 
       (.I0(rx_counter0_carry__2_n_5),
        .I1(\rx_counter[15]_i_4_n_0 ),
        .O(rx_counter[15]));
  LUT6 #(
    .INIT(64'h1111111111111711)) 
    \rx_counter[15]_i_4 
       (.I0(rx_state[0]),
        .I1(rx_state[1]),
        .I2(\FSM_sequential_rx_state[1]_i_3_n_0 ),
        .I3(\FSM_sequential_rx_state[1]_i_4_n_0 ),
        .I4(\FSM_sequential_rx_state[1]_i_5_n_0 ),
        .I5(\FSM_sequential_rx_state[1]_i_6_n_0 ),
        .O(\rx_counter[15]_i_4_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'hEEE0)) 
    \rx_counter[1]_i_1 
       (.I0(rx_state[1]),
        .I1(rx_state[0]),
        .I2(\rx_counter[11]_i_2_n_0 ),
        .I3(rx_counter0_carry_n_7),
        .O(\rx_counter[1]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h1F11)) 
    \rx_counter[2]_i_1 
       (.I0(rx_state[1]),
        .I1(rx_state[0]),
        .I2(\rx_counter[11]_i_2_n_0 ),
        .I3(rx_counter0_carry_n_6),
        .O(rx_counter[2]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \rx_counter[3]_i_1 
       (.I0(rx_counter0_carry_n_5),
        .I1(\rx_counter[15]_i_4_n_0 ),
        .O(rx_counter[3]));
  (* SOFT_HLUTNM = "soft_lutpair17" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \rx_counter[4]_i_1 
       (.I0(rx_counter0_carry_n_4),
        .I1(\rx_counter[15]_i_4_n_0 ),
        .O(rx_counter[4]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \rx_counter[5]_i_1 
       (.I0(rx_counter0_carry__0_n_7),
        .I1(\rx_counter[15]_i_4_n_0 ),
        .O(rx_counter[5]));
  (* SOFT_HLUTNM = "soft_lutpair18" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \rx_counter[6]_i_1 
       (.I0(rx_counter0_carry__0_n_6),
        .I1(\rx_counter[15]_i_4_n_0 ),
        .O(rx_counter[6]));
  (* SOFT_HLUTNM = "soft_lutpair3" *) 
  LUT4 #(
    .INIT(16'hEEE0)) 
    \rx_counter[7]_i_1 
       (.I0(rx_state[1]),
        .I1(rx_state[0]),
        .I2(\rx_counter[11]_i_2_n_0 ),
        .I3(rx_counter0_carry__0_n_5),
        .O(\rx_counter[7]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair8" *) 
  LUT4 #(
    .INIT(16'h1F11)) 
    \rx_counter[8]_i_1 
       (.I0(rx_state[1]),
        .I1(rx_state[0]),
        .I2(\rx_counter[11]_i_2_n_0 ),
        .I3(rx_counter0_carry__0_n_4),
        .O(rx_counter[8]));
  (* SOFT_HLUTNM = "soft_lutpair4" *) 
  LUT4 #(
    .INIT(16'hEEE0)) 
    \rx_counter[9]_i_1 
       (.I0(rx_state[1]),
        .I1(rx_state[0]),
        .I2(\rx_counter[11]_i_2_n_0 ),
        .I3(rx_counter0_carry__1_n_7),
        .O(\rx_counter[9]_i_1_n_0 ));
  FDRE \rx_counter_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[0]),
        .Q(\rx_counter_reg_n_0_[0] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[10] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[10]),
        .Q(\rx_counter_reg_n_0_[10] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[11] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(\rx_counter[11]_i_1_n_0 ),
        .Q(\rx_counter_reg_n_0_[11] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[12] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[12]),
        .Q(\rx_counter_reg_n_0_[12] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[13] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[13]),
        .Q(\rx_counter_reg_n_0_[13] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[14] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[14]),
        .Q(\rx_counter_reg_n_0_[14] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[15] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[15]),
        .Q(\rx_counter_reg_n_0_[15] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(\rx_counter[1]_i_1_n_0 ),
        .Q(\rx_counter_reg_n_0_[1] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[2]),
        .Q(\rx_counter_reg_n_0_[2] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[3] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[3]),
        .Q(\rx_counter_reg_n_0_[3] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[4] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[4]),
        .Q(\rx_counter_reg_n_0_[4] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[5] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[5]),
        .Q(\rx_counter_reg_n_0_[5] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[6] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[6]),
        .Q(\rx_counter_reg_n_0_[6] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[7] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(\rx_counter[7]_i_1_n_0 ),
        .Q(\rx_counter_reg_n_0_[7] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[8] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(rx_counter[8]),
        .Q(\rx_counter_reg_n_0_[8] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  FDRE \rx_counter_reg[9] 
       (.C(S_AXI_ACLK),
        .CE(rx_counter_1),
        .D(\rx_counter[9]_i_1_n_0 ),
        .Q(\rx_counter_reg_n_0_[9] ),
        .R(\rx_counter[15]_i_1_n_0 ));
  LUT5 #(
    .INIT(32'h40000000)) 
    \rx_data_reg[7]_i_1 
       (.I0(tx_active_reg_reg_0),
        .I1(S_AXI_ARESETN),
        .I2(rx_state[0]),
        .I3(rx_state[1]),
        .I4(\FSM_sequential_rx_state[1]_i_2_n_0 ),
        .O(\rx_data_reg[7]_i_1_n_0 ));
  FDRE \rx_data_reg_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(\rx_data_reg[7]_i_1_n_0 ),
        .D(\rx_shift_reg_n_0_[0] ),
        .Q(rx_data_reg[0]),
        .R(1'b0));
  FDRE \rx_data_reg_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(\rx_data_reg[7]_i_1_n_0 ),
        .D(p_0_in[0]),
        .Q(rx_data_reg[1]),
        .R(1'b0));
  FDRE \rx_data_reg_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(\rx_data_reg[7]_i_1_n_0 ),
        .D(p_0_in[1]),
        .Q(rx_data_reg[2]),
        .R(1'b0));
  FDRE \rx_data_reg_reg[3] 
       (.C(S_AXI_ACLK),
        .CE(\rx_data_reg[7]_i_1_n_0 ),
        .D(p_0_in[2]),
        .Q(rx_data_reg[3]),
        .R(1'b0));
  FDRE \rx_data_reg_reg[4] 
       (.C(S_AXI_ACLK),
        .CE(\rx_data_reg[7]_i_1_n_0 ),
        .D(p_0_in[3]),
        .Q(rx_data_reg[4]),
        .R(1'b0));
  FDRE \rx_data_reg_reg[5] 
       (.C(S_AXI_ACLK),
        .CE(\rx_data_reg[7]_i_1_n_0 ),
        .D(p_0_in[4]),
        .Q(rx_data_reg[5]),
        .R(1'b0));
  FDRE \rx_data_reg_reg[6] 
       (.C(S_AXI_ACLK),
        .CE(\rx_data_reg[7]_i_1_n_0 ),
        .D(p_0_in[5]),
        .Q(rx_data_reg[6]),
        .R(1'b0));
  FDRE \rx_data_reg_reg[7] 
       (.C(S_AXI_ACLK),
        .CE(\rx_data_reg[7]_i_1_n_0 ),
        .D(p_0_in[6]),
        .Q(rx_data_reg[7]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hE0E0E0E000E0E0E0)) 
    rx_data_valid_i_1
       (.I0(rx_data_valid),
        .I1(rx_done_reg_n_0),
        .I2(S_AXI_ARESETN),
        .I3(p_8_in),
        .I4(S_AXI_ARADDR[1]),
        .I5(rx_data_valid_i_2_n_0),
        .O(rx_data_valid_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT2 #(
    .INIT(4'hE)) 
    rx_data_valid_i_2
       (.I0(S_AXI_ARADDR[2]),
        .I1(S_AXI_ARADDR[0]),
        .O(rx_data_valid_i_2_n_0));
  FDRE rx_data_valid_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(rx_data_valid_i_1_n_0),
        .Q(rx_data_valid),
        .R(1'b0));
  FDRE rx_done_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\rx_data_reg[7]_i_1_n_0 ),
        .Q(rx_done_reg_n_0),
        .R(1'b0));
  FDRE rx_in_sync1_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(rx_in),
        .Q(rx_in_sync1),
        .R(1'b0));
  FDRE rx_in_sync2_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(rx_in_sync1),
        .Q(p_0_in[7]),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFEFFFFFF02000000)) 
    rx_int_en_i_1
       (.I0(S_AXI_WDATA[1]),
        .I1(tx_int_flag_i_2_n_0),
        .I2(S_AXI_AWADDR[2]),
        .I3(S_AXI_AWADDR[1]),
        .I4(S_AXI_AWADDR[0]),
        .I5(p_1_in[1]),
        .O(rx_int_en_i_1_n_0));
  FDRE rx_int_en_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(rx_int_en_i_1_n_0),
        .Q(p_1_in[1]),
        .R(rst));
  LUT5 #(
    .INIT(32'h0000C0EA)) 
    rx_int_flag_i_1
       (.I0(irq_rx),
        .I1(p_1_in[1]),
        .I2(rx_done_reg_n_0),
        .I3(rx_int_flag1_out),
        .I4(rx_int_flag_i_3_n_0),
        .O(rx_int_flag_i_1_n_0));
  LUT6 #(
    .INIT(64'h1000000000000000)) 
    rx_int_flag_i_2
       (.I0(S_AXI_AWADDR[0]),
        .I1(S_AXI_AWADDR[1]),
        .I2(S_AXI_AWADDR[2]),
        .I3(S_AXI_WDATA[1]),
        .I4(S_AXI_WREADY),
        .I5(S_AXI_AWREADY),
        .O(rx_int_flag1_out));
  LUT6 #(
    .INIT(64'h00001000FFFFFFFF)) 
    rx_int_flag_i_3
       (.I0(S_AXI_ARADDR[0]),
        .I1(S_AXI_ARADDR[2]),
        .I2(S_AXI_ARADDR[1]),
        .I3(S_AXI_ARVALID),
        .I4(axi_rvalid_reg_0),
        .I5(S_AXI_ARESETN),
        .O(rx_int_flag_i_3_n_0));
  FDRE rx_int_flag_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(rx_int_flag_i_1_n_0),
        .Q(irq_rx),
        .R(1'b0));
  LUT4 #(
    .INIT(16'h0040)) 
    \rx_shift[7]_i_1 
       (.I0(tx_active_reg_reg_0),
        .I1(\FSM_sequential_rx_state[1]_i_2_n_0 ),
        .I2(rx_state[1]),
        .I3(rx_state[0]),
        .O(\rx_shift[7]_i_1_n_0 ));
  FDRE \rx_shift_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(\rx_shift[7]_i_1_n_0 ),
        .D(p_0_in[0]),
        .Q(\rx_shift_reg_n_0_[0] ),
        .R(rst));
  FDRE \rx_shift_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(\rx_shift[7]_i_1_n_0 ),
        .D(p_0_in[1]),
        .Q(p_0_in[0]),
        .R(rst));
  FDRE \rx_shift_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(\rx_shift[7]_i_1_n_0 ),
        .D(p_0_in[2]),
        .Q(p_0_in[1]),
        .R(rst));
  FDRE \rx_shift_reg[3] 
       (.C(S_AXI_ACLK),
        .CE(\rx_shift[7]_i_1_n_0 ),
        .D(p_0_in[3]),
        .Q(p_0_in[2]),
        .R(rst));
  FDRE \rx_shift_reg[4] 
       (.C(S_AXI_ACLK),
        .CE(\rx_shift[7]_i_1_n_0 ),
        .D(p_0_in[4]),
        .Q(p_0_in[3]),
        .R(rst));
  FDRE \rx_shift_reg[5] 
       (.C(S_AXI_ACLK),
        .CE(\rx_shift[7]_i_1_n_0 ),
        .D(p_0_in[5]),
        .Q(p_0_in[4]),
        .R(rst));
  FDRE \rx_shift_reg[6] 
       (.C(S_AXI_ACLK),
        .CE(\rx_shift[7]_i_1_n_0 ),
        .D(p_0_in[6]),
        .Q(p_0_in[5]),
        .R(rst));
  FDRE \rx_shift_reg[7] 
       (.C(S_AXI_ACLK),
        .CE(\rx_shift[7]_i_1_n_0 ),
        .D(p_0_in[7]),
        .Q(p_0_in[6]),
        .R(rst));
  LUT6 #(
    .INIT(64'hFCFFFEFE00000202)) 
    tx_active_reg_i_1
       (.I0(tx_data_valid_reg_n_0),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_out_reg_i_3_n_0),
        .I4(tx_state[2]),
        .I5(tx_active_reg_reg_0),
        .O(tx_active_reg_i_1_n_0));
  FDRE tx_active_reg_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(tx_active_reg_i_1_n_0),
        .Q(tx_active_reg_reg_0),
        .R(rst));
  LUT6 #(
    .INIT(64'hFFD7FFF700200000)) 
    \tx_bit_idx[0]_i_1 
       (.I0(tx_out_reg_i_3_n_0),
        .I1(tx_state[0]),
        .I2(tx_state[1]),
        .I3(tx_state[2]),
        .I4(\FSM_sequential_tx_state[0]_i_2_n_0 ),
        .I5(\tx_bit_idx_reg_n_0_[0] ),
        .O(\tx_bit_idx[0]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFF10FF00004000)) 
    \tx_bit_idx[1]_i_1 
       (.I0(tx_state[2]),
        .I1(\tx_bit_idx_reg_n_0_[0] ),
        .I2(tx_state[1]),
        .I3(tx_out_reg_i_3_n_0),
        .I4(\tx_bit_idx[1]_i_2_n_0 ),
        .I5(\tx_bit_idx_reg_n_0_[1] ),
        .O(\tx_bit_idx[1]_i_1_n_0 ));
  LUT6 #(
    .INIT(64'hFFFFFF00FF80FFFF)) 
    \tx_bit_idx[1]_i_2 
       (.I0(\tx_bit_idx_reg_n_0_[2] ),
        .I1(\tx_bit_idx_reg_n_0_[1] ),
        .I2(\tx_bit_idx_reg_n_0_[0] ),
        .I3(tx_state[2]),
        .I4(tx_state[1]),
        .I5(tx_state[0]),
        .O(\tx_bit_idx[1]_i_2_n_0 ));
  LUT6 #(
    .INIT(64'hFFF7FFF700200000)) 
    \tx_bit_idx[2]_i_1 
       (.I0(tx_out_reg_i_3_n_0),
        .I1(tx_state[0]),
        .I2(tx_state[1]),
        .I3(tx_state[2]),
        .I4(\tx_bit_idx[2]_i_2_n_0 ),
        .I5(\tx_bit_idx_reg_n_0_[2] ),
        .O(\tx_bit_idx[2]_i_1_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair12" *) 
  LUT2 #(
    .INIT(4'h8)) 
    \tx_bit_idx[2]_i_2 
       (.I0(\tx_bit_idx_reg_n_0_[0] ),
        .I1(\tx_bit_idx_reg_n_0_[1] ),
        .O(\tx_bit_idx[2]_i_2_n_0 ));
  FDRE \tx_bit_idx_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\tx_bit_idx[0]_i_1_n_0 ),
        .Q(\tx_bit_idx_reg_n_0_[0] ),
        .R(rst));
  FDRE \tx_bit_idx_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\tx_bit_idx[1]_i_1_n_0 ),
        .Q(\tx_bit_idx_reg_n_0_[1] ),
        .R(rst));
  FDRE \tx_bit_idx_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(\tx_bit_idx[2]_i_1_n_0 ),
        .Q(\tx_bit_idx_reg_n_0_[2] ),
        .R(rst));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 tx_counter0_carry
       (.CI(1'b0),
        .CO({tx_counter0_carry_n_0,tx_counter0_carry_n_1,tx_counter0_carry_n_2,tx_counter0_carry_n_3}),
        .CYINIT(\tx_counter_reg_n_0_[0] ),
        .DI({\tx_counter_reg_n_0_[4] ,\tx_counter_reg_n_0_[3] ,\tx_counter_reg_n_0_[2] ,\tx_counter_reg_n_0_[1] }),
        .O({tx_counter0_carry_n_4,tx_counter0_carry_n_5,tx_counter0_carry_n_6,tx_counter0_carry_n_7}),
        .S({tx_counter0_carry_i_1_n_0,tx_counter0_carry_i_2_n_0,tx_counter0_carry_i_3_n_0,tx_counter0_carry_i_4_n_0}));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 tx_counter0_carry__0
       (.CI(tx_counter0_carry_n_0),
        .CO({tx_counter0_carry__0_n_0,tx_counter0_carry__0_n_1,tx_counter0_carry__0_n_2,tx_counter0_carry__0_n_3}),
        .CYINIT(1'b0),
        .DI({\tx_counter_reg_n_0_[8] ,\tx_counter_reg_n_0_[7] ,\tx_counter_reg_n_0_[6] ,\tx_counter_reg_n_0_[5] }),
        .O({tx_counter0_carry__0_n_4,tx_counter0_carry__0_n_5,tx_counter0_carry__0_n_6,tx_counter0_carry__0_n_7}),
        .S({tx_counter0_carry__0_i_1_n_0,tx_counter0_carry__0_i_2_n_0,tx_counter0_carry__0_i_3_n_0,tx_counter0_carry__0_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__0_i_1
       (.I0(\tx_counter_reg_n_0_[8] ),
        .O(tx_counter0_carry__0_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__0_i_2
       (.I0(\tx_counter_reg_n_0_[7] ),
        .O(tx_counter0_carry__0_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__0_i_3
       (.I0(\tx_counter_reg_n_0_[6] ),
        .O(tx_counter0_carry__0_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__0_i_4
       (.I0(\tx_counter_reg_n_0_[5] ),
        .O(tx_counter0_carry__0_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 tx_counter0_carry__1
       (.CI(tx_counter0_carry__0_n_0),
        .CO({tx_counter0_carry__1_n_0,tx_counter0_carry__1_n_1,tx_counter0_carry__1_n_2,tx_counter0_carry__1_n_3}),
        .CYINIT(1'b0),
        .DI({\tx_counter_reg_n_0_[12] ,\tx_counter_reg_n_0_[11] ,\tx_counter_reg_n_0_[10] ,\tx_counter_reg_n_0_[9] }),
        .O({tx_counter0_carry__1_n_4,tx_counter0_carry__1_n_5,tx_counter0_carry__1_n_6,tx_counter0_carry__1_n_7}),
        .S({tx_counter0_carry__1_i_1_n_0,tx_counter0_carry__1_i_2_n_0,tx_counter0_carry__1_i_3_n_0,tx_counter0_carry__1_i_4_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__1_i_1
       (.I0(\tx_counter_reg_n_0_[12] ),
        .O(tx_counter0_carry__1_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__1_i_2
       (.I0(\tx_counter_reg_n_0_[11] ),
        .O(tx_counter0_carry__1_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__1_i_3
       (.I0(\tx_counter_reg_n_0_[10] ),
        .O(tx_counter0_carry__1_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__1_i_4
       (.I0(\tx_counter_reg_n_0_[9] ),
        .O(tx_counter0_carry__1_i_4_n_0));
  (* ADDER_THRESHOLD = "35" *) 
  CARRY4 tx_counter0_carry__2
       (.CI(tx_counter0_carry__1_n_0),
        .CO({NLW_tx_counter0_carry__2_CO_UNCONNECTED[3:2],tx_counter0_carry__2_n_2,tx_counter0_carry__2_n_3}),
        .CYINIT(1'b0),
        .DI({1'b0,1'b0,\tx_counter_reg_n_0_[14] ,\tx_counter_reg_n_0_[13] }),
        .O({NLW_tx_counter0_carry__2_O_UNCONNECTED[3],tx_counter0_carry__2_n_5,tx_counter0_carry__2_n_6,tx_counter0_carry__2_n_7}),
        .S({1'b0,tx_counter0_carry__2_i_1_n_0,tx_counter0_carry__2_i_2_n_0,tx_counter0_carry__2_i_3_n_0}));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__2_i_1
       (.I0(\tx_counter_reg_n_0_[15] ),
        .O(tx_counter0_carry__2_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__2_i_2
       (.I0(\tx_counter_reg_n_0_[14] ),
        .O(tx_counter0_carry__2_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry__2_i_3
       (.I0(\tx_counter_reg_n_0_[13] ),
        .O(tx_counter0_carry__2_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry_i_1
       (.I0(\tx_counter_reg_n_0_[4] ),
        .O(tx_counter0_carry_i_1_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry_i_2
       (.I0(\tx_counter_reg_n_0_[3] ),
        .O(tx_counter0_carry_i_2_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry_i_3
       (.I0(\tx_counter_reg_n_0_[2] ),
        .O(tx_counter0_carry_i_3_n_0));
  LUT1 #(
    .INIT(2'h1)) 
    tx_counter0_carry_i_4
       (.I0(\tx_counter_reg_n_0_[1] ),
        .O(tx_counter0_carry_i_4_n_0));
  LUT5 #(
    .INIT(32'hAAAAABFF)) 
    \tx_counter[0]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(\tx_counter_reg_n_0_[0] ),
        .O(tx_counter[0]));
  LUT5 #(
    .INIT(32'h000A2220)) 
    \tx_counter[10]_i_1 
       (.I0(tx_counter0_carry__1_n_6),
        .I1(tx_out_reg_i_3_n_0),
        .I2(tx_state[0]),
        .I3(tx_state[1]),
        .I4(tx_state[2]),
        .O(tx_counter[10]));
  LUT5 #(
    .INIT(32'hABFFAAAA)) 
    \tx_counter[11]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_counter0_carry__1_n_5),
        .O(tx_counter[11]));
  LUT6 #(
    .INIT(64'h0000001055555555)) 
    \tx_counter[11]_i_2 
       (.I0(tx_state[2]),
        .I1(tx_out_reg_i_4_n_0),
        .I2(tx_out_reg_i_5_n_0),
        .I3(tx_out_reg_i_6_n_0),
        .I4(tx_out_reg_i_7_n_0),
        .I5(\tx_counter[11]_i_3_n_0 ),
        .O(\tx_counter[11]_i_2_n_0 ));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT2 #(
    .INIT(4'hE)) 
    \tx_counter[11]_i_3 
       (.I0(tx_state[0]),
        .I1(tx_state[1]),
        .O(\tx_counter[11]_i_3_n_0 ));
  LUT5 #(
    .INIT(32'h000A2220)) 
    \tx_counter[12]_i_1 
       (.I0(tx_counter0_carry__1_n_4),
        .I1(tx_out_reg_i_3_n_0),
        .I2(tx_state[0]),
        .I3(tx_state[1]),
        .I4(tx_state[2]),
        .O(tx_counter[12]));
  LUT5 #(
    .INIT(32'h000A2220)) 
    \tx_counter[13]_i_1 
       (.I0(tx_counter0_carry__2_n_7),
        .I1(tx_out_reg_i_3_n_0),
        .I2(tx_state[0]),
        .I3(tx_state[1]),
        .I4(tx_state[2]),
        .O(tx_counter[13]));
  LUT5 #(
    .INIT(32'h000A2220)) 
    \tx_counter[14]_i_1 
       (.I0(tx_counter0_carry__2_n_6),
        .I1(tx_out_reg_i_3_n_0),
        .I2(tx_state[0]),
        .I3(tx_state[1]),
        .I4(tx_state[2]),
        .O(tx_counter[14]));
  LUT5 #(
    .INIT(32'h00FE03FE)) 
    \tx_counter[15]_i_1 
       (.I0(tx_data_valid_reg_n_0),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_out_reg_i_3_n_0),
        .O(tx_counter_3));
  LUT5 #(
    .INIT(32'h000A2220)) 
    \tx_counter[15]_i_2 
       (.I0(tx_counter0_carry__2_n_5),
        .I1(tx_out_reg_i_3_n_0),
        .I2(tx_state[0]),
        .I3(tx_state[1]),
        .I4(tx_state[2]),
        .O(tx_counter[15]));
  LUT5 #(
    .INIT(32'hABFFAAAA)) 
    \tx_counter[1]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_counter0_carry_n_7),
        .O(tx_counter[1]));
  (* SOFT_HLUTNM = "soft_lutpair2" *) 
  LUT5 #(
    .INIT(32'h000A2220)) 
    \tx_counter[2]_i_1 
       (.I0(tx_counter0_carry_n_6),
        .I1(tx_out_reg_i_3_n_0),
        .I2(tx_state[0]),
        .I3(tx_state[1]),
        .I4(tx_state[2]),
        .O(tx_counter[2]));
  LUT5 #(
    .INIT(32'hABFFAAAA)) 
    \tx_counter[3]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_counter0_carry_n_5),
        .O(tx_counter[3]));
  LUT5 #(
    .INIT(32'hABFFAAAA)) 
    \tx_counter[4]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_counter0_carry_n_4),
        .O(tx_counter[4]));
  LUT5 #(
    .INIT(32'hABFFAAAA)) 
    \tx_counter[5]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_counter0_carry__0_n_7),
        .O(tx_counter[5]));
  LUT5 #(
    .INIT(32'hABFFAAAA)) 
    \tx_counter[6]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_counter0_carry__0_n_6),
        .O(tx_counter[6]));
  LUT5 #(
    .INIT(32'hABFFAAAA)) 
    \tx_counter[7]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_counter0_carry__0_n_5),
        .O(tx_counter[7]));
  LUT5 #(
    .INIT(32'h000A2220)) 
    \tx_counter[8]_i_1 
       (.I0(tx_counter0_carry__0_n_4),
        .I1(tx_out_reg_i_3_n_0),
        .I2(tx_state[0]),
        .I3(tx_state[1]),
        .I4(tx_state[2]),
        .O(tx_counter[8]));
  LUT5 #(
    .INIT(32'hABFFAAAA)) 
    \tx_counter[9]_i_1 
       (.I0(\tx_counter[11]_i_2_n_0 ),
        .I1(tx_state[1]),
        .I2(tx_state[0]),
        .I3(tx_state[2]),
        .I4(tx_counter0_carry__1_n_7),
        .O(tx_counter[9]));
  FDRE \tx_counter_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[0]),
        .Q(\tx_counter_reg_n_0_[0] ),
        .R(rst));
  FDRE \tx_counter_reg[10] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[10]),
        .Q(\tx_counter_reg_n_0_[10] ),
        .R(rst));
  FDRE \tx_counter_reg[11] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[11]),
        .Q(\tx_counter_reg_n_0_[11] ),
        .R(rst));
  FDRE \tx_counter_reg[12] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[12]),
        .Q(\tx_counter_reg_n_0_[12] ),
        .R(rst));
  FDRE \tx_counter_reg[13] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[13]),
        .Q(\tx_counter_reg_n_0_[13] ),
        .R(rst));
  FDRE \tx_counter_reg[14] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[14]),
        .Q(\tx_counter_reg_n_0_[14] ),
        .R(rst));
  FDRE \tx_counter_reg[15] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[15]),
        .Q(\tx_counter_reg_n_0_[15] ),
        .R(rst));
  FDRE \tx_counter_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[1]),
        .Q(\tx_counter_reg_n_0_[1] ),
        .R(rst));
  FDRE \tx_counter_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[2]),
        .Q(\tx_counter_reg_n_0_[2] ),
        .R(rst));
  FDRE \tx_counter_reg[3] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[3]),
        .Q(\tx_counter_reg_n_0_[3] ),
        .R(rst));
  FDRE \tx_counter_reg[4] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[4]),
        .Q(\tx_counter_reg_n_0_[4] ),
        .R(rst));
  FDRE \tx_counter_reg[5] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[5]),
        .Q(\tx_counter_reg_n_0_[5] ),
        .R(rst));
  FDRE \tx_counter_reg[6] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[6]),
        .Q(\tx_counter_reg_n_0_[6] ),
        .R(rst));
  FDRE \tx_counter_reg[7] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[7]),
        .Q(\tx_counter_reg_n_0_[7] ),
        .R(rst));
  FDRE \tx_counter_reg[8] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[8]),
        .Q(\tx_counter_reg_n_0_[8] ),
        .R(rst));
  FDRE \tx_counter_reg[9] 
       (.C(S_AXI_ACLK),
        .CE(tx_counter_3),
        .D(tx_counter[9]),
        .Q(\tx_counter_reg_n_0_[9] ),
        .R(rst));
  LUT5 #(
    .INIT(32'h00000008)) 
    \tx_data_reg[7]_i_1 
       (.I0(S_AXI_WREADY),
        .I1(S_AXI_AWREADY),
        .I2(S_AXI_AWADDR[2]),
        .I3(S_AXI_AWADDR[1]),
        .I4(S_AXI_AWADDR[0]),
        .O(tx_data_reg_0));
  FDRE \tx_data_reg_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(tx_data_reg_0),
        .D(S_AXI_WDATA[0]),
        .Q(tx_data_reg[0]),
        .R(rst));
  FDRE \tx_data_reg_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(tx_data_reg_0),
        .D(S_AXI_WDATA[1]),
        .Q(tx_data_reg[1]),
        .R(rst));
  FDRE \tx_data_reg_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(tx_data_reg_0),
        .D(S_AXI_WDATA[2]),
        .Q(tx_data_reg[2]),
        .R(rst));
  FDRE \tx_data_reg_reg[3] 
       (.C(S_AXI_ACLK),
        .CE(tx_data_reg_0),
        .D(S_AXI_WDATA[3]),
        .Q(tx_data_reg[3]),
        .R(rst));
  FDRE \tx_data_reg_reg[4] 
       (.C(S_AXI_ACLK),
        .CE(tx_data_reg_0),
        .D(S_AXI_WDATA[4]),
        .Q(tx_data_reg[4]),
        .R(rst));
  FDRE \tx_data_reg_reg[5] 
       (.C(S_AXI_ACLK),
        .CE(tx_data_reg_0),
        .D(S_AXI_WDATA[5]),
        .Q(tx_data_reg[5]),
        .R(rst));
  FDRE \tx_data_reg_reg[6] 
       (.C(S_AXI_ACLK),
        .CE(tx_data_reg_0),
        .D(S_AXI_WDATA[6]),
        .Q(tx_data_reg[6]),
        .R(rst));
  FDRE \tx_data_reg_reg[7] 
       (.C(S_AXI_ACLK),
        .CE(tx_data_reg_0),
        .D(S_AXI_WDATA[7]),
        .Q(tx_data_reg[7]),
        .R(rst));
  LUT6 #(
    .INIT(64'h0100000000000000)) 
    tx_data_valid_i_1
       (.I0(S_AXI_AWADDR[0]),
        .I1(S_AXI_AWADDR[1]),
        .I2(S_AXI_AWADDR[2]),
        .I3(S_AXI_AWREADY),
        .I4(S_AXI_WREADY),
        .I5(S_AXI_ARESETN),
        .O(tx_data_valid_i_1_n_0));
  FDRE tx_data_valid_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(tx_data_valid_i_1_n_0),
        .Q(tx_data_valid_reg_n_0),
        .R(1'b0));
  LUT6 #(
    .INIT(64'hFFFFFFF50000C000)) 
    tx_done_i_1
       (.I0(tx_data_valid_reg_n_0),
        .I1(tx_out_reg_i_3_n_0),
        .I2(tx_state[0]),
        .I3(tx_state[1]),
        .I4(tx_state[2]),
        .I5(p_3_in),
        .O(tx_done_i_1_n_0));
  FDRE tx_done_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(tx_done_i_1_n_0),
        .Q(p_3_in),
        .R(rst));
  LUT6 #(
    .INIT(64'hFEFFFFFF02000000)) 
    tx_int_en_i_1
       (.I0(S_AXI_WDATA[0]),
        .I1(tx_int_flag_i_2_n_0),
        .I2(S_AXI_AWADDR[2]),
        .I3(S_AXI_AWADDR[1]),
        .I4(S_AXI_AWADDR[0]),
        .I5(p_1_in[0]),
        .O(tx_int_en_i_1_n_0));
  FDRE tx_int_en_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(tx_int_en_i_1_n_0),
        .Q(p_1_in[0]),
        .R(rst));
  LUT6 #(
    .INIT(64'hFFBFBFBFFF000000)) 
    tx_int_flag_i_1
       (.I0(tx_int_flag_i_2_n_0),
        .I1(S_AXI_WDATA[0]),
        .I2(tx_int_flag_i_3_n_0),
        .I3(p_3_in),
        .I4(p_1_in[0]),
        .I5(irq_tx),
        .O(tx_int_flag_i_1_n_0));
  (* SOFT_HLUTNM = "soft_lutpair10" *) 
  LUT2 #(
    .INIT(4'h7)) 
    tx_int_flag_i_2
       (.I0(S_AXI_WREADY),
        .I1(S_AXI_AWREADY),
        .O(tx_int_flag_i_2_n_0));
  LUT3 #(
    .INIT(8'h02)) 
    tx_int_flag_i_3
       (.I0(S_AXI_AWADDR[2]),
        .I1(S_AXI_AWADDR[1]),
        .I2(S_AXI_AWADDR[0]),
        .O(tx_int_flag_i_3_n_0));
  FDRE tx_int_flag_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(tx_int_flag_i_1_n_0),
        .Q(irq_tx),
        .R(rst));
  LUT6 #(
    .INIT(64'hFFEFEFEE00202022)) 
    tx_out_reg_i_1
       (.I0(tx_out_reg_i_2_n_0),
        .I1(tx_state[2]),
        .I2(tx_out_reg_i_3_n_0),
        .I3(tx_state[0]),
        .I4(tx_state[1]),
        .I5(tx_out),
        .O(tx_out_reg_i_1_n_0));
  LUT6 #(
    .INIT(64'hBFB0B0B0BFB0BFBF)) 
    tx_out_reg_i_2
       (.I0(\tx_shift_reg_n_0_[1] ),
        .I1(\FSM_sequential_tx_state[0]_i_2_n_0 ),
        .I2(tx_state[1]),
        .I3(\tx_shift_reg_n_0_[0] ),
        .I4(tx_state[0]),
        .I5(tx_data_valid_reg_n_0),
        .O(tx_out_reg_i_2_n_0));
  LUT4 #(
    .INIT(16'h0004)) 
    tx_out_reg_i_3
       (.I0(tx_out_reg_i_4_n_0),
        .I1(tx_out_reg_i_5_n_0),
        .I2(tx_out_reg_i_6_n_0),
        .I3(tx_out_reg_i_7_n_0),
        .O(tx_out_reg_i_3_n_0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    tx_out_reg_i_4
       (.I0(\tx_counter_reg_n_0_[3] ),
        .I1(\tx_counter_reg_n_0_[8] ),
        .I2(\tx_counter_reg_n_0_[7] ),
        .I3(\tx_counter_reg_n_0_[0] ),
        .O(tx_out_reg_i_4_n_0));
  LUT4 #(
    .INIT(16'h0001)) 
    tx_out_reg_i_5
       (.I0(\tx_counter_reg_n_0_[12] ),
        .I1(\tx_counter_reg_n_0_[14] ),
        .I2(\tx_counter_reg_n_0_[13] ),
        .I3(\tx_counter_reg_n_0_[5] ),
        .O(tx_out_reg_i_5_n_0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    tx_out_reg_i_6
       (.I0(\tx_counter_reg_n_0_[1] ),
        .I1(\tx_counter_reg_n_0_[2] ),
        .I2(\tx_counter_reg_n_0_[10] ),
        .I3(\tx_counter_reg_n_0_[11] ),
        .O(tx_out_reg_i_6_n_0));
  LUT4 #(
    .INIT(16'hFFFE)) 
    tx_out_reg_i_7
       (.I0(\tx_counter_reg_n_0_[15] ),
        .I1(\tx_counter_reg_n_0_[9] ),
        .I2(\tx_counter_reg_n_0_[4] ),
        .I3(\tx_counter_reg_n_0_[6] ),
        .O(tx_out_reg_i_7_n_0));
  FDSE tx_out_reg_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(tx_out_reg_i_1_n_0),
        .Q(tx_out),
        .S(rst));
  LUT5 #(
    .INIT(32'hFFFD0001)) 
    tx_ready_reg_i_1
       (.I0(tx_data_valid_reg_n_0),
        .I1(tx_state[0]),
        .I2(tx_state[1]),
        .I3(tx_state[2]),
        .I4(tx_ready_reg),
        .O(tx_ready_reg_i_1_n_0));
  FDSE tx_ready_reg_reg
       (.C(S_AXI_ACLK),
        .CE(1'b1),
        .D(tx_ready_reg_i_1_n_0),
        .Q(tx_ready_reg),
        .S(rst));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hE2)) 
    \tx_shift[0]_i_1 
       (.I0(tx_data_reg[0]),
        .I1(tx_state[1]),
        .I2(\tx_shift_reg_n_0_[1] ),
        .O(tx_shift[0]));
  (* SOFT_HLUTNM = "soft_lutpair16" *) 
  LUT3 #(
    .INIT(8'hE2)) 
    \tx_shift[1]_i_1 
       (.I0(tx_data_reg[1]),
        .I1(tx_state[1]),
        .I2(\tx_shift_reg_n_0_[2] ),
        .O(tx_shift[1]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hE2)) 
    \tx_shift[2]_i_1 
       (.I0(tx_data_reg[2]),
        .I1(tx_state[1]),
        .I2(\tx_shift_reg_n_0_[3] ),
        .O(tx_shift[2]));
  (* SOFT_HLUTNM = "soft_lutpair15" *) 
  LUT3 #(
    .INIT(8'hE2)) 
    \tx_shift[3]_i_1 
       (.I0(tx_data_reg[3]),
        .I1(tx_state[1]),
        .I2(\tx_shift_reg_n_0_[4] ),
        .O(tx_shift[3]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hE2)) 
    \tx_shift[4]_i_1 
       (.I0(tx_data_reg[4]),
        .I1(tx_state[1]),
        .I2(\tx_shift_reg_n_0_[5] ),
        .O(tx_shift[4]));
  (* SOFT_HLUTNM = "soft_lutpair14" *) 
  LUT3 #(
    .INIT(8'hE2)) 
    \tx_shift[5]_i_1 
       (.I0(tx_data_reg[5]),
        .I1(tx_state[1]),
        .I2(\tx_shift_reg_n_0_[6] ),
        .O(tx_shift[5]));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT3 #(
    .INIT(8'hE2)) 
    \tx_shift[6]_i_1 
       (.I0(tx_data_reg[6]),
        .I1(tx_state[1]),
        .I2(\tx_shift_reg_n_0_[7] ),
        .O(tx_shift[6]));
  LUT5 #(
    .INIT(32'h00320002)) 
    \tx_shift[7]_i_1 
       (.I0(tx_data_valid_reg_n_0),
        .I1(tx_state[0]),
        .I2(tx_state[1]),
        .I3(tx_state[2]),
        .I4(tx_out_reg_i_3_n_0),
        .O(tx_shift_2));
  (* SOFT_HLUTNM = "soft_lutpair13" *) 
  LUT2 #(
    .INIT(4'h2)) 
    \tx_shift[7]_i_2 
       (.I0(tx_data_reg[7]),
        .I1(tx_state[1]),
        .O(tx_shift[7]));
  FDRE \tx_shift_reg[0] 
       (.C(S_AXI_ACLK),
        .CE(tx_shift_2),
        .D(tx_shift[0]),
        .Q(\tx_shift_reg_n_0_[0] ),
        .R(rst));
  FDRE \tx_shift_reg[1] 
       (.C(S_AXI_ACLK),
        .CE(tx_shift_2),
        .D(tx_shift[1]),
        .Q(\tx_shift_reg_n_0_[1] ),
        .R(rst));
  FDRE \tx_shift_reg[2] 
       (.C(S_AXI_ACLK),
        .CE(tx_shift_2),
        .D(tx_shift[2]),
        .Q(\tx_shift_reg_n_0_[2] ),
        .R(rst));
  FDRE \tx_shift_reg[3] 
       (.C(S_AXI_ACLK),
        .CE(tx_shift_2),
        .D(tx_shift[3]),
        .Q(\tx_shift_reg_n_0_[3] ),
        .R(rst));
  FDRE \tx_shift_reg[4] 
       (.C(S_AXI_ACLK),
        .CE(tx_shift_2),
        .D(tx_shift[4]),
        .Q(\tx_shift_reg_n_0_[4] ),
        .R(rst));
  FDRE \tx_shift_reg[5] 
       (.C(S_AXI_ACLK),
        .CE(tx_shift_2),
        .D(tx_shift[5]),
        .Q(\tx_shift_reg_n_0_[5] ),
        .R(rst));
  FDRE \tx_shift_reg[6] 
       (.C(S_AXI_ACLK),
        .CE(tx_shift_2),
        .D(tx_shift[6]),
        .Q(\tx_shift_reg_n_0_[6] ),
        .R(rst));
  FDRE \tx_shift_reg[7] 
       (.C(S_AXI_ACLK),
        .CE(tx_shift_2),
        .D(tx_shift[7]),
        .Q(\tx_shift_reg_n_0_[7] ),
        .R(rst));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
