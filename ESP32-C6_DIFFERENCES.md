# ESP32-C3 vs ESP32-C6 Technical Differences Analysis

**Document Version:** 1.0  
**Date:** 2026-02-10  
**Purpose:** Comprehensive analysis of hardware differences between ESP32-C3 and ESP32-C6 relevant to Tock OS porting

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [RISC-V Core Differences](#risc-v-core-differences)
3. [Memory Architecture](#memory-architecture)
4. [Interrupt System](#interrupt-system)
5. [Peripheral Base Addresses](#peripheral-base-addresses)
6. [Timer Groups](#timer-groups)
7. [GPIO System](#gpio-system)
8. [UART Controllers](#uart-controllers)
9. [System Control](#system-control)
10. [Power Management](#power-management)
11. [Random Number Generator](#random-number-generator)
12. [Boot ROM](#boot-rom)
13. [Impact Summary](#impact-summary)

---

## Executive Summary

The ESP32-C6 represents a significant evolution from the ESP32-C3, with architectural improvements that require substantial changes to the Tock OS port. While maintaining backward compatibility in concept, almost every peripheral has moved addresses and many have enhanced features.

### Key Statistics

| Metric | ESP32-C3 | ESP32-C6 | Change |
|--------|----------|----------|--------|
| RISC-V ISA | RV32IMC | RV32IMAC | +Atomic extension |
| ROM Size | 384 KB | 320 KB | -64 KB |
| HP SRAM | 400 KB | 512 KB | +112 KB |
| LP Memory | 8 KB RTC FAST | 16 KB LP SRAM | +8 KB |
| GPIO Pins | 22 | 31 | +9 pins |
| External Interrupts | 31 | 28 | -3 (reserved for CLINT) |
| Core Local Interrupts | 0 | 4 | +4 (CLINT) |
| UART Controllers | 2 | 3 | +LP_UART |
| Cache Size | 16 KB (8-way) | 32 KB (4-way) | 2x size |
| Hardware Triggers | 8 | 4 | Reduced |

### Severity Classification

**CRITICAL** - 15 changes that prevent boot or basic operation  
**HIGH** - 8 changes requiring driver rewrites  
**MEDIUM** - 12 changes requiring adjustments  
**LOW** - 5 changes that are cosmetic or optional

---

## RISC-V Core Differences

### ISA Extensions

**Severity: HIGH**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **ISA String** | RV32IMC | RV32IMAC |
| **Base** | RV32I (Integer) | RV32I (Integer) |
| **Multiply/Divide** | M extension | M extension |
| **Compressed** | C extension | C extension |
| **Atomic** | ❌ Not supported | ✅ A extension |

**Impact:**
- Toolchain target changes from `riscv32imc-unknown-none-elf` to `riscv32imac-unknown-none-elf`
- Atomic operations (`lr.w`, `sc.w`, `amoswap.w`, etc.) now available
- Enables lock-free data structures and better synchronization primitives
- Backward compatible - RV32IMC code runs on RV32IMAC

**Atomic Instructions Available in C6:**
- Load Reserved / Store Conditional: `lr.w`, `sc.w`
- Atomic Swap: `amoswap.w`
- Atomic Add: `amoadd.w`
- Atomic AND/OR/XOR: `amoand.w`, `amoor.w`, `amoxor.w`
- Atomic Min/Max: `amomin.w`, `amomax.w`, `amominu.w`, `amomaxu.w`

### Interrupt Architecture

**Severity: CRITICAL**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **External Interrupts** | 31 (IDs 1-31) | 28 (IDs 1-2, 5-6, 8-31) |
| **Core Local Interrupts** | None | 4 (IDs 0, 3, 4, 7) via CLINT |
| **User Mode Support** | Basic | Enhanced with `mideleg` |
| **Priority Levels** | 15 (1-15) | 16 (0-15) for external |

**CLINT Interrupts (NEW in C6):**

| ID | Name | Type | Default Mode |
|----|------|------|--------------|
| 0 | U-mode Software | Software-triggered | User |
| 3 | M-mode Software | Software-triggered | Machine |
| 4 | U-mode Timer | Hardware timer | User |
| 7 | M-mode Timer | Hardware timer | Machine |

**Impact:**
- CLINT provides 64-bit timer with compare registers
- CLINT interrupts have fixed priorities, cannot be masked by threshold
- External interrupts always preempt CLINT interrupts
- IDs 0, 3, 4, 7 are reserved and cannot be used for peripheral mapping
- Requires dual interrupt handling: CLINT + INTC

### CSR (Control and Status Registers)

**Severity: MEDIUM**

**New CSRs in C6:**

| CSR | Address | Name | Purpose |
|-----|---------|------|---------|
| `mideleg` | 0x303 | Machine Interrupt Delegation | Delegate interrupts to U-mode |
| `medeleg` | 0x302 | Machine Exception Delegation | Delegate exceptions to U-mode |
| `ustatus` | 0x000 | User Status | U-mode status register |
| `uie` | 0x004 | User Interrupt Enable | U-mode interrupt enable |
| `utvec` | 0x005 | User Trap Vector | U-mode trap handler address |
| `uscratch` | 0x040 | User Scratch | U-mode scratch register |
| `uepc` | 0x041 | User Exception PC | U-mode exception program counter |
| `ucause` | 0x042 | User Cause | U-mode exception cause |
| `utval` | 0x043 | User Trap Value | U-mode trap value |
| `uip` | 0x044 | User Interrupt Pending | U-mode interrupt pending |

**PMA (Physical Memory Attribute) CSRs:**
- `pma_cfg0` - `pma_cfg15` (0xBC0 - 0xBCF)
- `pma_addr0` - `pma_addr15` (0xBD0 - 0xBDF)

**Impact:**
- All C3 CSRs are preserved
- New CSRs enable better privilege separation
- PMA allows fine-grained memory attribute control
- User mode delegation improves security isolation

### PMP (Physical Memory Protection)

**Severity: LOW**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **PMP Regions** | 16 | 16 |
| **Max NAPOT Range** | 1 GB | 4 GB |
| **RISC-V Compliance** | Partial (non-compliant priority) | Full compliance |
| **Overlapping Regions** | Not supported | Supported per spec |

**C3 Non-compliance:**
- Higher-numbered PMPs could override lower-numbered ones
- Non-standard priority behavior

**C6 Compliance:**
- Lower-numbered PMPs take priority (per RISC-V spec)
- Proper overlapping region handling
- Better isolation guarantees

**Impact:**
- Existing PMP code may need adjustment if relying on C3 behavior
- Better security with spec-compliant implementation
- Same number of regions (16)

### Hardware Debug Triggers

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Breakpoints** | 8 | 4 |
| **Watchpoints** | 8 | 4 |
| **Total Triggers** | 8 | 4 |

**Impact:**
- Fewer hardware breakpoints for debugging
- May impact debugger functionality
- Not critical for production deployment

---

## Memory Architecture

### Memory Map Overview

**Severity: CRITICAL**

#### ESP32-C3 Memory Map

```
ROM (IBUS):     0x4000_0000 - 0x4005_FFFF  (384 KB)
ROM (DBUS):     0x3FF0_0000 - 0x3FF1_FFFF  (128 KB mapped)
SRAM (DBUS):    0x3FC8_0000 - 0x3FCD_FFFF  (400 KB)
SRAM (IBUS):    0x4037_C000 - 0x4037_FFFF  (16 KB)
SRAM (IBUS):    0x4038_0000 - 0x403D_FFFF  (384 KB)
RTC FAST:       0x5000_0000 - 0x5000_1FFF  (8 KB)
Flash (DBUS):   0x3C00_0000 - 0x3C7F_FFFF  (8 MB)
Flash (IBUS):   0x4200_0000 - 0x427F_FFFF  (8 MB)
```

#### ESP32-C6 Memory Map

```
ROM:            0x4000_0000 - 0x4004_FFFF  (320 KB, unified)
HP SRAM:        0x4080_0000 - 0x4087_FFFF  (512 KB, unified)
LP SRAM:        0x5000_0000 - 0x5000_3FFF  (16 KB)
Flash:          0x4200_0000 - 0x42FF_FFFF  (16 MB, unified)
```

**Key Changes:**
1. **Unified Bus Architecture:** C6 uses single address for I-bus and D-bus
2. **Simplified Addressing:** No dual mapping for same memory
3. **Increased Capacity:** More SRAM, more flash mapping
4. **New LP Subsystem:** Separate low-power memory

### Internal ROM

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Size** | 384 KB | 320 KB |
| **Address** | 0x4000_0000 - 0x4005_FFFF (IBUS)<br>0x3FF0_0000 - 0x3FF1_FFFF (DBUS) | 0x4000_0000 - 0x4004_FFFF |
| **Dual Mapping** | Yes (IBUS + DBUS) | No (unified) |

**Contents:**
- First-stage bootloader
- ROM API functions
- Flash boot code
- Secure boot logic

**Impact:**
- 64 KB smaller ROM
- Simpler addressing (no dual mapping)
- May affect ROM API availability
- Bootloader code different

### Internal SRAM (High-Performance)

**Severity: CRITICAL**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Size** | 400 KB total | 512 KB |
| **DBUS Address** | 0x3FC8_0000 - 0x3FCD_FFFF | 0x4080_0000 - 0x4087_FFFF |
| **IBUS Address** | 0x4037_C000 - 0x403D_FFFF | Same (unified) |
| **Dual Mapping** | Yes | No |

**C3 SRAM Layout:**
- 384 KB at 0x3FC8_0000 (DBUS) / 0x4038_0000 (IBUS)
- 16 KB at 0x4037_C000 (IBUS only)

**C6 SRAM Layout:**
- 512 KB at single address 0x4080_0000
- No bus-specific addressing

**Impact:**
- **CRITICAL:** All SRAM addresses must be updated
- Linker script requires complete rewrite for SRAM regions
- 28% more memory available (400 KB → 512 KB)
- Simplified addressing model

### Low-Power Memory

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Type** | RTC FAST SRAM | LP SRAM |
| **Size** | 8 KB | 16 KB |
| **Address** | 0x5000_0000 - 0x5000_1FFF | 0x5000_0000 - 0x5000_3FFF |
| **Access Modes** | Single | High-speed / Low-speed |
| **Retention** | Deep sleep | Deep sleep |

**C6 Access Modes:**
- **High-speed mode:** Fast access from HP CPU
- **Low-speed mode:** Power-optimized access from LP CPU

**Impact:**
- Double the RTC memory size
- Address range doubled (same base)
- New access mode configuration needed
- Better deep-sleep data retention

### External Flash Mapping

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Max Size** | 16 MB physical<br>8 MB mapped | 16 MB physical<br>16 MB mapped |
| **DBUS Address** | 0x3C00_0000 - 0x3C7F_FFFF | 0x4200_0000 - 0x42FF_FFFF |
| **IBUS Address** | 0x4200_0000 - 0x427F_FFFF | Same (unified) |
| **Dual Mapping** | Yes | No |

**Impact:**
- Full 16 MB flash accessible (vs 8 MB in C3)
- Unified addressing simplifies code placement
- Flash address changed for DBUS access
- IBUS address unchanged (0x4200_0000)

### Cache Configuration

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Size** | 16 KB | 32 KB |
| **Organization** | 8-way set-associative | 4-way set-associative |
| **Cache Line** | 32 bytes | 32 bytes |
| **Flash Cache** | Yes | Yes |
| **SRAM Cache** | No | No |

**Impact:**
- 2x larger cache improves performance
- Different associativity may affect access patterns
- Same cache line size (32 bytes)
- Optimization opportunities with larger cache

### Recommended Linker Script Memory Regions

**For ESP32-C6 Tock:**

```ld
MEMORY {
    /* ROM: Use flash starting at standard boot address */
    rom (rx)  : ORIGIN = 0x40380000, LENGTH = 0x28000  /* 160 KB kernel */
    
    /* HP SRAM: Use new unified address */
    ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x40000  /* 256 KB kernel data */
    
    /* App Flash: After kernel flash */
    prog (rx) : ORIGIN = 0x403A8000, LENGTH = 0x30000  /* 192 KB apps */
}
```

**Notes:**
- Kernel uses 160 KB flash (vs 192 KB in C3) due to smaller ROM
- Kernel gets 256 KB SRAM (vs 192 KB in C3) - more available
- Apps still get 192 KB flash
- Can expand allocations due to larger total memory

---

## Interrupt System

### Interrupt Controller Base Addresses

**Severity: CRITICAL**

| Component | ESP32-C3 | ESP32-C6 |
|-----------|----------|----------|
| **Interrupt Matrix** | 0x600C_2000 | 0x6001_0000 |
| **Priority Registers** | Part of INTC | 0x600C_5000 (separate) |
| **CLINT (M-mode)** | N/A | 0x2000_1800 |
| **CLINT (U-mode)** | N/A | 0x2000_1C00 |

**Impact:**
- Complete address reorganization
- INTC split into matrix and priority components
- New CLINT subsystem at different address space (0x2xxx_xxxx)

### Interrupt Controller Architecture

**Severity: CRITICAL**

#### ESP32-C3 INTC

- **Base:** 0x600C_2000
- **Type:** Proprietary vectored interrupt controller
- **External Interrupts:** 31 (IDs 1-31)
- **Priority Levels:** 15 (1-15, higher = higher priority)
- **Threshold:** Programmable via `CPU_INT_THRESH_REG`
- **Mapping:** Dynamic via `intr_map_reg_x` registers

#### ESP32-C6 Interrupt System

**Two-part system:**

1. **INTMTX (Interrupt Matrix)** - 0x6001_0000
   - Maps peripheral interrupts to CPU interrupt IDs
   - 28 external interrupt slots (1-2, 5-6, 8-31)
   - Reserves IDs 0, 3, 4, 7 for CLINT

2. **INTPRI (Interrupt Priority)** - 0x600C_5000
   - Controls priority and enable/disable
   - Priority levels 0-15 (0 = lowest)
   - Threshold register for masking
   - Type register (level/edge)

3. **CLINT (Core Local Interrupts)** - 0x2000_1800 (M) / 0x2000_1C00 (U)
   - 4 core-local interrupts (IDs 0, 3, 4, 7)
   - Fixed priorities (cannot be masked by threshold)
   - Hardware timer with 64-bit counter
   - Software interrupt capability

**Impact:**
- Requires two drivers: INTMTX + INTPRI instead of single INTC
- CLINT adds third interrupt management component
- External interrupts reduced from 31 to 28
- Priority range changed (0-15 instead of 1-15)

### Register Name Changes

**Severity: HIGH**

**ESP32-C3 Register Naming:**
```
INTERRUPT_CORE0_CPU_INT_ENABLE_REG
INTERRUPT_CORE0_CPU_INT_TYPE_REG
INTERRUPT_CORE0_CPU_INT_THRESH_REG
INTERRUPT_CORE0_CPU_INT_CLEAR_REG
INTERRUPT_CORE0_CPU_INT_EIP_STATUS_REG
INTERRUPT_CORE0_CPU_INT_PRI_n_REG
```

**ESP32-C6 Register Naming:**
```
INTPRI_CORE0_CPU_INT_ENABLE_REG
INTPRI_CORE0_CPU_INT_TYPE_REG
INTPRI_CORE0_CPU_INT_THRESH_REG
INTPRI_CORE0_CPU_INT_CLEAR_REG
INTPRI_CORE0_CPU_INT_EIP_STATUS_REG
INTPRI_CORE0_CPU_INT_PRI_n_REG
```

**Impact:**
- Global search/replace: `INTERRUPT_CORE0` → `INTPRI_CORE0`
- Register functionality remains similar
- Addresses changed, must update base pointer

### CLINT (Core Local Interrupts)

**Severity: HIGH** - New subsystem in C6

#### CLINT Interrupt Sources

| ID | Name | Type | Priority | Usage |
|----|------|------|----------|-------|
| 0 | `usip` | Software | 1 | User software interrupt |
| 3 | `msip` | Software | 3 | Machine software interrupt |
| 4 | `utip` | Timer | 0 | User timer interrupt |
| 7 | `mtip` | Timer | 2 | Machine timer interrupt |

#### CLINT Registers (M-mode, base 0x2000_1800)

| Offset | Name | Width | Description |
|--------|------|-------|-------------|
| 0x00 | `msip` | 32-bit | Machine software interrupt pending |
| 0x04 | `mtimectl` | 32-bit | Machine timer control |
| 0x08 | `mtime_lo` | 32-bit | Machine time counter low |
| 0x0C | `mtime_hi` | 32-bit | Machine time counter high |
| 0x10 | `mtimecmp_lo` | 32-bit | Machine time compare low |
| 0x14 | `mtimecmp_hi` | 32-bit | Machine time compare high |

#### CLINT Registers (U-mode, base 0x2000_1C00)

Similar layout for user mode: `usip`, `utimectl`, `utime`, `utimecmp`

#### CLINT Priority Behavior

**Critical:** CLINT interrupts have **fixed priorities** that cannot be masked:
- User timer (ID 4): Priority 0 (lowest)
- User software (ID 0): Priority 1
- Machine timer (ID 7): Priority 2
- Machine software (ID 3): Priority 3 (highest)

**External interrupts always preempt CLINT interrupts** regardless of priority setting.

**Impact:**
- Must implement CLINT driver from scratch
- System timer should use CLINT instead of TIMG
- Cannot use IDs 0, 3, 4, 7 for peripheral mapping
- Interrupt handler must check `mcause` and route accordingly

### Interrupt ID Mapping

**Severity: HIGH** - Peripheral interrupt IDs likely changed

**Known Differences:**
- C3 has 62 peripheral interrupt sources mapped to 31 external interrupts
- C6 has different peripheral interrupt sources mapped to 28 external interrupts
- Must consult ESP32-C6 Chapter 10 for specific mappings

**Action Required:**
Look up each peripheral's interrupt ID in C6 documentation:
- UART0 interrupt ID
- UART1 interrupt ID
- GPIO interrupt ID
- TIMG0/TIMG1 interrupt IDs
- Other peripherals

**Impact:**
- Must update `interrupts.rs` with correct mappings
- Cannot assume C3 mappings work on C6
- Test each interrupt source individually

---

## Peripheral Base Addresses

### Address Comparison Table

**Severity: CRITICAL**

| Peripheral | ESP32-C3 | ESP32-C6 | Change |
|------------|----------|----------|--------|
| **UART0** | 0x6000_0000 | 0x6000_0000 | ✅ SAME |
| **UART1** | 0x6001_0000 | 0x6000_1000 | ❌ CHANGED |
| **LP_UART** | N/A | 0x600B_1400 | ➕ NEW |
| **GPIO** | 0x6000_4000 | 0x6009_1000 | ❌ CHANGED |
| **IO MUX** | 0x6000_9000 | 0x6009_0000 | ❌ CHANGED |
| **LP IO MUX** | N/A | 0x600B_2000 | ➕ NEW |
| **RTC_CNTL** | 0x6000_8000 | N/A (replaced by PMU) | ❌ REMOVED |
| **PMU** | N/A | 0x600B_0000 | ➕ NEW |
| **RTC_TIMER** | Part of RTC_CNTL | 0x600B_0C00 | ➕ SEPARATE |
| **RTC_WDT** | Part of TIMG | 0x600B_1C00 | ➕ SEPARATE |
| **LP_AON** | N/A | 0x600B_1000 | ➕ NEW |
| **LP_CLKRST** | N/A | 0x600B_0400 | ➕ NEW |
| **TIMG0** | 0x6001_F000 | 0x6000_8000 | ❌ CHANGED |
| **TIMG1** | 0x6002_0000 | 0x6000_9000 | ❌ CHANGED |
| **SYSCON** | 0x6002_6000 | N/A (replaced by PCR) | ❌ REMOVED |
| **PCR** | N/A | 0x6009_6000 | ➕ NEW |
| **HP_SYSREG** | 0x600C_0000 | 0x6009_5000 | ❌ CHANGED |
| **INTC** | 0x600C_2000 | N/A (split) | ❌ CHANGED |
| **INTMTX** | N/A | 0x6001_0000 | ➕ NEW |
| **INTPRI** | N/A | 0x600C_5000 | ➕ NEW |
| **RNG** | 0x6002_60B0 | TBD | ❓ VERIFY |
| **UHCI0** | 0x6001_4000 | 0x6000_5000 | ❌ CHANGED |

**Legend:**
- ✅ Address unchanged
- ❌ Address changed
- ➕ New peripheral in C6
- ❌ Removed/replaced in C6
- ❓ Needs verification

**Impact:**
- Only UART0 kept same address
- All other peripherals require address updates
- New peripherals for LP subsystem
- System control reorganized (SYSCON → PCR, RTC_CNTL → PMU)

---

## Timer Groups

### Base Addresses

**Severity: MEDIUM** - Addresses changed, functionality similar

| Timer | ESP32-C3 | ESP32-C6 |
|-------|----------|----------|
| **TIMG0** | 0x6001_F000 | 0x6000_8000 |
| **TIMG1** | 0x6002_0000 | 0x6000_9000 |

### Timer Configuration

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Timers per group** | 1 (T0) + WDT | 1 (T0) + WDT |
| **Counter width** | 54-bit | 54-bit |
| **Prescaler** | 16-bit (2-65536) | 16-bit (2-65536) |
| **Auto-reload** | Yes | Yes |
| **Alarm** | Yes | Yes |
| **ETM Support** | No | Yes |

### Clock Source Selection

**Severity: MEDIUM**

#### ESP32-C3
**2 clock sources:**
- APB_CLK (80 MHz typically)
- XTAL_CLK (40 MHz typically)

**Configuration:** `TIMG_T0_USE_XTAL` bit in `TIMG_T0CONFIG_REG`

#### ESP32-C6
**3 clock sources:**
- PLL_F80M_CLK (80 MHz)
- XTAL_CLK (40 MHz)
- RC_FAST_CLK (~17.5 MHz, low power)

**Configuration:** `PCR_TG0_TIMER_CLK_SEL` field in `PCR_TIMERGROUP0_TIMER_CLK_CONF_REG`
- 0 = XTAL_CLK
- 1 = PLL_F80M_CLK
- 2 = RC_FAST_CLK

**Impact:**
- Clock selection moved from timer registers to PCR module
- Additional clock source (RC_FAST_CLK) for low-power operation
- Must update clock configuration code

### Register Layout

**Severity: LOW** - Mostly compatible

Timer register structure remains similar:
- `TIMG_T0CONFIG_REG` - Timer configuration
- `TIMG_T0LO_REG` / `TIMG_T0HI_REG` - Counter value
- `TIMG_T0ALARMLO_REG` / `TIMG_T0ALARMHI_REG` - Alarm value
- `TIMG_T0LOADLO_REG` / `TIMG_T0LOADHI_REG` - Load value
- `TIMG_T0LOAD_REG` - Trigger load
- `TIMG_INT_ENA_REG` - Interrupt enable
- `TIMG_INT_RAW_REG` - Raw interrupt status
- `TIMG_INT_CLR_REG` - Interrupt clear

**Differences:**
- Clock selection field removed from `TIMG_T0CONFIG_REG`
- ETM-related fields added in C6

### ETM (Event Task Matrix) Support

**Severity: LOW** - New feature, optional

**C6 Only:** Timer groups support ETM for hardware event handling.

**ETM Tasks:**
- `CNT_START_TIMER0` - Enable counter
- `CNT_STOP_TIMER0` - Disable counter
- `CNT_RELOAD_TIMER0` - Reload counter value
- `CNT_CAP_TIMER0` - Capture current counter value
- `ALARM_START_TIMER0` - Enable alarm

**ETM Events:**
- `CNT_CMP_TIMER0` - Counter reached alarm value (interrupt)

**Enable:** Set `TIMG_ETM_EN` bit

**Impact:**
- Optional feature, not required for basic timer functionality
- Enables hardware-triggered timer operations
- Useful for precise timing without CPU intervention

---

## GPIO System

### Base Addresses

**Severity: MEDIUM**

| Module | ESP32-C3 | ESP32-C6 |
|--------|----------|----------|
| **GPIO Matrix** | 0x6000_4000 | 0x6009_1000 |
| **IO MUX** | 0x6000_9000 | 0x6009_0000 |
| **LP IO MUX** | N/A | 0x600B_2000 |

### Pin Count

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Total GPIO** | 22 (GPIO0-21) | 31 (GPIO0-30) |
| **Available** | 22 | Varies by package |
| **CPU GPIO CSRs** | 8 pins (GPIO0-7) | 8 pins (GPIO0-7) |

**C6 Package Variants:**
- **QFN40 with in-package flash:** 22 GPIOs available (GPIO26-31 used for flash)
- **QFN40 with external flash:** 30 GPIOs available (GPIO26-27 used for flash)

**Impact:**
- GPIO driver must handle up to 31 pins (vs 22)
- Array sizes need expansion
- Package-specific pin availability
- Document which pins are usable on target board

### GPIO Functionality

**Severity: LOW** - Backward compatible

Both C3 and C6 support:
- Input/Output mode
- Pull-up/Pull-down resistors
- Interrupt (rising/falling/both/level)
- Open-drain mode
- Drive strength configuration
- Sleep mode retention
- Function multiplexing via IO MUX

**Register structure remains similar:**
- `GPIO_OUT_REG` - Output value
- `GPIO_IN_REG` - Input value
- `GPIO_ENABLE_REG` - Output enable
- `GPIO_STATUS_REG` - Interrupt status
- `GPIO_PINn_REG` - Per-pin configuration
- `IO_MUX_GPIOn_REG` - Pin multiplexing

### LP (Low-Power) GPIO

**Severity: LOW** - New feature, optional

**C6 Only:** Dedicated low-power GPIO subsystem at 0x600B_2000

**LP GPIO Features:**
- Operates during deep sleep
- Connected to LP CPU
- Separate IO MUX configuration
- Lower power consumption
- Subset of HP GPIO functionality

**Impact:**
- Optional subsystem for low-power applications
- Not required for basic GPIO operation
- Useful for wake-up sources and sleep mode sensing

---

## UART Controllers

### Base Addresses

**Severity: MEDIUM**

| UART | ESP32-C3 | ESP32-C6 |
|------|----------|----------|
| **UART0** | 0x6000_0000 | 0x6000_0000 ✅ |
| **UART1** | 0x6001_0000 | 0x6000_1000 ❌ |
| **LP_UART** | N/A | 0x600B_1400 ➕ |

**Good News:** UART0 address unchanged - console should work with minimal changes!

### UART Configuration

**Severity: LOW** - Register layout compatible

Both C3 and C6 support:
- Configurable baud rate
- 128-byte TX/RX FIFOs
- Hardware flow control (RTS/CTS)
- Interrupts for TX/RX
- DMA support via UHCI
- RS485 mode
- IrDA mode

**Register structure similar:**
- `UART_FIFO_REG` - FIFO data
- `UART_INT_RAW_REG` - Raw interrupts
- `UART_INT_ENA_REG` - Interrupt enable
- `UART_INT_CLR_REG` - Interrupt clear
- `UART_CLKDIV_REG` - Baud rate divider
- `UART_CONF0_REG` / `UART_CONF1_REG` - Configuration
- `UART_STATUS_REG` - Status

### LP_UART (Low-Power UART)

**Severity: LOW** - New feature, optional

**C6 Only:** Additional UART controller for low-power operation.

**Features:**
- Operates during light sleep
- Connected to LP CPU
- Simpler than HP UART
- Lower power consumption
- Suitable for wake-up communication

**Impact:**
- Not required for basic UART functionality
- Useful for battery-powered applications
- Can implement as separate optional driver

### UHCI (UART-DMA)

**Severity: LOW**

| Module | ESP32-C3 | ESP32-C6 |
|--------|----------|----------|
| **UHCI0** | 0x6001_4000 | 0x6000_5000 |

**Impact:**
- Address changed for UART DMA controller
- Only matters if using DMA for UART
- Not currently implemented in Tock C3 port

---

## System Control

### Clock and Reset Control

**Severity: HIGH** - Complete reorganization

#### ESP32-C3: SYSCON Module

**Base:** 0x6002_6000  
**Function:** System configuration, clock control, reset control

**Key Registers:**
- `SYSCON_SYSCLK_CONF_REG` - System clock configuration
- `SYSCON_CPU_PER_CONF_REG` - CPU peripheral control
- `PERIP_CLK_EN_REG` - Peripheral clock enable
- `PERIP_RST_EN_REG` - Peripheral reset

#### ESP32-C6: PCR Module

**Base:** 0x6009_6000  
**Function:** Power, Clock, and Reset management

**Key Registers:**
- `PCR_SYSCLK_CONF_REG` - System clock configuration
- `PCR_CPU_FREQ_CONF_REG` - CPU frequency control
- `PCR_TIMERGROUP0_CONF_REG` - Timer group 0 clock/reset
- `PCR_TIMERGROUP1_CONF_REG` - Timer group 1 clock/reset
- `PCR_UART0_CONF_REG` - UART0 clock/reset
- `PCR_UART1_CONF_REG` - UART1 clock/reset
- Many more peripheral-specific registers

**Impact:**
- All clock control code must be rewritten
- SYSCON references → PCR references
- Per-peripheral clock control more granular
- Register names and bit fields changed

### System Registers

**Severity: MEDIUM**

| Module | ESP32-C3 | ESP32-C6 |
|--------|----------|----------|
| **HP_SYSREG** | 0x600C_0000 | 0x6009_5000 |

**Function:** High-level system configuration

**Impact:**
- Address changed
- Register layout may differ
- Verify compatibility of existing code

### PLL and CPU Frequency

**Severity: MEDIUM**

#### ESP32-C3
**PLL Options:**
- 320 MHz
- 480 MHz

**CPU Options:**
- 80 MHz
- 160 MHz

#### ESP32-C6
**PLL Options:**
- Similar to C3

**CPU Options:**
- 80 MHz
- 160 MHz
- Additional fractional dividers

**Impact:**
- Configuration mechanism changed (PCR vs SYSCON)
- Frequency options similar
- Need to port PLL/CPU frequency selection code

---

## Power Management

### Power Management Architecture

**Severity: HIGH** - Complete redesign

#### ESP32-C3: Single-Core Architecture

**Low-Power Features:**
- 4 predefined power modes
- RTC controller for sleep management
- RTC FAST memory (8 KB) retention
- Peripheral power gating
- RTC watchdog timer
- Light sleep / deep sleep

#### ESP32-C6: Dual-Core Architecture

**HP (High-Performance) CPU:**
- Main RISC-V core for applications
- Access to HP SRAM (512 KB)
- Full peripheral access

**LP (Low-Power) CPU:**
- Ultra-low-power RISC-V core
- Access to LP SRAM (16 KB)
- LP peripherals only
- Operates during HP sleep

**Impact:**
- More complex power management
- Coordination between HP and LP CPUs
- Larger RTC memory (16 KB vs 8 KB)
- New power modes and transitions

### Power Management Unit (PMU)

**Severity: HIGH**

| Module | ESP32-C3 | ESP32-C6 |
|--------|----------|----------|
| **RTC_CNTL** | 0x6000_8000 | Replaced by PMU |
| **PMU** | N/A | 0x600B_0000 |
| **RTC_TIMER** | Part of RTC_CNTL | 0x600B_0C00 |
| **RTC_WDT** | Part of Timer Groups | 0x600B_1C00 |
| **LP_AON** | N/A | 0x600B_1000 |
| **LP_CLKRST** | N/A | 0x600B_0400 |

**Impact:**
- RTC_CNTL code must be completely rewritten for PMU
- RTC timer and watchdog now separate modules
- New LP subsystem management
- Sleep mode code requires updates

### RTC Memory / LP SRAM

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **Name** | RTC FAST SRAM | LP SRAM |
| **Size** | 8 KB | 16 KB |
| **Address** | 0x5000_0000 - 0x5000_1FFF | 0x5000_0000 - 0x5000_3FFF |
| **Access** | Single mode | High-speed / Low-speed |
| **Retention** | Deep sleep | Deep sleep |

**Impact:**
- Same base address, doubled size
- Update memory size constants
- New access mode configuration
- More space for sleep data retention

### Watchdog Timers

**Severity: MEDIUM**

#### ESP32-C3
- MWDT0, MWDT1 in Timer Groups
- RTC WDT in RTC_CNTL
- Super WDT in RTC_CNTL

#### ESP32-C6
- MWDT0, MWDT1 in Timer Groups (same)
- RTC WDT at separate address (0x600B_1C00)
- LP WDT in LP AON module

**Impact:**
- RTC watchdog address changed
- Additional LP watchdog
- Disable logic must be updated

---

## Random Number Generator

### RNG Configuration

**Severity: LOW** - Functionality identical

**Both C3 and C6:**
- True random number generator
- Based on thermal noise
- Requires ADC or RC_FAST_CLK enabled
- Read from `RNG_DATA_REG`
- 32-bit random values
- Maximum recommended read rate: 1-5 MHz

**Differences:**
- Base address likely different (need to verify from register chapter)
- ADC naming may differ
- Configuration registers may have different names

**Impact:**
- Update base address
- Verify ADC/clock enable mechanism
- Core functionality code can remain similar

---

## Boot ROM

### ROM Configuration

**Severity: MEDIUM**

| Feature | ESP32-C3 | ESP32-C6 |
|---------|----------|----------|
| **ROM Size** | 384 KB | 320 KB |
| **ROM Address** | 0x4000_0000 - 0x4005_FFFF | 0x4000_0000 - 0x4004_FFFF |
| **Boot Process** | Mask ROM bootloader | Mask ROM bootloader |

**Both support:**
- Secure boot
- Flash encryption
- Multiple boot modes
- ROM API functions
- UART download mode

**Impact:**
- 64 KB smaller ROM
- Different ROM version/code
- May affect ROM API compatibility
- Boot protocol likely similar
- Verify flash encryption compatibility

### Boot Sequence

**Both chips follow similar sequence:**

1. **Reset Vector:** Jump to ROM bootloader at 0x4000_0000
2. **ROM Bootloader:** 
   - Initialize basic hardware
   - Check boot mode (flash / UART download / etc.)
   - Load second-stage bootloader from flash
   - Verify signature if secure boot enabled
3. **Second-Stage Bootloader:**
   - Initialize more hardware
   - Load application
   - Jump to application entry point
4. **Application:** Tock kernel starts

**Impact:**
- Flash layout may differ
- Second-stage bootloader is different
- Application entry point address may change
- Tock kernel must handle C6-specific initialization

---

## Impact Summary

### Changes by Severity

#### CRITICAL (15 changes) - Prevents Boot

1. ✅ HP SRAM address (0x4080_0000 vs 0x3FC8_0000)
2. ✅ LP SRAM address/size (16 KB vs 8 KB)
3. ✅ Linker script memory regions
4. ✅ Interrupt controller base (0x6001_0000 vs 0x600C_2000)
5. ✅ INTC split into INTMTX + INTPRI
6. ✅ CLINT system (4 new interrupts)
7. ✅ External interrupt count (28 vs 31)
8. ✅ TIMG0 address (0x6000_8000 vs 0x6001_F000)
9. ✅ TIMG1 address (0x6000_9000 vs 0x6002_0000)
10. ✅ GPIO address (0x6009_1000 vs 0x6000_4000)
11. ✅ IO MUX address (0x6009_0000 vs 0x6000_9000)
12. ✅ System register address (0x6009_5000 vs 0x600C_0000)
13. ✅ UART1 address (0x6000_1000 vs 0x6001_0000)
14. ✅ Interrupt register prefix (INTPRI vs INTERRUPT)
15. ✅ ROM size/address (320 KB vs 384 KB)

#### HIGH (8 changes) - Major Rewrites

1. ✅ RISC-V ISA (RV32IMAC vs RV32IMC)
2. ✅ CLINT driver implementation
3. ✅ User mode delegation support
4. ✅ Clock control (PCR vs SYSCON)
5. ✅ Power management (PMU vs RTC_CNTL)
6. ✅ RTC/LP subsystem organization
7. ✅ Interrupt ID mappings
8. ✅ Dual-core coordination (HP + LP)

#### MEDIUM (12 changes) - Adjustments Needed

1. ✅ GPIO pin count (31 vs 22)
2. ✅ Timer clock sources (3 vs 2)
3. ✅ Cache configuration (32KB/4-way vs 16KB/8-way)
4. ✅ Flash mapping (16 MB vs 8 MB)
5. ✅ Memory bus architecture (unified vs dual-mapped)
6. ✅ PMP compliance (spec-compliant vs non-compliant)
7. ✅ Hardware triggers (4 vs 8)
8. ✅ ETM support (new in C6)
9. ✅ LP peripherals (LP_UART, LP_GPIO, LP_I2C)
10. ✅ RTC memory size (16 KB vs 8 KB)
11. ✅ Watchdog addresses
12. ✅ Boot ROM differences

#### LOW (5 changes) - Cosmetic/Optional

1. ✅ RNG base address update
2. ✅ Priority levels (0-15 vs 1-15)
3. ✅ CPU GPIO CSRs (same)
4. ✅ UART0 address (unchanged)
5. ✅ Register layouts (mostly compatible)

### Total Changes Required

- **40 total changes** identified
- **15 critical** for boot
- **23 high/medium** for full functionality
- **2 low** for completeness

### Compatibility Assessment

**Cannot Share Binary:**
- Different memory maps
- Different peripheral addresses
- Different ISA (atomic extension)
- Different interrupt architecture

**Can Share Driver Logic:**
- UART register structure (with address abstraction)
- Timer register structure (with clock config updates)
- GPIO functionality (with pin count adjustment)
- RNG functionality (with address update)

**Recommended Approach:**
- Separate chip crates: `esp32-c3` and `esp32-c6`
- Share common code in `esp32` crate where possible
- Use conditional compilation for chip-specific differences
- Abstract hardware differences in HAL layer

---

## Conclusion

The ESP32-C6 introduces substantial changes from the ESP32-C3 that require a significant porting effort. The most critical changes are:

1. **Complete memory map reorganization** with new addresses for ROM, SRAM, and peripherals
2. **Interrupt system redesign** with CLINT addition and external interrupt reduction
3. **Peripheral address changes** affecting almost every component
4. **System control reorganization** from SYSCON to PCR module
5. **Power management overhaul** with dual-core HP/LP architecture

Despite these changes, the port is highly feasible because:
- Core concepts remain similar (vectored interrupts, timer groups, GPIO matrix)
- Register structures are largely compatible
- Enhanced features provide better performance and power efficiency
- Well-documented differences enable systematic porting

**Estimated Effort:** 7-11 weeks for full port, 4-6 weeks for minimal viable port.

**Recommended Strategy:** Incremental port in 4 phases (Foundation → Core Peripherals → Interrupts → Advanced Features).

---

**Document End**
