# Arty S7-50 Vivado Project

## Quick Start

```bash
cd ArtS7-50/project/SPICopter

# Create project (first time or after clean)
vivado -mode batch -source build.tcl

# Open in GUI
vivado SPICopter.xpr
```

## Build Bitstream (Command Line)

```bash
vivado -mode batch -source build.tcl -tclargs build
```

Output: `SPICopter.bit`

## Directory Structure

```
SPICopter/
├── build.tcl              # Project creation script (VERSION CONTROLLED)
├── .gitignore             # Ignores Vivado-generated files
├── HOWTO.md               # This file
├── SPICopter.srcs/        # YOUR source files (VERSION CONTROLLED)
│   └── sources_1/
│       ├── arty_s7_spi_copter_top.v
│       └── Arty-S7-50-Master.xdc
├── SPICopter.xpr          # Vivado project (GENERATED - gitignored)
├── SPICopter.runs/        # Build outputs (GENERATED - gitignored)
├── SPICopter.cache/       # Cache (GENERATED - gitignored)
└── SPICopter.bit          # Bitstream output (GENERATED)
```

## Workflow

### Initial Setup
```bash
cd ArtS7-50/project/SPICopter
vivado -mode batch -source build.tcl
vivado SPICopter.xpr
```

### Daily Development (GUI)
1. Open: `vivado SPICopter.xpr`
2. Make changes (edit RTL, constraints, add IPs, etc.)
3. Build: Flow → Generate Bitstream
4. Program: Open Hardware Manager → Program Device

### Saving Changes to Git

After making changes in Vivado GUI that you want to keep:

```tcl
# In Vivado TCL Console:
write_project_tcl -force build.tcl
```

Then commit `build.tcl` to git.

### Clean Rebuild

```bash
cd ArtS7-50/project/SPICopter

# Remove generated files (keeps SPICopter.srcs/)
rm -rf SPICopter.xpr SPICopter.cache SPICopter.runs SPICopter.hw SPICopter.sim .Xil

# Regenerate project
vivado -mode batch -source build.tcl
```

## Adding New Source Files

### Option 1: Add to SPICopter.srcs (local files)
1. Put file in `SPICopter.srcs/sources_1/`
2. In Vivado: Add Sources → Add Files
3. Update build.tcl: `write_project_tcl -force build.tcl`

### Option 2: Add shared files (from main repo)
1. Edit `build.tcl` directly
2. Add `add_files -norecurse "$root_dir/path/to/file.v"`
3. Regenerate project

## Programming the Board

### From Vivado GUI
1. Open Hardware Manager
2. Auto Connect
3. Program Device → Select SPICopter.bit

### From Command Line
```bash
# Create program script
cat > program.tcl << 'EOF'
open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE {SPICopter.bit} [current_hw_device]
program_hw_devices [current_hw_device]
close_hw_manager
EOF

vivado -mode batch -source program.tcl
```

## Troubleshooting

### "Project already exists"
The script auto-cleans generated files. If issues persist:
```bash
rm -rf SPICopter.xpr SPICopter.cache SPICopter.runs SPICopter.hw
```

### Missing source files
Check `$root_dir` paths in build.tcl point to correct locations.

### Synthesis errors
Check the top module uses `common_vexriscv_spi_top` (not the old SERV version).

## VexRiscv JTAG Debugging

The Arty S7 build uses `VexRiscvJtag.v` which exposes hardware JTAG pins:
- `jtag_tms`, `jtag_tck`, `jtag_tdi`, `jtag_tdo`

Connect to OpenOCD or Vivado for CPU debugging.

## Version Control Summary

**Commit these files:**
- `build.tcl` - Project script
- `SPICopter.srcs/` - Your RTL and constraints
- `.gitignore` - Ignore rules
- `HOWTO.md` - This guide

**Ignore these (auto-generated):**
- `SPICopter.xpr` - Regenerated from build.tcl
- `SPICopter.runs/` - Build outputs
- `SPICopter.cache/` - Vivado cache
- `*.bit` - Bitstream (regenerate as needed)
