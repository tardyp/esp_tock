---
chapter: 14
title: "Chapter 14"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 14

## Timer Group (TIMG)

## 14.1 Overview

General-purpose timers can be used to precisely time an interval, trigger an interrupt after a particular interval (periodically and aperiodically), or act as a hardware clock. As shown in Figure 14.1-1, the ESP32-C6 chip contains two timer groups, namely timer group 0 and timer group 1. Each timer group consists of one general-purpose timer referred to as T0 and one Main System Watchdog Timer. The general-purpose timer is based on a 16-bit prescaler and a 54-bit auto-reload-capable up-down counter.

Figure 14.1-1. Timer Group Overview

![Image](images/14_Chapter_14_img001_70961909.png)

Note that while the Main System Watchdog Timer registers are described in this chapter, their functional description is included in the Chapter 15 Watchdog Timers (WDT). Therefore, the term "timer" within this chapter refers to the general-purpose timer.

## 14.2 Features

The timer’s features are summarized as follows:

- A 54-bit time-base counter programmable to incrementing or decrementing
- Three clock sources: PLL\_F80M\_CLK or XTAL\_CLK or RC\_FAST\_CLK
- A 16-bit clock prescaler, from 2 to 65536
- Able to read real-time value of the time-base counter
- Able to halt and resume the time-base counter
- Programmable alarm generation

- Timer value reload — Auto-reload at alarm or software-controlled instant reload
- RTC slow clock RTC\_SLOW\_CLK frequency calculation
- Level interrupt generation
- Support several ETM tasks and events

## 14.3 Functional Description

Figure 14.3-1. Timer Group Architecture

![Image](images/14_Chapter_14_img002_838eb788.png)

Figure 14.3-1 is a diagram of timer T0 in a timer group. T0 contains a 16-bit integer divider as a prescaler, a timer-based counter and a comparator for alarm generation.

## 14.3.1 16-bit Prescaler and Clock Selection

Take the T0 in timer group 0 as an example:

- The timer can select its clock source by setting the PCR\_TG0\_TIMER\_CLK\_SEL field of the PCR\_TIMERGROUP0\_TIMER\_CLK\_CONF\_REG register. When the field is 0, XTAL\_CLK is selected; when the field is 1, PLL\_F80M\_CLK is selected and when the field is 2, RC\_FAST\_CLK is selected.
- The selected clock can be switched on by setting PCR\_TG0\_TIMER\_CLK\_EN field of the PCR\_TIMERGROUP0\_TIMER\_CLK\_CONF\_REG register to 1 and switched off by setting it to 0. The clock is then divided by a 16-bit prescaler to generate the time-base counter clock (TB\_CLK) used by the time-base counter. The divisor of the prescaler can be configured through the TIMG\_T0\_DIVIDER field.

TIMG\_T0\_DIVIDER field can be configured as 0 ~ 65535 for a divisor range of 2 ~ 65536. To be more specific, when TIMG\_T0\_DIVIDER is configured as:

- 0: the divisor is 65536
- 1: the divisor is 2
- 2: the divisor is also 2
- 3 ~ 65525: the divisor is 3 ~ 65535

To modify the 16-bit prescaler, please first configure the TIMG\_T0\_DIVIDER field, and then set TIMG\_T0\_DIVCNT\_RST to 1. Meanwhile, the timer must be disabled (i.e. TIMG\_T0\_EN should be cleared). Otherwise, the result can be unpredictable.

## 14.3.2 54-bit Time-base Counter

The 54-bit time-base counter is based on TB\_CLK and can be configured to increment or decrement via the TIMG\_T0\_INCREASE field. The time-base counter can be enabled or disabled by setting or clearing the TIMG\_T0\_EN field, respectively. When enabled, the time-base counter increments or decrements on each cycle of TB\_CLK. When disabled, the time-base counter is essentially frozen. Note that the TIMG\_T0\_INCREASE field can be changed no matter whether TIMG\_T0\_EN is set or not, and this will cause the time-base counter to change direction instantly.

To read the 54-bit value of the time-base counter, the timer value must be latched to two registers before being read by the CPU (due to the CPU being 32-bit). By writing any value to the TIMG\_T0UPDATE\_REG, the current value of the 54-bit timer starts to be latched into the TIMG\_T0LO\_REG and TIMG\_T0HI\_REG registers containing the lower 32-bits and higher 22-bits, respectively. When TIMG\_T0UPDATE\_REG is cleared by hardware, it indicates the latch operation has been completed and current timer value can be read from the TIMG\_T0LO\_REG and TIMG\_T0HI\_REG registers. TIMG\_T0LO\_REG and TIMG\_T0HI\_REG registers will remain unchanged for the CPU to read in its own time until TIMG\_T0UPDATE\_REG is written to again.

## 14.3.3 Alarm Generation

A timer can be configured to trigger an alarm when the timer's current value matches the alarm value. An alarm will cause an interrupt to occur and (optionally) an automatic reload of the timer's current value (see Section 14.3.4).

The 54-bit alarm value is configured using TIMG\_T0ALARMLO\_REG and TIMG\_T0ALARMHI\_REG, which represent the lower 32-bits and higher 22-bits of the alarm value, respectively. However, the configured alarm value is ineffective until the alarm is enabled by setting the TIMG\_T0\_ALARM\_EN field. To avoid alarm being enabled "too late" (i.e. the timer value has already passed the alarm value when the alarm is enabled), the hardware will trigger the alarm immediately if the current timer value is:

- higher than the alarm value (within a defined range) when the up-down counter increments
- lower than the alarm value (within a defined range) when the up-down counter decrements

Table 14.3-1 and Table 14.3-2 show the relationship between the current value of the timer, the alarm value, and when an alarm is triggered. The current time value and the alarm value are defined as follows:

- TIMG\_VALUE = {TIMG\_T0HI\_REG , TIMG\_T0LO\_REG}
- ALARM\_VALUE = {TIMG\_T0ALARMHI\_REG , TIMG\_T0ALARMLO\_REG}

Table 14.3-1. Alarm Generation When Up-Down Counter Increments

|   Scenario | Range                                 | Alarm                                                                                                                                           |
|------------|---------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
|          1 | ALARM_VALUE  −  TIMG_VALUE > 2 53     | Triggered                                                                                                                                       |
|          2 | 0 < ALARM_VALUE  −  TIMG_VALUE ≤ 2 53 | Triggered when the up-down counter counts TIMG_VALUE up to ALARM_VALUE                                                                          |
|          3 | 0 ≤ TIMG_VALUE  −  ALARM_VALUE < 2 53 | Triggered                                                                                                                                       |
|          4 | TIMG_VALUE  −  ALARM_VALUE ≥ 2 53     | Triggered when the up-down counter restarts counting up from 0 after reaching the timer’s maximum value and counts TIMG_VALUE up to ALARM_VALUE |

![Image](images/14_Chapter_14_img003_65c2568f.png)

Table 14.3-2. Alarm Generation When Up-Down Counter Decrements

|   Scenario | Range                                 | Alarm                                                                                                                                                               |
|------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|          5 | TIMG_VALUE  −  ALARM_VALUE > 2 53     | Triggered                                                                                                                                                           |
|          6 | 0 < TIMG_VALUE  −  ALARM_VALUE ≤ 2 53 | Triggered when the up-down counter counts TIMG_VALUE down to ALARM_VALUE                                                                                            |
|          7 | 0 ≤ ALARM_VALUE  −  TIMG_VALUE < 2 53 | Triggered                                                                                                                                                           |
|          8 | ALARM_VALUE  −  TIMG_VALUE ≥ 2 53     | Triggered when the up-down counter restarts counting down from the timer’s maximum value after reaching the minimum value and counts TIMG_VALUE down to ALARM_VALUE |

When an alarm occurs, the TIMG\_T0\_ALARM\_EN field is automatically cleared and no alarm will occur again until the TIMG\_T0\_ALARM\_EN is set next time.

## 14.3.4 Timer Reload

A timer is reloaded when a timer's current value is overwritten with a reload value stored in the TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI fields that correspond to the lower 32-bits and higher 22-bits of the timer's new value, respectively. However, writing a reload value to TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI will not cause the timer's current value to change. Instead, the reload value is ignored by the timer until a reload event occurs. A reload event can be triggered either by a software instant reload or an auto-reload at alarm.

A software instant reload is triggered by the CPU writing any value to TIMG\_T0LOAD\_REG, which causes the timer's current value to be instantly reloaded. If TIMG\_T0\_EN is set, the timer will continue incrementing or decrementing from the new value. In this case if TIMG\_T0\_ALARM\_EN is set, the timer will still trigger alarms in scenarios listed in Table 14.3-1 and 14.3-2. If TIMG\_T0\_EN is cleared, the timer will remain frozen at the new value until counting is re-enabled.

An auto-reload at alarm will cause a timer reload when an alarm occurs, thus allowing the timer to continue incrementing or decrementing from the reload value. This is generally useful for resetting the timer's value when using periodic alarms. To enable auto-reload at alarm, the TIMG\_T0\_AUTORELOAD field should be set. If not enabled, the timer's value will continue to increment or decrement past the alarm value after an alarm.

## 14.3.5 Event Task Matrix Feature

The timer groups on ESP32-C6 support the Event Task Matrix (ETM) function, which allows timer groups' ETM tasks to be triggered by any peripherals' ETM events, or timer groups' ETM events to trigger any peripherals' ETM tasks. This section introduces the ETM tasks and events related to timer groups. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

The timer groups can receive the following ETM tasks:

- TIMERn\_TASK\_CNT\_START\_TIMER0 (n:0-1): When triggered, it will enable the time-base counter.
- TIMERn\_TASK\_CNT\_STOP\_TIMER0 (n:0-1): When triggered, it will disable the time-base counter.

## Note:

The above two ETM tasks have the same function as the APB configuration TIMG\_T0\_EN. When these operations occur at the same time, the priority of each operation from high to low is as follows:

1. TIMERn\_TASK\_CNT\_START\_TIMER0: When triggered, it will enable the time-base counter;
2. TIMERn\_TASK\_CNT\_STOP\_TIMER0: When triggered, it will disable the time-base counter;
3. APB configuration TIMG\_T0\_EN: When triggered, it will enable or disable the time-base counter.
- TIMERn\_TASK\_ALARM\_START\_TIMER0 (n:0-1): When triggered, it will enable the alarm generation.

## Note:

Alarm generation can also be configured through APB method and hardware events. When these operations occur at the same time, the priority of each operation from high to low is as follows:

1. TIMERn\_TASK\_ALARM\_START\_TIMER0: When triggered, it will enable the alarm generation;
2. Alarm events: When triggered, it will disable the alarm generation;
3. APB configuration TIMG\_ALARM\_EN: When triggered, it will enable or disable the alarm generation.
- TIMERn\_TASK\_CNT\_CAP\_TIMER0 (n:0-1): When triggered, it will update the current counter value to the TIMG\_T0LO\_REG and TIMG\_T0HI\_REG registers.
- TIMERn\_TASK\_CNT\_RELOAD\_TIMER0 (n:0-1): When triggered, it will overwrite the current counter value with the reload value stored in TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI .

The timer groups can generate the following ETM events:

- TIMERn\_EVT\_CNT\_CMP\_TIMER0 (n:0-1)fiIndicates the interrupt event of T0 in TIMGn .

All the ETM tasks and events will not take effect until the TIMG\_ETM\_EN is set to 1.

In practical applications, timer groups' ETM events can trigger their own ETM tasks. For example, TIMERn\_TASK\_ALARM\_START\_TIMER0 (n:0-1) can be triggered by TIMERn\_EVT\_CNT\_CMP\_TIMER0 (n:0-1) to realize periodic alarm. For configuration steps, please refer to 14.4.4 Timer as Periodic Alarm by ETM .

## 14.3.6 RTC\_SLOW\_CLK Frequency Calculation

Using XTAL\_CLK as a reference, it is possible to calculate the frequency of clock sources for RTC\_SLOW\_CLK (i.e. RC\_SLOW\_CLK, RC\_FAST\_DIV\_CLK, and XTAL32K\_CLK) as follows:

1. Start periodic or one-shot frequency calculation (see Section 14.4.5 for details);
2. Once receiving the signal to start calculation, the counter of XTAL\_CLK and the counter of RTC\_SLOW\_CLK begin to work at the same time. When the counter of RTC\_SLOW\_CLK counts to C0, the two counters stop counting simultaneously;
3. Assume the value of XTAL\_CLK's counter is C1, and the frequency of RTC\_SLOW\_CLK would be calculated as: f \_ rtc = C0×f \_ XT AL \_ CLK C1

## 14.3.7 Interrupts

Each timer has its own interrupt line that can be routed to the CPU, and thus each timer group has a total of two interrupt lines. Timers generate level interrupts that must be explicitly cleared by the CPU on each triggering.

Interrupts are triggered after an alarm (or stage timeout for watchdog timers) occurs. Level interrupts will be held high after an alarm (or stage timeout) occurs, and will remain so until manually cleared. To enable a timer's interrupt, the TIMG\_T0\_INT\_ENA bit should be set.

The interrupts of each timer group are governed by a set of registers. Each timer within the group has a corresponding bit in each of these registers:

- TIMG\_T0\_INT\_RAW : An alarm event sets it to 1. The bit will remain set until the timer's corresponding bit in TIMG\_T0\_INT\_CLR is written.
- TIMG\_WDT\_INT\_RAW : A stage time out will set the timer's bit to 1. The bit will remain set until the timer's corresponding bit in TIMG\_WDT\_INT\_CLR is written.
- TIMG\_T0\_INT\_ST : Reflects the status of each timer's interrupt and is generated by masking the bits of TIMG\_T0\_INT\_RAW with TIMG\_T0\_INT\_ENA .
- TIMG\_WDT\_INT\_ST : Reflects the status of each watchdog timer's interrupt and is generated by masking the bits of TIMG\_WDT\_INT\_RAW with TIMG\_WDT\_INT\_ENA .
- TIMG\_T0\_INT\_ENA : Used to enable or mask the interrupt status bits of timers within the group.
- TIMG\_WDT\_INT\_ENA : Used to enable or mask the interrupt status bits of watchdog timer within the group.
- TIMG\_T0\_INT\_CLR : Used to clear a timer's interrupt by setting its corresponding bit to 1. The timer's corresponding bit in TIMG\_T0\_INT\_RAW and TIMG\_T0\_INT\_ST will be cleared as a result. Note that a timer's interrupt must be cleared before the next interrupt occurs.
- TIMG\_WDT\_INT\_CLR : Used to clear a timer's interrupt by setting its corresponding bit to 1. The watchdog timer's corresponding bit in TIMG\_WDT\_INT\_RAW and TIMG\_WDT\_INT\_ST will be cleared as a result. Note that a watchdog timer's interrupt must be cleared before the next interrupt occurs.

## 14.4 Configuration and Usage

## 14.4.1 Timer as a Simple Clock

1. Configure the time-base counter
- Select clock source by setting or clearing PCR\_TG0\_TIMER\_CLK\_SEL field.
- Configure the 16-bit prescaler by setting TIMG\_T0\_DIVIDER .
- Configure the timer direction by setting or clearing TIMG\_T0\_INCREASE .
- Set the timer's starting value by writing the starting value to TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI, then reloading it into the timer by writing any value to TIMG\_T0LOAD\_REG .
2. Start the timer by setting TIMG\_T0\_EN .

3. Get the timer’s current value.
- Write any value to TIMG\_T0UPDATE\_REG to latch the timer's current value.
- Wait until TIMG\_T0UPDATE\_REG is cleared by hardware.
- Read the latched timer value from TIMG\_T0LO\_REG and TIMG\_T0HI\_REG .

## 14.4.2 Timer as One-shot Alarm

1. Configure the time-base counter following step 1 of Section 14.4.1 .
2. Configure the alarm.
- Configure the alarm value by setting TIMG\_T0ALARMLO\_REG and TIMG\_T0ALARMHI\_REG .
- Enable interrupt by setting TIMG\_T0\_INT\_ENA .
3. Disable auto reload by clearing TIMG\_T0\_AUTORELOAD .
4. Start the alarm by setting TIMG\_T0\_ALARM\_EN .
5. Handle the alarm interrupt.
- Clear the interrupt by setting the timer's corresponding bit in TIMG\_T0\_INT\_CLR .
- Disable the timer by clearing TIMG\_T0\_EN .

## 14.4.3 Timer as Periodic Alarm by APB

1. Configure the time-base counter following step 1 in Section 14.4.1 .
2. Configure the alarm following step 2 in Section 14.4.2 .
3. Enable auto reload by setting TIMG\_T0\_AUTORELOAD and configure the reload value via TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI .
4. Start the alarm by setting TIMG\_T0\_ALARM\_EN .
5. Handle the alarm interrupt (repeat on each alarm iteration).
- Clear the interrupt by setting the timer's corresponding bit in TIMG\_T0\_INT\_CLR .
- If the next alarm requires a new alarm value and reload value (i.e. different alarm interval per iteration), then TIMG\_T0ALARMLO\_REG , TIMG\_T0ALARMHI\_REG , TIMG\_T0\_LOAD\_LO, and TIMG\_T0\_LOAD\_HI should be reconfigured as needed. Otherwise, the aforementioned registers should remain unchanged.
- Re-enable the alarm by setting TIMG\_T0\_ALARM\_EN .
6. Stop the timer (on final alarm iteration).
- Clear the interrupt by setting the timer's corresponding bit in TIMG\_T0\_INT\_CLR .
- Disable the timer by clearing TIMG\_T0\_EN .

## 14.4.4 Timer as Periodic Alarm by ETM

1. Enable the ETM module’s clock
2. Map ETM event to ETM task (which means using the event to trigger the task)
- If TIMG\_T0\_AUTORELOAD is set to 1, map TIMERn\_EVT\_CNT\_CMP\_TIMER0 (n:0-1) to the TIMERn\_TASK\_ALARM\_START\_TIMER0 (n:0-1) by one ETM channel.
- If TIMG\_T0\_AUTORELOAD is set to 0, in addition to mapping TIMERn\_EVT\_CNT\_CMP\_TIMER0 (n:0-1) to the TIMERn\_TASK\_ALARM\_START\_TIMER0 (n:0-1), the TIMERn\_EVT\_CNT\_CMP\_TIMER0 (n:0-1) should also be mapped to TIMERn\_TASK\_CNT\_RELOAD\_TIMER0 (n:0-1) by another ETM channel.
3. Choose to enable the one or two ETM channels.
4. Set TIMER\_ETM\_EN to 1 to enable timer group’s ETM events and tasks.
5. Configure the time-base counter following step 1 in Section 14.4.1 .
6. Configure the alarm following step 2 in Section 14.4.2 .
7. Configure the reload value via TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI .
8. Handle the TIMERn\_EVT\_CNT\_CMP\_TIMER0 (n:0-1).
- When alarm generates, the TIMERn\_EVT\_CNT\_CMP\_TIMER0 (n:0-1) also generates, and the alarm generation will be disabled by the alarm.
- If TIMG\_T0\_AUTORELOAD is 1, the current counter value is overwritten by the reloaded value. The alarm generation will be reopen by TIMERn\_TASK\_ALARM\_START\_TIMER0 (n:0-1).
- If TIMG\_T0\_AUTORELOAD is 0, the current counter value is overwritten by the reloaded value because of the TIMERn\_TASK\_CNT\_RELOAD\_TIMER0 (n:0-1). The alarm generation will be reopen by TIMERn\_TASK\_ALARM\_START\_TIMER0 (n:0-1).
9. Stop the timer (on final alarm iteration).
- Disable the ETM channels used to map timer group's event and task
- Set TIMER\_ETM\_EN to 0.
- Clear the interrupt by setting the timer's corresponding bit in TIMG\_T0\_INT\_CLR .
- Disable the timer by clearing TIMG\_T0\_EN .

## 14.4.5 RTC\_SLOW\_CLK Frequency Calculation

1. One-shot frequency calculation
- Select the clock whose frequency is to be calculated (clock source of RTC\_SLOW\_CLK) via TIMG\_RTC\_CALI\_CLK\_SEL, and configure the time of calculation via TIMG\_RTC\_CALI\_MAX .
- Select one-shot frequency calculation by clearing TIMG\_RTC\_CALI\_START\_CYCLING, and enable the two counters via TIMG\_RTC\_CALI\_START .
- Once TIMG\_RTC\_CALI\_RDY becomes 1, read TIMG\_RTC\_CALI\_VALUE to get the value of XTAL\_CLK's counter, and calculate the frequency of RTC\_SLOW\_CLK according to the formula in Section 14.3.6 .

## 2. Periodic frequency calculation

- Select the clock whose frequency is to be calculated (clock source of RTC\_SLOW\_CLK) via TIMG\_RTC\_CALI\_CLK\_SEL, and configure the time of calculation via TIMG\_RTC\_CALI\_MAX .
- Select periodic frequency calculation by enabling TIMG\_RTC\_CALI\_START\_CYCLING .
- When TIMG\_RTC\_CALI\_CYCLING\_DATA\_VLD is 1, TIMG\_RTC\_CALI\_VALUE is valid.

## 3. Timeout

If the counter of RTC\_SLOW\_CLK cannot finish counting in TIMG\_RTC\_CALI\_TIMEOUT\_RST\_CNT cycles, TIMG\_RTC\_CALI\_TIMEOUT will be set to indicate a timeout.

## 14.5 Register Summary

The addresses in this section are relative to Timer Group base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                                          | Description                                                           | Address                                                       | Access                                                        |
|---------------------------------------------------------------|-----------------------------------------------------------------------|---------------------------------------------------------------|---------------------------------------------------------------|
| T0 control and configuration registers                        | T0 control and configuration registers                                | T0 control and configuration registers                        | T0 control and configuration registers                        |
| TIMG_T0CONFIG_REG                                             | Timer 0 configuration register                                        | 0x0000                                                        | varies                                                        |
| TIMG_T0LO_REG                                                 | Timer 0 current value, low 32 bits                                    | 0x0004                                                        | RO                                                            |
| TIMG_T0HI_REG                                                 | Timer 0 current value, high 22 bits                                   | 0x0008                                                        | RO                                                            |
| TIMG_T0UPDATE_REG                                             | Write to copy current timer value to TIMGn_T0LO_REG or TIMGn_T0HI_REG | 0x000C                                                        | R/W/SC                                                        |
| TIMG_T0ALARMLO_REG                                            | Timer 0 alarm value, low 32 bits                                      | 0x0010                                                        | R/W                                                           |
| TIMG_T0ALARMHI_REG                                            | Timer 0 alarm value, high bits                                        | 0x0014                                                        | R/W                                                           |
| TIMG_T0LOADLO_REG                                             | Timer 0 reload value, low 32 bits                                     | 0x0018                                                        | R/W                                                           |
| TIMG_T0LOADHI_REG                                             | Timer 0 reload value, high 22 bits                                    | 0x001C                                                        | R/W                                                           |
| TIMG_T0LOAD_REG                                               | Write to reload timer from TIMG_T0LOADLO_REG  or TIMG_T0LOADHI_REG    | 0x0020                                                        | WT                                                            |
| WDT control and configuration registers                       | WDT control and configuration registers                               | WDT control and configuration registers                       | WDT control and configuration registers                       |
| TIMG_WDTCONFIG0_REG                                           | Watchdog timer configuration register                                 | 0x0048                                                        | varies                                                        |
| TIMG_WDTCONFIG1_REG                                           | Watchdog timer prescaler register                                     | 0x004C                                                        | varies                                                        |
| TIMG_WDTCONFIG2_REG                                           | Watchdog timer stage 0 timeout value                                  | 0x0050                                                        | R/W                                                           |
| TIMG_WDTCONFIG3_REG                                           | Watchdog timer stage 1 timeout value                                  | 0x0054                                                        | R/W                                                           |
| TIMG_WDTCONFIG4_REG                                           | Watchdog timer stage 2 timeout value                                  | 0x0058                                                        | R/W                                                           |
| TIMG_WDTCONFIG5_REG                                           | Watchdog timer stage 3 timeout value                                  | 0x005C                                                        | R/W                                                           |
| TIMG_WDTFEED_REG                                              | Write to feed the watchdog timer                                      | 0x0060                                                        | WT                                                            |
| TIMG_WDTWPROTECT_REG                                          | Watchdog write protect register                                       | 0x0064                                                        | R/W                                                           |
| RTC frequency calculation control and configuration registers | RTC frequency calculation control and configuration registers         | RTC frequency calculation control and configuration registers | RTC frequency calculation control and configuration registers |
| TIMG_RTCCALICFG_REG                                           | RTC frequency calculation configuration regis ter 0                  | 0x0068                                                        | varies                                                        |
| TIMG_RTCCALICFG1_REG                                          | RTC frequency calculation configuration regis ter 1                  | 0x006C                                                        | RO                                                            |
| TIMG_RTCCALICFG2_REG                                          | RTC frequency calculation configuration regis ter 2                  | 0x0080                                                        | varies                                                        |
| Interrupt registers                                           | Interrupt registers                                                   | Interrupt registers                                           | Interrupt registers                                           |
| TIMG_INT_ENA_TIMERS_REG                                       | Interrupt enable bits                                                 | 0x0070                                                        | R/W                                                           |
| TIMG_INT_RAW_TIMERS_REG                                       | Raw interrupt status                                                  | 0x0074                                                        | R/SS/WTC                                                      |
| TIMG_INT_ST_TIMERS_REG                                        | Masked interrupt status                                               | 0x0078                                                        | RO                                                            |
| TIMG_INT_CLR_TIMERS_REG                                       | Interrupt clear bits                                                  | 0x007C                                                        | WT                                                            |
| Version register                                              | Version register                                                      | Version register                                              | Version register                                              |
| TIMG_NTIMERS_DATE_REG                                         | Timer version control register                                        | 0x00F8                                                        | R/W                                                           |
| Clock configuration registers                                 |                                                                       |                                                               |                                                               |

| Name            | Description                     | Address   | Access   |
|-----------------|---------------------------------|-----------|----------|
| TIMG_REGCLK_REG | Timer group clock gate register | 0x00FC    | R/W      |

Submit Documentation Feedback

## 14.6 Registers

The addresses in this section are relative to Timer Group base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 14.1. TIMG\_T0CONFIG\_REG (0x0000)

![Image](images/14_Chapter_14_img004_ddbf2443.png)

TIMG\_T0\_ALARM\_EN Configures whether or not to enable the timer 0 alarm function. This bit will be automatically cleared once an alarm occurs.

0: Disable

1: Enable

(R/W/SC)

TIMG\_T0\_DIVCNT\_RST Configures whether or not to reset the timer 0 ’s clock divider counter.

0: No effect

1: Reset

(WT)

TIMG\_T0\_DIVIDER Represents the timer 0 clock (T0\_clk) prescaler value. (R/W)

TIMG\_T0\_AUTORELOAD Configures whether or not to enable the timer 0 auto-reload function at the time of alarm.

0: No effect

1: Enable

(R/W)

TIMG\_T0\_INCREASE Configures the counting direction of the timer 0 time-base counter.

0: Decrement

1: Increment

(R/W)

TIMG\_T0\_EN Configures whether or not to enable the timer 0 time-base counter.

0: Disable

1: Enable

(R/W/SS/SC)

## Register 14.2. TIMG\_T0LO\_REG (0x0004)

![Image](images/14_Chapter_14_img005_c092e131.png)

TIMG\_T0\_LO Represents the low 32 bits of the time-base counter of timer 0. Valid only after writing to TIMG\_T0UPDATE\_REG .

Measurement unit: T0\_clk.

(RO)

## Register 14.3. TIMG\_T0HI\_REG (0x0008)

![Image](images/14_Chapter_14_img006_61b9d535.png)

TIMG\_T0\_HI Represents the high 22 bits of the time-base counter of timer 0. Valid only after writing to TIMG\_T0UPDATE\_REG .

Measurement unit: T0\_clk.

(RO)

Register 14.4. TIMG\_T0UPDATE\_REG (0x000C)

![Image](images/14_Chapter_14_img007_e93a6c12.png)

TIMG\_T0\_UPDATE Configures to latch the counter value.

0: Latch

1: Latch

(R/W/SC)

Register 14.5. TIMG\_T0ALARMLO\_REG (0x0010)

![Image](images/14_Chapter_14_img008_59b38dbd.png)

TIMG\_T0\_ALARM\_LO Configures the low 32 bits of timer 0 alarm trigger time-base counter value. Valid only when TIMG\_T0\_ALARM\_EN is 1.

Measurement unit: T0\_clk.

(R/W)

Register 14.6. TIMG\_T0ALARMHI\_REG (0x0014)

![Image](images/14_Chapter_14_img009_9973ce2d.png)

TIMG\_T0\_ALARM\_HI Configures the high 22 bits of timer 0 alarm trigger time-base counter value.

Valid only when TIMG\_T0\_ALARM\_EN is 1.

Measurement unit: T0\_clk.

(R/W)

## Register 14.7. TIMG\_T0LOADLO\_REG (0x0018)

![Image](images/14_Chapter_14_img010_ad121524.png)

TIMG\_T0\_LOAD\_LO Configures low 32 bits of the value that a reload will load onto timer 0 time- base counter.

Measurement unit: T0\_clk.

(R/W)

Register 14.8. TIMG\_T0LOADHI\_REG (0x001C)

![Image](images/14_Chapter_14_img011_8fc3fe76.png)

TIMG\_T0\_LOAD\_HI Configures high 22 bits of the value that a reload will load onto timer 0 time- base counter.

Measurement unit: T0\_clk.

(R/W)

## Register 14.9. TIMG\_T0LOAD\_REG (0x0020)

![Image](images/14_Chapter_14_img012_9350d52d.png)

TIMG\_T0\_LOAD Write any value to trigger a timer 0 time-base counter reload. (WT)

## Register 14.10. TIMG\_WDTCONFIG0\_REG (0x0048)

|   31 |   30 29 |   28 27 |   26 25 |   24 23 |   22 |   21 20 |     | 18   | 15   |   14 |   13 |   12 11 |                         | 0     |
|------|---------|---------|---------|---------|------|---------|-----|------|------|------|------|---------|-------------------------|-------|
|    0 |       0 |       0 |       0 |       0 |    0 |       0 | 0x1 |      | 0x1  |    1 |    0 |       0 | 0 0 0 0 0 0 0 0 0 0 0 0 | Reset |

![Image](images/14_Chapter_14_img013_746cb61c.png)

TIMG\_WDT\_APPCPU\_RESET\_EN Configures whether to mask the CPU reset generated by MWDT. Valid only when write protection is disabled.

0: Mask

1: Unmask

(R/W)

TIMG\_WDT\_PROCPU\_RESET\_EN Configures whether to mask the CPU reset generated by MWDT.

Valid only when write protection is disabled.

0: Mask

1: Unmask

(R/W)

TIMG\_WDT\_FLASHBOOT\_MOD\_EN Configures whether to enable flash boot protection.

0: Disable

1: Enable

(R/W)

TIMG\_WDT\_SYS\_RESET\_LENGTH Configures the system reset signal length. Valid only when write protection is disabled.

Measurement unit: mwdt\_clk.

| 0: 8   | 4: 40   |
|--------|---------|
| 1: 16  | 5: 64   |
| 2: 24  | 6: 128  |
| 3: 32  | 7: 256  |

(R/W)

Continued on the next page...

ESP32-C6 TRM (Version 1.1)

## Register 14.10. TIMG\_WDTCONFIG0\_REG (0x0048)

## Continued from the previous page...

TIMG\_WDT\_CPU\_RESET\_LENGTH Configures the CPU reset signal length. Valid only when write protection is disabled. Measurement unit: mwdt\_clk.

| 0: 8   | 4: 40   |
|--------|---------|
| 1: 16  | 5: 64   |
| 2: 24  | 6: 128  |
| 3: 32  | 7: 256  |

(R/W)

TIMG\_WDT\_CONF\_UPDATE\_EN Configures to update the WDT configuration registers.

- 0: No effect
- 1: Update

(WT)

TIMG\_WDT\_STG3 Configures the timeout action of stage 3. See details in TIMG\_WDT\_STG0. Valid only when write protection is disabled. (R/W)

TIMG\_WDT\_STG2 Configures the timeout action of stage 2. See details in TIMG\_WDT\_STG0. Valid only when write protection is disabled. (R/W)

TIMG\_WDT\_STG1 Configures the timeout action of stage 1. See details in TIMG\_WDT\_STG0. Valid only when write protection is disabled. (R/W)

TIMG\_WDT\_STG0 Configures the timeout action of stage 0. Valid only when write protection is disabled.

- 0: No effect
- 1: Interrupt
- 2: Reset CPU
- 3: Reset system

(R/W)

TIMG\_WDT\_EN Configures whether or not to enable the MWDT. Valid only when write protection is disabled.

- 0: Disable
- 1: Enable

(R/W)

## Register 14.11. TIMG\_WDTCONFIG1\_REG (0x004C)

![Image](images/14_Chapter_14_img014_b232283f.png)

TIMG\_WDT\_DIVCNT\_RST Configures whether to reset WDT’s clock divider counter.

0: No effect

1: Reset

(WT)

TIMG\_WDT\_CLK\_PRESCALE Configures MWDT clock prescaler value. Valid only when write protec- tion is disabled.

MWDT clock period = MWDT’s clock source period * TIMG\_WDT\_CLK\_PRESCALE.

(R/W)

Register 14.12. TIMG\_WDTCONFIG2\_REG (0x0050)

![Image](images/14_Chapter_14_img015_d1157d3e.png)

TIMG\_WDT\_STG0\_HOLD Configures the stage 0 timeout value. Valid only when write protection is disabled.

Measurement unit: mwdt\_clk.

(R/W)

## Register 14.13. TIMG\_WDTCONFIG3\_REG (0x0054)

TIMG\_WDT\_STG1\_HOLD

![Image](images/14_Chapter_14_img016_a1442849.png)

TIMG\_WDT\_STG1\_HOLD Configures the stage 1 timeout value. Valid only when write protection is disabled.

Measurement unit: mwdt\_clk.

(R/W)

Register 14.14. TIMG\_WDTCONFIG4\_REG (0x0058)

![Image](images/14_Chapter_14_img017_c808a253.png)

![Image](images/14_Chapter_14_img018_bdbf8b17.png)

TIMG\_WDT\_STG2\_HOLD Configures the stage 2 timeout value. Valid only when write protection is disabled.

Measurement unit: mwdt\_clk.

(R/W)

## Register 14.15. TIMG\_WDTCONFIG5\_REG (0x005C)

![Image](images/14_Chapter_14_img019_c6bd7300.png)

![Image](images/14_Chapter_14_img020_11fb6ee8.png)

TIMG\_WDT\_STG3\_HOLD Configures the stage 3 timeout value. Valid only when write protection is disabled.

Measurement unit: mwdt\_clk.

(R/W)

## Register 14.16. TIMG\_WDTFEED\_REG (0x0060)

![Image](images/14_Chapter_14_img021_257a6072.png)

![Image](images/14_Chapter_14_img022_803a6c4f.png)

TIMG\_WDT\_FEED Write any value to feed the MWDT. Valid only when write protection is disabled. (WT)

## Register 14.17. TIMG\_WDTWPROTECT\_REG (0x0064)

![Image](images/14_Chapter_14_img023_edac6d57.png)

![Image](images/14_Chapter_14_img024_aaf978b6.png)

TIMG\_WDT\_WKEY Configures a different value than its reset value to enable write protection. (R/W)

## Register 14.18. TIMG\_RTCCALICFG\_REG (0x0068)

![Image](images/14_Chapter_14_img025_fdcc7886.png)

TIMG\_RTC\_CALI\_START\_CYCLING Configures the frequency calculation mode.

0: one-shot frequency calculation

1: periodic frequency calculation.

(R/W)

TIMG\_RTC\_CALI\_CLK\_SEL Configures to select the clock to be calibrated

0: RTC\_SLOW\_CLK

1: RC\_FAST\_DIV\_CLK

2: XTAL32K\_CLK

(R/W)

TIMG\_RTC\_CALI\_RDY Represents whether one-shot frequency calculation is done.

0: Not done

1: Done

(RO)

TIMG\_RTC\_CALI\_MAX Configures the time to calculate RTC slow clock’s frequency.

Measurement unit: XTAL\_CLK.

(R/W)

TIMG\_RTC\_CALI\_START Configures whether to enable one-shot frequency calculation.

0: Disable

1: Enable

(R/W)

Register 14.19. TIMG\_RTCCALICFG1\_REG (0x006C)

![Image](images/14_Chapter_14_img026_b476d386.png)

TIMG\_RTC\_CALI\_CYCLING\_DATA\_VLD Represents whether periodic frequency calculation is done.

0: Not done

1: Done

(RO)

TIMG\_RTC\_CALI\_VALUE Represents the value countered by XTAL\_CLK when one-shot or periodic frequency calculation is done. It is used to calculate RTC slow clock's frequency. (RO)

Register 14.20. TIMG\_RTCCALICFG2\_REG (0x0080)

![Image](images/14_Chapter_14_img027_1b19011c.png)

TIMG\_RTC\_CALI\_TIMEOUT Represents whether RTC frequency calculation is timeout.

0: No timeout

- 1: Timeout

(RO)

TIMG\_RTC\_CALI\_TIMEOUT\_RST\_CNT Configures the cycles that reset frequency calculation time- out.

Measurement unit: XTAL\_CLK.

(R/W)

TIMG\_RTC\_CALI\_TIMEOUT\_THRES Configures the threshold value for the RTC frequency calculation timer. If the timer's value exceeds this threshold, a timeout is triggered.

Measurement unit: XTAL\_CLK.

(R/W)

## Register 14.21. TIMG\_INT\_ENA\_TIMERS\_REG (0x0070)

![Image](images/14_Chapter_14_img028_2fc1bb8a.png)

TIMG\_T0\_INT\_ENA Write 1 to enable the TIMG\_T0\_INT interrupt. (R/W)

TIMG\_WDT\_INT\_ENA Write 1 to enable the TIMG\_WDT\_INT interrupt. (R/W)

Register 14.22. TIMG\_INT\_RAW\_TIMERS\_REG (0x0074)

![Image](images/14_Chapter_14_img029_0445a09f.png)

TIMG\_T0\_INT\_RAW The raw interrupt status bit of the TIMG\_T0\_INT interrupt. (R/SS/WTC)

TIMG\_WDT\_INT\_RAW The raw interrupt status bit of the TIMG\_WDT\_INT interrupt. (R/SS/WTC)

## Register 14.23. TIMG\_INT\_ST\_TIMERS\_REG (0x0078)

![Image](images/14_Chapter_14_img030_05d74bb0.png)

TIMG\_T0\_INT\_ST The masked interrupt status bit of the TIMG\_T0\_INT interrupt. (RO)

TIMG\_WDT\_INT\_ST The masked interrupt status bit of the TIMG\_WDT\_INT interrupt. (RO)

Register 14.24. TIMG\_INT\_CLR\_TIMERS\_REG (0x007C)

![Image](images/14_Chapter_14_img031_cc99304b.png)

TIMG\_T0\_INT\_CLR Write 1 to clear the TIMG\_T0\_INT interrupt. (WT)

TIMG\_WDT\_INT\_CLR Write 1 to clear the TIMG\_WDT\_INT interrupt. (WT)

Register 14.25. TIMG\_NTIMERS\_DATE\_REG (0x00F8)

![Image](images/14_Chapter_14_img032_72b27936.png)

TIMG\_NTIMGS\_DATE Version control register (R/W)

## Register 14.26. TIMG\_REGCLK\_REG (0x00FC)

![Image](images/14_Chapter_14_img033_c91519b6.png)

TIMG\_ETM\_EN Configures whether to enable timer’s ETM task and event.

- 0: Disable
- 1: Enable

(R/W)

TIMG\_WDT\_CLK\_IS\_ACTIVE Configures whether to enable WDT’s clock.

- 0: Disable
- 1: Enable

(R/W)

TIMG\_TIMER\_CLK\_IS\_ACTIVE Configures whether to enable Timer 0’s clock.

- 0: Disable
- 1: Enable

(R/W)

- TIMG\_CLK\_EN Configures whether to enable gate clock signal for registers.
- 0: Force clock on for registers
- 1: Support clock only when registers are read or written to by software.

(R/W)
