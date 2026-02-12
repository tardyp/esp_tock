# SP003 Timer Integration - Quick Start Guide

## Current Status
✅ Test infrastructure created  
✅ Timer driver working in production  
🔄 Hardware validation pending  

## Complete Integration in 3 Steps

### Step 1: Add Test Module to Board (2 minutes)

Edit `tock/boards/nano-esp32-c6/src/main.rs`:

```rust
// Add after line 21 (after "pub mod io;")
mod timer_tests;
```

Then add test call in `setup()` function after line 137 (`peripherals.init();`):

```rust
unsafe fn setup() -> (...) {
    // ... existing code ...
    
    let peripherals = static_init!(Esp32C6DefaultPeripherals, Esp32C6DefaultPeripherals::new());
    peripherals.init();
    
    // ADD THIS LINE:
    timer_tests::run_timer_tests(&peripherals.timg1);
    
    // CRITICAL: Disable watchdogs early to prevent unexpected resets
    esp32_c6::usb_serial_jtag::write_bytes(b"Disabling watchdogs...\r\n");
    // ... rest of existing code ...
}
```

### Step 2: Build and Flash (2 minutes)

```bash
cd tock/boards/nano-esp32-c6
cargo build --release

espflash flash --chip esp32c6 --port /dev/tty.usbmodem112201 \
    ../../target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

### Step 3: Run Automated Test (30 seconds)

```bash
cd /Users/az02096/dev/perso/esp/esp_tock

./scripts/test_sp003_timers.sh \
    tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board \
    30
```

## Expected Output

You should see:

```
========================================
TIMER HARDWARE TESTS - SP003
========================================

[TEST] test_counter_increments: start
[TEST] Counter start: 12345678
[TEST] Counter end: 12456789
[TEST] Elapsed ticks: 111111
[TEST] test_counter_increments: PASS - counter incremented

[TEST] test_counter_frequency: start
[TEST] Elapsed ticks in ~100ms: 1000000
[TEST] Expected: ~1,000,000 to 2,000,000 ticks
[TEST] test_counter_frequency: PASS - frequency in expected range

[TEST] test_alarm_basic: start
[TEST] Setting alarm for 1 second from now
[TEST] Current ticks: 12456789
[TEST] Alarm is armed
[TEST] Alarm set for ticks: 32456789
[TEST] test_alarm_basic: PASS - alarm armed successfully
[TEST] Waiting for alarm to fire (check for interrupt callback)...

========================================
TIMER TESTS COMPLETE
========================================
```

## Test Results Location

Results will be saved to:
```
project_management/PI002_CorePeripherals/SP003_Timers/hardware_test_YYYYMMDD_HHMMSS/
├── flash.log
├── serial_raw.log
└── serial_output.log
```

## Success Criteria

- ✅ Counter increments over time
- ✅ Frequency in expected range (1-2 MHz for XTAL 40MHz)
- ✅ Alarm arms successfully
- ✅ No panics or crashes
- ✅ System remains stable

## If Tests Fail

### Counter Not Incrementing
→ Check if timer is started: `timer.start()`  
→ Verify PCR clock is enabled  
→ **Escalate to @implementor**

### Frequency Way Off (>50% error)
→ Check clock source configuration (XTAL vs PLL)  
→ Verify divider calculation  
→ **Escalate to @implementor**

### Alarm Not Arming
→ Check interrupt controller initialization  
→ Verify alarm client is set  
→ **Escalate to @implementor**

### System Crashes
→ Check for stack overflow  
→ Verify memory allocation  
→ **Escalate to @implementor immediately**

## After Testing

Update `003_integrator_hardware.md`:

1. Mark success criteria as complete
2. Add actual timing measurements
3. Document any issues found
4. Update status to COMPLETE

## Cleanup Before Handoff

If you want to remove test code after validation:

1. Remove `mod timer_tests;` from main.rs
2. Remove `timer_tests::run_timer_tests()` call
3. Delete `tock/boards/nano-esp32-c6/src/timer_tests.rs`
4. Rebuild and reflash

**Note:** Test code is clean and can be left in for future validation.

## Questions?

Refer to:
- `003_integrator_hardware.md` - Full integration report
- `tock/chips/esp32-c6/src/timg_README.md` - Timer usage guide
- `002_implementor_tdd.md` - Implementation details
