---
chapter: 10
title: "Chapter 10"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 10

## Interrupt Matrix (INTMTX)

## 10.1 Overview

The interrupt matrix embedded in ESP32-C6 independently routes peripheral interrupt sources to the ESP-RISC-V CPU's peripheral interrupts to timely inform CPU to process the coming interrupts.

The ESP32-C6 has 77 peripheral interrupt sources that can be routed to any of the 28 CPU interrupts using the interrupt matrix.

## Note:

This chapter focuses on how to map peripheral interrupt sources to CPU interrupts. For more details about interrupt configuration, vector, and interrupt handling operations recommended by the ISA, please refer to Chapter 1 HighPerformance CPU .

## 10.2 Features

The interrupt matrix embedded in ESP32-C6 has the following features:

- 77 peripheral interrupt sources accepted as input
- 28 CPU peripheral interrupts generated to CPU as output
- Current interrupt status query of peripheral interrupt sources
- Multiple interrupt sources mapping to a single CPU interrupt (i.e., shared interrupts)

Figure 10.2-1 shows the structure of the interrupt matrix.

Figure 10.2-1. Interrupt Matrix Structure

![Image](images/10_Chapter_10_img001_d333b61b.png)

## 10.3 Functional Description

## 10.3.1 Peripheral Interrupt Sources

The ESP32-C6 has 77 peripheral interrupt sources in total. Table 10.3-1 lists all these sources and their mapping/status registers.

- Column "No.": Peripheral interrupt source number, can be 0 ~ 76.
- Column "Chapter": in which chapter the interrupt source is described in detail.
- Column "Interrupt Source": Name of the peripheral interrupt source.
- Column "Interrupt Source Mapping Register": Registers used for routing the peripheral interrupt sources to CPU peripheral interrupts.
- Column "Interrupt Status Register": Registers used for indicating the interrupt status of peripheral interrupt sources.
- – Column "Interrupt Status Register - Bit": Bit position in status register, indicating the interrupt status.
- – Column "Interrupt Status Register - Name": Name of status registers.

Chapter 10 Interrupt Matrix (INTMTX)

Interrupt Status Register

Name

Table 10.3-1. CPU Peripheral Interrupt Source Mapping/Status Registers and Peripheral Interrupt Sources

1

reserved

2

reserved

0

reserved

4

reserved

7

reserved

8

reserved

13

INTMTX\_CORE0\_PMU\_INTR\_MAP\_REG

12

reserved

14

INTMTX\_CORE0\_EFUSE\_INTR\_MAP\_REG

11

reserved

15

INTMTX\_CORE0\_LP\_RTC\_TIMER\_INTR\_MAP\_REG

10

reserved

INTMTX\_CORE0\_INT\_STATUS\_0\_REG

16

INTMTX\_CORE0\_LP\_UART\_INTR\_MAP\_REG

17

INTMTX\_CORE0\_LP\_I2C\_INTR\_MAP\_REG

18

INTMTX\_CORE0\_LP\_WDT\_INTR\_MAP\_REG

19

INTMTX\_CORE0\_LP\_PERI\_TIMEOUT\_INTR\_MAP\_REG

9

reserved

5

reserved

6

reserved

3

reserved

25

INTMTX\_CORE0\_CPU\_INTR\_FROM\_CPU\_3\_MAP\_REG

20

INTMTX\_CORE0\_LP\_APM\_M0\_INTR\_MAP\_REG

26

INTMTX\_CORE0\_ASSIST\_DEBUG\_INTR\_MAP\_REG

27

INTMTX\_CORE0\_TRACE\_INTR\_MAP\_REG

22

INTMTX\_CORE0\_CPU\_INTR\_FROM\_CPU\_0\_MAP\_REG

23

INTMTX\_CORE0\_CPU\_INTR\_FROM\_CPU\_1\_MAP\_REG

24

INTMTX\_CORE0\_CPU\_INTR\_FROM\_CPU\_2\_MAP\_REG

21

INTMTX\_CORE0\_LP\_APM\_M1\_INTR\_MAP\_REG

28

reserved

31

reserved

29

INTMTX\_CORE0\_CPU\_PERI\_TIMEOUT\_INTR\_MAP\_REG

Bit

Interrupt Source Mapping Register

30

INTMTX\_CORE0\_GPIO\_INTERRUPT\_PRO\_MAP\_REG

| Interrupt Source   | reserved                                                             | EFUSE_INTR  LP_PERI_TIMEOUT_INTR  LP_APM_M1_INTR  CPU_INTR_FROM_CPU_0                                                                                                                                |                                                                                              |
|--------------------|----------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
|                    | reserved                                                             | LP_WDT_INTR                                                                                                                                                                                          |                                                                                              |
|                    | reserved  reserved  reserved  reserved  reserved  reserved  reserved | LP_I2C_INTR                                                                                                                                                                                          | CPU_INTR_FROM_CPU_2  TRACE_INTR  reserved  reserved                                          |
|                    |                                                                      | LP_UART_INTR  LP_APM_M0_INTR                                                                                                                                                                         | ASSIST_DEBUG_INTR  GPIO_INTERRUPT_PRO                                                        |
|                    |                                                                      | LP_RTC_TIMER_INTR                                                                                                                                                                                    | CPU_INTR_FROM_CPU_3  CPU_PERI_TIMEOUT_INTR                                                   |
|                    |                                                                      |                                                                                                                                                                                                      | IO MUX and GPIO Matrix (GPIO, IO MUX)                                                        |
|                    |                                                                      | eFuse Controller                                                                                                                                                                                     | High-Performance CPU                                                                         |
| Chapter            |                                                                      |                                                                                                                                                                                                      | High-Performance CPU  Debug Assistant (ASSIST_DEBUG)  High-Performance CPU  System Registers |
|                    | n/a  n/a  n/a  n/a  n/a  n/a  n/a                                    |                                                                                                                                                                                                      | n/a  n/a                                                                                     |
|                    | n/a  n/a                                                             | Low-Power Management  UART Controller (UART, LP_UART, UHCI)  I2C Controller (I2C)  Watchdog Timers (WDT)  System Registers  Permission Control (PMS)  Permission Control (PMS)  High-Performance CPU |                                                                                              |

No.

1

0

2

Espressif Systems

3

4

5

6

7

8

9

10

17

15

18

14

16

12

13

19

11

20

381

Submit Documentation Feedback

21

22

23

24

25

30

29

27

26

28

31

ESP32-C6 TRM (Version 1.1)

GoBack

Chapter 10 Interrupt Matrix (INTMTX)

Interrupt Status Register

Name

Bit

Interrupt Source Mapping Register

Interrupt Source

Chapter

4

INTMTX\_CORE0\_HP\_APM\_M1\_INTR\_MAP\_REG

7

INTMTX\_CORE0\_LP\_APM0\_INTR\_MAP\_REG

8

INTMTX\_CORE0\_MSPI\_INTR\_MAP\_REG

17

INTMTX\_CORE0\_RMT\_INTR\_MAP\_REG

15

INTMTX\_CORE0\_TWAI1\_INTR\_MAP\_REG

14

INTMTX\_CORE0\_TWAI0\_INTR\_MAP\_REG

INTMTX\_CORE0\_INT\_STATUS\_1\_REG

16

INTMTX\_CORE0\_USB\_INTR\_MAP\_REG

13

INTMTX\_CORE0\_LEDC\_INTR\_MAP\_REG

12

INTMTX\_CORE0\_UART1\_INTR\_MAP\_REG

11

INTMTX\_CORE0\_UART0\_INTR\_MAP\_REG

1

INTMTX\_CORE0\_HP\_PERI\_TIMEOUT\_INTR\_MAP\_REG

10

INTMTX\_CORE0\_UHCI0\_INTR\_MAP\_REG

19

INTMTX\_CORE0\_TG0\_T0\_INTR\_MAP\_REG

18

INTMTX\_CORE0\_I2C\_EXT0\_INTR\_MAP\_REG

9

INTMTX\_CORE0\_I2S\_INTR\_MAP\_REG

5

INTMTX\_CORE0\_HP\_APM\_M2\_INTR\_MAP\_REG

6

INTMTX\_CORE0\_HP\_APM\_M3\_INTR\_MAP\_REG

0

30

INTMTX\_CORE0\_PCNT\_INTR\_MAP\_REG

3

INTMTX\_CORE0\_HP\_APM\_M0\_INTR\_MAP\_REG

22

INTMTX\_CORE0\_TG1\_T0\_INTR\_MAP\_REG

26

INTMTX\_CORE0\_SYSTIMER\_TARGET1\_INTR\_MAP\_REG

20

29

INTMTX\_CORE0\_PWM\_INTR\_MAP\_REG

21

INTMTX\_CORE0\_TG0\_WDT\_INTR\_MAP\_REG

25

INTMTX\_CORE0\_SYSTIMER\_TARGET0\_INTR\_MAP\_REG

27

INTMTX\_CORE0\_SYSTIMER\_TARGET2\_INTR\_MAP\_REG

24

INTMTX\_CORE0\_TG1\_WDT\_INTR\_MAP\_REG

28

INTMTX\_CORE0\_APB\_ADC\_INTR\_MAP\_REG

2

23

31

INTMTX\_CORE0\_PARL\_IO\_INTR\_MAP\_REG

|          |                                                                                                                                                                                                                                                                                                                                                                                                          |                                                                                                                   |                                                                                                                                         | reserved                                                                             |
|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------|
|          |                                                                                                                                                                                                                                                                                                                                                                                                          | reserved                                                                                                          |                                                                                                                                         | HP_PERI_TIMEOUT_INTR  HP_APM_M0_INTR  HP_APM_M1_INTR  HP_APM_M2_INTR  HP_APM_M3_INTR |
|          |                                                                                                                                                                                                                                                                                                                                                                                                          | reserved                                                                                                          |                                                                                                                                         | HP_PERI_TIMEOUT_INTR  HP_APM_M0_INTR  HP_APM_M1_INTR  HP_APM_M2_INTR  HP_APM_M3_INTR |
|          | TWAI0_INTR                                                                                                                                                                                                                                                                                                                                                                                               | RMT_INTR  reserved                                                                                                | SYSTIMER_TARGET2_INTR  APB_ADC_INTR                                                                                                     | HP_PERI_TIMEOUT_INTR  HP_APM_M0_INTR  HP_APM_M1_INTR  HP_APM_M2_INTR  HP_APM_M3_INTR |
|          |                                                                                                                                                                                                                                                                                                                                                                                                          | TG0_T0_INTR  TG0_WDT_INTR                                                                                         |                                                                                                                                         | HP_PERI_TIMEOUT_INTR  HP_APM_M0_INTR  HP_APM_M1_INTR  HP_APM_M2_INTR  HP_APM_M3_INTR |
| reserved | MSPI_INTR  I2S_INTR  LEDC_INTR                                                                                                                                                                                                                                                                                                                                                                           | reserved  TG1_T0_INTR                                                                                             | PWM_INTR  PCNT_INTR                                                                                                                     | HP_PERI_TIMEOUT_INTR  HP_APM_M0_INTR  HP_APM_M1_INTR  HP_APM_M2_INTR  HP_APM_M3_INTR |
|          | LP_APM0_INTR  UHCI0_INTR  UART0_INTR  UART1_INTR                                                                                                                                                                                                                                                                                                                                                         |                                                                                                                   | PARL_IO_INTR                                                                                                                            | HP_PERI_TIMEOUT_INTR  HP_APM_M0_INTR  HP_APM_M1_INTR  HP_APM_M2_INTR  HP_APM_M3_INTR |
|          | TWAI1_INTR                                                                                                                                                                                                                                                                                                                                                                                               | USB_SERIAL_JTAG_INTR  I2C_EXT0_INTR  TG1_WDT_INTR                                                                 |                                                                                                                                         | HP_PERI_TIMEOUT_INTR  HP_APM_M0_INTR  HP_APM_M1_INTR  HP_APM_M2_INTR  HP_APM_M3_INTR |
| n/a      |                                                                                                                                                                                                                                                                                                                                                                                                          | USB Serial/JTAG Controller (USB_SERIAL_JTAG)  n/a  n/a                                                            | System Timer (SYSTIMER)                                                                                                                 |                                                                                      |
|          |                                                                                                                                                                                                                                                                                                                                                                                                          | Timer Group (TIMG)                                                                                                |                                                                                                                                         |                                                                                      |
|          | Permission Control (PMS)  Permission Control (PMS)  Permission Control (PMS)  Permission Control (PMS)  Permission Control (PMS)  SPI Controller (SPI)  I2S Controller (I2S)  UART Controller (UART, LP_UART, UHCI)  UART Controller (UART, LP_UART, UHCI)  UART Controller (UART, LP_UART, UHCI)  LED PWM Controller (LEDC)  Two-wire Automotive Interface (TWAI)  Two-wire Automotive Interface (TWAI) | Remote Control Peripheral (RMT)  I2C Controller (I2C)  Timer Group (TIMG)  Timer Group (TIMG)  Timer Group (TIMG) | On-Chip Sensor and Analog Signal Processing  Motor Control PWM (MCPWM)  Pulse Count Controller (PCNT)  Parallel IO Controller (PARL_IO) |                                                                                      |

No.

35

32

33

34

36

Espressif Systems

37

38

39

40

41

42

43

44

45

49

48

47

46

53

52

51

50

54

382

Submit Documentation Feedback

55

56

57

58

59

62

61

63

60

ESP32-C6 TRM (Version 1.1)

GoBack

Chapter 10 Interrupt Matrix (INTMTX)

Interrupt Status Register

Name

INTMTX\_CORE0\_INT\_STATUS\_2\_REG

Bit

Interrupt Source Mapping Register

Interrupt Source

0

INTMTX\_CORE0\_SLC0\_INTR\_MAP\_REG

SLC0\_INTR

1

INTMTX\_CORE0\_SLC1\_INTR\_MAP\_REG

SLC1\_INTR

2

INTMTX\_CORE0\_DMA\_IN\_CH0\_INTR\_MAP\_REG

GDMA\_IN\_CH0\_INTR

3

INTMTX\_CORE0\_DMA\_IN\_CH1\_INTR\_MAP\_REG

GDMA\_IN\_CH1\_INTR

4

INTMTX\_CORE0\_DMA\_IN\_CH2\_INTR\_MAP\_REG

GDMA\_IN\_CH2\_INTR

5

INTMTX\_CORE0\_DMA\_OUT\_CH0\_INTR\_MAP\_REG

GDMA\_OUT\_CH0\_INTR

6

INTMTX\_CORE0\_DMA\_OUT\_CH1\_INTR\_MAP\_REG

GDMA\_OUT\_CH1\_INTR

7

INTMTX\_CORE0\_DMA\_OUT\_CH2\_INTR\_MAP\_REG

GDMA\_OUT\_CH2\_INTR

8

INTMTX\_CORE0\_GPSPI2\_INTR\_MAP\_REG

GPSPI2\_INTR

9

INTMTX\_CORE0\_AES\_INTR\_MAP\_REG

AES\_INTR

10

INTMTX\_CORE0\_SHA\_INTR\_MAP\_REG

SHA\_INTR

11

INTMTX\_CORE0\_RSA\_INTR\_MAP\_REG

RSA\_INTR

12

INTMTX\_CORE0\_ECC\_INTR\_MAP\_REG

ECC\_INTR

Chapter

Reset and Clock

Reset and Clock

GDMA Controller (GDMA)

GDMA Controller (GDMA)

GDMA Controller (GDMA)

No.

64

65

66

67

68

Espressif Systems

GDMA Controller (GDMA)

69

GDMA Controller (GDMA)

70

GDMA Controller (GDMA)

71

SPI Controller (SPI)

72

AES Accelerator (AES)

73

SHA Accelerator (SHA)

74

RSA Accelerator (RSA)

75

ECC Accelerator (ECC)

76

383

Submit Documentation Feedback

GoBack

ESP32-C6 TRM (Version 1.1)

## 10.3.2 CPU Interrupts

The ESP32-C6 implements its interrupt mechanism using an interrupt controller instead of RISC-V Privileged ISA specification. The CPU has 32 interrupts, numbered from 0 ~ 31. The interrupts numbered 0, 3, 4, and 7 are used by the CPU for core-local interrupts (CLINT), while the remaining 28 interrupts (numbered 1, 2, 5, 6, and 8 ~ 31) are available for use in the interrupt matrix.

Each CPU interrupt has the following properties:

- Priority levels from 1 (lowest) to 15 (highest).
- Configurable as level-triggered or edge-triggered.
- Lower-priority interrupts mask-able by setting interrupt threshold.

## Note:

For detailed information about the function and configuration of CPU interrupts, see Chapter 1 High-Performance CPU .

## 10.3.3 Assign Peripheral Interrupt Source to CPU Interrupt

In this section, the following terms are used to describe the operation of the interrupt matrix.

- Source\_X: stands for a peripheral interrupt source, wherein X means the number of this interrupt source in Table 10.3-1 .
- INTMTX\_CORE0\_SOURCE\_X\_INTR\_MAP\_REG: stands for an interrupt source mapping register for the peripheral interrupt source (Source\_X).
- Num\_P: the index of CPU interrupts which can be 1, 2, 5, 6, 8 ~ 31.
- Interrupt\_P: stands for the CPU interrupt numbered as Num\_P.

## 10.3.3.1 Assign One Peripheral Interrupt Source (Source\_X) to CPU

Setting the corresponding source mapping register INTMTX\_CORE0\_SOURCE\_X\_INTR\_MAP\_REG of Source\_X to Num\_P assigns this interrupt source to Interrupt\_P.

## 10.3.3.2 Assign Multiple Peripheral Interrupt Sources (Source\_X) to CPU

Setting the corresponding source mapping register INTMTX\_CORE0\_SOURCE\_X\_INTR\_MAP\_REG of each interrupt source to the same Num\_P assigns multiple sources to the same Interrupt\_P. Any of these sources can trigger CPU Interrupt\_P. When an interrupt signal is generated, CPU should check the interrupt status registers to figure out which peripheral generated the interrupt. For more information, see Chapter 1 High-Performance CPU .

## 10.3.3.3 Disable CPU Peripheral Interrupt Source (Source\_X)

Writing 0 to the INTMTX\_CORE0\_SOURCE\_X\_INTR\_MAP\_REG register disables the corresponding interrupt source.

## 10.3.4 Query Current Interrupt Status of Peripheral Interrupt Source

After enabling peripheral interrupt sources, users can query current interrupt status of a peripheral interrupt source by reading the bit value in INTMTX\_CORE0\_INT\_STATUS\_n\_REG (read only). For the mapping between INTMTX\_CORE0\_INT\_STATUS\_n\_REG and peripheral interrupt sources, please refer to Table 10.3-1 .

Chapter 10 Interrupt Matrix (INTMTX)

Access

Address

Description

R/W

0x0034

PMU\_INTR mapping register

R/W

0x0038

EFUSE\_INTR mapping register

Register Summary

10.4

.

System and Memory

5

## in Chapter

## 5.3-2 .

Access Types for Registers

| are explained in Section                                                                                                                                                                                                                                                                                                                                                                                                                                             |                                                                                                                                                                                                                                                                                                                                                                  |
|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Access                                                                                                                                                                                                                                                                                                                                                                                                                                                               | INTMTX_CORE0_CPU_INTR_FROM_CPU_2_MAP_REG                                                                                                                                                                                                                                                                                                                         |
|                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | INTMTX_CORE0_CPU_INTR_FROM_CPU_3_MAP_REG  INTMTX_CORE0_ASSIST_DEBUG_INTR_MAP_REG  INTMTX_CORE0_TRACE_INTR_MAP_REG  INTMTX_CORE0_CPU_PERI_TIMEOUT_INTR_MAP_REG  INTMTX_CORE0_GPIO_INTERRUPT_PRO_MAP_REG  INTMTX_CORE0_HP_PERI_TIMEOUT_INTR_MAP_REG  INTMTX_CORE0_HP_APM_M0_INTR_MAP_REG  INTMTX_CORE0_HP_APM_M1_INTR_MAP_REG  INTMTX_CORE0_HP_APM_M2_INTR_MAP_REG |
| Interrupt Matrix Register Summary  INTMTX_CORE0_LP_APM_M1_INTR_MAP_REG                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                                                                                  |
| The addresses in this section are relative to the interrupt matrix base address provided in Table  The abbreviations given in Column  Interrupt Source Mapping RegisterINTMTX_CORE0_PMU_INTR_MAP_REG  INTMTX_CORE0_EFUSE_INTR_MAP_REG  INTMTX_CORE0_LP_RTC_TIMER_INTR_MAP_REG  INTMTX_CORE0_LP_UART_INTR_MAP_REG  INTMTX_CORE0_LP_I2C_INTR_MAP_REG  INTMTX_CORE0_LP_WDT_INTR_MAP_REG  INTMTX_CORE0_LP_PERI_TIMEOUT_INTR_MAP_REG  INTMTX_CORE0_LP_APM_M0_INTR_MAP_REG |                                                                                                                                                                                                                                                                                                                                                                  |
| Name                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |                                                                                                                                                                                                                                                                                                                                                                  |
| 10.4.1                                                                                                                                                                                                                                                                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                                                                                  |

Espressif Systems

R/W

0x0048

R/W

0x004C

LP\_WDT\_INTR mapping register

LP\_PERI\_TIMEOUT\_INTR mapping register

386

Submit Documentation Feedback

R/W

0x0068

R/W

0x006C

R/W

0x0074

R/W

0x0078

R/W

0x0084

GoBack

R/W

R/W

R/W

0x008C

0x0090

0x0094

ASSIST\_DEBUG\_INTR mapping register

TRACE\_INTR mapping register

CPU\_PERI\_TIMEOUT\_INTR mapping register

GPIO\_INTERRUPT\_PRO mapping register

HP\_PERI\_TIMEOUT\_INTR mapping register

HP\_APM\_M0\_INTR mapping register

HP\_APM\_M1\_INTR mapping register

HP\_APM\_M2\_INTR mapping register

ESP32-C6 TRM (Version 1.1)

R/W

0x003C

LP\_RTC\_TIMER\_INTR mapping register

R/W

0x0040

LP\_UART\_INTR mapping register

R/W

0x0044

LP\_I2C\_INTR mapping register

R/W

0x0050

LP\_APM\_M0\_INTR mapping register

R/W

0x0054

LP\_APM\_M1\_INTR mapping register

R/W

0x0058

CPU\_INTR\_FROM\_CPU\_0 mapping register

R/W

0x005C

CPU\_INTR\_FROM\_CPU\_1 mapping register

R/W

0x0060

CPU\_INTR\_FROM\_CPU\_2 mapping register

R/W

0x0064

CPU\_INTR\_FROM\_CPU\_3 mapping register

Chapter 10 Interrupt Matrix (INTMTX)

Access

R/W

R/W

R/W

R/W

R/W

R/W

Address

Description

R/W

0x0098

HP\_APM\_M3\_INTR mapping register

Name

INTMTX\_CORE0\_HP\_APM\_M3\_INTR\_MAP\_REG

0x009C

0x00A0

0x00A4

0x00A8

0x00AC

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

R/W

0x00CC

R/W

0x00D4

R/W

0x00D8

R/W

0x00E0

R/W

0x00E4

SYSTIMER\_TARGET0\_INTR mapping register

R/W

0x00E8

SYSTIMER\_TARGET1\_INTR mapping register

R/W

0x00EC

SYSTIMER\_TARGET2\_INTR mapping register

R/W

0x00F0

R/W

0x00F4

R/W

0x00F8

R/W

0x00FC

R/W

0x0100

R/W

0x0104

GoBack

R/W

R/W

R/W

0x0108

0x010C

0x0110

| TG0_WDT_INTR mapping register                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | GDMA_IN_CH1_INTR mapping register  GDMA_IN_CH2_INTR mapping register                                                                                                                                                                                                                                                  |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| I2C_EXT0_INTR mapping register  TG0_T0_INTR mapping register  TG1_T0_INTR mapping register  TG1_WDT_INTR mapping register                                                                                                                                                                                                                                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                                                                       |
| LP_APM0_INTR mapping register  MSPI_INTR mapping register  I2S_INTR mapping register  UHCI0_INTR mapping register  UART0_INTR mapping register  UART1_INTR mapping register  LEDC_INTR mapping register  TWAI0_INTR mapping register  TWAI1_INTR mapping register  USB_SERIAL_JTAG_INTR mapping register  RMT_INTR mapping register                                                                                                                                                                                                               |                                                                                                                                                                                                                                                                                                                       |
|                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | APB_ADC_INTR mapping register  PWM_INTR mapping register  PCNT_INTR mapping register  PARL_IO_INTR mapping register  SLC0_INTR mapping register  SLC1_INTR mapping register  GDMA_IN_CH0_INTR mapping register                                                                                                        |
| INTMTX_CORE0_LP_APM0_INTR_MAP_REG  INTMTX_CORE0_MSPI_INTR_MAP_REG  INTMTX_CORE0_I2S_INTR_MAP_REG  INTMTX_CORE0_UHCI0_INTR_MAP_REG  INTMTX_CORE0_UART0_INTR_MAP_REG  INTMTX_CORE0_UART1_INTR_MAP_REG  INTMTX_CORE0_LEDC_INTR_MAP_REG  INTMTX_CORE0_TWAI0_INTR_MAP_REG  INTMTX_CORE0_TWAI1_INTR_MAP_REG  INTMTX_CORE0_USB_INTR_MAP_REG  INTMTX_CORE0_RMT_INTR_MAP_REG  INTMTX_CORE0_I2C_EXT0_INTR_MAP_REG  INTMTX_CORE0_TG0_T0_INTR_MAP_REG  INTMTX_CORE0_TG0_WDT_INTR_MAP_REG  INTMTX_CORE0_TG1_T0_INTR_MAP_REG  INTMTX_CORE0_TG1_WDT_INTR_MAP_REG | INTMTX_CORE0_APB_ADC_INTR_MAP_REG  INTMTX_CORE0_PWM_INTR_MAP_REG  INTMTX_CORE0_PCNT_INTR_MAP_REG  INTMTX_CORE0_PARL_IO_INTR_MAP_REG  INTMTX_CORE0_SLC0_INTR_MAP_REG  INTMTX_CORE0_SLC1_INTR_MAP_REG  INTMTX_CORE0_DMA_IN_CH0_INTR_MAP_REG  INTMTX_CORE0_DMA_IN_CH1_INTR_MAP_REG  INTMTX_CORE0_DMA_IN_CH2_INTR_MAP_REG |
|                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | INTMTX_CORE0_SYSTIMER_TARGET2_INTR_MAP_REG                                                                                                                                                                                                                                                                            |

Espressif Systems

387

Submit Documentation Feedback

ESP32-C6 TRM (Version 1.1)

Chapter 10 Interrupt Matrix (INTMTX)

Access

R/W

R/W

R/W

R/W

R/W

R/W

Address

Description

R/W

0x0114

GDMA\_OUT\_CH0\_INTR mapping register

Name

INTMTX\_CORE0\_DMA\_OUT\_CH0\_INTR\_MAP\_REG

INTMTX\_CORE0\_DMA\_OUT\_CH1\_INTR\_MAP\_REG

INTMTX\_CORE0\_DMA\_OUT\_CH2\_INTR\_MAP\_REG

RO

0x0134

31

~

RO

0x013C

76

~

| GDMA_OUT_CH1_INTR mapping register  GDMA_OUT_CH2_INTR mapping register  GPSPI2_INTR mapping register  Status register for interrupt sources 0 Status register for interrupt sources 32 Status register for interrupt sources 64   |                                                                                   |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------|
| Version control register                                                                                                                                                                                                          |                                                                                   |
| AES_INTR mapping register  SHA_INTR mapping register  RSA_INTR mapping register  ECC_INTR mapping register                                                                                                                        | .  Enable register for CPU interrupts  Pending status register for CPU interrupts |
|                                                                                                                                                                                                                                   | Access Types for Registers                                                        |
|                                                                                                                                                                                                                                   | Description                                                                       |

INTMTX\_CORE0\_GPSPI2\_INTR\_MAP\_REG

are explained in Section

Access

| Interrupt Status Register   |                                                            |
|-----------------------------|------------------------------------------------------------|
|                             | The abbreviations given in Column  Configuration Registers |
| Version Control Register    |                                                            |
|                             | Name                                                       |

Espressif Systems

INTMTX\_CORE0\_INTERRUPT\_REG\_DATE\_REG

388

Submit Documentation Feedback

INTPRI\_CORE0\_CPU\_INT\_ENABLE\_REG

R/W

0x0004

Type configuration register for CPU interrupts

INTPRI\_CORE0\_CPU\_INT\_TYPE\_REG

INTPRI\_CORE0\_CPU\_INT\_EIP\_STATUS\_REG

R/W

0x000C

Priority configuration register for CPU interrupt 0

INTPRI\_CORE0\_CPU\_INT\_PRI\_0\_REG

GoBack

R/W

R/W

0x0010

Priority configuration register for CPU interrupt 1

INTPRI\_CORE0\_CPU\_INT\_PRI\_1\_REG

0x0014

Priority configuration register for CPU interrupt 2

INTPRI\_CORE0\_CPU\_INT\_PRI\_2\_REG

ESP32-C6 TRM (Version 1.1)

INTMTX\_CORE0\_AES\_INTR\_MAP\_REG

INTMTX\_CORE0\_SHA\_INTR\_MAP\_REG

INTMTX\_CORE0\_RSA\_INTR\_MAP\_REG

INTMTX\_CORE0\_ECC\_INTR\_MAP\_REG

INTMTX\_CORE0\_INT\_STATUS\_0\_REG

INTMTX\_CORE0\_INT\_STATUS\_1\_REG

INTMTX\_CORE0\_INT\_STATUS\_2\_REG

0x0118

0x011C

0x0120

0x0124

0x0128

0x012C

R/W

0x0130

RO

0x0138

63

~

R/W

0x07FC

Interrupt Priority Register Summary

.

System and Memory

5

in Chapter

The addresses in this section are relative to the interrupt priority base address provided in Table

Access

Address

R/W

0x0000

RO

0x0008

Chapter 10 Interrupt Matrix (INTMTX)

Access

R/W

R/W

R/W

R/W

R/W

R/W

Address

Description

R/W

0x0018

Priority configuration register for CPU interrupt 3

0x001C

Priority configuration register for CPU interrupt 4

0x0020

Priority configuration register for CPU interrupt 5

0x0024

Priority configuration register for CPU interrupt 6

Name

INTPRI\_CORE0\_CPU\_INT\_PRI\_3\_REG

0x0028

Priority configuration register for CPU interrupt 7

0x002C

Priority configuration register for CPU interrupt 8

0x0030

Priority configuration register for CPU interrupt 9

R/W

0x0034

Priority configuration register for CPU interrupt 10

R/W

0x0038

Priority configuration register for CPU interrupt 11

R/W

0x003C

Priority configuration register for CPU interrupt 12

R/W

0x0040

Priority configuration register for CPU interrupt 13

R/W

0x0044

Priority configuration register for CPU interrupt 14

R/W

0x0048

Priority configuration register for CPU interrupt 15

R/W

0x004C

R/W

0x0050

Priority configuration register for CPU interrupt 16

R/W

0x0054

Priority configuration register for CPU interrupt 18

R/W

0x0058

Priority configuration register for CPU interrupt 19

R/W

0x005C

Priority configuration register for CPU interrupt 20

R/W

0x0060

Priority configuration register for CPU interrupt 21

R/W

0x0064

Priority configuration register for CPU interrupt 22

R/W

0x0068

Priority configuration register for CPU interrupt 23

R/W

0x006C

R/W

0x0070

R/W

0x0074

R/W

0x0078

R/W

0x007C

GoBack

R/W

R/W

R/W

0x0080

0x0084

0x0088

Priority configuration register for CPU interrupt 24

| INTPRI_CORE0_CPU_INT_PRI_5_REG  INTPRI_CORE0_CPU_INT_PRI_6_REG  INTPRI_CORE0_CPU_INT_PRI_7_REG  INTPRI_CORE0_CPU_INT_PRI_8_REG  INTPRI_CORE0_CPU_INT_PRI_9_REG  INTPRI_CORE0_CPU_INT_PRI_10_REG  INTPRI_CORE0_CPU_INT_PRI_11_REG  INTPRI_CORE0_CPU_INT_PRI_12_REG  INTPRI_CORE0_CPU_INT_PRI_13_REG  INTPRI_CORE0_CPU_INT_PRI_14_REG  INTPRI_CORE0_CPU_INT_PRI_15_REG   | INTPRI_CORE0_CPU_INT_PRI_23_REG  INTPRI_CORE0_CPU_INT_PRI_24_REG  INTPRI_CORE0_CPU_INT_PRI_25_REG  INTPRI_CORE0_CPU_INT_PRI_26_REG  INTPRI_CORE0_CPU_INT_PRI_27_REG  INTPRI_CORE0_CPU_INT_PRI_28_REG  INTPRI_CORE0_CPU_INT_PRI_29_REG  INTPRI_CORE0_CPU_INT_PRI_30_REG  INTPRI_CORE0_CPU_INT_PRI_31_REG   |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|                                                                                                                                                                                                                                                                                                                                                                        | INTPRI_CORE0_CPU_INT_PRI_22_REG                                                                                                                                                                                                                                                                           |
| INTPRI_CORE0_CPU_INT_PRI_4_REG                                                                                                                                                                                                                                                                                                                                         |                                                                                                                                                                                                                                                                                                           |

Espressif Systems

Priority configuration register for CPU interrupt 17

389

Submit Documentation Feedback

Priority configuration register for CPU interrupt 25

Priority configuration register for CPU interrupt 26

Priority configuration register for CPU interrupt 27

Priority configuration register for CPU interrupt 28

Priority configuration register for CPU interrupt 29

Priority configuration register for CPU interrupt 30

Priority configuration register for CPU interrupt 31

ESP32-C6 TRM (Version 1.1)

Chapter 10 Interrupt Matrix (INTMTX)

Access

R/W

R/W

R/W

R/W

R/W

Address

Description

R/W

0x008C

Threshold configuration register for CPU interrupts

0x00A8

0x0090

CPU\_INTR\_FROM\_CPU\_0 mapping register

0x0094

0x0098

CPU\_INTR\_FROM\_CPU\_2 mapping register

0x009C

CPU\_INTR\_FROM\_CPU\_3 mapping register

R/W

0x00A0

| CPU interrupt clear register  CPU_INTR_FROM_CPU_1 mapping register  Version control register   |
|------------------------------------------------------------------------------------------------|

Name

INTPRI\_CORE0\_CPU\_INT\_THRESH\_REG

INTPRI\_CORE0\_CPU\_INT\_CLEAR\_REG

Interrupt Registers

INTPRI\_CPU\_INTR\_FROM\_CPU\_0\_REG

Espressif Systems

INTPRI\_CPU\_INTR\_FROM\_CPU\_1\_REG

INTPRI\_CPU\_INTR\_FROM\_CPU\_2\_REG

INTPRI\_CPU\_INTR\_FROM\_CPU\_3\_REG

Version Registers INTPRI\_DATE\_REG

390

Submit Documentation Feedback

GoBack

ESP32-C6 TRM (Version 1.1)

## 10.5 Registers

## 10.5.1 Interrupt Matrix Registers

The addresses in this section are relative to the interrupt matrix base address provided in Table 5.3-2 in Chapter 5 System and Memory .

```
Register 10.1. INTMTX_CORE0_PMU_INTR_MAP_REG (0x0034) Register 10.2. INTMTX_CORE0_EFUSE_INTR_MAP_REG (0x0038) Register 10.3. INTMTX_CORE0_LP_RTC_TIMER_INTR_MAP_REG (0x003C) Register 10.4. INTMTX_CORE0_LP_UART_INTR_MAP_REG (0x0040) Register 10.5. INTMTX_CORE0_LP_I2C_INTR_MAP_REG (0x0044) Register 10.6. INTMTX_CORE0_LP_WDT_INTR_MAP_REG (0x0048) Register 10.7. INTMTX_CORE0_LP_PERI_TIMEOUT_INTR_MAP_REG (0x004C) Register 10.8. INTMTX_CORE0_LP_APM_M0_INTR_MAP_REG (0x0050) Register 10.9. INTMTX_CORE0_LP_APM_M1_INTR_MAP_REG (0x0054) Register 10.10. INTMTX_CORE0_CPU_INTR_FROM_CPU_0_MAP_REG (0x0058) Register 10.11. INTMTX_CORE0_CPU_INTR_FROM_CPU_1_MAP_REG (0x005C) Register 10.12. INTMTX_CORE0_CPU_INTR_FROM_CPU_2_MAP_REG (0x0060) Register 10.13. INTMTX_CORE0_CPU_INTR_FROM_CPU_3_MAP_REG (0x0064) Register 10.14. INTMTX_CORE0_ASSIST_DEBUG_INTR_MAP_REG (0x0068) Register 10.15. INTMTX_CORE0_TRACE_INTR_MAP_REG (0x006C) Register 10.16. INTMTX_CORE0_CPU_PERI_TIMEOUT_INTR_MAP_REG (0x0074) Register 10.17. INTMTX_CORE0_GPIO_INTERRUPT_PRO_MAP_REG (0x0078) Register 10.18. INTMTX_CORE0_HP_PERI_TIMEOUT_INTR_MAP_REG (0x0084) Register 10.19. INTMTX_CORE0_HP_APM_M0_INTR_MAP_REG (0x008C) Register 10.20. INTMTX_CORE0_HP_APM_M1_INTR_MAP_REG (0x0090) Register 10.21. INTMTX_CORE0_HP_APM_M2_INTR_MAP_REG (0x0094) Register 10.22. INTMTX_CORE0_HP_APM_M3_INTR_MAP_REG (0x0098) Register 10.23. INTMTX_CORE0_LP_APM0_INTR_MAP_REG (0x009C) Register 10.24. INTMTX_CORE0_MSPI_INTR_MAP_REG (0x00A0) Register 10.25. INTMTX_CORE0_I2S_INTR_MAP_REG (0x00A4) Register 10.26. INTMTX_CORE0_UHCI0_INTR_MAP_REG (0x00A8) Register 10.27. INTMTX_CORE0_UART0_INTR_MAP_REG (0x00AC) Register 10.28. INTMTX_CORE0_UART1_INTR_MAP_REG (0x00B0) Register 10.29. INTMTX_CORE0_LEDC_INTR_MAP_REG (0x00B4) Register 10.30. INTMTX_CORE0_TWAI0_INTR_MAP_REG (0x00B8)
```

Register 10.31. INTMTX\_CORE0\_TWAI1\_INTR\_MAP\_REG (0x00BC) Register 10.32. INTMTX\_CORE0\_USB\_INTR\_MAP\_REG (0x00C0) Register 10.33. INTMTX\_CORE0\_RMT\_INTR\_MAP\_REG (0x00C4) Register 10.34. INTMTX\_CORE0\_I2C\_EXT0\_INTR\_MAP\_REG (0x00C8) Register 10.35. INTMTX\_CORE0\_TG0\_T0\_INTR\_MAP\_REG (0x00CC) Register 10.36. INTMTX\_CORE0\_TG0\_WDT\_INTR\_MAP\_REG (0x00D4) Register 10.37. INTMTX\_CORE0\_TG1\_T0\_INTR\_MAP\_REG (0x00D8) Register 10.38. INTMTX\_CORE0\_TG1\_WDT\_INTR\_MAP\_REG (0x00E0) Register 10.39. INTMTX\_CORE0\_SYSTIMER\_TARGET0\_INTR\_MAP\_REG (0x00E4) Register 10.40. INTMTX\_CORE0\_SYSTIMER\_TARGET1\_INTR\_MAP\_REG (0x00E8) Register 10.41. INTMTX\_CORE0\_SYSTIMER\_TARGET2\_INTR\_MAP\_REG (0x00EC) Register 10.42. INTMTX\_CORE0\_APB\_ADC\_INTR\_MAP\_REG (0x00F0) Register 10.43. INTMTX\_CORE0\_PWM\_INTR\_MAP\_REG (0x00F4) Register 10.44. INTMTX\_CORE0\_PCNT\_INTR\_MAP\_REG (0x00F8) Register 10.45. INTMTX\_CORE0\_PARL\_IO\_INTR\_MAP\_REG (0x00FC) Register 10.46. INTMTX\_CORE0\_SLC0\_INTR\_MAP\_REG (0x0100) Register 10.47. INTMTX\_CORE0\_SLC1\_INTR\_MAP\_REG (0x0104) Register 10.48. INTMTX\_CORE0\_DMA\_IN\_CH0\_INTR\_MAP\_REG (0x0108) Register 10.49. INTMTX\_CORE0\_DMA\_IN\_CH1\_INTR\_MAP\_REG (0x010C) Register 10.50. INTMTX\_CORE0\_DMA\_IN\_CH2\_INTR\_MAP\_REG (0x0110) Register 10.51. INTMTX\_CORE0\_DMA\_OUT\_CH0\_INTR\_MAP\_REG (0x0114) Register 10.52. INTMTX\_CORE0\_DMA\_OUT\_CH1\_INTR\_MAP\_REG (0x0118) Register 10.53. INTMTX\_CORE0\_DMA\_OUT\_CH2\_INTR\_MAP\_REG (0x011C) Register 10.54. INTMTX\_CORE0\_GPSPI2\_INTR\_MAP\_REG (0x0120) Register 10.55. INTMTX\_CORE0\_AES\_INTR\_MAP\_REG (0x0124)

Register 10.56. INTMTX\_CORE0\_SHA\_INTR\_MAP\_REG (0x0128)

Register 10.57. INTMTX\_CORE0\_RSA\_INTR\_MAP\_REG (0x012C)

Register 10.58. INTMTX\_CORE0\_ECC\_INTR\_MAP\_REG (0x0130)

Register 10.59. INTMTX\_CORE0\_SOURCE\_X\_MAP\_REG (0x0034 - 0x0130)

INTMTX\_CORE0\_SOURCE\_X\_MAP Map the interrupt source (SOURCE\_X) into one CPU interrupt. For the information of SOURCE\_X, see Table 10.3-1. (R/W)

![Image](images/10_Chapter_10_img002_04826d90.png)

## Register 10.60. INTMTX\_CORE0\_INT\_STATUS\_0\_REG (0x0134)

![Image](images/10_Chapter_10_img003_c4b43c94.png)

INTMTX\_CORE0\_INT\_STATUS\_0 Represents the status of the interrupt sources numbered from 0

- ~ 31. Each bit corresponds to one interrupt source.
- 0: The corresponding interrupt source triggered an interrupt
- 1: No interrupt triggered

(RO)

## Register 10.61. INTMTX\_CORE0\_INT\_STATUS\_1\_REG (0x0138)

![Image](images/10_Chapter_10_img004_4d1a6d65.png)

INTMTX\_CORE0\_INT\_STATUS\_1

Represents the status of the interrupt sources numbered from 32

- ~ 63. Each bit corresponds to one interrupt source.
- 0: The corresponding interrupt source triggered an interrupt
- 1: No interrupt triggered

(RO)

Register 10.62. INTMTX\_CORE0\_INT\_STATUS\_2\_REG (0x013C)

![Image](images/10_Chapter_10_img005_575b8e48.png)

INTMTX\_CORE0\_INT\_STATUS\_2 Represents the status of the interrupt sources numbered from 64 ~ 76. Bit 0 ~ 12 each corresponds to one interrupt source. Other bits are invalid.

- 0: The corresponding interrupt source triggered an interrupt
- 1: No interrupt triggered

(RO)

Register 10.63. INTMTX\_CORE0\_INTERRUPT\_REG\_DATE\_REG (0x07FC)

![Image](images/10_Chapter_10_img006_71b7d806.png)

INTMTX\_CORE0\_INTERRUPT\_REG\_DATE Version control register. (R/W)

## 10.5.2 Interrupt Priority Registers

The addresses in this section are relative to the interrupt priority base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 10.64. INTPRI\_CORE0\_CPU\_INT\_ENABLE\_REG (0x0000)

![Image](images/10_Chapter_10_img007_a80e598f.png)

INTPRI\_CORE0\_CPU\_INT\_ENABLE Configures whether to enable the corresponding CPU interrupt.

- 0: Not enable
- 1: Enable

For more information about how to use this register, see Chapter 1 High-Performance CPU . (R/W)

Register 10.65. INTPRI\_CORE0\_CPU\_INT\_TYPE\_REG (0x0004)

![Image](images/10_Chapter_10_img008_aa6710a6.png)

INTPRI\_CORE0\_CPU\_INT\_TYPE Configures CPU interrupt type.

- 0: Level-triggered
- 1: Edge-triggered

For more information about how to use this register, see Chapter 1 High-Performance CPU . (R/W)

![Image](images/10_Chapter_10_img009_3d5712b5.png)

## Register 10.69. INTPRI\_CORE0\_CPU\_INT\_CLEAR\_REG (0x00A8)

![Image](images/10_Chapter_10_img010_52866540.png)

INTPRI\_CORE0\_CPU\_INT\_CLEAR Configures whether to clear the corresponding CPU interrupt.

0: No effect

1: Clear

For more information about how to use this register, see Chapter 1 High-Performance CPU . (R/W)

Register 10.70. INTPRI\_CPU\_INTR\_FROM\_CPU\_n\_REG (n: 0-3) (0x0090+0x4*n)

![Image](images/10_Chapter_10_img011_42cef5fe.png)

INTPRI\_CPU\_INTR\_FROM\_CPU\_n CPU\_INTR\_FROM\_CPU\_n mapping register. (R/W)

## Register 10.71. INTPRI\_DATE\_REG (0x00A0)

![Image](images/10_Chapter_10_img012_3976bd97.png)

INTPRI\_DATE Version control register. (R/W)
