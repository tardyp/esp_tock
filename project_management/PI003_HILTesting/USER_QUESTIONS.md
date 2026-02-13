# PI003_HILTesting - Questions for Product Owner

**Analyst:** @analyst  
**Date:** 2026-02-12  
**Status:** AWAITING PO RESPONSE  

---

## Critical Questions (Block Sprint Start)

### Q1: Hardware Availability
**Question:** Do you have the nanoESP32-C6 board physically available for hardware testing?

**Context:** PI003 requires physical GPIO loopback connections (jumper wires connecting GPIO pins). This is hardware-in-the-loop testing, not simulation.

**Impact:** If board not available, we cannot proceed with HIL testing.

**Options:**
- [x] Yes, board is available → Proceed with PI003
- [ ] No, board not available → Defer PI003 until hardware arrives
- [ ] Board available but not accessible → Consider remote testing setup

---

### Q2: Jumper Wire Availability
**Question:** Do you have 2-3 female-to-female jumper wires for GPIO loopback connections?

**Context:** Tests require physically connecting GPIO pins:
- GPIO5 → GPIO6 (basic loopback)
- GPIO18 → GPIO19 (interrupt testing)

**Impact:** Without jumper wires, loopback tests cannot be performed.

**Required Materials:**
- 2-3 female-to-female jumper wires (standard breadboard wires, ~10cm)
- Optional: Small breadboard for organizing connections
- Optional: Multimeter for verifying connections

**Cost:** ~$2-5 for a pack of jumper wires


USER ==> Yes, the two suggested connections are done.

---

## Sprint Structure Questions (Affects Planning)

### Q3: Sprint Count Preference
**Question:** Do you prefer 3-sprint or 5-sprint structure for PI003?

**Context:** Research shows two main peripherals to test (GPIO, Timer). Analyst recommends **3 sprints**:

**Option A: 3-Sprint Structure (Recommended)**
- SP001: GPIO Interrupt HIL Tests (Loopback-Based)
- SP002: Timer Alarm HIL Tests (Accuracy & Edge Cases)
- SP003: Test Infrastructure & Documentation

**Advantages:**
- ✅ Less overhead (fewer handoffs)
- ✅ More focused testing per sprint
- ✅ Matches two peripherals (GPIO + Timer)
- ✅ Allows deeper validation

**Option B: 5-Sprint Structure (More Granular)**
- SP001: GPIO Loopback Enhancement
- SP002: GPIO Level Interrupts
- SP003: Timer Edge Cases
- SP004: Multi-Alarm Testing
- SP005: Test Infrastructure

**Advantages:**
- ✅ Smaller, more incremental deliveries
- ✅ More checkpoints
- ❌ More overhead

**Your Preference:**
- [x] Option A: 3 sprints (recommended)
- [ ] Option B: 5 sprints (more granular)
- [ ] Other: _______________

---

### Q4: Userspace Testing Scope
**Question:** Should userspace test applications be included in PI003, or deferred to PI004?

**Context:** 
- **Userspace tests** = Test applications compiled with libtock-c, run in process space
- **Board tests** = In-kernel tests, faster to develop and run
- **Finding:** Userspace tests require setting up libtock-c build environment (significant complexity)

**Analyst Recommendation:** **Defer userspace tests to PI004**

**Rationale:**
1. Board-level tests provide sufficient HIL validation
2. Userspace tests require additional infrastructure (libtock-c, build system)
3. Focus PI003 on core HIL validation
4. Add userspace tests in PI004 after HIL is proven

**Your Decision:**
- [ ] Defer userspace tests to PI004 (recommended)
- [x] Include userspace tests in PI003 (add ~2 sprints)
- [ ] Skip userspace tests entirely

USER: I added the two repositories to the workspace.

Prefer Rust testing!
C can be used if we just reuse already made tests.
contribution to libtock-rs is possible and encouraged.

---

## Testing Criteria Questions (Affects Acceptance)

### Q5: Timing Tolerance for Timer Tests
**Question:** What timing accuracy is acceptable for timer alarm tests?

**Context:** 
- Tock's TestRandomAlarm uses ±50ms tolerance
- ESP32-C6 crystal: ±20ppm accuracy
- Interrupt latency: ~10-20µs
- Analyst recommendation: **±10% tolerance** for millisecond-range delays

**Examples:**
- 100ms alarm: Accept 90-110ms (±10%)
- 1000ms alarm: Accept 900-1100ms (±10%)
- 10ms alarm: Accept 9-11ms (±10%)

**Your Preference:**
- [x] ±10% tolerance (recommended, generous)
- [ ] ±5% tolerance (tighter, may be challenging)
- [ ] ±1% tolerance (very tight, may fail due to interrupt latency)
- [ ] Other: _______________


USER: Not sure how do you plan to have the reference clock in order to make you reference checks.

---

### Q6: Test Capsule Usage
**Question:** Should we use existing Tock test capsules (TestRandomAlarm, TestAlarmEdgeCases) or write custom tests?

**Context:**
- **Existing capsules:** Proven, well-tested, used by other boards
- **Custom tests:** More control, specific to ESP32-C6 needs

**Analyst Recommendation:** **Use existing test capsules**

**Rationale:**
1. Proven test patterns from Tock core team
2. Used successfully on other platforms
3. Less code to write and maintain
4. Standard validation approach

**Your Preference:**
- [X] Use existing test capsules (recommended)
- [ ] Write custom tests
- [ ] Hybrid: Use existing + add custom tests

USER: As much as possible we want to reuse tock best practice and not reinvent the wheel

---

## Nice-to-Have Questions (Don't Block Progress)

### Q7: Test Automation Level
**Question:** How automated should the tests be?

**Current State:** Shell script greps serial output for PASS/FAIL

**Options:**
- **Level 1 (Current):** Shell script + grep
- **Level 2:** Python test harness (tock-hardware-ci framework)
- **Level 3:** CI/CD integration with automated hardware testing

**Analyst Recommendation:** **Level 1 for PI003**, Level 2 for PI004

**Your Preference:**
- [ ] Level 1: Shell script (current, sufficient for PI003)
- [x] Level 2: Python harness (more robust, more work)
- [ ] Level 3: Full CI/CD (future goal)

USER: use uv for python environment management.

---


### Q8: Logic Analyzer Availability
**Question:** Do you have a logic analyzer for timing verification?

**Context:** Logic analyzer can verify:
- Exact interrupt timing
- GPIO signal integrity
- Timer accuracy

**Impact:** 
- **Not required** for basic HIL testing
- **Nice to have** for debugging timing issues

**Your Response:**
- [x] Yes, have logic analyzer
- [ ] No, don't have logic analyzer
- [ ] Not needed for PI003

I have a Salae LA, but we shouln't require it for tests yet.

---

## Summary of Recommendations

**Analyst Recommendations:**
1. ✅ **3-sprint structure** (not 5)
2. ✅ **Defer userspace tests** to PI004
3. ✅ **±10% timing tolerance** for timer tests
4. ✅ **Use existing test capsules** (TestRandomAlarm, etc.)
5. ✅ **Shell script automation** for PI003 (Python harness in PI004)

**Critical Blockers:**
- ❗ **Hardware availability** (Q1, Q2) - Must have board + jumper wires

**Decisions Needed:**
- 🔸 Sprint structure (Q3)
- 🔸 Userspace testing scope (Q4)
- 🔸 Timing tolerance (Q5)

---

## PO Response Section

Response inline

---

## Additional Notes/Questions from PO

```
[Add any additional questions, concerns, or requirements here]
```

---

## SP001 Implementation Questions

### Q9: GPIO18→GPIO19 Connection Verification
**Question:** Can you verify the GPIO18→GPIO19 jumper wire is physically connected?

**Context:** 
- In Q2, you confirmed "the two suggested connections are done"
- Test results show GPIO19 reads LOW when GPIO18 is HIGH
- This indicates the jumper wire is NOT connected or has poor contact

**Diagnostic Test:**
```bash
cd tock/boards/nano-esp32-c6
./test_gpio_interrupts.sh
```

**Expected Output (if connected):**
```
[GI-001] Rising Edge
PASS (count=1)
```

**Current Output (not connected):**
```
[GI-001] Rising Edge
FAIL (count=0)
```

**Required Action:**
1. Physically verify jumper wire: GPIO18 (J6 pin 8) → GPIO19 (J6 pin 9)
2. Ensure good contact (may need to reseat wire)
3. Run test script and report results

**Impact:** Blocks SP001 progress until resolved

**Your Response:**
- [ ] Wire is connected, verified
- [ ] Wire was not connected, now connected
- [ ] Need help identifying pins
- [ ] Other: _______________

---

**Status:** ✅ APPROVED - PI003 Started, SP001 In Progress

**Next Step:** Resolve Q9 hardware connection issue to unblock SP001
