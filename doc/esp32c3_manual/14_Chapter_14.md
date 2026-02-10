---
chapter: 14
title: "Chapter 14"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 14

## Permission Control (PMS)

## 14.1 Overview

ESP32-C3 includes a Permission Controller (PMS), which allocates the hardware resources (memory and peripherals) to two isolated environments, thereby realizing the separation of privileged and unprivileged environments.

- Privileged Environment:
- – Can access all peripherals and memories;
- – Performs all confidential operations, such as user authentication, secure communication, and data encryption and decryption, etc.
- Unprivileged Environment:
- – Can access some peripherals and memories;
- – Performs other operations, such as user operation and different applications, etc.

Besides, ESP32-C3's RISC-V CPU also has a Physical Memory Protection (PMP) unit, which can be used by software to set memory access privileges (read, write, and execute permissions) for required memory regions. However, the PMP unit has some limitations:

- Only supports up to 16 configurable PMP regions, which sometimes are not enough to fully support the access management requirement of ESP32-C3's rich peripherals and different types of memories.
- Can only control CPU, not GDMA.

To this, ESP32-C3 has specially implemented this Permission Controller to complete the Physical Memory Protection unit.

ESP32-C3’s completed workflow of permission check can be described below (also see Figure 14.1-1):

1. Check PMP permission
- Pass: then continue and further check PMS permission
- Fail: throw an exception and will not further check PMS permission
2. Check PMS permission

- Pass: access allowed

- Fail: trigger an interrupt

Figure 14.1-1. Permission Control Overview

![Image](images/14_Chapter_14_img001_02d3ae43.png)

For details about PMP, please refer to Section 1.8.1 in Chapter 1 ESP-RISC-V CPU. For details about World Controller, please refer to Chapter 15 World Controller (WCL). This chapter only describes ESP32-C3's PMS mechanism.

## 14.2 Features

ESP32-C3’s extended permission control mechanism supports:

- Independent access management in a privileged environment and unprivileged environment
- Independent access management to internal memory, including
- – CPU access to internal memory
- – GDMA access to internal memory
- Independent access management to external memory, including
- – CPU to external memory via SPI1
- – CPU to external memory via Cache
- Independent access management to peripheral regions, including
- – CPU access to peripheral regions
- – Interrupt upon unsupported access alignment
- Address splitting for more flexible access management
- Register locks to secure the integrity of access management related registers
- Interrupt upon unauthorized access

## 14.3 Privileged Environment and Unprivileged Environment

During PMS check, ESP32-C3 chip:

- When in the privileged environment: check the permission configuration registers for the privileged environment

- When not in the unprivileged environment: check the permission configuration registers for the unprivileged environment

Users can choose either of these two ways below to enter the chip into privileged environment:

- By configuring the world controller
- – Switching to Secure world: entering the privileged environment
- – Switching to Non-secure world: entering the unprivileged environment
- By configuring the privileged level of the 32-bit RISC-V CPU:
- – Switching to Machine mode: entering the privileged environment
- – Switching to User mode: entering the unprivileged environment

Users can configure PMS\_PRIVILEGE\_MODE\_SEL to choose between the above-mentioned two ways to enter the chip into privileged environment:

- 0 (Default): via configuring the world controller. See details in Chapter 15 World Controller (WCL) .
- 1: via configuring the CP's privileged level. See details in Chapter 1 ESP-RISC-V CPU .

The following sections introduce how to configure the permission to different areas in the privileged environment and the unprivileged environment.

## 14.4 Internal Memory

ESP32-C3 has the following types of internal memory:

- ROM: 384 KB in total, including 256 KB Internal ROM0 and 128 KB Internal ROM1
- SRAM: 400 KB in total, including 16 KB Internal SRAM0 and 384 KB Internal SRAM1
- RTC FAST Memory: 8 KB in total, which can be further split into two regions each with independent permission configuration

This section describes how to configure the permission to each type of ESP32-C3’s internal memory.

## 14.4.1 ROM

ESP32-C3's ROM can be accessed by CPU's instruction bus (IBUS) and data bus (DBUS) when configured. The ROM ranges accessible for IBUS and DBUS respectively are listed in Table 14.4-1 .

Table 14.4-1. ROM Address

| ROM           | IBUS Address     | IBUS Address   | DBUS Address     | DBUS Address   |
|---------------|------------------|----------------|------------------|----------------|
| ROM           | Starting Address | Ending Address | Starting Address | Ending Address |
| Internal ROM0 | 0x4000_0000      | 0x4003_FFFF    | -                | -              |
| Internal ROM1 | 0x4004_0000      | 0x4005_FFFF    | 0x3FF0_0000      | 0x3FF1_FFFF    |

ESP32-C3 uses the registers listed in Table 14.4-2 to configure the instruction execution (X), write (W) and read (R) accesses of CPU's IBUS and DBUS, in User mode and Machine mode. Note that access configuration to ROM0 and ROM1 cannot be configured separately:

Table 14.4-2. Access Configuration to ROM (ROM0 and ROM1)

| Bus   | Environment   | Configuration Registers A                      | Access   |
|-------|---------------|------------------------------------------------|----------|
| IBUS  | Privileged    | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_2_REG [20:18] B | X/W/R    |
| IBUS  | Unprivileged  | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_1_REG [20:18] B | X/W/R    |
| DBUS  | Privileged    | PMS_CORE_X_DRAM0_PMS_CONSTRAIN_1_REG [25:24] C | W/R      |
| DBUS  | Unprivileged  | PMS_CORE_X_DRAM0_PMS_CONSTRAIN_1_REG [27:26]   | W/R      |

## 14.4.2 SRAM

ESP32-C3's SRAM can be accessed by CPU's instruction bus (IBUS) and data bus (DBUS) when configured. The SRAM address ranges accessible for IBUS and DBUS respectively are listed in Table 14.4-3 .

Table 14.4-3. SRAM Address

| SRAM           | Block   | IBUS Address     | IBUS Address   | DBUS Address     | DBUS Address   |
|----------------|---------|------------------|----------------|------------------|----------------|
| SRAM           | Block   | Starting Address | Ending Address | Starting Address | Ending Address |
| Internal SRAM0 | -       | 0x4037_C000      | 0x4037_FFFF    | -                | -              |
| Internal SRAM1 | Block0  | 0x4038_0000      | 0x4039_FFFF    | 0x3FC8_0000      | 0x3FC9_FFFF    |
| Internal SRAM1 | Block1  | 0x403A_0000      | 0x403B_FFFF    | 0x3FCA_0000      | 0x3FCB_FFFF    |
| Internal SRAM1 | Block2  | 0x403C_0000      | 0x403D_FFFF    | 0x3FCC_0000      | 0x3FCD_FFFF    |

Here, we will first introduce how to configure the permission to Internal SRAM0 and then Internal SRAM1.

## 14.4.2.1 Internal SRAM0 Access Configuration

ESP32-C3’s Internal SRAM0 can be allocated to either CPU or ICACHE.

Users can configure PMS\_INTERNAL\_SRAM\_USAGE\_CPU\_CACHE to allocate ESP32-C3's Internal SRAM0 to either CPU or ICACHE:

- 1: CPU
- 0: ICACHE

When the Internal SRAM0 is allocated to CPU, ESP32-C3 uses the registers listed in Table 14.4-4 to configure the instruction execution (X), write (W) and read (R) accesses of CPU's IBUS, in the privileged environment and the unprivileged environment:

Table 14.4-4. Access Configuration to Internal SRAM0

| Bus A   | Environment   | Configuration Registers B                                         | Access   |
|---------|---------------|-------------------------------------------------------------------|----------|
| IBUS    | Privileged    | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_SRAM_M_MODE_CACHEDATAARRAY_PMS_0 C | X/W/R    |
| IBUS    | Unprivileged  | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_SRAM_U_MODE_CACHEDATAARRAY_PMS_0   | X/W/R    |

## 14.4.2.2 Internal SRAM1 Access Configuration

ESP32-C3’s Internal SRAM1 includes Block0 ~ Block2 (see details in Table 14.4-3) and can be:

- Accessed by CPU's DBUS, IBUS and GDMA at the same time
- Further split into up to 6 regions with independent access management for more flexible permission control.

ESP32-C3's Internal SRAM1 can be further split into up to 6 regions with 5 split lines. Users can configure different access to each region independently.

To be more specific, the Internal SRAM1 can be first split into Instruction Region and Data Region by IRam0\_DRam0\_split\_line:

- Instruction Region:
- – Then the Instruction Region should be only configured to be accessed by IBUS;
- – And can be further split into three split regions by IRam0\_split\_line\_0 and IRam0\_split\_line\_1.
- Data Region:
- – The Data Region should be only configured to be accessed by DBUS;
- – And can be further split into three split regions by DRam0\_split\_line\_0 and DRam0\_split\_line\_1.

See illustration in Figure 14.4-1 and Table 14.4-5 below.

![Image](images/14_Chapter_14_img002_9e8de56d.png)

Figure 14.4-1. Split Lines for Internal SRAM1

![Image](images/14_Chapter_14_img003_d1e6d6a5.png)

Table 14.4-5. Internal SRAM1 Split Regions

| Internal Memory  A   | Instruction / Data Regions   | Split Regions B   |
|----------------------|------------------------------|-------------------|
| SRAM1                | Instruction Region           | Instr_Region_0    |
| SRAM1                | Instruction Region           | Instr_Region_1    |
| SRAM1                | Instruction Region           | Instr_Region_2    |
| SRAM1                | Data Region                  | Data_Region_0     |
| SRAM1                | Data Region                  | Data_Region_1     |
| SRAM1                | Data Region                  | Data_Region_2     |

## Internal SRAM1 Split Regions

ESP32-C3 allows users to configure the split lines to their needs with registers below:

- Split line to split the Instruction and Data regions (IRam0\_DRam0\_split\_line):
- – PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_1\_REG
- The first split line to further split the Instruction Region (IRam0\_split\_line\_0):
- – PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_2\_REG
- The second split line to further split the Instruction Region (IRam0\_split\_line\_1):
- – PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_3\_REG
- The first split line to further split the data Region (DRam0\_split\_line\_0):
- – PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_4\_REG
- The second split line to further split the data Region (DRam0\_split\_line\_1):
- – PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_5\_REG

## When configuring the split lines,

1. First configure the block in which the split line is by:
- Configuring the Category\_x field for the block in which the split line is to 0x1 or 0x2 (no difference)
- Configuring the Category\_0 ~ Category\_x-1 fields for all the preceding blocks to 0x0
- Configuring the Category\_x+1 ~ Category\_2 fields for all blocks afterwards to 0x3

For example, assuming you want to configure the split line in Block1, then first configure the Category\_1 field for Block1 to 0x1 or 0x2; configure the Category\_0 for Block0 to 0x0; and configure the Category\_2 for Block2 to 0x3 (see illustration in Figure 14.4-2). On the other hand, when reading 0x1 or 0x2 from Category\_1, then you know the split line is in Block1.

2. Configure the position of the split line inside the configured block by:
- Writing the [16:9] bits of the actual address at which you want to split the memory to the SPLITADDR field for the block in which the split line is.
- Note that the split address must be aligned to 512 bytes, meaning you can only write the integral multiples of 0x200 to the SPLITADDR field.

For example, if you want to split the instruction region at 0x3fc88000, then write the [16:9] bits of this address, which is 0b01000000, to SPLITADDR .

3. The split address applies to both IBUS and DBUS address. For example, DBUS address 0x3fc88000 and IBUS address 0x40388000 indicate the same location in SRAM1. The split address for both buses is [16:9].

Figure 14.4-2. An illustration of Configuring the Category fields

![Image](images/14_Chapter_14_img004_f1084701.png)

Note the following points when configuring the split lines:

- Position:
- – The split line that splitting the Instruction Region and Data Region can be configured anywhere inside Internal SRAM1.
- – The two split lines further splitting the Instruction Region into 3 split regions must stay inside the Instruction Region.
- – The two split lines further splitting the Data Region into 3 split regions must stay inside the Data Region.
- Spilt lines can overlap with each other. For example,
- – When the two split lines inside the Data Region are not overlapping with each other, then the Data Region is split into 3 split regions
- – When the two split lines inside the Data Region are overlapping with each other, then the Data Region is only split into 2 split regions
- – When the two split lines inside the Data Region are not only overlapping with each other but also with the split line that splits the Data Region and the Instruction Region, then the Data Region is not split at all and only has one region.

## Access Configuration

After configuring the split lines, users can then use the registers described in the Table 14.4-6 and Table 14.4-7 below to configure the access of CPU's IBUS, DBUS and GDMA peripherals, in the privileged environment and the unprivileged environment, to these split regions independently.

Table 14.4-6. Access Configuration to the Instruction Region of Internal SRAM1

| Buses   | Environment      | Configuration Registers                | Instruction Region   | Instruction Region   | Instruction Region   | Access   |
|---------|------------------|----------------------------------------|----------------------|----------------------|----------------------|----------|
|         |                  |                                        | instr_region_0       | instr_region_1       | instr_region_2       |          |
| IBUS    | Privileged       | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_2_REG   | [2:0]                | [5:3]                | [8:6]                | X/W/R    |
| IBUS    | Unprivileged     | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_1_REG   | [2:0]                | [5:3]                | [8:6]                | X/W/R    |
| DBUS    | Privileged       | PMS_Core_X_DRAM0_PMS_CONSTRAIN_1_REG   | [13:12] A            | [13:12] A            | [13:12] A            | W/R      |
| DBUS    | Unprivileged     | PMS_Core_X_DRAM0_PMS_CONSTRAIN_1_REG   | [1:0] A              | [1:0] A              | [1:0] A              | W/R      |
| GDMA C  | XX Peripherals D | PMS_DMA_APBPERI_XX_PMS_CONSTRAIN_1_REG | [1:0]B               | [1:0]B               | [1:0]B               | W/R      |

Table 14.4-7. Access Configuration to the Data Region of Internal SRAM1

| Buses   | Environment      | Configuration Registers                | Data Region   | Data Region   | Data Region   | Access   |
|---------|------------------|----------------------------------------|---------------|---------------|---------------|----------|
|         |                  |                                        | data_region_0 | data_region_1 | data_region_2 |          |
| IBUS    | Privileged       | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_2_REG   | [11:9] A      | [11:9] A      | [11:9] A      | X/W/R    |
| IBUS    | Unprivileged     | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_1_REG   | [11:9] A      | [11:9] A      | [11:9] A      | X/W/R    |
| DBUS    | Privileged       | PMS_Core_X_DRAM0_PMS_CONSTRAIN_1_REG   | [3:2]         | [5:4]         | [7:6]         | W/R      |
| DBUS    | Unprivileged     | PMS_Core_X_DRAM0_PMS_CONSTRAIN_1_REG   | [15:14]       | [17:16]       | [19:18]       | W/R      |
| GDMA  B | XX Peripherals C | PMS_DMA_APBPERI_XX_PMS_CONSTRAIN_1_REG | [3:2]         | [5:4]         | [7:6]         | W/R      |

For details on how to configure the split lines, see Section 14.4.2.2 .

## Note:

If enabled, the permission control module watches all the memory access and fires the panic handler if a permission violation is detected. This feature automatically splits the SRAM memory into data and instruction segments and sets Read/Execute permissions for the instruction part (below given splitting address) and Read/Write permissions for the data part (above the splitting address). The memory protection is effective on all access through the IRAM0 and DRAM0 buses. See details, see ESP-IDF api-reference Memory protection .

## 14.4.3 RTC FAST Memory

ESP32-C3’s RTC FAST Memory is 8 KB. See the address of RTC FAST Memory below:

Table 14.4-8. RTC FAST Memory Address

| Memory   | Starting Address   | Ending Address   |
|----------|--------------------|------------------|

| RTC FAST Memory   | 0x5000_0000   | 0x5000_1FFF   |
|-------------------|---------------|---------------|

ESP32-C3's RTC FAST Memory can be further split into 2 regions. Each split region can be configured independently with different access.

The Register for configuring the split line is described below:

Table 14.4-9. Split RTC FAST Memory into the Higher Region and the Lower Region

|                                      | Privileged Environment        | Unprivileged Environment       |
|--------------------------------------|-------------------------------|--------------------------------|
| Split Lines Configuration Register 1 | PIF_PMS_CONSTRAN_9_REG [10:0] | PIF_PMS_CONSTRAN_9_REG [21:11] |

Access configuration for the higher and lower regions of the RTC FAST Memory is described below:

Table 14.4-10. Access Configuration to the RTC FAST Memory

| Bus      | RTC           | Configuration Registers          | Configuration Registers        | Access A   |
|----------|---------------|----------------------------------|--------------------------------|------------|
|          | FAST Memory   | Privileged Environment           | Unprivileged Environment       |            |
| Peri Bus | Higher Region | PIF_PMS_CONSTRAN_10_REG [5:3]  B | PIF_PMS_CONSTRAN_10_REG [11:9] | X/R/W      |
| (PIF)    | Lower Region  | PIF_PMS_CONSTRAN_10_REG [2:0]    | PIF_PMS_CONSTRAN_10_REG [8:6]  | X/R/W      |

## 14.5 Peripherals

## 14.5.1 Access Configuration

ESP32-C3's CPU can be configured with different read (R) and write (W) accesses to most of its modules and peripherals independently, in the privileged environment and in the unprivileged environment, by configuring respective registers

(PMS\_CORE\_0\_PIF\_PMS\_CONSTRAN\_n\_REG).

Notes on PMS\_CORE\_0\_PIF\_PMS\_CONSTRAN\_n\_REG:

- n can be 1 ~ 8, in which 1 ~ 4 are for the privileged environment and 5 ~ 8 are for the unprivileged environment.

For example, users can configure PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_1\_REG [1:0] to 0x2, meaning CPU is granted with read access but not write access in the privileged environment to UART0. In this case, CPU won't be able to modify the UART0's internal registers when in the privileged environment.

Table 14.5-1. Access Configuration of the Peripherals

| Peripherals                   | Privileged Environment   | Unprivileged Environment   | Bit 3   |
|-------------------------------|--------------------------|----------------------------|---------|
| GDMA                          | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [7:6]   |
| eFuse Controller & PMU1       | **_PMS_CONSTRAN_1_REG    | **_PMS_CONSTRAN_5_REG      | [15:14] |
| IO_MUX                        | **_PMS_CONSTRAN_1_REG    | **_PMS_CONSTRAN_5_REG      | [17:16] |
| GPIO                          | **_PMS_CONSTRAN_1_REG    | **_PMS_CONSTRAN_5_REG      | [7:6]   |
| Interrupt Matrix              | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [21:20] |
| System Timer                  | **_PMS_CONSTRAN_2_REG    | **_PMS_CONSTRAN_6_REG      | [31:30] |
| Timer Group 0                 | **_PMS_CONSTRAN_2_REG    | **_PMS_CONSTRAN_6_REG      | [27:26] |
| Timer Group 1                 | **_PMS_CONSTRAN_2_REG    | **_PMS_CONSTRAN_6_REG      | [29:28] |
| System Registers              | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [17:16] |
| PMS Registers                 | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [19:18] |
| Debug Assist                  | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [27:26] |
| Accelerators2                 | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [5:4]   |
| Cache & XTS_AES 1             | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [25:25] |
| UART 0                        | **_PMS_CONSTRAN_1_REG    | **_PMS_CONSTRAN_5_REG      | [1:0]   |
| UART 1                        | **_PMS_CONSTRAN_1_REG    | **_PMS_CONSTRAN_5_REG      | [31:30] |
| SPI 0                         | **_PMS_CONSTRAN_1_REG    | **_PMS_CONSTRAN_5_REG      | [5:4]   |
| SPI 1                         | **_PMS_CONSTRAN_1_REG    | **_PMS_CONSTRAN_5_REG      | [3:2]   |
| SPI 2                         | **_PMS_CONSTRAN_3_REG    | **_PMS_CONSTRAN_7_REG      | [1:0]   |
| I2C 0                         | **_PMS_CONSTRAN_2_REG    | **_PMS_CONSTRAN_6_REG      | [5:4]   |
| I2S                           | **_PMS_CONSTRAN_3_REG    | **_PMS_CONSTRAN_7_REG      | [15:14] |
| USB OTG Core                  | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [15:14] |
| Two-wire Automotive Interface | **_PMS_CONSTRAN_3_REG    | **_PMS_CONSTRAN_7_REG      | [11:10] |
| UHCI 0                        | **_PMS_CONSTRAN_2_REG    | **_PMS_CONSTRAN_6_REG      | [7:6]   |
| LED PWM Controller            | **_PMS_CONSTRAN_2_REG    | **_PMS_CONSTRAN_6_REG      | [17:16] |
| Remote Control Peripheral     | **_PMS_CONSTRAN_2_REG    | **_PMS_CONSTRAN_6_REG      | [11:10] |
| APB Controller                | **_PMS_CONSTRAN_3_REG    | **_PMS_CONSTRAN_7_REG      | [5:4]   |
| ADC Controller                | **_PMS_CONSTRAN_4_REG    | **_PMS_CONSTRAN_8_REG      | [9:8]   |

## 14.5.2 Split Peripheral Regions into Split Regions

On top of what described in the previous section, user can select one of ESP32-C3's peripheral region to split them into 7 regions (from Peri Region0 ~ Peri Region7) for more flexible permission control.

For example, the registers for ESP32-C3’s GDMA controller are allocated as:

- 3 sets of registers for each of 3 RX channel
- 3 sets of registers for each of 3 TX channel
- 1 set of registers for configuration

As seen above, GDMA's peripheral region is divided into 7 split regions (implemented in hardware), which can be configured with different permission independently, thus achieving independent permission control for each GDMA channel.

Users can configure CPU's read (R) and write (W) accesses to a specific split region (Peri Regionn) in the privileged environment and in the unprivileged environment by configuring

PMS\_REGION\_PMS\_CONSTRAN\_n\_REG .

Notes on PMS\_REGION\_PMS\_CONSTRAN\_n\_REG:

- n can be 1~10, in which
- – PMS\_REGION\_PMS\_CONSTRAN\_1\_REG is for configuring CPU's permission in the privileged environment.
- – PMS\_REGION\_PMS\_CONSTRAN\_2\_REG is for configuring CPU's permission in the unprivileged environment.
- – PMS\_REGION\_PMS\_CONSTRAN\_n\_REG (n = 3~10) are used to configuring the starting addresses for each Peri Regions. Note the starting address of each Peri Region is also the ending address of the previous Peri Region.

Table 14.5-2. Access Configuration of Peri Regions

| Peri Regions   | Starting Address  Configuration   | Access Configuration                  | Access Configuration                  |
|----------------|-----------------------------------|---------------------------------------|---------------------------------------|
| Peri Regions   | Starting Address  Configuration   | Privileged Environment                | Unprivileged Environment              |
| Peri Region0   | PMS_REGION_PMS_CONSTRAN_3_REG     | PMS_REGION_PMS_CONSTRAN_1_REG [1:0]   | PMS_REGION_PMS_CONSTRAN_2_REG [1:0]   |
| Peri Region1   | PMS_REGION_PMS_CONSTRAN_4_REG     | PMS_REGION_PMS_CONSTRAN_1_REG [3:2]   | PMS_REGION_PMS_CONSTRAN_2_REG [3:2]   |
| Peri Region2   | PMS_REGION_PMS_CONSTRAN_5_REG     | PMS_REGION_PMS_CONSTRAN_1_REG [5:4]   | PMS_REGION_PMS_CONSTRAN_2_REG [5:4]   |
| Peri Region3   | PMS_REGION_PMS_CONSTRAN_6_REG     | PMS_REGION_PMS_CONSTRAN_1_REG [7:6]   | PMS_REGION_PMS_CONSTRAN_2_REG [7:6]   |
| Peri Region4   | PMS_REGION_PMS_CONSTRAN_7_REG     | PMS_REGION_PMS_CONSTRAN_1_REG [9:8]   | PMS_REGION_PMS_CONSTRAN_2_REG [9:8]   |
| Peri Region5   | PMS_REGION_PMS_CONSTRAN_8_REG     | PMS_REGION_PMS_CONSTRAN_1_REG [11:10] | PMS_REGION_PMS_CONSTRAN_2_REG [11:10] |
| Peri Region6 * | PMS_REGION_PMS_CONSTRAN_9_REG     | PMS_REGION_PMS_CONSTRAN_1_REG [13:12] | PMS_REGION_PMS_CONSTRAN_2_REG [13:12] |

## 14.6 External Memory

ESP32-C3 can access the external memory via one of the two ways illustrated in Figure 14.6-1 below.

- CPU via SPI1
- CPU via CACHE

## Where,

- Box 0 checks the SPI and Cache's access to external flash.
- Box 1 checks CPU's access to Cache.

## 14.6.1 SPI and Cache's Access to External Flash

Figure 14.6-1. Two Ways to Access External Memory

![Image](images/14_Chapter_14_img005_3c903abf.png)

## 14.6.1.1 Address

ESP32-C3's flash can be further split to achieve more flexible permission control. Each split region can be configured with different access independently.

- Flash can be split into 4 regions, the length of each should be the integral multiples of 64 KB.
- Also, the starting address of each region should also be aligned to 64 KB.

The following registers can be used to configure how the flash is split.

Table 14.6-1. Split the External Memory into Split Regions

| Split Regions          | Split Region Configuration 3 1  2   | Split Region Configuration 3 1  2   |
|------------------------|-------------------------------------|-------------------------------------|
|                        | Starting Address                    | Length                              |
| Flash Regionn (n: 0~3) | SYSCON_FLASH_ACEn_ADDR_REG          | SYSCON_FLASH_ACEn_SIZE_REG          |

## 14.6.1.2 Access Configuration

Each split region for flash can be configured with different permission independently via the register described in the table below.

Table 14.6-2. Access Configuration of Flash Regions

|                           | Access Configuration   | Access Configuration   | Access Configuration   |
|---------------------------|------------------------|------------------------|------------------------|
| Split Regions             | Configuration Register | Cache                  | SPI                    |
| Flash Region n (n: 0 ~ 3) | SYSCON_FLASH_ACEn_ATTR | [1:0] A                | [3:2] B                |

## 14.6.2 CPU's Access to Cache

ESP32-C3's CPU access Cache using a virtual address. The memory space in ESP32-C3 that is accessible for CPU to access Cache is called "Virtual Address Region", which can be seen in Table 14.6-3 below.

Table 14.6-3. Cache Virtual Address Region

| Bus Type         | Virtual Address Region   | Virtual Address Region   | Size (MB)   | Target        |
|------------------|--------------------------|--------------------------|-------------|---------------|
|                  | Starting Address         | Ending Address           | Size (MB)   | Target        |
| DBus (read-only) | 0x3C00_0000              | 0x3C7F_FFFF              | 8           | Uniform Cache |
| IBus             | 0x4200_0000              | 0x427F_FFFF              | 8           | Uniform Cache |

## 14.6.2.1 Split Regions

Both ESP32-C3's DBUS and IBUS Cache virtual address regions can be further split into up to 4 regions. Users can configure different access to each region independently.

Table 14.6-4. Split IBUS Cache Virtual Address into 4 Regions

| Split Regions 1   | Split Region Configuration          | Split Region Configuration          |
|-------------------|-------------------------------------|-------------------------------------|
| Split Regions 1   | Starting Address                    | Ending Address                      |
| IBUS Region0      | 0x4200_0000                         | EXTMEM_IBUS_PMS_TBL_BOUNDARY0_REG 2 |
| IBUS Region1      | EXTMEM_IBUS_PMS_TBL_BOUNDARY0_REG 2 | EXTMEM_IBUS_PMS_TBL_BOUNDARY1_REG 2 |
| IBUS Region2      | EXTMEM_IBUS_PMS_TBL_BOUNDARY1_REG 2 | EXTMEM_IBUS_PMS_TBL_BOUNDARY2_REG 2 |
| IBUS Region3      | EXTMEM_IBUS_PMS_TBL_BOUNDARY2_REG 2 | 0x4280_0000                         |

Table 14.6-5. Split DBUS Cache Virtual Address into 4 Regions

| Split Regions 1   | Split Region Configuration          | Split Region Configuration          |
|-------------------|-------------------------------------|-------------------------------------|
| Split Regions 1   | Starting Address                    | Ending Address                      |
| DBUS Region0      | 0x3C00_0000                         | EXTMEM_DBUS_PMS_TBL_BOUNDARY0_REG 2 |
| DBUS Region1      | EXTMEM_DBUS_PMS_TBL_BOUNDARY0_REG 2 | EXTMEM_DBUS_PMS_TBL_BOUNDARY1_REG 2 |
| DBUS Region2      | EXTMEM_DBUS_PMS_TBL_BOUNDARY1_REG 2 | EXTMEM_DBUS_PMS_TBL_BOUNDARY2_REG 2 |
| DBUS Region3      | EXTMEM_DBUS_PMS_TBL_BOUNDARY2_REG 2 | 0x3C80_0000                         |

## 14.6.3 Access Configuration

Each Cache split region can be configured with different permission independently via registers described in Table 14.6-6 and Table 14.6-7 below.

![Image](images/14_Chapter_14_img006_3c24e0e3.png)

Table 14.6-6. Access Configuration of IBUS to Split Regions

|                 | Access Configuration         | Access Configuration   | Access Configuration   |
|-----------------|------------------------------|------------------------|------------------------|
| Split Regions   | Configuration Register       | Privileged A           | Unprivileged A         |
| IBUS Region0 C  | -                            | -                      | -                      |
| IBUS Region1    | EXTMEM_IBUS_PMS_TBL_ATTR_REG | [1:0] B                | [3:2]                  |
| IBUS Region2    | EXTMEM_IBUS_PMS_TBL_ATTR_REG | [5:4]                  | [7:6]                  |
| IBUS Region3  C | -                            | -                      | -                      |

Table 14.6-7. Access Configuration of DBUS to Split Regions

|                | Access Configuration         | Access Configuration   | Access Configuration   |
|----------------|------------------------------|------------------------|------------------------|
| Split Regions  | Configuration Register       | Privileged A           | Unprivileged A         |
| DBUS Region0 C | -                            | -                      | -                      |
| DBUS Region1   | EXTMEM_DBUS_PMS_TBL_ATTR_REG | [0] B                  | [1]                    |
| DBUS Region2   | EXTMEM_DBUS_PMS_TBL_ATTR_REG | [2]                    | [3]                    |
| DBUS Region3 C | -                            | -                      | -                      |

## 14.7 Unauthorized Access and Interrupts

Any attempt to access ESP32-C3's slave device without configured permission is considered an unauthorized access and will be handled as described below:

- This attempt will only be responded with default values, in particular,
- – All instruction execution or read attempts will be responded with 0 (for internal memory and peripheral) or 0xdeadbeaf (for external memory)
- – All write attempts will fail
- An interrupt will be triggered (when enabled). See details below.

Note that only the information of the first interrupt is logged. Therefore, it's advised to handle interrupt signals and clear interrupts in-time, so the information of the next interrupt can be logged correctly.

## 14.7.1 Interrupt upon Unauthorized IBUS Access

ESP32-C3 can be configured to trigger interrupts when IBUS attempts to access internal ROM and SRAM without configured permission and log the information about this unauthorized access. Note that, once this interrupt is enabled, it's enabled for all internal ROM and SRAM memory, and cannot be only enabled for a certain address field. This interrupt corresponds to the PMS\_IBUS\_VIO\_INTR interrupt source described in Table 8.3-1 from Chapter 8 Interrupt Matrix (INTERRUPT) .

Table 14.7-1. Interrupt Registers for Unauthorized IBUS Access

| Registers                          | Bit    | Description                                                                                                                                        |
|------------------------------------|--------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| PMS_CORE_0_IRAM0_PMS_MONITOR_1_REG | [0]    | Clears interrupt signal                                                                                                                            |
| PMS_CORE_0_IRAM0_PMS_MONITOR_1_REG | [1]    | Enables interrupt                                                                                                                                  |
| PMS_CORE_0_IRAM0_PMS_MONITOR_2_REG | [0]    | Stores interrupt status of unauthorized IBUS access                                                                                                |
| PMS_CORE_0_IRAM0_PMS_MONITOR_2_REG | [1]    | Stores the access direction. 1: write; 0: read.                                                                                                    |
| PMS_CORE_0_IRAM0_PMS_MONITOR_2_REG | [2]    | Stores the instruction direction. 1: load/store; 0: instruction execution.                                                                         |
| PMS_CORE_0_IRAM0_PMS_MONITOR_2_REG | [4:3]  | Stores the privileged mode the CPU was in when the unauthorized IBUS access happened. 0b01: privileged environment; 0b10: unprivileged environment |
| PMS_CORE_0_IRAM0_PMS_MONITOR_2_REG | [28:5] | Stores the address that CPU’s IBUS was trying to access unauthorized.                                                                              |

## 14.7.2 Interrupt upon Unauthorized DBUS Access

ESP32-C3 can be configured to trigger interrupts when DBUS attempts to access internal ROM and SRAM without configured permission and log the information about this unauthorized access. Note that, once this interrupt is enabled, it's enabled for all internal ROM and SRAM memory, and cannot be only enabled for a certain address field. This interrupt corresponds to the PMS\_DBUS\_VIO\_INTR interrupt source described in Table 8.3-1 from Chapter 8 Interrupt Matrix (INTERRUPT) .

Table 14.7-2. Interrupt Registers for Unauthorized DBUS Access

| Registers                          | Bit    | Description                                                                                                                                        |
|------------------------------------|--------|----------------------------------------------------------------------------------------------------------------------------------------------------|
| PMS_CORE_0_DRAM0_PMS_MONITOR_1_REG | [0]    | Clears interrupt signal                                                                                                                            |
| PMS_CORE_0_DRAM0_PMS_MONITOR_1_REG | [1]    | Enables interrupt                                                                                                                                  |
| PMS_CORE_0_DRAM0_PMS_MONITOR_2_REG | [0]    | Stores interrupt status of unauthorized DBUS access                                                                                                |
| PMS_CORE_0_DRAM0_PMS_MONITOR_2_REG | [1]    | Flags atomic access. 1: atomic access; 0: not atomic access.                                                                                       |
| PMS_CORE_0_DRAM0_PMS_MONITOR_2_REG | [3:2]  | Stores the privileged mode the CPU was in when the unauthorized DBUS access happened. 0b01: privileged environment; 0b10: unprivileged environment |
| PMS_CORE_0_DRAM0_PMS_MONITOR_2_REG | [25:4] | Stores the address that CPU’s DBUS was trying to access unauthorized.                                                                              |
| PMS_CORE_0_DRAM0_PMS_MONITOR_3_REG | [0]    | Stores the access direction. 1: write; 0: read.                                                                                                    |
| PMS_CORE_0_DRAM0_PMS_MONITOR_3_REG | [25:4] | Stores the byte information of the unauthorized DBUS access.                                                                                       |

## 14.7.3 Interrupt upon Unauthorized Access to External Memory

ESP32-C3 can be configured to trigger Interrupt upon unauthorized access to external memory, and log the information about this unauthorized access. This interrupt corresponds to the SPI\_MEM\_REJECT\_INTR interrupt source described in Table 8.3-1 from Chapter 8 Interrupt Matrix (INTERRUPT) .

Table 14.7-3. Interrupt Registers for Unauthorized Access to External Memory

| Registers                   | Bit   | Description                                    |
|-----------------------------|-------|------------------------------------------------|
| SYSCON_SPI_MEM_PMS_CTRL_REG | [0]   | Stores exception signal                        |
| SYSCON_SPI_MEM_PMS_CTRL_REG | [1]   | Clears exception signal and logged information |
| SYSCON_SPI_MEM_PMS_CTRL_REG | [2]   | Indicates unauthorized instruction execution   |
| SYSCON_SPI_MEM_PMS_CTRL_REG | [3]   | Indicates unauthorized read                    |
| SYSCON_SPI_MEM_PMS_CTRL_REG | [4]   | Indicates unauthorized write                   |
| SYSCON_SPI_MEM_PMS_CTRL_REG | [5]   | Indicates overlapping split regions            |
| SYSCON_SPI_MEM_PMS_CTRL_REG | [6]   | Indicates invalid address                      |

## 14.7.4 Interrupt upon Unauthorized Access to Internal Memory via GDMA

ESP32-C3 can be configured to trigger Interrupt upon unauthorized access to internal memory via GDMA, and log the information about this unauthorized access. This interrupt corresponds to the PMS\_DMA\_VIO\_INTR interrupt source described in Table 8.3-1 from Chapter 8 Interrupt Matrix (INTERRUPT) .

Table 14.7-4. Interrupt Registers for Unauthorized Access to Internal Memory via GDMA

| Registers                         | Bit    | Description                                                                                                                                   |
|-----------------------------------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| PMS_DMA_APBPERI_PMS_MONITOR_1_REG | [0]    | Clears interrupt signal                                                                                                                       |
| PMS_DMA_APBPERI_PMS_MONITOR_1_REG | [1]    | Enables interrupt                                                                                                                             |
| PMS_DMA_APBPERI_PMS_MONITOR_2_REG | [0]    | Stores interrupt signal                                                                                                                       |
| PMS_DMA_APBPERI_PMS_MONITOR_2_REG | [2:1]  | Stores the privileged mode the CPU was in when the unauthorized access happened. 0b01: privileged environment; 0b10: unprivileged environment |
| PMS_DMA_APBPERI_PMS_MONITOR_2_REG | [24:3] | Stores the address that GDMA was trying to access unauthorized                                                                                |
| PMS_DMA_APBPERI_PMS_MONITOR_3_REG | [0]    | Stores the access direction. 1: write; 0: read                                                                                                |
| PMS_DMA_APBPERI_PMS_MONITOR_3_REG | [16:1] | Stores the byte information of unauthorized access                                                                                            |

For information about Interrupt upon unauthorized access to external memory via GDMA, please refer to Chapter 2 GDMA Controller (GDMA) .

## 14.7.5 Interrupt upon Unauthorized peripheral bus (PIF) Access

ESP32-C3 can be configured to trigger interrupts when PIF attempts to access RTC FAST memory and peripheral regions without configured permission, and log the information about this unauthorized access. Note that, once this interrupt is enabled, it's enabled for all RTC FAST memory and peripheral regions, and

cannot be only enabled for a certain address field. This interrupt corresponds to the PMS\_PERI\_VIO\_INTR interrupt source described in Table 8.3-1 from Chapter 8 Interrupt Matrix (INTERRUPT) .

Table 14.7-5. Interrupt Registers for Unauthorized PIF Access

| Registers                        | Bit    | Description                                                                                                                                       |
|----------------------------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------|
| PMS_CORE_0_PIF_PMS_MONITOR_1_REG | [1]    | Enables interrupt                                                                                                                                 |
| PMS_CORE_0_PIF_PMS_MONITOR_1_REG | [0]    | Clears interrupt signal and logged information                                                                                                    |
| PMS_CORE_0_PIF_PMS_MONITOR_2_REG | [7:6]  | Stores the privileged mode the CPU was in when the unauthorized PIF access happened. 0b01: privileged environment; 0b10: unprivileged environment |
| PMS_CORE_0_PIF_PMS_MONITOR_2_REG | [5]    | Stores the access direction. 1: write; 0: read                                                                                                    |
| PMS_CORE_0_PIF_PMS_MONITOR_2_REG | [4:2]  | Stores the data type of unauthorized access. 0: byte; 1: half-word; 2: word                                                                       |
| PMS_CORE_0_PIF_PMS_MONITOR_2_REG | [1]    | Stores the access type. 0: instruction; 1: data                                                                                                   |
| PMS_CORE_0_PIF_PMS_MONITOR_2_REG | [0]    | Stores the interrupt signal                                                                                                                       |
| PMS_CORE_0_PIF_PMS_MONITOR_3_REG | [31:0] | Stores the address of unauthorized access                                                                                                         |

In particular, ESP32-C3 can also be configured to check the access alignment when PIF attempts to access the peripheral regions and trigger Interrupt upon unauthorized alignment. See the detailed description in the following section.

## 14.7.6 Interrupt upon Unauthorized PIF Access Alignment

Access to all of ESP32-C3's modules/peripherals is word aligned .

ESP32-C3 can be configured to check the access alignment to all modules/peripherals, and trigger Interrupt upon non-word aligned access .

This interrupt corresponds to the PMS\_PERI\_VIO\_SIZE\_INTR interrupt source described in Table 8.3-1 from Chapter 8 Interrupt Matrix (INTERRUPT) .

Note that CPU can convert some non-word aligned access to word aligned access, thus avoiding triggering alignment interrupt.

Table 14.7-6 below lists all the possible access alignments and their results (when the interrupt is enabled), in which:

- INTR: interrupt
- √

Table 14.7-6. All Possible Access Alignment and their Results

| Accessed Address   | Access Alignment   | Read   | Write   |
|--------------------|--------------------|--------|---------|
| 0x0                | Byte aligned       | √      | INTR    |
| 0x0                | Half-word aligned  | √      | INTR    |
| 0x0                | Word aligned       | √      | √       |
| 0x1                | Byte aligned       | √      | INTR    |
|                    | Half-word aligned  | √      | INTR    |

| Accessed Address   | Access Alignment   | Read   | Write   |
|--------------------|--------------------|--------|---------|
|                    | Word aligned       | √      | INTR    |
| 0x2                | Byte aligned       | √      | INTR    |
| 0x2                | Half-word aligned  | √      | INTR    |
| 0x2                | Word aligned       | √      | INTR    |
| 0x3                | Byte aligned       | √      | INTR    |
| 0x3                | Half-word aligned  | √      | INTR    |
| 0x3                | Word aligned       | √      | INTR    |

Table 14.7-7. Interrupt Registers for Unauthorized Access Alignment

| Registers                        | Bit    | Description                                                                                                                                   |
|----------------------------------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------|
| PMS_CORE_0_PIF_PMS_MONITOR_4_REG | [1]    | Enables interrupt                                                                                                                             |
| PMS_CORE_0_PIF_PMS_MONITOR_4_REG | [0]    | Clears interrupt signal and logged information                                                                                                |
| PMS_CORE_0_PIF_PMS_MONITOR_5_REG | [4:3]  | Stores the privileged mode the CPU was in when the unauthorized access happened. 0b01: privileged environment; 0b10: unprivileged environment |
| PMS_CORE_0_PIF_PMS_MONITOR_5_REG | [2:1]  | Stores the unauthorized access type. 0: byte aligned; 1: half-word aligned; 2: word aligned                                                   |
| PMS_CORE_0_PIF_PMS_MONITOR_5_REG | [0]    | Stores the interrupt status. 0: no interrupt; 1: interrupt                                                                                    |
| PMS_CORE_0_PIF_PMS_MONITOR_6_REG | [31:0] | Stores the address of the unauthorized access                                                                                                 |

## 14.8 Register Locks

All ESP32-C3's permission control related registers can be locked by respective lock registers. When the lock registers are configured to 1, these registers themselves and their related permission control registers are all protected from modification until the next CPU reset.

Note that there isn't a one-to-one correspondence between the lock registers and permission control registers. See details in Table 14.8-1 .

Table 14.8-1. Lock Registers and Related Permission Control Registers

| Lock Registers                                     | Related Permission Control Registers               |
|----------------------------------------------------|----------------------------------------------------|
| Lock privileged Mode Configuration                 | Lock privileged Mode Configuration                 |
| PMS_PRIVILEGE_MODE_SEL_LOCK_REG                    | PMS_PRIVILEGE_MODE_SEL_LOCK_REG                    |
| PMS_PRIVILEGE_MODE_SEL_LOCK_REG                    | PMS_PRIVILEGE_MODE_SEL_REG                         |
| Lock Internal SRAM Usuage and Access Configuration | Lock Internal SRAM Usuage and Access Configuration |
| PMS_INTERNAL_SRAM_USAGE_0_REG                      | PMS_INTERNAL_SRAM_USAGE_0_REG                      |
| PMS_INTERNAL_SRAM_USAGE_0_REG                      | PMS_INTERNAL_SRAM_USAGE_1_REG                      |
| PMS_INTERNAL_SRAM_USAGE_0_REG                      | PMS_INTERNAL_SRAM_USAGE_4_REG                      |
| PMS_CORE_X_IRAM0_PMS_CONSTRAIN_0_REG               | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_0_REG               |
| PMS_CORE_X_IRAM0_PMS_CONSTRAIN_0_REG               | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_1_REG               |
| PMS_CORE_X_IRAM0_PMS_CONSTRAIN_0_REG               | PMS_CORE_X_IRAM0_PMS_CONSTRAIN_2_REG               |
|                                                    | PMS_CORE_m_IRAM0_PMS_MONITOR_0_REG                 |

PMS\_CORE\_m\_IRAM0\_PMS\_MONITOR\_0\_REG

| Lock Registers                                                  | Related Permission Control Registers                                               |
|-----------------------------------------------------------------|------------------------------------------------------------------------------------|
|                                                                 | PMS_CORE_m_IRAM0_PMS_MONITOR_1_REG                                                 |
| PMS_CORE_X_DRAM0_PMS_CONSTRAIN_0_REG                            | PMS_CORE_X_DRAM0_PMS_CONSTRAIN_0_REG                                               |
|                                                                 | PMS_CORE_X_DRAM0_PMS_CONSTRAIN_1_REG                                               |
| PMS_CORE_m_DRAM0_PMS_MONITOR_0_REG                              | PMS_CORE_m_DRAM0_PMS_MONITOR_0_REG                                                 |
|                                                                 | PMS_CORE_m_DRAM0_PMS_MONITOR_1_REG                                                 |
| Lock SRAM Split Lines Configuration                             |                                                                                    |
| PMS_CORE_X_IRAM0_DRAM0_DMA_SPLIT_LINE_  CONSTRAIN_0_REG         | _CONSTRAIN_0_REG PMS_CORE_X_IRAM0_DRAM0_DMA_SPLIT_LINE                             |
| Lock Peripherals Access Configuration                           |                                                                                    |
|                                                                 | _CONSTRAIN_n_REG (n: 1 - 5)                                                        |
| PMS_CORE_m_PIF_PMS_CONSTRAIN_0_REG                              | PMS_CORE_m_PIF_PMS_CONSTRAIN_0_REG                                                 |
| PMS_REGION_PMS_CONSTRAIN_0_REG                                  | PMS_CORE_m_PIF_PMS_CONSTRAIN_n_REG (n: 1 - 14) PMS_REGION_PMS_CONSTRAIN_0_REG      |
| PMS_CORE_m_PIF_PMS_MONITOR_0_REG                                | PMS_REGION_PMS_CONSTRAIN_n_REG (n: 1 - 14) PMS_CORE_m_PIF_PMS_CONSTRAIN_0_REG      |
|                                                                 | PMS_CORE_m_PIF_PMS_MONITOR_1_REG (n: 1 - 6)                                        |
| Lock Peripherals Access Configuration to Internal SRAM via GDMA |                                                                                    |
| PMS_DMA_APBPERI_SPI2_PMS_CONSTRAIN_0_REG                        | PMS_DMA_APBPERI_SPI2_PMS_CONSTRAIN_0_REG PMS_DMA_APBPERI_SPI2_PMS_CONSTRAIN_1_REG  |
| PMS_DMA_APBPERI_UCHI0_PMS_CONSTRAIN_0  _REG                     | PMS_DMA_APBPERI_UCHI0_PMS_CONSTRAIN_0_REG                                          |
|                                                                 | PMS_DMA_APBPERI_UCHI0_PMS_CONSTRAIN_1_REG PMS_DMA_APBPERI_I2S0_PMS_CONSTRAIN_0_REG |
| PMS_DMA_APBPERI_I2S0_PMS_CONSTRAIN_0_REG                        |                                                                                    |
|                                                                 | PMS_DMA_APBPERI_I2S0_PMS_CONSTRAIN_1_REG                                           |
|                                                                 | PMS_DMA_APBPERI_AES_PMS_CONSTRAIN_0_REG                                            |
| PMS_DMA_APBPERI_AES_PMS_CONSTRAIN_0_REG                         | PMS_DMA_APBPERI_AES_PMS_CONSTRAIN_1_REG                                            |
|                                                                 | PMS_DMA_APBPERI_SHA_PMS_CONSTRAIN_0_REG                                            |
| PMS_DMA_APBPERI_SHA_PMS_CONSTRAIN_0_REG                         | PMS_DMA_APBPERI_SHA_PMS_CONSTRAIN_1_REG                                            |
| PMS_DMA_APBPERI_ADC_DAC_PMS_CONSTRAIN_0  _REG                   | PMS_DMA_APBPERI_ADC_DAC_PMS_CONSTRAIN_0 _REG                                       |
|                                                                 | PMS_DMA_APBPERI_ADC_DAC_PMS_CONSTRAIN_1 _REG                                       |
| PMS_DMA_APBPERI_PMS_MONITOR_0_REG                               | PMS_DMA_APBPERI_PMS_MONITOR_0_REG                                                  |
|                                                                 | PMS_DMA_APBPERI_PMS_MONITOR_1_REG                                                  |
| Lock CPU’s Access Configuration to Cache                        | PMS_DMA_APBPERI_PMS_MONITOR_3_REG                                                  |
| EXTMEM_DBUS_PMS_TBL_LOCK_REG                                    | EXTMEM_DBUS_PMS_TBL_BOUNDARY1_REG                                                  |
| EXTMEM_IBUS_PMS_TBL_LOCK_REG                                    |                                                                                    |
|                                                                 | EXTMEM_IBUS_PMS_TBL_BOUNDARY0_REG                                                  |
|                                                                 | EXTMEM_IBUS_PMS_TBL_BOUNDARY1_REG                                                  |
|                                                                 | EXTMEM_IBUS_PMS_TBL_ATTR_REG                                                       |
|                                                                 | EXTMEM_DBUS_PMS_TBL_BOUNDARY2_REG                                                  |

| Lock Registers   | Related Permission Control Registers   |
|------------------|----------------------------------------|
|                  | EXTMEM_IBUS_PMS_TBL_BOUNDARY2_REG      |

Chapter 14 Permission Control (PMS)

Access

R/WL

R/WL

R/WL

.

System and Memory

3

in Chapter

## 3.3-3

The addresses in this section are relative to the Permission Control base address provided in Table

Register Summary

14.9

| Description                                                                                                                                                                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                               |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| PMS_PRIVILEGE_MODE_SEL_LOCK_REG  PMS_APB_PERIPHERAL_ACCESS_0_REG  PMS_APB_PERIPHERAL_ACCESS_1_REG  PMS_DMA_APBPERI_SPI2_PMS_CONSTRAIN_0_REG  PMS_DMA_APBPERI_SPI2_PMS_CONSTRAIN_1_REG  PMS_DMA_APBPERI_UCHI0_PMS_CONSTRAIN_0_REG  PMS_DMA_APBPERI_UCHI0_PMS_CONSTRAIN_1_REG  PMS_DMA_APBPERI_I2S0_PMS_CONSTRAIN_0_REG  PMS_DMA_APBPERI_I2S0_PMS_CONSTRAIN_1_REG  PMS_DMA_APBPERI_AES_PMS_CONSTRAIN_0_REG |                                                                                                                                                                                                                                                                                               |
| PMS_INTERNAL_SRAM_USAGE_0_REG  PMS_INTERNAL_SRAM_USAGE_1_REG  PMS_INTERNAL_SRAM_USAGE_4_REG                                                                                                                                                                                                                                                                                                              |                                                                                                                                                                                                                                                                                               |
| PMS_PRIVILEGE_MODE_SEL_REG                                                                                                                                                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                               |
|                                                                                                                                                                                                                                                                                                                                                                                                          | PMS_DMA_APBPERI_SHA_PMS_CONSTRAIN_1_REG  PMS_DMA_APBPERI_ADC_DAC_PMS_CONSTRAIN_0_REG  PMS_DMA_APBPERI_ADC_DAC_PMS_CONSTRAIN_1_REG  PMS_DMA_APBPERI_PMS_MONITOR_0_REG  PMS_DMA_APBPERI_PMS_MONITOR_1_REG  PMS_CORE_X_IRAM0_DRAM0_DMA_SPLIT_LINE : 0 - 5)  PMS_CORE_X_IRAM0_PMS_CONSTRAIN_0_REG |
|                                                                                                                                                                                                                                                                                                                                                                                                          | n                                                                                                                                                                                                                                                                                             |
|                                                                                                                                                                                                                                                                                                                                                                                                          | _REG (                                                                                                                                                                                                                                                                                        |
| Configuration Register                                                                                                                                                                                                                                                                                                                                                                                   | n                                                                                                                                                                                                                                                                                             |
| PMS_DMA_APBPERI_AES_PMS_CONSTRAIN_1_REG                                                                                                                                                                                                                                                                                                                                                                  | PMS_DMA_APBPERI_SHA_PMS_CONSTRAIN_0_REG  _CONSTRAIN_                                                                                                                                                                                                                                          |
| Name                                                                                                                                                                                                                                                                                                                                                                                                     |                                                                                                                                                                                                                                                                                               |

Espressif Systems

R/WL

0x003C

R/WL

0x0040

SPI2 GDMA Permission Config Register 1

UCHI0 GDMA Permission Config Register 0

335

Submit Documentation Feedback

R/WL

0x0074

R/WL

0x0078

R/WL

0x007C

R/WL

0x0080

R/WL

0x0084

GoBack

R/WL

R/WL

n

0x0090 + 4 *

0x00A8

SHA GDMA Permission Config Register 1

ADC\_DAC GDMA Permission Config Register 0

ADC\_DAC GDMA Permission Config Register 1

GDMA Permission Interrupt Register 0

GDMA Permission Interrupt Register 1

n

SRAM split line config register

IBUS Permission Config Register 0

ESP32-C3 TRM (Version 1.3)

R/WL

0x0014

APB peripheral configuration register 1

R/WL

0x0018

Internal SRAM configuration register 0

Address

0x0008

PMS\_PRIVILEGE\_MODE\_SEL\_LOCK\_REG

0x000C

PMS\_PRIVILEGE\_MODE\_SEL\_REG

0x0010

APB peripheral configuration register 0

R/WL

0x001C

Internal SRAM configuration register 1

R/WL

0x0024

Internal SRAM configuration register 4

R/WL

0x0038

SPI2 GDMA Permission Config Register 0

R/WL

0x0044

UCHI0 GDMA Permission Config Register 1

R/WL

0x0048

I2S GDMA Permission Config Register 0

R/WL

0x004C

I2S GDMA Permission Config Register 1

R/WL

0x0068

AES GDMA Permission Config Register 0

R/WL

0x006C

AES GDMA Permission Config Register 1

R/WL

0x0070

SHA GDMA Permission Config Register 0

Chapter 14 Permission Control (PMS)

Access

Address

Description

R/WL

0x00AC

IBUS Permission Config Register 1

0x00B0

IBUS Permission Config Register 2

0x00B4

CPU0 IBUS Permission Interrupt Register 0

0x00B8

CPU0 IBUS Permission Interrupt Register 1

Name

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_1\_REG

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_2\_REG

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_0\_REG

R/WL

R/WL

R/WL

R/WL

R/WL

R/WL

R/WL

n

0x00D8 + 4 *

n

Peripheral Permission Configuration Register

R/WL

n

0x0104 + 4 *

n

| DBUS Permission Config Register 0  DBUS Permission Config Register 1  CPU Split_Region Permission Register CPU PIF Permission Interrupt Register 1  GDMA Permission Interrupt Register 2  GDMA Permission Interrupt Register 3                                                                                                                                                                     |                                                                    |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------|
|                                                                                                                                                                                                                                                                                                                                                                                                    | Clock Gate Config Register  Sensitive Version Register             |
| : 0 - 10)                                                                                                                                                                                                                                                                                                                                                                                          |                                                                    |
| n                                                                                                                                                                                                                                                                                                                                                                                                  |                                                                    |
| _REG ( n : 0 - 10)                                                                                                                                                                                                                                                                                                                                                                                 |                                                                    |
| n _REG (                                                                                                                                                                                                                                                                                                                                                                                           | PMS_CORE_0_PIF_PMS_MONITOR_5_REG  PMS_CORE_0_PIF_PMS_MONITOR_6_REG |
| PMS_CORE_0_IRAM0_PMS_MONITOR_1_REG  PMS_CORE_X_DRAM0_PMS_CONSTRAIN_0_REG  PMS_CORE_X_DRAM0_PMS_CONSTRAIN_1_REG  PMS_CORE_0_DRAM0_PMS_MONITOR_0_REG  PMS_CORE_0_DRAM0_PMS_MONITOR_1_REG  PMS_CORE_0_PIF_PMS_CONSTRAIN_ n PMS_CORE_0_PIF_PMS_MONITOR_0_REG  PMS_CORE_0_PIF_PMS_MONITOR_1_REG  PMS_CORE_0_PIF_PMS_MONITOR_4_REG  PMS_DMA_APBPERI_PMS_MONITOR_2_REG  PMS_DMA_APBPERI_PMS_MONITOR_3_REG |                                                                    |
|                                                                                                                                                                                                                                                                                                                                                                                                    | PMS_CORE_0_PIF_PMS_MONITOR_3_REG                                   |
| PMS_CORE_0_IRAM0_PMS_MONITOR_2_REG                                                                                                                                                                                                                                                                                                                                                                 |                                                                    |
|                                                                                                                                                                                                                                                                                                                                                                                                    | PMS_CLOCK_GATE_REG_REG                                             |
|                                                                                                                                                                                                                                                                                                                                                                                                    | Version Register PMS_DATE_REG                                      |
| PMS_REGION_PMS_CONSTRAIN_ Status Register                                                                                                                                                                                                                                                                                                                                                          |                                                                    |

Espressif Systems

336

Submit Documentation Feedback

RO

0x0144

RO

0x0148

R/W

0x0170

R/W

0x0FFC

CPU PIF Permission Interrupt Register 5

CPU PIF Permission Interrupt Register 6

ESP32-C3 TRM (Version 1.3)

R/WL

0x00CC

CPU0 dBUS Permission Interrupt Register 1

0x00C0

0x00C4

0x00C8

CPU0 dBUS Permission Interrupt Register 0

R/WL

0x0130

CPU PIF Permission Interrupt Register 0

R/WL

0x0134

R/WL

0x0140

CPU PIF Permission Interrupt Register 4

RO

0x0088

RO

0x008C

RO

0x00BC

CPU0 IBUS Permission Interrupt Register 2

RO

0x00D0

CPU0 dBUS Permission Interrupt Register 2

RO

0x00D4

CPU0 dBUS Permission Interrupt Register 3

RO

0x0138

CPU PIF Permission Interrupt Register 2

RO

0x013C

CPU PIF Permission Interrupt Register 3

GoBack

Chapter 14 Permission Control (PMS)

Access

Address

Description

0x0020

External Memory Permission Lock Register

R/W

R/W

R/W

R/W

varies

RO

n

0x0028 + 4 *

Permission Config Register

n

n

0x0038 + 4 *

n

0x0048 + 4 *

0x0088

0x008C

Access

Address

R/W

0x00D8

R/W

n

0x00DC + 4 *

Starting Address Config

Cache IBUS Region

n

R/W

0x00E8

R/W

0x00EC

R/W

n

0x00F0 + 4 *

Starting Address

Cache DBUS Region

R/W

0x00FC

| Starting Address Config Register  Length Config Register  Cache IBUS Regions Lock  (n+1)  Cache DBUS Regions Lock  (n+1)   |
|----------------------------------------------------------------------------------------------------------------------------|

Flash Area

Flash Area

SYSCON\_EXT\_MEM\_PMS\_LOCK\_REG

: 0 - 3)

n

n

Flash Area

Description

Register

Cache IBUS Region Permission Register

Config Register

Cache DBUS Region Permission Register

| : 0 - 2)        | : 0 - 2)                | : 0 - 2)   | : 0 - 2)   |
|-----------------|-------------------------|------------|------------|
| : 0 - 2)  n     |                         |            |            |
| _REG ( n _REG ( |                         |            |            |
| n n             | : 0 - 3)                |            |            |
| : 0 - 3)  n     |                         |            |            |
|                 | _ADDR_S ( n _SIZE_REG ( |            |            |

Configuration Registers

\_ATTR\_REG (

n

n

Name

SYSCON\_FLASH\_ACE

SYSCON\_SRAM\_ACE

Espressif Systems

n

SYSCON\_FLASH\_ACE

EXTMEM\_DBUS\_PMS\_TBL\_ATTR\_REG

Permission Configure register EXTMEM\_IBUS\_PMS\_TBL\_LOCK\_REG

EXTMEM\_IBUS\_PMS\_TBL\_BOUNDARY

EXTMEM\_IBUS\_PMS\_TBL\_ATTR\_REG

EXTMEM\_DBUS\_PMS\_TBL\_LOCK\_REG

EXTMEM\_DBUS\_PMS\_TBL\_BOUNDARY

337

Submit Documentation Feedback

External Memory Unauthorized Access Address Register

SYSCON\_SPI\_MEM\_REJECT\_ADDR\_REG

External Memory Unauthorized Access Interrupt Register

SYSCON\_SPI\_MEM\_PMS\_CTRL\_REG

Name

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

.

System and Memory

3

in Chapter

## 3.3-3

The addresses in this section are relative to the Permission Control base address provided in Table

Registers

14.10

Espressif Systems

PMS\_PRIVILEGE\_MODE\_SEL\_LOCK

Reset

00

1

![Image](images/14_Chapter_14_img007_25109c88.png)

31

Set this bit to lock privilege\_mode configuration register. (R/WL)

PMS\_PRIVILEGE\_MODE\_SEL\_LOCK

338

Submit Documentation Feedback

Register 14.1. PMS\_PRIVILEGE\_MODE\_SEL\_LOCK\_REG (0x0008) (reserved) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 1

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

PMS\_PRIVILEGE\_MODE\_SEL

Reset

00

1

Reset

00

1

![Image](images/14_Chapter_14_img008_204e07bc.png)

Register 14.2. PMS\_PRIVILEGE\_MODE\_SEL\_REG (0x000C) (reserved) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 1

Espressif Systems

339

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

PMS\_APB\_PERIPHERAL\_ACCESS\_LOCK

GoBack

Chapter 14 Permission Control (PMS)

PMS\_APB\_PERIPHERAL\_ACCESS\_SPLIT\_BURST

Reset

1
0

1

Reset

0
0

1

![Image](images/14_Chapter_14_img009_e2f06f7b.png)

Register 14.4. PMS\_APB\_PERIPHERAL\_ACCESS\_1\_REG (0x0014)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

URST Set this bit to support split function for AHB access to APB peripherals. (R/WL)
Register 14.5. PMS\_INTERNAL\_SRAM\_USAGE\_0\_REG (0x0018)

340

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

PMS\_INTERNAL\_SRAM\_USAGE\_LOCK

GoBack

Chapter 14 Permission Control (PMS)

) 
PMS\_INTERNAL\_SRAM\_USAGE\_CPU\_CACHE

Reset

10

1

0x7

Register 14.6. PMS\_INTERNAL\_SRAM\_USAGE\_1\_REG (0x001C)

3

4

![Image](images/14_Chapter_14_img010_abb47615.png)

Espressif Systems

341

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

(reserved) 
P

PMS\_INTERNAL\_SRAM\_USAGE\_LOG\_SRAM

Reset

00

1

GoBack

Chapter 14 Permission Control (PMS)

PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img011_84cae21f.png)

31

Register 14.8. PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_0\_REG (0x0038)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock SPI2’s DMA permission configuration register. (R/WL)

PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_LOCK

342

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
I\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
A\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

Register 14.9. PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_1\_REG (0x003C)

PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONST

Espressif Systems

I\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
A\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MOD

A\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM

0

1

2

3

4

5

6

0x3

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 8 PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0 PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1 PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2 PMS\_DMA\_APBPERI\_SPI2\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3

![Image](images/14_Chapter_14_img012_fe145022.png)

343

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Reset

0x3

0x3

0x3

Configure SPI2’s permission to the instruction region. (R/WL)

Configure SPI2’s permission to the data region0 of SRAM. (R/WL)

Configure SPI2’s permission to the data region1 of SRAM. (R/WL)

Configure SPI2’s permission to the data region2 of SRAM. (R/WL)

GoBack

Chapter 14 Permission Control (PMS)

PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img013_9c375654.png)

31

Register 14.10. PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_0\_REG (0x0040)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock UHCI0’s DMA permission configuration register. (R/WL)

PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_LOCK

344

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS) 
0

Register 14.11. PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_1\_REG (0x0044)

PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONST

Espressif Systems

I\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
A\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MOD

A\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM

ter 14 Permission Control (PMS) 
MS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
I\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
A\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

0

1

2

3

4

5

6

0x3

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 8 PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0 PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1 PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2 PMS\_DMA\_APBPERI\_UCHI0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3

![Image](images/14_Chapter_14_img014_6eaa4152.png)

345

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Reset

0x3

0x3

0x3

Configure UHCI0’s permission to the instruction region. (R/WL)

Configure UHCI0’s permission to the data region0 of SRAM. (R/WL)

Configure UHCI0’s permission to the data region1 of SRAM. (R/WL)

Configure UHCI0’s permission to the data region2 of SRAM. (R/WL)

GoBack

Chapter 14 Permission Control (PMS)

PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img015_c020b63a.png)

31

Register 14.12. PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_0\_REG (0x0048)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock I2S’s DMA permission configuration register. (R/WL)

PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_LOCK

346

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
I\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
A\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

Register 14.13. PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_1\_REG (0x004C)

PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONST

Espressif Systems

I\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
A\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MOD

A\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM

0

1

2

3

4

5

6

0x3

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 8 PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0 PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1 PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2 PMS\_DMA\_APBPERI\_I2S0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3

![Image](images/14_Chapter_14_img016_fbfecca2.png)

347

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Reset

0x3

0x3

0x3

Configure I2S’s permission to the instruction region. (R/WL)

Configure I2S’s permission to the data region0 of SRAM. (R/WL)

Configure I2S’s permission to the data region1 of SRAM. (R/WL)

Configure I2S’s permission to the data region2 of SRAM. (R/WL)

GoBack

Chapter 14 Permission Control (PMS)

PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img017_d980a26f.png)

31

Register 14.14. PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_0\_REG (0x0068)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock AES’s DMA permission configuration register. (R/WL)

PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_LOCK

348

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
I\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
A\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

Register 14.15. PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_1\_REG (0x006C)

PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM
PMS\_DMA\_APBPERI\_AES\_PMS\_CONST

Espressif Systems

I\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
A\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MOD

A\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM

0

1

2

3

4

5

6

0x3

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 8 PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0 PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1 PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2 PMS\_DMA\_APBPERI\_AES\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3

![Image](images/14_Chapter_14_img018_22485a01.png)

349

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Reset

0x3

0x3

0x3

Configure AES’s permission to the instruction region. (R/WL)

Configure AES’s permission to the data region0 of SRAM. (R/WL)

Configure AES’s permission to the data region1 of SRAM. (R/WL)

Configure AES’s permission to the data region2 of SRAM. (R/WL)

GoBack

Chapter 14 Permission Control (PMS)

PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img019_ad538af8.png)

31

Register 14.16. PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_0\_REG (0x0070)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock SHA’s DMA permission configuration register. (R/WL)

PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_LOCK

350

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
I\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
A\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

Register 14.17. PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_1\_REG (0x0074)

PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONST

0

1

2

3

4

5

6

0x3

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 8 PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0 PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1 PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2 PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3

![Image](images/14_Chapter_14_img020_a77f307f.png)

Espressif Systems

351

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

I\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
A\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MOD

A\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_SHA\_PMS\_CONSTRAIN\_SRAM

Reset

0x3

0x3

0x3

Configure SHA’s permission to the instruction region. (R/WL)

Configure SHA’s permission to the data region0 of SRAM. (R/WL)

Configure SHA’s permission to the data region1 of SRAM. (R/WL)

Configure SHA’s permission to the data region2 of SRAM. (R/WL)

GoBack

Chapter 14 Permission Control (PMS)

PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img021_e97d3ca5.png)

31

Register 14.18. PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_0\_REG (0x0078)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock ADC\_DAC’s DMA permission configuration register. (R/WL)

PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_LOCK

352

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS) 
MS\_0

Register 14.19. PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_1\_REG (0x007C)

PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONST

Espressif Systems

I\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
A\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MOD

A\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM

ter 14 Permission Control (PMS) 
C\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
I\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
A\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

0

1

2

3

4

5

6

0x3

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 8 PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0 PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1 PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2 PMS\_DMA\_APBPERI\_ADC\_DAC\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3

![Image](images/14_Chapter_14_img022_da7c2b97.png)

353

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Reset

0x3

0x3

0x3

Configure ADC\_DAC’s permission to the instruction region. (R/WL)

Configure ADC\_DAC’s permission to the data region0 of SRAM. (R/WL)

Configure ADC\_DAC’s permission to the data region1 of SRAM. (R/WL)

Configure ADC\_DAC’s permission to the data region2 of SRAM. (R/WL)

GoBack

Chapter 14 Permission Control (PMS)

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img023_d868dd79.png)

31

Register 14.20. PMS\_DMA\_APBPERI\_PMS\_MONITOR\_0\_REG (0x0080)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock DMA access interrupt configuration register. (R/WL)

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_LOCK

354

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_EN
PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_CLR

Reset

1
0

1
1

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_EN
PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE

2

![Image](images/14_Chapter_14_img024_6218c5be.png)

31

Register 14.21. PMS\_DMA\_APBPERI\_PMS\_MONITOR\_1\_REG (0x0084)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 2

Espressif Systems

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_CLR

Set this bit to enable interrupt upon illegal DMA access. (R/WL)

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_EN

355

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img025_de78830b.png)

31

Register 14.22. PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_0\_REG (0x0090)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1
PMS\_C
0
0
R

Espressif Systems

Set this bit to lock internal SRAM’s split lines configuration. (R/WL)

PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_LOCK

356

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

Register 14.23. PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_1\_REG (0x0094)

PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CATEGORY\_2
PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CAT
PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA

RE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CATEGORY\_2
PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CATEGORY\_1
PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CAT

0\_DRAM0\_DMA\_SRAM\_CATEGORY\_2
RE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CATEGORY\_1
PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CATEGORY\_0

(reserved)

PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_SPLITADDR
(reserved)

0

1

2

3

4

5

6

![Image](images/14_Chapter_14_img026_7b0fd2a8.png)

- (reserved)

Espressif Systems

IRAM0\_DRAM0\_Split\_Line. (R/WL)

Reset

0

0

0

0 0 0 0 0 0 0 0

0 0 0 0 0 0 0 0 0 0

22

31

Configures Block0’s category field for the instruction and data split line

PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CATEGORY\_0

Configures Block1’s category field for the instruction and data split line

PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CATEGORY\_1

IRAM0\_DRAM0\_Split\_Line. (R/WL)

Configures Block2’s category field for the instruction and data split line

PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_CATEGORY\_2

357

Submit Documentation Feedback

IRAM0\_DRAM0\_Split\_Line. (R/WL)

Configures the split address of the instruction and data split line IRAM0\_DRAM0\_Split\_Line.

PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SRAM\_SPLITADDR

(R/WL)

ESP32-C3 TRM (Version 1.3)

GoBack

Chapter 14 Permission Control (PMS)

Register 14.24. PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_2\_REG (0x0098)

Espressif Systems

0\_SRAM\_LINE\_0\_CATEGORY\_2
RE\_X\_IRAM0\_SRAM\_LINE\_0\_CATEGORY\_1
PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_CATEGORY\_0

0

1

2

RE\_X\_IRAM0\_SRAM\_LINE\_0\_CATEGORY\_2
PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_CATEGORY\_1
PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_CAT

3

4

PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_CATEGORY\_2
PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_CAT
PMS\_CORE\_X\_IRAM0\_SRAM\_L

5

6

![Image](images/14_Chapter_14_img027_5ac420fb.png)

21

Configures Block0’s category field for the instruction internal split line IRAM0\_Split\_Line\_0. (R/WL)

Configures Block2’s category field for the instruction internal split line IRAM0\_Split\_Line\_0. (R/WL)

(reserved) 0 0 0 0 0 0 0 0 0 0 31 22 PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_CATEGORY\_0 PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_CATEGORY\_1 PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_CATEGORY\_2 PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_SPLITADDR

Configures Block1’s category field for the instruction internal split line IRAM0\_Split\_Line\_0. (R/WL)

Configures the split address of the instruction internal split line IRAM0\_Split\_Line\_0. (R/WL)

358

Submit Documentation Feedback

(reserved)

PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_0\_SPLITADDR
(reserve

Reset

0

0

0

0 0 0 0 0 0 0 0

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

Register 14.25. PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_3\_REG (0x009C)

Espressif Systems

0\_SRAM\_LINE\_1\_CATEGORY\_2
RE\_X\_IRAM0\_SRAM\_LINE\_1\_CATEGORY\_1
PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_CATEGORY\_0

0

1

2

RE\_X\_IRAM0\_SRAM\_LINE\_1\_CATEGORY\_2
PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_CATEGORY\_1
PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_CAT

3

4

PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_CATEGORY\_2
PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_CAT
PMS\_CORE\_X\_IRAM0\_SRAM

5

6

![Image](images/14_Chapter_14_img028_b47ec8e0.png)

21

(reserved) 0 0 0 0 0 0 0 0 0 0 31 22 PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_CATEGORY\_0 PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_CATEGORY\_1 PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_CATEGORY\_2 PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_SPLITADDR

Configures Block0’s category field for the instruction internal split line IRAM0\_Split\_Line\_1. (R/WL)

Configures Block1’s category field for the instruction internal split line IRAM0\_Split\_Line\_1. (R/WL)

Configures Block2’s category field for the instruction internal split line IRAM0\_Split\_Line\_1. (R/WL)

Configures the split address of the instruction internal split line IRAM0\_Split\_Line\_1. (R/WL)

359

Submit Documentation Feedback

(reserved)

PMS\_CORE\_X\_IRAM0\_SRAM\_LINE\_1\_SPLITADDR
(reserv

Reset

0

0

0

0 0 0 0 0 0 0 0

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

Register 14.26. PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_4\_REG (0x00A0)

PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_2
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CAT
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_L

RE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_2
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_1
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CAT

M0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_2
RE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_1
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_0

(reserved)

PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_SPLITADDR
(reserved)

0

1

2

3

4

5

6

![Image](images/14_Chapter_14_img029_332d7499.png)

0 0 0 0 0 0 0 0

Configures Block0’s category field for data internal split line DRAM0\_Split\_Line\_0. (R/WL)

Configures Block1’s category field for data internal split line DRAM0\_Split\_Line\_0. (R/WL)

Configures Block2’s category field for data internal split line DRAM0\_Split\_Line\_0. (R/WL)

Configures the split address of data internal split line DRAM0\_Split\_Line\_0. (R/WL)

(reserved) 0 0 0 0 0 0 0 0 0 0 31 22 21 PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_0 PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_1 PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_CATEGORY\_2 PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_0\_SPLITADDR

Espressif Systems

360

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Reset

0

0

0

GoBack

Chapter 14 Permission Control (PMS)

Register 14.27. PMS\_CORE\_X\_IRAM0\_DRAM0\_DMA\_SPLIT\_LINE\_CONSTRAIN\_5\_REG (0x00A4)

PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_2
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CAT
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM

RE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_2
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_1
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CAT

M0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_2
RE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_1
PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_0

(reserved)

PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_SPLITADDR
(reserved)

0

1

2

3

4

5

6

![Image](images/14_Chapter_14_img030_46c02f7d.png)

0 0 0 0 0 0 0 0

Configures Block0’s category field for data internal split line DRAM0\_Split\_Line\_1. (R/WL)

Configures Block1’s category field for data internal split line DRAM0\_Split\_Line\_1. (R/WL)

Configures Block2’s category field for data internal split line DRAM0\_Split\_Line\_1. (R/WL)

Configures the split address of data internal split line DRAM0\_Split\_Line\_1. (R/WL)

(reserved) 0 0 0 0 0 0 0 0 0 0 31 22 21 PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_0 PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_1 PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_CATEGORY\_2 PMS\_CORE\_X\_DRAM0\_DMA\_SRAM\_LINE\_1\_SPLITADDR

Espressif Systems

361

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Reset

0

0

0

GoBack

Chapter 14 Permission Control (PMS)

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img031_7936874d.png)

31

Register 14.28. PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_0\_REG (0x00A8)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock the permission of CPU IBUS to internal SRAM. (R/WL)

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_LOCK

362

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

HEDA
M\_U\_MODE\_PMS\_3
ONSTRAIN\_SRAM\_U\_MODE\_PMS\_2
\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_1
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_0

Register 14.29. PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_1\_REG (0x00AC)

ONSTRAIN\_SRAM\_U\_MODE\_CACHEDA
\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_3
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_2
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U
PMS\_CORE\_X\_IRAM0\_PMS\_CONST

M\_U\_MODE\_CACHED
ONSTRAIN\_SRAM\_U\_MODE\_PMS\_3
\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_2
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_1
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_ROM\_U\_MODE\_PMS
(reserved)
PMS\_CORE\_X\_IRAM0\_PMS\_CO
PMS\_CORE\_X

\_U\_MODE\_PMS
\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_CACHEDA
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_3
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U
PMS\_CORE\_X\_IRAM0\_PMS\_CONST
PMS\_CORE\_X\_IRAM

ONSTRAIN\_ROM\_U\_MODE\_PMS
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_CACHEDATAARRAY\_PMS\_0
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_3
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MO
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRA
PMS\_CORE\_X\_IRAM0

0

2

3

5

6

8

![Image](images/14_Chapter_14_img032_2e16c4c0.png)

GoBack

Configure the permission of CPU’s IBUS to SRAM0 from the un-

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_CACHEDATAARRAY\_PMS\_0

Reset

0x7

0x7

Configures the permission of CPU’s IBUS to instruction region1 of SRAM from the

Configures the permission of CPU’s IBUS to instruction region2 of SRAM from the

0 0 0 0 0 0 0 0 0 0 0

Configures the permission of CPU’s IBUS to instruction region0 of SRAM from the

Configures the permission of CPU’s IBUS to data region of SRAM from the unpriv-

- 31 unpriviledged environment. (R/WL) unpriviledged environment. (R/WL) unpriviledged environment. (R/WL) iledged environment. (R/WL)

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_0

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_1

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_2

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_3

priviledged environment. (R/WL)

- Espressif Systems 363 Submit Documentation Feedback ESP32-C3 TRM (Version 1.3)
- (R/WL)

Configure the permission of CPU’s IBUS to ROM from the unpriviledged environment.

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_ROM\_U\_MODE\_PMS

Chapter 14 Permission Control (PMS)

CHEDA
M\_M\_MODE\_PMS\_3
ONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

Register 14.30. PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_2\_REG (0x00B0)

ONSTRAIN\_SRAM\_M\_MODE\_CACHEDA
\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M
PMS\_CORE\_X\_IRAM0\_PMS\_CONST

M\_M\_MODE\_CACHED
ONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_ROM\_M\_MODE\_PMS
(reserved)
PMS\_CORE\_X\_IRAM0\_PMS\_CON
PMS\_CORE\_X\_I

\_M\_MODE\_PMS
\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_CACHEDA
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M
PMS\_CORE\_X\_IRAM0\_PMS\_CONST
PMS\_CORE\_X\_IRAM

ONSTRAIN\_ROM\_M\_MODE\_PMS
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_CACHEDATAARRAY\_PMS\_0
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MO
PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRA
PMS\_CORE\_X\_IRAM0

0

2

3

5

6

8

![Image](images/14_Chapter_14_img033_d1ab7951.png)

- 31

Reset

0x7

0x7

0 0 0 0 0 0 0 0 0 0 0

Configures the permission of CPU’s IBUS to instruction region0 of SRAM from the

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

Configures the permission of CPU’s IBUS to instruction region1 of SRAM from the

GoBack

Configures the permission of CPU’s IBUS to instruction region2 of SRAM from the

Configures the permission of CPU’s IBUS to data region of SRAM from the privileged

Configures the permission of CPU’s IBUS to SRAM0 from the

- privileged environment (R/WL) privileged environment (R/WL) privileged environment (R/WL) environment (R/WL) privileged environment (R/WL)

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_CACHEDATAARRAY\_PMS\_0

- Espressif Systems 364 Submit Documentation Feedback ESP32-C3 TRM (Version 1.3)

Configures the permission of CPU’s IBUS to ROM from the privileged environment

PMS\_CORE\_X\_IRAM0\_PMS\_CONSTRAIN\_ROM\_M\_MODE\_PMS

- (R/WL)

Chapter 14 Permission Control (PMS)

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img034_41f31192.png)

31

Register 14.31. PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_0\_REG (0x00B4)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock CPU0’s IBUS interrupt configuration. (R/WL)

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_LOCK

365

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_EN
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_CLR

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_EN
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE

Reset

1
0

1
1

2

![Image](images/14_Chapter_14_img035_841b7765.png)

31

Register 14.32. PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_1\_REG (0x00B8)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 2

Espressif Systems

Set this bit to clear the interrupt triggered when CPU0’s IBUS tries to access SRAM or ROM unau-

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_CLR

thorized. (R/WL)

Set this bit to enable interrupt when CPU0’s IBUS tries to access SRAM or ROM unauthorized.

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_EN

(R/WL)

366

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img036_bde5cfd9.png)

31

Register 14.33. PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_0\_REG (0x00C0)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock the permission of CPU DBUS to internal SRAM. (R/WL)

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_LOCK

367

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_0
ONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
M0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
RE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

Register 14.34. PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_1\_REG (0x00C4)

Espressif Systems

S\_3
MODE\_PMS\_2
\_SRAM\_U\_MODE\_PMS\_1
ONSTRAIN\_SRAM\_U\_MODE\_PMS\_0
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM
PMS\_CORE\_X\_DRAM0\_PMS\_CONST

S\_2
MODE\_PMS\_1
\_SRAM\_U\_MODE\_PMS\_0
RE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM

S\_1
MODE\_PMS\_0
M0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3
RE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MOD

(reserved)

0

1

2

3

4

5

6

## 7

8

![Image](images/14_Chapter_14_img037_85e09e30.png)

0 0 0 0

RE\_X\_DRAM0\_PMS\_CONSTRAIN\_ROM\_U\_MODE\_PMS
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_ROM\_M\_MODE\_PMS
(reserved)
PMS\_CORE\_X\_DRAM0\_PMS\_CON
PMS\_CORE\_X\_DRAM0
PMS\_CORE
P

MODE\_PMS
M0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_3
RE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_2
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_1
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MOD
(reserved)
PMS\_CORE\_X\_DRAM0
P
PMS\_CORE\_X
PM

S
ONSTRAIN\_SRAM\_U\_MODE\_PMS\_3
M0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_2
RE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_1
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_0
(reserved)
PMS\_CORE\_X\_DRAM0\_PMS\_CONST
PMS\_CORE\_X\_DRAM0\_P
PMS\_CORE\_X
PMS

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_ROM\_U\_MODE\_PMS
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_ROM\_M\_MO
(reserved)
PMS\_CORE\_X\_DRAM0
PMS\_CORE

- 0x3 27 26 0x3 25 24
- (reserved) 0 0 0 0 28
- 31 leged environment (R/WL) leged environment (R/WL) ileged environment (R/WL)

368

Submit Documentation Feedback

Configures the permission of CPU’s DBUS to data region2 of SRAM from the priv-

Configures the permission of CPU’s DBUS to instruction region of SRAM from the

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_3

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_0

GoBack privileged environment It’s advised to configure this field to 0. (R/WL)

- Continued on the next page...

ESP32-C3 TRM (Version 1.3)

MODE\_PMS
\_ROM\_M\_MODE\_PMS
RE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_3
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_2
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM
(reserved)
PMS\_CORE\_X
PMS

\_ROM\_U\_MODE\_PMS
ONSTRAIN\_ROM\_M\_MODE\_PMS
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_3
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM
PMS\_CORE\_X\_DRAM0\_PMS\_CONST
(reserved)
PMS

Reset

0x3

0x3

0x3

0x3

Configures the permission of CPU’s DBUS to instruction region of SRAM from the

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_0

Configures the permission of CPU’s DBUS to data region0 of SRAM from the privi-

privileged environment It’s advised to configure this field to 0. (R/WL)
PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_1 Co

Configures the permission of CPU’s DBUS to data region1 of SRAM from the privi-

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_M\_MODE\_PMS\_2

Chapter 14 Permission Control (PMS)

Register 14.34. PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_1\_REG (0x00C4)

Configures the permission of CPU’s DBUS to data region0 of SRAM from the privi-

Configures the permission of CPU’s DBUS to data region1 of SRAM from the privi-

Continued from the previous page...

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_1

Espressif Systems leged environment (R/WL)

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_2

leged environment (R/WL)

Configures the permission of CPU’s DBUS to data region2 of SRAM from the privi-

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_SRAM\_U\_MODE\_PMS\_3

leged environment (R/WL)

Configures the permission of CPU’s DBUS to ROM from the privileged environment

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_ROM\_M\_MODE\_PMS

(R/WL)

Configures the permission of CPU’s DBUS to ROM from the unpriviledged environment.

PMS\_CORE\_X\_DRAM0\_PMS\_CONSTRAIN\_ROM\_U\_MODE\_PMS

(R/WL)

369

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img038_cc056e77.png)

31

Register 14.35. PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_0\_REG (0x00C8)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock CPU’s DBUS interrupt configuration. (R/WL)

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_LOCK

370

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_EN
PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_CLR

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_EN
PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE

Reset

1
0

1
1

2

![Image](images/14_Chapter_14_img039_444ad5a0.png)

31

Register 14.36. PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_1\_REG (0x00CC)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 2

Espressif Systems

Set this bit to clear the interrupt triggered when CPU0’s dBUS tries to access SRAM or ROM

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_CLR

unauthorized. (R/WL)

Set this bit to enable interrupt when CPU0’s dBUS tries to access SRAM or ROM unauthorized.

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_EN

(R/WL)

371

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img040_6c88b472.png)

31

Register 14.37. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_0\_REG (0x00D8)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock CPU permission to different peripherals. (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_LOCK

372

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

TRAIN\_M\_MODE\_GPIO
PMS\_CONSTRAIN\_M\_MODE\_G0SPI\_
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_G0SPI\_
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_UART

PMS\_CONSTRAIN\_M\_MODE\_GPIO
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_G0SPI\_0
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_G0SPI\_1
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE

Register 14.38. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_1\_REG (0x00DC)

C
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_GPIO
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_G0SPI\_0
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_IO\_MUX
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE
(reserved)
PMS

RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_IO\_MU
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_RTC
(reserved)
PMS\_CORE
P

0

1

2

3

4

5

6

7

8

![Image](images/14_Chapter_14_img041_5817a0dc.png)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_UART1
(reserved) 0x3 31 30 (reserved) 0 0 0 0 0 0 0 0 0 0 0 0 29 18 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_UART PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_G0SPI\_1 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_G0SPI\_0 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_GPIO PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_RTC (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_IO\_MUX PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_UART1

Espressif Systems

Configures CPU’s permission to access UART 0 from the privileged environment (R/WL)

Configures CPU’s permission to access SPI 1 from the privileged environment (R/WL)

373

Submit Documentation Feedback

GoBack

Configures CPU’s permission to access IO\_MUX from the privileged environment (R/WL)

Configures CPU’s permission to access UART 1 from the privileged environment (R/WL)

ESP32-C3 TRM (Version 1.3)

MU
MODE\_RTC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_GPIO
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MO
PMS\_CORE\_0\_PIF\_PMS\_CONSTRA
PMS\_CORE\_0\_PIF\_PM

Reset

0x3

0x3

0x3

0x3

Configures CPU’s permission to access SPI 0 from the privileged environment (R/WL)

Configures CPU’s permission to access GPIO from the privileged environment (R/WL)

Configures CPU’s permission to access eFuse Controller &amp; PMU from the privileged environment

Chapter 14 Permission Control (PMS)

(reserved)

TRAIN\_M\_MODE\_RMT
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_UHCI0
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_I2C\_EXT0
(reserved)

RE\_
(reserved)
P

TRAIN\_M\_MODE\_LEDC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_RMT
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONSTR
PMS\_CORE\_0\_PIF\_PM
(reserv

Reset

0 0 0 0

0x3

0x3

0 0

0

3

4

5

6

7

8

![Image](images/14_Chapter_14_img042_29127ee0.png)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_SYSTIMER
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_T
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN
M
(reserved) 0x3 31 30 RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_SYSTIMER
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_TIMERGROUP1
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_TIME
(reserved) 0x3 29 28 PMS\_CONSTRAIN\_M\_MODE\_SYSTIMER
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_TIMERGROUP1
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_TIMERGROUP
(reserved)
PMS\_COR 0x3 27 26 (reserved) 0 0 0 0 0 0 0 0 25 18 0x3 17 16 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_I2C\_EXT0 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_UHCI0 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_RMT ment (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_LEDC (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_TIMERGROUP (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_TIMERGROUP1 (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_SYSTIMER (R/WL)

Register 14.39. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_2\_REG (0x00E0)

ERG
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_LEDC
(reserved)
PMS\_CORE\_0\_PIF\_PMS
(reserved)
PM

Espressif Systems

Configures CPU’s permission to access I2C 0 from the privileged environment (R/WL)

374

Submit Documentation Feedback

GoBack

Configures CPU’s permission to access Timer Group 0 from the privileged environment

Configures CPU’s permission to access Timer Group 1 from the privileged environment

Configures CPU’s permission to access System Timer from the privileged environment

ESP32-C3 TRM (Version 1.3)

C
PMS\_CONSTRAIN\_M\_MODE\_RMT
)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_UHCI0
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MOD
(reserved)

Configures CPU’s permission to access UHCI 0 from the privileged environment (R/WL)

Configures CPU’s permission to access Remote Control Peripheral from the privileged environ-

Configures CPU’s permission to access LED PWM Controller from the privileged environment

Chapter 14 Permission Control (PMS)

N
PMS\_CONSTRAIN\_M\_MODE\_APB\_CT
)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_SPI\_2

Register 14.40. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_3\_REG (0x00E4)

TRAIN\_M\_MODE\_CAN
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_APB\_CTRL
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M

RE\_
(reserved)
P

(reserved)

0

1

2

3

4

5

6

![Image](images/14_Chapter_14_img043_611e0d6a.png)

31

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_I2S1
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONSTR
(reserved)

PMS\_CONSTRAIN\_M\_MODE\_I2S1
)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CAN
(reserved)
PMS\_CORE\_0\_PIF\_PM
(reserved)
P

(reserved)

Espressif Systems

Reset

0x3

0 0

0x3

0 0 0 0

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Configures CPU’s permission to access SPI 2 from the privileged environment (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_SPI\_2

Configures CPU’s permission to access APB Controller from the privileged environment

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_APB\_CTRL

(R/WL)

Configures CPU’s permission to access Two-wire Automotive Interface from the privileged envi-

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CAN

ronment (R/WL)

375

Submit Documentation Feedback

Configures CPU’s permission to access I2S 1 from the privileged environment (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_I2S1

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

RE\_
(reserved)

TRAIN\_M\_MODE\_APB\_ADC
PMS\_CONSTRAIN\_M\_MODE\_CRYPTO\_DMA
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CRYPTO\_PER
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_USB\_WRAP
(reserved)

Register 14.41. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_4\_REG (0x00E8)

Reset

0 0

0x3

CHE\_CONFI
TRAIN\_M\_MODE\_INTERRUPT
PMS\_CONSTRAIN\_M\_MODE\_PMS
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_SYSTEM
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_USB\_DEVICE
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONS
PMS\_CORE\_0\_PIF
P
PMS\_COR

0

1

2

3

4

5

6

MODE\_CACHE\_C
PMS\_CONSTRAIN\_M\_MODE\_INTERRUP
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_PMS
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_SYSTEM
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE
(reserved)
PMS\_CORE\_0
PMS

S
MODE\_SYSTEM
TRAIN\_M\_MODE\_USB\_DEVIC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_APB\_ADC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE
C
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN
M
PMS\_CORE\_0\_PIF\_PMS\_CO
(reserved)

0x3

0x3

0x3

TRAIN\_M\_MODE\_AD
PMS\_CONSTRAIN\_M\_MODE\_CACHE\_CONF
)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_INTERRUPT
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_PM
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M
PMS\_CORE\_0\_PIF\_PMS\_CON
(reserved)

- PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_AD
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_M
(reserved)
PMS\_CORE\_0\_PIF\_P
PMS\_COR 0x3 27 26 0x3 25 24 RE\_
(reserved)
P 0 023 22 0x3 21 20 0x3 19 18

RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_AD
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CACHE\_CONFIG
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MO
PMS\_CORE\_0\_PIF\_PMS\_CONSTRA
PMS\_CORE\_0\_PIF\_PMS
PMS\_CORE

7

8

MODE\_AD
TRAIN\_M\_MODE\_CACHE
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_INTER
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_PMS
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MO
PMS\_CORE\_0\_PIF\_PMS\_CONSTR
(reserved)
P

![Image](images/14_Chapter_14_img044_7e634cb0.png)

| 0x3  17 16  0x3  15 14  (reserved)  0 0 0 0  13  10  9   |
|----------------------------------------------------------|

(reserved) 0 0 0 0 31 28

- Continued on the next page...

B\_DEVICE
PMS\_CONSTRAIN\_M\_MODE\_APB\_ADC
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CRYPTO\_DMA
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CRYPTO\_PERI
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_USB
(reserved)

TEM
MODE\_USB\_DEVICE
RE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_APB\_ADC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CRYPTO\_DMA
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CRYP
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_M
(reserved)

Configures CPU’s permission to access USB OTG External from the privileged environment

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_USB\_WRAP

Configures CPU’s permission to access Accelerators from the privileged environment

Configures CPU’s permission to access GDMA from the privileged environment (R/WL)

Configures CPU’s permission to access ADC Controller from the privileged environment

Configures CPU’s permission to access USB OTG Core from the privileged environment

GoBack

Configures CPU’s permission to access System Registers from the privileged environment

Configures CPU’s permission to access PMS Registers from the privileged environment (R/WL)

Configures CPU’s permission to access Interrupt Matrix from the privileged environment

- (R/WL) (R/WL) (R/WL) (R/WL) (R/WL) (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CRYPTO\_PERI

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CRYPTO\_DMA

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_APB\_ADC

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_USB\_DEVICE

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_SYSTEM

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_PMS

Espressif Systems 376 Submit Documentation Feedback ESP32-C3 TRM (Version 1.3)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_INTERRUPT

Chapter 14 Permission Control (PMS)

Register 14.41. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_4\_REG (0x00E8)

Configures CPU’s permission to access Cache &amp; XTS\_AES from the privileged envi-

Configures CPU’s permission to access Debug Assist from the privileged environment (R/WL)

Continued from the previous page...

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_CACHE\_CONFIG

Espressif Systems ronment (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_M\_MODE\_AD

377

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

TRAIN\_U\_MODE\_GPIO
PMS\_CONSTRAIN\_U\_MODE\_G0SPI\_
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_G0SPI\_
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_UART

PMS\_CONSTRAIN\_U\_MODE\_GPIO
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_G0SPI\_0
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_G0SPI\_1
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE

Register 14.42. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_5\_REG (0x00EC)

RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_GPIO
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_G0SPI\_0
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN

RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_IO\_MU
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_RTC
(reserved)
PMS\_CORE

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_IO\_MUX
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE
(reserved)
PMS

0

1

2

3

4

5

6

7

8

![Image](images/14_Chapter_14_img045_e2e5de53.png)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_UART1
(reserved) 0x3 31 30 (reserved) 0 0 0 0 0 0 0 0 0 0 0 0 29 18 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_UART PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_G0SPI\_1 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_G0SPI\_0 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_GPIO PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_RTC ment. (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_IO\_MUX PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_UART1

Espressif Systems

Configures CPU’s permission to access SPI 1 from the unpriviledged environment. (R/WL)

378

Submit Documentation Feedback

GoBack

Configures CPU’s permission to access IO\_MUX from the unpriviledged environment. (R/WL)

Configures CPU’s permission to access UART 1 from the unpriviledged environment. (R/WL)

ESP32-C3 TRM (Version 1.3)

MU
MODE\_RTC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_GPIO
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MO
PMS\_CORE\_0\_PIF\_PMS\_CONSTR
PMS\_CORE\_0\_PIF\_PM

Reset

0x3

0x3

0x3

0x3

Configures CPU’s permission to access UART 0 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to access SPI 0 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to access GPIO from the unpriviledged environment. (R/WL)

Configures CPU’s permission to access eFuse Controller &amp; PMU from the unpriviledged environ-

Chapter 14 Permission Control (PMS)

(reserved)

TRAIN\_U\_MODE\_RMT
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_UHCI0
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_I2C\_EXT0
(reserved)

RE\_
(reserved)
P

TRAIN\_U\_MODE\_LEDC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_RMT
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONSTR
PMS\_CORE\_0\_PIF\_PM
(reser

Reset

0 0 0 0

0x3

0x3

0 0

0

3

4

5

6

7

8

![Image](images/14_Chapter_14_img046_33480f6d.png)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_SYSTIMER
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_T
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN
(reserved) 0x3 31 30 RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_SYSTIMER
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_TIMERGROUP1
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_TIME
(reserved) 0x3 29 28 PMS\_CONSTRAIN\_U\_MODE\_SYSTIMER
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_TIMERGROUP1
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_TIMERGROUP
(reserved)
PMS\_CO 0x3 27 26 (reserved) 0 0 0 0 0 0 0 0 25 18 0x3 17 16 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_I2C\_EXT0 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_UHCI0 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_RMT ronment. (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_LEDC (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_TIMERGROUP ment. (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_TIMERGROUP1 ment. (R/WL) PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_SYSTIMER (R/WL)

Register 14.43. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_6\_REG (0x00F0)

ERG
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_LEDC
(reserved)
PMS\_CORE\_0\_PIF\_PM
(reserved)
P

Espressif Systems

Configures CPU’s permission to access I2C 0 from the unpriviledged environment. (R/WL)

379

Submit Documentation Feedback

GoBack

Configures CPU’s permission to access Timer Group 0 from the unpriviledged environ-

Configures CPU’s permission to access Timer Group 1 from the unpriviledged environ-

Configures CPU’s permission to access System Timer from the unpriviledged environment.

ESP32-C3 TRM (Version 1.3)

C
PMS\_CONSTRAIN\_U\_MODE\_RMT
)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_UHCI0
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MOD
(reserved)

Configures CPU’s permission to access UHCI 0 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to access Remote Control Peripheral from the unpriviledged envi-

Configures CPU’s permission to access LED PWM Controller from the unpriviledged environment.

Chapter 14 Permission Control (PMS)

PMS\_CONSTRAIN\_U\_MODE\_APB\_CT
)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_SPI\_2

Register 14.44. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_7\_REG (0x00F4)

TRAIN\_U\_MODE\_CAN
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_APB\_CTRL
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN
U

RE\_
(reserved)
P

(reserved)

0

1

2

3

4

5

6

![Image](images/14_Chapter_14_img047_d1bde206.png)

(R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_I2S1
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONST
(reserved)

PMS\_CONSTRAIN\_U\_MODE\_I2S1
)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CAN
(reserved)
PMS\_CORE\_0\_PIF\_PM
(reserved)

Reset

0x3

0 0

0x3

0 0 0 0

(reserved) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_SPI\_2 PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_APB\_CTRL PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CAN PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_I2S1

Espressif Systems environment. (R/WL)

380

Submit Documentation Feedback

Configures CPU’s permission to access SPI 2 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to access APB Controller from the unpriviledged environment.

Configures CPU’s permission to access Two-wire Automotive Interface from the unpriviledged

Configures CPU’s permission to access I2S 1 from the unpriviledged environment. (R/WL)

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

RE\_
(reserved)

TRAIN\_U\_MODE\_APB\_ADC
PMS\_CONSTRAIN\_U\_MODE\_CRYPTO\_DMA
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CRYPTO\_PER
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_USB\_WRAP
(reserved)

Register 14.45. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_8\_REG (0x00F8)

0

1

2

HE\_CONFI
TRAIN\_U\_MODE\_INTERRUPT
PMS\_CONSTRAIN\_U\_MODE\_PMS
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_SYSTEM
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_USB\_DEVICE
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONS
PMS\_CORE\_0\_PIF
PMS\_CO

3

4

5

6

MODE\_CACHE\_C
PMS\_CONSTRAIN\_U\_MODE\_INTERRUP
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_PMS
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_SYSTEM
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE
(reserved)
PMS\_CORE\_0
PMS

S
MODE\_SYSTEM
TRAIN\_U\_MODE\_USB\_DEVIC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_APB\_ADC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE
C
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN
PMS\_CORE\_0\_PIF\_PMS\_CO
(reserved)

7

8

MODE\_AD
TRAIN\_U\_MODE\_CACHE
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_INTER
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_PMS
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MO
PMS\_CORE\_0\_PIF\_PMS\_CONSTR
(reserved)
P

RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_AD
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CACHE\_CONFIG
(reserved)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MO
PMS\_CORE\_0\_PIF\_PMS\_CONSTR
PMS\_CORE\_0\_PIF\_PM
PMS\_CORE

TRAIN\_U\_MODE\_AD
PMS\_CONSTRAIN\_U\_MODE\_CACHE\_CONF
)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_INTERRUPT
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_PM
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U
PMS\_CORE\_0\_PIF\_PMS\_CON
(reserved)

![Image](images/14_Chapter_14_img048_c0b27cac.png)

| 0x3  17 16  0x3  15 14  (reserved)  0 0 0 0  13  10  9   |
|----------------------------------------------------------|

- (reserved) 28 27 26

Reset

0 0

0x3

0x3

0x3

0x3

- PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_AD
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_M
(reserved)
PMS\_CORE\_0\_PIF\_P
PMS\_COR 0x3 0x3 25 24 RE\_
(reserved)
P 0 023 22 0x3 21 20 0x3 19 18
- 0 0 0 0 31

Configures CPU’s permission to access USB OTG External from the unpriviledged environ-

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_USB\_WRAP

Configures CPU’s permission to access Accelerators from the unpriviledged environ-

Configures CPU’s permission to access GDMA from the unpriviledged environment.

Configures CPU’s permission to access ADC Controller from the unpriviledged environment.

Configures CPU’s permission to access USB OTG Core from the unpriviledged environ-

GoBack

Configures CPU’s permission to access System Registers from the unpriviledged environment.

Configures CPU’s permission to access PMS Registers from the unpriviledged environment.

Configures CPU’s permission to access Interrupt Matrix from the unpriviledged environ-

Configures CPU’s permission to access Cache &amp; XTS\_AES from the unpriviledged

- ment. (R/WL) ment. (R/WL) (R/WL) (R/WL) ment. (R/WL) (R/WL) (R/WL) ment. (R/WL) environment. (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CRYPTO\_PERI

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CRYPTO\_DMA

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_APB\_ADC

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_USB\_DEVICE

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_SYSTEM

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_PMS

- Espressif Systems 381 ESP32-C3 TRM (Version 1.3)

Submit Documentation Feedback

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CACHE\_CONFIG

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_INTERRUPT

\_DEVICE
PMS\_CONSTRAIN\_U\_MODE\_APB\_ADC
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CRYPTO\_DMA
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CRYPTO\_PERI
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_USB
(reserved)

TEM
MODE\_USB\_DEVICE
RE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_APB\_ADC
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CRYPTO\_DMA
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_CRYP
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_M
(reserved)

Configures CPU’s permission to access Debug Assist from the unpriviledged environment. (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_U\_MODE\_AD

Chapter 14 Permission Control (PMS)

Register 14.46. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_9\_REG (0x00FC)

R\_U\_MODE
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_SPLTADDR\_M\_MODE

0

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_SPLTADDR\_U\_MODE
PMS\_COR

0x7ff

![Image](images/14_Chapter_14_img049_0240231d.png)

Espressif Systems

382

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

(reserved) 0 0 0 0 0 0 0 0 0 0 31 22

Reset

Configures the address to split RTC Fast Memory into two regions in unpriv-

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_SPLTADDR\_M\_MODE

Configures the address to split RTC Fast Memory into two regions in privilege-

iledgeddenvironment for CPU. Note you should use address offset, instead of absolute address. (R/WL)
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_SPLTADDR\_U\_MODE Configures the address to split RTC

denvironment for CPU. Note you should use address offset, instead of absolute address. (R/WL)

GoBack

Chapter 14 Permission Control (PMS)

\_U\_MODE\_H
TRAIN\_RTCFAST\_U\_MODE\_L
\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_M\_MODE\_H
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_M\_MODE\_L

Register 14.47. PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_10\_REG (0x0100)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_U\_MODE\_H
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAS
PMS\_CORE\_0\_PIF\_PMS\_CON
PMS\_CORE

Espressif Systems

TRAIN\_RTCFAST\_U\_MODE\_H
\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_U\_MODE\_L
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_M\_MODE\_H
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAS

\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_U\_MODE\_H
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_U\_MODE\_L
PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFA
PMS\_CORE\_0\_PIF\_PMS\_CO

0

2

3

5

6

8

![Image](images/14_Chapter_14_img050_5ec1e07a.png)

Configures the permission of CPU from unpriviledgeddenvironment to the lower region of

Configures the permission of CPU from unpriviledgeddenvironment to the higher region

Configures the permission of CPU from privilegedenvironment to the lower region of RTC

Configures the permission of CPU from privilegedenvironment to the higher region of RTC

- 31 of RTC Fast Memory. (R/WL)

Reset

0x7

0x7

0x7

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_M\_MODE\_L

- RTC Fast Memory. (R/WL) Fast Memory. (R/WL) Fast Memory. (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_M\_MODE\_H

383

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_U\_MODE\_L

PMS\_CORE\_0\_PIF\_PMS\_CONSTRAIN\_RTCFAST\_U\_MODE\_H

ESP32-C3 TRM (Version 1.3)

Submit Documentation Feedback

GoBack

Chapter 14 Permission Control (PMS)

PMS\_REGION\_PMS\_CONSTRAIN\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img051_ebddab9e.png)

31

Register 14.48. PMS\_REGION\_PMS\_CONSTRAIN\_0\_REG (0x0104)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock Core0’s permission to peripheral regions. (R/WL)

PMS\_REGION\_PMS\_CONSTRAIN\_LOCK

384

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

E\_AREA\_4
N\_M\_MODE\_AREA\_3
\_CONSTRAIN\_M\_MODE\_AREA\_2
GION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_1
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_0

E\_AREA\_5
N\_M\_MODE\_AREA\_4
\_CONSTRAIN\_M\_MODE\_AREA\_3
GION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_2
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_1
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE

Register 14.49. PMS\_REGION\_PMS\_CONSTRAIN\_1\_REG (0x0108)

PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_6
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE
PMS\_REGION\_PMS\_CONSTRAIN
PMS\_REGION\_PMS\_C
PMS\_REGI

GION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_6
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_5
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE
PMS\_REGION\_PMS\_CONSTRAIN
PMS\_REGION\_PMS\_C
PMS\_REGI

\_CONSTRAIN\_M\_MODE\_AREA\_6
GION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_5
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_4
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE
PMS\_REGION\_PMS\_CONSTRAIN
PMS\_REGION\_PMS
C
PMS\_REGI

Reset

0x3

0x3

0x3

0x3

0x3

(reserved) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 14 PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_0 PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_1 PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_2 PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_3 PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_4 PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_5 PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_6

Espressif Systems

0

1

2

3

4

5

6

7

8

![Image](images/14_Chapter_14_img052_c57e2c41.png)

Configures CPU’s permission to Peri Region0 from the privileged environment (R/WL)

Configures CPU’s permission to Peri Region1 from the privileged environment (R/WL)

Configures CPU’s permission to Peri Region2 from the privileged environment (R/WL)

Configures CPU’s permission to Peri Region3 from the privileged environment (R/WL)

Configures CPU’s permission to Peri Region4 from the privilegedenvironment (R/WL)

Configures CPU’s permission to Peri Region5 from the privileged environment (R/WL)

GoBack

Configures CPU’s permission to Peri Region6 from the privileged environment (R/WL)

385

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

E\_AREA\_6
N\_M\_MODE\_AREA\_5
\_CONSTRAIN\_M\_MODE\_AREA\_4
GION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_3
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_2
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE
PMS\_REGION\_PMS\_CONSTRAIN

N\_M\_MODE\_AREA\_6
\_CONSTRAIN\_M\_MODE\_AREA\_5
GION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_4
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE\_AREA\_3
PMS\_REGION\_PMS\_CONSTRAIN\_M\_MODE
PMS\_REGION\_PMS\_CONSTRAIN
PMS\_REGION\_PMS\_C

Chapter 14 Permission Control (PMS)

E\_AREA\_4
N\_U\_MODE\_AREA\_3
\_CONSTRAIN\_U\_MODE\_AREA\_2
GION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_1
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_0

GION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_6
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_5
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE
PMS\_REGION\_PMS\_CONSTRAIN
PMS\_REGION\_PMS
PMS\_REG

E\_AREA\_5
N\_U\_MODE\_AREA\_4
\_CONSTRAIN\_U\_MODE\_AREA\_3
GION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_2
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_1
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE

PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_6
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE
PMS\_REGION\_PMS\_CONSTRAIN
PMS\_REGION\_PMS
PMS\_REG

\_CONSTRAIN\_U\_MODE\_AREA\_6
GION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_5
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_4
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE
PMS\_REGION\_PMS\_CONSTRAIN
PMS\_REGION\_PMS
PMS\_REG

Reset

0x3

0x3

0x3

0x3

0x3

(reserved) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 14 PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_0 PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_1 PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_2 PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_3 PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_4 PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_5 PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_6

Register 14.50. PMS\_REGION\_PMS\_CONSTRAIN\_2\_REG (0x010C)

Espressif Systems

N\_U\_MODE\_AREA\_6
\_CONSTRAIN\_U\_MODE\_AREA\_5
GION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_4
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_3
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE
PMS\_REGION\_PMS\_CONSTRAIN
PMS\_REGION\_PMS

E\_AREA\_6
N\_U\_MODE\_AREA\_5
\_CONSTRAIN\_U\_MODE\_AREA\_4
GION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_3
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE\_AREA\_2
PMS\_REGION\_PMS\_CONSTRAIN\_U\_MODE
PMS\_REGION\_PMS\_CONSTRAIN

0

1

2

3

4

5

6

7

8

![Image](images/14_Chapter_14_img053_296469d0.png)

Configures CPU’s permission to Peri Region0 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to Peri Region1 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to Peri Region2 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to Peri Region3 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to Peri Region4 from the unpriviledged environment. (R/WL)

Configures CPU’s permission to Peri Region5 from the unpriviledged environment. (R/WL)

GoBack

Configures CPU’s permission to Peri Region6 from the unpriviledged environment. (R/WL)

386

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

Reset

Register 14.51. PMS\_REGION\_PMS\_CONSTRAIN\_3\_REG (0x0110)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_0

(reserved)

Espressif Systems

0

0

![Image](images/14_Chapter_14_img054_8befb23d.png)

Configures the starting address of Region0 for CPU0. (R/WL)
Register 14.52. PMS\_REGION\_PMS\_CONSTRAIN\_4\_REG (0x0114)

Configures the starting address of Region1 for CPU0. (R/WL)

![Image](images/14_Chapter_14_img055_f525b01a.png)

387

Submit Documentation Feedback

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_1

ESP32-C3 TRM (Version 1.3)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_0

Reset

GoBack

Chapter 14 Permission Control (PMS)

Reset

Register 14.53. PMS\_REGION\_PMS\_CONSTRAIN\_5\_REG (0x0118)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_2

(reserved)

Espressif Systems

0

0

![Image](images/14_Chapter_14_img056_6554553d.png)

Configures the starting address of Region2 for CPU0. (R/WL)
Register 14.54. PMS\_REGION\_PMS\_CONSTRAIN\_6\_REG (0x011C)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_3

Configures the starting address of Region3 for CPU0. (R/WL)

![Image](images/14_Chapter_14_img057_86983ac0.png)

388

Submit Documentation Feedback

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_3

ESP32-C3 TRM (Version 1.3)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_2

Reset

GoBack

Chapter 14 Permission Control (PMS)

Reset

Register 14.55. PMS\_REGION\_PMS\_CONSTRAIN\_7\_REG (0x0120)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_4

(reserved)

Espressif Systems

0

0

![Image](images/14_Chapter_14_img058_39575926.png)

4 Configures the starting address of Region4 for CPU0. (R/WL)
Register 14.56. PMS\_REGION\_PMS\_CONSTRAIN\_8\_REG (0x0124)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_5

Configures the starting address of Region5 for CPU0. (R/WL)

![Image](images/14_Chapter_14_img059_fca5b21a.png)

389

Submit Documentation Feedback

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_5

ESP32-C3 TRM (Version 1.3)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_4

Reset

GoBack

Chapter 14 Permission Control (PMS)

Reset

Register 14.57. PMS\_REGION\_PMS\_CONSTRAIN\_9\_REG (0x0128)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_6

(reserved)

Espressif Systems

0

0

![Image](images/14_Chapter_14_img060_f24365ce.png)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_7

Configures the starting address of Region7 for CPU0. (R/WL)

![Image](images/14_Chapter_14_img061_79ac2852.png)

6 Configures the starting address of Region6 for CPU0. (R/WL)
Register 14.58. PMS\_REGION\_PMS\_CONSTRAIN\_10\_REG (0x012C)

390

Submit Documentation Feedback

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_7

ESP32-C3 TRM (Version 1.3)

PMS\_REGION\_PMS\_CONSTRAIN\_ADDR\_6

Reset

GoBack

Chapter 14 Permission Control (PMS)

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img062_5aa64dca.png)

31

Register 14.59. PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_0\_REG (0x0130)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock CPU’s PIF interrupt configuration. (R/WL)

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_LOCK

391

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_EN
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_CLR

Reset

1
0

1
1

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_EN
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE

2

![Image](images/14_Chapter_14_img063_470607d4.png)

31

Register 14.60. PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_1\_REG (0x0134)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 2

Espressif Systems

Set this bit to clear the interrupt triggered when CPU’s PIF bus tries to access RTC memory or pe-

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_CLR

Set this bit to enable interrupt when CPU’s PIF bus tries to access RTC memory or peripherals unau-

ripherals unauthorized. (R/WL)
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_EN

thorized. (R/WL)

392

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_EN
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_CLR

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_EN
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE

Reset

1
0

1
1

2

![Image](images/14_Chapter_14_img064_d50f34b6.png)

31

Register 14.61. PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_4\_REG (0x0140)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 2

Espressif Systems

Set this bit to clear the interrupt triggered when CPU’s PIF bus tries to access RTC mem-

Set this bit to enable interrupt when CPU’s PIF bus tries to access RTC memory or periph-

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_CLR

ory or peripherals using unsupported data type. (R/WL)
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_EN

erals using unsupported data type. (R/WL)

393

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

ved)
PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_INTR

Register 14.62. PMS\_DMA\_APBPERI\_PMS\_MONITOR\_2\_REG (0x0088)

Espressif Systems

(reserved)
PMS

Reset

0
0

1

2

0 0

3

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR

![Image](images/14_Chapter_14_img065_c3e4e136.png)

(reserved) 0 0 0 0 0 31 27 26

Stores unauthorized DMA access interrupt status. (RO)

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_INTR

Stores the address that triggered the unauthorized DMA address.

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR

Note that this is an offset to 0x3c000000 and the unit is 16, which means the actual address should be 0x3c000000 +

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR

394

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

APBPERI\_PMS\_MONITOR\_VIOLATE\_STATUS\_BYTE
PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_STATUS\_WR

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_STATUS\_BYTEEN
PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_STAT

Register 14.63. PMS\_DMA\_APBPERI\_PMS\_MONITOR\_3\_REG (0x008C)

Espressif Systems

4

5

![Image](images/14_Chapter_14_img066_aded9906.png)

31

Reset

0
0

1

0

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Store the direction of unauthorized GDMA access. 1: write, 0: read. (RO)

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_STATUS\_WR

Stores the byte information of unauthorized GDMA access. (RO)

PMS\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_STATUS\_BYTEEN

395

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

AM0\_PMS\_MONITOR\_VIOLATE\_STATUS
RE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS
S\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_INTR

CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WORLD
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_LOADSTORE
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WR
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_INTR

\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WOR
S\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_LOAD
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WR
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_INTR

Register 14.64. PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_2\_REG (0x00BC)

Espressif Systems

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WORLD
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS
L
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STAT
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE

Stores the interrupt status of CPU’s unauthorized IBUS access. (RO)

4

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR

5

![Image](images/14_Chapter_14_img067_569fe4e7.png)

(reserved)
0 0 031 29
28 31 29 28 PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_INTR

Indicates the access direction. 1: write, 0: read. Note that this field is only valid when

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WR

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_LOADSTORE

396

Submit Documentation Feedback

Stores the address that CPU’s IBUS was trying to access unautho-

privilegedenvironment, 0x10: unpriviledged environment. (RO)
PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR

GoBack rized. Note that this is an offset to 0x40000000 and the unit is 4, which means the actual address should be 0x40000000 +

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR * 4. (RO)

ESP32-C3 TRM (Version 1.3)

Reset

0
0

0
1

0
2

3

0

Indicates the instruction direction. 1: load/store, 0: instruction execution. (RO)

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_LOADSTORE

Stores the privileged mode the CPU was in when the illegal access happened. 0x01:

PMS\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WORLD

Chapter 14 Permission Control (PMS)

\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS
erved)
PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_INTR

Register 14.65. PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_2\_REG (0x00D0)

Espressif Systems

CORE\_
(reserved)
PMS\_C

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WORLD
(reserved)
PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_INTR

3

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR

4

![Image](images/14_Chapter_14_img068_0775beae.png)

28 27

(reserved) 0 0 0 0 31

Stores the interrupt status of dBUS unauthorized access. (RO)

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_INTR

Stores the privileged mode the CPU was in when the illegal access happened. 0x01:

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WORLD

Stores the address that CPU0’s dBUS was trying to access unauthorized.

privilegedenvironment, 0x10: unpriviledged environment. (RO)
PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR

397

Submit Documentation Feedback

Reset

0
0

0
1

2

0

Note that this is an offset to 0x3c000000 and the unit is 16, which means the actual address should be 0x3c000000 +

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_ADDR

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_BYTE
PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WR

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_BYTEEN
PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STAT

Register 14.66. PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_3\_REG (0x00D4)

Espressif Systems

4

5

![Image](images/14_Chapter_14_img069_a067137f.png)

31

Reset

0
0

1

0

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Stores the direction of unauthorized access. 0: read, 1: write. (RO)

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_WR

Stores the byte information of illegal access. (RO)

PMS\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_STATUS\_BYTEEN

398

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

R\_VIOLATE\_STATUS
MONITOR\_VIOLATE\_STATUS
\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS
S\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_INTR

F\_PMS\_MONITOR\_VIOLATE\_STATUS\_HWORL
RE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HWRITE
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HSIZE
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATU
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE

ONITOR\_VIOLATE\_STATUS\_HWORLD
PMS\_MONITOR\_VIOLATE\_STATUS\_HWRITE
RE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HSIZE
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HPORT\_0
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_INTR

Register 14.67. PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_2\_REG (0x0138)

Espressif Systems

CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HWORLD
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HWRITE
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLAT
PMS\_CORE\_0\_PIF\_PMS\_MONITOR
V

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HWORLD
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HW
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE
S
PMS\_CORE\_0\_PIF\_PMS\_MONITOR
PMS\_CORE\_0\_PIF\_PMS\_MON

7

8

![Image](images/14_Chapter_14_img070_5f6d1acf.png)

31

Reset

0
0

0
1

2

0

4

0
5

6

0

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Stores the interrupt status of PIF bus unauthorized access. (RO)

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_INTR

Stores the type of unauthorized access. 0: instruction. 1: data. (RO)

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HPORT\_0

Stores the data type of unauthorized access. 0: byte. 1: half-word. 2: word. (RO)

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HSIZE

399

Submit Documentation Feedback

Stores the direction of unauthorized access. 0: read. 1: write. (RO)

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HWRITE

Stores the privileged mode the CPU was in when the unauthorized access happened.

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HWORLD

01: privileged environment 10: unpriviledged environment. (RO)

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

Register 14.68. PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_3\_REG (0x013C)
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HADDR

Espressif Systems

0

![Image](images/14_Chapter_14_img071_f95c8f23.png)

31

Stores the address that CPU’s PIF bus was trying to access unauthorized. (RO)

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_STATUS\_HADDR

400

Submit Documentation Feedback

Reset

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

F\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS
CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_INTR

RE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS\_HWORL
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS\_HSIZE
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_INTR

Register 14.69. PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_5\_REG (0x0144)

Espressif Systems

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS\_HWORLD
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE

2

3

4

5

![Image](images/14_Chapter_14_img072_cd300316.png)

Reset

0
0

1

0

0

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

31 PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_INTR PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS\_HSIZE PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS\_HWORLD happened. 01: privileged environment 10: unpriviledged environment. (RO)

401

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Stores the interrupt status of PIF upsupported data type. (RO)

Stores the data type when the unauthorized access happened. (RO)

Stores the privileged mode the CPU was in when the unauthorized access

GoBack

Chapter 14 Permission Control (PMS)

Register 14.70. PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_6\_REG (0x0148)
PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS\_HADDR

Espressif Systems

0

Reset

Stores the address that CPU’s PIF bus was trying to access using unsup-

PMS\_CORE\_0\_PIF\_PMS\_MONITOR\_NONWORD\_VIOLATE\_STATUS\_HADDR

PMS\_CLK\_EN

Reset

1
0

1

![Image](images/14_Chapter_14_img073_a1e8d951.png)

31

Register 14.71. PMS\_CLOCK\_GATE\_REG\_REG (0x0170)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1 31

![Image](images/14_Chapter_14_img074_fe5f3d64.png)

402

Submit Documentation Feedback

GoBack

Set this bit to force the clock gating always on. (R/W)

PMS\_CLK\_EN

ESP32-C3 TRM (Version 1.3)

ported data type. (RO)

Chapter 14 Permission Control (PMS)

Reset

0

Reset

00

SYSCON\_EXT\_MEM\_PMS\_LOCK

1

![Image](images/14_Chapter_14_img075_3688804f.png)

31

Espressif Systems

31

Register 14.73. SYSCON\_EXT\_MEM\_PMS\_LOCK\_REG (0x0020) (reserved) 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 31 1

403

Submit Documentation Feedback

Register 14.72. PMS\_DATE\_REG (0x0FFC)

(reserved)

0 0 0 0

Date register. (R/W)

PMS\_DATE

SYSCON\_EXT\_MEM\_PMS\_LOCK

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

n\_ATTR

)

n

: 0 - 3) (0x0028 + 4*

n

\_ATTR\_REG (

n

Register 14.74. SYSCON\_FLASH\_ACE

Espressif Systems

SYSCON\_FLASH\_ACEn

0xff

![Image](images/14_Chapter_14_img076_6c1bf26a.png)

SYSCON\_FLASH\_ACE

Reset

En

0

)

n

: 0-3) (0x0038 + 4*

404

Submit Documentation Feedback

0

Reset

. The size of each region should be aligned to 64 KB. (R/W)

SYSCON\_FLASH\_ACE0\_ADDR\_S

ESP32-C3 TRM (Version 1.3)

GoBack

Chapter 14 Permission Control (PMS)

Reset

0

15

16

31

length of Flash Region
n. The size of each region should be aligned to 64 KB. (R/W)
Register 14.77. SYSCON\_SPI\_MEM\_PMS\_CTRL\_REG (0x0088)

6

7

![Image](images/14_Chapter_14_img077_7fff8301.png)

n

Configure the length of Flash Region

(reserved)

![Image](images/14_Chapter_14_img078_fde0efdf.png)

Reset

0
0

0
1

2

0x0

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Indicates exception accessing external memory and triggers an interrupt. (RO)

Set this bit to clear the exception status. (WT)

Stores the exception cause: invalid region, overlapping regions, illegal write, illegal read and illegal instruction execu-

SYSCON\_FLASH\_ACE tion. (RO)

405

Submit Documentation Feedback

SYSCON\_SPI\_MEM\_REJECT\_INT

SYSCON\_SPI\_MEM\_REJECT\_CLR

SYSCON\_SPI\_MEM\_REJECT\_CDE

ESP32-C3 TRM (Version 1.3)

)

n

: 0-3) (0x0048 + 4*

n

\_SIZE\_REG (

n

Register 14.76. SYSCON\_FLASH\_ACE

(reserved)

Espressif Systems n\_SIZE

SYSCON\_FLASH\_ACEn

En

0x1000

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

\_REJECT\_CDE
CON\_SPI\_MEM\_REJECT\_CLR
SYSCON\_SPI\_MEM\_REJECT\_INT

MEM\_REJECT\_CDE
SYSCON\_SPI\_MEM\_REJECT\_CLR
SYSCON\_SPI\_MEM\_REJECT

SYSCON\_SPI\_MEM\_REJECT\_CDE
SYSCON\_SPI\_MEM
SYSCON\_SPI

GoBack

Chapter 14 Permission Control (PMS)

Reset

0

Register 14.78. SYSCON\_SPI\_MEM\_REJECT\_ADDR\_REG (0x008C)
SYSCON\_SPI\_MEM\_REJECT\_ADDR
0x000000

EXTMEM\_IBUS\_PMS\_LOCK

Reset

0
0

1

![Image](images/14_Chapter_14_img079_694155a1.png)

31

Espressif Systems

![Image](images/14_Chapter_14_img080_e426b78f.png)

Store the execption address.(RO)

SYSCON\_SPI\_MEM\_REJECT\_ADDR

Register 14.79. EXTMEM\_IBUS\_PMS\_TBL\_LOCK\_REG (0x00D8)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

406

Submit Documentation Feedback

Set this bit to lock IBUS’ access to Cache IBUS regions. (R/W)

EXTMEM\_IBUS\_PMS\_LOCK

ESP32-C3 TRM (Version 1.3)

GoBack

Chapter 14 Permission Control (PMS)

EXTMEM\_IBUS\_PMS\_BOUNDARY0

0

11

12

31

Reset

0x0

EXTMEM\_IBUS\_PMS\_BOUNDARY1

Reset

0x800

![Image](images/14_Chapter_14_img081_5e0e8217.png)

(reserved)

![Image](images/14_Chapter_14_img082_c08fc21c.png)

407

Submit Documentation Feedback

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Configures the starting address of Cache IBUS Region2.(R/W)

EXTMEM\_IBUS\_PMS\_BOUNDARY1

ESP32-C3 TRM (Version 1.3)

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Register 14.80. EXTMEM\_IBUS\_PMS\_TBL\_BOUNDARY0\_REG (0x00DC)

(reserved)

Espressif Systems

Configures the starting address of Cache IBUS Region1. (R/W)
Register 14.81. EXTMEM\_IBUS\_PMS\_TBL\_BOUNDARY1\_REG (0x00E0)

EXTMEM\_IBUS\_PMS\_BOUNDARY0

0

GoBack

Chapter 14 Permission Control (PMS)

EXTMEM\_IBUS\_PMS\_BOUNDARY2

0

11

12

31

Reset

0x800

![Image](images/14_Chapter_14_img083_29bfacc2.png)

Configures the starting address of Cache IBUS Region3. (R/W)

EXTMEM\_IBUS\_PMS\_BOUNDARY2

408

Submit Documentation Feedback

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Register 14.82. EXTMEM\_IBUS\_PMS\_TBL\_BOUNDARY2\_REG (0x00E4)

(reserved)

Espressif Systems

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

S\_SCT2\_ATTR 
EXTMEM\_IBUS\_PMS\_SCT1\_ATTR

0

3

4

EXTMEM\_IBUS\_PMS\_SCT2\_ATTR 
EXTMEM\_IBU

7

8

- 31

Reset

0xf

0xf

![Image](images/14_Chapter_14_img084_c0ab60d1.png)

Configures IBUS’ access to Cache IBUS Region1.

EXTMEM\_IBUS\_PMS\_SCT1\_ATTR

(R/W)

Bit 0: Instruction execution access in the privileged environment Bit 1: Read access in the privileged environment Bit 2: Instruction execution access in the unprivileged environment Bit 3: Read access in the unprivileged environment

Configures IBUS’ access to Cache IBUS Region2.

EXTMEM\_IBUS\_PMS\_SCT2\_ATTR

Bit 0: Instruction execution access in the privileged environment Bit 1: Read access in the privileged environment Bit 2: Instruction execution access in the unprivileged environment Bit 3: Read access in the unprivileged environment

409

Submit Documentation Feedback

(R/W)

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Register 14.83. EXTMEM\_IBUS\_PMS\_TBL\_ATTR\_REG (0x00E8)

## (reserved)

Espressif Systems

GoBack

ESP32-C3 TRM (Version 1.3)

Chapter 14 Permission Control (PMS)

EXTMEM\_DBUS\_PMS\_LOCK

Reset

0
0

1

31

Register 14.84. EXTMEM\_DBUS\_PMS\_TBL\_LOCK\_REG (0x00EC)
(reserved)
0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 031 1

Espressif Systems

Set this bit to lock DBUS’ access to Cache DBUS regions. (R/W)
Register 14.85. EXTMEM\_DBUS\_PMS\_TBL\_BOUNDARY0\_REG (0x00F0)

EXTMEM\_DBUS\_PMS\_LOCK

EXTMEM\_DBUS\_PMS\_BOUNDARY0

Reset

0x0

![Image](images/14_Chapter_14_img085_4a1c33b8.png)

(reserved)

![Image](images/14_Chapter_14_img086_6f8e08ec.png)

410

Submit Documentation Feedback

Configures the starting address of Cache DBUS Region1. (R/W)

EXTMEM\_DBUS\_PMS\_BOUNDARY0

ESP32-C3 TRM (Version 1.3)

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

0

GoBack

Chapter 14 Permission Control (PMS)

EXTMEM\_DBUS\_PMS\_BOUNDARY1

0

11

12

31

Reset

0x800

EXTMEM\_DBUS\_PMS\_BOUNDARY2

Reset

0x800

![Image](images/14_Chapter_14_img087_6f881521.png)

(reserved)

![Image](images/14_Chapter_14_img088_3ca04a59.png)

411

Submit Documentation Feedback

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Configures the starting address of Cache DBUS Region3. (R/W)

EXTMEM\_DBUS\_PMS\_BOUNDARY2

ESP32-C3 TRM (Version 1.3)

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Register 14.86. EXTMEM\_DBUS\_PMS\_TBL\_BOUNDARY1\_REG (0x00F4)

(reserved)

Espressif Systems

Configures the starting address of Cache DBUS Region2. (R/W)
Register 14.87. EXTMEM\_DBUS\_PMS\_TBL\_BOUNDARY2\_REG (0x00F8)

EXTMEM\_DBUS\_PMS\_BOUNDARY1

0

GoBack

Chapter 14 Permission Control (PMS)

\_DBUS\_PMS\_SCT2\_ATTR
EXTMEM\_DBUS\_PMS\_SCT1\_ATTR

0

1

2

EXTMEM\_DBUS\_PMS\_SCT2\_ATTR
EXTMEM\_DBUS\_PMS\_SC

3

4

31

Reset

3

3

![Image](images/14_Chapter_14_img089_d224a043.png)

Configures DBUS’ access to Cache DBUS Region1.

EXTMEM\_DBUS\_PMS\_SCT1\_ATTR

Bit 0: Read access in the privileged environmentBit 1: Read access in the unprivileged environment

(R/W)

Configures DBUS’ access to Cache DBUS Region2.

EXTMEM\_DBUS\_PMS\_SCT2\_ATTR

Bit 0: Read access in the privileged environmentBit 1: Read access in the unprivileged environment

(R/W)

412

Submit Documentation Feedback

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Register 14.88. EXTMEM\_DBUS\_PMS\_TBL\_ATTR\_REG (0x00FC)

(reserved)

Espressif Systems

GoBack

ESP32-C3 TRM (Version 1.3)
