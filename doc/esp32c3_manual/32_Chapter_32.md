---
chapter: 32
title: "Chapter 32"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 32

## LED PWM Controller (LEDC)

## 32.1 Overview

The LED PWM Controller is a peripheral designed to generate PWM signals for LED control. It has specialized features such as automatic duty cycle fading. However, the LED PWM Controller can also be used to generate PWM signals for other purposes.

## 32.2 Features

The LED PWM Controller has the following features:

- Six independent PWM generators (i.e. six channels)
- Four independent timers that support division by fractions
- Automatic duty cycle fading (i.e. gradual increase/decrease of a PWM's duty cycle without interference from the processor) with interrupt generation on fade completion
- Adjustable phase of PWM signal output
- PWM signal output in low-power mode (Light-sleep mode)
- Maximum PWM resolution: 14 bits

Note that the four timers are identical regarding their features and operation. The following sections refer to the timers collectively as Timerx (where x ranges from 0 to 3). Likewise, the six PWM generators are also identical in features and operation, and thus are collectively referred to as PWMn (where n ranges from 0 to 5).

![Image](images/32_Chapter_32_img001_ac69bbb5.png)

Figure 32.2-1. LED PWM Architecture

![Image](images/32_Chapter_32_img002_e26d1887.png)

## 32.3 Functional Description

## 32.3.1 Architecture

Figure 32.2-1 shows the architecture of the LED PWM Controller.

The four timers can be independently configured (i.e. configurable clock divider, and counter overflow value) and each internally maintains a timebase counter (i.e. a counter that counts on cycles of a reference clock). Each PWM generator selects one of the timers and uses the timer's counter value as a reference to generate its PWM signal.

Figure 32.3-1 illustrates the main functional blocks of the timer and the PWM generator.

![Image](images/32_Chapter_32_img003_a4b57a0f.png)

Figure 32.3-1. LED PWM Generator Diagram

## 32.3.2 Timers

Each timer in LED PWM Controller internally maintains a timebase counter. Referring to Figure 32.3-1, this clock signal used by the timebase counter is named ref\_pulsex. All timers use the same clock source LEDC\_CLKx , which is then passed through a clock divider to generate ref\_pulsex for the counter.

## 32.3.2.1 Clock Source

LED PWM registers configured by software are clocked by APB\_CLK. For more information about APB\_CLK, see Chapter 6 Reset and Clock. To use the LED PWM peripheral, the APB\_CLK signal to the LED PWM has to be enabled. The APB\_CLK signal to LED PWM can be enabled by setting the SYSTEM\_LEDC\_CLK\_EN field in the register SYSTEM\_PERIP\_CLK\_EN0\_REG and be reset via software by setting the SYSTEM\_LEDC\_RST field in the register SYSTEM\_PERIP\_RST\_EN0\_REG. For more information, please refer to Table 16.3-1 in Chapter 16 System Registers (SYSREG) .

Timers in the LED PWM Controller choose their common clock source from one of the following clock signals: APB\_CLK, RC\_FAST\_CLK and XTAL\_CLK (see Chapter 6 Reset and Clock for more details about each clock signal). The procedure for selecting a clock source signal for LEDC\_CLKx is described below:

- APB\_CLK: Set LEDC\_APB\_CLK\_SEL[1:0] to 1
- RC\_FAST\_CLK: Set LEDC\_APB\_CLK\_SEL[1:0] to 2
- XTAL\_CLK: Set LEDC\_APB\_CLK\_SEL[1:0] to 3

The LEDC\_CLKx signal will then be passed through the clock divider.

## 32.3.2.2 Clock Divider Configuration

The LEDC\_CLKx signal is passed through a clock divider to generate the ref\_pulsex signal for the counter. The frequency of ref\_pulsex is equal to the frequency of LEDC\_CLKx divided by the divisor LEDC\_CLK\_DIV (see Figure 32.3-1).

The divisor LEDC\_CLK\_DIV is a fractional value. Thus, it can be a non-integer. LEDC\_CLK\_DIV is configured according to the following equation.

<!-- formula-not-decoded -->

- A corresponds to the most significant 10 bits of LEDC\_CLK\_DIV\_TIMERx (i.e. LEDC\_TIMERx\_CONF\_REG[21:12])
- The fractional part B corresponds to the least significant 8 bits of LEDC\_CLK\_DIV\_TIMERx (i.e. LEDC\_TIMERx\_CONF\_REG[11:4])

When the fractional part B is zero, LEDC\_CLK\_DIV is equivalent to an integer divisor (i.e. an integer prescaler). In other words, a ref\_pulsex clock pulse is generated after every A number of LEDC\_CLKx clock pulses.

However, when B is nonzero, LEDC\_CLK\_DIV becomes a non-integer divisor. The clock divider implements non-integer frequency division by alternating between A and (A+1) LEDC\_CLKx clock pulses per ref\_pulsex clock pulse. This will result in the average frequency of ref\_pulsex clock pulse being the desired frequency (i.e. the non-integer divided frequency). For every 256 ref\_pulsex clock pulses:

- A number of B ref\_pulsex clock pulses will consist of (A+1) LEDC\_CLKx clock pulses
- A number of (256-B) ref\_pulsex clock pulses will consist of A LEDC\_CLKx clock pulses
- The ref\_pulsex clock pulses consisting of (A+1) pulses are evenly distributed amongst those consisting of A pulses

Figure 32.3-2 illustrates the relation between LEDC\_CLKx clock pulses and ref\_pulsex clock pulses when dividing by a non-integer LEDC\_CLK\_DIV .

Figure 32.3-2. Frequency Division When LEDC\_CLK\_DIV is a Non-Integer Value

![Image](images/32_Chapter_32_img004_9949ba69.png)

To change the timer's clock divisor at runtime, first configure the LEDC\_CLK\_DIV\_TIMERx field, and then set the LEDC\_TIMERx\_PARA\_UP field to apply the new configuration. This will cause the newly configured values to take effect upon the next overflow of the counter. The LEDC\_TIMERx\_PARA\_UP field will be automatically cleared by hardware.

## 32.3.2.3 14-bit Counter

Each timer contains a 14-bit timebase counter that uses ref\_pulsex as its reference clock (see Figure 32.3-1). The LEDC\_TIMERx\_DUTY\_RES field configures the overflow value of this 14-bit counter. Hence, the maximum resolution of the PWM signal is 14 bits. The counter counts up to 2 LEDC \_ T IMERx \_ DUT Y \_ RES − 1, overflows and begins counting from 0 again. The counter's value can be read, reset, and suspended by software.

The counter can trigger LEDC\_TIMERx\_OVF\_INT interrupt (generated automatically by hardware without configuration) every time the counter overflows. It can also be configured to trigger LEDC\_OVF\_CNT\_CHn\_INT interrupt after the counter overflows LEDC \_ OV F \_ NUM \_ CHn + 1 times. To configure LEDC\_OVF\_CNT\_CHn\_INT interrupt, please:

1. Configure LEDC\_TIMER\_SEL\_CHn as the counter for the PWM generator
2. Enable the counter by setting LEDC\_OVF\_CNT\_EN\_CHn
3. Set LEDC\_OVF\_NUM\_CHn to the number of counter overflows to generate an interrupt, minus 1
4. Enable the overflow interrupt by setting LEDC\_OVF\_CNT\_CHn\_INT\_ENA
5. Set LEDC\_TIMERx\_DUTY\_RES to enable the timer and wait for a LEDC\_OVF\_CNT\_CHn\_INT interrupt

Referring to Figure 32.3-1, the frequency of a PWM generator output signal (sig\_outn) is dependent on the frequency of the timer's clock source LEDC\_CLKx, the clock divisor LEDC\_CLK\_DIV, and the duty resolution (counter width) LEDC\_TIMERx\_DUTY\_RES:

<!-- formula-not-decoded -->

Based on the formula above, the desired duty resolution can be calculated as follows:

<!-- formula-not-decoded -->

Table 32.3-1 lists the commonly-used frequencies and their corresponding resolutions.

Table 32.3-1. Commonly-used Frequencies and Resolutions

| LEDC_CLKx         | PWM Frequency   |   Highest Resolution (bit)  1 |   Lowest Resolution (bit) |
|-------------------|-----------------|-------------------------------|---------------------------|
| APB_CLK (80 MHz)  | 1 kHz           |                            14 |                         7 |
| APB_CLK (80 MHz)  | 5 kHz           |                            13 |                         4 |
| APB_CLK (80 MHz)  | 10 kHz          |                            12 |                         3 |
| XTAL_CLK (40 MHz) | 1 kHz           |                            14 |                         6 |
| XTAL_CLK (40 MHz) | 4 kHz           |                            13 |                         4 |

Table 32.3-1. Commonly-used Frequencies and Resolutions

| LEDC_CLKx              | PWM Frequency   |   Highest Resolution (bit)  1 |   Lowest Resolution (bit)  2 |
|------------------------|-----------------|-------------------------------|------------------------------|
| RC_FAST_CLK (17.5 MHz) | 1 kHz           |                            14 |                            5 |
| RC_FAST_CLK (17.5 MHz) | 1.75 kHz        |                            13 |                            4 |

To change the overflow value at runtime, first set the LEDC\_TIMERx\_DUTY\_RES field, and then set the LEDC\_TIMERx\_PARA\_UP field. This will cause the newly configured values to take effect upon the next overflow of the counter. If LEDC\_OVF\_CNT\_EN\_CHn field is reconfigured, LEDC\_PARA\_UP\_CHn should be set to apply the new configuration. In summary, these configuration values need to be updated by setting LEDC\_TIMERx\_PARA\_UP or LEDC\_PARA\_UP\_CHn . LEDC\_TIMERx\_PARA\_UP and LEDC\_PARA\_UP\_CHn will be automatically cleared by hardware.

## 32.3.3 PWM Generators

To generate a PWM signal, a PWM generator (PWMn) selects a timer (Timerx). Each PWM generator can be configured separately by setting LEDC\_TIMER\_SEL\_CHn to use one of four timers to generate the PWM output.

As shown in Figure 32.3-1, each PWM generator has a comparator and two multiplexers. A PWM generator compares the timer's 14-bit counter value (Timerx\_cnt) to two trigger values Hpointn and Lpointn. When the timer's counter value is equal to Hpointn or Lpointn, the PWM signal is high or low, respectively, as described below:

- If Timerx\_cnt == Hpointn, sig\_outn is 1.
- If Timerx\_cnt == Lpointn, sig\_outn is 0.

Figure 32.3-3 illustrates how Hpointn or Lpointn are used to generate a fixed duty cycle PWM output signal.

For a particular PWM generator (PWMn), its Hpointn is sampled from the LEDC\_HPOINT\_CHn field each time the selected timer's counter overflows. Likewise, Lpointn is also sampled on every counter overflow and is calculated from the sum of the LEDC\_DUTY\_CHn[18:4] and LEDC\_HPOINT\_CHn fields. By setting Hpointn and Lpointn via the LEDC\_HPOINT\_CHn and LEDC\_DUTY\_CHn[18:4] fields, the relative phase and duty cycle of the PWM output can be set.

The PWM output signal (sig\_outn) is enabled by setting LEDC\_SIG\_OUT\_EN\_CHn. When LEDC\_SIG\_OUT\_EN\_CHn is cleared, PWM signal output is disabled, and the output signal (sig\_outn) will output a constant level as specified by LEDC\_IDLE\_LV\_CHn .

Figure 32.3-3. LED\_PWM Output Signal Diagram

![Image](images/32_Chapter_32_img005_f10abb34.png)

The bits LEDC\_DUTY\_CHn[3:0] are used to dither the duty cycles of the PWM output signal (sig\_outn) by periodically altering the duty cycle of sig\_outn. When LEDC\_DUTY\_CHn[3:0] is set to a non-zero value, then for every 16 cycles of sig\_outn , LEDC\_DUTY\_CHn[3:0] of those cycles will have PWM pulses that are one timer tick longer than the other (16- LEDC\_DUTY\_CHn[3:0]) cycles. For instance, if LEDC\_DUTY\_CHn[18:4] is set to 10 and LEDC\_DUTY\_CHn[3:0] is set to 5, then 5 of 16 cycles will have a PWM pulse with a duty value of 11 and the rest of the 16 cycles will have a PWM pulse with a duty value of 10. The average duty cycle after 16 cycles is 10.3125.

If fields LEDC\_TIMER\_SEL\_CHn , LEDC\_HPOINT\_CHn , LEDC\_DUTY\_CHn[18:4] and LEDC\_SIG\_OUT\_EN\_CHn are reconfigured, LEDC\_PARA\_UP\_CHn must be set to apply the new configuration. This will cause the newly configured values to take effect upon the next overflow of the counter. LEDC\_PARA\_UP\_CHn field will be automatically cleared by hardware.

## 32.3.4 Duty Cycle Fading

The PWM generators can fade the duty cycle of a PWM output signal (i.e. gradually change the duty cycle from one value to another). If Duty Cycle Fading is enabled, the value of Lpointn will be incremented/decremented after a fixed number of counter overflows has occurred. Figure 32.3-4 illustrates Duty Cycle Fading.

Figure 32.3-4. Output Signal Diagram of Fading Duty Cycle

![Image](images/32_Chapter_32_img006_dbf1f1f4.png)

Duty Cycle Fading is configured using the following register fields:

- LEDC\_DUTY\_CHn is used to set the initial value of Lpointn .

- LEDC\_DUTY\_START\_CHn will enable/disable duty cycle fading when set/cleared.
- LEDC\_DUTY\_CYCLE\_CHn sets the number of counter overflow cycles for every Lpointn increment/decrement. In other words, Lpointn will be incremented/decremented after LEDC\_DUTY\_CYCLE\_CHn counter overflows.
- LEDC\_DUTY\_INC\_CHn configures whether Lpointn is incremented/decremented if set/cleared.
- LEDC\_DUTY\_SCALE\_CHn sets the amount that Lpointn is incremented/decremented.
- LEDC\_DUTY\_NUM\_CHn sets the maximum number of increments/decrements before duty cycle fading stops.

If the fields LEDC\_DUTY\_CHn , LEDC\_DUTY\_START\_CHn , LEDC\_DUTY\_CYCLE\_CHn , LEDC\_DUTY\_INC\_CHn , LEDC\_DUTY\_SCALE\_CHn, and LEDC\_DUTY\_NUM\_CHn are reconfigured, LEDC\_PARA\_UP\_CHn must be set to apply the new configuration. After this field is set, the values for duty cycle fading will take effect at once. LEDC\_PARA\_UP\_CHn field will be automatically cleared by hardware.

## 32.3.5 Interrupts

- LEDC\_OVF\_CNT\_CHn\_INT: Triggered when the timer counter overflows for (LEDC\_OVF\_NUM\_CHn + 1) times and the register LEDC\_OVF\_CNT\_EN\_CHn is set to 1.
- LEDC\_DUTY\_CHNG\_END\_CHn\_INT: Triggered when a fade on an LED PWM generator has finished.
- LEDC\_TIMERx\_OVF\_INT: Triggered when an LED PWM timer has reached its maximum counter value.

## 32.4 Register Summary

The addresses in this section are relative to the LED PWM Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                   | Description                            | Address   | Access   |
|------------------------|----------------------------------------|-----------|----------|
| Configuration Register |                                        |           |          |
| LEDC_CH0_CONF0_REG     | Configuration register 0 for channel 0 | 0x0000    | varies   |
| LEDC_CH0_CONF1_REG     | Configuration register 1 for channel 0 | 0x000C    | varies   |
| LEDC_CH1_CONF0_REG     | Configuration register 0 for channel 1 | 0x0014    | varies   |
| LEDC_CH1_CONF1_REG     | Configuration register 1 for channel 1 | 0x0020    | varies   |
| LEDC_CH2_CONF0_REG     | Configuration register 0 for channel 2 | 0x0028    | varies   |
| LEDC_CH2_CONF1_REG     | Configuration register 1 for channel 2 | 0x0034    | varies   |
| LEDC_CH3_CONF0_REG     | Configuration register 0 for channel 3 | 0x003C    | varies   |
| LEDC_CH3_CONF1_REG     | Configuration register 1 for channel 3 | 0x0048    | varies   |
| LEDC_CH4_CONF0_REG     | Configuration register 0 for channel 4 | 0x0050    | varies   |
| LEDC_CH4_CONF1_REG     | Configuration register 1 for channel 4 | 0x005C    | varies   |
| LEDC_CH5_CONF0_REG     | Configuration register 0 for channel 5 | 0x0064    | varies   |
| LEDC_CH5_CONF1_REG     | Configuration register 1 for channel 5 | 0x0070    | varies   |
| LEDC_CONF_REG          | Global LEDC configuration register     | 0x00D0    | R/W      |
| Hpoint Register        |                                        |           |          |
| LEDC_CH0_HPOINT_REG    | High point register for channel 0      | 0x0004    | R/W      |
| LEDC_CH1_HPOINT_REG    | High point register for channel 1      | 0x0018    | R/W      |
| LEDC_CH2_HPOINT_REG    | High point register for channel 2      | 0x002C    | R/W      |
| LEDC_CH3_HPOINT_REG    | High point register for channel 3      | 0x0040    | R/W      |
| LEDC_CH4_HPOINT_REG    | High point register for channel 4      | 0x0054    | R/W      |
| LEDC_CH5_HPOINT_REG    | High point register for channel 5      | 0x0068    | R/W      |
| Duty Cycle Register    |                                        |           |          |
| LEDC_CH0_DUTY_REG      | Initial duty cycle for channel 0       | 0x0008    | R/W      |
| LEDC_CH0_DUTY_R_REG    | Current duty cycle for channel 0       | 0x0010    | RO       |
| LEDC_CH1_DUTY_REG      | Initial duty cycle for channel 1       | 0x001C    | R/W      |
| LEDC_CH1_DUTY_R_REG    | Current duty cycle for channel 1       | 0x0024    | RO       |
| LEDC_CH2_DUTY_REG      | Initial duty cycle for channel 2       | 0x0030    | R/W      |
| LEDC_CH2_DUTY_R_REG    | Current duty cycle for channel 2       | 0x0038    | RO       |
| LEDC_CH3_DUTY_REG      | Initial duty cycle for channel 3       | 0x0044    | R/W      |
| LEDC_CH3_DUTY_R_REG    | Current duty cycle for channel 3       | 0x004C    | RO       |
| LEDC_CH4_DUTY_REG      | Initial duty cycle for channel 4       | 0x0058    | R/W      |
| LEDC_CH4_DUTY_R_REG    | Current duty cycle for channel 4       | 0x0060    | RO       |
| LEDC_CH5_DUTY_REG      | Initial duty cycle for channel 5       | 0x006C    | R/W      |
| LEDC_CH5_DUTY_R_REG    | Current duty cycle for channel 5       | 0x0074    | RO       |
| Timer Register         |                                        |           |          |
| LEDC_TIMER0_CONF_REG   | Timer 0 configuration                  | 0x00A0    | varies   |
| LEDC_TIMER0_VALUE_REG  | Timer 0 current counter value          | 0x00A4    | RO       |

| Name                  | Description                   | Address   | Access   |
|-----------------------|-------------------------------|-----------|----------|
| LEDC_TIMER1_CONF_REG  | Timer 1 configuration         | 0x00A8    | varies   |
| LEDC_TIMER1_VALUE_REG | Timer 1 current counter value | 0x00AC    | RO       |
| LEDC_TIMER2_CONF_REG  | Timer 2 configuration         | 0x00B0    | varies   |
| LEDC_TIMER2_VALUE_REG | Timer 2 current counter value | 0x00B4    | RO       |
| LEDC_TIMER3_CONF_REG  | Timer 3 configuration         | 0x00B8    | varies   |
| LEDC_TIMER3_VALUE_REG | Timer 3 current counter value | 0x00BC    | RO       |
| Interrupt Register    |                               |           |          |
| LEDC_INT_RAW_REG      | Raw interrupt status          | 0x00C0    | R/WTC/SS |
| LEDC_INT_ST_REG       | Masked interrupt status       | 0x00C4    | RO       |
| LEDC_INT_ENA_REG      | Interrupt enable bits         | 0x00C8    | R/W      |
| LEDC_INT_CLR_REG      | Interrupt clear bits          | 0x00CC    | WT       |
| Version Register      |                               |           |          |
| LEDC_DATE_REG         | Version control register      | 0x00FC    | R/W      |

## 32.5 Registers

The addresses in this section are relative to LED PWM Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 32.1. LEDC\_CHn\_CONF0\_REG (n: 0-5) (0x0000+20*n)

![Image](images/32_Chapter_32_img007_262c498f.png)

LEDC\_TIMER\_SEL\_CHn This field is used to select one of the timers for channel n .

0: select Timer0; 1: select Timer1; 2: select Timer2; 3: select Timer3 (R/W)

LEDC\_SIG\_OUT\_EN\_CHn Set this bit to enable signal output on channel n. (R/W)

LEDC\_IDLE\_LV\_CHn This bit is used to control the output value when channel n is inactive (when LEDC\_SIG\_OUT\_EN\_CHn is 0). (R/W)

LEDC\_PARA\_UP\_CHn This bit is used to update the listed fields below for channel n, and will be automatically cleared by hardware. (WT)

- LEDC\_HPOINT\_CHn
- LEDC\_DUTY\_START\_CHn
- LEDC\_SIG\_OUT\_EN\_CHn
- LEDC\_TIMER\_SEL\_CHn
- LEDC\_DUTY\_NUM\_CHn
- LEDC\_DUTY\_CYCLE\_CHn
- LEDC\_DUTY\_SCALE\_CHn
- LEDC\_DUTY\_INC\_CHn
- LEDC\_OVF\_CNT\_EN\_CHn

LEDC\_OVF\_NUM\_CHn This field is used to configure the maximum times of overflow minus 1.

The LEDC\_OVF\_CNT\_CHn\_INT interrupt will be triggered when channel n overflows for (LEDC\_OVF\_NUM\_CHn + 1) times. (R/W)

LEDC\_OVF\_CNT\_EN\_CHn This bit is used to count the number of times when the timer selected by channel n overflows. (R/W)

LEDC\_OVF\_CNT\_RESET\_CHn Set this bit to reset the timer-overflow counter of channel n. (WT)

Register 32.2. LEDC\_CHn\_CONF1\_REG (n: 0-5) (0x000C+20*n)

![Image](images/32_Chapter_32_img008_5d39ea2c.png)

- LEDC\_DUTY\_SCALE\_CHn This field configures the step size of the duty cycle change during fading. (R/W)
- LEDC\_DUTY\_CYCLE\_CHn The duty will change every LEDC\_DUTY\_CYCLE\_CHn cycle on channel n. (R/W)
- LEDC\_DUTY\_NUM\_CHn This field controls the number of times the duty cycle will be changed. (R/W)
- LEDC\_DUTY\_INC\_CHn This bit determines whether the duty cycle of the output signal on channel n increases or decreases. 1: Increase; 0: Decrease. (R/W)
- LEDC\_DUTY\_START\_CHn If this bit is set to 1, other configured fields in LEDC\_CHn\_CONF1\_REG will take effect upon the next timer overflow. (R/W/SC)

Register 32.3. LEDC\_CONF\_REG (0x00D0)

![Image](images/32_Chapter_32_img009_144ca4e9.png)

LEDC\_APB\_CLK\_SEL This field is used to select the common clock source for all the 4 timers.

1: APB\_CLK; 2: RC\_FAST\_CLK; 3: XTAL\_CLK. (R/W)

LEDC\_CLK\_EN This bit is used to control the clock.

- 1: Force clock on for register. 0: Support clock only when application writes registers. (R/W)

Register 32.4. LEDC\_CHn\_HPOINT\_REG (n: 0-5) (0x0004+20*n)

![Image](images/32_Chapter_32_img010_f35ba109.png)

LEDC\_HPOINT\_CHn The output value changes to high when the selected timer for this channel has reached the value specified by this field. (R/W)

Register 32.5. LEDC\_CHn\_DUTY\_REG (n: 0-5) (0x0008+20*n)

![Image](images/32_Chapter_32_img011_9b22a6f1.png)

LEDC\_DUTY\_CHn This field is used to change the output duty by controlling the Lpoint. The output value turns to low when the selected timer for this channel has reached the Lpoint. (R/W)

Register 32.6. LEDC\_CHn\_DUTY\_R\_REG (n: 0-5) (0x0010+20*n)

![Image](images/32_Chapter_32_img012_533d465a.png)

LEDC\_DUTY\_R\_CHn This field stores the current duty cycle of the output signal on channel n. (RO)

Register 32.7. LEDC\_TIMERx\_CONF\_REG (x: 0-3) (0x00A0+8*x)

![Image](images/32_Chapter_32_img013_9fcb4b6a.png)

LEDC\_TIMERx\_DUTY\_RES This field is used to control the range of the counter in timer x. (R/W)

LEDC\_CLK\_DIV\_TIMERx This field is used to configure the divisor for the divider in timer x. The least significant eight bits represent the fractional part. (R/W)

LEDC\_TIMERx\_PAUSE This bit is used to suspend the counter in timer x. (R/W)

LEDC\_TIMERx\_RST This bit is used to reset timer x. The counter will show 0 after reset. (R/W)

LEDC\_TIMERx\_PARA\_UP Set this bit to update LEDC\_CLK\_DIV\_TIMERx and LEDC\_TIMERx\_DUTY\_RES. (WT)

Register 32.8. LEDC\_TIMERx\_VALUE\_REG (x: 0-3) (0x00A4+8*x)

![Image](images/32_Chapter_32_img014_efc6b948.png)

LEDC\_TIMERx\_CNT This field stores the current counter value of timer x. (RO)

Register 32.9. LEDC\_INT\_RAW\_REG (0x00C0)

![Image](images/32_Chapter_32_img015_ce461bdb.png)

LEDC\_TIMERx\_OVF\_INT\_RAW Triggered when the timerx has reached its maximum counter value. (R/WTC/SS)

LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_RAW Interrupt raw bit for channel n. Triggered when the gradual change of duty has finished. (R/WTC/SS)

LEDC\_OVF\_CNT\_CHn\_INT\_RAW Interrupt raw bit for channel n. Triggered when the ovf\_cnt has reached the value specified by LEDC\_OVF\_NUM\_CHn. (R/WTC/SS)

## Register 32.10. LEDC\_INT\_ST\_REG (0x00C4)

![Image](images/32_Chapter_32_img016_19a93654.png)

LEDC\_TIMERx\_OVF\_INT\_ST This is the masked interrupt status bit for the LEDC\_TIMERx\_OVF\_INT interrupt when LEDC\_TIMERx\_OVF\_INT\_ENA is set to 1. (RO)

LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_ST This is the masked interrupt status bit for the LEDC\_DUTY\_CHNG\_END\_CHn\_INT interrupt when LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_ENA is set to 1. (RO)

LEDC\_OVF\_CNT\_CHn\_INT\_ST This is the masked interrupt status bit for the LEDC\_OVF\_CNT\_CHn\_INT interrupt when LEDC\_OVF\_CNT\_CHn\_INT\_ENA is set to 1. (RO)

## Register 32.11. LEDC\_INT\_ENA\_REG (0x00C8)

![Image](images/32_Chapter_32_img017_a942f87a.png)

LEDC\_TIMERx\_OVF\_INT\_ENA The interrupt enable bit for the LEDC\_TIMERx\_OVF\_INT interrupt.

(R/W) LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_ENA The interrupt enable bit for the LEDC\_DUTY\_CHNG\_END\_CHn\_INT interrupt. (R/W) LEDC\_OVF\_CNT\_CHn\_INT\_ENA The interrupt enable bit for the LEDC\_OVF\_CNT\_CHn\_INT interrupt.

(R/W)

## Register 32.12. LEDC\_INT\_CLR\_REG (0x00CC)

![Image](images/32_Chapter_32_img018_9040beac.png)

LEDC\_TIMERx\_OVF\_INT\_CLR Set this bit to clear the LEDC\_TIMERx\_OVF\_INT interrupt. (WT) LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_CLR Set this bit to clear the LEDC\_DUTY\_CHNG\_END\_CHn\_INT interrupt. (WT)

LEDC\_OVF\_CNT\_CHn\_INT\_CLR Set this bit to clear the LEDC\_OVF\_CNT\_CHn\_INT interrupt. (WT)

## Register 32.13. LEDC\_DATE\_REG (0x00FC)

![Image](images/32_Chapter_32_img019_d07bda25.png)

![Image](images/32_Chapter_32_img020_9b91377f.png)

LEDC\_LEDC\_DATE This is the version control register. (R/W)
