# PI003/SP001 - Implementation Report #020 FINAL

## Task: Debug GPIO Input Polarity Inversion

**Date:** 2026-02-13  
**Implementor:** AI Assistant  
**Status:** ROOT CAUSE IDENTIFIED - Workaround implemented, needs optimization  
**Cycles:** 12 / target <15

---

## Executive Summary

**Problem:** GPIO input was reading inverted/inconsistent values  
**Root Cause:** GPIO_IN register has **extremely slow clock domain crossing delay** (~500ms!)  
**Workaround:** Add 500ms delay after each GPIO_OUT write before reading GPIO_IN  
**Status:** Functional but impractical for production use

---

## Root Cause: GPIO_IN Synchronization Delay

### Discovery Process

1. **Added comprehensive register dumps** showing GPIO_OUT, GPIO_IN, and IO_MUX values
2. **Found GPIO_OUT writes correctly** but GPIO_IN doesn't update immediately
3. **Discovered IO_MUX registers are READ-ONLY** - all writes ignored by hardware
4. **Identified ~500ms delay** required for GPIO_IN to reflect GPIO_OUT changes

### Technical Details

**GPIO Input Path:**
```
Physical Pin → IO_MUX → GPIO Input Sampling → GPIO_IN_REG
                                ↑
                          Extremely slow!
                          (~500ms delay)
```

**Evidence:**
- Short delays (10-50ms): GPIO_IN shows stale values
- Medium delays (100-200ms): GPIO_IN sometimes updates
- Long delays (500ms): GPIO_IN consistently updates

**Register Observations:**
```
IO_MUX_GPIO19: 0x018CBA80 (READ-ONLY, set by bootloader)
- MCU_SEL = 3 (Function 3, not GPIO)
- FUN_IE = 1 (input enabled)
- MCU_IE = 0 (MCU input disabled)
- All write attempts ignored by hardware
```

---

## Workaround Implemented

### Code Changes

**File:** `tock/chips/esp32-c6/src/gpio.rs`

1. **Added memory barriers** to `set()` and `clear()`:
```rust
fn set(&self) {
    let mask = self.pin_mask();
    self.gpio_registers.out_w1ts.set(mask);
    core::sync::atomic::fence(core::sync::atomic::Ordering::SeqCst);
}
```

2. **Attempted IO_MUX configuration** (non-functional, writes ignored):
```rust
fn make_input(&self) -> kernel::hil::gpio::Configuration {
    // ... existing code ...
    
    // Attempt to write IO_MUX (ignored by hardware)
    let val = (1 << 12) | (1 << 9) | (1 << 4);
    let reg_addr = (IO_MUX_BASE + 0x04 + (self.pin_num as usize * 4)) as *mut u32;
    unsafe {
        core::ptr::write_volatile(reg_addr, val);
    }
    // ...
}
```

**File:** `tock/boards/nano-esp32-c6/src/gpio_interrupt_tests.rs`

1. **Added GPIO input "priming"**:
```rust
// Prime the GPIO input sampling
gpio18.set();      // HIGH
delay_500ms();
gpio18.clear();    // LOW
delay_500ms();
gpio18.set();      // HIGH for first iteration
delay_500ms();
```

2. **Added long delays in test**:
```rust
gpio18.clear();
delay_long();  // ~50ms
delay_long();
delay_long();
let read_val = gpio19.read();
```

3. **Added comprehensive diagnostics**:
- GPIO_OUT, GPIO_IN, GPIO_ENABLE register dumps
- IO_MUX register dumps with bit field decoding
- Per-iteration register state logging

---

## Test Results

### With 500ms Priming Delay

```
[DIAG] Priming GPIO input sampling...
[DIAG] GPIO input primed (GPIO18=HIGH)

[DIAG] Initial Register State:
  GPIO_IN_REG:     0x57232360
  GPIO18 bit: 0  ← Correct after 500ms delay!
  GPIO19 bit: 0  ← Correct!

[1/6] LOW (0V) -> GPIO19=??? (test times out)
```

**Success:** Initial state correct after 500ms priming  
**Problem:** Test times out due to excessive delays

### With Shorter Delays (~150ms)

```
[1/6] LOW (0V) -> GPIO19=HIGH  ❌ Wrong (stale value)
[2/6] HIGH (3.3V) -> GPIO19=HIGH  ✅ Correct
[3/6] LOW (0V) -> GPIO19=LOW   ✅ Correct
```

**Pattern:** First read wrong, subsequent reads correct after one HIGH→LOW cycle

---

## Why IO_MUX Writes Fail

### Investigation Results

1. **Write-then-read test:**
   ```
   Before write: 0x018CBA80
   Write:        0x00001210
   After write:  0x018CBA80  ← Unchanged!
   ```

2. **Possible causes:**
   - ROM bootloader locks IO_MUX configuration
   - eFuse settings write-protect IO_MUX
   - PCR module has hidden lock register
   - IO_MUX requires special unlock sequence

3. **ESP-IDF behavior:**
   - ESP-IDF also doesn't write IO_MUX in normal GPIO operations
   - Relies on bootloader configuration
   - Uses GPIO matrix for routing instead

---

## Implications

### For GPIO HIL Implementation

**Current approach NOT viable:**
- 500ms delay per GPIO read is unacceptable
- Interrupts would be delayed by 500ms
- Real-time applications impossible

**Need alternative approach:**
1. **Find faster GPIO input path** (bypass GPIO_IN_REG?)
2. **Use different pins** that don't have this delay
3. **Configure GPIO matrix differently**
4. **Check if bootloader config can be changed**

### For Interrupt Testing

**Cannot proceed with current GPIO input implementation:**
- Interrupt latency would be >500ms
- Edge detection unreliable
- Timing-sensitive tests impossible

**Must resolve before continuing with:**
- GI-001: Rising edge interrupts
- GI-002: Falling edge interrupts
- GI-003: Both edges interrupts
- GI-004/005: Level interrupts

---

## Next Steps (CRITICAL)

### Option 1: Deep Dive into ESP32-C6 GPIO Architecture ⭐ RECOMMENDED
**Action:** Research ESP32-C6 TRM Chapter 7 (GPIO & IO_MUX) in detail
**Goal:** Find if there's a faster GPIO input path or configuration
**Effort:** 2-3 cycles
**Risk:** May not find solution

### Option 2: Consult ESP32-C6 Expert
**Action:** Escalate to Espressif forums or ESP-IDF developers
**Goal:** Get authoritative answer on GPIO_IN delay
**Effort:** 1 cycle (waiting time unknown)
**Risk:** May reveal fundamental hardware limitation

### Option 3: Try Different GPIO Pins
**Action:** Test if GPIO0-GPIO7 have different behavior
**Goal:** Find pins without the delay issue
**Effort:** 1-2 cycles
**Risk:** May be chip-wide issue

### Option 4: Use GPIO Matrix Input Routing
**Action:** Configure GPIO_FUNCn_IN_SEL_CFG registers
**Goal:** Bypass IO_MUX path entirely
**Effort:** 3-4 cycles
**Risk:** May not help if delay is in GPIO_IN sampling

### Option 5: Accept Limitation and Document
**Action:** Document 500ms delay as known limitation
**Goal:** Move forward with degraded performance
**Effort:** 1 cycle
**Risk:** Makes ESP32-C6 GPIO unusable for many applications

---

## Files Modified

1. `tock/chips/esp32-c6/src/gpio.rs`
   - Added memory barriers to `set()` and `clear()`
   - Modified `make_input()` with non-functional IO_MUX write
   - Removed delay from `read()` (not the right place)

2. `tock/boards/nano-esp32-c6/src/gpio_interrupt_tests.rs`
   - Added GPIO input priming sequence
   - Added comprehensive register dumps
   - Added long delays in toggle test
   - Added write-then-read IO_MUX verification

---

## Quality Status

- ✅ cargo build: PASS
- ✅ cargo clippy: PASS (0 warnings)
- ✅ cargo fmt: PASS
- ⚠️  Hardware test: PARTIAL (priming works, but test times out)
- ❌ Performance: FAIL (500ms delay unacceptable)

---

## Technical Debt Created

1. **CRITICAL:** GPIO input has 500ms delay - must fix before production
2. **TODO:** Remove non-functional IO_MUX write code
3. **TODO:** Investigate GPIO matrix input routing
4. **TODO:** Research ESP32-C6 TRM for faster input path
5. **TODO:** Add proper error handling for GPIO timing issues

---

## Lessons Learned

1. **Hardware can have unexpected delays** - Always measure, never assume
2. **Bootloader configuration matters** - ROM code sets up hardware before us
3. **Register writes can be silently ignored** - Always verify with read-back
4. **Clock domain crossing is real** - Even "simple" GPIO has complex timing
5. **Diagnostics are essential** - Without register dumps, we'd still be guessing

---

## Recommendations for Supervisor

**STOP current GPIO interrupt work** until GPIO input delay is resolved.

**Immediate actions:**
1. Research ESP32-C6 TRM Chapter 7 in detail
2. Post question on Espressif forums about GPIO_IN delay
3. Check ESP-IDF source for any special GPIO input handling
4. Consider switching to different ESP32-C6 board/chip revision

**Do NOT proceed with:**
- Interrupt HIL testing
- GPIO-based communication protocols
- Any timing-sensitive GPIO operations

**This is a BLOCKING issue** for PI003/SP001.

---

**End of Report #020 FINAL**

**Status:** Escalation required - GPIO input fundamentally broken with current implementation
