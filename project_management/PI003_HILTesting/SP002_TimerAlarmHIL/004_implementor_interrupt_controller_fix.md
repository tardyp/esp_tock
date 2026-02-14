# PI003/SP002 - Implementation Report: Interrupt Controller Fix

## TDD Summary
- Tests written: 6 (new PLIC tests + updated INTC tests)
- Tests passing: 23 (all chip tests)
- Cycles: 4 / target <15

## Bug Summary

Three critical bugs were identified in the interrupt controller implementation:

### BUG 1: INTMTX Register Offsets Wrong
**Root Cause:** Register struct had incorrect offsets for peripheral interrupt mapping.

| Register | Old Offset | Correct Offset | Delta |
|----------|------------|----------------|-------|
| GPIO_INTERRUPT_PRO_MAP | 0x7C | 0x78 | -4 |
| GPIO_INTERRUPT_PRO_NMI_MAP | 0x80 | 0x7C | -4 |
| UART0_INTR_MAP | 0x74 | 0xAC | +56 |
| UART1_INTR_MAP | 0x78 | 0xB0 | +56 |
| TG0_T0_INTR_MAP | 0x84 | 0xCC | +72 |
| TG1_T0_INTR_MAP | 0x88 | 0xD8 | +80 |

**Fix:** Completely rewrote `IntmtxRegisters` struct with all 81 registers from ESP-IDF.

### BUG 2: Wrong Interrupt Controller Base Address
**Root Cause:** Code used INTPRI at `0x600C5000` instead of PLIC at `0x20001000`.

| Component | Old Address | Correct Address |
|-----------|-------------|-----------------|
| INTPRI (wrong) | 0x600C5000 | N/A |
| PLIC_MX (correct) | N/A | 0x20001000 |

**Fix:** Created new `plic.rs` module with correct PLIC registers.

### BUG 3: PLIC Register Layout Wrong
**Root Cause:** Even if base was correct, register offsets were wrong.

| Register | INTPRI Offset | PLIC Offset |
|----------|---------------|-------------|
| Enable | 0x00 | 0x00 |
| Type | 0x04 | 0x04 |
| Clear | 0xA8 | 0x08 |
| EIP Status | 0x08 | 0x0C |
| Priority[0] | 0x0C | 0x10 |
| Threshold | 0x8C | 0x90 |

**Fix:** PLIC register struct matches ESP-IDF `plic_reg.h`.

## Files Modified

| File | Purpose |
|------|---------|
| `chips/esp32-c6/src/intmtx.rs` | Fixed all register offsets (81 registers) |
| `chips/esp32-c6/src/plic.rs` | **NEW** - PLIC driver with correct layout |
| `chips/esp32-c6/src/intc.rs` | Updated to use PLIC instead of INTPRI |
| `chips/esp32-c6/src/chip.rs` | Updated to use PLIC base address |
| `chips/esp32-c6/src/lib.rs` | Added PLIC module export, recursion limit |

## Quality Status
- cargo build: **PASS**
- cargo test: **PASS** (23 tests)
- cargo clippy: **PASS** (0 warnings)
- cargo fmt: **PASS**

## Test Coverage

| Test | Purpose | Status |
|------|---------|--------|
| test_plic_base_address | Verify PLIC base is 0x20001000 | PASS |
| test_plic_register_layout | Verify struct size is 0x98 | PASS |
| test_priority_array_size | Verify 32 priority registers | PASS |
| test_intmtx_base_address | Verify INTMTX base is 0x60010000 | PASS |
| test_save_restore_logic | Test interrupt save/restore | PASS |
| test_multiple_saved_interrupts | Test multiple interrupt handling | PASS |

## Code Changes

### INTMTX Register Offsets (Before/After)

**Before (WRONG):**
```rust
(0x074 => uart0_intr_map: ReadWrite<u32>),
(0x078 => uart1_intr_map: ReadWrite<u32>),
(0x07C => gpio_interrupt_pro_map: ReadWrite<u32>),
(0x084 => timg0_intr_map: ReadWrite<u32>),  // 72 bytes off!
```

**After (CORRECT):**
```rust
(0x078 => gpio_interrupt_pro_map: ReadWrite<u32>),  // GPIO at 0x78
(0x0AC => uart0_intr_map: ReadWrite<u32>),          // UART0 at 0xAC
(0x0B0 => uart1_intr_map: ReadWrite<u32>),          // UART1 at 0xB0
(0x0CC => tg0_t0_intr_map: ReadWrite<u32>),         // Timer0 at 0xCC
(0x0D8 => tg1_t0_intr_map: ReadWrite<u32>),         // Timer1 at 0xD8
```

### PLIC Driver (NEW)

```rust
/// PLIC Machine mode registers for ESP32-C6
pub PlicRegisters {
    (0x000 => mxint_enable: ReadWrite<u32>),      // Enable mask
    (0x004 => mxint_type: ReadWrite<u32>),        // Level/edge
    (0x008 => mxint_clear: ReadWrite<u32>),       // Clear pending
    (0x00C => emip_status: ReadOnly<u32>),        // Pending status
    (0x010 => mxint_pri: [ReadWrite<u32>; 32]),   // Priorities
    (0x090 => mxint_thresh: ReadWrite<u32>),      // Threshold
    (0x094 => mxint_claim: ReadWrite<u32>),       // Claim/complete
    (0x098 => @END),
}
```

### INTC Update

```rust
// OLD (WRONG):
use crate::intpri::{Intpri, IntpriRegisters, INTPRI_BASE};
const INTC_INTPRI_BASE: usize = INTPRI_BASE;  // 0x600C5000

// NEW (CORRECT):
use crate::plic::{Plic, PlicRegisters, PLIC_MX_BASE};
const INTC_PLIC_BASE: usize = PLIC_MX_BASE;   // 0x20001000
```

## ESP-IDF Reference Files Used

| File | Purpose |
|------|---------|
| `soc/interrupt_matrix_reg.h` | INTMTX register offsets |
| `soc/plic_reg.h` | PLIC register layout |
| `soc/reg_base.h` | Base addresses (PLIC_MX = 0x20001000) |

## Hardware Testing Ready

**Status: READY FOR HARDWARE TEST**

The following changes should enable timer interrupts:

1. **INTMTX:** Timer Group 0 now maps to correct register (0xCC instead of 0x84)
2. **PLIC:** Enable/priority/clear operations now go to correct addresses
3. **Pending Status:** Now reads from correct register (0x0C instead of 0x08)

### Expected Behavior After Fix

```
[Timer Alarm Test]
Setting alarm for 100ms...
Alarm callback fired!  <-- This should now work
```

## Handoff Notes for Integrator

1. **Flash the board** with new firmware:
   ```bash
   cd tock/boards/nano-esp32-c6
   cargo build --release
   # Flash using espflash
   ```

2. **Run timer tests** to verify interrupts fire:
   ```bash
   ./scripts/test_timer_alarms.sh
   ```

3. **Expected results:**
   - Timer alarms should fire callbacks
   - GPIO interrupts should still work (no regression)
   - All 20 timer test cases should pass

4. **If issues persist:**
   - Check serial output for interrupt-related messages
   - Verify PLIC registers are being written (add debug prints)
   - Compare with ESP-IDF interrupt initialization sequence

## TDD Metrics

| Metric | Value |
|--------|-------|
| Cycles used | 4 |
| Target | <15 |
| Tests written | 6 |
| Tests passing | 23 |
| Red-Green-Refactor compliance | 100% |

## Session Summary

**Task:** Fix interrupt controller bugs (INTMTX offsets + PLIC driver)
**Cycles:** 4 / target <15
**Status:** COMPLETE - Ready for hardware testing

### Completed
- [x] Fixed INTMTX register offsets (81 registers)
- [x] Created PLIC driver with correct layout
- [x] Updated INTC to use PLIC instead of INTPRI
- [x] Updated chip.rs to use PLIC base address
- [x] All tests passing (23)
- [x] Clippy clean (0 warnings)
- [x] Format check passed

### Key Insight
The ESP32-C6 uses a **PLIC** (Platform-Level Interrupt Controller) at `0x20001000`, 
not the INTPRI controller at `0x600C5000`. This is a fundamental architectural 
difference that was causing all interrupt operations to write to the wrong hardware.
