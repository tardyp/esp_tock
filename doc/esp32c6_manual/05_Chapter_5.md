---
chapter: 5
title: "Chapter 5"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 5

## System and Memory

## 5.1 Overview

ESP32-C6 is an ultra-low power and highly-integrated system that integrates:

- a high-performance 32-bit RISC-V single-core processor (HP CPU), four-stage pipeline, clock frequency up to 160 MHz
- a low-power 32-bit RISC-V single-core processor (LP CPU), two-stage pipeline, clock frequency up to 20 MHz

All internal memory, external memory, and peripherals are located on the HP CPU and LP CPU buses.

## 5.2 Features

## · Address Space

- – 832 KB of internal memory address space accessed from the instruction bus or data bus
- – 832 KB of peripheral address space
- – 16 MB of external memory virtual address space accessed from the instruction bus or the data bus
- – 512 KB of internal DMA address space
- Internal Memory
- – 320 KB internal ROM
- – 512 KB HP SRAM
- – 16 KB LP SRAM
- External Memory
- – Supports up to 16 MB external flash
- Peripheral Space
- – 51 modules/peripherals in total
- GDMA
- – 8 GDMA-supported modules/peripherals

Figure 5.2-1 illustrates the system structure and address mapping.

MMU

External

Memory

Can not be accessed by LP CPU

Not available for use

## Note:

- The range of addresses available in the address space may be larger than the actual available memory of a particular type.
- For CPU Sub-system, please refer to Chapter 1 High-Performance CPU .

## 5.3 Functional Description

## 5.3.1 Address Mapping

All the non-reserved addresses are accessible by the instruction bus and the data bus, that is, the instruction bus and the data bus access the same address space.

Both data bus and instruction bus of the HP CPU and LP CPU are little-endian. The HP CPU and LP CPU can access data via the data bus using single-byte, double-byte, and 4-byte alignment.

## The CPU can:

- directly access the internal memory via both data bus and instruction bus.
- (for HP CPU only) directly access the external memory which is mapped into the address space via cache.
- directly access modules/peripherals via data bus.

HP CPU

0x2000\_0000

LP CPU

0x0000\_0000

Ox1FFF\_FFFF

0x2000\_0000

![Image](images/05_Chapter_5_img001_870131ba.png)

CPU Sub-system

Figure 5.2-1. System Structure and Address Mapping

Table 5.3-1 lists the address ranges on the data bus and instruction bus and their corresponding target memories.

Table 5.3-1. Memory Address Mapping

| Bus Type             | Boundary Address   | Boundary Address   | Size   | Target          |
|----------------------|--------------------|--------------------|--------|-----------------|
|                      | Low Address        | High Address       |        |                 |
|                      | 0x0000_0000        | 0x3FFF_FFFF        |        | Reserved        |
| Data/Instruction bus | 0x4000_0000        | 0x4004_FFFF        | 320 KB | ROM *           |
|                      | 0x4005_0000        | 0x407F_FFFF        |        | Reserved        |
| Data/Instruction bus | 0x4080_0000        | 0x4087_FFFF        | 512 KB | HP SRAM *       |
|                      | 0x4088_0000        | 0x41FF_FFFF        |        | Reserved        |
| Data/Instruction bus | 0x4200_0000        | 0x42FF_FFFF        | 16 MB  | External memory |
|                      | 0x4300_0000        | 0x4FFF_FFFF        |        | Reserved        |
| Data/Instruction bus | 0x5000_0000        | 0x5000_3FFF        | 16 KB  | LP SRAM *       |
|                      | 0x5000_4000        | 0x5FFF_FFFF        |        | Reserved        |
| Data/Instruction bus | 0x6000_0000        | 0x600C_FFFF        | 832 KB | Peripherals     |
|                      | 0x600D_0000        | 0xFFFF_FFFF        |        | Reserved        |

## 5.3.2 Internal Memory

ESP32-C6 consists of the following three types of internal memory:

- ROM (320 KB): The ROM is a read-only memory and can not be programmed. It contains the ROM code of some low-level system software and read-only data.
- HP SRAM (512 KB): The HP SRAM is a volatile memory that can be quickly accessed by the HP CPU or LP CPU (generally within a single HP CPU clock cycle for HP CPU).
- LP SRAM (16 KB): LP SRAM is also a volatile memory, however, in Deep-sleep mode, data stored in the LP SRAM will not be lost. The LP SRAM can be accessed by the HP CPU or LP CPU and is usually used to store program instructions and data that need to be kept in sleep mode.

## 1. ROM

This 320 KB ROM is a read-only memory, addressed by the HP CPU through the instruction bus or through the data bus via 0x4000\_0000 ~ 0x4004\_FFFF, as shown in Table 5.3-1 .

## 2. HP SRAM

This 512 KB HP SRAM is a read-and-write memory, accessed by the HP CPU or LP CPU through the instruction bus or through the data bus as shown in Table 5.3-1 .

## 3. LP SRAM

This 16 KB LP SRAM is a read-and-write memory, accessed by the HP CPU or LP CPU through the instruction bus or through the data bus via their shared address 0x5000\_0000 ~ 0x5000\_3FFF as shown in Table 5.3-1 .

LP SRAM can be accessed by the following modes:

- high-speed mode, i.e., the LP SRAM is accessed in HP CPU clock frequency. In this case:
- – HP CPU can access the LP SRAM without any latency.
- – But the latency of LP CPU accessing LP SRAM ranges from a few dozen to dozens of LP CPU cycles.
- low-speed mode, i.e., the LP SRAM is accessed in LP CPU clock frequency. In this case:
- – LP CPU can access the LP SRAM with zero cycle latency.
- – But the latency of HP CPU accessing LP SRAM ranges from a few dozen to dozens of HP CPU cycles.

You can switch the modes based on your application scenarios.

- If the LP CPU is not working, you can switch to high-speed mode to improve the access speed of the HP CPU.
- If the LP CPU is executing code in the LP SRAM, you can switch to the low-speed mode.

When the HP CPU is in sleep mode, you must switch to the low-speed mode.

Detailed configuration is as follows:

- Configure LP\_AON\_FAST\_MEM\_MUX\_SEL to select the mode needed:
- – 1: high-speed mode
- – 0: low-speed mode
- Set LP\_AON\_FAST\_MEM\_MUX\_SEL\_UPDATE to start mode switch.
- Read LP\_AON\_FAST\_MEM\_MUX\_SEL\_STATUS to check if mode switch is done:
- – 0: mode is switched
- – 1: mode is not switched

## 5.3.3 External Memory

ESP32-C6 supports SPI, Dual SPI, Quad SPI, and QPI interfaces that allow connection to external flash. ESP32-C6 also supports hardware manual encryption and automatic decryption based on XTS-AES algorithm to protect users' programs and data in the external flash.

## 5.3.3.1 External Memory Address Mapping

The HP CPU accesses the external memory via the cache. According to information inside the MMU (Memory Management Unit), the cache maps the HP CPU's address (0x4200\_0000 ~ 0x42FF\_FFFF) into a physical address of the external memory. Due to this address mapping, ESP32-C6 can address up to 16 MB external flash. Note that the instruction bus shares the same address space (16 MB) with the data bus to access the external memory.

## 5.3.3.2 Cache

As shown in Figure 5.3-1, ESP32-C6 has a read-only uniform cache which is four-way set-associative. Its size is 32 KB and its block size is 32 bytes. The cache is accessible by the instruction bus and the data bus at the same time, but can only respond to one of them at a time. When a cache miss occurs, the cache controller will initiate a request to the external memory.

Figure 5.3-1. Cache Structure

![Image](images/05_Chapter_5_img002_f9fc0c22.png)

## 5.3.3.3 Cache Operations

ESP32-C6 cache supports the following operations:

1. Invalidate: This operation is used to remove valid data in the cache. Once this operation is done, the deleted data is stored only in the external memory. If the HP CPU wants to access the data again, it needs to access the external memory. There are two types of invalidate operation: Invalidate-All and Manual-Invalidate. Manual-Invalidate is performed only on data in the specified area in the cache, while Invalidate-All is performed on all data in the cache.
2. Preload: This operation is to load instructions and data into the cache in advance. The minimum unit of preload-operation is one block. There are two types of preload-operation: manual preload (Manual-Preload) and automatic preload (Auto-Preload). Manual-Preload means that the hardware prefetches a piece of continuous data according to the virtual address specified by the software. Auto-Preload means the hardware prefetches a piece of continuous data according to the current address where the cache hits or misses (depending on configuration).
3. Lock/Unlock: The lock operation is used to prevent the data in the cache from being easily replaced. There are two types of lock: prelock and manual lock. When prelock is enabled, the cache locks the data in the specified area when filling the missing data to cache memory, while the data outside the specified area will not be locked. When manual lock is enabled, the cache checks the data that is already in the cache memory and locks the data only if it falls in the specified area, and leaves the data outside the specified area unlocked. When there are missing data, the cache will replace the data in the unlocked way first, so the data in the locked way is always stored in the cache and will not be replaced. But when all ways within the cache are locked, the cache will replace data, as if it was not locked. Unlocking is the reverse of locking, except that it only can be done manually.

Please note that Manual-Invalidate operation only works on the unlocked data. If you expect to perform such operation on the locked data, please unlock them first.

## 5.3.4 GDMA Address Space

The General Direct Memory Access (GDMA) peripheral consisting of three TX channels and three RX channels provides Direct Memory Access (DMA) service, including:

- data transfers between different locations of internal memory
- data transfers between modules/peripherals and internal memory

GDMA uses the same addresses as the data bus to access HP SRAM, i.e., GDMA uses address range 0x4080\_0000 ~ 0x4087\_FFFF to access HP SRAM.

Eight modules/peripherals in ESP32-C6 work together with GDMA. As shown in Figure 5.3-2, eight vertical lines correspond to these eight modules/peripherals with GDMA function. The horizontal line represents a certain channel of GDMA (can be any channel), and the intersection of the vertical line and the horizontal line indicates that a module/peripheral has the ability to access the corresponding channel of GDMA. If there are multiple intersections on the same line, it means that these peripherals/modules can not enable the GDMA function at the same time.

Figure 5.3-2. Modules/peripherals that can work with GDMA

![Image](images/05_Chapter_5_img003_b5be3ddd.png)

These modules/peripherals can access any memory available to GDMA. For more information, please refer to Chapter 4 GDMA Controller (GDMA) .

## Note:

When accessing a memory via GDMA, a corresponding access permission is needed, otherwise this access may fail. For more information about permission control, please refer to Chapter 16 Permission Control (PMS) .

## 5.3.5 Modules/Peripherals Address Mapping

Table 5.3-2 lists all the modules/peripherals and their respective address ranges. Note that the address space of specific modules/peripherals is defined by "Boundary Address" (including both Low Address and High Address).

Table 5.3-2. Module/Peripheral Address Mapping

| Target                                              | Boundary Address   | Boundary Address   | Size (KB)   |
|-----------------------------------------------------|--------------------|--------------------|-------------|
|                                                     | Low Address        | High Address       |             |
| UART Controller 0 (UART0)                           | 0x6000_0000        | 0x6000_0FFF        | 4           |
| UART Controller 1 (UART1)                           | 0x6000_1000        | 0x6000_1FFF        | 4           |
| External Memory Encryption and Decryption (XTS_AES) | 0x6000_2000        | 0x6000_2FFF        | 4           |
| Reserved                                            | 0x6000_3000        | 0x6000_3FFF        |             |
| I2C Controller (I2C)                                | 0x6000_4000        | 0x6000_4FFF        | 4           |
| UHCI Controller (UHCI)                              | 0x6000_5000        | 0x6000_5FFF        | 4           |
| Remote Control Peripheral (RMT)                     | 0x6000_6000        | 0x6000_6FFF        | 4           |
| LED PWM Controller (LEDC)                           | 0x6000_7000        | 0x6000_7FFF        | 4           |
| Timer Group 0 (TIMG0)                               | 0x6000_8000        | 0x6000_8FFF        | 4           |
| Timer Group 1 (TIMG1)                               | 0x6000_9000        | 0x6000_9FFF        | 4           |
| System Timer (SYSTIMER)                             | 0x6000_A000        | 0x6000_AFFF        | 4           |
| Two-wire Automotive Interface 0 (TWAI0)             | 0x6000_B000        | 0x6000_BFFF        | 4           |
| I2S Controller (I2S)                                | 0x6000_C000        | 0x6000_CFFF        | 4           |
| Two-wire Automotive Interface 1 (TWAI1)             | 0x6000_D000        | 0x6000_DFFF        | 4           |
| Successive Approximation ADC (SAR ADC)              | 0x6000_E000        | 0x6000_EFFF        | 4           |
| USB Serial/JTAG Controller                          | 0x6000_F000        | 0x6000_FFFF        | 4           |
| Interrupt Matrix (INTMTX)                           | 0x6001_0000        | 0x6001_0FFF        | 4           |
| Reserved                                            | 0x6001_1000        | 0x6001_1FFF        |             |
| Pulse Count Controller (PCNT)                       | 0x6001_2000        | 0x6001_2FFF        | 4           |
| Event Task Matrix (SOC_ETM)                         | 0x6001_3000        | 0x6001_3FFF        | 4           |
| Motor Control PWM (MCPWM)                           | 0x6001_4000        | 0x6001_4FFF        | 4           |
| Parallel IO Controller (PARL_IO)                    | 0x6001_5000        | 0x6001_5FFF        | 4           |
| SDIO HINF *                                         | 0x6001_6000        | 0x6001_6FFF        | 4           |
| SDIO SLC *                                          | 0x6001_7000        | 0x6001_7FFF        | 4           |
| SDIO SLCHOST  *                                     | 0x6001_8000        | 0x6001_8FFF        | 4           |
| Reserved                                            | 0x6001_9000        | 0x6007_FFFF        |             |
| GDMA Controller (GDMA)                              | 0x6008_0000        | 0x6008_0FFF        | 4           |
| General Purpose SPI2 (GP-SPI2)                      | 0x6008_1000        | 0x6008_1FFF        | 4           |
| Reserved                                            | 0x6008_2000        | 0x6008_7FFF        |             |
| AES Accelerator (AES)                               | 0x6008_8000        | 0x6008_8FFF        | 4           |
| SHA Accelerator (SHA)                               | 0x6008_9000        | 0x6008_9FFF        | 4           |
| RSA Accelerator (RSA)                               | 0x6008_A000        | 0x6008_AFFF        | 4           |
| ECC Accelerator (ECC)                               | 0x6008_B000        | 0x6008_BFFF        | 4           |
| Digital Signature (DS)                              | 0x6008_C000        | 0x6008_CFFF        | 4           |

Cont’d on next page

Table 5.3-2 – cont’d from previous page

| Target                                             | Boundary Address Low Address   | High Address   | Size (KB)   |
|----------------------------------------------------|--------------------------------|----------------|-------------|
| HMAC Accelerator (HMAC)                            | 0x6008_D000                    | 0x6008_DFFF    | 4           |
| Reserved                                           | 0x6008_E000                    | 0x6008_FFFF    |             |
| IO MUX                                             | 0x6009_0000                    | 0x6009_0FFF    | 4           |
| GPIO Matrix                                        | 0x6009_1000                    | 0x6009_1FFF    | 4           |
| Memory Access Monitor (MEM_MONITOR) *              | 0x6009_2000                    | 0x6009_2FFF    | 4           |
| Reserved                                           | 0x6009_4000                    | 0x6009_4FFF    |             |
| HP System Register (HP_SYSREG)                     | 0x6009_5000                    | 0x6009_5FFF    | 4           |
| Power/Clock/Reset (PCR) Register                   | 0x6009_6000                    | 0x6009_6FFF    | 4           |
| Reserved                                           | 0x6009_7000                    | 0x6009_7FFF    |             |
| Trusted Execution Environment (TEE) Regis ter *   | 0x6009_8000                    | 0x6009_8FFF    | 4           |
| Access Permission Management Controller (HP_APM) * | 0x6009_9000                    | 0x6009_9FFF    | 4           |
| Reserved                                           | 0x6009_A000                    | 0x600A_FFFF    |             |
| Power Management Unit (PMU)                        | 0x600B_0000                    | 0x600B_03FF    | 1           |
| Low-power Clock/Reset Register (LP_CLKRST)         | 0x600B_0400                    | 0x600B_07FF    | 1           |
| eFuse Controller (EFUSE)                           | 0x600B_0800                    | 0x600B_0BFF    | 1           |
| RTC Timer (RTC_TIMER)                              | 0x600B_0C00                    | 0x600B_0FFF    | 1           |
| Low-power Always-on Register (LP_AON)              | 0x600B_1000                    | 0x600B_13FF    | 1           |
| Low-power UART (LP_UART)                           | 0x600B_1400                    | 0x600B_17FF    | 1           |
| Low-power I2C (LP_I2C)                             | 0x600B_1800                    | 0x600B_1BFF    | 1           |
| RTC Watch Dog Timer (RTC_WDT)                      | 0x600B_1C00                    | 0x600B_1FFF    | 1           |
| Low-power IO MUX (LP IO MUX)                       | 0x600B_2000                    | 0x600B_23FF    | 1           |
| I2C Analog Master (I2C_ANA_MST)                    | 0x600B_2400                    | 0x600B_27FF    | 1           |
| Low-power Peripheral (LPPERI)                      | 0x600B_2800                    | 0x600B_2BFF    | 1           |
| Low-power Analog Peripheral (LP_ANA_PERI)          | 0x600B_2C00                    | 0x600B_2FFF    | 1           |
| Reserved                                           | 0x600B_3000                    | 0x600B_33FF    |             |
| Low-power Trusted Execution Environment (LP_TEE) * | 0x600B_3400                    | 0x600B_37FF    | 1           |
| Low-power Access Permission Management (LP_APM) *  | 0x600B_3800                    | 0x600B_3BFF    | 1           |
| Reserved                                           | 0x600B_3C00                    | 0x600B_FFFF    |             |
| RISC-V Trace Encoder (TRACE)                       | 0x600C_0000                    | 0x600C_0FFF    | 4           |
| Reserved                                           | 0x600C_1000                    | 0x600C_1FFF    |             |
| DEBUG ASSIST (ASSIST_DEBUG) *                      | 0x600C_2000                    | 0x600C_2FFF    | 4           |
| Reserved                                           | 0x600C_3000                    | 0x600C_4FFF    |             |
| Interrupt Priority Register (INTPRI)               | 0x600C_5000                    | 0x600C_5FFF    | 4           |
| Reserved                                           | 0x600C_6000                    | 0x600C_FFFF    |             |

## Note:

As shown in the figure 5.2-1fi

- HP CPU can access all peripherals listed in the table 5.3-2 .
- LP CPU can access all peripherals listed in the table 5.3-2 except RISC-V Trace Encoder (TRACE) , DEBUG ASSIST (ASSIST\_DEBUG) and Interrupt Priority Register (INTPRI) .
