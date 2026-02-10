---
chapter: 15
title: "Chapter 15"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 15

## World Controller (WCL)

## 15.1 Introduction

ESP32-C3 allows users to allocate its hardware and software resources into Secure World (World0) and Non-secure World (World1), thus protecting resources from unauthorized access (read or write), and from malicious attacks such as malware, hardware-based monitoring, hardware-level intervention, and so on. CPUs can switch between Secure World and Non-secure World with the help of the World Controller.

By default, all resources in ESP32-C3 are shareable. Users can allocate the resources into two worlds by managing respective permission (For details, please refer to Chapter 14 Permission Control (PMS)). This chapter only introduces the World Controller and how CPUs can switch between worlds with the help of World Controller.

## 15.2 Features

ESP32-C3’s World Controller:

- Controls the CPUs to switch between the Secure World and Non-secure World
- Logs CPU's world switches

## 15.3 Functional Description

With the help of World Controller, we can allocate different resources to the Secure World and the Non-secure World:

- Secure World (World0):
- – Can access all peripherals and memories;
- – Performs all security related operations, such user authentication, secure communication, and data encryption and decryption, etc.
- Non-secure World (World1):
- – Can access some peripherals and memories;
- – Performs other operations, such as user operation and different applications, etc.

ESP32-C3's CPU and slave devices are both configurable with permission to either Secure World and/or Non-Secure World:

- CPU can be in either world at a particular time:

- – In Secure World: performs confidential operations;
- – In Non-secure World: performs non-confidential operations;
- – By default, CPU runs in Secure World after power-up, then can be programmed to switch between two worlds.
- All slave devices (including peripherals * and memories) can be configured to be accessible from the Secure World and/or the Non-secure World:
- – Secure World Access: this slave can be called from Secure World only, meaning it can be accessed only when CPU is in Secure World;
- – Non-secure World Access: this slave can be called from Non-secure World only, meaning it can be accessed only when CPU is in Non-secure World.
- – Note that a slave can be configured to be accessible from both Secure World and Non-secure World simultaneously.

For details, please refer to Chapter 14 Permission Control (PMS) .

## Note:

* World Controller itself is a peripheral, meaning it also can be granted with Secure World access and/or Non-secure World access, just like all other peripherals. However, to secure the world switch mechanism, World Controller should not be accessible from Non-secure world. Therefore, world controller should not be granted with Non-secure World access, preventing any modification to world controller from the Non-secure World.

## When CPU accesses any slaves:

1. First, CPU notifies the slave about its own world information;
2. Second, slave checks if it can be accessed by CPU based on the CPU's world information and its own world permission configuration.
- if allowed, then this slave responds to CPU;
- if not allowed, then this slave will not respond to CPU and trigger an interrupt.

In this way, the resources in the Secure World will not be illegally accessible by the Non-secure World in an unauthorized way.

Note that the following CPU interrupt-related CSR registers can only be written to in the Secure World, and can only be read but not written to in the Non-secure World, thus ensuring that interrupts can only be controlled by the Secure World.

| Name                       | Description                  | Address                    | Access                     |
|----------------------------|------------------------------|----------------------------|----------------------------|
| Machine Trap Setup CSRs    | Machine Trap Setup CSRs      | Machine Trap Setup CSRs    | Machine Trap Setup CSRs    |
| mstatus                    | Machine Mode Status          | 0x300                      | R/W                        |
| mtvec                      | Machine Trap Vector          | 0x305                      | R/W                        |
| Machine Trap Handling CSRs | Machine Trap Handling CSRs   | Machine Trap Handling CSRs | Machine Trap Handling CSRs |
| mscratch                   | Machine Scratch              | 0x340                      | R/W                        |
| mepc                       | Machine Trap Program Counter | 0x341                      | R/W                        |
| mcause                     | Machine Trap Cause           | 0x342                      | R/W                        |
| mtval                      | Machine Trap Value           | 0x343                      | R/W                        |

...

## 15.4 CPU's World Switch

Configuration

CPU can switch from Secure World to Non-secure World, and from Non-secure World to Secure World.

...

## 15.4.1 From Secure World to Non-secure World

Figure 15.4-1. Switching From Secure World to Non-secure World

![Image](images/15_Chapter_15_img001_4af144a4.png)

ESP32-C3's CPU only needs to complete the following steps to switch from Secure World to Non-secure World:

1. Write 0x2 to Register WCL\_CORE\_0\_WORLD\_PERPARE\_REG, indicating the CPU needs to switch to the Non-secure World.
2. Configure Register WCL\_CORE\_0\_World\_TRIGGER\_ADDR\_REG as the entry address to the Non-secure World, i.e., the address of the application in the Non-secure World that needs to be executed.
3. Write any value to Register WCL\_CORE\_0\_World\_UPDATE\_REG, indicating the configuration is done.

## Note:

- Registers WCL\_COREm\_WORLD\_PERPARE\_REG and WCL\_CORE\_0\_World\_TRIGGER\_ADDR\_REG can be configured in any order. Register WCL\_CORE\_0\_World\_UPDATE\_REG must be configured at last.

Afterwards, the World Controller keeps monitoring if CPU is executing the configured address of the application in Non-secure World. CPU switches to the Non-secure World once it executes the configured address, and executes the applications in the Non-secure World.

After configuration, the World Controller:

- Keeps monitoring until the CPU executes the configured address and switches to the Non-secure World.
- – Write any value to Register WCL\_CORE\_0\_World\_Cancel\_REG to cancel the World Controller configuration. After the cancellation, CPU will not switch to the Non-secure World even it executes to the configured address.
- The World Controller can only switch from the Secure World to Non-secure World once per configuration. Therefore, the World Controller needs to be configured again after each world switch to

prepare it for the next world switch.

However, it's worth noting that you cannot call the application in Non-secure world immediately after configuring the World Controller. For reasons such as CPU pre-indexed addressing and pipeline, it is possible that the CPU has already executed the application in Non-secure World before the World Controller configuration is effective, meaning the CPU runs unsecured application in the Secure World.

Therefore, you need to make sure the CPU only calls applications in the Non-secure world after the World Controller configuration takes effect. This can be guaranteed by declaring the applications in the Non-secure World as "noinline" .

## 15.4.2 From Non-secure World to Secure World

Figure 15.4-2. Switching From Non-secure World to Secure World

![Image](images/15_Chapter_15_img002_4539d4f9.png)

CPU can only switch from Non-secure World to Secure World via Interrupts (or Exceptions). After configuring the World Controller, the CPU can switch back from Non-secure World to Secure World upon the configured Interrupt trigger.

## Configuring the World Controller

The detailed steps to configure the World Controller to switch the CPU from Non-secure World to Secure World are described below:

1. Configure the entry base address of interrupts or exception WCL\_CORE\_0\_MTVEC\_BASE\_REG. After that, the World controller populates the monitored addresses for each entry as follows:
- Exception entry: WCL\_CORE\_0\_MTVEC\_BASE\_REG + 0x00
- Interrupt entries: WCL\_CORE\_0\_MTVEC\_BASE\_REG + 4* i (i = 1~31)

Note that this register must be configured to the mtvec CSR register of the CPU. When modifying the CPU's mtvec CSR registers, this register also must be updated. For details, please refer to Chapter 1 ESP-RISC-V CPU .

2. Configure Register WCL\_CORE\_0\_ENTRY\_CHECK\_REG to enable the monitoring of one or more certain entries (0: disable; 1: enable).
- Bit 0 controls the entry monitoring of exception
- Bit x controls the entry monitoring of interrupt Entry x (x = 1~31), respectively

Note that, once configured, register WCL\_CORE\_0\_ENTRY\_CHECK\_REG is always effective till it's disabled again, meaning you don't need to configure this register every time after each world switch.

3. Configure WCL\_CORE\_0\_MSTATUS\_MIE\_REG to enable updating the World Switch Log. Otherwise, this log will not be updated for world switches. For detailed information about the World Switch Log, see Section 15.5 .

## 15.5 World Switch Log

In actual use cases, CPU is switching between two worlds quite frequently and has to deal with nested interrupts. To be able to restore to the previous world, World Controller keeps a world switching log in a series of registers, which is called "World Switch Log Table".

## 15.5.1 Structure of World Switch Log Register

ESP32-C3's World Switch Log Table consists of 32 WCL\_CORE\_0\_STATUSTABLEn\_REG(n: 0-31) registers (see Figure 15.5-1). The Entry x, is logged in WCL\_CORE\_0\_STATUSTABLEx\_REG .

Figure 15.5-1. World Switch Log Register

![Image](images/15_Chapter_15_img003_81c304c8.png)

- WCL\_CORE\_0\_FROM\_WORLD\_n: logs the world information before the world switch.
- – 0: CPU was in Secure World
- – 1: CPU was in Non-secure World
- WCL\_CORE\_0\_FROM\_ENTRY\_n: logs the entry information before the world switch, in total of 6 bits.
- – 0~31: CPU is currently jumping from another interrupt/exception entry 0 ~ 31
- – 32: CPU was not at any interrupts monitored at any entry
- WCL\_CORE\_0\_CURRENT\_n: indicates if CPU is at the interrupt monitored at the current entry. When CPU is at the interrupt monitored at Entry x ,
- – WCL\_CORE\_0\_CURRENT\_x is updated to 1;
- – and the same field of all other entries are updated to 0.

## 15.5.2 How World Switch Log Registers are Updated

To explain this process, assuming:

1. At the beginning:
- CPU is running in the Non-secure World;
- Registers WCL\_CORE\_0\_STATUSTABLEn\_REG(n: 0-31) are all empty.
2. Then an interrupt occurs at Entry 9;
3. Then another interrupt with higher priority occurs at Entry 1;
4. Then the last interrupt with highest priority occurs at Entry 4.

The World Switch Log Table is updated as described below:

1. First, an interrupt occurs at Entry 9. At this time, CPU executes to the entry address of this interrupt. The World Switch Log Table is updated as described in Figure 15.5-2:

Figure 15.5-2. Nested Interrupts Handling - Entry 9

![Image](images/15_Chapter_15_img004_9931466c.png)

## At this time:

- WCL\_CORE\_0\_STATUSTABLE9\_REG
- – Field WCL\_CORE\_0\_FROM\_WORLD\_9 is updated to 1, indicating CPU was in Non-secure World before the interrupt;
- – Field WCL\_CORE\_0\_FROM\_ENTRY\_9 is updated to 32, indicating there was not any interrupt before this one;
- – Field WCL\_CORE\_0\_CURRENT\_9 is updated to 1, indicating the CPU is currently at the interrupt monitored at Entry 9.
- Other WCL\_CORE\_0\_STATUSTABLEn\_REG registers are not updated.
2. Then another interrupt with higher priority occurs at Entry 1. At this time, CPU executes to the entry address of this interrupt. The World Switch Log Table is updated again as described in Figure 15.5-3:

## At this time:

- WCL\_CORE\_0\_STATUSTABLE1\_REG
- – Field WCL\_CORE\_0\_FROM\_WORLD\_1 is updated to 0, indicating the CPU was in Secure World before this interrupt.
- – Field WCL\_CORE\_0\_FROM\_ENTRY\_1 is updated to 9, indicating the CPU was executing the interrupt at Entry 9.
- – Field WCL\_CORE\_0\_CURRENT\_1 is updated to 1, indicating CPU is currently at the interrupt monitored at Entry 1.
- WCL\_CORE\_0\_STATUSTABLE9\_REG
- – Field WCL\_CORE\_0\_CURRENT\_9 is updated to 0, indicating CPU is no longer at the interrupt monitored at Entry 9 (Instead, CPU is at the interrupt monitored at Entry 1 already).
- – Fields WCL\_CORE\_0\_FROM\_WORLD\_9 and WCL\_CORE\_0\_FROM\_ENTRY\_9 stay the same.
- Other WCL\_CORE\_0\_STATUSTABLEn\_REG registers are not updated.
3. Then the last interrupt with highest priority occurs at Entry 4. At this time, CPU executes to the entry address of interrupt 4. The World Switch Log Table is updated again as described in Figure 15.5-4:

Figure 15.5-4. Nested Interrupts Handling - Entry 4

![Image](images/15_Chapter_15_img005_ee20d416.png)

## At this time:

- WCL\_CORE\_0\_STATUSTABLE4\_REG

Figure 15.5-3. Nested Interrupts Handling - Entry 1

![Image](images/15_Chapter_15_img006_4ba68f69.png)

- – Field WCL\_CORE\_0\_FROM\_WORLD\_4 is updated to 0, indicating the CPU was in Secure World before this interrupt.
- – Field WCL\_CORE\_0\_FROM\_ENTRY\_4 is updated to 1, indicating the CPU was the interrupt at Entry 1.
- – Field WCL\_CORE\_0\_CURRENT\_4 is updated to 1, indicating the CPU is currently at the interrupt monitored an Entry 4.
- WCL\_CORE\_0\_STATUSTABLE1\_REG
- – Field WCL\_CORE\_0\_CURRENT\_1 is updated to 0, indicating the CPU is no longer at the interrupt monitored at Entry 1 (Instead CPU is at the interrupt monitored at Entry 4 already).
- – Fields WCL\_CORE\_0\_FROM\_WORLD\_1 and WCL\_CORE\_0\_FROM\_ENTRY\_1 are not updated.
- Other WCL\_CORE\_0\_STATUSTABLEn\_REG registers are not updated.

## 15.5.3 How to Read World Switch Log Registers

By reading World Switch Log Registers, we get to understand the information of previous world switches and nested interrupts, thus being able to restore to previous world.

Steps are described below: (See Figure 15.5-4 as an example):

1. Read Register WCL\_CORE\_0\_STATUSTABLE\_CURRENT\_REG, and understand CPU is now at the interrupt monitored at Entry 4.
2. Read 1 from Field WCL\_CORE\_0\_FROM\_ENTRY\_4, and understand the CPU was at an interrupt monitored at Entry 1.
3. Read 9 from Field WCL\_CORE\_0\_FROM\_ENTRY\_1, and understand the CPU was at an interrupt monitored at Entry 9.
4. Read 32 from WCL\_CORE\_0\_FROM\_ENTRY\_9, and understand CPU wasn't at any interrupt. Then read 1 from WCL\_CORE\_0\_FROM\_WORLD\_9, and understand CPU was in Non-secure World at the beginning.

## 15.5.4 Nested Interrupts

To support interrupt nesting, World controller provides additional configuration to update World Switch Log . See details in Section Programming Procedure below.

## 15.5.4.1 Programming Procedure

Handling the interrupt at Entry A:

1. Save context.
2. Configure WCL\_CORE\_0\_MSTATUS\_MIE\_REG register to enable updating the World Switch Log table.
- After entering the interrupt and exception vector, CPU will automatically turn off the global interrupt enable to avoid interrupt nesting. After saving the context, the global interrupt enable can be turned on again to respond to higher-level interrupts.
- The World Controller WCL\_CORE\_0\_MSTATUS\_MIE\_REG register also supports a similar feature of global interrupt enable. When any entry trigger is detected, WCL\_CORE\_0\_MSTATUS\_MIE\_REG will

be automatically cleared to 0, and software needs to be enabled again in the interrupt/exception service routine. This register should be configured before turning on the global interrupt enable.

3. Enable the global interrupt enable.
4. Execute the interrupt programs.
5. Disable CPU global interrupt enable.
6. Read Field WCL\_CORE\_0\_FROM\_ENTRY\_A for Entry A:
- 32: indicates all interrupts are handled, and return to a normal program,
6. (a) Update Field WCL\_CORE\_0\_CURRENT\_A of Entry A to 0, indicating the CPU is no longer at the interrupt monitored at Entry A .
7. (b) Go to Step 7 .
- 0~31: indicates the CPU returns to another interrupt monitored at Entry B ,
9. – Update the world switch register of Entry A:
* Update Field WCL\_CORE\_0\_CURRENT\_A to 0, indicating the CPU is no longer at the interrupt monitored at Entry A .
* Fields WCL\_CORE\_0\_FROM\_WORLD\_A and WCL\_CORE\_0\_FROM\_ENTRY\_A stay the same.
12. – Update the world switch register of Entry B:
* Update Field WCL\_CORE\_0\_CURRENT\_B to 1, indicating the CPU will return to Entry B .
7. Prepare to exit interrupt.
15. (a) Check if CPU needs to switch to the other world:
- If world switch not required, then go to Step 8 .
- If world switch required, then switch the CPU to the other world following instructions described in Section 15.4, then go to Step 8 .
8. Enable interrupts, restore context and exit.

## Note:

Steps 6 and 7 should not be interrupted by any interrupts. Therefore, users need to disable all the interrupts before these steps, and enable interrupts once done.

ESP32-C3 TRM (Version 1.3)

## 15.6 Register Summary

The addresses in this section are relative to the World Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                     | Description                                              | Address                                  | Access                                   |
|------------------------------------------|----------------------------------------------------------|------------------------------------------|------------------------------------------|
| WORLD1 to WORLD0 Configuration Registers | WORLD1 to WORLD0 Configuration Registers                 | WORLD1 to WORLD0 Configuration Registers | WORLD1 to WORLD0 Configuration Registers |
| WCL_Core_0_MTVEC_BASE_REG                | MTVEC configuration                                      | 0x0000                                   | R/W                                      |
| WCL_Core_0_MSTATUS_MIE_REG               | MSTATUS_MIE configuration                                | 0x0004                                   | R/W                                      |
| WCL_Core_0_ENTRY_CHECK_REG               | CPU entry check configuration                            | 0x0008                                   | R/W                                      |
| StatusTable Registers                    | StatusTable Registers                                    | StatusTable Registers                    | StatusTable Registers                    |
| WCL_Core_0_STATUSTABLEn_REG (n: 0-31)    | Entry n world switching status                           | 0x0040                                   | R/W                                      |
| WCL_Core_0_STATUSTABLE_CURRENT_REG       | Represetns the entry where the interrupt is currently at | 0x00E0                                   | R/W                                      |
| WORLD0 to WORLD1 Configuration Registers | WORLD0 to WORLD1 Configuration Registers                 | WORLD0 to WORLD1 Configuration Registers | WORLD0 to WORLD1 Configuration Registers |
| WCL_Core_0_World_TRIGGER_ADDR_REG        | CPU trigger address configuration                        | 0x0140                                   | RW                                       |
| WCL_Core_0_World_PREPARE_REG             | CPU world switching preparation configuration            | 0x0144                                   | R/W                                      |
| WCL_Core_0_World_UPDATE_REG              | CPU world switching update configuration                 | 0x0148                                   | WO                                       |
| WCL_Core_0_World_Cancel_REG              | CPU world switching cancel configuration                 | 0x014C                                   | WO                                       |
| WCL_Core_0_World_IRam0_REG               | CPU IBUS world info                                      | 0x0150                                   | R/W                                      |
| WCL_Core_0_World_DRam0_PIF_REG           | CPU DBUS and PIF bus world info                          | 0x0154                                   | R/W                                      |
| WCL_Core_0_World_Phase_REG               | CPU world switching readiness                            | 0x0158                                   | RO                                       |

## 15.7 Registers

The addresses in this section are relative to the World Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 15.1. WCL\_Core\_0\_MTVEC\_BASE\_REG (0x0000)

![Image](images/15_Chapter_15_img007_0999f62b.png)

WCL\_CORE\_0\_MTVEC\_BASE Configures the MTVEC base address, which should be kept consistent with the MTVEC in RISC-V. (R/W)

Register 15.2. WCL\_Core\_0\_MSTATUS\_MIE\_REG (0x0004)

![Image](images/15_Chapter_15_img008_09d16aef.png)

WCL\_CORE\_0\_MSTATUS\_MIE Write 1 to enable World Switch Log Table. Only when the bit is set, the world switching is recorded in the World Switch Log Table. This bit is cleared once CPU switches from the Non-secure World to Secure World. (R/W)

Register 15.3. WCL\_Core\_0\_ENTRY\_CHECK\_REG (0x0008)

![Image](images/15_Chapter_15_img009_994d6497.png)

WCL\_CORE\_0\_ENTRY\_CHECK Write 1 to enable CPU switching from Non-secure World to Secure world upon the monitored addresses. (R/W)

Register 15.4. WCL\_Core\_0\_STATUSTABLEn\_REG(n: 0-31) (0x0x0040+4*n)

![Image](images/15_Chapter_15_img010_2a2bfffa.png)

WCL\_CORE\_0\_FROM\_WORLD\_n Stores the world info before CPU entering entry n. (R/W) WCL\_CORE\_0\_FROM\_ENTRY\_n Stores the previous entry info before CPU entering entry n.(R/W) WCL\_CORE\_0\_CURRENT\_n Represents if the interrupt is at entry n. (R/W)

Register 15.5. WCL\_Core\_0\_STATUSTABLE\_CURRENT\_REG (0x00E0)

![Image](images/15_Chapter_15_img011_1863b33f.png)

WCL\_CORE\_0\_STATUSTABLE\_CURRENT Represents the entry where the interrupt is currently at. (R/W)

## Register 15.6. WCL\_Core\_0\_World\_TRIGGER\_ADDR\_REG (0x0140)

![Image](images/15_Chapter_15_img012_1eace5bd.png)

WCL\_CORE\_0\_WORLD\_TRIGGER\_ADDR Configures the entry address at which CPU switches from Secure World to Non-secure World. (RW)

![Image](images/15_Chapter_15_img013_439076b0.png)

![Image](images/15_Chapter_15_img014_64363aa0.png)
