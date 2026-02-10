---
chapter: 37
title: "Chapter 37"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 37

## Remote Control Peripheral (RMT)

## 37.1 Overview

The RMT (Remote Control) module is designed to send and receive infrared remote control signals. A variety of remote control protocols can be encoded/decoded via software based on the RMT module. The RMT module converts pulse codes stored in the module's built-in RAM into output signals, or converts input signals into pulse codes and stores them in RAM. In addition, the RMT module optionally modulates its output signals with a carrier wave, or optionally demodulates and filters its input signals.

The RMT module has four channels, numbered from zero to three. Each channel is able to independently transmit or receive signals.

- Channels 0 ~ 1 (TX channel) are dedicated to transmitting signals;
- Channels 2 ~ 3 (RX channel) are dedicated to receiving signals.

Each TX/RX channel has the same functionality controlled by a dedicated set of registers and is able to independently transmit or receive data. TX channels are indicated by n which is used as a placeholder for the channel number, and by m for RX channels.

## 37.2 Features

The RMT module has the following features:

- Four channels:
- – Two TX channels
- – Two RX channels
- – Four channels share a 192 x 32-bit RAM
- The transmitter supports:
- – Normal TX mode
- – Wrap TX mode
- – Continuous TX mode
- – Modulation on TX pulses
- – Multiple channels (programmable) transmitting data simultaneously
- The receiver supports:
- – Normal RX mode

- – Wrap RX mode
- – RX filtering
- – Demodulation on RX pulses

## 37.3 Functional Description

## 37.3.1 RMT Architecture

Figure 37.3-1. RMT Architecture

![Image](images/37_Chapter_37_img001_a7817465.png)

As shown in Figure 37.3-1, each TX channel has:

- 1 x clock divider counter (Div Counter)
- 1 x state machine (FSM)
- 1 x transmitter

Each RX channel also has:

- 1 x clock divider counter (Div Counter)
- 1 x state machine (FSM)
- 1 x receiver

The four channels share a 192 x 32-bit RAM.

## 37.3.2 RMT RAM

## 37.3.2.1 Structure of RAM

Figure 37.3-2 shows the format of pulse code in RAM. Each pulse code contains a 16-bit entry with two fields: "level" and "period". "level" (0 or 1) indicates a low-/high-level value that was received or is going to be sent, while "period" points out the number of clock cycles (see clk\_div in Figure 37.3-1 ) that the level lasts for.

Figure 37.3-2. Format of Pulse Code in RAM

![Image](images/37_Chapter_37_img002_372d1f20.png)

The minimum value for the period is zero (0) and is interpreted as a transmission end-marker. For a non-zero period (i.e., not an end-marker), its value is limited by APB clock and RMT clock according to the equation below:

<!-- formula-not-decoded -->

## 37.3.2.2 Use of RAM

The RAM is divided into four 48 x 32-bit blocks. By default, each channel uses one block (block 0 for channel 0, block 1 for channel 1, and so on).

If the data size of one single transfer is larger than the block size of TX channel n or RX channel m, users can configure the channel:

- to enable wrap mode by setting RMT\_MEM\_TX/RX\_WRAP\_EN\_CHn/m;
- or to use more blocks by configuring RMT\_MEM\_SIZE\_CHn/m .

Setting RMT\_MEM\_SIZE\_CHn/m &gt; 1 allows channel n/m to use the memory of the subsequent channels, i.e., block (n/m) ~ block (n/m + RMT\_MEM\_SIZE\_CHn/m - 1). In such case, the subsequent channels n/m + 1 ~ n/m + RMT\_MEM\_SIZE\_CHn/m - 1 can not be used since their RAM blocks are occupied. For example, if channel 0 is configured to use block 0 and block 1, then channel 1 will be unavailable since its block is occupied, while channel 2 and channel 3 are not affected and can be used normally.

Note that the RAM used by each channel is mapped from low address to high address. In such mode, channel 0 is able to use the RAM blocks of channels 1, 2, and 3 by setting RMT\_MEM\_SIZE\_CH0, but channel 3 can not use the blocks of channels 0, 1, or 2. Therefore, the maximum value of RMT\_MEM\_SIZE\_CHn should not exceed (4 - n) and the maximum value of RMT\_MEM\_SIZE\_CHm should not exceed (2 - m).

The RMT RAM can be accessed via APB bus, or read by the transmitter and written by the receiver. To avoid any possible access conflict between the receiver writing RAM and the APB bus reading RAM, RMT can be

configured to designate the RAM block's owner, be it the receiver or the APB bus, by configuring RMT\_MEM\_OWNER\_CHm. If this ownership is violated, a flag signal RMT\_MEM\_OWNER\_ERR\_CHm will be generated.

When the RMT module is inactive, the RAM can be put into low-power mode by setting RMT\_MEM\_FORCE\_PD .

## 37.3.2.3 RAM Access

APB bus is able to access RAM in FIFO mode and in NONFIFO (Direct Address) mode, depending on the configuration of RMT\_APB\_FIFO\_MASK:

- 0: use FIFO mode;
- 1: use NONFIFO mode.

## FIFO Mode

In FIFO mode, the APB reads data from or writes data to RAM via a fixed address stored in RMT\_CHn/mDATA\_REG .

## NONFIFO Mode

In NONFIFO mode, the APB writes data to or reads data from a continuous address range.

- The write-starting address of TX channel n is: RMT base address + 0x400 + (n - 1) x 48. The access address for the second data and the following data are RMT base address + 0x400 + (n - 1) x 48 + 0x4, and so on, incremented by 0x4.
- The read-starting address of RX channel m is: RMT base address + 0x460 + (m - 1) x 48. The access address for the second data and the following data are RMT base address + 0x460 + (m - 1) x 48 + 0x4, and so on, incremented by 0x4.

## 37.3.3 Clock

The clock source of RMT can be PLL\_F80M\_CLK, RC\_FAST\_CLK, or XTAL\_CLK, depending on the configuration of PCR\_RMT\_SCLK\_SEL. RMT clock can be enabled by setting PCR\_RMT\_SCLK\_EN. RMT working clock (see rmt\_sclk in Figure 37.3-1) is obtained by dividing the selected clock source with a fractional divider. The divider is:

P CR \_ RMT \_ SCLK \_ DIV \_ NUM + 1 + P CR \_ RMT \_ SCLK \_ DIV \_ A/P CR \_ RMT \_ SCLK \_ DIV \_ B

For more information, see Chapter 8 Reset and Clock . RMT\_DIV\_CNT\_CHn/m is used to configure the divider coefficient of internal clock divider for RMT channels. The coefficient is normally equal to the value of RMT\_DIV\_CNT\_CHn/m, except for value 0 that represents divider 256. The clock divider can be reset by setting RMT\_REF\_CNT\_RST\_CHn/m. The clock generated from the divider can be used by the counter (see Figure 37.3-1).

## 37.3.4 Transmitter

## Note:

Updating the configuration described in this and subsequent sections requires to set RMT\_CONF\_UPDATE\_CHn/m first. See Section 37.3.6 .

## 37.3.4.1 Normal TX Mode

When RMT\_TX\_START\_CHn is set, the transmitter of channel n starts reading and sending pulse codes from the starting address of its RAM block. The codes are sent starting from low-address entry. When an end-marker (a zero period) is encountered, the transmitter stops the transmission, returns to idle state, and generates an RMT\_CHn\_TX\_END\_INT interrupt. Setting RMT\_TX\_STOP\_CHn to 1 also stops the transmission and immediately sets the transmitter back to idle. The output level of a transmitter in idle state is determined by the "level" field of the end-marker or by the content of RMT\_IDLE\_OUT\_LV\_CHn, depending on the configuration of RMT\_IDLE\_OUT\_EN\_CHn:

- 0: the level in idle state is determined by the "level" field of the end-marker;
- 1: the level is determined by RMT\_IDLE\_OUT\_LV\_CHn .

## 37.3.4.2 Wrap TX Mode

To transmit more pulse codes than can be fitted in the channel's RAM, users can enable wrap TX mode for channel n by setting RMT\_MEM\_TX\_WRAP\_EN\_CHn. In this mode, the transmitter sends the data from RAM in loops till an end-marker is encountered. For example, if RMT\_MEM\_SIZE\_CHn = 1, the transmitter starts sending data from the address 48 * n, and then the data from higher RAM address. Once the transmitter finishes sending the data from (48 * (n + 1) - 1), it continues sending data from 48 * n again till an end-marker is encountered. Wrap mode is also applicable for RMT\_MEM\_SIZE\_CHn &gt; 1.

When the size of transmitted pulse codes is larger than or equal to the value set by RMT\_TX\_LIM\_CHn, an RMT\_CHn\_TX\_THR\_EVENT\_INT interrupt is triggered. In wrap mode, RMT\_TX\_LIM\_CHn can be set to a half or a fraction of the size of the channel's RAM block. When an RMT\_CHn\_TX\_THR\_EVENT\_INT interrupt is detected by software, the already used RAM region can be updated by new pulse codes. In such way, the transmitter can seamlessly send unlimited pulse codes in wrap mode.

## 37.3.4.3 TX Modulation

Transmitter output can be modulated with a carrier wave by setting RMT\_CARRIER\_EN\_CHn. The carrier waveform is configurable. In a carrier cycle, high level lasts for (RMT\_CARRIER\_HIGH\_CHn + 1) rmt\_sclk cycles, while low level lasts for (RMT\_CARRIER\_LOW\_CHn + 1) rmt\_sclk cycles. When RMT\_CARRIER\_OUT\_LV\_CHn is set, carrier wave is added on the high-level of output signals; while RMT\_CARRIER\_OUT\_LV\_CHn is cleared, carrier wave is added on the low-level of output signals. Carrier wave can be added on all output signals during modulation, or just added on valid pulse codes (the data stored in RAM), which can be set by configuring RMT\_CARRIER\_EFF\_EN\_CHn:

- 0: add carrier wave on all output signals;
- 1: add carrier wave only on valid signals.

## 37.3.4.4 Continuous TX Mode

The continuous TX mode can be enabled by setting RMT\_TX\_CONTI\_MODE\_CHn. In this mode, the transmitter sends the pulse codes from RAM in loops:

- If an end-marker is encountered, the transmitter starts transmitting the first data of the channel's RAM again.
- If no end-marker is encountered, there are two possible situations. In normal TX mode (RMT\_MEM\_TX\_WRAP\_EN\_CHn = 0), an error interrupt occurs because the RAM is empty without any data to transmit. In wrap TX mode (RMT\_MEM\_TX\_WRAP\_EN\_CHn = 1), the transmitter starts transmitting the first data again after the last data is transmitted.

If RMT\_TX\_LOOP\_CNT\_EN\_CHn is set, the loop counting is incremented by 1 each time an end-marker is encountered. If the counting reaches the value set by RMT\_TX\_LOOP\_NUM\_CHn, an RMT\_CHn\_TX\_LOOP\_INT interrupt is generated. If RMT\_LOOP\_STOP\_EN\_CHn is set, the transmission stops instantly after an RMT\_CHn\_TX\_LOOP\_INT interrupt is generated. Otherwise, the transmission continues. In an end-marker, if its period[14:0] is 0, then the period of the previous data must satisfy:

<!-- formula-not-decoded -->

The period of the other data only need to satisfy relation (1) .

## 37.3.4.5 Simultaneous TX Mode

RMT module supports multiple channels transmitting data simultaneously. To use this function, follow the steps below:

1. Configure RMT\_TX\_SIM\_CHn to choose which multiple channels are used to transmit data simultaneously;
2. Set RMT\_TX\_SIM\_EN to enable this transmission mode;
3. Set RMT\_TX\_START\_CHn for each selected channel to start data transmission.

The transmission starts once the final channel is configured. Due to hardware limitations, there is no guarantee that two channels can start sending data exactly at the same time. The interval between two channels starting transmitting data is within 3 x Tclk \_ div.

## 37.3.5 Receiver

## 37.3.5.1 Normal RX Mode

The receiver of channel m is controlled by RMT\_RX\_EN\_CHm:

- 0: the receiver stops receiving data;
- 1: the receiver starts working.

When the receiver becomes active, it starts counting from the first edge of the signal, detecting signal levels and counting clock cycles the level lasts for. Each cycle count (period) is then written back to RAM together with the level information (level). When the receiver detects no change in a signal level for a number of clock cycles more than the value set by RMT\_IDLE\_THRES\_CHm, the receiver stops receiving data, returns to idle state, and generates an RMT\_CHm\_RX\_END\_INT interrupt. Please note that RMT\_IDLE\_THRES\_CHm should

be configured to a maximum value according to your application, otherwise a valid received level may be mistaken as a level in idle state. If the RAM space of this RX channel is used up by the received data, the receiver stops receiving data, and an RMT\_CHm\_ERR\_INT interrupt is triggered by RAM FULL event.

## 37.3.5.2 Wrap RX Mode

To receive more pulse codes than can be fitted in the channel's RAM, users can enable wrap mode for channel m by configuring RMT\_MEM\_RX\_WRAP\_EN\_CHm. In wrap mode, the receiver stores the received data to RAM space of this channel in loops. The receiving ends when the receiver detects no change in a signal level for a number of clock cycles more than the value set by RMT\_IDLE\_THRES\_CHm. The receiver returns to idle state and generates an RMT\_CHm\_RX\_END\_INT interrupt. For example, if RMT\_MEM\_SIZE\_CHm is set to 1, the receiver starts receiving data and stores the data to address 48 * m, and then to higher RAM address. When the receiver finishes storing the received data to (48 * (m + 1) - 1), the receiver continues receiving data and storing data to the address 48 * m again, and the receiving ends when no change is detected on a signal level for more than RMT\_IDLE\_THRES\_CHm clock cycles. Wrap mode is also applicable when RMT\_MEM\_SIZE\_CHm &gt; 1.

An RMT\_CHm\_RX\_THR\_EVENT\_INT interrupt is generated when the size of received pulse codes is larger than or equal to the value set by RMT\_CHm\_RX\_LIM\_REG. In wrap mode, RMT\_CHm\_RX\_LIM\_REG can be set to a half or a fraction of the size of the channel's RAM block. When an RMT\_CHm\_RX\_THR\_EVENT\_INT interrupt is detected, the already used RAM region can be updated by subsequent data.

## 37.3.5.3 RX Filtering

Users can enable the receiver to filter input signals by setting RMT\_RX\_FILTER\_EN\_CHm for channel m. The filter samples input signals continuously, and detects the signals which remain unchanged for a continuous RMT\_RX\_FILTER\_THRES\_CHm rmt\_sclk cycles as valid. Otherwise, the signals will be detected as invalid. Only the valid signals can pass through the filter. The filter removes pulses with a length of less than RMT\_RX\_FILTER\_THRES\_CHm rmt\_sclk cycles.

## 37.3.5.4 RX Demodulation

Users can enable RX demodulation on input signals or on filtered signals by setting RMT\_CARRIER\_EN\_CHm . RX demodulation can be applied to high-level carrier wave or low-level carrier wave, depending on the configuration of RMT\_CARRIER\_OUT\_LV\_CHm:

- 0: demodulate low-level carrier wave;
- 1: demodulate high-level carrier wave.

Users can configure RMT\_CARRIER\_HIGH\_THRES\_CHm and RMT\_CARRIER\_LOW\_THRES\_CHm to set the thresholds to demodulate high-level carrier or low-level carrier. If the high-level of a signal lasts for less than RMT\_CARRIER\_HIGH\_THRES\_CHm clk\_div cycles, or the low-level lasts for less than RMT\_CARRIER\_LOW\_THRES\_CHm clk\_div cycles, the signal is detected as a carrier and is then filtered out.

## 37.3.6 Configuration Update

To update RMT registers configuration, please set RMT\_CONF\_UPDATE\_CHn/m for each channel first.

All the bits/fields listed in the second column of Table 37.3-1 should follow this rule.

Table 37.3-1. Configuration Update

| Register                  | Bit/Field Configuration Update   |
|---------------------------|----------------------------------|
| TX Channel                |                                  |
| RMT_CHnCONF0_REG          | RMT_CARRIER_OUT_LV_CHn           |
| RMT_CHnCONF0_REG          | RMT_CARRIER_EN_CHn               |
| RMT_CHnCONF0_REG          | RMT_CARRIER_EFF_EN_CHn           |
| RMT_CHnCONF0_REG          | RMT_DIV_CNT_CHn                  |
| RMT_CHnCONF0_REG          | RMT_IDLE_OUT_EN_CHn              |
| RMT_CHnCONF0_REG          | RMT_IDLE_OUT_LV_CHn              |
| RMT_CHnCONF0_REG          | RMT_TX_CONTI_MODE_CHn            |
| RMT_CHnCARRIER_DUTY_REG   | RMT_CARRIER_HIGH_CHn             |
| RMT_CHnCARRIER_DUTY_REG   | RMT_CARRIER_LOW_CHn              |
| RMT_CHn_TX_LIM_REG        | RMT_TX_LOOP_CNT_EN_CHn           |
| RMT_CHn_TX_LIM_REG        | RMT_TX_LOOP_NUM_CHn              |
| RMT_CHn_TX_LIM_REG        | RMT_TX_LIM_CHn                   |
| RMT_TX_SIM_REG            | RMT_TX_SIM_EN                    |
| RX Channel                |                                  |
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

## 37.3.7 Interrupts

- RMT\_CHn/m\_ERR\_INT: triggered when channel n/m does not read or write data correctly. For example, if the transmitter still tries to read data from RAM when the RAM is empty, or the receiver still tries to write data into RAM when the RAM is full, this interrupt will be triggered.
- RMT\_CHn\_TX\_THR\_EVENT\_INT: triggered when the amount of data the transmitter has sent reaches the value set in RMT\_CHn\_TX\_LIM\_REG .
- RMT\_CHm\_RX\_THR\_EVENT\_INT: triggered each time when the amount of data received by the receiver reaches the value set in RMT\_CHm\_RX\_LIM\_REG .
- RMT\_CHn\_TX\_END\_INT: triggered when the transmitter has finished transmitting signals.
- RMT\_CHm\_RX\_END\_INT: triggered when the receiver has finished receiving signals.
- RMT\_CHn\_TX\_LOOP\_INT: triggered when the loop counting reaches the value set by RMT\_TX\_LOOP\_NUM\_CHn .

## 37.4 Register Summary

The addresses in this section are relative to Remote Control Peripheral base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                              | Description                                                        | Address   | Access   |
|-----------------------------------|--------------------------------------------------------------------|-----------|----------|
| FIFO R/W Registers                |                                                                    |           |          |
| RMT_CH0DATA_REG                   | The read and write data register for channel 0 by APB FIFO access. | 0x0000    | HRO      |
| RMT_CH1DATA_REG                   | The read and write data register for channel 1 by APB FIFO access. | 0x0004    | HRO      |
| RMT_CH2DATA_REG                   | The read and write data register for channel 2 by APB FIFO access. | 0x0008    | HRO      |
| RMT_CH3DATA_REG                   | The read and write data register for channel 3 by APB FIFO access. | 0x000C    | HRO      |
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

| Name                             | Description                                   | Address   | Access   |
|----------------------------------|-----------------------------------------------|-----------|----------|
| RMT_CH1_TX_LIM_REG               | Configuration register for channel 1 TX event | 0x005C    | varies   |
| RMT_TX_SIM_REG                   | RMT TX synchronous register                   | 0x006C    | R/W      |
| RX Event Configuration Registers |                                               |           |          |
| RMT_CH2_RX_LIM_REG               | Configuration register for channel 2 RX event | 0x0060    | R/W      |
| RMT_CH3_RX_LIM_REG               | Configuration register for channel 3 RX event | 0x0064    | R/W      |
| Version Register                 |                                               |           |          |
| RMT_DATE_REG                     | Version control register                      | 0x00CC    | R/W      |

## 37.5 Registers

The addresses in this section are relative to Remote Control Peripheral base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 37.1. RMT\_CHnDATA\_REG (n: 0-3) (0x0000+0x4*n)

![Image](images/37_Chapter_37_img003_0c7e2ab1.png)

RMT\_CHnDATA Read and write data for channel n via APB FIFO. (HRO)

Register 37.2. RMT\_CHnCONF0\_REG (n: 0-1) (0x0010+0x4*n)

![Image](images/37_Chapter_37_img004_1eebe6ce.png)

RMT\_TX\_START\_CHn Configures whether to enable sending data in channel n .

0: No effect

1: Enable

(WT)

RMT\_MEM\_RD\_RST\_CHn Configures whether to reset RAM read address accessed by the transmitter for channel n .

0: No effect

1: Reset

(WT)

RMT\_APB\_MEM\_RST\_CHn Configures whether to reset RAM W/R address accessed by APB FIFO for channel n .

0: No effect

1: Reset

(WT)

RMT\_TX\_CONTI\_MODE\_CHn Configures whether to enable continuous TX mode for channel n .

0: No Effect

1: Enable

In this mode, the transmitter starts transmission from the first data. If an end-marker is encountered, the transmitter starts transmitting data from the first data again; if no end-marker is encountered, the transmitter starts transmitting the first data again when the last data is transmitted.

(R/W)

RMT\_MEM\_TX\_WRAP\_EN\_CHn Configures whether to enable wrap TX mode for channel n .

0: No effect

1: Enable

In this mode, if the TX data size is larger than the channel's RAM block size, the transmitter continues transmitting the first data to the last data in loops.

(R/W)

RMT\_IDLE\_OUT\_LV\_CHn Configures the level of output signal for channel n when the transmitter is in idle state. (R/W)

Continued on the next page...

Register 37.2. RMT\_CHnCONF0\_REG (n: 0-1) (0x0010+0x4*n)

## Continued from the previous page...

RMT\_IDLE\_OUT\_EN\_CHn Configures whether to enable the output for channel n in idle state.

0: No effect

```
1: Enable (R/W)
```

RMT\_TX\_STOP\_CHn Configures whether to stop the transmitter of channel n sending data out. 0: No effect 1: Stop (R/W/SC) RMT\_DIV\_CNT\_CHn Configures the divider for clock of channel n . Measurement unit: rmt\_sclk (R/W) RMT\_MEM\_SIZE\_CHn Configures the maximum number of memory blocks allocated to channel n . (R/W) RMT\_CARRIER\_EFF\_EN\_CHn Configures whether to add carrier modulation on the output signal only at data-sending state for channel n . 0: Add carrier modulation on the output signal at data-sending state and idle state for channel n 1: Add carrier modulation on the output signal only at data-sending state for channel n Only valid when RMT\_CARRIER\_EN\_CHn is 1. (R/W) RMT\_CARRIER\_EN\_CHn Configures whether to enable the carrier modulation on output signal for channel n . 0: Disable 1: Enable

(R/W)

RMT\_CARRIER\_OUT\_LV\_CHn Configures the position of carrier wave for channel n .

```
0: Add carrier wave on low level 1: Add carrier wave on high level (R/W)
```

RMT\_CONF\_UPDATE\_CHn Synchronization bit for channel n. (WT)

## Register 37.3. RMT\_CHmCONF0\_REG (m: 2-3) (0x0008+0x8*m)

![Image](images/37_Chapter_37_img005_5662dd0d.png)

RMT\_DIV\_CNT\_CHm Configures the clock divider of channel m .

Measurement unit: rmt\_sclk

(R/W)

RMT\_IDLE\_THRES\_CHm Configures RX threshold.

When no edge is detected on the input signal for continuous clock cycles longer than this field value, the receiver stops receiving data.

Measurement unit: clk\_div

(R/W)

RMT\_MEM\_SIZE\_CHm Configures the maximum number of memory blocks allocated to channel m . (R/W)

RMT\_CARRIER\_EN\_CHm Configures whether to enable carrier modulation on output signal for channel m .

0: Disable

1: Enable

(R/W)

## RMT\_CARRIER\_OUT\_LV\_CHm Configures the position of carrier wave for channel m .

0: Add carrier wave on low level

1: Add carrier wave on high level

(R/W)

Register 37.4. RMT\_CHmCONF1\_REG (m: 2-3) (0x000C+0x8*m)

![Image](images/37_Chapter_37_img006_fce1a01b.png)

RMT\_RX\_EN\_CHm Configures whether to enable the receiver to start receiving data in channel m .

0: Disable

1: Enable

(R/W)

- RMT\_MEM\_WR\_RST\_CHm Configures whether to reset RAM write address accessed by the receiver for channel m .

0: No effect

1: Reset

(WT)

RMT\_APB\_MEM\_RST\_CHm Configures whether to reset RAM W/R address accessed by APB FIFO for channel m .

0: No effect

1: Reset

(WT)

RMT\_MEM\_OWNER\_CHm Configures the ownership of channel m's RAM block.

- 0: APB bus is using the RAM

```
1: Receiver is using the RAM
```

(R/W/SC)

RMT\_RX\_FILTER\_EN\_CHm Configures whether to enable the receiver's filter for channel m .

0: Disable

1: Enable

(R/W)

RMT\_RX\_FILTER\_THRES\_CHm Configures whether the receiver, when receiving data, ignores the input pulse when its width is shorter than this register value in units of rmt\_sclk cycles.

0: No effect

1: Reset

(R/W)

RMT\_MEM\_RX\_WRAP\_EN\_CHm Configures whether to enable wrap RX mode for channel m .

0: Disable

1: Enable

In this mode, if the RX data size is larger than channel m's RAM block size, the receiver stores the RX data from the first address to the last address in loops. (R/W)

## Register 37.5. RMT\_SYS\_CONF\_REG (0x0068)

![Image](images/37_Chapter_37_img007_2651c681.png)

RMT\_APB\_FIFO\_MASK Configures the memory access mode.

- 0: Access memory by FIFO
- 1: Access memory directly

(R/W)

RMT\_MEM\_CLK\_FORCE\_ON Configures whether to enable the clock for RMT memory.

- 0: Disable
- 1: Enable

(R/W)

RMT\_MEM\_FORCE\_PD Configures whether to power down RMT memory.

- 0: No effect
- 1: Power down

(R/W)

- RMT\_MEM\_FORCE\_PU Configures whether to disable the power-down function of RMT memory

in Light-sleep.

- 0: Power down RMT memory when RMT is in Light-sleep mode
- 1: Disable the power-down function of RMT memory in Light-sleep

(R/W)

- RMT\_CLK\_EN Configures whether to enable signal of RMT register clock gate.
- 0: Power down the drive clock of registers
- 1: Power up the drive clock of registers

(R/W)

## Register 37.6. RMT\_REF\_CNT\_RST\_REG (0x0070)

![Image](images/37_Chapter_37_img008_c658d244.png)

RMT\_REF\_CNT\_RST\_CHn Configures whether to reset the clock divider of channel n .

- 0: No effect
- 1: Reset

(WT)

RMT\_REF\_CNT\_RST\_CHm Configures whether to reset the clock divider of channel m .

- 0: No effect
- 1: Reset
- (WT)

## Register 37.7. RMT\_CHnSTATUS\_REG (n: 0-1) (0x0028+0x4*n)

![Image](images/37_Chapter_37_img009_20ff64b6.png)

RMT\_MEM\_RADDR\_EX\_CHn Represents the memory address offset when transmitter of channel n is using the RAM. (RO)

RMT\_STATE\_CHn Represents the FSM status of channel n. (RO)

RMT\_APB\_MEM\_WADDR\_CHn Represents the memory address offset when writes RAM over APB bus. (RO)

RMT\_APB\_MEM\_RD\_ERR\_CHn Represents whether the offset address exceeds memory size when reading via APB bus.

0: Not exceed

1: Exceed

(RO)

RMT\_MEM\_EMPTY\_CHn Represents whether the TX data size exceeds the memory size and the wrap TX mode is disabled.

0: Not exceed

1: Exceed

(RO)

RMT\_APB\_MEM\_WR\_ERR\_CHn Represents whether the offset address exceeds memory size (overflows) when writes via APB bus.

0: Not exceed

1: Exceed

(RO)

RMT\_APB\_MEM\_RADDR\_CHn Represents the memory address offset when reading RAM over APB bus. (RO)

## Register 37.8. RMT\_CHmSTATUS\_REG (m: 2-3) (0x0028+0x4*m)

![Image](images/37_Chapter_37_img010_9961dc8d.png)

RMT\_MEM\_WADDR\_EX\_CHm Represents the memory address offset when receiver of channel m is using the RAM. (RO)

RMT\_APB\_MEM\_RADDR\_CHm Represents the memory address offset when reads RAM over APB bus. (RO)

RMT\_STATE\_CHm Represents the FSM status of channel m. (RO)

RMT\_MEM\_OWNER\_ERR\_CHm Represents whether the ownership of memory block is wrong.

0: The ownership of memory block is correct

1: The ownership of memory block is wrong

(RO)

RMT\_MEM\_FULL\_CHm Represents whether the receiver receives more data than the memory can fit.

0: The receiver does not receive more data than the memory can fit

1: The receiver receives more data than the memory can fit

(RO)

RMT\_APB\_MEM\_RD\_ERR\_CHm Represents whether the offset address exceeds memory size (overflows) when reads RAM via APB bus.

0: Not exceed

1: Exceed

(RO)

## Register 37.9. RMT\_INT\_RAW\_REG (0x0038)

![Image](images/37_Chapter_37_img011_975510e5.png)

- RMT\_CHn\_TX\_END\_INT\_RAW The raw interrupt status of RMT\_CHn\_TX\_END\_INT. Triggered when the transmission is done. (R/WTC/SS)
- RMT\_CHm\_RX\_END\_INT\_RAW The raw interrupt status of RMT\_CHm\_RX\_END\_INT. Triggered when the reception is done. (R/WTC/SS)
- RMT\_CHn/m\_ERR\_INT\_RAW The raw interrupt status of RMT\_CHn/m\_ERR\_INT. Triggered when error occurs. (R/WTC/SS)
- RMT\_CHn\_TX\_THR\_EVENT\_INT\_RAW The raw interrupt status of RMT\_CHn\_TX\_THR\_EVENT\_INT. Triggered when the transmitter sent more data than the configured value. (R/WTC/SS)
- RMT\_CHm\_RX\_THR\_EVENT\_INT\_RAW The raw interrupt status of RMT\_CHm\_RX\_THR\_EVENT\_INT. Triggered when the receiver receives more data than the configured value. (R/WTC/SS)
- RMT\_CHn\_TX\_LOOP\_INT\_RAW The raw interrupt status of RMT\_CHn\_TX\_LOOP\_INT. Triggered when the loop count reaches the configured threshold value. (R/WTC/SS)

## Register 37.10. RMT\_INT\_ST\_REG (0x003C)

![Image](images/37_Chapter_37_img012_01d0e348.png)

RMT\_CHn\_TX\_END\_INT\_ST The masked interrupt status of RMT\_CHn\_TX\_END\_INT. (RO)

RMT\_CHm\_RX\_END\_INT\_ST The masked interrupt status of RMT\_CHm\_RX\_END\_INT. (RO)

RMT\_CHn/m\_ERR\_INT\_ST The masked interrupt status of RMT\_CHn/m\_ERR\_INT. (RO)

RMT\_CHn\_TX\_THR\_EVENT\_INT\_ST The masked interrupt status of RMT\_CHn\_TX\_THR\_EVENT\_INT. (RO)

RMT\_CHm\_RX\_THR\_EVENT\_INT\_ST The masked interrupt status of RMT\_CHm\_RX\_THR\_EVENT\_INT. (RO)

RMT\_CHn\_TX\_LOOP\_INT\_ST The masked interrupt status of RMT\_CHn\_TX\_LOOP\_INT. (RO)

## Register 37.11. RMT\_INT\_ENA\_REG (0x0040)

![Image](images/37_Chapter_37_img013_3218d1d0.png)

RMT\_CHn\_TX\_END\_INT\_ENA Write 1 to enable RMT\_CHn\_TX\_END\_INT. (R/W)

RMT\_CHm\_RX\_END\_INT\_ENA Write 1 to enable RMT\_CHm\_RX\_END\_INT. (R/W)

RMT\_CHn/m\_ERR\_INT\_ENA Write 1 to enable RMT\_CHn/m\_ERR\_INT. (R/W)

RMT\_CHn\_TX\_THR\_EVENT\_INT\_ENA Write 1 to enable RMT\_CHn\_TX\_THR\_EVENT\_INT. (R/W)

RMT\_CHm\_RX\_THR\_EVENT\_INT\_ENA Write 1 to enable RMT\_CHm\_RX\_THR\_EVENT\_INT. (R/W)

RMT\_CHn\_TX\_LOOP\_INT\_ENA Write 1 to enable RMT\_CHn\_TX\_LOOP\_INT. (R/W)

## Register 37.12. RMT\_INT\_CLR\_REG (0x0044)

![Image](images/37_Chapter_37_img014_339d071a.png)

RMT\_CHn\_TX\_END\_INT\_CLR Write 1 to clear RMT\_CHn\_TX\_END\_INT. (WT)

RMT\_CHm\_RX\_END\_INT\_CLR Write 1 to clear RMT\_CHm\_RX\_END\_INT. (WT)

RMT\_CHn/m\_ERR\_INT\_CLR Write 1 to clear RMT\_CHn/m\_ERR\_INT. (WT)

RMT\_CHn\_TX\_THR\_EVENT\_INT\_CLR Write 1 to clear RMT\_CHn\_TX\_THR\_EVENT\_INT. (WT)

RMT\_CHm\_RX\_THR\_EVENT\_INT\_CLR Write 1 to clear RMT\_CHm\_RX\_THR\_EVENT\_INT. (WT)

RMT\_CHn\_TX\_LOOP\_INT\_CLR Write 1 to clear RMT\_CHn\_TX\_LOOP\_INT. (WT)

## Register 37.13. RMT\_CHnCARRIER\_DUTY\_REG (n: 0-1) (0x0048+0x4*n)

![Image](images/37_Chapter_37_img015_2eabb9d4.png)

RMT\_CARRIER\_LOW\_CHn Configures carrier wave's low level clock period for channel n .

Measurement unit: rmt\_sclk

(R/W)

RMT\_CARRIER\_HIGH\_CHn Configures carrier wave's high level clock period for channel n . Measurement unit: rmt\_sclk (R/W)

Register 37.14. RMT\_CHm\_RX\_CARRIER\_RM\_REG (m: 2-3) (0x0048+0x4*m)

![Image](images/37_Chapter_37_img016_9d309086.png)

RMT\_CARRIER\_LOW\_THRES\_CHm Configures the low level period in a carrier modulation mode for channel m .

The low level period in a carrier modulation mode is (RMT\_CARRIER\_LOW\_THRES\_CHm + 1) for channel m .

Measurement unit: clk\_div (R/W)

RMT\_CARRIER\_HIGH\_THRES\_CHm Configures the high level period in a carrier modulation mode for channel m .

The high level period in a carrier modulation mode is (REG\_RMT\_REG\_CARRIER\_HIGH\_THRES\_CHm + 1) for channel m .

Measurement unit: clk\_div (R/W)

## Register 37.15. RMT\_CHn\_TX\_LIM\_REG (n: 0-1) (0x0058+0x4*n)

![Image](images/37_Chapter_37_img017_bc90e3ef.png)

RMT\_TX\_LIM\_CHn Configures the maximum entries that channel n can send out. (R/W)

RMT\_TX\_LOOP\_NUM\_CHn Configures the maximum loop count when Continuous TX mode is valid. (R/W)

RMT\_TX\_LOOP\_CNT\_EN\_CHn Configures whether to enable loop count.

0: No effect

1: Enable

(R/W)

RMT\_LOOP\_COUNT\_RESET\_CHn Configures whether to reset the loop count when tx\_conti\_mode is valid.

0: No effect

1: Reset

(WT)

RMT\_LOOP\_STOP\_EN\_CHn Configures whether to enable the loop send stop function after the loop counter counts to loop number for channel n .

0: No effect

1: Enable

(R/W)

## Register 37.16. RMT\_TX\_SIM\_REG (0x006C)

![Image](images/37_Chapter_37_img018_460cc27d.png)

RMT\_TX\_SIM\_CHn Configures whether to enable channel n to start sending data synchronously with other enabled channels.

- 0: No effect
- 1: Enable

(R/W)

- RMT\_TX\_SIM\_EN Configures whether to enable multiple of channels to start sending data syn-

chronously.

- 0: No effect
- 1: Enable

(R/W)

Register 37.17. RMT\_CHm\_RX\_LIM\_REG (m: 2-3) (0x0058+0x4*m)

![Image](images/37_Chapter_37_img019_600f3c2f.png)

RMT\_CHm\_RX\_LIM\_REG Configures the maximum entries that channel m can receive. (R/W)

![Image](images/37_Chapter_37_img020_5ab6d29f.png)

RMT\_DATE Version control register. (R/W)
