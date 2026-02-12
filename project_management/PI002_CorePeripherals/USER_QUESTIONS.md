# PI002 - Questions for Product Owner

**Date:** 2026-02-12  
**PI:** PI002_CorePeripherals  
**Analyst:** Analyst Agent

---

## Q1: Sprint Scope Confirmation

**Priority:** HIGH  
**Blocking:** Sprint planning

**Question:**
The proposed sprint breakdown has 5 sprints. Is this acceptable, or should we consolidate/split any sprints?

**Context:**
- SP001: Watchdog & Clock (critical stability) - 15-20 iterations
- SP002: INTC (critical for interrupts) - 25-30 iterations
- SP003: Timers (builds on SP001+SP002) - 20-25 iterations
- SP004: GPIO (builds on SP001+SP002) - 20-25 iterations
- SP005: Console (builds on SP002) - 15-20 iterations

**Total Estimated Effort:** 95-120 iterations (6-12 days)

**Options:**
- **A:** Keep 5 sprints as proposed (recommended)
- **B:** Combine SP003+SP004 into single "Peripherals" sprint
- **C:** Split SP002 into INTMTX and INTPRI sprints

**Recommendation:** Option A - 5 sprints provides good granularity and clear milestones. Each sprint has a focused goal and clear success criteria.

**Impact if not answered:**
- Cannot proceed with sprint planning
- Implementor unclear on scope boundaries

---

## Q2: PMP Implementation Priority

**Priority:** MEDIUM  
**Blocking:** PI scope definition

**Question:**
Issue #5 (HIGH) - PMP disabled for userspace memory protection. Should this be included in PI002 or deferred to PI003?

**Context:**
- **Current:** SimplePMP<0> (0 regions, no protection)
- **Issue:** No userspace memory protection - cannot safely run untrusted code
- **Complexity:** Requires SkipLockedPMP implementation to work around bootloader-locked entries
- **Effort:** Estimated 20-25 iterations (2-3 weeks)

**Options:**
- **A:** Include in PI002 as SP006 (adds 2-3 weeks to PI002)
- **B:** Defer to PI003 "Security & Isolation" (recommended)
- **C:** Implement minimal PMP in SP001 (quick fix, may not be robust)

**Recommendation:** Option B - Defer to PI003. 

**Rationale:**
- PI002 focus is peripheral functionality, not security
- PMP is important but not blocking for peripheral development
- Can develop and test peripherals without userspace processes
- Dedicated PI003 allows proper security architecture design

**Impact if not answered:**
- Scope creep risk if PMP added to PI002
- Issue #5 remains open longer if deferred

---

## Q3: Testing Strategy

**Priority:** MEDIUM  
**Blocking:** Sprint success criteria definition

**Question:**
Should we create hardware-in-the-loop (HIL) tests for each peripheral, or rely on manual testing?

**Context:**
- **Current:** 11/11 tests passing (build/compile tests only)
- **Need:** Functional tests for peripheral behavior
- **Complexity:** Automated tests require test harness, may be brittle
- **Value:** Automated tests catch regressions, enable CI/CD

**Options:**
- **A:** Create automated HIL tests for each peripheral (adds time but high value)
- **B:** Manual testing with documented test procedures (faster, less robust)
- **C:** Hybrid: automated for critical (timers, interrupts), manual for others (recommended)

**Recommendation:** Option C - Hybrid approach

**Rationale:**
- Critical peripherals (timers, interrupts) benefit from automation
- Manual testing acceptable for GPIO, console (visual verification)
- Balances thoroughness with development speed
- Can add more automation in future PIs

**Proposed Automated Tests:**
- Timer: Verify alarm fires at correct time
- INTC: Verify interrupt routing and priority
- Watchdog: Verify disable prevents resets

**Proposed Manual Tests:**
- GPIO: Toggle output, verify with LED
- Console: Send/receive data, verify output
- Clock: Verify peripheral clocks enabled

**Impact if not answered:**
- Unclear success criteria for sprints
- May over-invest or under-invest in testing

---

## Q4: RGB LED Priority

**Priority:** LOW  
**Blocking:** SP004 scope

**Question:**
Should we implement WS2812B RGB LED driver in SP004 (GPIO) for visual debugging?

**Context:**
- **Hardware:** nanoESP32-C6 has RGB LED on GPIO16
- **Requirements:** RMT peripheral or bit-banging driver
- **Value:** Excellent visual feedback for debugging (boot stages, errors, status)
- **Complexity:** Moderate (signal timing, GRB order, inverted signal via BSS138)
- **Effort:** 5-8 iterations

**Options:**
- **A:** Include in SP004 (adds 1-2 iterations to sprint)
- **B:** Create separate SP006 for RGB LED (dedicated sprint)
- **C:** Defer to PI003 or later (recommended)

**Recommendation:** Option C - Defer to later PI

**Rationale:**
- RGB LED is nice-to-have, not essential for core functionality
- Simple GPIO toggle can provide visual feedback for now
- RMT peripheral driver is significant undertaking
- Focus PI002 on essential peripherals

**Alternative:**
- Use simple GPIO toggle on available pin for basic visual feedback
- Implement full RGB LED driver in PI003 "Advanced Peripherals"

**Impact if not answered:**
- SP004 scope unclear
- May waste time on non-essential feature

---

## Q5: Documentation Depth

**Priority:** LOW  
**Blocking:** Definition of done

**Question:**
How much documentation should accompany each sprint?

**Context:**
- **Need:** Driver documentation, register documentation, usage examples
- **Trade-off:** Documentation time vs. implementation time
- **Audience:** Future developers, maintainers, users

**Options:**
- **A:** Minimal: Code comments only (fastest)
- **B:** Moderate: Code comments + README per driver (recommended)
- **C:** Comprehensive: Code comments + README + usage guide + register reference (thorough)

**Recommendation:** Option B - Moderate documentation

**Rationale:**
- Code comments explain implementation details
- README provides overview and usage examples
- Register reference can be generated from TRM
- Balances documentation value with time investment

**Proposed Documentation per Driver:**
- **Code comments:** Explain non-obvious logic, cite TRM sections
- **README.md:** Overview, features, usage example, register summary
- **No separate usage guide** (can be added later if needed)

**Example Structure:**
```
tock/chips/esp32-c6/src/
├── pcr.rs              # Code with inline comments
├── pcr_README.md       # Overview and usage
├── intc.rs             # Code with inline comments
└── intc_README.md      # Overview and usage
```

**Impact if not answered:**
- Unclear "definition of done" for each sprint
- May under-document or over-document

---

## Summary

**MUST ANSWER:**
- Q1: Sprint scope (blocks sprint planning)

**SHOULD ANSWER:**
- Q2: PMP priority (defines PI002 scope)
- Q3: Testing strategy (defines success criteria)

**NICE TO ANSWER:**
- Q4: RGB LED (clarifies SP004 scope)
- Q5: Documentation (clarifies definition of done)

**Recommended Answers:**
- Q1: Option A (5 sprints)
- Q2: Option B (defer PMP to PI003)
- Q3: Option C (hybrid testing)
- Q4: Option C (defer RGB LED)
- Q5: Option B (moderate documentation)

**PO Answers:**
- Q1: Option A (5 sprints)
- Q2: Option B (defer PMP to PI003)
- Q3: Option A (Full automated testing)
- Q4: Option C (defer RGB LED)
- Q5: Option B (moderate documentation)

---

**Next Steps:**
1. ✅ PO reviewed questions
2. ✅ PO provided answers (2026-02-12)
3. ✅ Sprint plans confirmed based on answers
4. ▶️ Implementor begins SP001_WatchdogClock

**PO Decision Summary:**
- **Sprint Structure:** 5 sprints as proposed (Q1: Option A)
- **PMP Priority:** Deferred to PI003 (Q2: Option B) - Issue #5 remains open
- **Testing Strategy:** Full automated testing for all peripherals (Q3: Option A) ⚠️ More comprehensive than analyst recommendation
- **RGB LED:** Deferred to later PI (Q4: Option C)
- **Documentation:** Moderate - code comments + README per driver (Q5: Option B)

**Impact of PO Decisions:**
- Q3 (Full automated testing): Will add 5-10 iterations per sprint for test harness development
- Updated sprint estimates: 110-150 iterations total (vs original 95-120)
- Testing infrastructure will be reusable for future PIs (high long-term value)
