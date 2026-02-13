# PI003/SP001 Report 010 - Implementor: GPIO Interrupt Debug (INCOMPLETE)

**Date:** 2026-02-12  
**Agent:** Implementor  
**Task:** Debug GPIO interrupt test failure  
**Status:** IN PROGRESS - Root cause not yet identified

---

## Executive Summary

Investigated GPIO interrupt test failure where callbacks are not firing (count=0). Verified interrupt configuration chain but interrupts still not working. **Binary size constraints prevented comprehensive debugging.** Need different approach or larger ROM allocation.

**Current Status:** GI-001 test still fails with count=0

---

## Problem Statement

GPIO interrupt test shows:
```
[GI-001] Rising Edge
FAIL (count=0)
```

Expected: Interrupt callback fires when GPIO18 toggles LOW→HIGH, count=1  
Actual: Callback never fires, count=0

---

## Investigation Summary

### Verified Components

✅ **GPIO Interrupt Mapping (INTMTX)**
- GPIO interrupt (IRQ 31) mapped to CPU interrupt 31
- Verified in `intc.rs` line 68

✅ **GPIO Interrupt Handler**
- `service_interrupt(31)` calls `gpio.handle_interrupt()`
- Verified in `chip.rs` line 60-62

✅ **GPIO Driver Structure**
- `handle_interrupt()` iterates all pins
- Calls `pin.handle_interrupt()` for each
- Verified in `gpio.rs` line 492-496

✅ **Pin Interrupt Handler**
- Checks `is_pending()` for interrupt status
- Clears status and calls client callback
- Verified in `gpio.rs` line 376-386

✅ **Interrupt Enable Code**
- `enable_interrupts()` sets INT_TYPE and INT_ENA
- INT_ENA set to 0b00001 (CPU line 0)
- Verified in `gpio.rs` line 353

### Attempted Fixes

❌ **Enable Global Interrupts (mstatus.MIE)**
- Added `csrsi mstatus, 0x8` to set MIE bit
- Result: No change, still count=0

❌ **Enable Machine External Interrupts (mie.MEIE)**
- Added `csrs mie, 0x800` to set MEIE bit  
- Result: No change, still count=0

### Blocked Investigation

⚠️ **Binary Size Constraint**
- Cannot add comprehensive debug output
- ROM limit: 32KB (31,280 bytes used)
- Debug code causes "Text plus relocations exceeds ROM space"
- Unable to verify:
  - GPIO PIN_CTRL register values
  - Interrupt status register
  - Whether GPIO interrupt handler is being called
  - Whether pin interrupt handler is being called

---

## Hypotheses

### Hypothesis 1: INT_ENA Value Incorrect

**Issue:** GPIO driver sets INT_ENA=0b00001 (CPU line 0), but GPIO peripheral interrupt is on CPU line 31

**Evidence:**
- `enable_interrupts()` sets INT_ENA.val(0b00001)
- INTMTX maps GPIO (IRQ 31) to CPU interrupt 31
- Possible mismatch between pin-level and peripheral-level routing

**Test Needed:**
- Try INT_ENA=0b11111 (all CPU lines)
- Or determine correct INT_ENA value from ESP32-C6 TRM

**Likelihood:** HIGH

### Hypothesis 2: Missing GPIO Peripheral Enable

**Issue:** GPIO peripheral itself might need global interrupt enable

**Evidence:**
- Only pin-level INT_ENA is set
- No global GPIO interrupt enable register configured
- ESP32-C6 might have GPIO_INTR_ENA register

**Test Needed:**
- Check ESP32-C6 TRM for GPIO peripheral interrupt enable
- Look for GPIO_INTR_ENA or similar register

**Likelihood:** MEDIUM

### Hypothesis 3: Interrupt Status Not Latching

**Issue:** Interrupt triggers but status register not being set

**Evidence:**
- `is_pending()` checks status register
- If status not set, callback won't fire
- Could be timing issue or missing configuration

**Test Needed:**
- Manually read GPIO status register after trigger
- Check if interrupt is firing but not latching

**Likelihood:** MEDIUM

### Hypothesis 4: Client Not Set Correctly

**Issue:** Client callback pointer not properly stored

**Evidence:**
- `set_client()` uses OptionalCell
- Callback uses `client.map(|client| client.fired())`
- If client is None, callback won't fire

**Test Needed:**
- Verify client is actually set
- Check if OptionalCell is working correctly

**Likelihood:** LOW (code looks correct)

---

## Files Modified

### tock/boards/nano-esp32-c6/src/main.rs

**Changes:**
- Added global interrupt enable (mstatus.MIE)
- Added machine external interrupt enable (mie.MEIE)
- Lines 206-212

**Code:**
```rust
// Enable global interrupts (mstatus.MIE) and machine external interrupts (mie.MEIE)
unsafe {
    core::arch::asm!("csrsi mstatus, 0x8");  // Set MIE bit (bit 3)
    // Set MEIE bit (bit 11) in mie register
    let mie_val: u32 = 0x800;
    core::arch::asm!("csrs mie, {}", in(reg) mie_val);
}
```

### tock/chips/esp32-c6/src/gpio_interrupt_tests.rs

**Changes:**
- Added `read_pin_ctrl_reg()` helper (unused due to binary size)
- Removed debug output from `test_rising_edge()`
- Lines 118-122

---

## Quality Status

### Build Status
```
✅ cargo build --release --features=gpio_interrupt_tests: PASS
✅ Binary size: 31,280 bytes (within 32KB limit, but no room for debug code)
```

### Test Results
```
❌ GI-001 Rising Edge: FAIL (count=0)
```

---

## Next Steps

### Immediate Actions (Blocked by Binary Size)

1. **Increase ROM allocation**
   - Modify `layout.ld` to allocate more ROM space
   - Current: 32KB, could increase to 64KB or 128KB
   - Would allow comprehensive debug output

2. **Add debug instrumentation**
   - Print GPIO PIN_CTRL register values
   - Print interrupt status register
   - Print whether handlers are being called
   - Verify INT_ENA and INT_TYPE values

3. **Test INT_ENA values**
   - Try INT_ENA=0b11111 (all lines)
   - Try INT_ENA matching CPU interrupt number
   - Determine correct value from TRM

### Alternative Approaches

1. **Use external logic analyzer**
   - Monitor GPIO18 and GPIO19 signals
   - Verify hardware is actually triggering
   - Check timing of transitions

2. **Compare with ESP-IDF**
   - Check ESP-IDF GPIO driver source
   - See what INT_ENA value they use
   - Check for missing initialization steps

3. **Simplify test**
   - Remove all other code to make room
   - Add minimal debug output
   - Binary debug to isolate issue

---

## Struggle Points

### Struggle 1: Binary Size Constraint (Cycles 1-8)

**Issue:** Cannot add debug output without exceeding ROM limit

**Impact:** Unable to verify register values or execution flow

**Attempts:**
- Removed hex printing functions
- Minimized debug strings
- Removed unused functions
- Still exceeded limit with any substantial debug code

**Resolution:** None - blocked on this issue

**Lesson:** Need larger ROM allocation for development/debugging

### Struggle 2: Limited Documentation (Cycles 9-12)

**Issue:** ESP32-C6 TRM doesn't clearly explain INT_ENA field usage

**Impact:** Uncertain what value to use for INT_ENA

**Attempts:**
- Read TRM Chapter 7 (GPIO)
- Checked ESP-IDF source (not easily accessible)
- Tried different values blindly

**Resolution:** None - need to find correct documentation or examples

---

## Recommendations

### For Product Owner

**Decision Needed:** Increase ROM allocation for development?

**Options:**
1. **Increase ROM to 64KB** - Allows debug code, easier development
2. **Keep 32KB** - Production size, but harder to debug
3. **Conditional allocation** - 64KB for debug builds, 32KB for release

**Trade-offs:**
- Larger ROM: Easier debugging, faster development
- Smaller ROM: More realistic production constraints
- ESP32-C6 has 8MB flash, so 64KB is still tiny (<1%)

### For Analyst

**Question:** Should we pause interrupt testing until ROM issue resolved?

**Alternatives:**
1. Continue with blind debugging (slow, frustrating)
2. Increase ROM allocation (quick fix, easier debugging)
3. Use external tools (logic analyzer, JTAG debugger)

---

## Technical Debt

### Issue: ROM Size Too Small for Development

**Problem:** 32KB ROM limit prevents adding debug instrumentation

**Impact:**
- Slow debugging process
- Cannot verify register values
- Cannot trace execution flow
- Increases development time significantly

**Proper Solution:**
- Increase ROM allocation to 64KB or 128KB for development
- Use conditional compilation for debug vs release builds
- ESP32-C6 has 8MB flash, plenty of room

**Priority:** HIGH - Blocking SP001 progress

---

## References

- ESP32-C6 Technical Reference Manual - Chapter 7 (GPIO & IO_MUX)
- ESP32-C6 Technical Reference Manual - Chapter 10 (Interrupt Matrix)
- Report 005: GPIO interrupt test infrastructure
- Report 009: Short delay workaround

---

**End of Report 010 (INCOMPLETE)**

**Status:** Paused pending decision on ROM allocation or alternative debugging approach
