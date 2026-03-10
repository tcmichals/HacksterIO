# VexRiscv Firmware Build (C++ with FreeRTOS)
# Target: RV32IMC (Integer + Multiply + Compressed)
cmake_minimum_required(VERSION 3.16)

# Must set toolchain before project()
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/riscv32-toolchain.cmake)

project(vexriscv_firmware
    VERSION 1.0.0
    LANGUAGES C CXX ASM
)

# ============================================================================
# Build Options
# ============================================================================
option(USE_FREERTOS "Build with FreeRTOS support" ON)
option(BUILD_TESTS "Build host-side unit tests" OFF)

set(CPU_CLOCK_HZ 80000000 CACHE STRING "CPU clock frequency in Hz")
set(RAM_SIZE_KB 32 CACHE STRING "RAM size in KB")

# ============================================================================
# Compiler Settings for RV32IMC
# ============================================================================
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Common flags for RV32IMC
set(RISCV_ARCH "rv32imc")
set(RISCV_ABI "ilp32")

set(COMMON_FLAGS
    -march=${RISCV_ARCH}
    -mabi=${RISCV_ABI}
    -mcmodel=medany
    -ffunction-sections
    -fdata-sections
    -fno-common
    -fno-exceptions
    -fno-rtti
    -Wall
    -Wextra
    -Os
)

# Linker flags
set(LINKER_SCRIPT ${CMAKE_CURRENT_SOURCE_DIR}/scripts/link.ld)
set(LINKER_FLAGS
    -T${LINKER_SCRIPT}
    -nostartfiles
    -Wl,--gc-sections
    -Wl,-Map=${CMAKE_BINARY_DIR}/firmware.map
    -Wl,--print-memory-usage
)

add_compile_options(${COMMON_FLAGS})
add_link_options(${COMMON_FLAGS} ${LINKER_FLAGS})

# Definitions
add_compile_definitions(
    CPU_CLOCK_HZ=${CPU_CLOCK_HZ}
    RAM_SIZE_KB=${RAM_SIZE_KB}
)

# ============================================================================
# Source Files
# ============================================================================
set(STARTUP_SOURCES
    scripts/crt0.S
)

set(FIRMWARE_SOURCES
    src/main.cpp
    src/msp_bridge.cpp
    src/msp_loop.cpp
    src/fourway.cpp
    src/syscalls.cpp
)

# ============================================================================
# FreeRTOS (optional, static allocation only - no heap manager)
# ============================================================================
if(USE_FREERTOS)
    set(FREERTOS_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../freertos-kernel)
    
    if(EXISTS ${FREERTOS_DIR})
        add_compile_definitions(USE_FREERTOS=1)
        
        # Static allocation only - NO heap_*.c needed
        set(FREERTOS_SOURCES
            ${FREERTOS_DIR}/tasks.c
            ${FREERTOS_DIR}/queue.c
            ${FREERTOS_DIR}/list.c
            ${FREERTOS_DIR}/portable/GCC/RISC-V/port.c
            ${FREERTOS_DIR}/portable/GCC/RISC-V/portASM.S
        )
        
        set(FREERTOS_INCLUDES
            ${FREERTOS_DIR}/include
            ${FREERTOS_DIR}/portable/GCC/RISC-V
            ${FREERTOS_DIR}/portable/GCC/RISC-V/chip_specific_extensions/RV32I_CLINT_no_extensions
            ${CMAKE_CURRENT_SOURCE_DIR}/include  # FreeRTOSConfig.h
        )
    else()
        message(WARNING "FreeRTOS not found at ${FREERTOS_DIR}, building without RTOS")
        set(USE_FREERTOS OFF)
    endif()
endif()

# ============================================================================
# Firmware Executable
# ============================================================================
add_executable(firmware
    ${STARTUP_SOURCES}
    ${FIRMWARE_SOURCES}
    ${FREERTOS_SOURCES}
)

target_include_directories(firmware PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${FREERTOS_INCLUDES}
)

# Ensure linker script dependency
set_target_properties(firmware PROPERTIES
    LINK_DEPENDS ${LINKER_SCRIPT}
    SUFFIX ".elf"
)

# ============================================================================
# Post-Build: Generate .bin and .hex
# ============================================================================
set(OBJCOPY ${CMAKE_OBJCOPY})
set(OBJDUMP ${CMAKE_OBJDUMP})
set(SIZE ${CMAKE_SIZE})

add_custom_command(TARGET firmware POST_BUILD
    COMMAND ${SIZE} firmware.elf
    COMMAND ${OBJCOPY} -O binary firmware.elf firmware.bin
    COMMAND ${OBJCOPY} -O ihex firmware.elf firmware.hex
    COMMAND ${OBJDUMP} -d -S firmware.elf > firmware.dis
    COMMAND ${CMAKE_COMMAND} -E echo "Generated: firmware.elf, firmware.bin, firmware.hex, firmware.dis"
    WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
    COMMENT "Generating binary outputs"
)

# ============================================================================
# Memory file for FPGA initialization (optional)
# ============================================================================
add_custom_target(firmware_mem
    COMMAND python3 ${CMAKE_CURRENT_SOURCE_DIR}/scripts/bin2mem.py
            ${CMAKE_BINARY_DIR}/firmware.bin
            ${CMAKE_BINARY_DIR}/firmware.mem
    DEPENDS firmware
    COMMENT "Generating firmware.mem for FPGA"
)

# ============================================================================
# Print configuration
# ============================================================================
message(STATUS "=== VexRiscv Firmware Configuration ===")
message(STATUS "  Architecture: ${RISCV_ARCH}")
message(STATUS "  ABI: ${RISCV_ABI}")
message(STATUS "  CPU Clock: ${CPU_CLOCK_HZ} Hz")
message(STATUS "  RAM Size: ${RAM_SIZE_KB} KB")
message(STATUS "  FreeRTOS: ${USE_FREERTOS}")
message(STATUS "========================================")
