// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals

#include "verilated_vcd_c.h"
#include "Vserv_tb_top__Syms.h"


VL_ATTR_COLD void Vserv_tb_top___024root__trace_init_sub__TOP__0(Vserv_tb_top___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_init_sub__TOP__0\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const int c = vlSymsp->__Vm_baseCode;
    tracep->pushPrefix("$rootio", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+185,0,"o_pc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+186,0,"o_pc_valid",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+187,0,"o_gpio",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->popPrefix();
    tracep->pushPrefix("serv_tb_top", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+185,0,"o_pc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+186,0,"o_pc_valid",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+187,0,"o_gpio",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+188,0,"MEMSIZE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declArray(c+189,0,"MEMFILE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 167,0);
    tracep->declBus(c+1,0,"wb_mem_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"wb_mem_dat",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"wb_mem_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+2,0,"wb_mem_we",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"wb_mem_stb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"wb_mem_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+14,0,"wb_mem_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"wb_ext_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"wb_ext_dat",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"wb_ext_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"wb_ext_we",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"wb_ext_stb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"wb_ext_cyc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+18,0,"wb_ext_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+19,0,"wb_ext_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+18,0,"gpio_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+19,0,"gpio_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+20,0,"uart_dbg_tx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("u_ram", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+188,0,"DEPTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declArray(c+189,0,"MEMFILE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 167,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+1,0,"i_wb_adr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"i_wb_dat",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"i_wb_sel",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+2,0,"i_wb_we",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"i_wb_stb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"o_wb_rdt",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+14,0,"o_wb_ack",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+195,0,"AW",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+4,0,"word_addr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 12,0);
    tracep->popPrefix();
    tracep->pushPrefix("u_serv", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+188,0,"MEMSIZE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declArray(c+189,0,"MEMFILE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 167,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"o_wb_ext_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_wb_ext_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"o_wb_ext_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"o_wb_ext_we",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"o_wb_ext_stb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"o_wb_ext_cyc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+18,0,"i_wb_ext_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+19,0,"i_wb_ext_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+1,0,"o_wb_mem_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_wb_mem_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"o_wb_mem_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+2,0,"o_wb_mem_we",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"o_wb_mem_stb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"i_wb_mem_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+14,0,"i_wb_mem_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+185,0,"o_debug_pc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+186,0,"o_debug_valid",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+196,0,"WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+197,0,"RF_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+198,0,"REGS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+199,0,"RF_L2D",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+21,0,"rf_waddr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 8,0);
    tracep->declBus(c+22,0,"rf_wdata",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+23,0,"rf_wen",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+24,0,"rf_raddr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 8,0);
    tracep->declBus(c+25,0,"rf_rdata",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+26,0,"rf_ren",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+1,0,"wb_mem_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"wb_mem_dat",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"wb_mem_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+2,0,"wb_mem_we",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"wb_mem_stb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"wb_mem_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+14,0,"wb_mem_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+25,0,"rf_rdata_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->pushPrefix("u_servile", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+196,0,"width",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+200,0,"reset_pc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+201,0,"reset_strategy",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+197,0,"rf_width",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+202,0,"sim",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"debug",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"with_c",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"with_csr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"with_mdu",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+204,0,"regs",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+199,0,"rf_l2d",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_timer_irq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+1,0,"o_wb_mem_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_wb_mem_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"o_wb_mem_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+2,0,"o_wb_mem_we",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"o_wb_mem_stb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"i_wb_mem_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+14,0,"i_wb_mem_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"o_wb_ext_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_wb_ext_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"o_wb_ext_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"o_wb_ext_we",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"o_wb_ext_stb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+18,0,"i_wb_ext_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+19,0,"i_wb_ext_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+21,0,"o_rf_waddr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 8,0);
    tracep->declBus(c+22,0,"o_rf_wdata",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+23,0,"o_rf_wen",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+24,0,"o_rf_raddr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 8,0);
    tracep->declBus(c+25,0,"i_rf_rdata",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+26,0,"o_rf_ren",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+27,0,"wb_ibus_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+5,0,"wb_ibus_stb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"wb_ibus_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+6,0,"wb_ibus_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"wb_dbus_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"wb_dbus_dat",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"wb_dbus_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"wb_dbus_we",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+28,0,"wb_dbus_stb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+29,0,"wb_dbus_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"wb_dbus_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"wb_dmem_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"wb_dmem_dat",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"wb_dmem_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"wb_dmem_we",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+30,0,"wb_dmem_stb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"wb_dmem_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+8,0,"wb_dmem_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+9,0,"rf_wreq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"rf_rreq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+31,0,"wreg0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+206,0,"wreg1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+32,0,"wen0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"wen1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+33,0,"wdata0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"wdata1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+34,0,"rreg0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+35,0,"rreg1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+10,0,"rf_ready",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+36,0,"rdata0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+37,0,"rdata1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+38,0,"mdu_rs1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"mdu_rs2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+39,0,"mdu_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+205,0,"mdu_valid",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+200,0,"mdu_rd",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+205,0,"mdu_ready",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("arbiter", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+15,0,"i_wb_cpu_dbus_adr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"i_wb_cpu_dbus_dat",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"i_wb_cpu_dbus_sel",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"i_wb_cpu_dbus_we",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+30,0,"i_wb_cpu_dbus_stb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"o_wb_cpu_dbus_rdt",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+8,0,"o_wb_cpu_dbus_ack",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+27,0,"i_wb_cpu_ibus_adr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+5,0,"i_wb_cpu_ibus_stb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"o_wb_cpu_ibus_rdt",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+6,0,"o_wb_cpu_ibus_ack",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+1,0,"o_wb_mem_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_wb_mem_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"o_wb_mem_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+2,0,"o_wb_mem_we",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"o_wb_mem_stb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"i_wb_mem_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+14,0,"i_wb_mem_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("cpu", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+203,0,"WITH_CSR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+207,0,"PRE_REGISTER",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+201,0,"RESET_STRATEGY",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+200,0,"RESET_PC",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+202,0,"DEBUG",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"MDU",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"COMPRESSED",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"ALIGN",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+183,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_timer_irq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"o_rf_rreq",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+9,0,"o_rf_wreq",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+10,0,"i_rf_ready",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+31,0,"o_wreg0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+206,0,"o_wreg1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+32,0,"o_wen0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"o_wen1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+33,0,"o_wdata0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"o_wdata1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+34,0,"o_rreg0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+35,0,"o_rreg1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+36,0,"i_rdata0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+37,0,"i_rdata1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+27,0,"o_ibus_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+5,0,"o_ibus_cyc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"i_ibus_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+6,0,"i_ibus_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"o_dbus_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_dbus_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"o_dbus_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"o_dbus_we",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+28,0,"o_dbus_cyc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+29,0,"i_dbus_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"i_dbus_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+39,0,"o_ext_funct3",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+205,0,"i_ext_ready",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+200,0,"i_ext_rd",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+38,0,"o_ext_rs1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_ext_rs2",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+205,0,"o_mdu_valid",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+31,0,"rd_addr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+34,0,"rs1_addr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+35,0,"rs2_addr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+40,0,"immdec_ctrl",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+41,0,"immdec_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+42,0,"sh_right",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"bne_or_bge",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+44,0,"cond_branch",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+45,0,"two_stage_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+46,0,"e_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+47,0,"ebreak",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+48,0,"branch_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+49,0,"shift_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+50,0,"rd_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"mdu_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+51,0,"rd_alu_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+52,0,"rd_csr_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+53,0,"rd_mem_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+54,0,"ctrl_rd",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+55,0,"alu_rd",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+56,0,"mem_rd",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"csr_rd",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+48,0,"mtval_pc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+57,0,"ctrl_pc_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+58,0,"jump",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+59,0,"jal_or_jalr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+60,0,"utype",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+61,0,"mret",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+62,0,"imm",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+205,0,"trap",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+63,0,"pc_rel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"iscomp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+64,0,"init",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+65,0,"cnt_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+66,0,"cnt0to3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+67,0,"cnt12to31",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+68,0,"cnt0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+69,0,"cnt1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+70,0,"cnt2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+71,0,"cnt3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+72,0,"cnt7",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+73,0,"cnt11",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+74,0,"cnt12",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+75,0,"cnt_done",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+76,0,"bufreg_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+77,0,"bufreg_sh_signed",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+78,0,"bufreg_rs1_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+79,0,"bufreg_imm_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+80,0,"bufreg_clr_lsb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+81,0,"bufreg_q",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+82,0,"bufreg2_q",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+29,0,"dbus_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"dbus_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+83,0,"alu_sub",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+84,0,"alu_bool_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+85,0,"alu_cmp_eq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+86,0,"alu_cmp_sig",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+87,0,"alu_cmp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+88,0,"alu_rd_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+36,0,"rs1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+37,0,"rs2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+89,0,"rd_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+90,0,"op_b",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+16,0,"op_b_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+91,0,"mem_signed",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+92,0,"mem_word",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"mem_half",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+93,0,"mem_bytecnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+94,0,"sh_done",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"mem_misalign",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+95,0,"bad_pc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+96,0,"csr_mstatus_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+97,0,"csr_mie_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+98,0,"csr_mcause_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+84,0,"csr_source",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+99,0,"csr_imm",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+42,0,"csr_d_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+100,0,"csr_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+101,0,"csr_addr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+205,0,"csr_pc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+102,0,"csr_imm_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+205,0,"csr_in",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"rf_csr_out",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+103,0,"dbus_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"new_irq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+104,0,"lsb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+13,0,"i_wb_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+27,0,"wb_ibus_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+5,0,"wb_ibus_cyc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"wb_ibus_rdt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+6,0,"wb_ibus_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("alu", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+65,0,"i_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+68,0,"i_cnt0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+87,0,"o_cmp",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+83,0,"i_sub",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+84,0,"i_bool_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+85,0,"i_cmp_eq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+86,0,"i_cmp_sig",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+88,0,"i_rd_sel",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+36,0,"i_rs1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+90,0,"i_op_b",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+81,0,"i_buf",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+55,0,"o_rd",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+105,0,"result_add",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+106,0,"result_slt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+107,0,"cmp_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+108,0,"add_cy",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+109,0,"add_cy_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+110,0,"rs1_sx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+111,0,"op_b_sx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+112,0,"add_b",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+113,0,"result_lt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+114,0,"result_eq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+115,0,"result_bool",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->popPrefix();
    tracep->pushPrefix("bufreg", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+202,0,"MDU",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+68,0,"i_cnt0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+69,0,"i_cnt1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+75,0,"i_cnt_done",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+76,0,"i_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+64,0,"i_init",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_mdu_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+104,0,"o_lsb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+78,0,"i_rs1_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+79,0,"i_imm_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+80,0,"i_clr_lsb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+49,0,"i_shift_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+42,0,"i_right_shift_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+116,0,"i_shamt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+77,0,"i_sh_signed",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+36,0,"i_rs1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+62,0,"i_imm",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+81,0,"o_q",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+15,0,"o_dbus_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+38,0,"o_ext_rs1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+117,0,"c",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+118,0,"q",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+119,0,"c_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+38,0,"data",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+120,0,"clr_lsb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->popPrefix();
    tracep->pushPrefix("bufreg2", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+65,0,"i_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+64,0,"i_init",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+72,0,"i_cnt7",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+75,0,"i_cnt_done",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+42,0,"i_sh_right",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+104,0,"i_lsb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+93,0,"i_bytecnt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+94,0,"o_sh_done",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+16,0,"i_op_b_sel",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+49,0,"i_shift_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+37,0,"i_rs2",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+62,0,"i_imm",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+90,0,"o_op_b",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+82,0,"o_q",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+11,0,"o_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"i_load",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+29,0,"i_dat",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+121,0,"dhi",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+122,0,"dlo",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 23,0);
    tracep->declBit(c+123,0,"byte_valid",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+124,0,"shift_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+125,0,"cnt_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+126,0,"cnt_next",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBus(c+127,0,"dat_shamt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->popPrefix();
    tracep->pushPrefix("ctrl", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+201,0,"RESET_STRATEGY",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+200,0,"RESET_PC",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"WITH_CSR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+57,0,"i_pc_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+67,0,"i_cnt12to31",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+68,0,"i_cnt0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+69,0,"i_cnt1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+70,0,"i_cnt2",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+58,0,"i_jump",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+59,0,"i_jal_or_jalr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+60,0,"i_utype",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+63,0,"i_pc_rel",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+61,0,"i_trap",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_iscomp",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+62,0,"i_imm",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+81,0,"i_buf",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"i_csr_pc",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+54,0,"o_rd",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+95,0,"o_bad_pc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+27,0,"o_ibus_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+128,0,"pc_plus_4",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+129,0,"pc_plus_4_cy",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+130,0,"pc_plus_4_cy_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+130,0,"pc_plus_4_cy_r_w",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+131,0,"pc_plus_offset",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+132,0,"pc_plus_offset_cy",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+133,0,"pc_plus_offset_cy_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+133,0,"pc_plus_offset_cy_r_w",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+95,0,"pc_plus_offset_aligned",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+70,0,"plus_4",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+134,0,"pc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+135,0,"new_pc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+136,0,"offset_a",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+137,0,"offset_b",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->popPrefix();
    tracep->pushPrefix("decode", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+207,0,"PRE_REGISTER",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"MDU",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+183,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+138,0,"i_wb_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,2);
    tracep->declBit(c+6,0,"i_wb_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+42,0,"o_sh_right",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"o_bne_or_bge",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+44,0,"o_cond_branch",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+46,0,"o_e_op",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+47,0,"o_ebreak",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+48,0,"o_branch_op",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+49,0,"o_shift_op",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+50,0,"o_rd_op",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+45,0,"o_two_stage_op",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+103,0,"o_dbus_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"o_mdu_op",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+39,0,"o_ext_funct3",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+78,0,"o_bufreg_rs1_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+79,0,"o_bufreg_imm_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+80,0,"o_bufreg_clr_lsb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+77,0,"o_bufreg_sh_signed",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+59,0,"o_ctrl_jal_or_jalr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+60,0,"o_ctrl_utype",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+63,0,"o_ctrl_pc_rel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+61,0,"o_ctrl_mret",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+83,0,"o_alu_sub",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+84,0,"o_alu_bool_op",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+85,0,"o_alu_cmp_eq",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+86,0,"o_alu_cmp_sig",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+88,0,"o_alu_rd_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+91,0,"o_mem_signed",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+92,0,"o_mem_word",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"o_mem_half",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+16,0,"o_mem_cmd",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+100,0,"o_csr_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+101,0,"o_csr_addr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+96,0,"o_csr_mstatus_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+97,0,"o_csr_mie_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+98,0,"o_csr_mcause_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+84,0,"o_csr_source",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+42,0,"o_csr_d_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+102,0,"o_csr_imm_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+48,0,"o_mtval_pc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+40,0,"o_immdec_ctrl",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+41,0,"o_immdec_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"o_op_b_source",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+53,0,"o_rd_mem_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+52,0,"o_rd_csr_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+51,0,"o_rd_alu_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+139,0,"opcode",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+39,0,"funct3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+47,0,"op20",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+140,0,"op21",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+141,0,"op22",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+142,0,"op26",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+143,0,"imm25",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+77,0,"imm30",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"co_mdu_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+45,0,"co_two_stage_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+49,0,"co_shift_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+48,0,"co_branch_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+103,0,"co_dbus_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+48,0,"co_mtval_pc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+92,0,"co_mem_word",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+51,0,"co_rd_alu_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+53,0,"co_rd_mem_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+39,0,"co_ext_funct3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+78,0,"co_bufreg_rs1_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+79,0,"co_bufreg_imm_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+80,0,"co_bufreg_clr_lsb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+44,0,"co_cond_branch",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+60,0,"co_ctrl_utype",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+59,0,"co_ctrl_jal_or_jalr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+63,0,"co_ctrl_pc_rel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+50,0,"co_rd_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+42,0,"co_sh_right",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"co_bne_or_bge",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+52,0,"csr_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+47,0,"co_ebreak",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+61,0,"co_ctrl_mret",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+46,0,"co_e_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+77,0,"co_bufreg_sh_signed",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+83,0,"co_alu_sub",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+144,0,"csr_valid",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+52,0,"co_rd_csr_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+100,0,"co_csr_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+96,0,"co_csr_mstatus_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+97,0,"co_csr_mie_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+98,0,"co_csr_mcause_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+84,0,"co_csr_source",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+42,0,"co_csr_d_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+102,0,"co_csr_imm_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+101,0,"co_csr_addr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+85,0,"co_alu_cmp_eq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+86,0,"co_alu_cmp_sig",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+16,0,"co_mem_cmd",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+91,0,"co_mem_signed",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"co_mem_half",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+84,0,"co_alu_bool_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+40,0,"co_immdec_ctrl",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+41,0,"co_immdec_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+88,0,"co_alu_rd_sel",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+16,0,"co_op_b_source",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("immdec", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+196,0,"SHARED_RFADDR_IMM_REGS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+65,0,"i_cnt_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+75,0,"i_cnt_done",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+41,0,"i_immdec_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+102,0,"i_csr_imm_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+40,0,"i_ctrl",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+31,0,"o_rd_addr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+34,0,"o_rs1_addr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+35,0,"o_rs2_addr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+99,0,"o_csr_imm",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+62,0,"o_imm",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+6,0,"i_wb_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+145,0,"i_wb_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,7);
    tracep->pushPrefix("gen_immdec_w_eq_1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+146,0,"imm31",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+147,0,"imm19_12_20",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 8,0);
    tracep->declBit(c+148,0,"imm7",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+149,0,"imm30_25",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 5,0);
    tracep->declBus(c+35,0,"imm24_20",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+31,0,"imm11_7",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+150,0,"signbit",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->pushPrefix("mem_if", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+202,0,"WITH_CSR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+93,0,"i_bytecnt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+104,0,"i_lsb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+205,0,"o_misalign",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+91,0,"i_signed",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+92,0,"i_word",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"i_half",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_mdu_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+82,0,"i_bufreg2_q",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+56,0,"o_rd",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+12,0,"o_wb_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+151,0,"signbit",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+152,0,"dat_valid",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("rf_if", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+203,0,"WITH_CSR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+65,0,"i_cnt_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+31,0,"o_wreg0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+206,0,"o_wreg1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+32,0,"o_wen0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"o_wen1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+33,0,"o_wdata0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"o_wdata1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+34,0,"o_rreg0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+35,0,"o_rreg1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+36,0,"i_rdata0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+37,0,"i_rdata1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+205,0,"i_trap",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+61,0,"i_mret",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+134,0,"i_mepc",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+48,0,"i_mtval_pc",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+81,0,"i_bufreg_q",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+95,0,"i_bad_pc",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"o_csr_pc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+100,0,"i_csr_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+101,0,"i_csr_addr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+205,0,"i_csr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"o_csr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+89,0,"i_rd_wen",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+31,0,"i_rd_waddr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+54,0,"i_ctrl_rd",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+55,0,"i_alu_rd",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+51,0,"i_rd_alu_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+205,0,"i_csr_rd",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+52,0,"i_rd_csr_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+56,0,"i_mem_rd",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+53,0,"i_rd_mem_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+34,0,"i_rs1_raddr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+36,0,"o_rs1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+35,0,"i_rs2_raddr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+37,0,"o_rs2",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+153,0,"rd_wen",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("gen_no_csr", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+33,0,"rd",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->pushPrefix("state", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+201,0,"RESET_STRATEGY",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+202,0,"WITH_CSR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"ALIGN",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+202,0,"MDU",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_new_irq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+87,0,"i_alu_cmp",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+64,0,"o_init",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+65,0,"o_cnt_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+66,0,"o_cnt0to3",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+67,0,"o_cnt12to31",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+68,0,"o_cnt0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+69,0,"o_cnt1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+70,0,"o_cnt2",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+71,0,"o_cnt3",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+72,0,"o_cnt7",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+73,0,"o_cnt11",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+74,0,"o_cnt12",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+75,0,"o_cnt_done",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+76,0,"o_bufreg_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+57,0,"o_ctrl_pc_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+58,0,"o_ctrl_jump",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"o_ctrl_trap",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+154,0,"i_ctrl_misalign",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+94,0,"i_sh_done",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+93,0,"o_mem_bytecnt",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+205,0,"i_mem_misalign",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+43,0,"i_bne_or_bge",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+44,0,"i_cond_branch",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+103,0,"i_dbus_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+45,0,"i_two_stage_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+48,0,"i_branch_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+49,0,"i_shift_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+42,0,"i_sh_right",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+155,0,"i_alu_rd_sel1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+51,0,"i_rd_alu_en",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+46,0,"i_e_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+50,0,"i_rd_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_mdu_op",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"o_mdu_valid",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_mdu_ready",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+28,0,"o_dbus_cyc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+7,0,"i_dbus_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"o_ibus_cyc",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"i_ibus_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"o_rf_rreq",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+9,0,"o_rf_wreq",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+10,0,"i_rf_ready",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+89,0,"o_rf_rd_en",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+156,0,"init_done",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"misalign_trap_sync",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+157,0,"o_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,2);
    tracep->declBus(c+158,0,"cnt_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+159,0,"ibus_cyc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+160,0,"take_branch",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+161,0,"last_init",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"trap_pending",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("gen_cnt_w_eq_1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+158,0,"cnt_lsb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->pushPrefix("mux", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+202,0,"sim",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+208,0,"sim_sig_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+209,0,"sim_halt_adr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"i_wb_cpu_adr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"i_wb_cpu_dat",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"i_wb_cpu_sel",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"i_wb_cpu_we",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+28,0,"i_wb_cpu_stb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+29,0,"o_wb_cpu_rdt",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"o_wb_cpu_ack",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"o_wb_mem_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_wb_mem_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"o_wb_mem_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"o_wb_mem_we",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+30,0,"o_wb_mem_stb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+13,0,"i_wb_mem_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+8,0,"i_wb_mem_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"o_wb_ext_adr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"o_wb_ext_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+12,0,"o_wb_ext_sel",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+16,0,"o_wb_ext_we",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"o_wb_ext_stb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+18,0,"i_wb_ext_rdt",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+19,0,"i_wb_ext_ack",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"sig_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"halt_en",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"sim_ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+162,0,"ext",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->pushPrefix("rf_ram_if", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+197,0,"width",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+196,0,"W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+201,0,"reset_strategy",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+200,0,"csr_regs",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+203,0,"B",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+210,0,"raw",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+196,0,"l2w",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+199,0,"aw",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+9,0,"i_wreq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"i_rreq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+10,0,"o_ready",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+31,0,"i_wreg0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+206,0,"i_wreg1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+32,0,"i_wen0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+205,0,"i_wen1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+33,0,"i_wdata0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+205,0,"i_wdata1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+34,0,"i_rreg0",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+35,0,"i_rreg1",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+36,0,"o_rdata0",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+37,0,"o_rdata1",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBus(c+21,0,"o_waddr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 8,0);
    tracep->declBus(c+22,0,"o_wdata",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBit(c+23,0,"o_wen",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+24,0,"o_raddr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 8,0);
    tracep->declBit(c+26,0,"o_ren",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+25,0,"i_rdata",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+197,0,"ratio",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+211,0,"CMSB",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+196,0,"l2r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+163,0,"rgnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+164,0,"rcnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+165,0,"rtrig1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+166,0,"wcnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+167,0,"wdata0_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+168,0,"wdata1_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+169,0,"wen0_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+170,0,"wen1_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+165,0,"wtrig0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+171,0,"wtrig1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+172,0,"wreg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBit(c+171,0,"rtrig0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+173,0,"rreg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+174,0,"rdata0",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+175,0,"rdata1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 0,0);
    tracep->declBit(c+26,0,"rgate",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+176,0,"rreq_r",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->pushPrefix("u_uart_dbg", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+212,0,"WB_ADDR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+213,0,"CLK_FREQ",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+214,0,"BAUD",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+183,0,"i_clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+184,0,"i_rst",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+15,0,"i_wb_adr",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"i_wb_dat",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+16,0,"i_wb_we",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+17,0,"i_wb_stb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+177,0,"o_wb_dat",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+178,0,"o_wb_ack",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+20,0,"o_uart_tx",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+212,0,"ADDR_TX",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+215,0,"ADDR_STATUS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+216,0,"CLKS_PER_BIT",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+179,0,"clk_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBus(c+180,0,"bit_idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBus(c+181,0,"shifter",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 9,0);
    tracep->declBit(c+182,0,"busy",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+178,0,"ack",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vserv_tb_top___024root__trace_init_top(Vserv_tb_top___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_init_top\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vserv_tb_top___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vserv_tb_top___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vserv_tb_top___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vserv_tb_top___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vserv_tb_top___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vserv_tb_top___024root__trace_register(Vserv_tb_top___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_register\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vserv_tb_top___024root__trace_const_0, 0, vlSelf);
    tracep->addFullCb(&Vserv_tb_top___024root__trace_full_0, 0, vlSelf);
    tracep->addChgCb(&Vserv_tb_top___024root__trace_chg_0, 0, vlSelf);
    tracep->addCleanupCb(&Vserv_tb_top___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vserv_tb_top___024root__trace_const_0_sub_0(Vserv_tb_top___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vserv_tb_top___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_const_0\n"); );
    // Body
    Vserv_tb_top___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vserv_tb_top___024root*>(voidSelf);
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    Vserv_tb_top___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vserv_tb_top___024root__trace_const_0_sub_0(Vserv_tb_top___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_const_0_sub_0\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    VlWide<6>/*191:0*/ __Vtemp_1;
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    bufp->fullIData(oldp+188,(0x00008000U),32);
    __Vtemp_1[0U] = 0x2e686578U;
    __Vtemp_1[1U] = 0x77617265U;
    __Vtemp_1[2U] = 0x6669726dU;
    __Vtemp_1[3U] = 0x6172652fU;
    __Vtemp_1[4U] = 0x69726d77U;
    __Vtemp_1[5U] = 0x00000066U;
    bufp->fullWData(oldp+189,(__Vtemp_1),168);
    bufp->fullIData(oldp+195,(0x0000000fU),32);
    bufp->fullIData(oldp+196,(1U),32);
    bufp->fullIData(oldp+197,(2U),32);
    bufp->fullIData(oldp+198,(0x00000020U),32);
    bufp->fullIData(oldp+199,(9U),32);
    bufp->fullIData(oldp+200,(0U),32);
    bufp->fullIData(oldp+201,(0x4d494e49U),32);
    bufp->fullBit(oldp+202,(0U));
    bufp->fullIData(oldp+203,(0U),32);
    bufp->fullIData(oldp+204,(0x00000020U),32);
    bufp->fullBit(oldp+205,(0U));
    bufp->fullCData(oldp+206,(0U),5);
    bufp->fullBit(oldp+207,(1U));
    bufp->fullIData(oldp+208,(0x80000000U),32);
    bufp->fullIData(oldp+209,(0x90000000U),32);
    bufp->fullIData(oldp+210,(5U),32);
    bufp->fullIData(oldp+211,(4U),32);
    bufp->fullIData(oldp+212,(0x40000110U),32);
    bufp->fullIData(oldp+213,(0x00989680U),32);
    bufp->fullIData(oldp+214,(0x0001c200U),32);
    bufp->fullIData(oldp+215,(0x40000114U),32);
    bufp->fullIData(oldp+216,(0x00000056U),32);
}

VL_ATTR_COLD void Vserv_tb_top___024root__trace_full_0_sub_0(Vserv_tb_top___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vserv_tb_top___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_full_0\n"); );
    // Body
    Vserv_tb_top___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vserv_tb_top___024root*>(voidSelf);
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    Vserv_tb_top___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vserv_tb_top___024root__trace_full_0_sub_0(Vserv_tb_top___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vserv_tb_top___024root__trace_full_0_sub_0\n"); );
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    bufp->fullIData(oldp+1,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr),32);
    bufp->fullBit(oldp+2,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_we));
    bufp->fullBit(oldp+3,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_stb));
    bufp->fullSData(oldp+4,((0x00001fffU & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_mem_adr 
                                            >> 2U))),13);
    bufp->fullBit(oldp+5,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc));
    bufp->fullBit(oldp+6,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__i_wb_en));
    bufp->fullBit(oldp+7,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_load));
    bufp->fullBit(oldp+8,(((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_ibus_cyc)) 
                           & (IData)(vlSelfRef.serv_tb_top__DOT__wb_mem_ack))));
    bufp->fullBit(oldp+9,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq));
    bufp->fullBit(oldp+10,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__i_wreq) 
                            | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt))));
    bufp->fullIData(oldp+11,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_dat),32);
    bufp->fullCData(oldp+12,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__o_wb_sel),4);
    bufp->fullIData(oldp+13,(vlSelfRef.serv_tb_top__DOT__wb_mem_rdt),32);
    bufp->fullBit(oldp+14,(vlSelfRef.serv_tb_top__DOT__wb_mem_ack));
    bufp->fullIData(oldp+15,((0xfffffffcU & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)),32);
    bufp->fullBit(oldp+16,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                  >> 3U))));
    bufp->fullBit(oldp+17,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__o_wb_ext_stb));
    bufp->fullIData(oldp+18,(vlSelfRef.serv_tb_top__DOT__gpio_reg),32);
    bufp->fullBit(oldp+19,(vlSelfRef.serv_tb_top__DOT__gpio_ack));
    bufp->fullBit(oldp+20,(vlSelfRef.serv_tb_top__DOT__uart_dbg_tx));
    bufp->fullSData(oldp+21,(((((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                 ? 0U : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7)) 
                               << 4U) | (0x0000000fU 
                                         & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                             - (IData)(4U)) 
                                            >> 1U)))),9);
    bufp->fullCData(oldp+22,((3U & ((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                     ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r)
                                     : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r)))),2);
    bufp->fullBit(oldp+23,((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1) 
                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen0_r)) 
                            | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen1_r)))));
    bufp->fullSData(oldp+24,(((0x000001f0U & (((1U 
                                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                                ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20)
                                                : ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                                   >> 4U)) 
                                              << 4U)) 
                              | (0x0000000fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                                >> 1U)))),9);
    bufp->fullCData(oldp+25,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_rdata_r),2);
    bufp->fullBit(oldp+26,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgate));
    bufp->fullIData(oldp+27,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr),32);
    bufp->fullBit(oldp+28,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc));
    bufp->fullIData(oldp+29,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__i_dat),32);
    bufp->fullBit(oldp+30,(((0U == (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                    >> 0x0000001eU)) 
                            & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_dbus_cyc))));
    bufp->fullCData(oldp+31,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7),5);
    bufp->fullBit(oldp+32,(((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb)) 
                            & (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op)) 
                               & (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7))))));
    bufp->fullBit(oldp+33,(((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype) 
                              & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc)) 
                             | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr))) 
                            | ((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf) 
                                 | (((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                     & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add)) 
                                    | ((IData)((((2U 
                                                  == 
                                                  (6U 
                                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))) 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r)) 
                                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0))) 
                                       | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                           >> 2U) & 
                                          (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                               ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))) 
                                           | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                               >> 1U) 
                                              & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)))))))) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en)) 
                               | (IData)(((0U == (5U 
                                                  & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                                          & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid)
                                              ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q)
                                              : ((~ 
                                                  ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                                   >> 2U)) 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit)))))))));
    bufp->fullCData(oldp+34,((0x0000001fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                             >> 4U))),5);
    bufp->fullCData(oldp+35,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20),5);
    bufp->fullBit(oldp+36,((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))));
    bufp->fullBit(oldp+37,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1)
                                   ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__rf_rdata_r)
                                   : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata1)))));
    bufp->fullIData(oldp+38,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data),32);
    bufp->fullCData(oldp+39,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3),3);
    bufp->fullCData(oldp+40,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_ctrl),4);
    bufp->fullCData(oldp+41,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_immdec_en),4);
    bufp->fullBit(oldp+42,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                  >> 2U))));
    bufp->fullBit(oldp+43,((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))));
    bufp->fullBit(oldp+44,((1U & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))));
    bufp->fullBit(oldp+45,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_two_stage_op));
    bufp->fullBit(oldp+46,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
                            & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)) 
                               & (~ (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)))))));
    bufp->fullBit(oldp+47,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20));
    bufp->fullBit(oldp+48,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                  >> 4U))));
    bufp->fullBit(oldp+49,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_shift_op));
    bufp->fullBit(oldp+50,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op));
    bufp->fullBit(oldp+51,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_alu_en));
    bufp->fullBit(oldp+52,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en));
    bufp->fullBit(oldp+53,((IData)((0U == (5U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))));
    bufp->fullBit(oldp+54,((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype) 
                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc)) 
                            | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr)))));
    bufp->fullBit(oldp+55,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf) 
                                  | (((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                      & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add)) 
                                     | ((IData)((((2U 
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
    bufp->fullBit(oldp+56,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid)
                             ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q)
                             : ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                    >> 2U)) & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit)))));
    bufp->fullBit(oldp+57,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_pc_en));
    bufp->fullBit(oldp+58,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump));
    bufp->fullBit(oldp+59,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_jal_or_jalr));
    bufp->fullBit(oldp+60,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_utype));
    bufp->fullBit(oldp+61,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
                            & ((~ (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)))));
    bufp->fullBit(oldp+62,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_imm));
    bufp->fullBit(oldp+63,(((0U == (7U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                            | ((3U == (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                               | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_4) 
                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20)) 
                                  | (0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                                  >> 3U))))))));
    bufp->fullBit(oldp+64,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init));
    bufp->fullBit(oldp+65,((0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb))));
    bufp->fullBit(oldp+66,((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt))));
    bufp->fullBit(oldp+67,((IData)((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                     >> 2U) | (3U == 
                                               (3U 
                                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)))))));
    bufp->fullBit(oldp+68,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0));
    bufp->fullBit(oldp+69,(((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                               >> 1U))));
    bufp->fullBit(oldp+70,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2));
    bufp->fullBit(oldp+71,(((0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                               >> 3U))));
    bufp->fullBit(oldp+72,(((1U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                               >> 3U))));
    bufp->fullBit(oldp+73,(((2U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                            & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb) 
                               >> 3U))));
    bufp->fullBit(oldp+74,(((3U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)) 
                            & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb))));
    bufp->fullBit(oldp+75,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_cnt_done));
    bufp->fullBit(oldp+76,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_en));
    bufp->fullBit(oldp+77,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm30));
    bufp->fullBit(oldp+78,((1U & ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                      >> 4U)) | (IData)(
                                                        (1U 
                                                         == 
                                                         (3U 
                                                          & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))))));
    bufp->fullBit(oldp+79,((1U & (~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                     >> 2U)))));
    bufp->fullBit(oldp+80,((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                             >> 4U) & ((0U == (3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                                       | (3U == (3U 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode)))))));
    bufp->fullBit(oldp+81,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_buf));
    bufp->fullBit(oldp+82,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__o_q));
    bufp->fullBit(oldp+83,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_sub));
    bufp->fullCData(oldp+84,((3U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))),2);
    bufp->fullBit(oldp+85,((0U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                         >> 1U)))));
    bufp->fullBit(oldp+86,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig));
    bufp->fullBit(oldp+87,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp));
    bufp->fullCData(oldp+88,(((4U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                              | (((1U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                                >> 1U))) 
                                  << 1U) | (0U == (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3))))),3);
    bufp->fullBit(oldp+89,(((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
                            & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op))));
    bufp->fullBit(oldp+90,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b));
    bufp->fullBit(oldp+91,((1U & (~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                     >> 2U)))));
    bufp->fullBit(oldp+92,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                  >> 1U))));
    bufp->fullCData(oldp+93,((3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                    >> 1U))),2);
    bufp->fullBit(oldp+94,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt) 
                                  >> 5U))));
    bufp->fullBit(oldp+95,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc));
    bufp->fullBit(oldp+96,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_12) 
                            & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22)) 
                               & (~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20))))));
    bufp->fullBit(oldp+97,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT____VdfgRegularize_h6d71b89f_0_12) 
                            & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20)) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22)))));
    bufp->fullBit(oldp+98,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en) 
                            & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20)) 
                               & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)))));
    bufp->fullBit(oldp+99,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                  >> 4U))));
    bufp->fullBit(oldp+100,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_csr_en) 
                             & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20) 
                                | ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)) 
                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26))))));
    bufp->fullCData(oldp+101,(((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20) 
                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26)) 
                                << 1U) | (1U & ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26)) 
                                                | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21))))),2);
    bufp->fullBit(oldp+102,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_csr_imm_en));
    bufp->fullBit(oldp+103,((IData)((0U == (0x14U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))));
    bufp->fullCData(oldp+104,((3U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)),2);
    bufp->fullBit(oldp+105,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add));
    bufp->fullBit(oldp+106,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r) 
                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0))));
    bufp->fullBit(oldp+107,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r));
    bufp->fullBit(oldp+108,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy));
    bufp->fullBit(oldp+109,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy_r));
    bufp->fullBit(oldp+110,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))));
    bufp->fullBit(oldp+111,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b))));
    bufp->fullBit(oldp+112,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_b));
    bufp->fullBit(oldp+113,((1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                                    & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)) 
                                   + ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cmp_sig) 
                                          & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b))) 
                                      + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__add_cy))))));
    bufp->fullBit(oldp+114,(((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__result_add)) 
                             & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__cmp_r) 
                                | (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0)))));
    bufp->fullBit(oldp+115,((1U & (((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)) 
                                    & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                       ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0))) 
                                   | (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                       >> 1U) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0)))))));
    bufp->fullCData(oldp+116,((7U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi))),3);
    bufp->fullBit(oldp+117,((1U & (((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_0) 
                                    + ((IData)(vlSelfRef.__VdfgRegularize_h6e95ff9d_0_3) 
                                       + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r))) 
                                   >> 1U))));
    bufp->fullBit(oldp+118,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__q));
    bufp->fullBit(oldp+119,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__c_r));
    bufp->fullBit(oldp+120,(((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                               >> 4U) & ((0U == (3U 
                                                 & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))) 
                                         | (3U == (3U 
                                                   & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode))))) 
                             & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_cnt0))));
    bufp->fullCData(oldp+121,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi),8);
    bufp->fullIData(oldp+122,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dlo),24);
    bufp->fullBit(oldp+123,((1U & ((IData)((0U == (3U 
                                                   & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data))) 
                                   | ((IData)((0U == 
                                               (6U 
                                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt)))) 
                                      | (((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                              >> 2U)) 
                                          & (~ (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                                >> 1U))) 
                                         | (((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                                 >> 2U)) 
                                             & (~ vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data)) 
                                            | ((~ ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt) 
                                                   >> 1U)) 
                                               & (~ 
                                                  (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                                   >> 1U))))))))));
    bufp->fullBit(oldp+124,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__shift_en));
    bufp->fullBit(oldp+125,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__cnt_en));
    bufp->fullCData(oldp+126,((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__i_op_b) 
                                << 7U) | ((0x00000040U 
                                           & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
                                              >> 1U)) 
                                          | (0x0000003fU 
                                             & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dhi) 
                                                - (IData)(1U)))))),8);
    bufp->fullCData(oldp+127,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg2__DOT__dat_shamt),8);
    bufp->fullBit(oldp+128,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4));
    bufp->fullBit(oldp+129,((1U & (((1U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr) 
                                    + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__i_cnt2) 
                                       + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r))) 
                                   >> 1U))));
    bufp->fullBit(oldp+130,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4_cy_r));
    bufp->fullBit(oldp+131,((1U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a) 
                                   + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b) 
                                      + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r))))));
    bufp->fullBit(oldp+132,((1U & (((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a) 
                                    + ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b) 
                                       + (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r))) 
                                   >> 1U))));
    bufp->fullBit(oldp+133,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_offset_cy_r));
    bufp->fullBit(oldp+134,((1U & vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__wb_ibus_adr)));
    bufp->fullBit(oldp+135,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__jump)
                              ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__o_bad_pc)
                              : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__pc_plus_4))));
    bufp->fullBit(oldp+136,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_a));
    bufp->fullBit(oldp+137,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__ctrl__DOT__offset_b));
    bufp->fullIData(oldp+138,((vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                               >> 2U)),30);
    bufp->fullCData(oldp+139,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode),5);
    bufp->fullBit(oldp+140,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21));
    bufp->fullBit(oldp+141,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op22));
    bufp->fullBit(oldp+142,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26));
    bufp->fullBit(oldp+143,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__imm25));
    bufp->fullBit(oldp+144,(((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op20) 
                             | ((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op21)) 
                                & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__op26)))));
    bufp->fullIData(oldp+145,((vlSelfRef.serv_tb_top__DOT__wb_mem_rdt 
                               >> 7U)),25);
    bufp->fullBit(oldp+146,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm31));
    bufp->fullSData(oldp+147,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20),9);
    bufp->fullBit(oldp+148,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm7));
    bufp->fullCData(oldp+149,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm30_25),6);
    bufp->fullBit(oldp+150,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__signbit));
    bufp->fullBit(oldp+151,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__signbit));
    bufp->fullBit(oldp+152,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__mem_if__DOT__dat_valid));
    bufp->fullBit(oldp+153,((((~ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__i_init)) 
                              & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__o_rd_op)) 
                             & (0U != (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7)))));
    bufp->fullBit(oldp+154,((1U & (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                   >> 1U))));
    bufp->fullBit(oldp+155,((1U == (3U & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3) 
                                          >> 1U)))));
    bufp->fullBit(oldp+156,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__init_done));
    bufp->fullCData(oldp+157,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__o_cnt),3);
    bufp->fullCData(oldp+158,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__gen_cnt_w_eq_1__DOT__cnt_lsb),4);
    bufp->fullBit(oldp+159,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__ibus_cyc));
    bufp->fullBit(oldp+160,((IData)((((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                      >> 4U) & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__opcode) 
                                                | ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__alu__DOT__o_cmp) 
                                                   ^ (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__decode__DOT__funct3)))))));
    bufp->fullBit(oldp+161,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__state__DOT__last_init));
    bufp->fullBit(oldp+162,((0U != (vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__bufreg__DOT__data 
                                    >> 0x0000001eU))));
    bufp->fullBit(oldp+163,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rgnt));
    bufp->fullCData(oldp+164,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt),5);
    bufp->fullBit(oldp+165,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rtrig1));
    bufp->fullCData(oldp+166,((0x0000001fU & ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt) 
                                              - (IData)(4U)))),5);
    bufp->fullCData(oldp+167,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata0_r),2);
    bufp->fullCData(oldp+168,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wdata1_r),3);
    bufp->fullBit(oldp+169,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen0_r));
    bufp->fullBit(oldp+170,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__wen1_r));
    bufp->fullBit(oldp+171,((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))));
    bufp->fullCData(oldp+172,(((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                ? 0U : (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm11_7))),5);
    bufp->fullCData(oldp+173,((0x0000001fU & ((1U & (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rcnt))
                                               ? (IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm24_20)
                                               : ((IData)(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__cpu__DOT__immdec__DOT__gen_immdec_w_eq_1__DOT__imm19_12_20) 
                                                  >> 4U)))),5);
    bufp->fullCData(oldp+174,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata0),2);
    bufp->fullBit(oldp+175,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rdata1));
    bufp->fullBit(oldp+176,(vlSelfRef.serv_tb_top__DOT__u_serv__DOT__u_servile__DOT__rf_ram_if__DOT__rreq_r));
    bufp->fullIData(oldp+177,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__o_wb_dat),32);
    bufp->fullBit(oldp+178,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__ack));
    bufp->fullSData(oldp+179,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__clk_cnt),16);
    bufp->fullCData(oldp+180,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__bit_idx),4);
    bufp->fullSData(oldp+181,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__shifter),10);
    bufp->fullBit(oldp+182,(vlSelfRef.serv_tb_top__DOT__u_uart_dbg__DOT__busy));
    bufp->fullBit(oldp+183,(vlSelfRef.i_clk));
    bufp->fullBit(oldp+184,(vlSelfRef.i_rst));
    bufp->fullIData(oldp+185,(vlSelfRef.o_pc),32);
    bufp->fullBit(oldp+186,(vlSelfRef.o_pc_valid));
    bufp->fullIData(oldp+187,(vlSelfRef.o_gpio),32);
}
