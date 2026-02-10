---
chapter: 7
title: "Chapter 7"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 7

## IO MUX and GPIO Matrix (GPIO, IO MUX)

## 7.1 Overview

The ESP32-C6 chip features 31 GPIO pins. Each pin can be used as a general-purpose I/O, or be connected to an internal peripheral signal. Through GPIO matrix, IO MUX, and low-power (LP) IO MUX, peripheral input signals can be from any IO pins, and peripheral output signals can be routed to any IO pins. Together these modules provide highly configurable I/O.

## Note:

- The 31 GPIO pins are numbered from GPIO0 ~ GPIO30.
- For chip variants without an in-package flash, GPIO14 is not led out to any chip pins, so GPIO14 is not available to users.
- For chip variants with an in-package flash, GPIO24 ~ GPIO30 are dedicated to connecting the in-package flash, not for other uses. GPIO10 ~ GPIO11 are not led out to any chip pins, thus not available to users. The remaining 22 GPIO pins (numbered GPIO0 ~ GPIO9, GPIO12 ~ GPIO23) are configurable by users.

## 7.2 Features

## GPIO matrix has the following features:

- A full-switching matrix between the peripheral input/output signals and the GPIO pins.
- 85 peripheral input signals sourced from the input of any GPIO pins.
- 93 peripheral output signals routed to the output of any GPIO pins.
- Signal synchronization for peripheral inputs based on IO MUX operating clock. For more information about the operating clock of IO MUX, please refer to Section 8 Reset and Clock .
- GPIO Filter hardware for input signal filtering.
- Glitch Filter hardware for second time filtering on input signal.
- Sigma delta modulated (SDM) output.
- GPIO simple input and output.

## IO MUX has the following features:

- Better high-frequency digital performance achieved by some digital signals (SPI, JTAG, UART) bypassing GPIO matrix. In this case, IO MUX is used to connect these pins directly to peripherals.
- A configuration register IO\_MUX\_GPIOn\_REG provided for each GPIO pin. The pin can be configured to

- – perform GPIO function routed by GPIO matrix;
- – or perform direct connection bypassing GPIO matrix.

## LP IO MUX has the following feature:

- Control of eight LP GPIO pins (GPIO0 ~ GPIO7) that can be used by the peripherals in ULP and LP system.

## 7.3 Architectural Overview

Figure 7.3-1 shows in details how GPIO matrix, IO MUX, and LP IO MUX route signals from pins to peripherals, and from peripherals to pins.

Figure 7.3-1. Architecture of IO MUX, LP IO MUX, and GPIO Matrix

![Image](images/07_Chapter_7_img001_1afb9bfc.png)

1. Only part of peripheral input signals (marked "yes" in column "Direct input through IO MUX" in Table 7.11-1) can bypass GPIO matrix. The other input signals can only be routed to peripherals via GPIO matrix.
2. There are only 31 inputs from GPIO SYNC to GPIO matrix, since ESP32-C6 provides 31 GPIO pins in total. Note:
- For chip variants without an in-package flash, there are 30 inputs from GPIO SYNC to GPIO matrix in total. GPIO14 is not led out to any chip pins.
- For chip variants with an in-package flash, there are only 22 inputs from GPIO SYNC to GPIO matrix in total. GPIO10 ∼ GPIO11 are not let out to chip pins, and GPIO24 ∼ GPIO30 are used to connect the in-package flash.

3. The pins supplied by VDDPST1 or by VDDPST2 are controlled by the signals: IE, OE, WPU, and WPD.
4. Only part of peripheral outputs (marked "yes" in column "Direct output through IO MUX" in Table 7.11-1) can be routed to pins bypassing GPIO matrix. The other output signals can only be routed to pins via GPIO matrix.
5. There are 31 outputs (corresponding to GPIO pin X: 0 ~ 30) from GPIO matrix to IO MUX. Note:
- For chip variants without an in-package flash, there are 30 outputs (corresponding to GPIO X: 0 ~ 13, 15 ~ 30) from GPIO matrix to IO MUX in total.
- For chip variants with an in-package flash, there are only 22 outputs (corresponding to GPIO X: 0 ~ 9, 12 ~ 23) from GPIO matrix to IO MUX in total.

Figure 7.3-2 shows the internal structure of a pad, which is an electrical interface between the chip logic and the GPIO pin. The structure is applicable to all 31 GPIO pins and can be controlled using IE, OE, WPU, and WPD signals.

Figure 7.3-2. Internal Structure of a Pad

![Image](images/07_Chapter_7_img002_3df3a80a.png)

- IE: input enable
- OE: output enable
- WPU: internal weak pull-up resistor
- WPD: internal weak pull-down resistor
- Bonding pad: a terminal point of the chip logic used to make a physical connection from the chip die to GPIO pin in the chip package

## 7.4 Peripheral Input via GPIO Matrix

![Image](images/07_Chapter_7_img003_3bb41b21.png)

## 7.4.1 Overview

To receive a peripheral input signal via GPIO matrix, the matrix is configured to source the peripheral input signal from one of the 31 GPIOs (0 ~ 30), see Table 7.11-1. Meanwhile, the register corresponding to the peripheral signal should be set to receive input signal via GPIO matrix.

As shown in Figure 7.3-1, when GPIO matrix is used to input a signal from the pin, all external input signals are sourced from the GPIO pins and then filtered by the GPIO Filter, as shown in Step 2 in Section 7.4.3 .

The Glitch Filter hardware can filter eight of the output signals from the GPIO Filter, and the other unselected signals go directly to the GPIO SYNC hardware, as shown in Step 3 in Section 7.4.3 .

All signals filtered by the GPIO Filter hardware or the Glitch Filter hardware are synchronized by the GPIO SYNC hardware to IO MUX operating clock and then enter the GPIO matrix, see Section 7.4.2. Such signal filtering and synchronization features apply to all GPIO matrix signals but do not apply when using the IO MUX.

## 7.4.2 Signal Synchronization
GP

on
GPIO Input Synchronization

Figure 7.4-1. GPIO Input Synchronized on Rising Edge or on Falling Edge of IO MUX Operating Clock

![Image](images/07_Chapter_7_img004_edf6a935.png)

Figure 7.4-1 shows the functionality of GPIO SYNC. In the figure, negative sync and positive sync mean GPIO input is synchronized on falling edge and on rising edge of IO MUX operating clock respectively.

The synchronization function is disabled by default by the synchronizer, i.e., GPIO\_PINx\_SYNC1/2\_BYPASS [1:0] = 0. But when an asynchronous peripheral signal is connected to the pin, the signal should be synchronized by the two-level synchronizer (i.e., the first-level synchronizer and the second-level synchronizer as shown in Figure 7.4-1) to lower the probability of causing metastability. For more information, see Step 4 in the following section.

## 7.4.3 Functional Description

To read GPIO pin X 1 into peripheral signal Y, follow the steps below:

1. Configure register GPIO\_FUNCy\_IN\_SEL\_CFG\_REG corresponding to peripheral signal Y in GPIO matrix:
- Set GPIO\_SIGy\_IN\_SEL to enable peripheral signal input via GPIO matrix.
- Set GPIO\_FUNCy\_IN\_SEL to the desired GPIO pin, i.e., X here.

Note that some peripheral signals have no valid GPIO\_SIGy\_IN\_SEL bit, namely, these peripherals can only receive input signals via GPIO matrix.

2. Optionally enable the GPIO Filter for pin input signals by setting IO\_MUX\_GPIOx\_FILTER\_EN. Only the signals with a valid width of more than two clock cycles can be sampled, see Figure 7.4-2 .

![Image](images/07_Chapter_7_img005_2e3ae00f.png)

Figure 7.4-2. GPIO Filter Timing of GPIO Input Signals

3. Glitch filter hardware supports eight channels, each of which selects one signal from the 31 (0~30) output signals from the GPIO Filter hardware and conducts the second-time filtering on the selected signal. This Glitch Filter hardware can be used to filter slow-speed signals. To enable this feature, follow the steps below:
- Configure GPIO\_EXT\_FILTER\_CHn\_INPUT\_IO\_NUM to m . n (0 ~ 7) represents the channel number. m (0 ~ 30) represents the GPIO pin number.
- Configure GPIO\_EXT\_FILTER\_CHn\_WINDOW\_WIDTH to VALUE1 and GPIO\_EXT\_FILTER\_CHn\_WINDOW\_THRES to VALUE2. During VALUE1 + 1 cycles, if there are VALUE2 + 1 input signals that do not match the current output signal value, the Glitch Filter hardware inverts the output signal. GPIO\_EXT\_FILTER\_CHn\_WINDOW\_WIDTH and GPIO\_EXT\_FILTER\_CHn\_WINDOW\_THRES can be configured to the same value VALUE3, then only signals with a width greater than VALUE3 + 1 clock cycles will be sampled.
- Set GPSD\_FILTER\_CHn\_EN to enable channel n .

An example is shown in Figure 7.4-3, where GPIO\_EXT\_FILTER\_CHx\_WINDOW\_WIDTH is configured to 3 and GPIO\_EXT\_FILTER\_CHx\_WINDOW\_THRES to 2. The output signal value (signal\_out) keeps as "0" in the four clock cycles before T1. The input signal value (signal\_in) has been "1" for three clock cycles in the same period, then the output signal is inverted to "1" after T1.

Figure 7.4-3. Glitch Filter Timing Example

![Image](images/07_Chapter_7_img006_fcc09c4d.png)

4. Synchronize GPIO input signals. To do so, please set GPIO\_PINx\_REG corresponding to GPIO pin X as follows:
- Set GPIO\_PINx\_SYNC1\_BYPASS to enable input signal synchronized on rising edge or on falling edge in the first-level synchronization, see Figure 7.4-1 .
- Set GPIO\_PINx\_SYNC2\_BYPASS to enable input signal synchronized on rising edge or on falling edge in the second-level synchronization, see Figure 7.4-1 .
5. Configure IO MUX register to enable pin input. For this end, please set IO\_MUX\_GPIOx\_REG corresponding to GPIO pin X as follows:
- Set IO\_MUX\_GPIOx\_FUN\_IE to enable input 2 .
- Set or clear IO\_MUX\_GPIOx\_FUN\_WPU and IO\_MUX\_GPIOx\_FUN\_WPD as desired to enable or disable pull-up and pull-down resistors.

For example, to connect I2S MSCK input signal 3 (I2S\_MCLK\_in, signal index 12) to GPIO7, please follow the steps below. Note that GPIO7 is also named as MTDO pin.

1. Set GPIO\_SIG12\_IN\_SEL in register GPIO\_FUNC12\_IN\_SEL\_CFG\_REG to enable peripheral signal input via GPIO matrix.
2. Set GPIO\_FUNC12\_IN\_SEL in register GPIO\_FUNC12\_IN\_SEL\_CFG\_REG to 7, i.e., select GPIO7.
3. Set IO\_MUX\_GPIO7\_FUN\_IE in register IO\_MUX\_GPIO7\_REG to enable pin input.

## Note:

1. One input pin can be connected to multiple peripheral input signals.
2. The input signal can be inverted by configuring GPIO\_FUNCy\_IN\_INV\_SEL .
3. It is possible to have a peripheral read a constantly low or constantly high input value without connecting this input to a pin. This can be done by selecting a special GPIO\_FUNCy\_IN\_SEL input, instead of a GPIO number:
- When GPIO\_FUNCy\_IN\_SEL is set to 0x3C, input signal is always 0.
- When GPIO\_FUNCy\_IN\_SEL is set to 0x38, input signal is always 1.

## 7.4.4 Simple GPIO Input

GPIO matrix can also be used for simple GPIO input. For this case, the input value of one GPIO pin can be read at any time without routing the GPIO input to any peripherals. GPIO\_IN\_REG holds the input values of each

GPIO pin.

To implement simple GPIO input, follow the steps below:

- Set IO\_MUX\_GPIOx\_FUN\_IE in register IO\_MUX\_GPIOx\_REG, to enable pin input.
- Read the GPIO input from GPIO\_IN\_REG[x] .

## 7.5 Peripheral Output via GPIO Matrix

## 7.5.1 Overview

To output a signal from a peripheral via GPIO matrix, the matrix is configured to route peripheral output signals (only signals with a name assigned in the column "Output signal" in Table 7.11-1) to one of the 31 GPIOs (0 ~ 30). Note:

- For chip variants without an in-package flash, output signals can be mapped to 30 GPIO pins, i.e., GPIO0 ~ GPIO13, GPIO15 ~ GPIO30.
- For chip variants with an in-package flash, output signals can only be mapped to 22 GPIO pins, i.e., GPIO0 ~ GPIO9, GPIO12 ~ GPIO23.

The output signal is routed from the peripheral into GPIO matrix and then into IO MUX. IO MUX must be configured to set the chosen pin to GPIO function. This enables the GPIO output signal to be connected to the pin.

## Note:

There is a range of peripheral output signals (97 ~ 100 in Table 7.11-1) which are not connected to any peripheral, but to the input signals (97 ~ 100) directly.

## 7.5.2 Functional Description

The 93 output signals (signals with a name assigned in the column "Output signal" in Table 7.11-1) can be set to go through GPIO matrix into IO MUX and then to a pin. Figure 7.3-1 illustrates the configuration.

To output peripheral signal Y to a particular GPIO pin X 1 , follow the steps below:

1. Configure registers GPIO\_FUNCx\_OUT\_SEL\_CFG\_REG and GPIO\_ENABLE\_REG[x] corresponding to GPIO pin X in GPIO matrix. Recommended operation: use corresponding W1TS (write 1 to set) and W1TC (write 1 to clear) registers to set or clear GPIO\_ENABLE\_REG .
- Set the GPIO\_FUNCx\_OUT\_SEL field in register GPIO\_FUNCx\_OUT\_SEL\_CFG\_REG to the index of the desired peripheral output signal Y .
- If the signal should always be enabled as an output, set the GPIO\_FUNCx\_OEN\_SEL bit in register GPIO\_FUNCx\_OUT\_SEL\_CFG\_REG and the bit in register GPIO\_ENABLE\_W1TS\_REG, corresponding to GPIO pin X. To have the output enable signal decided by internal logic (for example, the SPIQ\_oe in column "Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0" in Table 7.11-1), clear the GPIO\_FUNCx\_OEN\_SEL bit instead.
- Set the corresponding bit in register GPIO\_ENABLE\_W1TC\_REG to disable the output from the GPIO pin.

2. For an open drain output, set the GPIO\_PINx\_PAD\_DRIVER bit in register GPIO\_PINx\_REG corresponding to GPIO pin X .
3. Configure IO MUX register to enable output via GPIO matrix. Set IO\_MUX\_GPIOx\_REG corresponding to GPIO pin X as follows:
- Set the field IO\_MUX\_GPIOx\_MCU\_SEL to desired IO MUX function corresponding to GPIO pin X . This is Function 1 (GPIO function), numeric value 1, for all pins.
- Set the IO\_MUX\_GPIOx\_FUN\_DRV field to the desired value for output strength (0 ~ 3). The higher the drive strength, the more current can be sourced/sunk from the pin.
5. – 0: ~5 mA
6. – 1: ~10 mA
7. – 2: ~20 mA (default)
8. – 3: ~40 mA
- If using open drain mode, set/clear the IO\_MUX\_GPIOx\_FUN\_WPU and IO\_MUX\_GPIOx\_FUN\_WPD bits to enable/disable the internal pull-up/pull-down resistors.

## Note:

1. The output signal from a single peripheral can be sent to multiple pins simultaneously.
2. The output signal can be inverted by setting GPIO\_FUNCx\_OUT\_INV\_SEL .

## 7.5.3 Simple GPIO Output

GPIO matrix can also be used for simple GPIO output. For this case, one GPIO pin can be configured to directly output the desired value, without routing any peripheral output to this pin. This can be done as below:

- Set GPIO matrix GPIO\_FUNCn\_OUT\_SEL with a special peripheral index 128 (0x80);
- Set the corresponding bit in GPIO\_OUT\_REG register to the desired GPIO output value.

## Note:

- GPIO\_OUT\_REG[0] ~ GPIO\_OUT\_REG[30] correspond to GPIO0 ~ GPIO30 respectively. GPIO\_OUT\_REG[31] is invalid.
- Recommended operation: use GPIO\_OUT\_W1TS/GPIO\_OUT\_W1TC to set or clear the register GPIO\_OUT\_REG .

## 7.5.4 Sigma Delta Modulated Output (SDM)

## 7.5.4.1 Functional Description

Four out of the 93 peripheral output signals (index: 83 ~ 86 in Table 7.11-1 support 1-bit second-order sigma delta modulation. By default the output is enabled for these four channels. This Sigma Delta modulator can also output PDM (pulse density modulation) signal with configurable duty cycle. The transfer function is:

## Note:

For PDM signals, duty cycle refers to the percentage of high level cycles to the whole statistical period (several pulse cycles, for example, 256 pulse cycles).

## 7.5.4.2 SDM Configuration

The configuration of SDM is shown below:

- Route one of SDM outputs to a pin via GPIO matrix, see Section 7.5.2 .
- Enable the modulator clock by setting GPIO\_EXT\_SD\_FUNCTION\_CLK\_EN .
- Configure the divider value by setting GPIO\_EXT\_SDn\_PRESCALE .
- Configure the duty cycle of SDM output signal by setting GPIO\_EXT\_SDn\_IN .

## 7.6 Direct Input and Output via IO MUX

## 7.6.1 Overview

Some digital signals (SPI and JTAG) can bypass GPIO matrix for better high-frequency digital performance. In this case, IO MUX is used to connect these pins directly to peripherals.

This option is less flexible than routing signals via GPIO matrix, as the IO MUX register for each GPIO pin can only select from a limited number of functions, but high-frequency digital performance can be improved.

<!-- formula-not-decoded -->

E(z) is quantization error and X(z) is the input.

This modulator supports scaling down of IO MUX operating clock by divider 1 ~ 256:

- Set GPIO\_EXT\_SD\_FUNCTION\_CLK\_EN to enable the modulator clock.
- Configure GPIO\_EXT\_SDn\_PRESCALE (n = 0 ~ 3 for the four channels).

After scaling, the clock cycle is equal to one pulse output cycle from the modulator.

GPIO\_EXT\_SDn\_IN is a signed number with a range of [-128, 127] and is used to control the duty cycle 1 of PDM output signal.

- GPIO\_EXT\_SDn\_IN = -128, the duty cycle of the output signal is 0%.
- GPIO\_EXT\_SDn\_IN = 0, the duty cycle of the output signal is near 50%.
- GPIO\_EXT\_SDn\_IN = 127, the duty cycle of the output signal is near 100%.

The formula for calculating PDM signal duty cycle is shown as below:

<!-- formula-not-decoded -->

## 7.6.2 Functional Description

Two fields must be configured in order to bypass GPIO matrix for peripheral input signals:

1. IO\_MUX\_GPIOn\_MCU\_SEL for the GPIO pin must be set to the required pin function. For the list of pin functions, please refer to Section 7.12 .
2. Clear GPIO\_SIGn\_IN\_SEL to route the input directly to the peripheral.

To bypass GPIO matrix for peripheral output signals, IO\_MUX\_GPIOn\_MCU\_SEL for the GPIO pin must be set to the required pin function.

## Note:

Not all signals can be directly connected to peripheral via IO MUX. Some input/output signals can only be connected to peripheral via GPIO matrix.

## 7.7 LP IO MUX for Low Power and Analog Input/Output

## 7.7.1 Overview

ESP32-C6 provides eight GPIO pins with low power (LP) capabilities and analog functions. These pins can be controlled by either IO MUX or LP IO MUX.

If controlled by LP IO MUX, these pins will bypass IO MUX and GPIO matrix for the use by ULP and peripherals in LP system.

When configured as LP GPIOs, the pins can still be controlled by ULP or the peripherals in LP system during chip Deep-sleep, and wake up the chip from Deep-sleep.

## 7.7.2 Low Power Capabilities

The pins with LP functions are controlled by LP\_AON\_GPIO\_MUX\_SEL[n] (n = GPIO0 ~ GPIO7) bit in register LP\_AON\_GPIO\_MUX\_REG. By default, all bits in these registers are set to 0, routing all input/output signals via IO MUX.

If LP\_AON\_GPIO\_MUX\_SEL[n] is set to 1, then input/output signals are controlled by LP IO MUX. In this mode, LP\_IO\_GPIOn\_REG is used to control the LP GPIO pins. See 7.13-1 for the LP functions of each LP GPIO pin. Note that LP\_IO\_GPIOn\_REG applies the LP GPIO pin numbering, not the GPIO pin numbering.

## 7.7.3 Analog Functions

When the pin is used for analog purpose, make sure this pin is left floating by configuring LP\_IO\_GPIOn\_REG . By such way, the external analog signal is directly connected to internal analog signal via GPIO pin. The configuration is as follows:

- Set LP\_AON\_GPIO\_MUX\_SEL[n], to select LP IO MUX to route input and output signals.
- Clear LP\_GPIO\_GPIOn\_FUN\_IE , LP\_GPIO\_GPIOn\_FUN\_RUE, and LP\_GPIO\_GPIOn\_FUN\_RDE, to set the pin floating.
- Configure LP\_GPIO\_GPIOn\_FUN\_SEL to 0, i.e., select Analog Function 0;

- Write 1 to the corresponding bit in LP\_GPIO\_ENABLE\_W1TC, to clear output enable.

See Table 7.13-2 for analog functions of LP GPIO pins.

## 7.8 Pin Functions in Light-sleep

Pins may provide different functions when ESP32-C6 is in Light-sleep mode. If IO\_MUX\_GPIOn\_SLP\_SEL in register IO\_MUX\_GPIOn\_REG for a GPIO pin is set to 1, a different set of bits will be used to control the pin when the chip is in Light-sleep mode.

Table 7.8-1. Bit Used to Control IO MUX Functions in Light-sleep Mode

| IO MUX Function       | Normal Execution  OR IO_MUX_GPIOn_SLP_SEL = 0   | Light-sleep Mode AND IO_MUX_GPIOn_SLP_SEL = 1   |
|-----------------------|-------------------------------------------------|-------------------------------------------------|
| Output Drive Strength | IO_MUX_GPIOn_FUN_DRV                            | IO_MUX_GPIOn_MCU_DRV                            |
| Pull-up Resistor      | IO_MUX_GPIOn_FUN_WPU                            | IO_MUX_GPIOn_MCU_WPU                            |
| Pull-down Resistor    | IO_MUX_GPIOn_FUN_WPD                            | IO_MUX_GPIOn_MCU_WPD                            |
| Input Enable          | IO_MUX_GPIOn_FUN_IE                             | IO_MUX_GPIOn_MCU_IE                             |
| Output Enable         | OEN_SEL from GPIO matrix  ∗                     | IO_MUX_GPIOn_MCU_OE                             |

## Note:

If IO\_MUX\_GPIOn\_SLP\_SEL is set to 0, pin functions remain the same in both normal execution and in Light-sleep mode. Please refer to Section 7.5.2 for how to enable output in normal execution.

## 7.9 Pin Hold Feature

Each GPIO pin (including the LP pins: GPIO0 ~ GPIO7) has an individual hold function controlled by an LP register. When the pin is set to hold, the state is latched at that moment and will not change no matter how the internal signals change or how the IO MUX/GPIO configuration is modified. Users can use the hold function for the pins to retain the pin state through a core reset triggered by watchdog time-out or Deep-sleep events.

To use this feature, follow the steps below:

- Digital pins (GPIO8 ~ GPIO30)
- The Hold state of each digital pin is controlled by the result of OR operation of the pin's Hold enable signal and the global Hold enable signal.
- – LP\_AON\_GPIO\_HOLD0\_REG[n] (n = 8 ~ 30), controls the Hold signal of each pin of GPIO8 ~ GPIO30.
- – PMU\_TIE\_HIGH\_HP\_PAD\_HOLD\_ALL, controls the global Hold signal of all digital pins.

To use this feature, follow the steps below:

- – To maintain pin input/output status in Deep-sleep mode, users can set LP\_AON\_GPIO\_HOLD0\_REG[n] (where n = 8 ~ 30 corresponds to GPIO8 ~ GPIO30) to 1 before

powering down. To disable the hold function after the chip is woken up, users can set LP\_AON\_GPIO\_HOLD0\_REG[n] to 0.

- – Or users can set PMU\_TIE\_HIGH\_HP\_PAD\_HOLD\_ALL to maintain the input/output status of all digital pins, and set PMU\_TIE\_LOW\_HP\_PAD\_HOLD\_ALL to disable the hold function of all digital pins.
- LP pins (GPIO0 ~ GPIO7)

The Hold state of each LP pin is controlled by the result of OR operation of the pin's Hold enable signal and the global Hold enable signal.

- – LP\_AON\_GPIO\_HOLD0\_REG[n] (n = 0 ~ 7), controls the Hold signal of each pin of GPIO0 ~ GPIO7.
- – PMU\_TIE\_HIGH\_LP\_PAD\_HOLD\_ALL and PMU\_TIE\_LOW\_LP\_PAD\_HOLD\_ALL, control the global Hold signal of all LP pins.

To use this feature, follow the steps below:

- – Users can set LP\_AON\_GPIO\_HOLD0\_REG[n] (where n = 0 ~ 7 corresponds to GPIO0 ~ GPIO7) to 1 to hold the value of GPIOn, or set LP\_AON\_GPIO\_HOLD0\_REG[n] to 0 to disable the hold function of GPIOn .
- – Or users can set PMU\_TIE\_HIGH\_LP\_PAD\_HOLD\_ALL to hold the values of all LP pins, and set PMU\_TIE\_LOW\_LP\_PAD\_HOLD\_ALL to disable the hold function of all LP pins.

## 7.10 Power Supplies and Management of GPIO Pins

## 7.10.1 Power Supplies of GPIO Pins

For more information on the power supply for GPIO pins, please refer to Pin Definition in ESP32-C6 Datasheet . All the pins can be used to wake up the chip from Light-sleep mode, but only the pins (GPIO0 ~ GPIO7) in VDDPST1 domain can be used to wake up the chip from Deep-sleep mode.

## 7.10.2 Power Supply Management

Each ESP32-C6 pin is connected to one of the two different power domains.

- VDDPST1: the input power supply for LP GPIOs
- VDDPST2: the input power supply for digital GPIOs

## 7.11 Peripheral Signal List

Table 7.11-1 shows the peripheral input/output signals via GPIO matrix.

Please pay attention to the configuration of the bit GPIO\_FUNCn\_OEN\_SEL:

- GPIO\_FUNCn\_OEN\_SEL = 1: the output enable is controlled by the corresponding bit n of GPIO\_ENABLE\_REG:
- – GPIO\_ENABLE\_REG = 0: output is disabled;
- – GPIO\_ENABLE\_REG = 1: output is enabled;

- GPIO\_FUNCn\_OEN\_SEL = 0: use the output enable signal from peripheral, for example SPIQ\_oe in the column "Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0" of Table 7.11-1. Note that the signals such as SPIQ\_oe can be 1 (1'd1) or 0 (1'd0), depending on the configuration of corresponding peripherals. If it's 1'd1 in column "Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0", it indicates that once GPIO\_FUNCn\_OEN\_SEL is cleared, the output signal is always enabled by default.

## Note:

Signals are numbered consecutively, but not all signals are valid.

- Only the signals with a name assigned in the column "Input signal" in Table 7.11-1 are valid input signals.
- Only the signals with a name assigned in the column "Output signal" in Table 7.11-1 are valid output signals.

![Image](images/07_Chapter_7_img007_b4f96fa8.png)

Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct Outputvia IO MUX

no no

no

Output enable signal when

= 0

\_OEN\_SEL

n

GPIO\_FUNC

Output Signal

Direct Input via IO MUX

Default value

Input Signal no

1’d1

ledc\_ls\_sig\_out0

no

0

ext\_adc\_start

Signal No.

0

no

1’d1

1’d1

1’d1

1’d1

no

1’d1

yes

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

no

1’d1

-

-

-

-

-

-

-

-

GoBack

-

-

-

-

| ledc_ls_sig_out2   |                                                                 |              |                           |                          |    |
|--------------------|-----------------------------------------------------------------|--------------|---------------------------|--------------------------|----|
|                    | ledc_ls_sig_out3  ledc_ls_sig_out4  ledc_ls_sig_out5  U0RTS_out | I2S_MCLK_out | I2SO_SD_out  I2SI_BCK_out |                          |    |
|                    | U0TXD_out  U0DTR_out  U1TXD_out                                 |              |                           | usb_jtag_trst            |    |
| ledc_ls_sig_out1   |                                                                 | U1DTR_out    |                           | I2SO_SD1_out  -  -  -  - | -  |
| -  -               | -  -  -  yes  no  no  no                                        | no  no       | no  no                    | -  no  -  -  -  -        | -  |
| -  -               | -  -  -  0  0  0  1                                             | 0  0         | 0  0                      | -  0  -  -  -  -         | -  |
|                    |                                                                 |              |                           | usb_jtag_tdo_bridge      |    |
|                    | U0CTS_in                                                        | I2S_MCLK_in  |                           |                          |    |
|                    | U0RXD_in                                                        | U1DSR_in     | I2SI_SD_in I2SI_BCK_in    |                          |    |
| -  -               | -  -  -  U0DSR_in U1RXD_in                                      |              |                           | -  -  -  -  -            | -  |
| 1  2               | 3  4  5  6  7  8  9                                             | 11  12       | 15  16                    | 18  19  20  21  22  23   | 25 |

Espressif Systems

257

Submit Documentation Feedback

ESP32-C6 TRM (Version 1.1)

Table 7.11-1. Peripheral Signals via GPIO Matrix

Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct Output via IO MUX

Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0

Output Signal

Direct Input via IO MUX

Default value

Input Signal

-

-

-

-

-

-

-

-

-

-

-

-

Signal No.

26

27

no cpu\_gpio\_out\_oen0

no cpu\_gpio\_out\_oen1

no cpu\_gpio\_out\_oen2

no cpu\_gpio\_out\_oen3

no cpu\_gpio\_out\_oen4

no cpu\_gpio\_out\_oen5

no cpu\_gpio\_out\_oen6

no cpu\_gpio\_out\_oen7

-

-

-

-

-

-

-

-

-

no

I2CEXT0\_SCL\_oe no

no no

no no

GoBack no

no no

I2CEXT0\_SDA\_oe

|                              |                                                                  | -  -  -    | -  -  -  -     | 1’d1  1’d1  1’d1  1’d1  1’d1                                                | 1’d1  1’d1                  |
|------------------------------|------------------------------------------------------------------|------------|----------------|-----------------------------------------------------------------------------|-----------------------------|
|                              | cpu_gpio_out7                                                    |            |                | parl_tx_data4                                                               | parl_tx_data5               |
| cpu_gpio_out0  cpu_gpio_out1 | cpu_gpio_out3  cpu_gpio_out4  cpu_gpio_out5  cpu_gpio_out6       |            |                | I2CEXT0_SDA_out  parl_tx_data0  parl_tx_data1  parl_tx_data2  parl_tx_data3 | parl_tx_data6               |
|                              |                                                                  | -  -  -    | -  -  -  -     |                                                                             |                             |
| no  no                       | no  no  no  no  no                                               | -  -  -    | -  -  -  -     | no  no  no  no  no  no                                                      | no  no                      |
| 0  0                         | 0  0  0  0  0                                                    | -  -  -    | -  -  -  -     | 1  0  0  0  0  0                                                            | 0  0                        |
| cpu_gpio_in1                 |                                                                  | -  -       | -  -  -        |                                                                             |                             |
| cpu_gpio_in0                 | cpu_gpio_in3 cpu_gpio_in4 cpu_gpio_in5 cpu_gpio_in6 cpu_gpio_in7 |            |                | I2CEXT0_SDA_in  parl_rx_data0 parl_rx_data1 parl_rx_data2 parl_rx_data3     | parl_rx_data5 parl_rx_data6 |
|                              |                                                                  | -          | -              | parl_rx_data4                                                               |                             |
| 28  29                       | 31  32  33  34  35                                               | 38  39  40 | 41  42  43  44 | 46  47  48  49  50  51                                                      | 52  53                      |

Espressif Systems

258

Submit Documentation Feedback

ESP32-C6 TRM (Version 1.1)

Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct Output via IO MUX

Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0

Output Signal

Direct Input via IO MUX

Default value

Input Signal no

1’d1

parl\_tx\_data7

no

0

parl\_rx\_data7

no

1’d1

parl\_tx\_data8

no

0

parl\_rx\_data8

Signal No.

54

55

no no

no no

no no

no yes

FSPICLK\_oe yes

FSPIQ\_oe yes

FSPID\_oe yes

yes

FSPIHD\_oe yes

FSPICS0\_oe no

no no

no no

no no

no no

GoBack no

no no

| 1’d1  1’d1  1’d1                              | 1’d1  1’d1  1’d1  1’d1                                                 |            | 1’d1  1’d1  1’d1  1’d1                      | 1’d1  1’d1  1’d1  1’d1  1’d1    | 1’d1  1’d1    |
|-----------------------------------------------|------------------------------------------------------------------------|------------|---------------------------------------------|---------------------------------|---------------|
|                                               |                                                                        |            |                                             | twai0_bus_off_on  twai0_standby | twai1_standby |
|                                               | FSPICLK_out_mux                                                        |            | sdio_tohost_int_out                         | twai0_clkout                    | twai1_clkout  |
| parl_tx_data9  parl_tx_data10  parl_tx_data11 | parl_tx_data12  parl_tx_data13  parl_tx_data14  parl_tx_data15         | FSPIWP_out | parl_tx_clk_out  rmt_sig_out0  rmt_sig_out1 | twai0_tx                        |               |
|                                               |                                                                        |            |                                             | twai1_tx                        |               |
| no  no  no                                    | no  no  no  no  yes                                                    | yes        | no no  no  no                               | no  -  -  -  no                 | -  -          |
| 0  0  0                                       | 0  0  0  0  0                                                          | 0          | 0  0  0  0                                  | 1  -  -  -  1                   | -  -          |
| parl_rx_data11                                | parl_rx_data12 parl_rx_data13 parl_rx_data14 parl_rx_data15 FSPICLK_in |            | parl_rx_clk_in rmt_sig_in0                  | rmt_sig_in1                     |               |
| parl_rx_data9 parl_rx_data10                  |                                                                        | FSPIWP_in  | parl_tx_clk_in                              | twai0_rx  twai1_rx              |               |
|                                               |                                                                        |            |                                             | -  -  -                         | -  -          |
| 56  57  58                                    | 59  60  61  62  63                                                     | 67         | 69  70  71  72                              | 73  74  75  76  77              | 79  80        |

Espressif Systems

FSPIWP\_oe

259

Submit Documentation Feedback

ESP32-C6 TRM (Version 1.1)

Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct Output via IO MUX

Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0

Output Signal

Direct Input via IO MUX

Default value

Input Signal

-

-

-

-

-

-

-

-

-

-

-

-

Signal No.

81

82

no no

no no

no no

no no

no no

-

-

-

-

no no

no no

yes yes

yes yes

yes

-

GoBack

-

-

FSPICS1\_oe

| 1’d1  1’d1  1’d1           | 1’d1  1’d1  1’d1  1’d1  1’d1  1’d1                         | -  -  -                                | -  1’d1  1’d1  1’d1  1’d1                                   |                                                                                        | -  -              |
|----------------------------|------------------------------------------------------------|----------------------------------------|-------------------------------------------------------------|----------------------------------------------------------------------------------------|-------------------|
|                            | pwm0_out0a  pwm0_out0b  pwm0_out1a  pwm0_out1b  pwm0_out2a |                                        |                                                             | FSPICS5_out                                                                            |                   |
| gpio_sd1_out               |                                                            |                                        |                                                             |                                                                                        |                   |
| gpio_sd0_out  gpio_sd2_out | gpio_sd3_out                                               |                                        | sig_in_func97  sig_in_func98  sig_in_func99  sig_in_func100 | FSPICS1_out  FSPICS2_out  FSPICS3_out  FSPICS4_out                                     |                   |
|                            |                                                            | -  -  -                                | -                                                           |                                                                                        | -  -              |
| -  -  -                    | -  no  no  no  no  no                                      | no  no  no                             | -  no  no  no  no                                           | no  no  no  no  no                                                                     | no  no            |
| -  -  -                    | -  0  0  0  0  0                                           | 0  0  0                                | -  0  0  0  0                                               | 0  0  0  0  0                                                                          | 0  0              |
| -  -                       |                                                            | pwm0_cap0_in pwm0_cap1_in pwm0_cap2_in | -  sig_in_func_99                                           |                                                                                        |                   |
|                            | pwm0_sync0_in pwm0_sync1_in pwm0_sync2_in pwm0_f0_in       |                                        | sig_in_func_97 sig_in_func_98                               | pcnt_sig_ch0_in0 pcnt_sig_ch1_in0 pcnt_ctrl_ch0_in0 pcnt_ctrl_ch1_in0 pcnt_sig_ch0_in1 | pcnt_ctrl_ch1_in1 |
| -                          | -  pwm0_f1_in                                              |                                        | sig_in_func_100                                             |                                                                                        | pcnt_ctrl_ch0_in1 |
| 83  84  85                 | 86  87  88  89  90  91                                     | 93  94  95                             | 96  97  98  99  100                                         | 101  102  103  104  105                                                                | 107  108          |

Espressif Systems

260

Submit Documentation Feedback

FSPICS2\_oe

FSPICS3\_oe

FSPICS4\_oe

FSPICS5\_oe

ESP32-C6 TRM (Version 1.1)

Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct Output via IO MUX

Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0

Output Signal

Direct Input via IO MUX

Default value

Input Signal

-

-

-

no

0

pcnt\_sig\_ch0\_in2

-

-

-

no

0

pcnt\_sig\_ch1\_in2

-

-

-

yes

SPICLK\_oe pcnt\_sig\_ch1\_in3

114

yes

SPICS0\_oe pcnt\_ctrl\_ch0\_in3

115

no

SPICS1\_oe pcnt\_ctrl\_ch1\_in3

116

-

-

-

-

yes

SPIQ\_oe

SPIQ\_in

121

yes

SPID\_oe

SPID\_in

122

yes

SPIHD\_oe

SPIHD\_in

123

yes

SPIWP\_oe

SPIWP\_in

124

no no

no

| -  -       | -  -                   |          | 1’d1  1’d1  1’d1           | -   |
|------------|------------------------|----------|----------------------------|-----|
|            | SPICLK_out_mux         |          | CLK_OUT_out2  CLK_OUT_out3 |     |
|            | SPICS0_out  SPICS1_out |          | CLK_OUT_out1               |     |
|            |                        | SPID_out |                            |     |
| -  -       | -  -                   |          |                            | -   |
| no  no  no | no  no  no  -  -       | yes      | -  -  -                    |     |
| 0  0  0    | 0  0  0  -  -          | 0        | -  -  -                    |     |

-

117

-

118

-

119

-

120

-

125

261

Submit Documentation Feedback

-

126

-

127

pcnt\_sig\_ch0\_in3

113

pcnt\_ctrl\_ch1\_in2

112

pcnt\_ctrl\_ch0\_in2

Signal No.

109

110

111

Espressif Systems

GoBack

ESP32-C6 TRM (Version 1.1)

## 7.12 IO MUX Functions List

Table 7.12-1 shows the IO MUX functions of each GPIO pin.

Table 7.12-1. IO MUX Functions List

|   GPIO | Pin Name   | Function 0   | Function 1   | Function 2   | Function 3   |   DRV | Reset   | Notes   |
|--------|------------|--------------|--------------|--------------|--------------|-------|---------|---------|
|      0 | XTAL_32K_P | GPIO0        | GPIO0        | —            | —            |     2 | 0       | R       |
|      1 | XTAL_32K_N | GPIO1        | GPIO1        | —            | —            |     2 | 0       | R       |
|      2 | GPIO2      | GPIO2        | GPIO2        | FSPIQ        | —            |     2 | 1       | R       |
|      3 | GPIO3      | GPIO3        | GPIO3        | —            | —            |     2 | 1       | R       |
|      4 | MTMS       | MTMS         | GPIO4        | FSPIHD       | —            |     2 | 1       | R       |
|      5 | MTDI       | MTDI         | GPIO5        | FSPIWP       | —            |     2 | 1       | R       |
|      6 | MTCK       | MTCK         | GPIO6        | FSPICLK      | —            |     2 | 1*      | R       |
|      7 | MTDO       | MTDO         | GPIO7        | FSPID        | —            |     2 | 1       | R       |
|      8 | GPIO8      | GPIO8        | GPIO8        | —            | —            |     2 | 1       | —       |
|      9 | GPIO9      | GPIO9        | GPIO9        | —            | —            |     2 | 3       | —       |
|     10 | GPIO10     | GPIO10       | GPIO10       | —            | —            |     2 | 1       | S1      |
|     11 | GPIO11     | GPIO11       | GPIO11       | —            | —            |     2 | 1       | S1      |
|     12 | GPIO12     | GPIO12       | GPIO12       | —            | —            |     3 | 1       | USB     |
|     13 | GPIO13     | GPIO13       | GPIO13       | —            | —            |     3 | 3       | USB     |
|     14 | GPIO14     | GPIO14       | GPIO14       | —            | —            |     2 | 1       | S0      |
|     15 | GPIO15     | GPIO15       | GPIO15       | —            | —            |     2 | 1       | —       |
|     16 | U0TXD      | U0TXD        | GPIO16       | FSPICS0      | —            |     2 | 4       | —       |
|     17 | U0RXD      | U0RXD        | GPIO17       | FSPICS1      | —            |     2 | 3       | —       |
|     18 | SDIO_CMD   | SDIO_CMD     | GPIO18       | FSPICS2      | —            |     2 | 3       | —       |
|     19 | SDIO_CLK   | SDIO_CLK     | GPIO19       | FSPICS3      | —            |     2 | 3       | —       |
|     20 | SDIO_DATA0 | SDIO_DATA0   | GPIO20       | FSPICS4      | —            |     2 | 3       | —       |
|     21 | SDIO_DATA1 | SDIO_DATA1   | GPIO21       | FSPICS5      | —            |     2 | 3       | —       |
|     22 | SDIO_DATA2 | SDIO_DATA2   | GPIO22       | —            | —            |     2 | 3       | —       |
|     23 | SDIO_DATA3 | SDIO_DATA3   | GPIO23       | —            | —            |     2 | 3       | —       |
|     24 | SPICS0     | SPICS0       | GPIO24       | —            | —            |     2 | 3       | S1, S2  |
|     25 | SPIQ       | SPIQ         | GPIO25       | —            | —            |     2 | 3       | S1, S2  |
|     26 | SPIWP      | SPIWP        | GPIO26       | —            | —            |     2 | 3       | S1, S2  |
|     27 | VDD_SPI    | GPIO27       | GPIO27       | —            | —            |     2 | 0       | S1, S2  |
|     28 | SPIHD      | SPIHD        | GPIO28       | —            | —            |     2 | 3       | S1, S2  |
|     29 | SPICLK     | SPICLK       | GPIO29       | —            | —            |     2 | 3       | S1, S2  |
|     30 | SPID       | SPID         | GPIO30       | —            | —            |     2 | 3       | S1, S2  |

## Drive Strength

“DRV” column shows the drive strength of each pin after reset:

- 0 - Drive current = ~5 mA
- 1 - Drive current = ~10 mA
- 2 - Drive current = ~20 mA

![Image](images/07_Chapter_7_img008_cc7678cc.png)

- 3 - Drive current = ~40 mA

## Reset Configurations

“Reset” column shows the default configuration of each pin after reset:

- 0 - IE = 0 (input disabled)
- 1 - IE = 1 (input enabled)
- 2 - IE = 1, WPD = 1 (input enabled, pull-down resistor enabled)
- 3 - IE = 1, WPU = 1 (input enabled, pull-up resistor enabled)
- 4 - OE = 1, WPU = 1 (output enabled, pull-up resistor enabled)
- 1* - If EFUSE\_DIS\_PAD\_JTAG = 1, the pin MTCK is left floating after reset, i.e., IE = 1. If EFUSE\_DIS\_PAD\_JTAG = 0, the pin MTCK is connected to internal pull-up resistor, i.e., IE = 1, WPU = 1.

## Note:

- R - Pins in VDDPST1 domain, and part of them have analog functions, see Table 7.13-2 .
- USB - GPIO12 and GPIO13 are USB pins. The pull-up value of the two pins are controlled by the pins' pull-up value together with USB pull-up value. If any one of the pull-up value is 1, the pin's pull-up resistor will be enabled. The pull-up resistors of USB pins are controlled by USB\_SERIAL\_JTAG\_DP\_PULLUP .
- S0 - For chip variants without an in-package flash, this pin can not be used.
- S1 - For chip variants with an in-package flash, this pin can not be used.
- S2 - For chip variants with an in-package flash, this pin can only be used to connect the in-package flash, i.e., only Function 0 is available. For chip variants without an in-package flash, this pin can be used as a normal pin, i.e., all the functions are available.

## 7.13 LP IO MUX Functions List

Table 7.13-1 shows the LP GPIO pins and how they correspond to GPIO pins and LP functions.

Table 7.13-1. LP IO MUX Functions List

| LP GPIO No.   | GPIO No.   | GPIO Pin   | LP Functions   | LP Functions   |
|---------------|------------|------------|----------------|----------------|
| LP GPIO No.   | GPIO No.   | GPIO Pin   | 0              | 1              |
| 0             | 0          | XTAL_32K_P | LP_GPIO0       | lp_uart_dtrn 1 |
| 1             | 1          | XTAL_32K_N | LP_GPIO1       | lp_uart_dsrn 1 |
| 2             | 2          | GPIO2      | LP_GPIO2       | lp_uart_rtsn 1 |
| 3             | 3          | GPIO3      | LP_GPIO3       | lp_uart_ctsn 1 |
| 4             | 4          | MTMS       | LP_GPIO4       | lp_uart_rxd 1  |
| 5             | 5          | MTDI       | LP_GPIO5       | lp_uart_txd 1  |
| 6             | 6          | MTCK       | LP_GPIO6       | lp_i2c_sda 2   |
| 7             | 7          | MTDO       | LP_GPIO7       | lp_i2c_scl 2   |

1 For the configuration of lp\_uart\_xx, please refer to Section: LP UART Controller in Chapter 3 Low-Power CPU .

2 For the configuration of sar\_i2c\_xx, please refer to Section: LP I2C Controller in Chapter 3 Low-Power CPU .

Table 7.13-2 shows the LP GPIO pins and how they correspond to GPIO pins and analog functions.

Table 7.13-2. Analog Functions of IO MUX Pins

| LP GPIO No. 1   |   GPIO No. 1 | Pin Name   | Analog Function 0   | Analog Function 1   |
|-----------------|--------------|------------|---------------------|---------------------|
| 0               |            0 | XTAL_32K_P | XTAL_32K_P          | ADC1_CH0            |
| 1               |            1 | XTAL_32K_N | XTAL_32K_N          | ADC1_CH1            |
| 2               |            2 | GPIO2      | -                   | ADC1_CH2            |
| 3               |            3 | GPIO3      | -                   | ADC1_CH3            |
| 4               |            4 | MTMS       | -                   | ADC1_CH4            |
| 5               |            5 | MTDI       | -                   | ADC1_CH5            |
| 6               |            6 | MTCK       | -                   | ADC1_CH6            |
| -               |           12 | GPIO12 2   | USB_D-              | -                   |
| -               |           13 | GPIO13 2   | USB_D+              | -                   |

## 7.14 Event Task Matrix Function

In ESP32-C6 , GPIO supports ETM function, that is, the ETM task of GPIO can be triggered by the ETM event of any peripheral, or the ETM task of any peripheral can be triggered by the ETM event of GPIO. For more details about ETM, please refer to Chapter 11 Event Task Matrix (SOC\_ETM). Only ETM tasks and ETM events related to GPIO are introduced here.

The GPIO ETM provides eight task channels x (0 ~ 7). The ETM tasks that each task channel can receive are:

- GPIO\_TASK\_CHx\_SET: GPIO goes high when triggered;
- GPIO\_TASK\_CHx\_CLEAR: GPIO goes low when triggered;
- GPIO\_TASK\_CHx\_TOGGLE: GPIO toggle level when triggered.

Below is an example to configure task channel x to control GPIOy:

- Configure IO\_MUX\_GPIOy\_MCU\_SEL to 1, to select Function 1 listed in Table 7.12-1;
- Configure GPIO\_ENABLE\_REG[y] to 1;
- Configure GPIO\_EXT\_ETM\_TASK\_GPIOy\_SEL to x;
- Set GPSD\_ETM\_TASK\_GPIOy\_EN, to enable ETM task channel x to control GPIOy .

## Note:

- One task channel can be selected by one or more GPIOs.
- When two or three of the signals GPIO\_TASK\_CHx\_SET, GPIO\_TASK\_CHx\_CLEAR, and GPIO\_TASK\_CHx \_ TOGGLE of the task channel x selected by GPIOy are valid at the same time, then GPIO\_TASK\_CHx\_SET has the highest priority, GPIO\_TASK\_CHx\_CLEAR takes the second higher priority, and GPIO\_TASK\_CHx\_TOGGLE has the lowest priority.
- When GPIOy is controlled by ETM task channel, the values of GPIO\_OUT\_REG , GPIO\_FUNCn\_OUT\_INV\_SEL, and GPIO\_FUNCn\_OUT\_SEL may be modified by the hardware. For such reason, it's recommended to reconfigure these registers when the GPIO is free from the control of ETM task channel.

GPIO has eight event channels, and the ETM events that each event channel can generate are:

- GPIO\_EVT\_CHx\_RISE\_EDGE: Indicates that the output signal of the corresponding GPIO filter (see Figure 7.3-1) has a rising edge;
- GPIO\_EVT\_CHx\_FALL\_EDGE: Indicates that the output signal of the corresponding GPIO filter (see Figure 7.3-1) has a falling edge;
- GPIO\_EVT\_CHx\_ANY\_EDGE: Indicates that the output signal of the corresponding GPIO filter (see Figure 7.3-1) is reversed.

The specific configuration of the event channel is as follows:

- Set GPIO\_EXT\_ETM\_CHx\_EVENT\_EN to enable event channel x (0 ~ 7).
- Configure GPIO\_EXT\_ETM\_CHx\_EVENT\_SEL to y (0 ~ 30), i.e., select one from the 31 GPIOs.

## Note:

One GPIO can be selected by one or more event channels.

In specific applications, GPIO ETM events can be used to trigger GPIO ETM tasks. For example, event channel 0 selects GPIO0, GPIO1 selects task channel 0, and the GPIO\_EVT\_CH0\_RISE\_EDGE event is used to trigger the GPIO\_TASK\_CH0\_TOGGLE task. When a square wave signal is input to the chip through GPIO0, the chip outputs a square wave signal with a frequency divided by 2 through GPIO1.

## 7.15 Register Summary

## 7.15.1 GPIO Matrix Register Summary

The addresses in this section are relative to GPIO base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

Note: For chip variants with an in-package flash, 22 GPIO pins are available, i.e., GPIO0 ~ GPIO9 and GPIO12 ~ GPIO23. For this case:

- Configuration Registers: can only be configured for GPIO0 ~ GPIO9 and GPIO12 ~ GPIO23.

- Pin Configuration Registers: only GPIO\_PIN0\_REG ~ GPIO\_PIN9\_REG and GPIO\_PIN12\_REG ~ GPIO\_PIN23\_REG are available.
- Input Configuration Registers: can only be configured for GPIO0 ~ GPIO9 and GPIO12 ~ GPIO23.
- Output Configuration Registers: only GPIO\_FUNC0\_OUT\_SEL\_CFG\_REG ~ GPIO\_FUNC9\_OUT\_SEL\_CFG\_REG and GPIO\_PIN12\_OUT\_SEL\_CFG\_REG ~ GPIO\_PIN23\_OUT\_SEL\_CFG\_REG are available.

| Name                           | Description                                 | Address   | Access     |
|--------------------------------|---------------------------------------------|-----------|------------|
| Configuration Registers        |                                             |           |            |
| GPIO_OUT_REG                   | GPIO output register                        | 0x0004    | R/W/SC/WTC |
| GPIO_OUT_W1TS_REG              | GPIO output set register                    | 0x0008    | WT         |
| GPIO_OUT_W1TC_REG              | GPIO output clear register                  | 0x000C    | WT         |
| GPIO_ENABLE_REG                | GPIO output enable register                 | 0x0020    | R/W/WTC    |
| GPIO_ENABLE_W1TS_REG           | GPIO output enable set register             | 0x0024    | WT         |
| GPIO_ENABLE_W1TC_REG           | GPIO output enable clear register           | 0x0028    | WT         |
| GPIO_STRAP_REG                 | Strapping pin register                      | 0x0038    | RO         |
| GPIO_IN_REG                    | GPIO input register                         | 0x003C    | RO         |
| Interrupt Status Registers     |                                             |           |            |
| GPIO_STATUS_REG                | GPIO interrupt status register              | 0x0044    | R/W/WTC    |
| GPIO_STATUS_W1TS_REG           | GPIO interrupt status set register          | 0x0048    | WT         |
| GPIO_STATUS_W1TC_REG           | GPIO interrupt status clear register        | 0x004C    | WT         |
| GPIO_PCPU_INT_REG              | GPIO CPU interrupt status register          | 0x005C    | RO         |
| GPIO_STATUS_NEXT_REG           | GPIO interrupt source register              | 0x014C    | RO         |
| Pin Configuration Registers    |                                             |           |            |
| GPIO_PIN0_REG                  | GPIO0 configuration register                | 0x0074    | R/W        |
| GPIO_PIN1_REG                  | GPIO1 configuration register                | 0x0078    | R/W        |
| GPIO_PIN2_REG                  | GPIO2 configuration register                | 0x007C    | R/W        |
| ...                            | ...                                         | ...       | ...        |
| GPIO_PIN28_REG                 | GPIO28 configuration register               | 0x00E4    | R/W        |
| GPIO_PIN29_REG                 | GPIO29 configuration register               | 0x00E8    | R/W        |
| GPIO_PIN30_REG                 | GPIO30 configuration register               | 0x00EC    | R/W        |
| Input Configuration Registers  |                                             |           |            |
| GPIO_FUNC0_IN_SEL_CFG_REG      | Configuration register for input signal 0   | 0x0154    | R/W        |
| GPIO_FUNC1_IN_SEL_CFG_REG      | Configuration register for input signal 1   | 0x0158    | R/W        |
| GPIO_FUNC2_IN_SEL_CFG_REG      | Configuration register for input signal 2   | 0x015C    | R/W        |
| ...                            | ...                                         | ...       | ...        |
| GPIO_FUNC125_IN_SEL_CFG_REG    | Configuration register for input signal 125 | 0x0348    | R/W        |
| GPIO_FUNC126_IN_SEL_CFG_REG    | Configuration register for input signal 126 | 0x034C    | R/W        |
| GPIO_FUNC127_IN_SEL_CFG_REG    | Configuration register for input signal 127 | 0x0350    | R/W        |
| Output Configuration Registers |                                             |           |            |
| GPIO_FUNC0_OUT_SEL_CFG_REG     | Configuration register for GPIO0 output     | 0x0554    | varies     |
| GPIO_FUNC1_OUT_SEL_CFG_REG     | Configuration register for GPIO1 output     | 0x0558    | varies     |
| GPIO_FUNC2_OUT_SEL_CFG_REG     | Configuration register for GPIO2 output     | 0x055C    | varies     |
| ...                            | ...                                         | ...       | ...        |

| Name                        | Description                              | Address   | Access   |
|-----------------------------|------------------------------------------|-----------|----------|
| GPIO_FUNC28_OUT_SEL_CFG_REG | Configuration register for GPIO28 output | 0x05C4    | varies   |
| GPIO_FUNC29_OUT_SEL_CFG_REG | Configuration register for GPIO29 output | 0x05C8    | varies   |
| GPIO_FUNC30_OUT_SEL_CFG_REG | Configuration register for GPIO30 output | 0x05CC    | varies   |
| Version Register            |                                          |           |          |
| GPIO_DATE_REG               | GPIO version register                    | 0x06FC    | R/W      |
| Clock Gate Register         |                                          |           |          |
| GPIO_CLOCK_GATE_REG         | GPIO clock gate register                 | 0x062C    | R/W      |

## 7.15.2 IO MUX Register Summary

The addresses in this section are relative to the IO MUX base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Note: For chip variants with an in-package flash, only 22 GPIO pins are available, i.e., GPIO0 ~ GPIO9 and GPIO12 ~ GPIO23. For this case, Configuration Registers of IO\_MUX\_GPIO10\_REG ~ IO\_MUX\_GPIO11\_REG and IO\_MUX\_GPIO24\_REG ~ IO\_MUX\_GPIO30\_REG are not configurable.

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                    | Description                              | Address   | Access   |
|-------------------------|------------------------------------------|-----------|----------|
| Configuration Registers |                                          |           |          |
| IO_MUX_PIN_CTRL_REG     | Clock output configuration register      | 0x0000    | R/W      |
| IO_MUX_GPIO0_REG        | IO MUX configuration register for GPIO0  | 0x0004    | R/W      |
| IO_MUX_GPIO1_REG        | IO MUX configuration register for GPIO1  | 0x0008    | R/W      |
| IO_MUX_GPIO2_REG        | IO MUX configuration register for GPIO2  | 0x000C    | R/W      |
| IO_MUX_GPIO3_REG        | IO MUX configuration register for GPIO3  | 0x0010    | R/W      |
| IO_MUX_GPIO4_REG        | IO MUX configuration register for GPIO4  | 0x0014    | R/W      |
| IO_MUX_GPIO5_REG        | IO MUX configuration register for GPIO5  | 0x0018    | R/W      |
| IO_MUX_GPIO6_REG        | IO MUX configuration register for GPIO6  | 0x001C    | R/W      |
| IO_MUX_GPIO7_REG        | IO MUX configuration register for GPIO7  | 0x0020    | R/W      |
| IO_MUX_GPIO8_REG        | IO MUX configuration register for GPIO8  | 0x0024    | R/W      |
| IO_MUX_GPIO9_REG        | IO MUX configuration register for GPIO9  | 0x0028    | R/W      |
| IO_MUX_GPIO10_REG       | IO MUX configuration register for GPIO10 | 0x002C    | R/W      |
| IO_MUX_GPIO11_REG       | IO MUX configuration register for GPIO11 | 0x0030    | R/W      |
| IO_MUX_GPIO12_REG       | IO MUX configuration register for GPIO12 | 0x0034    | R/W      |
| IO_MUX_GPIO13_REG       | IO MUX configuration register for GPIO13 | 0x0038    | R/W      |
| IO_MUX_GPIO14_REG       | IO MUX configuration register for GPIO14 | 0x003C    | R/W      |
| IO_MUX_GPIO15_REG       | IO MUX configuration register for GPIO15 | 0x0040    | R/W      |
| IO_MUX_GPIO16_REG       | IO MUX configuration register for GPIO16 | 0x0044    | R/W      |
| IO_MUX_GPIO17_REG       | IO MUX configuration register for GPIO17 | 0x0048    | R/W      |
| IO_MUX_GPIO18_REG       | IO MUX configuration register for GPIO18 | 0x004C    | R/W      |
| IO_MUX_GPIO19_REG       | IO MUX configuration register for GPIO19 | 0x0050    | R/W      |
| IO_MUX_GPIO20_REG       | IO MUX configuration register for GPIO20 | 0x0054    | R/W      |
| IO_MUX_GPIO21_REG       | IO MUX configuration register for GPIO21 | 0x0058    | R/W      |
| IO_MUX_GPIO22_REG       | IO MUX configuration register for GPIO22 | 0x005C    | R/W      |

| Name              | Description                              | Address   | Access   |
|-------------------|------------------------------------------|-----------|----------|
| IO_MUX_GPIO23_REG | IO MUX configuration register for GPIO23 | 0x0060    | R/W      |
| IO_MUX_GPIO24_REG | IO MUX configuration register for GPIO24 | 0x0064    | R/W      |
| IO_MUX_GPIO25_REG | IO MUX configuration register for GPIO25 | 0x0068    | R/W      |
| IO_MUX_GPIO26_REG | IO MUX configuration register for GPIO26 | 0x006C    | R/W      |
| IO_MUX_GPIO27_REG | IO MUX configuration register for GPIO27 | 0x0070    | R/W      |
| IO_MUX_GPIO28_REG | IO MUX configuration register for GPIO28 | 0x0074    | R/W      |
| IO_MUX_GPIO29_REG | IO MUX configuration register for GPIO29 | 0x0078    | R/W      |
| IO_MUX_GPIO30_REG | IO MUX configuration register for GPIO30 | 0x007C    | R/W      |
| Version Register  |                                          |           |          |
| IO_MUX_DATE_REG   | Version control register                 | 0x00FC    | R/W      |

## 7.15.3 GPIO\_EXT Register Summary

GPIO\_EXT registers consist of SDM registers, Glitch Filter registers, and ETM registers.

The addresses in this section are relative to (GPIO base address + 0x0F00). GPIO base address is provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                  | Description                                         | Address   | Access   |
|---------------------------------------|-----------------------------------------------------|-----------|----------|
| SDM Configure Registers               |                                                     |           |          |
| GPIO_EXT_SIGMADELTA0_REG              | Duty cycle configuration register for SDM channel 0 | 0x0000    | R/W      |
| GPIO_EXT_SIGMADELTA1_REG              | Duty cycle configuration register for SDM channel 1 | 0x0004    | R/W      |
| GPIO_EXT_SIGMADELTA2_REG              | Duty cycle configuration register for SDM channel 2 | 0x0008    | R/W      |
| GPIO_EXT_SIGMADELTA3_REG              | Duty cycle configuration register for SDM channel 3 | 0x000C    | R/W      |
| GPIO_EXT_SIGMADELTA_MISC_REG          | MISC register                                       | 0x0024    | R/W      |
| Glitch Filter Configuration Registers |                                                     |           |          |
| GPIO_EXT_GLITCH_FILTER_CH0_REG        | Glitch Filter configuration register for channel 0  | 0x0030    | R/W      |
| GPIO_EXT_GLITCH_FILTER_CH1_REG        | Glitch Filter configuration register for channel 1  | 0x0034    | R/W      |
| GPIO_EXT_GLITCH_FILTER_CH2_REG        | Glitch Filter configuration register for channel 2  | 0x0038    | R/W      |
| GPIO_EXT_GLITCH_FILTER_CH3_REG        | Glitch Filter configuration register for channel 3  | 0x003C    | R/W      |
| GPIO_EXT_GLITCH_FILTER_CH4_REG        | Glitch Filter configuration register for channel 4  | 0x0040    | R/W      |
| GPIO_EXT_GLITCH_FILTER_CH5_REG        | Glitch Filter configuration register for channel 5  | 0x0044    | R/W      |

| Name                           | Description                                        | Address   | Access   |
|--------------------------------|----------------------------------------------------|-----------|----------|
| GPIO_EXT_GLITCH_FILTER_CH6_REG | Glitch Filter configuration register for channel 6 | 0x0048    | R/W      |
| GPIO_EXT_GLITCH_FILTER_CH7_REG | Glitch Filter configuration register for channel 7 | 0x004C    | R/W      |
| ETM Configuration Registers    |                                                    |           |          |
| GPIO_EXT_ETM_EVENT_CH0_CFG_REG | ETM configuration register for channel 0           | 0x0060    | R/W      |
| GPIO_EXT_ETM_EVENT_CH1_CFG_REG | ETM configuration register for channel 1           | 0x0064    | R/W      |
| GPIO_EXT_ETM_EVENT_CH2_CFG_REG | ETM configuration register for channel 2           | 0x0068    | R/W      |
| GPIO_EXT_ETM_EVENT_CH3_CFG_REG | ETM configuration register for channel 3           | 0x006C    | R/W      |
| GPIO_EXT_ETM_EVENT_CH4_CFG_REG | ETM configuration register for channel 4           | 0x0070    | R/W      |
| GPIO_EXT_ETM_EVENT_CH5_CFG_REG | ETM configuration register for channel 5           | 0x0074    | R/W      |
| GPIO_EXT_ETM_EVENT_CH6_CFG_REG | ETM configuration register for channel 6           | 0x0078    | R/W      |
| GPIO_EXT_ETM_EVENT_CH7_CFG_REG | ETM configuration register for channel 7           | 0x007C    | R/W      |
| GPIO_EXT_ETM_TASK_P0_CFG_REG   | GPIO selection register 0 for ETM                  | 0x00A0    | R/W      |
| GPIO_EXT_ETM_TASK_P1_CFG_REG   | GPIO selection register 1 for ETM                  | 0x00A4    | R/W      |
| GPIO_EXT_ETM_TASK_P2_CFG_REG   | GPIO selection register 2 for ETM                  | 0x00A8    | R/W      |
| GPIO_EXT_ETM_TASK_P3_CFG_REG   | GPIO selection register 3 for ETM                  | 0x00AC    | R/W      |
| GPIO_EXT_ETM_TASK_P4_CFG_REG   | GPIO selection register 4 for ETM                  | 0x00B0    | R/W      |
| GPIO_EXT_ETM_TASK_P5_CFG_REG   | GPIO selection register 5 for ETM                  | 0x00B4    | R/W      |
| GPIO_EXT_ETM_TASK_P6_CFG_REG   | GPIO selection register 6 for ETM                  | 0x00B8    | R/W      |
| GPIO_EXT_ETM_TASK_P7_CFG_REG   | GPIO selection register 7 for ETM                  | 0x00BC    | R/W      |
| Version Register               |                                                    |           |          |
| GPIO_EXT_VERSION_REG           | Version control register                           | 0x00FC    | R/W      |

## 7.15.4 LP IO MUX Register Summary

The addresses in this section are relative to LP\_IO base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                              | Description                             | Address                           | Access                            |
|-----------------------------------|-----------------------------------------|-----------------------------------|-----------------------------------|
| GPIO Configuration/Data Registers | GPIO Configuration/Data Registers       | GPIO Configuration/Data Registers | GPIO Configuration/Data Registers |
| LP_IO_OUT_REG                     | LP GPIO output register                 | 0x0000                            | R/W                               |
| LP_IO_OUT_W1TS_REG                | LP GPIO output set register             | 0x0004                            | WT                                |
| LP_IO_OUT_W1TC_REG                | LP GPIO output clear register           | 0x0008                            | WT                                |
| LP_IO_ENABLE_REG                  | LP GPIO output enable register          | 0x000C                            | R/W                               |
| LP_IO_ENABLE_W1TS_REG             | LP GPIO output enable set register      | 0x0010                            | WT                                |
| LP_IO_ENABLE_W1TC_REG             | LP GPIO output enable clear register    | 0x0014                            | WT                                |
| LP_IO_STATUS_REG                  | LP GPIO interrupt status register       | 0x0018                            | R/W                               |
| LP_IO_STATUS_W1TS_REG             | LP GPIO interrupt status set register   | 0x001C                            | WT                                |
| LP_IO_STATUS_W1TC_REG             | LP GPIO interrupt status clear register | 0x0020                            | WT                                |
| LP_IO_IN_REG                      | LP GPIO input register                  | 0x0024                            | RO                                |
| LP_IO_PIN0_REG                    | LP GPIO0 configuration register         | 0x0028                            | R/W                               |

| Name                                     | Description                                | Address                                  | Access                                   |
|------------------------------------------|--------------------------------------------|------------------------------------------|------------------------------------------|
| LP_IO_PIN1_REG                           | LP GPIO1 configuration register            | 0x002C                                   | R/W                                      |
| LP_IO_PIN2_REG                           | LP GPIO2 configuration register            | 0x0030                                   | R/W                                      |
| LP_IO_PIN3_REG                           | LP GPIO3 configuration register            | 0x0034                                   | R/W                                      |
| LP_IO_PIN4_REG                           | LP GPIO4 configuration register            | 0x0038                                   | R/W                                      |
| LP_IO_PIN5_REG                           | LP GPIO5 configuration register            | 0x003C                                   | R/W                                      |
| LP_IO_PIN6_REG                           | LP GPIO6 configuration register            | 0x0040                                   | R/W                                      |
| LP_IO_PIN7_REG                           | LP GPIO7 configuration register            | 0x0044                                   | R/W                                      |
| GPIO LP Function Configuration Registers | GPIO LP Function Configuration Registers   | GPIO LP Function Configuration Registers | GPIO LP Function Configuration Registers |
| LP_IO_GPIO0_REG                          | LP IO MUX configuration register for GPIO0 | 0x0048                                   | R/W                                      |
| LP_IO_GPIO1_REG                          | LP IO MUX configuration register for GPIO1 | 0x004C                                   | R/W                                      |
| LP_IO_GPIO2_REG                          | LP IO MUX configuration register for GPIO2 | 0x0050                                   | R/W                                      |
| LP_IO_GPIO3_REG                          | LP IO MUX configuration register for GPIO3 | 0x0054                                   | R/W                                      |
| LP_IO_GPIO4_REG                          | LP IO MUX configuration register for GPIO4 | 0x0058                                   | R/W                                      |
| LP_IO_GPIO5_REG                          | LP IO MUX configuration register for GPIO5 | 0x005C                                   | R/W                                      |
| LP_IO_GPIO6_REG                          | LP IO MUX configuration register for GPIO6 | 0x0060                                   | R/W                                      |
| LP_IO_GPIO7_REG                          | LP IO MUX configuration register for GPIO7 | 0x0064                                   | R/W                                      |
| LP_IO_STATUS_INT_REG                     | LP GPIO interrupt source register          | 0x0068                                   | RO                                       |
| Version Register                         | Version Register                           | Version Register                         | Version Register                         |
| LP_IO_DATE_REG                           | Version control regiter                    | 0x03FC                                   | R/W                                      |

## 7.16 Registers

## 7.16.1 GPIO Matrix Registers

The addresses in this section are relative to GPIO base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 7.1. GPIO\_OUT\_REG (0x0004)

![Image](images/07_Chapter_7_img009_a45a6dd2.png)

GPIO\_OUT\_DATA\_ORIG Configures the output value of GPIO0 ~ 30 output in simple GPIO output mode.

0: Low level

1: High level

The value of bit0 ~ bit30 correspond to the output value of GPIO0 ~ GPIO30 respectively. Bit31 is invalid.

(R/W/SC/WTC)

## Register 7.2. GPIO\_OUT\_W1TS\_REG (0x0008)

![Image](images/07_Chapter_7_img010_2ecbbab3.png)

![Image](images/07_Chapter_7_img011_ff7ac56e.png)

GPIO\_OUT\_W1TS Configures whether or not to set the output register GPIO\_OUT\_REG of GPIO0 ~ GPIO30.

- 0: Not set
- 1: The corresponding bit in GPIO\_OUT\_REG will be set to 1

Bit0 ~ bit30 are corresponding to GPIO0 ~ GPIO30. Bit31 is invalid. Recommended operation: use this register to set GPIO\_OUT\_REG .

(WT)

## Register 7.3. GPIO\_OUT\_W1TC\_REG (0x000C)

![Image](images/07_Chapter_7_img012_8d3519ff.png)

GPIO\_OUT\_W1TC Configures whether or not to clear the output register GPIO\_OUT\_REG of GPIO0 ~

- GPIO30 output.
- 0: Not clear
- 1: The corresponding bit in GPIO\_OUT\_REG will be cleared.

Bit0 ~ bit30 are corresponding to GPIO0 ~ GPIO30. Bit31 is invalid. Recommended operation: .

- use this register to clear GPIO\_OUT\_REG

(WT)

## Register 7.4. GPIO\_ENABLE\_REG (0x0020)

![Image](images/07_Chapter_7_img013_e8ee92dc.png)

GPIO\_ENABLE\_DATA Configures whether or not to enable the output of GPIO0 ~ GPIO30.

0: Not enable

1: Enable

Bit0 ~ bit30 are corresponding to GPIO0

(R/W/WTC)

~ GPIO30. Bit31 is invalid.

## Register 7.5. GPIO\_ENABLE\_W1TS\_REG (0x0024)

![Image](images/07_Chapter_7_img014_5e4835e8.png)

GPIO\_ENABLE\_W1TS Configures whether or not to set the output enable register GPIO\_ENABLE\_REG of GPIO0 ~ GPIO30.

0: Not set

1: The corresponding bit in GPIO\_ENABLE\_REG will be set to 1

~ GPIO30. Bit31 is invalid. Recommended operation:

.

Bit0 ~ bit30 are corresponding to GPIO0 use this register to set GPIO\_ENABLE\_REG

(WT)

## Register 7.6. GPIO\_ENABLE\_W1TC\_REG (0x0028)

![Image](images/07_Chapter_7_img015_a65d57ec.png)

GPIO\_ENABLE\_W1TC Configures whether or not to clear the output enable register GPIO\_ENABLE\_REG of GPIO0 ~ GPIO30.

- 0: Not clear
- 1: The corresponding bit in GPIO\_ENABLE\_REG will be cleared

Bit0 ~ bit30 are corresponding to GPIO0 ~ 30. Bit31 is invalid. Recommended operation: use this register to clear GPIO\_ENABLE\_REG .

(WT)

## Register 7.7. GPIO\_STRAP\_REG (0x0038)

![Image](images/07_Chapter_7_img016_ed9f3360.png)

GPIO\_STRAPPING Represents the values of GPIO strapping pins.

- bit0 ~ bit1: invalid
- bit2: GPIO8
- bit3: GPIO9
- bit4: GPIO15
- bit5: MTMS
- bit6: MTDI
- bit7 ~ bit15: invalid

(RO)

## Register 7.8. GPIO\_IN\_REG (0x003C)

![Image](images/07_Chapter_7_img017_9f0b4795.png)

GPIO\_IN\_DATA\_NEXT Represents the input value of GPIO0 ~ GPIO30. Each bit represents a pin input value:

0: Low level

1: High level

Bit0 ~ bit30 are corresponding to GPIO0 ~ GPIO30. Bit31 is invalid.

(RO)

## Register 7.9. GPIO\_STATUS\_REG (0x0044)

![Image](images/07_Chapter_7_img018_549c2f0b.png)

GPIO\_STATUS\_INTERRUPT The interrupt status of GPIO0 ~ GPIO30, can be configured by the software.

- Bit0 ~ bit30 are corresponding to GPIO0 ~ GPIO30. Bit31 is invalid.
- Each bit represents the status of its corresponding GPIO:
- – 0: Represents the GPIO does not generate the interrupt configured by GPIO\_PINn\_INT\_TYPE, or this bit is configured to 0 by the software.
- – 1: Represents the GPIO generates the interrupt configured by GPIO\_PINn\_INT\_TYPE , or this bit is configured to 1 by the software.

(R/W/WTC)

## Register 7.10. GPIO\_STATUS\_W1TS\_REG (0x0048)

![Image](images/07_Chapter_7_img019_90c3e771.png)

GPIO\_STATUS\_W1TS Configures whether or not to set the interrupt status register GPIO\_STATUS\_INTERRUPT of GPIO0 ~ GPIO30.

- Bit0 ~ bit30 are corresponding to GPIO0 ~ GPIO30. Bit31 is invalid.
- If the value 1 is written to a bit here, the corresponding bit in GPIO\_STATUS\_INTERRUPT will be set to 1.
- Recommended operation: use this register to set GPIO\_STATUS\_INTERRUPT .

(WT)

## Register 7.11. GPIO\_STATUS\_W1TC\_REG (0x004C)

![Image](images/07_Chapter_7_img020_a7638466.png)

GPIO\_STATUS\_W1TC Configures whether or not to clear the interrupt status register GPIO\_STATUS\_INTERRUPT of GPIO0 ~ GPIO30.

- Bit0 ~ bit30 are corresponding to GPIO0 ~ GPIO30. Bit31 is invalid.
- If the value 1 is written to a bit here, the corresponding bit in GPIO\_STATUS\_INTERRUPT will be cleared.
- Recommended operation: use this register to clear GPIO\_STATUS\_INTERRUPT .

(WT)

## Register 7.12. GPIO\_PCPU\_INT\_REG (0x005C)

![Image](images/07_Chapter_7_img021_fee5f38a.png)

![Image](images/07_Chapter_7_img022_bebe4abf.png)

GPIO\_PROCPU\_INT Represents the CPU interrupt status of GPIO0 ~ GPIO30. Each bit represents:

- 0: Represents CPU interrupt is not enabled, or the GPIO does not generate the interrupt configured by GPIO\_PINn\_INT\_TYPE .

1: Represents the GPIO generates an interrupt configured by GPIO\_PINn\_INT\_TYPE after the CPU interrupt is enabled.

Bit0 ~ bit30 are corresponding to GPIO0 ~ GPIO30. Bit31 is invalid. This interrupt status is corresponding to the bit in GPIO\_STATUS\_REG when assert (high) enable signal (bit13 of GPIO\_PINn\_REG).

(RO)

## Register 7.13. GPIO\_PINn\_REG (n: 0-30) (0x0074+4*n)

![Image](images/07_Chapter_7_img023_a2ea3dd8.png)

GPIO\_PINn\_SYNC2\_BYPASS Configures whether or not to synchronize GPIO input data on either edge of IO MUX operating clock for the second-level synchronization.

- 0: Not synchronize
- 1: Synchronize on falling edge
- 2: Synchronize on rising edge
- 3: Synchronize on rising edge (R/W)

GPIO\_PINn\_PAD\_DRIVER Configures to select pin drive mode.

- 0: Normal output
- 1: Open drain output

(R/W)

GPIO\_PINn\_SYNC1\_BYPASS Configures whether or not to synchronize GPIO input data on either edge of IO MUX operating clock for the first-level synchronization.

- 0: Not synchronize
- 1: Synchronize on falling edge
- 2: Synchronize on rising edge
- 3: Synchronize on rising edge
- (R/W)

GPIO\_PINn\_INT\_TYPE Configures GPIO interrupt type.

- 0: GPIO interrupt disabled
- 1: Rising edge trigger
- 2: Falling edge trigger
- 3: Any edge trigger
- 4: Low level trigger
- 5: High level trigger (R/W)

GPIO\_PINn\_WAKEUP\_ENABLE Configures whether or not to enable GPIO wake-up function.

- 0: Disable
- 1: Enable
- This function only wakes up the CPU from Light-sleep.

(R/W)

Continued on the next page...

Register 7.13. GPIO\_PINn\_REG (n: 0-30) (0x0074+4*n)

## Continued from the previous page...

GPIO\_PINn\_INT\_ENA Configures whether or not to enable CPU interrupt or CPU non-maskable interrupt.

- bit13: Configures whether or not to enable CPU interrupt:
- 0: Disable
- 1: Enable
- bit14: Configures CPU non-maskable interrupt:
- 0: Disable
- 1: Enable
- bit15 ~ bit17: invalid

(R/W)

## Register 7.14. GPIO\_STATUS\_NEXT\_REG (0x014C)

![Image](images/07_Chapter_7_img024_968662a8.png)

GPIO\_STATUS\_INTERRUPT\_NEXT Represents the interrupt source signal of GPIO0 ~ GPIO30.

Bit0 ~ bit30 are corresponding to GPIO0 ~ 30. Bit31 is invalid. Each bit represents:

- 0: The GPIO does not generate the interrupt configured by GPIO\_PINn\_INT\_TYPE .
- 1: The GPIO generates an interrupt configured by GPIO\_PINn\_INT\_TYPE .

The interrupt could be rising edge interrupt, falling edge interrupt, level sensitive interrupt and any edge interrupt.

(RO)

## Register 7.15. GPIO\_FUNCn\_IN\_SEL\_CFG\_REG (n: 0-127) (0x0154+4*n)

![Image](images/07_Chapter_7_img025_2e21bc8e.png)

GPIO\_FUNCn\_IN\_SEL Configures to select a pin from the 31 GPIO pins to connect the input signal

n

.

0: Select GPIO0

1: Select GPIO1

......

29: Select GPIO29

30: Select GPIO30

Or

- 0x38: A constantly high input

0x3C: A constantly low input

(R/W)

GPIO\_FUNCn\_IN\_INV\_SEL Configures whether or not to invert the input value.

- 0: Not invert

1: Invert

(R/W)

GPIO\_SIGn\_IN\_SEL Configures whether or not to route signals via GPIO matrix.

- 0: Bypass GPIO matrix, i.e., connect signals directly to peripheral configured in IO MUX.
- 1: Route signals via GPIO matrix.

(R/W)

## Register 7.16. GPIO\_FUNCn\_OUT\_SEL\_CFG\_REG (n: 0-30) (0x0554+4*n)

![Image](images/07_Chapter_7_img026_d4dcca7e.png)

GPIO\_FUNCn\_OUT\_SEL Configures to select a signal Y (0 &lt;= Y &lt; 128) from 128 peripheral signals to be output from GPIOn .

0: Select signal 0

1: Select signal 1

......

126: Select signal 126

127: Select signal 127

Or

128: Bit n of GPIO\_OUT\_REG and GPIO\_ENABLE\_REG are selected as the output value and output enable.

For the detailed signal list, see Table 7.11-1 .

(R/W/SC)

GPIO\_FUNCn\_OUT\_INV\_SEL Configures whether or not to invert the output value.

0: Not invert

1: Invert

(R/W/SC)

GPIO\_FUNCn\_OEN\_SEL Configures to select the source of output enable signal.

- 0: Use output enable signal from peripheral.
- 1: Force the output enable signal to be sourced from bit n of GPIO\_ENABLE\_REG .

(R/W)

GPIO\_FUNCn\_OEN\_INV\_SEL Configures whether or not to invert the output enable signal.

- 0: Not invert

1: Invert

(R/W)

## Register 7.17. GPIO\_CLOCK\_GATE\_REG (0x062C)

![Image](images/07_Chapter_7_img027_72584f6b.png)

GPIO\_CLK\_EN Configures whether or not to enable clock gate.

- 0: Not enable
- 1: Enable, the clock is free running.

(R/W)

![Image](images/07_Chapter_7_img028_40434a27.png)

## 7.16.2 IO MUX Registers

The addresses in this section are relative to the IO MUX base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 7.19. IO\_MUX\_PIN\_CTRL\_REG (0x0000)

![Image](images/07_Chapter_7_img029_52456709.png)

IO\_MUX\_CLK\_OUTx (x: 1 - 3) Configures the output clock for I2S.

0x0: Select CLK\_OUT\_outx for I2S output clock.

CLK\_OUT\_outx can be found in Table 7.11-1 .

(R/W)

## Register 7.20. IO\_MUX\_GPIOn\_REG (n: 0-30) (0x0004+4*n)

![Image](images/07_Chapter_7_img030_f8a98fc7.png)

- IO\_MUX\_GPIOn\_MCU\_OE Configures whether or not to enable the output of GPIOn in sleep mode.
- 0: Disable

1: Enable

(R/W)

- IO\_MUX\_GPIOn\_SLP\_SEL Configures whether or not to enter sleep mode for GPIOn .

0: Not enter

1: Enter

(R/W)

- IO\_MUX\_GPIOn\_MCU\_WPD Configure whether or not to enable pull-down resistor of GPIOn in sleep
- mode.
- 0: Disable

1: Enable

(R/W)

- IO\_MUX\_GPIOn\_MCU\_WPU Configures whether or not to enable pull-up resistor of GPIOn during sleep mode.

0: Disable

1: Enable

(R/W)

- IO\_MUX\_GPIOn\_MCU\_IE Configures whether or not to enable the input of GPIOn during sleep mode.
- 0: Disable

1: Enable

(R/W)

- IO\_MUX\_GPIOn\_MCU\_DRV Configures the drive strength of GPIOn during sleep mode.
- 0: ~5 mA

1: ~10 mA

2: ~20 mA

3: ~40 mA

(R/W)

- IO\_MUX\_GPIOn\_FUN\_WPD Configures whether or not to enable pull-down resistor of GPIOn .

0: Disable

1: Enable

(R/W)

## Continued on the next page...

## Register 7.20. IO\_MUX\_GPIOn\_REG (n: 0-30) (0x0004+4*n)

## Continued from the previous page...

- IO\_MUX\_GPIOn\_FUN\_WPU Configures whether or not enable pull-up resistor of GPIOn .

0: Disable

1: Enable

```
(R/W)
```

- IO\_MUX\_GPIOn\_FUN\_IE Configures whether or not to enable input of GPIOn .

0: Disable

1: Enable

```
(R/W)
```

- IO\_MUX\_GPIOn\_FUN\_DRV Configures the drive strength of GPIOn .

0: ~5 mA

1: ~10 mA

2: ~20 mA

3: ~40 mA

(R/W)

- IO\_MUX\_GPIOn\_MCU\_SEL Configures to select IO MUX function for this signal.

0: Select Function 0

```
1: Select Function 1 ......
```

(R/W)

- IO\_MUX\_GPIOn\_FILTER\_EN Configures whether or not to enable filter for pin input signals.

0: Disable

1: Enable

```
(R/W)
```

Register 7.21. IO\_MUX\_DATE\_REG (0x00FC)

![Image](images/07_Chapter_7_img031_5d5bd49a.png)

- IO\_MUX\_DATE\_REG Version control register.

(R/W)

## 7.16.3 GPIO\_EXT Registers

The addresses in this section are relative to (GPIO base address + 0x0F00). GPIO base address is provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 7.22. GPIO\_EXT\_SIGMADELTAn\_REG (n: 0-3) (0x0000+0x4*n)

![Image](images/07_Chapter_7_img032_cf733dcb.png)

GPIO\_EXT\_SDn\_IN (n: 0 - 3) Configures the duty cycle of sigma delta modulation output. (R/W)

GPIO\_EXT\_SDn\_PRESCALE (n: 0 - 3) Configures the divider value to divide IO MUX operating clock. (R/W)

Register 7.23. GPIO\_EXT\_SIGMADELTA\_MISC\_REG (0x0024)

![Image](images/07_Chapter_7_img033_c394a71e.png)

GPIO\_EXT\_SD\_FUNCTION\_CLK\_EN Configures whether or not to enable the clock for sigma delta modulation.

0: Not enable

1: Enable

(R/W)

Register 7.24. GPIO\_EXT\_GLITCH\_FILTER\_CHn\_REG (n: 0-7) (0x0030+0x4*n)

![Image](images/07_Chapter_7_img034_74c0327a.png)

GPIO\_EXT\_FILTER\_CHn\_EN Configures whether or not to enable channel n of Glitch Filter.

0: Not enable

1: Enable

(R/W)

GPIO\_EXT\_FILTER\_CHn\_INPUT\_IO\_NUM Configures to select the input GPIO for Glitch Filter.

0: Select GPIO0

1: Select GPIO1

......

29: Select GPIO29

30: Select GPIO30

(R/W)

GPIO\_EXT\_FILTER\_CHn\_WINDOW\_THRES Configures the window threshold for Glitch Filter. The window threshold should be less than or equal to GPIO\_EXT\_FILTER\_CHn\_WINDOW\_WIDTH . Measurement unit: IO MUX operating clock cycle (R/W)

GPIO\_EXT\_FILTER\_CHn\_WINDOW\_WIDTH Configures the window width for Glitch Filter. The effective value of window width is 0 ~ 62. 63 is a reserved value and cannot be used.

Measurement unit: IO MUX operating clock cycle

(R/W)

Register 7.25. GPIO\_EXT\_ETM\_EVENT\_CHn\_CFG\_REG (n: 0-7) (0x0060+0x4*n)

![Image](images/07_Chapter_7_img035_eb6c1a5c.png)

GPIO\_EXT\_ETM\_CHn\_EVENT\_SEL Configures to select GPIO for ETM event channel.

0: Select GPIO0

1: Select GPIO1

......

29: Select GPIO29

30: Select GPIO30

(R/W)

GPIO\_EXT\_ETM\_CHn\_EVENT\_EN Configures whether or not to enable ETM event send.

0: Not enable

1: Enable

(R/W)

## Register 7.26. GPIO\_EXT\_ETM\_TASK\_P0\_CFG\_REG (0x00A0)

![Image](images/07_Chapter_7_img036_9cf9a5ce.png)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_EN (n: 0 - 3) Configures whether or not to enable GPIOn to re- sponse ETM task.

0: Not enable

1: Enable

(R/W)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_SEL (n: 0 - 3) Configures to select an ETM task channel for GPIOn .

0: Select channel 0

1: Select channel 1

......

7: Select channel 7

(R/W)

## Register 7.27. GPIO\_EXT\_ETM\_TASK\_P1\_CFG\_REG (0x00A4)

![Image](images/07_Chapter_7_img037_5c884e61.png)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_EN (n: 4 - 7) Configures whether or not to enable GPIOn to response ETM task.

0: Not enable

1: Enable

(R/W)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_SEL (n: 4 - 7) Configures to select an ETM task channel for GPIOn .

0: Select channel 0

1: Select channel 1

......

7: Select channel 7

(R/W)

## Register 7.28. GPIO\_EXT\_ETM\_TASK\_P2\_CFG\_REG (0x00A8)

![Image](images/07_Chapter_7_img038_5e46943f.png)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_EN (n: 8 - 11) Configures whether or not to enable GPIOn to response ETM task.

0: Not enable

1: Enable

(R/W)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_SEL (n: 8 - 11) Configures to select an ETM task channel for GPIOn .

0: Select channel 0

1: Select channel 1

......

7: Select channel 7

(R/W)

## Register 7.29. GPIO\_EXT\_ETM\_TASK\_P3\_CFG\_REG (0x00AC)

![Image](images/07_Chapter_7_img039_d65c512b.png)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_EN (n: 12 - 15) Configures whether or not to enable GPIOn to response ETM task.

0: Not enable

1: Enable

(R/W)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_SEL (n: 12 - 15) Configures to select an ETM task channel for GPIOn .

0: Select channel 0

1: Select channel 1

......

7: Select channel 7

(R/W)

## Register 7.30. GPIO\_EXT\_ETM\_TASK\_P4\_CFG\_REG (0x00B0)

![Image](images/07_Chapter_7_img040_3dc0181b.png)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_EN (n: 16 - 19) Configures whether or not to enable GPIOn to response ETM task.

0: Not enable

1: Enable

(R/W)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_SEL (n: 16 - 19) Configures to select an ETM task channel for GPIOn .

0: Select channel 0

1: Select channel 1

......

7: Select channel 7

(R/W)

## Register 7.31. GPIO\_EXT\_ETM\_TASK\_P5\_CFG\_REG (0x00B4)

![Image](images/07_Chapter_7_img041_0c0cd869.png)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_EN (n: 20 - 23) Configures whether or not to enable GPIOn to response ETM task.

0: Not enable

1: Enable

(R/W)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_SEL (n: 20 - 23) Configures to select an ETM task channel for GPIOn .

0: Select channel 0

1: Select channel 1

......

7: Select channel 7

(R/W)

## Register 7.32. GPIO\_EXT\_ETM\_TASK\_P6\_CFG\_REG (0x00B8)

![Image](images/07_Chapter_7_img042_c25ed2ed.png)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_EN (n: 24 - 27) Configures whether or not to enable GPIOn to response ETM task.

0: Not enable

1: Enable

(R/W)

- GPIO\_EXT\_ETM\_TASK\_GPIOn\_SEL (n: 24 - 27) Configures to select an ETM task channel for GPIOn .

0: Select channel 0

1: Select channel 1

......

7: Select channel 7

(R/W)

## Register 7.33. GPIO\_EXT\_ETM\_TASK\_P7\_CFG\_REG (0x00BC)

![Image](images/07_Chapter_7_img043_937f3495.png)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_EN (n: 28 - 30) Configures whether or not to enable GPIOn to response ETM task.

0: Not enable

1: Enable

(R/W)

GPIO\_EXT\_ETM\_TASK\_GPIOn\_SEL (n: 28 - 30) Configures to select an ETM task channel for GPIOn .

0: Select channel 0

1: Select channel 1

......

7: Select channel 7

(R/W)

## Register 7.34. GPIO\_EXT\_VERSION\_REG (0x00FC)

![Image](images/07_Chapter_7_img044_aca570e4.png)

GPIO\_EXT\_DATE Version control register.

(R/W)

## 7.16.4 LP IO MUX Registers

The addresses in this section are relative to LP\_IO base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 7.35. LP\_IO\_OUT\_REG (0x0000)

![Image](images/07_Chapter_7_img045_03a07cc3.png)

## LP\_GPIO\_OUT\_DATA Configures the output of GPIO0 ~ GPIO7.

0: Low level

1: High level

```
bit0 ~ bit7 are corresponding to GPIO0
```

(R/W)

~ GPIO7.

## Register 7.36. LP\_IO\_OUT\_W1TS\_REG (0x0004)

![Image](images/07_Chapter_7_img046_34bf5642.png)

LP\_GPIO\_OUT\_DATA\_W1TS Configures whether or not to enable the output register LP\_IO\_OUT\_REG of GPIO0 ~ GPIO7.

- bit0 ~ bit7 are corresponding to GPIO0 ~ GPIO7.
- If the value 1 is written to a bit here, the corresponding bit in LP\_IO\_OUT\_REG will be set to 1.
- Recommended operation: use this register to set LP\_IO\_OUT\_REG .

(WT)

## Register 7.37. LP\_IO\_OUT\_W1TC\_REG (0x0008)

![Image](images/07_Chapter_7_img047_bb0c8d5b.png)

- LP\_GPIO\_OUT\_DATA\_W1TC Configures whether or not to clear the output register LP\_IO\_OUT\_REG of GPIO0 ~ GPIO7.
- bit0 ~ bit7 are corresponding to GPIO0 ~ GPIO7.
- If the value 1 is written to a bit here, the corresponding bit in LP\_IO\_OUT\_REG will be cleared.
- Recommended operation: use this register to clear LP\_IO\_OUT\_REG .

(WT)

## Register 7.38. LP\_IO\_ENABLE\_REG (0x000C)

![Image](images/07_Chapter_7_img048_ad6f5d95.png)

- LP\_GPIO\_ENABLE Configures whether or not to enable the output of GPIO0 ~ GPIO7.
- 0: Not enable
- 1: Enable

bit0 ~ bit7 are corresponding to GPIO0 ~ GPIO7.

(R/W)

## Register 7.39. LP\_IO\_ENABLE\_W1TS\_REG (0x0010)

![Image](images/07_Chapter_7_img049_6fd46136.png)

LP\_GPIO\_ENABLE\_W1TS Configures whether or not to set the output enable register LP\_IO\_ENABLE\_REG of GPIO0 ~ GPIO7.

- bit0 ~ bit7 are corresponding to GPIO0 ~ GPIO7.
- If the value 1 is written to a bit here, the corresponding bit in LP\_IO\_ENABLE\_REG will be set to 1.
- Recommended operation: use this register to set LP\_IO\_ENABLE\_REG .

(WT)

## Register 7.40. LP\_IO\_ENABLE\_W1TC\_REG (0x0014)

![Image](images/07_Chapter_7_img050_bdf333c6.png)

LP\_GPIO\_ENABLE\_W1TC Configures whether or not to clear the output enable register LP\_IO\_ENABLE\_REG of GPIO0 ~ GPIO7.

- bit0 ~ bit7 are corresponding to GPIO0 ~ GPIO7.
- If the value 1 is written to a bit here, the corresponding bit in LP\_IO\_ENABLE\_REG will be cleared.
- Recommended operation: use this register to clear LP\_IO\_ENABLE\_REG .

(WT)

## Register 7.41. LP\_IO\_STATUS\_REG (0x0018)

![Image](images/07_Chapter_7_img051_38a5997a.png)

LP\_GPIO\_STATUS\_INT Configures the interrupt status of GPIO0 ~ GPIO7.

0: No interrupt

1: Interrupt is triggered

Bit0 is corresponding to GPIO0, bit1 is corresponding to GPIO1, and etc. This register is used together LP\_IO\_PINn\_INT\_TYPE in register LP\_IO\_PINn\_REG . (R/W)

Register 7.42. LP\_IO\_STATUS\_W1TS\_REG (0x001C)

![Image](images/07_Chapter_7_img052_104ece4b.png)

LP\_GPIO\_STATUS\_INT\_W1TS Configures whether or not to set the interrupt status register LP\_IO\_STATUS\_INT of GPIO0 ~ GPIO7.

- Bit0 is corresponding to GPIO0, bit1 is corresponding to GPIO1, and etc.
- If the value 1 is written to a bit here, the corresponding bit in LP\_IO\_STATUS\_INT will be set to 1.
- Recommended operation: use this register to set LP\_IO\_STATUS\_INT .

(WT)

## Register 7.43. LP\_IO\_STATUS\_W1TC\_REG (0x0020)

![Image](images/07_Chapter_7_img053_6a72f466.png)

LP\_GPIO\_STATUS\_INT\_W1TC Configures whether or not to clear the interrupt status register LP\_IO\_STATUS\_INT of GPIO0 ~ GPIO7.

- Bit0 is corresponding to GPIO0, bit1 is corresponding to GPIO1, and etc.
- If the value 1 is written to a bit here, the corresponding bit in LP\_IO\_STATUS\_INT will be cleared
- ecommended operation: use this register to clear LP\_IO\_STATUS\_INT .

(WT)

## Register 7.44. LP\_IO\_IN\_REG (0x0024)

![Image](images/07_Chapter_7_img054_cb9859e2.png)

LP\_GPIO\_IN\_NEXT Represents the input value of GPIO0 ~ GPIO7.

- 0: Low level input
- 1: High level input

bit0 ~ bit7 are corresponding to GPIO0

(RO)

~

GPIO7.

## Register 7.45. LP\_IO\_PINn\_REG (n: 0-7) (0x0028+0x4*n)

![Image](images/07_Chapter_7_img055_d2dbbd19.png)

- LP\_GPIO\_PINn\_PAD\_DRIVER Configures to select the pin dirve mode of GPIOn .
- 0: Normal output
- 1: Open drain output
- (R/W)
- LP\_GPIO\_PINn\_EDGE\_WAKEUP\_CLR Configures whether or not to clear the edge wake-up status of GPIO0 ~ GPIO7.
- bit0 ~ bit7 are corresponding to GPIO0 ~ GPIO7.
- If the value 1 is written to a bit here, the edge wake-up status of corresponding GPIO will be cleared.

(WT)

- LP\_GPIO\_PINn\_INT\_TYPE Configures GPIOn interrupt type.
- 0: GPIO interrupt disabled
- 1: Rising edge trigger
- 2: Falling edge trigger
- 3: Any edge trigger
- 4: Low level trigger
- 5: High level trigger
- (R/W)
- LP\_GPIO\_PINn\_WAKEUP\_ENABLE Configures whether or not to enable GPIOn wake-up function.
- 0: Not enable
- 1: Enable

This function is disabled when PD\_LP\_PERI is powered off.

(R/W)

## Register 7.46. LP\_IO\_GPIOn\_REG (n: 0-7) (0x0048+0x4*n)

![Image](images/07_Chapter_7_img056_c3940ab0.png)

- LP\_GPIO\_GPIOn\_FUN\_SEL Configures to select the LP IO MUX function for GPIOn in normal exe-

cution mode.

0: Select Function 0

1: Select Function 1

......

(R/W)

- LP\_GPIO\_GPIOn\_FUN\_DRV Configures the drive strength of GPIOn in normal execution mode.

0: ~5 mA

1: ~10 mA

2: ~20 mA

3: ~40 mA

(R/W)

- LP\_GPIO\_GPIOn\_FUN\_IE Configures whether or not to enable the input of GPIOn in normal execu-

tion mode.

0: Not enable

1: Enable

(R/W)

- LP\_GPIO\_GPIOn\_FUN\_RUE Configures whether or not to enable the pull-up resistor of GPIOn in normal execution mode.

0: Not enable

1: Enable

(R/W)

- LP\_GPIO\_GPIOn\_FUN\_RDE Configures whether or not to enable the pull-down resistor of GPIOn in normal execution mode.

0: Not enable

1: Enable

(R/W)

- LP\_GPIO\_GPIOn\_MCU\_DRV Configures the drive strength of GPIOn during sleep mode.

0: ~5 mA

1: ~10 mA

2: ~20 mA

3: ~40 mA

(R/W)

Continued on the next page...

Register 7.46. LP\_IO\_GPIOn\_REG (n: 0-7) (0x0048+0x4*n)

## Continued from the previous page...

LP\_GPIO\_GPIOn\_MCU\_IE Configures whether or not to enable the input of GPIOn during sleep mode.

0: Not enable

1: Enable

(R/W)

- LP\_GPIO\_GPIOn\_MCU\_RUE Configures whether or not to enable the pull-up resistor of GPIOn during sleep mode.

0: Not enable

1: Enable

(R/W)

- LP\_GPIO\_GPIOn\_MCU\_RDE Configures whether or not to enable the pull-down resistor of GPIOn during sleep mode.

0: Not enable

1: Enable

(R/W)

- LP\_GPIO\_GPIOn\_SLP\_SEL Configures whether or not to enable the sleep mode for GPIOn .
- 0: Not enable

1: Enable

(R/W)

- LP\_GPIO\_GPIOn\_MCU\_OE Configures whether or not to enable the output of GPIOn during sleep mode.

0: Not enable

1: Enable

(R/W)

## Register 7.47. LP\_IO\_STATUS\_INT\_REG (0x0068)

![Image](images/07_Chapter_7_img057_17eeab1d.png)

LP\_GPIO\_STATUS\_INT\_NEXT Represents the interrupt source status of GPIO0 ~ GPIO7.

bit0 ~ bit7 are corresponding to GPIO0 ~ 7. Each bit represents:

0: Interrupt source status is invalid.

1: Interrupt source status is valid.

The interrupt here can be rising-edge triggered, falling-edge triggered, any edge triggered, or level triggered.

(RO)

## Register 7.48. LP\_IO\_DATE\_REG (0x03FC)

![Image](images/07_Chapter_7_img058_2bce2a25.png)

LP\_IO\_DATE Version control register.

(R/W)
