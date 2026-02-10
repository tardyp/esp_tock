---
chapter: 6
title: "Chapter 6"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 6

## Reset and Clock

## 6.1 Reset

## 6.1.1 Overview

ESP32-C3 provides four types of reset that occur at different levels, namely CPU Reset, Core Reset, System Reset, and Chip Reset. All reset types mentioned above (except Chip Reset) maintain the data stored in internal memory. Figure 6.1-1 shows the scope of affected subsystems by each type of reset.

## 6.1.2 Architectural Overview

Figure 6.1-1. Reset Types

![Image](images/06_Chapter_6_img001_baf1127b.png)

## 6.1.3 Features

- Support four reset levels:
- – CPU Reset: Only resets CPU core. Once such reset is released, the instructions from the CPU reset vector will be executed.

## Note:

If CPU is reset, PMS registers will be reset, too.

## 6.1.4 Functional Description

CPU will be reset immediately when any of the reset above occurs. Users can get reset source codes by reading register RTC\_CNTL\_RESET\_CAUSE\_PROCPU after the reset is released.

Table 6.1-1 lists possible reset sources and the types of reset they trigger.

- – Core Reset: Resets the whole digital system except RTC, including CPU, peripherals, Wi-Fi, Bluetooth ® LE, and digital GPIOs.
- – System Reset: Resets the whole digital system, including RTC.
- – Chip Reset: Resets the whole chip.
- Support software reset and hardware reset:
- – Software Reset: the CPU can trigger a software reset by configuring the corresponding registers, see Chapter 9 Low-power Management .
- – Hardware Reset: Hardware reset is directly triggered by the circuit.

Table 6.1-1. Reset Sources

| Code   | Source                 | Reset Type                 | Comments                                                                                                                                                    |
|--------|------------------------|----------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x01   | Chip reset 1           | Chip Reset                 | -                                                                                                                                                           |
| 0x0F   | Brown-out system reset | Chip Reset or System Reset | Triggered by brown-out detector 2                                                                                                                           |
| 0x10   | RWDT system reset      | System Reset               | See Chapter 12 Watchdog Timers (WDT)                                                                                                                        |
| 0x12   | Super Watchdog reset   | System Reset               | See Chapter 12 Watchdog Timers (WDT)                                                                                                                        |
| 0x13   | CLK GLITCH reset       | System Reset               | See Chapter 25 Clock Glitch Detection                                                                                                                       |
| 0x03   | Software system reset  | Core Reset                 | Triggered by configuring RTC_CNTL_SW_SYS_RST                                                                                                                |
| 0x05   | Deep-sleep reset       | Core Reset                 | See Chapter 9 Low-power Management                                                                                                                          |
| 0x07   | MWDT0 core reset       | Core Reset                 | See Chapter 12 Watchdog Timers (WDT)                                                                                                                        |
| 0x08   | MWDT1 core reset       | Core Reset                 | See Chapter 12 Watchdog Timers (WDT)                                                                                                                        |
| 0x09   | RWDT core reset        | Core Reset                 | See Chapter 12 Watchdog Timers (WDT)                                                                                                                        |
| 0x14   | eFuse reset            | Core Reset                 | Triggered by eFuse CRC error                                                                                                                                |
| 0x15   | USB (UART) reset       | Core Reset                 | Triggered when external USB host sends a specific com mand to the Serial interface of USB-Serial-JTAG. See 30 USB Serial/JTAG Controller (USB_SERIAL_JTAG) |
| 0x16   | USB (JTAG) reset       | Core Reset                 | Triggered when external USB host sends a specific com mand to the JTAG interface of USB-Serial-JTAG. See 30 USB Serial/JTAG Controller (USB_SERIAL_JTAG)   |
| 0x17   | Power glitch reset     | Core Reset                 | Triggered by power glitch                                                                                                                                   |
| 0x0B   | MWDT0 CPU reset        | CPU Reset                  | See Chapter 12 Watchdog Timers (WDT)                                                                                                                        |
| 0x0C   | Software CPU reset     | CPU Reset                  | Triggered by configuring RTC_CNTL_SW_PROCPU_RST                                                                                                             |
| 0x0D   | RWDT CPU reset         | CPU Reset                  | See Chapter 12 Watchdog Timers (WDT)                                                                                                                        |
| 0x11   | MWDT1 CPU reset        | CPU Reset                  | See Chapter 12 Watchdog Timers (WDT)                                                                                                                        |

- Triggered by chip power-on.
- Triggered by brown-out detector.

2 Once brown-out status is detected, the detector will trigger System Reset or Chip Reset, depending on register configuration. See Chapter 9 Low-power Management .

## 6.2 Clock

## 6.2.1 Overview

ESP32-C3 clocks are mainly sourced from oscillator (OSC), RC, and PLL circuit, and then processed by the dividers or selectors, which allows most functional modules to select their working clock according to their power consumption and performance requirements. Figure 6.2-1 shows the system clock structure.

## 6.2.2 Architectural Overview

Figure 6.2-1. System Clock

![Image](images/06_Chapter_6_img002_6d1db4a8.png)

## 6.2.3 Features

ESP32-C3 clocks can be classified in two types depending on their frequencies:

- High speed clocks for devices working at a higher frequency, such as CPU and digital peripherals
- – PLL\_CLK (320 MHz or 480 MHz): internal PLL clock
- – XTAL\_CLK (40 MHz): external crystal clock
- Slow speed clocks for low-power devices, such as RTC module and low-power peripherals
- – XTAL32K\_CLK (32 kHz): external crystal clock
- – RC\_FAST\_CLK (17.5 MHz by default): internal fast RC oscillator with adjustable frequency
- – RC\_FAST\_DIV\_CLK: internal fast RC oscillator derived from RC\_FAST\_CLK divided by 256
- – RC\_SLOW\_CLK (136 kHz by default): internal low RC oscillator with adjustable frequency

## 6.2.4 Functional Description

## 6.2.4.1 CPU Clock

As Figure 6.2-1 shows, CPU\_CLK is the master clock for CPU and it can be as high as 160 MHz when CPU works in high performance mode. Alternatively, CPU can run at lower frequencies, such as at 2 MHz, to lower power consumption. Users can set PLL\_CLK, RC\_FAST\_CLK or XTAL\_CLK as CPU\_CLK clock source by configuring register SYSTEM\_SOC\_CLK\_SEL, see Table 6.2-1 and Table 6.2-2. By default, the CPU clock is sourced from XTAL\_CLK with a divider of 2, i.e. the CPU clock is 20 MHz.

Table 6.2-1. CPU Clock Source

|   SYSTEM_SOC_CLK_SEL Value | CPU Clock Source   |
|----------------------------|--------------------|
|                          0 | XTAL_CLK           |
|                          1 | PLL_CLK            |
|                          2 | RC_FAST_CLK        |

Table 6.2-2. CPU Clock Frequency

| CPU Clock Source   |   SEL_0* | SEL_1*   | SEL_2*   | CPU Clock Frequency                                                                                    |
|--------------------|----------|----------|----------|--------------------------------------------------------------------------------------------------------|
| XTAL_CLK           |        0 | -        | -        | CPU_CLK = XTAL_CLK/(SYSTEM_PRE_DIV_CNT + 1) SYSTEM_PRE_DIV_CNT ranges from 0  ~  1023. Default is 1    |
| PLL_CLK (480 MHz)  |        1 | 1        | 0        | CPU_CLK = PLL_CLK/6 CPU_CLK frequency is 80 MHz                                                        |
| PLL_CLK (480 MHz)  |        1 | 1        | 1        | CPU_CLK = PLL_CLK/3 CPU_CLK frequency is 160 MHz                                                       |
| PLL_CLK (320 MHz)  |        1 | 0        | 0        | CPU_CLK = PLL_CLK/4 CPU_CLK frequency is 80 MHz                                                        |
| PLL_CLK (320 MHz)  |        1 | 0        | 1        | CPU_CLK = PLL_CLK/2 CPU_CLK frequency is 160 MHz                                                       |
| RC_FAST_CLK        |        2 | -        | -        | CPU_CLK = RC_FAST_CLK/(SYSTEM_PRE_DIV_CNT + 1) SYSTEM_PRE_DIV_CNT ranges from 0  ~  1023. Default is 1 |

## 6.2.4.2 Peripheral Clock

Peripheral clocks include APB\_CLK, CRYPTO\_CLK, PLL\_F160M\_CLK, LEDC\_SCLK, XTAL\_CLK, and RC\_FAST\_CLK. Table 6.2-3 shows which clock can be used by each peripheral.

Chapter 6 Reset and Clock

PLL\_D2\_CLK

Y

LEDC\_CLK

CRYPTO\_CLK

RC\_FAST\_CLK

Y

|                  | Y  Y   | Y   | Y   |
|------------------|--------|-----|-----|
| RTC_FAST_CLK     |        |     |     |
| PLL_F160M_CLK  Y |        |     | Y   |
| APB_CLK          | Y      |     | Y   |
| Y                | Y      | Y   | Y   |

XTAL\_CLK

Y

Y

Peripheral

TIMG

I2S

UHCI

Espressif Systems

Y

UART

Y

RMT

Y

I2C

Y

SPI

Y

eFuse Con-

Y

Temperature Sensor troller

SARADC

USB

CRYPTO

TWAI Controller

Y

LEDC

Y

SYS\_TIMER

196

Submit Documentation Feedback

Table 6.2-3. Peripheral Clocks

Y

GoBack

ESP32-C3 TRM (Version 1.3)

## APB\_CLK

The frequency of APB\_CLK is determined by the clock source of CPU\_CLK as shown in Table 6.2-4 .

Table 6.2-4. APB\_CLK Clock Frequency

| CPU_CLK Source   | APB_CLK Frequency   |
|------------------|---------------------|
| PLL_CLK          | 80 MHz              |
| XTAL_CLK         | CPU_CLK             |
| RC_FAST_CLK      | CPU_CLK             |

## CRYPTO\_CLK

The frequency of CRYPTO\_CLK is determined by the CPU\_CLK source, as shown in Table 6.2-5 .

Table 6.2-5. CRYPTO\_CLK Frequency

| CPU_CLK Source   | CRYPTO_CLK Frequency   |
|------------------|------------------------|
| PLL_CLK          | 160 MHz                |
| XTAL_CLK         | CPU_CLK                |
| RC_FAST_CLK      | CPU_CLK                |

## PLL\_F160M\_CLK

PLL\_F160M\_CLK is divided from PLL\_CLK according to current PLL frequency.

## LEDC\_SCLK

LEDC module uses RC\_FAST\_CLK as clock source when APB\_CLK is disabled. In other words, when the system is in low-power mode, most peripherals will be halted (as APB\_CLK is turned off), but LEDC can still work normally via RC\_FAST\_CLK.

## 6.2.4.3 Wi-Fi and Bluetooth LE Clock

Wi-Fi and Bluetooth LE can only work when CPU\_CLK uses PLL\_CLK as its clock source. Suspending PLL\_CLK requires that Wi-Fi and Bluetooth LE have entered low-power mode first.

LOW\_POWER\_CLK uses XTAL32K\_CLK, XTAL\_CLK, RC\_FAST\_CLK or RTC\_SLOW\_CLK (the low clock selected by RTC) as its clock source for Wi-Fi and Bluetooth LE in low-power mode.

## 6.2.4.4 RTC Clock

The clock sources for RTC\_SLOW\_CLK and RTC\_FAST\_CLK are low-frequency clocks. RTC module can operate when most other clocks are stopped. RTC\_SLOW\_CLK derived from RC\_SLOW\_CLK, XTAL32K\_CLK or RC\_FAST\_DIV\_CLK is used to clock Power Management module. RTC\_FAST\_CLK is used to clock On-chip Sensor module. It can be sourced from a divided XTAL\_CLK or from a divided RC\_FAST\_CLK.
