# PI001/SP003 - Analysis Report #022: No Serial Output

## Research Summary

Analyzed why Tock kernel produces no serial output on ESP32-C6 despite successful flash and reset. Compared with embassy-rs reference implementation and identified critical missing initialization steps.

**Root Cause**: UART hardware is never initialized. The code creates a UART object but never configures the hardware registers for baud rate, GPIO pin muxing, or peripheral clocks.

---

## Key Findings

### 1. UART Hardware Not Initialized

**Current Code** (`tock/boards/nano-esp32-c6/src/io.rs`):
```rust
impl IoWrite for Writer {
    fn write(&mut self, buf: &[u8]) -> usize {
        let uart = esp32::uart::Uart::new(esp32::uart::UART0_BASE);
        uart.disable_tx_interrupt();
        uart.disable_rx_interrupt();
        uart.transmit_sync(buf);
        buf.len()
    }
}
```

**Problems**:
- Creates UART object but never calls `configure()` 
- Never sets baud rate (defaults to 0 or ROM bootloader value)
- Never configures GPIO pins for UART function
- Assumes ROM bootloader left UART in working state (unreliable)

### 2. Missing Clock Initialization

**Embassy Reference** (`embassy-on-esp/src/main.rs:99`):
```rust
let clocks = ClockControl::boot_defaults(system.clock_control).freeze();
```

**Tock Current** (`tock/boards/nano-esp32-c6/src/main.rs:135`):
```rust
// TODO: Disable watchdogs
// TODO: Configure clocks
```

**Impact**: Without clock initialization, peripheral clocks may be:
- Disabled (no clock to UART)
- Running at wrong frequency (baud rate calculation wrong)
- Unstable (PLL not configured)

### 3. GPIO Pin Muxing Not Configured

**ESP32-C6 Default UART0 Pins**:
- TX: GPIO16
- RX: GPIO17

**Problem**: GPIO pins default to GPIO function, not UART function. Must explicitly configure:
- Set GPIO16 to UART0_TXD function
- Set GPIO17 to UART0_RXD function
- Configure pull-up/pull-down resistors
- Set drive strength

### 4. Embassy Uses USB-JTAG, Not UART0

**Critical Discovery**: Embassy's `esp-println` uses **USB-JTAG serial**, not UART0!

```toml
esp-println = { version = "0.8.0", features = ["jtag-serial"] }
esp-backtrace = { features = ["print-jtag-serial"] }
```

This is why embassy "just works" - it bypasses UART entirely and uses the built-in USB-JTAG interface.

**For Tock**: We want real UART0 for production use, so we must properly initialize it.

---

## Tock Architecture Context

### UART Driver Structure

```
tock/chips/esp32/src/uart.rs
├── UartRegisters (register definitions)
├── Uart::new() - Creates driver instance
├── Uart::configure() - Sets baud rate, parity, stop bits
├── Uart::transmit_sync() - Blocking transmit
└── Uart::handle_interrupt() - Interrupt handler
```

### Current Usage Pattern

```
main.rs:189 - Creates uart_mux component (calls configure)
main.rs:192 - Creates console component
io.rs:25 - Creates NEW Uart instance (WRONG!)
```

**Problem**: `io.rs` creates a separate UART instance instead of using the configured one from `main.rs`.

---

## ESP32-C6 Specifics

### UART0 Hardware Requirements

1. **Clock Enable**:
   - System clock must be configured
   - UART peripheral clock must be enabled
   - Clock source selected (APB_CLK or other)

2. **Baud Rate Calculation**:
   ```
   baud_rate = clock_freq / (CLKDIV + CLKDIV_FRAG/16)
   ```
   - For 115200 baud @ 80MHz APB: CLKDIV ≈ 694

3. **GPIO Configuration**:
   - GPIO Matrix: Route UART0_TXD signal to GPIO16
   - GPIO Matrix: Route GPIO17 to UART0_RXD signal
   - Set GPIO16 output enable
   - Set GPIO17 input enable

4. **UART Registers**:
   - CONF0: Data bits (8), parity (none), stop bits (1)
   - CLKDIV: Baud rate divisor
   - CONF1: FIFO thresholds
   - MEM_CONF: FIFO sizes

### Memory Map Verification

```
UART0_BASE: 0x6000_0000 ✓ (matches esp32 driver)
GPIO_BASE:  0x6000_4000 (need GPIO driver)
SYSTEM_BASE: 0x600C_0000 (need for clocks)
IO_MUX_BASE: 0x6000_9000 (need for pin muxing)
```

---

## Risks Identified

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| UART still doesn't work after init | Medium | High | Add debug output via USB-JTAG first |
| Clock configuration breaks other peripherals | Low | High | Follow embassy reference exactly |
| GPIO muxing conflicts with other pins | Low | Medium | Document pin assignments clearly |
| Baud rate calculation wrong | Medium | Medium | Test with oscilloscope/logic analyzer |
| ROM bootloader interference | Low | High | Explicitly reset UART registers |

---

## Comparison: Tock vs Embassy

| Aspect | Tock (Current) | Embassy | Required for Tock |
|--------|----------------|---------|-------------------|
| **UART Init** | ❌ Not done | ✓ Via HAL | ✓ Must add |
| **Clock Setup** | ❌ TODO comment | ✓ ClockControl | ✓ Must add |
| **GPIO Mux** | ❌ Not done | ✓ Via HAL | ✓ Must add |
| **Debug Output** | UART0 (broken) | USB-JTAG | Consider both |
| **Baud Rate** | Not set | 115200 | ✓ Must set |
| **Pin Config** | Not done | Via IO struct | ✓ Must add |

---

## Recommended Approach

### Phase 1: Quick Win - Use Configured UART (1-2 hours)

Fix `io.rs` to use the UART instance that's already configured in `main.rs`:

```rust
// io.rs - WRONG (current)
let uart = esp32::uart::Uart::new(esp32::uart::UART0_BASE);

// io.rs - RIGHT (use static reference)
static mut DEBUG_UART: Option<&'static esp32::uart::Uart> = None;

// main.rs - Set the static reference
unsafe { io::set_debug_uart(&peripherals.uart0); }
```

**Expected Result**: Still won't work, but eliminates one variable.

### Phase 2: Add Minimal UART Initialization (4-6 hours)

Add basic UART setup in `main.rs` before creating uart_mux:

```rust
// Configure UART0 hardware directly
peripherals.uart0.configure(hil::uart::Parameters {
    baud_rate: 115200,
    width: hil::uart::Width::Eight,
    parity: hil::uart::Parity::None,
    stop_bits: hil::uart::StopBits::One,
    hw_flow_control: false,
});
```

**Expected Result**: May work if ROM bootloader configured clocks/GPIO.

### Phase 3: Full Hardware Initialization (8-12 hours)

Implement complete initialization sequence:

1. **Clock Configuration** (2-3 hours):
   - Create `tock/chips/esp32-c6/src/clocks.rs`
   - Implement basic clock setup (APB @ 80MHz)
   - Enable UART peripheral clock

2. **GPIO Driver** (3-4 hours):
   - Create `tock/chips/esp32-c6/src/gpio.rs`
   - Implement GPIO Matrix configuration
   - Add pin muxing for UART0

3. **UART Enhancement** (3-5 hours):
   - Add hardware reset to `uart.rs`
   - Add baud rate calculation
   - Add FIFO configuration
   - Add proper initialization sequence

**Expected Result**: UART works reliably.

### Phase 4: USB-JTAG Debug (Optional, 4-6 hours)

Add USB-JTAG serial as alternative debug output:
- Simpler than UART (no GPIO muxing needed)
- Always available (built into chip)
- Useful for early boot debugging

---

## Handoff to Implementor

### Immediate Next Steps

1. **Start with Phase 1** (Quick Win):
   - File: `tock/boards/nano-esp32-c6/src/io.rs`
   - File: `tock/boards/nano-esp32-c6/src/main.rs`
   - Change: Use static reference to configured UART
   - Test: Flash and check for output

2. **If Phase 1 fails, proceed to Phase 2**:
   - File: `tock/boards/nano-esp32-c6/src/main.rs`
   - Add: Explicit UART configure() call
   - Test: Flash and check for output

3. **If Phase 2 fails, implement Phase 3**:
   - Start with clocks (highest priority)
   - Then GPIO muxing
   - Then UART enhancements

### Files That Need Changes

#### Immediate (Phase 1-2):
- `tock/boards/nano-esp32-c6/src/io.rs` - Fix UART reference
- `tock/boards/nano-esp32-c6/src/main.rs` - Add configure() call

#### If Full Init Needed (Phase 3):
- `tock/chips/esp32-c6/src/clocks.rs` - **NEW FILE** - Clock configuration
- `tock/chips/esp32-c6/src/gpio.rs` - **NEW FILE** - GPIO and pin muxing
- `tock/chips/esp32/src/uart.rs` - Enhance initialization
- `tock/chips/esp32-c6/src/lib.rs` - Export new modules

### Reference Implementation

**Embassy HAL**: Look at `esp-hal-common` crate for:
- Clock configuration: `esp-hal-common/src/clock.rs`
- GPIO setup: `esp-hal-common/src/gpio.rs`
- UART init: `esp-hal-common/src/uart.rs`

**ESP-IDF**: For register-level details:
- `components/hal/esp32c6/include/hal/uart_ll.h`
- `components/hal/esp32c6/include/hal/gpio_ll.h`

### Debug Strategy

1. **Add early debug marker**: Write to UART FIFO directly in `main()` entry
2. **Test with oscilloscope**: Verify TX pin toggles at 115200 baud
3. **Check registers**: Add panic handler to dump UART/clock registers
4. **Compare with ROM**: Read registers after ROM boot, before our init

### Success Criteria

- [ ] `debug!()` macro produces serial output
- [ ] Output appears at 115200 baud on GPIO16
- [ ] Output is readable (correct baud rate)
- [ ] Works reliably after reset
- [ ] Works after power cycle

---

## Questions for PO

1. **Debug Priority**: Should we implement USB-JTAG debug first (easier) or fix UART0 (production-ready)?
2. **Clock Strategy**: Use minimal clocks (ROM defaults) or full clock tree configuration?
3. **GPIO Conflicts**: Are GPIO16/17 available for UART or needed for other functions?
4. **Testing**: Do we have oscilloscope/logic analyzer for hardware debugging?

---

## Additional Notes

### Why Embassy "Just Works"

Embassy uses a completely different approach:
- USB-JTAG serial (built-in, no GPIO needed)
- Full HAL that handles all initialization
- Comprehensive clock setup
- Proper GPIO muxing

### Why Tock Doesn't Work

Tock assumes:
- ROM bootloader configured UART (unreliable)
- Clocks are already set up (not guaranteed)
- GPIO pins are already muxed (definitely not)

### The Fix

Tock needs to do what embassy does:
1. Configure clocks explicitly
2. Set up GPIO pin muxing
3. Initialize UART hardware completely
4. Don't assume ROM bootloader did anything

---

## Estimated Effort

- **Phase 1** (Quick fix): 1-2 hours
- **Phase 2** (Basic init): 4-6 hours
- **Phase 3** (Full init): 8-12 hours
- **Phase 4** (USB-JTAG): 4-6 hours (optional)

**Total**: 13-20 hours for complete solution

**Recommendation**: Start with Phase 1, escalate to Phase 2/3 as needed.

---

## References

- ESP32-C6 Technical Reference Manual: UART Chapter
- ESP32-C6 Technical Reference Manual: GPIO Matrix Chapter
- Embassy esp-hal-common source code
- Tock UART HIL documentation
- ESP-IDF UART driver source
