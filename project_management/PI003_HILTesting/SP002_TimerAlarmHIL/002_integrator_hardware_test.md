# PI003/SP002 - Integration Report: Timer Alarm Hardware Testing

## Session 1 - 2026-02-14

**Task:** Hardware validation of Timer Alarm HIL Tests
**Status:** BLOCKED - Timer interrupts not firing

---

## Hardware Tests

| Test | Status | Notes |
|------|--------|-------|
| Boot to kernel | PASS | Serial output verified |
| Timer counter running | PASS | After fix, timer counts correctly |
| Timer alarm set | PASS | Alarm is configured |
| Timer interrupt fires | **FAIL** | No interrupts delivered to CPU |
| Alarm callback executed | **FAIL** | Blocked by interrupt issue |

---

## Debug Findings

### Issue 1: Timer Clock Source Mismatch (FIXED)

**Symptom:** Timer not counting (now() returns 0)

**Root Cause:** Timer was created with `ClockSource::Pll` but PCR configured XTAL clock.

**Fix Applied:**
```rust
// In chips/esp32-c6/src/chip.rs
timg0: timg::TimG::new(TIMG0_BASE_REF, timg::ClockSource::Xtal),
```

### Issue 2: Timer Not Started (FIXED)

**Symptom:** Timer counter not incrementing

**Root Cause:** Timer `start()` function only set EN bit, not INCREASE bit.

**Fix Applied:**
```rust
// In chips/esp32/src/timg.rs
fn start(&self) -> Result<(), ErrorCode> {
    self.registers.t0config.write(
        CONFIG::EN::SET
            + CONFIG::INCREASE::SET
            + CONFIG::USE_XTAL.val(self.clocksource as u32)
            + CONFIG::DIVIDER.val(2 * (2 - self.clocksource as u32)),
    );
    Ok(())
}
```

Also added timer start in main.rs:
```rust
use kernel::hil::time::Counter;
let _ = peripherals.timg0.start();
```

### Issue 3: Interrupt Mapping Incorrect (FIXED)

**Symptom:** Peripheral sources > 31 mapped to invalid CPU interrupt lines

**Root Cause:** Peripheral source numbers (33, 34) were used as CPU interrupt line numbers, but CPU only has 32 interrupt lines (0-31).

**Fix Applied:**
```rust
// In chips/esp32-c6/src/interrupts.rs
// Separate PERIPHERAL_* constants from IRQ_* constants
pub const PERIPHERAL_TIMER_GROUP0: u32 = 33;  // Peripheral source
pub const IRQ_TIMER_GROUP0: u32 = 5;          // CPU interrupt line
```

### Issue 4: Edge-Triggered Interrupts Not Configured (FIXED)

**Symptom:** Timer uses edge-triggered interrupts but INTPRI not configured

**Root Cause:** INTPRI `cpu_int_type` register not set for edge-triggered mode.

**Fix Applied:**
```rust
// In chips/esp32-c6/src/intpri.rs
pub unsafe fn set_all_edge_triggered(&self) {
    self.registers.cpu_int_type.set(0xFFFF_FFFF);
}
```

### Issue 5: Timer Interrupts Not Delivered (BLOCKING)

**Symptom:** IRQ count = 0, no interrupts reaching trap handler

**Evidence:**
- Timer is counting correctly (verified with now())
- Alarm is set correctly (set_alarm() called)
- Timer interrupt enabled in timer hardware (int_c3_ena)
- CPU interrupt line enabled in INTPRI
- Machine external interrupts enabled (mie.MEIE)
- Global interrupts enabled (mstatus.MIE)

**Possible Causes:**
1. ESP32-C6 uses CLIC (Core Local Interrupt Controller) instead of standard PLIC
2. Interrupt matrix mapping not working correctly
3. Timer interrupt not generating hardware signal
4. CLIC-specific configuration missing

**Investigation Needed:**
- Check ESP32-C6 TRM Chapter 10 for CLIC configuration
- Verify INTMTX register writes are taking effect
- Add debug output to read back INTMTX/INTPRI registers
- Compare with ESP-IDF timer interrupt implementation

---

## Fixes Applied (Light)

| Fix | File | Description |
|-----|------|-------------|
| Clock source | chips/esp32-c6/src/chip.rs | Use Xtal instead of Pll |
| Timer start | chips/esp32/src/timg.rs | Configure INCREASE bit in start() |
| Timer init | boards/nano-esp32-c6/src/main.rs | Call start() during init |
| IRQ mapping | chips/esp32-c6/src/interrupts.rs | Separate peripheral/CPU IRQ numbers |
| Edge trigger | chips/esp32-c6/src/intpri.rs | Add set_all_edge_triggered() |
| Edge config | chips/esp32-c6/src/intc.rs | Call set_all_edge_triggered() |
| mstatus.MIE | chips/esp32-c6/src/chip.rs | Enable global interrupts |

---

## Escalated to @implementor

### Issue: Timer Interrupts Not Delivered to CPU

**Description:** Timer alarm interrupts are not being delivered to the CPU trap handler. The timer is counting correctly and alarms are being set, but no interrupts are received.

**Evidence:**
```
[DEBUG] Timer now() = 4945
[DEBUG] Timer now() after delay = 2007393
[DEBUG] Timer is counting: YES
=== Timer Alarm Accuracy Test E Starting ===
[TEST 1/20] Setting 100ms alarm
Entering kernel main loop...
[No output for 5 seconds, IRQ count: 0]
```

**Root Cause Analysis:**
The ESP32-C6 uses a CLIC (Core Local Interrupt Controller) which may require different configuration than the standard PLIC. The current interrupt controller implementation may not be correctly interfacing with the CLIC.

**Why Not Light Fix:**
- Requires understanding of ESP32-C6 CLIC architecture
- May need significant changes to interrupt controller
- Needs reference to ESP-IDF implementation
- Multiple files affected

**Suggested Approach:**
1. Study ESP32-C6 TRM Chapter 10 (Interrupt Matrix)
2. Compare with ESP-IDF interrupt handling code
3. Verify CLIC configuration registers
4. May need to implement CLIC-specific driver

---

## USB-UART Stability Issue

**Symptom:** Serial connection drops after entering kernel main loop

**Workaround Applied:** Changed sleep() from WFI to busy-wait loop
```rust
fn sleep(&self) {
    for _ in 0..1000 {
        core::hint::spin_loop();
    }
}
```

**Note:** This is a workaround, not a fix. The USB-UART peripheral may need specific handling to stay connected during low-power states.

---

## Debug Code Status

- [x] All debug prints removed from chip code
- [ ] Debug prints in main.rs (timer counting check) - can be removed after interrupt fix

---

## Test Automation Added

None - blocked by interrupt issue

---

## Handoff Notes

### For @implementor:

1. **Timer counting works** - The timer is now counting correctly after the clock source and start() fixes.

2. **Interrupt delivery broken** - The critical issue is that timer interrupts are not being delivered to the CPU. This needs investigation of the ESP32-C6 CLIC architecture.

3. **Files modified:**
   - `chips/esp32-c6/src/chip.rs` - Clock source, mstatus.MIE
   - `chips/esp32-c6/src/interrupts.rs` - Separate peripheral/CPU IRQ numbers
   - `chips/esp32-c6/src/intc.rs` - Edge-triggered config
   - `chips/esp32-c6/src/intpri.rs` - Edge-triggered function
   - `chips/esp32/src/timg.rs` - Timer start() fix
   - `boards/nano-esp32-c6/src/main.rs` - Timer init, debug output

4. **Reference:** ESP32-C6 TRM Chapter 10 describes the interrupt architecture

---

## Recommendation

**FAIL** - Tests cannot complete due to timer interrupts not firing.

**Action Required:** Return to @implementor for interrupt controller investigation.

---

## Sprint Status

**SP002 Hardware Validation: BLOCKED**

### Completed:
- [x] Timer counting verified
- [x] Clock source fixed
- [x] Timer start fixed
- [x] Interrupt mapping fixed
- [x] Edge-triggered config added

### Blocked:
- [ ] Timer interrupts not delivered to CPU
- [ ] Alarm callbacks not executing
- [ ] Timing accuracy cannot be measured
- [ ] Statistics cannot be collected

---

## References

- Implementation Report: `001_implementor_timer_tests.md`
- ESP32-C6 TRM: Chapter 10 (Interrupt Matrix)
- ESP-IDF: `components/esp_hw_support/intr_alloc.c`
- Tock Timer: `chips/esp32/src/timg.rs`
