---
chapter: 34
title: "Chapter 34"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 34

## On-Chip Sensor and Analog Signal Processing

## 34.1 Overview

ESP32-C3 provides the following on-chip sensor and analog signal processing peripherals:

- Two 12-bit Successive Approximation ADCs (SAR ADCs): SAR ADC1 and SAR ADC2, for measuring analog signals from six channels.
- One temperature sensor for measuring the internal temperature of the ESP32-C3 chip.

## 34.2 SAR ADCs

## 34.2.1 Overview

ESP32-C3 integrates two 12-bit SAR ADCs, which are able to measure analog signals from up to six pins. The SAR ADCs are managed by two dedicated controllers:

- DIG ADC controller: drives Digital\_Reader0 and Digital\_Reader1 to sample channel voltages of SAR ADC1 and SAR ADC2, respectively. This DIG ADC controller supports high-performance multi-channel scanning and DMA continuous conversion.
- PWDET controller: monitors RF power. Note this controller is only for RF internal use.

## Note:

The DIG ADC controller of SAR ADC2 for ESP32-C3 does not work properly and it is suggested to use SAR ADC1. For more information, please refer to ESP32-C3 Series SoC Errata .

## 34.2.2 Features

- Each SAR ADC has its own ADC Reader module (Digital\_Reader0 or Digital\_Reader1), which can be configured and operated separately.
- Support 12-bit sampling resolution
- Support sampling the analog voltages from up to six pins
- DIG ADC controller:
- – Provides separate control modules for one-time sampling and multi-channel scanning.
- – One-time sampling and multi-channel scanning can be run independently on each ADC.
- – Channel scanning sequence in multi-channel scanning mode is user-defined.

- – Provides two filters with configurable filter coefficient.
- – Supports threshold monitoring. An interrupt will be triggered when the sampled value is greater than the pre-set high threshold or less than the pre-set low threshold.
- – Supports DMA
- PWDET controller: monitors RF power (for internal use only)

## 34.2.3 Functional Description

The major components of SAR ADCs and their interconnections are shown in Figure 34.2-1 .

![Image](images/34_Chapter_34_img001_f37100d4.png)

—

: data flow; —: clock signal; —: ADC control signal

Figure 34.2-1. SAR ADCs Function Overview

As shown in Figure 34.2-1, the SAR ADC module consists of the following components:

- SAR ADC1: measures voltages from up to five channels.
- SAR ADC2: measures the voltage from one channel.
- Clock management: selects clock sources and their dividers:
- – Clock sources: can be APB\_CLK or PLL\_240.
- – Divided Clocks:
* SAR\_CLK: operating clock for SAR ADC1, SAR ADC2, Digital\_Reader0, and Digital\_Reader1. Note that the divider (sar\_div) of SAR\_ADC must be no less than 2.
* ADC\_CTRL\_CLK: operating clock for DIG ADC FSM.

- Arbiter: this arbiter determines which controller is selected as the ADC2's working controller, DIG ADC controller or PWDET controller.
- Digital\_Reader0 (driven by DIG ADC FSM): reads data from SAR ADC1.
- Digital\_Reader1 (driven by DIG ADC FSM): reads data from SAR ADC2.
- DIG ADC FSM: generates the signals required throughout the ADC sampling process.
- Threshold monitorx: threshold monitor 1 and threshold monitor 2. The monitorx will trigger a interrupt when the sampled value is greater than the pre-set high threshold or less than the pre-set low threshold.

The following sections describe the individual components in details.

## 34.2.3.1 Input Signals

In order to sample an analog signal, an SAR ADC must first select the analog pin to measure via an internal multiplexer. A summary of all the analog signals that may be sent to the SAR ADC module for processing by either ADC1 or ADC2 are presented in Table 34.2-1 .

Table 34.2-1. SAR ADC Input Signals

| Signal   |   Channel | ADC Selection   |
|----------|-----------|-----------------|
| GPIO0    |         0 | SAR ADC1        |
| GPIO1    |         1 | SAR ADC1        |
| GPIO2    |         2 | SAR ADC1        |
| GPIO3    |         3 | SAR ADC1        |
| GPIO4    |         4 | SAR ADC1        |
| GPIO5    |         0 | SAR ADC2        |

## 34.2.3.2 ADC Conversion and Attenuation

When the SAR ADCs convert an analog voltage, the resolution (12-bit) of the conversion spans voltage range from 0 mV to Vr Vref . Vref is the SAR ADC's internal reference voltage (1100 mV by design). The output value of the conversion (data) is mapped to analog voltage Vdata using the following formula:

<!-- formula-not-decoded -->

In order to convert voltages larger than Vref , input signals can be attenuated before being input into the SAR ADCs. The attenuation can be configured to 0 dB, 2.5 dB, 6 dB, and 12 dB.

## 34.2.3.3 DIG ADC Controller

The clock of the DIG ADC controller is quite fast, thus the sample rate is high. For more information, see Section ADC Characteristics in ESP32-C3 Series Datasheet .

This controller supports:

- up to 12-bit sampling resolution
- software-triggered one-time sampling
- timer-triggered multi-channel scanning

The configuration of a one-time sampling triggered by the software is as follows:

- Select SAR ADC1 or SAR ADC2 to perform a one-time sampling:
- – if APB\_SARADC1\_ONETIME\_SAMPLE is set, SAR ADC1 is selected.
- – if APB\_SARADC2\_ONETIME\_SAMPLE is set, SAR ADC2 is selected.
- Configure APB\_SARADC\_ONETIME\_CHANNEL to select one channel to sample.
- Configure APB\_SARADC\_ONETIME\_ATTEN to set attenuation.
- Configure APB\_SARADC\_ONETIME\_START to start this one-time sampling.
- On completion of sampling, APB\_SARADC\_ADCx\_DONE\_INT\_RAW interrupt is generated. Software can use this interrupt to initiate reading of the sample values from APB\_SARADC\_ADCx\_DATA . x can be 1 or 2. 1: SAR ADC1; 2: SAR ADC2.

If the timer-triggered multi-channel scanning is selected, follow the configuration below. Note that in this mode, the scan sequence is performed according to the configuration entered into pattern table.

- Configure APB\_SARADC\_TIMER\_TARGET to set the trigger target for DIG ADC timer. When the timer counting reaches two times of the pre-configured cycle number, a sampling operation is triggered. For the working clock of the timer, see Section 34.2.3.4 .
- Configure APB\_SARADC\_TIMER\_EN to enable the timer.
- When the timer times out, it drives DIG ADC FSM to start sampling according to the pattern table;
- Sampled data is automatically stored in memory via DMA. An interrupt is triggered once the scan is completed.

## Note:

Any SAR ADC can not be configured to perform both one-time sampling and multi-channel scanning at the same time. Therefore, if a pattern table is configured to use any SAR ADC for multi-channel scanning, then this SAR ADC can not be configured to perform one-time sampling.

## 34.2.3.4 DIG ADC Clock

Two clocks can be used as the working clock of DIG ADC controller, depending on the configuration of APB\_SARADC\_CLK\_SEL:

- 1: Select the clock (ADC\_CTRL\_CLK) divided from PLL\_240.
- 0: Select APB\_CLK.

If ADC\_CTRL\_CLK is selected, users can configure the divider by APB\_SARADC\_CLKM\_DIV\_NUM. Note that due to speed limits of SAR ADCs, the operating clock of Digital\_Reader0, SAR ADC1, Digital\_Reader1, and SAR ADC2 is SAR\_CLK, the frequency of which affects the sampling precision. The lower the frequency, the higher the precision. SAR\_CLK is divided from ADC\_CTRL\_CLK. The divider coefficient is configured by APB\_SARADC\_SAR\_CLK\_DIV .

The ADC needs 25 SAR\_CLK clock cycles per sample, so the maximum sampling rate is limited by the SAR\_CLK frequency.

## 34.2.3.5 DMA Support

DIG ADC controller supports direct memory access via peripheral DMA, which is triggered by DIG ADC timer. Users can switch the DMA data path to DIG ADC by configuring APB\_SARADC\_APB\_ADC\_TRANS via software. For specific DMA configuration, please refer to Chapter 2 GDMA Controller (GDMA) .

## 34.2.3.6 DIG ADC FSM

## Overview

Figure 34.2-2 shows the diagram of DIG ADC FSM.

Figure 34.2-2. Diagram of DIG ADC FSM

![Image](images/34_Chapter_34_img002_647a837b.png)

## Wherein:

- Timer: a dedicated timer for DIG ADC controller, to generate a sample\_start signal.
- pr: the pointer to pattern table entries. FSM sends out corresponding signals based on the configuration of the pattern table entry that the pointer points to.

The execution process is as follows:

- Configure APB\_SARADC\_TIMER\_EN to enable the DIG ADC timer. The timeout event of this timer triggers an sample\_start signal. This signal drives the FSM module to start sampling.
- When the FSM module receives the sample\_start signal, it starts the following operations:
- – Power up SAR ADC.
- – Select SAR ADC1 or SAR ADC2 as the working ADC, configure the ADC channel and attenuation, based on the pattern table entry that the current pr points to.
- – According to the configuration information, output the corresponding en\_pad and atten signals to the analog side.
- – Initiate the sar\_start signal and start sampling.

- When the FSM receives the reader\_done signal from ADC Reader (Digital\_Reader0 or Digital\_Reader1), it will
- – stop sampling,
- – transfer the data to the filter, and then threshold monitor transfers the data to memory via DMA,
- – update the pattern table pointer pr and wait for the next sampling. Note that if the pointer pr is smaller than APB\_SARADC\_SAR\_PATT\_LEN (table\_length), then pr = pr + 1, otherwise, pr is cleared.

## Pattern Table

There is one pattern table in the controller, consisting of the APB\_SARADC\_SAR\_PATT\_TAB1\_REG and APB\_SARADC\_SAR\_PATT\_TAB2\_REG registers, see Figure 34.2-3 and Figure 34.2-4:

![Image](images/34_Chapter_34_img003_9d07577b.png)

cmd x represents pattern table entries. x here is the index, 0 ~ 3.

Figure 34.2-3. APB\_SARADC\_SAR\_PATT\_TAB1\_REG and Pattern Table Entry 0 - Entry 3

![Image](images/34_Chapter_34_img004_bffec6d0.png)

cmd x represents pattern table entries. x here is the index, 4 ~ 7.

Figure 34.2-4. APB\_SARADC\_SAR\_PATT\_TAB2\_REG and Pattern Table Entry 4 - Entry 7

Each register consists of four 6-bit pattern table entries. Each entry is composed of three fields that contain working ADC, ADC channel and attenuation information, as shown in Table 34.2-5 .

Figure 34.2-5. Pattern Table Entry

![Image](images/34_Chapter_34_img005_73a59450.png)

atten Attenuation. 0: 0 dB; 1: 2.5 dB; 2: 6 dB; 3: 12 dB.

ch\_sel ADC channel, see Table 34.2-1 .

sar\_sel Working ADC. 0: SAR ARC1; 1: SAR ADC2.

## Configuration of multi-channel scanning

In this example, two channels are selected for multi-channel scanning:

- Channel 2 of SAR ADC1, with the attenuation of 12 dB

- Channel 0 of SAR ADC2, with the attenuation of 2.5 dB

The detailed configuration is as follows:

- Configure the first pattern table entry (cmd0):

Figure 34.2-6. cmd0 Configuration

![Image](images/34_Chapter_34_img006_c333c8b3.png)

atten write the value of 3 to this field, to set the attenuation to 12 dB.

ch\_sel write the value of 2 to this field, to select channel 2 (see Table 34.2-1).

sar\_sel write the value of 0 to this bit, to select SAR ADC1 as the working ADC.

- Configure the second pattern table entry (cmd1):

Figure 34.2-7. cmd1 configuration

![Image](images/34_Chapter_34_img007_8d43a61d.png)

atten write the value of 1 to this field, to set the attenuation to 2.5 dB.

ch\_sel write the value of 0 to this field, to select channel 0 (see Table 34.2-1).

sar\_sel write the value of 1 to this bit, to select SAR ADC2 as the working ADC.

- Configure APB\_SARADC\_SAR\_PATT\_LEN to 1, i.e., set pattern table length to (this value + 1 = 2). Then pattern table entries cmd0 and cmd1 will be used.
- Enable the timer, then DIG ADC controller starts scanning the two channels in cycles, as configured in the pattern table entries.

## DMA Data Format

The ADC eventually passes 32-bit data to the DMA, see the figure below.

![Image](images/34_Chapter_34_img008_ce2957b4.png)

Figure 34.2-8. DMA Data Format

![Image](images/34_Chapter_34_img009_8c998268.png)

data SAR ADC read value, 12-bit

ch\_sel Channel, 3-bit

sar\_sel SAR ADC selection, 1-bit

## 34.2.3.7 ADC Filters

The DIG ADC controller provides two filters for automatic filtering of sampled ADC data. Both filters can be configured to any channel of either SAR ADC and then filter the sampled data for the target channel. The filter's formula is shown below:

<!-- formula-not-decoded -->

- data cur : the filtered data value.
- data in : the sampled data value from the ADC.
- data prev : the last filtered data value.
- k: the filter coefficient.

The filters are configured as follows:

- Configure APB\_SARADC\_FILTER\_CHANNELx to select the ADC channel for filter x;
- Configure APB\_SARADC\_FILTER\_FACTORx to set the coefficient for filter x;

Note that x is used here as the placeholder of filter index. 0: filter 0; 1: filter 1.

## 34.2.3.8 Threshold Monitoring

DIG ADC controller contains two threshold monitors that can be configured to monitor on any channel of SAR ADC1 and SAR ADC2. A high threshold interrupt is triggered when the ADC sample value is larger than the pre-configured high threshold, and a low threshold interrupt is triggered if the sample value is lower than the pre-configured low threshold.

The configuration of threshold monitoring is as follows:

- Set APB\_SARADC\_THRESx\_EN to enable threshold monitor x .
- Configure APB\_SARADC\_THRESx\_LOW to set a low threshold;
- Configure APB\_SARADC\_THRESx\_HIGH to set a high threshold;
- Configure APB\_SARADC\_THRESx\_CHANNEL to select the SAR ADC and the channel to monitor.

Note that x is used here as the placeholder of monitor index. 0: monitor 0; 1: monitor 1.

## 34.2.3.9 SAR ADC2 Arbiter

SAR ADC2 can be controlled by two controllers, namely, DIG ADC controller and PWDET controller. To avoid any possible conflicts and to improve the efficiency of SAR ADC2, ESP32-C3 provides an arbiter for SAR ADC2. The arbiter supports fair arbitration and fixed priority arbitration.

- Fair arbitration mode (cyclic priority arbitration) can be enabled by clearing APB\_SARADC\_ADC\_ARB\_FIX\_ PRIORITY .
- In fixed priority arbitration, users can set APB\_SARADC\_ADC\_ARB\_APB\_PRIORITY (for DIG ADC controller) and APB\_SARADC\_ADC\_ARB\_WIFI\_PRIORITY (for PWDET controller), to configure the priorities for these controllers. A larger value indicates a higher priority.

The arbiter ensures that a higher priority controller can always start a conversion (sample) when required, regardless of whether a lower priority controller already has a conversion in progress. If a higher priority controller starts a conversion whilst the ADC already has a conversion in progress from a lower priority controller, the conversion in progress will be interrupted (stopped). The higher priority controller will then start its conversion. A lower priority controller will not be able to start a conversion whilst the ADC has a conversion in progress from a higher priority controller.

Therefore, certain data flags are embedded into the output data value to indicate whether the conversion is valid or not.

- The data flag for DIG ADC controller is the {sar\_sel, ch\_sel} bits in DMA data, see Figure 34.2-8 .
- – 4'b1111: Conversion is interrupted.
- – 4'b1110: Conversion is not started.
- – Corresponding channel No.: The data is valid.
- The data flag for PWDET controller is the two higher bits of the sampling result.
- – 2'b10: Conversion is interrupted.
- – 2'b01: Conversion is not started.
- – 2'b00: The data is valid.

Users can configure APB\_SARADC\_ADC\_ARB\_GRANT\_FORCE to mask the arbiter, and set APB\_SARADC\_ADC\_ARB\_WIFI\_FORCE or APB\_SARADC\_ADC\_ARB\_APB\_FORCE to authorize corresponding controllers.

## 34.3 Temperature Sensor

## 34.3.1 Overview

ESP32-C3 provides a temperature sensor to monitor temperature changes inside the chip in real time.

## 34.3.2 Features

The temperature sensor has the following features:

- Supports software triggering and, once triggered, the data can be read continuously
- Configurable temperature offset based on the environment, to improve the accuracy
- Adjustable measurement range

## 34.3.3 Functional Description

The temperature sensor can be started by software as follows:

- Set APB\_SARADC\_TSENS\_PU to start XPD\_SAR, and then to enable temperature sensor;
- Set SYSTEM\_TSENS\_CLK\_EN to enable temperature sensor clock;
- Wait for APB\_SARADC\_TSENS\_XPD\_WAIT clock cycles till the reset of temperature sensor is released, the sensor starts measuring the temperature;

- Wait for a while and then read the data from APB\_SARADC\_TSENS\_OUT. The output value gradually approaches the actual temperature linearly as the measurement time increases.

The actual temperature (°C) can be obtained by converting the output of temperature sensor via the following formula:

<!-- formula-not-decoded -->

VALUE in the formula is the output of the temperature sensor, and the offset is determined by the temperature offset. The temperature offset varies in different actual environment (the temperature range). For details, refer to Table 34.3-1 .

Table 34.3-1. Temperature Offset

| Measurement Range (°C)   |   Temperature Offset (°C) |
|--------------------------|---------------------------|
| 50 ~ 125                 |                        -2 |
| 20 ~ 100                 |                        -1 |
| -10 ~ 80                 |                         0 |
| -30 ~ 50                 |                         1 |
| -40 ~ 20                 |                         2 |

## 34.4 Interrupts

- APB\_SARADC\_ADC1\_DONE\_INT: Triggered when SAR ADC1 completes one data conversion.
- APB\_SARADC\_ADC2\_DONE\_INT: Triggered when SAR ADC2 completes one data conversion.
- APB\_SARADC\_THRESx\_HIGH\_INT: Triggered when the sampling value is higher than the high threshold of monitor x .
- APB\_SARADC\_THRESx\_LOW\_INT: Triggered when the sampling value is lower than the low threshold of monitor x .

## 34.5 Register Summary

The addresses in this section are relative to the ADC controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                          | Description                                   | Address   | Access   |
|-------------------------------|-----------------------------------------------|-----------|----------|
| Configuration Registers       |                                               |           |          |
| APB_SARADC_CTRL_REG           | SAR ADC control register 1                    | 0x0000    | R/W      |
| APB_SARADC_CTRL2_REG          | SAR ADC control register 2                    | 0x0004    | R/W      |
| APB_SARADC_FILTER_CTRL1_REG   | Filtering control register 1                  | 0x0008    | R/W      |
| APB_SARADC_SAR_PATT_TAB1_REG  | Pattern table register 1                      | 0x0018    | R/W      |
| APB_SARADC_SAR_PATT_TAB2_REG  | Pattern table register 2                      | 0x001C    | R/W      |
| APB_SARADC_ONETIME_SAMPLE_REG | Configuration register for one time sampling | 0x0020    | R/W      |

| Name                             | Description                             | Address   | Access   |
|----------------------------------|-----------------------------------------|-----------|----------|
| APB_SARADC_APB_ADC_ARB_CTRL_REG  | SAR ADC2 arbiter configuration register | 0x0024    | R/W      |
| APB_SARADC_FILTER_CTRL0_REG      | Filtering control register 0            | 0x0028    | R/W      |
| APB_SARADC_1_DATA_STATUS_REG     | SAR ADC1 sampling data register         | 0x002C    | RO       |
| APB_SARADC_2_DATA_STATUS_REG     | SAR ADC2 sampling data register         | 0x0030    | RO       |
| APB_SARADC_THRES0_CTRL_REG       | Sampling threshold control regis ter 0 | 0x0034    | R/W      |
| APB_SARADC_THRES1_CTRL_REG       | Sampling threshold control regis ter 1 | 0x0038    | R/W      |
| APB_SARADC_THRES_CTRL_REG        | Sampling threshold control regis ter   | 0x003C    | R/W      |
| APB_SARADC_INT_ENA_REG           | Enable register of SAR ADC inter rupts | 0x0040    | R/W      |
| APB_SARADC_INT_RAW_REG           | Raw register of SAR ADC interrupts      | 0x0044    | RO       |
| APB_SARADC_INT_ST_REG            | State register of SAR ADC inter rupts  | 0x0048    | RO       |
| APB_SARADC_INT_CLR_REG           | Clear register of SAR ADC inter rupts  | 0x004C    | WO       |
| APB_SARADC_DMA_CONF_REG          | DMA configuration register for SAR ADC  | 0x0050    | R/W      |
| APB_SARADC_APB_ADC_CLKM_CONF_REG | SAR ADC clock control register          | 0x0054    | R/W      |
| APB_SARADC_APB_TSENS_CTRL_REG    | Temperature sensor control regis ter 1 | 0x0058    | varies   |
| APB_SARADC_APB_TSENS_CTRL2_REG   | Temperature sensor control regis ter 2 | 0x005C    | R/W      |
| APB_SARADC_CALI_REG              | SAR ADC calibration register            | 0x0060    | R/W      |
| APB_SARADC_APB_CTRL_DATE_REG     | Version control register                | 0x03FC    | R/W      |

## 34.6 Register

The addresses in this section are relative to the ADC controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 34.1. APB\_SARADC\_CTRL\_REG (0x0000)

![Image](images/34_Chapter_34_img010_6d984774.png)

APB\_SARADC\_START\_FORCE 0: select FSM to start SAR ADC. 1: select software to start SAR ADC. (R/W)

APB\_SARADC\_START Write 1 here to start the SAR ADC by software. Valid only when APB\_SARADC\_START\_FORCE = 1. (R/W)

APB\_SARADC\_SAR\_CLK\_GATED SAR ADC clock gate enable bit. (R/W)

APB\_SARADC\_SAR\_CLK\_DIV SAR ADC clock divider. This value should be no less than 2. (R/W)

APB\_SARADC\_SAR\_PATT\_LEN Configure how many pattern table entries will be used. If this field is set to 1, then pattern table entries (cmd0) and (cmd1) will be used. (R/W)

APB\_SARADC\_SAR\_PATT\_P\_CLEAR Clear the pointer of pattern table entry for DIG ADC controller. (R/W)

APB\_SARADC\_XPD\_SAR\_FORCE Force select XPD SAR. (R/W)

APB\_SARADC\_WAIT\_ARB\_CYCLE The clock cycles of waiting arbitration signal stable after SAR\_DONE. (R/W)

Register 34.2. APB\_SARADC\_CTRL2\_REG (0x0004)

![Image](images/34_Chapter_34_img011_1586e48d.png)

APB\_SARADC\_MEAS\_NUM\_LIMIT Enable the limitation of SAR ADCs maximum conversion times. (R/W)

APB\_SARADC\_MAX\_MEAS\_NUM The SAR ADCs maximum conversion times. (R/W)

APB\_SARADC\_SAR1\_INV Write 1 here to invert the data of SAR ADC1. (R/W)

APB\_SARADC\_SAR2\_INV Write 1 here to invert the data of SAR ADC2. (R/W)

APB\_SARADC\_TIMER\_TARGET Set SAR ADC timer target. (R/W)

APB\_SARADC\_TIMER\_EN Enable SAR ADC timer trigger. (R/W)

Register 34.3. APB\_SARADC\_FILTER\_CTRL1\_REG (0x0008)

![Image](images/34_Chapter_34_img012_8bf79dd3.png)

APB\_SARADC\_FILTER\_FACTOR1 The filter coefficient for SAR ADC filter 1. (R/W)

APB\_SARADC\_FILTER\_FACTOR0 The filter coefficient for SAR ADC filter 0. (R/W)

Register 34.4. APB\_SARADC\_SAR\_PATT\_TAB1\_REG (0x0018)

![Image](images/34_Chapter_34_img013_cdd59b54.png)

APB\_SARADC\_SAR\_PATT\_TAB1 Pattern table entries 0 ~ 3 (each entry is six bits). (R/W)

Register 34.5. APB\_SARADC\_SAR\_PATT\_TAB2\_REG (0x001C)

![Image](images/34_Chapter_34_img014_784d6f93.png)

APB\_SARADC\_SAR\_PATT\_TAB2 Pattern table entries 4 ~ 7 (each entry is six bits). (R/W)

Register 34.6. APB\_SARADC\_ONETIME\_SAMPLE\_REG (0x0020)

![Image](images/34_Chapter_34_img015_1d3e31e9.png)

APB\_SARADC\_ONETIME\_ATTEN Configure the attenuation for a one-time sampling. (R/W)

APB\_SARADC\_ONETIME\_CHANNEL Configure the channel for a one-time sampling. (R/W)

APB\_SARADC\_ONETIME\_START Start SAR ADC one-time sampling. (R/W)

APB\_SARADC2\_ONETIME\_SAMPLE Enable SAR ADC2 one-time sampling. (R/W)

APB\_SARADC1\_ONETIME\_SAMPLE Enable SAR ADC1 one-time sampling. (R/W)

Register 34.7. APB\_SARADC\_APB\_ADC\_ARB\_CTRL\_REG (0x0024)

![Image](images/34_Chapter_34_img016_fc7a16a7.png)

APB\_SARADC\_ADC\_ARB\_APB\_FORCE SAR ADC2 arbiter forces to enable DIG ADC controller. (R/W)

APB\_SARADC\_ADC\_ARB\_WIFI\_FORCE SAR ADC2 arbiter forces to enable PWDET controller. (R/W)

APB\_SARADC\_ADC\_ARB\_GRANT\_FORCE ADC2 arbiter force grant. (R/W)

APB\_SARADC\_ADC\_ARB\_APB\_PRIORITY Set DIG ADC controller priority. (R/W)

APB\_SARADC\_ADC\_ARB\_WIFI\_PRIORITY Set PWDET controller priority. (R/W)

APB\_SARADC\_ADC\_ARB\_FIX\_PRIORITY ADC2 arbiter uses fixed priority. (R/W)

## Register 34.8. APB\_SARADC\_FILTER\_CTRL0\_REG (0x0028)

![Image](images/34_Chapter_34_img017_7ffb966f.png)

APB\_SARADC\_FILTER\_CHANNEL1 The filter channel for SAR ADC filter 1. (R/W)

APB\_SARADC\_FILTER\_CHANNEL0 The filter channel for SAR ADC filter 0. (R/W)

APB\_SARADC\_FILTER\_RESET Reset SAR ADC1 filter. (R/W)

![Image](images/34_Chapter_34_img018_82dfa45d.png)

Register 34.9. APB\_SARADC\_1\_DATA\_STATUS\_REG (0x002C)

![Image](images/34_Chapter_34_img019_4ab7258b.png)

APB\_SARADC\_ADC1\_DATA SAR ADC1 conversion data. (RO)

Register 34.10. APB\_SARADC\_2\_DATA\_STATUS\_REG (0x0030)

![Image](images/34_Chapter_34_img020_87807036.png)

APB\_SARADC\_ADC2\_DATA SAR ADC2 conversion data. (RO)

Register 34.11. APB\_SARADC\_THRES0\_CTRL\_REG (0x0034)

![Image](images/34_Chapter_34_img021_5eeda485.png)

APB\_SARADC\_THRES0\_CHANNEL The channel for SAR ADC monitor 0. (R/W)

APB\_SARADC\_THRES0\_HIGH The high threshold for SAR ADC monitor 0. (R/W)

APB\_SARADC\_THRES0\_LOW The low threshold for SAR ADC monitor 0. (R/W)

## Register 34.12. APB\_SARADC\_THRES1\_CTRL\_REG (0x0038)

![Image](images/34_Chapter_34_img022_f3618e9b.png)

APB\_SARADC\_THRES1\_CHANNEL The channel for SAR ADC monitor 1. (R/W)

APB\_SARADC\_THRES1\_HIGH The high threshold for SAR ADC monitor 1. (R/W)

APB\_SARADC\_THRES1\_LOW The low threshold for SAR ADC monitor 1. (R/W)

## Register 34.13. APB\_SARADC\_THRES\_CTRL\_REG (0x003C)

![Image](images/34_Chapter_34_img023_1fa6c503.png)

APB\_SARADC\_THRES\_ALL\_EN Enable the threshold monitoring for all configured channels. (R/W)

APB\_SARADC\_THRES1\_EN Enable threshold monitor 1. (R/W)

APB\_SARADC\_THRES0\_EN Enable threshold monitor 0. (R/W)

## Register 34.14. APB\_SARADC\_INT\_ENA\_REG (0x0040)

![Image](images/34_Chapter_34_img024_da85490a.png)

APB\_SARADC\_THRES1\_LOW\_INT\_ENA Enable bit of APB\_SARADC\_THRES1\_LOW\_INT interrupt. (R/W) APB\_SARADC\_THRES0\_LOW\_INT\_ENA Enable bit of APB\_SARADC\_THRES0\_LOW\_INT interrupt. (R/W) APB\_SARADC\_THRES1\_HIGH\_INT\_ENA Enable bit of APB\_SARADC\_THRES1\_HIGH\_INT interrupt. (R/W) APB\_SARADC\_THRES0\_HIGH\_INT\_ENA Enable bit of APB\_SARADC\_THRES0\_HIGH\_INT interrupt. (R/W) APB\_SARADC\_ADC2\_DONE\_INT\_ENA Enable bit of APB\_SARADC\_ADC2\_DONE\_INT interrupt. (R/W) APB\_SARADC\_ADC1\_DONE\_INT\_ENA Enable bit of APB\_SARADC\_ADC1\_DONE\_INT interrupt. (R/W)

## Register 34.15. APB\_SARADC\_INT\_RAW\_REG (0x0044)

![Image](images/34_Chapter_34_img025_aef4d3f4.png)

APB\_SARADC\_THRES1\_LOW\_INT\_RAW Raw bit of APB\_SARADC\_THRES1\_LOW\_INT interrupt. (RO)

- APB\_SARADC\_THRES0\_LOW\_INT\_RAW Raw bit of APB\_SARADC\_THRES0\_LOW\_INT interrupt. (RO)
- APB\_SARADC\_THRES1\_HIGH\_INT\_RAW Raw bit of APB\_SARADC\_THRES1\_HIGH\_INT interrupt. (RO)
- APB\_SARADC\_THRES0\_HIGH\_INT\_RAW Raw bit of APB\_SARADC\_THRES0\_HIGH\_INT interrupt. (RO)
- APB\_SARADC\_ADC2\_DONE\_INT\_RAW Raw bit of APB\_SARADC\_ADC2\_DONE\_INT interrupt. (RO)

APB\_SARADC\_ADC1\_DONE\_INT\_RAW Raw bit of APB\_SARADC\_ADC1\_DONE\_INT interrupt. (RO)

![Image](images/34_Chapter_34_img026_084e5195.png)

APB\_SARADC\_THRES1\_LOW\_INT\_ST

Status of APB\_SARADC\_THRES1\_LOW\_INT interrupt. (RO)

APB\_SARADC\_THRES0\_LOW\_INT\_ST Status of APB\_SARADC\_THRES0\_LOW\_INT interrupt. (RO)

APB\_SARADC\_THRES1\_HIGH\_INT\_ST Status of APB\_SARADC\_THRES1\_HIGH\_INT interrupt. (RO)

APB\_SARADC\_THRES0\_HIGH\_INT\_ST Status of APB\_SARADC\_THRES0\_HIGH\_INT interrupt. (RO)

APB\_SARADC\_ADC2\_DONE\_INT\_ST Status of APB\_SARADC\_ADC2\_DONE\_INT interrupt. (RO)

APB\_SARADC\_ADC1\_DONE\_INT\_ST Status of APB\_SARADC\_ADC1\_DONE\_INT interrupt. (RO)

## Register 34.17. APB\_SARADC\_INT\_CLR\_REG (0x004C)

![Image](images/34_Chapter_34_img027_a3ed6ba6.png)

APB\_SARADC\_THRES1\_LOW\_INT\_CLR Clear bit of APB\_SARADC\_THRES1\_LOW\_INT interrupt. (WO)

APB\_SARADC\_THRES0\_LOW\_INT\_CLR Clear bit of APB\_SARADC\_THRES0\_LOW\_INT interrupt. (WO)

APB\_SARADC\_THRES1\_HIGH\_INT\_CLR Clear bit of APB\_SARADC\_THRES1\_HIGH\_INT interrupt. (WO)

- APB\_SARADC\_THRES0\_HIGH\_INT\_CLR Clear bit of APB\_SARADC\_THRES0\_HIGH\_INT interrupt. (WO)

APB\_SARADC\_ADC2\_DONE\_INT\_CLR

Clear bit of APB\_SARADC\_ADC2\_DONE\_INT interrupt. (WO)

APB\_SARADC\_ADC1\_DONE\_INT\_CLR Clear bit of APB\_SARADC\_ADC1\_DONE\_INT interrupt. (WO)

## Register 34.18. APB\_SARADC\_DMA\_CONF\_REG (0x0050)

![Image](images/34_Chapter_34_img028_a7e7bbf5.png)

APB\_SARADC\_APB\_ADC\_EOF\_NUM Generate dma\_in\_suc\_eof when sample cnt = eof\_num. (R/W)

APB\_SARADC\_APB\_ADC\_RESET\_FSM Reset DIG ADC controller status. (R/W)

APB\_SARADC\_APB\_ADC\_TRANS When this bit is set, DIG ADC controller uses DMA. (R/W)

![Image](images/34_Chapter_34_img029_a122552b.png)

Register 34.19. APB\_SARADC\_APB\_ADC\_CLKM\_CONF\_REG (0x0054)

![Image](images/34_Chapter_34_img030_f531a822.png)

APB\_SARADC\_CLKM\_DIV\_NUM The integer part of ADC clock divider. Divider value = APB\_SARADC\_CLKM\_DIV\_NUM + APB\_SARADC\_CLKM\_DIV\_B/APB\_SARADC\_CLKM\_DIV\_A. (R/W)

APB\_SARADC\_CLKM\_DIV\_B The numerator value of fractional clock divider. (R/W)

APB\_SARADC\_CLKM\_DIV\_A The denominator value of fractional clock divider. (R/W)

APB\_SARADC\_CLK\_EN Enable the SAR ADC register clock. (R/W)

APB\_SARADC\_CLK\_SEL 0: Use APB\_CLK as clock source, 1: use divided-down PLL\_240 as clock source. (R/W)

Register 34.20. APB\_SARADC\_APB\_TSENS\_CTRL\_REG (0x0058)

![Image](images/34_Chapter_34_img031_f7b81d33.png)

APB\_SARADC\_TSENS\_OUT Temperature sensor data out. (RO)

APB\_SARADC\_TSENS\_IN\_INV Invert temperature sensor input value. (R/W)

APB\_SARADC\_TSENS\_CLK\_DIV Temperature sensor clock divider. (R/W)

APB\_SARADC\_TSENS\_PU Temperature sensor power up. (R/W)

![Image](images/34_Chapter_34_img032_15465fa7.png)

Register 34.21. APB\_SARADC\_APB\_TSENS\_CTRL2\_REG (0x005C)

![Image](images/34_Chapter_34_img033_ced5574a.png)

APB\_SARADC\_TSENS\_XPD\_WAIT The wait time before temperature sensor is powered up. (R/W) APB\_SARADC\_TSENS\_CLK\_SEL Choose working clock for temperature sensor. 0: RC\_FAST\_CLK. 1: XTAL\_CLK. (R/W)

Register 34.22. APB\_SARADC\_CALI\_REG (0x0060)

![Image](images/34_Chapter_34_img034_54490fc1.png)

APB\_SARADC\_CALI\_CFG Configure the SAR ADC calibration factor. (R/W)

Register 34.23. APB\_SARADC\_APB\_CTRL\_DATE\_REG (0x03FC)

![Image](images/34_Chapter_34_img035_5ec4a146.png)

APB\_SARADC\_DATE Version register. (R/W)

## Part VII Appendix

This part contains the following information starting from the next page:

- Related Documentation and Resources
- Glossary
- Programming Reserved Register Field
- Interrupt Configuration Registers
- Revision History

## Related Documentation and Resources

## Related Documentation

- ESP32-C3 Series Datasheet – Specifications of the ESP32-C3 hardware.
- ESP32-C3 Hardware Design Guidelines – Guidelines on how to integrate the ESP32-C3 into your hardware product.
- ESP32-C3 Series SoC Errata – Descriptions of known errors in ESP32-C3 series of SoCs.

•

Certificates https://espressif.com/en/support/documents/certificates

- ESP32-C3 Product/Process Change Notifications (PCN) https://espressif.com/en/support/documents/pcns?keys=ESP32-C3
- ESP32-C3 Advisories – Information on security, bugs, compatibility, component reliability. https://espressif.com/en/support/documents/advisories?keys=ESP32-C3
- Documentation Updates and Update Notification Subscription https://espressif.com/en/support/download/documents

## Developer Zone

- ESP-IDF Programming Guide for ESP32-C3 – Extensive documentation for the ESP-IDF development framework.

•

ESP-IDF and other development frameworks on GitHub.

https://github.com/espressif

- ESP32 BBS Forum – Engineer-to-Engineer (E2E) Community for Espressif products where you can post questions, share knowledge, explore ideas, and help solve problems with fellow engineers. https://esp32.com/
- The ESP Journal – Best Practices, Articles, and Notes from Espressif folks. https://blog.espressif.com/
- See the tabs SDKs and Demos , Apps , Tools , AT Firmware . https://espressif.com/en/support/download/sdks-demos

## Products

- ESP32-C3 Series SoCs – Browse through all ESP32-C3 SoCs. https://espressif.com/en/products/socs?id=ESP32-C3
- ESP32-C3 Series Modules – Browse through all ESP32-C3-based modules. https://espressif.com/en/products/modules?id=ESP32-C3
- ESP32-C3 Series DevKits – Browse through all ESP32-C3-based devkits. https://espressif.com/en/products/devkits?id=ESP32-C3
- ESP Product Selector – Find an Espressif hardware product suitable for your needs by comparing or applying filters. https://products.espressif.com/#/product-selector?language=en

## Contact Us

- See the tabs Sales Questions , Technical Enquiries , Circuit Schematic &amp; PCB Design Review , Get Samples (Online stores), Become Our Supplier , Comments &amp; Suggestions . https://espressif.com/en/contact-us/sales-questions

## Glossary

## Abbreviations for Peripherals

AES AES (Advanced Encryption Standard) Accelerator

DS Digital Signature

DMA DMA (Direct Memory Access) Controller

eFuse eFuse Controller

HMAC HMAC (Hash-based Message Authentication Code) Accelerator

I2C I2C (Inter-Integrated Circuit) Controller

I2S I2S (Inter-IC Sound) Controller

LEDC LED Control PWM (Pulse Width Modulation)

RMT Remote Control Peripheral

RNG Random Number Generator

RSA RSA (Rivest Shamir Adleman) Accelerator

SHA SHA (Secure Hash Algorithm) Accelerator

SPI SPI (Serial Peripheral Interface) Controller

SYSTIMER System Timer

TIMG Timer Group

TWAI Two-wire Automotive Interface

UART UART (Universal Asynchronous Receiver-Transmitter) Controller

WDT Watchdog Timers

## Abbreviations Related to Registers

REG

Register .

SYSREG

System registers are a group of registers that control system reset, memory, clocks, software interrupts, power management, clock gating, etc.

- ISO Isolation. If a peripheral or other chip component is powered down, the pins, if any, to which its output signals are routed will go into a floating state. ISO registers isolate such pins and keep them at a certain determined value, so that the other non-powered-down peripherals/devices attached to these pins are not affected.

- NMI Non-maskable interrupt is a hardware interrupt that cannot be disabled or ig- nored by the CPU instructions. Such interrupts exist to signal the occurrence of a critical error.

W1TS Abbreviation added to names of registers/fields to indicate that such regis- ter/field should be used to set a field in a corresponding register with a similar name. For example, the register GPIO\_ENABLE\_W1TS\_REG should be used to set the corresponding fields in the register GPIO\_ENABLE\_REG .

W1TC Same as W1TS, but used to clear a field in a corresponding register.

## Access Types for Registers

Sections Register Summary and Register Description in TRM chapters specify access types for registers and their fields.

Most frequently used access types and their combinations are as follows:

- RO
- WO
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
- W1S Write 1 to set. If user application writes 1 to this register/field, hardware automatically sets this register/field.
- W0S Write 0 to set. If user application writes 0 to this register/field, hardware automatically sets this register/field.
- R/WS/SS/SC
- R/SS/WTC
- R/SC/WTC
- R/SS/SC/WTC
- RF/WF
- R/SS/RC
- varies

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

Register 34.24. Register X (Address)

![Image](images/34_Chapter_34_img036_3e832f3a.png)

Suppose you want to set Field\_A, Field\_B, and Field\_C of Register X to 0x0, 0x1, and 0x2, you can:

- Use option 1 and fill in the reserved fields with the value you have just read. Suppose the register reads as 0x0000\_0003. Then, you can modify the fields you want to configure, thus writing 0x0002\_0002 to the register.
- Use option 2 and fill in the reserved fields with their defaults, thus writing 0x0002\_0002 to the register.

![Image](images/34_Chapter_34_img037_8576b2e7.png)

## Interrupt Configuration Registers

Generally, the peripherals' internal interrupt sources can be configured by the following common set of registers:

- RAW (Raw Interrupt Status) register: This register indicates the raw interrupt status. Each bit in the register represents a specific internal interrupt source. When an interrupt source triggers, its RAW bit is set to 1.
- ENA (Enable) register: This register is used to enable or disable the internal interrupt sources. Each bit in the ENA register corresponds to an internal interrupt source.

By manipulating the ENA register, you can mask or unmask individual internal interrupt source as needed. When an internal interrupt source is masked (disabled), it will not generate an interrupt signal, but its value can still be read from the RAW register.

- ST (Status) register: This register reflects the status of enabled interrupt sources. Each bit in the ST register corresponds to a specific internal interrupt source. The ST bit being 1 means that both the corresponding RAW bit and ENA bit are 1, indicating that the interrupt source is triggered and not masked. The other combinations of the RAW bit and ENA bit will result in the ST bit being 0.

The configuration of ENA/RAW/ST registers is shown in Table 34.6-4 .

- CLR (Clear) register: The CLR register is responsible for clearing the internal interrupt sources. Writing 1 to the corresponding bit in the CLR register clears the interrupt source.

Table 34.6-4. Configuration of ENA/RAW/ST Registers

|   ENA Bit Value | RAW Bit Value   |   ST Bit Value |
|-----------------|-----------------|----------------|
|               0 | Ignored         |              0 |
|               1 | 0               |              0 |
|               1 | 1               |              1 |

## Revision History

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|------------|-----------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2025-05-08 | v1.3      | Updated the following chapters: •  Chapter 2  GDMA Controller (GDMA): Added descriptions for the GDMA_OUTFIFO_OVF_CHn_INT,  GDMA_OUTFIFO_UDF_CHn_INT, GDMA_INFIFO_OVF_CHn_INT, and GDMA_INFIFO_UDF_CHn_INT in terrupts •  Chapter 34 On-Chip Sensor and Analog Signal Processing: Corrected “- 0.5” to “+0.5” in the ADC filter formula                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     |
| 2025-01-14 | v1.2      | Adjusted the order of chapters Updated the following chapters: •  Chapter 1 ESP-RISC-V CPU: Fixed the bit position of mte and added clari fication that the tcontrol register complies with the RISC-V External Debug Support Version 0.13.2 •  Chapter 2 GDMA Controller (GDMA): Updated the descriptions of suc_eof and the EOF flag •  Chapter 8 Interrupt Matrix (INTERRUPT): Updated I2S1_INT to I2S_INT •  Chapter 9 Low-power Management: Updated the description of prede fined low-power modes •  Chapter 16 System Registers (SYSREG): –  Updated the DMA sources in the notes under Table 16.3-2 according to the GDMA chapter –  Removed description about I2S1 •  Chapter 17 Debug Assistant (ASSIST_DEBUG): Updated the DMA sources in Table 17.4-3 according to the GDMA chapter •  Chapter 26 UART Controller (UART): Updated descriptions about clearing the wake_up signal •  Chapter 27 SPI Controller (SPI): Updated the description of register SPI_DIN_MODE_REG and added the description to clk_hclk. •  Chapter 30 USB Serial/JTAG Controller (USB_SERIAL_JTAG): Added a note in Section 30.4 stating that burning certain eFuse can affect the normal operation of USB Serial/JTAG controller. •  Chapter 32 LED PWM Controller (LEDC): Updated the lowest resolution in Table 32.3-1 •  Chapter 34 On-Chip Sensor and Analog Signal Processing: Removed de scriptions about the internal voltage/signal in SAR ADC2 measurement |

Cont’d on next page

## Cont’d from previous page

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
|------------|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2024-01-19 | v1.1      | Added Section Programming Reserved Register Field and Section Interrupt Configuration Registers Updated register prefix APB_CTRL to SYSCON Updated the following chapters: •  Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX): Updated the descrip tion in Section 5.9, and deleted the GPIO_PCPU_NMI_INT_REG register and related information •  Chapter 7 Chip Boot Control: Added SPI Download Boot mode, re named Download Boot mode to Joint Download mode in Section 7.2 , and provided more details about how FUSE_DIS_FORCE_DOWNLOAD and EFUSE_DIS_DOWNLOAD_MODE control chip boot mode •  Chapter  8  Interrupt Matrix (INTERRUPT): Deleted the INTER RUPT_CORE0_GPIO_INTERRUPT_PRO_NMI_MAP_REG register and related information •  Chapter 9 Low-power Management: Updated the description of register RTC_CNTL_WDT_WKEY •  Chapter  11  Timer Group (TIMG): Updated the description of TIMG_WDT_CLK_PRESCALE •  Chapter 14 Permission Control (PMS): Removed ROM_Table related de scription •  Chapter 26 UART Controller (UART): Updated Figure 26.3-1 UART Archi tecture Overview and the number of rising edges required to generate the wake_up signal •  Chapter 28 I2C Controller (I2C): Updated I2C timeout configura tion and the corresponding descriptions of I2C_TIME_OUT_VALUE , I2C_COMD0_REG ,  I2C_SDA_FORCE_OUT and I2C_SCL_FORCE_OUT |

Cont’d on next page

## Cont’d from previous page

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
|------------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2023-05-19 | v1.0      | Added Chapter 14 Permission Control (PMS) Updated the following chapters: •  Chapter  2  GDMA Controller (GDMA): Updated the descrip tions of the GDMA_IN_SUC_EOF_CHn_INT interrupt and the GDMA_INLINK_DSCR_ADDR_CHn field •  Chapter 3 System and Memory: Updated Table 3.3-3 •  Chapter 4 eFuse Controller (EFUSE): Added a note on programming the XTS-AES key •  Chapter  9  Low-power Management: Removed UART as a re ject to sleep cause, and added more description about register RTC_CNTL_GPIO_WAKEUP_REG •  Chapter 11 Timer Group (TIMG): Updated the procedures to read the timer’s value •  Chapter 12 Watchdog Timers (WDT): Removed ULP-RISC-V references •  Chapter 26 UART Controller (UART): Added descriptions about the break condition, and updated Figure UART Architecture Overview, Figure UART Structure, and Figure Hardware Flow Control Diagram , and updated the maximum length of stop bits and related descriptions •  Chapter  30  USB Serial/JTAG Controller (USB_SERIAL_JTAG): Added the specific pull-up values configured by the USB_SERIAL_JTAG_PULLUP_VALUE bit •  Chapter 32 LED PWM Controller (LEDC): Added the formula to calculate duty cycle resolution and Table Commonly-used Frequencies and Reso lutions |

Cont’d on next page

## Cont’d from previous page

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|------------|-----------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2022-12-16 | v0.7      | Added the following chapter: •  Chapter 15 World Controller (WCL) Updated the following chapters: •  Chapter 1 ESP-RISC-V CPU •  Chapter 3 System and Memory •  Chapter 4 eFuse Controller (EFUSE) •  Chapter 9 Low-power Management •  Chapter 17 Debug Assistant (ASSIST_DEBUG) •  Chapter 23 External Memory Encryption and Decryption (XTS_AES) •  Chapter 24 Random Number Generator (RNG) •  Chapter 29 I2S Controller (I2S) •  Chapter 34 On-Chip Sensor and Analog Signal Processing Updated clock names: •  FOSC_CLK: renamed as RC_FAST_CLK •  FOSC_DIV_CLK: renamed as RC_FAST_DIV_CLK •  RTC_CLK: renamed as RC_SLOW_CLK •  SLOW_CLK: renamed as RTC_SLOW_CLK •  FAST_CLK: renamed as RTC_FAST_CLK •  PLL_160M_CLK: renamed as PLL_F160M_CLK •  PLL_240M_CLK: renamed as PLL_D2_CLK Updated the Glossary section |
| 2022-02-16 | v0.6      | Added the following chapters: •  Chapter 27 SPI Controller (SPI) •  Chapter 29 I2S Controller (I2S)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| 2022-01-12 | v0.5      | Added the following chapters: •  Chapter 9 Low-power Management •  Chapter 23 External Memory Encryption and Decryption (XTS_AES) Updated the following Chapters: •  Chapter 1 ESP-RISC-V CPU, Section 1.4.1 by adding three GPIO Access CSRs; Section 1.5 by removing the list of CPU interrupt registers and pro viding redirection to Chapter 8 Interrupt Matrix (INTERRUPT) •  Chapter 3 System and Memory •  Chapter 4 eFuse Controller (EFUSE) •  Chapter 19 HMAC Accelerator (HMAC) •  Chapter 20 RSA Accelerator (RSA) •  Chapter 22 Digital Signature (DS)                                                                                                                                                                                                                                                         |

Cont’d on next page

## Cont’d from previous page

| Date       | Version   | Release notes                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                |
|------------|-----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 2021-10-28 | v0.4      | Added the following chapters: •  Chapter 8 Interrupt Matrix (INTERRUPT) •  Chapter 17 Debug Assistant (ASSIST_DEBUG) •  Chapter 28 I2C Controller (I2C) •  Chapter 34 On-Chip Sensor and Analog Signal Processing •  Chapter VII Updated the following Chapters: •  Chapter 4 eFuse Controller (EFUSE) •  Chapter 33 Remote Control Peripheral (RMT)                                                                                                                                                                                                                                         |
| 2021-08-05 | v0.3      | Added the following chapters: •  Chapter 10 System Timer (SYSTIMER) •  Chapter 12 Watchdog Timers (WDT) •  Chapter 13 XTAL32K Watchdog Timers (XTWDT) •  Chapter 16 System Registers (SYSREG) •  Chapter 19 HMAC Accelerator (HMAC) •  Chapter 22 Digital Signature (DS) •  Chapter 30 USB Serial/JTAG Controller (USB_SERIAL_JTAG) •  Chapter 33 Remote Control Peripheral (RMT) Updated the following Chapters: •  Chapter 4 eFuse Controller (EFUSE) •  Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX) •  Chapter 7 Chip Boot Control •  Chapter 31 Two-wire Automotive Interface (TWAI) |
| 2021-05-27 | v0.2      | Added the following chapters: •  Chapter 2 GDMA Controller (GDMA) •  Chapter 4 eFuse Controller (EFUSE) •  Chapter 11 Timer Group (TIMG) •  Chapter 26 UART Controller (UART) •  Chapter 32 LED PWM Controller (LEDC) Updated the Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX) Adjusted the order of chapters                                                                                                                                                                                                                                                                             |
| 2021-04-08 | v0.1      | Preliminary release                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |

![Image](images/34_Chapter_34_img038_7a7483de.png)

## Disclaimer and Copyright Notice

Information in this document, including URL references, is subject to change without notice.

ALL THIRD PARTY'S INFORMATION IN THIS DOCUMENT IS PROVIDED AS IS WITH NO WARRANTIES TO ITS AUTHENTICITY AND ACCURACY.

NO WARRANTY IS PROVIDED TO THIS DOCUMENT FOR ITS MERCHANTABILITY, NON-INFRINGEMENT, FITNESS FOR ANY PARTICULAR PURPOSE, NOR DOES ANY WARRANTY OTHERWISE ARISING OUT OF ANY PROPOSAL, SPECIFICATION OR SAMPLE.

All liability, including liability for infringement of any proprietary rights, relating to use of information in this document is disclaimed. No licenses express or implied, by estoppel or otherwise, to any intellectual property rights are granted herein.

The Wi-Fi Alliance Member logo is a trademark of the Wi-Fi Alliance. The Bluetooth logo is a registered trademark of Bluetooth SIG.

All trade names, trademarks and registered trademarks mentioned in this document are property of their respective owners, and are hereby acknowledged.

Copyright © 2025 Espressif Systems (Shanghai) Co., Ltd. All rights reserved.

www.espressif.com