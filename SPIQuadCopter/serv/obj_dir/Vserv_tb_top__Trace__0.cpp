// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals

#include "verilated_vcd_c.h"
#include "Vserv_tb_top__Syms.h"


void Vserv_tb_top___024root__trace_chg_0_sub_0(Vserv_tb_top___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vserv_tb_top___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_chg_0\n"); );
    // Body
    Vserv_tb_top___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vserv_tb_top___024root*>(voidSelf);
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    Vserv_tb_top___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vserv_tb_top___024root__trace_chg_0_sub_0(Vserv_tb_top___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_chg_0_sub_0\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    if (VL_UNLIKELY(((vlSelfRef.__Vm_traceActivity[1U] 
                      | vlSelfRef.__Vm_traceActivity
                      [2U])))) {
        bufp->chgIData(oldp+0,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr),32);
        bufp->chgBit(oldp+1,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we));
        bufp->chgBit(oldp+2,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb));
        bufp->chgSData(oldp+3,((0x00001fffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
                                               >> 2U))),13);
        bufp->chgBit(oldp+4,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc));
        bufp->chgBit(oldp+5,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en));
        bufp->chgBit(oldp+6,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load));
        bufp->chgBit(oldp+7,(((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc)) 
                              & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack))));
        bufp->chgBit(oldp+8,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq));
        bufp->chgBit(oldp+9,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq) 
                              | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt))));
    }
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[2U]))) {
        bufp->chgIData(oldp+10,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat),32);
        bufp->chgCData(oldp+11,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel),4);
        bufp->chgIData(oldp+12,(vlSelfRef.serv_tb_top__DOT__wb_mem_rdt),32);
        bufp->chgBit(oldp+13,(vlSelfRef.serv_tb_top__DOT__wb_mem_ack));
        bufp->chgIData(oldp+14,((0xfffffffcU & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)),32);
        bufp->chgBit(oldp+15,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                     >> 3U))));
        bufp->chgBit(oldp+16,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb));
        bufp->chgIData(oldp+17,(vlSelfRef.serv_tb_top__DOT__gpio_reg),32);
        bufp->chgBit(oldp+18,(vlSelfRef.serv_tb_top__DOT__gpio_ack));
        bufp->chgBit(oldp+19,(vlSelfRef.serv_tb_top__DOT__uart_dbg_tx));
        bufp->chgSData(oldp+20,(((((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                    ? 0U : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7)) 
                                  << 4U) | (0x0000000fU 
                                            & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                                - (IData)(4U)) 
                                               >> 1U)))),9);
        bufp->chgCData(oldp+21,((3U & ((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                        ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r)
                                        : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r)))),2);
        bufp->chgBit(oldp+22,((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen0_r)) 
                               | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen1_r)))));
        bufp->chgSData(oldp+23,(((0x000001f0U & (((1U 
                                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                                   ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20)
                                                   : 
                                                  ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                                   >> 4U)) 
                                                 << 4U)) 
                                 | (0x0000000fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                                   >> 1U)))),9);
        bufp->chgCData(oldp+24,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_rdata_r),2);
        bufp->chgBit(oldp+25,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgate));
        bufp->chgIData(oldp+26,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr),32);
        bufp->chgBit(oldp+27,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc));
        bufp->chgIData(oldp+28,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_dat),32);
        bufp->chgBit(oldp+29,(((0U == (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                       >> 0x0000001eU)) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc))));
        bufp->chgCData(oldp+30,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7),5);
        bufp->chgBit(oldp+31,(((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
                               & (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op)) 
                                  & (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7))))));
        bufp->chgBit(oldp+32,(((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype) 
                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc)) 
                                | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4) 
                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr))) 
                               | ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf) 
                                    | (((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                        & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add)) 
                                       | ((IData)((
                                                   ((2U 
                                                     == 
                                                     (6U 
                                                      & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))) 
                                                    & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r)) 
                                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0))) 
                                          | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                              >> 2U) 
                                             & (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                                 & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                                    ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))) 
                                                | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                                    >> 1U) 
                                                   & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                                      & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)))))))) 
                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en)) 
                                  | (IData)(((0U == 
                                              (5U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                                             & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid)
                                                 ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q)
                                                 : 
                                                ((~ 
                                                  ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                                   >> 2U)) 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit)))))))));
        bufp->chgCData(oldp+33,((0x0000001fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                                >> 4U))),5);
        bufp->chgCData(oldp+34,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20),5);
        bufp->chgBit(oldp+35,((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))));
        bufp->chgBit(oldp+36,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1)
                                      ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_rdata_r)
                                      : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata1)))));
        bufp->chgIData(oldp+37,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data),32);
        bufp->chgCData(oldp+38,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3),3);
        bufp->chgCData(oldp+39,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl),4);
        bufp->chgCData(oldp+40,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en),4);
        bufp->chgBit(oldp+41,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                     >> 2U))));
        bufp->chgBit(oldp+42,((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))));
        bufp->chgBit(oldp+43,((1U & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))));
        bufp->chgBit(oldp+44,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_two_stage_op));
        bufp->chgBit(oldp+45,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
                               & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)) 
                                  & (~ (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)))))));
        bufp->chgBit(oldp+46,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20));
        bufp->chgBit(oldp+47,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                     >> 4U))));
        bufp->chgBit(oldp+48,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op));
        bufp->chgBit(oldp+49,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op));
        bufp->chgBit(oldp+50,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en));
        bufp->chgBit(oldp+51,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en));
        bufp->chgBit(oldp+52,((IData)((0U == (5U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))));
        bufp->chgBit(oldp+53,((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc)) 
                               | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4) 
                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr)))));
        bufp->chgBit(oldp+54,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf) 
                                     | (((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                         & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add)) 
                                        | ((IData)(
                                                   (((2U 
                                                      == 
                                                      (6U 
                                                       & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))) 
                                                     & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r)) 
                                                    & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0))) 
                                           | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                               >> 2U) 
                                              & (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                                  & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                                     ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))) 
                                                 | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                                     >> 1U) 
                                                    & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                                       & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)))))))))));
        bufp->chgBit(oldp+55,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid)
                                ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q)
                                : ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                       >> 2U)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit)))));
        bufp->chgBit(oldp+56,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en));
        bufp->chgBit(oldp+57,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump));
        bufp->chgBit(oldp+58,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr));
        bufp->chgBit(oldp+59,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype));
        bufp->chgBit(oldp+60,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
                               & ((~ (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))) 
                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)))));
        bufp->chgBit(oldp+61,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm));
        bufp->chgBit(oldp+62,(((0U == (7U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                               | ((3U == (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                                  | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
                                      & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20)) 
                                     | (0U == (3U & 
                                               ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                                >> 3U))))))));
        bufp->chgBit(oldp+63,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init));
        bufp->chgBit(oldp+64,((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb))));
        bufp->chgBit(oldp+65,((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt))));
        bufp->chgBit(oldp+66,((IData)((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                        >> 2U) | (3U 
                                                  == 
                                                  (3U 
                                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)))))));
        bufp->chgBit(oldp+67,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0));
        bufp->chgBit(oldp+68,(((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                               & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                                  >> 1U))));
        bufp->chgBit(oldp+69,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2));
        bufp->chgBit(oldp+70,(((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                               & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                                  >> 3U))));
        bufp->chgBit(oldp+71,(((1U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                               & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                                  >> 3U))));
        bufp->chgBit(oldp+72,(((2U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                               & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                                  >> 3U))));
        bufp->chgBit(oldp+73,(((3U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb))));
        bufp->chgBit(oldp+74,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done));
        bufp->chgBit(oldp+75,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en));
        bufp->chgBit(oldp+76,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm30));
        bufp->chgBit(oldp+77,((1U & ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                         >> 4U)) | (IData)(
                                                           (1U 
                                                            == 
                                                            (3U 
                                                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))))));
        bufp->chgBit(oldp+78,((1U & (~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                        >> 2U)))));
        bufp->chgBit(oldp+79,((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                >> 4U) & ((0U == (3U 
                                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                                          | (3U == 
                                             (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))))));
        bufp->chgBit(oldp+80,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf));
        bufp->chgBit(oldp+81,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q));
        bufp->chgBit(oldp+82,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_sub));
        bufp->chgCData(oldp+83,((3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))),2);
        bufp->chgBit(oldp+84,((0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                            >> 1U)))));
        bufp->chgBit(oldp+85,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig));
        bufp->chgBit(oldp+86,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp));
        bufp->chgCData(oldp+87,(((4U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                 | (((1U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                                   >> 1U))) 
                                     << 1U) | (0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))))),3);
        bufp->chgBit(oldp+88,(((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op))));
        bufp->chgBit(oldp+89,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b));
        bufp->chgBit(oldp+90,((1U & (~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                        >> 2U)))));
        bufp->chgBit(oldp+91,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                     >> 1U))));
        bufp->chgCData(oldp+92,((3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                       >> 1U))),2);
        bufp->chgBit(oldp+93,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt) 
                                     >> 5U))));
        bufp->chgBit(oldp+94,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc));
        bufp->chgBit(oldp+95,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_12) 
                               & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22)) 
                                  & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20))))));
        bufp->chgBit(oldp+96,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_12) 
                               & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20)) 
                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22)))));
        bufp->chgBit(oldp+97,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en) 
                               & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20)) 
                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)))));
        bufp->chgBit(oldp+98,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                     >> 4U))));
        bufp->chgBit(oldp+99,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en) 
                               & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20) 
                                  | ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)) 
                                     & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26))))));
        bufp->chgCData(oldp+100,(((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20) 
                                    & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26)) 
                                   << 1U) | (1U & (
                                                   (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26)) 
                                                   | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21))))),2);
        bufp->chgBit(oldp+101,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_csr_imm_en));
        bufp->chgBit(oldp+102,((IData)((0U == (0x14U 
                                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))));
        bufp->chgCData(oldp+103,((3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)),2);
        bufp->chgBit(oldp+104,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add));
        bufp->chgBit(oldp+105,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0))));
        bufp->chgBit(oldp+106,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r));
        bufp->chgBit(oldp+107,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy));
        bufp->chgBit(oldp+108,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy_r));
        bufp->chgBit(oldp+109,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))));
        bufp->chgBit(oldp+110,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b))));
        bufp->chgBit(oldp+111,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_b));
        bufp->chgBit(oldp+112,((1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                                       & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)) 
                                      + ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b))) 
                                         + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy))))));
        bufp->chgBit(oldp+113,(((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add)) 
                                & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r) 
                                   | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0)))));
        bufp->chgBit(oldp+114,((1U & (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                       & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                          ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))) 
                                      | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                          >> 1U) & 
                                         ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                          & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)))))));
        bufp->chgCData(oldp+115,((7U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi))),3);
        bufp->chgBit(oldp+116,((1U & (((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0) 
                                       + ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                          + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r))) 
                                      >> 1U))));
        bufp->chgBit(oldp+117,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__q));
        bufp->chgBit(oldp+118,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r));
        bufp->chgBit(oldp+119,(((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                  >> 4U) & ((0U == 
                                             (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                                            | (3U == 
                                               (3U 
                                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0))));
        bufp->chgCData(oldp+120,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi),8);
        bufp->chgIData(oldp+121,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo),24);
        bufp->chgBit(oldp+122,((1U & ((IData)((0U == 
                                               (3U 
                                                & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data))) 
                                      | ((IData)((0U 
                                                  == 
                                                  (6U 
                                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)))) 
                                         | (((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                                 >> 2U)) 
                                             & (~ (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                                   >> 1U))) 
                                            | (((~ 
                                                 ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                                  >> 2U)) 
                                                & (~ vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
                                               | ((~ 
                                                   ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                                    >> 1U)) 
                                                  & (~ 
                                                     (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                                      >> 1U))))))))));
        bufp->chgBit(oldp+123,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__shift_en));
        bufp->chgBit(oldp+124,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__cnt_en));
        bufp->chgCData(oldp+125,((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                   << 7U) | ((0x00000040U 
                                              & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
                                                 >> 1U)) 
                                             | (0x0000003fU 
                                                & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
                                                   - (IData)(1U)))))),8);
        bufp->chgCData(oldp+126,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt),8);
        bufp->chgBit(oldp+127,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4));
        bufp->chgBit(oldp+128,((1U & (((1U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr) 
                                       + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2) 
                                          + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r))) 
                                      >> 1U))));
        bufp->chgBit(oldp+129,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r));
        bufp->chgBit(oldp+130,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a) 
                                      + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b) 
                                         + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r))))));
        bufp->chgBit(oldp+131,((1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a) 
                                       + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b) 
                                          + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r))) 
                                      >> 1U))));
        bufp->chgBit(oldp+132,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r));
        bufp->chgBit(oldp+133,((1U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr)));
        bufp->chgBit(oldp+134,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump)
                                 ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc)
                                 : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4))));
        bufp->chgBit(oldp+135,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a));
        bufp->chgBit(oldp+136,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b));
        bufp->chgIData(oldp+137,((vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                                  >> 2U)),30);
        bufp->chgCData(oldp+138,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode),5);
        bufp->chgBit(oldp+139,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21));
        bufp->chgBit(oldp+140,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22));
        bufp->chgBit(oldp+141,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26));
        bufp->chgBit(oldp+142,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm25));
        bufp->chgBit(oldp+143,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20) 
                                | ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)) 
                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26)))));
        bufp->chgIData(oldp+144,((vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                                  >> 7U)),25);
        bufp->chgBit(oldp+145,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm31));
        bufp->chgSData(oldp+146,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20),9);
        bufp->chgBit(oldp+147,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm7));
        bufp->chgCData(oldp+148,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25),6);
        bufp->chgBit(oldp+149,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit));
        bufp->chgBit(oldp+150,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit));
        bufp->chgBit(oldp+151,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid));
        bufp->chgBit(oldp+152,((((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op)) 
                                & (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7)))));
        bufp->chgBit(oldp+153,((1U & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                      >> 1U))));
        bufp->chgBit(oldp+154,((1U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                             >> 1U)))));
        bufp->chgBit(oldp+155,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done));
        bufp->chgCData(oldp+156,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt),3);
        bufp->chgCData(oldp+157,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb),4);
        bufp->chgBit(oldp+158,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__ibus_cyc));
        bufp->chgBit(oldp+159,((IData)((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                         >> 4U) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                                   | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp) 
                                                      ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)))))));
        bufp->chgBit(oldp+160,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init));
        bufp->chgBit(oldp+161,((0U != (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                       >> 0x0000001eU))));
        bufp->chgBit(oldp+162,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt));
        bufp->chgCData(oldp+163,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt),5);
        bufp->chgBit(oldp+164,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1));
        bufp->chgCData(oldp+165,((0x0000001fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                                 - (IData)(4U)))),5);
        bufp->chgCData(oldp+166,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r),2);
        bufp->chgCData(oldp+167,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r),3);
        bufp->chgBit(oldp+168,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen0_r));
        bufp->chgBit(oldp+169,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen1_r));
        bufp->chgBit(oldp+170,((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))));
        bufp->chgCData(oldp+171,(((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                   ? 0U : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7))),5);
        bufp->chgCData(oldp+172,((0x0000001fU & ((1U 
                                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                                  ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20)
                                                  : 
                                                 ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                                  >> 4U)))),5);
        bufp->chgCData(oldp+173,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0),2);
        bufp->chgBit(oldp+174,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata1));
        bufp->chgBit(oldp+175,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rreq_r));
        bufp->chgIData(oldp+176,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__o_wb_dat),32);
        bufp->chgBit(oldp+177,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__ack));
        bufp->chgSData(oldp+178,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt),16);
        bufp->chgCData(oldp+179,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx),4);
        bufp->chgSData(oldp+180,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__shifter),10);
        bufp->chgBit(oldp+181,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__busy));
    }
    bufp->chgBit(oldp+182,(vlSelfRef.i_clk));
    bufp->chgBit(oldp+183,(vlSelfRef.i_rst));
    bufp->chgIData(oldp+184,(vlSelfRef.o_pc),32);
    bufp->chgBit(oldp+185,(vlSelfRef.o_pc_valid));
    bufp->chgIData(oldp+186,(vlSelfRef.o_gpio),32);
}

void Vserv_tb_top___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_cleanup\n"); );
    // Body
    Vserv_tb_top___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vserv_tb_top___024root*>(voidSelf);
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
}
