---
chapter: 35
title: "Chapter 35"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 35

## LED PWM Controller (LEDC)

## 35.1 Overview

The LED PWM Controller is a peripheral designed to generate PWM signals for LED control. It has specialized features such as automatic duty cycle fading. However, the LED PWM Controller can also be used to generate PWM signals for other purposes.

## 35.2 Features

The LED PWM Controller has the following features:

- Six independent PWM generators (i.e. six channels)
- Maximum PWM duty cycle resolution: 20 bits
- Four independent timers that support fractional division
- Adjustable phase of PWM signal output
- PWM duty cycle dithering
- Automatic duty cycle fading — gradual increase/decrease of a PWM's duty cycle without interference from the processor. An interrupt will be generated upon fade completion
- Up to 16 duty cycle ranges for each PWM generator to generate gamma curve signals - each range can be independently configured in terms of fading direction (increase or decrease), fading amount (the amount by which the duty cycle increases or decreases each time), the number of fades (how many times the duty cycle fades in one range), and fading frequency
- PWM signal output in low-power mode (Light-sleep mode)
- Event generation and task response related to the Event Task Matrix (ETM) peripheral

Note that the four timers are identical regarding their features and operation. The following sections refer to the timers collectively as Timerx (where x ranges from 0 to 3). Likewise, the six PWM generators are also identical in features and operation, and thus are collectively referred to as PWMn (where n ranges from 0 to 5).

Figure 35.2-1. LED PWM Architecture

![Image](images/35_Chapter_35_img001_dbfcc144.png)

## 35.3 Functional Description

## 35.3.1 Architecture

Figure 35.2-1 shows the architecture of the LED PWM Controller.

Each of the four timers has an internal timebase counter (i.e. a counter that counts on cycles of a reference clock) and thus can be independently configured (i.e. configurable clock divider, and counter overflow value). Each PWM generator selects one of the timers by configuring the LEDC\_TIMER\_SEL\_CHn, and uses the timer's counter value timerx\_cnt as a reference to generate its PWM signal.

Figure 35.3-1 illustrates the main functional blocks of the timer and the PWM generator.

Figure 35.3-1. Timer and PWM Generator Block Diagram

![Image](images/35_Chapter_35_img002_5c657ee0.png)

## 35.3.2 Timers

Each timer in LED PWM Controller internally maintains a timebase counter. Referring to Figure 35.3-1, this clock signal used by the timebase counter is named ref\_pulsex. All timers use the same clock source LEDC\_CLKx , which is then passed through a clock divider to generate ref\_pulsex for the counter.

## 35.3.2.1 Clock Source

LED PWM registers configured by software are clocked by APB\_CLK. To use the LED PWM peripheral, the APB\_CLK signal going to the LED PWM has to be enabled. The APB\_CLK signal to LED PWM can be enabled by setting the PCR\_LEDC\_CLK\_EN field in the PCR\_LEDC\_CONF\_REG register, and reset via software by setting the PCR\_LEDC\_RST\_EN field in the PCR\_LEDC\_CONF\_REG register.

Timers in the LED PWM Controller choose their common clock source from one of the following clock signals: PLL\_F80M\_CLK, RC\_FAST\_CLK, and XTAL\_CLK. The procedure for selecting a clock source signal for LEDC\_CLKx is described below:

- PLL\_F80M\_CLK: Set LEDC\_SCLK\_SEL[1:0] to 1
- RC\_FAST\_CLK: Set LEDC\_SCLK\_SEL[1:0] to 2
- XTAL\_CLK: Set LEDC\_SCLK\_SEL[1:0] to 3

The LEDC\_CLKx signal will then be passed through the clock divider.

For more information, please refer to Chapter 8 Reset and Clock .

## 35.3.2.2 Clock Divider Configuration

The LEDC\_CLKx signal is passed through a clock divider to generate the ref\_pulsex signal for the counter. The frequency of ref\_pulsex is equal to the frequency of LEDC\_CLKx divided by the divisor LEDC\_CLK\_DIV (see Figure 35.3-1).

The clock divider is a fractional divider. Thus, the divisor LEDC\_CLK\_DIV can be non-integer values. LEDC\_CLK\_DIV is configured according to the following equation.

<!-- formula-not-decoded -->

- The integer part A corresponds to the most significant 10 bits of LEDC\_CLK\_DIV\_TIMERx (i.e. LEDC\_TIMERx\_CONF\_REG[22:13])
- The fractional part B corresponds to the least significant 8 bits of LEDC\_CLK\_DIV\_TIMERx (i.e. LEDC\_TIMERx\_CONF\_REG[12:5])

When the fractional part B is 0, LEDC\_CLK\_DIV is equivalent to an integer divisor (i.e. an integer prescaler). In other words, a ref\_pulsex clock pulse is generated after every A number of LEDC\_CLKx clock pulses.

However, when B is not 0, LEDC\_CLK\_DIV becomes a non-integer divisor. The clock divider implements non-integer frequency division by alternating between A and (A+1) LEDC\_CLKx clock pulses per ref\_pulsex clock pulse. In this way, the average frequency of ref\_pulsex clock pulse will be the desired frequency (i.e. the non-integer divided frequency). For every 256 ref\_pulsex clock pulses:

- A number of B ref\_pulsex clock pulses are generated every (A+1) LEDC\_CLKx clock pulses
- A number of (256-B) ref\_pulsex clock pulses are generated every A LEDC\_CLKx clock pulses

- The ref\_pulsex clock pulses generated every (A+1) pulses are evenly distributed amongst those generated every A pulses

Figure 35.3-2 illustrates the relation between LEDC\_CLKx clock pulses and ref\_pulsex clock pulses when LEDC\_CLK\_DIV is a non-integer value.

Figure 35.3-2. Frequency Division When LEDC\_CLK\_DIV is a Non-Integer Value

![Image](images/35_Chapter_35_img003_d472fde6.png)

To change the timer's clock divisor at runtime, first configure the LEDC\_CLK\_DIV\_TIMERx field, and then set the LEDC\_TIMERx\_PARA\_UP field to apply the new configuration. This will cause the newly configured values to take effect upon the next overflow of the counter. The LEDC\_TIMERx\_PARA\_UP field will be automatically cleared by hardware.

## 35.3.2.3 20-Bit Counter

Each timer contains a 20-bit timebase counter that uses ref\_pulsex as its reference clock (see Figure 35.3-1). The LEDC\_TIMERx\_DUTY\_RES field configures the overflow value of this 20-bit counter. Hence, the maximum resolution of the PWM signal is 20 bits. The counter counts up to 2 LEDC\_TIMERx\_DUTY\_RES − 1, overflows and begins counting from 0 again. The counter's value can be read, reset, and suspended by software. Figure 35.3-3 shows the relationship between the counter and PWM resolution.

Figure 35.3-3. Relationship Between Counter And Resolution

![Image](images/35_Chapter_35_img004_83338b36.png)

Every time the counter overflows, it can trigger the LEDC\_TIMERx\_OVF\_INT interrupt (generated automatically by hardware without configuration). It can also be configured to trigger LEDC\_OVF\_CNT\_CHn\_INT interrupt after overflowing LEDC\_OVF\_NUM\_CHn + 1 times. To configure LEDC\_OVF\_CNT\_CHn\_INT interrupt, please:

1. Configure LEDC\_TIMER\_SEL\_CHn to select the timer for the PWM generator
2. Enable the overflow counter by setting LEDC\_OVF\_CNT\_EN\_CHn
3. Configure LEDC\_OVF\_NUM\_CHn with the number of counter overflows (that triggers an interrupt) minus 1
4. Enable the overflow interrupt by setting LEDC\_OVF\_CNT\_CHn\_INT\_ENA

5. Set LEDC\_TIMERx\_DUTY\_RES to enable the timer and wait for a LEDC\_OVF\_CNT\_CHn\_INT interrupt

To change the overflow value at runtime, first set the LEDC\_TIMERx\_DUTY\_RES field, and then set the LEDC\_TIMERx\_PARA\_UP field. This will cause the newly configured values to take effect upon the next overflow of the counter. If LEDC\_OVF\_CNT\_EN\_CHn field is reconfigured, LEDC\_PARA\_UP\_CHn should be set to apply the new configuration. In summary, these configuration values need to be updated by setting LEDC\_TIMERx\_PARA\_UP or LEDC\_PARA\_UP\_CHn . LEDC\_TIMERx\_PARA\_UP and LEDC\_PARA\_UP\_CHn will be automatically cleared by hardware.

Referring to Figure 35.3-1, the frequency of a PWM generator output signal (sig\_outn) is dependent on the frequency of the timer's clock source LEDC\_CLKx, the clock divisor LEDC\_CLK\_DIV, and the duty resolution (counter width) LEDC\_TIMERx\_DUTY\_RES:

<!-- formula-not-decoded -->

Based on the formula above, the desired duty resolution can be calculated as follows:

<!-- formula-not-decoded -->

Table 35.3-1 lists the commonly-used frequencies and their corresponding resolutions.

Table 35.3-1. Commonly-used Frequencies and Resolutions

| LEDC_CLKx              | PWM Frequency   |   Highest Resolution (bit)  1 |   Lowest Resolution (bit)  2 |
|------------------------|-----------------|-------------------------------|------------------------------|
| PLL_F80M_CLK (80 MHz)  | 1 kHz           |                            16 |                            7 |
| PLL_F80M_CLK (80 MHz)  | 5 kHz           |                            13 |                            4 |
| PLL_F80M_CLK (80 MHz)  | 10 kHz          |                            12 |                            3 |
| XTAL_CLK (40 MHz)      | 1 kHz           |                            15 |                            6 |
| XTAL_CLK (40 MHz)      | 4 kHz           |                            13 |                            4 |
| RC_FAST_CLK (17.5 MHz) | 1 kHz           |                            14 |                            5 |
| RC_FAST_CLK (17.5 MHz) | 2 kHz           |                            13 |                            4 |

## 35.3.3 PWM Generators

To generate a PWM signal, a PWM generator (PWMn) needs a timer (Timerx). Each PWM generator can be configured separately by setting LEDC\_TIMER\_SEL\_CHn to use one of four timers to generate the PWM output.

As shown in Figure 35.3-1, each PWM generator has a comparator and two multiplexers. A PWM generator compares the timer's 20-bit counter value (Timerx\_cnt) to two trigger values Hpointn and Lpointn. When the timer's counter value is equal to Hpointn or Lpointn, the PWM signal is high or low, respectively, as described below:

- If Timerx\_cnt == Hpointn, sig\_outn is 1.
- If Timerx\_cnt == Lpointn, sig\_outn is 0.

Figure 35.3-4 illustrates how Hpointn and Lpointn are used to generate a fixed duty cycle PWM output signal.

For a particular PWM generator (PWMn), its Hpointn is sampled from the LEDC\_HPOINT\_CHn field each time the selected timer's counter overflows. Likewise, Lpointn is also sampled on every counter overflow and is calculated from the sum of the LEDC\_DUTY\_CHn[24:4] and LEDC\_HPOINT\_CHn fields. By setting Hpointn and Lpointn via the LEDC\_HPOINT\_CHn and LEDC\_DUTY\_CHn[24:4] fields, the relative phase and duty cycle of the PWM output can be set.

The PWM output signal (sig\_outn) is enabled by setting LEDC\_SIG\_OUT\_EN\_CHn. When LEDC\_SIG\_OUT\_EN\_CHn is cleared, PWM signal output is disabled, and the output signal (sig\_outn) will output a constant level specified by LEDC\_IDLE\_LV\_CHn .

Figure 35.3-4. LED PWM Output Signal Diagram

![Image](images/35_Chapter_35_img005_24444f3f.png)

The bits LEDC\_DUTY\_CHn[3:0] are used to dither the duty cycles of the PWM output signal (sig\_outn) by periodically altering the duty cycle of sig\_outn. When LEDC\_DUTY\_CHn[3:0] is not 0, then for every 16 cycles of sig\_outn , LEDC\_DUTY\_CHn[3:0] of those cycles will have PWM pulses that are one timer tick longer than the other (16- LEDC\_DUTY\_CHn[3:0]) cycles. For instance, if LEDC\_DUTY\_CHn[24:4] is set to 10 and LEDC\_DUTY\_CHn[3:0] is set to 5, then 5 of 16 cycles will have a PWM pulse with a duty value of 11 and the rest of the 16 cycles will have a PWM pulse with a duty value of 10. The average duty cycle after 16 cycles is 10.3125.

If fields LEDC\_TIMER\_SEL\_CHn , LEDC\_HPOINT\_CHn , LEDC\_DUTY\_CHn[24:4], and LEDC\_SIG\_OUT\_EN\_CHn are reconfigured, LEDC\_PARA\_UP\_CHn must be set to apply the new configuration. This will cause the newly configured values to take effect upon the next overflow of the counter. LEDC\_PARA\_UP\_CHn field will be automatically cleared by hardware.

## 35.3.4 Duty Cycle Fading

The PWM generators can fade the duty cycle of a PWM output signal (i.e. gradually change the duty cycle from one value to another). Each PWM generator can have up to 16 duty cycle ranges, which can be independently configured in terms of fading direction (increase or decrease), fading amount, the number of fades, and fading frequency. If Duty Cycle Fading is enabled, every range's Lpointn value will change according to its fading configuration.

## 35.3.4.1 Linear Duty Cycle Fading

Linear fading PWM signals can be generated by configuring the direction, fading amount, the number of fades, and fading frequency of the first duty cycle range.

Below are the programming procedures:

1. Configure the LEDC\_DUTY\_CHn field with the initial value of Lpointn .
2. Set the LEDC\_DUTY\_START\_CHn field to enable Duty Cycle Fading. When this field is cleared, Duty Cycle Fading will be disabled.
3. Configure the direction via the LEDC\_CHn\_GAMMA\_DUTY\_INC field of the LEDC\_CHn\_GAMMA\_WR\_REG register. When this field is set or cleared, the Lpointn will increment or decrement in the current configured range.

4. Configure the number of times the counter overflows per an increase or decrease of Lpointn via the LEDC\_CHn\_GAMMA\_DUTY\_CYCLE field of the LEDC\_CHn\_GAMMA\_WR\_REG register. In other words, Lpointn will increase or decrease after the counter overflows for LEDC\_CHn\_GAMMA\_DUTY\_CYCLE times.
5. Configure the amount by which Lpointn increase or decrease in the configured range via the LEDC\_CHn\_GAMMA\_SCALE field of the LEDC\_CHn\_GAMMA\_WR\_REG register.
6. Configure the number of fades via the LEDC\_CHn\_GAMMA\_DUTY\_NUM field of the LEDC\_CHn\_GAMMA\_WR\_REG register.
7. Write the duty cycle range number (0 in this case) to the LEDC\_CHn\_GAMMA\_WR\_ADDR field of the LEDC\_CHn\_GAMMA\_WR\_ADDR\_REG register. This range number (from 0 to 15) specifies to which range the configurations in Step 3, 4, 5, and 6 apply. For linear duty cycle fading only the first range needs to be configured, so configure LEDC\_CHn\_GAMMA\_WR\_ADDR as 0.
8. Configure the number of ranges per each fading (1 in this case) via the LEDC\_CHn\_GAMMA\_ENTRY\_NUM field of the LEDC\_CHn\_GAMMA\_CONF\_REG. Once the specified number of ranges have been faded, Duty Cycle Fading stops and the PWM generator triggers the LEDC\_DUTY\_CHNG\_END\_CHn\_INT interrupt. For linear duty cycle fading there is only one duty cycle range (i.e. the first one), so configure LEDC\_CHn\_GAMMA\_ENTRY\_NUM as 1.
9. Set the LEDC\_PARA\_UP\_CHn field to apply the above configurations. After this field is set, the configurations for Duty Cycle Fading will take effect upon the next overflow of the counter, and the PWM generator will output a linear fading PWM signal following configurations. LEDC\_PARA\_UP\_CHn field will be automatically cleared by hardware.

After the above procedures, the PWM generator can fade the duty cycle of a PWM signal once per LEDC\_CHn\_GAMMA\_DUTY\_CYCLE times of counter overflows. Every time when the PWM signal is faded, Lpointn increases or decreases (configured by LEDC\_CHn\_GAMMA\_DUTY\_INC) by LEDC\_CHn\_GAMMA\_SCALE, and the duty cycle increases or decreases (configured by LEDC\_CHn\_GAMMA\_DUTY\_INC) by

## LEDC\_CHn\_GAMMA\_SCALE LEDC\_TIMERx\_DUTY\_RES

The duty cycle is faded for LEDC\_CHn\_GAMMA\_DUTY\_NUM times. After that, the PWM generator stops fading and keeps outputting signals at this duty cycle. Upon each fading the duty cycle increases or decreases by the same amount, and therefore the PWM signal is a linear fading signal.

Figure 35.3-5 shows a linear fading PWM signal.

## 35.3.4.2 Gamma Curve Fading

Gamma curve fading PWM signals can be generated by configuring the fading direction, fading amount, the number of fades and fading frequency of multiple duty cycle fading ranges.

Below are the programming procedures:

1. The same as Step 1 in Section 35.3.4.1 .
2. The same as Step 2 in Section 35.3.4.1 .
3. Configure multiple duty cycle ranges:

Figure 35.3-5. Output Signal of Linear Duty Cycle Fading

![Image](images/35_Chapter_35_img006_d603a0d4.png)

- (a) Configure the LEDC\_CHn\_GAMMA\_DUTY\_INC field of the LEDC\_CHn\_GAMMA\_WR\_REG register for the currently configured range.
- (b) Configure the LEDC\_CHn\_GAMMA\_DUTY\_CYCLE field of the LEDC\_CHn\_GAMMA\_WR\_REG register for the currently configured range.
- (c) Configure the LEDC\_CHn\_GAMMA\_SCALE field of the LEDC\_CHn\_GAMMA\_WR\_REG register for the currently configured range.
- (d) Configure the LEDC\_CHn\_GAMMA\_DUTY\_NUM field of the LEDC\_CHn\_GAMMA\_WR\_REG register for the currently configured range.
- (e) Write the duty cycle range number (from 0 to 15) to the LEDC\_CHn\_GAMMA\_WR\_ADDR field of the LEDC\_CHn\_GAMMA\_WR\_ADDR\_REG register. This range number specifies to which range the above configurations apply. It must start from 0 and increase by 1 for the next range to be configured.
- (f) Once the above procedures are finished, the configuration for one range is complete. Other ranges are configured by repeating the same set of procedures. You can configure any number of ranges from 0 to 16, and each can be configured independently.
4. After all required ranges are configured, write the total number of ranges configured in Step 3 to the LEDC\_CHn\_GAMMA\_ENTRY\_NUM field of the LEDC\_CHn\_GAMMA\_CONF\_REG register.
5. Set the LEDC\_PARA\_UP\_CHn field to apply the above configuration. After this field is set, the configurations for duty cycle fading will take effect upon the next overflow of the counter, and the PWM generator will output a gamma curve fading PWM signal following the configurations. LEDC\_PARA\_UP\_CHn field will be automatically cleared by hardware.

After the above procedures, the PWM generator can generate a PWM signal with LEDC\_CHn\_GAMMA\_ENTRY\_NUM ranges. The duty cycle of the PWM signal fades according to the configurations of range 0 first, and then range 1, till range (LEDC\_CHn\_GAMMA\_ENTRY\_NUM − 1) (the last

range) where Duty Cycle Fading ends. The PWM signal fades independently in each range. In range LEDC\_CHn\_GAMMA\_WR\_ADDR, every time when the counter overflows for LEDC\_CHn\_GAMMA\_DUTY\_CYCLE times, Lpointn increases or decreases (configured by LEDC\_CHn\_GAMMA\_DUTY\_INC) by LEDC\_CHn\_GAMMA\_SCALE, and accordingly the duty cycle increases or decreases (configured by LEDC\_CHn\_GAMMA\_DUTY\_INC) by

<!-- formula-not-decoded -->

After the duty cycle fades for LEDC\_CHn\_GAMMA\_DUTY\_NUM times in a range, Duty Cycle Fading in this range finishes.

When Duty Cycle Fading finishes in all ranges (the number of ranges is specified by LEDC\_CHn\_GAMMA\_ENTRY\_NUM), the PWM signal stops fading and keeps the duty cycle of the last fade. Given that the duty cycle fades differently and linearly in each range, several linear fading ranges would be fitted to a gamma curve.

Figure 35.3-6 illustrates a gamma curve fading PWM signal.

Figure 35.3-6. Output Signal of Gamma Curve Fading

![Image](images/35_Chapter_35_img007_234b5d8b.png)

## 35.3.4.3 Suspend and Resume Duty Cycle Fading

To suspend Duty Cycle Fading that has already been started, write 1 to the LEDC\_CHn\_GAMMA\_PAUSE field of the LEDC\_CHn\_GAMMA\_CONF\_REG register. Once LEDC\_CHn\_GAMMA\_PAUSE is set to 1, the PWM signal keeps the duty cycle of the most recent fade.

To resume Duty Cycle Fading, write 1 to the LEDC\_CHn\_GAMMA\_RESUME field of the LEDC\_CHn\_GAMMA\_CONF\_REG register. Once LEDC\_CHn\_GAMMA\_RESUME is set to 1, the PWM signal resumes fading from the range where the suspension occurs, until fading in the last range finishes. The fading will continue from the state when it was paused until all the ranges complete duty cycle fading (when LEDC\_CHn\_GAMMA\_RESUME is set to 1, LEDC\_CHn\_GAMMA\_PAUSE is cleared automatically by hardware.

## 35.3.5 Event Task Matrix Feature

The LEDC on ESP32-C6 supports the Event Task Matrix (ETM) function, which allows LEDC's ETM tasks to be triggered by any peripherals' ETM events, or LEDC's ETM events to trigger any peripherals' ETM tasks. This section introduces the ETM tasks and events related to LEDC. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

ETM-related events and tasks are enabled by configuring corresponding fields of LEDC\_EVT\_TASK\_EN0\_REG , LEDC\_EVT\_TASK\_EN1\_REG and LEDC\_EVT\_TASK\_EN2\_REG registers. For the correspondence between events, tasks, and fields, Please refer to Section 35.5).

LEDC can receive the following ETM tasks:

- LEDC\_TASK\_DUTY\_SCALE\_UPDATE\_CHn: If the LEDC\_TASK\_DUTY\_SCALE\_UPDATE\_CHn\_EN field is enabled, upon receiving the LEDC\_TASK\_DUTY\_SCALE\_UPDATE\_CHn task, PWMn generates fading PWM signals according to the newly configured LEDC\_CHn\_GAMMA\_SCALE field.
- LEDC\_TASK\_TIMERx\_RES\_UPDATE: If the LEDC\_TASK\_TIMERx\_RES\_UPDATE\_EN field is enabled, upon receiving the LEDC\_TASK\_TIMERx\_RES\_UPDATE task, Timerx updates its counter's overflow value to the value configured in the LEDC\_TIMERx\_DUTY\_RES field at the next overflow of the counter.
- LEDC\_TASK\_TIMERx\_CAP: If the LEDC\_TASK\_TIMERx\_CAP\_EN field is enabled, upon receiving the LEDC\_TASK\_TIMERx\_CAP task, Timerx captures its counter's value, and stores the value into the LEDC\_TIMERx\_CNT\_CAP field of register LEDC\_TIMERx\_CNT\_CAP\_REG .
- LEDC\_TASK\_SIG\_OUT\_DIS\_CHn: If the LEDC\_TASK\_SIG\_OUT\_DIS\_CHn\_EN field is enabled, upon receiving the LEDC\_TASK\_SIG\_OUT\_DIS\_CHn task, PWMn's signal output is disabled, and the output signal (sig\_outn) outputs a constant level as specified by field LEDC\_IDLE\_LV\_CHn, as shown in Figure 35.3-1 .
- LEDC\_TASK\_OVF\_CNT\_RST\_CHn: If the LEDC\_TASK\_OVF\_CNT\_RST\_CHn\_EN field is enabled, upon receiving the LEDC\_TASK\_OVF\_CNT\_RST\_CHn task, PWMn timer's overflow counter is reset to 0.
- LEDC\_TASK\_TIMERx\_RST: If the LEDC\_TASK\_TIMERx\_RST\_EN field is enabled, upon receiving the LEDC\_TASK\_TIMERx\_RST task, Timerx's counter is reset to 0.
- LEDC\_TASK\_TIMERx\_RESUME and LEDC\_TASK\_TIMERx\_PAUSE: If the LEDC\_TASK\_TIMERx\_PAUSE\_RESUME\_EN field is enabled, upon receiving the LEDC\_TASK\_TIMERx\_RESUME and LEDC\_TASK\_TIMERx\_PAUSE task, Timerx is suspended and resumed alternately. That is, when the task is received, Timerx is paused; and when the task is received again, Timerx is resumed.
- LEDC\_TASK\_GAMMA\_RESTART\_CHn: If the LEDC\_TASK\_GAMMA\_RESTART\_CHn\_EN field is enabled, upon receiving the LEDC\_TASK\_GAMMA\_RESTART\_CHn task, the PWMn restarts to generate the fading PWM signal.
- LEDC\_TASK\_GAMMA\_PAUSE\_CHn: If the LEDC\_TASK\_GAMMA\_PAUSE\_CHn\_EN field is enabled, upon receiving the LEDC\_TASK\_GAMMA\_PAUSE\_CHn task, PWMn suspends Duty Cycle Fading at the next timer overflow. That is, after the task has been received, PWMn keeps the duty cycle of the last fade.
- LEDC\_TASK\_GAMMA\_RESUME\_CHn: If the LEDC\_TASK\_GAMMA\_RESUME\_CHn\_EN field is enabled, upon receiving the LEDC\_TASK\_GAMMA\_RESUME\_CHn task, PWMn resumes Duty Cycle Fading at the

![Image](images/35_Chapter_35_img008_a08a411f.png)

next counter overflow. That is, after the task has been received, PWMn resumes fading from the range where the suspension occurs.

LEDC can generate the following ETM events:

- LEDC\_EVT\_DUTY\_CHNG\_END\_CHn: Generated when the LEDC\_EVT\_DUTY\_CHNG\_END\_CHn\_EN field is enabled, and PWMn has finished Duty Cycle Fading.
- LEDC\_EVT\_OVF\_CNT\_PLS\_CHn: Generated when the LEDC\_EVT\_OVF\_CNT\_PLS\_CHn\_EN field is enabled and when PWMn timer's counter overflows for LEDC\_OVF\_NUM\_CHn + 1 times.
- LEDC\_EVT\_TIME\_OVF\_TIMERx: Generated when the LEDC\_EVT\_TIME\_OVF\_TIMERx\_EN field is enabled and Timerx's counter overflows.
- LEDC\_EVT\_TIMERx\_CMP: Generated when the LEDC\_EVT\_TIMEx\_CMP\_EN field is enabled and the value of Timerx)'s counter reaches that of the LEDC\_TIMERx\_CMP field of register LEDC\_TIMERx\_CMP\_REG .

In practical applications, LEDC's ETM events can trigger its own ETM tasks. For example, LEDC\_EVT\_DUTY\_CHNG\_END\_CHn event can trigger the LEDC\_TASK\_GAMMA\_RESTART\_CHn task, thus starting the next fading directly after the current fading is completed.

## 35.3.6 Interrupts

- LEDC\_OVF\_CNT\_CHn\_INT: Triggered when the timer counter overflows for LEDC\_OVF\_NUM\_CHn + 1 times and the register LEDC\_OVF\_CNT\_EN\_CHn is set to 1. To trigger this interrupt, the field LEDC\_OVF\_CNT\_CHn\_INT\_ENA of register LEDC\_INT\_ENA\_REG should be set.
- LEDC\_DUTY\_CHNG\_END\_CHn\_INT: Triggered when a fade on an LED PWM generator has finished. To trigger this interrupt, the field LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_ENA of register LEDC\_INT\_ENA\_REG should be set.
- LEDC\_TIMERx\_OVF\_INT: Triggered when an LED PWM timer has reached its maximum counter value. To trigger this interrupt, the field LEDC\_TIMERx\_OVF\_INT\_ENA of register LEDC\_INT\_ENA\_REG should be set.

## 35.4 Register Summary

The addresses in this section are relative to the LED PWM Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                    | Description                                 | Address   | Access   |
|-------------------------|---------------------------------------------|-----------|----------|
| Configuration Register  |                                             |           |          |
| LEDC_CH0_CONF0_REG      | Configuration register 0 for channel 0      | 0x0000    | varies   |
| LEDC_CH0_CONF1_REG      | Configuration register 1 for channel 0      | 0x000C    | R/W/SC   |
| LEDC_CH1_CONF0_REG      | Configuration register 0 for channel 1      | 0x0014    | varies   |
| LEDC_CH1_CONF1_REG      | Configuration register 1 for channel 1      | 0x0020    | R/W/SC   |
| LEDC_CH2_CONF0_REG      | Configuration register 0 for channel 2      | 0x0028    | varies   |
| LEDC_CH2_CONF1_REG      | Configuration register 1 for channel 2      | 0x0034    | R/W/SC   |
| LEDC_CH3_CONF0_REG      | Configuration register 0 for channel 3      | 0x003C    | varies   |
| LEDC_CH3_CONF1_REG      | Configuration register 1 for channel 3      | 0x0048    | R/W/SC   |
| LEDC_CH4_CONF0_REG      | Configuration register 0 for channel 4      | 0x0050    | varies   |
| LEDC_CH4_CONF1_REG      | Configuration register 1 for channel 4      | 0x005C    | R/W/SC   |
| LEDC_CH5_CONF0_REG      | Configuration register 0 for channel 5      | 0x0064    | varies   |
| LEDC_CH5_CONF1_REG      | Configuration register 1 for channel 5      | 0x0070    | R/W/SC   |
| LEDC_EVT_TASK_EN0_REG   | LEDC event task enable register 0           | 0x01A0    | R/W      |
| LEDC_EVT_TASK_EN1_REG   | LEDC event task enable register 1           | 0x01A4    | R/W      |
| LEDC_EVT_TASK_EN2_REG   | LEDC event task enable register 2           | 0x01A8    | R/W      |
| LEDC_TIMER0_CMP_REG     | LEDC timer 0 value comparison register      | 0x01B0    | R/W      |
| LEDC_TIMER1_CMP_REG     | LEDC timer 1 value comparison register      | 0x01B4    | R/W      |
| LEDC_TIMER2_CMP_REG     | LEDC timer 2 value comparison register      | 0x01B8    | R/W      |
| LEDC_TIMER3_CMP_REG     | LEDC timer 3 value comparison register      | 0x01BC    | R/W      |
| LEDC_TIMER0_CNT_CAP_REG | LEDC timer 0 counter value capture register | 0x01C0    | RO       |
| LEDC_TIMER1_CNT_CAP_REG | LEDC timer 1 counter value capture register | 0x01C4    | RO       |
| LEDC_TIMER2_CNT_CAP_REG | LEDC timer 2 counter value capture register | 0x01C8    | RO       |
| LEDC_TIMER3_CNT_CAP_REG | LEDC timer 3 counter value capture register | 0x01CC    | RO       |
| LEDC_CONF_REG           | Global LEDC configuration register          | 0x01F0    | R/W      |
| Hpoint Register         |                                             |           |          |
| LEDC_CH0_HPOINT_REG     | High point register for channel 0           | 0x0004    | R/W      |
| LEDC_CH1_HPOINT_REG     | High point register for channel 1           | 0x0018    | R/W      |
| LEDC_CH2_HPOINT_REG     | High point register for channel 2           | 0x002C    | R/W      |
| LEDC_CH3_HPOINT_REG     | High point register for channel 3           | 0x0040    | R/W      |
| LEDC_CH4_HPOINT_REG     | High point register for channel 4           | 0x0054    | R/W      |
| LEDC_CH5_HPOINT_REG     | High point register for channel 5           | 0x0068    | R/W      |
| Duty Cycle Register     |                                             |           |          |
| LEDC_CH0_DUTY_REG       | Initial duty cycle for channel 0            | 0x0008    | R/W      |
| LEDC_CH0_DUTY_R_REG     | Current duty cycle for channel 0            | 0x0010    | RO       |
| LEDC_CH1_DUTY_REG       | Initial duty cycle for channel 1            | 0x001C    | R/W      |
| LEDC_CH1_DUTY_R_REG     | Current duty cycle for channel 1            | 0x0024    | RO       |

| Name                       | Description                                     | Address   | Access   |
|----------------------------|-------------------------------------------------|-----------|----------|
| LEDC_CH2_DUTY_REG          | Initial duty cycle for channel 2                | 0x0030    | R/W      |
| LEDC_CH2_DUTY_R_REG        | Current duty cycle for channel 2                | 0x0038    | RO       |
| LEDC_CH3_DUTY_REG          | Initial duty cycle for channel 3                | 0x0044    | R/W      |
| LEDC_CH3_DUTY_R_REG        | Current duty cycle for channel 3                | 0x004C    | RO       |
| LEDC_CH4_DUTY_REG          | Initial duty cycle for channel 4                | 0x0058    | R/W      |
| LEDC_CH4_DUTY_R_REG        | Current duty cycle for channel 4                | 0x0060    | RO       |
| LEDC_CH5_DUTY_REG          | Initial duty cycle for channel 5                | 0x006C    | R/W      |
| LEDC_CH5_DUTY_R_REG        | Current duty cycle for channel 5                | 0x0074    | RO       |
| Timer Register             |                                                 |           |          |
| LEDC_TIMER0_CONF_REG       | Timer 0 configuration                           | 0x00A0    | varies   |
| LEDC_TIMER0_VALUE_REG      | Timer 0 current counter value                   | 0x00A4    | RO       |
| LEDC_TIMER1_CONF_REG       | Timer 1 configuration                           | 0x00A8    | varies   |
| LEDC_TIMER1_VALUE_REG      | Timer 1 current counter value                   | 0x00AC    | RO       |
| LEDC_TIMER2_CONF_REG       | Timer 2 configuration                           | 0x00B0    | varies   |
| LEDC_TIMER2_VALUE_REG      | Timer 2 current counter value                   | 0x00B4    | RO       |
| LEDC_TIMER3_CONF_REG       | Timer 3 configuration                           | 0x00B8    | varies   |
| LEDC_TIMER3_VALUE_REG      | Timer 3 current counter value                   | 0x00BC    | RO       |
| Interrupt Register         |                                                 |           |          |
| LEDC_INT_RAW_REG           | Raw interrupt status                            | 0x00C0    | R/WTC/SS |
| LEDC_INT_ST_REG            | Masked interrupt status                         | 0x00C4    | RO       |
| LEDC_INT_ENA_REG           | Interrupt enable bits                           | 0x00C8    | R/W      |
| LEDC_INT_CLR_REG           | Interrupt clear bits                            | 0x00CC    | WT       |
| Gamma RAM Register         |                                                 |           |          |
| LEDC_CH0_GAMMA_WR_REG      | LEDC channel 0 gamma RAM write register         | 0x0100    | R/W      |
| LEDC_CH0_GAMMA_WR_ADDR_REG | LEDC channel 0 gamma RAM write address register | 0x0104    | R/W      |
| LEDC_CH0_GAMMA_RD_ADDR_REG | LEDC channel 0 gamma RAM read address register  | 0x0108    | R/W      |
| LEDC_CH0_GAMMA_RD_DATA_REG | LEDC channel 0 gamma RAM read data reg ister   | 0x010C    | RO       |
| LEDC_CH1_GAMMA_WR_REG      | LEDC channel 1 gamma RAM write register         | 0x0110    | R/W      |
| LEDC_CH1_GAMMA_WR_ADDR_REG | LEDC channel 1 gamma RAM write address register | 0x0114    | R/W      |
| LEDC_CH1_GAMMA_RD_ADDR_REG | LEDC channel 1 gamma RAM read address register  | 0x0118    | R/W      |
| LEDC_CH1_GAMMA_RD_DATA_REG | LEDC channel 1 gamma RAM read data reg ister   | 0x011C    | RO       |
| LEDC_CH2_GAMMA_WR_REG      | LEDC channel 2 gamma RAM write register         | 0x0120    | R/W      |
| LEDC_CH2_GAMMA_WR_ADDR_REG | LEDC channel 2 gamma RAM write address register | 0x0124    | R/W      |
| LEDC_CH2_GAMMA_RD_ADDR_REG | LEDC channel 2 gamma RAM read address register  | 0x0128    | R/W      |
| LEDC_CH2_GAMMA_RD_DATA_REG | LEDC channel 2 gamma RAM read data reg ister   | 0x012C    | RO       |

| Name                         | Description                                     | Address                      | Access                       |
|------------------------------|-------------------------------------------------|------------------------------|------------------------------|
| LEDC_CH3_GAMMA_WR_REG        | LEDC channel 3 gamma RAM write register         | 0x0130                       | R/W                          |
| LEDC_CH3_GAMMA_WR_ADDR_REG   | LEDC channel 3 gamma RAM write address register | 0x0134                       | R/W                          |
| LEDC_CH3_GAMMA_RD_ADDR_REG   | LEDC channel 3 gamma RAM read address register  | 0x0138                       | R/W                          |
| LEDC_CH3_GAMMA_RD_DATA_REG   | LEDC channel 3 gamma RAM read data reg ister   | 0x013C                       | RO                           |
| LEDC_CH4_GAMMA_WR_REG        | LEDC channel 4 gamma RAM write register         | 0x0140                       | R/W                          |
| LEDC_CH4_GAMMA_WR_ADDR_REG   | LEDC channel 4 gamma RAM write address register | 0x0144                       | R/W                          |
| LEDC_CH4_GAMMA_RD_ADDR_REG   | LEDC channel 4 gamma RAM read address register  | 0x0148                       | R/W                          |
| LEDC_CH4_GAMMA_RD_DATA_REG   | LEDC channel 4 gamma RAM read data reg ister   | 0x014C                       | RO                           |
| LEDC_CH5_GAMMA_WR_REG        | LEDC channel 5 gamma RAM write register         | 0x0150                       | R/W                          |
| LEDC_CH5_GAMMA_WR_ADDR_REG   | LEDC channel 5 gamma RAM write address register | 0x0154                       | R/W                          |
| LEDC_CH5_GAMMA_RD_ADDR_REG   | LEDC channel 5 gamma RAM read address register  | 0x0158                       | R/W                          |
| LEDC_CH5_GAMMA_RD_DATA_REG   | LEDC channel 5 gamma RAM read data reg ister   | 0x015C                       | RO                           |
| Gamma Configuration Register | Gamma Configuration Register                    | Gamma Configuration Register | Gamma Configuration Register |
| LEDC_CH0_GAMMA_CONF_REG      | LEDC channel 0 gamma configuration reg ister   | 0x0180                       | varies                       |
| LEDC_CH1_GAMMA_CONF_REG      | LEDC channel 1 gamma configuration regis ter   | 0x0184                       | varies                       |
| LEDC_CH2_GAMMA_CONF_REG      | LEDC channel 2 gamma configuration regis ter   | 0x0188                       | varies                       |
| LEDC_CH3_GAMMA_CONF_REG      | LEDC channel 3 gamma configuration regis ter   | 0x018C                       | varies                       |
| LEDC_CH4_GAMMA_CONF_REG      | LEDC channel 4 gamma configuration regis ter   | 0x0190                       | varies                       |
| LEDC_CH5_GAMMA_CONF_REG      | LEDC channel 5 gamma configuration regis ter   | 0x0194                       | varies                       |
| Version Register             | Version Register                                | Version Register             | Version Register             |
| LEDC_DATE_REG                | Version control register                        | 0x01FC                       | R/W                          |

## 35.5 Registers

The addresses in this section are relative to LED PWM Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 35.1. LEDC\_CHn\_CONF0\_REG (n: 0-5) (0x0000+0x14*n)

![Image](images/35_Chapter_35_img009_fff11b4e.png)

LEDC\_TIMER\_SEL\_CHn Configures the timer for for channel n .

0: timer 0

1: timer 1

- 2: timer 2

3: timer 3

(R/W)

LEDC\_SIG\_OUT\_EN\_CHn Configures whether or not to enable signal output on channel n .

- 0: Disable

1: Enable

(R/W)

- LEDC\_IDLE\_LV\_CHn Configures the output level when channel n is inactive (when LEDC\_SIG\_OUT\_EN\_CHn is 0). (R/W)

LEDC\_PARA\_UP\_CHn

Configures whether or not to update LEDC\_HPOINT\_CHn

,

LEDC\_DUTY\_START\_CHn, LEDC\_SIG\_OUT\_EN\_CHn, LEDC\_TIMER\_SEL\_CHn, and

LEDC\_OVF\_CNT\_EN\_CHn fields for channel n

0: Invalid. No effect

1: Update

(WT)

LEDC\_OVF\_NUM\_CHn Configures the maximum overflow times minus 1.

The LEDC\_OVF\_CNT\_CHn\_INT interrupt will be triggered when channel n overflows for LEDC\_OVF\_NUM\_CHn + 1 times. (R/W)

LEDC\_OVF\_CNT\_EN\_CHn Configures whether or not to enable the overflow counter of channel n .

0: Disable

1: Enable

(R/W)

Continued on the next page...

.

Register 35.1. LEDC\_CHn\_CONF0\_REG (n: 0-5) (0x0000+0x14*n)

## Continued from the previous page...

LEDC\_OVF\_CNT\_RESET\_CHn Set this bit to reset the ovf\_cnt of channel n .

```
0: Invalid. No effect 1: Reset (WT)
```

Register 35.2. LEDC\_CHn\_CONF1\_REG (n: 0-5) (0x000C+0x14*n)

![Image](images/35_Chapter_35_img010_a6d7c380.png)

LEDC\_DUTY\_START\_CHn Configures whether or not to enable duty cycle fading.

0: Disable

1: Enable

(R/W/SC)

## Register 35.3. LEDC\_EVT\_TASK\_EN0\_REG (0x01A0)

![Image](images/35_Chapter_35_img011_1b4735bd.png)

LEDC\_EVT\_DUTY\_CHNG\_END\_CHn\_EN (n: 0-5) Configures whether or not to enable the LEDC\_EVT\_DUTY\_CHNG\_END\_CHn event.

0: Disable

1: Enable

(R/W)

- LEDC\_EVT\_OVF\_CNT\_PLS\_CHn\_EN (n: 0-5) Configures whether or not to enable the

LEDC\_EVT\_OVF\_CNT\_PLS\_CHn event.

0: Disable

1: Enable

(R/W)

- LEDC\_EVT\_TIME\_OVF\_TIMERx\_EN (x: 0-3) Configures whether or not to enable the LEDC\_EVT\_TIME\_OVF\_TIMERx event event.

0: Disable

1: Enable

(R/W)

- LEDC\_EVT\_TIMEx\_CMP\_EN (x: 0-3) Configures whether or not to enable the LEDC\_EVT\_TIMERx\_CMP event.

0: Disable

1: Enable

(R/W)

LEDC\_TASK\_DUTY\_SCALE\_UPDATE\_CHn\_EN (n: 0-5) Configures whether or not to enable the LEDC\_TASK\_DUTY\_SCALE\_UPDATE\_CHn task.

0: Disable

1: Enable

(R/W)

## Register 35.4. LEDC\_EVT\_TASK\_EN1\_REG (0x01A4)

![Image](images/35_Chapter_35_img012_1e596b48.png)

- LEDC\_TASK\_TIMERx\_RES\_UPDATE\_EN (x: 0-3) Configures whether or not to enable the LEDC\_TASK\_TIMERx\_RES\_UPDATE task.

0: Disable

1: Enable

(R/W)

- LEDC\_TASK\_TIMERx\_CAP\_EN (x: 0-3) Configures whether or not to enable the LEDC\_TASK\_TIMERx\_CAP task.

0: Disable

1: Enable

(R/W)

- LEDC\_TASK\_SIG\_OUT\_DIS\_CHn\_EN (n: 0-5) Configures whether or not to enable the LEDC\_TASK\_SIG\_OUT\_DIS\_CHn task.

0: Disable

1: Enable

(R/W)

- LEDC\_TASK\_OVF\_CNT\_RST\_CHn\_EN (n: 0-5) Configures whether or not to enable the LEDC\_TASK\_OVF\_CNT\_RST\_CHn task.

0: Disable

- 1: Enable

(R/W)

- LEDC\_TASK\_TIMERx\_RST\_EN (x: 0-3) Configures whether or not to enable the LEDC\_TASK\_TIMERx\_RST task.

```
0: Disable
```

1: Enable

(R/W)

- LEDC\_TASK\_TIMERx\_PAUSE\_RESUME\_EN (x: 0-3) Configures whether or not to enable the LEDC\_TASK\_TIMERx\_RESUME and LEDC\_TASK\_TIMERx\_PAUSE task.

0: Disable

1: Enable

(R/W)

Register 35.5. LEDC\_EVT\_TASK\_EN2\_REG (0x01A8)

![Image](images/35_Chapter_35_img013_b62e85a1.png)

LEDC\_TASK\_GAMMA\_RESTART\_CHn\_EN (n: 0-5) Configures whether or not to enable the LEDC\_TASK\_GAMMA\_RESTART\_CHn task.

0: Disable

1: Enable

(R/W)

- LEDC\_TASK\_GAMMA\_PAUSE\_CHn\_EN (n: 0-5) Configures whether or not to enable the LEDC\_TASK\_GAMMA\_PAUSE\_CHn task.

0: Disable

1: Enable

(R/W)

- LEDC\_TASK\_GAMMA\_RESUME\_CHn\_EN (n: 0-5) Configures whether or not to enable the LEDC\_TASK\_GAMMA\_RESUME\_CHn task.

0: Disable

1: Enable

```
(R/W)
```

Register 35.6. LEDC\_TIMERx\_CMP\_REG (x: 0-3) (0x01B0+0x4*x)

![Image](images/35_Chapter_35_img014_8b943332.png)

LEDC\_TIMERx\_CMP Configures the comparison value for LEDC timer x. (R/W)

Register 35.7. LEDC\_TIMERx\_CNT\_CAP\_REG (x: 0-3) (0x01C0+0x4*x)

![Image](images/35_Chapter_35_img015_07f8ebd6.png)

LEDC\_TIMERx\_CNT\_CAP Represents the captured LEDC timer x counter value. (RO)

Register 35.8. LEDC\_CONF\_REG (0x01F0)

![Image](images/35_Chapter_35_img016_0cb8f98f.png)

LEDC\_SCLK\_SEL Configures the clock source for the four timers.

- 0: PLL\_F80M\_CLK
- 1: RC\_FAST\_CLK
- 2: XTAL\_CLK
- 3: Invalid. No effect
- (R/W)

LEDC\_GAMMA\_RAM\_CLK\_EN\_CHn (n: 0-5) Configures when to enable register clock.

- 0: Support clock only when application reads or writes gamma RAM.
- 1: Force clock on for gamma RAM.

(R/W)

LEDC\_CLK\_EN Configures when to enable register clock.

- 0: Support clock only when application writes registers.
- 1: Force clock on for registers.

(R/W)

Register 35.9. LEDC\_CHn\_HPOINT\_REG (n: 0-5) (0x0004+0x14*n)

![Image](images/35_Chapter_35_img017_6ac4578c.png)

LEDC\_HPOINT\_CHn Configures the value of Hpoint. (R/W)

Register 35.10. LEDC\_CHn\_DUTY\_REG (n: 0-5) (0x0008+0x14*n)

![Image](images/35_Chapter_35_img018_f5e43b5c.png)

LEDC\_DUTY\_CHn Configures the initial value of Lpoint. (R/W)

Register 35.11. LEDC\_CHn\_DUTY\_R\_REG (n: 0-5) (0x0010+0x14*n)

![Image](images/35_Chapter_35_img019_d797028d.png)

LEDC\_DUTY\_CHn\_R Represents the current duty cycle of the output signal on channel n. (RO)

## Register 35.12. LEDC\_TIMERx\_CONF\_REG (x: 0-3) (0x00A0+0x8*x)

![Image](images/35_Chapter_35_img020_8d416dc8.png)

LEDC\_TIMERx\_DUTY\_RES Configures the duty cycle resolution (the width of the counter in timer x). (R/W)

LEDC\_CLK\_DIV\_TIMERx Configures the divisor for the divider in timer x .

The least significant eight bits represent the fractional part. The most significant ten bits represent the integer part. (R/W)

LEDC\_TIMERx\_PAUSE Configures whether or not to suspend the counter in timer x .

- 0: Not suspend

1: Suspend

(R/W)

LEDC\_TIMERx\_RST Configures whether or not to reset timer x (the counter will show 0 after reset).

```
0: Not reset 1: Reset (R/W)
```

LEDC\_TIMERx\_PARA\_UP Configures whether or not to update LEDC\_CLK\_DIV\_TIMERx and

```
LEDC_TIMERx_DUTY_RES. 0: Invalid. No effect 1: Update (WT)
```

Register 35.13. LEDC\_TIMERx\_VALUE\_REG (x: 0-3) (0x00A4+0x8*x)

![Image](images/35_Chapter_35_img021_9abca5b6.png)

LEDC\_TIMERx\_CNT Represents the current counter value of timer x. (RO)

## Register 35.14. LEDC\_INT\_RAW\_REG (0x00C0)

![Image](images/35_Chapter_35_img022_0b240506.png)

LEDC\_TIMERx\_OVF\_INT\_RAW (x: 0-3) The raw interrupt status of LEDC\_TIMERx\_OVF\_INT.

(R/WTC/SS) LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_RAW (n: 0-5) The raw interrupt status of LEDC\_DUTY\_CHNG\_END\_CHn\_INT. (R/WTC/SS)

LEDC\_OVF\_CNT\_CHn\_INT\_RAW (n: 0-5) The raw interrupt status of LEDC\_OVF\_CNT\_CHn\_INT. (R/WTC/SS)

## Register 35.15. LEDC\_INT\_ST\_REG (0x00C4)

![Image](images/35_Chapter_35_img023_b91f818b.png)

LEDC\_TIMERx\_OVF\_INT\_ST (x: 0-3) The masked interrupt status of LEDC\_TIMERx\_OVF\_INT.

Valid only when LEDC\_TIMERx\_OVF\_INT\_ENA is 1. (RO) LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_ST (n: 0-5) The masked interrupt status of LEDC\_DUTY\_CHNG\_END\_CHn\_INT. Valid only when LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_ENA is 1. (RO)

LEDC\_OVF\_CNT\_CHn\_INT\_ST (n: 0-5) The masked interrupt status of LEDC\_OVF\_CNT\_CHn\_INT. Valid only when LEDC\_OVF\_CNT\_CHn\_INT\_ENA is 1. (RO)

## Register 35.16. LEDC\_INT\_ENA\_REG (0x00C8)

![Image](images/35_Chapter_35_img024_910a31c3.png)

LEDC\_TIMERx\_OVF\_INT\_ENA (x: 0-3) Write 1 to enable LEDC\_TIMERx\_OVF\_INT. (R/W)

LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_ENA (n: 0-5)

LEDC\_DUTY\_CHNG\_END\_CHn\_INT. (R/W)

LEDC\_OVF\_CNT\_CHn\_INT\_ENA (n: 0-5) Write 1 to enable LEDC\_OVF\_CNT\_CHn\_INT. (R/W)

## Register 35.17. LEDC\_INT\_CLR\_REG (0x00CC)

![Image](images/35_Chapter_35_img025_e283c1b1.png)

LEDC\_TIMERx\_OVF\_INT\_CLR (x: 0-3) Write 1 to clear LEDC\_TIMERx\_OVF\_INT. (WT)

LEDC\_DUTY\_CHNG\_END\_CHn\_INT\_CLR (n: 0-5) Write 1 to clear LEDC\_DUTY\_CHNG\_END\_CHn\_INT. (WT)

LEDC\_OVF\_CNT\_CHn\_INT\_CLR (n: 0-5) Write 1 to clear LEDC\_OVF\_CNT\_CHn\_INT. (WT)

Write

1

to enable

Register 35.18. LEDC\_CHn\_GAMMA\_WR\_REG (n: 0-5) (0x0100+0x10*n)

![Image](images/35_Chapter_35_img026_da7f6e9a.png)

LEDC\_CHn\_GAMMA\_DUTY\_INC Configures the direction of duty cycle fading for PWM signals on channel n .

0: Decrease.

1: Increase

(R/W)

- LEDC\_CHn\_GAMMA\_DUTY\_CYCLE Configures the number of times the counter overflows per an duty cycle fade. (R/W)
- LEDC\_CHn\_GAMMA\_SCALE Configures the amount by which Lpointn increase or decrease each time. (R/W)

LEDC\_CHn\_GAMMA\_DUTY\_NUM Configures the number of fades in a duty cycle range. (R/W)

Register 35.19. LEDC\_CHn\_GAMMA\_WR\_ADDR\_REG (n: 0-5) (0x0104+0x10*n)

![Image](images/35_Chapter_35_img027_81198f23.png)

LEDC\_CHn\_GAMMA\_WR\_ADDR Configures LEDC channel n gamma RAM write address. (R/W)

LEDC\_CHn\_GAMMA\_RD\_DATA Represents data read from gamma RAM via LEDC channel n. (RO)

![Image](images/35_Chapter_35_img028_e3165735.png)

Register 35.22. LEDC\_CHn\_GAMMA\_CONF\_REG (n: 0-5) (0x0180+0x4*n)

![Image](images/35_Chapter_35_img029_68c9b02e.png)

LEDC\_CHn\_GAMMA\_ENTRY\_NUM Configures the number of duty cycle ranges. Maximum value is 16. (R/W)

LEDC\_CHn\_GAMMA\_PAUSE Configures whether or not to pause duty cycle fading.

```
0: Invalid. No effect 1: Pause (WT)
```

LEDC\_CHn\_GAMMA\_RESUME Configures whether or not to resume duty cycle fading.

```
0: Invalid. No effect 1: Resume
```

(WT)

## Register 35.23. LEDC\_DATE\_REG (0x01FC)

![Image](images/35_Chapter_35_img030_d49f9874.png)

LEDC\_LEDC\_DATE Version control register. (R/W)
