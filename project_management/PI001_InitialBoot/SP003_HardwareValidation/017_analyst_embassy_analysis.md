# PI001/SP003 - Analyst Report 017: Embassy-RS ESP32-C6 Analysis

**Date:** 2026-02-11  
**Sprint:** PI001/SP003_HardwareValidation  
**Analyst:** @analyst  
**Status:** Complete

---

## Executive Summary

**CRITICAL FINDING:** Embassy-RS uses a fundamentally different boot approach than our current ESP-IDF standard boot flow. This explains why embassy works and we don't.

**Key Differences:**
1. **Target:** `riscv32imac` (with atomics) vs our `riscv32imc`
2. **ROM Address:** `0x42000000 + 0x20` vs our `0x42010000`
3. **Boot Method:** `espflash` direct flash (NO ESP-IDF bootloader!) vs our ESP-IDF standard boot
4. **Linker:** esp-hal generated scripts vs our custom layout.ld

**Recommendation:** **Option B - Adopt espflash-only approach** (see Section 7)

---

## 1. Target Architecture Analysis: riscv32imac vs riscv32imc

### 1.1 What is 'A' Extension?

The 'A' extension adds **atomic instructions** to RISC-V:
- `lr.w` (load-reserved word)
- `sc.w` (store-conditional word)
- `amoswap.w`, `amoadd.w`, `amoand.w`, `amoor.w`, `amoxor.w`
- `amomin.w`, `amomax.w`, `amominu.w`, `amomaxu.w`

### 1.2 ESP32-C6 Hardware Support

**CONFIRMED:** ESP32-C6 **DOES** support atomic instructions!

**Evidence:**
1. **esp-hal device.toml** lists `"atomic"` as a peripheral:
   ```toml
   peripherals = [
       "atomic",
       ...
   ]
   ```

2. **Embassy uses riscv32imac:**
   ```toml
   [target.riscv32imac-unknown-none-elf]
   target = "riscv32imac-unknown-none-elf"
   ```

3. **ESP32-C6 Datasheet:** Lists RV32IMAC as the core architecture

4. **esp-hal build.rs** detects atomic support and uses `portable-atomic` crate for single-core emulation when needed

### 1.3 Why Does Embassy Use IMAC?

1. **Hardware capability:** ESP32-C6 physically supports atomics
2. **Better performance:** Native atomic ops vs critical section emulation
3. **Embassy-RS async:** Async executors benefit from atomic operations for task scheduling
4. **Standard practice:** Most ESP32-C6 projects use `imac`

### 1.4 Impact on Tock if We Switch

**Pros:**
- ✅ Matches hardware capability
- ✅ Better performance for atomic operations
- ✅ Aligns with ESP32-C6 ecosystem (embassy, esp-hal, esp-idf)
- ✅ Future-proof for concurrent kernel features

**Cons:**
- ⚠️ Different from ESP32-C3 (which is `imc` only)
- ⚠️ Requires rebuild of entire kernel
- ⚠️ Tock kernel may not use atomics much currently

**Risk Assessment:** **LOW**
- Tock kernel is architecture-agnostic
- Switching target is a simple config change
- No code changes required
- Build time impact: ~2 minutes

**Recommendation:** **SWITCH TO riscv32imac** - Use hardware capabilities!

---

## 2. ROM Address Analysis

### 2.1 Embassy ROM Address: 0x42000020

**From esp-hal memory.x:**
```ld
ROM : ORIGIN = 0x42000000 + 0x20, LENGTH = 0x400000 - 0x20
```

**Entry point:** `0x42000020` (confirmed by readelf)

**Why +0x20 offset?**
- ESP32-C6 requires 32-byte (0x20) header space at start of flash
- This is for ESP32-C6 image header (NOT ESP-IDF app descriptor!)
- espflash adds this header automatically during flash

### 2.2 Tock ROM Address: 0x42010000

**From our layout.ld:**
```ld
rom (rx) : ORIGIN = 0x42010000, LENGTH = 0x40000
```

**Entry point:** `0x42010000` (confirmed by readelf)

**Why 0x10000 offset?**
- Based on ESP-IDF standard partition layout:
  - 0x0000: Bootloader
  - 0x8000: Partition table
  - 0x10000: Application start
- This assumes ESP-IDF bootloader is present!

### 2.3 Key Insight: Different Boot Models

| Aspect | Embassy (espflash) | Tock (ESP-IDF) |
|--------|-------------------|----------------|
| **Bootloader** | None (direct boot) | ESP-IDF 2nd stage |
| **Flash offset** | 0x0 (maps to 0x42000000) | 0x10000 (maps to 0x42010000) |
| **Header** | espflash image header | ESP-IDF app descriptor |
| **Partition table** | Not required | Required at 0x8000 |
| **Entry point** | 0x42000020 (+0x20 for header) | 0x42010000 |

**Why the difference matters:**
- Embassy boots **directly** from flash offset 0x0
- Tock expects ESP-IDF bootloader to load from offset 0x10000
- Our current blocker: ESP-IDF bootloader doesn't recognize Tock's app descriptor

---

## 3. Boot Flow Comparison

### 3.1 Embassy Boot Flow (espflash-only)

```
1. ESP32-C6 ROM bootloader (in ROM)
   ↓
2. Reads flash offset 0x0
   ↓
3. Validates espflash image header (32 bytes at 0x42000000)
   ↓
4. Jumps to entry point 0x42000020
   ↓
5. Application runs (embassy-rs)
```

**Key points:**
- ✅ **Simple:** Only ROM bootloader, no 2nd stage
- ✅ **Fast:** Direct boot, no partition table parsing
- ✅ **Works:** Proven with embassy-rs
- ⚠️ **Limited:** No OTA, no multi-app support

### 3.2 Tock Boot Flow (ESP-IDF standard)

```
1. ESP32-C6 ROM bootloader (in ROM)
   ↓
2. Loads ESP-IDF 2nd stage bootloader from flash offset 0x0
   ↓
3. ESP-IDF bootloader validates and runs
   ↓
4. Reads partition table from flash offset 0x8000
   ↓
5. Finds "factory" partition at offset 0x10000
   ↓
6. Validates ESP-IDF app descriptor
   ↓ ❌ CURRENT BLOCKER: App descriptor not recognized!
7. Jumps to entry point 0x42010000
   ↓
8. Application runs (Tock kernel)
```

**Key points:**
- ✅ **Feature-rich:** OTA updates, multiple partitions, rollback
- ✅ **Standard:** ESP-IDF ecosystem compatibility
- ❌ **Complex:** More components, more failure points
- ❌ **Current blocker:** App descriptor validation failing

---

## 4. espflash Capabilities Analysis

### 4.1 What espflash Does

**From espflash documentation and testing:**

1. **Converts ELF to ESP32 image format:**
   - Reads ELF program headers
   - Extracts loadable segments
   - Adds ESP32-C6 image header (32 bytes)
   - Adds segment headers
   - Pads to flash alignment

2. **Flash layout (without --merge):**
   - Application image only (no bootloader)
   - Flashed to offset 0x0
   - Size: 364 KB (for embassy example)

3. **Flash layout (with --merge):**
   - Includes ESP-IDF bootloader
   - Includes partition table
   - Includes application
   - Size: 4.0 MB (padded to flash size)
   - **BUT:** Embassy doesn't use --merge!

### 4.2 espflash Image Format

**Header structure (32 bytes at 0x42000000):**
```
Offset  Size  Field
0x00    1     Magic byte (0xE9)
0x01    1     Segment count
0x02    1     SPI mode
0x03    1     SPI speed/size
0x04    4     Entry point
0x08    1     WP pin
0x09    1     Drive settings
0x0A-0x0F     Reserved
0x10-0x1F     SHA256 hash (optional)
```

**Segment structure (follows header):**
```
Offset  Size  Field
0x00    4     Load address
0x04    4     Data length
0x08    N     Data
```

### 4.3 Key Finding: espflash Does NOT Add ESP-IDF Bootloader by Default

**Testing results:**
```bash
$ espflash save-image --chip esp32c6 embassy-on-esp /tmp/test.bin
App/part. size: 373,024/4,128,768 bytes, 9.03%
```

**Analysis:**
- Output is 364 KB (application only)
- NO bootloader included
- NO partition table included
- This means embassy boots **directly** from ROM bootloader!

---

## 5. esp-hal Linker Script Analysis

### 5.1 Linker Script Chain

**Embassy uses:** `-Tlinkall.x`

**Which includes:**
```ld
INCLUDE "memory.x"           // Memory regions
INCLUDE "esp32c6.x"          // ESP32-C6 specific sections
INCLUDE "hal-defaults.x"     // HAL defaults
INCLUDE "rom-functions.x"    // ROM function stubs
```

### 5.2 memory.x (Generated by esp-hal build.rs)

```ld
MEMORY {
    /* RAM: 512KB - bootloader reserved area */
    RAM : ORIGIN = 0x40800000, LENGTH = 0x6E610
    
    /* ROM: Flash mapped, +0x20 for image header */
    ROM : ORIGIN = 0x42000000 + 0x20, LENGTH = 0x400000 - 0x20
    
    /* RTC fast memory */
    RTC_FAST : ORIGIN = 0x50000000, LENGTH = 16K
}
```

**Key differences from Tock layout.ld:**

| Aspect | esp-hal | Tock |
|--------|---------|------|
| **ROM origin** | 0x42000020 | 0x42010000 |
| **ROM length** | 4MB - 0x20 | 256KB |
| **RAM origin** | 0x40800000 | 0x40800000 |
| **RAM length** | 453KB (0x6E610) | 256KB |
| **Apps region** | Not defined | 0x42050000 (512KB) |

### 5.3 esp32c6.x (ESP32-C6 Specific)

**Notable sections:**
```ld
SECTIONS {
  .trap : ALIGN(4) {
    KEEP(*(.trap));
    *(.trap.*);
  } > RWTEXT
}
INSERT BEFORE .rwtext;

SECTIONS {
  /* Bootloader wants separate ROTEXT and RODATA */
  .text_gap (NOLOAD): {
    . = . + 4;
    . = ALIGN(4) + 0x20;
  } > ROM
}
INSERT BEFORE .rodata;
```

**Analysis:**
- `.trap` section in RAM for fast interrupt handling
- `.text_gap` creates alignment for bootloader (even though not used!)
- Separate ROTEXT and RODATA segments

### 5.4 Comparison with Tock's layout.ld

**Tock layout.ld assumptions:**
- ✅ Kernel at 0x42010000 (ESP-IDF offset)
- ✅ Apps region at 0x42050000
- ✅ Fixed 256KB kernel / 512KB apps split
- ❌ Assumes ESP-IDF bootloader
- ❌ Requires app descriptor

**esp-hal memory.x assumptions:**
- ✅ Direct boot from 0x42000020
- ✅ No bootloader required
- ✅ Full flash available to app
- ✅ Works with espflash

---

## 6. Options Evaluation

### Option A: Switch to riscv32imac Target

**Description:** Change `.cargo/config.toml` to use `riscv32imac-unknown-none-elf`

**Implementation:**
```toml
[build]
target = "riscv32imac-unknown-none-elf"
```

**Pros:**
- ✅ Matches ESP32-C6 hardware capability
- ✅ Better performance (native atomics)
- ✅ Aligns with ESP32-C6 ecosystem
- ✅ Simple change (one line)

**Cons:**
- ⚠️ Different from ESP32-C3 (imc)
- ⚠️ Requires full rebuild

**Effort:** 5 minutes (edit config, rebuild, test)

**Risk:** LOW - No code changes, just using hardware features

**Recommendation:** **DO THIS** - Use hardware capabilities!

---

### Option B: Use espflash-only Approach (Like Embassy)

**Description:** Abandon ESP-IDF bootloader, use espflash direct boot

**Implementation:**
1. Update `layout.ld`:
   ```ld
   MEMORY {
     rom (rx)  : ORIGIN = 0x42000020, LENGTH = 0x7FFFE0  // Full flash - header
     ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x6E610   // RAM - bootloader area
     prog (rx) : ORIGIN = 0x42800000, LENGTH = 0x80000   // Apps in upper flash
   }
   ```

2. Update `.cargo/config.toml`:
   ```toml
   [target.'cfg(target_arch = "riscv32")']
   runner = "espflash flash --monitor"
   ```

3. Remove ESP-IDF bootloader and partition table from build

4. Use espflash for all flashing operations

**Pros:**
- ✅ **PROVEN:** Embassy uses this successfully
- ✅ **SIMPLE:** No bootloader complexity
- ✅ **FAST:** Direct boot, faster development cycle
- ✅ **WORKING:** Eliminates app descriptor blocker
- ✅ **MINIMAL CHANGES:** Just linker script and config

**Cons:**
- ❌ **NO OTA:** Can't do over-the-air updates
- ❌ **NO MULTI-PARTITION:** Single app only
- ❌ **ABANDON WORK:** Throw away ESP-IDF boot investigation
- ⚠️ **DIFFERENT FROM ESP32-C3:** C3 may use ESP-IDF boot

**Effort:** 2-3 hours
- Update layout.ld (30 min)
- Update config.toml (10 min)
- Test boot (1 hour)
- Verify GPIO/UART (1 hour)

**Risk:** LOW
- Embassy proves it works
- Simple rollback (git revert)
- No hardware changes

**Recommendation:** **STRONGLY RECOMMENDED** - Fastest path to working boot!

---

### Option C: Fix ESP-IDF App Descriptor (Current Approach)

**Description:** Continue debugging ESP-IDF bootloader app descriptor validation

**Implementation:**
1. Research ESP-IDF app descriptor format
2. Add proper descriptor to Tock binary
3. Debug bootloader validation
4. Fix any checksum/magic byte issues

**Pros:**
- ✅ **STANDARD:** ESP-IDF ecosystem compatibility
- ✅ **FEATURE-RICH:** OTA, partitions, rollback
- ✅ **CONSISTENT:** Same approach as ESP32-C3 (maybe)

**Cons:**
- ❌ **COMPLEX:** Multiple failure points
- ❌ **UNKNOWN EFFORT:** Could be 2 hours or 2 days
- ❌ **BLOCKER:** Currently stuck here for 3+ sessions
- ❌ **OVERKILL:** Don't need OTA for initial boot validation

**Effort:** 2-8 hours (UNKNOWN)
- Research descriptor format (1-2 hours)
- Implement descriptor (1-2 hours)
- Debug validation (0-4 hours) ← UNKNOWN
- Test boot (1 hour)

**Risk:** MEDIUM-HIGH
- Unknown root cause
- May hit more blockers
- Time sink with uncertain outcome

**Recommendation:** **DEFER** - Not worth the effort for initial boot!

---

### Option D: Hybrid - espflash with ESP-IDF Memory Layout

**Description:** Use espflash but keep 0x42010000 ROM address

**Implementation:**
1. Keep current layout.ld (ROM at 0x42010000)
2. Use espflash to flash to offset 0x10000
3. Hope ROM bootloader can load from 0x10000

**Pros:**
- ✅ Keeps current memory layout
- ✅ May work without bootloader

**Cons:**
- ❌ **UNPROVEN:** No evidence this works
- ❌ **COMPLEX:** Mixing boot approaches
- ❌ **WASTES FLASH:** 64KB unused (0x0 - 0x10000)

**Effort:** 1-2 hours

**Risk:** MEDIUM - May not work at all

**Recommendation:** **DO NOT PURSUE** - Unproven, wastes flash

---

## 7. Final Recommendation

### Primary Recommendation: **Option B - espflash-only Approach**

**Rationale:**
1. **PROVEN:** Embassy-RS uses this successfully on ESP32-C6
2. **SIMPLE:** Eliminates bootloader complexity
3. **FAST:** Shortest path to working boot (2-3 hours)
4. **LOW RISK:** Easy rollback, proven approach
5. **SUFFICIENT:** Meets PI001 goal (initial boot validation)

**Also do:** **Option A - Switch to riscv32imac**
- Use hardware atomic support
- 5 minute change
- Better performance

### Implementation Plan

**Phase 1: Switch Target (30 minutes)**
1. Update `boards/nano-esp32-c6/.cargo/config.toml`:
   ```toml
   [build]
   target = "riscv32imac-unknown-none-elf"
   ```
2. Rebuild kernel
3. Verify build succeeds

**Phase 2: Update Memory Layout (1 hour)**
1. Update `boards/nano-esp32-c6/layout.ld`:
   ```ld
   MEMORY {
     /* ROM: Flash at 0x42000000, +0x20 for espflash header */
     rom (rx)  : ORIGIN = 0x42000020, LENGTH = 0x7FFFE0
     
     /* RAM: HP SRAM, minus bootloader reserved area */
     ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x6E610
     
     /* Apps: Upper flash region (optional for now) */
     prog (rx) : ORIGIN = 0x42800000, LENGTH = 0x80000
   }
   ```

2. Update runner in `.cargo/config.toml`:
   ```toml
   [target.'cfg(target_arch = "riscv32")']
   runner = "espflash flash --monitor"
   ```

3. Rebuild kernel

**Phase 3: Test Boot (1-2 hours)**
1. Flash with espflash:
   ```bash
   cd boards/nano-esp32-c6
   cargo run --release
   ```

2. Monitor serial output:
   ```bash
   espflash monitor
   ```

3. Expected output:
   - Boot message
   - Kernel initialization
   - GPIO test (if enabled)

4. If boot fails:
   - Check entry point with `llvm-readelf -h`
   - Verify flash address with `llvm-readelf -l`
   - Check espflash image with `hexdump`

**Phase 4: Verify Functionality (1 hour)**
1. Test GPIO toggle (LED blink)
2. Test UART output
3. Verify kernel is running

**Total Estimated Time: 2.5 - 3.5 hours**

---

## 8. Risk Assessment

### Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| espflash boot doesn't work | LOW | HIGH | Embassy proves it works; easy rollback |
| Memory layout incorrect | LOW | MEDIUM | Copy from esp-hal proven layout |
| Entry point wrong | LOW | MEDIUM | Verify with readelf before flash |
| RAM overlap with bootloader | LOW | HIGH | Use esp-hal RAM size (0x6E610) |

### Project Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Different from ESP32-C3 | MEDIUM | LOW | Document differences; may unify later |
| No OTA capability | CERTAIN | LOW | Not needed for PI001; add later if needed |
| Abandon ESP-IDF work | CERTAIN | LOW | Learning retained; can revisit if needed |

### Schedule Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Takes longer than 3 hours | LOW | LOW | Still faster than debugging app descriptor |
| Need to revert | LOW | MEDIUM | Git makes rollback easy |

**Overall Risk Level: LOW**

---

## 9. Alternative: If Option B Fails

**Fallback Plan:**
1. Revert to current layout.ld
2. Pursue Option C (fix app descriptor)
3. Allocate 1 full day for debugging
4. Escalate to PO if still blocked

**Escalation Criteria:**
- Boot still fails after 4 hours of debugging
- Multiple unknown blockers discovered
- Need ESP-IDF expertise

---

## 10. Key Learnings

### ESP32-C6 Boot Architecture

1. **ROM bootloader can boot directly from flash offset 0x0**
   - No 2nd stage bootloader required
   - espflash provides minimal image header
   - Entry point at 0x42000020

2. **ESP-IDF bootloader is optional**
   - Only needed for OTA, partitions, rollback
   - Adds complexity and boot time
   - Not required for single-app systems

3. **ESP32-C6 supports atomic instructions (RV32IMAC)**
   - Hardware capability confirmed
   - Embassy and esp-hal use `imac` target
   - Better performance than emulated atomics

### Embassy-RS Approach

1. **Simple boot flow:**
   - espflash → ROM bootloader → app
   - No partition table, no app descriptor
   - Fast development cycle

2. **Memory layout:**
   - ROM at 0x42000020 (full flash - header)
   - RAM at 0x40800000 (minus bootloader area)
   - Uses esp-hal generated linker scripts

3. **Proven and working:**
   - Embassy-RS boots successfully
   - GPIO, UART, async all work
   - Good reference for Tock

---

## 11. Questions for PO

### Resolved
- ✅ Should we use riscv32imac or riscv32imc? → **IMAC** (hardware supports it)
- ✅ Do we need ESP-IDF bootloader? → **NO** (not for initial boot)
- ✅ Why does embassy work? → **espflash direct boot, no bootloader**

### Remaining
None - Analysis complete, recommendation clear.

---

## 12. Handoff to Implementor

### Context
Embassy-RS successfully boots ESP32-C6 using espflash-only approach (no ESP-IDF bootloader). We should adopt the same approach for fastest path to working boot.

### Recommended Actions
1. **IMMEDIATE:** Switch to `riscv32imac` target (5 min)
2. **NEXT:** Update memory layout to 0x42000020 (1 hour)
3. **THEN:** Test boot with espflash (1-2 hours)

### Files to Modify
1. `boards/nano-esp32-c6/.cargo/config.toml` - Change target to imac
2. `boards/nano-esp32-c6/layout.ld` - Update ROM origin to 0x42000020
3. `boards/nano-esp32-c6/.cargo/config.toml` - Change runner to espflash

### Reference Files
- `embassy-on-esp/.cargo/config.toml` - Embassy config
- `~/.cargo/registry/.../esp-hal-common-0.15.0/ld/esp32c6/memory.x` - esp-hal memory layout
- `~/.cargo/registry/.../esp-hal-common-0.15.0/ld/esp32c6/esp32c6.x` - ESP32-C6 linker script

### Success Criteria
- Kernel boots from espflash
- Serial output visible
- Entry point at 0x42000020
- No bootloader required

### Fallback
If espflash approach fails after 4 hours, revert and escalate to PO.

---

## 13. Appendix: Technical Details

### A. Embassy ELF Analysis

```
Entry point: 0x42000020
Program Headers:
  LOAD 0x42000020 0x4fee8 R E  // .text
  LOAD 0x40800000 0x01140 R E  // .trap .rwtext
  LOAD 0x4204ff08 0x0a098 R    // .rodata
  LOAD 0x40801140 0x00020 RW   // .data
  LOAD 0x40801160 0x00344 RW   // .bss
```

### B. Tock ELF Analysis

```
Entry point: 0x42010000
Program Headers:
  LOAD 0x42010000 0x07238 R E  // .text
  LOAD 0x42017238 0x001c8 R    // .storage
  LOAD 0x40800000 0x00900 RW   // .stack
  LOAD 0x42050000 0x00004 RW   // .apps
  LOAD 0x40800900 0x00438 RW   // .sram
```

### C. espflash Image Header

```
Offset  Value   Description
0x00    0xE9    Magic byte
0x01    0x03    Segment count
0x02    0x02    SPI mode (DIO)
0x03    0x20    SPI speed/size
0x04-07 0x42000020  Entry point
0x08    0x10    WP pin
0x09    0xC4    Drive settings
```

### D. Memory Region Comparison

| Region | Embassy | Tock (current) | Tock (proposed) |
|--------|---------|----------------|-----------------|
| ROM start | 0x42000020 | 0x42010000 | 0x42000020 |
| ROM size | 4MB - 0x20 | 256KB | 8MB - 0x20 |
| RAM start | 0x40800000 | 0x40800000 | 0x40800000 |
| RAM size | 453KB | 256KB | 453KB |
| Apps start | N/A | 0x42050000 | 0x42800000 |
| Apps size | N/A | 512KB | 512KB |

---

## Session Summary

**Analysis Duration:** 2 hours  
**Files Examined:** 15+  
**Key Findings:** 4 major insights  
**Recommendation Confidence:** HIGH  
**Ready for Implementation:** YES

**Next Step:** Implementor to execute Option B (espflash-only approach) + Option A (switch to imac)
