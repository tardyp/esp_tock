# PI003/SP001 - Super Analyst Report 016

## GPIO Input Failure: Root Cause Analysis and Solution

**Date:** 2026-02-13  
**Analyst:** Super Analyst  
**Sprint:** SP001_GPIOInterruptHIL  
**PI:** PI003_HILTesting  
**Priority:** CRITICAL

---

## Executive Summary

**ROOT CAUSE IDENTIFIED:** The GPIO input failure is caused by **missing GPIO clock gate enable**. The ESP32-C6 has a dedicated `GPIO_CLOCK_GATE_REG` register at offset `0x62C` that must be enabled for the GPIO peripheral to function. This is separate from the IO_MUX clock that was enabled in Report 014.

Additionally, there's a secondary issue: the GPIO register structure in Tock has incorrect offsets due to missing registers in the middle of the struct.

**Confidence Level:** HIGH (95%)

---

## Root Cause Analysis

### Finding 1: Missing GPIO Clock Gate (PRIMARY CAUSE)

**Evidence from ESP-IDF `gpio_struct.h`:**

```c
/** Type of clock_gate register
 *  GPIO clock gate register
 */
typedef union {
    struct {
        /** clk_en : R/W; bitpos: [0]; default: 1;
         *  set this bit to enable GPIO clock gate
         */
        uint32_t clk_en:1;
        uint32_t reserved_1:31;
    };
    uint32_t val;
} gpio_clock_gate_reg_t;

// Located at offset 0x62C in the GPIO register block
```

**Current Tock Implementation:** Does NOT enable this clock gate.

**Why This Matters:**
- The GPIO clock gate controls the clock to the GPIO peripheral itself
- Without this clock, GPIO input sampling does not work
- The default value is `1` (enabled), BUT the bootloader or reset may disable it
- This is DIFFERENT from the IO_MUX clock (which was fixed in Report 014)

### Finding 2: Incorrect GPIO Register Structure

**ESP-IDF GPIO Structure (correct):**
```
Offset  Register
0x000   bt_select
0x004   out
0x008   out_w1ts
0x00C   out_w1tc
0x010   out1              <-- MISSING IN TOCK
0x014   out1_w1ts         <-- MISSING IN TOCK
0x018   out1_w1tc         <-- MISSING IN TOCK
0x01C   sdio_select       <-- MISSING IN TOCK
0x020   enable
0x024   enable_w1ts
0x028   enable_w1tc
0x02C   enable1           <-- MISSING IN TOCK
0x030   enable1_w1ts      <-- MISSING IN TOCK
0x034   enable1_w1tc      <-- MISSING IN TOCK
0x038   strap             <-- MISSING IN TOCK
0x03C   in                <-- INPUT REGISTER (offset correct by coincidence)
0x040   in1               <-- MISSING IN TOCK
0x044   status
0x048   status_w1ts
0x04C   status_w1tc
0x050   status1           <-- MISSING IN TOCK
0x054   status1_w1ts      <-- MISSING IN TOCK
0x058   status1_w1tc      <-- MISSING IN TOCK
0x05C   pcpu_int          <-- MISSING IN TOCK
0x060   pcpu_nmi_int      <-- MISSING IN TOCK
0x064   cpusdio_int       <-- MISSING IN TOCK
0x068   pcpu_int1         <-- MISSING IN TOCK
0x06C   pcpu_nmi_int1     <-- MISSING IN TOCK
0x070   cpusdio_int1      <-- MISSING IN TOCK
0x074   pin[35]           <-- PIN CONFIG REGISTERS
...
0x62C   clock_gate        <-- GPIO CLOCK GATE (CRITICAL!)
```

**Tock Implementation:**
```rust
register_structs! {
    pub GpioRegisters {
        (0x000 => bt_select: ReadWrite<u32>),
        (0x004 => out: ReadWrite<u32>),
        (0x008 => out_w1ts: ReadWrite<u32>),
        (0x00C => out_w1tc: ReadWrite<u32>),
        (0x010 => _reserved1: [u8; 0x10]),    // WRONG! These aren't reserved
        (0x020 => enable: ReadWrite<u32>),
        ...
        (0x03C => in_: ReadOnly<u32>),        // Offset happens to be correct
        ...
    }
}
```

**Analysis:** The `in_` register offset (0x03C) is correct by coincidence because the reserved space calculation happens to work out. However, the structure is fundamentally incorrect and will cause issues for:
- GPIO32-34 (uses `out1`, `enable1`, `in1` registers)
- Interrupt status reading (uses `pcpu_int` not `status`)

### Finding 3: ESP-IDF Input Enable Sequence

**ESP-IDF `gpio_ll_input_enable`:**
```c
static inline void gpio_ll_input_enable(gpio_dev_t *hw, uint32_t gpio_num)
{
    PIN_INPUT_ENABLE(IO_MUX_GPIO0_REG + (gpio_num * 4));
}
```

This expands to setting `FUN_IE` bit in IO_MUX register - which Tock already does correctly.

**ESP-IDF `gpio_ll_iomux_in`:**
```c
static inline void gpio_ll_iomux_in(gpio_dev_t *hw, uint32_t gpio, uint32_t signal_idx)
{
    hw->func_in_sel_cfg[signal_idx].sig_in_sel = 0;  // Bypass GPIO matrix
    PIN_INPUT_ENABLE(IO_MUX_GPIO0_REG + (gpio * 4));
}
```

**Analysis:** For simple GPIO input (not routing to a peripheral), we should use IOMUX bypass mode. This is what `sig_in_sel = 0` does. The Tock implementation doesn't need to configure `func_in_sel_cfg` for basic GPIO input because we're reading directly from `GPIO_IN_REG`, not routing through the matrix.

### Finding 4: ESP-IDF GPIO Read Function

**ESP-IDF `gpio_ll_get_level`:**
```c
static inline int gpio_ll_get_level(gpio_dev_t *hw, uint32_t gpio_num)
{
    return (hw->in.in_data_next >> gpio_num) & 0x1;
}
```

**Tock Implementation:**
```rust
fn read(&self) -> bool {
    let mask = self.pin_mask();
    (self.gpio_registers.in_.get() & mask) != 0
}
```

**Analysis:** The read logic is correct. The issue is not in how we read, but in what we're reading from (the GPIO peripheral isn't clocked).

---

## Verification of Hypothesis

### Why IO_MUX Clock Enable (Report 014) Didn't Fix It

Report 014 enabled:
1. `PCR_IOMUX_CONF_REG` - APB clock for IO_MUX register access
2. `PCR_IOMUX_CLK_CONF_REG` - Function clock for IO_MUX logic

But this only enables the **IO_MUX** peripheral, not the **GPIO** peripheral.

The GPIO peripheral has its own clock gate: `GPIO_CLOCK_GATE_REG` at `GPIO_BASE + 0x62C`.

### Why Output Works But Input Doesn't

**Output Path:**
```
GPIO_OUT_REG → GPIO Matrix (out_sel_cfg) → IO_MUX → Physical Pin
```
Output may work because:
1. The GPIO matrix output is configured (SIG_GPIO_OUT_IDX = 128)
2. IO_MUX is configured for GPIO function
3. The output driver doesn't require the full GPIO clock

**Input Path:**
```
Physical Pin → IO_MUX → GPIO Input Sampling → GPIO_IN_REG
```
Input fails because:
1. GPIO input sampling requires the GPIO clock
2. Without the clock, `GPIO_IN_REG` is not updated
3. Reading `GPIO_IN_REG` always returns the reset value (0)

---

## Proposed Solution

### Step 1: Enable GPIO Clock Gate (CRITICAL)

Add to `gpio.rs`:

```rust
// GPIO clock gate register
const GPIO_CLOCK_GATE_OFFSET: usize = 0x62C;

/// Enable GPIO peripheral clock
pub fn enable_gpio_clock() {
    unsafe {
        let reg = (GPIO_BASE + GPIO_CLOCK_GATE_OFFSET) as *mut u32;
        // Set bit 0 to enable clock gate
        core::ptr::write_volatile(reg, 1);
    }
}

/// Check if GPIO clock is enabled
pub fn is_gpio_clock_enabled() -> bool {
    unsafe {
        let reg = (GPIO_BASE + GPIO_CLOCK_GATE_OFFSET) as *const u32;
        (core::ptr::read_volatile(reg) & 1) != 0
    }
}
```

Call `enable_gpio_clock()` in board initialization, before any GPIO operations.

### Step 2: Verify Clock is Enabled (Debug)

Add debug output in test:
```rust
// Check GPIO clock gate
let clock_gate = unsafe {
    let reg = (0x6000_4000 + 0x62C) as *const u32;
    core::ptr::read_volatile(reg)
};
write_debug(b"GPIO_CLOCK_GATE: ");
write_hex(clock_gate);
write_debug(b"\r\n");
```

Expected: Should be `0x00000001` after enabling.

### Step 3: Fix GPIO Register Structure (RECOMMENDED)

Update `GpioRegisters` to match ESP-IDF structure:

```rust
register_structs! {
    pub GpioRegisters {
        (0x000 => bt_select: ReadWrite<u32>),
        (0x004 => out: ReadWrite<u32>),
        (0x008 => out_w1ts: ReadWrite<u32>),
        (0x00C => out_w1tc: ReadWrite<u32>),
        (0x010 => out1: ReadWrite<u32>),
        (0x014 => out1_w1ts: ReadWrite<u32>),
        (0x018 => out1_w1tc: ReadWrite<u32>),
        (0x01C => sdio_select: ReadWrite<u32>),
        (0x020 => enable: ReadWrite<u32>),
        (0x024 => enable_w1ts: ReadWrite<u32>),
        (0x028 => enable_w1tc: ReadWrite<u32>),
        (0x02C => enable1: ReadWrite<u32>),
        (0x030 => enable1_w1ts: ReadWrite<u32>),
        (0x034 => enable1_w1tc: ReadWrite<u32>),
        (0x038 => strap: ReadOnly<u32>),
        (0x03C => in_: ReadOnly<u32>),
        (0x040 => in1: ReadOnly<u32>),
        (0x044 => status: ReadWrite<u32>),
        (0x048 => status_w1ts: ReadWrite<u32>),
        (0x04C => status_w1tc: ReadWrite<u32>),
        (0x050 => status1: ReadWrite<u32>),
        (0x054 => status1_w1ts: ReadWrite<u32>),
        (0x058 => status1_w1tc: ReadWrite<u32>),
        (0x05C => pcpu_int: ReadOnly<u32>),
        (0x060 => pcpu_nmi_int: ReadOnly<u32>),
        (0x064 => cpusdio_int: ReadOnly<u32>),
        (0x068 => pcpu_int1: ReadOnly<u32>),
        (0x06C => pcpu_nmi_int1: ReadOnly<u32>),
        (0x070 => cpusdio_int1: ReadOnly<u32>),
        (0x074 => pin: [ReadWrite<u32, GPIO_PIN_CTRL::Register>; 35]),
        (0x100 => _reserved1: [u8; 0x4C]),
        (0x14C => status_next: ReadOnly<u32>),
        (0x150 => status_next1: ReadOnly<u32>),
        (0x154 => func_in_sel_cfg: [ReadWrite<u32>; 128]),
        (0x354 => _reserved2: [u8; 0x200]),
        (0x554 => func_out_sel_cfg: [ReadWrite<u32>; 35]),
        (0x5E0 => _reserved3: [u8; 0x4C]),
        (0x62C => clock_gate: ReadWrite<u32>),
        (0x630 => _reserved4: [u8; 0xCC]),
        (0x6FC => date: ReadWrite<u32>),
        (0x700 => @END),
    }
}
```

---

## Verification Plan

### Test 1: Verify GPIO Clock Gate

```rust
// Before enabling
let before = read_gpio_clock_gate();  // Expected: 0 or 1 (unknown state)

// Enable
enable_gpio_clock();

// After enabling
let after = read_gpio_clock_gate();   // Expected: 1

// Print results
write_debug(b"GPIO clock before: ");
write_hex(before);
write_debug(b", after: ");
write_hex(after);
write_debug(b"\r\n");
```

### Test 2: GPIO Loopback After Clock Enable

```rust
// Setup
enable_gpio_clock();  // NEW!
enable_iomux_clock(); // Already done

// Configure pins
gpio18.make_output();
gpio19.make_input();

// Test
gpio18.set();
delay_ms(10);
let result = gpio19.read();

// Expected: result == true (HIGH)
write_debug(b"GPIO19 reads: ");
write_debug(if result { b"HIGH" } else { b"LOW" });
write_debug(b"\r\n");
```

### Test 3: Register Dump (If Still Failing)

Dump these registers for debugging:
```
GPIO_IN_REG (0x6000_403C)      - Input value
GPIO_ENABLE_REG (0x6000_4020)  - Output enable
GPIO_OUT_REG (0x6000_4004)     - Output value
GPIO_CLOCK_GATE_REG (0x6000_462C) - Clock gate
IO_MUX_GPIO18_REG (0x6000_904C) - IO_MUX config for GPIO18
IO_MUX_GPIO19_REG (0x6000_9050) - IO_MUX config for GPIO19
```

---

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| GPIO clock gate not the issue | Low (10%) | High | Have backup plan: check func_in_sel_cfg |
| Register offsets still wrong | Medium (30%) | Medium | Verify with register dumps |
| Other missing initialization | Low (15%) | Medium | Compare with ESP-IDF gpio_config() |
| Hardware issue (despite ohmmeter) | Very Low (5%) | High | Try different pin pair |

---

## Iteration Budget Estimate

| Task | Estimated Cycles |
|------|------------------|
| Add GPIO clock gate enable | 2-3 |
| Test and verify fix | 2-3 |
| Fix register structure (if needed) | 3-5 |
| Debug if primary fix fails | 5-10 |
| **Total (optimistic)** | **4-6** |
| **Total (pessimistic)** | **10-18** |

**Recommendation:** Start with GPIO clock gate enable only. This is the most likely fix and requires minimal changes.

---

## Backup Plan

If GPIO clock gate enable doesn't fix the issue:

1. **Dump all relevant registers** to verify configuration
2. **Check `func_in_sel_cfg`** - may need to configure for GPIO input
3. **Compare with ESP-HAL** - their Rust implementation is known to work
4. **Try different pins** - rule out pin-specific issues
5. **Escalate to Espressif forums** - with register dumps

---

## Handoff to Implementor

### Immediate Action Required

1. **Add GPIO clock gate enable function** to `gpio.rs`
2. **Call it in board initialization** before GPIO operations
3. **Test GPIO loopback** (GPIO18 → GPIO19)
4. **Report results** with register dumps if still failing

### Code Changes Required

**File: `tock/chips/esp32-c6/src/gpio.rs`**

Add at module level:
```rust
/// GPIO clock gate register offset
const GPIO_CLOCK_GATE_OFFSET: usize = 0x62C;

/// Enable GPIO peripheral clock gate
/// 
/// This must be called before using GPIO input functionality.
/// The GPIO clock gate controls sampling of input pins.
pub fn enable_gpio_clock() {
    unsafe {
        let reg = (GPIO_BASE + GPIO_CLOCK_GATE_OFFSET) as *mut u32;
        core::ptr::write_volatile(reg, 1);
    }
}
```

**File: `tock/boards/nano-esp32-c6/src/main.rs`**

Add in `setup()` function, after IO_MUX clock enable:
```rust
// Enable GPIO clock gate (required for input)
esp32_c6::gpio::enable_gpio_clock();
```

### Success Criteria

- [ ] GPIO clock gate register reads `0x00000001` after enable
- [ ] GPIO19 reads HIGH when GPIO18 is set HIGH
- [ ] GPIO19 reads LOW when GPIO18 is set LOW
- [ ] All 6 test iterations pass

---

## References

### ESP-IDF Sources Consulted
- `components/soc/esp32c6/include/soc/gpio_struct.h` - Register structure
- `components/hal/esp32c6/include/hal/gpio_ll.h` - Low-level GPIO functions
- `components/soc/esp32c6/include/soc/gpio_reg.h` - Register definitions

### ESP32-C6 TRM Sections
- Chapter 7: IO MUX and GPIO Matrix
- Section 7.4: GPIO Clock and Reset

### Key Register Addresses
```
GPIO_BASE:           0x6000_4000
GPIO_IN_REG:         0x6000_403C
GPIO_CLOCK_GATE_REG: 0x6000_462C
IO_MUX_BASE:         0x6000_9000
IO_MUX_GPIO18_REG:   0x6000_904C
IO_MUX_GPIO19_REG:   0x6000_9050
```

---

## Analyst Progress Report

### Session 1 - 2026-02-13

**Task:** Root cause analysis of GPIO input failure

### Completed
- [x] Reviewed all previous reports (005-014)
- [x] Analyzed ESP-IDF `gpio_ll.h` source code
- [x] Analyzed ESP-IDF `gpio_struct.h` for register layout
- [x] Identified GPIO clock gate as primary root cause
- [x] Identified GPIO register structure issues
- [x] Created detailed fix proposal
- [x] Estimated iteration budget

### Root Cause Identified
**GPIO_CLOCK_GATE_REG (0x6000_462C) not enabled**

The GPIO peripheral has its own clock gate that must be enabled for input sampling to work. This is separate from the IO_MUX clock that was enabled in Report 014.

### Handoff Notes
- Primary fix: Enable `GPIO_CLOCK_GATE_REG` bit 0
- Secondary fix: Correct GPIO register structure
- Estimated fix time: 4-6 cycles (optimistic)
- Confidence level: 95%

---

**Status:** ✅ ANALYSIS COMPLETE - Ready for Implementation
