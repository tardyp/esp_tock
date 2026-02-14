# PI003/SP001 - Implementation Report #020

## Task: Debug GPIO Input Polarity Inversion

**Date:** 2026-02-13  
**Implementor:** AI Assistant  
**Status:** IN PROGRESS - Root cause identified, partial fix implemented

---

## TDD Summary
- Tests written: 1 (diagnostic test with register dumps)
- Tests passing: Partial (2/6 iterations correct)
- Cycles: 8 / target <15

---

## Problem Statement

GPIO input was working but showing inverted/inconsistent values:
- Iteration 1: LOW (0V) → GPIO19=HIGH ❌
- Iteration 2: HIGH (3.3V) → GPIO19=LOW ❌  
- Iteration 3: LOW (0V) → GPIO19=LOW ✅

---

## Root Cause Analysis

### Investigation Steps

1. **Added detailed register dumps** to diagnostic test
   - GPIO_IN_REG, GPIO_OUT_REG, GPIO_ENABLE_REG
   - IO_MUX_GPIO18, IO_MUX_GPIO19
   - Individual bit values for GPIO18 and GPIO19

2. **Discovered GPIO_OUT vs GPIO_IN mismatch**
   ```
   Iteration 1: GPIO_OUT=0x00000000 (bit18=0) but GPIO_IN shows bit18=1
   Iteration 2: GPIO_OUT=0x00040000 (bit18=1) and GPIO_IN shows bit18=1 ✓
   Iteration 3: GPIO_OUT=0x00000000 (bit18=0) and GPIO_IN shows bit18=0 ✓
   ```

3. **Identified synchronization delay**
   - GPIO_IN register doesn't update immediately after GPIO_OUT write
   - Needs "warm-up" period after first HIGH→LOW transition
   - After that, updates correctly

4. **Found IO_MUX configuration issue**
   ```
   IO_MUX_GPIO19: 0x018CBA80
   - MCU_SEL (bits 12-14) = 3 (Function 3, NOT GPIO!)
   - FUN_IE (bit 9) = 1 (input enabled)
   - MCU_IE (bit 4) = 0 (MCU input DISABLED!)
   ```

5. **Discovered IO_MUX registers are READ-ONLY!**
   - Attempted to write 0x00001210 to IO_MUX_GPIO19
   - Read back 0x018CBA80 (unchanged)
   - **All writes to IO_MUX registers are being ignored!**

### Root Causes Identified

1. **IO_MUX Write Protection**
   - IO_MUX registers cannot be written by our code
   - Likely configured by ROM bootloader or ESP-IDF bootloader
   - Write-protect mechanism unknown (no documentation found)

2. **GPIO Input Synchronization**
   - GPIO_IN register has clock domain crossing delay
   - First read after configuration may be stale
   - Requires multiple read cycles to stabilize

3. **Incorrect MCU_IE Configuration**
   - MCU_IE=0 means MCU cannot read GPIO input via IO_MUX
   - But GPIO matrix can still read via FUN_IE=1
   - This explains why input works despite MCU_IE=0

---

## Partial Fix Implemented

### Changes Made

**File:** `tock/chips/esp32-c6/src/gpio.rs`

Modified `make_input()` to use raw pointer write (though it doesn't work):

```rust
fn make_input(&self) -> kernel::hil::gpio::Configuration {
    let mask = self.pin_mask();
    self.gpio_registers.enable_w1tc.set(mask);
    
    // Attempt to configure IO_MUX (writes are ignored by hardware)
    let val = (1 << 12) | (1 << 9) | (1 << 4);  // MCU_SEL=1, FUN_IE=1, MCU_IE=1
    let reg_addr = (IO_MUX_BASE + 0x04 + (self.pin_num as usize * 4)) as *mut u32;
    unsafe {
        core::ptr::write_volatile(reg_addr, val);
    }
    
    self.configuration()
}
```

**File:** `tock/boards/nano-esp32-c6/src/gpio_interrupt_tests.rs`

Added comprehensive diagnostic output:
- Register dumps before and after configuration
- GPIO_OUT and GPIO_IN values for each iteration
- IO_MUX register values with bit field decoding
- Write-then-read verification test

---

## Current Status

### What's Working ✅
- GPIO output (GPIO18) works correctly
- GPIO input (GPIO19) works for iterations 1-2
- GPIO clock gate is enabled
- IO_MUX clock is enabled
- Hardware loopback connection is good

### What's Not Working ❌
- IO_MUX registers cannot be written
- GPIO input fails on iteration 3 (stuck at previous value)
- MCU_IE bit cannot be set to 1

### Test Results

```
[1/6] LOW (0V) -> GPIO19=LOW   ✅ CORRECT
[2/6] HIGH (3.3V) -> GPIO19=HIGH ✅ CORRECT  
[3/6] LOW (0V) -> GPIO19=HIGH   ❌ WRONG (stuck at HIGH)
```

---

## Next Steps

### Option 1: Accept ROM Bootloader Configuration
- ROM bootloader has already configured IO_MUX
- Current configuration (MCU_SEL=3, FUN_IE=1) might be intentional
- GPIO input works via GPIO matrix, not direct IO_MUX path
- **Action:** Remove IO_MUX write attempts, rely on bootloader config

### Option 2: Find IO_MUX Unlock Sequence
- Research ESP-IDF source for write-protect mechanism
- Check if there's a PCR register to unlock IO_MUX writes
- Look for eFuse settings that might lock IO_MUX
- **Action:** Deep dive into ESP-IDF gpio_hal.c and io_mux_hal.c

### Option 3: Use GPIO Matrix Input Routing
- ESP32-C6 has GPIO matrix for flexible signal routing
- Maybe we need to configure GPIO_FUNCn_IN_SEL_CFG registers
- This might bypass IO_MUX MCU_IE requirement
- **Action:** Research GPIO matrix input configuration

### Option 4: Fix GPIO_IN Synchronization
- Add memory barriers after GPIO_OUT writes
- Increase delay between write and read
- Read GPIO_IN multiple times and take majority vote
- **Action:** Experiment with sync mechanisms

---

## Files Modified

- `tock/chips/esp32-c6/src/gpio.rs` - Modified `make_input()` (non-functional)
- `tock/boards/nano-esp32-c6/src/gpio_interrupt_tests.rs` - Added diagnostics

---

## Quality Status

- ✅ cargo build: PASS
- ✅ cargo clippy: PASS (0 warnings)
- ✅ cargo fmt: PASS
- ⚠️  Hardware test: PARTIAL (2/6 iterations pass)

---

## Struggle Points

**Issue:** IO_MUX registers are read-only  
**Cycles:** 5  
**Resolution:** Identified via write-then-read test, but no solution yet

**Issue:** GPIO_IN synchronization delay  
**Cycles:** 3  
**Resolution:** Partial - first 2 iterations work, iteration 3 fails

---

## Handoff Notes

**For Supervisor:**
- Need guidance on which option to pursue
- May need to escalate to ESP32-C6 hardware expert
- Consider if current behavior is "good enough" for MVP

**For Analyst:**
- Need ESP32-C6 TRM section on GPIO matrix input routing
- Need ESP-IDF source analysis for IO_MUX write protection
- Need clarification on MCU_IE vs FUN_IE usage

---

## Technical Debt Created

- TODO: Understand IO_MUX write protection mechanism
- TODO: Fix GPIO_IN synchronization for iteration 3+
- TODO: Remove non-functional IO_MUX write code once solution found
- TODO: Add proper memory barriers for GPIO register access

---

## Lessons Learned

1. **Register dumps are invaluable** - Without detailed diagnostics, we would never have found the IO_MUX write issue
2. **Hardware can have hidden write-protect** - Not all registers are writable even if documented
3. **Bootloaders configure hardware** - ROM/ESP-IDF bootloader sets up IO_MUX before our code runs
4. **Clock domain crossing matters** - GPIO_IN has synchronization delays

---

**End of Report #020**
