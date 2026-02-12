# Summary for PO - USB-JTAG Serial Analysis

## Bottom Line Up Front

**Problem**: Bootloader still failing with "Assert failed in unpack_load_app, bootloader_utility.c:769 (rom_index == 2)"

**Root Cause**: 
1. Our test monitors USB-JTAG serial, but we configured UART0 (wrong interface)
2. ESP-IDF bootloader is still running (espflash adds it automatically)
3. Our ELF format doesn't match bootloader expectations

**Solution**: Implement USB-JTAG serial driver (4-6 hours) to get "Hello World" working

---

## Key Findings

### 1. Embassy Does NOT Bypass Bootloader

Embassy uses the SAME approach as us (`espflash flash`), which automatically adds ESP-IDF bootloader. There is no "direct boot" - embassy works WITH the bootloader.

**Implication**: We should keep the bootloader approach (it's proven to work).

### 2. USB-JTAG is Simple and Ready

- ✅ NO initialization needed (ROM bootloader sets it up)
- ✅ NO GPIO muxing needed (built-in USB interface)
- ✅ Just 2 registers: FIFO and CONF
- ✅ Reference implementation available (esp-println crate)

**Implication**: USB-JTAG is the fastest path to working serial output.

### 3. Test Infrastructure Uses USB-JTAG

Our test script monitors `/dev/tty.usbmodem*` (USB-JTAG), but we configured UART0 on GPIO16/17. This is why we see no output despite correct UART initialization.

**Implication**: Must implement USB-JTAG to match test infrastructure.

---

## Recommended Path Forward

### Phase 1: USB-JTAG "Hello World" (4-6 hours)
**Goal**: Prove kernel boots successfully

**Implementation**:
1. Create USB-JTAG driver (copy from esp-println)
2. Update io.rs to use USB-JTAG
3. Add early debug output
4. Test and verify

**Expected Result**: "Hello World" appears on serial monitor

**Risk**: Low (proven reference implementation)

### Phase 2: Fix Bootloader Issue (6-8 hours)
**Goal**: Eliminate bootloader assertion error

**Investigation**:
1. Compare ELF segments with embassy
2. Adjust linker script if needed
3. Fix segment layout

**Expected Result**: Clean boot without bootloader errors

**Risk**: Medium (need to understand ESP-IDF bootloader requirements)

### Phase 3: Dual Serial Support (2-3 hours)
**Goal**: Support both USB-JTAG and UART0

**Implementation**:
- USB-JTAG for kernel debug
- UART0 for userspace console
- Runtime selection

**Expected Result**: Flexible serial configuration

**Risk**: Low (both drivers already work)

---

## Questions for PO

### 1. Priority: Which first?
- **Option A**: USB-JTAG first (get output working, enables debugging)
- **Option B**: Fix bootloader first (clean boot, but blind debugging)

**Recommendation**: USB-JTAG first (need working debug output to fix bootloader)

### 2. Serial Strategy?
- **Option A**: USB-JTAG only (simpler)
- **Option B**: Dual USB-JTAG + UART0 (more flexible)

**Recommendation**: USB-JTAG for debug, UART0 for production later

### 3. Bootloader Approach?
- **Option A**: Keep ESP-IDF bootloader (matches embassy, proven)
- **Option B**: Pursue true direct boot (more work, uncertain)

**Recommendation**: Keep ESP-IDF bootloader (it works for embassy)

---

## Timeline

**Phase 1** (USB-JTAG): 4-6 hours
- Implementation: 3-4 hours
- Testing: 1-2 hours

**Phase 2** (Bootloader fix): 6-8 hours
- Investigation: 2-3 hours
- Implementation: 2-3 hours
- Testing: 2 hours

**Phase 3** (Dual serial): 2-3 hours
- Implementation: 1-2 hours
- Testing: 1 hour

**Total**: 12-17 hours

**Can deliver Phase 1 in one work session** (USB-JTAG "Hello World")

---

## Success Criteria

### Phase 1 Success:
- [ ] "Hello World" appears on USB-JTAG serial
- [ ] Test script detects output
- [ ] No kernel panic
- [ ] Repeatable after reset

### Phase 2 Success:
- [ ] No bootloader assertion errors
- [ ] Clean boot sequence
- [ ] Stable operation

### Phase 3 Success:
- [ ] Both USB-JTAG and UART0 work
- [ ] Configurable at build time
- [ ] No conflicts

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| USB-JTAG not initialized | Low | High | Add init code if needed |
| Bootloader fix complex | Medium | High | Debug with working serial |
| FIFO timeout hangs | Medium | Medium | Add timeout counter |
| Register addresses wrong | Low | High | Cross-ref with TRM |

**Overall Risk**: Low for Phase 1, Medium for Phase 2

---

## Deliverables

### Analysis Report (DONE)
- Complete USB-JTAG register documentation
- Step-by-step implementation guide
- Code examples from esp-println
- Risk analysis

### Implementation Plan (READY)
- File-by-file changes documented
- Code snippets provided
- Test strategy defined
- Success criteria clear

### Next: Implementation
- Ready to hand off to implementor
- All questions answered
- Clear path forward

---

## Recommendation

**Proceed with Phase 1 (USB-JTAG) immediately.**

This will:
1. ✅ Prove kernel boots successfully
2. ✅ Enable debugging for bootloader fix
3. ✅ Match test infrastructure
4. ✅ Deliver visible progress quickly

The implementation is straightforward (copy from working reference), low-risk, and provides immediate value.

---

**Status**: Analysis complete. Ready for implementation.

**Estimated Time to "Hello World"**: 4-6 hours of implementation time.
