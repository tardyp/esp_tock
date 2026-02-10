---
chapter: 1
title: "Chapter 1"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 1

## High-Performance CPU

## 1.1 Overview

ESP-RISC-V CPU is a 32-bit core based upon RISC-V instruction set architecture (ISA) comprising base integer (I), multiplication/division (M), atomic (A) and compressed (C) standard extensions. The core has 4-stage, in-order, scalar pipeline optimized for area, power and performance. CPU core complex has a debug module (DM), interrupt-controller (INTC), core local interrupts (CLINT) and system bus (SYS BUS) interfaces for memory and peripheral access.

Figure 1.1-1. CPU Block Diagram

![Image](images/01_Chapter_1_img001_58ef5a24.png)

## 1.2 Features

- RISC-V RV32IMAC ISA with four-stage pipeline that supports an operating clock frequency up to 160 MHz
- Compatible with RISC-V ISA Manual Volume I: Unprivileged ISA Version 2.2 and RISC-V ISA Manual, Volume II: Privileged Architecture, Version 1.10
- Zero wait cycle access to on-chip SRAM and Cache for program and data access over IRAM/DRAM interface

![Image](images/01_Chapter_1_img002_e8d4eb69.png)

- Branch target buffer (BTB) with static branch prediction
- User (U) mode support along with interrupt delegation
- Interrupt controller with up to 28 external vectored interrupts for both M and U modes with 16 programmable priority and threshold levels
- Core local interrupts (CLINT) dedicated for each privilege mode
- Debug module (DM) compliant with the specification RISC-V External Debug Support Version 0.13 with external debugger support over an industry-standard JTAG/USB port
- Support for instruction trace
- Debugger with a direct system bus access (SBA) to memory and peripherals
- Hardware trigger compliant to the specification RISC-V External Debug Support Version 0.13 with up to 4 breakpoints/watchpoints
- Physical memory protection (PMP) and attributes (PMA) for up to 16 configurable regions
- 32-bit AHB system bus for peripheral access
- Configurable events for core performance metrics

## 1.3 Terminology

branch

an instruction which conditionally changes the execution flow

delta

a change in the program counter that is other than the difference between two instructions placed consecutively in memory

hart

a RISC-V hardware thread

retire

the final stage of executing an instruction, when the machine state is updated

trap the transfer of control to a trap handler caused by either an exception or an interrupt

## 1.4 Address Map

Below table shows address map of various regions accessible by CPU for instruction, data, system bus peripheral and debug.

Table 1.4-1. CPU Address Map

| Name      | Description             | Starting Address   | Ending Address   | Access   |
|-----------|-------------------------|--------------------|------------------|----------|
| IRAM/DRAM | Instruction/Data region | 0x4000_0000        | 0x4FFF_FFFF      | R/W      |
| CPU       | CPU Sub-system region   | 0x2000_0000        | 0x2FFF_FFFF      | R/W      |
| AHB       | AHB Peripheral region   | *default           | *default         | R/W      |

## 1.5 Configuration and Status Registers (CSRs)

## 1.5.1 Register Summary

Below is a list of CSRs available to the CPU. Except for the custom performance counter CSRs, all the implemented CSRs follow the standard mapping of bit fields as described in the RISC-V Instruction Set Manual, Volume II: Privileged Architecture, Version 1.10. It must be noted that even among the standard CSRs, not all bit fields have been implemented, limited by the subset of features implemented in the CPU. Refer to the next section for detailed description of the subset of fields implemented under each of these CSRs.

| Name                                  | Description                              | Address                               | Access                                |
|---------------------------------------|------------------------------------------|---------------------------------------|---------------------------------------|
| Machine Information CSRs              | Machine Information CSRs                 | Machine Information CSRs              | Machine Information CSRs              |
| mvendorid                             | Machine Vendor ID                        | 0xF11                                 | RO                                    |
| marchid                               | Machine Architecture ID                  | 0xF12                                 | RO                                    |
| mimpid                                | Machine Implementation ID                | 0xF13                                 | RO                                    |
| mhartid                               | Machine Hart ID                          | 0xF14                                 | RO                                    |
| Machine Trap Setup CSRs               | Machine Trap Setup CSRs                  | Machine Trap Setup CSRs               | Machine Trap Setup CSRs               |
| mstatus                               | Machine Mode Status                      | 0x300                                 | R/W                                   |
| misa  ¹                               | Machine ISA                              | 0x301                                 | R/W                                   |
| mideleg                               | Machine Interrupt Delegation Register    | 0x303                                 | R/W                                   |
| mie                                   | Machine Interrupt Enable Register        | 0x304                                 | R/W                                   |
| mtvec  ²                              | Machine Trap Vector                      | 0x305                                 | R/W                                   |
| Machine Trap Handling CSRs            | Machine Trap Handling CSRs               | Machine Trap Handling CSRs            | Machine Trap Handling CSRs            |
| mscratch                              | Machine Scratch                          | 0x340                                 | R/W                                   |
| mepc                                  | Machine Trap Program Counter             | 0x341                                 | R/W                                   |
| mcause  ³                             | Machine Trap Cause                       | 0x342                                 | R/W                                   |
| mtval                                 | Machine Trap Value                       | 0x343                                 | R/W                                   |
| mip                                   | Machine Interrupt Pending                | 0x344                                 | R/W                                   |
| User Trap Setup CSRs                  | User Trap Setup CSRs                     | User Trap Setup CSRs                  | User Trap Setup CSRs                  |
| ustatus                               | User Mode Status                         | 0x000                                 | R/W                                   |
| uie                                   | User Interrupt Enable Register           | 0x004                                 | R/W                                   |
| utvec                                 | User Trap Vector                         | 0x005                                 | R/W                                   |
| User Trap Handling CSRs               | User Trap Handling CSRs                  | User Trap Handling CSRs               | User Trap Handling CSRs               |
| uscratch                              | User Scratch                             | 0x040                                 | R/W                                   |
| uepc                                  | User Trap Program Counter                | 0x041                                 | R/W                                   |
| ucause                                | User Trap Cause                          | 0x042                                 | R/W                                   |
| uip                                   | User Interrupt Pending                   | 0x044                                 | R/W                                   |
| Physical Memory Protection (PMP) CSRs | Physical Memory Protection (PMP) CSRs    | Physical Memory Protection (PMP) CSRs | Physical Memory Protection (PMP) CSRs |
| pmpcfg0                               | Physical memory protection configuration | 0x3A0                                 | R/W                                   |
| pmpcfg1                               | Physical memory protection configuration | 0x3A1                                 | R/W                                   |
| pmpcfg2                               | Physical memory protection configuration | 0x3A2                                 | R/W                                   |

| Name                                           | Description                                    | Address                                        | Access                                         |
|------------------------------------------------|------------------------------------------------|------------------------------------------------|------------------------------------------------|
| pmpcfg3                                        | Physical memory protection configuration       | 0x3A3                                          | R/W                                            |
| pmpaddr0                                       | Physical memory protection address register    | 0x3B0                                          | R/W                                            |
| pmpaddr1                                       | Physical memory protection address register    | 0x3B1                                          | R/W                                            |
| ....                                           | ....                                           | ....                                           | ....                                           |
| pmpaddr15                                      | Physical memory protection address register    | 0x3BF                                          | R/W                                            |
| Trigger Module CSRs (shared with Debug Mode)   | Trigger Module CSRs (shared with Debug Mode)   | Trigger Module CSRs (shared with Debug Mode)   | Trigger Module CSRs (shared with Debug Mode)   |
| tselect                                        | Trigger Select Register                        | 0x7A0                                          | R/W                                            |
| tdata1                                         | Trigger Abstract Data 1                        | 0x7A1                                          | R/W                                            |
| tdata2                                         | Trigger Abstract Data 2                        | 0x7A2                                          | R/W                                            |
| tcontrol                                       | Global Trigger Control                         | 0x7A5                                          | R/W                                            |
| Debug Mode CSRs                                | Debug Mode CSRs                                | Debug Mode CSRs                                | Debug Mode CSRs                                |
| dcsr                                           | Debug Control and Status                       | 0x7B0                                          | R/W                                            |
| dpc                                            | Debug PC                                       | 0x7B1                                          | R/W                                            |
| dscratch0                                      | Debug Scratch Register 0                       | 0x7B2                                          | R/W                                            |
| dscratch1                                      | Debug Scratch Register 1                       | 0x7B3                                          | R/W                                            |
| Performance Counter CSRs (Custom)  ⁴           | Performance Counter CSRs (Custom)  ⁴           | Performance Counter CSRs (Custom)  ⁴           | Performance Counter CSRs (Custom)  ⁴           |
| mpcer                                          | Machine Performance Counter Event              | 0x7E0                                          | R/W                                            |
| mpcmr                                          | Machine Performance Counter Mode               | 0x7E1                                          | R/W                                            |
| mpccr                                          | Machine Performance Counter Count              | 0x7E2                                          | R/W                                            |
| GPIO Access CSRs (Custom)                      | GPIO Access CSRs (Custom)                      | GPIO Access CSRs (Custom)                      | GPIO Access CSRs (Custom)                      |
| cpu_gpio_oen                                   | GPIO Output Enable                             | 0x803                                          | R/W                                            |
| cpu_gpio_in                                    | GPIO Input Value                               | 0x804                                          | RO                                             |
| cpu_gpio_out                                   | GPIO Output Value                              | 0x805                                          | R/W                                            |
| Physical Memory Attributes Checker (PMAC) CSRs | Physical Memory Attributes Checker (PMAC) CSRs | Physical Memory Attributes Checker (PMAC) CSRs | Physical Memory Attributes Checker (PMAC) CSRs |
| pma_cfg0                                       | Physical memory attribute configuration        | 0xBC0                                          | R/W                                            |
| pma_cfg1                                       | Physical memory attribute configuration        | 0xBC1                                          | R/W                                            |
| pma_cfg2                                       | Physical memory attribute configuration        | 0xBC2                                          | R/W                                            |
| pma_cfg3                                       | Physical memory attribute configuration        | 0xBC3                                          | R/W                                            |
| ....                                           | ....                                           | ....                                           | ....                                           |
| pma_cfg15                                      | Physical memory attribute configuration        | 0xBCF                                          | R/W                                            |
| pma_addr0                                      | Physical memory attribute address register     | 0xBD0                                          | R/W                                            |
| pma_addr1                                      | Physical memory attribute address register     | 0xBD1                                          | R/W                                            |
| ....                                           | ....                                           | ....                                           | ....                                           |
| pma_addr15                                     | Physical memory attribute address register     | 0xBDF                                          | R/W                                            |

Note that if write/set/clear operation is attempted on any of the CSRs which are read-only (RO), as indicated in the above table, the CPU will generate illegal instruction exception.

⁴ These custom CSRs have been implemented in the address space reserved by RISC-V standard for custom use

## 1.5.2 Register Description

![Image](images/01_Chapter_1_img003_8c1d519d.png)

## Register 1.5. mstatus (0x300)

![Image](images/01_Chapter_1_img004_2a0ff9ae.png)

- UIE Write 1 to enable the global user mode interrupt. (R/W)
- MIE Write 1 to enable the global machine mode interrupt. (R/W)
- UPIE Write 1 to enable the user previous interrupt (before trap). (R/W)
- MPIE Write 1 to enable the machine previous interrupt (before trap). (R/W)
- MPP Configures machine previous privilege mode (before trap).

0x0: User mode

0x3: Machine mode

Note: Only the lower bit is writable. Any write to the higher bit is ignored as it is directly tied to the lower bit.

(R/W)

- TW Configures whether to cause illegal instruction exception when WFI (Wait-for-Interrupt) instruction is executed in U mode.
- 0: Not cause illegal exception in U mode
- 1: Cause illegal instruction exception

(R/W)

## Register 1.6. misa (0x301)

![Image](images/01_Chapter_1_img005_65868949.png)

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
- A Atomic Extension = 1. (RO)

## Register 1.7. mideleg (0x303)

![Image](images/01_Chapter_1_img006_136b38c4.png)

![Image](images/01_Chapter_1_img007_db329a1a.png)

| 31   | 0     |
|------|-------|
|      | Reset |

MIDELEG Configures the U mode delegation state for each interrupt ID. Below interrupts are delegated to U mode by default:

Bit 0: User software interrupt (CLINT)

Bit 4: User timer interrupt (CLINT)

Bit 8: User external interrupt

The default delegation can be modified at run-time if required.

(R/W)

## Register 1.8. mie (0x304)

![Image](images/01_Chapter_1_img008_a11ad718.png)

USIE Write 1 to enable the user software interrupt. (R/W)

MSIE Write 1 to enable the machine software interrupt. (R/W)

UTIE Write 1 to enable the user timer interrupt. (R/W)

MTIE Write 1 to enable the machine timer interrupt. (R/W)

MXIE Write 1 to enable the 28 external interrupts. (R/W)

## Register 1.9. mtvec (0x305)

![Image](images/01_Chapter_1_img009_1df376e1.png)

MODE Represents whether machine mode interrupts are vectored. Only vectored mode 0x1 is available. (RO)

BASE Configures the higher 24 bits of trap vector base address aligned to 256 bytes. (R/W)

## Register 1.10. mscratch (0x340)

![Image](images/01_Chapter_1_img010_466e0c7a.png)

MSCRATCH Configures machine scratch information for custom use. (R/W)

## Register 1.11. mepc (0x341)

![Image](images/01_Chapter_1_img011_a3327d3d.png)

![Image](images/01_Chapter_1_img012_c481c1c0.png)

MEPC Configures the machine trap/exception program counter. This is automatically updated with address of the instruction which was about to be executed while CPU encountered the most recent trap. (R/W)

## Register 1.12. mcause (0x342)

![Image](images/01_Chapter_1_img013_3c13a820.png)

Exception Code This field is automatically updated with unique ID of the most recent exception or interrupt due to which CPU entered trap. Possible exception IDs are:

- 0x1: PMP instruction access fault
- 0x2: Illegal instruction
- 0x3: Hardware breakpoint/watchpoint or EBREAK
- 0x5: PMP load access fault
- 0x6: Misaligned store address or AMO address
- 0x7: PMP store access or AMO access fault
- 0x8: ECALL from U mode
- 0xb: ECALL from M mode
- Other values: reserved

Note: Exception ID 0x0 (instruction access misaligned) is not present because CPU always masks the lowest bit of the address during instruction fetch. (R/W)

Interrupt Flag This flag is automatically updated when CPU enters trap.

If this is found to be set, indicates that the latest trap occurred due to an interrupt. For exceptions it remains unset.

Note: The interrupt controller is using up IDs in range 1-2, 5-6 and 8-31 for all external interrupt sources. This is different from the RISC-V standard which has reserved IDs in range 0-15 for core local interrupts only. Although local interrupt sources (CLINT) do use the reserved IDs 0, 3, 4 and 7.

(R/W)

## Register 1.13. mtval (0x343)

![Image](images/01_Chapter_1_img014_50ed12a5.png)

![Image](images/01_Chapter_1_img015_e7c30ef0.png)

| 31   | 0     |
|------|-------|
|      | Reset |

MTVAL Configures machine trap value. This is automatically updated with an exception dependent data which may be useful for handling that exception.

Data is to be interpreted depending upon exception IDs:

- 0x1: Faulting virtual address of instruction
- 0x2: Faulting instruction opcode
- 0x5: Faulting data address of load operation
- 0x7: Faulting data address of store operation

Note: The value of this register is not valid for other exception IDs and interrupts.

(R/W)

## Register 1.14. mip (0x344)

![Image](images/01_Chapter_1_img016_8e5a7d29.png)

|     | MXIP[31:8]   | MTIP   | MXIP[6:5]
 UTI 6
 UTIP
 M   | P
 MSIP   |     | MXIP[2:1]
 US 2
 USIP   |
|-----|--------------|--------|-----------------------------|-----------|-----|-------------------------|
| 31  | 8            | 7 6    | 5 4                         | 3 2       | 1   | 0                       |
| 0x0 | 0x0          | 0x0    | 0x0 0x0                     | 0x0       | 0x0 | Reset                   |

USIP Configures the pending status of the user software interrupt.

- 0: Not pending
- 1: Pending

(R/W)

- MSIP Configures the pending status of the machine software interrupt.
- 0: Not pending
- 1: Pending

(R/W)

- UTIP Configures the pending status of the user timer interrupt.
- 0: Not pending
- 1: Pending

(R/W)

- MTIP Configures the pending status of the machine timer interrupt.
- 0: Not pending
- 1: Pending

(R/W)

- MXIP Configures the pending status of the 28 external interrupts.
- 0: Not pending
- 1: Pending

(R/W)

## Register 1.15. ustatus (0x300)

![Image](images/01_Chapter_1_img017_1afbfc45.png)

UIE Write 1 to enable the global user mode interrupt. (R/W)

UPIE Write 1 to enable the user previous interrupt (before trap). (R/W)

## Register 1.16. uie (0x004)

![Image](images/01_Chapter_1_img018_7a29ccf7.png)

USIE Write 1 to enable the user software interrupt. (R/W)

UTIE Write 1 to enable the user timer interrupt. (R/W)

UXIE Write 1 to enable the 28 external interrupts delegated to U mode. (R/W)

## Register 1.17. utvec (0x005)

![Image](images/01_Chapter_1_img019_e70f9803.png)

MODE Represents if user mode interrupts are vectored. Only vectored mode 0x1 is available. (RO)

BASE Configures the higher 24 bits of trap vector base address aligned to 256 bytes. (R/W)

## Register 1.18. uscratch (0x040)

![Image](images/01_Chapter_1_img020_b64d0988.png)

USCRATCH Configures user scratch information for custom use. (R/W)

## Register 1.19. uepc (0x041)

UEPC

![Image](images/01_Chapter_1_img021_ca293126.png)

UEPC Configures the user trap program counter. This is automatically updated with address of the instruction which was about to be executed in User mode while CPU encountered the most recent user mode interrupt. (R/W)

## Register 1.20. ucause (0x042)

![Image](images/01_Chapter_1_img022_b0934bfc.png)

Interrupt ID This field is automatically updated with the unique ID of the most recent user mode interrupt due to which CPU entered trap. (R/W)

Interrupt Flag This flag would always be set because CPU can only enter trap due to user mode interrupts as exception delegation is unsupported. (R/W)

## Register 1.21. uip (0x044)

![Image](images/01_Chapter_1_img023_4fbbc81a.png)

USIP Configures the pending status of the user software interrupt.

- 0: Not pending
- 1: Pending

(R/W)

- UTIP Configures the pending status of the user timer interrupt.
- 0: Not pending
- 1: Pending

(R/W)

- UXIP Configures the pending status of the 28 external interrupts delegated to user mode.
- 0: Not pending
- 1: Pending

(R/W)

![Image](images/01_Chapter_1_img024_7f131f54.png)

Register 1.22. mpcer (0x7E0)

![Image](images/01_Chapter_1_img025_c882269b.png)

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

CYCLE Count Clock Cycles. Cycle count does not increment during WFI mode.

Note: Each bit selects a specific event for counter to increment. If more than one event is selected and occurs simultaneously, then counter increments by one only. (R/W)

## Register 1.23. mpcmr (0x7E1)

![Image](images/01_Chapter_1_img026_2a0d26cd.png)

COUNT\_SAT Configures counter saturation.

0: Overflow on maximum value

1: Halt on maximum value

(R/W)

COUNT\_EN Configures whether to enable the counter.

0: Disable

1: Enable

(R/W)

## Register 1.24. mpccr (0x7E2)

![Image](images/01_Chapter_1_img027_004a1dee.png)

MPCCR Represents the machine performance counter value. (R/W)

## 1.6 Interrupt Controller

## 1.6.1 Features

The interrupt controller allows capturing, masking and dynamic prioritization of interrupt sources routed from peripherals to the RISC-V CPU. It supports:

- Up to 28 external asynchronous interrupts and 4 core local interrupt sources (CLINT) with unique IDs (0-31)
- Configurable via read/write to memory mapped registers
- Delegable to user mode
- 15 levels of priority, programmable for each interrupt
- Support for both level and edge type interrupt sources
- Programmable global threshold for masking interrupts with lower priority
- Interrupts IDs mapped to trap-vector address offsets

For the complete list of interrupt registers and detailed configuration information, please refer to Chapter 10 Interrupt Matrix (INTMTX) &gt; Section 10.4.2 .

## 1.6.2 Functional Description

Each interrupt ID has 6 properties associated with it. These properties can be configured for the 28 external interrupts (1-2, 5-6, 8-31), but are static (except mode) for the 4 local CLINT interrupts (0, 3, 4, 7). These properties are as follows:

## 1. Mode (M/U):

- Determines the mode in which an interrupt is to be serviced.
- Programmed by setting or clearing the corresponding bit in mideleg CSR.
- If the bit is cleared for an interrupt in mideleg CSR, then that interrupt will be captured in M mode.
- If the bit is set for an interrupt in mideleg CSR, then it will be delegated to U mode.

## 2. Enable State (0-1):

- Determines if an interrupt is enabled to be captured and serviced by the CPU.
- Programmed by writing the corresponding bit in INTPRI\_CORE0\_CPU\_INT\_ENABLE\_REG .
- Local CLINT interrupts have the corresponding bits reserved in the memory mapped registers thus they are always enabled at the INTC level.
- An M mode interrupt (external or local) further needs to be unmasked at core level by setting the corresponding bit in mie CSR.
- A U mode interrupt (external or local) further needs to be unmasked at core level by setting the corresponding bits in uie CSR.

## 3. Type (0-1):

- Enables latching the state of an interrupt signal on its rising edge.

- Programmed by writing the corresponding bit in INTPRI\_CORE0\_CPU\_INT\_TYPE\_REG .
- An interrupt for which type is kept 0 is referred as a 'level' type interrupt.
- An interrupt for which type is set to 1 is referred as an 'edge' type interrupt.
- Local CLINT interrupts are always 'level' type and thus have the corresponding bits reserved in the above register.

## 4. Priority (0-15):

- Determines which interrupt, among multiple pending interrupts, the CPU will service first.
- Programmed by writing to the INTPRI\_CORE0\_CPU\_INT\_PRI\_n\_REG for an external interrupt with particular interrupt ID n .
- Enabled external interrupts with priorities less than the threshold value in INTPRI\_CORE0\_CPU\_INT\_THRESH\_REG are masked.
- Priority levels increase from 0 (lowest) to 15 (highest).
- Interrupts with same priority are statically prioritized by their IDs, lowest ID having highest priority.
- Local CLINT interrupts have static priorities associated with them, and thus have the corresponding priority registers to be reserved.
- Local CLINT interrupts cannot be masked using the threshold values for either modes.

## 5. Pending State (0-1):

- Reflects the captured state of an enabled and unmasked external interrupt signal.
- For each external interrupt ID the corresponding bit in read-only INTPRI\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG gives its pending state.
- For each interrupt ID (local or external), the corresponding bit in the mip CSR for M mode interrupts or uip CSR for U mode interrupts, also gives its pending state.
- A pending interrupt will cause CPU to enter trap if no other pending interrupt has higher priority.
- A pending interrupt is said to be 'claimed' if it preempts the CPU and causes it to jump to the corresponding trap vector address.
- All pending interrupts which are yet to be serviced are termed as 'unclaimed'.

## 6. Clear State (0-1):

- Toggling this will clear the pending state of claimed edge-type interrupts only.
- Toggled by first setting and then clearing the corresponding bit in INTPRI\_CORE0\_CPU\_INT\_CLEAR\_REG .
- Pending state of a level type interrupt is unaffected by this and must be cleared from source.
- Pending state of an unclaimed edge type interrupt can be flushed, if required, by first clearing the corresponding bit in INTPRI\_CORE0\_CPU\_INT\_ENABLE\_REG and then toggling same bit in INTPRI\_CORE0\_CPU\_INT\_CLEAR\_REG .

For detailed description of the core local interrupt sources, please refer to Section 1.7 .

When CPU services a pending M/U mode interrupt, it:

- saves the address of the current un-executed instruction in mepc/uepc for resuming execution later.
- updates the value of mcause/ucause with the ID of the interrupt being serviced.
- copies the state of MIE/UIE into MPIE/UPIE, and subsequently clears MIE/UIE, thereby disabling interrupts globally.
- enters trap by jumping to a word-aligned offset of the address stored in mtvec/utvec .

The word aligned trap address for an M mode interrupt with a certain ID = i can be calculated as (mtvec + 4i) . Similarly, the word aligned trap address for a U mode interrupt can be calculated as (utvec + 4i) .

After jumping to the trap vector for the corresponding mode, the execution flow is dependent on software implementation, although it can be presumed that the interrupt will get handled (and cleared) in some interrupt service routine (ISR) and later the normal execution will resume once the CPU encounters MRET/URET instruction for that mode.

Upon execution of MRET/URET instruction, the CPU:

- copies the state of MPIE/UPIE back into MIE/UIE, and subsequently clears MPIE/UPIE. This means that if previously MPIE/UPIE was set, then, after MRET/URET, MIE/UIE will be set, thereby enabling interrupts globally.
- jumps to the address stored in mepc/uepc and resumes execution.

It is possible to perform software assisted nesting of interrupts inside an ISR as explained in Section 1.6.3 .

The below listed points outline the functional behavior of the controller:

- Only if an interrupt has priority higher or equal to the value in the threshold register, will it be reflected in INTPRI\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG .
- If an interrupt is visible in INTPRI\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG and has yet to be serviced, then it's possible to mask it (and thereby prevent the CPU from servicing it) by either lowering the value of its priority or increasing the global threshold.
- If an interrupt, visible in INTPRI\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG, is to be flushed (and prevented from being serviced at all), then it must be disabled (and cleared if it is of edge type).

## 1.6.3 Suggested Operation

## 1.6.3.1 Latency Aspects

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

## 1.6.3.2 Configuration Procedure

By default, interrupts are disabled globally, since the reset value of MIE bit in mstatus is 0. Software must set MIE=1 after initialization of the interrupt stack (including setting mtvec to the interrupt vector address) is done.

The threshold value for external interrupts in INTPRI\_CORE0\_CPU\_INT\_THRESH\_REG is 0 by default. For priority based masking of interrupts this could be initialized to 1 after CPU comes out of reset. That way all interrupt sources which have default 0 priority are masked.

During normal execution, if an external interrupt n is to be enabled, the below sequence may be followed:

1. save the state of MIE and clear MIE to 0
2. depending upon the type of the interrupt (edge/level), set/unset the nth bit of INTPRI\_CORE0\_CPU\_INT\_TYPE\_REG
3. set the priority by writing a value to INTPRI\_CORE0\_CPU\_INT\_PRI\_n\_REG in range 1 (lowest) to 15 (highest)
4. set the nth bit of INTPRI\_CORE0\_CPU\_INT\_ENABLE\_REG
5. execute FENCE instruction
6. restore the state of MIE

When one or more interrupts become pending, the CPU acknowledges (claims) the interrupt with the highest priority and jumps to the trap vector address corresponding to the interrupt's ID. Software implementation may read mcause to infer the type of trap (mcause(31) is 1 for interrupts and 0 for exceptions) and then the ID of the interrupt (mcause(4-0) gives ID of interrupt or exception). This inference may not be necessary if each entry in the trap vector are jump instructions to different trap handlers. Ultimately, the trap handler(s) will redirect execution to the appropriate ISR for this interrupt.

Upon entering into an ISR, software must toggle the nth bit of INTPRI\_CORE0\_CPU\_INT\_CLEAR\_REG if the interrupt is of edge type, or clear the source of the interrupt if it is of level type.

Software may also update the value of INTPRI\_CORE0\_CPU\_INT\_THRESH\_REG and program MIE=1 for allowing higher priority interrupts to preempt the current ISR (nesting), however, before doing so, all the state CSRs must be saved (mepc , mstatus , mcause, etc.) since they will get overwritten due to occurrence of such an interrupt. Later, when exiting the ISR, the values of these CSRs must be restored.

Finally, after the execution returns from the ISR back to the trap handler, MRET instruction is used to resume normal execution.

Later, if the n interrupt is no longer needed and needs to be disabled, the following sequence may be followed:

1. save the state of MIE and clear MIE to 0
2. check if the interrupt is pending in INTPRI\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG
3. set/unset the nth bit of INTPRI\_CORE0\_CPU\_INT\_ENABLE\_REG
4. if the interrupt is of edge type and was found to be pending in step 2 above, nth bit of INTPRI\_CORE0\_CPU\_INT\_CLEAR\_REG must be toggled, so that its pending status gets flushed
5. execute FENCE instruction
6. restore the state of MIE

Above is only a suggested scheme of operation. Actual software implementation may vary.

## 1.6.4 Registers

For the complete list of interrupt registers and configuration information, please refer to Section 10.4.2 and Section 10.5.2 respectively.

![Image](images/01_Chapter_1_img028_145205e7.png)

## 1.7 Core Local Interrupts (CLINT)

## 1.7.1 Overview

The CPU supports 4 local level-type interrupt sources with static priorities as shown below.

Table 1.7-1. Core Local Interrupt (CLINT) Sources

|   ID | Description               |   Priority |
|------|---------------------------|------------|
|    0 | U mode software interrupt |          1 |
|    3 | M mode software interrupt |          3 |
|    4 | U mode timer interrupt    |          0 |
|    7 | M mode timer interrupt    |          2 |

These interrupt sources have reserved IDs and fixed priorities which cannot be masked via the interrupt controller threshold registers for either modes.

Two of these interrupts (0 and 4) are by-default delegated to U mode as per the reset values of corresponding bits in mideleg CSR.

It must be noted that regardless of the fixed priority of CLINT interrupts, pending external interrupt sources always have higher priority over CLINT sources.

## 1.7.2 Features

- 4 local level-type interrupt sources with static priorities and IDs
- Memory mapped configuration and status registers
- Support for interrupts in both M and U modes
- 64-bit timer with interrupt with overflow flag
- Software interrupts

## 1.7.3 Software Interrupt

M and U mode software interrupt sources are controlled by setting or clearing the memory mapped registers MSIP and USIP, respectively.

The MSIE/USIE bit must be set in mie/uie CSR for enabling the interrupt at core level for a particular mode.

Pending state of this interrupt can be checked for either mode by reading the corresponding bit MSIP/USIP in mip/uip CSR.

Note that by default U mode software interrupt with ID 0 has the corresponding bit set in mideleg CSR. This bit can be toggled for using the interrupt in M mode instead. Similarly the bit corresponding to M mode software interrupt can be set for using it in U mode.

## 1.7.4 Timer Counter and Interrupt

The CPU provides a local memory-mapped 64-bit wide M mode timer counter register MTIME which has both read/write access. The timer counter can be enabled by setting the MTCE bit in MTIMECTL .

A read-only memory mapped UTIME is also provided for reading the timer counter from U mode, although it always reflects the same value as in the corresponding M mode counter MTIME register.

Timer interrupt for M/U mode is enabled by setting the MTIE/UTIE bit in MTIMECTL/UTIMECTL. Also, the MTIE/UTIE bit must be set in mie CSR for enabling the interrupt at core level for a particular mode.

Interrupt for M/U mode is asserted when the 64b timer value exceeds the 64b timer-compare value programmed in MTIMECMP/UTIMECMP .

Pending state of M/U mode timer interrupt is reflected as the read-only MTIP/UTIP bit in MTIMECTL/UTIMECTL .

For de-asserting the pending timer interrupt in M/U mode, either the MTIE/UTIE bit has to be cleared or the value of the MTIMECMP/UTIMECMP register needs to be updated.

Pending state of this interrupt can be checked at core level for either mode by reading the corresponding bit MTIP/UTIP in mip/uip .

Upon overflow of the 64b timer counter, the MTOF/UTOF bit in MTIMECTL/UTIMECTL gets set. It can be cleared after appropriate handling of the overflow situation.

Note that by default U mode timer interrupt with ID 4 has the corresponding bit set in mideleg CSR. This bit can be toggled for using the interrupt in M mode instead. Similarly the bit corresponding to M mode timer interrupt can be set for using it in U mode.

## 1.7.5 Register Summary

The addresses in this section are relative to CPU sub-system base address provided in Figure 5.2-1 in Chapter 5 System and Memory .

| Name     | Description                                                  | Address   | Access   |
|----------|--------------------------------------------------------------|-----------|----------|
| MSIP     | Core local machine software interrupt pending register       | 0x1800    | R/W      |
| MTIMECTL | Core local machine timer interrupt control/status regis ter | 0x1804    | R/W      |
| MTIME    | 64b core local timer counter value                           | 0x1808    | R/W      |
| MTIMECMP | 64b core local machine timer compare value                   | 0x1810    | R/W      |
| USIP     | Core local user software interrupt pending register          | 0x1C00    | R/W      |
| UTIMECTL | Core local user timer interrupt control/status register      | 0x1C04    | R/W      |
| UTIME    | Read-only 64b core local timer counter value                 | 0x1C08    | RO       |
| UTIMECMP | 64b core local user timer compare value                      | 0x1C10    | R/W      |

## 1.7.6 Register Description

The addresses in this section are relative to CPU subsystem base address provided in Figure 5.2-1 in Chapter 5 System and Memory .

## Register 1.25. MSIP (0x1800)

![Image](images/01_Chapter_1_img029_ddcfb31a.png)

MSIP Configures the pending status of the machine software interrupt.

- 0: Not pending
- 1: Pending
- (R/W)

## Register 1.26. MTIMECTL (0x1804)

![Image](images/01_Chapter_1_img030_644dd51d.png)

- MTCE Configures whether to enable the CLINT timer counter.
- 0: Not enable
- 1: Enable
- (R/W)
- MTIE Write 1 to enable the machine timer interrupt. (R/W)
- MTIP Represents the pending status of the machine timer interrupt.
- 0: Not pending
- 1: Pending
- (RO)
- MTOF Configures whether the machine timer overflows.
- 0: Not overflow
- 1: Overflow
- (R/W)

## Register 1.27. MTIME (0x1808)

![Image](images/01_Chapter_1_img031_42a3074d.png)

MTIME Configures the 64-bit CLINT timer counter value. (R/W)

## Register 1.28. MTIMECMP (0x1810)

![Image](images/01_Chapter_1_img032_cccb0c40.png)

MTIMECMP Configures the 64-bit machine timer compare value. (R/W)

## Register 1.29. USIP (0x1C00)

![Image](images/01_Chapter_1_img033_eebee3b5.png)

USIP Configures the pending status of the user software interrupt.

- 0: Not pending
- 1: Pending

(R/W)

## Register 1.30. UTIMECTL (0x1C04)

![Image](images/01_Chapter_1_img034_fa1df7ce.png)

- UTIE Write 1 to enable the user timer interrupt. (R/W)
- UTIP Represents the pending status of the user timer interrupt. (RO)
- UTOF Configures whether the user timer overflows.
- 0: Not overflow
- 1: Overflow

(R/W)

## Register 1.31. UTIME (0x1C08)

![Image](images/01_Chapter_1_img035_76a2044d.png)

UTIME Represents the read-only 64-bit CLINT timer counter value. (RO)

## Register 1.32. UTIMECMP (0x1C10)

![Image](images/01_Chapter_1_img036_d885b557.png)

UTIMECMP Configures the 64-bit user timer compare value. (R/W)

## 1.8 Physical Memory Protection

## 1.8.1 Overview

The CPU core includes a Physical Memory Protection (PMP) unit fully compliant to RISC-V Instruction Set Manual, Volume II: Privileged Architecture, Version 1.10, which can be used by software to set memory access privileges (read, write and execute permissions) for required memory regions. In addition to standard PMP checks, CPU core also implements custom Physical Memory Attributes (PMA) checkers to provide additional permission checks based on pre-defined attributes.

## 1.8.2 Features

The PMP unit can be used to restrict access to physical memory. It supports 16 regions and a minimum granularity of 4 bytes. Maximum supported NAPOT range is 4 GB.

## 1.8.3 Functional Description

Software can program the PMP unit's configuration and address registers in order to contain faults and support secure execution. PMP CSRs can only be programmed in machine-mode. Once the PMP unit is enabled by configuring PMP CSRs, write, read and execute permission checks are applied to all the accesses in user-mode as per programmed values of enabled 16 pmpcfgX and pmpaddrX registers (refer to the Register Summary).

By default, PMP grants permission to all accesses in machine-mode and revokes permission of all access in user-mode. This implies that it is mandatory to program the address range and valid permissions in pmpcfg and pmpaddr registers (refer to the Register Summary) for any valid access to pass through in user-mode. However, it is not required for machine-mode as PMP permits all accesses to go through by default. In cases where PMP checks are also required in machine-mode, software can set the lock bit of required PMP entry to enable permission checks on it. Once the lock bit is set, it can only be cleared through CPU reset.

When any instruction is being fetched from a memory region without execute permissions, an exception is generated at processor level and exception cause is set as instruction access fault in mcause CSR. Similarly, any load/store access without valid read/write permissions, will result in an exception generation with mcause updated as load access and store access fault respectively. In case of load/store access faults, violating address is captured in mtval CSR.

## 1.8.4 Register Summary

Below is a list of PMP CSRs supported by the CPU. These are only accessible from machine mode.

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

## 1.9 Physical Memory Attribute (PMA) Checker

## 1.9.1 Overview

CPU core also implements custom Physical Memory Attributes Checker (PMAC) to provide additional permission checks based on pre-defined memory type configured through custom CSRs.

## 1.9.2 Features

PMAC supports below features:

- Configurable memory type for defined memory regions
- Configurable attribute for defined memory regions

## 1.9.3 Functional Description

Software can program the PMAC unit's configuration and address registers in order to avoid faults due to access to invalid memory regions. PMAC CSRs can only be programmed in machine-mode. Once enabled, write, read and execute permission checks are applied to all the accesses irrespective of privilege mode as per programmed values of enabled 16 pma\_cfgX and pma\_addrX registers (refer to the Register Summary). Access to entries marked as invalid memory types will result in fetch fault or load/store fault exception, as the case may be.

Exception generation and handling for PMAC related faults will be handled in similar way to PMP checks. When any instruction is being fetched from a memory region configured as null or invalid memory region, an exception is generated at processor level and exception cause is set as instruction access fault in mcause CSR. Similarly, any load/store access to null or invalid memory region, will result in an exception generation with mcause updated as load access and store access fault respectively. In case of load/store access faults, violating address is captured in mtval CSR. For the PMAC entries configured as valid memory, the handling is same as for PMP checks.

A lock bit per entry is also provided in case software wants to disable programming of PMAC registers. Once the lock bit in any pma\_cfgX register is set, respective pma\_cfgX and pma\_addrX registers can not be programmed further, unless a CPU reset cycle is applied.

A 4-bit field in PMAC CSRs is also provided to define attributes for memory regions. These bits are not used internally by CPU core for any purpose. Based on address match, these attributes are provided on load/store interface as side-band signals and are used by cache controller block for its internal operation.

## 1.9.4 Register Summary

Below is a list of PMA CSRs supported by the CPU. These are only accessible from machine-mode:

| Name       | Description                                | Address   | Access   |
|------------|--------------------------------------------|-----------|----------|
| pma_cfg0   | Physical Memory Attribute configuration    | 0xBC0     | R/W      |
| pma_cfg1   | Physical Memory Attribute configuration    | 0xBC1     | R/W      |
| pma_cfg2   | Physical Memory Attribute configuration    | 0xBC2     | R/W      |
| pma_cfg3   | Physical Memory Attribute configuration    | 0xBC3     | R/W      |
| pma_cfg4   | Physical Memory Attribute configuration    | 0xBC4     | R/W      |
| pma_cfg5   | Physical Memory Attribute configuration    | 0xBC5     | R/W      |
| pma_cfg6   | Physical Memory Attribute configuration    | 0xBC6     | R/W      |
| pma_cfg7   | Physical Memory Attribute configuration    | 0xBC7     | R/W      |
| pma_cfg8   | Physical Memory Attribute configuration    | 0xBC8     | R/W      |
| pma_cfg9   | Physical Memory Attribute configuration    | 0xBC9     | R/W      |
| pma_cfg10  | Physical Memory Attribute configuration    | 0xBCA     | R/W      |
| pma_cfg11  | Physical Memory Attribute configuration    | 0xBCB     | R/W      |
| pma_cfg12  | Physical Memory Attribute configuration    | 0xBCC     | R/W      |
| pma_cfg13  | Physical Memory Attribute configuration    | 0xBCD     | R/W      |
| pma_cfg14  | Physical Memory Attribute configuration    | 0xBCE     | R/W      |
| pma_cfg15  | Physical Memory Attribute configuration    | 0xBCF     | R/W      |
| pma_addr0  | Physical Memory Attribute address register | 0xBD0     | R/W      |
| pma_addr1  | Physical Memory Attribute address register | 0xBD1     | R/W      |
| pma_addr2  | Physical Memory Attribute address register | 0xBD2     | R/W      |
| pma_addr3  | Physical Memory Attribute address register | 0xBD3     | R/W      |
| pma_addr4  | Physical Memory Attribute address register | 0xBD4     | R/W      |
| pma_addr5  | Physical Memory Attribute address register | 0xBD5     | R/W      |
| pma_addr6  | Physical Memory Attribute address register | 0xBD6     | R/W      |
| pma_addr7  | Physical Memory Attribute address register | 0xBD7     | R/W      |
| pma_addr8  | Physical Memory Attribute address register | 0xBD8     | R/W      |
| pma_addr9  | Physical Memory Attribute address register | 0xBD9     | R/W      |
| pma_addr10 | Physical Memory Attribute address register | 0xBDA     | R/W      |
| pma_addr11 | Physical Memory Attribute address register | 0xBDB     | R/W      |
| pma_addr12 | Physical Memory Attribute address register | 0xBDC     | R/W      |
| pma_addr13 | Physical Memory Attribute address register | 0xBDD     | R/W      |
| pma_addr14 | Physical Memory Attribute address register | 0xBDE     | R/W      |
| pma_addr15 | Physical Memory Attribute address register | 0xBDF     | R/W      |

## 1.9.5 Register Description

## Register 1.33. pma\_cfgX (0xBC0-0xBCF)

![Image](images/01_Chapter_1_img037_929f1fa6.png)

A Configures address type. The functionality is the same as pmpcfg register's A field. (R/W)

0x0: OFF

0x1: TOR

0x2: NA4

0x3: NAPOT

LOCK Configures whether to lock the corresponding pma\_cfgX and pma\_addrX. (R/W)

- 0: Not locked
- 1: Locked. The write permission to the corresponding pma\_cfgX and pma\_addrX is revoked.

It can only be unlocked by core reset.

ATTRIBUTE Configures the values to be driven on DRAM attribute ports. (R/W)

READ Configures read-permission for the corresponding region.

- 0: Read not allowed
- 1: Read allowed

(R/W)

WRITE Configures write-permission for the corresponding region.

- 0: Write not allowed
- 1: Write allowed

(R/W)

EXECUTE Configures execute-permission for the corresponding region.

- 0: Execution not allowed
- 1: Execution allowed

(R/W)

TYPE Configures region type. (R/W)

0x0: Invalid memory region (RWX access will be treated as 0, even if programmed to 1)

0x1: Valid memory region (Programmed RWX access will be applicable)

![Image](images/01_Chapter_1_img038_ed84a40e.png)

## Register 1.34. pma\_addrX (0xBD0-0xBDF)

![Image](images/01_Chapter_1_img039_513969b0.png)

![Image](images/01_Chapter_1_img040_8783c552.png)

| 31   | 0     |
|------|-------|
|      | Reset |

ADDR Configures address. The functionality is same as pmpaddr register. (R/W)

ESP32-C6 TRM (Version 1.1)

LP CORE

INTERFACE

DEBUG

DEBUG HOST

(GDB)

Debug Translator A

(OPENOCD)

## 1.10 Debug

ESP-RISC-V HP CORE COMPLEX

## 1.10.1 Overview

This section describes how to debug software running on HP and LP CPU cores. Debug support is provided through standard JTAG pins and complies to RISC-V External Debug Support Specification Version 0.13.

LP CORE

Figure 1.10-1 below shows the main components of External Debug Support.

DEBUG MODE

REG FILE

HW TRIGGER

CONTROL

Figure 1.10-1. Debug System Overview

![Image](images/01_Chapter_1_img041_fdf0d799.png)

The user interacts with the Debug Host (e.g. laptop), which is running a debugger (e.g. gdb). The debugger communicates with a Debug Translator (e.g. OpenOCD, which may include a hardware driver) to communicate with Debug Transport Hardware (e.g. ESP-Prog adapter). The Debug Transport Hardware connects the Debug Host to the ESP-RISC-V Core's Debug Transport Module (DTM) through standard JTAG interface. The DTM provides access to the Debug Module (DM) using the Debug Module Interface (DMI).

The DM allows the debugger to halt selected cores. Abstract commands provide access to GPRs (general

![Image](images/01_Chapter_1_img042_931bcce2.png)

DEBUG TRANSPORT

HARDWARE

purpose registers). The Program Buffer allows the debugger to execute arbitrary code on the core, which allows access to additional CPU core state. Alternatively, additional abstract commands can provide access to additional CPU core state. ESP-RISC-V core contains Trigger Module supporting 4 triggers. When trigger conditions are met, core will halt spontaneously and inform the debug module that they have halted.

System bus access block allows memory and peripheral register access without using the core.

## 1.10.2 Features

Basic debug functionality supports below features:

- Provides necessary information about the implementation to the debugger.
- Allows the CPU core to be halted and resumed.
- CPU core registers (including CSRs) can be read/written by debugger.
- CPU can be debugged from the first instruction executed after reset.
- CPU core can be reset through debugger.
- CPU can be halted on software breakpoint (planted breakpoint instruction).
- Hardware single-stepping.
- Execute arbitrary instructions in the halted CPU by means of the program buffer. 16-word program buffer is supported.
- System bus access is supported through word aligned address access.
- Supports four Hardware Triggers (can be used as breakpoints/watchpoints) as described in Section 1.11 .
- Supports LP core debug.
- Supports cross-triggering between HP and LP core.

## 1.10.3 Functional Description

As mentioned earlier, Debug Scheme conforms to RISC-V External Debug Support Specification Version 0.13. Please refer to the specification for functional operation details.

## 1.10.4 JTAG Control

Standard JTAG interface is the only way for DTM to access DM. The hardware provides two JTAG methods: PAD\_to\_JTAG and USB\_to\_JTAG.

- PAD\_to\_JTAG : means that the JTAG's signal source comes from IO.
- USB\_to\_JTAG : means that the JTAG's signal source comes from USB Serial/JTAG Controller.

Which JTAG method to use depends on many factors. The following table shows the configuration method.

|   Temporary disable JTAG 3 , 4 | EFUSE_DIS_ USB_JTAG 4   | EFUSE_DIS_ USB_SERIAL_ JTAG 4   | EFUSE_DIS_ PAD_JTAG 4   | EFUSE_JTAG_ SEL_ENABLE 4   | Strapping Pin GPIO15 5   | USB JTAG Status   | PAD JTAG Status   |
|--------------------------------|-------------------------|---------------------------------|-------------------------|----------------------------|--------------------------|-------------------|-------------------|
|                              0 | 0                       | 0                               | 0                       | 0                          | x 2                      | Available 1       | Unavailable 1     |
|                              0 | 0                       | 0                               | 0                       | 1                          | 1                        | Available         | Unavailable       |
|                              0 | 0                       | 0                               | 0                       | 1                          | 0                        | Unavailable       | Available         |
|                              0 | 0                       | 1                               | 0                       | x                          | x                        | Unavailable       | Available         |
|                              0 | 1                       | 0                               | 0                       | x                          | x                        | Unavailable       | Available         |
|                              0 | 1                       | 1                               | 0                       | x                          | x                        | Unavailable       | Available         |
|                              0 | 0                       | 0                               | 1                       | x                          | x                        | Available         | Unavailable       |
|                              0 | 0                       | 1                               | 1                       | x                          | x                        | Unavailable       | Unavailable       |
|                              0 | 1                       | 0                               | 1                       | x                          | x                        | Unavailable       | Unavailable       |
|                              0 | 1                       | 1                               | 1                       | x                          | x                        | Unavailable       | Unavailable       |
|                              1 | x                       | x                               | x                       | x                          | x                        | Unavailable       | Unavailable       |

## Note:

1. Available: the corresponding JTAG function is available. Unavailable: the corresponding JTAG function is not available.
2. x: do not care.
3. "Temporary disable JTAG" means that if there are an even number of bits "1" in EFUSE\_SOFT\_DIS\_JTAG[2:0], the JTAG function is turned on (the corresponding value in the table is 1), otherwise it is turned off (the corresponding value in the table is 0). However, under certain special conditions of the HMAC Accelerator in ESP32-C6, the JTAG function may be turned on even if there is an odd number of bits "1" in EFUSE\_SOFT\_DIS\_JTAG[2:0]. For information on how HMAC affects JTAG functionality, please refer to Chapter HMAC Accelerator .
4. Please refer to Chapter eFuse Controller to get more information about eFuse.
5. Please refer to Chip Boot Control to get more information about the strapping pin GPIO15.

## 1.10.5 Register Summary

Below is the list of Debug CSRs supported by ESP-RISC-V CPU core:

| Name      | Description              | Address   | Access   |
|-----------|--------------------------|-----------|----------|
| dcsr      | Debug Control and Status | 0x7B0     | R/W      |
| dpc       | Debug PC                 | 0x7B1     | R/W      |
| dscratch0 | Debug Scratch Register 0 | 0x7B2     | R/W      |
| dscratch1 | Debug Scratch Register 1 | 0x7B3     | R/W      |

All the debug module registers are implemented in conformance to the specification RISC-V External Debug Support Version 0.13. Please refer to it for more details.

## 1.10.6 Register Description

Below are the details of Debug CSRs supported by ESP-RISC-V core:

Register 1.35. dcsr (0x7B0)

![Image](images/01_Chapter_1_img043_de994545.png)

xdebugver Represents the debug version.

- 4: External debug support exists (RO)

ebreakm When 1, ebreak instructions in Machine Mode enter Debug Mode. (R/W)

ebreaku When 1, ebreak instructions in User/Application Mode enter Debug Mode. (R/W)

stopcount This feature is not implemented. Debugger will always read this bit as 0. (RO)

stoptime This feature is not implemented. Debugger will always read this bit as 0. (RO)

cause Explains why Debug Mode was entered. When there are multiple reasons to enter Debug Mode in a single cycle, the cause with the highest priority number is the one written.

- 1: An ebreak instruction was executed. (priority 3)
- 2: The Trigger Module caused a halt. (priority 4)
- 3: haltreq was set. (priority 2)
- 4: The CPU core single stepped because step was set. (priority 1)
- Other values are reserved for future use.

(RO)

- step When set and not in Debug Mode, the core will only execute a single instruction and then enter Debug Mode.

If the instruction does not complete due to an exception, the core will immediately enter Debug Mode before executing the trap handler, with appropriate exception registers set.

Setting this bit does not mask interrupts. This is a deviation from the RISC-V External Debug Support Specification Version 0.13.

(R/W)

- prv Contains the privilege level the core was operating in when Debug Mode was entered. A debugger can change this value to change the core's privilege level when exiting Debug Mode. Only 0x3 (machine mode) and 0x0 (user mode) are supported. (R/W)

## Register 1.36. dpc (0x7B1)

![Image](images/01_Chapter_1_img044_c0c1b026.png)

![Image](images/01_Chapter_1_img045_e1f65172.png)

dpc Upon entry to debug mode, dpc is written with the virtual address of the instruction that encountered the exception. When resuming, the CPU core's PC is updated to the virtual address stored in dpc. A debugger may write dpc to change where the CPU resumes. (R/W)

## Register 1.37. dscratch0 (0x7B2)

![Image](images/01_Chapter_1_img046_b0727e93.png)

dscratch0 Used by Debug Module internally. (R/W)

## Register 1.38. dscratch1 (0x7B3)

![Image](images/01_Chapter_1_img047_918233ff.png)

dscratch1 Used by Debug Module internally. (R/W)

## 1.11 Hardware Trigger

## 1.11.1 Features

Hardware Trigger module provides breakpoint and watchpoint capability for debugging. It includes the following features:

- 4 independent trigger units
- each unit can be configured for matching the address of program counter or load-store accesses
- can preempt execution by causing breakpoint exception
- can halt execution and transfer control to debugger
- support NAPOT (naturally aligned power-of-two regions) address encoding

## 1.11.2 Functional Description

The Hardware Trigger module provides four CSRs, which are listed under Section register summary. Among these, tdata1 and tdata2 are abstract CSRs, which means they are shadow registers for accessing internal registers for each of the four trigger units, one at a time.

To choose a particular trigger unit write the index (0-3) of that unit into tselect CSR. When tselect is written with a valid index, the abstract CSRs tdata1 and tdata2 are automatically mapped to reflect internal registers of that trigger unit. Each trigger unit has two internal registers, namely mcontrol and maddress, which are mapped to tdata1 and tdata2, respectively.

Writing larger than allowed indexes to tselect will clip the written value to the largest valid index, which can be read back. This property may be used for enumerating the number of available triggers during initialization or when using a debugger.

Since software or debugger may need to know the type of the selected trigger to correctly interpret tdata1 and tdata2, the 4 bits (31-28) of tdata1 encodes the type of the selected trigger. This type field is read-only and always provides a value of 0x2 for every trigger, which stands for match type trigger, hence, it is inferred that tdata1 and tdata2 are to be interpreted as mcontrol and maddress. The information regarding other possible values can be found in the specification RISC-V External Debug Support Version 0.13, but this trigger module only supports type 0x2.

Once a trigger unit has been chosen by writing its index to tselect, it will become possible to configure it by setting the appropriate bits in mcontrol CSR (tdata1) and writing the target address to maddress CSR (tdata2).

Each trigger unit can be configured to either cause breakpoint exception or enter debug mode, by writing to the action field of mcontrol. This bit can only be written from debugger, thus by default a trigger, if enabled, will cause breakpoint exception.

mcontrol for each trigger unit has a hit bit which may be read, after CPU halts or enters exception, to find out if this was the trigger unit that fired. This bit is set as soon as the corresponding trigger fires, but it has to be manually cleared before resuming operation. Although, failing to clear it does not affect normal execution in any way.

Each trigger unit only supports match on address, although this address could either be that of a load/store access or the virtual address of an instruction. The address and size of a region are specified by writing to maddress (tdata2) CSR for the selected trigger unit. Larger than 1 byte region sizes are specified through NAPOT (naturally aligned power-of-two) encoding (see Table 1.11-1) and enabled by setting match bit in mcontrol. Note that for NAPOT encoded addresses, by definition, the start address is constrained to be aligned to (i.e. an integer multiple of) the region size.

Table 1.11-1. NAPOT encoding for maddress

| maddress(31-0)   | Start Address    | Size (bytes)   |
|------------------|------------------|----------------|
| aaa...aaaaaaaaa0 | aaa...aaaaaaaaa0 | 2              |
| aaa...aaaaaaaa01 | aaa...aaaaaaaa00 | 4              |
| aaa...aaaaaaa011 | aaa...aaaaaaa000 | 8              |
| aaa...aaaaaa0111 | aaa...aaaaaa0000 | 16             |
| ....             | ....             | ....           |
| a01...1111111111 | a00...0000000000 | 2 31           |

tcontrol CSR is common to all trigger units. It is used for preventing triggers from causing repeated exceptions in machine-mode while execution is happening inside a trap handler. This also disables breakpoint exceptions inside ISRs by default, although, it is possible to manually enable this right before entering an ISR, for debugging purposes. This CSR is not relevant if a trigger is configured to enter debug mode.

## 1.11.3 Trigger Execution Flow

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

Note: If two different triggers fire at the same time, one with action = 0 and another with action = 1, then hart is halted and enters debug mode.

## 1.11.4 Register Summary

Below is a list of Trigger Module CSRs supported by the CPU. These are only accessible from machine-mode.

| Name     | Description             | Address   | Access   |
|----------|-------------------------|-----------|----------|
| tselect  | Trigger Select Register | 0x7A0     | R/W      |
| tdata1   | Trigger Abstract Data 1 | 0x7A1     | R/W      |
| tdata2   | Trigger Abstract Data 2 | 0x7A2     | R/W      |
| tcontrol | Global Trigger Control  | 0x7A5     | R/W      |

## 1.11.5 Register Description

Register 1.39. tselect (0x7A0)

![Image](images/01_Chapter_1_img048_6252aff3.png)

tselect Configures the index (0-3) of the selected trigger unit. (R/W)

## Register 1.40. tdata1 (0x7A1)

![Image](images/01_Chapter_1_img049_982a4194.png)

- type Represents the trigger type. This field is reserved since only match type (0x2) triggers are supported. (RO)

dmode This is set to 1 if a trigger is being used by the debugger.

- 0: Both Debug and M mode can write the tdata1 and tdata2 registers at the selected tselect.
- 1: Only Debug Mode can write the tdata1 and tdata2 registers at the selected tselect. Writes from other modes are ignored.

Note: Only writable from debug mode.

(R/W)

- data Configures the abstract tdata1 content. This will always be interpreted as fields of mcontrol since only match type (0x2) triggers are supported. (R/W)

![Image](images/01_Chapter_1_img050_a4bcac64.png)

## Register 1.41. tdata2 (0x7A2)

tdata2

![Image](images/01_Chapter_1_img051_c05f33c8.png)

tdata2 Configures the abstract tdata2 content. This will always be interpreted as maddress since only match type (0x2) triggers are supported. (R/W)

## Register 1.42. tcontrol (0x7A5)

![Image](images/01_Chapter_1_img052_24551384.png)

mpte Configures whether to enable the machine mode previous trigger.

When CPU is taking a machine mode trap, the value of mte is automatically pushed into this.

When CPU is executing MRET, its value is popped back into mte, so this becomes 0.

(R/W)

- mte Configures whether to enable the machine mode trigger.

When CPU is taking a machine mode trap, its value is automatically pushed into mpte, so this becomes 0 and triggers with action=0 are disabled globally.

When CPU is executing MRET, the value of mpte is automatically popped back into this. (R/W)

## Register 1.43. mcontrol (0x7A1)

![Image](images/01_Chapter_1_img053_a8fd8dbd.png)

dmode Same as dmode in tdata1. (RW *)

- hit This is found to be 1 if the selected trigger had fired previously. This bit is to be cleared manually. (R/W)
- action Configures the selected trigger to perform one of the available actions when firing. Valid options are:

0x0: cause breakpoint exception.

0x1: enter debug mode (only valid when dmode = 1)

Note: Writing an invalid value will set this to the default value 0x0.

(R/W)

- match Configures the selected trigger to perform one of the available matching operations on a data/instruction address. Valid options are:

0x0: exact byte match, i.e. address corresponding to one of the bytes in an access must match the value of maddress exactly.

0x1: NAPOT match, i.e. at least one of the bytes of an access must lie in the NAPOT region specified in maddress .

Note: Writing a larger value will clip it to the largest possible value 0x1. (R/W)

- m Set this for enabling selected trigger to operate in machine mode. (R/W)
- u Set this for enabling selected trigger to operate in user mode. (R/W)
- execute Set this for configuring the selected trigger to fire right before an instruction with matching virtual address is executed by the CPU. (R/W)
- store Set this for configuring the selected trigger to fire right before a store operation with matching data address is executed by the CPU. (R/W)
- load Set this for configuring the selected trigger to fire right before a load operation with matching data address is executed by the CPU. (R/W)

![Image](images/01_Chapter_1_img054_98b1d8a9.png)

## Register 1.44. maddress (0x7A2)

![Image](images/01_Chapter_1_img055_e17b2172.png)

maddress Configures the address used by the selected trigger when performing match operation.

This is decoded as NAPOT when match=1 in mcontrol. (R/W)

## 1.12 Trace

## 1.12.1 Overview

In order to support non-intrusive software debug, the CPU core provides an instruction trace interface which provides relevant information for offline debug purpose. This interface provides relevant information to Trace Encoder block, which compresses the information and stores in memory allocated for it. Software decoders can read this information from trace memory without interrupting the CPU core and re-generate the actual program execution by the CPU core.

## 1.12.2 Features

The CPU core supports instruction trace feature and provides below information to Trace Encoder as mandated in RISC-V Processor Trace Version 1.0:

- Number of instructions being retired.
- Occurrence of exception and interrupt along with cause and trap values.
- Current privilege level of hart.
- Instruction type of retired instructions for jumps, branches and return.
- Instruction address for instructions retired before and after program counter changes.

## 1.12.3 Functional Description

ESP-RISC-V CPU core implements mandatory instruction delta tracing, also known as branch tracing. It works by tracking execution from a known start address by sending information about deltas taken by a program. Deltas are typically introduced by jump, call, return, branch type instructions and also by interrupts and exceptions. All such deltas along with additional details about cause and actual instructions/addresses are communicated over high bandwidth instruction trace interface output from the core. Trace Encoder operates on the information on this trace interface and compresses the information for storage in memory for offline debug by a decoder. More information about the encoding is available in Chapter 2 RISC-V Trace Encoder (TRACE) .

The core does not have any internal registers to provide control over instruction trace interface. All register controls are available in 2 RISC-V Trace Encoder (TRACE) block.

## 1.13 Debug Cross-Triggering

## 1.13.1 Overview

In a multi-core system, when the debugging software is running on a given core, it is useful that the other cores do not change the state of the system. This requirement is addressed by synchronous halt and resume. It is important that halt/resume information is communicated as quickly as possible to other cores. So, it is better to do it based on chip infrastructure rather than commands through the debugger software running on the host.

## 1.13.2 Features

- Control register to enable or disable cross-trigger between cores
- Overriding the RunStall functionality of a core

## 1.13.3 Functional Description

Such a scheme has been implemented by providing a custom control register in the debug module. The register CORE\_XT\_EN implements a control bit to enable or disable cross-triggering mode. Once enabled, any core halted due to events such as hardware trigger and ebreak instructions will also result in halting of other cores without any intervention from the debugger. After halting of cores due to cross-trigger mode, it is not possible to resume without debugger intervention. The debugger has to connect to all cores and resume each core synchronously. Please note, debug cross trigger also halts any core which is stalled due to RunStall functionality.

## 1.13.4 Register Summary

Below is a required control register implemented inside debug module.

| Name       | Description               | Address    | Access   |
|------------|---------------------------|------------|----------|
| CORE_XT_EN | Cross Triggering Control. | 0x20000900 | R/W      |

## 1.13.5 Register Description

Register 1.45. CORE\_XT\_EN (0x20000900)

![Image](images/01_Chapter_1_img056_e722e152.png)

- XT\_EN Configures whether to enable the cross-trigger mode.
- 0: Disable

1: Enable

(R/W)

## 1.14 Dedicated IO

## 1.14.1 Overview

Normally, GPIOs are an APB peripheral, which means that changes to outputs and reads from inputs can get stuck in write buffers or behind other transfers, and in general are slower because generally the APB bus runs at a lower speed than the CPU. As an alternative, the CPU core implements I/O processors specific CPU registers (CSRs) which are directly connected to the GPIO matrix or IO pads. As these registers can get accessed in one instruction, speed is fast.

## 1.14.2 Features

- 8 dedicated IOs directly mapped on GPIOs
- No latency for driving output ports
- Two CPU cycle latency for sensing input values

## 1.14.3 Functional Description

The CPU core has a set of 8 inputs and outputs (pin value + pin output enable). These input and output ports are directly connected to the GPIO matrix, through which they can be mapped on top-level pads. Please refer to Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) for more details.

The CPU implements three custom CSRs:

- GPIO\_IN is read-only and reflects the input value.
- GPIO\_OUT is R/W and reflects the output value for the GPIOs.
- GPIO\_OEN is R/W and reflects the output enable state for the GPIOs. It controls the pad direction. Programming high would mean the pad should be configured in output mode. Programming low means it should be configured in input mode.

## 1.14.4 Register Summary

Below is a list of custom dedicated IO CSRs implemented inside the core.

| Name         | Description        | Address   | Access   |
|--------------|--------------------|-----------|----------|
| cpu_gpio_oen | GPIO Output Enable | 0x803     | R/W      |
| cpu_gpio_in  | GPIO Input Value   | 0x804     | RO       |
| cpu_gpio_out | GPIO Output Value  | 0x805     | R/W      |

## 1.14.5 Register Description

## Register 1.46. cpu\_gpio\_oen (0x803)

![Image](images/01_Chapter_1_img057_edce550c.png)

CPU\_GPIO\_OEN Configures whether to enable GPIOn (n=0 ~ 21) output. CPU\_GPIO\_OEN[7:0] correspond to output enable signals cpu\_gpio\_out\_oen[7:0] in Table 7.11-1 Peripheral Signals via GPIO Matrix. CPU\_GPIO\_OEN value matches that of cpu\_gpio\_out\_oen. CPU\_GPIO\_OEN is the enable signal of CPU\_GPIO\_OUT .

0: Disable GPIO output

1: Enable GPIO output

(R/W)

## Register 1.47. cpu\_gpio\_in (0x804)

![Image](images/01_Chapter_1_img058_f648aaee.png)

CPU\_GPIO\_IN Represents GPIOn (n=0 ~ 21) input value. It is a CPU CSR to read input value (1=high, 0=low) from SoC GPIO pin.

CPU\_GPIO\_IN[7:0] correspond to input signals cpu\_gpio\_in[7:0] in Table 7.11-1 Peripheral Signals via GPIO Matrix .

CPU\_GPIO\_IN[7:0] can only be mapped to GPIO pins through GPIO matrix. For details please refer to Section 7.4 in Chapter IO MUX and GPIO Matrix (GPIO, IO MUX) . (RO)

## Register 1.48. cpu\_gpio\_out (0x805)

![Image](images/01_Chapter_1_img059_e738f914.png)

CPU\_GPIO\_OUT Configures GPIOn (n=0 ~ 21) output value. It is a CPU CSR to write value (1=high, 0=low) to SoC GPIO pin. The value takes effect only when CPU\_GPIO\_OEN is set.

CPU\_GPIO\_OUT[7:0] correspond to output signals cpu\_gpio\_out[7:0] in Table 7.11-1 Peripheral Signals via GPIO Matrix .

CPU\_GPIO\_OUT[7:0] can only be mapped to GPIO pins through GPIO matrix. For details please refer to Section 7.5 in Chapter IO MUX and GPIO Matrix (GPIO, IO MUX) . (R/W)

## 1.15 Atomic (A) Extension

## 1.15.1 Overview

Support for atomic (A) extension is available in compliance with the RISC-V ISA Manual Volume I: Unprivileged ISA Version 2.2, with an emphasis to guarantee forward progress, i.e. any situation that may cause data memory lock for an indefinite amount of time is prevented by their very functionality.

The atomic instructions currently ignore the aq (acquire) and rl (release) bits as they are irrelevant to the current architecture in which memory ordering is always guaranteed.

## 1.15.2 Functional Description

## 1.15.2.1 Load Reserve (LR.W) Instruction

The LR.W instruction simply locks a 32-bit aligned memory address to which the load access is being performed. Once a 4-byte memory region is locked, it will remain locked, i.e. other harts won't be able to access this same memory location, until any of the following scenarios is encountered during execution:

- any load operation
- any store operation
- any interrupts/exceptions
- backward jump/taken backward branch
- JALR
- ECALL/EBREAK/MRET/URET
- FENCE/FENCE.I
- debug mode
- critical section exceeding 64 bytes
- data address in SC.W instruction not matching that in LR.W instruction

If any of the above happens, except SC.W, the memory lock will be released immediately. If an SC instruction is encountered instead, the lock will be released eventually (not immediately) in the manner described in Section 1.15.2.2 .

If a misaligned address is encountered, it will cause an exception with mcause = 6.

## 1.15.2.2 Store Conditional (SC.W) Instruction

The SC.W instruction first checks if the memory lock is still valid, and the address is the same as specified during the last LR.W instruction. If so, only then will it perform the store to memory, and later release the lock as soon as it gets an acknowledgement of operation completion from the memory.

On the other hand, if the lock is found to have been invalidated (due to any of the situations as described in Section 1.15.2.1), it will set a fail code (currently always 1) in the destination register rd.

If a misaligned address is encountered, it will cause an exception with mcause = 6.

## 1.15.2.3 AMO Instructions

An AMO instruction executes in 3 steps:

1. Read data from memory address given by rs1, and save it to destination register rd.
2. Combine the data in rd and rs2 according to the operation type and keep the result for Step 3 below.
3. Write the result obtained in Step 2 above to memory address given by rs1.

There are 9 different AMO operations: SWAP, ADD, AND, OR, XOR, MAX, MIN, MAXU and MINU.

During this whole process, the memory address is kept locked from being accessed by other harts. If a misaligned address is encountered, it will cause an exception with mcause = 6.

For AMO operations both load and store access faults (PMP/PMA) are checked in the 1st step itself. For such cases mcause = 7.

![Image](images/01_Chapter_1_img060_e66afdee.png)
