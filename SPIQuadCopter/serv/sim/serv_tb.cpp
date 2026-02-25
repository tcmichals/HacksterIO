// SERV Verilator Testbench
// Simple test to verify SERV core integration

#include <verilated.h>
#include <verilated_vcd_c.h>
#include "Vserv_tb_top.h"

#include <cstdio>
#include <cstdlib>

vluint64_t main_time = 0;
vluint64_t sim_end_time = 500000; // 500k cycles default

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    
    // Check for +cycles=N argument
    const char* arg = Verilated::commandArgsPlusMatch("cycles=");
    if (arg[0]) {
        sim_end_time = atoll(arg + 8);
        printf("Running for %lu cycles\n", sim_end_time);
    }
    
    // Create DUT
    Vserv_tb_top* dut = new Vserv_tb_top;
    
    // Setup VCD tracing
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    dut->trace(tfp, 99);
    tfp->open("serv_tb.vcd");
    
    // Initialize signals
    dut->i_clk = 0;
    dut->i_rst = 1;
    
    printf("SERV Wishbone Testbench\n");
    printf("=======================\n");
    
    // Reset for 10 cycles
    for (int i = 0; i < 20; i++) {
        dut->i_clk = !dut->i_clk;
        dut->eval();
        tfp->dump(main_time);
        main_time++;
    }
    
    // Release reset
    dut->i_rst = 0;
    printf("Reset released at t=%lu\n", main_time);
    
    // Main simulation loop
    vluint64_t instructions = 0;
    uint32_t last_pc = 0xFFFFFFFF;
    
    while (main_time < sim_end_time && !Verilated::gotFinish()) {
        // Toggle clock
        dut->i_clk = !dut->i_clk;
        dut->eval();
        
        // On rising clock edge, check for activity
        if (dut->i_clk) {
            // Track instruction fetches via debug signals
            if (dut->o_pc_valid) {
                uint32_t pc = dut->o_pc;
                if (pc != last_pc) {
                    instructions++;
                    last_pc = pc;
                    if (instructions <= 10 || instructions % 100 == 0) {
                        printf("  Instruction %lu at PC=0x%08x, t=%lu\n", 
                               instructions, pc, main_time);
                    }
                }
            }
        }
        
        tfp->dump(main_time);
        main_time++;
    }
    
    printf("\nSimulation complete\n");
    printf("  Total time: %lu cycles\n", main_time);
    printf("  Instructions executed: ~%lu\n", instructions);
    if (instructions > 0) {
        printf("  Avg cycles/instruction: %.1f\n", (double)main_time / instructions);
    }
    
    tfp->close();
    delete dut;
    
    return 0;
}
