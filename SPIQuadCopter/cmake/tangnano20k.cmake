# =============================================================================
# Tang Nano 20K Platform - CMake Configuration
# =============================================================================
# Gowin GW2AR-18 FPGA - OSS CAD Suite (Yosys + nextpnr-himbaechel)
# =============================================================================

message(STATUS "Configuring for Tang Nano 20K (Gowin GW2AR-18)")

# Platform-specific settings
set(FPGA_DEVICE "GW2AR-LV18QN88C8/I7")
set(FPGA_FAMILY "GW2A-18C")
set(TOP_MODULE "tangnano20k_top")

# Platform-specific sources
set(PLATFORM_SOURCES
    ${CMAKE_SOURCE_DIR}/TangNano20K/tangnano20k_top.sv
    ${CMAKE_SOURCE_DIR}/TangNano20K/pll.sv
)

# Constraints
set(CONSTRAINTS_FILE ${CMAKE_SOURCE_DIR}/TangNano20K/tangnano20k.cst)
set(TIMING_FILE ${CMAKE_SOURCE_DIR}/TangNano20K/tangnano20k_timing.sdc)

# -----------------------------------------------------------------------------
# Find OSS CAD Suite Tools
# -----------------------------------------------------------------------------
# Search in common install locations
set(OSS_CAD_HINTS
    $ENV{HOME}/.local/oss-cad-suite/bin
    $ENV{HOME}/.tools/oss-cad-suite/bin
    $ENV{HOME}/oss-cad-suite/bin
    /opt/oss-cad-suite/bin
)

find_program(YOSYS yosys HINTS ${OSS_CAD_HINTS})
find_program(NEXTPNR nextpnr-himbaechel HINTS ${OSS_CAD_HINTS})
find_program(GOWIN_PACK gowin_pack HINTS ${OSS_CAD_HINTS})
find_program(OPENFPGALOADER openFPGALoader HINTS ${OSS_CAD_HINTS})

if(NOT YOSYS)
    message(FATAL_ERROR "yosys not found. Install OSS CAD Suite with: ./scripts/install_local_tools.sh")
endif()
if(NOT NEXTPNR)
    message(FATAL_ERROR "nextpnr-himbaechel not found. Install OSS CAD Suite.")
endif()
if(NOT GOWIN_PACK)
    message(FATAL_ERROR "gowin_pack not found. Install OSS CAD Suite.")
endif()

message(STATUS "  yosys: ${YOSYS}")
message(STATUS "  nextpnr: ${NEXTPNR}")
message(STATUS "  gowin_pack: ${GOWIN_PACK}")

# Build seed for P&R reproducibility
set(PNR_SEED "42" CACHE STRING "Place and route seed")

# Output files
set(SYNTH_JSON ${BUILD_DIR}/hardware.json)
set(PNR_JSON ${BUILD_DIR}/hardware.pnr.json)
set(BITSTREAM ${BUILD_DIR}/hardware.fs)

# All RTL sources
set(ALL_SOURCES ${RTL_SOURCES} ${PLATFORM_SOURCES})

# Firmware file (used by wb_ram)
set(FIRMWARE_MEM_SRC ${CMAKE_SOURCE_DIR}/firmware/firmware.mem)

# -----------------------------------------------------------------------------
# Synthesis Target (Yosys)
# -----------------------------------------------------------------------------
add_custom_command(
    OUTPUT ${SYNTH_JSON}
    COMMAND ${YOSYS} -m slang -Q
        -p "synth_gowin -top ${TOP_MODULE} -json ${SYNTH_JSON}"
        ${ALL_SOURCES}
    DEPENDS ${ALL_SOURCES} ${FIRMWARE_MEM_SRC}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running Yosys synthesis for Tang Nano 20K..."
    VERBATIM
)

add_custom_target(synth
    DEPENDS ${SYNTH_JSON}
    COMMENT "Synthesis complete"
)

# -----------------------------------------------------------------------------
# Place & Route Target (nextpnr-himbaechel)
# -----------------------------------------------------------------------------
add_custom_command(
    OUTPUT ${PNR_JSON}
    COMMAND ${NEXTPNR}
        --device ${FPGA_DEVICE}
        --json ${SYNTH_JSON}
        --write ${PNR_JSON}
        --report ${BUILD_DIR}/hardware.pnr
        --vopt family=${FPGA_FAMILY}
        --vopt cst=${CONSTRAINTS_FILE}
        --sdc ${TIMING_FILE}
        --seed ${PNR_SEED}
        --timing-allow-fail
        --placer-heap-cell-placement-timeout 100000000
    DEPENDS ${SYNTH_JSON} ${CONSTRAINTS_FILE} ${TIMING_FILE}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running nextpnr place & route..."
    VERBATIM
)

add_custom_target(place
    DEPENDS ${PNR_JSON}
    COMMENT "Place & route complete"
)

# -----------------------------------------------------------------------------
# Pack Target (gowin_pack)
# -----------------------------------------------------------------------------
add_custom_command(
    OUTPUT ${BITSTREAM}
    COMMAND ${GOWIN_PACK}
        -d ${FPGA_FAMILY}
        -o ${BITSTREAM}
        ${PNR_JSON}
    DEPENDS ${PNR_JSON}
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Running gowin_pack to generate bitstream..."
    VERBATIM
)

add_custom_target(bitstream
    DEPENDS ${BITSTREAM}
    COMMENT "Bitstream generated: ${BITSTREAM}"
)

# Add firmware dependency if enabled
if(BUILD_FIRMWARE AND TARGET firmware)
    add_dependencies(bitstream firmware)
endif()

# -----------------------------------------------------------------------------
# Upload Target
# -----------------------------------------------------------------------------
if(OPENFPGALOADER)
    add_custom_target(upload
        COMMAND ${OPENFPGALOADER} -b tangnano20k ${BITSTREAM}
        DEPENDS ${BITSTREAM}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Programming Tang Nano 20K..."
    )
    
    add_custom_target(upload-flash
        COMMAND ${OPENFPGALOADER} -b tangnano20k -f ${BITSTREAM}
        DEPENDS ${BITSTREAM}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
        COMMENT "Programming Tang Nano 20K flash..."
    )
else()
    message(WARNING "openFPGALoader not found - upload target disabled")
endif()

# -----------------------------------------------------------------------------
# Resource Stats Target
# -----------------------------------------------------------------------------
add_custom_target(stats
    COMMAND ${YOSYS} -p "read_json ${SYNTH_JSON}$<SEMICOLON> stat"
    DEPENDS ${SYNTH_JSON}
    COMMENT "Resource utilization for Tang Nano 20K"
)
