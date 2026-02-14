# PI003/SP002 - Super Analyst Report: Timer Interrupt Investigation

## Session 1 - 2026-02-14

**Task:** Deep investigation of ESP32-C6 timer interrupt configuration using ESP-IDF as reference  
**Status:** ROOT CAUSE IDENTIFIED

---

## Executive Summary

**ROOT CAUSE FOUND:** The ESP32-C6 interrupt controller implementation has **THREE CRITICAL BUGS**:

1. **INTMTX Register Offsets Are Wrong** - Timer interrupt mapping register is at `0xCC`, not `0x084` (72 bytes off!)
2. **Wrong Interrupt Controller Base** - ESP32-C6 uses PLIC at `0x20001000`, not INTPRI at `0x600C5000`
3. **PLIC Register Layout Wrong** - Clear/Status registers are swapped, priority offset is wrong

These bugs explain why GPIO interrupts work but timer interrupts don't: GPIO register offset is only 4 bytes off and may still hit a valid register, while timer offset is 72 bytes off and writes to a completely wrong location.

---

## Root Cause Analysis

### Issue 1: INTMTX Register Offsets Are Incorrect

**Our Implementation (`intmtx.rs`):**
```rust
(0x07C => gpio_interrupt_pro_map: ReadWrite<u32>),
(0x084 => timg0_intr_map: ReadWrite<u32>),
```

**ESP-IDF (Correct) from `interrupt_matrix_reg.h`:**
```c
#define INTMTX_CORE0_GPIO_INTERRUPT_PRO_MAP_REG (DR_REG_INTMTX_BASE + 0x78)
#define INTMTX_CORE0_TG0_T0_INTR_MAP_REG (DR_REG_INTMTX_BASE + 0xcc)
```

**Offset Comparison:**

| Register | Our Offset | Correct Offset | Delta |
|----------|------------|----------------|-------|
| GPIO_INTERRUPT_PRO_MAP | 0x07C | 0x078 | -4 |
| TG0_T0_INTR_MAP | 0x084 | 0x0CC | +72 (0x48) |

The timer interrupt mapping register is at offset `0xCC`, but we're writing to `0x084` which is a completely different register!

### Issue 2: Wrong Interrupt Controller Base Address

**Our Implementation (`intpri.rs`):**
```rust
pub const INTPRI_BASE: usize = 0x600C_5000;
```

**ESP-IDF (Correct) from `interrupt_reg.h` and `plic_reg.h`:**
```c
// ESP32-C6 uses PLIC, not INTPRI!
#define DR_REG_PLIC_MX_BASE  0x20001000  // Machine mode PLIC
#define DR_REG_PLIC_UX_BASE  0x20001400  // User mode PLIC

// Backwards compatibility aliases:
#define INTERRUPT_CORE0_CPU_INT_ENABLE_REG  PLIC_MXINT_ENABLE_REG
#define INTERRUPT_CORE0_CPU_INT_TYPE_REG    PLIC_MXINT_TYPE_REG
```

**Key Insight from ESP-IDF `interrupt_reg.h` line 27-28:**
```c
/**
 * ESP32C6 should use the PLIC controller as the interrupt controller 
 * instead of INTC (SOC_INT_PLIC_SUPPORTED = y)
 * Keep the following macros for backward compatibility reasons
 */
```

The ESP32-C6 uses a **PLIC (Platform-Level Interrupt Controller)**, not the older INTPRI-based controller that ESP32-C3 uses!

---

## Why GPIO Works But Timer Doesn't

### GPIO Interrupt Path Analysis

1. **GPIO register offset** is `0x078` (ESP-IDF) vs `0x07C` (our code) - only 4 bytes off
2. The GPIO interrupt may be working due to:
   - GPIO has its own interrupt enable in GPIO peripheral registers
   - GPIO interrupt status is visible in GPIO_STATUS registers
   - The 4-byte offset error might still hit a valid mapping register

### Timer Interrupt Path Analysis

1. **Timer register offset** is `0x0CC` (ESP-IDF) vs `0x084` (our code) - **72 bytes off!**
2. Writing to `0x084` writes to a completely different peripheral's mapping register
3. Timer interrupt signal never gets routed to any CPU interrupt line
4. Result: Timer alarm fires (sets flag in hardware) but interrupt never reaches CPU

---

## ESP-IDF Interrupt Setup Sequence

From `esp_hw_support/intr_alloc.c` line 664:
```c
// Route peripheral interrupt source to CPU interrupt line
esp_rom_route_intr_matrix(cpu, source, intr);
```

From `intr_alloc.c` line 672:
```c
// Enable interrupt at CPU level
ESP_INTR_ENABLE(intr);
```

From `intr_alloc.c` lines 680-690 (for SOC_CPU_HAS_FLEXIBLE_INTC):
```c
// Set interrupt priority
esp_cpu_intr_set_priority(intr, level);

// Set interrupt type (edge vs level)
if (flags & ESP_INTR_FLAG_EDGE) {
    esp_cpu_intr_set_type(intr, ESP_CPU_INTR_TYPE_EDGE);
} else {
    esp_cpu_intr_set_type(intr, ESP_CPU_INTR_TYPE_LEVEL);
}
```

---

## PLIC Register Layout (ESP32-C6)

**Base Address:** `0x20001000` (Machine mode)

| Offset | Register | Description |
|--------|----------|-------------|
| 0x00 | MXINT_ENABLE | CPU interrupt enable mask (32 bits) |
| 0x04 | MXINT_TYPE | Interrupt type (0=level, 1=edge) |
| 0x08 | MXINT_CLEAR | Clear pending edge interrupts |
| 0x0C | EMIP_STATUS | Pending interrupt status |
| 0x10-0x8C | MXINTn_PRI | Priority for each interrupt (0-31) |
| 0x90 | MXINT_THRESH | Priority threshold |
| 0x94 | MXINT_CLAIM | Interrupt claim/complete |

---

## Correct INTMTX Register Layout

**Base Address:** `0x60010000`

Key registers (from `interrupt_matrix_reg.h`):

| Offset | Register | Peripheral Source |
|--------|----------|-------------------|
| 0x078 | GPIO_INTERRUPT_PRO_MAP | GPIO interrupt |
| 0x07C | GPIO_INTERRUPT_PRO_NMI_MAP | GPIO NMI |
| 0x0AC | UART0_INTR_MAP | UART0 |
| 0x0B0 | UART1_INTR_MAP | UART1 |
| 0x0CC | TG0_T0_INTR_MAP | Timer Group 0, Timer 0 |
| 0x0D0 | TG0_T1_INTR_MAP | Timer Group 0, Timer 1 |
| 0x0D4 | TG0_WDT_INTR_MAP | Timer Group 0, WDT |
| 0x0D8 | TG1_T0_INTR_MAP | Timer Group 1, Timer 0 |

---

## Fix Strategy

### Step 1: Fix INTMTX Register Offsets

Replace the entire `IntmtxRegisters` struct in `intmtx.rs` with correct offsets matching ESP-IDF `interrupt_matrix_reg.h`.

**Key Changes:**
```rust
register_structs! {
    pub IntmtxRegisters {
        // ... (first 29 registers at 0x000-0x070 are correct)
        (0x074 => cpu_peri_timeout_intr_map: ReadWrite<u32>),
        (0x078 => gpio_interrupt_pro_map: ReadWrite<u32>),  // GPIO at 0x78
        (0x07C => gpio_interrupt_pro_nmi_map: ReadWrite<u32>),
        (0x080 => pau_intr_map: ReadWrite<u32>),
        // ... many registers in between ...
        (0x0CC => tg0_t0_intr_map: ReadWrite<u32>),  // Timer at 0xCC
        (0x0D0 => tg0_t1_intr_map: ReadWrite<u32>),
        (0x0D4 => tg0_wdt_intr_map: ReadWrite<u32>),
        (0x0D8 => tg1_t0_intr_map: ReadWrite<u32>),
        // ...
    }
}
```

### Step 2: Replace INTPRI with PLIC

Create new `plic.rs` driver or update `intpri.rs` to use PLIC registers:

**Key Changes:**
```rust
pub const PLIC_MX_BASE: usize = 0x2000_1000;

register_structs! {
    pub PlicRegisters {
        (0x00 => mxint_enable: ReadWrite<u32>),
        (0x04 => mxint_type: ReadWrite<u32>),
        (0x08 => mxint_clear: ReadWrite<u32>),
        (0x0C => emip_status: ReadOnly<u32>),
        (0x10 => mxint_pri: [ReadWrite<u32>; 32]),
        (0x90 => mxint_thresh: ReadWrite<u32>),
        (0x94 => mxint_claim: ReadWrite<u32>),
        (0x98 => @END),
    }
}
```

### Step 3: Update Interrupt Mapping Function

In `intmtx.rs`, update `map_interrupt()` to use correct register names:

```rust
pub unsafe fn map_interrupt(&self, peripheral_source: u32, cpu_interrupt: u32) {
    match peripheral_source {
        crate::interrupts::PERIPHERAL_GPIO => {
            self.registers.gpio_interrupt_pro_map.set(cpu_interrupt);
        }
        crate::interrupts::PERIPHERAL_TIMER_GROUP0 => {
            self.registers.tg0_t0_intr_map.set(cpu_interrupt);
        }
        // ...
    }
}
```

### Step 4: Fix Peripheral Source Numbers

Update `interrupts.rs` to match ESP-IDF's `interrupts.h`:

```rust
// From ESP-IDF soc/esp32c6/include/soc/interrupts.h
pub const PERIPHERAL_GPIO: u32 = 30;  // ETS_GPIO_INTR_SOURCE (line 48)
pub const PERIPHERAL_TIMER_GROUP0_T0: u32 = 49;  // ETS_TG0_T0_LEVEL_INTR_SOURCE (line 69)
pub const PERIPHERAL_TIMER_GROUP1_T0: u32 = 52;  // ETS_TG1_T0_LEVEL_INTR_SOURCE (line 72)
```

---

## Files Requiring Changes

| File | Change Required |
|------|-----------------|
| `chips/esp32-c6/src/intmtx.rs` | Fix all register offsets to match ESP-IDF |
| `chips/esp32-c6/src/intpri.rs` | Replace with PLIC driver at `0x20001000` |
| `chips/esp32-c6/src/interrupts.rs` | Fix peripheral source numbers |
| `chips/esp32-c6/src/intc.rs` | Update to use PLIC instead of INTPRI |
| `chips/esp32-c6/src/chip.rs` | Update INTC initialization |

---

## ESP-IDF Evidence

### Source Files Referenced:

1. **`components/soc/esp32c6/register/soc/interrupt_matrix_reg.h`**
   - Defines correct INTMTX register offsets
   - TG0_T0_INTR_MAP at offset 0xCC

2. **`components/soc/esp32c6/include/soc/interrupt_reg.h`**
   - Lines 27-28: "ESP32C6 should use the PLIC controller"
   - Defines PLIC register aliases

3. **`components/soc/esp32c6/register/soc/plic_reg.h`**
   - PLIC base address: 0x20001000
   - Complete PLIC register layout

4. **`components/soc/esp32c6/include/soc/interrupts.h`**
   - Peripheral interrupt source enum
   - ETS_TG0_T0_LEVEL_INTR_SOURCE = 49 (line 69)

5. **`components/esp_hw_support/intr_alloc.c`**
   - Complete interrupt allocation sequence
   - Uses `esp_rom_route_intr_matrix()` for routing

---

## Verification Steps

After implementing fixes:

1. **Read back INTMTX registers** to verify timer mapping is set
2. **Read PLIC enable register** to verify CPU interrupt is enabled
3. **Read PLIC pending status** after alarm to verify interrupt is pending
4. **Verify trap handler** receives interrupt with correct mcause

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Other register offsets wrong | Medium | High | Audit all INTMTX registers against ESP-IDF |
| PLIC behavior differs from INTPRI | Low | Medium | Follow ESP-IDF implementation exactly |
| GPIO breaks after INTMTX fix | Low | Medium | Test GPIO after changes |

---

## Handoff Notes for Implementor

### Priority Actions:

1. **CRITICAL**: Fix INTMTX register offsets - this is the primary blocker
2. **CRITICAL**: Replace INTPRI with PLIC driver
3. **HIGH**: Update peripheral source numbers in interrupts.rs
4. **MEDIUM**: Add debug output to verify register writes

### Key Files to Reference:

- ESP-IDF: `components/soc/esp32c6/register/soc/interrupt_matrix_reg.h`
- ESP-IDF: `components/soc/esp32c6/register/soc/plic_reg.h`
- ESP-IDF: `components/soc/esp32c6/include/soc/interrupts.h`

### Testing Approach:

1. Add temporary debug prints to show:
   - INTMTX register address being written
   - Value being written to INTMTX
   - PLIC enable register value
   - PLIC pending status after alarm
2. Verify timer interrupt fires after fixes
3. Verify GPIO still works after changes

---

## Conclusion

The root cause of timer interrupts not firing is definitively identified:

1. **Wrong INTMTX register offsets** - Timer mapping register is 72 bytes off
2. **Wrong interrupt controller** - ESP32-C6 uses PLIC, not INTPRI

These are fundamental architecture bugs that must be fixed before any timer functionality can work. The fix is straightforward but requires careful attention to match ESP-IDF's register definitions exactly.

**Estimated Fix Effort:** 2-4 hours for experienced implementor

---

## Additional Verification

### Timer Base Addresses (VERIFIED CORRECT)

Our ESP32-C6 timer base addresses are correct:
- `TIMG0_BASE: 0x6000_8000` matches ESP-IDF `DR_REG_TIMERGROUP0_BASE`
- `TIMG1_BASE: 0x6000_9000` matches ESP-IDF `DR_REG_TIMERGROUP1_BASE`

### Timer Hardware (VERIFIED WORKING)

The timer counting and alarm configuration work correctly (verified in hardware test).
The issue is purely in the interrupt routing path.

---

## Quick Fix Summary

### Minimum Changes Required:

1. **`intmtx.rs`**: Add missing registers between offset 0x084 and 0xCC, or use direct register access:
   ```rust
   // Quick fix: Direct register write for timer mapping
   const TG0_T0_INTR_MAP_REG: usize = INTMTX_BASE + 0xCC;
   unsafe { core::ptr::write_volatile(TG0_T0_INTR_MAP_REG as *mut u32, cpu_interrupt); }
   ```

2. **`intpri.rs`**: Change base address AND fix register layout:
   ```rust
   pub const PLIC_BASE: usize = 0x2000_1000;  // PLIC_MX_BASE
   
   register_structs! {
       pub PlicRegisters {
           (0x00 => mxint_enable: ReadWrite<u32>),
           (0x04 => mxint_type: ReadWrite<u32>),
           (0x08 => mxint_clear: ReadWrite<u32>),  // Clear is at 0x08, not 0xA8!
           (0x0C => emip_status: ReadOnly<u32>),   // Status is at 0x0C, not 0x08!
           (0x10 => mxint_pri: [ReadWrite<u32>; 32]),  // Priority starts at 0x10, not 0x0C!
           (0x90 => mxint_thresh: ReadWrite<u32>),
           (0x94 => mxint_claim: ReadWrite<u32>),
           (0x98 => @END),
       }
   }
   ```

### Issue 3: INTPRI Register Layout Also Wrong

**Our INTPRI layout:**
| Offset | Our Register |
|--------|--------------|
| 0x00 | cpu_int_enable |
| 0x04 | cpu_int_type |
| 0x08 | cpu_int_eip_status |
| 0x0C | cpu_int_pri[0] |
| 0x8C | cpu_int_thresh |
| 0xA8 | cpu_int_clear |

**PLIC layout (correct):**
| Offset | PLIC Register |
|--------|---------------|
| 0x00 | mxint_enable |
| 0x04 | mxint_type |
| 0x08 | mxint_clear |
| 0x0C | emip_status |
| 0x10 | mxint_pri[0] |
| 0x90 | mxint_thresh |
| 0x94 | mxint_claim |

**Key differences:**
- Clear and Status registers are swapped
- Priority registers start at 0x10, not 0x0C (4 bytes later)
- Threshold is at 0x90, not 0x8C
- PLIC has a claim register at 0x94

---

## References

- ESP32-C6 Technical Reference Manual, Chapter 10 (Interrupt Matrix)
- ESP-IDF source code (v5.x)
- Previous integration report: `002_integrator_hardware_test.md`
- ESP-IDF `components/soc/esp32c6/register/soc/interrupt_matrix_reg.h`
- ESP-IDF `components/soc/esp32c6/register/soc/plic_reg.h`
- ESP-IDF `components/soc/esp32c6/register/soc/reg_base.h`
