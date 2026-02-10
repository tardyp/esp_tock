# USER_QUESTIONS.md - PI001 Initial Boot

## Open Questions

### Q1: UART Implementation Timing
**Asked by:** @analyst
**Date:** 2026-02-10
**Context:** UART is critical for debugging boot process, but adds complexity to SP001
**Question:** Should we include basic UART initialization in SP001 (Foundation Setup) for early debugging, or defer it to SP002 (Memory Layout) and rely on other methods for SP001 verification?

**Recommendation:** Include UART in SP001 since we can reuse ESP32-C3 driver with minimal changes
**Trade-off:** Adds 1 day to SP001 but enables much better debugging throughout all sprints

**PO Response:**

UART is critical for debug, we might even add an "earlyboot" uart driver to debug the initialization part of the os.

---

### Q2: RGB LED Priority
**Asked by:** @analyst
**Date:** 2026-02-10
**Context:** nanoESP32-C6 has WS2812B RGB LED on GPIO16 for visual feedback
**Question:** Should we implement the WS2812B (RGB LED) driver in SP001 for visual boot confirmation, or defer to later PI?

**Recommendation:** Defer to later PI - WS2812B requires precise timing (RMT peripheral), complex for initial boot
**Alternative:** Use simple GPIO LED if board has one, or rely on UART

**PO Response:**
 
don't care about LED

---

### Q3: Testing Strategy Without Hardware Feedback
**Asked by:** @analyst
**Date:** 2026-02-10
**Context:** If we defer UART and RGB LED, how do we verify boot progress in early sprints?
**Question:** What testing strategy should we use?
- Option A: Include UART in SP001 (enables printf debugging)
- Option B: Use JTAG debugger to verify execution
- Option C: Trust build success and verify later with UART in SP002

**Recommendation:** Option A (UART in SP001) - most practical for iterative development

**PO Response:**


---

### Q4: Flash Memory Allocation
**Asked by:** @analyst
**Date:** 2026-02-10
**Context:** nanoESP32-C6 has 8MB flash (vs typical 2-4MB), giving us flexibility
**Question:** How should we allocate the 8MB flash?
- **Option A (Conservative):** 128KB kernel, 256KB apps (matches ESP32-C3)
- **Option B (Moderate):** 256KB kernel, 512KB apps (use extra space)
- **Option C (Aggressive):** 512KB kernel, 1MB apps (maximum flexibility)

**Recommendation:** Option B - allows larger kernel features and apps without waste

**PO Response:**

B

---

### Q5: Rust Toolchain Version
**Asked by:** @analyst
**Date:** 2026-02-10
**Context:** ESP32-C6 uses RV32IMAC (adds atomics), may need specific toolchain
**Question:** Which Rust toolchain should we target?
- Current Tock uses: stable or nightly?
- Do we need specific version for RISC-V atomics?
- Any constraints from existing Tock builds?

**Recommendation:** Match existing Tock RISC-V targets (check existing chips/sifive, chips/lowrisc)

**PO Response:**

as RV32IMAC is retrocompatible with C3 architecture, for initial PI I would prefer to keep the same toolchain as c3.

---

## Summary for PO

The @analyst has completed PI001 planning with 8 sprints estimated at **4-5 weeks part-time** or **2-3 weeks full-time**.

**Most Critical Decision:** Q1 + Q3 are related - should we include UART in SP001 for debugging? This significantly impacts our ability to verify progress throughout the PI.

**Recommended Path:** 
- ✅ Include UART in SP001 (Q1: Yes)
- ✅ Defer RGB LED to later PI (Q2: No)
- ✅ Use 256KB kernel / 512KB apps allocation (Q4: Option B)
- ✅ Match existing Tock RISC-V toolchain (Q5: Check current setup)

**Ready to proceed once you provide guidance on these questions.**
