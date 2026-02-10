---
chapter: 17
title: "Chapter 17"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 17

## System Registers

## 17.1 Overview

ESP32-C6 supports a set of auxiliary chip features listed in subsection 17.2 Features below, which are configured via registers. This chapter provides a description of the registers used to configure these features.

## 17.2 Features

ESP32-C6 system registers can be used to control the following peripheral blocks and core modules:

- External Memory Encryption/Decryption
- Anti-DPA attack security
- HP Core/LP Core debug
- Bus timeout protection

## 17.3 Function Description

## 17.3.1 External Memory Encryption/Decryption Configuration

HP\_SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG configures encryption and decryption options of the external memory. For details, please refer to Chapter 25 External Memory Encryption and Decryption (XTS\_AES) .

## 17.3.2 Anti-DPA Attack Security Control

ESP32-C6 has a dual protection mechanism against Differential Power Analysis (DPA) attacks at the hardware level.

- First, a mask mechanism is introduced in the symmetric encryption operation process, which interferes with the power consumption trajectory by masking the real data in the operation process. This security mechanism cannot be turned off.
- Second, the clock selected for the operation will change dynamically in real time, blurring the power consumption trajectory during the operation. For this security mechanism, ESP32-C6 provides 4 security levels for users to choose to adapt to different applications.

Table 17.3-1. Security Level

| Security-Level Name   |   Security-Level Value | PLL_CLK (MHz)   | XTAL_CLK (MHz)   |
|-----------------------|------------------------|-----------------|------------------|
| SEC_DPA_OFF           |                      0 | 160             | 40               |
| SEC_DPA_LOW           |                      1 | (120,160] A     | (20,40] A        |
| SEC_DPA_MIDDLE        |                      2 | (96,160] A      | (33.3,40] A      |
| SEC_DPA_HIGH          |                      3 | (80,160] A      | (10,40] A        |

By default, the field HP\_SYSTEM\_SEC\_DPA\_CFG\_SEL in register HP\_SYSTEM\_SEC\_DPA\_CONF\_REG is 0. In this case, the security-level is decided by the eFuse field EFUSE\_SEC\_DPA\_LEVEL. If the field HP\_SYSTEM\_SEC\_DPA\_CFG\_SEL is set to 1, the security-level is decided by HP\_SYSTEM\_SEC\_DPA\_CFG\_LEVEL in register HP\_SYSTEM\_SEC\_DPA\_CONF\_REG .

## 17.3.3 HP Core/LP Core Debug Control

The following register is used to debug between HP CPU and LP CPU. For more information on how to debug HP CPU and LP CPU, please refer to the Subsection 1.10 Debug in Chapter 1 High-Performance CPU .

- HP\_SYSTEM\_CORE\_DEBUG\_RUNSTALL\_ENABLE: Enable this bit to enable debug RunStall feature between HP CPU and LP CPU.

## 17.3.4 Bus Timeout Protection

The Bus Timeout Protection function can be enabled and the timeout threshold can be configured through the configuration register. When a transfer is initiated, the counter inside the Timeout Protection module will increase by one every clock cycle. When the accumulated value is less than the timeout threshold and the bus receives a response from the slave, the internal counter is cleared. When the accumulated value is greater than the timeout threshold, if the slave device has not responded to the transfer, the Timeout Protection module will force the bus return signal to be pulled high. At the same time, it will report the interrupt and record the abnormal access address and master ID.

## 17.3.4.1 CPU Peripheral Timeout Protection Register

HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_CONF\_REG is the timeout protection configuration register for accessing CPU peripheral registers. CPU peripherals refer to the peripherals or modules whose addresses are in the range of 0x600C\_0000 ~ 0x600C\_FFFF. For corresponding peripheral information, please refer to Subsection 5.3.5 Modules/Peripherals Address Mapping in Chapter 5 System and Memory .

When a timeout occurs, the CPU\_PERI\_TIMEOUT\_INTR interrupt will be asserted.

- HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_CONF\_REG: Enables timeout protection and configures the timeout threshold.
- HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_ADDR\_REG: When a timeout occurs, this register will record the address of the timeout.
- HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_UID\_REG: When a timeout occurs, this register will record the address of the timeout.

## 17.3.4.2 HP Peripheral Timeout Protection Register

HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_CONF\_REG is the timeout protection configuration register for accessing HP peripheral registers.

HP peripherals refer to the peripherals or modules whose addresses are in the range of 0x6000\_0000 ~ 0x6009\_FFFF. For corresponding peripheral information, please refer to Subsection 5.3.5 Modules/Peripherals Address Mapping in Chapter 5 System and Memory .

When a timeout occurs, the HP\_PERI\_TIMEOUT\_INTR interrupt will be asserted.

- HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_CONF\_REG: Enables timeout protection and configures the timeout threshold.
- HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_ADDR\_REG: When a timeout occurs, this register will record the address of the timeout.
- HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_UID\_REG: When a timeout occurs, this register will record the Master-ID of the timeout.

## 17.3.4.3 LP Peripheral Timeout Protection Register

LP\_PERI\_BUS\_TIMEOUT\_CONF\_REG is the timeout protection configuration register for accessing LP peripheral registers. LP peripherals refer to the peripherals or modules whose addresses are in the range of 0x600B\_0000 ~ 0x600B\_FFFF. For corresponding peripheral information, please refer to Subsection 5.3.5 Modules/Peripherals Address Mapping in Chapter 5 System and Memory .

When a timeout occurs, the LP\_PERI\_TIMEOUT\_INTR interrupt will be asserted.

- LP\_PERI\_BUS\_TIMEOUT\_CONF\_REG: Enables timeout protection and configures the timeout threshold.
- LP\_PERI\_BUS\_TIMEOUT\_ADDR\_REG: When a timeout occurs, this register will record the address of the timeout.
- LP\_PERI\_BUS\_TIMEOUT\_UID\_REG: When a timeout occurs, this register will record the Master-ID of the timeout.

Chapter 17 System Registers

Access

R/W

Address

Description

.

System and Memory

5

## in Chapter

5.3-2

.

Access Types for Registers

The abbreviations given in Column

Register Summary

17.4

The addresses in this section are relative to System Registers base address provided in Table

Espressif Systems

0x0000

External device encryption/decryption config- uration register

R/W

0x0008

HP anti-DPA security configuration register

WTC

0x0014

Master ID and permission register varies

0x0018

HP Peripheral Timeout configuration register

WTC

0x0020

Master ID and permission register varies

0x0010

LP Peripheral timeout configuration register

RO

0x0014

LP Peripheral abnormal access address register

WTC

0x0018

LP Peripheral Master ID and permission register

R/W

0x03FC

Date control and version control register

|                                                                                                                                                                                                                                                                                 | HP_SYSTEM_EXTERNAL_DEVICE_ENCRYPT_DECRYPT_CONTROL_REG   |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|
| are explained in Section  HP_SYSTEM_CORE_DEBUG_RUNSTALL_CONF_REG  CPU Peripheral Timeout RegisterHP_SYSTEM_CPU_PERI_TIMEOUT_CONF_REG  HP_SYSTEM_CPU_PERI_TIMEOUT_ADDR_REG  HP_SYSTEM_CPU_PERI_TIMEOUT_UID_REG  HP Peripheral Timeout RegisterHP_SYSTEM_HP_PERI_TIMEOUT_CONF_REG |                                                         |
| Access                                                                                                                                                                                                                                                                          |                                                         |

Name

LP\_PERI\_BUS\_TIMEOUT\_UID\_REG

Version RegisterHP\_SYSTEM\_DATE\_REG

ESP32-C6 TRM (Version 1.1)

HP\_SYSTEM\_SEC\_DPA\_CONF\_REG

Configuration Register

R/W

0x0040

Core Debug RunStall configurion register varies

0x000C

CPU Peripheral Timeout configuration register

RO

0x0010

Abnormal access address register

RO

0x001C

Abnormal access address register

598

Submit Documentation Feedback

GoBack

## 17.5 Registers

The addresses in this section are relative to System Registers base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 17.1. HP\_SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG (0x0000)

![Image](images/17_Chapter_17_img001_6fe40f02.png)

- HP\_SYSTEM\_ENABLE\_SPI\_MANUAL\_ENCRYPT Configures whether or not to enable MSPI XTS manual encryption in SPI boot mode.
- 0: Disable
- 1: Enable
- (R/W)
- HP\_SYSTEM\_ENABLE\_DOWNLOAD\_G0CB\_DECRYPT Configures whether or not to enable MSPI

XTS auto decryption in download boot mode.

- 0: Disable
- 1: Enable
- (R/W)
- HP\_SYSTEM\_ENABLE\_DOWNLOAD\_MANUAL\_ENCRYPT Configures whether or not to enable MSPI

XTS manual encryption in download boot mode.

- 0: Disable
- 1: Enable
- (R/W)

## Register 17.2. HP\_SYSTEM\_SEC\_DPA\_CONF\_REG (0x0008)

![Image](images/17_Chapter_17_img002_9bd3066f.png)

- HP\_SYSTEM\_SEC\_DPA\_LEVEL Configures whether or not to enable anti-DPA attack. Valid only when HP\_SYSTEM\_SEC\_DPA\_CFG\_SEL is 0.
- 0: Disable
- 1-3: Enable. The larger the number, the higher the security level, which represents the ability to resist DPA attacks, with increased computational overhead of the hardware crypto-accelerators at the same time.

(R/W)

- HP\_SYSTEM\_SEC\_DPA\_CFG\_SEL Configures whether to select HP\_SYSTEM\_SEC\_DPA\_LEVEL or EFUSE\_SEC\_DPA\_LEVEL (from eFuse) to control DPA level.
- 0: Select EFUSE\_SEC\_DPA\_LEVEL
- 1: Select HP\_SYSTEM\_SEC\_DPA\_LEVEL

(R/W)

Register 17.3. HP\_SYSTEM\_CORE\_DEBUG\_RUNSTALL\_CONF\_REG (0x0040)

![Image](images/17_Chapter_17_img003_0d70928d.png)

- HP\_SYSTEM\_CORE\_DEBUG\_RUNSTALL\_ENABLE Configures whether or not to enable debug Run-

Stall functionality between HP CPU and LP CPU.

- 0: Disable
- 1: Enable
- (R/W)

Register 17.4. HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_CONF\_REG (0x000C)

![Image](images/17_Chapter_17_img004_185eb944.png)

HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_THRES Configures the timeout threshold for bus access for accessing CPU peripheral register in the number of clock cycles of the clock domain. (R/W)

HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_INT\_CLEAR Write 1 to clear timeout interrupt. (WT)

HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_PROTECT\_EN Configures whether or not to enable timeout protection for accessing CPU peripheral registers.

0: Disable

1: Enable

(R/W)

Register 17.5. HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_ADDR\_REG (0x0010)

![Image](images/17_Chapter_17_img005_e4f1785e.png)

HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_ADDR Represents the address information of abnormal access. (RO)

Register 17.6. HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_UID\_REG (0x0014)

![Image](images/17_Chapter_17_img006_604810d0.png)

HP\_SYSTEM\_CPU\_PERI\_TIMEOUT\_UID Represents the master id[4:0] and master permission[6:5] when trigger timeout. This register will be cleared after the interrupt is cleared. (WTC)

## Register 17.7. HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_CONF\_REG (0x0018)

![Image](images/17_Chapter_17_img007_73d4b481.png)

- HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_THRES Configures the timeout threshold for bus access for accessing HP peripheral register, corresponding to the number of clock cycles of the clock domain. (R/W)
- HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_INT\_CLEAR Configures whether or not to clear timeout interrupt.
- 0: No effect
- 1: Clear timeout interrupt
- (WT)
- HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_PROTECT\_EN Configures whether or not to enable timeout protection for accessing HP peripheral registers.
- 0: Disable
- 1: Enable
- (R/W)

## Register 17.8. HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_ADDR\_REG (0x001C)

HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_ADDR Represents the address information of abnormal access. (RO)

![Image](images/17_Chapter_17_img008_ae6e2b74.png)

## Register 17.9. HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_UID\_REG (0x0020)

HP\_SYSTEM\_HP\_PERI\_TIMEOUT\_UID Represents the master id[4:0] and master permission[6:5] when trigger timeout. This register will be cleared after the interrupt is cleared. (WTC)

![Image](images/17_Chapter_17_img009_583f4128.png)

## Register 17.10. LP\_PERI\_BUS\_TIMEOUT\_CONF\_REG (0x0010)

![Image](images/17_Chapter_17_img010_3444e5dd.png)

- LP\_PERI\_BUS\_TIMEOUT\_THRES Configures the timeout threshold for bus access for accessing LP peripheral register, corresponding to the number of clock cycles of the clock domain. (R/W)
- LP\_PERI\_BUS\_TIMEOUT\_INT\_CLEAR Configures whether to clear timeout interrupt.
- 0: No effect
- 1: Clear timeout interrupt

(WT)

- LP\_PERI\_BUS\_TIMEOUT\_PROTECT\_EN Configures whether to enable timeout protection for accessing LP peripheral registers.
- 0: Disable
- 1: Enable

(R/W)

Register 17.11. LP\_PERI\_BUS\_TIMEOUT\_ADDR\_REG (0x0014)

![Image](images/17_Chapter_17_img011_7159c8db.png)

LP\_PERI\_BUS\_TIMEOUT\_ADDR Represents the address information of abnormal access. (RO)

Register 17.12. LP\_PERI\_BUS\_TIMEOUT\_UID\_REG (0x0018)

![Image](images/17_Chapter_17_img012_4ebae74e.png)

HP\_SYSTEM\_DATE Version control register. (R/W)
