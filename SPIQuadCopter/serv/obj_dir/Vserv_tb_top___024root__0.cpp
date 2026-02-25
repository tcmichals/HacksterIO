// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vserv_tb_top.h for the primary calling header

#include "Vserv_tb_top__pch.h"

#ifdef VL_DEBUG
VL_ATTR_COLD void Vserv_tb_top___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vserv_tb_top___024root___eval_triggers__ico(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_triggers__ico\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VicoTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VicoTriggered
                                      [0U]) | (IData)((IData)(vlSelfRef.__VicoFirstIteration)));
    vlSelfRef.__VicoFirstIteration = 0U;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vserv_tb_top___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
    }
#endif
}

bool Vserv_tb_top___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___trigger_anySet__ico\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vserv_tb_top___024root___ico_sequent__TOP__0(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___ico_sequent__TOP__0\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc 
        = ((~ (IData)(vlSelfRef.i_rst)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__ibus_cyc));
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en 
            = vlSelfRef.serv_tb_top__DOT__wb_mem_ack;
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
            = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr;
    } else {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en = 0U;
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
            = (0xfffffffcU & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data);
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we 
        = (1U & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc)) 
                 & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                    >> 3U)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb 
        = (((0U == (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                    >> 0x0000001eU)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc)) 
           | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__gpio_ack) 
           | ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc)) 
              & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack)));
    vlSelfRef.o_pc = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr;
    vlSelfRef.o_pc_valid = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb) 
                            & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we)) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq 
        = (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op) 
            & ((4U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))
                ? (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt) 
                    >> 5U) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init) 
                              | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT____VdfgRegularize_h5a1b02a1_0_1)))
                : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init))) 
           | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load) 
              | ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                   >> 4U) | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en) 
                             & (2U == (6U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))))) 
                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init))));
}

void Vserv_tb_top___024root___eval_ico(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_ico\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VicoTriggered[0U])) {
        Vserv_tb_top___024root___ico_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[1U] = 1U;
    }
}

bool Vserv_tb_top___024root___eval_phase__ico(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_phase__ico\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VicoExecute;
    // Body
    Vserv_tb_top___024root___eval_triggers__ico(vlSelf);
    __VicoExecute = Vserv_tb_top___024root___trigger_anySet__ico(vlSelfRef.__VicoTriggered);
    if (__VicoExecute) {
        Vserv_tb_top___024root___eval_ico(vlSelf);
    }
    return (__VicoExecute);
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vserv_tb_top___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vserv_tb_top___024root___eval_triggers__act(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_triggers__act\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    ((IData)(vlSelfRef.i_clk) 
                                                     & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__i_clk__0)))));
    vlSelfRef.__Vtrigprevexpr___TOP__i_clk__0 = vlSelfRef.i_clk;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vserv_tb_top___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
}

bool Vserv_tb_top___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vserv_tb_top___024root___nba_sequent__TOP__0(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___nba_sequent__TOP__0\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11;
    serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11 = 0;
    CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_13;
    serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_13 = 0;
    CData/*0:0*/ __Vdly__serv_tb_top__DOT__gpio_ack;
    __Vdly__serv_tb_top__DOT__gpio_ack = 0;
    CData/*2:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r = 0;
    CData/*4:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt = 0;
    CData/*1:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0 = 0;
    CData/*2:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt = 0;
    CData/*3:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb = 0;
    SData/*8:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20 = 0;
    CData/*5:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25 = 0;
    CData/*4:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20 = 0;
    CData/*4:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7 = 0;
    IData/*31:0*/ __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data = 0;
    CData/*0:0*/ __Vdly__serv_tb_top__DOT__wb_mem_ack;
    __Vdly__serv_tb_top__DOT__wb_mem_ack = 0;
    CData/*0:0*/ __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__busy;
    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__busy = 0;
    SData/*15:0*/ __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt;
    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt = 0;
    CData/*3:0*/ __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx;
    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx = 0;
    SData/*9:0*/ __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__shifter;
    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__shifter = 0;
    CData/*1:0*/ __VdlyVal__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0;
    __VdlyVal__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0 = 0;
    SData/*8:0*/ __VdlyDim0__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0;
    __VdlyDim0__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0 = 0;
    CData/*0:0*/ __VdlySet__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0;
    __VdlySet__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0 = 0;
    CData/*7:0*/ __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v0;
    __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v0 = 0;
    SData/*12:0*/ __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v0;
    __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v0 = 0;
    CData/*0:0*/ __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v0;
    __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v0 = 0;
    CData/*7:0*/ __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v1;
    __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v1 = 0;
    SData/*12:0*/ __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v1;
    __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v1 = 0;
    CData/*0:0*/ __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v1;
    __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v1 = 0;
    CData/*7:0*/ __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v2;
    __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v2 = 0;
    SData/*12:0*/ __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v2;
    __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v2 = 0;
    CData/*0:0*/ __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v2;
    __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v2 = 0;
    CData/*7:0*/ __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v3;
    __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v3 = 0;
    SData/*12:0*/ __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v3;
    __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v3 = 0;
    CData/*0:0*/ __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v3;
    __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v3 = 0;
    // Body
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt;
    __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v0 = 0U;
    __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v1 = 0U;
    __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v2 = 0U;
    __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v3 = 0U;
    __Vdly__serv_tb_top__DOT__wb_mem_ack = vlSelfRef.serv_tb_top__DOT__wb_mem_ack;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0;
    __VdlySet__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0 = 0U;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7;
    if ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb) 
          & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
             >> 3U)) & (~ (IData)(vlSelfRef.serv_tb_top__DOT__gpio_ack)))) {
        if (VL_UNLIKELY(((1U == vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat)))) {
            VL_WRITEF_NX("[%0t] TEST PASSED!\n",0,64,
                         VL_TIME_UNITED_Q(1),-12);
            VL_FINISH_MT("sim/serv_tb_top.v", 137, "");
        } else if (VL_UNLIKELY(((0xdeadbeefU == vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat)))) {
            VL_WRITEF_NX("[%0t] TEST FAILED!\n",0,64,
                         VL_TIME_UNITED_Q(1),-12);
            VL_FINISH_MT("sim/serv_tb_top.v", 140, "");
        }
    }
    __Vdly__serv_tb_top__DOT__gpio_ack = vlSelfRef.serv_tb_top__DOT__gpio_ack;
    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__busy 
        = vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__busy;
    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt 
        = vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt;
    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx 
        = vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx;
    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__shifter 
        = vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__shifter;
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r 
        = (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r) 
                 >> 1U));
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0 
        = (1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0) 
                 >> 1U));
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__shift_en) 
         | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load))) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo 
            = (0x00ffffffU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load)
                               ? vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_dat
                               : ((0x00800000U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
                                                  << 0x00000017U)) 
                                  | (0x007fffffU & 
                                     (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo 
                                      >> 1U)))));
    }
    if ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1) 
          & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen0_r)) 
         | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
            & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen1_r)))) {
        __VdlyVal__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0 
            = (3U & ((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                      ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r)
                      : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r)));
        __VdlyDim0__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0 
            = ((((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                  ? 0U : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7)) 
                << 4U) | (0x0000000fU & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                          - (IData)(4U)) 
                                         >> 1U)));
        __VdlySet__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0 = 1U;
    }
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt 
        = (7U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                 + (1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                          >> 3U))));
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb 
        = ((0x0000000eU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                           << 1U)) | (1U & ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                                              >> 3U) 
                                             & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done))) 
                                            | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq) 
                                               | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt)))));
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en) {
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
            = ((3U & __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data) 
               | ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)
                     ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__q)
                     : ((vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                         >> 0x1fU) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm30))) 
                   << 0x0000001fU) | (0x7ffffffcU & 
                                      (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                       >> 1U))));
    }
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)
          ? ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0) 
             | ((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                   >> 1U))) : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en))) {
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
            = ((0xfffffffcU & __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data) 
               | ((2U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)
                           ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__q)
                           : (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                              >> 2U)) << 1U)) | (1U 
                                                 & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                                    >> 1U))));
    }
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) 
         | ((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en) 
               >> 1U)))) {
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20 
            = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en)
                ? ((0x000001feU & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                                   >> 0x0000000bU)) 
                   | (1U & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                            >> 0x00000014U))) : ((0x00000100U 
                                                  & (((8U 
                                                       & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl))
                                                       ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit)
                                                       : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20)) 
                                                     << 8U)) 
                                                 | (0x000000ffU 
                                                    & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                                       >> 1U))));
    }
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) 
         | ((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en) 
               >> 3U)))) {
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25 
            = (0x0000003fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en)
                               ? (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                                  >> 0x00000019U) : 
                              ((0x00000020U & (((4U 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl))
                                                 ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm7)
                                                 : 
                                                ((2U 
                                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl))
                                                  ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit)
                                                  : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20))) 
                                               << 5U)) 
                               | (0x0000001fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25) 
                                                 >> 1U)))));
    }
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) 
         | ((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en) 
               >> 2U)))) {
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20 
            = (0x0000001fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en)
                               ? (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                                  >> 0x00000014U) : 
                              ((0x00000010U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25) 
                                               << 4U)) 
                               | (0x0000000fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20) 
                                                 >> 1U)))));
    }
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) 
         | ((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
            & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en)))) {
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7 
            = (0x0000001fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en)
                               ? (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                                  >> 7U) : ((0x00000010U 
                                             & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25) 
                                                << 4U)) 
                                            | (0x0000000fU 
                                               & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7) 
                                                  >> 1U)))));
    }
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en) 
         | (IData)(vlSelfRef.i_rst))) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr 
            = ((IData)(vlSelfRef.i_rst) ? 0U : ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump)
                                                   ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc)
                                                   : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4)) 
                                                 << 0x0000001fU) 
                                                | (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr 
                                                   >> 1U)));
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r 
        = ((((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype) 
               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc)) 
              | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4) 
                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr))) 
             | ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf) 
                  | (((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                      & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add)) 
                     | ((IData)((((2U == (6U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))) 
                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r)) 
                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0))) 
                        | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                            >> 2U) & (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                       & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                          ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))) 
                                      | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                          >> 1U) & 
                                         ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                          & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)))))))) 
                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en)) 
                | (IData)(((0U == (5U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                           & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid)
                               ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q)
                               : ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                      >> 2U)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit))))))) 
            << 1U) | (1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r) 
                            >> 1U)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r = 0U;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en));
    if (((0x0000001fU == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt)) 
         | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en))) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgate 
            = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en;
    }
    __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt 
        = (0x0000001fU & ((IData)(1U) + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt)));
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) 
         | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq))) {
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt 
            = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq) 
               << 1U);
    }
    if ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) 
          | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done)) 
         | (IData)(vlSelfRef.i_rst))) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__ibus_cyc 
            = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en) 
               | (IData)(vlSelfRef.i_rst));
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy_r = 0U;
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata1 
            = (1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_rdata_r) 
                     >> 1U));
    }
    if ((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))) {
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0 
            = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_rdata_r;
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy_r 
        = ((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb))
            ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy)
            : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_sub));
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done 
            = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init) 
               & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done)));
    }
    if (vlSelfRef.i_rst) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done = 0U;
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt = 0U;
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb = 0U;
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgate = 0U;
        __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt = 0U;
    }
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm25 
            = (1U & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                     >> 0x00000019U));
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21 
            = (1U & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                     >> 0x00000015U));
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22 
            = (1U & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                     >> 0x00000016U));
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26 
            = (1U & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                     >> 0x0000001aU));
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20 
            = (1U & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                     >> 0x00000014U));
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm31 
            = (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
               >> 0x0000001fU);
    }
    if (vlSelfRef.i_rst) {
        vlSelfRef.serv_tb_top__DOT__gpio_reg = 0U;
        __Vdly__serv_tb_top__DOT__gpio_ack = 0U;
    } else {
        __Vdly__serv_tb_top__DOT__gpio_ack = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb) 
                                              & (~ (IData)(vlSelfRef.serv_tb_top__DOT__gpio_ack)));
        if (VL_UNLIKELY(((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb) 
                           & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                              >> 3U)) & (~ (IData)(vlSelfRef.serv_tb_top__DOT__gpio_ack)))))) {
            VL_WRITEF_NX("[%0t] GPIO write: 0x%08x\n",0,
                         64,VL_TIME_UNITED_Q(1),-12,
                         32,vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat);
            vlSelfRef.serv_tb_top__DOT__gpio_reg = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat;
        }
    }
    if ((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb))) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r 
            = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp;
    }
    if ((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen1_r = 0U;
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen0_r 
            = ((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
               & (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op)) 
                  & (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7))));
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0;
    vlSelfRef.serv_tb_top__DOT__gpio_ack = __Vdly__serv_tb_top__DOT__gpio_ack;
    if (vlSelfRef.i_rst) {
        __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__busy = 0U;
        __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt = 0U;
        __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx = 0U;
        __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__shifter = 0x03ffU;
        vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__ack = 0U;
        vlSelfRef.serv_tb_top__DOT__uart_dbg_tx = 1U;
        vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__o_wb_dat = 0U;
    } else {
        vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__ack = 0U;
        if ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb) 
              & (~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                    >> 3U))) & (0x40000114U == (0xfffffffcU 
                                                & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)))) {
            vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__o_wb_dat 
                = (1U & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__busy)));
            vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__ack = 1U;
        }
        if (((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb) 
               & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                  >> 3U)) & (0x40000110U == (0xfffffffcU 
                                             & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data))) 
             & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__busy)))) {
            __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__shifter 
                = (0x00000200U | (0x000001feU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat 
                                                 << 1U)));
            __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__busy = 1U;
            __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt = 0U;
            __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx = 0U;
            vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__ack = 1U;
        }
        if (vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__busy) {
            if ((0x0055U == (IData)(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt))) {
                __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx 
                    = (0x0000000fU & ((IData)(1U) + (IData)(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx)));
                __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt = 0U;
                vlSelfRef.serv_tb_top__DOT__uart_dbg_tx 
                    = (1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__shifter));
                if ((9U == (IData)(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx))) {
                    __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__busy = 0U;
                }
                __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__shifter 
                    = (0x00000200U | (0x000001ffU & 
                                      ((IData)(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__shifter) 
                                       >> 1U)));
            } else {
                __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt 
                    = (0x0000ffffU & ((IData)(1U) + (IData)(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt)));
            }
        } else {
            vlSelfRef.serv_tb_top__DOT__uart_dbg_tx = 1U;
        }
    }
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm30 
            = (1U & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                     >> 0x0000001eU));
    }
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump 
            = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init) 
               & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                   >> 4U) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                             | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp) 
                                ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)))));
    }
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3 
            = (7U & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                     >> 0x0000000cU));
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode 
            = (0x0000001fU & (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                              >> 2U));
    }
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__busy 
        = __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__busy;
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt 
        = __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt;
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx 
        = __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx;
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__shifter 
        = __Vdly__serv_tb_top__DOT__u_uart_dbg__DOT__shifter;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data;
    if ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__shift_en) 
          | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__cnt_en)) 
         | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load))) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi 
            = (0x000000ffU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load)
                               ? (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_dat 
                                  >> 0x18U) : ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt) 
                                               & (0x000000dfU 
                                                  | (0x00000020U 
                                                     & ((~ 
                                                         (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op) 
                                                           & ((1U 
                                                               == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                                                              & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                                                                 >> 3U))) 
                                                          & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__cnt_en)))) 
                                                        << 5U))))));
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rreq_r;
    if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en) 
         | (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)))) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm7 
            = (1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en)
                      ? (vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                         >> 7U) : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit)));
    }
    if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit 
            = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q;
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc 
        = ((~ (IData)(vlSelfRef.i_rst)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__ibus_cyc));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1 
        = (1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_rdata_r 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_ram
        [((0x000001f0U & (((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                            ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20)
                            : ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                               >> 4U)) << 4U)) | (0x0000000fU 
                                                  & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                                     >> 1U)))];
    vlSelfRef.o_gpio = vlSelfRef.serv_tb_top__DOT__gpio_reg;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20;
    if (__VdlySet__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_ram[__VdlyDim0__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0] 
            = __VdlyVal__serv_tb_top__DOT__u_serv__DOT__rf_ram__v0;
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20 
        = __Vdly__serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q 
        = (((3U == (3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
            & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi)) 
           | (((2U == (3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
               & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo 
                  >> 0x00000010U)) | (((1U == (3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
                                       & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo 
                                          >> 8U)) | 
                                      ((0U == (3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
                                       & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rreq_r 
        = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en;
    if (vlSelfRef.i_rst) {
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt = 0U;
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump = 0U;
        vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rreq_r = 0U;
        __Vdly__serv_tb_top__DOT__wb_mem_ack = 0U;
    } else if (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb) 
                & (~ (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack)))) {
        __Vdly__serv_tb_top__DOT__wb_mem_ack = 1U;
        vlSelfRef.serv_tb_top__DOT__wb_mem_rdt = vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem
            [(0x00001fffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
                             >> 2U))];
        if (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we) {
            if ((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel))) {
                __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v0 
                    = (0x000000ffU & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat);
                __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v0 
                    = (0x00001fffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
                                      >> 2U));
                __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v0 = 1U;
            }
            if ((2U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel))) {
                __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v1 
                    = (0x000000ffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat 
                                      >> 8U));
                __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v1 
                    = (0x00001fffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
                                      >> 2U));
                __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v1 = 1U;
            }
            if ((4U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel))) {
                __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v2 
                    = (0x000000ffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat 
                                      >> 0x10U));
                __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v2 
                    = (0x00001fffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
                                      >> 2U));
                __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v2 = 1U;
            }
            if ((8U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel))) {
                __VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v3 
                    = (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat 
                       >> 0x18U);
                __VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v3 
                    = (0x00001fffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
                                      >> 2U));
                __VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v3 = 1U;
            }
        }
    } else {
        __Vdly__serv_tb_top__DOT__wb_mem_ack = 0U;
    }
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2 
        = ((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
           & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
              >> 2U));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT____VdfgRegularize_h5a1b02a1_0_1 
        = ((~ (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb))) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0 
        = ((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done 
        = ((7U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
           & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
              >> 3U));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy 
        = (1U & (((1U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr) 
                  + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2) 
                     + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r))) 
                 >> 1U));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4 
        = (1U & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr 
                 + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2) 
                    + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid 
        = (1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                  >> 1U) | ((0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                          >> 1U))) 
                            | ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                   >> 2U)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig 
        = (1U & (~ (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                     >> 1U) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                               | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                  >> 2U)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl 
        = ((((2U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                    >> 3U)) | (IData)((0x10U == (0x11U 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))) 
            << 2U) | ((((0U == (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                        | (0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                        >> 1U)))) << 1U) 
                      | (8U == (0x0000000fU & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en 
        = (IData)((4U == (0x15U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr 
        = (IData)((0x11U == (0x11U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0 = (1U 
                                                & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0) 
                                                   & ((~ 
                                                       ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                                        >> 4U)) 
                                                      | (IData)(
                                                                (1U 
                                                                 == 
                                                                 (3U 
                                                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT____VdfgRegularize_h5a1b02a1_0_1) 
           & (0U == (0x14U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11 
        = (IData)((5U == (5U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_sub 
        = (1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                  >> 1U) | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                            | ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                 >> 3U) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm30)) 
                               | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                  >> 4U)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op 
        = (1U & ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                     >> 1U)) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                >> 2U)));
    serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_13 
        = (IData)((0U == (0x11U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4 
        = (IData)((0x14U == (0x14U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel 
        = ((((2U & (((3U == (3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
                     | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                         >> 1U) | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                   & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                      >> 1U)))) << 1U)) 
             | (1U & ((2U == (3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
                      | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                         >> 1U)))) << 2U) | ((2U & 
                                              (((1U 
                                                 == 
                                                 (3U 
                                                  & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
                                                | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                                    >> 1U) 
                                                   | ((~ 
                                                       (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                                        >> 1U)) 
                                                      & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)))) 
                                               << 1U)) 
                                             | (0U 
                                                == 
                                                (3U 
                                                 & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat 
        = (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
            << 0x00000018U) | vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo);
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc)
            ? vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr
            : (0xfffffffcU & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we 
        = (1U & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc)) 
                 & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                    >> 3U)));
    if (__VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v0) {
        vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem[__VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v0] 
            = ((0xffffff00U & vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem
                [__VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v0]) 
               | (IData)(__VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v0));
    }
    if (__VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v1) {
        vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem[__VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v1] 
            = ((0xffff00ffU & vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem
                [__VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v1]) 
               | ((IData)(__VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v1) 
                  << 8U));
    }
    if (__VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v2) {
        vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem[__VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v2] 
            = ((0xff00ffffU & vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem
                [__VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v2]) 
               | ((IData)(__VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v2) 
                  << 0x00000010U));
    }
    if (__VdlySet__serv_tb_top__DOT__u_ram__DOT__mem__v3) {
        vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem[__VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v3] 
            = ((0x00ffffffU & vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem
                [__VdlyDim0__serv_tb_top__DOT__u_ram__DOT__mem__v3]) 
               | ((IData)(__VdlyVal__serv_tb_top__DOT__u_ram__DOT__mem__v3) 
                  << 0x00000018U));
    }
    vlSelfRef.serv_tb_top__DOT__wb_mem_ack = __Vdly__serv_tb_top__DOT__wb_mem_ack;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op 
        = (1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                  >> 2U) | ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                >> 2U)) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr) 
                                           | (IData)(
                                                     (0U 
                                                      == 
                                                      (9U 
                                                       & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc) 
           & (0U != (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                     >> 0x0000001eU)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb 
        = (((0U == (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                    >> 0x0000001eU)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc)) 
           | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype 
        = ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
               >> 4U)) & (IData)(serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_two_stage_op 
        = (1U & ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                     >> 2U)) | ((IData)(((1U == (3U 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))) 
                                         & (IData)(serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_13))) 
                                | (IData)(((2U == (6U 
                                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))) 
                                           & (IData)(serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_13))))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
           & (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a 
        = (((0U == (7U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
            | ((3U == (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
               | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20)) 
                  | (0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                  >> 3U)))))) & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr);
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_csr_imm_en 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
           & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
              >> 2U));
    vlSelfRef.o_pc = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_dat 
        = ((0U != (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                   >> 0x0000001eU)) ? vlSelfRef.serv_tb_top__DOT__gpio_reg
            : vlSelfRef.serv_tb_top__DOT__wb_mem_rdt);
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__gpio_ack) 
           | ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc)) 
              & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack)));
    vlSelfRef.o_pc_valid = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb) 
                            & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we)) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init 
        = ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done)) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_two_stage_op));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_12 
        = ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26)) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en 
        = ((((IData)((1U != (0x1dU & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))) 
             << 3U) | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
                        | (8U != (9U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))) 
                       << 2U)) | ((((1U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                                  >> 1U))) 
                                    | ((IData)(serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11) 
                                       | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_csr_imm_en))) 
                                   << 1U) | (1U & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit 
        = ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_csr_imm_en)) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm31));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm 
        = (1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done)
                  ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit)
                  : ((8U == (0x0000000fU & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))
                      ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7)
                      : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en 
        = ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
           & (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__shift_en 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op)
            ? (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init) 
                & (0U == (6U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)))) 
               & (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)))
            : ((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
               & ((IData)((0U == (3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data))) 
                  | ((IData)((0U == (6U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)))) 
                     | (((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                             >> 2U)) & (~ (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                           >> 1U))) 
                        | (((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                >> 2U)) & (~ vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
                           | ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                  >> 1U)) & (~ (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                                >> 1U)))))))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__cnt_en 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op) 
           & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
              | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done) 
                 & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                    >> 2U))));
    vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3 = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm) 
                                                & ((~ 
                                                    ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                                     >> 2U)) 
                                                   & (~ 
                                                      ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                                         >> 4U) 
                                                        & ((0U 
                                                            == 
                                                            (3U 
                                                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                                                           | (3U 
                                                              == 
                                                              (3U 
                                                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))) 
                                                       & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b 
        = (1U & ((8U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))
                  ? ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1)
                      ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_rdata_r)
                      : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata1))
                  : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c 
        = (1U & (((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0) 
                  + ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                     + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r))) 
                 >> 1U));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__q 
        = (1U & ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0) 
                 + ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                    + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_b 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
           ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_sub));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__cnt_en)
            ? (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                << 7U) | ((0x00000040U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
                                          >> 1U)) | 
                          (0x0000003fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
                                          - (IData)(1U)))))
            : (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                << 7U) | (0x0000007fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
                                         >> 1U))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy 
        = (1U & (((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)) 
                  + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_b) 
                     + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy_r))) 
                 >> 1U));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add 
        = (1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0) 
                 + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_b) 
                    + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy_r))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq 
        = (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op) 
            & ((4U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))
                ? (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt) 
                    >> 5U) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init) 
                              | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT____VdfgRegularize_h5a1b02a1_0_1)))
                : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init))) 
           | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load) 
              | ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                   >> 4U) | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en) 
                             & (2U == (6U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))))) 
                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en 
        = (((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init) 
               | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                   >> 4U) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_two_stage_op)))) 
           | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op) 
              & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done) 
                 & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt) 
                     >> 5U) | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                               >> 2U)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp 
        = (1U & ((0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                               >> 1U))) ? ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add)) 
                                           & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r) 
                                              | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0)))
                  : (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                      & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)) 
                     + ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                            & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b))) 
                        + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf 
        = (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype)
            ? ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                 >> 2U) | (3U == (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)))) 
               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm))
            : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy 
        = (1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a) 
                  + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b) 
                     + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r))) 
                 >> 1U));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc 
        = (1U & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0)) 
                 & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a) 
                    + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b) 
                       + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r)))));
}

void Vserv_tb_top___024root___eval_nba(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_nba\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vserv_tb_top___024root___nba_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
    }
}

void Vserv_tb_top___024root___trigger_orInto__act(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___trigger_orInto__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vserv_tb_top___024root___eval_phase__act(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_phase__act\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vserv_tb_top___024root___eval_triggers__act(vlSelf);
    Vserv_tb_top___024root___trigger_orInto__act(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    return (0U);
}

void Vserv_tb_top___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vserv_tb_top___024root___eval_phase__nba(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_phase__nba\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vserv_tb_top___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vserv_tb_top___024root___eval_nba(vlSelf);
        Vserv_tb_top___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vserv_tb_top___024root___eval(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VicoIterCount;
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VicoIterCount = 0U;
    vlSelfRef.__VicoFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VicoIterCount)))) {
#ifdef VL_DEBUG
            Vserv_tb_top___024root___dump_triggers__ico(vlSelfRef.__VicoTriggered, "ico"s);
#endif
            VL_FATAL_MT("sim/serv_tb_top.v", 5, "", "Input combinational region did not converge after 100 tries");
        }
        __VicoIterCount = ((IData)(1U) + __VicoIterCount);
    } while (Vserv_tb_top___024root___eval_phase__ico(vlSelf));
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vserv_tb_top___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("sim/serv_tb_top.v", 5, "", "NBA region did not converge after 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vserv_tb_top___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("sim/serv_tb_top.v", 5, "", "Active region did not converge after 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
        } while (Vserv_tb_top___024root___eval_phase__act(vlSelf));
    } while (Vserv_tb_top___024root___eval_phase__nba(vlSelf));
}

#ifdef VL_DEBUG
void Vserv_tb_top___024root___eval_debug_assertions(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_debug_assertions\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if (VL_UNLIKELY(((vlSelfRef.i_clk & 0xfeU)))) {
        Verilated::overWidthError("i_clk");
    }
    if (VL_UNLIKELY(((vlSelfRef.i_rst & 0xfeU)))) {
        Verilated::overWidthError("i_rst");
    }
}
#endif  // VL_DEBUG
