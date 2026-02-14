# PI003/SP002 Report 008 - Implementor: USB-UART Chip Reset Disable

**Date:** 2026-02-14  
**Agent:** Implementor  
**Task:** Disable USB-UART chip reset mechanism  
**Status:** COMPLETE - Ready for hardware testing  
**Issue:** #16 (USB-UART watchdog)

---

## TDD Summary

| Metric | Value |
|--------|-------|
| Tests written | 4 |
| Tests passing | 4 |
| Cycles | 3 / target <15 |
| Red-Green-Refactor compliance | 100% |

### TDD Cycle Details

**Cycle 1 (RED):** Added CHIP_RST register structure and bitfields
- Extended `UsbSerialJtagRegisters` with `_reserved` padding and `chip_rst` field
- Added `CHIP_RST` bitfield with `USB_UART_CHIP_RST_DIS` at bit 2
- Initial test failed due to `modify()` return type issue

**Cycle 2 (GREEN):** Fixed test and verified register layout
- Fixed `test_chip_rst_dis_bit_position` to use mutable reference
- All 4 new tests passing

**Cycle 3 (REFACTOR):** Integrated into watchdog disable and added documentation
- Added `disable_usb_uart_chip_reset()` to `disable_watchdogs()`
- Updated `print_watchdog_status()` to include USB_RST status
- Enhanced documentation with usage examples

---

## Files Modified

| File | Purpose |
|------|---------|
| `tock/chips/esp32-c6/src/usb_serial_jtag.rs` | Added CHIP_RST register and disable function |
| `tock/chips/esp32-c6/src/watchdog.rs` | Integrated USB-UART disable into `disable_watchdogs()` |

---

## Implementation Details

### 1. Register Structure Extension

Added CHIP_RST register at offset 0x4C:

```rust
#[repr(C)]
struct UsbSerialJtagRegisters {
    // ... existing registers (0x00-0x18)
    ep1: ReadWrite<u32>,
    ep1_conf: ReadWrite<u32>,
    int_raw: ReadWrite<u32>,
    int_st: ReadWrite<u32>,
    int_ena: ReadWrite<u32>,
    int_clr: ReadWrite<u32>,
    conf0: ReadWrite<u32>,
    
    // Padding to reach offset 0x4C
    _reserved: [u32; 12],
    
    // CHIP_RST at offset 0x4C
    chip_rst: ReadWrite<u32, CHIP_RST::Register>,
}
```

### 2. Bitfield Definition

```rust
register_bitfields![u32,
    CHIP_RST [
        RTS OFFSET(0) NUMBITS(1) [],
        DTR OFFSET(1) NUMBITS(1) [],
        USB_UART_CHIP_RST_DIS OFFSET(2) NUMBITS(1) []
    ]
];
```

### 3. Disable Function

```rust
pub unsafe fn disable_usb_uart_chip_reset() {
    let regs = REGISTERS;
    regs.chip_rst.modify(CHIP_RST::USB_UART_CHIP_RST_DIS::SET);
}
```

### 4. Integration into Watchdog Disable

```rust
pub unsafe fn disable_watchdogs() {
    disable_timg0_watchdog();
    disable_timg1_watchdog();
    disable_rtc_watchdog();
    // Disable USB-UART chip reset (Issue #16)
    crate::usb_serial_jtag::disable_usb_uart_chip_reset();
}
```

---

## Quality Status

| Check | Status |
|-------|--------|
| `cargo build` | PASS |
| `cargo build --release` | PASS |
| `cargo build --features timer_alarm_tests` | PASS |
| `cargo test` | PASS (25 tests) |
| `cargo clippy --all-targets -- -D warnings` | PASS (0 warnings) |
| `cargo fmt --check` | PASS |

---

## Test Coverage

| Test | Purpose | Status |
|------|---------|--------|
| `test_usb_serial_jtag_base_address` | Verify base address 0x6000_F000 | PASS |
| `test_register_structure_size` | Verify structure is 80 bytes | PASS |
| `test_chip_rst_register_offset` | Verify CHIP_RST at offset 0x4C | PASS |
| `test_chip_rst_dis_bit_position` | Verify bit 2 is USB_UART_CHIP_RST_DIS | PASS |

---

## Hardware Testing Required

### Test 1: Basic Verification
After flashing, verify USB_RST status in boot output:
```
Disabling watchdogs...
  MWDT0=off
  MWDT1=off
  RTC=off
  USB_RST=disabled
Watchdogs disabled
```

### Test 2: Long Delay Test
Run a 10-second busy-wait loop:
```rust
debug!("Starting 10-second delay test...");
for _ in 0..10 {
    for _ in 0..80_000_000 {
        core::hint::spin_loop();
    }
    debug!(".");
}
debug!(" PASS");
```

**Expected:** Board completes without reset (previously reset after ~1.5s)

### Test 3: Timer Alarm Test Suite
```bash
cd tock/boards/nano-esp32-c6
cargo build --release --features timer_alarm_tests
# Flash and run
```

**Expected:** All 20 timer tests execute without reset

### Test 4: GPIO Regression
```bash
cargo build --release --features gpio_interrupt_tests
# Flash and run
```

**Expected:** GPIO tests still pass (no regression)

---

## Optional: Revert WFI Workaround

After confirming USB-UART reset is disabled, the `sleep()` workaround in `chip.rs` can be reverted:

**Current (workaround):**
```rust
fn sleep(&self) {
    // WORKAROUND: Don't use WFI as it causes USB-UART to disconnect
    for _ in 0..1000 {
        core::hint::spin_loop();
    }
}
```

**After fix (proper WFI):**
```rust
fn sleep(&self) {
    unsafe { core::arch::asm!("wfi") };
}
```

**Note:** Test WFI separately to confirm USB serial still works.

---

## Handoff Notes for Integrator

### Ready for Hardware Testing
- [x] Code compiles without errors
- [x] All unit tests pass
- [x] Clippy clean (0 warnings)
- [x] Formatting correct
- [x] Integrated into existing watchdog disable flow

### What to Verify
1. Boot message shows `USB_RST=disabled`
2. Long busy-wait loops complete without reset
3. Timer alarm tests run to completion
4. USB serial console remains functional
5. GPIO tests pass (no regression)

### Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| USB serial stops working | Low | High | Test serial output after disable |
| Other USB features affected | Low | Medium | Only affects reset, not data transfer |
| Register access fails | Very Low | High | Used read-modify-write pattern |

---

## Appendix: Full Test Output

```
running 25 tests
test chip::tests::test_chip_creation_with_intc ... ok
test chip::tests::test_no_pending_interrupts_initially ... ok
test chip::tests::test_peripherals_creation ... ok
test gpio::tests::test_gpio_clock_gate_api_exists ... ok
test gpio::tests::test_gpio_clock_gate_raw_pointer_address ... ok
test gpio::tests::test_gpio_clock_gate_register_offset ... ok
test gpio::tests::test_gpio_controller_creation ... ok
test gpio::tests::test_gpio_controller_get_pin ... ok
test gpio::tests::test_gpio_pin_creation ... ok
test gpio::tests::test_gpio_pin_invalid - should panic ... ok
test gpio::tests::test_gpio_pin_mask ... ok
test intc::tests::test_intmtx_base_address ... ok
test intc::tests::test_multiple_saved_interrupts ... ok
test intc::tests::test_plic_base_address ... ok
test intc::tests::test_save_restore_logic ... ok
test interrupts::tests::test_interrupt_numbers_unique ... ok
test plic::tests::test_plic_base_address ... ok
test plic::tests::test_plic_register_layout ... ok
test plic::tests::test_priority_array_size ... ok
test tests::test_console_uart0_interrupt ... ok
test tests::test_timer_frequency_type ... ok
test usb_serial_jtag::tests::test_chip_rst_dis_bit_position ... ok
test usb_serial_jtag::tests::test_chip_rst_register_offset ... ok
test usb_serial_jtag::tests::test_register_structure_size ... ok
test usb_serial_jtag::tests::test_usb_serial_jtag_base_address ... ok

test result: ok. 25 passed; 0 failed; 0 ignored; 0 measured; 0 filtered out
```

---

**End of Report 008**
