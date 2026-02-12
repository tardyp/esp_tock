# PI003_HILTesting - Research Report

**Analyst:** @analyst  
**Date:** 2026-02-12  
**PI:** PI003_HILTesting  
**Phase:** Research & Analysis  

---

## Executive Summary

This research report provides comprehensive analysis of Tock's Hardware Independent Layer (HIL) testing infrastructure and proposes a detailed plan for PI003. The goal is to move beyond basic shell script tests to production-quality HIL validation using hardware loopback tests and userspace test applications.

**Key Findings:**
1. ✅ Tock has established test patterns for GPIO loopback and timer validation
2. ✅ Test capsules exist for alarm/timer testing (TestRandomAlarm, TestAlarmEdgeCases)
3. ✅ Hardware test infrastructure exists (tock-hardware-ci repository)
4. ✅ ESP32-C6 board has suitable GPIO pins for loopback testing
5. ⚠️  Userspace test applications exist but are in separate libtock-c repository (not in main Tock repo)
6. ✅ Existing GPIO tests on nano-esp32-c6 provide good foundation

---

## 1. Research: Existing Tock Test Infrastructure

### 1.1 Test Organization Patterns

Tock uses **three levels** of testing:

#### Level 1: In-Kernel Test Capsules
**Location:** `tock/capsules/core/src/test/`

**Purpose:** Kernel-space validation of peripheral drivers through HIL traits

**Available Test Capsules:**
- `alarm_edge_cases.rs` - Tests alarm edge cases (delays of 0, 1, various timings)
- `random_alarm.rs` - Continuous random alarm testing with timing validation
- `capsule_test.rs` - Framework for async capsule testing

**Pattern Example (TestRandomAlarm):**
```rust
pub struct TestRandomAlarm<'a, A: Alarm<'a>> {
    alarm: &'a A,
    counter: Cell<usize>,
    // Sets alarms with random delays (0-512ms)
    // Validates timing accuracy within 50ms tolerance
}
```

**Key Insight:** These test capsules validate HIL implementations through continuous operation, not just one-shot tests.

#### Level 2: Board-Level Hardware Tests
**Location:** `tock/boards/{board}/src/test/`

**Examples Found:**
- `tock/boards/imix/src/test/` - 17 test modules including:
  - `spi_loopback.rs` - Physical MOSI-to-MISO loopback testing
  - `linear_log_test.rs` - Flash storage validation
  - `aes_test.rs`, `sha256_test.rs` - Crypto validation
  
- `tock/boards/nano-esp32-c6/src/gpio_tests.rs` - Our existing GPIO tests:
  - Output high/low
  - Input with pull resistors
  - **GPIO loopback (GPIO5→GPIO6)**
  - Interrupt testing (manual trigger)
  - Multiple pin operations
  - Stress testing (500 toggles)

- `tock/boards/nano-esp32-c6/src/timer_tests.rs` - Our existing timer tests:
  - Counter increment validation
  - Frequency measurement
  - Alarm arming verification

**Pattern:** Board tests are **in-kernel** but **hardware-dependent**, designed to run at boot and output results via UART.

#### Level 3: Userspace Test Applications
**Location:** External repository (libtock-c, libtock-rs)

**Status:** PO mentioned "I think I have seen such tests already in the code base"

**Finding:** Userspace tests exist in **separate repositories**:
- `tock/tock-hardware-ci` - Python-based hardware CI framework
- External: `libtock-c` repository (examples/tests/)
- External: `libtock-rs` repository

**Test Framework (tock-hardware-ci):**
```python
# hwci/tests/c_hello.py pattern
class MyTest(OneshotTest):
    def __init__(self):
        super().__init__(apps=["my_app"])
    
    def oneshot_test(self, board):
        output = board.serial.expect("Expected Output", timeout=10)
```

**Key Insight:** Userspace tests require:
1. Compiling test applications (libtock-c/libtock-rs)
2. Flashing to board
3. Python test harness to validate output
4. More complex setup than in-kernel tests

---

### 1.2 GPIO Loopback Test Patterns

#### Pattern 1: Imix SPI Loopback
**File:** `tock/boards/imix/src/test/spi_loopback.rs`

**Approach:**
- Physical connection: MOSI → MISO
- Writes incrementing pattern, reads back
- Validates byte-by-byte match
- Continuous testing with different speeds

**Key Code:**
```rust
impl spi::SpiMasterClient for SpiLoopback {
    fn read_write_done(&self, write: SubSliceMut<'static, u8>, 
                       read: Option<SubSliceMut<'static, u8>>, 
                       status: Result<usize, ErrorCode>) {
        for (c, v) in write[..].iter().enumerate() {
            if read[c] != *v {
                debug!("SPI test error at index {}: wrote {} but read {}", c, v, read[c]);
            }
        }
        // Set up next test with incremented pattern
    }
}
```

**Lesson:** Loopback tests validate **bidirectional communication** and **data integrity**.

#### Pattern 2: ESP32-C6 GPIO Loopback (Current Implementation)
**File:** `tock/boards/nano-esp32-c6/src/gpio_tests.rs`

**Current Test:**
```rust
// Test 3: Loopback (GPIO5 → GPIO6)
p5.make_output();
p6.make_input();
p6.set_floating_state(FloatingState::PullNone);

p5.set();
delay();
let h = p6.read();  // Expect HIGH

p5.clear();
delay();
let l = p6.read();  // Expect LOW

if h && !l {
    // PASS
}
```

**Strengths:**
- Simple, direct validation
- Tests basic GPIO functionality
- Already implemented and working

**Limitations:**
- Only tests static levels (not edges)
- No interrupt validation through loopback
- Manual connection required (documented in test output)

---

### 1.3 Timer/Alarm Test Patterns

#### Pattern 1: TestAlarmEdgeCases
**File:** `tock/capsules/core/src/test/alarm_edge_cases.rs`

**Approach:**
- Array of 20 test delays: `[100, 200, 25, 25, 25, 25, 500, 0, 448, 15, 19, 1, 0, 33, 5, 1000, 27, 1, 0, 1]` (ms)
- Sets alarm, waits for callback
- Validates alarm fires
- Tests edge cases: 0ms delay, 1ms delay, repeated delays

**Key Code:**
```rust
fn set_next_alarm(&self) {
    let delay = self.alarm.ticks_from_ms(self.alarms[counter % 20]);
    let now = self.alarm.now();
    let start = now.wrapping_sub(A::Ticks::from(10)); // Test past reference
    
    self.alarm.set_alarm(start, delay);
}

impl AlarmClient for TestAlarmEdgeCases {
    fn alarm(&self) {
        debug!("Alarm fired at {}.", now.into_u32());
        self.set_next_alarm(); // Continuous testing
    }
}
```

**Lesson:** Timer tests should validate:
1. Alarm fires at all
2. Timing accuracy (within tolerance)
3. Edge cases (0, 1, very short, very long delays)
4. Wraparound handling

#### Pattern 2: TestRandomAlarm
**File:** `tock/capsules/core/src/test/random_alarm.rs`

**Approach:**
- Pseudo-random delays (0-512ms range)
- Validates timing accuracy: `assert!(diff < 50ms)`
- Tests delays from the past (wraparound)
- Continuous operation

**Key Validation:**
```rust
fn alarm(&self) {
    let diff = now.wrapping_sub(self.expected.get());
    if !self.first.get() {
        assert!(self.alarm.ticks_to_ms(diff) < 50); // 50ms tolerance
    }
}
```

**Lesson:** Production timer tests need **timing accuracy validation**, not just "did it fire?"

#### Pattern 3: Multi-Alarm Test
**File:** `tock/boards/components/src/test/multi_alarm_test.rs`

**Approach:**
- Creates 3 virtual alarms from one MuxAlarm
- Each runs TestRandomAlarm with different seed
- Tests alarm multiplexing

**Lesson:** HIL tests should validate **virtualization** works correctly.

---

### 1.4 ESP32-C6 Current Test Status

#### Existing Tests (PI002 Deliverables)

**GPIO Tests (SP004):**
- ✅ Output high/low
- ✅ Input with pull-up/pull-down
- ✅ GPIO loopback (GPIO5→GPIO6)
- ✅ Interrupt setup (but manual trigger required)
- ✅ Multiple pin operations
- ✅ Stress test (500 toggles)

**Timer Tests (SP003):**
- ✅ Counter increments
- ✅ Frequency measurement
- ✅ Alarm arming
- ⚠️  Alarm callback verification (limited)

**Test Execution Method:**
- Shell script: `test_gpio.sh`
- Greps serial output for `[TEST]` markers
- Counts PASS/FAIL
- **Limitation:** No programmatic validation, just pattern matching

---

## 2. ESP32-C6 Hardware Analysis

### 2.1 GPIO Pin Availability

**Source:** `nanoESP32-C6/hardware/nanoesp32-c6-pinout.md`

#### Available GPIOs for Testing

**Total Available:** 20 GPIOs (GPIO0-13, GPIO15, GPIO18-23)

**Reserved/Special Pins:**
| GPIO | Function | Availability | Notes |
|------|----------|--------------|-------|
| GPIO9 | Boot button | Limited | Must be HIGH for normal boot |
| GPIO16 | RGB LED | Dedicated | WS2812B control (inverted via MOSFET) |
| TXD0 | UART TX | Reserved | Console output to CH343P |
| RXD0 | UART RX | Reserved | Console input from CH343P |

**Strapping Pins (use with caution):**
- GPIO8 - Boot mode selection (floating on board)
- GPIO9 - Boot mode selection (pulled HIGH via button)
- GPIO15 - JTAG/ROM message enable (floating)

#### Recommended GPIO Pairs for Loopback Testing

**Option 1: GPIO5 ↔ GPIO6 (Current Implementation)**
- ✅ Already used in existing tests
- ✅ No special functions
- ✅ Not strapping pins
- ✅ Easily accessible on header J1 (pins 2-3)
- **Recommendation:** Keep for basic loopback

**Option 2: GPIO18 ↔ GPIO19**
- ✅ No special functions
- ✅ Not strapping pins
- ✅ Adjacent on header J6 (pins 8-9)
- **Recommendation:** Use for interrupt loopback tests

**Option 3: GPIO20 ↔ GPIO21**
- ✅ No special functions
- ✅ Not strapping pins
- ✅ Adjacent on header J6 (pins 10-11)
- **Recommendation:** Use for additional test scenarios

**Option 4: GPIO22 ↔ GPIO23**
- ✅ No special functions
- ✅ Not strapping pins
- ✅ Adjacent on header J6 (pins 12-13)
- **Recommendation:** Reserve for future use

### 2.2 Hardware Setup Requirements

#### Physical Connections Needed

**For GPIO Loopback Tests:**
```
Jumper Wire Connections:
1. GPIO5  (J1 pin 2)  →  GPIO6  (J1 pin 3)   [Basic loopback]
2. GPIO18 (J6 pin 8)  →  GPIO19 (J6 pin 9)   [Interrupt tests]
3. GPIO20 (J6 pin 10) →  GPIO21 (J6 pin 11)  [Optional: additional tests]
```

**For Interrupt Tests (Manual Trigger):**
```
Test Wire:
- GPIO7 (J1 pin 4) → 3.3V or GND (for manual edge triggering)
```

**Safety Considerations:**
- ✅ All GPIOs are 3.3V tolerant
- ✅ No risk connecting GPIOs together (same voltage level)
- ⚠️  Do NOT connect to 5V rail (will damage ESP32-C6)
- ✅ Current limit: 40mA per GPIO (loopback draws ~0mA)
- ✅ Use female-to-female jumper wires (standard breadboard wires)

**Materials Needed:**
- 2-3 female-to-female jumper wires (10cm length typical)
- Optional: Small breadboard for organizing connections
- Optional: Logic analyzer for timing verification

### 2.3 Timer Hardware Characteristics

**ESP32-C6 Timer Groups (TIMG0/TIMG1):**
- **Counter:** 54-bit (wraps at 2^54)
- **Clock Source:** XTAL 40MHz (configured in PI002)
- **Divider:** Configurable (currently 4 → 10MHz effective)
- **Tick Period:** 100ns (at 10MHz)
- **Maximum Delay:** ~52 days (at 10MHz)

**Timing Accuracy Expectations:**
- **Crystal Accuracy:** ±20 ppm (typical XTAL)
- **Software Overhead:** ~1-10µs (interrupt latency)
- **Expected Tolerance:** ±100µs for millisecond-range delays
- **Test Tolerance:** Use ±10% for acceptance (generous for HIL testing)

**Interrupt Latency:**
- **ESP32-C6 RISC-V:** ~1-5µs typical
- **Tock Overhead:** ~5-10µs (context switch, callback dispatch)
- **Total:** ~10-20µs expected

---

## 3. Tock HIL Testing Best Practices

### 3.1 Test Design Principles (from Tock codebase analysis)

**Principle 1: Continuous Testing**
- Don't just test once - test continuously
- Example: TestRandomAlarm sets next alarm in callback
- Validates stability over time

**Principle 2: Edge Case Coverage**
- Test boundary conditions (0, 1, max values)
- Test wraparound behavior
- Test error conditions

**Principle 3: Timing Validation**
- Don't just check "did it happen?"
- Validate "did it happen at the right time?"
- Use reasonable tolerances (50ms for TestRandomAlarm)

**Principle 4: Serial Output Protocol**
- Use consistent markers: `[TEST]`, `[INFO]`, `[ERROR]`
- Include test name in output
- Report PASS/FAIL clearly
- Include diagnostic data (actual vs expected)

**Principle 5: Hardware Independence**
- Tests should work on any board implementing the HIL
- Use HIL traits, not direct register access
- Document hardware setup requirements

### 3.2 Test Capsule vs Board Test vs Userspace Test

**When to Use Test Capsules (in capsules/core/src/test/):**
- ✅ Testing HIL trait implementations
- ✅ Portable across boards
- ✅ Continuous/stress testing
- ✅ No hardware setup required
- ❌ Can't test board-specific wiring

**When to Use Board Tests (in boards/{board}/src/test/):**
- ✅ Testing board-specific features
- ✅ Loopback tests (require physical connections)
- ✅ Integration testing
- ✅ Quick to run (in-kernel)
- ❌ Not portable to other boards

**When to Use Userspace Tests (libtock-c apps):**
- ✅ Testing syscall interface
- ✅ Testing from application perspective
- ✅ CI/CD integration
- ✅ Automated test harness
- ❌ More complex setup
- ❌ Requires separate compilation

### 3.3 Recommended Approach for PI003

**Primary Focus: Enhanced Board-Level Tests**

**Rationale:**
1. **Faster iteration** - No need to compile separate userspace apps
2. **Direct HIL validation** - Tests the kernel implementation directly
3. **Hardware loopback** - Can test actual GPIO connections
4. **Immediate feedback** - Results visible via UART during boot
5. **Foundation for future** - Can add userspace tests later

**Secondary: Test Capsule Integration**

Use existing Tock test capsules (TestRandomAlarm, TestAlarmEdgeCases) to validate timer implementation.

**Future: Userspace Test Applications**

Defer to PI004 or later - requires setting up libtock-c build infrastructure.

---

## 4. Risk Analysis

### 4.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **GPIO loopback connections unreliable** | Low | Medium | Use quality jumper wires; document proper connection |
| **Interrupt timing too variable for validation** | Medium | Medium | Use generous tolerances (±10%); focus on "did fire" not exact timing |
| **Timer accuracy insufficient** | Low | High | PI002 already validated timers work; just need better tests |
| **Test output too verbose for shell script parsing** | Medium | Low | Use clear markers; structured output format |
| **Hardware damage from incorrect wiring** | Very Low | High | Provide clear wiring diagram; safety checks in documentation |

### 4.2 Scope Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Userspace tests too complex for PI003** | High | Medium | **MITIGATION: Defer userspace tests to future PI** |
| **Too many test scenarios** | Medium | Medium | Prioritize: loopback + interrupts first, edge cases second |
| **Test automation insufficient** | Low | Low | Shell scripts adequate for now; Python harness is future work |

### 4.3 Hardware Availability Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Board not available for testing** | Low | High | **QUESTION FOR PO:** Do you have the board and jumper wires? |
| **GPIO pins damaged** | Very Low | Medium | Follow safety guidelines; test with multimeter first |

---

## 5. Gaps Identified

### 5.1 Current Test Limitations

**GPIO Tests:**
- ✅ Basic loopback works (static levels)
- ❌ No interrupt validation through loopback
- ❌ No edge detection testing (rising/falling/both)
- ❌ No level interrupt testing (high/low)
- ❌ No interrupt callback verification (just setup)

**Timer Tests:**
- ✅ Counter and frequency work
- ✅ Alarm arming works
- ❌ No alarm callback timing validation
- ❌ No edge case testing (0ms, 1ms delays)
- ❌ No continuous alarm testing
- ❌ No multi-alarm testing

**Test Infrastructure:**
- ✅ Serial output parsing works
- ❌ No timing measurements in tests
- ❌ No automated pass/fail criteria
- ❌ No test repeatability validation

### 5.2 Knowledge Gaps

**Questions Answered by Research:**
1. ✅ Where are Tock userspace tests? → External repos (libtock-c)
2. ✅ How do other boards test GPIO? → Loopback pattern (imix/spi_loopback)
3. ✅ How do other boards test timers? → Test capsules (TestRandomAlarm, TestAlarmEdgeCases)
4. ✅ Which GPIO pins safe for loopback? → GPIO5-6, GPIO18-19, GPIO20-21
5. ✅ What timing tolerance acceptable? → 50ms for TestRandomAlarm, ±10% reasonable

**Questions for PO:**
1. ❓ Do you have the nanoESP32-C6 board physically available?
2. ❓ Do you have jumper wires for GPIO loopback connections?
3. ❓ Is userspace testing required for PI003, or can we defer to PI004?
4. ❓ What is acceptable timing tolerance for timer tests? (Suggest ±10%)
5. ❓ Should we use existing test capsules (TestRandomAlarm) or write custom tests?

---

## 6. Recommendations

### 6.1 Proposed Approach

**Strategy: Enhanced Board-Level HIL Tests**

**Phase 1: GPIO Interrupt Validation (High Priority)**
- Enhance existing GPIO loopback test
- Add interrupt testing through loopback
- Validate all 5 interrupt modes
- Test from kernel space (board tests)

**Phase 2: Timer Accuracy Validation (High Priority)**
- Integrate TestRandomAlarm capsule
- Add timing accuracy measurements
- Validate alarm callbacks fire correctly
- Test edge cases (0ms, 1ms, wraparound)

**Phase 3: Test Infrastructure Improvement (Medium Priority)**
- Improve test output format
- Add timing measurements
- Better pass/fail reporting
- Document test procedures

**Phase 4: Userspace Tests (Deferred to PI004)**
- Set up libtock-c build environment
- Create GPIO test application
- Create timer test application
- Integrate with tock-hardware-ci

### 6.2 Sprint Structure Proposal

**Recommended: 3 Sprints (not 5)**

**Why 3 Sprints:**
- GPIO and Timer are the only two peripherals needing HIL validation
- Userspace tests deferred (too complex for initial HIL validation)
- Focus on quality over quantity
- Allows time for thorough hardware testing

**Sprint Breakdown:**

#### SP001: GPIO Interrupt HIL Tests (Loopback-Based)
**Goal:** Validate GPIO interrupts work correctly through hardware loopback

**Scope:**
1. Enhance GPIO loopback test (GPIO5→GPIO6)
2. Add second loopback pair (GPIO18→GPIO19) for interrupt testing
3. Test all 5 interrupt modes:
   - Rising edge
   - Falling edge
   - Both edges
   - High level
   - Low level
4. Validate interrupt callbacks fire
5. Validate interrupt enable/disable
6. Test multiple simultaneous interrupts

**Hardware Setup:**
- Connect GPIO5→GPIO6 (existing)
- Connect GPIO18→GPIO19 (new)

**Success Criteria:**
- All 5 interrupt modes trigger correctly
- Callbacks fire when expected
- No spurious interrupts
- Multiple interrupts work simultaneously

**Estimated Complexity:** Medium (building on existing GPIO tests)

---

#### SP002: Timer Alarm HIL Tests (Accuracy & Edge Cases)
**Goal:** Validate timer alarms fire accurately and handle edge cases

**Scope:**
1. Integrate TestRandomAlarm capsule
2. Add timing accuracy measurements
3. Test edge cases:
   - 0ms delay
   - 1ms delay
   - Very short delays (<10ms)
   - Long delays (>1 second)
   - Wraparound scenarios
4. Validate timing accuracy (±10% tolerance)
5. Test multiple concurrent alarms (MuxAlarm)
6. Stress test: continuous alarms for 60 seconds

**Hardware Setup:**
- No additional hardware needed (timer is internal)

**Success Criteria:**
- Alarms fire within ±10% of expected time
- Edge cases handled correctly
- No missed alarms
- Multi-alarm works correctly
- Continuous operation stable

**Estimated Complexity:** Medium (integrating existing test capsules)

---

#### SP003: Test Infrastructure & Documentation
**Goal:** Improve test automation and document HIL testing procedures

**Scope:**
1. Enhance test output format:
   - Structured markers
   - Timing measurements
   - Clear pass/fail reporting
2. Improve test scripts:
   - Better parsing
   - Timing validation
   - Automated pass/fail
3. Create comprehensive test documentation:
   - Hardware setup guide with photos/diagrams
   - Test execution procedures
   - Expected results
   - Troubleshooting guide
4. Create test report template
5. Document lessons learned

**Success Criteria:**
- Tests run automatically
- Results clearly reported
- Documentation complete
- Reproducible by others

**Estimated Complexity:** Low (documentation and scripting)

---

### 6.3 Alternative: 5-Sprint Structure (if PO prefers)

If PO wants more granular sprints:

**SP001:** GPIO Loopback Enhancement (basic + edge interrupts)  
**SP002:** GPIO Level Interrupts & Multi-Pin Tests  
**SP003:** Timer Edge Cases & Accuracy  
**SP004:** Multi-Alarm & Stress Testing  
**SP005:** Test Infrastructure & Documentation  

**Analyst Recommendation:** **3-sprint structure is better**
- Less overhead
- More focused
- Allows deeper testing per sprint
- Matches the two peripherals being tested (GPIO, Timer)

---

## 7. Success Criteria for PI003

### 7.1 GPIO HIL Testing

**Must Have:**
- ✅ All 5 interrupt modes validated through loopback
- ✅ Interrupt callbacks verified to fire
- ✅ No spurious interrupts
- ✅ Hardware setup documented

**Should Have:**
- ✅ Multiple simultaneous interrupts tested
- ✅ Interrupt enable/disable verified
- ✅ Edge case testing (rapid toggles, etc.)

**Nice to Have:**
- ⭕ Interrupt latency measurements
- ⭕ Stress testing (1000s of interrupts)

### 7.2 Timer HIL Testing

**Must Have:**
- ✅ Alarm callbacks fire correctly
- ✅ Timing accuracy within ±10%
- ✅ Edge cases handled (0ms, 1ms, long delays)
- ✅ Continuous operation stable

**Should Have:**
- ✅ Multi-alarm testing (MuxAlarm)
- ✅ Wraparound scenarios tested
- ✅ Stress testing (continuous alarms for 60s)

**Nice to Have:**
- ⭕ Timing accuracy within ±1%
- ⭕ Very long delays tested (>10 seconds)

### 7.3 Test Infrastructure

**Must Have:**
- ✅ Tests run automatically via script
- ✅ Clear pass/fail reporting
- ✅ Hardware setup documented

**Should Have:**
- ✅ Timing measurements in output
- ✅ Structured test output format
- ✅ Troubleshooting guide

**Nice to Have:**
- ⭕ Python test harness (tock-hardware-ci)
- ⭕ CI/CD integration

---

## 8. Handoff to Implementation

### 8.1 What Implementor Needs to Know

**GPIO Interrupt Testing:**
1. Use GPIO18→GPIO19 loopback (new pair, not GPIO5-6)
2. Output pin triggers interrupt on input pin
3. Test pattern:
   - Set output HIGH → verify rising edge interrupt
   - Set output LOW → verify falling edge interrupt
   - Toggle rapidly → verify both edges
   - Hold HIGH → verify high level interrupt
   - Hold LOW → verify low level interrupt
4. Use interrupt client callback to count interrupts
5. Validate count matches expected triggers

**Timer Testing:**
1. Use existing TestRandomAlarm capsule from `capsules/core/src/test/`
2. Integrate into board main.rs
3. Add timing measurement (compare expected vs actual)
4. Report timing accuracy in test output
5. Run for 60 seconds to validate stability

**Test Output Format:**
```
[TEST] test_name: start
[TEST] test_name: step description
[TEST] test_name: PASS (optional: timing data)
[TEST] test_name: FAIL - reason
```

### 8.2 Files to Modify

**New Files:**
- `tock/boards/nano-esp32-c6/src/gpio_interrupt_tests.rs` (new)
- `tock/boards/nano-esp32-c6/src/timer_alarm_tests.rs` (new)

**Modified Files:**
- `tock/boards/nano-esp32-c6/src/main.rs` (add test calls)
- `tock/boards/nano-esp32-c6/src/gpio_tests.rs` (enhance existing)
- `tock/boards/nano-esp32-c6/src/timer_tests.rs` (enhance existing)

**New Documentation:**
- `project_management/PI003_HILTesting/HARDWARE_SETUP.md`
- `project_management/PI003_HILTesting/TEST_PROCEDURES.md`

### 8.3 Reference Implementations

**Study These Files:**
1. `tock/capsules/core/src/test/random_alarm.rs` - Timer test pattern
2. `tock/boards/imix/src/test/spi_loopback.rs` - Loopback test pattern
3. `tock/boards/nano-esp32-c6/src/gpio_tests.rs` - Existing GPIO tests
4. `tock/boards/components/src/test/multi_alarm_test.rs` - Multi-alarm pattern

---

## 9. Conclusion

### 9.1 Key Takeaways

1. **Tock has established HIL test patterns** - We don't need to invent new approaches
2. **Board-level tests are the right choice** - Faster iteration than userspace tests
3. **Hardware loopback is proven** - Used successfully in imix and other boards
4. **Test capsules exist for timers** - TestRandomAlarm provides excellent validation
5. **ESP32-C6 hardware is suitable** - Plenty of GPIO pins, good timer characteristics

### 9.2 Recommended Path Forward

**Immediate Next Steps:**
1. **PO Decision:** Approve 3-sprint structure (or request 5-sprint)
2. **PO Confirmation:** Hardware availability (board + jumper wires)
3. **Start SP001:** GPIO interrupt loopback tests
4. **Defer userspace tests** to PI004 (after HIL validation complete)

**Why This Approach:**
- ✅ Builds on existing work (PI002 GPIO and timer implementations)
- ✅ Uses proven Tock patterns (loopback, test capsules)
- ✅ Practical and achievable (no complex userspace setup)
- ✅ Provides real hardware validation (not just unit tests)
- ✅ Creates foundation for future userspace tests

### 9.3 Confidence Level

**Overall Confidence: HIGH (90%)**

**Reasons:**
- ✅ Clear patterns exist in Tock codebase
- ✅ Hardware is well-documented and suitable
- ✅ Building on successful PI002 foundation
- ✅ Scope is well-defined and achievable
- ⚠️  Slight uncertainty around timing tolerances (need PO input)
- ⚠️  Userspace test complexity (correctly deferred)

---

## Appendices

### Appendix A: GPIO Pin Mapping Quick Reference

```
Loopback Pair 1 (Basic):
  GPIO5  (J1 pin 2)  ↔  GPIO6  (J1 pin 3)

Loopback Pair 2 (Interrupts):
  GPIO18 (J6 pin 8)  ↔  GPIO19 (J6 pin 9)

Loopback Pair 3 (Optional):
  GPIO20 (J6 pin 10) ↔  GPIO21 (J6 pin 11)

Manual Trigger:
  GPIO7  (J1 pin 4)  → 3.3V/GND for edge testing
```

### Appendix B: Test Output Examples

**Good Test Output:**
```
[TEST] gpio_interrupt_rising: start
[TEST] gpio_interrupt_rising: Setting GPIO18 as output, GPIO19 as input
[TEST] gpio_interrupt_rising: Enabling rising edge interrupt on GPIO19
[TEST] gpio_interrupt_rising: Triggering: GPIO18 LOW→HIGH
[TEST] gpio_interrupt_rising: Interrupt fired (count: 1)
[TEST] gpio_interrupt_rising: PASS
```

**Good Timer Output:**
```
[TEST] timer_alarm_accuracy: start
[TEST] timer_alarm_accuracy: Setting 100ms alarm
[TEST] timer_alarm_accuracy: Expected: 100000µs, Actual: 100023µs
[TEST] timer_alarm_accuracy: Error: 0.023% (within ±10% tolerance)
[TEST] timer_alarm_accuracy: PASS
```

### Appendix C: References

**Tock Documentation:**
- [Hardware CI Guide](tock/doc/TockHardwareCI.md)
- [Imix Test README](tock/boards/imix/src/test/README.md)

**Code References:**
- Test Capsules: `tock/capsules/core/src/test/`
- Board Tests: `tock/boards/imix/src/test/`
- Current ESP32-C6 Tests: `tock/boards/nano-esp32-c6/src/*_tests.rs`

**Hardware:**
- [nanoESP32-C6 Pinout](nanoESP32-C6/hardware/nanoesp32-c6-pinout.md)
- [ESP32-C6 TRM](nanoESP32-C6/doc/esp32-c6_technical_reference_manual_en.pdf)

---

**End of Research Report**

**Next Steps:**
1. Review this report with PO
2. Answer questions in USER_QUESTIONS.md
3. Get approval for sprint structure
4. Proceed to PI planning document
