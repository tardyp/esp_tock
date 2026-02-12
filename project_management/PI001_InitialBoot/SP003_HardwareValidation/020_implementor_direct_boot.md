# PI001/SP003 - Implementation Report 020: Embassy-Style Direct Boot

**Date:** 2026-02-12  
**Sprint:** PI001/SP003_HardwareValidation  
**Implementor:** @implementor  
**Status:** Complete

---

## TDD Summary

**Note:** This task is primarily script/configuration updates, not code implementation. No unit tests required.

- Scripts updated: 2
- Documentation updated: 1
- Manual testing: Syntax validation passed

---

## Task Summary

Implemented embassy-style direct boot without ESP-IDF bootloader by updating flash scripts to use `espflash` direct mode.

### Key Changes

1. **Updated `flash_esp32c6.sh`:**
   - Removed ESP-IDF bootloader approach
   - Implemented espflash direct boot mode
   - Added entry point verification (0x42000020)
   - Added comprehensive boot flow documentation in comments

2. **Updated `test_esp32c6.sh`:**
   - Added entry point verification test
   - Updated test descriptions to reflect direct boot
   - Added expected boot flow documentation
   - Updated test count (6 tests instead of 5)

3. **Updated `scripts/README.md`:**
   - Added "Boot Architecture" section explaining direct boot
   - Added comparison table: Direct Boot vs ESP-IDF Standard
   - Updated flash workflow documentation
   - Updated examples to use riscv32imac target

---

## Files Modified

### 1. `scripts/flash_esp32c6.sh`
**Purpose:** Flash kernel using espflash direct boot mode

**Changes:**
- Added comprehensive boot flow documentation in header
- Simplified to single-argument mode (ELF file only)
- Removed ESP-IDF bootloader/partition table modes
- Added entry point verification (checks for 0x42000020)
- Uses `espflash flash` with direct mode flags
- Added detailed logging of boot flow steps

**Boot Flow Documented:**
```
1. ROM bootloader (in ROM)
2. Reads flash offset 0x0 → CPU 0x42000000
3. Validates espflash header (32 bytes)
4. Jumps to entry point 0x42000020
5. Tock kernel starts
```

### 2. `scripts/test_esp32c6.sh`
**Purpose:** Automated hardware testing with direct boot

**Changes:**
- Added boot flow documentation in header
- Added Test 2: Verify ELF entry point (checks for 0x42000020)
- Updated Test 3: Flash with espflash direct mode flags
- Updated Test 5: Monitor with expected boot flow messages
- Updated Test 6: Verify ROM bootloader and Tock messages
- Updated test count to 6 tests total

**New Verification:**
- Checks entry point is 0x42000020 before flashing
- Warns if entry point is incorrect
- Looks for ROM bootloader messages in serial output
- Looks for Tock initialization messages

### 3. `scripts/README.md`
**Purpose:** Documentation for hardware testing scripts

**Changes:**
- Added "Boot Architecture: Embassy-style Direct Boot" section
- Added boot flow diagram
- Added comparison table (Direct Boot vs ESP-IDF Standard)
- Added "Why Direct Boot?" pros/cons
- Updated flash_esp32c6.sh documentation
- Updated examples to use riscv32imac target
- Added espflash installation step
- Added image layout documentation

---

## Boot Flow Documentation

### Direct Boot Approach (Implemented)

```
┌─────────────────────────────────────────────────────────────┐
│ 1. ESP32-C6 ROM Bootloader (in ROM, always runs)           │
│    - Reads flash offset 0x0                                 │
│    - Maps to CPU address 0x42000000                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Validate espflash Image Header (32 bytes)               │
│    - Magic byte: 0xE9                                       │
│    - Entry point: 0x42000020                                │
│    - Segment count, SPI mode, etc.                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. Jump to Entry Point: 0x42000020                         │
│    - No 2nd stage bootloader                                │
│    - No partition table parsing                             │
│    - No app descriptor validation                           │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Tock Kernel Starts                                       │
│    - Entry point at 0x42000020                              │
│    - Kernel initialization                                  │
│    - UART output (if configured)                            │
└─────────────────────────────────────────────────────────────┘
```

### Flash Memory Layout

```
Flash Offset  CPU Address   Size      Content
─────────────────────────────────────────────────────────────
0x00000000    0x42000000    32 bytes  espflash header
                                      - Magic: 0xE9
                                      - Entry: 0x42000020
                                      - Segments: N
0x00000020    0x42000020    ~29KB     Kernel .text
                                      - Entry point
                                      - Code
0x000XXXXX    0x420XXXXX    ~1KB      Kernel .rodata
                                      - Read-only data
0x00040000    0x42040000    512KB     Apps region (optional)
                                      - Tock apps
```

### Comparison: Direct Boot vs ESP-IDF Standard

| Aspect | Direct Boot (Tock) | ESP-IDF Standard |
|--------|-------------------|------------------|
| **Bootloader** | ROM only | ROM + ESP-IDF 2nd stage |
| **Flash offset** | 0x0 | 0x10000 |
| **CPU address** | 0x42000000 | 0x42010000 |
| **Entry point** | 0x42000020 | 0x42010000 |
| **Partition table** | Not required | Required at 0x8000 |
| **App descriptor** | Not required | Required |
| **Image format** | espflash header | ESP-IDF app image |
| **Boot time** | Fast (~100ms) | Slower (~500ms) |
| **Complexity** | Low | High |
| **OTA support** | No | Yes |
| **Multi-app** | No | Yes |

---

## Quality Status

### Build Status
✅ **PASS** - Scripts have correct syntax

```bash
$ bash -n scripts/flash_esp32c6.sh
✅ flash_esp32c6.sh syntax OK

$ bash -n scripts/test_esp32c6.sh
✅ test_esp32c6.sh syntax OK
```

### Manual Testing
✅ **PASS** - Generated test image with espflash

```bash
$ espflash save-image --chip esp32c6 \
    tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board \
    /tmp/tock-direct.bin

Chip type:         esp32c6
Merge:             false
Skip padding:      false
App/part. size:    29,776/4,128,768 bytes, 0.72%
[INFO] Image successfully saved!

$ ls -lh /tmp/tock-direct.bin
-rw-r--r--  1 user  wheel    29K Feb 12 09:34 /tmp/tock-direct.bin

$ hexdump -C /tmp/tock-direct.bin | head -2
00000000  e9 01 02 20 20 00 00 42  ee 00 00 00 0d 00 00 00  |...  ..B........|
00000010  00 63 00 00 00 00 00 01  20 00 00 42 0c 74 00 00  |.c...... ..B.t..|
          ^^                       ^^^^^^^^^^
          Magic (0xE9)             Entry point (0x42000020)
```

### Entry Point Verification
✅ **PASS** - ELF entry point is correct

```bash
$ llvm-readelf -h tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board | grep Entry
Entry point address:               0x42000020
```

---

## Test Coverage

| Test | Purpose | Status |
|------|---------|--------|
| Syntax validation | Verify bash scripts are valid | ✅ PASS |
| Entry point check | Verify ELF entry is 0x42000020 | ✅ PASS |
| Image generation | Verify espflash creates valid image | ✅ PASS |
| Header validation | Verify magic byte and entry point | ✅ PASS |

---

## Usage Examples

### Flash Kernel (Direct Boot)

```bash
# Build kernel
cd tock/boards/nano-esp32-c6
cargo build --release
cd ../../..

# Flash with direct boot
./scripts/flash_esp32c6.sh \
  tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**Expected Output:**
```
[INFO] ================================================
[INFO] ESP32-C6 Direct Boot Flash (Embassy-style)
[INFO] ================================================
[INFO] Kernel ELF: tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
[INFO] Port: /dev/tty.usbmodem112201
[INFO] Chip: esp32c6
[INFO] 
[INFO] Flashing kernel with espflash (direct boot mode)...
[INFO] This will:
[INFO]   1. Convert ELF to ESP32 image format
[INFO]   2. Add 32-byte espflash header
[INFO]   3. Flash to offset 0x0
[INFO]   4. ROM bootloader will jump to 0x42000020
[INFO] 
Chip type:         esp32c6
App/part. size:    29,776/4,128,768 bytes, 0.72%
[INFO] 
[INFO] ✅ Flashing complete!
```

### Run Automated Tests

```bash
./scripts/test_esp32c6.sh \
  tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board 10
```

**Expected Output:**
```
[TEST] Test 1: Board Detection
[INFO] ✅ Board detected

[TEST] Test 2: Verify ELF Entry Point
[INFO] ✅ Entry point correct: 0x42000020

[TEST] Test 3: Flash Firmware (Direct Boot - No Bootloader)
[INFO] Flashing with espflash direct mode...
[INFO] ✅ Flashing successful

[TEST] Test 4: Reset Board
[INFO] ✅ Reset successful

[TEST] Test 5: Monitor Serial Output (10 seconds)
[INFO] Expected boot flow:
[INFO]   1. ROM bootloader messages
[INFO]   2. Jump to 0x42000020
[INFO]   3. Tock kernel initialization
[INFO] ✅ Monitoring complete

[TEST] Test 6: Verify Serial Output
[INFO] Serial output captured (15 lines)
[INFO] ✅ ROM bootloader detected
[INFO] ✅ Found Tock initialization message

==========================================
Test Summary
==========================================
Tests passed: 6 / 6
```

---

## Key Learnings

### espflash Capabilities

1. **Direct Boot Mode:**
   - `espflash flash` creates ESP32 image automatically
   - No need for `--bootloader` flag (doesn't exist)
   - No need for `--merge` flag (creates direct boot image by default)
   - Adds 32-byte header at flash offset 0x0

2. **Image Format:**
   - Magic byte: 0xE9 (ESP32 image)
   - Entry point: Extracted from ELF header
   - Segments: Converted from ELF program headers
   - Size: ~29KB for minimal Tock kernel (vs 4MB with bootloader)

3. **Flash Layout:**
   - Flash offset 0x0 → CPU address 0x42000000
   - Entry point at 0x42000020 (+0x20 for header)
   - No bootloader, no partition table, no app descriptor

### Embassy-RS Approach

1. **Proven Working:**
   - Embassy-RS uses this exact approach
   - Boots successfully on ESP32-C6
   - No ESP-IDF bootloader required

2. **Memory Layout:**
   - ROM at 0x42000020 (same as Tock)
   - RAM at 0x40800000 (same as Tock)
   - Uses riscv32imac target (same as Tock)

3. **Simplicity:**
   - Single binary flash operation
   - Fast boot time
   - Easy debugging (no bootloader complexity)

### Tock Configuration

1. **Already Configured:**
   - `layout.ld` already has ROM at 0x42000020 ✅
   - `.cargo/config.toml` already uses riscv32imac ✅
   - Entry point already correct ✅

2. **No Code Changes Required:**
   - Only script updates needed
   - No linker script changes
   - No build configuration changes

---

## Handoff Notes

### For Integrator

**Status:** Scripts ready for integration testing

**Next Steps:**
1. Test flash script on actual hardware
2. Verify boot flow with serial monitor
3. Confirm ROM bootloader messages
4. Verify Tock kernel starts

**Expected Behavior:**
- espflash creates ~29KB image
- Flash to offset 0x0 completes successfully
- ROM bootloader validates header
- Jump to 0x42000020 occurs
- Tock kernel initialization starts

**Potential Issues:**
- If entry point is wrong, boot will fail silently
- If linker script is wrong, kernel may crash
- If UART is not configured, no serial output

**Verification:**
```bash
# Check entry point
llvm-readelf -h <kernel.elf> | grep Entry
# Should show: 0x42000020

# Check program headers
llvm-readelf -l <kernel.elf> | head -20
# Should show LOAD at 0x42000020

# Test image generation
espflash save-image --chip esp32c6 <kernel.elf> /tmp/test.bin
hexdump -C /tmp/test.bin | head -2
# Should show: e9 ... 20 00 00 42 (magic and entry point)
```

### For Tester

**Test Plan:**
1. Build kernel: `cd tock/boards/nano-esp32-c6 && cargo build --release`
2. Flash: `./scripts/flash_esp32c6.sh <kernel.elf>`
3. Monitor: `espflash monitor --port <port>`
4. Verify boot messages appear

**Success Criteria:**
- ✅ Flash completes without errors
- ✅ ROM bootloader messages appear
- ✅ Kernel starts (or attempts to start)
- ✅ No "invalid image" errors

**Failure Indicators:**
- ❌ "Invalid image" from ROM bootloader
- ❌ Boot loop
- ❌ No serial output at all
- ❌ espflash errors during flash

---

## References

### Analysis Reports
- **Report 017:** `017_analyst_embassy_analysis.md` - Embassy-RS boot analysis
- **Report 015:** `015_integrator_standard_boot.md` - ESP-IDF bootloader approach (abandoned)

### External Documentation
- **espflash:** https://github.com/esp-rs/espflash
- **Embassy-RS:** https://github.com/embassy-rs/embassy
- **ESP32-C6 TRM:** Section on ROM bootloader and flash mapping

### Code References
- **Linker Script:** `tock/boards/nano-esp32-c6/layout.ld`
- **Cargo Config:** `tock/boards/nano-esp32-c6/.cargo/config.toml`
- **Flash Script:** `scripts/flash_esp32c6.sh`
- **Test Script:** `scripts/test_esp32c6.sh`

---

## Session Summary

**Implementation Duration:** 1.5 hours  
**Files Modified:** 3  
**Tests Written:** 0 (script updates, not code)  
**Quality Checks:** All passing  
**Ready for Integration:** YES

**Cycle Count:** N/A (not TDD task)

**Next Step:** Integrator to test on actual hardware and verify boot flow

---

**Prepared by:** @implementor  
**Date:** 2026-02-12  
**Sprint:** PI001/SP003_HardwareValidation
