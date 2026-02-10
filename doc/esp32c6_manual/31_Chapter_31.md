---
chapter: 31
title: "Chapter 31"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 31

## Pulse Count Controller (PCNT)

The pulse count controller (PCNT) is designed to count input pulses. It can increment or decrement a pulse counter value by keeping track of rising (positive) or falling (negative) edges of the input pulse signal. The PCNT has four independent pulse counters called units, which have their groups of registers. There is only one clock in PCNT, which is APB\_CLK. In this chapter, n denotes the number of a unit from 0 ~ 3.

Each unit includes two channels (ch0 and ch1) which can independently increment or decrement its pulse counter value. The remainder of the chapter will mostly focus on channel 0 (ch0) as the functionality of the two channels is identical.

As shown in Figure 31.0-1, each channel has two input signals:

1. One input pulse signal (e.g. sig\_ch0\_un, the input pulse signal for ch0 of unit n ch0)
2. One control signal (e.g. ctrl\_ch0\_un, the control signal for ch0 of unit n ch0)

Figure 31.0-1. PCNT Block Diagram

![Image](images/31_Chapter_31_img001_ba1e85ec.png)

## 31.1 Features

A PCNT has the following features:

- Four independent pulse counters (units) that count from 1 to 65535
- Each unit consists of two independent channels sharing one pulse counter
- All channels have input pulse signals (e.g. sig\_ch0\_un) with their corresponding control signals (e.g. ctrl\_ch0\_un)

- Independently filter glitches of input pulse signals (sig\_ch0\_un and sig\_ch1\_un) and control signals (ctrl\_ch0\_un and ctrl\_ch1\_un) on each unit
- Each channel has the following parameters:
1. Selection between counting on positive or negative edges of the input pulse signal
2. Configuration to Increment, Decrement, or Disable counter mode for control signal's high and low states
- Maximum frequency of pulses: fAP B \_ CLK 2

## 31.2 Functional Description

Figure 31.2-1. PCNT Unit Architecture

![Image](images/31_Chapter_31_img002_aa74136d.png)

Figure 31.2-1 shows PCNT's architecture. As stated above, ctrl\_ch0\_un is the control signal for ch0 of unit n . Its high and low states can be assigned different counter modes and used for pulse counting of the channel's input pulse signal sig\_ch0\_un on negative or positive edges. The available counter modes are as follows:

- Increment mode: When a channel detects an active edge of sig\_ch0\_un (can be configured by software), the counter value pulse\_cnt increases by 1. Upon reaching PCNT\_CNT\_H\_LIM\_Un, pulse\_cnt is cleared. If the channel's counter mode is changed or if PCNT\_CNT\_PAUSE\_Un is set before pulse\_cnt reaches PCNT\_CNT\_H\_LIM\_Un, then pulse\_cnt freezes and its counter mode changes.

Table 31.2-1. Counter Mode. Positive Edge of Input Pulse Signal. Control Signal in Low State

| PCNT_CH0_POS_MODE_Un   | PCNT_CH0_LCTRL_MODE_Un   | Counter Mode   |
|------------------------|--------------------------|----------------|
| 1                      | 0                        | Increment      |
| 1                      | 1                        | Decrement      |
| 1                      | Others                   | Disable        |
| 2                      | 0                        | Decrement      |
| 2                      | 1                        | Increment      |
| 2                      | Others                   | Disable        |
| Others                 | N/A                      | Disable        |

Table 31.2-2. Counter Mode. Positive Edge of Input Pulse Signal. Control Signal in High State

| PCNT_CH0_POS_MODE_Un   | PCNT_CH0_HCTRL_MODE_Un   | Counter Mode   |
|------------------------|--------------------------|----------------|
| 1                      | 0                        | Increment      |
| 1                      | 1                        | Decrement      |
| 1                      | Others                   | Disable        |
| 2                      | 0                        | Decrement      |
| 2                      | 1                        | Increment      |
| 2                      | Others                   | Disable        |
| Others                 | N/A                      | Disable        |

- Decrement mode: When a channel detects an active edge of sig\_ch0\_un (can be configured by software), the counter value pulse\_cnt decreases by 1. Upon reaching PCNT\_CNT\_L\_LIM\_Un, pulse\_cnt is cleared. If the channel's counter mode is changed or if PCNT\_CNT\_PAUSE\_Un is set before pulse\_cnt reaches PCNT\_CNT\_L\_LIM\_Un, then pulse\_cnt freezes and its counter mode changes.
- Disable mode: Counting is disabled, and the counter value pulse\_cnt freezes.

Table 31.2-1 to Table 31.2-4 provide information on how to configure the counter mode for channel 0.

Each unit has one filter for all its control and input pulse signals. A filter can be enabled with the bit PCNT\_FILTER\_EN\_Un. The filter monitors the signals and ignores all the noise, i.e. the glitches with pulse widths shorter than PCNT\_FILTER\_THRES\_Un APB clock cycles in length.

As shown on Figure 31.2-1, each unit has two channels which process different input pulse signals and increase or decrease values via their respective inc\_dec modules, then the two channels send these values

Table 31.2-3. Counter Mode. Negative Edge of Input Pulse Signal. Control Signal in Low State

| PCNT_CH0_NEG_MODE_Un   | PCNT_CH0_LCTRL_MODE_Un   | Counter Mode   |
|------------------------|--------------------------|----------------|
| 1                      | 0                        | Increment      |
| 1                      | 1                        | Decrement      |
| 1                      | Others                   | Disable        |
| 2                      | 0                        | Decrement      |
| 2                      | 1                        | Increment      |
| 2                      | Others                   | Disable        |
| Others                 | N/A                      | Disable        |

Table 31.2-4. Counter Mode. Negative Edge of Input Pulse Signal. Control Signal in High State

| PCNT_CH0_NEG_MODE_Un   | PCNT_CH0_HCTRL_MODE_Un   | Counter Mode   |
|------------------------|--------------------------|----------------|
| 1                      | 0                        | Increment      |
| 1                      | 1                        | Decrement      |
| 1                      | Others                   | Disable        |
| 2                      | 0                        | Decrement      |
| 2                      | 1                        | Increment      |
| 2                      | Others                   | Disable        |
| Others                 | N/A                      | Disable        |

to the adder module which has a 16-bit wide signed register. This adder can be suspended by setting PCNT\_CNT\_PAUSE\_Un, and cleared by setting PCNT\_PULSE\_CNT\_RST\_Un .

The PCNT has five watchpoints that share one interrupt. The interrupt can be enabled or disabled by interrupt enable signals of each individual watchpoint.

- Maximum count value: When pulse\_cnt reaches PCNT\_CNT\_H\_LIM\_Un, a high limit interrupt is triggered and PCNT\_CNT\_THR\_H\_LIM\_LAT\_Un is high.
- Minimum count value: When pulse\_cnt reaches PCNT\_CNT\_L\_LIM\_Un, a low limit interrupt is triggered and
- PCNT\_CNT\_THR\_L\_LIM\_LAT\_Un is high.
- Two threshold values: When pulse\_cnt equals either PCNT\_CNT\_THRES0\_Un or PCNT\_CNT\_THRES1\_Un , an interrupt is triggered and either PCNT\_CNT\_THR\_THRES0\_LAT\_Un or PCNT\_CNT\_THR\_THRES1\_LAT\_Un is high respectively.
- Zero: When pulse\_cnt is 0, an interrupt is triggered and PCNT\_CNT\_THR\_ZERO\_LAT\_Un is valid.

If PCNT\_CNT\_H\_LIM\_Un and/or PCNT\_CNT\_L\_LIM\_Un are reconfigured by software when PCNT is working, the new configuration will take effect after pulse\_cnt counts to any of the above five watchpoints; If PCNT\_CNT\_THRES0\_Un and/or PCNT\_CNT\_THRES1\_Un are reconfigured by software, the new configuration will take effect immediately.

## 31.3 Applications

In each unit, channel 0 and channel 1 can be configured to work independently or together. The three subsections below provide details of channel 0 incrementing independently, channel 0 decrementing independently, and channel 0 and channel 1 incrementing together. For other working modes not elaborated in this section (e.g. channel 1 incrementing/decremeting independently, or one channel incrementing while the other decrementing), reference can be made to these three subsections.

## 31.3.1 Channel 0 Incrementing Independently

Figure 31.3-1. Channel 0 Up Counting Diagram

![Image](images/31_Chapter_31_img003_10b9b06f.png)

Figure 31.3-1 illustrates how channel 0 is configured to increment independently on the positive edge of sig\_ch0\_un while channel 1 is disabled (see subsection 31.2 for how to disable channel 1). The configuration of channel 0 is shown below.

- PCNT\_CH0\_LCTRL\_MODE\_Un=0: When ctrl\_ch0\_un is low, the counter mode specified for the low state turns on, in this case it is Increment mode.
- PCNT\_CH0\_HCTRL\_MODE\_Un=2: When ctrl\_ch0\_un is high, the counter mode specified for the low state turns on, in this case it is Disable mode.
- PCNT\_CH0\_POS\_MODE\_Un=1: The counter increments on the positive edge of sig\_ch0\_un .
- PCNT\_CH0\_NEG\_MODE\_Un=0: The counter idles on the negative edge of sig\_ch0\_un .
- PCNT\_CNT\_H\_LIM\_Un=5: When pulse\_cnt counts up to PCNT\_CNT\_H\_LIM\_Un, it is cleared.

## 31.3.2 Channel 0 Decrementing Independently

Figure 31.3-2. Channel 0 Down Counting Diagram

![Image](images/31_Chapter_31_img004_5cee6eb6.png)

Figure 31.3-2 illustrates how channel 0 is configured to decrement independently on the positive edge of sig\_ch0\_un while channel 1 is disabled. The configuration of channel 0 in this case differs from that in Figure 31.3-1 in the following aspects:

- PCNT\_CH0\_POS\_MODE\_Un=2: the counter decrements on the positive edge of sig\_ch0\_un .
- PCNT\_CNT\_L\_LIM\_Un=-5: when pulse\_cnt counts down to PCNT\_CNT\_L\_LIM\_Un, it is cleared.

## 31.3.3 Channel 0 and Channel 1 Incrementing Together

Figure 31.3-3. Two Channels Up Counting Diagram

![Image](images/31_Chapter_31_img005_7878c33a.png)

Figure 31.3-3 illustrates how channel 0 and channel 1 are configured to increment on the positive edge of sig\_ch0\_un and sig\_ch1\_un respectively at the same time. It can be seen in Figure 31.3-3 that control signal ctrl\_ch0\_un and ctrl\_ch1\_un have the same waveform, so as input pulse signal sig\_ch0\_un and sig\_ch1\_un . The configuration procedure is shown below.

## · For channel 0:

- – PCNT\_CH0\_LCTRL\_MODE\_Un=0: When ctrl\_ch0\_un is low, the counter mode specified for the low state turns on, in this case it is Increment mode.
- – PCNT\_CH0\_HCTRL\_MODE\_Un=2: When ctrl\_ch0\_un is high, the counter mode specified for the low state turns on, in this case it is Disable mode.
- – PCNT\_CH0\_POS\_MODE\_Un=1: The counter increments on the positive edge of sig\_ch0\_un .
- – PCNT\_CH0\_NEG\_MODE\_Un=0: The counter idles on the negative edge of sig\_ch0\_un .

## · For channel 1:

- – PCNT\_CH1\_LCTRL\_MODE\_Un=0: When ctrl\_ch1\_un is low, the counter mode specified for the low state turns on, in this case it is Increment mode.
- – PCNT\_CH1\_HCTRL\_MODE\_Un=2: When ctrl\_ch1\_un is high, the counter mode specified for the low state turns on, in this case it is Disable mode.
- – PCNT\_CH1\_POS\_MODE\_Un=1: The counter increments on the positive edge of sig\_ch1\_un .
- – PCNT\_CH1\_NEG\_MODE\_Un=0: The counter idles on the negative edge of sig\_ch1\_un .
- PCNT\_CNT\_H\_LIM\_Un=10: When pulse\_cnt counts up to PCNT\_CNT\_H\_LIM\_Un, it is cleared.

## 31.4 Register Summary

The addresses in this section are relative to Pulse Count Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                   | Description                         | Address   | Access   |
|------------------------|-------------------------------------|-----------|----------|
| Configuration Register |                                     |           |          |
| PCNT_U0_CONF0_REG      | Configuration register 0 for unit 0 | 0x0000    | R/W      |
| PCNT_U0_CONF1_REG      | Configuration register 1 for unit 0 | 0x0004    | R/W      |
| PCNT_U0_CONF2_REG      | Configuration register 2 for unit 0 | 0x0008    | R/W      |
| PCNT_U1_CONF0_REG      | Configuration register 0 for unit 1 | 0x000C    | R/W      |
| PCNT_U1_CONF1_REG      | Configuration register 1 for unit 1 | 0x0010    | R/W      |
| PCNT_U1_CONF2_REG      | Configuration register 2 for unit 1 | 0x0014    | R/W      |
| PCNT_U2_CONF0_REG      | Configuration register 0 for unit 2 | 0x0018    | R/W      |
| PCNT_U2_CONF1_REG      | Configuration register 1 for unit 2 | 0x001C    | R/W      |
| PCNT_U2_CONF2_REG      | Configuration register 2 for unit 2 | 0x0020    | R/W      |
| PCNT_U3_CONF0_REG      | Configuration register 0 for unit 3 | 0x0024    | R/W      |
| PCNT_U3_CONF1_REG      | Configuration register 1 for unit 3 | 0x0028    | R/W      |
| PCNT_U3_CONF2_REG      | Configuration register 2 for unit 3 | 0x002C    | R/W      |
| PCNT_CTRL_REG          | Control register for all counters   | 0x0060    | R/W      |
| Status Register        |                                     |           |          |
| PCNT_U0_CNT_REG        | Counter value for unit 0            | 0x0030    | RO       |
| PCNT_U1_CNT_REG        | Counter value for unit 1            | 0x0034    | RO       |
| PCNT_U2_CNT_REG        | Counter value for unit 2            | 0x0038    | RO       |
| PCNT_U3_CNT_REG        | Counter value for unit 3            | 0x003C    | RO       |
| PCNT_U0_STATUS_REG     | PNCT UNIT0 status register          | 0x0050    | RO       |
| PCNT_U1_STATUS_REG     | PNCT UNIT1 status register          | 0x0054    | RO       |
| PCNT_U2_STATUS_REG     | PNCT UNIT2 status register          | 0x0058    | RO       |
| PCNT_U3_STATUS_REG     | PNCT UNIT3 status register          | 0x005C    | RO       |
| Interrupt Register     |                                     |           |          |
| PCNT_INT_RAW_REG       | Interrupt raw status register       | 0x0040    | RO       |
| PCNT_INT_ST_REG        | Interrupt status register           | 0x0044    | RO       |
| PCNT_INT_ENA_REG       | Interrupt enable register           | 0x0048    | R/W      |
| PCNT_INT_CLR_REG       | Interrupt clear register            | 0x004C    | WO       |
| Version Register       |                                     |           |          |
| PCNT_DATE_REG          | PCNT version control register       | 0x00FC    | R/W      |

## 31.5 Registers

The addresses in this section are relative to Pulse Count Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 31.1. PCNT\_Un\_CONF0\_REG (n: 0-3) (0x0000+0xC*n)

![Image](images/31_Chapter_31_img006_addb34cd.png)

PCNT\_FILTER\_THRES\_Un Configures the maximum threshold for the filter. Any pulses with width less than this will be ignored when the filter is enabled.

Measurement unit: APB\_CLK cycles.

(R/W)

PCNT\_FILTER\_EN\_Un This is the enable bit for unit n's input filter. (R/W)

PCNT\_THR\_ZERO\_EN\_Un This is the enable bit for unit n's zero comparator. (R/W)

PCNT\_THR\_H\_LIM\_EN\_Un This is the enable bit for unit n's thr\_h\_lim comparator. Configures it to enable the high limit interrupt.(R/W)

PCNT\_THR\_L\_LIM\_EN\_Un This is the enable bit for unit n's thr\_l\_lim comparator. Configures it to enable the low limit interrupt.(R/W)

PCNT\_THR\_THRES0\_EN\_Un This is the enable bit for unit n's thres0 comparator. (R/W)

PCNT\_THR\_THRES1\_EN\_Un This is the enable bit for unit n's thres1 comparator. (R/W)

PCNT\_CH0\_NEG\_MODE\_Un Configures the behavior when the signal input of channel 0 detects a negative edge.

1: Increment the counter

2: Decrement the counter

0, 3: No effect

(R/W)

PCNT\_CH0\_POS\_MODE\_Un Configures the behavior when the signal input of channel 0 detects a positive edge.

1: Increment the counter

2: Decrement the counter

0, 3: No effect

(R/W)

PCNT\_CH0\_HCTRL\_MODE\_Un Configures how the CHn\_POS\_MODE/CHn\_NEG\_MODE settings will be modified when the control signal is high.

0: No modification

1: Invert behavior (increase → decrease, decrease → increase)

2, 3: Inhibit counter modification

(R/W)

Continued on the next page...

Register 31.1. PCNT\_Un\_CONF0\_REG (n: 0-3) (0x0000+0xC*n)

## Continued from the previous page...

PCNT\_CH0\_LCTRL\_MODE\_Un Configures how the CHn\_POS\_MODE/CHn\_NEG\_MODE settings will be modified when the control signal is low.

- 0: No modification
- 1: Invert behavior (increase → decrease, decrease → increase)
- 2, 3: Inhibit counter modification

(R/W)

PCNT\_CH1\_NEG\_MODE\_Un Configures the behavior when the signal input of channel 1 detects a negative edge.

- 1: Increment the counter
- 2: Decrement the counter
- 0, 3: No effect

(R/W)

PCNT\_CH1\_POS\_MODE\_Un Configures the behavior when the signal input of channel 1 detects a positive edge.

- 1: Increment the counter
- 2: Decrement the counter
- 0, 3: No effect

(R/W)

PCNT\_CH1\_HCTRL\_MODE\_Un Configures how the CHn\_POS\_MODE/CHn\_NEG\_MODE settings will be modified when the control signal is high.

- 0: No modification
- 1: Invert behavior (increase → decrease, decrease → increase)
- 2, 3: Inhibit counter modification

(R/W)

PCNT\_CH1\_LCTRL\_MODE\_Un Configures how the CHn\_POS\_MODE/CHn\_NEG\_MODE settings will be modified when the control signal is low.

- 0: No modification
- 1: Invert behavior (increase → decrease, decrease → increase)
- 2, 3: Inhibit counter modification

(R/W)

Register 31.2. PCNT\_Un\_CONF1\_REG (n: 0-3) (0x0004+0xC*n)

![Image](images/31_Chapter_31_img007_af836937.png)

PCNT\_CNT\_THRES0\_Un Configures the thres0 value for unit n. (R/W)

PCNT\_CNT\_THRES1\_Un Configures the thres1 value for unit n. (R/W)

Register 31.3. PCNT\_Un\_CONF2\_REG (n: 0-3) (0x0008+0xC*n)

![Image](images/31_Chapter_31_img008_b168821a.png)

PCNT\_CNT\_H\_LIM\_Un Configures the thr\_h\_lim value for unit n. When pulse\_cnt reaches this value, the counter will be cleared to 0. (R/W)

PCNT\_CNT\_L\_LIM\_Un Configures the thr\_l\_lim value for unit n. When pulse\_cnt reaches this value, the counter will be cleared to 0.(R/W)

Register 31.4. PCNT\_CTRL\_REG (0x0060)

![Image](images/31_Chapter_31_img009_6bab3cc7.png)

PCNT\_PULSE\_CNT\_RST\_Un Write 1 to clear unit n's counter.

0: No effect

1: Clear

(R/W)

PCNT\_CNT\_PAUSE\_Un Write 1 to freeze unit n's counter.

0: No effect

1: Freeze

(R/W)

PCNT\_CLK\_EN Configures whether or not to enable the registers clock gate of PCNT module.

0: the clock for registers is enabled when registers are read and written

1: the clock for registers is always on

(R/W)

Register 31.5. PCNT\_Un\_CNT\_REG (n: 0-3) (0x0030+0x4*n)

![Image](images/31_Chapter_31_img010_f6f50af7.png)

PCNT\_PULSE\_CNT\_Un Represents the current pulse count value for unit n. (RO)

## Register 31.6. PCNT\_Un\_STATUS\_REG (n: 0-3) (0x0050+0x4*n)

![Image](images/31_Chapter_31_img011_32916ced.png)

PCNT\_CNT\_THR\_ZERO\_MODE\_Un Represents the pulse counter status of PCNT\_Un corresponding to 0.

0: pulse counter decreases from positive to 0

1: pulse counter increases from negative to 0

- 2: pulse counter is negative
- 3: pulse counter is positive

(RO)

PCNT\_CNT\_THR\_THRES1\_LAT\_Un Represents the latched value of thres1 event of PCNT\_Un when threshold event interrupt is valid.

- 0: others

1: the current pulse counter equals to thres1 and thres1 event is valid

(RO)

PCNT\_CNT\_THR\_THRES0\_LAT\_Un Represents the latched value of thres0 event of PCNT\_Un when threshold event interrupt is valid.

- 0: others

1: the current pulse counter equals to thres0 and thres0 event is valid

(RO)

PCNT\_CNT\_THR\_L\_LIM\_LAT\_Un Represents the latched value of low limit event of PCNT\_Un when threshold event interrupt is valid.

- 0: others

1: the current pulse counter equals to thr\_l\_lim and low limit event is valid.

(RO)

PCNT\_CNT\_THR\_H\_LIM\_LAT\_Un

Represents the latched value of high limit event of PCNT\_Un when threshold event interrupt is valid.

- 0: others

1: the current pulse counter equals to thr\_h\_lim and high limit event is valid.

(RO)

PCNT\_CNT\_THR\_ZERO\_LAT\_Un Represents the latched value of zero threshold event of PCNT\_Un when threshold event interrupt is valid.

- 0: others

1: the current pulse counter equals to 0 and zero threshold event is valid.

(RO)

![Image](images/31_Chapter_31_img012_5d6c46a4.png)

![Image](images/31_Chapter_31_img013_8c6845ad.png)
