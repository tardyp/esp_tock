---
chapter: 32
title: "Chapter 32"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 32

## USB Serial/JTAG Controller (USB\_SERIAL\_JTAG)

ESP32-C6 contains a USB Serial/JTAG Controller. This unit can be used to program the SoC's flash, read program output, as well as attach a debugger to the running program. All of these are possible for any computer with a USB host (hereafter referred to as 'host') without any active external components.

## 32.1 Overview

While programming and debugging an ESP32-C6 project using the UART and JTAG functionality is certainly possible, it has a few downsides. First of all, both UART and JTAG take up IO pins and as such, fewer pins are left usable for controlling external signals in software. Additionally, an external chip or adapter is needed for both UART and JTAG to interface with a host computer, which means it will be necessary to integrate these two functionalities in the form of external chips or debugging adapters.

In order to alleviate these issues, ESP32-C6 provides a USB Serial/JTAG Controller, which integrates the functionality of both a USB-to-serial converter as well as a USB-to-JTAG adapter. As this device directly interfaces with an external USB host using only the two data lines required by USB 2.0, only two pins are required to be dedicated to this functionality for debugging ESP32-C6.

## 32.2 Features

The USB Serial/JTAG controller has the following features:

- USB Full-speed device; Hardwired for CDC-ACM (Communication Device Class - Abstract Control Model) and JTAG adapter functionality
- CDC-ACM:
- – Integrates CDC-ACM adherent serial port emulation (plug-and-play on most modern OSes)
- – Supports host controllable chip reset and entry into download mode
- JTAG adapter functionality:
- – Allows fast communication with CPU debugging core using a compact representation of JTAG instructions
- Two OUT Endpoints and three IN Endpoints in addition to Control Endpoint 0; Up to 64-byte data payload size
- Internal PHY: very few or no external components needed to connect to a host computer

Figure 32.2-1. USB Serial/JTAG High Level Diagram

![Image](images/32_Chapter_32_img001_81865250.png)

As shown in Figure 32.2-1, the USB Serial/JTAG controller consists of a USB PHY, a USB device interface, a JTAG command processor, a response capture unit, and the CDC-ACM registers. The PHY and device interface are clocked from a 48 MHz clock derived from the baseband PLL (BBPLL); the software-accessible side of the CDC-ACM block is clocked from APB\_CLK. The JTAG command processor is connected to the JTAG debugging unit of the main processor; the CDC-ACM registers are connected to the APB bus and as such can be read from and written to by software running on the main CPU.

Note that while the USB Serial/JTAG device supports USB 2.0 standard, it only supports Full-speed (12 Mbps) mode but not other modes that the USB 2.0 standard introduced, e.g., the High-speed (480 Mbps) mode.

Figure 32.2-2 shows the internal details of the USB Serial/JTAG controller on the USB side. The USB Serial/JTAG controller consists of a USB 2.0 Full-speed device. It contains a control endpoint, a dummy interrupt endpoint, two bulk input endpoints, and two bulk output endpoints. Together, these form a USB composite device, which consists of a CDC-ACM USB class device as well as a vendor-specific device implementing the JTAG interface. On the SoC side, the JTAG interface is directly connected to the RISC-V CPU's debugging interface, allowing debugging of programs running on that core. Meanwhile, the CDC-ACM device is exposed as a set of registers, allowing a program on the CPU to read and write from it. Additionally, the ROM startup code of the SoC contains code that allows the user to reprogram attached flash memory using this interface.

![Image](images/32_Chapter_32_img002_35fd441c.png)

Figure 32.2-2. USB Serial/JTAG Block Diagram

![Image](images/32_Chapter_32_img003_817bd07c.png)

## 32.3 Functional Description

The USB Serial/JTAG controller interfaces with a USB host processor on one side, and with the CPU debugging hardware as well as the software that communicates through the CDC-ACM port on the other side.

## 32.3.1 CDC-ACM USB Interface Functional Description

The CDC-ACM interface adheres to the standard USB CDC-ACM class for serial port emulation. It contains a dummy interrupt endpoint (which will never send any events, as they are not implemented nor needed) and a Bulk IN as well as a Bulk OUT endpoint for the host's received and sent serial data respectively. These endpoints can handle 64-byte packets at a time, allowing high throughput. As CDC-ACM is a standard USB device class, a host generally can function without any special installation procedures. That is to say, when the USB debugging device is properly connected to a host, the operating system should show a new serial port moments later.

The CDC-ACM interface accepts the following standard CDC-ACM control requests:

Table 32.3-1. Standard CDC-ACM Control Requests

| Command                | Action                                                                                            |
|------------------------|---------------------------------------------------------------------------------------------------|
| SEND_BREAK             | Accepted but ignored (dummy)                                                                      |
| SET_LINE_CODING        | Accepted, value sent is readable in software                                                      |
| GET_LINE_CODING        | By default, returns 9600 baud, no parity, 8 databits, 1 stopbit (Can be changed through software) |
| SET_CONTROL_LINE_STATE | Set the state of the RTS/DTR lines. See Table 32.3-2                                              |

Aside from general-purpose communication, the CDC-ACM interface can also be used to reset ESP32-C6 and optionally make it enter download mode to flash new firmware. This can be realized by setting the RTS and

DTR lines on the virtual serial port.

Table 32.3-2. CDC-ACM Settings with RTS and DTR

|   RTS |   DTR | Action                   |
|-------|-------|--------------------------|
|     0 |     0 | Clear download mode flag |
|     0 |     1 | Set download mode flag   |
|     1 |     0 | Reset ESP32-C6           |
|     1 |     1 | No action                |

Note that if the download mode flag is set when ESP32-C6 is reset, ESP32-C6 will reboot into download mode. When this flag is cleared and the chip is reset, ESP32-C6 will boot from flash. For specific sequences, please refer to Section 32.4. All these functions can also be disabled by programming various eFuses. Please refer to Chapter 6 eFuse Controller for more details.

## 32.3.2 CDC-ACM Firmware Interface Functional Description

The CPU can interact with the USB Serial/JTAG controller as the module is connected to the internal APB bus of ESP32-C6. This is mainly used to read and write data from and to the virtual serial port on the attached host.

USB CDC-ACM serial data is sent to and received from the host in packets of 0 to 64 bytes in size. When enough CDC-ACM data has accumulated in the host, the host sends a packet to the CDC-ACM receive endpoint, and the USB Serial/JTAG controller accepts this packet if it has a free buffer. Conversely, the host checks periodically if the USB Serial/JTAG controller has a packet ready to be sent to the host, and if so, receives this packet.

Firmware can get notified of new data from the host in one of the following two ways. First of all, the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_EP\_DATA\_AVAIL bit will remain set as long as there still is unread host data in the buffer. Secondly, the availability of data will trigger the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT interrupt. When data is available, it can be read by firmware through repeatedly reading bytes from USB\_SERIAL\_JTAG\_EP1\_REG. The amount of bytes to read can be determined by checking the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_EP\_DATA\_AVAIL bit after reading each byte to see if there is more data to read. After all data is read, the USB debugging device is automatically readied to receive a new data packet from the host.

When the firmware has data to send, it can put the data in the send buffer and trigger a flush to allow the host to receive the data in a USB packet. In order to do so, there needs to be space available in the send buffer. Firmware can check this by reading USB\_REG\_SERIAL\_IN\_EP\_DATA\_FREE. A 1 in this register field indicates there is still free room in the buffer, and firmware can fill the buffer by writing bytes to the USB\_SERIAL\_JTAG\_EP1\_REG register. Writing the buffer does not immediately trigger sending data to the host until the buffer is flushed. After the flush, the entire buffer will be ready to be received by the USB host at once. A flush can be triggered in two ways: 1) after the 64th byte is written to the buffer, the USB hardware will automatically flush the buffer to the host; or 2) firmware can trigger a flush by writing 1 to USB\_REG\_SERIAL\_WR\_DONE .

Regardless of how a flush is triggered, the send buffer will be unavailable for firmware to write into until it has been fully read by the host. As soon as the send buffer has been fully read, the

USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT interrupt will be triggered, indicating that the send buffer can receive another 64 bytes.

It is possible to handle some out-of-band serial requests in software, specifically, the host setting DTR and RTS and changing the line state. If the CDC-ACM interface receives a SET\_LINE\_CODING request, the peripheral can be configured to trigger a USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_INT interrupt, at which point the line coding can be read from the USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_W0\_REG register. Similarly, SET\_CONTROL\_LINE\_STATE requests will trigger USB\_SERIAL\_JTAG\_RTS\_CHG\_INT and USB\_SERIAL\_JTAG\_DTR\_CHG\_INT interrupts if they change the state of these lines. Software can then read the specific state through the USB\_SERIAL\_JTAG\_RTS and USB\_SERIAL\_JTAG\_DTR bits. Note that as described earlier, certain RTS/DTR sequences lead to hardware reset of ESP32-C6. Software can disable hardware recognition of these DTR/RTS sequences by setting the

USB\_SERIAL\_JTAG\_USB\_UART\_CHIP\_RST\_DIS bit, allowing software to interpret these signals freely.

Finally, the host can read the current line state using GET\_LINE\_CODING. This event sends back the data in the USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_W0\_REG register and triggers a

USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_INT interrupt.

## 32.3.3 USB-to-JTAG Interface: JTAG Command Processor

The USB-to-JTAG interface uses a vendor-specific class for its implementation. It consists of two endpoints, one to receive commands and another to send responses. Additionally, some less time-sensitive commands can be given as control requests.

Commands from the host to the JTAG interface are interpreted by the JTAG command processor. Internally, the JTAG command processor implements a full four-wire JTAG bus, consisting of the TCK, TMS and TDI output lines to the RISC-V CPU, as well as the TDO line signalling back from the CPU to the JTAG response capture unit. These signals adhere to the IEEE 1149.1 JTAG standards. Additionally, there is an SRST line to reset ESP32-C6.

Optionally, software can set USB\_SERIAL\_JTAG\_USB\_JTAG\_BRIDGE\_EN in order to redirect these signals to the GPIO matrix instead, where they can be routed to IO pads on ESP32-C6. This also allows external devices to be debugged via the USB Serial/JTAG peripheral.

The JTAG command processor parses each received nibble (4-bit value) as a command. As USB data is received in 8-bit bytes, this means each byte contains two commands. The USB command processor will execute high-nibble first and low-nibble second. The commands are used to control the TCK, TMS, TDI, and SRST lines of the internal JTAG bus, as well as to signal the JTAG response capture unit the state of the TDO line (which is driven by the CPU debugging logic) that needs to be captured.

In the internal JTAG bus, TCK, TMS, TDI, and TDO are connected directly to the JTAG debugging logic of the RISC-V CPU. SRST is connected to the reset logic of the digital circuitry in ESP32-C6 and a high level on this line will cause a digital system reset. Note that the USB Serial/JTAG controller itself is not affected by SRST.

A nibble can contain the following commands:

Table 32.3-3. Commands of a Nibble

| bit       | 3  2  1  0    |
|-----------|---------------|
| CMD_CLK   | 0 cap tms tdi |
| CMD_RST   | 1 0 0 srst    |
| CMD_FLUSH | 1 0 1 0       |
| CMD_RSV   | 1 0 1 1       |
| CMD_REP   | 1 1 R1 R0     |

- CMD\_CLK will set the TDI and TMS as the indicated values and emit one clock pulse on TCK. If the CAP bit is 1, it will instruct the JTAG response capture unit to capture the state of the TDO line. This instruction forms the basis of JTAG communication.
- CMD\_RST will set the state of the SRST line as the indicated value. This can be used to reset ESP32-C6.
- CMD\_FLUSH will instruct the JTAG response capture unit to flush the buffer of all bits it collected so the host is able to read them. Note that in some cases, a JTAG transaction will end in an odd number of commands and as such an odd number of nibbles. In this case, it is allowed to repeat the CMD\_FLUSH command to get an even number of nibbles fitting an integer number of bytes.
- CMD\_RSV is reserved in the current implementation. This command will be ignored when received by ESP32-C6.
- CMD\_REP repeats the last (non-CMD\_REP) command for a certain number of times. The purpose is to compress command streams which repeat the CMD\_CLK instruction for multiple times. A command such as CMD\_CLK can be followed by multiple CMD\_REP commands. The number of repetitions done by one CMD\_REP can be expressed as repetition \_ count = (R1 × 2 + R0) × (4 cmd \_ rep \_ count ), where cmd\_rep\_count indicates the number of the CMD\_REP instruction that went directly before it. Note that the CMD\_REP command is only intended to repeat a CMD\_CLK command. Specifically, using it on a CMD\_FLUSH command may lead to an unresponsive USB device, and a USB reset will be required to recover it.

## 32.3.4 USB-to-JTAG Interface: CMD\_REP Usage Example

Here is a list of commands as an illustration of the usage of CMD\_REP. Note that each command is a nibble, and in this example, the bytewise command stream would be 0x0D 0x5E 0xCF.

1. 0x0 (CMD\_CLK: cap=0, tdi=0, tms=0)
2. 0xD (CMD\_REP: R1=0, R0=1)
3. 0x5 (CMD\_CLK: cap=1, tdi=0, tms=1)
4. 0xE (CMD\_REP: R1=1, R0=0)
5. 0xC (CMD\_REP: R1=0, R0=0)
6. 0xF (CMD\_REP: R1=1, R0=1)

The following shows what happens at every step:

1. TCK is clocked with the TDI and TMS lines set to 0. No data is captured.
2. TCK is clocked another (0 × 2 + 1) × (4 0 ) = 1 time with the same settings as step 1.

3. TCK is clocked with the TDI line set to 0 and TMS set to 1. Data on the TDO line is captured.
4. TCK is clocked another (1 × 2 + 0) × (4 0 ) = 2 times with the same settings as step 3.
5. Nothing happens: (0 × 2 + 0) × (4 1 ) = 0. Note that this increases cmd\_rep\_count in the next step.
6. TCK is clocked another (1 × 2 + 1) × (4 2 ) = 48 times with the same settings as step 3.

In other words, this example stream has the same net effect as that of executing command 1 twice, then repeating command 3 for 51 times.

## 32.3.5 USB-to-JTAG Interface: Response Capture Unit

The response capture unit reads the TDO line of the internal JTAG bus and captures its value when the command parser executes a CMD\_CLK with cap=1. It puts this bit into an internal shift register, and writes a byte into the USB buffer when 8 bits have been collected. Of these 8 bits, the least significant one is the one that is read from TDO the earliest.

As soon as either 64 bytes (512 bits) have been collected or a CMD\_FLUSH command is executed, the response capture unit will make the buffer available for the host to receive. Note that the interface to the USB logic is double-buffered. Therefore, as long as the USB throughput is sufficient, the response capture unit can always receive more data. That is to say, while one of the buffers is waiting to be sent to the host, the other can receive more data. When the host has received data from its buffer and the response capture unit flushes its buffer, the two buffers exchange position.

This also means that a command stream can cause at most 128 bytes of capture data generated (less if there are flush commands in the stream) without the host acting to receive the generated data. If more data is generated anyway, the command stream will pause and the device will not accept more commands until the generated capture data is read out.

Note that in general, the logic of the response capture unit tries not to send zero-byte responses. For instance, sending a series of CMD\_FLUSH commands will not cause a series of 0-byte USB responses to be sent. However, in the current implementation, some zero-0 responses may be generated in extraordinary circumstances. It is recommended to ignore these responses.

## 32.3.6 USB-to-JTAG Interface: Control Transfer Requests

Aside from the command processor and the response capture unit, the USB-to-JTAG interface also understands some control requests, as documented in the table below:

Table 32.3-4. USB-to-JTAG Control Requests

| bmRequestType   | bRequest             | wValue    | wIndex    |   wLength | Data            |
|-----------------|----------------------|-----------|-----------|-----------|-----------------|
| 01000000b       | 0 (VEND_JTAG_SETDIV) | [divider] | interface |         0 | None            |
| 01000000b       | 1 (VEND_JTAG_SETIO)  | [iobits]  | interface |         0 | None            |
| 11000000b       | 2 (VEND_JTAG_GETTDO) | 0         | interface |         1 | [iostate]       |
| 10000000b       | 6 (GET_DESCRIPTOR)   | 0x2000    | 0         |       256 | [jtag cap desc] |

- VEND\_JTAG\_SETDIV sets the divider used. This directly affects the duration of a TCK clock pulse. The TCK clock pulses are derived from a base clock of 48 MHz, which is divided down using an internal

divider. This control request allows the host to set this divider. Note that on startup, the divider is set to 2, which means the TCK clock rate will generally be 24 MHz.

- VEND\_JTAG\_SETIO can bypass the JTAG command processor to set the internal TDI, TDO, TMS, and SRST lines to given values. These values are encoded in the wValue field in the format of 11'b0, srst, trst, tck, tms, tdi.
- VEND\_JTAG\_GETTDO can bypass the JTAG response capture unit to read the internal TDO signal directly. This request returns one byte of data, of which the least significant bit represents the status of the TDO line.
- GET\_DESCRIPTOR is a standard USB request. However, it can also be used with a vendor-specific wValue of 0x2000 to get the JTAG capabilities descriptor. This returns a certain amount of bytes representing the following fixed structure, which describes the capabilities of the USB-to-JTAG adapter (as shown in Table 32.3-5). This structure allows host software to automatically support future revisions of the hardware without the need for an update.

The JTAG capability descriptors of ESP32-C6 are as follows. Note that all 16-bit values are little-endian.

Table 32.3-5. JTAG Capability Descriptors

| Byte   |   Value | Description                                                                                       |
|--------|---------|---------------------------------------------------------------------------------------------------|
| 0      |       1 | JTAG protocol capability structure version                                                        |
| 1      |      10 | Total length of JTAG protocol capabilities                                                        |
| 2      |       1 | Type of this struct: 1 for speed capability struct                                                |
| 3      |       8 | Length of this speed capabilities struct                                                          |
| 4 ~ 5  |    4800 | JTAG base clock speed in 10 kHz increments. Note that the maximum TCK speed is half of this value |
| 6 ~ 7  |       1 | Minimum divider value settable by the VEND_JTAG_SETDIV request                                    |
| 8 ~ 9  |     255 | Maximum divider value settable by the VEND_JTAG_SETDIV request                                    |

## 32.4 Recommended Operation

Little setup is needed for using the USB Serial/JTAG device. The USB-to-JTAG hardware itself does not need any setup aside from the standard USB initialization that the host operating system already does. Apart from that, the CDC-ACM emulation on the host side is also plug-and-play.

On the firmware side, very little initialization is needed either. The USB hardware is self-initialized and after boot-up, if a host is connected and listening on the CDC-ACM interface, data can be exchanged as described above without any specific setup except for the situation when the firmware optionally sets up an interrupt service handler.

One thing to note is that there may be situations where either the host is not attached or the CDC-ACM virtual port is not opened. In such cases, the packets that are flushed to the host will never be picked up and the send buffer will never be empty. It is important to detect these situations and implement timeout, as this is the only way to reliably detect whether the port on the host side is closed or not.

Another thing to note is that the USB device is dependent on the BBPLL for the 48 MHz USB PHY clock. If this PLL is disabled, the USB communication will cease to function.

One scenario where this happens is Deep-sleep. The USB Serial/JTAG controller (as well as the attached RISC-V CPU) will be entirely powered down in Deep-sleep mode. If a device needs to be debugged in this mode, it may be preferable to use an external JTAG debugger and a serial interface instead.

The CDC-ACM interface can also be used to reset the SoC and take it into or out of download mode. Generating the correct sequence of handshake signals can be a bit complicated, since most operating systems only allow setting or resetting DTR and RTS separately, but not in tandem. Additionally, some drivers (e.g., the standard CDC-ACM driver on Windows) do not set DTR until RTS is set and the user needs to explicitly set RTS in order to 'propagate' the DTR value. The recommended procedures are introduced below.

To reset the SoC into download mode:

Table 32.4-1. Reset SoC into Download Mode

| Action    | Internal state   | Note                       |
|-----------|------------------|----------------------------|
| Clear DTR | RTS=?, DTR=0     | Initialize to known values |
| Clear RTS | RTS=0, DTR=0     | -                          |
| Set DTR   | RTS=0, DTR=1     | Set download mode flag     |
| Clear RTS | RTS=0, DTR=1     | Propagate DTR              |
| Set RTS   | RTS=1, DTR=1     | -                          |
| Clear DTR | RTS=1, DTR=0     | Reset SoC                  |
| Set RTS   | RTS=1, DTR=0     | Propagate DTR              |
| Clear RTS | RTS=0, DTR=0     | Clear download flag        |

To reset the SoC into booting from flash:

Table 32.4-2. Reset SoC into Booting from flash

| Action    | Internal state   | Note                |
|-----------|------------------|---------------------|
| Clear DTR | RTS=?, DTR=0     | -                   |
| Clear RTS | RTS=0, DTR=0     | Clear download flag |
| Set RTS   | RTS=1, DTR=0     | Reset SoC           |
| Clear RTS | RTS=0, DTR=0     | Exit reset          |

## 32.5 Interrupts

- USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT: triggered when flush cmd is received for IN endpoint 2 of JTAG.
- USB\_SERIAL\_JTAG\_SOF\_INT: triggered when SOF frame is received.
- USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT: triggered when Serial Port OUT Endpoint receives one packet.
- USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT: triggered when Serial Port IN Endpoint is empty.
- USB\_SERIAL\_JTAG\_PID\_ERR\_INT: triggered when PID error is detected.
- USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT: triggered when CRC5 error is detected.

- USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT: triggered when CRC16 error is detected.
- USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT: triggered when a bit stuffing error is detected.
- USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT: triggered when IN token for IN endpoint 1 is received.
- USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT: triggered when USB bus reset is detected.
- USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT: triggered when OUT endpoint 1 receives packet with zero payload.
- USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT: triggered when OUT endpoint 2 receives packet with zero payload.
- USB\_SERIAL\_JTAG\_RTS\_CHG\_INT: triggered when level of RTS from USB serial channel is changed.
- USB\_SERIAL\_JTAG\_DTR\_CHG\_INT: triggered when level of DTR from USB serial channel is changed.
- USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_INT: triggered when level of GET LINE CODING request is received.
- USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_INT: triggered when level of SET LINE CODING request is received.

## 32.6 Register Summary

The addresses in this section are relative to USB Serial/JTAG controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                 | Description                                               | Address   | Access   |
|--------------------------------------|-----------------------------------------------------------|-----------|----------|
| Configuration Registers              |                                                           |           |          |
| USB_SERIAL_JTAG_EP1_REG              | FIFO access for the CDC-ACM data IN and OUT endpoints     | 0x0000    | R/W      |
| USB_SERIAL_JTAG_EP1_CONF_REG         | Configuration and control registers for the CDC-ACM FIFOs | 0x0004    | varies   |
| USB_SERIAL_JTAG_CONF0_REG            | PHY hardware configuration                                | 0x0018    | R/W      |
| USB_SERIAL_JTAG_TEST_REG             | Registers used for debugging the PHY                      | 0x001C    | varies   |
| USB_SERIAL_JTAG_MISC_CONF_REG        | Clock enable control                                      | 0x0044    | R/W      |
| USB_SERIAL_JTAG_MEM_CONF_REG         | Memory power control                                      | 0x0048    | R/W      |
| USB_SERIAL_JTAG_CHIP_RST_REG         | CDC-ACM chip reset control                                | 0x004C    | varies   |
| USB_SERIAL_JTAG_GET_LINE_CODE_W0_REG | W0 of GET_LINE_CODING command                             | 0x0058    | R/W      |
| USB_SERIAL_JTAG_GET_LINE_CODE_W1_REG | W1 of GET_LINE_CODING command                             | 0x005C    | R/W      |
| USB_SERIAL_JTAG_CONFIG_UPDATE_REG    | Configuration registers’ value update                     | 0x0060    | WT       |
| USB_SERIAL_JTAG_SER_AFIFO_CONFIG_REG | Serial AFIFO configure register                           | 0x0064    | varies   |
| Interrupt Registers                  |                                                           |           |          |
| USB_SERIAL_JTAG_INT_RAW_REG          | Interrupt raw status register                             | 0x0008    | R/WTC/SS |
| USB_SERIAL_JTAG_INT_ST_REG           | Interrupt status register                                 | 0x000C    | RO       |
| USB_SERIAL_JTAG_INT_ENA_REG          | Interrupt enable status register                          | 0x0010    | R/W      |
| USB_SERIAL_JTAG_INT_CLR_REG          | Interrupt clear status register                           | 0x0014    | WT       |
| Status Registers                     |                                                           |           |          |
| USB_SERIAL_JTAG_JFIFO_ST_REG         | JTAG FIFO status and control registers                    | 0x0020    | varies   |
| USB_SERIAL_JTAG_FRAM_NUM_REG         | Last received SOF frame index regis ter                  | 0x0024    | RO       |
| USB_SERIAL_JTAG_IN_EP0_ST_REG        | Control IN endpoint status informa tion                  | 0x0028    | RO       |
| USB_SERIAL_JTAG_IN_EP1_ST_REG        | CDC-ACM IN endpoint status infor mation                  | 0x002C    | RO       |
| USB_SERIAL_JTAG_IN_EP2_ST_REG        | CDC-ACM interrupt IN endpoint sta tus information        | 0x0030    | RO       |
| USB_SERIAL_JTAG_IN_EP3_ST_REG        | JTAG IN endpoint status information                       | 0x0034    | RO       |
| USB_SERIAL_JTAG_OUT_EP0_ST_REG       | Control OUT endpoint status informa tion                 | 0x0038    | RO       |
| USB_SERIAL_JTAG_OUT_EP1_ST_REG       | CDC-ACM OUT endpoint status infor mation                 | 0x003C    | RO       |
| USB_SERIAL_JTAG_OUT_EP2_ST_REG       | JTAG OUT endpoint status informa tion                    | 0x0040    | RO       |

| Name                                 | Description                   | Address   | Access   |
|--------------------------------------|-------------------------------|-----------|----------|
| USB_SERIAL_JTAG_SET_LINE_CODE_W0_REG | W0 of SET_LINE_CODING command | 0x0050    | RO       |
| USB_SERIAL_JTAG_SET_LINE_CODE_W1_REG | W1 of SET_LINE_CODING command | 0x0054    | RO       |
| USB_SERIAL_JTAG_BUS_RESET_ST_REG     | USB Bus reset status register | 0x0068    | RO       |
| Version Registers                    |                               |           |          |
| USB_SERIAL_JTAG_DATE_REG             | Date register                 | 0x0080    | R/W      |

## 32.7 Registers

The addresses in this section are relative to USB Serial/JTAG controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 32.1. USB\_SERIAL\_JTAG\_EP1\_REG (0x0000)

![Image](images/32_Chapter_32_img004_d8ed2ba5.png)

USB\_SERIAL\_JTAG\_RDWR\_BYTE Write or read byte data to or from UART TX/RX FIFO.

When USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT is set, users can write data (up to 64 bytes) into UART TX FIFO through this register.

When USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT is set, users can check how many data is received through USB\_SERIAL\_JTAG\_OUT\_EP1\_WR\_ADDR, then read data from UART RX FIFO through this register.

(R/W)

## Register 32.2. USB\_SERIAL\_JTAG\_EP1\_CONF\_REG (0x0004)

![Image](images/32_Chapter_32_img005_ae5b864e.png)

USB\_SERIAL\_JTAG\_WR\_DONE Configures whether to represent writing byte data to UART TX FIFO is done. 0: No effect 1: Represents writing byte data to UART TX FIFO is done This bit then stays 0 until data in UART TX FIFO is read by the USB Host. (WT)

USB\_SERIAL\_JTAG\_SERIAL\_IN\_EP\_DATA\_FREE Represents whether UART TX FIFO has space available. 0: UART TX FIFO is full and no data should be written into it 1: UART TX FIFO is not full and data can be written into it After writing USB\_SERIAL\_JTAG\_WR\_DONE, this bit will be 0 until data in UART TX FIFO is read by USB Host. (RO)

USB\_SERIAL\_JTAG\_SERIAL\_OUT\_EP\_DATA\_AVAIL Represents whether there is data in UART RX

- 0: There is no data in UART RX FIFO
- 1: There is data in UART RX FIFO

Submit Documentation Feedback

FIFO. (RO)

## Register 32.3. USB\_SERIAL\_JTAG\_CONF0\_REG (0x0018)

![Image](images/32_Chapter_32_img006_c28e571b.png)

USB\_SERIAL\_JTAG\_PHY\_SEL Configures whether to select internal or external PHY.

- 0: Internal PHY

1: External PHY

(R/W)

USB\_SERIAL\_JTAG\_EXCHG\_PINS\_OVERRIDE Configures whether to enable software control USB

D+ D- exchange.

- 0: Disable

1: Enable

(R/W)

- USB\_SERIAL\_JTAG\_EXCHG\_PINS Configures whether to enable USB D+ D- exchange.

0: Disable

1: Enable

(R/W)

- USB\_SERIAL\_JTAG\_VREFH Configures single-end input high threshold.
- USB\_SERIAL\_JTAG\_VREFL Configures single-end input low threshold.

- 0: 1.76 V

1: 1.84 V

- 2: 1.92 V

3: 2.00 V

(R/W)

0: 0.80 V

1: 0.88 V

2: 0.96 V

3: 1.04 V

(R/W)

USB\_SERIAL\_JTAG\_VREF\_OVERRIDE Configures whether to enable software control input thresh- old.

0: Disable

- 1: Enable

(R/W)

Continued on the next page...

ESP32-C6 TRM (Version 1.1)

## Register 32.3. USB\_SERIAL\_JTAG\_CONF0\_REG (0x0018)

## Continued from the previous page...

USB\_SERIAL\_JTAG\_PAD\_PULL\_OVERRIDE Configures whether to enable software to control USB

D+ D- pullup and pulldown.

0: Disable

1: Enable

(R/W)

USB\_SERIAL\_JTAG\_DP\_PULLUP Configures whether to enable USB D+ pull up when USB\_SERIAL\_JTAG\_PAD\_PULL\_OVERRIDE is 1.

0: Disable

1: Enable

(R/W)

USB\_SERIAL\_JTAG\_DP\_PULLDOWN Configures whether to enable USB D+ pull down when USB\_SERIAL\_JTAG\_PAD\_PULL\_OVERRIDE is 1.

0: Disable

1: Enable

(R/W)

- USB\_SERIAL\_JTAG\_DM\_PULLDOWN Configures whether to enable USB D- pull down when USB\_SERIAL\_JTAG\_PAD\_PULL\_OVERRIDE is 1.
- USB\_SERIAL\_JTAG\_PULLUP\_VALUE Configures the pull up value when USB\_SERIAL\_JTAG\_PAD\_PULL\_OVERRIDE is 1.

0: Disable

1: Enable

(R/W)

0: 2.2 K

1: 1.1 K

(R/W)

USB\_SERIAL\_JTAG\_USB\_PAD\_ENABLE Configures whether to enable USB pad function.

- 0: Disable

1: Enable

(R/W)

- USB\_SERIAL\_JTAG\_USB\_JTAG\_BRIDGE\_EN Configures whether to disconnect usb\_jtag and inter-

nal JTAG.

0: usb\_jtag is connected to the internal JTAG port of CPU

1: usb\_jtag and the internal JTAG are disconnected, MTMS, MTDI, and MTCK are output through GPIO Matrix, and MTDO is input through GPIO Matrix

(R/W)

## Register 32.4. USB\_SERIAL\_JTAG\_TEST\_REG (0x001C)

![Image](images/32_Chapter_32_img007_dd6f43ca.png)

USB\_SERIAL\_JTAG\_TEST\_ENABLE Configures whether to enable the test mode of the USB pad.

- 0: Resume normal operation

Enabling the test mode of the USB pad allows the USB pad to be controlled/read using the other bits in this register.

- 1: Enable the test mode of the USB pad (R/W)

USB\_SERIAL\_JTAG\_TEST\_USB\_OE Configures whether to enable USB pad output.

- 1: Output the values set in USB\_SERIAL\_JTAG\_TEST\_TX\_DP and USB\_SERIAL\_JTAG\_TEST\_TX\_DM on the D+ and D- pins
- 0: Set D+ and D- to high impedance (R/W)
- USB\_SERIAL\_JTAG\_TEST\_TX\_DP Configures value of USB D+ in test mode when USB\_SERIAL\_JTAG\_TEST\_USB\_OE is 1. (R/W)
- USB\_SERIAL\_JTAG\_TEST\_TX\_DM Configures value of USB D- in test mode when USB\_SERIAL\_JTAG\_TEST\_USB\_OE is 1. (R/W)
- USB\_SERIAL\_JTAG\_TEST\_RX\_RCV Represents the current logical level of the voltage difference between USB D- and USB D+ pads in test mode.

0: USB D- voltage is higher than USB D+

1: USB D+ voltage is higher than USB D-

(RO)

- USB\_SERIAL\_JTAG\_TEST\_RX\_DP Represents the logical level of the USB D+ pad in test mode. (RO)
- USB\_SERIAL\_JTAG\_TEST\_RX\_DM Represents the logical level of the USB D- pad in test mode. (RO)

## Register 32.5. USB\_SERIAL\_JTAG\_MISC\_CONF\_REG (0x0044)

![Image](images/32_Chapter_32_img008_40815f02.png)

USB\_SERIAL\_JTAG\_CLK\_EN Configures whether to force clock on for register.

- 0: Support clock only when application writes registers

1: Force clock on for register

(R/W)

Register 32.6. USB\_SERIAL\_JTAG\_MEM\_CONF\_REG (0x0048)

![Image](images/32_Chapter_32_img009_3896d0ab.png)

USB\_SERIAL\_JTAG\_USB\_MEM\_PD Configures whether to power down USB memory.

- 0: No effect
- 1: Power down
- (R/W)
- USB\_SERIAL\_JTAG\_USB\_MEM\_CLK\_EN Configures whether to force clock on for USB memory.
- 0: No effect
- 1: Force
- (R/W)

## Register 32.7. USB\_SERIAL\_JTAG\_CHIP\_RST\_REG (0x004C)

![Image](images/32_Chapter_32_img010_04fa476e.png)

USB\_SERIAL\_JTAG\_RTS Represents the state of RTS signal as set by the most recent SET\_LINE\_CODING command. (RO)

USB\_SERIAL\_JTAG\_DTR Represents the state of DTR signal as set by the most recent SET\_LINE\_CODING command. (RO)

USB\_SERIAL\_JTAG\_USB\_UART\_CHIP\_RST\_DIS Configures whether to disable chip reset from USB serial channel.

0: No effect

- 1: Disable

(R/W)

![Image](images/32_Chapter_32_img011_c8028bca.png)

USB\_SERIAL\_JTAG\_GET\_DW\_DTE\_RATE Configures the value of dwDTERate set by software, which is requested by GET\_LINE\_CODING command. (R/W)

Register 32.9. USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_W1\_REG (0x005C)

![Image](images/32_Chapter_32_img012_527e79eb.png)

- USB\_SERIAL\_JTAG\_GET\_BDATA\_BITS Configures the value of bDataBits set by software, which is requested by GET\_LINE\_CODING command. (R/W)

USB\_SERIAL\_JTAG\_GET\_BPARITY\_TYPE Configures the value of bParityType set by software, which is requested by GET\_LINE\_CODING command. (R/W)

USB\_SERIAL\_JTAG\_GET\_BCHAR\_FORMAT Configures the value of bCharFormat set by software, which is requested by GET\_LINE\_CODING command. (R/W)

Register 32.10. USB\_SERIAL\_JTAG\_CONFIG\_UPDATE\_REG (0x0060)

![Image](images/32_Chapter_32_img013_c9ab38e4.png)

USB\_SERIAL\_JTAG\_CONFIG\_UPDATE Configures whether to update the value of configuration registers from APB clock domain to 48 MHz clock domain.

0: No effect

- 1: Update

(WT)

## Register 32.11. USB\_SERIAL\_JTAG\_SER\_AFIFO\_CONFIG\_REG (0x0064)

![Image](images/32_Chapter_32_img014_d0fa10b6.png)

- USB\_SERIAL\_JTAG\_SERIAL\_IN\_AFIFO\_RESET\_WR Configures whether to reset CDC\_ACM IN async FIFO write clock domain.
- 0: No effect

1: Reset

(R/W)

- USB\_SERIAL\_JTAG\_SERIAL\_IN\_AFIFO\_RESET\_RD Configures whether to reset CDC\_ACM IN async FIFO read clock domain.
- 0: No effect

1: Reset

(R/W)

- USB\_SERIAL\_JTAG\_SERIAL\_OUT\_AFIFO\_RESET\_WR Configures whether to reset CDC\_ACM OUT

async FIFO write clock domain.

- 0: No effect
- 1: Reset

(R/W)

- USB\_SERIAL\_JTAG\_SERIAL\_OUT\_AFIFO\_RESET\_RD Configures whether to reset CDC\_ACM OUT async FIFO read clock domain.
- 0: No effect
- 1: Reset

(R/W)

- USB\_SERIAL\_JTAG\_SERIAL\_OUT\_AFIFO\_REMPTY Represents CDC\_ACM OUT async FIFO empty signal in read clock domain. (RO)

USB\_SERIAL\_JTAG\_SERIAL\_IN\_AFIFO\_WFULL Represents CDC\_ACM IN async FIFO full signal in write clock domain. (RO)

## Register 32.12. USB\_SERIAL\_JTAG\_INT\_RAW\_REG (0x0008)

![Image](images/32_Chapter_32_img015_992461a7.png)

USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_SOF\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_SOF\_INT . (R/WTC/SS)

USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_PID\_ERR\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_PID\_ERR\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT. (R/WTC/SS)

Continued on the next page...

Submit Documentation Feedback

## Register 32.12. USB\_SERIAL\_JTAG\_INT\_RAW\_REG (0x0008)

## Continued from the previous page...

USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_RTS\_CHG\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_RTS\_CHG\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_DTR\_CHG\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_DTR\_CHG\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_INT. (R/WTC/SS)

USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_INT\_RAW The raw interrupt status of USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_INT. (R/WTC/SS)

Submit Documentation Feedback

## Register 32.13. USB\_SERIAL\_JTAG\_INT\_ST\_REG (0x000C)

![Image](images/32_Chapter_32_img016_511e9e2a.png)

![Image](images/32_Chapter_32_img017_8d71d42a.png)

Continued on the next page...

## Register 32.13. USB\_SERIAL\_JTAG\_INT\_ST\_REG (0x000C)

## Continued from the previous page...

| USB_SERIAL_JTAG_RTS_CHG_INT_ST  The  USB_SERIAL_JTAG_RTS_CHG_INT. (RO)                                      | masked   | interrupt   | status   | of   |
|-------------------------------------------------------------------------------------------------------------|----------|-------------|----------|------|
| USB_SERIAL_JTAG_DTR_CHG_INT_ST  The  USB_SERIAL_JTAG_DTR_CHG_INT. (RO)                                      | masked   | interrupt   | status   | of   |
| USB_SERIAL_JTAG_GET_LINE_CODE_INT_ST The masked interrupt status of USB_SERIAL_JTAG_GET_LINE_CODE_INT. (RO) |          |             |          |      |
| USB_SERIAL_JTAG_SET_LINE_CODE_INT_ST The masked interrupt status of USB_SERIAL_JTAG_SET_LINE_CODE_INT. (RO) |          |             |          |      |

![Image](images/32_Chapter_32_img018_4d8035eb.png)

## Register 32.14. USB\_SERIAL\_JTAG\_INT\_ENA\_REG (0x0010)

![Image](images/32_Chapter_32_img019_a72f3af3.png)

USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT. (R/W)

## USB\_SERIAL\_JTAG\_SOF\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_SOF\_INT. (R/W)

## USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT\_ENA Write

USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT. (R/W)

USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT\_ENA Write

USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT. (R/W)

USB\_SERIAL\_JTAG\_PID\_ERR\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_PID\_ERR\_INT. (R/W)

USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT

(R/W)

USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT

(R/W)

USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT

(R/W)

USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT\_ENA Write

USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT. (R/W)

USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT\_ENA Write

USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT. (R/W)

USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT\_ENA Write

USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT. (R/W)

USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT\_ENA Write

USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT. (R/W)

Continued on the next page...

.

.

.

enable enable

enable enable

1

to to

Submit Documentation Feedback

1

1

1

1

1

to to

to to

enable enable

## Register 32.14. USB\_SERIAL\_JTAG\_INT\_ENA\_REG (0x0010)

## Continued from the previous page...

- USB\_SERIAL\_JTAG\_RTS\_CHG\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_RTS\_CHG\_INT . (R/W)
- USB\_SERIAL\_JTAG\_DTR\_CHG\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_DTR\_CHG\_INT . (R/W)
- USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_INT. (R/W)
- USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_INT\_ENA Write 1 to enable USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_INT. (R/W)

![Image](images/32_Chapter_32_img020_b27744b7.png)

## Register 32.15. USB\_SERIAL\_JTAG\_INT\_CLR\_REG (0x0014)

![Image](images/32_Chapter_32_img021_bba33747.png)

USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT

(WT)

USB\_SERIAL\_JTAG\_SOF\_INT\_CLR

Write 1 to clear USB\_SERIAL\_JTAG\_SOF\_INT. (WT)

- USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT. (WT)
- USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT. (WT)

USB\_SERIAL\_JTAG\_PID\_ERR\_INT\_CLR

Write 1 to clear USB\_SERIAL\_JTAG\_PID\_ERR\_INT. (WT)

- USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT . (WT)
- USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT . (WT)
- USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT . (WT)
- USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT. (WT)
- USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT . (WT)
- USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT. (WT)
- USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT. (WT)

Continued on the next page...

.

## Register 32.15. USB\_SERIAL\_JTAG\_INT\_CLR\_REG (0x0014)

Continued from the previous page...

USB\_SERIAL\_JTAG\_RTS\_CHG\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_RTS\_CHG\_INT. (WT)

USB\_SERIAL\_JTAG\_DTR\_CHG\_INT\_CLR

Write 1 to clear USB\_SERIAL\_JTAG\_DTR\_CHG\_INT. (WT)

USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_GET\_LINE\_CODE\_INT . (WT)

- USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_INT\_CLR Write 1 to clear USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_INT . (WT)

## Register 32.16. USB\_SERIAL\_JTAG\_JFIFO\_ST\_REG (0x0020)

![Image](images/32_Chapter_32_img022_48b4370d.png)

USB\_SERIAL\_JTAG\_IN\_FIFO\_CNT Represents JTAG IN FIFO counter. (RO)

USB\_SERIAL\_JTAG\_IN\_FIFO\_EMPTY Represents whether JTAG IN FIFO is empty.

- 0: Not empty
- 1: Empty
- (RO)

USB\_SERIAL\_JTAG\_IN\_FIFO\_FULL Represents whether JTAG IN FIFO is full.

- 0: Not full
- 1: Full

(RO)

USB\_SERIAL\_JTAG\_OUT\_FIFO\_CNT Represents JTAG OUT FIFO counter. (RO)

USB\_SERIAL\_JTAG\_OUT\_FIFO\_EMPTY Represents whether JTAG OUT FIFO is empty.

- 0: Not empty
- 1: Empty

(RO)

- USB\_SERIAL\_JTAG\_OUT\_FIFO\_FULL Represents whether JTAG OUT FIFO is full.
- 0: Not full
- 1: Full

(RO)

USB\_SERIAL\_JTAG\_IN\_FIFO\_RESET Configures whether to reset JTAG IN FIFO.

- 0: No effect
- 1: Reset

(R/W)

USB\_SERIAL\_JTAG\_OUT\_FIFO\_RESET Configures whether to reset JTAG OUT FIFO.

- 0: No effect
- 1: Reset

(R/W)

Register 32.17. USB\_SERIAL\_JTAG\_FRAM\_NUM\_REG (0x0024)

![Image](images/32_Chapter_32_img023_0698aa17.png)

USB\_SERIAL\_JTAG\_SOF\_FRAME\_INDEX Represents frame index of received SOF frame. (RO)

## Register 32.18. USB\_SERIAL\_JTAG\_IN\_EP0\_ST\_REG (0x0028)

![Image](images/32_Chapter_32_img024_59e1c59c.png)

USB\_SERIAL\_JTAG\_IN\_EP0\_STATE Represents state of IN Endpoint 0. (RO)

USB\_SERIAL\_JTAG\_IN\_EP0\_WR\_ADDR Represents write data address of IN endpoint 0. (RO)

USB\_SERIAL\_JTAG\_IN\_EP0\_RD\_ADDR Represents read data address of IN endpoint 0. (RO)

![Image](images/32_Chapter_32_img025_2e46047d.png)

Register 32.19. USB\_SERIAL\_JTAG\_IN\_EP1\_ST\_REG (0x002C)

![Image](images/32_Chapter_32_img026_6ed0e72c.png)

USB\_SERIAL\_JTAG\_IN\_EP1\_STATE Represents state of IN Endpoint 1. (RO)

USB\_SERIAL\_JTAG\_IN\_EP1\_WR\_ADDR Represents write data address of IN endpoint 1. (RO)

USB\_SERIAL\_JTAG\_IN\_EP1\_RD\_ADDR Represents read data address of IN endpoint 1. (RO)

## Register 32.20. USB\_SERIAL\_JTAG\_IN\_EP2\_ST\_REG (0x0030)

![Image](images/32_Chapter_32_img027_df351911.png)

USB\_SERIAL\_JTAG\_IN\_EP2\_STATE Represents state of IN Endpoint 2. (RO)

USB\_SERIAL\_JTAG\_IN\_EP2\_WR\_ADDR Represents write data address of IN endpoint 2. (RO)

USB\_SERIAL\_JTAG\_IN\_EP2\_RD\_ADDR Represents read data address of IN endpoint 2. (RO)

Register 32.21. USB\_SERIAL\_JTAG\_IN\_EP3\_ST\_REG (0x0034)

![Image](images/32_Chapter_32_img028_ab14789c.png)

USB\_SERIAL\_JTAG\_IN\_EP3\_STATE Represents state of IN Endpoint 3. (RO) USB\_SERIAL\_JTAG\_IN\_EP3\_WR\_ADDR Represents write data address of IN endpoint 3. (RO) USB\_SERIAL\_JTAG\_IN\_EP3\_RD\_ADDR Represents read data address of IN endpoint 3. (RO)

Register 32.22. USB\_SERIAL\_JTAG\_OUT\_EP0\_ST\_REG (0x0038)

![Image](images/32_Chapter_32_img029_62f2a099.png)

USB\_SERIAL\_JTAG\_OUT\_EP0\_STATE Represents state of OUT Endpoint 0. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP0\_WR\_ADDR Represents write data address of OUT endpoint 0. When USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT is detected, there are (USB\_SERIAL\_JTAG\_OUT\_EP0\_WR\_ADDR − 2) bytes data in OUT endpoint 0. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP0\_RD\_ADDR Represents read data address of OUT endpoint 0. (RO)

Register 32.23. USB\_SERIAL\_JTAG\_OUT\_EP1\_ST\_REG (0x003C)

![Image](images/32_Chapter_32_img030_6a41ad6d.png)

USB\_SERIAL\_JTAG\_OUT\_EP1\_STATE Represents state of OUT Endpoint 1. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP1\_WR\_ADDR Represents write data address of OUT endpoint 1. When USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT is detected, there are (USB\_SERIAL\_JTAG\_OUT\_EP1\_WR\_ADDR − 2) bytes data in OUT endpoint 1. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP1\_RD\_ADDR Represents read data address of OUT endpoint 1. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP1\_REC\_DATA\_CNT Represents data count in OUT endpoint 1 when one packet is received. (RO)

Register 32.24. USB\_SERIAL\_JTAG\_OUT\_EP2\_ST\_REG (0x0040)

![Image](images/32_Chapter_32_img031_b9a1885e.png)

USB\_SERIAL\_JTAG\_OUT\_EP2\_STATE Represents state of OUT Endpoint 2. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP2\_WR\_ADDR Represents write data address of OUT endpoint 2.

When USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT is detected there are (USB\_SERIAL\_JTAG\_OUT\_EP2\_WR\_ADDR − 2) bytes data in OUT endpoint 2. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP2\_RD\_ADDR Represents read data address of OUT endpoint 2. (RO)

![Image](images/32_Chapter_32_img032_8412c9a7.png)

Register 32.25. USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_W0\_REG (0x0050)

![Image](images/32_Chapter_32_img033_b97ff467.png)

USB\_SERIAL\_JTAG\_DW\_DTE\_RATE Represents the value of dwDTERate set by host through SET\_LINE\_CODING command. (RO)

Register 32.26. USB\_SERIAL\_JTAG\_SET\_LINE\_CODE\_W1\_REG (0x0054)

![Image](images/32_Chapter_32_img034_f8d1bd6b.png)

USB\_SERIAL\_JTAG\_BCHAR\_FORMAT Represents the value of bCharFormat set by host through SET\_LINE\_CODING command. (RO)

USB\_SERIAL\_JTAG\_BPARITY\_TYPE Represents the value of bParityTpye set by host through SET\_LINE\_CODING command. (RO)

USB\_SERIAL\_JTAG\_BDATA\_BITS Represents the value of bDataBits set by host through SET\_LINE\_CODING command. (RO)

![Image](images/32_Chapter_32_img035_4afeb596.png)
