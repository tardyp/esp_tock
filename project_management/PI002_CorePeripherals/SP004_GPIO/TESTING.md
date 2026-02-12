# SP004 GPIO Hardware Testing Guide

## Overview

This document describes the hardware testing infrastructure for the ESP32-C6 GPIO driver (SP004).

## Test Infrastructure

### Files Created

1. **GPIO Test Module:** `tock/boards/nano-esp32-c6/src/gpio_tests.rs`
   - Compact test suite for GPIO functionality
   - 148 lines of test code
   - Feature-gated to avoid ROM overflow

2. **Test Script:** `scripts/test_sp004_gpio.sh`
   - Automated test harness
   - 10 comprehensive test cases
   - Manual test orchestration

3. **Cargo Feature:** `tock/boards/nano-esp32-c6/Cargo.toml`
   - Added `gpio_tests` feature flag
   - Enables conditional compilation of test code

## ROM Size Constraint

**Problem:** ESP32-C6 bootloader ROM limited to 32KB (0x8000 bytes)

**Current Status:**
- Base firmware (console + alarm + UART): ~29.5KB ✅ Fits in ROM
- Test firmware (base + GPIO tests): ~32.6KB ❌ Exceeds ROM

**Solution:** Feature flag for optional test code

```bash
# Base firmware (no tests) - BUILDS SUCCESSFULLY
cargo build --release

# Test firmware (with tests) - EXCEEDS ROM
cargo build --release --features gpio_tests
```

## Testing Approach

Due to ROM constraints, GPIO testing uses a **hybrid approach**:

1. **Automated Tests** (via test script)
   - System boot verification
   - GPIO driver initialization
   - Serial output capture
   - Stability checks

2. **Manual Tests** (hardware interaction)
   - GPIO output (LED control)
   - GPIO input (button reading)
   - Pull-up/pull-down resistors
   - GPIO interrupts
   - Multiple pin operation

## Running Tests

### Prerequisites

```bash
# Install espflash
cargo install espflash

# Build firmware
cd tock/boards/nano-esp32-c6
cargo build --release
```

### Execute Test Script

```bash
# Run automated tests
./scripts/test_sp004_gpio.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board 30
```

### Manual Test Procedure

The test script will prompt for manual verification of:

1. **GPIO Output** - LED on GPIO5 turns on/off/toggles
2. **GPIO Input** - Pull-up reads HIGH, pull-down reads LOW
3. **GPIO Loopback** - GPIO5 output → GPIO6 input
4. **GPIO Interrupts** - Rising edge triggers callback
5. **Multiple Pins** - GPIO5, 8, 9 operate independently

## Hardware Setup

### Required Equipment

- ESP32-C6 development board
- 3x LEDs + 220Ω resistors
- Jumper wires
- Breadboard (optional)
- Multimeter (optional)

### Pin Assignments

| GPIO | Function | Usage |
|------|----------|-------|
| GPIO5 | Output | LED, loopback source, stress test |
| GPIO6 | Input | Pull resistors, loopback destination |
| GPIO7 | Input+IRQ | Interrupt testing |
| GPIO8 | Output | Multiple pin test |
| GPIO9 | Output | Multiple pin test |

### Wiring

```
GPIO5 ── [220Ω] ── LED1 ── GND
GPIO5 ── Jumper ── GPIO6 (for loopback)
GPIO7 ── Jumper ── 3.3V/GND (for interrupts)
GPIO8 ── [220Ω] ── LED2 ── GND
GPIO9 ── [220Ω] ── LED3 ── GND
```

## Test Results

Test artifacts are saved to:
```
project_management/PI002_CorePeripherals/SP004_GPIO/hardware_test_YYYYMMDD_HHMMSS/
├── flash.log
├── serial_output.log
├── test5_gpio_output.result
├── test6_gpio_input.result
├── test7_gpio_loopback.result
├── test8_gpio_interrupt.result
└── test9_gpio_multiple.result
```

## Expected Outcomes

### Automated Tests (4/10)

✅ Flash Firmware  
✅ Monitor Serial Output  
✅ System Boot  
✅ GPIO Initialization  
✅ System Stability  

### Manual Tests (5/10)

⏸️ GPIO Output (requires LED observation)  
⏸️ GPIO Input (requires voltage measurement)  
⏸️ GPIO Loopback (requires jumper wire)  
⏸️ GPIO Interrupts (requires manual trigger)  
⏸️ Multiple Pins (requires LED observation)  

## Future Improvements

1. **ROM Optimization**
   - Investigate LTO (Link-Time Optimization)
   - Consider increasing ROM allocation in linker script
   - Profile binary size during development

2. **Test Automation**
   - External GPIO controller for automated testing
   - Logic analyzer integration
   - Automated interrupt generation

3. **Test Coverage**
   - Test all 31 GPIO pins
   - Drive strength configuration
   - Open-drain mode
   - Simultaneous interrupts
   - Long-duration stability tests

## Troubleshooting

### Build Fails with ROM Overflow

**Symptom:**
```
error: section '.text' will not fit in region 'rom': overflowed by XXXX bytes
```

**Solution:**
- Build without `--features gpio_tests`
- Use base firmware for manual testing
- Follow manual test procedures in test script

### Test Script Fails to Flash

**Symptom:**
```
[ERROR] Flashing failed
```

**Solution:**
- Check USB connection
- Verify correct serial port: `FLASH_PORT=/dev/ttyUSB0 ./scripts/test_sp004_gpio.sh ...`
- Ensure espflash is installed: `cargo install espflash`
- Try manual flash: `espflash flash --chip esp32c6 --port /dev/ttyUSB0 <kernel.elf>`

### No Serial Output

**Symptom:**
```
[FAIL] No serial output captured
```

**Solution:**
- Check serial port permissions
- Verify board is powered and connected
- Try different USB cable/port
- Increase test duration: `./scripts/test_sp004_gpio.sh <kernel.elf> 60`

## References

- GPIO Driver Implementation: `tock/chips/esp32-c6/src/gpio.rs`
- GPIO Usage Guide: `project_management/PI002_CorePeripherals/SP004_GPIO/README.md`
- TDD Report: `project_management/PI002_CorePeripherals/SP004_GPIO/002_implementor_tdd.md`
- Integration Report: `project_management/PI002_CorePeripherals/SP004_GPIO/003_integrator_hardware.md`
