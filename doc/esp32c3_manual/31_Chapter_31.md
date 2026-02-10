---
chapter: 31
title: "Chapter 31"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 31

## Two-wire Automotive Interface (TWAI)

The Two-wire Automotive Interface (TWAI®) is a multi-master, multi-cast communication protocol with functions such as error detection and signaling and inbuilt message priorities and arbitration. The TWAI protocol is suited for automotive and industrial applications (see Section 31.2 for more details).

ESP32-C3 contains a TWAI controller that can be connected to the TWAI bus via an external transceiver. The TWAI controller contains numerous advanced features, and can be utilized in a wide range of use cases such as automotive products, industrial automation controls, building automation, etc.

## 31.1 Features

The TWAI controller on ESP32-C3 supports the following features:

- Compatible with ISO 11898-1 protocol (CAN Specification 2.0)
- Supports Standard Frame Format (11-bit ID) and Extended Frame Format (29-bit ID)
- Bit rates from 1 Kbit/s to 1 Mbit/s
- Multiple modes of operation
- – Normal
- – Listen-only (no influence on bus)
- – Self-test (no acknowledgment required during data transmission)
- 64-byte Receive FIFO
- Special transmissions
- – Single-shot transmissions (does not automatically re-transmit upon error)
- – Self Reception (the TWAI controller transmits and receives messages simultaneously)
- Acceptance Filter (supports single and dual filter modes)
- Error detection and handling
- – Error Counters
- – Configurable Error Warning Limit
- – Error Code Capture
- – Arbitration Lost Capture

## 31.2 Functional Protocol

## 31.2.1 TWAI Properties

The TWAI protocol connects two or more nodes in a bus network, and allows nodes to exchange messages in a latency bounded manner. A TWAI bus has the following properties.

Single Channel and Non-Return-to-Zero: The bus consists of a single channel to carry bits, and thus communication is half-duplex. Synchronization is also implemented in this channel, so extra channels (e.g., clock or enable) are not required. The bit stream of a TWAI message is encoded using the Non-Return-to-Zero (NRZ) method.

Bit Values: The single channel can either be in a dominant or recessive state, representing a logical 0 and a logical 1 respectively. A node transmitting data in a dominant state always overrides the other node transmitting data in a recessive state. The physical implementation on the bus is left to the application level to decide (e.g., differential pair or a single wire).

Bit Stuffing: Certain fields of TWAI messages are bit-stuffed. A transmitter that transmits five consecutive bits of the same value (e.g., dominant value or recessive value) should automatically insert a complementary bit. Likewise, a receiver that receives five consecutive bits should treat the next bit as a stuffed bit. Bit stuffing is applied to the following fields: SOF, arbitration field, control field, data field, and CRC sequence (see Section 31.2.2 for more details).

Multi-cast: All nodes receive the same bits as they are connected to the same bus. Data is consistent across all nodes unless there is a bus error (see Section 31.2.3 for more details).

Multi-master: Any node can initiate a transmission. If a transmission is already ongoing, a node will wait until the current transmission is over before initiating a new transmission.

Message Priority and Arbitration: If two or more nodes simultaneously initiate a transmission, the TWAI protocol ensures that one node will win arbitration of the bus. The arbitration field of the message transmitted by each node is used to determine which node will win arbitration.

Error Detection and Signaling: Each node actively monitors the bus for errors, and signals the detected errors by transmitting an error frame.

Fault Confinement: Each node maintains a set of error counters that are incremented/decremented according to a set of rules. When the error counters surpass a certain threshold, the node will automatically eliminate itself from the network by switching itself off.

Configurable Bit Rate: The bit rate for a single TWAI bus is configurable. However, all nodes on the same bus must operate at the same bit rate.

Transmitters and Receivers: At any point in time, a TWAI node can either be a transmitter or a receiver.

- A node generating a message is a transmitter. The node remains a transmitter until the bus is idle or until the node loses arbitration. Please note that nodes that have not lost arbitration can all be transmitters.
- All nodes that are not transmitters are receivers.

## 31.2.2 TWAI Messages

TWAI nodes use messages to transmit data, and signal errors to other nodes when detecting errors on the bus. Messages are split into various frame types, and some frame types will have different frame formats.

The TWAI protocol has of the following frame types:

- Data frame
- Remote frame
- Error frame
- Overload frame
- Interframe space

The TWAI protocol has the following frame formats:

- Standard Frame Format (SFF) that uses a 11-bit identifier
- Extended Frame Format (EFF) that uses a 29-bit identifier

## 31.2.2.1 Data Frames and Remote Frames

Data frames are used by nodes to send data to other nodes, and can have a payload of 0 to 8 data bytes. Remote frames are used for nodes to request a data frame with the same identifier from other nodes, and thus they do not contain any data bytes. However, data frames and remote frames share many fields. Figure 31.2-1 illustrates the fields and sub-fields of different frames and formats.

## Arbitration Field

When two or more nodes transmits a data or remote frame simultaneously, the arbitration field is used to determine which node will win arbitration of the bus. In the arbitration field, if a node transmits a recessive bit while detects a dominant bit, this indicates that another node has overridden its recessive bit. Therefore, the node transmitting the recessive bit has lost arbitration of the bus and should immediately switch to be a receiver.

The arbitration field primarily consists of a frame identifier that is transmitted from the most significant bit first. Given that a dominant bit represents a logical 0, and a recessive bit represents a logical 1:

- A frame with the smallest ID value always wins arbitration.
- Given the same ID and format, data frames always prevail over remote frames due to their RTR bits being dominant.
- Given the same first 11 bits of ID, a Standard Format Data Frame always prevails over an Extended Format Data Frame due to its SRR bits being recessive.

## Control Field

The control field primarily consists of the DLC (Data Length Code) which indicates the number of payload data bytes for a data frame, or the number of requested data bytes for a remote frame. The DLC is transmitted from the most significant bit first.

## Data Field

The data field contains the actual payload data bytes of a data frame. Remote frames do not contain any data field.

## CRC Field

The CRC field primarily consists of a CRC sequence. The CRC sequence is a 15-bit cyclic redundancy code calculated form the de-stuffed contents (everything from the SOF to the end of the data field) of a data or remote frame.

## ACK Field

The ACK field primarily consists of an ACK Slot and an ACK Delim. The ACK field indicates that the receiver has received an effective message from the transmitter.

Table 31.2-1. Data Frames and Remote Frames in SFF and EFF

| Data/Remote Frames   | Description                                                                                                                                                                                                                             |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SOF                  | The SOF (Start of Frame) is a single dominant bit used to synchronize nodes on the bus.                                                                                                                                                 |
| Base ID              | The Base ID (ID.28 to ID.18) is the 11-bit identifier for SFF, or the first 11 bits of the 29-bit identifier for EFF.                                                                                                                   |
| RTR                  | The RTR (Remote Transmission Request) bit indicates whether the message is a data frame (dominant) or a remote frame (recessive). This means that a remote frame will always lose arbitration to a data frame if they have the same ID. |

Cont’d on next page

Figure 31.2-1. Bit Fields in Data Frames and Remote Frames

![Image](images/31_Chapter_31_img001_46047faa.png)

Table 31.2-1 – cont’d from previous page

| Data/Remote Frames   | Description                                                                                                                                                                                                                                                                                                                |
|----------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SRR                  | The SRR (Substitute Remote Request) bit is transmitted in EFF to substitute for the RTR bit at the same position in SFF.                                                                                                                                                                                                   |
| IDE                  | The IDE (Identifier Extension) bit indicates whether the message is SFF (domi nant) or EFF (recessive). This means that a SFF frame will always win arbitration over an EFF frame if they have the same Base ID.                                                                                                          |
| Extd ID              | The Extended ID (ID.17 to ID.0) is the remaining 18 bits of the 29-bit identifier for EFF.                                                                                                                                                                                                                                 |
| r1                   | The r1 bit (reserved bit 1) is always dominant.                                                                                                                                                                                                                                                                            |
| r0                   | The r0 bit (reserved bit 0) is always dominant.                                                                                                                                                                                                                                                                            |
| DLC                  | The DLC (Data Length Code) is 4-bit long and should contain any value from 0 to 8. Data frames use the DLC to indicate the number of data bytes in the data frame. Remote frames used the DLC to indicate the number of data bytes to request from another node.                                                           |
| Data Bytes           | The data payload of data frames. The number of bytes should match the value of DLC. Data byte 0 is transmitted first, and each data byte is transmitted from the most significant bit first.                                                                                                                               |
| CRC Sequence         | The CRC sequence is a 15-bit cyclic redundancy code.                                                                                                                                                                                                                                                                       |
| CRC Delim            | The CRC Delim (CRC Delimiter) is a single recessive bit that follows the CRC sequence.                                                                                                                                                                                                                                     |
| ACK Slot             | The ACK Slot (Acknowledgment Slot) is intended for receiver nodes to indicate that the data or remote frame was received without any issue. The transmitter node will send a recessive bit in the ACK Slot and receiver nodes should over ride the ACK Slot with a dominant bit if the frame was received without errors. |
| ACK Delim            | The ACK Delim (Acknowledgment Delimiter) is a single recessive bit.                                                                                                                                                                                                                                                        |
| EOF                  | The EOF (End of Frame) marks the end of a data or remote frame, and consists of seven recessive bits.                                                                                                                                                                                                                      |

## 31.2.2.2 Error and Overload Frames

## Error Frames

Error frames are transmitted when a node detects a bus error. Error frames notably consist of an Error Flag which is made up of six consecutive bits of the same value, thus violating the bit-stuffing rule. Therefore, when a particular node detects a bus error and transmits an error frame, all other nodes will then detect a stuff error and transmit their own error frames in response. This has the effect of propagating the detection of a bus error across all nodes on the bus.

When a node detects a bus error, it will transmit an error frame starting from the next bit. However, if the type of bus error was a CRC error, then the error frame will start at the bit following the ACK Delim (see Section 31.2.3 for more details). The following Figure 31.2-2 shows different fields of an error frame:

Figure 31.2-2. Fields of an Error Frame

Table 31.2-2. Error Frame

| Error Frame              | Description                                                                                                                                                                                                                                                                                                       |
|--------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Error Flag               | The Error Flag has two forms, the Active Error Flag consisting of 6 domi nant bits and the Passive Error Flag consisting of 6 recessive bits (unless overridden by dominant bits of other nodes). Active Error Flags are sent by error active nodes, whilst Passive Error Flags are sent by error passive nodes. |
| Error Flag Superposition | The Error Flag Superposition field meant to allow for other nodes on the bus to transmit their respective Active Error Flags. The superposition field can range from 0 to 6 bits, and ends when the first recessive bit is detected (i.e., the first it of the Delimiter).                                        |
| Error Delimeter          | The Delimiter field marks the end of the error/overload frame, and con sists of 8 recessive bits.                                                                                                                                                                                                                |

## Overload Frames

An overload frame has the same bit fields as an error frame containing an Active Error Flag. The key difference is in the cases that can trigger the transmission of an overload frame. Figure 31.2-3 below shows the bit fields of an overload frame.

Figure 31.2-3. Fields of an Overload Frame

Table 31.2-3. Overload Frame

| Overload Flag               | Description                                                                                              |
|-----------------------------|----------------------------------------------------------------------------------------------------------|
| Overload Flag               | Consists of 6 dominant bits. Same as an Active Error Flag.                                               |
| Overload Flag Superposition | Allows for the superposition of Overload Flags from other nodes, similar to an Error Flag Superposition. |
| Overload Delimiter          | Consists of 8 recessive bits. Same as an Error Delimiter.                                                |

Overload frames will be transmitted under the following cases:

1. A receiver requires a delay of the next data or remote frame.
2. A dominant bit is detected at the first and second bit of intermission.

3. A dominant bit is detected at the eighth (last) bit of an Error Delimiter. Note that in this case, TEC and REC will not be incremented (see Section 31.2.3 for more details).

Transmitting an overload frame due to one of the above cases must also satisfy the following rules:

- The start of an overload frame due to case 1 is only allowed to be started at the first bit time of an expected intermission.
- The start of an overload frame due to case 2 and 3 is only allowed to be started one bit after detecting the dominant bit.
- A maximum of two overload frames may be generated in order to delay the transmission of the next data or remote frame.

## 31.2.2.3 Interframe Space

The Interframe Space acts as a separator between frames. Data frames and remote frames must be separated from preceding frames by an Interframe Space, regardless of the preceding frame's type (data frame, remote frame, error frame, or overload frame). However, error frames and overload frames do not need to be separated from preceding frames.

Figure 31.2-4 shows the fields within an Interframe Space:

Figure 31.2-4. The Fields within an Interframe Space

Table 31.2-4. Interframe Space

| Interframe Space     | Description                                                                                                                                                                                       |
|----------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Intermission         | The Intermission consists of 3 recessive bits.                                                                                                                                                    |
| Suspend Transmission | An Error Passive node that has just transmitted a message must include a Suspend Transmission field. This field consists of 8 recessive bits. Error Active nodes should not include this field.   |
| Bus Idle             | The Bus Idle field is of arbitrary length. Bus Idle ends when an SOF is transmitted. If a node has a pending transmission, the SOF should be transmitted at the first bit following Intermission. |

## 31.2.3 TWAI Errors

## 31.2.3.1 Error Types

Bus Errors in TWAI are categorized into the following types:

## Bit Error

A Bit Error occurs when a node transmits a bit value (i.e., dominant or recessive) but the opposite bit is detected (e.g., a dominant bit is transmitted but a recessive is detected). However, if the transmitted bit is

recessive and is located in the Arbitration Field or ACK Slot or Passive Error Flag, then detecting a dominant bit will not be considered a Bit Error.

## Stuff Error

A stuff error is detected when six consecutive bits of the same value are detected (which violats the bit-stuffing encoding rules).

## CRC Error

A receiver of a data or remote frame will calculate CRC based on the bits it has received. A CRC error occurs when the CRC calculated by the receiver does not match the CRC sequence in the received data or remote Frame.

## Format Error

A Format Error is detected when a format-fixed bit field of a message contains an illegal bit. For example, the r1 and r0 fields must be dominant.

## ACK Error

An ACK Error occurs when a transmitter does not detect a dominant bit at the ACK Slot.

## 31.2.3.2 Error States

TWAI nodes implement fault confinement by each maintaining two error counters, where the counter values determine the error state. The two error counters are known as the Transmit Error Counter (TEC) and Receive Error Counter (REC). TWAI has the following error states.

## Error Active

An Error Active node is able to participate in bus communication and transmit an Active Error Flag when it detects an error.

## Error Passive

An Error Passive node is able to participate in bus communication, but can only transmit an Passive Error Flag when it detects an error. Error Passive nodes that have transmitted a data or remote frame must also include the Suspend Transmission field in the subsequent Interframe Space.

## Bus Off

A Bus Off node is not permitted to influence the bus in any way (i.e., is not allowed to transmit data).

## 31.2.3.3 Error Counters

The TEC and REC are incremented/decremented according to the following rules. Note that more than one rule can apply to a given message transfer.

1. When a receiver detects an error, the REC is increased by 1, except when the detected error was a Bit Error during the transmission of an Active Error Flag or an Overload Flag.
2. When a receiver detects a dominant bit as the first bit after sending an Error Flag, the REC is increased by 8.
3. When a transmitter sends an Error Flag, the TEC is increased by 8. However, the following scenarios are exempt from this rule:
- A transmitter is Error Passive since the transmitter generates an Acknowledgment Error because of not detecting a dominant bit in the ACK Slot, while detecting a dominant bit when sending a passive error flag. In this case, the TEC should not be increased.

- A transmitter transmits an Error Flag due to a Stuff Error during Arbitration. If the stuffed bit should have been recessive but was monitored as dominant, then the TEC should not be increased.
4. If a transmitter detects a Bit Error whilst sending an Active Error Flag or Overload Flag, the TEC is increased by 8.
5. If a receiver detects a Bit Error while sending an Active Error Flag or Overload Flag, the REC is increased by 8.
6. A node can tolerate up to 7 consecutive dominant bits after sending an Active/Passive Error Flag, or Overload Flag. After detecting the 14th consecutive dominant bit (when sending an Active Error Flag or Overload Flag), or the 8th consecutive dominant bit following a Passive Error Flag, a transmitter will increase its TEC by 8 and a receiver will increase its REC by 8. Every additional 8 consecutive dominant bits will also increase the TEC (for transmitters) or REC (for receivers) by 8 as well.
7. When a transmitter has transmitted a message (getting ACK and no errors until the EOF is complete), the TEC is decremented by 1, unless the TEC is already at 0.
8. When a receiver successfully receives a message (no errors before ACK Slot, and successful sending of ACK), the REC is decremented.
- If the REC is between 1 and 127, the REC will be decremented by 1.
- If the REC is greater than 127, the REC will be set to 127.
- If the REC is 0, the REC will remain 0.
9. A node becomes Error Passive when its TEC and/or REC is greater than or equal to 128. Though the node becomes Error Passive, it still sends an Active Error Flag. Note that once the REC has reached to 128, any further increases to its value are invalid until the REC returns to a value less than 128.
10. A node becomes Bus Off when its TEC is greater than or equal to 256.
11. An Error Passive node becomes Error Active when both the TEC and REC are less than or equal to 127.
12. A Bus Off node can become Error Active (with both its TEC and REC reset to 0) after it monitors 128 occurrences of 11 consecutive recessive bits on the bus.

## 31.2.4 TWAI Bit Timing

## 31.2.4.1 Nominal Bit

The TWAI protocol allows a TWAI bus to operate at a particular bit rate. However, all nodes within a TWAI bus must operate at the same bit rate.

- The Nominal Bit Rate is defined as the number of bits transmitted per second.
- The Nominal Bit Time is defined as 1/Nominal Bit Rate .

A single Nominal Bit Time is divided into multiple segments, and each segment is made up of multiple Time Quanta. A Time Quantum is a minimum unit of time, and is implemented as some form of prescaled clock signal in each node. Figure 31.2-5 illustrates the segments within a single Nominal Bit Time.

TWAI controllers will operate in time steps of one Time Quanta where the state of the TWAI bus is analyzed. If the bus states in two consecutive Time Quantas are different (i.e., recessive to dominant or vice versa), it

means an edge is generated. The intersection of PBS1 and PBS2 is considered the Sample Point and the sampled bus value is considered the value of that bit.

Figure 31.2-5. Layout of a Bit

![Image](images/31_Chapter_31_img002_6449bfe5.png)

Table 31.2-5. Segments of a Nominal Bit Time

| Segment   | Description                                                                                                                                                                                             |
|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| SS        | The SS (Synchronization Segment) is 1 Time Quantum long. If all nodes are perfectly syn chronized, the edge of a bit will lie in the SS.                                                               |
| PBS1      | PBS1 (Phase Buffer Segment 1) can be 1 to 16 Time Quanta long. PBS1 is meant to com pensate for the physical delay times within the network. PBS1 can also be lengthened for synchronization purposes. |
| PBS2      | PBS2 (Phase Buffer Segment 2) can be 1 to 8 Time Quanta long. PBS2 is meant to com pensate for the information processing time of nodes. PBS2 can also be shortened for synchronization purposes.      |

## 31.2.4.2 Hard Synchronization and Resynchronization

Due to clock skew and jitter, the bit timing of nodes on the same bus may become out of phase. Therefore, a bit edge may come before or after the SS. To ensure that the internal bit timing clocks of each node are kept in phase, TWAI has various methods of synchronization. The Phase Error "e" is measured in the number of Time Quanta and relative to the SS.

- A positive Phase Error (e &gt; 0) is when the edge lies after the SS and before the Sample Point (i.e., the edge is late).
- A negative Phase Error (e &lt; 0) is when the edge lies after the Sample Point of the previous bit and before SS (i.e., the edge is early).

To correct for Phase Errors, there are two forms of synchronization, known as Hard Synchronization and Resynchronization . Hard Synchronization and Resynchronization obey the following rules:

- Only one synchronization may occur in a single bit time.
- Synchronizations only occurs on recessive to dominant edges.

## Hard Synchronization

Hard Synchronization occurs on the recessive to dominant (i.e., the first SOF bit after Bus Idle) edges when the bus is idle. All nodes will restart their internal bit timings so that the recessive to dominant edge lies within the SS of the restarted bit timing.

## Resynchronization

Resynchronization occurs on recessive to dominant edges when the bus is not idel. If the edge has a positive Phase Error (e &gt; 0), PBS1 is lengthened by a certain number of Time Quanta. If the edge has a negative Phase Error (e &lt; 0), PBS2 will be shortened by a certain number of Time Quanta.

The number of Time Quanta to lengthen or shorten depends on the magnitude of the Phase Error, and is also limited by the Synchronization Jump Width (SJW) value which is programmable.

- When the magnitude of the Phase Error (e) is less than or equal to the SJW, PBS1/PBS2 are lengthened/shortened by the e number of Time Quanta. This has a same effect as Hard Synchronization.
- When the magnitude of the Phase Error is greater to the SJW, PBS1/PBS2 are lengthened/shortened by the SJW number of Time Quanta. This means it may take multiple bits of synchronization before the Phase Error is entirely corrected.

## 31.3 Architectural Overview

Figure 31.3-1. TWAI Overview Diagram

![Image](images/31_Chapter_31_img003_a9f06486.png)

The major functional blocks of the TWAI controller are shown in Figure 31.3-1 .

## 31.3.1 Registers Block

The ESP32-C3 CPU accesses peripherals using 32-bit aligned words. However, the majority of registers in the TWAI controller only contain useful data at the least significant byte (bits [7:0]). Therefore, in these registers, bits [31:8] are ignored on writes, and return 0 on reads.

## Configuration Registers

The configuration registers store various configuration items for the TWAI controller such as bit rates, operation mode, Acceptance Filter, etc. Configuration registers can only be modified whilst the TWAI controller is in Reset Mode (See Section 31.4.1).

## Command Registers

The command register is used by the CPU to drive the TWAI controller to initiate certain actions such as transmitting a message or clearing the Receive Buffer. The command register can only be modified when the TWAI controller is in Operation Mode (see section 31.4.1).

## Interrupt &amp; Status Registers

The interrupt register indicates what events have occurred in the TWAI controller (each event is represented by a separate bit). The status register indicates the current status of the TWAI controller.

## Error Management Registers

The error management registers include error counters and capture registers. The error counter registers represent TEC and REC values. The capture registers will record information about instances where TWAI controller detects a bus error, or when it loses arbitration.

## Transmit Buffer Registers

The transmit buffer is a 13-byte buffer used to store a TWAI message to be transmitted.

## Receive Buffer Registers

The Receive Buffer is a 13-byte buffer which stores a single message. The Receive Buffer acts as a window of Receive FIFO, whose first message will be mapped into the Receive Buffer.

Note that the Transmit Buffer registers, Receive Buffer registers, and the Acceptance Filter registers share the same address range (offset 0x0040 to 0x0070). Their access is governed by the following rules:

- When the TWAI controller is in Reset Mode, all reads and writes to the address range maps to the Acceptance Filter registers.
- When the TWAI controller is in Operation Mode:
- – All reads to the address range maps to the Receive Buffer registers.
- – All writes to the address range maps to the Transmit Buffer registers.

## 31.3.2 Bit Stream Processor

The Bit Stream Processing (BSP) module frames data from the Transmit Buffer (e.g. bit stuffing and additional CRC fields) and generates a bit stream for the Bit Timing Logic (BTL) module. At the same time, the BSP module is also responsible for processing the received bit stream (e.g., de-stuffing and verifying CRC) from the BTL module and placing the message into the Receive FIFO. The BSP will also detect errors on the TWAI bus and report them to the Error Management Logic (EML).

## 31.3.3 Error Management Logic

The Error Management Logic (EML) module updates the TEC and REC, records error information like error types and positions, and updates the error state of the TWAI controller such that the BSP module generates the correct Error Flags. Furthermore, this module also records the bit position when the TWAI controller loses arbitration.

## 31.3.4 Bit Timing Logic

The Bit Timing Logic (BTL) module transmits and receives messages at the configured bit rate. The BTL module also handles bit timing synchronization so that communication remains stable. A single bit time consists of multiple programmable segments that allows users to set the length of each segment to account for factors such as propagation delay and controller processing time, etc.

## 31.3.5 Acceptance Filter

The Acceptance Filter is a programmable message filtering unit that allows the TWAI controller to accept or reject a received message based on the message's ID field. Only accepted messages will be stored in the Receive FIFO. The Acceptance Filter's registers can be programmed to specify a single filter, or two separate filters (dual filter mode).

## 31.3.6 Receive FIFO

The Receive FIFO is a 64-byte buffer (inside the TWAI controller) that stores received messages accepted by the Acceptance Filter. Messages in the Receive FIFO can vary in size (between 3 to 13-bytes). When the Receive FIFO is full (or does not have enough space to store the next received message in its entirety), the Overrun Interrupt will be triggered, and any subsequent received messages will be lost until adequate space is cleared in the Receive FIFO. The first message in the Receive FIFO will be mapped to the 13-byte Receive Buffer until that message is cleared (using the Release Receive Buffer command bit). After being cleared, the Receive Buffer will map to the next message in the Receive FIFO, and the space occupied by the previous message in the Receive FIFO can be used to receive new messages.

## 31.4 Functional Description

## 31.4.1 Modes

The ESP32-C3 TWAI controller has two working modes: Reset Mode and Operation Mode. Reset Mode and Operation Mode are entered by setting or clearing the TWAI\_RESET\_MODE bit.

## 31.4.1.1 Reset Mode

Entering Reset Mode is required in order to modify the various configuration registers of the TWAI controller. When entering Reset Mode, the TWAI controller is essentially disconnected from the TWAI bus. When in Reset Mode, the TWAI controller will not be able to transmit any messages (including error signals). Any transmission in progress is immediately terminated. Likewise, the TWAI controller will not be able to receive any messages either.

## 31.4.1.2 Operation Mode

In operation mode, the TWAI controller connects to the bus and write-protect all configuration registers to ensure consistency during operation. When in Operation Mode, the TWAI controller can transmit and receive messages (including error signaling) depending on which operation sub-mode the TWAI controller was configured with. The TWAI controller supports the following operation sub-modes:

- Normal Mode: The TWAI controller can transmit and receive messages including error signals (such as error and overload Frames).
- Self-test Mode: Self-test mode is similar to normal Mode, but the TWAI controller will consider the transmission of a data or RTR frame successful and do not generate an ACK error even if it was not acknowledged. This is commonly used when the TWAI controller does self-test.
- Listen-only Mode: The TWAI controller will be able to receive messages, but will remain completely passive on the TWAI bus. Thus, the TWAI controller will not be able to transmit any messages, acknowledgments, or error signals. The error counters will remain frozen. This mode is useful for TWAI bus monitoring.

Note that when exiting Reset Mode (i.e., entering Operation Mode), the TWAI controller must wait for 11 consecutive recessive bits to occur before being able to fully connect the TWAI bus (i.e., be able to transmit or receive).

## 31.4.2 Bit Timing

The operating bit rate of the TWAI controller must be configured whilst the TWAI controller is in Reset Mode. The bit rate is configured using TWAI\_BUS\_TIMING\_0\_REG and TWAI\_BUS\_TIMING\_1\_REG, and the two registers contain the following fields:

The following Table 31.4-1 illustrates the bit fields of TWAI\_BUS\_TIMING\_0\_REG .

Table 31.4-1. Bit Information of TWAI\_BUS\_TIMING\_0\_REG (0x18)

| Bit 31-16   | Bit 15   | Bit 14   | Bit 13   | Bit 12   | ......   | Bit 1   | Bit 0   |
|-------------|----------|----------|----------|----------|----------|---------|---------|
| Reserved    | SJW.1    | SJW.0    | Reserved | BRP.12   | ......   | BRP.1   | BRP.0   |

## Notes:

- BRP: The TWAI Time Quanta clock is derived from the APB clock that is usually 80 MHz. The Baud Rate Prescaler (BRP) field is used to define the prescaler according to the equation below, where tT q is the Time Quanta clock cycle and tCLK is APB clock cycle:

t T q = 2 × t CLK × (2 12 × BRP.12 + 211 × BRP.11 + ... + 21 × BRP.1 + 20 × BRP.0 + 1)

- SJW: Synchronization Jump Width (SJW) is configured in SJW.0 and SJW.1 where SJW = (2 x SJW.1 + SJW.0 + 1).

The following Table 31.4-2 illustrates the bit fields of TWAI\_BUS\_TIMING\_1\_REG .

Table 31.4-2. Bit Information of TWAI\_BUS\_TIMING\_1\_REG (0x1c)

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | SAM     | PBS2.2  | PBS2.1  | PBS2.0  | PBS1.3  | PBS1.2  | PBS1.1  | PBS1.0  |

## Notes:

- PBS1: The number of Time Quanta in Phase Buffer Segment 1 is defined according to the following equation: (8 x PBS1.3 + 4 x PBS1.2 + 2 x PBS1.1 + PBS1.0 + 1).
- PBS2: The number of Time Quanta in Phase Buffer Segment 2 is defined according to the following equation: (4 x PBS2.2 + 2 x PBS2.1 + PBS2.0 + 1).
- SAM: Enables triple sampling if set to 1. This is useful for low/medium speed buses to filter spikes on the bus line.

## 31.4.3 Interrupt Management

The ESP32-C3 TWAI controller provides eight interrupts, each represented by a single bit in the TWAI\_INT\_RAW\_REG. For a particular interrupt to be triggered, the corresponding enable bit in TWAI\_INT ENA\_REG must be set.

The TWAI controller provides the following interrupts:

- Receive Interrupt
- Transmit Interrupt
- Error Warning Interrupt
- Data Overrun Interrupt
- Error Passive Interrupt
- Arbitration Lost Interrupt
- Bus Error Interrupt
- Bus Status Interrupt

The TWAI controller's interrupt signal to the interrupt matrix will be asserted whenever one or more interrupt bits are set in the TWAI\_INT\_RAW\_REG, and deasserted when all bits in TWAI\_INT\_RAW\_REG are cleared. The majority of interrupt bits in TWAI\_INT\_RAW\_REG are automatically cleared when the register is read, except for the Receive Interrupt which can only be cleared when all the messages are released by setting the TWAI\_RELEASE\_BUF bit.

## 31.4.3.1 Receive Interrupt (RXI)

The Receive Interrupt (RXI) is asserted whenever the TWAI controller has received messages that are pending to be read from the Receive Buffer (i.e., when TWAI\_RX\_MESSAGE\_CNT\_REG &gt; 0). Pending received messages includes valid messages in the Receive FIFO and also overrun messages. The RXI will not be deasserted until all pending received messages are cleared using the TWAI\_RELEASE\_BUF command bit.

## 31.4.3.2 Transmit Interrupt (TXI)

The Transmit Interrupt (TXI) is triggered whenever Transmit Buffer becomes free, indicating another message can be loaded into the Transmit Buffer to be transmitted. The Transmit Buffer becomes free under the following scenarios:

- A message transmission has completed successfully, i.e., acknowledged without any errors. (Any failed messages will automatically be resent.)
- A single shot transmission has completed (successfully or unsuccessfully, indicated by the TWAI\_TX\_COMPLETE bit).
- A message transmission was aborted using the TWAI\_ABORT\_TX command bit.

## 31.4.3.3 Error Warning Interrupt (EWI)

The Error Warning Interrupt (EWI) is triggered whenever there is a change to the TWAI\_ERR\_ST and TWAI\_BUS\_OFF\_ST bits of the TWAI\_STATUS\_REG (i.e., transition from 0 to 1 or vice versa). Thus, an EWI

could indicate one of the following events, depending on the values TWAI\_ERR\_ST and TWAI\_BUS\_OFF\_ST at the moment when the EWI is triggered.

- If TWAI\_ERR\_ST = 0 and TWAI\_BUS\_OFF\_ST = 0:
- – If the TWAI controller was in the Error Active state, it indicates both the TEC and REC have returned below the threshold value set by TWAI\_ERR\_WARNING\_LIMIT\_REG .
- – If the TWAI controller was previously in the Bus Off Recovery state, it indicates that Bus Recovery has completed successfully.
- If TWAI\_ERR\_ST = 1 and TWAI\_BUS\_OFF\_ST = 0: The TEC or REC error counters have exceeded the threshold value set by TWAI\_ERR\_WARNING\_LIMIT\_REG .
- If TWAI\_ERR\_ST = 1 and TWAI\_BUS\_OFF\_ST = 1: The TWAI controller has entered the BUS\_OFF state (due to the TEC &gt;= 256).
- If TWAI\_ERR\_ST = 0 and TWAI\_BUS\_OFF\_ST = 1: The TWAI controller's TEC has dropped below the threshold value set by TWAI\_ERR\_WARNING\_LIMIT\_REG during BUS\_OFF recovery.

## 31.4.3.4 Data Overrun Interrupt (DOI)

The Data Overrun Interrupt (DOI) is triggered whenever the Receive FIFO has overrun. The DOI indicates that the Receive FIFO is full and should be cleared immediately to prevent any further overrun messages.

The DOI is only triggered by the first message that causes the Receive FIFO to overrun (i.e., the transition from the Receive FIFO not being full to the Receive FIFO overrunning). Any subsequent overrun messages will not trigger the DOI again. The DOI could be triggered again when all received messages (valid or overrun) have been cleared.

## 31.4.3.5 Error Passive Interrupt (TXI)

The Error Passive Interrupt (EPI) is triggered whenever the TWAI controller switches from Error Active to Error Passive, or vice versa.

## 31.4.3.6 Arbitration Lost Interrupt (ALI)

The Arbitration Lost Interrupt (ALI) is triggered whenever the TWAI controller is attempting to transmit a message and loses arbitration. The bit position where the TWAI controller lost arbitration is automatically recorded in Arbitration Lost Capture register (TWAI\_ARB LOST CAP\_REG). When the ALI occurs again, the Arbitration Lost Capture register will no longer record new bit location until it is cleared (via CPU reading this register).

## 31.4.3.7 Bus Error Interrupt (BEI)

The Bus Error Interrupt (BEI) is triggered whenever TWAI controller detects an error on the TWAI bus. When a bus error occurs, the Bus Error type and its bit position are automatically recorded in the Error Code Capture register (TWAI\_ERR\_CODE\_CAP\_REG). When the BEI occurs again, the Error Code Capture register will no longer record new error information until it is cleared (via a read from the CPU).

## 31.4.3.8 Bus Status Interrupt (BSI)

The Bus Status Interrupt (BSI) is triggered whenever TWAI controller is switching between receive/transmit status and idle status. When a BSI occurs, the current status of TWAI controller can be measured by reading TWAI\_RX\_ST and TWAI\_TX\_ST in TWAI\_STATUS\_REG register.

## 31.4.4 Transmit and Receive Buffers

## 31.4.4.1 Overview of Buffers

Table 31.4-3. Buffer Layout for Standard Frame Format and Extended Frame Format

| Standard Frame Format (SFF)   | Standard Frame Format (SFF)   | Extended Frame Format (EFF)   | Extended Frame Format (EFF)   |
|-------------------------------|-------------------------------|-------------------------------|-------------------------------|
| TWAI Address                  | Content                       | TWAI Address                  | Content                       |
| 0x40                          | TX/RX frame information       | 0x40                          | TX/RX frame information       |
| 0x44                          | TX/RX identifier 1            | 0x44                          | TX/RX identifier 1            |
| 0x48                          | TX/RX identifier 2            | 0x48                          | TX/RX identifier 2            |
| 0x4c                          | TX/RX data byte 1             | 0x4c                          | TX/RX identifier 3            |
| 0x50                          | TX/RX data byte 2             | 0x50                          | TX/RX identifier 4            |
| 0x54                          | TX/RX data byte 3             | 0x54                          | TX/RX data byte 1             |
| 0x58                          | TX/RX data byte 4             | 0x58                          | TX/RX data byte 2             |
| 0x5c                          | TX/RX data byte 5             | 0x5c                          | TX/RX data byte 3             |
| 0x60                          | TX/RX data byte 6             | 0x60                          | TX/RX data byte 4             |
| 0x64                          | TX/RX data byte 7             | 0x64                          | TX/RX data byte 5             |
| 0x68                          | TX/RX data byte 8             | 0x68                          | TX/RX data byte 6             |
| 0x6c                          | reserved                      | 0x6c                          | TX/RX data byte 7             |
| 0x70                          | reserved                      | 0x70                          | TX/RX data byte 8             |

Table 31.4-3 illustrates the layout of the Transmit Buffer and Receive Buffer registers. Both the Transmit and Receive Buffer registers share the same address space and are only accessible when the TWAI controller is in Operation Mode. The CPU accesses Transmit Buffer registers for write operations, and Receive Buffer registers for read operations . Both buffers share the exact same register layout and fields to represent a message (received or to be transmitted). The Transmit Buffer registers are used to configure a TWAI message to be transmitted. The CPU would write to the Transmit Buffer registers specifying the message's frame type, frame format, frame ID, and frame data (payload). Once the Transmit Buffer is configured, the CPU would then initiate the transmission by setting the TWAI\_TX\_REQ bit in TWAI\_CMD\_REG .

- For a self-reception request, set the TWAI\_SELF\_RX\_REQ bit instead.
- For a single-shot transmission, set both the TWAI\_TX\_REQ and the TWAI\_ABORT\_TX simultaneously.

The Receive Buffer registers map the first message in the Receive FIFO. The CPU would read the Receive Buffer registers to obtain the first message's frame type, frame format, frame ID, and frame data (payload). Once the message has been read from the Receive Buffer registers, the CPU can set the TWAI\_RELEASE\_BUF bit in TWAI\_CMD\_REG to clear the Receive Buffer registers. If there are still messages in the Receive FIFO, the Receive Buffer registers will map the first message again.

## 31.4.4.2 Frame Information

The frame information is one byte long and specifies a message's frame type, frame format, and length of data. The frame information fields are shown in Table 31.4-4 .

Table 31.4-4. TX/RX Frame Information (SFF/EFF); TWAI Address 0x40

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | FF1     | RTR2    | X
 3    | X
 3    | DLC.34  | DLC.24  | DLC.14  | DLC.04  |

## Notes:

1. FF: The Frame Format (FF) bit specifies whether the message is Extended Frame Format (EFF) or Standard Frame Format (SFF). The message is EFF when FF bit is 1, and SFF when FF bit is 0.
2. RTR: The Remote Transmission Request (RTR) bit specifies whether the message is a data frame or a remote frame. The message is a remote frame when the RTR bit is 1, and a data frame when the RTR bit is 0.
3. X: Don’t care, can be any value.
4. DLC: The Data Length Code (DLC) field specifies the number of data bytes for a data frame, or the number of data bytes to request in a remote frame. TWAI data frames are limited to a maximum payload of 8 data bytes, and thus the DLC should range anywhere from 0 to 8.

## 31.4.4.3 Frame Identifier

The Frame Identifier fields is two-byte (11-bit) long if the message is SFF, and four-byte (29-bit) long if the message is EFF.

The Frame Identifier fields for an SFF (11-bit) message is shown in Table 31.4-5 ~ 31.4-6 .

Table 31.4-5. TX/RX Identifier 1 (SFF); TWAI Address 0x44

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | ID.10   | ID.9    | ID.8    | ID.7    | ID.6    | ID.5    | ID.4    | ID.3    |

Table 31.4-6. TX/RX Identifier 2 (SFF); TWAI Address 0x48

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | ID.2    | ID.1    | ID.0    | X
 1    | X
 2    | X
 2    | X
 2    | X
 2    |

## Notes:

1. Don't care. Recommended to be compatible with receive buffer (i.e., set to RTR ) in case of using the self reception functionality (or together with self-test functionality).
2. Don't care. Recommended to be compatible with receive buffer (i.e., set to 0 ) in case of using the self reception functionality (or together with self-test functionality).

The Frame Identifier fields for an EFF (29-bits) message is shown in Table 31.4-7 ~ 31.4-10 .

Table 31.4-7. TX/RX Identifier 1 (EFF); TWAI Address 0x44

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | ID.28   | ID.27   | ID.26   | ID.25   | ID.24   | ID.23   | ID.22   | ID.21   |

Table 31.4-8. TX/RX Identifier 2 (EFF); TWAI Address 0x48

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | ID.20   | ID.19   | ID.18   | ID.17   | ID.16   | ID.15   | ID.14   | ID.13   |

Table 31.4-9. TX/RX Identifier 3 (EFF); TWAI Address 0x4c

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | ID.12   | ID.11   | ID.10   | ID.9    | ID.8    | ID.7    | ID.6    | ID.5    |

## Table 31.4-10. TX/RX Identifier 4 (EFF); TWAI Address 0x50

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | ID.4    | ID.3    | ID.2    | ID.1    | ID.0    | X
 1    | X
 2    | X
 2    |

## Notes:

1. Don't care. Recommended to be compatible with receive buffer (i.e., set to RTR ) in case of using the self reception functionality (or together with self-test functionality).
2. Don't care. Recommended to be compatible with receive buffer (i.e., set to 0 ) in case of using the self reception functionality (or together with self-test functionality).

## 31.4.4.4 Frame Data

The Frame Data field contains the payloads of transmitted or received data frame, and can range from 0 to eight bytes. The number of valid bytes should be equal to the DLC. However, if the DLC is larger than eight bytes, the number of valid bytes would still be limited to eight. Remote frames do not have data payloads, so their Frame Data fields will be unused.

For example, when transmitting a data frame with five bytes, the CPU should write five to the DLC field, and then write data to the corresponding register of the first to the fifth data field. Likewise, when the CPU receives a data frame with a DLC of five data bytes, only the first to the fifth data byte will contain valid payload data for the CPU to read.

## 31.4.5 Receive FIFO and Data Overruns

The Receive FIFO is a 64-byte internal buffer used to store received messages in First In First Out order. A single received message can occupy between 3 to 13 bytes of space in the Receive FIFO, and their endianness is identical to the register layout of the Receive Buffer registers. The Receive Buffer registers are mapped to the bytes of the first message in the Receive FIFO.

When the TWAI controller receives a message, it will increment the value of TWAI\_RX\_MESSAGE\_COUNTER up to a maximum of 64. If there is adequate space in the Receive FIFO, the message contents will be written into

the Receive FIFO. Once a message has been read from the Receive Buffer, the TWAI\_RELEASE\_BUF bit should be set. This will decrement TWAI\_RX\_MESSAGE\_COUNTER and free the space occupied by the first message in the Receive FIFO. The Receive Buffer will then map to the next message in the Receive FIFO.

A data overrun occurs when the TWAI controller receives a message, but the Receive FIFO lacks the adequate free space to store the received message in its entirety (either due to the message contents being larger than the free space in the Receive FIFO, or the Receive FIFO being completely full).

When a data overrun occurs:

- The free space left in the Receive FIFO is filled with the partial contents of the overrun message. If the Receive FIFO is already full, then none of the overrun message's contents will be stored.
- When data in the Receive FIFO overruns for the first time, a Data Overrun Interrupt will be triggered.
- Each overrun message will still increment the TWAI\_RX\_MESSAGE\_COUNTER up to a maximum of 64.
- The Receive FIFO will internally mark overrun messages as invalid. The TWAI\_MISS\_ST bit can be used to determine whether the message currently mapped to by the Receive Buffer is valid or overrun.

To clear an overrun Receive FIFO, the TWAI\_RELEASE\_BUF must be called repeatedly until TWAI\_RX\_MESSAGE\_COUNTER is 0. This has the effect of reading all valid messages in the Receive FIFO and clearing all overrun messages.

## 31.4.6 Acceptance Filter

The Acceptance Filter allows the TWAI controller to filter out received messages based on their ID (and optionally their first data byte and frame type). Only accepted messages are passed on to the Receive FIFO. The use of Acceptance Filters allows a more lightweight operation of the TWAI controller (e.g., less use of Receive FIFO, fewer Receive Interrupts) since the TWAI Controller only need to handle a subset of messages.

The Acceptance Filter configuration registers can only be accessed whilst the TWAI controller is in Reset Mode, since they share the same address spaces with the Transmit Buffer and Receive Buffer registers.

The configuration registers consist of a 32-bit Acceptance Code Value and a 32-bit Acceptance Mask Value. The Acceptance Code value specifies a bit pattern which each filtered bit of the message must match in order for the message to be accepted. The Acceptance Mask Value is able to mask out certain bits of the Code value (i.e., set as "Don't Care" bits). Each filtered bit of the message must either match the acceptance code or be masked in order for the message to be accepted, as demonstrated in Figure 31.4-1 .

Figure 31.4-1. Acceptance Filter

![Image](images/31_Chapter_31_img004_b7074600.png)

The TWAI controller Acceptance Filter allows the 32-bit Acceptance Code and Mask Values to either define a single filter (i.e., Single Filter Mode), or two filters (i.e., Dual Filter Mode). How the Acceptance Filter interprets the 32-bit code and mask values is dependent on filter mode and the format of received messages (i.e., SFF or EFF).

![Image](images/31_Chapter_31_img005_5c341bfb.png)

## 31.4.6.1 Single Filter Mode

Single Filter Mode is enabled by setting the TWAI\_RX\_FILTER\_MODE bit to 1. This will cause the 32-bit code and mask values to define a single filter. The single filter can filter the following bits of a data or remote frame:

- SFF
- – The entire 11-bit ID
- – RTR bit
- – Data byte 1 and Data byte 2
- EFF
- – The entire 29-bit ID
- – RTR bit

The following Figure 31.4-2 illustrates how the 32-bit code and mask values will be interpreted under Single Filter Mode.

Figure 31.4-2. Single Filter Mode

![Image](images/31_Chapter_31_img006_c7d60278.png)

## 31.4.6.2 Dual Filter Mode

Dual Filter Mode is enabled by clearing the TWAI\_RX\_FILTER\_MODE bit to 0. This will cause the 32-bit code and mask values to define a two separate filters referred to as filter 1 or filter 2. Under Dual Filter Mode, a message will be accepted if it is accepted by one of the two filters.

The two filters can filter the following bits of a data or remote frame:

- SFF
- – The entire 11-bit ID
- – RTR bit
- – Data byte 1 (for filter 1 only)
- EFF

- – The first 16 bits of the 29-bit ID

The following Figure 31.4-3 illustrates how the 32-bit code and mask values will be interpreted in Dual Filter Mode.

Figure 31.4-3. Dual Filter Mode

![Image](images/31_Chapter_31_img007_22a4c60e.png)

## 31.4.7 Error Management

The TWAI protocol requires that each TWAI node maintains the Transmit Error Counter (TEC) and Receive Error Counter (REC). The value of both error counters determines the current error state of the TWAI controller (i.e., Error Active, Error Passive, Bus-Off). The TWAI controller stores the TEC and REC values in TWAI\_TX\_ERR\_CNT\_REG and TWAI\_RX\_ERR\_CNT\_REG respectively, and they can be read by the CPU anytime. In addition to the error states, the TWAI controller also offers an Error Warning Limit (EWL) feature that can warn users of the occurrence of severe bus errors before the TWAI controller enters the Error Passive state.

The current error state of the TWAI controller is indicated via a combination of the following values and status bits: TEC, REC, TWAI\_ERR\_ST, and TWAI\_BUS\_OFF\_ST. Certain changes to these values and bits will also trigger interrupts, thus allowing the users to be notified of error state transitions (see section 31.4.3). The following figure 31.4-4 shows the relation between the error states, values and bits, and error state related interrupts.

Figure 31.4-4. Error State Transition

![Image](images/31_Chapter_31_img008_c712cae5.png)

## 31.4.7.1 Error Warning Limit

The Error Warning Limit (EWL) is a configurable threshold value for the TEC and REC, which will trigger an interrupt when exceeded. The EWL is intended to serve as a warning about severe TWAI bus errors, and is triggered before the TWAI controller enters the Error Passive state. The EWL is configured in TWAI\_ERR\_WARNING\_LIMIT\_REG and can only be configured whilst the TWAI controller is in Reset Mode. The TWAI\_ERR\_WARNING\_LIMIT\_REG has a default value of 96. When the values of TEC and/or REC are larger than or equal to the EWL value, the TWAI\_ERR\_ST bit is immediately set to 1. Likewise, when the values of both the TEC and REC are smaller than the EWL value, the TWAI\_ERR\_ST bit is immediately reset to 0. The Error Warning Interrupt is triggered whenever the value of the TWAI\_ERR\_ST bit (or the TWAI\_BUS\_OFF\_ST) changes.

## 31.4.7.2 Error Passive

The TWAI controller is in the Error Passive state when the TEC or REC value exceeds 127. Likewise, when both the TEC and REC are less than or equal to 127, the TWAI controller enters the Error Active state. The Error Passive Interrupt is triggered whenever the TWAI controller transitions from the Error Active state to the Error Passive state or vice versa.

## 31.4.7.3 Bus-Off and Bus-Off Recovery

The TWAI controller enters the Bus-Off state when the TEC value exceeds 255. On entering the Bus-Off state, the TWAI controller will automatically do the following:

- Set REC to 0
- Set TEC to 127
- Set the TWAI\_BUS\_OFF\_ST bit to 1
- Enter Reset Mode

The Error Warning Interrupt is triggered whenever the value of the TWAI\_BUS\_OFF\_ST bit (or the TWAI\_ERR\_ST bit) changes.

To return to the Error Active state, the TWAI controller must undergo Bus-Off Recovery. Bus-Off Recovery requires the TWAI controller to observe 128 occurrences of 11 consecutive recessive bits on the bus. To initiate Bus-Off Recovery (after entering the Bus-Off state), the TWAI controller should enter Operation Mode

by setting the TWAI\_RESET\_MODE bit to 0. The TEC tracks the progress of Bus-Off Recovery by decrementing the TEC each time when the TWAI controller observes 11 consecutive recessive bits. When Bus-Off Recovery has completed (i.e., TEC has decremented from 127 to 0), the TWAI\_BUS\_OFF\_ST bit will automatically be reset to 0, thus triggering the Error Warning Interrupt.

## 31.4.8 Error Code Capture

The Error Code Capture (ECC) feature allows the TWAI controller to record the error type and bit position of a TWAI bus error in the form of an error code. Upon detecting a TWAI bus error, the Bus Error Interrupt is triggered and the error code is recorded in TWAI\_ERR\_CODE\_CAP\_REG. Subsequent bus errors will trigger the Bus Error Interrupt, but their error codes will not be recorded until the current error code is read from the TWAI\_ERR\_CODE\_CAP\_REG .

The following Table 31.4-11 shows the fields of the TWAI\_ERR\_CODE\_CAP\_REG:

Table 31.4-11. Bit Information of TWAI\_ERR\_CODE\_CAP\_REG (0x30)

| Bit 31-8   | Bit 7   | Bit 6   | Bit 5   | Bit 4   | Bit 3   | Bit 2   | Bit 1   | Bit 0   |
|------------|---------|---------|---------|---------|---------|---------|---------|---------|
| Reserved   | ERRC.11 | ERRC.01 | DIR2    | SEG.43  | SEG.33  | SEG.23  | SEG.13  | SEG.03  |

## Notes:

- ERRC: The Error Code (ERRC) indicates the type of bus error: 00 for bit error, 01 for format error, 10 for stuff error, and 11 for other types of error.
- DIR: The Direction (DIR) indicates whether the TWAI controller was transmitting or receiving when the bus error occurred: 0 for transmitter, 1 for receiver.
- SEG: The Error Segment (SEG) indicates which segment of the TWAI message (i.e., bit position) the bus error occurred at.

The following Table 31.4-12 shows how to interpret the SEG.0 to SEG.4 bits.

Table 31.4-12. Bit Information of Bits SEG.4 - SEG.0

|   Bit SEG.4 |   Bit SEG.3 |   Bit SEG.2 |   Bit SEG.1 |   Bit SEG.0 | Description      |
|-------------|-------------|-------------|-------------|-------------|------------------|
|           0 |           0 |           0 |           1 |           1 | start of frame   |
|           0 |           0 |           0 |           1 |           0 | ID.28 ~ ID.21    |
|           0 |           0 |           1 |           1 |           0 | ID.20 ~ ID.18    |
|           0 |           0 |           1 |           0 |           0 | bit SRTR         |
|           0 |           0 |           1 |           0 |           1 | bit IDE          |
|           0 |           0 |           1 |           1 |           1 | ID.17 ~ ID.13    |
|           0 |           1 |           1 |           1 |           1 | ID.12 ~ ID.5     |
|           0 |           1 |           1 |           1 |           0 | ID.4 ~ ID.0      |
|           0 |           1 |           1 |           0 |           0 | bit RTR          |
|           0 |           1 |           1 |           0 |           1 | reserved bit 1   |
|           0 |           1 |           0 |           0 |           1 | reserved bit 0   |
|           0 |           1 |           0 |           1 |           1 | data length code |
|           0 |           1 |           0 |           1 |           0 | data field       |
|           0 |           1 |           0 |           0 |           0 | CRC sequence     |

Cont’d on next page

Table 31.4-12 – cont’d from previous page

|   Bit SEG.4 |   Bit SEG.3 |   Bit SEG.2 |   Bit SEG.1 |   Bit SEG.0 | Description            |
|-------------|-------------|-------------|-------------|-------------|------------------------|
|           1 |           1 |           0 |           0 |           0 | CRC delimiter          |
|           1 |           1 |           0 |           0 |           1 | ACK slot               |
|           1 |           1 |           0 |           1 |           1 | ACK delimiter          |
|           1 |           1 |           0 |           1 |           0 | end of frame           |
|           1 |           0 |           0 |           1 |           0 | intermission           |
|           1 |           0 |           0 |           0 |           1 | active error flag      |
|           1 |           0 |           1 |           1 |           0 | passive error flag     |
|           1 |           0 |           0 |           1 |           1 | tolerate dominant bits |
|           1 |           0 |           1 |           1 |           1 | error delimiter        |
|           1 |           1 |           1 |           0 |           0 | overload flag          |

## Notes:

- Bit SRTR: under Standard Frame Format.
- Bit IDE: Identifier Extension Bit, 0 for Standard Frame Format.

## 31.4.9 Arbitration Lost Capture

The Arbitration Lost Capture (ALC) feature allows the TWAI controller to record the bit position where it loses arbitration. When the TWAI controller loses arbitration, the bit position is recorded in TWAI\_ARB LOST CAP\_REG and the Arbitration Lost Interrupt is triggered.

Subsequent losses in arbitration will trigger the Arbitration Lost Interrupt, but will not be recorded in TWAI\_ARB LOST CAP\_REG until the current Arbitration Lost Capture is read from the TWAI\_ERR\_CODE\_CAP\_REG .

Table 31.4-13 illustrates bits and fields of TWAI\_ERR\_CODE\_CAP\_REG whilst Figure 31.4-5 illustrates the bit positions of a TWAI message.

Figure 31.4-5. Positions of Arbitration Lost Bits

![Image](images/31_Chapter_31_img009_1773695b.png)

Table 31.4-13. Bit Information of TWAI\_ARB LOST CAP\_REG (0x2c)

| Bit 31-5   | Bit 4    | Bit 3    | Bit 2    | Bit 1    | Bit 0    |
|------------|----------|----------|----------|----------|----------|
| Reserved   | BITNO.41 | BITNO.31 | BITNO.21 | BITNO.11 | BITNO.01 |

## Notes:

- BITNO: Bit Number (BITNO) indicates the nth bit of a TWAI message where arbitration was lost.

## 31.5 Register Summary

'|' here means separate line to distinguish between TWAI working modes discussed in Section 31.4.1 Modes . The left describes the access in Operation Mode. The right belongs to Reset Mode and is marked in red. The addresses in this section are relative to Two-wire Automotive Interface base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                       | Description                       | Address   | Access        |
|----------------------------|-----------------------------------|-----------|---------------|
| Configuration Registers    |                                   |           |               |
| TWAI_MODE_REG              | Mode Register                     | 0x0000    | R/W           |
| TWAI_BUS_TIMING_0_REG      | Bus Timing Register 0             | 0x0018    | RO &#124; R/W |
| TWAI_BUS_TIMING_1_REG      | Bus Timing Register 1             | 0x001C    | RO &#124; R/W |
| TWAI_ERR_WARNING_LIMIT_REG | Error Warning Limit Register      | 0x0034    | RO &#124; R/W |
| TWAI_DATA_0_REG            | Data Register 0                   | 0x0040    | WO &#124; R/W |
| TWAI_DATA_1_REG            | Data Register 1                   | 0x0044    | WO &#124; R/W |
| TWAI_DATA_2_REG            | Data Register 2                   | 0x0048    | WO &#124; R/W |
| TWAI_DATA_3_REG            | Data Register 3                   | 0x004C    | WO &#124; R/W |
| TWAI_DATA_4_REG            | Data Register 4                   | 0x0050    | WO &#124; R/W |
| TWAI_DATA_5_REG            | Data Register 5                   | 0x0054    | WO &#124; R/W |
| TWAI_DATA_6_REG            | Data Register 6                   | 0x0058    | WO &#124; R/W |
| TWAI_DATA_7_REG            | Data Register 7                   | 0x005C    | WO &#124; R/W |
| TWAI_DATA_8_REG            | Data Register 8                   | 0x0060    | WO &#124; RO  |
| TWAI_DATA_9_REG            | Data Register 9                   | 0x0064    | WO &#124; RO  |
| TWAI_DATA_10_REG           | Data Register 10                  | 0x0068    | WO &#124; RO  |
| TWAI_DATA_11_REG           | Data Register 11                  | 0x006C    | WO &#124; RO  |
| TWAI_DATA_12_REG           | Data Register 12                  | 0x0070    | WO &#124; RO  |
| TWAI_CLOCK_DIVIDER_REG     | Clock Divider Register            | 0x007C    | varies        |
| Contro Registers           |                                   |           |               |
| TWAI_CMD_REG               | Command Register                  | 0x0004    | WO            |
| Status Register            |                                   |           |               |
| TWAI_STATUS_REG            | Status Register                   | 0x0008    | RO            |
| TWAI_ARB LOST CAP_REG      | Arbitration Lost Capture Register | 0x002C    | RO            |
| TWAI_ERR_CODE_CAP_REG      | Error Code Capture Register       | 0x0030    | RO            |
| TWAI_RX_ERR_CNT_REG        | Receive Error Counter Register    | 0x0038    | RO &#124; R/W |
| TWAI_TX_ERR_CNT_REG        | Transmit Error Counter Register   | 0x003C    | RO &#124; R/W |
| TWAI_RX_MESSAGE_CNT_REG    | Receive Message Counter Register  | 0x0074    | RO            |
| Interrupt Registers        |                                   |           |               |
| TWAI_INT_RAW_REG           | Interrupt Register                | 0x000C    | RO            |
| TWAI_INT ENA_REG           | Interrupt Enable Register         | 0x0010    | R/W           |

## 31.6 Registers

'|' here means separate line. The left describes the access in Operation Mode. The right belongs to Reset Mode with red color. The addresses in this section are relative to Two-wire Automotive Interface base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 31.1. TWAI\_MODE\_REG (0x0000)

![Image](images/31_Chapter_31_img010_fdda1aea.png)

- TWAI\_RESET\_MODE This bit is used to configure the operation mode of the TWAI Controller. 1: Reset mode; 0: Operation mode (R/W)
- TWAI\_LISTEN\_ONLY\_MODE 1: Listen only mode. In this mode the nodes will only receive messages from the bus, without generating the acknowledge signal nor updating the RX error counter. (R/W)
- TWAI\_SELF\_TEST\_MODE 1: Self test mode. In this mode the TX nodes can perform a successful transmission without receiving the acknowledge signal. This mode is often used to test a single node with the self reception request command. (R/W)
- TWAI\_RX\_FILTER\_MODE This bit is used to configure the filter mode. 0: Dual filter mode; 1: Single filter mode (R/W)

Register 31.2. TWAI\_BUS\_TIMING\_0\_REG (0x0018)

![Image](images/31_Chapter_31_img011_53507725.png)

TWAI\_BAUD\_PRESC Baud Rate Prescaler value, determines the frequency dividing ratio. (RO | R/W)

TWAI\_SYNC\_JUMP\_WIDTH Synchronization Jump Width (SJW), 1 ~ 14 Tq wide. (RO | R/W)

Register 31.3. TWAI\_BUS\_TIMING\_1\_REG (0x001C)

![Image](images/31_Chapter_31_img012_c773af38.png)

TWAI\_TIME\_SEG1 The width of PBS1. (RO | R/W)

TWAI\_TIME\_SEG2 The width of PBS2. (RO | R/W)

TWAI\_TIME\_SAMP The number of sample points. 0: the bus is sampled once; 1: the bus is sampled three times (RO | R/W)

Register 31.4. TWAI\_ERR\_WARNING\_LIMIT\_REG (0x0034)

![Image](images/31_Chapter_31_img013_434cd204.png)

TWAI\_ERR\_WARNING\_LIMIT Error warning threshold. In the case when any of an error counter value exceeds the threshold, or all the error counter values are below the threshold, an error warning interrupt will be triggered (given the enable signal is valid). (RO | R/W)

Register 31.5. TWAI\_DATA\_0\_REG (0x0040)

![Image](images/31_Chapter_31_img014_9c47b15e.png)

TWAI\_TX\_BYTE\_0 Stored the 0th byte information of the data to be transmitted in operation mode. (WO)

TWAI\_ACCEPTANCE\_CODE\_0 Stored the 0th byte of the filter code in reset mode. (R/W)

Register 31.6. TWAI\_DATA\_1\_REG (0x0044)

![Image](images/31_Chapter_31_img015_2e36cbb7.png)

TWAI\_TX\_BYTE\_1 Stored the 1st byte information of the data to be transmitted in operation mode. (WO)

TWAI\_ACCEPTANCE\_CODE\_1 Stored the 1st byte of the filter code in reset mode. (R/W)

Register 31.7. TWAI\_DATA\_2\_REG (0x0048)

![Image](images/31_Chapter_31_img016_2e8bf220.png)

TWAI\_TX\_BYTE\_2 Stored the 2nd byte information of the data to be transmitted in operation mode. (WO)

TWAI\_ACCEPTANCE\_CODE\_2 Stored the 2nd byte of the filter code in reset mode. (R/W)

Register 31.8. TWAI\_DATA\_3\_REG (0x004C)

![Image](images/31_Chapter_31_img017_83c761f3.png)

TWAI\_TX\_BYTE\_3 Stored the 3rd byte information of the data to be transmitted in operation mode. (WO)

TWAI\_ACCEPTANCE\_CODE\_3 Stored the 3rd byte of the filter code in reset mode. (R/W)

Register 31.9. TWAI\_DATA\_4\_REG (0x0050)

![Image](images/31_Chapter_31_img018_b5b23340.png)

TWAI\_TX\_BYTE\_4 Stored the 4th byte information of the data to be transmitted in operation mode. (WO)

TWAI\_ACCEPTANCE\_MASK\_0 Stored the 0th byte of the filter code in reset mode. (R/W)

## Register 31.10. TWAI\_DATA\_5\_REG (0x0054)

TWAI\_TX\_BYTE\_5 Stored the 5th byte information of the data to be transmitted in operation mode. (WO)

![Image](images/31_Chapter_31_img019_f7f4468f.png)

TWAI\_ACCEPTANCE\_MASK\_1 Stored the 1st byte of the filter code in reset mode. (R/W)

## Register 31.11. TWAI\_DATA\_6\_REG (0x0058)

TWAI\_TX\_BYTE\_6 Stored the 6th byte information of the data to be transmitted in operation mode. (WO)

![Image](images/31_Chapter_31_img020_3aa2092f.png)

TWAI\_ACCEPTANCE\_MASK\_2 Stored the 2nd byte of the filter code in reset mode. (R/W)

## Register 31.12. TWAI\_DATA\_7\_REG (0x005C)

![Image](images/31_Chapter_31_img021_dc7f9b7c.png)

TWAI\_TX\_BYTE\_7 Stored the 7th byte information of the data to be transmitted in operation mode.

(WO)

TWAI\_ACCEPTANCE\_MASK\_3 Stored the 3rd byte of the filter code in reset mode. (R/W)

![Image](images/31_Chapter_31_img022_4a9c3d8c.png)

## Register 31.16. TWAI\_DATA\_11\_REG (0x006C)

![Image](images/31_Chapter_31_img023_58043993.png)

TWAI\_TX\_BYTE\_11 Stored the 11th byte information of the data to be transmitted in operation mode. (WO)

## Register 31.17. TWAI\_DATA\_12\_REG (0x0070)

TWAI\_TX\_BYTE\_12 Stored the 12th byte information of the data to be transmitted in operation mode. (WO)

![Image](images/31_Chapter_31_img024_241cef5b.png)

## Register 31.18. TWAI\_CLOCK\_DIVIDER\_REG (0x007C)

TWAI\_CD These bits are used to configure the divisor of the external CLKOUT pin. (R/W)

![Image](images/31_Chapter_31_img025_20e884b1.png)

TWAI\_CLOCK\_OFF This bit can be configured in reset mode. 1: Disable the external CLKOUT pin;

0: Enable the external CLKOUT pin (RO | R/W)

## Register 31.19. TWAI\_CMD\_REG (0x0004)

![Image](images/31_Chapter_31_img026_f0d2fd1f.png)

TWAI\_TX\_REQ Set the bit to 1 to drive nodes to start transmission. (WO)

TWAI\_ABORT\_TX Set the bit to 1 to cancel a pending transmission request. (WO)

TWAI\_RELEASE\_BUF Set the bit to 1 to release the RX buffer. (WO)

TWAI\_CLR\_OVERRUN Set the bit to 1 to clear the data overrun status bit. (WO)

TWAI\_SELF\_RX\_REQ Self reception request command. Set the bit to 1 to allow a message be transmitted and received simultaneously. (WO)

## Register 31.20. TWAI\_STATUS\_REG (0x0008)

![Image](images/31_Chapter_31_img027_5b657066.png)

- TWAI\_RX\_BUF\_ST 1: The data in the RX buffer is not empty, with at least one received data packet. (RO)
- TWAI\_OVERRUN\_ST 1: The RX FIFO is full and data overrun has occurred. (RO)

TWAI\_TX\_BUF\_ST 1: The TX buffer is empty, the CPU may write a message into it. (RO)

TWAI\_TX\_COMPLETE 1: The TWAI controller has successfully received a packet from the bus. (RO)

- TWAI\_RX\_ST 1: The TWAI Controller is receiving a message from the bus. (RO)

TWAI\_TX\_ST 1: The TWAI Controller is transmitting a message to the bus. (RO)

TWAI\_ERR\_ST 1: At least one of the RX/TX error counter has reached or exceeded the value set in register TWAI\_ERR\_WARNING\_LIMIT\_REG. (RO)

- TWAI\_BUS\_OFF\_ST 1: In bus-off status, the TWAI Controller is no longer involved in bus activities. (RO)
- TWAI\_MISS\_ST This bit reflects whether the data packet in the RX FIFO is complete. 1: The current packet is missing; 0: The current packet is complete (RO)

![Image](images/31_Chapter_31_img028_2d622912.png)

Register 31.21. TWAI\_ARB LOST CAP\_REG (0x002C)

![Image](images/31_Chapter_31_img029_2375e0af.png)

TWAI\_ARB\_LOST\_CAP This register contains information about the bit position of lost arbitration. (RO)

Register 31.22. TWAI\_ERR\_CODE\_CAP\_REG (0x0030)

![Image](images/31_Chapter_31_img030_398fdf29.png)

TWAI\_ECC\_SEGMENT This register contains information about the location of errors, see Table 31.411 for details. (RO)

TWAI\_ECC\_DIRECTION This register contains information about transmission direction of the node when error occurs. 1: Error occurs when receiving a message; 0: Error occurs when transmitting a message (RO)

TWAI\_ECC\_TYPE This register contains information about error types: 00: bit error; 01: form error; 10: stuff error; 11: other type of error (RO)

Register 31.23. TWAI\_RX\_ERR\_CNT\_REG (0x0038)

![Image](images/31_Chapter_31_img031_7354b7ae.png)

TWAI\_RX\_ERR\_CNT The RX error counter register, reflects value changes in reception status. (RO | R/W)

Register 31.24. TWAI\_TX\_ERR\_CNT\_REG (0x003C)

![Image](images/31_Chapter_31_img032_d9e76aaa.png)

TWAI\_TX\_ERR\_CNT The TX error counter register, reflects value changes in transmission status. (RO | R/W)

Register 31.25. TWAI\_RX\_MESSAGE\_CNT\_REG (0x0074)

![Image](images/31_Chapter_31_img033_cdf6dac7.png)

TWAI\_RX\_MESSAGE\_COUNTER This register reflects the number of messages available within the RX FIFO. (RO)

## Register 31.26. TWAI\_INT\_RAW\_REG (0x000C)

![Image](images/31_Chapter_31_img034_89694d99.png)

- TWAI\_RX\_INT\_ST Receive interrupt. If this bit is set to 1, it indicates there are messages to be handled in the RX FIFO. (RO)
- TWAI\_TX\_INT\_ST Transmit interrupt. If this bit is set to 1, it indicates the message transmission is finished and a new transmission is able to start. (RO)
- TWAI\_ERR\_WARN\_INT\_ST Error warning interrupt. If this bit is set to 1, it indicates the error status signal and the bus-off status signal of Status register have changed (e.g., switched from 0 to 1 or from 1 to 0). (RO)
- TWAI\_OVERRUN\_INT\_ST Data overrun interrupt. If this bit is set to 1, it indicates a data overrun interrupt is generated in the RX FIFO. (RO)
- TWAI\_ERR\_PASSIVE\_INT\_ST Error passive interrupt. If this bit is set to 1, it indicates the TWAI Controller is switched between error active status and error passive status due to the change of error counters. (RO)
- TWAI\_ARB\_LOST\_INT\_ST Arbitration lost interrupt. If this bit is set to 1, it indicates an arbitration lost interrupt is generated. (RO)
- TWAI\_BUS\_ERR\_INT\_ST Error interrupt. If this bit is set to 1, it indicates an error is detected on the bus. (RO)
- TWAI\_BUS\_STATE\_INT\_ST Bus state interrupt. If this bit is set to 1, it indicates the status of TWAI controller has changed. (RO)

## Register 31.27. TWAI\_INT ENA\_REG (0x0010)

![Image](images/31_Chapter_31_img035_0335d9ac.png)

TWAI\_RX\_INT\_ENA Set this bit to 1 to enable receive interrupt. (R/W)

TWAI\_TX\_INT\_ENA Set this bit to 1 to enable transmit interrupt. (R/W)

TWAI\_ERR\_WARN\_INT\_ENA Set this bit to 1 to enable error warning interrupt. (R/W)

TWAI\_OVERRUN\_INT\_ENA Set this bit to 1 to enable data overrun interrupt. (R/W)

TWAI\_ERR\_PASSIVE\_INT\_ENA Set this bit to 1 to enable error passive interrupt. (R/W)

TWAI\_ARB\_LOST\_INT\_ENA Set this bit to 1 to enable arbitration lost interrupt. (R/W)

TWAI\_BUS\_ERR\_INT\_ENA Set this bit to 1 to enable bus error interrupt. (R/W)

TWAI\_BUS\_STATE\_INT\_ENA Set this bit to 1 to enable bus state interrupt. (R/W)
