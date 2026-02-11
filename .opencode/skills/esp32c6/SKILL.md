---
name: esp32c6
description: ESP32-C6 hardware specifics - register addresses, peripherals, and RISC-V considerations
license: MIT
compatibility: opencode
metadata:
  category: hardware
  for_agent: implementor, analyst, integrator
  focus: hardware, correctness
---

# ESP32-C6 Hardware Reference

## Overview

- **Architecture**: RISC-V (RV32IMAC)
- **Cores**: Single-core up to 160 MHz
- **Memory**: 512KB SRAM, 4MB Flash (typical)
- **Peripherals**: GPIO, UART, SPI, I2C, WiFi 6, BLE 5, 802.15.4

## Memory Map

```
0x0000_0000 - 0x3FFF_FFFF : Reserved
0x4000_0000 - 0x4FFF_FFFF : Instruction memory
0x5000_0000 - 0x5FFF_FFFF : Data memory
0x6000_0000 - 0x6FFF_FFFF : Peripheral registers
```

## Key Peripheral Base Addresses

```rust
pub const GPIO_BASE: usize = 0x6000_4000;
pub const UART0_BASE: usize = 0x6000_0000;
pub const UART1_BASE: usize = 0x6000_1000;
pub const SPI0_BASE: usize = 0x6000_2000;
pub const I2C0_BASE: usize = 0x6000_7000;
pub const TIMG0_BASE: usize = 0x6000_8000;  // Timer Group 0
pub const TIMG1_BASE: usize = 0x6000_9000;  // Timer Group 1
pub const SYSTIMER_BASE: usize = 0x6000_A000;
pub const INTERRUPT_CORE0_BASE: usize = 0x6002_0000;
```

## GPIO

### Register Structure
```rust
// GPIO_OUT_REG - Output value
// GPIO_OUT_W1TS_REG - Set bits
// GPIO_OUT_W1TC_REG - Clear bits
// GPIO_ENABLE_REG - Output enable
// GPIO_IN_REG - Input value
// GPIO_PIN0_REG..GPIO_PIN30_REG - Pin configuration

register_bitfields! [u32,
    GPIO_PIN [
        PAD_DRIVER OFFSET(2) NUMBITS(1) [],  // 0=push-pull, 1=open-drain
        INT_TYPE OFFSET(7) NUMBITS(3) [
            Disabled = 0,
            RisingEdge = 1,
            FallingEdge = 2,
            AnyEdge = 3,
            LowLevel = 4,
            HighLevel = 5
        ],
        WAKEUP_ENABLE OFFSET(10) NUMBITS(1) [],
        INT_ENA OFFSET(13) NUMBITS(5) []
    ]
];
```

### GPIO Count
- GPIO0 - GPIO30 available
- Some pins have special functions (strapping, JTAG)

## UART

```rust
register_bitfields! [u32,
    UART_FIFO [
        RXFIFO_RD_BYTE OFFSET(0) NUMBITS(8) []
    ],
    UART_STATUS [
        RXFIFO_CNT OFFSET(0) NUMBITS(10) [],
        TXFIFO_CNT OFFSET(16) NUMBITS(10) []
    ],
    UART_CONF0 [
        PARITY OFFSET(0) NUMBITS(1) [],
        PARITY_EN OFFSET(1) NUMBITS(1) [],
        BIT_NUM OFFSET(2) NUMBITS(2) [],  // Data bits: 0=5, 1=6, 2=7, 3=8
        STOP_BIT_NUM OFFSET(4) NUMBITS(2) []  // Stop bits
    ]
];
```

## Interrupts

### Interrupt Controller
- PLIC-style interrupt controller
- 32 external interrupt sources
- Priority levels 1-15 (0 = disabled)

```rust
// Interrupt source numbers (examples)
pub const INT_GPIO: u32 = 8;
pub const INT_UART0: u32 = 21;
pub const INT_UART1: u32 = 22;
pub const INT_TIMER0: u32 = 14;
```

### Enabling Interrupts
```rust
// In interrupt controller registers
// INTERRUPT_CORE0_CPU_INT_ENABLE_REG - Enable mask
// INTERRUPT_CORE0_CPU_INT_THRESH_REG - Priority threshold
// INTERRUPT_CORE0_CPU_INT_PRI_n_REG - Priority for int n
```

## Timer

### System Timer (SYSTIMER)
- 52-bit counter
- 16MHz tick rate
- Two alarm units

```rust
register_bitfields! [u32,
    SYSTIMER_CONF [
        SYSTIMER_CLK_EN OFFSET(31) NUMBITS(1) []
    ],
    SYSTIMER_TARGET_CONF [
        TARGET_PERIOD OFFSET(0) NUMBITS(26) [],
        TARGET_PERIOD_MODE OFFSET(30) NUMBITS(1) []
    ]
];
```

## Boot Sequence

1. ROM bootloader runs
2. Loads second-stage bootloader
3. Second-stage loads application
4. Application entry at `_start`

### Linker Script Considerations
```
MEMORY {
    IRAM : ORIGIN = 0x40800000, LENGTH = 0x40000
    DRAM : ORIGIN = 0x40840000, LENGTH = 0x40000
}
```

## Flashing

```bash
# Using esptool
esptool.py --chip esp32c6 --port /dev/ttyUSB0 \
    write_flash 0x0 bootloader.bin \
    0x10000 firmware.bin

# Using cargo-espflash
cargo espflash flash --chip esp32c6 --port /dev/ttyUSB0
```

## Serial Console

- Default UART0 on GPIO16 (TX) and GPIO17 (RX)
- 115200 baud, 8N1 typical

```bash
# Monitor serial output
screen /dev/ttyUSB0 115200
# or
picocom -b 115200 /dev/ttyUSB0
```

## References

- ESP32-C6 Technical Reference Manual
- ESP32-C6 Datasheet
- esp-idf repository for register definitions
- esp-hal repository for Rust HAL reference
