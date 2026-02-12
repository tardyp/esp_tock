# Linker Script Changes for ESP32-C6 2-Segment Fix

**File:** `tock/boards/nano-esp32-c6/layout.ld`

---

## Strategy

**Use `INSERT` directive** to inject ESP32-C6 specific sections without modifying `tock_kernel_layout.ld`.

This is the same approach embassy-rs uses in `esp32c6.x`.

---

## Current layout.ld

```ld
/* Licensed under the Apache License, Version 2.0 or the MIT License. */
/* SPDX-License-Identifier: Apache-2.0 OR MIT                         */
/* Copyright Tock Contributors 2023.                                  */

/* ESP32-C6 Memory Layout for nanoESP32-C6 (8MB Flash)
 * 
 * Embassy-style direct boot approach (NO ESP-IDF bootloader)
 * ...
 */

MEMORY
{
  rom (rx)  : ORIGIN = 0x42000000 + 0x20, LENGTH = 0x40000 - 0x20
  ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x40000
  prog (rx) : ORIGIN = 0x42000000 + 0x40000, LENGTH = 0x80000
}

INCLUDE tock_kernel_layout.ld
```

---

## Modified layout.ld

```ld
/* Licensed under the Apache License, Version 2.0 or the MIT License. */
/* SPDX-License-Identifier: Apache-2.0 OR MIT                         */
/* Copyright Tock Contributors 2023.                                  */

/* ESP32-C6 Memory Layout for nanoESP32-C6 (8MB Flash)
 * 
 * ESP-IDF bootloader compatible layout (2-segment requirement)
 * 
 * Boot Flow:
 * - ROM bootloader loads ESP-IDF bootloader from 0x0
 * - ESP-IDF bootloader loads app from partition offset 0x10000
 * - Bootloader expects EXACTLY 2 flash segments:
 *   1. IROM (code) - executable segment
 *   2. DROM (data) - read-only segment
 * - Bootloader assertion: assert(rom_index == 2)
 * 
 * Memory Map:
 * - HP SRAM: 0x40800000 - 0x4087FFFF (512 KB total)
 * - Flash:   0x42000000 - 0x427FFFFF (8 MB total on nanoESP32-C6)
 * 
 * Flash Segment Layout:
 * - 0x42000020: .text (IROM) - kernel code
 * - 0x420XXXXX: .text_gap (NOLOAD) - forces segment boundary
 * - 0x420XXXXX: .rodata + .storage (DROM) - read-only data
 */

MEMORY
{
  /* Kernel code and read-only data in flash
   * Flash offset 0x0 maps to CPU address 0x42000000
   * +0x20 offset for espflash image header (32 bytes)
   * Using 256KB for kernel (can expand if needed)
   */
  rom (rx)  : ORIGIN = 0x42000000 + 0x20, LENGTH = 0x40000 - 0x20
  
  /* Kernel RAM (data, BSS, stack, heap)
   * HP SRAM starts at 0x40800000
   * Using 256KB for kernel RAM (conservative, can expand to 453KB like embassy)
   */
  ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x40000
  
  /* Application binaries in flash - 512 KB
   * Starts after kernel (0x40000)
   * Flash offset 0x40000 maps to CPU address 0x42040000
   */
  prog (rx) : ORIGIN = 0x42000000 + 0x40000, LENGTH = 0x80000
}

/* ESP32-C6 Specific: Force 2-segment layout for bootloader compatibility
 * 
 * The ESP-IDF bootloader scans flash range 0x42000000-0x43000000 and counts
 * LOAD segments. It REQUIRES exactly 2 segments:
 *   - Segment 1: IROM (instruction ROM) - executable code
 *   - Segment 2: DROM (data ROM) - read-only data
 * 
 * The .text_gap section forces the linker to create a segment boundary
 * between executable code (.text) and read-only data (.rodata, .storage).
 * 
 * Without this gap, the linker may merge sections into a single segment
 * or create too many segments, causing bootloader assertion failure.
 * 
 * Reference: embassy-rs esp-hal esp32c6.x linker script
 * Comment: "Bootloader really wants to have separate segments for ROTEXT and RODATA"
 */
SECTIONS
{
    .text_gap (NOLOAD) : {
        . = . + 4;
        . = ALIGN(4) + 0x20;
    } > rom
}
INSERT BEFORE .storage;

INCLUDE tock_kernel_layout.ld
```

---

## What Changed?

### 1. Added Comment Block

Explains the 2-segment requirement and why `.text_gap` is needed.

**Why:** Future maintainers need to understand this is ESP-IDF bootloader specific, not arbitrary.

### 2. Added `.text_gap` Section

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

**What it does:**
- Creates a NOLOAD section (doesn't consume flash space)
- Adds 36 bytes of padding (`4 + 0x20`)
- Placed between `.text` and `.storage` (which comes before `.rodata` in tock_kernel_layout.ld)
- Forces linker to create a new LOAD segment for everything after the gap

**Why 36 bytes?**
- Copied from embassy-rs (proven to work)
- Ensures sufficient gap for linker to recognize segment boundary
- Alignment requirements for RISC-V

### 3. Updated Boot Flow Comment

Changed from:
```
Embassy-style direct boot approach (NO ESP-IDF bootloader)
```

To:
```
ESP-IDF bootloader compatible layout (2-segment requirement)
```

**Why:** We ARE using ESP-IDF bootloader (contrary to earlier assumption).

---

## How `INSERT` Works

The `INSERT BEFORE .storage` directive:
1. Waits for `tock_kernel_layout.ld` to define all sections
2. Finds the `.storage` section definition
3. Inserts `.text_gap` section **before** `.storage` in the final layout
4. Results in section order: `.text` → `.text_gap` → `.storage` → `.rodata`

**Result:** Two LOAD segments:
- Segment 1: `.text` (ends at gap boundary)
- Segment 2: `.text_gap` (NOLOAD) + `.storage` + `.rodata` + everything else in ROM

---

## Alternative: Custom Section Order

If `INSERT` doesn't work (some linker versions don't support it), use custom layout:

```ld
MEMORY { /* same as above */ }

SECTIONS
{
    .text : {
        . = ALIGN(4);
        _stext = .;
        KEEP(*(.riscv.start));
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

    .storage : {
        . = ALIGN(PAGE_SIZE);
        _sstorage = .;
        *(.storage* storage*)
        _estorage = .;
        . = ALIGN(PAGE_SIZE);
    } > rom

    /* ... rest of tock_kernel_layout.ld sections ... */
}
```

**Downside:** Duplicates code from `tock_kernel_layout.ld`, harder to maintain.

**Upside:** Full control over section order.

---

## Verification After Build

### 1. Check Section Order

```bash
llvm-readelf -S tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board \
  | grep -E "\.text|\.text_gap|\.rodata|\.storage"
```

**Expected:**
```
[ 1] .text        PROGBITS  42000020  ...  R E
[ 2] .text_gap    NOBITS    420XXXXX  ...  A
[ 3] .storage     PROGBITS  420XXXXX  ...  R
[ 4] .rodata      PROGBITS  420XXXXX  ...  R
```

**Key points:**
- `.text_gap` has type `NOBITS` (NOLOAD)
- `.text_gap` comes between `.text` and other sections
- All sections in ROM have addresses starting with `0x42`

### 2. Check Segment Mapping

```bash
llvm-readelf -l tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**Expected:**
```
Program Headers:
  Type      Offset    VirtAddr   PhysAddr   FileSiz  MemSiz   Flg  Align
  LOAD      0x001020  0x42000020 0x42000020 0xXXXXX  0xXXXXX  R E  0x1000
  LOAD      0x00XXXX  0x420XXXXX 0x420XXXXX 0xXXXXX  0xXXXXX  R    0x1000
  LOAD      0x00XXXX  0x40800000 0x40800000 0xXXXXX  0xXXXXX  RW   0x1000
  ...

Section to Segment mapping:
  Segment Sections...
   00     .text
   01     .text_gap .storage .rodata
   02     .stack .sram
   ...
```

**Success criteria:**
- Exactly 2 LOAD segments with VirtAddr in range `0x42000000-0x43000000`
- Segment 0: `.text` only, flags `R E`
- Segment 1: `.text_gap .storage .rodata`, flags `R  ` (read-only, not executable)
- `.text_gap` appears in segment mapping despite being NOLOAD

---

## Troubleshooting

### `.text_gap` not creating segment boundary

**Symptom:** Still only 1 segment containing `.text .storage .rodata`

**Cause:** Gap too small or alignment issue

**Fix:** Increase gap size:
```ld
.text_gap (NOLOAD) : {
    . = . + 0x100;  /* Increase to 256 bytes */
} > rom
```

### Too many segments (still > 2)

**Symptom:** 3 or 4 segments in flash range

**Cause:** `.apps` or `.attributes` creating separate segments

**Fix 1:** Verify `.apps` is NOLOAD:
```bash
llvm-readelf -S <elf> | grep ".apps"
```
Should show `NOBITS` type.

**Fix 2:** Check if `.attributes` uses AT directive:
```bash
grep -n "\.attributes.*AT" tock/boards/build_scripts/tock_kernel_layout.ld
```
If found, this creates a separate LOAD segment. Need to modify `tock_kernel_layout.ld` or override in board-specific script.

### `.text_gap` section not found

**Symptom:** Linker error "section .text_gap not found"

**Cause:** `INSERT BEFORE .storage` fails if `.storage` not defined

**Fix:** Use absolute section ordering (custom layout approach above) instead of `INSERT`.

---

## Testing Checklist

- [ ] Build completes without linker errors
- [ ] `llvm-readelf -l` shows exactly 2 LOAD segments in range `0x42000000-0x43000000`
- [ ] Segment 1 has flags `R E` (IROM)
- [ ] Segment 2 has flags `R  ` (DROM)
- [ ] `.text_gap` appears in section list with type `NOBITS`
- [ ] Flash and verify bootloader reaches "Jumping to entry point" message
- [ ] No "Assert failed in unpack_load_app" error

---

**Next:** Implementor applies these changes and tests (SP003-T1, T2, T3).
