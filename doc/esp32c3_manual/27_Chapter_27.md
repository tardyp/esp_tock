---
chapter: 27
title: "Chapter 27"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 27

## SPI Controller (SPI)

## 27.1 Overview

The Serial Peripheral Interface (SPI) is a synchronous serial interface useful for communication with external peripherals. The ESP32-C3 chip integrates three SPI controllers:

- SPI0,
- SPI1,
- General Purpose SPI2 (GP-SPI2).

SPI0 and SPI1 controllers are primarily reserved for internal use. This chapter mainly focuses on the GP-SPI2 controller.

## 27.2 Glossary

To better illustrate the functions of GP-SPI2, the following terms are used in this chapter.

| Master Mode                     | GP-SPI2 acts as an SPI master and initiates SPI transactions.                                                                                                                                                 |
|---------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Slave Mode                      | GP-SPI2 acts as an SPI slave and transfers data with its master when its CS is asserted.                                                                                                                      |
| MISO                            | Master in, slave out, data transmission from a slave to a master.                                                                                                                                             |
| MOSI                            | Master out, slave in, data transmission from a master to a slave                                                                                                                                              |
| Transaction                     | One instance of a master asserting a CS line, transferring data to and from a slave, and de-asserting the CS line. Transactions are atomic, which means they can never be interrupted by another transaction. |
| SPI Transfer                    | The whole process of an SPI master exchanges data with a slave. One SPI transfer consists of one or more SPI transactions.                                                                                    |
| Single Transfer                 | An SPI transfer consists of only one transaction.                                                                                                                                                             |
| CPU-Controlled Transfer         | A data transfer happens between CPU buffer SPI_W0_REG  ~ SPI_W15_REG and SPI peripheral.                                                                                                                      |
| DMA-Controlled Transfer         | A data transfer happens between DMA and SPI peripheral, con trolled by DMA engine.                                                                                                                           |
| Configurable Segmented Transfer | A data transfer controlled by DMA in SPI master mode. Such transfer consists of multiple transactions (segments), and each of transactions can be configured independently.                                   |
| Slave Segmented Transfer        | A data transfer controlled by DMA in SPI slave mode. Such transfer consists of multiple transactions (segments).                                                                                              |

| Full-duplex        | The sending line and receiving line between the master and the slave are independent. Sending data and receiving data happen at the same time.               |
|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Half-duplex        | Only one side, the master or the slave, sends data first, and the other side receives data. Sending data and receiving data can not happen at the same time. |
| 4-line full-duplex | 4-line here means: clock line, CS line, and two data lines. The two data lines can be used to send or receive data simultaneously.                           |
| 4-line half-duplex | 4-line here means: clock line, CS line, and two data lines. The two data lines can not be used simultaneously.                                               |
| 3-line half-duplex | 3-line here means: clock line, CS line, and one data line. The data line is used to transmit or receive data.                                                |
| 1-bit SPI          | In one clock cycle, one bit can be transferred.                                                                                                              |
| (2-bit) Dual SPI   | In one clock cycle, two bits can be transferred.                                                                                                             |
| Dual Output Read   | A data mode of Dual SPI. In one clock cycle, one bit of a com mand, or one bit of an address, or two bits of data can be trans ferred.                     |
| Dual I/O Read      | Another data mode of Dual SPI. In one clock cycle, one bit of a command, or two bits of an address, or two bits of data can be transferred.                  |
| (4-bit) Quad SPI   | In one clock cycle, four bits can be transferred.                                                                                                            |
| Quad Output Read   | A data mode of Quad SPI. In one clock cycle, one bit of a com mand, or one bit of an address, or four bits of data can be trans ferred.                    |
| Quad I/O Read      | Another data mode of Quad SPI. In one clock cycle, one bit of a command, or four bits of an address, or four bits of data can be transferred.                |
| QPI                | In one clock cycle, four bits of a command, or four bits of an address, or four bits of data can be transferred.                                             |

## 27.3 Features

Some of the key features of GP-SPI2 are:

- Master and slave modes
- Half- and full-duplex communications
- CPU- and DMA-controlled transfers
- Various data modes:
- – 1-bit SPI mode
- – 2-bit Dual SPI mode
- – 4-bit Quad SPI mode
- – QPI mode
- Configurable module clock frequency:

- – Master: up to 80 MHz

- – Slave: up to 60 MHz

- Configurable data length:
- – CPU-controlled transfer in master mode or in slave mode: 1 ~ 64 B
- – DMA-controlled single transfer in master mode: 1 ~ 32 KB
- – DMA-controlled configurable segmented transfer in master mode: data length is unlimited
- – DMA-controlled single transfer or segmented transfer in slave mode: data length is unlimited
- Configurable bit read/write order
- Independent interrupts for CPU-controlled transfer and DMA-controlled transfer
- Configurable clock polarity and phase
- Four SPI clock modes: mode 0 ~ mode 3
- Six CS lines in master mode: CS0 ~ CS5
- Able to communicate with SPI devices, such as a sensor, a screen controller, as well as a flash or RAM chip

## 27.4 Architectural Overview

Figure 27.4-1. SPI Module Overview

![Image](images/27_Chapter_27_img001_3667529a.png)

Figure 27.4-1 shows an overview of SPI module. GP-SPI2 exchanges data with SPI devices by the following ways:

- CPU-controlled transfer: CPU ←&gt; GP-SPI2 ←&gt; SPI devices

- DMA-controlled transfer: GDMA ←&gt; GP-SPI2 ←&gt; SPI devices

The signals for GP-SPI2 are prefixed with "FSPI" (Fast SPI). FSPI bus signals are routed to GPIO pins via either GPIO matrix or IO MUX. For more information, see Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX) .

## 27.5 Functional Description

## 27.5.1 Data Modes

GP-SPI2 can be configured as either a master or a slave to communicate with other SPI devices in the following data modes, see Table 27.5-1 .

Table 27.5-1. Data Modes Supported by GP-SPI2

| Supported Mode   | Supported Mode   | CMD State   | Address State   | Data State   |
|------------------|------------------|-------------|-----------------|--------------|
| 1-bit SPI        | 1-bit SPI        | 1-bit       | 1-bit           | 1-bit        |
| Dual SPI         | Dual Output Read | 1-bit       | 1-bit           | 2-bit        |
| Dual SPI         | Dual I/O Read    | 1-bit       | 2-bit           | 2-bit        |
| Quad SPI         | Quad Output Read | 1-bit       | 1-bit           | 4-bit        |
| Quad SPI         | Quad I/O Read    | 1-bit       | 4-bit           | 4-bit        |
| QPI              | QPI              | 4-bit       | 4-bit           | 4-bit        |

For the states can be used in

- master mode, see Section 27.5.8 .
- slave mode, see Section 27.5.9 .

## 27.5.2 FSPI Bus Signal Mapping

The mapping of FSPI bus signals and the functional description of the signals are shown in Table 27.5-2 and in Table 27.5-3, respectively. The signals in one line in Table 27.5-2 corresponds to each other. For example, the signal FSPID is connected to MOSI in GP-SPI2 full-duplex communication, and FSPIQ to MISO. You can take Figure 27.5-6 as an example.

Table 27.5-2. Mapping of FSPI Bus Signals

| Standard SPI Protocol   | Standard SPI Protocol   | Extended SPI Protocol   |
|-------------------------|-------------------------|-------------------------|
| Full-Duplex  SPI Signal | Half-Duplex  SPI Signal | FSPI Bus Signal         |
| MOSI                    | MOSI                    | FSPID                   |
| MISO                    | (MISO)                  | FSPIQ                   |
| CS                      | CS                      | FSPICS0 ~ 5             |
| CLK                     | CLK                     | FSPICLK                 |
| —                       | —                       | FSPIWP                  |
| —                       | —                       | FSPIHD                  |

Table 27.5-3. Functional Description of FSPI Bus Signals

| FSPI Bus Signal   | Function                                       |
|-------------------|------------------------------------------------|
| FSPID             | MOSI/SIO0 (serial data input and output, bit0) |
| FSPIQ             | MISO/SIO1 (serial data input and output, bit1) |
| FSPIWP            | SIO2 (serial data input and output, bit2)      |
| FSPIHD            | SIO3 (serial data input and output, bit3)      |

Figure 27.5-4 shows the signals used in various SPI modes.

| FSPICLK     | Input and output clock in master/slave mode     |
|-------------|-------------------------------------------------|
| FSPICS0     | Input and output CS signal in master/slave mode |
| FSPICS1 ~ 5 | Output CS signal in master mode                 |

Chapter 27 SPI Controller (SPI)

QPI

Y

Y

4-bit Quad SPI

2-bit Dual SPI

Y

Y

Y

4-line HD

Y

Y

Y

3-line HD

1-bit SPI

Y

Y

Y

8

Y

7

Y

6

(Y)

Y

|                | FD   | FD        | FD   |
|----------------|------|-----------|------|
|                | Y    | Y         | Y    |
| QPI            | Y Y  | Y Y Y Y   | Y    |
|                |      | 5         | 5    |
|                | Y Y  | Y Y Y     | Y    |
| 4-bit Quad SPI |      | Y         |      |
|                | Y    | Y Y Y Y 4 | Y 4  |
| 2-bit Dual SPI | Y    |           |      |
| Master Mode    |      |           |      |

Y

Y

Y

Y

Y

3

(Y)

2

3-line HD Y Y Y Y Y Y Y Y

FD 1 Y Y Y Y Y Y Y Y

FSPI Signal

FSPICLK

FSPICS0

FSPICS1

FSPICS2

FSPICS3

FSPICS4

FSPICS5

Espressif Systems

FSPID

3

(Y)

Y

FSPIQ

FSPIWP

FSPIHD

FD: full-duplex

1

HD: half-duplex

2

Only one of the two signals is used at a time.

3

The two signals are used in parallel.

4

613

Submit Documentation Feedback

Table 27.5-4. Signals Used in Various SPI Modes

Slave Mode

1-bit SPI

Y

8

Y

7

Y

6

(Y)

Y

8

Y

Y

8

Y

The four signals are used in parallel.

5

Only one of the two signals is used at a time.

6

The two signals are used in parallel.

7

The four signals are used in parallel.

8

ESP32-C3 TRM (Version 1.3)

GoBack

## 27.5.3 Bit Read/Write Order Control

In master mode:

- The bit order of the command, address and data sent by the GP-SPI2 master is controlled by SPI\_WR\_BIT\_ORDER .
- The bit order of the data received by the master is controlled by SPI\_RD\_BIT\_ORDER .

## In slave mode:

- The bit order of the data sent by the GP-SPI2 slave is controlled by SPI\_WR\_BIT\_ORDER .
- The bit order of the command, address and data received by the slave is controlled by SPI\_RD\_BIT\_ORDER .

Table 27.5-5 shows the function of SPI\_RD/WR\_BIT\_ORDER .

Table 27.5-5. Bit Order Control in GP-SPI2 Master and Slave Modes

| Bit Mode   | FSPI Bus Data   | SPI_RD/WR_BIT_ORDER = 0 (MSB)   | SPI_RD/WR_BIT_ORDER = 1 (LSB)   |
|------------|-----------------|---------------------------------|---------------------------------|
| 1-bit mode | FSPID or FSPIQ  | B7→B6→B5→B4→B3→B2→B1→B0         | B0→B1→B2→B3→B4→B5→B6→B7         |
| 2-bit mode | FSPIQ           | B7→B5→B3→B1                     | B1→B3→B5→B7                     |
| 2-bit mode | FSPID           | B6→B4→B2→B0                     | B0→B2→B4→B6                     |
| 4-bit mode | FSPIHD          | B7→B3                           | B3→B7                           |
| 4-bit mode | FSPIWP          | B6→B2                           | B2→B6                           |
| 4-bit mode | FSPIQ           | B5→B1                           | B1→B5                           |
| 4-bit mode | FSPID           | B4→B0                           | B0→B4                           |

## 27.5.4 Transfer Modes

GP-SPI2 supports the following transfers when working as a master or a slave.

Table 27.5-6. Supported Transfers in Master and Slave Modes

| Mode   | Mode        | CPU-Controlled Single Transfer   | DMA-Controlled Single Transfer   | DMA-Controlled Configurable Segmented Transfer   | DMA-Controlled Slave Segmented Transfer   |
|--------|-------------|----------------------------------|----------------------------------|--------------------------------------------------|-------------------------------------------|
| Master | Full-Duplex | Y                                | Y                                | Y                                                | –                                         |
| Master | Half-Duplex | Y                                | Y                                | Y                                                | –                                         |
| Slave  | Full-Duplex | Y                                | Y                                | –                                                | Y                                         |
| Slave  | Half-Duplex | Y                                | Y                                | –                                                | Y                                         |

The following sections provide detailed information about the transfer modes listed in the table above.

## 27.5.5 CPU-Controlled Data Transfer

GP-SPI2 provides 16 x 32-bit data buffers, i.e., SPI\_W0\_REG ~ SPI\_W15\_REG, see Figure 27.5-1 . CPU-controlled transfer indicates the transfer, in which the data to send is from GP-SPI2 data buffer and the received data is stored to GP-SPI2 data buffer. In such transfer, every single transaction needs to be triggered by the CPU, after its related registers are configured. For such reason, the CPU-controlled transfer is always

single transfers (consisting of only one transaction). CPU-controlled mode supports full-duplex communication and half-duplex communication.

Figure 27.5-1. Data Buffer Used in CPU-Controlled Transfer

![Image](images/27_Chapter_27_img002_9879a72d.png)

## 27.5.5.1 CPU-Controlled Master Mode

In a CPU-controlled master full-duplex or half-duplex transfer, the RX or TX data is saved to or sent from SPI\_W0\_REG ~ SPI\_W15\_REG. The bits SPI\_USR\_MOSI\_HIGHPART and SPI\_USR\_MISO\_HIGHPART control which buffers are used, see the list below.

- TX data
- – When SPI\_USR\_MOSI\_HIGHPART is cleared, i.e., high part mode is disabled, TX data is from SPI\_W0\_REG ~ SPI\_W15\_REG and the data address is incremented by 1 on each byte transferred. If the data byte length is larger than 64, the data in SPI\_W0\_REG[7:0] ~ SPI\_W15\_REG[31:24] may be sent more than once. For instance, if 66 bytes (byte0 ~ byte65) need to be sent, then the address of byte65 is the result of (65 % 64 = 1), i.e., byte65 is from SPI\_W0\_REG[15:8], and byte64 is from SPI\_W0\_REG[7:0]. In this case, the content of SPI\_W0\_REG[15:0] may be sent more than once.
- – When SPI\_USR\_MOSI\_HIGHPART is set, i.e., high part mode is enabled, TX data is from SPI\_W8\_REG ~ SPI\_W15\_REG and the data address is incremented by 1 on each byte transferred. If the data byte length is larger than 32, the data in SPI\_W8\_REG[7:0] ~ SPI\_W15\_REG[31:24] may be sent more than once.

## · RX data

- – When SPI\_USR\_MISO\_HIGHPART is cleared, i.e., high part mode is disabled, RX data is saved to SPI\_W0\_REG ~ SPI\_W15\_REG, and the data address is incremented by 1 on each byte transferred. If the data byte length is larger than 64, the data in SPI\_W0\_REG[7:0] ~ SPI\_W15\_REG[31:24] may be overwritten. For instance, when 66 bytes (byte0 ~ byte65) are received, byte65 and byte64 are stored to the addresses of (65 % 64 = 1) and (64 % 64 = 0), i.e., SPI\_W0\_REG[15:8] and SPI\_W0\_REG[7:0]. In this case, the content of SPI\_W0\_REG[15:0] may be overwritten.
- – When SPI\_USR\_MISO\_HIGHPART is set, i.e., high part mode is enabled, the RX data is saved to SPI\_W8\_REG ~ SPI\_W15\_REG, and the data address is incremented by 1 on each byte transferred. If the data byte length is larger than 32, the content of SPI\_W8\_REG ~ SPI\_W15\_REG may be overwritten.

## Note:

- TX/RX data address mentioned above both are byte-addressable. Address 0 stands for SPI\_W0\_REG[7:0], and Address 1 for SPI\_W0\_REG[15:8], and so on. The largest address is SPI\_W15\_REG[31:24].
- To avoid any possible error in TX/RX data, such as TX data being sent more than once or RX data being overwritten, please make sure the registers are configured correctly.

## 27.5.5.2 CPU-Controlled Slave Mode

In a CPU-controlled slave full-duplex or half-duplex transfer, the RX data or TX data is saved to or sent from SPI\_W0\_REG ~ SPI\_W15\_REG, which are byte-addressable.

- In full-duplex communication, the address of SPI\_W0\_REG ~ SPI\_W15\_REG starts from 0 and is incremented by 1 on each byte transferred. If the data address is larger than 63, the content of SPI\_W15\_REG[31:24] is overwritten.
- In half-duplex communication, the ADDR value in transmission format is the start address of the RX or TX data, corresponding to the registers SPI\_W0\_REG ~ SPI\_W15\_REG. The RX or TX address is incremented by 1 on each byte transferred. If the address is larger than 63 (the highest byte address, i.e. SPI\_W15\_REG[31:24]), the address of overflowing data is always 63 and only the content of SPI\_W15\_REG[31:24] is overwritten.

According to your applications, the registers SPI\_W0\_REG ~ SPI\_W15\_REG can be used as:

- data buffers only
- data buffers and status buffers
- status buffers only

## 27.5.6 DMA-Controlled Data Transfer

DMA-controlled transfer refers to the transfer, in which GDMA RX module receives data and GDMA TX module sends data. This transfer is supported both in master mode and in slave mode.

A DMA-controlled transfer can be

- a single transfer, consisting of only one transaction. GP-SPI2 supports this transfer both in master and slave modes.
- a configurable segmented transfer, consisting of several transactions (segments). GP-SPI2 supports this transfer only in master mode. For more information, see Section 27.5.8.5 .
- a slave segmented transfer, consisting of several transactions (segments). GP-SPI2 supports this transfer only in slave mode. For more information, see Section 27.5.9.3 .

A DMA-controlled transfer only needs to be triggered once by CPU. When such transfer is triggered, data is transferred by the GDMA engine from or to the DMA-linked memory, without CPU operation.

DMA-controlled mode supports full-duplex communication, half-duplex communication and functions described in Section 27.5.8 and Section 27.5.9. Meanwhile, the GDMA RX module is independent from the GDMA TX module, which means that there are four kinds of full-duplex communications:

- Data is received in DMA-controlled mode and sent in DMA-controlled mode.

- Data is received in DMA-controlled mode but sent in CPU-controlled mode.
- Data is received in CPU-controlled mode but sent in DMA-controlled mode.
- Data is received in CPU-controlled mode and sent in CPU-controlled mode.

## 27.5.6.1 GDMA Configuration

- Select a GDMA channeln, and configure a GDMA TX/RX descriptor, see Chapter 2 GDMA Controller (GDMA) .
- Set the bit GDMA\_INLINK\_START\_CHn or GDMA\_OUTLINK\_START\_CHn to start GDMA RX/TX engine.
- Before all the GDMA TX buffer is used or the GDMA TX engine is reset, if GDMA\_OUTLINK\_RESTART\_CHn is set, a new TX buffer will be added to the end of the last TX buffer in use.
- GDMA RX buffer is linked in the same way as the GDMA TX buffer, by setting GDMA\_INLINK\_START\_CHn or GDMA\_INLINK\_RESTART\_CHn .
- The TX and RX data lengths are determined by the configured GDMA TX and RX buffer respectively, both of which are 0 ~ 32 KB.
- Initialize GDMA inlink and outlink before GDMA starts. The bits SPI\_DMA\_RX\_ENA and SPI\_DMA\_TX\_ENA in register SPI\_DMA\_CONF\_REG should be set, otherwise the read/write data will be stored to/sent from the registers SPI\_W0\_REG ~ SPI\_W15\_REG .

In master mode, if GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA is set, then the interrupt GDMA\_IN\_SUC\_EOF\_CHn\_INT will be triggered when one single transfer or one configurable segmented transfer is finished.

The only difference between DMA-controlled transfers in master mode and in slave mode is on the GDMA RX control:

- When the bit SPI\_RX\_EOF\_EN is cleared, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt may be generated after the CS is pulled high once:
- – In a slave single transfer, if SPI\_DMA\_SLV\_SEG\_TRANS\_EN is cleared and GDMA\_IN\_SUC\_EOF\_CHn\_INT
- \_ENA is set, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt will be triggered once the single transfer is done.
- – In a slave segmented transfer, if both SPI\_DMA\_SLV\_SEG\_TRANS\_EN and GDMA\_IN\_SUC\_EOF\_CHn \_ INT\_ENA are set, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt also is triggered once the command
- (CMD7 or End\_SEG\_TRANS) is received correctly.
- When the bit SPI\_RX\_EOF\_EN is set, the generation of GDMA\_IN\_SUC\_EOF\_CHn\_INT also depends on the length of transferred data.
- – In a slave single transfer, if SPI\_DMA\_SLV\_SEG\_TRANS\_EN is cleared and GDMA\_IN\_SUC\_EOF\_CHn \_ INT\_ENA is set, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt will be generated once the single transfer
- is done or the length of GDMA RX received data is equal to (SPI\_MS\_DATA\_BITLEN + 1).
- – In a slave segmented transfer, if SPI\_DMA\_SLV\_SEG\_TRANS\_EN is set, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt will be generated once the command (CMD7 or

End\_SEG\_TRANS) is received correctly or the length of GDMA RX received data is equal to (SPI\_MS\_DATA\_BITLEN + 1).

## 27.5.6.2 GDMA TX/RX Buffer Length Control

It is recommended that the length of configured GDMA TX/RX buffer is equal to the length of real transferred data.

- If the length of configured GDMA TX buffer is shorter than that of real transferred data, the extra data will be the same as the last transferred data. SPI\_OUTFIFO\_EMPTY\_ERR\_INT and GDMA\_OUT\_EOF\_CHn\_INT are triggered.
- If the length of configured GDMA TX buffer is longer than the that of real transferred data, the TX buffer is not fully used, and the remaining buffer is available for following transaction even if a new TX buffer is linked later. Please keep it in mind. Or save the unused data and reset DMA.
- If the length of configured GDMA RX buffer is shorter than that of real transferred data, the extra data will be lost. The interrupts SPI\_INFIFO\_FULL\_ERR\_INT and SPI\_TRANS\_DONE\_INT are triggered. But GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt is not generated.
- If the length of configured GDMA RX buffer is longer than that of real transferred data, the RX buffer is not fully used, and the remaining buffer is discarded. In the following transaction, a new linked buffer will be used directly.

## 27.5.7 Data Flow Control in GP-SPI2 Master and Slave Modes

CPU-controlled and DMA-controlled transfers are supported in GP-SPI2 master and slave modes. CPU-controlled transfer means that data transfers between registers SPI\_W0\_REG ~ SPI\_W15\_REG and the SPI device. DMA-controlled transfer means that data transfers between the configured GDMA TX/RX buffer and the SPI device. To select between the two transfer modes, configure SPI\_DMA\_RX\_ENA and SPI\_DMA\_TX\_ENA before the transfer starts.

## 27.5.7.1 GP-SPI2 Functional Blocks

Figure 27.5-2. GP-SPI2 Block Diagram

![Image](images/27_Chapter_27_img003_80565644.png)

Figure 27.5-2 shows main functional blocks in GP-SPI2, including:

- Master FSM: all the features, supported in GP-SPI2 master mode, are controlled by this state machine together with register configuration.
- SPI Buffer: SPI\_W0\_REG ~ SPI\_W15\_REG, see Figure 27.5-1. The data transferred in CPU-controlled mode is prepared in this buffer.
- Timing Module: capture data on FSPI bus.
- spi\_mst/slv\_din/dout\_ctrl: convert the TX/RX data into bytes.
- spi\_rx\_afifo: store the received data.
- buf\_tx\_afifo: store the data to send.
- dma\_tx\_afifo: store the data from GDMA.
- clk\_spi\_mst: this clock is the module clock of GP-SPI2 and derived from PLL\_CLK. It is used in GP-SPI2 master mode, to generate SPI\_CLK signal for data transfer and for slaves.
- SPI\_CLK Generator: generate SPI\_CLK by dividing clk\_spi\_mst. The divider is determined by SPI\_CLKCNT\_N and SPI\_CLKDIV\_PRE.
- SPI\_CLK\_out Mode Control: output the SPI\_CLK signal for data transfer and for slaves.
- SPI\_CLK\_in Mode Control: capture the SPI\_CLK signal from SPI master when GP-SPI2 works as a slave.

## 27.5.7.2 Data Flow Control in Master Mode

Figure 27.5-3. Data Flow Control in GP-SPI2 Master Mode

![Image](images/27_Chapter_27_img004_0420c86b.png)

Figure 27.5-3 shows the data flow of GP-SPI2 in master mode. Its control logic is as follows:

- RX data: data in FSPI bus is captured by Timing Module, converted in units of bytes by spi\_mst\_din\_ctrl module, and then stored in corresponding addresses according to the transfer modes.
- – CPU-controlled transfer: the data is stored to registers SPI\_W0\_REG ~ SPI\_W15\_REG .
- – DMA-controlled transfer: the data is stored to GDMA RX buffer.
- TX data: the TX data is from corresponding addresses according to transfer modes and is saved to buf\_tx\_afifo.
- – CPU-controlled transfer: TX data is from SPI\_W0\_REG ~ SPI\_W15\_REG .
- – DMA-controlled transfer: TX data is from GDMA TX buffer.

![Image](images/27_Chapter_27_img005_e51fb9ac.png)

The data in buf\_tx\_afifo is sent out to Timing Module in 1/2/4-bit modes, controlled by GP-SPI2 state machine. The Timing Module can be used for timing compensation. For more information, see Section 27.8 .

## 27.5.7.3 Data Flow Control in Slave Mode

Figure 27.5-4. Data Flow Control in GP-SPI2 Slave Mode

![Image](images/27_Chapter_27_img006_968a2970.png)

Figure 27.5-4 shows the data flow in GP-SPI2 slave mode. Its control logic is as follows:

- In CPU/DMA-controlled full-duplex/half-duplex modes, when an external SPI master starts the SPI transfer, data on the FSPI bus is captured, converted into unit of bytes by spi\_slv\_din\_ctrl module, and then is stored in spi\_rx\_afifo.
- – In CPU-controlled full-duplex transfer, the received data in spi\_rx\_afifo will be later stored into registers SPI\_W0\_REG ~ SPI\_W15\_REG, successively.
- – In half-duplex Wr\_BUF transfer, when the value of address (SLV\_ADDR[7:0]) is received, the received data in spi\_rx\_afifo will be stored in the related address of registers SPI\_W0\_REG ~ SPI\_W15\_REG
- – In DMA-controlled full-duplex transfer or in half-duplex Wr\_DMA transfer, the received data in spi\_rx\_afifo will be stored in the configured GDMA RX buffer.
- In CPU-controlled full-/half-duplex transfer, the data to send is stored in buf\_tx\_afifo. In DMA-controlled full-/half-duplex transfer, the data to send is stored in dma\_tx\_afifo. Therefore, Rd\_BUF transaction controlled by CPU and Rd\_DMA transaction controlled by DMA can be done in one slave segmented transfer. TX data comes from corresponding addresses according the transfer modes.
- – In CPU-controlled full-duplex transfer, when SPI\_SLAVE\_MODE and SPI\_DOUTDIN are set and SPI\_DMA
- \_TX\_ENA is cleared, the data in SPI\_W0\_REG ~ SPI\_W15\_REG will be stored into buf\_tx\_afifo;
- – In CPU-controlled half-duplex transfer, when SPI\_SLAVE\_MODE is set, SPI\_DOUTDIN is cleared, Rd\_BUF command and SLV\_ADDR[7:0] are received, the data started from the related address of SPI\_W0\_REG ~ SPI\_W15\_REG will be stored into buf\_tx\_afifo;
- – In DMA-controlled full-duplex transfer, when SPI\_SLAVE\_MODE , SPI\_DOUTDIN and SPI\_DMA\_TX\_ ENA are set, the data in the configured GDMA TX buffer will be stored into dma\_tx\_afifo;

![Image](images/27_Chapter_27_img007_625ef0df.png)

- – In DMA-controlled half-duplex transfer, when SPI\_SLAVE\_MODE is set, SPI\_DOUTDIN is cleared, and Rd\_DMA command is received, the data in the configured GDMA TX buffer will be stored into dma\_tx\_afifo.

The data in buf\_tx\_afifo or dma\_tx\_afifo is sent out by spi\_slv\_dout\_ctrl module in 1/2/4-bit modes.

## 27.5.8 GP-SPI2 Works as a Master

GP-SPI2 can be configured as a SPI master by clearing the bit SPI\_SLAVE\_MODE in SPI\_SLAVE\_REG. In this operation mode, GP-SPI2 provides clock signal (the divided clock from GP-SPI2 module clock) and six CS lines (CS0 ~ CS5).

## Note:

- The length of transferred data must be in unit of bytes, otherwise the extra bits will be lost. The extra bits here means the result of total data bits % 8.
- To transfer bits not in unit of bytes, consider implementing it in CMD state or ADDR state.

## 27.5.8.1 State Machine

When GP-SPI2 works as a master, the state machine controls its various states during data transfer, including configuration (CONF), preparation (PREP), command (CMD), address (ADDR), dummy (DUMMY), data out (DOUT), and data in (DIN) states. GP-SPI2 is mainly used to access 1/2/4-bit SPI devices, such as flash and external RAM, thus the naming of GP-SPI2 states keeps consistent with the sequence naming of flash and external RAM. The meaning of each state is described as follows and Figure 27.5-5 shows the workflow of GP-SPI2 state machine.

1. IDLE: GP-SPI2 is not active or is in slave mode.
2. CONF: only used in DMA-controlled configurable segmented transfer. Set SPI\_USR and SPI\_USR\_CONF to enable this state. If this state is not enabled, it means the current transfer is a single transfer.
3. PREP: prepare an SPI transaction and control SPI CS setup time. Set SPI\_USR and SPI\_CS\_SETUP to enable this state.
4. CMD: send command sequence. Set SPI\_USR and SPI\_USR\_COMMAND to enable this state.
5. ADDR: send address sequence. Set SPI\_USR and SPI\_USR\_ADDR to enable this state.
6. DUMMY (wait cycle): send dummy sequence. Set SPI\_USR and SPI\_USR\_DUMMY to enable this state.
7. DATA: transfer data.
- DOUT: send data sequence. Set SPI\_USR and SPI\_USR\_MOSI to enable this state.
- DIN: receive data sequence. Set SPI\_USR and SPI\_USR\_MISO to enable this state.
8. DONE: control SPI CS hold time. Set SPI\_USR to enable this state.

![Image](images/27_Chapter_27_img008_3ee979d4.png)

Chapter 27 SPI Controller (SPI)

GoBack

![Image](images/27_Chapter_27_img009_73694ff7.png)

Espressif Systems

622

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

## Legend to state flow:

- — : indicates corresponding state condition is not satisfied; repeats current state.
- — : corresponding registers are set and conditions are satisfied; goes to next state.
- — : state registers are not set; skips one or more following states, depending on the registers of the following states are set or not.

Explanation to the conditions listed in the figure above:

- CONF condition: gpc[17:0] &gt;= SPI\_CONF\_BITLEN[17:0]
- PREP condition: gpc[4:0] &gt;= SPI\_CS\_SETUP\_TIME[4:0]
- CMD condition: gpc[3:0] &gt;= SPI\_USR\_COMMAND\_BITLEN[3:0]
- ADDR condition: gpc[4:0] &gt;= SPI\_USR\_ADDR\_BITLEN[4:0]
- DUMMY condition: gpc[7:0] &gt;= SPI\_USR\_DUMMY\_CYCLELEN[7:0]
- DOUT condition: gpc[17:0] &gt;= SPI\_MS\_DATA\_BITLEN[17:0]
- DIN condition: gpc[17:0] &gt;= SPI\_MS\_DATA\_BITLEN[17:0]
- DONE condition: (gpc[4:0] &gt;= SPI\_CS\_HOLD\_TIME[4:0] || SPI\_CS\_HOLD == 1'b0)

A counter (gpc[17:0]) is used in the state machine to control the cycle length of each state. The states CONF, PREP, CMD, ADDR, DUMMY, DOUT, and DIN can be enabled or disabled independently. The cycle length of each state can also be configured independently.

## 27.5.8.2 Register Configuration for State and Bit Mode Control

## Introduction

The registers, related to GP-SPI2 state control, are listed in Table 27.5-7. Users can enable QPI mode for GP-SPI2 by setting the bit SPI\_QPI\_MODE in register SPI\_USER\_REG .

Table 27.5-7. Registers Used for State Control in 1/2/4-bit Modes

| State   | Control Registers for 1-bit Mode FSPI Bus                    | Control Registers for 2-bit Mode FSPI Bus                                  | Control Registers for 4-bit Mode FSPI Bus                                  |
|---------|--------------------------------------------------------------|----------------------------------------------------------------------------|----------------------------------------------------------------------------|
| CMD     | SPI_USR_COMMAND_VALUE SPI_USR_COMMAND_BITLEN SPI_USR_COMMAND | SPI_USR_COMMAND_VALUE SPI_USR_COMMAND_BITLEN SPI_FCMD_DUAL SPI_USR_COMMAND | SPI_USR_COMMAND_VALUE SPI_USR_COMMAND_BITLEN SPI_FCMD_QUAD SPI_USR_COMMAND |
| ADDR    | SPI_USR_ADDR_VALUE SPI_USR_ADDR_BITLEN SPI_USR_ADDR          | SPI_USR_ADDR_VALUE SPI_USR_ADDR_BITLEN SPI_USR_ADDR SPI_FADDR_DUAL         | SPI_USR_ADDR_VALUE SPI_USR_ADDR_BITLEN SPI_USR_ADDR SPI_FADDR_QUAD         |
| DUMMY   | SPI_USR_DUMMY_CYCLELEN SPI_USR_DUMMY                         | SPI_USR_DUMMY_CYCLELEN SPI_USR_DUMMY                                       | SPI_USR_DUMMY_CYCLELEN SPI_USR_DUMMY                                       |
| DIN     | SPI_USR_MISO SPI_MS_DATA_BITLEN                              | SPI_USR_MISO SPI_MS_DATA_BITLEN SPI_FREAD_DUAL                             | SPI_USR_MISO SPI_MS_DATA_BITLEN SPI_FREAD_QUAD                             |

![Image](images/27_Chapter_27_img010_1ecbcd98.png)

Table 27.5-7. Registers Used for State Control in 1/2/4-bit Modes

| State   | Control Registers for 1-bit Mode FSPI Bus   | Control Registers for 2-bit Mode FSPI Bus       | Control Registers for 4-bit Mode FSPI Bus       |
|---------|---------------------------------------------|-------------------------------------------------|-------------------------------------------------|
| DOUT    | SPI_USR_MOSI SPI_MS_DATA_BITLEN             | SPI_USR_MOSI SPI_MS_DATA_BITLEN SPI_FWRITE_DUAL | SPI_USR_MOSI SPI_MS_DATA_BITLEN SPI_FWRITE_QUAD |

As shown in Table 27.5-7, the registers in each cell should be configured to set the FSPI bus to corresponding bit mode, i.e. the mode shown in the table header, at a specific state (corresponding to the first column).

## Configuration

For instance, when GP-SPI2 reads data, and

- CMD is in 1-bit mode
- ADDR is in 2-bit mode
- DUMMY is 8 clock cycles
- DIN is in 4-bit mode

The register configuration can be as follows:

1. Configure CMD state related registers.
- Configure the required command value in SPI\_USR\_COMMAND\_VALUE .
- Configure command bit length in SPI\_USR\_COMMAND\_BITLEN . SPI\_USR\_COMMAND\_BITLEN = expected bit length - 1.
- Set SPI\_USR\_COMMAND .
- Clear SPI\_FCMD\_DUAL and SPI\_FCMD\_QUAD .
2. Configure ADDR state related registers.
- Configure the required address value in SPI\_USR\_ADDR\_VALUE .
- Configure address bit length in SPI\_USR\_ADDR\_BITLEN . SPI\_USR\_ADDR\_BITLEN = expected bit length - 1.
- Set SPI\_USR\_ADDR and SPI\_FADDR\_DUAL .
- Clear SPI\_FADDR\_QUAD .
3. Configure DUMMY state related registers.
- Configure DUMMY cycles in SPI\_USR\_DUMMY\_CYCLELEN . SPI\_USR\_DUMMY\_CYCLELEN = expected clock cycles - 1.
- Set SPI\_USR\_DUMMY .
4. Configure DIN state related registers.
- Configure read data bit length in SPI\_MS\_DATA\_BITLEN . SPI\_MS\_DATA\_BITLEN = bit length expected - 1.

ESP32-C3 TRM (Version 1.3)

- Set SPI\_FREAD\_QUAD and SPI\_USR\_MISO .
- Clear SPI\_FREAD\_DUAL .
- Configure GDMA in DMA-controlled mode. In CPU controlled mode, no action is needed.
5. Clear SPI\_USR\_MOSI .
6. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.
7. Set SPI\_USR to start GP-SPI2 transfer.

When writing data (DOUT state), SPI\_USR\_MOSI should be configured instead, while SPI\_USR\_MISO should be cleared. The output data bit length is the value of SPI\_MS\_DATA\_BITLEN + 1. Output data should be configured in GP-SPI2 data buffer (SPI\_W0\_REG ~ SPI\_W15\_REG) in CPU-controlled mode, or GDMA TX buffer in DMA-controlled mode. The data byte order is incremented from LSB (byte 0) to MSB.

Pay special attention to the command value in SPI\_USR\_COMMAND\_VALUE and to address value in SPI\_USR\_

## ADDR\_VALUE .

The configuration of command value is as follows:

- If SPI\_USR\_COMMAND\_BITLEN &lt; 8, the command value is written to SPI\_USR\_COMMAND\_VALUE[7:0]. Command value is sent as follows.
- – If SPI\_WR\_BIT\_ORDER is set, the lower part of SPI\_USR\_COMMAND\_VALUE[7:0], i.e. SPI\_USR\_ COMMAND\_VALUE[SPI\_USR\_COMMAND\_BITLEN:0], is sent first.
- – If SPI\_WR\_BIT\_ORDER is cleared, the higher part of SPI\_USR\_COMMAND\_VALUE[7:0], i.e. SPI\_USR\_COM MAND\_VALUE[7:7 - SPI\_USR\_COMMAND\_BITLEN], is sent first.
- If 7 &lt; SPI\_USR\_COMMAND\_BITLEN &lt; 16, the command value is written to SPI\_USR\_COMMAND\_VALUE[15:
- 0]. Command value is sent as follows.
- – If SPI\_WR\_BIT\_ORDER is set, SPI\_USR\_COMMAND\_VALUE[7:0] is sent first, and then the lower part of SPI\_USR\_COMMAND\_VALUE[15:8], i.e. SPI\_USR\_COMMAND\_VALUE[SPI\_USR\_COMMAND \_BITLEN:8], is sent.
- – If SPI\_WR\_BIT\_ORDER is cleared, SPI\_USR\_COMMAND\_VALUE[7:0] is sent first, and then the higher part of SPI\_USR\_COMMAND\_VALUE[15:8], i.e. SPI\_USR\_COMMAND\_VALUE[15:15 -SPI\_USR\_COMMAN D\_BITLEN], is sent.

The configuration of address value is as follows:

- If SPI\_USR\_ADDR\_BITLEN &lt; 8, the address value is written to SPI\_USR\_ADDR\_VALUE[31:24]. Address value is sent as follows.
- – If SPI\_WR\_BIT\_ORDER is set, the lower part of SPI\_USR\_ADDR\_VALUE[31:24], i.e. SPI\_USR\_ADD R\_VALUE[SPI\_USR\_ADDR\_BITLEN + 24:24], is sent first.
- – If SPI\_WR\_BIT\_ORDER is cleared, the higher part of SPI\_USR\_ADDR\_VALUE[31:24], i.e. SPI\_USR\_ADDR\_ VALUE[31:31 - SPI\_USR\_ADDR\_BITLEN], is sent first.

- If 7 &lt; SPI\_USR\_ADDR\_BITLEN &lt; 16, the ADDR value is written to SPI\_USR\_ADDR\_VALUE[31:16]. Address value is sent as follows.
- – If SPI\_WR\_BIT\_ORDER is set, SPI\_USR\_ADDR\_VALUE[31:24] is sent first, and then the lower part of SPI\_USR\_ADDR\_VALUE[23:16], i.e. SPI\_USR\_ADDR\_VALUE[SPI\_USR\_ADDR\_BITLEN + 8:16], is sent.
- – If SPI\_WR\_BIT\_ORDER is cleared, SPI\_USR\_ADDR\_VALUE[31:24] is sent first, and then the higher part of SPI\_USR\_ADDR\_VALUE[23:16], i.e. SPI\_USR\_ADDR\_VALUE[23:31 - SPI\_USR\_ADDR\_BITLEN], is sent.
- If 15 &lt; SPI\_USR\_ADDR\_BITLEN &lt; 24, the ADDR value is written to SPI\_USR\_ADDR\_VALUE[31:8]. Address value is sent as follows.
- – If SPI\_WR\_BIT\_ORDER is set, SPI\_USR\_ADDR\_VALUE[31:16] is sent first, and then the lower part of SPI\_USR\_ADDR\_VALUE[15:8], i.e. SPI\_USR\_ADDR\_VALUE[SPI\_USR\_ADDR\_BITLEN - 8:8], is sent.
- – If SPI\_WR\_BIT\_ORDER is cleared, SPI\_USR\_ADDR\_VALUE[31:16] is sent first, and then the higher part of SPI\_USR\_ADDR\_VALUE[15:8], i.e. SPI\_USR\_ADDR\_VALUE[15:31 - SPI\_USR\_ADDR\_BITLEN], is sent.
- If 23 &lt; SPI\_USR\_ADDR\_BITLEN &lt; 32, the ADDR value is written to SPI\_USR\_ADDR\_VALUE[31:0]. Address value is sent as follows.
- – If SPI\_WR\_BIT\_ORDER is set, SPI\_USR\_ADDR\_VALUE[31:8] is sent first, and then the lower part of SPI\_USR\_ADDR\_VALUE[7:0], i.e. SPI\_USR\_ADDR\_VALUE[SPI\_USR\_ADDR\_BITLEN - 24:0], is sent.
- – If SPI\_WR\_BIT\_ORDER is cleared, SPI\_USR\_ADDR\_VALUE[31:8] is sent first, and then the higher part of SPI\_USR\_ADDR\_VALUE[7:0], i.e. SPI\_USR\_ADDR\_VALUE[7:31 - SPI\_USR\_ADDR\_BITLEN], is sent.

## 27.5.8.3 Full-Duplex Communication (1-bit Mode Only)

## Introduction

GP-SPI2 supports SPI full-duplex communication. In this mode, SPI master provides CLK and CS signals, exchanging data with SPI slave in 1-bit mode via MOSI (FSPID, sending) and MISO (FSPIQ, receiving) at the same time. To enable this communication mode, set the bit SPI\_DOUTDIN in register SPI\_USER\_REG. Figure 27.5-6 illustrates the connection of GP-SPI2 with its slave in full-duplex communication.

Figure 27.5-6. Full-Duplex Communication Between GP-SPI2 Master and a Slave

![Image](images/27_Chapter_27_img011_c64273aa.png)

In full-duplex communication, the behavior of states CMD, ADDR, DUMMY, DOUT and DIN are configurable. Usually, the states CMD, ADDR and DUMMY are not used in this communication. The bit length of transferred data is configured in SPI\_MS\_DATA\_BITLEN. The actual bit length used in communication equals to (SPI\_MS\_DATA\_BITLEN + 1).

![Image](images/27_Chapter_27_img012_da21f3d0.png)

## Configuration

To start a data transfer, follow the steps below:

- Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
- Configure APB clock (APB\_CLK, see Chapter 6 Reset and Clock) and module clock (clk\_spi\_mst) for the GP-SPI2 module.
- Set SPI\_DOUTDIN and clear SPI\_SLAVE\_MODE, to enable full-duplex communication in master mode.
- Configure GP-SPI2 registers listed in Table 27.5-7 .
- Configure SPI CS setup time and hold time according to Section 27.6 .
- Set the property of FSPICLK according to Section 27.7 .
- Prepare data according to the selected transfer mode:
- – In CPU-controlled MOSI mode, prepare data in registers SPI\_W0\_REG ~ SPI\_W15\_REG .
- – In DMA-controlled mode,
* configure SPI\_DMA\_TX\_ENA/SPI\_DMA\_RX\_ENA
* configure GDMA TX/RX link
* start GDMA TX/RX engine, as described in Section 27.5.6 and Section 27.5.7 .
- Configure interrupts and wait for SPI slave to get ready for transfer.
- Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.
- Set SPI\_USR in register SPI\_CMD\_REG to start the transfer and wait for the configured interrupts.

## 27.5.8.4 Half-Duplex Communication (1/2/4-bit Mode)

## Introduction

In this mode, GP-SPI2 provides CLK and CS signals. Only one side (SPI master or slave) can send data at a time, while the other side receives the data. To enable this communication mode, clear the bit SPI\_DOUTDIN in register SPI\_USER\_REG. The standard format of SPI half-duplex communication is CMD + [ADDR +] [DUMMY +] [DOUT or DIN]. The states ADDR, DUMMY, DOUT, and DIN are optional, and can be disabled or enabled independently.

As described in Section 27.5.8.2, the properties of GP-SPI2 states: CMD, ADDR, DUMMY, DOUT and DIN, such as cycle length, value, and parallel bus bit mode, can be set independently. For the register configuration, see Table 27.5-7 .

The detailed properties of half-duplex GP-SPI2 are as follows:

1. CMD: 0 ~ 16 bits, master output, slave input.
2. ADDR: 0 ~ 32 bits, master output, slave input.
3. DUMMY: 0 ~ 256 FSPICLK cycles, master output, slave input.
4. DOUT: 0 ~ 512 bits (64 B) in CPU-controlled mode and 0 ~ 256 Kbits (32 KB) in DMA-controlled mode, master output, slave input.

![Image](images/27_Chapter_27_img013_128ca043.png)

5. DIN: 0 ~ 512 bits (64 B) in CPU-controlled mode and 0 ~ 256 Kbits (32 KB) in DMA-controlled mode, master input, slave output.

## Configuration

The register configuration is as follows:

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure APB clock (APB\_CLK) and module clock (clk\_spi\_mst) for the GP-SPI2 module.
3. Clear SPI\_DOUTDIN and SPI\_SLAVE\_MODE, to enable half-duplex communication in master mode.
4. Configure GP-SPI2 registers listed in Table 27.5-7 .
5. Configure SPI CS setup time and hold time according to Section 27.6 .
6. Set the property of FSPICLK according to Section 27.7 .
7. Prepare data according to the selected transfer mode:
- In CPU-controlled MOSI mode, prepare data in registers SPI\_W0\_REG ~ SPI\_W15\_REG .
- In DMA-controlled mode,
10. – configure SPI\_DMA\_TX\_ENA/SPI\_DMA\_RX\_ENA
11. – configure GDMA TX/RX link
12. – start GDMA TX/RX engine, as described in Section 27.5.6 and Section 27.5.7 .
8. Configure interrupts and wait for SPI slave to get ready for transfer.
9. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.
10. Set SPI\_USR in register SPI\_CMD\_REG to start the transfer and wait for the configured interrupts.

## Application Example

The following example shows how GP-SPI2 to access flash and external RAM in master half-duplex mode.

![Image](images/27_Chapter_27_img014_f0cc0721.png)

Figure 27.5-7. Connection of GP-SPI2 to Flash and External RAM in 4-bit Mode

![Image](images/27_Chapter_27_img015_d6f69de7.png)

Figure 27.5-8 indicates GP-SPI2 Quad I/O Read sequence according to standard flash specification. Other GP-SPI2 command sequences are implemented in accordance with the requirements of SPI slaves.

Figure 27.5-8. SPI Quad I/O Read Command Sequence Sent by GP-SPI2 to Flash

![Image](images/27_Chapter_27_img016_f79badce.png)

## 27.5.8.5 DMA-Controlled Configurable Segmented Transfer

## Note:

Note that there is no separate section on how to configure a single transfer in master mode, since the CONF state of a configurable segmented transfer can be skipped to implement a single transfer.

## Introduction

When GP-SPI2 works as a master, it provides a feature named: configurable segmented transfer controlled by DMA.

A DMA-controlled transfer in master mode can be

- a single transfer, consisting of only one transaction;
- or a configurable segmented transfer, consisting of several transactions (segments).

In a configurable segmented transfer, the registers of its each single transaction (segment) are configurable.

![Image](images/27_Chapter_27_img017_ef27bc16.png)

This feature enables GP-SPI2 to do as many as transactions (segments) as configured when such transfer is triggered once by CPU. Figure 27.5-9 shows how this feature works.

Figure 27.5-9. Configurable Segmented Transfer in DMA-Controlled Master Mode

![Image](images/27_Chapter_27_img018_b57decff.png)

As shown in Figure 27.5-9, the registers for one transaction (segment n) can be reconfigured by GP-SPI2 hardware according to the content in its Conf\_bufn during a CONF state, before this segment starts.

It's recommended to provide separate GDMA CONF links and CONF buffers (Conf\_bufi in Figure 27.5-9) for each CONF state. A GDMA TX link is used to connect all the CONF buffers and TX data buffers (Tx\_bufi in Figure 27.5-9) into a chain. Hence, the behavior of the FSPI bus in each segment can be controlled independently.

For example, in a configurable segmentent transfer, its segmenti, segmentj, and segmentk can be configured to full-duplex, half-duplex MISO, and half-duplex MOSI, respectively. i , j, and k are integer variables, which can be any segment number.

Meanwhile, the state of GP-SPI2, the data length and cycle length of the FSPI bus, and the behavior of the GDMA, can be configured independently for each segment. When this whole DMA-controlled transfer (consisting of several segments) has finished, a GP-SPI2 interrupt, SPI\_DMA\_SEG\_TRANS\_DONE\_INT, is triggered.

## Configuration

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure APB clock (APB\_CLK) and module clock (clk\_spi\_mst) for GP-SPI2 module.
3. Clear SPI\_DOUTDIN and SPI\_SLAVE\_MODE, to enable half-duplex communication in master mode.
4. Configure GP-SPI2 registers listed in Table 27.5-7 .
5. Configure SPI CS setup time and hold time according to Section 27.6 .
6. Set the property of FSPICLK according to Section 27.7 .
7. Prepare descriptors for GDMA CONF buffer and TX data (optional) for each segment. Chain the descriptors of CONF buffer and TX buffers of several segments into one linked list.
8. Similarly, prepare descriptors for RX buffers for each segment and chain them into one linked list.

9. Configure all the needed CONF buffers, TX buffers and RX buffers, respectively for each segment before this DMA-controlled transfer begins.
10. Point GDMA\_OUTLINK\_ADDR\_CHn to the head address of the CONF and TX buffer descriptor linked list, and then set GDMA\_OUTLINK\_START\_CHn to start the TX GDMA.
11. Clear the bit SPI\_RX\_EOF\_EN in register SPI\_DMA\_CONF\_REG. Point GDMA\_INLINK\_ADDR\_CHn to the head address of the RX buffer descriptor linked list, and then set GDMA\_INLINK\_START\_CHn to start the RX GDMA.
12. Set SPI\_USR\_CONF to enable CONF state.
13. Set SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_ENA to enable the SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. Configure other interrupts if needed according to Section 27.9 .
14. Wait for all the slaves to get ready for transfer.
15. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST and SPI\_RX\_AFIFO\_RST, to reset these buffers.
16. Set SPI\_USR to start this DMA-controlled transfer.
17. Wait for SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt, which means this transfer has finished and the data has been stored into corresponding memory.

## Configuration of CONF Buffer and Magic Value

On GP-SPI2, only registers which will change from the last transaction (segment) need to be re-configured to new values in CONF state. The configuration of other registers can be skipped (i.e. kept the same) to save time and chip resources.

The first word in GDMA CONF bufferi, called SPI\_BIT\_MAP\_WORD, defines whether each GP-SPI2 register is to be updated or not in segmenti. The relation of SPI\_BIT\_MAP\_WORD and GP-SPI2 registers to update can be seen in Table 27.5-8 Bitmap (BM) Table. If a bit in the BM table is set to 1, its corresponding register value will be updated in this segment. Otherwise, if some registers should be kept from being changed, the related bits should be set to 0.

Table 27.5-8. GP-SPI2 Master BM Table for CONF State

|   BM Bit | Register Name   |   BM Bit | Register Name       |
|----------|-----------------|----------|---------------------|
|        0 | SPI_ADDR_REG    |        7 | SPI_MISC_REG        |
|        1 | SPI_CTRL_REG    |        8 | SPI_DIN_MODE_REG    |
|        2 | SPI_CLOCK_REG   |        9 | SPI_DIN_NUM_REG     |
|        3 | SPI_USER_REG    |       10 | SPI_DOUT_MODE_REG   |
|        4 | SPI_USER1_REG   |       11 | SPI_DMA_CONF_REG    |
|        5 | SPI_USER2_REG   |       12 | SPI_DMA_INT_ENA_REG |
|        6 | SPI_MS_DLEN_REG |       13 | SPI_DMA_INT_CLR_REG |

Then new values of all the registers to be modified should be placed right after SPI\_BIT\_MAP\_WORD, in consecutive words in the CONF buffer.

To ensure the correctness of the content in each CONF buffer, the value in SPI\_BIT\_MAP\_WORD[31:28] is used as "magic value", and will be compared with SPI\_DMA\_SEG\_MAGIC\_VALUE in the register SPI\_SLAVE\_REG. The value of SPI\_DMA\_SEG\_MAGIC\_VALUE should be configured before this DMA-controlled transfer starts, and can not be changed during these segments.

- If SPI\_BIT\_MAP\_WORD[31:28] == SPI\_DMA\_SEG\_MAGIC\_VALUE, this DMA-controlled transfer continues normally; the interrupt SPI\_DMA\_SEG\_TRANS\_DONE\_INT is triggered at the end of this DMA-controlled transfer.
- If SPI\_BIT\_MAP\_WORD[31:28] != SPI\_DMA\_SEG\_MAGIC\_VALUE, GP-SPI2 state (spi\_st) goes back to IDLE and the transfer is ended immediately. The interrupt SPI\_DMA\_SEG\_TRANS\_DONE\_INT is still triggered, with SPI\_SEG\_MAGIC\_ERR\_INT\_RAW bit set to 1.

## CONF Buffer Configuration Example

Table 27.5-9 and Table 27.5-10 provide an example to show how to configure a CONF buffer for a transaction (segment i) whose SPI\_ADDR\_REG , SPI\_CTRL\_REG , SPI\_CLOCK\_REG , SPI\_USER\_REG , SPI\_USER1\_REG

need to be updated.

Table 27.5-9. An Example of CONF bufferi in Segmenti

| CONF bufferi     | Note                                                                                                                                                                                                                                    |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SPI_BIT_MAP_WORD | The first word in this buffer. Its value is 0xA000001F in this ex ample when the SPI_DMA_SEG_MAGIC_VALUE is set to 0xA. As shown in Table 27.5-10, bits 0, 1, 2, 3, and 4 are set, indicating the following registers will be updated. |
| SPI_ADDR_REG     | The second word, stores the new value to SPI_ADDR_REG .                                                                                                                                                                                 |
| SPI_CTRL_REG     | The third word, stores the new value to SPI_CTRL_REG .                                                                                                                                                                                  |
| SPI_CLOCK_REG    | The fourth word, stores the new value to SPI_CLOCK_REG .                                                                                                                                                                                |
| SPI_USER_REG     | The fifth word, stores the new value to SPI_USER_REG .                                                                                                                                                                                  |
| SPI_USER1_REG    | The sixth word, stores the new value to SPI_USER1_REG .                                                                                                                                                                                 |

Table 27.5-10. BM Bit Value v.s. Register to Be Updated in This Example

|   BM Bit |   Value | Register Name   |   BM Bit |   Value | Register Name       |
|----------|---------|-----------------|----------|---------|---------------------|
|        0 |       1 | SPI_ADDR_REG    |        7 |       0 | SPI_MISC_REG        |
|        1 |       1 | SPI_CTRL_REG    |        8 |       0 | SPI_DIN_MODE_REG    |
|        2 |       1 | SPI_CLOCK_REG   |        9 |       0 | SPI_DIN_NUM_REG     |
|        3 |       1 | SPI_USER_REG    |       10 |       0 | SPI_DOUT_MODE_REG   |
|        4 |       1 | SPI_USER1_REG   |       11 |       0 | SPI_DMA_CONF_REG    |
|        5 |       0 | SPI_USER2_REG   |       12 |       0 | SPI_DMA_INT_ENA_REG |
|        6 |       0 | SPI_MS_DLEN_REG |       13 |       0 | SPI_DMA_INT_CLR_REG |

## Notes:

In a DMA-controlled configurable segmented transfer, please pay special attention to the following bits:

- SPI\_USR\_CONF: set SPI\_USR\_CONF before SPI\_USR is set, to enable this transfer.
- SPI\_USR\_CONF\_NXT: if segmenti is not the final transaction of this whole DMA-controlled transfer, its SPI\_USR\_CONF\_NXT should be set to 1.
- SPI\_CONF\_BITLEN: GP-SPI2 CS setup time and hold time are programmable independently in each segment, see Section 27.6 for detailed configuration. The CS high time in each segment is about:

<!-- formula-not-decoded -->

![Image](images/27_Chapter_27_img019_eb17256b.png)

The CS high time in CONF state can be set from 62.5 µs to 3.2768 ms when fAPB\_CLK is 80 MHz. (SPI\_CONF\_

BITLEN + 5) will overflow from (0x40000 - SPI\_CONF\_BITLEN - 5) if SPI\_CONF\_BITLEN is larger than 0x3FFFA.

## 27.5.9 GP-SPI2 Works as a Slave

GP-SPI2 can be used as a slave to communicate with an SPI master. As a slave, GP-SPI2 supports 1-bit SPI, 2-bit dual SPI, 4-bit quad SPI, and QPI modes, with specific communication formats. To enable this mode, set SPI\_SLAVE\_MODE in register SPI\_SLAVE\_REG .

The CS signal must be held low during the transmission, and its falling/rising edges indicate the start/end of a single or segmented transmission. The length of transferred data must be in unit of bytes, otherwise the extra bits will be lost. The extra bits here means the result of total bits % 8.

## 27.5.9.1 Communication Formats

In GP-SPI2 slave mode, SPI full-duplex and half-duplex communications are available. To select from the two communications, configure SPI\_DOUTDIN in register SPI\_USER\_REG .

Full-duplex communication means that input data and output data are transmitted simultaneously throughout the entire transaction. All bits are treated as input or output data, which means no command, address or dummy states are expected. The interrupt SPI\_TRANS\_DONE\_INT is triggered once the transaction ends.

In half-duplex communication, the format is CMD+ADDR+DUMMY+DATA (DIN or DOUT).

- "DIN" means that an SPI master reads data from GP-SPI2.
- "DOUT" means that an SPI master writes data to GP-SPI2.

The detailed properties of each state are as follows:

## 1. CMD:

- Indicate the function of SPI slave;
- One byte from master to slave;
- Only the values in Table 27.5-11 and Table 27.5-12 are valid;
- Can be sent in 1-bit SPI mode or 4-bit QPI mode.

## 2. ADDR:

- The address for Wr\_BUF and Rd\_BUF commands in CPU-controlled transfer, or placeholder bits in other transfers and can be defined by application;
- One byte from master to slave;
- Can be sent in 1-bit, 2-bit or 4-bit modes (according to the command).

## 3. DUMMY:

- It's value is meaningless. SPI slave prepares data in this state;
- Bit mode of FSPI bus is also meaningless here;

## Note:

The states of ADDR and DUMMY can never be omitted in any half-duplex communications.

When a half-duplex transaction is complete, the transferred CMD and ADDR values are latched into SPI\_SLV\_

LAST\_COMMAND and SPI\_SLV\_LAST\_ADDR respectively. The SPI\_SLV\_CMD\_ERR\_INT\_RAW will be set if the transferred CMD value is not supported by GP-SPI2 slave mode. The SPI\_SLV\_CMD\_ERR\_INT\_RAW can only be cleared by software.

## 27.5.9.2 Supported CMD Values in Half-Duplex Communication

In half-duplex communication, the defined values of CMD determine the transfer types. Unsupported CMD values are disregarded, meanwhile the related transfer is ignored and SPI\_SLV\_CMD\_ERR\_INT\_RAW is set. The transfer format is CMD (8 bits) + ADDR (8 bits) + DUMMY (8 SPI\_CLK cycles) + DATA (unit in bytes). The detailed description of CMD[3:0] is as follows:

1. 0x1 (Wr\_BUF): CPU-controlled write mode. Master sends data and GP-SPI2 receives data. The data is stored in the related address of SPI\_W0\_REG ~ SPI\_W15\_REG .
2. 0x2 (Rd\_BUF): CPU-controlled read mode. Master receives the data sent by GP-SPI2. The data comes from the related address of SPI\_W0\_REG ~ SPI\_W15\_REG .
3. 0x3 (Wr\_DMA): DMA-controlled write mode. Master sends data and GP-SPI2 receives data. The data is stored in GP-SPI2 GDMA RX buffer.
4. 0x4 (Rd\_DMA): DMA-controlled read mode. Master receives the data sent by GP-SPI2. The data comes from GP-SPI2 GDMA TX buffer.
5. 0x7 (CMD7): used to generate an SPI\_SLV\_CMD7\_INT interrupt. It can also generate a GDMA\_IN\_SUC\_EOF
6. \_CHn\_INT interrupt in a slave segmented transfer when GDMA RX link is used. But it will not end
7. GP-SPI2’s slave segmented transfer.
6. 0x8 (CMD8): only used to generate an SPI\_SLV\_CMD8\_INT interrupt, which will not end GP-SPI2's slave segmented transfer.
7. 0x9 (CMD9): only used to generate an SPI\_SLV\_CMD9\_INT interrupt, which will not end GP-SPI2's slave segmented transfer.
8. 0xA (CMDA): only used to generate an SPI\_SLV\_CMDA\_INT interrupt, which will not end GP-SPI2's slave segmented transfer.

The detail function of CMD7, CMD8, CMD9, and CMDA commands is reserved for user definition. These commands can be used as handshake signals, the passwords of some specific functions, the triggers of some user defined actions, and so on.

- Last for eight SPI\_CLK cycles.

## 4. DIN or DOUT:

- Data length can be 0 ~ 64 B in CPU-controlled mode and unlimited in DMA-controlled mode;
- Can be sent in 1-bit, 2-bit or 4-bit modes according to the CMD value.

1/2/4-bit modes in states of CMD, ADDR, DATA are supported, which are determined by value of CMD[7:4]. The DUMMY state is always in 1-bit mode and lasts for eight SPI\_CLK cycles. The definition of CMD[7:4] is as follows:

1. 0x0: CMD, ADDR, and DATA states all are in 1-bit mode.
2. 0x1: CMD and ADDR are in 1-bit mode. DATA is in 2-bit mode.
3. 0x2: CMD and ADDR are in 1-bit mode. DATA is in 4-bit mode.
4. 0x5: CMD is in 1-bit mode. ADDR and DATA are in 2-bit mode.
5. 0xA: CMD is in 1-bit mode, ADDR and DATA are in 4-bit mode. Or in QPI mode.

In addition, if the value of CMD[7:0] is 0x05, 0xA5, 0x06, or 0xDD, DUMMY and DATA states are omitted. The definition of CMD[7:0] is as follows:

1. 0x05 (End\_SEG\_TRANS): master sends 0x05 command to end slave segmented transfer in SPI mode.
2. 0xA5 (End\_SEG\_TRANS): master sends 0xA5 command to end slave segmented transfer in QPI mode.
3. 0x06 (En\_QPI): GP-SPI2 enters QPI mode when receiving the 0x06 command and the bit SPI\_QPI\_MODE in register SPI\_USER\_REG is set.
4. 0xDD (Ex\_QPI): GP-SPI2 exits QPI mode when receiving the 0xDD command and the bit SPI\_QPI\_MODE is cleared.

All the GP-SPI2 supported CMD values are listed in Table 27.5-11 and Table 27.5-12. Note that DUMMY state is always in 1-bit mode and lasts for eight SPI\_CLK cycles.

Table 27.5-11. Supported CMD Values in SPI Mode

| Transfer Type   | CMD[7:0]   | CMD State   | ADDR State   | DATA State   |
|-----------------|------------|-------------|--------------|--------------|
| Wr_BUF          | 0x01       | 1-bit mode  | 1-bit mode   | 1-bit mode   |
| Wr_BUF          | 0x11       | 1-bit mode  | 1-bit mode   | 2-bit mode   |
| Wr_BUF          | 0x21       | 1-bit mode  | 1-bit mode   | 4-bit mode   |
| Wr_BUF          | 0x51       | 1-bit mode  | 2-bit mode   | 2-bit mode   |
| Wr_BUF          | 0xA1       | 1-bit mode  | 4-bit mode   | 4-bit mode   |
| Rd_BUF          | 0x02       | 1-bit mode  | 1-bit mode   | 1-bit mode   |
| Rd_BUF          | 0x12       | 1-bit mode  | 1-bit mode   | 2-bit mode   |
| Rd_BUF          | 0x22       | 1-bit mode  | 1-bit mode   | 4-bit mode   |
| Rd_BUF          | 0x52       | 1-bit mode  | 2-bit mode   | 2-bit mode   |
| Rd_BUF          | 0xA2       | 1-bit mode  | 4-bit mode   | 4-bit mode   |
| Wr_DMA          | 0x03       | 1-bit mode  | 1-bit mode   | 1-bit mode   |
| Wr_DMA          | 0x13       | 1-bit mode  | 1-bit mode   | 2-bit mode   |
| Wr_DMA          | 0x23       | 1-bit mode  | 1-bit mode   | 4-bit mode   |
| Wr_DMA          | 0x53       | 1-bit mode  | 2-bit mode   | 2-bit mode   |
| Wr_DMA          | 0xA3       | 1-bit mode  | 4-bit mode   | 4-bit mode   |
| Rd_DMA          | 0x04       | 1-bit mode  | 1-bit mode   | 1-bit mode   |
|                 | 0x14       | 1-bit mode  | 1-bit mode   | 2-bit mode   |
|                 | 0x24       | 1-bit mode  | 1-bit mode   | 4-bit mode   |
|                 | 0x54       | 1-bit mode  | 2-bit mode   | 2-bit mode   |
|                 | 0xA4       | 1-bit mode  | 4-bit mode   | 4-bit mode   |

Table 27.5-11. Supported CMD Values in SPI Mode

| Transfer Type   | CMD[7:0]   | CMD State   | ADDR State   | DATA State   |
|-----------------|------------|-------------|--------------|--------------|
| CMD7            | 0x07       | 1-bit mode  | 1-bit mode   | -            |
| CMD7            | 0x17       | 1-bit mode  | 1-bit mode   | -            |
| CMD7            | 0x27       | 1-bit mode  | 1-bit mode   | -            |
| CMD7            | 0x57       | 1-bit mode  | 2-bit mode   | -            |
| CMD7            | 0xA7       | 1-bit mode  | 4-bit mode   | -            |
| CMD8            | 0x08       | 1-bit mode  | 1-bit mode   | -            |
| CMD8            | 0x18       | 1-bit mode  | 1-bit mode   | -            |
| CMD8            | 0x28       | 1-bit mode  | 1-bit mode   | -            |
| CMD8            | 0x58       | 1-bit mode  | 2-bit mode   | -            |
| CMD8            | 0xA8       | 1-bit mode  | 4-bit mode   | -            |
| CMD9            | 0x09       | 1-bit mode  | 1-bit mode   | -            |
| CMD9            | 0x19       | 1-bit mode  | 1-bit mode   | -            |
| CMD9            | 0x29       | 1-bit mode  | 1-bit mode   | -            |
| CMD9            | 0x59       | 1-bit mode  | 2-bit mode   | -            |
| CMD9            | 0xA9       | 1-bit mode  | 4-bit mode   | -            |
| CMDA            | 0x0A       | 1-bit mode  | 1-bit mode   | -            |
|                 | 0x1A       | 1-bit mode  | 1-bit mode   | -            |
|                 | 0x2A       | 1-bit mode  | 1-bit mode   | -            |
|                 | 0x5A       | 1-bit mode  | 2-bit mode   | -            |
|                 | 0xAA       | 1-bit mode  | 4-bit mode   | -            |
| End_SEG_TRANS   | 0x05       | 1-bit mode  | -            | -            |
| En_QPI          | 0x06       | 1-bit mode  | -            | -            |

Table 27.5-12. Supported CMD Values in QPI Mode

| Transfer Type   | CMD[7:0]   | CMD State   | ADDR State   | DATA State   |
|-----------------|------------|-------------|--------------|--------------|
| Wr_BUF          | 0xA1       | 4-bit mode  | 4-bit mode   | 4-bit mode   |
| Rd_BUF          | 0xA2       | 4-bit mode  | 4-bit mode   | 4-bit mode   |
| Wr_DMA          | 0xA3       | 4-bit mode  | 4-bit mode   | 4-bit mode   |
| Rd_DMA          | 0xA4       | 4-bit mode  | 4-bit mode   | 4-bit mode   |
| CMD7            | 0xA7       | 4-bit mode  | 4-bit mode   | -            |
| CMD8            | 0xA8       | 4-bit mode  | 4-bit mode   | -            |
| CMD9            | 0xA9       | 4-bit mode  | 4-bit mode   | -            |
| CMDA            | 0xAA       | 4-bit mode  | 4-bit mode   | -            |
| End_SEG_TRANS   | 0xA5       | 4-bit mode  | 4-bit mode   | -            |
| Ex_QPI          | 0xDD       | 4-bit mode  | 4-bit mode   | -            |

Master sends 0x06 CMD (En\_QPI) to set GP-SPI2 slave to QPI mode and all the states of supported transfer will be in 4-bit mode afterwards. If 0xDD CMD (Ex\_QPI) is received, GP-SPI2 slave will be back to SPI mode.

Other transfer types than described in Table 27.5-11 and Table 27.5-12 are ignored. If the transferred data is not in unit of byte, GP-SPI2 can send or receive these extra bits (total bits % 8), however, the correctness of the

data is not guaranteed. But if the CS low time is longer than 2 APB clock (APB\_CLK) cycles, SPI\_TRANS\_DONE\_INT will be triggered. For more information on interrupts triggered at the end of transmissions, please refer to Section 27.9 .

## 27.5.9.3 Slave Single Transfer and Slave Segmented Transfer

When GP-SPI2 works as a slave, it supports full-duplex and half-duplex communications controlled by DMA and by CPU. DMA-controlled transfer can be a single transfer, or a slave segmented transfer consisting of several transactions (segments). The CPU-controlled transfer can only be one single transfer, since each CPU-controlled transaction needs to be triggered by CPU.

In a slave segmented transfer, all transfer types listed in Table 27.5-11 and Table 27.5-12 are supported in a single transaction (segment). It means that CPU-controlled transaction and DMA-controlled transaction can be mixed in one slave segmented transfer.

It is recommended that in a slave segmented transfer:

- CPU-controlled transaction is used for handshake communication and short data transfers.
- DMA-controlled transaction is used for large data transfers.

## 27.5.9.4 Configuration of Slave Single Transfer

In slave mode, GP-SPI2 supports CPU/DMA-controlled full-duplex/half-duplex single transfers. The register configuration procedure is as follows:

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure APB clock (APB\_CLK).
3. Set the bit SPI\_SLAVE\_MODE, to enable slave mode.
4. Configure SPI\_DOUTDIN:
- 1: enable full-duplex communication.
- 0: enable half-duplex communication.

## 5. Prepare data:

- if CPU-controlled transfer mode is selected and GP-SPI2 is used to send data, then prepare data in registers SPI\_W0\_REG ~ SPI\_W15\_REG .
- if DMA-controlled transfer mode is selected,
- – configure SPI\_DMA\_TX\_ENA/SPI\_DMA\_RX\_ENA and SPI\_RX\_EOF\_EN .
- – configure GDMA TX/RX link.
- – start GDMA TX/RX engine, as described in Section 27.5.6 and Section 27.5.7 .
6. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.
7. Clear SPI\_DMA\_SLV\_SEG\_TRANS\_EN in register SPI\_DMA\_CONF\_REG to enable slave single transfer mode.
8. Set SPI\_TRANS\_DONE\_INT\_ENA in SPI\_DMA\_INT\_ENA\_REG and wait for the interrupt SPI\_TRANS\_DONE\_INT. In DMA-controlled mode, it is recommended to wait for the interrupt

![Image](images/27_Chapter_27_img020_b9e27d5c.png)

GDMA\_IN\_SUC\_EOF\_CHn\_INT when GDMA RX buffer is used, which means that data has been stored in the related memory. Other interrupts described in Section 27.9 are optional.

## 27.5.9.5 Configuration of Slave Segmented Transfer in Half-Duplex

GDMA must be used in this mode. The register configuration procedure is as follows:

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure APB clock (APB\_CLK).
3. Set SPI\_SLAVE\_MODE to enable slave mode.
4. Clear SPI\_DOUTDIN to enable half-duplex communication.
5. Prepare data in registers SPI\_W0\_REG ~ SPI\_W15\_REG, if needed.
6. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST and SPI\_RX\_AFIFO\_RST to reset these buffers.
7. Set bits SPI\_DMA\_RX\_ENA and SPI\_DMA\_TX\_ENA. Clear the bit SPI\_RX\_EOF\_EN. Configure GDMA TX/RX link and start GDMA TX/RX engine, as shown in Section 27.5.6 and Section 27.5.7 .
8. Set SPI\_DMA\_SLV\_SEG\_TRANS\_EN in SPI\_DMA\_CONF\_REG to enable slave segmented transfer.
9. Set SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_ENA in SPI\_DMA\_INT\_ENA\_REG and wait for the interrupt SPI\_ DMA\_SEG\_TRANS\_DONE\_INT, which means that the segmented transfer has finished and data has been put into the related memory. Other interrupts described in Section 27.9 are optional.

When End\_SEG\_TRANS (0x05 in SPI mode, 0xA5 in QPI mode) is received by GP-SPI2, this slave segmented transfer is ended and the interrupt SPI\_DMA\_SEG\_TRANS\_DONE\_INT is triggered.

## 27.5.9.6 Configuration of Slave Segmented Transfer in Full-Duplex

GDMA must be used in this mode. In such transfer, the data is transferred from and to the GDMA buffer. The interrupt GDMA\_IN\_SUC\_EOF\_CHn

\_INT is triggered when the transfer ends. The configuration procedure is as follows:

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure APB clock (APB\_CLK).
3. Set SPI\_SLAVE\_MODE and SPI\_DOUTDIN, to enable full-duplex communication in slave mode.
4. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST bit, to reset these buffers.
5. Set SPI\_DMA\_TX\_ENA/SPI\_DMA\_RX\_ENA. Configure GDMA TX/RX link and start GDMA TX/RX engine, as shown in Section 27.5.6 and Section 27.5.7 .
6. Set the bit SPI\_RX\_EOF\_EN in register SPI\_DMA\_CONF\_REG. Configure SPI\_MS\_DATA\_BITLEN[17:0] in register SPI\_MS\_DLEN\_REG to the byte length of the received DMA data.
7. Set SPI\_DMA\_SLV\_SEG\_TRANS\_EN in SPI\_DMA\_CONF\_REG to enable slave segmented transfer mode.
8. Set GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA and wait for the interrupt GDMA\_IN\_SUC\_EOF\_CHn\_INT .

## 27.6 CS Setup Time and Hold Time Control

SPI bus CS (SPI\_CS) setup time and hold time are very important to meet the timing requirements of various SPI devices (e.g. flash or PSRAM).

CS setup time is the time between the CS falling edge and the first latch edge of SPI bus CLK (SPI\_CLK). The first latch edge for mode 0 and mode 3 is rising edge, and falling edge for mode 2 and mode 4.

CS hold time is the time between the last latch edge of SPI\_CLK and the CS rising edge.

In slave mode, the CS setup time and hold time should be longer than 0.5 x T\_SPI\_CLK, otherwise the SPI transfer may be incorrect. T\_SPI\_CLK: one cycle of SPI\_CLK.

In master mode, set the CS setup time by specifying SPI\_CS\_SETUP in SPI\_USER\_REG and SPI\_CS\_SETUP\_TIME in SPI\_USER1\_REG:

- If SPI\_CS\_SETUP is cleared, the SPI CS setup time is 0.5 x T\_SPI\_CLK.
- If SPI\_CS\_SETUP is set, the SPI CS setup time is (SPI\_CS\_SETUP\_TIME + 1.5) x T\_SPI\_CLK.

Set the CS hold time by specifying SPI\_CS\_HOLD in SPI\_USER\_REG and SPI\_CS\_HOLD\_TIME in SPI\_USER1\_REG:

- If SPI\_CS\_HOLD is cleared, the SPI CS hold time is 0.5 x T\_SPI\_CLK;
- If SPI\_CS\_HOLD is set, the SPI CS hold time is (SPI\_CS\_HOLD\_TIME + 1.5) x T\_SPI\_CLK.

Figure 27.6-1 and Figure 27.6-2 show the recommended CS timing and register configuration to access external RAM and flash.

![Image](images/27_Chapter_27_img021_9ff6a150.png)

Figure 27.6-1. Recommended CS Timing and Settings When Accessing External RAM

![Image](images/27_Chapter_27_img022_6e433b78.png)

![Image](images/27_Chapter_27_img023_3d810137.png)

Figure 27.6-2. Recommended CS Timing and Settings When Accessing Flash

## 27.7 GP-SPI2 Clock Control

GP-SPI2 has the following clocks:

- clk\_spi\_mst: module clock of GP-SPI2, derived from PLL\_CLK. Used in GP-SPI2 master mode, to generate SPI\_CLK signal for data transfer and for slaves.
- SPI\_CLK: output clock in master mode.
- APB\_CLK: clock for register configuration.
- clk\_hclk: module timing compensation clock of GP-SPI2.

In master mode, the maximum output clock frequency of GP-SPI2 is fclk\_spi\_mst. To have slower frequencies, the output clock frequency can be divided as follows:

<!-- formula-not-decoded -->

The divider is configured by SPI\_CLKCNT\_N and SPI\_CLKDIV\_PRE in register SPI\_CLOCK\_REG. When the bit SPI\_CLK\_EQU\_SYSCLK in register SPI\_CLOCK\_REG is set to 1, the output clock frequency of GP-SPI2 will be fclk\_spi\_mst. And for other integral clock divisions, SPI\_CLK\_EQU\_SYSCLK should be set to 0.

In slave mode, the supported input clock frequency (fSPI\_CLK) of GP-SPI2 is:

- If fAPB\_CLK &gt;= 60 MHz, fSPI\_CLK &lt;= 60 MHz;
- If fAPB\_CLK &lt; 60 MHz, fSPI\_CLK &lt;= fAPB\_CLK .

## 27.7.1 Clock Phase and Polarity

There are four clock modes in SPI protocol, modes 0 ~ 3, see Figure 27.7-1 and Figure 27.7-2 (excerpted from SPI protocol):

End of Idle State →

End of Idle State -

SCK (CPOL = 0)

SCK (CPOL = 0)

SCK (CPOL = 1)

SCK (CPOL = 1)

SAMPLE I

MOSI/MISO

MOSI/MISO

SAMPLE I

CHANGE O

CHANGE O

MOSI pin

MOSI pin

CHANGE O

MISO pin

CHANGE O

MISO pin

SEL SS (O)

Master only

Master only

SEL SS (O)

SEL SS (1)

SEL SS (1)

MSB first (LSBFE = 0): MSB

LSB first (LSBFE = 1): LSB

MSB first (LSBFE = 0): MSB

LSB first (LSBFE = 1): LSB

tL = Minimum leading time before the first SCK edge, not required for back to back transfers tL = Minimum leading time before the first SCK edge

t = Minimum trailing time after the last SCK edge t = Minimum trailing time after the last SCK edge

t = Minimum idling time between transfers (minimum SS high time), not required for back to back transfers

Transfer

Transfer

9

10

11

12

End -

End -

13 14

15

16

10

11 1

12

13

14

15

16

![Image](images/27_Chapter_27_img024_34a41b98.png)

t, = Minimum idling time between transfers (minimum SS high time)

tz, IT, and t, are guaranteed for the master mode and required for the slave mode.

Figure 27.7-1. SPI Clock Mode 0 or 2

Figure 27.7-2. SPI Clock Mode 1 or 3

![Image](images/27_Chapter_27_img025_939c1466.png)

1. Mode 0: CPOL = 0, CPHA = 0; SCK is 0 when the SPI is in idle state; data is changed on the negative edge of SCK and sampled on the positive edge. The first data is shifted out before the first negative edge of SCK.

Begin

Begin

Begin of Idle State

Begin of Idle State

2. Mode 1: CPOL = 0, CPHA = 1; SCK is 0 when the SPI is in idle state; data is changed on the positive edge of SCK and sampled on the negative edge.
3. Mode 2: CPOL = 1, CPHA = 0; SCK is 1 when the SPI is in idle state; data is changed on the positive edge of SCK and sampled on the negative edge. The first data is shifted out before the first positive edge of SCK.
4. Mode 3: CPOL = 1, CPHA = 1; SCK is 1 when the SPI is in idle state; data is changed on the negative edge of SCK and sampled on the positive edge.

## 27.7.2 Clock Control in Master Mode

The four clock modes 0 ~ 3 are supported in GP-SPI2 master mode. The polarity and phase of GP-SPI2 clock are controlled by the bit SPI\_CK\_IDLE\_EDGE in register SPI\_MISC\_REG and the bit SPI\_CK\_OUT\_EDGE in register SPI\_USER\_REG. The register configuration for SPI clock modes 0 ~ 3 is provided in Table 27.7-1, and can be changed according to the path delay in the application.

Table 27.7-1. Clock Phase and Polarity Configuration in Master Mode

| Control Bit      |   Mode 0 |   Mode 1 |   Mode 2 |   Mode 3 |
|------------------|----------|----------|----------|----------|
| SPI_CK_IDLE_EDGE |        0 |        0 |        1 |        1 |
| SPI_CK_OUT_EDGE  |        0 |        1 |        1 |        0 |

SPI\_CLK\_MODE is used to select the number of rising edges of SPI\_CLK, when SPI\_CS raises high, to be 0, 1, 2 or SPI\_CLK always on.

## Note:

When SPI\_CLK\_MODE is configured to 1 or 2, the bit SPI\_CS\_HOLD must be set and the value of SPI\_CS\_HOLD\_TIME should be larger than 1.

## 27.7.3 Clock Control in Slave Mode

GP-SPI2 slave mode also supports clock modes 0 ~ 3. The polarity and phase are configured by the bits SPI\_TSCK\_I\_EDGE and SPI\_RSCK\_I\_EDGE in register SPI\_USER\_REG. The output edge of data is controlled by SPI\_CLK\_MODE\_13 in register SPI\_SLAVE\_REG. The detailed register configuration is shown in Table 27.7-2:

Table 27.7-2. Clock Phase and Polarity Configuration in Slave Mode

| Control Bit     |   Mode 0 |   Mode 1 |   Mode 2 |   Mode 3 |
|-----------------|----------|----------|----------|----------|
| SPI_TSCK_I_EDGE |        0 |        1 |        1 |        0 |
| SPI_RSCK_I_EDGE |        0 |        1 |        1 |        0 |
| SPI_CLK_MODE_13 |        0 |        1 |        0 |        1 |

## 27.8 GP-SPI2 Timing Compensation

Introduction

The I/O lines are mapped via GPIO Matrix or IO MUX. But there is no timing adjustment in IO MUX. The input data and output data can be delayed for 1 or 2 APB\_CLK cycles at the rising or falling edge in GPIO matrix. For detailed register configuration, see Chapter 5 IO MUX and GPIO Matrix (GPIO, IO MUX) .

Figure 27.8-1 shows the timing compensation control for GP-SPI2 master mode, including the following paths:

- "CLK": the output path of GP-SPI2 bus clock. The clock is sent out by SPI\_CLK out control module, passes through GPIO Matrix or IO MUX and then goes to an external SPI device.
- "IN": data input path of GP-SPI2. The input data from an external SPI device passes through GPIO Matrix or IO MUX, then is adjusted by the Timing Module and finally is stored into spi\_rx\_afifo.
- "OUT": data output path of GP-SPI2. The output data is sent out to the Timing Module, passes through GPIO Matrix or IO MUX and is then captured by an external SPI device.

Figure 27.8-1. Timing Compensation Control Diagram in GP-SPI2 Master Mode

![Image](images/27_Chapter_27_img026_4a3a8200.png)

Every input and output data is passing through the Timing Module and the module can be used to apply delay in units of Tclk\_spi\_mst (one cycle of clk\_spi\_mst) on rising or falling edge.

## Key Registers

- SPI\_DIN\_MODE\_REG: select the latch edge of input data
- SPI\_DIN\_NUM\_REG: select the delay cycles of input data
- SPI\_DOUT\_MODE\_REG: select the latch edge of output data

## Timing Compensation Example

Figure 27.8-2 shows a timing compensation example in GP-SPI2 master mode. Note that DUMMY cycle length is configurable to compensate the delay in I/O lines, so as to enhance the performance of GP-SPI2.

Figure 27.8-2. Timing Compensation Example in GP-SPI2 Master Mode

![Image](images/27_Chapter_27_img027_825a76e1.png)

In Figure 27.8-2, "p1" is the point of input data of Timing Module, "p2" is the point of output data of Timing Module. Since the input data FSPIQ is unaligned to FSPID, the read data of GP-SPI2 will be wrong without the timing compensation.

To get correct read data, follow the the settings below, assuing fclk \_ spi \_ mst equals to fSP I \_ CLK:

- Delay FSPID for two cycles at the falling edge of clk\_spi\_mst.
- Delay FSPIQ for one cycle at the falling edge of clk\_spi\_mst.
- Add one extra dummy cycle.

In GP-SPI2 slave mode, if the bit SPI\_RSCK\_DATA\_OUT in register SPI\_SLAVE\_REG is set to 1, the output data is sent at latch edge, which is half an SPI clock cycle earlier. This can be used for slave mode timing compensation.

## 27.9 Interrupts

## Interrupt Summary

GP-SPI2 provides an SPI interface interrupt SPI\_INT. When an SPI transfer ends, an interrupt is generated in GP-SPI2. The interrupt may be one or more of the following ones:

- SPI\_DMA\_INFIFO\_FULL\_ERR\_INT: triggered when GDMA RX FIFO length is shorter than the real transferred data length.
- SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT: triggered when GDMA TX FIFO length is shorter than the real transferred data length.
- SPI\_SLV\_EX\_QPI\_INT: triggered when Ex\_QPI is received correctly in GP-SPI2 slave mode and the SPI transfer ends.

- SPI\_SLV\_EN\_QPI\_INT: triggered when En\_QPI is received correctly in GP-SPI2 slave mode and the SPI transfer ends.
- SPI\_SLV\_CMD7\_INT: triggered when CMD7 is received correctly in GP-SPI2 slave mode and the SPI transfer ends.
- SPI\_SLV\_CMD8\_INT: triggered when CMD8 is received correctly in GP-SPI2 slave mode and the SPI transfer ends.
- SPI\_SLV\_CMD9\_INT: triggered when CMD9 is received correctly in GP-SPI2 slave mode and the SPI transfer ends.
- SPI\_SLV\_CMDA\_INT: triggered when CMDA is received correctly in GP-SPI2 slave mode and the SPI transfer ends.
- SPI\_SLV\_RD\_DMA\_DONE\_INT: triggered at the end of Rd\_DMA transfer in slave mode.
- SPI\_SLV\_WR\_DMA\_DONE\_INT: triggered at the end of Wr\_DMA transfer in slave mode.
- SPI\_SLV\_RD\_BUF\_DONE\_INT: triggered at the end of Rd\_BUF transfer in slave mode.
- SPI\_SLV\_WR\_BUF\_DONE\_INT: triggered at the end of Wr\_BUF transfer in slave mode.
- SPI\_TRANS\_DONE\_INT: triggered at the end of SPI bus transfer in both master and slave modes.
- SPI\_DMA\_SEG\_TRANS\_DONE\_INT: triggered at the end of End\_SEG\_TRANS transfer in GP-SPI2 slave segmented transfer mode or at the end of configurable segmented transfer in master mode.
- SPI\_SEG\_MAGIC\_ERR\_INT: triggered when a Magic error occurs in CONF buffer during configurable segmented transfer in master mode.
- SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT: triggered by RX AFIFO write-full error in GP-SPI2 master mode.
- SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT: triggered by TX AFIFO read-empty error in GP-SPI2 master mode.
- SPI\_SLV\_CMD\_ERR\_INT: triggered when a received command value is not supported in GP-SPI2 slave mode.
- SPI\_APP2\_INT: used and triggered by software. It is only used for user defined function.
- SPI\_APP1\_INT: used and triggered by software. It is only used for user defined function.

## Interrupts Used in Master and Slave Modes

Table 27.9-1 and Table 27.9-2 show the interrupts used in GP-SPI2 master and slave modes. Set the interrupt enable bit SPI\_*\_INT\_ENA in SPI\_DMA\_INT\_ENA\_REG and wait for the SPI\_INT interrupt. When the transfer ends, the related interrupt is triggered and should be cleared by software before the next transfer.

Table 27.9-1. GP-SPI2 Master Mode Interrupts

| Transfer Type   | Communication Mode    | Controlled by   | Interrupt                  |
|-----------------|-----------------------|-----------------|----------------------------|
| Single Transfer | Full-duplex           | DMA             | GDMA_IN_SUC_EOF_CHn_INT  1 |
| Single Transfer | Full-duplex           | CPU             | SPI_TRANS_DONE_INT  2      |
| Single Transfer | Half-duplex MOSI Mode | DMA             | SPI_TRANS_DONE_INT         |
| Single Transfer | Half-duplex MOSI Mode | CPU             | SPI_TRANS_DONE_INT         |
| Single Transfer |                       | DMA             | GDMA_IN_SUC_EOF_CHn_INT    |

Half-duplex MISO Mode

Table 27.9-1. GP-SPI2 Master Mode Interrupts

| Transfer Type                   | Communication Mode    | Controlled by   | Interrupt                     |
|---------------------------------|-----------------------|-----------------|-------------------------------|
| Configurable Segmented Transfer | Full-duplex           | CPU             | SPI_TRANS_DONE_INT            |
| Configurable Segmented Transfer | Full-duplex           | DMA             | SPI_DMA_SEG_TRANS_DONE_INT  3 |
| Configurable Segmented Transfer | Full-duplex           | CPU             | Not supported                 |
| Configurable Segmented Transfer | Half-duplex MOSI Mode | DMA             | SPI_DMA_SEG_TRANS_DONE_INT    |
| Configurable Segmented Transfer | Half-duplex MOSI Mode | CPU             | Not supported                 |
| Configurable Segmented Transfer | Half-duplex MISO      | DMA             | SPI_DMA_SEG_TRANS_DONE_INT    |
| Configurable Segmented Transfer | Half-duplex MISO      | CPU             | Not supported                 |

## Note:

1. If GDMA\_IN\_SUC\_EOF\_CHn\_INT is triggered, it means all the RX data of GP-SPI2 has been stored in the RX buffer, and the TX data has been transferred to the slave.
2. SPI\_TRANS\_DONE\_INT is triggered when CS is high, which indicates that master has completed the data exchange in SPI\_W0\_REG ~ SPI\_W15\_REG with slave in this mode.
3. If SPI\_DMA\_SEG\_TRANS\_DONE\_INT is triggered, it means that the whole configurable segmented transfer (consisting of several segments) has finished, i.e. the RX data has been stored in the RX buffer completely and all the TX data has been sent out.

Table 27.9-2. GP-SPI2 Slave Mode Interrupts

| Transfer Type            | Communication Mode    | Controlled by   | Interrupt                     |
|--------------------------|-----------------------|-----------------|-------------------------------|
| Single Transfer          | Full-duplex           | DMA             | GDMA_IN_SUC_EOF_CHn_INT  1    |
| Single Transfer          | Full-duplex           | CPU             | SPI_TRANS_DONE_INT  2         |
| Single Transfer          | Half-duplex MOSI Mode | DMA (Wr_DMA)    | GDMA_IN_SUC_EOF_CHn_INT 3     |
| Single Transfer          | Half-duplex MOSI Mode | CPU (Wr_BUF)    | SPI_TRANS_DONE_INT 4          |
| Single Transfer          | Half-duplex MISO Mode | DMA (Rd_DMA)    | SPI_TRANS_DONE_INT 5          |
| Single Transfer          | Half-duplex MISO Mode | CPU (Rd_BUF)    | SPI_TRANS_DONE_INT 6          |
| Slave Segmented Transfer | Full-duplex           | DMA             | GDMA_IN_SUC_EOF_CHn_INT 7     |
| Slave Segmented Transfer | Full-duplex           | CPU             | Not supported 8               |
| Slave Segmented Transfer | Half-duplex MOSI Mode | DMA (Wr_DMA)    | SPI_DMA_SEG_TRANS_DONE_INT 9  |
| Slave Segmented Transfer | Half-duplex MOSI Mode | CPU (Wr_BUF)    | Not supported 10              |
| Slave Segmented Transfer | Half-duplex MISO Mode | DMA (Rd_DMA)    | SPI_DMA_SEG_TRANS_DONE_INT 11 |
| Slave Segmented Transfer | Half-duplex MISO Mode | CPU (Rd_BUF)    | Not supported 12              |

## Note:

1. If GDMA\_IN\_SUC\_EOF\_CHn\_INT is triggered, it means all the RX data has been stored in the RX buffer, and the TX data has been sent to the slave.
2. SPI\_TRANS\_DONE\_INT is triggered when CS is high, which indicates that master has completed the data exchange in SPI\_W0\_REG ~ SPI\_W15\_REG with slave in this mode.
3. SPI\_SLV\_WR\_DMA\_DONE\_INT just means that the transmission on the SPI bus is done, but can not ensure that all the push data has been stored in the RX buffer. For this reason, GDMA\_IN\_SUC\_EOF\_CHn\_INT is recommended.
4. Or wait for SPI\_SLV\_WR\_BUF\_DONE\_INT .

5. Or wait for SPI\_SLV\_RD\_DMA\_DONE\_INT .
6. Or wait for SPI\_SLV\_RD\_BUF\_DONE\_INT .
7. Slave should set the total read data byte length in SPI\_MS\_DATA\_BITLEN before the transfer begins. And set SPI\_RX\_EOF\_EN 0→1 before the end of the interrupt program.
8. Master and slave should define a method to end the segmented transfer, such as via GPIO interrupt and so on.
9. Master sends End\_SEG\_TRAN to end the segmented transfer or slave sets the total read data byte length in SPI\_MS\_DATA\_BITLEN and waits for GDMA\_IN\_SUC\_EOF\_CHn\_INT.
10. Half-duplex Wr\_BUF single transfer can be used in a DMA-controlled segmented transfer.
11. Master sends End\_SEG\_TRAN to end the segmented transfer.
12. Half-duplex Rd\_BUF single transfer can be used in a DMA-controlled segmented transfer.

## 27.10 Register Summary

The addresses in this section are relative to SPI base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                | Description                                 | Address   | Access   |
|-------------------------------------|---------------------------------------------|-----------|----------|
| User-defined control registers      |                                             |           |          |
| SPI_CMD_REG                         | Command control register                    | 0x0000    | varies   |
| SPI_ADDR_REG                        | Address value register                      | 0x0004    | R/W      |
| SPI_USER_REG                        | SPI USER control register                   | 0x0010    | varies   |
| SPI_USER1_REG                       | SPI USER control register 1                 | 0x0014    | R/W      |
| SPI_USER2_REG                       | SPI USER control register 2                 | 0x0018    | R/W      |
| Control and configuration registers |                                             |           |          |
| SPI_CTRL_REG                        | SPI control register                        | 0x0008    | R/W      |
| SPI_MS_DLEN_REG                     | SPI data bit length control register        | 0x001C    | R/W      |
| SPI_MISC_REG                        | SPI MISC register                           | 0x0020    | R/W      |
| SPI_DMA_CONF_REG                    | SPI DMA control register                    | 0x0030    | varies   |
| SPI_SLAVE_REG                       | SPI slave control register                  | 0x00E0    | varies   |
| SPI_SLAVE1_REG                      | SPI slave control register 1                | 0x00E4    | R/W/SS   |
| Clock control registers             |                                             |           |          |
| SPI_CLOCK_REG                       | SPI clock control register                  | 0x000C    | R/W      |
| SPI_CLK_GATE_REG                    | SPI module clock and register clock control | 0x00E8    | R/W      |
| Timing registers                    |                                             |           |          |
| SPI_DIN_MODE_REG                    | SPI input delay mode configuration          | 0x0024    | R/W      |
| SPI_DIN_NUM_REG                     | SPI input delay number configuration        | 0x0028    | R/W      |
| SPI_DOUT_MODE_REG                   | SPI output delay mode configuration         | 0x002C    | R/W      |
| Interrupt registers                 |                                             |           |          |
| SPI_DMA_INT_ENA_REG                 | SPI DMA interrupt enable register           | 0x0034    | R/W      |
| SPI_DMA_INT_CLR_REG                 | SPI DMA interrupt clear register            | 0x0038    | WT       |
| SPI_DMA_INT_RAW_REG                 | SPI DMA interrupt raw register              | 0x003C    | varies   |
| SPI_DMA_INT_ST_REG                  | SPI DMA interrupt status register           | 0x0040    | RO       |

| Name                       | Description                  | Address   | Access   |
|----------------------------|------------------------------|-----------|----------|
| CPU-controlled data buffer |                              |           |          |
| SPI_W0_REG                 | SPI CPU-controlled buffer 0  | 0x0098    | R/W/SS   |
| SPI_W1_REG                 | SPI CPU-controlled buffer 1  | 0x009C    | R/W/SS   |
| SPI_W2_REG                 | SPI CPU-controlled buffer 2  | 0x00A0    | R/W/SS   |
| SPI_W3_REG                 | SPI CPU-controlled buffer 3  | 0x00A4    | R/W/SS   |
| SPI_W4_REG                 | SPI CPU-controlled buffer 4  | 0x00A8    | R/W/SS   |
| SPI_W5_REG                 | SPI CPU-controlled buffer 5  | 0x00AC    | R/W/SS   |
| SPI_W6_REG                 | SPI CPU-controlled buffer 6  | 0x00B0    | R/W/SS   |
| SPI_W7_REG                 | SPI CPU-controlled buffer 7  | 0x00B4    | R/W/SS   |
| SPI_W8_REG                 | SPI CPU-controlled buffer 8  | 0x00B8    | R/W/SS   |
| SPI_W9_REG                 | SPI CPU-controlled buffer 9  | 0x00BC    | R/W/SS   |
| SPI_W10_REG                | SPI CPU-controlled buffer 10 | 0x00C0    | R/W/SS   |
| SPI_W11_REG                | SPI CPU-controlled buffer 11 | 0x00C4    | R/W/SS   |
| SPI_W12_REG                | SPI CPU-controlled buffer 12 | 0x00C8    | R/W/SS   |
| SPI_W13_REG                | SPI CPU-controlled buffer 13 | 0x00CC    | R/W/SS   |
| SPI_W14_REG                | SPI CPU-controlled buffer 14 | 0x00D0    | R/W/SS   |
| SPI_W15_REG                | SPI CPU-controlled buffer 15 | 0x00D4    | R/W/SS   |
| Version register           |                              |           |          |
| SPI_DATE_REG               | Version control              | 0x00F0    | R/W      |

## 27.11 Registers

The addresses in this section are relative to SPI base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 27.1. SPI\_CMD\_REG (0x0000)

![Image](images/27_Chapter_27_img028_29d6182f.png)

- SPI\_CONF\_BITLEN Define the SPI CLK cycles of SPI CONF state. Can be configured in CONF state. (R/W)
- SPI\_UPDATE Set this bit to synchronize SPI registers from APB clock domain into SPI module clock domain. This bit is only used in SPI master mode. (WT)
- SPI\_USR User-defined command enable. An SPI operation will be triggered when the bit is set. The bit will be cleared once the operation is done. 1: enable; 0: disable. Can not be changed by CONF\_buf. (R/W/SC)

## Register 27.2. SPI\_ADDR\_REG (0x0004)

![Image](images/27_Chapter_27_img029_159dc9c5.png)

![Image](images/27_Chapter_27_img030_924b8e62.png)

SPI\_USR\_ADDR\_VALUE Address to slave. Can be configured in CONF state. (R/W)

Submit Documentation Feedback

## Register 27.3. SPI\_USER\_REG (0x0010)

![Image](images/27_Chapter_27_img031_bd5379e8.png)

- SPI\_DOUTDIN Set the bit to enable full-duplex communication. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_QPI\_MODE 1: Enable QPI mode. 0: Disable QPI mode. This configuration is applicable when the SPI controller works as master or slave. Can be configured in CONF state. (R/W/SS/SC)
- SPI\_TSCK\_I\_EDGE In slave mode, this bit can be used to change the polarity of TSCK. 0: TSCK = SPI\_CK\_I. 1: TSCK = !SPI\_CK\_I. (R/W)
- SPI\_CS\_HOLD Keep SPI CS low when SPI is in DONE state. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_CS\_SETUP Enable SPI CS when SPI is in prepare (PREP) state. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_RSCK\_I\_EDGE In slave mode, this bit can be used to change the polarity of RSCK. 0: RSCK = !SPI\_CK\_I. 1: RSCK = SPI\_CK\_I. (R/W)
- SPI\_CK\_OUT\_EDGE This bit together with SPI\_CK\_IDLE\_EDGE is used to control SPI clock mode. Can be configured in CONF state. For more information, see Section 27.7.2. (R/W)
- SPI\_FWRITE\_DUAL In write operations, read-data phase is in 2-bit mode. Can be configured in CONF state. (R/W)
- SPI\_FWRITE\_QUAD In write operations, read-data phase is in 4-bit mode. Can be configured in CONF state. (R/W)
- SPI\_USR\_CONF\_NXT Enable the CONF state for the next transaction (segment) in a configurable segmented transfer. Can be configured in CONF state. (R/W)
- If this bit is set, it means this configurable segmented transfer will continue its next transaction (segment).
- If this bit is cleared, it means this transfer will end after the current transaction (segment) is finished. Or this is not a configurable segmented transfer.
- SPI\_SIO Set the bit to enable 3-line half-duplex communication, where MOSI and MISO signals share the same pin. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_USR\_MISO\_HIGHPART In read-data phase, only access to high-part of the buffers: SPI\_W8\_REG ~ SPI\_W15\_REG. 1: enable; 0: disable. Can be configured in CONF state. (R/W)

Continued on the next page...

## Register 27.3. SPI\_USER\_REG (0x0010)

## Continued from the previous page...

- SPI\_USR\_MOSI\_HIGHPART In write-data phase, only access to high-part of the buffers: SPI\_W8\_REG ~ SPI\_W15\_REG. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_USR\_DUMMY\_IDLE If this bit is set, SPI clock is disabled in DUMMY state. Can be configured in CONF state. (R/W)
- SPI\_USR\_MOSI Set this bit to enable the write-data (DOUT) state of an operation. Can be configured in CONF state. (R/W)
- SPI\_USR\_MISO Set this bit to enable the read-data (DIN) state of an operation. Can be configured in CONF state. (R/W)
- SPI\_USR\_DUMMY Set this bit to enable the DUMMY state of an operation. Can be configured in CONF state. (R/W)
- SPI\_USR\_ADDR Set this bit to enable the address (ADDR) state of an operation. Can be configured in CONF state. (R/W)
- SPI\_USR\_COMMAND Set this bit to enable the command (CMD) state of an operation. Can be configured in CONF state. (R/W)

![Image](images/27_Chapter_27_img032_b5acec8a.png)

Register 27.4. SPI\_USER1\_REG (0x0014)

![Image](images/27_Chapter_27_img033_824a49e3.png)

- SPI\_USR\_DUMMY\_CYCLELEN The length of DUMMY state, in unit of SPI\_CLK cycles. This value is (the expected cycle number - 1). Can be configured in CONF state. (R/W)
- SPI\_MST\_WFULL\_ERR\_END\_EN 1: SPI transfer is ended when SPI RX AFIFO wfull error occurs in GP-SPI master full-/half-duplex modes. 0: SPI transfer is not ended when SPI RX AFIFO wfull error occurs in GP-SPI master full-/half-duplex modes. (R/W)
- SPI\_CS\_SETUP\_TIME The length of prepare (PREP) state, in unit of SPI\_CLK cycles. This value is equal to the expected cycles - 1. This field is used together with SPI\_CS\_SETUP. Can be configured in CONF state. (R/W)
- SPI\_CS\_HOLD\_TIME Delay cycles of CS pin, in units of SPI\_CLK cycles. This field is used together with SPI\_CS\_HOLD. Can be configured in CONF state. (R/W)
- SPI\_USR\_ADDR\_BITLEN The bit length in address state. This value is (expected bit number - 1). Can be configured in CONF state. (R/W)

Register 27.5. SPI\_USER2\_REG (0x0018)

![Image](images/27_Chapter_27_img034_d1eec4c2.png)

SPI\_USR\_COMMAND\_VALUE The value of command. Can be configured in CONF state. (R/W)

- SPI\_MST\_REMPTY\_ERR\_END\_EN 1: SPI transfer is ended when SPI TX AFIFO read empty error occurs in GP-SPI master full-/half-duplex modes. 0: SPI transfer is not ended when SPI TX AFIFO read empty error occurs in GP-SPI master full-/half-duplex modes. (R/W)
- SPI\_USR\_COMMAND\_BITLEN The bit length of command state. This value is (expected bit number - 1). Can be configured in CONF state. (R/W)

![Image](images/27_Chapter_27_img035_7be0296f.png)

## Register 27.6. SPI\_CTRL\_REG (0x0008)

| 31   | 27 26       |   25 | 24   | 22 21   |   20 | 19   |   18 | 17 16 15   | 14 13   |   10 9 |   8 |    | 7   |   6 | 5 4   | 3 2     | 0     |
|------|-------------|------|------|---------|------|------|------|------------|---------|--------|-----|----|-----|-----|-------|---------|-------|
|      | 0 0 0 0 0 0 |    0 |      | 0 0 0   |    1 | 1 1  |    1 | 0 0 0 0    | 0 0 0 0 |      0 |   0 |  0 |     |   0 | 0 0   | 0 0 0 0 | Reset |

![Image](images/27_Chapter_27_img036_f2ec1542.png)

- SPI\_DUMMY\_OUT Configure the output signal level in DUMMY state. Can be configured in CONF state. (R/W)
- SPI\_FADDR\_DUAL Apply 2-bit mode during address (ADDR) state. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_FADDR\_QUAD Apply 4-bit mode during address (ADDR) state. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_FCMD\_DUAL Apply 2-bit mode during command (CMD) state. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_FCMD\_QUAD Apply 4-bit mode during command (CMD) state. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_FREAD\_DUAL In read operations, read-data (DIN) state is in 2-bit mode. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_FREAD\_QUAD In read operations, read-data (DIN) state is in 4-bit mode. 1: enable; 0: disable. Can be configured in CONF state. (R/W)
- SPI\_Q\_POL This bit is used to set MISO line polarity. 1: high; 0: low. Can be configured in CONF state. (R/W)
- SPI\_D\_POL This bit is used to set MOSI line polarity. 1: high; 0: low. Can be configured in CONF state. (R/W)
- SPI\_HOLD\_POL This bit is used to set SPI\_HOLD output value when SPI is in idle. 1: output high; 0: output low. Can be configured in CONF state. (R/W)
- SPI\_WP\_POL This bit is to set the output value of write-protect signal when SPI is in idle. 1: output high; 0: output low. Can be configured in CONF state. (R/W)
- SPI\_RD\_BIT\_ORDER In read-data (MISO) state, 1: LSB first; 0: MSB first. Can be configured in CONF state. (R/W)
- SPI\_WR\_BIT\_ORDER In command (CMD), address (ADDR), and write-data (MOSI) states, 1: LSB first; 0: MSB first. Can be configured in CONF state. (R/W)

Register 27.7. SPI\_MS\_DLEN\_REG (0x001C)

![Image](images/27_Chapter_27_img037_2b6bd9a1.png)

SPI\_MS\_DATA\_BITLEN The value of this field is the configured SPI transmission data bit length in master mode DMA-controlled transfer or CPU-controlled transfer. The value is also the configured bit length in slave mode DMA RX controlled transfer. The register value shall be (bit\_num -1). Can be configured in CONF state. (R/W)

## Register 27.8. SPI\_MISC\_REG (0x0020)

![Image](images/27_Chapter_27_img038_93c6ff02.png)

- SPI\_CS0\_DIS SPI CS0 pin enable bit. 1: disable CS0, 0: SPI\_CS0 signal is from/to CS0 pin. Can be configured in CONF state. (R/W)
- SPI\_CS1\_DIS SPI CS1 pin enable bit. 1: disable CS1, 0: SPI\_CS1 signal is from/to CS1 pin. Can be configured in CONF state. (R/W)
- SPI\_CS2\_DIS SPI CS2 pin enable bit. 1: disable CS2, 0: SPI\_CS2 signal is from/to CS2 pin. Can be configured in CONF state. (R/W)
- SPI\_CS3\_DIS SPI CS3 pin enable bit. 1: disable CS3, 0: SPI\_CS3 signal is from/to CS3 pin. Can be configured in CONF state. (R/W)
- SPI\_CS4\_DIS SPI CS4 pin enable bit. 1: disable CS4, 0: SPI\_CS4 signal is from/to CS4 pin. Can be configured in CONF state. (R/W)
- SPI\_CS5\_DIS SPI CS5 pin enable bit. 1: disable CS5, 0: SPI\_CS5 signal is from/to CS5 pin. Can be configured in CONF state. (R/W)
- SPI\_CK\_DIS 1: disable SPI\_CLK output. 0: enable SPI\_CLK output. Can be configured in CONF state. (R/W)
- SPI\_MASTER\_CS\_POL In master mode, the bits are the polarity of SPI CS line, the value is equivalent to SPI\_CS ^ SPI\_MASTER\_CS\_POL. Can be configured in CONF state. (R/W)
- SPI\_SLAVE\_CS\_POL Configure SPI slave input CS polarity. 1: invert. 0: not change. Can be configured in CONF state. (R/W)
- SPI\_CK\_IDLE\_EDGE 1: SPI\_CLK line is high when GP-SPI2 is in idle. 0: SPI\_CLK line is low when GP-SPI2 is in idle. Can be configured in CONF state. (R/W)
- SPI\_CS\_KEEP\_ACTIVE SPI CS line keeps low when the bit is set. Can be configured in CONF state. (R/W)
- SPI\_QUAD\_DIN\_PIN\_SWAP 1: SPI quad input swap enable. 0: SPI quad input swap disable. Can be configured in CONF state. (R/W)

![Image](images/27_Chapter_27_img039_2de2a467.png)

## Register 27.9. SPI\_DMA\_CONF\_REG (0x0030)

![Image](images/27_Chapter_27_img040_b9d037dd.png)

- SPI\_DMA\_SLV\_SEG\_TRANS\_EN 1: enable DAM-controlled segmented transfer in slave half-duplex mode. 0: disable. (R/W)
- SPI\_SLV\_RX\_SEG\_TRANS\_CLR\_EN In DMA-controlled half-duplex slave mode, if the size of DMA RX buffer is smaller than the size of the received data, 1: the data in following transfers will not be received. 0: the data in this transfer will not be received, but in the following transfers, if the size of DMA RX buffer is not 0, the data in following transfers will be received, otherwise not. (R/W)
- SPI\_SLV\_TX\_SEG\_TRANS\_CLR\_EN In DMA-controlled half-duplex slave mode, if the size of DMA TX buffer is smaller than the size of the transmitted data, 1: the data in the following transfers will not be updated, i.e. the old data is transmitted repeatedly. 0: the data in this transfer will not be updated. But in the following transfers, if new data is filled in DMA TX FIFO, new data will be transmitted, otherwise not. (R/W)
- SPI\_RX\_EOF\_EN 1: In a DAM-controlled transfer, if the bit number of transferred data is equal to (SPI\_MS\_DATA\_BITLEN + 1), then GDMA\_IN\_SUC\_EOF\_CHn\_INT\_RAW will be set by hardware. 0: GDMA\_IN\_SUC\_EOF\_CHn\_INT\_RAW is set by SPI\_TRANS\_DONE\_INT event in a nonsegmented transfer, or by in a SPI\_DMA\_SEG\_TRANS\_DONE\_INT event in a segmented transfer. (R/W)
- SPI\_DMA\_RX\_ENA Set this bit to enable SPI DMA controlled receive data mode. (R/W)
- SPI\_DMA\_TX\_ENA Set this bit to enable SPI DMA controlled send data mode. (R/W)
- SPI\_RX\_AFIFO\_RST Set this bit to reset spi\_rx\_afifo as shown in Figure 27.5-3 and in Figure 27.5-4 . spi\_rx\_afifo is used to receive data in SPI master and slave transfer. (WT)
- SPI\_BUF\_AFIFO\_RST Set this bit to reset buf\_tx\_afifo as shown in Figure 27.5-3 and in Figure 27.5-4 . buf\_tx\_afifo is used to send data out in CPU-controlled master and slave transfer. (WT)
- SPI\_DMA\_AFIFO\_RST Set this bit to reset dma\_tx\_afifo as shown in Figure 27.5-3 and in Figure 27.5-4. dma\_tx\_afifo is used to send data out in DMA-controlled slave transfer. (WT)

![Image](images/27_Chapter_27_img041_41081815.png)

## Register 27.10. SPI\_SLAVE\_REG (0x00E0)

![Image](images/27_Chapter_27_img042_b3fc5c89.png)

SPI\_CLK\_MODE SPI clock mode control bits. Can be configured in CONF state. (R/W)

- 0: SPI clock is off when CS becomes inactive.
- 1: SPI clock is delayed one cycle after CS becomes inactive.
- 2: SPI clock is delayed two cycles after CS becomes inactive.
- 3: SPI clock is always on.
- SPI\_CLK\_MODE\_13 Configure clock mode. (R/W)
- 1: support SPI clock mode 1 and 3. Output data B[0]/B[7] at the first edge.
- 0: support SPI clock mode 0 and 2. Output data B[1]/B[6] at the first edge.
- SPI\_RSCK\_DATA\_OUT Save half a cycle when TSCK is the same as RSCK. 1: output data at RSCK posedge. 0: output data at TSCK posedge. (R/W)
- SPI\_SLV\_RDDMA\_BITLEN\_EN If this bit is set, SPI\_SLV\_DATA\_BITLEN is used to store the data bit length of Rd\_DMA transfer. (R/W)
- SPI\_SLV\_WRDMA\_BITLEN\_EN If this bit is set, SPI\_SLV\_DATA\_BITLEN is used to store the data bit length of Wr\_DMA transfer. (R/W)
- SPI\_SLV\_RDBUF\_BITLEN\_EN If this bit is set, SPI\_SLV\_DATA\_BITLEN is used to store data bit length of Rd\_BUF transfer. (R/W)
- SPI\_SLV\_WRBUF\_BITLEN\_EN If this bit is set, SPI\_SLV\_DATA\_BITLEN is used to store data bit length of Wr\_BUF transfer. (R/W)
- SPI\_DMA\_SEG\_MAGIC\_VALUE Configure the magic value of BM table in DMA-controlled configurable segmented transfer. (R/W)
- SPI\_SLAVE\_MODE Set SPI work mode. 1: slave mode. 0: master mode. (R/W)
- SPI\_SOFT\_RESET Software reset enable bit. If this bit is set, the SPI clock line, CS line, and data line are reset. Can be configured in CONF state. (WT)
- SPI\_USR\_CONF 1: enable the CONF state of current DMA-controlled configurable segmented transfer, which means the configurable segmented transfer is started. 0: This is not a configurable segmented transfer. (R/W)

![Image](images/27_Chapter_27_img043_9e03018a.png)

## Register 27.11. SPI\_SLAVE1\_REG (0x00E4)

![Image](images/27_Chapter_27_img044_139a2d2d.png)

SPI\_SLV\_DATA\_BITLEN Configure the transferred data bit length in SPI slave full-/half-duplex modes. (R/W/SS)

SPI\_SLV\_LAST\_COMMAND In slave mode, it is the value of command. (R/W/SS)

SPI\_SLV\_LAST\_ADDR In slave mode, it is the value of address. (R/W/SS)

## Register 27.12. SPI\_CLOCK\_REG (0x000C)

![Image](images/27_Chapter_27_img045_10c53426.png)

- SPI\_CLKCNT\_L In master mode, this field must be equal to SPI\_CLKCNT\_N. In slave mode, it must be 0. Can be configured in CONF state. (R/W)
- SPI\_CLKCNT\_H In master mode, this field must be floor((SPI\_CLKCNT\_N + 1)/2 - 1). floor() here is to down round a number, floor(2.2) = 2. In slave mode, it must be 0. Can be configured in CONF state. (R/W)
- SPI\_CLKCNT\_N In master mode, this is the divider of SPI\_CLK. So SPI\_CLK frequency is fapb\_clk/(SPI\_CLKDIV\_PRE + 1)/(SPI\_CLKCNT\_N + 1). Can be configured in CONF state. (R/W)
- SPI\_CLKDIV\_PRE In master mode, this is pre-divider of SPI\_CLK. Can be configured in CONF state. (R/W)
- SPI\_CLK\_EQU\_SYSCLK In master mode, 1: SPI\_CLK is eqaul to APB\_CLK. 0: SPI\_CLK is divided from APB\_CLK. Can be configured in CONF state. (R/W)

![Image](images/27_Chapter_27_img046_a3cb1acc.png)

## Register 27.13. SPI\_CLK\_GATE\_REG (0x00E8)

![Image](images/27_Chapter_27_img047_0a294cd9.png)

SPI\_CLK\_EN Set this bit to enable clock gate. (R/W)

SPI\_MST\_CLK\_ACTIVE Set this bit to power on the SPI module clock. (R/W)

SPI\_MST\_CLK\_SEL This bit is used to select SPI module clock source in master mode. 1: PLL\_F80M\_CLK. 0: XTAL\_CLK. (R/W)

## Register 27.14. SPI\_DIN\_MODE\_REG (0x0024)

![Image](images/27_Chapter_27_img048_fa7d99a4.png)

SPI\_DIN0\_MODE Configure the input mode for FSPID signal. Can be configured in CONF state. (R/W)

- 0: input without delay
- 1: Input at the (SPI\_DIN0\_NUM + 1)th falling edge of clk\_spi\_mst
- 2: Input at the (SPI\_DIN0\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst rising edge cycle
- 3: Input at the (SPI\_DIN0\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst falling edge cycle

SPI\_DIN1\_MODE Configure the input mode for FSPIQ signal. Can be configured in CONF state. (R/W)

- 0: input without delay
- 1: Input at the (SPI\_DIN1\_NUM + 1)th falling edge of clk\_spi\_mst
- 2: Input at the (SPI\_DIN1\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst rising edge cycle
- 3: Input at the (SPI\_DIN1\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst falling edge cycle

SPI\_DIN2\_MODE Configure the input mode for FSPIWP signal. Can be configured in CONF state. (R/W)

- 0: input without delay
- 1: Input at the (SPI\_DIN2\_NUM + 1)th falling edge of clk\_spi\_mst
- 2: Input at the (SPI\_DIN2\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst rising edge cycle
- 3: Input at the (SPI\_DIN2\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst falling edge cycle

Continued on the next page...

## Register 27.14. SPI\_DIN\_MODE\_REG (0x0024)

## Continued from the previous page...

SPI\_DIN3\_MODE Configure the input mode for FSPIHD signal. Can be configured in CONF state. (R/W)

- 0: input without delay
- 1: Input at the (SPI\_DIN3\_NUM + 1)th falling edge of clk\_spi\_mst
- 2: Input at the (SPI\_DIN3\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst rising edge cycle
- 3: Input at the (SPI\_DIN3\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst falling edge cycle

SPI\_TIMING\_HCLK\_ACTIVE 1: enable HCLK (high-frequency clock) in SPI input timing module. 0: disable HCLK. Can be configured in CONF state. (R/W)

## Register 27.15. SPI\_DIN\_NUM\_REG (0x0028)

![Image](images/27_Chapter_27_img049_e7e7c3c4.png)

SPI\_DIN0\_NUM Configure the delays to input signal FSPID based on the setting of SPI\_DIN0\_MODE. Can be configured in CONF state. (R/W)

- 0: delayed by 1 clock cycle
- 1: delayed by 2 clock cycles
- 2: delayed by 3 clock cycles
- 3: delayed by 4 clock cycles

SPI\_DIN1\_NUM Configure the delays to input signal FSPIQ based on the setting of SPI\_DIN1\_MODE . Can be configured in CONF state. (R/W)

- 0: delayed by 1 clock cycle
- 1: delayed by 2 clock cycles
- 2: delayed by 3 clock cycles
- 3: delayed by 4 clock cycles

SPI\_DIN2\_NUM Configure the delays to input signal FSPIWP based on the setting of SPI\_DIN2\_MODE. Can be configured in CONF state. (R/W)

- 0: delayed by 1 clock cycle
- 1: delayed by 2 clock cycles
- 2: delayed by 3 clock cycles
- 3: delayed by 4 clock cycles

SPI\_DIN3\_NUM Configure the delays to input signal FSPIHD based on the setting of SPI\_DIN3\_MODE. Can be configured in CONF state. (R/W)

- 0: delayed by 1 clock cycle
- 1: delayed by 2 clock cycles
- 2: delayed by 3 clock cycles
- 3: delayed by 4 clock cycles

## Register 27.16. SPI\_DOUT\_MODE\_REG (0x002C)

![Image](images/27_Chapter_27_img050_32032947.png)

- SPI\_DOUT0\_MODE Configure the output mode for FSPID signal. Can be configured in CONF state. (R/W)
- 0: output without delay
- 1: output with a delay of a SPI module clock cycle at its falling edge
- SPI\_DOUT1\_MODE Configure the output mode for FSPIQ signal. Can be configured in CONF state.

(R/W)

- 0: output without delay
- 1: output with a delay of a SPI module clock cycle at its falling edge
- SPI\_DOUT2\_MODE Configure the output mode for FSPIWP signal. Can be configured in CONF state. (R/W)
- 0: output without delay
- 1: output with a delay of a SPI module clock cycle at its falling edge
- SPI\_DOUT3\_MODE Configure the output mode for FSPIHD signal. Can be configured in CONF state. (R/W)
- 0: output without delay
- 1: output with a delay of a SPI module clock cycle at its falling edge

## Register 27.17. SPI\_DMA\_INT\_ENA\_REG (0x0034)

![Image](images/27_Chapter_27_img051_ec26aa94.png)

- SPI\_DMA\_INFIFO\_FULL\_ERR\_INT\_ENA The enable bit for SPI\_DMA\_INFIFO\_FULL\_ERR\_INT interrupt. (R/W)
- SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT\_ENA The enable bit for SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT interrupt. (R/W)

SPI\_SLV\_EX\_QPI\_INT\_ENA The enable bit for SPI\_SLV\_EX\_QPI\_INT interrupt. (R/W)

SPI\_SLV\_EN\_QPI\_INT\_ENA The enable bit for SPI\_SLV\_EN\_QPI\_INT interrupt. (R/W)

SPI\_SLV\_CMD7\_INT\_ENA The enable bit for SPI\_SLV\_CMD7\_INT interrupt. (R/W)

- SPI\_SLV\_CMD8\_INT\_ENA The enable bit for SPI\_SLV\_CMD8\_INT interrupt. (R/W)
- SPI\_SLV\_CMD9\_INT\_ENA The enable bit for SPI\_SLV\_CMD9\_INT interrupt. (R/W)

SPI\_SLV\_CMDA\_INT\_ENA The enable bit for SPI\_SLV\_CMDA\_INT interrupt. (R/W)

- SPI\_SLV\_RD\_DMA\_DONE\_INT\_ENA The enable bit for SPI\_SLV\_RD\_DMA\_DONE\_INT interrupt. (R/W)
- SPI\_SLV\_WR\_DMA\_DONE\_INT\_ENA The enable bit for SPI\_SLV\_WR\_DMA\_DONE\_INT interrupt.
- SPI\_SLV\_RD\_BUF\_DONE\_INT\_ENA The enable bit for SPI\_SLV\_RD\_BUF\_DONE\_INT interrupt. (R/W)
- SPI\_SLV\_WR\_BUF\_DONE\_INT\_ENA The enable bit for SPI\_SLV\_WR\_BUF\_DONE\_INT interrupt. (R/W)
- SPI\_TRANS\_DONE\_INT\_ENA The enable bit for SPI\_TRANS\_DONE\_INT interrupt. (R/W)
- SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_ENA The enable bit for SPI\_DMA\_SEG\_TRANS\_DONE\_INT in-

(R/W) terrupt. (R/W)

- SPI\_SEG\_MAGIC\_ERR\_INT\_ENA The enable bit for SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (R/W) Continued on the next page...

## Register 27.17. SPI\_DMA\_INT\_ENA\_REG (0x0034)

Continued from the previous page...

SPI\_SLV\_CMD\_ERR\_INT\_ENA The enable bit for SPI\_SLV\_CMD\_ERR\_INT interrupt. (R/W)

SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_ENA The enable bit for SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (R/W) SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_ENA The enable bit for SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (R/W)

SPI\_APP2\_INT\_ENA The enable bit for SPI\_APP2\_INT interrupt. (R/W)

SPI\_APP1\_INT\_ENA The enable bit for SPI\_APP1\_INT interrupt. (R/W)

## Register 27.18. SPI\_DMA\_INT\_CLR\_REG (0x0038)

![Image](images/27_Chapter_27_img052_71ef9101.png)

SPI\_DMA\_INFIFO\_FULL\_ERR\_INT\_CLR The clear bit for SPI\_DMA\_INFIFO\_FULL\_ERR\_INT interrupt. (WT)

SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT\_CLR The clear bit for SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT interrupt. (WT)

SPI\_SLV\_EX\_QPI\_INT\_CLR The clear bit for SPI\_SLV\_EX\_QPI\_INT interrupt. (WT)

SPI\_SLV\_EN\_QPI\_INT\_CLR The clear bit for SPI\_SLV\_EN\_QPI\_INT interrupt. (WT)

SPI\_SLV\_CMD7\_INT\_CLR The clear bit for SPI\_SLV\_CMD7\_INT interrupt. (WT)

SPI\_SLV\_CMD8\_INT\_CLR The clear bit for SPI\_SLV\_CMD8\_INT interrupt. (WT)

SPI\_SLV\_CMD9\_INT\_CLR The clear bit for SPI\_SLV\_CMD9\_INT interrupt. (WT)

SPI\_SLV\_CMDA\_INT\_CLR The clear bit for SPI\_SLV\_CMDA\_INT interrupt. (WT)

SPI\_SLV\_RD\_DMA\_DONE\_INT\_CLR

- The clear bit for SPI\_SLV\_RD\_DMA\_DONE\_INT interrupt. (WT)
- SPI\_SLV\_WR\_DMA\_DONE\_INT\_CLR The clear bit for SPI\_SLV\_WR\_DMA\_DONE\_INT interrupt. (WT)

SPI\_SLV\_RD\_BUF\_DONE\_INT\_CLR The clear bit for SPI\_SLV\_RD\_BUF\_DONE\_INT interrupt. (WT)

SPI\_SLV\_WR\_BUF\_DONE\_INT\_CLR The clear bit for SPI\_SLV\_WR\_BUF\_DONE\_INT interrupt. (WT)

SPI\_TRANS\_DONE\_INT\_CLR The clear bit for SPI\_TRANS\_DONE\_INT interrupt. (WT)

SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_CLR The clear bit for SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. (WT)

SPI\_SEG\_MAGIC\_ERR\_INT\_CLR The clear bit for SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (WT)

Continued on the next page...

## Register 27.18. SPI\_DMA\_INT\_CLR\_REG (0x0038)

Continued from the previous page...

SPI\_SLV\_CMD\_ERR\_INT\_CLR The clear bit for SPI\_SLV\_CMD\_ERR\_INT interrupt. (WT)

SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_CLR The clear bit for SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (WT)

SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_CLR The clear bit for SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (WT)

SPI\_APP2\_INT\_CLR The clear bit for SPI\_APP2\_INT interrupt. (WT)

SPI\_APP1\_INT\_CLR The clear bit for SPI\_APP1\_INT interrupt. (WT)

![Image](images/27_Chapter_27_img053_a35c37cc.png)

## Register 27.19. SPI\_DMA\_INT\_RAW\_REG (0x003C)

![Image](images/27_Chapter_27_img054_6048fcdc.png)

SPI\_DMA\_INFIFO\_FULL\_ERR\_INT\_RAW The raw bit for SPI\_DMA\_INFIFO\_FULL\_ERR\_INT inter- rupt. (R/W/WTC/SS) SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT\_RAW The raw bit for SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_EX\_QPI\_INT\_RAW The raw bit for SPI\_SLV\_EX\_QPI\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_EN\_QPI\_INT\_RAW The raw bit for SPI\_SLV\_EN\_QPI\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_CMD7\_INT\_RAW The raw bit for SPI\_SLV\_CMD7\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_CMD8\_INT\_RAW The raw bit for SPI\_SLV\_CMD8\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_CMD9\_INT\_RAW The raw bit for SPI\_SLV\_CMD9\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_CMDA\_INT\_RAW The raw bit for SPI\_SLV\_CMDA\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_RD\_DMA\_DONE\_INT\_RAW The raw bit for SPI\_SLV\_RD\_DMA\_DONE\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_WR\_DMA\_DONE\_INT\_RAW The raw bit for SPI\_SLV\_WR\_DMA\_DONE\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_RD\_BUF\_DONE\_INT\_RAW The raw bit for SPI\_SLV\_RD\_BUF\_DONE\_INT interrupt. (R/W/WTC/SS) SPI\_SLV\_WR\_BUF\_DONE\_INT\_RAW The raw bit for SPI\_SLV\_WR\_BUF\_DONE\_INT interrupt. (R/W/WTC/SS) SPI\_TRANS\_DONE\_INT\_RAW The raw bit for SPI\_TRANS\_DONE\_INT interrupt. (R/W/WTC/SS) Continued on the next page...

## Register 27.19. SPI\_DMA\_INT\_RAW\_REG (0x003C)

## Continued from the previous page...

- SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_RAW The raw bit for SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. (R/W/WTC/SS)
- SPI\_SEG\_MAGIC\_ERR\_INT\_RAW The raw bit for SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (R/W/WTC/SS)
- SPI\_SLV\_CMD\_ERR\_INT\_RAW The raw bit for SPI\_SLV\_CMD\_ERR\_INT interrupt. (R/W/WTC/SS)
- SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_RAW The raw bit for SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (R/W/WTC/SS)
- SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_RAW The raw bit for SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (R/W/WTC/SS)
- SPI\_APP2\_INT\_RAW The raw bit for SPI\_APP2\_INT interrupt. The value is only controlled by application. (R/W/WTC)
- SPI\_APP1\_INT\_RAW The raw bit for SPI\_APP1\_INT interrupt. The value is only controlled by application. (R/W/WTC)

![Image](images/27_Chapter_27_img055_5f57df4f.png)

## Register 27.20. SPI\_DMA\_INT\_ST\_REG (0x0040)

![Image](images/27_Chapter_27_img056_096ed044.png)

SPI\_DMA\_INFIFO\_FULL\_ERR\_INT\_ST The status bit for SPI\_DMA\_INFIFO\_FULL\_ERR\_INT interrupt. (RO)

SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT\_ST The status bit for SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT

interrupt. (RO) SPI\_SLV\_EX\_QPI\_INT\_ST The status bit for SPI\_SLV\_EX\_QPI\_INT interrupt. (RO) SPI\_SLV\_EN\_QPI\_INT\_ST The status bit for SPI\_SLV\_EN\_QPI\_INT interrupt. (RO) SPI\_SLV\_CMD7\_INT\_ST The status bit for SPI\_SLV\_CMD7\_INT interrupt. (RO) SPI\_SLV\_CMD8\_INT\_ST The status bit for SPI\_SLV\_CMD8\_INT interrupt. (RO) SPI\_SLV\_CMD9\_INT\_ST The status bit for SPI\_SLV\_CMD9\_INT interrupt. (RO) SPI\_SLV\_CMDA\_INT\_ST The status bit for SPI\_SLV\_CMDA\_INT interrupt. (RO) SPI\_SLV\_RD\_DMA\_DONE\_INT\_ST The status bit for SPI\_SLV\_RD\_DMA\_DONE\_INT interrupt. (RO) SPI\_SLV\_WR\_DMA\_DONE\_INT\_ST The status bit for SPI\_SLV\_WR\_DMA\_DONE\_INT interrupt. (RO) SPI\_SLV\_RD\_BUF\_DONE\_INT\_ST The status bit for SPI\_SLV\_RD\_BUF\_DONE\_INT interrupt. (RO) SPI\_SLV\_WR\_BUF\_DONE\_INT\_ST The status bit for SPI\_SLV\_WR\_BUF\_DONE\_INT interrupt. (RO) SPI\_TRANS\_DONE\_INT\_ST The status bit for SPI\_TRANS\_DONE\_INT interrupt. (RO) SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_ST The status bit for SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. (RO) SPI\_SEG\_MAGIC\_ERR\_INT\_ST The status bit for SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (RO) SPI\_SLV\_CMD\_ERR\_INT\_ST The status bit for SPI\_SLV\_CMD\_ERR\_INT interrupt. (RO) Continued on the next page...

## Register 27.20. SPI\_DMA\_INT\_ST\_REG (0x0040)

Continued from the previous page...

SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_ST The status bit for SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (RO)

SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_ST The status bit for SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (RO)

SPI\_APP2\_INT\_ST The status bit for SPI\_APP2\_INT interrupt. (RO)

SPI\_APP1\_INT\_ST The status bit for SPI\_APP1\_INT interrupt. (RO)

## Register 27.21. SPI\_W0\_REG (0x0098)

![Image](images/27_Chapter_27_img057_24d72e05.png)

![Image](images/27_Chapter_27_img058_bf83c3c8.png)

SPI\_BUF0 32-bit data buffer 0. (R/W/SS)

## Register 27.22. SPI\_W1\_REG (0x009C)

![Image](images/27_Chapter_27_img059_46076928.png)

![Image](images/27_Chapter_27_img060_b3d188c4.png)

SPI\_BUF1 32-bit data buffer 1. (R/W/SS)

## Register 27.23. SPI\_W2\_REG (0x00A0)

![Image](images/27_Chapter_27_img061_9bf475d5.png)

![Image](images/27_Chapter_27_img062_972be4fd.png)

SPI\_BUF2 32-bit data buffer 2. (R/W/SS)

## Register 27.24. SPI\_W3\_REG (0x00A4)

![Image](images/27_Chapter_27_img063_982290d6.png)

![Image](images/27_Chapter_27_img064_f2070222.png)

SPI\_BUF3 32-bit data buffer 3. (R/W/SS)

## Register 27.25. SPI\_W4\_REG (0x00A8)

![Image](images/27_Chapter_27_img065_940243fd.png)

![Image](images/27_Chapter_27_img066_22e5b33e.png)

SPI\_BUF4 32-bit data buffer 4. (R/W/SS)

## Register 27.26. SPI\_W5\_REG (0x00AC)

![Image](images/27_Chapter_27_img067_0e059c49.png)

![Image](images/27_Chapter_27_img068_d789754e.png)

SPI\_BUF5 32-bit data buffer 5. (R/W/SS)

## Register 27.27. SPI\_W6\_REG (0x00B0)

![Image](images/27_Chapter_27_img069_5aac2d7d.png)

![Image](images/27_Chapter_27_img070_0fda21f7.png)

SPI\_BUF6 32-bit data buffer 6. (R/W/SS)

ESP32-C3 TRM (Version 1.3)

## Register 27.28. SPI\_W7\_REG (0x00B4)

![Image](images/27_Chapter_27_img071_51216fe0.png)

![Image](images/27_Chapter_27_img072_b06e6d7c.png)

SPI\_BUF7 32-bit data buffer 7. (R/W/SS)

## Register 27.29. SPI\_W8\_REG (0x00B8)

![Image](images/27_Chapter_27_img073_2ef8bce1.png)

![Image](images/27_Chapter_27_img074_1aa4808e.png)

SPI\_BUF8 32-bit data buffer 8. (R/W/SS)

## Register 27.30. SPI\_W9\_REG (0x00BC)

![Image](images/27_Chapter_27_img075_acfe7504.png)

![Image](images/27_Chapter_27_img076_f0f56236.png)

SPI\_BUF9 32-bit data buffer 9. (R/W/SS)

## Register 27.31. SPI\_W10\_REG (0x00C0)

![Image](images/27_Chapter_27_img077_6194edcc.png)

![Image](images/27_Chapter_27_img078_a754d0d3.png)

SPI\_BUF10 32-bit data buffer 10. (R/W/SS)

## Register 27.32. SPI\_W11\_REG (0x00C4)

![Image](images/27_Chapter_27_img079_30283f56.png)

![Image](images/27_Chapter_27_img080_d91e47ed.png)

SPI\_BUF11 32-bit data buffer 11. (R/W/SS)

## Register 27.33. SPI\_W12\_REG (0x00C8)

![Image](images/27_Chapter_27_img081_4f931188.png)

![Image](images/27_Chapter_27_img082_e4b96247.png)

SPI\_BUF12 32-bit data buffer 12. (R/W/SS)

## Register 27.34. SPI\_W13\_REG (0x00CC)

![Image](images/27_Chapter_27_img083_61034317.png)

![Image](images/27_Chapter_27_img084_cfca2551.png)

SPI\_BUF13 32-bit data buffer 13. (R/W/SS)

## Register 27.35. SPI\_W14\_REG (0x00D0)

![Image](images/27_Chapter_27_img085_7b70feaa.png)

![Image](images/27_Chapter_27_img086_9ad2ba84.png)

SPI\_BUF14 32-bit data buffer 14. (R/W/SS)

ESP32-C3 TRM (Version 1.3)

## Register 27.36. SPI\_W15\_REG (0x00D4)

![Image](images/27_Chapter_27_img087_55505a20.png)

![Image](images/27_Chapter_27_img088_4be41af5.png)

SPI\_BUF15 32-bit data buffer 15. (R/W/SS)

![Image](images/27_Chapter_27_img089_f674d9d3.png)

SPI\_DATE Version control register. (R/W)
