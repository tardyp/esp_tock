---
chapter: 15
title: "Chapter 15"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 15

## Watchdog Timers (WDT)

## 15.1 Overview

Watchdog timers are hardware timers used to detect and recover from malfunctions. They must be periodically fed (reset) to prevent a timeout. A system/software that is behaving unexpectedly (e.g. is stuck in a software loop or in overdue events) will fail to feed the watchdog thus trigger a watchdog timeout. Therefore, watchdog timers are useful for detecting and handling erroneous system/software behavior.

As shown in Figure 15.1-1, ESP32-C6 contains three digital watchdog timers: one in each of the two timer groups in Chapter 14 Timer Group (TIMG) (called Main System Watchdog Timers, or MWDT) and one in the RTC Module (called the RTC Watchdog Timer, or RWDT). Each digital watchdog timer allows for four separately configurable stages and each stage can be programmed to take one action upon timeout, unless the watchdog is fed or disabled. MWDT supports three timeout actions: interrupt, CPU reset, and core reset, while RWDT supports four timeout actions: interrupt, CPU reset, core reset, and system reset (see details in Section 15.2.2.2 Stages and Timeout Actions). A timeout value can be set for each stage individually.

During the flash boot process, RWDT and the MWDT in timer group 0 are enabled automatically in order to detect and recover from booting errors.

ESP32-C6 also has one analog watchdog timer: Super watchdog (SWD). It is an ultra-low-power circuit in analog domain that helps to prevent the system from operating in a sub-optimal state and resets the system if required.

Figure 15.1-1. Watchdog Timers Overview

![Image](images/15_Chapter_15_img001_e3c2d7c6.png)

Note that while this chapter provides the functional descriptions of the watchdog timer's, MWDT register descriptions are detailed in Chapter 14 Timer Group (TIMG), and the RWDT and SWD register descriptions are detailed in Section 15.5 Register Summary .

## 15.2 Digital Watchdog Timers

## 15.2.1 Features

Watchdog timers have the following features:

- Four stages, each with a separately programmable timeout value and timeout action
- Timeout actions:
- – MWDT: interrupt, CPU reset, core reset
- – RWDT: interrupt, CPU reset, core reset, system reset
- Flash boot protection at stage 0:
- – MWDT0: core reset upon timeout
- – RWDT: system reset upon timeout
- Write protection that makes WDT register read only unless unlocked
- 32-bit timeout counter
- Clock source:
- – MWDT: PLL\_F80M\_CLK, RC\_FAST\_CLK or XTAL\_CLK
- – RWDT: RTC\_SLOW\_CLK

## 15.2.2 Functional Description

Figure 15.2-1. Digital Watchdog Timers in ESP32-C6

![Image](images/15_Chapter_15_img002_befad41f.png)

Figure 15.2-1 shows the three watchdog timers in ESP32-C6 digital systems.

## 15.2.2.1 Clock Source and 32-Bit Counter

At the core of each watchdog timer is a 32-bit counter.

Take MWDT0 as an example:

- MWDT0 can select between the PLL\_F80M\_CLK, RC\_FAST\_CLK or XTAL\_CLK (external) clock as its clock source by setting the PCR\_TG0\_WDT\_CLK\_SEL field of the PCR\_TIMERGROUP0\_WDT\_CLK\_CONF\_REG register.
- The selected clock is switched on by setting PCR\_TG0\_WDT\_CLK\_EN field of the PCR\_TIMERGROUP0\_WDT\_CLK\_CONF\_REG register to 1 and switched off by setting it to 0. Then the selected clock is divided by a 16-bit configurable prescaler. See more details in Table 8.2-1 of Chapter 8 .

The 16-bit prescaler for MWDT is configured via the TIMG\_WDT\_CLK\_PRESCALE field of TIMG\_WDTCONFIG1\_REG. When TIMG\_WDT\_DIVCNT\_RST field is set, the prescaler is reset and it can be re-configured at once.

In contrast, the clock source of RWDT is derived directly from RTC\_SLOW\_CLK (see details in Chapter 8 Reset and Clock).

MWDT and RWDT are enabled by setting the TIMG\_WDT\_EN and RTC\_WDT\_EN fields respectively. When enabled, the 32-bit counters of the watchdog will increment on each source clock cycle until the timeout value of the current stage is reached (i.e. timeout of the current stage). When this occurs, the current counter value is reset to zero and the next stage will become active. If a watchdog timer is fed by software, the timer will return to stage 0 and reset its counter value to zero. Software can feed a watchdog timer by writing any value to TIMG\_WDTFEED\_REG for MDWT and by writing 1 to RTC\_WDT\_FEED for RWDT.

## 15.2.2.2 Stages and Timeout Actions

Timer stages allow for a timer to have a series of different timeout values and corresponding timeout action. When one stage times out, the timeout action is triggered, the counter value is reset to zero, and the next stage becomes active.

MWDT/RWDT provide four stages (called stages 0 to 3). The watchdog timers will progress through each stage in a loop (i.e. from stage 0 to 3, then back to stage 0).

Timeout values of each stage for MWDT are configured in TIMG\_WDTCONFIGi\_REG (where i ranges from 2 to 5), whilst timeout values for RWDT are configured using RTC\_WDT\_STGj\_HOLD field (where j ranges from 0 to 3).

Please note that the timeout value of stage 0 for RWDT (Thold₀) is determined by the combination of the

EFUSE\_WDT\_DELAY\_SEL field of eFuse register EFUSE\_RD\_REPEAT\_DATA0\_REG and RTC\_WDT\_STG0\_HOLD field. The relationship is as follows:

<!-- formula-not-decoded -->

where &lt;&lt; is a left-shift operator. For example, if RTC\_WDT\_STG0\_HOLD is configured as 100 and EFUSE\_WDT\_DELAY\_SEL is 1, the Thold₀ will be 400 cycles.

Upon the timeout of each stage, one of the following timeout actions will be executed:

Table 15.2-1. Timeout Actions

| Timeout Action   | Description                                                                                                                                                |
|------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Interrupt        | Trigger an interrupt                                                                                                                                       |
| CPU reset        | Reset the CPU core                                                                                                                                         |
| Core reset       | Reset the main system (which includes MWDT, CPU, and all peripherals). The power management unit and RTC peripherals will not be reset                     |
| System reset     | Reset the main system, power management unit and RTC peripherals (see de tails in Chapter 12 Low-Power Management). This action is only available in RWDT |
| Disabled         | No effect on the system                                                                                                                                    |

For MWDT, the timeout action of all stages is configured in TIMG\_WDTCONFIG0\_REG. Likewise for RWDT, the timeout action is configured in RTC\_WDT\_CONFIG0\_REG .

## 15.2.2.3 Write Protection

Watchdog timers are critical to detecting and handling erroneous system/software behavior, thus should not be disabled easily (e.g. due to a misplaced register write). Therefore, MWDT and RWDT incorporate a write protection mechanism that prevent the watchdogs from being disabled or tampered with due to an accidental write.

The write protection mechanism is implemented using a write-key field for each timer (TIMG\_WDT\_WKEY for MWDT, RTC\_WDT\_WKEY for RWDT). The value 0x50D83AA1 must be written to the watchdog timer's write-key field before any other register of the same watchdog timer can be changed. Any attempts to write to a watchdog timer's registers (other than the write-key field itself) whilst the write-key field's value is not 0x50D83AA1 will be ignored. The recommended procedure for accessing a watchdog timer is as follows:

1. Disable the write protection by writing the value 0x50D83AA1 to the timer’s write-key field.
2. Make the required modification of the watchdog such as feeding or changing its configuration.
3. Re-enable write protection by writing any value other than 0x50D83AA1 to the timer’s write-key field.

## 15.2.2.4 Flash Boot Protection

During flash booting process, MWDT0 as well as RWDT, are automatically enabled. Stage 0 for the enabled MWDT0 is automatically configured as core reset action upon timeout, known as core reset. Likewise, stage 0 for RWDT is configured to system reset, which resets the main system and RTC when it times out. After booting, TIMG\_WDT\_FLASHBOOT\_MOD\_EN and RTC\_WDT\_FLASHBOOT\_MOD\_EN should be cleared to stop the flash boot protection procedure for both MWDT0 and RWDT respectively. After this, MWDT0 and RWDT can be configured by software.

## 15.3 Super Watchdog

Super watchdog (SWD) is an ultra-low-power circuit in analog domain that helps to prevent the system from operating in a sub-optimal state and resets the system (system reset) if required. SWD contains a watchdog circuit that needs to be fed for at least once during its timeout period, which is slightly less than one second. About 100 ms before watchdog timeout, it will also send out a WD\_INTR signal as a request to remind the system to feed the watchdog.

If the system doesn't respond to SWD feed request and watchdog finally times out, SWD will generate a system level signal SWD\_RSTB to reset whole digital circuits on the chip (system reset) .

The source of the clock for SWD is constant and can not be selected.

## 15.3.1 Features

SWD has the following features:

- Ultra-low power
- Interrupt to indicate that the SWD is about to time out
- Various dedicated methods for software to feed SWD, which enables SWD to monitor the working state of the whole operating system

## 15.3.2 Super Watchdog Controller

## 15.3.2.1 Structure

Figure 15.3-1. Super Watchdog Controller Structure

![Image](images/15_Chapter_15_img003_0baf1c73.png)

## 15.3.2.2 Workflow

In normal state:

- SWD controller receives feed request from SWD.
- SWD controller can send an interrupt to main CPU.
- Main CPU can feed SWD directly by setting RTC\_WDT\_SWD\_FEED .
- When trying to feed SWD, CPU needs to disable SWD controller's write protection by writing 0x50D83AA1 to RTC\_WDT\_SWD\_WKEY. This prevents SWD from being fed by mistake when the system is operating in sub-optimal state.
- If setting RTC\_WDT\_SWD\_AUTO\_FEED\_EN to 1, SWD controller can also feed SWD itself without any interaction with CPU.

## After reset:

- Check RTC\_CLKRST\_RESET\_CAUSE[4:0] for the cause of CPU reset. If RTC\_CLKRST\_RESET\_CAUSE[4:0] == 0x12, it indicates that the cause is SWD reset.
- Set RTC\_WDT\_SWD\_RST\_FLAG\_CLR to clear the SWD reset flag.

## 15.4 Interrupts

For watchdog timer interrupts, please refer to Section 14.3.7 Interrupts in Chapter 14 Timer Group (TIMG) .

## 15.5 Register Summary

The addresses in this section are relative to RTC\_WDT base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                     | Description                               | Address                | Access                 |
|--------------------------|-------------------------------------------|------------------------|------------------------|
| configuration register   | configuration register                    | configuration register | configuration register |
| RTC_WDT_CONFIG0_REG      | Configure the RWDT operation              | 0x0000                 | R/W                    |
| RTC_WDT_CONFIG1_REG      | Configure the RWDT timeout time of stage0 | 0x0004                 | R/W                    |
| RTC_WDT_CONFIG2_REG      | Configure the RWDT timeout time of stage1 | 0x0008                 | R/W                    |
| RTC_WDT_CONFIG3_REG      | Configure the RWDT timeout time of stage2 | 0x000C                 | R/W                    |
| RTC_WDT_CONFIG4_REG      | Configure the RWDT timeout time of stage3 | 0x0010                 | R/W                    |
| RTC_WDT_FEED_REG         | Configure the feed function of RWDT       | 0x0014                 | WT                     |
| RTC_WDT_WPROTECT_REG     | Configure the lock function of RWDT       | 0x0018                 | R/W                    |
| RTC_WDT_SWD_CONFIG_REG   | Configure the SWD operation               | 0x001C                 | varies                 |
| RTC_WDT_SWD_WPROTECT_REG | Configure the lock function of SWD        | 0x0020                 | R/W                    |
| RTC_WDT_INT_RAW_REG      | The interrupt raw register of WDT         | 0x0024                 | R/WTC/SS               |
| RTC_WDT_INT_ST_REG       | The interrupt status register of WDT      | 0x0028                 | RO                     |
| RTC_WDT_INT_ENA_REG      | The interrupt enable register of WDT      | 0x002C                 | R/W                    |
| RTC_WDT_INT_CLR_REG      | The interrupt clear register of WDT       | 0x0030                 | WT                     |
| RTC_WDT_DATE_REG         | Version control register                  | 0x03FC                 | R/W                    |

## 15.6 Registers

MWDT registers are part of the timer submodule and are described in Section 14.5 Register Summary in Chapter 14 Timer Group (TIMG) .

The addresses of RWDT and SWD registers in this section are relative to RTC\_WDT base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 15.1. RTC\_WDT\_CONFIG0\_REG (0x0000)

![Image](images/15_Chapter_15_img004_266870a9.png)

RTC\_WDT\_PAUSE\_IN\_SLP Configure whether or not pause RWDT when chip is in sleep mode.

0: Enable

- 1: Disable

(R/W)

RTC\_WDT\_PROCPU\_RESET\_EN Configure whether or not to enable RWDT to reset CPU.

- 0: Disable

1: Enable

(R/W)

RTC\_WDT\_FLASHBOOT\_MOD\_EN Configure whether or not to enable RWDT when chip is in SPI

boot mode.

0: Disable

1: Enable

(R/W)

RTC\_WDT\_SYS\_RESET\_LENGTH Configure the core reset time.

```
Measurement unit: RTC_DYN_FAST_CLK (R/W)
```

RTC\_WDT\_CPU\_RESET\_LENGTH Configure the CPU reset time.

```
Measurement unit: RTC_DYN_FAST_CLK (R/W)
```

RTC\_WDT\_STG3 Configure the timeout action of stage3.

- 0: No operation
- 1: Generate interrupt
- 2: Generate CPU reset
- 3: Generate core reset
- 4: Generate system reset

(R/W)

## Continued on the next page...

## Register 15.1. RTC\_WDT\_CONFIG0\_REG (0x0000)

## Continued from the previous page...

## RTC\_WDT\_STG2 Configure the timeout action of stage2.

- 0: No operation
- 1: Generate interrupt
- 2: Generate CPU reset
- 3: Generate core reset
- 4: Generate system reset
- (R/W)

## RTC\_WDT\_STG1 Configure the timeout action of stage1.

- 0: No operation
- 1: Generate interrupt
- 2: Generate CPU reset
- 3: Generate core reset
- 4: Generate system reset

(R/W)

## RTC\_WDT\_STG0 Configure the timeout action of stage0.

- 0: No operation
- 1: Generate interrupt
- 2: Generate CPU reset
- 3: Generate core reset
- 4: Generate system reset

(R/W)

## RTC\_WDT\_EN Configure whether or not enable RWDT.

- 0: Disable RWDT
- 1: Enable RWDT

(R/W)

Register 15.2. RTC\_WDT\_CONFIG1\_REG (0x0004)

![Image](images/15_Chapter_15_img005_69fd3c2e.png)

RTC\_WDT\_STG0\_HOLD Configure the timeout time for stage0.

Measurement unit: RTC\_DYN\_SLOW\_CLK

(R/W)

Register 15.3. RTC\_WDT\_CONFIG2\_REG (0x0008)

![Image](images/15_Chapter_15_img006_369a46d7.png)

RTC\_WDT\_STG1\_HOLD Configure the timeout time for stage1.

Measurement unit: RTC\_DYN\_SLOW\_CLK

(R/W)

Register 15.4. RTC\_WDT\_CONFIG3\_REG (0x000C)

![Image](images/15_Chapter_15_img007_aedf2a4d.png)

RTC\_WDT\_STG2\_HOLD Configure the timeout time for stage2.

Measurement unit: RTC\_DYN\_SLOW\_CLK

(R/W)

Register 15.5. RTC\_WDT\_CONFIG4\_REG (0x0010)

![Image](images/15_Chapter_15_img008_69de7800.png)

RTC\_WDT\_STG3\_HOLD Configure the timeout time for stage3.

Measurement unit: RTC\_DYN\_SLOW\_CLK

(R/W)

Register 15.6. RTC\_WDT\_FEED\_REG (0x0014)

![Image](images/15_Chapter_15_img009_0d9f0c1f.png)

RTC\_WDT\_RTC\_WDT\_FEED Configure this bit to feed the RWDT.

0: Invalid

1: Feed RWDT

(WT)

## Register 15.7. RTC\_WDT\_WPROTECT\_REG (0x0018)

![Image](images/15_Chapter_15_img010_6858a12f.png)

RTC\_WDT\_WKEY Configure this field to lock or unlock RWDT’s configuration registers.

0x50D83AA1: unlock the RWDT configuration register

Others value: lock the RWDT configuration register which can't be modified by software. (R/W)

## Register 15.8. RTC\_WDT\_SWD\_CONFIG\_REG (0x001C)

![Image](images/15_Chapter_15_img011_0e8994db.png)

RTC\_WDT\_SWD\_RESET\_FLAG Represents the SWD whether or not generate the reset signal

0: No

- 1: Yes

(RO)

RTC\_WDT\_SWD\_AUTO\_FEED\_EN Configure this bit to enable to feed SWD automatically by hard- ware.

0: Disable

- 1: Enable

(R/W)

## RTC\_WDT\_SWD\_RST\_FLAG\_CLR Configure this bit to clear SWD reset flag

- 0: Invalid

1: clear the reset flag

(WT)

RTC\_WDT\_SWD\_SIGNAL\_WIDTH Confgure the SWD signal length that output to analog circuit.

Measurement unit: RTC\_DYN\_FAST\_CLK (R/W)

RTC\_WDT\_SWD\_DISABLE Configure this bit to disable the SWD.

- 0: Enable the SWD
- 1: Disable the SWD

(R/W)

## RTC\_WDT\_SWD\_FEED Configure this bit to feed the SWD.

- 0: Invalid
- 1: Feed SWD

(WT)

## Register 15.9. RTC\_WDT\_SWD\_WPROTECT\_REG (0x0020)

![Image](images/15_Chapter_15_img012_ce06be9b.png)

RTC\_WDT\_SWD\_WKEY Configure this field to lock or unlock SWD’s configuration registers.

0x50D83AA1: unlock the SWD configuration register.

Others value: lock the SWD configuration register which can’t be modified by the software.

(R/W)

## Register 15.10. RTC\_WDT\_INT\_RAW\_REG (0x0024)

![Image](images/15_Chapter_15_img013_61d844d2.png)

RTC\_WDT\_SWD\_INT\_RAW Represents the SWD whether or not generates timeout interrupt.

0: No

1: Yes

(R/WTC/SS)

RTC\_WDT\_INT\_RAW Represents the RWDT whether or not generates timeout interrupt.

0: No

1: Yes

(R/WTC/SS)

## Register 15.11. RTC\_WDT\_INT\_ST\_REG (0x0028)

![Image](images/15_Chapter_15_img014_15e629c7.png)

RTC\_WDT\_SWD\_INT\_ST Represents the SWD whether or not generates and sends timeout interrupt

- to CPU.
- 0: No
- 1: Yes

(RO)

RTC\_WDT\_INT\_ST Represents the RWDT whether or not generates and sends timeout interrupt to

- CPU.
- 0: No
- 1: Yes

(RO)

## Register 15.12. RTC\_WDT\_INT\_ENA\_REG (0x002C)

![Image](images/15_Chapter_15_img015_3aca734f.png)

RTC\_WDT\_SWD\_INT\_ENA Configure whether or not to enable the SWD to send timeout interrupt.

- 0: Disable
- 1: Enable
- (R/W)

RTC\_WDT\_INT\_ENA Configure whether or not to enable the RWDT to send timeout interrupt.

- 0: Disable
- 1: Enable
- (R/W)

## Register 15.13. RTC\_WDT\_INT\_CLR\_REG (0x0030)

![Image](images/15_Chapter_15_img016_17a5dec8.png)

RTC\_WDT\_SWD\_INT\_CLR Configure whether to clear the timeout interrupt signal sent by SWD to

CPU.

0: No

1: Yes

(WT)

RTC\_WDT\_INT\_CLR Configure whether to clear the timeout interrupt signal sent by RWDT to CPU.

0: No

1: Yes

(WT)

## Register 15.14. RTC\_WDT\_DATE\_REG (0x03FC)

![Image](images/15_Chapter_15_img017_fec807b9.png)

RTC\_WDT\_DATE Version control register (R/W)

RTC\_WDT\_CLK\_EN Reserved (R/W)
