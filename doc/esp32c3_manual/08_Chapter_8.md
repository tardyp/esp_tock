---
chapter: 8
title: "Chapter 8"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 8

## Interrupt Matrix (INTERRUPT)

## 8.1 Overview

The interrupt matrix embedded in ESP32-C3 independently routes peripheral interrupt sources to the ESP-RISC-V CPU's peripheral interrupts, to timely inform CPU to process the coming interrupts.

The ESP32-C3 has 62 peripheral interrupt sources. To map them to 31 CPU interrupts, this interrupt matrix is needed.

## Note:

This chapter focuses on how to map peripheral interrupt sources to CPU interrupts. For more details about interrupt configuration, vector, and ISA suggested operations, please refer to Chapter 1 ESP-RISC-V CPU .

## 8.2 Features

- Accept 62 peripheral interrupt sources as input
- Generate 31 CPU peripheral interrupts to CPU as output
- Query current interrupt status of peripheral interrupt sources
- Configure priority, type, threshold, and enable signal of CPU interrupts

Figure 8.2-1 shows the structure of the interrupt matrix.

![Image](images/08_Chapter_8_img001_04d8ef17.png)

Figure 8.2-1. Interrupt Matrix Structure

![Image](images/08_Chapter_8_img002_45afe642.png)

## 8.3 Functional Description

## 8.3.1 Peripheral Interrupt Sources

The ESP32-C3 has 62 peripheral interrupt sources in total. Table 8.3-1 lists all these sources and their configuration/status registers.

- Column "No.": Peripheral interrupt source number, can be 0 ~ 61.
- Column "Chapter": in which chapter the interrupt source is described in detailed.
- Column "Source": Name of the peripheral interrupt source.
- Column "Configuration Register": Registers used for routing the peripheral interrupt sources to CPU peripheral interrupts
- Column "Status Register": Registers used for indicating the interrupt status of peripheral interrupt sources.
- – Column "Status Register - Bit": Bit position in status register, indicating the interrupt status.
- – Column "Status Register - Name": Name of status registers.

Chapter 8 Interrupt Matrix (INTERRUPT)

Status Register

Name

Table 8.3-1. CPU Peripheral Interrupt Configuration/Status Registers and Peripheral Interrupt Sources

Bit

0

1

2

3

4

5

6

7

8

9

10

11

12

13

14

15

INTERRUPT\_CORE0\_UHCI0\_INTR\_MAP\_REG

16

INTERRUPT\_CORE0\_GPIO\_INTERRUPT\_PRO\_MAP\_REG

17

18

19

INTERRUPT\_CORE0\_SPI\_INTR\_2\_MAP\_REG

20

21

INTERRUPT\_CORE0\_UART\_INTR\_MAP\_REG

22

INTERRUPT\_CORE0\_UART1\_INTR\_MAP\_REG

23

24

25

26

27

GoBack

28

29

30

INTERRUPT\_CORE0\_EFUSE\_INT\_MAP\_REG

| Configuration Register   | reserved  reserved  reserved  reserved  reserved  reserved                                         | reserved  reserved                                                             | INTERRUPT_CORE0_I2S_INT_MAP_REG  INTERRUPT_CORE0_LEDC_INT_MAP_REG  INTERRUPT_CORE0_TWAI_INT_MAP_REG  reserved                                                                                                                                  |        |
|--------------------------|----------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------|
|                          | reserved                                                                                           |                                                                                |                                                                                                                                                                                                                                                | Source |
|                          | reserved  reserved  reserved                                                                       | reserved  reserved  reserved                                                   |                                                                                                                                                                                                                                                |        |
|                          | reserved  reserved  reserved  reserved  reserved  reserved  reserved  reserved  reserved  reserved | reserved  reserved  reserved  reserved  reserved  UHCI0_INTR  GPIO_PROCPU_INTR | GPSPI2_INTR_2  I2S_INTR  UART_INTR  UART1_INTR  LEDC_INTR  EFUSE_INTR  TWAI_INTR  USB_SERIAL_JTAG_INTR  RTC_CNTL_INTR  RMT_INTR  I2C_EXT0_INTR  reserved                                                                                       |        |
| Chapter                  | reserved                                                                                           | reserved  reserved                                                             | SPI Controller (SPI)  I2S Controller (I2S)  UART Controller (UART)                                                                                                                                                                             |        |
|                          | reserved  reserved  reserved  reserved  reserved  reserved  reserved  reserved  reserved           | reserved  reserved  reserved                                                   | reserved                                                                                                                                                                                                                                       |        |
|                          |                                                                                                    | UART Controller (UART)  IO MUX and GPIO Matrix (GPIO, IO MUX)                  | UART Controller (UART)  LED PWM Controller (LEDC)  eFuse Controller (EFUSE)  Two-wire Automotive Interface
 (TWAI)  USB Serial/JTAG Controller
 (USB_SERIAL_JTAG)  Low-power Management  Remote Control Peripheral (RMT)  I2C Controller (I2C) |        |
|                          | 0  1  2  3  4  5  6  7  8  9                                                                       | 10  11  12  13  14  15  16                                                     | 19  20  21  22  23  24  25 26 27  28  29  30                                                                                                                                                                                                   | No.    |

Espressif Systems

204

Submit Documentation Feedback

INTERRUPT\_CORE0\_USB\_INTR\_MAP\_REG

INTERRUPT\_CORE0\_RTC\_CORE\_INTR\_MAP\_REG

INTERRUPT\_CORE0\_RMT\_INTR\_MAP\_REG

INTERRUPT\_CORE0\_I2C\_EXT0\_INTR\_MAP\_REG

ESP32-C3 TRM (Version 1.3)

INTERRUPT\_CORE0\_INTR\_STATUS\_0\_REG

Chapter 8 Interrupt Matrix (INTERRUPT)

Status Register

Name

Bit

31

0

1

2

3

36

5

6

7

8

9

10

11

12

13

INTERRUPT\_CORE0\_INTR\_STATUS\_1\_REG

14

15

16

17

18

19

20

21

22

23

24

25

26

GoBack

27

28

RUPT\_CORE0\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_INTR\_MAP\_REG

|                        | INTERRUPT_CORE0_SYSTIMER_TARGET0_INT_MAP_REG  reserved                                                                                                              | INTERRUPT_CORE0_DMA_CH1_INT_MAP_REG  INTERRUPT_CORE0_DMA_CH2_INT_MAP_REG                                                                                                                 | INTERRUPT_CORE0_CPU_INTR_FROM_CPU_1_MAP_REG                                                                                                |                       |
|------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------|-----------------------|
|                        | reserved                                                                                                                                                            | SHA_INTR                                                                                                                                                                                 |                                                                                                                                            | SYSTIMER_TARGET0_INTR |
|                        | INTERRUPT_CORE0_TG1_T0_INT_MAP_REG  INTERRUPT_CORE0_TG1_WDT_INT_MAP_REG  INTERRUPT_CORE0_SYSTIMER_TARGET1_INT_MAP_REG  INTERRUPT_CORE0_SYSTIMER_TARGET2_INT_MAP_REG | INTERRUPT_CORE0_DMA_CH0_INT_MAP_REG  INTERRUPT_CORE0_RSA_INTR_MAP_REG                                                                                                                    | INTERRUPT_CORE0_ASSIST_DEBUG_INTR_MAP_REG                                                                                                  |                       |
| Configuration Register | reserved                                                                                                                                                            |                                                                                                                                                                                          |                                                                                                                                            |                       |
| reserved               | reserved                                                                                                                                                            |                                                                                                                                                                                          | INTER-  INTER-  INTER-  INTER-  INTER-  reserved                                                                                           |                       |
|                        | INTERRUPT_CORE0_TG_WDT_INT_MAP_REG                                                                                                                                  |                                                                                                                                                                                          | INTERRUPT_CORE0_CPU_INTR_FROM_CPU_3_MAP_REG                                                                                                |                       |
|                        |                                                                                                                                                                     | INTERRUPT_CORE0_APB_ADC_INT_MAP_REG  INTERRUPT_CORE0_AES_INTR_MAP_REG  INTERRUPT_CORE0_SHA_INTR_MAP_REG                                                                                  | INTERRUPT_CORE0_CPU_INTR_FROM_CPU_2_MAP_REG                                                                                                |                       |
|                        |                                                                                                                                                                     | vDIGTAL_ADC_INTR                                                                                                                                                                         | SW_INTR_1                                                                                                                                  |                       |
|                        |                                                                                                                                                                     | GDMA_CH0_INTR  GDMA_CH1_INTR  GDMA_CH2_INTR  AES_INTR                                                                                                                                    |                                                                                                                                            |                       |
| reserved               | reserved                                                                                                                                                            | RSA_INTR                                                                                                                                                                                 | reserved                                                                                                                                   |                       |
| Source                 | TG_WDT_INTR  TG1_T0_INTR  TG1_WDT_INTR  SYSTIMER_TARGET1_INTR  SYSTIMER_TARGET2_INTR  reserved                                                                      |                                                                                                                                                                                          | SW_INTR_2  SW_INTR_3  ASSIST_DEBUG_INTR  PMS_DMA_VIO_INTR  PMS_IBUS_VIO_INTR  PMS_DBUS_VIO_INTR  PMS_PERI_VIO_INTR  PMS_PERI_VIO_SIZE_INTR |                       |
|                        | Timer Group (TIMG)  Timer Group (TIMG)  Timer Group (TIMG)  System Timer (SYSTIMER)  System Timer (SYSTIMER)  System Timer (SYSTIMER)                               |                                                                                                                                                                                          |                                                                                                                                            |                       |
| Chapter  reserved      | reserved  reserved  reserved                                                                                                                                        |                                                                                                                                                                                          | System Registers (SYSREG)  System Registers (SYSREG)  System Registers (SYSREG)  Debug Assistant (ASSIST_DEBUG)  reserved                  |                       |
|                        |                                                                                                                                                                     | On-Chip Sensor and Analog Signal Processing  GDMA Controller (GDMA)  GDMA Controller (GDMA)  GDMA Controller (GDMA)  RSA Accelerator (RSA)  AES Accelerator (AES)  SHA Accelerator (SHA) | Permission Control (PMS)  Permission Control (PMS)  Permission Control (PMS)  Permission Control (PMS)  Permission Control (PMS)           |                       |
| No.  31                | 33  34  35  36  37  38  39  40  41                                                                                                                                  | 43  44  45  46  47  48  49                                                                                                                                                               | 51  52  53  54  55  56  57  58  59  60                                                                                                     |                       |

Espressif Systems

205

Submit Documentation Feedback

RUPT\_CORE0\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_INTR\_MAP\_REG

RUPT\_CORE0\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_INTR\_MAP\_REG

RUPT\_CORE0\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_INTR\_MAP\_REG

RUPT\_CORE0\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_SIZE\_INTR\_MAP\_REG

ESP32-C3 TRM (Version 1.3)

Chapter 8 Interrupt Matrix (INTERRUPT)

Status Register

Name

Bit

29

reserved reserved

reserved

Configuration Register

Source

Chapter

No.

61

Espressif Systems

206

Submit Documentation Feedback

GoBack

ESP32-C3 TRM (Version 1.3)

## 8.3.2 CPU Interrupts

The ESP32-C3 implements its interrupt mechanism using an interrupt controller instead of RISC-V Privileged ISA specification. The ESP-RISC-V CPU has 31 interrupts, numbered from 1 ~ 31. Each CPU interrupt has the following properties.

- Priority levels from 1 (lowest) to 15 (highest).
- Configurable as level-triggered or edge-triggered.
- Lower-priority interrupts mask-able by setting interrupt threshold.

## Note:

For detailed information about how to configure CPU interrupts, see Chapter 1 ESP-RISC-V CPU .

## 8.3.3 Allocate Peripheral Interrupt Source to CPU Interrupt

In this section, the following terms are used to describe the operation of the interrupt matrix.

- Source\_X: stands for a peripheral interrupt source, wherein X means the number of this interrupt source in Table 8.3-1 .
- INTERRUPT\_CORE0\_SOURCE\_X\_MAP\_REG: stands for a configuration register for the peripheral interrupt source (Source\_X).
- Num\_P: the index of CPU interrupts, can be 1 ~ 31.
- Interrupt\_P: stands for the CPU interrupt numbered as Num\_P.

## 8.3.3.1 Allocate one peripheral interrupt source (Source\_X) to CPU

Setting the corresponding configuration register INTERRUPT\_CORE0\_SOURCE\_X\_MAP\_REG of Source\_X to Num\_P allocates this interrupt source to Interrupt\_P.

## 8.3.3.2 Allocate multiple peripheral interrupt sources (Source\_Xn) to CPU

Setting the corresponding configuration register INTERRUPT\_CORE0\_SOURCE\_Xn\_MAP\_REG of each interrupt source to the same Num\_P allocates multiple sources to the same Interrupt\_P. Any of these sources can trigger CPU Interrupt\_P. When an interrupt signal is generated, CPU should check the interrupt status registers to figure out which peripheral generated the interrupt. For more information, see Chapter 1 ESP-RISC-V CPU .

## 8.3.3.3 Disable CPU peripheral interrupt source (Source\_X)

Clearing the configuration register INTERRUPT\_CORE0\_SOURCE\_X\_MAP\_REG disables the corresponding interrupt source.

## 8.3.4 Query Current Interrupt Status of Peripheral Interrupt Source

Users can query current interrupt status of a peripheral interrupt source by reading the bit value in INTERRUPT\_CORE0

\_INTR\_STATUS\_n\_REG (read only). For the mapping between INTERRUPT\_CORE0\_INTR\_STATUS\_n\_REG and peripheral interrupt sources, please refer to Table 8.3-1 .

ESP32-C3 TRM (Version 1.3)

Chapter 8 Interrupt Matrix (INTERRUPT)

Access

R/W

Address

0x0008

PWR\_INTR mapping register

R/W

0x002C

I2C\_MST\_INT mapping register

R/W

0x0030

SLC0\_INTR mapping register

R/W

0x0034

SLC1\_INTR mapping register

Register Summary

8.4

.

The addresses in this section are relative to the interrupt matrix base address provided in Table

| Description                                                                                                                                                                                                                                                                                                                             |                                                                                                                                                                                                                                                             |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| are explained in Section                                                                                                                                                                                                                                                                                                                |                                                                                                                                                                                                                                                             |
| INTERRUPT_CORE0_SPI_INTR_1_MAP_REG                                                                                                                                                                                                                                                                                                      |                                                                                                                                                                                                                                                             |
| Access                                                                                                                                                                                                                                                                                                                                  | INTERRUPT_CORE0_TWAI_INT_MAP_REG  INTERRUPT_CORE0_TG_WDT_INT_MAP_REG                                                                                                                                                                                        |
|                                                                                                                                                                                                                                                                                                                                         | INTERRUPT_CORE0_USB_INTR_MAP_REG  INTERRUPT_CORE0_RTC_CORE_INTR_MAP_REG  INTERRUPT_CORE0_RMT_INTR_MAP_REG  INTERRUPT_CORE0_I2C_EXT0_INTR_MAP_REG  INTERRUPT_CORE0_TIMER_INT1_MAP_REG  INTERRUPT_CORE0_TIMER_INT2_MAP_REG  INTERRUPT_CORE0_TG_T0_INT_MAP_REG |
| The abbreviations given in Column  Interrupt Source Mapping RegistersINTERRUPT_CORE0_PWR_INTR_MAP_REG  INTERRUPT_CORE0_I2C_MST_INT_MAP_REG  INTERRUPT_CORE0_SLC0_INTR_MAP_REG  INTERRUPT_CORE0_SLC1_INTR_MAP_REG  INTERRUPT_CORE0_APB_CTRL_INTR_MAP_REG  INTERRUPT_CORE0_UHCI0_INTR_MAP_REG  INTERRUPT_CORE0_GPIO_INTERRUPT_PRO_MAP_REG |                                                                                                                                                                                                                                                             |
| INTERRUPT_CORE0_SPI_INTR_2_MAP_REG  INTERRUPT_CORE0_I2S_INT_MAP_REG                                                                                                                                                                                                                                                                     |                                                                                                                                                                                                                                                             |
| Name                                                                                                                                                                                                                                                                                                                                    |                                                                                                                                                                                                                                                             |

Espressif Systems

R/W

0x0048

R/W

0x004C

SPI\_INTR\_1 mapping register

SPI\_INTR\_2 mapping register

209

Submit Documentation Feedback

R/W

0x0068

R/W

0x006C

R/W

0x0070

R/W

0x0074

R/W

0x0078

GoBack

R/W

R/W

R/W

0x007C

0x0080

0x0084

USB\_INTR mapping register

RTC\_CORE\_INTR mapping register

RMT\_INTR mapping register

I2C\_EXT0 intr mapping register

TIMER\_INT1 mapping register

TIMER\_INT2 mapping register

TG\_T0\_INT mapping register

TG\_WDT\_INT mapping register

ESP32-C3 TRM (Version 1.3)

Access Types for Registers

.

System and Memory

3

## in Chapter

3.3-3

R/W

0x0038

APB\_CTRL\_INTR mapping register

R/W

0x003C

UHCI0\_INTR mapping register

R/W

0x0040

GPIO\_INTERRUPT\_PRO mapping register

R/W

0x0050

I2S\_INT mapping register

R/W

0x0054

UART\_INTR mapping register

R/W

0x0058

UART1\_INTR mapping register

R/W

0x005C

LEDC\_INT mapping register

R/W

0x0060

EFUSE\_INT mapping register

R/W

0x0064

TWAI\_INT mapping register

Chapter 8 Interrupt Matrix (INTERRUPT)

Access

R/W

R/W

R/W

R/W

R/W

Address

Description

R/W

0x0088

TG1\_T0\_INT mapping register

R/W

0x008C

TG1\_WDT\_INT mapping register

0x0094

SYSTIMER\_TARGET0\_INT mapping register

Name

INTERRUPT\_CORE0\_TG1\_T0\_INT\_MAP\_REG

INTERRUPT\_CORE0\_TG1\_WDT\_INT\_MAP\_REG

0x0090

0x0098

SYSTIMER\_TARGET1\_INT mapping register

0x009C

SYSTIMER\_TARGET2\_INT mapping register

0x00A0

SPI\_MEM\_REJECT\_INTR mapping register

R/W

0x00A4

ICACHE\_PRELOAD\_INT mapping register

R/W

0x00A8

R/W

0x00AC

R/W

0x00B0

R/W

0x00B4

R/W

0x00B8

R/W

0x00BC

R/W

0x00C0

R/W

0x00C4

R/W

0x00C8

CPU\_INTR\_FROM\_CPU\_0 mapping register

R/W

0x00CC

CPU\_INTR\_FROM\_CPU\_1 mapping register

R/W

0x00D0

CPU\_INTR\_FROM\_CPU\_2 mapping register

R/W

0x00D4

CPU\_INTR\_FROM\_CPU\_3 intr mapping register

R/W

0x00D8

R/W

0x00DC

R/W

0x00E0

R/W

0x00E4

GoBack

R/W

0x00E8

DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE mapping register

| CACHE_IA_INT mapping register  ICACHE_SYNC_INT mapping register  APB_ADC_INT mapping register  DMA_CH0_INT mapping register  DMA_CH1_INT mapping register  DMA_CH2_INT mapping register  RSA_INT mapping register  AES_INT mapping register  SHA_INT mapping register                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | ASSIST_DEBUG_INTR mapping register                                                                                                                                                                                                                              |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | INTERRUPT_CORE0_ASSIST_DEBUG_INTR_MAP_REG                                                                                                                                                                                                                       |
| INTERRUPT_CORE0_CACHE_IA_INT_MAP_REG  INTERRUPT_CORE0_SYSTIMER_TARGET0_INT_MAP_REG  INTERRUPT_CORE0_SYSTIMER_TARGET1_INT_MAP_REG  INTERRUPT_CORE0_SYSTIMER_TARGET2_INT_MAP_REG  INTERRUPT_CORE0_SPI_MEM_REJECT_INTR_MAP_REG  INTERRUPT_CORE0_ICACHE_PRELOAD_INT_MAP_REG  INTERRUPT_CORE0_ICACHE_SYNC_INT_MAP_REG  INTERRUPT_CORE0_APB_ADC_INT_MAP_REG  INTERRUPT_CORE0_DMA_CH0_INT_MAP_REG  INTERRUPT_CORE0_DMA_CH1_INT_MAP_REG  INTERRUPT_CORE0_DMA_CH2_INT_MAP_REG  INTERRUPT_CORE0_RSA_INT_MAP_REG  INTERRUPT_CORE0_AES_INT_MAP_REG  INTERRUPT_CORE0_SHA_INT_MAP_REG  INTERRUPT_CORE0_CPU_INTR_FROM_CPU_0_MAP_REG  INTERRUPT_CORE0_CPU_INTR_FROM_CPU_1_MAP_REG  INTERRUPT_CORE0_CPU_INTR_FROM_CPU_2_MAP_REG  INTERRUPT_CORE0_CPU_INTR_FROM_CPU_3_MAP_REG | INTERRUPT_CORE0_DMA_APBPERI_PMS_MONITOR_VIOLATE_  INTR_MAP_REG  INTERRUPT_CORE0_CORE_0_IRAM0_PMS_MONITOR_VIOLATE  _INTR_MAP_REG  INTERRUPT_CORE0_CORE_0_DRAM0_PMS_MONITOR_VIOLAT  E_INTR_MAP_REG  INTERRUPT_CORE0_CORE_0_PIF_PMS_MONITOR_VIOLATE_  INTR_MAP_REG |

Espressif Systems

210

Submit Documentation Feedback

IRAM0\_PMS\_MONITOR\_VIOLATE mapping register

DRAM0\_PMS\_MONITOR\_VIOLATE mapping register

PIF\_PMS\_MONITOR\_VIOLATE mapping register

ESP32-C3 TRM (Version 1.3)

Chapter 8 Interrupt Matrix (INTERRUPT)

Access

R/W

R/W

RO

RO

Address

Description

R/W

0x00EC

PIF\_PMS\_MONITOR\_VIOLATE\_SIZE mapping register

0x00F0

BACKUP\_PMS\_VIOLATE mapping register

Name

INTERRUPT\_CORE0\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_

SIZE\_INTR\_MAP\_REG

0x00F8

31

~

| CACHE_CORE0_ACS mapping register  Status register for interrupt sources 0 Status register for interrupt sources 32 Enable register for CPU interrupts  CPU interrupt clear register                                                                                                                  |                                                                                                                                                                                                                                                                                              |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Clock register                                                                                                                                                                                                                                                                                       |                                                                                                                                                                                                                                                                                              |
| INTERRUPT_CORE0_BACKUP_PMS_VIOLATE_INTR_MAP_REG                                                                                                                                                                                                                                                      |                                                                                                                                                                                                                                                                                              |
| INTERRUPT_CORE0_CACHE_CORE0_ACS_INT_MAP_REG  Interrupt Source Status Registers INTERRUPT_CORE0_INTR_STATUS_0_REG  INTERRUPT_CORE0_INTR_STATUS_1_REG  INTERRUPT_CORE0_CPU_INT_ENABLE_REG  INTERRUPT_CORE0_CPU_INT_TYPE_REG  INTERRUPT_CORE0_CPU_INT_CLEAR_REG  INTERRUPT_CORE0_CPU_INT_EIP_STATUS_REG | INTERRUPT_CORE0_CPU_INT_PRI_7_REG                                                                                                                                                                                                                                                            |
| INTERRUPT_CORE0_CLOCK_GATE_REG                                                                                                                                                                                                                                                                       | INTERRUPT_CORE0_CPU_INT_PRI_8_REG  INTERRUPT_CORE0_CPU_INT_PRI_9_REG  INTERRUPT_CORE0_CPU_INT_PRI_10_REG  INTERRUPT_CORE0_CPU_INT_PRI_11_REG  INTERRUPT_CORE0_CPU_INT_PRI_12_REG  INTERRUPT_CORE0_CPU_INT_PRI_13_REG  INTERRUPT_CORE0_CPU_INT_PRI_14_REG  INTERRUPT_CORE0_CPU_INT_PRI_15_REG |
| Clock Register CPU Interrupt Registers                                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                              |

Espressif Systems

RO

0x0110

R/W

0x0118

Pending status register for CPU interrupts

Priority configuration register for CPU interrupt 1

211

Submit Documentation Feedback

R/W

0x0134

R/W

0x0138

R/W

0x013C

R/W

0x0140

R/W

0x0144

GoBack

R/W

R/W

R/W

0x0148

0x014C

0x0150

Priority configuration register for CPU interrupt 8

Priority configuration register for CPU interrupt 9

Priority configuration register for CPU interrupt 10

Priority configuration register for CPU interrupt 11

Priority configuration register for CPU interrupt 12

Priority configuration register for CPU interrupt 13

Priority configuration register for CPU interrupt 14

Priority configuration register for CPU interrupt 15

ESP32-C3 TRM (Version 1.3)

0x00F4

0x00FC

61

~

R/W

0x0100

R/W

0x0104

R/W

0x0108

Type configuration register for CPU interrupts

R/W

0x010C

R/W

0x011C

Priority configuration register for CPU interrupt 2

R/W

0x0120

Priority configuration register for CPU interrupt 3

R/W

0x0124

Priority configuration register for CPU interrupt 4

R/W

0x0128

Priority configuration register for CPU interrupt 5

R/W

0x012C

Priority configuration register for CPU interrupt 6

R/W

0x0130

Priority configuration register for CPU interrupt 7

Chapter 8 Interrupt Matrix (INTERRUPT)

Access

R/W

R/W

R/W

R/W

R/W

Address

Description

R/W

0x0154

Priority configuration register for CPU interrupt 16

R/W

0x0158

Priority configuration register for CPU interrupt 17

0x015C

Priority configuration register for CPU interrupt 18

0x0160

Priority configuration register for CPU interrupt 19

0x0164

Priority configuration register for CPU interrupt 20

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_20\_REG

0x0168

Priority configuration register for CPU interrupt 21

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_21\_REG

0x016C

Priority configuration register for CPU interrupt 22

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_22\_REG

R/W

0x0170

Priority configuration register for CPU interrupt 23

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_23\_REG

R/W

0x0174

Priority configuration register for CPU interrupt 24

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_24\_REG

R/W

0x0178

Priority configuration register for CPU interrupt 25

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_25\_REG

R/W

0x017C

Priority configuration register for CPU interrupt 26

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_26\_REG

R/W

0x0180

Priority configuration register for CPU interrupt 27

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_27\_REG

R/W

0x0184

Priority configuration register for CPU interrupt 28

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_28\_REG

R/W

0x0188

Priority configuration register for CPU interrupt 29

R/W

0x018C

Priority configuration register for CPU interrupt 30

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_29\_REG

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_30\_REG

R/W

0x0190

Priority configuration register for CPU interrupt 31

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_31\_REG

R/W

0x0194

Threshold configuration register for CPU interrupts

INTERRUPT\_CORE0\_CPU\_INT\_THRESH\_REG

R/W

0x07FC

| Version control register   |
|----------------------------|

Name

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_16\_REG

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_17\_REG

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_18\_REG

INTERRUPT\_CORE0\_CPU\_INT\_PRI\_19\_REG

Espressif Systems

Version Register

212

Submit Documentation Feedback

INTERRUPT\_CORE0\_INTERRUPT\_DATE\_REG

GoBack

ESP32-C3 TRM (Version 1.3)

## 8.5 Registers

The addresses in this section are relative to the interrupt matrix base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 8.1. INTERRUPT\_CORE0\_PWR\_INTR\_MAP\_REG (0x0008) Register 8.2. INTERRUPT\_CORE0\_I2C\_MST\_INT\_MAP\_REG (0x002C) Register 8.3. INTERRUPT\_CORE0\_SLC0\_INTR\_MAP\_REG (0x0030) Register 8.4. INTERRUPT\_CORE0\_SLC1\_INTR\_MAP\_REG (0x0034) Register 8.5. INTERRUPT\_CORE0\_SYSCON\_INTR\_MAP\_REG (0x0038) Register 8.6. INTERRUPT\_CORE0\_UHCI0\_INTR\_MAP\_REG (0x003C) Register 8.7. INTERRUPT\_CORE0\_GPIO\_INTERRUPT\_PRO\_MAP\_REG (0x0040) Register 8.8. INTERRUPT\_CORE0\_SPI\_INTR\_1\_MAP\_REG (0x0048) Register 8.9. INTERRUPT\_CORE0\_SPI\_INTR\_2\_MAP\_REG (0x004C) Register 8.10. INTERRUPT\_CORE0\_I2S\_INT\_MAP\_REG (0x0050) Register 8.11. INTERRUPT\_CORE0\_UART\_INTR\_MAP\_REG (0x0054) Register 8.12. INTERRUPT\_CORE0\_UART1\_INTR\_MAP\_REG (0x0058) Register 8.13. INTERRUPT\_CORE0\_LEDC\_INT\_MAP\_REG (0x005C) Register 8.14. INTERRUPT\_CORE0\_EFUSE\_INT\_MAP\_REG (0x0060) Register 8.15. INTERRUPT\_CORE0\_TWAI\_INT\_MAP\_REG (0x0064) Register 8.16. INTERRUPT\_CORE0\_USB\_INTR\_MAP\_REG (0x0068) Register 8.17. INTERRUPT\_CORE0\_RTC\_CORE\_INTR\_MAP\_REG (0x006C) Register 8.18. INTERRUPT\_CORE0\_RMT\_INTR\_MAP\_REG (0x0070) Register 8.19. INTERRUPT\_CORE0\_I2C\_EXT0\_INTR\_MAP\_REG (0x0074) Register 8.20. INTERRUPT\_CORE0\_TIMER\_INT1\_MAP\_REG (0x0078) Register 8.21. INTERRUPT\_CORE0\_TIMER\_INT2\_MAP\_REG (0x007C) Register 8.22. INTERRUPT\_CORE0\_TG\_T0\_INT\_MAP\_REG (0x0080) Register 8.23. INTERRUPT\_CORE0\_TG\_WDT\_INT\_MAP\_REG (0x0084) Register 8.24. INTERRUPT\_CORE0\_TG1\_T0\_INT\_MAP\_REG (0x0088) Register 8.25. INTERRUPT\_CORE0\_TG1\_WDT\_INT\_MAP\_REG (0x008C) Register 8.26. INTERRUPT\_CORE0\_CACHE\_IA\_INT\_MAP\_REG (0x0090) Register 8.27. INTERRUPT\_CORE0\_SYSTIMER\_TARGET0\_INT\_MAP\_REG (0x0094) Register 8.28. INTERRUPT\_CORE0\_SYSTIMER\_TARGET1\_INT\_MAP\_REG (0x0098) Register 8.29. INTERRUPT\_CORE0\_SYSTIMER\_TARGET2\_INT\_MAP\_REG (0x009C) Register 8.30. INTERRUPT\_CORE0\_SPI\_MEM\_REJECT\_INTR\_MAP\_REG (0x00A0)

Register 8.31. INTERRUPT\_CORE0\_ICACHE\_PRELOAD\_INT\_MAP\_REG (0x00A4)

Register 8.32. INTERRUPT\_CORE0\_ICACHE\_SYNC\_INT\_MAP\_REG (0x00A8)

Register 8.33. INTERRUPT\_CORE0\_APB\_ADC\_INT\_MAP\_REG (0x00AC)

Register 8.34. INTERRUPT\_CORE0\_DMA\_CH0\_INT\_MAP\_REG (0x00B0)

Register 8.35. INTERRUPT\_CORE0\_DMA\_CH1\_INT\_MAP\_REG (0x00B4)

Register 8.36. INTERRUPT\_CORE0\_DMA\_CH2\_INT\_MAP\_REG (0x00B8)

Register 8.37. INTERRUPT\_CORE0\_RSA\_INT\_MAP\_REG (0x00BC)

Register 8.38. INTERRUPT\_CORE0\_AES\_INT\_MAP\_REG (0x00C0)

Register 8.39. INTERRUPT\_CORE0\_SHA\_INT\_MAP\_REG (0x00C4)

Register 8.40. INTERRUPT\_CORE0\_CPU\_INTR\_FROM\_CPU\_0\_MAP\_REG (0x00C8)

Register 8.41. INTERRUPT\_CORE0\_CPU\_INTR\_FROM\_CPU\_1\_MAP\_REG (0x00CC)

Register 8.42. INTERRUPT\_CORE0\_CPU\_INTR\_FROM\_CPU\_2\_MAP\_REG (0x00D0)

Register 8.43. INTERRUPT\_CORE0\_CPU\_INTR\_FROM\_CPU\_3\_MAP\_REG (0x00D4)

Register 8.44. INTERRUPT\_CORE0\_ASSIST\_DEBUG\_INTR\_MAP\_REG (0x00D8)

Register 8.45. INTERRUPT\_CORE0\_DMA\_APBPERI\_PMS\_MONITOR\_VIOLATE\_INTR\_MAP\_REG (0x00DC)

Register 8.46. INTERRUPT\_CORE0\_CORE\_0\_IRAM0\_PMS\_MONITOR\_VIOLATE\_INTR\_MAP\_REG (0x00E0)

Register 8.47. INTERRUPT\_CORE0\_CORE\_0\_DRAM0\_PMS\_MONITOR\_VIOLATE\_INTR\_MAP\_REG (0x00E4)

Register 8.48. INTERRUPT\_CORE0\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_INTR\_MAP\_REG (0x00E8)

Register 8.49. INTERRUPT\_CORE0\_CORE\_0\_PIF\_PMS\_MONITOR\_VIOLATE\_SIZE\_INTR\_MAP\_REG (0x00EC)

Register 8.50. INTERRUPT\_CORE0\_BACKUP\_PMS\_VIOLATE\_INTR\_MAP\_REG (0x00F0)

Register 8.51. INTERRUPT\_CORE0\_CACHE\_CORE0\_ACS\_INT\_MAP\_REG (0x00F4)

![Image](images/08_Chapter_8_img003_35d67a4c.png)

INTERRUPT\_CORE0\_SOURCE\_X\_MAP Map the interrupt source (SOURCE\_X) into one CPU interrupt. For the information of SOURCE\_X, see Table 8.3-1. (R/W)

Register 8.52. INTERRUPT\_CORE0\_INTR\_STATUS\_0\_REG (0x00F8)

![Image](images/08_Chapter_8_img004_7550241d.png)

INTERRUPT\_CORE0\_INTR\_STATUS\_0 This register stores the status of the first 32 interrupt sources: 0 ~ 31. If the bit is 1 here, it means the corresponding source triggered an interrupt. (RO)

![Image](images/08_Chapter_8_img005_8db78485.png)

INTERRUPT\_CORE0\_INTR\_STATUS\_1 This register stores the status of the first 32 interrupt sources: 32 ~ 61. If the bit is 1 here, it means the corresponding source triggered an interrupt. (RO)

Register 8.54. INTERRUPT\_CORE0\_CLOCK\_GATE\_REG (0x0100)

![Image](images/08_Chapter_8_img006_826f8ef7.png)

INTERRUPT\_CORE0\_CLK\_EN Set 1 to force interrupt register clock-gate on. (R/W)

Register 8.55. INTERRUPT\_CORE0\_CPU\_INT\_ENABLE\_REG (0x0104)

![Image](images/08_Chapter_8_img007_e5767346.png)

INTERRUPT\_CORE0\_CPU\_INT\_ENABLE Writing 1 to the bit here enables its corresponding CPU interrupt. For more information about how to use this register, see Chapter 1 ESP-RISC-V CPU . (R/W)

![Image](images/08_Chapter_8_img008_d066145f.png)

INTERRUPT\_CORE0\_CPU\_INT\_TYPE Configure CPU interrupt type. 0: level-triggered; 1: edgetriggered. For more information about how to use this register, see Chapter 1 ESP-RISC-V CPU . (R/W)

Register 8.57. INTERRUPT\_CORE0\_CPU\_INT\_CLEAR\_REG (0x010C)

![Image](images/08_Chapter_8_img009_61ffe045.png)

INTERRUPT\_CORE0\_CPU\_INT\_CLEAR Writing 1 to the bit here clears its corresponding CPU interrupt. For more information about how to use this register, see Chapter 1 ESP-RISC-V CPU. (R/W)

Register 8.58. INTERRUPT\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG (0x0110)

![Image](images/08_Chapter_8_img010_c9bb4ffe.png)

INTERRUPT\_CORE0\_CPU\_INT\_EIP\_STATUS Store the pending status of CPU interrupts. For more information about how to use this register, see Chapter 1 ESP-RISC-V CPU. (RO)

Register 8.59. INTERRUPT\_CORE0\_CPU\_INT\_PRI\_n\_REG (n: 1 - 31)(0x0118 + 0x4*n)

![Image](images/08_Chapter_8_img011_93354299.png)

INTERRUPT\_CORE0\_CPU\_PRI\_n\_MAP Set the priority for CPU interrupt n. The priority here can be 1 (lowest) ~ 15 (highest). For more information about how to use this register, see Chapter 1 ESP-RISC-V CPU. (R/W)

Register 8.60. INTERRUPT\_CORE0\_CPU\_INT\_THRESH\_REG (0x0194)

![Image](images/08_Chapter_8_img012_4a233945.png)

INTERRUPT\_CORE0\_INTERRUPT\_DATE Version control register. (R/W)
