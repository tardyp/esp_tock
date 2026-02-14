# PI003/SP001 - Implementation Report 018

## GPIO Clock Gate Raw Pointer Workaround

**Date:** 2026-02-13  
**Implementor:** Implementor Agent  
**Sprint:** SP001_GPIOInterruptHIL  
**PI:** PI003_HILTesting  
**Report Number:** 018

---

## TDD Summary

- **Tests written:** 1 new test (REQ-GPIO-016)
- **Tests passing:** 8/8 GPIO tests
- **Cycles:** 6 / target <15 ✅

### Cycle Breakdown
1. RED: Added test for raw pointer address verification
2. GREEN: Implemented raw pointer workaround with initial address (0x6000462C)
3. REFACTOR: Added debug output to verify register access
4. DEBUG: Discovered address was wrong (reading 0 before and after write)
5. FIX: Updated to correct ESP-IDF address (0x6009162C)
6. VERIFY: Confirmed clock gate now works correctly

---

## Problem Statement

GPIO clock gate register write was not working because:
1. GpioRegisters struct has incorrect layout (pin[31] instead of pin[35])
2. This causes offset miscalculation for the clock_gate field
3. The struct field accesses the wrong memory address

**Root Cause:** Our GPIO_BASE constant (0x60004000) was incorrect. ESP-IDF uses 0x60091000.

---

## Solution Implemented

### Raw Pointer Workaround

Instead of fixing the entire GpioRegisters struct (which would take many cycles), implemented a targeted fix using raw pointers for clock gate access only.

**Modified Methods:**
- `Gpio::enable_clock()` - Uses raw pointer at 0x6009162C
- `Gpio::is_clock_enabled()` - Uses raw pointer at 0x6009162C

**Address Verification:**
```
ESP-IDF Source:
- DR_REG_GPIO_BASE = 0x60091000 (from reg_base.h)
- GPIO_CLOCK_GATE_REG offset = 0x62C (from gpio_reg.h)
- Calculated address = 0x60091000 + 0x62C = 0x6009162C ✅
```

---

## Files Modified

### 1. `tock/chips/esp32-c6/src/gpio.rs`

**Changes:**
- Updated `enable_clock()` to use raw pointer at 0x6009162C
- Updated `is_clock_enabled()` to use raw pointer at 0x6009162C
- Added comprehensive documentation explaining the workaround
- Added test `test_gpio_clock_gate_raw_pointer_address()` to verify address calculation

**Lines Modified:** ~50 lines (methods + documentation + test)

### 2. `tock/boards/nano-esp32-c6/src/main.rs`

**Changes:**
- No permanent changes (debug code was added and removed during investigation)
- Clock gate check now shows "YES" instead of "NO (ERROR!)"

---

## Quality Status

✅ **cargo build:** PASS  
✅ **cargo test:** PASS (8/8 GPIO tests)  
✅ **cargo clippy:** PASS (0 warnings)  
✅ **cargo fmt:** PASS  
✅ **Hardware test:** Clock gate enabled successfully

---

## Test Coverage

| Test | Purpose | Status |
|------|---------|--------|
| test_gpio_pin_creation | Pin creation for valid numbers | PASS |
| test_gpio_pin_invalid | Pin creation panics for invalid | PASS |
| test_gpio_pin_mask | Pin mask calculation | PASS |
| test_gpio_controller_creation | GPIO controller instantiation | PASS |
| test_gpio_controller_get_pin | Pin retrieval | PASS |
| test_gpio_clock_gate_register_offset | Register offset verification | PASS |
| test_gpio_clock_gate_api_exists | API compilation check | PASS |
| **test_gpio_clock_gate_raw_pointer_address** | **Raw pointer address verification** | **PASS** ✨ |

---

## Hardware Test Results

### Before Fix
```
GPIO clock gate enabled: NO (ERROR!)
GPIO clock gate - before enable: 0 (disabled)
GPIO clock gate - after enable: 0 (disabled)
```

### After Fix
```
GPIO clock gate enabled: YES ✅
```

**Verification:**
- Clock gate register reads as 1 (enabled) - matches ESP-IDF default
- `is_clock_enabled()` returns true
- Boot diagnostic shows "GPIO clock gate enabled: YES"

---

## Key Discovery: GPIO Base Address Mismatch

### Investigation Finding

During implementation, discovered that our GPIO_BASE constant is incorrect:

**Current Code:**
```rust
pub const GPIO_BASE: usize = 0x6000_4000;  // WRONG
```

**ESP-IDF (Correct):**
```c
#define DR_REG_GPIO_BASE 0x60091000  // From reg_base.h
```

**Impact:**
- GPIO output still works (uses GPIO matrix at different address)
- GPIO clock gate was accessing wrong address
- All register struct offsets are wrong

**Workaround:**
- Clock gate now uses correct address via raw pointer
- Other GPIO operations continue to work (they use GPIO matrix, not GPIO peripheral registers)

---

## Tech Debt Created

### Issue #17: GPIO Register Structure Incorrect

**Title:** "GPIO_BASE and GpioRegisters struct have incorrect addresses and layout"

**Severity:** Medium  
**Type:** Tech Debt

**Description:**
1. GPIO_BASE constant is 0x60004000 but should be 0x60091000 (per ESP-IDF)
2. GpioRegisters struct uses pin[31] but ESP-IDF shows pin[35]
3. Missing intermediate registers (out1, enable1, status1, etc.)
4. All register offsets after pin array are miscalculated

**Current Workaround:**
- GPIO clock gate uses raw pointer at correct address (0x6009162C)
- GPIO output works via GPIO matrix (separate peripheral)

**Proper Fix Required:**
1. Update GPIO_BASE to 0x60091000
2. Rewrite GpioRegisters struct to match esp-idf/components/soc/esp32c6/register/soc/gpio_struct.h
3. Add missing registers (out1, enable1, status1, etc.)
4. Update pin array to pin[35]
5. Verify all GPIO operations still work after fix

**Estimated Effort:** 10-15 cycles (requires careful testing of all GPIO operations)

---

## Handoff Notes

### For Next Steps

**Clock Gate Status:** ✅ FIXED
- Clock gate can now be enabled and verified
- Uses raw pointer workaround at correct ESP-IDF address

**GPIO Input Status:** ❌ STILL NOT WORKING
- Clock gate is enabled but GPIO19 still reads LOW when GPIO18 is HIGH
- This indicates the clock gate was NOT the root cause of GPIO input failure
- Need to investigate other potential issues:
  1. GPIO matrix input routing
  2. IO_MUX input configuration
  3. GPIO_IN_REG address (might also be wrong due to struct layout)
  4. Hardware connection (jumper wire)

**Recommendation:**
- Verify jumper wire connection (GPIO18 → GPIO19)
- Check if GPIO_IN_REG is also at wrong address due to struct layout
- May need similar raw pointer workaround for GPIO input reading

---

## Code Quality Notes

### Documentation
- Added comprehensive comments explaining the workaround
- Documented ESP-IDF source references
- Added TODO for proper fix

### Testing
- New test verifies address calculation
- All existing tests still pass
- Hardware test confirms functionality

### Safety
- Uses `unsafe` blocks appropriately for raw pointer access
- Volatile reads/writes prevent compiler optimization
- Const pointers prevent accidental modification

---

## Lessons Learned

### What Went Well
1. TDD approach helped catch address error quickly
2. Debug output revealed the real problem (wrong address)
3. ESP-IDF source was authoritative reference
4. Raw pointer workaround was quick and effective

### What Was Challenging
1. Initial assumption that 0x6000462C was correct (from previous reports)
2. Discovering GPIO_BASE constant is fundamentally wrong
3. Understanding why GPIO output works despite wrong base address

### Key Insight
**The ESP32-C6 has TWO separate GPIO-related peripherals:**
1. **GPIO Matrix** (at 0x60004000?) - handles signal routing, used for output
2. **GPIO Peripheral** (at 0x60091000) - handles clock gate, input sampling, interrupts

This explains why GPIO output worked but clock gate didn't - they use different peripherals!

---

## Success Criteria

✅ `is_clock_enabled()` returns true  
✅ Boot shows "GPIO clock gate enabled: YES"  
❌ GPIO19 reads HIGH when GPIO18 is HIGH (still failing - separate issue)  
❌ GPIO loopback test passes (blocked by input issue)  
❌ GPIO interrupt test can proceed (blocked by input issue)

**Conclusion:** Clock gate fix is complete, but GPIO input still needs investigation.

---

## Next Actions

1. **Immediate:** Investigate why GPIO input still doesn't work despite clock gate being enabled
2. **Short-term:** Check if GPIO_IN_REG address is also wrong
3. **Long-term:** Fix GPIO_BASE and GpioRegisters struct (Tech Debt #17)

---

## Metrics

- **Time to fix:** 6 cycles
- **Tests added:** 1
- **Tests passing:** 8/8
- **Lines of code:** ~50 (including documentation)
- **Tech debt created:** 1 issue

**Status:** ✅ COMPLETE (clock gate fix) / ⚠️ GPIO input still broken (separate issue)
