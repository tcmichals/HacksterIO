# =============================================================================
# SPI Quadcopter FPGA Project - CMake Build System
# =============================================================================
#
# Supported Platforms:
#   - Tang Nano 20K (Gowin GW2AR-18) - OSS CAD Suite
#   - Arty S7-50 (Xilinx XC7S50) - Vivado
#
# Usage:
#   cmake -B build -DPLATFORM=tangnano20k
#   cmake --build build --target bitstream
#   cmake --build build --target upload
#
# =============================================================================

cmake_minimum_required(VERSION 3.20)
project(SPIQuadCopter VERSION 2.0.0 LANGUAGES NONE)

# -----------------------------------------------------------------------------
# Platform Selection
# -----------------------------------------------------------------------------
set(PLATFORM "tangnano20k" CACHE STRING "Target platform: tangnano20k | artys7")
set_property(CACHE PLATFORM PROPERTY STRINGS tangnano20k artys7)

message(STATUS "Building for platform: ${PLATFORM}")

# -----------------------------------------------------------------------------
# Common Configuration
# -----------------------------------------------------------------------------
set(BUILD_DIR ${CMAKE_BINARY_DIR})
set(RTL_DIR ${CMAKE_SOURCE_DIR}/src)
set(FIRMWARE_DIR ${CMAKE_SOURCE_DIR}/firmware)

# System clock (80 MHz for all platforms)
set(SYSTEM_CLOCK_HZ 80000000)

# -----------------------------------------------------------------------------
# RTL Source Files (shared across platforms)
# -----------------------------------------------------------------------------
set(RTL_SOURCES
    # SPI Slave
    ${CMAKE_SOURCE_DIR}/spiSlave/spi_slave.sv
    
    # Core system
    ${RTL_DIR}/spi_slave_wb_bridge.sv
    ${RTL_DIR}/wb_spisystem.sv
    ${RTL_DIR}/common_vexriscv_spi_top.sv
    ${RTL_DIR}/wb_ram.sv
    ${RTL_DIR}/wb_mux_5.v
    ${RTL_DIR}/wb_mux_6.v
    
    # Peripherals
    ${RTL_DIR}/wb_led_controller.sv
    ${RTL_DIR}/wb_debug_gpio.sv
    ${RTL_DIR}/wb_usb_uart.sv
    ${RTL_DIR}/wb_esc_uart.sv
    ${RTL_DIR}/wb_timer.sv
    ${RTL_DIR}/wb_dshot_mailbox.sv
    ${RTL_DIR}/wb_serial_dshot_mux.sv
    
    # PWM Decoder
    ${CMAKE_SOURCE_DIR}/pwmDecoder/pwmdecoder.v
    ${CMAKE_SOURCE_DIR}/pwmDecoder/pwmdecoder_wb.v
    
    # NeoPixel
    ${CMAKE_SOURCE_DIR}/neoPXStrip/sendPx_axis_flexible.sv
    ${CMAKE_SOURCE_DIR}/neoPXStrip/wb_neoPx.v
    
    # DSHOT
    ${CMAKE_SOURCE_DIR}/dshot/dshot_out.v
    ${CMAKE_SOURCE_DIR}/dshot/dshot_mailbox.sv
    
    # Version
    ${CMAKE_SOURCE_DIR}/version/wb_version.sv
    
    # UART cores
    ${CMAKE_SOURCE_DIR}/verilog-uart/rtl/uart_tx.v
    ${CMAKE_SOURCE_DIR}/verilog-uart/rtl/uart_rx.v
)

# VexRiscv CPU selection based on platform
# - tangnano20k: VexRiscv.v (debug bus interface)
# - artys7: VexRiscvJtag.v (hardware JTAG TAP)
if(PLATFORM STREQUAL "artys7")
    set(VEXRISCV_CPU_FILE ${CMAKE_SOURCE_DIR}/src/cpu/VexRiscvJtag.v)
    set(VEXRISCV_GENERATOR "GenSPICopterCpuJtag")
    set(VEXRISCV_GEN_FILE "VexRiscvJtag.v")
else()
    set(VEXRISCV_CPU_FILE ${CMAKE_SOURCE_DIR}/src/cpu/VexRiscv.v)
    set(VEXRISCV_GENERATOR "GenSPICopterCpu")
    set(VEXRISCV_GEN_FILE "VexRiscv.v")
endif()

list(APPEND RTL_SOURCES ${VEXRISCV_CPU_FILE})

# -----------------------------------------------------------------------------
# Platform-Specific Configuration
# -----------------------------------------------------------------------------
if(PLATFORM STREQUAL "tangnano20k")
    include(${CMAKE_SOURCE_DIR}/cmake/tangnano20k.cmake)
elseif(PLATFORM STREQUAL "artys7")
    include(${CMAKE_SOURCE_DIR}/cmake/artys7.cmake)
else()
    message(FATAL_ERROR "Unknown platform: ${PLATFORM}. Use tangnano20k or artys7")
endif()

# -----------------------------------------------------------------------------
# Firmware Build (VexRiscv C++)
# -----------------------------------------------------------------------------
option(BUILD_FIRMWARE "Build VexRiscv firmware" ON)

set(FIRMWARE_MEM ${BUILD_DIR}/firmware/firmware.mem)

if(BUILD_FIRMWARE)
    # Search paths for RISC-V toolchain
    file(GLOB XPACK_RISCV_DIRS "$ENV{HOME}/.local/tools/xpack-riscv-none-elf-gcc-*/bin")
    set(RISCV_HINTS
        ${XPACK_RISCV_DIRS}
        $ENV{HOME}/.local/xpack-riscv/bin
        $ENV{HOME}/.tools/xpack-riscv/bin
        /opt/riscv/bin
        /opt/xpack-riscv/bin
    )
    
    # Find RISC-V toolchain
    find_program(RISCV_GCC riscv-none-elf-gcc HINTS ${RISCV_HINTS})
    if(NOT RISCV_GCC)
        find_program(RISCV_GCC riscv32-unknown-elf-gcc HINTS ${RISCV_HINTS})
    endif()
    
    if(RISCV_GCC)
        message(STATUS "Found RISC-V GCC: ${RISCV_GCC}")
        
        # Firmware build directory
        set(FIRMWARE_BUILD_DIR ${BUILD_DIR}/firmware)
        
        # Configure firmware (runs only once)
        add_custom_command(
            OUTPUT ${FIRMWARE_BUILD_DIR}/CMakeCache.txt
            COMMAND ${CMAKE_COMMAND} -E make_directory ${FIRMWARE_BUILD_DIR}
            COMMAND ${CMAKE_COMMAND}
                -DCMAKE_TOOLCHAIN_FILE=${FIRMWARE_DIR}/riscv32-toolchain.cmake
                -DCPU_CLOCK_HZ=${SYSTEM_CLOCK_HZ}
                -DRAM_SIZE_KB=32
                -S ${FIRMWARE_DIR}
                -B ${FIRMWARE_BUILD_DIR}
            DEPENDS ${FIRMWARE_DIR}/CMakeLists.txt
            COMMENT "Configuring VexRiscv firmware..."
        )
        
        # Destination for synthesis (yosys reads from source tree)
        set(FIRMWARE_MEM_SRC ${CMAKE_SOURCE_DIR}/firmware/firmware.mem)
        
        # Build firmware (produces .mem file for FPGA)
        add_custom_command(
            OUTPUT ${FIRMWARE_MEM} ${FIRMWARE_MEM_SRC}
            COMMAND ${CMAKE_COMMAND} --build ${FIRMWARE_BUILD_DIR} --parallel
            # Copy to source tree for yosys (runs from CMAKE_SOURCE_DIR)
            COMMAND ${CMAKE_COMMAND} -E copy ${FIRMWARE_MEM} ${FIRMWARE_MEM_SRC}
            DEPENDS ${FIRMWARE_BUILD_DIR}/CMakeCache.txt
                    ${FIRMWARE_DIR}/src/main.cpp
                    ${FIRMWARE_DIR}/src/msp_loop.cpp
                    ${FIRMWARE_DIR}/src/msp_bridge.cpp
                    ${FIRMWARE_DIR}/src/fourway.cpp
                    ${FIRMWARE_DIR}/src/syscalls.cpp
                    ${FIRMWARE_DIR}/include/wb_regs.h
                    ${FIRMWARE_DIR}/include/FreeRTOSConfig.h
            WORKING_DIRECTORY ${FIRMWARE_BUILD_DIR}
            COMMENT "Building VexRiscv firmware..."
        )
        
        # Firmware target for standalone build
        add_custom_target(firmware
            DEPENDS ${FIRMWARE_MEM}
            COMMENT "Firmware build complete: ${FIRMWARE_MEM}"
        )
    else()
        message(WARNING "RISC-V toolchain not found - firmware will not be built")
        # Create dummy target
        add_custom_target(firmware
            COMMENT "Firmware skipped - no RISC-V toolchain"
        )
    endif()
else()
    add_custom_target(firmware
        COMMENT "Firmware disabled (BUILD_FIRMWARE=OFF)"
    )
endif()

# -----------------------------------------------------------------------------
# VexRiscv CPU Generation (optional - requires Java 11/17 + sbt)
# -----------------------------------------------------------------------------
# Platform-specific VexRiscv:
#   tangnano20k: VexRiscv.v (debug bus)
#   artys7:      VexRiscvJtag.v (hardware JTAG TAP)
#
# Generated files should be committed to git.

find_program(SBT sbt)
if(SBT AND NOT TARGET generate-cpu)
    add_custom_target(generate-cpu
        COMMAND ${SBT} "runMain vexriscv.demo.${VEXRISCV_GENERATOR}"
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_SOURCE_DIR}/src/cpu
        COMMAND ${CMAKE_COMMAND} -E rename
            ${CMAKE_SOURCE_DIR}/${VEXRISCV_GEN_FILE}
            ${CMAKE_SOURCE_DIR}/src/cpu/${VEXRISCV_GEN_FILE}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Generating ${VEXRISCV_GEN_FILE} (${VEXRISCV_GENERATOR})"
    )
endif()

# Check if required VexRiscv file exists
if(NOT EXISTS ${VEXRISCV_CPU_FILE})
    message(WARNING "${VEXRISCV_GEN_FILE} not found at ${VEXRISCV_CPU_FILE}")
    message(WARNING "Run: cmake --build build --target generate-cpu")
endif()

# -----------------------------------------------------------------------------
# Simulation Targets (iverilog)
# -----------------------------------------------------------------------------
find_program(IVERILOG iverilog)
find_program(VVP vvp)

if(IVERILOG AND VVP)
    # SPI-WB testbench
    add_custom_target(tb-spi-wb
        COMMAND ${IVERILOG} -g2012 -o ${BUILD_DIR}/tb_spi_wb.vvp
            -I${RTL_DIR}
            ${CMAKE_SOURCE_DIR}/src/tb/spi_slave_wb_bridge_tb.sv
            ${CMAKE_SOURCE_DIR}/src/spi_slave_wb_bridge.sv
            ${CMAKE_SOURCE_DIR}/spiSlave/spi_slave.sv
        COMMAND ${VVP} ${BUILD_DIR}/tb_spi_wb.vvp
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running SPI-WB testbench"
    )
    
    # Version testbench
    add_custom_target(tb-version
        COMMAND ${IVERILOG} -g2012 -o ${BUILD_DIR}/tb_version.vvp
            ${CMAKE_SOURCE_DIR}/version/wb_version_tb.sv
            ${CMAKE_SOURCE_DIR}/version/wb_version.sv
        COMMAND ${VVP} ${BUILD_DIR}/tb_version.vvp
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running version testbench"
    )
    
    # DSHOT testbench
    add_custom_target(tb-dshot
        COMMAND ${IVERILOG} -g2012 -o ${BUILD_DIR}/tb_dshot.vvp
            ${CMAKE_SOURCE_DIR}/dshot/dshot_tb.v
            ${CMAKE_SOURCE_DIR}/dshot/dshot_out.v
            ${CMAKE_SOURCE_DIR}/dshot/dshot_mailbox.sv
        COMMAND ${VVP} ${BUILD_DIR}/tb_dshot.vvp
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running DSHOT testbench"
    )
    
    # PWM decoder testbench
    add_custom_target(tb-pwm
        COMMAND ${IVERILOG} -g2012 -o ${BUILD_DIR}/tb_pwm.vvp
            ${CMAKE_SOURCE_DIR}/pwmDecoder/pwmdecoder_tb.v
            ${CMAKE_SOURCE_DIR}/pwmDecoder/pwmdecoder.v
        COMMAND ${VVP} ${BUILD_DIR}/tb_pwm.vvp
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Running PWM decoder testbench"
    )
    
    # All unit testbenches
    add_custom_target(test
        DEPENDS tb-spi-wb tb-version tb-dshot tb-pwm
        COMMENT "Running all unit testbenches"
    )
endif()

# -----------------------------------------------------------------------------
# Verilator Full System Simulation
# -----------------------------------------------------------------------------
find_program(VERILATOR verilator)

if(VERILATOR)
    message(STATUS "Verilator found: ${VERILATOR}")
    
    set(SIM_DIR ${CMAKE_SOURCE_DIR}/sim)
    set(VEXRISCV_V ${CMAKE_SOURCE_DIR}/src/cpu/VexRiscv.v)
    
    # Full system simulation with VexRiscv
    add_custom_target(sim
        COMMAND ${CMAKE_COMMAND} -E echo "Running Verilator full system simulation..."
        COMMAND ${VERILATOR}
            --cc --exe --build -j 0
            --trace-fst
            -Wno-fatal -Wno-WIDTH -Wno-CASEINCOMPLETE
            --top-module system_tb
            -CFLAGS "-std=c++17"
            -I${RTL_DIR}
            -I${CMAKE_SOURCE_DIR}/src/cpu
            ${SIM_DIR}/system_tb.sv
            ${RTL_SOURCES}
            ${CMAKE_SOURCE_DIR}/src/common_vexriscv_spi_top.sv
            ${CMAKE_SOURCE_DIR}/src/wb_ram.sv
            ${VEXRISCV_V}
            ${SIM_DIR}/sim_main.cpp
            -o Vsystem_tb
        COMMAND ./obj_dir/Vsystem_tb
        WORKING_DIRECTORY ${BUILD_DIR}
        COMMENT "Full system simulation with Verilator"
    )
else()
    message(WARNING "Verilator not found - full system simulation disabled")
    add_custom_target(sim
        COMMAND ${CMAKE_COMMAND} -E echo "Verilator not installed. Install with:"
        COMMAND ${CMAKE_COMMAND} -E echo "  apt install verilator"
        COMMENT "Verilator required for full simulation"
    )
endif()

# -----------------------------------------------------------------------------
# Clean Target
# -----------------------------------------------------------------------------
add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${BUILD_DIR}
    COMMENT "Removing all build artifacts"
)

# -----------------------------------------------------------------------------
# Help Target
# -----------------------------------------------------------------------------
add_custom_target(help-build
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "SPI Quadcopter FPGA Build System"
    COMMAND ${CMAKE_COMMAND} -E echo "================================"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Platforms:"
    COMMAND ${CMAKE_COMMAND} -E echo "  tangnano20k  - Tang Nano 20K [Gowin GW2AR-18]"
    COMMAND ${CMAKE_COMMAND} -E echo "  artys7       - Arty S7-50 [Xilinx XC7S50]"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Build targets:"
    COMMAND ${CMAKE_COMMAND} -E echo "  bitstream    - Build FPGA bitstream"
    COMMAND ${CMAKE_COMMAND} -E echo "  upload       - Program the FPGA board"
    COMMAND ${CMAKE_COMMAND} -E echo "  firmware     - Build VexRiscv firmware only"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Simulation targets [iverilog]:"
    COMMAND ${CMAKE_COMMAND} -E echo "  test         - Run all unit testbenches"
    COMMAND ${CMAKE_COMMAND} -E echo "  tb-spi-wb    - SPI-WB bridge testbench"
    COMMAND ${CMAKE_COMMAND} -E echo "  tb-version   - Version register testbench"
    COMMAND ${CMAKE_COMMAND} -E echo "  tb-dshot     - DSHOT protocol testbench"
    COMMAND ${CMAKE_COMMAND} -E echo "  tb-pwm       - PWM decoder testbench"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Full system simulation [Verilator]:"
    COMMAND ${CMAKE_COMMAND} -E echo "  sim          - Full VexRiscv system simulation with FST trace"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "Usage:"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake -B build -DPLATFORM=tangnano20k"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build build --target bitstream"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build build --target upload"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build build --target sim"
    COMMAND ${CMAKE_COMMAND} -E echo ""
)
