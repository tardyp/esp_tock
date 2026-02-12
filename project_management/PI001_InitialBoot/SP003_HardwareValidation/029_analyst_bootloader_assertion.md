# PI001/SP003 - Analysis Report #029

**Date:** 2026-02-12  
**Analyst:** Analyst Agent  
**Topic:** ESP-IDF Bootloader Assertion "rom_index == 2" Error

---

## Executive Summary

**ROOT CAUSE IDENTIFIED:** ESP-IDF bootloader expects **exactly 2 flash-mapped segments** (IROM and DROM), but Tock's linker script produces **4 flash segments** due to missing segment gap between `.text` and `.storage` sections.

**IMPACT:** Bootloader crashes before jumping to our code despite successfully loading the binary.

**FIX REQUIRED:** Add `.text_gap` section to force linker to create separate LOAD segments for code and data, matching ESP32-C6 bootloader expectations.

---

## Research Summary

### 1. Bootloader Assertion Analysis

**Source:** `esp-idf/components/bootloader_support/src/bootloader_utility.c:769`

```c
static void unpack_load_app(const esp_image_metadata_t *data)
{
    uint32_t rom_addr[2] = {};
    uint32_t rom_load_addr[2] = {};
    uint32_t rom_size[2] = {};
    int rom_index = 0;  //shall not exceed 2

    // Find DROM & IROM addresses, to configure MMU mappings
    for (int i = 0; i < data->image.segment_count; i++) {
        const esp_image_segment_header_t *header = &data->segments[i];
        //`SOC_DROM_LOW` and `SOC_DROM_HIGH` are the same as `SOC_IROM_LOW` and `SOC_IROM_HIGH`
        if (header->load_addr >= SOC_DROM_LOW && header->load_addr < SOC_DROM_HIGH) {
            /**
             * D/I are shared, but there should not be a third segment on flash
             */
            assert(rom_index < 2);
            rom_addr[rom_index] = data->segment_data[i];
            rom_load_addr[rom_index] = header->load_addr;
            rom_size[rom_index] = header->data_len;
            rom_index++;
        }
    }
    assert(rom_index == 2);  // <<<< THIS IS WHERE WE CRASH
```

**Key Insight:** On ESP32-C6 with shared D/I cache (`SOC_MMU_DI_VADDR_SHARED`), the bootloader:
1. Scans all LOAD segments in flash range `0x42000000 - 0x43000000`
2. Expects **exactly 2 segments**: IROM (code) and DROM (read-only data)
3. Configures MMU mappings for these two segments
4. **Asserts if rom_index != 2**

**ESP32-C6 Flash Range:**
- `SOC_IROM_LOW = 0x42000000`
- `SOC_IROM_HIGH = 0x42000000 + (0x10000 << 8) = 0x43000000` (16 MB)
- `SOC_DROM_LOW/HIGH` are **identical** (shared D/I cache)

---

## Segment Comparison: Tock vs Embassy

### Embassy (Working) - 3 Flash Segments, 2 in Range

```
LOAD  0x001020  0x42000020  0x42000020  0x08b38  0x08b38  R E  0x1000  [.text]
LOAD  0x00a000  0x40800000  0x40800000  0x00cec  0x00cec  R E  0x1000  [.trap .rwtext]
LOAD  0x00bb58  0x42008b58  0x42008b58  0x02c9c  0x02c9c  R    0x1000  [.text_gap .rodata]
LOAD  0x00ecf0  0x40800cf0  0x4200b7f8  0x00020  0x00020  RW   0x1000  [.data]
LOAD  0x00ed10  0x40800d10  0x40800d10  0x00000  0x00348  RW   0x1000  [.bss]
```

**Flash segments (0x42xxxxxx):**
1. **Segment 1:** `0x42000020` - `.text` (executable code) - **IROM**
2. **Segment 3:** `0x42008b58` - `.text_gap + .rodata` (read-only data) - **DROM**

**Result:** `rom_index = 2` ✅ Bootloader happy!

---

### Tock (Broken) - 6 Flash Segments, 4 in Range

```
LOAD  0x000154  0x42000020  0x42000020  0x07430  0x07430  R E  0x4     [.text]
LOAD  0x007584  0x42007450  0x42007450  0x001b0  0x001b0  R    0x1     [.storage]
LOAD  0x007734  0x40800000  0x40800000  0x00000  0x00900  RW   0x1     [.stack]
LOAD  0x007734  0x42040000  0x42040000  0x00000  0x00004  RW   0x1     [.apps]
LOAD  0x007738  0x40800900  0x40800900  0x00000  0x00438  RW   0x8     [.sram]
LOAD  0x007738  0x42007600  0x4203ffd4  0x0002c  0x0002c  R    0x2     [.attributes]
```

**Flash segments (0x42xxxxxx):**
1. **Segment 1:** `0x42000020` - `.text`
2. **Segment 2:** `0x42007450` - `.storage`
3. **Segment 4:** `0x42040000` - `.apps`
4. **Segment 6:** `0x42007600` - `.attributes`

**Result:** `rom_index = 4` ❌ Bootloader assertion fails!

---

## Root Cause: Missing Segment Gap

### Problem in Tock Linker Script

**File:** `tock/boards/nano-esp32-c6/layout.ld` + `tock/boards/build_scripts/tock_kernel_layout.ld`

The Tock linker script places sections sequentially without forcing segment boundaries:

```ld
.text : {
    *(.text .text.* .gnu.linkonce.t.*)
    _srodata = .;
    *(.rodata .rodata.* .gnu.linkonce.r.*)
} > rom

.storage : {
    . = ALIGN(PAGE_SIZE);
    _sstorage = .;
    *(.storage* storage*)
    _estorage = .;
} > rom
```

**Result:** `.text` and `.storage` are **contiguous in the same LOAD segment** OR create **multiple small segments** instead of two large ones.

---

### Solution from Embassy

**File:** `embassy-on-esp/target/.../esp32c6.x` (lines 62-71)

```ld
SECTIONS {
  /**
   * Bootloader really wants to have separate segments for ROTEXT and RODATA
   * Thus, we need to force a gap here.
   */
  .text_gap (NOLOAD): {
    . = . + 4;
    . = ALIGN(4) + 0x20;
  } > ROM
}
INSERT BEFORE .rodata;
```

**How it works:**
1. Creates a **NOLOAD** section between `.text` and `.rodata`
2. Adds **36 bytes** (`4 + 0x20 = 36`) of padding
3. Forces linker to create **separate LOAD segments**:
   - Segment 1: `.text` (IROM)
   - Segment 2: `.text_gap + .rodata` (DROM)

**Why this works:**
- The gap breaks contiguity, forcing a new LOAD segment
- The NOLOAD attribute means the gap doesn't consume flash space
- Bootloader sees exactly 2 flash segments in range `0x42000000-0x43000000`

---

## Tock Architecture Context

### Current Tock Section Layout

```
ROM (0x42000020):
├── .text           (code + rodata merged)
├── .storage        (kernel non-volatile storage)
└── .attributes     (TLV metadata at end of ROM)

PROG (0x42040000):
└── .apps           (application binaries)
```

**Issues:**
1. `.text` includes both code AND rodata (no separation)
2. `.storage` creates a separate segment (should be merged with DROM)
3. `.apps` is in flash range (should be excluded or merged)
4. `.attributes` creates yet another segment

---

## Risks Identified

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Linker script changes break Tock assumptions | Medium | High | Test with existing Tock boards, verify symbols |
| `.storage` section misaligned after changes | Low | Medium | Preserve PAGE_SIZE alignment |
| `.apps` segment interferes with bootloader | High | High | Move to separate LOAD or mark NOLOAD |
| `.attributes` creates extra segment | High | Medium | Merge with DROM or place outside flash range |

---

## Questions for PO

**None** - Root cause is clear, solution is well-established in embassy-rs.

---

## Recommended Approach

### Strategy

**Adopt embassy-rs segment layout pattern** while preserving Tock's unique sections (`.storage`, `.apps`, `.attributes`).

### Goals

1. **Exactly 2 flash segments** in range `0x42000000-0x43000000`
2. **Preserve Tock semantics** for storage, apps, and attributes
3. **Minimal changes** to existing Tock linker infrastructure

---

## Sprint Breakdown

### SP003-T1: Modify Linker Script

**Scope:** Update `tock/boards/nano-esp32-c6/layout.ld` to force 2-segment layout

**Changes Required:**

1. **Add `.text_gap` section** (like embassy):
   ```ld
   .text : {
       *(.riscv.start)
       . = DEFINED(_start_trap) ? ALIGN(256) : ALIGN(1);
       KEEP(*(.riscv.trap_vectored));
       KEEP(*(.riscv.trap));
       *(.text .text.* .gnu.linkonce.t.*)
   } > rom
   
   .text_gap (NOLOAD) : {
       . = . + 4;
       . = ALIGN(4) + 0x20;
   } > rom
   
   .rodata : {
       _srodata = .;
       *(.rodata .rodata.* .gnu.linkonce.r.*)
       *(.srodata .srodata.*);
   } > rom
   ```

2. **Merge `.storage` into DROM segment:**
   ```ld
   .storage : {
       . = ALIGN(PAGE_SIZE);
       _sstorage = .;
       *(.storage* storage*)
       _estorage = .;
       . = ALIGN(PAGE_SIZE);
   } > rom
   /* No gap - stays in same LOAD segment as .rodata */
   ```

3. **Fix `.apps` section:**
   ```ld
   .apps (NOLOAD) : {
       . = ALIGN(4);
       _sapps = .;
       BYTE(0xFF) BYTE(0xFF) BYTE(0xFF) BYTE(0xFF)
   } > prog
   ```
   **Verify:** This should create a segment at `0x42040000` but **outside** the bootloader's scan range if we limit ROM to `< 0x40000`.

4. **Fix `.attributes` placement:**
   ```ld
   .attributes : AT (ORIGIN(rom) + LENGTH(rom) - SIZEOF(.attributes))
   {
       /* ... existing content ... */
   } > rom
   ```
   **Issue:** This creates a separate LOAD segment. **Solution:** Place attributes at end of `.storage` instead of using AT directive.

---

### SP003-T2: Verify Segment Layout

**Scope:** Confirm ELF has exactly 2 flash segments

**Commands:**
```bash
llvm-readelf -l tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board | grep "LOAD.*0x42"
```

**Expected Output:**
```
LOAD  0xXXXXXX  0x42000020  0x42000020  0xXXXXX  0xXXXXX  R E  0x1000  [.text]
LOAD  0xXXXXXX  0x420XXXXX  0x420XXXXX  0xXXXXX  0xXXXXX  R    0x1000  [.text_gap .rodata .storage]
```

**Acceptance Criteria:**
- Exactly 2 LOAD segments with VirtAddr in range `0x42000000-0x43000000`
- Segment 1: Executable (R E) - IROM
- Segment 2: Read-only (R) - DROM
- All other segments (RAM, apps) outside range or marked NOLOAD

---

### SP003-T3: Test Boot

**Scope:** Flash modified binary and verify bootloader passes assertion

**Commands:**
```bash
cd tock
make
espflash flash --monitor target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**Expected Output:**
```
I (85) esp_image: segment 0: paddr=00010020 vaddr=42000020 size=XXXXX map
I (90) esp_image: segment 1: paddr=000XXXXX vaddr=420XXXXX size=XXXXX map
I (100) boot: Loaded app from partition at offset 0x10000
I (100) boot: Disabling RNG early entropy source...
I (105) esp_image: Jumping to entry point 0x42000020...
```

**Success Criteria:**
- No assertion failure
- Bootloader jumps to entry point
- UART output from Tock kernel (if implemented)

---

## Handoff to Implementor

### Critical Information

1. **DO NOT modify `tock_kernel_layout.ld`** - It's shared across all Tock boards
2. **Use board-specific linker script** (`layout.ld`) to insert ESP32-C6 specific sections
3. **Preserve alignment requirements:**
   - `.storage`: PAGE_SIZE (512 bytes for Tock)
   - `.text_gap`: 4-byte aligned + 0x20 offset
   - RISC-V trap handler: 256-byte aligned

4. **Test with readelf BEFORE flashing** to avoid bootloop

5. **Reference implementation:** `embassy-on-esp/target/.../esp32c6.x`

### Key Files to Modify

- `tock/boards/nano-esp32-c6/layout.ld` - Add `.text_gap`, reorganize sections
- `tock/boards/nano-esp32-c6/Makefile` - No changes needed
- `tock/boards/nano-esp32-c6/src/main.rs` - No changes needed

### Verification Checklist

- [ ] Exactly 2 LOAD segments in flash range (0x42000000-0x43000000)
- [ ] Segment 1: VirtAddr=0x42000020, Flags=R E (IROM)
- [ ] Segment 2: VirtAddr=0x420XXXXX, Flags=R (DROM)
- [ ] `.storage` section present and aligned to PAGE_SIZE
- [ ] `.apps` section at 0x42040000 (outside bootloader scan or NOLOAD)
- [ ] Entry point = 0x42000020
- [ ] No assertion failure in bootloader logs
- [ ] Bootloader reaches "Jumping to entry point" message

---

## References

1. **ESP-IDF Bootloader Source:**
   - `esp-idf/components/bootloader_support/src/bootloader_utility.c:752-779`
   - Function: `unpack_load_app()` (SOC_MMU_DI_VADDR_SHARED variant)

2. **ESP32-C6 Memory Map:**
   - `esp-idf/components/soc/esp32c6/include/soc/soc.h`
   - `SOC_IROM_LOW = 0x42000000`
   - `SOC_IROM_HIGH = 0x43000000`

3. **Embassy Reference Implementation:**
   - `embassy-on-esp/target/.../esp32c6.x` (lines 62-71)
   - Comment: "Bootloader really wants to have separate segments for ROTEXT and RODATA"

4. **Tock Linker Script:**
   - `tock/boards/build_scripts/tock_kernel_layout.ld`
   - Generic layout for all Tock boards

---

## Next Steps

1. **Implementor:** Modify linker script per SP003-T1
2. **Implementor:** Verify segment layout per SP003-T2
3. **Implementor:** Test boot per SP003-T3
4. **Analyst:** Review segment layout if issues arise
5. **PO:** Approve if bootloader passes assertion and jumps to entry point

---

**End of Analysis Report #029**
