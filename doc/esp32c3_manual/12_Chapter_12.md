---
chapter: 12
title: "Chapter 12"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 12

## Watchdog Timers (WDT)

## 12.1 Overview

Watchdog timers are hardware timers used to detect and recover from malfunctions. They must be periodically fed (reset) to prevent a timeout. A system/software that is behaving unexpectedly (e.g. is stuck in a software loop or in overdue events) will fail to feed the watchdog thus trigger a watchdog timeout. Therefore, watchdog timers are useful for detecting and handling erroneous system/software behavior.

As shown in Figure 12.1-1, ESP32-C3 contains three digital watchdog timers: one in each of the two timer groups in Chapter 11 Timer Group (TIMG)(called Main System Watchdog Timers, or MWDT) and one in the RTC Module (called the RTC Watchdog Timer, or RWDT). Each digital watchdog timer allows for four separately configurable stages and each stage can be programmed to take one action upon expiry, unless the watchdog is fed or disabled. MWDT supports three timeout actions: interrupt, CPU reset, and core reset, while RWDT supports four timeout actions: interrupt, CPU reset, core reset, and system reset (see details in Section 12.2.2.2 Stages and Timeout Actions). A timeout value can be set for each stage individually.

During the flash boot process, RWDT and the first MWDT in timergroup 0 are enabled automatically in order to detect and recover from booting errors.

ESP32-C3 also has one analog watchdog timer: Super watchdog (SWD). It is an ultra-low-power circuit in analog domain that helps to prevent the system from operating in a sub-optimal state and resets the system if required.

Figure 12.1-1. Watchdog Timers Overview

![Image](images/12_Chapter_12_img001_a57568c6.png)

Note that while this chapter provides the functional descriptions of the watchdog timer's, their register descriptions are provided in Chapter 11 Timer Group (TIMG) and Chapter 9 Low-power Management .

## 12.2 Digital Watchdog Timers

## 12.2.1 Features

Watchdog timers have the following features:

- Four stages, each with a programmable timeout value. Each stage can be configured and enabled/disabled separately
- Three timeout actions (interrupt, CPU reset, or core reset) for MWDT and four timeout actions (interrupt, CPU reset, core reset, or system reset) for RWDT upon expiry of each stage
- 32-bit expiry counter
- Write protection, to prevent RWDT and MWDT configuration from being altered inadvertently
- Flash boot protection
- If the boot process from an SPI flash does not complete within a predetermined period of time, the watchdog will reboot the entire main system.

## 12.2.2 Functional Description

Figure 12.2-1. Watchdog Timers in ESP32-C3

![Image](images/12_Chapter_12_img002_726a2c98.png)

Figure 12.2-1 shows the three watchdog timers in ESP32-C3 digital systems.

## 12.2.2.1 Clock Source and 32-Bit Counter

At the core of each watchdog timer is a 32-bit counter.

MWDTs can select between the APB clock (APB\_CLK) or external clock (XTAL\_CLK) as its clock source by setting the TIMG\_WDT\_USE\_XTAL field of the TIMG\_WDTCONFIG0\_REG register. The selected clock is switched on by setting TIMG\_WDT\_CLK\_IS\_ACTIVE field of the TIMG\_REGCLK\_REG register to 1 and switched off by setting it to 0. Then the selected clock is divided by a 16-bit configurable prescaler. The 16-bit prescaler for MWDTs is configured via the TIMG\_WDT\_CLK\_PRESCALE field of TIMG\_WDTCONFIG1\_REG.When TIMG\_WDT\_DIVCNT\_RST field is set, the prescaler is reset and it can be re-configured at once.

In contrast, the clock source of RWDT is derived directly from an RTC slow clock (the RTC slow clock source shown in Chapter 6 Reset and Clock).

MWDTs and RWDT are enabled by setting the TIMG\_WDT\_EN and RTC\_CNTL\_WDT\_EN fields respectively.

When enabled, the 32-bit counters of each watchdog will increment on each source clock cycle until the timeout value of the current stage is reached (i.e. expiry of the current stage). When this occurs, the current counter value is reset to zero and the next stage will become active. If a watchdog timer is fed by software, the timer will return to stage 0 and reset its counter value to zero. Software can feed a watchdog timer by writing any value to TIMG\_WDTFEED\_REG for MDWTs and RTC\_CNTL\_WDT\_FEED for RWDT.

## 12.2.2.2 Stages and Timeout Actions

Timer stages allow for a timer to have a series of different timeout values and corresponding expiry action. When one stage expires, the expiry action is triggered, the counter value is reset to zero, and the next stage becomes active. MWDTs/ RWDT provide four stages (called stages 0 to 3). The watchdog timers will progress through each stage in a loop (i.e. from stage 0 to 3, then back to stage 0).

Timeout values of each stage for MWDTs are configured in TIMG\_WDTCONFIGi\_REG (where i ranges from 2 to 5), whilst timeout values for RWDT are configured using RTC\_CNTL\_WDT\_STGj\_HOLD field (where j ranges from 0 to 3).

Please note that the timeout value of stage 0 for RWDT (Thold₀) is determined by the combination of the

EFUSE\_WDT\_DELAY\_SEL field of eFuse register EFUSE\_RD\_REPEAT\_DATA1\_REG and RTC\_CNTL\_WDT\_STG0\_HOLD. The relationship is as follows:

<!-- formula-not-decoded -->

where &lt;&lt; is a left-shift operator.

Upon the expiry of each stage, one of the following expiry actions will be executed:

- Trigger an interrupt When the stage expires, an interrupt is triggered.
- CPU reset – Reset a CPU core When the stage expires, the CPU core will be reset.
- Core reset – Reset the main system When the stage expires, the main system (which includes MWDTs, CPU, and all peripherals) will be reset. The power management unit and RTC peripheral will not be reset.
- System reset – Reset the main system, power management unit and RTC peripheral When the stage expires the main system, power management unit and RTC peripheral (see details in Chapter 9 Low-power Management) will all be reset. This action is only available in RWDT.
- Disabled

This stage will have no effects on the system.

For MWDTs, the expiry action of all stages is configured in TIMG\_WDTCONFIG0\_REG. Likewise for RWDT, the expiry action is configured in RTC\_CNTL\_WDTCONFIG0\_REG .

## 12.2.2.3 Write Protection

Watchdog timers are critical to detecting and handling erroneous system/software behavior, thus should not be disabled easily (e.g. due to a misplaced register write). Therefore, MWDTs and RWDT incorporate a write

protection mechanism that prevent the watchdogs from being disabled or tampered with due to an accidental write. The write protection mechanism is implemented using a write-key field for each timer (TIMG\_WDT\_WKEY for MWDT, RTC\_CNTL\_WDT\_WKEY for RWDT). The value 0x50D83AA1 must be written to the watchdog timer's write-key field before any other register of the same watchdog timer can be changed. Any attempts to write to a watchdog timer's registers (other than the write-key field itself) whilst the write-key field's value is not 0x50D83AA1 will be ignored. The recommended procedure for accessing a watchdog timer is as follows:

1. Disable the write protection by writing the value 0x50D83AA1 to the timer’s write-key field.
2. Make the required modification of the watchdog such as feeding or changing its configuration.
3. Re-enable write protection by writing any value other than 0x50D83AA1 to the timer’s write-key field.

## 12.2.2.4 Flash Boot Protection

During flash booting process, MWDT in timer group 0 (see Figure 11.1-1 Timer Units within Groups), as well as RWDT, are automatically enabled. Stage 0 for the enabled MWDT is automatically configured to reset the system upon expiry, known as core reset. Likewise, stage 0 for RWDT is configured to system reset, which resets the main system and RTC when it expires. After booting, TIMG\_WDT\_FLASHBOOT\_MOD\_EN and RTC\_CNTL\_WDT\_FLASHBOOT\_MOD\_EN should be cleared to stop the flash boot protection procedure for both MWDT and RWDT respectively. After this, MWDT and RWDT can be configured by software.

## 12.3 Super Watchdog

Super watchdog (SWD) is an ultra-low-power circuit in analog domain that helps to prevent the system from operating in a sub-optimal state and resets the system if required. SWD contains a watchdog circuit that needs to be fed for at least once during its timeout period, which is slightly less than one second. About 100 ms before watchdog timeout, it will also send out a WD\_INTR signal as a request to remind the system to feed the watchdog.

If the system doesn't respond to SWD feed request and watchdog finally times out, SWD will generate a system level signal SWD\_RSTB to reset whole digital circuits on the chip.

## 12.3.1 Features

SWD has the following features:

- Ultra-low power
- Interrupt to indicate that the SWD timeout period is close to expiring
- Various dedicated methods for software to feed SWD, which enables SWD to monitor the working state of the whole operating system

## 12.3.2 Super Watchdog Controller

## 12.3.2.1 Structure

Figure 12.3-1. Super Watchdog Controller Structure

![Image](images/12_Chapter_12_img003_f87528be.png)

## 12.3.2.2 Workflow

## In normal state:

- SWD controller receives feed request from SWD.
- SWD controller can send an interrupt to main CPU.
- Main CPU can feed SWD directly by setting RTC\_CNTL\_SWD\_FEED .
- When trying to feed SWD, CPU needs to disable SWD controller's write protection by writing 0x8F1D312A to RTC\_CNTL\_SWD\_WKEY. This prevents SWD from being fed by mistake when the system is operating in sub-optimal state.
- If setting RTC\_CNTL\_SWD\_AUTO\_FEED\_EN to 1, SWD controller can also feed SWD itself without any interaction with CPU.

## After reset:

- Check RTC\_CNTL\_RESET\_CAUSE\_PROCPU[5:0] for the cause of CPU reset. If RTC\_CNTL\_RESET\_CAUSE\_PROCPU[5:0] == 0x12, it indicates that the cause is SWD reset.
- Set RTC\_CNTL\_SWD\_RST\_FLAG\_CLR to clear the SWD reset flag.

## 12.4 Interrupts

For watchdog timer interrupts, please refer to Section 11.2.6 Interrupts in Chapter 11 Timer Group (TIMG) .

## 12.5 Registers

MWDT registers are part of the timer submodule and are described in Section 11.4 Register Summary in Chapter 11 Timer Group (TIMG). RWDT and SWD registers are part of the RTC submodule and are described in Section 9.7 Register Summary in Chapter 9 Low-power Management .
