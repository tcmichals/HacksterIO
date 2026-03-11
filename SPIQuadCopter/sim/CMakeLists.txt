# =============================================================================
# Simulation Build - CMake Configuration
# =============================================================================
# Supports:
#   - Verilator (full system simulation with VexRiscv)
#   - iverilog (unit tests for peripherals)
# =============================================================================

cmake_minimum_required(VERSION 3.16)

# -----------------------------------------------------------------------------
# Find Simulation Tools
# -----------------------------------------------------------------------------
find_program(VERILATOR verilator)
find_program(IVERILOG iverilog)
find_program(VVP vvp)

# -----------------------------------------------------------------------------
# RTL Source Files
# -----------------------------------------------------------------------------
set(PROJECT_ROOT ${CMAKE_CURRENT_SOURCE_DIR}/..)

set(RTL_SOURCES
    ${PROJECT_ROOT}/src/common_vexriscv_spi_top.sv
    ${PROJECT_ROOT}/src/wb_ram.sv
    ${PROJECT_ROOT}/src/spi_slave_wb_bridge.sv
    ${PROJECT_ROOT}/src/wb_spisystem.sv
    ${PROJECT_ROOT}/src/wb_mux_5.v
    ${PROJECT_ROOT}/src/wb_mux_6.v
    ${PROJECT_ROOT}/src/wb_led_controller.sv
    ${PROJECT_ROOT}/src/wb_debug_gpio.sv
    ${PROJECT_ROOT}/src/wb_usb_uart.sv
    ${PROJECT_ROOT}/src/wb_esc_uart.sv
    ${PROJECT_ROOT}/src/wb_timer.sv
    ${PROJECT_ROOT}/src/wb_dshot_mailbox.sv
    ${PROJECT_ROOT}/src/wb_serial_dshot_mux.sv
    ${PROJECT_ROOT}/spiSlave/spi_slave.sv
    ${PROJECT_ROOT}/pwmDecoder/pwmdecoder.v
    ${PROJECT_ROOT}/pwmDecoder/pwmdecoder_wb.v
    ${PROJECT_ROOT}/neoPXStrip/sendPx_axis_flexible.sv
    ${PROJECT_ROOT}/neoPXStrip/wb_neoPx.v
    ${PROJECT_ROOT}/dshot/dshot_out.v
    ${PROJECT_ROOT}/dshot/dshot_mailbox.sv
    ${PROJECT_ROOT}/version/wb_version.sv
    ${PROJECT_ROOT}/verilog-uart/rtl/uart_tx.v
    ${PROJECT_ROOT}/verilog-uart/rtl/uart_rx.v
)

# VexRiscv (generated Verilog)
set(VEXRISCV_V ${PROJECT_ROOT}/src/cpu/VexRiscv.v)

# -----------------------------------------------------------------------------
# Verilator Full System Simulation
# -----------------------------------------------------------------------------
if(VERILATOR)
    message(STATUS "Verilator found: ${VERILATOR}")
    
    set(VERILATOR_FLAGS
        --cc
        --exe
        --build
        -j 0
        --trace
        --trace-fst
        -Wno-fatal
        -Wno-WIDTH
        -Wno-CASEINCOMPLETE
        --top-module system_tb
        -CFLAGS "-std=c++17"
        -I${PROJECT_ROOT}/src
        -I${PROJECT_ROOT}/src/cpu
    )
    
    # Check if VexRiscv.v exists
    if(EXISTS ${VEXRISCV_V})
        add_custom_target(verilator-sim
            COMMAND ${VERILATOR} ${VERILATOR_FLAGS}
                ${CMAKE_CURRENT_SOURCE_DIR}/system_tb.sv
                ${RTL_SOURCES}
                ${VEXRISCV_V}
                ${CMAKE_CURRENT_SOURCE_DIR}/sim_main.cpp
                -o Vsystem_tb
            COMMAND ./obj_dir/Vsystem_tb
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            COMMENT "Running Verilator full system simulation"
        )
    else()
        add_custom_target(verilator-sim
            COMMAND ${CMAKE_COMMAND} -E echo "ERROR: VexRiscv.v not found!"
            COMMAND ${CMAKE_COMMAND} -E echo "Run: ./scripts/generate_vexriscv.sh"
            COMMAND ${CMAKE_COMMAND} -E false
            COMMENT "VexRiscv Verilog required"
        )
    endif()
else()
    message(WARNING "Verilator not found - full system simulation disabled")
endif()

# -----------------------------------------------------------------------------
# iverilog Unit Tests
# -----------------------------------------------------------------------------
if(IVERILOG AND VVP)
    message(STATUS "iverilog found: ${IVERILOG}")
    
    # SPI-WB Bridge Test
    add_custom_target(tb-spi-wb
        COMMAND ${IVERILOG} -g2012 -o tb_spi_wb.vvp
            -I${PROJECT_ROOT}/src
            ${PROJECT_ROOT}/src/tb/spi_slave_wb_bridge_tb.sv
            ${PROJECT_ROOT}/src/spi_slave_wb_bridge.sv
            ${PROJECT_ROOT}/spiSlave/spi_slave.sv
        COMMAND ${VVP} tb_spi_wb.vvp
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Running SPI-WB bridge testbench"
    )
    
    # Version Register Test
    add_custom_target(tb-version
        COMMAND ${IVERILOG} -g2012 -o tb_version.vvp
            ${PROJECT_ROOT}/version/wb_version_tb.sv
            ${PROJECT_ROOT}/version/wb_version.sv
        COMMAND ${VVP} tb_version.vvp
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Running version register testbench"
    )
    
    # DSHOT Test
    add_custom_target(tb-dshot
        COMMAND ${IVERILOG} -g2012 -o tb_dshot.vvp
            ${PROJECT_ROOT}/dshot/dshot_tb.v
            ${PROJECT_ROOT}/dshot/dshot_out.v
            ${PROJECT_ROOT}/dshot/dshot_mailbox.sv
        COMMAND ${VVP} tb_dshot.vvp
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Running DSHOT testbench"
    )
    
    # PWM Decoder Test
    add_custom_target(tb-pwm
        COMMAND ${IVERILOG} -g2012 -o tb_pwm.vvp
            ${PROJECT_ROOT}/pwmDecoder/pwmdecoder_tb.v
            ${PROJECT_ROOT}/pwmDecoder/pwmdecoder.v
        COMMAND ${VVP} tb_pwm.vvp
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        COMMENT "Running PWM decoder testbench"
    )
    
    # All unit tests
    add_custom_target(unit-tests
        DEPENDS tb-spi-wb tb-version tb-dshot tb-pwm
        COMMENT "All unit tests complete"
    )
else()
    message(WARNING "iverilog not found - unit tests disabled")
endif()
