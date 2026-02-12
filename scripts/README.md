# ESP32-C6 Hardware Testing Scripts

This directory contains scripts for automated hardware testing of the ESP32-C6 Tock kernel.

## Boot Architecture: Embassy-style Direct Boot

**IMPORTANT:** This project uses **direct boot** (like embassy-rs), NOT ESP-IDF bootloader.

### Boot Flow
```
1. ESP32-C6 ROM bootloader (in ROM, always runs first)
   ↓
2. ROM reads flash offset 0x0 → CPU address 0x42000000
   ↓
3. ROM validates espflash image header (32 bytes)
   ↓
4. ROM jumps to entry point at 0x42000020
   ↓
5. Tock kernel starts
```

### Key Differences from ESP-IDF Standard Boot

| Aspect | Direct Boot (Tock) | ESP-IDF Standard |
|--------|-------------------|------------------|
| **Bootloader** | None (ROM only) | ESP-IDF 2nd stage |
| **Flash offset** | 0x0 → 0x42000000 | 0x10000 → 0x42010000 |
| **Entry point** | 0x42000020 | 0x42010000 |
| **Partition table** | Not required | Required at 0x8000 |
| **App descriptor** | Not required | Required |
| **Image format** | espflash header | ESP-IDF app image |

### Why Direct Boot?

✅ **Simple:** No bootloader complexity  
✅ **Fast:** Direct boot, faster development cycle  
✅ **Proven:** Embassy-rs uses this successfully  
✅ **Working:** Eliminates app descriptor issues  

❌ **No OTA:** Can't do over-the-air updates (not needed for initial boot validation)  
❌ **No multi-partition:** Single app only  

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
uv pip install --system --native-tls pyserial
```

### 2. `flash_esp32c6.sh`

Shell script for flashing firmware to the ESP32-C6 using **direct boot** (no ESP-IDF bootloader).

**Flashing Workflow (espflash direct mode):**
1. Reads ELF file with entry point at 0x42000020
2. Converts ELF to ESP32 image format
3. Adds 32-byte espflash header at flash offset 0x0
4. Flashes entire image to offset 0x0
5. ROM bootloader validates header and jumps to 0x42000020

**Usage:**
```bash
./flash_esp32c6.sh <kernel.elf>
```

**Requirements:**
- `espflash` (required): `cargo install espflash`
- `llvm-readelf` (for entry point verification)

**Environment Variables:**
- `FLASH_PORT` - Override default flash port (default: `/dev/tty.usbmodem112201`)

**Examples:**
```bash
# Flash kernel ELF (riscv32imac target)
./flash_esp32c6.sh tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board

# Flash with custom port
FLASH_PORT=/dev/ttyACM0 ./flash_esp32c6.sh kernel.elf
```

**What espflash does:**
- Converts ELF program headers to ESP32 segments
- Adds ESP32 image header (magic: 0xE9, entry point, segment count)
- Pads to flash alignment
- Flashes to offset 0x0 (no bootloader, no partition table)

**Image Layout:**
```
Flash Offset  CPU Address   Content
0x00000000    0x42000000    espflash header (32 bytes)
0x00000020    0x42000020    Kernel .text (entry point)
0x000XXXXX    0x420XXXXX    Kernel .rodata
...
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
3. uv package manager is installed
4. pyserial module is installed
5. esptool.py is installed and supports ESP32-C6
6. All scripts exist and are executable
7. Rust RISC-V target is installed
8. Tock board directory structure is correct
9. Hardware detection (optional)
10. Documentation files exist

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

# Install pyserial and esptool
uv pip install --system --native-tls -r requirements.txt
```

### 3. Install espflash (one-time setup)
```bash
cargo install espflash
```

### 4. Build Tock kernel
```bash
cd tock/boards/nano-esp32-c6
cargo build --release
cd ../../..
```

**Note:** The board is configured for `riscv32imac-unknown-none-elf` target (with atomics).

### 5. Run automated tests
```bash
./scripts/test_esp32c6.sh \
  tock/target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board
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

### pyserial or esptool not installed
```bash
uv pip install --system --native-tls -r requirements.txt
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
