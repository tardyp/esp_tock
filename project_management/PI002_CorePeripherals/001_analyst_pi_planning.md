# PI002 - Core Peripherals Planning

**Report:** 001_analyst_pi_planning.md  
**Date:** 2026-02-12  
**Analyst:** Analyst Agent  
**Status:** COMPREHENSIVE ANALYSIS COMPLETE

---

## Executive Summary

### PI002 Goal

Implement essential peripheral drivers and interrupt infrastructure to enable full kernel functionality on ESP32-C6, building upon the successful PI001 boot achievement.

### Key Deliverables

1. **Watchdog Management** - Disable/control RTC WDT, Super WDT, MWDT0/MWDT1
2. **Clock Configuration** - PCR-based peripheral clock management
3. **Interrupt Controller** - Complete INTC (INTMTX + INTPRI) driver implementation
4. **Timer Drivers** - Full TIMG0/TIMG1 functionality with alarm support
5. **GPIO Driver** - Complete digital I/O with interrupt support
6. **Console Infrastructure** - UART-based debug console

### Success Criteria

- ✅ No unexpected watchdog resets during operation
- ✅ Peripheral clocks properly configured via PCR
- ✅ Interrupts route correctly through INTC
- ✅ Timers fire interrupts and handle alarms
- ✅ GPIO input/output and interrupts working
- ✅ Console output for debugging
- ✅ All 11/11 tests passing with new infrastructure

### Current Status (Post-PI001)

**Working:**
- ✅ Kernel boots successfully
- ✅ USB-JTAG serial output functional
- ✅ UART driver implemented (basic)
- ✅ "Hello World from Tock!" displayed
- ✅ Autonomous test infrastructure in place
- ✅ Build: 0.46s, 11/11 tests passing

**Outstanding Technical Debt:**
- Issue #2 (HIGH): Watchdog not disabled - may cause unexpected resets
- Issue #3 (MEDIUM): Clock configuration missing - using bootloader defaults
- Issue #4 (HIGH): INTC driver placeholder - no interrupt routing
- Issue #5 (HIGH): PMP disabled - no userspace memory protection (defer to PI003)
- Issue #1 (LOW): Unused FAULT_RESPONSE constant
- Issue #6 (LOW): Clippy false positive on Writer struct

---

## Technical Analysis

### 1. Peripheral Architecture Review

#### 1.1 Watchdog Timers (Chapter 15)

**Reference:** ESP32-C6 TRM Chapter 15 - Watchdog Timers (WDT)

**Architecture:**
ESP32-C6 has **four** watchdog timers:

| Watchdog | Location | Base Address | Clock Source | Purpose |
|----------|----------|--------------|--------------|---------|
| **MWDT0** | Timer Group 0 | 0x6000_8000 | PLL_F80M/XTAL/RC_FAST | Main system watchdog |
| **MWDT1** | Timer Group 1 | 0x6000_9000 | PLL_F80M/XTAL/RC_FAST | Secondary watchdog |
| **RTC WDT** | RTC Module | 0x600B_1C00 | RTC_SLOW_CLK | RTC watchdog |
| **Super WDT** | PMU (analog) | PMU registers | Analog | Ultra-low-power watchdog |

**Key Features (TRM 15.2.1):**
- Four configurable stages per watchdog
- Timeout actions: interrupt, CPU reset, core reset, system reset (RWDT only)
- Flash boot protection enabled by default
- Write protection on WDT registers

**Critical Finding:**
> "During the flash boot process, RWDT and the MWDT in timer group 0 are enabled automatically in order to detect and recover from booting errors." (TRM 15.1)

**Impact:** Issue #2 is CRITICAL - MWDT0 and RTC WDT are enabled by bootloader and MUST be disabled early in kernel initialization to prevent unexpected resets.

**Register Access (TRM 15.2.2):**
- MWDT: `TIMG_WDT_EN` in `TIMG_WDTCONFIG0_REG`
- RTC WDT: `RTC_WDT_EN` in RTC registers
- Super WDT: PMU configuration registers

**Verification:** ✅ Confirmed from TRM Chapter 15, Section 15.1 and 15.2

---

#### 1.2 Clock Configuration (Chapter 8)

**Reference:** ESP32-C6 TRM Chapter 8 - Reset and Clock

**PCR Module (Power, Clock, and Reset):**
- **Base Address:** 0x6009_6000 (ESP32-C6_DIFFERENCES.md line 799)
- **Replaces:** SYSCON module from ESP32-C3
- **Function:** Unified control of peripheral power, clocks, and resets

**Key PCR Registers (TRM 8.4):**
- `PCR_SYSCLK_CONF_REG` - System clock configuration
- `PCR_CPU_FREQ_CONF_REG` - CPU frequency control
- `PCR_TIMERGROUP0_CONF_REG` - TIMG0 clock/reset
- `PCR_TIMERGROUP1_CONF_REG` - TIMG1 clock/reset
- `PCR_TIMERGROUP0_TIMER_CLK_CONF_REG` - TIMG0 timer clock source
- `PCR_TIMERGROUP0_WDT_CLK_CONF_REG` - TIMG0 watchdog clock
- `PCR_UART0_CONF_REG` - UART0 clock/reset
- `PCR_UART1_CONF_REG` - UART1 clock/reset
- `PCR_IO_CLK_CONF_REG` - GPIO clock configuration

**Clock Sources (TRM 8.2, Table 8.2-1):**
- **XTAL_CLK:** 40 MHz (external crystal)
- **PLL_CLK:** 480 MHz (PLL output)
- **PLL_F80M_CLK:** 80 MHz (PLL/6)
- **RC_FAST_CLK:** ~17.5 MHz (internal RC oscillator)

**Timer Clock Selection (TRM 14.3.1):**
For TIMG0/TIMG1, clock source is selected via:
- `PCR_TG0_TIMER_CLK_SEL` in `PCR_TIMERGROUP0_TIMER_CLK_CONF_REG`
  - 0 = XTAL_CLK (40 MHz)
  - 1 = PLL_F80M_CLK (80 MHz)
  - 2 = RC_FAST_CLK (~17.5 MHz)

**Default After Boot (TRM 8.2):**
- CPU: 80 MHz (PLL_F80M via bootloader)
- APB: 80 MHz
- XTAL: 40 MHz

**Impact:** Issue #3 - Need PCR driver to properly enable/configure peripheral clocks. Current code relies on bootloader defaults which may not be stable.

**Verification:** ✅ Confirmed from TRM Chapter 8, Section 8.2 and 8.4

---

#### 1.3 Interrupt Controller (Chapter 10)

**Reference:** ESP32-C6 TRM Chapter 10 - Interrupt Matrix (INTMTX)

**Architecture Change from C3:**
ESP32-C3 had single INTC module. ESP32-C6 splits into two components:

| Component | Base Address | Function |
|-----------|--------------|----------|
| **INTMTX** | 0x6001_0000 | Interrupt Matrix - maps peripheral sources to CPU interrupts |
| **INTPRI** | 0x600C_5000 | Interrupt Priority - controls priority, enable, threshold |

**Interrupt Sources (TRM 10.3.1, Table 10.3-1):**
- **77 peripheral interrupt sources** (numbered 0-76)
- **28 CPU peripheral interrupts** (IDs 1-2, 5-6, 8-31)
- **4 CLINT interrupts** (IDs 0, 3, 4, 7 - reserved, cannot be mapped)

**Key INTMTX Registers:**
- `INTMTX_CORE0_MAP_n` (n = 0-76) - Map peripheral source n to CPU interrupt

**Key INTPRI Registers (from C3 pattern, updated names):**
- `INTPRI_CORE0_CPU_INT_ENABLE_REG` - Enable mask
- `INTPRI_CORE0_CPU_INT_TYPE_REG` - Level/edge configuration
- `INTPRI_CORE0_CPU_INT_THRESH_REG` - Priority threshold
- `INTPRI_CORE0_CPU_INT_CLEAR_REG` - Clear pending interrupts
- `INTPRI_CORE0_CPU_INT_EIP_STATUS_REG` - Interrupt pending status
- `INTPRI_CORE0_CPU_INT_PRI_n_REG` (n = 0-31) - Priority for interrupt n

**Priority Levels (TRM 10.2):**
- **Range:** 0-15 (0 = lowest, 15 = highest)
- **Note:** Changed from ESP32-C3 which used 1-15

**Critical Peripheral Interrupt Numbers (TRM 10.3.1, Table 10.3-1):**
Need to verify these from TRM table - ASSUMPTION until verified:
- UART0: Source #21
- UART1: Source #22
- GPIO: Source #8
- TIMG0: Source #14
- TIMG1: Source #15

**Impact:** Issue #4 - Current placeholder must be replaced with full INTMTX + INTPRI driver.

**Verification:** ✅ Confirmed architecture from TRM Chapter 10. ⚠️ Specific interrupt numbers need TRM table verification.

---

#### 1.4 Timer Groups (Chapter 14)

**Reference:** ESP32-C6 TRM Chapter 14 - Timer Group (TIMG)

**Base Addresses (ESP32-C6_DIFFERENCES.md):**
- TIMG0: 0x6000_8000 ✅ (verified in tock/chips/esp32-c6/src/lib.rs:23)
- TIMG1: 0x6000_9000 ✅ (verified in tock/chips/esp32-c6/src/lib.rs:24)

**Architecture (TRM 14.1):**
Each timer group contains:
- **1 general-purpose timer (T0)** - 54-bit counter with alarm
- **1 Main System Watchdog Timer (MWDT)** - covered in section 1.1

**Timer Features (TRM 14.2):**
- 54-bit time-base counter (up/down counting)
- 16-bit prescaler (divisor 2-65536)
- Three clock sources: PLL_F80M_CLK, XTAL_CLK, RC_FAST_CLK
- Programmable alarm generation
- Auto-reload capability
- ETM (Event Task Matrix) support

**Clock Configuration (TRM 14.3.1):**
- Clock source selected via PCR module (not timer registers)
- `PCR_TG0_TIMER_CLK_SEL` in `PCR_TIMERGROUP0_TIMER_CLK_CONF_REG`
- Clock enable via `PCR_TG0_TIMER_CLK_EN`

**Key Registers:**
- `TIMG_T0CONFIG_REG` - Timer configuration
- `TIMG_T0LO_REG` / `TIMG_T0HI_REG` - Counter value (54-bit split)
- `TIMG_T0ALARMLO_REG` / `TIMG_T0ALARMHI_REG` - Alarm value
- `TIMG_T0LOADLO_REG` / `TIMG_T0LOADHI_REG` - Load value for reload
- `TIMG_T0LOAD_REG` - Trigger reload
- `TIMG_INT_ENA_REG` - Interrupt enable
- `TIMG_INT_RAW_REG` - Raw interrupt status
- `TIMG_INT_CLR_REG` - Interrupt clear

**Current Implementation Status:**
- ✅ Basic timer driver exists: `tock/chips/esp32/timg.rs`
- ✅ ESP32-C6 uses it with correct addresses: `tock/chips/esp32-c6/src/lib.rs:28`
- ⚠️ Clock source configuration via PCR not yet implemented

**Impact:** Timer driver mostly working, needs PCR integration for proper clock configuration.

**Verification:** ✅ Confirmed from TRM Chapter 14 and existing code

---

#### 1.5 GPIO System (Chapter 7)

**Reference:** ESP32-C6 TRM Chapter 7 - IO MUX and GPIO Matrix

**Base Addresses (ESP32-C6_DIFFERENCES.md):**
- GPIO Matrix: 0x6009_1000 (changed from C3: 0x6000_4000)
- IO MUX: 0x6009_0000 (changed from C3: 0x6000_9000)
- LP IO MUX: 0x600B_2000 (new in C6)

**Pin Count (TRM 7.1):**
- **Total:** 31 GPIO pins (GPIO0-GPIO30)
- **Available:** Depends on package variant
  - QFN40 with in-package flash: 22 GPIOs (GPIO26-31 used for flash)
  - QFN40 with external flash: 30 GPIOs (GPIO26-27 used for flash)

**Features (TRM 7.2):**
- Full switching matrix (85 inputs, 93 outputs)
- Interrupt support (rising/falling/both/level)
- Pull-up/pull-down resistors
- Open-drain mode
- Drive strength configuration
- Signal filtering (GPIO Filter + Glitch Filter)
- Sigma-delta modulation (SDM) output

**Key Registers:**
- `GPIO_OUT_REG` - Output value
- `GPIO_OUT_W1TS_REG` - Set bits (write-1-to-set)
- `GPIO_OUT_W1TC_REG` - Clear bits (write-1-to-clear)
- `GPIO_ENABLE_REG` - Output enable
- `GPIO_IN_REG` - Input value
- `GPIO_STATUS_REG` - Interrupt status
- `GPIO_PIN0_REG` ... `GPIO_PIN30_REG` - Per-pin configuration
- `IO_MUX_GPIO0_REG` ... `IO_MUX_GPIO30_REG` - Pin multiplexing

**Current Implementation:**
- ✅ Basic GPIO driver exists: `tock/chips/esp32-c6/src/gpio.rs`
- ⚠️ Need to verify it handles 31 pins (vs 22 in C3)
- ⚠️ Interrupt support may need updates

**Verification:** ✅ Confirmed from TRM Chapter 7

---

#### 1.6 UART Controllers (Chapter 27)

**Reference:** ESP32-C6 TRM Chapter 27 - UART Controller

**Base Addresses (ESP32-C6_DIFFERENCES.md):**
- UART0: 0x6000_0000 ✅ (unchanged from C3)
- UART1: 0x6000_1000 ❌ (changed from C3: 0x6001_0000)
- LP_UART: 0x600B_1400 (new in C6, low-power UART)

**Features:**
- Configurable baud rate
- 128-byte TX/RX FIFOs
- Hardware flow control (RTS/CTS)
- Interrupts for TX/RX
- DMA support via UHCI
- RS485 mode
- IrDA mode

**Current Implementation:**
- ✅ UART driver exists: `tock/chips/esp32/uart.rs`
- ✅ UART0 working (verified by "Hello World" output)
- ⚠️ UART1 address needs update if used

**Verification:** ✅ Confirmed from TRM Chapter 27 and working code

---

### 2. ESP32-C3 vs ESP32-C6 Comparison

**Reference Implementation:** `tock/chips/esp32-c3/`

#### 2.1 Files in ESP32-C3

```
tock/chips/esp32-c3/src/
├── chip.rs         - Chip structure, trap handler, interrupt routing
├── intc.rs         - Interrupt controller driver
├── interrupts.rs   - Interrupt ID definitions
├── rng.rs          - Random number generator
├── sysreg.rs       - System registers
└── lib.rs          - Module exports
```

#### 2.2 What Needs Adaptation for C6

| File | Status | Changes Required |
|------|--------|------------------|
| `chip.rs` | ✅ Exists | Update interrupt handling for INTMTX/INTPRI split |
| `intc.rs` | ❌ Missing | Create new driver for INTMTX + INTPRI architecture |
| `interrupts.rs` | ✅ Exists | Update interrupt IDs from TRM Table 10.3-1 |
| `rng.rs` | ❌ Missing | Port from C3 with address updates |
| `sysreg.rs` | ❌ Missing | Port from C3 with address updates |
| `pcr.rs` | ❌ NEW | Create PCR driver for clock/reset management |
| `watchdog.rs` | ❌ NEW | Create watchdog disable/management functions |

#### 2.3 Shared Peripherals (tock/chips/esp32/)

These can be reused with address updates:
- ✅ `uart.rs` - UART driver (working)
- ✅ `timg.rs` - Timer Group driver (working)
- ⚠️ `gpio.rs` - May need pin count update (22→31)
- ⚠️ `rtc_cntl.rs` - RTC control (may need PMU updates)

**Verification:** ✅ Confirmed by examining existing code structure

---

### 3. Tock Kernel Patterns and HIL Requirements

**Reference:** Tock Kernel Documentation + tock_kernel skill

#### 3.1 HIL Traits Needed

| Peripheral | HIL Trait | Location |
|------------|-----------|----------|
| Timer | `kernel::hil::time::Alarm` | `kernel/src/hil/time.rs` |
| Timer | `kernel::hil::time::Time` | `kernel/src/hil/time.rs` |
| GPIO | `kernel::hil::gpio::Pin` | `kernel/src/hil/gpio.rs` |
| GPIO | `kernel::hil::gpio::InterruptPin` | `kernel/src/hil/gpio.rs` |
| UART | `kernel::hil::uart::Transmit` | `kernel/src/hil/uart.rs` |
| UART | `kernel::hil::uart::Receive` | `kernel/src/hil/uart.rs` |
| UART | `kernel::hil::uart::Configure` | `kernel/src/hil/uart.rs` |

#### 3.2 Interrupt Handling Pattern

**From Tock Kernel Skill:**

```rust
impl InterruptService for Esp32C6DefaultPeripherals {
    unsafe fn service_interrupt(&self, interrupt: u32) -> bool {
        match interrupt {
            interrupts::IRQ_UART0 => self.uart0.handle_interrupt(),
            interrupts::IRQ_TIMER_GROUP0 => self.timg0.handle_interrupt(),
            interrupts::IRQ_TIMER_GROUP1 => self.timg1.handle_interrupt(),
            interrupts::IRQ_GPIO => self.gpio.handle_interrupt(),
            _ => return false,
        }
        true
    }
}
```

**Current Status:**
- ✅ Pattern implemented in `tock/chips/esp32-c6/src/chip.rs:56-66`
- ⚠️ Only handles UART0, TIMG0, TIMG1 currently
- ❌ GPIO interrupt handling not yet added

#### 3.3 Deferred Calls for Async Operations

**Pattern:** Use deferred calls for interrupt-driven operations

```rust
use kernel::deferred_call::{DeferredCall, DeferredCallClient};

impl DeferredCallClient for MyDriver {
    fn handle_deferred_call(&self) {
        // Handle async work
    }
    
    fn register(&'static self) {
        self.deferred_call.register(self);
    }
}
```

**Current Status:**
- ✅ Deferred call system initialized in `main.rs:122-124`
- ⚠️ Peripheral drivers need to register deferred calls

**Verification:** ✅ Confirmed from Tock kernel patterns and existing code

---

### 4. Dependencies Between Components

**Dependency Graph:**

```
PCR (Clock/Reset)
  ↓
  ├─→ TIMG0/TIMG1 (need clock enable)
  ├─→ UART0/UART1 (need clock enable)
  ├─→ GPIO (need clock enable)
  └─→ Watchdogs (need clock for configuration)

INTC (INTMTX + INTPRI)
  ↓
  ├─→ TIMG interrupts
  ├─→ GPIO interrupts
  └─→ UART interrupts

Watchdog Disable
  ↓
  └─→ Stable operation (prevent resets)
```

**Critical Path:**
1. **PCR** must be implemented first (enables peripheral clocks)
2. **Watchdog disable** must happen early (prevents unexpected resets)
3. **INTC** must be complete before peripheral interrupts work
4. **Peripherals** can be implemented once PCR + INTC ready

**Verification:** ✅ Logical analysis based on hardware architecture

---

## Sprint Breakdown (VERIFIED)

### Sprint Prioritization Rationale

**Priority 1: Stability (SP001)**
- Watchdog disable is CRITICAL - prevents unexpected resets
- PCR clock configuration needed for stable peripheral operation
- These resolve Issues #2 and #3 (both HIGH priority)

**Priority 2: Interrupt Infrastructure (SP002)**
- INTC driver needed for all interrupt-driven peripherals
- Resolves Issue #4 (HIGH priority)
- Blocks GPIO interrupts, UART interrupts, timer interrupts

**Priority 3: Core Peripherals (SP003-SP005)**
- Timer, GPIO, Console build on stable foundation
- Enable full kernel functionality
- Support application development

---

### SP001: Watchdog & Clock Management

**Goal:** Resolve critical stability issues by disabling watchdogs and implementing PCR-based clock configuration.

**Resolves:** Issue #2 (HIGH), Issue #3 (MEDIUM)

**Dependencies:** None (foundation sprint)

**Tasks:**

1. **Create PCR Driver** (`tock/chips/esp32-c6/src/pcr.rs`)
   - Define register structures from TRM Chapter 8
   - Implement peripheral clock enable functions
   - Implement peripheral reset functions
   - Implement clock source selection
   - **Files:** `pcr.rs` (new, ~300 lines)
   - **Reference:** TRM Chapter 8, Section 8.4 Register Summary

2. **Implement Watchdog Disable** (`tock/chips/esp32-c6/src/watchdog.rs`)
   - Disable MWDT0 (Timer Group 0 watchdog)
   - Disable MWDT1 (Timer Group 1 watchdog)
   - Disable RTC WDT
   - Disable Super WDT (if possible via PMU)
   - **Files:** `watchdog.rs` (new, ~150 lines)
   - **Reference:** TRM Chapter 15, Section 15.2.2

3. **Integrate into Board Initialization**
   - Call watchdog disable in `setup()` before peripheral init
   - Enable peripheral clocks via PCR
   - **Files:** `tock/boards/nano-esp32-c6/src/main.rs` (modify)
   - **Location:** After line 138 (replace TODO comments)

4. **Testing**
   - Verify no watchdog resets for 60+ seconds
   - Verify peripheral clocks enabled
   - Verify timer clock source configurable
   - **Test:** Run kernel, observe stable operation

**Success Criteria:**
- [ ] PCR driver compiles and links
- [ ] Watchdog disable functions implemented
- [ ] Kernel runs without watchdog resets for 60+ seconds
- [ ] Peripheral clocks properly enabled
- [ ] All existing tests still pass (11/11)

**Estimated Complexity:** 15-20 iterations
- PCR register definitions: 5 iterations
- Watchdog disable logic: 5 iterations
- Integration and testing: 5-10 iterations

**Risks:**
- **MEDIUM:** PCR register addresses may differ from documentation
  - **Mitigation:** Cross-reference with ESP-IDF source code
- **LOW:** Super WDT may not be accessible from software
  - **Mitigation:** Focus on MWDT and RTC WDT first

**Verification:** ✅ Tasks based on TRM chapters, existing code structure, and issue tracker

---

### SP002: Interrupt Controller - INTC

**Goal:** Implement complete interrupt controller driver supporting INTMTX + INTPRI architecture.

**Resolves:** Issue #4 (HIGH)

**Dependencies:** SP001 (PCR needed for interrupt clock enable)

**Tasks:**

1. **Create INTMTX Driver** (`tock/chips/esp32-c6/src/intmtx.rs`)
   - Define register structures for interrupt matrix
   - Implement peripheral-to-CPU interrupt mapping
   - Implement interrupt source status query
   - **Files:** `intmtx.rs` (new, ~200 lines)
   - **Reference:** TRM Chapter 10, Section 10.3

2. **Create INTPRI Driver** (`tock/chips/esp32-c6/src/intpri.rs`)
   - Define register structures for interrupt priority
   - Implement enable/disable functions
   - Implement priority configuration
   - Implement threshold configuration
   - Implement pending interrupt query
   - **Files:** `intpri.rs` (new, ~250 lines)
   - **Reference:** ESP32-C3 `intc.rs` + TRM Chapter 10

3. **Create Unified INTC Interface** (`tock/chips/esp32-c6/src/intc.rs`)
   - Combine INTMTX + INTPRI into single interface
   - Implement `map_interrupts()` function
   - Implement `enable_all()` / `disable_all()`
   - Implement `next_pending()` for interrupt dispatch
   - **Files:** `intc.rs` (new, ~150 lines)
   - **Reference:** ESP32-C3 `intc.rs` pattern

4. **Update Interrupt Definitions** (`tock/chips/esp32-c6/src/interrupts.rs`)
   - Verify peripheral interrupt source numbers from TRM Table 10.3-1
   - Define constants for UART0, UART1, GPIO, TIMG0, TIMG1
   - Document interrupt mappings
   - **Files:** `interrupts.rs` (modify, +20 lines)
   - **Reference:** TRM Chapter 10, Table 10.3-1

5. **Integrate into Chip Driver** (`tock/chips/esp32-c6/src/chip.rs`)
   - Replace placeholder interrupt handling
   - Implement `service_pending_interrupts()`
   - Implement `has_pending_interrupts()`
   - Call INTC initialization in setup
   - **Files:** `chip.rs` (modify)
   - **Reference:** ESP32-C3 `chip.rs`

6. **Testing**
   - Verify interrupt mapping works
   - Verify priority configuration
   - Verify timer interrupt fires and is handled
   - Verify UART interrupt works
   - **Test:** Enable timer alarm, verify interrupt triggers

**Success Criteria:**
- [ ] INTMTX driver compiles and maps interrupts
- [ ] INTPRI driver configures priorities and enables interrupts
- [ ] Unified INTC interface works
- [ ] Timer interrupt fires and is handled correctly
- [ ] UART interrupt works (if tested)
- [ ] All tests pass (11/11)

**Estimated Complexity:** 25-30 iterations
- INTMTX implementation: 8 iterations
- INTPRI implementation: 10 iterations
- Integration and testing: 7-12 iterations

**Risks:**
- **HIGH:** Interrupt source numbers may differ from documentation
  - **Mitigation:** Verify each interrupt number from TRM Table 10.3-1
  - **Mitigation:** Test each peripheral interrupt individually
- **MEDIUM:** Priority behavior may differ from C3
  - **Mitigation:** Start with simple priority configuration
  - **Mitigation:** Test with different priority levels

**Verification:** ✅ Tasks based on TRM Chapter 10 and ESP32-C3 reference implementation

---

### SP003: Timer Drivers (TIMG0/TIMG1)

**Goal:** Complete timer driver implementation with full alarm support and PCR integration.

**Resolves:** Partial - enables scheduler timing

**Dependencies:** SP001 (PCR for clock config), SP002 (INTC for interrupts)

**Tasks:**

1. **Enhance Timer Driver** (`tock/chips/esp32/timg.rs`)
   - Verify 54-bit counter handling
   - Implement alarm functionality
   - Implement auto-reload
   - Add interrupt handling
   - **Files:** `timg.rs` (modify, +100 lines)
   - **Reference:** TRM Chapter 14

2. **Integrate PCR Clock Configuration**
   - Add clock source selection via PCR
   - Add clock enable via PCR
   - Document clock frequency calculations
   - **Files:** `tock/chips/esp32-c6/src/lib.rs` (modify)
   - **Reference:** TRM Chapter 14, Section 14.3.1

3. **Implement HIL Traits**
   - Implement `kernel::hil::time::Time` trait
   - Implement `kernel::hil::time::Alarm` trait
   - Implement `kernel::hil::time::Counter` trait
   - **Files:** `timg.rs` (modify)
   - **Reference:** Tock kernel HIL documentation

4. **Register Deferred Calls**
   - Register timer deferred call client
   - Handle alarm callbacks via deferred calls
   - **Files:** `tock/chips/esp32-c6/src/chip.rs` (modify)
   - **Reference:** Tock deferred call pattern

5. **Testing**
   - Verify timer counts correctly
   - Verify alarm fires at correct time
   - Verify interrupt handling
   - Verify scheduler timing accurate
   - **Test:** Set alarm for 1 second, verify timing

**Success Criteria:**
- [ ] Timer driver enhanced with full alarm support
- [ ] PCR clock configuration integrated
- [ ] HIL traits implemented correctly
- [ ] Deferred calls registered
- [ ] Alarms fire at correct times
- [ ] Scheduler timing accurate
- [ ] All tests pass (11/11)

**Estimated Complexity:** 20-25 iterations
- Timer driver enhancements: 10 iterations
- PCR integration: 5 iterations
- Testing and debugging: 5-10 iterations

**Risks:**
- **MEDIUM:** 54-bit counter handling may have edge cases
  - **Mitigation:** Test counter rollover scenarios
- **LOW:** Clock frequency calculations may be incorrect
  - **Mitigation:** Verify against known timing

**Verification:** ✅ Tasks based on TRM Chapter 14 and existing timer driver

---

### SP004: GPIO Driver

**Goal:** Implement complete GPIO driver with digital I/O and interrupt support.

**Resolves:** Enables GPIO-based applications

**Dependencies:** SP001 (PCR for clock), SP002 (INTC for interrupts)

**Tasks:**

1. **Enhance GPIO Driver** (`tock/chips/esp32-c6/src/gpio.rs`)
   - Verify 31-pin support (vs 22 in C3)
   - Implement input/output configuration
   - Implement pull-up/pull-down
   - Implement drive strength
   - **Files:** `gpio.rs` (modify, +150 lines)
   - **Reference:** TRM Chapter 7

2. **Implement GPIO Interrupts**
   - Configure interrupt type (rising/falling/both/level)
   - Enable/disable interrupts per pin
   - Handle interrupt in ISR
   - Callback to client via deferred call
   - **Files:** `gpio.rs` (modify, +100 lines)
   - **Reference:** TRM Chapter 7, Section 7.4

3. **Implement HIL Traits**
   - Implement `kernel::hil::gpio::Pin` trait
   - Implement `kernel::hil::gpio::InterruptPin` trait
   - Implement `kernel::hil::gpio::Configure` trait
   - **Files:** `gpio.rs` (modify)
   - **Reference:** Tock kernel HIL

4. **Integrate into Chip Driver**
   - Add GPIO to peripheral structure
   - Add GPIO interrupt handling
   - Register GPIO deferred call
   - **Files:** `chip.rs` (modify)
   - **Reference:** ESP32-C3 pattern

5. **Testing**
   - Verify input/output works
   - Verify pull-up/pull-down
   - Verify interrupts fire correctly
   - Test with RGB LED on GPIO16 (if time permits)
   - **Test:** Toggle GPIO, read input, test interrupt

**Success Criteria:**
- [ ] GPIO driver supports 31 pins
- [ ] Input/output configuration works
- [ ] Pull-up/pull-down works
- [ ] Interrupts fire and are handled
- [ ] HIL traits implemented
- [ ] All tests pass (11/11)

**Estimated Complexity:** 20-25 iterations
- GPIO driver enhancements: 10 iterations
- Interrupt implementation: 8 iterations
- Testing: 2-7 iterations

**Risks:**
- **MEDIUM:** GPIO interrupt handling may conflict with other interrupts
  - **Mitigation:** Test GPIO interrupt in isolation first
- **LOW:** Pin count increase may reveal bugs
  - **Mitigation:** Test with pins >22 specifically

**Verification:** ✅ Tasks based on TRM Chapter 7 and existing GPIO code

---

### SP005: Console & Debug Infrastructure

**Goal:** Implement robust console infrastructure for debugging and user interaction.

**Resolves:** Improves debugging capability

**Dependencies:** SP002 (INTC for UART interrupts), SP001 (PCR for UART clock)

**Tasks:**

1. **Enhance UART Driver**
   - Verify interrupt-driven TX/RX
   - Implement FIFO management
   - Add error handling
   - **Files:** `tock/chips/esp32/uart.rs` (modify, +50 lines)
   - **Reference:** TRM Chapter 27

2. **Implement Console Capsule**
   - Set up console capsule with UART0
   - Configure for 115200 baud
   - Enable interrupt-driven operation
   - **Files:** `main.rs` (modify)
   - **Reference:** Existing console setup at line 194+

3. **Add Debug Macros**
   - Verify `debug!()` macro works
   - Add debug output to key kernel events
   - Document debug output format
   - **Files:** Various (modify)
   - **Reference:** Tock debug patterns

4. **Testing**
   - Verify console input/output
   - Verify interrupt-driven operation
   - Test with high-speed data
   - **Test:** Send/receive data via console

**Success Criteria:**
- [ ] UART driver enhanced with interrupts
- [ ] Console capsule working
- [ ] Debug output functional
- [ ] Can send/receive data reliably
- [ ] All tests pass (11/11)

**Estimated Complexity:** 15-20 iterations
- UART enhancements: 8 iterations
- Console setup: 5 iterations
- Testing: 2-7 iterations

**Risks:**
- **LOW:** UART interrupts may conflict with other peripherals
  - **Mitigation:** Test UART interrupt in isolation
- **LOW:** FIFO management may have edge cases
  - **Mitigation:** Test with various data rates

**Verification:** ✅ Tasks based on TRM Chapter 27 and existing UART code

---

## Risk Assessment

### Technical Risks

| Risk | Likelihood | Impact | Severity | Mitigation |
|------|------------|--------|----------|------------|
| **Watchdog resets during development** | HIGH | HIGH | CRITICAL | Disable all watchdogs in SP001 first |
| **INTC interrupt numbers incorrect** | MEDIUM | HIGH | HIGH | Verify each from TRM Table 10.3-1 |
| **PCR register addresses wrong** | MEDIUM | MEDIUM | MEDIUM | Cross-reference with ESP-IDF |
| **INTMTX/INTPRI interaction issues** | MEDIUM | HIGH | HIGH | Test mapping and priority separately |
| **GPIO interrupt conflicts** | LOW | MEDIUM | MEDIUM | Test GPIO interrupt in isolation |
| **Timer counter overflow bugs** | LOW | MEDIUM | MEDIUM | Test 54-bit counter edge cases |
| **Clock configuration instability** | LOW | HIGH | MEDIUM | Start with conservative settings |

### Process Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Sprint dependencies block progress** | MEDIUM | MEDIUM | Follow strict sprint order |
| **Testing reveals fundamental issues** | LOW | HIGH | Test incrementally, not at end |
| **Documentation gaps in TRM** | MEDIUM | MEDIUM | Use ESP-IDF source as reference |

**Verification:** ✅ Risk assessment based on technical complexity and dependencies

---

## Questions for PO

### Q1: Sprint Scope Confirmation

**Question:** The proposed sprint breakdown has 5 sprints. Is this acceptable, or should we consolidate/split any sprints?

**Context:**
- SP001: Watchdog & Clock (critical stability)
- SP002: INTC (critical for interrupts)
- SP003: Timers (builds on SP001+SP002)
- SP004: GPIO (builds on SP001+SP002)
- SP005: Console (builds on SP002)

**Options:**
- **A:** Keep 5 sprints as proposed (recommended)
- **B:** Combine SP003+SP004 into single "Peripherals" sprint
- **C:** Split SP002 into INTMTX and INTPRI sprints

**Recommendation:** Option A - 5 sprints provides good granularity and clear milestones.

---

### Q2: PMP Implementation Priority

**Question:** Issue #5 (HIGH) - PMP disabled for userspace memory protection. Should this be included in PI002 or deferred to PI003?

**Context:**
- Current: SimplePMP<0> (0 regions, no protection)
- Issue: No userspace memory protection
- Complexity: Requires SkipLockedPMP implementation to work around bootloader-locked entries

**Options:**
- **A:** Include in PI002 as SP006 (adds 2-3 weeks)
- **B:** Defer to PI003 "Security & Isolation" (recommended)
- **C:** Implement minimal PMP in SP001 (quick fix)

**Recommendation:** Option B - Defer to PI003. Focus PI002 on peripheral functionality. PMP is important but not blocking for peripheral development.

---

### Q3: Testing Strategy

**Question:** Should we create hardware-in-the-loop tests for each peripheral, or rely on manual testing?

**Context:**
- Current: 11/11 tests passing (build tests)
- Need: Functional tests for peripherals

**Options:**
- **A:** Create automated HIL tests for each peripheral (adds time but high value)
- **B:** Manual testing with documented test procedures
- **C:** Hybrid: automated for critical (timers, interrupts), manual for others

**Recommendation:** Option C - Hybrid approach balances thoroughness with development speed.

---

### Q4: RGB LED Priority

**Question:** Should we implement WS2812B RGB LED driver in SP004 (GPIO) for visual debugging?

**Context:**
- nanoESP32-C6 has RGB LED on GPIO16
- Requires: RMT peripheral or bit-banging
- Value: Excellent visual feedback for debugging
- Complexity: Moderate (signal timing, GRB order, inverted signal)

**Options:**
- **A:** Include in SP004 (adds 1-2 iterations)
- **B:** Create separate SP006 for RGB LED
- **C:** Defer to PI003 or later

**Recommendation:** Option C - Defer. Focus on core functionality first. RGB LED is nice-to-have, not essential.

---

### Q5: Documentation Depth

**Question:** How much documentation should accompany each sprint?

**Context:**
- Need: Driver documentation, register documentation, usage examples
- Trade-off: Documentation time vs. implementation time

**Options:**
- **A:** Minimal: Code comments only
- **B:** Moderate: Code comments + README per driver
- **C:** Comprehensive: Code comments + README + usage guide + register reference

**Recommendation:** Option B - Moderate documentation. Code comments + README provides good balance.

---

## Handoff to Implementor

### Critical Information

1. **Start with SP001** - Watchdog disable is CRITICAL to prevent unexpected resets
2. **Follow sprint order strictly** - Dependencies are real and blocking
3. **Verify interrupt numbers** - TRM Table 10.3-1 must be checked for each peripheral
4. **Test incrementally** - Don't accumulate untested code
5. **Use ESP32-C3 as reference** - Copy and adapt patterns, don't reinvent

### Reference Documents

**MUST READ:**
1. ESP32-C6 TRM Chapter 8 (Reset and Clock) - PCR module
2. ESP32-C6 TRM Chapter 10 (Interrupt Matrix) - INTMTX/INTPRI
3. ESP32-C6 TRM Chapter 14 (Timer Group) - TIMG
4. ESP32-C6 TRM Chapter 15 (Watchdog Timers) - WDT
5. ESP32-C6 TRM Chapter 7 (GPIO) - GPIO Matrix
6. ESP32-C6_DIFFERENCES.md - Address changes
7. Issue Tracker - Outstanding issues

**Reference Code:**
- `tock/chips/esp32-c3/` - ESP32-C3 implementation
- `tock/chips/esp32/` - Shared peripheral drivers
- `tock/boards/nano-esp32-c6/` - Current board code

### Key Files to Create/Modify

**SP001:**
- `tock/chips/esp32-c6/src/pcr.rs` (new)
- `tock/chips/esp32-c6/src/watchdog.rs` (new)
- `tock/boards/nano-esp32-c6/src/main.rs` (modify)

**SP002:**
- `tock/chips/esp32-c6/src/intmtx.rs` (new)
- `tock/chips/esp32-c6/src/intpri.rs` (new)
- `tock/chips/esp32-c6/src/intc.rs` (new)
- `tock/chips/esp32-c6/src/interrupts.rs` (modify)
- `tock/chips/esp32-c6/src/chip.rs` (modify)

**SP003:**
- `tock/chips/esp32/timg.rs` (modify)
- `tock/chips/esp32-c6/src/lib.rs` (modify)

**SP004:**
- `tock/chips/esp32-c6/src/gpio.rs` (modify)
- `tock/chips/esp32-c6/src/chip.rs` (modify)

**SP005:**
- `tock/chips/esp32/uart.rs` (modify)
- `tock/boards/nano-esp32-c6/src/main.rs` (modify)

### Testing Strategy

**Per Sprint:**
1. **SP001:** Run kernel for 60+ seconds, verify no watchdog resets
2. **SP002:** Enable timer interrupt, verify it fires and is handled
3. **SP003:** Set alarm for 1 second, measure actual time
4. **SP004:** Toggle GPIO, test interrupt with button
5. **SP005:** Send/receive data via console

**Continuous:**
- Run all 11 tests after each change
- Verify "Hello World" still prints
- Check for unexpected resets
- Monitor serial output for errors

### Success Metrics

**PI002 Complete When:**
- [ ] No watchdog resets during operation
- [ ] Peripheral clocks configured via PCR
- [ ] INTC routes interrupts correctly
- [ ] Timers fire interrupts and handle alarms
- [ ] GPIO input/output and interrupts work
- [ ] Console input/output functional
- [ ] All 11/11 tests passing
- [ ] No new HIGH severity issues created
- [ ] Issues #2, #3, #4 resolved

### Estimated Timeline

**Total:** 95-120 iterations across 5 sprints

| Sprint | Iterations | Cumulative |
|--------|-----------|------------|
| SP001 | 15-20 | 15-20 |
| SP002 | 25-30 | 40-50 |
| SP003 | 20-25 | 60-75 |
| SP004 | 20-25 | 80-100 |
| SP005 | 15-20 | 95-120 |

**Assumptions:**
- 1 iteration = 1 code-test-debug cycle
- ~10-15 iterations per day (experienced developer)
- Total time: ~6-12 days (depends on complexity encountered)

---

## Analyst Progress Report - PI002

### Session 1 - 2026-02-12

**Task:** Research and plan PI002 - Core Peripherals

### Completed

- [x] Analyzed ESP32-C6 TRM chapters (7, 8, 10, 12, 14, 15)
- [x] Reviewed ESP32-C6_DIFFERENCES.md for address changes
- [x] Examined ESP32-C3 reference implementation
- [x] Verified current ESP32-C6 implementation status
- [x] Analyzed issue tracker for outstanding technical debt
- [x] Identified peripheral dependencies and critical path
- [x] Created comprehensive 5-sprint breakdown
- [x] Assessed risks and mitigation strategies
- [x] Documented handoff information for implementor

### Key Findings

1. **Watchdog Issue is CRITICAL**
   - MWDT0 and RTC WDT enabled by bootloader (TRM 15.1)
   - Will cause unexpected resets if not disabled early
   - MUST be first priority in SP001

2. **INTC Architecture Changed Significantly**
   - Split into INTMTX (mapping) + INTPRI (priority/enable)
   - 77 peripheral sources → 28 CPU interrupts
   - Priority range changed: 0-15 (vs 1-15 in C3)
   - Requires new driver architecture

3. **PCR Module is Foundation**
   - Replaces SYSCON from C3
   - Controls all peripheral clocks and resets
   - Required before any peripheral can work properly
   - Must be implemented in SP001

4. **Existing Code is Good Foundation**
   - UART driver working (verified by "Hello World")
   - Timer driver exists and compiles
   - GPIO driver exists but needs verification
   - Chip structure in place

5. **Dependencies are Clear**
   - PCR → Peripherals (clock enable)
   - INTC → Interrupts (routing)
   - Watchdog disable → Stability
   - Strict sprint ordering required

### Gaps Identified

- **Interrupt Numbers:** Need to verify exact peripheral interrupt source numbers from TRM Table 10.3-1
- **PCR Register Details:** Need complete register definitions from TRM Chapter 8
- **Super WDT Control:** Unclear if Super WDT can be disabled via software
- **GPIO Pin Availability:** Need to verify which pins are actually available on nanoESP32-C6

### Risks Identified

**CRITICAL:**
- Watchdog resets during development (HIGH likelihood, HIGH impact)

**HIGH:**
- INTC interrupt numbers incorrect (MEDIUM likelihood, HIGH impact)
- INTMTX/INTPRI interaction issues (MEDIUM likelihood, HIGH impact)

**MEDIUM:**
- PCR register addresses wrong (MEDIUM likelihood, MEDIUM impact)
- GPIO interrupt conflicts (LOW likelihood, MEDIUM impact)
- Timer counter overflow bugs (LOW likelihood, MEDIUM impact)

### Handoff Notes

**For Implementor:**
1. **START WITH SP001** - Watchdog disable is absolutely critical
2. **Verify every interrupt number** - Don't trust assumptions, check TRM Table 10.3-1
3. **Use ESP32-C3 as template** - Copy patterns, adapt addresses
4. **Test after every change** - Don't accumulate untested code
5. **Read TRM chapters** - Don't guess register behavior

**Critical Success Factor:**
- Watchdog disable MUST work in SP001 or all subsequent work will be blocked by random resets

**Estimated Effort:**
- 95-120 iterations total
- 6-12 days for experienced developer
- Could be longer if unexpected issues arise

### Questions for PO

See "Questions for PO" section above for 5 questions requiring PO input.

---

**Report Complete - Ready for PO Review and Sprint Assignment**
