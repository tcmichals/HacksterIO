// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vserv_tb_top.h for the primary calling header

#include "Vserv_tb_top__pch.h"

VL_ATTR_COLD void Vserv_tb_top___024root___eval_static__TOP(Vserv_tb_top___024root* vlSelf);
VL_ATTR_COLD void Vserv_tb_top___024root____Vm_traceActivitySetAll(Vserv_tb_top___024root* vlSelf);

VL_ATTR_COLD void Vserv_tb_top___024root___eval_static(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_static\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vserv_tb_top___024root___eval_static__TOP(vlSelf);
    Vserv_tb_top___024root____Vm_traceActivitySetAll(vlSelf);
    vlSelfRef.__Vtrigprevexpr___TOP__i_clk__0 = vlSelfRef.i_clk;
}

VL_ATTR_COLD void Vserv_tb_top___024root___eval_static__TOP(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_static__TOP\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt = 0U;
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx = 0U;
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__shifter = 0x03ffU;
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__busy = 0U;
    vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__ack = 0U;
}

VL_ATTR_COLD void Vserv_tb_top___024root___eval_initial__TOP(Vserv_tb_top___024root* vlSelf);

VL_ATTR_COLD void Vserv_tb_top___024root___eval_initial(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_initial\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vserv_tb_top___024root___eval_initial__TOP(vlSelf);
}

VL_ATTR_COLD void Vserv_tb_top___024root___eval_initial__TOP(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_initial__TOP\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    VL_READMEM_N(true, 32, 8192, 0, "firmware/firmware.hex"s
                 ,  &(vlSelfRef.serv_tb_top__DOT__u_ram__DOT__mem)
                 , 0, ~0ULL);
}

VL_ATTR_COLD void Vserv_tb_top___024root___eval_final(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_final\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vserv_tb_top___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vserv_tb_top___024root___eval_phase__stl(Vserv_tb_top___024root* vlSelf);

VL_ATTR_COLD void Vserv_tb_top___024root___eval_settle(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_settle\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vserv_tb_top___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("sim/serv_tb_top.v", 5, "", "Settle region did not converge after 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
    } while (Vserv_tb_top___024root___eval_phase__stl(vlSelf));
}

VL_ATTR_COLD void Vserv_tb_top___024root___eval_triggers__stl(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_triggers__stl\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered
                                      [0U]) | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    vlSelfRef.__VstlFirstIteration = 0U;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vserv_tb_top___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
}

VL_ATTR_COLD bool Vserv_tb_top___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vserv_tb_top___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vserv_tb_top___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vserv_tb_top___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vserv_tb_top___024root___stl_sequent__TOP__0(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___stl_sequent__TOP__0\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11;
    serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11 = 0;
    CData/*0:0*/ serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_13;
    serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_13 = 0;
    // Body
    vlSelfRef.o_gpio = vlSelfRef.serv_tb_top__DOT__gpio_reg;
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl 
        = ((((2U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                    >> 3U)) | (IData)((0x10U == (0x11U 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))) 
            << 2U) | ((((0U == (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                        | (0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                        >> 1U)))) << 1U) 
                      | (8U == (0x0000000fU & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat 
        = (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
            << 0x00000018U) | vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo);
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
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid 
        = (1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                  >> 1U) | ((0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                          >> 1U))) 
                            | ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                   >> 2U)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)))));
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
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_dat 
        = ((0U != (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                   >> 0x0000001eU)) ? vlSelfRef.serv_tb_top__DOT__gpio_reg
            : vlSelfRef.serv_tb_top__DOT__wb_mem_rdt);
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en 
        = (IData)((4U == (0x15U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig 
        = (1U & (~ (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                     >> 1U) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                               | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                  >> 2U)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2 
        = ((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
           & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
              >> 2U));
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
    serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11 
        = (IData)((5U == (5U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT____VdfgRegularize_h5a1b02a1_0_1 
        = ((~ (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb))) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0 
        = ((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
           & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_sub 
        = (1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                  >> 1U) | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                            | ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                 >> 3U) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm30)) 
                               | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                  >> 4U)))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc 
        = ((~ (IData)(vlSelfRef.i_rst)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__ibus_cyc));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op 
        = (1U & ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                     >> 1U)) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                >> 2U)));
    serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_13 
        = (IData)((0U == (0x11U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4 
        = (IData)((0x14U == (0x14U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
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
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op 
        = (1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                  >> 2U) | ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                >> 2U)) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr) 
                                           | (IData)(
                                                     (0U 
                                                      == 
                                                      (9U 
                                                       & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))))));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype 
        = ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
               >> 4U)) & (IData)(serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_11));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT____VdfgRegularize_h5a1b02a1_0_1) 
           & (0U == (0x14U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))));
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
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__gpio_ack) 
           | ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc)) 
              & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack)));
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
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb 
        = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc) 
           & (0U != (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                     >> 0x0000001eU)));
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb 
        = (((0U == (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                    >> 0x0000001eU)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc)) 
           | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc));
    vlSelfRef.o_pc = vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr;
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
    vlSelfRef.o_pc_valid = ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb) 
                            & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we)) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack)));
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
    vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm 
        = (1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done)
                  ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit)
                  : ((8U == (0x0000000fU & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))
                      ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7)
                      : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20))));
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

VL_ATTR_COLD void Vserv_tb_top___024root___eval_stl(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_stl\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        Vserv_tb_top___024root___stl_sequent__TOP__0(vlSelf);
        Vserv_tb_top___024root____Vm_traceActivitySetAll(vlSelf);
    }
}

VL_ATTR_COLD bool Vserv_tb_top___024root___eval_phase__stl(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___eval_phase__stl\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vserv_tb_top___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = Vserv_tb_top___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vserv_tb_top___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vserv_tb_top___024root___trigger_anySet__ico(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vserv_tb_top___024root___dump_triggers__ico(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___dump_triggers__ico\n"); );
    // Body
    if ((1U & (~ (IData)(Vserv_tb_top___024root___trigger_anySet__ico(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'ico' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

bool Vserv_tb_top___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vserv_tb_top___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vserv_tb_top___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge i_clk)\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vserv_tb_top___024root____Vm_traceActivitySetAll(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root____Vm_traceActivitySetAll\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vm_traceActivity[0U] = 1U;
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
}

VL_ATTR_COLD void Vserv_tb_top___024root___ctor_var_reset(Vserv_tb_top___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root___ctor_var_reset\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->i_clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15925868812496733354ull);
    vlSelf->i_rst = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9693334148897220726ull);
    vlSelf->o_pc = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11158079901618717280ull);
    vlSelf->o_pc_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1940651075908895263ull);
    vlSelf->o_gpio = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6051398484066467195ull);
    vlSelf->serv_tb_top__DOT__wb_mem_rdt = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 11875080244725638879ull);
    vlSelf->serv_tb_top__DOT__wb_mem_ack = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5092646958298628778ull);
    vlSelf->serv_tb_top__DOT__gpio_reg = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16209981076586326570ull);
    vlSelf->serv_tb_top__DOT__gpio_ack = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1573034441129794608ull);
    vlSelf->serv_tb_top__DOT__uart_dbg_tx = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11817207002241593343ull);
    for (int __Vi0 = 0; __Vi0 < 512; ++__Vi0) {
        vlSelf->serv_tb_top__DOT__u_serv__DOT__rf_ram[__Vi0] = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 7838680776626707916ull);
    }
    vlSelf->serv_tb_top__DOT__u_serv__DOT__rf_rdata_r = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 15477625787283189779ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 7138084023649927992ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13092716072481869145ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8074157445941421839ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9852565470580975307ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16539555199787424456ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 698834068913022420ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 12157158197723297251ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1034449974216673615ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 9927708197988546777ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 7454325970586192391ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen0_r = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2317274636049221940ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen1_r = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17839259579430233851ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0 = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 2289142590465058322ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata1 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15225289791139934441ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgate = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14821992795696368062ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rreq_r = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14939789142248551915ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1795213716433365610ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1985359838878448243ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14550935179520961621ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3821104511094065574ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13803423570614694322ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 12893838218935999227ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__ibus_cyc = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17440582370398394364ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14276146998045191613ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 16029058219993112360ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT____VdfgRegularize_h5a1b02a1_0_1 = 0;
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11446707071023488655ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8318833757360374864ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_two_stage_op = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2792906823997692236ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_csr_imm_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 977385842449520094ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 18335688710322477700ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 12567124410679972397ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9924990049082694473ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12356108308423055460ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 10330898252217253380ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3 = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 910060613722843966ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10295778936052863451ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11117511127713322866ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2187546855404940044ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16752735698043520806ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm25 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1523438934404979047ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm30 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15888615134978810993ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4 = 0;
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_12 = 0;
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm31 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15415289551711259138ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20 = VL_SCOPED_RAND_RESET_I(9, __VscopeHash, 5905203875749716915ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm7 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13067623227996674216ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25 = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 17648044870610687464ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20 = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 9131437898653263065ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7 = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 12515448459728410256ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12373454451477201490ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9054778685568990654ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6173049883627995595ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1803737972880308327ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13925166061114468218ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6694929557630333286ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1346658568724947924ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14066140861816709452ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7981741903467756315ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 15804955469445960418ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13899479277646857476ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 4533248132484847185ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17589812686093456944ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_dat = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 4116566284583300425ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 14987110946328196395ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo = VL_SCOPED_RAND_RESET_I(24, __VscopeHash, 15136443716852043560ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__shift_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7909011586440629370ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__cnt_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16615630570191070119ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 16478929126547580193ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4162535563602976090ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10915301807797389052ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 117163605150373285ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1778445485078754611ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14113734738111180496ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14208573990300881124ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10732268240879152361ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6909964783287455677ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12313547434309643517ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4807911098898211701ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15939279978510255271ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18362811523618251879ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2754364114651302817ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13691457512415034811ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_sub = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1034678684236990024ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2793585551257067165ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6375953847759657814ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3977681233447853256ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11128484304763078587ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3166615189145234837ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7418323926395768053ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy_r = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5522638596935069194ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_b = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16813656264165637854ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 10973454424925332083ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 516713319670411210ull);
    vlSelf->serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5884131091158042374ull);
    for (int __Vi0 = 0; __Vi0 < 8192; ++__Vi0) {
        vlSelf->serv_tb_top__DOT__u_ram__DOT__mem[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9093002247189520538ull);
    }
    vlSelf->serv_tb_top__DOT__u_uart_dbg__DOT__o_wb_dat = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 1010972043324164514ull);
    vlSelf->serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 2270878541363888290ull);
    vlSelf->serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 18028749089943022788ull);
    vlSelf->serv_tb_top__DOT__u_uart_dbg__DOT__shifter = VL_SCOPED_RAND_RESET_I(10, __VscopeHash, 18294006936305891033ull);
    vlSelf->serv_tb_top__DOT__u_uart_dbg__DOT__busy = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5119734647962954898ull);
    vlSelf->serv_tb_top__DOT__u_uart_dbg__DOT__ack = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7633373396313716686ull);
    vlSelf->__VdfgRegularize_h6e95ff9d_0_0 = 0;
    vlSelf->__VdfgRegularize_h6e95ff9d_0_3 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VicoTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__i_clk__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 3; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
