---
chapter: 36
title: "Chapter 36"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 36

## Motor Control PWM (MCPWM)

## 36.1 Overview

The Motor Control Pulse Width Modulator (MCPWM) peripheral is intended for motor and power control. It provides six PWM outputs that can be set up to operate in several topologies. One common topology uses a pair of PWM outputs driving an H-bridge to control motor rotation speed and rotation direction.

The MCPWM can be divided into five main modules: PWM timers, PWM operators, Capture module, Event Task Matrix (ETM) module, and Fault Detection module. Each PWM timer provides timing references that can either run freely or be synced to other timers or external sources. Each PWM operator has all necessary control resources to generate waveform pairs for one PWM channel. The Capture module is used for systems that need to accurately time external events. The ETM module responds to tasks received by the MCPWM, generating corresponding events depending on the state of motion. The Fault Detection module is used to capture external faults, allowing the system to respond by choice.

ESP32-C6 has one MCPWM peripheral, which is MCPWM0.

## 36.2 Features

An MCPWM peripheral has one clock divider (prescaler), three PWM timers, three PWM operators, a Capture module, an ETM module, and a Fault Detection module. MCPWM's core clock can be selected from three clock sources: PLL\_F160M\_CLK, XTAL\_CLK, and RC\_FAST\_CLK (configured by PWM\_CLKM\_SEL field in PCR register). Figure 36.2-1 shows the submodules inside MCPWM and the signals on the interface. PWM timers are used for generating timing references. The PWM operators generate the desired waveform based on the timing references. Any PWM operator can be configured to use the timing references of any PWM timers. Different PWM operators can use the same PWM timer's timing reference to generate PWM signals, or different PWM timers' values to generate separate PWM signals. Different PWM timers can also be synchronized together.

Below is an overview of the submodules’ functionality in Figure 36.2-1:

- PWM Timers 0, 1, and 2:
- – Every PWM timer has a dedicated 8-bit clock prescaler.
- – The 16-bit counter in the PWM timer can work in count-up mode, count-down mode, or count-up-down mode.
- – A hardware sync or software sync can trigger a reload on the PWM timer with a phase register. It will also trigger the prescaler's restart, so that the timer's clock can also be synced. The source of the hard sync can come from any GPIO or any other PWM timer's sync\_out. The source of the soft sync comes from writing toggle value to the MCPWM\_TIMERx\_SYNC\_SW bit.

Figure 36.2-1. MCPWM Module Overview

![Image](images/36_Chapter_36_img001_36f4ea07.png)

- PWM Operators 0, 1, and 2:
- – Every PWM operator has two PWM outputs: PWMxA and PWMxB. They can work independently, in symmetric or asymmetric configurations.
- – The control of the PWM signal can be updated asynchronously.
- – Configurable dead time on rising and falling edges; each set up independently.
- – All events can trigger CPU interrupts.
- – Modulating of PWM output by high-frequency carrier signals, useful when gate drivers are insulated with a transformer.
- – Period, time stamps, and important control registers have shadow registers with flexible updating methods.
- Fault Detection Module:
- – Programmable fault handling in both cycle-by-cycle mode and one-shot mode.
- – A fault condition can force the PWM output to either high or low logic levels.
- Capture Module:
- – Clock of the capture module is the same as MCPWM's core clock.
- – Speed measurement of rotating machinery.
- – Measurement of elapsed time between position sensor pulses
- – Period and duty cycle measurement of pulse train signals
- – Decoding current or voltage amplitude derived from duty-cycle-encoded signals of current/voltage sensors
- – Three individual capture channels, each of which with a time-stamp register (32-bit)

- – Selection of edge polarity and prescaling of input capture signals
- – The capture timer can sync with a PWM timer or external signals.
- – Interrupt on each of the three capture channels

## · ETM Module:

- – Generation of different events depending on the different running states of each timer and operator.
- – Each timer and operator responds to its corresponding task and automatically performs the corresponding operation.
- – Each event and task can be enabled independently. When an event is not enabled, the corresponding event will not be generated. When a task is not enabled, the corresponding task will not be responded to.

## 36.3 Modules

## 36.3.1 Overview

This section lists the configuration parameters of key modules. For information on adjusting a specific parameter, e.g. synchronization source of PWM timer, please refer to Section 36.3.2 for details.

## 36.3.1.1 Prescaler Module

## Configuration option:

- Scale the PWM\_CORE\_CLK.

## 36.3.1.2 Timer Module

Figure 36.3-2. Timer Module

![Image](images/36_Chapter_36_img002_e6a01cac.png)

## Configuration options:

- Configure the PWM timer frequency or period.
- Configure the working mode for the timer:
- – Count-Up Mode: for asymmetric PWM outputs
- – Count-Down Mode: for asymmetric PWM outputs
- – Count-Up-Down Mode: for symmetric PWM outputs
- Configure the reloading phase (including the value and the direction) used during software and hardware synchronization.
- Synchronize the PWM timers with each other. Either hardware or software synchronization may be used.
- Configure the source of the PWM timer's the synchronization input to one of the seven sources below:
- – The three PWM timer's synchronization outputs.
- – Three synchronization signals from the GPIO matrix: PWMn\_SYNC0\_IN, PWMn\_SYNC1\_IN, PWMn\_SYNC2\_IN.

Figure 36.3-1. Prescaler Module

![Image](images/36_Chapter_36_img003_7cad9d93.png)

- – No synchronization input signal selected
- Configure the source of the PWM timer's synchronization output to one of the four sources below:
- – Synchronization input signal
- – Event generated when the value of the PWM timer is equal to zero
- – Event generated when the value of the PWM timer is equal to the period
- – Event generated when writing toggle value to MCPWM\_TIMERx\_SYNC\_SW bit
- Configure the method of period updating.

## 36.3.1.3 Operator Module

Figure 36.3-3. Operator Module

![Image](images/36_Chapter_36_img004_ae411363.png)

The configuration parameters of the operator module are shown in Table 36.3-1 .

Table 36.3-1. Configuration Parameters of the Operator Submodule

| Submodule     | Configuration Parameter or Option
 • Configure the PWM duty cyc nfi
 •  guration Parameter or Option
 Configure the PWM duty cycle for PWMxA and/or PWMxB                                                                                                                                                                                                                                                                      |
|---------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| PWM Generator | output. •  Configure at which time the timing events occur. •  Configure what action should be taken on timing events: –  Switch high or low of PWMxA and/or PWMxB outputs –  Toggle PWMxA and/or PWMxB outputs –  Take no action on outputs •  Use direct s/w control to force the state of PWM outputs •  Add a dead time to raising edge and/or failing edge on PWM outputs. •  Configure update method for this submodule. |

| Submodule           | Configuration Parameter or Option
 • Control of complementary de nfi
 •  guration Parameter or Option
 Control of complementary dead time relationship between                                                                                                                                                                                                                                                                                                                                                                                 |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Dead Time Generator | upper and lower switches. •  Specify the dead time on rising edge. •  Specify the dead time on falling edge. •  Bypass the dead time generator module. The PWM wave form will pass through without inserting dead time. •  Allow PWMxB phase shifting with respect to the PWMxA out put. •  Configure updating method for this submodule.
 Eblid t if •  gpg 
 Enable carrier and set up carrier frequency.                                                                                                                                  |
| PWM Carrier         | •  Configure duration of the first pulse in the carrier waveform. •  Configure the duty cycle of the following pulses. •  Bypass the PWM carrier module. The PWM waveform will be passed through without modification.
 Cfiif d hthPWM dlh •  pg
 Configure if and how the PWM module should react the fault                                                                                                                                                                                                                                   |
| Fault Handler       | event signals. •  Specify the action taken when a fault event occurs: –  Force PWMxA and/or PWMxB high. –  Force PWMxA and/or PWMxB low. –  Configure PWMxA and/or PWMxB to ignore any fault event. •  Configure how often the PWM should react to fault events: –  One-shot –  Cycle-by-cycle •  Generate interrupts. •  Bypass the fault handler submodule entirely. •  Configure an option for cycle-by-cycle actions clearing. •  If desired, independently-configured actions can be taken when time-base counter is counting down or up. |

## 36.3.1.4 Fault Detection Module

Figure 36.3-4. Fault Detection Module

![Image](images/36_Chapter_36_img005_bf36b79a.png)

## Configuration options:

- Enable fault event generation and configure the polarity of fault event generated for every fault signal.
- Generate fault event interrupts.

## 36.3.1.5 Capture Module

Configuration options:

- Select the edge polarity and prescale the capture input.
- Set up a software-triggered capture.
- Configure the capture timer's sync trigger and sync phase.
- Software syncs the capture timer.

## 36.3.1.6 ETM Module

Figure 36.3-6. ETM Module

![Image](images/36_Chapter_36_img006_f1198d56.png)

## Configuration options:

- Each event and task can be enabled independently. When an event is not enabled, the corresponding event will not be generated. When a task is not enabled, the corresponding task will not be responded to.

## 36.3.2 PWM Timer Module

MCPWM has three PWM timer modules. Any of them can determine the necessary event timing for any of the three PWM operator modules. By using the synchronization signals from the GPIO matrix, built-in synchronization logic allows multiple PWM timer modules in one or more MCPWM peripherals to work together as a system.

## 36.3.2.1 Configurations of the PWM Timer Module

Users can configure the following functions of the PWM timer module:

- Control how often events occur by specifying the PWM timer frequency or period.
- Configure a particular PWM timer to synchronize with other PWM timers or modules.

Figure 36.3-5. Capture Module

![Image](images/36_Chapter_36_img007_257ab5fa.png)

- Get a PWM timer in phase with other PWM timers or modules.
- Configure the following timer counting modes: count-up, count-down, count-up-down.
- Change the rate of the PWM timer clock (PT\_clk) with a prescaler. Each timer has its own prescaler configured with MCPWM\_TIMERx\_PRESCALE of the register MCPWM\_TIMER0\_CFG0\_REG. The PWM timer increments or decrements at a slower pace, depending on the setting of this field. The new MCPWM\_TIMERx\_PRESCALE configuration value will take effect when the timer stops and starts counting again.

## 36.3.2.2 PWM Timer's Working Modes and Timing Event Generation

The PWM timer has three working modes, selected by the PWMx timer mode field:

- Count-Up Mode:

The PWM timer increments from zero until reaching the value configured in the period field. Once done, the PWM timer returns to zero and starts increasing again. PWM period = the value of the period field + 1. Note: The period field is MCPWM\_TIMERx\_PERIOD (x = 0, 1, 2), i.e., MCPWM\_TIMER0\_PERIOD , MCPWM\_TIMER1\_PERIOD , MCPWM\_TIMER2\_PERIOD .

- Count-Down Mode:

The PWM timer decrements to zero, starting from the value configured in the period field. Once done, the PWM timer returns to the period value and starts decrementing again. In this case, the PWM period = the value of period field + 1.

- Count-Up-Down Mode:

This is a combination of the two modes mentioned above. The PWM timer starts increasing from zero until the period value is reached. Then, the timer decreases back to zero. The PWM timer cycles incrementally and decrementally in this mode. The PWM period = the value of the period field × 2.

Figures 36.3-7 to 36.3-10 show PWM timer waveforms in different modes, including timer behavior during synchronization events. In Count-Up mode, the counting direction after synchronization is always counting up. In Count-Down mode, the counting direction after synchronization is always counting down. In Count-Up-Down Mode, the counting direction after synchronization can be chosen by setting the MCPWM\_TIMERx\_PHASE\_DIRECTION .

Figure 36.3-7. Count-Up Mode Waveform

![Image](images/36_Chapter_36_img008_0d84bf0c.png)

![Image](images/36_Chapter_36_img009_3b7466d3.png)

Figure 36.3-8. Count-Down Mode Waveforms

Figure 36.3-9. Count-Up-Down Mode Waveforms, Count-Down at Synchronization Event

![Image](images/36_Chapter_36_img010_39caf635.png)

Figure 36.3-10. Count-Up-Down Mode Waveforms, Count-Up at Synchronization Event

![Image](images/36_Chapter_36_img011_1584697b.png)

When the PWM timer is running, it generates the following timing events periodically and automatically:

- UTEP: The timing event generated when the PWM timer's value is equal to the value of the period field (MCPWM\_TIMERx\_PERIOD) and when the PWM timer is increasing.
- UTEZ: The timing event generated when the PWM timer's value equals to zero and when the PWM timer is increasing.
- DTEP: The timing event generated when the PWM timer's value equals to the value of the period field (MCPWM\_TIMERx\_PERIOD) and when the PWM timer is decreasing.
- DTEZ: The timing event generated when the PWM timer's value equals to zero and when the PWM timer is decreasing.

Figures 36.3-11 to 36.3-13 show the timing waveforms of U/DTEP and U/DTEZ.

![Image](images/36_Chapter_36_img012_093da9f4.png)

Figure 36.3-11. UTEP and UTEZ Generation in Count-Up Mode

![Image](images/36_Chapter_36_img013_37ee3a38.png)

Figure 36.3-12. DTEP and DTEZ Generation in Count-Down Mode

![Image](images/36_Chapter_36_img014_79584494.png)

Figure 36.3-13. DTEP and UTEZ Generation in Count-Up-Down Mode

![Image](images/36_Chapter_36_img015_44b8d7d3.png)

Please note that in the Count-Up-Down Mode, when the counting direction is increasing, the timer range is [0,

period value - 1], and when the counting direction is decreasing, the timer range is [period value, 1]. That is, in this mode, when synchronizing the timer to 0, decreasing counting direction will be illegal, namely, MCPWM\_TIMERn\_PHASE\_DIRECTION cannot be set to 1. Similarly, when synchronizing the timer to period value, increasing counting direction will be illegal, namely, MCPWM\_TIMERn\_PHASE\_DIRECTION cannot be set to 0. Therefore, when the timer is synchronized to 0, the counting direction can only be increasing, and MCPWM\_TIMERn\_PHASE\_DIRECTION will be 0. When the timer is synchronized to the period value, the counting direction can only be decreasing, and MCPWM\_TIMERn\_PHASE\_DIRECTION will be 1.

![Image](images/36_Chapter_36_img016_451dc64d.png)

## 36.3.2.3 Shadow Register of PWM Timer

The PWM timer's period register and the PWM timer's clock prescaler register have shadow registers. The shadow registers can back up the values that are about to be written to the valid registers. It also supports to write the values saved into the active register at a specific moment of hardware synchronization. The functionality of both register types is as follows:

- Active Register: Directly responsible for controlling all actions performed by hardware.
- Shadow Register: Acts as a temporary buffer for a value to be written to the active register. At a specific, user-configured point in time, the value saved in the shadow register is copied to the active register. Before this happens, the content of the shadow register has no direct effect on the controlled hardware. This helps to prevent erroneous operation of the hardware, which may happen when a register is asynchronously modified by software. Both the shadow register and the active register have the same memory address. The software always writes into, or reads from the shadow register.

The moment of updating the clock prescaler's active register is at the time when the timer starts operating. When MCPWM\_GLOBAL\_UP\_EN is set to 1, the moment of updating the period active register can be selected by the following ways:

- – By configuring the update method register MCPWM\_TIMERx\_PERIOD\_UPMETHOD to 0, the update will start immediately.
- – By configuring the update method register MCPWM\_TIMERx\_PERIOD\_UPMETHOD to 1, the update can start when the PWM timer is equal to zero.
- – By configuring the update method register MCPWM\_TIMERx\_PERIOD\_UPMETHOD to 2, the update can start when the PWM timer is synchronized.
- – By configuring the update method register MCPWM\_TIMERx\_PERIOD\_UPMETHOD to 3, the update can start when the PWM timer is equal to zero or is synchronized.
- – Software can also trigger a globally forced update bit MCPWM\_GLOBAL\_FORCE\_UP which will prompt all registers in the module to be updated according to shadow registers.

## 36.3.2.4 PWM Timer Synchronization and Phase Locking

The PWM modules adopt a flexible synchronization method. Each PWM timer has a synchronization input and a synchronization output. The synchronization input can be selected from three synchronization outputs and three synchronization signals from the GPIO matrix. The synchronization output can be generated from the synchronization input signal, when the PWM timer's value is equal to period or zero, or software synchronization. Thus, the PWM timers can be chained together with their phase locked. During synchronization, the PWM timer clock prescaler will reset its counter in order to synchronize the PWM timer clock.

## 36.3.3 PWM Operator Module

The PWM Operator module has the following functions:

- Generates a PWM signal pair, based on timing references obtained from the corresponding PWM timer.
- Each signal out of the PWM signal pair includes a specific pattern of dead time.

- Superimposes a carrier on the PWM signal, if configured to do so.
- Handles response under fault conditions.

Figure 36.3-14 shows the block diagram of a PWM operator.

![Image](images/36_Chapter_36_img017_87911999.png)

Figure 36.3-14. Block Diagram of A PWM Operator

![Image](images/36_Chapter_36_img018_46519360.png)

## 36.3.3.1 PWM Generator Module

## Purpose of the PWM Generator Module

In this module, important timing events are generated or imported. The events are then converted into specific actions to generate the desired waveforms at the PWMxA and PWMxB outputs.

The PWM generator module performs the following actions:

- Generation of timing events based on time stamps configured using the A and B registers. Events happen when the following conditions are met:
- – UTEA: the PWM timer is counting up and its value is equal to register A.
- – UTEB: the PWM timer is counting up and its value is equal to register B.
- – DTEA: the PWM timer is counting down and its value is equal to register A.
- – DTEB: the PWM timer is counting down and its value is equal to register B.
- Generation of U/DT0, U/DT1 timing events based on fault or synchronization events.
- – UT0: the PWM timer is counting up and FAULT0 detected (field MCPWM\_GENx\_T0\_SEL is set to 0) or FAULT1 detected (field MCPWM\_GENx\_T0\_SEL is set to 1) or FAULT2 detected (field MCPWM\_GENx\_T0\_SEL is set to 2) or synchronized (field MCPWM\_GENx\_T0\_SEL is set to 3).
- – UT1: the PWM timer is counting up and FAULT0 detected (field MCPWM\_GENx\_T1\_SEL is set to 0) or FAULT1 detected (field MCPWM\_GENx\_T1\_SEL is set to 1) or FAULT2 detected (field MCPWM\_GENx\_T1\_SEL is set to 2) or synchronized (field MCPWM\_GENx\_T1\_SEL is set to 3).
- – DT0: the PWM timer is counting down and FAULT0 detected (field MCPWM\_GENx\_T0\_SEL is set to 0) or FAULT1 detected (field MCPWM\_GENx\_T0\_SEL is set to 1) or FAULT2 detected (field MCPWM\_GENx\_T0\_SEL is set to 2) or synchronized (field MCPWM\_GENx\_T0\_SEL is set to 3).
- – DT1: the PWM timer is counting down and FAULT0 detected(field MCPWM\_GENx\_T1\_SEL is set to 0) or FAULT1 detected (field MCPWM\_GENx\_T1\_SEL is set to 1) or FAULT2 detected (field MCPWM\_GENx\_T1\_SEL is set to 2) or synchronized (field MCPWM\_GENx\_T1\_SEL is set to 3).
- Management of priority when these timing events occur concurrently.
- Generation of set, clear, and toggle actions, based on the timing events.
- Controlling of the PWM duty cycle, depending on configuration of the PWM generator module.
- Handling of new time stamp values, using shadow registers to prevent glitches in the PWM cycle.

## Shadow Register of PWM Operator

The time stamp registers A and B, as well as action configuration registers MCPWM\_GENx\_A\_REG and MCPWM\_GENx\_B\_REG are shadowed. Shadowing provides a way of updating registers in sync with the hardware.

When MCPWM\_GLOBAL\_UP\_EN is set to 1, the shadow registers can be written to the active register at a specified time. The update method field for MCPWM\_GENx\_A\_REG and MCPWM\_GENx\_B\_REG is MCPWM\_GENx\_CFG\_UPMETHOD. Software can also trigger a globally forced update bit MCPWM\_GLOBAL\_FORCE\_UP which will prompt all registers in the module to be updated according to shadow registers. For a description of the shadow registers, please see Section 36.3.2.3 .

## Timing Events

For convenience, all timing signals and events are summarized in Table 36.3-2 .

Table 36.3-2. Timing Events Used in PWM Generator

| Signal               | Event Description                                     | PWM Timer Operation   |
|----------------------|-------------------------------------------------------|-----------------------|
| DTEP                 | PWM timer value is equal to the period register value | PWM timer counts down |
| DTEZ                 | PWM timer value is equal to zero                      | PWM timer counts down |
| DTEA                 | PWM timer value is equal to register A                | PWM timer counts down |
| DTEB                 | PWM timer value is equal to register B                | PWM timer counts down |
| DT0 event            | Based on fault or synchronization events              | PWM timer counts down |
| DT1 event            | Based on fault or synchronization events              | PWM timer counts down |
| UTEP                 | PWM timer value is equal to the period register value | PWM timer counts up   |
| UTEZ                 | PWM timer value is equal to zero                      | PWM timer counts up   |
| UTEA                 | PWM timer value is equal to register A                | PWM timer counts up   |
| UTEB                 | PWM timer value is equal to register B                | PWM timer counts up   |
| UT0 event            | Based on fault or synchronization events              | PWM timer counts up   |
| UT1 event            | Based on fault or synchronization events              | PWM timer counts up   |
| Software-force event | Software-initiated asynchronous event                 | N/A                   |

The purpose of a software-force event is to impose non-continuous or continuous changes on the PWMxA and PWMxB outputs. The change is done asynchronously. Software-force control is handled by the MCPWM\_GENx\_FORCE\_REG registers.

The selection and configuration of T0/T1 in the PWM generator module is independent of the configuration of fault events in the fault handler module. A particular trip event may or may not be configured to cause trip action in the fault handler submodule, but the same event can be used by the PWM generator to trigger T0/T1 for controlling PWM waveforms.

It is important to know that when the PWM timer is in count-up-down mode. It will always decrement after a TEP event, and increment after a TEZ event. So, when the PWM timer is in count-up-down mode, DTEP and UTEZ events will occur, while UTEP and DTEZ events never occurs.

The PWM generator can handle multiple events at the same time. Events are prioritized by the hardware and relevant details are provided in Table 36.3-3 and Table 36.3-4. Priority levels range from 1 (the highest) to 7 (the lowest). Please note that the priority of TEP and TEZ events depends on the PWM timer's counting mode.

If the value of A or B is set to be greater than the period, then U/DTEA and U/DTEB will never occur.

Table 36.3-3. Timing Events Priority When PWM Timer Increments

| Priority Level   | Event                 |
|------------------|-----------------------|
| 1 (highest)      | Software-forced event |
| 2                | UTEP                  |
| 3                | UT0                   |
| 4                | UT1                   |
| 5                | UTEB                  |

## Notes:

1. UTEP and UTEZ do not happen simultaneously. When the PWM timer is in count-up mode, UTEP will always happen one cycle earlier than UTEZ, as demonstrated in Figure 36.3-11, so their action on PWM signals will not interrupt each other. When the PWM timer is in count-up-down mode, UTEP will not occur.
2. DTEP and DTEZ do not happen simultaneously. When the PWM timer is in count-down mode, DTEZ will always happen one cycle earlier than DTEP, as demonstrated in Figure 36.3-12, so their action on PWM signals will not interrupt each other. When the PWM timer is in count-up-down mode, DTEZ will not occur.

## PWM Signal Generation

The PWM generator module controls the behavior of outputting PWMxA and PWMxB when a particular timing event occurs. The timing events are further qualified by the PWM timer's counting mode (increment or decrement). Knowing the counting mode, the module may then perform an independent action at each stage of the PWM timer counting up or down.

The following actions may be configured on PWMxA and PWMxB outputs:

- Set High: Set the output of PWMxA or PWMxB to a high level.
- Clear Low: Clear the output of PWMxA or PWMxB by setting it to a low level.
- Toggle: Change the current output level of PWMxA or PWMxB to the opposite value. If it is currently pulled up, then pull it down, or vice versa.
- Do Nothing: Keep both outputs PWMxA and PWMxB unchanged. In this state, interrupts can still be triggered.

Actions on outputs is configured by using registers MCPWM\_GENx\_A\_REG and

MCPWM\_GENx\_B\_REG. So, the action to be taken on each output is set independently. Also there is great flexibility in selecting actions to be taken on a given output based on events. More specifically, any event listed in Table 36.3-2 can operate on either output of PWMxA or PWMxB. To check out registers for particular generator 0, 1, or 2, please refer to register description in Section 36.4 .

| Priority Level   | Event   |
|------------------|---------|
| 6                | UTEA    |
| 7 (lowest)       | UTEZ    |

Table 36.3-4. Timing Events Priority when PWM Timer Decrements

| Priority level   | Event                 |
|------------------|-----------------------|
| 1 (highest)      | Software-forced event |
| 2                | DTEZ                  |
| 3                | DT0                   |
| 4                | DT1                   |
| 5                | DTEB                  |
| 6                | DTEA                  |
| 7 (lowest)       | DTEP                  |

## Waveforms for Common Configurations

Figure 36.3-15 presents the symmetric PWM waveform generated when the PWM timer is in Count-Up-Down mode. DC 0%–100% modulation can be calculated via the formula below:

<!-- formula-not-decoded -->

If A matches the PWM timer value and the PWM timer is incrementing, then the PWM output is pulled up. If A matches the PWM timer value while the PWM timer is decrementing, then the PWM output is pulled low.

Figure 36.3-15. Symmetrical Waveform in Count-Up-Down Mode

![Image](images/36_Chapter_36_img019_97e8e3ce.png)

The PWM waveforms in Figures 36.3-16 to 36.3-19 show some common PWM operator configurations. The following conventions are used in the figures:

- Period A and B refer to the values written in the corresponding registers.
- PWMxA and PWMxB are the output signals of PWM Operator x .

Figure 36.3-16. Count-Up, Single Edge Asymmetric Waveform, with Independent Modulation on PWMxA and PWMxB — Active High

![Image](images/36_Chapter_36_img020_c9551f65.png)

The duty modulation for PWMxA is set by B, active high and proportional to B.

The duty modulation for PWMxB is set by A, active high and proportional to A.

P eriod = (MCPWM \_ T IMERx \_ P ERIOD + 1) × TP T \_ clk

Figure 36.3-17. Count-Up, Pulse Placement Asymmetric Waveform with Independent Modulation on PWMxA

![Image](images/36_Chapter_36_img021_ebb33a52.png)

Pulses may be generated anywhere within the PWM cycle (zero to period). PWMxA's high time duty is proportional to (B – A).

P eriod = (MCPWM \_ T IMERx \_ P ERIOD + 1) × TP T \_ clk

Figure 36.3-18. Count-Up-Down, Dual Edge Symmetric Waveform, with Independent Modulation on PWMxA and PWMxB — Active High

![Image](images/36_Chapter_36_img022_573865d0.png)

The duty modulation for PWMxA is set by A, active high and proportional to A.

The duty modulation for PWMxB is set by B, active high and proportional to B.

Outputting PWMxA and PWMxB can drive separate switches.

P eriod = (2 × MCPWM \_ T IMERx \_ P ERIOD) × TP T \_ clk

Figure 36.3-19. Count-Up-Down, Dual Edge Symmetric Waveform, with Independent Modulation on PWMxA and PWMxB — Complementary

![Image](images/36_Chapter_36_img023_e4811353.png)

The duty modulation of PWMxA is set by A, is active high and proportional to A.

The duty modulation of PWMxB is set by B, is active low and proportional to B.

Outputs PWMx can drive upper/lower (complementary) switches.

Dead time = B – A. Edge placement is configurable by software. Dead time generator module supports configuring edge delay methods when required.

<!-- formula-not-decoded -->

Figure 36.3-20 shows a waveform when UT0/1 and DT0/1 events are generated. In this example, T0 selects

Figure 36.3-20. Count-Up-Down, Fault or Synchronization Events, with Same Modulation on PWMxA and PWMxB

![Image](images/36_Chapter_36_img024_7454dae2.png)

FAULT0 and T1 selects FAULT1. The events selected by T0 and T1 can be configured independently, these events can be FAULT0, FAULT1, FAULT2 or synchronous. For detailed configuration, see section 36.3.3.1 .

## Software-Force Events

There are two types of software-force events inside the PWM generator:

- Non-continuous-immediate (NCI) software-force events: Such types of events are immediately effective on PWM outputs when triggered by software. The forcing is non-continuous, which means the next active timing events will be able to alter the PWM outputs.
- Continuous (CNTU) software-force events: Such types of events are continuous. The forced PWM outputs will continue until they are released by software. The events' triggers are configurable. They can

be configured to be timing events or immediate events.

Figure 36.3-21 shows a waveform of NCI software-force events. NCI events are used to force PWMxA output low. Forcing on PWMxB is disabled in this case.

Figure 36.3-21. Example of an NCI Software-Force Event on PWMxA

![Image](images/36_Chapter_36_img025_e314a0c1.png)

Figure 36.3-22 shows a waveform of CNTU software-force events. UTEZ events are selected as triggers for CNTU software-force events. CNTU is used to force the PWMxB output low. Forcing on PWMxA is disabled.

Figure 36.3-22. Example of a CNTU Software-Force Event on PWMxB

![Image](images/36_Chapter_36_img026_5af77455.png)

## 36.3.3.2 Dead Time Generator Module

## Purpose of the Dead Time Generator Module

Section 36.3.3.1 introduced several options to generate signals on PWMxA and PWMxB outputs, with a specific placement of signal edges. The required dead time is obtained by altering the edge placement between signals and by setting the signal's duty cycle. Another option to control the dead time is to use a specialized module – Dead Time Generator.

The key functions of the Dead Time Generator module are as follows:

- Generating signal pairs (PWMxA and PWMxB) with a dead time from a single PWMxA input
- Creating a dead time by adding delay to signal edges:
- – Rising edge delay (RED)
- – Falling edge delay (FED)
- Configuring the signal pairs to be:
- – Active high complementary (AHC)
- – Active low complementary (ALC)
- – Active high (AH)
- – Active low (AL)
- This module may also be bypassed, if the dead time is configured directly in the generator module.

## Shadow Register of Dead Time Generator

Delay registers RED and FED are shadowed with registers MCPWM\_DTx\_RED\_CFG\_REG and MCPWM\_DTx\_FED\_CFG\_REG. When MCPWM\_GLOBAL\_UP\_EN is set to 1, the values saved in the shadow registers can be written to the active register at specified time. The update method register for MCPWM\_DTx\_RED\_CFG\_REG is MCPWM\_DTx\_RED\_UPMETHOD. The update method register for MCPWM\_DTx\_FED\_CFG\_REG is MCPWM\_DTx\_FED\_UPMETHOD. The Software can also trigger a globally forced update bit MCPWM\_GLOBAL\_FORCE\_UP which will prompt all registers in the module to be updated according to shadow registers. For the description of shadow registers, please see section 36.3.2.3 .

## Highlights for Operation of the Dead Time Generator

Options for setting up the dead time module are shown in Figure 36.3-23 .

Figure 36.3-23. Options for Setting up the Dead Time Generator Module

![Image](images/36_Chapter_36_img027_ef6a213c.png)

S0-S8 in the figure above are switches controlled by fields in register MCPWM\_DTx\_CFG\_REG shown in Table 36.3-5 .

Table 36.3-5. Dead Time Generator Switches Control Fields

| Switch   | Field                   |
|----------|-------------------------|
| S0       | MCPWM_DTx_B_OUTBYPASS   |
| S1       | MCPWM_DTx_A_OUTBYPASS   |
| S2       | MCPWM_DTx_RED_OUTINVERT |
| S3       | MCPWM_DTx_FED_OUTINVERT |
| S4       | MCPWM_DTx_RED_INSEL     |
| S5       | MCPWM_DTx_FED_INSEL     |
| S6       | MCPWM_DTx_A_OUTSWAP     |
| S7       | MCPWM_DTx_B_OUTSWAP     |
| S8       | MCPWM_DTx_DEB_MODE      |

All switch combinations are supported, but not all of them represent the typical modes of use. Table 36.3-6 documents some typical dead time configurations. In these configurations, the position of S4 and S5 sets PWMxA as the common source of both falling edge delay (FED) and rising edge delay (RED). The modes presented in table 36.3-6 may be categorized as follows:

Table 36.3-6. Typical Dead Time Generator Operating Modes

|   Mode | Mode Description                                    |   S0 |   S1 | S2   | S3   |
|--------|-----------------------------------------------------|------|------|------|------|
|      1 | PWMxA and PWMxB Pass Through/No Delay               |    1 |    1 | X    | X    |
|      2 | Active High Complementary (AHC), see Figure 36.3-24 |    0 |    0 | 0    | 1    |
|      3 | Active Low Complementary (ALC), see Figure 36.3-25  |    0 |    0 | 1    | 0    |
|      4 | Active High (AH), see Figure 36.3-26                |    0 |    0 | 0    | 0    |
|      5 | Active Low (AL), see Figure 36.3-27                 |    0 |    0 | 1    | 1    |

|   Mode | Mode Description                                                                            |   S0 |   S1 | S2     | S3     |
|--------|---------------------------------------------------------------------------------------------|------|------|--------|--------|
|      6 | PWMxA Output = PWMxA In (No Delay)  PWMxB Output = PWMxA Input with Falling Edge Delay      |    0 |    1 | 0 or 1 | 0 or 1 |
|      7 | PWMxA Output = PWMxA Input with Rising Edge Delay  PWMxB Output = PWMxB Input with No Delay |    1 |    0 | 0 or 1 | 0 or 1 |

## Note:

For all the modes above, the position of the binary switches S4 to S8 is set to 0.

- Mode 1: Bypass delays on both FED and RED

In this mode, the dead time module is disabled. Signals of PWMxA and PWMxB pass through without any modifications.

- Mode 2-5: Classical Dead Time Polarity Settings

These four modes represent typical configurations of polarity and should cover the active-high/low modes in available industry power switch gate drivers. The typical waveforms are shown in Figures 36.3-24 to 36.3-27 .

- Modes 6 and 7: Bypass delay on falling edge (FED) or rising edge (RED)

In these two modes, either RED or FED is bypassed. As a result, the corresponding delay is not applied.

Figure 36.3-24. Active High Complementary (AHC) Dead Time Waveforms

![Image](images/36_Chapter_36_img028_6512c883.png)

RED and FED delays may be set up independently. The delay value is programmed using the 16-bit field MCPWM\_DTx\_RED and MCPWM\_DTx\_FED. The register value represents the number of clock (DT\_CLK) periods by which a signal edge is delayed. DT\_CLK can be selected from PWM\_clk or PT\_clk through register MCPWM\_DTx\_CLK\_SEL .

To calculate the delay on falling edge (FED) and rising edge (RED), use the following formulas:

F ED = MCPWM \_ DTx \_ F ED × TD TDT \_ clk

RED = MCPWM \_ DTx \_ RED × TD TDT \_

<!-- formula-not-decoded -->

![Image](images/36_Chapter_36_img029_5f9f75f8.png)

Figure 36.3-25. Active Low Complementary (ALC) Dead Time Waveforms

Figure 36.3-26. Active High (AH) Dead Time Waveforms

![Image](images/36_Chapter_36_img030_be9fe9c8.png)

Figure 36.3-27. Active Low (AL) Dead Time Waveforms

![Image](images/36_Chapter_36_img031_8ac5b780.png)

## 36.3.3.3 PWM Carrier Module

The coupling of PWM output to a motor driver may need isolation with a transformer. Transformers deliver only AC signals, while the duty cycle of a PWM signal may range anywhere from 0% to 100%. The PWM carrier module passes such a PWM signal through a transformer by using a high frequency carrier to modulate the signal.

## Function Overview

The following key characteristics of this module are configurable:

- Carrier frequency
- Pulse width of the first pulse
- Duty cycle of the second and the subsequent pulses
- Enabling/disabling the carrier function

## Operational Highlights

The PWM carrier clock (PC\_clk) is derived from PWM\_clk. The frequency and duty cycle are configured by the MCPWM\_CARRIERx\_PRESCALE and MCPWM\_CARRIERx\_DUTY bits in the MCPWM\_CARRIERx\_CFG\_REG register. The purpose of one-shot pulses is to provide high-energy impulse to reliably turn on the power switch. Subsequent pulses sustain the power-on status. The width of a one-shot pulse is configurable with the

MCPWM\_CARRIERx\_OSHTWTH field. Enabling/disabling of the carrier module is done with the MCPWM\_CARRIERx\_EN bit.

## Waveform Examples

Figure 36.3-28 shows an example of waveforms, where a carrier is superimposed on original PWM pulses. This figure do not show the first one-shot pulse and the duty-cycle control. Related details are covered in the following two sections.

Figure 36.3-28. Example of Waveforms Showing PWM Carrier Action

![Image](images/36_Chapter_36_img032_165284ae.png)

## One-Shot Pulse

The width of the first pulse can be configured to 16 different values, which can be calculated by the following equation:

<!-- formula-not-decoded -->

TP TPWM \_ clk × 8 × (MCPWM \_ CARRIERx \_ P RESCALE + 1) × (MCPWM \_ CARRIERx \_ OSHTW T H + 1)

## Where:

- TP TPMW \_ clk is the period of the PWM clock (PWM\_clk).
- (MCPWM \_ CARRIERx \_ OSHTW T H + 1) is the width of the first pulse (whose value ranges from 1 to 16).
- (MCPWM \_ CARRIERx \_ P RESCALE + 1) is the PWM carrier clock's (PC\_clk) prescaler value.

The first one-shot pulse and subsequent sustaining pulses are shown in Figure 36.3-29 .

Figure 36.3-29. Example of the First Pulse and the Subsequent Sustaining Pulses of the PWM Carrier Submodule

![Image](images/36_Chapter_36_img033_792f6c09.png)

## Duty Cycle Control

After issuing the first one-shot pulse, the remaining PWM signal is modulated according to the carrier frequency. Users can configure the duty cycle of this signal. Tuning of duty may be required, so that the signal passes through the isolating transformer and can still operate (turn on/off) the motor drive, changing rotation speed and direction.

The duty cycle may be set to one of seven values, using MCPWM\_CARRIERx\_DUTY, or bits [7:5] of register MCPWM\_CARRIERx\_CFG\_REG .

Below is the formula for calculating the duty cycle:

<!-- formula-not-decoded -->

All seven settings of the duty cycle are shown in Figure 36.3-30 .

Figure 36.3-30. Possible Duty Cycle Settings for Sustaining Pulses in the PWM Carrier Submodule

![Image](images/36_Chapter_36_img034_d9263292.png)

## 36.3.3.4 Fault Detection Module

Each MCPWM peripheral is connected to three fault signals (FAULT0, FAULT1, and FAULT2) which are sourced from the GPIO matrix. These signals are intended to indicate external fault conditions, and may be preprocessed by the Fault Detection module to generate fault events. Fault events can then execute the user code to control MCPWM outputs in response to specific faults.

## Function of Fault Detection Module

The key actions performed by the fault detection module are:

- Forcing outputs PWMxA and PWMxB, upon detected fault, to one of the following states:
- – High
- – Low
- – Toggle
- – No action taken
- Execution of one-shot trip (OST) upon detection of over-current conditions/short circuits.
- Cycle-by-cycle trip (CBC) to provide current-limiting operation.
- Allocation of either one-shot or cycle-by-cycle operation for each fault signal.
- Generation of interrupts for each fault input.
- Support for software-force tripping.
- Enabling or disabling of module function as required.

![Image](images/36_Chapter_36_img035_86bc3b26.png)

## Operation and Configuration Tips

This section provides the operational tips and set-up options for the Fault Detection module.

Fault signals coming from pins are sampled and synced in the GPIO matrix. In order to guarantee the successful sampling of fault pulses, each pulse duration must be at least two APB clock cycles. The Fault Detection module will then sample fault signals by using PWM\_clk. So, the duration of fault pulses coming from GPIO matrix must be at least one PWM\_clk cycle. Differently put, regardless of the period relation between APB clock and PWM\_clk, the width of fault signal pulses on pins must be at least equal to the sum of two APB clock cycles and one PWM\_clk cycle.

Each level of fault signals, FAULT0 to FAULT2, can be used by the Fault Detection module to generate fault events (fault\_event0 to fault\_event2). Every fault event can be configured individually to provide CBC action, OST action, or none.

## · Cycle-by-Cycle (CBC) action:

When CBC action is triggered, the state of PWMxA and PWMxB will be changed immediately according to the configuration of fields MCPWM\_FHx\_A\_CBC\_U/D and MCPWM\_FHx\_B\_CBC\_U/D. Different actions can be indicated when the PWM timer is incrementing or decrementing. Different CBC action interrupts can be triggered for different fault events. Status field MCPWM\_FHx\_CBC\_ON indicates whether a CBC action is on or off. When the fault event is no longer present, CBC actions on PWMxA/B will be cleared at a specified point, which is either a D/UTEP or D/UTEZ event. Field MCPWM\_FHx\_CBCPULSE determines at which event PWMxA and PWMxB will be able to resume normal actions. Therefore, in this mode, the CBC action is cleared or refreshed upon every PWM cycle.

## · One-Shot (OST) action:

When OST action is triggered, the state of PWMxA and PWMxB will be changed immediately, depending on the setting of fields MCPWM\_FHx\_A\_OST\_U/D and MCPWM\_FHx\_B\_OST\_U/D. Different actions can be configured when PWM timer is incrementing or decrementing. Different OST action interrupts can be triggered form different fault events. Status field MCPWM\_FHx\_OST\_ON indicates whether an OST action is on or off. The OST actions on PWMxA/B are not automatically cleared when the fault event is no

- longer present. One-shot actions must be cleared manually by setting the MCPWM\_FHx\_CLR\_OST bit.

## 36.3.4 Capture Module

## 36.3.4.1 Introduction

The capture module contains three complete capture channels. Channel inputs CAP0, CAP1, and CAP2 are sourced from the GPIO matrix. Thanks to the flexibility of the GPIO matrix, CAP0, CAP1, and CAP2 can be configured from any pin input. Multiple capture channels can be sourced from the same pin input, while prescaling for each channel can be set differently. Also, capture channels are sourced from different pins. This provides several options for handling capture signals by hardware in the background, instead of having them processed directly by the CPU. A capture module has the following independent key resources:

- One 32-bit timer (counter) which can be synchronized with the PWM timer, another module, or software.
- Three capture channels, each equipped with a 32-bit time-stamp and a capture prescaler.
- Independent edge polarity (rising/falling edge) selection for any capture channel.
- Input capture signal prescaling (from 1 to 256).

- Interrupt capabilities on any of the three capture events.

## 36.3.4.2 Capture Timer

The capture timer is a 32-bit counter incrementing continuously. It is enabled by setting MCPWM\_CAP\_TIMER\_EN to 1. Its operating clock source is MCPWM core clock. When MCPWM\_CAP\_SYNCI\_EN is configured, the counter will be loaded with phase stored in register MCPWM\_CAP\_TIMER\_PHASE\_REG at the time of a sync event. Sync events can select from PWM timers sync-out, or PWM module sync-in by configuring MCPWM\_CAP\_SYNCI\_SEL. Sync events can also be generated by setting MCPWM\_CAP\_SYNC\_SW. The capture timer provides timing references for all three capture channels.

## 36.3.4.3 Capture Channel

The capture signal coming to a capture channel will be inverted first, if needed, and then prescaled. Each capture channel has a prescaler register of MCPWM\_CAPx\_PRESCALE. Finally, specified edges of preprocessed capture signal will trigger capture events. Setting MCPWM\_CAPx\_EN to enable a capture channel. The capture event occurs at the time selected by the MCPWM\_CAPx\_MODE. When a capture event occurs, the capture timer's value is stored in time-stamp register MCPWM\_CAP\_CHx\_REG. Different interrupts can be generated for different capture channels at capture events. The edge that triggers a capture event is recorded in register MCPWM\_CAPx\_EDGE. The capture event can be also forced by software setting MCPWM\_CAPx\_SW .

## 36.3.5 ETM Module

## 36.3.5.1 Overview

The MCPWM peripheral on ESP32-C6 supports the Event Task Matrix (ETM) function, which allows MCPWM's ETM tasks to be triggered by any peripherals' ETM events, or MCPWM's ETM events to trigger any peripherals' ETM tasks. The capture module, the fault detection module, three timers, and three operators can generate events and respond to tasks independently. This section introduces the ETM tasks and events related to MCPWM. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

## 36.3.5.2 MCPWM-Related ETM Events

When setting enable field to 1, after the generation condition is met, the corresponding event would be generated. For details, please refer to Table 36.3-7 below:

Table 36.3-7. MCPWM-Related ETM Events

| Enable Field         | Generation Condition                                           | Event Generated   |
|----------------------|----------------------------------------------------------------|-------------------|
| MCPWM_EVT_CAPx_EN    | CAPx capture event occurs                                      | MCPWM_EVT_CAPx    |
| MCPWM_EVT_TZx_OST_EN | PWM operator x performs a One-Shot trip (OST) operation        | MCPWM_EVT_TZx_OST |
| MCPWM_EVT_TZx_CBC_EN | PWM operator x performs a cycle-by-cycle trip (CBC) operation. | MCPWM_EVT_TZx_CBC |
| MCPWM_EVT_Fx_CLR_EN  | fault event fault_eventx is cleared                            | MCPWM_EVT_Fx_CLR  |

| Enable Field             | Generation Condition                                                                              | Event Generated      |
|--------------------------|---------------------------------------------------------------------------------------------------|----------------------|
| MCPWM_EVT_Fx_EN          | fault event fault_eventx is generated                                                             | MCPWM_EVT_Fx         |
| MCPWM_EVT_OPx_TEB_EN     | the count value of the timer that PWM operator x selects is equal to the value of timer stamp B 1 | MCPWM_EVT_OPx_TEB    |
| MCPWM_EVT_OPx_TEA_EN     | the count value of the timer that PWM operator x selects is equal to the value of timer stamp A 1 | MCPWM_EVT_OPx_TEA    |
| MCPWM_EVT_TIMERx_TEP_EN  | count value of timer x is equal to the period value MCPWM_TIMERx_PERIOD                           | MCPWM_EVT_TIMERx_TEP |
| MCPWM_EVT_TIMERx_TEZ_EN  | count value of timer x is equal to 0                                                              | MCPWM_EVT_TIMERx_TEZ |
| MCPWM_EVT_TIMERx_STOP_EN | timer x’s count stops                                                                             | MCPWM_EVT_OPx_TEA    |

## 36.3.5.3 MCPWM-Related ETM Tasks

When setting the enable field to 1, after inputting valid tasks, the corresponding response operation would be generated. For details, please refer to Table 36.3-8 below:

Table 36.3-8. ETM Related Tasks

| Enable Field                   | Valid Task Input            | Response Operation                                                                                  |
|--------------------------------|-----------------------------|-----------------------------------------------------------------------------------------------------|
| MCPWM_TASK_CAPx_EN             | MCPWM_TASK_CAPx             | CAPx channel performs a capture operation                                                           |
| MCPWM_TASK_CLRx_OST_EN         | MCPWM_TASK_CLRx_OST         | PWM operator x clears the One-Shot Trip operation                                                   |
| MCPWM_TASK_TZx_OST_EN          | MCPWM_TASK_TZx_OST          | PWM operator x performs a One-Shot Trip (OST) operation                                             |
| MCPWM_TASK_TIMERx_PERIOD_UP_EN | MCPWM_TASK_TIMERx_PERIOD_UP | the period of timer x is updated to the value configured in the period register MCPWM_TIMERx_PERIOD |
| MCPWM_TASK_TIMERx_SYNC_EN      | MCPWM_TASK_TIMERx_SYN       | timer x performs a sync operation                                                                   |
| MCPWM_TASK_GEN_STOP_EN         | MCPWM_TASK_GEN_STOP         | all the timers stop counting and the PWM signals output by all PWM operators remain unchanged       |
| MCPWM_TASK_CMPRx_B_UP_EN       | MCPWM_TASK_CMPRx_B_UP       | timer stamp B of the PWM operator x is updated to the value of the shadow register MCPWM_GENx_B     |

| Enable Field             | Valid Task Input      | Response Operation                                                                              |
|--------------------------|-----------------------|-------------------------------------------------------------------------------------------------|
| MCPWM_TASK_CMPRx_A_UP_EN | MCPWM_TASK_CMPRx_A_UP | timer stamp A of the PWM operator x is updated to the value of the shadow register MCPWM_GENx_A |

## 36.4 Register Summary

The addresses in this section are relative to Motor Control PWM base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                      | Description                                                             | Address                                   | Access                                    |
|-------------------------------------------|-------------------------------------------------------------------------|-------------------------------------------|-------------------------------------------|
| Prescaler Configuration                   |                                                                         |                                           |                                           |
| MCPWM_CLK_CFG_REG                         | PWM clock prescaler register                                            | 0x0000                                    | R/W                                       |
| MCPWM Timer 0 Configuration and Status    | MCPWM Timer 0 Configuration and Status                                  | MCPWM Timer 0 Configuration and Status    | MCPWM Timer 0 Configuration and Status    |
| MCPWM_TIMER0_CFG0_REG                     | PWM timer0 period and update method config uration register            | 0x0004                                    | R/W                                       |
| MCPWM_TIMER0_CFG1_REG                     | PWM timer0 working mode and start/stop con trol configuration register | 0x0008                                    | varies                                    |
| MCPWM_TIMER0_SYNC_REG                     | PWM timer0 sync function configuration regis ter                       | 0x000C                                    | R/W                                       |
| MCPWM_TIMER0_STATUS_REG                   | PWM timer0 status register                                              | 0x0010                                    | RO                                        |
| MCPWM Timer 1 Configuration and Status    | MCPWM Timer 1 Configuration and Status                                  | MCPWM Timer 1 Configuration and Status    | MCPWM Timer 1 Configuration and Status    |
| MCPWM_TIMER1_CFG0_REG                     | PWM timer1 period and update method config uration register            | 0x0014                                    | R/W                                       |
| MCPWM_TIMER1_CFG1_REG                     | PWM timer1 working mode and start/stop con trol configuration register | 0x0018                                    | varies                                    |
| MCPWM_TIMER1_SYNC_REG                     | PWM timer1 sync function configuration register                         | 0x001C                                    | R/W                                       |
| MCPWM_TIMER1_STATUS_REG                   | PWM timer1 status register                                              | 0x0020                                    | RO                                        |
| MCPWM Timer 2 Configuration and status    | MCPWM Timer 2 Configuration and status                                  | MCPWM Timer 2 Configuration and status    | MCPWM Timer 2 Configuration and status    |
| MCPWM_TIMER2_CFG0_REG                     | PWM timer2 period and update method config uration register            | 0x0024                                    | R/W                                       |
| MCPWM_TIMER2_CFG1_REG                     | PWM timer2 working mode and start/stop con trol configuration register | 0x0028                                    | varies                                    |
| MCPWM_TIMER2_SYNC_REG                     | PWM timer2 sync function configuration regis ter                       | 0x002C                                    | R/W                                       |
| MCPWM_TIMER2_STATUS_REG                   | PWM timer2 status register                                              | 0x0030                                    | RO                                        |
| Common Configuration for MCPWM Timers     | Common Configuration for MCPWM Timers                                   | Common Configuration for MCPWM Timers     | Common Configuration for MCPWM Timers     |
| MCPWM_TIMER_SYNCI_CFG_REG                 | Synchronization input selection for three PWM timers                    | 0x0034                                    | R/W                                       |
| MCPWM_OPERATOR_TIMERSEL_REG               | Select specific timer for PWM operators                                 | 0x0038                                    | R/W                                       |
| MCPWM Operator 0 Configuration and Status | MCPWM Operator 0 Configuration and Status                               | MCPWM Operator 0 Configuration and Status | MCPWM Operator 0 Configuration and Status |
| MCPWM_GEN0_STMP_CFG_REG                   | Transfer status and update method for time stamp registers A and B      | 0x003C                                    | varies                                    |
| MCPWM_GEN0_TSTMP_A_REG                    | Shadow register for register A                                          | 0x0040                                    | R/W                                       |
| MCPWM_GEN0_TSTMP_B_REG                    | Shadow register for register B                                          | 0x0044                                    | R/W                                       |
| MCPWM_GEN0_CFG0_REG                       | Fault event T0 and T1 handling                                          | 0x0048                                    | R/W                                       |
| MCPWM_GEN0_FORCE_REG                      | Permissives to force PWM0A and PWM0B out puts by software              | 0x004C                                    | R/W                                       |

| Name                                      | Description                                                        | Address                                   | Access                                    |
|-------------------------------------------|--------------------------------------------------------------------|-------------------------------------------|-------------------------------------------|
| MCPWM_GEN0_A_REG                          | Actions triggered by events on PWM0A                               | 0x0050                                    | R/W                                       |
| MCPWM_GEN0_B_REG                          | Actions triggered by events on PWM0B                               | 0x0054                                    | R/W                                       |
| MCPWM_DT0_CFG_REG                         | Dead time type selection and configuration                         | 0x0058                                    | R/W                                       |
| MCPWM_DT0_FED_CFG_REG                     | Shadow register for falling edge delay (FED)                       | 0x005C                                    | R/W                                       |
| MCPWM_DT0_RED_CFG_REG                     | Shadow register for rising edge delay (RED)                        | 0x0060                                    | R/W                                       |
| MCPWM_CARRIER0_CFG_REG                    | Carrier enable and configuration                                   | 0x0064                                    | R/W                                       |
| MCPWM_FH0_CFG0_REG                        | Actions on PWM0A and PWM0B trip events                             | 0x0068                                    | R/W                                       |
| MCPWM_FH0_CFG1_REG                        | Software triggers for fault handler actions                        | 0x006C                                    | R/W                                       |
| MCPWM_FH0_STATUS_REG                      | Status of fault events                                             | 0x0070                                    | RO                                        |
| MCPWM Operator 1 Configuration and Status | MCPWM Operator 1 Configuration and Status                          | MCPWM Operator 1 Configuration and Status | MCPWM Operator 1 Configuration and Status |
| MCPWM_GEN1_STMP_CFG_REG                   | Transfer status and update method for time stamp registers A and B | 0x0074                                    | varies                                    |
| MCPWM_GEN1_TSTMP_A_REG                    | Shadow register for register A                                     | 0x0078                                    | R/W                                       |
| MCPWM_GEN1_TSTMP_B_REG                    | Shadow register for register B                                     | 0x007C                                    | R/W                                       |
| MCPWM_GEN1_CFG0_REG                       | Fault event T0 and T1 handling                                     | 0x0080                                    | R/W                                       |
| MCPWM_GEN1_FORCE_REG                      | Permissives to force PWM1A and PWM1B out puts by software         | 0x0084                                    | R/W                                       |
| MCPWM_GEN1_A_REG                          | Actions triggered by events on PWM1A                               | 0x0088                                    | R/W                                       |
| MCPWM_GEN1_B_REG                          | Actions triggered by events on PWM1B                               | 0x008C                                    | R/W                                       |
| MCPWM_DT1_CFG_REG                         | Dead time type selection and configuration                         | 0x0090                                    | R/W                                       |
| MCPWM_DT1_FED_CFG_REG                     | Shadow register for falling edge delay (FED)                       | 0x0094                                    | R/W                                       |
| MCPWM_DT1_RED_CFG_REG                     | Shadow register for rising edge delay (RED)                        | 0x0098                                    | R/W                                       |
| MCPWM_CARRIER1_CFG_REG                    | Carrier enable and configuration                                   | 0x009C                                    | R/W                                       |
| MCPWM_FH1_CFG0_REG                        | Actions on PWM1A and PWM1B trip events                             | 0x00A0                                    | R/W                                       |
| MCPWM_FH1_CFG1_REG                        | Software triggers for fault handler actions                        | 0x00A4                                    | R/W                                       |
| MCPWM_FH1_STATUS_REG                      | Status of fault events                                             | 0x00A8                                    | RO                                        |
| MCPWM Operator 2 Configuration and Status | MCPWM Operator 2 Configuration and Status                          | MCPWM Operator 2 Configuration and Status | MCPWM Operator 2 Configuration and Status |
| MCPWM_GEN2_STMP_CFG_REG                   | Transfer status and update method for time stamp registers A and B | 0x00AC                                    | varies                                    |
| MCPWM_GEN2_TSTMP_A_REG                    | Shadow register for register A                                     | 0x00B0                                    | R/W                                       |
| MCPWM_GEN2_TSTMP_B_REG                    | Shadow register for register B                                     | 0x00B4                                    | R/W                                       |
| MCPWM_GEN2_CFG0_REG                       | Fault event T0 and T1 handling                                     | 0x00B8                                    | R/W                                       |
| MCPWM_GEN2_FORCE_REG                      | Permissives to force PWM2A and PWM2B out puts by software         | 0x00BC                                    | R/W                                       |
| MCPWM_GEN2_A_REG                          | Actions triggered by events on PWM2A                               | 0x00C0                                    | R/W                                       |
| MCPWM_GEN2_B_REG                          | Actions triggered by events on PWM2B                               | 0x00C4                                    | R/W                                       |
| MCPWM_DT2_CFG_REG                         | Dead time type selection and configuration                         | 0x00C8                                    | R/W                                       |
| MCPWM_DT2_FED_CFG_REG                     | Shadow register for falling edge delay (FED)                       | 0x00CC                                    | R/W                                       |
| MCPWM_DT2_RED_CFG_REG                     | Shadow register for rising edge delay (RED)                        | 0x00D0                                    | R/W                                       |
| MCPWM_CARRIER2_CFG_REG                    | Carrier enable and configuration                                   | 0x00D4                                    | R/W                                       |
| MCPWM_FH2_CFG0_REG                        | Actions on PWM2A and PWM2B trip events                             | 0x00D8                                    | R/W                                       |
| MCPWM_FH2_CFG1_REG                        | Software triggers for fault handler actions                        | 0x00DC                                    | R/W                                       |
| MCPWM_FH2_STATUS_REG                      | Status of fault events                                             | 0x00E0                                    | RO                                        |

| Name                                     | Description                                | Address                                  | Access                                   |
|------------------------------------------|--------------------------------------------|------------------------------------------|------------------------------------------|
| Fault Detection Configuration and Status | Fault Detection Configuration and Status   | Fault Detection Configuration and Status | Fault Detection Configuration and Status |
| MCPWM_FAULT_DETECT_REG                   | Fault detection configuration and status   | 0x00E4                                   | varies                                   |
| Capture Configuration and Status         | Capture Configuration and Status           | Capture Configuration and Status         | Capture Configuration and Status         |
| MCPWM_CAP_TIMER_CFG_REG                  | Configure capture timer                    | 0x00E8                                   | varies                                   |
| MCPWM_CAP_TIMER_PHASE_REG                | Phase for capture timer sync               | 0x00EC                                   | R/W                                      |
| MCPWM_CAP_CH0_CFG_REG                    | Capture channel 0 configuration and enable | 0x00F0                                   | varies                                   |
| MCPWM_CAP_CH1_CFG_REG                    | Capture channel 1 configuration and enable | 0x00F4                                   | varies                                   |
| MCPWM_CAP_CH2_CFG_REG                    | Capture channel 2 configuration and enable | 0x00F8                                   | varies                                   |
| MCPWM_CAP_CH0_REG                        | ch0 capture value status register          | 0x00FC                                   | RO                                       |
| MCPWM_CAP_CH1_REG                        | ch1 capture value status register          | 0x0100                                   | RO                                       |
| MCPWM_CAP_CH2_REG                        | ch2 capture value status register          | 0x0104                                   | RO                                       |
| MCPWM_CAP_STATUS_REG                     | Edge of last capture trigger               | 0x0108                                   | RO                                       |
| Enable Update of Active Registers        | Enable Update of Active Registers          | Enable Update of Active Registers        | Enable Update of Active Registers        |
| MCPWM_UPDATE_CFG_REG                     | Enable update                              | 0x010C                                   | R/W                                      |
| Manage Interrupts                        | Manage Interrupts                          | Manage Interrupts                        | Manage Interrupts                        |
| MCPWM_INT_ENA_REG                        | Interrupt enable bits                      | 0x0110                                   | R/W                                      |
| MCPWM_INT_RAW_REG                        | Raw interrupt status                       | 0x0114                                   | R/WTC /SS                                |
| MCPWM_INT_ST_REG                         | Masked interrupt status                    | 0x0118                                   | RO                                       |
| MCPWM_INT_CLR_REG                        | Interrupt clear bits                       | 0x011C                                   | WT                                       |
| MCPWM Event Enable Register              | MCPWM Event Enable Register                | MCPWM Event Enable Register              | MCPWM Event Enable Register              |
| MCPWM_EVT_EN_REG                         | MCPWM event enable register                | 0x0120                                   | R/W                                      |
| MCPWM Task Enable Register               | MCPWM Task Enable Register                 | MCPWM Task Enable Register               | MCPWM Task Enable Register               |
| MCPWM_TASK_EN_REG                        | MCPWM task enable register                 | 0x0124                                   | R/W                                      |
| MCPWM APB Configuration Register         | MCPWM APB Configuration Register           | MCPWM APB Configuration Register         | MCPWM APB Configuration Register         |
| MCPWM_CLK_REG                            | MCPWM APB configuration register           | 0x0128                                   | R/W                                      |
| Version Register                         | Version Register                           | Version Register                         | Version Register                         |
| MCPWM_VERSION_REG                        | Version register                           | 0x012C                                   | R/W                                      |

## 36.5 Registers

The addresses in this section are relative to Motor Control PWM base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 36.1. MCPWM\_CLK\_CFG\_REG (0x0000)

![Image](images/36_Chapter_36_img036_a473296e.png)

MCPWM\_CLK\_PRESCALE Configures the prescaler value of clock, so that the period of PWM\_CLK = 6.25ns * (PWM\_CLK\_PRESCALE + 1). (R/W)

Register 36.2. MCPWM\_TIMER0\_CFG0\_REG (0x0004)

![Image](images/36_Chapter_36_img037_be01c1be.png)

MCPWM\_TIMER0\_PRESCALE Configures the prescaler value of timer0, so that the period of PT0\_CLK = Period of PWM\_CLK * (PWM\_TIMER0\_PRESCALE + 1). (R/W)

MCPWM\_TIMER0\_PERIOD Configures the period shadow register of PWM timer0. (R/W)

MCPWM\_TIMER0\_PERIOD\_UPMETHOD Configures the update method for active register of PWM timer0 period.

0: Immediate

1: TEZ

2: sync

- 3: TEZ | sync

TEZ here and below means timer equal zero event. (R/W)

## Register 36.3. MCPWM\_TIMER0\_CFG1\_REG (0x0008)

![Image](images/36_Chapter_36_img038_1d8cac48.png)

MCPWM\_TIMER0\_START Configures whether or not to start/stop PWM timer0.

- 0: If PWM timer0 starts, then stops at TEZ
- 1: If timer0 starts, then stops at TEP
- 2: PWM timer0 starts and runs on
- 3: Timer0 starts and stops at the next TEZ
- 4: Timer0 starts and stops at the next TEP
- 5: Invalid. No effect
- 6: Invalid. No effect
- 7: Invalid. No effect
- TEP here and below means the event that happens when the timer equals to period. (R/W/SC)

## MCPWM\_TIMER0\_MOD Configures the working mode of PWM timer0.

- 0: Freeze
- 1: Increase mode
- 2: Decrease mode
- 3: Up-down mode
- (R/W)

Register 36.4. MCPWM\_TIMER0\_SYNC\_REG (0x000C)

![Image](images/36_Chapter_36_img039_cd42448a.png)

MCPWM\_TIMER0\_SYNCI\_EN Configures whether or not to enable timer reloading with phase on sync input event.

0: Disable

1: Enable

(R/W)

MCPWM\_TIMER0\_SYNC\_SW Toggling this bit will trigger a software sync. (R/W)

MCPWM\_TIMER0\_SYNCO\_SEL PWM timer0 sync out selection.

0: sync\_in. The sync out will always generate when toggling the MCPWM\_TIMER0\_SYNC\_SW bit.

1: TEZ

2: TEP

3: No effect

(R/W)

MCPWM\_TIMER0\_PHASE Phase for timer reload on sync event. (R/W)

MCPWM\_TIMER0\_PHASE\_DIRECTION Configures the PWM timer0’s direction when timer0 mode is up-down mode.

0: Increase

1: Decrease

(R/W)

![Image](images/36_Chapter_36_img040_14749c42.png)

Register 36.5. MCPWM\_TIMER0\_STATUS\_REG (0x0010)

![Image](images/36_Chapter_36_img041_813a486f.png)

MCPWM\_TIMER0\_VALUE Represents current PWM timer0 counter value. (RO)

MCPWM\_TIMER0\_DIRECTION Represents current PWM timer0 counter direction.

0: Increment

1: Decrement

(RO)

Register 36.6. MCPWM\_TIMER1\_CFG0\_REG (0x0014)

![Image](images/36_Chapter_36_img042_646b9bf6.png)

MCPWM\_TIMER1\_PRESCALE Configures the prescaler value of timer1, so that the period of PT0\_CLK = Period of PWM\_CLK * (PWM\_timer1\_PRESCALE + 1). (R/W)

MCPWM\_TIMER1\_PERIOD Period shadow register of PWM timer1. (R/W)

MCPWM\_TIMER1\_PERIOD\_UPMETHOD Configures the update method for active register of PWM

timer1 period.

0: Immediate

1: TEZ

2: Sync

3: TEZ | sync

TEZ here and below means timer equal zero event. (R/W)

## Register 36.7. MCPWM\_TIMER1\_CFG1\_REG (0x0018)

![Image](images/36_Chapter_36_img043_9876b7c6.png)

MCPWM\_TIMER1\_START Configures whether or not to start/stop PWM timer1.

- 0: If PWM timer1 starts, then stops at TEZ
- 1: If timer1 starts, then stops at TEP
- 2: PWM timer1 starts and runs on
- 3: Timer1 starts and stops at the next TEZ
- 4: Timer1 starts and stops at the next TEP
- 5-7: Invalid. No effect

TEP here and below means the event that happens when the timer equals to period.

(R/W/SC)

MCPWM\_TIMER1\_MOD Configures the working mode of PWM timer1.

- 0: Freeze
- 1: Increase mode
- 2: Decrease mode
- 3: Up-down mode

(R/W)

Register 36.8. MCPWM\_TIMER1\_SYNC\_REG (0x001C)

![Image](images/36_Chapter_36_img044_f371a3fc.png)

MCPWM\_TIMER1\_SYNCI\_EN Configures whether or not to enable timer reloading with phase on sync input event.

0: Disable

1: Enable

(R/W)

MCPWM\_TIMER1\_SYNC\_SW Toggling this bit will trigger a software sync. (R/W)

MCPWM\_TIMER1\_SYNCO\_SEL Configures PWM timer1 sync out selection.

0: sync\_in

1: TEZ

2: TEP, and sync out will always generate when toggling the reg\_timer1\_sync\_sw bit.

3: No effect

(R/W)

MCPWM\_TIMER1\_PHASE Phase for timer reload on sync event. (R/W)

MCPWM\_TIMER1\_PHASE\_DIRECTION Configures the PWM timer1’s direction when timer1 is in up-

down mode.

0: Increase

1: Decrease

(R/W)

Register 36.9. MCPWM\_TIMER1\_STATUS\_REG (0x0020)

![Image](images/36_Chapter_36_img045_b3dcf7d6.png)

MCPWM\_TIMER1\_VALUE Represents current PWM timer1 counter value. (RO)

MCPWM\_TIMER1\_DIRECTION Represents current PWM timer1 counter direction.

0: Increment

1: Decrement

(RO)

## Register 36.10. MCPWM\_TIMER2\_CFG0\_REG (0x0024)

![Image](images/36_Chapter_36_img046_527fdaf3.png)

MCPWM\_TIMER2\_PRESCALE Configures the prescaler value of timer2, so that the period of PT0\_CLK = Period of PWM\_CLK * (PWM\_timer2\_PRESCALE + 1). (R/W)

MCPWM\_TIMER2\_PERIOD Period shadow register of PWM timer2. (R/W)

MCPWM\_TIMER2\_PERIOD\_UPMETHOD Configures the update method for active register of PWM timer2 period.

0: Immediate

1: TEZ

2: Sync

3: TEZ | sync

TEZ here and below means timer equal zero event. (R/W)

## Register 36.11. MCPWM\_TIMER2\_CFG1\_REG (0x0028)

![Image](images/36_Chapter_36_img047_9d99718f.png)

MCPWM\_TIMER2\_START Configures whether or not to start/stop PWM timer2.

- 0: If PWM timer2 starts, then stops at TEZ
- 1: If timer2 starts, then stops at TEP
- 2: PWM timer2 starts and runs on
- 3: Timer2 starts and stops at the next TEZ
- 4: Timer2 starts and stops at the next TEP
- 5: Invalid. No effect
- 6: Invalid. No effect
- 7: Invalid. No effect
- TEP here and below means the event that happens when the timer equals to period. (R/W/SC)

## MCPWM\_TIMER2\_MOD Configures the working mode of PWM timer2.

- 0: Freeze
- 1: Increase mode
- 2: Decrease mode
- 3: Up-down mode
- (R/W)

Register 36.12. MCPWM\_TIMER2\_SYNC\_REG (0x002C)

![Image](images/36_Chapter_36_img048_dab84c0f.png)

MCPWM\_TIMER2\_SYNCI\_EN Configures whether or not to enable timer reloading with phase on

sync input event.

0: Disable

1: Enable

(R/W)

MCPWM\_TIMER2\_SYNC\_SW Toggling this bit will trigger a software sync. (R/W)

MCPWM\_TIMER2\_SYNCO\_SEL PWM timer2 sync out selection.

0: sync\_in

1: TEZ

2: TEP, and sync out will always generate when toggling the reg\_timer0\_sync\_sw bit

3: No effect

(R/W)

MCPWM\_TIMER2\_PHASE Configures phase for timer reload on sync event. (R/W)

MCPWM\_TIMER2\_PHASE\_DIRECTION Configures the PWM timer2’s direction when timer2 is in up-

down mode.

0: Increase

1: Decrease

(R/W)

Register 36.13. MCPWM\_TIMER2\_STATUS\_REG (0x0030)

![Image](images/36_Chapter_36_img049_2b8a4302.png)

MCPWM\_TIMER2\_VALUE Represents current PWM timer2 counter value. (RO)

MCPWM\_TIMER2\_DIRECTION Represents current PWM timer2 counter direction.

0: Increment

1: Decrement

(RO)

## Register 36.14. MCPWM\_TIMER\_SYNCI\_CFG\_REG (0x0034)

![Image](images/36_Chapter_36_img050_b89bfd16.png)

## MCPWM\_TIMER0\_SYNCISEL Configures sync input for PWM timer0.

- 1: PWM timer0 sync out
- 2: PWM timer1 sync out
- 3: PWM timer2 sync out
- 4: SYNC0 from GPIO matrix
- 5: SYNC1 from GPIO matrix
- 6: SYNC2 from GPIO matrix

Other values: no sync input selected

- (R/W)

## MCPWM\_TIMER1\_SYNCISEL Select sync input for PWM timer1.

- 1: PWM timer0 sync out
- 2: PWM timer1 sync out
- 3: PWM timer2 sync out
- 4: SYNC0 from GPIO matrix
- 5: SYNC1 from GPIO matrix
- 6: SYNC2 from GPIO matrix

Other values: no sync input selected

- (R/W)

## MCPWM\_TIMER2\_SYNCISEL Select sync input for PWM timer2.

- 1: PWM timer0 sync out
- 2: PWM timer1 sync out
- 3: PWM timer2 sync out
- 4: SYNC0 from GPIO matrix
- 5: SYNC1 from GPIO matrix
- 6: SYNC2 from GPIO matrix
- Other values: no sync input selected
- (R/W)

MCPWM\_EXTERNAL\_SYNCI0\_INVERT Invert SYNC0 from GPIO matrix. (R/W)

MCPWM\_EXTERNAL\_SYNCI1\_INVERT Invert SYNC1 from GPIO matrix. (R/W)

MCPWM\_EXTERNAL\_SYNCI2\_INVERT Invert SYNC2 from GPIO matrix. (R/W)

## Register 36.15. MCPWM\_OPERATOR\_TIMERSEL\_REG (0x0038)

![Image](images/36_Chapter_36_img051_c94d97f7.png)

MCPWM\_OPERATOR0\_TIMERSEL Configures which PWM timer will be the timing reference for PWM operator0.

- 0: timer0
- 1: timer1
- 2: timer2
- 3: Invalid
- (R/W)
- MCPWM\_OPERATOR1\_TIMERSEL Configures which PWM timer will be the timing reference for PWM

operator1.

- 0: timer0
- 1: timer1
- 2: timer2
- 3: Invalid
- (R/W)

MCPWM\_OPERATOR2\_TIMERSEL Configures which PWM timer will be the timing reference for PWM operator2.

- 0: timer0
- 1: timer1
- 2: timer2
- 3: Invalid
- (R/W)

## Register 36.16. MCPWM\_GEN0\_STMP\_CFG\_REG (0x003C)

![Image](images/36_Chapter_36_img052_fc611357.png)

MCPWM\_GEN0\_A\_UPMETHOD Configures the update method for PWM generator 0 time stamp

A’s active register.

When all bits are set to 0: Immediately

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

When bit2 is set to 1: Sync

When bit3 is set to 1: Disable the update

(R/W)

MCPWM\_GEN0\_B\_UPMETHOD Configures the update method for PWM generator 0 time stamp

B’s active register. (R/W)

When all bits are set to 0: Immediately

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

When bit2 is set to 1: Sync

When bit3 is set to 1: Disable the update

(R/W)

MCPWM\_GEN0\_A\_SHDW\_FULL Set and reset by hardware.

- 0: A’s active reg has been updated with shadow register latest value.
- 1: PWM generator 0 time stamp A's shadow reg is filled and waiting to be transferred to A's active reg.

(R/SC/WTC)

MCPWM\_GEN0\_B\_SHDW\_FULL Set and reset by hardware.

- 0: B’s active reg has been updated with shadow register latest value.
- 1: PWM generator 0 time stamp B's shadow reg is filled and waiting to be transferred to B's active reg.

(R/SC/WTC)

Register 36.17. MCPWM\_GEN0\_TSTMP\_A\_REG (0x0040)

![Image](images/36_Chapter_36_img053_a79087a3.png)

MCPWM\_GEN0\_A Shadow register for PWM generator 0 time stamp A. (R/W)

Register 36.18. MCPWM\_GEN0\_TSTMP\_B\_REG (0x0044)

![Image](images/36_Chapter_36_img054_4d4261c4.png)

MCPWM\_GEN0\_B Shadow register for PWM generator 0 time stamp B. (R/W)

## Register 36.19. MCPWM\_GEN0\_CFG0\_REG (0x0048)

![Image](images/36_Chapter_36_img055_8825972b.png)

MCPWM\_GEN0\_CFG\_UPMETHOD Configures update method for PWM generator 0’s active regis- ter.

When all bits are set to 0: Immediately

When bit0 is set to 1: TEZ

- When bit1 is set to 1: TEP

When bit2 is set to 1: Sync

When bit3 is set to 1: Disable the update

(R/W)

MCPWM\_GEN0\_T0\_SEL Configures source selection for PWM generator 0 event\_t0, take effect immediately.

0: fault\_event0

1: fault\_event1

2: fault\_event2

- 3: sync\_taken

4: None

(R/W)

MCPWM\_GEN0\_T1\_SEL Configures source selection for PWM generator 0 event\_t1, take effect immediately

- 0: fault\_event0

1: fault\_event1

- 2: fault\_event2
- 3: sync\_taken
- 4: None

(R/W)

## Register 36.20. MCPWM\_GEN0\_FORCE\_REG (0x004C)

![Image](images/36_Chapter_36_img056_97559c9b.png)

MCPWM\_GEN0\_CNTUFORCE\_UPMETHOD Configures update method for continuous software force of PWM generator0.

When all bits are set to 0: Immediately

When bit0 is set to 1: TEZ

- When bit1 is set to 1: TEP
- When bit2 is set to 1: TEA
- When bit3 is set to 1: TEB
- When bit4 is set to 1: Sync
- When bit5 is set to 1: Disable update

TEA/B means an event generated when the timer's value equals to that of register A/B. (R/W)

MCPWM\_GEN0\_A\_CNTUFORCE\_MODE Configures continuous software force mode for PWM0A.

- 0: Disabled
- 1: Low
- 2: High
- 3: Disabled
- (R/W)

MCPWM\_GEN0\_B\_CNTUFORCE\_MODE Configures continuous software force mode for PWM0B. See details in MCPWM\_GEN0\_A\_CNTUFORCE\_MODE. (R/W)

MCPWM\_GEN0\_A\_NCIFORCE Configures whether or not to trigger a non-continuous immediate software-force event for PWM0A.

- 0: No effect
- 1: Trigger a force event
- (R/W)

MCPWM\_GEN0\_A\_NCIFORCE\_MODE Configures non-continuous immediate software force mode for PWM0A.

- 0: Disabled
- 1: Low
- 2: High
- 3: Disabled
- (R/W)

Continued on the next page...

## Register 36.20. MCPWM\_GEN0\_FORCE\_REG (0x004C)

## Continued from the previous page...

MCPWM\_GEN0\_B\_NCIFORCE Configures whether or not to trigger a non-continuous immediate software-force event for PWM0B.

- 0: No effect
- 1: Trigger a force event

(R/W)

MCPWM\_GEN0\_B\_NCIFORCE\_MODE Configures non-continuous immediate software force mode for PWM0B. See details in MCPWM\_GEN0\_A\_NCIFORCE\_MODE. (R/W)

## Register 36.21. MCPWM\_GEN0\_A\_REG (0x0050)

![Image](images/36_Chapter_36_img057_e01a4203.png)

MCPWM\_GEN0\_A\_UTEZ Configures action on PWM0A triggered by event TEZ when timer increas- ing.

0: No change

1: Low

2: High

3: Toggle

(R/W)

- MCPWM\_GEN0\_A\_UTEP Configures action on PWM0A triggered by event TEP when timer increasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_UTEA Configures action on PWM0A triggered by event TEA when timer increasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_UTEB Configures action on PWM0A triggered by event TEB when timer increasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_UT0 Configures action on PWM0A triggered by event\_t0 when timer increasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_UT1 Configures action on PWM0A triggered by event\_t1 when timer increasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_DTEZ Configures action on PWM0A triggered by event TEZ when timer decreasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_DTEP Configures action on PWM0A triggered by event TEP when timer decreasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_DTEA Configures action on PWM0A triggered by event TEA when timer decreasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_DTEB Configures action on PWM0A triggered by event TEB when timer decreasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_DT0 Configures action on PWM0A triggered by event\_t0 when timer decreasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)
- MCPWM\_GEN0\_A\_DT1 Configures action on PWM0A triggered by event\_t1 when timer decreasing. See details in MCPWM\_GEN0\_A\_UTEZ. (R/W)

## Register 36.22. MCPWM\_GEN0\_B\_REG (0x0054)

![Image](images/36_Chapter_36_img058_7cabd221.png)

MCPWM\_GEN0\_B\_UTEZ Configures action on PWM0B triggered by event TEZ when timer increas- ing.

0: No change

1: Low.

2: High.

3: Toggle

(R/W)

- MCPWM\_GEN0\_B\_UTEP Configures action on PWM0B triggered by event TEP when timer increasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)

MCPWM\_GEN0\_B\_UTEA Configures action on PWM0B triggered by event TEA when timer increasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)

- MCPWM\_GEN0\_B\_UTEB Configures action on PWM0B triggered by event TEB when timer increasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)
- MCPWM\_GEN0\_B\_UT0 Configures action on PWM0B triggered by event\_t0 when timer increasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)
- MCPWM\_GEN0\_B\_UT1 Configures action on PWM0B triggered by event\_t1 when timer increasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)
- MCPWM\_GEN0\_B\_DTEZ Configures action on PWM0B triggered by event TEZ when timer decreasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)
- MCPWM\_GEN0\_B\_DTEP Configures action on PWM0B triggered by event TEP when timer decreasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)
- MCPWM\_GEN0\_B\_DTEA Configures action on PWM0B triggered by event TEA when timer decreasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)
- MCPWM\_GEN0\_B\_DTEB Configures action on PWM0B triggered by event TEB when timer decreasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)
- MCPWM\_GEN0\_B\_DT0 Configures action on PWM0B triggered by event\_t0 when timer decreasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)
- MCPWM\_GEN0\_B\_DT1 Configures action on PWM0B triggered by event\_t1 when timer decreasing. See details in MCPWM\_GEN0\_B\_UTEZ. (R/W)

Register 36.23. MCPWM\_DT0\_CFG\_REG (0x0058)

![Image](images/36_Chapter_36_img059_f87787f7.png)

MCPWM\_DT0\_FED\_UPMETHOD Configures update method for FED active register.

0: Immediate

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

When bit2 is set to 1: sync

When bit3 is set to 1: disable the update (R/W)

MCPWM\_DT0\_RED\_UPMETHOD Update method for RED active register. See details in MCPWM\_DT0\_FED\_UPMETHOD. (R/W)

MCPWM\_DT0\_DEB\_MODE S8 in table 36.3-5, dual-edge B mode.

0: FED/RED take effect on different path separately

1: FED/RED take effect on B path, A out is in bypass or dulpB mode

(R/W)

MCPWM\_DT0\_A\_OUTSWAP S6 in table 36.3-5. (R/W)

MCPWM\_DT0\_B\_OUTSWAP S7 in table 36.3-5. (R/W)

MCPWM\_DT0\_RED\_INSEL S4 in table 36.3-5. (R/W)

MCPWM\_DT0\_FED\_INSEL S5 in table 36.3-5. (R/W)

MCPWM\_DT0\_RED\_OUTINVERT S2 in table 36.3-5. (R/W)

MCPWM\_DT0\_FED\_OUTINVERT S3 in table 36.3-5. (R/W)

MCPWM\_DT0\_A\_OUTBYPASS S1 in table 36.3-5. (R/W)

MCPWM\_DT0\_B\_OUTBYPASS S0 in table 36.3-5. (R/W)

MCPWM\_DT0\_CLK\_SEL Configures dead time generator 0 clock selection.

0: PWM\_CLK

1: PT\_CLK

(R/W)

Register 36.24. MCPWM\_DT0\_FED\_CFG\_REG (0x005C)

![Image](images/36_Chapter_36_img060_4887a0b6.png)

MCPWM\_DT0\_FED Shadow register for FED. (R/W)

Register 36.25. MCPWM\_DT0\_RED\_CFG\_REG (0x0060)

![Image](images/36_Chapter_36_img061_b18af03a.png)

MCPWM\_DT0\_RED Shadow register for RED. (R/W)

Register 36.26. MCPWM\_CARRIER0\_CFG\_REG (0x0064)

![Image](images/36_Chapter_36_img062_edb581ea.png)

MCPWM\_CARRIER0\_EN Configures whether or not to enable carrier0.

0: Bypass

1: Enable

(R/W)

MCPWM\_CARRIER0\_PRESCALE Configures the prescale value of PWM carrier0 clock (PC\_CLK), so that period of PC\_CLK = period of PWM\_CLK * (PWM\_CARRIER0\_PRESCALE + 1). (R/W)

MCPWM\_CARRIER0\_DUTY Configures carrier duty selection. Duty = PWM\_CARRIER0\_DUTY/8. (R/W)

MCPWM\_CARRIER0\_OSHTWTH Configures width of the first pulse in number of periods of the carrier. (R/W)

MCPWM\_CARRIER0\_OUT\_INVERT Configures whether or not to invert the output of PWM0A and PWM0B for this submodule.

0: No effect

1: Invert

(R/W)

MCPWM\_CARRIER0\_IN\_INVERT Configures whether or not to invert the input of PWM0A and PWM0B for this submodule.

0: No effect

1: Invert

(R/W)

## Register 36.27. MCPWM\_FH0\_CFG0\_REG (0x0068)

![Image](images/36_Chapter_36_img063_98879151.png)

MCPWM\_FH0\_SW\_CBC Configures whether or not to enable software force cycle-by-cycle mode action.

0: Disable

1: Enable

(R/W)

MCPWM\_FH0\_F2\_CBC Configures whether or not fault\_event2 will trigger cycle-by-cycle mode action.

0: Disable

1: Enable

(R/W)

MCPWM\_FH0\_F1\_CBC Configures whether or not fault\_event1 will trigger cycle-by-cycle mode action. See details in MCPWM\_FH0\_F2\_CBC. (R/W)

MCPWM\_FH0\_F0\_CBC Configures whether or not fault\_event0 will trigger cycle-by-cycle mode action. See details in MCPWM\_FH0\_F2\_CBC. (R/W)

MCPWM\_FH0\_SW\_OST Configures whether or not to enable software force one-shot mode action. See details in MCPWM\_FH0\_SW\_CBC. (R/W)

MCPWM\_FH0\_F2\_OST Configures whether or not fault\_event2 will trigger one-shot mode action. See details in MCPWM\_FH0\_F2\_CBC. (R/W)

MCPWM\_FH0\_F1\_OST Configures whether or not fault\_event1 will trigger one-shot mode action. See details in MCPWM\_FH0\_F2\_CBC. (R/W)

MCPWM\_FH0\_F0\_OST Configures whether or not fault\_event0 will trigger one-shot mode action. See details in MCPWM\_FH0\_F2\_CBC. (R/W)

MCPWM\_FH0\_A\_CBC\_D Configures cycle-by-cycle mode action on PWM0A when fault event occurs and timer is decreasing.

0: Do nothing

1: Force low

2: Force high

3: Toggle

(R/W)

MCPWM\_FH0\_A\_CBC\_U Configures cycle-by-cycle mode action on PWM0A when fault event occurs and timer is increasing. See details in MCPWM\_FH0\_A\_CBC\_D. (R/W)

Continued on the next page...

## Register 36.27. MCPWM\_FH0\_CFG0\_REG (0x0068)

## Continued from the previous page...

- MCPWM\_FH0\_A\_OST\_D Configures one-shot mode action on PWM0A when fault event occurs and timer is decreasing. See details in MCPWM\_FH0\_A\_CBC\_D. (R/W)
- MCPWM\_FH0\_A\_OST\_U Configures one-shot mode action on PWM0A when fault event occurs and timer is increasing. See details in MCPWM\_FH0\_A\_CBC\_D. (R/W)
- MCPWM\_FH0\_B\_CBC\_D Configures cycle-by-cycle mode action on PWM0B when fault event occurs and timer is decreasing. See details in MCPWM\_FH0\_A\_CBC\_D. (R/W)
- MCPWM\_FH0\_B\_CBC\_U Configures cycle-by-cycle mode action on PWM0B when fault event occurs and timer is increasing. See details in MCPWM\_FH0\_A\_CBC\_D. (R/W)
- MCPWM\_FH0\_B\_OST\_D Configures one-shot mode action on PWM0B when fault event occurs and timer is decreasing. See details in MCPWM\_FH0\_A\_CBC\_D. (R/W)
- MCPWM\_FH0\_B\_OST\_U Configures one-shot mode action on PWM0B when fault event occurs and timer is increasing. See details in MCPWM\_FH0\_A\_CBC\_D. (R/W)

![Image](images/36_Chapter_36_img064_3f1a6286.png)

## Register 36.28. MCPWM\_FH0\_CFG1\_REG (0x006C)

![Image](images/36_Chapter_36_img065_1aa216b4.png)

MCPWM\_FH0\_CLR\_OST Configures whether or not a rising edge will clear an ongoing one-shot mode action.

- 0: No effect
- 1: Clear

(R/W)

MCPWM\_FH0\_CBCPULSE Configures cycle-by-cycle mode action refresh moment selection.

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

(R/W)

MCPWM\_FH0\_FORCE\_CBC Configures whether or not to trigger a cycle-by-cycle mode action.

- 0: No effect
- 1: Trigger a cycle-by-cycle mode action

(R/W)

MCPWM\_FH0\_FORCE\_OST Configures whether or not to trigger a one-shot mode action.

- 0: No effect
- 1: Trigger a one-shot mode action

(R/W)

## Register 36.29. MCPWM\_FH0\_STATUS\_REG (0x0070)

![Image](images/36_Chapter_36_img066_74b862db.png)

MCPWM\_FH0\_CBC\_ON Represents set and reset by hardware. If set, a cycle-by-cycle mode action is on going. (RO)

MCPWM\_FH0\_OST\_ON Represents set and reset by hardware. If set, an one-shot mode action is on going. (RO)

Register 36.30. MCPWM\_GEN1\_STMP\_CFG\_REG (0x0074)

![Image](images/36_Chapter_36_img067_8660a64c.png)

MCPWM\_GEN1\_A\_UPMETHOD Configures update method for PWM generator 1 time stamp A’s ac- tive register.

When all bits are set to 0: immediately. When bit0 is set to 1: TEZ.

When bit1 is set to 1: TEP

When bit2 is set to 1: sync

When bit3 is set to 1: disable the update

(R/W)

MCPWM\_GEN1\_B\_UPMETHOD Configures update method for PWM generator 1 time stamp B's active register. See details in MCPWM\_GEN1\_A\_UPMETHOD. (R/W)

MCPWM\_GEN1\_A\_SHDW\_FULL Set and reset by hardware.

0: A’s active reg has been updated with shadow register latest value.

1: PWM generator 1 time stamp A's shadow reg is filled and waiting to be transferred to A's active reg.

(R/SC/WTC)

## MCPWM\_GEN1\_B\_SHDW\_FULL Set and reset by hardware.

0: B’s active reg has been updated with shadow register latest value.

1: PWM generator 1 time stamp B's shadow reg is filled and waiting to be transferred to B's active reg.

(R/SC/WTC)

Register 36.31. MCPWM\_GEN1\_TSTMP\_A\_REG (0x0078)

![Image](images/36_Chapter_36_img068_c9f49edb.png)

MCPWM\_GEN1\_A Shadow register for PWM generator 1 time stamp A. (R/W)

Register 36.32. MCPWM\_GEN1\_TSTMP\_B\_REG (0x007C)

![Image](images/36_Chapter_36_img069_900a550d.png)

MCPWM\_GEN1\_B Shadow register for PWM generator 1 time stamp B. (R/W)

Register 36.33. MCPWM\_GEN1\_CFG0\_REG (0x0080)

![Image](images/36_Chapter_36_img070_6067a1f3.png)

MCPWM\_GEN1\_CFG\_UPMETHOD Configures update method for PWM generator 1’s active register of configuration.

When all bits are set to 0: immediately

When bit0 is set to 1: TEZ

When bit1 is set to 1: sync

When bit3 is set to 1: disable the update

(R/W)

MCPWM\_GEN1\_T0\_SEL Configures source selection for PWM generator 1 event\_t0, take effect immediately.

0: fault\_event0

1: fault\_event1.

2: fault\_event2

3: sync\_taken

4: None

(R/W)

MCPWM\_GEN1\_T1\_SEL Configures source selection for PWM generator 1 event\_t1, take effect immediately. See details in MCPWM\_GEN1\_T0\_SEL. (R/W)

## Register 36.34. MCPWM\_GEN1\_FORCE\_REG (0x0084)

![Image](images/36_Chapter_36_img071_97a8c7bd.png)

MCPWM\_GEN1\_CNTUFORCE\_UPMETHOD Configures updating method for continuous software force of PWM generator 1.

When all bits are set to 0: immediately

When bit0 is set to 1: TEZ

- When bit1 is set to 1: TEP

- When bit2 is set to 1: TEA

When bit3 is set to 1: TEB

When bit4 is set to 1: sync

When bit5 is set to 1: disable update

TEA/B here and below means an event generated when the timer’s value equals to that of register A/B.

(R/W)

MCPWM\_GEN1\_A\_CNTUFORCE\_MODE Continuous software force mode for PWM1A.

- 0: Disabled
- 1: Low
- 2: High
- 3: Disabled
- (R/W)

MCPWM\_GEN1\_B\_CNTUFORCE\_MODE Configures continuous software force mode for PWM1B. See details in MCPWM\_GEN1\_A\_CNTUFORCE\_MODE. (R/W)

MCPWM\_GEN1\_A\_NCIFORCE Configures whether or not to trigger a non-continuous immediate software-force event for PWM1A

- 0: No effect
- 1: Trigger a force event

(R/W)

MCPWM\_GEN1\_A\_NCIFORCE\_MODE Configures non-continuous immediate software force mode for PWM1A.

- 0: Disabled
- 1: Low
- 2: High
- 3: Disabled
- (R/W)

## Continued on the next page...

## Register 36.34. MCPWM\_GEN1\_FORCE\_REG (0x0084)

## Continued from the previous page...

MCPWM\_GEN1\_B\_NCIFORCE Configures whether or not to trigger a non-continuous immediate software-force event for PWM1B.

- 0: No effect

1: Trigger a force event

(R/W)

MCPWM\_GEN1\_B\_NCIFORCE\_MODE Configures non-continuous immediate software force mode for PWM1B. See details in MCPWM\_GEN1\_A\_NCIFORCE\_MODE. (R/W)

## Register 36.35. MCPWM\_GEN1\_A\_REG (0x0088)

![Image](images/36_Chapter_36_img072_8b375ba1.png)

MCPWM\_GEN1\_A\_UTEZ Configures action on PWM1A triggered by event TEZ when timer increas- ing.

0: No change

1: Low

2: High

3: Toggle

(R/W)

- MCPWM\_GEN1\_A\_UTEP Configures action on PWM1A triggered by event TEP when timer increasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)

MCPWM\_GEN1\_A\_UTEA Configures action on PWM1A triggered by event TEA when timer increasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)

- MCPWM\_GEN1\_A\_UTEB Configures action on PWM1A triggered by event TEB when timer increasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)
- MCPWM\_GEN1\_A\_UT0 Configures action on PWM1A triggered by event\_t0 when timer increasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)
- MCPWM\_GEN1\_A\_UT1 Configures action on PWM1A triggered by event\_t1 when timer increasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)
- MCPWM\_GEN1\_A\_DTEZ Configures action on PWM1A triggered by event TEZ when timer decreasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)
- MCPWM\_GEN1\_A\_DTEP Configures action on PWM1A triggered by event TEP when timer decreasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)
- MCPWM\_GEN1\_A\_DTEA Configures action on PWM1A triggered by event TEA when timer decreasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)
- MCPWM\_GEN1\_A\_DTEB Configures action on PWM1A triggered by event TEB when timer decreasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)
- MCPWM\_GEN1\_A\_DT0 Configures action on PWM1A triggered by event\_t0 when timer decreasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)
- MCPWM\_GEN1\_A\_DT1 Configures action on PWM1A triggered by event\_t1 when timer decreasing. See details in MCPWM\_GEN1\_A\_UTEZ. (R/W)

## Register 36.36. MCPWM\_GEN1\_B\_REG (0x008C)

![Image](images/36_Chapter_36_img073_39f73460.png)

MCPWM\_GEN1\_B\_UTEZ Configures the action on PWM1B triggered by event TEZ when timer increasing.

0: No change

1: Low

2: High

3: Toggle

(R/W)

- MCPWM\_GEN1\_B\_UTEP Configures action on PWM1B triggered by event TEP when timer increasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_UTEA Configures action on PWM1B triggered by event TEA when timer increasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_UTEB Configures action on PWM1B triggered by event TEB when timer increasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_UT0 Configures action on PWM1B triggered by event\_t0 when timer increasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_UT1 Configures action on PWM1B triggered by event\_t1 when timer increasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_DTEZ Configures action on PWM1B triggered by event TEZ when timer decreasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_DTEP Configures action on PWM1B triggered by event TEP when timer decreasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_DTEA Configures action on PWM1B triggered by event TEA when timer decreasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_DTEB Configures action on PWM1B triggered by event TEB when timer decreasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_DT0 Configures action on PWM1B triggered by event\_t0 when timer decreasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)
- MCPWM\_GEN1\_B\_DT1 Configures action on PWM1B triggered by event\_t1 when timer decreasing. See details in MCPWM\_GEN1\_B\_UTEZ. (R/W)

Register 36.37. MCPWM\_DT1\_CFG\_REG (0x0090)

![Image](images/36_Chapter_36_img074_b675bb72.png)

MCPWM\_DT1\_FED\_UPMETHOD Configures update method for FED (falling edge delays) active register.

0: immediate.

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

When bit2 is set to 1: sync

When bit3 is set to 1: disable the update (R/W)

MCPWM\_DT1\_RED\_UPMETHOD Configures update method for RED (rising edge delay) active register. See details in MCPWM\_DT1\_FED\_UPMETHOD. (R/W)

MCPWM\_DT1\_DEB\_MODE S8 in table 36.3-5, dual-edge B mode.

0: fed/red take effect on different path separately

1: fed/red take effect on B path, A out is in bypass or dulpB mode (R/W)

MCPWM\_DT1\_A\_OUTSWAP S6 in table 36.3-5. (R/W)

MCPWM\_DT1\_B\_OUTSWAP S7 in table 36.3-5. (R/W)

MCPWM\_DT1\_RED\_INSEL S4 in table 36.3-5. (R/W)

MCPWM\_DT1\_FED\_INSEL S5 in table 36.3-5. (R/W)

MCPWM\_DT1\_RED\_OUTINVERT S2 in table 36.3-5. (R/W)

MCPWM\_DT1\_FED\_OUTINVERT S3 in table 36.3-5. (R/W)

MCPWM\_DT1\_A\_OUTBYPASS S1 in table 36.3-5. (R/W)

MCPWM\_DT1\_B\_OUTBYPASS S0 in table 36.3-5. (R/W)

MCPWM\_DT1\_CLK\_SEL Configures the dead time generator 1 clock selection.

0: PWM\_CLK.

```
1: PT_CLK.
```

(R/W)

Register 36.38. MCPWM\_DT1\_FED\_CFG\_REG (0x0094)

![Image](images/36_Chapter_36_img075_a341bcf7.png)

MCPWM\_DT1\_FED Shadow register for FED. (R/W)

Register 36.39. MCPWM\_DT1\_RED\_CFG\_REG (0x0098)

![Image](images/36_Chapter_36_img076_d093af3e.png)

MCPWM\_DT1\_RED Shadow register for RED. (R/W)

![Image](images/36_Chapter_36_img077_a2827ea7.png)

Register 36.40. MCPWM\_CARRIER1\_CFG\_REG (0x009C)

![Image](images/36_Chapter_36_img078_d6232cde.png)

MCPWM\_CARRIER1\_EN Configures whether or not to enable carrier1 function.

- 0: Bypass carrier1

1: Enable carrier1 function

(R/W)

MCPWM\_CARRIER1\_PRESCALE Configures the PWM carrier1 clock (PC\_CLK) prescale value. Period of PC\_CLK = period of PWM\_CLK * (PWM\_CARRIER0\_PRESCALE + 1). (R/W)

MCPWM\_CARRIER1\_DUTY Configures carrier duty selection. Duty = PWM\_CARRIER0\_DUTY/8. (R/W)

MCPWM\_CARRIER1\_OSHTWTH Configures width of the first pulse in number of periods of the carrier. (R/W)

MCPWM\_CARRIER1\_OUT\_INVERT Configures whether or not to invert the output of PWM1A and PWM1B for this submodule.

- 0: No effect
- 1: Invert

(R/W)

MCPWM\_CARRIER1\_IN\_INVERT Configures whether or not to invert the input of PWM1A and PWM1B for this submodule.

- 0: No effect
- 1: Invert

(R/W)

## Register 36.41. MCPWM\_FH1\_CFG0\_REG (0x00A0)

![Image](images/36_Chapter_36_img079_2aba10ec.png)

MCPWM\_FH1\_SW\_CBC Configures whether or not to enable software force cycle-by-cycle mode action.

0: Disable

1: Enable

(R/W)

MCPWM\_FH1\_F2\_CBC Configures whether or not fault\_event2 will trigger cycle-by-cycle mode action.

0: Disable

1: Enable

(R/W)

MCPWM\_FH1\_F1\_CBC Configures whether or not fault\_event1 will trigger cycle-by-cycle mode action. See details in MCPWM\_FH1\_F2\_CBC. (R/W)

MCPWM\_FH1\_F0\_CBC Configures whether or not fault\_event0 will trigger cycle-by-cycle mode action. See details in MCPWM\_FH1\_F2\_CBC. (R/W)

MCPWM\_FH1\_SW\_OST Configures whether or not to enable register for software force one-shot mode action. See details in MCPWM\_FH1\_SW\_CBC. (R/W)

MCPWM\_FH1\_F2\_OST Configures whether or not fault\_event2 will trigger one-shot mode action. See details in MCPWM\_FH1\_F2\_CBC. (R/W)

MCPWM\_FH1\_F1\_OST Configures whether or not fault\_event1 will trigger one-shot mode action. See details in MCPWM\_FH1\_F2\_CBC. (R/W)

MCPWM\_FH1\_F0\_OST Configures whether or not fault\_event0 will trigger one-shot mode action. See details in MCPWM\_FH1\_F2\_CBC. (R/W)

MCPWM\_FH1\_A\_CBC\_D Configures cycle-by-cycle mode action on PWM1A when fault event occurs and timer is decreasing.

0: Do nothing

1: Force low

2: Force high

3: Toggle

(R/W)

MCPWM\_FH1\_A\_CBC\_U Configures cycle-by-cycle mode action on PWM1A when fault event occurs and timer is increasing. See details in MCPWM\_FH1\_F2\_CBC. (R/W)

Continued on the next page...

## Register 36.41. MCPWM\_FH1\_CFG0\_REG (0x00A0)

## Continued from the previous page...

- MCPWM\_FH1\_A\_OST\_D Configures one-shot mode action on PWM1A when fault event occurs and timer is decreasing. See details in MCPWM\_FH1\_F2\_CBC. (R/W)
- MCPWM\_FH1\_A\_OST\_U Configures one-shot mode action on PWM1A when fault event occurs and timer is increasing. See details in MCPWM\_FH1\_F2\_CBC. (R/W)
- MCPWM\_FH1\_B\_CBC\_D Configures cycle-by-cycle mode action on PWM1B when fault event occurs and timer is decreasing. See details in MCPWM\_FH1\_F2\_CBC. (R/W)
- MCPWM\_FH1\_B\_CBC\_U Configures cycle-by-cycle mode action on PWM1B when fault event occurs and timer is increasing. See details in MCPWM\_FH1\_F2\_CBC. (R/W)
- MCPWM\_FH1\_B\_OST\_D Configures one-shot mode action on PWM1B when fault event occurs and timer is decreasing. See details in MCPWM\_FH1\_F2\_CBC. (R/W)
- MCPWM\_FH1\_B\_OST\_U Configures one-shot mode action on PWM1B when fault event occurs and timer is increasing. See details in MCPWM\_FH1\_F2\_CBC. (R/W)

![Image](images/36_Chapter_36_img080_96336ba8.png)

## Register 36.42. MCPWM\_FH1\_CFG1\_REG (0x00A4)

![Image](images/36_Chapter_36_img081_eef4cc7f.png)

MCPWM\_FH1\_CLR\_OST Configures whether or not a rising edge will clear on going one-shot mode action.

0: No effect

- 1: Clear

(R/W)

MCPWM\_FH1\_CBCPULSE Configures cycle-by-cycle mode action refresh moment selection.

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

(R/W)

MCPWM\_FH1\_FORCE\_CBC Configures whether or not to trigger a cycle-by-cycle mode action.

- 0: No effect
- 1: Trigger

(R/W)

MCPWM\_FH1\_FORCE\_OST Configures whether or not to trigger a one-shot mode action.

- 0: No effect
- 1: Trigger

(R/W)

## Register 36.43. MCPWM\_FH1\_STATUS\_REG (0x00A8)

![Image](images/36_Chapter_36_img082_f657e7bd.png)

MCPWM\_FH1\_CBC\_ON Represents set and reset by hardware. If set, a cycle-by-cycle mode action is ongoing. (RO)

MCPWM\_FH1\_OST\_ON Represents set and reset by hardware. If set, a one-shot mode action is ongoing. (RO)

Register 36.44. MCPWM\_GEN2\_STMP\_CFG\_REG (0x00AC)

![Image](images/36_Chapter_36_img083_af39294c.png)

MCPWM\_GEN2\_A\_UPMETHOD Configures update method for PWM generator 2 time stamp A's active register.

When all bits are set to 0: immediately.

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

When bit2 is set to 1: sync

When bit3 is set to 1: disable the update

(R/W)

MCPWM\_GEN2\_B\_UPMETHOD Configures update method for PWM generator 2 time stamp B's active register. See details in MCPWM\_GEN2\_A\_UPMETHOD. (R/W)

MCPWM\_GEN2\_A\_SHDW\_FULL Set and reset by hardware.

- 0: A’s active reg has been updated with shadow register latest value.
- 1: PWM generator 2 time stamp A's shadow reg is filled and waiting to be transferred to A's active reg.

(R/SC/WTC)

MCPWM\_GEN2\_B\_SHDW\_FULL Set and reset by hardware.

- 0: B’s active reg has been updated with shadow register latest value.
- 1: PWM generator 2 time stamp B's shadow reg is filled and waiting to be transferred to B's active reg.

(R/SC/WTC)

Register 36.45. MCPWM\_GEN2\_TSTMP\_A\_REG (0x00B0)

![Image](images/36_Chapter_36_img084_cc7b9f20.png)

MCPWM\_GEN2\_A Shadow register for PWM generator 2 time stamp A. (R/W)

Register 36.46. MCPWM\_GEN2\_TSTMP\_B\_REG (0x00B4)

![Image](images/36_Chapter_36_img085_40f9ef58.png)

MCPWM\_GEN2\_B Shadow register for PWM generator 2 time stamp B. (R/W)

## Register 36.47. MCPWM\_GEN2\_CFG0\_REG (0x00B8)

![Image](images/36_Chapter_36_img086_b38b6b27.png)

MCPWM\_GEN2\_CFG\_UPMETHOD Configures update method for PWM generator 2's active register.

0: Immediately

- When bit0 is set to 1: TEZ

- When bit1 is set to 1: sync

When bit3 is set to 1: disable the update

(R/W)

MCPWM\_GEN2\_T0\_SEL Source selection for PWM generator 2 event\_t0, take effect immediately.

0: fault\_event0

1: fault\_event1

2: fault\_event2

3: sync\_taken

4: None

(R/W)

MCPWM\_GEN2\_T1\_SEL Source selection for PWM generator 2 event\_t1, take effect immediately.

0: fault\_event0

1: fault\_event1

2: fault\_event2

3: sync\_taken

4: None

(R/W)

## Register 36.48. MCPWM\_GEN2\_FORCE\_REG (0x00BC)

![Image](images/36_Chapter_36_img087_02bf2696.png)

MCPWM\_GEN2\_CNTUFORCE\_UPMETHOD Configures updating method for continuous software force of PWM generator 2. When all bits are set to 0: Immediately.

- When bit0 is set to 1: TEZ
- When bit1 is set to 1: TEP
- When bit2 is set to 1: TEA
- When bit3 is set to 1: TEB
- When bit4 is set to 1: Sync
- When bit5 is set to 1: Disable update

TEA/B here and below means an event generated when the timer's value equals to that of register A/B.

- (R/W)

MCPWM\_GEN2\_A\_CNTUFORCE\_MODE Configures continuous software force mode for PWM2A.

- 0: Disabled
- 1: Low
- 2: High
- 3: Disabled
- (R/W)

MCPWM\_GEN2\_B\_CNTUFORCE\_MODE Configures continuous software force mode for PWM2B.

- 0: Disabled
- 1: Low
- 2: High
- 3: Disabled
- (R/W)

MCPWM\_GEN2\_A\_NCIFORCE Configures whether or not to trigger a non-continuous immediate software-force event for PWM2A.

- 0: No effect
- 1: Trigger a force event
- (R/W)

Continued on the next page...

## Register 36.48. MCPWM\_GEN2\_FORCE\_REG (0x00BC)

## Continued from the previous page...

MCPWM\_GEN2\_A\_NCIFORCE\_MODE Configures non-continuous immediate software force mode for PWM2A.

- 0: Disabled
- 1: Low
- 2: High
- 3: Disabled
- (R/W)

MCPWM\_GEN2\_B\_NCIFORCE Configures whether or not to trigger a non-continuous immediate software-force event for PWM2B.

- 0: No effect

1: Trigger a force event

(R/W)

MCPWM\_GEN2\_B\_NCIFORCE\_MODE Configures non-continuous immediate software force mode for PWM2B. See details in MCPWM\_GEN2\_A\_NCIFORCE\_MODE. (R/W)

## Register 36.49. MCPWM\_GEN2\_A\_REG (0x00C0)

![Image](images/36_Chapter_36_img088_2c0400a6.png)

MCPWM\_GEN2\_A\_UTEZ Action on PWM2A triggered by event TEZ when timer increasing.

0: No change

- 1: Low.

2: High.

3: Toggle

(R/W)

MCPWM\_GEN2\_A\_UTEP Action on PWM2A triggered by event TEP when timer increasing. (R/W)

MCPWM\_GEN2\_A\_UTEA Action on PWM2A triggered by event TEA when timer increasing. (R/W)

MCPWM\_GEN2\_A\_UTEB Action on PWM2A triggered by event TEB when timer increasing. (R/W)

MCPWM\_GEN2\_A\_UT0 Action on PWM2A triggered by event\_t0 when timer increasing. (R/W)

MCPWM\_GEN2\_A\_UT1 Action on PWM2A triggered by event\_t1 when timer increasing. (R/W)

MCPWM\_GEN2\_A\_DTEZ Action on PWM2A triggered by event TEZ when timer decreasing. (R/W)

MCPWM\_GEN2\_A\_DTEP Action on PWM2A triggered by event TEP when timer decreasing. (R/W)

MCPWM\_GEN2\_A\_DTEA Action on PWM2A triggered by event TEA when timer decreasing. (R/W)

MCPWM\_GEN2\_A\_DTEB Action on PWM2A triggered by event TEB when timer decreasing. (R/W)

MCPWM\_GEN2\_A\_DT0 Action on PWM2A triggered by event\_t0 when timer decreasing. (R/W)

MCPWM\_GEN2\_A\_DT1 Action on PWM2A triggered by event\_t1 when timer decreasing. (R/W)

## Register 36.50. MCPWM\_GEN2\_B\_REG (0x00C4)

![Image](images/36_Chapter_36_img089_e7d02b2b.png)

MCPWM\_GEN2\_B\_UTEZ Action on PWM2B triggered by event TEZ when timer increasing.

0: No change

1: Low

2: High

3: Toggle

(R/W)

MCPWM\_GEN2\_B\_UTEP Action on PWM2B triggered by event TEP when timer increasing. (R/W)

MCPWM\_GEN2\_B\_UTEA Action on PWM2B triggered by event TEA when timer increasing. (R/W)

MCPWM\_GEN2\_B\_UTEB Action on PWM2B triggered by event TEB when timer increasing. (R/W)

MCPWM\_GEN2\_B\_UT0 Action on PWM2B triggered by event\_t0 when timer increasing. (R/W)

MCPWM\_GEN2\_B\_UT1 Action on PWM2B triggered by event\_t1 when timer increasing. (R/W)

MCPWM\_GEN2\_B\_DTEZ Action on PWM2B triggered by event TEZ when timer decreasing. (R/W)

MCPWM\_GEN2\_B\_DTEP Action on PWM2B triggered by event TEP when timer decreasing. (R/W)

MCPWM\_GEN2\_B\_DTEA Action on PWM2B triggered by event TEA when timer decreasing. (R/W)

MCPWM\_GEN2\_B\_DTEB Action on PWM2B triggered by event TEB when timer decreasing. (R/W)

MCPWM\_GEN2\_B\_DT0 Action on PWM2B triggered by event\_t0 when timer decreasing. (R/W)

MCPWM\_GEN2\_B\_DT1 Action on PWM2B triggered by event\_t1 when timer decreasing. (R/W)

![Image](images/36_Chapter_36_img090_515ec856.png)

Register 36.51. MCPWM\_DT2\_CFG\_REG (0x00C8)

![Image](images/36_Chapter_36_img091_d31d613b.png)

MCPWM\_DT2\_FED\_UPMETHOD Configures update method for FED (falling edge delay) active reg- ister.

0: Immediate.

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

When bit2 is set to 1: sync

When bit3 is set to 1: disable the update

(R/W)

MCPWM\_DT2\_RED\_UPMETHOD Configures update method for RED (rising edge delay) active register. See details in MCPWM\_DT2\_FED\_UPMETHOD. (R/W)

MCPWM\_DT2\_DEB\_MODE S8 in table 36.3-5, dual-edge B mode.

0: fed/red take effect on different path separately

1: fed/red take effect on B path, A out is in bypass or dulpB mode (R/W)

MCPWM\_DT2\_A\_OUTSWAP S6 in table 36.3-5. (R/W)

MCPWM\_DT2\_B\_OUTSWAP S7 in table 36.3-5. (R/W)

MCPWM\_DT2\_RED\_INSEL S4 in table 36.3-5. (R/W)

MCPWM\_DT2\_FED\_INSEL S5 in table 36.3-5. (R/W)

MCPWM\_DT2\_RED\_OUTINVERT S2 in table 36.3-5. (R/W)

MCPWM\_DT2\_FED\_OUTINVERT S3 in table 36.3-5. (R/W)

MCPWM\_DT2\_A\_OUTBYPASS S1 in table 36.3-5. (R/W)

MCPWM\_DT2\_B\_OUTBYPASS S0 in table 36.3-5. (R/W)

MCPWM\_DT2\_CLK\_SEL Configures dead time generator 2 clock selection.

0: PWM\_CLK

1: PT\_CLK

(R/W)

Register 36.52. MCPWM\_DT2\_FED\_CFG\_REG (0x00CC)

![Image](images/36_Chapter_36_img092_a960f27f.png)

MCPWM\_DT2\_FED Shadow register for FED. (R/W)

Register 36.53. MCPWM\_DT2\_RED\_CFG\_REG (0x00D0)

![Image](images/36_Chapter_36_img093_811a3daa.png)

MCPWM\_DT2\_RED Shadow register for RED. (R/W)

Register 36.54. MCPWM\_CARRIER2\_CFG\_REG (0x00D4)

![Image](images/36_Chapter_36_img094_d1614bed.png)

MCPWM\_CARRIER2\_EN Configures whether or not to enable the carrier2 function.

0: Bypass carrier2

1: Enable

(R/W)

MCPWM\_CARRIER2\_PRESCALE Configures the PWM carrier2 clock (PC\_CLK) prescale value. Period of PC\_CLK = period of PWM\_CLK * (PWM\_CARRIER0\_PRESCALE + 1). (R/W)

MCPWM\_CARRIER2\_DUTY Configures the carrier duty selection. Duty = PWM\_CARRIER0\_DUTY/8. (R/W)

MCPWM\_CARRIER2\_OSHTWTH Configures the width of the first pulse in number of periods of the carrier. (R/W)

MCPWM\_CARRIER2\_OUT\_INVERT Configures whether or not to invert the output of PWM2A and PWM2B for this submodule.

0: No effect

1: Invert

(R/W)

MCPWM\_CARRIER2\_IN\_INVERT Configures whether or not to invert the input of PWM2A and PWM2B for this submodule.

0: No effect

1: Invert

(R/W)

## Register 36.55. MCPWM\_FH2\_CFG0\_REG (0x00D8)

![Image](images/36_Chapter_36_img095_42346429.png)

MCPWM\_FH2\_SW\_CBC Configures whether or not to enable software force cycle-by-cycle mode action.

0: Disable

1: Enable

(R/W)

MCPWM\_FH2\_F2\_CBC Configures whether or not fault\_event2 will trigger cycle-by-cycle mode action.

0: No effect

1: Trigger

(R/W)

MCPWM\_FH2\_F1\_CBC Configures whether or not fault\_event1 will trigger cycle-by-cycle mode ac- tion.

0: No effect

1: Trigger

(R/W)

MCPWM\_FH2\_F0\_CBC Configures whether or not fault\_event0 will trigger cycle-by-cycle mode action.

0: No effect

1: Trigger

(R/W)

MCPWM\_FH2\_SW\_OST Configures whether or not to enable software force one-shot mode action.

0: Disable

1: Enable

(R/W)

MCPWM\_FH2\_F2\_OST Configures whether or not fault\_event2 will trigger one-shot mode action.

0: No effect

1: Trigger

(R/W) (R/W)

MCPWM\_FH2\_F1\_OST Configures whether or not fault\_event1 will trigger one-shot mode action.

0: No effect

1: Trigger

(R/W) (R/W)

Continued on the next page...

## Register 36.55. MCPWM\_FH2\_CFG0\_REG (0x00D8)

## Continued from the previous page...

MCPWM\_FH2\_F0\_OST Configures whether or not fault\_event0 will trigger one-shot mode action.

0: No effect

1: Trigger

(R/W) (R/W)

MCPWM\_FH2\_A\_CBC\_D Configures cycle-by-cycle mode action on PWM2A when fault event occurs and timer is decreasing.

0: Do nothing.

1: Force low.

2: Force high.

3: Toggle

(R/W)

- MCPWM\_FH2\_A\_CBC\_U Configures cycle-by-cycle mode action on PWM2A when fault event occurs and the timer is increasing. See details in MCPWM\_FH2\_A\_CBC\_D. (R/W)
- MCPWM\_FH2\_A\_OST\_D Configures one-shot mode action on PWM2A when fault event occurs and timer is decreasing. See details in MCPWM\_FH2\_A\_CBC\_D. (R/W)
- MCPWM\_FH2\_A\_OST\_U Configures one-shot mode action on PWM2A when fault event occurs and timer is increasing. See details in MCPWM\_FH2\_A\_CBC\_D. (R/W)
- MCPWM\_FH2\_B\_CBC\_D Configures cycle-by-cycle mode action on PWM2B when fault event occurs and timer is decreasing. See details in MCPWM\_FH2\_A\_CBC\_D. (R/W)
- MCPWM\_FH2\_B\_CBC\_U Configures cycle-by-cycle mode action on PWM2B when fault event occurs and timer is increasing. See details in MCPWM\_FH2\_A\_CBC\_D. (R/W)
- MCPWM\_FH2\_B\_OST\_D Configures one-shot mode action on PWM2B when fault event occurs and timer is decreasing. See details in MCPWM\_FH2\_A\_CBC\_D. (R/W)
- MCPWM\_FH2\_B\_OST\_U Configures one-shot mode action on PWM2B when fault event occurs and timer is increasing. See details in MCPWM\_FH2\_A\_CBC\_D. (R/W)

## Register 36.56. MCPWM\_FH2\_CFG1\_REG (0x00DC)

![Image](images/36_Chapter_36_img096_c3aa60c0.png)

MCPWM\_FH2\_CLR\_OST Configures whether or not a rising edge will clear an ongoing one-shot mode action.

- 0: Not clear
- 1: Clear

(R/W)

MCPWM\_TZ2\_CBCPULSE Configures cycle-by-cycle mode action refresh moment selection.

When bit0 is set to 1: TEZ

When bit1 is set to 1: TEP

(R/W)

MCPWM\_TZ2\_FORCE\_CBC Configures whether or not to trigger a cycle-by-cycle mode action.

- 0: No effect
- 1: Trigger a cycle-by-cycle mode action

(R/W)

MCPWM\_TZ2\_FORCE\_OST Configures whether or not to trigger a one-shot mode action.

- 0: No effect
- 1: Trigger a one-shot mode action

(R/W)

## Register 36.57. MCPWM\_FH2\_STATUS\_REG (0x00E0)

![Image](images/36_Chapter_36_img097_764b5fb9.png)

MCPWM\_FH2\_CBC\_ON Represents set and reset by hardware. If set, a cycle-by-cycle mode action is ongoing. (RO)

MCPWM\_FH2\_OST\_ON Represents set and reset by hardware. If set, a one-shot mode action is ongoing. (RO)

## Register 36.58. MCPWM\_FAULT\_DETECT\_REG (0x00E4)

![Image](images/36_Chapter_36_img098_8a50e687.png)

MCPWM\_F0\_EN Configures whether or not to enable fault\_event0 generation.

0: No effect

1: Enable

(R/W)

MCPWM\_F1\_EN Configures whether or not to enable fault\_event1 generation.

0: No effect

1: Enable

(R/W)

MCPWM\_F2\_EN Configures whether or not to enable fault\_event2 generation.

0: No effect

1: Enable

(R/W)

MCPWM\_F0\_POLE Configures fault\_event0 trigger polarity on FAULT0 source from GPIO matrix.

0: Level low

1: Level high

(R/W)

MCPWM\_F1\_POLE Configures fault\_event1 trigger polarity on FAULT1 source from GPIO matrix.

0: Level low

1: Level high

(R/W)

MCPWM\_F2\_POLE Configures fault\_event2 trigger polarity on FAULT2 source from GPIO matrix.

0: Level low

1: Level high

(R/W)

MCPWM\_EVENT\_F0 Represents set and reset by hardware. If set, fault\_event0 is on going. (RO)

MCPWM\_EVENT\_F1 Represents set and reset by hardware. If set, fault\_event1 is on going. (RO)

MCPWM\_EVENT\_F2 Represents set and reset by hardware. If set, fault\_event2 is on going. (RO)

## Register 36.59. MCPWM\_CAP\_TIMER\_CFG\_REG (0x00E8)

![Image](images/36_Chapter_36_img099_82e81a3b.png)

MCPWM\_CAP\_TIMER\_EN Configures whether or not to enable capture timer incrementing under

APB\_CLK.

- 0: No effect
- 1: Enable

(R/W)

MCPWM\_CAP\_SYNCI\_EN Configures whether or not to enable capture timer sync.

- 0: No effect
- 1: Enable

(R/W)

MCPWM\_CAP\_SYNCI\_SEL Configures the capture module sync input selection.

- 0: None
- 1: timer0 sync out
- 2: timer1 sync out
- 3: timer2 sync out
- 4: SYNC0 from GPIO matrix
- 5: SYNC1 from GPIO matrix
- 6: SYNC2 from GPIO matrix
- (R/W)

MCPWM\_CAP\_SYNC\_SW When MCPWM\_CAP\_SYNCI\_EN is set to 1, configures whether or not to trigger a capture timer sync so that capture timer is loaded with value in phase register.

- 0: No effect
- 1: Trigger a capture timer sync

(WT)

Register 36.60. MCPWM\_CAP\_TIMER\_PHASE\_REG (0x00EC)

MCPWM\_CAP\_PHASE

![Image](images/36_Chapter_36_img100_6c725e59.png)

MCPWM\_CAP\_PHASE Configures the phase value for capture timer sync operation. (R/W)

## Register 36.61. MCPWM\_CAP\_CH0\_CFG\_REG (0x00F0)

![Image](images/36_Chapter_36_img101_99fccc32.png)

MCPWM\_CAP0\_EN Configures whether or not to enable capture on channel 0.

- 0: Not enable
- 1: Enable

(R/W)

MCPWM\_CAP0\_MODE Configures the edge of capture on channel 0 after prescaling.

When bit0 is set to 1: enable capture on the falling edge.

When bit1 is set to 1: enable capture on the rising edge.

(R/W)

MCPWM\_CAP0\_PRESCALE Configures the prescale value on the rising edge of CAP0. Prescale value = PWM\_CAP0\_PRESCALE + 1. (R/W)

MCPWM\_CAP0\_IN\_INVERT Configures whether or not to invert the CAP0 from GPIO matrix before prescale.

- 0: No effect
- 1: Invert

(R/W)

MCPWM\_CAP0\_SW Configures whether or not to trigger a software forced capture on channel 0.

- 0: Not trigger
- 1: Trigger

(WT)

## Register 36.62. MCPWM\_CAP\_CH1\_CFG\_REG (0x00F4)

![Image](images/36_Chapter_36_img102_13548c3f.png)

MCPWM\_CAP1\_EN Configures whether or not to enable capture on channel 1.

0: Not enable

1: Enable

(R/W)

MCPWM\_CAP1\_MODE Configures the edge of capture on channel 1 after prescaling.

When bit0 is set to 1: enable capture on the falling edge.

When bit1 is set to 1: enable capture on the rising edge.

(R/W)

MCPWM\_CAP1\_PRESCALE COnfigures the value of prescaling on the rising edge of CAP1. Prescale value = PWM\_CAP1\_PRESCALE + 1. (R/W)

MCPWM\_CAP1\_IN\_INVERT Configures whether or not to invert the CAP1 from GPIO matrix before prescale.

0: No effect

1: Invert

(R/W)

MCPWM\_CAP1\_SW Configures whether or not to trigger a software forced capture on channel 1.

0: Not trigger

1: Trigger

(WT)

Register 36.63. MCPWM\_CAP\_CH2\_CFG\_REG (0x00F8)

![Image](images/36_Chapter_36_img103_27e0d193.png)

MCPWM\_CAP2\_EN Configures whether or not to enable capture on channel 2.

- 0: Not enable

1: Enable

(R/W)

MCPWM\_CAP2\_MODE Configures the edge of capture on channel 2 after prescaling.

When bit0 is set to 1: enable capture on the falling edge.

When bit1 is set to 1: enable capture on the rising edge.

(R/W)

MCPWM\_CAP2\_PRESCALE Configures the value of prescaling on the rising edge of CAP2. Prescale value = PWM\_CAP2\_PRESCALE + 1. (R/W)

MCPWM\_CAP2\_IN\_INVERT Configures whether or not to invert the CAP2 from GPIO matrix before prescale.

0: No effect

- 1: Invert

(R/W)

MCPWM\_CAP2\_SW Configures whether or not to trigger a software forced capture on channel 2.

- 0: Not trigger

1: Trigger

(WT)

Register 36.64. MCPWM\_CAP\_CH0\_REG (0x00FC)

![Image](images/36_Chapter_36_img104_c85b4d6c.png)

MCPWM\_CAP0\_VALUE Represents the value of the last capture on channel 0. (RO)

## Register 36.65. MCPWM\_CAP\_CH1\_REG (0x0100)

![Image](images/36_Chapter_36_img105_df7ea36a.png)

MCPWM\_CAP1\_VALUE Represents the value of the last capture on channel 1. (RO)

## Register 36.66. MCPWM\_CAP\_CH2\_REG (0x0104)

![Image](images/36_Chapter_36_img106_7007fec5.png)

MCPWM\_CAP2\_VALUE Represents the value of the last capture on channel 2. (RO)

## Register 36.67. MCPWM\_CAP\_STATUS\_REG (0x0108)

![Image](images/36_Chapter_36_img107_ed4beb41.png)

MCPWM\_CAP0\_EDGE Represents the edge of the last capture trigger on channel 0.

- 0: Rising edge
- 1: Falling edge

(RO)

MCPWM\_CAP1\_EDGE Represents the edge of the last capture trigger on channel 1. See details in MCPWM\_CAP0\_EDGE. (RO)

MCPWM\_CAP2\_EDGE Represents the edge of the last capture trigger on channel 2. See details in MCPWM\_CAP0\_EDGE. (RO)

## Register 36.68. MCPWM\_UPDATE\_CFG\_REG (0x010C)

![Image](images/36_Chapter_36_img108_4b2edb68.png)

MCPWM\_GLOBAL\_UP\_EN Configures whether to globally update all active registers.

- 0: No effect
- 1: Update all active registers globally

(R/W)

MCPWM\_GLOBAL\_FORCE\_UP Configures whether or not to trigger a forced update of all active registers globally.

- 0: No effect
- 1: Trigger a forced update
- (R/W)

MCPWM\_OP0\_UP\_EN Configures whether or not to update active registers in PWM operator 0 when MCPWM\_GLOBAL\_UP\_EN is set to 1.

- 0: No effect

1: Update active registers in PWM operator 0 (R/W)

MCPWM\_OP0\_FORCE\_UP Configures whether or not to trigger a forced update of active registers

- in PWM operator 0.
- 0: No effect
- 1: Trigger a forced update

(R/W)

MCPWM\_OP1\_UP\_EN Configures whether or not to update active registers in PWM operator 1 when MCPWM\_GLOBAL\_UP\_EN is set to 1.

- 0: No effect

1: Update active registers in PWM operator 1 (R/W)

Continued on the next page...

## Register 36.68. MCPWM\_UPDATE\_CFG\_REG (0x010C)

## Continued from the previous page...

MCPWM\_OP1\_FORCE\_UP Configures whether or not to trigger a forced update of active registers

- in PWM operator 1.
- 0: No effect
- 1: Trigger a forced update

(R/W)

MCPWM\_OP2\_UP\_EN Configures whether or not to update active registers in PWM operator 2 when MCPWM\_GLOBAL\_UP\_EN is set to 1.

- 0: No effect

1: Update active registers in PWM operator 2 (R/W)

- MCPWM\_OP2\_FORCE\_UP Configures whether or not to trigger a forced update of active registers in PWM operator 2.
- 0: No effect
- 1: Trigger a forced update

(R/W)

## Register 36.69. MCPWM\_INT\_ENA\_REG (0x0110)

![Image](images/36_Chapter_36_img109_8158cab0.png)

MCPWM\_TIMER0\_STOP\_INT\_ENA Enables the interrupt triggered when the timer 0 stops. (R/W) MCPWM\_TIMER1\_STOP\_INT\_ENA Enables the interrupt triggered when the timer 1 stops. (R/W) MCPWM\_TIMER2\_STOP\_INT\_ENA Enables the interrupt triggered when the timer 2 stops. (R/W) MCPWM\_TIMER0\_TEZ\_INT\_ENA Enables the interrupt triggered by a PWM timer 0 TEZ event. (R/W) MCPWM\_TIMER1\_TEZ\_INT\_ENA Enables the interrupt triggered by a PWM timer 1 TEZ event. (R/W) MCPWM\_TIMER2\_TEZ\_INT\_ENA Enables the interrupt triggered by a PWM timer 2 TEZ event. (R/W) MCPWM\_TIMER0\_TEP\_INT\_ENA Enables the interrupt triggered by a PWM timer 0 TEP event. (R/W) MCPWM\_TIMER1\_TEP\_INT\_ENA Enables the interrupt triggered by a PWM timer 1 TEP event. (R/W) MCPWM\_TIMER2\_TEP\_INT\_ENA Enables the interrupt triggered by a PWM timer 2 TEP event. (R/W) MCPWM\_FAULT0\_INT\_ENA Enables the interrupt triggered when fault\_event0 starts. (R/W) MCPWM\_FAULT1\_INT\_ENA Enables the interrupt triggered when fault\_event1 starts. (R/W) MCPWM\_FAULT2\_INT\_ENA Enables the interrupt triggered when fault\_event2 starts. (R/W) MCPWM\_FAULT0\_CLR\_INT\_ENA Enables the interrupt triggered when fault\_event0 ends. (R/W) MCPWM\_FAULT1\_CLR\_INT\_ENA Enables the interrupt triggered when fault\_event1 ends. (R/W) MCPWM\_FAULT2\_CLR\_INT\_ENA Enables the interrupt triggered when fault\_event2 ends. (R/W) Continued on the next page...

![Image](images/36_Chapter_36_img110_b9fa3a09.png)

## Register 36.69. MCPWM\_INT\_ENA\_REG (0x0110)

## Continued from the previous page...

- MCPWM\_CMPR0\_TEA\_INT\_ENA Enables the interrupt triggered by a PWM operator 0 TEA event (R/W)
- MCPWM\_CMPR1\_TEA\_INT\_ENA Enables the interrupt triggered by a PWM operator 1 TEA event (R/W)
- MCPWM\_CMPR2\_TEA\_INT\_ENA Enables the interrupt triggered by a PWM operator 2 TEA event (R/W)
- MCPWM\_CMPR0\_TEB\_INT\_ENA Enables the interrupt triggered by a PWM operator 0 TEB event (R/W)
- MCPWM\_CMPR1\_TEB\_INT\_ENA Enables the interrupt triggered by a PWM operator 1 TEB event (R/W)
- MCPWM\_CMPR2\_TEB\_INT\_ENA Enables the interrupt triggered by a PWM operator 2 TEB event (R/W)
- MCPWM\_TZ0\_CBC\_INT\_ENA Enables the interrupt triggered by a cycle-by-cycle mode action on PWM0. (R/W)
- MCPWM\_TZ1\_CBC\_INT\_ENA Enables the interrupt triggered by a cycle-by-cycle mode action on PWM1. (R/W)
- MCPWM\_TZ2\_CBC\_INT\_ENA Enables the interrupt triggered by a cycle-by-cycle mode action on PWM2. (R/W)
- MCPWM\_TZ0\_OST\_INT\_ENA Enables the interrupt triggered by a one-shot mode action on PWM0. (R/W)
- MCPWM\_TZ1\_OST\_INT\_ENA Enables the interrupt triggered by a one-shot mode action on PWM1. (R/W)
- MCPWM\_TZ2\_OST\_INT\_ENA Enables the interrupt triggered by a one-shot mode action on PWM2. (R/W)
- MCPWM\_CAP0\_INT\_ENA Enables the interrupt triggered by capture on channel 0. (R/W)
- MCPWM\_CAP1\_INT\_ENA Enables the interrupt triggered by capture on channel 1. (R/W)
- MCPWM\_CAP2\_INT\_ENA Enables the interrupt triggered by capture on channel 2. (R/W)

![Image](images/36_Chapter_36_img111_e31b093d.png)

## Register 36.70. MCPWM\_INT\_RAW\_REG (0x0114)

![Image](images/36_Chapter_36_img112_e34772ca.png)

- MCPWM\_TIMER0\_STOP\_INT\_RAW Represents the raw status for the interrupt triggered when the timer 0 stops. (R/WTC/SS)

MCPWM\_TIMER1\_STOP\_INT\_RAW Represents the raw status for the interrupt triggered when the

MCPWM\_TIMER2\_STOP\_INT\_RAW Represents the raw status for the interrupt triggered when the

MCPWM\_TIMER0\_TEZ\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM timer 0 TEZ event. (R/WTC/SS)

MCPWM\_TIMER1\_TEZ\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM timer 1 TEZ event. (R/WTC/SS)

MCPWM\_TIMER2\_TEZ\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM

MCPWM\_TIMER0\_TEP\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM timer 0 TEP event. (R/WTC/SS)

- MCPWM\_TIMER1\_TEP\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM timer 1 TEP event. (R/WTC/SS)
- MCPWM\_TIMER2\_TEP\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM timer 2 TEP event. (R/WTC/SS)
- MCPWM\_FAULT0\_INT\_RAW Represents the raw status for the interrupt triggered when fault\_event0 starts. (R/WTC/SS)
- MCPWM\_FAULT1\_INT\_RAW Represents the raw status for the interrupt triggered when fault\_event1 starts. (R/WTC/SS)
- MCPWM\_FAULT2\_INT\_RAW Represents the raw status for the interrupt triggered when fault\_event2 starts. (R/WTC/SS)

MCPWM\_FAULT0\_CLR\_INT\_RAW Represents the raw status for the interrupt triggered when timer 1 stops. (R/WTC/SS) timer 2 stops. (R/WTC/SS) timer 2 TEZ event. (R/WTC/SS) fault\_event0 ends. (R/WTC/SS)

- MCPWM\_FAULT1\_CLR\_INT\_RAW Represents the raw status for the interrupt triggered when fault\_event1 ends. (R/WTC/SS)

Continued on the next page...

## Register 36.70. MCPWM\_INT\_RAW\_REG (0x0114)

## Continued from the previous page...

- MCPWM\_FAULT2\_CLR\_INT\_RAW Represents the raw status for the interrupt triggered when fault\_event2 ends. (R/WTC/SS)
- MCPWM\_CMPR0\_TEA\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM operator 0 TEA event. (R/WTC/SS)
- MCPWM\_CMPR1\_TEA\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM operator 1 TEA event. (R/WTC/SS)
- MCPWM\_CMPR2\_TEA\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM operator 2 TEA event. (R/WTC/SS)
- MCPWM\_CMPR0\_TEB\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM operator 0 TEB event. (R/WTC/SS)
- MCPWM\_CMPR1\_TEB\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM operator 1 TEB event. (R/WTC/SS)
- MCPWM\_CMPR2\_TEB\_INT\_RAW Represents the raw status for the interrupt triggered by a PWM operator 2 TEB event. (R/WTC/SS)
- MCPWM\_TZ0\_CBC\_INT\_RAW Represents the raw status for the interrupt triggered by a cycle-bycycle mode action on PWM0. (R/WTC/SS)
- MCPWM\_TZ1\_CBC\_INT\_RAW Represents the raw status for the interrupt triggered by a cycle-bycycle mode action on PWM1. (R/WTC/SS)
- MCPWM\_TZ2\_CBC\_INT\_RAW Represents the raw status for the interrupt triggered by a cycle-bycycle mode action on PWM2. (R/WTC/SS)
- MCPWM\_TZ0\_OST\_INT\_RAW Represents the raw status for the interrupt triggered by a one-shot mode action on PWM0. (R/WTC/SS)
- MCPWM\_TZ1\_OST\_INT\_RAW Represents the raw status for the interrupt triggered by a one-shot mode action on PWM1. (R/WTC/SS)
- MCPWM\_TZ2\_OST\_INT\_RAW Represents the raw status for the interrupt triggered by a one-shot mode action on PWM2. (R/WTC/SS)
- MCPWM\_CAP0\_INT\_RAW Represents the raw status for the interrupt triggered by capture on channel 0. (R/WTC/SS)
- MCPWM\_CAP1\_INT\_RAW Represents the raw status for the interrupt triggered by capture on channel 1. (R/WTC/SS)
- MCPWM\_CAP2\_INT\_RAW Represents the raw status for the interrupt triggered by capture on channel 2. (R/WTC/SS)

![Image](images/36_Chapter_36_img113_9fbd3dd9.png)

## Register 36.71. MCPWM\_INT\_ST\_REG (0x0118)

![Image](images/36_Chapter_36_img114_cc74c02a.png)

| timer 0 stops. (RO)                                                                                           | MCPWM_TIMER0_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER0_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER0_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER0_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER0_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER0_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER0_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER0_STOP_INT_ST Represents the masked status for the interrupt triggered when the   |
|---------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------|
| timer 1 stops. (RO)                                                                                           | MCPWM_TIMER1_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER1_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER1_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER1_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER1_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER1_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER1_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER1_STOP_INT_ST Represents the masked status for the interrupt triggered when the   |
| timer 2 stops. (RO)                                                                                           | MCPWM_TIMER2_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER2_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER2_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER2_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER2_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER2_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER2_STOP_INT_ST Represents the masked status for the interrupt triggered when the   | MCPWM_TIMER2_STOP_INT_ST Represents the masked status for the interrupt triggered when the   |
| timer 0 TEZ event. (RO)                                                                                       | MCPWM_TIMER0_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    |
| timer 1 TEZ event. (RO)                                                                                       | MCPWM_TIMER1_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    |
| timer 2 TEZ event. (RO)                                                                                       | MCPWM_TIMER2_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEZ_INT_ST Represents the masked status for the interrupt triggered by a PWM    |
| timer 0 TEP event. (RO)                                                                                       | MCPWM_TIMER0_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER0_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    |
| timer 1 TEP event. (RO)                                                                                       | MCPWM_TIMER1_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER1_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    |
| timer 2 TEP event. (RO)                                                                                       | MCPWM_TIMER2_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    | MCPWM_TIMER2_TEP_INT_ST Represents the masked status for the interrupt triggered by a PWM    |
| fault_event0 starts. (RO)                                                                                     | MCPWM_FAULT0_INT_ST Represents the masked status for the interrupt triggered when            |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |
| MCPWM_FAULT1_INT_ST Represents the masked status for the interrupt triggered when fault_event1 starts. (RO)   |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |
| MCPWM_FAULT2_INT_ST Represents the masked status for the interrupt triggered when fault_event2 starts. (RO)   |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |
| MCPWM_FAULT0_CLR_INT_ST Represents the masked status for the interrupt triggered when fault_event0 ends. (RO) |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |
| MCPWM_FAULT1_CLR_INT_ST Represents the masked status for the interrupt triggered when fault_event1 ends. (RO) |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |
| Continued on the next page...                                                                                 |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |                                                                                              |

## Register 36.71. MCPWM\_INT\_ST\_REG (0x0118)

## Continued from the previous page...

- MCPWM\_FAULT2\_CLR\_INT\_ST Represents the masked status for the interrupt triggered when fault\_event2 ends. (RO)
- MCPWM\_CMPR0\_TEA\_INT\_ST Represents the masked status for the interrupt triggered by a PWM operator 0 TEA event. (RO)
- MCPWM\_CMPR1\_TEA\_INT\_ST Represents the masked status for the interrupt triggered by a PWM operator 1 TEA event. (RO)
- MCPWM\_CMPR2\_TEA\_INT\_ST Represents the masked status for the interrupt triggered by a PWM operator 2 TEA event. (RO)
- MCPWM\_CMPR0\_TEB\_INT\_ST Represents the masked status for the interrupt triggered by a PWM operator 0 TEB event. (RO)
- MCPWM\_CMPR1\_TEB\_INT\_ST Represents the masked status for the interrupt triggered by a PWM operator 1 TEB event. (RO)
- MCPWM\_CMPR2\_TEB\_INT\_ST Represents the masked status for the interrupt triggered by a PWM operator 2 TEB event. (RO)
- MCPWM\_TZ0\_CBC\_INT\_ST Represents the masked status for the interrupt triggered by a cycleby-cycle mode action on PWM0. (RO)
- MCPWM\_TZ1\_CBC\_INT\_ST Represents the masked status for the interrupt triggered by a cycle-bycycle mode action on PWM1. (RO)
- MCPWM\_TZ2\_CBC\_INT\_ST Represents the masked status for the interrupt triggered by a cycleby-cycle mode action on PWM2. (RO)
- MCPWM\_TZ0\_OST\_INT\_ST Represents the masked status for the interrupt triggered by a one-shot mode action on PWM0. (RO)
- MCPWM\_TZ1\_OST\_INT\_ST Represents the masked status for the interrupt triggered by a one-shot mode action on PWM1. (RO)
- MCPWM\_TZ2\_OST\_INT\_ST Represents the masked status for the interrupt triggered by a one-shot mode action on PWM2. (RO)
- MCPWM\_CAP0\_INT\_ST Represents the masked status for the interrupt triggered by capture on channel 0. (RO)
- MCPWM\_CAP1\_INT\_ST Represents the masked status for the interrupt triggered by capture on channel 1. (RO)
- MCPWM\_CAP2\_INT\_ST Represents the masked status for the interrupt triggered by capture on channel 2. (RO)

## Register 36.72. MCPWM\_INT\_CLR\_REG (0x011C)

![Image](images/36_Chapter_36_img115_f26a0151.png)

- MCPWM\_TIMER0\_STOP\_INT\_CLR Write 1 to clear the interrupt triggered when the timer 0 stops. (WT)
- MCPWM\_TIMER1\_STOP\_INT\_CLR Write 1 to clear the interrupt triggered when the timer 1 stops. (WT)
- MCPWM\_TIMER2\_STOP\_INT\_CLR Write 1 to clear the interrupt triggered when the timer 2 stops. (WT)
- MCPWM\_TIMER0\_TEZ\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM timer 0 TEZ event. (WT)
- MCPWM\_TIMER1\_TEZ\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM timer 1 TEZ event. (WT)
- MCPWM\_TIMER2\_TEZ\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM timer 2 TEZ event. (WT)
- MCPWM\_TIMER0\_TEP\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM timer 0 TEP event. (WT)
- MCPWM\_TIMER1\_TEP\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM timer 1 TEP event. (WT)
- MCPWM\_TIMER2\_TEP\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM timer 2 TEP event. (WT)
- MCPWM\_FAULT0\_INT\_CLR Write 1 to clear the interrupt triggered when fault\_event0 starts. (WT) MCPWM\_FAULT1\_INT\_CLR Write 1 to clear the interrupt triggered when fault\_event1 starts. (WT) MCPWM\_FAULT2\_INT\_CLR Write 1 to clear the interrupt triggered when fault\_event2 starts. (WT) MCPWM\_FAULT0\_CLR\_INT\_CLR Write 1 to clear the interrupt triggered when fault\_event0 ends. (WT) Continued on the next page...

![Image](images/36_Chapter_36_img116_944898d5.png)

## Register 36.72. MCPWM\_INT\_CLR\_REG (0x011C)

## Continued from the previous page...

- MCPWM\_FAULT1\_CLR\_INT\_CLR Write 1 to clear the interrupt triggered when fault\_event1 ends. (WT)
- MCPWM\_FAULT2\_CLR\_INT\_CLR Write 1 to clear the interrupt triggered when fault\_event2 ends. (WT)
- MCPWM\_CMPR0\_TEA\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM operator 0 TEA event. (WT)
- MCPWM\_CMPR1\_TEA\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM operator 1 TEA event. (WT)
- MCPWM\_CMPR2\_TEA\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM operator 2 TEA event. (WT)
- MCPWM\_CMPR0\_TEB\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM operator 0 TEB event. (WT)
- MCPWM\_CMPR1\_TEB\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM operator 1 TEB event. (WT)
- MCPWM\_CMPR2\_TEB\_INT\_CLR Write 1 to clear the interrupt triggered by a PWM operator 2 TEB event. (WT)
- MCPWM\_TZ0\_CBC\_INT\_CLR Write 1 to clear the interrupt triggered by a cycle-by-cycle mode action on PWM0. (WT)
- MCPWM\_TZ1\_CBC\_INT\_CLR Write 1 to clear the interrupt triggered by a cycle-by-cycle mode action on PWM1. (WT)
- MCPWM\_TZ2\_CBC\_INT\_CLR Write 1 to clear the interrupt triggered by a cycle-by-cycle mode action on PWM2. (WT)
- MCPWM\_TZ0\_OST\_INT\_CLR Write 1 to clear the interrupt triggered by a one-shot mode action on PWM0. (WT)
- MCPWM\_TZ1\_OST\_INT\_CLR Write 1 to clear the interrupt triggered by a one-shot mode action on PWM1. (WT)
- MCPWM\_TZ2\_OST\_INT\_CLR Write 1 to clear the interrupt triggered by a one-shot mode action on PWM2. (WT)
- MCPWM\_CAP0\_INT\_CLR Write 1 to clear the interrupt triggered by capture on channel 0. (WT)
- MCPWM\_CAP1\_INT\_CLR Write 1 to clear the interrupt triggered by capture on channel 1. (WT)
- MCPWM\_CAP2\_INT\_CLR Write 1 to clear the interrupt triggered by capture on channel 2. (WT)

## Register 36.73. MCPWM\_EVT\_EN\_REG (0x0120)

![Image](images/36_Chapter_36_img117_5a4761d8.png)

MCPWM\_EVT\_TIMER0\_STOP\_EN Configures whether or not to enable timer0 stop event genera- tion.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TIMER1\_STOP\_EN Configures whether or not to enable timer1 stop event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TIMER2\_STOP\_EN Configures whether or not to enable timer2 stop event genera- tion.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TIMER0\_TEZ\_EN Configures whether or not to enable timer0 equal zero event gen- eration.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TIMER1\_TEZ\_EN Configures whether or not to enable timer1 equal zero event gen- eration.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TIMER2\_TEZ\_EN Configures whether or not to enable timer2 equal zero event gen- eration.

0: Disable

1: Enable

(R/W)

Continued on the next page...

## Register 36.73. MCPWM\_EVT\_EN\_REG (0x0120)

## Continued from the previous page...

MCPWM\_EVT\_TIMER0\_TEP\_EN Configures whether or not to enable timer0 equal period event

generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TIMER1\_TEP\_EN Configures whether or not to enable timer1 equal period event gen- eration.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TIMER2\_TEP\_EN Configures whether or not to enable timer2 equal period event

generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_OP0\_TEA\_EN Configures whether or not to enable PWM generator0 timer equal A

event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_OP1\_TEA\_EN Configures whether or not to enable PWM generator1 timer equal A

event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_OP2\_TEA\_EN Configures whether or not to enable PWM generator2 timer equal A

event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_OP0\_TEB\_EN Configures whether or not to enable PWM generator0 timer equal B

event generation.

0: Disable

1: Enable

(R/W)

Continued on the next page...

## Register 36.73. MCPWM\_EVT\_EN\_REG (0x0120)

## Continued from the previous page...

MCPWM\_EVT\_OP1\_TEB\_EN Configures whether or not to enable PWM generator1 timer equal B

event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_OP2\_TEB\_EN Configures whether or not to enable PWM generator2 timer equal B

event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_F0\_EN Configures whether or not to enable FAULT0 event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_F1\_EN Configures whether or not to enable FAULT1 event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_F2\_EN Configures whether or not to enable FAULT2 event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_F0\_CLR\_EN Configures whether or not to enable FAULT0 clear event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_F1\_CLR\_EN Configures whether or not to enable FAULT1 clear event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_F2\_CLR\_EN Configures whether or not to enable FAULT2 clear event generation.

0: Disable

1: Enable

(R/W)

Continued on the next page...

## Register 36.73. MCPWM\_EVT\_EN\_REG (0x0120)

## Continued from the previous page...

MCPWM\_EVT\_TZ0\_CBC\_EN Configures whether or not to enable cycle by cycle trip0 event gen-

eration.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TZ1\_CBC\_EN Configures whether or not to enable cycle by cycle trip1 event gener- ation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TZ2\_CBC\_EN Configures whether or not to enable cycle by cycle trip2 event gen- eration.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TZ0\_OST\_EN Configures whether or not to enable one shot trip0 event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TZ1\_OST\_EN Configures whether or not to enable one shot trip1 event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_TZ2\_OST\_EN Configures whether or not to enable one shot trip2 event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_CAP0\_EN Configures whether or not to enable capture0 event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_CAP1\_EN Configures whether or not to enable capture1 event generation.

0: Disable

1: Enable

(R/W)

MCPWM\_EVT\_CAP2\_EN Configures whether or not to enable capture2 event generation.

0: Disable

1: Enable

(R/W)

Espressif Systems

## Register 36.74. MCPWM\_TASK\_EN\_REG (0x0124)

![Image](images/36_Chapter_36_img118_0f1bf5ed.png)

MCPWM\_TASK\_CMPR0\_A\_UP\_EN Configures whether or not to receive update task of PWM generator0 timer stamp A's shadow register.

0: No effect

- 1: Receive

(R/W)

MCPWM\_TASK\_CMPR1\_A\_UP\_EN Configures whether or not to receive update task of PWM generator1 timer stamp A's shadow register.

- 0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_CMPR2\_A\_UP\_EN Configures whether or not to receive update task of PWM generator2 timer stamp A's shadow register.

- 0: No effect
- 1: Receive

(R/W)

MCPWM\_TASK\_CMPR0\_B\_UP\_EN Configures whether or not to receive update task of PWM generator0 timer stamp B's shadow register.

- 0: No effect
- 1: Receive

(R/W)

MCPWM\_TASK\_CMPR1\_B\_UP\_EN Configures whether or not to receive update task of PWM generator1 timer stamp B's shadow register.

- 0: No effect
- 1: Receive

(R/W)

MCPWM\_TASK\_CMPR2\_B\_UP\_EN Configures whether or not to receive update task of PWM generator2 timer stamp B's shadow register.

- 0: No effect
- 1: Receive

(R/W)

Continued on the next page...

## Register 36.74. MCPWM\_TASK\_EN\_REG (0x0124)

## Continued from the previous page...

MCPWM\_TASK\_GEN\_STOP\_EN Configures whether or not to receive all PWM generate stop task.

0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_TIMER0\_SYNC\_EN Configures whether or not to receive timer0 sync task.

0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_TIMER1\_SYNC\_EN Configures whether or not to receive timer1 sync task.

0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_TIMER2\_SYNC\_EN Configures whether or not to receive timer2 sync task.

0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_TIMER0\_PERIOD\_UP\_EN Configures whether or not to receive timer0 period up- date task.

0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_TIMER1\_PERIOD\_UP\_EN Configures whether or not to receive timer1 period update task.

0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_TIMER2\_PERIOD\_UP\_EN Configures whether or not to receive timer2 period up- date task.

0: No effect

1: Receive

(R/W)

Continued on the next page...

## Register 36.74. MCPWM\_TASK\_EN\_REG (0x0124)

Continued from the previous page...

MCPWM\_TASK\_TZ0\_OST\_EN Configures whether or not to receive one shot trip0 task.

0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_TZ1\_OST\_EN Configures whether or not to receive one shot trip1 task.

0: No effect

- 1: Receive

(R/W)

MCPWM\_TASK\_TZ2\_OST\_EN Configures whether or not to receive one shot trip2 task.

- 0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_CLR0\_OST\_EN Configures whether or not to receive one shot trip0 clear task.

- 0: No effect
- 1: Receive

(R/W)

MCPWM\_TASK\_CLR1\_OST\_EN Configures whether or not to receive one shot trip1 clear task.

- 0: No effect
- 1: Receive

(R/W)

MCPWM\_TASK\_CLR2\_OST\_EN Configures whether or not to receive one shot trip2 clear task.

- 0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_CAP0\_EN Configures whether or not to receive capture0 task.

- 0: No effect
- 1: Receive

(R/W)

MCPWM\_TASK\_CAP1\_EN Configures whether or not to receive capture1 task.

- 0: No effect

1: Receive

(R/W)

MCPWM\_TASK\_CAP2\_EN Configures whether or not to receive capture2 task.

0: No effect

1: Receive

(R/W)

## Register 36.75. MCPWM\_CLK\_REG (0x0128)

![Image](images/36_Chapter_36_img119_0442e2e7.png)

MCPWM\_CLK\_EN Configures whether or not to force the clock on.

0: No effect

1: Force the clock on

(R/W)

## Register 36.76. MCPWM\_VERSION\_REG (0x012C)

![Image](images/36_Chapter_36_img120_d59785e3.png)

MCPWM\_DATE Version control register. (R/W)
