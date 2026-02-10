---
chapter: 28
title: "Chapter 28"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 28

## SPI Controller (SPI)

## 28.1 Overview

The Serial Peripheral Interface (SPI) is a synchronous serial interface useful for communication with external peripherals. The ESP32-C6 chip integrates three SPI controllers:

- SPI0,
- SPI1,
- and General Purpose SPI2 (GP-SPI2).

SPI0 and SPI1 controllers (MSPI) are primarily reserved for internal use to communicate with external flash and PSRAM memory. This chapter mainly focuses on the GP-SPI2 controller.

## 28.2 Glossary

To better illustrate the functions of GP-SPI2, the following terms are used in this chapter.

| Master Mode                     | GP-SPI2 acts as an SPI master and initiates SPI transactions.                                                                                                                                                 |
|---------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Slave Mode                      | GP-SPI2 acts as an SPI slave and exchanges data with its master when its CS is asserted.                                                                                                                      |
| MISO                            | Master in, slave out, data transmission from a slave to a master.                                                                                                                                             |
| MOSI                            | Master out, slave in, data transmission from a master to a slave                                                                                                                                              |
| Transaction                     | One instance of a master asserting a CS line, transferring data to and from a slave, and de-asserting the CS line. Transactions are atomic, which means they can never be interrupted by another transaction. |
| SPI Transfer                    | The whole process of an SPI master exchanging data with a slave. One SPI transfer consists of one or more SPI transactions.                                                                                   |
| Single Transfer                 | An SPI transfer that consists of only one transaction.                                                                                                                                                        |
| CPU-Controlled Transfer         | A data transfer that happens between CPU buffer SPI_W0_REG  ~ SPI_W15_REG and SPI peripheral.                                                                                                                 |
| DMA-Controlled Transfer         | A data transfer that happens between DMA and SPI peripheral, controlled by the DMA engine.                                                                                                                    |
| Configurable Segmented Transfer | A data transfer controlled by DMA in SPI master mode. Such trans fer consists of multiple transactions (segments), and each trans action can be configured independently.                                   |
| Slave Segmented Transfer        | A data transfer controlled by DMA in SPI slave mode. Such transfer consists of multiple transactions (segments).                                                                                              |

| Full-duplex        | The sending line and receiving line between the master and the slave are independent. Sending data and receiving data happen at the same time.                     |
|--------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Half-duplex        | Only one side, the master or the slave, sends data, and the other side receives data. Sending data and receiving data can not hap pen simultaneously on one side. |
| 4-line full-duplex | 4-line here means: clock line, CS line, and two data lines. The two data lines can be used to send or receive data simultaneously.                                 |
| 4-line half-duplex | 4-line here means: clock line, CS line, and two data lines. The two data lines can not be used simultaneously.                                                     |
| 3-line half-duplex | 3-line here means: clock line, CS line, and one data line. The data line is used to transmit or receive data.                                                      |
| 1-bit SPI          | In one clock cycle, one bit can be transferred.                                                                                                                    |
| (2-bit) Dual SPI   | In one clock cycle, two bits can be transferred.                                                                                                                   |
| Dual Output Read   | A data mode of Dual SPI. In one clock cycle, one bit of a com mand, or one bit of an address, or two bits of data can be trans ferred.                           |
| Dual I/O Read      | Another data mode of Dual SPI. In one clock cycle, one bit of a command, or two bits of an address, or two bits of data can be transferred.                        |
| (4-bit) Quad SPI   | In one clock cycle, four bits can be transferred.                                                                                                                  |
| Quad Output Read   | A data mode of Quad SPI. In one clock cycle, one bit of a com mand, or one bit of an address, or four bits of data can be trans ferred.                          |
| Quad I/O Read      | Another data mode of Quad SPI. In one clock cycle, one bit of a command, or four bits of an address, or four bits of data can be transferred.                      |
| QPI                | In one clock cycle, four bits of a command, or four bits of an address, or four bits of data can be transferred.                                                   |
| FSPI               | Fast SPI. The prefix of the signals for GP-SPI2. FSPI bus signals are routed to GPIO pins via either GPIO matrix or IO MUX.                                        |

## 28.3 Features

Some of the key features of GP-SPI2 are:

- Works as master or as slave
- Half- and full-duplex communications
- CPU- and DMA-controlled transfers
- Various data modes:
- – 1-bit SPI mode
- – 2-bit Dual SPI mode
- – 4-bit Quad SPI mode

- – QPI mode
- Configurable module clock frequency:
- Configurable data length:
- – CPU-controlled transfer as master or as slave: 1 ~ 64 B
- – DMA-controlled single transfer as master: 1 ~ 32 KB
- – DMA-controlled configurable segmented transfer as master: data length is unlimited
- – DMA-controlled single transfer or segmented transfer as slave: data length is unlimited
- Configurable bit read/write order
- Independent interrupts for CPU-controlled transfer and DMA-controlled transfer
- Configurable clock polarity and phase
- Four SPI clock modes: mode 0 ~ mode 3
- Six CS lines as master: CS0 ~ CS5
- Able to communicate with SPI devices, such as a sensor, a screen controller, as well as a flash or RAM chip

- – Master: up to 80 MHz

- – Slave: up to 40 MHz

## 28.4 Architectural Overview

Figure 28.4-1. SPI Module Overview

![Image](images/28_Chapter_28_img001_ced34c41.png)

Figure 28.4-1 shows an overview of SPI module. GP-SPI2 exchanges data with SPI devices by the following ways:

- CPU-controlled transfer: CPU ←&gt; GP-SPI2 ←&gt; SPI devices

- DMA-controlled transfer: GDMA ←&gt; GP-SPI2 ←&gt; SPI devices

The signals for GP-SPI2 are prefixed with "FSPI" (Fast SPI). FSPI bus signals are routed to GPIO pins via either GPIO matrix or IO MUX. For more information, see Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) .

![Image](images/28_Chapter_28_img002_5de03e41.png)

## 28.5 Functional Description

## 28.5.1 Data Modes

GP-SPI2 can be configured as either a master or a slave to communicate with other SPI devices in the following data modes. See Table 28.5-1 .

Table 28.5-1. Data Modes Supported by GP-SPI2

| Supported Mode   | Supported Mode   | CMD State   | Address State   | Data State   |
|------------------|------------------|-------------|-----------------|--------------|
| 1-bit SPI        | 1-bit SPI        | 1-bit       | 1-bit           | 1-bit        |
| Dual SPI         | Dual Output Read | 1-bit       | 1-bit           | 2-bit        |
| Dual SPI         | Dual I/O Read    | 1-bit       | 2-bit           | 2-bit        |
| Quad SPI         | Quad Output Read | 1-bit       | 1-bit           | 4-bit        |
| Quad SPI         | Quad I/O Read    | 1-bit       | 4-bit           | 4-bit        |
| QPI              | QPI              | 4-bit       | 4-bit           | 4-bit        |

For more information about the data modes used when GP-SPI2 works as a master or a slave, see Section 28.5.8 and Section 28.5.9, respectively.

## 28.5.2 Introduction to FSPI Bus Signals

The functional description of FSPI bus signals is shown in Table 28.5-2. Table 28.5-3 lists the signals used in various SPI modes.

Table 28.5-2. Functional Description of FSPI Bus Signals

| FSPI Bus Signal   | Function                                       |
|-------------------|------------------------------------------------|
| FSPID             | MOSI/SIO0 (serial data input and output, bit0) |
| FSPIQ             | MISO/SIO1 (serial data input and output, bit1) |
| FSPIWP            | SIO2 (serial data input and output, bit2)      |
| FSPIHD            | SIO3 (serial data input and output, bit3)      |
| FSPICLK           | Input and output clock as master/slave         |
| FSPICS0           | Input and output CS signal as master/slave     |
| FSPICS1 ~ 5       | Output CS signal as master                     |

Chapter 28 SPI Controller (SPI)

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

| FD  Y                  |     |           |     |
|------------------------|-----|-----------|-----|
| FD  Y                  | Y   | Y         | Y   |
| FD  Y                  | Y Y | Y Y Y Y   | Y   |
|                        |     | 5         | 5   |
|                        | Y Y | Y Y Y     | Y   |
| 4-bit Quad SPI         |     | Y         |     |
|                        | Y Y | Y Y Y Y 4 | Y 4 |
| Master  2-bit Dual SPI |     |           |     |

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

825

Submit Documentation Feedback

Table 28.5-3. Signals Used in Various SPI Modes

Slave

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

ESP32-C6 TRM (Version 1.1)

GoBack

## 28.5.3 Bit Read/Write Order Control

When operating as master:

- The bit order of the command, address, and data sent by the GP-SPI2 master is controlled by SPI\_WR\_BIT\_ORDER .
- The bit order of the data received by the master is controlled by SPI\_RD\_BIT\_ORDER .

When operating as slave:

- The bit order of the data sent by the GP-SPI2 slave is controlled by SPI\_WR\_BIT\_ORDER .
- The bit order of the command, address, and data received by the slave is controlled by SPI\_RD\_BIT\_ORDER .

Table 28.5-4 shows the function of SPI\_RD/WR\_BIT\_ORDER .

Chapter 28 SPI Controller (SPI)

= 3 (LSB)

SPI\_RD/WR\_BIT\_ORDER

B0→B1→B2→B3→B4→B5→B6→B7

B0→B2→B4→B6

= 1 (LSB)

SPI\_RD/WR\_BIT\_ORDER

= 2 (MSB)

SPI\_RD/WR\_BIT\_ORDER

= 0 (MSB)

SPI\_RD/WR\_BIT\_ORDER

FSPI Bus Data

B0→B1→B2→B3→B4→B5→B6→B7

B7→B6→B5→B4→B3→B2→B1→B0

B1→B3→B5→B7

B1→B3→B5→B7

B0→B2→B4→B6

B0→B4

B3→B7

B1→B5

B2→B6

B2→B6

B1→B5

B3→B7

B0→B4

| B4→B0   |       |
|---------|-------|
| B4→B0   | B7→B3 |
| B4→B0   |       |
| B4→B0   |       |

B7→B6→B5→B4→B3→B2→B1→B0

FSPID or FSPIQ

B6→B4→B2→B0

B7→B5→B3→B1

FSPIQ

B7→B5→B3→B1

B6→B4→B2→B0

FSPID

B7→B3

FSPIHD

Bit Mode

1-bit mode

2-bit mode

Espressif Systems

B6→B2

FSPIWP

B5→B1

FSPIQ

B4→B0

FSPID

Table 28.5-4. Bit Order Control in GP-SPI2

4-bit mode

827

Submit Documentation Feedback

GoBack

ESP32-C6 TRM (Version 1.1)

## 28.5.4 Transfer Types

The transfer types supported by GP-SPI2 when working as a master or a slave are shown on Table 28.5-5 .

Table 28.5-5. Supported Transfer Types as Master or Slave

| Mode   | Mode        | CPU-Controlled Single Transfer   | DMA-Controlled Single Transfer   | DMA-Controlled Configurable Segmented Transfer   | DMA-Controlled Slave Segmented Transfer   |
|--------|-------------|----------------------------------|----------------------------------|--------------------------------------------------|-------------------------------------------|
| Master | Full-Duplex | Y                                | Y                                | Y                                                | –                                         |
| Master | Half-Duplex | Y                                | Y                                | Y                                                | –                                         |
| Slave  | Full-Duplex | Y                                | Y                                | –                                                | Y                                         |
| Slave  | Half-Duplex | Y                                | Y                                | –                                                | Y                                         |

The following sections provide detailed information about the transfer types listed in the table above.

## 28.5.5 CPU-Controlled Data Transfer

GP-SPI2 provides 16 x 32-bit data buffers, i.e., SPI\_W0\_REG ~ SPI\_W15\_REG, as shown in Figure 28.5-1 . CPU-controlled transfer indicates the transfer in which the data to send is from GP-SPI2 data buffer and the received data is stored to GP-SPI2 data buffer. In such transfer, every single transaction needs to be triggered by the CPU after its related registers are configured. For such reason, the CPU-controlled transfer is always single transfer (consisting of only one transaction). CPU-controlled transfer supports full-duplex communication and half-duplex communication.

Figure 28.5-1. Data Buffer Used in CPU-Controlled Transfer

![Image](images/28_Chapter_28_img003_7d3b1d81.png)

## 28.5.5.1 CPU-Controlled Master Transfer

In a CPU-controlled master full-duplex or half-duplex transfer, the RX or TX data is saved to or sent from SPI\_W0\_REG ~ SPI\_W15\_REG. The bits SPI\_USR\_MOSI\_HIGHPART and SPI\_USR\_MISO\_HIGHPART control which buffers are used. See the list below.

## · TX data

- – When SPI\_USR\_MOSI\_HIGHPART is cleared, i.e., high part mode is disabled, TX data is read from SPI\_W0\_REG ~ SPI\_W15\_REG and the data address is incremented by 1 on each byte transferred. If

the data byte length is larger than 64, the data in SPI\_W0\_REG ∼ SPI\_W15\_REG may be sent more than once. Take each 256 bytes as a cycle:

* The first 64 bytes (Byte 0 ~ Byte 63) are read from SPI\_W0\_REG ~ SPI\_W15\_REG, respectively.
* Byte 64 ~ Byte 255 are read from SPI\_W15\_REG[31:24] repeatedly.
* Byte 256 ~ Byte 319 (the first 64 bytes in the another 256 bytes) are read from SPI\_W0\_REG ~ SPI\_W15\_REG again, respectively, same as the behaviors described above.

For instance: to send 258 bytes (Byte 0 ~ Byte 257), the data is read from the registers as follows:

* The first 64 bytes (Byte 0 ~ Byte 63) are read from SPI\_W0\_REG ~ SPI\_W15\_REG, respectively.
* Byte 64 ~ Byte 255 are read from SPI\_W15\_REG[31:24] repeatedly.
* The other bytes (Byte 256 and Byte 257) are read from SPI\_W0\_REG[7:0] and SPI\_W0\_REG[15:8] again, respectively. The logic is:
- The address to read data for Byte 256 is the result of (256 % 64 = 0), i.e.,SPI\_W0\_REG[7:0].
- The address to read data for Byte 257 is the result of (257 % 64 = 1), i.e., SPI\_W0\_REG[15:8].
- – When SPI\_USR\_MOSI\_HIGHPART is set, i.e., high part mode is enabled, TX data is read from SPI\_W8\_REG ~ SPI\_W15\_REG and the data address is incremented by 1 on each byte transferred. If the data byte length is larger than 32, the data in SPI\_W8\_REG ∼ SPI\_W15\_REG may be sent more than once. Take each 256 bytes as a cycle:
* The first 32 bytes (Byte 0 ~ Byte 31) are read from SPI\_W8\_REG ~ SPI\_W15\_REG, respectively.
* Byte 32 ~ Byte 255 are read from SPI\_W15\_REG[31:24] repeatedly.
* Byte 256 ~ Byte 287 (the first 32 bytes in the another 256 bytes) are read from SPI\_W8\_REG ~ SPI\_W15\_REG again, respectively, same as the behaviors described above.

For instance: to send 258 bytes (Byte 0 ~ Byte 257), the data is read from the registers as follows:

* The first 32 bytes (Byte 0 ~ Byte 31) are read from SPI\_W8\_REG ~ SPI\_W15\_REG, respectively.
* Byte 32 ~ Byte 255 are read from SPI\_W15\_REG[31:24] repeatedly.
* The other bytes (Byte 256 and Byte 257) are read from SPI\_W8\_REG[7:0] and SPI\_W8\_REG[15:8] again, respectively. The logic is:
- The address to read data for Byte 256 is the result of (256 % 32 = 0), i.e., SPI\_W8\_REG[7:0].
- The address to read data for Byte 257 is the result of (257 % 32 = 1), i.e., SPI\_W8\_REG[15:8].

## · RX data

- – When SPI\_USR\_MISO\_HIGHPART is cleared, i.e., high part mode is disabled, RX data is saved to SPI\_W0\_REG ~ SPI\_W15\_REG, and the data address is incremented by 1 on each byte transferred. If the data byte length is larger than 64, the data in SPI\_W0\_REG ∼ SPI\_W15\_REG may be overwritten. Take each 256 bytes as a cycle:
* The first 64 bytes (Byte 0 ~ Byte 63) are saved to SPI\_W0\_REG ~ SPI\_W15\_REG, respectively.

## Note:

- TX/RX data address mentioned above both are byte-addressable.
- – If high part mode is disabled, Address 0 stands for SPI\_W0\_REG[7:0], and Address 1 for SPI\_W0\_REG[15:8], and so on.
- – If high part mode is enabled, Address 0 stands for SPI\_W8\_REG[7:0], and Address 1 for SPI\_W8\_REG[15:8], and so on.

The largest address points to SPI\_W15\_REG[31:24].

- To avoid any possible error in TX/RX data, such as TX data being sent more than once or RX data being overwritten, please make sure the registers are configured correctly.
* Byte 64 ~ Byte 255 are saved to SPI\_W15\_REG[31:24] repeatedly.
* Byte 255 ~ Byte 319 (the first 64 bytes in the another 256 bytes) are saved to SPI\_W0\_REG ~ SPI\_W15\_REG again, respectively, same as the behaviors described above.

For instance: to receive 258 bytes (Byte 0 ~ Byte 257), the data is saved to the registers as follows:

* The first 64 bytes (Byte 0 ~ Byte 63) are saved to SPI\_W0\_REG ~ SPI\_W15\_REG, respectively.
* Byte 64 ~ Byte 255 are saved to SPI\_W15\_REG[31:24] repeatedly.
* The other bytes (Byte 256 and Byte 257) are saved to SPI\_W0\_REG[7:0] and SPI\_W0\_REG[15:8] again, respectively. The logic is:
- The address to save Byte 256 is the result of (256 % 64 = 0), i.e., SPI\_W0\_REG[7:0].
- The address to save Byte 257 is the result of (257 % 64 = 1), i.e., SPI\_W0\_REG[15:8].
- – When SPI\_USR\_MISO\_HIGHPART is set, i.e., high part mode is enabled, the RX data is saved to
- SPI\_W8\_REG ∼ SPI\_W15\_REG, and the data address is incremented by 1 on each byte transferred. If the data byte length is larger than 32, the content of SPI\_W8\_REG ∼ SPI\_W15\_REG may be overwritten. Take each 256 bytes as a cycle:
* Byte 0 ~ Byte 31 are saved to SPI\_W8\_REG ~ SPI\_W15\_REG, respectively.
* Byte 32 ~ Byte 255 are saved to SPI\_W15\_REG[31:24] repeatedly.
* Byte 256 ~ Byte 287 (the first 32 bytes in the another 256 bytes) are saved to SPI\_W8\_REG ~ SPI\_W15\_REG again, respectively.

For instance: to receive 258 bytes (Byte 0 ~ Byte 257), the data is saved to the registers as follows:

* The first 32 bytes (Byte 0 ~ Byte 31) are saved to SPI\_W8\_REG ~ SPI\_W15\_REG, respectively.
* Byte 32 ~ Byte 255 are saved to SPI\_W15\_REG[31:24] repeatedly.
* The other bytes (Byte 256 and Byte 257) are saved to SPI\_W8\_REG[7:0] and SPI\_W8\_REG[15:8] again, respectively. The logic is:
- The address to save Byte 256 is the result of (256 % 32 = 0), i.e., SPI\_W8\_REG[7:0].
- The address to save Byte 257 is the result of (257 % 32 = 1), i.e., SPI\_W8\_REG[15:8].

## 28.5.5.2 CPU-Controlled Slave Transfer

In a CPU-controlled slave full-duplex or half-duplex transfer, the RX data or TX data is saved to or sent from SPI\_W0\_REG ~ SPI\_W15\_REG, which are byte-addressable.

- In full-duplex communication, the address of SPI\_W0\_REG ~ SPI\_W15\_REG starts from 0 and is incremented by 1 on each byte transferred. If the data address is larger than 63, the data in SPI\_W0\_REG ~ SPI\_W15\_REG will be overwritten, same as the behaviors described in the master mode when high part mode is disabled.
- In half-duplex communication, the ADDR value in transmission format is the start address of the RX or TX data, corresponding to the registers SPI\_W0\_REG ~ SPI\_W15\_REG. The RX or TX address is incremented by 1 on each byte transferred. If the address is larger than 63 (the highest byte address, i.e., SPI\_W15\_REG[31:24]), the data in SPI\_W8\_REG ~ SPI\_W15\_REG will be overwritten, same as the behaviors described in the master mode when high part mode is enabled.

According to your applications, the registers SPI\_W0\_REG ~ SPI\_W15\_REG can be used as:

- data buffers only
- data buffers and status buffers
- status buffers only

## 28.5.6 DMA-Controlled Data Transfer

DMA-controlled transfer refers to the transfer in which the GDMA RX module receives data and the GDMA TX module sends data. This transfer is supported both as master and as slave.

A DMA-controlled transfer can be:

- a single transfer, consisting of only one transaction. GP-SPI2 supports this transfer both as master and as slave.
- a configurable segmented transfer, consisting of several transactions (segments). GP-SPI2 supports this transfer only as master. For more information, see Section 28.5.8.5 .
- a slave segmented transfer, consisting of several transactions (segments). GP-SPI2 supports this transfer only as slave. For more information, see Section 28.5.9.3 .

A DMA-controlled transfer only needs to be triggered once by CPU. When such a transfer is triggered, data is transferred by the GDMA engine from or to the DMA-linked memory, without CPU operation.

DMA-controlled transfer supports full-duplex communication, half-duplex communication and functions described in Section 28.5.8 and Section 28.5.9. Meanwhile, the GDMA RX module is independent from the GDMA TX module, which means that there are four kinds of full-duplex communications:

- Data is received in DMA-controlled mode and sent in DMA-controlled mode.
- Data is received in DMA-controlled mode but sent in CPU-controlled mode.
- Data is received in CPU-controlled mode but sent in DMA-controlled mode.
- Data is received in CPU-controlled mode and sent in CPU-controlled mode.

## 28.5.6.1 GDMA Configuration

- Select a GDMA channeln, and configure a GDMA TX/RX descriptor. See Chapter 4 GDMA Controller (GDMA) .
- Set the bit GDMA\_INLINK\_START\_CHn or GDMA\_OUTLINK\_START\_CHn to start GDMA RX engine and TX engine, respectively.
- Before all the GDMA TX buffer is used or the GDMA TX engine is reset, if GDMA\_OUTLINK\_RESTART\_CHn is set, a new TX buffer will be added to the end of the last TX buffer in use.
- GDMA RX buffer is linked in the same way as the GDMA TX buffer, by setting GDMA\_INLINK\_START\_CHn or GDMA\_INLINK\_RESTART\_CHn .
- The TX and RX data lengths are determined by the configured GDMA TX and RX buffer respectively, both of which are 0 ~ 32 KB.
- Initialize GDMA inlink and outlink before GDMA starts. The bits SPI\_DMA\_RX\_ENA and SPI\_DMA\_TX\_ENA in register SPI\_DMA\_CONF\_REG should be set, otherwise the read/write data will be stored to/sent from the registers SPI\_W0\_REG ~ SPI\_W15\_REG .

When operating as master, if GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA is set, then the interrupt GDMA\_IN\_SUC\_EOF\_CHn\_INT will be triggered when one single transfer or one configurable segmented transfer is finished.

When operating as slave, if GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA is set, then the interrupt GDMA\_IN\_SUC\_EOF\_CHn\_INT will be triggered when one of the following conditions are met.

Table 28.5-6. Interrupt Trigger Condition on GP-SPI2 Data Transfer as Slave

| Transfer Type            |   Control Bit 1 |   Control Bit2 | Condition                                                                                                              |
|--------------------------|-----------------|----------------|------------------------------------------------------------------------------------------------------------------------|
| Slave Single Transfer    |               0 |              0 | A single transfer is done.                                                                                             |
| Slave Single Transfer    |               1 |              0 | A single transfer is done. Or the length of the re ceived data is equal to (SPI_MS_DATA_BITLEN + 1)                   |
| Slave Segmented Transfer |               0 |              1 | (CMD7 or End_SEG_TRANS) is received correctly.                                                                         |
| Slave Segmented Transfer |               1 |              1 | (CMD7 or End_SEG_TRANS) is received correctly. Or the length of the received data is equal to (SPI_MS_DATA_BITLEN + 1) |

## 28.5.6.2 GDMA TX/RX Buffer Length Control

It is recommended that the length of configured GDMA TX/RX buffer is equal to the length of actual data transferred.

- If the length of configured GDMA TX buffer is shorter than that of actual data transferred, the extra data will be the same as the last transferred data. SPI\_OUTFIFO\_EMPTY\_ERR\_INT and GDMA\_OUT\_EOF\_CHn\_INT are triggered.
- If the length of configured GDMA TX buffer is longer than that of actual data transferred, the TX buffer is not fully used, and the remaining buffer will be used for following transaction even if a new TX buffer is linked later. Please keep it in mind. Or save the unused data and reset DMA.

- If the length of configured GDMA RX buffer is shorter than that of actual data transferred, the extra data will be lost. The interrupts SPI\_INFIFO\_FULL\_ERR\_INT and SPI\_TRANS\_DONE\_INT are triggered. But GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt is not generated.
- If the length of configured GDMA RX buffer is longer than that of actual data transferred, the RX buffer is not fully used, and the remaining buffer is discarded. In the following transaction, a new linked buffer will be used directly.

## 28.5.7 Data Flow Control

CPU-controlled and DMA-controlled transfers are supported in GP-SPI2 both as master and as slave. CPU-controlled transfer means that data is transferred between registers SPI\_W0\_REG ~ SPI\_W15\_REG and the SPI device. DMA-controlled transfer means that data is transferred between the configured GDMA TX/RX buffer and the SPI device. To select between the two transfer modes, configure SPI\_DMA\_RX\_ENA and SPI\_DMA\_TX\_ENA before the transfer starts.

## 28.5.7.1 GP-SPI2 Functional Blocks

Figure 28.5-2. GP-SPI2 Block Diagram

![Image](images/28_Chapter_28_img004_4fd50a73.png)

Figure 28.5-2 shows the main functional blocks in GP-SPI2, including:

- Master FSM: all the features supported in GP-SPI2 as master are controlled by this state machine together with register configuration.
- SPI Buffer: SPI\_W0\_REG ~ SPI\_W15\_REG. See Figure 28.5-1. The data transferred in CPU-controlled mode is prepared in this buffer.
- Timing Module: captures data on FSPI bus.
- spi\_mst/slv\_din\_ctrl and spi\_mst/slv\_dout\_ctrl: converts the TX/RX data into bytes.
- spi\_rx\_afifo: stores the received data.
- buf\_tx\_afifo: stores the data to send.
- dma\_tx\_afifo: stores the data from GDMA.
- clk\_spi\_mst: this clock is the module clock of GP-SPI2 and derived from PLL\_CLK. It is used in GP-SPI2 as master to generate SPI\_CLK signal for data transfer and for slaves.

- SPI\_CLK Generator: generates SPI\_CLK by dividing clk\_spi\_mst. The divider is determined by SPI\_CLKCNT\_N and SPI\_CLKDIV\_PRE. See Section 28.7 .
- SPI\_CLK\_out Mode Control: outputs the SPI\_CLK signal for data transfer and for slaves.
- SPI\_CLK\_in Mode Control: captures the SPI\_CLK signal from SPI master when GP-SPI2 works as a slave.

## 28.5.7.2 Data Flow Control as Master

Figure 28.5-3. Data Flow Control in GP-SPI2 as Master

![Image](images/28_Chapter_28_img005_7c8b8f9d.png)

Figure 28.5-3 shows the data flow of GP-SPI2 as master. Its control logic is as follows:

- RX data: data in FSPI bus is captured by Timing Module, converted in units of bytes by spi\_mst\_din\_ctrl module, then buffered in spi\_rx\_afifo, and finally stored in corresponding addresses according to the transfer modes.
- – CPU-controlled transfer: the data is stored to registers SPI\_W0\_REG ~ SPI\_W15\_REG .
- – DMA-controlled transfer: the data is stored to GDMA RX buffer.
- TX data: the TX data is from corresponding addresses according to transfer modes and is saved to buf\_tx\_afifo .
- – CPU-controlled transfer: TX data is from SPI\_W0\_REG ~ SPI\_W15\_REG .
- – DMA-controlled transfer: TX data is from GDMA TX buffer.

The data in buf\_tx\_afifo is sent out to Timing Module in 1/2/4-bit modes, controlled by GP-SPI2 state machine. The Timing Module can be used for timing compensation. For more information, see Section 28.8 .

## 28.5.7.3 Data Flow Control as Slave

Figure 28.5-4. Data Flow Control in GP-SPI2 as Slave

![Image](images/28_Chapter_28_img006_53585e38.png)

Figure 28.5-4 shows the data flow in GP-SPI2 as slave. Its control logic is as follows:

- In CPU/DMA-controlled full-/half-duplex transfer, when an external SPI master starts the SPI transfer, data on the FSPI bus is captured, converted into unit of bytes by the spi\_slv\_din\_ctrl module, and then is stored in spi\_rx\_afifo .
- – In CPU-controlled full-duplex transfer, the received data in spi\_rx\_afifo will be later stored into registers SPI\_W0\_REG ~ SPI\_W15\_REG, successively.
- – In half-duplex Wr\_BUF transfer, when the value of address (SLV\_ADDR[7:0]) is received, the received data in spi\_rx\_afifo will be stored in the related address of registers SPI\_W0\_REG ~ SPI\_W15\_REG
- – In DMA-controlled full-duplex transfer or in half-duplex Wr\_DMA transfer, the received data in spi\_rx\_afifo will be stored in the configured GDMA RX buffer.
- In CPU-controlled full-/half-duplex transfer, the data to send is stored in buf\_tx\_afifo. In DMA-controlled full-/half-duplex transfer, the data to send is stored in dma\_tx\_afifo. Therefore, Rd\_BUF transaction controlled by CPU and Rd\_DMA transaction controlled by DMA can be done in one slave segmented transfer. TX data comes from corresponding addresses according the transfer modes.
- – In CPU-controlled full-duplex transfer, when SPI\_SLAVE\_MODE and SPI\_DOUTDIN are set and SPI\_DMA\_TX\_ENA is cleared, the data in SPI\_W0\_REG ~ SPI\_W15\_REG will be stored into buf\_tx\_afifo;
- – In CPU-controlled half-duplex transfer, when SPI\_SLAVE\_MODE is set, SPI\_DOUTDIN is cleared, Rd\_BUF command and SLV\_ADDR[7:0] are received, the data started from the related address of SPI\_W0\_REG ~ SPI\_W15\_REG will be stored into buf\_tx\_afifo;
- – In DMA-controlled full-duplex transfer, when SPI\_SLAVE\_MODE , SPI\_DOUTDIN and SPI\_DMA\_TX\_ENA are set, the data in the configured GDMA TX buffer will be stored into dma\_tx\_afifo;
- – In DMA-controlled half-duplex transfer, when SPI\_SLAVE\_MODE is set, SPI\_DOUTDIN is cleared, and Rd\_DMA command is received, the data in the configured GDMA TX buffer will be stored into dma\_tx\_afifo .

The data in buf\_tx\_afifo or dma\_tx\_afifo is sent out by spi\_slv\_dout\_ctrl module in 1/2/4-bit modes.

## 28.5.8 GP-SPI2 as a Master

GP-SPI2 can be configured as a SPI master by clearing the bit SPI\_SLAVE\_MODE in SPI\_SLAVE\_REG. In this operation mode, GP-SPI2 provides clock signal (the divided clock from GP-SPI2 module clock) and six CS lines (CS0 ~ CS5).

## Note:

- The length of transferred data must be an integral multiple of byte (8 bits), otherwise the extra bits will be lost. The extra bits here means the result of total data bits mod 8.
- To transfer bits that is not an integral multiple of byte (8 bits), consider implementing it in CMD state or ADDR state.

## 28.5.8.1 State Machine

When GP-SPI2 works as a master, the state machine controls its various states during data transfer, including configuration (CONF), preparation (PREP), command (CMD), address (ADDR), dummy (DUMMY), data out (DOUT), and data in (DIN) states. GP-SPI2 is mainly used to access 1/2/4-bit SPI devices, such as flash and external RAM, thus the naming of GP-SPI2 states keeps consistent with the sequence naming of flash and external RAM. The meaning of each state is described as follows and Figure 28.5-5 shows the workflow of GP-SPI2 state machine.

1. IDLE: GP-SPI2 is not active or is operating as slave.
2. CONF: only used in DMA-controlled configurable segmented transfer. Set SPI\_USR and SPI\_USR\_CONF to enable this state. If this state is not enabled, it means the current transfer is a single transfer.
3. PREP: prepare an SPI transaction and control SPI CS setup time. Set SPI\_USR and SPI\_CS\_SETUP to enable this state.
4. CMD: send command sequence. Set SPI\_USR and SPI\_USR\_COMMAND to enable this state.
5. ADDR: send address sequence. Set SPI\_USR and SPI\_USR\_ADDR to enable this state.
6. DUMMY (wait cycle): send dummy sequence. Set SPI\_USR and SPI\_USR\_DUMMY to enable this state.
7. DATA: transfer data.
- DOUT: send data sequence. Set SPI\_USR and SPI\_USR\_MOSI to enable this state.
- DIN: receive data sequence. Set SPI\_USR and SPI\_USR\_MISO to enable this state.
8. DONE: control SPI CS hold time. Set SPI\_USR to enable this state.

## Note:

To start this state machine, set SPI\_USR first. SPI\_MST\_FD\_WAIT\_DMA\_TX\_DATA controls when SPI\_USR takes effect:

- 0: the configured state takes effect immediately after SPI\_USR and other control registers are configured.
- 1: if DOUT state is configured, the SPI\_USR and other control registers will take effect, and the state machine will start, only when the data is ready in buf\_tx\_afifo .

Chapter 28 SPI Controller (SPI)

GoBack

![Image](images/28_Chapter_28_img007_3c021de2.png)

Espressif Systems

837

Submit Documentation Feedback

ESP32-C6 TRM (Version 1.1)

## Legend to state flow:

- — : corresponding state condition is not satisfied; repeats current state.
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

## 28.5.8.2 Register Configuration for State and Bit Mode Control

## Introduction

The registers, related to GP-SPI2 state control, are listed in Table 28.5-7. Users can enable QPI mode for GP-SPI2 by setting the bit SPI\_QPI\_MODE in register SPI\_USER\_REG .

Table 28.5-7. Registers Used for State Control in 1/2/4-bit Modes

| State   | Control Registers for 1-bit Mode FSPI Bus                    | Control Registers for 2-bit Mode FSPI Bus                                  | Control Registers for 4-bit Mode FSPI Bus                                  |
|---------|--------------------------------------------------------------|----------------------------------------------------------------------------|----------------------------------------------------------------------------|
| CMD     | SPI_USR_COMMAND_VALUE SPI_USR_COMMAND_BITLEN SPI_USR_COMMAND | SPI_USR_COMMAND_VALUE SPI_USR_COMMAND_BITLEN SPI_FCMD_DUAL SPI_USR_COMMAND | SPI_USR_COMMAND_VALUE SPI_USR_COMMAND_BITLEN SPI_FCMD_QUAD SPI_USR_COMMAND |
| ADDR    | SPI_USR_ADDR_VALUE SPI_USR_ADDR_BITLEN SPI_USR_ADDR          | SPI_USR_ADDR_VALUE SPI_USR_ADDR_BITLEN SPI_USR_ADDR SPI_FADDR_DUAL         | SPI_USR_ADDR_VALUE SPI_USR_ADDR_BITLEN SPI_USR_ADDR SPI_FADDR_QUAD         |
| DUMMY   | SPI_USR_DUMMY_CYCLELEN SPI_USR_DUMMY                         | SPI_USR_DUMMY_CYCLELEN SPI_USR_DUMMY                                       | SPI_USR_DUMMY_CYCLELEN SPI_USR_DUMMY                                       |
| DIN     | SPI_USR_MISO SPI_MS_DATA_BITLEN                              | SPI_USR_MISO SPI_MS_DATA_BITLEN SPI_FREAD_DUAL                             | SPI_USR_MISO SPI_MS_DATA_BITLEN SPI_FREAD_QUAD                             |

Table 28.5-7. Registers Used for State Control in 1/2/4-bit Modes

| State   | Control Registers for 1-bit Mode FSPI Bus   | Control Registers for 2-bit Mode FSPI Bus       | Control Registers for 4-bit Mode FSPI Bus       |
|---------|---------------------------------------------|-------------------------------------------------|-------------------------------------------------|
| DOUT    | SPI_USR_MOSI SPI_MS_DATA_BITLEN             | SPI_USR_MOSI SPI_MS_DATA_BITLEN SPI_FWRITE_DUAL | SPI_USR_MOSI SPI_MS_DATA_BITLEN SPI_FWRITE_QUAD |

As shown in Table 28.5-7, the registers in each cell should be configured to set the FSPI bus to corresponding bit mode, i.e., the mode shown in the table header, at a specific state (corresponding to the first column).

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

- Set SPI\_FREAD\_QUAD and SPI\_USR\_MISO .
- Clear SPI\_FREAD\_DUAL .
- Configure GDMA in DMA-controlled mode. In CPU-controlled mode, no action is needed.
5. Clear SPI\_USR\_MOSI .
6. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.
7. Set SPI\_USR to start GP-SPI2 transfer.

When writing data (DOUT state), SPI\_USR\_MOSI should be configured instead, while SPI\_USR\_MISO should be cleared. The output data bit length is the value of SPI\_MS\_DATA\_BITLEN + 1. Output data should be configured in GP-SPI2 data buffer (SPI\_W0\_REG ~ SPI\_W15\_REG) in CPU-controlled mode, or GDMA TX buffer in DMA-controlled mode. The data byte order is incremented from LSB (byte 0) to MSB.

Pay special attention to the command value in SPI\_USR\_COMMAND\_VALUE and to address value in SPI\_USR\_ADDR\_VALUE .

The configuration of command value is as follows:

Table 28.5-8. Sending Sequence of Command Value

| COMMAND_BITLEN 1   | COMMAND_VALUE 2   |   BIT_ORDER 3 | Sending Sequence of Command Value                                                             |
|--------------------|-------------------|---------------|-----------------------------------------------------------------------------------------------|
| 0 - 7              | [7:0]             |             1 | COMMAND_VALUE[COMMAND_BITLEN:0] is sent first.                                                |
| 0 - 7              | [7:0]             |             0 | COMMAND_VALUE[7:7 - COMMAND_BITLEN] is sent first.                                            |
| 8 - 15             | [15:0]            |             1 | COMMAND_VALUE[7:0] is sent first, and then COMMAND_VALUE[COMMAND_BITLEN:8] is sent.           |
| 8 - 15             | [15:0]            |             0 | COMMAND_VALUE[7:0] is sent first, and then  COMMAND_VALUE[15:15 -  COM MAND_BITLEN] is sent. |

The configuration of address value is as follows:

Table 28.5-9. Sending Sequence of Address Value

| ADDR_BITLEN 1   | ADDR_VALUE 2   |   BIT_ORDER 3 | Sending Sequence of Address Value                                                  |
|-----------------|----------------|---------------|------------------------------------------------------------------------------------|
| 0 - 7           | [31:24]        |             1 | ADDR_VALUE[ADDR_BITLEN + 24:24] is sent first.                                     |
| 0 - 7           | [31:24]        |             0 | ADDR_VALUE[31:31 - ADDR_BITLEN] is sent first.                                     |
| 8 - 15          | [31:16]        |             1 | ADDR_VALUE[31:24] is sent first, and then ADDR_VALUE[ADDR_BITLEN + 8:16] is sent.  |
| 8 - 15          | [31:16]        |             0 | ADDR_VALUE[31:24] is sent first, and then ADDR_VALUE[23:31 - ADDR_BITLEN] is sent. |
| 16 - 23         | [31:8]         |             1 | ADDR_VALUE[31:16] is sent first, and then ADDR_VALUE[ADDR_BITLEN - 8:8] is sent.   |
| 16 - 23         | [31:8]         |             0 | ADDR_VALUE[31:16] is sent first, and then ADDR_VALUE[15:31 - ADDR_BITLEN] is sent. |
| 24 - 31         | [31:0]         |             1 | ADDR_VALUE[31:8] is sent first, and then ADDR_VALUE[ADDR_BITLEN - 24:0] is sent.   |
| 24 - 31         | [31:0]         |             0 | ADDR_VALUE[31:8] is sent first, and then ADDR_VALUE[7:31 - ADDR_BITLEN] is sent.   |

## 28.5.8.3 Full-Duplex Communication (1-bit Mode Only)

## Introduction

GP-SPI2 supports SPI full-duplex communication. In this mode, SPI master provides CLK and CS signals, exchanging data with SPI slave in 1-bit mode via MOSI (FSPID, sending) and MISO (FSPIQ, receiving) at the same time. To enable this communication mode, set the bit SPI\_DOUTDIN in register SPI\_USER\_REG. Figure 28.5-6 illustrates the connection of GP-SPI2 with its slave in full-duplex communication.

Figure 28.5-6. Full-Duplex Communication Between GP-SPI2 Master and a Slave

![Image](images/28_Chapter_28_img008_253d82a4.png)

In full-duplex communication, the behavior of states CMD, ADDR, DUMMY, DOUT and DIN are configurable. Usually, the states CMD, ADDR and DUMMY are not used in this communication. The bit length of transferred data is configured in SPI\_MS\_DATA\_BITLEN. The actual bit length used in communication equals to (SPI\_MS\_DATA\_BITLEN + 1).

## Configuration

To start a data transfer, follow the steps below:

- Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
- Configure AHB clock (AHB\_CLK), APB clock (APB\_CLK, see Chapter 8 Reset and Clock) and module clock (clk\_spi\_mst) for the GP-SPI2 module.
- Set SPI\_DOUTDIN and clear SPI\_SLAVE\_MODE, to enable full-duplex communication as master.
- Configure GP-SPI2 registers listed in Table 28.5-7 .
- Configure SPI CS setup time and hold time according to Section 28.6 .
- Set the property of FSPICLK according to Section 28.7 .
- Prepare data according to the selected transfer mode:
- – In CPU-controlled MOSI mode, prepare data in registers SPI\_W0\_REG ~ SPI\_W15\_REG .
- – In DMA-controlled mode,
* configure SPI\_DMA\_TX\_ENA/SPI\_DMA\_RX\_ENA ,
* configure GDMA TX/RX link,
* and start GDMA TX/RX engine, as described in Section 28.5.6 and Section 28.5.7 .
- Configure interrupts and wait for SPI slave to get ready for transfer.
- Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.
- Set SPI\_USR in register SPI\_CMD\_REG to start the transfer and wait for the configured interrupts.

## 28.5.8.4 Half-Duplex Communication (1/2/4-bit Mode)

## Introduction

In this mode, GP-SPI2 provides CLK and CS signals. Only one side (SPI master or slave) can send data at a time, while the other side receives the data. To enable this communication mode, clear the bit SPI\_DOUTDIN in register SPI\_USER\_REG. The standard format of SPI half-duplex communication is CMD + [ADDR +] [DUMMY +] [DOUT or DIN]. The states ADDR, DUMMY, DOUT, and DIN are optional, and can be disabled or enabled independently.

As described in Section 28.5.8.2, the properties of GP-SPI2 states: CMD, ADDR, DUMMY, DOUT and DIN, such as cycle length, value, and parallel bus bit mode, can be set independently. For the register configuration, see Table 28.5-7 .

The detailed properties of half-duplex GP-SPI2 are as follows:

1. CMD: 0 ~ 16 bits, master output, slave input.
2. ADDR: 0 ~ 32 bits, master output, slave input.
3. DUMMY: 0 ~ 256 FSPICLK cycles, master output, slave input.
4. DOUT: 0 ~ 512 bits (64 B) in CPU-controlled mode and 0 ~ 256 Kbits (32 KB) in DMA-controlled mode, master output, slave input.
5. DIN: 0 ~ 512 bits (64 B) in CPU-controlled mode and 0 ~ 256 Kbits (32 KB) in DMA-controlled mode, master input, slave output.

## Configuration

The register configuration is as follows:

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure AHB clock (AHB\_CLK), APB clock (APB\_CLK), and module clock (clk\_spi\_mst) for the GP-SPI2 module.
3. Clear SPI\_DOUTDIN and SPI\_SLAVE\_MODE, to enable half-duplex communication as master.
4. Configure GP-SPI2 registers listed in Table 28.5-7 .
5. Configure SPI CS setup time and hold time according to Section 28.6 .
6. Set the property of FSPICLK according to Section 28.7 .
7. Prepare data according to the selected transfer mode:
- In CPU-controlled MOSI mode, prepare data in registers SPI\_W0\_REG ~ SPI\_W15\_REG .
- In DMA-controlled mode,
10. – configure SPI\_DMA\_TX\_ENA/SPI\_DMA\_RX\_ENA ,
11. – configure GDMA TX/RX link,
12. – and start GDMA TX/RX engine, as described in Section 28.5.6 and Section 28.5.7 .
8. Configure interrupts and wait for SPI slave to get ready for transfer.
9. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.
10. Set SPI\_USR in register SPI\_CMD\_REG to start the transfer and wait for the configured interrupts.

## Application Example

The following example shows how GP-SPI2 accesses flash and external RAM in master half-duplex mode.

Figure 28.5-7. Connection of GP-SPI2 to Flash and External RAM in 4-bit Mode

![Image](images/28_Chapter_28_img009_a47d0de0.png)

Figure 28.5-8 indicates GP-SPI2 Quad I/O Read sequence according to standard flash specification. Other GP-SPI2 command sequences are implemented in accordance with the requirements of SPI slaves.

Figure 28.5-8. SPI Quad I/O Read Command Sequence Sent by GP-SPI2 to Flash

![Image](images/28_Chapter_28_img010_31874964.png)

## 28.5.8.5 DMA-Controlled Configurable Segmented Transfer

## Note:

Note that there is no separate section on how to configure a single transfer as master, since the CONF state of a configurable segmented transfer can be skipped to implement a single transfer.

## Introduction

When GP-SPI2 works as a master, it provides a feature named configurable segmented transfer controlled by DMA.

A DMA-controlled transfer as master can be

- a single transfer, consisting of only one transaction;
- or a configurable segmented transfer, consisting of several transactions (segments).

In a configurable segmented transfer, the registers of each single transaction (segment) are configurable. This feature enables GP-SPI2 to do as many transactions (segments) as configured after such transfer is triggered once by the CPU. Figure 28.5-9 shows how this feature works.

Figure 28.5-9. Configurable Segmented Transfer as Master

![Image](images/28_Chapter_28_img011_72dc4540.png)

As shown in Figure 28.5-9, the registers for one transaction (segment n) can be reconfigured by GP-SPI2

hardware according to the content in its Conf\_bufn during a CONF state, before this segment starts.

It's recommended to provide separate GDMA CONF links and CONF buffers (Conf\_bufi in Figure 28.5-9) for each CONF state. A GDMA TX link is used to connect all the CONF buffers and TX data buffers (Tx\_bufi in Figure 28.5-9) into a chain. Hence, the behavior of the FSPI bus in each segment can be controlled independently.

For example, in a configurable segmented transfer, its segmenti, segmentj, and segmentk can be configured to full-duplex, half-duplex MISO, and half-duplex MOSI, respectively. i , j, and k represent different segment numbers.

Meanwhile, the state of GP-SPI2, the data length and cycle length of the FSPI bus, and the behavior of the GDMA, can be configured independently for each segment. When this whole DMA-controlled transfer (consisting of several segments) has finished, a GP-SPI2 interrupt, SPI\_DMA\_SEG\_TRANS\_DONE\_INT, is triggered.

## Configuration

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure AHB clock (AHB\_CLK), APB clock (APB\_CLK), and module clock (clk\_spi\_mst) for GP-SPI2 module.
3. Clear SPI\_DOUTDIN and SPI\_SLAVE\_MODE, to enable half-duplex communication as master.
4. Configure GP-SPI2 registers listed in Table 28.5-7 .
5. Configure SPI CS setup time and hold time according to Section 28.6 .
6. Set the property of FSPICLK according to Section 28.7 .
7. Prepare descriptors for GDMA CONF buffer and TX data (optional) for each segment. Chain the descriptors of CONF buffer and TX buffers of several segments into one linked list.
8. Similarly, prepare descriptors for RX buffers for each segment and chain them into one linked list.
9. Configure all the needed CONF buffers, TX buffers and RX buffers, respectively for each segment before this DMA-controlled transfer begins.
10. Point GDMA\_OUTLINK\_ADDR\_CHn to the head address of the CONF and TX buffer descriptor linked list, and then set GDMA\_OUTLINK\_START\_CHn to start the TX GDMA.
11. Clear the bit SPI\_RX\_EOF\_EN in register SPI\_DMA\_CONF\_REG. Point GDMA\_INLINK\_ADDR\_CHn to the head address of the RX buffer descriptor linked list, and then set GDMA\_INLINK\_START\_CHn to start the RX GDMA.
12. Set SPI\_USR\_CONF to enable CONF state.
13. Set SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_ENA to enable the SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. Configure other interrupts if needed according to Section 28.9 .
14. Wait for all the slaves to get ready for transfer.
15. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST and SPI\_RX\_AFIFO\_RST, to reset these buffers.
16. Set SPI\_USR to start this DMA-controlled transfer.
17. Wait for SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt, which means this transfer has finished and the data has been stored into corresponding memory.

## Configuration of CONF Buffer and Magic Value

In a configurable segmented transfer, only registers which will change from the last transaction (segment) need to be re-configured to new values in CONF state. The configuration of other registers can be skipped (i.e., kept the same) to save time and chip resources.

The first word in GDMA CONF bufferi, called SPI\_BIT\_MAP\_WORD, defines whether each GP-SPI2 register is to be updated or not in segmenti. The relation of SPI\_BIT\_MAP\_WORD and GP-SPI2 registers to update can be seen in Bitmap (BM) Table, Table 28.5-10. If a bit in the BM table is set to 1, its corresponding register value will be updated in this segment. Otherwise, if some registers should be kept from being changed, the related bits should be set to 0.

Table 28.5-10. BM Table for CONF State

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

To ensure the correctness of the content in each CONF buffer, the value in SPI\_BIT\_MAP\_WORD[31:28] is used as "magic value", and will be compared with SPI\_DMA\_SEG\_MAGIC\_VALUE in register SPI\_SLAVE\_REG . The value of SPI\_DMA\_SEG\_MAGIC\_VALUE should be configured before this DMA-controlled transfer starts, and can not be changed during these segments.

- If SPI\_BIT\_MAP\_WORD[31:28] == SPI\_DMA\_SEG\_MAGIC\_VALUE, this DMA-controlled transfer continues normally; the interrupt SPI\_DMA\_SEG\_TRANS\_DONE\_INT is triggered at the end of this DMA-controlled transfer.
- If SPI\_BIT\_MAP\_WORD[31:28] != SPI\_DMA\_SEG\_MAGIC\_VALUE, GP-SPI2 state (spi\_st) goes back to IDLE and the transfer is ended immediately. The interrupt SPI\_DMA\_SEG\_TRANS\_DONE\_INT is still triggered, with SPI\_SEG\_MAGIC\_ERR\_INT\_RAW bit set to 1.

## CONF Buffer Configuration Example

Table 28.5-11 and Table 28.5-12 provide an example to show how to configure a CONF buffer for a transaction (segment i) in which SPI\_ADDR\_REG , SPI\_CTRL\_REG , SPI\_CLOCK\_REG , SPI\_USER\_REG , SPI\_USER1\_REG need to be updated.

Table 28.5-11. An Example of CONF bufferi in Segmenti

| CONF bufferi     | Note                                                                                                                                                                                                                                    |
|------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SPI_BIT_MAP_WORD | The first word in this buffer. Its value is 0xA000001F in this ex ample when the SPI_DMA_SEG_MAGIC_VALUE is set to 0xA. As shown in Table 28.5-12, bits 0, 1, 2, 3, and 4 are set, indicating the following registers will be updated. |
| SPI_ADDR_REG     | The second word, stores the new value to SPI_ADDR_REG .                                                                                                                                                                                 |
| SPI_CTRL_REG     | The third word, stores the new value to SPI_CTRL_REG .                                                                                                                                                                                  |
| SPI_CLOCK_REG    | The fourth word, stores the new value to SPI_CLOCK_REG .                                                                                                                                                                                |
| SPI_USER_REG     | The fifth word, stores the new value to SPI_USER_REG .                                                                                                                                                                                  |
| SPI_USER1_REG    | The sixth word, stores the new value to SPI_USER1_REG .                                                                                                                                                                                 |

Table 28.5-12. BM Bit Value v.s. Register to Be Updated in This Example

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
- SPI\_USR\_CONF\_NXT: if segmenti is not the final transaction of this whole DMA-controlled transfer, its SPI\_USR\_CONF\_NXT bit should be set to 1.
- SPI\_CONF\_BITLEN: GP-SPI2 CS setup time and hold time are programmable independently in each segment, see Section 28.6 for detailed configuration. The CS high time in each segment is about:

<!-- formula-not-decoded -->

The CS high time in CONF state can be set from 62.5 ns to 3.2768 ms when fAHB\_CLK is 80 MHz. (SPI\_CONF\_BITLEN + 5) will overflow from (0x40000 - SPI\_CONF\_BITLEN - 5) if SPI\_CONF\_BITLEN is larger than 0x3FFFA.

## 28.5.9 GP-SPI2 Works as a Slave

GP-SPI2 can be used as a slave to communicate with an SPI master. As a slave, GP-SPI2 supports 1-bit SPI, 2-bit dual SPI, 4-bit quad SPI, and QPI modes, with specific communication formats. To enable this mode, set SPI\_SLAVE\_MODE in register SPI\_SLAVE\_REG .

The CS signal must be held low during the transmission, and its falling/rising edges indicate the start/end of a single or segmented transmission. The length of transferred data must be in unit of bytes, otherwise the extra bits will be lost. The extra bits here means the result of total bits % 8.

## 28.5.9.1 Communication Formats

In GP-SPI2 as slave, SPI full-duplex and half-duplex communications are available. To select from the two communications, configure SPI\_DOUTDIN in register SPI\_USER\_REG .

Full-duplex communication means that input data and output data are transmitted simultaneously throughout the entire transaction. All bits are treated as input or output data, which means no command, address or dummy states are expected. The interrupt SPI\_TRANS\_DONE\_INT is triggered once the transaction ends.

In half-duplex communication, the format is CMD+ADDR+DUMMY+DATA (DIN or DOUT).

- "DIN" means that an SPI master reads data from GP-SPI2.
- "DOUT" means that an SPI master writes data to GP-SPI2.

The detailed properties of each state are as follows:

## 1. CMD:

- Indicate the function of SPI slave;
- One byte from master to slave;
- Only the values in Table 28.5-13 and Table 28.5-14 are valid;
- Can be sent in 1-bit SPI mode or 4-bit QPI mode.

## 2. ADDR:

- The address for Wr\_BUF and Rd\_BUF commands in CPU-controlled transfer, or placeholder bits in other transfers and can be defined by application;
- One byte from master to slave;
- Can be sent in 1-bit, 2-bit or 4-bit modes (according to the command).

## 3. DUMMY:

- Its value is meaningless. SPI slave prepares data in this state;
- Bit mode of FSPI bus is also meaningless here;
- Last for eight SPI\_CLK cycles.

## 4. DIN or DOUT:

- Data length can be 0 ~ 64 B in CPU-controlled mode and unlimited in DMA-controlled mode;
- Can be sent in 1-bit, 2-bit or 4-bit modes according to the CMD value.

## Note:

The states of ADDR and DUMMY can never be skipped in any half-duplex communications.

When a half-duplex transaction is complete, the transferred CMD and ADDR values are latched into SPI\_SLV\_LAST\_COMMAND and SPI\_SLV\_LAST\_ADDR respectively. The SPI\_SLV\_CMD\_ERR\_INT\_RAW will be

set if the transferred CMD value is not supported by GP-SPI2 as slave. The SPI\_SLV\_CMD\_ERR\_INT\_RAW can only be cleared by software.

## 28.5.9.2 Supported CMD Values in Half-Duplex Communication

In half-duplex communication, the defined values of CMD determine the transfer types. Unsupported CMD values are disregarded, meanwhile the related transfer is ignored and SPI\_SLV\_CMD\_ERR\_INT\_RAW is set. The transfer format is CMD (8 bits) + ADDR (8 bits) + DUMMY (8 SPI\_CLK cycles) + DATA (unit in bytes). The detailed description of CMD[3:0] is as follows:

- 0x1 (Wr\_BUF): CPU-controlled write mode. Master sends data and GP-SPI2 receives data. The data is stored in the related address of SPI\_W0\_REG ~ SPI\_W15\_REG .
- 0x2 (Rd\_BUF): CPU-controlled read mode. Master receives the data sent by GP-SPI2. The data comes from the related address of SPI\_W0\_REG ~ SPI\_W15\_REG .
- 0x3 (Wr\_DMA): DMA-controlled write mode. Master sends data and GP-SPI2 receives data. The data is stored in GP-SPI2 GDMA RX buffer.
- 0x4 (Rd\_DMA): DMA-controlled read mode. Master receives the data sent by GP-SPI2. The data comes from GP-SPI2 GDMA TX buffer.
- 0x7 (CMD7): used to generate an SPI\_SLV\_CMD7\_INT interrupt. It can also generate a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt in a slave segmented transfer when GDMA RX link is used. But it will not end GP-SPI2's slave segmented transfer.
- 0x8 (CMD8): only used to generate an SPI\_SLV\_CMD8\_INT interrupt, which will not end GP-SPI2's slave segmented transfer.
- 0x9 (CMD9): only used to generate an SPI\_SLV\_CMD9\_INT interrupt, which will not end GP-SPI2's slave segmented transfer.
- 0xA (CMDA): only used to generate an SPI\_SLV\_CMDA\_INT interrupt, which will not end GP-SPI2's slave segmented transfer.

The detailed function of CMD7, CMD8, CMD9, and CMDA commands is reserved for user definition. These commands can be used as handshake signals, as passwords of some specific functions, as triggers of some user defined actions, and so on.

1/2/4-bit modes in states of CMD, ADDR, DATA are supported, which are determined by value of CMD[7:4]. The DUMMY state is always in 1-bit mode and lasts for eight SPI\_CLK cycles. The definition of CMD[7:4] is as follows:

- 0x0: CMD, ADDR, and DATA states all are in 1-bit mode.
- 0x1: CMD and ADDR are in 1-bit mode. DATA is in 2-bit mode.
- 0x2: CMD and ADDR are in 1-bit mode. DATA is in 4-bit mode.
- 0x5: CMD is in 1-bit mode. ADDR and DATA are in 2-bit mode.
- 0xA: CMD is in 1-bit mode, ADDR and DATA are in 4-bit mode or in QPI mode.

In addition, if the value of CMD[7:0] is 0x05, 0xA5, 0x06, or 0xDD, DUMMY and DATA states are skipped. The definition of CMD[7:0] is as follows:

- 0x05 (End\_SEG\_TRANS): master sends 0x05 command to end slave segmented transfer in SPI mode.

- 0xA5 (End\_SEG\_TRANS): master sends 0xA5 command to end slave segmented transfer in QPI mode.
- 0x06 (En\_QPI): GP-SPI2 enters QPI mode when receiving the 0x06 command and the bit SPI\_QPI\_MODE in register SPI\_USER\_REG is set.
- 0xDD (Ex\_QPI): GP-SPI2 exits QPI mode when receiving the 0xDD command and the bit SPI\_QPI\_MODE is cleared.

All the CMD values supported by GP-SPI2 are listed in Table 28.5-13 and Table 28.5-14. Note that DUMMY state is always in 1-bit mode and lasts for eight SPI\_CLK cycles.

Table 28.5-13. Supported CMD Values in SPI Mode

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
| Rd_DMA          | 0x14       | 1-bit mode  | 1-bit mode   | 2-bit mode   |
| Rd_DMA          | 0x24       | 1-bit mode  | 1-bit mode   | 4-bit mode   |
| Rd_DMA          | 0x54       | 1-bit mode  | 2-bit mode   | 2-bit mode   |
| Rd_DMA          | 0xA4       | 1-bit mode  | 4-bit mode   | 4-bit mode   |
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

Table 28.5-13. Supported CMD Values in SPI Mode

| Transfer Type   | CMD[7:0]   | CMD State   | ADDR State   | DATA State   |
|-----------------|------------|-------------|--------------|--------------|
| CMDA            | 0xA9       | 1-bit mode  | 4-bit mode   | -            |
|                 | 0x0A       | 1-bit mode  | 1-bit mode   | -            |
|                 | 0x1A       | 1-bit mode  | 1-bit mode   | -            |
|                 | 0x2A       | 1-bit mode  | 1-bit mode   | -            |
|                 | 0x5A       | 1-bit mode  | 2-bit mode   | -            |
|                 | 0xAA       | 1-bit mode  | 4-bit mode   | -            |
| End_SEG_TRANS   | 0x05       | 1-bit mode  | -            | -            |
| En_QPI          | 0x06       | 1-bit mode  | -            | -            |

Table 28.5-14. Supported CMD Values in QPI Mode

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

Other transfer types than these described in Table 28.5-13 and Table 28.5-14 are ignored. If the transferred data is not in unit of byte, GP-SPI2 will send or receive the data in unit of byte, but the extra bits (the result of total bits mod 8) will be lost. But if the CS low time is longer than 2 APB clock (APB\_CLK) cycles, SPI\_TRANS\_DONE\_INT will be triggered. For more information on interrupts triggered at the end of transmissions, please refer to Section 28.9 .

## 28.5.9.3 Slave Single Transfer and Slave Segmented Transfer

When GP-SPI2 works as a slave, it supports full-duplex and half-duplex communications controlled by DMA and by CPU. DMA-controlled transfer can be a single transfer, or a slave segmented transfer consisting of several transactions (segments). The CPU-controlled transfer can only be one single transfer, since each CPU-controlled transaction needs to be triggered by CPU.

In a slave segmented transfer, all transfer types listed in Table 28.5-13 and Table 28.5-14 are supported in a single transaction (segment). It means that CPU-controlled transaction and DMA-controlled transaction can be mixed in one slave segmented transfer.

It is recommended that in a slave segmented transfer:

- CPU-controlled transaction is used for handshake communication and short data transfers.
- DMA-controlled transaction is used for large data transfers.

## 28.5.9.4 Configuration of Slave Single Transfer

When operating as slave, GP-SPI2 supports CPU/DMA-controlled full-duplex/half-duplex single transfers. The register configuration procedure is as follows:

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure AHB clock (AHB\_CLK) and APB clock (APB\_CLK).
3. Set the bit SPI\_SLAVE\_MODE to enable slave mode.
4. Configure SPI\_DOUTDIN:
- 1: enable full-duplex communication.
- 0: enable half-duplex communication.

## 5. Prepare data:

- if CPU-controlled transfer mode is selected and GP-SPI2 is used to send data, then prepare data in registers SPI\_W0\_REG ~ SPI\_W15\_REG .
- if DMA-controlled transfer mode is selected,
- – configure SPI\_DMA\_TX\_ENA/SPI\_DMA\_RX\_ENA and SPI\_RX\_EOF\_EN ,
- – configure GDMA TX/RX link,
- – and start GDMA TX/RX engine, as described in Section 28.5.6 and Section 28.5.7 .
6. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.
7. Clear SPI\_DMA\_SLV\_SEG\_TRANS\_EN in register SPI\_DMA\_CONF\_REG to enable slave single transfer mode.
8. Set SPI\_TRANS\_DONE\_INT\_ENA in SPI\_DMA\_INT\_ENA\_REG and wait for the interrupt SPI\_TRANS\_DONE\_INT. In DMA-controlled mode, it is recommended to wait for the interrupt GDMA\_IN\_SUC\_EOF\_CHn\_INT when GDMA RX buffer is used, which means that data has been stored in the related memory. Other interrupts described in Section 28.9 are optional.

## 28.5.9.5 Configuration of Slave Segmented Transfer in Half-Duplex

GDMA must be used in this mode. The register configuration procedure is as follows:

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure AHB clock (AHB\_CLK) and APB clock (APB\_CLK).
3. Set SPI\_SLAVE\_MODE to enable slave mode.
4. Clear SPI\_DOUTDIN to enable half-duplex communication.
5. Prepare data in registers SPI\_W0\_REG ~ SPI\_W15\_REG, if needed.
6. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST to reset these buffers.

![Image](images/28_Chapter_28_img012_1db86f84.png)

7. Set bits SPI\_DMA\_RX\_ENA and SPI\_DMA\_TX\_ENA. Clear the bit SPI\_RX\_EOF\_EN. Configure GDMA TX/RX link and start GDMA TX/RX engine, as shown in Section 28.5.6 and Section 28.5.7 .
8. Set SPI\_DMA\_SLV\_SEG\_TRANS\_EN in SPI\_DMA\_CONF\_REG to enable slave segmented transfer.
9. Set SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_ENA in SPI\_DMA\_INT\_ENA\_REG and wait for the interrupt SPI\_ DMA\_SEG\_TRANS\_DONE\_INT, which means that the segmented transfer has finished and data has been put into the related memory. Other interrupts described in Section 28.9 are optional.

When End\_SEG\_TRANS (0x05 in SPI mode, 0xA5 in QPI mode) is received by GP-SPI2, this slave segmented transfer is ended and the interrupt SPI\_DMA\_SEG\_TRANS\_DONE\_INT is triggered.

## 28.5.9.6 Configuration of Slave Segmented Transfer in Full-Duplex

GDMA must be used in this mode. In such transfer, the data is transferred from and to the GDMA buffer. The interrupt GDMA\_IN\_SUC\_EOF\_CHn

\_INT is triggered when the transfer ends. The configuration procedure is as follows:

1. Configure the IO path via IO MUX or GPIO matrix between GP-SPI2 and an external SPI device.
2. Configure AHB clock (AHB\_CLK) and APB clock (APB\_CLK).
3. Set SPI\_SLAVE\_MODE and SPI\_DOUTDIN, to enable full-duplex communication as slave.
4. Set SPI\_DMA\_AFIFO\_RST , SPI\_BUF\_AFIFO\_RST, and SPI\_RX\_AFIFO\_RST, to reset these buffers.
5. Set SPI\_DMA\_TX\_ENA/SPI\_DMA\_RX\_ENA. Configure GDMA TX/RX link and start GDMA TX/RX engine, as shown in Section 28.5.6 and Section 28.5.7 .
6. Set the bit SPI\_RX\_EOF\_EN in register SPI\_DMA\_CONF\_REG. Configure SPI\_MS\_DATA\_BITLEN[17:0] in register SPI\_MS\_DLEN\_REG to the byte length of the received DMA data.
7. Set SPI\_DMA\_SLV\_SEG\_TRANS\_EN in SPI\_DMA\_CONF\_REG to enable slave segmented transfer mode.
8. Set GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA and wait for the interrupt GDMA\_IN\_SUC\_EOF\_CHn\_INT .

## 28.6 CS Setup Time and Hold Time Control

SPI bus CS (SPI\_CS) setup time and hold time are very important to meet the timing requirements of various SPI devices (e.g., flash or PSRAM).

CS setup time is the time between the CS falling edge and the first latch edge of SPI bus CLK (SPI\_CLK). The first latch edge for mode 0 and mode 3 is rising edge, and falling edge for mode 1 and mode 2.

CS hold time is the time between the last latch edge of SPI\_CLK and the CS rising edge.

When operating as slave, the CS setup time and hold time should be longer than 0.5 x T\_SPI\_CLK, otherwise the SPI transfer may be incorrect. T\_SPI\_CLK is one cycle of SPI\_CLK.

When operating as master, set the CS setup time by specifying SPI\_CS\_SETUP in SPI\_USER\_REG and SPI\_CS\_SETUP\_TIME in SPI\_USER1\_REG:

- If SPI\_CS\_SETUP is cleared, the SPI CS setup time is 0.5 x T\_SPI\_CLK.
- If SPI\_CS\_SETUP is set, the SPI CS setup time is (SPI\_CS\_SETUP\_TIME + 1.5) x T\_SPI\_CLK.

Set the CS hold time by specifying SPI\_CS\_HOLD in SPI\_USER\_REG and SPI\_CS\_HOLD\_TIME in SPI\_USER1\_REG:

- If SPI\_CS\_HOLD is cleared, the SPI CS hold time is 0.5 x T\_SPI\_CLK;
- If SPI\_CS\_HOLD is set, the SPI CS hold time is (SPI\_CS\_HOLD\_TIME + 1.5) x T\_SPI\_CLK.

Figure 28.6-1 and Figure 28.6-2 show the recommended CS timing and register configuration to access external RAM and flash.

![Image](images/28_Chapter_28_img013_8551beaf.png)

Figure 28.6-1. Recommended CS Timing and Settings When Accessing External RAM

![Image](images/28_Chapter_28_img014_29df9572.png)

Figure 28.6-2. Recommended CS Timing and Settings When Accessing Flash

## 28.7 GP-SPI2 Clock Control

GP-SPI2 has the following clocks:

- clk\_spi\_mst: module clock of GP-SPI2, derived from PLL\_CLK. Used in GP-SPI2 as master to generate SPI\_CLK signal for data transfer and for slaves.
- SPI\_CLK: output clock as master.
- AHB\_CLK/APB\_CLK: clock for register configuration.
- clk\_hclk: module timing compensation clock of GP-SPI2.

clk\_spi\_mst is enabled by PCR\_SPI2\_MST\_CLK\_ACTIVE\_I and its clock source is controlled by PCR\_SPI2\_MST\_CLK\_SEL\_I[1:0]:

- 0: XTAL\_CLK
- 1: PLL\_F80M\_CLK
- 2: RC\_FAST\_CLK

When operating as master, the maximum output clock frequency of GP-SPI2 is fclk\_spi\_mst. To have slower frequencies, the output clock frequency can be divided as follows:

<!-- formula-not-decoded -->

The divider is configured by SPI\_CLKCNT\_N and SPI\_CLKDIV\_PRE in register SPI\_CLOCK\_REG. When the bit SPI\_CLK\_EQU\_SYSCLK in register SPI\_CLOCK\_REG is set to 1, the output clock frequency of GP-SPI2 will be fclk\_spi\_mst. For other integral clock divisions, SPI\_CLK\_EQU\_SYSCLK should be set to 0.

When operating as slave, the supported input clock frequency (fSPI\_CLK) of GP-SPI2 is fSPI\_CLK &lt;= fAHB\_CLK .

## 28.7.1 Clock Phase and Polarity

SPI protocol has four clock modes, i.e., modes 0 ~ 3. See Figure 28.7-1 and Figure 28.7-2 (excerpted from SPI protocol):

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

![Image](images/28_Chapter_28_img015_2cd39a67.png)

t, = Minimum idling time between transfers (minimum SS high time)

tz, IT, and t, are guaranteed for the master mode and required for the slave mode.

Figure 28.7-1. SPI Clock Mode 0 or 2

Figure 28.7-2. SPI Clock Mode 1 or 3

![Image](images/28_Chapter_28_img016_939c1466.png)

1. Mode 0: CPOL = 0, CPHA = 0; SCK is 0 when the SPI is in idle state; data is changed on the negative edge of SCK and sampled on the positive edge. The first data is shifted out before the first negative edge of SCK.

Begin

Begin

Begin of Idle State

Begin of Idle State

2. Mode 1: CPOL = 0, CPHA = 1; SCK is 0 when the SPI is in idle state; data is changed on the positive edge of SCK and sampled on the negative edge.
3. Mode 2: CPOL = 1, CPHA = 0; SCK is 1 when the SPI is in idle state; data is changed on the positive edge of SCK and sampled on the negative edge. The first data is shifted out before the first positive edge of SCK.
4. Mode 3: CPOL = 1, CPHA = 1; SCK is 1 when the SPI is in idle state; data is changed on the negative edge of SCK and sampled on the positive edge.

## 28.7.2 Clock Control as Master

The four clock modes 0 ~ 3 are supported in GP-SPI2 as master. The polarity and phase of GP-SPI2 clock are controlled by the bit SPI\_CK\_IDLE\_EDGE in register SPI\_MISC\_REG and the bit SPI\_CK\_OUT\_EDGE in register SPI\_USER\_REG. The register configuration for SPI clock modes 0 ~ 3 is provided in Table 28.7-1, and can be changed according to the path delay in the application.

Table 28.7-1. Clock Phase and Polarity Configuration as Master

| Control Bit      |   Mode 0 |   Mode 1 |   Mode 2 |   Mode 3 |
|------------------|----------|----------|----------|----------|
| SPI_CK_IDLE_EDGE |        0 |        0 |        1 |        1 |
| SPI_CK_OUT_EDGE  |        0 |        1 |        1 |        0 |

SPI\_CLK\_MODE is used to select the number of rising edges of SPI\_CLK when SPI\_CS raises high to be 0, 1, 2 or SPI\_CLK always on.

## Note:

When SPI\_CLK\_MODE is configured to 1 or 2, the bit SPI\_CS\_HOLD must be set and the value of SPI\_CS\_HOLD\_TIME should be larger than 1.

## 28.7.3 Clock Control as Slave

GP-SPI2 as slave also supports clock modes 0 ~ 3. The polarity and phase are configured by the bits SPI\_TSCK\_I\_EDGE and SPI\_RSCK\_I\_EDGE in register SPI\_USER\_REG. The output edge of data is controlled by SPI\_CLK\_MODE\_13 in register SPI\_SLAVE\_REG. The detailed register configuration is shown in Table 28.7-2:

Table 28.7-2. Clock Phase and Polarity Configuration as Slave

| Control Bit     |   Mode 0 |   Mode 1 |   Mode 2 |   Mode 3 |
|-----------------|----------|----------|----------|----------|
| SPI_TSCK_I_EDGE |        0 |        1 |        1 |        0 |
| SPI_RSCK_I_EDGE |        0 |        1 |        1 |        0 |
| SPI_CLK_MODE_13 |        0 |        1 |        0 |        1 |

## 28.8 GP-SPI2 Timing Compensation

## Introduction

The I/O lines are mapped via GPIO Matrix or IO MUX. But there is no timing adjustment in IO MUX. The input data and output data can be delayed for 1 or 2 IO MUX operating clock cycles at the rising or falling edge in GPIO matrix. For detailed register configuration, see Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) .

Figure 28.8-1 shows the timing compensation control for GP-SPI2 as master, including the following paths:

- "CLK": the output path of GP-SPI2 bus clock. The clock is sent out by SPI\_CLK out control module, passes through GPIO Matrix or IO MUX and then goes to an external SPI device.
- "IN": data input path of GP-SPI2. The input data from an external SPI device passes through GPIO Matrix or IO MUX, then is adjusted by the Timing Module and finally is stored into spi\_rx\_afifo.
- "OUT": data output path of GP-SPI2. The output data is sent out to the Timing Module, passes through GPIO Matrix or IO MUX and is then captured by an external SPI device.

Figure 28.8-1. Timing Compensation Control Diagram in GP-SPI2 as Master

![Image](images/28_Chapter_28_img017_98a06870.png)

Every input and output data is passing through the Timing Module and the module can be used to apply delay in units of Tclk\_spi\_mst (one cycle of clk\_spi\_mst) on rising or falling edge.

## Key Registers

- SPI\_DIN\_MODE\_REG: select the latch edge of input data
- SPI\_DIN\_NUM\_REG: select the delay cycles of input data
- SPI\_DOUT\_MODE\_REG: select the latch edge of output data

## Timing Compensation Example

Figure 28.8-2 shows a timing compensation example in GP-SPI2 as master. Note that DUMMY cycle length is configurable to compensate the delay in I/O lines, so as to enhance the performance of GP-SPI2.

Figure 28.8-2. Timing Compensation Example in GP-SPI2 as Master

![Image](images/28_Chapter_28_img018_825a76e1.png)

In Figure 28.8-2, "p1" is the point of input data of Timing Module, "p2" is the point of output data of Timing Module. Since the input data FSPIQ is unaligned to FSPID, the read data of GP-SPI2 will be wrong without the timing compensation.

To get the correct read data, follow the settings below. Assuming fclk \_ spi \_ mst equals to fSP I \_ CLK:

- Delay FSPID for two cycles at the falling edge of clk\_spi\_mst.
- Delay FSPIQ for one cycle at the falling edge of clk\_spi\_mst.
- Add one extra dummy cycle.

When GP-SPI2 works as slave, if the bit SPI\_RSCK\_DATA\_OUT in register SPI\_SLAVE\_REG is set to 1, the output data is sent at latch edge, which is half an SPI clock cycle earlier. This can be used for slave mode timing compensation.

## 28.9 Interrupts

## Interrupt Summary

GP-SPI2 provides an SPI interface interrupt SPI\_INT. When an SPI transfer ends, an interrupt is generated in GP-SPI2.

- SPI\_DMA\_INFIFO\_FULL\_ERR\_INT: triggered when the length of GDMA RX FIFO is shorter than that of actual data transferred.
- SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT: triggered when the length of GDMA TX FIFO is shorter than that of actual data transferred.
- SPI\_SLV\_EX\_QPI\_INT: triggered when Ex\_QPI is received correctly in GP-SPI2 as slave and the SPI transfer ends.

- SPI\_SLV\_EN\_QPI\_INT: triggered when En\_QPI is received correctly in GP-SPI2 as slave and the SPI transfer ends.
- SPI\_SLV\_CMD7\_INT: triggered when CMD7 is received correctly in GP-SPI2 as slave and the SPI transfer ends.
- SPI\_SLV\_CMD8\_INT: triggered when CMD8 is received correctly in GP-SPI2 as slave and the SPI transfer ends.
- SPI\_SLV\_CMD9\_INT: triggered when CMD9 is received correctly in GP-SPI2 as slave and the SPI transfer ends.
- SPI\_SLV\_CMDA\_INT: triggered when CMDA is received correctly in GP-SPI2 as slave and the SPI transfer ends.
- SPI\_SLV\_RD\_DMA\_DONE\_INT: triggered at the end of Rd\_DMA transfer as slave.
- SPI\_SLV\_WR\_DMA\_DONE\_INT: triggered at the end of Wr\_DMA transfer as slave.
- SPI\_SLV\_RD\_BUF\_DONE\_INT: triggered at the end of Rd\_BUF transfer as slave.
- SPI\_SLV\_WR\_BUF\_DONE\_INT: triggered at the end of Wr\_BUF transfer as slave.
- SPI\_TRANS\_DONE\_INT: triggered at the end of SPI bus transfer in both as master and as slave.
- SPI\_DMA\_SEG\_TRANS\_DONE\_INT: triggered at the end of End\_SEG\_TRANS transfer in GP-SPI2 slave segmented transfer mode or at the end of configurable segmented transfer as master.
- SPI\_SEG\_MAGIC\_ERR\_INT: triggered when a Magic error occurs in CONF buffer during configurable segmented transfer as master.
- SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT: triggered by RX AFIFO write-full error in GP-SPI2 as master.
- SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT: triggered by TX AFIFO read-empty error in GP-SPI2 as master.
- SPI\_SLV\_CMD\_ERR\_INT: triggered when a received command value is not supported in GP-SPI2 as slave.
- SPI\_APP2\_INT: used and triggered by software. Only used for user defined function.
- SPI\_APP1\_INT: used and triggered by software. Only used for user defined function.

## Interrupts Used as Master and Slave

Table 28.9-1 and Table 28.9-2 show the interrupts used in GP-SPI2 as master and as slave, respectively. Set the interrupt enable bit SPI\_*\_INT\_ENA in SPI\_DMA\_INT\_ENA\_REG and wait for the SPI\_INT interrupt. When the transfer ends, the related interrupt is triggered and should be cleared by software before the next transfer.

![Image](images/28_Chapter_28_img019_206dc2be.png)

Table 28.9-1. GP-SPI2 Interrupts as Master

| Transfer Type                   | Communication Mode   | Controlled by   | Interrupt                     |
|---------------------------------|----------------------|-----------------|-------------------------------|
| Single Transfer                 | Full-duplex          | DMA             | GDMA_IN_SUC_EOF_CHn_INT  1    |
| Single Transfer                 | Full-duplex          | CPU             | SPI_TRANS_DONE_INT  2         |
| Single Transfer                 | Half-duplex MOSI     | DMA             | SPI_TRANS_DONE_INT            |
| Single Transfer                 | Half-duplex MOSI     | CPU             | SPI_TRANS_DONE_INT            |
| Single Transfer                 | Half-duplex MISO     | DMA             | GDMA_IN_SUC_EOF_CHn_INT       |
| Single Transfer                 | Half-duplex MISO     | CPU             | SPI_TRANS_DONE_INT            |
| Configurable Segmented Transfer | Full-duplex          | DMA             | SPI_DMA_SEG_TRANS_DONE_INT  3 |
| Configurable Segmented Transfer | Full-duplex          | CPU             | Not supported                 |
| Configurable Segmented Transfer | Half-duplex MOSI     | DMA             | SPI_DMA_SEG_TRANS_DONE_INT    |
| Configurable Segmented Transfer | Half-duplex MOSI     | CPU             | Not supported                 |
| Configurable Segmented Transfer | Half-duplex MISO     | DMA             | SPI_DMA_SEG_TRANS_DONE_INT    |
| Configurable Segmented Transfer | Half-duplex MISO     | CPU             | Not supported                 |

Table 28.9-2. GP-SPI2 Interrupts as Slave

| Transfer Type            | Communication Mode   | Controlled by   | Interrupt                     |
|--------------------------|----------------------|-----------------|-------------------------------|
| Single Transfer          | Full-duplex          | DMA             | GDMA_IN_SUC_EOF_CHn_INT  1    |
| Single Transfer          | Full-duplex          | CPU             | SPI_TRANS_DONE_INT  2         |
|                          | Half-duplex MOSI     | DMA (Wr_DMA)    | GDMA_IN_SUC_EOF_CHn_INT 3     |
|                          | Half-duplex MOSI     | CPU (Wr_BUF)    | SPI_TRANS_DONE_INT 4          |
|                          | Half-duplex MISO     | DMA (Rd_DMA)    | SPI_TRANS_DONE_INT 5          |
|                          | Half-duplex MISO     | CPU (Rd_BUF)    | SPI_TRANS_DONE_INT 6          |
| Slave Segmented Transfer | Full-duplex          | DMA             | GDMA_IN_SUC_EOF_CHn_INT 7     |
| Slave Segmented Transfer | Full-duplex          | CPU             | Not supported 8               |
|                          | Half-duplex MOSI     | DMA (Wr_DMA)    | SPI_DMA_SEG_TRANS_DONE_INT 9  |
|                          | Half-duplex MOSI     | CPU (Wr_BUF)    | Not supported 10              |
|                          | Half-duplex MISO     | DMA (Rd_DMA)    | SPI_DMA_SEG_TRANS_DONE_INT 11 |
|                          | Half-duplex MISO     | CPU (Rd_BUF)    | Not supported 12              |

Continued on the next page

## Table 28.9-2 – Continued from the previous page

| Transfer Type   | Communication Mode  Controlled by   | Interrupt   |
|-----------------|-------------------------------------|-------------|

- 1 If GDMA\_IN\_SUC\_EOF\_CHn\_INT is triggered, it means all the RX data has been stored in the RX buffer, and the TX data has been sent to the slave.

2 SPI\_TRANS\_DONE\_INT is triggered when CS is high, which indicates that master has completed the data exchange in SPI\_W0\_REG ∼ SPI\_W15\_REG with slave in this mode.

- 3 SPI\_SLV\_WR\_DMA\_DONE\_INT just means that the transmission on the SPI bus is done, but can not ensure that all the push data has been stored in the RX buffer. For this reason, GDMA\_IN\_SUC\_EOF\_CHn\_INT is recommended.

4 Or wait for SPI\_SLV\_WR\_BUF\_DONE\_INT .

5 Or wait for SPI\_SLV\_RD\_DMA\_DONE\_INT .

6 Or wait for SPI\_SLV\_RD\_BUF\_DONE\_INT .

7 Slave should set the total read data byte length in SPI\_MS\_DATA\_BITLEN before the transfer begins. Set SPI\_RX\_EOF\_EN to 1 before the end of the interrupt program.

8 Master and slave should define a method to end the segmented transfer, such as via GPIO interrupt.

9 Master sends End\_SEG\_TRAN to end the segmented transfer or slave sets the total read data byte length in SPI\_MS\_DATA\_BITLEN and waits for GDMA\_IN\_SUC\_EOF\_CHn\_INT.

10 Half-duplex Wr\_BUF single transfer can be used in a slave segmented transfer.

11 Master sends End\_SEG\_TRAN to end the segmented transfer.

12 Half-duplex Rd\_BUF single transfer can be used in a slave segmented transfer.

## 28.10 Register Summary

The addresses in this section are relative to SPI base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                | Description                                 | Address                             | Access                              |
|-------------------------------------|---------------------------------------------|-------------------------------------|-------------------------------------|
| User-defined control registers      | User-defined control registers              | User-defined control registers      | User-defined control registers      |
| SPI_CMD_REG                         | Command control register                    | 0x0000                              | varies                              |
| SPI_ADDR_REG                        | Address value register                      | 0x0004                              | R/W                                 |
| SPI_USER_REG                        | SPI USER control register                   | 0x0010                              | varies                              |
| SPI_USER1_REG                       | SPI USER control register 1                 | 0x0014                              | R/W                                 |
| SPI_USER2_REG                       | SPI USER control register 2                 | 0x0018                              | R/W                                 |
| Control and configuration registers | Control and configuration registers         | Control and configuration registers | Control and configuration registers |
| SPI_CTRL_REG                        | SPI control register                        | 0x0008                              | varies                              |
| SPI_MS_DLEN_REG                     | SPI data bit length control register        | 0x001C                              | R/W                                 |
| SPI_MISC_REG                        | SPI misc register                           | 0x0020                              | varies                              |
| SPI_DMA_CONF_REG                    | SPI DMA control register                    | 0x0030                              | varies                              |
| SPI_SLAVE_REG                       | SPI slave control register                  | 0x00E0                              | varies                              |
| SPI_SLAVE1_REG                      | SPI slave control register 1                | 0x00E4                              | R/W/SS                              |
| Clock control registers             | Clock control registers                     | Clock control registers             | Clock control registers             |
| SPI_CLOCK_REG                       | SPI clock control register                  | 0x000C                              | R/W                                 |
| SPI_CLK_GATE_REG                    | SPI module clock and register clock control | 0x00E8                              | R/W                                 |

| Name                       | Description                          | Address   | Access   |
|----------------------------|--------------------------------------|-----------|----------|
| Timing registers           |                                      |           |          |
| SPI_DIN_MODE_REG           | SPI input delay mode configuration   | 0x0024    | varies   |
| SPI_DIN_NUM_REG            | SPI input delay number configuration | 0x0028    | varies   |
| SPI_DOUT_MODE_REG          | SPI output delay mode configuration  | 0x002C    | varies   |
| Interrupt registers        |                                      |           |          |
| SPI_DMA_INT_ENA_REG        | SPI interrupt enable register        | 0x0034    | R/W      |
| SPI_DMA_INT_CLR_REG        | SPI interrupt clear register         | 0x0038    | WT       |
| SPI_DMA_INT_RAW_REG        | SPI interrupt raw register           | 0x003C    | R/WTC/SS |
| SPI_DMA_INT_ST_REG         | SPI interrupt status register        | 0x0040    | RO       |
| SPI_DMA_INT_SET_REG        | SPI interrupt software set register  | 0x0044    | WT       |
| CPU-controlled data buffer |                                      |           |          |
| SPI_W0_REG                 | SPI CPU-controlled buffer0           | 0x0098    | R/W/SS   |
| SPI_W1_REG                 | SPI CPU-controlled buffer1           | 0x009C    | R/W/SS   |
| SPI_W2_REG                 | SPI CPU-controlled buffer2           | 0x00A0    | R/W/SS   |
| SPI_W3_REG                 | SPI CPU-controlled buffer3           | 0x00A4    | R/W/SS   |
| SPI_W4_REG                 | SPI CPU-controlled buffer4           | 0x00A8    | R/W/SS   |
| SPI_W5_REG                 | SPI CPU-controlled buffer5           | 0x00AC    | R/W/SS   |
| SPI_W6_REG                 | SPI CPU-controlled buffer6           | 0x00B0    | R/W/SS   |
| SPI_W7_REG                 | SPI CPU-controlled buffer7           | 0x00B4    | R/W/SS   |
| SPI_W8_REG                 | SPI CPU-controlled buffer8           | 0x00B8    | R/W/SS   |
| SPI_W9_REG                 | SPI CPU-controlled buffer9           | 0x00BC    | R/W/SS   |
| SPI_W10_REG                | SPI CPU-controlled buffer10          | 0x00C0    | R/W/SS   |
| SPI_W11_REG                | SPI CPU-controlled buffer11          | 0x00C4    | R/W/SS   |
| SPI_W12_REG                | SPI CPU-controlled buffer12          | 0x00C8    | R/W/SS   |
| SPI_W13_REG                | SPI CPU-controlled buffer13          | 0x00CC    | R/W/SS   |
| SPI_W14_REG                | SPI CPU-controlled buffer14          | 0x00D0    | R/W/SS   |
| SPI_W15_REG                | SPI CPU-controlled buffer15          | 0x00D4    | R/W/SS   |
| Version register           |                                      |           |          |
| SPI_DATE_REG               | Version control                      | 0x00F0    | R/W      |

## 28.11 Registers

The addresses in this section are relative to SPI base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 28.1. SPI\_CMD\_REG (0x0000)

![Image](images/28_Chapter_28_img020_c55205d9.png)

SPI\_CONF\_BITLEN Configures the SPI\_CLK cycles of SPI CONF state. (R/W)

Measurement unit: SPI\_CLK clock cycle.

Can be configured in CONF state.

SPI\_UPDATE Configures whether or not to synchronize SPI registers from APB clock domain into SPI module clock domain. (WT)

- 0: Not synchronize
- 1: Synchronize

This bit is only used in SPI master transfer.

SPI\_USR Configures whether or not to enable user-defined command. (R/W/SC)

- 0: Not enable
- 1: Enable

An SPI operation will be triggered when the bit is set. This bit will be cleared once the operation is done. Can not be changed by CONF\_buf.

Register 28.2. SPI\_ADDR\_REG (0x0004)

![Image](images/28_Chapter_28_img021_44b18f04.png)

SPI\_USR\_ADDR\_VALUE Configures the address to slave. (R/W) Can be configured in CONF state.

## Register 28.3. SPI\_USER\_REG (0x0010)

![Image](images/28_Chapter_28_img022_eba0df94.png)

SPI\_DOUTDIN Configures whether or not to enable full-duplex communication. (R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

SPI\_QPI\_MODE Configures whether or not to enable QPI mode. (R/W/SS/SC)

- 0: Disable
- 1: Enable

This configuration is applicable when the SPI controller works as master or slave. Can be configured in CONF state.

SPI\_TSCK\_I\_EDGE Configures whether or not to change the polarity of TSCK in slave transfer. (R/W)

- 0: TSCK = SPI\_CK\_I
- 1: TSCK = !SPI\_CK\_I

SPI\_CS\_HOLD Configures whether or not to keep SPI CS low when SPI is in DONE state. (R/W)

- 0: Not keep low
- 1: Keep low

Can be configured in CONF state.

SPI\_CS\_SETUP Configures whether or not to enable SPI CS when SPI is in prepare (PREP) state.

(R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

SPI\_RSCK\_I\_EDGE Configures whether or not to change the polarity of RSCK in slave transfer. (R/W)

- 0: RSCK = !SPI\_CK\_I
- 1: RSCK = SPI\_CK\_I

Continued on the next page...

## Register 28.3. SPI\_USER\_REG (0x0010)

Continued from the previous page...

- SPI\_CK\_OUT\_EDGE Configures SPI clock mode together with SPI\_CK\_IDLE\_EDGE. (R/W) Can be configured in CONF state. For more information, see Section 28.7.2 .
- SPI\_FWRITE\_DUAL Configures whether or not to enable the 2-bit mode of read-data phase in write operations. (R/W)
- 0: Not enable
- 1: Enable

Can be configured in CONF state.

- SPI\_FWRITE\_QUAD Configures whether or not to enable the 4-bit mode of read-data phase in write operations. (R/W)
- 0: Not enable
- 1: Enable

Can be configured in CONF state.

- SPI\_USR\_CONF\_NXT Configures whether or not to enable the CONF state for the next transaction (segment) in a configurable segmented transfer. (R/W)
- 0: this transfer will end after the current transaction (segment) is finished. Or this is not a configurable segmented transfer.
- 1: this configurable segmented transfer will continue its next transaction (segment).

Can be configured in CONF state.

- SPI\_SIO Configures whether or not to enable 3-line half-duplex communication, where MOSI and MISO signals share the same pin. (R/W)
- 0: Disable
- 1: Enable

Can be configured in CONF state.

- SPI\_USR\_MISO\_HIGHPART Configures whether or not to enable "high part mode", i.e., only access to high part of the buffers: SPI\_W8\_REG ~ SPI\_W15\_REG in read-data phase. (R/W)
- 0: Disable
- 1: Enable

Can be configured in CONF state.

Continued on the next page...

## Register 28.3. SPI\_USER\_REG (0x0010)

## Continued from the previous page...

SPI\_USR\_MOSI\_HIGHPART Configures whether or not to enable "high part mode", i.e., only access to high part of the buffers: SPI\_W8\_REG ~ SPI\_W15\_REG in write-data phase. (R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state. (R/W)

SPI\_USR\_DUMMY\_IDLE Configures whether or not to disable SPI clock in DUMMY state. (R/W)

- 0: Not disable
- 1: Disable

Can be configured in CONF state.

- SPI\_USR\_MOSI Configures whether or not to enable the write-data (DOUT) state of an operation. (R/W)
- 0: Disable
- 1: Enable

Can be configured in CONF state.

- SPI\_USR\_MISO Configures whether or not to enable the read-data (DIN) state of an operation.

(R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

SPI\_USR\_DUMMY Configures whether or not to enable the DUMMY state of an operation. (R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

- SPI\_USR\_ADDR Configures whether or not to enable the address (ADDR) state of an operation. (R/W)
- 0: Disable
- 1: Enable

Can be configured in CONF state.

Continued on the next page...

## Register 28.3. SPI\_USER\_REG (0x0010)

## Continued from the previous page...

SPI\_USR\_COMMAND Configures whether or not to enable the command (CMD) state of an operation. (R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

## Register 28.4. SPI\_USER1\_REG (0x0014)

![Image](images/28_Chapter_28_img023_5bd63759.png)

## SPI\_USR\_DUMMY\_CYCLELEN Configures the length of DUMMY state. (R/W)

Measurement unit: SPI\_CLK clock cycles.

This value is (the expected cycle number - 1). Can be configured in CONF state.

SPI\_MST\_WFULL\_ERR\_END\_EN Configures whether or not to end the SPI transfer when SPI RX AFIFO wfull error occurs in master full-/half-duplex transfers. (R/W)

- 0: Not end
- 1: End

SPI\_CS\_SETUP\_TIME Configures the length of prepare (PREP) state. (R/W)

Measurement unit: SPI\_CLK clock cycles.

This value is equal to the expected cycles - 1. This field is used together with SPI\_CS\_SETUP Can be configured in CONF state.

SPI\_CS\_HOLD\_TIME Configures the delay cycles of CS pin. (R/W)

Measurement unit: SPI\_CLK clock cycles.

This field is used together with SPI\_CS\_HOLD. Can be configured in CONF state.

SPI\_USR\_ADDR\_BITLEN Configures the bit length in address state. (R/W)

This value is (expected bit number - 1). Can be configured in CONF state.

.

Register 28.5. SPI\_USER2\_REG (0x0018)

![Image](images/28_Chapter_28_img024_afbdffdb.png)

SPI\_USR\_COMMAND\_VALUE Configures the command value. (R/W)

Can be configured in CONF state. (R/W)

SPI\_MST\_REMPTY\_ERR\_END\_EN Configures whether or not to end the SPI transfer when SPI TX AFIFO read empty error occurs in master full-/half-duplex transfers. (R/W)

- 0: Not end
- 1: End

SPI\_USR\_COMMAND\_BITLEN Configures the bit length of command state. (R/W)

This value is (expected bit number - 1). Can be configured in CONF state.

## Register 28.6. SPI\_CTRL\_REG (0x0008)

![Image](images/28_Chapter_28_img025_db61d79d.png)

SPI\_DUMMY\_OUT Configures whether or not to output the FSPI bus signals in DUMMY state. (R/W)

- 0: Not output
- 1: Output

Can be configured in CONF state.

- SPI\_FADDR\_DUAL Configures whether or not to enable 2-bit mode during address (ADDR) state.

(R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

- SPI\_FADDR\_QUAD Configures whether or not to enable 4-bit mode during address (ADDR) state.

(R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

- SPI\_FCMD\_DUAL Configures whether or not to enable 2-bit mode during command (CMD) state.

(R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state. (R/W)

- SPI\_FCMD\_QUAD Configures whether or not to enable 4-bit mode during command (CMD) state. (R/W)
- 0: Disable
- 1: Enable

Can be configured in CONF state. (R/W)

Continued on the next page...

## Register 28.6. SPI\_CTRL\_REG (0x0008)

## Continued from the previous page...

SPI\_FREAD\_DUAL Configures whether or not to enable the 2-bit mode of read-data (DIN) state in read operations. (R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

SPI\_FREAD\_QUAD Configures whether or not to enable the 4-bit mode of read-data (DIN) state in read operations. (R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

SPI\_Q\_POL Configures MISO line polarity. (R/W)

- 0: Low
- 1: High

Can be configured in CONF state.

SPI\_D\_POL Configures MOSI line polarity. (R/W)

- 0: Low
- 1: High

Can be configured in CONF state.

SPI\_HOLD\_POL Configures SPI\_HOLD output value when SPI is in idle. (R/W)

- 0: Output low
- 1: Output high

Can be configured in CONF state.

SPI\_WP\_POL Configures the output value of write-protect signal when SPI is in idle. (R/W)

- 0: Output low
- 1: Output high

Can be configured in CONF state.

Continued on the next page...

## Register 28.6. SPI\_CTRL\_REG (0x0008)

## Continued from the previous page...

SPI\_RD\_BIT\_ORDER Configures the bit order in read-data (MISO) state. (R/W)

- 0: MSB first
- 1: LSB first

Can be configured in CONF state.

SPI\_WR\_BIT\_ORDER Configures the bit order in command (CMD), address (ADDR), and write-data (MOSI) states. (R/W)

- 0: MSB first
- 1: LSB first

Can be configured in CONF state.

Register 28.7. SPI\_MS\_DLEN\_REG (0x001C)

![Image](images/28_Chapter_28_img026_cb782c86.png)

SPI\_MS\_DATA\_BITLEN Configures the data bit length of SPI transfer in DMA-controlled master transfer or in CPU-controlled master transfer. Or configures the bit length of SPI RX transfer in DMA-controlled slave transfer. (R/W)

This value shall be (expected bit\_num - 1). Can be configured in CONF state.

![Image](images/28_Chapter_28_img027_864c1ffe.png)

## Register 28.8. SPI\_MISC\_REG (0x0020)

![Image](images/28_Chapter_28_img028_edaa4a23.png)

SPI\_CSn\_DIS (n = 0 ∼ 5) Configures whether or not to disable SPI\_CSn pin. (R/W)

- 0: SPI\_CSn signal is from/to SPI\_CSn pin.
- 1: Disable SPI\_CSn pin.

Can be configured in CONF state.

SPI\_CK\_DIS Configures whether or not to disable SPI\_CLK output. (R/W)

- 0: Enable
- 1: Disable

Can be configured in CONF state.

SPI\_MASTER\_CS\_POL[n ] Configures the polarity of SPI\_CSn (n = 0 ∼ 5) line in master transfer. (R/W)

- 0: SPI\_CSn is low active.
- 1: SPI\_CSn is high active.

Can be configured in CONF state.

SPI\_SLAVE\_CS\_POL Configures whether or not invert SPI slave input CS polarity. (R/W)

- 0: Not change
- 1: Invert

Can be configured in CONF state.

SPI\_CK\_IDLE\_EDGE Configures the level of SPI\_CLK line when GP-SPI2 is in idle. (R/W)

- 0: Low
- 1: High

Can be configured in CONF state.

SPI\_CS\_KEEP\_ACTIVE Configures whether or not to keep the SPI\_CS line low. (R/W)

- 0: Not keep low
- 1: Keep low

Can be configured in CONF state.

## Register 28.9. SPI\_DMA\_CONF\_REG (0x0030)

![Image](images/28_Chapter_28_img029_e88f394c.png)

- SPI\_DMA\_OUTFIFO\_EMPTY Represents whether or not the DMA TX FIFO is ready for sending data. (RO)
- 0: Ready
- 1: Not ready
- SPI\_DMA\_INFIFO\_FULL Represents whether or not the DMA RX FIFO is ready for receiving data. (RO)
- 0: Ready
- 1: Not ready
- SPI\_DMA\_SLV\_SEG\_TRANS\_EN Configures whether or not to enable DMA-controlled segmented transfer in slave half-duplex communication. (R/W)
- 0: Disable
- 1: Enable
- SPI\_SLV\_RX\_SEG\_TRANS\_CLR\_EN In slave segmented transfer, if the size of the DMA RX buffer is smaller than the size of the received data, 1: the data in all the following Wr\_DMA transactions will not be received; 0: the data in this Wr\_DMA transaction will not be received, but in the following transactions, (R/W)
- if the size of DMA RX buffer is not 0, the data in following Wr\_DMA transactions will be received.
- if the size of DMA RX buffer is 0, the data in following Wr\_DMA transactions will not be received.
- SPI\_SLV\_TX\_SEG\_TRANS\_CLR\_EN In slave segmented transfer, if the size of the DMA TX buffer is smaller than the size of the transmitted data, (R/W)
- 1: the data in the following transactions will not be updated, i.e. the old data is transmitted repeatedly.
- 0: the data in this transaction will not be updated. But in the following transactions,
- – if new data is filled in DMA TX FIFO, new data will be transmitted.
- – if no new data is filled in DMA TX FIFO, no new data will be transmitted.

## Register 28.9. SPI\_DMA\_CONF\_REG (0x0030)

## Continued from the previous page...

SPI\_RX\_EOF\_EN 1: In a DAM-controlled transfer, if the bit number of transferred data is equal to (SPI\_MS\_DATA\_BITLEN + 1), then GDMA\_IN\_SUC\_EOF\_CHn\_INT\_RAW will be set by hardware. 0: GDMA\_IN\_SUC\_EOF\_CHn\_INT\_RAW is set by SPI\_TRANS\_DONE\_INT event in a single transfer, or by an SPI\_DMA\_SEG\_TRANS\_DONE\_INT event in a segmented transfer. (R/W)

- SPI\_DMA\_RX\_ENA Configures whether or not to enable DMA-controlled receive data transfer. (R/W)
- 0: Disable
- 1: Enable
- SPI\_DMA\_TX\_ENA Configures whether or not to enable DMA-controlled send data transfer. (R/W)
- 0: Disable
- 1: Enable
- SPI\_RX\_AFIFO\_RST Configures whether or not to reset spi\_rx\_afifo as shown in Figure 28.5-3 and in Figure 28.5-4. (WT)
- 0: Not reset
- 1: Reset

spi\_rx\_afifo is used to receive data in SPI master and slave transfer.

- SPI\_BUF\_AFIFO\_RST Configures whether or not to reset buf\_tx\_afifo as shown in Figure 28.5-3 and in Figure 28.5-4. (WT)
- 0: Not reset
- 1: Reset

buf\_tx\_afifo is used to send data out in CPU-controlled master and slave transfer.

SPI\_DMA\_AFIFO\_RST Configures whether or not to reset dma\_tx\_afifo as shown in Figure 28.5-3 and in Figure 28.5-4. (WT)

- 0: Not reset
- 1: Reset

dma\_tx\_afifo is used to send data out in DMA-controlled slave transfer.

## Register 28.10. SPI\_SLAVE\_REG (0x00E0)

![Image](images/28_Chapter_28_img030_cb3addb8.png)

SPI\_CLK\_MODE Configures SPI clock mode. (R/W)

- 0: SPI clock is off when CS becomes inactive.
- 1: SPI clock is delayed one cycle after CS becomes inactive.
- 2: SPI clock is delayed two cycles after CS becomes inactive.
- 3: SPI clock is always on.

Can be configured in CONF state.

SPI\_CLK\_MODE\_13 Configure clock mode. (R/W)

- 0: Support SPI clock mode 0 or 2. See Table 28.7-2 .
- 1: Support SPI clock mode 1 or 3. See Table 28.7-2 .

SPI\_RSCK\_DATA\_OUT Configures the edge of output data. (R/W)

- 0: Output data at TSCK rising edge.
- 1: Output data at RSCK rising edge.

SPI\_SLV\_RDDMA\_BITLEN\_EN Configures whether or not to use SPI\_SLV\_DATA\_BITLEN to store the data bit length of Rd\_DMA transfer. (R/W)

- 0: Not use
- 1: Use

SPI\_SLV\_WRDMA\_BITLEN\_EN Configures whether or not to use SPI\_SLV\_DATA\_BITLEN to store the data bit length of Wr\_DMA transfer. (R/W)

- 0: Not use
- 1: Use

Continued on the next page...

## Register 28.10. SPI\_SLAVE\_REG (0x00E0)

## Continued from the previous page...

SPI\_SLV\_RDBUF\_BITLEN\_EN Configures whether or not to use SPI\_SLV\_DATA\_BITLEN to store the data bit length of Rd\_BUF transfer. (R/W)

- 0: Not use
- 1: Use

SPI\_SLV\_WRBUF\_BITLEN\_EN Configures whether or not to use SPI\_SLV\_DATA\_BITLEN to store the data bit length of Wr\_BUF transfer. (R/W)

- 0: Not use
- 1: Use

SPI\_DMA\_SEG\_MAGIC\_VALUE Configures the magic value of BM table in DMA-controlled configurable segmented transfer. (R/W)

SPI\_SLAVE\_MODE Configures SPI work mode. (R/W)

- 0: Master
- 1: Slave
- SPI\_SOFT\_RESET Configures whether to reset the SPI clock line, CS line, and data line via software. (WT)
- 0: Not reset
- 1: Reset

Can be configured in CONF state.

- SPI\_USR\_CONF Configures whether or not to enable the CONF state of current DMA-controlled configurable segmented transfer. (R/W)
- 0: No effect, which means the current transfer is not a configurable segmented transfer.
- 1: Enable, which means a configurable segmented transfer is started.

SPI\_MST\_FD\_WAIT\_DMA\_TX\_DATA Configures whether or not to wait DMA TX data gets ready before starting SPI transfer in master full-duplex transfer. (R/W)

- 0: Not wait
- 1: Wait

Register 28.11. SPI\_SLAVE1\_REG (0x00E4)

![Image](images/28_Chapter_28_img031_139a2d2d.png)

SPI\_SLV\_DATA\_BITLEN Configures the transferred data bit length in SPI slave full-/half-duplex modes. (R/W/SS)

SPI\_SLV\_LAST\_COMMAND Configures the command value in slave mode. (R/W/SS)

SPI\_SLV\_LAST\_ADDR Configures the address value in slave mode. (R/W/SS)

Register 28.12. SPI\_CLOCK\_REG (0x000C)

![Image](images/28_Chapter_28_img032_cb04863e.png)

SPI\_CLKCNT\_L In master transfer, this field must be equal to SPI\_CLKCNT\_N. In slave mode, it must be 0. Can be configured in CONF state. (R/W)

SPI\_CLKCNT\_H Configures the duty cycle of SPI\_CLK (high level) in master transfer. (R/W)

It’s recommended to configure this value to floor((SPI\_CLKCNT\_N + 1)/2 - 1). floor() here is to round a number down, e.g., floor(2.2) = 2. In slave mode, it must be 0. Can be configured in CONF state.

- SPI\_CLKCNT\_N Configures the divider of SPI\_CLK in master transfer. (R/W)

SPI\_CLK frequency is fclk\_spi\_mst/(SPI\_CLKDIV\_PRE + 1)/(SPI\_CLKCNT\_N + 1). Can be configured in CONF state.

- SPI\_CLKDIV\_PRE Configures the pre-divider of SPI\_CLK in master transfer. (R/W)

Can be configured in CONF state.

SPI\_CLK\_EQU\_SYSCLK Configures whether or not the SPI\_CLK is equal to clk\_spi\_mst in master transfer. (R/W)

- 0: SPI\_CLK is divided from clk\_spi\_mst.
- 1: SPI\_CLK is equal to clk\_spi\_mst.

Can be configured in CONF state.

![Image](images/28_Chapter_28_img033_fcd0da5b.png)

Register 28.13. SPI\_CLK\_GATE\_REG (0x00E8)

![Image](images/28_Chapter_28_img034_08903951.png)

![Image](images/28_Chapter_28_img035_4190dcf8.png)

![Image](images/28_Chapter_28_img036_436a8f99.png)

SPI\_CLK\_EN Configures whether or not to enable clock gate. (R/W)

- 0: Disable
- 1: Enable

## Register 28.14. SPI\_DIN\_MODE\_REG (0x0024)

![Image](images/28_Chapter_28_img037_fa7d99a4.png)

SPI\_DIN0\_MODE Configures the input mode for FSPID signal. (R/W)

- 0: Input without delay
- 1: Input at the (SPI\_DIN0\_NUM + 1)th falling edge of clk\_spi\_mst
- 2: Input at the (SPI\_DIN0\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst rising edge cycle
- 3: Input at the (SPI\_DIN0\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst falling edge cycle

Can be configured in CONF state.

SPI\_DIN1\_MODE Configures the input mode for FSPIQ signal. (R/W)

- 0: Input without delay
- 1: Input at the (SPI\_DIN1\_NUM+1)th falling edge of clk\_spi\_mst
- 2: Input at the (SPI\_DIN1\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst rising edge cycle
- 3: Input at the (SPI\_DIN1\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst falling edge cycle

Can be configured in CONF state.

SPI\_DIN2\_MODE Configures the input mode for FSPIWP signal. (R/W)

- 0: Input without delay
- 1: Input at the (SPI\_DIN2\_NUM + 1)th falling edge of clk\_spi\_mst
- 2: Input at the (SPI\_DIN2\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst rising edge cycle
- 3: Input at the (SPI\_DIN2\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst falling edge cycle

Can be configured in CONF state.

Continued on the next page...

## Register 28.14. SPI\_DIN\_MODE\_REG (0x0024)

## Continued from the previous page...

SPI\_DIN3\_MODE Configures the input mode for FSPIHD signal. (R/W)

- 0: Input without delay
- 1: Input at the (SPI\_DIN3\_NUM + 1)th falling edge of clk\_spi\_mst
- 2: Input at the (SPI\_DIN3\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst rising edge cycle
- 3: Input at the (SPI\_DIN3\_NUM + 1)th rising edge of clk\_hclk plus one clk\_spi\_mst falling edge cycle

Can be configured in CONF state.

SPI\_TIMING\_HCLK\_ACTIVE Configures whether or not to enable HCLK (high-frequency clock) in SPI input timing module. (R/W)

- 0: Disable
- 1: Enable

Can be configured in CONF state.

## Register 28.15. SPI\_DIN\_NUM\_REG (0x0028)

![Image](images/28_Chapter_28_img038_e7e7c3c4.png)

SPI\_DIN0\_NUM Configures the delays to input signal FSPID based on the setting of SPI\_DIN0\_MODE. (R/W)

- 0: Delayed by 1 clock cycle
- 1: Delayed by 2 clock cycles
- 2: Delayed by 3 clock cycles
- 3: Delayed by 4 clock cycles

Can be configured in CONF state.

SPI\_DIN1\_NUM Configures the delays to input signal FSPIQ based on the setting of SPI\_DIN1\_MODE. (R/W)

- 0: Delayed by 1 clock cycle
- 1: Delayed by 2 clock cycles
- 2: Delayed by 3 clock cycles
- 3: Delayed by 4 clock cycles

Can be configured in CONF state.

SPI\_DIN2\_NUM Configures the delays to input signal FSPIWP based on the setting of SPI\_DIN2\_MODE. (R/W)

- 0: Delayed by 1 clock cycle
- 1: Delayed by 2 clock cycles
- 2: Delayed by 3 clock cycles
- 3: Delayed by 4 clock cycles

Can be configured in CONF state.

- SPI\_DIN3\_NUM Configures the delays to input signal FSPIHD based on the setting of SPI\_DIN3\_MODE. (R/W)
- 0: Delayed by 1 clock cycle
- 1: Delayed by 2 clock cycles
- 2: Delayed by 3 clock cycles
- 3: Delayed by 4 clock cycles

Can be configured in CONF state.

## Register 28.16. SPI\_DOUT\_MODE\_REG (0x002C)

![Image](images/28_Chapter_28_img039_32032947.png)

SPI\_DOUT0\_MODE Configures the output mode for FSPID signal. (R/W)

- 0: Output without delay
- 1: Output with a delay of a SPI module clock cycle at its falling edge

Can be configured in CONF state.

SPI\_DOUT1\_MODE Configures the output mode for FSPIQ signal. (R/W)

- 0: Output without delay
- 1: Output with a delay of a SPI module clock cycle at its falling edge

Can be configured in CONF state.

SPI\_DOUT2\_MODE Configures the output mode for FSPIWP signal. (R/W)

- 0: Output without delay
- 1: Output with a delay of a SPI module clock cycle at its falling edge

Can be configured in CONF state.

SPI\_DOUT3\_MODE Configures the output mode for FSPIHD signal. (R/W)

- 0: Output without delay
- 1: Output with a delay of a SPI module clock cycle at its falling edge

Can be configured in CONF state.

## Register 28.17. SPI\_DMA\_INT\_ENA\_REG (0x0034)

![Image](images/28_Chapter_28_img040_1157282a.png)

SPI\_DMA\_INFIFO\_FULL\_ERR\_INT\_ENA Write 1 to enable SPI\_DMA\_INFIFO\_FULL\_ERR\_INT interrupt. (R/W) SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT\_ENA Write 1 to enable SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT interrupt. (R/W) SPI\_SLV\_EX\_QPI\_INT\_ENA Write 1 to enable SPI\_SLV\_EX\_QPI\_INT interrupt. (R/W) SPI\_SLV\_EN\_QPI\_INT\_ENA Write 1 to enable SPI\_SLV\_EN\_QPI\_INT interrupt. (R/W) SPI\_SLV\_CMD7\_INT\_ENA Write 1 to enable SPI\_SLV\_CMD7\_INT interrupt. (R/W) SPI\_SLV\_CMD8\_INT\_ENA Write 1 to enable SPI\_SLV\_CMD8\_INT interrupt. (R/W) SPI\_SLV\_CMD9\_INT\_ENA Write 1 to enable SPI\_SLV\_CMD9\_INT interrupt. (R/W) SPI\_SLV\_CMDA\_INT\_ENA Write 1 to enable SPI\_SLV\_CMDA\_INT interrupt. (R/W) SPI\_SLV\_RD\_DMA\_DONE\_INT\_ENA Write 1 to enable SPI\_SLV\_RD\_DMA\_DONE\_INT interrupt. (R/W) SPI\_SLV\_WR\_DMA\_DONE\_INT\_ENA Write 1 to enable SPI\_SLV\_WR\_DMA\_DONE\_INT interrupt. (R/W) SPI\_SLV\_RD\_BUF\_DONE\_INT\_ENA Write 1 to enable SPI\_SLV\_RD\_BUF\_DONE\_INT interrupt. (R/W) SPI\_SLV\_WR\_BUF\_DONE\_INT\_ENA Write 1 to enable SPI\_SLV\_WR\_BUF\_DONE\_INT interrupt. (R/W) SPI\_TRANS\_DONE\_INT\_ENA Write 1 to enable SPI\_TRANS\_DONE\_INT interrupt. (R/W) SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_ENA Write 1 to enable SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. (R/W) SPI\_SEG\_MAGIC\_ERR\_INT\_ENA Write 1 to enable SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (R/W) Continued on the next page...

## Register 28.17. SPI\_DMA\_INT\_ENA\_REG (0x0034)

Continued from the previous page...

SPI\_SLV\_CMD\_ERR\_INT\_ENA Write 1 to enable SPI\_SLV\_CMD\_ERR\_INT interrupt. (R/W)

SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_ENA Write 1 to enable SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (R/W)

SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_ENA Write 1 to enable SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (R/W)

SPI\_APP2\_INT\_ENA Write 1 to enable SPI\_APP2\_INT interrupt. (R/W)

SPI\_APP1\_INT\_ENA Write 1 to enable SPI\_APP1\_INT interrupt. (R/W)

![Image](images/28_Chapter_28_img041_85e3427e.png)

## Register 28.18. SPI\_DMA\_INT\_CLR\_REG (0x0038)

![Image](images/28_Chapter_28_img042_3b74c9a8.png)

SPI\_DMA\_INFIFO\_FULL\_ERR\_INT\_CLR Write 1 to clear SPI\_DMA\_INFIFO\_FULL\_ERR\_INT interrupt. (WT)

SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT\_CLR Write 1 to clear SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT interrupt. (WT)

SPI\_SLV\_EX\_QPI\_INT\_CLR Write 1 to clear SPI\_SLV\_EX\_QPI\_INT interrupt. (WT)

SPI\_SLV\_EN\_QPI\_INT\_CLR Write 1 to clear SPI\_SLV\_EN\_QPI\_INT interrupt. (WT)

SPI\_SLV\_CMD7\_INT\_CLR Write 1 to clear SPI\_SLV\_CMD7\_INT interrupt. (WT)

SPI\_SLV\_CMD8\_INT\_CLR Write 1 to clear SPI\_SLV\_CMD8\_INT interrupt. (WT)

SPI\_SLV\_CMD9\_INT\_CLR Write 1 to clear SPI\_SLV\_CMD9\_INT interrupt. (WT)

SPI\_SLV\_CMDA\_INT\_CLR Write 1 to clear SPI\_SLV\_CMDA\_INT interrupt. (WT)

SPI\_SLV\_RD\_DMA\_DONE\_INT\_CLR Write 1 to clear SPI\_SLV\_RD\_DMA\_DONE\_INT interrupt. (WT)

SPI\_SLV\_WR\_DMA\_DONE\_INT\_CLR Write 1 to clear SPI\_SLV\_WR\_DMA\_DONE\_INT interrupt. (WT)

SPI\_SLV\_RD\_BUF\_DONE\_INT\_CLR Write 1 to clear SPI\_SLV\_RD\_BUF\_DONE\_INT interrupt. (WT)

SPI\_SLV\_WR\_BUF\_DONE\_INT\_CLR Write 1 to clear SPI\_SLV\_WR\_BUF\_DONE\_INT interrupt. (WT)

SPI\_TRANS\_DONE\_INT\_CLR Write 1 to clear SPI\_TRANS\_DONE\_INT interrupt. (WT)

SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_CLR Write 1 to clear SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. (WT)

SPI\_SEG\_MAGIC\_ERR\_INT\_CLR Write 1 to clear SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (WT)

Continued on the next page...

## Register 28.18. SPI\_DMA\_INT\_CLR\_REG (0x0038)

Continued from the previous page...

SPI\_SLV\_CMD\_ERR\_INT\_CLR Write 1 to clear SPI\_SLV\_CMD\_ERR\_INT interrupt. (WT)

SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_CLR Write 1 to clear SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (WT)

SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_CLR Write 1 to clear SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (WT)

SPI\_APP2\_INT\_CLR Write 1 to clear SPI\_APP2\_INT interrupt. (WT)

SPI\_APP1\_INT\_CLR Write 1 to clear SPI\_APP1\_INT interrupt. (WT)

![Image](images/28_Chapter_28_img043_85e3427e.png)

## Register 28.19. SPI\_DMA\_INT\_RAW\_REG (0x003C)

![Image](images/28_Chapter_28_img044_5b9f7c79.png)

## Register 28.19. SPI\_DMA\_INT\_RAW\_REG (0x003C)

## Continued from the previous page...

- SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_RAW The raw interrupt status of SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. (R/WTC/SS)
- SPI\_SEG\_MAGIC\_ERR\_INT\_RAW The raw interrupt status of SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (R/WTC/SS)
- SPI\_SLV\_CMD\_ERR\_INT\_RAW The raw interrupt status of SPI\_SLV\_CMD\_ERR\_INT interrupt. (R/WTC/SS)
- SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_RAW The raw interrupt status of SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (R/WTC/SS)
- SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_RAW The raw interrupt status of SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (R/WTC/SS)
- SPI\_APP2\_INT\_RAW The raw interrupt status of SPI\_APP2\_INT interrupt. The value is only controlled by the application. (R/WTC)
- SPI\_APP1\_INT\_RAW The raw interrupt status of SPI\_APP1\_INT interrupt. The value is only controlled by the application. (R/WTC)

## Register 28.20. SPI\_DMA\_INT\_ST\_REG (0x0040)

![Image](images/28_Chapter_28_img045_3939f610.png)

SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT\_ST The interrupt status of

- SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT interrupt. (RO) SPI\_SLV\_EX\_QPI\_INT\_ST The interrupt status of SPI\_SLV\_EX\_QPI\_INT interrupt. (RO) SPI\_SLV\_EN\_QPI\_INT\_ST The interrupt status of SPI\_SLV\_EN\_QPI\_INT interrupt. (RO) SPI\_SLV\_CMD7\_INT\_ST The interrupt status of SPI\_SLV\_CMD7\_INT interrupt. (RO) SPI\_SLV\_CMD8\_INT\_ST The interrupt status of SPI\_SLV\_CMD8\_INT interrupt. (RO) SPI\_SLV\_CMD9\_INT\_ST The interrupt status of SPI\_SLV\_CMD9\_INT interrupt. (RO) SPI\_SLV\_CMDA\_INT\_ST The interrupt status of SPI\_SLV\_CMDA\_INT interrupt. (RO) SPI\_SLV\_RD\_DMA\_DONE\_INT\_ST The interrupt status of SPI\_SLV\_RD\_DMA\_DONE\_INT interrupt. (RO) SPI\_SLV\_WR\_DMA\_DONE\_INT\_ST The interrupt status of SPI\_SLV\_WR\_DMA\_DONE\_INT interrupt. (RO) SPI\_SLV\_RD\_BUF\_DONE\_INT\_ST The interrupt status of SPI\_SLV\_RD\_BUF\_DONE\_INT interrupt. (RO) SPI\_SLV\_WR\_BUF\_DONE\_INT\_ST The interrupt status of SPI\_SLV\_WR\_BUF\_DONE\_INT interrupt. (RO) SPI\_TRANS\_DONE\_INT\_ST The interrupt status of SPI\_TRANS\_DONE\_INT interrupt. (RO) SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_ST The interrupt status of SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. (RO) SPI\_SEG\_MAGIC\_ERR\_INT\_ST The interrupt status of SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (RO) SPI\_SLV\_CMD\_ERR\_INT\_ST The interrupt status of SPI\_SLV\_CMD\_ERR\_INT interrupt. (RO) Continued on the next page...

## Register 28.20. SPI\_DMA\_INT\_ST\_REG (0x0040)

## Continued from the previous page...

SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_ST The interrupt status of SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (RO) SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_ST The interrupt status of SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (RO)

SPI\_APP2\_INT\_ST The interrupt status of SPI\_APP2\_INT interrupt. (RO)

SPI\_APP1\_INT\_ST The interrupt status of SPI\_APP1\_INT interrupt. (RO)

## Register 28.21. SPI\_DMA\_INT\_SET\_REG (0x0044)

![Image](images/28_Chapter_28_img046_a45936ef.png)

SPI\_DMA\_INFIFO\_FULL\_ERR\_INT\_SET Write 1 to set SPI\_DMA\_INFIFO\_FULL\_ERR\_INT interrupt. (WT)

SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT\_SET Write 1 to set SPI\_DMA\_OUTFIFO\_EMPTY\_ERR\_INT interrupt. (WT)

SPI\_SLV\_EX\_QPI\_INT\_SET Write 1 to set SPI\_SLV\_EX\_QPI\_INT interrupt. (WT)

SPI\_SLV\_EN\_QPI\_INT\_SET Write 1 to set SPI\_SLV\_EN\_QPI\_INT interrupt. (WT)

SPI\_SLV\_CMD7\_INT\_SET Write 1 to set SPI\_SLV\_CMD7\_INT interrupt. (WT)

SPI\_SLV\_CMD8\_INT\_SET Write 1 to set SPI\_SLV\_CMD8\_INT interrupt. (WT)

SPI\_SLV\_CMD9\_INT\_SET Write 1 to set SPI\_SLV\_CMD9\_INT interrupt. (WT)

SPI\_SLV\_CMDA\_INT\_SET Write 1 to set SPI\_SLV\_CMDA\_INT interrupt. (WT)

Continued on the next page...

## Register 28.21. SPI\_DMA\_INT\_SET\_REG (0x0044)

## Continued from the previous page...

SPI\_SLV\_RD\_DMA\_DONE\_INT\_SET Write 1 to set SPI\_SLV\_RD\_DMA\_DONE\_INT interrupt. (WT)

SPI\_SLV\_WR\_DMA\_DONE\_INT\_SET Write 1 to set SPI\_SLV\_WR\_DMA\_DONE\_INT interrupt. (WT)

SPI\_SLV\_RD\_BUF\_DONE\_INT\_SET Write 1 to set SPI\_SLV\_RD\_BUF\_DONE\_INT interrupt. (WT)

SPI\_SLV\_WR\_BUF\_DONE\_INT\_SET Write 1 to set SPI\_SLV\_WR\_BUF\_DONE\_INT interrupt. (WT)

SPI\_TRANS\_DONE\_INT\_SET Write 1 to set SPI\_TRANS\_DONE\_INT interrupt. (WT)

SPI\_DMA\_SEG\_TRANS\_DONE\_INT\_SET Write 1 to set SPI\_DMA\_SEG\_TRANS\_DONE\_INT interrupt. (WT)

SPI\_SEG\_MAGIC\_ERR\_INT\_SET Write 1 to set SPI\_SEG\_MAGIC\_ERR\_INT interrupt. (WT)

SPI\_SLV\_CMD\_ERR\_INT\_SET Write 1 to set SPI\_SLV\_CMD\_ERR\_INT interrupt. (WT)

SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT\_SET Write 1 to set SPI\_MST\_RX\_AFIFO\_WFULL\_ERR\_INT interrupt. (WT)

SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT\_SET Write 1 to set SPI\_MST\_TX\_AFIFO\_REMPTY\_ERR\_INT interrupt. (WT)

SPI\_APP2\_INT\_SET Write 1 to set SPI\_APP2\_INT interrupt. (WT)

SPI\_APP1\_INT\_SET Write 1 to set SPI\_APP1\_INT interrupt. (WT)

## Register 28.22. SPI\_Wn\_REG (n: 0-15) (0x0098 + 0x4*n)

![Image](images/28_Chapter_28_img047_7df6db72.png)

![Image](images/28_Chapter_28_img048_efc034b9.png)

SPI\_BUFn 32-bit data buffer n. (R/W/SS)

## Register 28.23. SPI\_DATE\_REG (0x00F0)

![Image](images/28_Chapter_28_img049_7f9d27f3.png)

SPI\_DATE Version control register. (R/W)

![Image](images/28_Chapter_28_img050_c5111fd7.png)
