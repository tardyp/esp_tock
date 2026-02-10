---
chapter: 27
title: "Chapter 27"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 27

## UART Controller (UART, LP\_UART, UHCI)

## 27.1 Overview

In embedded system applications, data is required to be transferred in a simple way with minimal system resources. This can be achieved by a Universal Asynchronous Receiver/Transmitter (UART), which flexibly exchanges data with other peripheral devices in full-duplex mode. ESP32-C6 has three UART controllers, including two regular UARTs and one low-power LP UART. These UARTs are compatible with various UART devices, and support Infrared Data Association (IrDA) and RS485 communication.

Each of the two regular UART controllers has a group of registers that function identically. In this chapter, the two regular UART controllers are referred to as UARTn, in which n denotes 0 or 1. LP UART is the cut-down version of regular UART, with a separate group of registers. For differences between UART and LP UART, please refer to Table 27.2-1 .

A UART is a character-oriented data link for asynchronous communication between devices. Such communication does not add clock signals to the data sent. Therefore, in order to communicate successfully, the transmitter and the receiver must operate at the same baud rate with the same stop bit(s) and a parity bit.

A UART data frame usually begins with one start bit, followed by data bits, one parity bit (optional), and one or more stop bits. UART controllers on ESP32-C6 support various lengths of data bits and stop bits. These controllers also support software and hardware flow control as well as GDMA for high-speed data transfer. This allows developers to use multiple UART ports at minimal software cost.

## 27.2 Features

Table 27.2-1 lists the feature comparison between UART and LP UART:

Table 27.2-1. UART and LP UART Feautre Comparison

| UART Feature                                                                        | LP_UART Feature                                                          |
|-------------------------------------------------------------------------------------|--------------------------------------------------------------------------|
| Programmable baud rate up to 5 MBaud                                                | Programmable baud rate up to 5 MBaud                                     |
| 128 x 8 bit RAM respectively for the TX channel and RX channel of a UART controller | 32 x 8-bit RAM respectively for the TX channel and RX channel of LP_UART |
| Full-duplex asynchronous communication                                              | Full-duplex asynchronous communication                                   |
| Data bits (5 to 8 bits)                                                             | Data bits (5 to 8 bits)                                                  |
| Stop bits (1, 1.5 or 2 bits)                                                        | Stop bits (1, 1.5 or 2 bits)                                             |
| Parity bit                                                                          | Parity bit                                                               |

Cont’d on next page

Table 27.2-1 – cont’d from previous page

| UART Feature                                                          | LP_UART Feature                                             |
|-----------------------------------------------------------------------|-------------------------------------------------------------|
| Special character AT_CMD detection                                    | Special character AT_CMD detection                          |
| RS485 protocol                                                        | —                                                           |
| IrDA protocol                                                         | —                                                           |
| High-speed data communication using GDMA                              | —                                                           |
| Receive timeout                                                       | Receive timeout                                             |
| UART as wake-up source                                                | UART as wake-up source                                      |
| Software and hardware flow control                                    | Software and hardware flow control                          |
| Three prescalable clock sources 1. APB_CLK 2. XTAL_CLK 3. RC_FAST_CLK | Two prescalable clock sources 1. XTAL_D2_CLK 2. LP_FAST_CLK |

The following description mainly covers regular UART controllers.

## 27.3 UART Structure

Figure 27.3-1. UART Structure

![Image](images/27_Chapter_27_img001_281a48bb.png)

Figure 27.3-1 shows the basic structure of a UART controller. A UART controller works in four clock domains, namely APB\_CLK, AHB\_CLK, UART\_SCLK, and UART\_FCLK. APB\_CLK and AHB\_CLK are synchronized but with different frequencies (APB\_CLK is derived from AHB\_CLK by division), and likewise UART\_SCLK and UART\_FCLK are synchronized but with different frequencies (UART\_SCLK is derived from UART\_FCLK by division). UART\_FCLK has three clock sources: an 80 MHz PLL\_F80M\_CLK, RC\_FAST\_CLK, and external

crystal clock XTAL\_CLK (for details, please refer to Chapter 8 Reset and Clock), which are selected by configuring PCR\_UARTn\_SCLK\_SEL. The selected clock source is divided by a divider to generate UART\_SCLK clock signals. The divisor is configured by PCR\_UARTn\_SCLK\_DIV\_NUM for the integral part, PCR\_UARTn\_SCLK\_DIV\_A for the denominator of the fractional part, and PCR\_UARTn\_SCLK\_DIV\_B for the numerator of the fractional part. The divisor ranges from 1 ~ 256. Only regular UART has such a divider; LP UART does not.

A UART controller can be broken down into two parts according to functions: a transmitter and a receiver.

The transmitter contains a TX FIFO (i.e. Tx\_FIFO in Figure 27.3-1), which buffers data to be sent. Software can write data to Tx\_FIFO via the APB bus, or move data to Tx\_FIFO using GDMA. Tx\_FIFO\_Ctrl controls writing and reading Tx\_FIFO. When Tx\_FIFO is not empty, Tx\_FSM reads data bits in the data frame via Tx\_FIFO\_Ctrl, and converts them into a bitstream. The levels of output bitstream signal txd\_out can be inverted by configuring the UART\_TXD\_INV field.

The receiver contains an RX FIFO (i.e. Rx\_FIFO in Figure 27.3-1), which buffers data to be processed. The input bitstream signal rxd\_in is transferred to the UART controller, and its level can be inverted by configuring UART\_RXD\_INV field. Baudrate\_Detect measures the baud rate of input bitstream signal rxd\_in by detecting its minimum pulse width. Start\_Detect detects the start bit in a data frame. If the start bit is detected, Rx\_FSM stores data bits in the data frame into Rx\_FIFO by Rx\_FIFO\_Ctrl. Software can read data from Rx\_FIFO via the APB bus, or receive data using GDMA.

HW\_Flow\_Ctrl controls rxd\_in and txd\_out data flows by standard UART RTS and CTS flow control signals (rtsn\_out and ctsn\_in). SW\_Flow\_Ctrl controls data flows by adding special characters to outgoing data and detecting special characters in incoming data. When a UART controller is Light-sleep mode (see Chapter 12 Low-Power Management for more details), a wake\_up signal can be generated in four ways and sent to RTC, which then wakes up the ESP32-C6 chip. For more information about wakeup, please refer to Section 27.4.8 .

## 27.4 Functional Description

## 27.4.1 Clock and Reset

UART controllers are asynchronous. Their register configuration module works in the APB\_CLK domain. TX FIFO and RX FIFO work across the AHB\_CLK and UART\_FCLK domains. The UART RAM control unit works in the UART\_FCLK domain. The UART transmission and reception control module works in the UART\_SCLK domain, i.e. UART Core's clock domain.

When the frequency of the UART\_SCLK is higher than the frequency needed to generate the baud rate, the UART Core can be clocked at a lower frequency by the divider, in order to reduce power consumption. Usually, the UART Core's clock frequency is lower than the APB\_CLK's frequency, and can be divided by the largest divisor when higher than the frequency needed to generate the baud rate. The frequency of the UART Core's clock can also be at most twice higher than the APB\_CLK. The clock for the UART transmitter and the UART receiver can be controlled independently. To enable the clock for the UART transmitter, UART\_TX\_SCLK\_EN shall be set; to enable the clock for the UART receiver, UART\_RX\_SCLK\_EN shall be set.

To ensure that the configured register values are synchronized from APB\_CLK domain to the UART Core's clock domain, please follow the procedures in Section27.5 .

To reset the whole UART, please:

- Enable the UART Core's clock by setting PCR\_UARTnn\_CLK\_EN to 1.
- Write 1 to PCR\_UARTn\_RST\_EN .
- Clear PCR\_UARTn\_RST\_EN to 0.

## 27.4.2 UART FIFO

The transmitter and the receiver on the UART controller each use a 128 x 8-bit RAM, and access their respective RAM through a separate 4 x 8-bit asynchronous FIFO interface. The RAM and asynchronous FIFO interface for the transmitter and the receiver are independent and cannot be shared.

UART0 Tx\_FIFO and UART1 Tx\_FIFO are reset by setting UART\_TXFIFO\_RST. UART0 Rx\_FIFO and UART1 Rx\_FIFO are reset by setting UART\_RXFIFO\_RST .

Data to be sent is written to TX FIFO via the APB bus or using GDMA, read automatically, and converted from a frame into a bitstream by hardware Tx\_FSM. Data received is converted from a bitstream into a frame by hardware Rx\_FSM, written into RX FIFO, and then stored into RAM via the APB bus or using GDMA. The two UART controllers share one GDMA channel.

The empty signal threshold for Tx\_FIFO is configured by setting UART\_TXFIFO\_EMPTY\_THRHD. When data stored in Tx\_FIFO is less than UART\_TXFIFO\_EMPTY\_THRHD, a UART\_TXFIFO\_EMPTY\_INT interrupt is generated. The full signal threshold for Rx\_FIFO is configured by setting UART\_RXFIFO\_FULL\_THRHD. When data stored in Rx\_FIFO is greater than or equal to UART\_RXFIFO\_FULL\_THRHD, a UART\_RXFIFO\_FULL\_INT interrupt is generated. In addition, when Rx\_FIFO receives more data than its capacity, a UART\_RXFIFO\_OVF\_INT interrupt is generated.

UARTn can access FIFO via register UART\_FIFO\_REG. Writing to UART\_RXFIFO\_RD\_BYTE stores the data into the TX FIFO. As UART\_RXFIFO\_RD\_BYTE is a read-only register field, the hardware does not actually perform a write operation on UART\_RXFIFO\_RD\_BYTE; instead, upon detecting a write request to this field's address, it passes the corresponding write data to the TX FIFO via a separate bypass. Reading UART\_RXFIFO\_RD\_BYTE retrieves the data from the RX FIFO.

## 27.4.3 Baud Rate Generation and Detection

## 27.4.3.1 Baud Rate Generation

Before a UART controller sends or receives data, the baud rate should be configured by setting corresponding registers. The baud rate generator of a UART controller functions by dividing the input clock source. It can divide the clock source by a fractional amount. The divisor is configured by UART\_CLKDIV\_SYNC\_REG: UART\_CLKDIV for the integral part, and UART\_CLKDIV\_FRAG for the fractional part. When using the 80 MHz input clock, the UART controller supports a maximum baud rate of 5 Mbaud.

The divisor of the baud rate divider is equal to

<!-- formula-not-decoded -->

meaning that the final baud rate is equal to

<!-- formula-not-decoded -->

where INPUT\_FREQ is the frequency of UART Core's source clock. For example, if UART\_CLKDIV = 694 and UART\_CLKDIV\_FRAG = 7, then the divisor value is

<!-- formula-not-decoded -->

When UART\_CLKDIV\_FRAG is 0, the baud rate generator is an integer clock divider where an output pulse is generated every UART\_CLKDIV input pulses.

When UART\_CLKDIV\_FRAG is not 0, the divider is fractional and the output baud rate clock pulses are not strictly uniform. As shown in Figure 27.4-1, for every 16 output pulses, the generator divides either (UART\_CLKDIV + 1) input pulses or UART\_CLKDIV input pulses per output pulse. A total of UART\_CLKDIV\_FRAG output pulses are generated by dividing (UART\_CLKDIV + 1) input pulses, and the remaining (16 -UART\_CLKDIV\_FRAG) output pulses are generated by dividing UART\_CLKDIV input pulses.

The output pulses are interleaved as shown in Figure 27.4-1 below, to make the output timing more uniform:

Figure 27.4-1. UART Controllers Division

![Image](images/27_Chapter_27_img002_f0f71758.png)

To support IrDA (see Section 27.4.7 for details), the fractional clock divider for IrDA data transmission generates clock signals divided by 16 × UART\_CLKDIV\_SYNC\_REG. This divider works similarly as the one elaborated above: it takes UART\_CLKDIV/16 as the integer value and the lowest four bits of UART\_CLKDIV as the fractional value.

## 27.4.3.2 Baud Rate Detection

Automatic baud rate detection (Autobaud) on UARTs is enabled by setting UART\_AUTOBAUD\_EN. The Baudrate\_Detect module shown in Figure 27.3-1 filters any noise whose pulse width is shorter than UART\_GLITCH\_FILT .

Before communication starts, the transmitter could send random data to the receiver for baud rate detection. UART\_LOWPULSE\_MIN\_CNT stores the minimum low pulse width, UART\_HIGHPULSE\_MIN\_CNT stores the minimum high pulse width, UART\_POSEDGE\_MIN\_CNT stores the minimum pulse width between two rising edges, and UART\_NEGEDGE\_MIN\_CNT stores the minimum pulse width between two falling edges. These four fields are read by software to determine the transmitter's baud rate.

Figure 27.4-2. The Timing Diagram of Weak UART Signals Along Falling Edges

![Image](images/27_Chapter_27_img003_6dfd067e.png)

The baud rate can be determined in the following three ways:

1. Normally, to avoid sampling erroneous data along rising or falling edges in a metastable state, which results in the inaccuracy of UART\_LOWPULSE\_MIN\_CNT or UART\_HIGHPULSE\_MIN\_CNT, use a weighted average of these two values to eliminate errors for 1-bit pulses. In this case, the baud rate is calculated as follows:

<!-- formula-not-decoded -->

2. If UART signals are weak along falling edges as shown in Figure 27.4-2, which leads to an inaccurate average of UART\_LOWPULSE\_MIN\_CNT and UART\_HIGHPULSE\_MIN\_CNT, use UART\_POSEDGE\_MIN\_CNT to determine the transmitter's baud rate as follows:

<!-- formula-not-decoded -->

3. If UART signals are weak along rising edges, use UART\_NEGEDGE\_MIN\_CNT to determine the transmitter's baud rate as follows:

<!-- formula-not-decoded -->

![Image](images/27_Chapter_27_img004_72a31ee3.png)

## 27.4.4 UART Data Frame

Figure 27.4-3. Structure of UART Data Frame

![Image](images/27_Chapter_27_img005_2cdad9c1.png)

Figure 27.4-3 shows the basic structure of a data frame. A frame starts with one start bit, and ends with stop bits which can be 1, 1.5 or 2 bits long, configured by UART\_STOP\_BIT\_NUM (in RS485 mode turnaround delay may be added. See details in Section 27.4.6.2). The start bit is logical low, whereas stop bits are logical high.

The actual data length can be anywhere between 5 ~ 8 bit, configured by UART\_BIT\_NUM. When UART\_PARITY\_EN is set, a parity bit is added after data bits. UART\_PARITY is used to choose even parity or odd parity. When the receiver detects a parity bit error in the data received, a UART\_PARITY\_ERR\_INT interrupt is generated, and the data received will still be stored into RX FIFO. When the receiver detects a data frame error, a UART\_FRM\_ERR\_INT interrupt is generated, and the data received by default is stored into RX FIFO.

If all data in Tx\_FIFO has been sent, a UART\_TX\_DONE\_INT interrupt is generated. After this, if the UART\_TXD\_BRK bit is set, then the transmitter will enter the Break condition and send several NULL characters in which the TX data line is logical low. The number of NULL characters is configured by UART\_TX\_BRK\_NUM . Once the transmitter has sent all NULL characters, a UART\_TX\_BRK\_DONE\_INT interrupt is generated. The minimum interval between data frames can be configured using UART\_TX\_IDLE\_NUM. If the transmitter stays idle for UART\_TX\_IDLE\_NUM or more time, a UART\_TX\_BRK\_IDLE\_DONE\_INT interrupt is generated.

The receiver can also detect the Break conditions when the RX data line remains logical low for one NULL character transmission, and a UART\_BRK\_DET\_INT interrupt will be triggered to detect that a Break condition has been completed.

The receiver can detect the current bus state through the timeout interrupt UART\_RXFIFO\_TOUT\_INT. The UART\_RXFIFO\_TOUT\_INT interrupt will be triggered when the bus is in the idle state for more than UART\_RX\_TOUT\_THRHD bit time on current baud rate after the receiver has received at least one byte. You can use this interrupt to detect whether all the data from the transmitter has been sent.

## 27.4.5 AT\_CMD Character Structure

![Image](images/27_Chapter_27_img006_2a7cacb0.png)

Figure 27.4-4. AT\_CMD Character Structure

![Image](images/27_Chapter_27_img007_4f11961f.png)

Figure 27.4-4 is the structure of a special character AT\_CMD. If the receiver constantly receives AT\_CMD\_CHAR and the following conditions are met, a UART\_AT\_CMD\_CHAR\_DET\_INT interrupt is generated.

- The interval between the first AT\_CMD\_CHAR and the last non-AT\_CMD\_CHAR character is at least UART \_PRE\_IDLE\_NUM cycles.
- The interval between two AT\_CMD\_CHAR characters is less than UART\_RX\_GAP\_TOUT in the unit of baud rate cycles.
- The number of AT\_CMD\_CHAR characters is equal to or greater than UART\_CHAR\_NUM .
- The interval between the last AT\_CMD\_CHAR character and next non-AT\_CMD\_CHAR character is at least UART\_POST\_IDLE\_NUM cycles.

Note: Given that the interval between AT\_CMD\_CHAR characters is less than UART\_RX\_GAP\_TOUT in the unit of baud rate cycles, the APB\_CLK frequency is suggested not to be lower than 8 MHz.

## 27.4.6 RS485

The two regular UART controllers support RS485 communication mode. In this mode differential signals are used to transmit data, so it can communicate over longer distances at higher bit rates than RS232. RS485 has two-wire half-duplex and four-wire full-duplex options. UART controllers support two-wire half-duplex transmission and bus snooping.

## 27.4.6.1 Driver Control

As shown in Figure 27.4-5, in a two-wire multidrop network, an external RS485 transceiver is needed for differential to single-ended conversion or the other way around. An RS485 transceiver contains a driver and a receiver. When a UART controller is not in transmitter mode, the connection to the differential line can be broken by disabling the driver. When DE is 1, the driver is enabled; when DE is 0, the driver is disabled.

The UART receiver converts differential signals to single-ended signals via an external receiver. RE is the enable control signal for the receiver. When RE is 0, the receiver is enabled; when RE is 1, the receiver is disabled. If RE is configured as 0, the UART controller is allowed to snoop data on the bus, including the data sent by itself.

DE can be controlled by either software or hardware. To reduce the cost of software, in our design DE is controlled by hardware. As shown in Figure 27.4-5, DE is connected to dtrn\_out of UART (please refer to Section 27.4.9.1 for more details).

Figure 27.4-5. Driver Control Diagram in RS485 Mode

![Image](images/27_Chapter_27_img008_5a69027b.png)

## 27.4.6.2 Turnaround Delay

By default, the two UART controllers work in receiver mode. When a UART controller is switched from transmitter mode to receiver mode, the RS485 protocol requires a turnaround delay of one cycle after the stop bit. The UART transmitter supports adding a turnaround delay of one cycle before the start bit or after the stop bit. When UART\_DL0\_EN is set, a turnaround delay of one cycle is added before the start bit; when UART\_DL1\_EN is set, a turnaround delay of one cycle is added after the stop bit.

## 27.4.6.3 Bus Snooping

In a two-wire multidrop network, UART controllers support bus snooping if RE of the external RS485 transceiver is 0. By default, a UART controller is not allowed to transmit and receive data simultaneously. If UART\_RS485TX\_RX\_EN is set and the external RS485 transceiver is configured as in Figure 27.4-5, a UART controller may receive data in transmitter mode and snoop the bus. If UART\_RS485RXBY\_TX\_EN is set, a UART controller may transmit data in receiver mode.

The two UART controllers can snoop the data sent by themselves. In transmitter mode, when a UART controller monitors a collision between the data sent and the data received, a UART\_RS485\_CLASH\_INT is generated; when a UART controller monitors a data frame error, a UART\_RS485\_FRM\_ERR\_INT interrupt is generated; when a UART controller monitors a polarity error, a UART\_RS485\_PARITY\_ERR\_INT is generated.

## 27.4.7 IrDA

IrDA protocol consists of three layers, namely the physical layer, the link access protocol, and the link management protocol. The two UART controllers implement IrDA's physical layer. In IrDA encoding, a UART controller supports data rates up to 115.2 kbit/s (SIR, or serial infrared mode). As shown in Figure 27.4-6, the IrDA encoder converts a non-return to zero code (NRZ) signal to a return to zero inverted code (RZI) signal and sends it to the external driver and infrared LED. This encoder uses modulated signals whose pulse width is 3/16 bits to indicate logic "0", and low levels to indicate logic "1". The IrDA decoder receives signals from the infrared receiver and converts them to NRZ signals. In most cases, the receiver is high when it is idle, and the encoder output polarity is the opposite of the decoder input polarity. If a low pulse is detected, it indicates that a start bit has been received.

When IrDA function is enabled, one bit is divided into 16 clock cycles. If the bit to be sent is zero, then the 9th, 10th, and 11th clock cycle are high.

Figure 27.4-6. The Timing Diagram of Encoding and Decoding in SIR mode

![Image](images/27_Chapter_27_img009_0ae29904.png)

The IrDA transceiver is half-duplex, meaning that it cannot send and receive data simultaneously. As shown in Figure 27.4-7, IrDA function is enabled by setting UART\_IRDA\_EN. When UART\_IRDA\_TX\_EN is set to 1, the IrDA transceiver is enabled to send data and not allowed to receive data; when UART\_IRDA\_TX\_EN is reset to 0, the IrDA transceiver is enabled to receive data and not allowed to send data.

Figure 27.4-7. IrDA Encoding and Decoding Diagram

![Image](images/27_Chapter_27_img010_166a2557.png)

## 27.4.8 Wake-up

UART can be set as wake-up source. When a UART controller is in Light-sleep mode, a wake\_up signal can be generated in four ways and be sent to the RTC module, which then wakes up ESP32-C6.

- UART\_WK\_MODE\_SEL = 0: When all the clocks are disabled, the chip can be woken up by reverting RXD for multiple cycles until the number of rising edges is equal to or greater than (UART\_ACTIVE\_THRESHOLD + 3).
- UART\_WK\_MODE\_SEL = 1: UART Core keeps working, so the UART receiver can still receive data and store the received data in RX FIFO. When the number of data bytes in RX FIFO is greater than UART\_RX\_WAKE\_UP\_THRHD, the chip can be woken up from the Light-sleep mode.
- UART\_WK\_MODE\_SEL = 2: When the UART receiver detects a start bit, the chip will be woken up.

- UART\_WK\_MODE\_SEL = 3: When the UART receiver receives a specific character sequence, the chip will be woken up. The wakeup characters can be defined by configuring UART\_WK\_CHAR0 , UART\_WK\_CHAR1 , UART\_WK\_CHAR2 , UART\_WK\_CHAR3, and UART\_WK\_CHAR4. These four characters can be formed into different character sequences by configuring UART\_CHAR\_NUM and UART\_WK\_CHAR\_MASK, as shown in Table 27.4-1. Once the sequence is detected, the chip will be woken up. For the last configuration in Table 27.4-1, UART will detects for CHAR0 ~ CHAR4 in order.

Table 27.4-1. UART\_CHAR\_WAKEUP Mode Configuration

|   UART_CHAR_NAME | UART_WP_CHAR_MASK   | Character Sequence            |
|------------------|---------------------|-------------------------------|
|                1 | 0xF                 | CHAR4                         |
|                2 | 0x7                 | CHAR3/CHAR4                   |
|                3 | 0x3                 | CHAR2/CHAR3/CHAR4             |
|                4 | 0x1                 | CHAR1/CHAR2/CHAR3/CHAR4       |
|                5 | 0x0                 | CHAR0/CHAR1/CHAR2/CHAR3/CHAR4 |

After the chip is woken up by UART, it is necessary to clear the wake\_up signal by transmitting data to UART in Active mode or resetting the whole UART, otherwise the number of rising edges required for the next wakeup will be reduced.

## 27.4.9 Flow Control

UART controllers have two ways to control data flow, namely hardware flow control and software flow control. Hardware flow control is achieved using output signal rtsn\_out and input signal ctsn\_in. Software flow control is achieved by inserting special characters in the data flow sent and detecting special characters in the data flow received.

## 27.4.9.1 Hardware Flow Control

Figure 27.4-8. Hardware Flow Control Diagram

![Image](images/27_Chapter_27_img011_6dc86659.png)

Figure 27.4-8 shows the hardware flow control of a UART controller. Hardware flow control uses output signal rtsn\_out and input signal dsrn\_in. Figure 27.4-9 illustrates how these signals are connected between UART on ESP32-C6 (hereinafter referred to as IU0) and the external UART (hereinafter referred to as EU0).

When rtsn\_out of IU0 is low, EU0 is allowed to send data. When rtsn\_out of IU0 is high, EU0 is notified to stop sending data until rtsn\_out of IU0 returns to low. The output signal rtsn\_out can be controlled in two ways.

- Software control: Enter this mode by clearing UART\_RX\_FLOW\_EN to 0. In this mode, the level of rtsn\_out is changed by configuring UART\_SW\_RTS .
- Hardware control: Enter this mode by setting UART\_RX\_FLOW\_EN to 1. In this mode, rtsn\_out is pulled high when data in Rx\_FIFO exceeds UART\_RX\_FLOW\_THRHD .

![Image](images/27_Chapter_27_img012_114f5027.png)

Figure 27.4-9. Connection between Hardware Flow Control Signals

![Image](images/27_Chapter_27_img013_772f46a0.png)

When ctsn\_in of IU0 is low, IU0 is allowed to send data; when ctsn\_in is high, IU0 is not allowed to send data. When IU0 detects an edge change of ctsn\_in, a UART\_CTS\_CHG\_INT interrupt is generated.

If dtrn\_out of IU0 is high, it indicates that IU0 is ready to transmit data. dtrn\_out is generated by configuring the UART\_SW\_DTR field. When the IU0 transmitter detects an edge change of dsrn\_in, a UART\_DSR\_CHG\_INT interrupt is generated. After this interrupt is detected, software can obtain the level of input signal dsrn\_in by reading UART\_DSRN. If dsrn\_in is high, it indicates that EU0 is ready to transmit data.

In a two-wire RS485 multidrop network enabled by setting UART\_RS485\_EN, dtrn\_out is generated by hardware and used for transmit/receive turnaround. When data transmission starts, dtrn\_out is pulled high and the external driver is enabled; when data transmission completes, dtrn\_out is pulled low and the external driver is disabled. Please note that when there is a turnaround delay of one cycle added after the stop bit, dtrn\_out is pulled low after the delay.

UART loopback test is enabled by setting UART\_LOOPBACK. In the test, UART output signal txd\_out is connected to its input signal rxd\_in, rtsn\_out is connected to ctsn\_in, and dtrn\_out is connected to dsrn\_out. If the data sent matches the data received, it indicates that UART controllers are working properly.

## 27.4.9.2 Software Flow Control

Instead of CTS/RTS lines, software flow control uses XON/XOFF characters to start or stop data transmission. Such flow control is enabled by setting UART\_SW\_FLOW\_CON\_EN to 1.

When using software flow control, hardware automatically detects if there are XON/XOFF characters in the data flow received, and generate a UART\_SW\_XOFF\_INT or a UART\_SW\_XON\_INT interrupt accordingly. If an XOFF character is detected, the transmitter stops data transmission once the current byte has been transmitted; if an XON character is detected, the transmitter starts data transmission. In addition, software can force the transmitter to stop sending data by setting UART\_FORCE\_XOFF, or to start sending data by setting UART\_FORCE\_XON .

Software determines whether to insert flow control characters according to the remaining room in RX FIFO. When UART\_SEND\_XOFF is set, the transmitter sends an XOFF character configured by UART\_XOFF\_CHAR after the current byte in transmission; when UART\_SEND\_XON is set, the transmitter sends an XON character configured by UART\_XON\_CHAR after the current byte in transmission. If the RX FIFO of a UART controller stores more data than UART\_XOFF\_THRESHOLD , UART\_SEND\_XOFF is set by hardware. As a result, the

transmitter sends an XOFF character configured by UART\_XOFF\_CHAR after the current byte in transmission. If the RX FIFO of a UART controller stores less data than UART\_XON\_THRESHOLD , UART\_SEND\_XON is set by hardware. As a result, the transmitter sends an XON character configured by UART\_XON\_CHAR after the current byte in transmission.

In full-duplex mode, when the UART receiver receives an XOFF character, the UART transmitter is not allowed to send any data including XOFF even if the UART receiver receives more data than its threshold. To avoid deadlocks in software flow control or overflow caused thereby, you can set UART\_\_XON\_XOFF\_STILL\_SEND. In this way, the UART transmitter can still send an XOFF character when it is not allowed to send any data.

## 27.4.10 GDMA Mode

The two UART controllers on ESP32-C6 share one TX/RX GDMA (general direct memory access) channel via UHCI. In GDMA mode, UART controllers support the decoding and encoding of HCI data packets. The UHCI\_UARTn\_CE field determines which UART controller occupies the GDMA TX/RX channel.

Figure 27.4-10. Data Transfer in GDMA Mode

![Image](images/27_Chapter_27_img014_607ad3f4.png)

Figure 27.4-10 shows how data is transferred using GDMA. Before GDMA receives data, software prepares an inlink. GDMA\_INLINK\_ADDR\_CHn points to the first receive descriptor in the inlink. After GDMA\_INLINK\_START\_CHn is set, UHCI sends data that UART has received to the decoder. The decoded data is then stored into the RAM pointed by the inlink under the control of GDMA.

Before GDMA sends data, software prepares an outlink and data to be sent. GDMA\_OUTLINK\_ADDR\_CHn points to the first transmit descriptor in the outlink. After GDMA\_OUTLINK\_START\_CHn is set, GDMA reads data from the RAM pointed by outlink. The data is then encoded by the encoder, and sent sequentially by the UART transmitter.

HCI data packets have separators at the beginning and the end, with data bits in the middle (separators + data bits + separators). The encoder inserts separators in front of and after data bits, and replaces data bits identical to separators with special characters. The decoder removes separators in front of and after data bits, and replaces special characters with separators. There can be more than one continuous separator at the beginning and the end of a data packet. The separator is configured by UHCI\_SEPER\_CHAR, 0xC0 by default. The special character is configured by UHCI\_ESC\_SEQ0\_CHAR0 (0xDB by default) and

UHCI\_ESC\_SEQ0\_CHAR1 (0xDD by default). When all data has been sent, a GDMA\_OUT\_TOTAL\_EOF\_CHn\_INT interrupt is generated. When all data has been received, a GDMA\_IN\_SUC\_EOF\_CHn\_INT is generated.

## 27.4.11 UART Interrupts

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
- UART\_RXFIFO\_TOUT\_INT: Triggered when the receiver has received at least one byte, and the bus remains idle for UART\_RX\_TOUT\_THRHD .
- UART\_BRK\_DET\_INT: Triggered when the receiver detects a NULL character (i.e. logic 0 for one NULL character transmission) after stop bits.
- UART\_CTS\_CHG\_INT: Triggered when the receiver detects an edge change of CTSn signals.
- UART\_DSR\_CHG\_INT: Triggered when the receiver detects an edge change of DSRn signals.
- UART\_RXFIFO\_OVF\_INT: Triggered when the amount of data received by the receiver exceeds the storage capacity of the FIFO.
- UART\_FRM\_ERR\_INT: Triggered when the receiver detects a data frame error.
- UART\_PARITY\_ERR\_INT: Triggered when the receiver detects a parity error.
- UART\_TXFIFO\_EMPTY\_INT: Triggered when TX FIFO stores less data than what UART\_TXFIFO\_EMPTY\_THRHD specifies.
- UART\_RXFIFO\_FULL\_INT: Triggered when the receiver receives more data than what UART\_RXFIFO\_FULL\_THRHD specifies.
- UART\_WAKEUP\_INT: Triggered when UART is woken up.

## 27.4.12 UHCI Interrupts

- UHCI\_APP\_CTRL1\_INT: Triggered when software sets UHCI\_APP\_CTRL1\_INT\_RAW .
- UHCI\_APP\_CTRL0\_INT: Triggered when software sets UHCI\_APP\_CTRL0\_INT\_RAW .

- UHCI\_OUTLINK\_EOF\_ERR\_INT: Triggered when an EOF error is detected in a transmit descriptor.
- UHCI\_SEND\_A\_REG\_Q\_INT: Triggered when UHCI has sent a series of short packets using always\_send.
- UHCI\_SEND\_S\_REG\_Q\_INT: Triggered when UHCI has sent a series of short packets using single\_send.
- UHCI\_TX\_HUNG\_INT: Triggered when UHCI takes too long to read RAM using a GDMA transmit channel.
- UHCI\_RX\_HUNG\_INT: Triggered when UHCI takes too long to receive data using a GDMA receive channel.
- UHCI\_TX\_START\_INT: Triggered when GDMA detects a separator character.
- UHCI\_RX\_START\_INT: Triggered when a separator character has been sent.

## 27.5 Programming Procedures

## 27.5.1 Register Type

All UART registers are in the APB\_CLK domain.

UART configuration registers can be classified into two groups. One group of registers are read in APB\_CLK or AHB\_CLK domains, so once such registers are configured no extra operations are required. The other group of registers are read in the UART Core's clock domain, and therefore need to implement the clock domain crossing design. Once these registers are configured, the configured values need to be synchronized to the UART Core's clock domain by writing to UART\_REG\_UPDATE. Once all values have been synchronized, UART\_REG\_UPDATE will be automatically cleared by hardware. After configuring registers that need synchronization, it is recommended to check whether UART\_REG\_UPDATE is 0. This is to ensure that register values configured before have already been synchronized.

To distinguish between these two groups of registers easily, all registers that implement the clock domain crossing design have the \_SYNC suffix, and are put together in Section 27.6. Those without the \_SYNC suffix in Section 27.6 are configuration registers that require no clock domain crossing.

## 27.5.2 Detailed Steps

Figure 27.5-1 illustrates the process to program UART controllers, namely initialize UART, configure registers, enable the UART transmitter or receiver, and finish data transmission.

Figure 27.5-1. UART Programming Procedures

![Image](images/27_Chapter_27_img015_f1287cc3.png)

## 27.5.2.1 Initializing UARTn

To initialize UARTn:

- Write 1 to PCR\_UARTn\_RST\_EN .
- Clear PCR\_UARTn\_RST\_EN .

## 27.5.2.2 Configuring UARTn Communication

To configure UARTn communication:

- Wait for UART\_REG\_UPDATE to become 0, which indicates the completion of the last synchronization.
- Select the clock source via PCR\_UARTn\_SCLK\_SEL .
- Configure divisor of the divider via PCR\_UARTn\_SCLK\_DIV\_NUM , PCR\_UARTn\_SCLK\_DIV\_A, and PCR\_UARTn\_SCLK\_DIV\_B .
- Configure the baud rate for transmission via UART\_CLKDIV and UART\_CLKDIV\_FRAG .
- Configure data length via UART\_BIT\_NUM .
- Configure odd or even parity check via UART\_PARITY\_EN and UART\_PARITY .
- Optional steps depending on application ...
- Synchronize the configured values to the Core Clock domain by writing 1 to UART\_REG\_UPDATE .

## 27.5.2.3 Enabling UARTn

To enable UARTn transmitter:

- Configure TX FIFO's empty threshold via UART\_TXFIFO\_EMPTY\_THRHD .
- Disable UART\_TXFIFO\_EMPTY\_INT interrupt by clearing UART\_TXFIFO\_EMPTY\_INT\_ENA .
- Write data to be sent to UART\_RXFIFO\_RD\_BYTE .
- Clear UART\_TXFIFO\_EMPTY\_INT interrupt by setting UART\_TXFIFO\_EMPTY\_INT\_CLR .
- Enable UART\_TXFIFO\_EMPTY\_INT interrupt by setting UART\_TXFIFO\_EMPTY\_INT\_ENA .
- Check UART\_TXFIFO\_EMPTY\_INT\_ST and wait for the completion of data transmission.

To enable UARTn receiver:

- Configure RX FIFO's full threshold via UART\_RXFIFO\_FULL\_THRHD .
- Enable UART\_RXFIFO\_FULL\_INT interrupt by setting UART\_RXFIFO\_FULL\_INT\_ENA .
- Check UART\_RXFIFO\_FULL\_INT\_ST and wait until the RX FIFO is full.
- Read data from RX FIFO via UART\_RXFIFO\_RD\_BYTE, and obtain the number of bytes received in RX FIFO via UART\_RXFIFO\_CNT .

## 27.6 Register Summary

## 27.6.1 UART Register Summary

The addresses in this section are relative to UART Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

R/WTC/SS

| Name                                       | Description                                   | Address   | Access   |
|--------------------------------------------|-----------------------------------------------|-----------|----------|
| FIFO Configuration                         |                                               |           |          |
| UART_FIFO_REG                              | FIFO data register                            | 0x0000    | RO       |
| UART_TOUT_CONF_SYNC_REG                    | UART threshold and allocation configuration   | 0x0064    | R/W      |
| UART Interrupt Register                    |                                               |           |          |
| UART_INT_RAW_REG                           | Raw interrupt status                          | 0x0004    |          |
| UART_INT_ST_REG                            | Masked interrupt status                       | 0x0008    | RO       |
| UART_INT_ENA_REG                           | Interrupt enable bits                         | 0x000C    | R/W      |
| UART_INT_CLR_REG                           | Interrupt clear bits                          | 0x0010    | WT       |
| Configuration Register                     |                                               |           |          |
| UART_CLKDIV_SYNC_REG                       | Clock divider configuration                   | 0x0014    | R/W      |
| UART_RX_FILT_REG                           | RX filter configuration                       | 0x0018    | R/W      |
| UART_CONF0_SYNC_REG                        | Configuration register 0                      | 0x0020    | R/W      |
| UART_CONF1_REG                             | Configuration register 1                      | 0x0024    | R/W      |
| UART_HWFC_CONF_SYNC_REG                    | Hardware flow control configuration           | 0x002C    | R/W      |
| UART_SLEEP_CONF0_REG                       | UART sleep configuration register 0           | 0x0030    | R/W      |
| UART_SLEEP_CONF1_REG                       | UART sleep configuration register 1           | 0x0034    | R/W      |
| UART_SLEEP_CONF2_REG                       | UART sleep configuration register 2           | 0x0038    | R/W      |
| UART_SWFC_CONF0_SYNC_REG                   | Software flow control character configuration | 0x003C    | varies   |
| UART_SWFC_CONF1_REG                        | Software flow control character configuration | 0x0040    | R/W      |
| UART_TXBRK_CONF_SYNC_REG                   | TX break character configuration              | 0x0044    | R/W      |
| UART_IDLE_CONF_SYNC_REG                    | Frame end idle time configuration             | 0x0048    | R/W      |
| UART_RS485_CONF_SYNC_REG                   | RS485 mode configuration                      | 0x004C    | R/W      |
| UART_CLK_CONF_REG                          | UART core clock configuration                 | 0x0088    | R/W      |
| UART_REG_UPDATE_REG                        | UART register configuration update            | 0x0098    | R/W/SC   |
| UART_ID_REG                                | UART ID register                              | 0x009C    | R/W      |
| Status Register                            |                                               |           |          |
| UART_STATUS_REG                            | UART status register                          | 0x001C    | RO       |
| UART_MEM_TX_STATUS_REG                     | TX FIFO write and read offset address         | 0x0068    | RO       |
| UART_MEM_RX_STATUS_REG                     | Rx FIFO write and read offset address         | 0x006C    | RO       |
| UART_FSM_STATUS_REG                        | UART transmit and receive status              | 0x0070    | RO       |
| UART_AFIFO_STATUS_REG                      | UART asynchronous FIFO status                 | 0x0090    | RO       |
| AT Escape Sequence Selection Configuration |                                               |           |          |
| UART_AT_CMD_PRECNT_SYNC_REG                | Pre-sequence timing configuration             | 0x0050    | R/W      |
| UART_AT_CMD_POSTCNT_SYNC_REG               | Post-sequence timing configuration            | 0x0054    | R/W      |
| UART_AT_CMD_GAPTOUT_SYNC_REG               | Timeout configuration                         | 0x0058    | R/W      |

| Name                      | Description                                   | Address   | Access   |
|---------------------------|-----------------------------------------------|-----------|----------|
| UART_AT_CMD_CHAR_SYNC_REG | AT escape sequence detection configuration    | 0x005C    | R/W      |
| Autobaud Register         |                                               |           |          |
| UART_POSPULSE_REG         | Autobaud high pulse register                  | 0x0074    | RO       |
| UART_NEGPULSE_REG         | Autobaud low pulse register                   | 0x0078    | RO       |
| UART_LOWPULSE_REG         | Autobaud minimum low pulse duration register  | 0x007C    | RO       |
| UART_HIGHPULSE_REG        | Autobaud minimum high pulse duration register | 0x0080    | RO       |
| UART_RXD_CNT_REG          | Autobaud edge change count register           | 0x0084    | RO       |
| Version Register          |                                               |           |          |
| UART_DATE_REG             | UART version control register                 | 0x008C    | R/W      |

## 27.6.2 LP UART Register Summary

The addresses in this section are relative to LP UART base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

R/WTC/SS

| Name                        | Description                                    | Address   | Access   |
|-----------------------------|------------------------------------------------|-----------|----------|
| FIFO Configuration          |                                                |           |          |
| LP_UART_FIFO_REG            | FIFO data register                             | 0x0000    | RO       |
| LP_UART_TOUT_CONF_SYNC_REG  | LP UART threshold and allocation configuration | 0x0064    | R/W      |
| LP UART Interrupt Register  |                                                |           |          |
| LP_UART_INT_RAW_REG         | Raw interrupt status                           | 0x0004    |          |
| LP_UART_INT_ST_REG          | Masked interrupt status                        | 0x0008    | RO       |
| LP_UART_INT_ENA_REG         | Interrupt enable bits                          | 0x000C    | R/W      |
| LP_UART_INT_CLR_REG         | Interrupt clear bits                           | 0x0010    | WT       |
| Configuration Register      |                                                |           |          |
| LP_UART_CLKDIV_SYNC_REG     | Clock divider configuration                    | 0x0014    | R/W      |
| LP_UART_RX_FILT_REG         | RX filter configuration                        | 0x0018    | R/W      |
| LP_UART_CONF0_SYNC_REG      | Configuration register 0                       | 0x0020    | R/W      |
| LP_UART_CONF1_REG           | Configuration register 1                       | 0x0024    | R/W      |
| LP_UART_HWFC_CONF_SYNC_REG  | Hardware flow control configuration            | 0x002C    | R/W      |
| LP_UART_SLEEP_CONF0_REG     | LP UART sleep configuration register 0         | 0x0030    | R/W      |
| LP_UART_SLEEP_CONF1_REG     | LP UART sleep configuration register 1         | 0x0034    | R/W      |
| LP_UART_SLEEP_CONF2_REG     | LP UART sleep configuration register 2         | 0x0038    | R/W      |
| LP_UART_SWFC_CONF0_SYNC_REG | Software flow control character configuration  | 0x003C    | varies   |
| LP_UART_SWFC_CONF1_REG      | Software flow control character configuration  | 0x0040    | R/W      |
| LP_UART_TXBRK_CONF_SYNC_REG | TX break character configuration               | 0x0044    | R/W      |
| LP_UART_IDLE_CONF_SYNC_REG  | Frame end idle time configuration              | 0x0048    | R/W      |
| LP_UART_DELAY_CONF_SYNC_REG | Delay bit configuration                        | 0x004C    | R/W      |
| LP_UART_CLK_CONF_REG        | LP UART core clock configuration               | 0x0088    | R/W      |
| LP_UART_REG_UPDATE_REG      | LP UART register configuration update register | 0x0098    | R/W/SC   |
| LP_UART_ID_REG              | LP UART ID register                            | 0x009C    | R/W      |

| Name                                                               | Description                                | Address                                    | Access                                     |
|--------------------------------------------------------------------|--------------------------------------------|--------------------------------------------|--------------------------------------------|
| LP_UART_STATUS_REG                                                 | LP UART status register                    | 0x001C                                     | RO                                         |
| LP_UART_MEM_TX_STATUS_REG                                          | TX FIFO write and read offset address      | 0x0068                                     | RO                                         |
| LP_UART_MEM_RX_STATUS_REG                                          | RX FIFO write and read offset address      | 0x006C                                     | RO                                         |
| LP_UART_FSM_STATUS_REG                                             | LP UART transmit and receive status        | 0x0070                                     | RO                                         |
| LP_UART_AFIFO_STATUS_REG                                           | LP UART asynchronous FIFO Status           | 0x0090                                     | RO                                         |
| AT Escape Sequence Selection Configuration                         | AT Escape Sequence Selection Configuration | AT Escape Sequence Selection Configuration | AT Escape Sequence Selection Configuration |
| LP_UART_AT_CMD_PRECNT_SYNC_REG                                     | Pre-sequence timing configuration          | 0x0050                                     | R/W                                        |
| LP_UART_AT_CMD_POSTCNT_SYNC_REG Post-sequence timing configuration |                                            | 0x0054                                     | R/W                                        |
| LP_UART_AT_CMD_GAPTOUT_SYNC_REG Timeout configuration              |                                            | 0x0058                                     | R/W                                        |
| LP_UART_AT_CMD_CHAR_SYNC_REG                                       | AT escape sequence detection configuration | 0x005C                                     | R/W                                        |
| Version Register                                                   | Version Register                           | Version Register                           | Version Register                           |
| LP_UART_DATE_REG                                                   | LP UART version register                   | 0x008C                                     | R/W                                        |

## 27.6.3 UHCI Register Summary

The addresses in this section are relative to UHCI base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                   | Description                              | Address                | Access                 |
|------------------------|------------------------------------------|------------------------|------------------------|
| Configuration Register | Configuration Register                   | Configuration Register | Configuration Register |
| UHCI_CONF0_REG         | UHCI configuration register              | 0x0000                 | R/W                    |
| UHCI_CONF1_REG         | UHCI configuration register              | 0x0014                 | varies                 |
| UHCI_ESCAPE_CONF_REG   | Escape character configuration           | 0x0020                 | R/W                    |
| UHCI_HUNG_CONF_REG     | Timeout configuration                    | 0x0024                 | R/W                    |
| UHCI_ACK_NUM_REG       | UHCI ACK number configuration            | 0x0028                 | varies                 |
| UHCI_QUICK_SENT_REG    | UHCI quick send configuration register   | 0x0030                 | varies                 |
| UHCI_REG_Q0_WORD0_REG  | Q0 WORD0 quick send register             | 0x0034                 | R/W                    |
| UHCI_REG_Q0_WORD1_REG  | Q0 WORD1 quick send register             | 0x0038                 | R/W                    |
| UHCI_REG_Q1_WORD0_REG  | Q1 WORD0 quick send register             | 0x003C                 | R/W                    |
| UHCI_REG_Q1_WORD1_REG  | Q1 WORD1 quick send register             | 0x0040                 | R/W                    |
| UHCI_REG_Q2_WORD0_REG  | Q2 WORD0 quick send register             | 0x0044                 | R/W                    |
| UHCI_REG_Q2_WORD1_REG  | Q2 WORD1 quick send register             | 0x0048                 | R/W                    |
| UHCI_REG_Q3_WORD0_REG  | Q3 WORD0 quick send register             | 0x004C                 | R/W                    |
| UHCI_REG_Q3_WORD1_REG  | Q3 WORD1 quick send register             | 0x0050                 | R/W                    |
| UHCI_REG_Q4_WORD0_REG  | Q4 WORD0 quick send register             | 0x0054                 | R/W                    |
| UHCI_REG_Q4_WORD1_REG  | Q4 WORD1 quick send register             | 0x0058                 | R/W                    |
| UHCI_REG_Q5_WORD0_REG  | Q5 WORD0 quick send register             | 0x005C                 | R/W                    |
| UHCI_REG_Q5_WORD1_REG  | Q5 WORD1 quick send register             | 0x0060                 | R/W                    |
| UHCI_REG_Q6_WORD0_REG  | Q6 WORD0 quick send register             | 0x0064                 | R/W                    |
| UHCI_REG_Q6_WORD1_REG  | Q6 WORD1 quick register                  | 0x0068                 | R/W                    |
| UHCI_ESC_CONF0_REG     | Escape sequence configuration register 0 | 0x006C                 | R/W                    |
| UHCI_ESC_CONF1_REG     | Escape sequence configuration register 1 | 0x0070                 | R/W                    |

| Name                    | Description                              | Address   | Access   |
|-------------------------|------------------------------------------|-----------|----------|
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
| Version Register        |                                          |           |          |
| UHCI_DATE_REG           | UHCI version control register            | 0x0080    | R/W      |

## 27.7 Registers

## 27.7.1 UART Registers

The addresses in this section are relative to UART Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 27.1. UART\_FIFO\_REG (0x0000)

![Image](images/27_Chapter_27_img016_ee001c58.png)

UART\_RXFIFO\_RD\_BYTE Represents the data UART n read from FIFO.

Measurement unit: byte. (RO)

Register 27.2. UART\_TOUT\_CONF\_SYNC\_REG (0x0064)

![Image](images/27_Chapter_27_img017_db02a374.png)

UART\_RX\_TOUT\_EN Configures whether or not to enable UART receiver’s timeout function.

0: Disable

1: Enable

(R/W)

UART\_RX\_TOUT\_THRHD Configures the amount of time that the bus can remain idle before timeout.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.3. UART\_INT\_RAW\_REG (0x0004)

![Image](images/27_Chapter_27_img018_94db8b3a.png)

UART\_RXFIFO\_FULL\_INT\_RAW The raw interrupt status of UART\_RXFIFO\_FULL\_INT. (R/WTC/SS)

UART\_TXFIFO\_EMPTY\_INT\_RAW The raw interrupt status of UART\_TXFIFO\_EMPTY\_INT. (R/WTC/SS)

UART\_PARITY\_ERR\_INT\_RAW The raw interrupt status of UART\_PARITY\_ERR\_INT. (R/WTC/SS)

UART\_FRM\_ERR\_INT\_RAW The raw interrupt status of UART\_FRM\_ERR\_INT. (R/WTC/SS)

UART\_RXFIFO\_OVF\_INT\_RAW The raw interrupt status of UART\_RXFIFO\_OVF\_INT. (R/WTC/SS)

UART\_DSR\_CHG\_INT\_RAW The raw interrupt status of UART\_DSR\_CHG\_INT. (R/WTC/SS)

UART\_CTS\_CHG\_INT\_RAW The raw interrupt status of UART\_CTS\_CHG\_INT. (R/WTC/SS)

UART\_BRK\_DET\_INT\_RAW The raw interrupt status of UART\_BRK\_DET\_INT. (R/WTC/SS)

UART\_RXFIFO\_TOUT\_INT\_RAW The raw interrupt status of UART\_RXFIFO\_TOUT\_INT. (R/WTC/SS)

UART\_SW\_XON\_INT\_RAW The raw interrupt status of UART\_SW\_XON\_INT. (R/WTC/SS)

UART\_SW\_XOFF\_INT\_RAW UART\_SW\_XOFF\_INT. (R/WTC/SS)

UART\_GLITCH\_DET\_INT\_RAW The raw interrupt status of UART\_GLITCH\_DET\_INT. (R/WTC/SS)

UART\_TX\_BRK\_DONE\_INT\_RAW The raw interrupt status of UART\_TX\_BRK\_DONE\_INT. (R/WTC/SS)

UART\_TX\_BRK\_IDLE\_DONE\_INT\_RAW The raw interrupt status of UART\_TX\_BRK\_IDLE\_DONE\_INT. (R/WTC/SS)

UART\_TX\_DONE\_INT\_RAW The raw interrupt status of UART\_TX\_DONE\_INT. (R/WTC/SS)

UART\_RS485\_PARITY\_ERR\_INT\_RAW The raw interrupt status of UART\_RS485\_PARITY\_ERR\_INT. (R/WTC/SS)

UART\_RS485\_FRM\_ERR\_INT\_RAW The raw interrupt status of UART\_RS485\_FRM\_ERR\_INT. (R/WTC/SS)

Continued on the next page...

## Register 27.3. UART\_INT\_RAW\_REG (0x0004)

Continued from the previous page...

UART\_RS485\_CLASH\_INT\_RAW The raw interrupt status of UART\_RS485\_CLASH\_INT. (R/WTC/SS)

UART\_AT\_CMD\_CHAR\_DET\_INT\_RAW The raw interrupt status of UART\_AT\_CMD\_CHAR\_DET\_INT.

(R/WTC/SS)

UART\_WAKEUP\_INT\_RAW The raw interrupt status of UART\_WAKEUP\_INT. (R/WTC/SS)

ESP32-C6 TRM (Version 1.1)

## Register 27.4. UART\_INT\_ST\_REG (0x0008)

![Image](images/27_Chapter_27_img019_74fb9622.png)

UART\_RXFIFO\_FULL\_INT\_ST The masked interrupt status of UART\_RXFIFO\_FULL\_INT.(RO)

UART\_TXFIFO\_EMPTY\_INT\_ST The masked interrupt status of UART\_TXFIFO\_EMPTY\_INT. (RO)

UART\_PARITY\_ERR\_INT\_ST The masked interrupt status of UART\_PARITY\_ERR\_INT. (RO)

UART\_FRM\_ERR\_INT\_ST The masked interrupt status of UART\_FRM\_ERR\_INT. (RO)

UART\_RXFIFO\_OVF\_INT\_ST The masked interrupt status of UART\_RXFIFO\_OVF\_INT. (RO)

UART\_DSR\_CHG\_INT\_ST The masked interrupt status of UART\_DSR\_CHG\_INT. (RO)

UART\_CTS\_CHG\_INT\_ST The masked interrupt status of UART\_CTS\_CHG\_INT. (RO)

UART\_BRK\_DET\_INT\_ST The masked interrupt status of UART\_BRK\_DET\_INT. (RO)

UART\_RXFIFO\_TOUT\_INT\_ST The masked interrupt status of UART\_RXFIFO\_TOUT\_INT. (RO)

UART\_SW\_XON\_INT\_ST The masked interrupt status of UART\_SW\_XON\_INT. (RO)

UART\_SW\_XOFF\_INT\_ST The masked interrupt status of UART\_SW\_XOFF\_INT. (RO)

UART\_GLITCH\_DET\_INT\_ST The masked interrupt status of UART\_GLITCH\_DET\_INT. (RO)

UART\_TX\_BRK\_DONE\_INT\_ST The masked interrupt status of UART\_TX\_BRK\_DONE\_INT. (RO)

UART\_TX\_BRK\_IDLE\_DONE\_INT\_ST The masked interrupt status of UART\_TX\_BRK\_IDLE\_DONE\_INT. (RO)

UART\_TX\_DONE\_INT\_ST The masked interrupt status of UART\_TX\_DONE\_INT. (RO)

UART\_RS485\_PARITY\_ERR\_INT\_ST The masked interrupt status of UART\_RS485\_PARITY\_ERR\_INT. (RO)

UART\_RS485\_FRM\_ERR\_INT\_ST The masked interrupt status of UART\_RS485\_FRM\_ERR\_INT. (RO)

UART\_RS485\_CLASH\_INT\_ST The masked interrupt status of UART\_RS485\_CLASH\_INT. (RO)

UART\_AT\_CMD\_CHAR\_DET\_INT\_ST The masked interrupt status of UART\_AT\_CMD\_CHAR\_DET\_INT. (RO)

UART\_WAKEUP\_INT\_ST The masked interrupt status of UART\_WAKEUP\_INT. (RO)

## Register 27.5. UART\_INT\_ENA\_REG (0x000C)

![Image](images/27_Chapter_27_img020_c5f5269d.png)

UART\_RXFIFO\_FULL\_INT\_ENA Write 1 to enable UART\_RXFIFO\_FULL\_INT. (R/W)

UART\_TXFIFO\_EMPTY\_INT\_ENA Write 1 to enable UART\_TXFIFO\_EMPTY\_INT. (R/W)

UART\_PARITY\_ERR\_INT\_ENA Write 1 to enable UART\_PARITY\_ERR\_INT. (R/W)

UART\_FRM\_ERR\_INT\_ENA Write 1 to enable UART\_FRM\_ERR\_INT. (R/W)

UART\_RXFIFO\_OVF\_INT\_ENA Write 1 to enable UART\_RXFIFO\_OVF\_INT. (R/W)

UART\_DSR\_CHG\_INT\_ENA Write 1 to enable UART\_DSR\_CHG\_INT. (R/W)

UART\_CTS\_CHG\_INT\_ENA Write 1 to enable UART\_CTS\_CHG\_INT. (R/W)

UART\_BRK\_DET\_INT\_ENA Write 1 to enable UART\_BRK\_DET\_INT. (R/W)

UART\_RXFIFO\_TOUT\_INT\_ENA Write 1 to enable UART\_RXFIFO\_TOUT\_INT. (R/W)

UART\_SW\_XON\_INT\_ENA Write 1 to enable UART\_SW\_XON\_INT.(R/W)

UART\_SW\_XOFF\_INT\_ENA Write 1 to enable UART\_SW\_XOFF\_INT. (R/W)

UART\_GLITCH\_DET\_INT\_ENA Write 1 to enable UART\_GLITCH\_DET\_INT. (R/W)

UART\_TX\_BRK\_DONE\_INT\_ENA Write 1 to enable UART\_TX\_BRK\_DONE\_INT. (R/W)

UART\_TX\_BRK\_IDLE\_DONE\_INT\_ENA Write 1 to enable UART\_TX\_BRK\_IDLE\_DONE\_INT. (R/W)

UART\_TX\_DONE\_INT\_ENA Write 1 to enable UART\_TX\_DONE\_INT. (R/W)

UART\_RS485\_PARITY\_ERR\_INT\_ENA Write 1 to enable UART\_RS485\_PARITY\_ERR\_INT. (R/W)

UART\_RS485\_FRM\_ERR\_INT\_ENA Write 1 to enable UART\_RS485\_FRM\_ERR\_INT. (R/W)

UART\_RS485\_CLASH\_INT\_ENA Write 1 to enable UART\_RS485\_CLASH\_INT. (R/W)

UART\_AT\_CMD\_CHAR\_DET\_INT\_ENA Write 1 to enable UART\_AT\_CMD\_CHAR\_DET\_INT. (R/W)

UART\_WAKEUP\_INT\_ENA Write 1 to enable UART\_WAKEUP\_INT. (R/W)

![Image](images/27_Chapter_27_img021_b236e792.png)

## Register 27.6. UART\_INT\_CLR\_REG (0x0010)

![Image](images/27_Chapter_27_img022_016321a7.png)

UART\_RXFIFO\_FULL\_INT\_CLR Write 1 to clear UART\_RXFIFO\_FULL\_INT. (WT) UART\_TXFIFO\_EMPTY\_INT\_CLR Write 1 to clear UART\_TXFIFO\_EMPTY\_INT. (WT) UART\_PARITY\_ERR\_INT\_CLR Write 1 to clear UART\_PARITY\_ERR\_INT. (WT) UART\_FRM\_ERR\_INT\_CLR Write 1 to clear UART\_FRM\_ERR\_INT. (WT) UART\_RXFIFO\_OVF\_INT\_CLR Write 1 to clear UART\_RXFIFO\_OVF\_INT. (WT) UART\_DSR\_CHG\_INT\_CLR Write 1 to clear UART\_DSR\_CHG\_INT. (WT) UART\_CTS\_CHG\_INT\_CLR Write 1 to clear UART\_CTS\_CHG\_INT. (WT) UART\_BRK\_DET\_INT\_CLR Write 1 to clear UART\_BRK\_DET\_INT. (WT) UART\_RXFIFO\_TOUT\_INT\_CLR Write 1 to clear UART\_RXFIFO\_TOUT\_INT. (WT) UART\_SW\_XON\_INT\_CLR Write 1 to clear UART\_SW\_XON\_INT. (WT) UART\_SW\_XOFF\_INT\_CLR Write 1 to clear UART\_SW\_XOFF\_INT. (WT) UART\_GLITCH\_DET\_INT\_CLR Write 1 to clear UART\_GLITCH\_DET\_INT. (WT) UART\_TX\_BRK\_DONE\_INT\_CLR Write 1 to clear UART\_TX\_BRK\_DONE\_INT. (WT) UART\_TX\_BRK\_IDLE\_DONE\_INT\_CLR Write 1 to clear UART\_TX\_BRK\_IDLE\_DONE\_INT. (WT) UART\_TX\_DONE\_INT\_CLR Write 1 to clear UART\_TX\_DONE\_INT. (WT)

UART\_RS485\_PARITY\_ERR\_INT\_CLR Write 1 to clear UART\_RS485\_PARITY\_ERR\_INT. (WT)

UART\_RS485\_FRM\_ERR\_INT\_CLR Write 1 to clear UART\_RS485\_FRM\_ERR\_INT. (WT)

UART\_RS485\_CLASH\_INT\_CLR Write 1 to clear UART\_RS485\_CLASH\_INT. (WT)

UART\_AT\_CMD\_CHAR\_DET\_INT\_CLR Write 1 to clear UART\_AT\_CMD\_CHAR\_DET\_INT. (WT)

UART\_WAKEUP\_INT\_CLR Write 1 to clear UART\_WAKEUP\_INT. (WT)

![Image](images/27_Chapter_27_img023_6f6e97b4.png)

## Register 27.7. UART\_CLKDIV\_SYNC\_REG (0x0014)

![Image](images/27_Chapter_27_img024_6ec9a1ac.png)

UART\_CLKDIV Configures the integral part of the divisor for baud rate generation. (R/W)

UART\_CLKDIV\_FRAG Configures the fractional part of the divisor for baud rate generation. (R/W)

Register 27.8. UART\_RX\_FILT\_REG (0x0018)

![Image](images/27_Chapter_27_img025_ecd778ed.png)

UART\_GLITCH\_FILT Configures the width of a pulse to be filtered.

Measurement unit: UART Core’s clock cycle.

Pulses whose width is lower than this value will be ignored. (R/W)

UART\_GLITCH\_FILT\_EN Configures whether or not to enable RX signal filter.

0: Disable

1: Enable(R/W)

## Register 27.9. UART\_CONF0\_SYNC\_REG (0x0020)

![Image](images/27_Chapter_27_img026_1e9d9fbf.png)

- UART\_PARITY Configures the parity check mode.
- 0: Even parity
- 1: Odd parity
- (R/W)

UART\_PARITY\_EN Configures whether or not to enable UART parity check.

- 0: Disable
- 1: Enable
- (R/W)
- UART\_BIT\_NUM Configures the number of data bits.
- 0: 5 bits
- 1: 6 bits
- 2: 7 bits
- 3: 8 bits
- (R/W)
- UART\_STOP\_BIT\_NUM Configures the number of stop bits.
- 0: Invalid. No effect
- 1: 1 bit
- 2: 1.5 bits
- 3: 2 bits
- (R/W)

UART\_TXD\_BRK Configures whether or not to send NULL characters when finishing data transmis-

- sion.
- 0: Not send
- 1: Send
- (R/W)

UART\_IRDA\_DPLX Configures whether or not to enable IrDA loopback test.

- 0: Disable
- 1: Enable
- (R/W)
- UART\_IRDA\_TX\_EN Configures whether or not to enable the IrDA transmitter.
- 0: Disable
- 1: Enable
- (R/W)

Continued on the next page...

## Register 27.9. UART\_CONF0\_SYNC\_REG (0x0020)

## Continued from the previous page...

UART\_IRDA\_WCTL Configures the 11th bit of the IrDA transmitter.

0: This bit is 0.

1: This bit is the same as the 10th bit.

(R/W)

UART\_IRDA\_TX\_INV Configures whether or not to invert the level of the IrDA transmitter.

0: Not invert

1: Invert

(R/W)

UART\_IRDA\_RX\_INV Configures whether or not to invert the level of the IrDA receiver.

0: Not invert

1: Invert

(R/W)

UART\_LOOPBACK Configures whether or not to enable UART loopback test.

0: Disable

1: Enable

(R/W)

UART\_TX\_FLOW\_EN Configures whether or not to enable flow control for the transmitter.

0: Disable

1: Enable

(R/W)

UART\_IRDA\_EN Configures whether or not to enable IrDA protocol.

0: Disable

1: Enable

(R/W)

UART\_RXD\_INV Configures whether or not to invert the level of UART RXD signal.

0: Not invert

1: Invert

(R/W)

UART\_TXD\_INV Configures whether or not to invert the level of UART TXD signal.

0: Not invert

1: Invert

(R/W)

UART\_DIS\_RX\_DAT\_OVF Configures whether or not to disable data overflow detection for the UART

receiver.

0: Enable

- 1: Disable

(R/W)

Continued on the next page...

## Register 27.9. UART\_CONF0\_SYNC\_REG (0x0020)

## Continued from the previous page...

UART\_ERR\_WR\_MASK Configures whether or not to store the received data with errors into FIFO.

0: Store

1: Not store

(R/W)

UART\_AUTOBAUD\_EN Configures whether or not to enable baud rate detection.

0: Disable

1: Enable

(R/W)

UART\_MEM\_CLK\_EN Configures whether or not to enable clock gating for UART memory.

0: Disable

1: Enable

(R/W)

UART\_SW\_RTS Configures the RTS signal used in software flow control.

- 0: The UART transmitter is not allowed to send data.
- 1: The UART transmitted is allowed to send data.

(R/W)

UART\_RXFIFO\_RST Configures whether or not to reset the UART RX FIFO.

- 0: Not reset

1: Reset

(R/W)

UART\_TXFIFO\_RST Configures whether or not to reset the UART TX FIFO.

0: Not reset

1: Reset

(R/W)

## Register 27.10. UART\_CONF1\_REG (0x0024)

![Image](images/27_Chapter_27_img027_b78b989f.png)

UART\_RXFIFO\_FULL\_THRHD Configures the threshold for RX FIFO being full.

Measurement unit: byte. (R/W)

UART\_TXFIFO\_EMPTY\_THRHD Configures the threshold for TX FIFO being empty.

Measurement unit: byte. (R/W)

UART\_CTS\_INV Configures whether or not to invert the level of UART CTS signal.

0: Not invert

1: Invert

(R/W)

UART\_DSR\_INV Configures whether or not to invert the level of UART DSR signal.

- 0: Not invert

1: Invert

(R/W)

UART\_RTS\_INV Configures whether or not to invert the level of UART RTS signal.

- 0: Not invert

1: Invert

(R/W)

UART\_DTR\_INV Configures whether or not to invert the level of UART DTR signal.

- 0: Not invert

1: Invert

(R/W)

UART\_SW\_DTR Configures the DTR signal used in software flow control.

- 0: Data to be transmitted is not ready.
- 1: Data to be transmitted is ready.

(R/W)

UART\_CLK\_EN Configures clock gating.

- 0: Support clock only when the application writes registers.
- 1: Always force the clock on for registers.

(R/W)

## Register 27.11. UART\_HWFC\_CONF\_SYNC\_REG (0x002C)

![Image](images/27_Chapter_27_img028_11d259a9.png)

UART\_RX\_FLOW\_THRHD Configures the maximum number of data bytes that can be received during hardware flow control.

Measurement unit: byte. (R/W)

UART\_RX\_FLOW\_EN Configures whether or not to enable the UART receiver.

0: Disable

1: Enable

(R/W)

## Register 27.12. UART\_SLEEP\_CONF0\_REG (0x0030)

![Image](images/27_Chapter_27_img029_d19d9f5f.png)

## Register 27.13. UART\_SLEEP\_CONF1\_REG (0x0034)

![Image](images/27_Chapter_27_img030_795a9cbd.png)

## Register 27.14. UART\_SLEEP\_CONF2\_REG (0x0038)

![Image](images/27_Chapter_27_img031_2e1a75d6.png)

UART\_ACTIVE\_THRESHOLD Configures the number of RXD edge changes to wake up the chip in wakeup mode 0. (R/W)

UART\_RX\_WAKE\_UP\_THRHD Configures the number of received data bytes to wake up the chip in wakeup mode 1. (R/W)

UART\_WK\_CHAR\_NUM Configures the number of wakeup characters. (R/W)

UART\_WK\_CHAR\_MASK Configures whether or not to mask wakeup characters.

0: Not mask

1: Mask

(R/W)

UART\_WK\_MODE\_SEL Configures which wakeup mode to select.

0: Mode 0

1: Mode 1

2: Mode 2

3: Mode 3

(R/W)

## Register 27.15. UART\_SWFC\_CONF0\_SYNC\_REG (0x003C)

![Image](images/27_Chapter_27_img032_1f47c1b9.png)

UART\_XON\_CHAR Configures the XON character for flow control. (R/W)

UART\_XOFF\_CHAR Configures the XOFF character for flow control. (R/W)

UART\_XON\_XOFF\_STILL\_SEND Configures whether the UART transmitter can send XON or XOFF characters when it is disabled.

0: Cannot send

1: Can send

(R/W)

UART\_SW\_FLOW\_CON\_EN Configures whether or not to enable software flow control.

0: Disable

1: Enable

(R/W)

UART\_XONOFF\_DEL Configures whether or not to remove flow control characters from the received data.

0: Not move

1: Move

(R/W)

UART\_FORCE\_XON Configures whether the transmitter continues to sending data.

0: Not send

1: Send

(R/W)

UART\_FORCE\_XOFF Configures whether or not to stop the transmitter from sending data.

0: Not stop

1: Stop

(R/W)

UART\_SEND\_XON Configures whether or not to send XON characters.

0: Not send

1: Send

(R/W/SS/SC)

UART\_SEND\_XOFF Configures whether or not to send XOFF characters.

0: Not send

1: Send

(R/W/SS/SC)

## Register 27.16. UART\_SWFC\_CONF1\_REG (0x0040)

![Image](images/27_Chapter_27_img033_a1ddd618.png)

UART\_XON\_THRESHOLD Configures the threshold for data in RX FIFO to send XON characters in software flow control.

Measurement unit: byte. (R/W)

UART\_XOFF\_THRESHOLD Configures the threshold for data in RX FIFO to send XOFF characters in software flow control.

Measurement unit: byte. (R/W)

## Register 27.17. UART\_TXBRK\_CONF\_SYNC\_REG (0x0044)

![Image](images/27_Chapter_27_img034_f2204c15.png)

UART\_TX\_BRK\_NUM Configures the number of NULL characters to be sent after finishing data trans- mission.

Valid only when UART\_TXD\_BRK is 1. (R/W)

## Register 27.18. UART\_IDLE\_CONF\_SYNC\_REG (0x0048)

![Image](images/27_Chapter_27_img035_a1ebe901.png)

UART\_RX\_IDLE\_THRHD Configures the threshold to generate a frame end signal when the receiver takes more time to receive one data byte data.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

UART\_TX\_IDLE\_NUM Configures the interval between two data transfers.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.19. UART\_RS485\_CONF\_SYNC\_REG (0x004C)

![Image](images/27_Chapter_27_img036_c51af202.png)

UART\_RS485\_EN Configures whether or not to enable RS485 mode.

0: Disable

1: Enable

(R/W)

UART\_DL0\_EN Configures whether or not to add a turnaround delay of 1 bit before the start bit.

0: Not add

1: Add

(R/W)

UART\_DL1\_EN Configures whether or not to add a turnaround delay of 1 bit after the stop bit.

0: Not add

- 1: Add

(R/W)

UART\_RS485TX\_RX\_EN Configures whether or not to enable the receiver for data reception when the transmitter is transmitting data in RS485 mode.

0: Disable

1: Enable

(R/W)

UART\_RS485RXBY\_TX\_EN Configures whether to enable the RS485 transmitter for data transmission when the RS485 receiver is busy.

0: Disable

1: Enable

(R/W)

UART\_RS485\_RX\_DLY\_NUM Configures the delay of internal data signals in the receiver.

Measurement unit: bit time (the time to transmit 1 bit).. (R/W)

UART\_RS485\_TX\_DLY\_NUM Configures the delay of internal data signals in the transmitter.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.20. UART\_CLK\_CONF\_REG (0x0088)

![Image](images/27_Chapter_27_img037_3086a330.png)

UART\_TX\_SCLK\_EN Configures whether or not to enable UART TX clock.

0: Disable

1: Enable

(R/W)

UART\_RX\_SCLK\_EN Configures whether or not to enable UART RX clock.

0: Disable

1: Enable

(R/W)

UART\_TX\_RST\_CORE Write 1 and then write 0 to reset UART TX. (R/W)

UART\_RX\_RST\_CORE Write 1 and then write 0 to reset UART RX. (R/W)

## Register 27.21. UART\_STATUS\_REG (0x001C)

![Image](images/27_Chapter_27_img038_25ad34e8.png)

UART\_RXFIFO\_CNT Represents the number of valid data bytes in RX FIFO. (RO)

UART\_DSRN Represents the level of the internal UART DSR signal. (RO)

UART\_CTSN Represents the level of the internal UART CTS signal. (RO)

UART\_RXD Represents the level of the internal UART RXD signal. (RO)

UART\_TXFIFO\_CNT Represents the number of valid data bytes in RX FIFO. (RO)

UART\_DTRN Represents the level of the internal UART DTR signal. (RO)

UART\_RTSN Represents the level of the internal UART RTS signal. (RO)

UART\_TXD Represents the level of the internal UART TXD signal. (RO)

![Image](images/27_Chapter_27_img039_94264d9a.png)

## Register 27.25. UART\_AFIFO\_STATUS\_REG (0x0090)

![Image](images/27_Chapter_27_img040_913d24e4.png)

UART\_TX\_AFIFO\_FULL Represents whether or not the APB TX asynchronous FIFO is full.

- 0: Not full
- 1: Full

(RO)

UART\_TX\_AFIFO\_EMPTY Represents whether or not the APB TX asynchronous FIFO is empty.

- 0: Not empty
- 1: Empty
- (RO)

UART\_RX\_AFIFO\_FULL Represents whether or not the APB RX asynchronous FIFO is full.

- 0: Not full
- 1: Full

(RO)

UART\_RX\_AFIFO\_EMPTY Represents whether or not the APB RX asynchronous FIFO is empty.

- 0: Not empty
- 1: Empty

(RO)

Register 27.26. UART\_AT\_CMD\_PRECNT\_SYNC\_REG (0x0050)

![Image](images/27_Chapter_27_img041_8c24aede.png)

UART\_PRE\_IDLE\_NUM Configures the idle time before the receiver receives the first AT\_CMD.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.27. UART\_AT\_CMD\_POSTCNT\_SYNC\_REG (0x0054)

![Image](images/27_Chapter_27_img042_269ffdac.png)

UART\_POST\_IDLE\_NUM Configures the interval between the last AT\_CMD and subsequent data. Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.28. UART\_AT\_CMD\_GAPTOUT\_SYNC\_REG (0x0058)

UART\_RX\_GAP\_TOUT Configures the interval between two AT\_CMD characters.

![Image](images/27_Chapter_27_img043_4734ebfe.png)

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.29. UART\_AT\_CMD\_CHAR\_SYNC\_REG (0x005C)

![Image](images/27_Chapter_27_img044_40887562.png)

UART\_AT\_CMD\_CHAR Configures the AT\_CMD character. (R/W)

UART\_CHAR\_NUM Configures the number of continuous AT\_CMD characters a receiver can receive. (R/W)

![Image](images/27_Chapter_27_img045_3afcce59.png)

![Image](images/27_Chapter_27_img046_849e9b84.png)

UART\_DATE Version control register. (R/W)

## Register 27.36. UART\_REG\_UPDATE\_REG (0x0098)

![Image](images/27_Chapter_27_img047_8bd6226f.png)

UART\_REG\_UPDATE Configures whether or not to synchronize registers.

- 0: Not synchronize

1: Synchronize

(R/W/SC)

## Register 27.37. UART\_ID\_REG (0x009C)

UART\_ID Configures the UART ID. (R/W)

![Image](images/27_Chapter_27_img048_61133284.png)

## 27.7.2 LP UART Registers

The addresses in this section are relative to LP UART base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 27.38. LP\_UART\_FIFO\_REG (0x0000)

![Image](images/27_Chapter_27_img049_4bb5536c.png)

LP\_UART\_RXFIFO\_RD\_BYTE Represents the data LP UART n read from FIFO.

Measurement unit: byte. (RO)

## Register 27.39. LP\_UART\_TOUT\_CONF\_SYNC\_REG (0x0064)

![Image](images/27_Chapter_27_img050_3a3a3d1a.png)

- LP\_UART\_RX\_TOUT\_EN Configures whether or not to enable LP UART receiver’s timeout function.
- LP\_UART\_RX\_TOUT\_FLOW\_DIS Configures whether or not to stop the idle status counter when hardware flow control is enabled.

0: Disable

1: Enable

(R/W)

0: Invalid. No effect

1: Stop

(R/W)

- LP\_UART\_RX\_TOUT\_THRHD Configures the amount of time that the bus can remain idle before time-

out.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.40. LP\_UART\_INT\_RAW\_REG (0x0004)

![Image](images/27_Chapter_27_img051_32483eb9.png)

- LP\_UART\_RXFIFO\_FULL\_INT\_RAW The raw interrupt status of LP\_UART\_RXFIFO\_FULL\_INT. (R/WTC/SS)

LP\_UART\_TXFIFO\_EMPTY\_INT\_RAW The raw interrupt status of LP\_UART\_TXFIFO\_EMPTY\_INT. (R/WTC/SS) LP\_UART\_PARITY\_ERR\_INT\_RAW The raw interrupt status of LP\_UART\_PARITY\_ERR\_INT. (R/WTC/SS) LP\_UART\_FRM\_ERR\_INT\_RAW The raw interrupt status of LP\_UART\_FRM\_ERR\_INT. (R/WTC/SS) LP\_UART\_RXFIFO\_OVF\_INT\_RAW The raw interrupt status of LP\_UART\_RXFIFO\_OVF\_INT. (R/WTC/SS) LP\_UART\_DSR\_CHG\_INT\_RAW The raw interrupt status of LP\_UART\_DSR\_CHG\_INT. (R/WTC/SS) LP\_UART\_CTS\_CHG\_INT\_RAW The raw interrupt status of LP\_UART\_CTS\_CHG\_INT. (R/WTC/SS) LP\_UART\_BRK\_DET\_INT\_RAW The raw interrupt status of LP\_UART\_BRK\_DET\_INT. (R/WTC/SS) LP\_UART\_RXFIFO\_TOUT\_INT\_RAW The raw interrupt status of LP\_UART\_RXFIFO\_TOUT\_INT. (R/WTC/SS) LP\_UART\_SW\_XON\_INT\_RAW The raw interrupt status of LP\_UART\_SW\_XON\_INT. (R/WTC/SS) LP\_UART\_SW\_XOFF\_INT\_RAW LP\_UART\_SW\_XOFF\_INT. (R/WTC/SS)

- LP\_UART\_GLITCH\_DET\_INT\_RAW The raw interrupt status of LP\_UART\_GLITCH\_DET\_INT. (R/WTC/SS)
- LP\_UART\_TX\_BRK\_DONE\_INT\_RAW The raw interrupt status of LP\_UART\_TX\_BRK\_DONE\_INT. (R/WTC/SS)
- LP\_UART\_TX\_BRK\_IDLE\_DONE\_INT\_RAW The raw interrupt status of LP\_UART\_TX\_BRK\_IDLE\_DONE\_INT. (R/WTC/SS)

## Continued on the next page...

## Register 27.40. LP\_UART\_INT\_RAW\_REG (0x0004)

## Continued from the previous page...

LP\_UART\_TX\_DONE\_INT\_RAW The raw interrupt status of LP\_UART\_TX\_DONE\_INT. (R/WTC/SS)

LP\_UART\_AT\_CMD\_CHAR\_DET\_INT\_RAW The raw interrupt status of LP\_UART\_AT\_CMD\_CHAR\_DET\_INT. (R/WTC/SS)

LP\_UART\_WAKEUP\_INT\_RAW The raw interrupt status of LP\_UART\_WAKEUP\_INT. (R/WTC/SS)

![Image](images/27_Chapter_27_img052_cebd5cd8.png)

## Register 27.41. LP\_UART\_INT\_ST\_REG (0x0008)

![Image](images/27_Chapter_27_img053_45aa2787.png)

LP\_UART\_RXFIFO\_FULL\_INT\_ST The masked interrupt status of LP\_UART\_RXFIFO\_FULL\_INT.(RO) LP\_UART\_TXFIFO\_EMPTY\_INT\_ST The masked interrupt status of LP\_UART\_TXFIFO\_EMPTY\_INT. (RO)

LP\_UART\_PARITY\_ERR\_INT\_ST The masked interrupt status of LP\_UART\_PARITY\_ERR\_INT. (RO)

LP\_UART\_FRM\_ERR\_INT\_ST The masked interrupt status of LP\_UART\_FRM\_ERR\_INT. (RO)

LP\_UART\_RXFIFO\_OVF\_INT\_ST The masked interrupt status of LP\_UART\_RXFIFO\_OVF\_INT. (RO)

LP\_UART\_DSR\_CHG\_INT\_ST The masked interrupt status of LP\_UART\_DSR\_CHG\_INT. (RO)

LP\_UART\_CTS\_CHG\_INT\_ST The masked interrupt status of LP\_UART\_CTS\_CHG\_INT. (RO)

LP\_UART\_BRK\_DET\_INT\_ST The masked interrupt status of LP\_UART\_BRK\_DET\_INT. (RO)

LP\_UART\_RXFIFO\_TOUT\_INT\_ST The masked interrupt status of LP\_UART\_RXFIFO\_TOUT\_INT. (RO)

LP\_UART\_SW\_XON\_INT\_ST The masked interrupt status of LP\_UART\_SW\_XON\_INT. (RO)

LP\_UART\_SW\_XOFF\_INT\_ST The masked interrupt status of LP\_UART\_SW\_XOFF\_INT. (RO)

LP\_UART\_GLITCH\_DET\_INT\_ST The masked interrupt status of LP\_UART\_GLITCH\_DET\_INT. (RO)

LP\_UART\_TX\_BRK\_DONE\_INT\_ST The masked interrupt status of LP\_UART\_TX\_BRK\_DONE\_INT. (RO)

- LP\_UART\_TX\_BRK\_IDLE\_DONE\_INT\_ST The masked interrupt status of LP\_UART\_TX\_BRK\_IDLE\_DONE\_INT. (RO)

LP\_UART\_TX\_DONE\_INT\_ST The masked interrupt status of LP\_UART\_TX\_DONE\_INT. (RO)

- LP\_UART\_AT\_CMD\_CHAR\_DET\_INT\_ST The masked interrupt status of LP\_UART\_AT\_CMD\_CHAR\_DET\_INT. (RO)

LP\_UART\_WAKEUP\_INT\_ST The masked interrupt status of LP\_UART\_WAKEUP\_INT. (RO)

## Register 27.42. LP\_UART\_INT\_ENA\_REG (0x000C)

![Image](images/27_Chapter_27_img054_c5ca0cbd.png)

LP\_UART\_RXFIFO\_FULL\_INT\_ENA Write 1 to enable LP\_UART\_RXFIFO\_FULL\_INT. (R/W) LP\_UART\_TXFIFO\_EMPTY\_INT\_ENA Write 1 to enable LP\_UART\_TXFIFO\_EMPTY\_INT. (R/W) LP\_UART\_PARITY\_ERR\_INT\_ENA Write 1 to enable LP\_UART\_PARITY\_ERR\_INT. (R/W) LP\_UART\_FRM\_ERR\_INT\_ENA Write 1 to enable LP\_UART\_FRM\_ERR\_INT. (R/W) LP\_UART\_RXFIFO\_OVF\_INT\_ENA Write 1 to enable LP\_UART\_RXFIFO\_OVF\_INT. (R/W) LP\_UART\_DSR\_CHG\_INT\_ENA Write 1 to enable LP\_UART\_DSR\_CHG\_INT. (R/W) LP\_UART\_CTS\_CHG\_INT\_ENA Write 1 to enable LP\_UART\_CTS\_CHG\_INT. (R/W) LP\_UART\_BRK\_DET\_INT\_ENA Write 1 to enable LP\_UART\_BRK\_DET\_INT. (R/W) LP\_UART\_RXFIFO\_TOUT\_INT\_ENA Write 1 to enable LP\_UART\_RXFIFO\_TOUT\_INT. (R/W) LP\_UART\_SW\_XON\_INT\_ENA Write 1 to enable LP\_UART\_SW\_XON\_INT.(R/W) LP\_UART\_SW\_XOFF\_INT\_ENA Write 1 to enable LP\_UART\_SW\_XOFF\_INT. (R/W) LP\_UART\_GLITCH\_DET\_INT\_ENA Write 1 to enable LP\_UART\_GLITCH\_DET\_INT. (R/W) LP\_UART\_TX\_BRK\_DONE\_INT\_ENA Write 1 to enable LP\_UART\_TX\_BRK\_DONE\_INT. (R/W) LP\_UART\_TX\_BRK\_IDLE\_DONE\_INT\_ENA Write 1 to enable LP\_UART\_TX\_BRK\_IDLE\_DONE\_INT. (R/W) LP\_UART\_TX\_DONE\_INT\_ENA Write 1 to enable LP\_UART\_TX\_DONE\_INT. (R/W) LP\_UART\_AT\_CMD\_CHAR\_DET\_INT\_ENA Write 1 to enable LP\_UART\_AT\_CMD\_CHAR\_DET\_INT. (R/W)

LP\_UART\_WAKEUP\_INT\_ENA Write 1 to enable LP\_UART\_WAKEUP\_INT. (R/W)

![Image](images/27_Chapter_27_img055_9b7cee0b.png)

## Register 27.43. LP\_UART\_INT\_CLR\_REG (0x0010)

![Image](images/27_Chapter_27_img056_6c07d729.png)

LP\_UART\_RXFIFO\_FULL\_INT\_CLR Write 1 to clear LP\_UART\_RXFIFO\_FULL\_INT. (WT) LP\_UART\_TXFIFO\_EMPTY\_INT\_CLR Write 1 to clear LP\_UART\_TXFIFO\_EMPTY\_INT. (WT) LP\_UART\_PARITY\_ERR\_INT\_CLR Write 1 to clear LP\_UART\_PARITY\_ERR\_INT. (WT) LP\_UART\_FRM\_ERR\_INT\_CLR Write 1 to clear LP\_UART\_FRM\_ERR\_INT. (WT) LP\_UART\_RXFIFO\_OVF\_INT\_CLR Write 1 to clear LP\_UART\_RXFIFO\_OVF\_INT. (WT) LP\_UART\_DSR\_CHG\_INT\_CLR Write 1 to clear LP\_UART\_DSR\_CHG\_INT. (WT) LP\_UART\_CTS\_CHG\_INT\_CLR Write 1 to clear LP\_UART\_CTS\_CHG\_INT. (WT) LP\_UART\_BRK\_DET\_INT\_CLR Write 1 to clear LP\_UART\_BRK\_DET\_INT. (WT) LP\_UART\_RXFIFO\_TOUT\_INT\_CLR Write 1 to clear LP\_UART\_RXFIFO\_TOUT\_INT. (WT) LP\_UART\_SW\_XON\_INT\_CLR Write 1 to clear LP\_UART\_SW\_XON\_INT. (WT) LP\_UART\_SW\_XOFF\_INT\_CLR Write 1 to clear LP\_UART\_SW\_XOFF\_INT. (WT) LP\_UART\_GLITCH\_DET\_INT\_CLR Write 1 to clear LP\_UART\_GLITCH\_DET\_INT. (WT) LP\_UART\_TX\_BRK\_DONE\_INT\_CLR Write 1 to clear LP\_UART\_TX\_BRK\_DONE\_INT. (WT)

LP\_UART\_TX\_BRK\_IDLE\_DONE\_INT\_CLR Write 1 to clear LP\_UART\_TX\_BRK\_IDLE\_DONE\_INT. (WT)

LP\_UART\_TX\_DONE\_INT\_CLR Write 1 to clear LP\_UART\_TX\_DONE\_INT. (WT) LP\_UART\_AT\_CMD\_CHAR\_DET\_INT\_CLR Write 1 to clear LP\_UART\_AT\_CMD\_CHAR\_DET\_INT. (WT)

LP\_UART\_WAKEUP\_INT\_CLR Write 1 to clear LP\_UART\_WAKEUP\_INT. (WT)

Submit Documentation Feedback

## Register 27.44. LP\_UART\_CLKDIV\_SYNC\_REG (0x0014)

![Image](images/27_Chapter_27_img057_8e62dbe5.png)

LP\_UART\_CLKDIV Configures the integral part of the divisor for baud rate generation. (R/W)

LP\_UART\_CLKDIV\_FRAG Configures the fractional part of the divisor for baud rate generation. (R/W)

Register 27.45. LP\_UART\_RX\_FILT\_REG (0x0018)

![Image](images/27_Chapter_27_img058_45b8e910.png)

- LP\_UART\_GLITCH\_FILT Configures the width of a pulse to be filtered.

Measurement unit: UART Core’s clock cycle.

Pulses whose width is lower than this value will be ignored. (R/W)

- LP\_UART\_GLITCH\_FILT\_EN Configures whether or not to enable RX signal filter.
- 0: Disable
- 1: Enable(R/W)

## Register 27.46. LP\_UART\_CONF0\_SYNC\_REG (0x0020)

![Image](images/27_Chapter_27_img059_3da45809.png)

- LP\_UART\_PARITY Configures the parity check mode.
- LP\_UART\_PARITY\_EN Configures whether or not to enable LP UART parity check.

0: Even parity

1: Odd parity

(R/W)

0: Disable

1: Enable

(R/W)

- LP\_UART\_BIT\_NUM Configures the number of data bits.

0: 5 bits

1: 6 bits

2: 7 bits

3: 8 bits

(R/W)

- LP\_UART\_STOP\_BIT\_NUM Configures the number of stop bits.
- LP\_UART\_TXD\_BRK Configures whether or not to send NULL characters when finishing data trans-

0: Invalid. No effect

1: 1 bit

2: 1.5 bits

3: 2 bits

(R/W)

mission.

0: Not send

1: Send

(R/W)

- LP\_UART\_LOOPBACK Configures whether or not to enable LP UART loopback test.

0: Disable

1: Enable

(R/W)

Continued on the next page...

## Register 27.46. LP\_UART\_CONF0\_SYNC\_REG (0x0020)

## Continued from the previous page...

- LP\_UART\_TX\_FLOW\_EN Configures whether or not to enable flow control for the transmitter.

0: Disable

1: Enable

(R/W)

- LP\_UART\_RXD\_INV Configures whether or not to invert the level of LP UART RXD signal.
- 0: Not invert
- 1: Invert

(R/W)

- LP\_UART\_TXD\_INV Configures whether or not to invert the level of LP UART TXD signal.
- 0: Not invert
- 1: Invert

(R/W)

- LP\_UART\_DIS\_RX\_DAT\_OVF Configures whether or not to disable data overflow detection for the
- LP UART receiver.
- 0: Enable
- 1: Disable

(R/W)

- LP\_UART\_ERR\_WR\_MASK Configures whether or not to store the received data with errors into FIFO.

0: Store

- 1: Not store

(R/W)

- LP\_UART\_MEM\_CLK\_EN Configures whether or not to enable clock gating for LP UART memory.
- 0: Disable
- 1: Enable

(R/W)

- LP\_UART\_SW\_RTS Configures the RTS signal used in software flow control.
- 0: The LP UART transmitter is not allowed to send data.
- 1: The LP UART transmitted is allowed to send data.

(R/W)

- LP\_UART\_RXFIFO\_RST Configures whether or not to reset the LP UART RX FIFO.
- 0: Not reset
- 1: Reset

(R/W)

- LP\_UART\_TXFIFO\_RST Configures whether or not to reset the LP UART TX FIFO.
- 0: Not reset
- 1: Reset

(R/W)

## Register 27.47. LP\_UART\_CONF1\_REG (0x0024)

![Image](images/27_Chapter_27_img060_d36df08e.png)

- LP\_UART\_RXFIFO\_FULL\_THRHD Configures the threshold for RX FIFO being full.
- LP\_UART\_TXFIFO\_EMPTY\_THRHD Configures the threshold for TX FIFO being empty.
- LP\_UART\_CTS\_INV Configures whether or not to invert the level of LP UART CTS signal.
- 0: Not invert

Measurement unit: byte. (R/W)

Measurement unit: byte. (R/W)

1: Invert

(R/W)

- LP\_UART\_DSR\_INV Configures whether or not to invert the level of LP UART DSR signal.
- LP\_UART\_RTS\_INV Configures whether or not to invert the level of LP UART RTS signal.
- LP\_UART\_DTR\_INV Configures whether or not to invert the level of LP UART DTR signal.
- 0: Not invert

0: Not invert

- 1: Invert

(R/W)

0: Not invert

1: Invert

(R/W)

1: Invert

(R/W)

- LP\_UART\_SW\_DTR Configures the DTR signal used in software flow control.
- 0: Data to be transmitted is not ready.
- 1: Data to be transmitted is ready.

(R/W)

- LP\_UART\_CLK\_EN Configures clock gating.
- 0: Support clock only when the application writes registers.
- 1: Always force the clock on for registers.

(R/W)

## Register 27.48. LP\_UART\_HWFC\_CONF\_SYNC\_REG (0x002C)

![Image](images/27_Chapter_27_img061_554e52a4.png)

- LP\_UART\_RX\_FLOW\_THRHD Configures the maximum number of data bytes that can be received

during hardware flow control.

Measurement unit: byte. (R/W)

- LP\_UART\_RX\_FLOW\_EN Configures whether or not to enable the LP UART receiver.

0: Disable

1: Enable

(R/W)

## Register 27.49. LP\_UART\_SLEEP\_CONF0\_REG (0x0030)

![Image](images/27_Chapter_27_img062_747c77f5.png)

- LP\_UART\_WK\_CHAR1 Configures wakeup character 1. (R/W)

LP\_UART\_WK\_CHAR2 Configures wakeup character 2. (R/W)

LP\_UART\_WK\_CHAR3 Configures wakeup character 3. (R/W)

LP\_UART\_WK\_CHAR4 Configures wakeup character 4. (R/W)

## Register 27.50. LP\_UART\_SLEEP\_CONF1\_REG (0x0034)

![Image](images/27_Chapter_27_img063_de8a499b.png)

LP\_UART\_WK\_CHAR0 Configures wakeup character 0. (R/W)

## Register 27.51. LP\_UART\_SLEEP\_CONF2\_REG (0x0038)

![Image](images/27_Chapter_27_img064_fd60995c.png)

- LP\_UART\_ACTIVE\_THRESHOLD Configures the number of RXD edge changes to wake up the chip in wakeup mode 0. (R/W)
- LP\_UART\_RX\_WAKE\_UP\_THRHD Configures the number of received data bytes to wake up the chip in wakeup mode 1. (R/W)
- LP\_UART\_WK\_CHAR\_NUM Configures the number of wakeup characters. (R/W)
- LP\_UART\_WK\_CHAR\_MASK Configures whether or not to mask wakeup characters.

0: Not mask

1: Mask

(R/W)

- LP\_UART\_WK\_MODE\_SEL Configures which wakeup mode to select.

0: Mode 0

1: Mode 1

- 2: Mode 2

3: Mode 3

(R/W)

## Register 27.52. LP\_UART\_SWFC\_CONF0\_SYNC\_REG (0x003C)

![Image](images/27_Chapter_27_img065_c5bb056e.png)

- LP\_UART\_XON\_CHAR Configures the XON character for flow control. (R/W)

LP\_UART\_XOFF\_CHAR Configures the XOFF character for flow control. (R/W)

- LP\_UART\_XON\_XOFF\_STILL\_SEND Configures whether the LP UART transmitter can send XON or XOFF characters when it is disabled.

0: Cannot send

1: Can send

(R/W)

- LP\_UART\_SW\_FLOW\_CON\_EN Configures whether or not to enable software flow control.
- LP\_UART\_XONOFF\_DEL Configures whether or not to remove flow control characters from the re-

0: Disable

1: Enable

(R/W)

ceived data.

0: Not move

1: Move

(R/W)

- LP\_UART\_FORCE\_XON Configures whether the transmitter continues to sending data.

0: Not send

1: Send

(R/W)

- LP\_UART\_FORCE\_XOFF Configures whether or not to stop the transmitter from sending data.

0: Not stop

1: Stop

(R/W)

- LP\_UART\_SEND\_XON Configures whether or not to send XON characters.

0: Not send

1: Send

(R/W/SS/SC)

- LP\_UART\_SEND\_XOFF Configures whether or not to send XOFF characters.

0: Not send

1: Send

(R/W/SS/SC)

## Register 27.53. LP\_UART\_SWFC\_CONF1\_REG (0x0040)

![Image](images/27_Chapter_27_img066_53be68d7.png)

- LP\_UART\_XON\_THRESHOLD Configures the threshold for data in RX FIFO to send XON characters in

software flow control.

Measurement unit: byte. (R/W)

- LP\_UART\_XOFF\_THRESHOLD Configures the threshold for data in RX FIFO to send XOFF characters in software flow control.

Measurement unit: byte. (R/W)

## Register 27.54. LP\_UART\_TXBRK\_CONF\_SYNC\_REG (0x0044)

![Image](images/27_Chapter_27_img067_ef27ede6.png)

- LP\_UART\_TX\_BRK\_NUM Configures the number of NULL characters to be sent after finishing data

transmission.

Valid only when LP\_UART\_TXD\_BRK is 1. (R/W)

## Register 27.55. LP\_UART\_IDLE\_CONF\_SYNC\_REG (0x0048)

![Image](images/27_Chapter_27_img068_e56e9d6a.png)

- LP\_UART\_RX\_IDLE\_THRHD Configures the threshold to generate a frame end signal when the re-

ceiver takes more time to receive one data byte data.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

- LP\_UART\_TX\_IDLE\_NUM Configures the interval between two data transfers.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.56. LP\_UART\_DELAY\_CONF\_SYNC\_REG (0x004C)

![Image](images/27_Chapter_27_img069_c91dc7c6.png)

- LP\_UART\_DL0\_EN Configures whether or not to add a turnaround delay of 1 bit before the start bit.
- 0: Not add
- 1: Add

(R/W)

- LP\_UART\_DL1\_EN Configures whether or not to add a turnaround delay of 1 bit after the stop bit.
- 0: Not add
- 1: Add

(R/W)

## Register 27.57. LP\_UART\_CLK\_CONF\_REG (0x0088)

![Image](images/27_Chapter_27_img070_045a957a.png)

LP\_UART\_TX\_SCLK\_EN Configures whether or not to enable LP UART TX clock.

0: Disable

1: Enable

(R/W)

- LP\_UART\_RX\_SCLK\_EN Configures whether or not to enable LP UART RX clock.

0: Disable

1: Enable

(R/W)

LP\_UART\_TX\_RST\_CORE Write 1 and then write 0 to reset LP UART TX. (R/W)

LP\_UART\_RX\_RST\_CORE Write 1 and then write 0 to reset LP UART RX. (R/W)

## Register 27.58. LP\_UART\_STATUS\_REG (0x001C)

![Image](images/27_Chapter_27_img071_21c294b7.png)

LP\_UART\_RXFIFO\_CNT Represents the number of valid data bytes in RX FIFO. (RO)

LP\_UART\_DSRN Represents the level of the internal LP UART DSR signal. (RO)

LP\_UART\_CTSN Represents the level of the internal LP UART CTS signal. (RO)

LP\_UART\_RXD Represents the level of the internal LP UART RXD signal. (RO)

LP\_UART\_TXFIFO\_CNT Represents the number of valid data bytes in RX FIFO. (RO)

LP\_UART\_DTRN Represents the level of the internal LP UART DTR signal. (RO)

LP\_UART\_RTSN Represents the level of the internal LP UART RTS signal. (RO)

LP\_UART\_TXD Represents the level of the internal LP UART TXD signal. (RO)

## Register 27.59. LP\_UART\_MEM\_TX\_STATUS\_REG (0x0068)

![Image](images/27_Chapter_27_img072_4d5a442c.png)

LP\_UART\_TX\_SRAM\_WADDR Represents the offset address to write TX FIFO. (RO)

LP\_UART\_TX\_SRAM\_RADDR Represents the offset address to read TX FIFO. (RO)

## Register 27.60. LP\_UART\_MEM\_RX\_STATUS\_REG (0x006C)

![Image](images/27_Chapter_27_img073_1480ca08.png)

LP\_UART\_RX\_SRAM\_RADDR Represents the offset address to read RX FIFO. (RO)

LP\_UART\_RX\_SRAM\_WADDR Represents the offset address to write RX FIFO. (RO)

## Register 27.61. LP\_UART\_FSM\_STATUS\_REG (0x0070)

![Image](images/27_Chapter_27_img074_b90a5fa3.png)

LP\_UART\_ST\_URX\_OUT Represents the status of the receiver. (RO)

LP\_UART\_ST\_UTX\_OUT Represents the status of the transmitter. (RO)

## Register 27.62. LP\_UART\_AFIFO\_STATUS\_REG (0x0090)

![Image](images/27_Chapter_27_img075_211d5a79.png)

- LP\_UART\_TX\_AFIFO\_FULL Represents whether or not the APB TX asynchronous FIFO is full.
- 0: Not full
- 1: Full
- (RO)
- LP\_UART\_TX\_AFIFO\_EMPTY Represents whether or not the APB TX asynchronous FIFO is empty.
- 0: Not empty
- 1: Empty

(RO)

- LP\_UART\_RX\_AFIFO\_FULL Represents whether or not the APB RX asynchronous FIFO is full.
- 0: Not full
- 1: Full

(RO)

- LP\_UART\_RX\_AFIFO\_EMPTY Represents whether or not the APB RX asynchronous FIFO is empty.
- 0: Not empty
- 1: Empty
- (RO)

Register 27.63. LP\_UART\_AT\_CMD\_PRECNT\_SYNC\_REG (0x0050)

![Image](images/27_Chapter_27_img076_65d4c09c.png)

LP\_UART\_PRE\_IDLE\_NUM Configures the idle time before the receiver receives the first AT\_CMD. Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.64. LP\_UART\_AT\_CMD\_POSTCNT\_SYNC\_REG (0x0054)

![Image](images/27_Chapter_27_img077_763f6d8e.png)

LP\_UART\_POST\_IDLE\_NUM Configures the interval between the last AT\_CMD and subsequent data.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

Register 27.65. LP\_UART\_AT\_CMD\_GAPTOUT\_SYNC\_REG (0x0058)

![Image](images/27_Chapter_27_img078_4c25065e.png)

LP\_UART\_RX\_GAP\_TOUT Configures the interval between two AT\_CMD characters.

Measurement unit: bit time (the time to transmit 1 bit). (R/W)

## Register 27.66. LP\_UART\_AT\_CMD\_CHAR\_SYNC\_REG (0x005C)

![Image](images/27_Chapter_27_img079_b4b27bca.png)

LP\_UART\_AT\_CMD\_CHAR Configures the AT\_CMD character. (R/W)

LP\_UART\_CHAR\_NUM Configures the number of continuous AT\_CMD characters a receiver can receive. (R/W)

![Image](images/27_Chapter_27_img080_e1efe13d.png)

## 27.7.3 UHCI Registers

The addresses in this section are relative to UHCI base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 27.70. UHCI\_CONF0\_REG (0x0000)

![Image](images/27_Chapter_27_img081_b3e954e0.png)

UHCI\_TX\_RST Write 1 and then write 0 to reset the decoder state machine. (R/W)

UHCI\_RX\_RST Write 1 and then write 0 to reset the encoder state machine. (R/W)

UHCI\_UART0\_CE Configures whether or not to connect UHCI with UART0.

- 0: Not connect
- 1: Connect

(R/W)

UHCI\_UART1\_CE Configures whether or not to connect UHCI with UART1.

- 0: Not connect
- 1: Connect

(R/W)

UHCI\_SEPER\_EN Configures whether or not to separate the data frame with a special character.

- 0: Not separate
- 1: Separate

(R/W)

UHCI\_HEAD\_EN Configures whether or not to encode the data packet with a formatting header.

- 0: Not use formatting header
- 1: Use formatting header

(R/W)

UHCI\_CRC\_REC\_EN Configures whether or not to enable the reception of the 16-bit CRC.

- 0: Disable
- 1: Enable

(R/W)

UHCI\_UART\_IDLE\_EOF\_EN Configures whether or not to stop receiving data when UART is idle.

- 0: Not stop
- 1: Stop

(R/W)

UHCI\_LEN\_EOF\_EN Configures when the UHCI decoder stops receiving data.

- 0: Stops after receiving 0xC0
- 1: Stops when the number of received data bytes reach the specified value. When UHCI\_HEAD\_EN is 1, the specified value is the data length indicated by the UHCI packet header; when UHCI\_HEAD\_EN is 0, the specified value is the configured value.

(R/W)

Continued on the next page...

## Register 27.70. UHCI\_CONF0\_REG (0x0000)

## Continued from the previous page...

UHCI\_ENCODE\_CRC\_EN Configures whether or not to enable data integrity check by appending a 16 bit CCITT-CRC to the end of the data.

- 0: Disable
- 1: Enable

(R/W)

## UHCI\_CLK\_EN Configures clock gating.

- 0: Support clock only when the application writes registers.
- 1: Always force the clock on for registers.

(R/W)

UHCI\_UART\_RX\_BRK\_EOF\_EN Configures whether or not to stop UHCI from receiving data after UART has received a NULL frame.

- 0: Not stop
- 1: Stop

(R/W)

## Register 27.71. UHCI\_CONF1\_REG (0x0014)

![Image](images/27_Chapter_27_img082_8cb25a61.png)

UHCI\_CHECK\_SUM\_EN Configures whether or not to enable header checksum validation when UHCI receives a data packet.

- 0: Disable
- 1: Enable

(R/W)

UHCI\_CHECK\_SEQ\_EN Configures whether or not to enable the sequence number check when UHCI receives a data packet.

- 0: Disable
- 1: Enable

(R/W)

UHCI\_CRC\_DISABLE Configures whether or not to enable CRC calculation.

- 0: Disable
- 1: Enable

Valid only when the Data Integrity Check Present bit in UHCI packet is 1.

(R/W)

UHCI\_SAVE\_HEAD Configures whether or not to save the packet header when UHCI receives a data packet.

- 0: Not save
- 1: Save

(R/W)

UHCI\_TX\_CHECK\_SUM\_RE Configures whether or not to encode the data packet with a checksum.

- 0: Not use checksum
- 1: Use checksum

(R/W)

- UHCI\_TX\_ACK\_NUM\_RE Configures whether or not to encode the data packet with an acknowl-

edgment when a reliable packet is to be transmitted.

- 0: Not use acknowledgement
- 1: Use acknowledgement

(R/W)

Continued on the next page...

## Register 27.71. UHCI\_CONF1\_REG (0x0014)

## Continued from the previous page...

- UHCI\_WAIT\_SW\_START Configures whether or not to put the UHCI encoder state machine to

ST\_SW\_WAIT state.

- 0: No
- 1: Yes

(R/W)

- UHCI\_SW\_START Configures whether or not to send data packets when the encoder state machine is in ST\_SW\_WAIT state.
- 0: Not send
- 1: Send
- (R/W/SC)

## Register 27.72. UHCI\_ESCAPE\_CONF\_REG (0x0020)

![Image](images/27_Chapter_27_img083_fe5dd315.png)

UHCI\_TX\_C0\_ESC\_EN Configures whether or not to decode character 0xC0 when DMA receives data.

0: Not decode

1: Decode

(R/W)

UHCI\_TX\_DB\_ESC\_EN Configures whether or not to decode character 0xDB when DMA receives data.

0: Not decode

1: Decode

(R/W)

- UHCI\_TX\_11\_ESC\_EN Configures whether or not to decode flow control character 0x11 when DMA receives data.

0: Not decode

1: Decode

(R/W)

- UHCI\_TX\_13\_ESC\_EN Configures whether or not to decode flow control character 0x13 when DMA receives data.
- 0: Not decode

1: Decode

(R/W)

- UHCI\_RX\_C0\_ESC\_EN Configures whether or not to replace 0xC0 by special characters when DMA

sends data.

- 0: Not replace
- 1: Replace

(R/W)

- UHCI\_RX\_DB\_ESC\_EN Configures whether or not to replace 0xDB by special characters when DMA

sends data.

- 0: Not replace
- 1: Replace

(R/W)

Continued on the next page...

## Register 27.72. UHCI\_ESCAPE\_CONF\_REG (0x0020)

## Continued from the previous page...

UHCI\_RX\_11\_ESC\_EN Configures whether or not to replace flow control character 0x11 by special characters when DMA sends data.

- 0: Not replace
- 1: Replace

(R/W)

- UHCI\_RX\_13\_ESC\_EN Configures whether or not to replace flow control character 0x13 by special characters when DMA sends data.
- 0: Not replace
- 1: Replace

(R/W)

ESP32-C6 TRM (Version 1.1)

## Register 27.73. UHCI\_HUNG\_CONF\_REG (0x0024)

![Image](images/27_Chapter_27_img084_13cf0490.png)

UHCI\_TXFIFO\_TIMEOUT Configures the timeout value for DMA data reception.

Measurement unit: ms. (R/W)

UHCI\_TXFIFO\_TIMEOUT\_SHIFT Configures the upper limit of the timeout counter for TX FIFO. (R/W)

UHCI\_TXFIFO\_TIMEOUT\_ENA Configures whether or not to enable the data reception timeout for

TX FIFO.

0: Disable

1: Enable

(R/W)

UHCI\_RXFIFO\_TIMEOUT Configures the timeout value for DMA to read data from RAM.

Measurement unit: ms. (R/W)

UHCI\_RXFIFO\_TIMEOUT\_SHIFT Configures the upper limit of the timeout counter for RX FIFO. (R/W)

UHCI\_RXFIFO\_TIMEOUT\_ENA Configures whether or not to enable the DMA data transmission time- out.

0: Disable

1: Enable

(R/W)

## Register 27.74. UHCI\_ACK\_NUM\_REG (0x0028)

![Image](images/27_Chapter_27_img085_d362302f.png)

UHCI\_ACK\_NUM Configures the number of acknowledgements used in software flow control. (R/W)

UHCI\_ACK\_NUM\_LOAD Configures whether or not load acknowledgements.

- 0: Not load
- 1: Load

(WT)

## Register 27.75. UHCI\_QUICK\_SENT\_REG (0x0030)

![Image](images/27_Chapter_27_img086_30210296.png)

UHCI\_SINGLE\_SEND\_NUM Configures the source of data to be transmitted in single\_send mode.

- 0: Q0 register
- 1: Q1 register
- 2: Q2 register
- 3: Q3 register
- 4: Q4 register
- 5: Q5 register
- 6: Q6 register
- 7: Invalid. No effect
- (R/W)

UHCI\_SINGLE\_SEND\_EN Configures whether or not to enable single\_send mode.

- 0: Disable
- 1: Enable

(R/W/SC)

UHCI\_ALWAYS\_SEND\_NUM Configures the source of data to be transmitted in always\_send mode.

- 0: Q0 register
- 1: Q1 register
- 2: Q2 register
- 3: Q3 register
- 4: Q4 register
- 5: Q5 register
- 6: Q6 register
- 7: Invalid. No effect
- (R/W)

UHCI\_ALWAYS\_SEND\_EN Configures whether or not to enable always\_send mode.

- 0: Disable
- 1: Enable

(R/W)

![Image](images/27_Chapter_27_img087_80856620.png)

![Image](images/27_Chapter_27_img088_3353e8c3.png)

![Image](images/27_Chapter_27_img089_f7f2611d.png)

UHCI\_SEND\_Q4\_WORD0 Data to be transmitted in Q4 register. (R/W)

![Image](images/27_Chapter_27_img090_2a640172.png)

UHCI\_SEND\_Q5\_WORD1 Data to be transmitted in Q5 register. (R/W)

## Register 27.88. UHCI\_REG\_Q6\_WORD0\_REG (0x0064)

![Image](images/27_Chapter_27_img091_72d66b3d.png)

UHCI\_SEND\_Q6\_WORD0 Data to be transmitted in Q6 register. (R/W)

## Register 27.89. UHCI\_REG\_Q6\_WORD1\_REG (0x0068)

![Image](images/27_Chapter_27_img092_74ea53ae.png)

UHCI\_SEND\_Q6\_WORD1 Data to be transmitted in Q6 register. (R/W)

## Register 27.90. UHCI\_ESC\_CONF0\_REG (0x006C)

![Image](images/27_Chapter_27_img093_1f2619be.png)

- UHCI\_SEPER\_CHAR Configures separators to encode data packets. The default value is 0xC0. (R/W)

UHCI\_SEPER\_ESC\_CHAR0 Configures the first character of SLIP escape sequence. The default value is 0xDB. (R/W)

UHCI\_SEPER\_ESC\_CHAR1 Configures the second character of SLIP escape sequence. The default value is 0xDC. (R/W)

## Register 27.91. UHCI\_ESC\_CONF1\_REG (0x0070)

![Image](images/27_Chapter_27_img094_7dd50539.png)

- UHCI\_ESC\_SEQ0 Configures the character that needs to be encoded. The default value is 0xDB used as the first character of SLIP escape sequence. (R/W)
- UHCI\_ESC\_SEQ0\_CHAR0 Configures the first character of SLIP escape sequence. The default value is 0xDB. (R/W)
- UHCI\_ESC\_SEQ0\_CHAR1 Configures the second character of SLIP escape sequence. The default value is 0xDD. (R/W)

## Register 27.92. UHCI\_ESC\_CONF2\_REG (0x0074)

![Image](images/27_Chapter_27_img095_f1c7d849.png)

- UHCI\_ESC\_SEQ1 Configures a character that need to be encoded. The default value is 0x11 used as a flow control character. (R/W)
- UHCI\_ESC\_SEQ1\_CHAR0 Configures the first character of SLIP escape sequence. The default value is 0xDB. (R/W)
- UHCI\_ESC\_SEQ1\_CHAR1 Configures the second character of SLIP escape sequence. The default value is 0xDE. (R/W)

![Image](images/27_Chapter_27_img096_ddbe0855.png)

## Register 27.93. UHCI\_ESC\_CONF3\_REG (0x0078)

![Image](images/27_Chapter_27_img097_5bc0ee3b.png)

- UHCI\_ESC\_SEQ2 Configures the character that needs to be decoded. The default value is 0x13 used as a flow control character. (R/W)

UHCI\_ESC\_SEQ2\_CHAR0 Configures the first character of SLIP escape sequence. The default value is 0xDB. (R/W)

UHCI\_ESC\_SEQ2\_CHAR1 Configures the second character of SLIP escape sequence. The default value is 0xDF. (R/W)

## Register 27.94. UHCI\_PKT\_THRES\_REG (0x007C)

![Image](images/27_Chapter_27_img098_30681a94.png)

UHCI\_PKT\_THRS Configures the maximum value of the packet length.

Measurement unit: byte.

Valid only when UHCI\_HEAD\_EN is 0. (R/W)

## Register 27.95. UHCI\_INT\_RAW\_REG (0x0004)

![Image](images/27_Chapter_27_img099_d7d6b654.png)

UHCI\_RX\_START\_INT\_RAW The raw interrupt status of UHCI\_RX\_START\_INT. (R/WTC/SS) UHCI\_TX\_START\_INT\_RAW The raw interrupt status of UHCI\_TX\_START\_INT. (R/WTC/SS) UHCI\_RX\_HUNG\_INT\_RAW The raw interrupt status of UHCI\_RX\_HUNG\_INT. (R/WTC/SS) UHCI\_TX\_HUNG\_INT\_RAW The raw interrupt status of UHCI\_TX\_HUNG\_INT. (R/WTC/SS)

UHCI\_SEND\_S\_REG\_Q\_INT\_RAW The raw interrupt status of UHCI\_SEND\_S\_REG\_Q\_INT. (R/WTC/SS)

UHCI\_SEND\_A\_REG\_Q\_INT\_RAW The raw interrupt status of UHCI\_SEND\_A\_REG\_Q\_INT. (R/WTC/SS)

UHCI\_OUT\_EOF\_INT\_RAW The raw interrupt status of UHCI\_OUT\_EOF\_INT. (R/WTC/SS)

UHCI\_APP\_CTRL0\_INT\_RAW The raw interrupt status of UHCI\_APP\_CTRL0\_INT. (R/W)

UHCI\_APP\_CTRL1\_INT\_RAW The raw interrupt status of UHCI\_APP\_CTRL1\_INT. (R/W)

## Register 27.96. UHCI\_INT\_ST\_REG (0x0008)

![Image](images/27_Chapter_27_img100_5f03a500.png)

UHCI\_RX\_START\_INT\_ST The masked interrupt status of UHCI\_RX\_START\_INT. (RO)

UHCI\_TX\_START\_INT\_ST The masked interrupt status of UHCI\_TX\_START\_INT. (RO)

UHCI\_RX\_HUNG\_INT\_ST The masked interrupt status of UHCI\_RX\_HUNG\_INT. (RO)

UHCI\_TX\_HUNG\_INT\_ST The masked interrupt status of UHCI\_TX\_HUNG\_INT. (RO)

UHCI\_SEND\_S\_REG\_Q\_INT\_ST The masked interrupt status of UHCI\_SEND\_S\_REG\_Q\_INT. (RO)

UHCI\_SEND\_A\_REG\_Q\_INT\_ST The masked interrupt status of UHCI\_SEND\_A\_REG\_Q\_INT. (RO)

UHCI\_OUTLINK\_EOF\_ERR\_INT\_ST The masked interrupt status of UHCI\_OUTLINK\_EOF\_ERR\_INT. (RO)

UHCI\_APP\_CTRL0\_INT\_ST The masked interrupt status of UHCI\_APP\_CTRL0\_INT. (RO)

UHCI\_APP\_CTRL1\_INT\_ST The masked interrupt status of UHCI\_APP\_CTRL1\_INT. (RO)

## Register 27.97. UHCI\_INT\_ENA\_REG (0x000C)

![Image](images/27_Chapter_27_img101_4d182c20.png)

## Register 27.98. UHCI\_INT\_CLR\_REG (0x0010)

![Image](images/27_Chapter_27_img102_125fc094.png)

UHCI\_RX\_START\_INT\_CLR Write 1 to clear UHCI\_RX\_START\_INT. (WT) UHCI\_TX\_START\_INT\_CLR Write 1 to clear UHCI\_TX\_START\_INT. (WT) UHCI\_RX\_HUNG\_INT\_CLR Write 1 to clear UHCI\_RX\_HUNG\_INT. (WT) UHCI\_TX\_HUNG\_INT\_CLR Write 1 to clear UHCI\_TX\_HUNG\_INT. (WT) UHCI\_SEND\_S\_REG\_Q\_INT\_CLR Write 1 to clear UHCI\_SEND\_S\_REG\_Q\_INT. (WT) UHCI\_SEND\_A\_REG\_Q\_INT\_CLR Write 1 to clear UHCI\_SEND\_A\_REG\_Q\_INT. (WT) UHCI\_OUTLINK\_EOF\_ERR\_INT\_CLR Write 1 to clear UHCI\_OUTLINK\_EOF\_ERR\_INT. (WT) UHCI\_APP\_CTRL0\_INT\_CLR Write 1 to clear UHCI\_APP\_CTRL0\_INT. (WT)

UHCI\_APP\_CTRL1\_INT\_CLR Write 1 to clear UHCI\_APP\_CTRL1\_INT. (WT)

## Register 27.99. UHCI\_STATE0\_REG (0x0018)

![Image](images/27_Chapter_27_img103_b5f6b65e.png)

UHCI\_RX\_ERR\_CAUSE Represents the error type when DMA has received a packet with error.

- 0: Invalid. No effect
- 1: Checksum error in the HCI packet
- 2: Sequence number error in the HCI packet
- 3: CRC bit error in the HCI packet
- 4: 0xC0 is found but the received HCI packet is not complete 5: 0xC0 is not found when the
- HCI packet has been received
- 6: CRC check error
- 7: Invalid. No effect

(RO)

UHCI\_DECODE\_STATE Represents the UHCI decoder status. (RO)

## Register 27.100. UHCI\_STATE1\_REG (0x001C)

![Image](images/27_Chapter_27_img104_a13cb402.png)

UHCI\_ENCODE\_STATE Represents the UHCI encoder status. (RO)

## Register 27.101. UHCI\_RX\_HEAD\_REG (0x002C)

![Image](images/27_Chapter_27_img105_2f3e2861.png)

UHCI\_RX\_HEAD Represents the header of the current received packet. (RO)

31

## Register 27.102. UHCI\_DATE\_REG (0x0080)

![Image](images/27_Chapter_27_img106_08ae24e0.png)

0x2007170

UHCI\_DATE Version control register. (R/W)

0

Reset
