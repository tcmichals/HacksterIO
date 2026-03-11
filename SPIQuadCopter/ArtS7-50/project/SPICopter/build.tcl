# =============================================================================
# Arty S7-50 Vivado Build Script (Pro Pattern)
# =============================================================================
# Usage:
#   cd ArtS7-50/project/SPICopter
#   vivado -mode batch -source build.tcl              # Create project only
#   vivado -mode batch -source build.tcl -tclargs build  # Build bitstream
#   vivado -mode gui -source build.tcl                # Open in GUI
#
# After GUI changes, update this script:
#   write_project_tcl -force -no_copy_sources build.tcl
# =============================================================================

set script_dir [file dirname [info script]]
set src_dir "$script_dir/src"
set root_dir [file normalize "$script_dir/../../.."]

set project_name "SPICopter"
set project_dir "$script_dir/vivado_project"
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
# Clean Slate - Delete entire project directory
# -----------------------------------------------------------------------------
if {[file exists $project_dir]} {
    puts "Cleaning existing project directory..."
    file delete -force $project_dir
}

# -----------------------------------------------------------------------------
# Create Project (fresh, in vivado_project subdirectory)
# -----------------------------------------------------------------------------
puts "Creating project: $project_name"
create_project $project_name $project_dir -part $part

# Set project properties
set_property target_language Verilog [current_project]
set_property simulator_language Mixed [current_project]

# Optional: Set board part if installed
# set_property board_part digilentinc.com:arty-s7-50:part0:1.1 [current_project]

# -----------------------------------------------------------------------------
# Add Local Source Files (from src/ - version controlled)
# Using -norecurse so edits in Vivado save back to your real files
# -----------------------------------------------------------------------------
puts "Adding local source files from src/..."
add_files -norecurse [glob -nocomplain $src_dir/*.v]
add_files -norecurse [glob -nocomplain $src_dir/*.sv]
add_files -fileset constrs_1 -norecurse [glob -nocomplain $src_dir/*.xdc]

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
# Set Top Module and Update Compile Order
# -----------------------------------------------------------------------------
set_property top $top_module [current_fileset]
update_compile_order -fileset sources_1

puts ""
puts "Project created successfully!"
puts "Project file: $project_dir/$project_name.xpr"
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
    
    # Copy bitstream to script directory
    set bitstream_file "$project_dir/$project_name.runs/impl_1/${top_module}.bit"
    if {[file exists $bitstream_file]} {
        file copy -force $bitstream_file "$script_dir/${project_name}.bit"
        puts ""
        puts "SUCCESS! Bitstream: $script_dir/${project_name}.bit"
    }
    
    puts "Build complete!"
} else {
    puts ""
    puts "To build bitstream:"
    puts "  vivado -mode batch -source build.tcl -tclargs build"
    puts ""
    puts "To open in GUI:"
    puts "  vivado $project_dir/$project_name.xpr"
    puts ""
    puts "After GUI changes, update this script:"
    puts "  write_project_tcl -force -no_copy_sources build.tcl"
}
