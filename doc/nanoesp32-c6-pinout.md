# nanoESP32-C6 v1.0 - Complete Hardware Reference for BSP Development

**Board Version:** v1.0  
**Design Date:** 2023-04-25  
**MCU Module:** ESP32-C6-WROOM-1  
**Target:** Tock OS / Embedded Rust BSP

---

## Table of Contents

1. [Board Overview](#board-overview)
2. [Pin Mapping Reference](#pin-mapping-reference)
3. [Power System](#power-system)
4. [USB-to-Serial Interface](#usb-to-serial-interface)
5. [Programming and Debug](#programming-and-debug)
6. [GPIO Header Pinout](#gpio-header-pinout)
7. [RGB LED (WS2812B)](#rgb-led-ws2812b)
8. [Buttons and Reset](#buttons-and-reset)
9. [Hardware Constraints](#hardware-constraints)
10. [BSP Implementation Notes](#bsp-implementation-notes)

---

## Board Overview

The nanoESP32-C6 v1.0 is a compact development board based on the ESP32-C6-WROOM-1 module, featuring:

- **MCU:** ESP32-C6 (RISC-V single-core, 160MHz)
- **Wireless:** WiFi 6, Bluetooth 5.3, 802.15.4 (Zigbee/Thread)
- **USB:** Native USB serial/JTAG + CH343P USB-to-Serial converter
- **LED:** 1x WS2812B RGB LED (addressable)
- **Buttons:** 2x (BOOT/GPIO9, RESET/EN)
- **Headers:** 2x 15-pin headers exposing most GPIOs
- **Power:** 5V USB input, 3.3V regulated output (AMS1117-3.3)

---

## Pin Mapping Reference

### ESP32-C6-WROOM-1 Module Pinout (U1)

| Pin # | Pin Name    | Net Name          | Function/Notes                          |
|-------|-------------|-------------------|-----------------------------------------|
| 1     | GND1        | GND               | Ground                                  |
| 2     | 3V3         | 3V3               | Power supply (3.3V)                     |
| 3     | EN          | CHIP_PU           | Enable/Reset (active high)              |
| 4     | IO4         | GPIO4             | General purpose I/O                     |
| 5     | IO5         | GPIO5             | General purpose I/O                     |
| 6     | IO6         | GPIO6             | General purpose I/O                     |
| 7     | IO7         | GPIO7             | General purpose I/O                     |
| 8     | IO0         | GPIO0             | General purpose I/O / Boot mode         |
| 9     | IO1         | GPIO1             | General purpose I/O                     |
| 10    | IO8         | GPIO8             | General purpose I/O                     |
| 11    | IO10        | GPIO10            | General purpose I/O                     |
| 12    | IO11        | GPIO11            | General purpose I/O                     |
| 13    | IO12        | GPIO12            | General purpose I/O                     |
| 14    | IO13        | GPIO13            | General purpose I/O                     |
| 15    | IO15        | GPIO15            | General purpose I/O                     |
| 16    | NC          | -                 | Not connected                           |
| 17    | IO9         | GPIO9             | Boot button (S1)                        |
| 18    | IO18        | GPIO18            | General purpose I/O                     |
| 19    | IO19        | GPIO19            | General purpose I/O                     |
| 20    | IO20        | GPIO20            | General purpose I/O                     |
| 21    | IO21        | GPIO21            | General purpose I/O                     |
| 22    | IO22        | GPIO22            | General purpose I/O                     |
| 23    | IO23        | GPIO23            | General purpose I/O                     |
| 24    | NC          | -                 | Not connected                           |
| 25    | RXD0        | RXD0              | UART0 RX (connected to CH343P)          |
| 26    | TXD0        | TXD0              | UART0 TX (connected to CH343P)          |
| 27    | IO3         | GPIO3             | General purpose I/O                     |
| 28    | IO2         | GPIO2             | General purpose I/O                     |
| 29    | EPAD/GND2   | GND               | Exposed pad / Ground                    |

### GPIO Availability Summary

**Available GPIOs:** GPIO0-13, GPIO15, GPIO18-23 (total: 20 GPIOs)

**Special Function Pins:**
- **GPIO9:** Boot button (S1), pulled high
- **CHIP_PU (EN):** Reset button (S2), pulled high via 10kΩ
- **TXD0/RXD0:** UART0 (connected to CH343P USB-to-Serial)
- **GPIO16:** RGB LED data input (via level shifter)
- **GPIO17:** Available (routed to header J6)

---

## Power System

### Power Architecture

```
USB 5V (J6) ──┬─→ CH343P (U2) USB-Serial IC
              │
              ├─→ AMS1117-3.3 (Voltage Regulator)
              │   ├─→ 3V3 Rail ─→ ESP32-C6 Module
              │   │              ├─→ All GPIOs
              │   │              └─→ Logic circuits
              │   │
              │   └─→ Decoupling capacitors:
              │       - C3: 10µF (input)
              │       - C4: 0.1µF (input)
              │       - C6: 1µF (output)
              │
              └─→ WS2812B RGB LED (5V supply)
```

### Power Components

| Designator | Type              | Value    | Function                    |
|------------|-------------------|----------|-----------------------------|
| U2 (VReg)  | AMS1117-3.3       | 3.3V     | Linear voltage regulator    |
| C3         | Capacitor         | 10µF     | Input bulk capacitor        |
| C4         | Capacitor         | 0.1µF    | Input decoupling            |
| C6         | Capacitor         | 1µF      | Output decoupling           |
| C1         | Capacitor         | 1µF      | CH343P supply decoupling    |
| C2         | Capacitor         | 1µF      | CH343P V3 decoupling        |

### Power Rails

- **5V:** USB VBUS input (J6 pin 1)
- **3V3:** Regulated 3.3V for ESP32-C6 and logic
- **GND:** Common ground

**Maximum Current (3V3 Rail):** ~800mA (AMS1117-3.3 limit)  
**Typical ESP32-C6 Current:**
  - Active WiFi: ~120mA
  - Deep sleep: ~5µA
  - Light sleep: ~1-2mA

---

## USB-to-Serial Interface

### CH343P USB-to-Serial Converter (U2)

The board includes a **CH343P** USB-to-Serial IC providing UART communication and automatic bootloader entry.

#### CH343P Pin Connections

| CH343P Pin | Net Name          | Connection               | Function                  |
|------------|-------------------|--------------------------|---------------------------|
| Pin 1      | V3                | 3V3 (via C2)             | Power supply              |
| Pin 2      | GND               | GND                      | Ground                    |
| Pin 3      | VDD               | 5V                       | USB VBUS                  |
| Pin 4      | TXD0              | TXD0 → ESP RXD0 (pin 25) | UART TX                   |
| Pin 5      | RXD0              | RXD0 → ESP TXD0 (pin 26) | UART RX                   |
| Pin 6      | D+                | CH343_USB_P              | USB D+                    |
| Pin 7      | D-                | CH343_USB_N              | USB D-                    |
| Pin 8      | UD+               | Internal USB             | Internal                  |
| Pin 9      | UD-               | Internal USB             | Internal                  |
| Pin 10     | PP0               | Via logic circuit        | Programming control       |
| Pin 11     | PP1               | Via logic circuit        | Programming control       |
| Pin 12     | RTS               | RTS signal               | Auto-reset via transistor |
| Pin 13     | DTR               | DTR signal               | Auto-boot via transistor  |
| Pin 14     | DSR               | Not connected            | -                         |
| Pin 15     | CTS               | Not connected            | -                         |
| Pin 16     | RI                | Not connected            | -                         |
| Pin 17     | GND               | GND                      | Ground                    |

#### Auto-Programming Circuit

The board implements automatic bootloader entry using DTR and RTS signals:

**Transistor Network (Q1A, Q1B - LMBT3904 dual NPN):**

```
DTR ──[10kΩ R5]──┬─→ Q1A Base
                 │   Q1A Emitter → GND
                 └─→ Q1A Collector → CHIP_PU (EN)

RTS ──[10kΩ R7]──┬─→ Q1B Base  
                 │   Q1B Emitter → GND
                 └─→ Q1B Collector → GPIO9
```

**Programming Sequence:**
1. DTR=LOW, RTS=HIGH → Pulls CHIP_PU low → Reset active
2. DTR=HIGH, RTS=LOW → Pulls GPIO9 low → Boot mode
3. DTR=HIGH, RTS=HIGH → Normal operation

**BSP Note:** When using the CH343P serial port, the ESP32-C6 will automatically enter bootloader mode when flashing tools assert DTR/RTS.

---

## Programming and Debug

### Programming Interfaces

#### 1. USB-to-Serial (CH343P) - Primary Method
- **Interface:** UART0 (TXD0/RXD0)
- **Bootloader:** ROM bootloader via GPIO9 strapping
- **Tools:** esptool.py, espflash, cargo-espflash
- **Automatic:** DTR/RTS-based auto-reset/boot

#### 2. Native USB Serial/JTAG (ESP32-C6 Built-in)
- **Pins:** USB D+/D- on ESP32-C6 (GPIO12/GPIO13 internally)
- **Note:** These pins are NOT exposed on this board design
- **Status:** Not available on nanoESP32-C6 v1.0

### Boot Mode Selection

| GPIO9 State | EN State | Boot Mode              |
|-------------|----------|------------------------|
| HIGH        | HIGH     | Normal execution       |
| LOW         | HIGH     | UART bootloader mode   |
| X           | LOW      | Reset (no boot)        |

**Hardware Boot Button (S1):** Pulling GPIO9 LOW while pressing reset enters bootloader.

---

## GPIO Header Pinout

The board provides two 15-pin headers (J1 and J6) for GPIO access.

### Header J1 (Left Side, Pins 1-15)

| Pin # | Net Name  | ESP32-C6 Pin | Function/Notes                |
|-------|-----------|--------------|-------------------------------|
| 1     | GPIO4     | Pin 4        | General purpose I/O           |
| 2     | GPIO5     | Pin 5        | General purpose I/O           |
| 3     | GPIO6     | Pin 6        | General purpose I/O           |
| 4     | GPIO7     | Pin 7        | General purpose I/O           |
| 5     | GPIO0     | Pin 8        | General purpose I/O           |
| 6     | GPIO1     | Pin 9        | General purpose I/O           |
| 7     | GPIO8     | Pin 10       | General purpose I/O           |
| 8     | GPIO10    | Pin 11       | General purpose I/O           |
| 9     | GPIO11    | Pin 12       | General purpose I/O           |
| 10    | GPIO12    | Pin 13       | General purpose I/O           |
| 11    | GPIO13    | Pin 14       | General purpose I/O           |
| 12    | CHIP_PU   | Pin 3        | Reset/Enable (input)          |
| 13    | GND       | -            | Ground                        |
| 14    | 3V3       | -            | 3.3V power output             |
| 15    | 5V        | -            | 5V from USB (input/output)    |

### Header J6 (Right Side, Pins 1-15)

| Pin # | Net Name  | ESP32-C6 Pin | Function/Notes                |
|-------|-----------|--------------|-------------------------------|
| 1     | 5V        | -            | 5V from USB (input/output)    |
| 2     | 3V3       | -            | 3.3V power output             |
| 3     | GND       | -            | Ground                        |
| 4     | GPIO16    | Internal     | **RGB LED control**           |
| 5     | GPIO17    | Internal     | General purpose I/O           |
| 6     | GPIO8     | Pin 10       | General purpose I/O (dup)     |
| 7     | GPIO9     | Pin 17       | Boot button                   |
| 8     | GPIO18    | Pin 18       | General purpose I/O           |
| 9     | GPIO19    | Pin 19       | General purpose I/O           |
| 10    | GPIO20    | Pin 20       | General purpose I/O           |
| 11    | GPIO21    | Pin 21       | General purpose I/O           |
| 12    | GPIO22    | Pin 22       | General purpose I/O           |
| 13    | GPIO23    | Pin 23       | General purpose I/O           |
| 14    | GPIO15    | Pin 15       | General purpose I/O           |
| 15    | RXD0      | Pin 25       | UART RX (CH343P connection)   |

**Note:** TXD0 is not exposed on headers (only used by CH343P).

---

## RGB LED (WS2812B)

### LED Specifications

- **Type:** WS2812B addressable RGB LED (D2)
- **Protocol:** Single-wire, 800kHz timing
- **Control GPIO:** GPIO16 (via level shifter)
- **Power:** 5V rail
- **Current:** ~60mA max (20mA per color @ full brightness)

### Hardware Configuration

```
GPIO16 ──[10kΩ R2]──┬─→ BSS138 MOSFET Gate (Q2)
                    │   Source → GND
                    └─→ Drain → WS2812B DIN

5V ──[10kΩ R4]──┬─→ WS2812B DIN pull-up
                └─→ WS2812B VDD (Pin 3)

WS2812B Pinout:
  Pin 1 (DOUT) → Not connected (single LED)
  Pin 2 (GND)  → GND
  Pin 3 (VDD)  → 5V
  Pin 4 (DIN)  → From Q2 drain
```

### Level Shifter Circuit

**Purpose:** Convert 3.3V GPIO16 logic to 5V for WS2812B

- **Q2:** BSS138 N-channel MOSFET
- **R2:** 10kΩ (GPIO16 → Gate)
- **R4:** 10kΩ (5V pull-up on DIN)

**Logic:**
- GPIO16 LOW → MOSFET OFF → DIN pulled HIGH (5V)
- GPIO16 HIGH → MOSFET ON → DIN pulled LOW (0V)

**Note:** Signal is inverted! BSP driver must account for this.

### BSP Implementation for WS2812B

**Timing Requirements (WS2812B):**
- T0H: 0.4µs ±150ns (Logic 0, high time)
- T0L: 0.85µs ±150ns (Logic 0, low time)
- T1H: 0.8µs ±150ns (Logic 1, high time)
- T1L: 0.45µs ±150ns (Logic 1, low time)
- Reset: >50µs low

**Driver Considerations:**
1. Use RMT (Remote Control) peripheral for precise timing
2. Account for signal inversion (level shifter)
3. Disable interrupts during transmission
4. RGB order: GRB (not RGB!)

**Example Configuration (Conceptual):**
```rust
// RMT channel configuration
// Inverted output due to MOSFET level shifter
rmt_channel.configure(
    gpio: GPIO16,
    clock_div: 2,  // 40MHz APB → 20MHz (50ns per tick)
    inverted: true,  // Account for BSS138 inversion
);

// Bit timings (in 50ns ticks)
const BIT_0: (u16, u16) = (8, 17);   // 0.4µs high, 0.85µs low
const BIT_1: (u16, u16) = (16, 9);   // 0.8µs high, 0.45µs low
const RESET: u32 = 1000;             // 50µs low
```

---

## Buttons and Reset

### Button S1 - BOOT/GPIO9

- **Connected to:** GPIO9 (ESP32-C6 pin 17)
- **Pull-up:** Internal pull-up resistor in ESP32-C6
- **Function:** 
  - Boot mode selection (when held during reset)
  - User button (during normal operation)
- **Active:** LOW when pressed

**BSP Usage:**
```rust
// Configure as input with pull-up
gpio9.configure(InputMode::PullUp);

// Read button state
let pressed = !gpio9.read();  // Active low
```

### Button S2 - RESET/EN

- **Connected to:** CHIP_PU (EN pin, ESP32-C6 pin 3)
- **Pull-up:** 10kΩ resistor (R3) to 3V3
- **Capacitor:** C6 (1µF) for debouncing
- **Function:** Hardware reset
- **Active:** LOW when pressed

**Note:** This is a hardware reset button, not readable by software.

---

## Hardware Constraints

### Reserved/Special Pins

| GPIO   | Function                  | Availability            | Notes                          |
|--------|---------------------------|-------------------------|--------------------------------|
| GPIO9  | Boot button (S1)          | Limited                 | Must be HIGH for normal boot   |
| GPIO16 | WS2812B LED control       | Dedicated               | Used for onboard RGB LED       |
| TXD0   | UART TX to CH343P         | Reserved                | Serial communication           |
| RXD0   | UART RX from CH343P       | Reserved (but exposed)  | Can be repurposed if needed    |
| EN     | Reset button (S2)         | Hardware only           | Not software-controllable      |

### GPIO Strapping Pins (ESP32-C6 Specific)

The ESP32-C6 uses certain GPIOs as strapping pins during boot:

| GPIO   | Strapping Function           | Default/Safe State | Board Configuration  |
|--------|------------------------------|--------------------|-----------------------|
| GPIO8  | Boot mode selection          | Pull-up (HIGH)     | Floating (safe)       |
| GPIO9  | Boot mode selection          | Pull-up (HIGH)     | Button, pulled HIGH   |
| GPIO15 | JTAG/ROM message enable      | Pull-up (HIGH)     | Floating (safe)       |

**BSP Recommendation:** Avoid using strapping pins for critical boot-time functions.

### Current Limitations

1. **3.3V Rail:** Max 800mA (AMS1117 limit)
2. **Per-GPIO:** Max 40mA source/sink
3. **Total GPIO:** Max 200mA combined
4. **WS2812B:** 60mA max (from 5V rail)

### Peripheral Availability (ESP32-C6)

| Peripheral   | Count | Notes                                    |
|--------------|-------|------------------------------------------|
| UART         | 2     | UART0 used by CH343P                     |
| SPI          | 2     | SPI2 (FSPI), SPI3 (HSPI)                 |
| I2C          | 1     | All GPIOs support I2C                    |
| RMT          | 4     | Channel 0 recommended for WS2812B        |
| LEDC (PWM)   | 6     | All GPIOs support PWM                    |
| ADC          | 7ch   | GPIO0-6 (12-bit SAR ADC)                 |
| Touch        | 14ch  | Most GPIOs support capacitive touch      |

---

## BSP Implementation Notes

### Initialization Sequence

**Recommended BSP startup order:**

1. **Clock Configuration**
   - Configure CPU clock (80/160MHz)
   - Enable peripheral clocks

2. **GPIO Initialization**
   - Configure boot button (GPIO9) as input
   - Set default GPIO states
   - Configure strapping pins appropriately

3. **UART Configuration**
   - Initialize UART0 (TXD0/RXD0) for console
   - Baud rate: 115200 (default)

4. **Peripheral Initialization**
   - RMT for WS2812B control
   - SPI/I2C as needed
   - ADC for analog inputs

5. **Power Management**
   - Configure sleep modes
   - Set up wake sources

### Pin Mapping Macros (Suggested)

```rust
// Core system pins
pub const PIN_RESET: u8 = 3;  // CHIP_PU/EN (hardware only)
pub const PIN_BOOT_BUTTON: u8 = 9;  // Boot/User button

// UART0 (Console/Debug)
pub const PIN_UART0_TX: u8 = 26;  // TXD0 (to CH343P)
pub const PIN_UART0_RX: u8 = 25;  // RXD0 (from CH343P)

// Onboard LED
pub const PIN_RGB_LED: u8 = 16;  // WS2812B control (inverted)

// Available GPIOs
pub const AVAILABLE_GPIOS: &[u8] = &[
    0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 15,
    17, 18, 19, 20, 21, 22, 23
];

// Analog-capable GPIOs (ADC1)
pub const ADC_GPIOS: &[u8] = &[0, 1, 2, 3, 4, 5, 6];

// Strapping pins (use with caution)
pub const STRAPPING_PINS: &[u8] = &[8, 9, 15];
```

### Tock OS Specific Considerations

**For Tock OS BSP development:**

1. **Board Definition:**
   - Create board definition in `boards/nano_esp32_c6/`
   - Define GPIO mapping
   - Configure UART as console

2. **Capsule Configuration:**
   - LED capsule for WS2812B (requires RMT driver)
   - Button capsule for GPIO9
   - Console capsule for UART0

3. **Memory Layout:**
   - Flash: 4MB (ESP32-C6-WROOM-1)
   - RAM: 512KB SRAM
   - Bootloader: 0x0000-0x8000 (ROM)
   - App flash: 0x10000+ (configurable)

4. **Interrupt Handling:**
   - GPIO interrupts for button
   - UART interrupts for console
   - RMT interrupts for LED control

### Testing and Validation

**Essential BSP tests:**

1. ✓ Boot sequence and console output
2. ✓ GPIO read/write (test with available pins)
3. ✓ Button press detection (GPIO9)
4. ✓ RGB LED control (WS2812B via RMT)
5. ✓ UART communication (loopback test)
6. ✓ ADC readings (GPIO0-6)
7. ✓ Sleep/wake functionality
8. ✓ Peripheral initialization (SPI/I2C)

---

## Schematic Reference

### Component Summary

| Designator | Type                | Value/Part Number  | Function                       |
|------------|---------------------|--------------------|--------------------------------|
| U1         | ESP32-C6-WROOM-1    | -                  | Main MCU module                |
| U2         | CH343P              | -                  | USB-to-Serial converter        |
| U_VReg     | AMS1117-3.3         | -                  | 3.3V voltage regulator         |
| D2         | WS2812B             | -                  | RGB LED                        |
| Q1A/Q1B    | LMBT3904            | Dual NPN           | Auto-reset/boot transistors    |
| Q2         | BSS138              | N-CH MOSFET        | Level shifter for LED          |
| S1         | Push button         | -                  | Boot/User button               |
| S2         | Push button         | -                  | Reset button                   |
| R2, R4     | Resistor            | 10kΩ               | LED level shifter              |
| R3         | Resistor            | 10kΩ               | EN pull-up                     |
| R5, R7     | Resistor            | 10kΩ               | Auto-reset circuit             |
| C1, C2, C6 | Capacitor           | 1µF                | Decoupling                     |
| C3         | Capacitor           | 10µF               | Regulator input bulk           |
| C4         | Capacitor           | 0.1µF              | Regulator input decoupling     |
| J1, J6     | Pin header          | 15-pin             | GPIO expansion                 |

### Net Names Reference

**Power:**
- `3V3` - 3.3V regulated power
- `5V` - USB VBUS (5V)
- `GND` - Ground

**Control:**
- `CHIP_PU` - Reset/Enable (active high)
- `RTS` - CH343P RTS (auto-reset)
- `DTR` - CH343P DTR (auto-boot)

**UART:**
- `TXD0` - ESP32 TX → CH343P RX
- `RXD0` - ESP32 RX ← CH343P TX

**USB:**
- `CH343_USB_P` / `CH343_USB_N` - USB data lines to CH343P

**GPIO:**
- `GPIO0` - `GPIO23` - General purpose I/O nets

---

## Revision History

| Version | Date       | Changes                                      |
|---------|------------|----------------------------------------------|
| 1.0     | 2023-04-25 | Initial hardware design                      |
| BSP 1.0 | 2026-02-10 | Complete BSP documentation created           |

---

## Additional Resources

### Datasheets
- [ESP32-C6 Technical Reference Manual](https://www.espressif.com/sites/default/files/documentation/esp32-c6_technical_reference_manual_en.pdf)
- [ESP32-C6-WROOM-1 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-c6-wroom-1_wroom-1u_datasheet_en.pdf)
- [CH343 Datasheet](http://www.wch-ic.com/products/CH343.html)
- [WS2812B Datasheet](https://cdn-shop.adafruit.com/datasheets/WS2812B.pdf)
- [AMS1117 Datasheet](http://www.advanced-monolithic.com/pdf/ds1117.pdf)

### Development Tools
- **ESP-IDF:** Official Espressif SDK
- **esp-hal:** Rust HAL for ESP32-C6
- **esptool.py:** Flash and debug tool
- **Tock OS:** Embedded operating system for Cortex-M and RISC-V

---

**Document prepared for Tock OS BSP development**  
**Target platform:** nanoESP32-C6 v1.0  
**Generated:** 2026-02-10
