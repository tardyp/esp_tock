# PI001/SP003 - Analysis Report #024: USB-JTAG Serial Implementation

## Research Summary

**CRITICAL FINDING**: The ESP-IDF bootloader error "Assert failed in unpack_load_app, bootloader_utility.c:769 (rom_index == 2)" indicates that `espflash flash` is STILL using the ESP-IDF bootloader, despite our "direct boot" approach.

**ROOT CAUSE**: `espflash flash` automatically adds bootloader and partition table. Embassy works because it ALSO uses this approach - there is NO true "direct boot" on ESP32-C6.

**SOLUTION**: Focus on USB-JTAG serial first (single port strategy) to get "Hello World" output, then debug the bootloader issue separately.

---

## Key Findings

### 1. How Embassy REALLY Flashes

**Embassy's `.cargo/config.toml`**:
```toml
[target.riscv32imac-unknown-none-elf]
runner = "espflash flash --monitor"
```

**Critical Discovery**: Embassy uses `espflash flash`, NOT `espflash write-bin`!

**What `espflash flash` Does**:
```
Given a path to an ELF file, first convert it into the appropriate binary 
application image format as required by the ESP32 devices. Once we have a 
valid application image, we can write the bootloader, partition table, and 
application image to the connected target device.
```

**This means**:
- ❌ Embassy does NOT bypass ESP-IDF bootloader
- ✅ Embassy USES ESP-IDF bootloader (espflash adds it automatically)
- ✅ `espflash flash` adds bootloader at 0x0
- ✅ `espflash flash` adds partition table at 0x8000
- ✅ `espflash flash` adds application at 0x10000 (default)

### 2. Why ESP-IDF Bootloader is Still Running

**Our Current Approach** (`tock/boards/nano-esp32-c6/.cargo/config.toml`):
```toml
runner = "espflash flash --monitor"
```

**We're using the SAME command as embassy!** This means:
- espflash automatically adds ESP-IDF bootloader
- espflash automatically creates partition table
- Our ELF entry point (0x42000020) is WRONG for this approach

**The Error**: "rom_index == 2" means bootloader expected 3 segments but found different number. This is an image format mismatch.

### 3. How Embassy Uses USB-JTAG Serial

**Embassy's Dependencies** (`embassy-on-esp/Cargo.toml`):
```toml
esp-println = { version = "0.8.0", features = ["jtag-serial"] }
esp-backtrace = { features = ["print-jtag-serial"] }
```

**USB-JTAG Serial Implementation** (from `esp-println` source):

```rust
// ESP32-C6 USB-JTAG Serial Registers
const SERIAL_JTAG_FIFO_REG: usize = 0x6000_F000;  // FIFO data register
const SERIAL_JTAG_CONF_REG: usize = 0x6000_F004;  // Configuration register

// Write byte to FIFO
fn fifo_write(byte: u8) {
    let fifo = SERIAL_JTAG_FIFO_REG as *mut u32;
    unsafe { fifo.write_volatile(byte as u32) }
}

// Flush FIFO
fn fifo_flush() {
    let conf = SERIAL_JTAG_CONF_REG as *mut u32;
    unsafe { conf.write_volatile(0b001) };  // Set flush bit
}

// Check if FIFO is full
fn fifo_full() -> bool {
    let conf = SERIAL_JTAG_CONF_REG as *mut u32;
    unsafe { conf.read_volatile() & 0b010 == 0b000 }
}
```

**Complete Write Implementation**:
```rust
impl Printer {
    pub fn write_bytes_assume_cs(&mut self, bytes: &[u8]) {
        if fifo_full() {
            if TIMED_OUT.load(Ordering::Relaxed) {
                return;  // No host attached
            }
            if !wait_for_flush() {
                return;
            }
        } else {
            TIMED_OUT.store(false, Ordering::Relaxed);
        }

        for &b in bytes {
            if fifo_full() {
                fifo_flush();
                if !wait_for_flush() {
                    return;
                }
            }
            fifo_write(b);
        }
    }

    pub fn flush(&mut self) {
        fifo_flush();
    }
}
```

**Key Features**:
- ✅ NO initialization required (ROM bootloader sets it up)
- ✅ NO GPIO muxing needed (built-in USB interface)
- ✅ Timeout handling (detects if no host attached)
- ✅ FIFO management (waits when full)

### 4. USB-JTAG Initialization Requirements

**Answer**: NONE! The ROM bootloader initializes USB-JTAG before running our code.

**Evidence from esp-println**:
- No clock configuration
- No GPIO setup
- No peripheral enable
- Just direct register writes

**Why It Works**:
- ROM bootloader uses USB-JTAG for its own debug output
- ROM leaves it configured and running
- Our code can immediately use it

---

## ESP32-C6 Specifics

### USB-JTAG Serial Registers

```rust
// Base address: 0x6000_F000
pub const USB_SERIAL_JTAG_BASE: usize = 0x6000_F000;

// Register offsets
pub const USB_SERIAL_JTAG_EP1_REG: usize = USB_SERIAL_JTAG_BASE + 0x00;  // FIFO data
pub const USB_SERIAL_JTAG_EP1_CONF_REG: usize = USB_SERIAL_JTAG_BASE + 0x04;  // Config
pub const USB_SERIAL_JTAG_INT_RAW_REG: usize = USB_SERIAL_JTAG_BASE + 0x08;  // Interrupts
pub const USB_SERIAL_JTAG_INT_ST_REG: usize = USB_SERIAL_JTAG_BASE + 0x0C;
pub const USB_SERIAL_JTAG_INT_ENA_REG: usize = USB_SERIAL_JTAG_BASE + 0x10;
pub const USB_SERIAL_JTAG_INT_CLR_REG: usize = USB_SERIAL_JTAG_BASE + 0x14;
pub const USB_SERIAL_JTAG_CONF0_REG: usize = USB_SERIAL_JTAG_BASE + 0x18;

// Configuration bits
// EP1_CONF_REG[0]: WR_DONE - Write done (flush)
// EP1_CONF_REG[1]: SERIAL_IN_EP_DATA_FREE - FIFO not full
```

### Memory Map Verification

```
USB-JTAG Serial: 0x6000_F000 ✓
UART0:           0x6000_0000 ✓
GPIO:            0x6000_4000 ✓
```

---

## Comparison: espflash Commands

### `espflash flash` (What Embassy Uses)

**Command**: `espflash flash --monitor <elf-file>`

**What it does**:
1. Parses ELF file
2. Downloads ESP-IDF bootloader from espflash's embedded copy
3. Generates partition table
4. Converts ELF segments to ESP32 image format
5. Flashes:
   - 0x0: Bootloader (~28KB)
   - 0x8000: Partition table (~3KB)
   - 0x10000: Application image
6. Resets chip
7. Monitors serial output

**Image Format**: ESP32 bootable image with header (0xE9 magic byte)

### `espflash write-bin` (What We Tried)

**Command**: `espflash write-bin 0x0 <bin-file>`

**What it does**:
1. Writes raw binary to specified address
2. NO bootloader added
3. NO partition table added
4. NO image format conversion
5. Resets chip

**Image Format**: Raw binary (whatever you provide)

### Why `write-bin` Failed

**Our attempt**:
```bash
espflash write-bin 0x0 nano-esp32-c6-board.bin
```

**Problem**: ROM bootloader expects:
- Valid ESP32 image header at 0x0
- Bootloader code that understands partition table
- Application at partition table location

**What we provided**:
- Raw Tock kernel binary
- No bootloader
- No partition table
- Entry point at 0x42000020 (wrong for this approach)

---

## Bootloader Error Explained

### Error Message
```
Assert failed in unpack_load_app, bootloader_utility.c:769 (rom_index == 2)
```

### What This Means

**Location**: ESP-IDF bootloader code (added by espflash)

**Function**: `unpack_load_app()` - Loads application from partition table

**Assertion**: `rom_index == 2` - Expected 3 segments (0, 1, 2)

**Cause**: Our ELF has wrong number of segments or wrong segment format for ESP-IDF bootloader

### Why Embassy Works

**Embassy's ELF Structure**:
```
Entry point: 0x42000020 (flash)
Segments:
  LOAD 0x42000000 (flash ROM) - code
  LOAD 0x40800000 (RAM) - data
  LOAD 0x50000000 (RTC RAM) - optional
```

**Our Tock ELF Structure**:
```
Entry point: 0x42000020 ✓ (same)
Segments: ??? (need to check)
```

**Likely Issue**: Segment layout doesn't match ESP-IDF bootloader expectations

---

## Recommended Approach

### Phase 1: USB-JTAG "Hello World" (4-6 hours)

**Goal**: Get ANY output working to prove boot succeeds

**Implementation**:
1. Create `tock/chips/esp32-c6/src/usb_serial_jtag.rs`
2. Copy register definitions from esp-println
3. Implement simple write function
4. Add to `io.rs` as primary debug output
5. Test with existing espflash command

**Expected Result**: "Hello World" appears on USB-JTAG serial

**Files to Create/Modify**:
- `tock/chips/esp32-c6/src/usb_serial_jtag.rs` - NEW
- `tock/chips/esp32-c6/src/lib.rs` - Export module
- `tock/boards/nano-esp32-c6/src/io.rs` - Use USB-JTAG
- `tock/boards/nano-esp32-c6/src/main.rs` - Early debug output

### Phase 2: Fix Bootloader Issue (6-8 hours)

**Goal**: Understand why ESP-IDF bootloader fails

**Investigation Steps**:
1. Compare our ELF segments with embassy's:
   ```bash
   llvm-readelf -l tock/target/.../nano-esp32-c6-board.elf
   llvm-readelf -l embassy-on-esp/target/.../embassy-on-esp
   ```

2. Check espflash image generation:
   ```bash
   espflash save-image --chip esp32c6 <elf> /tmp/test.bin
   hexdump -C /tmp/test.bin | head -100
   ```

3. Compare linker scripts:
   - Our: `tock/boards/nano-esp32-c6/layout.ld`
   - Embassy: `esp-hal-common/out/linkall.x`

4. Check for segment alignment issues

**Possible Fixes**:
- Adjust linker script segment layout
- Add missing segments
- Fix segment flags (read/write/execute)
- Adjust entry point or segment addresses

### Phase 3: Dual Serial Support (2-3 hours)

**Goal**: Support both USB-JTAG (debug) and UART0 (production)

**Implementation**:
- USB-JTAG for kernel debug output
- UART0 for userspace console
- Runtime selection via config

---

## Step-by-Step Plan: USB-JTAG "Hello World"

### Step 1: Create USB-JTAG Driver (2 hours)

**File**: `tock/chips/esp32-c6/src/usb_serial_jtag.rs`

```rust
//! USB-JTAG Serial Driver for ESP32-C6
//!
//! The USB-JTAG peripheral provides a serial interface over USB
//! without requiring external UART hardware. The ROM bootloader
//! initializes it, so we can use it immediately.

use kernel::utilities::registers::{register_bitfields, ReadWrite};
use kernel::utilities::StaticRef;

const USB_SERIAL_JTAG_BASE: usize = 0x6000_F000;

#[repr(C)]
struct UsbSerialJtagRegisters {
    ep1: ReadWrite<u32>,           // 0x00 - FIFO data
    ep1_conf: ReadWrite<u32>,      // 0x04 - Configuration
    int_raw: ReadWrite<u32>,       // 0x08 - Raw interrupts
    int_st: ReadWrite<u32>,        // 0x0C - Interrupt status
    int_ena: ReadWrite<u32>,       // 0x10 - Interrupt enable
    int_clr: ReadWrite<u32>,       // 0x14 - Interrupt clear
    conf0: ReadWrite<u32>,         // 0x18 - Configuration 0
}

register_bitfields![u32,
    EP1_CONF [
        WR_DONE OFFSET(0) NUMBITS(1) [],
        SERIAL_IN_EP_DATA_FREE OFFSET(1) NUMBITS(1) []
    ]
];

const REGISTERS: StaticRef<UsbSerialJtagRegisters> =
    unsafe { StaticRef::new(USB_SERIAL_JTAG_BASE as *const UsbSerialJtagRegisters) };

/// Write bytes to USB-JTAG serial
pub fn write_bytes(bytes: &[u8]) {
    let regs = REGISTERS;
    
    for &byte in bytes {
        // Wait if FIFO is full
        while (regs.ep1_conf.get() & 0b010) == 0 {
            // Timeout after some iterations to avoid hanging
            // if no USB host is connected
        }
        
        // Write byte to FIFO
        regs.ep1.set(byte as u32);
    }
    
    // Flush FIFO
    regs.ep1_conf.set(0b001);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_usb_serial_jtag_base() {
        assert_eq!(USB_SERIAL_JTAG_BASE, 0x6000_F000);
    }
}
```

### Step 2: Export Module (5 minutes)

**File**: `tock/chips/esp32-c6/src/lib.rs`

```rust
pub mod usb_serial_jtag;
```

### Step 3: Update io.rs (30 minutes)

**File**: `tock/boards/nano-esp32-c6/src/io.rs`

```rust
use core::fmt::Write;
use core::panic::PanicInfo;
use kernel::debug;
use kernel::debug::IoWrite;

pub struct Writer {}

impl Write for Writer {
    fn write_str(&mut self, s: &str) -> ::core::fmt::Result {
        self.write(s.as_bytes());
        Ok(())
    }
}

impl IoWrite for Writer {
    fn write(&mut self, buf: &[u8]) -> usize {
        // Use USB-JTAG serial (always available, no init needed)
        esp32_c6::usb_serial_jtag::write_bytes(buf);
        buf.len()
    }
}

// ... rest of panic handler unchanged
```

### Step 4: Add Early Debug Output (15 minutes)

**File**: `tock/boards/nano-esp32-c6/src/main.rs`

```rust
#[no_mangle]
pub unsafe fn main() {
    // Early debug output via USB-JTAG
    esp32_c6::usb_serial_jtag::write_bytes(b"\r\n=== Tock Kernel Starting ===\r\n");
    
    // ... rest of initialization
    
    esp32_c6::usb_serial_jtag::write_bytes(b"Kernel initialized, entering main loop\r\n");
    
    kernel.kernel_loop(&NANO_ESP32_C6, chip, None::<&kernel::ipc::IPC<0>>, &main_loop_cap);
}
```

### Step 5: Test (30 minutes)

```bash
cd tock/boards/nano-esp32-c6
cargo build --release
espflash flash --monitor target/riscv32imac-unknown-none-elf/release/nano-esp32-c6-board.elf
```

**Expected Output**:
```
=== Tock Kernel Starting ===
Kernel initialized, entering main loop
```

---

## Risks Identified

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| USB-JTAG not initialized by ROM | Low | High | Add initialization code if needed |
| FIFO timeout hangs kernel | Medium | High | Add timeout counter with escape |
| Bootloader issue persists | High | High | Investigate ELF segment layout |
| Register addresses wrong | Low | High | Cross-reference with TRM |
| USB host not connected causes hang | Medium | Medium | Implement timeout detection |

---

## Handoff to Implementor

### Immediate Next Steps

1. **Create USB-JTAG driver** (Step 1 above)
   - Copy register definitions
   - Implement write_bytes()
   - Add timeout protection

2. **Update io.rs** (Step 3 above)
   - Switch from UART to USB-JTAG
   - Remove UART dependency

3. **Add early debug** (Step 4 above)
   - Output at kernel start
   - Output before main loop

4. **Test and verify** (Step 5 above)
   - Should see output immediately
   - Proves kernel is booting

### Files to Create/Modify

**New Files**:
- `tock/chips/esp32-c6/src/usb_serial_jtag.rs`

**Modified Files**:
- `tock/chips/esp32-c6/src/lib.rs` - Export module
- `tock/boards/nano-esp32-c6/src/io.rs` - Use USB-JTAG
- `tock/boards/nano-esp32-c6/src/main.rs` - Early debug output

### Success Criteria

- [ ] USB-JTAG driver compiles without errors
- [ ] Early debug output appears on serial monitor
- [ ] "Hello World" message visible
- [ ] No kernel panic
- [ ] Output appears immediately after flash

### Debug Strategy

If no output appears:

1. **Check USB connection**: Ensure USB-C cable is data-capable
2. **Check serial port**: Verify `/dev/tty.usbmodem*` is correct port
3. **Add more output**: Put debug at very start of `main()`
4. **Check registers**: Verify USB-JTAG base address in TRM
5. **Try ROM functions**: Use ROM bootloader's USB-JTAG functions

### Reference Implementation

**Embassy esp-println**: `/Users/az02096/.cargo/registry/src/.../esp-println-0.8.0/src/lib.rs`
- Lines 104-107: Register addresses for ESP32-C6
- Lines 118-186: Complete implementation with timeout

**ESP-IDF**: `components/hal/esp32c6/include/hal/usb_serial_jtag_ll.h`
- Low-level register definitions
- Initialization sequences (if needed)

---

## Questions for PO

1. **Priority**: Should we fix bootloader issue first or get USB-JTAG working first?
   - **Recommendation**: USB-JTAG first (proves boot works, enables debugging)

2. **Serial Strategy**: USB-JTAG only, or dual USB-JTAG + UART0?
   - **Recommendation**: USB-JTAG for debug, UART0 for production later

3. **Bootloader Approach**: Keep using ESP-IDF bootloader or try true direct boot?
   - **Recommendation**: Keep ESP-IDF bootloader (matches embassy, proven to work)

4. **Testing**: Do we have hardware to test UART0 output (USB-UART adapter)?
   - **Impact**: If no, focus on USB-JTAG only

---

## Additional Notes

### Why Embassy "Just Works"

1. **Uses espflash flash**: Gets bootloader automatically
2. **Uses USB-JTAG**: No hardware setup needed
3. **Proper ELF format**: Segments match bootloader expectations
4. **Complete HAL**: All initialization handled

### Why Tock Doesn't Work Yet

1. **Wrong serial interface**: Configured UART0, test monitors USB-JTAG
2. **Bootloader mismatch**: ELF format doesn't match ESP-IDF bootloader expectations
3. **No USB-JTAG driver**: Can't output to monitored interface

### The Fix

1. **Implement USB-JTAG**: Match test infrastructure
2. **Fix ELF format**: Match embassy's segment layout
3. **Keep UART0**: Available for production use later

---

## Estimated Effort

- **Phase 1** (USB-JTAG Hello World): 4-6 hours
  - Driver implementation: 2 hours
  - Integration: 1 hour
  - Testing and debug: 1-3 hours

- **Phase 2** (Fix bootloader): 6-8 hours
  - Investigation: 2-3 hours
  - Linker script fixes: 2-3 hours
  - Testing: 2 hours

- **Phase 3** (Dual serial): 2-3 hours
  - Configuration: 1 hour
  - Testing: 1-2 hours

**Total**: 12-17 hours for complete solution

**Recommendation**: Start with Phase 1 (USB-JTAG), verify it works, then tackle Phase 2 (bootloader) with working debug output.

---

## References

- ESP32-C6 Technical Reference Manual: USB Serial/JTAG Controller Chapter
- Embassy `esp-println` source code (version 0.8.0)
- ESP-IDF `components/hal/esp32c6/include/hal/usb_serial_jtag_ll.h`
- espflash documentation and source code
- Analyst Report #022: UART initialization analysis
- Implementor Report #023: UART hardware configuration

---

## Conclusion

The path forward is clear:

1. **Implement USB-JTAG serial** - Simple, no hardware init needed, matches test infrastructure
2. **Get "Hello World" working** - Proves kernel boots successfully
3. **Debug bootloader issue** - With working serial output to help debug
4. **Keep UART0 available** - For production use later

The USB-JTAG approach is proven (embassy uses it), simple (no GPIO muxing), and matches our test infrastructure (monitors USB-JTAG port). This is the fastest path to a working system.
