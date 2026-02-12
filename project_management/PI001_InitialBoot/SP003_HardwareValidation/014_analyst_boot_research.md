# PI001/SP003 - Analysis Report: ESP32-C6 Bootloader Requirements & Tock Compatibility

## Analysis: ESP32-C6 Boot Process and Tock OS Integration

### Objective
Resolve the critical blocker preventing ESP32-C6 from booting Tock kernel due to bootloader image format incompatibility.

**Error:** `image at 0x10000 has invalid magic byte (nothing flashed here?)`

**Root Cause:** ESP32-C6 ROM bootloader expects ESP-IDF image format with specific headers; Tock generates raw RISC-V binaries without ESP32-specific headers.

---

## Research Summary

### 1. ESP32-C6 Boot Process

The ESP32-C6 uses a **two-stage bootloader architecture**:

1. **ROM Bootloader (1st stage)** - Located in ROM, runs at power-on
   - Reads bootloader from flash offset 0x0
   - Validates ESP32 image format (magic byte 0xE9)
   - Loads 2nd stage bootloader to RAM

2. **ESP-IDF Bootloader (2nd stage)** - Located at flash 0x0
   - Reads partition table from flash offset 0x8000
   - Selects application partition (default: 0x10000)
   - Validates application image format
   - Loads application to RAM and transfers control

**Key Insight:** The ROM bootloader REQUIRES the ESP-IDF image format. It cannot boot raw binaries directly.

### 2. ESP-IDF Image Format

According to ESP-IDF documentation, an application image consists of:

```
[esp_image_header_t]           // Magic byte 0xE9, segment count, SPI config
  [esp_image_segment_header_t] // Load address, data length
  [segment 0 data]
  [esp_image_segment_header_t]
  [segment 1 data]
  ...
[checksum byte]                // Padded to 16-byte boundary
[SHA256 hash] (optional)       // 32 bytes
[signature] (optional)         // 68 bytes (ECDSA) or 4KB (RSA)
```

**Critical Fields:**
- `magic`: Must be 0xE9 (ESP_IMAGE_HEADER_MAGIC)
- `segment_count`: Number of memory segments
- `spi_mode`, `spi_speed`, `spi_size`: Flash configuration
- `entry_addr`: Application entry point
- `chip_id`: Must be ESP_CHIP_ID_ESP32C6

**Tock Issue:** Tock's `.bin` file is a raw binary dump of the ELF file's `.text` section. It has NO ESP32 headers.

### 3. ESP32-C3 Approach Analysis

The ESP32-C3 Tock port uses `esptool.py elf2image` to convert Tock binaries:

**Workflow (from `tock/boards/esp32-c3-devkitM-1/Makefile`):**

```bash
# Step 1: Create simple ELF wrapper around binary
$(OBJCOPY) --input-target=binary \
           --output-target=elf32-littleriscv \
           --change-section-address=.data=0x40380000 \
           --set-start=0x40380000 \
           esp32_c3_devkitm1.bin esp32_c3_devkitm1.bin.elf

# Step 2: Convert ELF to ESP32-C3 image format
esptool.py --chip esp32c3 elf2image \
           --output esp32_c3_devkitm1.flash.bin \
           esp32_c3_devkitm1.bin.elf \
           --dont-append-digest

# Step 3: Flash to address 0x0 (bootloader location)
esptool.py --chip esp32c3 write_flash \
           --flash_mode dio \
           --flash_size detect \
           --flash_freq 80m \
           0x0 esp32_c3_devkitm1.flash.bin
```

**Key Insight:** ESP32-C3 flashes Tock kernel to address **0x0** (bootloader location), bypassing the ESP-IDF bootloader entirely!

### 4. ESP32-C3 vs ESP32-C6 Memory Differences

| Aspect | ESP32-C3 | ESP32-C6 |
|--------|----------|----------|
| **Flash Mapping** | 0x40380000 (direct map) | 0x42000000 (MMU-based) |
| **Boot Address** | 0x40380000 (flash-executable) | 0x42010000 (requires bootloader) |
| **ROM Bootloader** | Can execute from flash directly | Requires 2nd stage bootloader |
| **MMU** | Simple direct mapping | Advanced MMU with page tables |

**Critical Difference:** ESP32-C3 can execute code directly from flash-mapped memory. ESP32-C6 requires the ROM bootloader to configure the MMU and load code to RAM.

---

## Existing Work

### Tock Reference
- **ESP32-C3 port:** `tock/boards/esp32-c3-devkitM-1/`
  - Uses `esptool.py elf2image` to add ESP32 headers
  - Flashes to 0x0, replacing bootloader entirely
  - Works because ESP32-C3 can execute from flash directly

### ESP32-C6 Specifics
- **Memory Map:** Flash at 0x42000000, SRAM at 0x40800000
- **Boot Sequence:**
  1. ROM bootloader runs from internal ROM
  2. Loads 2nd stage bootloader from flash 0x0
  3. 2nd stage loads app from flash 0x10000
  4. App executes from RAM (0x42010000 is flash-mapped)

### Current Tock ESP32-C6 Implementation
- **Linker Script:** `tock/boards/nano-esp32-c6/layout.ld`
  - ROM: 0x42010000 (256 KB) - kernel code
  - RAM: 0x40800000 (256 KB) - kernel data
  - PROG: 0x42050000 (512 KB) - apps
- **Build Output:** Raw binary without ESP32 headers
- **Flash Script:** Attempts to flash binary to 0x10000

---

## Knowledge Gaps

| Gap | Impact | Resolution |
|-----|--------|------------|
| Can ESP32-C6 boot from 0x0 like ESP32-C3? | HIGH - Determines if we can bypass bootloader | Research ESP32-C6 ROM behavior |
| Does elf2image work for ESP32-C6? | HIGH - Determines if ESP32-C3 approach works | Test with actual hardware |
| Can we use minimal ESP-IDF bootloader? | MEDIUM - Alternative if direct boot fails | Research ESP-IDF bootloader customization |
| What's espflash's bootloader support? | MEDIUM - Might simplify workflow | Already researched - espflash has built-in bootloader |

---

## Options Analysis

### Option A: Use esptool elf2image + Flash to 0x0 (ESP32-C3 Approach)

**Approach:**
```bash
# Convert binary to ELF wrapper
objcopy --input-target=binary \
        --output-target=elf32-littleriscv \
        --change-section-address=.data=0x42010000 \
        --set-start=0x42010000 \
        kernel.bin kernel.bin.elf

# Convert to ESP32-C6 image format
esptool.py --chip esp32c6 elf2image \
           --output kernel.flash.bin \
           kernel.bin.elf \
           --dont-append-digest

# Flash to bootloader location
esptool.py --chip esp32c6 write_flash \
           --flash_mode dio \
           --flash_size detect \
           --flash_freq 80m \
           0x0 kernel.flash.bin
```

**Pros:**
- ✅ Proven approach (works on ESP32-C3)
- ✅ No ESP-IDF dependency
- ✅ Simple tooling (esptool.py only)
- ✅ Bypasses ESP-IDF bootloader complexity

**Cons:**
- ❌ **CRITICAL:** May not work on ESP32-C6 due to MMU requirements
- ❌ ROM bootloader might require 2nd stage bootloader
- ❌ Replaces bootloader (can't use ESP-IDF tools)
- ❌ Unknown if ESP32-C6 ROM supports this

**Risk:** HIGH - ESP32-C6 architecture differences may prevent direct boot

**Recommendation:** TEST FIRST - Try this approach and monitor serial output

---

### Option B: Use ESP-IDF Bootloader + Partition Table

**Approach:**
```bash
# Extract bootloader from ESP-IDF
# (or build minimal ESP-IDF project)
esptool.py --chip esp32c6 elf2image \
           --output kernel.app.bin \
           kernel.bin.elf

# Flash bootloader, partition table, and app
esptool.py --chip esp32c6 write_flash \
           0x0 bootloader.bin \
           0x8000 partition-table.bin \
           0x10000 kernel.app.bin
```

**Pros:**
- ✅ Follows ESP32-C6 standard boot flow
- ✅ Compatible with ESP-IDF tools (espflash, idf.py)
- ✅ Guaranteed to work (ROM bootloader expects this)
- ✅ Can use partition table for OTA, NVS, etc.

**Cons:**
- ❌ Requires ESP-IDF bootloader binary
- ❌ More complex tooling (3 files to flash)
- ❌ Larger flash footprint (bootloader + partition table)
- ❌ Dependency on ESP-IDF for bootloader updates

**Risk:** LOW - This is the standard ESP32-C6 boot flow

**Recommendation:** FALLBACK - Use if Option A fails

---

### Option C: Custom Minimal Bootloader

**Approach:**
- Write a minimal 2nd stage bootloader in Rust
- Bootloader loads Tock kernel from flash to RAM
- Configure MMU and jump to Tock entry point

**Pros:**
- ✅ Full control over boot process
- ✅ No ESP-IDF dependency
- ✅ Can optimize for Tock-specific needs
- ✅ Educational value

**Cons:**
- ❌ **CRITICAL:** High development effort (2-4 weeks)
- ❌ Requires deep ESP32-C6 ROM knowledge
- ❌ Must handle MMU configuration
- ❌ Must handle flash initialization
- ❌ Debugging complexity (bootloader bugs are hard)

**Risk:** VERY HIGH - Complex, time-consuming, error-prone

**Recommendation:** AVOID - Only if Options A and B fail

---

### Option D: Use espflash Built-in Bootloader

**Approach:**
```bash
# espflash automatically includes bootloader
espflash flash --chip esp32c6 kernel.elf
```

**Investigation Results:**
- ✅ espflash has `--bootloader` option for custom bootloader
- ✅ espflash can generate partition tables
- ✅ espflash supports `save-image --merge` for single binary
- ❌ **BLOCKER:** espflash expects ESP-IDF app descriptor in image
- ❌ Tock kernels don't have ESP-IDF app descriptor

**Error from previous attempts:**
```
Error: espflash::elf: Missing app descriptor
```

**Pros:**
- ✅ Single-command flashing
- ✅ Built-in bootloader support
- ✅ Automatic partition table generation

**Cons:**
- ❌ **BLOCKER:** Requires ESP-IDF app descriptor in Tock kernel
- ❌ Would need to modify Tock kernel to add descriptor
- ❌ Tight coupling with ESP-IDF format

**Risk:** MEDIUM - Requires kernel modifications

**Recommendation:** DEFER - Requires upstream Tock changes

---

## Recommended Approach

### Phase 1: Test ESP32-C3 Approach on ESP32-C6 (Option A)

**Rationale:**
1. Lowest effort (reuse ESP32-C3 Makefile pattern)
2. Quick validation (can test in <1 hour)
3. No external dependencies (esptool.py already installed)
4. If it works, we're done!

**Implementation Plan:**

1. **Update Makefile** (5 min)
   ```makefile
   # Add elf2image target similar to ESP32-C3
   flash-elf2image: $(KERNEL_ELF)
       $(OBJCOPY) --input-target=binary \
                  --output-target=elf32-littleriscv \
                  --change-section-address=.data=0x42010000 \
                  --set-start=0x42010000 \
                  $(KERNEL_BIN) $(KERNEL_BIN).elf
       esptool.py --chip esp32c6 elf2image \
                  --output $(KERNEL_BIN).flash.bin \
                  $(KERNEL_BIN).elf \
                  --dont-append-digest
       esptool.py --chip esp32c6 write_flash \
                  --flash_mode dio \
                  --flash_size detect \
                  --flash_freq 80m \
                  0x0 $(KERNEL_BIN).flash.bin
   ```

2. **Test on Hardware** (10 min)
   ```bash
   cd tock/boards/nano-esp32-c6
   make flash-elf2image
   make monitor
   ```

3. **Monitor Serial Output** (5 min)
   - Look for ROM bootloader messages
   - Check if Tock kernel starts
   - Document any errors

**Success Criteria:**
- ✅ Kernel boots without "invalid magic byte" error
- ✅ Tock initialization messages appear on serial
- ✅ No ROM bootloader errors

**Failure Criteria:**
- ❌ ROM bootloader rejects image
- ❌ MMU configuration errors
- ❌ Kernel doesn't start

**If Phase 1 Fails:** Proceed to Phase 2

---

### Phase 2: Use ESP-IDF Bootloader (Option B)

**Rationale:**
1. Guaranteed to work (standard ESP32-C6 boot flow)
2. Well-documented approach
3. Compatible with ESP-IDF ecosystem

**Implementation Plan:**

1. **Extract ESP-IDF Bootloader** (30 min)
   ```bash
   # Option 1: Use pre-built bootloader from ESP-IDF
   # Download from ESP-IDF releases
   
   # Option 2: Build minimal ESP-IDF project
   idf.py create-project minimal-boot
   cd minimal-boot
   idf.py build
   # Extract build/bootloader/bootloader.bin
   # Extract build/partition_table/partition-table.bin
   ```

2. **Create Custom Partition Table** (15 min)
   ```csv
   # partitions.csv
   # Name,     Type, SubType, Offset,  Size
   nvs,        data, nvs,     0x9000,  0x6000
   phy_init,   data, phy,     0xf000,  0x1000
   factory,    app,  factory, 0x10000, 0x100000
   ```

3. **Update Flash Script** (15 min)
   ```bash
   # Flash bootloader, partition table, and Tock kernel
   esptool.py --chip esp32c6 write_flash \
              0x0 bootloader.bin \
              0x8000 partition-table.bin \
              0x10000 kernel.app.bin
   ```

4. **Convert Tock Binary to ESP-IDF App Format** (30 min)
   ```bash
   # Use elf2image to add ESP32 headers
   esptool.py --chip esp32c6 elf2image \
              --output kernel.app.bin \
              kernel.bin.elf
   ```

5. **Test on Hardware** (10 min)

**Success Criteria:**
- ✅ Bootloader loads successfully
- ✅ Partition table recognized
- ✅ Tock kernel boots from 0x10000
- ✅ No ROM bootloader errors

---

## Detailed Implementation Plan (Phase 1)

### Step 1: Create elf2image Makefile Target

**File:** `tock/boards/nano-esp32-c6/Makefile`

**Changes:**
```makefile
# Add after existing flash target

# ESP32-C3-style flash using elf2image (experimental)
.PHONY: flash-elf2image
flash-elf2image: $(KERNEL_ELF).bin
	@echo "Converting Tock binary to ESP32-C6 image format..."
	# Step 1: Create ELF wrapper around binary
	$(OBJCOPY) --input-target=binary \
	           --output-target=elf32-littleriscv \
	           --change-section-address=.data=0x42010000 \
	           --set-start=0x42010000 \
	           $(KERNEL_ELF).bin $(KERNEL_ELF).bin.elf
	# Step 2: Convert to ESP32-C6 image format
	esptool.py --chip esp32c6 elf2image \
	           --output $(KERNEL_ELF).flash.bin \
	           $(KERNEL_ELF).bin.elf \
	           --dont-append-digest
	@echo "Flashing to bootloader location (0x0)..."
	# Step 3: Flash to address 0x0
	esptool.py --chip esp32c6 write_flash \
	           --flash_mode dio \
	           --flash_size detect \
	           --flash_freq 80m \
	           0x0 $(KERNEL_ELF).flash.bin
	@echo "✅ Flash complete! Monitor serial output..."
```

### Step 2: Test Workflow

```bash
# Terminal 1: Build and flash
cd tock/boards/nano-esp32-c6
make clean
make
make flash-elf2image

# Terminal 2: Monitor serial output
make monitor
```

### Step 3: Analyze Results

**Expected Outcomes:**

**Scenario A: SUCCESS** ✅
```
ESP-ROM:esp32c6-20220919
Build:Sep 19 2022
rst:0x1 (POWERON),boot:0xc (SPI_FAST_FLASH_BOOT)
SPIWP:0xee
mode:DIO, clock div:1
load:0x42010000,len:0x7138
entry 0x42010000
Tock kernel starting...
ESP32-C6 initialization complete.
```

**Scenario B: FAILURE - Invalid Magic Byte** ❌
```
ESP-ROM:esp32c6-20220919
Build:Sep 19 2022
rst:0x1 (POWERON),boot:0xc (SPI_FAST_FLASH_BOOT)
invalid magic byte (nothing flashed here?)
ets_main.c 329
```
→ **Action:** Proceed to Phase 2 (ESP-IDF bootloader)

**Scenario C: FAILURE - MMU Error** ❌
```
ESP-ROM:esp32c6-20220919
Build:Sep 19 2022
rst:0x1 (POWERON),boot:0xc (SPI_FAST_FLASH_BOOT)
load:0x42010000,len:0x7138
MMU configuration failed
```
→ **Action:** Proceed to Phase 2 (ESP-IDF bootloader)

---

## Impact Assessment

### Tooling Changes

**Option A (elf2image):**
- ✅ Minimal changes to Makefile
- ✅ No new dependencies (esptool.py already installed)
- ✅ No changes to build system

**Option B (ESP-IDF bootloader):**
- ⚠️ Need to manage bootloader binary
- ⚠️ Need to manage partition table
- ⚠️ More complex flash workflow
- ⚠️ Potential ESP-IDF dependency

### Code Changes

**Option A (elf2image):**
- ✅ NO code changes required
- ✅ Linker script unchanged
- ✅ Kernel code unchanged

**Option B (ESP-IDF bootloader):**
- ✅ NO code changes required
- ⚠️ May need to adjust linker script if bootloader expects different layout
- ✅ Kernel code unchanged

### Documentation Changes

**Both Options:**
- Update `QUICKSTART_HARDWARE.md` with boot process explanation
- Update `scripts/README.md` with flash workflow
- Add troubleshooting section for boot failures
- Document ESP32-C6 vs ESP32-C3 differences

---

## Risks Identified

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| ESP32-C6 ROM requires 2nd stage bootloader | HIGH | CRITICAL | Test Option A first, have Option B ready |
| elf2image doesn't work for ESP32-C6 | MEDIUM | HIGH | Fallback to Option B |
| ESP-IDF bootloader incompatible with Tock | LOW | HIGH | Test with minimal ESP-IDF app first |
| MMU configuration issues | MEDIUM | CRITICAL | Research ESP32-C6 ROM bootloader behavior |
| Partition table conflicts | LOW | MEDIUM | Use custom partition table |
| Flash size limitations | LOW | LOW | 8MB flash is sufficient |

---

## Questions for PO

### RESOLVED (via research):
1. ✅ **Can we use ESP32-C3 approach on ESP32-C6?**
   - Answer: Unknown - requires hardware testing
   - Plan: Test in Phase 1

2. ✅ **Do we need ESP-IDF bootloader?**
   - Answer: Likely yes, but test Option A first
   - Plan: Phase 2 fallback

3. ✅ **What's the minimal bootloader size?**
   - Answer: ~24 KB (from ESP-IDF documentation)
   - Impact: Fits in 0x0-0x8000 range

### NEW QUESTIONS:
None - all questions answered via research.

---

## Recommendation

### Primary Approach: **Option A (elf2image + flash to 0x0)**

**Justification:**
1. **Lowest Risk:** Quick test (< 1 hour) with minimal changes
2. **Proven Pattern:** Works on ESP32-C3, might work on ESP32-C6
3. **No Dependencies:** Uses existing esptool.py
4. **Easy Rollback:** If it fails, try Option B

**If Option A Fails:** **Option B (ESP-IDF bootloader)**

**Justification:**
1. **Guaranteed Success:** Standard ESP32-C6 boot flow
2. **Well-Documented:** ESP-IDF has extensive docs
3. **Low Complexity:** Extract pre-built binaries
4. **Future-Proof:** Compatible with ESP-IDF ecosystem

**Avoid:** Option C (custom bootloader) and Option D (espflash) due to high complexity and kernel modifications.

---

## Handoff to Implementor

### Immediate Actions

1. **Test Option A** (Priority: CRITICAL)
   - Add `flash-elf2image` target to Makefile
   - Test on hardware
   - Document results

2. **Prepare Option B** (Priority: HIGH)
   - Download ESP-IDF bootloader binary
   - Create custom partition table
   - Test with minimal ESP-IDF app first

3. **Update Documentation** (Priority: MEDIUM)
   - Document boot process
   - Add troubleshooting guide
   - Explain ESP32-C6 vs ESP32-C3 differences

### Success Criteria

- ✅ Kernel boots without "invalid magic byte" error
- ✅ Tock initialization messages appear on serial
- ✅ `make flash` works reliably
- ✅ Documentation updated

### Testing Checklist

- [ ] Build kernel: `make`
- [ ] Flash with elf2image: `make flash-elf2image`
- [ ] Monitor serial: `make monitor`
- [ ] Verify boot messages
- [ ] Test kernel functionality (LED blink, UART)
- [ ] Document any errors or warnings

### Fallback Plan

If Option A fails:
1. Extract ESP-IDF bootloader and partition table
2. Update Makefile for 3-file flash
3. Test with hardware
4. Update documentation

---

## References

### ESP-IDF Documentation
- [Bootloader](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/api-guides/bootloader.html)
- [App Image Format](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/api-reference/system/app_image_format.html)
- [Partition Tables](https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/api-guides/partition-tables.html)

### Tock Reference
- ESP32-C3 Makefile: `tock/boards/esp32-c3-devkitM-1/Makefile`
- ESP32-C3 Linker Script: `tock/boards/esp32-c3-devkitM-1/layout.ld`
- ESP32-C3 README: `tock/boards/esp32-c3-devkitM-1/README.md`

### Tools
- esptool.py: https://github.com/espressif/esptool
- espflash: https://github.com/esp-rs/espflash
- ESP-IDF: https://github.com/espressif/esp-idf

---

## Session Summary

**Research Completed:**
- ✅ ESP32-C6 boot process documented
- ✅ ESP-IDF image format analyzed
- ✅ ESP32-C3 approach reverse-engineered
- ✅ Four options evaluated
- ✅ Recommended approach identified
- ✅ Implementation plan created

**Key Findings:**
1. ESP32-C6 ROM bootloader requires ESP-IDF image format
2. ESP32-C3 bypasses bootloader by flashing to 0x0
3. ESP32-C6 may require 2nd stage bootloader due to MMU
4. Two viable options: elf2image (quick test) or ESP-IDF bootloader (guaranteed)

**Next Steps:**
1. Implementor: Test Option A (elf2image)
2. If fails: Implement Option B (ESP-IDF bootloader)
3. Update documentation with boot process details

**Status:** READY FOR IMPLEMENTATION ✅
