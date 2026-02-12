# PI001/SP003 - Implementation Report 030: Linker Script Fix Attempt

## TDD Summary
- Tests written: 1 (verify_segments.sh)
- Tests passing: 0 (target: 2 segments, actual: 3 segments)
- Cycles: 20+ / target <15 ⚠️ **STRUGGLE POINT**

## Task
Fix linker script to add .text_gap section for bootloader compatibility.
Target: Exactly 2 LOAD segments in flash range (0x42000000-0x43000000).

## Files Modified
- `tock/boards/nano-esp32-c6/layout.ld` - Modified memory regions and attempted section overrides
- `tock/boards/nano-esp32-c6/verify_segments.sh` - Created test script (NEW)

## Current State

### Segment Count Progress
- **Initial:** 4 segments (.text, .storage, .apps, .attributes)
- **Current:** 3 segments (.text, .storage, .attributes)
- **Target:** 2 segments (IROM, DROM)

### What Worked ✓
1. **Moved .apps outside scan range:** Changed `prog` region from 0x42040000 to 0x3C000000
   - Result: .apps no longer counted by bootloader (4 → 3 segments)

### What Didn't Work ✗
1. **INSERT directive:** `INSERT AFTER .ARM.exidx` - section not created
2. **INSERT BEFORE .storage:** - section not created  
3. **PHDRS directive:** Conflicted with INCLUDE, linker errors
4. **/DISCARD/ section:** Didn't remove .attributes from INCLUDE
5. **Shrinking ROM region:** Changed PhysAddr but not VirtAddr (still in scan range)
6. **Overriding .attributes:** Created duplicate section instead of replacing

### Root Cause
**Cannot override sections defined in `INCLUDE tock_kernel_layout.ld` using directives that come AFTER the INCLUDE.**

The `.attributes` section is defined in `tock_kernel_layout.ld` (line 382) with:
```ld
.attributes : AT (ORIGIN(rom) + LENGTH(rom) - SIZEOF(.attributes))
```

The `AT()` directive places .attributes at the end of ROM (0x42007fd4), creating a gap from .storage (0x42007450), which forces a new LOAD segment.

## Attempted Solutions

### Cycle Summary
| Cycle | Approach | Result |
|-------|----------|--------|
| 1-2 | Created test script | ✓ Test works, confirms 4 segments |
| 3-4 | INSERT AFTER .text | ✗ Section not created |
| 5-6 | INSERT BEFORE .storage | ✗ Section not created |
| 7-8 | PHDRS directive | ✗ Linker errors |
| 9-10 | Move prog region | ✓ Reduced to 3 segments |
| 11-12 | Move .attributes to new region | ✗ Duplicate section created |
| 13-14 | /DISCARD/ .attributes | ✗ Original section still present |
| 15-16 | Shrink ROM to push .attributes out | ✗ VirtAddr still in range |
| 17-18 | Override .attributes definition | ✗ Both sections included |
| 19-20 | Test current 3-segment binary | ? Flash succeeded, boot unknown |

## Technical Analysis

### Current Segment Layout
```
Segment 1: 0x42000020 - .text (R E) - IROM ✓
Segment 2: 0x42007450 - .storage (R) - DROM (partial) ✓
Segment 3: 0x42007600 - .attributes (R) - Should merge with Segment 2 ✗
```

### Why .storage and .attributes are Separate
1. **Different section flags:** .text has `AXMSR`, .storage has `A`
2. **Gap created by AT():** .attributes placed at end of ROM, not contiguous
3. **Linker behavior:** Non-contiguous sections with same flags → separate segments

### Possible Solutions (Not Attempted)
1. **Custom linker script:** Replace `INCLUDE tock_kernel_layout.ld` with full custom script
   - Risk: High (might break Tock assumptions)
   - Effort: High (473 lines to copy/modify)
   
2. **Modify tock_kernel_layout.ld:** Remove AT() from .attributes
   - Risk: Medium (affects all boards)
   - Effort: Medium (need to test all Tock boards)

3. **Test if 3 segments actually works:** ESP-IDF bootloader might be more lenient
   - Risk: Low (just testing)
   - Effort: Low (hardware test)

## Quality Status
- cargo build: PASS
- cargo test: N/A (no unit tests for linker scripts)
- cargo clippy: N/A
- cargo fmt: N/A
- Segment verification: FAIL (3 segments, target 2)

## Hardware Test Result
- Flash: ✓ SUCCESS
- ESP-IDF bootloader: ✓ Started loading
- Tock kernel boot: ? UNKNOWN (monitor failed in non-interactive mode)

## Struggle Point Documentation

**Issue:** Cannot achieve 2-segment layout using board-specific linker script overrides

**Cycles:** 20+ (exceeded target of 15)

**Blockers:**
1. `INSERT` directive doesn't work with `INCLUDE` files
2. Cannot override sections defined in `INCLUDE` from board-specific script
3. `.attributes` section uses `AT()` directive that creates mandatory gap

**Resolution Options:**
1. **Escalate to Analyst:** Request architecture decision on modifying tock_kernel_layout.ld
2. **Test current state:** Verify if 3 segments actually prevents boot
3. **Custom linker script:** Full replacement of INCLUDE (high risk)

## Recommendation

**PAUSE and ESCALATE to Supervisor**

Reasons:
1. Exceeded cycle budget (20+ vs target <15)
2. Fundamental architectural issue (cannot override INCLUDE sections)
3. Need decision: Modify core Tock files vs board-specific workaround
4. Unknown if 3 segments actually prevents boot (need hardware validation)

**Next Steps:**
1. Supervisor: Decide on approach (modify core vs workaround vs test-as-is)
2. If test-as-is: Need interactive hardware test to see actual boot behavior
3. If modify core: Analyst to design tock_kernel_layout.ld changes
4. If workaround: Implementor to create full custom linker script

## Handoff Notes

**For Supervisor:**
- Current binary flashes successfully
- ESP-IDF bootloader starts
- Unknown if Tock kernel reaches entry point
- Need hardware test with interactive monitor to see boot logs

**For Integrator:**
- If 3 segments is acceptable, current changes are ready:
  - `prog` region moved to 0x3C000000
  - `rom` region set to 32KB
  - Test script created at `verify_segments.sh`

**For Analyst:**
- If core modification needed, target is `.attributes` section in tock_kernel_layout.ld line 382
- Remove `AT()` directive to make .attributes contiguous with .storage
- This will affect all Tock boards - need compatibility analysis

---

**Status:** BLOCKED - Awaiting supervisor decision on approach
**Cycle Count:** 20+ (struggle point)
**Date:** 2026-02-12
