---
chapter: 16
title: "Chapter 16"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 16

## Permission Control (PMS)

## 16.1 Overview

The permission management of ESP32-C6 can be divided into two parts: PMP (Physical Memory Protection) and APM (Access Permission Management).

The areas managed by PMP and APM are shown in the table 16.1-1. The first column lists the masters and the first row lists the slaves. For the CPU, the permission management relation between PMP and APM is shown in Figure 16.1-1 .

For example, to access the ROM, the master HP CPU needs the permission from PMP; and to access the LP\_MEM, the master HP CPU needs permission from PMP and APM. It is worth noting that HP CPU passes the PMP permission management first and then the APM. If the PMP check fails, the APM permission management will not be triggered.

For HP CPU, PMP manages the access permission of all address spaces, but APM can't manage HP CPU's access to HP\_MEM and ROM.

Table 16.1-1. Management Area of PMP and APM

|            | ROM   | HP_MEM   | LP_MEM    | CPU_PERI 1   | HP_PERI 2   | LP_PERI 3   |
|------------|-------|----------|-----------|--------------|-------------|-------------|
| HP CPU     | PMP   | PMP      | PMP + APM | PMP + APM    | PMP + APM   | PMP + APM   |
| LP CPU     | N/A   | APM      | APM       | N/A          | APM         | APM         |
| SDIO slave | N/A   | APM      | APM       | APM          | APM         | APM         |
| Others4    | N/A   | APM      | APM       | N/A          | N/A         | N/A         |

Figure 16.1-1. PMP-APM Management Relation

![Image](images/16_Chapter_16_img001_aec23617.png)

PMP related registers are located inside HP CPU and can be read or configured by special instructions. For how to configure PMP, please refer to chapter High-Performance CPU &gt; Physical Memory Protection .

APM module contains two parts: TEE (Trusted Execution Environment) controller and APM controller. Each of them contains its own register module: TEE register module and APM register module.

- The TEE controller is responsible for configuring the security mode of a particular master in ESP32-C6 (such as DMA, which can access memory as a master). There are four types of security mode: TEE, REE0 (Rich Execution Environment), REE1, REE2.
- The APM controller is responsible for managing a master's access permissions (read/write/execute) when accessing memory and peripheral registers. By comparing the pre-configured address ranges and corresponding access permissions with the information carried on the bus, such as ID number (please refer to the table 18.4-5 in Chapter 18 Debug Assistant (ASSIST\_DEBUG)), security mode, access address, access permissions, etc, APM determines whether access is allowed.

TEE related registers are used to configure the security mode of each master, and the APM related registers are used to specify the access permission and access address range of each security mode. With TEE controller and APM controller, ESP32-C6 can precisely control the access permission of all masters to memory and peripheral registers.

## 16.2 Features

ESP32-C6’s TEE controller has the following features:

- Four security modes available for the masters
- Security mode configuration for up to 32 masters

ESP32-C6’s APM controller has the following features:

- Access permission configuration for up to 16 address ranges
- Access management to internal and external memory and peripheral registers
- Interrupt function
- Exception information record

## 16.3 Functional Description

## 16.3.1 TEE Controller Functional Description

ESP32-C6 provides four kinds of security mode: TEE, REEO, REE1, and REE2.

For the HP CPU to access memory or peripheral registers, first select the machine mode or user mode of the HP CPU, then configure its security mode. For the configuration of machine mode and user mode, please refer to RISC-V Instruction Set Manual, Volume II: Privileged Architecture, Version 1.10.

- When the HP CPU is in machine mode, its security mode is TEE mode.
- When the HP CPU is in user mode, its security mode is REE mode. To specify REE0, REE1 or REE2 mode, TEE\_M0\_MODE of TEE\_M0\_MODE\_CTRL\_REG should be configured:
- – If set TEE\_M0\_MODE to 0, which is in TEE modefiits security mode is REE0fi
- – if set TEE\_M0\_MODE to 1,2 or 3, which is in REE mode, it security mode is REE0, REE1 and REE2 respectively.

For the LP CPU's access to memories or peripheral registers, security mode can be set by configuring the LP\_TEE\_M0\_MODE of LP\_TEE\_M0\_MODE\_CTRL\_REG register.

As for other masters, security mode can be set by configuring the TEE\_Mn\_MODE of TEE registers. n here equals to the ID number of master in table 18.4-5 .

## 16.3.2 APM Controller Functional Description

## 16.3.2.1 Architecture

There are 3 register modules for APM registers:

- High Performance APM Registers (HP\_APM\_REG)
- Low Power APM0 Registers (LP\_APM0\_REG)
- Low Power APM Registers (LP\_APM\_REG)

Figure 16.3-1 shows the access path managed by the APM controller.

Figure 16.3-1. APM Controller Structure

![Image](images/16_Chapter_16_img002_1fb91c93.png)

## Note:

For the difference between Low speed mode and High speed mode in the figure, please refer to System and Memory .

As shown in the Figure 16.3-1, APM controller contains 3 functional modules: HP\_APM\_CTRLfiLP\_APM0\_CTRL and LP\_APM\_CTRL, configured by the register modules HP\_APM\_REG , LP\_APM0\_REG and LP\_APM\_REG respectively.

- HP\_APM\_CTRL manages 4 access paths, namely M0-M3 in the figure 16.3-1. Permission management of each path can be enabled by configuring HP\_APM\_FUNC\_CTRL\_REG (enabled by default).
- LP\_APM0\_CTRL manages one access path, namely M0 in the figure 16.3-1. Permission management of this path can be enabled by configuring LP\_APM0 \_FUNC\_CTRL\_REG (enabled by default).
- LP\_APM\_CTRL manages 2 access paths, namely M0 and M1 in the figure 16.3-1. Permission management of each path can be enabled by configuring LP\_APM \_FUNC\_CTRL\_REG (enabled by default).

The table 16.3-1 below shows the detailed information of each functional module:

Table 16.3-1. Configuring Access Path

| Register Mod ules   | Functional Modules   |   Access Path No. | Enable Permission Management   |   Configurable Address Ranges No. | Enable Address Ranges        |
|----------------------|----------------------|-------------------|--------------------------------|-----------------------------------|------------------------------|
| HP_APM_REG           | HP_APM_CTRL          |                 4 | HP_APM_ FUNC_CTRL_REG          |                                16 | HP_APM_REGION_FILTER_ EN_REG |

| LP_APM0_REG   | LP_APM0_CTRL   |   1 | LP_APM0 _FUNC_CTRL_REG   |   4 | LP_APM0_REGION_FILTER_ EN_REG   |
|---------------|----------------|-----|--------------------------|-----|---------------------------------|
| LP_APM_REG    | LP_APM_CTRL    |   2 | LP_APM _FUNC_CTRL_REG    |   4 | LP_APM_REGION_FILTER_ EN_REG    |

## 16.3.2.2 Address Ranges

- HP\_APM\_REG register module can configure up to 16 groups of address ranges for functional mudule HP\_APM\_CTRL. The start and end address for each region (address range) can be configured by setting HP\_APM\_REGIONn\_ADDR\_START and HP\_APM\_REGIONn\_ADDR\_END respectively. Configure the bit n of HP\_APM\_REGION\_FILTER\_EN\_REG to enable region n. The first group of address ranges is enabled by default.
- LP\_APM0\_REG register module can configure up to 4 groups of address ranges for functional mudule LP\_APM0\_CTRL. The start and end address for each region can be configured by setting LP\_APM0\_REGIONn\_ADDR\_START and LP\_APM0\_REGIONn\_ADDR\_END. Configure the bit n of LP\_APM0\_REGION\_FILTER\_EN\_REG to enable region n. The first group of address ranges is enabled by default.
- LP\_APM\_REG register module can configure up to 4 groups of address ranges for functional mudule LP\_APM\_CTRL. The start and end address for region n can be configured by setting LP\_APM\_REGIONn\_ADDR\_START and LP\_APM\_REGIONn\_ADDR\_END. Configure the bit n of LP\_APM\_REGION\_FILTER\_EN\_REG to enable region n. The first group of address ranges is enabled by default.

When configuring the address ranges, the address requires 4-byte alignment (the lower two bits of the address are 0). For example, the address range could be set as 0x4080000C ~ 0x40808774 or 0x600C0008 ~ 0x600CFF70.

## 16.3.2.3 Access Permissions of Address Ranges

Within each address range, access permissions (read/write/execute) can be configured for different security modes:

- The master in TEE mode always has read, write, and execute permissions in the address range.
- For master in REE0, REE1 or REE2 mode, access permissions can be configured in HP\_APM\_REGIONn\_ATTR\_REG , LP\_APM\_REGIONn\_ATTR\_REG or LP\_APM0\_REGIONn\_ATTR\_REG based on the access path.

Different access paths managed by the same register module share the configuration of address ranges and access permissions. For example, the permission management of data path HP\_APM M0-M3 shown in figure 16.3-1 should follow the address ranges and access permissions of each address range configured in the register module HP\_APM\_REG. Likewise, the permission management of data path LP\_APM M0-M1 shown in figure 16.3-1 should follow the address ranges and access permissions of each address range configured in the register module LP\_APM\_REG .

For the access path HP\_APM M1, all masters except HP CPU and LP CPU access HP\_MEM through this data access path. Suppose that HP\_APM\_M1\_FUNC\_EN is enabled and a master in REE1 mode needs to access HP\_MEM through HP\_APM M1. The whole process is as follows:

1. HP\_APM M1 will first determine whether the address requested to access is within the 16 address ranges configured in the HP\_APM\_REG register module. If 16 groups of address ranges are partially enabled, HP\_APM M1 will only determine whether the address requested to access is within the enabled address ranges.
2. Assuming that the address requested to access is within second group of configured address ranges, then determine whether the address range of this group is enabled, that is, whether bit 1 of HP\_APM\_REGION\_FILTER\_EN is 1.
3. If the address range is enabled, judge whether the master has read permission for the second group of address ranges in REE1 mode, that is, whether HP\_APM\_REGION1\_R1\_R in HP\_APM\_REGION1\_ATTR\_REG is valid (that is, 1). If valid, the read request will be allowed. Otherwise it will return 0.

When the HP power domain (see chapter Low-Power Management) powered down and restarted, the LP CPU does not have access to HP\_MEM by default. The master must be in the TEE mode to configure LP\_TEE\_FORCE\_ACC\_HPMEM\_EN in the LP power domain. When LP\_TEE\_FORCE\_ACC\_HPMEM\_EN is enabled, the LP CPU can access the HP\_MEM without the permission management of APM controller.

The address ranges configured above may overlap. For example, region 1 and region 2 overlap. If region 1 is set to be unreadable and region 2 is set to be readable, in this case the overlapping area of region 1 and region 2 is readable. The same rules apply for write and execute permissions.

## Note:

- When powered up, only the HP CPU is in TEE mode by default, and the other masters are in REE2 mode. By default, APM controller blocks access requests from all master in REE0, REE1, and REE2 modes.
- All registers listed in 16.6 Register Summary can only be configured by the master in TEE security mode.

## 16.4 Programming Procedure

- Configure the HP CPU to machine mode (ie. TEE mode).
- Choose the security mode of the master by configuring TEE\_Mn\_MODE or LP\_TEE\_Mn\_MODE . n here equals to the master ID in Table 18.4-5 .
- Configure the start and end address for access address ranges by setting HP\_APM\_REGIONn\_ADDR\_START , HP\_APM\_REGIONn\_ADDR\_END, or LP\_APM0\_REGIONn\_ADDR\_START , LP\_APM0\_REGIONn\_ADDR\_END, or LP\_APM\_REGIONn\_ADDR\_START , LP\_APM\_REGIONn\_ADDR\_END .
- Configure the access permissions of each region in different security mode by configuring HP\_APM\_REGIONn\_ATTR\_REG or LP\_APM\_REGIONn\_ATTR\_REG or LP\_APM0\_REGIONn\_ATTR\_REG .
- Set the bit n of HP\_APM\_REGION\_FILTER\_EN\_REG or LP\_APM\_REGION\_FILTER\_ EN\_REG or LP\_APM0\_REGION\_FILTER\_ EN\_REG to enable region n .
- Configure HP\_APM\_ FUNC\_CTRL\_REGfiLP\_APM \_FUNC\_CTRL\_REG or LP\_APM0 \_FUNC\_CTRL\_REG enable permission management of different access paths (enabled by default).

Take I2S accessing HP\_MEM via GDMA as an example, assuming that it is only allowed to read and write in the fourth group address range 0x40805000 ~ 0x4080F000 address range:

- Configure the HP CPU to machine mode (ie. TEE mode).
- According to the ID number in the table 18.4-5, set the TEE\_M19\_MODE to be 1, so as to set the security mode for I2S access via GDMA to REE0 mode.
- Configure the start address to 0x40805000 and end address to 0x4080F000 for the access address range by configuring HP\_APM\_REGION3\_ADDR\_START and HP\_APM\_REGION3\_ADDR\_END respectively.
- Set HP\_APM\_REGION3\_R0\_W and HP\_APM\_REGION3\_R0\_R to 1.
- Set the bit 3 of HP\_APM\_REGION\_FILTER\_EN to 1.
- Set HP\_APM\_M1\_FUNC\_EN to 1.

Through the above configuration, I2S can read and write in the address range of 0x40805000 ~ 0x4080F000 in HP\_MEM via GDMA.

## 16.5 Illegal access and interrupts

If the information carried on the bus is inconsistent with the configuration, ESP32-C6 will regard it as an illegal access and proceed as follows:

- Deny the access request and return the default value:
- – Returns 0 on instruction execution and read
- – Invalidate the write operation
- Trigger interrupt

The APM controller module will automatically record relevant information about illegal access, including master ID, security mode, access address, reason for illegal access (address out of bounds or permission restrictions ), and permission management result of each access path. All these information can be obtained from relevant registers listed in the section 16.6 Register Summary .

Take the access path HP\_APM M0 as an example. When illegal access occurs:

- HP\_APM\_M0\_EXCEPTION\_ID records the master ID.
- HP\_APM\_M0\_EXCEPTION\_MODE records the security mode.
- HP\_APM\_M0\_EXCEPTION\_ADDR records the access address.
- HP\_APM\_M0\_EXCEPTION\_STATUS records the reason for illegal access.
- – If the address requested to access is not among the enabled region of the 16 address ranges configured by HP\_APM\_REGIONn\_ADDR\_START , HP\_APM\_REGIONn\_ADDR\_END and HP\_APM\_REGION\_FILTER\_EN, bit1 of HP\_APM\_M0\_EXCEPTION\_STATUS will be set to 1, indicating address out of bounds.
- – If the address requested to access is among the enabled region/regions of the 16 address rangesfibut the master doesn't have the read/write/execute permission within this region/regions, then the bit0 will be set to 1, indicating permission restrictions.
- HP\_APM\_M0\_EXCEPTION\_REGION records the permission management result of each address range. This register has a total of 16 bits, corresponding to 16 groups of address ranges, and bit0 corresponds to the first group of address ranges. When the address to access is within a particular enabled address

![Image](images/16_Chapter_16_img003_e03d0133.png)

range, but the master doesn't have the corresponding read/write/execute permission within this address range, the corresponding bit of this register will be set to 1 .

ESP32-C6's APM controller can generate seven interrupt signals, which will be sent to Interrupt Matrix (INTMTX):

- HP\_APM\_M0\_INTR
- HP\_APM\_M1\_INTR
- HP\_APM\_M2\_INTR
- HP\_APM\_M3\_INTR
- LP\_APM\_M0\_INTR
- LP\_APM\_M1\_INTR
- LP\_APM0\_M0\_INTR

These seven interrupt signals correspond to the controlled access paths shown in Figure 16.3-1. If an illegal access occurs in a controlled access path, the corresponding interrupt will be generated.

## 16.6 Register Summary

## 16.6.1 High Performance APM Registers (HP\_APM\_REG)

The addresses in this section are relative to the Access Permission Management Controller (HP\_APM) base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                       | Description                                  | Address                                    | Access                                     |
|--------------------------------------------|----------------------------------------------|--------------------------------------------|--------------------------------------------|
| Region filter enable register              | Region filter enable register                | Region filter enable register              | Region filter enable register              |
| HP_APM_REGION_FILTER_EN_REG                | Region filter enable register                | 0x0000                                     | R/W                                        |
| Region address register                    | Region address register                      | Region address register                    | Region address register                    |
| HP_APM_REGIONn_ADDR_START_REG (n: 0-15)    | Region address register                      | 0x0004+0xC*n                               | R/W                                        |
| HP_APM_REGIONn_ADDR_END_REG (n: 0-15)      | Region address register                      | 0x0008+0xC*n                               | R/W                                        |
| Region access authority attribute register | Region access authority attribute register   | Region access authority attribute register | Region access authority attribute register |
| HP_APM_REGIONn_ATTR_REG (n: 0- 15)         | Region access authority attribute regis ter | 0x000C+0xC*n R/W                           |                                            |
| function control register                  | function control register                    | function control register                  | function control register                  |
| HP_APM_FUNC_CTRL_REG                       | APM function control register                | 0x00C4                                     | R/W                                        |
| M0 status register                         | M0 status register                           | M0 status register                         | M0 status register                         |
| HP_APM_M0_STATUS_REG                       | M0 status register                           | 0x00C8                                     | RO                                         |
| M0 status clear register                   | M0 status clear register                     | M0 status clear register                   | M0 status clear register                   |
| HP_APM_M0_STATUS_CLR_REG                   | M0 status clear register                     | 0x00CC                                     | WT                                         |
| M0 exception_info0 register                | M0 exception_info0 register                  | M0 exception_info0 register                | M0 exception_info0 register                |
| HP_APM_M0_EXCEPTION_INFO0_REG              | M0 exception_info0 register                  | 0x00D0                                     | RO                                         |

| Name                          | Description                   | Address   | Access   |
|-------------------------------|-------------------------------|-----------|----------|
| M0 exception_info1 register   |                               |           |          |
| HP_APM_M0_EXCEPTION_INFO1_REG | M0 exception_info1 register   | 0x00D4    | RO       |
| M1 status register            |                               |           |          |
| HP_APM_M1_STATUS_REG          | M1 status register            | 0x00D8    | RO       |
| M1 status clear register      |                               |           |          |
| HP_APM_M1_STATUS_CLR_REG      | M1 status clear register      | 0x00DC    | WT       |
| M1 exception_info0 register   |                               |           |          |
| HP_APM_M1_EXCEPTION_INFO0_REG | M1 exception_info0 register   | 0x00E0    | RO       |
| M1 exception_info1 register   |                               |           |          |
| HP_APM_M1_EXCEPTION_INFO1_REG | M1 exception_info1 register   | 0x00E4    | RO       |
| M2 status register            |                               |           |          |
| HP_APM_M2_STATUS_REG          | M2 status register            | 0x00E8    | RO       |
| M2 status clear register      |                               |           |          |
| HP_APM_M2_STATUS_CLR_REG      | M2 status clear register      | 0x00EC    | WT       |
| M2 exception_info0 register   |                               |           |          |
| HP_APM_M2_EXCEPTION_INFO0_REG | M2 exception_info0 register   | 0x00F0    | RO       |
| M2 exception_info1 register   |                               |           |          |
| HP_APM_M2_EXCEPTION_INFO1_REG | M2 exception_info1 register   | 0x00F4    | RO       |
| M3 status register            |                               |           |          |
| HP_APM_M3_STATUS_REG          | M3 status register            | 0x00F8    | RO       |
| M3 status clear register      |                               |           |          |
| HP_APM_M3_STATUS_CLR_REG      | M3 status clear register      | 0x00FC    | WT       |
| M3 exception_info0 register   |                               |           |          |
| HP_APM_M3_EXCEPTION_INFO0_REG | M3 exception_info0 register   | 0x0100    | RO       |
| M3 exception_info1 register   |                               |           |          |
| HP_APM_M3_EXCEPTION_INFO1_REG | M3 exception_info1 register   | 0x0104    | RO       |
| APM interrupt enable register |                               |           |          |
| HP_APM_INT_EN_REG             | APM interrupt enable register | 0x0108    | R/W      |
| Clock gating register         |                               |           |          |
| HP_APM_CLOCK_GATE_REG         | Clock gating register         | 0x010C    | R/W      |
| Version control register      |                               |           |          |
| HP_APM_DATE_REG               | Version control register      | 0x07FC    | R/W      |

## 16.6.2 Low Power APM Registers (LP\_APM\_REG)

The addresses in this section are relative to the Low-Power Access Permission Management (LP\_APM) base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                          | Description                   | Address                 | Access                  |
|-------------------------------|-------------------------------|-------------------------|-------------------------|
| Region filter enable register |                               |                         |                         |
| LP_APM_REGION_FILTER_EN_REG   | Region filter enable register | 0x0000                  | R/W                     |
| Region address register       | Region address register       | Region address register | Region address register |

| Name                                       | Description                                  | Address                                    | Access                                     |
|--------------------------------------------|----------------------------------------------|--------------------------------------------|--------------------------------------------|
| LP_APM_REGIONn_ADDR_START_REG (n: 0-3)     | Region address register                      | 0x0004+0xC*n                               | R/W                                        |
| LP_APM_REGIONn_ADDR_END_REG (n: 0-3)       | Region address register                      | 0x0008+0xC*n                               | R/W                                        |
| Region access authority attribute register | Region access authority attribute register   | Region access authority attribute register | Region access authority attribute register |
| LP_APM_REGIONn_ATTR_REG (n: 0- 3)          | Region access authority attribute regis ter | 0x000C+0xC*n R/W                           |                                            |
| function control register                  | function control register                    | function control register                  | function control register                  |
| LP_APM_FUNC_CTRL_REG                       | APM function control register                | 0x00C4                                     | R/W                                        |
| M0 status register                         | M0 status register                           | M0 status register                         | M0 status register                         |
| LP_APM_M0_STATUS_REG                       | M0 status register                           | 0x00C8                                     | RO                                         |
| M0 status clear register                   | M0 status clear register                     | M0 status clear register                   | M0 status clear register                   |
| LP_APM_M0_STATUS_CLR_REG                   | M0 status clear register                     | 0x00CC                                     | WT                                         |
| M0 exception_info0 register                | M0 exception_info0 register                  | M0 exception_info0 register                | M0 exception_info0 register                |
| LP_APM_M0_EXCEPTION_INFO0_REG              | M0 exception_info0 register                  | 0x00D0                                     | RO                                         |
| M0 exception_info1 register                | M0 exception_info1 register                  | M0 exception_info1 register                | M0 exception_info1 register                |
| LP_APM_M0_EXCEPTION_INFO1_REG              | M0 exception_info1 register                  | 0x00D4                                     | RO                                         |
| M1 status register                         | M1 status register                           | M1 status register                         | M1 status register                         |
| LP_APM_M1_STATUS_REG                       | M1 status register                           | 0x00D8                                     | RO                                         |
| M1 status clear register                   | M1 status clear register                     | M1 status clear register                   | M1 status clear register                   |
| LP_APM_M1_STATUS_CLR_REG                   | M1 status clear register                     | 0x00DC                                     | WT                                         |
| M1 exception_info0 register                | M1 exception_info0 register                  | M1 exception_info0 register                | M1 exception_info0 register                |
| LP_APM_M1_EXCEPTION_INFO0_REG              | M1 exception_info0 register                  | 0x00E0                                     | RO                                         |
| M1 exception_info1 register                | M1 exception_info1 register                  | M1 exception_info1 register                | M1 exception_info1 register                |
| LP_APM_M1_EXCEPTION_INFO1_REG              | M1 exception_info1 register                  | 0x00E4                                     | RO                                         |
| APM interrupt enable register              | APM interrupt enable register                | APM interrupt enable register              | APM interrupt enable register              |
| LP_APM_INT_EN_REG                          | APM interrupt enable register                | 0x00E8                                     | R/W                                        |
| clock gating register                      | clock gating register                        | clock gating register                      | clock gating register                      |
| LP_APM_CLOCK_GATE_REG                      | clock gating register                        | 0x00EC                                     | R/W                                        |
| Version control register                   | Version control register                     | Version control register                   | Version control register                   |
| LP_APM_DATE_REG                            | Version control register                     | 0x00FC                                     | R/W                                        |

## 16.6.3 Low Power APM0 Registers (LP\_APM0\_REG)

The addresses in this section are relative to the Access Permission Management Controller (HP\_APM) base address + 0x1000 provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                          | Description                   | Address   | Access   |
|-------------------------------|-------------------------------|-----------|----------|
| Region filter enable register |                               |           |          |
| LP_APM0_REGION_FILTER_EN_REG  | Region filter enable register | 0x0000    | R/W      |
| Region address register       |                               |           |          |

| Name                                       | Description                                  | Address                                    | Access                                     |
|--------------------------------------------|----------------------------------------------|--------------------------------------------|--------------------------------------------|
| LP_APM0_REGIONn_ADDR_START_REG (n: 0-3)    | Region address register                      | 0x0004+0xC*n                               | R/W                                        |
| LP_APM0_REGIONn_ADDR_END_REG (n: 0-3)      | Region address register                      | 0x0008+0xC*n                               | R/W                                        |
| Region access authority attribute register | Region access authority attribute register   | Region access authority attribute register | Region access authority attribute register |
| LP_APM0_REGIONn_ATTR_REG (n: 0- 3)         | Region access authority attribute regis ter | 0x000C+0xC*n R/W                           |                                            |
| APM function control register              | APM function control register                | APM function control register              | APM function control register              |
| LP_APM0_FUNC_CTRL_REG                      | APM function control register                | 0x00C4                                     | R/W                                        |
| M0 status register                         | M0 status register                           | M0 status register                         | M0 status register                         |
| LP_APM0_M0_STATUS_REG                      | M0 status register                           | 0x00C8                                     | RO                                         |
| M0 status clear register                   | M0 status clear register                     | M0 status clear register                   | M0 status clear register                   |
| LP_APM0_M0_STATUS_CLR_REG                  | M0 status clear register                     | 0x00CC                                     | WT                                         |
| M0 exception_info0 register                | M0 exception_info0 register                  | M0 exception_info0 register                | M0 exception_info0 register                |
| LP_APM0_M0_EXCEPTION_INFO0_REG             | M0 exception_info0 register                  | 0x00D0                                     | RO                                         |
| M0 exception_info1 register                | M0 exception_info1 register                  | M0 exception_info1 register                | M0 exception_info1 register                |
| LP_APM0_M0_EXCEPTION_INFO1_REG             | M0 exception_info1 register                  | 0x00D4                                     | RO                                         |
| APM interrupt enable register              | APM interrupt enable register                | APM interrupt enable register              | APM interrupt enable register              |
| LP_APM0_INT_EN_REG                         | APM interrupt enable register                | 0x00D8                                     | R/W                                        |
| Clock gating register                      | Clock gating register                        | Clock gating register                      | Clock gating register                      |
| LP_APM0_CLOCK_GATE_REG                     | Clock gating register                        | 0x00DC                                     | R/W                                        |
| Version control register                   | Version control register                     | Version control register                   | Version control register                   |
| LP_APM0_DATE_REG                           | Version control register                     | 0x07FC                                     | R/W                                        |

## 16.6.4 High Performance TEE Registers

The addresses in this section are relative to the Trusted Execution Environment (TEE) Register provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                           | Description               | Address      | Access   |
|--------------------------------|---------------------------|--------------|----------|
| Tee mode control register      |                           |              |          |
| TEE_Mn_MODE_CTRL_REG (n: 0-31) | TEE mode control register | 0x0000+0x4*n | R/W      |
| clock gating register          |                           |              |          |
| TEE_CLOCK_GATE_REG             | Clock gating register     | 0x0080       | R/W      |
| Version control register       |                           |              |          |
| TEE_DATE_REG                   | Version control register  | 0x0FFC       | R/W      |

## 16.6.5 Low Power TEE Registers

The addresses in this section are relative to the Low-power Trusted Execution Environment (LP\_TEE) provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                      | Description                                  | Address                   | Access                    |
|---------------------------|----------------------------------------------|---------------------------|---------------------------|
| Tee mode control register | Tee mode control register                    | Tee mode control register | Tee mode control register |
| LP_TEE_M0_MODE_CTRL_REG   | TEE mode control register                    | 0x0000                    | R/W                       |
| clock gating register     | clock gating register                        | clock gating register     | clock gating register     |
| LP_TEE_CLOCK_GATE_REG     | Clock gating register                        | 0x0004                    | R/W                       |
| configure_register        | configure_register                           | configure_register        | configure_register        |
| LP_TEE_FORCE_ACC_HP_REG   | Force access to hpmem configuration register | 0x0090                    | R/W                       |
| Version control register  | Version control register                     | Version control register  | Version control register  |
| LP_TEE_DATE_REG           | Version control register                     | 0x00FC                    | R/W                       |

## 16.7 Registers

## 16.7.1 High Performance APM Registers (HP\_APM\_REG)

Register 16.1. HP\_APM\_REGION\_FILTER\_EN\_REG (0x0000)

![Image](images/16_Chapter_16_img004_8436cf3e.png)

HP\_APM\_REGION\_FILTER\_EN Configure bit n (0-15) to enable region n .

0: disable

1: enable

(R/W)

![Image](images/16_Chapter_16_img005_bbdab9e2.png)

HP\_APM\_REGIONn\_ADDR\_START Configures start address of region n. (R/W)

![Image](images/16_Chapter_16_img006_a83dd2eb.png)

HP\_APM\_REGIONn\_ADDR\_END Configures end address of region n. (R/W)

Register 16.4. HP\_APM\_REGIONn\_ATTR\_REG (n: 0-15) (0x000C+0xC*n)

![Image](images/16_Chapter_16_img007_9ce1af46.png)

Register 16.5. HP\_APM\_FUNC\_CTRL\_REG (0x00C4)

![Image](images/16_Chapter_16_img008_6b3e0b75.png)

![Image](images/16_Chapter_16_img009_1d3e3154.png)

![Image](images/16_Chapter_16_img010_b222d549.png)

Register 16.12. HP\_APM\_M1\_EXCEPTION\_INFO0\_REG (0x00E0)

![Image](images/16_Chapter_16_img011_3bbbdb8e.png)

HP\_APM\_M1\_EXCEPTION\_REGION Represents exception region. (RO)

HP\_APM\_M1\_EXCEPTION\_MODE Represents exception mode. (RO)

HP\_APM\_M1\_EXCEPTION\_ID Represents exception id information. (RO)

## Register 16.13. HP\_APM\_M1\_EXCEPTION\_INFO1\_REG (0x00E4)

![Image](images/16_Chapter_16_img012_7de2f99a.png)

HP\_APM\_M1\_EXCEPTION\_ADDR Represents exception addr. (RO)

Register 16.14. HP\_APM\_M2\_STATUS\_REG (0x00E8)

bit0: 1 represents authority\_exception

bit1: 1 represents space\_exception

(RO)

![Image](images/16_Chapter_16_img013_62a74dda.png)

## Register 16.15. HP\_APM\_M2\_STATUS\_CLR\_REG (0x00EC)

![Image](images/16_Chapter_16_img014_bb09530c.png)

HP\_APM\_M2\_REGION\_STATUS\_CLR Configures to clear exception status. (WT)

## Register 16.16. HP\_APM\_M2\_EXCEPTION\_INFO0\_REG (0x00F0)

![Image](images/16_Chapter_16_img015_3d0839ae.png)

HP\_APM\_M2\_EXCEPTION\_REGION Represents exception region. (RO)

HP\_APM\_M2\_EXCEPTION\_MODE Represents exception mode. (RO)

HP\_APM\_M2\_EXCEPTION\_ID Represents exception id information. (RO)

## Register 16.17. HP\_APM\_M2\_EXCEPTION\_INFO1\_REG (0x00F4)

![Image](images/16_Chapter_16_img016_348869f5.png)

578

Submit Documentation Feedback

![Image](images/16_Chapter_16_img017_a179435d.png)

## Register 16.21. HP\_APM\_M3\_EXCEPTION\_INFO1\_REG (0x0104)

![Image](images/16_Chapter_16_img018_713c0b15.png)

HP\_APM\_M3\_EXCEPTION\_ADDR Represents exception addr. (RO)

## Register 16.22. HP\_APM\_INT\_EN\_REG (0x0108)

![Image](images/16_Chapter_16_img019_6a4ec320.png)

- HP\_APM\_M0\_APM\_INT\_EN Configures to enable APM M0 interrupt.
- 0: disable

1: enable

(R/W)

- HP\_APM\_M1\_APM\_INT\_EN Configures to enable APM M1 interrupt.
- 0: disable

1: enable

(R/W)

- HP\_APM\_M2\_APM\_INT\_EN Configures to enable APM M2 interrupt.

0: disable

1: enable

(R/W)

- HP\_APM\_M3\_APM\_INT\_EN Configures to enable APM M3 interrupt.

0: disable

1: enable

(R/W)

## Register 16.23. HP\_APM\_CLOCK\_GATE\_REG (0x010C)

![Image](images/16_Chapter_16_img020_a58cca90.png)

- HP\_APM\_CLK\_EN Configures whether to keep the clock always on.
- 0: enable automatic clock gating
- 1: keep the clock always on

(R/W)

## Register 16.24. HP\_APM\_DATE\_REG (0x07FC)

![Image](images/16_Chapter_16_img021_d23e4973.png)

HP\_APM\_DATE Version control register. (R/W)

## 16.7.2 Low Power APM Registers (LP\_APM\_REG)

Register 16.25. LP\_APM\_REGION\_FILTER\_EN\_REG (0x0000)

![Image](images/16_Chapter_16_img022_fe060f0d.png)

![Image](images/16_Chapter_16_img023_420a8a67.png)

LP\_APM\_REGIONn\_ADDR\_END Configures end address of region n. (R/W)

Register 16.28. LP\_APM\_REGIONn\_ATTR\_REG (n: 0-3) (0x000C+0xC*n)

![Image](images/16_Chapter_16_img024_35aa5935.png)

## Register 16.29. LP\_APM\_FUNC\_CTRL\_REG (0x00C4)

![Image](images/16_Chapter_16_img025_578df867.png)

LP\_APM\_M0\_FUNC\_EN Configures APM M0 function enable. (R/W)

LP\_APM\_M1\_FUNC\_EN Configures APM M1 function enable. (R/W)

![Image](images/16_Chapter_16_img026_3c2c3a2e.png)

![Image](images/16_Chapter_16_img027_c24ac0b6.png)

Register 16.36. LP\_APM\_M1\_EXCEPTION\_INFO0\_REG (0x00E0)

![Image](images/16_Chapter_16_img028_69f5ab4d.png)

LP\_APM\_M1\_EXCEPTION\_REGION Represents exception region. (RO)

LP\_APM\_M1\_EXCEPTION\_MODE Represents exception mode. (RO)

LP\_APM\_M1\_EXCEPTION\_ID Represents exception id information. (RO)

Register 16.37. LP\_APM\_M1\_EXCEPTION\_INFO1\_REG (0x00E4)

![Image](images/16_Chapter_16_img029_44469de1.png)

LP\_APM\_M1\_EXCEPTION\_ADDR Represents exception addr. (RO)

## Register 16.38. LP\_APM\_INT\_EN\_REG (0x00E8)

![Image](images/16_Chapter_16_img030_519b8b19.png)

- LP\_APM\_M0\_APM\_INT\_EN Configures to enable APM M0 interrupt.
- 0: disable
- 1: enable

(R/W)

- LP\_APM\_M1\_APM\_INT\_EN Configures to enable APM M1 interrupt.
- 0: disable
- 1: enable

(R/W)

## Register 16.39. LP\_APM\_CLOCK\_GATE\_REG (0x00EC)

![Image](images/16_Chapter_16_img031_8cfce0e5.png)

- LP\_APM\_CLK\_EN Configures whether to keep the clock always on.
- 0: enable automatic clock gating
- 1: keep the clock always on

(R/W)

## Register 16.40. LP\_APM\_DATE\_REG (0x00FC)

![Image](images/16_Chapter_16_img032_103ca4eb.png)

LP\_APM\_DATE Version control register. (R/W)

## 16.7.3 Low Power APM0 Registers (LP\_APM0\_REG)

![Image](images/16_Chapter_16_img033_e5a4308e.png)

Register 16.44. LP\_APM0\_REGIONn\_ATTR\_REG (n: 0-3) (0x000C+0xC*n)

![Image](images/16_Chapter_16_img034_175aa62b.png)

LP\_APM0\_REGIONn\_R0\_X Configures region execute authority in REE\_MODE0 (R/W)

LP\_APM0\_REGIONn\_R0\_W Configures region write authority in REE\_MODE0 (R/W)

LP\_APM0\_REGIONn\_R0\_R Configures region read authority in REE\_MODE0 (R/W)

LP\_APM0\_REGIONn\_R1\_X Configures region execute authority in REE\_MODE1 (R/W)

LP\_APM0\_REGIONn\_R1\_W Configures region write authority in REE\_MODE1 (R/W)

LP\_APM0\_REGIONn\_R1\_R Configures region read authority in REE\_MODE1 (R/W)

LP\_APM0\_REGIONn\_R2\_X Configures region execute authority in REE\_MODE2 (R/W)

LP\_APM0\_REGIONn\_R2\_W Configures region write authority in REE\_MODE2 (R/W)

LP\_APM0\_REGIONn\_R2\_R Configures region read authority in REE\_MODE2 (R/W)

Register 16.45. LP\_APM0\_FUNC\_CTRL\_REG (0x00C4)

![Image](images/16_Chapter_16_img035_25ad2351.png)

LP\_APM0\_M0\_FUNC\_EN Configures to enable APM M0 function. (R/W)

![Image](images/16_Chapter_16_img036_0041dea4.png)

LP\_APM0\_M0\_REGION\_STATUS\_CLR Configures to clear exception status (WT)

## Register 16.48. LP\_APM0\_M0\_EXCEPTION\_INFO0\_REG (0x00D0)

![Image](images/16_Chapter_16_img037_cb705405.png)

LP\_APM0\_M0\_EXCEPTION\_REGION Represents exception region (RO)

LP\_APM0\_M0\_EXCEPTION\_MODE Represents exception mode (RO)

LP\_APM0\_M0\_EXCEPTION\_ID Represents exception id information (RO)

## Register 16.49. LP\_APM0\_M0\_EXCEPTION\_INFO1\_REG (0x00D4)

![Image](images/16_Chapter_16_img038_7efea74f.png)

LP\_APM0\_M0\_EXCEPTION\_ADDR Represents exception addr (RO)

Register 16.50. LP\_APM0\_INT\_EN\_REG (0x00D8)

![Image](images/16_Chapter_16_img039_a87cc9d5.png)

LP\_APM0\_M0\_APM\_INT\_EN Configures APM M0 interrupt enable.

0: disable

1: enable

(R/W)

Register 16.51. LP\_APM0\_CLOCK\_GATE\_REG (0x00DC)

![Image](images/16_Chapter_16_img040_43cb4ecf.png)

- LP\_APM0\_CLK\_EN Configures whether to keep the clock always on.
- 0: enable automatic clock gating
- 1: keep the clock always on

```
(R/W)
```

## Register 16.52. LP\_APM0\_DATE\_REG (0x07FC)

![Image](images/16_Chapter_16_img041_78668ce6.png)

LP\_APM0\_DATE Version control register (R/W)

## 16.7.4 High Performance TEE Registers

Register 16.53. TEE\_Mn\_MODE\_CTRL\_REG (n: 0-31) (0x0000+0x4*n)

![Image](images/16_Chapter_16_img042_920e9163.png)

![Image](images/16_Chapter_16_img043_3c6bd42f.png)

## Register 16.54. TEE\_CLOCK\_GATE\_REG (0x0080)

![Image](images/16_Chapter_16_img044_8d9b5ea4.png)

TEE\_CLK\_EN Configures whether to keep the clock always on.

- 0: enable automatic clock gating
- 1: keep the clock always on

(R/W)

## Register 16.55. TEE\_DATE\_REG (0x0FFC)

![Image](images/16_Chapter_16_img045_91771cb2.png)

TEE\_DATE\_REG Version control register (R/W)

## 16.7.5 Low Power TEE Registers

## Register 16.56. LP\_TEE\_M0\_MODE\_CTRL\_REG (0x0000)

![Image](images/16_Chapter_16_img046_c5bd121c.png)

LP\_TEE\_M0\_MODE Configures M0 security level mode.

- 0: tee\_mode
- 1: ree\_mode0
- 2: ree\_mode1
- 3: ree\_mode2

(R/W)

## Register 16.57. LP\_TEE\_CLOCK\_GATE\_REG (0x0004)

![Image](images/16_Chapter_16_img047_ce3648d5.png)

- LP\_TEE\_CLK\_EN Configures whether to keep the clock always on.
- 0: enable automatic clock gating
- 1: keep the clock always on

(R/W)

## Register 16.58. LP\_TEE\_FORCE\_ACC\_HP\_REG (0x0090)

![Image](images/16_Chapter_16_img048_69245fd2.png)

- LP\_TEE\_FORCE\_ACC\_HPMEM\_EN Configures whether to allow LP CPU to force access to HP\_MEM regardless of permission management.
- 0: disable force access HP\_MEM
- 1: enable force access HP\_MEM

(R/W)

## Register 16.59. LP\_TEE\_DATE\_REG (0x00FC)

![Image](images/16_Chapter_16_img049_158b945f.png)

LP\_TEE\_DATE Version control register (R/W)
