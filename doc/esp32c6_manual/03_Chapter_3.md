---
chapter: 3
title: "Chapter 3"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 3

## Low-Power CPU

The ESP32-C6 Low-Power CPU (LP CPU) is a 32-bit processor based upon RISC-V ISA comprising integer (I), multiplication/division (M), atomic (A), and compressed (C) standard extensions. It features ultra-low power consumption and has a 2-stage, in-order, and scalar pipeline. The LP CPU core complex has an interrupt controller (INTC), a debug module (DM), and system bus (SYS BUS) interfaces for memory and peripheral access.

The LP CPU is in sleep mode by default (see Section 3.9). It can stay powered on when the chip enters Deep-sleep mode (see Chapter 12 Low-Power Management for details) and can access most peripherals and memories (see Chapter 5 System and Memory for details). It has two application scenarios:

- Power insensitive scenario: When the High-Performance CPU (HP CPU) is active, the LP CPU can assist the HP CPU with some speed- and efficiency-insensitive controls and computations.
- Power sensitive scenario: When the HP CPU is in the power-down state to save power, the LP CPU can be woken up to handle some external wake-up events.

Figure 3.0-1. LP CPU Overview

![Image](images/03_Chapter_3_img001_87cd9376.png)

## 3.1 Features

The LP CPU has the following features:

- Operating clock frequency up to 20 MHz
- 1 vector interrupts
- Debug module compliant with RISC-V External Debug Support Version 0.13 with external debugger support over an industry-standard JTAG/USB port
- Hardware trigger compliant with RISC-V External Debug Support Version 0.13 with up to 2 breakpoints/watchpoints

![Image](images/03_Chapter_3_img002_63e67a3b.png)

- 32-bit AHB system bus for peripheral and memory access
- Core performance metric events
- Able to wake up the HP CPU and send an interrupt to it
- Access to HP memory and LP memory
- Access to the entire peripheral address space

## 3.2 Configuration and Status Registers (CSRs)

## 3.2.1 Register Summary

Below is a list of CSRs available to the CPU. Except for the custom performance counter CSRs, all the implemented CSRs follow the standard mapping of bit fields as described in the RISC-V Instruction Set Manual, Volume II: Privileged Architecture, Version 1.10. It must be noted that even among the standard CSRs, not all bit fields have been implemented, limited by the subset of features implemented in the CPU. Refer to the next section for a detailed description of the subset of fields implemented under each of these CSRs.

| Name                                         | Description                                  | Address                                      | Access                                       |
|----------------------------------------------|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| Machine Information CSR                      | Machine Information CSR                      | Machine Information CSR                      | Machine Information CSR                      |
| mhartid                                      | Machine Hart ID                              | 0xF14                                        | RO                                           |
| Machine Trap Setup CSRs                      | Machine Trap Setup CSRs                      | Machine Trap Setup CSRs                      | Machine Trap Setup CSRs                      |
| mstatus                                      | Machine Mode Status                          | 0x300                                        | R/W                                          |
| misa  ¹                                      | Machine ISA                                  | 0x301                                        | R/W                                          |
| mie                                          | Machine Interrupt Enable                     | 0x304                                        | R/W                                          |
| mtvec  ²                                     | Machine Trap Vector                          | 0x305                                        | R/W                                          |
| Machine Trap Handling CSRs                   | Machine Trap Handling CSRs                   | Machine Trap Handling CSRs                   | Machine Trap Handling CSRs                   |
| mscratch                                     | Machine Scratch                              | 0x340                                        | R/W                                          |
| mepc                                         | Machine Trap Program Counter                 | 0x341                                        | R/W                                          |
| mcause  ³                                    | Machine Trap Cause                           | 0x342                                        | R/W                                          |
| mtval                                        | Machine Trap Value                           | 0x343                                        | R/W                                          |
| mip                                          | Machine Interrupt Pending                    | 0x344                                        | R/W                                          |
| Trigger Module CSRs (shared with Debug Mode) | Trigger Module CSRs (shared with Debug Mode) | Trigger Module CSRs (shared with Debug Mode) | Trigger Module CSRs (shared with Debug Mode) |
| tselect                                      | Trigger Select Register                      | 0x7A0                                        | R/W                                          |
| tdata1                                       | Trigger Abstract Data 1                      | 0x7A1                                        | R/W                                          |
| tdata2                                       | Trigger Abstract Data 2                      | 0x7A2                                        | R/W                                          |
| Debug Mode CSRs                              | Debug Mode CSRs                              | Debug Mode CSRs                              | Debug Mode CSRs                              |
| dcsr                                         | Debug Control and Status                     | 0x7B0                                        | R/W                                          |
| dpc                                          | Debug PC                                     | 0x7B1                                        | R/W                                          |
| dscratch0                                    | Debug Scratch Register 0                     | 0x7B2                                        | R/W                                          |
| dscratch1                                    | Debug Scratch Register 1                     | 0x7B3                                        | R/W                                          |

| Name                      | Description                                | Address                   | Access                    |
|---------------------------|--------------------------------------------|---------------------------|---------------------------|
| mcycle                    | Machine Clock Cycle Counter                | 0xB00                     | R/W                       |
| minstret                  | Machine Retired Instruction Counter        | 0xB02                     | R/W                       |
| mhpmcountern(n:3-12)      | Machine Performance Monitor Counter        | 0xB00+n                   | R/W                       |
| mcycleh                   | The higher 32 bits of mcycle               | 0xB80                     | R/W                       |
| minstreth                 | The higher 32 bits of minstret             | 0xB82                     | R/W                       |
| mhpmcounternh(n:3-12)     | The higher 32 bits of mhpmcountern(n:3-12) | 0xB80+n                   | R/W                       |
| Machine Counter Setup CSR | Machine Counter Setup CSR                  | Machine Counter Setup CSR | Machine Counter Setup CSR |
| mcountinhibit             | Machine Counter Control                    | 0x320                     | R/W                       |

Note that if write, set, or clear operation is attempted on any of the read-only (RO) CSRs indicated in the above table, the CPU will generate an illegal instruction exception.

## 3.2.2 Registers

Register 3.1. mhartid (0xF14)

![Image](images/03_Chapter_3_img003_b6f7c304.png)

Register 3.2. mstatus (0x300)

![Image](images/03_Chapter_3_img004_8bf5317e.png)

- MIE Write 1 to enable the global machine mode interrupt. (R/W)

MPIE Write 1 to enable the machine previous interrupt (before trap). (R/W)

MPP Configures machine previous privilege mode (before trap).

0x3: Machine mode

Other values: Invalid

Note: Only the lower bit is writable. Any write to the higher bit is ignored as it is directly tied to the lower bit.

(R/W)

- TW Configures whether to cause illegal instruction exception when WFI (Wait-for-Interrupt) instruction is executed in User mode.
- 0: Not cause illegal exception in User mode
- 1: Cause illegal instruction exception

(R/W)

Register 3.3. misa (0x301)

![Image](images/03_Chapter_3_img005_6cf2c67f.png)

- MXL Machine XLEN = 1 (32-bit). (RO)
- Z Reserved = 0. (RO)
- Y Reserved = 0. (RO)
- X Non-standard extensions present = 0. (RO)
- W Reserved = 0. (RO)
- V Reserved = 0. (RO)
- U User mode implemented = 0. (RO)
- T Reserved = 0. (RO)
- S Supervisor mode implemented = 0. (RO)
- R Reserved = 0. (RO)
- Q Quad-precision floating-point extension = 0. (RO)
- P Reserved = 0. (RO)
- O Reserved = 0. (RO)
- N User-level interrupts supported = 0. (RO)
- M Integer Multiply/Divide extension = 1. (RO)
- L Reserved = 0. (RO)
- K Reserved = 0. (RO)
- J Reserved = 0. (RO)
- I RV32I base ISA = 1. (RO)
- H Hypervisor extension = 0. (RO)
- G Additional standard extensions present = 0. (RO)
- F Single-precision floating-point extension = 0. (RO)
- E RV32E base ISA = 0. (RO)
- D Double-precision floating-point extension = 0. (RO)
- C Compressed Extension = 1. (RO)
- B Reserved = 0. (RO)
- A Atomic Standard Extension = 1. (RO)

## Register 3.4. mie (0x304)

![Image](images/03_Chapter_3_img006_93fc1383.png)

IE Write 1 to enable the interrupt. (R/W)

Register 3.5. mtvec (0x305)

![Image](images/03_Chapter_3_img007_11280a60.png)

MODE Represents whether machine mode interrupts are vectored. Only vectored mode 0x1 is available. (RO)

BASE Configures the higher 24 bits of trap vector base address aligned to 256 bytes. (R/W)

Register 3.6. mscratch (0x340)

![Image](images/03_Chapter_3_img008_81ba3acb.png)

MSCRATCH Contains machine scratch information for custom use. (R/W)

## Register 3.7. mepc (0x341)

![Image](images/03_Chapter_3_img009_a88a5c27.png)

MEPC Configures the machine trap/exception program counter. This is automatically updated with address of the instruction which was about to be executed while CPU encountered the most recent trap. (R/W)

## Register 3.8. mcause (0x342)

![Image](images/03_Chapter_3_img010_b0934bfc.png)

Exception Code This field is automatically updated with unique ID of the most recent exception or interrupt due to which CPU entered trap. Possible exception IDs are:

- 0x2: Illegal instruction

0x3: Hardware breakpoint/watchpoint or EBREAK

- 0x6: Misaligned atomic instructions

Note: Exception ID 0x0 (instruction access misaligned) is not present because CPU always masks the lowest bit of the address during instruction fetch. (R/W)

Interrupt Flag This flag is automatically updated when CPU enters trap. If this is found to be set, it indicates that the latest trap occurred due to an interrupt. For exceptions it remains unset. (R/W)

## Register 3.9. mtval (0x343)

![Image](images/03_Chapter_3_img011_ec3c66a7.png)

![Image](images/03_Chapter_3_img012_a2cff1db.png)

- MTVAL Configures machine trap value. This is automatically updated with an exception dependent data which may be useful for handling that exception. Data is to be interpreted depending upon exception IDs:
- 0x1: Faulting virtual address of instruction
- 0x2: Faulting instruction opcode
- 0x5: Faulting data address of load operation
- 0x7: Faulting data address of store operation

Note: The value of this register is not valid for other exception IDs and interrupts.

(R/W)

## Register 3.10. mip (0x344)

![Image](images/03_Chapter_3_img013_0ba6dc66.png)

- IP Configures the pending status of the interrupt.
- 0: Not pending
- 1: Pending
- (R/W)

## Register 3.11. mcycle (0xB00)

![Image](images/03_Chapter_3_img014_5fba5c15.png)

MCYCLE Configures the lower 32 bits of the clock cycle counter. (R/W)

## Register 3.12. minstret (0xB02)

minstret

![Image](images/03_Chapter_3_img015_a817ad82.png)

MINSTRET Configures the lower 32 bits of the instruction counter. (R/W)

## Register 3.13. mhpmcountern(n: 3-12) (0xB00+n)

![Image](images/03_Chapter_3_img016_730efe2c.png)

MHPMCOUNTERn Configures the lower 32 bits of the performance counter n. (R/W)

![Image](images/03_Chapter_3_img017_66e9879c.png)

Register 3.17. mcouninhibit (0x320)

![Image](images/03_Chapter_3_img018_a14d6706.png)

|     | HPM IR            | (reserved)
 CY CY   |
|-----|-------------------|---------------------|
| 31  | 3 2               | 1 0                 |
| 0x0 | 0x0 0x0 0x0 Reset | 0x0 0x0 0x0 Reset   |

HPM Configures whether the performance counter n(n:3-12) increments.

- 0: The counter does not count
- 1: The counter increments (R/W)
- IR Configure whether the instruction counter increments.
- 0: The counter does not count
- 1: The counter increments (R/W)
- CY Configure whether the clock cycle counter increments.
- 0: The counter does not count
- 1: The counter increments (R/W)

## 3.3 Interrupts and Exceptions

The LP CPU handles interrupts and exceptions according to RISC-V Instruction Set Manual, Volume II: Privileged Architecture, Version 1.10. After entering an interrupt/exception handler, the CPU:

- Saves the current program counter (PC) value to the mepc CSR
- Copies the state of MIE of mstatus to MPIE of mstatus
- Saves the current privileged mode to MPP of mstatus
- Clears MIE of mstatus
- Toggles the privileged mode to machine mode (M mode)
- Jumps to the handler address
- – For exceptions, the handler address is the base address of the vector table in the mtvec CSR.
- – For interrupts, the handler address is mtvec + 4 ∗ 30 .

After the mret instruction is executed, the core jumps to the PC saved in the mepc CSR and restores the value of MPIE of mstatus to MIE of mstatus .

When the core starts up, the base address of the vector table is initialized to the boot address 0x50000000. After startup, the base address can be changed by writing to the mtvec CSR. For more information about CSRs, see Section 3.2.1 .

The core fetches instructions from address 0x50000080 after reset.

## 3.3.1 Interrupts

The ESP32-C6 LP CPU supports only one interrupt entry, to which all interrupt events jump. The LP CPU supports the following peripheral interrupt sources:

- Power Management Unit (PMU)
- Low-Power Timer (RTC\_TIMER)
- Low-Power UART (LP\_UART)
- Low-Power I2C (LP\_I2C)
- Low-Power IO MUX (LP IO MUX)

For more information on those peripheral interrupts, please refer to the corresponding chapter.

## 3.3.2 Interrupt Handling

By default, interrupts are disabled globally because the MIE bit in mstatus has a reset value of 0. Software must set this bit to enable global interrupts.

1. Enable interrupts
- To enable interrupts globally, set the MIE bit of mstatus .
- To enable Interrupt 30, set the 30th bit of mie CSR.
2. After interrupts are enabled, the LP CPU can respond to interrupts. It also needs to configure interrupts of the peripherals so that they can send an interrupt signal to the LP CPU.
3. After the interrupt is triggered, the LP CPU jumps to mtvec + 4 ∗ 30 .
4. After enterring the interrupt handler, users need to read LPPERI\_INTERRUPT\_SOURCE\_REG to get the peripheral that triggered the interrupt and process the interrupt. Note that if the interrupts are triggered by multiple peripherals, the CPU will process them one by one in sequence until none is left. If not all interrupts are processed, the CPU will enter the interrupt handler again.
5. To clear interrupts, just clear the interrupt signal of the peripheral.

## 3.3.3 Exceptions

The LP CPU supports the RISC-V standard exceptions and can trigger the following exceptions:

Table 3.3-1. LP CPU Exception Causes

|   Exception ID | Description                    |
|----------------|--------------------------------|
|              2 | Illegal instructions           |
|              3 | Breakpoints (EBREAK)           |
|              6 | Misaligned atomic instructions |

## 3.4 Debugging

This section describes how to debug and test the LP CPU. Debug support is provided through standard JTAG pins and complies with RISC-V External Debug Support Version 0.13.

For ESP32-C6 system debugging overview, please refer to Section 1.10 Debug &gt; Figure 1.10-1 .

The user interacts with the Debug Host (e.g. laptop), which is running a debugger (e.g., gdb). The debugger communicates with a Debug Translator (e.g. OpenOCD, which may include a hardware driver) to communicate with Debug Transport Hardware (e.g. ESP-Prog adapter). The Debug Transport Hardware connects the Debug Host to the CPU's Debug Transport Module (DTM) through a standard JTAG interface. The DTM provides access to the debug module (DM) using the Debug Module Interface (DMI).

DM supports multi-core debugging in compliance with the specification RISC-V External Debug Support Version 0.13, and can control the HP CPU and the LP CPU simultaneously. Hart 1 represents the LP CPU. Users can use OpenOCD to select a hart (0: HP CPU, 1: LP CPU) for debugging.

The LP CPU implements four registers for core debugging: dcsr , dpc , dscratch0, and dscratch1. All of those registers can only be accessed from debug mode. If software attempts to access them when the LP CPU is not in debug mode, an illegal instruction exception will be triggered.

## 3.4.1 Features

The Low-Power CPU has the following debugging features:

- Provides necessary information about the implementation to the debugger.
- Allows the CPU core to be halted and resumed.
- CPU core registers (including CSRs) can be read/written by the debugger.
- CPU core can be reset through the debugger.
- CPU can be halted on software breakpoint (planted breakpoint instruction).
- Hardware single-stepping.
- Two hardware triggers (which can be used as breakpoints/watchpoints). See Section 3.5 for details.

## 3.4.2 Functional Description

The debugging mechanism adheres to the specification RISC-V External Debug Support Version 0.13. For a detailed description of the debugging features, refer to the specification.

According to the specification, a hart can be in the following states: nonexistent, unavail, running, and halted. By default, the LP CPU is in the unavail state. To connect the LP CPU for debugging, users need to clear the state by configuring the LPPERI\_CPU\_REG register.

## 3.4.3 Register Summary

The following table lists the debug CSRs supported for the LP CPU.

| Name      | Description              | Address   | Access   |
|-----------|--------------------------|-----------|----------|
| dcsr      | Debug Control and Status | 0x7B0     | R/W      |
| dpc       | Debug PC                 | 0x7B1     | R/W      |
| dscratch0 | Debug Scratch Register 0 | 0x7B2     | R/W      |
| dscratch1 | Debug Scratch Register 1 | 0x7B3     | R/W      |

All debug module registers are implemented in accordance with the specification RISC-V External Debug Support Version 0.13. For more information, refer to the specification.

## 3.4.4 Registers

The following is a detailed description of the debug CSR supported by the LP CPU.

## Register 3.18. dcsr (0x7B0)

![Image](images/03_Chapter_3_img019_99ce2fe6.png)

xdebugver Represents the debug version.

- 4: External debug support exists

(RO)

ebreakm Configures execution of the EBREAK instruction in machine mode.

0: Trigger an exception with mcause = 3

- 1: Enter debug mode

(R/W)

ebreaku Configures execution of the EBREAK instruction in user mode.

- 0: Trigger an exception with mcause = 3 as described in privileged mode

1: Enter debug mode

(R/W)

- cause Represents the reason why debug mode was entered. When there are multiple reasons to enter debug mode in a single cycle, the cause with the highest priority number is the one written.
- 1: An EBREAK instruction was executed. (priority 3)
- 2: The Trigger Module caused a halt. (priority 4)
- 3: haltreq was set. (priority 2)
- 4: The CPU core single stepped because step was set. (priority 1)

Other values: reserved for future use

(RO)

- step When set and not in Debug Mode, the core will only execute a single instruction and then enter Debug Mode.

If the instruction does not complete due to an exception, the core will immediately enter Debug Mode before executing the trap handler, with appropriate exception registers set.

Setting this bit does not mask interrupts. This is a deviation from the RISC-V External Debug Support Specification Version 0.13.

(R/W)

- prv Contains the privilege level the core is operating in when debug mode is entered. A debugger can change this value to change the core's privilege level when exiting debug mode. Only 0x3 (machine mode) and 0x0 (user mode) are supported. (RO)

## Register 3.19. dpc (0x7B1)

![Image](images/03_Chapter_3_img020_96df0d5b.png)

![Image](images/03_Chapter_3_img021_50944278.png)

## 3.5 Hardware Trigger

## 3.5.1 Features

Hardware Trigger module provides breakpoint and watchpoint capability for debugging. It has the following features:

- Two independent trigger units
- Configurable unit to match the address of the program counter
- Able to halt execution and transfer control to the debugger

## 3.5.2 Functional Description

The hardware trigger module provides three CSRs. See Section 3.5 for details. Among these, tdata1 and tdata2 are abstract CSRs, which means they are shadow registers for accessing internal registers in the trigger units, one at a time.

To select a specific trigger unit, the corresponding number (0-1) needs to be written to the tselect CSR. When a valid value is written, the abstract CSRs, tdata1 and tdata2, automatically match the internal registers of the trigger unit. Each trigger unit has two internal registers, namely mcontrol and maddress, which are mapped to tdata1 and tdata2, respectively.

Writing a value more than 1 to tselect will set tselect to 1.

Since software or debugger may need to know the type of the selected trigger to correctly interpret tdata1 and tdata2, the 4-bit field (31-28) of tdata1 encodes the type of the selected trigger. This type field is read-only and always provides a value of 0x2 for every trigger, which stands for support for address and data matching. Hence, it is inferred that tdata1 and tdata2 are to be interpreted as fields of mcontrol and maddress , respectively. The specification RISC-V External Debug Support Version 0.13 provides information on other possible values, but the trigger module only supports the 0x2 type.

Once a trigger unit has been chosen by writing its index to tselect, it will become possible to configure it by setting the appropriate bits in mcontrol CSR (tdata1) and writing the target address to maddress CSR (tdata2).

## 3.5.3 Trigger Execution Flow

When a hart is halted and enters debug mode due to the firing of a trigger (action = 1):

- dpc is set to the current PC in the decoding phase
- The cause field in dcsr is set to 2, which means halt due to trigger

## 3.5.4 Register Summary

Below is a list of Trigger Module CSRs supported by the CPU. These are only accessible from machine mode.

| Name     | Description             | Address   | Access   |
|----------|-------------------------|-----------|----------|
| tselect  | Trigger Select Register | 0x7A0     | R/W      |
| tdata1   | Trigger Abstract Data 1 | 0x7A1     | R/W      |
| mcontrol | tdata1 Shadow Register  | 0x7A1     | R/W      |
| tdata2   | Trigger Abstract Data 2 | 0x7A2     | R/W      |

## 3.5.5 Registers

Register 3.22. tselect (0x7A0)

![Image](images/03_Chapter_3_img022_cfa78f94.png)

![Image](images/03_Chapter_3_img023_52a074d7.png)

tselect Configures the index of the selected trigger unit. (R/W)

![Image](images/03_Chapter_3_img024_4ed637b6.png)

Register 3.23. tdata1 (0x7A1)

![Image](images/03_Chapter_3_img025_b23c5cf1.png)

| type   |           |   dmode | data   |    |         |
|--------|-----------|---------|--------|----|---------|
| 31     | 28 27     |      26 |        |    | 0       |
|        | 0 0 1 0 1 |       0 |        | 4  | 0 Reset |

- type Represents the trigger type. This field is reserved since only match type (0x2) triggers are supported. (RO)
- dmode This is set to 1 if a trigger is being used by the debugger. This field is reserved since it is only supported in debug mode. (RO)
- data Configures the abstract tdata1 content. This will always be interpreted as fields of mcontrol since only match type (0x2) triggers are supported. (R/W)

Register 3.24. tdata2 (0x7A2)

![Image](images/03_Chapter_3_img026_a57ed9a9.png)

![Image](images/03_Chapter_3_img027_1e410145.png)

tdata2 Configures the abstract tdata2 content. This will always be interpreted as maddress since only match type (0x2) triggers are supported. (R/W)

Register 3.25. mcontrol (0x7A1)

![Image](images/03_Chapter_3_img028_a59d6955.png)

dmode Same as dmode in tdata1. (RO)

maskmax Represents the maximum NAPOT range.

0: A byte. Only exact match is supported.

Other values: Not supported.

(RO)

hit Not implemented in hardware. This field remains 0. (RO)

select Configures to select between an address match or a data match.

0: Perform a match on the virtual address

1: Perform a match on the data value loaded or stored, or the instruction executed

Note: Only address match is implemented. This field remains 0.

(RO)

timing Configures when the trigger will take action.

- 0: Take action before the instruction is executed

1: Take action after the instruction is executed

Note: The field remains 0.

(RO)

sizelo Only match of any size is supported. This field remains 0. (RO)

action Configure action of the selected trigger after it is triggered.

0x0: Cause a breakpoint exception

0x1: Enter debug mode (Valid only when dmode = 1)

Note: Only entering debug mode is supported. This field remains 1.

(RO)

CHAIN Not implemented in hardware. This field remains 0. (RO)

match Configures the trigger to perform the matching operation of the lower data/instruction address.

0x0: Exact match. Namely, the address corresponding to a certain byte during the access must exactly match the value of maddress .

0x1: NAPOT match. Namely, at least one byte during the access is in the NAPOT region specified in maddress .

Note: Only exact byte match is supported. This field remains 0. (R/W)

- m Set this field to make the selected trigger operate in machine mode. (RO)
- S Set this field to make the selected trigger operate in supervisor mode. Operation in supervisor mode is not supported. This field is always 0. (RO)

Continued on the next page...

## Register 3.25. mcontrol (0x7A1)

## Continued from the previous page...

- U Set this field to make the selected trigger operate in user mode. Operation in user mode is not supported. This field is always 0. (RO)
- execute Configures whether to enable the selected trigger to match the virtual address of instructions.
- 0: Not enable
- 1: Enable

(R/W)

- store Set this field to make the selected trigger match the virtual address of the memory write operation. Not supported by hardware. This field is always 0. (RO)
- load Set this field to make the selected trigger match the virtual address of a memory read operation. Not supported by hardware. This field is always 0. (RO)

## Register 3.26. maddress (0x7A2)

![Image](images/03_Chapter_3_img029_f6c52fa1.png)

maddress Configures the address used by the selected trigger when performing match operation. (R/W)

## 3.6 Performance Counter

The LP CPU implements a clock cycle counter mcycle(h), an instruction counter minstret(h), and 10 event counters mhpmcountern(n:3-12). The clock cycle counter and instruction counter are always available and each is 64-bit wide. Other performance counters are 40-bit wide each.

By default, all counters are enabled after reset. A counter can be enabled or disabled individually via the corresponding bit in the mcountinhibit CSR.

As shown in Table 3.6-1, each counter is dedicated to counting a particular event.

Table 3.6-1. Performance Counter

| Counter      | Counted Event                 |
|--------------|-------------------------------|
| mcycle       | Clock cycles                  |
| minstret     | The number of instructions    |
| mhpmcounter3 | Wait cycles for memory access |

| Counter       | Counted Event                                                                |
|---------------|------------------------------------------------------------------------------|
| mhpmcounter4  | Wait cycles for fetching instructions                                        |
| mhpmcounter5  | The number of memory read operations. An unaligned read is counted as two.   |
| mhpmcounter6  | The number of memory write operations. An unaligned write is counted as two. |
| mhpmcounter7  | The number of unconditional jump instructions (jal, jr, jalr)                |
| mhpmcounter8  | The number of branch instructions                                            |
| mhpmcounter9  | The number of taken branch instructions                                      |
| mhpmcounter10 | The number of compressed instructions                                        |
| mhpmcounter11 | Wait cycles for multiplication instructions                                  |
| mhpmcounter12 | Wait cycles for division instructions                                        |

## 3.7 System Access

## 3.7.1 Memory Access

The ESP32-C6 LP CPU can access LP SRAM and HP SRAM. For more information, please refer to Section 5 System and Memory .

- LP SRAM: 16 KB starting from 0x5000\_0000 to 0x5000\_3FFF, where you can fetch instructions, read data, write data, etc.
- HP SRAM: 512 KB starting from 0x4080\_0000 to 0x4087\_FFFF, where you can fetch instructions, read data, write data, etc.

## Note:

The LP CPU has a high latency to access the HP SRAM, but can access the LP SRAM with no latency.

The LP CPU supports the atomic instruction set. Both the LP CPU and the HP CPU can access memory through atomic instructions, thus achieving atomicity of memory access. For details on the atomic instruction set, please refer to RISC-V Instruction Set Manual Volume I: Unprivileged ISA, Version 2.2.

## 3.7.2 Peripheral Access

Table 5.3-2 in Chapter 5 System and Memory lists the peripherals accessible by the LP CPU and their base addresses.

## 3.8 Event Task Matrix Feature

The LP CPU on ESP32-C6 supports the Event Task Matrix (ETM) function, which allows LP CPU's ETM tasks to be triggered by any peripherals' ETM events, or LP CPU's ETM events to trigger any peripherals' ETM tasks. This section introduces the ETM tasks and events related to the LP CPU. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

LP CPU can receive the following ETM task:

- ULP\_TASK\_WAKEUP\_CPU: Wakes up the LP CPU.

LP CPU can generate the following ETM events:

- ULP\_EVT\_ERR\_INTR: Indicates that an LP CPU exception occurs.
- ULP\_EVT\_START\_INTR: Indicates that the LP CPU clock is turned on.

## 3.9 Sleep and Wake-Up Process

## 3.9.1 Features

- Able to sleep, wake up, and operate independently in the low-power system when the HP CPU is sleeping
- Able to actively configure registers to enter the sleep status based on software operating status
- Wake-up events:
- – The HP CPU setting the register PMU\_HP\_TRIGGER\_LP
- – The interrupt state of the LP IO
- – ETM events
- – The RTC timer timeout
- – The LP UART receiving a certain number of RX pulses when LPPERI\_LP\_UART\_WAKEUP\_EN is enabled

## 3.9.2 Process

The LP CPU is in sleep by default and its wake-up module follows the process below to wake it up for work and make it sleep.

To configure wake-up sources, please refer to Table 3.9-1 .

![Image](images/03_Chapter_3_img030_e9116e55.png)

PMU\_LP\_CPU\_SLP\_STALL\_WAIT

Figure 3.9-1. Wake-Up and Sleep Flow of LP CPU

![Image](images/03_Chapter_3_img031_21d9a9c3.png)

The first startup of the LP CPU after power-up depends on the wake-up enable and wake-up source configuration by the HP CPU.

- Initialization of the LP CPU
- – Initialize the LP memory.
- – Start the LP CPU. Since the startup of the LP CPU depends on the wake-up process, it is recommended to use the PMU\_HP\_TRIGGER\_LP register to start the initialization of the LP CPU in the following way:
* Set PMU\_LP\_CPU\_WAKEUP\_EN to 0x1
* Set PMU\_HP\_TRIGGER\_LP to 0x1
* The LP CPU will go through the wake-up process to start running

## · Wake-up process:

- – The wake-up module receives a wake-up signal and sends a power-up request to the PMU.
- – If the current power consumption state (clock, power supply, etc.) meets the requirements of the LP CPU, the PMU will immediately reply with the completion signal. Otherwise, it will adjust the power consumption state before replying with the completion signal.
- – The wake-up module disables the STALL state of the LP CPU and enables interrupt receiving.
- – The wake-up module starts the clock, releases reset (ignore this step if reset is not enabled for sleep), and starts working.

## · Sleep process:

- – The LP CPU configures the register PMU\_LP\_CPU\_SLEEP\_REQ to enable the wake-up module to start the sleep process.
- – If PMU\_LP\_CPU\_SLP\_STALL\_EN is 1, the wake-up module enables the STALL state of the LP CPU. If it is 0, the module does not enable that state.
- – The wake-up module waits for PMU\_LP\_CPU\_SLP\_STALL\_WAIT LP CPU clock cycles, and then turns off the LP CPU clock. If PMU\_LP\_CPU\_SLP\_RESET\_EN is 1, the module enables reset of the LP CPU.

## 3.9.3 Wake-Up Sources

Table 3.9-1. Wake Sources

| Register Value  1   | Wake-Up Source             | Description                                                                                                                                                                                |
|---------------------|----------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x1                 | Register PMU_HP_TRIGGER_LP | The HP CPU sets the regis ter  PMU_HP_TRIGGER_LP  to wake up the LP CPU, and sets PMU_HP_SW_TRIGGER_INT_CLR  to clear this wake-up source.                                                |
| 0x2                 | LP UART                    | The LP UART receives a certain number of RX pulses. LPPERI_LP_UART_WAKEUP_EN needs to be enabled. For more information, please refer to Chapter 27 UART Controller (UART, LP_UART, UHCI) . |
| 0x4                 | LP IO                      | This wake-up source uses the LP IO interrupt status register signal. For more information, please refer to Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) .                               |
| 0x8                 | ETM                        | Wake-up sources received from ETM can wake up the LP CPU. For more information, please refer to Chapter 11 Event Task Matrix (SOC_ETM) .                                                   |
| 0x10                | RTC timer                  | RTC timer target 1 timeout interrupt control. For more information, please refer to Chapter 12 Low-Power Management .                                                                      |

## 3.10 Register Summary

The addresses in this section are relative to Low-Power Peripheral base address provided in Table 5.3-2 in Chapter 5 System and Memory .

| Name                        | Description                      | Address   | Access   |
|-----------------------------|----------------------------------|-----------|----------|
| LPPERI_CPU_REG              | LP CPU Control Register          | 0x000C    | R/W      |
| LPPERI_INTERRUPT_SOURCE_REG | LP CPU Interrupt Status Register | 0x0020    | RO       |

## 3.11 Registers

The addresses in this section are relative to Low-Power Peripheral base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 3.27. LPPERI\_CPU\_REG (0x000C)

![Image](images/03_Chapter_3_img032_a2e22f73.png)

## LPPERI\_LPCORE\_DBGM\_UNAVALIABLE Configures the LP CPU state.

0: LP CPU can connect to JTAG

1: LP CPU is unavailable and cannot connect to JTAG

(R/W)

Register 3.28. LPPERI\_INTERRUPT\_SOURCE\_REG (0x0020)

![Image](images/03_Chapter_3_img033_3223c2a5.png)

## LPPERI\_LP\_INTERRUPT\_SOURCE Represents the LP interrupt source.

Bit 5: PMU\_LP\_INT

Bit 4: Reserved

Bit 3: RTC\_Timer\_LP\_INT

Bit 2: LP\_UART\_INT

Bit 1: LP\_I2C\_INT

Bit 0: LP\_IO\_INT

(RO)
