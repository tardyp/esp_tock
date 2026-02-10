---
chapter: 11
title: "Chapter 11"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 11

## Timer Group (TIMG)

## 11.1 Overview

General purpose timers can be used to precisely time an interval, trigger an interrupt after a particular interval (periodically and aperiodically), or act as a hardware clock. As shown in Figure 11.1-1, the ESP32-C3 chip contains two timer groups, namely timer group 0 and timer group 1. Each timer group consists of one general purpose timer referred to as T0 and one Main System Watchdog Timer. All general purpose timers are based on 16-bit prescalers and 54-bit auto-reload-capable up-down counters.

Figure 11.1-1. Timer Units within Groups

![Image](images/11_Chapter_11_img001_434006fa.png)

Note that while the Main System Watchdog Timer registers are described in this chapter, their functional description is included in the Chapter 12 Watchdog Timers (WDT). Therefore, the term 'timers' within this chapter refers to the general purpose timers.

The timers’ features are summarized as follows:

- A 16-bit clock prescaler, from 2 to 65536
- A 54-bit time-base counter programmable to incrementing or decrementing
- Able to read real-time value of the time-base counter
- Halting and resuming the time-base counter
- Programmable alarm generation
- Timer value reload (Auto-reload at alarm or software-controlled instant reload)
- Level interrupt generation

![Image](images/11_Chapter_11_img002_53e9adba.png)

## 11.2 Functional Description

Figure 11.2-1. Timer Group Architecture

![Image](images/11_Chapter_11_img003_e2e3cd13.png)

Figure11.2-1 is a diagram of timer T0 in a timer group. T0 contains a clock selector, a 16-bit integer divider as a prescaler, a timer-based counter and a comparator for alarm generation.

## 11.2.1 16-bit Prescaler and Clock Selection

The timer can select between the APB clock (APB\_CLK) or external clock (XTAL\_CLK) as its clock source by setting the TIMG\_T0\_USE\_XTAL field of the TIMG\_T0CONFIG\_REG register. The selected clock is switched on by setting TIMG\_TIMER\_CLK\_IS\_ACTIVE field of the TIMG\_REGCLK\_REG register to 1 and switched off by setting it to 0. The clock is then divided by a 16-bit prescaler to generate the time-base counter clock (TB\_CLK) used by the time-base counter. When the TIMG\_T0\_DIVIDER field is configured as 2 ~ 65536, the divisor of the prescaler would be 2 ~ 65536. Note that programming value 0 to TIMG\_T0\_DIVIDER will result in the divisor being 65536. When the TIMG\_T0\_DIVIDER is set to 1, the actual divisor is 2 so the timer counter value represents the half of real time.

To modify the 16-bit prescaler, please first configure the TIMG\_T0\_DIVIDER field, and then set TIMG\_T0\_DIVIDER\_RST to 1. Meanwhile, the timer must be disabled (i.e. TIMG\_T0\_EN should be cleared). Otherwise, the result can be unpredictable.

## 11.2.2 54-bit Time-base Counter

The 54-bit time-base counters are based on TB\_CLK and can be configured to increment or decrement via the TIMG\_T0\_INCREASE field. The time-base counter can be enabled or disabled by setting or clearing the TIMG\_T0\_EN field, respectively. When enabled, the time-base counter increments or decrements on each cycle of TB\_CLK. When disabled, the time-base counter is essentially frozen. Note that the TIMG\_T0\_INCREASE field can be changed while TIMG\_T0\_EN is set and this will cause the time-base counter to change direction instantly.

To read the 54-bit value of the time-base counter, the timer value must be latched to two registers before being read by the CPU (due to the CPU being 32-bit). By writing any value to the TIMG\_T0UPDATE\_REG, the current value of the 54-bit timer starts to be latched into the TIMG\_T0LO\_REG and TIMG\_T0HI\_REG registers containing the lower 32-bits and higher 22-bits, respectively. When TIMG\_T0UPDATE\_REG is cleared by hardware, it indicates the latch operation has been completed and current timer value can be read from the TIMG\_T0LO\_REG and TIMG\_T0HI\_REG registers. TIMG\_T0LO\_REG and TIMG\_T0HI\_REG registers will remain unchanged for the CPU to read in its own time until TIMG\_T0UPDATE\_REG is written to again.

## 11.2.3 Alarm Generation

A timer can be configured to trigger an alarm when the timer's current value matches the alarm value. An alarm will cause an interrupt to occur and (optionally) an automatic reload of the timer's current value (see Section 11.2.4).

The 54-bit alarm value is configured using TIMG\_T0ALARMLO\_REG and TIMG\_T0ALARMHI\_REG, which represent the lower 32-bits and higher 22-bits of the alarm value, respectively. However, the configured alarm value is ineffective until the alarm is enabled by setting the TIMG\_T0\_ALARM\_EN field. To avoid alarm being enabled 'too late' (i.e. the timer value has already passed the alarm value when the alarm is enabled), the hardware will trigger the alarm immediately if the current timer value is higher than the alarm value (within a defined range) when the up-down counter increments, or lower than the alarm value (within a defined range) when the up-down counter decrements. Table 11.2-1 and Table 11.2-2 show the relationship between the current value of the timer, the alarm value, and when an alarm is triggered.The current time value and the alarm value are defined as follows:

- TIMG\_VALUE = {TIMG\_T0HI\_REG , TIMG\_T0LO\_REG}
- ALARM\_VALUE = {TIMG\_T0ALARMHI\_REG , TIMG\_T0ALARMLO\_REG}

Table 11.2-1. Alarm Generation When Up-Down Counter Increments

|   Scenario | Range                                 | Alarm                                                                                                                                           |
|------------|---------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|
|          1 | ALARM_VALUE  −  TIMG_VALUE > 2 53     | Triggered                                                                                                                                       |
|          2 | 0 < ALARM_VALUE  −  TIMG_VALUE ≤ 2 53 | Triggered when the up-down counter counts TIMG_VALUE up to ALARM_VALUE                                                                          |
|          3 | 0 ≤ TIMG_VALUE  −  ALARM_VALUE < 2 53 | Triggered                                                                                                                                       |
|          4 | TIMG_VALUE  −  ALARM_VALUE ≥ 2 53     | Triggered when the up-down counter restarts counting up from 0 after reaching the timer’s maximum value and counts TIMG_VALUE up to ALARM_VALUE |

Table 11.2-2. Alarm Generation When Up-Down Counter Decrements

|   Scenario | Range                                 | Alarm                                                                                                                                                               |
|------------|---------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|          5 | TIMG_VALUE  −  ALARM_VALUE > 2 53     | Triggered                                                                                                                                                           |
|          6 | 0 < TIMG_VALUE  −  ALARM_VALUE ≤ 2 53 | Triggered when the up-down counter counts TIMG_VALUE down to ALARM_VALUE                                                                                            |
|          7 | 0 ≤ ALARM_VALUE  −  TIMG_VALUE < 2 53 | Triggered                                                                                                                                                           |
|          8 | ALARM_VALUE  −  TIMG_VALUE ≥ 2 53     | Triggered when the up-down counter restarts counting down from the timer’s maximum value after reaching the minimum value and counts TIMG_VALUE down to ALARM_VALUE |

When an alarm occurs, the TIMG\_T0\_ALARM\_EN field is automatically cleared and no alarm will occur again until the TIMG\_T0\_ALARM\_EN is set next time.

## 11.2.4 Timer Reload

A timer is reloaded when a timer's current value is overwritten with a reload value stored in the TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI fields that correspond to the lower 32-bits and higher 22-bits of the timer's new value, respectively. However, writing a reload value to TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI will not cause the timer's current value to change. Instead, the reload value is ignored by the timer until a reload event occurs. A reload event can be triggered either by a software instant reload or an auto-reload at alarm.

A software instant reload is triggered by the CPU writing any value to TIMG\_T0LOAD\_REG, which causes the timer's current value to be instantly reloaded. If TIMG\_T0\_EN is set, the timer will continue incrementing or decrementing from the new value. If TIMG\_T0\_EN is cleared, the timer will remain frozen at the new value until counting is re-enabled.

An auto-reload at alarm will cause a timer reload when an alarm occurs, thus allowing the timer to continue incrementing or decrementing from the reload value. This is generally useful for resetting the timer's value when using periodic alarms. To enable auto-reload at alarm, the TIMG\_T0\_AUTORELOAD field should be set. If not enabled, the timer's value will continue to increment or decrement past the alarm value after an alarm.

## 11.2.5 RTC\_SLOW\_CLK Frequency Calculation

Via XTAL\_CLK, a timer could calculate the frequency of clock sources for RTC\_SLOW\_CLK (i.e. RC\_RTC\_SLOW\_CLK, RC\_FAST\_DIV\_CLK, and XTAL32K\_CLK) as follows:

1. Start periodic or one-shot frequency calculation;
2. Once receiving the signal to start calculation, the counter of XTAL\_CLK and the counter of RTC\_SLOW\_CLK begin to work at the same time. When the counter of RTC\_SLOW\_CLK counts to C0, the two counters stop counting simultaneously;
3. Assume the value of XTAL\_CLK's counter is C1, and the frequency of RTC\_SLOW\_CLK would be calculated as: f \_ rtc = C0×f \_ XT AL \_ CLK C1

## 11.2.6 Interrupts

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

## 11.3 Configuration and Usage

## 11.3.1 Timer as a Simple Clock

1. Configure the time-base counter
- Select clock source by setting or clearing TIMG\_T0\_USE\_XTAL field.
- Configure the 16-bit prescaler by setting TIMG\_T0\_DIVIDER .
- Configure the timer direction by setting or clearing TIMG\_T0\_INCREASE .
- Set the timer's starting value by writing the starting value to TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI, then reloading it into the timer by writing any value to TIMG\_T0LOAD\_REG .
2. Start the timer by setting TIMG\_T0\_EN .
3. Get the timer’s current value.
- Write any value to TIMG\_T0UPDATE\_REG to latch the timer's current value.
- Wait until TIMG\_T0UPDATE\_REG is cleared by hardware.
- Read the latched timer value from TIMG\_T0LO\_REG and TIMG\_T0HI\_REG .

## 11.3.2 Timer as One-shot Alarm

1. Configure the time-base counter following step 1 of Section 11.3.1 .
2. Configure the alarm.
- Configure the alarm value by setting TIMG\_T0ALARMLO\_REG and TIMG\_T0ALARMHI\_REG .
- Enable interrupt by setting TIMG\_T0\_INT\_ENA .
3. Disable auto reload by clearing TIMG\_T0\_AUTORELOAD .
4. Start the alarm by setting TIMG\_T0\_ALARM\_EN .

5. Handle the alarm interrupt.
- Clear the interrupt by setting the timer's corresponding bit in TIMG\_T0\_INT\_CLR .
- Disable the timer by clearing TIMG\_T0\_EN .

## 11.3.3 Timer as Periodic Alarm

1. Configure the time-base counter following step 1 in Section 11.3.1 .
2. Configure the alarm following step 2 in Section 11.3.2 .
3. Enable auto reload by setting TIMG\_T0\_AUTORELOAD and configure the reload value via TIMG\_T0\_LOAD\_LO and TIMG\_T0\_LOAD\_HI .
4. Start the alarm by setting TIMG\_T0\_ALARM\_EN .
5. Handle the alarm interrupt (repeat on each alarm iteration).
- Clear the interrupt by setting the timer's corresponding bit in TIMG\_T0\_INT\_CLR .
- If the next alarm requires a new alarm value and reload value (i.e. different alarm interval per iteration), then TIMG\_T0ALARMLO\_REG , TIMG\_T0ALARMHI\_REG , TIMG\_T0\_LOAD\_LO, and TIMG\_T0\_LOAD\_HI should be reconfigured as needed. Otherwise, the aforementioned registers should remain unchanged.
- Re-enable the alarm by setting TIMG\_T0\_ALARM\_EN .
6. Stop the timer (on final alarm iteration).
- Clear the interrupt by setting the timer's corresponding bit in TIMG\_T0\_INT\_CLR .
- Disable the timer by clearing TIMG\_T0\_EN .

## 11.3.4 RTC\_SLOW\_CLK Frequency Calculation

1. One-shot frequency calculation
- Select the clock whose frequency is to be calculated (clock source of RTC\_SLOW\_CLK) via TIMG\_RTC\_CALI\_CLK\_SEL, and configure the time of calculation via TIMG\_RTC\_CALI\_MAX .
- Select one-shot frequency calculation by clearing TIMG\_RTC\_CALI\_START\_CYCLING, and enable the two counters via TIMG\_RTC\_CALI\_START .
- Once TIMG\_RTC\_CALI\_RDY becomes 1, read TIMG\_RTC\_CALI\_VALUE to get the value of XTAL\_CLK's counter, and calculate the frequency of RTC\_SLOW\_CLK.
2. Periodic frequency calculation
- Select the clock whose frequency is to be calculated (clock source of RTC\_SLOW\_CLK) via TIMG\_RTC\_CALI\_CLK\_SEL, and configure the time of calculation via TIMG\_RTC\_CALI\_MAX .
- Select periodic frequency calculation by enabling TIMG\_RTC\_CALI\_START\_CYCLING .
- When TIMG\_RTC\_CALI\_CYCLING\_DATA\_VLD is 1, TIMG\_RTC\_CALI\_VALUE is valid.

## 3. Timeout

If the counter of RTC\_SLOW\_CLK cannot finish counting in TIMG\_RTC\_CALI\_TIMEOUT\_RST\_CNT cycles, TIMG\_RTC\_CALI\_TIMEOUT will be set to indicate a timeout.

## 11.4 Register Summary

The addresses in this section are relative to Timer Group base addresses (one for Timer Group 0 and another one for Timer Group 1) provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                                          | Description                                                   | Address                                                       | Access                                                        |
|---------------------------------------------------------------|---------------------------------------------------------------|---------------------------------------------------------------|---------------------------------------------------------------|
| T0 control and configuration registers                        | T0 control and configuration registers                        | T0 control and configuration registers                        | T0 control and configuration registers                        |
| TIMG_T0CONFIG_REG                                             | Timer 0 configuration register                                | 0x0000                                                        | varies                                                        |
| TIMG_T0LO_REG                                                 | Timer 0 current value, low 32 bits                            | 0x0004                                                        | RO                                                            |
| TIMG_T0HI_REG                                                 | Timer 0 current value, high 22 bits                           | 0x0008                                                        | RO                                                            |
| TIMG_T0UPDATE_REG                                             | Write to copy current timer value to TIMGn_T0_(LO/HI)_REG     | 0x000C                                                        | R/W/SC                                                        |
| TIMG_T0ALARMLO_REG                                            | Timer 0 alarm value, low 32 bits                              | 0x0010                                                        | R/W                                                           |
| TIMG_T0ALARMHI_REG                                            | Timer 0 alarm value, high bits                                | 0x0014                                                        | R/W                                                           |
| TIMG_T0LOADLO_REG                                             | Timer 0 reload value, low 32 bits                             | 0x0018                                                        | R/W                                                           |
| TIMG_T0LOADHI_REG                                             | Timer 0 reload value, high 22 bits                            | 0x001C                                                        | R/W                                                           |
| TIMG_T0LOAD_REG                                               | Write to reload timer from TIMG_T0_(LOADLO/LOADHI)_REG        | 0x0020                                                        | WT                                                            |
| WDT control and configuration registers                       | WDT control and configuration registers                       | WDT control and configuration registers                       | WDT control and configuration registers                       |
| TIMG_WDTCONFIG0_REG                                           | Watchdog timer configuration register                         | 0x0048                                                        | varies                                                        |
| TIMG_WDTCONFIG1_REG                                           | Watchdog timer prescaler register                             | 0x004C                                                        | varies                                                        |
| TIMG_WDTCONFIG2_REG                                           | Watchdog timer stage 0 timeout value                          | 0x0050                                                        | R/W                                                           |
| TIMG_WDTCONFIG3_REG                                           | Watchdog timer stage 1 timeout value                          | 0x0054                                                        | R/W                                                           |
| TIMG_WDTCONFIG4_REG                                           | Watchdog timer stage 2 timeout value                          | 0x0058                                                        | R/W                                                           |
| TIMG_WDTCONFIG5_REG                                           | Watchdog timer stage 3 timeout value                          | 0x005C                                                        | R/W                                                           |
| TIMG_WDTFEED_REG                                              | Write to feed the watchdog timer                              | 0x0060                                                        | WT                                                            |
| TIMG_WDTWPROTECT_REG                                          | Watchdog write protect register                               | 0x0064                                                        | R/W                                                           |
| RTC frequency calculation control and configuration registers | RTC frequency calculation control and configuration registers | RTC frequency calculation control and configuration registers | RTC frequency calculation control and configuration registers |
| TIMG_RTCCALICFG_REG                                           | RTC frequency calculation configuration register 0            | 0x0068                                                        | varies                                                        |
| TIMG_RTCCALICFG1_REG                                          | RTC frequency calculation configuration register 1            | 0x006C                                                        | RO                                                            |
| TIMG_RTCCALICFG2_REG                                          | RTC frequency calculation configuration register 2            | 0x0080                                                        | varies                                                        |
| Interrupt registers                                           | Interrupt registers                                           | Interrupt registers                                           | Interrupt registers                                           |
| TIMG_INT_ENA_TIMERS_REG                                       | Interrupt enable bits                                         | 0x0070                                                        | R/W                                                           |
| TIMG_INT_RAW_TIMERS_REG                                       | Raw interrupt status                                          | 0x0074                                                        | R/SS/WTC                                                      |
| TIMG_INT_ST_TIMERS_REG                                        | Masked interrupt status                                       | 0x0078                                                        | RO                                                            |
| TIMG_INT_CLR_TIMERS_REG                                       | Interrupt clear bits                                          | 0x007C                                                        | WT                                                            |
| Version register                                              | Version register                                              | Version register                                              | Version register                                              |
| TIMG_NTIMERS_DATE_REG                                         | Timer version control register                                | 0x00F8                                                        | R/W                                                           |
| Clock configuration registers                                 | Clock configuration registers                                 | Clock configuration registers                                 | Clock configuration registers                                 |
| TIMG_REGCLK_REG                                               | Timer group clock gate register                               | 0x00FC                                                        | R/W                                                           |

## 11.5 Registers

The addresses in this section are relative to Timer Group base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 11.1. TIMG\_T0CONFIG\_REG (0x0000)

![Image](images/11_Chapter_11_img004_08cc56ed.png)

TIMG\_T0\_USE\_XTAL 1: Use XTAL\_CLK as the source clock of timer group. 0: Use APB\_CLK as the source clock of timer group. (R/W)

TIMG\_T0\_ALARM\_EN When set, the alarm is enabled. This bit is automatically cleared once an alarm occurs. (R/W/SC)

TIMG\_T0\_DIVIDER\_RST When set, Timer 0 ’s clock divider counter will be reset. (WT)

TIMG\_T0\_DIVIDER Timer 0 clock (T0\_clk) prescaler value. (R/W)

TIMG\_T0\_AUTORELOAD When set, Timer 0 auto-reload at alarm is enabled. (R/W)

TIMG\_T0\_INCREASE When set, the Timer 0 time-base counter will increment every clock tick. When cleared, the Timer 0 time-base counter will decrement. (R/W)

TIMG\_T0\_EN When set, the Timer 0 time-base counter is enabled. (R/W)

Register 11.2. TIMG\_T0LO\_REG (0x0004)

![Image](images/11_Chapter_11_img005_f881eabb.png)

TIMG\_T0\_LO After writing to TIMG\_T0UPDATE\_REG, the low 32 bits of the time-base counter of Timer 0 can be read here. (RO)

Register 11.3. TIMG\_T0HI\_REG (0x0008)

![Image](images/11_Chapter_11_img006_a99c658c.png)

TIMG\_T0\_HI After writing to TIMG\_T0UPDATE\_REG, the high 22 bits of the time-base counter of Timer 0 can be read here. (RO)

Register 11.4. TIMG\_T0UPDATE\_REG (0x000C)

![Image](images/11_Chapter_11_img007_3b8f73b9.png)

TIMG\_T0\_UPDATE After writing 0 or 1 to TIMG\_T0UPDATE\_REG, the counter value is latched. (R/W/SC)

Register 11.5. TIMG\_T0ALARMLO\_REG (0x0010)

![Image](images/11_Chapter_11_img008_ab6ba340.png)

TIMG\_T0\_ALARM\_LO Timer 0 alarm trigger time-base counter value, low 32 bits. (R/W)

Register 11.6. TIMG\_T0ALARMHI\_REG (0x0014)

![Image](images/11_Chapter_11_img009_ae9531e2.png)

TIMG\_T0\_ALARM\_HI Timer 0 alarm trigger time-base counter value, high 22 bits. (R/W)

![Image](images/11_Chapter_11_img010_025a6cf1.png)

Register 11.7. TIMG\_T0LOADLO\_REG (0x0018)

![Image](images/11_Chapter_11_img011_0147e053.png)

TIMG\_T0\_LOAD\_LO Low 32 bits of the value that a reload will load onto Timer 0 time-base counter. (R/W)

Register 11.8. TIMG\_T0LOADHI\_REG (0x001C)

![Image](images/11_Chapter_11_img012_a4469c39.png)

TIMG\_T0\_LOAD\_HI High 22 bits of the value that a reload will load onto Timer 0 time-base counter. (R/W)

Register 11.9. TIMG\_T0LOAD\_REG (0x0020)

![Image](images/11_Chapter_11_img013_40cecd9b.png)

TIMG\_T0\_LOAD Write any value to trigger a Timer 0 time-base counter reload. (WT)

## Register 11.10. TIMG\_WDTCONFIG0\_REG (0x0048)

![Image](images/11_Chapter_11_img014_cb6804c2.png)

TIMG\_WDT\_APPCPU\_RESET\_EN WDT reset CPU enable. (R/W)

TIMG\_WDT\_PROCPU\_RESET\_EN WDT reset CPU enable. (R/W)

TIMG\_WDT\_FLASHBOOT\_MOD\_EN When set, Flash boot protection is enabled. (R/W)

TIMG\_WDT\_SYS\_RESET\_LENGTH System reset signal length selection. 0: 100 ns, 1: 200 ns, 2: 300 ns, 3: 400 ns, 4: 500 ns, 5: 800 ns, 6: 1.6 µs, 7: 3.2 µs. (R/W)

TIMG\_WDT\_CPU\_RESET\_LENGTH CPU reset signal length selection. 0: 100 ns, 1: 200 ns, 2: 300 ns, 3: 400 ns, 4: 500 ns, 5: 800 ns, 6: 1.6 µs, 7: 3.2 µs. (R/W)

TIMG\_WDT\_USE\_XTAL Chooses WDT clock. 0: APB\_CLK; 1:XTAL\_CLK. (R/W)

TIMG\_WDT\_CONF\_UPDATE\_EN Updates the WDT configuration registers. (WT)

TIMG\_WDT\_STG3 Stage 3 configuration. 0: off, 1: interrupt, 2: reset CPU, 3: reset system. (R/W)

TIMG\_WDT\_STG2 Stage 2 configuration. 0: off, 1: interrupt, 2: reset CPU, 3: reset system. (R/W)

TIMG\_WDT\_STG1 Stage 1 configuration. 0: off, 1: interrupt, 2: reset CPU, 3: reset system. (R/W)

TIMG\_WDT\_STG0 Stage 0 configuration. 0: off, 1: interrupt, 2: reset CPU, 3: reset system. (R/W)

TIMG\_WDT\_EN When set, MWDT is enabled. (R/W)

## Register 11.11. TIMG\_WDTCONFIG1\_REG (0x004C)

![Image](images/11_Chapter_11_img015_311d9d98.png)

TIMG\_WDT\_DIVCNT\_RST When set, WDT ’s clock divider counter will be reset. (WT)

TIMG\_WDT\_CLK\_PRESCALE MWDT clock prescaler value. MWDT clock period = MWDT's clock source period * TIMG\_WDT\_CLK\_PRESCALE. (R/W)

![Image](images/11_Chapter_11_img016_1df345f6.png)

TIMG\_WDT\_STG2\_HOLD Stage 2 timeout value, in MWDT clock cycles. (R/W)

## Register 11.15. TIMG\_WDTCONFIG5\_REG (0x005C)

![Image](images/11_Chapter_11_img017_2530c4f5.png)

![Image](images/11_Chapter_11_img018_788daa76.png)

TIMG\_WDT\_STG3\_HOLD Stage 3 timeout value, in MWDT clock cycles. (R/W)

## Register 11.16. TIMG\_WDTFEED\_REG (0x0060)

![Image](images/11_Chapter_11_img019_38444de7.png)

![Image](images/11_Chapter_11_img020_0e505bb4.png)

TIMG\_WDT\_FEED Write any value to feed the MWDT. (WO) (WT)

## Register 11.17. TIMG\_WDTWPROTECT\_REG (0x0064)

![Image](images/11_Chapter_11_img021_53aa3248.png)

![Image](images/11_Chapter_11_img022_e649e839.png)

TIMG\_WDT\_WKEY If the register contains a different value than its reset value, write protection is enabled. (R/W)

## Register 11.18. TIMG\_RTCCALICFG\_REG (0x0068)

![Image](images/11_Chapter_11_img023_40e5eb6c.png)

TIMG\_RTC\_CALI\_START\_CYCLING Enables periodic frequency calculation. (R/W)

TIMG\_RTC\_CALI\_CLK\_SEL 0: RC\_SLOW\_CLK; 1: RC\_FAST\_DIV\_CLK; 2: XTAL32K\_CLK. (R/W)

TIMG\_RTC\_CALI\_RDY Marks the completion of one-shot frequency calculation. (RO)

TIMG\_RTC\_CALI\_MAX Configures the time to calculate the frequency of RTC\_SLOW\_CLK. Measurement unit: RTC\_SLOW\_CLK cycle. (R/W)

TIMG\_RTC\_CALI\_START Set this bit to enable one-shot frequency calculation. (R/W)

Register 11.19. TIMG\_RTCCALICFG1\_REG (0x006C)

![Image](images/11_Chapter_11_img024_2d987441.png)

TIMG\_RTC\_CALI\_CYCLING\_DATA\_VLD Marks the completion of periodic frequency calculation. (RO)

TIMG\_RTC\_CALI\_VALUE When one-shot or periodic frequency calculation completes, read this value to calculate the frequency of RTC\_SLOW\_CLK. Measurement unit: XTAL\_CLK cycle. (RO)

## Register 11.20. TIMG\_RTCCALICFG2\_REG (0x0080)

![Image](images/11_Chapter_11_img025_79fd775a.png)

TIMG\_RTC\_CALI\_TIMEOUT Indicates frequency calculation timeout. (RO) TIMG\_RTC\_CALI\_TIMEOUT\_RST\_CNT Cycles to reset frequency calculation timeout. (R/W)

TIMG\_RTC\_CALI\_TIMEOUT\_THRES Threshold value for the frequency calculation timer. If the timer's value exceeds this threshold, a timeout is triggered. (R/W)

## Register 11.21. TIMG\_INT\_ENA\_TIMERS\_REG (0x0070)

![Image](images/11_Chapter_11_img026_d39fd65e.png)

TIMG\_T0\_INT\_ENA The interrupt enable bit for the TIMG\_T0\_INT interrupt. (R/W)

TIMG\_WDT\_INT\_ENA The interrupt enable bit for the TIMG\_WDT\_INT interrupt. (R/W)

## Register 11.22. TIMG\_INT\_RAW\_TIMERS\_REG (0x0074)

![Image](images/11_Chapter_11_img027_9c1ed83b.png)

TIMG\_T0\_INT\_RAW The raw interrupt status bit for the TIMG\_T0\_INT interrupt. (R/SS/WTC)

TIMG\_WDT\_INT\_RAW The raw interrupt status bit for the TIMG\_WDT\_INT interrupt. (R/SS/WTC)

## Register 11.23. TIMG\_INT\_ST\_TIMERS\_REG (0x0078)

![Image](images/11_Chapter_11_img028_91ece444.png)

TIMG\_T0\_INT\_ST The masked interrupt status bit for the TIMG\_T0\_INT interrupt. (RO)

TIMG\_WDT\_INT\_ST The masked interrupt status bit for the TIMG\_WDT\_INT interrupt. (RO)

Register 11.24. TIMG\_INT\_CLR\_TIMERS\_REG (0x007C)

![Image](images/11_Chapter_11_img029_91fdcc9b.png)

TIMG\_T0\_INT\_CLR Set this bit to clear the TIMG\_T0\_INT interrupt. (WT)

TIMG\_WDT\_INT\_CLR Set this bit to clear the TIMG\_WDT\_INT interrupt. (WT)

## Register 11.25. TIMG\_NTIMERS\_DATE\_REG (0x00F8)

![Image](images/11_Chapter_11_img030_9602d259.png)

TIMG\_NTIMGS\_DATE Timer version control register (R/W)

Register 11.26. TIMG\_REGCLK\_REG (0x00FC)

![Image](images/11_Chapter_11_img031_57bb1882.png)

TIMG\_WDT\_CLK\_IS\_ACTIVE enable WDT’s clock (R/W)

TIMG\_TIMER\_CLK\_IS\_ACTIVE enable Timer 0’s clock (R/W)

TIMG\_CLK\_EN Register clock gate signal. 0: The clock used by software to read and write registers is on only when there is software operation. 1: The clock used by software to read and write registers is always on. (R/W)
