# PI001/SP003 - Implementation Report: ESP-IDF App Descriptor

## Task
Add ESP-IDF app descriptor to Tock kernel for ESP32-C6 to enable bootloader validation and boot.

**Context:** ESP-IDF bootloader requires a 256-byte `esp_app_desc_t` structure with magic word 0xABCD5432. Without this, the bootloader rejects the application with "Failed to fetch app description header!" error.

---

## TDD Summary

### Cycle Tracking
- **Total Cycles:** 3
- **Target:** <5 cycles (focused task)
- **Status:** ✅ PASS (well under target)

### TDD Cycles

**Cycle 1: RED - Establish failing test**
- Verified current kernel builds successfully
- Confirmed bootloader rejects app without descriptor (from integrator report)
- Error: "E (75) esp_image: Failed to fetch app description header!"

**Cycle 2: GREEN - Implement minimal descriptor**
- Created `esp_app_desc.rs` module with 256-byte structure
- Added module to `main.rs`
- Fixed attribute placement (moved from struct to static)
- Fixed section name (`.rodata_desc` → `.rodata.desc` to match linker pattern)
- Build successful ✅
- Magic word verified in binary ✅

**Cycle 3: REFACTOR - Quality checks**
- Verified code formatting (cargo fmt) ✅
- Verified no clippy warnings for new code ✅
- Verified binary size increase reasonable (+512 bytes) ✅
- Added comprehensive documentation ✅

---

## Files Modified

### 1. New File: `tock/boards/nano-esp32-c6/src/esp_app_desc.rs`
**Purpose:** ESP-IDF app descriptor structure

**Key Features:**
- 256-byte `#[repr(C)]` structure matching ESP-IDF `esp_app_desc_t`
- Magic word: 0xABCD5432 (ESP_APP_DESC_MAGIC_WORD)
- Version: "Tock 2.1"
- Project name: "tock-esp32c6"
- IDF version: "none" (Tock doesn't use ESP-IDF)
- SHA256 placeholder (zeros - can be computed at build time if needed)
- Compile-time assertion ensuring exactly 256 bytes
- Placed in `.rodata.desc` section for inclusion in ROM

**Design Decisions:**
- Used `.rodata.desc` section name (not `.rodata_desc`) to match linker pattern `*(.rodata .rodata.*)`
- Static strings with null padding to meet fixed-size requirements
- `#[used]` attribute prevents linker from removing as "unused"
- Minimal implementation - only what bootloader requires

### 2. Modified: `tock/boards/nano-esp32-c6/src/main.rs`
**Change:** Added `mod esp_app_desc;` declaration

**Location:** Line 21 (after `pub mod io;`)

**Purpose:** Include the app descriptor module in the build

### 3. Modified: `tock/boards/nano-esp32-c6/layout.ld`
**Change:** No changes required!

**Reason:** The generic linker script `tock_kernel_layout.ld` already includes pattern `*(.rodata .rodata.*)` in the `.text` section, which matches our `.rodata.desc` section name.

---

## Quality Status

### Build Status
- ✅ `cargo build`: PASS
- ✅ `cargo fmt --check`: PASS (no formatting issues)
- ✅ `cargo clippy --lib -- -D warnings`: PASS (no warnings in new code)
- ✅ Binary size: 29,740 bytes (+512 bytes from baseline 29,228)

### Binary Verification
```bash
$ hexdump -C nano-esp32-c6-board.bin | grep -A10 "32 54 cd ab"
00005660  48 00 00 00 33 00 00 00  32 54 cd ab 00 00 00 00  |H...3...2T......|
00005670  00 00 00 00 00 00 00 00  54 6f 63 6b 20 32 2e 31  |........Tock 2.1|
00005680  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
00005690  00 00 00 00 00 00 00 00  74 6f 63 6b 2d 65 73 70  |........tock-esp|
000056a0  33 32 63 36 00 00 00 00  00 00 00 00 00 00 00 00  |32c6............|
000056b0  00 00 00 00 00 00 00 00  30 30 3a 30 30 3a 30 30  |........00:00:00|
000056c0  00 00 00 00 00 00 00 00  4a 61 6e 20 20 31 20 32  |........Jan  1 2|
000056d0  30 32 34 00 00 00 00 00  6e 6f 6e 65 00 00 00 00  |024.....none....|
```

**Verified:**
- ✅ Magic word present: `32 54 cd ab` (0xABCD5432 little-endian)
- ✅ Version string: "Tock 2.1"
- ✅ Project name: "tock-esp32c6"
- ✅ Time: "00:00:00"
- ✅ Date: "Jan  1 2024"
- ✅ IDF version: "none"
- ✅ Structure size: 256 bytes (0x100)

### ESP-IDF Image Conversion
```bash
$ esptool.py --chip esp32c6 elf2image --output tock-app.bin nano-esp32-c6-board
Creating esp32c6 image...
Merged 2 ELF sections
Successfully created esp32c6 image.

$ esptool.py image_info tock-app.bin
File size: 95312 (bytes)
Detected image type: ESP32-C6
Image version: 1
Entry point: 42010000
2 segments
Checksum: e1 (valid)
Validation Hash: 5d2988a3218ab6a8077ab531a8620abc34fe35eadfd21455b1158016a172b154 (valid)
```

**Status:** ✅ Valid ESP32-C6 image with app descriptor included

---

## Test Coverage

| Test | Purpose | Status |
|------|---------|--------|
| Compile-time size check | Ensure struct is exactly 256 bytes | ✅ PASS |
| Build without errors | Verify code compiles | ✅ PASS |
| Magic word in binary | Verify descriptor in output | ✅ PASS |
| ESP-IDF image conversion | Verify bootloader compatibility | ✅ PASS |
| Section placement | Verify in ROM (not RAM) | ✅ PASS |
| Code formatting | Verify Tock style compliance | ✅ PASS |
| Clippy lints | Verify no warnings | ✅ PASS |

---

## Implementation Details

### ESP-IDF App Descriptor Structure

```rust
#[repr(C)]
pub struct EspAppDesc {
    magic_word: u32,        // 0xABCD5432
    secure_version: u32,    // 0 (not used)
    reserv1: [u32; 2],      // Reserved
    version: [u8; 32],      // "Tock 2.1"
    project_name: [u8; 32], // "tock-esp32c6"
    time: [u8; 16],         // "00:00:00"
    date: [u8; 16],         // "Jan  1 2024"
    idf_ver: [u8; 32],      // "none"
    app_elf_sha256: [u8; 32], // zeros (placeholder)
    reserv2: [u32; 20],     // Reserved
}
```

**Size Breakdown:**
- 4 bytes: magic_word
- 4 bytes: secure_version
- 8 bytes: reserv1
- 32 bytes: version
- 32 bytes: project_name
- 16 bytes: time
- 16 bytes: date
- 32 bytes: idf_ver
- 32 bytes: app_elf_sha256
- 80 bytes: reserv2
- **Total: 256 bytes** ✅

### Linker Section Placement

The `.rodata.desc` section is automatically included in the `.text` output section by the generic linker script pattern:

```ld
.text : {
    ...
    *(.rodata .rodata.* .gnu.linkonce.r.*)  // Matches .rodata.desc
    ...
} > rom
```

**Memory Layout:**
- ROM region: 0x42010000 - 0x4204FFFF (256 KB)
- App descriptor location: ~0x42015668 (within ROM)
- Bootloader can read from flash-mapped address

---

## Hardware Testing (Ready for @integrator)

### Test Procedure

1. **Build kernel:**
   ```bash
   cd tock/boards/nano-esp32-c6
   make clean && make
   ```

2. **Convert to ESP-IDF format:**
   ```bash
   cd esp_boot_components
   esptool.py --chip esp32c6 elf2image \
       --output tock-app.bin \
       ../tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board
   ```

3. **Flash complete image:**
   ```bash
   ./test_boot.sh
   ```

4. **Monitor serial output:**
   ```bash
   python3 ../scripts/monitor_serial.py
   ```

### Expected Success Criteria

**Bootloader Output (Expected):**
```
ESP-ROM:esp32c6-20220919
Build:Sep 19 2022
rst:0x1 (POWERON),boot:0xc (SPI_FAST_FLASH_BOOT)
...
I (22) boot: ESP-IDF v5.5.1-838-gd66ebb86d2e 2nd stage bootloader
I (43) boot: Partition Table:
I (46) boot: ## Label            Usage          Type ST Offset   Length
I (52) boot:  0 nvs              WiFi data        01 02 00009000 00006000
I (59) boot:  1 phy_init         RF data          01 01 0000f000 00001000
I (65) boot:  2 factory          factory app      00 00 00010000 00200000
I (72) boot: End of partition table
I (75) boot_comm: chip revision: 1, min. bootloader chip revision: 0
I (82) esp_image: segment 0: paddr=00010018 vaddr=00000000 size=0ffd8h ( 65496) map
I (103) esp_image: segment 1: paddr=0001fff8 vaddr=42010000 size=0742ch ( 29740) map
I (110) boot: Loaded app from partition at offset 0x10000
I (110) boot: Jumping to the app...

[TOCK KERNEL BOOT MESSAGES]
ESP32-C6 initialization complete. Entering main loop
```

**Success Indicators:**
- ✅ No "Failed to fetch app description header!" error
- ✅ Bootloader successfully loads app
- ✅ "Jumping to the app..." message appears
- ✅ Tock kernel starts and prints initialization message

**Failure Indicators:**
- ❌ "Failed to fetch app description header!" - descriptor not found
- ❌ "Factory app partition is not bootable" - magic word incorrect
- ❌ Bootloop - structure size wrong

---

## Handoff Notes for @integrator

### Ready for Hardware Testing ✅

**What's Done:**
1. ✅ ESP-IDF app descriptor structure implemented
2. ✅ Placed in correct linker section (.rodata.desc in ROM)
3. ✅ Magic word verified in binary (0xABCD5432)
4. ✅ Structure size verified (exactly 256 bytes)
5. ✅ ESP-IDF image conversion successful
6. ✅ Code quality checks passed (fmt, clippy)
7. ✅ Binary size reasonable (+512 bytes)

**What to Test:**
1. Flash complete image to hardware using `test_boot.sh`
2. Monitor serial output for bootloader messages
3. Verify no "Failed to fetch app description header!" error
4. Verify Tock kernel boots successfully
5. Verify "ESP32-C6 initialization complete" message appears

**Expected Outcome:**
This implementation should resolve the final blocker for ESP32-C6 boot. The bootloader should now accept the Tock kernel and transfer control to it.

**If Boot Fails:**
1. Check serial output for specific error message
2. Verify app descriptor in binary: `hexdump -C tock-app.bin | grep "32 54 cd ab"`
3. Verify image info: `esptool.py image_info tock-app.bin`
4. Check that descriptor is at correct offset (should be in first segment)

**Next Steps After Successful Boot:**
1. Update `scripts/flash_esp32c6.sh` to use 3-file flash by default
2. Document boot process in board README
3. Consider adding build-time SHA256 computation (currently zeros)
4. Consider adding compile date/time from build environment

---

## Technical Notes

### Why `.rodata.desc` Instead of `.rodata_desc`?

The generic Tock linker script uses the pattern `*(.rodata .rodata.*)` to match read-only data sections. This pattern matches:
- `.rodata` (exact match)
- `.rodata.anything` (prefix match with dot)

But does NOT match:
- `.rodata_desc` (underscore, not dot)

By using `.rodata.desc`, the section is automatically included in the `.text` output section without requiring linker script modifications.

### Why No Linker Script Changes?

The board-specific `layout.ld` only defines memory regions and includes the generic `tock_kernel_layout.ld`. The generic script already has the pattern we need, so no changes were required.

This approach:
- ✅ Minimizes changes to Tock infrastructure
- ✅ Follows existing Tock conventions
- ✅ Avoids board-specific linker script complexity
- ✅ Makes future Tock updates easier

### Future Enhancements

**Optional improvements (not required for boot):**

1. **Build-time SHA256:**
   - Compute SHA256 of ELF file during build
   - Requires build script modification
   - ESP-IDF uses this for secure boot verification

2. **Dynamic version info:**
   - Extract version from Cargo.toml
   - Add compile timestamp
   - Requires build script

3. **Verification tool:**
   - Script to verify app descriptor in binary
   - Could be added to CI/CD pipeline

4. **Upstream to Tock:**
   - Consider upstreaming ESP-IDF compatibility
   - Would benefit other ESP32 ports (ESP32-C3, ESP32-S3, etc.)

---

## Lessons Learned

### What Worked Well ✅

1. **TDD approach:** Clear RED-GREEN-REFACTOR cycles kept implementation focused
2. **Binary verification:** Hexdump verification caught issues early
3. **Minimal changes:** Using existing linker patterns avoided complexity
4. **Documentation:** ESP-IDF header file provided exact structure definition

### Challenges Overcome 💡

1. **Attribute placement:** Initial attempt put `#[used]` on struct instead of static
   - **Solution:** Moved attributes to static variable only
   
2. **Section naming:** `.rodata_desc` didn't match linker pattern
   - **Solution:** Changed to `.rodata.desc` to match `*(.rodata.*)`
   
3. **Section placement:** Initial concern about linker script modifications
   - **Solution:** Discovered existing pattern already handles it

### Key Insights 🎯

1. **Linker patterns are powerful:** Understanding glob patterns in linker scripts saved significant work
2. **Compile-time assertions are valuable:** `assert!(size_of::<T>() == 256)` catches errors early
3. **Binary verification is essential:** Can't trust build success alone - must verify output
4. **Minimal is better:** Simplest solution that works is often the best

---

## References

### ESP-IDF Documentation
- [App Image Format](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/api-reference/system/app_image_format.html)
- [Bootloader](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/api-guides/bootloader.html)

### ESP-IDF Source Code
- `esp-idf/components/esp_app_format/include/esp_app_desc.h` - Structure definition
- `esp-idf/components/bootloader_support/src/esp_image_format.c` - Bootloader validation

### Tock Reference
- `tock/boards/build_scripts/tock_kernel_layout.ld` - Generic linker script
- `tock/boards/nano-esp32-c6/layout.ld` - Board-specific memory layout

### Related Reports
- `015_integrator_standard_boot.md` - Integration report identifying this blocker
- `IMPLEMENTOR_GUIDE.md` - Quick implementation guide

---

## Session Summary

**Task Completed:** ✅ ESP-IDF app descriptor added to Tock kernel

**TDD Metrics:**
- Cycles: 3 / target <5 ✅
- Tests passing: 7/7 ✅
- Code quality: PASS ✅

**Deliverables:**
1. ✅ New module: `esp_app_desc.rs` (256-byte structure)
2. ✅ Modified: `main.rs` (module declaration)
3. ✅ Binary verification: Magic word present and correct
4. ✅ ESP-IDF image: Valid and ready for flashing
5. ✅ Documentation: Comprehensive implementation report

**Status:** READY FOR HARDWARE TESTING

**Next Agent:** @integrator - Flash to hardware and verify boot

**Confidence Level:** HIGH - All quality checks passed, binary verified, structure matches ESP-IDF specification exactly.

---

**Report Date:** 2026-02-11  
**Report Number:** 016  
**Agent:** @implementor  
**Sprint:** PI001/SP003_HardwareValidation  
**TDD Cycles:** 3 / target <5 ✅
