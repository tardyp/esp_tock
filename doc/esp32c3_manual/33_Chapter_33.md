---
chapter: 33
title: "Chapter 33"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 33

## Remote Control Peripheral (RMT)

## 33.1 Overview

The RMT (Remote Control) module is designed to send and receive infrared remote control signals. A variety of remote control protocols are supported. The RMT module converts pulse codes stored in the module's built-in RAM into output signals, or converts input signals into pulse codes and stores them back in RAM. Optionally, the RMT module modulates its output signals with a carrier wave, or demodulates and filters its input signals.

The RMT module has four channels, numbered from zero to three. Channels 0 ~ 1 (TX channels) are dedicated to transmit signals, and channels 2 ~ 3 (RX channels) to receive signals. Each TX/RX channel has the same functionality controlled by a dedicated set of registers and is able to independently either transmit or receive data. TX channels are indicated by n which is used as a placeholder for the channel number, and by m for RX channels.

## 33.2 Features

- Two TX channels
- Two RX channels
- Support multiple channels (programmable) transmitting data simultaneously
- Four channels share a 192 x 32-bit RAM
- Support modulation on TX pulses
- Support filtering and demodulation on RX pulses
- Wrap TX mode
- Wrap RX mode
- Continuous TX mode

## 33.3 Functional Description

## 33.3.1 RMT Architecture

Figure 33.3-1. RMT Architecture

![Image](images/33_Chapter_33_img001_bad71699.png)

The RMT module has four independent channels, two of which are TX channels and the other two are RX channels. Each TX channel has its own clock-divider counter, state machine, and transmitter. Each RX channel also has its own clock-divider counter, state machine, and receiver. The four channels share a 192 x 32-bit RAM.

## 33.3.2 RMT RAM

Figure 33.3-2. Format of Pulse Code in RAM

![Image](images/33_Chapter_33_img002_17516e8e.png)

Figure 33.3-2 shows the format of pulse code in RAM. Each pulse code contains a 16-bit entry with two fields, level and period.

- Level (0 or 1): indicates a low-/high-level value was received or is going to be sent.
- Period: points out how many clk\_div clock cycles the level lasts for, see Figure 33.3-1 .

A zero (0) period is interpreted as a transmission end-marker. If the period is not an end-marker, its value is limited by APB clock and RMT clock:

<!-- formula-not-decoded -->

The RAM is divided into four 48 x 32-bit blocks. By default, each channel uses one block, block zero for channel zero, block one for channel one, and so on.

If the data size of one single transfer is larger than this block size of TX channel n or RX channel m, users can configure the channel

- to enable wrap mode by setting RMT\_MEM\_TX\_WRAP\_EN\_CHn/m .
- or to use more blocks by configuring RMT\_MEM\_SIZE\_CHn/m .

Setting RMT\_MEM\_SIZE\_CHn/m &gt; 1 allows channel n/m to use the memory of subsequent channels, block (n/m) ~ block (n/m + RMT\_MEM\_SIZE\_CHn/m -1). If so, the subsequent channels n/m + 1 ~ n/m + RMT\_MEM\_SIZE\_CHn/m - 1 can not be used once their RAM blocks are occupied.

Note that the RAM used by each channel is mapped from low address to high address. In such mode, channel 0 is able to use the RAM blocks for channels 1, 2 and 3 by setting RMT\_MEM\_SIZE\_CH0, but channel 3 can not use the blocks for channels 0, 1, or 2. Therefore, the maximum value of RMT\_MEM\_SIZE\_CHn should not exceed (4 - n) and the maximum value of RMT\_MEM\_SIZE\_CHm should not exceed (2 - m).

The RMT RAM can be accessed via APB bus, or read by the transmitter and written by the receiver. To avoid any possible access conflict between the receiver and the APB bus, RMT can be configured to designate the RAM block's owner, be it the receiver or the APB bus, by configuring RMT\_MEM\_OWNER\_CHm. If this ownership is violated, a flag signal RMT\_CHm\_OWNER\_ERR will be generated.

APB bus is able to access RAM in FIFO mode and in Direct Address (NONFIFO) mode, depending on the configuration of RMT\_FIFO\_MASK:

- 1: use NONFIFO mode;
- 0: use FIFO mode.

When the RMT module is inactive, the RAM can be put into low-power mode by setting RMT\_MEM\_FORCE\_PD .

## 33.3.3 Clock

The clock source of RMT can be APB\_CLK, RC\_FAST\_CLK or XTAL\_CLK, depending on the configuration of RMT\_SCLK\_SEL. RMT clock can be enabled by setting RMT\_SCLK\_ACTIVE. RMT working clock (rmt\_sclk) is obtained by dividing the selected clock source with a fractional divider, see Figure 33.3-1. The divider is:

<!-- formula-not-decoded -->

For more information, please check Chapter 6 Reset and Clock .

RMT\_DIV\_CNT\_CHn/m is used to configure the divider coefficient of internal clock divider for RMT channels. The coefficient is normally equal to the value of RMT\_DIV\_CNT\_CHn/m, except value 0 that represents coefficient 256. The clock divider can be reset by clearing RMT\_REF\_CNT\_RST\_CHn/m. The clock generated from the divider can be used by the counter (see Figure 33.3-1).

## 33.3.4 Transmitter

## 33.3.4.1 Normal TX Mode

When RMT\_TX\_START\_CHn is set, the transmitter of channel n starts reading and sending pulse codes from the starting address of its RAM block. The codes are sent starting from low-address entry.

When an end-marker (a zero period) is encountered, the transmitter stops the transmission, returns to idle state and generates an RMT\_CHn\_TX\_END\_INT interrupt. Setting RMT\_TX\_STOP\_CHn to 1 also stops the transmission and immediately sets the transmitter back to idle.

The output level of a transmitter in idle state is determined by the "level" field of the end-marker or by the content of RMT\_IDLE\_OUT\_LV\_CHn, depending on the configuration of RMT\_IDLE\_OUT\_EN\_CHn .

To implement the above-mentioned configurations, please set RMT\_CONF\_UPDATE\_CHn first. For more information, see Section 33.3.6 .

## 33.3.4.2 Wrap TX Mode

To transmit more pulse codes than can be fitted in the channel's RAM, users can enable wrap TX mode by setting RMT\_MEM\_TX\_WRAP\_EN\_CHn. In this mode, the transmitter sends the data from RAM in loops till an end-marker is encountered.

For example, if RMT\_MEM\_SIZE\_CHn = 1, the transmitter starts sending data from the address 48 * n, and then the data from higher RAM address. Once the transmitter finishes sending the data from (48 * (n + 1) - 1), it continues sending data from 48 * n again till an end-marker is encountered. Wrap mode is also applicable for RMT\_MEM\_SIZE\_CHn &gt; 1.

When the size of transmitted pulse codes is larger than or equal to the value set by RMT\_TX\_LIM\_CHn, an RMT\_CHn\_TX\_THR\_EVENT\_INT interrupt is triggered. In wrap mode, RMT\_TX\_LIM\_CHn can be set to a half or a fraction of the size of the channel's RAM block. When an RMT\_CHn\_TX\_THR\_EVENT\_INT interrupt is detected by software, the already used RAM region can be updated with new pulse codes. In this way the transmitter can seamlessly send unlimited pulse codes in wrap mode.

To update the configuration of RMT\_MEM\_TX\_WRAP\_EN\_CHn, RMT\_MEM\_SIZE\_CHn, and RMT\_TX\_LIM\_CHn , please set RMT\_CONF\_UPDATE\_CHn first. For more information, see Section 33.3.6 .

## 33.3.4.3 TX Modulation

Transmitter output can be modulated with a carrier wave by setting RMT\_CARRIER\_EN\_CHn. The carrier waveform is configurable.

In a carrier cycle, high level lasts for (RMT\_CARRIER\_HIGH\_CHn + 1) rmt\_sclk cycles, while low level lasts for (RMT\_CARRIER\_LOW\_CHn + 1) rmt\_sclk cycles. When RMT\_CARRIER\_OUT\_LV\_CHn is set, carrier wave is added on the high-level of output signals; while RMT\_CARRIER\_OUT\_LV\_CHn is cleared, carrier wave is added on the low-level of output signals.

Carrier wave can be added on all output signals during modulation, or just added on valid pulse codes (the data stored in RAM), depending on the configuration of RMT\_CARRIER\_EFF\_EN\_CHn:

- 0: add carrier wave on all output signals;
- 1: add carrier wave only on valid signals.

To implement the modulation configuration, please set RMT\_CONF\_UPDATE\_CHn first. For more information, see Section 33.3.6 .

## 33.3.4.4 Continuous TX Mode

This continuous TX mode can be enabled by setting RMT\_TX\_CONTI\_MODE\_CHn. In this mode, the transmitter sends the pulse codes from RAM in loops.

- If an end-marker is encountered, the transmitter starts transmitting the first data again.
- If no end-marker is encountered, the transmitter starts transmitting the first data again after the last data is transmitted.

If RMT\_TX\_LOOP\_CNT\_EN\_CHn is set, the loop counting is incremented by 1 each time an end-marker is encountered. If the counting reaches the value set in RMT\_TX \_LOOP\_NUM\_CHn, an RMT\_CHn\_TX\_LOOP\_INT is generated.

In an end-marker, if its period[14:0] is 0, then the period of the previous data must satisfy the following requirement:

<!-- formula-not-decoded -->

The period of the other data only need to satisfy relation (1) .

To implement the above-mentioned configuration, please set RMT\_CONF\_UPDATE\_CHn first. For more information, see Section 33.3.6 .

## 33.3.4.5 Simultaneous TX Mode

RMT module supports multiple channels transmitting data simultaneously. To use this function, follow the steps below.

1. Configure RMT\_TX\_SIM\_CHn to choose which multiple channels are used to transmit data simultaneously.
2. Set RMT\_TX\_SIM\_EN to enable this transmission mode.
3. Set RMT\_TX\_START\_CHn for each selected channel, to start data transmitting.

Once the last channel is configured, these channels start transmitting data simultaneously. Due to hardware limitations, there is no guarantee that two channels can start sending data exactly at the same time. The interval between two channels starting transmitting data is within 3 x Tclk \_ div.

To configure RMT\_TX\_SIM\_EN, please set RMT\_CONF\_UPDATE\_CHn first. For more information, see Section 33.3.6 .

## 33.3.5 Receiver

## 33.3.5.1 Normal RX Mode

The receiver of channel m is controlled by RMT\_RX\_EN\_CHm:

- RMT\_RX\_EN\_CHm = 1, the receiver starts working.
- RMT\_RX\_EN\_CHm = 0, the receiver stops receiving data.

When the receiver becomes active, it starts counting from the first edge of the signal, detecting signal levels and counting clock cycles the level lasts for. Each cycle count is then written back to RAM.

When the receiver detects no change in a signal level for a number of clock cycles more than the value set by RMT\_IDLE\_THRES\_CHm, the receiver will stop receiving data, return to idle state, and generate an RMT\_CHm\_RX\_END\_INT interrupt.

Please note that RMT\_IDLE\_THRES\_CHm should be configured to a maximum value according to your application, otherwise a valid received level may be mistaken as a level in idle state.

If RAM block of this RX channel is used up by the received data, the receiver will stop receiving data, and generate an RMT\_CHm\_ERR\_INT interrupt triggered by RAM FULL event.

To implement configuration above, please set RMT\_CONF\_UPDATE\_CHm first. For more information, see Section 33.3.6 .

## 33.3.5.2 Wrap RX Mode

To receive more pulse codes than can be fitted in the channel's RAM, users can enable wrap RX mode for channel m by configuring RMT\_MEM\_RX\_WRAP\_EN\_CHm. In wrap mode, the receiver stores the received data to RAM block of this channel in loops.

Receiving ends, when the receiver detects no change in a signal level for a number of clock cycles more than the value set by RMT\_IDLE\_THRES\_CHm. The receiver then returns to idle state and generates an RMT\_CHm\_RX\_END\_INT interrupt.

For example, if RMT\_MEM\_SIZE\_CHm is set to 1, the receiver starts receiving data and stores the data to address 48 * m, and then to higher RAM address. When the receiver finishes storing the received data to address (48 * (m + 1) - 1), the receiver continues receiving data and storing data to the address 48 * m again, till no change is detected on a signal level for more than RMT\_IDLE\_THRES\_CHm clock cycles. Wrap mode is also applicable for RMT\_MEM\_SIZE\_CHm &gt; 1.

An RMT\_CHm\_RX\_THR\_EVENT\_INT is generated when the size of received pulse codes is larger than or equal to the value set by RMT\_RX\_LIM\_CHm. In wrap mode, RMT\_RX\_LIM\_CHM can be set to a half or a fraction of the size of the channel's RAM block. When an RMT\_CHm\_RX\_THR\_EVENT\_INT interrupt is detected by software, the system will be notified to copy out data stored in already used RMT RAM region, and then the region can be updated by subsequent data. In this way an arbitrary amount of data can be seamlessly received.

To implement the configuration above, please set RMT\_CONF\_UPDATE\_CHm first. For more information, see Section 33.3.6 .

## 33.3.5.3 RX Filtering

Users can enable the receiver to filter input signals by setting RMT\_RX\_FILTER\_EN\_CHm for each channel. The filter samples input signals continuously, and detects the signals which remain unchanged for a

continuous RMT\_RX\_FILTER\_THRES\_CHm rmt\_sclk cycles as valid, otherwise, the signals are rejected. Only the valid signals can pass through this filter. The filter removes pulses with a length of less than RMT\_RX\_FILTER\_THRES\_CHn rmt\_sclk cycles.

To implement the configuration above, please set RMT\_CONF\_UPDATE\_CHm first. For more information, see Section 33.3.6 .

## 33.3.5.4 RX Demodulation

Users can enable demodulation function on input signals or on filtered output signals by setting RMT\_CARRIER\_EN\_CHm. RX demodulation can be applied to high-level carrier wave or low-level carrier wave, depending on the configuration of RMT\_CARRIER\_OUT\_LV\_CHm:

- 1: demodulate high-level carrier wave
- 0: demodulate low-level carrier wave

Users can configure RMT\_CARRIER\_HIGH\_THRES\_CHm and RMT\_CARRIER\_LOW\_THRES\_CHm to set the thresholds to demodulate high-level carrier wave or low-level carrier wave.

If the high-level of a signal lasts for less than RMT\_CARRIER\_HIGH\_THRES\_CHm clk\_div cycles, or the low-level lasts for less than RMT\_CARRIER\_LOW\_THRES\_CHm clk\_div cycles, such level is detected as a carrier wave and then is filtered out.

To implement the configuration above, please set RMT\_CONF\_UPDATE\_CHm first. For more information, see Section 33.3.6 .

## 33.3.6 Configuration Update

To update RMT registers configuration, please set RMT\_CONF\_UPDATE\_CHn/m for each channel first.

All the bits/fields listed in the second column of Table 33.3-1 should follow this rule.

Table 33.3-1. Configuration Update

| Register                | Bit/Field Configuration Update   |
|-------------------------|----------------------------------|
| TX Channels             | TX Channels                      |
| RMT_CHnCONF0_REG        | RMT_CARRIER_OUT_LV_CHn           |
| RMT_CHnCONF0_REG        | RMT_CARRIER_EN_CHn               |
| RMT_CHnCONF0_REG        | RMT_CARRIER_EFF_EN_CHn           |
| RMT_CHnCONF0_REG        | RMT_DIV_CNT_CHn                  |
| RMT_CHnCONF0_REG        | RMT_TX_STOP_CHn                  |
| RMT_CHnCONF0_REG        | RMT_IDLE_OUT_EN_CHn              |
| RMT_CHnCONF0_REG        | RMT_IDLE_OUT_LV_CHn              |
| RMT_CHnCONF0_REG        | RMT_TX_CONTI_MODE_CHn            |
| RMT_CHnCARRIER_DUTY_REG | RMT_CARRIER_HIGH_CHn             |
| RMT_CHnCARRIER_DUTY_REG | RMT_CARRIER_LOW_CHn              |
| RMT_CHn_TX_LIM_REG      | RMT_TX_LOOP_CNT_EN_CHn           |
| RMT_CHn_TX_LIM_REG      | RMT_TX_LOOP_NUM_CHn              |
| RMT_CHn_TX_LIM_REG      | RMT_TX_LIM_CHn                   |
| RMT_CHn_TX_SIM_REG      | RMT_TX_SIM_EN                    |

Cont’d on next page

Table 33.3-1 – cont’d from previous page

| Register                  | Bit/Field Configuration Update   |
|---------------------------|----------------------------------|
| RX Channels               | RX Channels                      |
| RMT_CHmCONF0_REG          | RMT_CARRIER_OUT_LV_CHm           |
| RMT_CHmCONF0_REG          | RMT_CARRIER_EN_CHm               |
| RMT_CHmCONF0_REG          | RMT_IDLE_THRES_CHm               |
| RMT_CHmCONF0_REG          | RMT_DIV_CNT_CHm                  |
| RMT_CHmCONF1_REG          | RMT_RX_FILTER_THRES_CHm          |
| RMT_CHmCONF1_REG          | RMT_RX_EN_CHm                    |
| RMT_CHm_RX_CARRIER_RM_REG | RMT_CARRIER_HIGH_THRES_CHm       |
| RMT_CHm_RX_CARRIER_RM_REG | RMT_CARRIER_LOW_THRES_CHm        |
| RMT_CHm_RX_LIM_REG        | RMT_RX_LIM_CHm                   |
| RMT_REF_CNT_RST_REG       | RMT_REF_CNT_RST_CHm              |

## 33.3.7 Interrupts

- RMT\_CHn/m\_ERR\_INT: triggered when channel n/m does not read or write data correctly. For example, if the transmitter still tries to read data from RAM when the RAM is empty, or the receiver still tries to write data into RAM when the RAM is full, this interrupt will be triggered.
- RMT\_CHn\_TX\_THR\_EVENT\_INT: triggered when the amount of data the transmitter has sent matches the value of RMT\_CHn\_TX\_LIM\_REG .
- RMT\_CHm\_RX\_THR\_EVENT\_INT: triggered each time when the amount of data received by the receiver reaches the value set in RMT\_CHm\_RX\_LIM\_REG.
- RMT\_CHn\_TX\_END\_INT: Triggered when the transmitter has finished transmitting signals.
- RMT\_CHm\_RX\_END\_INT: Triggered when the receiver has finished receiving signals.
- RMT\_CHn\_TX\_LOOP\_INT: Triggered when the loop counting reaches the value set by RMT\_TX\_LOOP\_NUM\_CHn .

## 33.4 Register Summary

The addresses in this section are relative to RMT base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                              | Description                                                        | Address   | Access   |
|-----------------------------------|--------------------------------------------------------------------|-----------|----------|
| FIFO R/W Registers                |                                                                    |           |          |
| RMT_CH0DATA_REG                   | The read and write data register for channel 0 by APB FIFO access. | 0x0000    | RO       |
| RMT_CH1DATA_REG                   | The read and write data register for channel 1 by APB FIFO access. | 0x0004    | RO       |
| RMT_CH2DATA_REG                   | The read and write data register for channel 2 by APB FIFO access. | 0x0008    | RO       |
| RMT_CH3DATA_REG                   | The read and write data register for channel 3 by APB FIFO access. | 0x000C    | RO       |
| Configuration Registers           |                                                                    |           |          |
| RMT_CH0CONF0_REG                  | Configuration register 0 for channel 0                             | 0x0010    | varies   |
| RMT_CH1CONF0_REG                  | Configuration register 0 for channel 1                             | 0x0014    | varies   |
| RMT_CH2CONF0_REG                  | Configuration register 0 for channel 2                             | 0x0018    | R/W      |
| RMT_CH2CONF1_REG                  | Configuration register 1 for channel 2                             | 0x001C    | varies   |
| RMT_CH3CONF0_REG                  | Configuration register 0 for channel 3                             | 0x0020    | R/W      |
| RMT_CH3CONF1_REG                  | Configuration register 1 for channel 3                             | 0x0024    | varies   |
| RMT_SYS_CONF_REG                  | Configuration register for RMT APB                                 | 0x0068    | R/W      |
| RMT_REF_CNT_RST_REG               | Reset register for RMT clock divider                               | 0x0070    | WT       |
| Status Registers                  |                                                                    |           |          |
| RMT_CH0STATUS_REG                 | Channel 0 status register                                          | 0x0028    | RO       |
| RMT_CH1STATUS_REG                 | Channel 1 status register                                          | 0x002C    | RO       |
| RMT_CH2STATUS_REG                 | Channel 2 status register                                          | 0x0030    | RO       |
| RMT_CH3STATUS_REG                 | Channel 3 status register                                          | 0x0034    | RO       |
| Interrupt Registers               |                                                                    |           |          |
| RMT_INT_RAW_REG                   | Raw interrupt status                                               | 0x0038    | R/WTC/SS |
| RMT_INT_ST_REG                    | Masked interrupt status                                            | 0x003C    | RO       |
| RMT_INT_ENA_REG                   | Interrupt enable bits                                              | 0x0040    | R/W      |
| RMT_INT_CLR_REG                   | Interrupt clear bits                                               | 0x0044    | WT       |
| Carrier Wave Duty Cycle Registers |                                                                    |           |          |
| RMT_CH0CARRIER_DUTY_REG           | Duty cycle configuration register for channel 0                    | 0x0048    | R/W      |
| RMT_CH1CARRIER_DUTY_REG           | Duty cycle configuration register for channel 1                    | 0x004C    | R/W      |
| RMT_CH2_RX_CARRIER_RM_REG         | Carrier remove register for channel 2                              | 0x0050    | R/W      |
| RMT_CH3_RX_CARRIER_RM_REG         | Carrier remove register for channel 3                              | 0x0054    | R/W      |
| TX Event Configuration Registers  |                                                                    |           |          |
| RMT_CH0_TX_LIM_REG                | Configuration register for channel 0 TX event                      | 0x0058    | varies   |
| RMT_CH1_TX_LIM_REG                | Configuration register for channel 1 TX event                      | 0x005C    | varies   |
| RMT_TX_SIM_REG                    | RMT TX synchronous register                                        | 0x006C    | R/W      |

| Name                             | Description                                   | Address                          | Access                           |
|----------------------------------|-----------------------------------------------|----------------------------------|----------------------------------|
| RX Event Configuration Registers | RX Event Configuration Registers              | RX Event Configuration Registers | RX Event Configuration Registers |
| RMT_CH2_RX_LIM_REG               | Configuration register for channel 2 RX event | 0x0060                           | R/W                              |
| RMT_CH3_RX_LIM_REG               | Configuration register for channel 3 RX event | 0x0064                           | R/W                              |
| Version Register                 | Version Register                              | Version Register                 | Version Register                 |
| RMT_DATE_REG                     | Version control register                      | 0x00CC                           | R/W                              |

## 33.5 Registers

The addresses in this section are relative to RMT base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 33.1. RMT\_CHnDATA\_REG (n = 0, 1) (0x0000, 0x0004)

![Image](images/33_Chapter_33_img003_f0c13c95.png)

RMT\_CHnDATA Read and write data for channel n via APB FIFO. (RO)

Register 33.2. RMT\_CHmDATA\_REG (m = 2, 3) (0x0008, 0x000C)

![Image](images/33_Chapter_33_img004_55e77922.png)

RMT\_CHmDATA Read and write data for channel m via APB FIFO. (RO)

Register 33.3. RMT\_CHnCONF0\_REG (n = 0, 1) (0x0010, 0x0014)

![Image](images/33_Chapter_33_img005_0a7d6a34.png)

RMT\_TX\_START\_CHn Set this bit to start sending data in channel n. (WT)

RMT\_MEM\_RD\_RST\_CHn Set this bit to reset RAM read address accessed by the transmitter for channel n. (WT)

RMT\_APB\_MEM\_RST\_CHn Set this bit to reset RAM W/R address accessed by APB FIFO for channel n. (WT)

RMT\_TX\_CONTI\_MODE\_CHn Set this bit to enable continuous TX mode for channel n. (R/W)

In this mode, the transmitter starts its transmission from the first data, and in the following transmission:

- if an end-marker is encountered, the transmitter starts transmitting data from the first data again;
- if no end-marker is encountered, the transmitter starts transmitting the first data again when the last data is transmitted.

RMT\_MEM\_TX\_WRAP\_EN\_CHn Set this bit to enable wrap TX mode for channel n. In this mode, if the TX data size is larger than the channel's RAM block size, the transmitter continues transmitting the first data to the last data in loops. (R/W)

RMT\_IDLE\_OUT\_LV\_CHn This bit configures the level of output signal for channel n when the transmitter is in idle state. (R/W)

RMT\_IDLE\_OUT\_EN\_CHn This is the output enable-bit for channel n in idle state. (R/W)

RMT\_TX\_STOP\_CHn Set this bit to stop the transmitter of channel n sending data out. (R/W/SC)

Continued on the next page...

Register 33.3. RMT\_CHnCONF0\_REG (n = 0, 1) (0x0010, 0x0014)

## Continued from the previous page...

RMT\_DIV\_CNT\_CHn This field is used to configure the divider for clock of channel n. (R/W)

RMT\_MEM\_SIZE\_CHn This register is used to configure the maximum number of memory blocks allocated to channel n. (R/W)

- RMT\_CARRIER\_EFF\_EN\_CHn 1: Add carrier modulation on the output signal only at data-sending state for channel n. 0: Add carrier modulation on the output signal at data-sending state and idle state for channel n. Only valid when RMT\_CARRIER\_EN\_CHn is 1. (R/W)
- RMT\_CARRIER\_EN\_CHn This is the carrier modulation enable-bit for channel n. 1: Add carrier modulation on the output signal. 0: No carrier modulation is added on output signal. (R/W)

RMT\_CARRIER\_OUT\_LV\_CHn This bit is used to configure the position of carrier wave for channel n. (R/W)

1’h0: add carrier wave on low level.

1’h1: add carrier wave on high level.

RMT\_CONF\_UPDATE\_CHn Synchronization bit for channel n (WT)

Register 33.4. RMT\_CHmCONF0\_REG (m = 2, 3) (0x0018, 0x0020)

![Image](images/33_Chapter_33_img006_5d68ea03.png)

RMT\_DIV\_CNT\_CHm This field is used to configure the clock divider of channel m. (R/W)

RMT\_IDLE\_THRES\_CHm This field is used to configure RX threshold. When no edge is detected on the input signal for continuous clock cycles longer than this field value, the receiver stops receiving data. (R/W)

RMT\_MEM\_SIZE\_CHm This field is used to configure the maximum number of memory blocks allocated to channel m. (R/W)

- RMT\_CARRIER\_EN\_CHm This is the carrier modulation enable-bit for channel m. 1: Add carrier modulation on output signal. 0: No carrier modulation is added on output signal. (R/W)

RMT\_CARRIER\_OUT\_LV\_CHm This bit is used to configure the position of carrier wave for channel m. (R/W)

1’h0: add carrier wave on low level.

1’h1: add carrier wave on high level.

![Image](images/33_Chapter_33_img007_14b9d4e9.png)

Register 33.5. RMT\_CHmCONF1\_REG(m = 2, 3) (0x001C, 0x0024)

![Image](images/33_Chapter_33_img008_7d58b447.png)

RMT\_RX\_EN\_CHm Set this bit to enable the receiver to start receiving data in channel m. (R/W)

RMT\_MEM\_WR\_RST\_CHm Set this bit to reset RAM write address accessed by the receiver for channel m. (WT)

RMT\_APB\_MEM\_RST\_CHm Set this bit to reset RAM W/R address accessed by APB FIFO for channel m. (WT)

RMT\_MEM\_OWNER\_CHm This bit marks the ownership of channel m's RAM block. (R/W/SC)

1’h1: Receiver is using the RAM.

1’h0: APB bus is using the RAM.

RMT\_RX\_FILTER\_EN\_CHm Set this bit to enable the receiver's filter for channel m. (R/W)

RMT\_RX\_FILTER\_THRES\_CHm When receiving data, the receiver ignores the input pulse when its width is shorter than this register value in units of rmt\_sclk cycles. (R/W)

RMT\_MEM\_RX\_WRAP\_EN\_CHm Set this bit to enable wrap RX mode for channel m. In this mode, if the RX data size is larger than channel m's RAM block size, the receiver stores the RX data from the first address to the last address in loops. (R/W)

RMT\_CONF\_UPDATE\_CHm Synchronization bit for channel m. (WT)

## Register 33.6. RMT\_SYS\_CONF\_REG (0x0068)

![Image](images/33_Chapter_33_img009_67522fa0.png)

RMT\_APB\_FIFO\_MASK 1’h1: Access memory directly. 1’h0: Access memory by FIFO. (R/W)

RMT\_MEM\_CLK\_FORCE\_ON Set this bit to enable the clock for RMT memory. (R/W)

RMT\_MEM\_FORCE\_PD Set this bit to power down RMT memory. (R/W)

RMT\_MEM\_FORCE\_PU 1: Disable the power-down function of RMT memory in Light-sleep. 0: Power down RMT memory when RMT is in Light-sleep mode. (R/W)

RMT\_SCLK\_DIV\_NUM The integral part of the fractional divider. (R/W)

RMT\_SCLK\_DIV\_A The numerator of the fractional part of the fractional divider. (R/W)

RMT\_SCLK\_DIV\_B The denominator of the fractional part of the fractional divider. (R/W)

RMT\_SCLK\_SEL Choose the clock source of rmt\_sclk. 1: APB\_CLK; 2: RC\_FAST\_CLK; 3: XTAL\_CLK. (R/W)

RMT\_SCLK\_ACTIVE rmt\_sclk switch. (R/W)

RMT\_CLK\_EN The enable signal of RMT register clock gate. 1: Power up the drive clock of registers.

0: Power down the drive clock of registers. (R/W)

## Register 33.7. RMT\_REF\_CNT\_RST\_REG (0x0070)

![Image](images/33_Chapter_33_img010_e112f828.png)

RMT\_REF\_CNT\_RST\_CH0 This bit is used to reset the clock divider of channel 0. (WT)

RMT\_REF\_CNT\_RST\_CH1 This bit is used to reset the clock divider of channel 1. (WT)

RMT\_REF\_CNT\_RST\_CH2 This bit is used to reset the clock divider of channel 2. (WT)

RMT\_REF\_CNT\_RST\_CH3 This bit is used to reset the clock divider of channel 3. (WT)

Register 33.8. RMT\_CHnSTATUS\_REG (n = 0, 1) (0x0028, 0x002C)

![Image](images/33_Chapter_33_img011_bd3d6118.png)

RMT\_MEM\_RADDR\_EX\_CHn This field records the memory address offset when transmitter of channel n is using the RAM. (RO)

RMT\_STATE\_CHn This field records the FSM status of channel n. (RO)

- RMT\_APB\_MEM\_WADDR\_CHn This field records the memory address offset when writes RAM over APB bus. (RO)
- RMT\_APB\_MEM\_RD\_ERR\_CHn This status bit will be set if the offset address is out of memory size (overflows) when reads RAM via APB bus. (RO)
- RMT\_MEM\_EMPTY\_CHn This status bit will be set when the TX data size is larger than the memory size and the wrap TX mode is disabled. (RO)
- RMT\_APB\_MEM\_WR\_ERR\_CHn This status bit will be set if the offset address is out of memory size (overflows) when writes via APB bus. (RO)
- RMT\_APB\_MEM\_RADDR\_CHn This field records the memory address offset when reads RAM over APB bus. (RO)

Register 33.9. RMT\_CHmSTATUS\_REG (m = 2, 3) (0x0030, 0x0034)

![Image](images/33_Chapter_33_img012_a75a0aff.png)

- RMT\_MEM\_WADDR\_EX\_CHm This field records the memory address offset when the receiver of channel m is using the RAM. (RO)
- RMT\_APB\_MEM\_RADDR\_CHm This field records the memory address offset when reads RAM over APB bus. (RO)
- RMT\_STATE\_CHm This field records the FSM status of channel m. (RO)
- RMT\_MEM\_OWNER\_ERR\_CHm This status bit will be set when the ownership of memory block is wrong. (RO)
- RMT\_MEM\_FULL\_CHm This status bit will be set if the receiver receives more data than the memory can fit. (RO)
- RMT\_APB\_MEM\_RD\_ERR\_CHm This status bit will be set if the offset address is out of memory size (overflows) when reads RAM via APB bus. (RO)

## Register 33.10. RMT\_INT\_RAW\_REG (0x0038)

![Image](images/33_Chapter_33_img013_db5bac97.png)

RMT\_CH0\_TX\_END\_INT\_RAW The interrupt raw bit of RMT\_CH0\_TX\_END\_INT. (R/WTC/SS)

RMT\_CH1\_TX\_END\_INT\_RAW The interrupt raw bit of RMT\_CH1\_TX\_END\_INT. (R/WTC/SS)

RMT\_CH2\_RX\_END\_INT\_RAW The interrupt raw bit of RMT\_CH2\_RX\_END\_INT. (R/WTC/SS)

RMT\_CH3\_RX\_END\_INT\_RAW The interrupt raw bit of RMT\_CH3\_RX\_END\_INT. (R/WTC/SS)

RMT\_CH0\_ERR\_INT\_RAW The interrupt raw bit of RMT\_CH0\_ERR\_INT. (R/WTC/SS)

RMT\_CH1\_ERR\_INT\_RAW The interrupt raw bit of RMT\_CH1\_ERR\_INT. (R/WTC/SS)

RMT\_CH2\_ERR\_INT\_RAW The interrupt raw bit of RMT\_CH2\_ERR\_INT. (R/WTC/SS)

RMT\_CH3\_ERR\_INT\_RAW The interrupt raw bit of RMT\_CH3\_ERR\_INT. (R/WTC/SS)

RMT\_CH0\_TX\_THR\_EVENT\_INT\_RAW The interrupt raw bit of RMT\_CH0\_TX\_THR\_EVENT\_INT . (R/WTC/SS)

RMT\_CH1\_TX\_THR\_EVENT\_INT\_RAW The interrupt raw bit of RMT\_CH0\_TX\_THR\_EVENT\_INT . (R/WTC/SS)

RMT\_CH2\_RX\_THR\_EVENT\_INT\_RAW The interrupt raw bit of RMT\_CH2\_RX\_THR\_EVENT\_INT . (R/WTC/SS)

RMT\_CH3\_RX\_THR\_EVENT\_INT\_RAW The interrupt raw bit of RMT\_CH3\_RX\_THR\_EVENT\_INT . (R/WTC/SS)

RMT\_CH0\_TX\_LOOP\_INT\_RAW The interrupt raw bit of RMT\_CH0\_TX\_LOOP\_INT. (R/WTC/SS)

RMT\_CH1\_TX\_LOOP\_INT\_RAW The interrupt raw bit of RMT\_CH1\_TX\_LOOP\_INT. (R/WTC/SS)

## Register 33.11. RMT\_INT\_ST\_REG (0x003C)

![Image](images/33_Chapter_33_img014_93ca34da.png)

RMT\_CH0\_TX\_END\_INT\_ST The masked interrupt status bit for RMT\_CH0\_TX\_END\_INT. (RO)

RMT\_CH1\_TX\_END\_INT\_ST The masked interrupt status bit for RMT\_CH1\_TX\_END\_INT. (RO)

RMT\_CH2\_RX\_END\_INT\_ST The masked interrupt status bit for RMT\_CH2\_RX\_END\_INT. (RO)

RMT\_CH3\_RX\_END\_INT\_ST The masked interrupt status bit for RMT\_CH3\_RX\_END\_INT. (RO)

RMT\_CH0\_ERR\_INT\_ST The masked interrupt status bit for RMT\_CH0\_ERR\_INT. (RO)

RMT\_CH1\_ERR\_INT\_ST The masked interrupt status bit for RMT\_CH1\_ERR\_INT. (RO)

RMT\_CH2\_ERR\_INT\_ST The masked interrupt status bit for RMT\_CH2\_ERR\_INT. (RO)

RMT\_CH3\_ERR\_INT\_ST The masked interrupt status bit for RMT\_CH3\_ERR\_INT. (RO)

| RMT_CH0_TX_THR_EVENT_INT_ST The masked interrupt status bit for RMT_CH0_TX_THR_EVENT_INT. (RO)   |
|--------------------------------------------------------------------------------------------------|
| RMT_CH1_TX_THR_EVENT_INT_ST The masked interrupt status bit for RMT_CH1_TX_THR_EVENT_INT. (RO)   |
| RMT_CH2_RX_THR_EVENT_INT_ST The masked interrupt status bit for RMT_CH2_RX_THR_EVENT_INT. (RO)   |
| RMT_CH3_RX_THR_EVENT_INT_ST The masked interrupt status bit for RMT_CH3_RX_THR_EVENT_INT. (RO)   |

RMT\_CH0\_TX\_LOOP\_INT\_ST The masked interrupt status bit for RMT\_CH0\_TX\_LOOP\_INT. (RO)

RMT\_CH1\_TX\_LOOP\_INT\_ST The masked interrupt status bit for RMT\_CH1\_TX\_LOOP\_INT. (RO)

## Register 33.12. RMT\_INT\_ENA\_REG (0x0040)

![Image](images/33_Chapter_33_img015_159a0df6.png)

RMT\_CH0\_TX\_END\_INT\_ENA The interrupt enable bit for RMT\_CH0\_TX\_END\_INT. (R/W)

RMT\_CH1\_TX\_END\_INT\_ENA The interrupt enable bit for RMT\_CH1\_TX\_END\_INT. (R/W)

RMT\_CH2\_RX\_END\_INT\_ENA The interrupt enable bit for RMT\_CH2\_RX\_END\_INT. (R/W)

RMT\_CH3\_RX\_END\_INT\_ENA The interrupt enable bit for RMT\_CH3\_RX\_END\_INT. (R/W)

RMT\_CH0\_ERR\_INT\_ENA The interrupt enable bit for RMT\_CH0\_ERR\_INT. (R/W)

RMT\_CH1\_ERR\_INT\_ENA The interrupt enable bit for RMT\_CH1\_ERR\_INT. (R/W)

RMT\_CH2\_ERR\_INT\_ENA The interrupt enable bit for RMT\_CH2\_ERR\_INT. (R/W)

RMT\_CH3\_ERR\_INT\_ENA The interrupt enable bit for RMT\_CH3\_ERR\_INT. (R/W)

RMT\_CH0\_TX\_THR\_EVENT\_INT\_ENA The interrupt enable bit for RMT\_CH0\_TX\_THR\_EVENT\_INT . (R/W)

- RMT\_CH1\_TX\_THR\_EVENT\_INT\_ENA The interrupt enable bit for RMT\_CH1\_TX\_THR\_EVENT\_INT . (R/W)
- RMT\_CH2\_RX\_THR\_EVENT\_INT\_ENA The interrupt enable bit for RMT\_CH2\_RX\_THR\_EVENT\_INT . (R/W)
- RMT\_CH3\_RX\_THR\_EVENT\_INT\_ENA The interrupt enable bit for RMT\_CH3\_RX\_THR\_EVENT\_INT . (R/W)

RMT\_CH0\_TX\_LOOP\_INT\_ENA The interrupt enable bit for RMT\_CH0\_TX\_LOOP\_INT. (R/W)

RMT\_CH1\_TX\_LOOP\_INT\_ENA The interrupt enable bit for RMT\_CH1\_TX\_LOOP\_INT. (R/W)

![Image](images/33_Chapter_33_img016_c972d589.png)

## Register 33.13. RMT\_INT\_CLR\_REG (0x0044)

![Image](images/33_Chapter_33_img017_28842c50.png)

RMT\_CH0\_TX\_END\_INT\_CLR Set this bit to clear the RMT\_CH0\_TX\_END\_INT interrupt. (WT)

RMT\_CH1\_TX\_END\_INT\_CLR Set this bit to clear the RMT\_CH1\_TX\_END\_INT interrupt. (WT)

RMT\_CH2\_RX\_END\_INT\_CLR Set this bit to clear the RMT\_CH2\_RX\_END\_IN interrupt. (WT)

RMT\_CH3\_RX\_END\_INT\_CLR Set this bit to clear the RMT\_CH3\_RX\_END\_IN interrupt. (WT)

RMT\_CH0\_ERR\_INT\_CLR Set this bit to clear the RMT\_CH0\_ERR\_INT interrupt. (WT)

RMT\_CH1\_ERR\_INT\_CLR Set this bit to clear the RMT\_CH1\_ERR\_INT interrupt. (WT)

RMT\_CH2\_ERR\_INT\_CLR Set this bit to clear the RMT\_CH2\_ERR\_INT interrupt. (WT)

RMT\_CH3\_ERR\_INT\_CLR Set this bit to clear the RMT\_CH3\_ERR\_INT interrupt. (WT)

RMT\_CH0\_TX\_THR\_EVENT\_INT\_CLR Set this bit to clear the RMT\_CH0\_TX\_THR\_EVENT\_INT interrupt. (WT)

RMT\_CH1\_TX\_THR\_EVENT\_INT\_CLR Set this bit to clear the RMT\_CH1\_TX\_THR\_EVENT\_INT interrupt. (WT)

RMT\_CH2\_RX\_THR\_EVENT\_INT\_CLR Set this bit to clear the RMT\_CH2\_RX\_THR\_EVENT\_INT interrupt. (WT)

RMT\_CH3\_RX\_THR\_EVENT\_INT\_CLR Set this bit to clear the RMT\_CH3\_RX\_THR\_EVENT\_INT interrupt. (WT)

RMT\_CH0\_TX\_LOOP\_INT\_CLR Set this bit to clear the RMT\_CH0\_TX\_LOOP\_INT interrupt. (WT)

RMT\_CH1\_TX\_LOOP\_INT\_CLR Set this bit to clear the RMT\_CH1\_TX\_LOOP\_INT interrupt. (WT)

Register 33.14. RMT\_CHnCARRIER\_DUTY\_REG (n = 0, 1) (0x0048, 0x004C)

![Image](images/33_Chapter_33_img018_1ce4a844.png)

RMT\_CARRIER\_LOW\_CHn This field is used to configure carrier wave's low level clock period for channel n. (R/W)

RMT\_CARRIER\_HIGH\_CHn This field is used to configure carrier wave's high level clock period for channel n. (R/W)

Register 33.15. RMT\_CHm\_RX\_CARRIER\_RM\_REG (m = 2, 3) (0x0050, 0x0054)

![Image](images/33_Chapter_33_img019_9b6a8b36.png)

RMT\_CARRIER\_LOW\_THRES\_CHm The low level period in a carrier modulation mode is (RMT\_CARRIER\_LOW\_THRES\_CHm + 1) for channel m. (R/W)

RMT\_CARRIER\_HIGH\_THRES\_CHm The high level period in a carrier modulation mode is (RMT\_CARRIER\_HIGH\_THRES\_CHm + 1) for channel m. (R/W)

Register 33.16. RMT\_CHn\_TX\_LIM\_REG (n = 0, 1) (0x0058, 0x005C)

![Image](images/33_Chapter_33_img020_a3fd1351.png)

RMT\_TX\_LIM\_CHn This field is used to configure the maximum entries that channel n can send out. (R/W)

RMT\_TX\_LOOP\_NUM\_CHn This field is used to configure the maximum loop count when continuous TX mode is enabled. (R/W)

RMT\_TX\_LOOP\_CNT\_EN\_CHn This bit is the enable bit for loop counting. (R/W)

RMT\_LOOP\_COUNT\_RESET\_CHn This bit is used to reset the loop count when continuous TX mode is enabled. (WT)

## Register 33.17. RMT\_TX\_SIM\_REG (0x006C)

![Image](images/33_Chapter_33_img021_4d85c0cc.png)

- RMT\_TX\_SIM\_CH0 Set this bit to enable channel 0 to start sending data synchronously with other enabled channels. (R/W)

RMT\_TX\_SIM\_CH1 Set this bit to enable channel 1 to start sending data synchronously with other enabled channels. (R/W)

RMT\_TX\_SIM\_EN This bit is used to enable multiple of channels to start sending data synchronously. (R/W)

Register 33.18. RMT\_CHm\_RX\_LIM\_REG (m = 2, 3) (0x0060, 0x0064)

![Image](images/33_Chapter_33_img022_ae0843a4.png)

RMT\_RX\_LIM\_CHm This field is used to configure the maximum entries that channel m can receive. (R/W)

## Register 33.19. RMT\_DATE\_REG (0x00CC)

RMT\_DATE Version control register. (R/W)

![Image](images/33_Chapter_33_img023_086183ed.png)

## Part VI

## Analog Signal Processing

This part describes components related to analog-to-digital conversion, on-chip sensors, and features such as temperature sensing, demonstrating the system's capabilities in handling analog signals.
