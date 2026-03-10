# CMake toolchain file for RISC-V 32-bit (RV32IMC)
# Works with xpack-riscv-none-elf-gcc or riscv32-unknown-elf-gcc

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR riscv32)

# Try multiple toolchain prefixes
set(TOOLCHAIN_PREFIXES
    "riscv-none-elf-"
    "riscv32-unknown-elf-"
    "riscv64-unknown-elf-"
    "riscv-none-embed-"
)

# Find the first available toolchain
foreach(PREFIX ${TOOLCHAIN_PREFIXES})
    find_program(RISCV_GCC ${PREFIX}gcc)
    if(RISCV_GCC)
        set(TOOLCHAIN_PREFIX ${PREFIX})
        message(STATUS "Found RISC-V toolchain: ${TOOLCHAIN_PREFIX}")
        break()
    endif()
endforeach()

if(NOT RISCV_GCC)
    message(FATAL_ERROR "RISC-V toolchain not found. Install with:\n"
        "  Ubuntu: sudo apt install gcc-riscv64-unknown-elf\n"
        "  macOS:  brew install riscv-gnu-toolchain\n"
        "  Or download xpack-riscv-none-elf-gcc from:\n"
        "  https://github.com/xpack-dev-tools/riscv-none-elf-gcc-xpack/releases"
    )
endif()

# Set compilers
set(CMAKE_C_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_CXX_COMPILER ${TOOLCHAIN_PREFIX}g++)
set(CMAKE_ASM_COMPILER ${TOOLCHAIN_PREFIX}gcc)
set(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}objcopy)
set(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}objdump)
set(CMAKE_SIZE ${TOOLCHAIN_PREFIX}size)
set(CMAKE_AR ${TOOLCHAIN_PREFIX}ar)
set(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}ranlib)

# Don't try to run test executables on host
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Search paths for libraries and includes
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
