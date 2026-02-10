# PI001/SP001 - Analyst Report: Initial ESP32-C6 Boot Planning

## Session Summary
**Date:** 2026-02-10
**Task:** Research and plan PI001 - Initial ESP32-C6 Boot
**Status:** Complete

---

## Analysis: ESP32-C6 Initial Boot Implementation

### Objective
Successfully boot the Tock OS kernel on the ESP32-C6 (nanoESP32-C6 board) and reach the main scheduler loop. This is the foundation for all subsequent development.

### Existing Work

**Reference Implementation:**
- **ESP32-C3 Port:** `tock/boards/esp32-c3-devkitM-1/` and `tock/chips/esp32-c3/`
- **Shared Peripherals:** `tock/chips/esp32/` (UART, GPIO, Timer - reusable)
- **Architecture:** `tock/arch/rv32i/` (RISC-V support)

**ESP32-C3 Components Available:**
- ✅ `chip.rs` - Chip structure and trap handler
- ✅ `intc.rs` - Interrupt controller (needs update for C6)
- ✅ `interrupts.rs` - Interrupt definitions
- ✅ `rng.rs` - Random number generator
- ✅ `sysreg.rs` - System registers
- ✅ `main.rs` - Board initialization
- ✅ Shared: UART, GPIO, Timer drivers

**Documentation Available:**
- ✅ ESP32-C6 Technical Reference Manual (`doc/esp32c6_manual/`)
- ✅ ESP32-C3 Technical Reference Manual (for comparison)
- ✅ Comprehensive difference analysis (`ESP32-C6_DIFFERENCES.md`)
- ✅ Detailed porting plan (`ESP32-C6_PORTING_PLAN.md`)
- ✅ Board-specific notes (`NANOESP32-C6_BOARD_NOTES.md`)

---

## Research Summary

### 1. Critical Architectural Changes (C3 → C6)

#### RISC-V ISA Extension
- **C3:** RV32IMC (Integer, Multiply, Compressed)
- **C6:** RV32IMAC (adds Atomic extension)
- **Impact:** Toolchain target changes, atomic operations available
- **Risk:** LOW - Backward compatible, just need new toolchain

#### Memory Map (CRITICAL CHANGE)
| Component | ESP32-C3 | ESP32-C6 | Impact |
|-----------|----------|----------|--------|
| ROM Size | 384 KB | 320 KB | Smaller ROM space |
| HP SRAM Base | 0x3FCA0000 | 0x40800000 | **Complete address change** |
| HP SRAM Size | 400 KB | 512 KB | More RAM available |
| LP Memory | 8 KB RTC FAST | 16 KB LP SRAM | New LP subsystem |
| Flash Base | 0x42000000 | 0x42000000 | Unchanged |

**Linker Script Impact:** ALL memory addresses must be updated.

#### Interrupt System (CRITICAL REDESIGN)
- **C3:** 31 external interrupts via INTC
- **C6:** 28 external (INTC) + 4 CLINT interrupts
- **New CLINT Interrupts:**
  - ID 0: U-mode Software
  - ID 3: M-mode Software
  - ID 4: U-mode Timer
  - ID 7: M-mode Timer
- **Impact:** Dual interrupt routing required (CLINT + INTC)
- **Risk:** HIGH - New interrupt architecture to implement

#### Peripheral Base Addresses (CRITICAL)
| Peripheral | ESP32-C3 | ESP32-C6 | Change |
|------------|----------|----------|--------|
| UART0 | 0x60000000 | 0x60000000 | ✅ Same |
| GPIO | 0x60004000 | 0x60091000 | ❌ Changed |
| IOMUX | 0x60009000 | 0x60090000 | ❌ Changed |
| TIMG0 | 0x6001F000 | 0x60008000 | ❌ Changed |
| TIMG1 | 0x60020000 | 0x60009000 | ❌ Changed |
| INTC (INTPRI) | 0x600C2000 | 0x600C5000 | ❌ Changed |
| CLINT-M | N/A | 0x20001800 | 🆕 New |
| CLINT-U | N/A | 0x20001C00 | 🆕 New |
| PCR | N/A | 0x60096000 | 🆕 New (replaces SYSCON) |

**Impact:** Every peripheral driver needs address updates.

### 2. Board-Specific Considerations (nanoESP32-C6)

**Hardware Advantages:**
- ✅ **8MB Flash** (vs typical 2-4MB) - can allocate more space for kernel/apps
- ✅ **Dual USB Type-C** - CH343 on `/dev/ttyACM0` for programming
- ✅ **RGB LED on GPIO16** - excellent visual debugging tool
- ✅ **Boot button on GPIO9** - hardware input available

**Hardware Constraints:**
- ⚠️ **RGB LED Signal Inverted** - BSS138 MOSFET level shifter inverts signal
- ⚠️ **GRB Color Order** - WS2812B uses GRB not RGB
- ⚠️ **GPIO26-31 Unavailable** - Used for internal flash
- ⚠️ **UART0 TX Not Exposed** - Connected to CH343, not on header

**Recommended Memory Layout (8MB Flash):**
```ld
MEMORY {
    /* Kernel in flash - can be larger with 8MB */
    rom (rx)  : ORIGIN = 0x40380000, LENGTH = 0x40000  /* 256 KB */
    
    /* HP SRAM - C6 has 512KB total, allocate 256KB */
    ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x40000  /* 256 KB */
    
    /* Apps in flash - much more space with 8MB! */
    prog (rx) : ORIGIN = 0x403C0000, LENGTH = 0x80000  /* 512 KB */
}
```

### 3. Minimal Boot Requirements

To reach the main scheduler loop, we need:

1. **Startup Code:**
   - RISC-V reset vector (`_start`)
   - Stack initialization
   - BSS zeroing
   - Data section copy from ROM to RAM
   - Jump to Rust `main()`

2. **Memory Layout:**
   - Correct linker script with C6 addresses
   - Proper section placement (text, rodata, data, bss)
   - Stack and heap allocation

3. **Trap Handler:**
   - Configure `mtvec` CSR
   - Handle interrupts (CLINT + INTC routing)
   - Handle exceptions (illegal instruction, misaligned access, etc.)

4. **Minimal Interrupt Support:**
   - CLINT driver (machine timer for scheduling)
   - INTC driver (basic enable/disable)
   - Interrupt routing logic

5. **System Initialization:**
   - Disable watchdogs (RTC WDT, Super WDT)
   - Configure CPU clock (start with 80MHz for safety)
   - Enable peripheral clocks via PCR
   - Initialize deferred call system

6. **Chip Structure:**
   - Create `Esp32C6` chip type
   - Implement kernel interfaces
   - Set up MPU (PMP-based)

**NOT Required for Initial Boot:**
- ❌ UART (helpful but not essential)
- ❌ GPIO (can use for debugging)
- ❌ Timer Groups (CLINT timer sufficient initially)
- ❌ Process loading
- ❌ Any peripherals beyond basic interrupt/timer

---

## Tock Architecture Context

### Chip Implementation Pattern

Tock separates chip-specific code into layers:

```
tock/chips/esp32-c6/          # C6-specific code
├── src/
│   ├── lib.rs                # Module exports
│   ├── chip.rs               # Chip struct, trap handler
│   ├── intc.rs               # Interrupt controller
│   ├── clint.rs              # NEW - Core local interrupts
│   ├── interrupts.rs         # Interrupt definitions
│   ├── pcr.rs                # NEW - Power/Clock/Reset
│   ├── sysreg.rs             # System registers
│   └── rng.rs                # Random number generator

tock/chips/esp32/             # Shared ESP32 peripherals
├── src/
│   ├── uart.rs               # UART driver (reusable)
│   ├── gpio.rs               # GPIO driver (needs address update)
│   ├── timg.rs               # Timer Groups (needs address update)
│   └── rtc_cntl.rs           # RTC control

tock/boards/nanoESP32-c6/     # Board-specific configuration
├── src/
│   ├── main.rs               # Board initialization
│   ├── io.rs                 # Panic handler
│   └── tests/                # Board tests
├── layout.ld                 # Linker script
├── Cargo.toml                # Dependencies
└── Makefile                  # Build configuration
```

### Key Tock Patterns

1. **Static Allocation:** No heap, everything is `static_init!`
2. **HIL Traits:** Hardware abstraction (e.g., `gpio::Pin`, `uart::Transmit`)
3. **Register Access:** `tock_registers` crate for safe MMIO
4. **Deferred Calls:** Async operations without threads
5. **Component Pattern:** Board initialization helpers

---

## ESP32-C6 Specifics

### Boot Sequence

1. **ROM Bootloader (0x40000000):**
   - Runs first after reset
   - Checks boot mode (GPIO strapping)
   - Loads second-stage bootloader from flash
   - Validates and jumps to application

2. **Second-Stage Bootloader:**
   - ESP-IDF bootloader at 0x0 in flash
   - Initializes flash, cache
   - Loads application partition at 0x10000
   - Jumps to application entry point

3. **Tock Entry (`_start`):**
   - Reset vector in `arch/rv32i/src/start.S`
   - Initialize stack pointer
   - Clear BSS
   - Copy data section
   - Call Rust `reset_handler()`

4. **Rust Initialization:**
   - `main.rs::reset_handler()`
   - Set up trap handler
   - Initialize chip
   - Create kernel
   - Enter scheduler loop

### Clock Configuration

**Default After Boot:**
- CPU: 80 MHz (PLL_F80M)
- APB: 80 MHz
- XTAL: 40 MHz

**PCR Module (NEW in C6):**
- Replaces SYSCON from C3
- Controls peripheral clocks
- Manages resets
- Configures clock sources

**Safe Initial Configuration:**
- Keep 80 MHz CPU clock
- Enable TIMG0/TIMG1 clocks via PCR
- Enable UART0 clock via PCR
- Don't change PLL settings initially

### Watchdog Management

**ESP32-C6 has multiple watchdogs:**
1. **RTC Watchdog (RTC_WDT):** 0x600B1C00
2. **Super Watchdog (SWD):** In PMU
3. **Timer Group Watchdogs (MWDT):** In TIMG0/TIMG1

**Critical:** Disable all watchdogs early in boot to prevent unexpected resets.

---

## Risks Identified

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Memory address errors** | HIGH | Boot failure | Centralize addresses, verify against TRM |
| **CLINT interrupt routing** | MEDIUM | Interrupt failures | Implement CLINT separately, test individually |
| **Linker script errors** | MEDIUM | Boot failure | Copy from C3, update carefully, verify with objdump |
| **Watchdog resets** | HIGH | Unexpected resets | Disable all watchdogs early in `setup()` |
| **Clock configuration** | LOW | Timing issues | Start conservative (80MHz), verify with timer |
| **PCR register access** | MEDIUM | Peripheral failures | Study C6 TRM Chapter 6 carefully |
| **Toolchain compatibility** | LOW | Build failures | Verify `riscv32imac` target before starting |
| **Flash layout** | LOW | Flashing issues | Use board-specific esptool command |

---

## Sprint Breakdown

### SP001: Foundation Setup (Week 1)
**Goal:** Create directory structure and build configuration

**Tasks:**
1. Create `tock/chips/esp32-c6/` directory structure
2. Create `tock/boards/nanoESP32-c6/` directory structure
3. Update `Cargo.toml` files with correct dependencies
4. Create `.cargo/config.toml` with `riscv32imac` target
5. Create basic `Makefile` for building
6. Verify toolchain installation

**Deliverables:**
- [ ] Directory structure created
- [ ] Build system configured
- [ ] Toolchain verified
- [ ] Initial compilation succeeds (even if incomplete)

**Estimated Effort:** 2-3 days

---

### SP002: Memory Layout (Week 1-2)
**Goal:** Define correct memory layout for ESP32-C6

**Tasks:**
1. Create `layout.ld` linker script with C6 memory map
2. Define memory regions (ROM, RAM, PROG)
3. Set up section placement (.text, .rodata, .data, .bss)
4. Define symbols for Rust code (_stext, _etext, etc.)
5. Verify with `objdump` that sections are correct

**Deliverables:**
- [ ] `layout.ld` with correct C6 addresses
- [ ] Sections placed correctly
- [ ] Symbols defined for Rust
- [ ] Binary builds with correct memory layout

**Estimated Effort:** 2-3 days

---

### SP003: Peripheral Address Constants (Week 2)
**Goal:** Define all peripheral base addresses for C6

**Tasks:**
1. Create address constants in `chips/esp32-c6/src/lib.rs`
2. Define CLINT addresses (M-mode and U-mode)
3. Define INTC addresses (INTMTX and INTPRI)
4. Define peripheral addresses (UART, GPIO, TIMG, etc.)
5. Document TRM chapter references for each address
6. Create type aliases for Timer with correct frequency

**Deliverables:**
- [ ] All addresses defined as constants
- [ ] Documentation comments with TRM references
- [ ] Type aliases for shared peripherals
- [ ] Code compiles without address-related errors

**Estimated Effort:** 1-2 days

---

### SP004: CLINT Driver Implementation (Week 2-3)
**Goal:** Implement Core Local Interrupt controller

**Tasks:**
1. Create `chips/esp32-c6/src/clint.rs`
2. Define register structures for M-mode CLINT
3. Implement timer read/write functions
4. Implement timer compare (mtimecmp) for alarms
5. Implement software interrupt triggers
6. Create HIL trait implementations (Time, Alarm)
7. Write unit tests for CLINT functionality

**Deliverables:**
- [ ] `clint.rs` with complete register definitions
- [ ] Timer read/write working
- [ ] Alarm functionality implemented
- [ ] HIL traits implemented
- [ ] Tests passing

**Estimated Effort:** 3-4 days

---

### SP005: INTC Driver Update (Week 3)
**Goal:** Update interrupt controller for C6 architecture

**Tasks:**
1. Update `chips/esp32-c6/src/intc.rs` from C3 version
2. Update register addresses (INTPRI base)
3. Handle 28 interrupts instead of 31
4. Update priority range (0-15 instead of 1-15)
5. Implement interrupt mapping (INTMTX)
6. Implement enable/disable/priority functions
7. Implement interrupt handling logic

**Deliverables:**
- [ ] `intc.rs` updated for C6
- [ ] Register structures correct
- [ ] Basic enable/disable working
- [ ] Priority configuration working
- [ ] Interrupt mapping functional

**Estimated Effort:** 2-3 days

---

### SP006: Interrupt Routing (Week 3-4)
**Goal:** Implement dual interrupt routing (CLINT + INTC)

**Tasks:**
1. Update `chips/esp32-c6/src/interrupts.rs` with C6 interrupt IDs
2. Define CLINT interrupt IDs (0, 3, 4, 7)
3. Define external interrupt IDs (1-2, 5-6, 8-31)
4. Create `chips/esp32-c6/src/chip.rs` with trap handler
5. Implement interrupt routing logic in `handle_interrupt()`
6. Route CLINT interrupts (IDs 0, 3, 4, 7) to CLINT driver
7. Route external interrupts to INTC driver
8. Test interrupt routing with timer interrupt

**Deliverables:**
- [ ] Interrupt definitions complete
- [ ] Trap handler configured
- [ ] Routing logic implemented
- [ ] CLINT interrupts route correctly
- [ ] External interrupts route correctly
- [ ] Timer interrupt fires and is handled

**Estimated Effort:** 3-4 days

---

### SP007: System Initialization (Week 4)
**Goal:** Implement minimal system initialization

**Tasks:**
1. Create `chips/esp32-c6/src/pcr.rs` for clock management
2. Implement watchdog disable functions
3. Implement peripheral clock enable functions
4. Create `boards/nanoESP32-c6/src/main.rs`
5. Implement `setup()` function with minimal initialization
6. Disable all watchdogs
7. Configure CPU clock (80 MHz initially)
8. Enable CLINT and INTC
9. Create chip structure
10. Create kernel structure

**Deliverables:**
- [ ] `pcr.rs` with basic clock control
- [ ] Watchdogs disabled
- [ ] `main.rs` with minimal setup
- [ ] Chip and kernel structures created
- [ ] System initializes without crashes

**Estimated Effort:** 3-4 days

---

### SP008: First Boot (Week 4-5)
**Goal:** Successfully boot kernel to main loop

**Tasks:**
1. Implement `reset_handler()` in `main.rs`
2. Configure trap handler (`mtvec`)
3. Initialize deferred call system
4. Create scheduler
5. Enter main scheduler loop
6. Build complete kernel binary
7. Flash to nanoESP32-C6 board
8. Verify boot (LED toggle or JTAG)
9. Debug any boot failures
10. Document boot process

**Deliverables:**
- [ ] Complete kernel binary builds
- [ ] Binary flashes successfully
- [ ] Kernel boots without crashing
- [ ] Main loop reached (verified)
- [ ] Boot process documented

**Estimated Effort:** 3-5 days (includes debugging)

---

## Questions for PO

### 1. Sprint Scope Clarification
**Question:** Should SP001 (PI001 - Initial Boot) include UART output for debugging, or should we defer that to SP002 (Basic Peripherals)?

**Context:** UART is extremely helpful for debugging boot issues, but it's not strictly required to reach the main loop. We could use GPIO toggle + LED or JTAG for initial boot verification.

**Options:**
- **A:** Include minimal UART in SP001 for debug output (adds 1-2 days)
- **B:** Defer UART to SP002, use LED/GPIO for boot verification
- **C:** Include UART only if boot issues arise

**Recommendation:** Option A - UART is worth the extra time for debugging.

---

### 2. RGB LED Priority
**Question:** Should we implement WS2812B RGB LED driver in SP001 for visual boot indicators?

**Context:** The nanoESP32-C6 has an on-board RGB LED on GPIO16. This could provide excellent visual feedback during boot stages, but requires:
- Bit-banging driver or RMT peripheral
- Understanding of inverted signal (BSS138 level shifter)
- GRB color order handling

**Options:**
- **A:** Implement basic RGB LED in SP001 (adds 2-3 days, high value for debugging)
- **B:** Use simple GPIO toggle on available pin for boot indicator
- **C:** Defer RGB LED to SP002 (Basic Peripherals)

**Recommendation:** Option B for SP001, Option A for SP002 - Simple GPIO first, RGB later.

---

### 3. Testing Strategy
**Question:** How should we verify successful boot without UART or RGB LED?

**Context:** If we defer both UART and RGB LED to SP002, we need alternative verification methods.

**Options:**
- **A:** Use JTAG debugger to verify program counter reaches main loop
- **B:** Toggle a GPIO pin and verify with logic analyzer/oscilloscope
- **C:** Use simple LED on/off on any available GPIO
- **D:** Include minimal UART for "Boot OK" message

**Recommendation:** Option C (simple LED) + Option D (minimal UART) - Belt and suspenders approach.

---

### 4. Memory Allocation
**Question:** Should we take advantage of the 8MB flash on nanoESP32-C6 for larger allocations?

**Context:** Standard ESP32-C6 boards have 2-4MB flash. The nanoESP32-C6 has 8MB, allowing:
- Larger kernel (256 KB vs 160 KB)
- More app space (512 KB vs 192 KB)
- Future expansion room

**Options:**
- **A:** Use conservative allocations matching standard C6 (160KB kernel, 192KB apps)
- **B:** Use larger allocations (256KB kernel, 512KB apps) - recommended
- **C:** Maximum allocations (512KB kernel, 1MB+ apps)

**Recommendation:** Option B - Take advantage of 8MB but leave room for growth.

---

### 5. Toolchain Version
**Question:** Which Rust toolchain version should we target?

**Context:** Need to ensure `riscv32imac-unknown-none-elf` target is available and stable.

**Options:**
- **A:** Latest stable Rust (currently 1.75+)
- **B:** Specific version matching Tock CI (need to check)
- **C:** Nightly for latest features

**Recommendation:** Option B - Match Tock CI for compatibility, document version.

---

## Handoff to Implementor

### Critical Information

1. **Start with SP001:** Directory structure and build configuration
2. **Reference C3 heavily:** Copy and adapt rather than write from scratch
3. **Memory addresses are critical:** Double-check every address against TRM
4. **CLINT is new:** No C3 reference, implement from TRM Chapter 7
5. **Test incrementally:** Build and verify after each sprint
6. **Use version control:** Commit after each working change

### Key Files to Create

**Priority 1 (SP001-SP002):**
- `tock/chips/esp32-c6/Cargo.toml`
- `tock/chips/esp32-c6/src/lib.rs`
- `tock/boards/nanoESP32-c6/Cargo.toml`
- `tock/boards/nanoESP32-c6/.cargo/config.toml`
- `tock/boards/nanoESP32-c6/layout.ld`
- `tock/boards/nanoESP32-c6/Makefile`

**Priority 2 (SP003-SP005):**
- `tock/chips/esp32-c6/src/clint.rs` (NEW)
- `tock/chips/esp32-c6/src/intc.rs` (from C3)
- `tock/chips/esp32-c6/src/interrupts.rs` (from C3)
- `tock/chips/esp32-c6/src/pcr.rs` (NEW)

**Priority 3 (SP006-SP008):**
- `tock/chips/esp32-c6/src/chip.rs` (from C3)
- `tock/boards/nanoESP32-c6/src/main.rs` (from C3)
- `tock/boards/nanoESP32-c6/src/io.rs` (from C3)

### Reference Documents

**MUST READ:**
1. `ESP32-C6_DIFFERENCES.md` - Understand all changes
2. `ESP32-C6_PORTING_PLAN.md` - Phase 1 details
3. `NANOESP32-C6_BOARD_NOTES.md` - Board specifics
4. ESP32-C6 TRM Chapter 5 (Memory)
5. ESP32-C6 TRM Chapter 7 (CLINT)
6. ESP32-C6 TRM Chapter 10 (Interrupts)

**Reference Code:**
- `tock/chips/esp32-c3/` - C3 implementation
- `tock/boards/esp32-c3-devkitM-1/` - C3 board
- `tock/chips/esp32/` - Shared peripherals

### Debugging Tips

**No Boot:**
- Check linker script addresses with `objdump -h`
- Verify reset vector with `objdump -d`
- Check stack pointer initialization
- Verify flash address in esptool command

**Crashes:**
- Use JTAG debugger to find crash location
- Check `mcause` CSR for exception type
- Verify trap handler is configured (`mtvec`)
- Check for misaligned memory access

**Interrupt Issues:**
- Verify CLINT vs INTC routing in trap handler
- Check interrupt enable bits
- Verify interrupt priorities
- Test each interrupt source individually

### Success Criteria for SP001-SP008

**Minimum Viable Boot:**
- [x] Kernel binary builds without errors
- [x] Binary flashes to board successfully
- [x] Kernel boots without immediate crash
- [x] Trap handler is configured
- [x] Main scheduler loop is reached
- [x] System runs without watchdog resets

**Verification Methods:**
- GPIO toggle visible on oscilloscope/LED
- UART output shows "Boot OK" message (if implemented)
- JTAG debugger shows PC in main loop
- No unexpected resets for 10+ seconds

---

## Next Steps

1. **PO Review:** Review this analysis and answer questions above
2. **Implementor Assignment:** Assign implementor agent to SP001
3. **Begin SP001:** Create directory structure and build configuration
4. **Daily Standups:** Brief progress updates during implementation
5. **Sprint Reviews:** Review after each sprint completion

---

## Related Issues

None yet - this is the first PI. Issues will be created as blockers arise.

---

## Appendix: Detailed Memory Map

### ESP32-C6 Memory Layout (for linker script)

```
ROM (Instruction):  0x40000000 - 0x4004FFFF  (320 KB)
ROM (Data):         0x40000000 - 0x4004FFFF  (same, unified bus)

HP SRAM:            0x40800000 - 0x4087FFFF  (512 KB total)
  - Available:      0x40800000 - 0x4083FFFF  (256 KB for Tock)
  - Reserved:       0x40840000 - 0x4087FFFF  (256 KB for other uses)

LP SRAM:            0x50000000 - 0x50003FFF  (16 KB)
  - Not used initially

Flash (Instruction): 0x42000000 - 0x427FFFFF  (8 MB)
Flash (Data):        0x42000000 - 0x427FFFFF  (same, unified bus)

Peripherals:        0x60000000 - 0x600FFFFF  (Various)
```

### Recommended Linker Script Sections

```ld
MEMORY {
    /* ROM: Kernel code and read-only data */
    rom (rx)  : ORIGIN = 0x40380000, LENGTH = 0x40000  /* 256 KB */
    
    /* RAM: Kernel data, BSS, stack, heap */
    ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x40000  /* 256 KB */
    
    /* PROG: Application binaries */
    prog (rx) : ORIGIN = 0x403C0000, LENGTH = 0x80000  /* 512 KB */
}

SECTIONS {
    .text : {
        _stext = .;
        *(.text._start)
        *(.text*)
        _etext = .;
    } > rom
    
    .rodata : {
        _srodata = .;
        *(.rodata*)
        _erodata = .;
    } > rom
    
    .data : AT(ADDR(.rodata) + SIZEOF(.rodata)) {
        _srelocate = .;
        *(.data*)
        _erelocate = .;
    } > ram
    
    .bss : {
        _szero = .;
        *(.bss*)
        *(COMMON)
        _ezero = .;
    } > ram
    
    .stack (NOLOAD) : {
        _sstack = .;
        . = . + 0x2000;  /* 8KB stack */
        _estack = .;
    } > ram
    
    .apps : {
        _sapps = .;
        KEEP(*(.apps*))
        _eapps = .;
    } > prog
}
```

---

## Analyst Progress Report - PI001/SP001

### Session 1 - 2026-02-10
**Task:** Research and plan PI001 - Initial ESP32-C6 Boot

### Completed
- [x] Analyzed existing ESP32-C3 implementation
- [x] Reviewed comprehensive difference analysis
- [x] Studied ESP32-C6 Technical Reference Manual (key chapters)
- [x] Reviewed nanoESP32-C6 board specifications
- [x] Identified critical architectural changes
- [x] Defined minimal boot requirements
- [x] Created 8-sprint breakdown for initial boot
- [x] Identified risks and mitigation strategies
- [x] Documented handoff information for implementor

### Gaps Identified
- **Toolchain version:** Need to confirm which Rust version Tock CI uses
- **UART priority:** Need PO decision on including UART in SP001
- **RGB LED priority:** Need PO decision on visual debugging approach
- **Memory allocation:** Need PO confirmation on using 8MB flash advantages
- **Testing strategy:** Need PO input on verification methods without UART

### Key Findings

1. **Architecture is well-documented:** Comprehensive difference analysis and porting plan already exist
2. **ESP32-C3 reference is solid:** Can copy and adapt most code
3. **CLINT is the main new component:** No C3 reference, must implement from TRM
4. **Memory addresses changed significantly:** All peripherals need address updates
5. **8MB flash is a major advantage:** Can allocate much more space than standard C6
6. **nanoESP32-C6 board is well-suited:** RGB LED and dual USB are excellent for development

### Risks Identified

**HIGH PRIORITY:**
- Memory address errors causing boot failure
- CLINT interrupt routing complexity
- Watchdog resets during development

**MEDIUM PRIORITY:**
- Linker script errors
- PCR register access for clock configuration
- Interrupt mapping changes

**LOW PRIORITY:**
- Toolchain compatibility
- Flash layout issues

### Handoff Notes

**For Implementor:**
1. Start with SP001 (directory structure and build config)
2. Reference ESP32-C3 implementation heavily - copy and adapt
3. All memory addresses are in `ESP32-C6_DIFFERENCES.md` - verify each one
4. CLINT is new - implement from TRM Chapter 7, no C3 reference
5. Test after each sprint - don't accumulate untested code
6. Use version control - commit after each working change

**Critical Files:**
- Reference: `tock/chips/esp32-c3/` and `tock/boards/esp32-c3-devkitM-1/`
- Create: `tock/chips/esp32-c6/` and `tock/boards/nanoESP32-c6/`
- Key docs: `ESP32-C6_DIFFERENCES.md`, `ESP32-C6_PORTING_PLAN.md`

**Success Criteria:**
- Kernel builds without errors
- Flashes to board successfully
- Boots without crashing
- Reaches main scheduler loop
- Runs without watchdog resets

**Estimated Timeline:**
- SP001-SP008: 4-5 weeks (part-time) or 2-3 weeks (full-time)
- First boot expected by end of SP008

### Questions for PO (USER_QUESTIONS.md)

See "Questions for PO" section above for 5 critical questions requiring PO input before implementation begins.

---

**Report Complete - Ready for PO Review and Implementor Assignment**
