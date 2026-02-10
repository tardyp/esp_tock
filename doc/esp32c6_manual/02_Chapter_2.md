---
chapter: 2
title: "Chapter 2"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 2

## RISC-V Trace Encoder (TRACE)

fi

The high-performance CPU (HP CPU) of ESP32-C6 supports instruction trace interface through the trace encoder. The trace encoder connects to HP CPU's instruction trace interface, compresses the information into smaller packets, and then stores the packets in internal SRAM (see Chapter 5 System and Memory).

Figure 2.0-1. Trace Encoder Overview

![Image](images/02_Chapter_2_img001_21572572.png)

## 2.1 Terminology

To better illustrate the functions of the RISC-V Trace Encoder, the following terms are used in this chapter.

hart

RISC-V hardware thread

branch

an instruction which conditionally changes the execution flow

uninferable discontinuity

a program counter change that can not be inferred from the pro- gram binary alone

delta

a change in the program counter that is other than the difference between two instructions placed consecutively in memory

trap

the transfer of control to a trap handler caused by either an ex- ception or an interrupt

qualification

an instruction that meets the filtering criteria passes the qualifica-

tion, and will be traced

te\_inst

the name of the packet type emitted by the encoder

retire

the final stage of executing an instruction, when the machine state is updated

## 2.2 Introduction

In complex systems, understanding program execution flow is not straightforward. This may be due to a number of factors, for example, interactions with other cores, peripherals, real-time events, poor implementations, or some combination of all of the above.

It is hard to use a debugger to monitor the program execution flow of a running system in real time, as this is intrusive and might affect the running state. But providing visibility of program execution is important.

That is where instruction trace comes in, which provides trace of the program execution.

Figure 2.2-1. Trace Overview

![Image](images/02_Chapter_2_img002_1cfcc0fa.png)

Figure 2.2-1 shows the schematics of instruction trace:

- The HP CPU core provides an instruction trace interface that outputs the instruction information executed by the HP CPU. Such information includes instruction address, instruction type, etc. For more details about ESP32-C6 HP CPU's instruction trace interface, please refer to Chapter 1 High-Performance CPU .
- The trace encoder connects to the HP CPU's instruction trace interface and compresses the information into lower bandwidth packets, and then stores the packets in system memory.
- The debugger can dump the trace packets from the system memory via JTAG or USB Serial/JTAG, and use a decoder to decompress and reconstruct the program execution flow. The Trace Decoder, usually software on an external PC, takes in the trace packets and reconstructs the program instruction flow with the program binary that runs on the originating hart. This decoding step can be done offline or in real-time while the hart is executing.

This chapter mainly introduces the implementation details of ESP32-C6’s trace encoder.

## 2.3 Features

- Compatible with RISC-V Processor Trace Version 1.0. See Table 2.3-1 for the implemented parameters

- Arbitrary address range of the trace memory size
- Two synchronization modes:
- – synchronization counter counts by packet
- – synchronization counter counts by cycle
- Trace lost status to indicate packet loss
- Automatic restart after packet loss
- Memory writing in loop or non-loop mode
- Two interrupts:
- – Triggered when the packet size exceeds the configured memory space
- – Triggered when a packet is lost
- FIFO (128 × 8 bits) to buffer packets

Table 2.3-1. Trace Encoder Parameters

| Parameter Name      |   Value | Description                                                  |
|---------------------|---------|--------------------------------------------------------------|
| arch_p              |       0 | Initial version                                              |
| bpred_size_p        |       0 | Branch prediction mode is not supported                      |
| cache_size_p        |       0 | Jump target cache mode is not supported                      |
| call_counter_size_p |       0 | Implicit return mode is not supported                        |
| ctype_width_p       |       0 | Packets contain no context information                       |
| context_width_p     |       0 | Packets contain no context information                       |
| ecause_width_p      |       5 | Width of exception cause                                     |
| ecause_choice_p     |       0 | Multiple choice is not supported                             |
| f0s_width_p         |       0 | Format 0 packets are not supported                           |
| filter_context_p    |       0 | Filter function is not supported                             |
| filter_excint_p     |       0 | Filter function is not supported                             |
| filter_privilege_p  |       0 | Filter function is not supported                             |
| filter_tval_p       |       0 | Filter function is not supported                             |
| iaddress_lsb_p      |       1 | Compressed instructions are supported                        |
| iaddress_width_p    |      32 | The instruction bus is 32-bit                                |
| iretire_width_p     |       1 | Width of the iretire bus                                     |
| ilastsize_width_p   |       0 | Width of the ilastsize                                       |
| itype_width_p       |       3 | Width of the itype bus                                       |
| noncontext_p        |       1 | Exclude context from te_inst packets                         |
| privilege_width_p   |       1 | Only machine and user mode are supported                     |
| retires_p           |       1 | Maximum number of instructions that can be retired per block |
| return_stack_size_p |       0 | Implicit return mode is not supported                        |
| sijump_p            |       0 | Sequentially inferable jump mode is not supported            |
| taken_branches_p    |       1 | Only one instruction retired per cycle                       |
| impdef_width_p      |       0 | Not implemented                                              |

For detailed descriptions of the above parameters, please refer to the RISC-V Processor Trace Version 1.0 &gt; Chapter Parameters and Discovery.

## 2.4 Architectural Overview

As shown in Figure 2.0-1, the trace encoder contains an encoder, a FIFO, a register configuration module, and a transmission control module.

The encoder receives HP CPU's instruction information via the instruction trace interface, compresses it into different packets, and writes it to the internal FIFO.

The transmission control module writes the data in the FIFO to the internal SRAM through the AHB bus.

The FIFO is 128 deep and 8-bit wide. When the memory bandwidth is insufficient, the FIFO may overflow and packet loss occurs. If a packet is lost, the encoder will send a packet to tell that a packet is lost, and will stop working until the FIFO is empty.

## 2.5 Functional Description

## 2.5.1 Synchronization

In order to make the trace robust there must be regular synchronization points within the trace. Synchronization is accomplished by sending a full valued instruction address. When the synchronization counter value reaches the value of the TRACE\_RESYNC\_PROLONGED field of the TRACE\_RESYNC\_PROLONGED\_REG register, the encoder will send a synchronization packet (format 3 subformat 0, see Section 2.6.3.1).

There are two synchronization modes configured via TRACE\_RESYNC\_MODE:

- 0: Synchronization counter counts by cycle
- 1: Synchronization counter counts by packet

You can adjust the trace bandwidth by increasing the value of TRACE\_RESYNC\_PROLONGED\_REG to reduce the frequency of sending synchronization packets, thereby reducing the bandwidth occupied by packets.

## 2.5.2 Anchor Tag

Since the length of data packets is variable, in order to identify boundaries between data packets when packed packets are written to memory, ESP32-C6 inserts zero bytes between data packets:

- The maximum packet length is 13 bytes, so a sequence of at least 14 zero bytes cannot occur within a packet. Therefore, the first non-zero byte seen after a sequence of at least 14 zero bytes must be the first byte of a packet.
- Every time when 128 packets are transmitted, the encoder writes 14 zero bytes to the memory partition boundary as anchor tags.

## 2.5.3 Memory Writing Mode

When writing the trace memory, the size of the trace packets might exceed the capacity of the memory. In this case, you can choose whether to wrap around the trace memory or not by configuring the memory writing mode:

- Loop mode: When the size of the trace packets exceeds the capacity of the trace memory (namely when TRACE\_MEM\_CURRENT\_ADDR\_REG reaches the value of TRACE\_MEM\_END\_ADDR\_REG), the trace memory is wrapped around, so that the encoder loops back to the memory's starting address TRACE\_MEM\_START\_ADDR\_REG, and old data in the memory will be overwritten by new data.
- Non-loop mode: When the size of the trace packets exceeds the capacity of the trace memory, the trace memory is not wrapped around. The encoder stops at TRACE\_MEM\_END\_ADDR\_REG, and old data will be retained.

## 2.5.4 Automatic Restart

When packets are lost due to FIFO overflow, the encoder will stop working and need to be resumed by software. If the TRACE\_RESTART\_ENA bit of TRACE\_TRIGGER\_REG is set, once the FIFO is empty, the encoder can automatically be restarted and does not need to be resumed by software.

If the automatic restart feature is enabled, the encoder will be restarted in any case. Therefore, to disable the encoder, the automatic restart feature must be disabled first by clearing the TRACE\_RESTART\_ENA bit of the TRACE\_TRIGGER\_REG register.

## 2.6 Encoder Output Packets

This section mainly introduces ESP32-C6 trace encoder output packet format. ESP32-C6 only implements mandatory instruction delta tracing. It does not support the following optional features:

- Delta address mode (run-time configurable modes is supported)
- Context information and all context-related fields
- Optional sideband signals
- Trigger outputs from the Debug Module

For details about the above features, please refer RISC-V Processor Trace Version 1.0 (referred to below as the specification).

Figure 2.6-1. Trace packet Format

![Image](images/02_Chapter_2_img003_a0a95adf.png)

A packet includes header, index and payload. Header, index and payload are transmitted sequentially in bit stream form, from the fields listed at the top of tables below to the fields listed at the bottom. If a field consists

of multiple bits, then the least significant bit is transmitted first.

## 2.6.1 Header

Header is 1-byte long. The format of header is shown in Table 2.6-1 .

Table 2.6-1. Header Format

| Field       |   Bits | Description            | Value   |
|-------------|--------|------------------------|---------|
| length      |      5 | Length of whole packet | 4 ~ 13  |
| placeholder |      3 | Reserved               | 0       |

## 2.6.2 Index

Index has 2 bytes. The format of index is shown in Table 2.6-2 .

Table 2.6-2. Index Format

| Field   |   Bits | Description              | Value     |
|---------|--------|--------------------------|-----------|
| index   |     16 | The index of each packet | 0 ~ 65536 |

## 2.6.3 Payload

The length of payload ranges from 1 byte to 10 bytes.

## 2.6.3.1 Format 3 Packets

Format 3 packets are used for synchronization, and report supporting information. There are 4 subformats defined in the specification. ESP32-C6 only supports 3 of them.

## Format 3 Subformat 0 - Synchronization

This packet contains all the information the decoder needs to fully identify an instruction. It is sent for the first traced instruction (unless that instruction also happens to be a first in an exception handler), and when synchronization has been scheduled by expiry of the synchronization timer. The payload length is 5 bytes.

Table 2.6-3. Packet format 3 subformat 0

| Field name   |   Bits | Description                                                                                                                                                  |
|--------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| format       |      2 | 11 (sync): Synchronization                                                                                                                                   |
| subformat    |      2 | 00 (start): Start of tracing, or resync                                                                                                                      |
| branch       |      1 | Set to 0 if the address points to a branch instruction, and the branch was taken. Set to 1 if the instruction is not a branch or if the branch is not taken. |
| privilege    |      1 | The privilege level of the reported instruction                                                                                                              |
| address      |     31 | Full instruction address. The address must be left shifted 1 bit in order to recreate the original byte address.                                             |

| Field name   |   Bits | Description   |
|--------------|--------|---------------|
| sign_extend  |      3 | Reserved      |

## Format 3 Subformat 1 - Exception

This packet also contains all the information the decoder needs to fully identify an instruction. It is sent following an exception or interrupt, and includes the cause, the 'trap value' (for exceptions), and the address of the trap handler or of the exception itself. The length is 10 bytes.

Table 2.6-4. Packet format 3 subformat 1

| Field name   |   Bits | Description                                                                                                                                                  |
|--------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------|
| format       |      2 | 11 (sync): Synchronization                                                                                                                                   |
| subformat    |      2 | 01 (exception): Exception cause and trap handler address                                                                                                     |
| branch       |      1 | Set to 0 if the address points to a branch instruction, and the branch was taken. Set to 1 if the instruction is not a branch or if the branch is not taken. |
| privilege    |      1 | The privilege level of the reported instruction                                                                                                              |
| ecause       |      5 | Exception cause                                                                                                                                              |
| interrupt    |      1 | Interrupt                                                                                                                                                    |
| address      |     31 | Full instruction address. The value of this field must be left shifted 1 bit in order to recreate original byte address.                                     |
| tvalepc      |     32 | Exception address if ecause is 2 and interrupt is 0, or trap value otherwise                                                                                 |
| sign_extend  |      6 | Reserved                                                                                                                                                     |

## Format 3 Subformat 3 - Support

This packet provides supporting information to aid the decoder. It is issued when the trace is ended. The length is 1 byte.

Table 2.6-5. Packet format 3 subformat 3

| Field name   |   Bits | Description                                                                                                                                                                                                                                                                                                                                                                                                        |
|--------------|--------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| format       |      2 | 11 (sync): Synchronization                                                                                                                                                                                                                                                                                                                                                                                         |
| subformat    |      2 | 11 (support): Supporting information for the decoder                                                                                                                                                                                                                                                                                                                                                               |
| enable       |      1 | Indicates if the encoder is enabled                                                                                                                                                                                                                                                                                                                                                                                |
| qual_status  |      2 | Indicates qualification status: •  00 (no_change): No change to filter qualification •  01 (ended_rep): Qualification ended, preceding instruction sent explicitly to indicate last qualification instruction •  10 (trace lost): One or more packets lost •  11 (ended_upd): Qualification ended, preceding te_inst would have been sent anyway due to an updiscon, even if wasn’t the last qualified instruction |
| sign_extend  |      1 | Reserved                                                                                                                                                                                                                                                                                                                                                                                                           |

## 2.6.3.2 Format 2 Packets

This packet contains only an instruction address, and is used when the address of an instruction must be reported, and there is no reported branch information. The length is 5 bytes.

Table 2.6-6. Packet format 2

| Field name   |   Bits | Description                                                                                                                                                                                                                       |
|--------------|--------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| format       |      2 | 10 (addr-only): No branch information                                                                                                                                                                                             |
| address      |     31 | Full instruction address                                                                                                                                                                                                          |
| notify       |      1 | ESP32-C6 don’t support notification, so this bit is always same with the MSB of address.                                                                                                                                          |
| updiscon     |      1 | If the value of this bit is different from notify, it indicates that this packet is reporting the instruction following an uninferable discontinuity and is also the instruction before an exception, privilege change or resync. |
| sign_extend  |      5 |                                                                                                                                                                                                                                   |

## 2.6.3.3 Format 1 Packets

This packet includes branch information, and is used when either the branch information must be reported (for example because the branch map is full), or when the address of instruction must be reported, and there has must been at least one branch since the previous packet. This packet only supports full address mode.

## Format 1 - address, branch\_map

The length is variable.

Table 2.6-7. Packet format 1 with address

| Field name   | Bits     | Description                                                                                                                                                                                                                                                                                       |
|--------------|----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| format       | 2        | 01: Includes branch information                                                                                                                                                                                                                                                                   |
| branches     | 5        | Number of valid bits branch_map. The number of bits of branch_map is determined as follows: •  0: (cannot occur for this format) •  1: 1 bit •  2-3: 3 bits •  4-7: 7 bits •  8-15: 15 bits •  16-31: 31 bits For example if branches = 12, branch_map is 15-bit long, and the 12 LSBs are valid. |
| branch_map   | Variable | An array of bits indicating whether branches are taken or not. Bit 0 represents the oldest branch instruction executed. For each bit: •  0: branch taken •  1: branch not taken The field Bits is variable and determined by the branches field.                                                  |

| Field name   | Bits     | Description                                                                                                                                                                                                                       |
|--------------|----------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| address      | 31       | Full instruction address                                                                                                                                                                                                          |
| notify       | 1        | ESP32-C6 don’t support notification, so this bit is always same with the MSB of address.                                                                                                                                          |
| updiscon     | 1        | If the value of this bit is different from notify, it indicates that this packet is reporting the instruction following an uninferable discontinuity and is also the instruction before an exception, privilege change or resync. |
| sign_extend  | Variable | The field bits are determined by the branches. The number of bits of sign_extend is as follows: •  1: 7 bits •  2-3: 5 bits •  4-7: 1 bit •  8-15: 1 bit •  16-32: 31 bits                                                        |

## Format 1 - no address, branch\_map

The length is 5 bytes.

Table 2.6-8. Packet format 1 without address

| Field name   |   Bits | Description                                                                                                                                                                     |
|--------------|--------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| format       |      2 | 01: includes branch information                                                                                                                                                 |
| branches     |      5 | Number of valid bits in branch_map. The length of branch_map is 31 bits. Only 0 valid.                                                                                          |
| branch_map   |     31 | An array of bits indicating whether branches are taken or not. Bit 0 represents the oldest branch instruction executed. For each bit: •  0: branch taken •  1: branch not taken |
| sign_extend  |      2 | Reserved                                                                                                                                                                        |

## 2.7 Interrupt

- TRACE\_MEM\_FULL\_INTR: Triggered when the packet size exceeds the capacity of the trace memory, namely when TRACE\_MEM\_CURRENT\_ADDR\_REG reaches the value of TRACE\_MEM\_END\_ADDR\_REG . If necessary, this interrupt can be enabled to notify the HP CPU for processing, such as applying for a new memory space again.
- TRACE\_FIFO\_OVERFLOW\_INTR: Triggered when the internal FIFO overflows and one or more packets have been lost.

After enabling the trace encoder interrupts, map them to numbered CPU interrupts through the Interrupt Matrix, so that the HP CPU can respond to these trace encoder interrupts. For details, please refer to Chapter 10 Interrupt Matrix (INTMTX) .

## 2.8 Programming Procedures

## 2.8.1 Enable Encoder

- Configure the address space for the trace memory via TRACE\_MEM\_START\_ADDR\_REG and TRACE\_MEM\_END\_ADDR\_REG
- Update the value of TRACE\_MEM\_CURRENT\_ADDR\_REG to the value of TRACE\_MEM\_START\_ADDR\_REG by setting TRACE\_MEM\_CURRENT\_ADDR\_UPDATE
- (Optional) Configure the memory writing mode via the TRACE\_MEM\_LOOP bit of TRACE\_TRIGGER\_REG
- – 0: Non-loop mode
- – 1: Loop mode (default)
- Configure the synchronization mode via the TRACE\_RESYNC\_MODE bit of TRACE\_RESYNC\_PROLONGED\_REG
- – 0: count by cycle (default)
- – 1: count by packet
- (Optional) Configures the threshold for the synchronization counter (default value is 128) via TRACE\_RESYNC\_PROLONGED\_REG
- (Optional) Enable Interrupt
- – Set the corresponding bit of TRACE\_INTR\_ENA\_REG to enable the corresponding interrupt
- – Set the corresponding bit of TRACE\_INTR\_CLR\_REG to clear the corresponding interrupt
- – Read TRACE\_INTR\_RAW\_REG to know which interrupt occurs
- (Optional) Enable automatic restart by setting the TRACE\_RESTART\_ENA bit of TRACE\_TRIGGER\_REG . This function is enabled by default
- Enable the trace encoder by setting the TRACE\_TRIGGER\_ON field of TRACE\_TRIGGER\_REG

Once the encoder is enabled, it will keep tracing the HP CPU's instruction trace interface and writing packets to the trace memory.

## 2.8.2 Disable Encoder

- Disable automatic restart by clearing the TRACE\_RESTART\_ENA bit of TRACE\_TRIGGER\_REG
- Stop the encoder by setting the TRACE\_TRIGGER\_OFF bit of TRACE\_TRIGGER\_REG
- Confirm whether all data in the FIFO have been written into the memory by reading the TRACE\_FIFO\_EMPTY bit

## 2.8.3 Decode Data Packets

- Find the first address to decode
- – Read the TRACE\_MEM\_FULL\_INTR\_RAW bit of the TRACE\_INTR\_RAW\_REG register to know if the trace memory is full

* if read 0, read the trace packets from TRACE\_MEM\_START\_ADDR\_REG
* if read 1, and the loop mode is enabled, then the old trace packets are overwritten. In this case, read the TRACE\_MEM\_CURRENT\_ADDR\_REG to know the last writing address, and use this address as the first address to decode
- Use the decoder to decode data packets
- – The decoder reads all data packets starting from the first address, and reconstructs the data stream with the binary file
- – As mentioned in 2.6, the encoder writes 14 zero bytes to the memory partition boundary every time when 128 packets are transmitted. Given this fact, the first non-zero byte after 14 zero bytes should be the header of a new packet

## 2.9 Register Summary

The addresses in this section are relative to RISC-V Trace Encoder base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                            | Description                                     | Address   | Access   |
|-------------------------------------------------|-------------------------------------------------|-----------|----------|
| Memory configuration registers                  |                                                 |           |          |
| TRACE_MEM_START_ADDR_REG                        | Memory start address                            | 0x0000    | R/W      |
| TRACE_MEM_END_ADDR_REG                          | Memory end address                              | 0x0004    | R/W      |
| TRACE_MEM_CURRENT_ADDR_REG                      | Memory current address                          | 0x0008    | RO       |
| TRACE_MEM_ADDR_UPDATE_REG                       | Memory address update                           | 0x000C    | WT       |
| FIFO status register                            |                                                 |           |          |
| TRACE_FIFO_STATUS_REG                           | FIFO status register                            | 0x0010    | RO       |
| Interrupt registers                             |                                                 |           |          |
| TRACE_INTR_ENA_REG                              | Interrupt enable register                       | 0x0014    | R/W      |
| TRACE_INTR_RAW_REG                              | Interrupt raw status register                   | 0x0018    | RO       |
| TRACE_INTR_CLR_REG                              | Interrupt clear register                        | 0x001C    | WT       |
| Trace configuration registers                   |                                                 |           |          |
| TRACE_TRIGGER_REG                               | Trace enable register                           | 0x0020    | varies   |
| TRACE_RESYNC_PROLONGED_REG                      | Resynchronization configuration register        | 0x0024    | R/W      |
| Clock gating control and configuration register | Clock gating control and configuration register |           |          |
| TRACE_CLOCK_GATE_REG                            | Clock gating control register                   | 0x0028    | R/W      |
| Version register                                |                                                 |           |          |
| TRACE_DATE_REG                                  | Version control register                        | 0x03FC    | R/W      |

## 2.10 Registers

The addresses in this section are relative to RISC-V Trace Encoder base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 2.1. TRACE\_MEM\_START\_ADDR\_REG (0x0000)

![Image](images/02_Chapter_2_img004_51559a4c.png)

Register 2.4. TRACE\_MEM\_ADDR\_UPDATE\_REG (0x000C)

![Image](images/02_Chapter_2_img005_9f382ca5.png)

TRACE\_MEM\_CURRENT\_ADDR\_UPDATE Configures whether to update the current memory address to the start address of the memory.

- 0: Not update
- 1: Update
- (WT)

Register 2.5. TRACE\_FIFO\_STATUS\_REG (0x0010)

![Image](images/02_Chapter_2_img006_34440540.png)

TRACE\_FIFO\_EMPTY Represents the FIFO status.

- 0: Not empty
- 1: Empty
- (RO)

TRACE\_WORK\_STATUS Represents the encoder status.

- 0: Not tracing instruction.
- 1: Tracing instructions and reporting packets.

(RO)

![Image](images/02_Chapter_2_img007_f73e5a1f.png)

## Register 2.9. TRACE\_TRIGGER\_REG (0x0020)

![Image](images/02_Chapter_2_img008_f149e0ce.png)

TRACE\_TRIGGER\_ON Configures whether or not to enable the trace encoder.

- 0: Invalid. No effect
- 1: Enable

(WT)

TRACE\_TRIGGER\_OFF Configures whether to stop the trace encoder.

- 0: Invalid. No effect
- 1: Stop

(WT)

## TRACE\_MEM\_LOOP Configures memory mode.

- 0: Non-loop mode
- 1: Loop mode

(R/W)

TRACE\_RESTART\_ENA Configures whether or not to enable the automatic restart function for the encoder.

- 0: Disable
- 1: Enable

(R/W)

## Register 2.10. TRACE\_RESYNC\_PROLONGED\_REG (0x0024)

![Image](images/02_Chapter_2_img009_7e0ccd44.png)

TRACE\_RESYNC\_PROLONGED Configures the threshold for the synchronization counter. (R/W)

TRACE\_RESYNC\_MODE Configures the synchronization mode.

0: Count by cycle

1: Count by packet

(R/W)

Register 2.11. TRACE\_CLOCK\_GATE\_REG (0x0028)

![Image](images/02_Chapter_2_img010_b7b6e82d.png)

TRACE\_CLK\_EN Configures register clock gating. 0: Support clock only when the application writes registers to save power.

- 1: Always force the clock on for registers.

This bit doesn’t affect register access.

(R/W)

## Register 2.12. TRACE\_DATE\_REG (0x03FC)

![Image](images/02_Chapter_2_img011_eea4b6ed.png)

TRACE\_DATE Version control register. (R/W)
