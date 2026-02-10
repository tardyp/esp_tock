---
chapter: 10
title: "Chapter 10"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 10

## System Timer (SYSTIMER)

## 10.1 Overview

ESP32-C3 provides a 52-bit timer, which can be used to generate tick interrupts for operating system, or be used as a general timer to generate periodic interrupts or one-time interrupts.

The timer consists of two counters UNIT0 and UNIT1. The count values can be monitored by three comparators COMP0, COMP1 and COMP2. See the timer block diagram on Figure 10.1-1 .

Figure 10.1-1. System Timer Structure

![Image](images/10_Chapter_10_img001_e86f0ad6.png)

## 10.2 Features

- Consist of two 52-bit counters and three 52-bit comparators
- Software accessing registers is clocked by APB\_CLK
- Use CNT\_CLK for counting, with an average frequency of 16 MHz in two counting cycles
- Use 40 MHz XTAL\_CLK as the clock source of CNT\_CLK
- Support for 52-bit alarm values (t) and 26-bit alarm periods (δt)
- Provide two modes to generate alarms:
- – Target mode: only a one-time alarm is generated based on the alarm value (t)
- – Period mode: periodic alarms are generated based on the alarm period (δt)
- Three comparators can generate three independent interrupts based on configured alarm value (t) or alarm period (δt)

![Image](images/10_Chapter_10_img002_a4bf881b.png)

- Software configuring the reference count value. For example, the system timer is able to load back the sleep time recorded by the RTC timer via software after Light-sleep
- Can be configured to stall or continue running when CPU stalls or enters on-chip-debugging mode

## 10.3 Clock Source Selection

The counters and comparators are driven using XTAL\_CLK. After scaled by a fractional divider, a fXT AL \_ CLK /3 clock is generated in one count cycle and a fXT AL \_ CLK /2 clock in another count cycle. The average clock frequency is fXT AL \_ CLK /2 . 5, which is 16 MHz, i.e. the CNT\_CLK in Figure 10.4-1. The timer counting is incremented by 1/16 µs on each CNT\_CLK cycle.

Software operation such as configuring registers is clocked by APB\_CLK. For more information about APB\_CLK, see Chapter 6 Reset and Clock .

The following two bits of system registers are also used to control the system timer:

- SYSTEM\_SYSTIMER\_CLK\_EN in register SYSTEM\_PERIP\_CLK\_EN0\_REG: enable APB\_CLK signal to system timer.
- SYSTEM\_SYSTIMER\_RST in register SYSTEM\_PERIP\_RST\_EN0\_REG: reset system timer.

Note that if the timer is reset, its registers will be restored to their default values. For more information, please refer to Table Peripheral Clock Gating and Reset in Chapter 16 System Registers (SYSREG) .

## 10.4 Functional Description

Figure 10.4-1. System Timer Alarm Generation

![Image](images/10_Chapter_10_img003_5a1ce8a8.png)

Figure 10.4-1 shows the procedure to generate alarm in system timer. In this process, one timer counter and one timer comparator are used. An alarm interrupt will be generated accordingly based on the comparison result in comparator.

## 10.4.1 Counter

The system timer has two 52-bit timer counters, shown as UNITn (n = 0 or 1). Their counting clock source is a 16 MHz clock, i.e. CNT\_CLK. Whether UNITn works or not is controlled by two bits in register SYSTIMER\_CONF\_REG:

- SYSTIMER\_TIMER\_UNITn\_WORK\_EN: set this bit to enable the counter UNITn in system timer.
- SYSTIMER\_TIMER\_UNITn\_CORE0\_STALL\_EN: if this bit is set, the counter UNITn stops when CPU is stalled. The counter continues its counting after the CPU resumes.

The configuration of the two bits to control the counter UNITn is shown below, assuming that CPU is stalled.

Table 10.4-1. UNITn Configuration Bits

|   SYSTIMER_TIMER_  UNITn_WORK_EN | SYSTIMER_TIMER_  UNITn_CORE0_STALL_EN   | Counter UNITn                                                        |
|----------------------------------|-----------------------------------------|----------------------------------------------------------------------|
|                                0 | x *                                     | Not at work                                                          |
|                                1 | 1                                       | Stop counting, but will continue its counting after the CPU resumes. |
|                                1 | 0                                       | Keep counting                                                        |

When the counter UNITn is at work, the count value is incremented on each counting cycle. When the counter UNITn is stopped, the count value stops increasing and keeps unchanged.

The lower 32 and higher 20 bits of initial count value are loaded from the registers

SYSTIMER\_TIMER\_UNITn\_LOAD

\_LO and SYSTIMER\_TIMER\_UNITn\_LOAD\_HI. Writing 1 to the bit SYSTIMER\_TIMER\_UNITn\_LOAD will trigger a reload event, and the current count value will be changed immediately. If UNITn is at work, the counter will continue to count up from the new reloaded value.

Writing 1 to SYSTIMER\_TIMER\_UNITn\_UPDATE will trigger an update event. The lower 32 and higher 20 bits of current count value will be locked into the registers SYSTIMER\_TIMER\_UNITn\_VALUE\_LO and SYSTIMER\_TIMER\_

UNITn\_VALUE\_HI, and then SYSTIMER\_TIMER\_UNITn\_VALUE\_VALID is asserted. Before the next update event, the values of SYSTIMER\_TIMER\_UNITn\_VALUE\_LO and SYSTIMER\_TIMER\_UNITn\_VALUE\_HI remain unchanged.

## 10.4.2 Comparator and Alarm

The system timer has three 52-bit comparators, shown as COMPx (x = 0, 1, or 2). The comparators can generate independent interrupts based on different alarm values (t) or alarm periods (δt).

Configure SYSTIMER\_TARGETx\_PERIOD\_MODE to choose from the two alarm modes for each COMPx:

- 1: select period mode
- 0: select target mode

In period mode, the alarm period (δt) is provided by the register SYSTIMER\_TARGETx\_PERIOD. Assuming that current count value is t1, when it reaches (t1 + δt), an alarm interrupt will be generated. Another alarm interrupt also will be generated when the count value reaches (t1 + 2*δt). By such way, periodic alarms are generated.

In target mode, the lower 32 bits and higher 20 bits of the alarm value (t) are provided by SYSTIMER\_TIMER\_TARGET

ESP32-C3 TRM (Version 1.3)

- x\_LO and SYSTIMER\_TIMER\_TARGETx\_HI. Assuming that current count value is t2 (t2 &lt;= t), an alarm interrupt will be generated when the count value reaches the alarm value (t). Unlike in period mode, only one alarm interrupt is generated in target mode.

SYSTIMER\_TARGETx\_TIMER\_UNIT\_SEL is used to choose the count value from which timer counter to be compared for alarm:

- 1: use the count value from UNIT1
- 0: use the count value from UNIT0

Finally, set SYSTIMER\_TARGETx\_WORK\_EN and COMPx starts to compare the count value with the alarm value (t) in target mode or with the alarm period (t1 + n*δt) in period mode.

An alarm is generated when the count value equals to the alarm value (t) in target mode or to the start value + n*alarm period δt (n = 1,2,3...) in period mode. But if the alarm value (t) set in registers is less than current count value, i.e. the target has already passed, or current count value is larger than the target value (t) within a range (0 ~ 2 51 -1), an alarm interrupt also is generated immediately. The relationship between current count value t c , the alarm value t t and alarm trigger point is shown below.

Table 10.4-2. Trigger Point

| Relationship Between t c  and t t                                                                  | Trigger Point                                                                                                                                                 |
|----------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------|
| t c -  t t  <= 0                                                                                   | t c  =  t t , an alarm is triggered.                                                                                                                          |
| 0 <= t c  -  t t  < 2 51  - 1 ( t c  < 2 51  and t t  < 2 51 , or t c  >= 2 51  and t t  >= 2 51 ) | An alarm is triggered immediately.                                                                                                                            |
| t c  -  t t  >= 2 51  - 1                                                                          | t c  overflows after counting to its maximum value 52’hfffffffffffff, and then starts counting up from 0. When its value reaches t t , an alarm is triggered. |

## 10.4.3 Synchronization Operation

The clock (APB\_CLK) used in software operation is not the same one as the timer counters and comparators working on CNT\_CLK. Synchronization is needed for some configuration registers. A complete synchronization action takes two steps:

1. Software writes suitable values to configuration fields, see the first column in Table 10.4-3 .
2. Software writes 1 to corresponding bits to start synchronization, see the second column in Table 10.4-3 .

Table 10.4-3. Synchronization Operation

| Configuration Fields                                                        | Synchronization Enable Bit   |
|-----------------------------------------------------------------------------|------------------------------|
| SYSTIMER_TIMER_UNITn_LOAD_LO SYSTIMER_TIMER_UNITn_LOAD_HI                   | SYSTIMER_TIMER_UNITn_LOAD    |
| SYSTIMER_TARGETx_PERIOD SYSTIMER_TIMER_TARGETx_HI SYSTIMER_TIMER_TARGETx_LO | SYSTIMER_TIMER_COMPx_LOAD    |

## 10.4.4 Interrupt

Each comparator has one level-type alarm interrupt, named as SYSTIMER\_TARGETx\_INT. Interrupts signal is asserted high when the comparator starts to alarm. Until the interrupt is cleared by software, it remains high. To enable interrupts, set the bit SYSTIMER\_TARGETx\_INT\_ENA .

## 10.5 Programming Procedure

When configuring COMPx and UNITn, please ensure the corresponding COMP and UNIT are at work.

## 10.5.1 Read Current Count Value

1. Set SYSTIMER\_TIMER\_UNITn\_UPDATE to update the current count value into SYSTIMER\_TIMER\_UNITn \_ VALUE\_HI and SYSTIMER\_TIMER\_UNITn\_VALUE\_LO .
2. Poll the reading of SYSTIMER\_TIMER\_UNITn\_VALUE\_VALID, till it's 1, which means user now can read the count value from SYSTIMER\_TIMER\_UNITn\_VALUE\_HI and SYSTIMER\_TIMER\_UNITn\_VALUE\_LO .
3. Read the lower 32 bits and higher 20 bits from SYSTIMER\_TIMER\_UNITn\_VALUE\_LO and SYSTIMER\_TIMER\_UNITn\_VALUE\_HI .

## 10.5.2 Configure One-Time Alarm in Target Mode

1. Set SYSTIMER\_TARGETx\_TIMER\_UNIT\_SEL to select the counter (UNIT0 or UNIT1) used for COMPx .
2. Read current count value, see Section 10.5.1. This value will be used to calculate the alarm value (t) in Step 4.
3. Clear SYSTIMER\_TARGETx\_PERIOD\_MODE to enable target mode.
4. Set an alarm value (t), and fill its lower 32 bits to SYSTIMER\_TIMER\_TARGETx\_LO, and the higher 20 bits to SYSTIMER\_TIMER\_TARGETx\_HI .
5. Set SYSTIMER\_TIMER\_COMPx\_LOAD to synchronize the alarm value (t) to COMPx, i.e. load the alarm value (t) to the COMPx .
6. Set SYSTIMER\_TARGETx\_WORK\_EN to enable the selected COMPx. COMPx starts comparing the count value with the alarm value (t).
7. Set SYSTIMER\_TARGETx\_INT\_ENA to enable timer interrupt. When Unitn counts to the alarm value (t), a SYSTIMER\_TARGETx\_INT interrupt is triggered.

## 10.5.3 Configure Periodic Alarms in Period Mode

1. Set SYSTIMER\_TARGETx\_TIMER\_UNIT\_SEL to select the counter (UNIT0 or UNIT1) used for COMPx .
2. Set an alarm period (δt), and fill it to SYSTIMER\_TARGETx\_PERIOD .
3. Set SYSTIMER\_TIMER\_COMPx\_LOAD to synchronize the alarm period (δt) to COMPx, i.e. load the alarm period (δt) to COMPx .
4. Clear and then set SYSTIMER\_TARGETx\_PERIOD\_MODE to configure COMPx into period mode.

5. Set SYSTIMER\_TARGETx\_WORK\_EN to enable the selected COMPx. COMPx starts comparing the count value with the sum of start value + n*δt (n = 1, 2, 3...).
6. Set SYSTIMER\_TARGETx\_INT\_ENA to enable timer interrupt. A SYSTIMER\_TARGETx\_INT interrupt is triggered when Unitn counts to start value + n*δt (n = 1, 2, 3...) set in step 2.

## 10.5.4 Update After Light-sleep

1. Configure the RTC timer before the chip goes to Light-sleep, to record the exact sleep time. For more information, see Chapter 9 Low-power Management .
2. Read the sleep time from the RTC timer when the chip is woken up from Light-sleep.
3. Read current count value of system timer, see Section 10.5.1 .
4. Convert the time value recorded by the RTC timer from the clock cycles based on RTC\_SLOW\_CLK to that based on 16 MHz CNT\_CLK. For example, if the frequency of RTC\_SLOW\_CLK is 32 KHz, the recorded RTC timer value should be converted by multiplying by 500.
5. Add the converted RTC value to the current count value of the system timer:
- Fill the new value into SYSTIMER\_TIMER\_UNITn\_LOAD\_LO (low 32 bits) and SYSTIMER\_TIMER\_UNITn\_LOAD\_HI (high 20 bits).
- Set SYSTIMER\_TIMER\_UNITn\_LOAD to load new timer value into system timer. By such way, the system timer is updated.

## 10.6 Register Summary

The addresses in this section are relative to system timer base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                      | Description                               | Address                                   | Access                                    |
|-------------------------------------------|-------------------------------------------|-------------------------------------------|-------------------------------------------|
| Clock Control Register                    | Clock Control Register                    | Clock Control Register                    | Clock Control Register                    |
| SYSTIMER_CONF_REG                         | Configure system timer clock              | 0x0000                                    | R/W                                       |
| UNIT0 Control and Configuration Registers | UNIT0 Control and Configuration Registers | UNIT0 Control and Configuration Registers | UNIT0 Control and Configuration Registers |
| SYSTIMER_UNIT0_OP_REG                     | Read UNIT0 value to registers             | 0x0004                                    | varies                                    |
| SYSTIMER_UNIT0_LOAD_HI_REG                | High 20 bits to be loaded to UNIT0        | 0x000C                                    | R/W                                       |
| SYSTIMER_UNIT0_LOAD_LO_REG                | Low 32 bits to be loaded to UNIT0         | 0x0010                                    | R/W                                       |
| SYSTIMER_UNIT0_VALUE_HI_REG               | UNIT0 value, high 20 bits                 | 0x0040                                    | RO                                        |
| SYSTIMER_UNIT0_VALUE_LO_REG               | UNIT0 value, low 32 bits                  | 0x0044                                    | RO                                        |
| SYSTIMER_UNIT0_LOAD_REG                   | UNIT0 synchronization register            | 0x005C                                    | WT                                        |
| UNIT1 Control and Configuration Registers | UNIT1 Control and Configuration Registers | UNIT1 Control and Configuration Registers | UNIT1 Control and Configuration Registers |
| SYSTIMER_UNIT1_OP_REG                     | Read UNIT1 value to registers             | 0x0008                                    | varies                                    |
| SYSTIMER_UNIT1_LOAD_HI_REG                | High 20 bits to be loaded to UNIT1        | 0x0014                                    | R/W                                       |
| SYSTIMER_UNIT1_LOAD_LO_REG                | Low 32 bits to be loaded to UNIT1         | 0x0018                                    | R/W                                       |
| SYSTIMER_UNIT1_VALUE_HI_REG               | UNIT1 value, high 20 bits                 | 0x0048                                    | RO                                        |
| SYSTIMER_UNIT1_VALUE_LO_REG               | UNIT1 value, low 32 bits                  | 0x004C                                    | RO                                        |

| Name                                            | Description                                     | Address                                         | Access                                          |
|-------------------------------------------------|-------------------------------------------------|-------------------------------------------------|-------------------------------------------------|
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
| SYSTIMER_INT_RAW_REG                            | Interrupt raw register of system timer          | 0x0068                                          | R/WTC/SS                                        |
| SYSTIMER_INT_CLR_REG                            | Interrupt clear register of system timer        | 0x006C                                          | WT                                              |
| SYSTIMER_INT_ST_REG                             | Interrupt status register of system timer       | 0x0070                                          | RO                                              |
| Version Register                                | Version Register                                | Version Register                                | Version Register                                |
| SYSTIMER_DATE_REG                               | Version control register                        | 0x00FC                                          | R/W                                             |

![Image](images/10_Chapter_10_img004_7c6acb0e.png)

## 10.7 Registers

The addresses in this section are relative to system timer base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 10.1. SYSTIMER\_CONF\_REG (0x0000)

![Image](images/10_Chapter_10_img005_90b02e2a.png)

Register 10.2. SYSTIMER\_UNIT0\_OP\_REG (0x0004)

![Image](images/10_Chapter_10_img006_28dd2090.png)

SYSTIMER\_TIMER\_UNIT0\_VALUE\_VALID Timer value is synchronized and valid. (R/SS/WTC)

SYSTIMER\_TIMER\_UNIT0\_UPDATE Update timer UNIT0, i.e. read the UNIT0 count value to SYS-TIMER\_TIMER\_UNIT0\_VALUE\_HI and SYSTIMER\_TIMER\_UNIT0\_VALUE\_LO. (WT)

Register 10.3. SYSTIMER\_UNIT0\_LOAD\_HI\_REG (0x000C)

![Image](images/10_Chapter_10_img007_7cf85f2a.png)

SYSTIMER\_TIMER\_UNIT0\_LOAD\_HI The value to be loaded to UNIT0, high 20 bits. (R/W)

Register 10.4. SYSTIMER\_UNIT0\_LOAD\_LO\_REG (0x0010)

![Image](images/10_Chapter_10_img008_bdf9a190.png)

SYSTIMER\_TIMER\_UNIT0\_LOAD\_LO The value to be loaded to UNIT0, low 32 bits. (R/W)

Register 10.5. SYSTIMER\_UNIT0\_VALUE\_HI\_REG (0x0040)

![Image](images/10_Chapter_10_img009_6589c15b.png)

SYSTIMER\_TIMER\_UNIT0\_VALUE\_HI UNIT0 read value, high 20 bits. (RO)

Register 10.6. SYSTIMER\_UNIT0\_VALUE\_LO\_REG (0x0044)

![Image](images/10_Chapter_10_img010_4bdbdcc9.png)

SYSTIMER\_TIMER\_UNIT0\_VALUE\_LO UNIT0 read value, low 32 bits. (RO)

Register 10.7. SYSTIMER\_UNIT0\_LOAD\_REG (0x005C)

![Image](images/10_Chapter_10_img011_2206a637.png)

SYSTIMER\_TIMER\_UNIT0\_LOAD UNIT0 synchronization enable signal. Set this bit to reload the values of SYSTIMER\_TIMER\_UNIT0\_LOAD\_HI and SYSTIMER\_TIMER\_UNIT0\_LOAD\_LO to UNIT0. (WT)

## Register 10.8. SYSTIMER\_UNIT1\_OP\_REG (0x0008)

![Image](images/10_Chapter_10_img012_faf6ca30.png)

SYSTIMER\_TIMER\_UNIT1\_VALUE\_VALID UNIT1 value is synchronized and valid. (R/SS/WTC)

SYSTIMER\_TIMER\_UNIT1\_UPDATE Update timer UNIT1, i.e. read the UNIT1 count value to SYS-TIMER\_TIMER\_UNIT1\_VALUE\_HI and SYSTIMER\_TIMER\_UNIT1\_VALUE\_LO. (WT)

## Register 10.9. SYSTIMER\_UNIT1\_LOAD\_HI\_REG (0x0014)

![Image](images/10_Chapter_10_img013_eeaccadc.png)

SYSTIMER\_TIMER\_UNIT1\_LOAD\_HI The value to be loaded to UNIT1, high 20 bits. (R/W)

## Register 10.10. SYSTIMER\_UNIT1\_LOAD\_LO\_REG (0x0018)

![Image](images/10_Chapter_10_img014_67ffca11.png)

SYSTIMER\_TIMER\_UNIT1\_LOAD\_LO The value to be loaded to UNIT1, low 32 bits. (R/W)

Register 10.11. SYSTIMER\_UNIT1\_VALUE\_HI\_REG (0x0048)

![Image](images/10_Chapter_10_img015_d4f8582a.png)

SYSTIMER\_TIMER\_UNIT1\_VALUE\_HI UNIT1 read value, high 20 bits. (RO)

Register 10.12. SYSTIMER\_UNIT1\_VALUE\_LO\_REG (0x004C)

![Image](images/10_Chapter_10_img016_5cd4bfc8.png)

SYSTIMER\_TIMER\_UNIT1\_VALUE\_LO UNIT1 read value, low 32 bits. (RO)

Register 10.13. SYSTIMER\_UNIT1\_LOAD\_REG (0x0060)

![Image](images/10_Chapter_10_img017_a231dae0.png)

SYSTIMER\_TIMER\_UNIT1\_LOAD UNIT1 synchronization enable signal. Set this bit to reload the values of SYSTIMER\_TIMER\_UNIT1\_LOAD\_HI and SYSTIMER\_TIMER\_UNIT1\_LOAD\_LO to UNIT1. (WT)

Register 10.14. SYSTIMER\_TARGET0\_HI\_REG (0x001C)

![Image](images/10_Chapter_10_img018_2c346e8e.png)

SYSTIMER\_TIMER\_TARGET0\_HI The alarm value to be loaded to COMP0, high 20 bits. (R/W)

## Register 10.15. SYSTIMER\_TARGET0\_LO\_REG (0x0020)

![Image](images/10_Chapter_10_img019_19545c1d.png)

SYSTIMER\_TIMER\_TARGET0\_LO The alarm value to be loaded to COMP0, low 32 bits. (R/W)

## Register 10.16. SYSTIMER\_TARGET0\_CONF\_REG (0x0034)

![Image](images/10_Chapter_10_img020_c0d62e74.png)

SYSTIMER\_TARGET0\_PERIOD COMP0 alarm period. (R/W)

SYSTIMER\_TARGET0\_PERIOD\_MODE Set COMP0 to period mode. (R/W)

SYSTIMER\_TARGET0\_TIMER\_UNIT\_SEL Select which unit to compare for COMP0. (R/W)

## Register 10.17. SYSTIMER\_COMP0\_LOAD\_REG (0x0050)

![Image](images/10_Chapter_10_img021_07ebf63d.png)

Register 10.18. SYSTIMER\_TARGET1\_HI\_REG (0x0024)

![Image](images/10_Chapter_10_img022_594efa69.png)

SYSTIMER\_TIMER\_TARGET1\_HI The alarm value to be loaded to COMP1, high 20 bits. (R/W)

## Register 10.19. SYSTIMER\_TARGET1\_LO\_REG (0x0028)

![Image](images/10_Chapter_10_img023_deacee21.png)

SYSTIMER\_TIMER\_TARGET1\_LO The alarm value to be loaded to COMP1, low 32 bits. (R/W)

Register 10.20. SYSTIMER\_TARGET1\_CONF\_REG (0x0038)

![Image](images/10_Chapter_10_img024_7a3d3844.png)

SYSTIMER\_TARGET1\_PERIOD COMP1 alarm period. (R/W)

SYSTIMER\_TARGET1\_PERIOD\_MODE Set COMP1 to period mode. (R/W)

SYSTIMER\_TARGET1\_TIMER\_UNIT\_SEL Select which unit to compare for COMP1. (R/W)

Register 10.21. SYSTIMER\_COMP1\_LOAD\_REG (0x0054)

![Image](images/10_Chapter_10_img025_d302ca26.png)

SYSTIMER\_TIMER\_COMP1\_LOAD COMP1 synchronization enable signal. Set this bit to reload the alarm value/period to COMP1. (WT)

Register 10.22. SYSTIMER\_TARGET2\_HI\_REG (0x002C)

![Image](images/10_Chapter_10_img026_730c51fb.png)

SYSTIMER\_TIMER\_TARGET2\_HI The alarm value to be loaded to COMP2, high 20 bits. (R/W)

## Register 10.23. SYSTIMER\_TARGET2\_LO\_REG (0x0030)

![Image](images/10_Chapter_10_img027_8cde1fc2.png)

SYSTIMER\_TIMER\_TARGET2\_LO The alarm value to be loaded to COMP2, low 32 bits. (R/W)

## Register 10.24. SYSTIMER\_TARGET2\_CONF\_REG (0x003C)

![Image](images/10_Chapter_10_img028_9ca9f5b5.png)

SYSTIMER\_TARGET2\_PERIOD COMP2 alarm period. (R/W)

SYSTIMER\_TARGET2\_PERIOD\_MODE Set COMP2 to period mode. (R/W)

SYSTIMER\_TARGET2\_TIMER\_UNIT\_SEL Select which unit to compare for COMP2. (R/W)

Register 10.25. SYSTIMER\_COMP2\_LOAD\_REG (0x0058)

![Image](images/10_Chapter_10_img029_1bd3f0cc.png)

SYSTIMER\_TIMER\_COMP2\_LOAD COMP2 synchronization enable signal. Set this bit to reload the alarm value/period to COMP2. (WT)

![Image](images/10_Chapter_10_img030_7fb2908a.png)

![Image](images/10_Chapter_10_img031_2eee5cd0.png)
