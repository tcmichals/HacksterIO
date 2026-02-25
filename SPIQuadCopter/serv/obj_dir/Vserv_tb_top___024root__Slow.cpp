// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vserv_tb_top.h for the primary calling header

#include "Vserv_tb_top__pch.h"

void Vserv_tb_top___024root___ctor_var_reset(Vserv_tb_top___024root* vlSelf);

Vserv_tb_top___024root::Vserv_tb_top___024root(Vserv_tb_top__Syms* symsp, const char* namep)
 {
    vlSymsp = symsp;
    vlNamep = strdup(namep);
    // Reset structure values
    Vserv_tb_top___024root___ctor_var_reset(this);
}

void Vserv_tb_top___024root::__Vconfigure(bool first) {
    (void)first;  // Prevent unused variable warning
}

Vserv_tb_top___024root::~Vserv_tb_top___024root() {
    VL_DO_DANGLING(std::free(const_cast<char*>(vlNamep)), vlNamep);
}
