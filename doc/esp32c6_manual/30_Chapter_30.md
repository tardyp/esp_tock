---
chapter: 30
title: "Chapter 30"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 30

## I2S Controller (I2S)

## 30.1 Overview

ESP32-C6 has a built-in I2S interface, which provides a flexible communication interface for streaming digital data in multimedia applications, especially digital audio applications.

The I2S standard bus defines three signals: a bit clock signal (BCK), a channel/word select signal (WS), and a serial data signal (SD). A basic I2S data bus has one master and one slave. The roles remain unchanged throughout the communication. The I2S module on ESP32-C6 provides separate transmit (TX) and receive (RX) units for high performance.

## 30.2 Terminology

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

## 30.3 Features

The I2S module has the following features:

- Master mode and slave mode
- Full-duplex and half-duplex communications
- Separate TX and RX units that can work independently or simultaneously
- A variety of audio standards supported:
- – TDM Philips standard
- – TDM MSB alignment standard
- – TDM PCM standard
- – PDM standard
- Configurable high-precision sample clock:
- – Supports the following frequencies: 8 kHz, 16 kHz, 32 kHz, 44.1 kHz, 48 kHz, 88.2 kHz, 96 kHz, 128 kHz, and 192 kHz (Note that in slave mode, due to the frequency limitation of the clock source, the maximum sampling frequency is limited by the data bit width and number of channels. For detailed information, refer to Section 30.6)
- 8-/16-/24-/32-bit data communication
- Direct Memory Access (DMA)
- Standard I2S interface interrupts

## 30.4 System Architecture

Figure 30.4-1. ESP32-C6 I2S System Diagram

![Image](images/30_Chapter_30_img001_19f02dc8.png)

Figure 30.4-1 shows the structure of ESP32-C6 I2S module, consisting of:

- Transmit control unit (TX Unit)
- Receive control unit (RX Unit)
- Input and output timing unit (I/O Sync)
- Clock divider (Clock Generator)
- 64 x 32-bit TX FIFO
- 64 x 32-bit RX FIFO
- Compress/Decompress units

I2S module supports direct memory access (DMA) to internal memory. For more information, see Chapter 4 GDMA Controller (GDMA) .

Both the TX unit and the RX unit have a three-line interface that uses a bit clock line (BCK), a word select line (WS), and a serial data line (SD). The SD line of the TX unit is fixed as output, and the SD line of the RX unit as input. BCK and WS signal lines for TX unit and RX unit can be configured as master output mode or slave input mode.

The signal bus of I2S module is shown at the right part of Figure 30.4-1. The naming of these signals in RX and TX units follows the pattern: I2SA \_ B \_ C, such as I2SI \_ BCK \_ in .

- "A" represents the direction of data bus, which includes:
- – "I": input, receiving

- – "O": output, transmitting
- "B" represents the signal function, which includes:
- – BCK
- – WS
- – SD
- "C" represents the signal direction, which includes:
- – "in": input signal into I2S module
- – "out": output signal from I2S module

Table 30.4-1 provides a detailed description of I2S signals.

Table 30.4-1. I2S Signal Description

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

Any required signals of I2S must be mapped to the chip's pins via GPIO matrix. For more information, see Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) .

## 30.5 Supported Audio Standards

ESP32-C6 I2S supports multiple audio standards, including TDM Philips standard, TDM MSB alignment standard, TDM PCM standard, and PDM standard.

Select the needed standard by configuring the following bits:

- I2S\_TX/RX\_TDM\_EN
- – 0: disable TDM mode.
- – 1: enable TDM mode.

WS(LRCK)

BCK(SCLK)

SD(SDOUT)

Left Channels

- I2S\_TX/RX\_PDM\_EN
- – 0: disable PDM mode.
- – 1: enable PDM mode.
- I2S\_TX/RX\_MSB\_SHIFT
- – 0: WS and SD signals change simultaneously, i.e., enable MSB alignment standard.

‹ Channel n -

- – 1: WS signal changes one BCK clock cycle earlier than SD signal, i.e., enable Philips standard or select PCM standard.
- I2S\_TX/RX\_PCM\_BYPASS
- – 0: enable PCM standard.
- – 1: disable PCM standard.

## 30.5.1 TDM Philips Standard

Philips specifications require that WS signal changes one BCK clock cycle earlier than SD signal on BCK falling edge, which means that WS signal is valid from one clock cycle before transmitting the first bit of channel data and changes one clock before the end of channel data transfer. SD signal line transmits the most significant bit of audio data first.

Compared with Philips standard, TDM Philips standard supports multiple channels. See Figure 30.5-1 .

Figure 30.5-1. TDM Philips Standard Timing Diagram

![Image](images/30_Chapter_30_img002_83bb82b5.png)

## 30.5.2 TDM MSB Alignment Standard

MSB alignment specifications require that WS and SD signals change simultaneously on the falling edge of BCK. The WS signal is valid until the end of channel data transfer. The SD signal line transmits the most significant bit of audio data first.

Compared with MSB alignment standard, TDM MSB alignment standard supports multiple channels. See Figure 30.5-2 .

![Image](images/30_Chapter_30_img003_625213f3.png)

1 SCLK

Right Channels

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

Figure 30.5-2. TDM MSB Alignment Standard Timing Diagram

![Image](images/30_Chapter_30_img004_185806de.png)

## 30.5.3 TDM PCM Standard

Short frame synchronization under PCM standard requires that WS signal changes one BCK clock cycle earlier than SD signal on the falling edge of BCK, which means that the WS signal becomes valid one clock cycle before transferring the first bit of channel data and remains unchanged in this BCK clock cycle. SD signal line transmits the most significant bit of audio data first.

Compared with PCM standard, TDM PCM standard supports multiple channels. See Figure 30.5-3 .

Figure 30.5-3. TDM PCM Standard Timing Diagram

![Image](images/30_Chapter_30_img005_4afcb482.png)

## 30.5.4 PDM Standard

Under PDM standard, WS signal changes continuously during data transmission. The low-level and high-level of this signal indicates the left channel and right channel respectively. WS and SD signals change simultaneously on the falling edge of BCK. See Figure 30.5-4 .

![Image](images/30_Chapter_30_img006_c728e15e.png)

WS(LRCK)

BCK(SCLK)

SD(SDOUT)-

Figure 30.5-4. PDM Standard Timing Diagram

![Image](images/30_Chapter_30_img007_2b8f9291.png)

## 30.6 I2S TX/RX Clock

I2S\_TX/RX\_CLK is the master clock of I2S TX/RX unit, divided from:

- 40 MHz XTAL\_CLK
- 160 MHz PLL\_F160M\_CLK
- 240 MHz PLL\_F240M\_CLK
- or external input clock: I2S\_MCLK\_in

The serial clock (BCK) of the I2S TX/RX unit is divided from I2S\_TX/RX\_CLK, as shown in Figure 30.6-1 . PCR\_I2S\_TX/RX\_CLKM\_SEL is used to select clock source for TX/RX unit, and PCR\_I2S\_TX/RX\_CLKM\_EN to enable or disable the clock source.

![Image](images/30_Chapter_30_img008_c4159997.png)

Figure 30.6-1. I2S Clock Generator

![Image](images/30_Chapter_30_img009_4e882b00.png)

The following formula shows the relation between I2S\_TX/RX\_CLK frequency fI2S\_TX/RX\_CLK and the divider clock source frequency fI2S\_CLK\_S:

<!-- formula-not-decoded -->

N is an integer value between 2 and 256. The value of N corresponds to the value of PCR\_I2S\_TX/RX\_CLKM\_DIV\_NUM in register PCR\_I2S\_TX/RX\_CLKM\_CONF\_REG as follows:

- When PCR\_I2S\_TX/RX\_CLKM\_DIV\_NUM = 0, N = 256;
- When PCR\_I2S\_TX/RX\_CLKM\_DIV\_NUM = 1, N = 2;
- When PCR\_I2S\_TX/RX\_CLKM\_DIV\_NUM has any other value, N = PCR\_I2S\_TX/RX\_CLKM\_DIV\_NUM .

The values of "a" and "b" in fractional divider depend only on x, y, z, and yn1. The corresponding formulas are as follows:

- When b &lt;= a 2 , yn1 = 0, x = floor([ a b ]) − 1, y = a%b, z = b;
- When b &gt; a 2 , yn1 = 1, x = floor([ a a - b ]) − 1, y = a%(a - b), z = a - b.

The values of x, y, z, and yn1 are configured in PCR\_I2S\_TX/RX\_CLKM\_DIV\_X , PCR\_I2S\_TX/RX\_CLKM\_DIV\_Y , PCR\_I2S\_TX/RX\_CLKM\_DIV\_Z, and PCR\_I2S\_TX/RXCLKM\_DIV\_YN1 .

To configure the integer divider, clear PCR\_I2S\_TX/RX\_CLKM\_DIV\_X and PCR\_I2S\_TX/RX\_CLKM\_DIV\_Z, then set PCR\_I2S\_TX/RX\_CLKM\_DIV\_Y to 1.

## Note:

Using fractional divider may introduce some clock jitter.

In master TX mode, the serial clock BCK for I2S TX unit is I2SO\_BCK\_out divided from I2S\_TX\_CLK, which is:

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

“MO” is an integer value:

## Note:

Note that I2S\_TX\_BCK\_DIV\_NUM must not be configured as 1.

In master RX mode, the serial clock BCK for I2S RX unit is I2SI\_BCK\_out divided from I2S\_RX\_CLK, which is:

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

“MI” is an integer value:

## Note:

- I2S\_RX\_BCK\_DIV\_NUM must not be configured as 1.
- In I2S slave mode, make sure fI2S\_TX/RX\_CLK &gt;= 8 * fBCK. The I2S module can output I2S\_MCLK\_out as the master clock for peripherals.

## 30.7 I2S Reset

The units and FIFOs in I2S module are reset by the following bits.

- I2S TX/RX units: reset by the bits I2S\_TX\_RESET and I2S\_RX\_RESET;
- I2S TX/RX FIFO: reset by the bits I2S\_TX\_FIFO\_RESET and I2S\_RX\_FIFO\_RESET .

## Note:

The I2S module clock must be configured first before the module and FIFO are reset.

## 30.8 I2S Master/Slave Mode

The ESP32-C6 I2S module can operate as a master or a slave in half-duplex and full-duplex communications, depending on the configuration of I2S\_RX\_SLAVE\_MOD and I2S\_TX\_SLAVE\_MOD .

- I2S\_TX\_SLAVE\_MOD
- – 0: master TX mode
- – 1: slave TX mode
- I2S\_RX\_SLAVE\_MOD
- – 0: master RX mode
- – 1: slave RX mode

## 30.8.1 Master/Slave TX Mode

- I2S works as a master transmitter:
- – Set I2S\_TX\_START to start transmitting data.
- – TX unit keeps driving the clock signal and serial data.
- – If I2S\_TX\_STOP\_EN is set and all the data in FIFO is transmitted, the master stops transmitting data and clock signals.
- – If I2S\_TX\_STOP\_EN is cleared and all the data in FIFO is transmitted, meanwhile no new data is filled into FIFO, then the TX unit keeps sending the last data frame and clock signal.
- – Master stops sending data when the bit I2S\_TX\_START is cleared.
- I2S works as a slave transmitter:
- – Set I2S\_TX\_START .

![Image](images/30_Chapter_30_img010_1b6edcfa.png)

- – Wait for the master BCK clock to enable a transmit operation.
- – If I2S\_TX\_STOP\_EN is set and all the data in FIFO is transmitted, then the slave keeps sending zeros, till the master stops providing BCK signal.
- – If I2S\_TX\_STOP\_EN is cleared and all the data in FIFO is transmitted, meanwhile no new data is filled into FIFO, then the TX unit keeps sending the last data frame.
- – If I2S\_TX\_START is cleared, slave keeps sending zeros till the master stops providing BCK clock signal.

## 30.8.2 Master/Slave RX Mode

- I2S works as a master receiver:
- – Set I2S\_RX\_START to start receiving data.
- – RX unit keeps outputting clock signal and sampling input data.
- – RX unit stops receiving data when the bit I2S\_RX\_START is cleared.
- I2S works as a slave receiver:
- – Set I2S\_RX\_START .
- – Wait for master BCK signal to start receiving data.
- – RX unit stops receiving data when the bit I2S\_RX\_START is cleared.

## 30.9 Transmitting Data

## Note:

Updating the configuration described in this and subsequent sections requires to set I2S\_TX\_UPDATE accordingly to synchronize registers from APB clock domain to TX clock domain. For more detailed configuration, see Section 30.11.1 .

In TX mode, I2S first reads data through DMA and sends these data out via output signals according to the configured data mode and channel mode.

## 30.9.1 Data Format Control

Data format is controlled in the following phases:

- Phase I: read data from memory and write it to TX FIFO;
- Phase II: read the data to send (TX data) from TX FIFO and convert the data according to the output data mode;
- Phase III: clock out the TX data serially.

## 30.9.1.1 Bit Width Control of Channel Valid Data

The bit width of valid data in each channel is determined by I2S\_TX\_BITS\_MOD and I2S\_TX\_24\_FILL\_EN. For details, see the table below.

Table 30.9-1. Bit Width of Channel Valid Data

| Channel Valid Data Width   |   I2S_TX_BITS_MOD | I2S_TX_24_FILL_EN   |
|----------------------------|-------------------|---------------------|
| 32                         |                31 | x *                 |
| 24                         |                23 | 1                   |
|                            |                23 | 0                   |
| 16                         |                15 | x                   |
| 8                          |                 7 | x                   |

## 30.9.1.2 Endian Control of Channel Valid Data

When I2S reads data through DMA, the data endian under various data width is controlled by I2S\_TX\_BIG\_ENDIAN. Table 30.9-2 shows how I2S\_TX\_BIG\_ENDIAN controls the data reading with different channel valid data widths.

Table 30.9-2. Endian of Channel Valid Data

|   Channel Valid Data Width | Original Data    | Endian of Processed Data   | I2S_TX_BIG_ENDIAN   |
|----------------------------|------------------|----------------------------|---------------------|
|                         32 | {B3, B2, B1, B0} | {B3, B2, B1, B0}           | 0                   |
|                         32 | {B3, B2, B1, B0} | {B0, B1, B2, B3}           | 1                   |
|                         24 | {B2, B1, B0}     | {B2, B1, B0}               | 0                   |
|                         24 | {B2, B1, B0}     | {B0, B1, B2}               | 1                   |
|                         16 | {B1, B0}         | {B1, B0}                   | 0                   |
|                         16 | {B1, B0}         | {B0, B1}                   | 1                   |
|                          8 | {B0}             | {B0}                       | x                   |

## Note:

B0, B1, B2, B3 each represents an 8-bit data, and the symbol {} means that the bytes are combined together. For example, {B3, B2, B1, B0} represents a 32-bit number, wherein B0 represents bit 0-7, B1 represents bit 8-15, B2 represents bit 16-23, and B3 represents bit 24-31.

## 30.9.1.3 A-law/µ-law Compression and Decompression

ESP32-C6 I2S compresses/decompresses the valid data into 32-bit by A-law or by µ-law. If the bit width of valid data is smaller than 32, zeros are filled to the extra high bits of the data to be compressed/decompressed by default.

## Note:

Extra high bits here mean the bits[31: channel valid data width] of the data to be compressed/decompressed.

## Configure I2S\_TX\_PCM\_BYPASS:

- 0: compress or decompress the data
- 1: do not compress or decompress the data

## Configure I2S\_TX\_PCM\_CONF:

- 0: decompress the data using A-law
- 1: compress the data using A-law
- 2: decompress the data using µ-law
- 3: compress the data using µ-law

At this point, the first phase of data format control is completed.

## 30.9.1.4 Bit Width Control of Channel TX Data

The TX data width in each channel is determined by I2S\_TX\_TDM\_CHAN\_BITS .

- If TX data width in each channel is larger than the valid data width, zeros will be filled to these extra bits. Configure I2S\_TX\_LEFT\_ALIGN:
- – 0: the valid data is at the lower bits of TX data. Zeros are filled into higher bits of TX data;
- – 1: the valid data is at the higher bits of TX data. Zeros are filled into lower bits of TX data.
- If the TX data width in each channel is smaller than the valid data width, only the lower bits of valid data are sent out, and the higher bits are discarded.

At this point, the second phase of data format control is completed.

## 30.9.1.5 Bit Order Control of Channel Data

The data bit order in each channel is controlled by I2S\_TX\_BIT\_ORDER:

- 0: Not reverse the valid data bit order;
- 1: Reverse the valid data bit order.

At this point, the data format control is completed. The data after format control will be sent sequentially from high to low. Figure 30.9-1 shows the complete process of TX data format control.

12S\_TX\_BIG\_ENDIAN = 1

I2S\_TX\_TDM\_CHAN\_BITS = 31

12S\_TX\_LEFT\_ALIGN = 1

12S\_TX\_BIT\_ORDER = 1

B217:01 | B117:01 BO[7:0]

Figure 30.9-1. TX Data Format Control

![Image](images/30_Chapter_30_img011_e80713e7.png)

## 30.9.2 Channel Mode Control

ESP32-C6 I2S supports both TDM TX mode and PDM TX mode. Set I2S\_TX\_TDM\_EN to enable TDM TX mode, or set I2S\_TX\_PDM\_EN to enable PDM TX mode.

## Note:

- I2S\_TX\_TDM\_EN and I2S\_TX\_PDM\_EN must not be cleared or set simultaneously.
- Most stereo I2S codecs can be controlled by setting the I2S module into 2-channel mode under TDM standard.

## 30.9.2.1 I2S Channel Control in TDM TX Mode

In TDM TX mode, the total number of TX channels supported is related to the channel valid data width for I2S as follows:

Table 30.9-3. The Matching Between Valid Data Width and Number of TX Channel Supported

|   Channel Valid Data Width |   Total Number of Channels Supported |
|----------------------------|--------------------------------------|
|                         32 |                                    4 |
|                         24 |                                    5 |
|                         16 |                                    8 |
|                          8 |                                   16 |

The total number of TX channels in use is controlled by I2S\_TX\_TDM\_TOT\_CHAN\_NUM. For example, if I2S\_TX\_TDM\_TOT\_CHAN\_NUM is set to 5, six channels in total (channel 0 ~ 5) will be used to transmit data. See Figure 30.9-2 .

In these TX channels, if I2S\_TX\_TDM\_CHANn\_EN is set to:

- 1: this channel sends the channel data out;
- 0: the TX data to be sent by this channel is controlled by I2S\_TX\_CHAN\_EQUAL:
- – 1: the data of previous channel is sent out;
- – 0: the data stored in I2S\_SINGLE\_DATA is sent out.

In TDM TX master mode, WS signal is controlled by I2S\_TX\_WS\_IDLE\_POL and I2S\_TX\_TDM\_WS\_WIDTH:

- I2S\_TX\_WS\_IDLE\_POL: the default level of WS signal;
- I2S\_TX\_TDM\_WS\_WIDTH: the cycles the WS default level lasts for when transmitting all channel data.

I2S\_TX\_HALF\_SAMPLE\_BITS x 2 is equal to the BCK cycles in one WS period.

## TDM Channel Configuration Example

In this example, register configuration is as follows:

- I2S\_TX\_TDM\_CHAN\_NUM = 5, i.e., channel 0 ~ 5 are used to transmit data.
- I2S\_TX\_CHAN\_EQUAL = 1, i.e., that data of previous channel will be transmitted if the bit I2S\_TX\_TDM\_CHANn\_EN is cleared. n = 0 ~ 5.
- I2S\_TX\_TDM\_CHAN0/2/5\_EN = 1, i.e., these channels send their channel data out.
- I2S\_TX\_TDM\_CHAN1/3/4\_EN = 0, i.e., these channels send the previous channel data out.

Once the configuration is done, data is transmitted as follows.

![Image](images/30_Chapter_30_img012_e1caec88.png)

I2S\_TX\_TDM\_CHAN\_NUM = 5; I2S\_TX\_CHAN\_EQUAL = 1;

I2S\_TX\_TDM\_CHAN0\_EN = 1; I2S\_TX\_TDM\_CHAN1\_EN = 0; I2S\_TX\_TDM\_CHAN2\_EN = 1; I2S\_TX\_TDM\_CHAN3\_EN = 0; I2S\_TX\_TDM\_CHAN4\_EN = 0; I2S\_TX\_TDM\_CHAN5\_EN = 1;

Figure 30.9-2. TDM Channel Control

## 30.9.2.2 I2S Channel Control in PDM TX Mode

ESP32-C6 I2S supports two PDM TX modes, namely, normal PDM TX mode and PCM-to-PDM TX mode.

In PDM TX mode, fetching data through DMA is controlled by I2S\_TX\_MONO and I2S\_TX\_MONO\_FST\_VLD . See Table 30.9-4. Please configure the two bits according to the data stored in memory, be it the single-channel or dual-channel data.

![Image](images/30_Chapter_30_img013_9f2de54a.png)

Table 30.9-4. Data-Fetching Control in PDM Mode

| Data-Fetching Control Option                                                  | Mode        |   I2S_TX_MONO | I2S_TX_MONO_FST_VLD   |
|-------------------------------------------------------------------------------|-------------|---------------|-----------------------|
| Post data-fetching request to DMA at any edge of WS signal                    | Stereo mode |             0 | x                     |
| Post data-fetching request to DMA only at the second half period of WS signal | Mono mode   |             1 | 0                     |
| Post data-fetching request to DMA only at the first half period of WS signal  | Mono mode   |             1 | 1                     |

When the I2S is in PDM TX master mode, the default level of WS signal is controlled by I2S\_TX\_WS\_IDLE\_POL , and the WS signal frequency is half of the BCK signal frequency. The configuration of WS signal is similar to that of BCK signal. Please refer to Section 30.6 and Figure 30.6 .

In normal PDM TX mode, I2S channel mode is controlled by I2S\_TX\_CHAN\_MOD and I2S\_TX\_WS\_IDLE\_POL . See the table below.

Table 30.9-5. I2S Channel Control in Normal PDM TX Mode

| Channel Con trol Option   | Left Channel                     | Right Channel                   |   Mode Control Field1 | Channel Select Bit2   |
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

In PCM-to-PDM TX mode, the PCM data through DMA is converted to PDM data and then output in PDM signal format. Configure I2S\_PCM2PDM\_CONV\_EN to enable this mode. The register configuration for PCM-to-PDM TX mode is as follows:

- Configure 1-line PDM output format or 1-/2-line DAC output mode as the table below:

Table 30.9-6. PCM-to-PDM TX Mode

| Channel Output Format      |   I2S_TX_PDM_DAC_MODE_EN | I2S_TX_PDM_DAC_2OUT_EN   |
|----------------------------|--------------------------|--------------------------|
| 1-line PDM output format 1 |                        0 | x                        |
| 1-line DAC output format 2 |                        1 | 0                        |
| 2-line DAC output format   |                        1 | 1                        |

## Note:

1. The data above refers to the processed data after data format control instead of the original data.
2. The "Left" and "Right" represent channel data, and their bit widths are channel valid data width. Please refer to Section 30.9.1fi

Then the channel data is transmitted after channel mode control as follows.

## Note:

1. In PDM output format, SD data of two channels is sent out in one WS period.
2. In DAC output format, SD data of one channel is sent out in one WS period.
- Configure sampling frequency and upsampling rate:
4. In PCM-to-PDM TX mode, PDM clock frequency is equal to BCK frequency. The relation of sampling frequency (fSampling) and BCK frequency is as follows:

<!-- formula-not-decoded -->

Upsampling rate (OSR) is related to I2S\_TX\_PDM\_SINC\_OSR2 as follows:

<!-- formula-not-decoded -->

Sampling frequency fSampling is related to I2S\_TX\_PDM\_FS as follows:

<!-- formula-not-decoded -->

Configure the registers according to needed sampling frequency, upsampling rate, and PDM clock frequency.

## PDM Channel Configuration Example

In this example, the register configuration is as follows.

- I2S\_PCM2PDM\_CONV\_EN = 0, i.e., the normal PDM TX mode is selected.
- I2S\_TX\_MONO = 0, i.e., data is fetched from memory via DMA in both the high and low levels of WS.
- I2S\_TX\_CHAN\_MOD = 2, i.e., mono mode is selected, and the right channel data will be discarded.
- I2S\_TX\_WS\_IDLE\_POL = 1, i.e., both the left channel and right channel transmit the left channel data.

Once the configuration is done, assume that the data in memory after data format control is:

![Image](images/30_Chapter_30_img014_7e16501c.png)

| Left   | Right   | Left   | Right   | ...   | Left   | Right   |
|--------|---------|--------|---------|-------|--------|---------|

I2S\_TX\_CHAN\_MOD = 2; I2S\_TX\_WS\_IDLE\_POL = 1;

![Image](images/30_Chapter_30_img015_3601294b.png)

Figure 30.9-3. PDM Channel Control Example

## 30.10 Receiving Data

In RX mode, I2S first reads data from peripheral interface, and then stores the data into memory via DMA according to the configured channel mode and data mode.

## 30.10.1 Channel Mode Control

ESP32-C6 I2S supports both TDM RX mode and PDM RX mode. Set I2S\_RX\_TDM\_EN to enable TDM RX mode, or set I2S\_RX\_PDM\_EN to enable PDM RX mode.

## Note:

I2S\_RX\_TDM\_EN and I2S\_RX\_PDM\_EN must not be cleared or set simultaneously.

## 30.10.1.1 I2S Channel Control in TDM RX Mode

In TDM RX mode, the total number of RX channels supported is related to the channel valid data width for I2S as follows:

Table 30.10-1. The Matching Between Valid Data Width and Number of RX Channel Supported

|   Channel Valid Data Width |   Total Number of Channels Supported |
|----------------------------|--------------------------------------|
|                         32 |                                    4 |
|                         24 |                                    5 |
|                         16 |                                    8 |
|                          8 |                                   16 |

In TDM RX mode, I2S supports up to 16 channels to input data. The total number of RX channels in use is controlled by I2S\_RX\_TDM\_TOT\_CHAN\_NUM. For example, if I2S\_RX\_TDM\_TOT\_CHAN\_NUM is set to 5,

channel 0 ~ 5 will be used to receive data.

In these RX channels, if I2S\_RX\_TDM\_CHANn\_EN is set to:

- 1: this channel data is valid and will be stored into RX FIFO;
- 0: this channel data is invalid and will not be stored into RX FIFO.

In TDM master mode, WS signal is controlled by I2S\_RX\_WS\_IDLE\_POL and I2S\_RX\_TDM\_WS\_WIDTH .

- I2S\_RX\_WS\_IDLE\_POL: the default level of WS signal;
- I2S\_RX\_TDM\_WS\_WIDTH: the cycles the WS default level lasts for when receiving all channel data.

I2S\_RX\_HALF\_SAMPLE\_BITS x 2 is equal to the BCK cycles in one WS period.

## 30.10.1.2 I2S Channel Control in PDM RX Mode

In PDM RX mode, I2S converts the serial data from channels to the data to be entered into memory.

In PDM RX master mode, the default level of WS signal is controlled by I2S\_RX\_WS\_IDLE\_POL. WS frequency is half of BCK frequency. The configuration of BCK signal is similar to that of WS signal as described in Section 30.6. Note, in PDM RX mode, the value of I2S\_RX\_HALF\_SAMPLE\_BITS must be same as that of I2S\_RX\_BITS\_MOD .

## 30.10.2 Data Format Control

Data format is controlled in the following phases:

- Phase I: serial input data is converted into the data to be saved to RX FIFO;
- Phase II: the data is read from RX FIFO and converted according to the input data mode.

## 30.10.2.1 Bit Order Control of Channel Data

The channel data will be stored as the data to be input in order from high to low. The data bit order in each channel is controlled by I2S\_RX\_BIT\_ORDER:

- 0: The bit order of the data to be input is not reversed;
- 1: The bit order of the data to be input is reversed.

At this point, the first phase of data format control is completed.

## 30.10.2.2 Bit Width Control of Channel Storage (Valid) Data

The storage data width in each channel is controlled by I2S\_RX\_BITS\_MOD and I2S\_RX\_24\_FILL\_EN. See the table below.

Table 30.10-2. Channel Storage Data Width

| Channel Storage Data Width   |   I2S_RX_BITS_MOD | I2S_RX_24_FILL_EN   |
|------------------------------|-------------------|---------------------|
| 32                           |                31 | x                   |
|                              |                23 | 1                   |
| 24                           |                23 | 0                   |
| 16                           |                15 | x                   |
| 8                            |                 7 | x                   |

## 30.10.2.3 Bit Width Control of Channel RX Data

The RX data width in each channel is determined by I2S\_RX\_TDM\_CHAN\_BITS .

- If the storage data width in each channel is smaller than the received (RX) data width, then only the bits within the storage data width is saved into memory. Configure I2S\_RX\_LEFT\_ALIGN to:
- – 0: only the lower bits of the received data within the storage data width is stored to memory;
- – 1: only the higher bits of the received data within the storage data width is stored to memory.
- If the received data width is smaller than the storage data width in each channel, the higher bits of the received data will be filled with zeros and then the data is saved to memory.

## 30.10.2.4 Endian Control of Channel Storage Data

The received data is then converted into storage data (to be stored to memory) after some processing, such as discarding extra bits or filling zeros in missing bits. The endian of the storage data is controlled by I2S\_RX\_BIG\_ENDIAN under various data width. See the table below.

Table 30.10-3. Channel Storage Data Endian

|   Channel Storage Data Width | Original Data    | Endian of Processed Data   | I2S_RX_BIG_ENDIAN   |
|------------------------------|------------------|----------------------------|---------------------|
|                           32 | {B3, B2, B1, B0} | {B3, B2, B1, B0}           | 0                   |
|                           32 | {B3, B2, B1, B0} | {B0, B1, B2, B3}           | 1                   |
|                           24 | {B2, B1, B0}     | {B2, B1, B0}               | 0                   |
|                           24 | {B2, B1, B0}     | {B0, B1, B2}               | 1                   |
|                           16 | {B1, B0}         | {B1, B0}                   | 0                   |
|                           16 | {B1, B0}         | {B0, B1}                   | 1                   |
|                            8 | {B0}             | {B0}                       | x                   |

## 30.10.2.5 A-law/µ-law Compression and Decompression

ESP32-C6 I2S compresses/decompresses the storage data in 32-bit by A-law or by µ-law. By default, zeros are filled into high bits.

## Configure I2S\_RX\_PCM\_BYPASS:

- 0: compress or decompress the data
- 1: do not compress or decompress the data

## Configure I2S\_RX\_PCM\_CONF:

- 0: decompress the data using A-law
- 1: compress the data using A-law
- 2: decompress the data using µ-law
- 3: compress the data using µ-law

At this point, the data format control is completed. Data then is stored into memory via DMA.

## 30.11 Software Configuration Process

## 30.11.1 Configure I2S as TX Mode

Follow the steps below to configure I2S as TX mode via software:

1. Configure the clock as described in Section 30.6 .
2. Configure signal pins according to Table 30.4-1 .
3. Select the mode needed by configuring I2S\_TX\_SLAVE\_MOD .
- 0: master TX mode
- 1: slave TX mode
4. Set needed TX data mode and TX channel mode as described in Section 30.9, and then set I2S\_TX\_UPDATE .
5. Reset TX unit and TX FIFO as described in Section 30.7 .
6. Enable corresponding interrupts. See Section 30.12 .
7. Configure DMA outlink.
8. Set I2S\_TX\_STOP\_EN if needed. For more information, please refer to Section 30.8.1 .
9. Start transmitting data:
- In master mode, wait till I2S slave gets ready, then set I2S\_TX\_START to start transmitting data.
- In slave mode, set I2S\_TX\_START. When the I2S master supplies BCK and WS signals, I2S slave starts transmitting data.
10. Wait for the interrupt signals set in Step 6, or check whether the transfer is completed by querying I2S\_TX\_IDLE:
- 0: transmitter is working;
- 1: transmitter is in idle state.
11. Clear I2S\_TX\_START to stop data transfer.

## 30.11.2 Configure I2S as RX Mode

Follow the steps below to configure I2S as RX mode via software:

1. Configure the clock as described in Section 30.6 .

2. Configure signal pins according to Table 30.4-1 .
3. Select the mode needed by configuring I2S\_RX\_SLAVE\_MOD .
- 0: master RX mode
- 1: slave RX mode
4. Set needed RX data mode and RX channel mode as described in Section 30.10, and then set I2S\_RX\_UPDATE .
5. Reset RX unit and its FIFO according to Section 30.7 .
6. Enable corresponding interrupts. See Section 30.12 .
7. Configure DMA inlink, and set the length of RX data by configuring I2S\_RX\_EOF\_NUM\_REG .
8. Start receiving data:
- In master mode, when the slave is ready, set I2S\_RX\_START to start receiving data.
- In slave mode, set I2S\_RX\_START to start receiving data when get BCK and WS signals from the master.
9. The received data is then stored to the specified address of ESP32-C6 memory according the configuration of DMA. Then the corresponding interrupt set in step 6 is generated.

## 30.12 I2S Interrupts

- I2S\_TX\_HUNG\_INT: triggered when transmitting data is timed out. For example, if module is configured as TX slave mode, but the master does not provide BCK or WS signal for a long time (specified in I2S\_LC\_HUNG\_CONF\_REG), then this interrupt will be triggered.
- I2S\_RX\_HUNG\_INT: triggered when receiving data is timed out. For example, if I2S module is configured as RX slave mode, but the master does not send data for a long time (specified in I2S\_LC\_HUNG\_CONF\_REG), then this interrupt will be triggered.
- I2S\_TX\_DONE\_INT: triggered when transmitting data is completed.
- I2S\_RX\_DONE\_INT: triggered when receiving data is completed.

## 30.13 Event Task Matrix Feature

ESP32-C6 I2S supports the Event Task Matrix (ETM) function, which allows I2S's ETM tasks to be triggered by any peripherals' ETM events, or I2S's ETM events to trigger any peripherals' ETM tasks. This section introduces the ETM tasks and events related to I2S. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

I2S can receive the following ETM tasks:

- I2S\_TASK\_START\_TX: Enables I2S TX for data transfer.
- I2S\_TASK\_START\_RX: Enables I2S RX for data transfer.
- I2S\_TASK\_STOP\_TX: Stops I2S TX data transfer.

- I2S\_TASK\_STOP\_RX: Stops I2S RX data transfer.

I2S can generate the following ETM events:

- I2S\_EVT\_TX\_DONE: Indicates that I2S TX has completed data transmission.
- I2S\_EVT\_RX\_DONE: Indicates that I2S RX has completed data receiving.
- I2S\_EVT\_X\_WORDS\_SENT: Indicates that the word number sent by I2S TX is equal to or larger than the value set by I2S\_ETM\_TX\_SEND\_WORD\_NUM .
- I2S\_EVT\_X\_WORDS\_RECEIVED: Indicates that the word number received by I2S RX is equal to or larger than the value set by I2S\_ETM\_RX\_RECEIVE\_WORD\_NUM .

In practical applications, I2S's ETM events can trigger its own ETM tasks. For example, the I2S\_EVT\_X\_WORDS\_SENT event can trigger the I2S\_TASK\_STOP\_TX task, and in this way stop the I2S operation through ETM.

## 30.14 Register Summary

The addresses in this section are relative to I2S Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                   | Description                                | Address                             | Access                              |
|----------------------------------------|--------------------------------------------|-------------------------------------|-------------------------------------|
| Interrupt registers                    |                                            |                                     |                                     |
| I2S_INT_RAW_REG                        | I2S interrupt raw register                 | 0x000C                              | RO/WTC/SS                           |
| I2S_INT_ST_REG                         | I2S interrupt status register              | 0x0010                              | RO                                  |
| I2S_INT_ENA_REG                        | I2S interrupt enable register              | 0x0014                              | R/W                                 |
| I2S_INT_CLR_REG                        | I2S interrupt clear register               | 0x0018                              | WT                                  |
| RX control and configuration registers | RX control and configuration registers     |                                     |                                     |
| I2S_RX_CONF_REG                        | I2S RX configuration register              | 0x0020                              | varies                              |
| I2S_RX_CONF1_REG                       | I2S RX configuration register 1            | 0x0028                              | R/W                                 |
| I2S_TX_PCM2PDM_CONF_REG                | I2S TX PCM-to-PDM configuration register   | 0x0040                              | R/W                                 |
| I2S_TX_PCM2PDM_CONF1_REG               | I2S TX PCM-to-PDM configuration register 1 | 0x0044                              | R/W                                 |
| I2S_RX_TDM_CTRL_REG                    | I2S TX TDM mode control register           | 0x0050                              | R/W                                 |
| I2S_RXEOF_NUM_REG                      | I2S RX data number control register        | 0x0064                              | R/W                                 |
| TX control and configuration registers | TX control and configuration registers     |                                     |                                     |
| I2S_TX_CONF_REG                        | I2S TX configuration register              | 0x0024                              | varies                              |
| I2S_TX_CONF1_REG                       | I2S TX configuration register 1            | 0x002C                              | R/W                                 |
| I2S_TX_TDM_CTRL_REG                    | I2S TX TDM mode control register           | 0x0054                              | R/W                                 |
| RX timing register                     | RX timing register                         |                                     |                                     |
| I2S_RX_TIMING_REG                      | I2S RX timing control register             | 0x0058                              | R/W                                 |
| TX timing register                     | TX timing register                         |                                     |                                     |
| I2S_TX_TIMING_REG                      | I2S TX timing control register             | 0x005C                              | R/W                                 |
| Control and configuration registers    | Control and configuration registers        | Control and configuration registers | Control and configuration registers |
| I2S_LC_HUNG_CONF_REG                   | I2S timeout configuration register         | 0x0060                              | R/W                                 |
| I2S_CONF_SIGLE_DATA_REG                | I2S single data register                   | 0x0068                              | R/W                                 |
| TX status register                     | TX status register                         | TX status register                  | TX status register                  |
| I2S_STATE_REG                          | I2S TX status register                     | 0x006C                              | RO                                  |
| ETM register                           | ETM register                               | ETM register                        | ETM register                        |
| I2S_ETM_CONF_REG                       | I2S ETM configure register                 | 0x0070                              | R/W                                 |
| Version register                       | Version register                           | Version register                    | Version register                    |
| I2S_DATE_REG                           | Version control register                   | 0x0080                              | R/W                                 |

## 30.15 Registers

The addresses in this section are relative to I2S Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 30.1. I2S\_INT\_RAW\_REG (0x000C)

![Image](images/30_Chapter_30_img016_b261cadf.png)

- I2S\_RX\_DONE\_INT\_RAW The raw interrupt status of the I2S\_RX\_DONE\_INT interrupt. (RO/WTC/SS)
- I2S\_TX\_DONE\_INT\_RAW The raw interrupt status of the I2S\_TX\_DONE\_INT interrupt. (RO/WTC/SS)
- I2S\_RX\_HUNG\_INT\_RAW The raw interrupt status of the I2S\_RX\_HUNG\_INT interrupt. (RO/WTC/SS)
- I2S\_TX\_HUNG\_INT\_RAW The raw interrupt status of the I2S\_TX\_HUNG\_INT interrupt. (RO/WTC/SS)
- I2S\_RX\_DONE\_INT\_ST The masked interrupt status of the I2S\_RX\_DONE\_INT interrupt. (RO)
- I2S\_TX\_DONE\_INT\_ST The masked interrupt status of the I2S\_TX\_DONE\_INT interrupt. (RO)
- I2S\_RX\_HUNG\_INT\_ST The masked interrupt status of the I2S\_RX\_HUNG\_INT interrupt. (RO)

Register 30.2. I2S\_INT\_ST\_REG (0x0010)

![Image](images/30_Chapter_30_img017_e4b0a121.png)

I2S\_TX\_HUNG\_INT\_ST The masked interrupt status of the I2S\_TX\_HUNG\_INT interrupt. (RO)

## Register 30.3. I2S\_INT\_ENA\_REG (0x0014)

![Image](images/30_Chapter_30_img018_05b2523e.png)

I2S\_RX\_DONE\_INT\_ENA Write 1 to enable the I2S\_RX\_DONE\_INT interrupt. (R/W)

I2S\_TX\_DONE\_INT\_ENA Write 1 to enable the I2S\_TX\_DONE\_INT interrupt. (R/W)

I2S\_RX\_HUNG\_INT\_ENA Write 1 to enable the I2S\_RX\_HUNG\_INT interrupt. (R/W)

I2S\_TX\_HUNG\_INT\_ENA Write 1 to enable the I2S\_TX\_HUNG\_INT interrupt. (R/W)

## Register 30.4. I2S\_INT\_CLR\_REG (0x0018)

![Image](images/30_Chapter_30_img019_96349af1.png)

I2S\_RX\_DONE\_INT\_CLR Write 1 to clear the I2S\_RX\_DONE\_INT interrupt. (WT)

I2S\_TX\_DONE\_INT\_CLR Write 1 to clear the I2S\_TX\_DONE\_INT interrupt. (WT)

I2S\_RX\_HUNG\_INT\_CLR Write 1 to clear the I2S\_RX\_HUNG\_INT interrupt. (WT)

I2S\_TX\_HUNG\_INT\_CLR Write 1 to clear the I2S\_TX\_HUNG\_INT interrupt. (WT)

## Register 30.5. I2S\_RX\_CONF\_REG (0x0020)

![Image](images/30_Chapter_30_img020_211f0710.png)

- I2S\_RX\_RESET Configures whether to reset RX unit.
- 0: No effect
- 1: Reset
- (WT)
- I2S\_RX\_FIFO\_RESET Configures whether to reset RX FIFO.
- 0: No effect
- 1: Reset
- (WT)
- I2S\_RX\_START Configures whether to start receiving data.
- 0: No effect
- 1: Start
- (R/W/SC)
- I2S\_RX\_SLAVE\_MOD Configures whether to enable slave RX mode.
- 0: Disable
- 1: Enable
- (R/W)
- I2S\_RX\_MONO Configures whether to enable RX unit in mono mode.
- 0: Disable
- 1: Enable
- (R/W)
- I2S\_RX\_BIG\_ENDIAN Configures I2S RX byte endian.
- 0: Low address data is saved to low address
- 1: Low address data is saved to high address
- (R/W)
- I2S\_RX\_UPDATE Configures whether to update I2S RX registers from APB clock domain to I2S RX clock domain.
- 0: No effect
- 1: Update
- This bit will be cleared by hardware after the register update is done.
- (R/W/SC)

Continued on the next page...

## Register 30.5. I2S\_RX\_CONF\_REG (0x0020)

## Continued from the previous page...

- I2S\_RX\_MONO\_FST\_VLD Configures the valid data channel in I2S RX mono mode.
- 0: The second channel data valid
- 1: The first channel data valid

(R/W)

- I2S\_RX\_PCM\_CONF Configures I2S RX compress/decompress mode.
- I2S\_RX\_PCM\_BYPASS Configures whether to bypass the Compress/Decompress units for re-

- 0 (atol): A-law decompress

- 1 (ltoa): A-law compress

- 2 (utol): µ-law decompress

- 3 (ltou): µ-law compress

(R/W)

ceived data.

- 0: No effect
- 1: Bypass

(R/W)

- I2S\_RX\_STOP\_MODE Configures I2S RX stop mode.
- 0: I2S RX only stops when REG\_TXRX\_START is cleared
- 1: I2S RX stops when REG\_TXRX\_START is 0 or in\_suc\_eof is 1
- 2: I2S RX stops when REG\_TXRX\_START is 0 or RX FIFO is full (R/W)
- I2S\_RX\_LEFT\_ALIGN Configures I2S RX alignment mode.
- 0: Right alignment mode
- 1: Left alignment mode

(R/W)

- I2S\_RX\_24\_FILL\_EN Configures the bit number that the 24-bit channel data is stored to.
- 0: Store 24-bit channel data to 24 bits
- 1: Store 24-bit channel data to 32 bits (Extra bits are filled with zeros)

(R/W)

- I2S\_RX\_WS\_IDLE\_POL Configures the relationship between WS level and which channel data to receive.
- 0: WS remains low when receiving left channel data and high when receiving right channel data
- 1: WS remains high when receiving left channel data and low when receiving right channel data (R/W)

## Continued on the next page...

## Register 30.5. I2S\_RX\_CONF\_REG (0x0020)

## Continued from the previous page...

- I2S\_RX\_BIT\_ORDER Configures whether to reverse the bit order of the I2S RX data to be received.

0: Not reverse

1: Reverse

(R/W)

- I2S\_RX\_TDM\_EN Configures whether to enable I2S TDM RX mode.
- 0: Disable

1: Enable

(R/W)

- I2S\_RX\_PDM\_EN Configures whether to enable I2S PDM RX mode.
- 0: Disable
- 1: Enable

(R/W)

## Register 30.6. I2S\_RX\_CONF1\_REG (0x0028)

![Image](images/30_Chapter_30_img021_8e767d4b.png)

- I2S\_RX\_TDM\_WS\_WIDTH Configures the width of rx\_ws\_out (WS default level) in TDM mode. Width of rx\_ws\_out (WS default level) in TDM mode = (I2S\_RX\_TDM\_WS\_WIDTH[6:0] + 1) x T\_BCK. (R/W)
- I2S\_RX\_BCK\_DIV\_NUM Configures the divider of BCK in RX mode. Note this divider must not be configured to 1. (R/W)
- I2S\_RX\_BITS\_MOD Configures the valid data bit length of I2S RX channel.
- 7: All the valid channel data is in 8-bit mode
- 15: All the valid channel data is in 16-bit mode
- 23: All the valid channel data is in 24-bit mode
- 31: All the valid channel data is in 32-bit mode
- Other values are invalid.

(R/W)

- I2S\_RX\_HALF\_SAMPLE\_BITS Configures I2S RX sample bits. BCK cycles in one WS period = I2S\_RX\_HALF\_SAMPLE\_BITS x 2. (R/W)
- I2S\_RX\_TDM\_CHAN\_BITS Configures RX bit number for each channel in TDM mode. Bit number expected = I2S\_RX\_TDM\_CHAN\_BITS + 1. (R/W)
- I2S\_RX\_MSB\_SHIFT Configures the timing between WS signal and the MSB of data.
- 0: Align at rising edge
- 1: WS signal changes one BCK clock earlier

(R/W)

## Register 30.7. I2S\_TX\_PCM2PDM\_CONF\_REG (0x0040)

![Image](images/30_Chapter_30_img022_9bcbe9ff.png)

I2S\_TX\_PDM\_SINC\_OSR2 Configures I2S TX PDM OSR value. (R/W)

I2S\_TX\_PDM\_DAC\_2OUT\_EN Configures DAC output mode.

0: Enable 1-line DAC output mode

1: Enable 2-line DAC output mode

Only valid when I2S\_TX\_PDM\_DAC\_MODE\_EN is set.

(R/W)

## I2S\_TX\_PDM\_DAC\_MODE\_EN Configures whether to enable 1-line PDM output mode or DAC out-

put mode.

0: Enable 1-line PDM output mode

1: Enable DAC output mode

(R/W)

## I2S\_PCM2PDM\_CONV\_EN Configures whether to enable I2S TX PCM-to-PDM conversion.

0: Disable

1: Enable

(R/W)

## Register 30.8. I2S\_TX\_PCM2PDM\_CONF1\_REG (0x0044)

![Image](images/30_Chapter_30_img023_8f27964c.png)

I2S\_TX\_PDM\_FS Configures I2S PDM TX upsampling parameter. (R/W)

## Register 30.9. I2S\_RX\_TDM\_CTRL\_REG (0x0050)

![Image](images/30_Chapter_30_img024_f4436b71.png)

- I2S\_RX\_TDM\_PDM\_CHANn\_EN (n: 0-7) Configures whether to enable the valid data input of I2S RX TDM or PDM channel n . 0: Disable. Channel n only inputs 0 1: Enable (R/W)
- I2S\_RX\_TDM\_CHANn\_EN (n = 8-15) Configures whether to enable the valid data input of I2S RX TDM channel n . 0: Disable. Channel n only inputs 0 1: Enable (R/W)
- I2S\_RX\_TDM\_TOT\_CHAN\_NUM Configures the total number of channels in use in I2S RX TDM mode. Total channel number in use = I2S\_RX\_TDM\_TOT\_CHAN\_NUM + 1. (R/W)

## Register 30.10. I2S\_RXEOF\_NUM\_REG (0x0064)

![Image](images/30_Chapter_30_img025_676e0e0c.png)

I2S\_RX\_EOF\_NUM Configures the bit length of RX data. Bit length of RX data = (I2S\_RX\_BITS\_MOD + 1) x (I2S\_RX\_EOF\_NUM + 1). Once the received data reaches such bit length, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt is triggered in the configured DMA RX channel. (R/W)

## Register 30.11. I2S\_TX\_CONF\_REG (0x0024)

![Image](images/30_Chapter_30_img026_fcd9f575.png)

- I2S\_TX\_RESET Configures whether to reset TX unit.
- 0: No effect
- 1: Reset

(WT)

- I2S\_TX\_FIFO\_RESET Configures whether to reset TX FIFO.
- 0: No effect
- 1: Reset

(WT)

- I2S\_TX\_START Configures whether to start transmitting data.
- 0: No effect
- 1: Start

(R/W/SC)

- I2S\_TX\_SLAVE\_MOD Configures whether to enable slave TX mode.
- 0: Disable
- 1: Enable

(R/W)

- I2S\_TX\_MONO Configures whether to enable TX unit in mono mode.
- 0: Disable
- 1: Enable

(R/W)

- I2S\_TX\_CHAN\_EQUAL Configures whether to equalize left channel data and right channel data in I2S TX mono mode or TDM mode.
- 0: The I2S\_SINGLE\_DATA is invalid channel data in I2S TX mono mode or TDM mode
- 1: The left channel data is equal to right channel data in I2S TX mono mode or TDM mode (R/W)
- I2S\_TX\_BIG\_ENDIAN Configures I2S TX byte endian.
- 0: Low address with low address value
- 1: Low address value to high address
- (R/W)

Continued on the next page...

## Register 30.11. I2S\_TX\_CONF\_REG (0x0024)

## Continued from the previous page...

- I2S\_TX\_UPDATE Configures whether to update I2S TX registers from APB clock domain to I2S TX clock domain.
- 0: No effect

1: Update

This bit will be cleared by hardware after update register done.

(R/W/SC)

- I2S\_TX\_MONO\_FST\_VLD Configures the valid data channel in I2S TX mono mode.
- 0: The second channel data valid
- 1: The first channel data valid

(R/W)

- I2S\_TX\_PCM\_CONF Configures the I2S TX compress/decompress mode.
- 0 (atol): A-law decompress
- 1 (ltoa) : A-law compress
- 2 (utol) : µ-law decompress
- 3 (ltou) : µ-law compress

(R/W)

- I2S\_TX\_PCM\_BYPASS Configures whether to bypass Compress/Decompress units for transmitted

data.

- 0: No effect
- 1: Bypass

(R/W)

- I2S\_TX\_STOP\_EN Configures whether to stop outputting BCK signal and WS signal when TX FIFO
- is empty.
- 0: No effect
- 1: Stop

(R/W)

- I2S\_TX\_LEFT\_ALIGN Configures I2S TX alignment mode.
- 0: Right alignment mode
- 1: Left alignment mode

(R/W)

- I2S\_TX\_24\_FILL\_EN Configures the bit number that the 24 channel bits are stored to.
- 0: Store 24-bit channel data to 24 bits
- 1: Store 24-bit channel data to 32 bits (Extra bits are filled with zeros)

(R/W)

- I2S\_TX\_WS\_IDLE\_POL Configures the relationship between WS and which channel data to send.
- 0: WS remains low when sending left channel data and high when sending right channel data
- 1: WS remains high when sending left channel data and low when sending right channel data (R/W)

## Continued on the next page...

## Register 30.11. I2S\_TX\_CONF\_REG (0x0024)

## Continued from the previous page...

- I2S\_TX\_BIT\_ORDER Configures whether to reverse the bit order of valid data to be sent by the I2S

TX.

0: Not reverse

1: Reverse

(R/W)

- I2S\_TX\_TDM\_EN Configures whether to enable I2S TDM TX mode.
- 0: Disable

1: Enable

(R/W)

- I2S\_TX\_PDM\_EN Configures whether to enable I2S PDM TX mode.
- 0: Disable

1: Enable

(R/W)

- I2S\_TX\_CHAN\_MOD Configures I2S TX channel mode. For more information, see Table 30.9-5 . (R/W)
- I2S\_SIG\_LOOPBACK Configures whether to enable TX unit and RX unit sharing the same WS and BCK signals.
- 0: Disable

1: Enable

(R/W)

## Register 30.12. I2S\_TX\_CONF1\_REG (0x002C)

![Image](images/30_Chapter_30_img027_077c091e.png)

- I2S\_TX\_TDM\_WS\_WIDTH Configures the width of tx\_ws\_out (WS default level) in TDM mode. The width of tx\_ws\_out (WS default level) in TDM mode = (I2S\_TX\_TDM\_WS\_WIDTH[6:0] +1) x T\_BCK. (R/W)
- I2S\_TX\_BCK\_DIV\_NUM Configures the divider of BCK in TX mode. Note this divider must not be configured to 1. (R/W)
- I2S\_TX\_BITS\_MOD Configures the valid data bit length of I2S TX channel.
- 7: All the valid channel data is in 8-bit mode
- 15: All the valid channel data is in 16-bit mode
- 23: All the valid channel data is in 24-bit mode
- 31: All the valid channel data is in 32-bit mode

Other values are invalid.

(R/W)

- I2S\_TX\_HALF\_SAMPLE\_BITS Configures I2S TX sample bits. BCK cycles in one WS period = I2S\_TX\_HALF\_SAMPLE\_BITS x 2. (R/W)
- I2S\_TX\_TDM\_CHAN\_BITS Configures TX bit number for each channel in TDM mode. Bit number expected = I2S\_TX\_TDM\_CHAN\_BITS + 1. (R/W)
- I2S\_TX\_MSB\_SHIFT Configures the timing between WS signal and the MSB of data.
- 0: Align at rising edge
- 1: WS signal changes one BCK clock earlier

(R/W)

- I2S\_TX\_BCK\_NO\_DLY Configures whether BCK is delayed to generate rising/falling edge in master

mode.

- 0: Delayed

1: Not delayed

(R/W)

## Register 30.13. I2S\_TX\_TDM\_CTRL\_REG (0x0054)

![Image](images/30_Chapter_30_img028_12bab0b0.png)

- I2S\_TX\_TDM\_CHANn\_EN (n: 0-15) Configures whether to enable the valid data output of I2S TX TDM channel n .
- 0: Channel TX data is controlled by I2S\_TX\_CHAN\_EQUAL and I2S\_SINGLE\_DATA. See Section 30.9.2.1

1: Enable

(R/W)

- I2S\_TX\_TDM\_TOT\_CHAN\_NUM Configures the total number of channels in use in I2S TX TDM mode.

Total channel number in use = I2S\_TX\_TDM\_TOT\_CHAN\_NUM + 1. (R/W)

- I2S\_TX\_TDM\_SKIP\_MSK\_EN Configures the data to be sent in DMA TX buffer.
- 0: Data stored in DMA TX buffer is used by enabled channels and will not be read by channels that are not enabled.
- 1: Data stored in DMA TX buffer is read by all channels and will be skipped by channels that are not enabled.

(R/W)

## Register 30.14. I2S\_RX\_TIMING\_REG (0x0058)

![Image](images/30_Chapter_30_img029_f0b9c608.png)

- I2S\_RX\_SD\_IN\_DM Configures the delay mode of I2S RX SD input signal.
- 0: Bypass
- 1: Delay by rising edge
- 2: Delay by falling edge
- 3: Not used
- (R/W)
- I2S\_RX\_WS\_OUT\_DM Configures the delay mode of I2S RX WS output signal. For detailed configuration values, please refer to I2S\_RX\_SD\_IN\_DM. (R/W)
- I2S\_RX\_BCK\_OUT\_DM Configures the delay mode of I2S RX BCK output signal. For detailed configuration values, please refer to I2S\_RX\_SD\_IN\_DM. (R/W)
- I2S\_RX\_WS\_IN\_DM Configures the delay mode of I2S RX WS input signal. For detailed configuration values, please refer to I2S\_RX\_SD\_IN\_DM. (R/W)
- I2S\_RX\_BCK\_IN\_DM Configures the delay mode of I2S RX BCK input signal. For detailed configuration values, please refer to I2S\_RX\_SD\_IN\_DM. (R/W)

## Register 30.15. I2S\_TX\_TIMING\_REG (0x005C)

![Image](images/30_Chapter_30_img030_e4f81601.png)

- I2S\_TX\_SD\_OUT\_DM Configures the delay mode of I2S TX SD output signal.
- 0: Bypass
- 1: Delay by rising edge
- 2: Delay by falling edge
- 3: Not used

(R/W)

- I2S\_TX\_SD1\_OUT\_DM Configures the delay mode of I2S TX SD1 output signal. For detailed configuration values, please refer to I2S\_TX\_SD\_OUT\_DM. (R/W)
- I2S\_TX\_WS\_OUT\_DM Configures the delay mode of I2S TX WS output signal. For detailed configuration values, please refer to I2S\_TX\_SD\_OUT\_DM. (R/W)
- I2S\_TX\_BCK\_OUT\_DM Configures the delay mode of I2S TX BCK output signal. For detailed configuration values, please refer to I2S\_TX\_SD\_OUT\_DM. (R/W)
- I2S\_TX\_WS\_IN\_DM Configures the delay mode of I2S TX WS input signal. For detailed configuration values, please refer to I2S\_TX\_SD\_OUT\_DM. (R/W)
- I2S\_TX\_BCK\_IN\_DM Configures the delay mode of I2S TX BCK input signal. For detailed configuration values, please refer to I2S\_TX\_SD\_OUT\_DM. (R/W)

## Register 30.16. I2S\_LC\_HUNG\_CONF\_REG (0x0060)

![Image](images/30_Chapter_30_img031_20e6714f.png)

I2S\_LC\_FIFO\_TIMEOUT Configures FIFO timeout threshold. I2S\_TX\_HUNG\_INT or I2S\_RX\_HUNG\_INT interrupt will be triggered when FIFO hung counter is equal to this value. (R/W)

I2S\_LC\_FIFO\_TIMEOUT\_SHIFT Configures tick counter threshold. The tick counter is reset when counter value &gt;= 88000/2 I2S \_ LC \_ F IF O \_ T IMEOUT \_ SHIF T . (R/W)

- I2S\_LC\_FIFO\_TIMEOUT\_ENA Configures whether to enable FIFO timeout.

0: Disable

1: Enable

(R/W)

## Register 30.17. I2S\_CONF\_SIGLE\_DATA\_REG (0x0068)

![Image](images/30_Chapter_30_img032_f03e0818.png)

I2S\_SINGLE\_DATA Configures constant channel data to be sent out. (R/W)

## Register 30.18. I2S\_STATE\_REG (0x006C)

![Image](images/30_Chapter_30_img033_8ded71fb.png)

- I2S\_TX\_IDLE Represents the TX unit state.

0: I2S TX unit is working

1: I2S TX unit is in idle state

(RO)

## Register 30.19. I2S\_ETM\_CONF\_REG (0x0070)

![Image](images/30_Chapter_30_img034_a5c2b32e.png)

- I2S\_ETM\_TX\_SEND\_WORD\_NUM Configures the threshold of triggering ETM I2S\_TX\_X\_WORDS\_SENT event. When sending word number of I2S\_ETM\_TX\_SEND\_WORD\_NUM [9:0], I2S will trigger the corresponding ETM event. (R/W)
- I2S\_ETM\_RX\_RECEIVE\_WORD\_NUM Configures the threshold of triggering ETM I2S\_RX\_X\_WORDS\_RECEIVED event. When receiving word number of I2S\_ETM\_RX\_RECEIVE\_WORD\_NUM [9:0], I2S will trigger the corresponding ETM event. (R/W)

## Register 30.20. I2S\_DATE\_REG (0x0080)

I2S\_DATE Version control register. (R/W)

![Image](images/30_Chapter_30_img035_191f10d2.png)
