---
chapter: 30
title: "Chapter 30"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 30

## USB Serial/JTAG Controller (USB\_SERIAL\_JTAG)

The ESP32-C3 contains an USB Serial/JTAG Controller. This unit can be used to program the SoC's flash, read program output, as well as attach a debugger to the running program. All of these are possible for any computer with a USB host ('host' in the rest of this text) without any active external components.

## 30.1 Overview

While programming and debugging an ESP32-C3 project using the UART and JTAG functionality is certainly possible, it has a few downsides. First of all, both UART and JTAG take up IO pins and as such, fewer pins are left usable for controlling external signals in software. Additionally, an external chip or adapter is needed for both UART and JTAG to interface with a host computer, which means it will be necessary to integrate these two functionalities in the form of external chips or debugging adapters.

In order to alleviate these issues„ as well as to negate the need for external devices, the ESP32-C3 contains an USB Serial/JTAG Controller, which integrates the functionality of both an USB-to-serial converter as well as those of an USB-to-JTAG adapter. As this device directly interfaces to an external USB host using only the two data lines required by USB2.0, debugging the ESP32-C3 only requires two pins to be dedicated to this functionality.

## 30.2 Features

- USB Full-speed device.
- Fixed function device, hardwired for CDC-ACM (Communication Device Class - Abstract Control Model) and JTAG adapter functionality.
- 2 OUT Endpoints, 3 IN Endpoints in addition to Control Endpoint 0; Up to 64-byte data payload size.
- Internal PHY, so no or very few external components needed to connect to a host computer.
- CDC-ACM adherent serial port emulation is plug-and-play on most modern OSes.
- JTAG interface allows fast communication with CPU debug core using a compact representation of JTAG instructions.
- CDC-ACM supports host controllable chip reset and entry into download mode.

As shown in Figure 30.2-1, the USB Serial/JTAG Controller consists of an USB PHY, a USB device interface, a JTAG command processor and a response capture unit, as well as the CDC-ACM registers. The PHY and part of the device interface are clocked from a 48 MHz clock derived from the main PLL, the rest of the logic is clocked from APB\_CLK. The JTAG command processor is connected to the JTAG debug unit of the main processor; the CDC-ACM registers are connected to the APB bus and as such can be read from and written to by software running on the main CPU.

Figure 30.2-1. USB Serial/JTAG High Level Diagram

![Image](images/30_Chapter_30_img001_2d270c89.png)

Note that while the USB Serial/JTAG device is a USB 2.0 device, it only supports Full-speed (12 Mbps) and not the High-speed (480 Mbps) mode the USB2.0 standard introduced.

Figure 30.2-2 shows the internal details of the USB Serial/JTAG controller on the USB side. The USB Serial/JTAG Controller consists of an USB 2.0 Full Speed device. It contains a control endpoint, a dummy interrupt endpoint, two bulk input endpoints as well as two bulk output endpoints. Together, these form an USB Composite device, which consists of an CDC-ACM USB class device as well as a vendor-specific device implementing the JTAG interface. On the SoC side, the JTAG interface is directly connected to the RISC-V CPU's debugging interface, allowing debugging of programs running on that core. Meanwhile, the CDC-ACM device is exposed as a set of registers, allowing a program on the CPU to read and write from this. Additionally, the ROM startup code of the SoC contains code allowing the user to reprogram attached flash memory using this interface.

## 30.3 Functional Description

The USB Serial/JTAG Controller interfaces with an USB host processor on one side, and the CPU debug hardware as well as the software running on the USB port on the other side.

## 30.3.1 CDC-ACM USB Interface Functional Description

The CDC-ACM interface adheres to the standard USB CDC-ACM class for serial port emulation. It contains a dummy interrupt endpoint (which will never send any events, as they are not implemented nor needed) and a Bulk IN as well as a Bulk OUT endpoint for the host's received and sent serial data respectively. These endpoints can handle 64-byte packets at a time, allowing for high throughput. As CDC-ACM is a standard USB device class, a host generally does not need any special installation procedures for it to function: when the USB debugging device is properly connected to a host, the operating system should show a new serial port moments later.

The CDC-ACM interface accepts the following standard CDC-ACM control requests:

![Image](images/30_Chapter_30_img002_5b1ec7f7.png)

Figure 30.2-2. USB Serial/JTAG Block Diagram

![Image](images/30_Chapter_30_img003_ee7ddd4d.png)

Table 30.3-1. Standard CDC-ACM Control Requests

| Command                | Action                                                     |
|------------------------|------------------------------------------------------------|
| SEND_BREAK             | Accepted but ignored (dummy)                               |
| SET_LINE_CODING        | Accepted but ignored (dummy)                               |
| GET_LINE_CODING        | Always returns 9600 baud, no parity, 8 databits, 1 stopbit |
| SET_CONTROL_LINE_STATE | Set the state of the RTS/DTR lines, see Table 30.3-2       |

Aside from general-purpose communication, the CDC-ACM interface also can be used to reset the ESP32-C3 and optionally make it go into download mode in order to flash new firmware. This is done by setting the RTS and DTR lines on the virtual serial port.

Table 30.3-2. CDC-ACM Settings with RTS and DTR

|   RTS |   DTR | Action                   |
|-------|-------|--------------------------|
|     0 |     0 | Clear download mode flag |
|     0 |     1 | Set download mode flag   |
|     1 |     0 | Reset ESP32-C3           |
|     1 |     1 | No action                |

Note that if the download mode flag is set when the ESP32-C3 is reset, the ESP32-C3 will reboot into download mode. When this flag is cleared and the chip is reset, the ESP32-C3 will boot from flash. For specific sequences, please refer to Section 30.4. All these functions can also be disabled by programming various eFuses, please refer to Chapter 4 eFuse Controller (EFUSE) for more details.

![Image](images/30_Chapter_30_img004_6c537abd.png)

## 30.3.2 CDC-ACM Firmware Interface Functional Description

As the USB Serial/JTAG Controller is connected to the internal APB bus of the ESP32-C3, the CPU can interact with it. This is mainly used to read and write data from and to the virtual serial port on the attached host.

USB CDC-ACM serial data is sent to and received from the host in packets of 0 to 64 bytes in size. When enough CDC-ACM data has accumulated in the host, the host will send a packet to the CDC-ACM receive endpoint, and when the USB Serial/JTAG Controller has a free buffer, it will accept this packet. Conversely, the host will check periodically if the USB Serial/JTAG Controller has a packet ready to be sent to the host, and if so, receive this packet.

Firmware can get notified of new data from the host in one of two ways. First of all, the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_EP\_DATA\_AVAIL bit will remain set to one as long as there still is unread host data in the buffer. Secondly, the availability of data will trigger the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT interrupt as well.

When data is available, it can be read by firmware by repeatedly reading bytes from USB\_SERIAL\_JTAG\_EP1\_REG. The amount of bytes to read can be determined by checking the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_EP\_DATA\_AVAIL bit after reading each byte to see if there is more data to read. After all data is read, the USB debug device is automatically readied to receive a new data packet from the host.

When the firmware has data to send, it can do so by putting it in the send buffer and triggering a flush, allowing the host to receive the data in a USB packet. In order to do so, there needs to be space available in the send buffer. Firmware can check this by reading USB\_REG\_SERIAL\_IN\_EP\_DATA\_FREE; a one in this register field indicates there is still free room in the buffer. While this is the case, firmware can fill the buffer by writing bytes to the USB\_SERIAL\_JTAG\_EP1\_REG register.

Writing the buffer doesn't immediately trigger sending data to the host. This does not happen until the buffer is flushed; a flush causes the entire buffer to be readied for reception by the USB host at once. A flush can be triggered in two ways: after the 64th byte is written to the buffer, the USB hardware will automatically flush the buffer to the host. Alternatively, firmware can trigger a flush by writing a one to USB\_REG\_SERIAL\_WR\_DONE .

Regardless of how a flush is triggered, the send buffer will be unavailable for firmware to write into until it has been fully read by the host. As soon as this happens, the USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT interrupt will be triggered, indicating the send buffer can receive another 64 bytes.

## 30.3.3 USB-to-JTAG Interface

The USB-to-JTAG interface uses a vendor-specific class for its implementation. It consists of two endpoints, one to receive commands and one to send responses. Additionally, some less time-sensitive commands can be given as control requests.

## 30.3.4 JTAG Command Processor

Commands from the host to the JTAG interface are interpreted by the JTAG command processor. Internally, the JTAG command processor implements a full four-wire JTAG bus, consisting of the TCK, TMS and TDI output lines to the RISC-V CPU, as well as the TDO line signalling back from the CPU to the JTAG response

capture unit. These signals adhere to the IEEE 1149.1 JTAG standards. Additionally, there is a SRST line to reset the SoC.

The JTAG command processor parses each received nibble (4-bit value) as a command. As USB data is received in 8-bit bytes, this means each byte contains two commands. The USB command processor will execute high-nibble first and low-nibble second. The commands are used to control the TCK, TMS, TDI, and SRST lines of the internal JTAG bus, as well as signal the JTAG response capture unit that the state of the TDO line (which is driven by the CPU debug logic) needs to be captured.

Of this internal JTAG bus, TCK, TMS, TDI and TDO are connected directly to the JTAG debugging logic of the RISC-V CPU. SRST is connected to the reset logic of the digital circuitry in the SoC and a high level on this line will cause a digital system reset. Note that the USB Serial/JTAG Controller itself is not affected by SRST.

A nibble can contain the following commands:

Table 30.3-3. Commands of a Nibble

| bit       | 3  2  1  0    |
|-----------|---------------|
| CMD_CLK   | 0 cap tms tdi |
| CMD_RST   | 1 0 0 srst    |
| CMD_FLUSH | 1 0 1 0       |
| CMD_RSV   | 1 0 1 1       |
| CMD_REP   | 1 1 R1 R0     |

- CMD\_CLK will set the TDI and TMS to the indicated values and emit one clock pulse on TCK. If the CAP bit is 1, it will also instruct the JTAG response capture unit to capture the state of the TDO line. This instruction forms the basis of JTAG communication.
- CMD\_RST will set the state of the SRST line to the indicated value. This can be used to reset the ESP32-C3.
- CMD\_FLUSH will instruct the JTAG response capture unit to flush the buffer of all bits it collected so the host is able to read them. Note that in some cases, a JTAG transaction will end in an odd number of commands and as such an odd number of nibbles. In this case, it is allowable to repeat the CMD\_FLUSH to get an even number of nibbles fitting an integer number of bytes.
- CMD\_RSV is reserved in the current implementation. The ESP32-C3 will ignore this command when it receives it.
- CMD\_REP repeats the last (non-CMD\_REP) command a certain number of times. It's intended goal is to compress command streams which repeat the same CMD\_CLK instruction multiple times. A command like CMD\_CLK can be followed by multiple CMD\_REP commands. The number of repetitions done by one CMD\_REP can be expressed as no \_ repetitions = (R1 × 2 + R0) × (4 cmd \_ rep \_ count ), where cmd\_rep\_count is how many CMD\_REP instructions went directly before it. Note that the CMD\_REP is only intended to repeat a CMD\_CLK command. Specifically, using it on a CMD\_FLUSH command may lead to an unresponsive USB device, needing an USB reset to recover.

## 30.3.5 USB-to-JTAG Interface: CMD\_REP usage example

Here is a list of commands as an illustration of the use of CMD\_REP. Note each command is a nibble; in this example the bytewise command stream would be 0x0D 0x5E 0xCF.

1. 0x0 (CMD\_CLK: cap=0, tdi=0, tms=0)
2. 0xD (CMD\_REP: R1=0, R0=1)
3. 0x5 (CMD\_CLK: cap=1, tdi=0, tms=1)
4. 0xE (CMD\_REP: R1=1, R0=0)
5. 0xC (CMD\_REP: R1=0, R0=0)
6. 0xF (CMD\_REP: R1=1, R0=1)

This is what happens at every step:

1. TCK is clocked with the TDI and TMS lines set to 0. No data is captured.
2. TCK is clocked another (0 × 2 + 1) × (4 0 ) = 1 time with the same settings as step 1.
3. TCK is clocked with the TDI line set to 0 and TMS set to 1. Data on the TDO line is captured.
4. TCK is clocked another (1 × 2 + 0) × (4 0 ) = 2 times with the same settings as step 3.
5. Nothing happens: (0 × 2 + 0) × (4 1 ) = 0. Note that this does increase cmd\_rep\_count for the next step.
6. TCK is clocked another (1 × 2 + 1) × (4 2 ) = 48 times with the same settings as step 3.

In other words: This example stream has the same net effect as command 1 twice, then repeating command 3 for 51 times.

## 30.3.6 USB-to-JTAG Interface: Response Capture Unit

The response capture unit reads the TDO line of the internal JTAG bus and captures its value when the command parser executes a CMD\_CLK with cap=1. It puts this bit into an internal shift register, and writes a byte into the USB buffer when 8 bits have been collected. Of these 8 bits, the least significant one is the one that is read from TDO the earliest.

As soon as either 64 bytes (512 bits) have been collected or a CMD\_FLUSH command is executed, the response capture unit will make the buffer available for the host to receive. Note that the interface to the USB logic is double-buffered. This way, as long as USB throughput is sufficient, the response capture unit can always receive more data: while one of the buffers is waiting to be sent to the host, the other one can receive more data. When the host has received data from its buffer and the response capture unit flushes its buffer, the two buffers change position.

This also means that a command stream can cause at most 128 bytes of capture data to be generated (less if there are flush commands in the stream) without the host acting to receive the generated data. If more data is generated anyway, the command stream is paused and the device will not accept more commands before the generated capture data is read out.

Note that in general, the logic of the response capture unit tries not to send zero-byte responses: for instance, sending a series of CMD\_FLUSH commands will not cause a series of zero-byte USB responses to be sent. However, in the current implementation, some zero-byte responses may be generated in extraordinary circumstances. It's recommended to ignore these responses.

## 30.3.7 USB-to-JTAG Interface: Control Transfer Requests

Aside from the command processor and the response capture unit, the USB-to-JTAG interface also understands some control requests, as documented in the table below:

Table 30.3-4. USB-to-JTAG Control Requests

| bmRequestType   | bRequest             | wValue    | wIndex    |   wLength | Data            |
|-----------------|----------------------|-----------|-----------|-----------|-----------------|
| 01000000b       | 0 (VEND_JTAG_SETDIV) | [divider] | interface |         0 | None            |
| 01000000b       | 1 (VEND_JTAG_SETIO)  | [iobits]  | interface |         0 | None            |
| 11000000b       | 2 (VEND_JTAG_GETTDO) | 0         | interface |         1 | [iostate]       |
| 10000000b       | 6 (GET_DESCRIPTOR)   | 0x2000    | 0         |       256 | [jtag cap desc] |

- VEND\_JTAG\_SETDIV sets the divider used. This directly affects the duration of a TCK clock pulse. The TCK clock pulses are derived from APB\_CLK, which is divided down using an internal divider. This control request allows the host to set this divider. Note that on startup, the divider is set to 2, meaning the TCK clock rate will generally be 40 MHz.
- VEND\_JTAG\_SETIO can bypass the JTAG command processor to set the internal TDI, TDO, TMS and SRST lines to given values. These values are encoded in the wValue field in the format of 11'b0, srst, trst, tck, tms, tdi.
- VEND\_JTAG\_GETTDO can bypass the JTAG response capture unit to read the internal TDO signal directly. This request returns one byte of data, of which the least significant bit represents the status of the TDO line.
- GET\_DESCRIPTOR is a standard USB request, however it can also be used with a vendor-specific wValue of 0x2000 to get the JTAG capabilities descriptor. This returns a certain amount of bytes representing the following fixed structure, which describes the capabilities of the USB-to-JTAG adapter. This structure allows host software to automatically support future revisions of the hardware without needing an update.

The JTAG capabilities descriptor of the ESP32-C3 is as follows. Note that all 16-bit values are little-endian.

Table 30.3-5. JTAG Capabilities Descriptor

| Byte   |   Value | Description                                                                         |
|--------|---------|-------------------------------------------------------------------------------------|
| 0      |       1 | JTAG protocol capabilities structure version                                        |
| 1      |      10 | Total length of JTAG protocol capabilities                                          |
| 2      |       1 | Type of this struct: 1 for speed capabilities struct                                |
| 3      |       8 | Length of this speed capabilities struct                                            |
| 4 ~ 5  |    8000 | APB_CLK speed in 10 kHz increments. Note that the maximal TCK speed is half of this |
| 6 ~ 7  |       1 | Minimum divisor settable by the VEND_JTAG_SETDIV request                            |
| 8 ~ 9  |     255 | Maximum divisor settable by the VEND_JTAG_SETDIV request                            |

## 30.4 Recommended Operation

## Note:

When burning EFUSE\_DIS\_PAD\_JTAG and EFUSE\_DIS\_USB\_JTAG, e.g., when preparing for secure boot, the USB Serial/JTAG controller may lose connection until ESP32-C3 reboots.

There is very little setup needed in order to use the USB Serial/JTAG Device. The USB-to-JTAG hardware itself does not need any setup aside from the standard USB initialization the host operating system already does. The CDC-ACM emulation, on the host side, also is plug-and-play.

On the firmware side, very little initialization should be needed either: the USB hardware is self-initializing and after boot-up, if a host is connected and listening on the CDC-ACM interface, data can be exchanged as described above without any specific setup aside from the firmware optionally setting up an interrupt service handler.

One thing to note is that there may be situations where the host is either not attached or the CDC-ACM virtual port is not opened. In this case, the packets that are flushed to the host will never be picked up and the transmit buffer will never be empty. It is important to detect this and time out, as this is the only way to reliably detect that the port on the host side is closed.

Another thing to note is that the USB device is dependent on both the PLL for the 48 MHz USB PHY clock, as well as APB\_CLK. Specifically, an APB\_CLK of 40 MHz or more is required for proper USB compliant operation, although the USB device will still function with most hosts with an APB\_CLK as low as 10 MHz. Behaviour shown when this happens is dependent on the host USB hardware and drivers, and can include the device being unresponsive and it disappearing when first accessed.

More specifically, the APB\_CLK will be affected by clock gating the USB Serial/JTAG Controller, which may happen in Light Sleep. Additionally, the USB serial/JTAG Controller (as well as the attached RISC-V CPU) will be entirely powered down in Deep Sleep mode. If a device needs to be debugged in either of these two modes, it may be preferable to use an external JTAG debugger and serial interface instead.

The CDC-ACM interface can also be used to reset the SoC and take it into or out of download mode. Generating the correct sequence of handshake signals can be a bit complicated: Most operating systems only allow setting or resetting DTR and RTS separately, and not in tandem. Additionally, some drivers (e.g. the standard CDC-ACM driver on Windows) do not set DTR until RTS is set and the user needs to explicitly set RTS in order to 'propagate' the DTR value. These are the recommended procedures:

To reset the SoC into download mode:

Table 30.4-1. Reset SoC into Download Mode

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

Table 30.4-2. Reset SoC into Booting

| Action    | Internal state   | Note                |
|-----------|------------------|---------------------|
| Clear DTR | RTS=?, DTR=0     | -                   |
| Clear RTS | RTS=0, DTR=0     | Clear download flag |
| Set RTS   | RTS=1, DTR=0     | Reset SoC           |
| Clear RTS | RTS=0, DTR=0     | Exit reset          |

## 30.5 Register Summary

The addresses in this section are relative to USB Serial/JTAG Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

R/WTC/SS

| Name                           | Description                                                | Address   | Access   |
|--------------------------------|------------------------------------------------------------|-----------|----------|
| Configuration Registers        |                                                            |           |          |
| USB_SERIAL_JTAG_EP1_REG        | FIFO access for the CDC-ACM data IN and OUT endpoints      | 0x0000    | R/W      |
| USB_SERIAL_JTAG_CONF0_REG      | PHY hardware configuration                                 | 0x0018    | R/W      |
| USB_SERIAL_JTAG_TEST_REG       | Registers used for debugging the PHY                       | 0x001C    | R/W      |
| USB_SERIAL_JTAG_MISC_CONF_REG  | Clock enable control                                       | 0x0044    | R/W      |
| USB_SERIAL_JTAG_MEM_CONF_REG   | Memory power control                                       | 0x0048    | R/W      |
| Status Registers               |                                                            |           |          |
| USB_SERIAL_JTAG_EP1_CONF_REG   | Configuration and control registers for the CDC ACM FIFOs | 0x0004    | varies   |
| USB_SERIAL_JTAG_JFIFO_ST_REG   | JTAG FIFO status and control registers                     | 0x0020    | varies   |
| USB_SERIAL_JTAG_FRAM_NUM_REG   | Last received SOF frame index register                     | 0x0024    | RO       |
| USB_SERIAL_JTAG_IN_EP0_ST_REG  | Control IN endpoint status information                     | 0x0028    | RO       |
| USB_SERIAL_JTAG_IN_EP1_ST_REG  | CDC-ACM IN endpoint status information                     | 0x002C    | RO       |
| USB_SERIAL_JTAG_IN_EP2_ST_REG  | CDC-ACM interrupt IN endpoint status informa tion         | 0x0030    | RO       |
| USB_SERIAL_JTAG_IN_EP3_ST_REG  | JTAG IN endpoint status information                        | 0x0034    | RO       |
| USB_SERIAL_JTAG_OUT_EP0_ST_REG | Control OUT endpoint status information                    | 0x0038    | RO       |
| USB_SERIAL_JTAG_OUT_EP1_ST_REG | CDC-ACM OUT endpoint status information                    | 0x003C    | RO       |
| USB_SERIAL_JTAG_OUT_EP2_ST_REG | JTAG OUT endpoint status information                       | 0x0040    | RO       |
| Interrupt Registers            |                                                            |           |          |
| USB_SERIAL_JTAG_INT_RAW_REG    | Interrupt raw status register                              | 0x0008    |          |
| USB_SERIAL_JTAG_INT_ST_REG     | Interrupt status register                                  | 0x000C    | RO       |
| USB_SERIAL_JTAG_INT_ENA_REG    | Interrupt enable status register                           | 0x0010    | R/W      |
| USB_SERIAL_JTAG_INT_CLR_REG    | Interrupt clear status register                            | 0x0014    | WT       |
| Version Registers              |                                                            |           |          |
| USB_SERIAL_JTAG_DATE_REG       | Version register                                           | 0x0080    | R/W      |

## 30.6 Registers

The addresses in this section are relative to USB Serial/JTAG Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 30.1. USB\_SERIAL\_JTAG\_EP1\_REG (0x0000)

![Image](images/30_Chapter_30_img005_fed6c764.png)

USB\_SERIAL\_JTAG\_RDWR\_BYTE Write and read byte data to/from UART Tx/Rx FIFO through this field. When USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT is set then user can write data (up to 64 bytes) into UART Tx FIFO. When USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT is set, user can check USB\_SERIAL\_JTAG\_OUT\_EP1\_WR\_ADDR and USB\_SERIAL\_JTAG\_OUT\_EP1\_RD\_ADDR to know how many data is received, then read that amount of data from UART Rx FIFO. (R/W)

Register 30.2. USB\_SERIAL\_JTAG\_CONF0\_REG (0x0018)

![Image](images/30_Chapter_30_img006_204b47f2.png)

USB\_SERIAL\_JTAG\_PHY\_SEL Select internal/external PHY. 1'b0: internal PHY, 1'b1: external PHY. (R/W)

USB\_SERIAL\_JTAG\_EXCHG\_PINS\_OVERRIDE Enable software control USB D+ D- exchange. (R/W)

USB\_SERIAL\_JTAG\_EXCHG\_PINS USB D+ D- exchange (R/W)

USB\_SERIAL\_JTAG\_VREFL Control single-end input high threshold. 1.76 V to 2 V, step 80 mV. (R/W)

USB\_SERIAL\_JTAG\_VREFH Control single-end input low threshold. 0.8 V to 1.04 V, step 80 mV. (R/W)

USB\_SERIAL\_JTAG\_VREF\_OVERRIDE Enable software control input threshold. (R/W)

USB\_SERIAL\_JTAG\_PAD\_PULL\_OVERRIDE Enable software control USB D+ D- pull-up pull-down. (R/W)

USB\_SERIAL\_JTAG\_DP\_PULLUP Control USB D+ pull-up. (R/W)

USB\_SERIAL\_JTAG\_DP\_PULLDOWN Control USB D+ pull-down. (R/W)

USB\_SERIAL\_JTAG\_DM\_PULLUP Control USB D- pull-up. (R/W)

USB\_SERIAL\_JTAG\_DM\_PULLDOWN Control USB D- pull-down. (R/W)

USB\_SERIAL\_JTAG\_PULLUP\_VALUE Control pull-up value. 0: 2.2 K; 1: 1.1 K. (R/W)

USB\_SERIAL\_JTAG\_USB\_PAD\_ENABLE Enable USB pad function. (R/W)

![Image](images/30_Chapter_30_img007_e40ebbc8.png)

## Register 30.3. USB\_SERIAL\_JTAG\_TEST\_REG (0x001C)

![Image](images/30_Chapter_30_img008_4df98ea8.png)

## Register 30.5. USB\_SERIAL\_JTAG\_MEM\_CONF\_REG (0x0048)

![Image](images/30_Chapter_30_img009_50ae7c1c.png)

USB\_SERIAL\_JTAG\_USB\_MEM\_PD Set to power down USB memory. (R/W)

USB\_SERIAL\_JTAG\_USB\_MEM\_CLK\_EN Set to force clock-on for USB memory. (R/W)

## Register 30.6. USB\_SERIAL\_JTAG\_EP1\_CONF\_REG (0x0004)

![Image](images/30_Chapter_30_img010_fa2e4646.png)

USB\_SERIAL\_JTAG\_WR\_DONE Set this bit to indicate writing byte data to UART Tx FIFO is done. This bit then stays 0 until data in UART Tx FIFO is read by the USB Host. (WT)

USB\_SERIAL\_JTAG\_SERIAL\_IN\_EP\_DATA\_FREE 1'b1: Indicate UART Tx FIFO is not full and data can be written into in. After writing USB\_SERIAL\_JTAG\_WR\_DONE, this will be 1'b0 until the data is sent to the USB Host. (RO)

USB\_SERIAL\_JTAG\_SERIAL\_OUT\_EP\_DATA\_AVAIL 1’b1: Indicate there is data in UART Rx FIFO. (RO)

## Register 30.7. USB\_SERIAL\_JTAG\_JFIFO\_ST\_REG (0x0020)

![Image](images/30_Chapter_30_img011_2bdc45cb.png)

USB\_SERIAL\_JTAG\_IN\_FIFO\_CNT JTAG in FIFO counter. (RO)

USB\_SERIAL\_JTAG\_IN\_FIFO\_EMPTY Set to indicate JTAG in FIFO is empty. (RO)

USB\_SERIAL\_JTAG\_IN\_FIFO\_FULL Set to indicate JTAG in FIFO is full. (RO)

USB\_SERIAL\_JTAG\_OUT\_FIFO\_CNT JTAT out FIFO counter. (RO)

USB\_SERIAL\_JTAG\_OUT\_FIFO\_EMPTY Set to indicate JTAG out FIFO is empty. (RO)

USB\_SERIAL\_JTAG\_OUT\_FIFO\_FULL Set to indicate JTAG out FIFO is full. (RO)

USB\_SERIAL\_JTAG\_IN\_FIFO\_RESET Write 1 to reset JTAG in FIFO. (R/W)

USB\_SERIAL\_JTAG\_OUT\_FIFO\_RESET Write 1 to reset JTAG out FIFO. (R/W)

Register 30.8. USB\_SERIAL\_JTAG\_FRAM\_NUM\_REG (0x0024)

![Image](images/30_Chapter_30_img012_7ad52e69.png)

USB\_SERIAL\_JTAG\_SOF\_FRAME\_INDEX Frame index of received SOF frame. (RO)

Register 30.9. USB\_SERIAL\_JTAG\_IN\_EP0\_ST\_REG (0x0028)

![Image](images/30_Chapter_30_img013_9c5bdcff.png)

USB\_SERIAL\_JTAG\_IN\_EP0\_STATE State of IN Endpoint 0. (RO)

USB\_SERIAL\_JTAG\_IN\_EP0\_WR\_ADDR Write data address of IN endpoint 0. (RO)

USB\_SERIAL\_JTAG\_IN\_EP0\_RD\_ADDR Read data address of IN endpoint 0. (RO)

## Register 30.10. USB\_SERIAL\_JTAG\_IN\_EP1\_ST\_REG (0x002C)

![Image](images/30_Chapter_30_img014_a2b86766.png)

USB\_SERIAL\_JTAG\_IN\_EP1\_STATE State of IN Endpoint 1. (RO)

USB\_SERIAL\_JTAG\_IN\_EP1\_WR\_ADDR Write data address of IN endpoint 1. (RO)

USB\_SERIAL\_JTAG\_IN\_EP1\_RD\_ADDR Read data address of IN endpoint 1. (RO)

Register 30.11. USB\_SERIAL\_JTAG\_IN\_EP2\_ST\_REG (0x0030)

![Image](images/30_Chapter_30_img015_1d594481.png)

USB\_SERIAL\_JTAG\_IN\_EP2\_STATE State of IN Endpoint 2. (RO) USB\_SERIAL\_JTAG\_IN\_EP2\_WR\_ADDR Write data address of IN endpoint 2. (RO) USB\_SERIAL\_JTAG\_IN\_EP2\_RD\_ADDR Read data address of IN endpoint 2. (RO)

Register 30.12. USB\_SERIAL\_JTAG\_IN\_EP3\_ST\_REG (0x0034)

![Image](images/30_Chapter_30_img016_4c30c805.png)

USB\_SERIAL\_JTAG\_IN\_EP3\_STATE State of IN Endpoint 3. (RO) USB\_SERIAL\_JTAG\_IN\_EP3\_WR\_ADDR Write data address of IN endpoint 3. (RO) USB\_SERIAL\_JTAG\_IN\_EP3\_RD\_ADDR Read data address of IN endpoint 3. (RO)

![Image](images/30_Chapter_30_img017_8bcf2d1d.png)

## Register 30.13. USB\_SERIAL\_JTAG\_OUT\_EP0\_ST\_REG (0x0038)

![Image](images/30_Chapter_30_img018_63120cfc.png)

USB\_SERIAL\_JTAG\_OUT\_EP0\_STATE State of OUT Endpoint 0. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP0\_WR\_ADDR Write data address of OUT Endpoint 0. When USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT is detected, there are USB\_SERIAL\_JTAG\_OUT\_EP0\_WR\_ADDR - 2 bytes of data in OUT EP0. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP0\_RD\_ADDR Read data address of OUT endpoint 0. (RO)

## Register 30.14. USB\_SERIAL\_JTAG\_OUT\_EP1\_ST\_REG (0x003C)

![Image](images/30_Chapter_30_img019_f1ce6c03.png)

USB\_SERIAL\_JTAG\_OUT\_EP1\_STATE State of OUT Endpoint 1. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP1\_WR\_ADDR Write data address of OUT Endpoint 1. When USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT is detected, there are USB\_SERIAL\_JTAG\_OUT\_EP1\_WR\_ADDR - 2 bytes of data in OUT EP1. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP1\_RD\_ADDR Read data address of OUT endpoint 1. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP1\_REC\_DATA\_CNT Data count in OUT Endpoint 1 when one packet is received. (RO)

## Register 30.15. USB\_SERIAL\_JTAG\_OUT\_EP2\_ST\_REG (0x0040)

![Image](images/30_Chapter_30_img020_f682b0cf.png)

USB\_SERIAL\_JTAG\_OUT\_EP2\_STATE State of OUT Endpoint 2. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP2\_WR\_ADDR Write data address of OUT endpoint 2. When USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT is detected, there are USB\_SERIAL\_JTAG\_OUT\_EP2\_WR\_ADDR - 2 bytes of data in OUT EP2. (RO)

USB\_SERIAL\_JTAG\_OUT\_EP2\_RD\_ADDR Read data address of OUT endpoint 2. (RO)

![Image](images/30_Chapter_30_img021_ad66274e.png)

## Register 30.16. USB\_SERIAL\_JTAG\_INT\_RAW\_REG (0x0008)

![Image](images/30_Chapter_30_img022_3604f03b.png)

- USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT\_RAW The raw interrupt bit turns to high level when a flush command is received for IN endpoint 2 of JTAG. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_SOF\_INT\_RAW The raw interrupt bit turns to high level when a SOF frame is received. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT\_RAW The raw interrupt bit turns to high level when the Serial Port OUT Endpoint received one packet. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT\_RAW The raw interrupt bit turns to high level when the Serial Port IN Endpoint is empty. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_PID\_ERR\_INT\_RAW The raw interrupt bit turns to high level when a PID error is detected. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT\_RAW The raw interrupt bit turns to high level when a CRC5 error is detected. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT\_RAW The raw interrupt bit turns to high level when a CRC16 error is detected. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT\_RAW The raw interrupt bit turns to high level when a bit stuffing error is detected. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT\_RAW The raw interrupt bit turns to high level when an IN token for IN endpoint 1 is received. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT\_RAW The raw interrupt bit turns to high level when a USB bus reset is detected. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT\_RAW The raw interrupt bit turns to high level when OUT endpoint 1 received packet with zero payload. (R/WTC/SS)
- USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT\_RAW The raw interrupt bit turns to high level when OUT endpoint 2 received packet with zero payload. (R/WTC/SS)

## Register 30.17. USB\_SERIAL\_JTAG\_INT\_ST\_REG (0x000C)

![Image](images/30_Chapter_30_img023_bad8608a.png)

USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_SOF\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_SOF\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_PID\_ERR\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_PID\_ERR\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT\_ST The raw interrupt status bit for the USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT interrupt. (RO) USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT\_ST The raw interrupt status bit for the

- USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT interrupt. (RO)

## Register 30.18. USB\_SERIAL\_JTAG\_INT\_ENA\_REG (0x0010)

![Image](images/30_Chapter_30_img024_bdf1c51d.png)

USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_SOF\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_SOF\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_PID\_ERR\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_PID\_ERR\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT interrupt. (R/W) USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT\_ENA The interrupt enable bit for the USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT interrupt. (R/W)

## Register 30.19. USB\_SERIAL\_JTAG\_INT\_CLR\_REG (0x0014)

![Image](images/30_Chapter_30_img025_b1f28c9e.png)

USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_JTAG\_IN\_FLUSH\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_SOF\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_JTAG\_SOF\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_SERIAL\_OUT\_RECV\_PKT\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_SERIAL\_IN\_EMPTY\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_PID\_ERR\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_PID\_ERR\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_CRC5\_ERR\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_CRC16\_ERR\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_STUFF\_ERR\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_IN\_TOKEN\_REC\_IN\_EP1\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_IN\_TOKEN\_IN\_EP1\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_USB\_BUS\_RESET\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_OUT\_EP1\_ZERO\_PAYLOAD\_INT interrupt. (WT) USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT\_CLR Set this bit to clear the USB\_SERIAL\_JTAG\_OUT\_EP2\_ZERO\_PAYLOAD\_INT interrupt. (WT)

Submit Documentation Feedback

Register 30.20. USB\_SERIAL\_JTAG\_DATE\_REG (0x0080)

![Image](images/30_Chapter_30_img026_2ff71690.png)

![Image](images/30_Chapter_30_img027_dd8ec75d.png)

USB\_SERIAL\_JTAG\_DATE Version control register. (R/W)
