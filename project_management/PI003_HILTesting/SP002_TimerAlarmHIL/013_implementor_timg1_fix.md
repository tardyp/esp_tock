# PI003/SP002 - Implementation Report: TIMG1 Fix for Timer Alarm Tests

**Report:** 013_implementor_timg1_fix.md  
**Sprint:** PI003/SP002 (Timer Alarm HIL Tests)  
**Date:** 2026-02-14

---

## TDD Summary

| Metric | Value |
|--------|-------|
| Tests written | 0 (fix only, existing tests) |
| Tests passing | 48 (23 esp32 + 25 esp32-c6) |
| Cycles | 2 / target <15 |

---

## Problem Description

From @integrator report 012:

**Conflict:**
1. `setup()` creates AlarmMux using `timg0` and sets itself as alarm client
2. Timer alarm test also uses `timg0` and sets itself as alarm client
3. This overwrites AlarmMux's client, breaking kernel alarm infrastructure
4. Timer alarm callbacks never fire

**Root cause:**
- ESP32-C6 has two timer groups: TIMG0 and TIMG1
- AlarmMux uses TIMG0 for kernel scheduling
- Timer alarm test was also using TIMG0, causing conflict

---

## Solution

Changed timer alarm test to use TIMG1 instead of TIMG0.

### Changes Made

**File:** `tock/boards/nano-esp32-c6/src/main.rs`

1. **Added documentation** explaining TIMG0/TIMG1 separation:
   ```rust
   // IMPORTANT: Uses TIMG1 to avoid conflict with AlarmMux which uses TIMG0.
   // - TIMG0: Reserved for kernel AlarmMux (scheduler, userspace alarms)
   // - TIMG1: Available for hardware tests
   ```

2. **Start TIMG1 counter** (TIMG0 is already started for AlarmMux):
   ```rust
   use kernel::hil::time::Counter;
   let _ = peripherals.timg1.start();
   ```

3. **Changed debug timer reads** from `timg0` to `timg1`:
   ```rust
   let t1 = peripherals.timg1.now();  // Was: timg0
   let t2 = peripherals.timg1.now();  // Was: timg0
   ```

4. **Changed test initialization** to use TIMG1:
   ```rust
   timer_alarm_tests::TimerAlarmAccuracyTest::new(
       &peripherals.timg1,  // Was: &peripherals.timg0
       ...
   )
   ```

5. **Changed alarm client registration** to TIMG1:
   ```rust
   peripherals.timg1.set_alarm_client(edge_case_test);  // Was: timg0
   ```

---

## Verification

### TIMG1 Infrastructure Already in Place

| Component | Status | Location |
|-----------|--------|----------|
| TIMG1 peripheral | READY | `chip.rs:44` - `timg1: timg::TimG::new(...)` |
| TIMG1 clock enabled | READY | `main.rs:161-162` - `pcr.enable_timergroup1_clock()` |
| TIMG1 interrupt constant | READY | `interrupts.rs:61` - `IRQ_TIMER_GROUP1: u32 = 6` |
| TIMG1 interrupt handler | READY | `chip.rs:60` - `interrupts::IRQ_TIMER_GROUP1 => self.timg1.handle_interrupt()` |
| TIMG1 INTMTX mapping | READY | `intc.rs` - Maps peripheral source 34 to CPU line 6 |

### Build Results

```
cargo build --release --features timer_alarm_tests
   Compiling nano-esp32-c6-board v0.2.3-dev
    Finished `release` profile [optimized + debuginfo] target(s) in 1.58s
```

### Quality Status

| Check | Status |
|-------|--------|
| cargo build | PASS |
| cargo clippy | PASS (0 warnings) |
| cargo fmt --check | PASS |
| esp32 tests | PASS (23 tests) |
| esp32-c6 tests | PASS (25 tests) |

---

## Files Modified

| File | Changes |
|------|---------|
| `tock/boards/nano-esp32-c6/src/main.rs` | Changed timer alarm tests from TIMG0 to TIMG1 |

---

## Code Diff Summary

```diff
-        let t1 = peripherals.timg0.now();
+        let t1 = peripherals.timg1.now();

-        let t2 = peripherals.timg0.now();
+        let t2 = peripherals.timg1.now();

-                &peripherals.timg0,
+                &peripherals.timg1,  // Use TIMG1, not TIMG0

-        peripherals.timg0.set_alarm_client(edge_case_test);
+        peripherals.timg1.set_alarm_client(edge_case_test);
```

---

## Expected Hardware Behavior

After this fix, when running on hardware:

1. **Boot sequence:**
   - TIMG0 started for AlarmMux (kernel scheduling)
   - TIMG1 started for timer alarm tests

2. **Test execution:**
   - `[TEST] Using TIMG1 (TIMG0 reserved for AlarmMux)` printed
   - `[TEST] TIMG1 started` printed
   - TIMG1 counter verified counting
   - Edge case test sets alarms on TIMG1
   - TIMG1 interrupts fire (CPU line 6)
   - `handle_interrupt()` called on `timg1`
   - `AlarmClient::alarm()` callback invoked on test
   - Test results printed

3. **No conflict:**
   - AlarmMux remains connected to TIMG0
   - Timer alarm test uses TIMG1
   - Both can operate independently

---

## Ready for Hardware Testing

**Status:** READY

**Build command:**
```bash
cd tock/boards/nano-esp32-c6
cargo build --release --features timer_alarm_tests
```

**Flash command:**
```bash
espflash flash --monitor target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**Expected output:**
```
=== Tock Kernel Starting ===
...
[TEST] Using TIMG1 (TIMG0 reserved for AlarmMux)
[TEST] TIMG1 started
[DEBUG] TIMG1 now() = <value>
[DEBUG] TIMG1 now() after delay = <larger value>
[DEBUG] TIMG1 is counting: YES

=== Timer Alarm Accuracy Test E Starting ===
[TEST] Tolerance: +/-10%
[TEST] Test count: 20

[TEST 1/20] Setting 100ms alarm
[TEST] Timer alarm test started - results will appear as alarms fire
Entering kernel main loop...

  -> Fired: actual=100ms expected=100ms error=0ms PASS
[TEST 2/20] Setting 200ms alarm
  -> Fired: actual=200ms expected=200ms error=0ms PASS
...
[TEST 20/20] Setting 1ms alarm
  -> Fired: actual=1ms expected=1ms error=0ms PASS

=== Timer Alarm Test E Summary ===
[RESULT] Total alarms: 20
[RESULT] Passed: 20
[RESULT] Failed: 0
...
[TEST] Timer Alarm Test E PASSED
```

---

## Handoff Notes

### For @integrator

1. **Build and flash** with `--features timer_alarm_tests`
2. **Verify** TIMG1 is counting (debug output)
3. **Verify** alarm callbacks fire (20 tests should execute)
4. **Verify** timing accuracy within ±10%
5. **Verify** no USB-UART reset (WFI fix still working)

### For @reviewer

1. **Architecture decision:** TIMG0 for kernel, TIMG1 for tests
2. **No breaking changes:** AlarmMux still uses TIMG0
3. **Clean separation:** Tests don't interfere with kernel infrastructure

---

## TDD Cycle Details

### Cycle 1: Analysis
- Read integrator report 012
- Identified root cause: AlarmMux conflict
- Verified TIMG1 infrastructure exists

### Cycle 2: Implementation
- Modified main.rs to use TIMG1
- Added documentation comments
- Built and verified with clippy/fmt

**Total cycles: 2** (well under target of 15)

---

## Summary

| Item | Status |
|------|--------|
| Root cause identified | AlarmMux conflict on TIMG0 |
| Solution implemented | Use TIMG1 for tests |
| Build passing | YES |
| Clippy clean | YES |
| Fmt clean | YES |
| Host tests passing | YES (48 tests) |
| Ready for hardware | YES |
