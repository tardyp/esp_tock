---
chapter: 26
title: "Chapter 26"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 26

## UART Controller (UART)

## 26.1 Overview

In embedded system applications, data is required to be transferred in a simple way with minimal system resources. This can be achieved by a Universal Asynchronous Receiver/Transmitter (UART), which flexibly exchanges data with other peripheral devices in full-duplex mode. ESP32-C3 has two UART controllers compatible with various UART devices. They support Infrared Data Association (IrDA) and RS485 transmission.

Each of the two UART controllers has a group of registers that function identically. In this chapter, the two UART controllers are referred to as UARTn, in which n denotes 0 or 1.

A UART is a character-oriented data link for asynchronous communication between devices. Such communication does not add clock signals to the data sent. Therefore, in order to communicate successfully, the transmitter and the receiver must operate at the same baud rate with the same stop bit(s) and parity bit.

A UART data frame usually begins with one start bit, followed by data bits, one parity bit (optional) and one or more stop bits. UART controllers on ESP32-C3 support various lengths of data bits and stop bits. These controllers also support software and hardware flow control as well as GDMA for seamless high-speed data transfer. This allows developers to use multiple UART ports at minimal software cost.

## 26.2 Features

Each UART controller has the following features:

- Three clock sources that can be divided
- Programmable baud rate
- 512 x 8-bit RAM shared by TX FIFOs and RX FIFOs of the two UART controllers
- Full-duplex asynchronous communication
- Automatic baud rate detection of input signals
- Data bits ranging from 5 to 8
- Stop bits whose length can be 1, 1.5 or 2 bits
- Parity bit
- Special character AT\_CMD detection
- RS485 protocol

- IrDA protocol
- High-speed data communication using GDMA
- UART as wake-up source
- Software and hardware flow control

## 26.3 UART Structure

![Image](images/26_Chapter_26_img001_d47c744a.png)

Figure 26.3-1. UART Architecture Overview

![Image](images/26_Chapter_26_img002_8d403097.png)

Figure 26.3-2. UART Structure

![Image](images/26_Chapter_26_img003_af47d695.png)

Figure 26.3-2 shows the basic structure of a UART controller. A UART controller works in two clock domains, namely APB\_CLK domain and Core Clock domain (the UART Core's clock domain). The UART Core has three clock sources: a 80 MHz APB\_CLK, RC\_FAST\_CLK and external crystal clock XTAL\_CLK (for details, please refer to Chapter 6 Reset and Clock), which are selected by configuring UART\_SCLK\_SEL. The selected clock source is divided by a divider to generate clock signals that drive the UART Core. The divisor is configured by UART\_CLKDIV\_REG: UART\_CLKDIV for the integral part, and UART\_CLKDIV\_FRAG for the fractional part.

A UART controller is broken down into two parts according to functions: a transmitter and a receiver.

The transmitter contains a TX FIFO, which buffers data to be sent. Software can write data to Tx\_FIFO via the APB bus, or move data to Tx\_FIFO using GDMA. Tx\_FIFO\_Ctrl controls writing and reading Tx\_FIFO. When Tx\_FIFO is not empty, Tx\_FSM reads data bits in the data frame via Tx\_FIFO\_Ctrl, and converts them into a bitstream. The levels of output signal txd\_out can be inverted by configuring the UART\_TXD\_INV field.

The receiver contains a RX FIFO, which buffers data to be processed. The levels of input signal rxd\_in can be inverted by configuring UART\_RXD\_INV field. Baudrate\_Detect measures the baud rate of input signal rxd\_in by detecting its minimum pulse width. Start\_Detect detects the start bit in a data frame. If the start bit is detected, Rx\_FSM stores data bits in the data frame into Rx\_FIFO by Rx\_FIFO\_Ctrl. Software can read data from Rx\_FIFO via the APB bus, or receive data using GDMA.

HW\_Flow\_Ctrl controls rxd\_in and txd\_out data flows by standard UART RTS and CTS flow control signals (rtsn\_out and ctsn\_in). SW\_Flow\_Ctrl controls data flows by automatically adding special characters to outgoing data and detecting special characters in incoming data. When a UART controller is Light-sleep mode (see Chapter 9 Low-power Management for more details), Wakeup\_Ctrl counts up rising edges of rxd\_in. When the number is equal to or greater than (UART\_ACTIVE\_THRESHOLD + 3), a wake\_up signal is generated and sent to RTC, which then wakes up the ESP32-C3 chip.

## 26.4 Functional Description

## 26.4.1 Clock and Reset

UART controllers are asynchronous. Their register configuration module, TX FIFO and RX FIFO are in APB\_CLK domain, while the UART Core that controls transmission and reception is in Core Clock domain. The three clock sources of the UART core, namely APB\_CLK, RC\_FAST\_CLK and external crystal clock XTAL\_CLK, are selected by configuring UART\_SCLK\_SEL. The selected clock source is divided by a divider. This divider supports fractional frequency division: UART\_SCLK\_DIV\_NUM field is the integral part, UART\_SCLK\_DIV\_B field is the numerator of the fractional part, and UART\_SCLK\_DIV\_A is the denominator of the fractional part. The divisor ranges from 1 ~ 256.

When the frequency of the UART Core's clock is higher than the frequency needed to generate the baud rate, the UART Core can be clocked at a lower frequency by the divider, in order to reduce power consumption. Usually, the UART Core's clock frequency is lower than the APB\_CLK's frequency, and can be divided by the largest divisor value when higher than the frequency needed to generate the baud rate. The frequency of the UART Core's clock can also be at most twice higher than the APB\_CLK. The clock for the UART transmitter and the UART receiver can be controlled independently. To enable the clock for the UART transmitter, UART\_TX\_SCLK\_EN shall be set; to enable the clock for the UART receiver, UART\_RX\_SCLK\_EN shall be set.

To ensure that the configured register values are synchronized from APB\_CLK domain to Core Clock domain,

please follow procedures in Section26.5 .

To reset the whole UART, please:

- enable the clock for UART RAM by setting SYSTEM\_UART\_MEM\_CLK\_EN to 1;
- enable APB\_CLK for UARTn by setting SYSTEM\_UARTn\_CLK\_EN to 1
- clear SYSTEM\_UARTn\_RST to 0;
- write 1 to UART\_RST\_CORE;
- write 1 to SYSTEM\_UARTn\_RST;
- clear SYSTEM\_UARTn\_RST to 0;
- clear UART\_RST\_CORE to 0.

Note that it is not recommended to reset the APB clock domain module or UART Core only.

## 26.4.2 UART RAM

Figure 26.4-1. UART Controllers Sharing RAM

![Image](images/26_Chapter_26_img004_6fd81fe1.png)

The two UART controllers on ESP32-C3 share 512 × 8 bits of FIFO RAM. As Figure 26.4-1 illustrates, RAM is divided into 4 blocks, each has 128 × 8 bits. Figure 26.4-1 shows how many RAM blocks are allocated to TX FIFOs and RX FIFOs of the two UART controllers by default. UARTn Tx\_FIFO can be expanded by configuring UART\_TX\_SIZE, while UARTn Rx\_FIFO can be expanded by configuring UART\_RX\_SIZE. Some limits are imposed:

- UART0 Tx\_FIFO can be increased up to 4 blocks (the whole RAM);
- UART1 Tx\_FIFO can be increased up to 3 blocks (from offset 128 to the end address);
- UART0 Rx\_FIFO can be increased up to 2 blocks (from offset 256 to the end address);
- UART1 Rx\_FIFO cannot be increased.

Please note that starting addresses of all FIFOs are fixed, so expanding one FIFO may take up the default space of other FIFOs. For example, by setting UART\_TX\_SIZE of UART0 to 2, the size of UART0 Tx\_FIFO is increased by 128 bytes (from offset 0 to offset 255). In this case, UART0 Tx\_FIFO takes up the default space for UART1 Tx\_FIFO, and UART1's transmitting function cannot be used as a result.

When neither of the two UART controllers is active, RAM could enter low-power mode by setting UART\_MEM\_FORCE\_PD .

![Image](images/26_Chapter_26_img005_ae8e933b.png)

UART0 Tx\_FIFO and UART1 Tx\_FIFO are reset by setting UART\_TXFIFO\_RST. UART0 Rx\_FIFO and UART1 Rx\_FIFO are reset by setting UART\_RXFIFO\_RST .

Data to be sent is written to TX FIFO via the APB bus or using GDMA, read automatically and converted from a frame into a bitstream by hardware Tx\_FSM; data received is converted from a bitstream into a frame by hardware Rx\_FSM, written into RX FIFO, and then stored into RAM via the APB bus or using GDMA. The two UART controllers share one GDMA channel.

The empty signal threshold for Tx\_FIFO is configured by setting UART\_TXFIFO\_EMPTY\_THRHD. When data stored in Tx\_FIFO is less than UART\_TXFIFO\_EMPTY\_THRHD, a UART\_TXFIFO\_EMPTY\_INT interrupt is generated. The full signal threshold for Rx\_FIFO is configured by setting UART\_RXFIFO\_FULL\_THRHD. When data stored in Rx\_FIFO is greater than UART\_RXFIFO\_FULL\_THRHD, a UART\_RXFIFO\_FULL\_INT interrupt is generated. In addition, when Rx\_FIFO receives more data than its capacity, a UART\_RXFIFO\_OVF\_INT interrupt is generated.

UARTn can access FIFO via register UART\_FIFO\_REG. Writing to UART\_RXFIFO\_RD\_BYTE stores the data into the TX FIFO. As UART\_RXFIFO\_RD\_BYTE is a read-only register field, the hardware does not actually perform a write operation on UART\_RXFIFO\_RD\_BYTE; instead, upon detecting a write request to this field's address, it passes the corresponding write data to the TX FIFO via a separate bypass. Reading UART\_RXFIFO\_RD\_BYTE retrieves the data from the RX FIFO.

## 26.4.3 Baud Rate Generation and Detection

## 26.4.3.1 Baud Rate Generation

Before a UART controller sends or receives data, the baud rate should be configured by setting corresponding registers. The baud rate generator of a UART controller functions by dividing the input clock source. It can divide the clock source by a fractional amount. The divisor is configured by UART\_CLKDIV\_REG: UART\_CLKDIV for the integral part, and UART\_CLKDIV\_FRAG for the fractional part. When using the 80 MHz input clock, the UART controller supports a maximum baud rate of 5 Mbaud.

The divisor of the baud rate divider is equal to

<!-- formula-not-decoded -->

meaning that the final baud rate is equal to

<!-- formula-not-decoded -->

where INPUT\_FREQ is the frequency of UART Core's source clock. For example, if UART\_CLKDIV = 694 and UART\_CLKDIV\_FRAG = 7 then the divisor value is

<!-- formula-not-decoded -->

When UART\_CLKDIV\_FRAG is 0, the baud rate generator is an integer clock divider where an output pulse is generated every UART\_CLKDIV input pulses.

When UART\_CLKDIV\_FRAG is not 0, the divider is fractional and the output baud rate clock pulses are not strictly uniform. As shown in Figure 26.4-2, for every 16 output pulses, the generator divides either (UART\_CLKDIV + 1) input pulses or UART\_CLKDIV input pulses per output pulse. A total of UART\_CLKDIV\_FRAG output pulses are generated by dividing (UART\_CLKDIV + 1) input pulses, and the remaining (16 -UART\_CLKDIV\_FRAG) output pulses are generated by dividing UART\_CLKDIV input pulses.

The output pulses are interleaved as shown in Figure 26.4-2 below, to make the output timing more uniform:

Figure 26.4-2. UART Controllers Division

![Image](images/26_Chapter_26_img006_74d68133.png)

To support IrDA (see Section 26.4.7 for details), the fractional clock divider for IrDA data transmission generates clock signals divided by 16 × UART\_CLKDIV\_REG. This divider works similarly as the one elaborated above: it takes UART\_CLKDIV/16 as the integer value and the lowest four bits of UART\_CLKDIV as the fractional value.

## 26.4.3.2 Baud Rate Detection

Automatic baud rate detection (Autobaud) on UARTs is enabled by setting UART\_AUTOBAUD\_EN. The Baudrate\_Detect module shown in Figure 26.3-2 filters any noise whose pulse width is shorter than UART\_GLITCH\_FILT .

Before communication starts, the transmitter could send random data to the receiver for baud rate detection. UART\_LOWPULSE\_MIN\_CNT stores the minimum low pulse width, UART\_HIGHPULSE\_MIN\_CNT stores the minimum high pulse width, UART\_POSEDGE\_MIN\_CNT stores the minimum pulse width between two rising edges, and UART\_NEGEDGE\_MIN\_CNT stores the minimum pulse width between two falling edges. These four fields are read by software to determine the transmitter's baud rate.

Figure 26.4-3. The Timing Diagram of Weak UART Signals Along Falling Edges

![Image](images/26_Chapter_26_img007_4bb9afd1.png)

The baud rate can be determined in the following three ways:

1. Normally, to avoid sampling erroneous data along rising or falling edges in a metastable state, which results in the inaccuracy of UART\_LOWPULSE\_MIN\_CNT or UART\_HIGHPULSE\_MIN\_CNT, use a weighted average of these two values to eliminate errors. In this case, the baud rate is calculated as follows:

<!-- formula-not-decoded -->

2. If UART signals are weak along falling edges as shown in Figure 26.4-3, which leads to an inaccurate average of UART\_LOWPULSE\_MIN\_CNT and UART\_HIGHPULSE\_MIN\_CNT, use UART\_POSEDGE\_MIN\_CNT to determine the transmitter's baud rate as follows:

<!-- formula-not-decoded -->

3. If UART signals are weak along rising edges, use UART\_NEGEDGE\_MIN\_CNT to determine the transmitter's baud rate as follows:

<!-- formula-not-decoded -->

## 26.4.4 UART Data Frame

Figure 26.4-4. Structure of UART Data Frame

![Image](images/26_Chapter_26_img008_7b9d0c88.png)

Figure 26.4-4 shows the basic structure of a data frame. A frame starts with one START bit, and ends with STOP bits which can be 1, 1.5, or 2 bits long, configured by UART\_STOP\_BIT\_NUM (in RS485 mode turnaround delay may be added. See details in Section 26.4.6.2). The START bit is logical low, whereas STOP bits are logical high.

The actual data length can be anywhere between 5 ~ 8 bit, configured by UART\_BIT\_NUM. When UART\_PARITY\_EN is set, a parity bit is added after data bits. UART\_PARITY is used to choose even parity or odd parity. When the receiver detects a parity bit error in the data received, a UART\_PARITY\_ERR\_INT interrupt is generated, and the data received is still stored into RX FIFO. When the receiver detects a data frame error, a UART\_FRM\_ERR\_INT interrupt is generated, and the data received by default is stored into RX FIFO.

If all data in Tx\_FIFO has been sent, a UART\_TX\_DONE\_INT interrupt is generated. After this, if the UART\_TXD\_BRK bit is set then the transmitter will enter the Break condition and send several NULL characters in which the TX data line is logical low. The number of NULL characters is configured by UART\_TX\_BRK\_NUM . Once the transmitter has sent all NULL characters, a UART\_TX\_BRK\_DONE\_INT interrupt is generated. The minimum interval between data frames can be configured using UART\_TX\_IDLE\_NUM. If the transmitter stays idle for UART\_TX\_IDLE\_NUM or more time, a UART\_TX\_BRK\_IDLE\_DONE\_INT interrupt is generated.

The receiver can also detect the Break conditions when the RX data line remains logical low for one NULL character transmission, and a UART\_BRK\_DET\_INT interrupt will be triggered to detect that a Break condition has been completed.

The receiver can detect the current bus state through the timeout interrupt UART\_RXFIFO\_TOUT\_INT. The UART\_RXFIFO\_TOUT\_INT interrupt will be triggered when the bus is in the idle state for more than UART\_RX\_TOUT\_THRHD bit time on current baud rate after the receiver has received at least one byte. You can use this interrupt to detect whether all the data from the transmitter has been sent.

## 26.4.5 AT\_CMD Character Structure

Figure 26.4-5. AT\_CMD Character Structure

![Image](images/26_Chapter_26_img009_9c3adf55.png)

Figure 26.4-5 is the structure of a special character AT\_CMD. If the receiver constantly receives AT\_CMD\_CHAR and the following conditions are met, a UART\_AT\_CMD\_CHAR\_DET\_INT interrupt is generated.

- The interval between the first AT\_CMD\_CHAR and the last non-AT\_CMD\_CHAR character is at least UART \_PRE\_IDLE\_NUM cycles.
- The interval between two AT\_CMD\_CHAR characters is less than UART\_RX\_GAP\_TOUT cycles.
- The number of AT\_CMD\_CHAR characters is equal to or greater than UART\_CHAR\_NUM .
- The interval between the last AT\_CMD\_CHAR character and next non-AT\_CMD\_CHAR character is at least UART\_POST\_IDLE\_NUM cycles.

## 26.4.6 RS485

The two UART controllers support RS485 protocol. This protocol uses differential signals to transmit data, so it can communicate over longer distances at higher bit rates than RS232. RS485 has two-wire half-duplex mode and four-wire full-duplex mode. UART controllers support two-wire half-duplex transmission and bus snooping. In a two-wire RS485 multidrop network, there can be 32 slaves at most.

## 26.4.6.1 Driver Control

As shown in Figure 26.4-6, in a two-wire multidrop network, an external RS485 transceiver is needed for differential to single-ended conversion. An RS485 transceiver contains a driver and a receiver. When a UART controller is not in transmitter mode, the connection to the differential line can be broken by disabling the driver. When DE is 1, the driver is enabled; when DE is 0, the driver is disabled.

The UART receiver converts differential signals to single-ended signals via an external receiver. RE is the enable control signal for the receiver. When RE is 0, the receiver is enabled; when RE is 1, the receiver is disabled. If RE is configured as 0, the UART controller is allowed to snoop data on the bus, including the data sent by itself.

DE can be controlled by either software or hardware. To reduce the cost of software, in our design DE is controlled by hardware. As shown in Figure 26.4-6, DE is connected to dtrn\_out of UART (please refer to Section 26.4.9.1 for more details).

![Image](images/26_Chapter_26_img010_8c90d205.png)

Figure 26.4-6. Driver Control Diagram in RS485 Mode

![Image](images/26_Chapter_26_img011_bf933176.png)

## 26.4.6.2 Turnaround Delay

By default, the two UART controllers work in receiver mode. When a UART controller is switched from transmitter mode to receiver mode, the RS485 protocol requires a turnaround delay of one cycle after the stop bit. The UART transmitter supports adding a turnaround delay of one cycle before the start bit or after the stop bit. When UART\_DL0\_EN is set, a turnaround delay of one cycle is added before the start bit; when UART\_DL1\_EN is set, a turnaround delay of one cycle is added after the stop bit.

## 26.4.6.3 Bus Snooping

In a two-wire multidrop network, UART controllers support bus snooping if RE of the external RS485 transceiver is 0. By default, a UART controller is not allowed to transmit and receive data simultaneously. If UART\_RS485TX\_RX\_EN is set and the external RS485 transceiver is configured as in Figure 26.4-6, a UART controller may receive data in transmitter mode and snoop the bus. If UART\_RS485RXBY\_TX\_EN is set, a UART controller may transmit data in receiver mode.

The two UART controllers can snoop the data sent by themselves. In transmitter mode, when a UART controller monitors a collision between the data sent and the data received, a UART\_RS485\_CLASH\_INT is generated; when a UART controller monitors a data frame error, a UART\_RS485\_FRM\_ERR\_INT interrupt is generated; when a UART controller monitors a polarity error, a UART\_RS485\_PARITY\_ERR\_INT is generated.

## 26.4.7 IrDA

IrDA protocol consists of three layers, namely the physical layer, the link access protocol, and the link management protocol. The two UART controllers implement IrDA's physical layer. In IrDA encoding, a UART controller supports data rates up to 115.2 kbit/s (SIR, or serial infrared mode). As shown in Figure 26.4-7, the IrDA encoder converts a NRZ (non-return to zero code) signal to a RZI (return to zero inverted code) signal and sends it to the external driver and infrared LED. This encoder uses modulated signals whose pulse width is 3/16 bits to indicate logic "0", and low levels to indicate logic "1". The IrDA decoder receives signals from the infrared receiver and converts them to NRZ signals. In most cases, the receiver is high when it is idle, and the encoder output polarity is the opposite of the decoder input polarity. If a low pulse is detected, it indicates that a start bit has been received.

When IrDA function is enabled, one bit is divided into 16 clock cycles. If the bit to be sent is zero, then the 9th, 10th and 11th clock cycle are high.

Figure 26.4-7. The Timing Diagram of Encoding and Decoding in SIR mode

![Image](images/26_Chapter_26_img012_fa1a85cc.png)

The IrDA transceiver is half-duplex, meaning that it cannot send and receive data simultaneously. As shown in Figure 26.4-8, IrDA function is enabled by setting UART\_IRDA\_EN. When UART\_IRDA\_TX\_EN is set (high), the IrDA transceiver is enabled to send data and not allowed to receive data; when UART\_IRDA\_TX\_EN is reset (low), the IrDA transceiver is enabled to receive data and not allowed to send data.

Figure 26.4-8. IrDA Encoding and Decoding Diagram

![Image](images/26_Chapter_26_img013_cbc94c9b.png)

## 26.4.8 Wake-up

UART0 and UART1 can be set as wake-up source. When a UART controller is in Light-sleep mode, Wakeup\_Ctrl counts up the rising edges of rxd\_in. When the number of rising edges is is equal to or greater than (UART\_ACTIVE\_THRESHOLD + 3), a wake\_up signal is generated and sent to RTC, which then wakes up ESP32-C3.

After the chip is woken up by UART, it is necessary to clear the wake\_up signal by transmitting data to UART in Active mode or resetting the whole UART, otherwise the number of rising edges required for the next wakeup will be reduced.

![Image](images/26_Chapter_26_img014_0c6f82db.png)

## 26.4.9 Flow Control

UART controllers have two ways to control data flow, namely hardware flow control and software flow control. Hardware flow control is achieved using output signal rtsn\_out and input signal dsrn\_in. Software flow control is achieved by inserting special characters in the data flow sent and detecting special characters in the data flow received.

## 26.4.9.1 Hardware Flow Control

Figure 26.4-9. Hardware Flow Control Diagram

![Image](images/26_Chapter_26_img015_2fbe7b83.png)

Figure 26.4-9 shows the hardware flow control of a UART controller. Hardware flow control uses output signal rtsn\_out and input signal dsrn\_in. Figure 26.4-10 illustrates how these signals are connected between UART on ESP32-C3 (hereinafter referred to as IU0) and the external UART (hereinafter referred to as EU0).

When rtsn\_out of IU0 is low, EU0 is allowed to send data; when rtsn\_out of IU0 is high, EU0 is notified to stop sending data until rtsn\_out of IU0 returns to low. The output signal rtsn\_out can be controlled in two ways.

- Software control: Enter this mode by clearing UART\_RX\_FLOW\_EN to 0. In this mode, the level of rtsn\_out is changed by configuring UART\_SW\_RTS .
- Hardware control: Enter this mode by setting UART\_RX\_FLOW\_EN to 1. In this mode, rtsn\_out is pulled high when data in Rx\_FIFO exceeds UART\_RX\_FLOW\_THRHD .

![Image](images/26_Chapter_26_img016_241b881d.png)

Figure 26.4-10. Connection between Hardware Flow Control Signals

![Image](images/26_Chapter_26_img017_30a5bbcc.png)

When ctsn\_in of IU0 is low, IU0 is allowed to send data; when ctsn\_in is high, IU0 is not allowed to send data. When IU0 detects an edge change of ctsn\_in, a UART\_CTS\_CHG\_INT interrupt is generated.

If dtrn\_out of IU0 is high, it indicates that IU0 is ready to transmit data. dtrn\_out is generated by configuring the UART\_SW\_DTR field. When the IU0 transmitter detects a edge change of dsrn\_in, a UART\_DSR\_CHG\_INT interrupt is generated. After this interrupt is detected, software can obtain the level of input signal dsrn\_in by reading UART\_DSRN. If dsrn\_in is high, it indicates that EU0 is ready to transmit data.

In a two-wire RS485 multidrop network enabled by setting UART\_RS485\_EN, dtrn\_out is generated by hardware and used for transmit/receive turnaround. When data transmission starts, dtrn\_out is pulled high and the external driver is enabled; when data transmission completes, dtrn\_out is pulled low and the external driver is disabled. Please note that when there is a turnaround delay of one cycle added after the stop bit, dtrn\_out is pulled low after the delay.

UART loopback test is enabled by setting UART\_LOOPBACK. In the test, UART output signal txd\_out is connected to its input signal rxd\_in, rtsn\_out is connected to ctsn\_in, and dtrn\_out is connected to dsrn\_out. If the data sent matches the data received, it indicates that UART controllers are working properly.

## 26.4.9.2 Software Flow Control

Instead of CTS/RTS lines, software flow control uses XON/XOFF characters to start or stop data transmission. Such flow control is enabled by setting UART\_SW\_FLOW\_CON\_EN to 1.

When using software flow control, hardware automatically detects if there are XON/XOFF characters in the data flow received, and generate a UART\_SW\_XOFF\_INT or a UART\_SW\_XON\_INT interrupt accordingly. If an XOFF character is detected, the transmitter stops data transmission once the current byte has been transmitted; if an XON character is detected, the transmitter starts data transmission. In addition, software can force the transmitter to stop sending data by setting UART\_FORCE\_XOFF, or to start sending data by setting UART\_FORCE\_XON .

Software determines whether to insert flow control characters according to the remaining room in RX FIFO. When UART\_SEND\_XOFF is set, the transmitter sends an XOFF character configured by UART\_XOFF\_CHAR after the current byte in transmission; when UART\_SEND\_XON is set, the transmitter sends an XON character configured by UART\_XON\_CHAR after the current byte in transmission. If the RX FIFO of a UART controller stores more data than UART\_XOFF\_THRESHOLD , UART\_SEND\_XOFF is set by hardware. As a result, the transmitter sends an XOFF character configured by UART\_XOFF\_CHAR after the current byte in transmission. If the RX FIFO of a UART controller stores less data than UART\_XON\_THRESHOLD , UART\_SEND\_XON is set by

hardware. As a result, the transmitter sends an XON character configured by UART\_XON\_CHAR after the current byte in transmission.

## 26.4.10 GDMA Mode

The two UART controllers on ESP32-C3 share one TX/RX GDMA (general direct memory access) channel via UHCI. In GDMA mode, UART controllers support the decoding and encoding of HCI data packets. The UHCI\_UARTn\_CE field determines which UART controller occupies the GDMA TX/RX channel.

Figure 26.4-11. Data Transfer in GDMA Mode

![Image](images/26_Chapter_26_img018_c4d7d73d.png)

Figure 26.4-11 shows how data is transferred using GDMA. Before GDMA receives data, software prepares an inlink. GDMA\_INLINK\_ADDR\_CHn points to the first receive descriptor in the inlink. After GDMA\_INLINK\_START\_CHn is set, UHCI sends data that UART has received to the decoder. The decoded data is then stored into the RAM pointed by the inlink under the control of GDMA.

Before GDMA sends data, software prepares an outlink and data to be sent. GDMA\_OUTLINK\_ADDR\_CHn points to the first transmit descriptor in the outlink. After GDMA\_OUTLINK\_START\_CHn is set, GDMA reads data from the RAM pointed by outlink. The data is then encoded by the encoder, and sent sequentially by the UART transmitter.

HCI data packets have separators at the beginning and the end, with data bits in the middle (separators + data bits + separators). The encoder inserts separators in front of and after data bits, and replaces data bits identical to separators with special characters. The decoder removes separators in front of and after data bits, and replaces special characters with separators. There can be more than one continuous separator at the beginning and the end of a data packet. The separator is configured by UHCI\_SEPER\_CHAR, 0xC0 by default. The special character is configured by UHCI\_ESC\_SEQ0\_CHAR0 (0xDB by default) and UHCI\_ESC\_SEQ0\_CHAR1 (0xDD by default). When all data has been sent, a GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT interrupt is generated. When all data has been received, a GDMA\_IN\_SUC\_EOF\_CHn\_INT is generated.

## 26.4.11 UART Interrupts

- UART\_AT\_CMD\_CHAR\_DET\_INT: Triggered when the receiver detects an AT\_CMD character.
- UART\_RS485\_CLASH\_INT: Triggered when a collision is detected between the transmitter and the receiver in RS485 mode.
- UART\_RS485\_FRM\_ERR\_INT: Triggered when an error is detected in the data frame sent by the transmitter in RS485 mode.

- UART\_RS485\_PARITY\_ERR\_INT: Triggered when an error is detected in the parity bit sent by the transmitter in RS485 mode.
- UART\_TX\_DONE\_INT: Triggered when all data in the transmitter's TX FIFO has been sent.
- UART\_TX\_BRK\_IDLE\_DONE\_INT: Triggered when the transmitter stays idle for the minimum interval (threshold) after sending the last data bit.
- UART\_TX\_BRK\_DONE\_INT: Triggered when the transmitter has sent all NULL characters after all data in TX FIFO had been sent.
- UART\_GLITCH\_DET\_INT: Triggered when the receiver detects a glitch in the middle of the start bit.
- UART\_SW\_XOFF\_INT: Triggered when UART\_SW\_FLOW\_CON\_EN is set and the receiver receives a XOFF character.
- UART\_SW\_XON\_INT: Triggered when UART\_SW\_FLOW\_CON\_EN is set and the receiver receives a XON character.
- UART\_RXFIFO\_TOUT\_INT: Triggered when the receiver takes more time than UART\_RX\_TOUT\_THRHD to receive one byte.
- UART\_BRK\_DET\_INT: Triggered when the receiver detects a NULL character (i.e. logic 0 for one NULL character transmission) after stop bits.
- UART\_CTS\_CHG\_INT: Triggered when the receiver detects an edge change of CTSn signals.
- UART\_DSR\_CHG\_INT: Triggered when the receiver detects an edge change of DSRn signals.
- UART\_RXFIFO\_OVF\_INT: Triggered when the receiver receives more data than the capacity of RX FIFO.
- UART\_FRM\_ERR\_INT: Triggered when the receiver detects a data frame error.
- UART\_PARITY\_ERR\_INT: Triggered when the receiver detects a parity error.
- UART\_TXFIFO\_EMPTY\_INT: Triggered when TX FIFO stores less data than what UART\_TXFIFO\_EMPTY\_THRHD specifies.
- UART\_RXFIFO\_FULL\_INT: Triggered when the receiver receives more data than what UART\_RXFIFO\_FULL\_THRHD specifies.
- UART\_WAKEUP\_INT: Triggered when UART is woken up.

## 26.4.12 UHCI Interrupts

- UHCI\_APP\_CTRL1\_INT: Triggered when software sets UHCI\_APP\_CTRL1\_INT\_RAW .
- UHCI\_APP\_CTRL0\_INT: Triggered when software sets UHCI\_APP\_CTRL0\_INT\_RAW .
- UHCI\_OUTLINK\_EOF\_ERR\_INT: Triggered when an EOF error is detected in a transmit descriptor.
- UHCI\_SEND\_A\_REG\_Q\_INT: Triggered when UHCI has sent a series of short packets using always\_send.
- UHCI\_SEND\_S\_REG\_Q\_INT: Triggered when UHCI has sent a series of short packets using single\_send.
- UHCI\_TX\_HUNG\_INT: Triggered when UHCI takes too long to read RAM using a GDMA transmit channel.
- UHCI\_RX\_HUNG\_INT: Triggered when UHCI takes too long to receive data using a GDMA receive channel.
- UHCI\_TX\_START\_INT: Triggered when GDMA detects a separator character.

![Image](images/26_Chapter_26_img019_6bec335a.png)

- UHCI\_RX\_START\_INT: Triggered when a separator character has been sent.

## 26.5 Programming Procedures

## 26.5.1 Register Type

All UART registers are in APB\_CLK domain. According to whether clock domain crossing and synchronization are required, UART registers that can be configured by software are classified into three types, namely immediate registers, synchronous registers, and static registers. Immediate registers are read in APB\_CLK domain, and take effect after configured via the APB bus. Synchronous registers are read in Core Clock domain, and take effect after synchronization. Static registers are also read in Core Clock domain, but would not change dynamically. Therefore, for static registers clock domain crossing is not required, and software can turn on and off the clock for the UART transmitter or receiver to ensure that the configuration sampled in Core Clock domain is correct.

## 26.5.1.1 Synchronous Registers

Read in Core Clock domain, synchronous registers implement the clock domain crossing design to ensure that their values sampled in Core Clock domain are correct. These registers as listed in Table 26.5-1 are configured as follows:

- Enable register synchronization by clearing UART\_UPDATE\_CTRL to 0;
- Wait for UART\_REG\_UPDATE to become 0, which indicates the completion of last synchronization;
- Configure synchronous registers;
- Synchronize the configured values to Core Clock domain by writting 1 to UART\_REG\_UPDATE .

Table 26.5-1. UARTn Synchronous Registers

| Register        | Field                 |
|-----------------|-----------------------|
| UART_CLKDIV_REG | UART_CLKDIV_FRAG[3:0] |
| UART_CLKDIV_REG | UART_CLKDIV[11:0]     |
| UART_CONF0_REG  | UART_AUTOBAUD_EN      |
|                 | UART_ERR_WR_MASK      |
|                 | UART_TXD_INV          |
|                 | UART_RXD_INV          |
|                 | UART_IRDA_EN          |
|                 | UART_TX_FLOW_EN       |
|                 | UART_LOOPBACK         |
|                 | UART_IRDA_RX_INV      |
|                 | UART_IRDA_TX_EN       |
|                 | UART_IRDA_WCTL        |
|                 | UART_IRDA_TX_EN       |
|                 | UART_IRDA_DPLX        |
|                 | UART_STOP_BIT_NUM     |
|                 | UART_BIT_NUM          |

Cont’d on next page

Table 26.5-1 – cont’d from previous page

| Register            | Field                      |
|---------------------|----------------------------|
|                     | UART_PARITY_EN             |
|                     | UART_PARITY                |
| UART_FLOW_CONF_REG  | UART_SEND_XOFF             |
| UART_FLOW_CONF_REG  | UART_SEND_XON              |
| UART_FLOW_CONF_REG  | UART_FORCE_XOFF            |
| UART_FLOW_CONF_REG  | UART_FORCE_XON             |
| UART_FLOW_CONF_REG  | UART_XONOFF_DEL            |
| UART_FLOW_CONF_REG  | UART_SW_FLOW_CON_EN        |
| UART_TXBRK_CONF_REG | UART_RS485_TX_DLY_NUM[3:0] |
| UART_TXBRK_CONF_REG | UART_RS485_RX_DLY_NUM      |
| UART_TXBRK_CONF_REG | UART_RS485RXBY_TX_EN       |
| UART_TXBRK_CONF_REG | UART_RS485TX_RX_EN         |
| UART_TXBRK_CONF_REG | UART_DL1_EN                |
| UART_TXBRK_CONF_REG | UART_DL0_EN                |
| UART_TXBRK_CONF_REG | UART_RS485_EN              |

## 26.5.1.2 Static Registers

Static registers, though also read in Core Clock domain, would not change dynamically when UART controllers are at work, so they do not implement the clock domain crossing design. These registers must be configured when the UART transmitter or receiver is not at work. In this case, software can turn off the clock for the UART transmitter or receiver, so that static registers are not sampled in their metastable state. When software turns on the clock, the configured values are stable to be correctly sampled. Static registers as listed in Table 26.5-2 are configured as follows:

- Turn off the clock for the UART transmitter by clearing UART\_TX\_SCLK\_EN, or the clock for the UART receiver by clearing UART\_RX\_SCLK\_EN, depending on which one (transmitter or receiver) is not at work;
- Configure static registers;
- Turn on the clock for the UART transmitter by writing 1 to UART\_TX\_SCLK\_EN, or the clock for the UART receiver by writing 1 to UART\_RX\_SCLK\_EN .

Table 26.5-2. UARTn Static Registers

| Register                | Field                      |
|-------------------------|----------------------------|
| UART_RX_FILT_REG        | UART_GLITCH_FILT_EN        |
| UART_RX_FILT_REG        | UART_GLITCH_FILT[7:0]      |
| UART_SLEEP_CONF_REG     | UART_ACTIVE_THRESHOLD[9:0] |
| UART_SWFC_CONF0_REG     | UART_XOFF_CHAR[7:0]        |
| UART_SWFC_CONF1_REG     | UART_XON_CHAR[7:0]         |
| UART_IDLE_CONF_REG      | UART_TX_IDLE_NUM[9:0]      |
| UART_AT_CMD_PRECNT_REG  | UART_PRE_IDLE_NUM[15:0]    |
| UART_AT_CMD_POSTCNT_REG | UART_POST_IDLE_NUM[15:0]   |
| UART_AT_CMD_GAPTOUT_REG | UART_RX_GAP_TOUT[15:0]     |

Cont’d on next page

Table 26.5-2 – cont’d from previous page

| Register             | Field                 |
|----------------------|-----------------------|
| UART_AT_CMD_CHAR_REG | UART_CHAR_NUM[7:0]    |
| UART_AT_CMD_CHAR_REG | UART_AT_CMD_CHAR[7:0] |

## 26.5.1.3 Immediate Registers

Except those listed in Table 26.5-1 and Table 26.5-2, registers that can be configured by software are immediate registers read in APB\_CLK domain, such as interrupt and FIFO configuration registers.

## 26.5.2 Detailed Steps

Figure 26.5-1 illustrates the process to program UART controllers, namely initialize UART, configure registers, enable the UART transmitter or receiver, and finish data transmission.

Figure 26.5-1. UART Programming Procedures

![Image](images/26_Chapter_26_img020_c14ca328.png)

## 26.5.2.1 Initializing UARTn

To initialize UARTn:

- enable the clock for UART RAM by setting SYSTEM\_UART\_MEM\_CLK\_EN to 1;
- enable APB\_CLK for UARTn by setting SYSTEM\_UARTn\_CLK\_EN to 1;
- clear SYSTEM\_UARTn\_RST;
- write 1 to UART\_RST\_CORE;
- write 1 to SYSTEM\_UARTn\_RST;
- clear SYSTEM\_UARTn\_RST;
- clear UART\_RST\_CORE;
- enable register synchronization by clearing UART\_UPDATE\_CTRL .

## 26.5.2.2 Configuring UARTn Communication

To configure UARTn communication:

- wait for UART\_REG\_UPDATE to become 0, which indicates the completion of the last synchronization;
- configure static registers (if any) following Section 26.5.1.2;
- select the clock source via UART\_SCLK\_SEL;
- configure divisor of the divider via UART\_SCLK\_DIV\_NUM , UART\_SCLK\_DIV\_A, and UART\_SCLK\_DIV\_B;
- configure the baud rate for transmission via UART\_CLKDIV and UART\_CLKDIV\_FRAG;
- configure data length via UART\_BIT\_NUM;
- configure odd or even parity check via UART\_PARITY\_EN and UART\_PARITY;
- optional steps depending on application ...
- synchronize the configured values to the Core Clock domain by writing 1 to UART\_REG\_UPDATE .

## 26.5.2.3 Enabling UARTn

To enable UARTn transmitter:

- configure TX FIFO's empty threshold via UART\_TXFIFO\_EMPTY\_THRHD;
- disable UART\_TXFIFO\_EMPTY\_INT interrupt by clearing UART\_TXFIFO\_EMPTY\_INT\_ENA;
- write data to be sent to UART\_RXFIFO\_RD\_BYTE;
- clear UART\_TXFIFO\_EMPTY\_INT interrupt by setting UART\_TXFIFO\_EMPTY\_INT\_CLR;
- enable UART\_TXFIFO\_EMPTY\_INT interrupt by setting UART\_TXFIFO\_EMPTY\_INT\_ENA;
- detect UART\_TXFIFO\_EMPTY\_INT and wait for the completion of data transmission.

To enable UARTn receiver:

- configure RX FIFO's full threshold via UART\_RXFIFO\_FULL\_THRHD;
- enable UART\_RXFIFO\_FULL\_INT interrupt by setting UART\_RXFIFO\_FULL\_INT\_ENA;

- detect UART\_TXFIFO\_FULL\_INT and wait until the RX FIFO is full;
- read data from RX FIFO via UART\_RXFIFO\_RD\_BYTE, and obtain the number of bytes received in RX FIFO via UART\_RXFIFO\_CNT .

![Image](images/26_Chapter_26_img021_32d56f1a.png)

ESP32-C3 TRM (Version 1.3)

## 26.6 Register Summary

The addresses in this section are relative to UART Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                       | Description                                   | Address   | Access   |
|--------------------------------------------|-----------------------------------------------|-----------|----------|
| FIFO Configuration                         |                                               |           |          |
| UART_FIFO_REG                              | FIFO data register                            | 0x0000    | RO       |
| UART_MEM_CONF_REG                          | UART threshold and allocation configuration   | 0x0060    | R/W      |
| UART Interrupt Register                    |                                               |           |          |
| UART_INT_RAW_REG                           | Raw interrupt status                          | 0x0004    | R/WTC/SS |
| UART_INT_ST_REG                            | Masked interrupt status                       | 0x0008    | RO       |
| UART_INT_ENA_REG                           | Interrupt enable bits                         | 0x000C    | R/W      |
| UART_INT_CLR_REG                           | Interrupt clear bits                          | 0x0010    | WT       |
| Configuration Register                     |                                               |           |          |
| UART_CLKDIV_REG                            | Clock divider configuration                   | 0x0014    | R/W      |
| UART_RX_FILT_REG                           | RX filter configuration                       | 0x0018    | R/W      |
| UART_CONF0_REG                             | Configuration register 0                      | 0x0020    | R/W      |
| UART_CONF1_REG                             | Configuration register 1                      | 0x0024    | R/W      |
| UART_FLOW_CONF_REG                         | Software flow control configuration           | 0x0034    | varies   |
| UART_SLEEP_CONF_REG                        | Sleep mode configuration                      | 0x0038    | R/W      |
| UART_SWFC_CONF0_REG                        | Software flow control character configuration | 0x003C    | R/W      |
| UART_SWFC_CONF1_REG                        | Software flow control character configuration | 0x0040    | R/W      |
| UART_TXBRK_CONF_REG                        | TX break character configuration              | 0x0044    | R/W      |
| UART_IDLE_CONF_REG                         | Frame end idle time configuration             | 0x0048    | R/W      |
| UART_RS485_CONF_REG                        | RS485 mode configuration                      | 0x004C    | R/W      |
| UART_CLK_CONF_REG                          | UART core clock configuration                 | 0x0078    | R/W      |
| Status Register                            |                                               |           |          |
| UART_STATUS_REG                            | UART status register                          | 0x001C    | RO       |
| UART_MEM_TX_STATUS_REG                     | TX FIFO write and read offset address         | 0x0064    | RO       |
| UART_MEM_RX_STATUS_REG                     | RX FIFO write and read offset address         | 0x0068    | RO       |
| UART_FSM_STATUS_REG                        | UART transmitter and receiver status          | 0x006C    | RO       |
| Autobaud Register                          |                                               |           |          |
| UART_LOWPULSE_REG                          | Autobaud minimum low pulse duration register  | 0x0028    | RO       |
| UART_HIGHPULSE_REG                         | Autobaud minimum high pulse duration register | 0x002C    | RO       |
| UART_RXD_CNT_REG                           | Autobaud edge change count register           | 0x0030    | RO       |
| UART_POSPULSE_REG                          | Autobaud high pulse register                  | 0x0070    | RO       |
| UART_NEGPULSE_REG                          | Autobaud low pulse register                   | 0x0074    | RO       |
| AT Escape Sequence Selection Configuration |                                               |           |          |
| UART_AT_CMD_PRECNT_REG                     | Pre-sequence timing configuration             | 0x0050    | R/W      |
| UART_AT_CMD_POSTCNT_REG                    | Post-sequence timing configuration            | 0x0054    | R/W      |

| Name                    | Description                                | Address   | Access   |
|-------------------------|--------------------------------------------|-----------|----------|
| UART_AT_CMD_GAPTOUT_REG | Timeout configuration                      | 0x0058    | R/W      |
| UART_AT_CMD_CHAR_REG    | AT escape sequence detection configuration | 0x005C    | R/W      |
| Version Register        |                                            |           |          |
| UART_DATE_REG           | UART version control register              | 0x007C    | R/W      |
| UART_ID_REG             | UART ID register                           | 0x0080    | varies   |

| Name                    | Description                              | Address   | Access   |
|-------------------------|------------------------------------------|-----------|----------|
| Configuration Register  |                                          |           |          |
| UHCI_CONF0_REG          | UHCI configuration register              | 0x0000    | R/W      |
| UHCI_CONF1_REG          | UHCI configuration register              | 0x0014    | varies   |
| UHCI_ESCAPE_CONF_REG    | Escape character configuration           | 0x0020    | R/W      |
| UHCI_HUNG_CONF_REG      | Timeout configuration                    | 0x0024    | R/W      |
| UHCI_ACK_NUM_REG        | UHCI ACK number configuration            | 0x0028    | varies   |
| UHCI_QUICK_SENT_REG     | UHCI quick_sent configuration register   | 0x0030    | varies   |
| UHCI_REG_Q0_WORD0_REG   | Q0_WORD0 quick_sent register             | 0x0034    | R/W      |
| UHCI_REG_Q0_WORD1_REG   | Q0_WORD1 quick_sent register             | 0x0038    | R/W      |
| UHCI_REG_Q1_WORD0_REG   | Q1_WORD0 quick_sent register             | 0x003C    | R/W      |
| UHCI_REG_Q1_WORD1_REG   | Q1_WORD1 quick_sent register             | 0x0040    | R/W      |
| UHCI_REG_Q2_WORD0_REG   | Q2_WORD0 quick_sent register             | 0x0044    | R/W      |
| UHCI_REG_Q2_WORD1_REG   | Q2_WORD1 quick_sent register             | 0x0048    | R/W      |
| UHCI_REG_Q3_WORD0_REG   | Q3_WORD0 quick_sent register             | 0x004C    | R/W      |
| UHCI_REG_Q3_WORD1_REG   | Q3_WORD1 quick_sent register             | 0x0050    | R/W      |
| UHCI_REG_Q4_WORD0_REG   | Q4_WORD0 quick_sent register             | 0x0054    | R/W      |
| UHCI_REG_Q4_WORD1_REG   | Q4_WORD1 quick_sent register             | 0x0058    | R/W      |
| UHCI_REG_Q5_WORD0_REG   | Q5_WORD0 quick_sent register             | 0x005C    | R/W      |
| UHCI_REG_Q5_WORD1_REG   | Q5_WORD1 quick_sent register             | 0x0060    | R/W      |
| UHCI_REG_Q6_WORD0_REG   | Q6_WORD0 quick_sent register             | 0x0064    | R/W      |
| UHCI_REG_Q6_WORD1_REG   | Q6_WORD1 quick_sent register             | 0x0068    | R/W      |
| UHCI_ESC_CONF0_REG      | Escape sequence configuration register 0 | 0x006C    | R/W      |
| UHCI_ESC_CONF1_REG      | Escape sequence configuration register 1 | 0x0070    | R/W      |
| UHCI_ESC_CONF2_REG      | Escape sequence configuration register 2 | 0x0074    | R/W      |
| UHCI_ESC_CONF3_REG      | Escape sequence configuration register 3 | 0x0078    | R/W      |
| UHCI_PKT_THRES_REG      | Configuration register for packet length | 0x007C    | R/W      |
| UHCI Interrupt Register |                                          |           |          |
| UHCI_INT_RAW_REG        | Raw interrupt status                     | 0x0004    | varies   |
| UHCI_INT_ST_REG         | Masked interrupt status                  | 0x0008    | RO       |
| UHCI_INT_ENA_REG        | Interrupt enable bits                    | 0x000C    | R/W      |
| UHCI_INT_CLR_REG        | Interrupt clear bits                     | 0x0010    | WT       |
| UHCI Status Register    |                                          |           |          |
| UHCI_STATE0_REG         | UHCI receive status                      | 0x0018    | RO       |
| UHCI_STATE1_REG         | UHCI transmit status                     | 0x001C    | RO       |
| UHCI_RX_HEAD_REG        | UHCI packet header register              | 0x002C    | RO       |

ESP32-C3 TRM (Version 1.3)

| Name          | Description                   | Address   | Access   |
|---------------|-------------------------------|-----------|----------|
| UHCI_DATE_REG | UHCI version control register | 0x0080    | R/W      |

## 26.7 Registers

The addresses in this section are relative to UART Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 26.1. UART\_FIFO\_REG (0x0000)

![Image](images/26_Chapter_26_img022_a3382b68.png)

UART\_RXFIFO\_RD\_BYTE UARTn accesses FIFO via this field. (RO)

Register 26.2. UART\_MEM\_CONF\_REG (0x0060)

![Image](images/26_Chapter_26_img023_8eba0c0b.png)

- UART\_RX\_SIZE This field is used to configure the amount of RAM allocated for RX FIFO. The default number is 128 bytes. (R/W)
- UART\_TX\_SIZE This field is used to configure the amount of RAM allocated for TX FIFO. The default number is 128 bytes. (R/W)
- UART\_RX\_FLOW\_THRHD This field is used to configure the maximum amount of data bytes that can be received when hardware flow control works. (R/W)
- UART\_RX\_TOUT\_THRHD This field is used to configure the threshold time that the receiver takes to receive one byte, in the unit of bit time (the time it takes to transfer one bit). The UART\_RXFIFO\_TOUT\_INT interrupt will be triggered when the receiver takes more time to receive one byte with UART RX\_TOUT\_EN set to 1. (R/W)

UART\_MEM\_FORCE\_PD Set this bit to force power down UART RAM. (R/W)

UART\_MEM\_FORCE\_PU Set this bit to force power up UART RAM. (R/W)

![Image](images/26_Chapter_26_img024_3f06ba44.png)

Register 26.3. UART\_INT\_RAW\_REG (0x0004)

![Image](images/26_Chapter_26_img025_85cae117.png)

- UART\_RXFIFO\_FULL\_INT\_RAW This interrupt raw bit turns to high level when the receiver receives more data than what UART\_RXFIFO\_FULL\_THRHD specifies. (R/WTC/SS)
- UART\_TXFIFO\_EMPTY\_INT\_RAW This interrupt raw bit turns to high level when the amount of data in TX FIFO is less than what UART\_TXFIFO\_EMPTY\_THRHD specifies. (R/WTC/SS)
- UART\_PARITY\_ERR\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects a parity error in the data. (R/WTC/SS)
- UART\_FRM\_ERR\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects a data frame error. (R/WTC/SS)
- UART\_RXFIFO\_OVF\_INT\_RAW This interrupt raw bit turns to high level when the receiver receives more data than the capacity of RX FIFO. (R/WTC/SS)
- UART\_DSR\_CHG\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects the edge change of DSRn signal. (R/WTC/SS)
- UART\_CTS\_CHG\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects the edge change of CTSn signal. (R/WTC/SS)
- UART\_BRK\_DET\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects a 0 after the stop bit. (R/WTC/SS)
- UART\_RXFIFO\_TOUT\_INT\_RAW This interrupt raw bit turns to high level when the receiver takes more time than UART\_RX\_TOUT\_THRHD to receive a byte. (R/WTC/SS)
- UART\_SW\_XON\_INT\_RAW This interrupt raw bit turns to high level when the receiver receives an XON character and UART\_SW\_FLOW\_CON\_EN is set to 1. (R/WTC/SS)
- UART\_SW\_XOFF\_INT\_RAW This interrupt raw bit turns to high level when the receiver receives an XOFF character and UART\_SW\_FLOW\_CON\_EN is set to 1. (R/WTC/SS)
- UART\_GLITCH\_DET\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects a glitch in the middle of a start bit. (R/WTC/SS)
- Continued on the next page...

## Register 26.3. UART\_INT\_RAW\_REG (0x0004)

## Continued from the previous page...

- UART\_TX\_BRK\_DONE\_INT\_RAW This interrupt raw bit turns to high level when the transmitter completes sending NULL characters, after all data in TX FIFO are sent. (R/WTC/SS)
- UART\_TX\_BRK\_IDLE\_DONE\_INT\_RAW This interrupt raw bit turns to high level when the transmitter has kept the shortest duration after sending the last data. (R/WTC/SS)
- UART\_TX\_DONE\_INT\_RAW This interrupt raw bit turns to high level when the transmitter has sent out all data in FIFO. (R/WTC/SS)
- UART\_RS485\_PARITY\_ERR\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects a parity error from the echo of the transmitter in RS485 mode. (R/WTC/SS)
- UART\_RS485\_FRM\_ERR\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects a data frame error from the echo of the transmitter in RS485 mode. (R/WTC/SS)
- UART\_RS485\_CLASH\_INT\_RAW This interrupt raw bit turns to high level when a collision is detected between the transmitter and the receiver in RS485 mode. (R/WTC/SS)
- UART\_AT\_CMD\_CHAR\_DET\_INT\_RAW This interrupt raw bit turns to high level when the receiver detects the configured UART\_AT\_CMD\_CHAR. (R/WTC/SS)
- UART\_WAKEUP\_INT\_RAW This interrupt raw bit turns to high level when the input RXD edge changes more times than what (UART\_ACTIVE\_THRESHOLD + 3) specifies in Light-sleep mode. (R/WTC/SS)

![Image](images/26_Chapter_26_img026_e49deb7e.png)

ESP32-C3 TRM (Version 1.3)

Register 26.4. UART\_INT\_ST\_REG (0x0008)

![Image](images/26_Chapter_26_img027_a83b0dd5.png)

| UART_RXFIFO_FULL_INT_ST This is the status bit for UART_RXFIFO_FULL_INT when UART_RXFIFO_FULL_INT_ENA is set to 1. (RO)    |
|----------------------------------------------------------------------------------------------------------------------------|
| UART_TXFIFO_EMPTY_INT_ST This is the status bit for UART_TXFIFO_EMPTY_INT when UART_TXFIFO_EMPTY_INT_ENA is set to 1. (RO) |
| UART_PARITY_ERR_INT_ST This is the status bit for UART_PARITY_ERR_INT when UART_PARITY_ERR_INT_ENA is set to 1. (RO)       |
| UART_FRM_ERR_INT_ST This is the status bit for UART_FRM_ERR_INT when UART_FRM_ERR_INT_ENA is set to 1. (RO)                |
| UART_RXFIFO_OVF_INT_ST This is the status bit for UART_RXFIFO_OVF_INT when UART_RXFIFO_OVF_INT_ENA is set to 1. (RO)       |
| UART_DSR_CHG_INT_ST This is the status bit for UART_DSR_CHG_INT when UART_DSR_CHG_INT_ENA is set to 1. (RO)                |
| UART_CTS_CHG_INT_ST This is the status bit for UART_CTS_CHG_INT when UART_CTS_CHG_INT_ENA is set to 1. (RO)                |
| UART_BRK_DET_INT_ST This is the status bit for UART_BRK_DET_INT when UART_BRK_DET_INT_ENA is set to 1. (RO)                |
| UART_RXFIFO_TOUT_INT_ST This is the status bit for UART_RXFIFO_TOUT_INT when UART_RXFIFO_TOUT_INT_ENA is set to 1. (RO)    |
| UART_SW_XON_INT_ST This is the status bit for UART_SW_XON_INT when UART_SW_XON_INT_ENA is set to 1. (RO)                   |
| UART_SW_XOFF_INT_ST This is the status bit for UART_SW_XOFF_INT when UART_SW_XOFF_INT_ENA is set to 1. (RO)                |
| UART_GLITCH_DET_INT_ST This is the status bit for UART_GLITCH_DET_INT when UART_GLITCH_DET_INT_ENA is set to 1. (RO)       |
| UART_TX_BRK_DONE_INT_ST This is the status bit for UART_TX_BRK_DONE_INT when UART_TX_BRK_DONE_INT_ENA is set to 1. (RO)    |
| Continued on the next page...                                                                                              |

## Register 26.4. UART\_INT\_ST\_REG (0x0008)

## Continued from the previous page...

- UART\_TX\_BRK\_IDLE\_DONE\_INT\_ST This is the status bit for UART\_TX\_BRK\_IDLE\_DONE\_INT when UART\_TX\_BRK\_IDLE\_DONE\_INT\_ENA is set to 1. (RO)
- UART\_TX\_DONE\_INT\_ST This is the status bit for UART\_TX\_DONE\_INT when UART\_TX\_DONE\_INT\_ENA is set to 1. (RO)
- UART\_RS485\_PARITY\_ERR\_INT\_ST This is the status bit for UART\_RS485\_PARITY\_ERR\_INT when UART\_RS485\_PARITY\_INT\_ENA is set to 1. (RO)
- UART\_RS485\_FRM\_ERR\_INT\_ST This is the status bit for UART\_RS485\_FRM\_ERR\_INT when UART\_RS485\_FRM\_ERR\_INT\_ENA is set to 1. (RO)
- UART\_RS485\_CLASH\_INT\_ST This is the status bit for UART\_RS485\_CLASH\_INT when UART\_RS485\_CLASH\_INT\_ENA is set to 1. (RO)
- UART\_AT\_CMD\_CHAR\_DET\_INT\_ST This is the status bit for UART\_AT\_CMD\_CHAR\_DET\_INT when UART\_AT\_CMD\_CHAR\_DET\_INT\_ENA is set to 1. (RO)
- UART\_WAKEUP\_INT\_ST This is the status bit for UART\_WAKEUP\_INT when UART\_WAKEUP\_INT\_ENA is set to 1. (RO)

![Image](images/26_Chapter_26_img028_24953d0a.png)

Register 26.5. UART\_INT\_ENA\_REG (0x000C)

![Image](images/26_Chapter_26_img029_c5f5269d.png)

UART\_RXFIFO\_FULL\_INT\_ENA This is the enable bit for UART\_RXFIFO\_FULL\_INT. (R/W)

UART\_TXFIFO\_EMPTY\_INT\_ENA This is the enable bit for UART\_TXFIFO\_EMPTY\_INT. (R/W)

UART\_PARITY\_ERR\_INT\_ENA This is the enable bit for UART\_PARITY\_ERR\_INT. (R/W)

UART\_FRM\_ERR\_INT\_ENA This is the enable bit for UART\_FRM\_ERR\_INT. (R/W)

UART\_RXFIFO\_OVF\_INT\_ENA This is the enable bit for UART\_RXFIFO\_OVF\_INT. (R/W)

UART\_DSR\_CHG\_INT\_ENA This is the enable bit for UART\_DSR\_CHG\_INT. (R/W)

UART\_CTS\_CHG\_INT\_ENA This is the enable bit for UART\_CTS\_CHG\_INT. (R/W)

UART\_BRK\_DET\_INT\_ENA This is the enable bit for UART\_BRK\_DET\_INT. (R/W)

UART\_RXFIFO\_TOUT\_INT\_ENA This is the enable bit for UART\_RXFIFO\_TOUT\_INT. (R/W)

UART\_SW\_XON\_INT\_ENA This is the enable bit for UART\_SW\_XON\_INT. (R/W)

UART\_SW\_XOFF\_INT\_ENA This is the enable bit for UART\_SW\_XOFF\_INT. (R/W)

UART\_GLITCH\_DET\_INT\_ENA This is the enable bit for UART\_GLITCH\_DET\_INT. (R/W)

UART\_TX\_BRK\_DONE\_INT\_ENA This is the enable bit for UART\_TX\_BRK\_DONE\_INT. (R/W)

UART\_TX\_BRK\_IDLE\_DONE\_INT\_ENA This is the enable bit for UART\_TX\_BRK\_IDLE\_DONE\_INT. (R/W)

UART\_TX\_DONE\_INT\_ENA This is the enable bit for UART\_TX\_DONE\_INT. (R/W)

Continued on the next page...

![Image](images/26_Chapter_26_img030_466996a7.png)

## Register 26.5. UART\_INT\_ENA\_REG (0x000C)

Continued from the previous page...

UART\_RS485\_PARITY\_ERR\_INT\_ENA This is the enable bit for UART\_RS485\_PARITY\_ERR\_INT. (R/W)

UART\_RS485\_FRM\_ERR\_INT\_ENA This is the enable bit for UART\_RS485\_PARITY\_ERR\_INT. (R/W)

UART\_RS485\_CLASH\_INT\_ENA This is the enable bit for UART\_RS485\_CLASH\_INT. (R/W)

UART\_AT\_CMD\_CHAR\_DET\_INT\_ENA This is the enable bit for UART\_AT\_CMD\_CHAR\_DET\_INT. (R/W)

UART\_WAKEUP\_INT\_ENA This is the enable bit for UART\_WAKEUP\_INT. (R/W)

![Image](images/26_Chapter_26_img031_fa174e82.png)

Register 26.6. UART\_INT\_CLR\_REG (0x0010)

![Image](images/26_Chapter_26_img032_388f3397.png)

UART\_RXFIFO\_FULL\_INT\_CLR Set this bit to clear the UART\_THE RXFIFO\_FULL\_INT interrupt. (WT)

UART\_TXFIFO\_EMPTY\_INT\_CLR Set this bit to clear the UART\_TXFIFO\_EMPTY\_INT interrupt. (WT)

UART\_PARITY\_ERR\_INT\_CLR Set this bit to clear the UART\_PARITY\_ERR\_INT interrupt. (WT)

UART\_FRM\_ERR\_INT\_CLR Set this bit to clear the UART\_FRM\_ERR\_INT interrupt. (WT)

UART\_RXFIFO\_OVF\_INT\_CLR Set this bit to clear the UART\_UART\_RXFIFO\_OVF\_INT interrupt. (WT)

UART\_DSR\_CHG\_INT\_CLR Set this bit to clear the UART\_DSR\_CHG\_INT interrupt. (WT)

UART\_CTS\_CHG\_INT\_CLR Set this bit to clear the UART\_CTS\_CHG\_INT interrupt. (WT)

UART\_BRK\_DET\_INT\_CLR Set this bit to clear the UART\_BRK\_DET\_INT interrupt. (WT)

UART\_RXFIFO\_TOUT\_INT\_CLR Set this bit to clear the UART\_RXFIFO\_TOUT\_INT interrupt. (WT)

UART\_SW\_XON\_INT\_CLR Set this bit to clear the UART\_SW\_XON\_INT interrupt. (WT)

UART\_SW\_XOFF\_INT\_CLR Set this bit to clear the UART\_SW\_XOFF\_INT interrupt. (WT)

UART\_GLITCH\_DET\_INT\_CLR Set this bit to clear the UART\_GLITCH\_DET\_INT interrupt. (WT)

UART\_TX\_BRK\_DONE\_INT\_CLR Set this bit to clear the UART\_TX\_BRK\_DONE\_INT interrupt. (WT)

UART\_TX\_BRK\_IDLE\_DONE\_INT\_CLR Set this bit to clear the UART\_TX\_BRK\_IDLE\_DONE\_INT interrupt. (WT)

UART\_TX\_DONE\_INT\_CLR Set this bit to clear the UART\_TX\_DONE\_INT interrupt. (WT)

UART\_RS485\_PARITY\_ERR\_INT\_CLR Set this bit to clear the UART\_RS485\_PARITY\_ERR\_INT interrupt. (WT)

Continued on the next page...

![Image](images/26_Chapter_26_img033_d2c2e9d0.png)

## Register 26.6. UART\_INT\_CLR\_REG (0x0010)

Continued from the previous page...

UART\_RS485\_FRM\_ERR\_INT\_CLR Set this bit to clear the UART\_RS485\_FRM\_ERR\_INT interrupt. (WT)

UART\_RS485\_CLASH\_INT\_CLR Set this bit to clear the UART\_RS485\_CLASH\_INT interrupt. (WT)

UART\_AT\_CMD\_CHAR\_DET\_INT\_CLR Set this bit to clear the UART\_AT\_CMD\_CHAR\_DET\_INT interrupt. (WT)

UART\_WAKEUP\_INT\_CLR Set this bit to clear the UART\_WAKEUP\_INT interrupt. (WT)

## Register 26.7. UART\_CLKDIV\_REG (0x0014)

![Image](images/26_Chapter_26_img034_ffe4b1fc.png)

UART\_CLKDIV The integral part of the frequency divisor. (R/W)

UART\_CLKDIV\_FRAG The fractional part of the frequency divisor. (R/W)

Register 26.8. UART\_RX\_FILT\_REG (0x0018)

![Image](images/26_Chapter_26_img035_f9af1bcf.png)

UART\_GLITCH\_FILT When input pulse width is lower than this value, the pulse is ignored. (R/W) UART\_GLITCH\_FILT\_EN Set this bit to enable RX signal filter. (R/W)

## Register 26.9. UART\_CONF0\_REG (0x0020)

![Image](images/26_Chapter_26_img036_95f6495b.png)

UART\_PARITY This bit is used to configure the parity check mode. (R/W)

UART\_PARITY\_EN Set this bit to enable UART parity check. (R/W)

UART\_BIT\_NUM This field is used to set the length of data. (R/W)

UART\_STOP\_BIT\_NUM This field is used to set the length of stop bit. (R/W)

UART\_SW\_RTS This bit is used to configure the software RTS signal which is used in software flow control. (R/W)

UART\_SW\_DTR This bit is used to configure the software DTR signal which is used in software flow control. (R/W)

UART\_TXD\_BRK Set this bit to enable the transmitter to send NULL characters when the process of sending data is done. (R/W)

UART\_IRDA\_DPLX Set this bit to enable IrDA loopback mode. (R/W)

UART\_IRDA\_TX\_EN This is the start enable bit for IrDA transmitter. (R/W)

UART\_IRDA\_WCTL 1: The IrDA transmitter's 11th bit is the same as 10th bit; 0: Set IrDA transmitter's 11th bit to 0. (R/W)

UART\_IRDA\_TX\_INV Set this bit to invert the level of IrDA transmitter. (R/W)

UART\_IRDA\_RX\_INV Set this bit to invert the level of IrDA receiver. (R/W)

UART\_LOOPBACK Set this bit to enable UART loopback test mode. (R/W)

UART\_TX\_FLOW\_EN Set this bit to enable flow control function for the transmitter. (R/W)

UART\_IRDA\_EN Set this bit to enable IrDA protocol. (R/W)

UART\_RXFIFO\_RST Set this bit to reset the UART RX FIFO. (R/W)

UART\_TXFIFO\_RST Set this bit to reset the UART TX FIFO. (R/W)

UART\_RXD\_INV Set this bit to invert the level value of UART RXD signal. (R/W)

UART\_CTS\_INV Set this bit to invert the level value of UART CTS signal. (R/W)

UART\_DSR\_INV Set this bit to invert the level value of UART DSR signal. (R/W)

Continued on the next page...

## Register 26.9. UART\_CONF0\_REG (0x0020)

## Continued from the previous page...

UART\_TXD\_INV Set this bit to invert the level value of UART TXD signal. (R/W)

UART\_RTS\_INV Set this bit to invert the level value of UART RTS signal. (R/W)

UART\_DTR\_INV Set this bit to invert the level value of UART DTR signal. (R/W)

UART\_CLK\_EN 1: Force clock on for register; 0: Support clock only when application writes registers. (R/W)

UART\_ERR\_WR\_MASK 1: The receiver stops storing data into FIFO when data is wrong; 0: The receiver stores the data even if the received data is wrong. (R/W)

UART\_AUTOBAUD\_EN This is the enable bit for baud rate detection. (R/W)

UART\_MEM\_CLK\_EN The signal to enable UART RAM clock gating. (R/W)

## Register 26.10. UART\_CONF1\_REG (0x0024)

![Image](images/26_Chapter_26_img037_4c9f9ee8.png)

UART\_RXFIFO\_FULL\_THRHD An UART\_RXFIFO\_FULL\_INT interrupt is generated when the receiver receives more data than the value of this field. (R/W)

UART\_TXFIFO\_EMPTY\_THRHD An UART\_TXFIFO\_EMPTY\_INT interrupt is generated when the number of data bytes in TX FIFO is less than the value of this field. (R/W)

UART\_DIS\_RX\_DAT\_OVF Disable UART RX data overflow detection. (R/W)

UART\_RX\_TOUT\_FLOW\_DIS Set this bit to stop accumulating idle\_cnt when hardware flow control works. (R/W)

UART\_RX\_FLOW\_EN This is the flow enable bit for UART receiver. (R/W)

UART\_RX\_TOUT\_EN This is the enable bit for UART receiver’s timeout function. (R/W)

## Register 26.11. UART\_FLOW\_CONF\_REG (0x0034)

![Image](images/26_Chapter_26_img038_78235d68.png)

UART\_SW\_FLOW\_CON\_EN Set this bit to enable software flow control. When UART receives flow control characters XON or XOFF, which can be configured by UART\_XON\_CHAR or UART\_XOFF\_CHAR respectively, UART\_SW\_XON\_INT or UART\_SW\_XOFF\_INT interrupts can be triggered if enabled. (R/W)

UART\_XONOFF\_DEL Set this bit to remove flow control characters from the received data. (R/W)

UART\_FORCE\_XON Set this bit to force the transmitter to send data. (R/W)

UART\_FORCE\_XOFF Set this bit to stop the transmitter from sending data. (R/W)

UART\_SEND\_XON Set this bit to send an XON character. This bit is cleared by hardware automatically. (R/W/SS/SC)

UART\_SEND\_XOFF Set this bit to send an XOFF character. This bit is cleared by hardware automatically. (R/W/SS/SC)

## Register 26.12. UART\_SLEEP\_CONF\_REG (0x0038)

![Image](images/26_Chapter_26_img039_7a844999.png)

UART\_ACTIVE\_THRESHOLD UART is activated from Light-sleep mode when the input RXD edge changes more times than the value of this field plus 3. (R/W)

## Register 26.13. UART\_SWFC\_CONF0\_REG (0x003C)

![Image](images/26_Chapter_26_img040_01bffd35.png)

UART\_XOFF\_THRESHOLD When the number of data bytes in RX FIFO is more than the value of this field with UART\_SW\_FLOW\_CON\_EN set to 1, the transmitter sends an XOFF character. (R/W)

UART\_XOFF\_CHAR This field stores the XOFF flow control character. (R/W)

## Register 26.14. UART\_SWFC\_CONF1\_REG (0x0040)

![Image](images/26_Chapter_26_img041_dffd0723.png)

UART\_XON\_THRESHOLD When the number of data bytes in RX FIFO is less than the value of this field with UART\_SW\_FLOW\_CON\_EN set to 1, the transmitter sends an XON character. (R/W)

UART\_XON\_CHAR This field stores the XON flow control character. (R/W)

## Register 26.15. UART\_TXBRK\_CONF\_REG (0x0044)

![Image](images/26_Chapter_26_img042_9123fc82.png)

UART\_TX\_BRK\_NUM This field is used to configure the number of 0 to be sent after the process of sending data is done. It is active when UART\_TXD\_BRK is set to 1. (R/W)

## Register 26.16. UART\_IDLE\_CONF\_REG (0x0048)

![Image](images/26_Chapter_26_img043_78faadab.png)

UART\_RX\_IDLE\_THRHD A frame end signal is generated when the receiver takes more time to receive one byte data than the value of this field, in the unit of bit time (the time it takes to transfer one bit). (R/W)

UART\_TX\_IDLE\_NUM This field is used to configure the duration time between transfers, in the unit of bit time (the time it takes to transfer one bit). (R/W)

## Register 26.17. UART\_RS485\_CONF\_REG (0x004C)

![Image](images/26_Chapter_26_img044_6f87f367.png)

UART\_RS485\_EN Set this bit to choose RS485 mode. (R/W)

UART\_DL0\_EN Configures whether or not to add a turnaround delay of 1 bit before the start bit.

0: Not add

1: Add

(R/W)

- UART\_DL1\_EN Configures whether or not to add a turnaround delay of 1 bit after the stop bit.

0: Not add

1: Add

(R/W)

- UART\_RS485TX\_RX\_EN Set this bit to enable the receiver could receive data when the transmitter is transmitting data in RS485 mode. (R/W)

UART\_RS485RXBY\_TX\_EN 1: enable RS485 transmitter to send data when RS485 receiver line is busy. (R/W)

UART\_RS485\_RX\_DLY\_NUM This bit is used to delay the receiver’s internal data signal. (R/W)

UART\_RS485\_TX\_DLY\_NUM This field is used to delay the transmitter’s internal data signal. (R/W)

## Register 26.18. UART\_CLK\_CONF\_REG (0x0078)

![Image](images/26_Chapter_26_img045_0c39477f.png)

UART\_SCLK\_DIV\_B The denominator of the frequency divisor. (R/W)

UART\_SCLK\_DIV\_A The numerator of the frequency divisor. (R/W)

UART\_SCLK\_DIV\_NUM The integral part of the frequency divisor. (R/W)

UART\_SCLK\_SEL Selects UART clock source. 1: APB\_CLK; 2: RC\_FAST\_CLK; 3: XTAL\_CLK. (R/W)

UART\_SCLK\_EN Set this bit to enable UART TX/RX clock. (R/W)

UART\_RST\_CORE Write 1 and then write 0 to this bit, to reset UART TX/RX. (R/W)

UART\_TX\_SCLK\_EN Set this bit to enable UART TX clock. (R/W)

UART\_RX\_SCLK\_EN Set this bit to enable UART RX clock. (R/W)

## Register 26.19. UART\_STATUS\_REG (0x001C)

![Image](images/26_Chapter_26_img046_2afda3e4.png)

UART\_RXFIFO\_CNT Stores the number of valid data bytes in RX FIFO. (RO)

UART\_DSRN This bit represents the level of the internal UART DSR signal. (RO)

UART\_CTSN This bit represents the level of the internal UART CTS signal. (RO)

UART\_RXD This bit represents the level of the internal UART RXD signal. (RO)

UART\_TXFIFO\_CNT Stores the number of data bytes in TX FIFO. (RO)

UART\_DTRN This bit represents the level of the internal UART DTR signal. (RO)

UART\_RTSN This bit represents the level of the internal UART RTS signal. (RO)

UART\_TXD This bit represents the level of the internal UART TXD signal. (RO)

![Image](images/26_Chapter_26_img047_0b9eb4de.png)

Register 26.20. UART\_MEM\_TX\_STATUS\_REG (0x0064)

![Image](images/26_Chapter_26_img048_9c6cb7bc.png)

UART\_APB\_TX\_WADDR This field stores the offset address in TX FIFO when software writes TX FIFO via APB. (RO)

UART\_TX\_RADDR This field stores the offset address in TX FIFO when TX FSM reads data via Tx\_FIFO\_Ctrl. (RO)

Register 26.21. UART\_MEM\_RX\_STATUS\_REG (0x0068)

![Image](images/26_Chapter_26_img049_d0a9293a.png)

UART\_APB\_RX\_RADDR This field stores the offset address in RX FIFO when software reads data from RX FIFO via APB. UART0 is 0x200. UART1 is 0x280. (RO)

UART\_RX\_WADDR This field stores the offset address in RX FIFO when Rx\_FIFO\_Ctrl writes RX FIFO. (RO)

Register 26.22. UART\_FSM\_STATUS\_REG (0x006C)

![Image](images/26_Chapter_26_img050_973ad7f3.png)

![Image](images/26_Chapter_26_img051_9736b7d1.png)

31

12

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

UART\_POSEDGE\_MIN\_CNT

0xfff

Reset

UART\_POSEDGE\_MIN\_CNT This field stores the minimal input clock count between two positive edges. It is used in baud rate detection. (RO)

Register 26.27. UART\_NEGPULSE\_REG (0x0074)

![Image](images/26_Chapter_26_img052_94a8b93b.png)

UART\_NEGEDGE\_MIN\_CNT This field stores the minimal input clock count between two negative edges. It is used in baud rate detection. (RO)

Register 26.28. UART\_AT\_CMD\_PRECNT\_REG (0x0050)

(reserved)

UART\_PRE\_IDLE\_NUM

0x901

31

16

0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0

Reset

UART\_PRE\_IDLE\_NUM This field is used to configure the idle duration time before the first AT\_CMD is received by the receiver, in the unit of bit time (the time it takes to transfer one bit). (R/W)

Register 26.26. UART\_POSPULSE\_REG (0x0070)

(reserved)

15

11

0

0

Register 26.29. UART\_AT\_CMD\_POSTCNT\_REG (0x0054)

![Image](images/26_Chapter_26_img053_fdd737a8.png)

UART\_POST\_IDLE\_NUM This field is used to configure the duration time between the last AT\_CMD and the next data byte, in the unit of bit time (the time it takes to transfer one bit). (R/W)

Register 26.30. UART\_AT\_CMD\_GAPTOUT\_REG (0x0058)

![Image](images/26_Chapter_26_img054_38b6c996.png)

UART\_RX\_GAP\_TOUT This field is used to configure the duration time between the AT\_CMD characters, in the unit of bit time (the time it takes to transfer one bit). (R/W)

Register 26.31. UART\_AT\_CMD\_CHAR\_REG (0x005C)

![Image](images/26_Chapter_26_img055_3eccc77f.png)

UART\_AT\_CMD\_CHAR This field is used to configure the content of AT\_CMD character. (R/W)

UART\_CHAR\_NUM This field is used to configure the number of continuous AT\_CMD characterss received by the receiver. (R/W)

## Register 26.32. UART\_DATE\_REG (0x007C)

![Image](images/26_Chapter_26_img056_e9574a4e.png)

UART\_DATE This is the version control register. (R/W)

## Register 26.33. UART\_ID\_REG (0x0080)

![Image](images/26_Chapter_26_img057_42d2817f.png)

UART\_ID This field is used to configure the UART\_ID. (R/W)

UART\_UPDATE\_CTRL This bit is used to control register synchronization mode. This bit must be cleared before writing 1 to UART\_REG\_UPDATE to synchronize configured values to UART Core's clock domain. (R/W)

UART\_REG\_UPDATE When this bit is set to 1 by software, registers are synchronized to UART Core's clock domain. This bit is cleared by hardware after synchronization is done. (R/W/SC)

Register 26.34. UHCI\_CONF0\_REG (0x0000)

![Image](images/26_Chapter_26_img058_fdf7af24.png)

UHCI\_TX\_RST Write 1, then write 0 to this bit to reset decode state machine. (R/W)

UHCI\_RX\_RST Write 1, then write 0 to this bit to reset encode state machine. (R/W)

UHCI\_UART0\_CE Set this bit to link up UHCI and UART0. (R/W)

UHCI\_UART1\_CE Set this bit to link up UHCI and UART1. (R/W)

UHCI\_SEPER\_EN Set this bit to separate the data frame using a special character. (R/W)

UHCI\_HEAD\_EN Set this bit to encode the data packet with a formatting header. (R/W)

UHCI\_CRC\_REC\_EN Set this bit to enable UHCI to receive the 16 bit CRC. (R/W)

UHCI\_UART\_IDLE\_EOF\_EN If this bit is set to 1, UHCI will end the payload receiving process when UART has been in idle state. (R/W)

UHCI\_LEN\_EOF\_EN If this bit is set to 1, UHCI decoder stops receiving payload data when the number of received data bytes has reached the specified value. The value is payload length indicated by UHCI packet header when UHCI\_HEAD\_EN is 1 or the value is configuration value when UHCI\_HEAD\_EN is 0. If this bit is set to 0, UHCI decoder stops receiving payload data when 0xC0 has been received. (R/W)

UHCI\_ENCODE\_CRC\_EN Set this bit to enable data integrity check by appending a 16 bit CCITT-CRC to end of the payload. (R/W)

UHCI\_CLK\_EN 1: Force clock on for register; 0: Support clock only when application writes registers. (R/W)

UHCI\_UART\_RX\_BRK\_EOF\_EN If this bit is set to 1, UHCI will end payload receive process when NULL frame is received by UART. (R/W)

## Register 26.35. UHCI\_CONF1\_REG (0x0014)

![Image](images/26_Chapter_26_img059_9c822814.png)

- UHCI\_CHECK\_SUM\_EN This is the enable bit to check header checksum when UHCI receives a data packet. (R/W)

UHCI\_CHECK\_SEQ\_EN This is the enable bit to check sequence number when UHCI receives a data packet. (R/W)

UHCI\_CRC\_DISABLE Set this bit to support CRC calculation. Data Integrity Check Present bit in UHCI packet frame should be 1. (R/W)

UHCI\_SAVE\_HEAD Set this bit to save the packet header when UHCI receives a data packet. (R/W)

UHCI\_TX\_CHECK\_SUM\_RE Set this bit to encode the data packet with a checksum. (R/W)

UHCI\_TX\_ACK\_NUM\_RE Set this bit to encode the data packet with an acknowledgment when a reliable packet is to be transmitted. (R/W)

UHCI\_WAIT\_SW\_START The UHCI der will jump to ST\_SW\_WAIT status if this bit is set to 1. (R/W)

UHCI\_SW\_START If current UHCI\_ENCODE\_STATE is ST\_SW\_WAIT, the UHCI will start to send data packet out when this bit is set to 1. (R/W/SC)

![Image](images/26_Chapter_26_img060_a109d1ad.png)

## Register 26.36. UHCI\_ESCAPE\_CONF\_REG (0x0020)

![Image](images/26_Chapter_26_img061_9a3951b2.png)

- UHCI\_TX\_C0\_ESC\_EN Set this bit to decode character 0xC0 when DMA receives data. (R/W)
- UHCI\_TX\_DB\_ESC\_EN Set this bit to decode character 0xDB when DMA receives data. (R/W)
- UHCI\_TX\_11\_ESC\_EN Set this bit to decode flow control character 0x11 when DMA receives data. (R/W)
- UHCI\_TX\_13\_ESC\_EN Set this bit to decode flow control character 0x13 when DMA receives data. (R/W)
- UHCI\_RX\_C0\_ESC\_EN Set this bit to replace 0xC0 by special characters when DMA sends data. (R/W)
- UHCI\_RX\_DB\_ESC\_EN Set this bit to replace 0xDB by special characters when DMA sends data. (R/W)
- UHCI\_RX\_11\_ESC\_EN Set this bit to replace flow control character 0x11 by special characters when DMA sends data. (R/W)
- UHCI\_RX\_13\_ESC\_EN Set this bit to replace flow control character 0x13 by special characters when DMA sends data. (R/W)

## Register 26.37. UHCI\_HUNG\_CONF\_REG (0x0024)

![Image](images/26_Chapter_26_img062_0406229d.png)

UHCI\_TXFIFO\_TIMEOUT This field stores the timeout value. UHCI will produce the UHCI\_TX\_HUNG\_INT interrupt when DMA takes more time to receive data. (R/W)

UHCI\_TXFIFO\_TIMEOUT\_SHIFT This field is used to configure the maximum tick count. (R/W)

UHCI\_TXFIFO\_TIMEOUT\_ENA This is the enable bit for TX FIFO receive timeout. (R/W)

UHCI\_RXFIFO\_TIMEOUT This field stores the timeout value. UHCI will produce the UHCI\_RX\_HUNG\_INT interrupt when DMA takes more time to read data from RAM. (R/W)

UHCI\_RXFIFO\_TIMEOUT\_SHIFT This field is used to configure the maximum tick count. (R/W)

UHCI\_RXFIFO\_TIMEOUT\_ENA This is the enable bit for DMA send timeout. (R/W)

## Register 26.38. UHCI\_ACK\_NUM\_REG (0x0028)

![Image](images/26_Chapter_26_img063_b259856e.png)

UHCI\_ACK\_NUM This is the ACK number used in software flow control. (R/W)

UHCI\_ACK\_NUM\_LOAD Set this bit to 1, and the value configured by UHCI\_ACK\_NUM would be loaded. (WT)

## Register 26.39. UHCI\_QUICK\_SENT\_REG (0x0030)

![Image](images/26_Chapter_26_img064_8d0bfcd6.png)

UHCI\_SINGLE\_SEND\_NUM This field is used to specify the single\_send mode. (R/W)

UHCI\_SINGLE\_SEND\_EN Set this bit to enable single\_send mode to send short packets. (R/W/SC)

UHCI\_ALWAYS\_SEND\_NUM This field is used to specify the always\_send mode. (R/W)

UHCI\_ALWAYS\_SEND\_EN Set this bit to enable always\_send mode to send short packets. (R/W)

## Register 26.40. UHCI\_REG\_Q0\_WORD0\_REG (0x0034)

![Image](images/26_Chapter_26_img065_29045fc5.png)

UHCI\_SEND\_Q0\_WORD0 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.41. UHCI\_REG\_Q0\_WORD1\_REG (0x0038)

![Image](images/26_Chapter_26_img066_79182bbd.png)

![Image](images/26_Chapter_26_img067_cbcdc919.png)

UHCI\_SEND\_Q0\_WORD1 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.42. UHCI\_REG\_Q1\_WORD0\_REG (0x003C)

UHCI\_SEND\_Q1\_WORD0

![Image](images/26_Chapter_26_img068_b7fc33fa.png)

UHCI\_SEND\_Q1\_WORD0 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.43. UHCI\_REG\_Q1\_WORD1\_REG (0x0040)

![Image](images/26_Chapter_26_img069_492e4fca.png)

![Image](images/26_Chapter_26_img070_beb92d17.png)

UHCI\_SEND\_Q1\_WORD1 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.44. UHCI\_REG\_Q2\_WORD0\_REG (0x0044)

![Image](images/26_Chapter_26_img071_964d7a78.png)

![Image](images/26_Chapter_26_img072_15a715d8.png)

UHCI\_SEND\_Q2\_WORD0 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.45. UHCI\_REG\_Q2\_WORD1\_REG (0x0048)

UHCI\_SEND\_Q2\_WORD1

![Image](images/26_Chapter_26_img073_95600e5f.png)

UHCI\_SEND\_Q2\_WORD1 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.46. UHCI\_REG\_Q3\_WORD0\_REG (0x004C)

UHCI\_SEND\_Q3\_WORD0

![Image](images/26_Chapter_26_img074_3c4da2ba.png)

UHCI\_SEND\_Q3\_WORD0 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.47. UHCI\_REG\_Q3\_WORD1\_REG (0x0050)

![Image](images/26_Chapter_26_img075_735c0f5d.png)

![Image](images/26_Chapter_26_img076_93e4ef64.png)

UHCI\_SEND\_Q3\_WORD1 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.48. UHCI\_REG\_Q4\_WORD0\_REG (0x0054)

![Image](images/26_Chapter_26_img077_da60c69c.png)

![Image](images/26_Chapter_26_img078_47fbf581.png)

UHCI\_SEND\_Q4\_WORD0 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.49. UHCI\_REG\_Q4\_WORD1\_REG (0x0058)

![Image](images/26_Chapter_26_img079_15b2cae0.png)

![Image](images/26_Chapter_26_img080_63769395.png)

UHCI\_SEND\_Q4\_WORD1 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.50. UHCI\_REG\_Q5\_WORD0\_REG (0x005C)

![Image](images/26_Chapter_26_img081_fc7f273f.png)

![Image](images/26_Chapter_26_img082_b3c8998c.png)

UHCI\_SEND\_Q5\_WORD0 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.51. UHCI\_REG\_Q5\_WORD1\_REG (0x0060)

![Image](images/26_Chapter_26_img083_4cfb2552.png)

![Image](images/26_Chapter_26_img084_cd0bf7e7.png)

UHCI\_SEND\_Q5\_WORD1 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.52. UHCI\_REG\_Q6\_WORD0\_REG (0x0064)

![Image](images/26_Chapter_26_img085_4f5e52f9.png)

![Image](images/26_Chapter_26_img086_0e4b52be.png)

UHCI\_SEND\_Q6\_WORD0 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

## Register 26.53. UHCI\_REG\_Q6\_WORD1\_REG (0x0068)

![Image](images/26_Chapter_26_img087_840b0280.png)

![Image](images/26_Chapter_26_img088_9508a984.png)

UHCI\_SEND\_Q6\_WORD1 This register is used as a quick\_sent register when mode is specified by UHCI\_ALWAYS\_SEND\_NUM or UHCI\_SINGLE\_SEND\_NUM. (R/W)

Register 26.54. UHCI\_ESC\_CONF0\_REG (0x006C)

![Image](images/26_Chapter_26_img089_5dacd809.png)

UHCI\_SEPER\_CHAR This field is used to define separators to encode data packets. The default value is 0xC0. (R/W)

UHCI\_SEPER\_ESC\_CHAR0 This field is used to define the first character of SLIP escape sequence. The default value is 0xDB. (R/W)

UHCI\_SEPER\_ESC\_CHAR1 This field is used to define the second character of SLIP escape sequence. The default value is 0xDC. (R/W)

Register 26.55. UHCI\_ESC\_CONF1\_REG (0x0070)

![Image](images/26_Chapter_26_img090_a36f78ab.png)

UHCI\_ESC\_SEQ0 This field is used to define a character that need to be encoded. The default value is 0xDB that used as the first character of SLIP escape sequence. (R/W)

UHCI\_ESC\_SEQ0\_CHAR0 This field is used to define the first character of SLIP escape sequence. The default value is 0xDB. (R/W)

UHCI\_ESC\_SEQ0\_CHAR1 This field is used to define the second character of SLIP escape sequence. The default value is 0xDD. (R/W)

![Image](images/26_Chapter_26_img091_ccb419bf.png)

Register 26.56. UHCI\_ESC\_CONF2\_REG (0x0074)

![Image](images/26_Chapter_26_img092_875116db.png)

UHCI\_ESC\_SEQ1 This field is used to define a character that need to be encoded. The default value is 0x11 that used as a flow control character. (R/W)

UHCI\_ESC\_SEQ1\_CHAR0 This field is used to define the first character of SLIP escape sequence. The default value is 0xDB. (R/W)

UHCI\_ESC\_SEQ1\_CHAR1 This field is used to define the second character of SLIP escape sequence. The default value is 0xDE. (R/W)

Register 26.57. UHCI\_ESC\_CONF3\_REG (0x0078)

![Image](images/26_Chapter_26_img093_66a4a473.png)

UHCI\_ESC\_SEQ2 This field is used to define a character that need to be decoded. The default value is 0x13 that used as a flow control character. (R/W)

UHCI\_ESC\_SEQ2\_CHAR0 This field is used to define the first character of SLIP escape sequence. The default value is 0xDB. (R/W)

UHCI\_ESC\_SEQ2\_CHAR1 This field is used to define the second character of SLIP escape sequence. The default value is 0xDF. (R/W)

![Image](images/26_Chapter_26_img094_2456dfc4.png)

Register 26.58. UHCI\_PKT\_THRES\_REG (0x007C)

![Image](images/26_Chapter_26_img095_290a184e.png)

UHCI\_PKT\_THRS This field is used to configure the maximum value of the packet length when UHCI\_HEAD\_EN is 0. (R/W)

![Image](images/26_Chapter_26_img096_042ef121.png)

## Register 26.59. UHCI\_INT\_RAW\_REG (0x0004)

![Image](images/26_Chapter_26_img097_60cae55f.png)

- UHCI\_RX\_START\_INT\_RAW This is the interrupt raw bit for UHCI\_RX\_START\_INT interrupt. The interrupt is triggered when a separator has been sent. (R/WTC/SS)
- UHCI\_TX\_START\_INT\_RAW This is the interrupt raw bit for UHCI\_TX\_START\_INT interrupt. The interrupt is triggered when UHCI detects a separator. (R/WTC/SS)
- UHCI\_RX\_HUNG\_INT\_RAW This is the interrupt raw bit for UHCI\_RX\_HUNG\_INT interrupt. The interrupt is triggered when UHCI takes more time to receive data than configure value. (R/WTC/SS)
- UHCI\_TX\_HUNG\_INT\_RAW This is the interrupt raw bit for UHCI\_TX\_HUNG\_INT interrupt. The interrupt is triggered when UHCI takes more time to read data from RAM than the configured value. (R/WTC/SS)
- UHCI\_SEND\_S\_REG\_Q\_INT\_RAW This is the interrupt raw bit for UHCI\_SEND\_S\_REG\_Q\_INT interrupt. The interrupt is triggered when UHCI has sent out a short packet using single\_send mode. (R/WTC/SS)
- UHCI\_SEND\_A\_REG\_Q\_INT\_RAW This is the interrupt raw bit for UHCI\_SEND\_A\_REG\_Q\_INT interrupt. The interrupt is triggered when UHCI has sent out a short packet using always\_send mode. (R/WTC/SS)
- UHCI\_OUT\_EOF\_INT\_RAW This is the interrupt raw bit for UHCI\_OUT\_EOF\_INT interrupt. The interrupt is triggered when there are some errors in EOF in the transmit descriptors. (R/WTC/SS)
- UHCI\_APP\_CTRL0\_INT\_RAW This is the interrupt raw bit for UHCI\_APP\_CTRL0\_INT interrupt. The interrupt is triggered when UHCI\_APP\_CTRL0\_IN\_SET is set. (R/W)
- UHCI\_APP\_CTRL1\_INT\_RAW This is the interrupt raw bit for UHCI\_APP\_CTRL1\_INT interrupt. The interrupt is triggered when UHCI\_APP\_CTRL1\_IN\_SET is set. (R/W)

## Register 26.60. UHCI\_INT\_ST\_REG (0x0008)

![Image](images/26_Chapter_26_img098_4cc663d3.png)

- UHCI\_RX\_START\_INT\_ST This is the masked interrupt bit for UHCI\_RX\_START\_INT interrupt when UHCI\_RX\_START\_INT\_ENA is set to 1. (RO)
- UHCI\_TX\_START\_INT\_ST This is the masked interrupt bit for UHCI\_TX\_START\_INT interrupt when UHCI\_TX\_START\_INT\_ENA is set to 1. (RO)
- UHCI\_RX\_HUNG\_INT\_ST This is the masked interrupt bit for UHCI\_RX\_HUNG\_INT interrupt when UHCI\_RX\_HUNG\_INT\_ENA is set to 1. (RO)

UHCI\_TX\_HUNG\_INT\_ST This is the masked interrupt bit for UHCI\_TX\_HUNG\_INT interrupt when UHCI\_TX\_HUNG\_INT\_ENA is set to 1. (RO)

- UHCI\_SEND\_S\_REG\_Q\_INT\_ST This is the masked interrupt bit for UHCI\_SEND\_S\_REG\_Q\_INT interrupt when UHCI\_SEND\_S\_REG\_Q\_INT\_ENA is set to 1. (RO)
- UHCI\_SEND\_A\_REG\_Q\_INT\_ST This is the masked interrupt bit for UHCI\_SEND\_A\_REG\_Q\_INT interrupt when UHCI\_SEND\_A\_REG\_Q\_INT\_ENA is set to 1. (RO)
- UHCI\_OUTLINK\_EOF\_ERR\_INT\_ST This is the masked interrupt bit for UHCI\_OUTLINK\_EOF\_ERR\_INT interrupt when UHCI\_OUTLINK\_EOF\_ERR\_INT\_ENA is set to 1. (RO)
- UHCI\_APP\_CTRL0\_INT\_ST This is the masked interrupt bit for UHCI\_APP\_CTRL0\_INT interrupt when UHCI\_APP\_CTRL0\_INT\_ENA is set to 1. (RO)
- UHCI\_APP\_CTRL1\_INT\_ST This is the masked interrupt bit for UHCI\_APP\_CTRL1\_INT interrupt when UHCI\_APP\_CTRL1\_INT\_ENA is set to 1. (RO)

## Register 26.61. UHCI\_INT\_ENA\_REG (0x000C)

![Image](images/26_Chapter_26_img099_77c15f1f.png)

- UHCI\_RX\_START\_INT\_ENA This is the interrupt enable bit for UHCI\_RX\_START\_INT interrupt. (R/W)
- UHCI\_TX\_START\_INT\_ENA This is the interrupt enable bit for UHCI\_TX\_START\_INT interrupt. (R/W)
- UHCI\_RX\_HUNG\_INT\_ENA This is the interrupt enable bit for UHCI\_RX\_HUNG\_INT interrupt. (R/W)
- UHCI\_TX\_HUNG\_INT\_ENA This is the interrupt enable bit for UHCI\_TX\_HUNG\_INT interrupt. (R/W)
- UHCI\_SEND\_S\_REG\_Q\_INT\_ENA This is the interrupt enable bit for UHCI\_SEND\_S\_REG\_Q\_INT interrupt. (R/W)
- UHCI\_SEND\_A\_REG\_Q\_INT\_ENA This is the interrupt enable bit for UHCI\_SEND\_A\_REG\_Q\_INT interrupt. (R/W)
- UHCI\_OUTLINK\_EOF\_ERR\_INT\_ENA This is the interrupt enable bit for UHCI\_OUTLINK\_EOF\_ERR\_INT interrupt. (R/W)
- UHCI\_APP\_CTRL0\_INT\_ENA This is the interrupt enable bit for UHCI\_APP\_CTRL0\_INT interrupt. (R/W)
- UHCI\_APP\_CTRL1\_INT\_ENA This is the interrupt enable bit for UHCI\_APP\_CTRL1\_INT interrupt. (R/W)

Register 26.62. UHCI\_INT\_CLR\_REG (0x0010)

![Image](images/26_Chapter_26_img100_125fc094.png)

UHCI\_RX\_START\_INT\_CLR Set this bit to clear UHCI\_RX\_START\_INT interrupt. (WT)

UHCI\_TX\_START\_INT\_CLR Set this bit to clear UHCI\_TX\_START\_INT interrupt. (WT)

UHCI\_RX\_HUNG\_INT\_CLR Set this bit to clear UHCI\_RX\_HUNG\_INT interrupt. (WT)

UHCI\_TX\_HUNG\_INT\_CLR Set this bit to clear UHCI\_TX\_HUNG\_INT interrupt. (WT)

UHCI\_SEND\_S\_REG\_Q\_INT\_CLR Set this bit to clear UHCI\_SEND\_S\_REG\_Q\_INT interrupt. (WT)

UHCI\_SEND\_A\_REG\_Q\_INT\_CLR Set this bit to clear UHCI\_SEND\_A\_REG\_Q\_INT interrupt. (WT)

UHCI\_OUTLINK\_EOF\_ERR\_INT\_CLR Set this bit to clear UHCI\_OUTLINK\_EOF\_ERR\_INT interrupt. (WT)

UHCI\_APP\_CTRL0\_INT\_CLR Set this bit to clear UHCI\_APP\_CTRL0\_INT interrupt. (WT)

UHCI\_APP\_CTRL1\_INT\_CLR Set this bit to clear UHCI\_APP\_CTRL1\_INT interrupt. (WT)

Register 26.63. UHCI\_STATE0\_REG (0x0018)

![Image](images/26_Chapter_26_img101_f4fe6d07.png)

UHCI\_RX\_ERR\_CAUSE This field indicates the error type when DMA has received a packet with error. 3'b001: Checksum error in the HCI packet; 3'b010: Sequence number error in the HCI packet; 3'b011: CRC bit error in the HCI packet; 3'b100: 0xC0 is found but the received the HCI packet is not end; 3'b101: 0xC0 is not found when the HCI packet has been received; 3'b110: CRC check error. (RO)

UHCI\_DECODE\_STATE UHCI decoder status. (RO)

![Image](images/26_Chapter_26_img102_50d56c5e.png)

## Register 26.64. UHCI\_STATE1\_REG (0x001C)

![Image](images/26_Chapter_26_img103_0df61125.png)
