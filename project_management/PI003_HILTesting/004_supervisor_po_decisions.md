# PI003_HILTesting - Product Owner Decisions Summary

**Supervisor:** @supervisor  
**Date:** 2026-02-12  
**Status:** APPROVED - Ready to Execute  

---

## PO Responses Summary

### Critical Decisions

#### Q1 & Q2: Hardware Availability ✅
**Decision:** YES - Hardware is ready
- nanoESP32-C6 board available
- Jumper wire connections completed:
  - GPIO5 → GPIO6 (basic loopback)
  - GPIO18 → GPIO19 (interrupt testing)

**Impact:** PI003 can proceed immediately

---

#### Q3: Sprint Structure ✅
**Decision:** 3-Sprint Structure (Option A - Recommended)
- SP001: GPIO Interrupt HIL Tests (Loopback-Based)
- SP002: Timer Alarm HIL Tests (Accuracy & Edge Cases)
- SP003: Test Infrastructure & Documentation

**Rationale:** Less overhead, more focused testing, matches two peripherals

---

#### Q4: Userspace Testing Scope ✅
**Decision:** Include userspace tests in PI003

**PO Notes:**
- "I added the two repositories to the workspace" (libtock-c, libtock-rs)
- **Prefer Rust testing** (libtock-rs)
- C can be used if reusing existing tests
- Contribution to libtock-rs is encouraged

**Impact:** 
- Expand PI003 scope to include userspace tests
- Focus on libtock-rs (Rust) over libtock-c
- May add 1-2 sprints for userspace testing
- **Revised Sprint Count:** Likely 4-5 sprints total

---

#### Q5: Timing Tolerance ✅
**Decision:** ±10% tolerance (recommended)

**PO Question:** "Not sure how do you plan to have the reference clock in order to make your reference checks."

**Supervisor Response:** 
- ESP32-C6 has internal XTAL (40 MHz) as reference
- Tock timer HIL uses this for alarm scheduling
- Tests will measure actual vs expected delay
- ±10% tolerance accounts for interrupt latency and scheduling overhead
- Example: 100ms alarm → accept 90-110ms

**Action:** Document reference clock approach in SP002 planning

---

#### Q6: Test Capsule Usage ✅
**Decision:** Use existing test capsules (recommended)

**PO Note:** "As much as possible we want to reuse tock best practice and not reinvent the wheel"

**Impact:** 
- Use TestRandomAlarm, TestAlarmEdgeCases from Tock core
- Follow proven test patterns
- Less custom code to maintain

---

### Test Infrastructure Decisions

#### Q7: Test Automation Level ✅
**Decision:** Level 2 - Python test harness

**PO Requirement:** "use uv for python environment management"

**Impact:**
- Build Python test harness in PI003 (not defer to PI004)
- Use `uv` for dependency management
- More robust than shell scripts
- Foundation for CI/CD integration

**Revised Scope:** SP003 will include Python harness development

---

#### Q8: Logic Analyzer Availability ✅
**Decision:** YES - Saleae logic analyzer available

**PO Note:** "I have a Salae LA, but we shouldn't require it for tests yet."

**Impact:**
- Logic analyzer available for debugging if needed
- Not required for test PASS/FAIL criteria
- Can be used for timing verification during development
- Document usage in troubleshooting guide

---

## Revised PI003 Structure

### Original Plan (3 Sprints)
1. SP001: GPIO Interrupt HIL Tests
2. SP002: Timer Alarm HIL Tests
3. SP003: Test Infrastructure & Documentation

### Revised Plan (5 Sprints) - Incorporating PO Decisions

1. **SP001: GPIO Interrupt HIL Tests (Board-Level)**
   - Hardware loopback validation
   - All 5 interrupt modes
   - Board tests only (kernel space)

2. **SP002: Timer Alarm HIL Tests (Board-Level)**
   - Timing accuracy with ±10% tolerance
   - Edge cases (0ms, 1ms, wraparound)
   - Use existing test capsules

3. **SP003: Python Test Harness**
   - Replace shell scripts with Python
   - Use `uv` for environment management
   - Serial port automation
   - PASS/FAIL reporting

4. **SP004: Userspace GPIO Tests (libtock-rs)**
   - Port GPIO tests to libtock-rs
   - Validate HIL from userspace
   - Contribute tests back to libtock-rs

5. **SP005: Userspace Timer Tests & Documentation**
   - Port timer tests to libtock-rs
   - Integration documentation
   - Test troubleshooting guide (including logic analyzer usage)

---

## Key Changes from Original Plan

| Aspect | Original | Revised | Reason |
|--------|----------|---------|--------|
| Sprint Count | 3 | 5 | Added userspace tests + Python harness |
| Userspace Tests | Deferred to PI004 | Included in PI003 | PO added repos to workspace |
| Test Language | N/A | Prefer Rust (libtock-rs) | PO preference |
| Automation | Shell scripts | Python with `uv` | PO requirement |
| Logic Analyzer | N/A | Available for debug | PO has Saleae LA |

---

## Success Criteria (Updated)

### Board-Level Tests (SP001-SP002)
- ✅ All GPIO interrupt modes validated via loopback
- ✅ Timer alarms accurate within ±10% tolerance
- ✅ Edge cases handled correctly
- ✅ Use existing Tock test capsules

### Userspace Tests (SP004-SP005)
- ✅ GPIO tests working in libtock-rs
- ✅ Timer tests working in libtock-rs
- ✅ Tests contributed back to libtock-rs repo

### Test Infrastructure (SP003)
- ✅ Python test harness with `uv`
- ✅ Automated serial port testing
- ✅ Clear PASS/FAIL reporting
- ✅ Documentation for logic analyzer usage (optional)

---

## Risk Assessment (Updated)

### New Risks from Scope Expansion

| Risk | Mitigation |
|------|------------|
| libtock-rs build complexity | Start with simple GPIO test, escalate if blocked |
| Python harness scope creep | Keep minimal for PI003, enhance in PI004 |
| Timing reference uncertainty | Document XTAL usage, validate with logic analyzer if needed |
| 5 sprints vs 3 (more overhead) | Each sprint is smaller, more focused |

### Mitigated Risks
- ✅ Hardware availability (confirmed)
- ✅ Test approach uncertainty (use existing capsules)
- ✅ Automation level (Python with `uv`)

---

## Approval

**Status:** ✅ **APPROVED**

**Supervisor Decision:** Proceed with revised 5-sprint structure

**Next Action:** Create SP001_GPIOInterruptHIL folder and delegate to @implementor

**Report Number for SP001:** 005 (next available)

---

## Notes for Team

1. **@implementor**: Focus on board-level tests first (SP001-SP002), userspace comes later
2. **@integrator**: Hardware setup complete, ready for testing
3. **@analyst**: May need research on libtock-rs build system before SP004
4. **@reviewer**: Watch for scope creep in Python harness (SP003)

---

**PI003 Status:** 🚀 **READY TO EXECUTE**
