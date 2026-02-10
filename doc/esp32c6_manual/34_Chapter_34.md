---
chapter: 34
title: "Chapter 34"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 34

## SDIO Slave Controller (SDIO)

## 34.1 Overview

The ESP32-C6 features hardware support for the Secure Digital Input/Output (SDIO) device interface that conforms to the SDIO Specification V2.00. This allows an SDIO host to access the ESP32-C6 via an SDIO bus protocol.

The SDIO host can read ESP32-C6 SDIO interface registers directly or access shared memory via the Direct Memory Access (DMA) engine, thus reducing processor's overhead while keeping high performance.

## 34.2 Features

The SDIO Slave Controller has the following features:

- Compatible with SD Physical Layer Specification V2.00 and SDIO V2.00 specifications
- Support for two IO functions (except function 0)
- Support for SPI, 1-bit SDIO, and 4-bit SDIO transfer modes
- Clock range of 0 ~ 50 MHz
- Configurable sample and drive clock edge
- Integrated and SDIO-accessible registers for information interaction
- Support for SDIO interrupt mechanism
- Automatic padding data and discarding the padded data on the SDIO bus
- Block size up to 512 bytes
- Interrupt vector between the host and slave for bidirectional interrupt
- Support DMA for data transfer
- Support for wake-up from sleep when connection is retained

## 34.3 Architecture Overview

The functional block diagram of the SDIO slave module is shown in Figure 34.3-1 .

Figure 34.3-1. SDIO Slave Block Diagram

![Image](images/34_Chapter_34_img001_efc7fbb7.png)

In the above figure, Host represents any host device that is compatible with SDIO Specification V2.00. It interacts with the ESP32-C6 (configured as the SDIO slave) via the standard SDIO bus implementation.

The SDIO Device Interface block enables effective communication with the external Host by directly providing SDIO interface registers and enabling DMA operation for high-speed data transfer over the Advanced High-Performance Bus (AHB) without engaging the CPU.

## 34.4 Standards Compliance

The ESP32-C6 SDIO Slave Controller conforms to the following standards:

- SD Specifications Part1 Physical Layer Specification Version 2.00 (referred to as Physical Layer Specification V2.00 in this chapter)
- SD Specifications Part E1 SDIO Specification Version 2.00, January 30, 2007 (referred to as SDIO Specification V2.00 in this chapter)

## 34.5 Functional Description

## 34.5.1 Physical Bus

- Bus mode: SPI, 1-bit and 4-bit SDIO transfer modes.
- Bus signal: The physical bus signals of the standard SDIO Specification V2.00, including CS/DI/SCLK/DO/IRQ in the SPI transmission mode, CMD/CLK/DATA/IRQ in the SDIO 1-bit transmission mode, and CMD/CLK/DAT[3:0] in the SDIO 4-bit transmission mode.
- Bus speed mode: full-speed card mode of 0 ~ 50 MHz clock range and low-speed card mode of 0 ~ 400 kHz clock range.
- IO functions: 2 IO functions in addition to function 0. Function 0 is only used for CCCR, FBR, and CIS operations. Function 1 and 2 can be used at the same time to transfer application data packets (such as Wi-Fi packets and Bluetooth packets) and to access SLC Host registers.

For more information, please refer to Physical Layer Specification V2.00 and SDIO Specification V2.00.

![Image](images/34_Chapter_34_img002_23bdcdf5.png)

34.5.3

1/0 Function O Address Space

Card Information Structure (CIS) operations. Figure 34.5-3 shows its address space map, which is specified by

## 34.5.2 Supported Commands

The SDIO Slave Controller mainly supports the IO\_RW\_DIRECT (CMD52) and IO\_RW\_EXTENDED (CMD53) data transfer commands. 0x000000-0x0000FF CCCR

IO\_RW\_DIRECT (CMD52) can be used to access registers and transfer data, but usually it is used to access registers. Figure 34.5-1 shows its fields. For the meaning of each field, please refer to the SDIO Specification V2.00. 0x000300-0x0003FF FBR (Function 3)

| 0x000700-0x0007FF 0x000800-0x000FFF   | FBR (Function 7) RFU   |
|---------------------------------------|------------------------|

0x001000-0x017FFF

CIS Area

(common and per-function)

Figure 34.5-1. CMD52 Content

0x018000-0x01FFFF

RFU

IO\_RW\_EXTENDED (CMD53) is used to initiate the transfer of packets of an arbitrary length. Figure 34.5-2 shows the its fields. For the meaning of each field, please refer to the SDIO Specification V2.00.

![Image](images/34_Chapter_34_img003_97592fae.png)

| As defined in the SDIO Specification, CCCR are common control registers, FBR are control configuration registers for each function, and CIS are status registers for storing card information, such as version, power   |
|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|

Espressif Systems

Figure 34.5-2. CMD53 Content

Submit Documentation Feedback

## 34.5.3 I/O Function 0 Address Space

I/O function 0 is only used for Card Common Control Registers (CCCR), Function Basic Registers (FBR), and Card Information Structure (CIS) operations. Figure 34.5-3 shows its address space map, which is specified by the SDIO Specification. For what each section in this map means, please refer to the Specification.

Figure 34.5-3. Function 0 Address Space

![Image](images/34_Chapter_34_img004_8cc54d0b.png)

As defined in the SDIO Specification, CCCR are common control registers, FBR are control configuration registers for each function, and CIS are status registers for storing card information, such as version, power

![Image](images/34_Chapter_34_img005_d9bb06e6.png)

ESP32-C6 TRM (Version 1.1)

consumption, and manufacturer. The functions of these registers are optional, and their meanings are detailed in the SDIO Specification.

The CCCR configuration of ESP32-C6 SDIO slave is shown in Table 34.5-1, and the FBR configuration is shown Table 34.5-2 .

Table 34.5-1. SDIO Slave CCCR Configuration

| Adress     | Register Name               | Bit 7                                                                                   | Bit 6                                                                                   | Bit 5                                                                                   | Bit 4                                                                                   | Bit 3                                                                                   | Bit 2                                                                                   | Bit 1                                                                                   | Bit 0                                                                                   |
|------------|-----------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| 0x00       | CCCR/SDIO Revision          | Set SDIO bit[3:0] using HINF_SDIO_VER[7:4] in                                           | Set SDIO bit[3:0] using HINF_SDIO_VER[7:4] in                                           | HINF_CFG_DATA1_REG                                                                      | Set SDIO bit[3:0] using HINF_SDIO_VER[7:4] in                                           | Set CCCR bit[3:0] using HINF_SDIO_VER[3:0] in HINF_CFG_DATA1_REG                        | Set CCCR bit[3:0] using HINF_SDIO_VER[3:0] in HINF_CFG_DATA1_REG                        | Set CCCR bit[3:0] using HINF_SDIO_VER[3:0] in HINF_CFG_DATA1_REG                        | Set CCCR bit[3:0] using HINF_SDIO_VER[3:0] in HINF_CFG_DATA1_REG                        |
| 0x01       | SD Specifica tion Revision | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | Set SD bit[3:0] using HINF_SDIO_VER[11:8] in HINF_CFG_DATA1_REG                         | Set SD bit[3:0] using HINF_SDIO_VER[11:8] in HINF_CFG_DATA1_REG                         | Set SD bit[3:0] using HINF_SDIO_VER[11:8] in HINF_CFG_DATA1_REG                         | Set SD bit[3:0] using HINF_SDIO_VER[11:8] in HINF_CFG_DATA1_REG                         |
| 0x02       | I/O Enable                  | 0 (IOE[7:3])                                                                            | 0 (IOE[7:3])                                                                            | 0 (IOE[7:3])                                                                            | 0 (IOE[7:3])                                                                            | 0 (IOE[7:3])                                                                            | R/W (IOE[2:1])                                                                          | R/W (IOE[2:1])                                                                          | 0 (RFU)                                                                                 |
| 0x03       | I/O Ready                   | 0 (IOR[7:3])                                                                            | 0 (IOR[7:3])                                                                            | 0 (IOR[7:3])                                                                            | 0 (IOR[7:3])                                                                            | 0 (IOR[7:3])                                                                            | R (IOR[2:1])                                                                            | R (IOR[2:1])                                                                            | 0 (RFU)                                                                                 |
| 0x04       | Int Enable                  | 0 (IEN[7:3])                                                                            | 0 (IEN[7:3])                                                                            | 0 (IEN[7:3])                                                                            | 0 (IEN[7:3])                                                                            | 0 (IEN[7:3])                                                                            | R/W (IEN[2:1])                                                                          | R/W (IEN[2:1])                                                                          | R/W (IENM)                                                                              |
| 0x05       | Int Pending                 | 0 (INT[7:3])                                                                            | 0 (INT[7:3])                                                                            | 0 (INT[7:3])                                                                            | 0 (INT[7:3])                                                                            | 0 (INT[7:3])                                                                            | R (INT[2:1])                                                                            | R (INT[2:1])                                                                            | 0 (RFU)                                                                                 |
| 0x06       | I/O Abort                   | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | W (RES)                                                                                 | W (AS[2:0])                                                                             | W (AS[2:0])                                                                             | W (AS[2:0])                                                                             |
| 0x07       | Bus Interface Control       | R/W (CD Disable)                                                                        | 1 (SCSI)                                                                                | R/W (ECSI)                                                                              | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | R/W (Bus Width[1:0])                                                                    | R/W (Bus Width[1:0])                                                                    |
| 0x08       | Card Capability             | 0 (4BLS)                                                                                | 0 (LSC)                                                                                 | R/W (E4MI)                                                                              | 1 (S4MI)                                                                                | 0 (SBS)                                                                                 | 1 (SRW)                                                                                 | 1 (SMB)                                                                                 | 1 (SDC)                                                                                 |
| 0x09- 0x0B | Common CIS Pointer          | Address 0x09: 0x0; Address 0x0A: 0x10; Address 0x0B: 0x0 (Pointer to card’s common CIS) | Address 0x09: 0x0; Address 0x0A: 0x10; Address 0x0B: 0x0 (Pointer to card’s common CIS) | Address 0x09: 0x0; Address 0x0A: 0x10; Address 0x0B: 0x0 (Pointer to card’s common CIS) | Address 0x09: 0x0; Address 0x0A: 0x10; Address 0x0B: 0x0 (Pointer to card’s common CIS) | Address 0x09: 0x0; Address 0x0A: 0x10; Address 0x0B: 0x0 (Pointer to card’s common CIS) | Address 0x09: 0x0; Address 0x0A: 0x10; Address 0x0B: 0x0 (Pointer to card’s common CIS) | Address 0x09: 0x0; Address 0x0A: 0x10; Address 0x0B: 0x0 (Pointer to card’s common CIS) | Address 0x09: 0x0; Address 0x0A: 0x10; Address 0x0B: 0x0 (Pointer to card’s common CIS) |
| 0x0C       | Bus Suspend                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (BR)                                                                                  | 0 (BS)                                                                                  |
| 0x0D       | Function Select             | 0 (DF)                                                                                  |                                                                                         | 0 (RFU)                                                                                 |                                                                                         | 0 (FS[3:0])                                                                             | 0 (FS[3:0])                                                                             | 0 (FS[3:0])                                                                             | 0 (FS[3:0])                                                                             |
| 0x0E       | Exec Flags                  | 0 (EX[7:1])                                                                             | 0 (EX[7:1])                                                                             | 0 (EX[7:1])                                                                             | 0 (EX[7:1])                                                                             | 0 (EX[7:1])                                                                             | 0 (EX[7:1])                                                                             | 0 (EX[7:1])                                                                             | 0 (EXM)                                                                                 |
| 0x0F       | Ready Flags                 | 0 (RF[7:1])                                                                             | 0 (RF[7:1])                                                                             | 0 (RF[7:1])                                                                             | 0 (RF[7:1])                                                                             | 0 (RF[7:1])                                                                             | 0 (RF[7:1])                                                                             | 0 (RF[7:1])                                                                             | 0 (RFM)                                                                                 |
| 0x10- 0x11 | FN0 Block Size              | R/W (Supported range: 0 - 512) (I/O block size for Function 0)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 0)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 0)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 0)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 0)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 0)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 0)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 0)                          |
| 0x12       | Power Control               | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | R/W (EMPC)                                                                              | 1 (SMPC)                                                                                |

Cont’d on next page

Table 34.5-1. SDIO Slave CCCR Configuration – cont’d from previous page

| Address   | Register Name   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1     | Bit 0         |
|-----------|-----------------|---------|---------|---------|---------|---------|---------|-----------|---------------|
| 0x13      | High-Speed      | 0 (RFU) | 0 (RFU) | 0 (RFU) | 0 (RFU) | 0 (RFU) | 0 (RFU) | R/W (EHS) | Note  a (SHS) |

Table 34.5-2. SDIO Slave FBR Configuration

| Address      | Bit 7                                                                                   | Bit 6                                                                                   | Bit 5                                                                                   | Bit 4                                                                                   | Bit 3                                                                                   | Bit 1                                                                                   | Bit 0                                                                                   |                                                                                         |
|--------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| 0x100        | 0 (Function 1 CSA enable)                                                               | 0 (Function 1 supports CSA)                                                             | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (Function 1 Standard SDIO Function interface code)                                    | 0 (Function 1 Standard SDIO Function interface code)                                    | 0 (Function 1 Standard SDIO Function interface code)                                    | 0 (Function 1 Standard SDIO Function interface code)                                    |
| 0x101        | 0 (Function 1 Extended standard SDIO Function interface code)                           | 0 (Function 1 Extended standard SDIO Function interface code)                           | 0 (Function 1 Extended standard SDIO Function interface code)                           | 0 (Function 1 Extended standard SDIO Function interface code)                           | 0 (Function 1 Extended standard SDIO Function interface code)                           | 0 (Function 1 Extended standard SDIO Function interface code)                           | 0 (Function 1 Extended standard SDIO Function interface code)                           | 0 (Function 1 Extended standard SDIO Function interface code)                           |
| 0x102        | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | R/W (EPS)                                                                               | 0 (SPS)                                                                                 |                                                                                         |
| 0x109- 0x10B | Address 0x109: 0x0; Address 0x10A: 0x11; Address 0x10B: 0x0 (Pointer to Function 1 CIS) | Address 0x109: 0x0; Address 0x10A: 0x11; Address 0x10B: 0x0 (Pointer to Function 1 CIS) | Address 0x109: 0x0; Address 0x10A: 0x11; Address 0x10B: 0x0 (Pointer to Function 1 CIS) | Address 0x109: 0x0; Address 0x10A: 0x11; Address 0x10B: 0x0 (Pointer to Function 1 CIS) | Address 0x109: 0x0; Address 0x10A: 0x11; Address 0x10B: 0x0 (Pointer to Function 1 CIS) | Address 0x109: 0x0; Address 0x10A: 0x11; Address 0x10B: 0x0 (Pointer to Function 1 CIS) | Address 0x109: 0x0; Address 0x10A: 0x11; Address 0x10B: 0x0 (Pointer to Function 1 CIS) | Address 0x109: 0x0; Address 0x10A: 0x11; Address 0x10B: 0x0 (Pointer to Function 1 CIS) |
| 0x110- 0x111 | R/W (Supported range: 0 - 512) (I/O block size for Function 1)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 1)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 1)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 1)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 1)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 1)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 1)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 1)                          |
| 0x200        | 0 (Function 2 CSA enable)                                                               | 0 (Function 2 supports CSA)                                                             | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0x2 (Function 2 Standard SDIO Function interface code)                                  | 0x2 (Function 2 Standard SDIO Function interface code)                                  | 0x2 (Function 2 Standard SDIO Function interface code)                                  | 0x2 (Function 2 Standard SDIO Function interface code)                                  |
| 0x201        | 0                                                                                       | 0                                                                                       | 0                                                                                       | 0                                                                                       | 0                                                                                       | 0                                                                                       | 0                                                                                       | 0                                                                                       |
| 0x202        | (Function 2 Extended standard SDIO Function interface code)                             | (Function 2 Extended standard SDIO Function interface code)                             | (Function 2 Extended standard SDIO Function interface code)                             | (Function 2 Extended standard SDIO Function interface code)                             | (Function 2 Extended standard SDIO Function interface code)                             | (Function 2 Extended standard SDIO Function interface code)                             | (Function 2 Extended standard SDIO Function interface code)                             | (Function 2 Extended standard SDIO Function interface code)                             |
| 0x209-       | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | 0 (RFU)                                                                                 | R/W (EPS)                                                                               | 0 (SPS)                                                                                 |                                                                                         |
| 0x20B        | Address 0x209: 0x0; Address 0x20A: 0x12; Address 0x20B: 0x0 (Pointer to Function 2 CIS) | Address 0x209: 0x0; Address 0x20A: 0x12; Address 0x20B: 0x0 (Pointer to Function 2 CIS) | Address 0x209: 0x0; Address 0x20A: 0x12; Address 0x20B: 0x0 (Pointer to Function 2 CIS) | Address 0x209: 0x0; Address 0x20A: 0x12; Address 0x20B: 0x0 (Pointer to Function 2 CIS) | Address 0x209: 0x0; Address 0x20A: 0x12; Address 0x20B: 0x0 (Pointer to Function 2 CIS) | Address 0x209: 0x0; Address 0x20A: 0x12; Address 0x20B: 0x0 (Pointer to Function 2 CIS) | Address 0x209: 0x0; Address 0x20A: 0x12; Address 0x20B: 0x0 (Pointer to Function 2 CIS) | Address 0x209: 0x0; Address 0x20A: 0x12; Address 0x20B: 0x0 (Pointer to Function 2 CIS) |
| 0x210- 0x211 | R/W (Supported range: 0 - 512) (I/O block size for Function 2)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 2)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 2)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 2)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 2)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 2)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 2)                          | R/W (Supported range: 0 - 512) (I/O block size for Function 2)                          |

## 34.5.4 I/O Function 1/2 Address Space Map

I/O function 1 and 2 have the exactly the same functions and permissions. They can be used at the same time or independently to transmit application data (such as Wi-Fi data and Bluetooth data) in fixed-address packets or incremental-address packets. They can also access the same set of SLC Host registers. Figure 34.5-4 shows their address space map. All segments in this space can be accessed by the host.

Figure 34.5-4. Function 1/2 Address Space Map

![Image](images/34_Chapter_34_img006_142e6304.png)

| 0x0             | Fixed address Packet   |
|-----------------|------------------------|
| 0x1 -0x3F       | Reserved               |
| 0x40 -0x3FF     | SLC Host Register      |
| 0x400 - 0x1F7FF | Incr address Packet    |

## 34.5.4.1 Accessing SLC HOST Register Space

For effective interaction, the host can access the registers that are in contiguous address from 0x40 to 0x3FF in the slave via the I/O function 1/2. To access them, the host simply needs to set the Register Address field of CMD52 or CMD53 to the low 10 bits of their address. Besides, CMD53 allows the host to access multiple registers at one go for a higher transfer rate.

From SLCHOST\_CONF\_W0\_REG and SLCHOST\_CONF\_W15\_REG, there are 52 bytes of fields that the host and slave can access and change, thus facilitating the information interaction.

The software on both the host and the slave sides can access the SLC Host register space at the same time, so an upper-layer mechanism should be designed to avoid the error caused by such behavior.

## 34.5.4.2 Transferring Incremental-Address Packets

When the host uses the address 0x400 - 0x1F7FF to continuously transmit multiple application data packets (such as Wi-Fi packets), the address field in CMD53 should be set to increment mode and the OP Code field to 1.

For example, if the host wants to use CMD53 to transfer (send or receive) three data blocks starting from the base address 0x500, then it should:

- Set the Block Mode field in CMD53 to 1, indicating data unit is block
- Set the OP Code field to 1, indicating incremental address mode
- Set the Register Address field to 0x500, indicating the base address is 0x500
- Set the Byte/Block Count field to 0x3, indicating 3 data blocks
- Set other fields according to the SDIO Specification

When the packet is transmitted (slave sends to host, or slave receives from host) through CMD53, the slave will determine whether all the valid data of the current packet has been transmitted so as to pad (when slave sends to host) or discard (when slave receives from host) the invalid data. For more information about data padding and discarding, please refer to Section 34.5.5.3 .

## 34.5.4.3 Transferring Fixed-Address Packets

When the host uses address 0x0 to transmit application data packets (such as Bluetooth packets), the address field and OP Code field in CMD53 should be set to 0.

For example, if the host wants to use CMD53 to transfer (send or receive) three data blocks starting from the fixed address 0x0, then it should:

- Set the Block Mode field in CMD53 to 1, indicating data unit is block
- Set the OP Code field to 0, indicating fixed address mode
- Set the Register Address field to 0x0, indicating the fixed address is 0x0
- Set the Byte/Block Count field to 0x3, indicating 3 data blocks
- Set other fields according to the SDIO Specification

When the packet is transmitted (slave sends to host, or slave receives from host) between the host and the slave through CMD53, the slave will determine whether all the valid data of the current packet has been transmitted so as to pad (when slave sends to host) or discard (when slave receives from host) the invalid data. For more information about data padding and discarding, please refer to Section 34.5.5.3 .

## 34.5.5 DMA

The SDIO Slave Controller uses a dedicated DMA to access data residing in RAM. As shown in Figure 34.3-1 , RAM is accessed over the AHB. For the RAM space accessible by the Controller, please refer to Chapter 5 System and Memory. To set the RAM address range that can be accessed for one transfer, please configure the *SHAREMEM*\_REG fields described in Section 34.8 .

DMA has two channels, SLC0 and SLC1. They are used to transfer incremental-address packets and fixed-address packets, respectively. For the convenience of users, the SDIO slave provides function 1/2 for data transmission. The address range of I/O Function 1/2 is detailed in Section 34.5.4. It is recommended to transmit incremental-address packets via SLC0 using function 1 and fixed-address packets via SLC1 using function 2.

DMA accesses RAM over AHB. Users can configure whether the AHB interface can use burst operation and which burst operation type to use by configuring the relevant fields in SDIO\_SLCCONF0\_REG and SDIO\_SLC\_BURST\_LEN\_REG. For more information, please refer to Section 34.8 .

## 34.5.5.1 Linked List

The slave software can use the DMA engine by mounting linked lists. DMA sends the data from the RAM address space configured in the RX (slave to host) linked list and stores the received data into the address space configured in the TX (host to slave) linked list. A linked list consists of several descriptors.

Figure 34.5-5. DMA Linked List Descriptor Structure of the SDIO Slave

![Image](images/34_Chapter_34_img007_597ab702.png)

The TX linked list descriptor and the RX linked list descriptor have the same structure, which is shown in Figure 34.5-5. The descriptor consists of 3 words. The meaning of each field is as follows:

- owner (DW0) [31]: Indicates who is allowed to access the buffer that this descriptor points to. 0: CPU
- 1: DMA engine

Slave software should set this field to 1 when creating the descriptor. After the DMA write-back permission is enabled and the corresponding buffer is used by the DMA, the field is cleared to 0.

- eof (DW0) [30]: Indicates the end of a data packet.
- 0: The current descriptor is not the last descriptor of the packet 1: The current descriptor is the last descriptor of the packet

When the host sends a packet to the slave, the slave software should set the field to 0 while creating the descriptor. DMA sets the field of the last descriptor in the packet to 1; When the host receives packets from the slave, the slave software configures the field depending on whether this descriptor is the last descriptor of the packet.

- reserved (DW0) [29:28]: reserved. Slave software should set this field to 0x0.
- length (DW0) [27:14]: Indicates the number of valid bytes in the corresponding buffer. When the DMA engine is reading data from the buffer, it indicates the number of bytes that can be read; when DMA engine is storing data in the buffer, it indicates the number of bytes of the stored data. When the host sends a packet to the slave, the slave software should set this field to 0x0 while creating the descriptor. DMA writes back the field after the corresponding buffer is used up; when the host receives the packet from the slave and the slave creates the descriptor, the slave software should set this field to the number of bytes that can be read by the corresponding buffer.
- size (DW0) [13:0]: Indicates the size of the corresponding buffer. Unit: byte.
- Slave software should configure this field when creating the descriptor. Note: This field must be word-aligned.
- buffer address pointer (DW1): Buffer address pointer. Slave software should configure this field when creating the descriptor. Note: This field must be word-aligned.
- next descriptor address (DW2): Address of the next descriptor. When the next descriptor does not exist, the value is 0.

Slave software should configure this field when creating the descriptor.

For more information on DMA write-back linked list descriptor fields, please refer to Section 34.5.5.2 .

The slave software can combine multiple descriptors into a linked list using the next descriptor address (DW2) field. The SDIO slave DMA linked list is shown in Figure 34.5-6 .

Figure 34.5-6. DMA Linked List of the SDIO Slave

![Image](images/34_Chapter_34_img008_a895e043.png)

An example is provided below to facilitate understanding of the linked list and the eof bit. Suppose the slave software creates a linked list that contains 3 descriptors; descriptor 0 points to 500 bytes data and its eof bit is 0; descriptor 1 points to 200 bytes data and its eof bit is 1; descriptor 2 points to 200 bytes data and its eof bit is 1. If the first CMD53 needs to read 400 bytes data, then DMA sends the first 400 bytes data of descriptor 0 to the host. If the second CMD53 needs to read 400 bytes data, firstly DMA sends the remaining 100 bytes data of descriptor 0 to the host. Secondly, it sends 200 bytes data of descriptor 1 to the host. Since the eof bit of descriptor 1 is 1, DMA considers the valid data of the current CMD53 is over. So, lastly DMA sends 100 bytes invalid data 0x0 to the host. If the third CMD53 needs to read 400 bytes data, firstly DMA sends the 200 bytes data of descriptor 2 to the host. Since descriptor 2's eof bit is 1, DMA considers the valid data of current CMD53 is over. So, DMA sends 200 bytes invalid data 0x0 to the host.

## 34.5.5.2 Write-Back of Linked List

In the process of sending packets from the host to the slave, when the buffer specified by a linked list descriptor is full, or when a packet transmission ends, the DMA engine needs to jump to the next descriptor to store subsequent data. Before the jump, DMA writes back the current descriptor. In DW0, DMA updates the eof and length bits to the latest value. The value of the owner bit is determined by SDIO\_SLC0/1\_TX\_LOOP\_TEST in SDIO\_SLCCONF0\_REG .

In the process of receiving packets from the slave, when the host reads all the data in the buffer specified by a linked list descriptor, DMA engine needs to jump to the next descriptor to read subsequent data. Before the jump, the slave software can set SDIO\_SLC0/1\_RX\_AUTO\_WRBACK in SDIO\_SLCCONF0\_REG to 1 so that the DMA will write back the current descriptor. The value to write to the owner bit is determined by SDIO\_SLC0/1\_RX\_LOOP\_TEST in SDIO\_SLCCONF0\_REG. Values of other bits in DW0 remain unchanged.

The relevant register fields are described in Section 34.8 .

## 34.5.5.3 Data Padding and Discarding

In order to transfer data in blocks, both the host and the slave need to pad the data sent on the SDIO bus into entire blocks. The slave will automatically pad data when sending the packet, and automatically discard the padded data after receiving packets.

- When the host sends a data packet to the slave through CMD53 and the amount of data reaches the length of the data packet, the SDIO slave considers that the valid data of the current data packet is over. At this time, DMA will write back the current linked list descriptor, set the eof bit of the current descriptor to 1, and generate SLC0/1\_TX\_SUC\_EOF\_INT interrupt. After it determines that the valid data is over, the remaining data of the current packet will be considered as invalid data, and will not be received into the buffer by DMA. The slave will not restart receiving data into the next buffer until the next CMD53.
- – For incremental-address packets, the slave determines valid data based on the address. The data with the address greater than or equal to 0x1F800 is considered as invalid data and will be discarded. Therefore, the host should set the CMD53 start address field to 0x1F800 – Packet\_length (unit: byte). The data flow of incremental-address packets on SDIO bus is shown in Figure 34.5-7 .
- – For fixed-address packets, the slave considers the first 3 bytes of the data packet as the packet length (including the first 3 bytes, which will also be stored in the buffer specified by the linked list). After the length of the received data reaches the packet length, the subsequent data will be considered as invalid and discarded.
- When the host receives data packets (including incremental-address packets and fixed-address packets) from the slave through CMD53 and DMA reads the last byte of a buffer and the eof bit of the DMA linked list descriptor is 1, the SDIO slave will consider the valid data of the current packet is over. At this time, DMA will write back the current descriptor and generate SLC0/1\_RX\_EOF\_INT interrupt. After it is determined that the valid data is over, the remaining bits of the current data packet will be padded with invalid data 0x0, and will not be read from the buffer via DMA. The slave will restart to read data from the buffer via DMA until the next CMD53.

Figure 34.5-7. Data Flow of Sending Incremental-address Packets From Host to Slave

![Image](images/34_Chapter_34_img009_b54f529f.png)

Note: When the host receives either incremental-address or fixed-address data packets from the slave, the eof bit of the DMA linked list descriptor is always considered as the basis for determining the end of data, rather than the address 0x1F800. Therefore, when the host sends multiple CMD53s to obtain multiple data packets, as long as the DMA does not encounter the eof bit is 1 in the descriptors, the slave will obtain the data from buffers in sequence according to the linked list and then transmit them to the host; when the DMA encounters the eof bit is 1, the data will be fetched from the corresponding buffer, and then invalid data will be added to complete the current CMD53 command, and the next CMD53 command will take data from the buffer pointed to by the next descriptor.

![Image](images/34_Chapter_34_img010_92ac93c4.png)

## 34.5.6 SDIO Bus Timing

The SDIO bus operates at a very high speed and the PCB trace length usually affects signal integrity by introducing latency. To ensure that the timing characteristics conform to the desired bus timing, the SDIO slave module supports configuration of input sampling clock edge and output driving clock edge.

When the incoming data changes near the rising edge of the clock, the slave will perform sampling on the falling edge of the clock, or vice versa, as Figure 34.5-8 shows.

Figure 34.5-8. Sampling Timing Diagram

![Image](images/34_Chapter_34_img011_9926636d.png)

By default, the MTMS (GPIO4) strapping value determines the slave's sampling edge. However, users can decide the sampling edge by configuring the SLCHOST\_CONF\_REG register, with priority from high to low: (1) Set SLCHOST\_FRC\_POS\_SAMP to sample the corresponding signal at the rising edge; (2) Set SLCHOST\_FRC\_NEG\_SAMP to sample the corresponding signal at the falling edge.

SLCHOST\_FRC\_POS\_SAMP and SLCHOST\_FRC\_NEG\_SAMP fields are five bits wide. The bits correspond to the CMD line and four DATA lines (0-3). Setting a bit causes the corresponding line to be sampled for input at the rising clock edge or falling clock edge.

The slave can also select which edge to drive the output lines, in order to accommodate for any latency caused by the physical signal path. The output timing is shown in Figure 34.5-9 .

Figure 34.5-9. Output Timing Diagram

![Image](images/34_Chapter_34_img012_6a589010.png)

By default, the MTDI (GPIO5) strapping value determines the slave's output driving edge. However, users can decide the output driving edge by configuring the following registers, with priority from high to low: (1) Set SLCHOST\_FRC\_SDIO11 in SLCHOST\_CONF\_REG to output the corresponding signal at the falling clock edge; (2) Set SLCHOST\_FRC\_SDIO22 in SLCHOST\_CONF\_REG to output the corresponding signal at the rising clock edge; (3) Set HINF\_HIGHSPEED\_ENABLE in HINF\_CFG\_DATA1\_REG and SLCHOST\_HSPEED\_CON\_EN in SLCHOST\_CONF\_REG, then set the EHS (Enable High-Speed) bit in CCCR at the host side to output the corresponding signal at the rising clock edge.

SLCHOST\_FRC\_SDIO11 and SLCHOST\_FRC\_SDIO22 fields are five bits wide. The bits correspond to the CMD line and four DATA lines (0-3). Setting a bit causes the corresponding line to output at the rising clock edge or falling clock edge.

Notes on priority setting: The configuration of strapping pins has the lowest priority when controlling the sampling edge or driving edge. The lower-priority configuration takes effect only when the higher-priority configuration is not set. For example, the MTMS (GPIO4) strapping value determines the sampling edge only when SCLHOST\_FRC\_POS\_SAMP and SCLHOST\_FRC\_NEG\_SAMP are not set.

## 34.6 Interrupt

The host and the slave can interrupt each other via the interrupt vector. There are 8 interrupt vectors between the host and each DMA SLC channel of the slave. To send an interrupt to the other side, the enable bit of the interrupt vector register should be set to 1.

## 34.6.1 Host Interrupt

- SLCHOST\_SLC0/1\_RX\_NEW\_PACKET\_INT : The slave has a packet to send. Any of the cases below can trigger the interrupt.
- – When SDIO\_SLC0\_RXLINK\_START or SDIO\_SLC1\_RXLINK\_START is set to enable DMA
- – When a new RX linked list descriptor is coming after DMA processes the RX linked list descriptor with the eof bit being 1
- – When a packet needs to be retry
- SLCHOST\_SLC0/1\_TX\_OVF\_INT : Slave receiving buffer overflow interrupt
- SLCHOST\_SLC0/1\_RX\_UDF\_INT : Slave sending buffer underflow interrupt.
- SLCHOST\_SLC0/1\_TOHOST\_BITn\_INT (n: 0 ~ 7): Slave interrupts the host.

## 34.6.2 Slave Interrupt

- SLC0/1\_RX\_DSCR\_ERR\_INT : Slave sending linked list descriptor error.
- SLC0/1\_TX\_DSCR\_ERR\_INT : Slave receiving linked list descriptor error.
- SLC0/1\_RX\_EOF\_INT : Slave sending operation is finished.
- SLC0/1\_RX\_DONE\_INT : A single buffer is sent by the slave.
- SLC0/1\_TX\_SUC\_EOF\_INT : Slave receiving operation is finished.
- SLC0/1\_TX\_DONE\_INT : A single buffer is finished during receiving operation.
- SLC0/1\_TX\_OVF\_INT : Slave receiving buffer overflow interrupt.
- SLC0/1\_RX\_UDF\_INT : Slave sending buffer underflow interrupt.
- SLC0/1\_TX\_START\_INT : Slave receiving start interrupt.
- SLC0/1\_RX\_START\_INT : Slave sending start interrupt.
- SLC\_FRHOST\_BITn\_INT (n: 0 ~ 15): The host interrupts the slave via the SLC0 channel if interrupt vector Bit[7:0] is set or via the SLC1 channel if interrupt vector Bit[15:8] is set.

## 34.7 Packet Sending and Receiving Procedure

The SDIO host and slave devices need to follow specific data transfer procedures to successfully exchange data over the SDIO interface. Beside SDIO Specifications, ESP32-C6 should also follow the procedures below to transmit data over higher abstraction layers, such as Wi-Fi and Bluetooth data.

## 34.7.1 Sending Packets to SDIO Host

The transmission of packets from the slave to the host is initiated by the slave. The host will be notified with an interrupt (for detailed information on interrupts, please refer to SDIO Specification). After the host reads the relevant information from the slave, it will initiate an SDIO bus transmission accordingly. The whole procedure is illustrated in Figure 34.7-1 .

Figure 34.7-1. Procedure of Slave Sending Packets to Host

![Image](images/34_Chapter_34_img013_5eb7b3e5.png)

1. The slave CPU creates the linked list for the data packets that it will send to the host. For how to create a linked list, please refer to Section 34.5.5.1 .
2. The slave CPU updates the length of data that will be sent to the host using the register

![Image](images/34_Chapter_34_img014_7fc0f516.png)

SDIO\_SLC0\_LEN\_CONF\_REG .

3. The slave CPU starts DMA by writing the 32-bit address of the first descriptor in linked list to SDIO\_SLC0RX\_LINK\_ADDR\_REG or SDIO\_SLC1RX\_LINK\_ADDR\_REG and then configuring SDIO\_SLC0\_RXLINK\_START or SDIO\_SLC1\_RXLINK\_START to start DMA. For more information on DMA, please refer to Section 34.5.5 .
4. The slave DMA sends an interrupt to the host.
5. After the host received the interrupt, it reads from SLCHOST\_SLC0HOST\_INT\_ST\_REG , SLCHOST\_SLC1HOST\_INT\_ST\_REG, and SLCHOST\_PKT\_LEN\_REG the following information:
- SLCHOST\_SLC0/1HOST\_INT\_ST\_REG: Interrupt status register. If the SLCHOST\_SLC0/1\_RX\_NEW\_PACKET\_INT\_ST bit is 1, this indicates that the slave has packets to send.
- SLCHOST\_PKT\_LEN\_REG: Packet length accumulator register. The current value minus the value of last time equals the packet length sent this time.
6. The host clears the interrupt through CMD52.
7. The host fetches packets from the slave through CMD53. During the transmission, when the slave determines that the valid data of the current packet is over, the subsequent bits will be padded with invalid data 0x0. For how to determine the end of valid data, please refer to Section 34.5.5.3 .
8. After the packets is transmitted, the slave DMA sends an interrupt to the CPU, and the CPU can recycle the buffer at this time.

## Notes:

- It is not recommended to set all of the eof bits to 0 in the linked list. Otherwise, the DMA may send the data of the next packet to the current command, which may cause errors. In cases where all of the eof bits is set to 0, the slave software should align the length of each packet to the size of the data block by padding data, to prevent the DMA from sending the data of the next packet to the current command. When the host sends CMD53 to read data, it should accurately control the number of data blocks in each packet, do not read more or less data blocks. Besides, the host should be able to identify the padded data.
- It is recommended that a CMD53 command only should transmit one data packet and each data packet should use only one linked list so as to avoid unknown exceptions caused by complex transmission.
- It is not recommended to send multiple packets through one linked list because it may be difficult for the host and software to split between the data packets. In cases where this has to be done, the software should set the eof bit when creating the linled list to divide the data packets so that the DMA can pad data packets accordingly (it is recommended that the length of each data packet should be aligned to the size of the data block to avoid data padding by DMA), and the host should be able to identify the padded data.

## 34.7.2 Receiving Packets from SDIO Host

Transmission of packets from the host to slave is initiated by the host. The slave receives data via DMA and stores it in RAM. After transmission is completed, the CPU will be interrupted to process the data. The whole procedure is demonstrated in Figure 34.7-2 .

Figure 34.7-2. Procedure of Slave Receiving Packets from Host

![Image](images/34_Chapter_34_img015_ae5c4be8.png)

The host obtains the number of available receiving buffers from the slave by accessing SLCHOST\_SLC0HOST\_TOKEN\_RDATA\_REG or SLCHOST\_SLC1HOST\_TOKEN\_RDATA\_REG. The slave CPU should update the value of the register after the receiving DMA linked list is prepared.

SLCHOST\_HOSTSLCHOST\_SLC0\_TOKEN1 or SLCHOST\_HOSTSLCHOST\_SLC1\_TOKEN1 stores the accumulated number of available buffers. The host can figure out the available buffer space, using the register value minus the number of buffers already used. If the buffers are not enough, the host needs to constantly poll the register until there are enough buffers available.

During the transmission of packets to the slave through the CMD53 command, when a buffer specified by a linked list descriptor is written full, or when a packet transmission ends, the DMA will jump to the next buffer to store subsequent data. When the slave determines that the valid data of the current packet is over, the remaining data will be considered invalid and discarded, DMA will write back the current linked list descriptor, set the eof bit of the current descriptor to 1, and the SLC0/1\_TX\_SUC \_EOF\_INT interrupt will be generated.

For more information about DMA functions, linked list, and data discarding, please refer to Section 34.5.5 .

To ensure sufficient receiving buffers, the slave CPU must constantly load buffers on the receiving linked list. The process is shown in Figure 34.7-3 .

![Image](images/34_Chapter_34_img016_eef8a84b.png)

Figure 34.7-3. Loading Receiving Buffer

![Image](images/34_Chapter_34_img017_afa94211.png)

The CPU first needs to append new buffer segments at the end of the linked list that is being used by DMA and is available for receiving data.

The CPU then needs to notify the DMA that the linked list has been updated. This can be done by setting SDIO\_SLC0\_TXLINK\_RESTART or SDIO\_SLC1\_TXLINK\_RESTART. Please note that when the CPU initiates DMA to receive packets for the first time, SDIO\_SLC0\_TXLINK\_START or SDIO\_SLC1\_TXLINK\_START should be set to 1.

Notes: Use the *\_RESTART field to restart DMA only in the two scenarios:

- DMA is suspended by configuration of the *\_STOP field.
- DMA is suspended as a result of insufficient linked list descriptors. Users can restart it after descriptors are added.

Lastly, the CPU refreshes any available buffer information by writing to the SDIO\_SLC0TOKEN1\_REG or SDIO\_SLC1TOKEN1\_REG register.

![Image](images/34_Chapter_34_img018_0163d85b.png)

## 34.8 Register Summary

The addresses in this section are relative to SDIO Slave Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

## 34.8.1 HINF Register Summary

| Name                         | Description                        | Address                 | Access                  |
|------------------------------|------------------------------------|-------------------------|-------------------------|
| Configuration registers      | Configuration registers            | Configuration registers | Configuration registers |
| HINF_CFG_DATA0_REG           | SDIO CIS configuration             | 0x0000                  | R/W                     |
| HINF_CFG_DATA1_REG           | SDIO configuration                 | 0x0004                  | R/W                     |
| HINF_CFG_DATA7_REG           | SDIO configuration                 | 0x001C                  | varies                  |
| HINF_CIS_CONF_Wn_REG(n: 0-7) | SDIO CIS configuration             | 0x0020+0x4*n            | R/W                     |
| HINF_CFG_DATA16_REG          | SDIO CIS configuration             | 0x0040                  | R/W                     |
| Status registers             | Status registers                   | Status registers        | Status registers        |
| HINF_CONF_STATUS_REG         | SDIO CIS function 0 config0 status | 0x0054                  | RO                      |

## 34.8.2 SLC Register Summary

| Name                            | Description                              | Address   | Access   |
|---------------------------------|------------------------------------------|-----------|----------|
| Configuration registers         |                                          |           |          |
| SDIO_SLCCONF0_REG               | DMA configuration                        | 0x0000    | R/W      |
| SDIO_SLC0RX_LINK_REG            | SCL0 RX linked list configuration        | 0x003C    | varies   |
| SDIO_SLC0RX_LINK_ADDR_REG       | SCL0 RX linked list address              | 0x0040    | R/W      |
| SDIO_SLC0TX_LINK_REG            | SCL0 TX linked list configuration        | 0x0044    | varies   |
| SDIO_SLC0TX_LINK_ADDR_REG       | SCL0 TX linked list address              | 0x0048    | R/W      |
| SDIO_SLC1RX_LINK_REG            | SCL1 RX linked list configuration        | 0x004C    | varies   |
| SDIO_SLC1RX_LINK_ADDR_REG       | SCL1 RX linked list address              | 0x0050    | R/W      |
| SDIO_SLC1TX_LINK_REG            | SCL1 TX linked list configuration        | 0x0054    | varies   |
| SDIO_SLC1TX_LINK_ADDR_REG       | SCL1 TX linked list address              | 0x0058    | R/W      |
| SDIO_SLC0TOKEN1_REG             | SLC0 receiving buffer configuration      | 0x0064    | varies   |
| SDIO_SLC1TOKEN1_REG             | SLC1 receiving buffer configuration      | 0x006C    | varies   |
| SDIO_SLCCONF1_REG               | DMA configuration                        | 0x0070    | R/W      |
| SDIO_SLC_RX_DSCR_CONF_REG       | DMA slave to host configuration register | 0x00A8    | R/W      |
| SDIO_SLC0_LEN_CONF_REG          | Length control of transmitting packets   | 0x00F4    | varies   |
| SDIO_SLC0_TX_SHAREMEM_START_REG | SLC0 AHB TX start address range          | 0x0154    | R/W      |
| SDIO_SLC0_TX_SHAREMEM_END_REG   | SLC0 AHB TX end address range            | 0x0158    | R/W      |
| SDIO_SLC0_RX_SHAREMEM_START_REG | SLC0 AHB RX start address range          | 0x015C    | R/W      |
| SDIO_SLC0_RX_SHAREMEM_END_REG   | SLC0 AHB RX end address range            | 0x0160    | R/W      |
| SDIO_SLC1_TX_SHAREMEM_START_REG | SLC1 AHB TX start address range          | 0x0164    | R/W      |
| SDIO_SLC1_TX_SHAREMEM_END_REG   | SLC1 AHB TX end address range            | 0x0168    | R/W      |
| SDIO_SLC1_RX_SHAREMEM_START_REG | SLC1 AHB RX start address range          | 0x016C    | R/W      |

| Name                          | Description                           | Address   | Access   |
|-------------------------------|---------------------------------------|-----------|----------|
| SDIO_SLC1_RX_SHAREMEM_END_REG | SLC1 AHB RX end address range         | 0x0170    | R/W      |
| SDIO_SLC_BURST_LEN_REG        | DMA AHB burst type configuration      | 0x017C    | R/W      |
| Interrupt registers           |                                       |           |          |
| SDIO_SLC0INT_RAW_REG          | SLC0 to slave raw interrupt status    | 0x0004    | varies   |
| SDIO_SLC0INT_ST_REG           | SLC0 to slave masked interrupt status | 0x0008    | RO       |
| SDIO_SLC0INT_ENA_REG          | SLC0 to slave interrupt enable        | 0x000C    | R/W      |
| SDIO_SLC0INT_CLR_REG          | SLC0 to slave interrupt clear         | 0x0010    | WT       |
| SDIO_SLC1INT_RAW_REG          | SLC1 to slave raw interrupt status    | 0x0014    | varies   |
| SDIO_SLC1INT_CLR_REG          | SLC1 to slave interrupt clear         | 0x0020    | WT       |
| SDIO_SLCINTVEC_TOHOST_REG     | Slave to host interrupt vector set    | 0x005C    | WT       |
| SDIO_SLC1INT_ST1_REG          | SLC1 to slave masked interrupt status | 0x014C    | RO       |
| SDIO_SLC1INT_ENA1_REG         | SLC1 to slave interrupt enable        | 0x0150    | R/W      |
| Status registers              |                                       |           |          |
| SDIO_SLC0_LENGTH_REG          | Length of transmitting packets        | 0x00F8    | RO       |

## 34.8.3 SLC Host Register Summary

| Name                               | Description                                    | Address      | Access   |
|------------------------------------|------------------------------------------------|--------------|----------|
| Configuration registers            |                                                |              |          |
| SLCHOST_CONF_REG                   | Edge configuration                             | 0x01F0       | R/W      |
| Interrupt registers                |                                                |              |          |
| SLCHOST_SLC0HOST_INT_RAW_REG       | SLC0 to host raw interrupt status              | 0x0050       | varies   |
| SLCHOST_SLC1HOST_INT_RAW_REG       | SLC1 to host raw interrupt status              | 0x0054       | varies   |
| SLCHOST_SLC0HOST_INT_ST_REG        | SLC0 to host masked interrupt status           | 0x0058       | RO       |
| SLCHOST_SLC1HOST_INT_ST_REG        | SLC1 to host masked interrupt sta tus         | 0x005C       | RO       |
| SLCHOST_CONF_W7_REG                | Host to slave interrupt vector set             | 0x008C       | R/W      |
| SLCHOST_SLC0HOST_INT_CLR_REG       | SLC0 to host interrupt clear                   | 0x00D4       | WT       |
| SLCHOST_SLC1HOST_INT_CLR_REG       | SLC1 to host interrupt clear                   | 0x00D8       | WT       |
| SLCHOST_SLC0HOST_FUNC1_INT_ENA_REG | SLC0 to host interrupt enable                  | 0x00DC       | R/W      |
| SLCHOST_SLC1HOST_FUNC1_INT_ENA_REG | SLC0 to host interrupt enable                  | 0x00E0       | R/W      |
| Status registers                   |                                                |              |          |
| SLCHOST_SLC0HOST_TOKEN_RDATA_REG   | Accumulated number of SLC0 re ceiving buffers | 0x0044       | RO       |
| SLCHOST_PKT_LEN_REG                | Length of the transmitting pack ets           | 0x0060       | RO       |
| SLCHOST_SLC1HOST_TOKEN_RDATA_REG   | Accumulated number of SLC1 re ceiving buffers | 0x00C4       | RO       |
| Communication Registers            |                                                |              |          |
| SLCHOST_CONF_Wn_REG(n: 0-2)        | Host and slave communication                   | 0x006C+0x4*n | R/W      |
| SLCHOST_CONF_W3_REG                | Host and slave communication                   | 0x0078       | R/W      |
| SLCHOST_CONF_W4_REG                | Host and slave communication                   | 0x007C       | R/W      |

| Name                         | Description                  | Address           | Access   |
|------------------------------|------------------------------|-------------------|----------|
| SLCHOST_CONF_W6_REG          | Host and slave communication | 0x0088            | R/W      |
| SLCHOST_CONF_Wn_REG(n: 8-15) | Host and slave communication | 0x009C+0x4*(n 8) | R/W      |

Submit Documentation Feedback

## 34.9 Registers

The addresses in this section are relative to SDIO Slave Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## 34.9.1 HINF Registers

Register 34.1. HINF\_CFG\_DATA0\_REG (0x0000)

![Image](images/34_Chapter_34_img019_15cb7d3b.png)

HINF\_DEVICE\_ID\_FN1 Configures device ID of function 1 in SDIO CIS. (R/W)

HINF\_USER\_ID\_FN1 Configures user ID of function 1 in SDIO CIS. (R/W)

## Register 34.2. HINF\_CFG\_DATA1\_REG (0x0004)

![Image](images/34_Chapter_34_img020_092eb574.png)

HINF\_SDIO\_IOREADY1 Configures the field IOR1 in SDIO CCCR and the field function 1 ready in SDIO CIS.

- 0: The function 1 is not ready
- 1: The function 1 is ready

Please refer to SDIO Specification for details.

(R/W)

HINF\_HIGHSPEED\_ENABLE Configures whether to support SHS in SDIO CCCR.

- 0: Not support High-Speed mode
- 1: Support High-Speed mode

Please refer to SDIO Specification for details.

(R/W)

HINF\_HIGHSPEED\_MODE Represents whether EHS status is enabled in SDIO CCCR.

- 0: Disabled
- 1: Enabled

Please refer to SDIO Specification for details.

(RO)

HINF\_SDIO\_CD\_ENABLE Configures whether to enable SDIO card detection.

- 0: Disable
- 1: Enable

(R/W)

HINF\_SDIO\_IOREADY2 Configures the field IOR2 in SDIO CCCR and the field function 2 ready in SDIO CIS.

- 0: The function 2 is not ready
- 1: The function 2 is ready

Please refer to SDIO Specification for details.

(R/W)

HINF\_IOENABLE2 Represents whether IOE2 is enabled in SDIO CCCR.

- 0: The function 2 is disabled
- 1: The function 2 is enabled

Please refer to SDIO Specification for details.

(RO)

Continued on the next page...

## Register 34.2. HINF\_CFG\_DATA1\_REG (0x0004)

## Continued from the previous page...

HINF\_CD\_DISABLE Represents whether CD is disabled in SDIO CCCR.

0: Enabled

1: Disabled

Please refer to SDIO Specification for details.

(RO)

HINF\_FUNC1\_EPS Represents function 1 EPS status in SDIO FBR.

- 0: The function 1 operates in Higher Current Mode
- 1: The function 1 works in Lower Current Mode

Please refer to SDIO Specification for details.

(RO)

## HINF\_EMP Represents EMPC status in SDIO CCCR.

- 0: Master Power Control is disabled
- 1: Master Power Control is enabled

Please refer to SDIO Specification for details.

(RO)

## HINF\_IOENABLE1 Represents IOE1 status in SDIO CCCR.

- 0: The function 1 is disabled
- 1: The function 1 is enabled

Please refer to SDIO Specification for details.

(RO)

HINF\_SDIO\_VER Configures SD bit[3:0], SDIO bit[3:0], CCCR bit[3:0] in SDIO CCCR.

HINF\_SDIO\_VER[11:8] mapping to SD bit[3:0]

HINF\_SDIO\_VER[7:4] mapping to SDIO bit[3:0]

HINF\_SDIO\_VER[3:0] mapping to CCCR bit[3:0]

Please refer to SDIO Specification for details.

(R/W)

## HINF\_FUNC2\_EPS Represents function 2 EPS status in SDIO FBR.

- 0: The function 2 operates in Higher Current Mode
- 1: The function 2 works in Lower Current Mode

Please refer to SDIO Specification for details.

(RO)

## Register 34.3. HINF\_CFG\_DATA7\_REG (0x001C)

![Image](images/34_Chapter_34_img021_0664a2d4.png)

HINF\_PIN\_STATE Configures SDIO CIS address 318 and 574. Please refer to SDIO Specification for details. (R/W)

HINF\_CHIP\_STATE Configures SDIO CIS address 312, 315, 568, and 571. Please refer to SDIO Specification for details. (R/W)

HINF\_SDIO\_RST Configures whether to reset the SDIO slave module.

0: No effect

1: Reset

(R/W)

HINF\_ESDIO\_DATA1\_INT\_EN Configures whether to enable SDIO interrupt on data1 line.

0: Disable

1: Enable

(R/W)

HINF\_SDIO\_WAKEUP\_CLR Configures whether to clear wake up signal after the chip is waken up by the SDIO slave.

0: No effect

1: Clear

(WT)

Register 34.4. HINF\_CIS\_CONF\_Wn\_REG(n: 0-7) (0x0020+0x4*n)

![Image](images/34_Chapter_34_img022_a1cbdf54.png)

HINF\_CIS\_CONF\_Wn Configures SDIO CIS address (39+4*n) ~ (36+4*n). Please refer to SDIO Specification for details. (R/W)

Register 34.5. HINF\_CFG\_DATA16\_REG (0x0040)

![Image](images/34_Chapter_34_img023_43e1ce60.png)

HINF\_FUNC0\_CONFIG0 Represents SDIO CIS function 0 config0 (addr: 0x20f0) status. Please refer to SDIO Specification for details. (RO)

## 34.9.2 SLC Registers

## Register 34.7. SDIO\_SLCCONF0\_REG (0x0000)

![Image](images/34_Chapter_34_img024_dddfad91.png)

- SDIO\_SLC0\_TX\_RST Configures whether to reset TX (host to slave) FSM (finite state machine) in
- SLC0.
- 0: No effect
- 1: Reset

(R/W)

SDIO\_SLC0\_RX\_RST Configures whether to reset RX (slave to host) FSM in SCL0.

- 0: No effect
- 1: Reset

(R/W)

- SDIO\_SLC0\_TX\_LOOP\_TEST Configures whether SCL0 loops around when the slave buffer finishes receiving packets from the host.
- 0: Not loop around
- 1: Loop around, and hardware will not change the owner bit in the linked list (R/W)
- SDIO\_SLC0\_RX\_LOOP\_TEST Configures whether SCL0 loops around when the slave buffer finishes sending packets to the host.
- 0: Not loop around
- 1: Loop around, and hardware will not change the owner bit in the linked list (R/W)

SDIO\_SLC0\_RX\_AUTO\_WRBACK Configures whether SCL0 changes the owner bit of RX linked list.

- 0: Not change
- 1: Change
- (R/W)

SDIO\_SLC0\_RX\_NO\_RESTART\_CLR Please initialize to 1, and do not modify it. (R/W)

- SDIO\_SLC0\_RXDSCR\_BURST\_EN Configures whether SCL0 can use AHB burst operation when reading the RX linked list from memory.
- 0: Only use single operation
- 1: Can use burst operation
- (R/W)

Continued on the next page...

## Register 34.7. SDIO\_SLCCONF0\_REG (0x0000)

## Continued from the previous page...

SDIO\_SLC0\_RXDATA\_BURST\_EN Configures whether SCL0 can use AHB burst operation when read data from memory.

0: Only use single operation

1: Can use burst operation

(R/W)

SDIO\_SLC0\_TXDSCR\_BURST\_EN Configures whether SCL0 can use AHB burst operation when read the TX linked list from memory.

- 0: Only use single operation
- 1: Can use burst operation

(R/W)

SDIO\_SLC0\_TXDATA\_BURST\_EN Configures whether SCL0 can use AHB burst operation when send data to memory.

- 0: Only use single operation
- 1: Can use burst operation

(R/W)

SDIO\_SLC0\_TOKEN\_AUTO\_CLR Please initialize to 0, and do not modify it. (R/W)

SDIO\_SLC1\_TX\_RST Configures whether to reset TX FSM in SLC1.

0: No effect

- 1: Reset

(R/W)

SDIO\_SLC1\_RX\_RST Configures whether to reset RX FSM in SLC1.

- 0: No effect
- 1: Reset

(R/W)

SDIO\_SLC1\_TX\_LOOP\_TEST Configures whether SCL1 loops around when the slave buffer finishes receiving packets from the host.

- 0: Not loop around

1: Loop around, and hardware will not change the owner bit in the linked list

(R/W)

SDIO\_SLC1\_RX\_LOOP\_TEST Configures whether SCL1 loops around when the slave buffer finishes sending packets to the host.

- 0: Not loop around

1: Loop around, and hardware will not change the owner bit in the linked list

(R/W)

Continued on the next page...

## Register 34.7. SDIO\_SLCCONF0\_REG (0x0000)

## Continued from the previous page...

SDIO\_SLC1\_RX\_AUTO\_WRBACK Configures whether SCL1 changes the owner bit of the RX linked list.

0: Not change

1: Change

(R/W)

SDIO\_SLC1\_RX\_NO\_RESTART\_CLR Please initialize to 1, and do not modify it. (R/W)

SDIO\_SLC1\_RXDSCR\_BURST\_EN Configures whether SCL1 can use AHB burst operation when read the RX linked list from memory.

0: Only use single operation

1: Can use burst operation

(R/W)

SDIO\_SLC1\_RXDATA\_BURST\_EN Configures whether SCL1 can use AHB burst operation when read- ing data from memory.

0: Only use single operation

1: Can use burst operation

(R/W)

SDIO\_SLC1\_TXDSCR\_BURST\_EN Configures whether SCL1 can use AHB burst operation when read the TX linked list from memory.

0: Only use single operation

1: Can use burst operation

(R/W)

SDIO\_SLC1\_TXDATA\_BURST\_EN Configures whether SCL1 can use AHB burst operation when send data to memory.

0: Only use single operation

1: Can use burst operation

(R/W)

SDIO\_SLC1\_TOKEN\_AUTO\_CLR Please initialize to 0, and do not modify it. (R/W)

## Register 34.8. SDIO\_SLC0RX\_LINK\_REG (0x003C)

![Image](images/34_Chapter_34_img025_476ad390.png)

SDIO\_SLC0\_RXLINK\_STOP Configures whether to stop SLC0 RX linked list operation.

- 0: No effect
- 1: Stop the operation
- (R/W/SC)

SDIO\_SLC0\_RXLINK\_START Configures whether to start SLC0 RX linked list operation from the address indicated by SDIO\_SLC0\_RXLINK\_ADDR.

- 0: No effect
- 1: Start the operation

(R/W/SC)

- SDIO\_SLC0\_RXLINK\_RESTART Configures whether to restart and continue SLC0 RX linked list op-

eration.

- 0: No effect
- 1: Restart the operation

(R/W/SC)

SDIO\_SLC0\_RXLINK\_PARK Represents SLC0 RX linked list FSM state.

- 0: The FSM not in idle state
- 1: The FSM in idle state

(RO)

Register 34.9. SDIO\_SLC0RX\_LINK\_ADDR\_REG (0x0040)

SDIO\_SLC0\_RXLINK\_ADDR

![Image](images/34_Chapter_34_img026_1842d8b7.png)

SDIO\_SLC0\_RXLINK\_ADDR Configures SLC0 RX linked list initial address. (R/W)

## Register 34.10. SDIO\_SLC0TX\_LINK\_REG (0x0044)

![Image](images/34_Chapter_34_img027_1c0accf4.png)

SDIO\_SLC0\_TXLINK\_STOP Configures whether to stop SLC0 TX linked list operation.

- 0: No effect
- 1: Stop the operation

(R/W/SC)

SDIO\_SLC0\_TXLINK\_START Configures whether to start SLC0 TX linked list operation from the address indicated by SDIO\_SLC0\_TXLINK\_ADDR.

- 0: No effect
- 1: Start the operation

(R/W/SC)

SDIO\_SLC0\_TXLINK\_RESTART Configures whether to restart and continue SLC0 TX linked list op- eration.

- 0: No effect
- 1: Restart the operation

(R/W/SC)

SDIO\_SLC0\_TXLINK\_PARK Represents SLC0 TX linked list FSM state.

- 0: The FSM not in idle state
- 1: The FSM in idle state

(RO)

Register 34.11. SDIO\_SLC0TX\_LINK\_ADDR\_REG (0x0048)

![Image](images/34_Chapter_34_img028_4d53f884.png)

SDIO\_SLC0\_TXLINK\_ADDR Configures SLC0 TX linked list initial address. (R/W)

## Register 34.12. SDIO\_SLC1RX\_LINK\_REG (0x004C)

![Image](images/34_Chapter_34_img029_f4147cd1.png)

SDIO\_SLC1\_RXLINK\_STOP Configures whether to stop SLC1 RX linked list operation.

- 0: No effect
- 1: Stop the operation

(R/W/SC)

SDIO\_SLC1\_RXLINK\_START Configures whether to start SLC1 RX linked list operation from the ad- dress indicated by SDIO\_SLC1\_RXLINK\_ADDR.

- 0: No effect
- 1: Start the operation

(R/W/SC)

SDIO\_SLC1\_RXLINK\_RESTART Configures whether to restart and continue SLC1 RX linked list oper- ation.

- 0: No effect
- 1: Restart the operation

(R/W/SC)

SDIO\_SLC1\_RXLINK\_PARK Represents SLC1 RX linked list FSM state.

- 0: The FSM not in idle state
- 1: The FSM in idle state

(RO)

Register 34.13. SDIO\_SLC1RX\_LINK\_ADDR\_REG (0x0050)

![Image](images/34_Chapter_34_img030_5281c0b8.png)

SDIO\_SLC1\_RXLINK\_ADDR Configures SLC1 RX linked list initial address. (R/W)

## Register 34.14. SDIO\_SLC1TX\_LINK\_REG (0x0054)

![Image](images/34_Chapter_34_img031_e05c529a.png)

SDIO\_SLC1\_TXLINK\_STOP Configures whether to stop SLC1 TX linked list operation.

- 0: No effect
- 1: Stop the operation

(R/W/SC)

SDIO\_SLC1\_TXLINK\_START Configures whether to start SLC1 TX linked list operation from the ad- dress indicated by SDIO\_SLC1\_TXLINK\_ADDR.

- 0: No effect
- 1: Start the operation

(R/W/SC)

SDIO\_SLC1\_TXLINK\_RESTART Configures whether to restart and continue SLC1 TX linked list oper- ation.

- 0: No effect
- 1: Restart the operation

(R/W/SC)

SDIO\_SLC1\_TXLINK\_PARK Represents SLC1 TX linked list FSM state.

- 0: The FSM not in idle state
- 1: The FSM in idle state

(RO)

Register 34.15. SDIO\_SLC1TX\_LINK\_ADDR\_REG (0x0058)

![Image](images/34_Chapter_34_img032_5431c6dc.png)

SDIO\_SLC1\_TXLINK\_ADDR Configures SLC1 TX linked list initial address. (R/W)

Register 34.16. SDIO\_SLC0TOKEN1\_REG (0x0064)

![Image](images/34_Chapter_34_img033_f1974e40.png)

SDIO\_SLC0\_TOKEN1\_WDATA Configures SLC0 token 1 value. (WT)

SDIO\_SLC0\_TOKEN1\_WR Configures this bit to 1 to write SDIO\_SLC0\_TOKEN1\_WDATA into SDIO\_SLC0\_TOKEN1. (WT)

SDIO\_SLC0\_TOKEN1\_INC Configures this bit to 1 to add 1 to SDIO\_SLC0\_TOKEN1. (WT)

SDIO\_SLC0\_TOKEN1\_INC\_MORE Configures this bit to 1 to add the value of SDIO\_SLC0\_TOKEN1\_WDATA to SDIO\_SLC0\_TOKEN1. (WT)

SDIO\_SLC0\_TOKEN1 Represents the SLC0 accumulated number of buffers for receiving packets. (RO)

Register 34.17. SDIO\_SLC1TOKEN1\_REG (0x006C)

![Image](images/34_Chapter_34_img034_28016f2c.png)

SDIO\_SLC1\_TOKEN1\_WDATA Configures SLC1 token1 value. (WT)

SDIO\_SLC1\_TOKEN1\_WR Configures this bit to 1 to write SDIO\_SLC1\_TOKEN1\_WDATA into SDIO\_SLC1\_TOKEN1. (WT)

SDIO\_SLC1\_TOKEN1\_INC Configures this bit to 1 to add 1 to SDIO\_SLC1\_TOKEN1. (WT)

SDIO\_SLC1\_TOKEN1\_INC\_MORE Configures this bit to 1 to add the value of SDIO\_SLC1\_TOKEN1\_WDATA to SDIO\_SLC1\_TOKEN1. (WT)

SDIO\_SLC1\_TOKEN1 Represents SLC1 accumulated number of buffers for receiving packets. (RO)

## Register 34.18. SDIO\_SLCCONF1\_REG (0x0070)

![Image](images/34_Chapter_34_img035_40df3763.png)

SDIO\_SDIO\_CMD\_HOLD\_EN Please initialize to 0, and do not modify it. (R/W)

SDIO\_SLC0\_LEN\_AUTO\_CLR Please initialize to 0, and do not modify it. (R/W)

SDIO\_SLC0\_TX\_STITCH\_EN Please initialize to 0, and do not modify it. (R/W)

SDIO\_SLC0\_RX\_STITCH\_EN Please initialize to 0, and do not modify it. (R/W)

SDIO\_HOST\_INT\_LEVEL\_SEL Configures the polarity of interrupt to host.

0: Low active

1: High active

(R/W)

SDIO\_SLC1\_TX\_STITCH\_EN Please initialize to 0, and do not modify it. (R/W)

SDIO\_SLC1\_RX\_STITCH\_EN Please initialize to 0, and do not modify it. (R/W)

## Register 34.19. SDIO\_SLC\_RX\_DSCR\_CONF\_REG (0x00A8)

![Image](images/34_Chapter_34_img036_f627548d.png)

SDIO\_SLC0\_TOKEN\_NO\_REPLACE Please initialize to 1, and do not modify it. (R/W)

Register 34.20. SDIO\_SLC0\_LEN\_CONF\_REG (0x00F4)

![Image](images/34_Chapter_34_img037_d74bb45a.png)

SDIO\_SLC0\_LEN\_WDATA Configures the length of the data that the slave wants to send. (WT)

SDIO\_SLC0\_LEN\_WR Configures this bit to 1 to write SDIO\_SLC0\_LEN\_WDATA into SDIO\_SLC0\_LEN and SLCHOST\_HOSTSLCHOST\_SLC0\_LEN. (WT)

SDIO\_SLC0\_LEN\_INC Configures this bit to 1 to add 1 to SDIO\_SLC0\_LEN and SL-CHOST\_HOSTSLCHOST\_SLC0\_LEN. (WT)

SDIO\_SLC0\_LEN\_INC\_MORE Configures this bit to 1 to add the value of SDIO\_SLC0\_LEN\_WDATA to SDIO\_SLC0\_LEN and SLCHOST\_HOSTSLCHOST\_SLC0\_LEN. (WT)

Register 34.21. SDIO\_SLC0\_TX\_SHAREMEM\_START\_REG (0x0154)

![Image](images/34_Chapter_34_img038_fd784ee8.png)

SDIO\_SDIO\_SLC0\_TX\_SHAREMEM\_START\_ADDR Configures SLC0 host to slave channel AHB start address boundary. (R/W)

Register 34.22. SDIO\_SLC0\_TX\_SHAREMEM\_END\_REG (0x0158)

![Image](images/34_Chapter_34_img039_2f704b4c.png)

SDIO\_SDIO\_SLC0\_TX\_SHAREMEM\_END\_ADDR Configures SLC0 host to slave channel AHB end address boundary. (R/W)

Register 34.23. SDIO\_SLC0\_RX\_SHAREMEM\_START\_REG (0x015C)

![Image](images/34_Chapter_34_img040_e3c7c254.png)

SDIO\_SDIO\_SLC0\_RX\_SHAREMEM\_START\_ADDR Configures SLC0 slave to host channel AHB start address boundary. (R/W)

Register 34.24. SDIO\_SLC0\_RX\_SHAREMEM\_END\_REG (0x0160)

![Image](images/34_Chapter_34_img041_e9318a98.png)

SDIO\_SDIO\_SLC0\_RX\_SHAREMEM\_END\_ADDR Configures SLC0 slave to host channel AHB end address boundary. (R/W)

Register 34.25. SDIO\_SLC1\_TX\_SHAREMEM\_START\_REG (0x0164)

![Image](images/34_Chapter_34_img042_f5fbe8ee.png)

SDIO\_SDIO\_SLC1\_TX\_SHAREMEM\_START\_ADDR Configures SLC1 host to slave channel AHB start address boundary. (R/W)

Register 34.26. SDIO\_SLC1\_TX\_SHAREMEM\_END\_REG (0x0168)

![Image](images/34_Chapter_34_img043_7233b00f.png)

SDIO\_SDIO\_SLC1\_TX\_SHAREMEM\_END\_ADDR Configures SLC1 host to slave channel AHB end address boundary. (R/W)

Register 34.27. SDIO\_SLC1\_RX\_SHAREMEM\_START\_REG (0x016C)

![Image](images/34_Chapter_34_img044_1c762d5d.png)

SDIO\_SDIO\_SLC1\_RX\_SHAREMEM\_START\_ADDR Configures SLC1 slave to host channel AHB start address boundary. (R/W)

## Register 34.28. SDIO\_SLC1\_RX\_SHAREMEM\_END\_REG (0x0170)

![Image](images/34_Chapter_34_img045_74120f9a.png)

SDIO\_SDIO\_SLC1\_RX\_SHAREMEM\_END\_ADDR Configures SLC1 slave to host channel AHB end address boundary. (R/W)

## Register 34.29. SDIO\_SLC\_BURST\_LEN\_REG (0x017C)

![Image](images/34_Chapter_34_img046_6f3c5711.png)

SDIO\_SLC0\_TXDATA\_BURST\_LEN Configures SLC0 host to slave channel AHB burst type.

- 0: Can use incr4
- 1: Can use incr8

(R/W)

- SDIO\_SLC0\_RXDATA\_BURST\_LEN Configures SLC0 slave to host channel AHB burst type.
- 0: Can use incr and incr4
- 1: Can use incr and incr8

(R/W)

SDIO\_SLC1\_TXDATA\_BURST\_LEN Configures SLC1 host to slave channel AHB burst type.

- 0: Can use incr4
- 1: Can use incr8

(R/W)

SDIO\_SLC1\_RXDATA\_BURST\_LEN Configures SLC1 slave to host channel AHB burst type.

- 0: Can use incr and incr4
- 1: Can use incr and incr8
- (R/W)

Register 34.30. SDIO\_SLC0INT\_RAW\_REG (0x0004)

![Image](images/34_Chapter_34_img047_f0f77f57.png)

SDIO\_SLC\_FRHOST\_BITn\_INT\_RAW (n: 0-7) The raw interrupt status of SLC\_FRHOST\_BITn\_INT (n: 0-7). (R/WTC/SS)

SDIO\_SLC0\_RX\_START\_INT\_RAW The raw interrupt status of SLC0\_RX\_START\_INT. (R/WTC/SS) SDIO\_SLC0\_TX\_START\_INT\_RAW The raw interrupt status of SLC0\_TX\_START\_INT. (R/WTC/SS) SDIO\_SLC0\_RX\_UDF\_INT\_RAW The raw interrupt status of SLC0\_RX\_UDF\_INT. (R/WTC/SS) SDIO\_SLC0\_TX\_OVF\_INT\_RAW The raw interrupt status of SLC0\_TX\_OVF\_INT. (R/WTC/SS) SDIO\_SLC0\_TX\_DONE\_INT\_RAW The raw interrupt status of SLC0\_TX\_DONE\_INT. (R/WTC/SS) SDIO\_SLC0\_TX\_SUC\_EOF\_INT\_RAW The raw interrupt status of SLC0\_TX\_SUC\_EOF\_INT . (R/WTC/SS) SDIO\_SLC0\_RX\_DONE\_INT\_RAW The raw interrupt status of SLC0\_RX\_DONE\_INT. (R/WTC/SS) SDIO\_SLC0\_RX\_EOF\_INT\_RAW The raw interrupt status of SLC0\_RX\_EOF\_INT. (R/WTC/SS)

SDIO\_SLC0\_TX\_DSCR\_ERR\_INT\_RAW The raw interrupt status of SLC0\_TX\_DSCR\_ERR\_INT . (R/WTC/SS)

SDIO\_SLC0\_RX\_DSCR\_ERR\_INT\_RAW The raw interrupt status of SLC0\_RX\_DSCR\_ERR\_INT . (R/WTC/SS)

Register 34.31. SDIO\_SLC0INT\_ST\_REG (0x0008)

![Image](images/34_Chapter_34_img048_95468537.png)

SDIO\_SLC\_FRHOST\_BITn\_INT\_ST (n: 0-7) The masked interrupt status of SLC\_FRHOST\_BITn\_INT (n: 0-7). (RO)

SDIO\_SLC0\_RX\_START\_INT\_ST The masked interrupt status of SLC0\_RX\_START\_INT. (RO)

SDIO\_SLC0\_TX\_START\_INT\_ST The masked interrupt status bit of SLC0\_TX\_START\_INT. (RO)

SDIO\_SLC0\_RX\_UDF\_INT\_ST The masked interrupt status of SLC0\_RX\_UDF\_INT. (RO)

SDIO\_SLC0\_TX\_OVF\_INT\_ST The masked interrupt status of SLC0\_TX\_OVF\_INT. (RO)

SDIO\_SLC0\_TX\_DONE\_INT\_ST The masked interrupt status of SLC0\_TX\_DONE\_INT. (RO)

SDIO\_SLC0\_TX\_SUC\_EOF\_INT\_ST The masked interrupt status of SLC0\_TX\_SUC\_EOF\_INT. (RO)

SDIO\_SLC0\_RX\_DONE\_INT\_ST The masked interrupt status of SLC0\_RX\_DONE\_INT. (RO)

SDIO\_SLC0\_RX\_EOF\_INT\_ST The masked interrupt status bit of SLC0\_RX\_EOF\_INT. (RO)

SDIO\_SLC0\_TX\_DSCR\_ERR\_INT\_ST The masked interrupt status of SLC0\_TX\_DSCR\_ERR\_INT . (RO)

SDIO\_SLC0\_RX\_DSCR\_ERR\_INT\_ST The masked interrupt status of SLC0\_RX\_DSCR\_ERR\_INT . (RO)

Register 34.32. SDIO\_SLC0INT\_ENA\_REG (0x000C)

![Image](images/34_Chapter_34_img049_4f47bff9.png)

SDIO\_SLC\_FRHOST\_BITn\_INT\_ENA (n: 0-7) Write 1 to enable interrupt SLC\_FRHOST\_BITn\_INT (n: 0-7). (R/W)

SDIO\_SLC0\_RX\_START\_INT\_ENA Write 1 to enable interrupt SLC0\_RX\_START\_INT. (R/W)

SDIO\_SLC0\_TX\_START\_INT\_ENA Write 1 to enable interrupt SLC0\_TX\_START\_INT. (R/W)

SDIO\_SLC0\_RX\_UDF\_INT\_ENA Write 1 to enable interrupt SLC0\_RX\_UDF\_INT. (R/W)

SDIO\_SLC0\_TX\_OVF\_INT\_ENA Write 1 to enable interrupt SLC0\_TX\_OVF\_INT. (R/W)

SDIO\_SLC0\_TX\_DONE\_INT\_ENA Write 1 to enable interrupt SLC0\_TX\_DONE\_INT. (R/W)

SDIO\_SLC0\_TX\_SUC\_EOF\_INT\_ENA Write 1 to enable interrupt SLC0\_TX\_SUC\_EOF\_INT. (R/W)

SDIO\_SLC0\_RX\_DONE\_INT\_ENA Write 1 to enable interrupt SLC0\_RX\_DONE\_INT. (R/W)

SDIO\_SLC0\_RX\_EOF\_INT\_ENA Write 1 to enable interrupt SLC0\_RX\_EOF\_INT. (R/W)

SDIO\_SLC0\_TX\_DSCR\_ERR\_INT\_ENA Write 1 to enable interrupt SLC0\_TX\_DSCR\_ERR\_INT. (R/W)

SDIO\_SLC0\_RX\_DSCR\_ERR\_INT\_ENA Write 1 to enable interrupt SLC0\_RX\_DSCR\_ERR\_INT. (R/W)

Register 34.33. SDIO\_SLC0INT\_CLR\_REG (0x0010)

![Image](images/34_Chapter_34_img050_fca35308.png)

SDIO\_SLC\_FRHOST\_BITn\_INT\_CLR (n: 0-7) Write 1 to clear interrupt SLC\_FRHOST\_BITn\_INT (n: 07).(WT)

SDIO\_SLC0\_RX\_START\_INT\_CLR Write 1 to clear interrupt SLC0\_RX\_START\_INT. (WT)

SDIO\_SLC0\_TX\_START\_INT\_CLR Write 1 to clear interrupt SLC0\_TX\_START\_INT. (WT) SDIO\_SLC0\_RX\_UDF\_INT\_CLR Write 1 to clear interrupt SLC0\_RX\_UDF\_INT. (WT) SDIO\_SLC0\_TX\_OVF\_INT\_CLR Write 1 to clear interrupt SLC0\_TX\_OVF\_INT. (WT) SDIO\_SLC0\_TX\_DONE\_INT\_CLR Write 1 to clear interrupt SLC0\_TX\_DONE\_INT. (WT) SDIO\_SLC0\_TX\_SUC\_EOF\_INT\_CLR Write 1 to clear interrupt SLC0\_TX\_SUC\_EOF\_INT. (WT) SDIO\_SLC0\_RX\_DONE\_INT\_CLR Write 1 to clear interrupt SLC0\_RX\_DONE\_INT. (WT)

SDIO\_SLC0\_RX\_EOF\_INT\_CLR Write 1 to clear interrupt SLC0\_RX\_EOF\_INT. (WT)

SDIO\_SLC0\_TX\_DSCR\_ERR\_INT\_CLR Write 1 to clear interrupt SLC0\_TX\_DSCR\_ERR\_INT. (WT)

SDIO\_SLC0\_RX\_DSCR\_ERR\_INT\_CLR Write 1 to clear interrupt SLC0\_RX\_DSCR\_ERR\_INT. (WT)

## Register 34.34. SDIO\_SLC1INT\_RAW\_REG (0x0014)

![Image](images/34_Chapter_34_img051_9fca8e80.png)

SDIO\_SLC\_FRHOST\_BITn\_INT\_RAW (n: 8-15) The raw interrupt status of SLC\_FRHOST\_BITn\_INT (n: 8-15). (R/WTC/SS)

SDIO\_SLC1\_RX\_START\_INT\_RAW The raw interrupt status of SLC1\_RX\_START\_INT. (R/WTC/SS)

SDIO\_SLC1\_TX\_START\_INT\_RAW The raw interrupt status of SLC1\_TX\_START\_INT. (R/WTC/SS)

SDIO\_SLC1\_RX\_UDF\_INT\_RAW The raw interrupt status of SLC1\_RX\_UDF\_INT. (R/WTC/SS)

SDIO\_SLC1\_TX\_OVF\_INT\_RAW The raw interrupt status of SLC1\_TX\_OVF\_INT. (R/WTC/SS)

SDIO\_SLC1\_TX\_DONE\_INT\_RAW The raw interrupt status of SLC1\_TX\_DONE\_INT. (R/WTC/SS)

SDIO\_SLC1\_TX\_SUC\_EOF\_INT\_RAW The raw interrupt status of SLC1\_TX\_SUC\_EOF\_INT . (R/WTC/SS)

SDIO\_SLC1\_RX\_DONE\_INT\_RAW The raw interrupt status of SLC1\_RX\_DONE\_INT. (R/WTC/SS)

SDIO\_SLC1\_RX\_EOF\_INT\_RAW The raw interrupt status of SLC1\_RX\_EOF\_INT. (R/WTC/SS)

SDIO\_SLC1\_TX\_DSCR\_ERR\_INT\_RAW The raw interrupt status of SLC1\_TX\_DSCR\_ERR\_INT . (R/WTC/SS)

SDIO\_SLC1\_RX\_DSCR\_ERR\_INT\_RAW The raw interrupt status of SLC1\_RX\_DSCR\_ERR\_INT . (R/WTC/SS)

Register 34.35. SDIO\_SLC1INT\_CLR\_REG (0x0020)

![Image](images/34_Chapter_34_img052_1c0f77a9.png)

SDIO\_SLC\_FRHOST\_BITn\_INT\_CLR (n: 8-15) Write 1 to clear interrupt SLC\_FRHOST\_BITn\_INT (n: 8-15). (WT)

SDIO\_SLC1\_RX\_START\_INT\_CLR Write 1 to clear interrupt SLC1\_RX\_START\_INT. (WT)

SDIO\_SLC1\_TX\_START\_INT\_CLR Write 1 to clear interrupt SLC1\_TX\_START\_INT. (WT)

SDIO\_SLC1\_RX\_UDF\_INT\_CLR Write 1 to clear interrupt SLC1\_RX\_UDF\_INT. (WT)

SDIO\_SLC1\_TX\_OVF\_INT\_CLR Write 1 to clear interrupt SLC1\_TX\_OVF\_INT. (WT)

SDIO\_SLC1\_TX\_DONE\_INT\_CLR Write 1 to clear interrupt SLC1\_TX\_DONE\_INT. (WT)

SDIO\_SLC1\_TX\_SUC\_EOF\_INT\_CLR Write 1 to clear interrupt SLC1\_TX\_SUC\_EOF\_INT. (WT)

SDIO\_SLC1\_RX\_DONE\_INT\_CLR Write 1 to clear interrupt SLC1\_RX\_DONE\_INT. (WT)

SDIO\_SLC1\_RX\_EOF\_INT\_CLR Write 1 to clear interrupt SLC1\_RX\_EOF\_INT. (WT)

SDIO\_SLC1\_TX\_DSCR\_ERR\_INT\_CLR Write 1 to clear interrupt SLC1\_TX\_DSCR\_ERR\_INT. (WT)

SDIO\_SLC1\_RX\_DSCR\_ERR\_INT\_CLR Write 1 to clear interrupt SLC1\_RX\_DSCR\_ERR\_INT. (WT)

Register 34.36. SDIO\_SLCINTVEC\_TOHOST\_REG (0x005C)

![Image](images/34_Chapter_34_img053_00ab2562.png)

SDIO\_SLC0\_TOHOST\_INTVEC The interrupt set bit of SLCHOST\_SLC0\_TOHOST\_BITn\_INT (n: 0-7) . These bits will be cleared automatically. (WT)

SDIO\_SLC1\_TOHOST\_INTVEC The interrupt set bit of SLCHOST\_SLC1\_TOHOST\_BITn\_INT (n: 0-7) . These bits will be cleared automatically. (WT)

Register 34.37. SDIO\_SLC1INT\_ST1\_REG (0x014C)

![Image](images/34_Chapter_34_img054_7d388b55.png)

SLC\_FRHOST\_BITn\_INT (n: 8-15). (RO)

SDIO\_SLC1\_RX\_START\_INT\_ST1 The masked interrupt status of SLC1\_RX\_START\_INT. (RO) SDIO\_SLC1\_TX\_START\_INT\_ST1 The masked interrupt status of SLC1\_TX\_START\_INT. (RO) SDIO\_SLC1\_RX\_UDF\_INT\_ST1 The masked interrupt status of SLC1\_RX\_UDF\_INT. (RO) SDIO\_SLC1\_TX\_OVF\_INT\_ST1 The masked interrupt status of SLC1\_TX\_OVF\_INT. (RO) SDIO\_SLC1\_TX\_DONE\_INT\_ST1 The masked interrupt status of SLC1\_TX\_DONE\_INT. (RO) SDIO\_SLC1\_TX\_SUC\_EOF\_INT\_ST1 The masked interrupt status of SLC1\_TX\_SUC\_EOF\_INT. (RO) SDIO\_SLC1\_RX\_DONE\_INT\_ST1 The masked interrupt status of SLC1\_RX\_DONE\_INT. (RO) SDIO\_SLC1\_RX\_EOF\_INT\_ST1 The masked interrupt status of SLC1\_RX\_EOF\_INT. (RO)

SDIO\_SLC1\_TX\_DSCR\_ERR\_INT\_ST1 The masked interrupt status of SLC1\_TX\_DSCR\_ERR\_INT . (RO)

SDIO\_SLC1\_RX\_DSCR\_ERR\_INT\_ST1 The masked interrupt status of SLC1\_RX\_DSCR\_ERR\_INT . (RO)

Register 34.38. SDIO\_SLC1INT\_ENA1\_REG (0x0150)

![Image](images/34_Chapter_34_img055_a7a2807f.png)

SDIO\_SLC\_FRHOST\_BITn\_INT\_ENA1 (n: 8-15) Write 1 to enable interrupt SLC\_FRHOST\_BITn\_INT (n: 8-15). (R/W)

SDIO\_SLC1\_RX\_START\_INT\_ENA1 Write 1 to enable interrupt SLC1\_RX\_START\_INT. (R/W)

SDIO\_SLC1\_TX\_START\_INT\_ENA1 Write 1 to enable interrupt SLC1\_TX\_START\_INT. (R/W)

SDIO\_SLC1\_RX\_UDF\_INT\_ENA1 Write 1 to enable interrupt SLC1\_RX\_UDF\_INT. (R/W)

SDIO\_SLC1\_TX\_OVF\_INT\_ENA1 Write 1 to enable interrupt SLC1\_TX\_OVF\_INT. (R/W)

SDIO\_SLC1\_TX\_DONE\_INT\_ENA1 Write 1 to enable interrupt SLC1\_TX\_DONE\_INT. (R/W)

SDIO\_SLC1\_TX\_SUC\_EOF\_INT\_ENA1 Write 1 to enable interrupt SLC1\_TX\_SUC\_EOF\_INT. (R/W)

SDIO\_SLC1\_RX\_DONE\_INT\_ENA1 Write 1 to enable interrupt SLC1\_RX\_DONE\_INT. (R/W)

SDIO\_SLC1\_RX\_EOF\_INT\_ENA1 Write 1 to enable interrupt SLC1\_RX\_EOF\_INT. (R/W)

SDIO\_SLC1\_TX\_DSCR\_ERR\_INT\_ENA1 Write 1 to enable interrupt SLC1\_TX\_DSCR\_ERR\_INT. (R/W)

SDIO\_SLC1\_RX\_DSCR\_ERR\_INT\_ENA1 Write 1 to enable interrupt SLC1\_RX\_DSCR\_ERR\_INT. (R/W)

Register 34.39. SDIO\_SLC0\_LENGTH\_REG (0x00F8)

![Image](images/34_Chapter_34_img056_4e0ba3c3.png)

SDIO\_SLC0\_LEN Represents the accumulated length of data that the slave wants to send. (RO)

## 34.9.3 SLC Host Registers

Register 34.40. SLCHOST\_CONF\_REG (0x01F0)

![Image](images/34_Chapter_34_img057_b0bfb764.png)

- SLCHOST\_FRC\_SDIO11 Configure 1 to bit[4] to force drive CMD signal at the falling clock edge. Configures 1 to bit[3:0] corresponding bit to force drive DAT[3:0] signal corresponding bit at the falling clock edge. (R/W)
- SLCHOST\_FRC\_SDIO20 Configure 1 to bit[4] to force drive CMD signal at the rising clock edge. Configures 1 to bit[3:0] corresponding bit to force drive DAT[3:0] signal corresponding bit at the rising clock edge. (R/W)
- SLCHOST\_FRC\_NEG\_SAMP Configure 1 to bit[4] to force sample CMD signal at the falling clock edge. Configures 1 to bit[3:0] corresponding bit to force sample DAT[3:0] signal corresponding bit at the falling clock edge. (R/W)
- SLCHOST\_FRC\_POS\_SAMP Configure 1 to bit[4] to force sample CMD signal at the rising clock edge. Configures 1 to bit[3:0] corresponding bit to force sample DAT[3:0] signal corresponding bit at the rising clock edge. (R/W)
- SLCHOST\_HSPEED\_CON\_EN Configures 1 to this bit, configures 1 to HINF\_HIGHSPEED\_ENABLE , and then the host configures 1 to EHS in CCCR to force drive CMD and DAT signals at the rising clock edge. (R/W)

Register 34.41. SLCHOST\_SLC0HOST\_INT\_RAW\_REG (0x0050)

![Image](images/34_Chapter_34_img058_d30dcb3d.png)

SLCHOST\_SLC0\_TOHOST\_BITn\_INT\_RAW (n: 0-7) The raw interrupt status of SL-CHOST\_SLC0\_TOHOST\_BITn\_INT (n: 0-7). (R/WTC/SS)

SLCHOST\_SLC0\_RX\_UDF\_INT\_RAW The raw interrupt status of SLCHOST\_SLC0\_RX\_UDF\_INT . (R/WTC/SS)

SLCHOST\_SLC0\_TX\_OVF\_INT\_RAW The raw interrupt status of SLCHOST\_SLC0\_TX\_OVF\_INT . (R/WTC/SS)

SLCHOST\_SLC0\_RX\_NEW\_PACKET\_INT\_RAW The raw interrupt status of SL-CHOST\_SLC0\_RX\_NEW\_PACKET\_INT. (R/WTC/SS)

## Register 34.42. SLCHOST\_SLC1HOST\_INT\_RAW\_REG (0x0054)

![Image](images/34_Chapter_34_img059_af107d4d.png)

SLCHOST\_SLC1\_TOHOST\_BITn\_INT\_RAW (n: 0-7) The raw interrupt status of SL-CHOST\_SLC1\_TOHOST\_BITn\_INT (n: 0-7). (R/WTC/SS)

SLCHOST\_SLC1\_RX\_UDF\_INT\_RAW The raw interrupt status of SLCHOST\_SLC1\_RX\_UDF\_INT . (R/WTC/SS)

SLCHOST\_SLC1\_TX\_OVF\_INT\_RAW The raw interrupt status of SLCHOST\_SLC1\_TX\_OVF\_INT . (R/WTC/SS)

SLCHOST\_SLC1\_RX\_NEW\_PACKET\_INT\_RAW The raw interrupt status of SL-CHOST\_SLC1\_RX\_NEW\_PACKET\_INT. (R/WTC/SS)

Register 34.43. SLCHOST\_SLC0HOST\_INT\_ST\_REG (0x0058)

![Image](images/34_Chapter_34_img060_0a1745e4.png)

SLCHOST\_SLC0\_RX\_UDF\_INT\_ST The masked interrupt status of SLCHOST\_SLC0\_RX\_UDF\_INT . (RO)

- SLCHOST\_SLC0\_TX\_OVF\_INT\_ST The masked interrupt status of SLCHOST\_SLC0\_TX\_OVF\_INT . (RO)
- SLCHOST\_SLC0\_RX\_NEW\_PACKET\_INT\_ST The masked interrupt status of SL-CHOST\_SLC0\_RX\_NEW\_PACKET\_INT. (RO)

Register 34.44. SLCHOST\_SLC1HOST\_INT\_ST\_REG (0x005C)

![Image](images/34_Chapter_34_img061_9e18dfde.png)

SLCHOST\_SLC1\_RX\_UDF\_INT\_ST The masked interrupt status of SLCHOST\_SLC1\_RX\_UDF\_INT . (RO)

SLCHOST\_SLC1\_TX\_OVF\_INT\_ST The masked interrupt status of SLCHOST\_SLC1\_TX\_OVF\_INT. (RO)

SLCHOST\_SLC1\_RX\_NEW\_PACKET\_INT\_ST The masked interrupt status of SL-CHOST\_SLC1\_RX\_NEW\_PACKET\_INT. (RO)

## Register 34.45. SLCHOST\_CONF\_W7\_REG (0x008C)

![Image](images/34_Chapter_34_img062_b06d66b9.png)

SLCHOST\_SLCHOST\_CONF29 The interrupt set bits of SLCINT\_SLC\_FRHOST\_BITn\_INT (n: 0-7) . These bits will not be cleared automatically. (R/W)

SLCHOST\_SLCHOST\_CONF31 The interrupt set bits of SLCINT\_SLC\_FRHOST\_BITn\_INT (n: 8-15) . These bits will not be cleared automatically. (R/W)

Register 34.46. SLCHOST\_SLC0HOST\_INT\_CLR\_REG (0x00D4)

![Image](images/34_Chapter_34_img063_55757f98.png)

## Register 34.47. SLCHOST\_SLC1HOST\_INT\_CLR\_REG (0x00D8)

![Image](images/34_Chapter_34_img064_5af056cb.png)

Register 34.48. SLCHOST\_SLC0HOST\_FUNC1\_INT\_ENA\_REG (0x00DC)

![Image](images/34_Chapter_34_img065_5d777881.png)

Register 34.49. SLCHOST\_SLC1HOST\_FUNC1\_INT\_ENA\_REG (0x00E0)

![Image](images/34_Chapter_34_img066_a6c213a7.png)

Register 34.50. SLCHOST\_SLC0HOST\_TOKEN\_RDATA\_REG (0x0044)

![Image](images/34_Chapter_34_img067_149ea169.png)

SLCHOST\_HOSTSLCHOST\_SLC0\_TOKEN1 Represents the SLC0 accumulated number of buffers for receiving data. (RO)

Register 34.51. SLCHOST\_PKT\_LEN\_REG (0x0060)

![Image](images/34_Chapter_34_img068_672b95b8.png)

SLCHOST\_HOSTSLCHOST\_SLC0\_LEN Represents the accumulated length of data that the slave wants to send. The value gets updated only when the host reads it. (RO)

SLCHOST\_HOSTSLCHOST\_SLC0\_LEN\_CHECK Check SLCHOST\_HOSTSLCHOST\_SLC0\_LEN. Its value is SLCHOST\_HOSTSLCHOST\_SLC0\_LEN bit[9:0] plus bit[19:10]. (RO)

Register 34.52. SLCHOST\_SLC1HOST\_TOKEN\_RDATA\_REG (0x00C4)

![Image](images/34_Chapter_34_img069_1070984e.png)

SLCHOST\_HOSTSLCHOST\_SLC1\_TOKEN1 Represents the SLC1 accumulated number of buffers for receiving data. (RO)

![Image](images/34_Chapter_34_img070_36d40b90.png)

SLCHOST\_SLCHOST\_CONFn The information interaction register between the host and slave. Both of them can access it. (R/W)

Register 34.54. SLCHOST\_CONF\_W3\_REG (0x0078)

![Image](images/34_Chapter_34_img071_d67fedea.png)

SLCHOST\_SLCHOST\_CONF3 The information interaction register between the host and slave. Both of them can access it. (R/W)

Register 34.55. SLCHOST\_CONF\_W4\_REG (0x007C)

![Image](images/34_Chapter_34_img072_732d9139.png)

SLCHOST\_SLCHOST\_CONF4 The information interaction register between the host and slave. Both of them can access it. (R/W)

Register 34.56. SLCHOST\_CONF\_W6\_REG (0x0088)

![Image](images/34_Chapter_34_img073_5785b4a9.png)

SLCHOST\_SLCHOST\_CONF6 The information interaction register between the host and slave. Both of them can access it. (R/W)

Register 34.57. SLCHOST\_CONF\_Wn\_REG(n: 8-15) (0x009C+0x4*(n-8))

Fn

SLCHOST\_SLCHOST\_CONFn

![Image](images/34_Chapter_34_img074_dd07757b.png)

SLCHOST\_SLCHOST\_CONFn The information interaction register between the host and slave. Both of them can access it. (R/W)
