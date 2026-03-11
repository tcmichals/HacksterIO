/**
 * sim_main.cpp - Verilator Simulation Main
 *
 * Drives the full system simulation with VexRiscv running firmware.
 */

#include <verilated.h>
#include <verilated_fst_c.h>
#include "Vsystem_tb.h"
#include <iostream>
#include <cstdint>

// Simulation time (in ns)
vluint64_t main_time = 0;

double sc_time_stamp() {
    return main_time;
}

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    
    // Create DUT
    Vsystem_tb* top = new Vsystem_tb;
    
    // Enable trace
    Verilated::traceEverOn(true);
    VerilatedFstC* tfp = new VerilatedFstC;
    top->trace(tfp, 99);
    tfp->open("system_tb.fst");
    
    std::cout << "===========================================" << std::endl;
    std::cout << "Verilator Full System Simulation" << std::endl;
    std::cout << "===========================================" << std::endl;
    
    // Run simulation
    const vluint64_t max_time = 100'000'000;  // 100ms
    
    while (!Verilated::gotFinish() && main_time < max_time) {
        top->eval();
        tfp->dump(main_time);
        main_time += 1;  // 1ns step
        
        // Progress indicator every 10ms
        if (main_time % 10'000'000 == 0) {
            std::cout << "[" << main_time/1000000 << "ms] Simulating..." << std::endl;
        }
    }
    
    std::cout << "===========================================" << std::endl;
    std::cout << "Simulation complete at " << main_time << " ns" << std::endl;
    std::cout << "Trace: system_tb.fst" << std::endl;
    std::cout << "===========================================" << std::endl;
    
    tfp->close();
    delete tfp;
    delete top;
    
    return 0;
}
