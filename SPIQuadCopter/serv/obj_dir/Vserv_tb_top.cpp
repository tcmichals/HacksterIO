// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Model implementation (design independent parts)

#include "Vserv_tb_top__pch.h"
#include "verilated_vcd_c.h"

//============================================================
// Constructors

Vserv_tb_top::Vserv_tb_top(VerilatedContext* _vcontextp__, const char* _vcname__)
    : VerilatedModel{*_vcontextp__}
    , vlSymsp{new Vserv_tb_top__Syms(contextp(), _vcname__, this)}
    , i_clk{vlSymsp->TOP.i_clk}
    , i_rst{vlSymsp->TOP.i_rst}
    , o_pc_valid{vlSymsp->TOP.o_pc_valid}
    , o_pc{vlSymsp->TOP.o_pc}
    , o_gpio{vlSymsp->TOP.o_gpio}
    , rootp{&(vlSymsp->TOP)}
{
    // Register model with the context
    contextp()->addModel(this);
    contextp()->traceBaseModelCbAdd(
        [this](VerilatedTraceBaseC* tfp, int levels, int options) { traceBaseModel(tfp, levels, options); });
}

Vserv_tb_top::Vserv_tb_top(const char* _vcname__)
    : Vserv_tb_top(Verilated::threadContextp(), _vcname__)
{
}

//============================================================
// Destructor

Vserv_tb_top::~Vserv_tb_top() {
    delete vlSymsp;
}

//============================================================
// Evaluation function

#ifdef VL_DEBUG
void Vserv_tb_top___024root___eval_debug_assertions(Vserv_tb_top___024root* vlSelf);
#endif  // VL_DEBUG
void Vserv_tb_top___024root___eval_static(Vserv_tb_top___024root* vlSelf);
void Vserv_tb_top___024root___eval_initial(Vserv_tb_top___024root* vlSelf);
void Vserv_tb_top___024root___eval_settle(Vserv_tb_top___024root* vlSelf);
void Vserv_tb_top___024root___eval(Vserv_tb_top___024root* vlSelf);

void Vserv_tb_top::eval_step() {
    VL_DEBUG_IF(VL_DBG_MSGF("+++++TOP Evaluate Vserv_tb_top::eval_step\n"); );
#ifdef VL_DEBUG
    // Debug assertions
    Vserv_tb_top___024root___eval_debug_assertions(&(vlSymsp->TOP));
#endif  // VL_DEBUG
    vlSymsp->__Vm_activity = true;
    vlSymsp->__Vm_deleter.deleteAll();
    if (VL_UNLIKELY(!vlSymsp->__Vm_didInit)) {
        vlSymsp->__Vm_didInit = true;
        VL_DEBUG_IF(VL_DBG_MSGF("+ Initial\n"););
        Vserv_tb_top___024root___eval_static(&(vlSymsp->TOP));
        Vserv_tb_top___024root___eval_initial(&(vlSymsp->TOP));
        Vserv_tb_top___024root___eval_settle(&(vlSymsp->TOP));
    }
    VL_DEBUG_IF(VL_DBG_MSGF("+ Eval\n"););
    Vserv_tb_top___024root___eval(&(vlSymsp->TOP));
    // Evaluate cleanup
    Verilated::endOfEval(vlSymsp->__Vm_evalMsgQp);
}

//============================================================
// Events and timing
bool Vserv_tb_top::eventsPending() { return false; }

uint64_t Vserv_tb_top::nextTimeSlot() {
    VL_FATAL_MT(__FILE__, __LINE__, "", "No delays in the design");
    return 0;
}

//============================================================
// Utilities

const char* Vserv_tb_top::name() const {
    return vlSymsp->name();
}

//============================================================
// Invoke final blocks

void Vserv_tb_top___024root___eval_final(Vserv_tb_top___024root* vlSelf);

VL_ATTR_COLD void Vserv_tb_top::final() {
    Vserv_tb_top___024root___eval_final(&(vlSymsp->TOP));
}

//============================================================
// Implementations of abstract methods from VerilatedModel

const char* Vserv_tb_top::hierName() const { return vlSymsp->name(); }
const char* Vserv_tb_top::modelName() const { return "Vserv_tb_top"; }
unsigned Vserv_tb_top::threads() const { return 1; }
void Vserv_tb_top::prepareClone() const { contextp()->prepareClone(); }
void Vserv_tb_top::atClone() const {
    contextp()->threadPoolpOnClone();
}
std::unique_ptr<VerilatedTraceConfig> Vserv_tb_top::traceConfig() const {
    return std::unique_ptr<VerilatedTraceConfig>{new VerilatedTraceConfig{false, false, false}};
};

//============================================================
// Trace configuration

void Vserv_tb_top___024root__trace_decl_types(VerilatedVcd* tracep);

void Vserv_tb_top___024root__trace_init_top(Vserv_tb_top___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD static void trace_init(void* voidSelf, VerilatedVcd* tracep, uint32_t code) {
    // Callback from tracep->open()
    Vserv_tb_top___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vserv_tb_top___024root*>(voidSelf);
    Vserv_tb_top__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (!vlSymsp->_vm_contextp__->calcUnusedSigs()) {
        VL_FATAL_MT(__FILE__, __LINE__, __FILE__,
            "Turning on wave traces requires Verilated::traceEverOn(true) call before time 0.");
    }
    vlSymsp->__Vm_baseCode = code;
    tracep->pushPrefix(vlSymsp->name(), VerilatedTracePrefixType::SCOPE_MODULE);
    Vserv_tb_top___024root__trace_decl_types(tracep);
    Vserv_tb_top___024root__trace_init_top(vlSelf, tracep);
    tracep->popPrefix();
}

VL_ATTR_COLD void Vserv_tb_top___024root__trace_register(Vserv_tb_top___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vserv_tb_top::traceBaseModel(VerilatedTraceBaseC* tfp, int levels, int options) {
    (void)levels; (void)options;
    VerilatedVcdC* const stfp = dynamic_cast<VerilatedVcdC*>(tfp);
    if (VL_UNLIKELY(!stfp)) {
        vl_fatal(__FILE__, __LINE__, __FILE__,"'Vserv_tb_top::trace()' called on non-VerilatedVcdC object;"
            " use --trace-fst with VerilatedFst object, and --trace-vcd with VerilatedVcd object");
    }
    stfp->spTrace()->addModel(this);
    stfp->spTrace()->addInitCb(&trace_init, &(vlSymsp->TOP));
    Vserv_tb_top___024root__trace_register(&(vlSymsp->TOP), stfp->spTrace());
}
