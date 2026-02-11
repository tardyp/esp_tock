# ESP32-C6 Tock OS Port - Documentation Index

This directory contains comprehensive documentation for porting Tock OS from ESP32-C3 to ESP32-C6, specifically targeting the **nanoESP32-C6** development board by MuseLab.

---

## 📚 Documentation Files

### 0. **CRITICAL_FINDINGS.md** 🔥🔥🔥 READ THIS FIRST!
**Critical hardware discoveries from schematic analysis - MUST READ!**

**Contents:**
- ⚠️ RGB LED signal inversion (BSS138 MOSFET)
- ⚠️ GRB color order (not RGB!)
- ⚠️ GPIO16 is hardware-dedicated
- ⚠️ CH343P on `/dev/ttyACM0` (not ttyUSB0)
- ✅ Complete pin verification
- ✅ 8MB flash layout recommendations

**Purpose:** Prevent critical mistakes before you start coding.

**READ THIS** before writing any code to avoid common pitfalls!

---

### 0.5. **HARDWARE_SUMMARY.md** ⭐⭐⭐ Quick Reference
**Critical hardware info for nanoESP32-C6 - keep this open while coding!**

**Contents:**
- Pin assignments (verified from schematic)
- RGB LED on GPIO16 (WS2812B, inverted signal!)
- Boot button on GPIO9
- UART0 configuration
- Memory layout recommendations
- Common pitfalls and solutions

**Purpose:** Quick reference for hardware-specific details during development.

**Use this** when you need to check a pin number or hardware configuration quickly.

---

### 1. **ESP32-C6_DIFFERENCES.md** ⭐ Start Here
**Comprehensive technical analysis of differences between ESP32-C3 and ESP32-C6**

**Contents:**
- RISC-V core differences (RV32IMC → RV32IMAC)
- Memory architecture reorganization
- Interrupt system redesign (CLINT + INTC)
- Peripheral base address changes
- System control updates (SYSCON → PCR)
- Power management evolution
- Complete impact assessment

**Purpose:** Understand what changed and why it matters for the Tock port.

**Read this first** to understand the scope of changes needed.

---

### 2. **ESP32-C6_PORTING_PLAN.md** ⭐ Implementation Guide
**Step-by-step plan to port Tock OS to ESP32-C6**

**Contents:**
- 4-phase incremental approach
- Detailed task breakdowns
- Code examples and snippets
- Testing strategies
- Timeline estimates (7-11 weeks)
- Risk mitigation

**Phases:**
1. **Foundation** - Boot to main loop (2-3 weeks)
2. **Core Peripherals** - UART, GPIO, Timers (2-3 weeks)
3. **Complete Interrupts** - Full INTC + CLINT (2-3 weeks)
4. **Feature Parity** - Match C3 functionality (1-2 weeks)

**Use this** as your implementation roadmap.

---

### 3. **NANOESP32-C6_BOARD_NOTES.md** ⭐ Hardware Reference
**Board-specific information for the nanoESP32-C6**

**Contents:**
- Hardware specifications
- USB interface details (CH343 on `/dev/ttyACM0`)
- GPIO pinout and availability
- RGB LED configuration
- Flash memory layout (8MB!)
- Flashing commands
- Debugging tips

**Critical Board Features:**
- ✅ 8MB flash (vs 2-4MB typical) - more space!
- ✅ Dual USB Type-C (CH343 + native ESP32-C6)
- ✅ On-board RGB LED for visual debugging
- ✅ Compact form factor with all GPIOs

**Use this** for board-specific configuration and debugging.

---

## 🎯 Quick Start Guide

### What You Have
- ✅ **nanoESP32-C6 board** by MuseLab
- ✅ **ESP32-C6 documentation** in `doc/esp32c6_manual/`
- ✅ **ESP32-C3 reference** in `doc/esp32c3_manual/`
- ✅ **Working C3 implementation** in `tock/boards/esp32-c3-devkitM-1/`
- ✅ **Comprehensive porting plan**

### What You Need to Do

#### Step 1: Verify Your Hardware (5 minutes)
```bash
# Connect nanoESP32-C6 via USB Type-C
# Check if device appears
lsusb | grep -i "CH34\|QinHeng"
ls -l /dev/ttyACM*

# Test with demo firmware
cd nanoESP32-C6
./demo/flash_write.sh /dev/ttyACM0
# RGB LED should blink
```

#### Step 2: Read the Documentation (2-3 hours)
1. Read `ESP32-C6_DIFFERENCES.md` - understand what changed
2. Skim `ESP32-C6_PORTING_PLAN.md` - get the big picture
3. Review `NANOESP32-C6_BOARD_NOTES.md` - board specifics

#### Step 3: Setup Development Environment (1 hour)
```bash
# Install Rust target
rustup target add riscv32imac-unknown-none-elf

# Verify esptool.py
esptool.py version

# Verify tockloader
tockloader --version
```

#### Step 4: Begin Phase 1 Implementation (2-3 weeks)
Follow `ESP32-C6_PORTING_PLAN.md` Phase 1:
1. Create board and chip directories
2. Update memory layout
3. Update peripheral addresses
4. Implement minimal interrupt controller
5. First boot!

---

## 📊 Key Differences Summary

### Critical Changes (Prevent Boot)
| Component | ESP32-C3 | ESP32-C6 | Impact |
|-----------|----------|----------|--------|
| **ISA** | RV32IMC | RV32IMAC | Toolchain change |
| **HP SRAM** | 0x3FCA0000 (400KB) | 0x40800000 (512KB) | All addresses |
| **Interrupts** | 31 external | 28 external + 4 CLINT | New system |
| **TIMG0** | 0x6001F000 | 0x60008000 | Address change |
| **GPIO** | 0x60004000 | 0x60091000 | Address change |
| **System** | SYSCON | PCR module | Clock control |

### Advantages of C6
- ✅ More SRAM (512KB vs 400KB)
- ✅ Larger cache (32KB vs 16KB)
- ✅ Atomic instructions (RV32A extension)
- ✅ Better privilege separation (user mode delegation)
- ✅ More GPIOs (31 vs 22)
- ✅ nanoESP32-C6: 8MB flash!

---

## 🎯 Success Criteria

### Minimum Viable Port (MVP)
- [ ] Kernel boots successfully
- [ ] UART console works
- [ ] Timer interrupts fire
- [ ] GPIO toggles (LED blink)
- [ ] Process loads and runs

**Target:** End of Phase 2 (4-6 weeks)

### Feature Complete
- [ ] All interrupts working (CLINT + INTC)
- [ ] All peripherals functional
- [ ] C3 test suite passes
- [ ] Documentation complete

**Target:** End of Phase 4 (7-11 weeks)

---

## 🛠️ Tools and Resources

### Essential Tools
```bash
# Rust toolchain
rustup target add riscv32imac-unknown-none-elf

# Flashing and debugging
pip install esptool tockloader

# Serial terminal
sudo apt install tio  # or minicom, screen
```

### Directory Structure
```
esp_tock/
├── tock/                           # Tock OS repository
│   ├── boards/
│   │   ├── esp32-c3-devkitM-1/    # Reference C3 implementation
│   │   └── nanoESP32-c6/          # NEW - C6 board (to create)
│   ├── chips/
│   │   ├── esp32-c3/              # C3 chip support
│   │   ├── esp32-c6/              # NEW - C6 chip support (to create)
│   │   └── esp32/                 # Shared peripherals (UART, GPIO, Timer)
│   └── arch/rv32i/                # RISC-V architecture support
├── doc/
│   ├── esp32c3_manual/            # C3 technical reference
│   └── esp32c6_manual/            # C6 technical reference
├── nanoESP32-C6/                  # Board documentation and examples
├── ESP32-C6_DIFFERENCES.md        # ⭐ Technical analysis
├── ESP32-C6_PORTING_PLAN.md       # ⭐ Implementation plan
├── NANOESP32-C6_BOARD_NOTES.md    # ⭐ Board-specific info
└── README_ESP32C6_PORT.md         # ⭐ This file
```

### Reference Documentation
- **ESP32-C6 TRM:** `doc/esp32c6_manual/` or `nanoESP32-C6/doc/esp32-c6_technical_reference_manual_en.pdf`
- **ESP32-C6 Datasheet:** `nanoESP32-C6/doc/esp32-c6_datasheet_en.pdf`
- **Board Schematic:** `nanoESP32-C6/hardware/nanoESP32C6.pdf`
- **Tock Docs:** https://book.tockos.org/
- **RISC-V Spec:** https://riscv.org/technical/specifications/

---

## 📝 Implementation Checklist

### Phase 1: Foundation ⏳ (Week 1-4)
- [ ] Create `tock/boards/nanoESP32-c6/` directory
- [ ] Create `tock/chips/esp32-c6/` directory
- [ ] Update `.cargo/config.toml` to `riscv32imac`
- [ ] Write new `layout.ld` with C6 memory map
- [ ] Define peripheral base address constants
- [ ] Implement minimal INTC driver
- [ ] Implement minimal CLINT driver
- [ ] Update trap handler for dual interrupts
- [ ] First boot achieved! 🎉

### Phase 2: Core Peripherals ⏳ (Week 5-8)
- [ ] UART0 driver (should mostly work!)
- [ ] GPIO driver (31 pins, new address)
- [ ] Timer Groups (new address, PCR clocking)
- [ ] PCR (Power/Clock/Reset) driver
- [ ] RGB LED working
- [ ] Simple app runs

### Phase 3: Complete Interrupts ⏳ (Week 9-11)
- [ ] Full INTC implementation
- [ ] Full CLINT implementation
- [ ] Map peripheral interrupt IDs
- [ ] Test all interrupt sources
- [ ] Multi-alarm test passes

### Phase 4: Feature Parity ⏳ (Week 12-15)
- [ ] RNG driver
- [ ] PMU/watchdog driver
- [ ] All C3 tests pass
- [ ] Documentation complete
- [ ] CI/CD integration

---

## 🚀 Expected Timeline

### Part-Time (20 hours/week)
- **Phase 1:** Weeks 1-4 (Foundation)
- **Phase 2:** Weeks 5-8 (Core Peripherals)
- **Phase 3:** Weeks 9-11 (Interrupts)
- **Phase 4:** Weeks 12-15 (Feature Parity)
- **Total:** 15 weeks

### Full-Time (40 hours/week)
- **Phase 1:** Weeks 1-2
- **Phase 2:** Weeks 3-4
- **Phase 3:** Weeks 5-6
- **Phase 4:** Week 7-8
- **Total:** 8 weeks

### Minimum Viable Port
- **Target:** End of Phase 2
- **Time:** 4-6 weeks part-time, 2-3 weeks full-time
- **Features:** Boot, UART, GPIO, Timer, basic apps

---

## ⚠️ Known Challenges

### 1. Memory Addresses (CRITICAL)
**Issue:** All peripheral addresses changed  
**Solution:** Centralize addresses, verify each one against TRM

### 2. Interrupt System (HIGH)
**Issue:** CLINT + INTC dual system is complex  
**Solution:** Implement separately, test individually, clear routing

### 3. Clock Configuration (MEDIUM)
**Issue:** PCR module replaces SYSCON  
**Solution:** Study PCR carefully, start conservative (80MHz)

### 4. Peripheral Mapping (HIGH)
**Issue:** Interrupt IDs may have changed  
**Solution:** Look up each peripheral in C6 TRM Chapter 10

---

## 💡 Tips for Success

### 1. Start Simple
- Get boot working first (Phase 1)
- Add peripherals one at a time
- Test thoroughly before moving on

### 2. Use Visual Debugging
- RGB LED shows boot stages
- GPIO toggle + logic analyzer
- JTAG if available

### 3. Reference C3 Implementation
- Study how C3 does things
- Adapt rather than rewrite from scratch
- Share code where possible (esp32 common crate)

### 4. Document As You Go
- Note what works and what doesn't
- Record GPIO assignments
- Update board README

### 5. Test Incrementally
- Build and test after each change
- Don't accumulate untested code
- Use version control (git)

---

## 🤝 Getting Help

### Resources
1. **Tock OS Documentation:** https://book.tockos.org/
2. **Tock Slack/Matrix:** Community support
3. **ESP32-C6 Forums:** Espressif community
4. **RISC-V Spec:** For architecture questions

### Debugging Strategy
1. **No Boot:** Check memory addresses in linker script
2. **No Serial:** Verify UART pins (GPIO16/17), try RGB LED
3. **Crashes:** Use JTAG debugger, check trap handler
4. **Interrupt Issues:** Verify CLINT vs INTC routing

---

## 📈 Progress Tracking

Create a tracking document to monitor progress:

```markdown
# ESP32-C6 Port Progress

## Phase 1: Foundation
- [x] Directory structure created (2024-02-10)
- [ ] Memory layout updated
- [ ] INTC driver implemented
- [ ] CLINT driver implemented
- [ ] First boot achieved

## Phase 2: Core Peripherals
- [ ] UART working
- [ ] GPIO working
- [ ] Timers working
- [ ] Apps running

## Phase 3: Complete Interrupts
- [ ] All interrupts mapped
- [ ] Tests passing

## Phase 4: Feature Parity
- [ ] All drivers ported
- [ ] Documentation done
```

---

## 🎓 Learning Outcomes

By completing this port, you will gain deep expertise in:

1. **RISC-V Architecture**
   - ISA extensions (IMC vs IMAC)
   - Interrupt handling (CLINT, external)
   - Privilege levels and delegation
   - PMP memory protection

2. **Embedded Systems**
   - Memory mapping and linker scripts
   - Peripheral driver development
   - Interrupt controller architecture
   - Boot sequences and initialization

3. **Tock OS**
   - Kernel architecture
   - Capsule system
   - Process isolation
   - Hardware abstraction layers

4. **ESP32 Platform**
   - ESP32-C6 peripherals
   - Clock and power management
   - Flash memory organization
   - Development tools (esptool, etc.)

---

## 🏁 Conclusion

You have everything you need to successfully port Tock OS to the ESP32-C6:

✅ **Hardware:** nanoESP32-C6 board (excellent choice with 8MB flash!)  
✅ **Documentation:** Comprehensive difference analysis and porting plan  
✅ **Reference:** Working ESP32-C3 implementation  
✅ **Plan:** Clear 4-phase approach with detailed steps

**Next Action:** Verify your hardware works, then begin Phase 1!

```bash
# Test your board right now:
cd nanoESP32-C6
./demo/flash_write.sh /dev/ttyACM0
# Watch the RGB LED blink - you're ready to start!
```

**Good luck with the port! 🚀**

---

*For questions or updates, refer to the specific documentation files or open an issue in the Tock repository.*
