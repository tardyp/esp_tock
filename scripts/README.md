# ESP32-C6 Hardware Testing Scripts

This directory contains scripts for automated hardware testing of the ESP32-C6 Tock kernel.

## Quick Start

### Validate Setup
```bash
./scripts/validate_tooling.sh
```

This will check that all dependencies and tools are properly installed.

## Scripts

### 1. `monitor_serial.py`

Python script for monitoring serial output from the ESP32-C6.

**Usage:**
```bash
python3 monitor_serial.py [PORT] [BAUDRATE] [DURATION] [OUTPUT_FILE]
```

**Examples:**
```bash
# Monitor for 5 seconds (default)
python3 monitor_serial.py /dev/tty.usbmodem595B0538021 115200 5

# Monitor for 10 seconds and save to file
python3 monitor_serial.py /dev/tty.usbmodem595B0538021 115200 10 output.log

# Use defaults (macOS CH343 port, 115200 baud, 5 seconds)
python3 monitor_serial.py
```

**Requirements:**
```bash
uv pip install pyserial
```

### 2. `flash_esp32c6.sh`

Shell script for flashing firmware to the ESP32-C6.

**Usage:**
```bash
# Flash ELF file (recommended - handles bootloader automatically)
./flash_esp32c6.sh path/to/nano-esp32-c6-board

# Flash separate binaries (bootloader + partition + app)
./flash_esp32c6.sh bootloader.bin partition-table.bin app.bin
```

**Environment Variables:**
- `FLASH_PORT` - Override default flash port (default: `/dev/tty.usbmodem112201`)

**Examples:**
```bash
# Flash kernel ELF
./flash_esp32c6.sh tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board

# Flash with custom port
FLASH_PORT=/dev/ttyACM0 ./flash_esp32c6.sh kernel.elf

# Flash demo binaries
./flash_esp32c6.sh nanoESP32-C6/demo/blink/bootloader.bin \
                   nanoESP32-C6/demo/blink/partition-table.bin \
                   nanoESP32-C6/demo/blink/blink.bin
```

### 3. `test_esp32c6.sh`

Automated hardware test suite - flashes firmware and verifies serial output.

### 4. `validate_tooling.sh`

Validation script that checks all dependencies and tools are properly installed.

**Usage:**
```bash
./test_esp32c6.sh <kernel.elf> [test_duration]
```

**Examples:**
```bash
# Run tests with 10 second monitoring (default)
./test_esp32c6.sh path/to/nano-esp32-c6-board

# Run tests with 30 second monitoring
./test_esp32c6.sh path/to/nano-esp32-c6-board 30
```

**Environment Variables:**
- `FLASH_PORT` - Flash port (default: `/dev/tty.usbmodem112201`)
- `UART_PORT` - UART monitoring port (default: `/dev/tty.usbmodem595B0538021`)
- `BAUDRATE` - Serial baud rate (default: `115200`)

**Test Sequence:**
1. Board detection
2. Flash firmware
3. Reset board
4. Monitor serial output
5. Verify output (checks for initialization message and panics)

**Output:**
Creates a timestamped directory with test results:
- `board_info.log` - Board detection output
- `flash.log` - Flashing output
- `reset.log` - Reset output
- `serial_output.log` - Captured serial output
- `monitor.log` - Monitor script output

### 4. `validate_tooling.sh`

Validation script that checks all dependencies and tools are properly installed.

**Usage:**
```bash
./validate_tooling.sh
```

**Checks:**
1. espflash binary exists and works
2. Python 3 is installed
3. pyserial module is installed
4. All scripts exist and are executable
5. Rust RISC-V target is installed
6. Tock board directory structure is correct
7. Hardware detection (optional)
8. Documentation files exist

**Exit Codes:**
- `0` - All checks passed
- `1` - One or more checks failed

## Port Configuration

### macOS (nanoESP32-C6)
- **Flash Port:** `/dev/tty.usbmodem112201` (ESP32-C6 native USB)
- **UART Port:** `/dev/tty.usbmodem595B0538021` (CH343 USB-UART)

### Linux (nanoESP32-C6)
- **Flash Port:** `/dev/ttyACM0` or `/dev/ttyUSB0` (ESP32-C6 native USB)
- **UART Port:** `/dev/ttyACM1` or `/dev/ttyUSB1` (CH343 USB-UART)

**Note:** Port names may vary. Use `ls /dev/tty*` or `ls /dev/ttyACM*` to find available ports.

## Quick Start

### 1. Build espflash (one-time setup)
```bash
cd espflash
cargo build --release --bin espflash
cd ..
```

### 2. Install Python dependencies (one-time setup)
```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install pyserial
uv pip install pyserial
```

### 3. Build Tock kernel
```bash
cd tock/boards/nano-esp32-c6
cargo build --release
cd ../../..
```

### 4. Run automated tests
```bash
./scripts/test_esp32c6.sh \
  tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board
```

## Troubleshooting

### Port not found
```bash
# List available ports
ls /dev/tty* | grep -i usb

# Or use espflash
./espflash/target/release/espflash list-ports
```

### Permission denied
```bash
# macOS - no action needed (ports are world-writable)

# Linux - add user to dialout group
sudo usermod -a -G dialout $USER
# Log out and back in for changes to take effect

# Or use sudo (not recommended for automation)
sudo ./scripts/flash_esp32c6.sh kernel.elf
```

### No serial output
- Verify UART port is correct
- Check baud rate (default: 115200)
- Ensure firmware outputs to UART0
- Try monitoring the flash port instead (USB-Serial-JTAG)

### espflash not found
```bash
# Build espflash
cd espflash
cargo build --release --bin espflash
cd ..
```

### pyserial not installed
```bash
uv pip install pyserial
```

## Integration with CI/CD

### GitHub Actions Example
```yaml
- name: Flash and Test ESP32-C6
  run: |
    ./scripts/test_esp32c6.sh \
      tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board 30
  env:
    FLASH_PORT: /dev/ttyACM0
    UART_PORT: /dev/ttyACM1
```

### Local Development
```bash
# Quick flash during development
./scripts/flash_esp32c6.sh path/to/kernel.elf

# Monitor serial output separately
python3 scripts/monitor_serial.py /dev/tty.usbmodem595B0538021 115200 60
```

## See Also

- [Hardware Testing Skill](../.opencode/skills/hardware_testing/SKILL.md)
- [ESP32-C6 Skill](../.opencode/skills/esp32c6/SKILL.md)
- [Integration Report](../project_management/PI001_InitialBoot/SP002_Tooling/007_integrator_hardware_experiments.md)
