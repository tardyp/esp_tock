---
chapter: 5
title: "Chapter 5"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 5

## IO MUX and GPIO Matrix (GPIO, IO MUX)

## 5.1 Overview

The ESP32-C3 chip features 22 physical GPIO pins. Each pin can be used as a general-purpose I/O, or be connected to an internal peripheral signal. Through GPIO matrix and IO MUX, peripheral input signals can be from any IO pins, and peripheral output signals can be routed to any IO pins. Together these modules provide highly configurable I/O.

Note that the GPIO pins are numbered from 0 ~ 21.

## 5.2 Features

## GPIO Matrix Features

- A full-switching matrix between the peripheral input/output signals and the pins.
- 42 peripheral input signals can be sourced from the input of any GPIO pins.
- The output of any GPIO pins can be from any of the 78 peripheral output signals.
- Supports signal synchronization for peripheral inputs based on APB clock bus.
- Provides input signal filter.
- Supports sigma delta modulated output.
- Supports GPIO simple input and output.

## IO MUX Features

- Provides one configuration register IO\_MUX\_GPIOn\_REG for each GPIO pin. The pin can be configured to
- – perform GPIO function routed by GPIO matrix;
- – or perform direct connection bypassing GPIO matrix.
- Supports some high-speed digital signals (SPI, JTAG, UART) bypassing GPIO matrix for better high-frequency digital performance. In this case, IO MUX is used to connect these pins directly to peripherals.

## 5.3 Architectural Overview

This section provides an overview to the architecture of IO MUX and GPIO matrix with the following figures:

- Figure 5.3-1 shows the general work flow of IO MUX and GPIO matrix.

- Figure 5.3-2 shows in details how IO MUX and GPIO matrix route signals from pins to peripherals, and from peripherals to pins.
- Figure 5.3-3 shows the interface logic for a GPIO pin.
- ⃝1 Only part of peripheral input signals (marked "yes" in column "Direct input through IO MUX" in Table 5.11-1) can bypass GPIO matrix. The other input signals can only be routed to peripherals via GPIO matrix.
- ⃝2 There are only 22 inputs from GPIO SYNC to GPIO matrix, since ESP32-C3 provides 22 GPIO pins in

Figure 5.3-1. Diagram of IO MUX and GPIO Matrix

![Image](images/05_Chapter_5_img001_3116b1d0.png)

Figure 5.3-2. Architecture of IO MUX and GPIO Matrix

![Image](images/05_Chapter_5_img002_46e2c676.png)

![Image](images/05_Chapter_5_img003_7eb1d02e.png)

total.

- ⃝3 The pins supplied by VDD3P3\_CPU or by VDD3P3\_RTC are controlled by the signals: IE, OE, WPU, and WPD.
- ⃝4 Only part of peripheral outputs (marked "yes" in column "Direct output through IO MUX" in Table 5.11-1) can be routed to pins bypassing GPIO matrix. See Table 5.11-1 .
- ⃝5 There are only 22 outputs (GPIO pin X: 0 ~ 21) from GPIO matrix to IO MUX.

Figure 5.3-3 shows the internal structure of a pad, which is an electrical interface between the chip logic and the GPIO pin. The structure is applicable to all 22 GPIO pins and can be controlled using IE, OE, WPU, and WPD signals.

Figure 5.3-3. Internal Structure of a Pad

![Image](images/05_Chapter_5_img004_ef006899.png)

## Note:

- IE: input enable
- OE: output enable
- WPU: internal weak pull-up
- WPD: internal weak pull-down
- Bonding pad: a terminal point of the chip logic used to make a physical connection from the chip die to GPIO pin in the chip package.

## 5.4 Peripheral Input via GPIO Matrix

## 5.4.1 Overview

To receive a peripheral input signal via GPIO matrix, the matrix is configured to source the peripheral input signal from one of the 22 GPIOs (0 ~ 21), see Table 5.11-1. Meanwhile, register corresponding to the peripheral signal should be set to receive input signal via GPIO matrix.

## 5.4.2 Signal Synchronization

When signals are directed from pins using GPIO matrix, the signals will be synchronized to the APB bus clock by GPIO SYNC hardware, then go to GPIO matrix. This synchronization applies to all GPIO matrix signals but does not apply when using the IO MUX, see Figure 5.3-2 .

Figure 5.4-1. GPIO Input Synchronized on APB Clock Rising Edge or on Falling Edge

![Image](images/05_Chapter_5_img005_ee5eb1b4.png)

Figure 5.4-1 shows the functionality of GPIO SYNC. In the figure, negative sync and positive sync mean GPIO input is synchronized on APB clock falling edge and on APB clock rising edge, respectively.

## 5.4.3 Functional Description

To read GPIO pin X 1 into peripheral signal Y, follow the steps below:

1. Configure register GPIO\_FUNCy\_IN\_SEL\_CFG\_REG corresponding to peripheral signal Y in GPIO matrix:
- Set GPIO\_SIGy\_IN\_SEL to enable peripheral signal input via GPIO matrix.
- Set GPIO\_FUNCy\_IN\_SEL to the desired GPIO pin, i.e. X here.

Note that some peripheral signals have no valid GPIO\_SIGy\_IN\_SEL bit, namely, these peripherals can only receive input signals via GPIO matrix.

2. Optionally enable the filter for pin input signals by setting the register IO\_MUX\_GPIOn\_FILTER\_EN. Only the signals with a valid width of more than two clock cycles can be sampled, see Figure 5.4-2 .
3. Synchronize GPIO input. To do so, please set GPIO\_PINx\_REG corresponding to GPIO pin X as follows:

Figure 5.4-2. Filter Timing of GPIO Input Signals

![Image](images/05_Chapter_5_img006_ab7340c6.png)

- Set GPIO\_PINx\_SYNC1\_BYPASS to enable input signal synchronized on rising edge or on falling edge in the first clock, see Figure 5.4-1 .
- Set GPIO\_PINx\_SYNC2\_BYPASS to enable input signal synchronized on rising edge or on falling edge in the second clock, see Figure 5.4-1 .
4. Configure IO MUX register to enable pin input. For this end, please set IO\_MUX\_GPIOx\_REG corresponding to GPIO pin X as follows:
- Set IO\_MUX\_GPIOx\_FUN\_IE to enable input 2 .
- Set or clear IO\_MUX\_GPIOx\_FUN\_WPU and IO\_MUX\_GPIOx\_FUN\_WPD, as desired, to enable or disable pull-up and pull-down resistors.

For example, to connect I2S MCLK input signal 3 (I2S\_MCLK\_in, signal index 12) to GPIO7, please follow the steps below. Note that GPIO7 is also named as MTDO pin.

1. Set GPIO\_SIG12\_IN\_SEL in register GPIO\_FUNC12\_IN\_SEL\_CFG\_REG to enable peripheral signal input via GPIO matrix.
2. Set GPIO\_FUNC12\_IN\_SEL in register GPIO\_FUNC12\_IN\_SEL\_CFG\_REG to 7.
3. Set IO\_MUX\_GPIO7\_FUN\_IE in register IO\_MUX\_GPIO7\_REG to enable pin input.

## Note:

1. One input pin can be connected to multiple peripheral input signals.
2. The input signal can be inverted by configuring GPIO\_FUNCy\_IN\_INV\_SEL .
3. It is possible to have a peripheral read a constantly low or constantly high input value without connecting this input to a pin. This can be done by selecting a special GPIO\_FUNCy\_IN\_SEL input, instead of a GPIO number:
- When GPIO\_FUNCy\_IN\_SEL is set to 0x1F, input signal is always 0.
- When GPIO\_FUNCy\_IN\_SEL is set to 0x1E, input signal is always 1.

## 5.4.4 Simple GPIO Input

GPIO\_IN\_REG holds the input values of each GPIO pin. The input value of any GPIO pin can be read at any time without configuring GPIO matrix for a particular peripheral signal. However, it is necessary to enable the input via IO MUX by setting IO\_MUX\_GPIOx\_FUN\_IE bit in register IO\_MUX\_GPIOx\_REG corresponding to pin X, as mentioned in Section 5.4.2 .

## 5.5 Peripheral Output via GPIO Matrix

## 5.5.1 Overview

To output a signal from a peripheral via GPIO matrix, the matrix is configured to route peripheral output signals (only signals with a name assigned in the column "Output signal" in Table 5.11-1) to one of the 22 GPIOs (0 ~ 21). See Table 5.11-1 .

The output signal is routed from the peripheral into GPIO matrix and then into IO MUX. IO MUX must be configured to set the chosen pin to GPIO function. This enables the output GPIO signal to be connected to

the pin.

## Note:

There is a range of peripheral output signals (97 ~ 100) which are not connected to any peripheral, but to the input signals (97 ~ 100 in Table 5.11-1) directly. These can be used to input a signal from one GPIO pin and output directly to another GPIO pin.

## 5.5.2 Functional Description

Some of the 78 output signals (signals with a name assigned in the column "Output signal" in Table 5.11-1) can be set to go through GPIO matrix into IO MUX and then to a pin. Figure 5.3-2 illustrates the configuration.

To output peripheral signal Y to a particular GPIO pin X 1 , follow these steps:

1. Configure register GPIO\_FUNCx\_OUT\_SEL\_CFG\_REG and GPIO\_ENABLE\_REG[x] corresponding to GPIO pin X in GPIO matrix. Recommended operation: use corresponding W1TS (write 1 to set) and W1TC (write 1 to clear) registers to set or clear GPIO\_ENABLE\_REG .
- Set the GPIO\_FUNCx\_OUT\_SEL field in register GPIO\_FUNCx\_OUT\_SEL\_CFG\_REG to the index of the desired peripheral output signal Y .
- If the signal should always be enabled as an output, set the GPIO\_FUNCx\_OEN\_SEL bit in register GPIO\_FUNCx\_OUT\_SEL\_CFG\_REG and the bit in register GPIO\_ENABLE\_W1TS\_REG, corresponding to GPIO pin X. To have the output enable signal decided by internal logic (for example, the SPIQ\_oe in column "Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0" in Table 5.11-1), clear GPIO\_FUNCx \_OEN\_SEL bit instead.
- Set the corresponding bit in register GPIO\_ENABLE\_W1TC\_REG to disable the output from the GPIO pin.
2. For an open drain output, set the GPIO\_PINx\_PAD\_DRIVER bit in register GPIO\_PINx\_REG corresponding to GPIO pin X .
3. Configure IO MUX register to enable output via GPIO matrix. Set the IO\_MUX\_GPIOx\_REG corresponding to GPIO pin X as follows:
- Set the field IO\_MUX\_GPIOx\_MCU\_SEL to desired IO MUX function corresponding to GPIO pinX . This is Function 1 (GPIO function), numeric value 1, for all pins.
- Set the IO\_MUX\_GPIOx\_FUN\_DRV field to the desired value for output strength (0 ~ 3).
- If using open drain mode, set/clear the IO\_MUX\_GPIOx\_FUN\_WPU and IO\_MUX\_GPIOx\_FUN\_WPD bits to enable/disable the internal pull-up/pull-down resistors.

## Note:

1. The output signal from a single peripheral can be sent to multiple pins simultaneously.
2. The output signal can be inverted by setting GPIO\_FUNCx\_OUT\_INV\_SEL bit.

## 5.5.3 Simple GPIO Output

GPIO matrix can also be used for simple GPIO output. This can be done as below:

- Set GPIO matrix GPIO\_FUNCn\_OUT\_SEL with a special peripheral index 128 (0x80);
- Set the corresponding bit in GPIO\_OUT\_REG register to the desired GPIO output value.

## Note:

- GPIO\_OUT\_REG[0] ~ GPIO\_OUT\_REG[21] correspond to GPIO0 ~ GPIO21, and GPIO\_OUT\_REG[25:22] are invalid.
- Recommended operation: use corresponding W1TS and W1TC registers, such as GPIO\_OUT\_W1TS/GPIO\_OUT \_W1TC to set or clear the registers GPIO\_OUT\_REG .

## 5.5.4 Sigma Delta Modulated Output (SDM)

## 5.5.4.1 Functional Description

Four out of the 125 peripheral outputs (output index: 55 ~ 58 in Table 5.11-1) support 1-bit second-order sigma delta modulation. By default output is enabled for these four channels. This modulator can also output PDM (pulse density modulation) signal with configurable duty cycle. The transfer function of this second-order SDM modulator is:

<!-- formula-not-decoded -->

E(z) is quantization error and X(z) is the input.

Sigma Delta modulator supports scaling down of APB\_CLK by divider 1 ~ 256:

- Set GPIOSD\_FUNCTION\_CLK\_EN to enable the modulator clock.
- Configure register GPIOSD\_SDn\_PRESCALE (n is 0 ~ 3 for four channels).

After scaling, the clock cycle is equal to one pulse output cycle from the modulator.

GPIOSD\_SDn\_IN is a signed number with a range of [-128, 127] and is used to control the duty cycle 1 of PDM output signal.

- GPIOSD\_SDn\_IN = -128, the duty cycle of the output signal is 0%.
- GPIOSD\_SDn\_IN = 0, the duty cycle of the output signal is near 50%.
- GPIOSD\_SDn\_IN = 127, the duty cycle of the output signal is close to 100%.

The formula for calculating PDM signal duty cycle is shown as below:

<!-- formula-not-decoded -->

## Note:

For PDM signals, duty cycle refers to the percentage of high level cycles to the whole statistical period (several pulse cycles, for example 256 pulse cycles).

## 5.5.4.2 SDM Configuration

The configuration of SDM is shown below:

- Route one of SDM outputs to a pin via GPIO matrix, see Section 5.5.2 .
- Enable the modulator clock by setting the register GPIOSD\_FUNCTION\_CLK\_EN .
- Configure the divider value by setting the register GPIOSD\_SDn\_PRESCALE .
- Configure the duty cycle of SDM output signal by setting the register GPIOSD\_SDn\_IN .

## 5.6 Direct Input and Output via IO MUX

## 5.6.1 Overview

Some high-speed signals (SPI and JTAG) can bypass GPIO matrix for better high-frequency digital performance. In this case, IO MUX is used to connect these pins directly to peripherals.

This option is less flexible than routing signals via GPIO matrix, as the IO MUX register for each GPIO pin can only select from a limited number of functions, but high-frequency digital performance can be improved.

## 5.6.2 Functional Description

Two registers must be configured in order to bypass GPIO matrix for peripheral input signals:

1. IO\_MUX\_GPIOn\_MCU\_SEL for the GPIO pin must be set to the required pin function. For the list of pin functions, please refer to Section 5.12 .
2. Clear GPIO\_SIGn\_IN\_SEL to route the input directly to the peripheral.

To bypass GPIO matrix for peripheral output signals, IO\_MUX\_GPIOn\_MCU\_SEL for the GPIO pin must be set to the required pin function. For the list of pin functions, please refer to Section 5.12 .

## Note:

Not all signals can be directly connected to peripheral via IO MUX. Some input/output signals can only be connected to peripheral via GPIO matrix.

## 5.7 Analog Functions of GPIO Pins

Some GPIO pins in ESP32-C3 provide analog functions. When the pin is used for analog purpose, make sure that pull-up and pull-down resistors are disabled by following configuration:

- Set IO\_MUX\_GPIOn\_MCU\_SEL to 1, and clear IO\_MUX\_GPIOn\_FUN\_IE , IO\_MUX\_GPIOn\_FUN\_WPU , IO\_ MUX\_GPIOn\_FUN\_WPD .
- Write 1 to GPIO\_ENABLE\_W1TC[n], to clear output enable.

See Table 5.13-1 for analog functions of ESP32-C3 pins.

## 5.8 Pin Functions in Light-sleep

Pins may provide different functions when ESP32-C3 is in Light-sleep mode. If IO\_MUX\_SLP\_SEL in register IO\_MUX\_n\_REG for a GPIO pin is set to 1, a different set of bits will be used to control the pin when the chip is in Light-sleep mode.

Table 5.8-1. Bits Used to Control IO MUX Functions in Light-sleep Mode

| IO MUX Functions      | Normal Execution  OR IO_MUX_SLP_SEL = 0   | Light-sleep Mode AND IO_MUX_SLP_SEL = 1   |
|-----------------------|-------------------------------------------|-------------------------------------------|
| Output Drive Strength | IO_MUX_FUN_DRV                            | IO_MUX_MCU_DRV                            |
| Pull-up Resistor      | IO_MUX_FUN_WPU                            | IO_MUX_MCU_WPU                            |
| Pull-down Resistor    | IO_MUX_FUN_WPD                            | IO_MUX_MCU_WPD                            |
| Output Enable         | OEN_SEL from GPIO matrix  ∗               | IO_MUX_MCU_OE                             |

## Note:

If IO\_MUX\_SLP\_SEL is set to 0, pin functions remain the same in both normal execution and Light-sleep mode. Please refer to Section 5.5.2 for how to enable output in normal execution.

## 5.9 Pin Hold Feature

Each GPIO pin (including the RTC pins: GPIO0 ~ GPIO5) has an individual hold function controlled by a RTC register. When the pin is set to hold, the state is latched at that moment and will not change no matter how the internal signals change or how the IO MUX/GPIO configuration is modified. Users can use the hold function for the pins to retain the pin state through a core reset triggered by watchdog time-out or Deep-sleep events.

## Note:

- For digital pins (GPIO6 ~21), to maintain pin input/output status in Deep-sleep mode, users can set RTC\_CNTL\_DIG \_PAD\_HOLDn in register RTC\_CNTL\_DIG\_PAD\_HOLD\_REG to 1 before powering down. To disable the hold function after the chip is woken up, users can set RTC\_CNTL\_DIG\_PAD\_HOLDn to 0.
- For RTC pins (GPIO0 ~5), the input and output values are controlled by the corresponding bits of register RTC\_CNTL
- \_PAD\_HOLD\_REG, and users can set it to 1 to hold the value or set it to 0 to unhold the value.

## 5.10 Power Supplies and Management of GPIO Pins

## 5.10.1 Power Supplies of GPIO Pins

For more information on the power supply for GPIO pins, please refer to Pin Definition in ESP32-C3 Datasheet . All the pins can be used to wake up the chip from Light-sleep mode, but only the pins (GPIO0 ~ GPIO5) in VDD3P3\_RTC domain can be used to wake up the chip from Deep-sleep mode.

![Image](images/05_Chapter_5_img007_0ae70e46.png)

## 5.10.2 Power Supply Management

Each ESP32-C3 pin is connected to one of the two different power domains.

- VDD3P3\_RTC: the input power supply for both RTC and CPU
- VDD3P3\_CPU: the input power supply for CPU

## 5.11 Peripheral Signal List

Table 5.11-1 shows the peripheral input/output signals via GPIO matrix.

Please pay attention to the configuration of the bit GPIO\_FUNCn\_OEN\_SEL:

- GPIO\_FUNCn\_OEN\_SEL = 1: the output enable is controlled by the corresponding bit n of GPIO\_ENABLE\_REG:
- – GPIO\_ENABLE\_REG = 0: output is disabled;
- – GPIO\_ENABLE\_REG = 1: output is enabled;
- GPIO\_FUNCn\_OEN\_SEL = 0: use the output enable signal from peripheral, for example SPIQ\_oe in the column "Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0" of Table 5.11-1. Note that the signals such as SPIQ\_oe can be 1 (1'd1) or 0 (1'd0), depending on the configuration of corresponding peripherals. If it's 1'd1 in the "Output enable signal when GPIO\_FUNCn\_OEN\_SEL = 0", it indicates that once the register GPIO\_FUNCn\_OEN\_SEL is cleared, the output signal is always enabled by default.

## Note:

Signals are numbered consecutively, but not all signals are valid.

- Only the signals with a name assigned in the column "Input signal" in Table 5.11-1 are valid input signals.
- Only the signals with a name assigned in the column "Output signal" in Table 5.11-1 are valid output signals.

Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct
Output via
IO MUX

yes yes

yes

Output enable signal when

= 0

\_OEN\_SEL

n

GPIO\_FUNC

Output Signal

Direct Input via IO MUX

Default value

Input Signal

Signal No.

yes

SPIQ\_oe

SPID\_oe

SPIHD\_oe

SPIWP\_oe yes

SPICLK\_oe yes

SPICS0\_oe yes

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

no no

no no

no

GoBack no

no no

no no

no no

no

1'd1 1'd1 1'd1 1'd1 1'd1 1'd1 1'd1 1'd1 1'd1 1'd1 1'd1 1'd1 1'd1

|          | SPID_out  SPIHD_out  SPIWP_out  SPICLK_out_mux   | U1RTS_out         | I2SO_BCK_out  I2SO_WS_out   | I2SI_BCK_out  I2SI_WS_out  gpio_wlan_prio  gpio_wlan_active   |
|----------|--------------------------------------------------|-------------------|-----------------------------|---------------------------------------------------------------|
| SPIQ_out | SPICS0_out  U0TXD_out                            | U1DTR_out         |                             |                                                               |
|          |                                                  |                   |                             | -  -                                                          |
| yes      | yes  yes  yes  -  -  yes                         | no  no            | no  no                      | no  no  no  no  -  -                                          |
| 0        | 0  0  0  -  -  0                                 | 0  0              | 0  0                        | 0  0  0  0  -  -                                              |
|          | SPID_in                                          | U1CTS_in U1DSR_in | I2SO_BCK_in I2SO_WS_in      | -                                                             |
| SPIQ_in  | SPIHD_in SPIWP_in -  -  U0RXD_in                 |                   |                             | I2SI_BCK_in I2SI_WS_in gpio_bt_priority gpio_bt_active -      |
| 0        | 1  2  3  4  5  6                                 | 10  11            | 13  14                      | 16  17  18  19  20  21                                        |

Espressif Systems

169

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Table 5.11-1. Peripheral Signals via GPIO Matrix

Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct
Output via
IO MUX

Output enable signal when

= 0

\_OEN\_SEL

n

GPIO\_FUNC

Output Signal

Direct Input via IO MUX

Default value

Input Signal

Signal No.

25

|    | cpu_gpio_out4                                              |              |      | ledc_ls_sig_out2  ledc_ls_sig_out3   | rmt_sig_out0   |
|----|------------------------------------------------------------|--------------|------|--------------------------------------|----------------|
|    | cpu_gpio_out0  cpu_gpio_out1  cpu_gpio_out2  cpu_gpio_out3 | usb_jtag_tms |      | ledc_ls_sig_out0  ledc_ls_sig_out1   |                |
| -  |                                                            |              | -  - | -  -  -                              |                |
| -  | no  no  no  no  no                                         | -            | -  - | -  -  -  no  -  -  -                 | no             |
| -  | 0  0  0  0  0                                              | -            | -  - | -  -  -  0  -  -  -                  | 0              |
|    |                                                            |              |      | -                                    | rmt_sig_in0    |
|    | cpu_gpio_in0                                               |              |      |                                      |                |
| -  | cpu_gpio_in1 cpu_gpio_in2 cpu_gpio_in3 cpu_gpio_in4        | -            | -  - | -  -  -  ext_adc_start -  -          |                |
|    | 29  30  31  32                                             |              | 40   |                                      |                |
| 26 | 28                                                         | 37           | 41   | 42  43  44  45  46  47  48           | 51             |

Espressif Systems no

1’d1

170

Submit Documentation Feedback no

no no

no no

GoBack no

no no

1’d1

1’d1

1’d1

1’d1

1’d1

1’d1

1’d1

1’d1

ESP32-C3 TRM (Version 1.3)

no

1’d1

no

1’d1

no

1’d1

no cpu\_gpio\_out\_oen0

no cpu\_gpio\_out\_oen1

no cpu\_gpio\_out\_oen2

no cpu\_gpio\_out\_oen3

no cpu\_gpio\_out\_oen4

no cpu\_gpio\_out\_oen5

no cpu\_gpio\_out\_oen6

no cpu\_gpio\_out\_oen7

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

Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct
Output via
IO MUX

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

rmt\_sig\_out1

no

0

rmt\_sig\_in1

Signal No.

52

| I2CEXT0_SCL_out   |                                                                      |           |                         |                                                                 |    |
|-------------------|----------------------------------------------------------------------|-----------|-------------------------|-----------------------------------------------------------------|----|
|                   | gpio_sd0_out  gpio_sd1_out  gpio_sd2_out  gpio_sd3_out  I2SO_SD1_out |           | FSPIWP_out  FSPICS0_out | twai_bus_off_on                                                 |    |
|                   |                                                                      | FSPIQ_out |                         |                                                                 |    |
|                   |                                                                      |           |                         | FSPICS1_out  FSPICS2_out  FSPICS3_out  FSPICS4_out  FSPICS5_out |    |
|                   |                                                                      |           |                         | twai_tx                                                         | -  |
|                   | -  -  -  -                                                           |           |                         | -  -  -  -  no  -                                               | -  |
| no                | -                                                                    | yes       | yes  yes                | -                                                               |    |
| 1                 | -  -  -  -  -                                                        | 0         | 0  0                    | -  -  -  -  -  1  -                                             | -  |
|                   |                                                                      |           | FSPIWP_in               |                                                                 |    |
| I2CEXT0_SCL_in    |                                                                      | FSPIQ_in  | FSPICS0_in              | twai_rx                                                         |    |
|                   | -  -  -  -  -                                                        |           |                         | -  -  -  -  -  -                                                | -  |
|                   | 55  56  57  58  59                                                   |           | 67  68                  | 75                                                              |    |
| 53                |                                                                      | 64        |                         | 69  70  71  72  73  74                                          | 78 |

Espressif Systems yes

FSPICLK\_oe yes

FSPIQ\_oe

171

Submit Documentation Feedback no

no no

no no

GoBack no

no no

FSPICS3\_oe

FSPICS4\_oe

FSPICS5\_oe

1’d1

1’d1

1’d1

1’d1

1’d1

ESP32-C3 TRM (Version 1.3)

no

I2CEXT0\_SCL\_oe no

I2CEXT0\_SDA\_oe no

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

yes

FSPID\_oe yes

FSPIHD\_oe yes

FSPIWP\_oe yes

FSPICS0\_oe no

FSPICS1\_oe no

FSPICS2\_oe

Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct
Output via
IO MUX

Output enable signal when

= 0

\_OEN\_SEL

n

GPIO\_FUNC

Output Signal

Direct Input via IO MUX

Default value

Input Signal

Signal No.

79

|    |                |          |          | sig_in_func98  sig_in_func99  sig_in_func100                 |     |
|----|----------------|----------|----------|--------------------------------------------------------------|-----|
|    |                | ant_sel2 | ant_sel6 | sig_in_func97                                                |     |
| -  | -  -  -  -  -  |          | ant_sel5 |                                                              | -   |
| -  | -  -  -  -  -  | -        | -  -     | no  no  no  no                                               | -   |
| -  | -  -  -  -  -  | -        | -  -     | 0  0  0  0                                                   | -   |
|    |                |          |          | sig_in_func_97 sig_in_func_98 sig_in_func_99 sig_in_func_100 |     |
| -  | -  -  -  -  -  | -        | -  -     |                                                              | -   |
|    | 83             |          | 94       | 100                                                          | 105 |
| 80 | 82  84  85  86 | 91       | 95       | 97  98  99                                                   |     |

Espressif Systems no

1’d1

172

Submit Documentation Feedback no

no no

no no

GoBack no

no no

1’d1

1’d1

1’d1

1’d1

1’d1

1’d1

1’d1

1’d1

ESP32-C3 TRM (Version 1.3)

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

Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX)

Direct
Output via
IO MUX

Output enable signal when

= 0

\_OEN\_SEL

n

GPIO\_FUNC

Output Signal

Direct Input via IO MUX

Default value

Input Signal

Signal No.

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

|    |    |    | CLK_OUT_out2  CLK_OUT_out3  SPICS1_out   |
|----|----|----|------------------------------------------|
| -  | -  | -  |                                          |
| -  | -  | -  | -  -  -                                  |
| -  | -  | -  | -  -  -                                  |
| -  | -  | -  | -  -  -                                  |

106

107

Espressif Systems

108

109

110

111

112

113

114

115

116

117

118

119

120

121

122

173

Submit Documentation Feedback

123

124

125

126

127

ESP32-C3 TRM (Version 1.3)

GoBack

## 5.12 IO MUX Functions List

Table 5.12-1 shows the IO MUX functions of each pin.

Table 5.12-1. IO MUX Pin Functions

|   Pin No. | Pin Name   | Function 0   | Function 1   | Function 2   | Function 3   |   DRV | Reset   | Notes   |
|-----------|------------|--------------|--------------|--------------|--------------|-------|---------|---------|
|         4 | XTAL_32K_P | GPIO0        | GPIO0        | -            | -            |     2 | 0       | R       |
|         5 | XTAL_32K_N | GPIO1        | GPIO1        | -            | -            |     2 | 0       | R       |
|         6 | GPIO2      | GPIO2        | GPIO2        | FSPIQ        | -            |     2 | 1       | R       |
|         8 | GPIO3      | GPIO3        | GPIO3        | -            | -            |     2 | 1       | R       |
|         9 | MTMS       | MTMS         | GPIO4        | FSPIHD       | -            |     2 | 1       | R       |
|        10 | MTDI       | MTDI         | GPIO5        | FSPIWP       | -            |     2 | 1       | R       |
|        12 | MTCK       | MTCK         | GPIO6        | FSPICLK      | -            |     2 | 1*      | G       |
|        13 | MTDO       | MTDO         | GPIO7        | FSPID        | -            |     2 | 1       | G       |
|        14 | GPIO8      | GPIO8        | GPIO8        | -            | -            |     2 | 1       | -       |
|        15 | GPIO9      | GPIO9        | GPIO9        | -            | -            |     2 | 3       | -       |
|        16 | GPIO10     | GPIO10       | GPIO10       | FSPICS0      | -            |     2 | 1       | G       |
|        18 | VDD_SPI    | GPIO11       | GPIO11       | -            | -            |     2 | 0       | -       |
|        19 | SPIHD      | SPIHD        | GPIO12       | -            | -            |     2 | 3       | -       |
|        20 | SPIWP      | SPIWP        | GPIO13       | -            | -            |     2 | 3       | -       |
|        21 | SPICS0     | SPICS0       | GPIO14       | -            | -            |     2 | 3       | -       |
|        22 | SPICLK     | SPICLK       | GPIO15       | -            | -            |     2 | 3       | -       |
|        23 | SPID       | SPID         | GPIO16       | -            | -            |     2 | 3       | -       |
|        24 | SPIQ       | SPIQ         | GPIO17       | -            | -            |     2 | 3       | -       |
|        25 | GPIO18     | GPIO18       | GPIO18       | -            | -            |     3 | 0       | USB, G  |
|        26 | GPIO19     | GPIO19       | GPIO19       | -            | -            |     3 | 0*      | USB     |
|        27 | U0RXD      | U0RXD        | GPIO20       | -            | -            |     2 | 3       | G       |
|        28 | U0TXD      | U0TXD        | GPIO21       | -            | -            |     2 | 4       | -       |

## Drive Strength

“DRV” column shows the drive strength of each pin after reset:

- GPIO2, GPIO3, GPIO4, GPIO5, GPIO18, GPIO19
- – 0 - Drive current = ~5 mA
- – 1 - Drive current = ~20 mA
- – 2 - Drive current = ~10 mA
- – 3 - Drive current = ~40 mA
- Other GPIOs
- – 0 - Drive current = ~5 mA
- – 1 - Drive current = ~10 mA

- – 2 - Drive current = ~20 mA
- – 3 - Drive current = ~40 mA

## Reset Configurations

“Reset” column shows the default configuration of each pin after reset:

- 0 - IE = 0 (input disabled)
- 1 - IE = 1 (input enabled)
- 2 - IE = 1, WPD = 1 (input enabled, pull-down resistor enabled)
- 3 - IE = 1, WPU = 1 (input enabled, pull-up resistor enabled)
- 4 - OE = 1, WPU = 1 (output enabled, pull-up resistor enabled)
- 0* - IE = 0, WPU = 0. The USB pull-up value of GPIO19 is 1 by default, therefore, the pin's pull-up resistor is enabled. For more information, see the note below.
- 1* - If eFuse bit EFUSE\_DIS\_PAD\_JTAG = 1, the pin MTCK is left floating after reset, i.e. IE = 1. If eFuse bit EFUSE\_DIS\_PAD\_JTAG = 0, the pin MTCK is connected to internal pull-up resistor, i.e. IE = 1, WPU = 1.

## Note:

- R - Pins in VDD3P3\_RTC domain, and part of them have analog functions, see Table 5.13-1 .
- USB - GPIO18 and GPIO19 are USB pins. The pull-up value of the two pins are controlled by the pins' pull-up value together with USB pull-up value. If any one of the pull-up value is 1, the pin's pull-up resistor will be enabled. The pull-up resistors of USB pins are controlled by USB\_SERIAL\_JTAG\_DP\_PULLUP.
- G - These pins have glitches during power-up. See details in Table 5.12-2 .

Table 5.12-2. Power-Up Glitches on Pins

| Pin    | Glitch            |   Typical Time Period (ns) |
|--------|-------------------|----------------------------|
| MTCK   | Low-level glitch  |                          5 |
| MTDO   | Low-level glitch  |                          5 |
| GPIO10 | Low-level glitch  |                          5 |
| U0RXD  | Low-level glitch  |                          5 |
| GPIO18 | High-level glitch |                      50000 |

## 5.13 Analog Functions List

Table 5.13-1 shows the IO MUX pins with analog functions.

Table 5.13-1. Analog Functions of IO MUX Pins

|   GPIO Num | Pin Name   | Analog Function 0   | Analog Function 1   |
|------------|------------|---------------------|---------------------|
|          0 | XTAL_32K_P | XTAL_32K_P          | ADC1_CH0            |
|          1 | XTAL_32K_N | XTAL_32K_N          | ADC1_CH1            |
|          2 | GPIO2      | -                   | ADC1_CH2            |

|   GPIO Num | Pin Name   | Analog Function 0   | Analog Function 1   |
|------------|------------|---------------------|---------------------|
|          3 | GPIO3      | -                   | ADC1_CH3            |
|          4 | MTMS       | -                   | ADC1_CH4            |

## 5.14 Register Summary

## 5.14.1 GPIO Matrix Register Summary

The addresses in this section are relative to the GPIO base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                        | Description                            | Address   | Access   |
|-----------------------------|----------------------------------------|-----------|----------|
| Configuration Registers     |                                        |           |          |
| GPIO_BT_SELECT_REG          | GPIO bit select register               | 0x0000    | R/W      |
| GPIO_OUT_REG                | GPIO output register                   | 0x0004    | R/W/SS   |
| GPIO_OUT_W1TS_REG           | GPIO output set register               | 0x0008    | WT       |
| GPIO_OUT_W1TC_REG           | GPIO output clear register             | 0x000C    | WT       |
| GPIO_ENABLE_REG             | GPIO output enable register            | 0x0020    | R/W/SS   |
| GPIO_ENABLE_W1TS_REG        | GPIO output enable set register        | 0x0024    | WT       |
| GPIO_ENABLE_W1TC_REG        | GPIO output enable clear register      | 0x0028    | WT       |
| GPIO_STRAP_REG              | pin strapping register                 | 0x0038    | RO       |
| GPIO_IN_REG                 | GPIO input register                    | 0x003C    | RO       |
| GPIO_STATUS_REG             | GPIO interrupt status register         | 0x0044    | R/W/SS   |
| GPIO_STATUS_W1TS_REG        | GPIO interrupt status set register     | 0x0048    | WT       |
| GPIO_STATUS_W1TC_REG        | GPIO interrupt status clear register   | 0x004C    | WT       |
| GPIO_PCPU_INT_REG           | GPIO PRO_CPU interrupt status register | 0x005C    | RO       |
| GPIO_STATUS_NEXT_REG        | GPIO interrupt source register         | 0x014C    | RO       |
| Pin Configuration Registers |                                        |           |          |
| GPIO_PIN0_REG               | GPIO pin0 configuration register       | 0x0074    | R/W      |
| GPIO_PIN1_REG               | GPIO pin1 configuration register       | 0x0078    | R/W      |
| GPIO_PIN2_REG               | GPIO pin2 configuration register       | 0x007C    | R/W      |
| GPIO_PIN3_REG               | GPIO pin3 configuration register       | 0x0080    | R/W      |
| GPIO_PIN4_REG               | GPIO pin4 configuration register       | 0x0084    | R/W      |
| GPIO_PIN5_REG               | GPIO pin5 configuration register       | 0x0088    | R/W      |
| GPIO_PIN6_REG               | GPIO pin6 configuration register       | 0x008C    | R/W      |
| GPIO_PIN7_REG               | GPIO pin7 configuration register       | 0x0090    | R/W      |
| GPIO_PIN8_REG               | GPIO pin8 configuration register       | 0x0094    | R/W      |
| GPIO_PIN9_REG               | GPIO pin9 configuration register       | 0x0098    | R/W      |
| GPIO_PIN10_REG              | GPIO pin10 configuration register      | 0x009C    | R/W      |
| GPIO_PIN11_REG              | GPIO pin11 configuration register      | 0x00A0    | R/W      |
| GPIO_PIN12_REG              | GPIO pin12 configuration register      | 0x00A4    | R/W      |
| GPIO_PIN13_REG              | GPIO pin13 configuration register      | 0x00A8    | R/W      |
| GPIO_PIN14_REG              | GPIO pin14 configuration register      | 0x00AC    | R/W      |

| Name                                    | Description                                 | Address                                 | Access                                  |
|-----------------------------------------|---------------------------------------------|-----------------------------------------|-----------------------------------------|
| GPIO_PIN15_REG                          | GPIO pin15 configuration register           | 0x00B0                                  | R/W                                     |
| GPIO_PIN16_REG                          | GPIO pin16 configuration register           | 0x00B4                                  | R/W                                     |
| GPIO_PIN17_REG                          | GPIO pin17 configuration register           | 0x00B8                                  | R/W                                     |
| GPIO_PIN18_REG                          | GPIO pin18 configuration register           | 0x00BC                                  | R/W                                     |
| GPIO_PIN19_REG                          | GPIO pin19 configuration register           | 0x00C0                                  | R/W                                     |
| GPIO_PIN20_REG                          | GPIO pin20 configuration register           | 0x00C4                                  | R/W                                     |
| GPIO_PIN21_REG                          | GPIO pin21 configuration register           | 0x00C8                                  | R/W                                     |
| Input Function Configuration Registers  | Input Function Configuration Registers      | Input Function Configuration Registers  | Input Function Configuration Registers  |
| GPIO_FUNC0_IN_SEL_CFG_REG               | Configuration register for input signal 0   | 0x0154                                  | R/W                                     |
| GPIO_FUNC1_IN_SEL_CFG_REG               | Configuration register for input signal 1   | 0x0158                                  | R/W                                     |
| ...                                     | ...                                         | ...                                     | ...                                     |
| GPIO_FUNC126_IN_SEL_CFG_REG             | Configuration register for input signal 126 | 0x034C                                  | R/W                                     |
| GPIO_FUNC127_IN_SEL_CFG_REG             | Configuration register for input signal 127 | 0x0350                                  | R/W                                     |
| Output Function Configuration Registers | Output Function Configuration Registers     | Output Function Configuration Registers | Output Function Configuration Registers |
| GPIO_FUNC0_OUT_SEL_CFG_REG              | Configuration register for GPIO0 output     | 0x0554                                  | R/W                                     |
| GPIO_FUNC1_OUT_SEL_CFG_REG              | Configuration register for GPIO1 output     | 0x0558                                  | R/W                                     |
| GPIO_FUNC2_OUT_SEL_CFG_REG              | Configuration register for GPIO2 output     | 0x055C                                  | R/W                                     |
| GPIO_FUNC3_OUT_SEL_CFG_REG              | Configuration register for GPIO3 output     | 0x0560                                  | R/W                                     |
| GPIO_FUNC4_OUT_SEL_CFG_REG              | Configuration register for GPIO4 output     | 0x0564                                  | R/W                                     |
| GPIO_FUNC5_OUT_SEL_CFG_REG              | Configuration register for GPIO5 output     | 0x0568                                  | R/W                                     |
| GPIO_FUNC6_OUT_SEL_CFG_REG              | Configuration register for GPIO6 output     | 0x056C                                  | R/W                                     |
| GPIO_FUNC7_OUT_SEL_CFG_REG              | Configuration register for GPIO7 output     | 0x0570                                  | R/W                                     |
| GPIO_FUNC8_OUT_SEL_CFG_REG              | Configuration register for GPIO8 output     | 0x0574                                  | R/W                                     |
| GPIO_FUNC9_OUT_SEL_CFG_REG              | Configuration register for GPIO9 output     | 0x0578                                  | R/W                                     |
| GPIO_FUNC10_OUT_SEL_CFG_REG             | Configuration register for GPIO10 output    | 0x057C                                  | R/W                                     |
| GPIO_FUNC11_OUT_SEL_CFG_REG             | Configuration register for GPIO11 output    | 0x0580                                  | R/W                                     |
| GPIO_FUNC12_OUT_SEL_CFG_REG             | Configuration register for GPIO12 output    | 0x0584                                  | R/W                                     |
| GPIO_FUNC13_OUT_SEL_CFG_REG             | Configuration register for GPIO13 output    | 0x0588                                  | R/W                                     |
| GPIO_FUNC14_OUT_SEL_CFG_REG             | Configuration register for GPIO14 output    | 0x058C                                  | R/W                                     |
| GPIO_FUNC15_OUT_SEL_CFG_REG             | Configuration register for GPIO15 output    | 0x0590                                  | R/W                                     |
| GPIO_FUNC16_OUT_SEL_CFG_REG             | Configuration register for GPIO16 output    | 0x0594                                  | R/W                                     |
| GPIO_FUNC17_OUT_SEL_CFG_REG             | Configuration register for GPIO17 output    | 0x0598                                  | R/W                                     |
| GPIO_FUNC18_OUT_SEL_CFG_REG             | Configuration register for GPIO18 output    | 0x059C                                  | R/W                                     |
| GPIO_FUNC19_OUT_SEL_CFG_REG             | Configuration register for GPIO19 output    | 0x05A0                                  | R/W                                     |
| GPIO_FUNC20_OUT_SEL_CFG_REG             | Configuration register for GPIO20 output    | 0x05A4                                  | R/W                                     |
| GPIO_FUNC21_OUT_SEL_CFG_REG             | Configuration register for GPIO21 output    | 0x05A8                                  | R/W                                     |
| Version Register                        | Version Register                            | Version Register                        | Version Register                        |
| GPIO_DATE_REG                           | GPIO version register                       | 0x06FC                                  | R/W                                     |
| Clock Gate Register                     | Clock Gate Register                         | Clock Gate Register                     | Clock Gate Register                     |
| GPIO_CLOCK_GATE_REG                     | GPIO clock gate register                    | 0x062C                                  | R/W                                     |

## 5.14.2 IO MUX Register Summary

The addresses in this section are relative to the IO MUX base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                    | Description                                      | Address                                       | Access           |                  |                  |
|-------------------------|--------------------------------------------------|-----------------------------------------------|------------------|------------------|------------------|
| Configuration Registers |                                                  |                                               |                  |                  |                  |
| IO_MUX_PIN_CTRL_REG     | Clock output configuration Register              | Clock output configuration Register           | 0x0000           | R/W              |                  |
| IO_MUX_GPIO0_REG        | IO MUX configuration register for pin XTAL_32K_P |                                               | 0x0004           | R/W              |                  |
| IO_MUX_GPIO1_REG        | IO MUX configuration register for pin XTAL_32K_N |                                               | 0x0008           | R/W              |                  |
| IO_MUX_GPIO2_REG        | IO MUX configuration register for pin GPIO2      | IO MUX configuration register for pin GPIO2   | 0x000C           | R/W              |                  |
| IO_MUX_GPIO3_REG        | IO MUX configuration register for pin GPIO3      | IO MUX configuration register for pin GPIO3   | 0x0010           | R/W              |                  |
| IO_MUX_GPIO4_REG        | IO MUX configuration register for pin MTMS       | IO MUX configuration register for pin MTMS    | 0x0014           | R/W              |                  |
| IO_MUX_GPIO5_REG        | IO MUX configuration register for pin MTDI       | IO MUX configuration register for pin MTDI    | 0x0018           | R/W              |                  |
| IO_MUX_GPIO6_REG        | IO MUX configuration register for pin MTCK       | IO MUX configuration register for pin MTCK    | 0x001C           | R/W              |                  |
| IO_MUX_GPIO7_REG        | IO MUX configuration register for pin MTDO       | IO MUX configuration register for pin MTDO    | 0x0020           | R/W              |                  |
| IO_MUX_GPIO8_REG        | IO MUX configuration register for pin GPIO8      | IO MUX configuration register for pin GPIO8   | 0x0024           | R/W              |                  |
| IO_MUX_GPIO9_REG        | IO MUX configuration register for pin GPIO9      | IO MUX configuration register for pin GPIO9   | 0x0028           | R/W              |                  |
| IO_MUX_GPIO10_REG       | IO MUX configuration register for pin GPIO10     | IO MUX configuration register for pin GPIO10  | 0x002C           | R/W              |                  |
| IO_MUX_GPIO11_REG       | IO MUX configuration register for pin VDD_SPI    | IO MUX configuration register for pin VDD_SPI | 0x0030           | R/W              |                  |
| IO_MUX_GPIO12_REG       | IO MUX configuration register for pin SPIHD      | IO MUX configuration register for pin SPIHD   | 0x0034           | R/W              |                  |
| IO_MUX_GPIO13_REG       | IO MUX configuration register for pin SPIWP      | IO MUX configuration register for pin SPIWP   | 0x0038           | R/W              |                  |
| IO_MUX_GPIO14_REG       | IO MUX configuration register for pin SPICS0     | IO MUX configuration register for pin SPICS0  | 0x003C           | R/W              |                  |
| IO_MUX_GPIO15_REG       | IO MUX configuration register for pin SPICLK     | IO MUX configuration register for pin SPICLK  | 0x0040           | R/W              |                  |
| IO_MUX_GPIO16_REG       | IO MUX configuration register for pin SPID       | IO MUX configuration register for pin SPID    | 0x0044           | R/W              |                  |
| IO_MUX_GPIO17_REG       | IO MUX configuration register for pin SPIQ       | IO MUX configuration register for pin SPIQ    | 0x0048           | R/W              |                  |
| IO_MUX_GPIO18_REG       | IO MUX configuration register for pin GPIO18     | IO MUX configuration register for pin GPIO18  | 0x004C           | R/W              |                  |
| IO_MUX_GPIO19_REG       | IO MUX configuration register for pin GPIO19     | IO MUX configuration register for pin GPIO19  | 0x0050           | R/W              |                  |
| IO_MUX_GPIO20_REG       | IO MUX configuration register for pin U0RXD      | IO MUX configuration register for pin U0RXD   | 0x0054           | R/W              |                  |
| IO_MUX_GPIO21_REG       | IO MUX configuration register for pin U0TXD      | IO MUX configuration register for pin U0TXD   | 0x0058           | R/W              |                  |
| Version Register        | Version Register                                 | Version Register                              | Version Register | Version Register | Version Register |
| IO_MUX_DATE_REG         | IO MUX Version Control Register                  | IO MUX Version Control Register               | 0x00FC           | R/W              |                  |

## 5.14.3 SDM Register Summary

The addresses in this section are relative to (GPIO base address provided in Table 3.3-3 in Chapter 3 System and Memory + 0x0F00).

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                    | Description   | Address   | Access   |
|-------------------------|---------------|-----------|----------|
| Configuration registers |               |           |          |

| Name                          | Description                               | Address   | Access   |
|-------------------------------|-------------------------------------------|-----------|----------|
| GPIOSD_SIGMADELTA0_REG        | Duty Cycle Configuration Register of SDM0 | 0x0000    | R/W      |
| GPIOSD_SIGMADELTA1_REG        | Duty Cycle Configuration Register of SDM1 | 0x0004    | R/W      |
| GPIOSD_SIGMADELTA2_REG        | Duty Cycle Configuration Register of SDM2 | 0x0008    | R/W      |
| GPIOSD_SIGMADELTA3_REG        | Duty Cycle Configuration Register of SDM3 | 0x000C    | R/W      |
| GPIOSD_SIGMADELTA_CG_REG      | Clock Gating Configuration Register       | 0x0020    | R/W      |
| GPIOSD_SIGMADELTA_MISC_REG    | MISC Register                             | 0x0024    | R/W      |
| Version register              |                                           |           |          |
| GPIOSD_SIGMADELTA_VERSION_REG | Version Control Register                  | 0x0028    | R/W      |

## 5.15 Registers

## 5.15.1 GPIO Matrix Registers

The addresses in this section are relative to the GPIO base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 5.1. GPIO\_BT\_SELECT\_REG (0x0000)

![Image](images/05_Chapter_5_img008_3336adc5.png)

GPIO\_BT\_SEL Reserved (R/W)

Register 5.2. GPIO\_OUT\_REG (0x0004)

![Image](images/05_Chapter_5_img009_ebe77b73.png)

GPIO\_OUT\_DATA\_ORIG GPIO0 ~ 21 output value in simple GPIO output mode. The values of bit0 ~ bit21 correspond to the output value of GPIO0 ~ GPIO21 respectively, and bit22 ~ bit25 are invalid. (R/W/SS)

Register 5.3. GPIO\_OUT\_W1TS\_REG (0x0008)

![Image](images/05_Chapter_5_img010_31b06093.png)

GPIO\_OUT\_W1TS GPIO0 ~ 21 output set register. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. If the value 1 is written to a bit here, the corresponding bit in GPIO\_OUT\_REG will be set to 1. Recommended operation: use this register to set GPIO\_OUT\_REG. (WT)

Register 5.4. GPIO\_OUT\_W1TC\_REG (0x000C)

![Image](images/05_Chapter_5_img011_2793ec41.png)

GPIO\_OUT\_W1TC GPIO0 ~ 21 output clear register. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. If the value 1 is written to a bit here, the corresponding bit in GPIO\_OUT\_REG will be cleared. Recommended operation: use this register to clear GPIO\_OUT\_REG. (WT)

Register 5.5. GPIO\_ENABLE\_REG (0x0020)

![Image](images/05_Chapter_5_img012_bd47f4ce.png)

GPIO\_ENABLE\_DATA GPIO output enable register for GPIO0 ~ 21. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. (R/W/SS)

Register 5.6. GPIO\_ENABLE\_W1TS\_REG (0x0024)

![Image](images/05_Chapter_5_img013_a7488de2.png)

GPIO\_ENABLE\_W1TS GPIO0 ~ 21 output enable set register. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. If the value 1 is written to a bit here, the corresponding bit in GPIO\_ENABLE\_REG will be set to 1. Recommended operation: use this register to set GPIO\_ENABLE\_REG. (WT)

Register 5.7. GPIO\_ENABLE\_W1TC\_REG (0x0028)

![Image](images/05_Chapter_5_img014_cc0e10ea.png)

GPIO\_ENABLE\_W1TC GPIO0 ~ 21 output enable clear register. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. If the value 1 is written to a bit here, the corresponding bit in GPIO\_ENABLE\_REG will be cleared. Recommended operation: use this register to clear GPIO\_ENABLE\_REG. (WT)

Register 5.8. GPIO\_STRAP\_REG (0x0038)

![Image](images/05_Chapter_5_img015_30748d23.png)

GPIO\_STRAPPING GPIO strapping values. (RO)

- •

- bit 0: GPIO2

- •

- bit 2: GPIO8

- bit 3: GPIO9

![Image](images/05_Chapter_5_img016_1984bce3.png)

Register 5.9. GPIO\_IN\_REG (0x003C)

![Image](images/05_Chapter_5_img017_b10ad082.png)

GPIO\_IN\_DATA\_NEXT GPIO0 ~ 21 input value. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. Each bit represents a pin input value, 1 for high level and 0 for low level. (RO)

Register 5.10. GPIO\_STATUS\_REG (0x0044)

![Image](images/05_Chapter_5_img018_7f8fa1a2.png)

GPIO\_STATUS\_INTERRUPT GPIO0 ~ 21 interrupt status register. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. (R/W/SS)

Register 5.11. GPIO\_STATUS\_W1TS\_REG (0x0048)

![Image](images/05_Chapter_5_img019_84d8537f.png)

GPIO\_STATUS\_W1TS GPIO0 ~ 21 interrupt status set register. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. If the value 1 is written to a bit here, the corresponding bit in GPIO\_STATUS\_INTERRUPT will be set to 1. Recommended operation: use this register to set GPIO\_STATUS\_INTERRUPT. (WT)

Register 5.12. GPIO\_STATUS\_W1TC\_REG (0x004C)

![Image](images/05_Chapter_5_img020_81f44248.png)

GPIO\_STATUS\_W1TC GPIO0 ~ 21 interrupt status clear register. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. If the value 1 is written to a bit here, the corresponding bit in GPIO\_STATUS\_INTERRUPT will be cleared. Recommended operation: use this register to clear GPIO\_STATUS\_INTERRUPT. (WT)

Register 5.13. GPIO\_PCPU\_INT\_REG (0x005C)

![Image](images/05_Chapter_5_img021_683fbc86.png)

GPIO\_PROCPU\_INT GPIO0 ~ 21 PRO\_CPU interrupt status. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. This interrupt status is corresponding to the bit in GPIO\_STATUS\_REG when assert (high) enable signal (bit13 of GPIO\_PINn\_REG). (RO)

Register 5.14. GPIO\_PINn\_REG (n: 0-21) (0x0074+4*n)

![Image](images/05_Chapter_5_img022_f53d36f7.png)

GPIO\_PINn\_SYNC2\_BYPASS For the second stage synchronization, GPIO input data can be synchronized on either edge of the APB clock. 0: no synchronization; 1: synchronized on falling edge; 2 and 3: synchronized on rising edge. (R/W)

- GPIO\_PINn\_PAD\_DRIVER pin drive selection. 0: normal output; 1: open drain output. (R/W)

GPIO\_PINn\_SYNC1\_BYPASS For the first stage synchronization, GPIO input data can be synchronized on either edge of the APB clock. 0: no synchronization; 1: synchronized on falling edge; 2 and 3: synchronized on rising edge. (R/W)

GPIO\_PINn\_INT\_TYPE Interrupt type selection. 0: GPIO interrupt disabled; 1: rising edge trigger; 2: falling edge trigger; 3: any edge trigger; 4: low level trigger; 5: high level trigger. (R/W)

GPIO\_PINn\_WAKEUP\_ENABLE GPIO wake-up enable bit, only wakes up the CPU from Light-sleep. (R/W)

- GPIO\_PINn\_CONFIG reserved (R/W)

GPIO\_PINn\_INT\_ENA Interrupt enable bits. bit13: CPU interrupt enabled; bit14: CPU non-maskable interrupt enabled. (R/W)

## Register 5.15. GPIO\_STATUS\_NEXT\_REG (0x014C)

![Image](images/05_Chapter_5_img023_2fbcea82.png)

GPIO\_STATUS\_INTERRUPT\_NEXT Interrupt source signal of GPIO0 ~ 21, could be rising edge interrupt, falling edge interrupt, level sensitive interrupt and any edge interrupt. Bit0 ~ bit21 are corresponding to GPIO0 ~ 21, and bit22 ~ bit25 are invalid. (RO)

Register 5.16. GPIO\_FUNCn\_IN\_SEL\_CFG\_REG (n: 0-127) (0x0154+4*n)

![Image](images/05_Chapter_5_img024_7685e977.png)

GPIO\_FUNCn\_IN\_SEL Selection control for peripheral input signal n, selects a pin from the 22 GPIO matrix pins to connect this input signal. Or selects 0x1e for a constantly high input or 0x1f for a constantly low input. (R/W)

GPIO\_FUNCn\_IN\_INV\_SEL Invert the input value. 1: invert enabled; 0: invert disabled. (R/W)

GPIO\_SIGn\_IN\_SEL Bypass GPIO matrix. 1: route signals via GPIO matrix, 0: connect signals directly to peripheral configured in IO MUX. (R/W)

## Register 5.17. GPIO\_FUNCn\_OUT\_SEL\_CFG\_REG (n: 0-21) (0x0554+4*n)

![Image](images/05_Chapter_5_img025_6d999ab6.png)

GPIO\_FUNCn\_OUT\_SEL Selection control for GPIO output n. If a value Y (0&lt;=Y&lt;128) is written to this field, the peripheral output signal Y will be connected to GPIO output n. If a value 128 is written to this field, bit n of GPIO\_OUT\_REG and GPIO\_ENABLE\_REG will be selected as the output value and output enable. (R/W)

GPIO\_FUNCn\_OUT\_INV\_SEL 0: Do not invert the output value; 1: Invert the output value. (R/W)

GPIO\_FUNCn\_OEN\_SEL 0: Use output enable signal from peripheral; 1: Force the output enable signal to be sourced from bit n of GPIO\_ENABLE\_REG. (R/W)

GPIO\_FUNCn\_OEN\_INV\_SEL 0: Do not invert the output enable signal; 1: Invert the output enable signal. (R/W)

Register 5.18. GPIO\_CLOCK\_GATE\_REG (0x062C)

![Image](images/05_Chapter_5_img026_50546e9d.png)

GPIO\_CLK\_EN Clock gating enable bit. If set to 1, the clock is free running. (R/W)

## Register 5.19. GPIO\_DATE\_REG (0x06FC)

![Image](images/05_Chapter_5_img027_ffaac764.png)

GPIO\_DATE\_REG Version control register (R/W)

## 5.15.2 IO MUX Registers

The addresses in this section are relative to the IO MUX base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 5.20. IO\_MUX\_PIN\_CTRL\_REG (0x0000)

![Image](images/05_Chapter_5_img028_9ae2227f.png)

IO\_MUX\_CLK\_OUTx If you want to output clock for I2S to CLK\_OUT\_outx, set IO\_MUX\_CLK\_OUTx to 0x0. CLK\_OUT\_outx can be found in Table 5.11-1. (R/W)

Register 5.21. IO\_MUX\_GPIOn\_REG (n: 0-21) (0x0004+4*n)

![Image](images/05_Chapter_5_img029_70e4e748.png)

- IO\_MUX\_GPIOn\_MCU\_OE Output enable of the pin in sleep mode. 1: output enabled; 0: output disabled. (R/W)
- IO\_MUX\_GPIOn\_SLP\_SEL Sleep mode selection of this pin. Set to 1 to put the pin in sleep mode. (R/W)
- IO\_MUX\_GPIOn\_MCU\_WPD Pull-down enable of the pin in sleep mode. 1: internal pull-down enabled; 0: internal pull-down disabled. (R/W)
- IO\_MUX\_GPIOn\_MCU\_WPU Pull-up enable of the pin during sleep mode. 1: internal pull-up enabled; 0: internal pull-up disabled. (R/W)
- IO\_MUX\_GPIOn\_MCU\_IE Input enable of the pin during sleep mode. 1: input enabled; 0: input disabled. (R/W)
- IO\_MUX\_GPIOn\_MCU\_DRV Configures the drive strength of GPIOn during sleep mode.
- GPIO2, GPIO3, GPIO5, GPIO18, GPIO18, GPIO19
- 0: ~5 mA
- 1: ~20 mA
- 2: ~10 mA
- 3: ~40 mA
- Other GPIOs
- 0: ~5 mA
- 1: ~10 mA
- 2: ~20 mA
- 3: ~40 mA

(R/W)

- IO\_MUX\_GPIOn\_FUN\_WPD Pull-down enable of the pin. 1: internal pull-down enabled; 0: internal pull-down disabled. (R/W)
- IO\_MUX\_GPIOn\_FUN\_WPU Pull-up enable of the pin. 1: internal pull-up enabled; 0: internal pull-up disabled. (R/W)
- IO\_MUX\_GPIOn\_FUN\_IE Input enable of the pin. 1: input enabled; 0: input disabled. (R/W)
- Continued on the next page...

![Image](images/05_Chapter_5_img030_01b6aa4c.png)

Register 5.21. IO\_MUX\_GPIOn\_REG (n: 0-21) (0x0004+4*n)

## Continued from the previous page...

- IO\_MUX\_GPIOn\_FUN\_DRV Select the drive strength of the pin.
- GPIO2, GPIO3, GPIO5, GPIO18, GPIO18, GPIO19
- 0: ~5 mA
- 1: ~20 mA
- 2: ~10 mA
- 3: ~40 mA
- Other GPIOs

0: ~5 mA

- 1: ~10 mA

2: ~20 mA

3: ~40 mA

(R/W)

- IO\_MUX\_GPIOn\_MCU\_SEL Select IO MUX function for this signal. 0: Select Function 0; 1: Select Function 1; etc. (R/W)
- IO\_MUX\_GPIOn\_FILTER\_EN Enable filter for pin input signals. 1: Filter enabled; 0: Filter disabled. (R/W)

Register 5.22. IO\_MUX\_DATE\_REG (0x00FC)

![Image](images/05_Chapter_5_img031_6947a083.png)

IO\_MUX\_DATE\_REG Version control register (R/W)

## 5.15.3 SDM Output Registers

The addresses in this section are relative to (GPIO base address provided in Table 3.3-3 in Chapter 3 System and Memory + 0x0F00).

Register 5.23. GPIOSD\_SIGMADELTAn\_REG (n: 0-3) (0x0000+4*n)

![Image](images/05_Chapter_5_img032_08bb6cf6.png)

GPIOSD\_SDn\_IN This field is used to configure the duty cycle of sigma delta modulation output. (R/W)

GPIOSD\_SDn\_PRESCALE This field is used to set a divider value to divide APB clock. (R/W)

Register 5.24. GPIOSD\_SIGMADELTA\_CG\_REG (0x0020)

![Image](images/05_Chapter_5_img033_335906ab.png)

Register 5.25. GPIOSD\_SIGMADELTA\_MISC\_REG (0x0024)

![Image](images/05_Chapter_5_img034_4e4086a4.png)

Register 5.26. GPIOSD\_SIGMADELTA\_VERSION\_REG (0x0028)

![Image](images/05_Chapter_5_img035_cb4220b4.png)

GPIOSD\_DATE Version Control Register. (R/W)
