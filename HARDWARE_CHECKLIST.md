# ESP32-C6 Hardware Testing Checklist

Use this checklist when setting up or testing ESP32-C6 hardware.

## Initial Setup

- [ ] Hardware connected via USB
- [ ] Both USB ports visible in system
  - [ ] ESP32-C6 USB-JTAG port (1001:303A)
  - [ ] CH343 UART port (55D3:1A86)
- [ ] espflash built (`cd espflash && cargo build --release`)
- [ ] Python dependencies installed (`pip3 install pyserial`)
- [ ] Rust target installed (`rustup target add riscv32imc-unknown-none-elf`)

## Port Verification

Run: `./espflash/target/release/espflash list-ports`

Expected output:
- [ ] Espressif USB JTAG/serial debug unit (1001:303A)
- [ ] USB Single Serial (55D3:1A86)

## Board Detection

Run: `./espflash/target/release/espflash board-info --port <FLASH_PORT>`

Expected:
- [ ] Chip type: esp32c6
- [ ] Flash size: 16MB
- [ ] Features: WiFi 6, BT 5

## Build Kernel

```bash
cd tock/boards/nano-esp32-c6
cargo build --release
cd ../../..
```

Verify:
- [ ] Build succeeds without errors
- [ ] Binary exists: `tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board`

## Flash Firmware

Run: `./scripts/flash_esp32c6.sh <path-to-kernel>`

Expected:
- [ ] Flashing completes without errors
- [ ] Board info displayed after flash
- [ ] No "permission denied" errors

## Monitor Serial Output

Run: `python3 scripts/monitor_serial.py <UART_PORT> 115200 10`

Expected:
- [ ] Script starts without errors
- [ ] Serial port opens successfully
- [ ] Output captured (if firmware outputs to UART)

## Automated Testing

Run: `./scripts/test_esp32c6.sh <path-to-kernel>`

Expected:
- [ ] Test 1: Board Detection - PASS
- [ ] Test 2: Flash Firmware - PASS
- [ ] Test 3: Reset Board - PASS
- [ ] Test 4: Monitor Serial - PASS (or INCONCLUSIVE if no UART output)
- [ ] Test 5: Verify Output - PASS (if firmware outputs expected messages)
- [ ] Test results directory created

## Verify Boot

Expected serial output (if firmware outputs to UART):
- [ ] Initialization message appears
- [ ] No panic messages
- [ ] No unexpected resets

## Common Issues

### Port Not Found
- [ ] Check USB cables are connected
- [ ] Run `ls /dev/tty* | grep usb` to see available ports
- [ ] Try unplugging and replugging USB cables

### Permission Denied (Linux)
- [ ] Add user to dialout group: `sudo usermod -a -G dialout $USER`
- [ ] Log out and back in
- [ ] Verify with: `groups | grep dialout`

### No Serial Output
- [ ] Verify using correct UART port (CH343, not USB-JTAG)
- [ ] Check baud rate is 115200
- [ ] Confirm firmware outputs to UART0
- [ ] Try monitoring flash port instead (USB-JTAG has serial too)

### Flashing Fails
- [ ] Check port is correct (USB-JTAG, not CH343)
- [ ] Try resetting board manually
- [ ] Check USB cable supports data (not charge-only)
- [ ] Verify espflash is built: `./espflash/target/release/espflash --version`

### Build Fails
- [ ] Check Rust target installed: `rustup target list | grep riscv32imc`
- [ ] Update Rust: `rustup update`
- [ ] Clean build: `cargo clean && cargo build --release`

## Documentation Reference

- [ ] Read [QUICKSTART_HARDWARE.md](QUICKSTART_HARDWARE.md) for quick start
- [ ] Read [HARDWARE_SETUP.md](HARDWARE_SETUP.md) for port details
- [ ] Read [scripts/README.md](scripts/README.md) for script usage
- [ ] Read [Integration Report](project_management/PI001_InitialBoot/SP002_Tooling/007_integrator_hardware_experiments.md) for complete findings

## Sign-Off

- [ ] All tests passing
- [ ] Serial output verified
- [ ] No unexpected behavior
- [ ] Documentation updated if needed

**Tester:** _______________  
**Date:** _______________  
**Notes:** _______________
