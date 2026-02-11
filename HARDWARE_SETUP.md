# ESP32-C6 Hardware Setup - Quick Reference

**Board:** nanoESP32-C6 (WeAct Studio / MuseLab)  
**Chip:** ESP32-C6 revision v0.1  
**Flash:** 16MB  
**MAC:** 40:4c:ca:5e:ae:b8

## USB Ports (macOS)

| Port | Device | Use For | USB ID |
|------|--------|---------|--------|
| `/dev/tty.usbmodem112201` | ESP32-C6 USB-JTAG | **Flashing** | 1001:303A |
| `/dev/tty.usbmodem595B0538021` | CH343 UART | **Serial Monitor** | 55D3:1A86 |

**Linux:** Replace with `/dev/ttyACM*` or `/dev/ttyUSB*`

## Quick Commands

### Flash Firmware
```bash
./scripts/flash_esp32c6.sh path/to/kernel.elf
```

### Monitor Serial
```bash
python3 scripts/monitor_serial.py /dev/tty.usbmodem595B0538021 115200 10
```

### Run Tests
```bash
./scripts/test_esp32c6.sh path/to/kernel.elf
```

### Manual espflash
```bash
# Flash
./espflash/target/release/espflash flash \
  --chip esp32c6 \
  --port /dev/tty.usbmodem112201 \
  kernel.elf

# Reset
./espflash/target/release/espflash reset \
  --port /dev/tty.usbmodem112201

# Board info
./espflash/target/release/espflash board-info \
  --port /dev/tty.usbmodem112201
```

## Build Tock Kernel

```bash
cd tock/boards/nano-esp32-c6
cargo build --release
cd ../../..

# Binary location:
# tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board
```

## Troubleshooting

**Port not found?**
```bash
ls /dev/tty* | grep usb
# or
./espflash/target/release/espflash list-ports
```

**Permission denied? (Linux)**
```bash
sudo usermod -a -G dialout $USER
# Log out and back in
```

**No serial output?**
- Check UART port is correct
- Verify firmware outputs to UART0
- Try 115200 baud rate

## See Also

- [Hardware Testing Scripts](scripts/README.md)
- [Integration Report](project_management/PI001_InitialBoot/SP002_Tooling/007_integrator_hardware_experiments.md)
- [Hardware Testing Skill](.opencode/skills/hardware_testing/SKILL.md)
