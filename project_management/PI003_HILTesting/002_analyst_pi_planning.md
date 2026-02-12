# PI003_HILTesting - PI Planning Document

**Analyst:** @analyst  
**Date:** 2026-02-12  
**PI:** PI003_HILTesting  
**Status:** PLANNING (Awaiting PO Approval)  

---

## Table of Contents

1. [PI Overview](#1-pi-overview)
2. [Sprint Structure](#2-sprint-structure)
3. [Sprint Details](#3-sprint-details)
4. [Hardware Setup](#4-hardware-setup)
5. [Success Criteria](#5-success-criteria)
6. [Risk Management](#6-risk-management)
7. [Deliverables](#7-deliverables)
8. [Dependencies](#8-dependencies)

---

## 1. PI Overview

### 1.1 PI Goal

**Comprehensive Hardware Independent Layer (HIL) validation for ESP32-C6 core peripherals**

**Transition:** Move from basic shell script tests to production-quality HIL validation

**Scope:**
- GPIO interrupt validation through hardware loopback
- Timer alarm accuracy and edge case testing
- Enhanced test infrastructure and documentation

### 1.2 Background

**Current State (Post-PI002):**
- ✅ Core peripherals implemented (Watchdog, Clock, INTC, Timer, GPIO, Console)
- ✅ Basic hardware tests exist (gpio_tests.rs, timer_tests.rs)
- ✅ Shell script validation (test_gpio.sh)
- ⚠️  Limited interrupt testing (setup only, no validation)
- ⚠️  Limited timer testing (no accuracy measurements)

**Problem:**
- Current tests don't validate interrupts work correctly
- Timer tests don't measure timing accuracy
- No edge case coverage
- Shell scripts are basic (grep for PASS/FAIL only)

**Solution:**
- Hardware loopback tests for GPIO interrupts
- Timing accuracy validation for alarms
- Integration of proven Tock test capsules
- Enhanced test infrastructure

### 1.3 Strategic Alignment

**Tock OS Standards:**
- ✅ Use HIL traits (not direct register access)
- ✅ Follow existing Tock test patterns
- ✅ Portable test approach (could be adapted to other boards)
- ✅ Production-quality validation

**Project Goals:**
- ✅ Validate PI002 peripheral implementations
- ✅ Build confidence in ESP32-C6 port
- ✅ Create foundation for application development
- ✅ Document best practices for future boards

### 1.4 Out of Scope (Deferred to Future PIs)

**Not in PI003:**
- ❌ Userspace test applications (libtock-c) → PI004
- ❌ Python test harness (tock-hardware-ci) → PI004
- ❌ CI/CD integration → PI005
- ❌ SPI/I2C HIL testing → Future
- ❌ ADC HIL testing → Future
- ❌ Wireless (WiFi/BLE) testing → Much later

---

## 2. Sprint Structure

### 2.1 Recommended Structure: 3 Sprints

**Rationale:**
- Two peripherals to test (GPIO, Timer)
- One sprint for infrastructure
- Focused, deep testing per sprint
- Less overhead than 5-sprint structure

### 2.2 Sprint Overview

| Sprint | Name | Focus | Complexity | Est. Effort |
|--------|------|-------|------------|-------------|
| **SP001** | GPIO Interrupt HIL Tests | Hardware loopback interrupt validation | Medium | 3-4 iterations |
| **SP002** | Timer Alarm HIL Tests | Timing accuracy and edge cases | Medium | 3-4 iterations |
| **SP003** | Test Infrastructure | Documentation and automation | Low | 2-3 iterations |

**Total Estimated Effort:** 8-11 iterations (vs 15-20 for 5-sprint structure)

### 2.3 Alternative 5-Sprint Structure

*(If PO prefers more granular sprints)*

| Sprint | Name | Focus |
|--------|------|-------|
| SP001 | GPIO Loopback Enhancement | Basic + edge interrupts |
| SP002 | GPIO Level Interrupts | High/low level interrupts |
| SP003 | Timer Edge Cases | 0ms, 1ms, wraparound |
| SP004 | Multi-Alarm Testing | MuxAlarm validation |
| SP005 | Test Infrastructure | Documentation |

**Analyst Recommendation:** **3-sprint structure preferred**

---

## 3. Sprint Details

---

## SP001: GPIO Interrupt HIL Tests (Loopback-Based)

### Sprint Goal

**Validate all 5 GPIO interrupt modes work correctly through hardware loopback**

### Background

**Current State:**
- ✅ GPIO driver implemented (SP004 of PI002)
- ✅ Basic loopback test exists (GPIO5→GPIO6, static levels)
- ✅ Interrupt setup tested (enable, configure)
- ❌ No interrupt callback validation
- ❌ No edge detection testing
- ❌ No level interrupt testing

**Problem:**
Current tests only verify interrupts can be configured, not that they actually fire.

**Solution:**
Use hardware loopback to trigger interrupts programmatically and validate callbacks fire.

### Scope

#### In Scope
1. **Loopback Infrastructure**
   - Enhance existing GPIO5→GPIO6 loopback
   - Add second loopback pair (GPIO18→GPIO19) for interrupt testing
   - Document physical connections

2. **Interrupt Mode Testing** (All 5 modes)
   - ✅ Rising edge interrupts
   - ✅ Falling edge interrupts
   - ✅ Both edges interrupts
   - ✅ High level interrupts
   - ✅ Low level interrupts

3. **Interrupt Validation**
   - Verify callbacks fire when expected
   - Count interrupt occurrences
   - Validate no spurious interrupts
   - Test enable/disable functionality

4. **Multi-Interrupt Testing**
   - Multiple pins with interrupts simultaneously
   - Different interrupt modes at same time
   - Stress test (rapid interrupts)

#### Out of Scope
- Interrupt latency measurements (nice-to-have)
- Interrupt priority testing (INTC already tested in PI002)
- Wakeup from sleep via interrupts (future)

### Technical Approach

#### Test Pattern

**Loopback Setup:**
```
GPIO18 (Output) ──wire──> GPIO19 (Input with interrupt)
```

**Test Sequence:**
```rust
// 1. Configure pins
gpio18.make_output();
gpio19.make_input();
gpio19.set_client(&interrupt_client);

// 2. Test rising edge
gpio19.enable_interrupts(InterruptEdge::RisingEdge);
gpio18.clear();  // Start LOW
delay();
gpio18.set();    // Trigger: LOW→HIGH
delay();
// Expect: interrupt_client.fired() called once

// 3. Test falling edge
gpio19.enable_interrupts(InterruptEdge::FallingEdge);
gpio18.set();    // Start HIGH
delay();
gpio18.clear();  // Trigger: HIGH→LOW
delay();
// Expect: interrupt_client.fired() called once

// ... similar for other modes
```

**Interrupt Client:**
```rust
pub struct InterruptTestClient {
    count: Cell<usize>,
    expected_mode: Cell<InterruptMode>,
}

impl Client for InterruptTestClient {
    fn fired(&self) {
        let c = self.count.get() + 1;
        self.count.set(c);
        debug!("[TEST] Interrupt fired (count: {})", c);
    }
}
```

#### Hardware Setup

**Required Connections:**
```
Jumper Wire 1: GPIO5  (J1 pin 2)  → GPIO6  (J1 pin 3)   [Existing]
Jumper Wire 2: GPIO18 (J6 pin 8)  → GPIO19 (J6 pin 9)   [New]
```

**Safety:**
- ✅ Both pins are 3.3V (safe to connect)
- ✅ No external voltage sources
- ✅ Current draw: negligible (input impedance ~10MΩ)

#### Files to Create/Modify

**New Files:**
- `tock/boards/nano-esp32-c6/src/gpio_interrupt_tests.rs` (~300 lines)

**Modified Files:**
- `tock/boards/nano-esp32-c6/src/main.rs` (add test call)
- `tock/boards/nano-esp32-c6/src/gpio_tests.rs` (enhance if needed)

**Test Scripts:**
- `tock/boards/nano-esp32-c6/test_gpio_interrupts.sh` (new)

### Test Cases

| Test ID | Test Name | Description | Expected Result |
|---------|-----------|-------------|-----------------|
| GI-001 | Rising Edge Interrupt | GPIO18 LOW→HIGH triggers interrupt on GPIO19 | Callback fires once |
| GI-002 | Falling Edge Interrupt | GPIO18 HIGH→LOW triggers interrupt on GPIO19 | Callback fires once |
| GI-003 | Both Edges Interrupt | GPIO18 toggle triggers interrupt twice | Callback fires twice |
| GI-004 | High Level Interrupt | GPIO18 held HIGH triggers interrupt on GPIO19 | Callback fires (level) |
| GI-005 | Low Level Interrupt | GPIO18 held LOW triggers interrupt on GPIO19 | Callback fires (level) |
| GI-006 | No Spurious Interrupts | No GPIO18 changes, no interrupts | Callback count = 0 |
| GI-007 | Interrupt Disable | Disable interrupt, trigger edge | Callback not fired |
| GI-008 | Interrupt Re-enable | Disable, re-enable, trigger | Callback fires |
| GI-009 | Multiple Pins | GPIO5→GPIO6 + GPIO18→GPIO19 simultaneous | Both callbacks fire |
| GI-010 | Rapid Interrupts | Toggle GPIO18 100 times rapidly | 100 callbacks (both edges) |

**Total Test Cases:** 10

### Success Criteria

**Must Pass:**
- ✅ All 5 interrupt modes trigger correctly
- ✅ Callbacks fire when expected
- ✅ No spurious interrupts (count matches expected)
- ✅ Disable/enable works correctly
- ✅ Multiple pins work simultaneously

**Quality Metrics:**
- ✅ 100% test pass rate
- ✅ Zero spurious interrupts
- ✅ Consistent results (run 3 times)

### Deliverables

1. **Code:**
   - gpio_interrupt_tests.rs (interrupt test module)
   - Updated main.rs (test integration)
   - Test script (test_gpio_interrupts.sh)

2. **Documentation:**
   - Hardware setup guide (with photos/diagrams)
   - Test procedure documentation
   - Expected results

3. **Test Report:**
   - Test execution results
   - Pass/fail summary
   - Any issues found

### Estimated Complexity

**Complexity:** Medium

**Rationale:**
- Building on existing GPIO implementation
- Similar pattern to existing loopback test
- Interrupt client is straightforward
- Hardware setup is simple

**Risk Areas:**
- Interrupt timing (debouncing may be needed)
- Level interrupts (may fire continuously)
- Rapid interrupt handling

**Estimated Iterations:** 3-4

---

## SP002: Timer Alarm HIL Tests (Accuracy & Edge Cases)

### Sprint Goal

**Validate timer alarms fire accurately and handle edge cases correctly**

### Background

**Current State:**
- ✅ Timer driver implemented (SP003 of PI002)
- ✅ Basic timer tests exist (counter, frequency, alarm arming)
- ✅ Timer working in production (scheduler uses it)
- ❌ No timing accuracy measurements
- ❌ No edge case testing (0ms, 1ms delays)
- ❌ No continuous alarm testing

**Problem:**
Current tests verify alarms can be set, but not that they fire at the correct time.

**Solution:**
Integrate proven Tock test capsules (TestRandomAlarm, TestAlarmEdgeCases) and add timing measurements.

### Scope

#### In Scope
1. **Test Capsule Integration**
   - Integrate TestRandomAlarm from capsules/core/src/test/
   - Integrate TestAlarmEdgeCases from capsules/core/src/test/
   - Adapt for ESP32-C6 timer

2. **Timing Accuracy Validation**
   - Measure actual vs expected alarm times
   - Calculate timing error percentage
   - Validate within tolerance (±10% default)
   - Report timing statistics

3. **Edge Case Testing**
   - 0ms delay (immediate alarm)
   - 1ms delay (very short)
   - Very short delays (<10ms)
   - Long delays (>1 second)
   - Wraparound scenarios

4. **Multi-Alarm Testing**
   - Multiple virtual alarms (MuxAlarm)
   - Concurrent alarms
   - Alarm cancellation
   - Alarm rescheduling

5. **Stress Testing**
   - Continuous alarms for 60 seconds
   - Rapid alarm rescheduling
   - Validate no missed alarms

#### Out of Scope
- Very long delays (>10 seconds) - nice-to-have
- Sleep/wake with timers - future
- Timer overflow testing (54-bit counter, won't overflow in test time)

### Technical Approach

#### Test Pattern 1: TestRandomAlarm Integration

**Source:** `tock/capsules/core/src/test/random_alarm.rs`

**Approach:**
```rust
// In board main.rs
let test_alarm = static_init!(
    TestRandomAlarm<'static, TimG<'static>>,
    TestRandomAlarm::new(&peripherals.timg0, 19, 'A', true)
);
peripherals.timg0.set_alarm_client(test_alarm);
test_alarm.run();

// TestRandomAlarm will:
// - Set random delays (0-512ms)
// - Validate timing accuracy (±50ms)
// - Run continuously
// - Report via debug!()
```

**Customization Needed:**
- Adjust tolerance to ±10% (from fixed 50ms)
- Add timing statistics (min, max, avg error)
- Add test duration limit (60 seconds)

#### Test Pattern 2: TestAlarmEdgeCases Integration

**Source:** `tock/capsules/core/src/test/alarm_edge_cases.rs`

**Approach:**
```rust
let test_edge = static_init!(
    TestAlarmEdgeCases<'static, TimG<'static>>,
    TestAlarmEdgeCases::new(&peripherals.timg0)
);
peripherals.timg0.set_alarm_client(test_edge);
test_edge.run();

// Tests delays: [100, 200, 25, 25, 25, 25, 500, 0, 448, 15, 19, 1, 0, 33, 5, 1000, 27, 1, 0, 1]
```

**Customization Needed:**
- Add timing measurements
- Report accuracy statistics
- Add pass/fail criteria

#### Test Pattern 3: Custom Timing Validation

**New Test Module:**
```rust
pub struct TimerAccuracyTest {
    timer: &'static TimG<'static>,
    test_delays: [u32; 10],  // ms
    current_test: Cell<usize>,
    start_time: Cell<Ticks64>,
    expected_time: Cell<Ticks64>,
}

impl AlarmClient for TimerAccuracyTest {
    fn alarm(&self) {
        let actual = self.timer.now();
        let expected = self.expected_time.get();
        let error = actual.wrapping_sub(expected);
        
        let error_pct = calculate_error_percentage(error, expected);
        
        if error_pct <= 10.0 {
            debug!("[TEST] Timing: PASS (error: {:.2}%)", error_pct);
        } else {
            debug!("[TEST] Timing: FAIL (error: {:.2}%)", error_pct);
        }
        
        // Set next alarm
        self.set_next_test_alarm();
    }
}
```

#### Hardware Setup

**No additional hardware required** - Timer is internal to ESP32-C6

**Optional:**
- Logic analyzer to verify timing accuracy externally
- GPIO toggle on alarm callback (for external measurement)

#### Files to Create/Modify

**New Files:**
- `tock/boards/nano-esp32-c6/src/timer_alarm_tests.rs` (~400 lines)

**Modified Files:**
- `tock/boards/nano-esp32-c6/src/main.rs` (add test calls)
- `tock/boards/nano-esp32-c6/src/timer_tests.rs` (enhance existing)

**Test Scripts:**
- `tock/boards/nano-esp32-c6/test_timer_alarms.sh` (new)

### Test Cases

| Test ID | Test Name | Description | Expected Result |
|---------|-----------|-------------|-----------------|
| TA-001 | 0ms Alarm | Set alarm with 0ms delay | Fires immediately (within 1ms) |
| TA-002 | 1ms Alarm | Set alarm with 1ms delay | Fires at ~1ms (±10%) |
| TA-003 | 10ms Alarm | Set alarm with 10ms delay | Fires at ~10ms (±10%) |
| TA-004 | 100ms Alarm | Set alarm with 100ms delay | Fires at ~100ms (±10%) |
| TA-005 | 1000ms Alarm | Set alarm with 1000ms delay | Fires at ~1000ms (±10%) |
| TA-006 | Random Delays | 100 random delays (0-512ms) | All within ±10% |
| TA-007 | Edge Case Array | TestAlarmEdgeCases delays | All fire correctly |
| TA-008 | Multi-Alarm | 3 concurrent virtual alarms | All fire correctly |
| TA-009 | Alarm Cancel | Set alarm, cancel before fire | Does not fire |
| TA-010 | Alarm Reschedule | Set alarm, reschedule | Fires at new time |
| TA-011 | Continuous Alarms | Alarms for 60 seconds | No missed alarms |
| TA-012 | Wraparound | Set alarm from past reference | Handles correctly |

**Total Test Cases:** 12

### Success Criteria

**Must Pass:**
- ✅ All alarms fire (no missed alarms)
- ✅ Timing accuracy within ±10% (configurable tolerance)
- ✅ Edge cases handled (0ms, 1ms)
- ✅ Multi-alarm works correctly
- ✅ Continuous operation stable (60 seconds)

**Quality Metrics:**
- ✅ 100% alarm fire rate
- ✅ ≥90% within ±10% timing tolerance
- ✅ ≥95% within ±20% timing tolerance
- ✅ Zero crashes or hangs

**Performance Metrics:**
- Average timing error: <5%
- Maximum timing error: <10%
- Standard deviation: <3%

### Deliverables

1. **Code:**
   - timer_alarm_tests.rs (alarm test module)
   - Updated main.rs (test integration)
   - Test script (test_timer_alarms.sh)

2. **Documentation:**
   - Test procedure documentation
   - Timing accuracy analysis
   - Expected results

3. **Test Report:**
   - Timing statistics (min, max, avg, stddev)
   - Pass/fail summary
   - Any issues found

### Estimated Complexity

**Complexity:** Medium

**Rationale:**
- Integrating existing test capsules (proven code)
- Adding timing measurements (straightforward)
- Timer already working in production

**Risk Areas:**
- Timing accuracy may vary (interrupt latency)
- Very short delays (<1ms) may be challenging
- Continuous testing stability

**Estimated Iterations:** 3-4

---

## SP003: Test Infrastructure & Documentation

### Sprint Goal

**Improve test automation and create comprehensive documentation for HIL testing**

### Background

**Current State:**
- ✅ Basic shell scripts exist (test_gpio.sh)
- ✅ Serial output parsing works (grep for PASS/FAIL)
- ❌ No timing validation in scripts
- ❌ No structured test reports
- ❌ Limited documentation

**Problem:**
- Test scripts are basic (just grep)
- No automated timing validation
- Documentation is minimal
- Hard for others to reproduce tests

**Solution:**
- Enhanced test scripts with timing validation
- Structured test output format
- Comprehensive documentation
- Test report templates

### Scope

#### In Scope
1. **Test Script Enhancement**
   - Better parsing (structured output)
   - Timing validation (extract and validate timing data)
   - Automated pass/fail determination
   - Test summary generation

2. **Test Output Format**
   - Structured markers ([TEST], [INFO], [ERROR], [TIMING])
   - Consistent formatting
   - Machine-parseable output
   - Human-readable output

3. **Documentation**
   - Hardware setup guide (with photos/diagrams)
   - Test execution procedures
   - Expected results documentation
   - Troubleshooting guide
   - Lessons learned

4. **Test Reports**
   - Test report template
   - Automated report generation
   - Test result archiving
   - Trend analysis (optional)

#### Out of Scope
- Python test harness (tock-hardware-ci) → PI004
- CI/CD integration → PI005
- Automated hardware setup → Future

### Technical Approach

#### Enhanced Test Script

**Current (test_gpio.sh):**
```bash
#!/bin/bash
PORT=/dev/ttyACM0
timeout 30 cat $PORT | grep "\[TEST\]" | grep -c "PASS"
```

**Enhanced (test_gpio_interrupts.sh):**
```bash
#!/bin/bash
PORT=/dev/ttyACM0
TIMEOUT=60
LOG_FILE="test_results_$(date +%Y%m%d_%H%M%S).log"

# Capture output
timeout $TIMEOUT cat $PORT > $LOG_FILE

# Parse results
TOTAL_TESTS=$(grep -c "\[TEST\].*: start" $LOG_FILE)
PASSED=$(grep -c "\[TEST\].*: PASS" $LOG_FILE)
FAILED=$(grep -c "\[TEST\].*: FAIL" $LOG_FILE)

# Extract timing data (if present)
grep "\[TIMING\]" $LOG_FILE > timing_data.txt

# Generate report
echo "=== Test Summary ==="
echo "Total Tests: $TOTAL_TESTS"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo "Pass Rate: $(( PASSED * 100 / TOTAL_TESTS ))%"

# Exit code
if [ $FAILED -eq 0 ]; then
    echo "ALL TESTS PASSED"
    exit 0
else
    echo "SOME TESTS FAILED"
    exit 1
fi
```

#### Structured Test Output Format

**Proposed Format:**
```
[TEST] test_name: start
[INFO] test_name: description of what's being tested
[STEP] test_name: step description
[TIMING] test_name: expected=100ms actual=102ms error=2.0%
[TEST] test_name: PASS
```

**Example:**
```
[TEST] gpio_interrupt_rising: start
[INFO] gpio_interrupt_rising: Testing rising edge interrupt on GPIO19
[STEP] gpio_interrupt_rising: Configuring GPIO18 as output, GPIO19 as input
[STEP] gpio_interrupt_rising: Enabling rising edge interrupt
[STEP] gpio_interrupt_rising: Triggering LOW→HIGH transition
[INFO] gpio_interrupt_rising: Interrupt fired (count: 1)
[TEST] gpio_interrupt_rising: PASS

[TEST] timer_alarm_100ms: start
[INFO] timer_alarm_100ms: Testing 100ms alarm accuracy
[STEP] timer_alarm_100ms: Setting alarm for 100ms
[TIMING] timer_alarm_100ms: expected=100000µs actual=100234µs error=0.23%
[TEST] timer_alarm_100ms: PASS (within ±10% tolerance)
```

#### Documentation Structure

**Hardware Setup Guide:**
```markdown
# PI003 HIL Testing - Hardware Setup Guide

## Required Materials
- nanoESP32-C6 board
- 2-3 female-to-female jumper wires (10cm)
- USB-C cable
- Computer with serial terminal

## GPIO Loopback Connections

### Connection 1: Basic Loopback
- GPIO5 (J1 pin 2) → GPIO6 (J1 pin 3)
- [Photo of connection]

### Connection 2: Interrupt Testing
- GPIO18 (J6 pin 8) → GPIO19 (J6 pin 9)
- [Photo of connection]

## Verification
1. Visual inspection: wires firmly connected
2. Multimeter test: continuity between pins
3. Power on: no shorts, board boots normally

## Safety Checklist
- [ ] All connections are 3.3V (no 5V connections)
- [ ] No loose wires touching other pins
- [ ] Board powered via USB only
```

**Test Execution Guide:**
```markdown
# PI003 HIL Testing - Test Execution Guide

## Pre-Test Checklist
- [ ] Hardware connections verified
- [ ] Board powered and detected (/dev/ttyACM0)
- [ ] Serial terminal ready (115200 baud)

## Running GPIO Interrupt Tests

1. Flash test firmware:
   ```bash
   cd tock/boards/nano-esp32-c6
   make flash-test-gpio-interrupts
   ```

2. Run test script:
   ```bash
   ./test_gpio_interrupts.sh
   ```

3. Expected output:
   ```
   [TEST] gpio_interrupt_rising: PASS
   [TEST] gpio_interrupt_falling: PASS
   ...
   === Test Summary ===
   Total Tests: 10
   Passed: 10
   Failed: 0
   Pass Rate: 100%
   ALL TESTS PASSED
   ```

## Troubleshooting
...
```

#### Files to Create

**Test Scripts:**
- `test_gpio_interrupts.sh` (enhanced GPIO test script)
- `test_timer_alarms.sh` (enhanced timer test script)
- `run_all_hil_tests.sh` (master test script)

**Documentation:**
- `HARDWARE_SETUP.md` (hardware setup guide with photos)
- `TEST_PROCEDURES.md` (test execution procedures)
- `EXPECTED_RESULTS.md` (expected test results)
- `TROUBLESHOOTING.md` (common issues and solutions)
- `LESSONS_LEARNED.md` (insights from testing)

**Templates:**
- `TEST_REPORT_TEMPLATE.md` (test report template)

### Deliverables

1. **Enhanced Test Scripts:**
   - test_gpio_interrupts.sh
   - test_timer_alarms.sh
   - run_all_hil_tests.sh

2. **Documentation:**
   - HARDWARE_SETUP.md (with photos/diagrams)
   - TEST_PROCEDURES.md
   - EXPECTED_RESULTS.md
   - TROUBLESHOOTING.md
   - LESSONS_LEARNED.md

3. **Templates:**
   - TEST_REPORT_TEMPLATE.md

4. **Test Report:**
   - SP003 completion report
   - Overall PI003 summary

### Success Criteria

**Must Have:**
- ✅ Test scripts run automatically
- ✅ Clear pass/fail reporting
- ✅ Hardware setup fully documented (with photos)
- ✅ Test procedures documented
- ✅ Troubleshooting guide created

**Should Have:**
- ✅ Timing validation in scripts
- ✅ Structured test output
- ✅ Test report template
- ✅ Lessons learned documented

**Nice to Have:**
- ⭕ Automated report generation
- ⭕ Test result archiving
- ⭕ Trend analysis

### Estimated Complexity

**Complexity:** Low

**Rationale:**
- Mostly documentation and scripting
- Building on existing test scripts
- No hardware changes needed

**Estimated Iterations:** 2-3

---

## 4. Hardware Setup

### 4.1 Required Materials

**Essential:**
- ✅ nanoESP32-C6 development board
- ✅ 2-3 female-to-female jumper wires (10cm standard breadboard wires)
- ✅ USB-C cable (for power and programming)
- ✅ Computer with serial terminal (screen, picocom, or similar)

**Optional:**
- ⭕ Logic analyzer (for timing verification)
- ⭕ Multimeter (for connection verification)
- ⭕ Small breadboard (for organizing connections)

**Cost:** ~$2-5 for jumper wires (if not already available)

### 4.2 GPIO Loopback Connections

**Connection Diagram:**
```
nanoESP32-C6 Board

Header J1 (Left Side):
  Pin 1  [GPIO4]
  Pin 2  [GPIO5]  ──┐
  Pin 3  [GPIO6]  ──┘ Wire 1 (Basic Loopback)
  Pin 4  [GPIO7]
  ...

Header J6 (Right Side):
  ...
  Pin 8  [GPIO18] ──┐
  Pin 9  [GPIO19] ──┘ Wire 2 (Interrupt Testing)
  Pin 10 [GPIO20] ──┐
  Pin 11 [GPIO21] ──┘ Wire 3 (Optional)
  ...
```

**Physical Connections:**
1. **Wire 1:** GPIO5 (J1-2) ↔ GPIO6 (J1-3) - Basic loopback (existing)
2. **Wire 2:** GPIO18 (J6-8) ↔ GPIO19 (J6-9) - Interrupt testing (new)
3. **Wire 3:** GPIO20 (J6-10) ↔ GPIO21 (J6-11) - Optional (future use)

### 4.3 Safety Considerations

**Voltage Levels:**
- ✅ All GPIOs are 3.3V
- ✅ Safe to connect GPIOs together
- ⚠️  DO NOT connect to 5V rail (will damage ESP32-C6)

**Current Limits:**
- GPIO output: 40mA max (per pin)
- GPIO input: ~0mA (high impedance)
- Loopback: negligible current draw

**Protection:**
- ✅ No external voltage sources
- ✅ No risk of shorts (different pins)
- ✅ USB power only (no external power supply)

**Pre-Test Checklist:**
- [ ] Visual inspection: wires firmly seated in headers
- [ ] No loose wires touching other pins
- [ ] Multimeter continuity test (optional but recommended)
- [ ] Board boots normally with connections in place

### 4.4 Test Environment

**Serial Console:**
- Port: /dev/ttyACM0 (Linux/Mac) or COMx (Windows)
- Baud rate: 115200
- Format: 8N1 (8 data bits, no parity, 1 stop bit)
- Flow control: None

**Software:**
- esptool.py (for flashing)
- screen, picocom, or minicom (for serial monitoring)
- Bash shell (for test scripts)

---

## 5. Success Criteria

### 5.1 Overall PI Success Criteria

**Must Achieve:**
- ✅ All 5 GPIO interrupt modes validated through loopback
- ✅ Timer alarms fire with ±10% timing accuracy
- ✅ Edge cases handled correctly (0ms, 1ms, wraparound)
- ✅ No spurious interrupts or missed alarms
- ✅ Hardware setup fully documented
- ✅ Test procedures documented
- ✅ Reproducible by others

**Quality Gates:**
- ✅ 100% test pass rate (all tests must pass)
- ✅ ≥90% timing accuracy (within ±10%)
- ✅ Zero crashes or system hangs
- ✅ Consistent results (run 3 times successfully)

### 5.2 Sprint-Specific Success Criteria

**SP001 (GPIO Interrupts):**
- ✅ 10/10 test cases pass
- ✅ All interrupt modes work
- ✅ No spurious interrupts

**SP002 (Timer Alarms):**
- ✅ 12/12 test cases pass
- ✅ ≥90% within ±10% timing tolerance
- ✅ Continuous operation stable (60s)

**SP003 (Infrastructure):**
- ✅ Test scripts run automatically
- ✅ Documentation complete
- ✅ Reproducible by others

### 5.3 Definition of Done

**For Each Sprint:**
- [ ] All code written and reviewed
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Test report created
- [ ] Handoff to next sprint (or PI complete)

**For Overall PI:**
- [ ] All sprints complete
- [ ] All tests passing consistently
- [ ] Hardware setup documented (with photos)
- [ ] Test procedures documented
- [ ] Lessons learned documented
- [ ] PI completion report written

---

## 6. Risk Management

### 6.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| **Interrupt timing unreliable** | Medium | Medium | Use generous debounce delays; test multiple times | Implementor |
| **Level interrupts fire continuously** | Medium | Low | Disable after first fire; document behavior | Implementor |
| **Timing accuracy insufficient** | Low | Medium | Use ±10% tolerance; measure with logic analyzer if needed | Implementor |
| **Hardware connections unreliable** | Low | Medium | Use quality jumper wires; document proper seating | Analyst |
| **Board damage from incorrect wiring** | Very Low | High | Provide clear safety guidelines; pre-test checklist | Analyst |

### 6.2 Schedule Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| **Timing measurements complex** | Medium | Low | Use existing test capsules; simple calculations | Implementor |
| **Documentation takes longer** | Low | Low | Use templates; focus on essential docs | Implementor |
| **Hardware not available** | Low | High | **BLOCKER - PO must confirm availability** | PO |

### 6.3 Scope Risks

| Risk | Likelihood | Impact | Mitigation | Owner |
|------|------------|--------|------------|-------|
| **Scope creep (userspace tests)** | Medium | Medium | **Firm decision: defer to PI004** | Analyst/PO |
| **Too many test scenarios** | Low | Low | Prioritize: core functionality first | Implementor |
| **Over-documentation** | Low | Low | Focus on essential docs; iterate later | Implementor |

### 6.4 Risk Mitigation Actions

**Pre-PI Actions:**
1. ✅ Research complete (this document)
2. ⏳ PO confirms hardware availability (USER_QUESTIONS.md)
3. ⏳ PO approves sprint structure
4. ⏳ PO confirms timing tolerance acceptable

**During PI Actions:**
1. Test hardware connections before starting each sprint
2. Run tests multiple times to ensure consistency
3. Document any issues immediately
4. Escalate blockers to PO promptly

---

## 7. Deliverables

### 7.1 Code Deliverables

**New Files:**
- `tock/boards/nano-esp32-c6/src/gpio_interrupt_tests.rs` (~300 lines)
- `tock/boards/nano-esp32-c6/src/timer_alarm_tests.rs` (~400 lines)
- `tock/boards/nano-esp32-c6/test_gpio_interrupts.sh` (~100 lines)
- `tock/boards/nano-esp32-c6/test_timer_alarms.sh` (~100 lines)
- `tock/boards/nano-esp32-c6/run_all_hil_tests.sh` (~50 lines)

**Modified Files:**
- `tock/boards/nano-esp32-c6/src/main.rs` (+50 lines, test integration)
- `tock/boards/nano-esp32-c6/src/gpio_tests.rs` (+50 lines, enhancements)
- `tock/boards/nano-esp32-c6/src/timer_tests.rs` (+50 lines, enhancements)

**Total New Code:** ~1,100 lines

### 7.2 Documentation Deliverables

**Sprint Documentation:**
- `project_management/PI003_HILTesting/SP001_GPIOInterrupts/` (sprint folder)
- `project_management/PI003_HILTesting/SP002_TimerAlarms/` (sprint folder)
- `project_management/PI003_HILTesting/SP003_Infrastructure/` (sprint folder)

**Test Documentation:**
- `project_management/PI003_HILTesting/HARDWARE_SETUP.md` (with photos)
- `project_management/PI003_HILTesting/TEST_PROCEDURES.md`
- `project_management/PI003_HILTesting/EXPECTED_RESULTS.md`
- `project_management/PI003_HILTesting/TROUBLESHOOTING.md`
- `project_management/PI003_HILTesting/LESSONS_LEARNED.md`

**Templates:**
- `project_management/PI003_HILTesting/TEST_REPORT_TEMPLATE.md`

**Reports:**
- `project_management/PI003_HILTesting/PI003_COMPLETION_SUMMARY.md`

**Total Documentation:** ~8-10 documents

### 7.3 Test Deliverables

**Test Results:**
- GPIO interrupt test results (10 test cases)
- Timer alarm test results (12 test cases)
- Test execution logs
- Timing statistics

**Test Reports:**
- SP001 test report
- SP002 test report
- SP003 test report
- Overall PI003 test summary

---

## 8. Dependencies

### 8.1 Prerequisites (Must Have Before Starting)

**Hardware:**
- [ ] nanoESP32-C6 board available
- [ ] Jumper wires available
- [ ] USB-C cable available
- [ ] Serial terminal software installed

**Software:**
- [x] PI002 complete (core peripherals implemented)
- [x] GPIO driver functional
- [x] Timer driver functional
- [x] UART console working
- [x] Build system working

**Knowledge:**
- [x] Research complete (this document)
- [ ] PO approval received
- [ ] Hardware setup understood

### 8.2 External Dependencies

**Tock Upstream:**
- [x] Test capsules available (capsules/core/src/test/)
- [x] HIL traits defined
- [x] Documentation available

**Tools:**
- [x] esptool.py installed
- [x] Rust toolchain installed
- [x] Serial terminal available (screen/picocom)

**None of these are blockers** - all already available.

### 8.3 Inter-Sprint Dependencies

**SP001 → SP002:**
- No hard dependency
- Can run in parallel if needed
- SP002 doesn't depend on SP001 completion

**SP001 + SP002 → SP003:**
- SP003 requires SP001 and SP002 complete (documentation sprint)
- Must have test results to document

**Recommended Sequence:**
1. SP001 (GPIO interrupts)
2. SP002 (Timer alarms)
3. SP003 (Infrastructure) - requires both complete

**Alternative (Parallel):**
- SP001 and SP002 in parallel (if resources available)
- SP003 after both complete

---

## 9. Approval and Next Steps

### 9.1 PO Approval Required

**This plan requires PO approval for:**
- [ ] Sprint structure (3 sprints vs 5 sprints)
- [ ] Scope (defer userspace tests to PI004)
- [ ] Timing tolerance (±10%)
- [ ] Hardware availability confirmation
- [ ] Success criteria

**PO: Please review and approve in USER_QUESTIONS.md**

### 9.2 Next Steps After Approval

1. **PO Reviews:**
   - Review this planning document
   - Answer questions in USER_QUESTIONS.md
   - Approve sprint structure

2. **Analyst:**
   - Address any PO feedback
   - Finalize sprint plans
   - Create sprint folders

3. **Implementor:**
   - Review sprint plans
   - Ask clarifying questions
   - Begin SP001 implementation

### 9.3 Communication Plan

**Daily:**
- Progress updates via sprint progress reports
- Issue escalation if blockers found

**Per Sprint:**
- Sprint completion report
- Test results summary
- Handoff to next sprint

**End of PI:**
- PI completion summary
- Lessons learned
- Recommendations for PI004

---

## 10. Conclusion

### 10.1 Summary

**PI003 Plan:**
- **3 sprints** (GPIO interrupts, Timer alarms, Infrastructure)
- **Hardware loopback testing** for GPIO interrupts
- **Timing accuracy validation** for timer alarms
- **Enhanced documentation** and test infrastructure
- **Deferred userspace tests** to PI004 (correct decision)

**Confidence Level:** HIGH (90%)

**Why High Confidence:**
- ✅ Clear patterns exist in Tock
- ✅ Building on successful PI002
- ✅ Hardware is well-documented
- ✅ Scope is well-defined
- ✅ Proven test capsules available

**Remaining Uncertainties:**
- ⚠️  Hardware availability (PO must confirm)
- ⚠️  Timing tolerance acceptable (PO must approve)
- ⚠️  Sprint structure preference (PO must decide)

### 10.2 Analyst Recommendation

**Proceed with 3-sprint structure:**
- SP001: GPIO Interrupt HIL Tests
- SP002: Timer Alarm HIL Tests
- SP003: Test Infrastructure & Documentation

**Rationale:**
- Focused, deep testing
- Less overhead
- Matches two peripherals
- Allows thorough validation

**Defer to PI004:**
- Userspace test applications (libtock-c)
- Python test harness (tock-hardware-ci)
- CI/CD integration

**This is the right approach** - validate HIL first, then build userspace tests on proven foundation.

---

**End of PI Planning Document**

**Status:** ⏳ AWAITING PO APPROVAL

**Next:** PO reviews and approves via USER_QUESTIONS.md, then proceed to SP001 implementation.
