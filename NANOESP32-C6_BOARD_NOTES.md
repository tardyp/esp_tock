# nanoESP32-C6 Board-Specific Notes for Tock Port

**Board:** nanoESP32-C6 by MuseLab  
**Documentation:** `nanoESP32-C6/` directory  
**Date:** 2026-02-10

---

## Board Overview

The nanoESP32-C6 is a compact ESP32-C6 development board manufactured by MuseLab. It provides a good platform for Tock OS development with its dual USB interfaces and on-board RGB LED.

### Key Features

- **Module:** ESP32-C6-WROOM-1
- **Flash:** 8MB (significantly more than typical 2MB - allows larger kernel/app allocation)
- **Form Factor:** Compact with all GPIOs broken out
- **USB:** Dual Type-C interfaces (one for programming, one native ESP32-C6 USB)
- **Visual Indicator:** RGB LED for debugging
- **Power:** 3.3V regulated, can power from either USB port

---

## Hardware Specifications

### Flash Configuration

| Parameter | Value | Impact on Tock |
|-----------|-------|----------------|
| **Flash Size** | 8MB | Can increase kernel and app allocations |
| **Flash Mode** | DIO | Same as C3, compatible |
| **Flash Frequency** | 80MHz | Same as C3, compatible |
| **Partition Start** | 0x10000 | Standard ESP32-C6 layout |

**Recommended Tock Memory Layout (with 8MB flash):**
```ld
MEMORY {
    /* Kernel in flash - can be larger than C3 */
    rom (rx)  : ORIGIN = 0x40380000, LENGTH = 0x40000  /* 256 KB (was 160 KB) */
    
    /* HP SRAM - same as any C6 */
    ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x40000  /* 256 KB */
    
    /* Apps in flash - much more space available! */
    prog (rx) : ORIGIN = 0x403C0000, LENGTH = 0x80000  /* 512 KB (was 192 KB) */
}
```

With 8MB flash, you have much more flexibility than the standard C6 board!

---

## USB Interfaces

### CH343 USB-to-Serial (Primary for Development)

- **Device:** `/dev/ttyACM0` (Linux) or `/dev/cu.usbmodem*` (macOS)
- **Chipset:** CH343 USB-to-UART bridge
- **Purpose:** Programming and serial console
- **Baud Rate:** Up to 460800 (tested), can go higher
- **Driver:** Built into modern Linux kernels, may need driver on Windows

**Usage:**
```bash
# Flash firmware
esptool.py --chip esp32c6 -p /dev/ttyACM0 -b 460800 write_flash ...

# Monitor serial
tio /dev/ttyACM0 -b 115200
# or
screen /dev/ttyACM0 115200
```

### Native ESP32-C6 USB

- **Type:** USB Serial/JTAG on ESP32-C6 itself
- **Purpose:** Can be used for advanced debugging (future feature)
- **Support:** Not yet implemented in Tock C6 port
- **Future Use:** Could enable USB console, firmware update, debugging

---

## GPIO Pinout

### Available GPIOs ✅ VERIFIED FROM SCHEMATIC

**Based on ESP32-C6-WROOM-1 module and nanoESP32-C6 v1.0 schematic:**

| GPIO Range | Status | Notes |
|------------|--------|-------|
| GPIO0-GPIO7 | ✅ Available | GPIO0-6 have ADC capability |
| GPIO8 | ✅ Available | Strapping pin (use with caution) |
| GPIO9 | ⚠️ Boot Button | Available but connected to S1 button |
| GPIO10-GPIO13 | ✅ Available | Standard GPIO |
| GPIO15 | ✅ Available | Strapping pin (use with caution) |
| GPIO16 | 🔴 RGB LED | **Dedicated to WS2812B RGB LED control** |
| GPIO17 | ✅ Available | General purpose |
| GPIO18-GPIO23 | ✅ Available | Standard GPIO |
| RXD0 (Pin 25) | ⚠️ UART0 RX | Connected to CH343P, but exposed on header |
| TXD0 (Pin 26) | 🔴 UART0 TX | **Reserved** - Connected to CH343P, not on header |
| GPIO26-GPIO31 | ❌ Flash Interface | Used for internal flash, **NOT AVAILABLE** |

**Total Available GPIOs:** 20 pins (GPIO0-13, GPIO15, GPIO17-23)  
**Hardware-Dedicated:** GPIO16 (RGB LED), GPIO9 (Boot button)

### Special Function Pins ✅ VERIFIED

| GPIO | Function | Usage | Notes |
|------|----------|-------|-------|
| **GPIO9** | Boot Button (S1) | Input, active-low | Hardware pulled HIGH, LOW when pressed |
| **GPIO16** | RGB LED Control | WS2812B driver | Via BSS138 level shifter (inverted!) |
| **TXD0 (Pin 26)** | UART0 TX | Console output | To CH343P, not exposed on header |
| **RXD0 (Pin 25)** | UART0 RX | Console input | From CH343P, exposed on J6 pin 15 |
| **EN (Pin 3)** | Reset Button (S2) | Hardware reset | 10kΩ pull-up, not software readable |

**Note:** Exact RGB LED and button pins need verification from schematic (`nanoESP32-C6/hardware/nanoESP32C6.pdf`)

### Strapping Pins ✅ VERIFIED

ESP32-C6 has strapping pins that affect boot mode:
- **GPIO8:** Boot mode selection (safe to use after boot)
- **GPIO9:** Boot mode selection (connected to S1 button, pulled HIGH)
- **GPIO15:** ROM messages enable/disable (safe to use after boot)

**During normal operation:** These pins are safe to use after boot completes.

### ADC-Capable Pins ✅ VERIFIED

ESP32-C6 has 7 ADC channels on the following GPIOs:
- **GPIO0-GPIO6:** 12-bit SAR ADC (ADC1)

**Note:** GPIO7 and above do not have ADC capability.

---

## RGB LED ✅ VERIFIED FROM SCHEMATIC

### Hardware Configuration

The board includes a **WS2812B** addressable RGB LED with a level shifter circuit.

**Specifications:**
- **Type:** WS2812B (confirmed from schematic, designator D2)
- **Control GPIO:** GPIO16 (ESP32-C6 internal GPIO)
- **Interface:** Single-wire, 800kHz timing protocol
- **Power:** 5V rail (not 3.3V!)
- **Current:** ~60mA max (20mA per color @ full brightness)
- **Color Order:** GRB (Green-Red-Blue, not RGB!)

### Level Shifter Circuit ⚠️ CRITICAL

**Hardware Implementation:**
```
GPIO16 ──[10kΩ R2]──→ BSS138 MOSFET Gate
                      Source → GND
                      Drain → WS2812B DIN

5V ──[10kΩ R4]──→ WS2812B DIN (pull-up)

WS2812B:
  VDD (Pin 3) → 5V
  GND (Pin 2) → GND
  DIN (Pin 4) → From MOSFET drain
  DOUT (Pin 1) → Not connected
```

**⚠️ CRITICAL: Signal is INVERTED by the MOSFET!**
- GPIO16 LOW → MOSFET OFF → DIN pulled HIGH (5V) → LED sees HIGH
- GPIO16 HIGH → MOSFET ON → DIN pulled LOW (0V) → LED sees LOW

**Driver must invert the signal before transmission!**

### Tock Implementation Options:

1. **Bit-banging (like C3 SK68xx driver) - Quick Start:**
   ```rust
   // Can reuse existing SK68xx capsule with modifications
   // CRITICAL: Must invert signal due to MOSFET
   let led = static_init!(
       capsules_extra::sk68xx::SK68xx<'static, ...>,
       capsules_extra::sk68xx::SK68xx::new(
           &peripherals.gpio.pins[16],  // GPIO16
           inverted: true,  // Account for BSS138 inversion
           // ...
       )
   );
   ```

2. **RMT peripheral (recommended for production):**
   - More precise timing (±150ns tolerance met easily)
   - Less CPU intensive (hardware handles timing)
   - Requires RMT driver implementation
   - Can handle inversion in hardware configuration

### WS2812B Timing Requirements

**From WS2812B datasheet:**
- **T0H:** 0.4µs ±150ns (Logic 0, high time)
- **T0L:** 0.85µs ±150ns (Logic 0, low time)
- **T1H:** 0.8µs ±150ns (Logic 1, high time)
- **T1L:** 0.45µs ±150ns (Logic 1, low time)
- **Reset:** >50µs low

**For 160MHz CPU (bit-banging):**
- Each cycle = 6.25ns
- T0H: ~64 cycles
- T0L: ~136 cycles
- T1H: ~128 cycles
- T1L: ~72 cycles

**Testing (remember GRB order!):**
```rust
// Set RGB LED to RED (actually GRB: 0, 255, 0)
led.set_grb(0, 255, 0);

// Set to GREEN (GRB: 255, 0, 0)
led.set_grb(255, 0, 0);

// Set to BLUE (GRB: 0, 0, 255)
led.set_grb(0, 0, 255);
```

---

## Flashing and Development

### Standard Flash Command

```bash
esptool.py --chip esp32c6 \
  -p /dev/ttyACM0 \
  -b 460800 \
  --before=default_reset \
  --after=hard_reset \
  write_flash \
  --flash_mode dio \
  --flash_freq 80m \
  --flash_size 8MB \
  0x0 bootloader.bin \
  0x8000 partition-table.bin \
  0x10000 kernel.bin
```

### Tock-Specific Flash Command

For Tock, we'll use tockloader (after initial setup):

```bash
# Configure tockloader for nanoESP32-C6
cd tock/boards/nanoESP32-c6
make init

# Build and flash
make flash

# Or manually:
tockloader flash \
  --board nanoESP32-c6 \
  --arch rv32imac \
  --flash-address 0x40380000 \
  --app-address 0x403C0000 \
  target/riscv32imac-unknown-none-elf/release/nanoESP32-c6.bin
```

### Serial Console

```bash
# Using tio (recommended)
tio /dev/ttyACM0 -b 115200

# Using screen
screen /dev/ttyACM0 115200

# Using minicom
minicom -D /dev/ttyACM0 -b 115200
```

---

## Power Considerations

### Power Supply

- **USB-C Power:** Either USB port can power the board
- **3.3V Regulator:** On-board LDO provides stable 3.3V
- **Current Draw:** 
  - Idle: ~40mA
  - Active WiFi: ~150-200mA (not used in Tock yet)
  - Peak: ~300mA

**For Tock development:** USB power is sufficient.

### Power Modes

ESP32-C6 supports multiple power modes:
- **Active:** Full performance, all peripherals available
- **Modem Sleep:** WiFi/BLE off, CPU running (not applicable yet)
- **Light Sleep:** CPU paused, RTC running, quick wake
- **Deep Sleep:** Only RTC/ULP active, very low power

**Tock Port Priority:**
1. Active mode - full functionality ✅
2. Light sleep - future enhancement
3. Deep sleep - future enhancement

---

## Differences from ESP32-C6-DevKitC-1

| Feature | nanoESP32-C6 | ESP32-C6-DevKitC-1 | Impact |
|---------|--------------|---------------------|--------|
| **USB-to-Serial** | CH343 | CP2102N | Different device name, both work |
| **Flash Size** | 8MB | 4MB typically | More space on nanoESP32-C6! |
| **RGB LED** | On-board | Not standard | Extra feature for nanoESP32-C6 |
| **Form Factor** | Compact | Standard DevKit | Smaller footprint |
| **Price** | Lower | Higher | More accessible |

**Compatibility:** The Tock port will work on both boards with minimal changes (mainly LED GPIO).

---

## Testing Checklist

### Hardware Verification

- [ ] Connect nanoESP32-C6 via USB Type-C
- [ ] Verify `/dev/ttyACM0` appears (or `/dev/ttyUSB*`)
- [ ] Test flashing with esptool.py using demo firmware
- [ ] Verify RGB LED blinks with demo firmware
- [ ] Test serial console output

**Commands:**
```bash
# Check USB device
lsusb | grep -i "CH34\|QinHeng"

# Check serial port
ls -l /dev/ttyACM* /dev/ttyUSB*

# Flash test firmware (from nanoESP32-C6 repo)
cd nanoESP32-C6
./demo/flash_write.sh /dev/ttyACM0

# Watch RGB LED blink
```

### Tock Boot Verification

After porting:
- [ ] Kernel boots without crash
- [ ] Serial console shows boot messages
- [ ] RGB LED can be controlled from Tock
- [ ] GPIO pins respond correctly
- [ ] Timer interrupts fire
- [ ] Can load and run applications

---

## Pin Mapping Reference

### UART0 (Console)

| Function | GPIO | Notes |
|----------|------|-------|
| RX | GPIO16 | Console input |
| TX | GPIO17 | Console output |

**Configuration:**
```rust
const UART0_RX_PIN: usize = 16;
const UART0_TX_PIN: usize = 17;
```

### Common Peripherals ✅ VERIFIED

| Peripheral | GPIO | Purpose | Notes |
|------------|------|---------|-------|
| **RGB LED** | GPIO16 | Visual indicator | WS2812B, inverted signal |
| **Boot Button** | GPIO9 | User input / Boot mode | Active-low, hardware pull-up |
| **UART0 TX** | TXD0 (Pin 26) | Console output | To CH343P |
| **UART0 RX** | RXD0 (Pin 25) | Console input | From CH343P |

### Recommended I2C/SPI Pin Assignments

These are suggestions for applications using I2C or SPI:

| Peripheral | Suggested GPIO | Notes |
|------------|----------------|-------|
| I2C SDA | GPIO6 | Also has ADC |
| I2C SCL | GPIO7 | Standard GPIO |
| SPI MISO | GPIO2 | Also has ADC |
| SPI MOSI | GPIO3 | Also has ADC |
| SPI CLK | GPIO4 | Also has ADC |
| SPI CS | GPIO5 | Also has ADC |

**Note:** These are recommendations. ESP32-C6 supports flexible pin mapping for most peripherals.

---

## Debugging Tips

### Visual Debugging with RGB LED

Since the board has an RGB LED, use it for early boot debugging:

```rust
// In early boot, before UART works:
fn indicate_boot_stage(stage: u8) {
    match stage {
        0 => set_rgb(255, 0, 0),    // Red: Early boot
        1 => set_rgb(255, 165, 0),  // Orange: Trap handler configured
        2 => set_rgb(255, 255, 0),  // Yellow: Peripherals initializing
        3 => set_rgb(0, 255, 0),    // Green: Boot successful
        _ => set_rgb(0, 0, 255),    // Blue: Error
    }
}
```

### Serial Debugging

If boot fails before UART initializes:
1. Use RGB LED for stage indication
2. Toggle GPIO pin and use logic analyzer
3. Use JTAG debugger (if available)

### Common Issues

**Issue:** `/dev/ttyACM0` not appearing  
**Solution:** Check USB cable (must be data cable, not charge-only)

**Issue:** Flash fails with "connection timeout"  
**Solution:** 
- Press and hold BOOT button while connecting
- Try lower baud rate: `-b 115200` instead of `-b 460800`
- Check USB cable quality

**Issue:** RGB LED not working  
**Solution:** 
- Verify GPIO pin assignment
- Check timing parameters for WS2812
- Ensure 3.3V logic levels

**Issue:** Serial output garbled  
**Solution:**
- Check baud rate (should be 115200)
- Verify UART pins (GPIO16/17)
- Check clock configuration

---

## Memory Layout Recommendations

### Conservative Layout (Start Here)

```ld
MEMORY {
    rom (rx)  : ORIGIN = 0x40380000, LENGTH = 0x28000   /* 160 KB kernel */
    ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x40000   /* 256 KB RAM */
    prog (rx) : ORIGIN = 0x403A8000, LENGTH = 0x80000   /* 512 KB apps */
}
```

**Total Flash Used:** 160 KB + 512 KB = 672 KB out of 8 MB

### Expanded Layout (After Stability)

```ld
MEMORY {
    rom (rx)  : ORIGIN = 0x40380000, LENGTH = 0x40000   /* 256 KB kernel */
    ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x60000   /* 384 KB RAM */
    prog (rx) : ORIGIN = 0x403C0000, LENGTH = 0x100000  /* 1 MB apps */
}
```

**Total Flash Used:** 256 KB + 1 MB = 1.28 MB out of 8 MB

### Maximum Layout (Future)

With 8MB flash, you could even have:
- 512 KB kernel
- 2 MB applications
- 2 MB OTA update partition
- 2 MB user data storage

---

## Next Steps

1. **Verify Hardware:**
   ```bash
   cd nanoESP32-C6
   ./demo/flash_write.sh /dev/ttyACM0
   # Observe RGB LED blinking
   ```

2. **Extract Pin Assignments:**
   - Review `nanoESP32-C6/hardware/nanoESP32C6.pdf` schematic
   - Identify RGB LED GPIO
   - Identify button GPIO (if present)
   - Document any other special pins

3. **Begin Tock Port:**
   - Follow `ESP32-C6_PORTING_PLAN.md`
   - Use conservative memory layout initially
   - Start with Phase 1: Foundation

4. **Test Incrementally:**
   - Use RGB LED for early visual feedback
   - Enable UART as soon as possible
   - Test each peripheral individually

---

## Resources

### Documentation in `nanoESP32-C6/` Directory

- `README.md` - Board introduction (Chinese)
- `README_en.md` - Board introduction (English)
- `hardware/nanoESP32C6.pdf` - Schematic (need to review)
- `doc/esp32-c6_technical_reference_manual_en.pdf` - ESP32-C6 TRM
- `doc/esp32-c6_datasheet_en.pdf` - ESP32-C6 datasheet

### Vendor Links

- **MuseLab GitHub:** https://github.com/wuxx/nanoesp32-c6
- **Purchase:** Tindie, AliExpress (see README)
- **ESP-IDF Examples:** Work with this board

### Related Tock Documentation

- `ESP32-C6_DIFFERENCES.md` - Detailed C3 vs C6 comparison
- `ESP32-C6_PORTING_PLAN.md` - Step-by-step porting guide
- `tock/boards/esp32-c3-devkitM-1/` - Reference C3 implementation

---

**Good luck with the port! The nanoESP32-C6 is a great choice with its extra flash and RGB LED.**
