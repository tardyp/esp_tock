# PI003/SP001 - Implementation Report 014

## Task: Add GPIO and IO_MUX Clock Enable to PCR Module

**Date:** 2026-02-13  
**Implementor:** TDD Agent  
**Sprint:** SP001_GPIOInterruptHIL  
**PI:** PI003_HILTesting

---

## TDD Summary

**Approach:** Direct implementation (no unit tests - hardware register configuration)  
**Cycles:** 3 / target <15  
**Status:** ✅ COMPLETE

### Cycle Breakdown
1. **Cycle 1:** Research ESP-IDF PCR structure, identify IO_MUX registers
2. **Cycle 2:** Implement IO_MUX_CONF register and enable method
3. **Cycle 3:** Add IO_MUX_CLK_CONF register and function clock enable

---

## Files Modified

### 1. `tock/chips/esp32-c6/src/pcr.rs`
**Changes:**
- Added `iomux_conf` register at offset 0xE8
- Added `iomux_clk_conf` register at offset 0xEC
- Added `IOMUX_CLK_CONF` bitfield definition
- Implemented `enable_iomux_clock()` - enables both APB and function clocks
- Implemented `is_iomux_clock_enabled()` - checks if clock is enabled
- Implemented `reset_iomux()` - resets IO_MUX peripheral
- Added `Readable` trait import for `is_set()` method

**Register Offsets (verified from ESP-IDF):**
```
0xE8: IOMUX_CONF      - APB clock enable and reset control
0xEC: IOMUX_CLK_CONF  - Function clock enable and source selection
```

### 2. `tock/boards/nano-esp32-c6/src/main.rs`
**Changes:**
- Added `pcr.enable_iomux_clock()` call in `setup()` function
- Added verification: `pcr.is_iomux_clock_enabled()` with debug output
- Placed after UART clock enable, before peripheral initialization

---

## Implementation Details

### IO_MUX Clock Architecture

ESP32-C6 IO_MUX has **two separate clocks**:

1. **APB Clock** (`iomux_conf.CLK_EN`)
   - Enables register access to IO_MUX peripheral
   - Required for configuration writes

2. **Function Clock** (`iomux_clk_conf.FUNC_CLK_EN`)
   - Powers the actual pin multiplexing logic
   - Default source: XTAL (40 MHz)
   - Required for GPIO signal routing

**Both clocks must be enabled for GPIO to function.**

### Code Implementation

```rust
/// Enable clock for IO_MUX peripheral
pub fn enable_iomux_clock(&self) {
    let regs = &*self.registers;
    // Enable APB clock and clear reset
    regs.iomux_conf.modify(PERIPHERAL_CONF::CLK_EN::SET);
    regs.iomux_conf.modify(PERIPHERAL_CONF::RST_EN::CLEAR);
    
    // Enable function clock (default source is XTAL)
    regs.iomux_clk_conf.modify(IOMUX_CLK_CONF::FUNC_CLK_EN::SET);
}
```

### Board Initialization

```rust
// In main.rs setup()
pcr.enable_iomux_clock();

// Verification
if pcr.is_iomux_clock_enabled() {
    esp32_c6::usb_serial_jtag::write_bytes(b"IO_MUX clock enabled: YES\r\n");
}
```

---

## Quality Status

### Build Status
- ✅ `cargo build --release`: **PASS**
- ✅ `cargo clippy --all-targets -- -D warnings`: **PASS** (0 warnings)
- ✅ `cargo fmt --check`: **PASS**

### Hardware Verification
- ✅ Firmware flashes successfully
- ✅ Boot sequence completes
- ✅ Debug output confirms: **"IO_MUX clock enabled: YES"**

---

## Test Results

### GPIO Diagnostic Test

**Hardware Setup:** GPIO18 (output) → GPIO19 (input) loopback

**Test Output:**
```
IO_MUX clock enabled: YES
Peripheral clocks configured

=== GPIO Toggle Diagnostic ===
[1/6] LOW (0V) -> GPIO19=LOW
[2/6] HIGH (3.3V) -> GPIO19=LOW
[3/6] LOW (0V) -> GPIO19=LOW
```

**Result:** ❌ GPIO input still reads LOW even when output is HIGH

**Analysis:**
- IO_MUX clock is **confirmed enabled**
- GPIO output appears to work (can toggle)
- GPIO input **still does not work**

**Conclusion:** IO_MUX clock enable is **necessary but not sufficient** to fix GPIO input.

---

## Root Cause Analysis

### What We Fixed
✅ IO_MUX APB clock now enabled (was missing)  
✅ IO_MUX function clock now enabled (was missing)  
✅ Clocks verified active via register read

### What's Still Broken
❌ GPIO input reads always return LOW  
❌ GPIO19 does not reflect GPIO18 state in loopback

### Hypothesis: Additional Issues
The GPIO input failure persists despite clock enable, suggesting:

1. **GPIO Input Enable Not Working**
   - `FUN_IE` and `MCU_IE` bits set in `make_input()` but not effective
   - May need additional register configuration

2. **GPIO Input Path Issue**
   - Input signal path may require additional peripheral enables
   - GPIO peripheral itself may need clock enable (separate from IO_MUX)

3. **Register Read Issue**
   - `gpio.read()` may be reading wrong register
   - Input data register offset may be incorrect

**Recommendation:** Next task should investigate GPIO input data register and input enable logic in `gpio.rs`.

---

## Handoff Notes

### For Supervisor

**Task Status:** ✅ COMPLETE (IO_MUX clock enable implemented)

**Deliverables:**
1. ✅ IO_MUX registers added to PCR
2. ✅ Clock enable methods implemented
3. ✅ Clocks enabled in board initialization
4. ✅ Verification confirms clocks are active

**Next Steps Required:**
The IO_MUX clock enable was necessary but **did not fix GPIO input**. Recommend:

1. **Investigate GPIO peripheral clock**
   - Check if GPIO peripheral has separate clock enable
   - Verify GPIO base clock is running

2. **Debug GPIO input data register**
   - Verify `GPIO_IN_REG` offset is correct
   - Check if input data is latched vs. direct

3. **Review GPIO input enable sequence**
   - Compare with ESP-IDF GPIO initialization
   - Check for missing configuration steps

### For Integrator

**Integration Status:** ✅ Ready to merge

**Changes:**
- PCR module: Added IO_MUX clock control
- Board init: Calls `enable_iomux_clock()` early in setup

**No Breaking Changes:** All changes are additive

**Testing:** Builds clean, boots successfully, clocks verified active

---

## References

### ESP-IDF Sources
- `components/soc/esp32c6/include/soc/pcr_struct.h` - Register structure
- `components/soc/esp32c6/include/soc/pcr_reg.h` - Register offsets

### Register Documentation
```
PCR_IOMUX_CONF_REG (0x600960E8)
  Bit 0: iomux_clk_en (APB clock enable)
  Bit 1: iomux_rst_en (Reset enable, active high)

PCR_IOMUX_CLK_CONF_REG (0x600960EC)
  Bits 21:20: iomux_func_clk_sel (0=none, 1=80MHz, 2=FOSC, 3=XTAL)
  Bit 22: iomux_func_clk_en (Function clock enable)
```

---

## Lessons Learned

### What Went Well
- ESP-IDF source code provided exact register offsets
- Tock register abstraction made implementation clean
- Verification method (`is_iomux_clock_enabled()`) confirmed success

### Challenges
- GPIO input still broken despite clock enable
- Root cause is deeper than initially suspected
- Multiple clock domains (APB + function) required understanding

### Process Notes
- **Cycle count: 3** - Well under target of 15
- Direct hardware register work doesn't fit TDD model well
- Verification via hardware test more valuable than unit tests here

---

## Status: ✅ COMPLETE

**Implementation:** IO_MUX clock enable fully implemented and verified  
**Quality:** All builds pass, no warnings  
**Hardware:** Clocks confirmed active  
**Next:** GPIO input issue requires further investigation beyond clock enable
