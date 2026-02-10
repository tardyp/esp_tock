---
chapter: 4
title: "Chapter 4"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 4

## GDMA Controller (GDMA)

## 4.1 Overview

General Direct Memory Access (GDMA) is a feature that allows peripheral-to-memory, memory-to-peripheral, and memory-to-memory data transfer at high speed. The CPU is not involved in the GDMA transfer and therefore is more efficient with less workload.

The GDMA controller in ESP32-C6 has six independent channels, i.e. three transmit channels and three receive channels. These six channels are shared by peripherals with the GDMA feature, and can be assigned to any of such peripherals, including SPI2, UHCI (UART0/UART1), I2S, AES, SHA, ADC, and PARLIO. UART0 and UART1 use UHCI together.

The GDMA controller uses fixed-priority and round-robin channel arbitration schemes to manage peripherals' needs for bandwidth.

Figure 4.1-1. Modules with GDMA Feature and GDMA Channels

![Image](images/04_Chapter_4_img001_868f5d6a.png)

## 4.2 Features

The GDMA controller has the following features:

- AHB bus architecture
- Programmable length of data to be transferred in bytes
- Linked list of descriptors
- INCR burst transfer when accessing internal RAM
- Access to an address space of 384 KB at most in internal RAM

- Three transmit channels and three receive channels
- Software-configurable selection of peripheral requesting its service
- Fixed channel priority and round-robin channel arbitration

## 4.3 Architecture

In ESP32-C6, all modules that need high-speed data transfer support GDMA. The GDMA controller and CPU data bus have access to the same address space in internal RAM. Figure 4.3-1 shows the basic architecture of the GDMA controller.

Figure 4.3-1. GDMA controller Architecture

![Image](images/04_Chapter_4_img002_e25b9cf1.png)

The GDMA controller has six independent channels, i.e. three transmit channels and three receive channels. Every channel can be connected to different peripherals. In other words, channels are general-purpose, shared by peripherals.

The GDMA controller reads data from or writes data to internal RAM via AHB\_BUS. Before this, the GDMA controller uses fixed-priority arbitration scheme for channels requesting read or write access. For available address range of Internal RAM, please see Chapter 5 System and Memory .

Software can use the GDMA controller through linked lists. These linked lists, stored in internal RAM, consist of outlinkn and inlinkn, where n indicates the channel number (ranging from 0 to 2). The GDMA controller reads an outlinkn (i.e. a linked list of transmit descriptors) from internal RAM and transmits data in corresponding RAM according to the outlinkn, or reads an inlinkn (i.e. a linked list of receive descriptors) and stores received data into specific address space in RAM according to the inlinkn .

## 4.4 Functional Description

## 4.4.1 Linked List

Figure 4.4-1. Structure of a Linked List

![Image](images/04_Chapter_4_img003_a7389b73.png)

![Image](images/04_Chapter_4_img004_b5dc1634.png)

Figure 4.4-1 shows the structure of a linked list. An outlink and an inlink have the same structure. A linked list is formed by one or more descriptors, and each descriptor consists of three words. Linked lists should be in internal RAM for the GDMA controller to be able to use them. The meanings of a descriptor's fields are as follows:

- owner (DW0) [31]: Specifies who is allowed to access the buffer that this descriptor points to. 0: CPU can access the buffer.
- 1: The GDMA controller can access the buffer.

When the GDMA controller stops using the buffer, this bit in a receive descriptor is automatically cleared by hardware, and this bit in a transmit descriptor can only be automatically cleared by hardware if GDMA\_OUT\_AUTO\_WRBACK\_CHn is set to 1. Software can disable automatic clearing by hardware by setting GDMA\_OUT\_LOOP\_TEST\_CHn or GDMA\_IN\_LOOP\_TEST\_CHn bit. When software loads a linked list, this bit should be set to 1.

Note: GDMA\_OUT is the prefix of transmit channel registers, and GDMA\_IN is the prefix of receive channel registers.

- suc\_eof (DW0) [30]: Specifies whether the GDMA\_IN\_SUC\_EOF\_CHn\_INT or GDMA\_OUT\_EOF\_CHn\_INT interrupt will be triggered when the data corresponding to this descriptor has been received or transmitted.

1’b0: No interrupt will be triggered after the current descriptor’s successful transfer;

1’b1: An interrupt will be triggered after the current descriptor’s successful transfer.

For receive descriptors, software needs to clear this bit to 0, and hardware will set it to 1 after receiving data containing the EOF flag.

For transmit descriptors, software needs to set this bit to 1 as needed.

If software configures this bit to 1 in a descriptor, the GDMA will include the EOF flag in the data sent to the corresponding peripheral, indicating to the peripheral that this data segment marks the end of one

transfer phase.

- reserved (DW0) [29]: Reserved. Value of this bit does not matter.
- err\_eof (DW0) [28]: Specifies whether the received data has errors.
- 0: The received data does not have errors.
- 1: The received data has errors.

This bit is used only when UHCI or PARLIO uses GDMA to receive data. When an error is detected in the received data segment corresponding to a descriptor, this bit in the receive descriptor is set to 1 by hardware.

- reserved (DW0) [27:24]: Reserved.
- length (DW0) [23:12]: Specifies the number of valid bytes in the buffer that this descriptor points to. This field in a transmit descriptor is written by software and indicates how many bytes can be read from the buffer; this field in a receive descriptor is written by hardware automatically and indicates how many valid bytes have been stored into the buffer.
- size (DW0) [11:0]: Specifies the size of the buffer that this descriptor points to.
- buffer address pointer (DW1): Address of the buffer. This field can only point to internal RAM.
- next descriptor address (DW2): Address of the next descriptor. If the current descriptor is the last one, this value is 0. This field can only point to internal RAM.

If the length of data received is smaller than the size of the buffer, the GDMA controller will not use available space of the buffer in the next transaction.

## 4.4.2 Peripheral-to-Memory and Memory-to-Peripheral Data Transfer

The GDMA controller can transfer data from memory to peripheral (transmit) and from peripheral to memory (receive). A transmit channel transfers data in the specified memory location to a peripheral's transmitter via an outlinkn, whereas a receive channel transfers data received by a peripheral to the specified memory location via an inlinkn .

Every transmit and receive channel can be connected to any peripheral with GDMA feature. Table 4.4-1 illustrates how to select the peripheral to be connected via registers. "Dummy-n" corresponds to register values for memory-to-memory data transfer. When a channel is connected to a peripheral, the rest channels cannot be connected to that peripheral.

Table 4.4-1. Selecting Peripherals via Register Configuration

|   GDMA_PERI_IN_SEL_CHn GDMA_PERI_OUT_SEL_CHn | Peripheral   |
|----------------------------------------------|--------------|
|                                            0 | SPI2         |
|                                            1 | Dummy-1      |
|                                            2 | UHCI         |
|                                            3 | I2S          |
|                                            4 | Dummy-4      |
|                                            5 | Dummy-5      |
|                                            6 | AES          |
|                                            7 | SHA          |

| 8       | ADC             |
|---------|-----------------|
| 9       | PARLIO          |
| 10 ~ 15 | Dummy-10  ~  15 |
| 16 ~ 63 | Invalid         |

## 4.4.3 Memory-to-Memory Data Transfer

The GDMA controller also allows memory-to-memory data transfer. Such data transfer can be enabled by setting GDMA\_MEM\_TRANS\_EN\_CHn, which connects the output of transmit channel n to the input of receive channel n. Note that a transmit channel is only connected to the receive channel with the same number (n), and GDMA\_PERI\_IN\_SEL\_CHn and GDMA\_PERI\_OUT\_SEL\_CHn should be configured to the same value corresponding to "Dummy".

## 4.4.4 Enabling GDMA

Software uses the GDMA controller through linked lists. When the GDMA controller receives data, software loads an inlink, configures GDMA\_INLINK\_ADDR\_CHn field with address of the first receive descriptor, and sets GDMA\_INLINK\_START\_CHn bit to enable GDMA. When the GDMA controller transmits data, software loads an outlink, prepares data to be transmitted, configures GDMA\_OUTLINK\_ADDR\_CHn field with address of the first transmit descriptor, and sets GDMA\_OUTLINK\_START\_CHn bit to enable GDMA. GDMA\_INLINK\_START\_CHn bit and GDMA\_OUTLINK\_START\_CHn bit are cleared automatically by hardware.

In some cases, you may want to append more descriptors to a DMA transfer that is already started. Naively, it would seem to be possible to do this by clearing the EOF bit of the final descriptor in the existing list and setting its next descriptor address pointer field (DW2) to the first descriptor of the to-be-added list. However, this strategy fails if the existing DMA transfer is almost or entirely finished. Instead, the GDMA controller has specialized logic to make sure a DMA transfer can be continued or restarted: if the transfer is ongoing, the controller will make sure to take the appended descriptors into account; if the transfer has already finished, the controller will restart with the new descriptors. This is implemented by the Restart function.

When using the Restart function, software needs to rewrite address of the first descriptor in the new list to DW2 of the last descriptor in the loaded list, and set GDMA\_INLINK\_RESTART\_CHn bit or GDMA\_OUTLINK\_RESTART\_CHn bit (these two bits are cleared automatically by hardware). As shown in Figure 4.4-2, by doing so hardware can obtain the address of the first descriptor in the new list when reading the last descriptor in the loaded list, and then read the new list.

Figure 4.4-2. Relationship among Linked Lists

![Image](images/04_Chapter_4_img005_4b5b4bb2.png)

## 4.4.5 Linked List Reading Process

Once configured and enabled by software, the GDMA controller starts to read the linked list from internal RAM. The GDMA performs checks on descriptors in the linked list. Only if descriptors pass the checks, the corresponding GDMA channel will start data transfer. If the descriptors fail any of the checks, hardware will trigger descriptor error interrupt (either GDMA\_IN\_DSCR\_ERR\_CHn\_INT or GDMA\_OUT\_DSCR\_ERR\_CHn\_INT), and the channel will halt.

The checks performed on descriptors are:

- Owner bit check when GDMA\_IN\_CHECK\_OWNER\_CHn or GDMA\_OUT\_CHECK\_OWNER\_CHn is set to 1. If the owner bit is 0, the buffer is accessed by the CPU. In this case, the owner bit fails the check. The owner bit will not be checked if GDMA\_IN\_CHECK\_OWNER\_CHn or GDMA\_OUT\_CHECK\_OWNER\_CHn is 0.
- Buffer address pointer (DW1) check. If the buffer address pointer points to 0x40800000 ~ 0x4087FFFF (please refer to Section 4.4.7), it passes the check. Otherwise it fails the check.

After software detects a descriptor error interrupt, it must reset the corresponding channel, and enable GDMA by setting GDMA\_OUTLINK\_START\_CHn or GDMA\_INLINK\_START\_CHn bit.

Note: The third word (DW2) in a descriptor can only point to a location in internal RAM, given that the third word points to the next descriptor to use and that all descriptors must be in internal memory.

## 4.4.6 EOF

The GDMA controller uses EOF (end of frame) flags to indicate the end of data segment transfer corresponding to a specific descriptor.

Before the GDMA controller transmits data, GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_ENA bit should be set to enable GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT interrupt. If data in the buffer pointed by the last descriptor (with EOF) has been transmitted, a GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT interrupt is generated.

Before the GDMA controller receives data, GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA bit should be set to enable GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt. If a data segment with an EOF flag has been received successfully, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt is generated. In addition, when GDMA channel is connected to UHCI

or PARLIO, the GDMA controller also supports GDMA\_IN\_ERR\_CHn\_EOF\_INT interrupt. This interrupt is enabled by setting GDMA\_IN\_ERR\_EOF\_CHn\_INT\_ENA bit, and it indicates that a data segment corresponding to a descriptor has been received with errors.

When detecting a GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT or a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt, software can record the value of GDMA\_OUT\_EOF\_DES\_ADDR\_CHn or GDMA\_IN\_SUC\_EOF\_DES\_ADDR\_CHn field, i.e. address of the last descriptor. Therefore, software can tell which descriptors have been used and reclaim them as needed.

Note: In this chapter, EOF of transmit descriptors refers to suc\_eof, while EOF of receive descriptors refers to both suc\_eof and err\_eof.

## 4.4.7 Accessing Internal RAM

Any transmit and receive channels of GDMA can access 0x40800000 ~ 0x4087FFFF in internal RAM. To improve data transfer efficiency, GDMA can send data in burst mode, which is disabled by default. This mode is enabled for receive channels by setting GDMA\_IN\_DATA\_BURST\_EN\_CHn, and enabled for transmit channels by setting GDMA\_OUT\_DATA\_BURST\_EN\_CHn .

Table 4.4-2. Descriptor Field Alignment Requirements

| Inlink/Outlink   |   Burst Mode | Size         | Length   | Buffer Address Pointer   |
|------------------|--------------|--------------|----------|--------------------------|
| Inlink           |            0 | —            | —        | —                        |
| Inlink           |            1 | Word-aligned | —        | Word-aligned             |
| Outlink          |            0 | —            | —        | —                        |
| Outlink          |            1 | —            | —        | —                        |

Table 4.4-2 lists the requirements for descriptor field alignment when accessing internal RAM.

When burst mode is disabled, size, length, and buffer address pointer in both transmit and receive descriptors do not need to be word-aligned. That is, for a descriptor, GDMA can read data of specified length (1 ~ 4095 bytes) from any start addresses in the accessible address range, or write received data of the specified length (1 ~ 4095 bytes) to any contiguous addresses in the accessible address range.

When burst mode is enabled, size, length, and buffer address pointer in transmit descriptors are also not necessarily word-aligned. However, size and buffer address pointer in receive descriptors except length should be word-aligned.

## 4.4.8 Arbitration

To ensure timely response to peripherals running at a high speed with low latency (such as SPI), the GDMA controller implements a fixed-priority channel arbitration scheme. That is to say, each channel can be assigned a priority from 0 ~ 5 (in total 6 levels). The larger the number, the higher the priority, and the more timely the response. When several channels are assigned the same priority, the GDMA controller adopts a round-robin arbitration scheme.

## 4.4.9 Event Task Matrix Feature

The GDMA controller on ESP32-C6 supports the Event Task Matrix (ETM) function, which allows GDMA's ETM tasks to be triggered by any peripherals' ETM events, or GDMA's ETM events to trigger any peripherals' ETM

tasks. This section introduces the ETM tasks and events related to GDMA. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

GDMA can receive the following ETM tasks:

- GDMA\_TASK\_IN\_START\_CHn: Enables the corresponding RX channel n for data transfer.
- GDMA\_TASK\_OUT\_START\_CHn: Enables the corresponding TX channel n for data transfer.

## Note:

Above ETM tasks can achieve the same functions as CPU configuring GDMA\_INLNIK\_START\_CHn and GDMA\_OUTLINK\_START\_CHn . When GDMA\_IN\_ETM\_EN\_CHn or GDMA\_OUT\_ETM\_EN\_CHn is 1, only ETM tasks can be used to configure the transfer direction and enable the corresponding GDMA channel. When GDMA\_IN\_ETM\_EN\_CHn or GDMA\_OUT\_ETM\_EN\_CHn is 0, only CPU can be used to enable the corresponding GDMA channel.

GDMA can generate the following ETM events:

- GDMA\_EVT\_IN\_DONE\_CHn: Indicates that the data has been received according to the receive descriptor via channel n .
- GDMA\_EVT\_IN\_SUC\_EOF\_CHn: Indicates that the data corresponding to a receive descriptor has been received via channel n and the EOF bit of this descriptor is 1.
- GDMA\_EVT\_IN\_FIFO\_EMPTY\_CHn: Indicates that the RX FIFO has become empty.
- GDMA\_EVT\_IN\_FIFO\_FULL\_CHn: Indicates that the RX FIFO has become full.
- GDMA\_EVT\_OUT\_DONE\_CHn: Indicates that the data has been transmitted according to the transmit descriptor via channel n .
- GDMA\_EVT\_OUT\_SUC\_EOF\_CHn: Indicates that the data corresponding to a transmit descriptor has been transmitted or received via channel n and the EOF bit of this descriptor is 1.
- GDMA\_EVT\_OUT\_TOTAL\_EOF\_CHn: Indicates that the data corresponding to the last transmit descriptors has been sent via transmit channel n and the EOF bit of this descriptor is 1.
- GDMA\_EVT\_OUT\_FIFO\_EMPTY\_CHn: Indicates that the TX FIFO has become empty.
- GDMA\_EVT\_OUT\_FIFO\_FULL\_CHn: Indicates that the TX FIFO has become full.

In practical applications, GDMA's ETM events can trigger its own ETM tasks. For example, the GDMA\_EVT\_OUT\_TOTAL\_EOF\_CH0 event can trigger the GDMA\_TASK\_IN\_START\_CH1 task, and in this way trigger a new round of GDMA operations.

## 4.5 GDMA Interrupts

- DMA\_INFIFO\_OVF\_CHn\_INT: Triggered when the RX FIFO of GDMA overflows.
- GDMA\_INFIFO\_UDF\_CHn\_INT: Triggered when the RX FIFO of GDMA underflows.
- GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT: Triggered when the size of the buffer pointed by receive descriptors is smaller than the length of data to be received via receive channel n .
- GDMA\_IN\_DSCR\_ERR\_CHn\_INT: Triggered when an error is detected in a receive descriptor on receive channel n .

- GDMA\_IN\_ERR\_EOF\_CHn\_INT: Triggered when an error is detected in the data segment corresponding to a descriptor received via receive channel n. This interrupt is used only for UHCI peripheral (UART0 or UART1) or PARLIO.
- GDMA\_IN\_SUC\_EOF\_CHn\_INT: Triggered when the suc\_eof bit in a receive descriptor is 1 and the data corresponding to this receive descriptor has been received via receive channel n .
- GDMA\_IN\_DONE\_CHn\_INT: Triggered when all data corresponding to a receive descriptor has been received via receive channel n .
- GMA\_OUTFIFO\_OVF\_CHn\_INT: Triggered when the TX FIFO of GDMA overflows.
- GDMA\_OUTFIFO\_UDF\_CHn\_INT: Triggered when the TX FIFO of GDMA underflows.
- GDMA\_OUT\_DSCR\_ERR\_CHn\_INT: Triggered when an error is detected in a transmit descriptor on transmit channel n .
- GDMA\_OUT\_EOF\_CHn\_INT: Triggered when EOF in a transmit descriptor is 1 and data corresponding to this descriptor has been sent via transmit channel n. If GDMA\_OUT\_EOF\_MODE\_CHn is 0, this interrupt will be triggered when the last byte of data corresponding to this descriptor enters GDMA's transmit channel; if GDMA\_OUT\_EOF\_MODE\_CHn is 1, this interrupt is triggered when the last byte of data is taken from GDMA's transmit channel.
- GDMA\_OUT\_DONE\_CHn\_INT: Triggered when all data corresponding to a transmit descriptor has been sent via transmit channel n .
- GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT: Triggered when all data corresponding to a linked list (including multiple descriptors) has been sent via transmit channel n .

## 4.6 Programming Procedures

The clock gating for GDMA can be configured via PCR\_GDMA\_CLK\_EN, and is enabled by default. GDMA can be reset by configuring PCR\_GDMA\_RST\_EN .

## 4.6.1 Programming Procedures for GDMA's Transmit Channel

To transmit data, GDMA’s transmit channel should be configured by software as follows:

1. Set GDMA\_OUT\_RST\_CHn first to 1 and then to 0, to reset the state machine of GDMA's transmit channel and FIFO pointer.
2. Load an outlink, and configure GDMA\_OUTLINK\_ADDR\_CHn with address of the first transmit descriptor.
3. Configure GDMA\_PERI\_OUT\_SEL\_CHn with the value corresponding to the peripheral to be connected, as shown in Table 4.4-1 .
4. Set GDMA\_OUTLINK\_START\_CHn to enable GDMA’s transmit channel for data transfer.
5. Configure and enable the corresponding peripheral (SPI2, UHCI (UART0 or UART1), I2S, AES, SHA, and ADC). See details in individual chapters of these peripherals.
6. Wait for GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT interrupt, which indicates the completion of data transfer.

## 4.6.2 Programming Procedures for GDMA's Receive Channel

To receive data, GDMA’s receive channel should be configured by software as follows:

1. Set GDMA\_IN\_RST\_CHn first to 1 and then to 0, to reset the state machine of GDMA's receive channel and FIFO pointer.
2. Load an inlink, and configure GDMA\_INLINK\_ADDR\_CHn with address of the first receive descriptor.
3. Configure GDMA\_PERI\_IN\_SEL\_CHn with the value corresponding to the peripheral to be connected, as shown in Table 4.4-1 .
4. Set GDMA\_INLINK\_START\_CHn to enable GDMA’s receive channel for data transfer.
5. Configure and enable the corresponding peripheral (SPI2, UHCI (UART0 or UART1), I2S, AES, SHA, and ADC). See details in individual chapters of these peripherals.

## 4.6.3 Programming Procedures for Memory-to-Memory Transfer

To transfer data from one memory location to another, GDMA should be configured by software as follows:

1. Set GDMA\_OUT\_RST\_CHn first to 1 and then to 0, to reset the state machine of GDMA's transmit channel and FIFO pointer.
2. Set GDMA\_IN\_RST\_CHn first to 1 and then to 0, to reset the state machine of GDMA's receive channel and FIFO pointer.
3. Load an outlink, and configure GDMA\_OUTLINK\_ADDR\_CHn with address of the first transmit descriptor.
4. Load an inlink, and configure GDMA\_INLINK\_ADDR\_CHn with address of the first receive descriptor.
5. Set GDMA\_MEM\_TRANS\_EN\_CHn to enable memory-to-memory transfer.
6. Set GDMA\_OUTLINK\_START\_CHn to enable GDMA’s transmit channel for data transfer.
7. Set GDMA\_INLINK\_START\_CHn to enable GDMA’s receive channel for data transfer.
8. If the suc\_eof bit is set in a transmit descriptor, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interruptwill be triggered when the data segment corresponding to this descriptor has been transmitted.

## 4.7 Register Summary

The addresses in this section are relative to GDMA base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                     | Description                                    | Address   | Access   |
|--------------------------|------------------------------------------------|-----------|----------|
| Interrupt Registers      |                                                |           |          |
| GDMA_IN_INT_RAW_CH0_REG  | Raw interrupt status of RX channel 0           | 0x0000    | R/WTC/SS |
| GDMA_IN_INT_ST_CH0_REG   | Masked interrupt status of RX channel 0        | 0x0004    | RO       |
| GDMA_IN_INT_ENA_CH0_REG  | Interrupt enable bits of RX channel 0          | 0x0008    | R/W      |
| GDMA_IN_INT_CLR_CH0_REG  | Interrupt clear bits of RX channel 0           | 0x000C    | WT       |
| GDMA_IN_INT_RAW_CH1_REG  | Raw interrupt status interrupt of TX channel 1 | 0x0010    | R/WTC/SS |
| GDMA_IN_INT_ST_CH1_REG   | Masked interrupt status of TX channel 1        | 0x0014    | RO       |
| GDMA_IN_INT_ENA_CH1_REG  | Interrupt enable bits of TX channel 1          | 0x0018    | R/W      |
| GDMA_IN_INT_CLR_CH1_REG  | Interrupt clear bits of TX channel 1           | 0x001C    | WT       |
| GDMA_IN_INT_RAW_CH2_REG  | Raw interrupt status of RX channel 2           | 0x0020    | R/WTC/SS |
| GDMA_IN_INT_ST_CH2_REG   | Masked interrupt status of RX channel 2        | 0x0024    | RO       |
| GDMA_IN_INT_ENA_CH2_REG  | Interrupt enable bits of RX channel 2          | 0x0028    | R/W      |
| GDMA_IN_INT_CLR_CH2_REG  | Interrupt clear bits of RX channel 2           | 0x002C    | WT       |
| GDMA_OUT_INT_RAW_CH0_REG | Raw interrupt status of TX channel 0           | 0x0030    | R/WTC/SS |
| GDMA_OUT_INT_ST_CH0_REG  | Masked interrupt status of TX channel 0        | 0x0034    | RO       |
| GDMA_OUT_INT_ENA_CH0_REG | Interrupt enable bits of TX channel 0          | 0x0038    | R/W      |
| GDMA_OUT_INT_CLR_CH0_REG | Interrupt clear bits of TX channel 0           | 0x003C    | WT       |
| GDMA_OUT_INT_RAW_CH1_REG | Raw interrupt status of TX channel 1           | 0x0040    | R/WTC/SS |
| GDMA_OUT_INT_ST_CH1_REG  | Masked interrupt status of TX channel 1        | 0x0044    | RO       |
| GDMA_OUT_INT_ENA_CH1_REG | Interrupt enable bits of TX channel 1          | 0x0048    | R/W      |
| GDMA_OUT_INT_CLR_CH1_REG | Interrupt clear bits of TX channel 1           | 0x004C    | WT       |
| GDMA_OUT_INT_RAW_CH2_REG | Raw interrupt status of TX channel 2           | 0x0050    | R/WTC/SS |
| GDMA_OUT_INT_ST_CH2_REG  | Masked interrupt status of TX channel 2        | 0x0054    | RO       |
| GDMA_OUT_INT_ENA_CH2_REG | Interrupt enable bits of TX channel 2          | 0x0058    | R/W      |
| GDMA_OUT_INT_CLR_CH2_REG | Interrupt clear bits of TX channel 2           | 0x005C    | WT       |
| Debug Registers          |                                                |           |          |
| GDMA_AHB_TEST_REG        | Reserved                                       | 0x0060    | R/W      |
| Configuration Registers  |                                                |           |          |
| GDMA_MISC_CONF_REG       | Miscellaneous register                         | 0x0064    | R/W      |
| GDMA_IN_CONF0_CH0_REG    | Configuration register 0 of RX channel 0       | 0x0070    | R/W      |
| GDMA_IN_CONF1_CH0_REG    | Configuration register 1 of RX channel 0       | 0x0074    | R/W      |
| GDMA_IN_POP_CH0_REG      | Pop control register of RX channel 0           | 0x007C    | varies   |

| Name                             | Description                                                                                               | Address   | Access   |
|----------------------------------|-----------------------------------------------------------------------------------------------------------|-----------|----------|
| GDMA_IN_LINK_CH0_REG             | Linked list descriptor configuration and control register of RX channel 0                                 | 0x0080    | varies   |
| GDMA_OUT_CONF0_CH0_REG           | Configuration register 0 of TX channel 0                                                                  | 0x00D0    | R/W      |
| GDMA_OUT_CONF1_CH0_REG           | Configuration register 1 of TX channel 0                                                                  | 0x00D4    | R/W      |
| GDMA_OUT_PUSH_CH0_REG            | Push control register of RX channel 0                                                                     | 0x00DC    | varies   |
| GDMA_OUT_LINK_CH0_REG            | Linked list descriptor configuration and control register of TX channel 0                                 | 0x00E0    | varies   |
| GDMA_IN_CONF0_CH1_REG            | Configuration register 0 of RX channel 1                                                                  | 0x0130    | R/W      |
| GDMA_IN_CONF1_CH1_REG            | Configuration register 1 of RX channel 1                                                                  | 0x0134    | R/W      |
| GDMA_IN_POP_CH1_REG              | Pop control register of RX channel 1                                                                      | 0x013C    | varies   |
| GDMA_IN_LINK_CH1_REG             | Linked list descriptor configuration and control register of RX channel 1                                 | 0x0140    | varies   |
| GDMA_OUT_CONF0_CH1_REG           | Configuration register 0 of TX channel 1                                                                  | 0x0190    | R/W      |
| GDMA_OUT_CONF1_CH1_REG           | Configuration register 1 of TX channel 1                                                                  | 0x0194    | R/W      |
| GDMA_OUT_PUSH_CH1_REG            | Push control register of RX channel 1                                                                     | 0x019C    | varies   |
| GDMA_OUT_LINK_CH1_REG            | Linked list descriptor configuration and control register of TX channel 1                                 | 0x01A0    | varies   |
| GDMA_IN_CONF0_CH2_REG            | Configuration register 0 of RX channel 2                                                                  | 0x01F0    | R/W      |
| GDMA_IN_CONF1_CH2_REG            | Configuration register 1 of RX channel 2                                                                  | 0x01F4    | R/W      |
| GDMA_IN_POP_CH2_REG              | Pop control register of RX channel 2                                                                      | 0x01FC    | varies   |
| GDMA_IN_LINK_CH2_REG             | Linked list descriptor configuration and control register of RX channel 2                                 | 0x0200    | varies   |
| GDMA_OUT_CONF0_CH2_REG           | Configuration register 0 of TX channel 2                                                                  | 0x0250    | R/W      |
| GDMA_OUT_CONF1_CH2_REG           | Configuration register 1 of TX channel 2                                                                  | 0x0254    | R/W      |
| GDMA_OUT_PUSH_CH2_REG            | Push control register of RX channel 2                                                                     | 0x025C    | varies   |
| GDMA_OUT_LINK_CH2_REG            | Linked list descriptor configuration and control register of TX channel 2                                 | 0x0260    | varies   |
| Version Register                 |                                                                                                           |           |          |
| GDMA_DATE_REG                    | Version control register                                                                                  | 0x0068    | R/W      |
| Status Registers                 |                                                                                                           |           |          |
| GDMA_INFIFO_STATUS_CH0_REG       | Receive FIFO status of RX channel 0                                                                       | 0x0078    | RO       |
| GDMA_IN_STATE_CH0_REG            | Receive status of RX channel 0                                                                            | 0x0084    | RO       |
| GDMA_IN_SUC_EOF_DES_ADDR_CH0_REG | Receive descriptor address when EOF occurs on RX channel 0                                                | 0x0088    | RO       |
| GDMA_IN_ERR_EOF_DES_ADDR_CH0_REG | Receive descriptor address when er rors occur of RX channel 0                                            | 0x008C    | RO       |
| GDMA_IN_DSCR_CH0_REG             | Address of the next receive descriptor pointed by the current pre-read receive descriptor on RX channel 0 | 0x0090    | RO       |
| GDMA_IN_DSCR_BF0_CH0_REG         | Address of the current pre-read receive descriptor on RX channel 0                                        | 0x0094    | RO       |

| Name                               | Description                                                                                                   | Address   | Access   |
|------------------------------------|---------------------------------------------------------------------------------------------------------------|-----------|----------|
| GDMA_IN_DSCR_BF1_CH0_REG           | Address of the previous pre-read re ceive descriptor on RX channel 0                                         | 0x0098    | RO       |
| GDMA_OUTFIFO_STATUS_CH0_REG        | Transmit FIFO status of TX channel 0                                                                          | 0x00D8    | RO       |
| GDMA_OUT_STATE_CH0_REG             | Transmit status of TX channel 0                                                                               | 0x00E4    | RO       |
| GDMA_OUT_EOF_DES_ADDR_CH0_REG      | Transmit descriptor address when EOF occurs on TX channel 0                                                   | 0x00E8    | RO       |
| GDMA_OUT_EOF_BFR_DES_ADDR_CH0 _REG | The last transmit descriptor address when EOF occurs on TX channel 0                                          | 0x00EC    | RO       |
| GDMA_OUT_DSCR_CH0_REG              | Address of the next transmit descriptor pointed by the current pre-read trans mit descriptor on TX channel 0 | 0x00F0    | RO       |
| GDMA_OUT_DSCR_BF0_CH0_REG          | Address of the current pre-read trans mit descriptor on TX channel 0                                         | 0x00F4    | RO       |
| GDMA_OUT_DSCR_BF1_CH0_REG          | Address of the previous pre-read trans mit descriptor on TX channel 0                                        | 0x00F8    | RO       |
| GDMA_INFIFO_STATUS_CH1_REG         | Receive FIFO status of RX channel 1                                                                           | 0x0138    | RO       |
| GDMA_IN_STATE_CH1_REG              | Receive status of RX channel 1                                                                                | 0x0144    | RO       |
| GDMA_IN_SUC_EOF_DES_ADDR_CH1_REG   | Receive descriptor address when EOF occurs on RX channel 1                                                    | 0x0148    | RO       |
| GDMA_IN_ERR_EOF_DES_ADDR_CH1_REG   | Receive descriptor address when er rors occur of RX channel 1                                                | 0x014C    | RO       |
| GDMA_IN_DSCR_CH1_REG               | Address of the next receive descriptor pointed by the current pre-read receive descriptor on RX channel 1     | 0x0150    | RO       |
| GDMA_IN_DSCR_BF0_CH1_REG           | Address of the current pre-read receive descriptor on RX channel 1                                            | 0x0154    | RO       |
| GDMA_IN_DSCR_BF1_CH1_REG           | Address of the previous pre-read re ceive descriptor on RX channel 1                                         | 0x0158    | RO       |
| GDMA_OUTFIFO_STATUS_CH1_REG        | Transmit FIFO status of TX channel 1                                                                          | 0x0198    | RO       |
| GDMA_OUT_STATE_CH1_REG             | Transmit status of TX channel 1                                                                               | 0x01A4    | RO       |
| GDMA_OUT_EOF_DES_ADDR_CH1_REG      | Transmit descriptor address when EOF occurs on TX channel 1                                                   | 0x01A8    | RO       |
| GDMA_OUT_EOF_BFR_DES_ADDR_CH1 _REG | The last transmit descriptor address when EOF occurs on TX channel 1                                          | 0x01AC    | RO       |
| GDMA_OUT_DSCR_CH1_REG              | Address of the next transmit descriptor pointed by the current pre-read trans mit descriptor on TX channel 1 | 0x01B0    | RO       |
| GDMA_OUT_DSCR_BF0_CH1_REG          | Address of the current pre-read trans mit descriptor on TX channel 1                                         | 0x01B4    | RO       |
| GDMA_OUT_DSCR_BF1_CH1_REG          | Address of the previous pre-read trans mit descriptor on TX channel 1                                        | 0x01B8    | RO       |
| GDMA_INFIFO_STATUS_CH2_REG         | Receive FIFO status of RX channel 2                                                                           | 0x01F8    | RO       |
| GDMA_IN_STATE_CH2_REG              | Receive status of RX channel 2                                                                                | 0x0204    | RO       |

| Name                               | Description                                                                                                   | Address   | Access   |
|------------------------------------|---------------------------------------------------------------------------------------------------------------|-----------|----------|
| GDMA_IN_SUC_EOF_DES_ADDR_CH2_REG   | Receive descriptor address when EOF occurs on RX channel 2                                                    | 0x0208    | RO       |
| GDMA_IN_ERR_EOF_DES_ADDR_CH2_REG   | Receive descriptor address when er rors occur of RX channel 2                                                | 0x020C    | RO       |
| GDMA_IN_DSCR_CH2_REG               | Address of the next receive descriptor pointed by the current pre-read receive descriptor on RX channel 2     | 0x0210    | RO       |
| GDMA_IN_DSCR_BF0_CH2_REG           | Address of the current pre-read receive descriptor on RX channel 2                                            | 0x0214    | RO       |
| GDMA_IN_DSCR_BF1_CH2_REG           | Address of the previous pre-read re ceive descriptor on RX channel 2                                         | 0x0218    | RO       |
| GDMA_OUTFIFO_STATUS_CH2_REG        | Transmit FIFO status of TX channel 2                                                                          | 0x0258    | RO       |
| GDMA_OUT_STATE_CH2_REG             | Transmit status of TX channel 2                                                                               | 0x0264    | RO       |
| GDMA_OUT_EOF_DES_ADDR_CH2_REG      | Transmit descriptor address when EOF occurs on TX channel 2                                                   | 0x0268    | RO       |
| GDMA_OUT_EOF_BFR_DES_ADDR_CH2 _REG | The last transmit descriptor address when EOF occurs on TX channel 2                                          | 0x026C    | RO       |
| GDMA_OUT_DSCR_CH2_REG              | Address of the next transmit descriptor pointed by the current pre-read trans mit descriptor on TX channel 2 | 0x0270    | RO       |
| GDMA_OUT_DSCR_BF0_CH2_REG          | Address of the current pre-read trans mit descriptor on TX channel 2                                         | 0x0274    | RO       |
| GDMA_OUT_DSCR_BF1_CH2_REG          | Address of the previous pre-read trans mit descriptor on TX channel 2                                        | 0x0278    | RO       |
| Priority Registers                 |                                                                                                               |           |          |
| GDMA_IN_PRI_CH0_REG                | Priority register of RX channel 0                                                                             | 0x009C    | R/W      |
| GDMA_OUT_PRI_CH0_REG               | Priority register of TX channel 0                                                                             | 0x00FC    | R/W      |
| GDMA_IN_PRI_CH1_REG                | Priority register of RX channel 1                                                                             | 0x015C    | R/W      |
| GDMA_OUT_PRI_CH1_REG               | Priority register of TX channel 1                                                                             | 0x01BC    | R/W      |
| GDMA_IN_PRI_CH2_REG                | Priority register of RX channel 2                                                                             | 0x021C    | R/W      |
| GDMA_OUT_PRI_CH2_REG               | Priority register of TX channel 2                                                                             | 0x027C    | R/W      |
| Peripheral Selection Registers     |                                                                                                               |           |          |
| GDMA_IN_PERI_SEL_CH0_REG           | Peripheral selection register of RX channel 0                                                                 | 0x00A0    | R/W      |
| GDMA_OUT_PERI_SEL_CH0_REG          | Peripheral selection register of TX channel 0                                                                 | 0x0100    | R/W      |
| GDMA_IN_PERI_SEL_CH1_REG           | Peripheral selection register of RX channel 1                                                                 | 0x0160    | R/W      |
| GDMA_OUT_PERI_SEL_CH1_REG          | Peripheral selection register of TX channel 1                                                                 | 0x01C0    | R/W      |
| GDMA_IN_PERI_SEL_CH2_REG           | Peripheral selection register of RX channel 2                                                                 | 0x0220    | R/W      |
| GDMA_OUT_PERI_SEL_CH2_REG          | Peripheral selection register of TX channel 2                                                                 | 0x0280    | R/W      |

## 4.8 Registers

The addresses in this section are relative to GDMA base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 4.1. GDMA\_IN\_INT\_RAW\_CHn\_REG (n: 0-2) (0x0000+0x10*n)

![Image](images/04_Chapter_4_img006_4261b034.png)

- GDMA\_IN\_DONE\_CHn\_INT\_RAW The raw interrupt status of GDMA\_IN\_DONE\_CHn\_INT. (R/WTC/SS)
- GDMA\_IN\_SUC\_EOF\_CHn\_INT\_RAW The raw interrupt status of GDMA\_IN\_SUC\_EOF\_CHn\_INT. For UHCI this bit turns to 1 when the last data byte pointed by one receive descriptor has been received and no data error is detected for RX channel 0. (R/WTC/SS)
- GDMA\_IN\_ERR\_EOF\_CHn\_INT\_RAW The raw interrupt status of GDMA\_IN\_ERR\_EOF\_CHn\_INT. Valid only for UHCI or PARLIO. (R/WTC/SS)
- GDMA\_IN\_DSCR\_ERR\_CHn\_INT\_RAW The raw interrupt status of GDMA\_IN\_DSCR\_ERR\_CHn\_INT. (R/WTC/SS)
- GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT\_RAW The raw interrupt status of GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT. (R/WTC/SS)
- GDMA\_INFIFO\_OVF\_CHn\_INT\_RAW The raw interrupt status of GDMA\_INFIFO\_OVF\_CHn\_INT. (R/WTC/SS)
- GDMA\_INFIFO\_UDF\_CHn\_INT\_RAW The raw interrupt status of GDMA\_INFIFO\_UDF\_CHn\_INT. (R/WTC/SS)

Register 4.2. GDMA\_IN\_INT\_ST\_CHn\_REG (n: 0-2) (0x0004+0x10*n)

![Image](images/04_Chapter_4_img007_5fc30bf6.png)

GDMA\_IN\_DONE\_CHn\_INT\_ST The masked interrupt status of GDMA\_IN\_DONE\_CHn\_INT. (RO) GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ST The masked interrupt status of GDMA\_IN\_SUC\_EOF\_CHn\_INT. (RO) GDMA\_IN\_ERR\_EOF\_CHn\_INT\_ST The masked interrupt status of GDMA\_IN\_ERR\_EOF\_CHn\_INT. (RO) GDMA\_IN\_DSCR\_ERR\_CHn\_INT\_ST The masked interrupt status of GDMA\_IN\_DSCR\_ERR\_CHn\_INT. (RO) GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT\_ST The masked interrupt status of GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT. (RO) GDMA\_INFIFO\_OVF\_CHn\_INT\_ST The masked interrupt status of GDMA\_INFIFO\_OVF\_CHn\_INT. (RO) GDMA\_INFIFO\_UDF\_CHn\_INT\_ST The masked interrupt status of GDMA\_INFIFO\_UDF\_CHn\_INT.

- (RO)

Register 4.3. GDMA\_IN\_INT\_ENA\_CHn\_REG (n: 0-2) (0x0008+0x10*n)

![Image](images/04_Chapter_4_img008_dde6387a.png)

GDMA\_IN\_DONE\_CHn\_INT\_ENA Write 1 to enable GDMA\_IN\_DONE\_CHn\_INT. (R/W) GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA Write 1 to enable GDMA\_IN\_SUC\_EOF\_CHn\_INT. (R/W) GDMA\_IN\_ERR\_EOF\_CHn\_INT\_ENA Write 1 to enable GDMA\_IN\_ERR\_EOF\_CHn\_INT. (R/W) GDMA\_IN\_DSCR\_ERR\_CHn\_INT\_ENA Write 1 to enable GDMA\_IN\_DSCR\_ERR\_CHn\_INT. (R/W) GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT\_ENA Write 1 to enable GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT. (R/W) GDMA\_INFIFO\_OVF\_CHn\_INT\_ENA Write 1 to enable GDMA\_INFIFO\_OVF\_CHn\_INT. (R/W) GDMA\_INFIFO\_UDF\_CHn\_INT\_ENA Write 1 to enable GDMA\_INFIFO\_UDF\_CHn\_INT. (R/W)

Submit Documentation Feedback

Register 4.4. GDMA\_IN\_INT\_CLR\_CHn\_REG (n: 0-2) (0x000C+0x10*n)

![Image](images/04_Chapter_4_img009_0d34b953.png)

GDMA\_IN\_DONE\_CHn\_INT\_CLR Write 1 to clear GDMA\_IN\_DONE\_CHn\_INT. (WT) GDMA\_IN\_SUC\_EOF\_CHn\_INT\_CLR Write 1 to clear GDMA\_IN\_SUC\_EOF\_CHn\_INT. (WT) GDMA\_IN\_ERR\_EOF\_CHn\_INT\_CLR Write 1 to clear GDMA\_IN\_ERR\_EOF\_CHn\_INT. (WT) GDMA\_IN\_DSCR\_ERR\_CHn\_INT\_CLR Write 1 to clear GDMA\_IN\_DSCR\_ERR\_CHn\_INT. (WT) GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT\_CLR Write 1 to clear GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT. (WT) GDMA\_INFIFO\_OVF\_CHn\_INT\_CLR Write 1 to clear GDMA\_INFIFO\_OVF\_CHn\_INT. (WT) GDMA\_INFIFO\_UDF\_CHn\_INT\_CLR Write 1 to clear GDMA\_INFIFO\_UDF\_CHn\_INT. (WT)

Submit Documentation Feedback

Register 4.5. GDMA\_OUT\_INT\_RAW\_CHn\_REG (n: 0-2) (0x0030+0x10*n)

![Image](images/04_Chapter_4_img010_93935be2.png)

GDMA\_OUT\_DONE\_CHn\_INT\_RAW The raw interrupt status of GDMA\_OUT\_DONE\_CHn\_INT. (R/WTC/SS) GDMA\_OUT\_EOF\_CHn\_INT\_RAW The raw interrupt status of GDMA\_OUT\_EOF\_CHn\_INT. (R/WTC/SS) GDMA\_OUT\_DSCR\_ERR\_CHn\_INT\_RAW The raw interrupt status of GDMA\_OUT\_DSCR\_ERR\_CHn\_INT. (R/WTC/SS) GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_RAW The raw interrupt status of GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT. (R/WTC/SS) GDMA\_OUTFIFO\_OVF\_CHn\_INT\_RAW The raw interrupt status of GDMA\_OUTFIFO\_OVF\_CHn\_INT. (R/WTC/SS) GDMA\_OUTFIFO\_UDF\_CHn\_INT\_RAW The raw interrupt status of GDMA\_OUTFIFO\_UDF\_CHn\_INT. (R/WTC/SS)

Submit Documentation Feedback

Register 4.6. GDMA\_OUT\_INT\_ST\_CHn\_REG (n: 0-2) (0x0034+0x10*n)

![Image](images/04_Chapter_4_img011_9b26b578.png)

GDMA\_OUT\_DONE\_CHn\_INT\_ST The masked interrupt status of GDMA\_OUT\_DONE\_CHn\_INT. (RO)

GDMA\_OUT\_EOF\_CHn\_INT\_ST The masked interrupt status of GDMA\_OUT\_EOF\_CHn\_INT. (RO)

| GDMA_OUT_DSCR_ERR_CHn_INT_ST  The  GDMA_OUT_DSCR_ERR_CHn_INT. (RO)   | masked   | interrupt   | status   | of   |
|----------------------------------------------------------------------|----------|-------------|----------|------|
| GDMA_OUT_TOTAL_EOF_CHn_INT_ST  The  GDMA_OUT_TOTAL_EOF_CHn_INT. (RO) | masked   | interrupt   | status   | of   |
| GDMA_OUTFIFO_OVF_CHn_INT_ST  The  GDMA_OUTFIFO_OVF_CHn_INT. (RO)     | masked   | interrupt   | status   | of   |
| GDMA_OUTFIFO_UDF_CHn_INT_ST  The  GDMA_OUTFIFO_UDF_CHn_INT. (RO)     | masked   | interrupt   | status   | of   |

Register 4.7. GDMA\_OUT\_INT\_ENA\_CHn\_REG (n: 0-2) (0x0038+0x10*n)

![Image](images/04_Chapter_4_img012_ce473c1d.png)

GDMA\_OUT\_DONE\_CHn\_INT\_ENA Write 1 to enable GDMA\_OUT\_DONE\_CHn\_INT. (R/W) GDMA\_OUT\_EOF\_CHn\_INT\_ENA Write 1 to enable GDMA\_OUT\_EOF\_CHn\_INT. (R/W) GDMA\_OUT\_DSCR\_ERR\_CHn\_INT\_ENA Write 1 to enable GDMA\_OUT\_DSCR\_ERR\_CHn\_INT. (R/W)

GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_ENA Write 1 to enable GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT. (R/W)

GDMA\_OUTFIFO\_OVF\_CHn\_INT\_ENA Write 1 to enable GDMA\_OUTFIFO\_OVF\_CHn\_INT. (R/W)

GDMA\_OUTFIFO\_UDF\_CHn\_INT\_ENA Write 1 to enable GDMA\_OUTFIFO\_UDF\_CHn\_INT. (R/W)

Register 4.8. GDMA\_OUT\_INT\_CLR\_CHn\_REG (n: 0-2) (0x003C+0x10*n)

![Image](images/04_Chapter_4_img013_197b1735.png)

GDMA\_OUT\_DONE\_CHn\_INT\_CLR Write 1 to clear GDMA\_OUT\_DONE\_CHn\_INT. (WT)

GDMA\_OUT\_EOF\_CHn\_INT\_CLR Write 1 to clear GDMA\_OUT\_EOF\_CHn\_INT. (WT)

GDMA\_OUT\_DSCR\_ERR\_CHn\_INT\_CLR Write 1 to clear GDMA\_OUT\_DSCR\_ERR\_CHn\_INT. (WT)

GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_CLR Write 1 to clear GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT. (WT)

GDMA\_OUTFIFO\_OVF\_CHn\_INT\_CLR Write 1 to clear GDMA\_OUTFIFO\_OVF\_CHn\_INT. (WT)

GDMA\_OUTFIFO\_UDF\_CHn\_INT\_CLR Write 1 to clear GDMA\_OUTFIFO\_UDF\_CHn\_INT. (WT)

## Register 4.9. GDMA\_AHB\_TEST\_REG (0x0060)

![Image](images/04_Chapter_4_img014_1ecc16e2.png)

GDMA\_AHB\_TESTMODE Reserved. (R/W)

GDMA\_AHB\_TESTADDR Reserved. (R/W)

## Register 4.10. GDMA\_MISC\_CONF\_REG (0x0064)

![Image](images/04_Chapter_4_img015_e0435827.png)

GDMA\_AHBM\_RST\_INTER Write 1 and then 0 to reset the internal AHB FSM. (R/W)

GDMA\_ARB\_PRI\_DIS Configures whether or not to disable the fixed-priority channel arbitration.

- 0: Enable
- 1: Disable

(R/W)

## GDMA\_CLK\_EN Configures clock gating.

- 0: Support clock only when the application writes registers.
- 1: Always force the clock on for registers.

(R/W)

Register 4.11. GDMA\_IN\_CONF0\_CHn\_REG (n: 0-2) (0x0070+0xC0*n)

![Image](images/04_Chapter_4_img016_a0868d49.png)

GDMA\_IN\_RST\_CHn Write 1 and then 0 to reset GDMA channel 0 RX FSM and RX FIFO pointer.(R/W)

GDMA\_IN\_LOOP\_TEST\_CHn Reserved. (R/W)

GDMA\_INDSCR\_BURST\_EN\_CHn Configures whether or not to enable INCR burst transfer for RX channel n to read descriptors.

0: Disable

1: Enable

(R/W)

GDMA\_IN\_DATA\_BURST\_EN\_CHn Configures whether or not to enable INCR burst transfer for RX

channel n .

0: Disable

1: Enable

(R/W)

GDMA\_MEM\_TRANS\_EN\_CHn Configures whether or not to enable memory-to-memory data trans- fer.

0: Disable

1: Enable

(R/W)

GDMA\_IN\_ETM\_EN\_CHn Configures whether or not to enable ETM control for RX channeln .

0: Disable

1: Enable

(R/W)

Register 4.12. GDMA\_IN\_CONF1\_CHn\_REG (n: 0-2) (0x0074+0xC0*n)

![Image](images/04_Chapter_4_img017_92fe17a2.png)

GDMA\_IN\_CHECK\_OWNER\_CHn Configures whether or not to enable owner bit check for RX chan- nel n .

0: Disable

1: Enable

(R/W)

Register 4.13. GDMA\_IN\_POP\_CHn\_REG (n: 0-2) (0x007C+0xC0*n)

![Image](images/04_Chapter_4_img018_0bb0fb01.png)

GDMA\_INFIFO\_RDATA\_CHn

Represents the data popped from GDMA FIFO. (RO)

GDMA\_INFIFO\_POP\_CHn Configures whether to pop data from GDMA FIFO.

0: Invalid. No effect

1: Pop

(WT)

Register 4.14. GDMA\_IN\_LINK\_CHn\_REG (n: 0-2) (0x0080+0xC0*n)

![Image](images/04_Chapter_4_img019_d1724d3a.png)

GDMA\_INLINK\_ADDR\_CHn Represents the lower 20 bits of the first receive descriptor's address. (R/W)

GDMA\_INLINK\_AUTO\_RET\_CHn Configures whether or not to return to the current receive descriptor's address when there are some errors in current receiving data.

0: Not return

1: Return

(R/W)

GDMA\_INLINK\_STOP\_CHn Configures whether to stop GDMA's RX channel n from receiving data.

0: Invalid. No effect

1: Stop

(WT)

GDMA\_INLINK\_START\_CHn Configures whether or not to enable GDMA's RX channel n for data transfer.

0: Disable

1: Enable

(WT)

GDMA\_INLINK\_RESTART\_CHn Configures whether to restart RX channel n for GDMA transfer.

0: Invalid. No effect

```
1: Restart
```

(WT)

GDMA\_INLINK\_PARK\_CHn Represents the status of the receive descriptor's FSM.

0: Running

1: Idle

(RO)

Register 4.15. GDMA\_OUT\_CONF0\_CHn\_REG (n: 0-2) (0x00D0+0xC0*n)

![Image](images/04_Chapter_4_img020_ddfa3516.png)

GDMA\_OUT\_RST\_CHn Configures the reset state of GDMA channel n TX FSM and TX FIFO pointer.

0: Release reset

1: Reset

(R/W)

GDMA\_OUT\_LOOP\_TEST\_CHn Reserved. (R/W)

GDMA\_OUT\_AUTO\_WRBACK\_CHn Configures whether or not to enable automatic outlink writeback when all the data in TX FIFO has been transmitted.

0: Disable

1: Enable

(R/W)

GDMA\_OUT\_EOF\_MODE\_CHn Configures when to generate EOF flag.

0: EOF flag for TX channel n is generated when data to be transmitted has been pushed into FIFO in GDMA.

1: EOF flag for TX channel n is generated when data to be transmitted has been popped from FIFO in GDMA.

(R/W)

GDMA\_OUTDSCR\_BURST\_EN\_CHn Configures whether or not to enable INCR burst transfer for TX

channel n reading descriptors.

0: Disable

1: Enable

(R/W)

GDMA\_OUT\_DATA\_BURST\_EN\_CHn Configures whether or not to enable INCR burst transfer for TX

channel n .

0: Disable

1: Enable

(R/W)

GDMA\_OUT\_ETM\_EN\_CHn Configures whether or not to enable ETM control for TX channel n .

0: Disable

1: Enable

( (R/W)

Register 4.16. GDMA\_OUT\_CONF1\_CHn\_REG (n: 0-2) (0x00D4+0xC0*n)

![Image](images/04_Chapter_4_img021_25413fe5.png)

GDMA\_OUT\_CHECK\_OWNER\_CHn Configures whether or not to enable owner bit check for TX channel n .

0: Disable

1: Enable

(R/W)

Register 4.17. GDMA\_OUT\_PUSH\_CHn\_REG (n: 0-2) (0x00DC+0xC0*n)

![Image](images/04_Chapter_4_img022_0a7ebc9e.png)

GDMA\_OUTFIFO\_WDATA\_CHn Represents the data that need to be pushed into GDMA FIFO. (R/W)

GDMA\_OUTFIFO\_PUSH\_CHn Configures whether to push data into GDMA FIFO.

0: Invalid. No effect

1: Push

(WT)

Register 4.18. GDMA\_OUT\_LINK\_CHn\_REG (n: 0-2) (0x00E0+0xC0*n)

![Image](images/04_Chapter_4_img023_64eda7e6.png)

GDMA\_OUTLINK\_ADDR\_CHn Represents the lower 20 bits of the first transmit descriptor's address. (R/W)

GDMA\_OUTLINK\_STOP\_CHn Configures whether to stop GDMA's TX channel n from transmitting data.

0: Invalid. No effect

1: Stop

(WT)

GDMA\_OUTLINK\_START\_CHn Configures whether to enable GDMA's TX channel n for data transfer.

0: Disable

1: Enable

(WT)

GDMA\_OUTLINK\_RESTART\_CHn Configures whether to restart TX channel n for GDMA transfer.

0: Invalid. No effect

1: Restart

(WT)

GDMA\_OUTLINK\_PARK\_CHn Represents the status of the transmit descriptor's FSM.

0: Running

1: Idle

(RO)

## Register 4.19. GDMA\_DATE\_REG (0x0068)

![Image](images/04_Chapter_4_img024_38b4121d.png)

GDMA\_DATE Version control register. (R/W)

Register 4.20. GDMA\_INFIFO\_STATUS\_CHn\_REG (n: 0-2) (0x0078+0xC0*n)

![Image](images/04_Chapter_4_img025_7e9e4f05.png)

GDMA\_INFIFO\_FULL\_CHn Represents whether or not L1 RX FIFO is full.

0: Not Full

1: Full

(RO)

GDMA\_INFIFO\_EMPTY\_CHn Represents whether or not L1 RX FIFO is empty.

```
0: Not empty 1: Empty
```

(RO)

GDMA\_INFIFO\_CNT\_CHn Represents the number of data bytes in L1 RX FIFO for RX channel n. (RO)

GDMA\_IN\_REMAIN\_UNDER\_1B\_CHn Reserved. (RO)

GDMA\_IN\_REMAIN\_UNDER\_2B\_CHn Reserved. (RO)

GDMA\_IN\_REMAIN\_UNDER\_3B\_CHn Reserved. (RO)

GDMA\_IN\_REMAIN\_UNDER\_4B\_CHn Reserved. (RO)

GDMA\_IN\_BUF\_HUNGRY\_CHn Reserved. (RO)

Register 4.21. GDMA\_IN\_STATE\_CHn\_REG (n: 0-2) (0x0084+0xC0*n)

![Image](images/04_Chapter_4_img026_970d465b.png)

GDMA\_INLINK\_DSCR\_ADDR\_CHn Represents the lower 18 bits of the next receive descriptor address that is pre-read (but not processed yet). If the current receive descriptor is the last descriptor, then this field represents the address of the current receive descriptor. (RO)

GDMA\_IN\_DSCR\_STATE\_CHn Reserved. (RO)

GDMA\_IN\_STATE\_CHn Reserved. (RO)

Register 4.22. GDMA\_IN\_SUC\_EOF\_DES\_ADDR\_CHn\_REG (n: 0-2) (0x0088+0xC0*n)

![Image](images/04_Chapter_4_img027_47dbe8e3.png)

GDMA\_IN\_SUC\_EOF\_DES\_ADDR\_CHn Represents the address of the receive descriptor when the EOF bit in this descriptor is 1. (RO)

Register 4.23. GDMA\_IN\_ERR\_EOF\_DES\_ADDR\_CHn\_REG (n: 0-2) (0x008C+0xC0*n)

![Image](images/04_Chapter_4_img028_25c5d6fb.png)

GDMA\_IN\_ERR\_EOF\_DES\_ADDR\_CHn Represents the address of the receive descriptor when there are some errors in the currently received data. Valid only for UHCI or PARLIO. (RO)

Register 4.24. GDMA\_IN\_DSCR\_CHn\_REG (n: 0-2) (0x0090+0xC0*n)

GDMA\_INLINK\_DSCR\_CH0

![Image](images/04_Chapter_4_img029_286411e1.png)

GDMA\_INLINK\_DSCR\_CHn Represents the address of the next receive descriptor x+1 pointed by the current receive descriptor that is pre-read. (RO)

Register 4.25. GDMA\_IN\_DSCR\_BF0\_CHn\_REG (n: 0-2) (0x0094+0xC0*n)

GDMA\_INLINK\_DSCR\_BF0\_CH0

![Image](images/04_Chapter_4_img030_cff98f00.png)

GDMA\_INLINK\_DSCR\_BF0\_CHn Represents the address of the current receive descriptor x that is pre-read. (RO)

Register 4.26. GDMA\_IN\_DSCR\_BF1\_CHn\_REG (n: 0-2) (0x0098+0xC0*n)

![Image](images/04_Chapter_4_img031_7e079554.png)

GDMA\_INLINK\_DSCR\_BF1\_CHn Represents the address of the previous receive descriptor x-1 that is pre-read. (RO)

## Register 4.27. GDMA\_OUTFIFO\_STATUS\_CHn\_REG (n: 0-2) (0x00D8+0xC0*n)

![Image](images/04_Chapter_4_img032_19312a8a.png)

GDMA\_OUTFIFO\_FULL\_CHn Represents whether or not L1 TX FIFO is full.

0: Not Full

1: Full

(RO)

- GDMA\_OUTFIFO\_EMPTY\_CHn Represents whether or not L1 TX FIFO is empty.

0: Not empty

1: Empty

(RO)

GDMA\_OUTFIFO\_CNT\_CHn Represents the number of data bytes in L1 TX FIFO for TX channel n . (RO)

GDMA\_OUT\_REMAIN\_UNDER\_1B\_CHn Reserved. (RO)

GDMA\_OUT\_REMAIN\_UNDER\_2B\_CHn Reserved. (RO)

GDMA\_OUT\_REMAIN\_UNDER\_3B\_CHn Reserved. (RO)

GDMA\_OUT\_REMAIN\_UNDER\_4B\_CHn Reserved. (RO)

Register 4.28. GDMA\_OUT\_STATE\_CHn\_REG (n: 0-2) (0x00E4+0xC0*n)

![Image](images/04_Chapter_4_img033_3f5f49d4.png)

GDMA\_OUTLINK\_DSCR\_ADDR\_CHn Represents the lower 18 bits of the next transmit descriptor address that is pre-read (but not processed yet). If the current transmit descriptor is the last descriptor, then this field represents the address of the current transmit descriptor. (RO)

GDMA\_OUT\_DSCR\_STATE\_CHn Reserved. (RO)

GDMA\_OUT\_STATE\_CHn Reserved. (RO)

Register 4.29. GDMA\_OUT\_EOF\_DES\_ADDR\_CHn\_REG (n: 0-2) (0x00E8+0xC0*n)

![Image](images/04_Chapter_4_img034_772639cd.png)

GDMA\_OUT\_EOF\_DES\_ADDR\_CHn Represents the address of the transmit descriptor when the EOF bit in this descriptor is 1. (RO)

Register 4.30. GDMA\_OUT\_EOF\_BFR\_DES\_ADDR\_CHn\_REG (n: 0-2) (0x00EC+0xC0*n)

![Image](images/04_Chapter_4_img035_f289b196.png)

GDMA\_OUT\_EOF\_BFR\_DES\_ADDR\_CHn Represents the address of the transmit descriptor before the last transmit descriptor. (RO)

Register 4.31. GDMA\_OUT\_DSCR\_CHn\_REG (n: 0-2) (0x00F0+0xC0*n)

GDMA\_OUTLINK\_DSCR\_CH0

![Image](images/04_Chapter_4_img036_d7e46875.png)

GDMA\_OUTLINK\_DSCR\_CHn Represents the address of the next transmit descriptor y+1 pointed by the current transmit descriptor that is pre-read. (RO)

Register 4.32. GDMA\_OUT\_DSCR\_BF0\_CHn\_REG (n: 0-2) (0x00F4+0xC0*n)

![Image](images/04_Chapter_4_img037_1e53cd59.png)

GDMA\_OUTLINK\_DSCR\_BF0\_CHn Represents the address of the current transmit descriptor y that is pre-read. (RO)

Value range: 0

~

9

![Image](images/04_Chapter_4_img038_f445ef30.png)

Register 4.36. GDMA\_IN\_PERI\_SEL\_CHn\_REG (n: 0-2) (0x00A0+0xC0*n)

![Image](images/04_Chapter_4_img039_9642603d.png)

GDMA\_PERI\_IN\_SEL\_CHn Configures the peripheral connected to RX channel n .

- 0: SPI2
- 1: Dummy-1
- 2: UHCI
- 3: I2S
- 4: Dummy-4
- 5: Dummy-5
- 6: AES
- 7: SHA
- 8: ADC
- 9: Parallel IO
- 10 ~ 15: Dummy-10 ~ 15
- 16 ~ 63: Invalid
- (R/W)

Register 4.37. GDMA\_OUT\_PERI\_SEL\_CHn\_REG (n: 0-2) (0x0100+0xC0*n)

![Image](images/04_Chapter_4_img040_da9a2f20.png)

GDMA\_PERI\_OUT\_SEL\_CHn Configures the peripheral connected to TX channel n .

- 0: SPI2
- 1: Dummy-1
- 2: UHCI
- 3: I2S
- 4: Dummy-4
- 5: Dummy-5
- 6: AES
- 7: SHA
- 8: ADC
- 9: Parallel IO
- 10 ~ 15: Dummy-10 ~ 15
- 16 ~ 63: Invalid
- (R/W)

## Part II

## Memory Organization

This part provides insights into the system's memory structure, discussing the organization and mapping of RAM, ROM, eFuse, and external memories, offering a framework for understanding memory-related subsystems.
