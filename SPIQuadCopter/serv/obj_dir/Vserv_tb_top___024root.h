// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vserv_tb_top.h for the primary calling header

#ifndef VERILATED_VSERV_TB_TOP___024ROOT_H_
#define VERILATED_VSERV_TB_TOP___024ROOT_H_  // guard

#include "verilated.h"


class Vserv_tb_top__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vserv_tb_top___024root final {
  public:

    // DESIGN SPECIFIC STATE
    // Anonymous structures to workaround compiler member-count bugs
    struct {
        VL_IN8(i_clk,0,0);
        VL_IN8(i_rst,0,0);
        VL_OUT8(o_pc_valid,0,0);
        CData/*0:0*/ serv_tb_top__DOT__wb_mem_ack;
        CData/*0:0*/ serv_tb_top__DOT__gpio_ack;
        CData/*0:0*/ serv_tb_top__DOT__uart_dbg_tx;
        CData/*1:0*/ serv_tb_top__DOT__u_serv__DOT__rf_rdata_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt;
        CData/*4:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1;
        CData/*1:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r;
        CData/*2:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen0_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen1_r;
        CData/*1:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata1;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgate;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rreq_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done;
        CData/*2:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__ibus_cyc;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init;
        CData/*3:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT____VdfgRegularize_h5a1b02a1_0_1;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_two_stage_op;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_csr_imm_en;
        CData/*3:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl;
        CData/*3:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en;
        CData/*4:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode;
        CData/*2:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm25;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm30;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_12;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm31;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm7;
        CData/*5:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25;
        CData/*4:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20;
        CData/*4:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__q;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q;
    };
    struct {
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load;
        CData/*7:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__shift_en;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__cnt_en;
        CData/*7:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_sub;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy_r;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_b;
        CData/*3:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit;
        CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid;
        CData/*3:0*/ serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx;
        CData/*0:0*/ serv_tb_top__DOT__u_uart_dbg__DOT__busy;
        CData/*0:0*/ serv_tb_top__DOT__u_uart_dbg__DOT__ack;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_0;
        CData/*0:0*/ __VdfgRegularize_h6e95ff9d_0_3;
        CData/*0:0*/ __VstlFirstIteration;
        CData/*0:0*/ __VicoFirstIteration;
        CData/*0:0*/ __Vtrigprevexpr___TOP__i_clk__0;
        SData/*8:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20;
        SData/*15:0*/ serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt;
        SData/*9:0*/ serv_tb_top__DOT__u_uart_dbg__DOT__shifter;
        VL_OUT(o_pc,31,0);
        VL_OUT(o_gpio,31,0);
        IData/*31:0*/ serv_tb_top__DOT__wb_mem_rdt;
        IData/*31:0*/ serv_tb_top__DOT__gpio_reg;
        IData/*31:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr;
        IData/*31:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr;
        IData/*31:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data;
        IData/*31:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat;
        IData/*31:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_dat;
        IData/*23:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo;
        IData/*31:0*/ serv_tb_top__DOT__u_uart_dbg__DOT__o_wb_dat;
        IData/*31:0*/ __VactIterCount;
        VlUnpacked<CData/*1:0*/, 512> serv_tb_top__DOT__u_serv__DOT__rf_ram;
        VlUnpacked<IData/*31:0*/, 8192> serv_tb_top__DOT__u_ram__DOT__mem;
        VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VicoTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
        VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
        VlUnpacked<CData/*0:0*/, 3> __Vm_traceActivity;
    };

    // INTERNAL VARIABLES
    Vserv_tb_top__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vserv_tb_top___024root(Vserv_tb_top__Syms* symsp, const char* namep);
    ~Vserv_tb_top___024root();
    VL_UNCOPYABLE(Vserv_tb_top___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
