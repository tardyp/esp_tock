---
chapter: 8
title: "Chapter 8"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 8

## Reset and Clock

## 8.1 Reset

## 8.1.1 Overview

ESP32-C6 provides four types of reset that occur at different levels, namely CPU Reset, Core Reset, System Reset, and Chip Reset. All reset types mentioned above (except Chip Reset) preserve the data stored in internal memory. Figure 8.1-1 shows the scopes of affected subsystems by each type of reset.

## 8.1.2 Architectural Overview

Figure 8.1-1. Reset Types

![Image](images/08_Chapter_8_img001_a8270e73.png)

ESP32-C6's Digital System consists of High Performance System (HP system) that includes Digital Core and Wireless Circuit, and Low Power System (LP system). See Figure 8.1-1 for details.

## 8.1.3 Features

- Four reset types:

- – CPU Reset: resets CPU core. Once such reset is released, the instructions from the CPU reset vector will be executed.
- – Core Reset: resets the whole digital system except LP system, including CPU, peripherals, Wi-Fi, Bluetooth ® LE, and digital GPIOs.
- – System Reset: resets the whole digital system, including LP system.
- – Chip Reset: resets the whole chip.
- Software reset and hardware reset:
- – Software Reset: triggered via software by configuring the corresponding registers of CPU, see Chapter 12 Low-Power Management .
- – Hardware Reset: triggered directly by the hardware.

## 8.1.4 Functional Description

CPU will be reset immediately when any type of reset above occurs. Users can retrieve reset source codes by reading RTC\_CLKRST\_RESET\_CAUSE after the reset is released. Table 8.1-1 lists possible reset sources and the types of reset they trigger.

Table 8.1-1. Reset Source

| Code   | Source                   | Reset Type                 | Note                                                                                                                                                                               |
|--------|--------------------------|----------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0x01   | Chip reset 1             | Chip Reset                 | —                                                                                                                                                                                  |
| 0x0F   | Brown-out system re set | Chip Reset or System Reset | Triggered by brown-out detector 2                                                                                                                                                  |
| 0x10   | RWDT system reset        | System Re set             | See Chapter 15 Watchdog Timers (WDT)                                                                                                                                               |
| 0x12   | Super Watchdog reset     | System Re set             | See Chapter 15 Watchdog Timers (WDT)                                                                                                                                               |
| 0x03   | Software system reset    | Core Reset                 | Triggered by configuring LP_AON_HPSYS_SW_RESET                                                                                                                                     |
| 0x05   | Deep-sleep reset         | Core Reset                 | See Chapter 12 Low-Power Management                                                                                                                                                |
| 0x06   | SDIO core reset          | Core Reset                 | Reserved                                                                                                                                                                           |
| 0x07   | MWDT0 core reset         | Core Reset                 | See Chapter 15 Watchdog Timers (WDT)                                                                                                                                               |
| 0x08   | MWDT1 core reset         | Core Reset                 | See Chapter 15 Watchdog Timers (WDT)                                                                                                                                               |
| 0x09   | RWDT core reset          | Core Reset                 | See Chapter 15 Watchdog Timers (WDT)                                                                                                                                               |
| 0x14   | eFuse reset              | Core Reset                 | Triggered by eFuse CRC error                                                                                                                                                       |
| 0x15   | USB (UART) reset         | Core Reset                 | Triggered when external USB host sends a specific com mand to the Serial interface of USB Serial/JTAG Con troller. See Chapter  32  USB Serial/JTAG Controller (USB_SERIAL_JTAG) |
| 0x16   | USB (JTAG) reset         | Core Reset                 | Triggered when external USB host sends a specific com mand to the JTAG interface of USB Serial/JTAG Con troller. See Chapter  32  USB Serial/JTAG Controller (USB_SERIAL_JTAG)   |
| 0x0B   | MWDT0 CPU reset          | CPU Reset                  | See Chapter 15 Watchdog Timers (WDT)                                                                                                                                               |
| 0x0C   | Software CPU reset       | CPU Reset                  | Triggered by configuring LP_AON_CPU_CORE0_SW_RESET                                                                                                                                 |
| 0x0D   | RWDT CPU reset           | CPU Reset                  | See Chapter 15 Watchdog Timers (WDT)                                                                                                                                               |
| 0x11   | MWDT1 CPU reset          | CPU Reset                  | See Chapter 15 Watchdog Timers (WDT)                                                                                                                                               |
| 0x18   | JTAG CPU reset           | CPU Reset                  | Triggered when a ”JDB Resetting CPU” instruction is received                                                                                                                       |

- Triggered by chip power-on.
- Triggered by brown-out detector.

2 Once brown-out status is detected, the detector will trigger System Reset or Chip Reset, depending on register configuration. See Chapter 12 Low-Power Management .

## 8.1.5 Peripheral Reset

Peripherals can be reset individually by configuring corresponding registers, or globally by Core Reset, System Reset, or Chip Reset. The reset registers of ESP32-C6 peripherals are merged to Power/Clock/Reset (PCR) module. See Section 8.4 Register Summary for detailed information.

## 8.2 Clock

## 8.2.1 Overview

ESP32-C6 clocks are mainly sourced from oscillator (OSC), RC, and PLL circuit, and then processed by the dividers or selectors, which allows most functional modules to select their working clock according to their power consumption and performance requirements. Figure 8.2-1 shows the system clock structure.

## 8.2.2 Architectural Overview

Figure 8.2-1. System Clock

![Image](images/08_Chapter_8_img002_92b6b2a5.png)

## Note:

The AUTODIV in the figure will divide 480 MHz PLL\_CLK into 160 MHz clock by hardware control only when the MUX before selects PLL\_CLK. If the MUX before selects RC\_FAST\_CLK or XTAL\_CLK, AUTODIV will not divide the clock frequency.

## 8.2.3 Features

ESP32-C6 clock sources as shown on the left side of Figure 8.2-1 can be classified into two types depending on their frequencies:

- High-speed clock sources for devices working at a higher frequency, such as CPU and digital peripherals
- – PLL\_CLK (480 MHz): internal PLL clock. Its reference clock is XTAL\_CLK.
- – XTAL\_CLK (40 MHz): external crystal clock
- Slow-speed clock sources for LP system and some peripherals working in low-power mode
- – XTAL32K\_CLK (32 kHz): external crystal clock
- – RC\_FAST\_CLK (17.5 MHz by default): internal fast RC oscillator with adjustable frequency
- – RC\_SLOW\_CLK (136 kHz by default): internal slow RC oscillator
- – OSC\_SLOW\_CLK (32 kHz by default): external slow clock input through XTAL\_32K\_P. After configuring this GPIO, also configure the Hold function (see Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) &gt; 7.9 Pin Hold Feature)

## 8.2.4 Functional Description

## 8.2.4.1 HP System Clock

As Figure 8.2-1 shows, CPU\_CLK is the master clock for CPU and it can be as high as 160 MHz when CPU works in high performance mode. Alternatively, CPU can run at lower frequencies, such as at 2 MHz, to achieve lower power consumption. CPU\_CLK shares the same clock sources with AHB\_CLK, CRYPTO\_CLK, and MSPI\_CLK. Users can select from XTAL\_CLK, PLL\_CLK, or RC\_FAST\_CLK as the clock source of CPU\_CLK by configuring PCR\_SOC\_CLK\_SEL. See Table 8.2-1 and Table 8.2-2. When PLL\_CLK is selected as the clock source, CPU\_CLK will be divided into 160 MHz clock by hardware control before the configurable divider, please refer to AUTODIV in figure 8.2-1. By default, the CPU clock is sourced from XTAL\_CLK with a divider of 1, i.e., the CPU clock is 40 MHz.

Table 8.2-1. CPU\_CLK Clock Source

|   PCR_SOC_CLK_SEL | CPU Clock Source   |
|-------------------|--------------------|
|                 0 | XTAL_CLK           |
|                 1 | PLL_CLK            |
|                 2 | RC_FAST_CLK        |

Table 8.2-2. Frequency of CPU\_CLK, AHB\_CLK and HP\_ROOT\_CLK

| Clock         | Source                   | Frequency                                             |
|---------------|--------------------------|-------------------------------------------------------|
| HP_ROOT_CLK 1 | PLL_CLK                  | 480 MHz, will be divided to 160 MHz clock by hardware |
| HP_ROOT_CLK 1 | XTAL_CLK                 | 40 MHz                                                |
| HP_ROOT_CLK 1 | RC_FAST_CLK              | 17.5 MHz                                              |
| CPU_CLK 2     | PLL_CLK                  | fHP_ROOT_CLK / (PCR_CPU_HS_DIV_NUM + 1)               |
| CPU_CLK 2     | Low-speed clock source 3 | fHP_ROOT_CLK / (PCR_CPU_LS_DIV_NUM + 1)               |
| AHB_CLK 4     | PLL_CLK                  | fHP_ROOT_CLK / (PCR_AHB_HS_DIV_NUM + 1)               |
| AHB_CLK 4     | Low-speed clock source   | fHP_ROOT_CLK / (PCR_AHB_LS_DIV_NUM + 1)               |

The available divider values for CPU\_CLK and AHB\_CLK are as follows:

- PCR\_CPU\_HS\_DIV\_NUM: 0, 1, 3
- PCR\_CPU\_LS\_DIV\_NUM: 0, 1, 3, 7, 15, 31
- PCR\_AHB\_HS\_DIV\_NUM: 3, 7, 15
- PCR\_AHB\_LS\_DIV\_NUM: 0, 1, 3, 7, 15, 31

As shown in 8.2-1, to generate APB\_CLK, AHB\_CLK might be divided twice. The first division is compulsory. That is, AHB\_CLK is always divided by the divisor (PCR\_APB\_DIV\_NUM + 1). The second division (also called automatic frequency reduction) is optional. When there is no request from the host in the chip to access peripheral registers, AHB\_CLK will be further divided by APB\_DECREASE\_DIV\_NUM + 1. If the host initiates a request to access peripheral registers, APB\_CLK will be restored to the frequency after the first division.

Note that the chip's performance will degrade due to the automatic frequency reduction. This function can be disabled (already disabled by default) by configuring APB\_DECREASE\_DIV\_NUM to 0.

## 8.2.4.2 LP System Clock

The LP system can operate when most other clocks are disabled. LP system clocks include LP\_SLOW\_CLK and LP\_FAST\_CLK.

The clock sources for LP\_SLOW\_CLK and LP\_FAST\_CLK are low-frequency clocks:

- LP\_SLOW\_CLK can be derived from:
- – RC\_SLOW\_CLK
- – XTAL32K\_CLK
- – OSC\_SLOW\_CLK
- LP\_FAST\_CLK can be derived from:
- – 20 MHz XTAL\_D2\_CLK, which is XTAL\_CLK divided by 2
- – RC\_FAST\_CLK

The clock source of LP\_DYN\_SLOW\_CLK is LP\_SLOW\_CLK.

The clock source of LP\_DYN\_FAST\_CLK depends on the chip's power mode (see Chapter 12 Low-Power Management).

- Select LP\_FAST\_CLK as its clock source in Active and Modem-sleep mode
- Select LP\_SLOW\_CLK as its clock source in Light-sleep and Deep-sleep mode

## 8.2.4.3 Peripheral Clocks

Table 8.2-3, Table 8.2-4, and Table 8.2-5 list the derived clocks source and HP clocks/LP clocks for each peripheral.

Chapter 8 Reset and Clock

Source Clock

CLOCK FROM IO

LP\_FAST\_CLK

20 MHz

SLOW\_CLK

FAST\_CLK

CPU\_CLK

AHB\_CLK

Derived Clock

Source Clock

Derived Clock

LP\_FAST\_CLK

20 MHz

SLOW\_CLK

FAST\_CLK

CPU\_CLK

AHB\_CLK

![Image](images/08_Chapter_8_img003_d2514c17.png)

| APB_CLK                 | APB_CLK                   |
|-------------------------|---------------------------|
| CRYPTO_CLK              | CRYPTO_CLK                |
| MSPI_CLK                | MSPI_CLK                  |
|                         | 160 MHz/40
 MHz/17.5
 MHz |
| HP_ROOT_CLK             |                           |
| 160 MHz/40 MHz/17.5 MHz |                           |

CLK 32 kHz

OSC\_SLOW\_CLK 32 kHz

Y

Y

Table 8.2-4. HP Clocks Used by Each Peripheral

| Source Clock                         | Source Clock                         |                                      |                                      |                                        |                                      |
|--------------------------------------|--------------------------------------|--------------------------------------|--------------------------------------|----------------------------------------|--------------------------------------|
| RC_SLOW_                             | CLK 136 kHz                          | Y  Y                                 |                                      | CLK 136
 kHz                           |                                      |
|                                      | RC_FAST_  CLK 17.5 MHz               |                                      | Y                                    | CLK 17.5
 MHz Y                        |                                      |
|                                      | 48 MHz                               |                                      |                                      | 48 MHz                                 |                                      |
|                                      | 80 MHz                               |                                      |                                      | 80 MHz Y                               |                                      |
| Derived Clock  PLL_CLK               | 160 MHz                              |                                      |                                      | 160MHz                                 |                                      |
|                                      | 240 MHz                              |                                      |                                      | 240MHz                                 |                                      |
| 480 MHz                              |                                      |                                      |                                      | 480MHz                                 |                                      |
| Source Clock  XTAL_CLK  40 MHz  Y  Y | Source Clock  XTAL_CLK  40 MHz  Y  Y | Source Clock  XTAL_CLK  40 MHz  Y  Y | Source Clock  XTAL_CLK  40 MHz  Y  Y | 40 MHz  Y  Y                           | Source Clock  XTAL_CLK  40 MHz  Y  Y |
|                                      |                                      | LP_DYN_FAST_CLK  LP_DYN_SLOW_CLK     | XTAL_D2_CLK                          | Timer Group Main SystemWatchdog Timers |                                      |
| Derived Clock                        |                                      | CPU_CLK                              | LP_FAST_CLK                          | (TIMG)                                 |                                      |

Espressif Systems

CLK 32
kHz

OSC\_SLOW\_CLK
32 kHz

311

Submit Documentation Feedback

ESP32-C6 TRM (Version 1.1)

Table 8.2-3. Derived Clock Source

XTAL\_D2\_CLK

LP\_DYN\_

LP\_DYN\_

XTAL32K\_

Y

Y

XTAL\_D2\_CK

LP\_DYN\_

LP\_DYN\_

XTAL32K\_

CLOCK FROM IO

I2S\_MCLK\_PAD

GoBack

Continued on the next page...

Chapter 8 Reset and Clock

Source Clock

CLOCK FROM IO

PARL\_CLK\_PAD

LP\_FAST\_CLK

20 MHz

SLOW\_CLK

FAST\_CLK

CPU\_CLK

AHB\_CLK

Y

Y

Y

Y

LP\_FAST\_CLK

20 MHz

SLOW\_CLK

FAST\_CLK

CPU\_CLK

AHB\_CLK

| APB_CLK                                        | Y   | Table 8.2-5. LP Clocks Used by Each Peripheral   | Table 8.2-5. LP Clocks Used by Each Peripheral   | Table 8.2-5. LP Clocks Used by Each Peripheral   | Table 8.2-5. LP Clocks Used by Each Peripheral   |
|------------------------------------------------|-----|--------------------------------------------------|--------------------------------------------------|--------------------------------------------------|--------------------------------------------------|
|                                                |     |                                                  | CRYPTO_CLK  APB_CLK                              |                                                  |                                                  |
| CRYPTO_CLK                                     |     |                                                  |                                                  |                                                  |                                                  |
| HP_ROOT_CLK  160 MHz/40 MHz/17.5 MHz  MSPI_CLK |     |                                                  | 160 MHz/40
 MHz/17.5
 MHz MSPI_CLK               |                                                  |                                                  |
| XTAL32K_  CLK 32 kHz                           |     |                                                  | CLK 32
 kHz                                      |                                                  |                                                  |
|                                                |     |                                                  | OSC_SLOW_CLK
 32 kHz                             |                                                  |                                                  |
| OSC_SLOW_CLK 32 kHz                            |     |                                                  |                                                  |                                                  |                                                  |

RC\_SLOW\_

RC\_FAST\_

Derived Clock

Source Clock

Derived Clock

Source Clock

Peripheral

Parallel IO Con- troller (PARL\_IO)

CLK 136 kHz

Source Clock

Derived Clock

Source Clock

## RC\_SLOW\_ CLK 136
kHz

RC\_FAST\_

Peripheral

Pulse Count Con-troller (PCNT)

Event Task Matrix(SOC\_ETM)

GDMA Controller

| CLK 17.5 MHz  Y              |               |        | Y   | Y   | Y   | Y   | Y   | Y   | Y   | Y   |
|------------------------------|---------------|--------|-----|-----|-----|-----|-----|-----|-----|-----|
| 48                           |               | 48 MHz |     |     |     |     |     |     |     |     |
| MHz                          |               |        |     |     |     |     |     |     |     |     |
| 80 MHz                       | Derived Clock | 80 MHz |     |     |     |     |     |     |     |     |
| PLL_CLK  240 MHz  160 MHz  Y | PLL_CLK       | 160MHz |     |     |     |     |     |     |     |     |
|                              |               | 240MHz |     |     |     |     |     |     |     |     |
| 480 MHz                      |               | 480MHz |     |     |     |     |     |     |     |     |
|                              | Source Clock  |        |     |     |     |     |     |     |     |     |
| XTAL_CLK  40 MHz  Y          | XTAL_CLK      | 40 MHz |     |     |     |     |     |     |     |     |

IO MUX

Espressif Systems

/

(SHA)

Digital

/

(ECC)

(GDMA)

UHCI

312

Submit Documentation Feedback

(eFuse)

(LP\_I2C)

Brownout Detec- tor

Power Manage-ment Unit (PMU)

UART Controller(LP\_UART)

Low-Power CPU

I2C Controller

LP\_IO MUX

ESP32-C6 TRM (Version 1.1)

Table 8.2-4 – Continued from the previous page...

XTAL\_D2\_CK

LP\_DYN\_

LP\_DYN\_

AES Accelera-tor (AES)/SHA

Accelerator erator (RSA)

Accelerator

Signature

/

(DS)

(DS)/HMAC Ac-celerator (HMAC)

Interrupt Matrix(INTMTX)

XTAL\_D2\_CK

LP\_DYN\_

LP\_DYN\_

CLOCK FROM IO

Y

eFuse Controller

Y

Y

RTC WatchdogTimer (RWDT)

Y

Y

RTC Timer

Y

Y

Y

Y

Y

Y

Y

Y

Y

Y

GoBack

## PLL\_CLK

PLL\_F480M\_CLK is the source clock of PLLfiwhich is 480 MHz. PLL\_D2\_CLK (240 MHz), PLL\_F160M\_CLK, PLL\_F80M\_CLK, and PLL\_F48M\_CLK are divided from PLL\_F480M\_CLK.

## CRYPTO\_CLK

As shown in Figure 8.2-1, CRYPTO\_CLK shares the same clock sources with CPU\_CLK, and its frequency is up to 160 MHz.

To protect encryption and decryption peripherals from DPA (Differential Power Analysis) attacks, a random divider strategy is implemented for the function clock of encryption and decryption peripherals. Four security levels are available, depending on the range of random divider. Users can select the security level by configuring HP\_SYSTEM\_SEC\_DPA\_CONF\_REG. If HP\_SYSTEM\_SEC\_DPA\_CFG\_SEL is set to 1, the security level is determined by configuration of EFUSE\_SEC\_DPA\_LEVEL, otherwise, by the value of HP\_SYSTEM\_SEC\_DPA\_LEVEL .

## LED\_PWM

LEDC module uses PLL\_F80M\_CLK, RC\_FAST\_CLK and XTAL\_CLK as clock source when APB\_CLK is disabled. In other words, when the system is in low-power mode, most peripherals will be halted (APB\_CLK is turned off), but LEDC can work normally via RC\_FAST\_CLK.

## 8.2.4.4 Wi-Fi and Bluetooth LE Clock

Wi-Fi and Bluetooth LE can work only when CPU\_CLK uses PLL\_CLK as its clock source. Suspending PLL\_CLK requires that Wi-Fi and Bluetooth LE have entered low-power mode first.

## 8.2.5 HP System Clock Gating Controlled by PMU

In various operating modes of the ESP32-C6 chip, the following register fields can be pre-configured to enable the PMU to control the clock gating of HP system peripherals:

- PMU\_HP\_x\_DIG\_ICG\_APB\_EN (x = ACTIVE/MODEM/SLEEP): Controls the clock gating of the register read/write operations of HP system peripherals.
- PMU\_HP\_x\_DIG\_ICG\_FUNC\_EN (x = ACTIVE/MODEM/SLEEP): Controls the clock gating of the operating clock of HP system peripherals.

For detailed configuration procedures, please refer to 12 Low-Power Management .

Tables 8.2-6 and 8.2-7 list the correspondence between pre-configured PMU register bits and HP system clock gating.

Table 8.2-6. Mapping Between PMU Register Bits and the Clock Gating of Peripherals' Register R/W Operations

|   PMU_HP_x_DIG_ICG_APB_EN Bit | Peripheral                                                                                                                             |
|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
|                             0 | AES Accelerator (AES) SHA Accelerator (SHA) RSA Accelerator (RSA) ECC Accelerator (ECC) Digital Signature (DS) HMAC Accelerator (HMAC) |
|                             1 | GDMA Controller (GDMA)                                                                                                                 |
|                             2 | SPI2                                                                                                                                   |
|                             3 | Interrupt Matrix (INTMTX)                                                                                                              |
|                             4 | I2S Controller (I2S)                                                                                                                   |
|                             6 | UART0                                                                                                                                  |
|                             7 | UART1                                                                                                                                  |
|                             8 | UHCI                                                                                                                                   |
|                            11 | Timer Group 0                                                                                                                          |
|                            12 | Timer Group 1                                                                                                                          |
|                            13 | I2C Controller (I2C)                                                                                                                   |
|                            14 | LED PWM Controller (LEDC)                                                                                                              |
|                            15 | Remote Control Peripheral (RMT)                                                                                                        |
|                            16 | System Timer (SYSTIMER)                                                                                                                |
|                            17 | USB Serial/JTAG Controller (USB_SERIAL_JTAG)                                                                                           |
|                            18 | TWAI 0                                                                                                                                 |
|                            19 | TWAI 1                                                                                                                                 |
|                            20 | Pulse Count Controller (PCNT)                                                                                                          |
|                            21 | Motor Control PWM (MCPWM)                                                                                                              |
|                            22 | Event Task Matrix (SOC_ETM)                                                                                                            |
|                            23 | Parallel IO Controller (PARL_IO)                                                                                                       |
|                            25 | Debug Assistant (ASSIST_DEBUG)                                                                                                         |
|                            26 | IO MUX and GPIO Matrix (GPIO, IO MUX)                                                                                                  |

Table 8.2-7. Mapping Between PMU Register Bits and the Gating of Peripherals’ Operating Clock

|   PMU_HP_x_DIG_ICG_FUNC_EN Bit | Peripheral                                                                                                                             |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|
|                              0 | GDMA Controller (GDMA)                                                                                                                 |
|                              1 | SPI2                                                                                                                                   |
|                              2 | I2S Receive Side                                                                                                                       |
|                              3 | UART0                                                                                                                                  |
|                              4 | UART1                                                                                                                                  |
|                              5 | UHCI                                                                                                                                   |
|                              6 | USB Serial/JTAG Controller (USB_SERIAL_JTAG)                                                                                           |
|                              7 | I2S Transmit Side                                                                                                                      |
|                             10 | Debug Assistant (ASSIST_DEBUG)                                                                                                         |
|                             11 | SDIO Slave Controller (SDIO)                                                                                                           |
|                             12 | On-Chip Sensor and Analog Signal Processing                                                                                            |
|                             13 | Timer Group 0                                                                                                                          |
|                             14 | Timer Group 1                                                                                                                          |
|                             16 | Event Task Matrix (SOC_ETM)                                                                                                            |
|                             17 | High-Performance CPU                                                                                                                   |
|                             18 | System Timer (SYSTIMER)                                                                                                                |
|                             19 | AES Accelerator (AES) SHA Accelerator (SHA) RSA Accelerator (RSA) ECC Accelerator (ECC) Digital Signature (DS) HMAC Accelerator (HMAC) |
|                             21 | Remote Control Peripheral (RMT)                                                                                                        |
|                             22 | Motor Control PWM (MCPWM)                                                                                                              |
|                             24 | Parallel IO Transmit Side                                                                                                              |
|                             25 | Parallel IO Receive Side                                                                                                               |
|                             27 | LED PWM Controller (LEDC)                                                                                                              |
|                             28 | IO MUX and GPIO Matrix (GPIO, IO MUX)                                                                                                  |
|                             29 | I2C Controller (I2C)                                                                                                                   |
|                             30 | TWAI 0                                                                                                                                 |
|                             31 | TWAI 1                                                                                                                                 |

## 8.3 Programming Procedures

## 8.3.1 HP System Clock Configuration

The clock source of HP\_ROOT\_CLK can be configured via PCR\_SOC\_CLK\_SEL .

- If PLL\_CLK is selected as the clock source of HP\_ROOT\_CLK,
- – the clock divisor for CPU\_CLK can be configured via PCR\_CPU\_HS\_DIV\_NUM .
- – the clock divisor for AHB\_CLK can be configured via PCR\_AHB\_HS\_DIV\_NUM .

- If XTAL\_CLK or RC\_FAST\_CLK is selected as the clock source of HP\_ROOT\_CLK,
- – the clock divisor for CPU\_CLK can be configured via PCR\_CPU\_LS\_DIV\_NUM .
- – the clock divisor for AHB\_CLK can be configured via PCR\_AHB\_LS\_DIV\_NUM .

## 8.3.2 LP System Clock Configuration

The clock source of LP\_SLOW\_CLK can be configured via LP\_CLKRST\_SLOW\_CLK\_SEL .

The clock source of LP\_FAST\_CLK can be configured via LP\_CLKRST\_FAST\_CLK\_SEL .

## 8.3.3 Peripheral Clock Reset and Configuration

## Notice:

ESP32-C6 features low power consumption. This is why some peripheral clocks are gated (disabled) by default. Before using any of these peripherals, it is mandatory to enable the clock for the given peripheral by setting the corresponding CLK\_EN bit to 1, and release the peripheral from reset state to make it operational by setting the RST\_EN bit to 0.

The clocks of most peripherals can be classified into two types:

- Bus clock: used to configure peripheral registers.
- Function clock: such as UART's reference clock, used by peripherals to operate.

The operating clock (function clock) of most peripherals can be selected from multiple clock sources. In the description of the gating registers, it will be stated whether the register belongs to the bus clock (AHB\_CLK, APB\_CLK) gating register or the function clock gating register.

Bus clock switches, function clock switches, and the configuration registers for clock source selection and clock frequency division are grouped into the PCR module. For more information, see Section 8.4fiRegister Summary .

When a peripheral is not working, users can turn off its function clock by configuring related registers. Turning off the peripheral's function clock does not affect the rest of the system.

Take I2C clock configuration as an example.

Figure 8.3-1. Clock Configuration Example

![Image](images/08_Chapter_8_img004_b6180ab9.png)

Figure 8.3-1 shows the clock structure of I2C. The clock structure of other peripherals is similar to this one. CLK\_SWITCH is used to select a clock output and CLK\_GATE to turn on/off the clock.

In scenarios that require low power consumption, when the peripheral is not in use, in addition to turning off the function clock, the bus clock of the peripheral can also be turned off to further lower power consumption.

Note that if you turn off the bus clock first, the function clock may continue working. It is recommended to turn off the function clock first and then the bus clock when turning off the clocks. It is also recommended to turn on the bus clock first and then the function clock when turning on the clocks.

## 8.4 Register Summary

## 8.4.1 PCR Registers

The addresses in this section are relative to the Power/Clock/Reset (PCR) Register base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                    | Description                       | Address   | Access   |
|-------------------------|-----------------------------------|-----------|----------|
| Configuration Register  |                                   |           |          |
| PCR_UART0_CONF_REG      | UART0 configuration register      | 0x0000    | R/W      |
| PCR_UART0_SCLK_CONF_REG | UART0_SCLK configuration register | 0x0004    | R/W      |
| PCR_UART0_PD_CTRL_REG   | UART0 power control register      | 0x0008    | R/W      |
| PCR_UART1_CONF_REG      | UART1 configuration register      | 0x000C    | R/W      |
| PCR_UART1_SCLK_CONF_REG | UART1_SCLK configuration register | 0x0010    | R/W      |

| Name                                | Description                                    | Address   | Access   |
|-------------------------------------|------------------------------------------------|-----------|----------|
| PCR_UART1_PD_CTRL_REG               | UART1 power control register                   | 0x0014    | R/W      |
| PCR_I2C_CONF_REG                    | I2C configuration register                     | 0x0020    | R/W      |
| PCR_I2C_SCLK_CONF_REG               | I2C_SCLK configuration register                | 0x0024    | R/W      |
| PCR_UHCI_CONF_REG                   | UHCI configuration register                    | 0x0028    | R/W      |
| PCR_RMT_CONF_REG                    | RMT configuration register                     | 0x002C    | R/W      |
| PCR_RMT_SCLK_CONF_REG               | RMT_SCLK configuration register                | 0x0030    | R/W      |
| PCR_LEDC_CONF_REG                   | LEDC configuration register                    | 0x0034    | R/W      |
| PCR_LEDC_SCLK_CONF_REG              | LEDC_SCLK configuration register               | 0x0038    | R/W      |
| PCR_TIMERGROUP0_CONF_REG            | TIMERGROUP0 configuration register             | 0x003C    | R/W      |
| PCR_TIMERGROUP0_TIMER_CLK_ CONF_REG | TIMERGROUP0_TIMER_CLK configuration reg ister | 0x0040    | R/W      |
| PCR_TIMERGROUP0_WDT_CLK_ CONF_REG   | TIMERGROUP0_WDT_CLK configuration regis ter   | 0x0044    | R/W      |
| PCR_TIMERGROUP1_CONF_REG            | TIMERGROUP1 configuration register             | 0x0048    | R/W      |
| PCR_TIMERGROUP1_TIMER_CLK_ CONF_REG | TIMERGROUP1_TIMER_CLK configuration reg ister | 0x004C    | R/W      |
| PCR_TIMERGROUP1_WDT_CLK_ CONF_REG   | TIMERGROUP1_WDT_CLK configuration register     | 0x0050    | R/W      |
| PCR_SYSTIMER_CONF_REG               | SYSTIMER configuration register                | 0x0054    | R/W      |
| PCR_SYSTIMER_FUNC_CLK_CONF _REG     | SYSTIMER_FUNC_CLK configuration register       | 0x0058    | R/W      |
| PCR_TWAI0_CONF_REG                  | TWAI0 configuration register                   | 0x005C    | R/W      |
| PCR_TWAI0_FUNC_CLK_CONF_REG         | TWAI0_FUNC_CLK configuration register          | 0x0060    | R/W      |
| PCR_TWAI1_CONF_REG                  | TWAI1 configuration register                   | 0x0064    | R/W      |
| PCR_TWAI1_FUNC_CLK_CONF_REG         | TWAI1_FUNC_CLK configuration register          | 0x0068    | R/W      |
| PCR_I2S_CONF_REG                    | I2S configuration register                     | 0x006C    | R/W      |
| PCR_I2S_TX_CLKM_CONF_REG            | I2S_TX_CLKM configuration register             | 0x0070    | R/W      |
| PCR_I2S_TX_CLKM_DIV_CONF_REG        | I2S_TX_CLKM_DIV configuration register         | 0x0074    | R/W      |
| PCR_I2S_RX_CLKM_CONF_REG            | I2S_RX_CLKM configuration register             | 0x0078    | R/W      |
| PCR_I2S_RX_CLKM_DIV_CONF_REG        | I2S_RX_CLKM_DIV configuration register         | 0x007C    | R/W      |
| PCR_SARADC_CONF_REG                 | SARADC configuration register                  | 0x0080    | R/W      |
| PCR_SARADC_CLKM_CONF_REG            | SARADC_CLKM configuration register             | 0x0084    | R/W      |
| PCR_TSENS_CLK_CONF_REG              | TSENS_CLK configuration register               | 0x0088    | R/W      |
| PCR_USB_SERIAL_JTAG_CONF_REG        | _SERIAL_JTAG configuration register            | 0x008C    | R/W      |
| PCR_INTMTX_CONF_REG                 | INTMTX configuration register                  | 0x0090    | R/W      |
| PCR_PCNT_CONF_REG                   | PCNT configuration register                    | 0x0094    | R/W      |
| PCR_ETM_CONF_REG                    | ETM configuration register                     | 0x0098    | R/W      |
| PCR_PWM_CONF_REG                    | PWM configuration register                     | 0x009C    | R/W      |
| PCR_PWM_CLK_CONF_REG                | PWM_CLK configuration register                 | 0x00A0    | R/W      |
| PCR_PARL_IO_CONF_REG                | PARL_IO configuration register                 | 0x00A4    | R/W      |
| PCR_PARL_CLK_RX_CONF_REG            | PARL_CLK_RX configuration register             | 0x00A8    | R/W      |
| PCR_PARL_CLK_TX_CONF_REG            | PARL_CLK_TX configuration register             | 0x00AC    | R/W      |
| PCR_SDIO_SLAVE_CONF_REG             | SDIO_SLAVE configuration register              | 0x00B0    | R/W      |

| Name                          | Description                                        | Address   | Access   |
|-------------------------------|----------------------------------------------------|-----------|----------|
| PCR_GDMA_CONF_REG             | GDMA configuration register                        | 0x00BC    | R/W      |
| PCR_SPI2_CONF_REG             | SPI2 configuration register                        | 0x00C0    | R/W      |
| PCR_SPI2_CLKM_CONF_REG        | SPI2_CLKM configuration register                   | 0x00C4    | R/W      |
| PCR_AES_CONF_REG              | AES configuration register                         | 0x00C8    | R/W      |
| PCR_SHA_CONF_REG              | SHA configuration register                         | 0x00CC    | R/W      |
| PCR_RSA_CONF_REG              | RSA configuration register                         | 0x00D0    | R/W      |
| PCR_RSA_PD_CTRL_REG           | RSA power control register                         | 0x00D4    | R/W      |
| PCR_ECC_CONF_REG              | ECC configuration register                         | 0x00D8    | R/W      |
| PCR_ECC_PD_CTRL_REG           | ECC power control register                         | 0x00DC    | R/W      |
| PCR_DS_CONF_REG               | DS configuration register                          | 0x00E0    | R/W      |
| PCR_HMAC_CONF_REG             | HMAC configuration register                        | 0x00E4    | R/W      |
| PCR_IOMUX_CONF_REG            | IOMUX configuration register                       | 0x00E8    | R/W      |
| PCR_IOMUX_CLK_CONF_REG        | IOMUX_CLK configuration register                   | 0x00EC    | R/W      |
| PCR_MEM_MONITOR_CONF_REG      | MEM_MONITOR configuration register                 | 0x00F0    | R/W      |
| PCR_TRACE_CONF_REG            | TRACE configuration register                       | 0x00FC    | R/W      |
| PCR_ASSIST_CONF_REG           | ASSIST configuration register                      | 0x0100    | R/W      |
| PCR_CACHE_CONF_REG            | CACHE configuration register                       | 0x0104    | R/W      |
| PCR_MODEM_APB_CONF_REG        | MODEM_APB configuration register                   | 0x0108    | R/W      |
| PCR_TIMEOUT_CONF_REG          | TIMEOUT configuration register                     | 0x010C    | R/W      |
| PCR_SYSCLK_CONF_REG           | SYSCLK configuration register                      | 0x0110    | varies   |
| PCR_CPU_WAITI_CONF_REG        | CPU_WAITI configuration register                   | 0x0114    | R/W      |
| PCR_CPU_FREQ_CONF_REG         | CPU_FREQ configuration register                    | 0x0118    | R/W      |
| PCR_AHB_FREQ_CONF_REG         | AHB_FREQ configuration register                    | 0x011C    | R/W      |
| PCR_APB_FREQ_CONF_REG         | APB_FREQ configuration register                    | 0x0120    | R/W      |
| PCR_PLL_DIV_CLK_EN_REG        | SPLL DIV clock-gating configuration register       | 0x0128    | R/W      |
| PCR_CTRL_32K_CONF_REG         | 32KHz clock configuration register                 | 0x0134    | R/W      |
| PCR_SRAM_POWER_CONF_REG       | HP SRAM/ROM configuration register                 | 0x0138    | R/W      |
| PCR_RESET_EVENT_BYPASS_REG    | Reset event bypass backdoor configuration register | 0x0FF0    | R/W      |
| Frequency Statistics Register |                                                    |           |          |
| PCR_SYSCLK_FREQ_QUERY_0_REG   | SYSCLK frequency query register 0                  | 0x0124    | HRO      |
| Version Register              |                                                    |           |          |
| PCR_DATE_REG                  | Version control register                           | 0x0FFC    | R/W      |

## 8.4.2 LP System Clock Registers

The addresses in this section are relative to the Low-power Clock/Reset Register (LP\_CLKRST) base address. .

For base address, please refer to Table 5.3-2 in Chapter 5 System and Memory

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                      | Description                          | Address   | Access   |
|---------------------------|--------------------------------------|-----------|----------|
| Configuration Registers   |                                      |           |          |
| LP_CLKRST_LP_CLK_CONF_REG | Configures the root clk of LP system | 0x0000    | R/W      |

| Name                       | Description                                      | Address   | Access   |
|----------------------------|--------------------------------------------------|-----------|----------|
| LP_CLKRST_LP_CLK_PO_EN_REG | Configures the clk gate to pad                   | 0x0004    | R/W      |
| LP_CLKRST_LP_CLK_EN_REG    | Configure LP root clk source gate                | 0x0008    | R/W      |
| LP_CLKRST_LP_RST_EN_REG    | Configures the peri of LP system software reset  | 0x000C    | R/W      |
| LP_CLKRST_RESET_CAUSE_REG  | Represents the reset casue                       | 0x0010    | varies   |
| LP_CLKRST_CPU_RESET_REG    | Configures CPU reset                             | 0x0014    | R/W      |
| LP_CLKRST_FOSC_CNTL_REG    | Configures the RC_FAST_CLK frequency             | 0x0018    | R/W      |
| LP_CLKRST_CLK_TO_HP_REG    | Configures the clk gate of LP clk to HP system   | 0x0020    | R/W      |
| LP_CLKRST_LPMEM_FORCE_REG  | Configures the LP_MEM clk gate force param eter | 0x0024    | R/W      |
| LP_CLKRST_LPPERI_REG       | Configures the LP peri clk                       | 0x0028    | R/W      |
| LP_CLKRST_XTAL32K_REG      | Configures the XTAL32K parameter                 | 0x002C    | R/W      |
| LP_CLKRST_DATE_REG         | Version control register                         | 0x03FC    | R/W      |

## 8.5 Registers

## 8.5.1 PCR Registers

The addresses in this section are relative to the Power/Clock/Reset (PCR) Register base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 8.1. PCR\_UART0\_CONF\_REG (0x0000)

![Image](images/08_Chapter_8_img005_9fb45ad1.png)

PCR\_UART0\_CLK\_EN Configures whether or not to enable UART0 APB clock.

0: Not enable

1: Enable

(R/W)

PCR\_UART0\_RST\_EN Configures whether or not to reset UART0 module.

0: Not reset

1: Reset

(R/W)

Register 8.2. PCR\_UART0\_SCLK\_CONF\_REG (0x0004)

![Image](images/08_Chapter_8_img006_b12b28c9.png)

PCR\_UART0\_SCLK\_DIV\_A Configures the denominator of the frequency divider factor for UART0

function clock.

(R/W)

PCR\_UART0\_SCLK\_DIV\_B Configures the numerator of the frequency divider factor for UART0

function clock.

(R/W)

PCR\_UART0\_SCLK\_DIV\_NUM Configures the integral part of the frequency divider factor for UART0 function clock.

- (R/W)

PCR\_UART0\_SCLK\_SEL Configures to select clock source.

- 0: Not select any clock
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Select XTAL\_CLK

(R/W)

PCR\_UART0\_SCLK\_EN Configures whether or not to enable UART0 function clock.

- 0: Not enable
- 1: Enable

(R/W)

Register 8.3. PCR\_UART0\_PD\_CTRL\_REG (0x0008)

![Image](images/08_Chapter_8_img007_68b36c89.png)

PCR\_UART0\_MEM\_FORCE\_PU Configures whether or not to force power up UART0 memory.

- 0: Not force power up UART0 memory
- 1: Force power up UART0 memory
- (R/W)

PCR\_UART0\_MEM\_FORCE\_PD Configures whether or not to force power down UART0 memory.

- 0: Not force power down UART0 memory
- 1: Force power down UART0 memory

(R/W)

## Register 8.4. PCR\_UART1\_CONF\_REG (0x000C)

![Image](images/08_Chapter_8_img008_352253f8.png)

PCR\_UART1\_CLK\_EN Configures whether or not to enable UART1 APB clock.

- 0: Not enable
- 1: Enable
- (R/W)

PCR\_UART1\_RST\_EN Configures whether or not to reset UART1 module.

- 0: Not reset
- 1: Reset

(R/W)

Register 8.5. PCR\_UART1\_SCLK\_CONF\_REG (0x0010)

![Image](images/08_Chapter_8_img009_8dd5050d.png)

PCR\_UART1\_SCLK\_DIV\_A Configures the denominator of the frequency divider factor for UART1

function clock.

(R/W)

PCR\_UART1\_SCLK\_DIV\_B Configures the numerator of the frequency divider factor for UART1 function clock.

(R/W)

PCR\_UART1\_SCLK\_DIV\_NUM Configures the integral part of the frequency divider factor for UART1 function clock.

- (R/W)

PCR\_UART1\_SCLK\_SEL Configures to select clock source.

- 0: Not select any clock

1: Select PLL\_F80M\_CLK

- 2: Select RC\_FAST\_CLK

3: Select XTAL\_CLK

(R/W)

PCR\_UART1\_SCLK\_EN Configures whether or not to enable UART1 function clock.

0: Not enable

- 1: Enable

(R/W)

## Register 8.6. PCR\_UART1\_PD\_CTRL\_REG (0x0014)

![Image](images/08_Chapter_8_img010_fc226bca.png)

PCR\_UART1\_MEM\_FORCE\_PU Configures whether or not to force power up UART1 memory.

- 0: Not force power up UART1 memory
- 1: Force power up UART1 memory

(R/W)

- PCR\_UART1\_MEM\_FORCE\_PD Configures whether or not to force power down UART1 memory.
- 0: Not force power down UART1 memory
- 1: Force power down UART1 memory
- (R/W)

## Register 8.7. PCR\_I2C\_CONF\_REG (0x0020)

![Image](images/08_Chapter_8_img011_05ac949c.png)

PCR\_I2C\_CLK\_EN Configures whether or not to enable I2C APB clock.

- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_I2C\_RST\_EN Configures whether or not to reset I2C module.
- 0: Not reset
- 1: Reset
- (R/W)

Register 8.8. PCR\_I2C\_SCLK\_CONF\_REG (0x0024)

![Image](images/08_Chapter_8_img012_d9284a58.png)

PCR\_I2C\_SCLK\_DIV\_A Configures the denominator of the frequency divider factor for I2C function clock.

(R/W)

PCR\_I2C\_SCLK\_DIV\_B Configures the numerator of the frequency divider factor for I2C function clock.

- (R/W)
- PCR\_I2C\_SCLK\_DIV\_NUM Configures the integral part of the frequency divider factor for I2C function clock. (R/W)

PCR\_I2C\_SCLK\_SEL Configures to select clock source.

- 0 (default): Select XTAL\_CLK
- 1: Select RC\_FAST\_CLK

(R/W)

PCR\_I2C\_SCLK\_EN Configures whether or not to enable I2C function clock.

- 0: Not enable

1: Enable

(R/W)

## Register 8.9. PCR\_UHCI\_CONF\_REG (0x0028)

![Image](images/08_Chapter_8_img013_3a35acbc.png)

PCR\_UHCI\_CLK\_EN Configures whether or not to enable UHCI clock.

- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_UHCI\_RST\_EN Configures whether or not to reset UHCI module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.10. PCR\_RMT\_CONF\_REG (0x002C)

![Image](images/08_Chapter_8_img014_4fd281fc.png)

PCR\_RMT\_CLK\_EN Configures whether or not to enable RMT APB clock.

- 0: Enable
- 1: Not enable
- (R/W)
- PCR\_RMT\_RST\_EN Configures whether or not to reset RMT module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.11. PCR\_RMT\_SCLK\_CONF\_REG (0x0030)

![Image](images/08_Chapter_8_img015_c3e8ee12.png)

PCR\_RMT\_SCLK\_DIV\_A Configures the denominator of the frequency divider factor for RMT function clock.

(R/W)

PCR\_RMT\_SCLK\_DIV\_B Configures the numerator of the frequency divider factor for RMT function clock.

(R/W)

PCR\_RMT\_SCLK\_DIV\_NUM Configures the integral part of the frequency divider factor for RMT

function clock.

(R/W)

PCR\_RMT\_SCLK\_SEL Configures to select clock source.

0: Not select any clock

1 (default): Select PLL\_F80M\_CLK

2: Select RC\_FAST\_CLK

3: Select XTAL\_CLK

(R/W)

- PCR\_RMT\_SCLK\_EN Configures whether or not to enable RMT function clock.
- 0: Not enable

1: Enable

(R/W)

## Register 8.12. PCR\_LEDC\_CONF\_REG (0x0034)

![Image](images/08_Chapter_8_img016_ada215be.png)

- PCR\_LEDC\_CLK\_EN Configures whether or not to enable LEDC APB clock.
- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_LEDC\_RST\_EN Configures whether or not to reset LEDC module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.13. PCR\_LEDC\_SCLK\_CONF\_REG (0x0038)

![Image](images/08_Chapter_8_img017_75aaab7a.png)

## PCR\_LEDC\_SCLK\_SEL Configures to select clock source.

- 0 (default): Not select any clock
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Select XTAL\_CLK
- (R/W)
- PCR\_LEDC\_SCLK\_EN Configures whether or not to enable LEDC function clock.
- 0: Not enable
- 1: Enable

(R/W)

## Register 8.14. PCR\_TIMERGROUP0\_CONF\_REG (0x003C)

![Image](images/08_Chapter_8_img018_6b24ec1b.png)

PCR\_TG0\_CLK\_EN Configures whether or not to enable TIMER\_GROUP0 APB clock.

- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_TG0\_RST\_EN Configures whether or not to reset TIMER\_GROUP0 module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.15. PCR\_TIMERGROUP0\_TIMER\_CLK\_CONF\_REG (0x0040)

![Image](images/08_Chapter_8_img019_2284020f.png)

- PCR\_TG0\_TIMER\_CLK\_SEL Configures to select clock source.
- 0 (default): Select XTAL\_CLK
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Reserved
- (R/W)
- PCR\_TG0\_TIMER\_CLK\_EN Configures whether or not to enable TIMER\_GROUP0 timer clock.
- 0: Not enable
- 1: Enable
- (R/W)

## Register 8.16. PCR\_TIMERGROUP0\_WDT\_CLK\_CONF\_REG (0x0044)

![Image](images/08_Chapter_8_img020_a431e9ae.png)

PCR\_TG0\_WDT\_CLK\_SEL Configures to select clock source.

- 0 (default): Select XTAL\_CLK
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Reserved
- (R/W)

PCR\_TG0\_WDT\_CLK\_EN Configures whether or not to enable TIMER\_GROUP0 WDT clock.

- 0: Not enable
- 1: Enable
- (R/W)

## Register 8.17. PCR\_TIMERGROUP1\_CONF\_REG (0x0048)

![Image](images/08_Chapter_8_img021_86c8ce86.png)

PCR\_TG1\_CLK\_EN Configures whether or not to enable TIMER\_GROUP1 APB clock.

- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_TG1\_RST\_EN Configures whether or not to reset TIMER\_GROUP1 module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.18. PCR\_TIMERGROUP1\_TIMER\_CLK\_CONF\_REG (0x004C)

![Image](images/08_Chapter_8_img022_2cef0406.png)

## PCR\_TG1\_TIMER\_CLK\_SEL Configures to select clock source.

- 0 (default): Select XTAL\_CLK
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Reserved
- (R/W)

## PCR\_TG1\_TIMER\_CLK\_EN Configures whether or not to enable TIMER\_GROUP1 timer clock.

- 0: Not enable
- 1: Enable
- (R/W)

## Register 8.19. PCR\_TIMERGROUP1\_WDT\_CLK\_CONF\_REG (0x0050)

![Image](images/08_Chapter_8_img023_ff8e1d9a.png)

## PCR\_TG1\_WDT\_CLK\_SEL Configures to select clock source.

- 0 (default): Select XTAL\_CLK
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Reserved
- (R/W)

PCR\_TG1\_WDT\_CLK\_EN Configures whether or not to enable TIMER\_GROUP1 WDT clock.

- 0: Not enable
- 1: Enable
- (R/W)

## Register 8.20. PCR\_SYSTIMER\_CONF\_REG (0x0054)

![Image](images/08_Chapter_8_img024_4ac0b787.png)

PCR\_SYSTIMER\_CLK\_EN Configures whether or not to enable SYSTIMER APB clock.

- 0: Not enable
- 1: Enable

(R/W)

## PCR\_SYSTIMER\_RST\_EN Configures whether or not to reset SYSTIMER module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.21. PCR\_SYSTIMER\_FUNC\_CLK\_CONF\_REG (0x0058)

![Image](images/08_Chapter_8_img025_1c5b73fe.png)

PCR\_SYSTIMER\_FUNC\_CLK\_SEL Configures to select clock source.

- 0 (default): Select XTAL\_CLK
- 1: Select RC\_FAST\_CLK
- (R/W)

PCR\_SYSTIMER\_FUNC\_CLK\_EN Configures whether or not to enable SYSTIMER function clock.

- 0: Not enable
- 1: Enable

(R/W)

## Register 8.22. PCR\_TWAI0\_CONF\_REG (0x005C)

![Image](images/08_Chapter_8_img026_381959f1.png)

- PCR\_TWAI0\_CLK\_EN Configures whether or not to enable TWAI0 APB clock.
- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_TWAI0\_RST\_EN Configures whether or not to reset TWAI0 module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.23. PCR\_TWAI0\_FUNC\_CLK\_CONF\_REG (0x0060)

![Image](images/08_Chapter_8_img027_a8998a6a.png)

- PCR\_TWAI0\_FUNC\_CLK\_SEL Configures to select clock source.
- 0 (default): Select XTAL\_CLK
- 1: Select RC\_FAST\_CLK
- (R/W)

## PCR\_TWAI0\_FUNC\_CLK\_EN Configures whether or not to enable TWAI0 function clock.

- 0: Not enable
- 1: Enable
- (R/W)

## Register 8.24. PCR\_TWAI1\_CONF\_REG (0x0064)

![Image](images/08_Chapter_8_img028_c5abe764.png)

- PCR\_TWAI1\_CLK\_EN Configures whether or not to enable TWAI1 APB clock.
- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_TWAI1\_RST\_EN Configures whether or not to reset TWAI1 module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.25. PCR\_TWAI1\_FUNC\_CLK\_CONF\_REG (0x0068)

![Image](images/08_Chapter_8_img029_b5766a08.png)

PCR\_TWAI1\_FUNC\_CLK\_SEL Configures to select clock source.

- 0 (default): Select XTAL\_CLK
- 1: Select RC\_FAST\_CLK
- (R/W)
- PCR\_TWAI1\_FUNC\_CLK\_EN Configures whether or not to enable TWAI1 function clock.
- 0: Not enable
- 1: Enable
- (R/W)

## Register 8.26. PCR\_I2S\_CONF\_REG (0x006C)

![Image](images/08_Chapter_8_img030_51ba60b0.png)

PCR\_I2S\_CLK\_EN Configures whether or not to enable I2S APB clock.

- 0: Not enable
- 1: Enable

(R/W)

- PCR\_I2S\_RST\_EN Configures whether or not to reset I2S module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.27. PCR\_I2S\_TX\_CLKM\_CONF\_REG (0x0070)

![Image](images/08_Chapter_8_img031_35616add.png)

PCR\_I2S\_TX\_CLKM\_DIV\_NUM Configures the integral part of I2S TX clock divider.

(R/W)

PCR\_I2S\_TX\_CLKM\_SEL Configures to select I2S TX module source clock.

- 0: Select XTAL\_CLK
- 1: Select PLL\_F240M\_CLK
- 2: Select PLL\_F160M\_CLK
- 3: Select I2S\_MCLK\_in (R/W)

PCR\_I2S\_TX\_CLKM\_EN Configures whether or not to enable I2S TX function clock.

- 0: Not enable
- 1: Enable

(R/W)

## Register 8.28. PCR\_I2S\_TX\_CLKM\_DIV\_CONF\_REG (0x0074)

![Image](images/08_Chapter_8_img032_c8d15a19.png)

PCR\_I2S\_TX\_CLKM\_DIV\_Z For b &lt;= a/2, the value of I2S\_TX\_CLKM\_DIV\_Z is b. For b &gt; a/2, the value of I2S\_TX\_CLKM\_DIV\_Z is (a - b). (R/W)

- PCR\_I2S\_TX\_CLKM\_DIV\_Y For b &lt;= a/2, the value of I2S\_TX\_CLKM\_DIV\_Y is (a%b). For b &gt; a/2, the value of I2S\_TX\_CLKM\_DIV\_Y is (a%(a - b)). (R/W)
- PCR\_I2S\_TX\_CLKM\_DIV\_X For b &lt;= a/2, the value of I2S\_TX\_CLKM\_DIV\_X is floor(a/b) - 1. For b &gt; a/2, the value of I2S\_TX\_CLKM\_DIV\_X is floor(a/(a - b)) - 1. (R/W)
- PCR\_I2S\_TX\_CLKM\_DIV\_YN1 For b &lt;= a/2, the value of I2S\_TX\_CLKM\_DIV\_YN1 is 0. For b &gt; a/2, the value of I2S\_TX\_CLKM\_DIV\_YN1 is 1. (R/W)

## Note:

"a" and "b" represent the denominator and the numerator of fractional divider, respectively. For more information, see Section 30.6 in Chapter I2S Controller (I2S) .

Register 8.29. PCR\_I2S\_RX\_CLKM\_CONF\_REG (0x0078)

![Image](images/08_Chapter_8_img033_cdf5f593.png)

PCR\_I2S\_RX\_CLKM\_DIV\_NUM Configures the integral part of I2S clock divider value. (R/W)

PCR\_I2S\_RX\_CLKM\_SEL Configures to select I2S RX module source clock.

0: Not select any clock

1: Select PLL\_F240M\_CLK

2: Select PLL\_F160M\_CLK

3: Select I2S\_MCLK\_in

(R/W)

PCR\_I2S\_RX\_CLKM\_EN Configures whether or not to enable I2S RX function clock.

0: Not enable

1: Enable

(R/W)

PCR\_I2S\_MCLK\_SEL Configures to select master clock.

```
0 (default): Select I2S_RX_CLK
```

1: Select I2S\_TX\_CLK

(R/W)

## Register 8.30. PCR\_I2S\_RX\_CLKM\_DIV\_CONF\_REG (0x007C)

![Image](images/08_Chapter_8_img034_da2db6f3.png)

- PCR\_I2S\_RX\_CLKM\_DIV\_Z For b &lt;= a/2, the value of I2S\_RX\_CLKM\_DIV\_Z is b. For b &gt; a/2, the value of I2S\_RX\_CLKM\_DIV\_Z is (a - b). (R/W)
- PCR\_I2S\_RX\_CLKM\_DIV\_Y For b &lt;= a/2, the value of I2S\_RX\_CLKM\_DIV\_Y is (a%b). For b &gt; a/2, the value of I2S\_RX\_CLKM\_DIV\_Y is (a%(a - b)). (R/W)
- PCR\_I2S\_RX\_CLKM\_DIV\_X For b &lt;= a/2, the value of I2S\_RX\_CLKM\_DIV\_X is floor(a/b) - 1. For b &gt; a/2, the value of I2S\_RX\_CLKM\_DIV\_X is floor(a/(a-b)) - 1. (R/W)
- PCR\_I2S\_RX\_CLKM\_DIV\_YN1 For b &lt;= a/2, the value of I2S\_RX\_CLKM\_DIV\_YN1 is 0. For b &gt; a/2, the value of I2S\_RX\_CLKM\_DIV\_YN1 is 1. (R/W)

## Note:

"a" and "b" represent the denominator and the numerator of fractional divider, respectively. For more information, see Section 30.6 .

Register 8.31. PCR\_SARADC\_CONF\_REG (0x0080)

![Image](images/08_Chapter_8_img035_ed043a79.png)

PCR\_SARADC\_RST\_EN Configures whether or not to reset function register of SAR ADC module.

- 0: Not reset
- 1: Reset

(R/W)

- PCR\_SARADC\_APB\_CLK\_EN Configures whether or not to enable SAR ADC APB clock.
- 0: Not enable
- 1: Enable

(R/W)

PCR\_SARADC\_APB\_RST\_EN Configures whether or not to reset APB register of SAR ADC module.

- 0: Not reset
- 1: Reset

(R/W)

Register 8.32. PCR\_SARADC\_CLKM\_CONF\_REG (0x0084)

![Image](images/08_Chapter_8_img036_669320fa.png)

PCR\_SARADC\_CLKM\_DIV\_A Configures the denominator of the frequency divider factor for SAR ADC function clock.

(R/W)

- PCR\_SARADC\_CLKM\_DIV\_B Configures the numerator of the frequency divider factor for SAR ADC function clock. (R/W)
- PCR\_SARADC\_CLKM\_DIV\_NUM Configures the integral part of the frequency divider factor for SAR

ADC function clock.

(R/W)

PCR\_SARADC\_CLKM\_SEL Configures to select clock source.

- 0 (default): Select XTAL\_CLK
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Reserved

(R/W)

PCR\_SARADC\_CLKM\_EN Configures whether or not to enable SAR ADC function clock.

- 0: Not enable
- 1: Enable

(R/W)

## Register 8.33. PCR\_TSENS\_CLK\_CONF\_REG (0x0088)

![Image](images/08_Chapter_8_img037_a2fef4a0.png)

PCR\_TSENS\_CLK\_SEL Configures to select clock source.

- 0 (default): Select RC\_FAST\_CLK
- 1: Select XTAL\_CLK
- (R/W)
- PCR\_TSENS\_CLK\_EN Configures whether or not to enable TSENS clock.
- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_TSENS\_RST\_EN Configures whether or not to reset TSENS module.
- 0: Not reset
- 1: Reset
- (R/W)

Register 8.34. PCR\_USB\_SERIAL\_JTAG\_CONF\_REG (0x008C)

![Image](images/08_Chapter_8_img038_46e2a139.png)

PCR\_USB\_SERIAL\_JTAG\_CLK\_EN Configures whether or not to enable USB\_SERIAL\_JTAG clock.

- 0: Not enable
- 1: Enable

(R/W)

PCR\_USB\_SERIAL\_JTAG\_RST\_EN Configures whether or not to reset USB\_SERIAL\_JTAG module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.35. PCR\_INTMTX\_CONF\_REG (0x0090)

![Image](images/08_Chapter_8_img039_9771ecb9.png)

PCR\_INTMTX\_CLK\_EN Configures whether or not to enable Interrupt Matrix clock.

- 0: Not enable
- 1: Enable
- (R/W)

PCR\_INTMTX\_RST\_EN Configures whether or not to reset Interrupt Matrix module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.36. PCR\_PCNT\_CONF\_REG (0x0094)

![Image](images/08_Chapter_8_img040_7693068d.png)

PCR\_PCNT\_CLK\_EN Configures whether or not to enable PCNT clock.

- 0: Not enable
- 1: Enable
- (R/W)

PCR\_PCNT\_RST\_EN Configures whether or not to reset PCNT module.

- 0: Not reset
- 1: Reset
- (R/W)

## Register 8.37. PCR\_ETM\_CONF\_REG (0x0098)

![Image](images/08_Chapter_8_img041_39134c5f.png)

- PCR\_ETM\_CLK\_EN Configures whether or not to enable ETM clock.
- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_ETM\_RST\_EN Configures whether or not to reset ETM module.
- 0: Not reset
- 1: Reset
- (R/W)

## Register 8.38. PCR\_PWM\_CONF\_REG (0x009C)

![Image](images/08_Chapter_8_img042_eaac7639.png)

- PCR\_PWM\_CLK\_EN Configures whether or not to enable PWM clock.
- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_PWM\_RST\_EN Configures whether or not to reset PWM module.
- 0: Not reset
- 1: Reset
- (R/W)

## Register 8.39. PCR\_PWM\_CLK\_CONF\_REG (0x00A0)

![Image](images/08_Chapter_8_img043_cd5e8f21.png)

PCR\_PWM\_DIV\_NUM Configures the integral part of the frequency divider factor for PWM function clock.

(R/W)

## PCR\_PWM\_CLKM\_SEL Configures to select clock source.

- 0 (default): Not select any clock
- 1: Select PLL\_F160M\_CLK
- 2: Select XTAL\_CLK
- 3: Select RC\_FAST\_CLK

(R/W)

## PCR\_PWM\_CLKM\_EN Configures whether or not to activate PWM\_CLKM.

- 0: Not activate
- 1: Activate

(R/W)

## Register 8.40. PCR\_PARL\_IO\_CONF\_REG (0x00A4)

![Image](images/08_Chapter_8_img044_46a9c9bc.png)

PCR\_PARL\_CLK\_EN Configures whether or not to enable PARL APB clock.

- 0: Not enable
- 1: Enable

(R/W)

## PCR\_PARL\_RST\_EN Configures whether or not to reset PARL APB register.

- 0: Not reset
- 1: Reset

(R/W)

Register 8.41. PCR\_PARL\_CLK\_RX\_CONF\_REG (0x00A8)

![Image](images/08_Chapter_8_img045_a546315c.png)

PCR\_PARL\_CLK\_RX\_DIV\_NUM Configures the integral part of the frequency divider factor for PARL RX clock.

(R/W)

## PCR\_PARL\_CLK\_RX\_SEL Configures to select clock source.

- 0 (default): Select XTAL
- 1: Select PLL\_F240M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Use the clock from chip pin (R/W)
- PCR\_PARL\_CLK\_RX\_EN Configures whether or not to enable PARL RX clock.
- 0: Not enable
- 1: Enable

(R/W)

## PCR\_PARL\_RX\_RST\_EN Configures whether or not to reset PARL RX module.

- 0: Not reset
- 1: Reset

(R/W)

Register 8.42. PCR\_PARL\_CLK\_TX\_CONF\_REG (0x00AC)

![Image](images/08_Chapter_8_img046_da5ae77c.png)

PCR\_PARL\_CLK\_TX\_DIV\_NUM Configures the integral part of the frequency divider factor for PARL

TX clock.

(R/W)

## PCR\_PARL\_CLK\_TX\_SEL Configures to select clock source.

- 0 (default): Select XTAL
- 1: Select PLL\_F240M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Use the clock from chip pin

(R/W)

PCR\_PARL\_CLK\_TX\_EN Configures whether or not to enable PARL TX clock.

- 0: Not enable
- 1: Enable

(R/W)

## PCR\_PARL\_TX\_RST\_EN Configures whether or not to reset PARL TX module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.43. PCR\_SDIO\_SLAVE\_CONF\_REG (0x00B0)

![Image](images/08_Chapter_8_img047_ffb3150f.png)

PCR\_SDIO\_SLAVE\_CLK\_EN Configures whether or not to enable SDIO slave clock.

- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_SDIO\_SLAVE\_RST\_EN Configures whether or not to reset SDIO slave module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.44. PCR\_GDMA\_CONF\_REG (0x00BC)

![Image](images/08_Chapter_8_img048_834c3d8e.png)

PCR\_GDMA\_CLK\_EN Configures whether or not to enable GDMA clock.

- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_GDMA\_RST\_EN Configures whether or not to reset GDMA module.
- 0: Not reset
- 1: Reset
- (R/W)

## Register 8.45. PCR\_SPI2\_CONF\_REG (0x00C0)

![Image](images/08_Chapter_8_img049_418349fd.png)

PCR\_SPI2\_CLK\_EN Configures whether or not to enable SPI2 APB clock.

- 0: Not enable
- 1: Enable
- (R/W)

PCR\_SPI2\_RST\_EN Configures whether or not to reset SPI2 module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.46. PCR\_SPI2\_CLKM\_CONF\_REG (0x00C4)

![Image](images/08_Chapter_8_img050_81d88801.png)

PCR\_SPI2\_CLKM\_SEL Configures to select clock source.

- 0 (default): Select XTAL\_CLK
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: Reserved

(R/W)

PCR\_SPI2\_CLKM\_EN Configures whether or not to enable SPI2 function clock.

- 0: Not enable
- 1: Enable

(R/W)

## Register 8.47. PCR\_AES\_CONF\_REG (0x00C8)

![Image](images/08_Chapter_8_img051_2775460c.png)

PCR\_AES\_CLK\_EN Configures whether or not to enable AES clock.

- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_AES\_RST\_EN Configures whether or not to reset AES module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.48. PCR\_SHA\_CONF\_REG (0x00CC)

![Image](images/08_Chapter_8_img052_898b1cb5.png)

PCR\_SHA\_CLK\_EN Configures whether or not to enable SHA clock.

- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_SHA\_RST\_EN Configures whether or not to reset SHA module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.49. PCR\_RSA\_CONF\_REG (0x00D0)

![Image](images/08_Chapter_8_img053_c5d850eb.png)

- PCR\_RSA\_CLK\_EN Configures whether or not to enable RSA clock.
- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_RSA\_RST\_EN Configures whether or not to reset RSA module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.50. PCR\_RSA\_PD\_CTRL\_REG (0x00D4)

![Image](images/08_Chapter_8_img054_91448e17.png)

PCR\_RSA\_MEM\_PD Configures whether or not to power down RSA internal memory.

- 0: Not power down
- 1: Power down
- (R/W)
- PCR\_RSA\_MEM\_FORCE\_PU Configures whether or not to force power up RSA internal memory.
- 0: Not force power up
- 1: Force power up
- (R/W)
- PCR\_RSA\_MEM\_FORCE\_PD Configures whether or not to force power down RSA internal memory.
- 0: Not force power down
- 1: Force power down
- (R/W)

## Register 8.51. PCR\_ECC\_CONF\_REG (0x00D8)

![Image](images/08_Chapter_8_img055_f05ddcf4.png)

- PCR\_ECC\_CLK\_EN Configures whether or not to enable ECC clock.
- 0: Not enable
- 1: Enable
- (R/W)
- PCR\_ECC\_RST\_EN Configures whether or not to reset ECC module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.52. PCR\_ECC\_PD\_CTRL\_REG (0x00DC)

![Image](images/08_Chapter_8_img056_f0511069.png)

PCR\_ECC\_MEM\_PD Configures whether or not to power down ECC internal memory.

- 0: Not power down
- 1: Power down
- (R/W)
- PCR\_ECC\_MEM\_FORCE\_PU Configures whether or not to force power up ECC internal memory.
- 0: Not force power up
- 1: Force power up
- (R/W)
- PCR\_ECC\_MEM\_FORCE\_PD Configures whether or not to force power down ECC internal memory.
- 0: Not force power down
- 1: Force power down
- (R/W)

## Register 8.53. PCR\_DS\_CONF\_REG (0x00E0)

![Image](images/08_Chapter_8_img057_314054f5.png)

PCR\_DS\_CLK\_EN Configures whether or not to enable DS clock.

- 0: Not enable
- 1: Enable

(R/W)

- PCR\_DS\_RST\_EN Configures whether or not to reset DS module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.54. PCR\_HMAC\_CONF\_REG (0x00E4)

![Image](images/08_Chapter_8_img058_2b64a054.png)

PCR\_HMAC\_CLK\_EN Configures whether or not to enable HMAC clock.

- 0: Not enable
- 1: Enable

(R/W)

- PCR\_HMAC\_RST\_EN Configures whether or not to reset HMAC module.
- 0: Not reset
- 1: Reset

(R/W)

## Register 8.55. PCR\_IOMUX\_CONF\_REG (0x00E8)

![Image](images/08_Chapter_8_img059_31c8d8a1.png)

PCR\_IOMUX\_CLK\_EN Configures whether or not to enable IO MUX APB clock.

- 0: Not enable
- 1: Enable
- (R/W)

PCR\_IOMUX\_RST\_EN Configures whether or not to reset IO MUX module.

- 0: Not reset
- 1: Reset
- (R/W)

## Register 8.56. PCR\_IOMUX\_CLK\_CONF\_REG (0x00EC)

![Image](images/08_Chapter_8_img060_0da25800.png)

## PCR\_IOMUX\_FUNC\_CLK\_SEL Configures to select clock source.

- 0: Not select any clock
- 1: Select PLL\_F80M\_CLK
- 2: Select RC\_FAST\_CLK
- 3: XTAL\_CLK
- (R/W)

PCR\_IOMUX\_FUNC\_CLK\_EN Configures whether or not to enable IO MUX function clock.

- 0: Not enable
- 1: Enable
- (R/W)

## Register 8.57. PCR\_MEM\_MONITOR\_CONF\_REG (0x00F0)

![Image](images/08_Chapter_8_img061_717ab7b0.png)

PCR\_MEM\_MONITOR\_CLK\_EN Configures whether or not to enable MEM\_MONITOR clock.

- 0: Not enable
- 1: Enable
- (R/W)

PCR\_MEM\_MONITOR\_RST\_EN Configures whether or not to reset MEM\_MONITOR module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.58. PCR\_TRACE\_CONF\_REG (0x00FC)

![Image](images/08_Chapter_8_img062_396fdd2f.png)

PCR\_TRACE\_CLK\_EN Configures whether or not to enable TRACE clock.

- 0: Not enable
- 1: Enable
- (R/W)

PCR\_TRACE\_RST\_EN Configures whether or not to reset TRACE module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.59. PCR\_ASSIST\_CONF\_REG (0x0100)

![Image](images/08_Chapter_8_img063_47512dfa.png)

PCR\_ASSIST\_CLK\_EN Configures whether or not to enable ASSIST clock.

- 0: Not enable
- 1: Enable

(R/W)

PCR\_ASSIST\_RST\_EN Configures whether or not to reset ASSIST module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.60. PCR\_CACHE\_CONF\_REG (0x0104)

![Image](images/08_Chapter_8_img064_6ffcf4f7.png)

PCR\_CACHE\_CLK\_EN Configures whether or not to enable CACHE clock.

- 0: Not enable
- 1: Enable
- (R/W)

PCR\_CACHE\_RST\_EN Configures whether or not to reset CACHE module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.61. PCR\_MODEM\_APB\_CONF\_REG (0x0108)

![Image](images/08_Chapter_8_img065_aaa7e5bf.png)

PCR\_MODEM\_APB\_CLK\_EN Configures whether or not to enable MODEM\_APB clock.

- 0: Disable
- 1: Enable
- (R/W)
- PCR\_MODEM\_RST\_EN Configures whether or not to reset modem subsystem.
- 0: Not reset
- 1: Reset

(R/W)

Register 8.62. PCR\_TIMEOUT\_CONF\_REG (0x010C)

![Image](images/08_Chapter_8_img066_c4daf767.png)

PCR\_CPU\_TIMEOUT\_RST\_EN Configures whether or not to reset CPU\_PERI TIMEOUT module.

- 0: Not reset
- 1: Reset

(R/W)

PCR\_HP\_TIMEOUT\_RST\_EN Configures whether or not to reset HP\_PERI TIMEOUT module and HP\_MODEM TIMEOUT module.

- 0: Not reset
- 1: Reset

(R/W)

## Register 8.63. PCR\_SYSCLK\_CONF\_REG (0x0110)

![Image](images/08_Chapter_8_img067_a5577b5e.png)

PCR\_LS\_DIV\_NUM Represents HP\_ROOT\_CLK is derived from a low-speed clock source (such as

XTAL/FOSC) divided by 1.

(HRO)

PCR\_HS\_DIV\_NUM Represents HP\_ROOT\_CLK is derived from a high-speed clock source (such as

SPLL) divided by 3.

(HRO)

## PCR\_SOC\_CLK\_SEL Configures to select clock source.

0: Select XTAL\_CLK

1: Select PLL\_CLK

2: Select RC\_FAST\_CLK

3: Reserved

(R/W)

- PCR\_CLK\_XTAL\_FREQ Represents the frequency of XTAL.

Measurement unit: MHz

(RO)

Register 8.64. PCR\_CPU\_WAITI\_CONF\_REG (0x0114)

![Image](images/08_Chapter_8_img068_1654b014.png)

PCR\_CPU\_WAIT\_MODE\_FORCE\_ON Configures whether or not to force enable cpu\_waiti\_clk.

- 0: Not force enable

1: Force enable

(R/W)

PCR\_CPU\_WAITI\_DELAY\_NUM Configures delay cycle when CPU enters WAITI mode.

After delay, waiti\_clk will close.

(R/W)

## Register 8.65. PCR\_CPU\_FREQ\_CONF\_REG (0x0118)

![Image](images/08_Chapter_8_img069_c29a2d0c.png)

PCR\_CPU\_LS\_DIV\_NUM Configures the divider of HP\_ROOT\_CLK to generate CPU\_CLK.

0 (default): The HP\_ROOT\_CLK is divided by 1 to generate CPU\_CLK

- 1: The HP\_ROOT\_CLK is divided by 2 to generate CPU\_CLK
- 3: The HP\_ROOT\_CLK is divided by 4 to generate CPU\_CLK

This field is only available when a low-speed clock source such as XTAL/FOSC is selected, and should be used together with PCR\_AHB\_LS\_DIV\_NUM. (R/W)

PCR\_CPU\_HS\_DIV\_NUM Configures the divider of HP\_ROOT\_CLK to generate CPU\_CLK.

0 (default): The HP\_ROOT\_CLK is divided by 1 to generate CPU\_CLK

- 1: The HP\_ROOT\_CLK is divided by 2 to generate CPU\_CLK

3: The HP\_ROOT\_CLK is divided by 4 to generate CPU\_CLK

This field is only available when a high-speed clock source such as SPLL is selected, and should be used together with PCR\_AHB\_HS\_DIV\_NUM. (R/W)

PCR\_CPU\_HS\_120M\_FORCE Configures whether or not to force CPU\_CLK at 120 MHz when

PCR\_CPU\_HS\_DIV\_NUM is 0.

0: Not force CPU\_CLK at 120 MHz

1: Force CPU\_CLK at 120 MHz

This bit is only available when PCR\_CPU\_HS\_DIV\_NUM is 0 and CPU\_CLK is derived from SPLL. (R/W)

Register 8.66. PCR\_AHB\_FREQ\_CONF\_REG (0x011C)

![Image](images/08_Chapter_8_img070_a2b0dbee.png)

PCR\_AHB\_LS\_DIV\_NUM Configures the divider of HP\_ROOT\_CLK to generate AHB\_CLK.

0 (default): HP\_ROOT\_CLK is divided by 1 to generate AHB\_CLK

1: HP\_ROOT\_CLK is divided by 2 to generate AHB\_CLK

3: HP\_ROOT\_CLK is divided by 4 to generate AHB\_CLK

7: HP\_ROOT\_CLK is divided by 8 to generate AHB\_CLK

This field is only available when a low-speed clock source such as XTAL/FOSC is selected, and should be used together with PCR\_CPU\_LS\_DIV\_NUM.

(R/W)

PCR\_AHB\_HS\_DIV\_NUM Configure the divider of HP\_ROOT\_CLK to generate AHB\_CLK.

3 (default): HP\_ROOT\_CLK is divided by 4 to generate AHB\_CLK

7: HP\_ROOT\_CLK is divided by 8 to generate AHB\_CLK

15: HP\_ROOT\_CLK is divided by 16 to generate AHB\_CLK

This field is only available when a high-speed clock source such as SPLL is selected, and should be used together with PCR\_CPU\_HS\_DIV\_NUM. (R/W)

## Register 8.67. PCR\_APB\_FREQ\_CONF\_REG (0x0120)

![Image](images/08_Chapter_8_img071_29889898.png)

PCR\_APB\_DECREASE\_DIV\_NUM Configures the divider of APB\_CLK to generate APB\_DECREASE\_CLK.

- 0: APB\_CLK is divided by 1 to generate APB\_DECREASE\_CLK
- 1: APB\_CLK is divided by 2 to generate APB\_DECREASE\_CLK
- 3 (default): APB\_CLK is divided by 4 to generate APB\_DECREASE\_CLK

If the value of this field is greater than PCR\_APB\_DIV\_NUM, APB\_CLK will be automatically down to APB\_DECREASE\_CLK only when no access is on APB bus, and will recover to the previous frequency when a new access appears on APB bus. Note that enabling this function will reduce performance. Users can set this field as zero to disable the auto-decrease-APB-freq function. By default, this function is disabled.

(R/W)

PCR\_APB\_DIV\_NUM Configures the divider of AHB\_CLK to generate APB\_CLK.

- 0 (default): AHB\_CLK is divided by 1 to generate APB\_CLK
- 1: AHB\_CLK is divided by 2 to generate APB\_CLK
- 3: AHB\_CLK is divided by 4 to generate APB\_CLK (R/W)

## Register 8.68. PCR\_PLL\_DIV\_CLK\_EN\_REG (0x0128)

![Image](images/08_Chapter_8_img072_138d664d.png)

- PCR\_PLL\_240M\_CLK\_EN Configures whether or not to enable 240 MHz clock derived from SPLL

divided by 2.

- 0: Not enable
- 1 (default): Enable
- Only available when high-speed clock source SPLL is active.
- (R/W)
- PCR\_PLL\_160M\_CLK\_EN Configures whether or not to enable 160 MHz clock derived from SPLL

divided by 3.

- 0: Not enable
- 1 (default): Enable

Only available when high-speed clock source SPLL is active.

(R/W)

- PCR\_PLL\_120M\_CLK\_EN Configures whether or not to enable 120 MHz clock derived from SPLL divided by 4.
- 0: Not enable
- 1 (default): Enable

Only available when high-speed clock source SPLL is active.

- (R/W)
- PCR\_PLL\_80M\_CLK\_EN Configures whether or not to enable 80 MHz clock derived from SPLL

divided by 6.

- 0: Not enable
- 1 (default): Enable
- Only available when high-speed clock source SPLL is active.
- (R/W)
- PCR\_PLL\_48M\_CLK\_EN Configures whether or not to enable 48 MHz clock derived from SPLL

divided by 10.

- 0: Not enable
- 1 (default): Enable

Only available when high-speed clock source SPLL is active.

(R/W)

Continued on the next page...

## Register 8.68. PCR\_PLL\_DIV\_CLK\_EN\_REG (0x0128)

## Continued from the previous page...

PCR\_PLL\_40M\_CLK\_EN Configures whether or not to enable 40 MHz clock derived from SPLL

divided by 12.

0: Not enable

- 1 (default): Enable

Only available when high-speed clock source SPLL is active.

(R/W)

- PCR\_PLL\_20M\_CLK\_EN Configures whether or not to enable 20 MHz clock derived from SPLL divided by 24.

0: Not enable

- 1 (default): Enable

Only available when high-speed clock source SPLL is active.

(R/W)

## Register 8.69. PCR\_CTRL\_TICK\_CONF\_REG (0x0130)

![Image](images/08_Chapter_8_img073_57ef9e19.png)

PCR\_FOSC\_TICK\_NUM Configures the clock divisor for RC\_FAST\_CLK before it enters the calibration module. (R/W)

## Register 8.70. PCR\_CTRL\_32K\_CONF\_REG (0x0134)

![Image](images/08_Chapter_8_img074_6a4d3142.png)

PCR\_32K\_SEL Configures to select one 32 kHz clock for MODEM\_SYSTEM and TIMER\_GROUP.

- 0: Invalid

1: Select XTAL32K\_CLK

2/3: Select OSC\_SLOW\_CLK from GPIO0

(R/W)

Register 8.71. PCR\_SRAM\_POWER\_CONF\_REG (0x0138)

![Image](images/08_Chapter_8_img075_9604b295.png)

PCR\_SRAM\_FORCE\_PU Configures whether or not to force power up SRAM.

- 0: Not force power up
- 1: Force power up

(R/W)

PCR\_SRAM\_FORCE\_PD Configures whether or not to force power down SRAM.

- 0: Not force power down
- 1: Force power down

(R/W)

- PCR\_SRAM\_CLKGATE\_FORCE\_ON Configures whether or not to force open the clock and bypass

the gate-clock when accessing the SRAM.

- 0: A gate-clock will be used when accessing the SRAM.
- 1: Force to open the clock and bypass the gate-clock when accessing the SRAM.

(R/W)

- PCR\_ROM\_FORCE\_PU Configures whether or not to force power up ROM.
- 0: Not force power up
- 1: Force power up

(R/W)

PCR\_ROM\_FORCE\_PD Configures whether or not to force power down ROM.

- 0: Not force power down
- 1: Force power down

(R/W)

- PCR\_ROM\_CLKGATE\_FORCE\_ON Configures whether or not to force open the clock and bypass the gate-clock when accessing the ROM.
- 0: A gate-clock will be used when accessing the ROM.
- 1: Force to open the clock and bypass the gate-clock when accessing the ROM.

(R/W)

Register 8.72. PCR\_RESET\_EVENT\_BYPASS\_REG (0x0FF0)

![Image](images/08_Chapter_8_img076_f7ce8f3d.png)

PCR\_RESET\_EVENT\_BYPASS\_APM Configures to control reset event relationship for tee\_reg/apm\_reg/hp\_system\_reg.

- 0: tee\_reg/apm\_reg/hp\_system\_reg will not only be reset by power-reset, but also some reset events.
- 1: tee\_reg/apm\_reg/hp\_system\_reg will only be reset by power-reset. Some reset events will be bypassed.

(R/W)

- PCR\_RESET\_EVENT\_BYPASS Configures to control reset event relationship for system-bus.
- 0: System bus (including arbiter/router) will not only be reset by power-reset, but also some reset events.
- 1: System bus (including arbiter/router) will only be reset by power-reset. Some reset events will be bypassed.

(R/W)

Register 8.73. PCR\_SYSCLK\_FREQ\_QUERY\_0\_REG (0x0124)

![Image](images/08_Chapter_8_img077_f91c77de.png)

PCR\_FOSC\_FREQ Represents the frequency of RC\_FAST\_CLK.

Measurement unit: MHz

(HRO)

PCR\_PLL\_FREQ Represents the frequency of PLL\_CLK.

Measurement unit: MHz

(HRO)

## Register 8.74. PCR\_DATE\_REG (0x0FFC)

![Image](images/08_Chapter_8_img078_55f9f16f.png)

## 8.5.2 LP Registers

The addresses in this section are relative to the Low-power Clock/Reset Register (LP\_CLKRST) base address. For base address, please refer to Table 5.3-2 in Chapter 5 System and Memory .

Register 8.75. LP\_CLKRST\_LP\_CLK\_CONF\_REG (0x0000)

![Image](images/08_Chapter_8_img079_af16cbe9.png)

- LP\_CLKRST\_SLOW\_CLK\_SEL Configures the source of LP\_SLOW\_CLK.
- 0: RC\_SLOW\_CLK
- 1: XTAL32K\_CLK
- 2: OSC\_SLOW\_CLK
- 3: Invalid
- (R/W)
- LP\_CLKRST\_FAST\_CLK\_SEL configures the source of LP\_FAST\_CLK.
- 0: RC\_FAST\_CLK
- 1: XTAL\_D2\_CLK
- (R/W)

## Register 8.76. LP\_CLKRST\_LP\_CLK\_PO\_EN\_REG (0x0004)

![Image](images/08_Chapter_8_img080_df4a0a63.png)

- LP\_CLKRST\_AON\_SLOW\_OEN Configures the clock gate to pad of the LP\_DYN\_SLOW\_CLK.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate (R/W)
- LP\_CLKRST\_AON\_FAST\_OEN Configures the clock gate to pad of the LP\_DYN\_FAST\_CLK.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate

(R/W)

- LP\_CLKRST\_SOSC\_OEN Configures the clock gate to pad of the OSC\_SLOW\_CLK.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate

(R/W)

- LP\_CLKRST\_FOSC\_OEN Configures the clock gate to pad of the RC\_FAST\_CLK.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate (R/W)
- LP\_CLKRST\_XTAL32K\_OEN Configures the clock gate to pad of the XTAL32K\_CLK.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate (R/W)

Continued on the next page...

## Register 8.76. LP\_CLKRST\_LP\_CLK\_PO\_EN\_REG (0x0004)

## Continued from the previous page...

- LP\_CLKRST\_CORE\_EFUSE\_OEN Configures the clock gate to pad of the EFUSE\_CTRL clock.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate

(R/W)

- LP\_CLKRST\_SLOW\_OEN Configures the clock gate to pad of the LP\_SLOW\_CLK.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate

(R/W)

- LP\_CLKRST\_FAST\_OEN Configures the clock gate to pad of the LP\_FAST\_CLK.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate

(R/W)

- LP\_CLKRST\_RNG\_OEN Configures the clock gate to pad of the RNG clk.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate

(R/W)

- LP\_CLKRST\_LPBUS\_OEN Configures the clock gate to pad of the LP bus clk.
- 0: Disable the clk pass clock gate
- 1: Enable the clk pass clock gate

(R/W)

## Register 8.77. LP\_CLKRST\_LP\_CLK\_EN\_REG (0x0008)

![Image](images/08_Chapter_8_img081_ef921c50.png)

- LP\_CLKRST\_FAST\_ORI\_GATE Configures the clock gate to LP\_FAST\_CLK
- 0: Invalid. The clock gate controlled by hardware fsm
- 1: Force the clk pass clock gate

(R/W)

## Register 8.78. LP\_CLKRST\_LP\_RST\_EN\_REG (0x000C)

![Image](images/08_Chapter_8_img082_f34d53fa.png)

- LP\_CLKRST\_AON\_EFUSE\_CORE\_RESET\_EN Configures whether or not to reset EFUSE\_CTRL

always-on part

0: Invalid.No effect

1: Reset

(R/W)

- LP\_CLKRST\_RTC\_TIMER\_RESET\_EN Configures whether or not to reset RTC\_TIMER

0: Invalid.No effect

1: Reset

(R/W)

- LP\_CLKRST\_WDT\_RESET\_EN Configures whether or not to reset RTC\_WDT and super watch dog

0: Invalid.No effect

1: Reset

(R/W)

- LP\_CLKRST\_ANA\_PERI\_RESET\_EN Configures whether or not to reset analog peri, include

brownout controller

0: Invalid.No effect

1: Reset

(R/W)

## Register 8.79. LP\_CLKRST\_RESET\_CAUSE\_REG (0x0010)

![Image](images/08_Chapter_8_img083_691b9322.png)

RTC\_CLKRST\_RESET\_CAUSE Represents the reset cause.

(RO)

LP\_CLKRST\_CORE0\_RESET\_CAUSE\_CLR Configures whether or not to trigger the reset cause to

0x0

0: Invalid. No effect

1: Trigger the reset cause to 0x0 (WT)

## Register 8.80. LP\_CLKRST\_CPU\_RESET\_REG (0x0014)

![Image](images/08_Chapter_8_img084_0af169e2.png)

## LP\_CLKRST\_RTC\_WDT\_CPU\_RESET\_LENGTH configures the reset length of RTC\_WDT reset CPU

- Measurement unit: LP\_DYN\_FAST\_CLK

(R/W)

- LP\_CLKRST\_RTC\_WDT\_CPU\_RESET\_EN Configures whether or not RTC\_WDT can reset CPU
- 0: RTC\_WDT could not reset CPU when RTC\_WDT timeout
- 1: RTC\_WDT could reset CPU when RTC\_WDT timeout (R/W)
- LP\_CLKRST\_CPU\_STALL\_WAIT configure the time between CPU stall and reset Measurement unit: LP\_DYN\_FAST\_CLK (R/W)
- LP\_CLKRST\_CPU\_STALL\_EN Configures whether or not CPU entry stall state before RTC\_WDT and software reset CPU
- 0: CPU will not entry stall state before RTC\_WDT and software reset CPU
- 1: CPU will entry stall state before RTC\_WDT and software reset CPU

(R/W)

## Register 8.81. LP\_CLKRST\_FOSC\_CNTL\_REG (0x0018)

![Image](images/08_Chapter_8_img085_8585f32f.png)

- LP\_CLKRST\_FOSC\_DFREQ Configures the RC\_FAST\_CLK frequency, the clock frequency will increase with this field.

(R/W)

## Register 8.82. LP\_CLKRST\_CLK\_TO\_HP\_REG (0x0020)

![Image](images/08_Chapter_8_img086_6e1edfde.png)

- LP\_CLKRST\_ICG\_HP\_XTAL32K Configures the clk gate of XTAL32K\_CLK to HP system
- 0: The clk could not pass to HP system
- 1: The clk could pass to HP system

(R/W)

- LP\_CLKRST\_ICG\_HP\_SOSC Configures the clk gate of RC\_SLOW\_CLK to HP system
- 0: The clk could not pass to HP system
- 1: The clk could pass to HP system
- (R/W)
- LP\_CLKRST\_ICG\_HP\_FOSC Configures the clk gate of RC\_FAST\_CLK to HP system
- 0: The clk could not pass to HP system
- 1: The clk could pass to HP system

(R/W)

## Register 8.83. LP\_CLKRST\_LPMEM\_FORCE\_REG (0x0024)

![Image](images/08_Chapter_8_img087_b720f89c.png)

- LP\_CLKRST\_LPMEM\_CLK\_FORCE\_ON Configures whether ot not force open the clock gate of LP

MEM

- 0: Invalid. The clock gate controlled by hardware FSM
- 1: Force open clock gate of LP MEM

(R/W)

Register 8.84. LP\_CLKRST\_LPPERI\_REG (0x0028)

![Image](images/08_Chapter_8_img088_c6f74f60.png)

- LP\_CLKRST\_LP\_I2C\_CLK\_SEL Configures the source clk of LP I2C.
- 0: LP\_FAST\_CLK
- 1: XTAL\_D2\_CLK

(R/W)

- LP\_CLKRST\_LP\_UART\_CLK\_SEL Configures the source clk of LP UART.
- 0: LP\_FAST\_CLK
- 1: XTAL\_D2\_CLK

(R/W)

## Register 8.85. LP\_CLKRST\_XTAL32K\_REG (0x002C)

![Image](images/08_Chapter_8_img089_a8772faf.png)

- LP\_CLKRST\_DRES\_XTAL32K Configures DRES.
- (R/W)
- LP\_CLKRST\_DGM\_XTAL32K Configures DGM.

(R/W)

- LP\_CLKRST\_DBUF\_XTAL32K Configures DBUF. (R/W)
- LP\_CLKRST\_DAC\_XTAL32K Configures DAC.

(R/W)

Register 8.86. LP\_CLKRST\_DATE\_REG (0x03FC)

![Image](images/08_Chapter_8_img090_61f3e6e5.png)
