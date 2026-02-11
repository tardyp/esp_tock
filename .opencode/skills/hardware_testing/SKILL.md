---
name: hardware_testing
description: Hardware test automation patterns for ESP32-C6, similar to Tock's existing test infrastructure
license: MIT
compatibility: opencode
metadata:
  category: testing
  for_agent: integrator
  focus: validation, automation
---

# Hardware Testing for Tock ESP32-C6

## Test Infrastructure Overview

Tock uses board-level tests that run on actual hardware and verify behavior via serial output and GPIO states.

## Test Organization

```
boards/esp32c6_devkit/
  src/
    main.rs
    tests/
      mod.rs
      gpio_test.rs
      uart_test.rs
      timer_test.rs
```

## Test Pattern

```rust
// In tests/gpio_test.rs
use kernel::debug;

pub fn run_gpio_tests(gpio: &'static GpioDriver) {
    debug!("[TEST] GPIO: Starting tests");
    
    test_output_high_low(gpio);
    test_input_read(gpio);
    test_interrupt_trigger(gpio);
    
    debug!("[TEST] GPIO: All tests passed");
}

fn test_output_high_low(gpio: &'static GpioDriver) {
    debug!("[TEST] gpio_output_high_low: start");
    
    let pin = gpio.get_pin(5).unwrap();
    pin.make_output();
    
    pin.set();
    // Verify with multimeter or logic analyzer
    debug!("[TEST] gpio_output_high_low: set high - verify externally");
    
    pin.clear();
    debug!("[TEST] gpio_output_high_low: set low - verify externally");
    
    debug!("[TEST] gpio_output_high_low: PASS");
}
```

## Serial Output Protocol

Use consistent prefixes for parsing:

```rust
debug!("[TEST] {name}: start");      // Test starting
debug!("[TEST] {name}: {step}");     // Test progress
debug!("[TEST] {name}: PASS");       // Test passed
debug!("[TEST] {name}: FAIL - {reason}");  // Test failed
debug!("[INFO] {message}");          // Informational
debug!("[ERROR] {message}");         // Error condition
```

## Automated Test Runner

```bash
#!/bin/bash
# run_tests.sh

PORT=/dev/ttyUSB0
TIMEOUT=30

# Flash the test firmware
cargo espflash flash --chip esp32c6 --port $PORT

# Capture serial output
timeout $TIMEOUT cat $PORT > test_output.log &
PID=$!

# Wait for tests to complete
sleep $TIMEOUT
kill $PID 2>/dev/null

# Check results
if grep -q "All tests passed" test_output.log; then
    echo "TESTS PASSED"
    exit 0
else
    echo "TESTS FAILED"
    grep "FAIL" test_output.log
    exit 1
fi
```

## GPIO Loopback Testing

Connect two GPIO pins together for automated input/output testing:

```rust
fn test_gpio_loopback(gpio: &'static GpioDriver) {
    // Connect GPIO5 (output) to GPIO6 (input) externally
    let out_pin = gpio.get_pin(5).unwrap();
    let in_pin = gpio.get_pin(6).unwrap();
    
    out_pin.make_output();
    in_pin.make_input();
    
    out_pin.set();
    // Small delay for signal to settle
    for _ in 0..1000 { core::hint::spin_loop(); }
    
    if in_pin.read() {
        debug!("[TEST] gpio_loopback_high: PASS");
    } else {
        debug!("[TEST] gpio_loopback_high: FAIL - expected high");
    }
    
    out_pin.clear();
    for _ in 0..1000 { core::hint::spin_loop(); }
    
    if !in_pin.read() {
        debug!("[TEST] gpio_loopback_low: PASS");
    } else {
        debug!("[TEST] gpio_loopback_low: FAIL - expected low");
    }
}
```

## Timer Testing

```rust
fn test_timer_delay(timer: &'static TimerDriver) {
    debug!("[TEST] timer_delay: start");
    
    let start = timer.now();
    timer.delay_ms(100);
    let elapsed = timer.now() - start;
    
    // Allow 10% tolerance
    if elapsed >= 90_000 && elapsed <= 110_000 {  // microseconds
        debug!("[TEST] timer_delay: PASS ({} us)", elapsed);
    } else {
        debug!("[TEST] timer_delay: FAIL - elapsed {} us", elapsed);
    }
}
```

## Debug Print Strategy

Add debug prints strategically, then remove before handoff:

```rust
// Temporary debug - REMOVE BEFORE HANDOFF
debug!("[DEBUG] register value: 0x{:08x}", reg.read());
debug!("[DEBUG] entering state: {:?}", self.state);
```

## Capturing Logs

```bash
# Using screen with logging
screen -L -Logfile test.log /dev/ttyUSB0 115200

# Using picocom with logging
picocom -b 115200 --logfile test.log /dev/ttyUSB0

# Using minicom with capture
minicom -D /dev/ttyUSB0 -b 115200 -C test.log
```

## Test Report Format

```markdown
## Hardware Test Results

### Environment
- Board: ESP32-C6 DevKit
- Firmware: commit abc123
- Date: YYYY-MM-DD

### Test Results
| Test | Status | Notes |
|------|--------|-------|
| gpio_output | PASS | |
| gpio_input | PASS | |
| gpio_loopback | PASS | Pins 5-6 connected |
| uart_tx | PASS | |
| timer_delay | FAIL | Off by 15% |

### Failures
#### timer_delay
- Expected: 100ms +/- 10%
- Actual: 115ms
- Possible cause: Clock configuration
- Issue: #3 created
```

## Cleanup Checklist

Before handoff:
- [ ] All `[DEBUG]` prints removed
- [ ] Test results documented
- [ ] Failures escalated with issue numbers
- [ ] git status shows no debug modifications
