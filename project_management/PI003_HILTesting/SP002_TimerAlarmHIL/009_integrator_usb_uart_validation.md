# PI003/SP002 Report 009 - Integrator: USB-UART Reset Validation

**Date:** 2026-02-14  
**Agent:** Integrator  
**Task:** Hardware validation of USB-UART chip reset fix  
**Status:** FAIL - USB-UART reset still occurring  
**Issue:** #16 (USB-UART watchdog)

---

## Executive Summary

**VERDICT: FAIL** - The USB-UART chip reset disable implementation does NOT prevent device resets.

Despite setting both known disable bits:
- `USB_DEVICE.CHIP_RST.USB_UART_CHIP_RST_DIS` (bit 2 at 0x6000_F04C)
- `LP_AON.USB.RESET_DISABLE` (bit 31 at 0x600B_1044)

The device still resets after ~9-10 seconds with reset reason `rst:0x15 (USB_UART_HPSYS)`.

---

## Hardware Tests Executed

| Test | Status | Notes |
|------|--------|-------|
| Boot to kernel | PASS | Serial output verified |
| Watchdog status display | PASS | Shows USB_RST=disabled |
| Timer tests 1-7 | PASS | All timing accurate |
| Timer test 8 (0ms alarm) | FAIL | Device resets at this point |
| Full 20-test suite | FAIL | Only 7/20 tests complete |

---

## Debug Findings

### Register Values Observed

**USB_DEVICE.CHIP_RST (0x6000_F04C):**
```
First boot:  Before=0x07, After=0x07
Second boot: Before=0x05, After=0x05
```
- Bit 2 (USB_UART_CHIP_RST_DIS) is ALREADY SET by bootloader
- Bits 0,1 (RTS, DTR) indicate reset was detected

**LP_AON.USB (0x600B_1044):**
```
Before=0x80000000, After=0x80000000
```
- Bit 31 (RESET_DISABLE) is ALREADY SET by bootloader

### Reset Timing

| Run | Time to Reset | Last Test Completed |
|-----|---------------|---------------------|
| 1 | 9.7s | Test 7 (500ms) |
| 2 | 9.6s | Test 7 (500ms) |
| 3 | 9.5s | Test 7 (500ms) |

Reset consistently occurs:
- After ~9-10 seconds from boot
- When Test 8 (0ms alarm) is set
- With ~8 seconds of no serial output before reset

### Reset Reason Analysis

```
rst:0x15 (USB_UART_HPSYS)
```

This corresponds to `CoreUsbUart` (0x15) in ESP32-C6 reset reasons:
- "USB UART resets the digital core"
- This is the exact reset source we're trying to disable

---

## Root Cause Analysis

### Hypothesis 1: Disable Bits Don't Work (LIKELY)
The `USB_UART_CHIP_RST_DIS` and `LP_AON.USB.RESET_DISABLE` bits may not actually prevent the USB-UART reset. This could be:
- A hardware bug in ESP32-C6 rev 0.1
- Undocumented behavior
- Bits only prevent certain types of resets

### Hypothesis 2: Different Reset Mechanism
There may be another reset mechanism we haven't discovered:
- USB PHY timeout
- USB enumeration failure
- USB suspend/resume handling

### Hypothesis 3: Kernel Blocking USB Servicing
The kernel may be blocking USB interrupt handling:
- Timer interrupt handler taking too long
- Interrupt priority issues
- USB peripheral not being serviced

### Hypothesis 4: WFI Workaround Insufficient
The current WFI workaround uses busy-wait:
```rust
fn sleep(&self) {
    for _ in 0..1000 {
        core::hint::spin_loop();
    }
}
```
This may not be sufficient to keep USB active.

---

## Code Changes Made

### Files Modified (Debug Only - Reverted)

| File | Change | Status |
|------|--------|--------|
| `usb_serial_jtag.rs` | Added LP_AON.USB register write | KEPT |
| `usb_serial_jtag.rs` | Added debug prints | REVERTED |
| `main.rs` | Added watchdog status print | REVERTED |

### Current Implementation

```rust
// usb_serial_jtag.rs
pub unsafe fn disable_usb_uart_chip_reset() {
    let regs = REGISTERS;
    
    // Method 1: USB_DEVICE.CHIP_RST bit 2
    regs.chip_rst.modify(CHIP_RST::USB_UART_CHIP_RST_DIS::SET);
    
    // Method 2: LP_AON.USB bit 31
    let lp_aon_usb = LP_AON_USB_REG as *mut u32;
    let current = core::ptr::read_volatile(lp_aon_usb);
    core::ptr::write_volatile(lp_aon_usb, current | (1 << 31));
}
```

---

## Escalation to @implementor

### Issue: USB-UART Reset Not Disabled

**Evidence:**
- Both known disable bits are set (verified by reading back)
- Device still resets after ~9-10 seconds
- Reset reason is `CoreUsbUart` (0x15)
- Bootloader already sets these bits, suggesting they're known

**Root Cause:** Unknown - requires deeper investigation

**Why Not Light Fix:**
- Requires understanding of USB Serial JTAG hardware
- May need to service USB interrupts
- May need to modify kernel main loop
- May require ESP-IDF/esp-hal reference implementation study

### Suggested Investigation Areas

1. **Check ESP-IDF source code** for how they handle USB Serial JTAG
2. **Check if USB interrupts need handling** to prevent timeout
3. **Check USB PHY configuration** for timeout settings
4. **Check if there's a USB "keep-alive" mechanism** needed
5. **Test with actual WFI instruction** to see if it makes a difference
6. **Check ESP32-C6 errata** for known issues

---

## Serial Output Captures

### Boot Sequence (Successful)
```
=== Tock Kernel Starting ===
Deferred calls initialized
Disabling watchdogs...
Watchdogs disabled
Configuring peripheral clocks...
IO_MUX clock enabled: YES
GPIO clock gate enabled: YES
Peripheral clocks configured
[INTC] Initializing interrupt controller
[INTC] Mapping interrupts
[INTC] Enabling interrupts
[INTC] Interrupt controller ready
Starting timer...
Timer started
Setting up UART console...
UART0 configured
Console initialized
Platform setup complete

*** Hello World from Tock! ***
```

### Timer Tests (Partial Success)
```
=== Timer Alarm Accuracy Test E Starting ===
[TEST] Tolerance: +/-10%
[TEST] Test count: 20

[TEST 1/20] Setting 100ms alarm
  -> Fired: actual=100ms expected=100ms error=0ms PASS
[TEST 2/20] Setting 200ms alarm
  -> Fired: actual=200ms expected=200ms error=0ms PASS
[TEST 3/20] Setting 25ms alarm
  -> Fired: actual=25ms expected=25ms error=0ms PASS
[TEST 4/20] Setting 25ms alarm
  -> Fired: actual=25ms expected=25ms error=0ms PASS
[TEST 5/20] Setting 25ms alarm
  -> Fired: actual=25ms expected=25ms error=0ms PASS
[TEST 6/20] Setting 25ms alarm
  -> Fired: actual=25ms expected=25ms error=0ms PASS
[TEST 7/20] Setting 500ms alarm
  -> Fired: actual=500ms expected=500ms error=0ms PASS
[TEST 8/20] Setting 0ms alarm
<DEVICE RESET>
```

---

## Handoff Notes

### For @implementor

The USB-UART chip reset disable is NOT working. Both known disable bits are set but the device still resets. This requires deeper investigation into:

1. How ESP-IDF handles USB Serial JTAG
2. Whether USB interrupts need to be serviced
3. Whether there's a USB keep-alive mechanism
4. ESP32-C6 hardware errata

### Current State

- Code compiles and runs
- 7/20 timer tests pass before reset
- USB serial console works until reset
- All watchdog timers are disabled
- Both USB reset disable bits are set

### What's Blocking

- Cannot run tests longer than ~9 seconds
- Cannot complete full timer test suite
- Cannot validate long-running operations

---

## Debug Code Status

- [x] All debug prints removed from production code
- [x] LP_AON.USB register write kept (may help)
- [x] Code compiles cleanly

---

**End of Report 009**
