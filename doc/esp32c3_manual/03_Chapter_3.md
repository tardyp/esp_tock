---
chapter: 3
title: "Chapter 3"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 3

## System and Memory

## 3.1 Overview

The ESP32-C3 is an ultra-low-power and highly-integrated system with a 32-bit RISC-V single-core processor with a four-stage pipeline that operates at up to 160 MHz. All internal memory, external memory, and peripherals are located on the CPU buses.

## 3.2 Features

## · Address Space

- – 792 KB of internal memory address space accessed from the instruction bus
- – 552 KB of internal memory address space accessed from the data bus
- – 836 KB of peripheral address space
- – 8 MB of external memory virtual address space accessed from the instruction bus
- – 8 MB of external memory virtual address space accessed from the data bus
- – 384 KB of internal DMA address space

## · Internal Memory

- – 384 KB of Internal ROM
- – 400 KB of Internal SRAM
- – 8 KB of RTC Memory
- External Memory
- – Supports up to 16 MB external flash
- Peripheral Space
- – 35 modules/peripherals in total
- GDMA
- – 7 GDMA-supported modules/peripherals

Figure 3.2-1 illustrates the system structure and address mapping.

Figure 3.2-1. System Structure and Address Mapping

![Image](images/03_Chapter_3_img001_9b124e36.png)

## Note:

- The address space with gray background is not available to users.
- The range of addresses available in the address space may be larger than the actual available memory of a particular type.

## 3.3 Functional Description

## 3.3.1 Address Mapping

Addresses below 0x4000\_0000 are accessed using the data bus. Addresses in the range of 0x4000\_0000 ~ 0x4FFF\_FFFF are accessed using the instruction bus. Addresses over and including 0x5000\_0000 are shared by the data bus and the instruction bus.

Both data bus and instruction bus are little-endian. The CPU can access data via the data bus using single-byte, double-byte, 4-byte alignment. The CPU can also access data via the instruction bus, but only in 4-byte aligned manner.

The CPU can:

![Image](images/03_Chapter_3_img002_cbb7112f.png)

- directly access the internal memory via both data bus and instruction bus;
- access the external memory which is mapped into the virtual address space via cache;
- directly access modules/peripherals via data bus.

Figure 3.2-1 lists the address ranges on the data bus and instruction bus and their corresponding target memory.

Some internal and external memory can be accessed via both data bus and instruction bus. In such cases, the CPU can access the same memory using multiple addresses.

## 3.3.2 Internal Memory

The ESP32-C3 consists of the following three types of internal memory:

- Internal ROM (384 KB): The Internal ROM of the ESP32-C3 is a Mask ROM, meaning it is strictly read-only and cannot be reprogrammed. Internal ROM contains the ROM code (software instructions and some software read-only data) of some low level system software.
- Internal SRAM (400 KB): The Internal Static RAM (SRAM) is a volatile memory that can be quickly accessed by the CPU (generally within a single CPU clock cycle).
- – A part of the SRAM can be configured to operate as a cache for external memory access.
- – Some parts of the SRAM can only be accessed via the CPU's instruction bus.
- – Some parts of the SRAM can be accessed via both the CPU's instruction bus and the CPU's data bus.
- RTC Memory (8 KB): The RTC (Real Time Clock) memory implemented as Static RAM (SRAM) thus is volatile. However, RTC memory has the added feature of being persistent in deep sleep (i.e., the RTC memory retains its values throughout deep sleep).
- – RTC FAST Memory (8 KB): RTC FAST memory can only be accessed by the CPU and can be generally used to store instructions and data that needs to persist across a deep sleep.

Based on the three different types of internal memory described above, the internal memory of the ESP32-C3 is split into three segments: Internal ROM (384 KB), Internal SRAM (400 KB), RTC FAST Memory (8 KB).

However, within each segment, there may be different bus access restrictions (e.g., some parts of the segment may only be accessible by the CPU's Data bus). Therefore, each some segments are also further divided into parts. Table 3.3-1 describes each part of internal memory and their address ranges on the data bus and/or instruction bus.

Table 3.3-1. Internal Memory Address Mapping

| Bus Type        | Boundary Address   | Boundary Address   | Size (KB)   | Target          |
|-----------------|--------------------|--------------------|-------------|-----------------|
|                 | Low Address        | High Address       |             |                 |
| Data bus        | 0x3FF0_0000        | 0x3FF1_FFFF        | 128         | Internal ROM 1  |
| Data bus        | 0x3FC8_0000        | 0x3FCD_FFFF        | 384         | Internal SRAM 1 |
| Instruction bus | 0x4000_0000        | 0x4003_FFFF        | 256         | Internal ROM 0  |
| Instruction bus | 0x4004_0000        | 0x4005_FFFF        | 128         | Internal ROM 1  |
| Instruction bus | 0x4037_C000        | 0x4037_FFFF        | 16          | Internal SRAM 0 |

Cont’d on next page

## Note:

All of the internal memories are managed by Permission Control module. An internal memory can only be accessed when it is allowed by Permission Control, then the internal memory can be available to the CPU. For more information about Permission Control, please refer to Chapter 14 Permission Control (PMS) .

## 1. Internal ROM 0

Internal ROM 0 is a 256 KB, read-only memory space, addressed by the CPU only through the instruction bus via 0x4000\_0000 ~ 0x4003\_FFFF, as shown in Table 3.3-1 .

## 2. Internal ROM 1

Internal ROM 1 is a 128 KB, read-only memory space, addressed by the CPU through the instruction bus via 0x4004\_0000 ~ 0x4005\_FFFF or through the data bus via 0x3FF0\_0000 ~ 0x3FF1\_FFFF in the same order, as shown in Table 3.3-1 .

This means, for example, address 04004\_0000 and 0x3FF0\_0000 correspond to the same word, 0x4004\_0004 and 0x3FF0\_0004 correspond to the same word, 0x4004\_0008 and 0x3FF0\_0008 correspond to the same word, etc (the same ordering applies for Internal SRAM 1).

## 3. Internal SRAM 0

Internal SRAM 0 is a 16 KB, read-and-write memory space, addressed by the CPU through the instruction bus via the range described in Table 3.3-1 .

This memory managed by Permission Control, can be configured as instruction cache to store cache instructions or read-only data of the external memory. In this case, the memory cannot be accessed by the CPU. For more information about Permission Control, please refer to Chapter 14 Permission Control (PMS) .

## 4. Internal SRAM 1

Internal SRAM 1 is a 384 KB, read-and-write memory space, addressed by the CPU through the data bus or instruction bus, in the same order, via the ranges described in Table 3.3-1 .

## 5. RTC FAST Memory

RTC FAST Memory is a 8 KB, read-and-write SRAM, addressed by the CPU through the data/instruction bus via the shared address 0x5000\_0000 ~ 0x5000\_1FFF, as described in Table 3.3-1 .

## 3.3.3 External Memory

ESP32-C3 supports SPI, Dual SPI, Quad SPI, and QPI interfaces that allow connection to multiple external flash. It supports hardware manual encryption and automatic decryption based on XTS\_AES to protect user programs and data in the external flash.

Table 3.3-1 – cont’d from previous page

| Bus Type             | Boundary Address   | Boundary Address   | Size (KB)   | Target          |
|----------------------|--------------------|--------------------|-------------|-----------------|
|                      | Low Address        | High Address       |             |                 |
|                      | 0x4038_0000        | 0x403D_FFFF        | 384         | Internal SRAM 1 |
| Data/Instruction bus | 0x5000_0000        | 0x5000_1FFF        | 8           | RTC FAST Memory |

## 3.3.3.1 External Memory Address Mapping

The CPU accesses the external memory via the cache. According to the MMU (Memory Management Unit) settings, the cache maps the CPU's address to the external memory's physical address. Due to this address mapping, the ESP32-C3 can address up to 16 MB external flash.

Using the cache, ESP32-C3 is able to support the following address space mappings. Note that the instruction bus address space (8MB) and the data bus address space (8 MB) is always shared.

- Up to 8 MB instruction bus address space can be mapped into the external flash. The mapped address space is organized as individual 64-KB blocks.
- Up to 8 MB data bus (read-only) address space can be mapped into the external flash. The mapped address space is organized as individual 64-KB blocks.

Table 3.3-2 lists the mapping between the cache and the corresponding address ranges on the data bus and instruction bus.

Table 3.3-2. External Memory Address Mapping

| Bus Type              | Boundary Address   | Boundary Address   | Size (MB)   | Target        |
|-----------------------|--------------------|--------------------|-------------|---------------|
|                       | Low Address        | High Address       |             |               |
| Data bus (read only) | 0x3C00_0000        | 0x3C7F_FFFF        | 8           | Uniform Cache |
| Instruction bus       | 0x4200_0000        | 0x427F_FFFF        | 8           | Uniform Cache |

## Note:

Only if the CPU obtains permission for accessing the external memory, can it be responded for memory access. For more detailed information about permission control, please refer to Chapter 14 Permission Control (PMS) .

## 3.3.3.2 Cache

As shown in Figure 3.3-1, ESP32-C3 has a read-only uniform cache which is eight-way set-associative, its size is 16 KB and its block size is 32 bytes. When cache is active, some internal memory space will be occupied by cache (see Internal SRAM 0 in Section 3.3.2).

The uniform cache is accessible by the instruction bus and the data bus at the same time, but can only respond to one of them at a time. When a cache miss occurs, the cache controller will initiate a request to the external memory.

Figure 3.3-1. Cache Structure

![Image](images/03_Chapter_3_img003_3ea979d5.png)

## 3.3.3.3 Cache Operations

ESP32-C3 cache support the following operations:

1. Invalidate: This operation is used to clear valid data in the cache. After this operation is completed, the data will only be stored in the external memory. The CPU needs to access the external memory in order to read this data. There are two types of invalidate-operation: automatic invalidation (Auto-Invalidate) and manual invalidation (Manual-Invalidate). Manual-Invalidate is performed only on data in the specified area in the cache, while Auto-Invalidate is performed on all data in the cache.
2. Preload: This operation is used to load instructions and data into the cache in advance. The minimum unit of preload-operation is one block. There are two types of preload-operation: manual preload (Manual-Preload) and automatic preload (Auto-Preload). Manual-Preload means that the hardware prefetches a piece of continuous data according to the virtual address specified by the software. Auto-Preload means the hardware prefetches a piece of continuous data according to the current address where the cache hits or misses (depending on configuration).
3. Lock/Unlock: The lock operation is used to prevent the data in the cache from being easily replaced. There are two types of lock: prelock and manual lock. When prelock is enabled, the cache locks the data in the specified area when filling the missing data to cache memory, while the data outside the specified area will not be locked. When manual lock is enabled, the cache checks the data that is already in the cache memory and only locks the data in the specified area, and leaves the data outside the specified area unlocked. When there are missing data, the cache will replace the data in the unlocked way first, so the data in the locked way is always stored in the cache and will not be replaced. But when all ways within the cache are locked, the cache will replace data, as if it was not locked. Unlocking is the reverse of locking, except that it only can be done manually.

Please note that the Manual-Invalidate operations will only work on the unlocked data. If you expect to perform such operation on the locked data, please unlock them first.

## 3.3.4 GDMA Address Space

The GDMA (General Direct Memory Access) peripheral in ESP32-C3 can provide DMA (Direct Memory Access) services including:

- Data transfers between different locations of internal memory;
- Data transfers between modules/peripherals and internal memory.

GDMA uses the same addresses as the data bus to read and write Internal SRAM 1. Specifically, GDMA uses address range 0x3FC8\_0000 ~ 0x3FCD\_FFFF to access Internal SRAM 1. Note that GDMA cannot access the internal memory occupied by the cache.

There are 7 peripherals/modules that can work together with GDMA.

As shown in Figure 3.3-2, these 7 vertical lines in turn correspond to these 7 peripherals/modules with GDMA function, the horizontal line represents a certain channel of GDMA (can be any channel), and the intersection of the vertical line and the horizontal line indicates that a peripheral/module has the ability to access the corresponding channel of GDMA. If there are multiple intersections on the same line, it means that these peripherals/modules cannot enable the GDMA function at the same time.

Figure 3.3-2. Peripherals/modules that can work with GDMA

![Image](images/03_Chapter_3_img004_ff290bfd.png)

These peripherals/modules can access any memory available to GDMA. For more information, please refer to Chapter 2 GDMA Controller (GDMA) .

## Note:

When accessing a memory via GDMA, a corresponding access permission is needed, otherwise this access may fail. For more information about permission control, please refer to Chapter 14 Permission Control (PMS) .

## 3.3.5 Modules/Peripherals

The CPU can access modules/peripherals via 0x6000\_0000 ~ 0x600D\_0FFF shared by the data/instruction bus.

## 3.3.5.1 Module/Peripheral Address Mapping

Table 3.3-3 lists all the modules/peripherals and their respective address ranges. Note that the address space of specific modules/peripherals is defined by "Boundary Address" (including both Low Address and High Address).

Table 3.3-3. Module/Peripheral Address Mapping

| Target                        | Boundary Address   | Boundary Address   | Size (KB)   | Notes   |
|-------------------------------|--------------------|--------------------|-------------|---------|
|                               | Low Address        | High Address       |             |         |
| UART Controller 0             | 0x6000_0000        | 0x6000_0FFF        | 4           |         |
| Reserved                      | 0x6000_1000        | 0x6000_1FFF        |             |         |
| SPI Controller 1              | 0x6000_2000        | 0x6000_2FFF        | 4           |         |
| SPI Controller 0              | 0x6000_3000        | 0x6000_3FFF        | 4           |         |
| GPIO                          | 0x6000_4000        | 0x6000_4FFF        | 4           |         |
| Reserved                      | 0x6000_5000        | 0x6000_6FFF        |             |         |
| Reserved                      | 0x6000_7000        | 0x6000_7FFF        |             |         |
| Low-Power Management          | 0x6000_8000        | 0x6000_8FFF        | 4           |         |
| IO MUX                        | 0x6000_9000        | 0x6000_9FFF        | 4           |         |
| Reserved                      | 0x6000_A000        | 0x6000_FFFF        |             |         |
| UART Controller 1             | 0x6001_0000        | 0x6001_0FFF        | 4           |         |
| Reserved                      | 0x6001_1000        | 0x6001_2FFF        |             |         |
| I2C Controller                | 0x6001_3000        | 0x6001_3FFF        | 4           |         |
| UHCI0                         | 0x6001_4000        | 0x6001_4FFF        | 4           |         |
| Reserved                      | 0x6001_5000        | 0x6001_5FFF        |             |         |
| Remote Control Peripheral     | 0x6001_6000        | 0x6001_6FFF        | 4           |         |
| Reserved                      | 0x6001_7000        | 0x6001_8FFF        |             |         |
| LED PWM Controller            | 0x6001_9000        | 0x6001_9FFF        | 4           |         |
| eFuse Controller              | 0x6001_A000        | 0x6001_AFFF        | 4           |         |
| Reserved                      | 0x6001_B000        | 0x6001_EFFF        |             |         |
| Timer Group 0                 | 0x6001_F000        | 0x6001_FFFF        | 4           |         |
| Timer Group 1                 | 0x6002_0000        | 0x6002_0FFF        | 4           |         |
| Reserved                      | 0x6002_1000        | 0x6002_2FFF        |             |         |
| System Timer                  | 0x6002_3000        | 0x6002_3FFF        | 4           |         |
| SPI Controller 2              | 0x6002_4000        | 0x6002_4FFF        | 4           |         |
| Reserved                      | 0x6002_5000        | 0x6002_5FFF        |             |         |
| SYSCON                        | 0x6002_6000        | 0x6002_6FFF        | 4           |         |
| Reserved                      | 0x6002_7000        | 0x6002_AFFF        |             |         |
| Two-wire Automotive Interface | 0x6002_B000        | 0x6002_BFFF        | 4           |         |
| Reserved                      | 0x6002_C000        | 0x6002_CFFF        |             |         |
| I2S Controller                | 0x6002_D000        | 0x6002_DFFF        | 4           |         |
| Reserved                      | 0x6002_E000        | 0x6003_9FFF        |             |         |
| AES Accelerator               | 0x6003_A000        | 0x6003_AFFF        | 4           |         |
| SHA Accelerator               | 0x6003_B000        | 0x6003_BFFF        | 4           |         |
| RSA Accelerator               | 0x6003_C000        | 0x6003_CFFF        | 4           |         |

Cont’d on next page

Table 3.3-3 – cont’d from previous page

| Target                                    | Boundary Address   | Boundary Address   | Size (KB)   | Notes   |
|-------------------------------------------|--------------------|--------------------|-------------|---------|
|                                           | Low Address        | High Address       | Size (KB)   | Notes   |
| Digital Signature                         | 0x6003_D000        | 0x6003_DFFF        | 4           |         |
| HMAC Accelerator                          | 0x6003_E000        | 0x6003_EFFF        | 4           |         |
| GDMA Controller                           | 0x6003_F000        | 0x6003_FFFF        | 4           |         |
| ADC Controller                            | 0x6004_0000        | 0x6004_0FFF        | 4           |         |
| Reserved                                  | 0x6004_1000        | 0x6002_FFFF        |             |         |
| USB Serial/JTAG Controller                | 0x6004_3000        | 0x6004_3FFF        | 4           |         |
| Reserved                                  | 0x6004_4000        | 0x600B_FFFF        |             |         |
| System Registers                          | 0x600C_0000        | 0x600C_0FFF        | 4           |         |
| PMS Registers                             | 0x600C_1000        | 0x600C_1FFF        | 4           |         |
| Interrupt Matrix                          | 0x600C_2000        | 0x600C_2FFF        | 4           |         |
| Reserved                                  | 0x600C_3000        | 0x600C_3FFF        |             |         |
| Reserved                                  | 0x600C_4000        | 0x600C_BFFF        |             |         |
| External Memory Encryption and Decryption | 0x600C_C000        | 0x600C_CFFF        | 4           |         |
| Reserved                                  | 0x600C_D000        | 0x600C_DFFF        |             |         |
| Assist Debug                              | 0x600C_E000        | 0x600C_EFFF        | 4           |         |
| Reserved                                  | 0x600C_F000        | 0x600C_FFFF        |             |         |
| World Controller                          | 0x600D_0000        | 0x600D_0FFF        | 4           |         |
