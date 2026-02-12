# ESP32-C6 Hardware Testing - Quick Start Guide

This guide will get you up and running with ESP32-C6 hardware testing in 5 minutes.

## Prerequisites

1. **Hardware:** nanoESP32-C6 board connected via USB
2. **Software:** 
   - Rust toolchain with `riscv32imc-unknown-none-elf` target
   - Python 3
   - Git

## Setup (One-Time)

### 1. Build espflash
```bash
cd espflash
cargo build --release --bin espflash
cd ..
```

### 2. Install Python dependencies
```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install pyserial and esptool (required for elf2image conversion)
uv pip install --system --native-tls -r requirements.txt
```

### 3. Verify hardware connection
```bash
./espflash/target/release/espflash list-ports
```

Expected output:
```
/dev/tty.usbmodem112201       1001:303A  Espressif  USB JTAG/serial debug unit
/dev/tty.usbmodem595B0538021  55D3:1A86             USB Single Serial
```

## Build and Test Workflow

### Option 1: Automated Testing (Recommended)

```bash
# 1. Build kernel
cd tock/boards/nano-esp32-c6
cargo build --release
cd ../../..

# 2. Run automated tests
./scripts/test_esp32c6.sh \
  tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board
```

This will:
- ✅ Detect the board
- ✅ Flash the firmware
- ✅ Reset the board
- ✅ Monitor serial output for 10 seconds
- ✅ Verify expected messages
- ✅ Create a test results directory

### Option 2: Manual Testing

```bash
# 1. Build kernel
cd tock/boards/nano-esp32-c6
cargo build --release
cd ../../..

# 2. Flash firmware
./scripts/flash_esp32c6.sh \
  tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board

# 3. Monitor serial output (in separate terminal)
python3 scripts/monitor_serial.py /dev/tty.usbmodem595B0538021 115200 30
```

## Expected Output

### Successful Boot
```
ESP32-C6 initialization complete. Entering main loop
```

### Panic (if something goes wrong)
```
panicked at 'reason', file.rs:line:col
```

## Troubleshooting

### "Port not found"
```bash
# Check connected devices
ls /dev/tty* | grep usb

# Or use espflash
./espflash/target/release/espflash list-ports
```

### "Permission denied" (Linux only)
```bash
sudo usermod -a -G dialout $USER
# Log out and back in
```

### "No serial output"
- Verify you're using the correct port (CH343: `/dev/tty.usbmodem595B0538021`)
- Check baud rate is 115200
- Ensure firmware outputs to UART0
- Try monitoring the flash port instead

### "espflash not found"
```bash
cd espflash
cargo build --release --bin espflash
cd ..
```

### "pyserial or esptool not installed"
```bash
uv pip install --system --native-tls -r requirements.txt
```

## Port Reference

| Purpose | macOS | Linux |
|---------|-------|-------|
| Flashing | `/dev/tty.usbmodem112201` | `/dev/ttyACM0` |
| Serial Monitor | `/dev/tty.usbmodem595B0538021` | `/dev/ttyACM1` |

**Note:** Port names may vary. Use `espflash list-ports` to identify.

## Development Workflow

### Quick Iteration
```bash
# Build and flash in one go
cd tock/boards/nano-esp32-c6 && \
cargo build --release && \
cd ../../.. && \
./scripts/flash_esp32c6.sh \
  tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board
```

### Continuous Monitoring
```bash
# In one terminal: monitor serial
python3 scripts/monitor_serial.py /dev/tty.usbmodem595B0538021 115200 3600

# In another terminal: build and flash
cd tock/boards/nano-esp32-c6
cargo build --release
cd ../../..
./scripts/flash_esp32c6.sh \
  tock/target/riscv32imc-unknown-none-elf/release/nano-esp32-c6-board
```

## Next Steps

- Read [Hardware Setup](HARDWARE_SETUP.md) for detailed port information
- Read [Scripts README](scripts/README.md) for advanced usage
- Read [Integration Report](project_management/PI001_InitialBoot/SP002_Tooling/007_integrator_hardware_experiments.md) for complete findings

## Common Tasks

### Get board information
```bash
./espflash/target/release/espflash board-info \
  --port /dev/tty.usbmodem112201
```

### Reset board
```bash
./espflash/target/release/espflash reset \
  --port /dev/tty.usbmodem112201
```

### Flash demo blink
```bash
./scripts/flash_esp32c6.sh \
  nanoESP32-C6/demo/blink/bootloader.bin \
  nanoESP32-C6/demo/blink/partition-table.bin \
  nanoESP32-C6/demo/blink/blink.bin
```

## Help

For detailed documentation, see:
- `scripts/README.md` - Script usage and examples
- `HARDWARE_SETUP.md` - Hardware configuration
- `project_management/PI001_InitialBoot/SP002_Tooling/007_integrator_hardware_experiments.md` - Complete findings
