# Quick Reference: Bootloader "rom_index == 2" Fix

**Problem:** ESP-IDF bootloader expects exactly 2 flash segments, Tock has 4.

**Root Cause:** Missing `.text_gap` section + `.apps` in bootloader scan range.

---

## The 2-Segment Rule

ESP32-C6 bootloader scans flash range `0x42000000 - 0x43000000` and counts LOAD segments:

```c
int rom_index = 0;
for (each segment in ELF) {
    if (segment.vaddr >= 0x42000000 && segment.vaddr < 0x43000000) {
        rom_index++;
    }
}
assert(rom_index == 2);  // MUST BE EXACTLY 2
```

**Expected:**
- Segment 1: IROM (code) - executable
- Segment 2: DROM (data) - read-only

---

## Current State (BROKEN)

```
0x42000020: Segment 1 [.text]           rom_index++  (1)
0x42007450: Segment 2 [.storage]        rom_index++  (2)
0x42040000: Segment 3 [.apps]           rom_index++  (3) ❌
0x42007600: Segment 4 [.attributes]     rom_index++  (4) ❌

Result: rom_index = 4 → ASSERTION FAILS
```

---

## Target State (FIXED)

```
0x42000020: Segment 1 [.text]                       rom_index++  (1)
            .text_gap (NOLOAD - forces new segment)
0x420XXXXX: Segment 2 [.rodata + .storage]          rom_index++  (2)

Result: rom_index = 2 → BOOTLOADER HAPPY ✅
```

**Key Changes:**
1. Add `.text_gap (NOLOAD)` between `.text` and `.rodata`
2. Merge `.storage` into DROM segment (no gap after `.rodata`)
3. Mark `.apps` as `NOLOAD` (already is, but verify)
4. Remove `.attributes` AT directive (merge into DROM)

---

## Linker Script Changes

### File: `tock/boards/nano-esp32-c6/layout.ld`

**Option 1: Board-Specific Override (RECOMMENDED)**

Add to `layout.ld` BEFORE `INCLUDE tock_kernel_layout.ld`:

```ld
SECTIONS
{
    .text_gap (NOLOAD) : {
        . = . + 4;
        . = ALIGN(4) + 0x20;
    } > rom
}
INSERT BEFORE .storage;
```

**Option 2: Custom Layout (More Control)**

Replace `INCLUDE tock_kernel_layout.ld` with custom sections:
- Copy `.text` section definition
- Add `.text_gap` section
- Copy `.rodata` + `.storage` sections (contiguous)
- Fix `.attributes` placement

---

## Verification Steps

### 1. Check Segment Count

```bash
llvm-readelf -l tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board \
  | grep "LOAD.*0x42" | wc -l
```

**Expected:** `2` (exactly 2 lines)

### 2. Verify Segment Layout

```bash
llvm-readelf -l tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board \
  | grep -A 1 "LOAD.*0x42"
```

**Expected:**
```
LOAD  0xXXXXXX  0x42000020  0x42000020  0xXXXXX  0xXXXXX  R E  0xXXXX
LOAD  0xXXXXXX  0x420XXXXX  0x420XXXXX  0xXXXXX  0xXXXXX  R    0xXXXX
```

**Flags:**
- Segment 1: `R E` (read + execute) = IROM
- Segment 2: `R  ` (read only) = DROM

### 3. Test Boot

```bash
espflash flash --monitor target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**Expected Output:**
```
I (85) esp_image: segment 0: paddr=00010020 vaddr=42000020 size=XXXXX map
I (90) esp_image: segment 1: paddr=000XXXXX vaddr=420XXXXX size=XXXXX map
I (100) boot: Loaded app from partition at offset 0x10000
I (100) boot: Disabling RNG early entropy source...
ESP-ROM:esp32c6-20220919
```

**Success:** No "Assert failed in unpack_load_app" message!

---

## Reference Implementation

**Embassy-rs:** `esp-hal/esp32c6.x` (lines 62-71)

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

---

## Troubleshooting

### Still getting "rom_index == 2" assertion?

1. **Check segment count:**
   ```bash
   llvm-readelf -l <elf> | grep "LOAD.*0x42" | nl
   ```
   If > 2, identify extra segments.

2. **Common culprits:**
   - `.apps` not marked NOLOAD
   - `.attributes` using AT directive (creates separate segment)
   - `.storage` has gap before it (creates separate segment)
   - Multiple `.text` sections

3. **Debug linker:**
   ```bash
   rust-lld -verbose <objects> -o <elf> -T layout.ld 2>&1 | grep -i segment
   ```

### Bootloader crashes at different point?

- If assertion passes but still crashes, check:
  - Entry point = `0x42000020` (verify with `readelf -h`)
  - `.text` section starts with valid RISC-V code
  - Stack pointer initialized correctly

---

## Key Takeaways

1. **ESP32-C6 bootloader is strict:** Exactly 2 flash segments, no more, no less.
2. **`.text_gap` is mandatory:** Forces linker to create separate IROM/DROM segments.
3. **NOLOAD sections don't count:** Use for padding/alignment without creating segments.
4. **Embassy-rs got it right:** Follow their proven pattern.

---

**Next:** Hand off to Implementor for linker script modification (SP003-T1).
