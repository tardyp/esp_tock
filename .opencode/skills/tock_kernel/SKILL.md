---
name: tock_kernel
description: Tock kernel patterns, HIL traits, and embedded Rust conventions for chip implementation
license: MIT
compatibility: opencode
metadata:
  category: patterns
  for_agent: implementor, analyst
  focus: architecture, correctness
---

# Tock Kernel Patterns

## Project Structure

```
tock/
  kernel/           # Core kernel (don't modify)
  capsules/         # Hardware-independent drivers
  chips/
    esp32c6/        # Our chip implementation
      src/
        lib.rs
        gpio.rs
        uart.rs
        timer.rs
        interrupts.rs
  boards/
    esp32c6_devkit/  # Board configuration
      src/
        main.rs
        io.rs
```

## HIL (Hardware Interface Layer)

Tock uses HIL traits for hardware abstraction:

```rust
// Implementing a HIL trait
use kernel::hil::gpio;

impl gpio::Pin for GpioPin<'_> {
    fn set(&self) {
        // Write to hardware register
    }
    
    fn clear(&self) {
        // Write to hardware register
    }
    
    fn toggle(&self) -> bool {
        // Toggle and return new state
    }
    
    fn read(&self) -> bool {
        // Read from hardware register
    }
}
```

## Static Allocation

**No heap in kernel!** Use static allocation:

```rust
// Static buffer allocation
static mut BUFFER: [u8; 64] = [0; 64];

// Static component initialization
let gpio = static_init!(
    GpioComponent,
    GpioComponent::new(board_kernel, &peripherals.gpio)
);
```

## Deferred Calls

For async operations without threads:

```rust
use kernel::deferred_call::{DeferredCall, DeferredCallClient};

impl DeferredCallClient for MyDriver {
    fn handle_deferred_call(&self) {
        // Handle the deferred work
    }
    
    fn register(&'static self) {
        self.deferred_call.register(self);
    }
}
```

## Register Access

Use `tock_registers` crate:

```rust
use tock_registers::registers::{ReadOnly, ReadWrite, WriteOnly};
use tock_registers::register_bitfields;

register_bitfields! [u32,
    GPIO_CTRL [
        ENABLE OFFSET(0) NUMBITS(1) [],
        MODE OFFSET(1) NUMBITS(2) [
            Input = 0,
            Output = 1,
            Alternate = 2
        ],
        PULL OFFSET(4) NUMBITS(2) [
            None = 0,
            Up = 1,
            Down = 2
        ]
    ]
];

#[repr(C)]
struct GpioRegisters {
    ctrl: ReadWrite<u32, GPIO_CTRL::Register>,
    status: ReadOnly<u32>,
    // ...
}
```

## Error Handling

Use Tock's error types:

```rust
use kernel::ErrorCode;

fn configure(&self) -> Result<(), ErrorCode> {
    if !self.is_valid() {
        return Err(ErrorCode::INVAL);
    }
    // ...
    Ok(())
}
```

Common error codes:
- `ErrorCode::FAIL` - Generic failure
- `ErrorCode::BUSY` - Resource busy
- `ErrorCode::INVAL` - Invalid argument
- `ErrorCode::SIZE` - Size error
- `ErrorCode::NOSUPPORT` - Not supported

## Interrupt Handling

```rust
impl InterruptService for Esp32C6 {
    unsafe fn service_interrupt(&self, interrupt: u32) -> bool {
        match interrupt {
            0 => self.gpio.handle_interrupt(),
            1 => self.uart.handle_interrupt(),
            _ => return false,
        }
        true
    }
}
```

## Component Pattern

For board initialization:

```rust
pub struct GpioComponent {
    gpio: &'static GpioRegisters,
}

impl Component for GpioComponent {
    type StaticInput = &'static mut MaybeUninit<GpioDriver>;
    type Output = &'static GpioDriver;
    
    fn finalize(self, s: Self::StaticInput) -> Self::Output {
        let driver = s.write(GpioDriver::new(self.gpio));
        driver
    }
}
```

## Documentation

Every public item needs docs:

```rust
/// GPIO pin driver for ESP32-C6.
///
/// Provides digital I/O functionality following Tock's GPIO HIL.
///
/// # Example
/// ```ignore
/// let pin = gpio.get_pin(5);
/// pin.set();
/// ```
pub struct GpioPin<'a> {
    // ...
}
```
