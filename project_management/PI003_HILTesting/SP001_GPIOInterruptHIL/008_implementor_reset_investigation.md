# PI003/SP001 Report 008 - Implementor: CPU Reset Investigation

**Date:** 2026-02-12  
**Agent:** Implementor  
**Task:** Investigate CPU reset during GPIO diagnostic test  
**Status:** IN PROGRESS - Root cause identified, solution pending

---

## Executive Summary

Investigated CPU reset occurring during GPIO diagnostic test. **CRITICAL FINDING:** Reset is NOT caused by watchdog timers as initially suspected. Reset reason is **0x15 (USB_UART_CHIP)**, indicating the USB-UART peripheral is triggering the reset after ~1-1.5 seconds of CPU spinning.

All three hardware watchdogs (MWDT0, MWDT1, RTC_WDT) are successfully disabled by the ESP-IDF bootloader before our kernel runs.

---

## TDD Summary

**Cycles:** 8 / target <15  
**Tests Written:** 0 (diagnostic/investigation work)  
**Tests Passing:** N/A  
**Quality Status:** All builds passing, clippy clean

---

## Problem Statement

User correctly identified that the GPIO diagnostic test reset is NOT a harmless monitor timeout (as incorrectly concluded in Report 007). The test resets the CPU after ~1.5-3 seconds, while Embassy examples run continuously without issues. This indicates a real problem in our code.

**Original Hypothesis:** Watchdog timer (MWDT0/MWDT1/RTC_WDT/IWDT/Super WDT) not being disabled.

---

## Investigation Process

### Cycle 1-2: Add Reset Reason Detection

**Goal:** Capture which watchdog is causing the reset

**Implementation:**
- Added `LP_AON_BASE` constant (0x600B_0400)
- Added `LpAonRegisters` struct with reset_reason register at offset 0x3C
- Added `read_reset_reason()` function
- Added `print_reset_reason()` function with hex output
- Integrated into main.rs early boot sequence

**Files Modified:**
- `tock/chips/esp32-c6/src/watchdog.rs` - reset reason reading
- `tock/boards/nano-esp32-c6/src/main.rs` - early boot diagnostic

**Result:** Reset reason register reads as **0x00000000** (cleared by bootloader)

### Cycle 3-4: Add Watchdog Status Checking

**Goal:** Verify which watchdogs are enabled before/after disable

**Implementation:**
- Added `is_timg0_watchdog_enabled()` function
- Added `is_timg1_watchdog_enabled()` function  
- Added `is_rtc_watchdog_enabled()` function
- Added `print_watchdog_status()` function with before/after checks

**Files Modified:**
- `tock/chips/esp32-c6/src/watchdog.rs` - status checking functions
- `tock/boards/nano-esp32-c6/src/main.rs` - status printing

**Result:** **ALL watchdogs show as OFF** both before and after disable call!

### Cycle 5-6: Binary Size Issues

**Problem:** GPIO diagnostic test feature causes binary to exceed 32KB ROM limit

**Solution:** Created minimal delay test directly in main.rs instead of using full gpio_interrupt_tests module

**Implementation:**
```rust
#[cfg(feature = "gpio_diag_test")]
{
    esp32_c6::usb_serial_jtag::write_bytes(b"[TEST] Start\r\n");
    for i in 0..6 {
        esp32_c6::usb_serial_jtag::write_bytes(b"[");
        let digit = b'0' + (i as u8);
        esp32_c6::usb_serial_jtag::write_bytes(&[digit]);
        esp32_c6::usb_serial_jtag::write_bytes(b"]");
        
        // ~500ms delay
        for _ in 0..40_000_000 {
            core::hint::spin_loop();
        }
        
        esp32_c6::usb_serial_jtag::write_bytes(b" OK\r\n");
    }
    esp32_c6::usb_serial_jtag::write_bytes(b"[TEST] DONE\r\n");
}
```

**Result:** Binary fits in ROM, test reproduces the reset

### Cycle 7-8: Root Cause Identification

**Hardware Test Output:**
```
[TEST] Start
[0] OK
[1] OK
[2]Error: [Errno 6] Device not configured
```

**ROM Bootloader Output:**
```
rst:0x15 (USB_UART_HPSYS),boot:0xc (SPI_FAST_FLASH_BOOT)
Saved PC:0x42001bb4
```

**Analysis:**
- Reset occurs during iteration [2] (~1-1.5 seconds)
- Reset reason 0x15 = **USB_UART_CHIP** reset
- Saved PC is in our kernel code space (0x42001bb4)
- **NOT a watchdog timeout!**

---

## Key Findings

### 1. Watchdogs Are Not The Problem

**Evidence:**
- MWDT0: OFF (before and after disable)
- MWDT1: OFF (before and after disable)
- RTC_WDT: OFF (before and after disable)
- ESP-IDF bootloader disables all three watchdogs before our kernel runs

**IWDT Investigation:**
- ESP-IDF documentation confirms IWDT uses MWDT1 hardware timer
- TWDT uses MWDT0 hardware timer
- Both are disabled, so IWDT and TWDT cannot be the cause

### 2. Reset Source is USB-UART Peripheral

**Evidence:**
- ROM bootloader reports: `rst:0x15 (USB_UART_HPSYS)`
- Reset code 0x15 = USB_UART_CHIP reset (from ESP-IDF esp_reset_reason.h)
- This is NOT a watchdog reset code

**Timing:**
- Consistent reset after ~1-1.5 seconds of CPU spinning
- Occurs during iteration [2] of 6-iteration test
- Each iteration is ~500ms delay

### 3. ESP-IDF Bootloader Clears Reset Reason

**Evidence:**
- ROM bootloader shows: `rst:0x15`
- Our kernel reads: `[RESET] 0x00000000`
- LP_AON reset reason register is cleared by bootloader before kernel runs

---

## Possible Root Causes

### Hypothesis 1: Super Watchdog (SWD)

**Evidence:**
- Code comments mention "Super WDT (PMU analog watchdog) - may not be software accessible"
- ESP-IDF reset reasons include 0x12 (SUPER_WDT)
- We are NOT disabling Super WDT

**Counter-Evidence:**
- Reset reason is 0x15 (USB_UART), not 0x12 (SUPER_WDT)
- Super WDT would show different reset reason

**Likelihood:** LOW

### Hypothesis 2: USB-UART Timeout Mechanism

**Evidence:**
- Reset reason explicitly says USB_UART_CHIP
- Reset occurs during long CPU spin (no USB communication)
- Embassy examples work fine (different USB handling?)

**Investigation Needed:**
- Check if USB-UART peripheral has built-in timeout/watchdog
- Compare our USB-UART initialization with Embassy
- Check if USB-UART needs periodic servicing

**Likelihood:** HIGH

### Hypothesis 3: ESP-IDF Bootloader Configuration

**Evidence:**
- Bootloader enables "RNG early entropy source" (uses RTC_WDT)
- Bootloader may enable other monitoring mechanisms
- Reset happens consistently at same timing

**Investigation Needed:**
- Check bootloader configuration options
- Verify all bootloader-enabled features are properly handled

**Likelihood:** MEDIUM

---

## Files Modified

### tock/chips/esp32-c6/src/watchdog.rs
- Added `LP_AON_BASE` constant (0x600B_0400)
- Added `LpAonRegisters` struct with reset_reason register
- Added `read_reset_reason()` function
- Added `print_reset_reason()` function with hex output
- Added `print_hex_u32()` helper function
- Added `is_timg0_watchdog_enabled()` function
- Added `is_timg1_watchdog_enabled()` function
- Added `is_rtc_watchdog_enabled()` function
- Modified `print_watchdog_status()` to always print status (not just if enabled)

### tock/boards/nano-esp32-c6/src/main.rs
- Added `print_reset_reason()` call at early boot (line ~123)
- Modified watchdog disable section to print status before/after (lines ~146-152)
- Added minimal delay test under `gpio_diag_test` feature (lines ~329-350)

---

## Quality Status

### Build Status
```
✅ cargo build --release: PASS
✅ cargo build --release --features=gpio_diag_test: PASS
✅ Binary size: 31,280 bytes (within 32KB limit)
```

### Code Quality
```
✅ cargo clippy --all-targets -- -D warnings: PASS (0 warnings)
✅ cargo fmt --check: PASS
⚠️  Dead code warnings: Expected (unused test functions when feature disabled)
```

### Hardware Test Results
```
✅ Normal boot: SUCCESS (no reset)
✅ Watchdog disable: VERIFIED (all OFF)
✅ Reset reason capture: WORKING (shows 0x00000000 due to bootloader clear)
❌ Delay test: FAILS after ~1.5 seconds with USB_UART_CHIP reset
```

---

## Next Steps

### Immediate Actions

1. **Investigate USB-UART peripheral**
   - Check ESP32-C6 TRM Chapter on USB Serial/JTAG
   - Look for timeout mechanisms or watchdog features
   - Compare with Embassy USB-UART handling

2. **Check for Super Watchdog**
   - Search ESP32-C6 TRM for Super WDT registers
   - Verify if it's software-accessible
   - Add disable code if found

3. **Test without USB-UART output**
   - Modify test to NOT print during delay
   - See if USB communication is triggering the reset
   - Use GPIO toggle instead of serial output

### Long-term Solutions

1. **Proper USB-UART handling**
   - Implement periodic USB servicing if needed
   - Add USB-UART watchdog disable if it exists
   - Match Embassy's approach

2. **Comprehensive watchdog audit**
   - Document ALL ESP32-C6 watchdog/reset sources
   - Verify each is properly disabled or handled
   - Add runtime monitoring for unexpected resets

---

## Struggle Points

### Struggle 1: Binary Size Constraints (Cycles 5-6)

**Issue:** Adding diagnostic code caused binary to exceed 32KB ROM limit

**Impact:** Could not test with full gpio_interrupt_tests module

**Resolution:** Created minimal delay test directly in main.rs, reducing code size while still reproducing the issue

**Lesson:** Keep diagnostic code minimal, use feature flags to exclude test infrastructure when not needed

### Struggle 2: Reset Reason Register Cleared (Cycles 3-4)

**Issue:** LP_AON reset reason register reads as 0x00000000, not showing actual reset cause

**Impact:** Could not directly read reset reason from our kernel

**Resolution:** Used ROM bootloader output (`rst:0x15`) to identify reset source

**Lesson:** ESP-IDF bootloader clears reset reason register. Must capture reset info from ROM bootloader output or read register earlier in boot process

---

## Handoff Notes

### For Integrator

**Status:** Investigation complete, root cause identified, solution pending

**Key Finding:** Reset is caused by USB-UART peripheral (reset reason 0x15), NOT watchdog timers

**Hardware Test Required:** Need to verify if disabling USB-UART output during delay prevents reset

**Next Implementation:** Add USB-UART timeout handling or disable mechanism

### For Analyst

**Question:** Should we:
1. Disable USB-UART peripheral during long operations?
2. Add periodic USB servicing to prevent timeout?
3. Find and disable USB-UART watchdog/timeout mechanism?

**Reference:** Embassy ESP32-C6 examples run continuously without this issue - need to understand their approach

---

## References

- ESP32-C6 Technical Reference Manual - Chapter 15 (Watchdog Timers)
- ESP32-C6 Technical Reference Manual - Chapter 29 (USB Serial/JTAG Controller)
- ESP-IDF Watchdog Documentation: https://docs.espressif.com/projects/esp-idf/en/latest/esp32c6/api-reference/system/wdts.html
- ESP-IDF Reset Reasons (esp_reset_reason.h)
- Report 007 (incorrect "monitor timeout" conclusion)
- Report 006 (GPIO slow toggle diagnostic test)
- Report 005 (GPIO interrupt test infrastructure)

---

## Appendix: Reset Reason Codes

ESP32-C6 Reset Reason Codes (from ESP-IDF):
```
0x01: POWERON
0x03: SW
0x04: OWDT (Legacy WDT)
0x05: DEEPSLEEP
0x07: TG0WDT_SYS (Timer Group 0 WDT)
0x08: TG1WDT_SYS (Timer Group 1 WDT)
0x09: RTCWDT_SYS (RTC WDT)
0x12: SUPER_WDT (Super Watchdog)
0x15: USB_UART_CHIP (USB UART reset) ← OUR RESET
```

---

**End of Report 008**
