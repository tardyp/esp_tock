# PI003/SP001 - Implementation Report 013

## Task: Fix GPIO Input Reading Issue

**Status:** ❌ BLOCKED - Need Supervisor Assistance  
**Cycles:** 30+ / target <15  
**Date:** 2026-02-13

---

## Problem Statement

GPIO input reading is fundamentally broken on ESP32-C6. Hardware test shows:

```
[1/6] LOW (0V) -> GPIO19=LOW    ← Correct
[2/6] HIGH (3.3V) -> GPIO19=LOW ← WRONG! Should be HIGH
[3/6] LOW (0V) -> GPIO19=LOW    ← Correct
```

**Hardware Status:** User verified with ohmmeter that GPIO18 and GPIO19 are physically connected with jumper wire. This is a SOFTWARE issue.

---

## Root Cause Investigation

### Findings from ESP-IDF Analysis

Compared Tock implementation with ESP-IDF `gpio.c` and found several missing configurations:

1. **MCU_SEL Field Value** ✅ FIXED
   - **Issue:** GPIO_PIN enum had `GPIO = 0` (WRONG!)
   - **Fix:** Changed to `GPIO = 1` (matches ESP-IDF `PIN_FUNC_GPIO`)
   - **Evidence:** ESP-IDF `io_mux.h`: `#define PIN_FUNC_GPIO 1`

2. **GPIO Matrix Output Routing** ✅ ADDED
   - **Issue:** Missing `GPIO_FUNCn_OUT_SEL_CFG` register configuration
   - **Fix:** Added `configure_gpio_matrix_output()` function
   - **Evidence:** ESP-IDF calls `esp_rom_gpio_connect_out_signal(gpio_num, SIG_GPIO_OUT_IDX, false, false)`

3. **Output Disable for Input Pins** ✅ ADDED
   - **Issue:** Input pins should have output disabled
   - **Fix:** Added `gpio_registers.enable_w1tc.set(mask)` in `make_input()`
   - **Evidence:** ESP-IDF `gpio_set_direction()` calls `gpio_output_disable()` for input mode

4. **Input Enable Bits** ✅ TRIED BOTH
   - Tried `FUN_IE` (bit 9) - ESP-IDF uses this
   - Tried `MCU_IE` (bit 4) - Also set this
   - Tried both together - Still doesn't work!

---

## Changes Made

### File: `tock/chips/esp32-c6/src/gpio.rs`

1. **Fixed MCU_SEL enum** (lines 77-84):
```rust
MCU_SEL OFFSET(12) NUMBITS(3) [
    Function0 = 0,
    GPIO = 1,        // ← Changed from 0 to 1
    Function2 = 2,
    ...
]
```

2. **Added GPIO matrix constants** (lines 28-32):
```rust
const SIG_GPIO_OUT_IDX: u32 = 128;
const GPIO_FUNC_OUT_SEL_CFG_OFFSET: usize = 0x554;
```

3. **Added GPIO matrix configuration function** (lines 432-445):
```rust
fn configure_gpio_matrix_output(&self) {
    let reg_addr = GPIO_BASE + GPIO_FUNC_OUT_SEL_CFG_OFFSET + (self.pin_num as usize * 4);
    unsafe {
        let reg = reg_addr as *mut u32;
        core::ptr::write_volatile(reg, SIG_GPIO_OUT_IDX);
    }
}
```

4. **Updated make_output()** (line 276):
```rust
fn make_output(&self) -> kernel::hil::gpio::Configuration {
    // ... existing code ...
    self.configure_gpio_matrix_output();  // ← Added
    self.configuration()
}
```

5. **Updated make_input()** (lines 293-310):
```rust
fn make_input(&self) -> kernel::hil::gpio::Configuration {
    let mask = self.pin_mask();
    
    // Disable output (input pins should not drive)
    self.gpio_registers.enable_w1tc.set(mask);
    
    // Configure IO_MUX with all input-related bits
    let io_mux_reg = self.get_io_mux_register();
    io_mux_reg.write(
        GPIO_PIN::MCU_SEL::GPIO       // Function = GPIO (1)
        + GPIO_PIN::FUN_IE::SET        // Function input enable
        + GPIO_PIN::MCU_IE::SET        // MCU input enable
        + GPIO_PIN::MCU_OE::CLEAR      // MCU output disable
        + GPIO_PIN::FUN_WPU::CLEAR     // No pull-up
        + GPIO_PIN::FUN_WPD::CLEAR     // No pull-down
    );
    
    self.configuration()
}
```

---

## Testing Results

### Quality Gates
- ✅ `cargo build` - PASS
- ✅ `cargo test` - PASS (15 tests)
- ✅ `cargo clippy --all-targets -- -D warnings` - PASS
- ✅ `cargo fmt --check` - PASS

### Hardware Test
- ❌ GPIO input still reads LOW when output is HIGH
- ❌ No change in behavior after all fixes

---

## Struggle Points

**Issue:** GPIO input not working despite multiple fix attempts  
**Cycles:** 30+  
**Attempts:**
1. Fixed MCU_SEL value (0 → 1)
2. Added GPIO matrix output configuration
3. Disabled output for input pins
4. Set FUN_IE bit
5. Set MCU_IE bit
6. Set both FUN_IE and MCU_IE
7. Used `write()` instead of `modify()` to ensure clean register state

**None of these fixed the issue!**

---

## Hypotheses for Remaining Issue

### 1. Clock/Power Not Enabled
- ESP32-C6 has PCR (Power/Clock/Reset) module
- GPIO or IO_MUX clock might need explicit enable
- **Action:** Check if GPIO clock gate needs configuration

### 2. GPIO Matrix Input Routing
- We configured GPIO matrix OUTPUT (GPIO_FUNCn_OUT_SEL_CFG)
- Maybe also need GPIO matrix INPUT (GPIO_FUNCn_IN_SEL_CFG)?
- **Evidence:** ESP-IDF has `gpio_ll_iomux_in()` that sets `func_in_sel_cfg`

### 3. Register Write Not Taking Effect
- Maybe volatile writes aren't working?
- **Action:** Add register read-back verification

### 4. Pin Multiplexing Conflict
- Maybe GPIO18/19 have special function that's interfering?
- **Action:** Check ESP32-C6 TRM for pin restrictions

### 5. Missing Initialization Step
- Maybe there's a global GPIO initialization we're missing?
- **Action:** Check ESP-IDF `gpio_install_isr_service()` and related init functions

---

## Request for Supervisor

**BLOCKED:** Need assistance to debug why GPIO input doesn't work despite:
- Correct MCU_SEL value (1 for GPIO)
- Input enable bits set (FUN_IE and MCU_IE)
- Output disabled
- GPIO matrix configured
- Hardware verified with ohmmeter

**Recommendation:** 
1. Review ESP32-C6 TRM Chapter 7 (GPIO & IO_MUX) for missing initialization
2. Check if PCR module needs GPIO clock enable
3. Investigate GPIO matrix input routing requirements
4. Consider using logic analyzer to verify pin state vs register state

**Next Steps if Unblocked:**
- Once GPIO input works, interrupt test should also work
- Can proceed with full GPIO interrupt HIL test suite

---

## Files Modified

- `tock/chips/esp32-c6/src/gpio.rs` - GPIO driver fixes
- `tock/boards/nano-esp32-c6/src/gpio_interrupt_tests.rs` - Diagnostic test (attempted register dumps, removed due to ROM space)

---

## Handoff Notes for Supervisor

**Critical:** GPIO input fundamentally broken. All ESP-IDF-based fixes attempted without success. Need expert review of:
1. ESP32-C6 GPIO initialization sequence
2. IO_MUX vs GPIO matrix interaction
3. Possible missing PCR/clock configuration

**Hardware:** User has confirmed jumper wire GPIO18→GPIO19 with ohmmeter. Physical connection is good.

**Test Command:**
```bash
cd tock/boards/nano-esp32-c6
cargo build --release --features gpio_diag_test
espflash flash --port /dev/tty.usbmodem112201 target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
# Reset board and observe: GPIO19 should read HIGH when GPIO18 is HIGH
```

---

## TDD Metrics

- Cycles: 30+ (CRITICAL - exceeded budget)
- Tests written: 0 (can't write tests for hardware issue)
- Tests passing: 15 (existing unit tests still pass)
- Red-Green-Refactor compliance: N/A (hardware debugging, not TDD)

**Escalation:** This task has exceeded 25 cycles without resolution. Requesting supervisor intervention per TDD skill guidelines.
