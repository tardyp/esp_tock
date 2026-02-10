---
chapter: 1
title: "Chapter 1"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 1

IBUS

## ESP-RISC-V CPU

## 1.1 Overview

ESP-RISC-V CPU is a 32-bit core based upon RISC-V ISA comprising base integer (I), multiplication/division (M) and compressed (C) standard extensions. The core has 4-stage, in-order, scalar pipeline optimized for area, power and performance. CPU core complex has an interrupt-controller (INTC), debug module (DM) and system bus (SYS BUS) interfaces for memory and peripheral access.

1.2 Features interface

levels

Espressif Systems

## 1.2 Features

- Operating clock frequency up to 160 MHz
- Zero wait cycle access to on-chip SRAM and Cache for program and data access over IRAM/DRAM interface
- Interrupt controller (INTC) with up to 31 vectored interrupts with programmable priority and threshold levels

Figure 1.1-1. CPU Block Diagram

![Image](images/01_Chapter_1_img001_10db579e.png)

RV32IMC

CORE

SYS BUS

DBUS

SBA

INTC

DM

IRQ

→ JTAG

ESP32-C3 TRM (Version 1.3)

- Debug module (DM) compliant with RISC-V debug specification v0.13 with external debugger support over an industry-standard JTAG/USB port
- Debugger direct system bus access (SBA) to memory and peripherals
- Hardware trigger compliant to RISC-V debug specification v0.13 with up to 8 breakpoints/watchpoints
- Physical memory protection (PMP) for up to 16 configurable regions
- 32-bit AHB system bus for peripheral access
- Configurable events for core performance metrics

## 1.3 Address Map

Below table shows address map of various regions accessible by CPU for instruction, data, system bus peripheral and debug.

Table 1.3-1. CPU Address Map

| Name   | Description             | Starting Address   | Ending Address   | Access   |
|--------|-------------------------|--------------------|------------------|----------|
| IRAM   | Instruction Address Map | 0x4000_0000        | 0x47FF_FFFF      | R/W      |
| DRAM   | Data Address Map        | 0x3800_0000        | 0x3FFF_FFFF      | R/W      |
| DM     | Debug Address Map       | 0x2000_0000        | 0x27FF_FFFF      | R/W      |
| AHB    | AHB Address Map         | *default           | *default         | R/W      |

## 1.4 Configuration and Status Registers (CSRs)

## 1.4.1 Register Summary

Below is a list of CSRs available to the CPU. Except for the custom performance counter CSRs and the tcontrol register (which complies with the RISC-V External Debug Support Version 0.13.2), all the implemented CSRs follow the standard mapping of bit fields as described in the RISC-V Instruction Set Manual, Volume II: Privileged Architecture, Version 1.10. It must be noted that even among the standard CSRs, not all bit fields have been implemented, limited by the subset of features implemented in the CPU. Refer to the next section for detailed description of the subset of fields implemented under each of these CSRs.

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                     | Description               | Address                  | Access                   |
|--------------------------|---------------------------|--------------------------|--------------------------|
| Machine Information CSRs | Machine Information CSRs  | Machine Information CSRs | Machine Information CSRs |
| mvendorid                | Machine Vendor ID         | 0xF11                    | RO                       |
| marchid                  | Machine Architecture ID   | 0xF12                    | RO                       |
| mimpid                   | Machine Implementation ID | 0xF13                    | RO                       |
| mhartid                  | Machine Hart ID           | 0xF14                    | RO                       |
| Machine Trap Setup CSRs  | Machine Trap Setup CSRs   | Machine Trap Setup CSRs  | Machine Trap Setup CSRs  |

| Name                                         | Description                                  | Address                                      | Access                                       |
|----------------------------------------------|----------------------------------------------|----------------------------------------------|----------------------------------------------|
| mstatus                                      | Machine Mode Status                          | 0x300                                        | R/W                                          |
| misa  ¹                                      | Machine ISA                                  | 0x301                                        | R/W                                          |
| mtvec  ²                                     | Machine Trap Vector                          | 0x305                                        | R/W                                          |
| Machine Trap Handling CSRs                   | Machine Trap Handling CSRs                   | Machine Trap Handling CSRs                   | Machine Trap Handling CSRs                   |
| mscratch                                     | Machine Scratch                              | 0x340                                        | R/W                                          |
| mepc                                         | Machine Trap Program Counter                 | 0x341                                        | R/W                                          |
| mcause  ³                                    | Machine Trap Cause                           | 0x342                                        | R/W                                          |
| mtval                                        | Machine Trap Value                           | 0x343                                        | R/W                                          |
| Physical Memory Protection (PMP) CSRs        | Physical Memory Protection (PMP) CSRs        | Physical Memory Protection (PMP) CSRs        | Physical Memory Protection (PMP) CSRs        |
| pmpcfg0                                      | Physical memory protection configuration     | 0x3A0                                        | R/W                                          |
| pmpcfg1                                      | Physical memory protection configuration     | 0x3A1                                        | R/W                                          |
| pmpcfg2                                      | Physical memory protection configuration     | 0x3A2                                        | R/W                                          |
| pmpcfg3                                      | Physical memory protection configuration     | 0x3A3                                        | R/W                                          |
| pmpaddr0                                     | Physical memory protection address register  | 0x3B0                                        | R/W                                          |
| pmpaddr1                                     | Physical memory protection address register  | 0x3B1                                        | R/W                                          |
| ....                                         | ....                                         | ....                                         | ....                                         |
| pmpaddr15                                    | Physical memory protection address register  | 0x3BF                                        | R/W                                          |
| Trigger Module CSRs (shared with Debug Mode) | Trigger Module CSRs (shared with Debug Mode) | Trigger Module CSRs (shared with Debug Mode) | Trigger Module CSRs (shared with Debug Mode) |
| tselect                                      | Trigger Select Register                      | 0x7A0                                        | R/W                                          |
| tdata1                                       | Trigger Abstract Data 1                      | 0x7A1                                        | R/W                                          |
| tdata2                                       | Trigger Abstract Data 2                      | 0x7A2                                        | R/W                                          |
| tcontrol                                     | Global Trigger Control                       | 0x7A5                                        | R/W                                          |
| Debug Mode CSRs                              | Debug Mode CSRs                              | Debug Mode CSRs                              | Debug Mode CSRs                              |
| dcsr                                         | Debug Control and Status                     | 0x7B0                                        | R/W                                          |
| dpc                                          | Debug PC                                     | 0x7B1                                        | R/W                                          |
| dscratch0                                    | Debug Scratch Register 0                     | 0x7B2                                        | R/W                                          |
| dscratch1                                    | Debug Scratch Register 1                     | 0x7B3                                        | R/W                                          |
| Performance Counter CSRs (Custom)  ⁴         | Performance Counter CSRs (Custom)  ⁴         | Performance Counter CSRs (Custom)  ⁴         | Performance Counter CSRs (Custom)  ⁴         |
| mpcer                                        | Machine Performance Counter Event            | 0x7E0                                        | R/W                                          |
| mpcmr                                        | Machine Performance Counter Mode             | 0x7E1                                        | R/W                                          |
| mpccr                                        | Machine Performance Counter Count            | 0x7E2                                        | R/W                                          |
| GPIO Access CSRs (Custom)                    | GPIO Access CSRs (Custom)                    | GPIO Access CSRs (Custom)                    | GPIO Access CSRs (Custom)                    |
| cpu_gpio_oen                                 | GPIO Output Enable                           | 0x803                                        | R/W                                          |
| cpu_gpio_in                                  | GPIO Input Value                             | 0x804                                        | RO                                           |
| cpu_gpio_out                                 | GPIO Output Value                            | 0x805                                        | R/W                                          |

Note that if write/set/clear operation is attempted on any of the CSRs which are read-only (RO), as indicated in the above table, the CPU will generate illegal instruction exception.

¹ Although misa is specified as having both read and write access (R/W), its fields are hardwired and thus write has no effect. This is what would be termed WARL (Write Any Read Legal) in RISC-V terminology

² mtvec only provides configuration for trap handling in vectored mode with the base address aligned to 256 bytes

³ External interrupt IDs reflected in mcause include even those IDs which have been reserved by RISC-V standard for core internal sources.

⁴ These custom CSRs have been implemented in the address space reserved by RISC-V standard for custom use

## 1.4.2 Register Description

## Register 1.1. mvendorid (0xF11)

MVENDORID

0x00000612

31

0

Reset

MVENDORID Vendor ID. (RO)

## Register 1.2. marchid (0xF12)

MARCHID

0x80000001

31

0

Reset

MARCHID Architecture ID. (RO)

## Register 1.3. mimpid (0xF13)

MIMPID

0x00000001

31

0

Reset

MIMPID Implementation ID. (RO)

## Register 1.4. mhartid (0xF14)

MHARTID

0x00000000

31

0

Reset

MHARTID Hart ID. (RO)

![Image](images/01_Chapter_1_img002_5e1d26bc.png)

## Register 1.5. mstatus (0x300)

![Image](images/01_Chapter_1_img003_8bf5317e.png)

- MIE Global machine mode interrupt enable. (R/W)
- MPIE Machine previous interrupt enable (before trap). (R/W)
- MPP Machine previous privilege mode (before trap). (R/W) Possible values:
- 0x0: User mode
- 0x3: Machine mode

Note : Only lower bit is writable. Write to the higher bit is ignored as it is directly tied to the lower bit.

## TW Timeout wait. (R/W)

If this bit is set, executing WFI (Wait-for-Interrupt) instruction in User mode will cause illegal instruction exception.

## Register 1.6. misa (0x301)

![Image](images/01_Chapter_1_img004_f03d5a43.png)

- MXL Machine XLEN = 1 (32-bit). (RO)
- Z Reserved = 0. (RO)
- Y Reserved = 0. (RO)
- X Non-standard extensions present = 0. (RO)
- W Reserved = 0. (RO)
- V Reserved = 0. (RO)
- U User mode implemented = 1. (RO)
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
- A Atomic Extension = 0. (RO)

## Register 1.7. mtvec (0x305)

![Image](images/01_Chapter_1_img005_55272f57.png)

MODE Only vectored mode 0x1 is available. (RO)

BASE Higher 24 bits of trap vector base address aligned to 256 bytes. (R/W)

## Register 1.8. mscratch (0x340)

![Image](images/01_Chapter_1_img006_25c630fe.png)

MSCRATCH Machine scratch register for custom use. (R/W)

## Register 1.9. mepc (0x341)

![Image](images/01_Chapter_1_img007_bf711025.png)

MEPC Machine trap/exception program counter. (R/W)

This is automatically updated with address of the instruction which was about to be executed while CPU encountered the most recent trap.

## Register 1.10. mcause (0x342)

![Image](images/01_Chapter_1_img008_3c13a820.png)

Exception Code This field is automatically updated with unique ID of the most recent exception or interrupt due to which CPU entered trap. (R/W)

Possible exception IDs are:

- 0x1: PMP Instruction access fault
- 0x2: Illegal Instruction
- 0x3: Hardware Breakpoint/Watchpoint or EBREAK
- 0x5: PMP Load access fault
- 0x7: PMP Store access fault
- 0x8: ECALL from U mode
- 0xb: ECALL from M mode

Note : Exception ID 0x0 (instruction access misaligned) is not present because CPU always masks the lowest bit of the address during instruction fetch.

Interrupt Flag This flag is automatically updated when CPU enters trap. (R/W)

If this is found to be set, indicates that the latest trap occurred due to interrupt. For exceptions it remains unset.

Note : The interrupt controller is using up IDs in range 1-31 for all external interrupt sources. This is different from the RISC-V standard which has reserved IDs in range 0-15 for core internal interrupt sources.

## Register 1.11. mtval (0x343)

![Image](images/01_Chapter_1_img009_894b2ab1.png)

MTVAL Machine trap value. (R/W)

This is automatically updated with an exception dependent data which may be useful for handling that exception.

Data is to be interpreted depending upon exception IDs:

- 0x1: Faulting virtual address of instruction
- 0x2: Faulting instruction opcode
- 0x5: Faulting data address of load operation
- 0x7: Faulting data address of store operation

Note : The value of this register is not valid for other exception IDs and interrupts.

## Register 1.12. mpcer (0x7E0)

![Image](images/01_Chapter_1_img010_c882269b.png)

INST\_COMP Count Compressed Instructions. (R/W)

BRANCH\_TAKEN Count Branches Taken. (R/W)

BRANCH Count Branches. (R/W)

JMP\_UNCOND Count Unconditional Jumps. (R/W)

STORE Count Stores. (R/W)

LOAD Count Loads. (R/W)

IDLE Count IDLE Cycles. (R/W)

JMP\_HAZARD Count Jump Hazards. (R/W)

LD\_HAZARD Count Load Hazards. (R/W)

INST Count Instructions. (R/W)

CYCLE Count Clock Cycles. Cycle count does not increment during WFI mode. (R/W)

Note: Each bit selects a specific event for counter to increment. If more than one event is selected and occurs simultaneously, then counter increments by one only.

## Register 1.13. mpcmr (0x7E1)

![Image](images/01_Chapter_1_img011_d5206101.png)

COUNT\_SAT Counter Saturation Control. (R/W)

Possible values:

- 0: Overflow on maximum value
- 1: Halt on maximum value

COUNT\_EN Counter Enable Control. (R/W)

Possible values:

- 0: Disabled
- 1: Enabled

## Register 1.14. mpccr (0x7E2)

![Image](images/01_Chapter_1_img012_1ea6b37c.png)

![Image](images/01_Chapter_1_img013_106f3c54.png)

MPCCR Machine Performance Counter Value. (R/W)

## Register 1.15. cpu\_gpio\_oen (0x803)

![Image](images/01_Chapter_1_img014_360202fc.png)

CPU\_GPIO\_OEN GPIOn (n=0 ~ 21) Output Enable. CPU\_GPIO\_OEN[7:0] correspond to output enable signals cpu\_gpio\_out\_oen[7:0] in Table 5.11-1 Peripheral Signals via GPIO Matrix . CPU\_GPIO\_OEN value matches that of cpu\_gpio\_out\_oen. CPU\_GPIO\_OEN is the enable signal of CPU\_GPIO\_OUT. (R/W)

- 0: GPIO output disable
- 1: GPIO output enable

## Register 1.16. cpu\_gpio\_in (0x804)

![Image](images/01_Chapter_1_img015_66664481.png)

CPU\_GPIO\_IN GPIOn (n=0 ~ 21) Input Value. It is a CPU CSR to read input value (1=high, 0=low) from SoC GPIO pin.

CPU\_GPIO\_IN[7:0] correspond to input signals cpu\_gpio\_in[7:0] in Table 5.11-1 Peripheral Signals via GPIO Matrix .

CPU\_GPIO\_IN[7:0] can only be mapped to GPIO pins through GPIO matrix. For details please refer to Section 5.4 in Chapter IO MUX and GPIO Matrix (GPIO, IO MUX). (RO)

## Register 1.17. cpu\_gpio\_out (0x805)

![Image](images/01_Chapter_1_img016_e738f914.png)

CPU\_GPIO\_OUT GPIOn (n=0 ~ 21) Output Value. It is a CPU CSR to write value (1=high, 0=low) to SoC GPIO pin. The value takes effect only when CPU\_GPIO\_OEN is set.

CPU\_GPIO\_OUT[7:0] correspond to output signals cpu\_gpio\_out[7:0] in Table 5.11-1 Peripheral Signals via GPIO Matrix .

CPU\_GPIO\_OUT[7:0] can only be mapped to GPIO pins through GPIO matrix. For details please refer to Section 5.5 in Chapter IO MUX and GPIO Matrix (GPIO, IO MUX). (R/W)

## 1.5 Interrupt Controller

## 1.5.1 Features

The interrupt controller allows capturing, masking and dynamic prioritization of interrupt sources routed from peripherals to the RISC-V CPU. It supports:

- Up to 31 asynchronous interrupts with unique IDs (1-31)
- Configurable via read/write to memory mapped registers
- 15 levels of priority, programmable for each interrupt
- Support for both level and edge type interrupt sources
- Programmable global threshold for masking interrupts with lower priority
- Interrupts IDs mapped to trap-vector address offsets

For the complete list of interrupt registers and detailed configuration information, please refer to Chapter 8 Interrupt Matrix (INTERRUPT), section 8.4, register group "CPU Interrupt Registers".

## 1.5.2 Functional Description

Each interrupt ID has 5 properties associated with it:

1. Enable State (0-1):
- Determines if an interrupt is enabled to be captured and serviced by the CPU.
- Programmed by writing the corresponding bit in INTERRUPT\_CORE0\_CPU\_INT\_ENABLE\_REG .
2. Type (0-1):
- Enables latching the state of an interrupt signal on its rising edge.
- Programmed by writing the corresponding bit in INTERRUPT\_CORE0\_CPU\_INT\_TYPE\_REG .
- An interrupt for which type is kept 0 is referred as a 'level' type interrupt.
- An interrupt for which type is set to 1 is referred as an 'edge' type interrupt.
3. Priority (1-15):
- Determines which interrupt, among multiple pending interrupts, the CPU will service first.
- Programmed by writing to the INTERRUPT\_CORE0\_CPU\_INT\_PRI\_n\_REG for a particular interrupt ID n in range (1-31).
- Enabled interrupts with priorities zero or less than the threshold value in INTERRUPT\_CORE0\_CPU\_INT\_THRESH\_REG are masked.
- Priority levels increase from 1 (lowest) to 15 (highest).
- Interrupts with same priority are statically prioritized by their IDs, lowest ID having highest priority.
4. Pending State (0-1):
- Reflects the captured state of an enabled and unmasked interrupt signal.

- For each interrupt ID, the corresponding bit in read-only INTERRUPT\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG gives its pending state.
- A pending interrupt will cause CPU to enter trap if no other pending interrupt has higher priority.
- A pending interrupt is said to be 'claimed' if it preempts the CPU and causes it to jump to the corresponding trap vector address.
- All pending interrupts which are yet to be serviced are termed as 'unclaimed'.

## 5. Clear State (0-1):

- Toggling this will clear the pending state of claimed edge-type interrupts only.
- Toggled by first setting and then clearing the corresponding bit in INTERRUPT\_CORE0\_CPU\_INT\_CLEAR\_REG .
- Pending state of a level type interrupt is unaffected by this and must be cleared from source.
- Pending state of an unclaimed edge type interrupt can be flushed, if required, by first clearing the corresponding bit in INTERRUPT\_CORE0\_CPU\_INT\_ENABLE\_REG and then toggling same bit in INTERRUPT\_CORE0\_CPU\_INT\_CLEAR\_REG .

## When CPU services a pending interrupt, it:

- saves the address of the current un-executed instruction in mepc for resuming execution later.
- updates the value of mcause with the ID of the interrupt being serviced.
- copies the state of MIE into MPIE, and subsequently clears MIE, thereby disabling interrupts globally.
- enters trap by jumping to a word-aligned offset of the address stored in mtvec .

Table 1.5-1 shows the mapping of each interrupt ID with the corresponding trap-vector address. In short, the word aligned trap address for an interrupt with a certain ID = i can be calculated as (mtvec + 4i) .

Note : ID = 0 is unavailable and therefore cannot be used for capturing interrupts. This is because the corresponding trap vector address (mtvec + 0x00) is reserved for exceptions.

Table 1.5-1. ID wise map of Interrupt Trap-Vector Addresses

|   ID | Address      |   ID | Address      |   ID | Address      |   ID | Address      |
|------|--------------|------|--------------|------|--------------|------|--------------|
|    0 | NA           |    8 | mtvec + 0x20 |   16 | mtvec + 0x40 |   24 | mtvec + 0x60 |
|    1 | mtvec + 0x04 |    9 | mtvec + 0x24 |   17 | mtvec + 0x44 |   25 | mtvec + 0x64 |
|    2 | mtvec + 0x08 |   10 | mtvec + 0x28 |   18 | mtvec + 0x48 |   26 | mtvec + 0x68 |
|    3 | mtvec + 0x0c |   11 | mtvec + 0x2c |   19 | mtvec + 0x4c |   27 | mtvec + 0x6c |
|    4 | mtvec + 0x10 |   12 | mtvec + 0x30 |   20 | mtvec + 0x50 |   28 | mtvec + 0x70 |
|    5 | mtvec + 0x14 |   13 | mtvec + 0x34 |   21 | mtvec + 0x54 |   29 | mtvec + 0x74 |
|    6 | mtvec + 0x18 |   14 | mtvec + 0x38 |   22 | mtvec + 0x58 |   30 | mtvec + 0x78 |
|    7 | mtvec + 0x1c |   15 | mtvec + 0x3c |   23 | mtvec + 0x5c |   31 | mtvec + 0x7c |

After jumping to the trap-vector, the execution flow is dependent on software implementation, although it can be presumed that the interrupt will get handled (and cleared) in some interrupt service routine (ISR) and later the normal execution will resume once the CPU encounters MRET instruction.

Upon execution of MRET instruction, the CPU:

- copies the state of MPIE back into MIE, and subsequently clears MPIE. This means that if previously MPIE was set, then, after MRET, MIE will be set, thereby enabling interrupts globally.
- jumps to the address stored in mepc and resumes execution.

It is possible to perform software assisted nesting of interrupts inside an ISR as explained in 1.5.3 .

The below listed points outline the functional behavior of the controller:

- Only if an interrupt has non-zero priority, higher or equal to the value in the threshold register, will it be reflected in INTERRUPT\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG .
- If an interrupt is visible in INTERRUPT\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG and has yet to be serviced, then it's possible to mask it (and thereby prevent the CPU from servicing it) by either lowering the value of its priority or increasing the global threshold.
- If an interrupt, visible in INTERRUPT\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG, is to be flushed (and prevented from being serviced at all), then it must be disabled (and cleared if it is of edge type).

## 1.5.3 Suggested Operation

## 1.5.3.1 Latency Aspects

There is latency involved while configuring the Interrupt Controller.

In steady state operation, the Interrupt Controller has a fixed latency of 4 cycles. Steady state means that no changes have been made to the Interrupt Controller registers recently. This implies that any interrupt that is asserted to the controller will take exactly 4 cycles before the CPU starts processing the interrupt. This further implies that CPU may execute up to 5 instructions before the preemption happens.

Whenever any of its registers are modified, the Interrupt Controller enters into transient state, which may take up to 4 cycles for it to settle down into steady state again. During this transient state, the ordering of interrupts may not be predictable, and therefore, a few safety measures need to be taken in software to avoid any synchronization issues.

Also, it must be noted that the Interrupt Controller configuration registers lie in the APB address range, hence any R/W access to these registers may take multiple cycles to complete.

In consideration of above mentioned characteristics, users are advised to follow the sequence described below, whenever modifying any of the Interrupt Controller registers:

1. save the state of MIE and clear MIE to 0
2. read-modify-write one or more Interrupt Controller registers
3. execute FENCE instruction to wait for any pending write operations to complete
4. finally, restore the state of MIE

Due to its critical nature, it is recommended to disable interrupts globally (MIE=0) beforehand, whenever configuring interrupt controller registers, and then restore MIE right after, as shown in the sequence above.

After execution of the sequence above, the Interrupt Controller will resume operation in steady state.

## 1.5.3.2 Configuration Procedure

By default, interrupts are disabled globally, since the reset value of MIE bit in mstatus is 0. Software must set MIE=1 after initialization of the interrupt stack (including setting mtvec to the interrupt vector address) is done.

During normal execution, if an interrupt n is to be enabled, the below sequence may be followed:

1. save the state of MIE and clear MIE to 0
2. depending upon the type of the interrupt (edge/level), set/unset the nth bit of INTERRUPT\_CORE0\_CPU\_INT\_TYPE\_REG
3. set the priority by writing a value to INTERRUPT\_CORE0\_CPU\_INT\_PRI\_n\_REG in range 1(lowest) to 15 (highest)
4. set the nth bit of INTERRUPT\_CORE0\_CPU\_INT\_ENABLE\_REG
5. execute FENCE instruction
6. restore the state of MIE

When one or more interrupts become pending, the CPU acknowledges (claims) the interrupt with the highest priority and jumps to the trap vector address corresponding to the interrupt's ID. Software implementation may read mcause to infer the type of trap (mcause(31) is 1 for interrupts and 0 for exceptions) and then the ID of the interrupt (mcause(4-0) gives ID of interrupt or exception). This inference may not be necessary if each entry in the trap vector are jump instructions to different trap handlers. Ultimately, the trap handler(s) will redirect execution to the appropriate ISR for this interrupt.

Upon entering into an ISR, software must toggle the nth bit of INTERRUPT\_CORE0\_CPU\_INT\_CLEAR\_REG if the interrupt is of edge type, or clear the source of the interrupt if it is of level type.

Software may also update the value of INTERRUPT\_CORE0\_CPU\_INT\_THRESH\_REG and program MIE=1 for allowing higher priority interrupts to preempt the current ISR (nesting), however, before doing so, all the state CSRs must be saved (mepc , mstatus , mcause, etc.) since they will get overwritten due to occurrence of such an interrupt. Later, when exiting the ISR, the values of these CSRs must be restored.

Finally, after the execution returns from the ISR back to the trap handler, MRET instruction is used to resume normal execution.

Later, if the n interrupt is no longer needed and needs to be disabled, the following sequence may be followed:

1. save the state of MIE and clear MIE to 0
2. check if the interrupt is pending in INTERRUPT\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG
3. set/unset the nth bit of INTERRUPT\_CORE0\_CPU\_INT\_ENABLE\_REG
4. if the interrupt is of edge type and was found to be pending in step 2 above, nth bit of INTERRUPT\_CORE0\_CPU\_INT\_CLEAR\_REG must be toggled, so that its pending status gets flushed
5. execute FENCE instruction
6. restore the state of MIE

Above is only a suggested scheme of operation. Actual software implementation may vary.

## 1.5.4 Register Summary

The addresses in this section are relative to Interrupt Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

For the complete list of interrupt registers and detailed configuration information, please refer to Chapter 8 Interrupt Matrix (INTERRUPT), section 8.4, register group "CPU Interrupt Registers".

## 1.5.5 Register Description

The addresses in this section are relative to Interrupt Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

For the complete list of interrupt registers and detailed configuration information, please refer to Chapter 8 Interrupt Matrix (INTERRUPT), section 8.4, register group "CPU Interrupt Registers".

DEBUG HOST

(GDB)

## 1.6 Debug

ESP-RV CORE COMPLEX

DEBUG MODULE (DM)

## 1.6.1 Overview

DM REG

This section describes how to debug and test software running on CPU core. Debug support is provided through standard JTAG pins and complies to RISC-V External Debug Support Specification version 0.13.

DEBUG MODE

Figure 1.6-1 below shows the main components of External Debug Support.

ABSTRACT\_CMD/

PROGRAM

BUFFER

BUS

ACCESS

Figure 1.6-1. Debug System Overview

![Image](images/01_Chapter_1_img017_bf3df84a.png)

The user interacts with the Debug Host (eg. laptop), which is running a debugger (eg. gdb). The debugger communicates with a Debug Translator (eg. OpenOCD, which may include a hardware driver) to communicate with Debug Transport Hardware (eg. Olimex USB-JTAG adapter). The Debug Transport Hardware connects the Debug Host to the ESP-RV Core's Debug Transport Module (DTM) through standard JTAG interface. The DTM provides access to the Debug Module (DM) using the Debug Module Interface (DMI).

The DM allows the debugger to halt the core. Abstract commands provide access to its GPRs (general purpose registers). The Program Buffer allows the debugger to execute arbitrary code on the core, which allows access to additional CPU core state. Alternatively, additional abstract commands can provide access to additional CPU core state. ESP-RV core contains Trigger Module supporting 8 triggers. When trigger conditions are met, cores will halt spontaneously and inform the debug module that they have halted.

System bus access block allows memory and peripheral register access without using RISC-V core.

SYSTEM BUS

DEBUG TRANSPORT

HARDWARE

JTAG DTM

## 1.6.2 Features

Basic debug functionality supports below features.

- Provides necessary information about the implementation to the debugger.
- Allows the CPU core to be halted and resumed.
- CPU core registers (including CSR's) can be read/written by debugger.
- CPU can be debugged from the first instruction executed after reset.
- CPU core can be reset through debugger.
- CPU can be halted on software breakpoint (planted breakpoint instruction).
- Hardware single-stepping.
- Execute arbitrary instructions in the halted CPU by means of the program buffer. 16-word program buffer is supported.
- System bus access is supported through word aligned address access.
- Supports eight Hardware Triggers (can be used as breakpoints/watchpoints) as described in Section 1.7 .

## 1.6.3 Functional Description

As mentioned earlier, Debug Scheme conforms to RISC-V External Debug Support Specification version 0.13. Please refer the specs for functional operation details.

## 1.6.4 Register Summary

Below is the list of Debug CSR’s supported by ESP-RV core.

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name      | Description              | Address   | Access   |
|-----------|--------------------------|-----------|----------|
| dcsr      | Debug Control and Status | 0x7B0     | R/W      |
| dpc       | Debug PC                 | 0x7B1     | R/W      |
| dscratch0 | Debug Scratch Register 0 | 0x7B2     | R/W      |
| dscratch1 | Debug Scratch Register 1 | 0x7B3     | R/W      |

All the debug module registers are implemented in conformance to RISC-V External Debug Support Specification version 0.13. Please refer it for more details.

## 1.6.5 Register Description

Below are the details of Debug CSR’s supported by ESP-RV core

Register 1.18. dcsr (0x7B0)

![Image](images/01_Chapter_1_img018_540f44d6.png)

xdebugver Debug version. (RO)

- 4: External debug support exists

ebreakm When 1, ebreak instructions in Machine Mode enter Debug Mode. (R/W)

ebreaku When 1, ebreak instructions in User/Application Mode enter Debug Mode. (R/W)

stopcount This bit is not implemented. Debugger will always read this bit as 0. (RO)

stoptime This feature is not implemented. Debugger will always read this bit as 0. (RO)

cause Explains why Debug Mode was entered. When there are multiple reasons to enter Debug Mode in a single cycle, the cause with the highest priority number is the one written.

1. An ebreak instruction was executed. (priority 3)
2. The Trigger Module caused a halt. (priority 4)
3. haltreq was set. (priority 2)
4. The CPU core single stepped because step was set. (priority 1)

Other values are reserved for future use. (RO)

- step When set and not in Debug Mode, the core will only execute a single instruction and then enter Debug Mode. Interrupts are enabled* when this bit is set. If the instruction does not complete due to an exception, the core will immediately enter Debug Mode before executing the trap handler, with appropriate exception registers set. (R/W)
- prv Contains the privilege level the core was operating in when Debug Mode was entered. A debugger can change this value to change the core's privilege level when exiting Debug Mode. Only 0x3 (machine mode) and 0x0(user mode) are supported.

* Note: Different from RISC-V Debug specification 0.13

## Register 1.19. dpc (0x7B1)

dpc

![Image](images/01_Chapter_1_img019_ad7e2fe7.png)

- dpc Upon entry to debug mode, dpc is written with the virtual address of the instruction that encountered the exception. When resuming, the CPU core's PC is updated to the virtual address stored in dpc. A debugger may write dpc to change where the CPU resumes. (R/W)

## Register 1.20. dscratch0 (0x7B2)

![Image](images/01_Chapter_1_img020_b99801e5.png)

dscratch0 Used by Debug Module internally. (R/W)

## Register 1.21. dscratch1 (0x7B3)

![Image](images/01_Chapter_1_img021_9cb7f3f4.png)

dscratch1 Used by Debug Module internally. (R/W)

ESP32-C3 TRM (Version 1.3)

## 1.7 Hardware Trigger

## 1.7.1 Features

Hardware Trigger module provides breakpoint and watchpoint capability for debugging. It includes the following features:

- 8 independent trigger units
- each unit can be configured for matching the address of program counter or load-store accesses
- can preempt execution by causing breakpoint exception
- can halt execution and transfer control to debugger
- support NAPOT (naturally aligned power of two) address encoding

## 1.7.2 Functional Description

The Hardware Trigger module provides four CSRs, which are listed under register summary section. Among these, tdata1 and tdata2 are abstract CSRs, which means they are shadow registers for accessing internal registers for each of the eight trigger units, one at a time.

To choose a particular trigger unit write the index (0-7) of that unit into tselect CSR. When tselect is written with a valid index, the abstract CSRs tdata1 and tdata2 are automatically mapped to reflect internal registers of that trigger unit. Each trigger unit has two internal registers, namely mcontrol and maddress, which are mapped to tdata1 and tdata2, respectively.

Writing larger than allowed indexes to tselect will clip the written value to the largest valid index, which can be read back. This property may be used for enumerating the number of available triggers during initialization or when using a debugger.

Since software or debugger may need to know the type of the selected trigger to correctly interpret tdata1 and tdata2, the 4 bits (31-28) of tdata1 encodes the type of the selected trigger. This type field is read-only and always provides a value of 0x2 for every trigger, which stands for match type trigger, hence, it is inferred that tdata1 and tdata2 are to be interpreted as mcontrol and maddress. The information regarding other possible values can be found in the RISC-V Debug Specification v0.13, but this trigger module only supports type 0x2.

Once a trigger unit has been chosen by writing its index to tselect, it will become possible to configure it by setting the appropriate bits in mcontrol CSR (tdata1) and writing the target address to maddress CSR (tdata2).

Each trigger unit can be configured to either cause breakpoint exception or enter debug mode, by writing to the action bit of mcontrol. This bit can only be written from debugger, thus by default a trigger, if enabled, will cause breakpoint exception.

mcontrol for each trigger unit has a hit bit which may be read, after CPU halts or enters exception, to find out if this was the trigger unit that fired. This bit is set as soon as the corresponding trigger fires, but it has to be manually cleared before resuming operation. Although, failing to clear it doesn't affect normal execution in any way.

Each trigger unit only supports match on address, although this address could either be that of a load/store access or the virtual address of an instruction. The address and size of a region are specified by writing to maddress (tdata2) CSR for the selected trigger unit. Larger than 1 byte region sizes are specified through NAPOT (naturally aligned power of two) encoding (see Table 1.7-1) and enabled by setting match bit in mcontrol. Note that for NAPOT encoded addresses, by definition, the start address is constrained to be aligned to (i.e. an integer multiple of) the region size.

Table 1.7-1. NAPOT encoding for maddress

| maddress(31-0)   | Start Address    | Size (bytes)   |
|------------------|------------------|----------------|
| aaa...aaaaaaaaa0 | aaa...aaaaaaaaa0 | 2              |
| aaa...aaaaaaaa01 | aaa...aaaaaaaa00 | 4              |
| aaa...aaaaaaa011 | aaa...aaaaaaa000 | 8              |
| aaa...aaaaaa0111 | aaa...aaaaaa0000 | 16             |
| ....             | ....             | ....           |
| a01...1111111111 | a00...0000000000 | 2 31           |

tcontrol CSR is common to all trigger units. It is used for preventing triggers from causing repeated exceptions in machine-mode while execution is happening inside a trap handler. This also disables breakpoint exceptions inside ISRs by default, although, it is possible to manually enable this right before entering an ISR, for debugging purposes. This CSR is not relevant if a trigger is configured to enter debug mode.

## 1.7.3 Trigger Execution Flow

When hart is halted and enters debug mode due to the firing of a trigger (action = 1):

- dpc is set to current PC (in decode stage)
- cause field in dcsr is set to 2, which means halt due to trigger
- hit bit is set to 1, corresponding to the trigger(s) which fired

When hart goes into trap due to the firing of a trigger (action = 0) :

- mepc is set to current PC (in decode stage)
- mcause is set to 3, which means breakpoint exception
- mpte is set to the value in mte right before trap
- mte is set to 0
- hit bit is set to 1, corresponding to the trigger(s) which fired

Note : If two different triggers fire at the same time, one with action = 0 and another with action = 1, then hart is halted and enters debug mode.

## 1.7.4 Register Summary

Below is a list of Trigger Module CSRs supported by the CPU. These are only accessible from machine-mode.

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name     | Description             | Address   | Access   |
|----------|-------------------------|-----------|----------|
| tselect  | Trigger Select Register | 0x7A0     | R/W      |
| tdata1   | Trigger Abstract Data 1 | 0x7A1     | R/W      |
| tdata2   | Trigger Abstract Data 2 | 0x7A2     | R/W      |
| tcontrol | Global Trigger Control  | 0x7A5     | R/W      |

## 1.7.5 Register Description

Register 1.22. tselect (0x7A0)

![Image](images/01_Chapter_1_img022_06c02265.png)

tselect Index (0-7) of the selected trigger unit. (R/W)

Register 1.23. tdata1 (0x7A1)

![Image](images/01_Chapter_1_img023_25e55baf.png)

## type Type of trigger. (RO)

This field is reserved since only match type (0x2) triggers are supported.

dmode This is set to 1 if a trigger is being used by the debugger. (R/W *)

- 0: Both Debug and M-mode can write the tdata1 and tdata2 registers at the selected tselect.
- 1: Only Debug Mode can write the tdata1 and tdata2 registers at the selected tselect. Writes from other modes are ignored.
* Note : Only writable from debug mode.

## data Abstract tdata1 content. (R/W)

This will always be interpreted as fields of mcontrol since only match type (0x2) triggers are supported.

## Register 1.24. tdata2 (0x7A2)

tdata2

![Image](images/01_Chapter_1_img024_88969c08.png)

| 31   | 0     |
|------|-------|
|      | Reset |

## tdata2 Abstract tdata2 content. (R/W)

This will always be interpreted as maddress since only match type (0x2) triggers are supported.

## Register 1.25. tcontrol (0x7A5)

![Image](images/01_Chapter_1_img025_36e24442.png)

mpte Machine mode previous trigger enable bit. (R/W)

- When CPU is taking a machine mode trap, the value of mte is automatically pushed into this.
- When CPU is executing MRET, its value is popped back into mte, so this becomes 0.

mte Machine mode trigger enable bit. (R/W)

- When CPU is taking a machine mode trap, its value is automatically pushed into mpte, so this becomes 0 and triggers with action=0 are disabled globally.
- When CPU is executing MRET, the value of mpte is automatically popped back into this.

## Register 1.26. mcontrol (0x7A1)

![Image](images/01_Chapter_1_img026_a8fd8dbd.png)

dmode Same as dmode in tdata1 .

hit This is found to be 1 if the selected trigger had fired previously. (R/W)

This bit is to be cleared manually.

action Write this for configuring the selected trigger to perform one of the available actions when firing. (R/W)

Valid options are:

- 0x0: cause breakpoint exception.
- 0x1: enter debug mode (only valid when dmode = 1)

Note : Writing an invalid value will set this to the default value 0x0.

match Write this for configuring the selected trigger to perform one of the available matching operations on a data/instruction address. (R/W) Valid options are:

- 0x0: exact byte match, i.e. address corresponding to one of the bytes in an access must match the value of maddress exactly.
- 0x1: NAPOT match, i.e. at least one of the bytes of an access must lie in the NAPOT region specified in maddress .

Note : Writing a larger value will clip it to the largest possible value 0x1.

- m Set this for enabling selected trigger to operate in machine mode. (R/W)
- u Set this for enabling selected trigger to operate in user mode. (R/W)

execute Set this for configuring the selected trigger to fire right before an instruction with matching virtual address is executed by the CPU. (R/W)

- store Set this for configuring the selected trigger to fire right before a store operation with matching data address is executed by the CPU. (R/W)

load Set this for configuring the selected trigger to fire right before a load operation with matching data address is executed by the CPU. (R/W)

## Register 1.27. maddress (0x7A2)

![Image](images/01_Chapter_1_img027_e17b2172.png)

maddress Address used by the selected trigger when performing match operation. (R/W) This is decoded as NAPOT when match=1 in mcontrol .

## 1.8 Memory Protection

## 1.8.1 Overview

The CPU core includes a physical memory protection unit, which can be used by software to set memory access privileges (read, write and execute permissions) for required memory regions. However it is not fully compliant to the Physical Memory Protection (PMP) description specified in RISC-V Instruction Set Manual, Volume II: Privileged Architecture, Version 1.10. Details of existing non-conformance are provided in next section.

For detailed understanding of the RISC-V PMP concept, please refer to RISC-V Instruction Set Manual, Volume II: Privileged Architecture, Version 1.10.

## 1.8.2 Features

The PMP unit can be used to restrict access to physical memory. It supports 16 regions and a minimum granularity of 4 bytes. Below are the current non-conformance with PMP description from RISC-V Privilege specifications:

- Static priority i.e. overlapping regions are not supported
- Maximum supported NAPOT range is 1 GB

As per RISC-V Privilege specifications, PMP entries should be statically prioritized and the lowest-numbered PMP entry that matches any address byte of an access will determine whether that access succeeds or fails. This means, when any address matches more than one PMP entry i.e. overlapping regions among different PMP entries, lowest number PMP entry will decide whether such address access will succeed or fail.

However, RISC-V CPU PMP unit in ESP32-C3 does not implement static priority. So, software should make sure that all enabled PMP entries are programmed with unique regions i.e. without any region overlap among them. If software still tries to program multiple PMP entries with overlapping region having contradicting permissions, then access will succeed if it matches at least one of enabled PMP entries. An exception will be generated, if access matches none of the enabled PMP entries.

## 1.8.3 Functional Description

Software can program the PMP unit's configuration and address registers in order to contain faults and support secure execution. PMP CSR's can only be programmed in machine-mode. Once enabled, write, read and execute permission checks are applied to all the accesses in user-mode as per programmed values of enabled 16 pmpcfgX and pmpaddrX registers (refer Register Summary).

By default, PMP grants permission to all accesses in machine-mode and revokes permission of all access in user-mode. This implies that it is mandatory to program address range and valid permissions in pmpcfg and pmpaddr registers (refer Register Summary) for any valid access to pass through in user-mode. However, it is not required for machine-mode as PMP permits all accesses to go through by deafult. In cases where PMP checks are also required in machine-mode, software can set the lock bit of required PMP entry to enable permission checks on it. Once lock bit is set, it can only be cleared through CPU reset.

When any instruction is being fetched from memory region without execute permissions, exception is generated at processor level and exception cause is set as instruction access fault in mcause CSR. Similarly,

any load/store access without valid read/write permissions, will result in exception generation with mcause updated as load access and store access fault respectively. In case of load/store access faults, violating address is captured in mtval CSR.

![Image](images/01_Chapter_1_img028_4290e1b6.png)

## 1.8.4 Register Summary

Below is a list of PMP CSRs supported by the CPU. These are only accessible from machine-mode.

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name      | Description                                  | Address   | Access   |
|-----------|----------------------------------------------|-----------|----------|
| pmpcfg0   | Physical memory protection configuration.    | 0x3A0     | R/W      |
| pmpcfg1   | Physical memory protection configuration.    | 0x3A1     | R/W      |
| pmpcfg2   | Physical memory protection configuration.    | 0x3A2     | R/W      |
| pmpcfg3   | Physical memory protection configuration.    | 0x3A3     | R/W      |
| pmpaddr0  | Physical memory protection address register. | 0x3B0     | R/W      |
| pmpaddr1  | Physical memory protection address register. | 0x3B1     | R/W      |
| pmpaddr2  | Physical memory protection address register. | 0x3B2     | R/W      |
| pmpaddr3  | Physical memory protection address register. | 0x3B3     | R/W      |
| pmpaddr4  | Physical memory protection address register. | 0x3B4     | R/W      |
| pmpaddr5  | Physical memory protection address register. | 0x3B5     | R/W      |
| pmpaddr6  | Physical memory protection address register. | 0x3B6     | R/W      |
| pmpaddr7  | Physical memory protection address register. | 0x3B7     | R/W      |
| pmpaddr8  | Physical memory protection address register. | 0x3B8     | R/W      |
| pmpaddr9  | Physical memory protection address register. | 0x3B9     | R/W      |
| pmpaddr10 | Physical memory protection address register. | 0x3BA     | R/W      |
| pmpaddr11 | Physical memory protection address register. | 0x3BB     | R/W      |
| pmpaddr12 | Physical memory protection address register. | 0x3BC     | R/W      |
| pmpaddr13 | Physical memory protection address register. | 0x3BD     | R/W      |
| pmpaddr14 | Physical memory protection address register. | 0x3BE     | R/W      |
| pmpaddr15 | Physical memory protection address register. | 0x3BF     | R/W      |

## 1.8.5 Register Description

PMP unit implements all pmpcfg0-3 and pmpaddr0-15 CSRs as defined in RISC-V Instruction Set Manual Volume II: Privileged Architecture, Version 1.10 .
