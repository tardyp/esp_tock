---
chapter: 39
title: "Chapter 39"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 39

## On-Chip Sensor and Analog Signal Processing

## 39.1 Overview

ESP32-C6 provides the following on-chip sensor and analog signal processing peripherals:

- One 12-bit Successive Approximation ADC (SAR ADC) for measuring analog signals from seven channels;
- One temperature sensor for measuring the internal temperature of the ESP32-C6 chip.

## 39.2 SAR ADC

## 39.2.1 Overview

ESP32-C6 integrates a 12-bit SAR ADC which is able to measure analog signals from up to seven pins. It is also possible to measure internal signals, such as VDD33. The SAR ADC is managed by the DIG ADC controller, which drives the Digital\_reader to sample channel voltages by SAR ADC. It supports high-performance multi-channel scanning and DMA continuous conversion.

## 39.2.2 Features

- 12-bit sampling resolution
- Analog voltage sampling from up to seven pins
- DIG ADC controller:
- – Separate control modules for one-time sampling and multi-channel scanning
- – Configurable channel scanning sequence in multi-channel scanning mode
- – Two filters with configurable filter coefficient
- – Threshold monitoring, which helps to trigger an interrupt when the sampled value is greater than the pre-set high threshold or less than the pre-set low threshold
- – DMA

## 39.2.3 Functional Description

The major components of SAR ADC and their interconnections are shown in Figure 39.2-1 .

Figure 39.2-1. SAR ADCs Function Overview

![Image](images/39_Chapter_39_img001_c66f8579.png)

As shown in Figure 39.2-1, the SAR ADC module provides the following functions and consists of the following components:

- Measures voltages from up to seven channels.
- Clock management: selects clock sources and their dividers:
- – Clock sources: can be XTAL\_CLK, RC\_FAST\_CLK, or PLL\_F80M\_CLK;
- – Divided Clocks:
* SAR\_CLK: operating clock for SAR ADC and Digital\_reader (the control signal generator for analog circuit). Note that the divider (sar\_div) of SAR\_ADC must be no less than 15;
* ADC\_CTRL\_CLK: operating clock for DIG ADC FSM and other logic circuits except for APB interface and Digital\_reader.
- Digital\_reader (driven by DIG ADC FSM): reads data from SAR ADC.
- DIG ADC FSM: generates the signals required throughout the ADC sampling process.
- Threshold monitorx: threshold monitor 1 and threshold monitor 2. The monitorx will trigger an interrupt when the sampled value is greater than the pre-set high threshold or less than the pre-set low threshold.

The following sections describe the individual components in details.

![Image](images/39_Chapter_39_img002_62293604.png)

## 39.2.3.1 Input Signals

In order to sample an analog signal, the SAR ADC must first select the analog pin to measure via an internal multiplexer. A summary of all the analog signals that may be sent to the SAR ADC module for processing by ADC are presented in Table 39.2-1 .

Table 39.2-1. SAR ADC Input Signals

| Signal         |   Channel | ADC Selection   |
|----------------|-----------|-----------------|
| X32K_P (GPIO0) |         0 | SAR ADC         |
| X32K_N (GPIO1) |         1 | SAR ADC         |
| GPIO2          |         2 | SAR ADC         |
| GPIO3          |         3 | SAR ADC         |
| MTMS (GPIO4)   |         4 | SAR ADC         |
| MTDI (GPIO5)   |         5 | SAR ADC         |
| MTCK (GPIO6)   |         6 | SAR ADC         |

## 39.2.3.2 ADC Conversion and Attenuation

When the SAR ADC converts an analog voltage, the resolution (12-bit) of the conversion spans voltage range from 0 mV to Vr Vref . Vref is the SAR ADC's internal reference voltage (1100 mV by design). The output value of the conversion (data) is mapped to analog voltage Vdata using the following formula:

<!-- formula-not-decoded -->

In order to convert voltages larger than Vref , input signals can be attenuated before being input into the SAR ADC. The attenuation can be configured to 0 dB, 2.5 dB, 6 dB, and 12 dB.

## 39.2.3.3 DIG ADC Controller

The clock of the DIG ADC controller is quite fast, thus the sample rate is high. This controller supports:

- up to 12-bit sampling resolution
- software-triggered one-time sampling
- timer-triggered multi-channel scanning

The configuration of a one-time sampling triggered by the software is as follows:

- Set APB\_SARADC\_ONETIME\_SAMPLE to select SAR ADC to perform a one-time sampling.
- Configure APB\_SARADC\_ONETIME\_CHANNEL to select a channel to sample.
- Configure APB\_SARADC\_ONETIME\_ATTEN to set attenuation.
- Configure APB\_SARADC\_ONETIME\_START to start the one-time sampling.
- Upon completion of sampling, the APB\_SARADC\_ADC\_DONE\_INT\_RAW interrupt is generated. Once this interrupt is detected, software can initiate reading of the sampled values from APB\_SARADC\_ADC\_DATA .

If the timer-triggered multi-channel scanning is selected, follow the configuration below. Note that in this mode, the scan sequence is performed according to the configuration entered in the pattern table.

- Configure APB\_SARADC\_TIMER\_TARGET to set the trigger target for DIG ADC timer. When the timer counting reaches two times of the pre-configured cycle number, a sampling operation is triggered.
- Configure APB\_SARADC\_TIMER\_EN to enable the timer.
- When the timer times out, it drives FSM to start sampling according to the pattern table.
- Sampled data is automatically stored in memory via DMA. An interrupt is triggered once the scan is completed.

## Note:

One-time sampling and multi-channel scanning can not be configured to perform at the same time.

## 39.2.3.4 DMA Support

DIG ADC controller supports direct memory access via the peripheral DMA, which is triggered by DIG ADC timer. Users can switch the DMA data path to DIG ADC by configuring APB\_SARADC\_APB\_ADC\_TRANS via software. For specific DMA configuration, please refer to Chapter 4 GDMA Controller (GDMA) .

## 39.2.3.5 DIG ADC FSM

## Overview

Figure 39.2-2 shows the diagram of DIG ADC FSM.

Figure 39.2-2. Diagram of DIG ADC FSM

![Image](images/39_Chapter_39_img003_65f8dc22.png)

## Wherein:

- Timer: a dedicated timer for DIG ADC controller to generate a sample\_start signal.

- pr: the pointer to pattern table entries. FSM sends out corresponding signals based on the configuration of the pattern table entry that the pointer points to.

Execution of the sampling process is as follows:

- Configure APB\_SARADC\_TIMER\_EN to enable the DIG ADC timer. The timeout event of this timer triggers an sample\_start signal. This signal drives the FSM module to start sampling.
- When the FSM module receives the sample\_start signal, it starts the following operations:
- – Power up SAR ADC.
- – Configure the ADC channel and attenuation based on the pattern table entry that the current pr points to.
- – Output the corresponding en\_pad and atten signals to the analog side according to the configuration information.
- – Initiate the sar\_start signal and start sampling.
- When the FSM module receives the reader\_done signal from ADC Reader (Digital\_reader), it starts the following operations:
- – Stop sampling.
- – Transfer the data to the filter, and then threshold monitor transfers the data to memory via DMA (see Figure 39.2-1).
- – Update the pattern table pointer pr and wait for the next sampling. Note that if the pointer pr is smaller than APB\_SARADC\_SAR\_PATT\_LEN (table\_length), then pr = pr + 1. Otherwise, pr is cleared.

## Pattern Table

There is one pattern table in the controller, consisting of the APB\_SARADC\_SAR\_PATT\_TAB1\_REG and APB\_SARADC\_SAR\_PATT\_TAB2\_REG registers. See Figure 39.2-3 and Figure 39.2-4:

![Image](images/39_Chapter_39_img004_525b2518.png)

cmd x represents pattern table entries. x here is the index numbered from 0 ~ 3.

Figure 39.2-3. APB\_SARADC\_SAR\_PATT\_TAB1\_REG and Pattern Table Entry 0 - Entry 3

![Image](images/39_Chapter_39_img005_1588419a.png)

cmd x represents pattern table entries. x here is the index number from 4 ~ 7.

Figure 39.2-4. APB\_SARADC\_SAR\_PATT\_TAB2\_REG and Pattern Table Entry 4 - Entry 7

![Image](images/39_Chapter_39_img006_e5160bbe.png)

Each register consists of four 6-bit pattern table entries. Each entry is composed of three fields that contain the ADC channel and attenuation information, as shown in Table 39.2-5 .

Figure 39.2-5. Pattern Table Entry

![Image](images/39_Chapter_39_img007_a52d54d9.png)

atten Attenuation:

0: 0 dB

1: 2.5 dB

2: 6 dB

3: 12 dB

ch\_sel ADC channel, see Table 39.2-1 .

## Configuration of multi-channel scanning

In this example, two channels are selected for multi-channel scanning:

- Channel 0 of SAR ADC, with the attenuation of 2.5 dB
- Channel 2 of SAR ADC, with the attenuation of 12 dB

The detailed configuration is as follows:

- Configure the first pattern table entry (cmd0):

Figure 39.2-6. cmd1 configuration

![Image](images/39_Chapter_39_img008_1c467226.png)

atten write the value of 1 to this field, to set the attenuation to 2.5 dB.

ch\_sel write the value of 0 to this field, to select channel 0 (see Table 39.2-1).

- Configure the second pattern table entry (cmd1):

Figure 39.2-7. cmd0 Configuration

![Image](images/39_Chapter_39_img009_93d4a2ef.png)

atten write the value of 3 to this field, to set the attenuation to 12 dB.

ch\_sel write the value of 2 to this field, to select channel 2 (see Table 39.2-1).

![Image](images/39_Chapter_39_img010_378b0da4.png)

- Configure APB\_SARADC\_SAR\_PATT\_LEN to 1, i.e., set pattern table length to (this value + 1 = 2). Then pattern table entries cmd0 and cmd1 will be used.
- Enable the timer, then DIG ADC controller starts scanning the two channels in cycles, as configured in the pattern table entries.

## DMA Data Format

The ADC eventually passes 32-bit data to the DMA. See the figure below.

Figure 39.2-8. DMA Data Format

![Image](images/39_Chapter_39_img011_5072bdbf.png)

data SAR ADC read value; 12-bit

ch\_sel Channel; 3-bit

## 39.2.3.6 ADC Filters

The DIG ADC controller provides two filters for automatic filtering of sampled ADC data. Both filters can be configured to any channel of the SAR ADC and then filter the sampled data for the target channel. The filter's formula is shown below:

<!-- formula-not-decoded -->

- data cur : the filtered data value.

- data in : the sampled data value from the ADC.

- data prev : the last filtered data value.

- k: the filter coefficient.

The filters are configured as follows:

- Configure APB\_SARADC\_FILTER\_CHANNELx to select the ADC channel for filter x .
- Configure APB\_SARADC\_FILTER\_FACTORx to set the coefficient for filter x .

Note that x is used here as the placeholder of filter index. 0: filter 0; 1: filter 1.

## 39.2.3.7 Threshold Monitoring

DIG ADC controller contains two threshold monitors that can be configured to monitor on any channel of the SAR ADC. A high threshold interrupt is triggered when the ADC sample value is larger than the pre-configured high threshold, and a low threshold interrupt is triggered if the sample value is lower than the pre-configured low threshold.

The configuration of threshold monitoring is as follows:

- Set APB\_SARADC\_THRESx\_EN to enable threshold monitor x;
- Configure APB\_SARADC\_THRESx\_LOW to set a low threshold;

- Configure APB\_SARADC\_THRESx\_HIGH to set a high threshold;
- Configure APB\_SARADC\_THRESx\_CHANNEL to select the channel to monitor.

Note that x is used here as the placeholder of monitor index. 0 stands for monitor0 and 1 for monitor 1 .

## 39.3 Temperature Sensor

## 39.3.1 Overview

ESP32-C6 provides a temperature sensor to monitor temperature changes inside the chip in real time. Figure 39.3-1 shows the internal structure of the temperature sensor.

Figure 39.3-1. Temperature Sensor Structure

![Image](images/39_Chapter_39_img012_464c2ed1.png)

## 39.3.2 Features

The temperature sensor has the following features:

- Software triggering, wherein the data can be read continuously once triggered
- Hardware automatic triggering and temperature monitoring
- Configurable temperature offset based on the environment to improve the accuracy
- Adjustable measurement range

## 39.3.3 Functional Description

The temperature sensor can be started by software as follows:

- Set APB\_SARADC\_TSENS\_PU to start XPD\_SAR and to enable the temperature sensor; Set PCR\_TSENS\_CLK\_EN to enable the temperature sensor clock;
- Wait for APB\_SARADC\_TSENS\_XPD\_WAIT clock cycles till the reset of the temperature sensor is released, then the sensor starts measuring the temperature;
- Wait for a while and then read the data from APB\_SARADC\_TSENS\_OUT. The output value gradually approaches the actual temperature linearly as the measurement time increases.

The temperature sensor can also be automatically triggered to continuously monitor the temperature as follows:

- Set APB\_SARADC\_TSENS\_PU to start XPD\_SAR and to enable the temperature sensor; Set PCR\_TSENS\_CLK\_EN to enable the temperature sensor clock;
- Wait for APB\_SARADC\_TSENS\_XPD\_WAIT clock cycles till the reset of the temperature sensor is released, then the sensor starts measuring the temperature;
- Configure APB\_SARADC\_TSENS\_SAMPLE\_RATE to set sample rate;
- Set APB\_SARADC\_WAKEUP\_MODE to enable temperature monitor mode;
- Set APB\_SARADC\_WAKEUP\_EN to enable temperature monitoring;
- Set APB\_SARADC\_TSENS\_SAMPLE\_EN to automatically start continuous temperature monitoring.

There are two wake-up modes for the temperature sensor to start automatic monitor:

- Absolute value mode:
- – Monitors the absolute value of the current temperature. Configure APB\_SARADC\_WAKEUP\_TH\_LOW and APB\_SARADC\_WAKEUP\_TH\_HIGH to set the temperature thresholds. Wake-up will be triggered if the sampled value exceeds the high threshold or is less than the low threshold.
- Incremental value mode:
- – Monitors the incremental value of the current temperature. If the temperature increment of two consecutive samplings exceeds the high threshold configured in APB\_SARADC\_WAKEUP\_TH\_HIGH or the temperature decrement of two consecutive samplings exceeds the low threshold configured in APB\_SARADC\_WAKEUP\_TH\_LOW, a wake-up will be triggered. For example, when APB\_SARADC\_WAKEUP\_TH\_LOW is configured as 8, if two consecutive sampling values are 28 and 19 respectively, i.e., the temperature decrement is 9, then a wake-up will be triggered.

The actual temperature (°C) can be obtained by converting the output of temperature sensor via the following formula:

<!-- formula-not-decoded -->

VALUE in the formula is the output of the temperature sensor, and the offset is determined by the temperature offset. The temperature offset varies in different actual environment (the temperature range). For details, refer to Table 39.3-1 .

Table 39.3-1. Temperature Offset

| Measurement Range (°C)   |   Temperature Offset (°C) |
|--------------------------|---------------------------|
| 50 ~ 125                 |                        -2 |
| 20 ~ 100                 |                        -1 |

| -10 ~ 80   |   0 |
|------------|-----|
| -30 ~ 50   |   1 |
| -40 ~ 20   |   2 |

## 39.4 Event Task Matrix Feature

The SAR ADC and temperature sensor on ESP32-C6 support the Event Task Matrix (ETM) function, which allows SAR ADC's/temperature sensor's ETM tasks to be triggered by any peripherals' ETM events, or SAR ADC's/temperature sensor's ETM events to trigger any peripherals' ETM tasks. This section introduces the ETM tasks and events related to SAR ADC and temperature sensor. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

## 39.4.1 SAR ADC's ETM Feature

The SAR ADC can receive the following ETM tasks:

- ADC\_TASK\_SAMPLE0: ADC starts one-time sampling when this task is triggered.
- ADC\_TASK\_START0: ADC starts continuous sampling when this task is triggered.
- ADC\_TASK\_STOP0: ADC stops sampling when this task is triggered.

The SAR ADC can generate the following ETM events:

- ADC\_EVT\_CONV\_CMPLT0: Generated when ADC completes a sampling.
- ADC\_EVT\_EQ\_ABOVE\_THRESHn (n: 0 ~ 1): Generated when the ADC data is above the threshold.
- ADC\_EVT\_EQ\_BELOW\_THRESHn (n: 0 ~ 1): Generated when the ADC data is below the threshold.
- ADC\_EVT\_STARTED0: Generated when ADC begins sampling; one-time sampling will not trigger this event.
- ADC\_EVT\_STOPPED0: Generated when ADC stops sampling, one-time sampling will not trigger this event.

In practical applications, SAR ADC's ETM events can trigger its own ETM tasks. For example, the ADC\_EVT\_EQ\_ABOVE\_THRESHn event can trigger the ADC\_TASK\_STOP0 task.

## 39.4.2 Temperature Sensor's ETM Feature

The temperature sensor can receive the following ETM tasks:

- TMPSNSR\_TASK\_START\_SAMPLE: The temperature sensor starts sampling when this task is triggered.
- TMPSNSR\_TASK\_STOP\_SAMPLE: The temperature sensor stops sampling when this task is triggered.

The temperature sensor can generate the following ETM events:

- TMPSNSR\_EVT\_OVER\_LIMIT: Generated when the temperature is beyond the threshold.

## 39.5 Interrupts

- APB\_SARADC\_ADC\_DONE\_INT: Triggered when SAR ADC completes one data conversion.
- APB\_SARADC\_THRESx\_HIGH\_INT: Triggered when the sampling value is higher than the high threshold of monitor x .
- APB\_SARADC\_THRESx\_LOW\_INT: Triggered when the sampling value is lower than the low threshold of monitor x .
- APB\_SARADC\_TSENS\_INT: Triggered when the temperature sample value exceeds the threshold.

## 39.6 Register Summary

The addresses in this section are relative to On-Chip Sensors and Analog Signal Processing base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                           | Description                                  | Address   | Access   |
|--------------------------------|----------------------------------------------|-----------|----------|
| Configure Register             |                                              |           |          |
| APB_SARADC_CTRL_REG            | SAR ADC control register 1                   | 0x0000    | R/W      |
| APB_SARADC_CTRL2_REG           | SAR ADC control register 2                   | 0x0004    | R/W      |
| APB_SARADC_FILTER_CTRL1_REG    | Filtering control register 1                 | 0x0008    | R/W      |
| APB_SARADC_SAR_PATT_TAB1_REG   | Pattern table register 1                     | 0x0018    | R/W      |
| APB_SARADC_SAR_PATT_TAB2_REG   | Pattern table register 2                     | 0x001C    | R/W      |
| APB_SARADC_ONETIME_SAMPLE_REG  | Configuration register for one-time sampling | 0x0020    | R/W      |
| APB_SARADC_FILTER_CTRL0_REG    | Filtering control register 0                 | 0x0028    | R/W      |
| APB_SARADC_SAR1DATA_STATUS_REG | SAR ADC sampling data register               | 0x002C    | RO       |
| APB_SARADC_THRES0_CTRL_REG     | Sampling threshold control register 0        | 0x0034    | R/W      |
| APB_SARADC_THRES1_CTRL_REG     | Sampling threshold control register 1        | 0x0038    | R/W      |
| APB_SARADC_THRES_CTRL_REG      | Sampling threshold control register          | 0x003C    | R/W      |
| APB_SARADC_INT_ENA_REG         | Enable register of SAR ADC interrupts        | 0x0040    | R/W      |
| APB_SARADC_INT_RAW_REG         | Raw register of SAR ADC interrupts           | 0x0044    | R/WTC/SS |
| APB_SARADC_INT_ST_REG          | State register of SAR ADC interrupts         | 0x0048    | RO       |
| APB_SARADC_INT_CLR_REG         | Clear register of SAR ADC interrupts         | 0x004C    | WT       |
| APB_SARADC_DMA_CONF_REG        | DMA configuration register for SAR ADC       | 0x0050    | R/W      |
| APB_SARADC_APB_TSENS_CTRL_REG  | Temperature sensor control register 1        | 0x0058    | varies   |
| APB_SARADC_TSENS_CTRL2_REG     | Temperature sensor control register 2        | 0x005C    | R/W      |
| APB_SARADC_CALI_REG            | SAR ADC calibration register                 | 0x0060    | R/W      |
| APB_TSENS_WAKE_REG             | Temperature sensor configuration register    | 0x0064    | varies   |
| APB_TSENS_SAMPLE_REG           | Temperature sensor configuration register    | 0x0068    | R/W      |
| APB_SARADC_CTRL_DATE_REG       | Version control register                     | 0x03FC    | R/W      |

## 39.7 Registers

The addresses in this section are relative to On-Chip Sensors and Analog Signal Processing base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 39.1. APB\_SARADC\_CTRL\_REG (0x0000)

![Image](images/39_Chapter_39_img013_c26d8c94.png)

APB\_SARADC\_START\_FORCE Configures whether to use software to enable SAR ADC.

- 0: Select FSM to start SAR ADC
- 1: Select software to start SAR ADC

(R/W)

APB\_SARADC\_START Configures whether to start SAR ADC by software.

- 0: No effect
- 1: Start SAR ADC by software

Valid only when APB\_SARADC\_START\_FORCE = 1.

(R/W)

APB\_SARADC\_SAR\_CLK\_GATED Configures whether to enable SAR ADC clock gate.

- 0: Disable
- 1: Enable

(R/W)

- APB\_SARADC\_SAR\_CLK\_DIV Configures SAR ADC clock divider. This value should be no less than

2. (R/W)

APB\_SARADC\_SAR\_PATT\_LEN Configures how many pattern table entries will be used.

- 0: Only cmd3 will be used
- 1: Pattern table entries cmd0 and cmd1 will be used

(R/W)

- APB\_SARADC\_SAR\_PATT\_P\_CLEAR Configures whether to clear the pointer of pattern table for DIG ADC controller.
- 0: No effect
- 1: Clear

(R/W)

APB\_SARADC\_XPD\_SAR\_FORCE Configures whether to force select XPD SAR.

- 0: No effect

1: Force select XPD SAR

(R/W)

- APB\_SARADC\_WAIT\_ARB\_CYCLE Configures the clock cycle of waiting arbitration signal stable after SAR\_DONE. (R/W)

Register 39.2. APB\_SARADC\_CTRL2\_REG (0x0004)

![Image](images/39_Chapter_39_img014_f41c6579.png)

APB\_SARADC\_MEAS\_NUM\_LIMIT Configures whether to enable the limitation of SAR ADC's maximum conversion times.

0: Disable

1: Enable

(R/W)

APB\_SARADC\_MAX\_MEAS\_NUM Configures the SAR ADC’s maximum conversion times. (R/W)

APB\_SARADC\_SAR1\_INV Configures whether to invert the data of SAR ADC.

0: No effect

1: Invert the data of SAR ADC

(R/W)

APB\_SARADC\_TIMER\_TARGET Configures SAR ADC timer target. (R/W)

APB\_SARADC\_TIMER\_EN Configures whether to enable SAR ADC timer trigger.

0: Disable

1: Enable

(R/W)

## Register 39.3. APB\_SARADC\_FILTER\_CTRL1\_REG (0x0008)

![Image](images/39_Chapter_39_img015_bf04bee9.png)

APB\_SARADC\_FILTER\_FACTOR1 Configures the filter coefficient for SAR ADC filter 1. (R/W) APB\_SARADC\_FILTER\_FACTOR0 Configures the filter coefficient for SAR ADC filter 0. (R/W)

Register 39.4. APB\_SARADC\_SAR\_PATT\_TAB1\_REG (0x0018)

![Image](images/39_Chapter_39_img016_3c59b8b6.png)

APB\_SARADC\_SAR\_PATT\_TAB1 Configures pattern table entries 0 ~ 3 (each entry takes six bits). (R/W)

Register 39.5. APB\_SARADC\_SAR\_PATT\_TAB2\_REG (0x001C)

![Image](images/39_Chapter_39_img017_f964b19f.png)

APB\_SARADC\_SAR\_PATT\_TAB2 Configures pattern table entries 4 ~ 7 (each entry takes six bits). (R/W)

## Register 39.6. APB\_SARADC\_ONETIME\_SAMPLE\_REG (0x0020)

![Image](images/39_Chapter_39_img018_fdf54e54.png)

APB\_SARADC\_ONETIME\_ATTEN Configures the attenuation for a one-time sampling. (R/W)

APB\_SARADC\_ONETIME\_CHANNEL Configures the channel for a one-time sampling. (R/W)

APB\_SARADC\_ONETIME\_START Configures whether to start SAR ADC one-time sampling.

0: No effect

1: Start

(R/W)

APB\_SARADC\_ONETIME\_SAMPLE Configures whether to enable SAR ADC one-time sampling.

0: Disable

1: Enable

(R/W)

## Register 39.7. APB\_SARADC\_FILTER\_CTRL0\_REG (0x0028)

![Image](images/39_Chapter_39_img019_c900b9b5.png)

APB\_SARADC\_FILTER\_CHANNEL1 Configures the filter channel for SAR ADC filter 1. (R/W)

APB\_SARADC\_FILTER\_CHANNEL0 Configures the filter channel for SAR ADC filter 0. (R/W)

APB\_SARADC\_FILTER\_RESET Configures whether to reset SAR ADC filter.

0: No effect

1: Reset

(R/W)

Register 39.8. APB\_SARADC\_SAR1DATA\_STATUS\_REG (0x002C)

![Image](images/39_Chapter_39_img020_d77af51b.png)

APB\_SARADC\_DATA Represents SAR ADC conversion data. (RO)

Register 39.9. APB\_SARADC\_THRES0\_CTRL\_REG (0x0034)

![Image](images/39_Chapter_39_img021_0b054d11.png)

APB\_SARADC\_THRES0\_CHANNEL Configures the channel for SAR ADC monitor 0. (R/W)

APB\_SARADC\_THRES0\_HIGH Configures the high threshold for SAR ADC monitor 0. (R/W)

APB\_SARADC\_THRES0\_LOW Configures the low threshold for SAR ADC monitor 0. (R/W)

Register 39.10. APB\_SARADC\_THRES1\_CTRL\_REG (0x0038)

![Image](images/39_Chapter_39_img022_f581fe1f.png)

APB\_SARADC\_THRES1\_CHANNEL Configures the channel for SAR ADC monitor 1. (R/W)

APB\_SARADC\_THRES1\_HIGH Configures the high threshold for SAR ADC monitor 1. (R/W)

APB\_SARADC\_THRES1\_LOW Configures the low threshold for SAR ADC monitor 1. (R/W)

## Register 39.11. APB\_SARADC\_THRES\_CTRL\_REG (0x003C)

![Image](images/39_Chapter_39_img023_6452e3e3.png)

APB\_SARADC\_THRES\_ALL\_EN Configures whether to enable the threshold monitoring for all con- figured channels.

- 0: Disable

1: Enable

(R/W)

APB\_SARADC\_THRES1\_EN Configures whether to enable threshold monitor 1.

- 0: Disable
- 1: Enable

(R/W)

APB\_SARADC\_THRES0\_EN Configures whether to enable threshold monitor 0.

- 0: Disable
- 1: Enable

(R/W)

## Register 39.12. APB\_SARADC\_INT\_ENA\_REG (0x0040)

![Image](images/39_Chapter_39_img024_a50e654f.png)

APB\_SARADC\_TSENS\_INT\_ENA Write 1 to enable the APB\_SARADC\_TSENS\_INT interrupt. (R/W)

- APB\_SARADC\_THRES1\_LOW\_INT\_ENA Write 1 to enable the APB\_SARADC\_THRES1\_LOW\_INT interrupt. (R/W)
- APB\_SARADC\_THRES0\_LOW\_INT\_ENA Write 1 to enable the APB\_SARADC\_THRES0\_LOW\_INT interrupt. (R/W)
- APB\_SARADC\_THRES1\_HIGH\_INT\_ENA Write 1 to enable the APB\_SARADC\_THRES1\_HIGH\_INT interrupt. (R/W)
- APB\_SARADC\_THRES0\_HIGH\_INT\_ENA Write 1 to enable the APB\_SARADC\_THRES0\_HIGH\_INT interrupt. (R/W)
- APB\_SARADC\_ADC\_DONE\_INT\_ENA Write 1 to enable the APB\_SARADC\_ADC\_DONE\_INT interrupt. (R/W)

## Register 39.13. APB\_SARADC\_INT\_RAW\_REG (0x0044)

![Image](images/39_Chapter_39_img025_a0c8a971.png)

APB\_SARADC\_TSENS\_INT\_RAW The raw interrupt status of the APB\_SARADC\_TSENS\_INT interrupt. (R/WTC/SS) APB\_SARADC\_THRES1\_LOW\_INT\_RAW The raw interrupt status of the APB\_SARADC\_THRES1\_LOW\_INT interrupt. (R/WTC/SS) APB\_SARADC\_THRES0\_LOW\_INT\_RAW The raw interrupt status of the APB\_SARADC\_THRES0\_LOW\_INT interrupt. (R/WTC/SS) APB\_SARADC\_THRES1\_HIGH\_INT\_RAW The raw interrupt status of the APB\_SARADC\_THRES1\_HIGH\_INT interrupt. (R/WTC/SS) APB\_SARADC\_THRES0\_HIGH\_INT\_RAW The raw interrupt status of the APB\_SARADC\_THRES0\_HIGH\_INT interrupt. (R/WTC/SS) APB\_SARADC\_ADC\_DONE\_INT\_RAW The raw interrupt status of the

APB\_SARADC\_ADC\_DONE\_INT interrupt. (R/WTC/SS)

## Register 39.14. APB\_SARADC\_INT\_ST\_REG (0x0048)

![Image](images/39_Chapter_39_img026_92227066.png)

APB\_SARADC\_TSENS\_INT\_ST The masked interrupt status of the APB\_SARADC\_TSENS\_INT interrupt. (RO)

APB\_SARADC\_THRES1\_LOW\_INT\_ST The masked interrupt status of the

APB\_SARADC\_THRES1\_LOW\_INT interrupt. (RO)

APB\_SARADC\_THRES0\_LOW\_INT\_ST The masked interrupt status of the

APB\_SARADC\_THRES0\_LOW\_INT interrupt. (RO)

APB\_SARADC\_THRES1\_HIGH\_INT\_ST The masked interrupt status of the

APB\_SARADC\_THRES1\_HIGH\_INT interrupt. (RO)

APB\_SARADC\_THRES0\_HIGH\_INT\_ST The masked interrupt status of the

APB\_SARADC\_THRES0\_HIGH\_INT interrupt. (RO)

APB\_SARADC\_ADC\_DONE\_INT\_ST The masked interrupt status of the APB\_SARADC\_ADC\_DONE\_INT interrupt. (RO)

## Register 39.15. APB\_SARADC\_INT\_CLR\_REG (0x004C)

![Image](images/39_Chapter_39_img027_36b843c7.png)

APB\_SARADC\_TSENS\_INT\_CLR Write 1 to clear the APB\_SARADC\_TSENS\_INT interrupt. (WT)

- APB\_SARADC\_THRES1\_LOW\_INT\_CLR Write 1 to clear the APB\_SARADC\_THRES1\_LOW\_INT interrupt. (WT)
- APB\_SARADC\_THRES0\_LOW\_INT\_CLR Write 1 to clear the APB\_SARADC\_THRES0\_LOW\_INT interrupt. (WT)
- APB\_SARADC\_THRES1\_HIGH\_INT\_CLR Write 1 to clear the APB\_SARADC\_THRES1\_HIGH\_INT interrupt. (WT)
- APB\_SARADC\_THRES0\_HIGH\_INT\_CLR Write 1 to clear the APB\_SARADC\_THRES0\_HIGH\_INT interrupt. (WT)
- APB\_SARADC\_ADC\_DONE\_INT\_CLR Write 1 to clear the APB\_SARADC\_ADC\_DONE\_INT interrupt. (WT)

## Register 39.16. APB\_SARADC\_DMA\_CONF\_REG (0x0050)

![Image](images/39_Chapter_39_img028_c5a84cc5.png)

APB\_SARADC\_APB\_ADC\_EOF\_NUM Configures whether to enable generating dma\_in\_suc\_eof when sample cnt = eof\_num.

- 0: No effect
- 1: Generate

(R/W)

- APB\_SARADC\_APB\_ADC\_RESET\_FSM Configures whether to reset DIG ADC controller status.
- 0: No effect
- 1: Reset

(R/W)

APB\_SARADC\_APB\_ADC\_TRANS Configures whether to let DIG ADC controller use DMA.

- 0: No effect
- 1: DIG ADC controller uses DMA

(R/W)

## Register 39.17. APB\_SARADC\_APB\_TSENS\_CTRL\_REG (0x0058)

![Image](images/39_Chapter_39_img029_296df06b.png)

APB\_SARADC\_TSENS\_OUT Represents temperature sensor data out. (RO)

APB\_SARADC\_TSENS\_IN\_INV Configures whether to invert temperature sensor data.

0: No effect

1: Invert

(R/W)

APB\_SARADC\_TSENS\_CLK\_DIV Configures temperature sensor clock divider. (R/W)

APB\_SARADC\_TSENS\_PU Configures whether to power up temperature sensor.

0: No effect

1: Power up

(R/W)

## Register 39.18. APB\_SARADC\_TSENS\_CTRL2\_REG (0x005C)

![Image](images/39_Chapter_39_img030_c661dec4.png)

APB\_SARADC\_TSENS\_CLK\_SEL Configures the working clock for temperature sensor.

<!-- formula-not-decoded -->

1: XTAL\_CLK

(R/W)

APB\_SARADC\_TSENS\_CLK\_INV Configures the phase of sensor sample clock. (R/W)

APB\_SARADC\_TSENS\_XPD\_FORCE Configures whether to enable force power up/down the tem- perature sensor.

0/1: Disable force power up/down function

2: Enable force power up temperature sensor

3: Enable force power down temperature sensor

(R/W)

APB\_SARADC\_TSENS\_XPD\_WAIT Configure the wait time for analog circuit build up. (R/W)

## Register 39.19. APB\_SARADC\_CALI\_REG (0x0060)

![Image](images/39_Chapter_39_img031_5c99a141.png)

APB\_SARADC\_CALI\_CFG Configures the SAR ADC calibration factor. (R/W)

## Register 39.20. APB\_TSENS\_WAKE\_REG (0x0064)

![Image](images/39_Chapter_39_img032_43dc1e81.png)

- APB\_SARADC\_WAKEUP\_TH\_LOW Configures the low threshold for temperature sensor wake-up function. (R/W)
- APB\_SARADC\_WAKEUP\_TH\_HIGH Configures the high threshold for temperature sensor wake-up function. (R/W)
- APB\_SARADC\_WAKEUP\_OVER\_UPPER\_TH Represents whether the temperature value exceeds the threshold.
- 0: The temperature value is below the low threshold
- 1: The temperature value is above the high threshold

(RO)

- APB\_SARADC\_WAKEUP\_MODE Configures the wake-up mode for temperature sensor.
- 0: Absolute value mode
- 1: Incremental value mode

(R/W)

- APB\_SARADC\_WAKEUP\_EN Configures whether to enable wake-up.
- 0: Disable
- 1: Enable

(R/W)

## Register 39.21. APB\_TSENS\_SAMPLE\_REG (0x0068)

![Image](images/39_Chapter_39_img033_500315c0.png)

APB\_SARADC\_TSENS\_SAMPLE\_RATE Configures the hardware sampling rate. (R/W)

APB\_SARADC\_TSENS\_SAMPLE\_EN Configures whether to enable hardware sampling.

0: Disable

1: Enable

(R/W)

## Register 39.22. APB\_SARADC\_CTRL\_DATE\_REG (0x03FC)

![Image](images/39_Chapter_39_img034_7836fc5a.png)

APB\_SARADC\_DATE Version control register. (R/W)

## Part VII Appendix

This part contains the following information starting from the next page:

- Related Documentation and Resources
- Glossary
- Programming Reserved Register Field
- Interrupt Configuration Registers
- Revision History

## Related Documentation and Resources

## Related Documentation

- ESP32-C6 Series Datasheet – Specifications of the ESP32-C6 hardware.
- ESP32-C6 Hardware Design Guidelines – Guidelines on how to integrate the ESP32-C6 into your hardware product.
- Certificates https://espressif.com/en/support/documents/certificates
- ESP32-C6 Product/Process Change Notifications (PCN) https://espressif.com/en/support/documents/pcns?keys=ESP32-C6
- Documentation Updates and Update Notification Subscription https://espressif.com/en/support/download/documents

## Developer Zone

- ESP-IDF Programming Guide for ESP32-C6 – Extensive documentation for the ESP-IDF development framework.
- ESP-IDF and other development frameworks on GitHub.
- https://github.com/espressif
- ESP32 BBS Forum – Engineer-to-Engineer (E2E) Community for Espressif products where you can post questions, share knowledge, explore ideas, and help solve problems with fellow engineers. https://esp32.com/
- The ESP Journal – Best Practices, Articles, and Notes from Espressif folks. https://blog.espressif.com/
- See the tabs SDKs and Demos , Apps , Tools , AT Firmware . https://espressif.com/en/support/download/sdks-demos

## Products

- ESP32-C6 Series SoCs – Browse through all ESP32-C6 SoCs. https://espressif.com/en/products/socs?id=ESP32-C6
- ESP32-C6 Series Modules – Browse through all ESP32-C6-based modules. https://espressif.com/en/products/modules?id=ESP32-C6
- ESP32-C6 Series DevKits – Browse through all ESP32-C6-based devkits. https://espressif.com/en/products/devkits?id=ESP32-C6
- ESP Product Selector – Find an Espressif hardware product suitable for your needs by comparing or applying filters. https://products.espressif.com/#/product-selector?language=en

## Contact Us

•

See the tabs Sales Questions

,

Technical Enquiries

,

Circuit Schematic &amp; PCB Design Review

(Online stores), Become Our Supplier

,

Comments &amp; Suggestions https://espressif.com/en/contact-us/sales-questions

.

,

Get Samples

## Glossary

## Abbreviations for Peripherals

AES AES (Advanced Encryption Standard) Accelerator

DS Digital Signature

DMA DMA (Direct Memory Access) Controller

ECC ECC (Elliptic Curve Cryptography) Accelerator

eFuse eFuse Controller

ETM Event Task Matrix

HMAC HMAC (Hash-based Message Authentication Code) Accelerator

HP CPU High-Performance CPU

I2C I2C (Inter-Integrated Circuit) Controller

I2S I2S (Inter-IC Sound) Controller

LEDC LED PWM (Pulse Width Modulation) Controller

LP CPU Low-Power CPU

MCPWM Motor Control PWM (Pulse Width Modulation)

PARLIO Parallel IO Controller

PCNT Pulse Count Controller

RMT Remote Control Peripheral

RNG Random Number Generator

RSA RSA (Rivest Shamir Adleman) Accelerator

SDIO SDIO 2.0 Slave Controller

SHA SHA (Secure Hash Algorithm) Accelerator

SPI SPI (Serial Peripheral Interface) Controller

SYSTIMER System Timer

TIMG Timer Group

TWAI Two-wire Automotive Interface

UART UART (Universal Asynchronous Receiver-Transmitter) Controller

WDT Watchdog Timers

## Abbreviations Related to Registers

SYSREG

REG Register .

System registers are a group of registers that control system reset, memory,

clocks, software interrupts, power management, clock gating, etc.

ISO Isolation. If a peripheral or other chip component is powered down, the pins, if any, to which its output signals are routed will go into a floating state. ISO registers isolate such pins and keep them at a certain determined value, so that the other non-powered-down peripherals/devices attached to these pins are not affected.

NMI Non-maskable interrupt is a hardware interrupt that cannot be disabled or ig- nored by the CPU instructions. Such interrupts exist to signal the occurrence of a critical error.

- W1TS Abbreviation added to names of registers/fields to indicate that such register/field should be used to set a field in a corresponding register with a similar name. For example, the register GPIO\_ENABLE\_W1TS\_REG should be used to set the corresponding fields in the register GPIO\_ENABLE\_REG .
- W1TC Same as W1TS, but used to clear a field in a corresponding register.

## Access Types for Registers

Sections Register Summary and Register Description in TRM chapters specify access types for registers and their fields.

Most frequently used access types and their combinations are as follows:

- RO

•

WO

- WT
- R/W
- R/W1
- WL
- R/W/SC
- R/W/SS
- R/W/SS/SC
- R/WC/SS
- R/WC/SC
- R/WC/SS/SC
- R/WS/SC
- R/WS/SS

Descriptions of all access types are provided below.

- R Read. User application can read from this register/field; usually combined with other access types.
- RO Read only. User application can only read from this register/field.
- HRO Hardware Read Only. Only hardware can read from this register/field; used for storing default settings for variable parameters.
- W Write. User application can write to this register/field; usually combined with other access types.
- WO Write only. User application can only write to this register/field.
- W1 Write Once. User application can write to this register/field only once; only allowed to write 1; writing 0 is invalid.
- SS Self set. On a specified event, hardware automatically writes 1 to this register/field; used with 1-bit fields.
- SC Self clear. On a specified event, hardware automatically writes 0 to this register/field; used with 1-bit and multi-bit fields.
- SM Self modify. On a specified event, hardware automatically writes a specified value to this register/field; used with multi-bit fields.
- SU Self update. On a specified event, hardware automatically updates this register/field; used with multi-bit fields.
- RS Read to set. If user application reads from this register/field, hardware automatically writes 1 to it.
- RC Read to clear. If user application reads from this register/field, hardware automatically writes 0 to it.
- RF Read from FIFO. If user application writes new data to FIFO, the register/field automatically reads it.
- WF Write to FIFO. If user application writes new data to this register/field, it automatically passes the data to FIFO via APB bus.
- WS Write any value to set. If user application writes to this register/field, hardware automatically sets this register/field.
- R/WS/SS/SC
- R/SS/WTC
- R/SC/WTC
- R/SS/SC/WTC
- RF/WF
- R/SS/RC
- varies

- W1S Write 1 to set. If user application writes 1 to this register/field, hardware automatically sets this register/field.
- W0S Write 0 to set. If user application writes 0 to this register/field, hardware automatically sets this register/field.
- WC Write any value to clear. If user application writes to this register/field, hardware automatically clears this register/field.
- W1C Write 1 to clear. If user application writes 1 to this register/field, hardware automatically clears this register/field.
- W0C Write 0 to clear. If user application writes 0 to this register/field, hardware automatically clears this register/field.
- WT Write 1 to trigger an event. If user application writes 1 to this field, this action triggers an event (pulse in the APB bus) or clears a corresponding WTC field (see WTC).
- WTC Write to clear. Hardware automatically clears this field if user application writes 1 to the corresponding WT field (see WT).
- W1T Write 1 to toggle. If user application writes 1 to this field, hardware automatically inverts the corresponding field; otherwise - no effect.
- W0T Write 0 to toggle. If user application writes 0 to this field, hardware automatically inverts the corresponding field; otherwise - no effect.
- WL Write if a lock is deactivated. If the lock is deactivated, user application can write to this register/field.
- varies The access type varies. Different fields of this register might have different access types.

## Programming Reserved Register Field

## Introduction

A field in a register is reserved if the field is not open to users, or produces unpredictable results if configured to values other than defaults.

## Programming Reserved Register Field

The reserved fields should not be modified. It is not possible to write only part of a register since registers must always be written as a whole. As a result, to write an entire register that contains reserved fields, you can choose one of the following two options:

1. Read the value of the register, modify only the fields you want to configure and then write back the value so that reserved fields are untouched.

OR

2. Modify only the fields you want to configure and write back the default value of the reserved fields. The default value of a field is provided in the "Reset" line of a register diagram. For example, the default value of Field\_A in Register X is 1.

Register 39.23. Register X (Address)

![Image](images/39_Chapter_39_img035_06fac1d8.png)

Suppose you want to set Field\_A, Field\_B, and Field\_C of Register X to 0x0, 0x1, and 0x2, you can:

- Use option 1 and fill in the reserved fields with the value you have just read. Suppose the register reads as 0x0000\_0003. Then, you can modify the fields you want to configure, thus writing 0x0002\_0002 to the register.
- Use option 2 and fill in the reserved fields with their defaults, thus writing 0x0002\_0002 to the register.

![Image](images/39_Chapter_39_img036_11fb7f44.png)

## Interrupt Configuration Registers

Generally, the peripherals' internal interrupt sources can be configured by the following common set of registers:

- RAW (Raw Interrupt Status) register: This register indicates the raw interrupt status. Each bit in the register represents a specific internal interrupt source. When an interrupt source triggers, its RAW bit is set to 1.
- ENA (Enable) register: This register is used to enable or disable the internal interrupt sources. Each bit in the ENA register corresponds to an internal interrupt source.

By manipulating the ENA register, you can mask or unmask individual internal interrupt source as needed. When an internal interrupt source is masked (disabled), it will not generate an interrupt signal, but its value can still be read from the RAW register.

- ST (Status) register: This register reflects the status of enabled interrupt sources. Each bit in the ST register corresponds to a specific internal interrupt source. The ST bit being 1 means that both the corresponding RAW bit and ENA bit are 1, indicating that the interrupt source is triggered and not masked. The other combinations of the RAW bit and ENA bit will result in the ST bit being 0.

The configuration of ENA/RAW/ST registers is shown in Table 39.7-4 .

- CLR (Clear) register: The CLR register is responsible for clearing the internal interrupt sources. Writing 1 to the corresponding bit in the CLR register clears the interrupt source.

Table 39.7-4. Configuration of ENA/RAW/ST Registers

|   ENA Bit Value | RAW Bit Value   |   ST Bit Value |
|-----------------|-----------------|----------------|
|               0 | Ignored         |              0 |
|               1 | 0               |              0 |
|               1 | 1               |              1 |

## Revision History

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      |
|------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2025-06-18 | v1.1      | Updated the following chapters: •  Chapter 4  GDMA Controller (GDMA): Added descriptions for the GDMA_OUTFIFO_OVF_CHn_INT,  GDMA_OUTFIFO_UDF_CHn_INT, GDMA_INFIFO_OVF_CHn_INT, and GDMA_INFIFO_UDF_CHn_INT in terrupts •  Chapter 8  Reset and Clock: Removed RC32K_CLK according to AR2024-011 Bug Advisory Concerning the Removal of RC32K_CLK in ESP32-C6 Series Products; Updated the description of the RC_SCL_CLK clock •  Chapter 10 Interrupt Matrix (INTMTX): Removed the CACHE_INTR inter rupt source •  Chapter 12 Low-Power Management: Fixed a typo in Table 12.4- 1  to indicate that LP CPU is a wake-up source in Deep-sleep; Removed RC32K_CLK according to  AR2024-011  Bug  Advisory Concerning  the  Removal  of  RC32K_CLK  in  ESP32-C6  Series Products; Added the description of RTC_EVT_TICK; Added the description of registers  PMU_LP_CPU_SLP_STALL_WAIT , LP_AON_FORCE_DOWNLOAD_BOOT ,  LP_AON_GPIO_MUX_REG , LP_AON_GPIO_HOLD0_REG ,  LP_AON_LPBUS_REG ,  and PMU_IMM_PAD_HOLD_ALL_REG •  Chapter 20 ECC Accelerator (ECC): Updated register field prefix from ECC to ECC_MULT •  Chapter 27 UART Controller (UART, LP_UART, UHCI): Updated FIFO-related descriptions to clarify the RAM size and FIFO usage of the transmitter and the receiver; add clarification about writing UART_RXFIFO_RD_BYTE •  Chapter 39 On-Chip Sensor and Analog Signal Processing: Corrected “- 0.5” to “+0.5” in the ADC filter formula; Added descriptions of ETM tasks for the temperature sensor |
| 2024-06-24 | v1.0      | Added the following chapter: •  Chapter 12 Low-Power Management Updated the following chapters: •  Chapter 3 Low-Power CPU: Updated descriptions of the mie and mip reg isters; LP Timer was updated to RTC Timer •  Chapter 8 Reset and Clock: Added information of PMU controlled clock gating •  Chapter 28 SPI Controller (SPI): Updated the supported input clock fre quencies when GP-SPI2 works as a slave •  Updated “LP Timer” to “RTC Timer” globally                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |

Cont’d on next page

## Cont’d from previous page

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|------------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2024-05-10 | v0.4      | Updated the following chapters: •  Chapter 3 Low-Power CPU: Updated a few PMU register names •  Chapter 4 GDMA Controller (GDMA): Updated the descriptions of suc_eof and the EOF flag •  Chapter 5 System and Memory: Added the base address of External Memory Encryption and Decryption in Table 5.3-2; updated the word ing in Section 5.3.2 •  Chapter  6  eFuse Controller: Updated the location of the EFUSE_CRYPT_DPA_ENABLE field •  Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX): Updated the descrip tion in Section 7.9, and deleted the GPIO_PCPU_NMI_INT_REG register and related information •  Chapter 8 Reset and Clock: Added a note in Section 8.3.3; Updated the description to LP_CLKRST_SLOW_CLK_SEL; Added descriptions of the PCR_FOSC_TICK_NUM field •  Chapter 10 Interrupt Matrix (INTMTX): Removed the TG0_T1_INTR and TG1_T1_INTR interrupt sources, which do not exist; Deleted the INTMTX_CORE0_GPIO_INTERRUPT_PRO_NMI_MAP_REG register and related information; removed the PAU_INTR interrupt source •  Chapter 11 Event Task Matrix (SOC_ETM): Changed the peripheral that supports Event Task Matrix from RTC Watchdog Timer to RTC Timer •  Chapter 27 UART Controller (UART, LP_UART, UHCI): Updated the de scriptions about RAM size and the number of rising edges required to generate the wake_up signal, and the clock sources for LP_UART in Ta ble 27.2-1 •  Chapter 35 LED PWM Controller (LEDC): Updated the RC_FAST_CLK fre quency and lowest resolution in Table 35.3-1 •  Chapter 38 Parallel IO Controller (PARL_IO): Updated the example in Sec tion 38.7.3 Co-working with LCD Added Section Interrupt Configuration Registers |

Cont’d on next page

## Cont’d from previous page

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|------------|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2023-06-07 | v0.3      | Added the following chapter: •  Chapter 3 Low-Power CPU Updated the following chapters: •  Chapter 1 High-Performance CPU: Fixed interrupt IDs •  Chapter 6  eFuse Controller: Updated the description of register EFUSE_SEC_DPA_LEVEL •  Chapter 8 Reset and Clock: Updated the description to Reset fields in Section 8.4.1 PCR Registers •  Chapter 10 Interrupt Matrix (INTMTX): Added the LP_PERI_TIMEOUT_INTR interrupt source •  Chapter 16 Permission Control (PMS)fiadded 16.1-1, and updated relevant descriptions •  Chapter 28 SPI Controller (SPI)fiUpdated clock information •  Chapter 39 On-Chip Sensor and Analog Signal Processing: Updated Sec tion 39.4 Event Task Matrix Feature Added Section Programming Reserved Register Field |

Cont’d on next page

## Cont’d from previous page

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               |
|------------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2023-04-20 | v0.2      | Added the following chapters: •  Chapter 1 High-Performance CPU •  Chapter 2 RISC-V Trace Encoder (TRACE) •  Chapter 34 SDIO Slave Controller (SDIO) •  Chapter 38 Parallel IO Controller (PARL_IO) Updated the following chapters: •  Chapter  4  GDMA Controller (GDMA): Updated the descrip tions of the GDMA_IN_SUC_EOF_CHn_INT interrupt and the GDMA_INLINK_DSCR_ADDR_CHn field •  Chapter 6 eFuse Controller: Added a note on programming the XTS-AES key •  Chapter 8 Reset and Clock: Changed RC_FAST_CLK to 17.5 MHz, and changed RC_SLOW_CLK to 136 kHZ •  Chapter 10 Interrupt Matrix (INTMTX): Updated the names for several reg isters •  Chapter 11 Event Task Matrix (SOC_ETM): Updated the complete proce dure to configure ETM channels •  Chapter  18  Debug Assistant (ASSIST_DEBUG): Added two registers,  ASSIST_DEBUG_CLOCK_GATE_REG and MEM_MONITOR_CLOCK_GATE_REG; Updated Table 18.4-5 •  Chapter 22 RSA Accelerator (RSA) ,  23 SHA Accelerator (SHA), and 19 AES Accelerator (AES): Updated the register to enable the accelerators •  Chapter 27 UART Controller (UART, LP_UART, UHCI): Updated the maxi mum length of stop bits and related descriptions •  Chapter 39 On-Chip Sensor and Analog Signal Processing: Updated the pattern table indexes in Figure 39.2-3 and Figure 39.2-4 Updated abbreviations for peripherals and added “varies” as an access type for registers in the Glossary section |
| 2023-01-13 | v0.1      | Preliminary release                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |

![Image](images/39_Chapter_39_img037_7a7483de.png)

## Disclaimer and Copyright Notice

Information in this document, including URL references, is subject to change without notice.

ALL THIRD PARTY'S INFORMATION IN THIS DOCUMENT IS PROVIDED AS IS WITH NO WARRANTIES TO ITS AUTHENTICITY AND ACCURACY.

NO WARRANTY IS PROVIDED TO THIS DOCUMENT FOR ITS MERCHANTABILITY, NON-INFRINGEMENT, FITNESS FOR ANY PARTICULAR PURPOSE, NOR DOES ANY WARRANTY OTHERWISE ARISING OUT OF ANY PROPOSAL, SPECIFICATION OR SAMPLE.

All liability, including liability for infringement of any proprietary rights, relating to use of information in this document is disclaimed. No licenses express or implied, by estoppel or otherwise, to any intellectual property rights are granted herein.

The Wi-Fi Alliance Member logo is a trademark of the Wi-Fi Alliance. The Bluetooth logo is a registered trademark of Bluetooth SIG.

All trade names, trademarks and registered trademarks mentioned in this document are property of their respective owners, and are hereby acknowledged.

Copyright © 2025 Espressif Systems (Shanghai) Co., Ltd. All rights reserved.

www.espressif.com