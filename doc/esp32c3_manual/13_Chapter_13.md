---
chapter: 13
title: "Chapter 13"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 13

## XTAL32K Watchdog Timers (XTWDT)

## 13.1 Overview

The XTAL32K watchdog timer on ESP32-C3 is used to monitor the status of external crystal XTAL32K\_CLK. This watchdog timer can detect the oscillation failure of XTAL32K\_CLK, change the clock source of RTC, etc. When XTAL32K\_CLK works as the clock source of RTC\_SLOW\_CLK (for clock description, see Chapter 6 Reset and Clock) and stops vibrating, the XTAL32K watchdog timer first switches to BACKUP32K\_CLK derived from RC\_SLOW\_CLK and generates an interrupt (if the chip is in Light-sleep and Deep-sleep mode, the CPU will be woken up), and then switches back to XTAL32K\_CLK after it is restarted by software.

Figure 13.1-1. XTAL32K Watchdog Timer

![Image](images/13_Chapter_13_img001_ad8d4662.png)

## 13.2 Features

## 13.2.1 Interrupt and Wake-Up

When the XTAL32K watchdog timer detects the oscillation failure of XTAL32K\_CLK, an oscillation failure interrupt RTC\_XTAL32K\_DEAD\_INT (for interrupt description, please refer to Chapter 9 Low-power Management) is generated. At this point, the CPU will be woken up if in Light-sleep and Deep-sleep mode.

## 13.2.2 BACKUP32K\_CLK

Once the XTAL32K watchdog timer detects the oscillation failure of XTAL32K\_CLK, it replaces XTAL32K\_CLK with BACKUP32K\_CLK (with a frequency of 32 kHz or so) derived from RC\_SLOW\_CLK as RTC\_SLOW\_CLK, so as to ensure proper functioning of the system.

## 13.3 Functional Description

## 13.3.1 Workflow

1. The XTAL32K watchdog timer starts counting when RTC\_CNTL\_XTAL32K\_WDT\_EN is enabled. The counter based on RC\_SLOW\_CLK keeps counting until it detects the positive edge of XTAL\_32K and is then cleared. When the counter reaches RTC\_CNTL\_XTAL32K\_WDT\_TIMEOUT, it generates an interrupt or a wake-up signal and is then reset.
2. If RTC\_CNTL\_XTAL32K\_AUTO\_BACKUP is set and step 1 is finished, the XTAL32K watchdog timer will automatically enable BACKUP32K\_CLK as the alternative clock source of RTC\_SLOW\_CLK, to ensure the system's proper functioning and the accuracy of timers running on RTC\_SLOW\_CLK (e.g. RTC\_TIMER). For information about clock frequency configuration, please refer to Section 13.3.2 .
3. Software restarts XTAL32K\_CLK by turning its XPD (meaning no power-down) signal off and on again via the RTC\_CNTL\_XPD\_XTAL\_32K bit. Then, the XTAL32K watchdog timer switches back to XTAL32K\_CLK as the clock source of RTC\_SLOW\_CLK by clearing RTC\_CNTL\_XTAL32K\_WDT\_EN (BACKUP32K\_CLK\_EN is also automatically cleared). If the chip is in Light-sleep and Deep-sleep mode, the XTAL32K watchdog timer will wake up the CPU to finish the above steps.

## 13.3.2 BACKUP32K\_CLK Working Principle

Chips have different RC\_SLOW\_CLK frequencies due to production process variations. To ensure the accuracy of RTC\_TIMER and other timers running on RTC\_SLOW\_CLK when BACKUP32K\_CLK is at work, the divisor of BACKUP32K\_CLK should be configured according to the actual frequency of RC\_SLOW\_CLK (see details in Chapter 9 Low-power Management) via the RTC\_CNTL\_XTAL32K\_CLK\_FACTOR\_REG register. Each byte in this register corresponds to a divisor component (x0 ~ x7 ). BACKUP32K\_CLK is divided by a fraction where the denominator is always 4, as calculated below.

<!-- formula-not-decoded -->

f\_back\_clk is the desired frequency of BACKUP32K\_CLK, i.e. 32.768 kHz; f\_rc\_slow\_clk is the actual frequency of RC\_SLOW\_CLK; x0 ~ x7 correspond to the pulse width in high and low state of four BACKUP32K\_CLK clock signals (unit: RC\_SLOW\_CLK clock cycle).

## 13.3.3 Configuring the Divisor Component of BACKUP32K\_CLK

Based on principles described in Section 13.3.2, configure the divisor component as follows:

- Calculate the sum of divisor components S according to the frequency of RC\_SLOW\_CLK and the desired frequency of BACKUP32K\_CLK;
- Calculate the integer part of divisor N = f \_ rc \_ slow \_ clk/f \_ back \_ clk;
- Calculate the integer part of divisor component M = N/2. The integer part of divisor N are separated into two parts because a divisor component corresponds to a pulse width in high or low state;
- Calculate the number of divisor components that equal M (x n = M) and the number of divisor components that equal M + 1 (x n = M + 1) according to the value of M and S. (M + 1) is the fractional part of divisor component.

For example, if the frequency of RC\_SLOW\_CLK is 163 kHz, then f \_ rc \_ slow \_ clk = 163000 , f \_ back \_ clk = 32768 , S = 20 , M = 2, and {x0, x1, x2, x3, x4, x5, x6, x7} = {2 , 3 , 2 , 3 , 2 , 3 , 2 , 3}. As a result, the frequency of BACKUP32K\_CLK is 32.6 kHz.
