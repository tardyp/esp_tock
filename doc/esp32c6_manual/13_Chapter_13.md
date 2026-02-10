---
chapter: 13
title: "Chapter 13"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 13

## System Timer (SYSTIMER)

## 13.1 Overview

ESP32-C6 provides a 52-bit timer, which can be used to generate tick interrupts for the operating system, or be used as a general timer to generate periodic interrupts or one-time interrupts.

The timer consists of two counters: UNIT0 and UNIT1. The counter values can be monitored by three comparators COMP0, COMP1, and COMP2. See the timer block diagram on Figure 13.1-1 .

Figure 13.1-1. System Timer Structure

![Image](images/13_Chapter_13_img001_860a3d52.png)

## 13.2 Features

The system timer has the following features:

- Two 52-bit counters and three 52-bit comparators
- Software accessing registers clocked by APB\_CLK
- CNT\_CLK used for counting, with an average frequency of 16 MHz in two counting cycles
- 40 MHz XTAL\_CLK as the clock source of CNT\_CLK
- 52-bit alarm values (t) and 26-bit alarm periods (δt)
- Two modes to generate alarms:
- – Target mode: only a one-time alarm is generated based on the alarm value (t)
- – Period mode: periodic alarms are generated based on the alarm period (δt)

![Image](images/13_Chapter_13_img002_d328fad9.png)

- Three comparators generating three independent interrupts based on configured alarm value (t) or alarm period (δt)
- Software configuring the reference count value. For example, the system timer is able to load back the sleep time recorded by the RTC timer via software after Light-sleep
- Able to stall or continue running when CPU stalls or enters the on-chip-debugging mode
- Alarm for Event Task Matrix (ETM) event

## 13.3 Clock Source Selection

The counters and comparators use XTAL\_CLK or RC\_FAST\_CLK as the clock sources. The clock source can be selected by configuring field PCR\_SYSTIMER\_FUNC\_CLK\_SEL in register

PCR\_SYSTIMER\_FUNC\_CLK\_CONF\_REG. After XTAL\_CLK is scaled by a fractional divider, a fXT AL \_ CLK /3 clock is generated in one count cycle and a fXT AL \_ CLK /2 clock in another count cycle. The average clock frequency is fXT AL \_ CLK /2 . 5, which is 16 MHz, i.e. the CNT\_CLK in Figure 13.4-1. The timer counter is incremented by 1/16 µs on each CNT\_CLK cycle.

Software operation such as configuring registers is clocked by APB\_CLK. For more information about APB\_CLK, see Chapter 8 Reset and Clock .

The following two bits of system registers are also used to control the system timer:

- Set PCR\_SYSTIMER\_CLK\_EN in register PCR\_SYSTIMER\_CONF\_REG to enable APB\_CLK signal to the system timer.
- Set PCR\_SYSTIMER\_RST\_EN in register PCR\_SYSTIMER\_CONF\_REG to reset the system timer.

Note that if the timer is reset, its registers will be restored to their default values. For more information, please refer to Chapter 8 Reset and Clock .

## 13.4 Functional Description

Figure 13.4-1. System Timer Alarm Generation

![Image](images/13_Chapter_13_img003_97ec7fa6.png)

Figure 13.4-1 shows the procedure to generate alarm in system timer. In this process, one timer counter and one timer comparator are used. An alarm interrupt will be generated accordingly based on the comparison result in comparator.

## 13.4.1 Counter

The system timer has two 52-bit timer counters, shown as UNITn (n = 0 or 1). Their counting clock source is a 16 MHz clock, i.e. CNT\_CLK. Whether UNITn works or not is controlled by two bits in register SYSTIMER\_CONF\_REG:

- SYSTIMER\_TIMER\_UNITn\_WORK\_EN: set this bit to enable the counter UNITn in system timer.
- SYSTIMER\_TIMER\_UNITn\_CORE0\_STALL\_EN: if this bit is set, the counter UNITn stops when CPU is stalled. The counter continues its counting after the CPU resumes.

The configuration of the two bits to control the counter UNITn is shown below, assuming that CPU is stalled.

Table 13.4-1. UNITn Configuration Bits

|   SYSTIMER_TIMER_  UNITn_WORK_EN | SYSTIMER_TIMER_  UNITn_CORE0_STALL_EN   | Counter UNITn                                                       |
|----------------------------------|-----------------------------------------|---------------------------------------------------------------------|
|                                0 | x *                                     | Not at work                                                         |
|                                1 | 1                                       | Stop counting, but will continue its counting after the CPU resumes |
|                                1 | 0                                       | Keep counting                                                       |

When the counter UNITn is at work, the count value is incremented on each counting cycle. When the counter UNITn is stopped, the count value stops increasing and keeps unchanged.

The lower 32 and higher 20 bits of initial count value are loaded from the registers SYSTIMER\_TIMER\_UNITn\_LOAD\_LO and SYSTIMER\_TIMER\_UNITn\_LOAD\_HI. Writing 1 to the bit SYSTIMER\_TIMER\_UNITn\_LOAD will trigger a reload event, and the current count value will be changed immediately. If UNITn is at work, the counter will continue to count up from the new reloaded value.

Writing 1 to SYSTIMER\_TIMER\_UNITn\_UPDATE will trigger an update event. The lower 32 and higher 20 bits of current count value will be locked into the registers SYSTIMER\_TIMER\_UNITn\_VALUE\_LO and SYSTIMER\_TIMER\_UNITn\_VALUE\_HI, and then SYSTIMER\_TIMER\_UNITn\_VALUE\_VALID is asserted. Before the next update event, the values of SYSTIMER\_TIMER\_UNITn\_VALUE\_LO and SYSTIMER\_TIMER\_UNITn\_VALUE\_HI remain unchanged.

## 13.4.2 Comparator and Alarm

The system timer has three 52-bit comparators, shown as COMPx (x = 0, 1, or 2). The comparators can generate independent interrupts based on different alarm values (t) or alarm periods (δt).

Configure SYSTIMER\_TARGETx\_PERIOD\_MODE to choose from the two alarm modes for each COMPx:

- 1: period mode
- 0: target mode

In period mode, the alarm period (δt) is provided by the register SYSTIMER\_TARGETx\_PERIOD. Assuming that current count value is t1, when it reaches (t1 + δt), an alarm interrupt will be generated. When the count value

reaches (t1 + 2*δt), another alarm interrupt also will be generated. By such way, periodic alarms are generated.

In target mode, the lower 32 bits and higher 20 bits of the alarm value (t) are provided by SYSTIMER\_TIMER\_TARGETx\_LO and SYSTIMER\_TIMER\_TARGETx\_HI. Assuming that current count value is t2 (t2 &lt;= t), an alarm interrupt will be generated when the count value reaches the alarm value (t). Unlike in period mode, only one alarm interrupt is generated in target mode.

SYSTIMER\_TARGETx\_TIMER\_UNIT\_SEL is used to choose the count value from which timer counter to be compared for alarm:

- 1: Use the count value from UNIT1
- 0: Use the count value from UNIT0

Finally, set SYSTIMER\_TARGETx\_WORK\_EN and COMPx starts to compare the count value:

- In target mode, COMPx compares with the alarm value (t).
- In period mode, COMPx compares with the alarm period (t1 + n*δt).

An alarm is generated when the count value equals to the alarm value (t) in target mode or to the start value + n*alarm period δt (n = 1, 2, 3...) in period mode. But if the alarm value (t) set in registers is less than current count value, i.e. the target has already passed, when the current count value is larger than the alarm value (t) within a range (0 ~ 2 51 - 1), an alarm interrupt is also generated immediately. No matter in target mode or period mode, the low 32 bits and high 20 bits of the real alarm value can always be read from SYSTIMER\_TARGETx\_LO\_RO and SYSTIMER\_TARGETx\_HI\_RO. The alarm trigger point and the relationship between current count value t c and the alarm value t t are shown below.

Table 13.4-2. Trigger Point

| Relationship Between t c  and t t                                                                  | Trigger Point                                                                                                                                                 |
|----------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| t c -  t t  <= 0                                                                                   | t c  =  t t , an alarm is triggered.                                                                                                                          |
| 0 <= t c  -  t t  < 2 51  - 1 ( t c  < 2 51  and t t  < 2 51 , or t c  >= 2 51  and t t  >= 2 51 ) | An alarm is triggered immediately.                                                                                                                            |
| t c  -  t t  >= 2 51  - 1                                                                          | t c  overflows after counting to its maximum value 52’hfffffffffffff, and then starts counting up from 0. When its value reaches t t , an alarm is triggered. |

## 13.4.3 Event Task Matrix

The system timer on ESP32-C6 supports the Event Task Matrix (ETM) function, which allows the system timer's ETM tasks to be triggered by any peripherals' ETM events, or system timer's ETM events to trigger any peripherals' ETM tasks. This section introduces the ETM tasks and events related to the system timer. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

The system timer can generate the following ETM event:

- SYSTIMER\_EVT\_CNT\_CMPx: Indicates the alarm pulses generated by COMPx .

When SYSTIMER\_ETM\_EN is set to 1, the alarm pulses can trigger the ETM event.

## 13.4.4 Synchronization Operation

The clock (APB\_CLK) used in software operation is separate from CNT\_CLK to drive the timer counters and comparators. Synchronization is needed for some configuration registers. A complete synchronization action takes two steps:

1. Software writes specific values to configuration fields, see the first column in Table 13.4-3 .
2. Software writes 1 to corresponding bits to start synchronization, see the second column in Table 13.4-3 .

Table 13.4-3. Synchronization Operation for Configuration Registers

| Configuration Fields                                                        | Synchronization Enable Bit   |
|-----------------------------------------------------------------------------|------------------------------|
| SYSTIMER_TIMER_UNITn_LOAD_LO SYSTIMER_TIMER_UNITn_LOAD_HI                   | SYSTIMER_TIMER_UNITn_LOAD    |
| SYSTIMER_TARGETx_PERIOD SYSTIMER_TIMER_TARGETx_HI SYSTIMER_TIMER_TARGETx_LO | SYSTIMER_TIMER_COMPx_LOAD    |

Synchronization is also needed for reading some status registers since the timer counter related status have a different clock than APB\_CLK. A complete synchronization action takes three steps:

1. Software writes specific values to the updating register SYSTIMER\_TIMER\_UNITn\_UPDATE .
2. Software reads the corresponding bit SYSTIMER\_TIMER\_UNITn\_VALUE\_VALID to be valid to check synchronization is done.
3. Software reads corresponding status registers SYSTIMER\_TIMER\_UNITn\_VALUE\_HI and SYSTIMER\_TIMER\_UNITn\_VALUE\_LO .

## 13.4.5 Interrupt

Each comparator has one level-type alarm interrupt, named as SYSTIMER\_TARGETx\_INT. Interrupts signal is asserted high when the comparator starts to alarm. Until the interrupt is cleared by software, it remains high. To enable interrupts, set the bit SYSTIMER\_TARGETx\_INT\_ENA .

## 13.5 Programming Procedure

When configuring COMPx and UNITn, please ensure the corresponding COMP and UNIT are at work.

## 13.5.1 Read Current Count Value

1. Set SYSTIMER\_TIMER\_UNITn\_UPDATE to update the current count value of COMPx into SYSTIMER\_TIMER\_UNITn\_VALUE\_HI and SYSTIMER\_TIMER\_UNITn\_VALUE\_LO .
2. Poll the reading of SYSTIMER\_TIMER\_UNITn\_VALUE\_VALID till it's 1. Then, user can read the count value from SYSTIMER\_TIMER\_UNITn\_VALUE\_HI and SYSTIMER\_TIMER\_UNITn\_VALUE\_LO .
3. Read the lower 32 bits and higher 20 bits from SYSTIMER\_TIMER\_UNITn\_VALUE\_LO and SYSTIMER\_TIMER\_UNITn\_VALUE\_HI respectively.

## 13.5.2 Configure One-Time Alarm in Target Mode

1. Set SYSTIMER\_TARGETx\_TIMER\_UNIT\_SEL to select the counter (UNIT0 or UNIT1) used for COMPx .

2. Read current count value, see Section 13.5.1. This value will be used to calculate the alarm value (t) in Step 4.
3. Clear SYSTIMER\_TARGETx\_PERIOD\_MODE to enable target mode.
4. Set an alarm value (t), and fill its lower 32 bits to SYSTIMER\_TIMER\_TARGETx\_LO, and the higher 20 bits to SYSTIMER\_TIMER\_TARGETx\_HI .
5. Set SYSTIMER\_TIMER\_COMPx\_LOAD to synchronize the alarm value (t) to COMPx, i.e., load the alarm value (t) to the COMPx .
6. Set SYSTIMER\_TARGETx\_WORK\_EN to enable the selected COMPx. COMPx starts comparing the count value with the alarm value (t).
7. Set SYSTIMER\_TARGETx\_INT\_ENA to enable timer interrupt. When Unitn counts to the alarm value (t), a SYSTIMER\_TARGETx\_INT interrupt is triggered.

## 13.5.3 Configure Periodic Alarms in Period Mode

1. Set SYSTIMER\_TARGETx\_TIMER\_UNIT\_SEL to select the counter (UNIT0 or UNIT1) used for COMPx .
2. Set an alarm period (δt), and fill it to SYSTIMER\_TARGETx\_PERIOD .
3. Set SYSTIMER\_TIMER\_COMPx\_LOAD to synchronize the alarm period (δt) to COMPx, i.e., load the alarm period (δt) to COMPx .
4. Clear and then set SYSTIMER\_TARGETx\_PERIOD\_MODE to configure COMPx into period mode.
5. Set SYSTIMER\_TARGETx\_WORK\_EN to enable the selected COMPx. COMPx starts comparing the count value with the sum of (start value + n*δt) (n = 1, 2, 3...).
6. Set SYSTIMER\_TARGETx\_INT\_ENA to enable timer interrupt. A SYSTIMER\_TARGETx\_INT interrupt is triggered when Unitn counts to start value + n*δt (n = 1, 2, 3...) set in Step 2.

## 13.5.4 Update After Light-sleep

1. Configure the RTC timer before the chip goes to Light-sleep mode, to record the exact sleep time. For more information, see Chapter 12 Low-Power Management .
2. Read the sleep time from the RTC timer when the chip is woken up from Light-sleep mode.
3. Read current count value of system timer, see Section 13.5.1 .
4. Convert the time value recorded by the RTC timer from the clock cycles based on RTC\_SLOW\_CLK to that based on 16 MHz CNT\_CLK. For example, if the frequency of RTC\_SLOW\_CLK is 32 kHz, the recorded RTC timer value should be converted by multiplying by 500.
5. Add the converted RTC value to the current count value of the system timer:
- Fill the new value into SYSTIMER\_TIMER\_UNITn\_LOAD\_LO (low 32 bits) and SYSTIMER\_TIMER\_UNITn\_LOAD\_HI (high 20 bits).
- Set SYSTIMER\_TIMER\_UNITn\_LOAD to load new timer value into system timer. By such way, the system timer is updated.

## 13.6 Register Summary

The addresses in this section are relative to system timer base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

R/WTC/SS

![Image](images/13_Chapter_13_img004_f13dde6c.png)

| Name                                            | Description                                     | Address                                         | Access                                          |
|-------------------------------------------------|-------------------------------------------------|-------------------------------------------------|-------------------------------------------------|
| Clock Control Register                          |                                                 |                                                 |                                                 |
| SYSTIMER_CONF_REG                               | Configure system timer clock                    | 0x0000                                          | R/W                                             |
| UNIT0 Control and Configuration Registers       | UNIT0 Control and Configuration Registers       | UNIT0 Control and Configuration Registers       | UNIT0 Control and Configuration Registers       |
| SYSTIMER_UNIT0_OP_REG                           | Read UNIT0 value to registers                   | 0x0004                                          | varies                                          |
| SYSTIMER_UNIT0_LOAD_HI_REG                      | High 20 bits to be loaded to UNIT0              | 0x000C                                          | R/W                                             |
| SYSTIMER_UNIT0_LOAD_LO_REG                      | Low 32 bits to be loaded to UNIT0               | 0x0010                                          | R/W                                             |
| SYSTIMER_UNIT0_VALUE_HI_REG                     | UNIT0 value, high 20 bits                       | 0x0040                                          | RO                                              |
| SYSTIMER_UNIT0_VALUE_LO_REG                     | UNIT0 value, low 32 bits                        | 0x0044                                          | RO                                              |
| SYSTIMER_UNIT0_LOAD_REG                         | UNIT0 synchronization register                  | 0x005C                                          | WT                                              |
| UNIT1 Control and Configuration Registers       | UNIT1 Control and Configuration Registers       | UNIT1 Control and Configuration Registers       | UNIT1 Control and Configuration Registers       |
| SYSTIMER_UNIT1_OP_REG                           | Read UNIT1 value to registers                   | 0x0008                                          | varies                                          |
| SYSTIMER_UNIT1_LOAD_HI_REG                      | High 20 bits to be loaded to UNIT1              | 0x0014                                          | R/W                                             |
| SYSTIMER_UNIT1_LOAD_LO_REG                      | Low 32 bits to be loaded to UNIT1               | 0x0018                                          | R/W                                             |
| SYSTIMER_UNIT1_VALUE_HI_REG                     | UNIT1 value, high 20 bits                       | 0x0048                                          | RO                                              |
| SYSTIMER_UNIT1_VALUE_LO_REG                     | UNIT1 value, low 32 bits                        | 0x004C                                          | RO                                              |
| SYSTIMER_UNIT1_LOAD_REG                         | UNIT1 synchronization register                  | 0x0060                                          | WT                                              |
| Comparator0 Control and Configuration Registers | Comparator0 Control and Configuration Registers | Comparator0 Control and Configuration Registers | Comparator0 Control and Configuration Registers |
| SYSTIMER_TARGET0_HI_REG                         | Alarm value to be loaded to COMP0, high 20 bits | 0x001C                                          | R/W                                             |
| SYSTIMER_TARGET0_LO_REG                         | Alarm value to be loaded to COMP0, low 32 bits  | 0x0020                                          | R/W                                             |
| SYSTIMER_TARGET0_CONF_REG                       | Configure COMP0 alarm mode                      | 0x0034                                          | R/W                                             |
| SYSTIMER_COMP0_LOAD_REG                         | COMP0 synchronization register                  | 0x0050                                          | WT                                              |
| Comparator1 Control and Configuration Registers | Comparator1 Control and Configuration Registers | Comparator1 Control and Configuration Registers | Comparator1 Control and Configuration Registers |
| SYSTIMER_TARGET1_HI_REG                         | Alarm value to be loaded to COMP1, high 20 bits | 0x0024                                          | R/W                                             |
| SYSTIMER_TARGET1_LO_REG                         | Alarm value to be loaded to COMP1, low 32 bits  | 0x0028                                          | R/W                                             |
| SYSTIMER_TARGET1_CONF_REG                       | Configure COMP1 alarm mode                      | 0x0038                                          | R/W                                             |
| SYSTIMER_COMP1_LOAD_REG                         | COMP1 synchronization register                  | 0x0054                                          | WT                                              |
| Comparator2 Control and Configuration Registers | Comparator2 Control and Configuration Registers | Comparator2 Control and Configuration Registers | Comparator2 Control and Configuration Registers |
| SYSTIMER_TARGET2_HI_REG                         | Alarm value to be loaded to COMP2, high 20 bits | 0x002C                                          | R/W                                             |
| SYSTIMER_TARGET2_LO_REG                         | Alarm value to be loaded to COMP2, low 32 bits  | 0x0030                                          | R/W                                             |
| SYSTIMER_TARGET2_CONF_REG                       | Configure COMP2 alarm mode                      | 0x003C                                          | R/W                                             |
| SYSTIMER_COMP2_LOAD_REG                         | COMP2 synchronization register                  | 0x0058                                          | WT                                              |
| Interrupt Registers                             | Interrupt Registers                             | Interrupt Registers                             | Interrupt Registers                             |
| SYSTIMER_INT_ENA_REG                            | Interrupt enable register of system timer       | 0x0064                                          | R/W                                             |
| SYSTIMER_INT_RAW_REG                            | Interrupt raw register of system timer          | 0x0068                                          |                                                 |
| SYSTIMER_INT_CLR_REG                            | Interrupt clear register of system timer        | 0x006C                                          | WT                                              |

| Name                         | Description                                | Address   | Access   |
|------------------------------|--------------------------------------------|-----------|----------|
| SYSTIMER_INT_ST_REG          | Interrupt status register of system timer  | 0x0070    | RO       |
| COMP0 Status Registers       |                                            |           |          |
| SYSTIMER_REAL_TARGET0_LO_REG | Actual target value of COMP0, low 32 bits  | 0x0074    | RO       |
| SYSTIMER_REAL_TARGET0_HI_REG | Actual target value of COMP0, high 20 bits | 0x0078    | RO       |
| COMP1 Status Registers       |                                            |           |          |
| SYSTIMER_REAL_TARGET1_LO_REG | Actual target value of COMP1, low 32 bits  | 0x007C    | RO       |
| SYSTIMER_REAL_TARGET1_HI_REG | Actual target value of COMP1, high 20 bits | 0x0080    | RO       |
| COMP2 Status Registers       |                                            |           |          |
| SYSTIMER_REAL_TARGET2_LO_REG | Actual target value of COMP2, low 32 bits  | 0x0084    | RO       |
| SYSTIMER_REAL_TARGET2_HI_REG | Actual target value of COMP2, high 20 bits | 0x0088    | RO       |
| Version Register             |                                            |           |          |
| SYSTIMER_DATE_REG            | Version control register                   | 0x00FC    | R/W      |

## 13.7 Registers

The addresses in this section are relative to system timer base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 13.1. SYSTIMER\_CONF\_REG (0x0000)

![Image](images/13_Chapter_13_img005_271eacd7.png)

SYSTIMER\_ETM\_EN Configures whether or not to enable generation of ETM events.

0: Disable

1: Enable

(R/W)

SYSTIMER\_TARGET2\_WORK\_EN Configures whether or not to enable COMP2.

0: Disable

1: Enable

(R/W)

SYSTIMER\_TARGET1\_WORK\_EN Configures whether or not to enable COMP1. See details in SYS-TIMER\_TARGET2\_WORK\_EN. (R/W)

SYSTIMER\_TARGET0\_WORK\_EN Configures whether or not to enable COMP0. See details in SYS-TIMER\_TARGET2\_WORK\_EN. (R/W)

SYSTIMER\_TIMER\_UNIT1\_CORE1\_STALL\_EN Configures whether or not UNIT1 is stalled when CORE1 is stalled.

0: UNIT1 is not stalled.

1: UNIT1 is stalled.

(R/W)

SYSTIMER\_TIMER\_UNIT1\_CORE0\_STALL\_EN Configures whether or not UNIT1 is stalled when CORE0 is stalled. See details in SYSTIMER\_TIMER\_UNIT1\_CORE1\_STALL\_EN. (R/W)

SYSTIMER\_TIMER\_UNIT0\_CORE1\_STALL\_EN Configures whether or not UNIT0 is stalled when CORE1 is stalled. See details in SYSTIMER\_TIMER\_UNIT1\_CORE1\_STALL\_EN. (R/W)

SYSTIMER\_TIMER\_UNIT0\_CORE0\_STALL\_EN Configures whether or not UNIT0 is stalled when CORE0 is stalled. See details in SYSTIMER\_TIMER\_UNIT1\_CORE1\_STALL\_EN. (R/W)

Continued on the next page...

## Register 13.1. SYSTIMER\_CONF\_REG (0x0000)

## Continued from the previous page...

SYSTIMER\_TIMER\_UNIT1\_WORK\_EN Configures whether or not to enable UNIT1.

0: Disable

1: Enable

(R/W)

SYSTIMER\_TIMER\_UNIT0\_WORK\_EN Configures whether or not to enable UNIT0.

- 0: Disable

1: Enable

(R/W)

SYSTIMER\_CLK\_EN Configures register clock gating.

- 0: Only enable needed clock for register read or write operations.
- 1: Register clock is always enabled for read and write operations.

(R/W)

## Register 13.2. SYSTIMER\_UNIT0\_OP\_REG (0x0004)

![Image](images/13_Chapter_13_img006_4135aa72.png)

SYSTIMER\_TIMER\_UNIT0\_VALUE\_VALID Represents UNIT0 value is synchronized and valid. (R/SS/WTC)

SYSTIMER\_TIMER\_UNIT0\_UPDATE Configures whether or not to update timer UNIT0, i.e., reads the UNIT0 count value to SYSTIMER\_TIMER\_UNIT0\_VALUE\_HI and SYS-TIMER\_TIMER\_UNIT0\_VALUE\_LO .

0: No effect

1: Update timer UNIT0

(WT)

Register 13.3. SYSTIMER\_UNIT0\_LOAD\_HI\_REG (0x000C)

![Image](images/13_Chapter_13_img007_563f7216.png)

SYSTIMER\_TIMER\_UNIT0\_LOAD\_HI Configures the value to be loaded to UNIT0, high 20 bits. (R/W)

Register 13.4. SYSTIMER\_UNIT0\_LOAD\_LO\_REG (0x0010)

![Image](images/13_Chapter_13_img008_0c0fc61e.png)

SYSTIMER\_TIMER\_UNIT0\_LOAD\_LO Configures the value to be loaded to UNIT0, low 32 bits. (R/W)

Register 13.5. SYSTIMER\_UNIT0\_VALUE\_HI\_REG (0x0040)

![Image](images/13_Chapter_13_img009_751bfce6.png)

SYSTIMER\_TIMER\_UNIT0\_VALUE\_HI Represents UNIT0 read value, high 20 bits. (RO)

Register 13.6. SYSTIMER\_UNIT0\_VALUE\_LO\_REG (0x0044)

![Image](images/13_Chapter_13_img010_22d3c488.png)

SYSTIMER\_TIMER\_UNIT0\_VALUE\_LO Represents UNIT0 read value, low 32 bits. (RO)

Register 13.7. SYSTIMER\_UNIT0\_LOAD\_REG (0x005C)

![Image](images/13_Chapter_13_img011_6c47dd1a.png)

SYSTIMER\_TIMER\_UNIT0\_LOAD Configures whether or not to reload the value of UNIT0, i.e., reloads the values of SYSTIMER\_TIMER\_UNIT0\_VALUE\_HI and SYS-TIMER\_TIMER\_UNIT0\_VALUE\_LO to UNIT0.

0: No effect

1: Reload the value of UNIT0

(WT)

Register 13.8. SYSTIMER\_UNIT1\_OP\_REG (0x0008)

![Image](images/13_Chapter_13_img012_b08d519a.png)

SYSTIMER\_TIMER\_UNIT1\_VALUE\_VALID Represents UNIT1 value is synchronized and valid. (R/SS/WTC)

SYSTIMER\_TIMER\_UNIT1\_UPDATE Configures whether or not to update timer UNIT1, i.e., reads the UNIT1 count value to SYSTIMER\_TIMER\_UNIT1\_VALUE\_HI and SYS-TIMER\_TIMER\_UNIT1\_VALUE\_LO .

0: No effect

1: Update timer UNIT1

(WT)

Register 13.9. SYSTIMER\_UNIT1\_LOAD\_HI\_REG (0x0014)

![Image](images/13_Chapter_13_img013_efc40545.png)

SYSTIMER\_TIMER\_UNIT1\_LOAD\_HI Configures the value to be loaded to UNIT1, high 20 bits. (R/W)

![Image](images/13_Chapter_13_img014_d7571947.png)

## Register 13.13. SYSTIMER\_UNIT1\_LOAD\_REG (0x0060)

![Image](images/13_Chapter_13_img015_466d3bec.png)

SYSTIMER\_TIMER\_UNIT1\_LOAD Configures whether or not to reload the value of UNIT1, i.e., reload the values of SYSTIMER\_TIMER\_UNIT1\_VALUE\_HI and SYSTIMER\_TIMER\_UNIT1\_VALUE\_LO to UNIT1.

- 0: No effect

1: Reload the value of UNIT1

(WT)

## Register 13.14. SYSTIMER\_TARGET0\_HI\_REG (0x001C)

![Image](images/13_Chapter_13_img016_52b04b51.png)

SYSTIMER\_TIMER\_TARGET0\_HI Configures the alarm value to be loaded to COMP0, high 20 bits. (R/W)

## Register 13.15. SYSTIMER\_TARGET0\_LO\_REG (0x0020)

![Image](images/13_Chapter_13_img017_32d91e1f.png)

SYSTIMER\_TIMER\_TARGET0\_LO Configures the alarm value to be loaded to COMP0, low 32 bits. (R/W)

## Register 13.16. SYSTIMER\_TARGET0\_CONF\_REG (0x0034)

![Image](images/13_Chapter_13_img018_91938021.png)

SYSTIMER\_TARGET0\_PERIOD Configures COMP0 alarm period. (R/W)

SYSTIMER\_TARGET0\_PERIOD\_MODE Selects the two alarm modes for COMP0.

- 0: Target mode
- 1: Period mode

(R/W)

SYSTIMER\_TARGET0\_TIMER\_UNIT\_SEL Chooses the counter value for comparison with COMP0.

- 0: Use the count value from UNIT0
- 1: Use the count value from UNIT1

(R/W)

Register 13.17. SYSTIMER\_COMP0\_LOAD\_REG (0x0050)

![Image](images/13_Chapter_13_img019_5a2504c8.png)

SYSTIMER\_TIMER\_COMP0\_LOAD Configures whether or not to enable COMP0 synchronization,

- i.e., reload the alarm value/period to COMP0.
- 0: No effect
- 1: Enable COMP0 synchronization

(WT)

Register 13.18. SYSTIMER\_TARGET1\_HI\_REG (0x0024)

![Image](images/13_Chapter_13_img020_7c9ceb5a.png)

SYSTIMER\_TIMER\_TARGET1\_HI Configures the alarm value to be loaded to COMP1, high 20 bits. (R/W)

## Register 13.19. SYSTIMER\_TARGET1\_LO\_REG (0x0028)

![Image](images/13_Chapter_13_img021_c2966272.png)

SYSTIMER\_TIMER\_TARGET1\_LO Configures the alarm value to be loaded to COMP1, low 32 bits. (R/W)

## Register 13.20. SYSTIMER\_TARGET1\_CONF\_REG (0x0038)

![Image](images/13_Chapter_13_img022_d95baaf7.png)

SYSTIMER\_TARGET1\_PERIOD Configures COMP1 alarm period. (R/W)

SYSTIMER\_TARGET1\_PERIOD\_MODE Selects the two alarm modes for COMP1. See details in SYS-TIMER\_TARGET0\_PERIOD\_MODE. (R/W)

SYSTIMER\_TARGET1\_TIMER\_UNIT\_SEL Chooses the counter value for comparison with COMP1. See details in SYSTIMER\_TARGET0\_TIMER\_UNIT\_SEL. (R/W)

## Register 13.21. SYSTIMER\_COMP1\_LOAD\_REG (0x0054)

![Image](images/13_Chapter_13_img023_35ef70a3.png)

SYSTIMER\_TIMER\_COMP1\_LOAD Configures whether or not to enable COMP1 synchronization, i.e., reload the alarm value/period to COMP1.

0: No effect

1: Enable COMP1 synchronization

(WT)

Register 13.22. SYSTIMER\_TARGET2\_HI\_REG (0x002C)

![Image](images/13_Chapter_13_img024_492f3096.png)

SYSTIMER\_TIMER\_TARGET2\_HI Configures the alarm value to be loaded to COMP2, high 20 bits. (R/W)

## Register 13.23. SYSTIMER\_TARGET2\_LO\_REG (0x0030)

![Image](images/13_Chapter_13_img025_7e5813a8.png)

SYSTIMER\_TIMER\_TARGET2\_LO Configures the alarm value to be loaded to COMP2, low 32 bits. (R/W)

Register 13.24. SYSTIMER\_TARGET2\_CONF\_REG (0x003C)

![Image](images/13_Chapter_13_img026_2815d722.png)

SYSTIMER\_TARGET2\_PERIOD Configures COMP2 alarm period. (R/W)

SYSTIMER\_TARGET2\_PERIOD\_MODE Configures Configures the two alarm modes for COMP2. See details in SYSTIMER\_TARGET0\_PERIOD\_MODE. (R/W)

SYSTIMER\_TARGET2\_TIMER\_UNIT\_SEL Chooses the counter value for comparison with COMP2. See details in SYSTIMER\_TARGET0\_TIMER\_UNIT\_SEL. (R/W)

Register 13.25. SYSTIMER\_COMP2\_LOAD\_REG (0x0058)

![Image](images/13_Chapter_13_img027_44c4c3db.png)

SYSTIMER\_TIMER\_COMP2\_LOAD Configures whether or not to enable COMP2 synchronization,

- i.e., reload the alarm value/period to COMP2.
- 0: No effect
- 1: Enable COMP2 synchronization

(WT)

![Image](images/13_Chapter_13_img028_74300a3c.png)

![Image](images/13_Chapter_13_img029_53f119ab.png)

Register 13.31. SYSTIMER\_REAL\_TARGET0\_HI\_REG (0x0078)

![Image](images/13_Chapter_13_img030_be295c84.png)

SYSTIMER\_TARGET0\_HI\_RO Represents the actual target value of COMP0, high 20 bits. (RO)

Register 13.32. SYSTIMER\_REAL\_TARGET1\_LO\_REG (0x007C)

![Image](images/13_Chapter_13_img031_d2fe096a.png)

SYSTIMER\_TARGET1\_LO\_RO Represents the actual target value of COMP1, low 32 bits. (RO)

Register 13.33. SYSTIMER\_REAL\_TARGET1\_HI\_REG (0x0080)

![Image](images/13_Chapter_13_img032_c53fc308.png)

SYSTIMER\_TARGET1\_HI\_RO Represents the actual target value of COMP1, high 20 bits. (RO)

![Image](images/13_Chapter_13_img033_df3e2fc5.png)

SYSTIMER\_DATE Version control register. (R/W)
