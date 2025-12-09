# Tang9K FPGA Project - Documentation Index

## 📚 Documentation Overview

This project includes comprehensive documentation for building, testing, and programming the Tang9K FPGA board with an SPI Slave interface and LED blinker.

### Quick Navigation

**Start Here:**
- **[QUICK_START.md](QUICK_START.md)** - 2-minute quick reference guide

**For Detailed Information:**
- **[BUILD_AND_PROGRAM.md](BUILD_AND_PROGRAM.md)** - Complete build & programming guide
- **[README.md](README.md)** - Project overview and features
- **[PROJECT_SUMMARY.md](PROJECT_SUMMARY.md)** - Technical summary
- **[LED_BLINKER.md](LED_BLINKER.md)** - LED blinker module documentation

**Automation:**
- **[build.sh](build.sh)** - Complete automated build script

---

## 📄 Document Descriptions

### QUICK_START.md (5 KB)
**Best for:** Getting started quickly, reference card

Contains:
- One-time installation steps
- Standard build & program workflow
- Troubleshooting checklist
- Common errors & fixes
- Essential commands reference
- File locations
- Performance tips

**Use this if:** You need to build/program quickly and know the basics

---

### BUILD_AND_PROGRAM.md (16 KB)
**Best for:** Detailed guidance, complete reference

Contains:
- Detailed prerequisites and installation
- Project structure explanation
- Step-by-step build process
- Three programming methods
- Complete build workflow with scripts
- Extensive troubleshooting section
- Advanced topics (custom PLL, timing constraints)
- Performance optimization
- FAQ section
- Command reference
- Additional resources

**Use this if:** You need detailed explanations or are troubleshooting issues

---

### README.md (4.8 KB)
**Best for:** Project overview

Contains:
- Feature highlights
- Pin assignments table
- Building with apio
- SPI slave testing
- Interface protocol
- Register map
- Module specifications
- Synchronization details
- Future enhancements

**Use this if:** You want to understand the project at a high level

---

### PROJECT_SUMMARY.md (6.3 KB)
**Best for:** Technical reference

Contains:
- Complete project structure
- Component overview
- Feature highlights
- Pin assignments
- Building instructions
- Testbench results
- Signal naming convention
- Register map
- Performance metrics
- File statistics

**Use this if:** You need technical details or want to understand system architecture

---

### LED_BLINKER.md (5.2 KB)
**Best for:** Understanding LED control

Contains:
- Feature overview
- Module interface
- Implementation details
- Clock dividers explanation
- PWM breathing effect
- Integration with top module
- PLL module documentation
- Testing procedure
- Synthesis considerations
- Debugging tips
- References

**Use this if:** You want details about the LED blinker implementation

---

### build.sh (11.9 KB)
**Best for:** Automated build process

Features:
- 9-step automated workflow
- Color-coded output
- Comprehensive logging
- Error handling
- USB device detection
- Build verification
- Detailed reports

Run with:
```bash
./build.sh
```

**Use this if:** You want fully automated build with minimal interaction

---

## 🚀 Quick Start Flowchart

```
Start
  ↓
[1] Read QUICK_START.md
  ↓
[2] Install apio: pip install apio
  ↓
[3] Install tools: apio install gowin
  ↓
[4] Build: apio build
  ↓
[5] Connect board via USB
  ↓
[6] Program: apio upload
  ↓
[7] Check LEDs blinking
  ↓
Success!

Problems? → Check BUILD_AND_PROGRAM.md troubleshooting section
```

---

## 📋 File Manifest

```
SPIQuadCopter/
├── Documentation (this directory)
│   ├── QUICK_START.md              ← Start here (5 min)
│   ├── BUILD_AND_PROGRAM.md        ← Detailed guide (30 min)
│   ├── README.md                   ← Project overview
│   ├── PROJECT_SUMMARY.md          ← Technical reference
│   ├── LED_BLINKER.md              ← LED module docs
│   └── INDEX.md                    ← This file
│
├── Configuration Files
│   ├── apio.ini                    ← Board settings
│   └── tang9k.cst                  ← Pin constraints
│
├── Scripts
│   ├── build.sh                    ← Automated build
│   └── Makefile                    ← Build targets
│
├── Source Code (src/)
│   ├── tang9k_top.sv               ← Top module
│   ├── led_blinker.sv              ← LED control
│   ├── pll.sv                      ← Clock generation
│   └── Makefile
│
├── SPI Slave Core (spiSlave/)
│   ├── spi_slave.sv                ← SPI implementation
│   ├── spi_slave_tb.sv             ← Testbench
│   └── Makefile
│
└── Build Artifacts (build/) [auto-generated]
    ├── project.gw                  ← Bitstream
    ├── project.log                 ← Build log
    └── ...
```

---

## 🔍 Which Document Should I Read?

### If I want to...

| Goal | Read | Time |
|------|------|------|
| Get started immediately | QUICK_START.md | 5 min |
| Understand the project | README.md | 10 min |
| Build for the first time | BUILD_AND_PROGRAM.md (step 1-3) | 15 min |
| Program the board | BUILD_AND_PROGRAM.md (step 4-5) | 10 min |
| Fix a build error | BUILD_AND_PROGRAM.md (troubleshooting) | 10 min |
| Fix a programming error | BUILD_AND_PROGRAM.md (troubleshooting) | 10 min |
| Understand LED blinker | LED_BLINKER.md | 15 min |
| Understand SPI slave | README.md or PROJECT_SUMMARY.md | 20 min |
| Use automated build | build.sh (just run it) | 5 min |
| Full system understanding | All documents | 60 min |

---

## 💻 Common Commands

### Installation (One-Time)
```bash
pip install apio
apio install gowin
```

### Build & Program
```bash
apio build
apio upload
```

### Simulation
```bash
cd spiSlave && make simulate && make wave
cd ../src && make simulate && make wave
```

### Automated (Recommended)
```bash
./build.sh
```

---

## 🐛 Troubleshooting Quick Links

**Problem → Solution**

- apio not found → QUICK_START.md (Installation section)
- Build fails → BUILD_AND_PROGRAM.md (Troubleshooting #7)
- USB not detected → BUILD_AND_PROGRAM.md (Troubleshooting #5)
- Pin errors → BUILD_AND_PROGRAM.md (Troubleshooting #6)
- Module not found → BUILD_AND_PROGRAM.md (Troubleshooting #4)
- Programming fails → BUILD_AND_PROGRAM.md (Troubleshooting #5)
- Want to debug → LED_BLINKER.md (Debugging Tips)
- Performance issues → BUILD_AND_PROGRAM.md (Performance Optimization)

---

## 📊 Document Statistics

| Document | Size | Sections | Time to Read |
|----------|------|----------|--------------|
| QUICK_START.md | 5 KB | 10 | 5 min |
| BUILD_AND_PROGRAM.md | 16 KB | 12 | 30 min |
| README.md | 4.8 KB | 13 | 10 min |
| PROJECT_SUMMARY.md | 6.3 KB | 12 | 15 min |
| LED_BLINKER.md | 5.2 KB | 14 | 15 min |
| **Total** | **37 KB** | **61** | **75 min** |

---

## 🎯 Recommended Reading Order

### For First-Time Users
1. QUICK_START.md (5 min)
2. BUILD_AND_PROGRAM.md - Prerequisites & Installation (15 min)
3. Run `./build.sh` (5-10 min)
4. Verify LEDs blink ✓

### For Developers
1. README.md (10 min)
2. PROJECT_SUMMARY.md (15 min)
3. LED_BLINKER.md (15 min)
4. Explore source code (30 min)

### For Integration
1. BUILD_AND_PROGRAM.md - Full read (30 min)
2. README.md - SPI Interface section (5 min)
3. PROJECT_SUMMARY.md - Register Map (5 min)

---

## 📞 Getting Help

### Quick Reference
- **Installation issues** → BUILD_AND_PROGRAM.md section 2-3
- **Build errors** → BUILD_AND_PROGRAM.md section 4 & troubleshooting
- **Programming issues** → BUILD_AND_PROGRAM.md section 5 & troubleshooting
- **Hardware connections** → README.md or PROJECT_SUMMARY.md pin assignments
- **LED blinker details** → LED_BLINKER.md

### Online Resources
- Apio: https://apiodocs.readthedocs.io/
- Gowin: http://www.gowinsemi.com/
- iverilog: http://iverilog.icarus.com/
- GTKWave: http://gtkwave.sourceforge.net/

---

## ✅ Verification Checklist

After programming, verify:

- [ ] LEDs are visible on board
- [ ] LED0 blinks slowly (~0.5 Hz)
- [ ] LED1 blinks faster (~1 Hz)
- [ ] LED2 blinks even faster (~2 Hz)
- [ ] LED3 shows breathing effect
- [ ] All LEDs are synchronized to system clock
- [ ] No errors in build log
- [ ] Bitstream programmed successfully (no USB errors)

---

## 🔄 Workflow Summary

```
Installation (one-time)
    ↓
[Edit source code]
    ↓
[Run tests/simulation]
    ↓
[Build design] - apio build
    ↓
[Program board] - apio upload
    ↓
[Verify on hardware]
    ↓
Repeat from step 1 as needed
```

---

## 📝 Document Maintenance

Last Updated: **December 7, 2025**

All documentation is synchronized and includes:
- ✓ Installation guides
- ✓ Build procedures
- ✓ Programming instructions
- ✓ Troubleshooting guides
- ✓ Reference materials
- ✓ Example commands
- ✓ Quick reference cards

---

## 🎓 Learning Path

### Beginner (Build & Program Only)
```
QUICK_START.md → build.sh → Done!
```
**Time: 15 minutes**

### Intermediate (Understand Project)
```
README.md → BUILD_AND_PROGRAM.md → PROJECT_SUMMARY.md
```
**Time: 1 hour**

### Advanced (Complete Understanding)
```
All documents + Source code exploration + Testbenches
```
**Time: 2-3 hours**

---

## 📦 Complete Project Status

✅ **Documentation**: Complete and comprehensive
✅ **Code**: Tested and verified
✅ **Configuration**: Ready for Tang9K board
✅ **Build System**: Automated and reliable
✅ **Testing**: Simulation testbenches included
✅ **Scripts**: Automated build script provided

**Ready to build and program!**

---

**For questions or updates, refer to the specific documentation files or check the BUILD_AND_PROGRAM.md "Getting Help" section.**

