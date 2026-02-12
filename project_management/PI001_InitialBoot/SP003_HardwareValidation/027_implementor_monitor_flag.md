# PI001/SP003 - Implementation Report 027

## Task: Fix flash script to use --monitor flag for proper boot mode

**Date:** 2026-02-12  
**Implementor:** AI Agent  
**Sprint:** PI001/SP003 - Hardware Validation  
**Root Cause:** Missing --monitor flag causes device to stay in DOWNLOAD mode (boot:0x4)

---

## TDD Summary
- Tests written: 0 (script fix, no unit tests needed)
- Tests passing: N/A
- Cycles: 1 / target <15
- Validation: Syntax check passed

---

## Files Modified

### 1. `scripts/flash_esp32c6.sh` (line 126-132)
**Purpose:** Add --monitor flag to espflash flash command

**Change:**
```bash
espflash flash \
    --chip "$CHIP" \
    --port "$FLASH_PORT" \
    --flash-mode dio \
    --flash-freq 80mhz \
    --monitor \           # ← ADDED
    "$KERNEL_ELF"
```

### 2. `scripts/test_esp32c6.sh` (line 112)
**Purpose:** Add --monitor flag to espflash flash command in test script

**Change:**
```bash
# Before:
espflash flash --chip esp32c6 --port $FLASH_PORT --flash-mode dio --flash-freq 80mhz "$KERNEL_ELF"

# After:
espflash flash --chip esp32c6 --port $FLASH_PORT --flash-mode dio --flash-freq 80mhz --monitor "$KERNEL_ELF"
```

---

## Quality Status
- ✅ bash syntax check: PASS (both scripts)
- ✅ Script modification: COMPLETE
- ✅ One-line change: CONFIRMED
- ⏳ Hardware validation: PENDING (requires physical test)

---

## Technical Details

### Root Cause (from Report 026)
Without `--monitor` flag, espflash leaves the device in DOWNLOAD mode:
- Boot mode: 0x4 (DOWNLOAD_BOOT)
- Strapping pins: 0x8000 (GPIO9 high)
- Device waits for commands, doesn't execute flashed code

### Fix Mechanism
The `--monitor` flag tells espflash to:
1. Flash the firmware
2. Reset the device into NORMAL mode
3. Start serial monitor (optional, can be interrupted)

This ensures boot mode: 0xc (SPI_FAST_FLASH_BOOT) - normal execution mode.

### Expected Boot Sequence After Fix
```
ESP-ROM:esp32c6-20220919
Build:Sep 19 2022
rst:0x1 (POWERON),boot:0xc (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:1
load:0x42000000,len:0x...
entry 0x42000020
[Tock kernel starts]
```

---

## Validation Steps

### 1. Syntax Validation (COMPLETED)
```bash
bash -n scripts/flash_esp32c6.sh  # ✅ PASS
bash -n scripts/test_esp32c6.sh   # ✅ PASS
```

### 2. Hardware Validation (REQUIRED)
Run on actual ESP32-C6 hardware:

```bash
# Build kernel
cd tock
make -C boards/nano-esp32-c6

# Flash with new script
./scripts/flash_esp32c6.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
```

**Success Criteria:**
- ✅ Device boots in NORMAL mode (boot:0xc)
- ✅ No DOWNLOAD mode (boot:0x4)
- ✅ No manual power cycle needed between flashes
- ✅ Serial output shows kernel execution

---

## Handoff Notes

### For Integrator
1. **Changes are minimal:** Only added `--monitor` flag to two scripts
2. **No code changes:** This is a tooling fix, not a kernel change
3. **Validation required:** Need physical ESP32-C6 to verify boot mode
4. **Expected outcome:** Device should boot immediately after flash without power cycle

### For Tester
**Test Plan:**
1. Flash firmware using updated script
2. Verify boot mode in serial output: `boot:0xc` (not `boot:0x4`)
3. Verify kernel starts without manual reset
4. Test multiple flash cycles without power cycling

**Expected Serial Output:**
```
ESP-ROM:esp32c6-20220919
Build:Sep 19 2022
rst:0x1 (POWERON),boot:0xc (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:1
load:0x42000000,len:0x...
entry 0x42000020
```

### Known Limitations
- The `--monitor` flag will start a serial monitor after flashing
- User can interrupt with Ctrl+C if monitor not needed
- This is expected behavior and ensures proper boot mode

---

## References
- **Root Cause Analysis:** Report 026
- **Boot Mode Documentation:** ESP32-C6 Technical Reference Manual, Section 2.4
- **espflash Documentation:** https://github.com/esp-rs/espflash

---

## Status
✅ **COMPLETE** - Scripts updated, syntax validated, ready for hardware testing
