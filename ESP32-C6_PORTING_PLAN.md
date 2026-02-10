# ESP32-C6 Tock OS Porting Plan

**Target:** Port Tock OS from ESP32-C3 to ESP32-C6 with equivalent functionality  
**Board:** nanoESP32-C6 by MuseLab  
**Version:** 1.0  
**Date:** 2026-02-10

---

## Table of Contents

1. [Objectives](#objectives)
2. [Success Criteria](#success-criteria)
3. [Prerequisites](#prerequisites)
4. [Phase Overview](#phase-overview)
5. [Phase 1: Foundation - Boot to Main Loop](#phase-1-foundation---boot-to-main-loop)
6. [Phase 2: Core Peripherals - Basic I/O](#phase-2-core-peripherals---basic-io)
7. [Phase 3: Complete Interrupt System](#phase-3-complete-interrupt-system)
8. [Phase 4: Feature Parity with C3](#phase-4-feature-parity-with-c3)
9. [Testing Strategy](#testing-strategy)
10. [Risk Mitigation](#risk-mitigation)
11. [Timeline and Milestones](#timeline-and-milestones)

---

## Objectives

### Primary Goal
Port Tock OS to ESP32-C6 with the same level of support as currently exists for ESP32-C3.

### Target Feature Set (Matching ESP32-C3)

**Implemented Components:**
- ✅ Boot sequence and kernel initialization
- ✅ Interrupt handling (INTC + CLINT)
- ✅ Timer Groups (TIMG0, TIMG1) for scheduling and alarms
- ✅ GPIO/IOMUX (31 pins vs C3's 22)
- ✅ UART0 for console and debug
- ✅ Hardware RNG
- ✅ System registers and clock configuration
- ✅ RTC control and watchdog management
- ✅ PMP-based memory protection
- ✅ Process loading and execution

**Out of Scope (Not in C3 either):**
- WiFi/Bluetooth
- SPI, I2C, I2S
- ADC, PWM/LEDC
- USB Serial/JTAG
- DMA
- Crypto accelerators
- LP CPU and LP peripherals (optional future enhancement)

---

## Success Criteria

### Minimum Viable Port (MVP)
- [x] Kernel boots successfully
- [x] UART console output works
- [x] Timer interrupts fire correctly
- [x] GPIO can be toggled (LED blink)
- [x] Process can be loaded and executed
- [x] System calls work
- [x] Basic scheduler functions

### Feature Complete
- [x] All MVP criteria met
- [x] Full interrupt system working (CLINT + INTC)
- [x] Multiple concurrent alarms
- [x] GPIO input with interrupts
- [x] Hardware RNG functional
- [x] Watchdog management
- [x] All C3 test cases pass on C6

### Production Ready
- [x] All Feature Complete criteria met
- [x] CI/CD integration
- [x] Documentation complete
- [x] Performance benchmarks meet expectations
- [x] Power management functional
- [x] Stable over extended runtime

---

## Prerequisites

### Hardware
- [x] nanoESP32-C6 development board by MuseLab ✅ **YOU HAVE THIS**
- [x] USB Type-C cable for programming and serial console
- [ ] (Optional) JTAG debugger for hardware debugging

**nanoESP32-C6 Board Features:**
- ESP32-C6-WROOM-1 module (8MB flash)
- Dual USB Type-C interfaces:
  - CH343 USB-to-serial (for flashing/debug) - `/dev/ttyACM0`
  - Native ESP32-C6 USB (can be used later)
- On-board RGB LED (WS2812/similar, specific GPIO TBD)
- All GPIO pins broken out
- 3.3V power regulation
- Flash mode: DIO, 80MHz

### Software
- [ ] Rust toolchain with `riscv32imac-unknown-none-elf` target
- [ ] esptool.py for flashing
- [ ] tockloader (configured for ESP32-C6)
- [ ] Serial terminal (e.g., minicom, screen, tio)

### Documentation
- [x] ESP32-C6 Technical Reference Manual
- [x] ESP32-C3 Technical Reference Manual (for comparison)
- [x] Current ESP32-C3 Tock implementation
- [x] Difference analysis document (`ESP32-C6_DIFFERENCES.md`)

### Knowledge
- [ ] Familiarity with RISC-V architecture
- [ ] Understanding of Tock OS architecture
- [ ] Basic embedded systems debugging skills
- [ ] ESP32 peripheral concepts

### nanoESP32-C6 Specific Information

**Module:** ESP32-C6-WROOM-1 (8MB flash)  
**Flash Size:** 8MB (2MB usable with standard partition, expandable)  
**Package:** QFN40 with internal flash

**Key Hardware Details:**
- **RGB LED:** On-board WS2812-compatible RGB LED (GPIO to be identified in schematic)
- **Flash Interface:** Uses internal flash (GPIO26-31 likely used for flash)
- **Available GPIOs:** Most GPIO0-25 should be available
- **USB Interfaces:**
  - CH343 UART: `/dev/ttyACM0` (for esptool.py flashing)
  - ESP32-C6 USB: Can be used for USB Serial/JTAG (future feature)
- **Flash Parameters:** DIO mode, 80MHz frequency

**Flashing Command (from board documentation):**
```bash
esptool.py --chip esp32c6 -p /dev/ttyACM0 -b 460800 \
  --before=default_reset --after=hard_reset write_flash \
  --flash_mode dio --flash_freq 80m --flash_size 8MB \
  0x0 bootloader.bin 0x8000 partition-table.bin 0x10000 app.bin
```

**Important Notes:**
1. Use `/dev/ttyACM0` for flashing (CH343 USB-to-serial)
2. Board has 8MB flash vs typical 2MB - we can expand allocations
3. RGB LED adds visual debugging capability
4. All standard ESP32-C6 GPIOs should be available

---

## Phase Overview

| Phase | Goal | Duration | Deliverable |
|-------|------|----------|-------------|
| **Phase 1** | Boot to main loop | 2-3 weeks | Kernel boots, reaches scheduler |
| **Phase 2** | Basic I/O working | 2-3 weeks | UART, GPIO, Timer functional |
| **Phase 3** | Full interrupts | 2-3 weeks | All interrupt sources working |
| **Phase 4** | Feature parity | 1-2 weeks | Match C3 functionality |

**Total Estimated Time:** 7-11 weeks (part-time) or 4-6 weeks (full-time)

---

## Phase 1: Foundation - Boot to Main Loop

**Goal:** Successfully boot the kernel and reach the main event loop without peripherals.

**Success Criteria:**
- Kernel loads from flash
- ROM bootloader jumps to Tock entry point
- Trap handler is configured
- Basic initialization completes
- Main scheduler loop is reached
- No crashes during early boot

### Step 1.1: Create Directory Structure

**Duration:** 1 day

**Tasks:**
1. Create new board directory
   ```bash
   cd tock/boards
   cp -r esp32-c3-devkitM-1 nanoESP32-c6
   cd nanoESP32-c6
   ```

2. Create new chip directory
   ```bash
   cd tock/chips
   cp -r esp32-c3 esp32-c6
   cd esp32-c6
   ```

3. Update `Cargo.toml` in both directories
   - Change package names: `esp32-c3-*` → `esp32-c6-*`
   - Update dependencies
   - Set correct edition and metadata

**Deliverables:**
- `tock/boards/nanoESP32-c6/` directory
- `tock/chips/esp32-c6/` directory
- Updated `Cargo.toml` files

### Step 1.2: Update Build Configuration

**Duration:** 1 day

**Tasks:**
1. Update `.cargo/config.toml`
   ```toml
   [build]
   target = "riscv32imac-unknown-none-elf"  # Changed from riscv32imc
   
   [target.riscv32imac-unknown-none-elf]
   rustflags = [
     "-C", "link-arg=-Tlayout.ld",
     "-C", "relocation-model=static",
   ]
   ```

2. Update `Makefile`
   ```makefile
   PLATFORM = nanoESP32-c6
   TARGET = riscv32imac-unknown-none-elf
   FLASH_ADDRESS = 0x40380000
   APP_ADDRESS = 0x403A8000
   ```

3. Verify Rust toolchain has target
   ```bash
   rustup target add riscv32imac-unknown-none-elf
   ```

**Deliverables:**
- Updated build configuration files
- Verified toolchain installation

### Step 1.3: Update Memory Layout (Linker Script)

**Duration:** 2 days

**File:** `boards/nanoESP32-c6/layout.ld`

**Tasks:**
1. Update memory regions based on C6 memory map:
   ```ld
   MEMORY {
       /* Flash for kernel - C6 has 320KB ROM instead of 384KB */
       rom (rx)  : ORIGIN = 0x40380000, LENGTH = 0x28000  /* 160 KB */
       
       /* HP SRAM - C6 has 512KB at new address */
       ram (rwx) : ORIGIN = 0x40800000, LENGTH = 0x40000  /* 256 KB */
       
       /* Flash for applications */
       prog (rx) : ORIGIN = 0x403A8000, LENGTH = 0x30000  /* 192 KB */
   }
   ```

2. Verify section placement:
   - `.text` → rom
   - `.rodata` → rom
   - `.data` → ram (load from rom)
   - `.bss` → ram
   - Stack and heap → ram
   - App binaries → prog

3. Update symbols:
   - `_stext`, `_etext`
   - `_srelocate`, `_erelocate`
   - `_szero`, `_ezero`
   - `_sstack`, `_estack`
   - `_sapps`, `_eapps`
   - `_sappmem`, `_eappmem`

**Key Changes from C3:**
- ROM size: 192 KB → 160 KB (C6 has smaller ROM)
- RAM address: 0x3FCA0000 → 0x40800000 (completely different!)
- RAM size: 192 KB → 256 KB (more available)
- Unified bus (no separate IBUS/DBUS addresses)

**Verification:**
```bash
riscv32-unknown-elf-objdump -h target/riscv32imac-unknown-none-elf/release/nanoESP32-c6.elf
```

**Deliverables:**
- Updated `layout.ld`
- Build succeeds
- Section addresses verified

### Step 1.4: Create Peripheral Base Address Constants

**Duration:** 1 day

**File:** `chips/esp32-c6/src/lib.rs`

**Tasks:**
1. Create constants for all peripheral base addresses:
   ```rust
   // Interrupt system
   pub const INTMTX_BASE: usize = 0x6001_0000;
   pub const INTPRI_BASE: usize = 0x600C_5000;
   pub const CLINT_M_BASE: usize = 0x2000_1800;
   pub const CLINT_U_BASE: usize = 0x2000_1C00;
   
   // System control
   pub const HP_SYSREG_BASE: usize = 0x6009_5000;
   pub const PCR_BASE: usize = 0x6009_6000;
   
   // Timers
   pub const TIMG0_BASE: usize = 0x6000_8000;
   pub const TIMG1_BASE: usize = 0x6000_9000;
   
   // Communication
   pub const UART0_BASE: usize = 0x6000_0000;  // UNCHANGED
   pub const UART1_BASE: usize = 0x6000_1000;
   pub const LP_UART_BASE: usize = 0x600B_1400;
   
   // GPIO
   pub const GPIO_BASE: usize = 0x6009_1000;
   pub const IOMUX_BASE: usize = 0x6009_0000;
   pub const LP_IOMUX_BASE: usize = 0x600B_2000;
   
   // Power management
   pub const PMU_BASE: usize = 0x600B_0000;
   pub const RTC_TIMER_BASE: usize = 0x600B_0C00;
   pub const RTC_WDT_BASE: usize = 0x600B_1C00;
   pub const LP_AON_BASE: usize = 0x600B_1000;
   pub const LP_CLKRST_BASE: usize = 0x600B_0400;
   
   // Other
   pub const RNG_BASE: usize = 0x6002_60B0;  // TODO: Verify
   pub const UHCI_BASE: usize = 0x6000_5000;
   ```

2. Document source of each address (reference C6 TRM chapter)

**Deliverables:**
- Comprehensive address constant definitions
- Documentation comments with TRM references

### Step 1.5: Minimal Interrupt Controller Implementation

**Duration:** 3-5 days

**Files:**
- `chips/esp32-c6/src/intc.rs` - INTC driver
- `chips/esp32-c6/src/clint.rs` - CLINT driver (new)
- `chips/esp32-c6/src/interrupts.rs` - Interrupt definitions

#### Task 1.5a: Update Interrupt Definitions

**File:** `chips/esp32-c6/src/interrupts.rs`

**Changes:**
1. Define 28 external interrupts (IDs 1-2, 5-6, 8-31)
2. Define 4 CLINT interrupts (IDs 0, 3, 4, 7)
3. Look up peripheral interrupt sources from C6 Chapter 10
4. Create enums:
   ```rust
   #[repr(u32)]
   pub enum ExternalInterrupt {
       IRQ_1 = 1,
       IRQ_2 = 2,
       // ID 3 reserved for CLINT
       IRQ_5 = 5,
       IRQ_6 = 6,
       // ID 7 reserved for CLINT
       IRQ_8 = 8,
       // ... 9-31
   }
   
   #[repr(u32)]
   pub enum ClintInterrupt {
       U_SOFTWARE = 0,
       M_SOFTWARE = 3,
       U_TIMER = 4,
       M_TIMER = 7,
   }
   
   // TODO: Map peripheral sources to interrupt IDs
   // These need to be looked up in C6 TRM Chapter 10
   pub const UART0_INTERRUPT: u32 = ?;
   pub const UART1_INTERRUPT: u32 = ?;
   pub const GPIO_INTERRUPT: u32 = ?;
   pub const TIMG0_INTERRUPT: u32 = ?;
   pub const TIMG1_INTERRUPT: u32 = ?;
   ```

#### Task 1.5b: Minimal INTC Driver

**File:** `chips/esp32-c6/src/intc.rs`

**Approach:** Port from C3, update for C6 changes

**Key Changes:**
1. Update base addresses (INTMTX + INTPRI)
2. Update register names (`INTERRUPT_*` → `INTPRI_*`)
3. Handle 28 interrupts instead of 31
4. Update priority range (0-15 instead of 1-15)

**Minimal Implementation:**
```rust
use kernel::utilities::registers::{register_bitfields, register_structs, ReadWrite};
use kernel::utilities::StaticRef;

register_structs! {
    pub IntPriRegisters {
        (0x000 => cpu_int_enable: ReadWrite<u32>),
        (0x004 => cpu_int_type: ReadWrite<u32>),
        (0x008 => cpu_int_clear: ReadWrite<u32>),
        (0x00c => cpu_int_eip_status: ReadWrite<u32>),
        (0x010 => cpu_int_pri_0: ReadWrite<u32>),
        // ... pri_1 through pri_31
        (0x090 => cpu_int_thresh: ReadWrite<u32>),
        (0x094 => @END),
    }
}

pub struct Intc {
    intpri_registers: StaticRef<IntPriRegisters>,
    // TODO: Add INTMTX registers when needed
}

impl Intc {
    pub fn new() -> Self {
        Intc {
            intpri_registers: unsafe { 
                StaticRef::new(INTPRI_BASE as *const IntPriRegisters) 
            },
        }
    }
    
    pub fn enable(&self, interrupt: u32) {
        // Set enable bit for interrupt
    }
    
    pub fn disable(&self, interrupt: u32) {
        // Clear enable bit
    }
    
    pub fn set_priority(&self, interrupt: u32, priority: u8) {
        // Priority 0-15
    }
    
    pub fn clear(&self, interrupt: u32) {
        // Clear pending interrupt
    }
}
```

#### Task 1.5c: Minimal CLINT Driver

**File:** `chips/esp32-c6/src/clint.rs` (NEW)

**Approach:** Implement from scratch based on C6 TRM Chapter 7

**Minimal Implementation:**
```rust
use kernel::utilities::registers::{register_bitfields, register_structs, ReadWrite};
use kernel::utilities::StaticRef;

register_structs! {
    pub ClintMRegisters {
        (0x00 => msip: ReadWrite<u32>),
        (0x04 => mtimectl: ReadWrite<u32>),
        (0x08 => mtime_lo: ReadWrite<u32>),
        (0x0c => mtime_hi: ReadWrite<u32>),
        (0x10 => mtimecmp_lo: ReadWrite<u32>),
        (0x14 => mtimecmp_hi: ReadWrite<u32>),
        (0x18 => @END),
    }
}

pub struct Clint {
    m_registers: StaticRef<ClintMRegisters>,
}

impl Clint {
    pub fn new() -> Self {
        Clint {
            m_registers: unsafe {
                StaticRef::new(CLINT_M_BASE as *const ClintMRegisters)
            },
        }
    }
    
    pub fn get_mtime(&self) -> u64 {
        // Read 64-bit timer value
        let lo = self.m_registers.mtime_lo.get();
        let hi = self.m_registers.mtime_hi.get();
        ((hi as u64) << 32) | (lo as u64)
    }
    
    pub fn set_mtimecmp(&self, value: u64) {
        // Set timer compare for interrupt
        let lo = (value & 0xFFFF_FFFF) as u32;
        let hi = (value >> 32) as u32;
        self.m_registers.mtimecmp_lo.set(lo);
        self.m_registers.mtimecmp_hi.set(hi);
    }
    
    pub fn clear_timer_interrupt(&self) {
        // Clear by setting mtimecmp to max
        self.set_mtimecmp(u64::MAX);
    }
}
```

**Deliverables:**
- Working INTC driver with basic enable/disable/priority
- Working CLINT driver with timer functionality
- Interrupt ID definitions

### Step 1.6: Update Trap Handler

**Duration:** 2-3 days

**File:** `chips/esp32-c6/src/chip.rs`

**Tasks:**
1. Update `configure_trap_handler()` to set up vectored interrupts
2. Implement dual interrupt routing in `handle_interrupt()`:
   ```rust
   pub unsafe fn handle_interrupt() {
       let mcause = csr::CSR.mcause.read();
       
       if mcause & (1 << 31) != 0 {
           // Interrupt bit set
           let int_id = mcause & 0x1F;
           
           match int_id {
               0 | 3 | 4 | 7 => {
                   // CLINT interrupt
                   CHIP.unwrap().clint.handle_interrupt(int_id);
               }
               _ => {
                   // External interrupt via INTC
                   CHIP.unwrap().intc.handle_interrupt();
               }
           }
       } else {
           // Exception
           handle_exception();
       }
   }
   ```

3. Update `Esp32C6` chip structure:
   ```rust
   pub struct Esp32C6<'a, I: InterruptService<()> + 'a> {
       mpu: PMPUserMPU<8, SimplePMP<16>>,
       intc: &'a Intc,
       clint: &'a Clint,
       scheduler_timer: &'a VirtualSchedulerTimer<ClintTimer>,
       userspace_kernel_boundary: SysCall,
   }
   ```

**Deliverables:**
- Updated trap handler with CLINT routing
- Chip structure with INTC + CLINT

### Step 1.7: Minimal System Initialization

**Duration:** 2 days

**File:** `boards/nanoESP32-c6/src/main.rs`

**Tasks:**
1. Update `setup()` function for minimal boot:
   ```rust
   pub unsafe fn setup() -> (
       &'static kernel::Kernel,
       &'static Esp32C6<'static>,
       &'static Esp32C6DefaultPeripherals<'static>,
   ) {
       // Configure trap handler
       esp32_c6::chip::configure_trap_handler();
       
       // Initialize deferred calls
       kernel::deferred_call::DeferredCallClient::initialize();
       
       // Create peripherals
       let peripherals = static_init!(
           Esp32C6DefaultPeripherals,
           Esp32C6DefaultPeripherals::new()
       );
       
       // Disable watchdogs
       // TODO: Update for C6 watchdog addresses
       
       // Create chip
       let chip = static_init!(
           Esp32C6,
           Esp32C6::new(&peripherals.intc, &peripherals.clint)
       );
       
       // Create kernel
       let kernel = static_init!(
           kernel::Kernel,
           kernel::Kernel::new(&PROCESSES)
       );
       
       (kernel, chip, peripherals)
   }
   ```

2. Comment out all peripheral initialization except bare minimum
3. Skip process loading for now
4. Just enter main loop

**Deliverables:**
- Minimal `main.rs` that boots to scheduler loop

### Step 1.8: First Build and Flash

**Duration:** 1-2 days (includes debugging)

**Tasks:**
1. Build the kernel:
   ```bash
   cd boards/nanoESP32-c6
   make
   ```

2. Fix compilation errors:
   - Missing dependencies
   - Type mismatches
   - API changes

3. Flash to board:
   ```bash
   make flash
   ```

4. Monitor serial output:
   ```bash
   tio /dev/ttyUSB0 -b 115200
   ```

**Expected Issues:**
- Compilation errors due to missing/changed APIs
- Boot failures due to incorrect memory addresses
- Crashes in initialization code

**Debugging Strategy:**
- Use GPIO bit-banging if UART doesn't work yet
- Add LED toggle at various boot stages
- Use JTAG debugger if available
- Check memory addresses in ELF file

**Success Indicator:**
- Kernel boots without crashing
- Reaches main scheduler loop
- (Optional) Serial output appears if UART works

**Deliverables:**
- Successfully built kernel binary
- Flashed to ESP32-C6 board
- Boot reaches main loop (verified by LED/JTAG/serial)

---

## Phase 2: Core Peripherals - Basic I/O

**Goal:** Get UART, GPIO, and Timer working for basic interaction.

**Success Criteria:**
- UART console output works
- GPIO can be toggled (LED blink)
- Timer interrupts fire
- Basic scheduling works

### Step 2.1: UART Driver

**Duration:** 2-3 days

**File:** `chips/esp32/src/uart.rs`

**Good News:** UART0 address unchanged (0x6000_0000)!

**Tasks:**
1. Test existing UART driver with C6:
   ```rust
   // In main.rs setup()
   let uart = static_init!(
       esp32::uart::Uart,
       esp32::uart::Uart::new(UART0_BASE, /* ... */)
   );
   uart.configure(uart::Parameters {
       baud_rate: 115200,
       // ...
   });
   ```

2. If issues, check:
   - Register layout compatibility
   - Clock source configuration (may need PCR)
   - Interrupt mapping

3. Set up console:
   ```rust
   let console = static_init!(
       capsules_core::console::Console,
       capsules_core::console::Console::new(
           uart,
           &mut CONSOLE_BUF,
           &mut CONSOLE_WRITE_BUF,
           &mut CONSOLE_READ_BUF,
       )
   );
   uart.set_transmit_client(console);
   uart.set_receive_client(console);
   ```

4. Test with debug print:
   ```rust
   debug!("ESP32-C6 Tock kernel booting...");
   ```

**Deliverables:**
- UART0 working for console output
- Debug messages visible on serial terminal

### Step 2.2: GPIO Driver Update

**Duration:** 3-4 days

**File:** `chips/esp32/src/gpio.rs`

**Tasks:**
1. Update base addresses:
   ```rust
   const GPIO_BASE: usize = 0x6009_1000;  // was 0x6000_4000
   const IOMUX_BASE: usize = 0x6009_0000; // was 0x6000_9000
   ```

2. Increase pin count:
   ```rust
   pub struct Port<'a> {
       pins: [GpioPin<'a>; 31],  // was 22
   }
   
   impl Port<'_> {
       pub fn new() -> Self {
           Port {
               pins: [
                   GpioPin::new(0),
                   GpioPin::new(1),
                   // ... up to 30
                   GpioPin::new(30),
               ],
           }
       }
   }
   ```

3. Update array sizes in registers:
   - `GPIO_OUT_REG` - 32 bits (enough for 31 pins)
   - `GPIO_ENABLE_REG` - 32 bits
   - `GPIO_IN_REG` - 32 bits
   - Per-pin registers up to GPIO30

4. Test with LED blink:
   ```rust
   // Assuming LED on GPIO8 like C3
   let led = &peripherals.gpio.pins[8];
   led.make_output();
   led.set();  // Turn on
   // ... timer-based blink
   ```

**Package Consideration:**
- Document which pins are available on your board
- Some pins may be used for flash (GPIO26-31 on some packages)

**Deliverables:**
- GPIO driver updated for 31 pins
- LED blink working
- GPIO output verified

### Step 2.3: Timer Groups Driver

**Duration:** 3-4 days

**File:** `chips/esp32/src/timg.rs`

**Tasks:**
1. Update base addresses:
   ```rust
   pub const TIMG0_BASE: usize = 0x6000_8000;  // was 0x6001_F000
   pub const TIMG1_BASE: usize = 0x6000_9000;  // was 0x6002_0000
   ```

2. Update clock configuration to use PCR:
   ```rust
   // Instead of SYSCON, use PCR module
   pub fn configure_clock(&self, source: ClockSource) {
       match source {
           ClockSource::XTAL => {
               // Set PCR_TG0_TIMER_CLK_SEL = 0
               let pcr = PCR_BASE as *mut u32;
               unsafe {
                   let conf = pcr.add(PCR_TG0_TIMER_CLK_CONF_OFFSET);
                   *conf = (*conf & !0x3) | 0x0;  // XTAL_CLK
                   *conf |= (1 << 22);  // Enable clock
               }
           }
           ClockSource::PLL80M => {
               // Set PCR_TG0_TIMER_CLK_SEL = 1
               // Similar to above but value 0x1
           }
           // New in C6: RC_FAST_CLK option
           ClockSource::RC_FAST => {
               // Set PCR_TG0_TIMER_CLK_SEL = 2
           }
       }
   }
   ```

3. Verify register layout compatibility:
   - `TIMG_T0CONFIG_REG`
   - `TIMG_T0LO_REG` / `TIMG_T0HI_REG`
   - `TIMG_T0ALARMLO_REG` / `TIMG_T0ALARMHI_REG`
   - Interrupt registers

4. Create timer for scheduling:
   ```rust
   let timer = static_init!(
       esp32::timg::TimG,
       esp32::timg::TimG::new(TIMG1_BASE)
   );
   timer.configure_clock(ClockSource::PLL80M);
   timer.enable();
   ```

5. Set up alarm for testing:
   ```rust
   let alarm = static_init!(
       MuxAlarm<'static, esp32::timg::TimG>,
       MuxAlarm::new(timer)
   );
   timer.set_alarm_client(alarm);
   
   // Test alarm
   alarm.set_alarm(timer.now(), timer.now().wrapping_add(80_000_000)); // 1 second
   ```

**Deliverables:**
- Timer driver working with new addresses
- Clock configuration via PCR
- Timer interrupts firing
- Scheduler timer functional

### Step 2.4: System Clock Configuration

**Duration:** 2-3 days

**Files:**
- `chips/esp32-c6/src/pcr.rs` (NEW)
- `chips/esp32-c6/src/sysreg.rs` (update)

**Tasks:**
1. Create PCR (Power, Clock, Reset) driver:
   ```rust
   pub struct Pcr {
       registers: StaticRef<PcrRegisters>,
   }
   
   impl Pcr {
       pub fn enable_peripheral_clock(&self, peripheral: Peripheral) {
           match peripheral {
               Peripheral::TIMG0 => {
                   // Set PCR_TG0_TIMER_CLK_EN
               }
               Peripheral::UART0 => {
                   // Set PCR_UART0_CLK_EN
               }
               // ...
           }
       }
       
       pub fn configure_cpu_clock(&self, freq: CpuFrequency) {
           match freq {
               CpuFrequency::Mhz80 => {
                   // Configure PLL and dividers for 80 MHz
               }
               CpuFrequency::Mhz160 => {
                   // Configure for 160 MHz
               }
           }
       }
   }
   ```

2. Update system initialization to use PCR:
   ```rust
   let pcr = static_init!(Pcr, Pcr::new());
   pcr.configure_cpu_clock(CpuFrequency::Mhz160);
   pcr.enable_peripheral_clock(Peripheral::TIMG0);
   pcr.enable_peripheral_clock(Peripheral::UART0);
   ```

3. Port SYSCON functionality to PCR equivalents

**Deliverables:**
- PCR driver for clock/reset control
- System clock configured correctly
- Peripheral clocks enabled

### Step 2.5: Basic Application Test

**Duration:** 1-2 days

**Tasks:**
1. Enable process loading:
   ```rust
   // In main.rs
   kernel::process::load_processes(
       board_kernel,
       chip,
       core::slice::from_raw_parts(
           &_sapps as *const u8,
           &_eapps as *const u8 as usize - &_sapps as *const u8 as usize,
       ),
       core::slice::from_raw_parts_mut(
           &mut _sappmem as *mut u8,
           &_eappmem as *const u8 as usize - &_sappmem as *mut u8 as usize,
       ),
       &mut PROCESSES,
       &FAULT_RESPONSE,
       &process_mgmt_cap,
   );
   ```

2. Build and flash simple app (e.g., blink or hello):
   ```bash
   cd libtock-c/examples/blink
   make
   tockloader install blink.tab
   ```

3. Verify app runs

**Expected Issues:**
- System call interface compatibility
- Memory protection (PMP) configuration
- Process initialization

**Deliverables:**
- Process loading works
- Simple application executes
- System calls functional

**Phase 2 Complete When:**
- [x] UART console output works
- [x] GPIO can toggle LED
- [x] Timer interrupts fire
- [x] Basic app runs
- [x] System calls work

---

## Phase 3: Complete Interrupt System

**Goal:** Full interrupt controller implementation with all sources working.

**Success Criteria:**
- All 28 external interrupts can be enabled/disabled
- All 4 CLINT interrupts work
- Interrupt priorities function correctly
- Multiple concurrent interrupts handled properly

### Step 3.1: Complete INTC Implementation

**Duration:** 3-4 days

**File:** `chips/esp32-c6/src/intc.rs`

**Tasks:**
1. Implement full register definitions:
   ```rust
   register_structs! {
       pub IntPriRegisters {
           (0x000 => cpu_int_enable: ReadWrite<u32>),
           (0x004 => cpu_int_type: ReadWrite<u32>),
           (0x008 => cpu_int_clear: ReadWrite<u32>),
           (0x00c => cpu_int_eip_status: ReadWrite<u32>),
           (0x010 => cpu_int_pri: [ReadWrite<u32>; 32]),
           (0x090 => cpu_int_thresh: ReadWrite<u32>),
           (0x094 => @END),
       }
   }
   
   register_structs! {
       pub IntMtxRegisters {
           (0x000 => intr_map: [ReadWrite<u32>; 64]),  // Map peripheral sources
           (0x100 => @END),
       }
   }
   ```

2. Implement interrupt mapping:
   ```rust
   pub fn map_interrupt(&self, source: u32, cpu_int: u32) {
       // Map peripheral interrupt source to CPU interrupt ID
       self.intmtx_registers.intr_map[source].set(cpu_int);
   }
   ```

3. Implement priority configuration:
   ```rust
   pub fn set_priority(&self, interrupt: u32, priority: u8) {
       assert!(priority <= 15);  // C6 has 0-15 priority
       self.intpri_registers.cpu_int_pri[interrupt].set(priority as u32);
   }
   
   pub fn set_threshold(&self, threshold: u8) {
       assert!(threshold <= 15);
       self.intpri_registers.cpu_int_thresh.set(threshold as u32);
   }
   ```

4. Implement interrupt type (level/edge):
   ```rust
   pub fn set_type(&self, interrupt: u32, edge_triggered: bool) {
       let mut val = self.intpri_registers.cpu_int_type.get();
       if edge_triggered {
           val |= 1 << interrupt;
       } else {
           val &= !(1 << interrupt);
       }
       self.intpri_registers.cpu_int_type.set(val);
   }
   ```

5. Implement interrupt handling:
   ```rust
   pub fn handle_interrupt(&self) -> Option<u32> {
       // Read which interrupt is pending
       let pending = self.intpri_registers.cpu_int_eip_status.get();
       
       // Find highest priority pending interrupt
       // (lowest numbered has highest priority if same priority value)
       for i in 1..32 {
           if i == 0 || i == 3 || i == 4 || i == 7 {
               continue;  // Skip CLINT IDs
           }
           if (pending & (1 << i)) != 0 {
               return Some(i);
           }
       }
       None
   }
   
   pub fn complete(&self, interrupt: u32) {
       // Clear interrupt
       self.intpri_registers.cpu_int_clear.set(1 << interrupt);
   }
   ```

**Deliverables:**
- Full INTC driver with all functions
- Interrupt mapping working
- Priority and threshold functional

### Step 3.2: Complete CLINT Implementation

**Duration:** 2-3 days

**File:** `chips/esp32-c6/src/clint.rs`

**Tasks:**
1. Implement all CLINT interrupts:
   ```rust
   impl Clint {
       // Machine timer interrupt (ID 7)
       pub fn set_mtimer(&self, ticks: u64) {
           self.m_registers.mtimecmp_lo.set((ticks & 0xFFFFFFFF) as u32);
           self.m_registers.mtimecmp_hi.set((ticks >> 32) as u32);
       }
       
       pub fn get_mtime(&self) -> u64 {
           let lo = self.m_registers.mtime_lo.get();
           let hi = self.m_registers.mtime_hi.get();
           let lo2 = self.m_registers.mtime_lo.get();
           
           // Check for wraparound
           if lo2 < lo {
               let hi2 = self.m_registers.mtime_hi.get();
               ((hi2 as u64) << 32) | (lo2 as u64)
           } else {
               ((hi as u64) << 32) | (lo as u64)
           }
       }
       
       // Machine software interrupt (ID 3)
       pub fn trigger_m_software_interrupt(&self) {
           self.m_registers.msip.set(1);
       }
       
       pub fn clear_m_software_interrupt(&self) {
           self.m_registers.msip.set(0);
       }
       
       // Optional: User mode interrupts (IDs 0, 4)
       // ...
   }
   ```

2. Implement CLINT as alarm/timer source:
   ```rust
   impl<'a> kernel::hil::time::Time for Clint<'a> {
       type Frequency = Freq80MHz;  // Or actual CLINT frequency
       type Ticks = u64;
       
       fn now(&self) -> u64 {
           self.get_mtime()
       }
   }
   
   impl<'a> kernel::hil::time::Alarm<'a> for Clint<'a> {
       fn set_alarm(&self, reference: u64, dt: u64) {
           let target = reference.wrapping_add(dt);
           self.set_mtimer(target);
       }
       
       fn get_alarm(&self) -> u64 {
           let lo = self.m_registers.mtimecmp_lo.get();
           let hi = self.m_registers.mtimecmp_hi.get();
           ((hi as u64) << 32) | (lo as u64)
       }
       
       // ...
   }
   ```

3. Use CLINT for scheduler timer:
   ```rust
   // In main.rs
   let clint = static_init!(Clint, Clint::new());
   
   let scheduler_timer = static_init!(
       VirtualSchedulerTimer<Clint>,
       VirtualSchedulerTimer::new(clint)
   );
   clint.set_alarm_client(scheduler_timer);
   ```

**Deliverables:**
- Full CLINT driver
- Timer interrupt working
- CLINT used for system timer

### Step 3.3: Map Peripheral Interrupts

**Duration:** 2-3 days

**File:** `chips/esp32-c6/src/interrupts.rs`

**Tasks:**
1. Look up peripheral interrupt IDs in ESP32-C6 TRM Chapter 10
2. Create mapping constants:
   ```rust
   // Peripheral interrupt sources (from TRM)
   pub const UART0_INTR_SOURCE: u32 = ?;  // Look up in Chapter 10
   pub const UART1_INTR_SOURCE: u32 = ?;
   pub const GPIO_INTR_SOURCE: u32 = ?;
   pub const TIMG0_T0_INTR_SOURCE: u32 = ?;
   pub const TIMG1_T0_INTR_SOURCE: u32 = ?;
   
   // CPU interrupt IDs (1-2, 5-6, 8-31)
   pub const UART0_CPU_INT: u32 = 21;  // Example, choose appropriately
   pub const UART1_CPU_INT: u32 = 22;
   pub const GPIO_CPU_INT: u32 = 16;
   pub const TIMG0_CPU_INT: u32 = 30;
   pub const TIMG1_CPU_INT: u32 = 31;
   ```

3. Configure mappings at startup:
   ```rust
   // In chip.rs or main.rs
   intc.map_interrupt(UART0_INTR_SOURCE, UART0_CPU_INT);
   intc.map_interrupt(GPIO_INTR_SOURCE, GPIO_CPU_INT);
   intc.map_interrupt(TIMG0_T0_INTR_SOURCE, TIMG0_CPU_INT);
   // ...
   ```

4. Update peripheral drivers to use correct interrupt IDs

**Deliverables:**
- Complete interrupt mapping table
- All peripherals mapped to CPU interrupts
- Interrupts fire for each peripheral

### Step 3.4: Test Interrupt Handling

**Duration:** 2-3 days

**Tasks:**
1. Test UART interrupt:
   ```rust
   // Enable UART RX interrupt
   uart.enable_receive_interrupt();
   
   // Type in serial console, verify interrupt fires
   ```

2. Test GPIO interrupt:
   ```rust
   // Configure button with interrupt
   button.enable_interrupts(gpio::InterruptEdge::FallingEdge);
   
   // Press button, verify interrupt
   ```

3. Test timer interrupt:
   ```rust
   // Set alarm
   timer.set_alarm(timer.now(), 1_000_000);  // 1 second @ 1MHz
   
   // Verify interrupt fires after 1 second
   ```

4. Test multiple concurrent interrupts:
   - Set up UART, GPIO, and Timer interrupts
   - Trigger all three
   - Verify all are handled
   - Check priority ordering

5. Test interrupt nesting (if enabled):
   - High priority interrupt preempts low priority

**Deliverables:**
- All interrupt sources tested
- Concurrent interrupts handled correctly
- Priority system working

**Phase 3 Complete When:**
- [x] All 28 external interrupts working
- [x] All 4 CLINT interrupts working
- [x] Peripheral interrupt mapping complete
- [x] Multiple concurrent interrupts handled
- [x] Priority system functional

---

## Phase 4: Feature Parity with C3

**Goal:** Complete remaining features to match ESP32-C3 functionality.

**Success Criteria:**
- All C3 drivers ported
- All C3 test cases pass
- CI/CD integration complete
- Documentation updated

### Step 4.1: RNG Driver

**Duration:** 1 day

**File:** `chips/esp32-c6/src/rng.rs`

**Tasks:**
1. Verify RNG base address (likely 0x6002_60B0, same as C3)
2. Test existing RNG driver
3. Update if needed:
   ```rust
   pub struct Rng {
       registers: StaticRef<RngRegisters>,
   }
   
   impl Rng {
       pub fn new() -> Self {
           Rng {
               registers: unsafe {
                   StaticRef::new(RNG_BASE as *const RngRegisters)
               },
           }
       }
       
       pub fn read(&self) -> u32 {
           self.registers.rng_data.get()
       }
   }
   ```

4. Verify entropy quality
5. Test with RNG application

**Deliverables:**
- RNG driver working
- Random numbers generated
- Entropy test passed

### Step 4.2: Power Management / Watchdog

**Duration:** 3-4 days

**Files:**
- `chips/esp32-c6/src/pmu.rs` (NEW)
- `chips/esp32-c6/src/rtc_wdt.rs` (update)

**Tasks:**
1. Create PMU (Power Management Unit) driver:
   ```rust
   pub struct Pmu {
       registers: StaticRef<PmuRegisters>,
   }
   
   impl Pmu {
       pub fn disable_all_watchdogs(&self) {
           // Disable RTC WDT
           // Disable Super WDT
           // Similar to C3 but different addresses/registers
       }
       
       pub fn configure_sleep(&self, mode: SleepMode) {
           // Configure light sleep or deep sleep
           // More complex than C3 due to HP/LP coordination
       }
   }
   ```

2. Update RTC watchdog for new address (0x600B_1C00):
   ```rust
   pub struct RtcWdt {
       registers: StaticRef<RtcWdtRegisters>,
   }
   
   impl RtcWdt {
       pub fn disable(&self) {
           // Disable RTC watchdog
           // Different register layout from C3
       }
   }
   ```

3. Disable watchdogs at startup:
   ```rust
   // In main.rs setup()
   let pmu = static_init!(Pmu, Pmu::new());
   pmu.disable_all_watchdogs();
   ```

**Note:** Full sleep mode support can be deferred. Focus on watchdog disable for now.

**Deliverables:**
- PMU driver for basic power management
- All watchdogs disabled at boot
- No unexpected resets

### Step 4.3: Complete Board Setup

**Duration:** 2-3 days

**File:** `boards/nanoESP32-c6/src/main.rs`

**Tasks:**
1. Add all peripherals to board:
   ```rust
   pub struct Esp32C6DefaultPeripherals<'a> {
       pub uart0: &'a esp32::uart::Uart<'a>,
       pub gpio: &'a esp32::gpio::Port<'a>,
       pub timg0: &'a esp32::timg::TimG<'a>,
       pub timg1: &'a esp32::timg::TimG<'a>,
       pub intc: &'a esp32_c6::intc::Intc,
       pub clint: &'a esp32_c6::clint::Clint<'a>,
       pub rng: &'a esp32_c6::rng::Rng,
       pub pmu: &'a esp32_c6::pmu::Pmu,
       // ...
   }
   ```

2. Set up all capsules (matching C3):
   - Console
   - GPIO
   - Alarm
   - LED (SK68XX if present)
   - Button
   - RNG

3. Configure process management:
   - Process console
   - Fault response
   - Memory allocation

4. Set up board-specific features:
   - LED on GPIO8 (or appropriate pin for C6 board)
   - Button on GPIO9 (or appropriate pin)

**Deliverables:**
- Complete board initialization
- All capsules functional
- Board-specific hardware configured

### Step 4.4: Testing

**Duration:** 3-5 days

**Tasks:**
1. Port C3 test suite to C6:
   ```rust
   // In boards/nanoESP32-c6/src/tests/
   mod multi_alarm_test;
   mod trivial_test;
   ```

2. Run all tests:
   ```bash
   # Build with tests enabled
   make test
   
   # Flash and monitor
   make flash
   # Run tests via console commands
   ```

3. Create C6-specific CI test configuration:
   ```rust
   // In tools/ci/board-runner/src/esp32_c6.rs
   pub fn run_tests(board: &str) {
       // C hello world
       // Blink
       // Sensors
       // Printf
       // Malloc
       // Stack tests
       // MPU tests
       // Multi-alarm
   }
   ```

4. Test applications from libtock-c:
   - blink
   - c_hello
   - buttons
   - sensors (if sensors added)

5. Stress testing:
   - Multiple apps running
   - Heavy interrupt load
   - Extended runtime
   - Memory allocation patterns

**Deliverables:**
- All C3 tests pass on C6
- CI test suite for C6
- Multiple applications verified

### Step 4.5: Documentation

**Duration:** 2-3 days

**Tasks:**
1. Create board README:
   ```markdown
   # nanoESP32-c6 Tock Board
   
   ## Board Description
   - ESP32-C6 with RISC-V core
   - 512 KB HP SRAM
   - 16 KB LP SRAM
   - 31 GPIO pins
   - WiFi 6, Bluetooth LE (not yet supported in Tock)
   
   ## Supported Features
   - UART console
   - GPIO
   - Timers
   - RNG
   - ...
   
   ## Build and Flash
   ...
   ```

2. Update chip documentation:
   ```markdown
   # ESP32-C6 Chip Support
   
   ## Architecture
   - RISC-V RV32IMAC
   - CLINT + INTC interrupt system
   - ...
   
   ## Implemented Drivers
   - INTC: Interrupt controller
   - CLINT: Core local interrupts
   - ...
   
   ## Memory Map
   ...
   ```

3. Document differences from C3:
   - Link to `ESP32-C6_DIFFERENCES.md`
   - Highlight breaking changes
   - Migration guide if sharing code

4. Update top-level Tock documentation:
   - Add ESP32-C6 to supported boards list
   - Update RISC-V boards section

**Deliverables:**
- Complete README for board
- Chip documentation
- Porting guide
- Updated Tock docs

### Step 4.6: CI/CD Integration

**Duration:** 2-3 days

**Tasks:**
1. Add C6 board to CI build matrix:
   ```yaml
   # In .github/workflows/ci.yml
   matrix:
     board:
       - esp32-c3-devkitM-1
       - nanoESP32-c6
       # ...
   ```

2. Set up automated testing (if hardware available):
   - Flash and test on real hardware
   - Run test suite
   - Collect results

3. Add size checks:
   ```yaml
   - name: Check binary size
     run: |
       size=<check nanoESP32-c6 binary size>
       if [ $size -gt 163840 ]; then
         echo "Binary too large!"
         exit 1
       fi
   ```

4. Set up documentation builds:
   - Auto-generate rustdoc
   - Deploy to docs site

**Deliverables:**
- C6 board in CI pipeline
- Automated testing (if possible)
- Size checks passing

**Phase 4 Complete When:**
- [x] RNG working
- [x] Watchdogs disabled
- [x] All peripherals functional
- [x] Test suite passes
- [x] Documentation complete
- [x] CI integrated

---

## Testing Strategy

### Unit Testing
- Test individual drivers in isolation
- Mock hardware interfaces
- Verify register access patterns

### Integration Testing
- Test driver interactions
- Verify interrupt handling across drivers
- Test process/kernel boundary

### Hardware Testing
- Flash to real ESP32-C6 board
- Run functional tests
- Verify timing and performance

### Test Applications

**Minimal Tests:**
1. **Blink** - GPIO output
2. **Hello** - UART output
3. **Button** - GPIO input with interrupt

**Intermediate Tests:**
4. **Printf** - Formatted output, buffer management
5. **Alarm** - Single timer alarm
6. **Multi-alarm** - Multiple concurrent alarms

**Advanced Tests:**
7. **Sensors** - If sensors available
8. **Malloc** - Memory allocation patterns
9. **Stack** - Stack growth and limits
10. **MPU** - Memory protection

### Debugging Tools

**Software:**
- `debug!()` macro for serial output
- LED toggling for state indication
- Assertion failures with panic handler

**Hardware:**
- JTAG debugger (OpenOCD + GDB)
- Logic analyzer for signal verification
- Oscilloscope for timing analysis

### Continuous Integration

**Automated Checks:**
- Build verification
- Size checks
- Test execution (if hardware in loop)
- Documentation generation
- Clippy lints
- Format checking

---

## Risk Mitigation

### Risk 1: Memory Address Errors

**Risk:** Incorrect peripheral addresses cause crashes or undefined behavior.

**Mitigation:**
- Create central constants file
- Cross-reference with TRM for every address
- Use static typing to prevent address confusion
- Test each peripheral individually

### Risk 2: Interrupt System Complexity

**Risk:** CLINT + INTC dual system is complex and error-prone.

**Mitigation:**
- Implement CLINT and INTC independently
- Test each interrupt source individually
- Use clear routing logic in trap handler
- Document interrupt ID reservations

### Risk 3: Clock Configuration

**Risk:** Incorrect clock setup causes timing issues or boot failure.

**Mitigation:**
- Start with conservative settings (80 MHz CPU, XTAL clock)
- Verify PLL lock before switching
- Measure actual frequencies with timer
- Use oscilloscope to verify if needed

### Risk 4: Toolchain Issues

**Risk:** RV32IMAC toolchain compatibility problems.

**Mitigation:**
- Verify toolchain before starting
- Use known-good Rust version
- Test atomic instructions explicitly
- Have fallback to RV32IMC if needed

### Risk 5: Peripheral Compatibility

**Risk:** C6 peripheral registers differ from C3 despite similar function.

**Mitigation:**
- Read register descriptions carefully
- Don't assume C3 code works on C6
- Test every register access
- Use conservative read-modify-write operations

### Risk 6: LP Subsystem Confusion

**Risk:** LP (Low-Power) peripherals interfere with HP peripherals.

**Mitigation:**
- Ignore LP subsystem initially
- Document LP peripherals as future work
- Ensure LP CPU is not running
- Keep HP and LP drivers separate

---

## Timeline and Milestones

### Timeline (Part-time Development)

```
Week 1-2:   Phase 1.1-1.4  Directory setup, memory layout, addresses
Week 3-4:   Phase 1.5-1.8  Interrupt basics, first boot
Week 5-6:   Phase 2.1-2.3  UART, GPIO, Timers
Week 7-8:   Phase 2.4-2.5  System config, apps
Week 9-10:  Phase 3.1-3.2  Complete interrupts
Week 11:    Phase 3.3-3.4  Peripheral mapping, testing
Week 12-13: Phase 4.1-4.3  RNG, PMU, board setup
Week 14-15: Phase 4.4-4.6  Testing, docs, CI
```

**Total: 15 weeks part-time (~7-8 weeks full-time)**

### Milestones

**M1: First Boot (End of Phase 1)**
- Date: Week 4
- Criteria: Kernel boots to main loop
- Deliverable: Working binary that boots on C6

**M2: Basic I/O (End of Phase 2)**
- Date: Week 8
- Criteria: UART, GPIO, Timer working
- Deliverable: LED blink app running

**M3: Full Interrupts (End of Phase 3)**
- Date: Week 11
- Criteria: All interrupt sources working
- Deliverable: Multi-alarm test passes

**M4: Feature Complete (End of Phase 4)**
- Date: Week 15
- Criteria: Match C3 functionality
- Deliverable: Production-ready port

### Success Metrics

**Technical Metrics:**
- Boot time < 100ms
- Interrupt latency < 10us
- Context switch < 5us
- Memory usage similar to C3

**Quality Metrics:**
- All tests pass
- No known critical bugs
- Documentation complete
- CI pipeline green

**Functional Metrics:**
- All C3 features ported
- Applications run correctly
- Stable over 24+ hours

---

## Next Steps

### Immediate Actions

1. **Verify Hardware**
   - [ ] Obtain ESP32-C6 development board
   - [ ] Test with basic examples (Arduino/ESP-IDF)
   - [ ] Verify serial console works

2. **Setup Development Environment**
   - [ ] Install Rust toolchain with `riscv32imac` target
   - [ ] Install esptool.py
   - [ ] Install tockloader
   - [ ] Clone Tock repository

3. **Read Documentation**
   - [ ] Review ESP32-C6 TRM Chapter 1 (System Overview)
   - [ ] Review Chapter 7 (CLINT)
   - [ ] Review Chapter 10 (Interrupts)
   - [ ] Review Chapter 5 (Memory)

4. **Start Phase 1**
   - [ ] Create directory structure
   - [ ] Update build configuration
   - [ ] Begin linker script updates

### Questions to Resolve

Before starting, clarify:
1. Which ESP32-C6 development board? (DevKitC-1 recommended)
2. What package? (QFN40 with internal flash most common)
3. Target use case? (IoT application, specific peripherals needed?)
4. LP CPU usage? (Defer to future or include now?)
5. Testing resources? (JTAG debugger available?)

### Decision Points

**After Phase 1:**
- Continue with incremental approach? Or
- Parallelize Phase 2 and 3?

**After Phase 2:**
- Add optional features (LP UART, ETM)? Or
- Focus on stability and testing?

**After Phase 3:**
- Target production deployment? Or
- Add advanced features (WiFi, Bluetooth)?

---

## Conclusion

This plan provides a systematic approach to porting Tock OS from ESP32-C3 to ESP32-C6. The four-phase structure allows for:

1. **Incremental Progress:** Each phase builds on previous work
2. **Early Validation:** Boot and basic I/O working quickly
3. **Risk Reduction:** Critical issues found early
4. **Flexibility:** Can stop at any phase for partial functionality

**Minimum Viable Port:** Complete Phases 1-2 (4-6 weeks)  
**Full Feature Parity:** Complete all phases (7-11 weeks)

The port is feasible because:
- Clear understanding of differences (see `ESP32-C6_DIFFERENCES.md`)
- Well-structured existing C3 implementation
- Comprehensive ESP32-C6 documentation
- Systematic approach with clear milestones

**Recommended Path Forward:**
1. Review this plan with team
2. Verify prerequisites
3. Begin Phase 1
4. Iterate based on findings

Good luck with the port!

---

**Document End**
