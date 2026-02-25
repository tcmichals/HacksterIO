// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Symbol table internal header
//
// Internal details; most calling programs do not need this header,
// unless using verilator public meta comments.

#ifndef VERILATED_VSERV_TB_TOP__SYMS_H_
#define VERILATED_VSERV_TB_TOP__SYMS_H_  // guard

#include "verilated.h"

// INCLUDE MODEL CLASS

#include "Vserv_tb_top.h"

// INCLUDE MODULE CLASSES
#include "Vserv_tb_top___024root.h"

// SYMS CLASS (contains all model state)
class alignas(VL_CACHE_LINE_BYTES) Vserv_tb_top__Syms final : public VerilatedSyms {
  public:
    // INTERNAL STATE
    Vserv_tb_top* const __Vm_modelp;
    bool __Vm_activity = false;  ///< Used by trace routines to determine change occurred
    uint32_t __Vm_baseCode = 0;  ///< Used by trace routines when tracing multiple models
    VlDeleter __Vm_deleter;
    bool __Vm_didInit = false;

    // MODULE INSTANCE STATE
    Vserv_tb_top___024root         TOP;

    // CONSTRUCTORS
    Vserv_tb_top__Syms(VerilatedContext* contextp, const char* namep, Vserv_tb_top* modelp);
    ~Vserv_tb_top__Syms();

    // METHODS
    const char* name() const { return TOP.vlNamep; }
};

#endif  // guard
