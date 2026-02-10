---
chapter: 2
title: "Chapter 2"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 2

## GDMA Controller (GDMA)

## 2.1 Overview

General Direct Memory Access (GDMA) is a feature that allows peripheral-to-memory, memory-to-peripheral, and memory-to-memory data transfer at a high speed. The CPU is not involved in the GDMA transfer, and therefore it becomes more efficient with less workload.

The GDMA controller in ESP32-C3 has six independent channels, i.e. three transmit channels and three receive channels. These six channels are shared by peripherals with GDMA feature, namely SPI2, UHCI0 (UART0/UART1), I2S, AES, SHA, and ADC. Users can assign the six channels to any of these peripherals. UART0 and UART1 use UHCI0 together.

The GDMA controller uses fixed-priority and round-robin channel arbitration schemes to manage peripherals' needs for bandwidth.

Figure 2.1-1. Modules with GDMA Feature and GDMA Channels

![Image](images/02_Chapter_2_img001_36b8b1bb.png)

## 2.2 Features

The GDMA controller has the following features:

- AHB bus architecture
- Programmable length of data to be transferred in bytes
- Linked list of descriptors
- INCR burst transfer when accessing internal RAM
- Access to an address space of 384 KB at most in internal RAM

![Image](images/02_Chapter_2_img002_629c8a3c.png)

- Three transmit channels and three receive channels
- Software-configurable selection of peripheral requesting its service
- Fixed channel priority and round-robin channel arbitration

## 2.3 Architecture

In ESP32-C3, all modules that need high-speed data transfer support GDMA. The GDMA controller and CPU data bus have access to the same address space in internal RAM. Figure 2.3-1 shows the basic architecture of the GDMA engine.

Figure 2.3-1. GDMA Engine Architecture

![Image](images/02_Chapter_2_img003_580ef547.png)

The GDMA controller has six independent channels, i.e. three transmit channels and three receive channels. Every channel can be connected to different peripherals. In other words, channels are general-purpose, shared by peripherals.

The GDMA engine reads data from or writes data to internal RAM via the AHB\_BUS. Before this, the GDMA controller uses fixed-priority arbitration scheme for channels requesting read or write access. For available address range of Internal RAM, please see Chapter 3 System and Memory .

Software can use the GDMA engine through linked lists. These linked lists, stored in internal RAM, consist of outlinkn and inlinkn, where n indicates the channel number (ranging from 0 to 2). The GDMA controller reads an outlinkn (i.e. a linked list of transmit descriptors) from internal RAM and transmits data in corresponding RAM according to the outlinkn, or reads an inlinkn (i.e. a linked list of receive descriptors) and stores received data into specific address space in RAM according to the inlinkn .

## 2.4 Functional Description

## 2.4.1 Linked List

Figure 2.4-1. Structure of a Linked List

![Image](images/02_Chapter_2_img004_6d0cb069.png)

Figure 2.4-1 shows the structure of a linked list. An outlink and an inlink have the same structure. A linked list is formed by one or more descriptors, and each descriptor consists of three words. Linked lists should be in internal RAM for the GDMA engine to be able to use them. The meaning of each field is as follows:

- Owner (DW0) [31]: Specifies who is allowed to access the buffer that this descriptor points to. 1'b0: CPU can access the buffer;

1’b1: The GDMA controller can access the buffer.

When the GDMA controller stops using the buffer, this bit in a receive descriptor is automatically cleared by hardware, and this bit in a transmit descriptor is automatically cleared by hardware only if GDMA\_OUT\_AUTO\_WRBACK\_CHn is set to 1. Software can disable automatic clearing by hardware by setting GDMA\_OUT\_LOOP\_TEST\_CHn or GDMA\_IN\_LOOP\_TEST\_CHn bit. When software loads a linked list, this bit should be set to 1.

Note: GDMA\_OUT is the prefix of transmit channel registers, and GDMA\_IN is the prefix of receive channel registers.

- suc\_eof (DW0) [30]: Specifies whether the GDMA\_IN\_SUC\_EOF\_CHn\_INT or GDMA\_OUT\_EOF\_CHn\_INT interrupt will be triggered when the data corresponding to this descriptor has been received or transmitted.

1’b0: No interrupt will be triggered after the current descriptor’s successful transfer;

1’b1: An interrupt will be triggered after the current descriptor’s successful transfer.

For receive descriptors, software needs to clear this bit to 0, and hardware will set it to 1 after receiving data containing the EOF flag.

For transmit descriptors, software needs to set this bit to 1 as needed.

If software configures this bit to 1 in a descriptor, the GDMA will include the EOF flag in the data sent to the corresponding peripheral, indicating to the peripheral that this data segment marks the end of one transfer phase.

- Reserved (DW0) [29]: Reserved. Value of this bit does not matter.
- err\_eof (DW0) [28]: Specifies whether the received data has errors. This bit is used only when UHCI0 uses GDMA to receive data. When an error is detected in the received data segment corresponding to a descriptor, this bit in the receive descriptor is set to 1 by hardware.

![Image](images/02_Chapter_2_img005_4068a54f.png)

- Reserved (DW0) [27:24]: Reserved.
- Length (DW0) [23:12]: Specifies the number of valid bytes in the buffer that this descriptor points to. This field in a transmit descriptor is written by software and indicates how many bytes can be read from the buffer; this field in a receive descriptor is written by hardware automatically and indicates how many valid bytes have been stored into the buffer.
- Size (DW0) [11:0]: Specifies the size of the buffer that this descriptor points to.
- Buffer address pointer (DW1): Address of the buffer. This field can only point to internal RAM.
- Next descriptor address (DW2): Address of the next descriptor. If the current descriptor is the last one, this value is 0. This field can only point to internal RAM.

If the length of data received is smaller than the size of the buffer, the GDMA controller will not use the available space of the buffer in the next transaction.

## 2.4.2 Peripheral-to-Memory and Memory-to-Peripheral Data Transfer

The GDMA controller can transfer data from memory to peripheral (transmit) and from peripheral to memory (receive). A transmit channel transfers data in the specified memory location to a peripheral's transmitter via an outlinkn, whereas a receive channel transfers data received by a peripheral to the specified memory location via an inlinkn .

Every transmit and receive channel can be connected to any peripheral with GDMA feature. Table 2.4-1 illustrates how to select the peripheral to be connected via registers. When a channel is connected to a peripheral, the rest channels can not be connected to that peripheral.

Table 2.4-1. Selecting Peripherals via Register Configuration

| GDMA_PERI_IN_SEL_CHn GDMA_PERI_OUT_SEL_CHn   | Peripheral   |
|----------------------------------------------|--------------|
| 0                                            | SPI2         |
| 1                                            | Reserved     |
| 2                                            | UHCI0        |
| 3                                            | I2S          |
| 4                                            | Reserved     |
| 5                                            | Reserved     |
| 6                                            | AES          |
| 7                                            | SHA          |
| 8                                            | ADC          |
| 9 ~ 63                                       | Invalid      |

## 2.4.3 Memory-to-Memory Data Transfer

The GDMA controller also allows memory-to-memory data transfer. Such data transfer can be enabled by setting GDMA\_MEM\_TRANS\_EN\_CHn, which connects the output of transmit channel n to the input of receive channel n. Note that a transmit channel is only connected to the receive channel with the same number (n).

## 2.4.4 Enabling GDMA

Software uses the GDMA controller through linked lists. When the GDMA controller receives data, software loads an inlink, configures GDMA\_INLINK\_ADDR\_CHn field with address of the first receive descriptor, and sets GDMA\_INLINK\_START\_CHn bit to enable GDMA. When the GDMA controller transmits data, software loads an outlink, prepares data to be transmitted, configures GDMA\_OUTLINK\_ADDR\_CHn field with address of the first transmit descriptor, and sets GDMA\_OUTLINK\_START\_CHn bit to enable GDMA. GDMA\_INLINK\_START\_CHn bit and GDMA\_OUTLINK\_START\_CHn bit are cleared automatically by hardware.

In some cases, you may want to append more descriptors to a DMA transfer that is already started. Naively, it would seem to be possible to do this by clearing the EOF bit of the final descriptor in the existing list and setting its next descriptor address pointer field (DW2) to the first descriptor of the to-be-added list. However, this strategy fails if the existing DMA transfer is almost or entirely finished. Instead, the GDMA engine has specialized logic to make sure a DMA transfer can be continued or restarted: if it is still ongoing, it will make sure to take the appended descriptors into account; if the transfer has already finished, it will restart with the new descriptors. This is implemented in the Restart function.

When using the Restart function, software needs to rewrite address of the first descriptor in the new list to DW2 of the last descriptor in the loaded list, and set GDMA\_INLINK\_RESTART\_CHn bit or GDMA\_OUTLINK\_RESTART\_CHn bit (these two bits are cleared automatically by hardware). As shown in Figure 2.4-2, by doing so hardware can obtain the address of the first descriptor in the new list when reading the last descriptor in the loaded list, and then read the new list.

Figure 2.4-2. Relationship among Linked Lists

![Image](images/02_Chapter_2_img006_f2e3492b.png)

## 2.4.5 Linked List Reading Process

Once configured and enabled by software, the GDMA controller starts to read the linked list from internal RAM. The GDMA performs checks on descriptors in the linked list. Only if descriptors pass the checks, will the corresponding GDMA channel transfer data. If the descriptors fail any of the checks, hardware will trigger descriptor error interrupt (either GDMA\_IN\_DSCR\_ERR\_CHn\_INT or GDMA\_OUT\_DSCR\_ERR\_CHn\_INT), and the channel will halt.

The checks performed on descriptors are:

- Owner bit check when GDMA\_IN\_CHECK\_OWNER\_CHn or GDMA\_OUT\_CHECK\_OWNER\_CHn is set to 1.

![Image](images/02_Chapter_2_img007_40444f47.png)

If the owner bit is 0, the buffer is accessed by the CPU. In this case, the owner bit fails the check. The owner bit will not be checked if GDMA\_IN\_CHECK\_OWNER\_CHn or GDMA\_OUT\_CHECK\_OWNER\_CHn is 0;

- Buffer address pointer (DW1) check. If the buffer address pointer points to 0x3FC80000 ~ 0x3FCDFFFF (please refer to Section 2.4.7), it passes the check.

After software detects a descriptor error interrupt, it must reset the corresponding channel, and enable GDMA by setting GDMA\_OUTLINK\_START\_CHn or GDMA\_INLINK\_START\_CHn bit.

Note: The third word (DW2) in a descriptor can only point to a location in internal RAM, given that the third word points to the next descriptor to use and that all descriptors must be in internal memory.

## 2.4.6 EOF

The GDMA controller uses EOF (end of frame) flags to indicate the end of data segment transfer corresponding to a specific descriptor.

Before the GDMA controller transmits data, GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_ENA bit should be set to enable GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT interrupt. If data in the buffer pointed by the last descriptor (with EOF) has been transmitted, a GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT interrupt is generated.

Before the GDMA controller receives data, GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA bit should be set to enable GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt. If a data segment with an EOF flag has been received successfully, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt is generated. In addition, when GDMA channel is connected to UHCI0, the GDMA controller also supports GDMA\_IN\_ERR\_CHn\_EOF\_INT interrupt. This interrupt is enabled by setting GDMA\_IN\_ERR\_EOF\_CHn\_INT\_ENA bit, and it indicates that a data segment corresponding to a descriptor has been received with errors.

When detecting a GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT or a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt, software can record the value of GDMA\_OUT\_EOF\_DES\_ADDR\_CHn or GDMA\_IN\_SUC\_EOF\_DES\_ADDR\_CHn field, i.e. address of the last descriptor. Therefore, software can tell which descriptors have been used and reclaim them.

Note: In this chapter, EOF of transmit descriptors refers to suc\_eof, while EOF of receive descriptors refers to both suc\_eof and err\_eof.

## 2.4.7 Accessing Internal RAM

Any transmit and receive channels of GDMA can access 0x3FC80000 ~ 0x3FCDFFFF in internal RAM. To improve data transfer efficiency, GDMA can send data in burst mode, which is disabled by default. This mode is enabled for receive channels by setting GDMA\_IN\_DATA\_BURST\_EN\_CHn, and enabled for transmit channels by setting GDMA\_OUT\_DATA\_BURST\_EN\_CHn .

Table 2.4-2. Descriptor Field Alignment Requirements

| Inlink/Outlink   |   Burst Mode | Size         | Length   | Buffer Address Pointer   |
|------------------|--------------|--------------|----------|--------------------------|
| Inlink           |            0 | —            | —        | —                        |
| Inlink           |            1 | Word-aligned | —        | Word-aligned             |
| Outlink          |            0 | —            | —        | —                        |
| Outlink          |            1 | —            | —        | —                        |

Table 2.4-2 lists the requirements for descriptor field alignment when accessing internal RAM.

When burst mode is disabled, size, length, and buffer address pointer in both transmit and receive descriptors do not need to be word-aligned. That is to say, GDMA can read data of specified length (1 ~ 4095 bytes) from any start addresses in the accessible address range, or write received data of the specified length (1 ~ 4095 bytes) to any contiguous addresses in the accessible address range.

When burst mode is enabled, size, length, and buffer address pointer in transmit descriptors are also not necessarily word-aligned. However, size and buffer address pointer in receive descriptors except length should be word-aligned.

## 2.4.8 Arbitration

To ensure timely response to peripherals running at a high speed with low latency (such as SPI), the GDMA controller implements a fixed-priority channel arbitration scheme. That is to say, each channel can be assigned a priority from 0 ~ 9. The larger the number, the higher the priority, and the more timely the response. When several channels are assigned the same priority, the GDMA controller adopts a round-robin arbitration scheme.

Please note that the overall throughput of peripherals with GDMA feature cannot exceed the maximum bandwidth of the GDMA, so that requests from low-priority peripherals can be responded to.

## 2.5 GDMA Interrupts

- DMA\_INFIFO\_OVF\_CHn\_INT: Triggered when the RX FIFO of GDMA overflows.
- GDMA\_INFIFO\_UDF\_CHn\_INT: Triggered when the RX FIFO of GDMA underflows.
- GMA\_OUTFIFO\_OVF\_CHn\_INT: Triggered when the TX FIFO of GDMA overflows.
- GDMA\_OUTFIFO\_UDF\_CHn\_INT: Triggered when the TX FIFO of GDMA underflows.
- GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT: Triggered when all data corresponding to a linked list (including multiple descriptors) has been sent via transmit channel n .
- GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT: Triggered when the size of the buffer pointed by receive descriptors is smaller than the length of data to be received via receive channel n .
- GDMA\_OUT\_DSCR\_ERR\_CHn\_INT: Triggered when an error is detected in a transmit descriptor on transmit channel n .
- GDMA\_IN\_DSCR\_ERR\_CHn\_INT: Triggered when an error is detected in a receive descriptor on receive channel n .
- GDMA\_OUT\_EOF\_CHn\_INT: Triggered when EOF in a transmit descriptor is 1 and data corresponding to this descriptor has been sent via transmit channel n. If GDMA\_OUT\_EOF\_MODE\_CHn is 0, this interrupt will be triggered when the last byte of data corresponding to this descriptor enters GDMA's transmit channel; if GDMA\_OUT\_EOF\_MODE\_CHn is 1, this interrupt is triggered when the last byte of data is taken from GDMA's transmit channel.

- GDMA\_OUT\_DONE\_CHn\_INT: Triggered when all data corresponding to a transmit descriptor has been sent via transmit channel n .
- GDMA\_IN\_ERR\_EOF\_CHn\_INT: Triggered when an error is detected in the data segment corresponding to a descriptor received via receive channel n. This interrupt is used only for UHCI0 peripheral (UART0 or UART1).
- GDMA\_IN\_SUC\_EOF\_CHn\_INT: Triggered when the suc\_eof bit in a receive descriptor is 1 and the data corresponding to this receive descriptor has been received via receive channel n .
- GDMA\_IN\_DONE\_CHn\_INT: Triggered when all data corresponding to a receive descriptor has been received via receive channel n .

## 2.6 Programming Procedures

## 2.6.1 Programming Procedure for GDMA Clock and Reset

GDMA’s clock and reset should be configured as follows:

1. Set SYSTEM\_DMA\_CLK\_EN to enable GDMA’s clock;
2. Clear SYSTEM\_DMA\_RST to reset GDMA.

## 2.6.2 Programming Procedures for GDMA's Transmit Channel

To transmit data, GDMA’s transmit channel should be configured by software as follows:

1. Set GDMA\_OUT\_RST\_CHn first to 1 and then to 0, to reset the state machine of GDMA's transmit channel and FIFO pointer;
2. Load an outlink, and configure GDMA\_OUTLINK\_ADDR\_CHn with address of the first transmit descriptor;
3. Configure GDMA\_PERI\_OUT\_SEL\_CHn with the value corresponding to the peripheral to be connected, as shown in Table 2.4-1;
4. Set GDMA\_OUTLINK\_START\_CHn to enable GDMA’s transmit channel for data transfer;
5. Configure and enable the corresponding peripheral (SPI2, UHCI0 (UART0 or UART1), I2S, AES, SHA, and ADC). See details in individual chapters of these peripherals;
6. Wait for GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT interrupt, which indicates the completion of data transfer.

## 2.6.3 Programming Procedures for GDMA's Receive Channel

To receive data, GDMA’s receive channel should be configured by software as follows:

1. Set GDMA\_IN\_RST\_CHn first to 1 and then to 0, to reset the state machine of GDMA's receive channel and FIFO pointer;
2. Load an inlink, and configure GDMA\_INLINK\_ADDR\_CHn with address of the first receive descriptor;
3. Configure GDMA\_PERI\_IN\_SEL\_CHn with the value corresponding to the peripheral to be connected, as shown in Table 2.4-1;
4. Set GDMA\_INLINK\_START\_CHn to enable GDMA’s receive channel for data transfer;

![Image](images/02_Chapter_2_img008_ec52458d.png)

5. Configure and enable the corresponding peripheral (SPI2, UHCI0 (UART0 or UART1), I2S, AES, SHA, and ADC). See details in individual chapters of these peripherals;

## 2.6.4 Programming Procedures for Memory-to-Memory Transfer

To transfer data from one memory location to another, GDMA should be configured by software as follows:

1. Set GDMA\_OUT\_RST\_CHn first to 1 and then to 0, to reset the state machine of GDMA's transmit channel and FIFO pointer;
2. Set GDMA\_IN\_RST\_CHn first to 1 and then to 0, to reset the state machine of GDMA's receive channel and FIFO pointer;
3. Load an outlink, and configure GDMA\_OUTLINK\_ADDR\_CHn with address of the first transmit descriptor;
4. Load an inlink, and configure GDMA\_INLINK\_ADDR\_CHn with address of the first receive descriptor;
5. Set GDMA\_MEM\_TRANS\_EN\_CHn to enable memory-to-memory transfer;
6. Set GDMA\_OUTLINK\_START\_CHn to enable GDMA’s transmit channel for data transfer;
7. Set GDMA\_INLINK\_START\_CHn to enable GDMA’s receive channel for data transfer;
8. If the suc\_eof bit is set in a transmit descriptor, a GDMA\_IN\_SUC\_EOF\_CHn\_INT interrupt will be triggered when the data segment corresponding to this descriptor has been transmitted.

![Image](images/02_Chapter_2_img009_1bd70c6e.png)

## 2.7 Register Summary

The addresses in this section are relative to GDMA base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                    | Description                                                        | Address   | Access   |
|-------------------------|--------------------------------------------------------------------|-----------|----------|
| Interrupt Registers     |                                                                    |           |          |
| GDMA_INT_RAW_CH0_REG    | Raw status interrupt of RX channel 0                               | 0x0000    | R/WTC/SS |
| GDMA_INT_ST_CH0_REG     | Masked interrupt of RX channel 0                                   | 0x0004    | RO       |
| GDMA_INT_ENA_CH0_REG    | Interrupt enable bits of RX channel 0                              | 0x0008    | R/W      |
| GDMA_INT_CLR_CH0_REG    | Interrupt clear bits of RX channel 0                               | 0x000C    | WT       |
| GDMA_INT_RAW_CH1_REG    | Raw status interrupt of RX channel 1                               | 0x0010    | R/WTC/SS |
| GDMA_INT_ST_CH1_REG     | Masked interrupt of RX channel 1                                   | 0x0014    | RO       |
| GDMA_INT_ENA_CH1_REG    | Interrupt enable bits of RX channel 1                              | 0x0018    | R/W      |
| GDMA_INT_CLR_CH1_REG    | Interrupt clear bits of RX channel 1                               | 0x001C    | WT       |
| GDMA_INT_RAW_CH2_REG    | Raw status interrupt of RX channel 2                               | 0x0020    | R/WTC/SS |
| GDMA_INT_ST_CH2_REG     | Masked interrupt of RX channel 2                                   | 0x0024    | RO       |
| GDMA_INT_ENA_CH2_REG    | Interrupt enable bits of RX channel 2                              | 0x0028    | R/W      |
| GDMA_INT_CLR_CH2_REG    | Interrupt clear bits of RX channel 2                               | 0x002C    | WT       |
| Configuration Register  |                                                                    |           |          |
| GDMA_MISC_CONF_REG      | Miscellaneous register                                             | 0x0044    | R/W      |
| Version Registers       |                                                                    |           |          |
| GDMA_DATE_REG           | Version control register                                           | 0x0048    | R/W      |
| Configuration Registers |                                                                    |           |          |
| GDMA_IN_CONF0_CH0_REG   | Configuration register 0 of RX channel 0                           | 0x0070    | R/W      |
| GDMA_IN_CONF1_CH0_REG   | Configuration register 1 of RX channel 0                           | 0x0074    | R/W      |
| GDMA_IN_POP_CH0_REG     | Pop control register of RX channel 0                               | 0x007C    | varies   |
| GDMA_IN_LINK_CH0_REG    | Link descriptor configuration and control register of RX channel 0 | 0x0080    | varies   |
| GDMA_OUT_CONF0_CH0_REG  | Configuration register 0 of TX channel 0                           | 0x00D0    | R/W      |
| GDMA_OUT_CONF1_CH0_REG  | Configuration register 1 of TX channel 0                           | 0x00D4    | R/W      |
| GDMA_OUT_PUSH_CH0_REG   | Push control register of TX channel 0                              | 0x00DC    | varies   |
| GDMA_OUT_LINK_CH0_REG   | Link descriptor configuration and control register of TX channel 0 | 0x00E0    | varies   |
| GDMA_IN_CONF0_CH1_REG   | Configuration register 0 of RX channel 1                           | 0x0130    | R/W      |
| GDMA_IN_CONF1_CH1_REG   | Configuration register 1 of RX channel 1                           | 0x0134    | R/W      |
| GDMA_IN_POP_CH1_REG     | Pop control register of RX channel 1                               | 0x013C    | varies   |
| GDMA_IN_LINK_CH1_REG    | Link descriptor configuration and control register of RX channel 1 | 0x0140    | varies   |
| GDMA_OUT_CONF0_CH1_REG  | Configuration register 0 of TX channel 1                           | 0x0190    | R/W      |
| GDMA_OUT_CONF1_CH1_REG  | Configuration register 1 of TX channel 1                           | 0x0194    | R/W      |
| GDMA_OUT_PUSH_CH1_REG   | Push control register of TX channel 1                              | 0x019C    | varies   |

![Image](images/02_Chapter_2_img010_ed84a40e.png)

| Name                               | Description                                                                                                 | Address   | Access   |
|------------------------------------|-------------------------------------------------------------------------------------------------------------|-----------|----------|
| GDMA_OUT_LINK_CH1_REG              | Link descriptor configuration and control register of TX channel 1                                          | 0x01A0    | varies   |
| GDMA_IN_CONF0_CH2_REG              | Configuration register 0 of RX channel 2                                                                    | 0x01F0    | R/W      |
| GDMA_IN_CONF1_CH2_REG              | Configuration register 1 of RX channel 2                                                                    | 0x01F4    | R/W      |
| GDMA_IN_POP_CH2_REG                | Pop control register of RX channel 2                                                                        | 0x01FC    | varies   |
| GDMA_IN_LINK_CH2_REG               | Link descriptor configuration and control register of RX channel 2                                          | 0x0200    | varies   |
| GDMA_OUT_CONF0_CH2_REG             | Configuration register 0 of TX channel 2                                                                    | 0x0250    | R/W      |
| GDMA_OUT_CONF1_CH2_REG             | Configuration register 1 of TX channel 2                                                                    | 0x0254    | R/W      |
| GDMA_OUT_PUSH_CH2_REG              | Push control register of TX channel 2                                                                       | 0x025C    | varies   |
| GDMA_OUT_LINK_CH2_REG              | Link descriptor configuration and control register of TX channel 2                                          | 0x0260    | varies   |
| Status Registers                   |                                                                                                             |           |          |
| GDMA_INFIFO_STATUS_CH0_REG         | RX FIFO status of RX channel 0                                                                              | 0x0078    | RO       |
| GDMA_IN_STATE_CH0_REG              | Receive status of RX channel 0                                                                              | 0x0084    | RO       |
| GDMA_IN_SUC_EOF_DES_ADDR_CH0 _REG  | Inlink descriptor address when EOF occurs of RX channel 0                                                   | 0x0088    | RO       |
| GDMA_IN_ERR_EOF_DES_ADDR_CH0 _REG  | Inlink descriptor address when errors occur of RX channel 0                                                 | 0x008C    | RO       |
| GDMA_IN_DSCR_CH0_REG               | Address of the next receive descriptor pointed by the current pre-read receive descriptor on RX channel 0   | 0x0090    | RO       |
| GDMA_IN_DSCR_BF0_CH0_REG           | Address of the current pre-read receive descriptor on RX channel 0                                          | 0x0094    | RO       |
| GDMA_IN_DSCR_BF1_CH0_REG           | Address of the previous pre-read receive descriptor on RX channel 0                                         | 0x0098    | RO       |
| GDMA_OUTFIFO_STATUS_CH0_REG        | TX FIFO status of TX channel 0                                                                              | 0x00D8    | RO       |
| GDMA_OUT_STATE_CH0_REG             | Transmit status of TX channel 0                                                                             | 0x00E4    | RO       |
| GDMA_OUT_EOF_DES_ADDR_CH0_REG      | Outlink descriptor address when EOF occurs of TX channel 0                                                  | 0x00E8    | RO       |
| GDMA_OUT_EOF_BFR_DES_ADDR_CH0 _REG | The last outlink descriptor address when EOF occurs of TX channel 0                                         | 0x00EC    | RO       |
| GDMA_OUT_DSCR_CH0_REG              | Address of the next transmit descriptor pointed by the current pre-read transmit descriptor on TX channel 0 | 0x00F0    | RO       |
| GDMA_OUT_DSCR_BF0_CH0_REG          | Address of the current pre-read transmit descriptor on TX channel 0                                         | 0x00F4    | RO       |
| GDMA_OUT_DSCR_BF1_CH0_REG          | Address of the previous pre-read transmit descriptor on TX channel 0                                        | 0x00F8    | RO       |
| GDMA_INFIFO_STATUS_CH1_REG         | RX FIFO status of RX channel 1                                                                              | 0x0138    | RO       |
| GDMA_IN_STATE_CH1_REG              | Receive status of RX channel 1                                                                              | 0x0144    | RO       |
| GDMA_IN_SUC_EOF_DES_ADDR_CH1 _REG  | Inlink descriptor address when EOF occurs of RX channel 1                                                   | 0x0148    | RO       |

| Name                               | Description                                                                                                 | Address   | Access   |
|------------------------------------|-------------------------------------------------------------------------------------------------------------|-----------|----------|
| GDMA_IN_ERR_EOF_DES_ADDR_CH1 _REG  | Inlink descriptor address when errors occur of RX channel 1                                                 | 0x014C    | RO       |
| GDMA_IN_DSCR_CH1_REG               | Address of the next receive descriptor pointed by the current pre-read receive descriptor on RX channel 1   | 0x0150    | RO       |
| GDMA_IN_DSCR_BF0_CH1_REG           | Address of the current pre-read receive descriptor on RX channel 1                                          | 0x0154    | RO       |
| GDMA_IN_DSCR_BF1_CH1_REG           | Address of the previous pre-read receive descriptor on RX channel 1                                         | 0x0158    | RO       |
| GDMA_OUTFIFO_STATUS_CH1_REG        | TX FIFO status of TX channel 1                                                                              | 0x0198    | RO       |
| GDMA_OUT_STATE_CH1_REG             | Transmit status of TX channel 1                                                                             | 0x01A4    | RO       |
| GDMA_OUT_EOF_DES_ADDR_CH1_REG      | Outlink descriptor address when EOF occurs of TX channel 1                                                  | 0x01A8    | RO       |
| GDMA_OUT_EOF_BFR_DES_ADDR_CH1 _REG | The last outlink descriptor address when EOF occurs of TX channel 1                                         | 0x01AC    | RO       |
| GDMA_OUT_DSCR_CH1_REG              | Address of the next transmit descriptor pointed by the current pre-read transmit descriptor on TX channel 1 | 0x01B0    | RO       |
| GDMA_OUT_DSCR_BF0_CH1_REG          | Address of the current pre-read transmit descriptor on TX channel 1                                         | 0x01B4    | RO       |
| GDMA_OUT_DSCR_BF1_CH1_REG          | Address of the previous pre-read transmit descriptor on TX channel 1                                        | 0x01B8    | RO       |
| GDMA_INFIFO_STATUS_CH2_REG         | RX FIFO status of RX channel 2                                                                              | 0x01F8    | RO       |
| GDMA_IN_STATE_CH2_REG              | Receive status of RX channel 2                                                                              | 0x0204    | RO       |
| GDMA_IN_SUC_EOF_DES_ADDR_CH2 _REG  | Inlink descriptor address when EOF occurs of RX channel 2                                                   | 0x0208    | RO       |
| GDMA_IN_ERR_EOF_DES_ADDR_CH2 _REG  | Inlink descriptor address when errors occur of RX channel 2                                                 | 0x020C    | RO       |
| GDMA_IN_DSCR_CH2_REG               | Address of the next receive descriptor pointed by the current pre-read receive descriptor on RX channel 2   | 0x0210    | RO       |
| GDMA_IN_DSCR_BF0_CH2_REG           | Address of the current pre-read receive descriptor on RX channel 2                                          | 0x0214    | RO       |
| GDMA_IN_DSCR_BF1_CH2_REG           | Address of the previous pre-read receive descriptor on RX channel 2                                         | 0x0218    | RO       |
| GDMA_OUTFIFO_STATUS_CH2_REG        | TX FIFO status of TX channel 2                                                                              | 0x0258    | RO       |
| GDMA_OUT_STATE_CH2_REG             | Transmit status of TX channel 2                                                                             | 0x0264    | RO       |
| GDMA_OUT_EOF_DES_ADDR_CH2_REG      | Outlink descriptor address when EOF occurs of TX channel 2                                                  | 0x0268    | RO       |
| GDMA_OUT_EOF_BFR_DES_ADDR_CH2 _REG | The last outlink descriptor address when EOF occurs of TX channel 2                                         | 0x026C    | RO       |
| GDMA_OUT_DSCR_CH2_REG              | Address of the next transmit descriptor pointed by the current pre-read transmit descriptor on TX channel 2 | 0x0270    | RO       |

| Name                        | Description                                                          | Address   | Access   |
|-----------------------------|----------------------------------------------------------------------|-----------|----------|
| GDMA_OUT_DSCR_BF0_CH2_REG   | Address of the current pre-read transmit descriptor on TX channel 2  | 0x0274    | RO       |
| GDMA_OUT_DSCR_BF1_CH2_REG   | Address of the previous pre-read transmit descriptor on TX channel 2 | 0x0278    | RO       |
| Priority Registers          |                                                                      |           |          |
| GDMA_IN_PRI_CH0_REG         | Priority register of RX channel 0                                    | 0x009C    | R/W      |
| GDMA_OUT_PRI_CH0_REG        | Priority register of TX channel 0                                    | 0x00FC    | R/W      |
| GDMA_IN_PRI_CH1_REG         | Priority register of RX channel 1                                    | 0x015C    | R/W      |
| GDMA_OUT_PRI_CH1_REG        | Priority register of TX channel 1                                    | 0x01BC    | R/W      |
| GDMA_IN_PRI_CH2_REG         | Priority register of RX channel 2                                    | 0x021C    | R/W      |
| GDMA_OUT_PRI_CH2_REG        | Priority register of TX channel 2                                    | 0x027C    | R/W      |
| Peripheral Select Registers |                                                                      |           |          |
| GDMA_IN_PERI_SEL_CH0_REG    | Peripheral selection of RX channel 0                                 | 0x00A0    | R/W      |
| GDMA_OUT_PERI_SEL_CH0_REG   | Peripheral selection of TX channel 0                                 | 0x0100    | R/W      |
| GDMA_IN_PERI_SEL_CH1_REG    | Peripheral selection of RX channel 1                                 | 0x0160    | R/W      |
| GDMA_OUT_PERI_SEL_CH1_REG   | Peripheral selection of TX channel 1                                 | 0x01C0    | R/W      |
| GDMA_IN_PERI_SEL_CH2_REG    | Peripheral selection of RX channel 2                                 | 0x0220    | R/W      |
| GDMA_OUT_PERI_SEL_CH2_REG   | Peripheral selection of TX channel 2                                 | 0x0280    | R/W      |

![Image](images/02_Chapter_2_img011_adbf5507.png)

## 2.8 Registers

The addresses in this section are relative to GDMA base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 2.1. GDMA\_INT\_RAW\_CHn\_REG (n: 0-2) (0x0000+16*n)

![Image](images/02_Chapter_2_img012_9e04511e.png)

GDMA\_IN\_DONE\_CHn\_INT\_RAW The raw interrupt bit turns to high level when the last data pointed by one receive descriptor has been received for RX channel 0. (R/WTC/SS)

GDMA\_IN\_SUC\_EOF\_CHn\_INT\_RAW The raw interrupt bit turns to high level for RX channel 0 when the last data pointed by one receive descriptor has been received and the suc\_eof bit in this descriptor is 1. For UHCI0, the raw interrupt bit turns to high level when the last data pointed by one receive descriptor has been received and no data error is detected for RX channel 0. (R/WTC/SS)

- GDMA\_IN\_ERR\_EOF\_CHn\_INT\_RAW The raw interrupt bit turns to high level when data error is detected only in the case that the peripheral is UHCI0 for RX channel 0. For other peripherals, this raw interrupt is reserved. (R/WTC/SS)
- GDMA\_OUT\_DONE\_CHn\_INT\_RAW The raw interrupt bit turns to high level when the last data pointed by one transmit descriptor has been transmitted to peripherals for TX channel 0. (R/WTC/SS)
- GDMA\_OUT\_EOF\_CHn\_INT\_RAW The raw interrupt bit turns to high level when the last data pointed by one transmit descriptor has been read from memory for TX channel 0. (R/WTC/SS)
- GDMA\_IN\_DSCR\_ERR\_CHn\_INT\_RAW The raw interrupt bit turns to high level when detecting receive descriptor error, including owner error, the second and third word error of receive descriptor for RX channel 0. (R/WTC/SS)

GDMA\_OUT\_DSCR\_ERR\_CHn\_INT\_RAW The raw interrupt bit turns to high level when detecting transmit descriptor error, including owner error, the second and third word error of transmit descriptor for TX channel 0. (R/WTC/SS)

Continued on the next page...

Register 2.1. GDMA\_INT\_RAW\_CHn\_REG (n: 0-2) (0x0000+16*n)

Continued from the previous page...

- GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT\_RAW The raw interrupt bit turns to high level when RX buffer pointed by inlink is full and receiving data is not completed, but there is no more inlink for RX channel 0. (R/WTC/SS)
- GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_RAW The raw interrupt bit turns to high level when data corresponding a outlink (includes one descriptor or few descriptors) is transmitted out for TX channel 0. (R/WTC/SS)
- GDMA\_INFIFO\_OVF\_CHn\_INT\_RAW This raw interrupt bit turns to high level when level 1 FIFO of RX channel 0 is overflow. (R/WTC/SS)
- GDMA\_INFIFO\_UDF\_CHn\_INT\_RAW This raw interrupt bit turns to high level when level 1 FIFO of RX channel 0 is underflow. (R/WTC/SS)
- GDMA\_OUTFIFO\_OVF\_CHn\_INT\_RAW This raw interrupt bit turns to high level when level 1 FIFO of TX channel 0 is overflow. (R/WTC/SS)
- GDMA\_OUTFIFO\_UDF\_CHn\_INT\_RAW This raw interrupt bit turns to high level when level 1 FIFO of TX channel 0 is underflow. (R/WTC/SS)

ESP32-C3 TRM (Version 1.3)

Register 2.2. GDMA\_INT\_ST\_CHn\_REG (n: 0-2) (0x0004+16*n)

![Image](images/02_Chapter_2_img013_ed0c6660.png)

GDMA\_IN\_DONE\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_IN\_DONE\_CH\_INT interrupt. (RO) GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_IN\_SUC\_EOF\_CH\_INT interrupt. (RO) GDMA\_IN\_ERR\_EOF\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_IN\_ERR\_EOF\_CH\_INT interrupt. (RO) GDMA\_OUT\_DONE\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_OUT\_DONE\_CH\_INT interrupt. (RO) GDMA\_OUT\_EOF\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_OUT\_EOF\_CH\_INT interrupt. (RO) GDMA\_IN\_DSCR\_ERR\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_IN\_DSCR\_ERR\_CH\_INT interrupt. (RO) GDMA\_OUT\_DSCR\_ERR\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_OUT\_DSCR\_ERR\_CH\_INT interrupt. (RO) GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_IN\_DSCR\_EMPTY\_CH\_INT interrupt. (RO) GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_OUT\_TOTAL\_EOF\_CH\_INT interrupt. (RO) GDMA\_INFIFO\_OVF\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_INFIFO\_OVF\_L1\_CH\_INT interrupt. (RO) GDMA\_INFIFO\_UDF\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_INFIFO\_UDF\_L1\_CH\_INT interrupt. (RO) GDMA\_OUTFIFO\_OVF\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_OUTFIFO\_OVF\_L1\_CH\_INT interrupt. (RO) GDMA\_OUTFIFO\_UDF\_CHn\_INT\_ST The raw interrupt status bit for the GDMA\_OUTFIFO\_UDF\_L1\_CH\_INT interrupt. (RO)

Register 2.3. GDMA\_INT\_ENA\_CHn\_REG (n: 0-2) (0x0008+16*n)

![Image](images/02_Chapter_2_img014_897e5665.png)

GDMA\_IN\_DONE\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_IN\_DONE\_CH\_INT interrupt. (R/W) GDMA\_IN\_SUC\_EOF\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_IN\_SUC\_EOF\_CH\_INT interrupt. (R/W) GDMA\_IN\_ERR\_EOF\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_IN\_ERR\_EOF\_CH\_INT interrupt. (R/W) GDMA\_OUT\_DONE\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_OUT\_DONE\_CH\_INT interrupt. (R/W) GDMA\_OUT\_EOF\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_OUT\_EOF\_CH\_INT interrupt. (R/W) GDMA\_IN\_DSCR\_ERR\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_IN\_DSCR\_ERR\_CH\_INT interrupt. (R/W) GDMA\_OUT\_DSCR\_ERR\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_OUT\_DSCR\_ERR\_CH\_INT interrupt. (R/W) GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_IN\_DSCR\_EMPTY\_CH\_INT interrupt. (R/W) GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_OUT\_TOTAL\_EOF\_CH\_INT interrupt. (R/W) GDMA\_INFIFO\_OVF\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_INFIFO\_OVF\_L1\_CH\_INT interrupt. (R/W) GDMA\_INFIFO\_UDF\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_INFIFO\_UDF\_L1\_CH\_INT interrupt. (R/W) GDMA\_OUTFIFO\_OVF\_CHn\_INT\_ENA The interrupt enable bit for the GDMA\_OUTFIFO\_OVF\_L1\_CH\_INT interrupt. (R/W) GDMA\_OUTFIFO\_UDF\_CHn\_INT\_ENA The interrupt enable bit for the

- GDMA\_OUTFIFO\_UDF\_L1\_CH\_INT interrupt. (R/W)

Register 2.4. GDMA\_INT\_CLR\_CHn\_REG (n: 0-2) (0x000C+16*n)

![Image](images/02_Chapter_2_img015_0d38fcc6.png)

- GDMA\_IN\_DONE\_CHn\_INT\_CLR Set this bit to clear the GDMA\_IN\_DONE\_CH\_INT interrupt. (WT)
- GDMA\_IN\_SUC\_EOF\_CHn\_INT\_CLR Set this bit to clear the GDMA\_IN\_SUC\_EOF\_CH\_INT interrupt. (WT)
- GDMA\_IN\_ERR\_EOF\_CHn\_INT\_CLR Set this bit to clear the GDMA\_IN\_ERR\_EOF\_CH\_INT interrupt. (WT)
- GDMA\_OUT\_DONE\_CHn\_INT\_CLR Set this bit to clear the GDMA\_OUT\_DONE\_CH\_INT interrupt. (WT)
- GDMA\_OUT\_EOF\_CHn\_INT\_CLR Set this bit to clear the GDMA\_OUT\_EOF\_CH\_INT interrupt. (WT)
- GDMA\_IN\_DSCR\_ERR\_CHn\_INT\_CLR Set this bit to clear the GDMA\_IN\_DSCR\_ERR\_CH\_INT interrupt. (WT)
- GDMA\_OUT\_DSCR\_ERR\_CHn\_INT\_CLR Set this bit to clear the GDMA\_OUT\_DSCR\_ERR\_CH\_INT interrupt. (WT)
- GDMA\_IN\_DSCR\_EMPTY\_CHn\_INT\_CLR Set this bit to clear the GDMA\_IN\_DSCR\_EMPTY\_CH\_INT

interrupt. (WT)

- GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT\_CLR Set this bit to clear the GDMA\_OUT\_TOTAL\_EOF\_CH\_INT interrupt. (WT)
- GDMA\_INFIFO\_OVF\_CHn\_INT\_CLR Set this bit to clear the GDMA\_INFIFO\_OVF\_L1\_CH\_INT interrupt. (WT)
- GDMA\_INFIFO\_UDF\_CHn\_INT\_CLR Set this bit to clear the GDMA\_INFIFO\_UDF\_L1\_CH\_INT interrupt. (WT)
- GDMA\_OUTFIFO\_OVF\_CHn\_INT\_CLR Set this bit to clear the GDMA\_OUTFIFO\_OVF\_L1\_CH\_INT interrupt. (WT)
- GDMA\_OUTFIFO\_UDF\_CHn\_INT\_CLR Set this bit to clear the GDMA\_OUTFIFO\_UDF\_L1\_CH\_INT interrupt. (WT)

Register 2.5. GDMA\_MISC\_CONF\_REG (0x0044)

![Image](images/02_Chapter_2_img016_828fade0.png)

GDMA\_AHBM\_RST\_INTER Set this bit, then clear this bit to reset the internal ahb FSM. (R/W)

GDMA\_ARB\_PRI\_DIS Set this bit to disable priority arbitration function. (R/W)

GDMA\_CLK\_EN 0: Enable the clock only when application writes registers. 1: Force the clock on for registers. (R/W)

Register 2.6. GDMA\_DATE\_REG (0x0048)

![Image](images/02_Chapter_2_img017_376b17d4.png)

![Image](images/02_Chapter_2_img018_27724224.png)

GDMA\_DATE This is the version control register. (R/W)

Register 2.7. GDMA\_IN\_CONF0\_CHn\_REG (n: 0-2) (0x0070+192*n)

![Image](images/02_Chapter_2_img019_8af389b0.png)

GDMA\_IN\_RST\_CHn This bit is used to reset GDMA channel 0 RX FSM and RX FIFO pointer. (R/W)

GDMA\_IN\_LOOP\_TEST\_CHn This bit is used to fill the owner bit of receive descriptor by hardware of receive descriptor. (R/W)

GDMA\_INDSCR\_BURST\_EN\_CHn Set this bit to 1 to enable INCR burst transfer for RX channel 0 reading descriptor when accessing internal RAM. (R/W)

GDMA\_IN\_DATA\_BURST\_EN\_CHn Set this bit to 1 to enable INCR burst transfer for RX channel 0 receiving data when accessing internal RAM. (R/W)

GDMA\_MEM\_TRANS\_EN\_CHn Set this bit 1 to enable automatic transmitting data from memory to memory via GDMA. (R/W)

Register 2.8. GDMA\_IN\_CONF1\_CHn\_REG (n: 0-2) (0x0074+192*n)

![Image](images/02_Chapter_2_img020_eb177f9e.png)

GDMA\_IN\_CHECK\_OWNER\_CHn Set this bit to enable checking the owner attribute of the descriptor. (R/W)

Register 2.9. GDMA\_IN\_POP\_CHn\_REG (n: 0-2) (0x007C+192*n)

![Image](images/02_Chapter_2_img021_851e4677.png)

GDMA\_INFIFO\_RDATA\_CHn This register stores the data popping from GDMA FIFO (intended for debugging). (RO)

GDMA\_INFIFO\_POP\_CHn Set this bit to pop data from GDMA FIFO (intended for debugging). (R/W/SC)

Register 2.10. GDMA\_IN\_LINK\_CHn\_REG (n: 0-2) (0x0080+192*n)

![Image](images/02_Chapter_2_img022_4e4e0b66.png)

- GDMA\_INLINK\_ADDR\_CHn This register stores the 20 least significant bits of the first receive descriptor's address. (R/W)
- GDMA\_INLINK\_AUTO\_RET\_CHn Set this bit to return to current receive descriptor's address, when there are some errors in current receiving data. (R/W)

GDMA\_INLINK\_STOP\_CHn Set this bit to stop GDMA's receive channel from receiving data. (R/W/SC)

- GDMA\_INLINK\_START\_CHn Set this bit to enable GDMA's receive channel from receiving data. (R/W/SC)
- GDMA\_INLINK\_RESTART\_CHn Set this bit to mount a new receive descriptor. (R/W/SC)
- GDMA\_INLINK\_PARK\_CHn 1: the receive descriptor's FSM is in idle state; 0: the receive descriptor's FSM is working. (RO)

![Image](images/02_Chapter_2_img023_c64f9faf.png)

Register 2.11. GDMA\_OUT\_CONF0\_CHn\_REG (n: 0-2) (0x00D0+192*n)

![Image](images/02_Chapter_2_img024_6587b12a.png)

GDMA\_OUT\_RST\_CHn This bit is used to reset GDMA channel 0 TX FSM and TX FIFO pointer. (R/W)

GDMA\_OUT\_LOOP\_TEST\_CHn Reserved. (R/W)

GDMA\_OUT\_AUTO\_WRBACK\_CHn Set this bit to enable automatic outlink-writeback when all the data in TX buffer has been transmitted. (R/W)

GDMA\_OUT\_EOF\_MODE\_CHn EOF flag generation mode when transmitting data. 1: EOF flag for TX channel 0 is generated when data need to transmit has been popped from FIFO in GDMA. (R/W)

GDMA\_OUTDSCR\_BURST\_EN\_CHn Set this bit to 1 to enable INCR burst transfer for TX channel 0 reading descriptor when accessing internal RAM. (R/W)

GDMA\_OUT\_DATA\_BURST\_EN\_CHn Set this bit to 1 to enable INCR burst transfer for TX channel 0 transmitting data when accessing internal RAM. (R/W)

Register 2.12. GDMA\_OUT\_CONF1\_CHn\_REG (n: 0-2) (0x00D4+192*n)

![Image](images/02_Chapter_2_img025_9e20d54d.png)

GDMA\_OUT\_CHECK\_OWNER\_CHn Set this bit to enable checking the owner attribute of the descriptor. (R/W)

Register 2.13. GDMA\_OUT\_PUSH\_CHn\_REG (n: 0-2) (0x00DC+192*n)

![Image](images/02_Chapter_2_img026_5e74fc18.png)

GDMA\_OUTFIFO\_WDATA\_CHn This register stores the data that need to be pushed into GDMA FIFO. (R/W)

GDMA\_OUTFIFO\_PUSH\_CHn Set this bit to push data into GDMA FIFO. (R/W/SC)

Register 2.14. GDMA\_OUT\_LINK\_CHn\_REG (n: 0-2) (0x00E0+192*n)

![Image](images/02_Chapter_2_img027_5fb57833.png)

GDMA\_OUTLINK\_ADDR\_CHn This register stores the 20 least significant bits of the first transmit descriptor's address. (R/W)

GDMA\_OUTLINK\_STOP\_CHn Set this bit to stop GDMA's transmit channel from transferring data. (R/W/SC)

GDMA\_OUTLINK\_START\_CHn Set this bit to enable GDMA's transmit channel for data transfer. (R/W/SC)

GDMA\_OUTLINK\_RESTART\_CHn Set this bit to restart a new outlink from the last address. (R/W/SC)

GDMA\_OUTLINK\_PARK\_CHn 1: the transmit descriptor's FSM is in idle state; 0: the transmit descriptor's FSM is working. (RO)

Register 2.15. GDMA\_INFIFO\_STATUS\_CHn\_REG (n: 0-2) (0x0078+192*n)

![Image](images/02_Chapter_2_img028_dbbdc005.png)

GDMA\_INFIFO\_FULL\_CHn L1 RX FIFO full signal for RX channel 0. (RO)

GDMA\_INFIFO\_EMPTY\_CHn L1 RX FIFO empty signal for RX channel 0. (RO)

GDMA\_INFIFO\_CNT\_CHn The register stores the byte number of the data in L1 RX FIFO for RX channel 0. (RO)

GDMA\_IN\_REMAIN\_UNDER\_1B\_CHn Reserved. (RO)

GDMA\_IN\_REMAIN\_UNDER\_2B\_CHn Reserved. (RO)

GDMA\_IN\_REMAIN\_UNDER\_3B\_CHn Reserved. (RO)

GDMA\_IN\_REMAIN\_UNDER\_4B\_CHn Reserved. (RO)

GDMA\_IN\_BUF\_HUNGRY\_CHn Reserved. (RO)

Register 2.16. GDMA\_IN\_STATE\_CHn\_REG (n: 0-2) (0x0084+192*n)

![Image](images/02_Chapter_2_img029_2e4a78c1.png)

GDMA\_INLINK\_DSCR\_ADDR\_CHn This register stores the lower 18 bits of the next receive descriptor address that is pre-read (but not processed yet). If the current receive descriptor is the last descriptor, then this field represents the address of the current receive descriptor. (RO)

GDMA\_IN\_DSCR\_STATE\_CHn Reserved. (RO)

GDMA\_IN\_STATE\_CHn Reserved. (RO)

Register 2.17. GDMA\_IN\_SUC\_EOF\_DES\_ADDR\_CHn\_REG (n: 0-2) (0x0088+192*n)

![Image](images/02_Chapter_2_img030_3446fc84.png)

GDMA\_IN\_SUC\_EOF\_DES\_ADDR\_CHn This register stores the address of the receive descriptor when the EOF bit in this descriptor is 1. (RO)

![Image](images/02_Chapter_2_img031_120e14fa.png)

GDMA\_IN\_ERR\_EOF\_DES\_ADDR\_CHn This register stores the address of the receive descriptor when there are some errors in current receiving data. Only used when peripheral is UHCI0. (RO)

![Image](images/02_Chapter_2_img032_0a62f379.png)

GDMA\_INLINK\_DSCR\_CHn Represents the address of the next receive descriptor x+1 pointed by the current receive descriptor that is pre-read. (RO)

![Image](images/02_Chapter_2_img033_b2654ada.png)

GDMA\_INLINK\_DSCR\_BF0\_CHn Represents the address of the current receive descriptor x that is pre-read. (RO)

Register 2.21. GDMA\_IN\_DSCR\_BF1\_CHn\_REG (n: 0-2) (0x0098+192*n)

![Image](images/02_Chapter_2_img034_0ccd9af7.png)

GDMA\_INLINK\_DSCR\_BF1\_CHn Represents the address of the previous receive descriptor x-1 that is pre-read. (RO)

Register 2.22. GDMA\_OUTFIFO\_STATUS\_CHn\_REG (n: 0-2) (0x00D8+192*n)

![Image](images/02_Chapter_2_img035_c4dea1e0.png)

GDMA\_OUTFIFO\_FULL\_CHn L1 TX FIFO full signal for TX channel 0. (RO)

GDMA\_OUTFIFO\_EMPTY\_CHn L1 TX FIFO empty signal for TX channel 0. (RO)

GDMA\_OUTFIFO\_CNT\_CHn The register stores the byte number of the data in L1 TX FIFO for TX channel 0. (RO)

GDMA\_OUT\_REMAIN\_UNDER\_1B\_CHn Reserved. (RO)

GDMA\_OUT\_REMAIN\_UNDER\_2B\_CHn Reserved. (RO)

GDMA\_OUT\_REMAIN\_UNDER\_3B\_CHn Reserved. (RO)

GDMA\_OUT\_REMAIN\_UNDER\_4B\_CHn Reserved. (RO)

Register 2.23. GDMA\_OUT\_STATE\_CHn\_REG (n: 0-2) (0x00E4+192*n)

![Image](images/02_Chapter_2_img036_10e2cdbc.png)

GDMA\_OUTLINK\_DSCR\_ADDR\_CHn This register stores the lower 18 bits of the next receive descriptor address that is pre-read (but not processed yet). If the current receive descriptor is the last descriptor, then this field represents the address of the current receive descriptor. (RO)

GDMA\_OUT\_DSCR\_STATE\_CHn Reserved. (RO)

GDMA\_OUT\_STATE\_CHn Reserved. (RO)

Register 2.24. GDMA\_OUT\_EOF\_DES\_ADDR\_CHn\_REG (n: 0-2) (0x00E8+192*n)

![Image](images/02_Chapter_2_img037_d1ac9aa7.png)

GDMA\_OUT\_EOF\_DES\_ADDR\_CHn This register stores the address of the transmit descriptor when the EOF bit in this descriptor is 1. (RO)

![Image](images/02_Chapter_2_img038_a8bd8b42.png)

GDMA\_OUT\_EOF\_BFR\_DES\_ADDR\_CHn This register stores the address of the transmit descriptor before the last transmit descriptor. (RO)

Register 2.26. GDMA\_OUT\_DSCR\_CHn\_REG (n: 0-2) (0x00F0+192*n)

![Image](images/02_Chapter_2_img039_6c00c32b.png)

GDMA\_OUTLINK\_DSCR\_CHn Represents the address of the next transmit descriptor y+1 pointed by the current transmit descriptor that is pre-read. (RO)

Register 2.27. GDMA\_OUT\_DSCR\_BF0\_CHn\_REG (n: 0-2) (0x00F4+192*n)

![Image](images/02_Chapter_2_img040_339cf65a.png)

GDMA\_OUTLINK\_DSCR\_BF0\_CHn Represents the address of the current transmit descriptor y that is pre-read. (RO)

Register 2.28. GDMA\_OUT\_DSCR\_BF1\_CHn\_REG (n: 0-2) (0x00F8+192*n)

![Image](images/02_Chapter_2_img041_1f94cfaa.png)

GDMA\_OUTLINK\_DSCR\_BF1\_CHn Represents the address of the previous transmit descriptor y-1 that is pre-read. (RO)

Register 2.29. GDMA\_IN\_PRI\_CHn\_REG (n: 0-2) (0x009C+192*n)

![Image](images/02_Chapter_2_img042_1b48f801.png)

GDMA\_RX\_PRI\_CHn The priority of RX channel 0. The larger the value, the higher the priority. (R/W)

Register 2.30. GDMA\_OUT\_PRI\_CHn\_REG (n: 0-2) (0x00FC+192*n)

![Image](images/02_Chapter_2_img043_8b17e11a.png)

GDMA\_TX\_PRI\_CHn The priority of TX channel 0. The larger the value, the higher the priority. (R/W)

Register 2.31. GDMA\_IN\_PERI\_SEL\_CHn\_REG (n: 0-2) (0x00A0+192*n)

![Image](images/02_Chapter_2_img044_10a02e1c.png)

GDMA\_PERI\_IN\_SEL\_CHn This register is used to select peripheral for RX channel 0. 0: SPI2. 1: reserved. 2: UHCI0. 3: I2S. 4: reserved. 5: reserved. 6: AES. 7: SHA. 8: ADC; 9 ~ 63: Invalid. (R/W)

Register 2.32. GDMA\_OUT\_PERI\_SEL\_CHn\_REG (n: 0-2) (0x0100+192*n)

![Image](images/02_Chapter_2_img045_5f1763d5.png)

GDMA\_PERI\_OUT\_SEL\_CHn This register is used to select peripheral for TX channel 0. 0: SPI2. 1: reserved. 2: UHCI0. 3: I2S. 4: reserved. 5: reserved. 6: AES. 7: SHA. 8: ADC; 9 ~ 63: Invalid. (R/W)

![Image](images/02_Chapter_2_img046_747524f6.png)

## Part II

## Memory Organization

This part provides insights into the system's memory structure, discussing the organization and mapping of RAM, ROM, eFuse, and external memories, offering a framework for understanding memory-related subsystems.
