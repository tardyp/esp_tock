# PI001/SP003 - Implementation Report #032

## Task: Add .text_gap Section to Fix Bootloader Segment Merging

**Date:** 2026-02-12  
**Status:** ✅ COMPLETE - Bootloader segment issue FIXED  
**Implementor:** TDD Agent  
**Sprint:** PI001/SP003 - Hardware Validation

---

## TDD Summary

- **Cycles:** 1 / target <15 ✅
- **Tests:** Hardware verification (segment count validation)
- **Result:** SUCCESS - Exactly 2 segments in bootloader range

### TDD Cycle 1: RED-GREEN-REFACTOR

**RED (Failing State):**
- Before fix: ESP image had only 1 segment in 0x42 range
- Bootloader expected exactly 2 segments
- Result: Bootloader assertion failure `rom_index == 2`

**GREEN (Passing State):**
- Added `.text_gap` section (36 bytes) after `.ARM.exidx` section
- ESP image now has exactly 2 segments in 0x42 range
- Bootloader successfully loads app and starts Tock kernel

**REFACTOR:**
- Added comprehensive comments explaining the fix
- Followed Embassy's proven pattern

---

## Files Modified

### `/Users/az02096/dev/perso/esp/esp_tock/tock/boards/nano-esp32-c6/tock_kernel_layout_esp32c6.ld`

**Location:** After line 203 (after `.ARM.exidx` section, before `.storage` section)

**Change:** Added `.text_gap` section to force a gap between segments:

```ld
/* ESP32-C6 FIX: Force gap to prevent espflash segment merging
 *
 * The ESP-IDF bootloader expects EXACTLY 2 segments in 0x42000000-0x43000000.
 * Without this gap, espflash merges contiguous .text and .storage into one.
 * Embassy uses the same technique (see esp32c6.x .text_gap section).
 *
 * The 36-byte gap (0x24) breaks contiguity, forcing espflash to create
 * separate segments for code (.text) and data (.storage).
 */
.text_gap (NOLOAD) : {
    . = . + 0x24;  /* 36 bytes gap, same as Embassy */
} > rom
```

---

## Quality Status

- ✅ **cargo build:** PASS (12.53s)
- ✅ **cargo fmt --check:** PASS (no formatting issues)
- ✅ **cargo clippy:** PASS (only expected unstable feature warning)
- ✅ **Segment verification:** PASS (exactly 2 segments in 0x42 range)
- ✅ **Hardware boot test:** PASS (bootloader loads app, Tock kernel starts)

---

## Verification Results

### Before Fix (Failing):
```
Segment count: 1
Entry point: 0x42000020
Segment 1: 0x42000020, 30176 bytes ** IN BOOTLOADER RANGE **
Segments in 0x42 range: 1 (need exactly 2)
❌ FAIL: Expected 2 segments, got 1
```

### After Fix (Success):
```
Segment count: 3
Entry point: 0x42000020
Segment 1: 0x42000020, 29744 bytes ** IN BOOTLOADER RANGE **
Segment 2: 0x00000000, 20 bytes
Segment 3: 0x42007474, 396 bytes ** IN BOOTLOADER RANGE **
Segments in 0x42 range: 2 (need exactly 2)
✅ SUCCESS: Exactly 2 segments in bootloader range!
```

### Gap Verification:
- Segment 1 ends at: 0x42000020 + 29744 = 0x42007450
- Segment 3 starts at: 0x42007474
- Gap size: 0x42007474 - 0x42007450 = 0x24 (36 bytes) ✅

---

## Hardware Boot Test Results

### Bootloader Output (SUCCESS):
```
[0;32mI (87) esp_image: segment 0: paddr=00010020 vaddr=42000020 size=07430h ( 29744) map[0m
[0;32mI (101) esp_image: segment 1: paddr=00017458 vaddr=00000000 size=00014h (    20) [0m
[0;32mI (103) esp_image: segment 2: paddr=00017474 vaddr=42007474 size=0018ch (   396) map[0m
[0;32mI (112) boot: Loaded app from partition at offset 0x10000[0m
[0;32mI (118) boot: Disabling RNG early entropy source...[0m

=== Tock Kernel Starting ===
Deferred calls initialized
```

### Key Success Indicators:
1. ✅ **No bootloader assertion error** - `rom_index == 2` check passed
2. ✅ **"Loaded app from partition at offset 0x10000"** - App loaded successfully
3. ✅ **"=== Tock Kernel Starting ==="** - Tock kernel initialization began
4. ✅ **"Deferred calls initialized"** - Kernel subsystems initializing

### Known Issue (Out of Scope):
The kernel panics during chip initialization:
```
panicked at ./chips/esp32-c6/src/chip.rs:72:51:
called `Result::unwrap()` on an `Err` value: ()
```

**This is a DIFFERENT issue** from the bootloader segment problem. The `.text_gap` fix has successfully resolved the bootloader segment merging issue. The panic is a separate chip initialization problem that needs to be addressed in a future task.

---

## Root Cause Analysis (Confirmed)

### Problem:
espflash merges contiguous ELF segments when creating the ESP image. Tock's `.text` section ended at 0x42007450, and `.storage` started at 0x42007450 (contiguous), so espflash merged them into a single segment.

### Solution:
Add a `.text_gap` section with NOLOAD attribute to create a 36-byte gap between `.text` and `.storage`. This breaks contiguity, preventing espflash from merging the segments.

### Why 36 bytes (0x24)?
- Embassy uses the same gap size in their proven working implementation
- Large enough to prevent merging
- Small enough to not waste significant flash space

### Why NOLOAD?
- The gap doesn't contain any actual data
- NOLOAD prevents the linker from allocating file space for it
- It only affects the virtual address layout, not the physical file

---

## Test Coverage

| Test | Purpose | Status |
|------|---------|--------|
| Segment count verification | Verify ESP image has exactly 2 segments in 0x42 range | ✅ PASS |
| Gap size verification | Verify 36-byte gap between segments | ✅ PASS |
| Bootloader load test | Verify bootloader loads app without assertion | ✅ PASS |
| Kernel start test | Verify Tock kernel begins initialization | ✅ PASS |

---

## Success Criteria (All Met)

- ✅ espflash image has exactly 2 segments in 0x42 range
- ✅ No bootloader assertion error
- ✅ "Loaded app from partition at offset 0x10000" appears
- ✅ "=== Tock Kernel Starting ===" appears

**Note:** "Hello World from Tock!" was not reached due to a separate chip initialization panic (out of scope for this task).

---

## Handoff Notes

### For Integrator:
The `.text_gap` fix is complete and working. The bootloader segment merging issue is **RESOLVED**. The bootloader now successfully loads the Tock kernel and begins execution.

### Next Steps (New Task Required):
The kernel panics during chip initialization at `chips/esp32-c6/src/chip.rs:72:51`. This is a **separate issue** from the bootloader segment problem and should be addressed in a new task:

```
panicked at ./chips/esp32-c6/src/chip.rs:72:51:
called `Result::unwrap()` on an `Err` value: ()
Last cause (mcause): Instruction access misaligned (interrupt=0, exception code=0x00000000)
```

This suggests an issue with interrupt vector setup or memory alignment in the chip initialization code.

### Files Changed:
- `tock/boards/nano-esp32-c6/tock_kernel_layout_esp32c6.ld` - Added `.text_gap` section

### Verification Command:
```bash
# Build
cd tock/boards/nano-esp32-c6 && make

# Verify segment count
espflash save-image --chip esp32c6 \
  target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board \
  /tmp/tock.bin

python3 -c "
import struct
with open('/tmp/tock.bin', 'rb') as f:
    header = f.read(24)
    seg_count = struct.unpack('<B', header[1:2])[0]
    flash_segs = 0
    for i in range(seg_count):
        seg = f.read(8)
        addr, size = struct.unpack('<II', seg)
        if 0x42000000 <= addr < 0x43000000:
            flash_segs += 1
        f.seek(size, 1)
    print(f'Segments in 0x42 range: {flash_segs}')
    assert flash_segs == 2, f'Expected 2, got {flash_segs}'
"
```

---

## Progress Report

### Session 1 - 2026-02-12
**Task:** Add .text_gap section to fix bootloader segment merging

### Completed
- [x] Loaded TDD and Tock kernel skills
- [x] Verified current failing state (1 segment in 0x42 range)
- [x] Added `.text_gap` section to linker script
- [x] Rebuilt kernel and verified segment count (2 segments)
- [x] Tested on hardware - bootloader successfully loads app
- [x] Verified Tock kernel starts
- [x] Documented fix with comprehensive comments

### TDD Metrics
- **Cycles used:** 1 / 15 budget ✅
- **Tests passing:** All verification tests pass
- **Red-Green-Refactor compliance:** 100%

### Quality Gates
- ✅ cargo build: PASS
- ✅ cargo fmt: PASS
- ✅ cargo clippy: PASS (only expected warnings)
- ✅ Hardware verification: PASS

### Struggle Points
None - fix was straightforward and worked on first attempt.

### Handoff Status
**READY FOR INTEGRATION** - The bootloader segment issue is fully resolved. A new task is needed to address the chip initialization panic.
