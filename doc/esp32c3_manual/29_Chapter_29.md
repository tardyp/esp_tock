---
chapter: 29
title: "Chapter 29"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 29

## I2S Controller (I2S)

## 29.1 Overview

ESP32-C3 has a built-in I2S interface, which provides a flexible communication interface for streaming digital data in multimedia applications, especially digital audio applications.

The I2S standard bus defines three signals: a bit clock signal (BCK), a channel/word select signal (WS), and a serial data signal (SD). A basic I2S data bus has one master and one slave. The roles remain unchanged throughout the communication. The I2S module on ESP32-C3 provides separate transmit (TX) and receive (RX) units for high performance.

## 29.2 Terminology

To better illustrate the functionality of I2S, the following terms are used in this chapter.

| Master mode        | As a master, I2S drives BCK/WS signals, and sends data to or receives data from a slave.                                                                                                                                                                                                                                                                                                     |
|--------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Slave mode         | As a slave, I2S is driven by BCK/WS signals, and receives data from or sends data to a master.                                                                                                                                                                                                                                                                                               |
| Full-duplex        | There are two separate data lines. Transmitted and received data are carried simultaneously.                                                                                                                                                                                                                                                                                                 |
| Half-duplex        | Only one side, the master or the slave, sends data first, and the other side receives data. Sending data and receiving data can not                                                                                                                                                                                                                                                          |
| A-law and µ-law    | A-law and µ-law are compression/decompression algorithms in digital pulse code modulated (PCM) non-uniform quantization, which can effectively improve the signal-to-quantization noise ra                                                                                                                                                                                                  |
| TDM RX mode        | In this mode, pulse code modulated (PCM) data is received and stored into memory via direct memory access (DMA), utilizing time division multiplexing (TDM). The signal lines include: BCK, WS, and SD. Data from 16 channels at most can be received. TDM Philips standard, TDM MSB alignment standard, and TDM PCM standard are supported in this mode, depending on user config uration. |
| Normal PDM RX mode | In this mode, pulse density modulation (PDM) data is received and stored into memory via DMA. Used signals: WS and DATA. PDM standard is supported in this mode by user configuration.                                                                                                                                                                                                       |

| TDM TX mode        | In this mode, pulse code modulated (PCM) data is sent from memory via DMA, in a way of time division multiplexing (TDM). The signal lines include: BCK, WS, and DATA. Data up to 16 channels can be sent. TDM Philips standard, TDM MSB alignment standard, and TDM PCM standard are supported in this mode, depending on user configuration.   |
|--------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Normal PDM TX mode | In this mode, pulse density modulation (PDM) data is sent from memory via DMA. The signal lines include: WS and DATA. PDM standard is supported in this mode by user configuration.                                                                                                                                                             |
| PCM-to-PDM TX mode | In this mode, I2S as a master, converts the pulse code modulated (PCM) data from memory via DMA into pulse density modulation (PDM) data, and then sends the data out. Used signals: WS and DATA. PDM standard is supported in this mode by user configura tion.                                                                               |

## 29.3 Features

- Supports master mode and slave mode
- Supports full-duplex and half-duplex communications
- Provides separate TX unit and RX unit, independent of each other
- Supports TX unit and RX unit to work independently and simultaneously
- Supports a variety of audio standards:
- – TDM Philips standard
- – TDM MSB alignment standard
- – TDM PCM standard
- – PDM standard
- Configurable high-precision sample clock
- Supports the following frequencies: 8 kHz, 16 kHz, 32 kHz, 44.1 kHz, 48 kHz, 88.2 kHz, 96 kHz, 128 kHz, and 192 kHz (192 kHz is not supported in 32-bit slave mode).
- Supports 8-/16-/24-/32-bit data communication
- Supports DMA access
- Supports standard I2S interface interrupts

## 29.4 System Architecture

Figure 29.4-1. ESP32-C3 I2S System Diagram

![Image](images/29_Chapter_29_img001_a53696bd.png)

Figure 29.4-1 shows the structure of ESP32-C3 I2S module, consisting of:

- TX unit (TX control)
- RX unit (RX control)
- input and output timing unit (I/O sync)
- clock divider (Clock Generator)
- 64 x 32-bit TX FIFO
- 64 x 32-bit RX FIFO
- Compress/Decompress units

I2S module supports direct access (DMA) to internal memory, see Chapter 2 GDMA Controller (GDMA) .

Both the TX unit and the RX unit have a three-line interface that includes a bit clock line (BCK), a word select line (WS), and a serial data line (SD). The SD line of the TX unit is fixed as output, and the SD line of the RX unit as input. BCK and WS signal lines for TX unit and RX unit can be configured as master output mode or slave input mode.

The signal bus of I2S module is shown at the right part of Figure 29.4-1. The naming of these signals in RX and TX units follows the pattern: I2SA \_ B \_ C, such as I2SI \_ BCK \_ in .

- “A”: direction of data bus

- – “I”: input, receiving

- – “O”: output, transmitting

- "B": signal function
- – BCK
- – WS
- – SD
- "C": signal direction
- – "in": input signal into I2S module
- – "out": output signal from I2S module

Table 29.4-1 provides a detailed description of I2S signals.

Table 29.4-1. I2S Signal Description

| Signal        | Direction   | Function                                                               |
|---------------|-------------|------------------------------------------------------------------------|
| I2SI_BCK_in   | Input       | In I2S slave mode, inputs BCK signal for RX unit.                      |
| I2SI_BCK_out  | Output      | In I2S master mode, outputs BCK signal for RX unit.                    |
| I2SI_WS_in    | Input       | In I2S slave mode, inputs WS signal for RX unit.                       |
| I2SI_WS_out   | Output      | In I2S master mode, outputs WS signal for RX unit.                     |
| I2SI_Data_in  | Input       | Works as the serial input data bus for I2S RX unit.                    |
| I2SO_Data_out | Output      | Works as the serial output data bus for I2S TX unit.                   |
| I2SO_BCK_in   | Input       | In I2S slave mode, inputs BCK signal for TX unit.                      |
| I2SO_BCK_out  | Output      | In I2S master mode, outputs BCK signal for TX unit.                    |
| I2SO_WS_in    | Input       | In I2S slave mode, inputs WS signal for TX unit.                       |
| I2SO_WS_out   | Output      | In I2S master mode, outputs WS signal for TX unit.                     |
| I2S_MCLK_in   | Input       | In I2S slave mode, works as a clock source from the external mas ter. |
| I2S_MCLK_out  | Output      | In I2S master mode, works as a clock source for the external slave.    |

## Note:

Any required signals of I2S must be mapped to the chip's pins via GPIO matrix, see Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX) .

## 29.5 Supported Audio Standards

ESP32-C3 I2S supports multiple audio standards, including TDM Philips standard, TDM MSB alignment standard, TDM PCM standard, and PDM standard.

Select the needed standard by configuring the following bits:

- I2S\_TX/RX\_TDM\_EN
- – 0: disable TDM mode.
- – 1: enable TDM mode.
- I2S\_TX/RX\_PDM\_EN

WS(LRCK)

BCK(SCLK)

SD(SDOUT)

Left Channels

- – 0: disable PDM mode.
- – 1: enable PDM mode.
- I2S\_TX/RX\_MSB\_SHIFT
- – 0: WS and SD signals change simultaneously, i.e. enable MSB alignment standard.
- – 1: WS signal changes one BCK clock cycle earlier than SD signal, i.e. enable Philips standard or select PCM standard. · Channel n —
- I2S\_TX/RX\_PCM\_BYPASS
- – 0: enable PCM standard.
- – 1: disable PCM standard.

## 29.5.1 TDM Philips Standard

Philips specifications require that WS signal changes one BCK clock cycle earlier than SD signal on BCK falling edge, which means that WS signal is valid from one clock cycle before transmitting the first bit of channel data and changes one clock before the end of channel data transfer. SD signal line transmits the most significant bit of audio data first.

Compared with Philips standard, TDM Philips standard supports multiple channels, see Figure 29.5-1 .

Figure 29.5-1. TDM Philips Standard Timing Diagram

![Image](images/29_Chapter_29_img002_f21976a3.png)

## 29.5.2 TDM MSB Alignment Standard

MSB alignment specifications require WS and SD signals change simultaneously on the falling edge of BCK. The WS signal is valid until the end of channel data transfer. The SD signal line transmits the most significant bit of audio data first.

Compared with MSB alignment standard, TDM MSB alignment standard supports multiple channels, see Figure 29.5-2 .

1 SCLK

Right Channels

→

WS(LRCK)

WS(LRCK)

BCK(SCLK)

BCK(SCLK)

SD(SDOUT)

SD(SDOUT)

Left Channels

Right Channels

→

1 SCLK

Figure 29.5-2. TDM MSB Alignment Standard Timing Diagram

![Image](images/29_Chapter_29_img003_185806de.png)

## 29.5.3 TDM PCM Standard

Short frame synchronization under PCM standard requires WS signal changes one BCK clock cycle earlier than SD signal on the falling edge of BCK, which means that the WS signal becomes valid one clock cycle before transferring the first bit of channel data and remains unchanged in this BCK clock cycle. SD signal line transmits the most significant bit of audio data first.

Compared with PCM standard, TDM PCM standard supports multiple channels, see Figure 29.5-3 .

Figure 29.5-3. TDM PCM Standard Timing Diagram

![Image](images/29_Chapter_29_img004_4afcb482.png)

## 29.5.4 PDM Standard

Under PDM standard, WS signal changes continuously during data transmission. The low-level and high-level of this signal indicates the left channel and right channel, respectively. WS and SD signals change simultaneously on the falling edge of BCK, see Figure 29.5-4 .

WS(LRCK)

BCK(SCLK)

SD(SDOUT)-

Figure 29.5-4. PDM Standard Timing Diagram

![Image](images/29_Chapter_29_img005_6e2220ef.png)

## 29.6 I2S TX/RX Clock

I2S\_TX/RX\_CLK is the master clock of I2S TX/RX unit, divided from:

- 40 MHz XTAL\_CLK
- 160 MHz PLL\_F160M\_CLK
- 240 MHz PLL\_D2\_CLK
- or external input clock: I2S\_MCLK\_in

The serial clock (BCK) of the I2S TX/RX unit is divided from I2S\_TX/RX\_CLK, as shown in Figure 29.6-1 . I2S\_TX/RX\_CLK\_SEL is used to select clock source for TX/RX unit, and I2S\_TX/RX\_CLK\_ACTIVE to enable or disable the clock source.

Figure 29.6-1. I2S Clock

![Image](images/29_Chapter_29_img006_b778ffa4.png)

The following formula shows the relation between I2S\_TX/RX\_CLK frequency fI2S\_TX/RX\_CLK and the divider clock source frequency fI2S\_CLK\_S:

<!-- formula-not-decoded -->

N is an integer value between 2 and 256. The value of N corresponds to the value of I2S\_TX/RX\_CLKM\_DIV\_NUM in register I2S\_TX/RX\_CLKM\_CONF\_REG as follows:

- When I2S\_TX/RX\_CLKM\_DIV\_NUM = 0, N = 256.
- When I2S\_TX/RX\_CLKM\_DIV\_NUM = 1, N = 2.
- When I2S\_TX/RX\_CLKM\_DIV\_NUM has any other value, N = I2S\_TX/RX\_CLKM\_DIV\_NUM .

The values of "a" and "b" in fractional divider depend only on x, y, z, and yn1. The corresponding formulas are as follows:

- When b &lt;= a 2 , yn1 = 0, x = floor([ a b ]) − 1, y = a%b, z = b;
- When b &gt; a 2 , yn1 = 1, x = floor([ a a - b ]) − 1, y = a%(a - b), z = a - b.

The values of x, y, z, and yn1 are configured in I2S\_TX/RX\_CLKM\_DIV\_X , I2S\_TX/RX\_CLKM\_DIV\_Y , I2S\_TX/RX\_CLKM\_DIV\_Z, and I2S\_TX/RXCLKM\_DIV\_YN1. To configure the integer divider, clear I2S\_TX/RX\_CLKM\_DIV\_X and I2S\_TX/RX\_CLKM\_DIV\_Z, then set I2S\_TX/RX\_CLKM\_DIV\_Y to 1.

## Note:

Using fractional divider may introduce some clock jitter.

In master TX mode, the serial clock BCK for I2S TX unit is I2SO\_BCK\_out, divided from I2S\_TX\_CLK. That is:

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

“MO” is an integer value:

## Note:

I2S\_TX\_BCK\_DIV\_NUM must not be configured as 1.

In master RX mode, the serial clock BCK for I2S RX unit is I2SI\_BCK\_out, divided from I2S\_RX\_CLK. That is:

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

“MI” is an integer value:

## Note:

- I2S\_RX\_BCK\_DIV\_NUM must not be configured as 1.
- In I2S slave mode, make sure fI2S\_TX/RX\_CLK &gt;= 8 * fBCK. I2S module can output I2S\_MCLK\_out as the master clock for peripherals.

## 29.7 I2S Reset

The units and FIFOs in I2S module are reset by the following bits.

- I2S TX/RX units: reset by the bits I2S\_TX\_RESET and I2S\_RX\_RESET .
- I2S TX/RX FIFO: reset by the bits I2S\_TX\_FIFO\_RESET and I2S\_RX\_FIFO\_RESET .

## Note:

I2S module clock must be configured first before the module and FIFO are reset.

## 29.8 I2S Master/Slave Mode

The ESP32-C3 I2S module can operate as a master or a slave in half-duplex and full-duplex communication modes, depending on the configuration of I2S\_RX\_SLAVE\_MOD and I2S\_TX\_SLAVE\_MOD .

- I2S\_TX\_SLAVE\_MOD
- – 0: master TX mode
- – 1: slave TX mode
- I2S\_RX\_SLAVE\_MOD
- – 0: master RX mode
- – 1: slave RX mode

## 29.8.1 Master/Slave TX Mode

- I2S works as a master transmitter:
- – Set the bit I2S\_TX\_START to start transmitting data.
- – TX unit keeps driving the clock signal and serial data.
- – If I2S\_TX\_STOP\_EN is set and all the data in FIFO is transmitted, the master stops transmitting data.
- – If I2S\_TX\_STOP\_EN is cleared and all the data in FIFO is transmitted, meanwhile no new data is filled into FIFO, then the TX unit keeps sending the last data frame.
- – Master stops sending data when the bit I2S\_TX\_START is cleared.
- I2S works as a slave transmitter:
- – Set the bit I2S\_TX\_START .

- – Wait for the master BCK clock to enable a transmit operation.
- – If I2S\_TX\_STOP\_EN is set and all the data in FIFO is transmitted, then the slave keeps sending zeros, till the master stops providing BCK signal.
- – If I2S\_TX\_STOP\_EN is cleared and all the data in FIFO is transmitted, meanwhile no new data is filled into FIFO, then the TX unit keeps sending the last data frame.
- – If I2S\_TX\_START is cleared, slave keeps sending zeros till the master stops providing BCK clock signal.

## 29.8.2 Master/Slave RX Mode

- I2S works as a master receiver:
- – Set the bit I2S\_RX\_START to start receiving data.
- – RX unit keeps outputting clock signal and sampling input data.
- – RX unit stops receiving data when the bit I2S\_RX\_START is cleared.
- I2S works as a slave receiver:
- – Set the bit I2S\_RX\_START .
- – Wait for master BCK signal to start receiving data.
- – RX unit stops receiving data when the bit I2S\_RX\_START is cleared.

## 29.9 Transmitting Data

## Note:

Updating the configuration described in this and subsequent sections requires to set I2S\_TX\_UPDATE accordingly, to synchronize registers from APB clock domain to TX clock domain. For more detailed configuration, see Section 29.11.1 .

In TX mode, I2S first reads data from DMA and sends these data out via output signals according to the configured data mode and channel mode.

## 29.9.1 Data Format Control

Data format is controlled in the following phases:

- Phase I: read data from memory and write it to TX FIFO.
- Phase II: read the data to send (TX data) from TX FIFO and convert the data according to output data mode.
- Phase III: clock out the TX data serially.

## 29.9.1.1 Bit Width Control of Channel Valid Data

The bit width of valid data in each channel is determined by I2S\_TX\_BITS\_MOD and I2S\_TX\_24\_FILL\_EN, see the table below.

Table 29.9-1. Bit Width of Channel Valid Data

| Channel Valid Data Width   |   I2S_TX_BITS_MOD | I2S_TX_24_FILL_EN   |
|----------------------------|-------------------|---------------------|
| 32                         |                31 | x 1                 |
| 24                         |                23 | 1                   |
|                            |                23 | 0                   |
| 16                         |                15 | x                   |
| 8                          |                 7 | x                   |

## 29.9.1.2 Endian Control of Channel Valid Data

When I2S reads data from DMA, the data endian under various data width is controlled by I2S\_TX\_BIG\_ENDIAN, see the table below.

Table 29.9-2. Endian of Channel Valid Data

|   Channel Valid Data Width | Origin Data      | Endian of Processed Data   | I2S_TX_BIG_ENDIAN   |
|----------------------------|------------------|----------------------------|---------------------|
|                         32 | {B3, B2, B1, B0} | {B3, B2, B1, B0}           | 0                   |
|                         32 | {B3, B2, B1, B0} | {B0, B1, B2, B3}           | 1                   |
|                         24 | {B2, B1, B0}     | {B2, B1, B0}               | 0                   |
|                         24 | {B2, B1, B0}     | {B0, B1, B2}               | 1                   |
|                         16 | {B1, B0}         | {B1, B0}                   | 0                   |
|                         16 | {B1, B0}         | {B0, B1}                   | 1                   |
|                          8 | {B0}             | {B0}                       | x                   |

## 29.9.1.3 A-law/µ-law Compression and Decompression

ESP32-C3 I2S compresses/decompresses the valid data into 32-bit by A-law or by µ-law. If the bit width of valid data is smaller than 32, zeros are filled to the extra high bits of the data to be compressed/decompressed by default.

## Note:

Extra high bits here mean the bits[31: channel valid data width] of the data to be compressed/decompressed.

## Configure I2S\_TX\_PCM\_BYPASS to:

- 0: compress or decompress the data.
- 1: do not compress or decompress the data.

Configure I2S\_TX\_PCM\_CONF to:

- 0: decompress the data using A-law.
- 1: compress the data using A-law.
- 2: decompress the data using µ-law.
- 3: compress the data using µ-law.

B217:01 | B117:01 BO[7:0]

At this point, the first phase of data format control is complete.

## 29.9.1.4 Bit Width Control of Channel TX Data

The TX data width in each channel is determined by I2S\_TX\_TDM\_CHAN\_BITS .

- If TX data width in each channel is larger than the valid data width, zeros will be filled to these extra bits. Configure I2S\_TX\_LEFT\_ALIGN to:
- – 0: the valid data is at the lower bits of TX data. Zeros are filled into higher bits of TX data.
- – 1: the valid data is at the higher bits of TX data. Zeros are filled into lower bits of TX data.
- If the TX data width in each channel is smaller than the valid data width, only the lower bits of valid data are sent out, and the higher bits are discarded.

At this point, the second phase of data format control is complete.

## 29.9.1.5 Bit Order Control of Channel Data

The data bit order in each channel is controlled by I2S\_TX\_BIT\_ORDER:

- 0: Not reverse the valid data bit order;
- 1: Reverse the valid data bit order.

At this point, the data format control is complete. Figure 29.9-1 shows a complete process of TX data format control.

![Image](images/29_Chapter_29_img007_a61bbf9e.png)

Figure 29.9-1. TX Data Format Control

![Image](images/29_Chapter_29_img008_9aac30d4.png)

## 29.9.2 Channel Mode Control

ESP32-C3 I2S supports both TDM TX mode and PDM TX mode. Set I2S\_TX\_TDM\_EN to enable TDM TX mode, or set I2S\_TX\_PDM\_EN to enable PDM TX mode.

## Note:

- I2S\_TX\_TDM\_EN and I2S\_TX\_PDM\_EN must not be cleared or set simultaneously.
- Most stereo I2S codecs can be controlled by setting the I2S module into 2-channel mode under TDM standard.

## 29.9.2.1 I2S Channel Control in TDM TX Mode

In TDM TX mode, I2S supports up to 16 channels to output data. The total number of TX channels in use is controlled by I2S\_TX\_TDM\_TOT\_CHAN\_NUM. For example, if I2S\_TX\_TDM\_TOT\_CHAN\_NUM is set to 5, six channels in total (channel 0 ~ 5) will be used to transmit data, see Figure 29.9-2 .

In these TX channels, if I2S\_TX\_TDM\_CHANn\_EN is set to:

- 1: this channel sends the channel data out.
- 0: the TX data to be sent by this channel is controlled by I2S\_TX\_CHAN\_EQUAL:
- – 1: the data of previous channel is sent out.
- – 0: the data stored in I2S\_SINGLE\_DATA is sent out.

In TDM TX master mode, WS signal is controlled by I2S\_TX\_WS\_IDLE\_POL and

I2S\_TX\_TDM\_WS\_WIDTH:

- I2S\_TX\_WS\_IDLE\_POL: the default level of WS signal
- I2S\_TX\_TDM\_WS\_WIDTH: the cycles the WS default level lasts for when transmitting all channel data

I2S\_TX\_HALF\_SAMPLE\_BITS x 2 is equal to the BCK cycles in one WS period.

## TDM Channel Configuration Example

In this example, register configuration is as follows:

- I2S\_TX\_TDM\_CHAN\_NUM = 5, i.e. channel 0 ~ 5 are used to transmit data.
- I2S\_TX\_CHAN\_EQUAL = 1, i.e. that data of previous channel will be transmitted if the bit I2S\_TX\_TDM\_CHANn
- \_EN is cleared. n = 0 ~ 5.
- I2S\_TX\_TDM\_CHAN0/2/5\_EN = 1, i.e. these channels send their channel data out.
- I2S\_TX\_TDM\_CHAN1/3/4\_EN = 0, i.e. these channels send the previous channel data out.

Once the configuration is done, data is transmitted as follows.

Data\_0

Data\_0 X

Data\_2

channel

- Channel

Data\_2

Data\_2

Channel -

Data\_5

Figure 29.9-2. TDM Channel Control

![Image](images/29_Chapter_29_img009_838d54d8.png)

## 29.9.2.2 I2S Channel Control in PDM TX Mode

ESP32-C3 I2S supports two PDM TX modes, namely, normal PDM TX mode and PCM-to-PDM TX mode.

In PDM TX mode, fetching data from DMA is controlled by I2S\_TX\_MONO and I2S\_TX\_MONO\_FST\_VLD, see Table 29.9-3. Please configure the two bits according to the data stored in memory, be it the single-channel or dual-channel data.

Table 29.9-3. Data-Fetching Control in PDM TX Mode

| Data-Fetching Control Option                                                  | Mode        |   I2S_TX_MONO | I2S_TX_MONO_FST_VLD   |
|-------------------------------------------------------------------------------|-------------|---------------|-----------------------|
| Post data-fetching request to DMA at any edge of WS signal                    | Stereo mode |             0 | x                     |
| Post data-fetching request to DMA only at the second half period of WS signal | Mono mode   |             1 | 0                     |
| Post data-fetching request to DMA only at the first half period of WS signal  | Mono mode   |             1 | 1                     |

In normal PDM TX mode, I2S channel mode is controlled by I2S\_TX\_CHAN\_MOD and I2S\_TX\_WS\_IDLE\_POL , see the table below.

Table 29.9-4. I2S Channel Control in Normal PDM TX Mode

| Channel Control Op tion   | Left Channel                     | Right Channel                   |   Mode Control Field1 | Channel Select Bit2   |
|----------------------------|----------------------------------|---------------------------------|-----------------------|-----------------------|
| Stereo mode                | Transmit the left channel data   | Transmit the right channel data |                     0 | x                     |
| Mono mode                  | Transmit the left channel data   | Transmit the left channel data  |                     1 | 0                     |
| Mono mode                  | Transmit the right channel data  | Transmit the right channel data |                     1 | 1                     |
| Mono mode                  | Transmit the right channel data  | Transmit the right channel data |                     2 | 0                     |
| Mono mode                  | Transmit the left channel data   | Transmit the left channel data  |                     2 | 1                     |
| Mono mode                  | Transmit the value of “single” 3 | Transmit the right channel data |                     3 | 0                     |
| Mono mode                  | Transmit the left channel data   | Transmit the value of “single”  |                     3 | 1                     |
| Mono mode                  | Transmit the left channel data   | Transmit the value of “single”  |                     4 | 0                     |
| Mono mode                  | Transmit the value of “single”   | Transmit the right channel data |                     4 | 1                     |

In PDM TX aster mode, the WS level of I2S module is controlled by I2S\_TX\_WS\_IDLE\_POL. The frequency of WS signal is half of BCK frequency. The configuration of WS signal is similar to that of BCK signal, see Section 29.6 and Figure 29.9-3 .

In PCM-to-PDM TX mode, the PCM data from DMA is converted to PDM data and then output in PDM signal format. Configure I2S\_PCM2PDM\_CONV\_EN to enable this mode.

The register configuration for PCM-to-PDM TX mode is as follows:

- Configure 1-line PDM output format or 1-/2-line DAC output mode as the table below:

Table 29.9-5. PCM-to-PDM TX Mode

| Channel Output Format      |   I2S_TX_PDM_DAC_MODE_EN | I2S_TX_PDM_DAC_2OUT_EN   |
|----------------------------|--------------------------|--------------------------|
| 1-line PDM output format 1 |                        0 | x                        |
| 1-line DAC output format 2 |                        1 | 0                        |
| 2-line DAC output format   |                        1 | 1                        |

## Note:

1. In PDM output format, SD data of two channels is sent out in one WS period.
2. In DAC output format, SD data of one channel is sent out in one WS period.
3. In PCM-to-PDM TX mode, PDM clock frequency is equal to BCK frequency. The relation of sampling
- Configure sampling frequency and upsampling rate frequency (fSampling) and BCK frequency is as follows:

<!-- formula-not-decoded -->

Upsampling rate (OSR) is related to I2S\_TX\_PDM\_SINC\_OSR2 as follows:

<!-- formula-not-decoded -->

Sampling frequency fSampling is related to I2S\_TX\_PDM\_FS as follows:

<!-- formula-not-decoded -->

Configure the registers according to needed sampling frequency, upsampling rate, and PDM clock frequency.

## PDM Channel Configuration Example

In this example, the register configuration is as follows.

- I2S\_TX\_CHAN\_MOD = 2, i.e. mono mode is selected.
- I2S\_TX\_WS\_IDLE\_POL = 1, i.e. both the left channel and right channel transmit the left channel data.

Once the configuration is done, the channel data is transmitted as follows.

![Image](images/29_Chapter_29_img010_d63bf0a0.png)

I2S\_TX\_CHAN\_MOD = 2; I2S\_TX\_WS\_IDLE\_POL = 1;

Figure 29.9-3. PDM Channel Control Example

## 29.10 Receiving Data

## Note:

Updating the configuration described in this and subsequent sections requires setting I2S\_RX\_UPDATE, to synchronize registers from APB clock domain to RX clock domain. For more detailed configuration, see Section 29.11.2 .

In RX mode, I2S first reads data from peripheral interface, and then stores the data into memory via DMA, according to the configured channel mode and data mode.

## 29.10.1 Channel Mode Control

ESP32-C3 I2S supports both TDM RX mode and PDM RX mode. Set I2S\_RX\_TDM\_EN to enable TDM RX mode, or set I2S\_RX\_PDM\_EN to enable PDM RX mode.

## Note:

I2S\_RX\_TDM\_EN and I2S\_RX\_PDM\_EN must not be cleared or set simultaneously.

## 29.10.1.1 I2S Channel Control in TDM RX Mode

In TDM RX mode, I2S supports up to 16 channels to input data. The total number of RX channels in use is controlled by I2S\_RX\_TDM\_TOT\_CHAN\_NUM. For example, if I2S\_RX\_TDM\_TOT\_CHAN\_NUM is set to 5, channel 0 ~ 5 will be used to receive data.

In these RX channels, if I2S\_RX\_TDM\_CHANn\_EN is set to:

- 1: this channel data is valid and will be stored into RX FIFO.
- 0: this channel data is invalid and will not be stored into RX FIFO.

In TDM RX master mode, WS signal is controlled by I2S\_RX\_WS\_IDLE\_POL and I2S\_RX\_TDM\_WS\_WIDTH .

- I2S\_RX\_WS\_IDLE\_POL: the default level of WS signal
- I2S\_RX\_TDM\_WS\_WIDTH: the cycles the WS default level lasts for when receiving all channel data

I2S\_RX\_HALF\_SAMPLE\_BITS x 2 is equal to the BCK cycles in one WS period.

## 29.10.1.2 I2S Channel Control in PDM RX Mode

In PDM RX mode, I2S converts the serial data from channels to the data to be entered into memory.

In PDM RX master mode, the default level of WS signal is controlled by I2S\_RX\_WS\_IDLE\_POL. WS frequency is half of BCK frequency. The configuration of BCK signal is similar to that of WS signal as described in Section 29.6. Note, in PDM RX mode, the value of I2S\_RX\_HALF\_SAMPLE\_BITS must be same as that of I2S\_RX\_BITS\_MOD .

## 29.10.2 Data Format Control

Data format is controlled in the following phases:

- Phase I: serial input data is converted into the data to be saved to RX FIFO.
- Phase II: the data is read from RX FIFO and converted according to input data mode.

## 29.10.2.1 Bit Order Control of Channel Data

The channel data will be stored as the data to be input in order from high to low. The data bit order in each channel is controlled by I2S\_RX\_BIT\_ORDER:

- 0: The bit order of the data to be input is not reversed;
- 1: The bit order of the data to be input is reversed.

At this point, the first phase of data format control is complete.

## 29.10.2.2 Bit Width Control of Channel Storage (Valid) Data

The storage data width in each channel is controlled by I2S\_RX\_BITS\_MOD and I2S\_RX\_24\_FILL\_EN, see the table below.

Table 29.10-1. Channel Storage Data Width

| Channel Storage Data Width   |   I2S_RX_BITS_MOD | I2S_RX_24_FILL_EN   |
|------------------------------|-------------------|---------------------|
| 32                           |                31 | x                   |
|                              |                23 | 1                   |
| 24                           |                23 | 0                   |
| 16                           |                15 | x                   |
| 8                            |                 7 | x                   |

## 29.10.2.3 Bit Width Control of Channel RX Data

The RX data width in each channel is determined by I2S\_RX\_TDM\_CHAN\_BITS .

- If the storage data width in each channel is smaller than the received (RX) data width, then only the bits within the storage data width is saved into memory. Configure I2S\_RX\_LEFT\_ALIGN to:
- – 0: only the lower bits of the received data within the storage data width is stored to memory.
- – 1: only the higher bits of the received data within the storage data width is stored to memory.
- If the received data width is smaller than the storage data width in each channel, the higher bits of the received data will be filled with zeros and then the data is saved to memory.

## 29.10.2.4 Endian Control of Channel Storage Data

The received data is then converted into storage data (to be stored to memory) after some processing, such as discarding extra bits or filling zeros in missing bits. The endian of the storage data is controlled by I2S\_RX\_BIG\_ENDIAN under various data width, see the table below.

Table 29.10-2. Channel Storage Data Endian

|   Channel Storage Data Width | Origin Data      | Endian of Processed Data   | I2S_RX_BIG_ENDIAN   |
|------------------------------|------------------|----------------------------|---------------------|
|                           32 | {B3, B2, B1, B0} | {B3, B2, B1, B0}           | 0                   |
|                           32 | {B3, B2, B1, B0} | {B0, B1, B2, B3}           | 1                   |
|                           24 | {B2, B1, B0}     | {B2, B1, B0}               | 0                   |
|                           24 | {B2, B1, B0}     | {B0, B1, B2}               | 1                   |
|                           16 | {B1, B0}         | {B1, B0}                   | 0                   |
|                           16 | {B1, B0}         | {B0, B1}                   | 1                   |
|                            8 | {B0}             | {B0}                       | x                   |

## 29.10.2.5 A-law/µ-law Compression and Decompression

ESP32-C3 I2S compresses/decompresses the storage data in 32-bit by A-law or by µ-law. By default, zeros are filled into high bits.

Configure I2S\_RX\_PCM\_BYPASS to:

- 0: compress or decompress the data.
- 1: do not compress or decompress the data.

Configure I2S\_RX\_PCM\_CONF to:

- 0: decompress the data using A-law.
- 1: compress the data using A-law.
- 2: decompress the data using µ-law.
- 3: compress the data using µ-law.

At this point, the data format control is complete. Data then is stored into memory via DMA.

## 29.11 Software Configuration Process

## 29.11.1 Configure I2S as TX Mode

Follow the steps below to configure I2S as TX mode via software:

1. Configure the clock as described in Section 29.6 .
2. Configure signal pins according to Table 29.4-1 .
3. Select the mode needed by configuring the bit I2S\_TX\_SLAVE\_MOD .
- 0: master TX mode
- 1: slave TX mode
4. Set needed TX data mode and TX channel mode as described in Section 29.9, and then set the bit I2S\_TX\_UPDATE .
5. Reset TX unit and TX FIFO as described in Section 29.7 .
6. Enable corresponding interrupts, see Section 29.12 .
7. Configure DMA outlink.
8. Set I2S\_TX\_STOP\_EN if needed. For more information, please refer to Section 29.8.1 .
9. Start transmitting data:
- In master mode, wait till I2S slave gets ready, then set I2S\_TX\_START to start transmitting data.
- In slave mode, set the bit I2S\_TX\_START. When the I2S master supplies BCK and WS signals, I2S slave starts transmitting data.
10. Wait for the interrupt signals set in Step 6, or check whether the transfer is completed by querying I2S\_TX\_IDLE:
- 0: transmitter is working.

- 1: transmitter is in idle.
11. Clear I2S\_TX\_START to stop data transfer.

## 29.11.2 Configure I2S as RX Mode

Follow the steps below to configure I2S as RX mode via software:

1. Configure the clock as described in Section 29.6 .
2. Configure signal pins according to Table 29.4-1 .
3. Select the mode needed by configuring the bit I2S\_RX\_SLAVE\_MOD .
- 0: master RX mode
- 1: slave RX mode
4. Set needed RX data mode and RX channel mode as described in Section 29.10, and then set the bit I2S\_RX\_UPDATE .
5. Reset RX unit and its FIFO according to Section 29.7 .
6. Enable corresponding interrupts, see Section 29.12 .
7. Configure DMA inlink, and set the length of RX data in I2S\_RXEOF\_NUM\_REG .
8. Start receiving data:
- In master mode, when the slave is ready, set I2S\_RX\_START to start receiving data.
- In slave mode, set I2S\_RX\_START to start receiving data when get BCK and WS signals from the master.
9. The received data is then stored to the specified address of ESP32-C3 memory according the configuration of DMA. Then the corresponding interrupt set in Step 6 is generated.

## 29.12 I2S Interrupts

- I2S\_TX\_HUNG\_INT: triggered when transmitting data is timed out. For example, if module is configured as TX slave mode, but the master does not provide BCK or WS signal for a long time (specified in I2S\_LC\_HUNG\_CO
- NF\_REG), then this interrupt will be triggered.
- I2S\_RX\_HUNG\_INT: triggered when receiving data is timed out. For example, if I2S module is configured as RX slave mode, but the master does not send data for a long time (specified in I2S\_LC\_HUNG\_CONF\_REG), then this interrupt will be triggered.
- I2S\_TX\_DONE\_INT: triggered when transmitting data is completed.
- I2S\_RX\_DONE\_INT: triggered when receiving data is completed.

## 29.13 Register Summary

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                   | Description                                      | Address                             | Access                              |
|----------------------------------------|--------------------------------------------------|-------------------------------------|-------------------------------------|
| Interrupt registers                    |                                                  |                                     |                                     |
| I2S_INT_RAW_REG                        | I2S interrupt raw register                       | 0x000C                              | RO/WTC/SS                           |
| I2S_INT_ST_REG                         | I2S interrupt status register                    | 0x0010                              | RO                                  |
| I2S_INT_ENA_REG                        | I2S interrupt enable register                    | 0x0014                              | R/W                                 |
| I2S_INT_CLR_REG                        | I2S interrupt clear register                     | 0x0018                              | WT                                  |
| RX control and configuration registers | RX control and configuration registers           |                                     |                                     |
| I2S_RX_CONF_REG                        | I2S RX configuration register                    | 0x0020                              | varies                              |
| I2S_RX_CONF1_REG                       | I2S RX configuration register 1                  | 0x0028                              | R/W                                 |
| I2S_RX_CLKM_CONF_REG                   | I2S RX clock configuration register              | 0x0030                              | R/W                                 |
| I2S_TX_PCM2PDM_CONF_REG                | I2S TX PCM-to-PDM configuration register         | 0x0040                              | R/W                                 |
| I2S_TX_PCM2PDM_CONF1_REG               | I2S TX PCM-to-PDM configuration register 1       | 0x0044                              | R/W                                 |
| I2S_RX_TDM_CTRL_REG                    | I2S TX TDM mode control register                 | 0x0050                              | R/W                                 |
| I2S_RXEOF_NUM_REG                      | I2S RX data number control register              | 0x0064                              | R/W                                 |
| TX control and configuration registers | TX control and configuration registers           |                                     |                                     |
| I2S_TX_CONF_REG                        | I2S TX configuration register                    | 0x0024                              | varies                              |
| I2S_TX_CONF1_REG                       | I2S TX configuration register 1                  | 0x002C                              | R/W                                 |
| I2S_TX_CLKM_CONF_REG                   | I2S TX clock configuration register              | 0x0034                              | R/W                                 |
| I2S_TX_TDM_CTRL_REG                    | I2S TX TDM mode control register                 | 0x0054                              | R/W                                 |
| RX clock and timing registers          | RX clock and timing registers                    | RX clock and timing registers       | RX clock and timing registers       |
| I2S_RX_CLKM_DIV_CONF_REG               | I2S RX unit clock divider configuration register | 0x0038                              | R/W                                 |
| I2S_RX_TIMING_REG                      | I2S RX timing control register                   | 0x0058                              | R/W                                 |
| TX clock and timing registers          | TX clock and timing registers                    | TX clock and timing registers       | TX clock and timing registers       |
| I2S_TX_CLKM_DIV_CONF_REG               | I2S TX unit clock divider configuration register | 0x003C                              | R/W                                 |
| I2S_TX_TIMING_REG                      | I2S TX timing control register                   | 0x005C                              | R/W                                 |
| Control and configuration registers    | Control and configuration registers              | Control and configuration registers | Control and configuration registers |
| I2S_LC_HUNG_CONF_REG                   | I2S timeout configuration register               | 0x0060                              | R/W                                 |
| I2S_CONF_SIGLE_DATA_REG                | I2S single data register                         | 0x0068                              | R/W                                 |
| TX status register                     | TX status register                               | TX status register                  | TX status register                  |
| I2S_STATE_REG                          | I2S TX status register                           | 0x006C                              | RO                                  |
| Version register                       | Version register                                 | Version register                    | Version register                    |
| I2S_DATE_REG                           | Version control register                         | 0x0080                              | R/W                                 |

## 29.14 Registers

## Register 29.1. I2S\_INT\_RAW\_REG (0x000C)

![Image](images/29_Chapter_29_img011_6d973c7c.png)

I2S\_RX\_DONE\_INT\_RAW The raw interrupt status bit for I2S\_RX\_DONE\_INT interrupt. (RO/WTC/SS)

I2S\_TX\_DONE\_INT\_RAW The raw interrupt status bit for I2S\_TX\_DONE\_INT interrupt. (RO/WTC/SS)

I2S\_RX\_HUNG\_INT\_RAW The raw interrupt status bit for I2S\_RX\_HUNG\_INT interrupt. (RO/WTC/SS)

I2S\_TX\_HUNG\_INT\_RAW The raw interrupt status bit for I2S\_TX\_HUNG\_INT interrupt. (RO/WTC/SS)

## Register 29.2. I2S\_INT\_ST\_REG (0x0010)

![Image](images/29_Chapter_29_img012_673a5fd5.png)

## Register 29.3. I2S\_INT\_ENA\_REG (0x0014)

![Image](images/29_Chapter_29_img013_05b2523e.png)

I2S\_RX\_DONE\_INT\_ENA The interrupt enable bit for I2S\_RX\_DONE\_INT interrupt. (R/W)

I2S\_TX\_DONE\_INT\_ENA The interrupt enable bit for I2S\_TX\_DONE\_INT interrupt. (R/W)

I2S\_RX\_HUNG\_INT\_ENA The interrupt enable bit for I2S\_RX\_HUNG\_INT interrupt. (R/W)

I2S\_TX\_HUNG\_INT\_ENA The interrupt enable bit for I2S\_TX\_HUNG\_INT interrupt. (R/W)

## Register 29.4. I2S\_INT\_CLR\_REG (0x0018)

![Image](images/29_Chapter_29_img014_e9a514ae.png)

I2S\_RX\_DONE\_INT\_CLR Set this bit to clear I2S\_RX\_DONE\_INT interrupt. (WT)

I2S\_TX\_DONE\_INT\_CLR Set this bit to clear I2S\_TX\_DONE\_INT interrupt. (WT)

I2S\_RX\_HUNG\_INT\_CLR Set this bit to clear I2S\_RX\_HUNG\_INT interrupt. (WT)

I2S\_TX\_HUNG\_INT\_CLR Set this bit to clear I2S\_TX\_HUNG\_INT interrupt. (WT)

Register 29.5. I2S\_RX\_CONF\_REG (0x0020)

![Image](images/29_Chapter_29_img015_371d6672.png)

- I2S\_RX\_RESET Set this bit to reset RX unit. (WT)
- I2S\_RX\_FIFO\_RESET Set this bit to reset RX FIFO. (WT)
- I2S\_RX\_START Set this bit to start receiving data. (R/W)
- I2S\_RX\_SLAVE\_MOD Set this bit to enable slave RX mode. (R/W)
- I2S\_RX\_MONO Set this bit to enable RX unit in mono mode. (R/W)
- I2S\_RX\_BIG\_ENDIAN I2S RX byte endian. 1: low address data is saved to high address. 0: low address data is saved to low address. (R/W)
- I2S\_RX\_UPDATE Set 1 to update I2S RX registers from APB clock domain to I2S RX clock domain. This bit will be cleared by hardware after register update is done. (R/W/SC)
- I2S\_RX\_MONO\_FST\_VLD 1: The first channel data is valid in I2S RX mono mode. 0: The second channel data is valid in I2S RX mono mode. (R/W)
- I2S\_RX\_PCM\_CONF I2S RX compress/decompress configuration bit. 0 (atol): A-law decompress, 1 (ltoa): A-law compress, 2 (utol): µ-law decompress, 3 (ltou): µ-law compress. (R/W)
- I2S\_RX\_PCM\_BYPASS Set this bit to bypass Compress/Decompress module for received data. (R/W)
- I2S\_RX\_STOP\_MODE 0: I2S RX stops only when I2S\_RX\_START is cleared. 1: I2S RX stops when I2S\_RX\_START is 0 or in\_suc\_eof is 1. 2: I2S RX stops when I2S\_RX\_START is 0 or RX FIFO is full. (R/W)
- I2S\_RX\_LEFT\_ALIGN 1: I2S RX left alignment mode. 0: I2S RX right alignment mode. (R/W)
- I2S\_RX\_24\_FILL\_EN 1: store 24-bit channel data to 32 bits (Extra bits are filled with zeros). 0: store 24-bit channel data to 24 bits. (R/W)
- I2S\_RX\_WS\_IDLE\_POL 0: WS remains low when receiving left channel data, and remains high when receiving right channel data. 1: WS remains high when receiving left channel data, and remains low when receiving right channel data. (R/W)
- I2S\_RX\_BIT\_ORDER Configures whether to reverse the bit order of the I2S RX data to be received. 0: Not reverse. 1: Reverse. (R/W)
- I2S\_RX\_TDM\_EN 1: Enable I2S TDM RX mode. 0: Disable I2S TDM RX mode. (R/W)
- I2S\_RX\_PDM\_EN 1: Enable I2S PDM RX mode. 0: Disable I2S PDM RX mode. (R/W)

Register 29.6. I2S\_RX\_CONF1\_REG (0x0028)

![Image](images/29_Chapter_29_img016_3163f29d.png)

- I2S\_RX\_TDM\_WS\_WIDTH The width of rx\_ws\_out (WS default level) in TDM mode is (I2S\_RX\_TDM\_WS\_WIDTH + 1) * T\_BCK. (R/W)
- I2S\_RX\_BCK\_DIV\_NUM Configure the divider of BCK in RX mode. Note this divider must not be configured to 1. (R/W)
- I2S\_RX\_BITS\_MOD Configure the valid data bit length of I2S RX channel. 7: all the valid channel data is in 8-bit mode. 15: all the valid channel data is in 16-bit mode. 23: all the valid channel data is in 24-bit mode. 31: all the valid channel data is in 32-bit mode. (R/W)
- I2S\_RX\_HALF\_SAMPLE\_BITS I2S RX half sample bits. This value x 2 is equal to the BCK cycles in one WS period. (R/W)
- I2S\_RX\_TDM\_CHAN\_BITS Configure RX bit number for each channel in TDM mode. Bit number expected = this value + 1. (R/W)
- I2S\_RX\_MSB\_SHIFT Control the timing between WS signal and the MSB of data. 1: WS signal changes one BCK clock earlier. 0: Align at rising edge. (R/W)
- I2S\_RX\_CLKM\_DIV\_NUM Integral I2S clock divider value. (R/W)
- I2S\_RX\_CLK\_ACTIVE Clock enable signal of I2S RX unit. (R/W)
- I2S\_RX\_CLK\_SEL Select clock source for I2S RX unit. 0: XTAL\_CLK. 1: PLL\_D2\_CLK. 2: PLL\_F160M\_CLK. 3: I2S\_MCLK\_in. (R/W)
- I2S\_MCLK\_SEL 0: Use I2S TX unit clock as I2S\_MCLK\_OUT. 1: Use I2S RX unit clock as I2S\_MCLK\_OUT. (R/W)

Register 29.7. I2S\_RX\_CLKM\_CONF\_REG (0x0030)

![Image](images/29_Chapter_29_img017_73532866.png)

## Register 29.8. I2S\_TX\_PCM2PDM\_CONF\_REG (0x0040)

![Image](images/29_Chapter_29_img018_c9190353.png)

I2S\_TX\_PDM\_SINC\_OSR2 I2S TX PDM OSR value. (R/W)

I2S\_TX\_PDM\_DAC\_2OUT\_EN 0: 1-line DAC output mode. 1: 2-line DAC output mode. Only valid when I2S\_TX\_PDM\_DAC\_MODE\_EN is set. (R/W)

I2S\_TX\_PDM\_DAC\_MODE\_EN 0: 1-line PDM output mode. 1: DAC output mode. (R/W)

I2S\_PCM2PDM\_CONV\_EN Enable bit for I2S TX PCM-to-PDM conversion. (R/W)

## Register 29.9. I2S\_TX\_PCM2PDM\_CONF1\_REG (0x0044)

![Image](images/29_Chapter_29_img019_6ac65290.png)

I2S\_TX\_PDM\_FS I2S PDM TX upsampling parameter. (R/W)

## Register 29.10. I2S\_RX\_TDM\_CTRL\_REG (0x0050)

![Image](images/29_Chapter_29_img020_ab2ce85f.png)

I2S\_RX\_TDM\_PDM\_CHANn\_EN (n = 0 - 7) 1: Enable the valid data input of I2S RX TDM or PDM channel n. 0: Disable. Channel n only inputs 0. (R/W)

I2S\_RX\_TDM\_CHANn\_EN (n = 8 - 15) 1: Enable the valid data input of I2S RX TDM channel n. 0:

Disable. Channel n only inputs 0. (R/W)

I2S\_RX\_TDM\_TOT\_CHAN\_NUM The total number of channels in use in I2S RX TDM mode. Total channel number in use = this value + 1. (R/W)

## Register 29.11. I2S\_RXEOF\_NUM\_REG (0x0064)

![Image](images/29_Chapter_29_img021_647321f5.png)

I2S\_RX\_EOF\_NUM The bit length of RX data is (I2S\_RX\_BITS\_MOD + 1) * (I2S\_RX\_EOF\_NUM + 1). Once the length of received data reaches such bit length, an in\_suc\_eof interrupt is triggered in the configured DMA RX channel. (R/W)

## Register 29.12. I2S\_TX\_CONF\_REG (0x0024)

![Image](images/29_Chapter_29_img022_3b62dd28.png)

- I2S\_TX\_RESET Set this bit to reset TX unit. (WT)
- I2S\_TX\_FIFO\_RESET Set this bit to reset TX FIFO. (WT)
- I2S\_TX\_START Set this bit to start transmitting data. (R/W)
- I2S\_TX\_SLAVE\_MOD Set this bit to enable slave TX mode. (R/W)
- I2S\_TX\_MONO Set this bit to enable TX unit in mono mode. (R/W)
- I2S\_TX\_CHAN\_EQUAL 1: The left channel data is equal to right channel data in I2S TX mono mode or TDM mode. 0: The invalid channel data is I2S\_SINGLE\_DATA in I2S TX mono mode or TDM mode. (R/W)
- I2S\_TX\_BIG\_ENDIAN I2S TX byte endian. 1: low address data is saved to high address. 0: low address data is saved to low address. (R/W)
- I2S\_TX\_UPDATE Set 1 to update I2S TX registers from APB clock domain to I2S TX clock domain. This bit will be cleared by hardware after register update is done. (R/W/SC)
- I2S\_TX\_MONO\_FST\_VLD 1: The first channel data is valid in I2S TX mono mode. 0: The second channel data is valid in I2S TX mono mode. (R/W)
- I2S\_TX\_PCM\_CONF I2S TX compress/decompress configuration bits. 0 (atol): A-law decompress, 1 (ltoa): A-law compress, 2 (utol): µ-law decompress, 3 (ltou): µ-law compress. (R/W)
- I2S\_TX\_PCM\_BYPASS Set this bit to bypass Compress/Decompress module for transmitted data. (R/W)
- I2S\_TX\_STOP\_EN Set this bit to stop outputting BCK signal and WS signal when TX FIFO is empty. (R/W)
- I2S\_TX\_LEFT\_ALIGN 1: I2S TX left alignment mode. 0: I2S TX right alignment mode. (R/W)
- I2S\_TX\_24\_FILL\_EN 1: Sent 32 bits in 24-bit channel data mode. (Extra bits are filled with zeros). 0: Sent 24 bits in 24-bit channel data mode. (R/W)
- I2S\_TX\_WS\_IDLE\_POL 0: WS remains low when sending left channel data, and remains high when sending right channel data. 1: WS remains high when sending left channel data, and remains low when sending right channel data. (R/W)
- I2S\_TX\_BIT\_ORDER Configures whether to reverse the bit order of valid data to be sent by the I2S TX. 0: Not reverse. 1: Reverse. (R/W)
- I2S\_TX\_TDM\_EN 1: Enable I2S TDM TX mode. 0: Disable I2S TDM TX mode. (R/W)

## Register 29.12. I2S\_TX\_CONF\_REG (0x0024)

## Continued from the previous page...

I2S\_TX\_PDM\_EN 1: Enable I2S PDM TX mode. 0: Disable I2S PDM TX mode. (R/W)

- I2S\_TX\_CHAN\_MOD I2S TX channel configuration bits. For more information, see Table 29.9-4 . (R/W)
- I2S\_SIG\_LOOPBACK Enable signal loop back mode with TX unit and RX unit sharing the same WS and BCK signals. (R/W)
- I2S\_TX\_TDM\_WS\_WIDTH The width of tx\_ws\_out (WS default level) in TDM mode is (I2S\_TX\_TDM\_WS\_WIDTH + 1) * T\_BCK. (R/W)
- I2S\_TX\_BCK\_DIV\_NUM Configure the divider of BCK in TX mode. Note this divider must not be configured to 1. (R/W)
- I2S\_TX\_BITS\_MOD Set the bits to configure the valid data bit length of I2S TX channel. 7: all the valid channel data is in 8-bit mode. 15: all the valid channel data is in 16-bit mode. 23: all the valid channel data is in 24-bit mode. 31: all the valid channel data is in 32-bit mode. (R/W)
- I2S\_TX\_HALF\_SAMPLE\_BITS I2S TX half sample bits. This value x 2 is equal to the BCK cycles in one WS period. (R/W)
- I2S\_TX\_TDM\_CHAN\_BITS Configure TX bit number for each channel in TDM mode. Bit number expected = this value + 1. (R/W)
- I2S\_TX\_MSB\_SHIFT Control the timing between WS signal and the MSB of data. 1: WS signal changes one BCK clock earlier. 0: Align at rising edge. (R/W)
- I2S\_TX\_BCK\_NO\_DLY 1: BCK is not delayed to generate rising/falling edge in master mode. 0: BCK is delayed to generate rising/falling edge in master mode. (R/W)

Register 29.13. I2S\_TX\_CONF1\_REG (0x002C)

![Image](images/29_Chapter_29_img023_d0046e63.png)

![Image](images/29_Chapter_29_img024_cbf9eb99.png)

## Register 29.14. I2S\_TX\_CLKM\_CONF\_REG (0x0034)

![Image](images/29_Chapter_29_img025_ee2e195d.png)

I2S\_TX\_CLKM\_DIV\_NUM Integral I2S TX clock divider value. (R/W)

I2S\_TX\_CLK\_ACTIVE I2S TX unit clock enable signal. (R/W)

I2S\_TX\_CLK\_SEL Select clock clock for I2S TX unit. 0: XTAL\_CLK. 1: PLL\_D2\_CLK. 2: PLL\_F160M\_CLK. 3: I2S\_MCLK\_in. (R/W)

I2S\_CLK\_EN Set this bit to enable clock gate. (R/W)

## Register 29.15. I2S\_TX\_TDM\_CTRL\_REG (0x0054)

![Image](images/29_Chapter_29_img026_d61c292c.png)

- I2S\_TX\_TDM\_CHANn\_EN (n = 0 - 15) 1: Enable the valid data output of I2S TX TDM channel n . 0: Channel TX data is controlled by I2S\_TX\_CHAN\_EQUAL and I2S\_SINGLE\_DATA. See Section 29.9.2.1. (R/W)
- I2S\_TX\_TDM\_TOT\_CHAN\_NUM Set the total number of channels in use in I2S TX TDM mode. Total channel number in use = this value + 1. (R/W)
- I2S\_TX\_TDM\_SKIP\_MSK\_EN When DMA TX buffer stores the data of (I2S\_TX\_TDM\_TOT\_CHAN\_NUM + 1) channels, and only the data of the enabled channels is sent, then this bit should be set. Clear it when all the data stored in DMA TX buffer is for enabled channels. (R/W)

## Register 29.16. I2S\_RX\_CLKM\_DIV\_CONF\_REG (0x0038)

![Image](images/29_Chapter_29_img027_86aeb54e.png)

- I2S\_RX\_CLKM\_DIV\_Z For b &lt;= a/2, the value of I2S\_RX\_CLKM\_DIV\_Z is b. For b &gt; a/2, the value of I2S\_RX\_CLKM\_DIV\_Z is (a - b). (R/W)
- I2S\_RX\_CLKM\_DIV\_Y For b &lt;= a/2, the value of I2S\_RX\_CLKM\_DIV\_Y is (a%b). For b &gt; a/2, the value of I2S\_RX\_CLKM\_DIV\_Y is (a%(a - b)). (R/W)
- I2S\_RX\_CLKM\_DIV\_X For b &lt;= a/2, the value of I2S\_RX\_CLKM\_DIV\_X is floor(a/b) - 1. For b &gt; a/2, the value of I2S\_RX\_CLKM\_DIV\_X is floor(a/(a - b)) - 1. (R/W)
- I2S\_RX\_CLKM\_DIV\_YN1 For b &lt;= a/2, the value of I2S\_RX\_CLKM\_DIV\_YN1 is 0. For b &gt; a/2, the value of I2S\_RX\_CLKM\_DIV\_YN1 is 1. (R/W)

## Note:

"a" and "b" represent the denominator and the numerator of fractional divider, respectively. For more information, see Section 29.6 .

## Register 29.17. I2S\_RX\_TIMING\_REG (0x0058)

![Image](images/29_Chapter_29_img028_ddb89e13.png)

- I2S\_RX\_SD\_IN\_DM The delay mode of I2S RX SD input signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_RX\_WS\_OUT\_DM The delay mode of I2S RX WS output signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_RX\_BCK\_OUT\_DM The delay mode of I2S RX BCK output signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_RX\_WS\_IN\_DM The delay mode of I2S RX WS input signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_RX\_BCK\_IN\_DM The delay mode of I2S RX BCK input signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)

## Register 29.18. I2S\_TX\_CLKM\_DIV\_CONF\_REG (0x003C)

![Image](images/29_Chapter_29_img029_1b6e7030.png)

- I2S\_TX\_CLKM\_DIV\_Z For b &lt;= a/2, the value of I2S\_TX\_CLKM\_DIV\_Z is b. For b &gt; a/2, the value of I2S\_TX\_CLKM\_DIV\_Z is (a - b). (R/W)
- I2S\_TX\_CLKM\_DIV\_Y For b &lt;= a/2, the value of I2S\_TX\_CLKM\_DIV\_Y is (a%b). For b &gt; a/2, the value of I2S\_TX\_CLKM\_DIV\_Y is (a%(a - b)). (R/W)
- I2S\_TX\_CLKM\_DIV\_X For b &lt;= a/2, the value of I2S\_TX\_CLKM\_DIV\_X is floor(a/b) - 1. For b &gt; a/2, the value of I2S\_TX\_CLKM\_DIV\_X is floor(a/(a - b)) - 1. (R/W)
- I2S\_TX\_CLKM\_DIV\_YN1 For b &lt;= a/2, the value of I2S\_TX\_CLKM\_DIV\_YN1 is 0. For b &gt; a/2, the value of I2S\_TX\_CLKM\_DIV\_YN1 is 1. (R/W)

## Note:

"a" and "b" represent the denominator and the numerator of fractional divider, respectively. For more information, see Section 29.6 .

## Register 29.19. I2S\_TX\_TIMING\_REG (0x005C)

![Image](images/29_Chapter_29_img030_d6f98ee7.png)

- I2S\_TX\_SD\_OUT\_DM The delay mode of I2S TX SD output signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_TX\_SD1\_OUT\_DM The delay mode of I2S TX SD1 output signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_TX\_WS\_OUT\_DM The delay mode of I2S TX WS output signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_TX\_BCK\_OUT\_DM The delay mode of I2S TX BCK output signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_TX\_WS\_IN\_DM The delay mode of I2S TX WS input signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)
- I2S\_TX\_BCK\_IN\_DM The delay mode of I2S TX BCK input signal. 0: bypass. 1: delay by rising edge. 2: delay by falling edge. 3: not used. (R/W)

## Register 29.20. I2S\_LC\_HUNG\_CONF\_REG (0x0060)

![Image](images/29_Chapter_29_img031_e27411ae.png)

- I2S\_LC\_FIFO\_TIMEOUT I2S\_TX\_HUNG\_INT or I2S\_RX\_HUNG\_INT interrupt will be triggered when FIFO hung counter is equal to this value. (R/W)
- I2S\_LC\_FIFO\_TIMEOUT\_SHIFT The bits are used to scale tick counter threshold. The tick counter is reset when counter value &gt;= 88000/2 I2S \_ LC \_ F IF O \_ T IMEOUT \_ SHIF T . (R/W)
- I2S\_LC\_FIFO\_TIMEOUT\_ENA The enable bit for FIFO timeout. (R/W)

![Image](images/29_Chapter_29_img032_d4c5279a.png)

![Image](images/29_Chapter_29_img033_6d3cf911.png)
