# =============================================================================
# Arty S7-50 Vivado Build Script
# =============================================================================
# Usage:
#   cd ArtS7-50/project/SPICopter
#   vivado -mode batch -source build.tcl              # Create project only
#   vivado -mode batch -source build.tcl -tclargs build  # Create + build bitstream
#
# Or open in GUI after creating:
#   vivado SPICopter.xpr
#
# To update this script after GUI changes:
#   In Vivado TCL console: write_project_tcl -force build.tcl
# =============================================================================

set script_dir [file dirname [info script]]
set project_dir $script_dir
set root_dir [file normalize "$script_dir/../../.."]
set local_srcs "$script_dir/SPICopter.srcs/sources_1"

set project_name "SPICopter"
set part "xc7s50csga324-1"
set top_module "arty_s7_spi_copter_top"

# Check if we should build bitstream
set do_build 0
if {[llength $argv] > 0} {
    if {[lindex $argv 0] eq "build"} {
        set do_build 1
    }
}

# -----------------------------------------------------------------------------
# Delete existing project files (but preserve SPICopter.srcs)
# -----------------------------------------------------------------------------
foreach item [list SPICopter.xpr SPICopter.cache SPICopter.hw SPICopter.ip_user_files SPICopter.runs SPICopter.sim] {
    if {[file exists "$project_dir/$item"]} {
        puts "Removing $item..."
        file delete -force "$project_dir/$item"
    }
}

# -----------------------------------------------------------------------------
# Create Project
# -----------------------------------------------------------------------------
puts "Creating project: $project_name"
create_project $project_name $project_dir -part $part -force

# Optional: Set board part if installed (uncomment if you have Digilent board files)
# set_property board_part digilentinc.com:arty-s7-50:part0:1.1 [current_project]

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

# -----------------------------------------------------------------------------
# Add Local Source Files (in SPICopter.srcs - version controlled)
# -----------------------------------------------------------------------------
puts "Adding local source files..."

# Top-level (local)
add_files -norecurse "$local_srcs/arty_s7_spi_copter_top.v"

# Constraints (local)
add_files -fileset constrs_1 -norecurse "$local_srcs/Arty-S7-50-Master.xdc"

# -----------------------------------------------------------------------------
# Add Shared Source Files (from main repo)
# -----------------------------------------------------------------------------
puts "Adding shared source files..."

# VexRiscv CPU (use JTAG version for Arty S7)
add_files -norecurse "$root_dir/vexriscv/VexRiscvJtag.v"

# Core system (SystemVerilog)
add_files -norecurse [glob -nocomplain "$root_dir/src/*.sv"]
add_files -norecurse [glob -nocomplain "$root_dir/src/*.v"]

# SPI Slave
add_files -norecurse "$root_dir/spiSlave/spi_slave.sv"

# PWM Decoder
add_files -norecurse "$root_dir/pwmDecoder/pwmdecoder.v"
add_files -norecurse "$root_dir/pwmDecoder/pwmdecoder_wb.v"

# NeoPixel
add_files -norecurse "$root_dir/neoPXStrip/sendPx_axis_flexible.sv"
add_files -norecurse "$root_dir/neoPXStrip/wb_neoPx.v"

# DSHOT
add_files -norecurse "$root_dir/dshot/dshot_out.v"
add_files -norecurse "$root_dir/dshot/dshot_mailbox.sv"

# Version
add_files -norecurse "$root_dir/version/wb_version.sv"

# UART cores
add_files -norecurse "$root_dir/verilog-uart/rtl/uart_tx.v"
add_files -norecurse "$root_dir/verilog-uart/rtl/uart_rx.v"

# Wishbone mux
add_files -norecurse "$root_dir/verilog-wishbone/rtl/wb_mux.v"

# -----------------------------------------------------------------------------
# Set Top Module
# -----------------------------------------------------------------------------
set_property top $top_module [current_fileset]
update_compile_order -fileset sources_1

puts ""
puts "Project created successfully!"
puts "Project file: $project_dir/SPICopter.xpr"
puts ""

# -----------------------------------------------------------------------------
# Build Bitstream (optional)
# -----------------------------------------------------------------------------
if {$do_build} {
    puts "Starting synthesis..."
    launch_runs synth_1 -jobs 4
    wait_on_run synth_1
    
    if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
        puts "ERROR: Synthesis failed!"
        exit 1
    }
    
    puts "Starting implementation..."
    launch_runs impl_1 -to_step write_bitstream -jobs 4
    wait_on_run impl_1
    
    if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
        puts "ERROR: Implementation failed!"
        exit 1
    }
    
    # Copy bitstream to project root
    set bitstream_file "$project_dir/SPICopter.runs/impl_1/${top_module}.bit"
    if {[file exists $bitstream_file]} {
        file copy -force $bitstream_file "$project_dir/${project_name}.bit"
        puts ""
        puts "SUCCESS! Bitstream: $project_dir/${project_name}.bit"
    }
    
    puts "Build complete!"
} else {
    puts ""
    puts "To build bitstream, run:"
    puts "  vivado -mode batch -source build.tcl -tclargs build"
    puts ""
    puts "Or open in GUI:"
    puts "  vivado SPICopter.xpr"
    puts ""
    puts "After making changes in GUI, update this script:"
    puts "  write_project_tcl -force build.tcl"
}
