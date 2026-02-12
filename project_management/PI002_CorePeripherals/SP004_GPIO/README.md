# ESP32-C6 GPIO Driver Usage Guide

## Overview

The ESP32-C6 GPIO driver provides digital I/O functionality with interrupt support for all 31 GPIO pins (GPIO0-GPIO30). It implements the Tock kernel HIL traits for portability and consistency.

## Features

- ✅ 31 GPIO pins (GPIO0-GPIO30)
- ✅ Digital input/output
- ✅ Pull-up/pull-down resistors
- ✅ Drive strength control
- ✅ Interrupt support (rising/falling/both edges)
- ✅ Full Tock HIL compliance

## Quick Start

### Accessing GPIO Pins

```rust
use kernel::hil::gpio::{Configure, Output, Input, InterruptPin, InterruptEdge, FloatingState};

// Get GPIO controller from peripherals
let gpio = &peripherals.gpio;

// Get a specific pin
let led_pin = gpio.get_pin(5).unwrap();
```

### Digital Output

```rust
// Configure pin as output
led_pin.make_output();

// Set pin high
led_pin.set();

// Set pin low
led_pin.clear();

// Toggle pin
let new_state = led_pin.toggle(); // Returns true if now high
```

### Digital Input

```rust
// Configure pin as input
button_pin.make_input();

// Read pin state
let is_pressed = button_pin.read(); // true = high, false = low

// Configure pull-up resistor
button_pin.set_floating_state(FloatingState::PullUp);

// Configure pull-down resistor
button_pin.set_floating_state(FloatingState::PullDown);

// No pull resistor
button_pin.set_floating_state(FloatingState::PullNone);
```

### GPIO Interrupts

```rust
use kernel::hil::gpio::Client;

// Define interrupt client
struct MyGpioClient;

impl Client for MyGpioClient {
    fn fired(&self) {
        // Handle interrupt
        debug!("Button pressed!");
    }
}

// Set up interrupt
let client = static_init!(MyGpioClient, MyGpioClient);
button_pin.set_client(client);

// Enable interrupt on rising edge
button_pin.enable_interrupts(InterruptEdge::RisingEdge);

// Enable interrupt on falling edge
button_pin.enable_interrupts(InterruptEdge::FallingEdge);

// Enable interrupt on both edges
button_pin.enable_interrupts(InterruptEdge::EitherEdge);

// Disable interrupts
button_pin.disable_interrupts();

// Check if interrupt is pending
if button_pin.is_pending() {
    // Handle pending interrupt
}
```

### Input/Output Mode

Some pins can be configured as both input and output simultaneously:

```rust
// Configure as input/output
pin.make_input();
pin.make_output();

// Now can both read and write
pin.set();
let value = pin.read();
```

### Low Power Mode

```rust
// Deactivate pin to lowest power state
pin.deactivate_to_low_power();
```

## Pin Mapping

### Available Pins

All 31 GPIO pins are available:
- GPIO0 - GPIO30

### Special Function Pins

Some pins have special functions:

| Pin | Special Function | Notes |
|-----|------------------|-------|
| GPIO16 | UART0 TX | Default console output |
| GPIO17 | UART0 RX | Default console input |
| GPIO18 | USB D- | USB Serial JTAG |
| GPIO19 | USB D+ | USB Serial JTAG |

**Note:** When using pins for special functions (UART, SPI, etc.), configure them via the appropriate peripheral driver, not the GPIO driver.

## Complete Example

```rust
use kernel::hil::gpio::{Configure, Output, Input, InterruptPin, InterruptEdge, FloatingState, Client};

// LED on GPIO5
let led = gpio.get_pin(5).unwrap();
led.make_output();
led.set(); // Turn on LED

// Button on GPIO9 with pull-up
let button = gpio.get_pin(9).unwrap();
button.make_input();
button.set_floating_state(FloatingState::PullUp);

// Set up button interrupt
struct ButtonClient;
impl Client for ButtonClient {
    fn fired(&self) {
        debug!("Button pressed!");
    }
}

let button_client = static_init!(ButtonClient, ButtonClient);
button.set_client(button_client);
button.enable_interrupts(InterruptEdge::FallingEdge); // Active low button

// Read button state
if !button.read() {
    led.clear(); // Turn off LED when button pressed
} else {
    led.set(); // Turn on LED when button released
}
```

## Board Integration

### Adding GPIO to Board

In your board's `main.rs`:

```rust
use kernel::hil::gpio::Pin;

// Access GPIO from peripherals
let gpio = &peripherals.gpio;

// Create pin references for board
let led_pin = gpio.get_pin(5).unwrap();
let button_pin = gpio.get_pin(9).unwrap();

// Configure pins
led_pin.make_output();
button_pin.make_input();
button_pin.set_floating_state(FloatingState::PullUp);
```

### Component Pattern

For capsules that need GPIO:

```rust
use kernel::hil::gpio::InterruptPin;

// Pass GPIO pin to capsule
let gpio_capsule = GpioCapsule::new(led_pin);
```

## Interrupt Handling

GPIO interrupts are automatically handled by the chip driver:

1. Interrupt fires on configured edge/level
2. `Esp32C6DefaultPeripherals::service_interrupt()` called
3. `Gpio::handle_interrupt()` checks all pins
4. Pending interrupts cleared
5. Client callbacks invoked

**Note:** Interrupt handling uses deferred calls for safety.

## Hardware Considerations

### Drive Strength

Drive strength is controlled via IO_MUX registers. Default drive strength is suitable for most applications.

### Input Threshold

Input pins use standard CMOS logic levels:
- Low: < 0.3 * VDD
- High: > 0.7 * VDD

### Pull Resistors

Internal pull-up/pull-down resistors are approximately 45kΩ.

### Maximum Current

- Per pin: 40mA (absolute maximum)
- Recommended: 20mA per pin
- Total for all pins: 200mA

## Troubleshooting

### Pin Not Responding

1. Check pin is not used by another peripheral
2. Verify pin number is valid (0-30)
3. Check pin is configured correctly (input vs output)
4. Verify power supply is stable

### Interrupt Not Firing

1. Check client is set: `pin.set_client(&client)`
2. Verify interrupt is enabled: `pin.enable_interrupts(edge)`
3. Check interrupt edge matches signal
4. Verify GPIO interrupt is mapped in INTC

### Unexpected Pin State

1. Check for external pull-up/pull-down resistors
2. Verify floating state configuration
3. Check for conflicting peripheral usage
4. Measure pin voltage with multimeter

## API Reference

### Traits Implemented

- `kernel::hil::gpio::Output` - Digital output
- `kernel::hil::gpio::Input` - Digital input
- `kernel::hil::gpio::Configure` - Pin configuration
- `kernel::hil::gpio::Interrupt<'a>` - Interrupt support
- `kernel::hil::gpio::Pin` - Combined I/O (blanket impl)
- `kernel::hil::gpio::InterruptPin<'a>` - Combined I/O + interrupt (blanket impl)

### Key Methods

#### Output
- `set()` - Set pin high
- `clear()` - Set pin low
- `toggle() -> bool` - Toggle pin, returns new state

#### Input
- `read() -> bool` - Read pin state

#### Configure
- `make_output() -> Configuration` - Configure as output
- `make_input() -> Configuration` - Configure as input
- `disable_output() -> Configuration` - Disable output
- `disable_input() -> Configuration` - Disable input
- `set_floating_state(FloatingState)` - Set pull-up/pull-down
- `floating_state() -> FloatingState` - Get pull-up/pull-down state
- `configuration() -> Configuration` - Get current configuration
- `deactivate_to_low_power()` - Enter low power mode

#### Interrupt
- `set_client(&'a dyn Client)` - Set interrupt callback
- `enable_interrupts(InterruptEdge)` - Enable interrupts
- `disable_interrupts()` - Disable interrupts
- `is_pending() -> bool` - Check interrupt status

## Testing

Unit tests are located in `tock/chips/esp32-c6/src/gpio.rs`:

```bash
cd tock/chips/esp32-c6
cargo test --lib gpio::tests
```

All tests should pass:
```
test result: ok. 14 passed; 0 failed; 0 ignored; 0 measured
```

## References

- ESP32-C6 Technical Reference Manual, Chapter 7 (GPIO & IO_MUX)
- Tock Kernel HIL: `kernel/src/hil/gpio.rs`
- Implementation: `tock/chips/esp32-c6/src/gpio.rs`

## License

Licensed under the Apache License, Version 2.0 or the MIT License.
