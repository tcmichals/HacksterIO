# Arty S7-50 Vivado Project (Pro Workflow)

## Directory Structure

```
SPICopter/
├── src/                    <- YOUR source files (version controlled)
│   ├── arty_s7_spi_copter_top.v
│   └── Arty-S7-50-Master.xdc
├── build.tcl               <- Build script (version controlled)
├── HOWTO.md                <- This file
├── .gitignore
└── vivado_project/         <- Vivado generates here (gitignored, disposable)
```

## Quick Start

```bash
cd ArtS7-50/project/SPICopter

# Create project (opens GUI when done)
vivado -mode batch -source build.tcl
vivado vivado_project/SPICopter.xpr

# Or create and build bitstream in one command
vivado -mode batch -source build.tcl -tclargs build
```

## Workflow

### 1. Create/Recreate Project
```bash
vivado -mode batch -source build.tcl
```
This deletes `vivado_project/` and creates a fresh project every time.

### 2. Open in GUI
```bash
vivado vivado_project/SPICopter.xpr
```

### 3. Make Changes in GUI
- Edit RTL, constraints, add IPs, change settings
- Your edits to files in `src/` save directly (linked, not copied)

### 4. Update build.tcl After GUI Changes
In Vivado TCL Console:
```tcl
write_project_tcl -force -no_copy_sources ../build.tcl
```

### 5. Build Bitstream (Command Line)
```bash
vivado -mode batch -source build.tcl -tclargs build
```
Output: `SPICopter.bit`

## Key Concepts

### Why This Structure?
- **src/** = Your real code (version controlled)
- **vivado_project/** = Disposable (gitignored)
- **build.tcl** = Single source of truth for project settings

### Idempotent Builds
Run `build.tcl` as many times as you want - it always:
1. Deletes `vivado_project/` completely
2. Creates fresh project
3. Links to your `src/` files (not copies)

### Version Control
**Commit these:**
- `src/` - Your RTL and constraints
- `build.tcl` - Project settings
- `.gitignore`
- `HOWTO.md`

**Never commit:**
- `vivado_project/` - Regenerated from build.tcl
- `*.bit` - Build output
- `*.jou`, `*.log` - Vivado logs

## Troubleshooting

### Project won't build?
```bash
rm -rf vivado_project/
vivado -mode batch -source build.tcl
```

### Missing source files?
Check `src/` has your `.v` and `.xdc` files.

### Need to add new shared files?
Edit `build.tcl` and add them to the "Add Shared Source Files" section.

## Programming the Board

```bash
# In Vivado TCL Console after opening Hardware Manager:
open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE {SPICopter.bit} [current_hw_device]
program_hw_devices [current_hw_device]
```
