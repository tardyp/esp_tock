---
chapter: 38
title: "Chapter 38"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 38

## Parallel IO Controller (PARL\_IO)

## 38.1 Introduction

ESP32-C6 contains a Parallel IO controller (PARLIO) capable of transferring data between external devices and internal memory on a parallel bus through GDMA. It is composed of a TX unit and an RX unit, which are fixed as a transmitter and a receiver respectively. With the two units combined, PARLIO achieves full-duplex communication.

Due to its flexibility, PARLIO can function as a general interface to connect various peripherals. For example, with SPI as the master device and PARLIO as the slave device, a peer-to-peer transfer can be achieved. For detailed application examples, refer to Section 38.7 .

## 38.2 Glossary

This section covers terminology used to describe the functionality of PARLIO.

| RX unit            | Module in PARLIO responsible for receiving data from external par allel bus and storing them into internal memory.                                                                               |
|--------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| TX unit            | Module in PARLIO responsible for transmitting data from internal memory to external parallel bus.                                                                                                 |
| RXD                | Parallel data received from the IO interface of the RX unit.                                                                                                                                      |
| TXD                | Parallel data sent from the IO interface of the TX unit.                                                                                                                                          |
| Frame              | Transferred data unit from the moment the START signal is set to the moment the End of Frame (EOF) signal is received.                                                                            |
| Free-running clock | Clock that toggles continuously. Otherwise, the clock only tog gles during the period when valid data is received and remains constant for the rest of the time.                                 |
| GDMA SUC EOF       | Signal that indicates GDMA successful end of frame. When GDMA receives this signal, a GDMA interrupt will be triggered, indicating that the current frame is correct and the receive is finished. |
| GDMA ERR EOF       | Signal that indicates GDMA error end of frame. When GDMA re ceives this signal, a GDMA interrupt will be triggered, indicating that the current frame has error and the receive is finished.     |
| CDC                | Clock domain crossing.                                                                                                                                                                            |

## 38.3 Features

The PARLIO module has the following main features:

- Variety of clock sources:
- – Including external IO clock PAD\_CLK and internal system clocks XTAL\_CLK, PLL\_F240M\_CLK, and RC\_FAST\_CLK
- – Maximum clock frequency of 40 MHz
- – Integer clock frequency division
- 1/2/4/8/16-bit configurable data bus width
- Half-duplex communication with 16-bit data bus width and full-duplex communication with 8-bit data bus width
- Bit reordering in 1/2/4-bit data bus width mode
- RX unit for receiving IO parallel data, which supports:
- – RX unit input clock inverse
- – Variety of receive modes
- – Configurable GDMA SUC EOF generation
- – Configurable IO pin of external enable signal
- TX unit for sending IO parallel data, which supports:
- – TX unit output clock inverse
- – Valid signal output
- – Configurable bus idle value

## 38.4 Architectural Overview

Figure 38.4-1. PARLIO Architecture

![Image](images/38_Chapter_38_img001_3829b6ad.png)

Figure 38.4-1 shows the architecture of PARLIO. In addition to the RX unit and the TX unit, a group of status configuration registers is also included.

The RX unit converts RXD into an asynchronous FIFO interface, which synchronizes RXD to the AHB clock domain. RXD is then converted to a standard GDMA interface and sent to the internal memory.

The TX unit fetches data from internal memory through GDMA and converts the GDMA interface into an asynchronous FIFO interface. The asynchronous FIFO synchronizes the data to the TX Core clock domain and converts the data to TXD for parallel IO bus output.

## 38.5 Functional Description

## 38.5.1 Clock Generator

There are four input clock domains in PARLIO, namely, RX Core, TX Core, AHB, and APB.

The status configuration register group works in the APB clock domain.

The GDMA interface logic works in the AHB clock domain.

RX Core and TX Core clock domains each have four clock sources for selection, i.e., the internal system clock sources XTAL\_CLK, RC\_FAST\_CLK, PLL\_F240M\_CLK, and the external clock source (PAD\_CLK\_TX/RX), as shown in Figure 38.5-1. Clock sources can be selected by configuring PCR\_PARL\_CLK\_RX\_SEL and

PCR\_PARL\_CLK\_TX\_SEL. The clock can be divided by configuring PCR\_PARL\_CLK\_RX\_DIV\_NUM and PCR\_PARL\_CLK\_TX\_DIV\_NUM. The clock division factor can be configured up to (2 16 − 1) .

The input clock of the RX unit can be inverted. The operating clock of the TX unit can also be inverted before being output to IO.

Figure 38.5-1. PARLIO Clock Generation

![Image](images/38_Chapter_38_img002_97ed4303.png)

## 38.5.2 Clock &amp; Reset Restriction

Due to the versatility of PARLIO, the PAD clocks of PARLIO may come from different masters (external devices or internal clock sources). These clocks might be either free-running clock or not. If the clock is not free-running, some internal control signals of PARLIO cannot process CDC, so there are certain restrictions during the operation.

1. During the reset of the asynchronous FIFO, it takes two clock cycles to synchronize within AHB clock domain and Core clock domain. Therefore, if the reset of AHB clock domain is performed with a clock that is not free-running, the reset synchronization must be performed two clock cycles in advance. The specific operation is as follows:
- Scenario 1: The current frame transfer is based on free-running clock, but the next frame transfer is not based on free-running clock.
3. Operation: Users can reset the next frame transfer before switching to the clock that is not free-running. After the reset is completed, users can switch the clock.
- Scenario 2: The current frame transfer is not based on free-running clock, but the next frame transfer is based on free-running clock.
5. Operation: The next frame can be reset freely. Users only need to ensure that there is an interval of two clock cycles between the reset and the start of the transfer.
- Scenario 3: Both the current and next frame transfers are not based on free-running clock. Operation: If the next frame transfer needs to be reset, users need to first switch to the internal free-running clock, and then switch to the actual clock after the reset is completed.
2. Due to the restrictions caused by a clock that is not free-running, PARL\_IO\_RX\_START and

![Image](images/38_Chapter_38_img003_615ac42a.png)

PARL\_IO\_TX\_START cannot perform CDC processing. Therefore, it is necessary to wait until PARL\_IO\_RX\_START and PARL\_IO\_TX\_START are stable before starting the data transfer, otherwise the transfer might enter a metastable state.

Here are the specific operation steps in the RX unit:

- Clear PCR\_PARL\_CLK\_RX\_EN to turn off RX Core clock domain;
- Write 1 to PARL\_IO\_RX\_START;
- Set PCR\_PARL\_CLK\_RX\_EN to turn on RX Core clock domain;
- Operate the external device to start sending data;
- Clear PCR\_PARL\_CLK\_RX\_EN to turn off RX Core clock domain;
- Write 0 to PARL\_IO\_RX\_START .

Here are the specific operation steps in the TX unit:

- Clear PCR\_PARL\_CLK\_TX\_EN to turn off TX Core clock domain;
- Write 1 to PARL\_IO\_TX\_START;
- Set PCR\_PARL\_CLK\_TX\_EN to turn on TX Core clock domain;
- Operate the external device to start receiving data;
- Clear PCR\_PARL\_CLK\_TX\_EN to turn off TX Core clock domain;
- Write 0 to PARL\_IO\_TX\_START .
3. Reset should follow the requirements below:
- The clock reset during the chip start-up should follow the sequence below:
- – First reset APB clock domain;
- – Then reset AHB clock domain;
- – Finally reset Core clock domain.
- Inter-frame transfer requires Core clock domain reset and async FIFO reset.

## 38.5.3 Master-Slave Mode

The TX unit can function as both master and slave while the RX unit can only function as slave.

When the TX unit serves as master, it is necessary to set the internal free-running clock as the clock source.

The TX unit drives TXD on the rising edge of the clock.

When the TX unit functions as a slave device, there are three scenarios:

- Scenario 1: The clock sent by the master device is a free-running clock. Requirement: There is no requirement for the acquisition edge of the master clock.
- Scenario 2: The clock sent by the master device is not a free-running clock, and the clock waveform is as shown in Figure 38.5-2 .

Requirement: The master clock should capture TXD at the falling edge.

Figure 38.5-2. Master Clock Positive Waveform

![Image](images/38_Chapter_38_img004_5d8f5a4a.png)

- Scenario 3: The clock sent by the master device is not a free-running clock, and the clock waveform is as shown in Figure 38.5-3 .

Requirement: The master device should invert the original clock and convert it to the waveform as Figure 38.5-2 shows before output.

Figure 38.5-3. Master Clock Negative Waveform

![Image](images/38_Chapter_38_img005_3dd34551.png)

For the RX unit which can only function as slave, the following three scenarios can occur:

- Scenario 1: The clock sent by the master device is a free-running clock.
- Requirement: There is no requirement for the acquisition edge of the master clock, and the valid data is subject to the external enable signal.
- Scenario 2: The clock sent by the master device is not a free-running clock, and the clock waveform is as shown in Figure 38.5-2 .
- Requirement: It is required for the master device to drive the data at the rising edge and the RX unit to capture the data at the falling edge (i.e., to inverse the master clock).
- Scenario 3: The clock sent by the master device is not a free-running clock, and the clock waveform is as shown in Figure 38.5-3 .
- Requirement: It is required for the master device to drive the data at the falling edge and the RX unit to capture the data at the rising edge (i.e., to use the original master clock).

## 38.5.4 Receive Modes of the RX Unit

PARLIO supports 15 receive modes, which can be divided into three major categories according to the enable signal:

- Level Enable mode: data received is enabled by the external signal level;
- Pulse Enable mode: data received is enabled by the external signal pulse;
- Software Enable mode: the enable signal of data received can be configured by users directly.

## 38.5.4.1 Level Enable Mode

Level Enable mode can be divided into two sub-modes depending on the active level of the external enable signal, as shown in Figure 38.5-4 .

In both cases, an active level on the external enable signal must be aligned with valid data. Since the external level enable signal occupies one IO pin, there are at most 15 IO pins left usable for RXD.

Figure 38.5-4. Sub-Modes of Level Enable Mode for RX Unit

![Image](images/38_Chapter_38_img006_2ab56001.png)

| Mode         | Sub-mode   | Description      |
|--------------|------------|------------------|
| LEVEL_ENABLE | sub-mode 1 | Valid data       |
| LEVEL_ENABLE | sub-mode 1 | signal level low |
| LEVEL_ENABLE | sub-mode 2 | Valid data       |

## 38.5.4.2 Pulse Enable Mode

Pulse Enable mode can be divided into 12 sub-modes depending on the pulse active level and its alignment with valid data. For detailed classification, see Figure 38.5-5 .

Sub-modes 1 ~ 8 all contain start pulse and end pulse. The difference lies in whether start pulse and end pulse are aligned with valid data.

Sub-modes 9 ~ 12 only contain start pulse and the end of valid data is signaled by configuring PARL\_IO\_RX\_DATA\_BYTELEN .

Since the external pulse enable signal occupies one IO pin, there are at most 15 IO pins left usable for RXD. However, in sub-modes 4, 8, 10, and 12, as the data is considered valid before the pulse's first edge and after the pulse's last edge, the enable signal IO pin can serve as a data IO pin at the same time. Therefore, there are 16 IO pins usable for RXD in these sub-modes.

Figure 38.5-5. Sub-Modes of Pulse Enable Mode for RX Unit

![Image](images/38_Chapter_38_img007_fdedc214.png)

## 38.5.4.3 Software Enable Mode

The enable signal in Software Enable mode is determined by the internal configuration register. If users switch to this mode, the receive will only be activated when both PARL\_IO\_RX\_SW\_EN and PARL\_IO\_RX\_START are set to 1.

Since the enable signal does not occupy IO pins on the interface, there are at most 16 IO pins usable by the RXD. Due to the differences of clock domains, the enable signal cannot be aligned with valid data. Thus, the validity of data needs to be identified by the valid clock edge. In this case, the RX Core clock needs to be aligned with valid data.

Figure 38.5-6. Sub-Mode of Software Enable Mode for RX Unit

| Mode      | Sub-mode   | Description   |
|-----------|------------|---------------|
| SW_ENABLE | /          | / Valid data  |

## 38.5.5 RX Unit GDMA SUC EOF Generation

The RX unit generates a GDMA SUC EOF signal to indicate the end of current frame transfer and send it to the GDMA interface. GDMA SUC EOF can be generated by an external enable signal or by the internally configured byte length.

- When GDMA SUC EOF is generated by the internally configured byte length, there is no restriction on the receive mode selection. However, PARL\_IO\_RX\_DATA\_BYTELEN must be configured. If the configured value of PARL\_IO\_RX\_DATA\_BYTELEN is less than the actual received data, the GDMA SUC EOF will be triggered in advance. In this case, the RX unit stops reading data from the FIFO, but the FIFO continues to receive external data until an RX\_FIFO\_WFULL\_INTR interrupt is triggered.
- When GDMA SUC EOF is generated by the external enable signal, only sub-modes 1, 3, 5, and 7 of Pulse Enable mode can be selected. In this mode, the transfer is not affected by the value of PARL\_IO\_RX\_DATA\_BYTELEN, and the transferred data of the frame is not limited.

## 38.5.6 RX Unit Timeout

The RX unit supports the receive timeout. When the timeout is triggered, a GDMA ERR EOF signal will be generated and sent to the GDMA interface to indicate the end of the receiving. Configure PARL\_IO\_RX\_TIMEOUT\_THRESHOLD to set the timeout threshold.

The timeout function is enabled by default and can be disabled by users. The upper threshold of the configurable timeout is (2 16 − 1) cycles of AHB clock domain, and the lower threshold depends on the relative frequency relationship between AHB clock domain and RX Core clock domain. It is recommended to set a relatively large value for PARL\_IO\_RX\_TIMEOUT\_THRESHOLD to avoid undesired GDMA ERR EOF signals.

## 38.5.7 Valid Signal Output of TX Unit

The TX unit can generate a valid signal aligned with TXD. Configure PARL\_IO\_TX\_HW\_VALID\_EN to choose whether to output it to TXD. The polarity of the valid signal is fixed to active high.

The valid output function is disabled by default. When enabled, the output valid signal occupies the MSB of the TXD, which means that no matter what the original value is, the 15th bit of TXD remains high and is output as the valid signal. However, the valid signal pin does not affect the bus width configuration. For example, if user configures data bus width as 1 bit, the valid output function can still be enabled with a fixed pin as TXD[15] while the data pin is TXD[0].

## 38.5.8 Bus Idle Value of TX Unit

The TX unit is regarded as in idle state when it is not transmitting data. It supports a configurable bus idle value.

The bus idle value is 0x0 by default, and its maximum configurable value is 0xFFFF. Note that the configured idle value should not conflict with other enabled functions. For example, when the MSB of TXD is used as the valid signal, users should avoid configuring the MSB of the idle value as 1.

## 38.5.9 Data Transfer in a Single Frame

The RX unit and the TX unit are transferred in the unit of bytes, i.e., a single frame transfers 1 byte of data at least.

When the RX unit generates GDMA EOF signals through byte length, the maximum length of the single-frame transmission is (2 16 − 1) bytes. When the RX unit generates GDMA EOF signals through the enable signal from an external device, there is no limit to the amount of bytes of the single-frame transmission.

The TX unit only generates GDMA EOF signals through byte length, so the maximum length of a single frame transmission is (2 16 − 1) bytes.

When the configured data bus width is 16 bit, the byte length must be configured as a multiple of 2 bytes.

Normally, PARLIO can perform full-duplex transfer. But when in 16-bit bus width mode, PARAIO can only perform half-duplex transfer due to the limitation of the IO numbers.

## 38.5.10 Bit Reordering in One Byte

The sequence of data within one byte can be reversed. Taking the RX unit as an example, when the configured bus width is 2 bit, the data needs to be packed into one byte before being written into the RX FIFO.

Presume that the original bit sequence is:

<!-- formula-not-decoded -->

If the bit reordering function is enabled, the sequence will be reordered to:

<!-- formula-not-decoded -->

## 38.6 Programming Procedures

## 38.6.1 Data Receiving Operation Process

This section introduces the programming procedure for receiving data in the RX unit. Perform the following procedure to receive parallel data from IO pins connected to external devices to be stored in the internal memory. For detailed description of the clock and reset operation restrictions in the RX unit, refer to Section 38.5.2 .

1. Reset the RX unit. For specific reset scenarios and sequences, refer to Section 38.5.2 .
2. Set PARL\_IO\_RX\_FIFO\_WFULL\_INT\_CLR and PARL\_IO\_RX\_FIFO\_WFULL\_INT\_ENA .
3. Select the RXD IO pins. If a PAD clock is used, the clock IO pin also needs to be configured.
4. Select the clock source and divide the clock by configuring PCR registers.
5. Turn off the clock of RX Core clock domain.

6. Select the receive mode and enable functions required as described in Sections 38.3 and 38.5 .
7. Configure GDMA inlink list.
8. Set PARL\_IO\_RX\_REG\_UPDATE to synchronize the register signals.
9. Set PARL\_IO\_RX\_START .
10. Turn on the clock of RX Core clock domain.
11. Operate the external device to start sending data.
12. Poll the GDMA SUC EOF interrupt.
13. Clear the GDMA SUC EOF interrupt.
14. Turn off the clock of RX Core clock domain.
15. Clear PARL\_IO\_RX\_START .

## 38.6.2 Data Transmitting Operation Process

This section introduces the programming procedure for transmitting data in the TX unit. Perform the following procedure to transmit parallel data from internal memory to the IO pins connected to external devices. For detailed description of the clock and reset operation restrictions in the TX unit, refer to Section 38.5.2 .

1. Reset the TX unit. For specific reset scenarios and sequences, refer to Section 38.5.2 .
2. Set PARL\_IO\_TX\_FIFO\_REMPTY\_INT\_CLR , PARL\_IO\_TX\_EOF\_INT\_CLR , PARL\_IO\_TX\_FIFO\_REMPTY\_INT\_ENA, and PARL\_IO\_TX\_EOF\_INT\_ENA consecutively.
3. Select the TXD IO pins. If a PAD clock is used, the clock IO PAD also needs to be configured.
4. Select the clock source and divide the clock by configuring PCR registers.
5. Turn off the clock of TX Core clock domain.
6. Select the functions required as described in Section 38.5 .
7. Configure GDMA outlink list.
8. Poll the PARL\_IO\_TX\_READY .
9. Set PARL\_IO\_TX\_START .
10. Turn on the clock of TX Core clock domain.
11. Operate the external device to start receiving data.
12. Poll the PARL\_IO\_TX\_EOF\_INT\_ST .
13. Set PARL\_IO\_TX\_EOF\_INT\_CLR .
14. Turn off the clock of TX Core clock domain.
15. Clear PARL\_IO\_TX\_START .

## 38.7 Application Examples

This section introduces some PARLIO application examples and their detailed operation process. All peripherals used in the examples are from ESP series chips and can work with PARLIO to form a complete data path.

## Note:

The data paths constructed in the examples may not be the optimal. For example, users can use the SPI peripherals on two identical ESP chips to complete the peer-to-peer transfer in real case instead of using PARLIO to work with SPI. However, these examples demonstrate the flexibility of the PARLIO interface to a certain extent.

## 38.7.1 Co-working with SPI

In this example, external SPI sends data as a master device and PARLIO RX unit receives data as a slave device, and at the same time, PARLIO TX sends data as a master device and SPI receives data as a slave device, thus achieving a peer-to-peer serial data transfer.

- Follow the operation process below to achieve SPI transmit and PARLIO receive:
- – Configure SPI clock.
- – Configure SPI as the master device.
- – Configure signal pins. Connect FSPICLK to PAD\_CLK\_RX, FSPICS0 to RXD[16], and FSPID to RXD[0].
- – Write the data sent into the SPI buffer and configure the bit length of the data sent.
- – Set SPI\_UPDATE to update the configured register value.
- – Reset PARLIO RX unit.
- – Configure PARLIO RX unit clock.
- – Turn off the PARLIO RX Core clock domain.
- – Configure PARLIO receive mode as sub-mode 1 of Level Enable mode. Configure RX unit data bus width as 1 bit. Configure PARL\_IO\_RX\_DATA\_BYTELEN according to the sending length of SPI. Set PARL\_IO\_RX\_REG\_UPDATE .
- – Configure PARLIO GDMA inlink list.
- – Set PARL\_IO\_RX\_START .
- – Turn on the PARLIO RX Core clock domain.
- – Set SPI\_USR to start transmitting data of SPI.
- – Poll GDMA SUC EOF interrupt.
- – Clear PARL\_IO\_RX\_START .
- Follow the operation process below to achieve PARLIO transmit and SPI receive:
- – Configure SPI clock.
- – Configure SPI as the slave device.

- – Configure signal pins. Connect FSPICLK to PAD\_CLK\_TX, FSPICS0 to TXD[16], and FSPID to TXD[0].
- – Set SPI\_RD\_BIT\_ORDER to invert the bit order.
- – Set SPI\_UPDATE to update the configured register value.
- – Reset PARLIO TX unit.
- – Set PARL\_IO\_TX\_EOF\_INT\_CLR and PARL\_IO\_TX\_EOF\_INT\_ENA .
- – Configure PARLIO TX unit clock.
- – Turn off the clock of TX Core clock domain.
- – Configure data bus width as 1 bit. Write 1 to PARL\_IO\_TX\_HW\_VALID\_EN. Configure PARL\_IO\_TX\_BYTELEN .
- – Configure GDMA outlink list.
- – Poll PARL\_IO\_TX\_READY .
- – Write 1 to PARL\_IO\_TX\_START .
- – Turn on the clock of TX Core clock domain.
- – Start data transfer.
- – Poll PARL\_IO\_TX\_EOF\_INT\_ST .
- – Set PARL\_IO\_TX\_EOF\_INT\_CLR .
- – Turn off the clock of TX Core clock domain.
- – Clear PARL\_IO\_TX\_START .

## 38.7.2 Co-working with I2S

In this example, external I2S sends data as a master device and PARLIO RX unit receives data as a slave device. PARLIO supports the transmission of the I2S TDM MSB alignment standard and the TDM PCM standard. When the I2S transfer protocol is the TDM MSB alignment standard, it is required to configure the receive mode of PARLIO as Level Enable mode. When the I2S transfer protocol is the TDM PCM standard, it is required to configure the receive mode of PARLIO as the sub-mode 10 of Pulse Enable mode.

This section takes the TDM PCM alignment standard as an example. The specific operation process is as follows:

1. Configure I2S clock.
2. Configure signal pins. Connect I2SO\_BCK\_out to PAD\_CLK\_RX, I2SO\_WS\_out to RXD[16], and I2SO\_Data\_out to RXD[0].
3. Configure I2S as the master device.
4. Configure the I2S TX data mode and channel mode required. Set I2S\_TX\_UPDATE .
5. Reset I2S TX unit and TX FIFO.
6. Enable I2S\_TX\_DONE\_INT .
7. Configure I2S GDMA outlink list.

8. Set I2S\_TX\_STOP\_EN .
9. Reset PARLIO RX unit.
10. Configure PARLIO RX unit clock.
11. Turn off PARLIO RX Core clock domain.
12. Configure PARLIO receive mode as sub-mode 10 of Pulse Enable mode. Configure the RX unit data bus width as 1 bit. Configure PARL\_IO\_RX\_DATA\_BYTELEN according to the length of the data sent by I2S. Set PARL\_IO\_RX\_REG\_UPDATE .
13. Configure PARLIO GDMA inlink list.
14. Set PARL\_IO\_RX\_START .
15. Turn on PARLIO RX Core clock domain.
16. Set I2S\_TX\_START to start transmitting data.
17. Poll I2S\_TX\_DONE\_INT .
18. Poll GDMA SUC EOF interrupt.
19. Clear I2S\_TX\_START .
20. Clear PARL\_IO\_RX\_START .

## 38.7.3 Co-working with LCD

## Note:

ESP32-C6 does not support LCD interface. For detailed descriptions about LCD control register fields mentioned below, please refer to the documentation of corresponding ESP series chips.

In this example, PARLIO TX unit sends data as a master device and external LCD controller receives data as a slave device. The I8080/MOTO6800 format is used. The specific operation process is as follows:

1. Configure signal pins. Connect CLK\_TX\_out to LCD pixel clock PCLK, TXD[7:0] to LCD data input pin, TXD[8] to LCD CS pin, TXD[9] to LCD CD pin.
2. Reset PARLIO TX unit.
3. Set PARL\_IO\_TX\_FIFO\_REMPTY\_INT\_CLR , PARL\_IO\_TX\_EOF\_INT\_CLR , PARL\_IO\_TX\_FIFO\_REMPTY\_INT\_ENA, and PARL\_IO\_TX\_EOF\_INT\_ENA in sequence.
4. Configure PARLIO TX unit clock.
5. Turn off the clock of TX Core clock domain.
6. Configure data bus width as 16 bit. Configure PARL\_IO\_TX\_BYTELEN .
7. Configure GDMA outlink list. Note that the data sent in the linked list should conform to I8080/MOTO6800 format. The lower eight bits are valid parallel data. The 9th and 10th bits are respectively CS, CD. The MSB is the constant 1. The remaining bits are arbitrary values.
8. Poll PARL\_IO\_TX\_READY .
9. Write 1 to PARL\_IO\_TX\_START .

10. Turn on the clock of TX Core clock domain.
11. Start data transfer.
12. Poll PARL\_IO\_TX\_EOF\_INT\_ST .
13. Set PARL\_IO\_TX\_EOF\_INT\_CLR .
14. Turn off the clock of TX Core clock domain.
15. Clear PARL\_IO\_TX\_START .

## 38.8 Interrupts

- TX\_FIFO\_REMPTY\_INT: Triggered when TX FIFO is empty. This interrupt indicates that there might be error in the data sent by TX.
- RX\_FIFO\_WFULL\_INT: Triggered when RX FIFO is full. This interrupt indicates that there might be error in the data received by RX.
- TX\_EOF\_INT: Triggered when TX finishes sending a complete frame of data.

## 38.9 Register Summary

The addresses in this section are relative to Parallel IO Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                                | Description                                         | Address                                             | Access                                              |
|-----------------------------------------------------|-----------------------------------------------------|-----------------------------------------------------|-----------------------------------------------------|
| PARLIO RX Configuration Registers                   | PARLIO RX Configuration Registers                   | PARLIO RX Configuration Registers                   | PARLIO RX Configuration Registers                   |
| PARL_IO_RX_CFG0_REG                                 | PARLIO RX module configuration register 0           | 0x0000                                              | R/W                                                 |
| PARL_IO_RX_CFG1_REG                                 | PARLIO RX module configuration register 1           | 0x0004                                              | varies                                              |
| PARLIO TX Configuration Registers                   | PARLIO TX Configuration Registers                   | PARLIO TX Configuration Registers                   | PARLIO TX Configuration Registers                   |
| PARL_IO_TX_CFG0_REG                                 | PARLIO TX module configuration register 0           | 0x0008                                              | R/W                                                 |
| PARL_IO_TX_CFG1_REG                                 | PARLIO TX module configuration register 1           | 0x000C                                              | R/W                                                 |
| PARLIO TX Status Register                           | PARLIO TX Status Register                           | PARLIO TX Status Register                           | PARLIO TX Status Register                           |
| PARL_IO_ST_REG                                      | PARLIO module status register 0                     | 0x0010                                              | RO                                                  |
| PARLIO Interrupt Configuration and Status Registers | PARLIO Interrupt Configuration and Status Registers | PARLIO Interrupt Configuration and Status Registers | PARLIO Interrupt Configuration and Status Registers |
| PARL_IO_INT_ENA_REG                                 | PARLIO interrupt enable register                    | 0x0014                                              | R/W                                                 |
| PARL_IO_INT_RAW_REG                                 | PARLIO interrupt raw register                       | 0x0018                                              | R/SS/WTC                                            |
| PARL_IO_INT_ST_REG                                  | PARLIO interrupt status register                    | 0x001C                                              | RO                                                  |
| PARL_IO_INT_CLR_REG                                 | PARLIO interrupt clear register                     | 0x0020                                              | WT                                                  |
| PARLIO Clock Gating Configuration Register          | PARLIO Clock Gating Configuration Register          | PARLIO Clock Gating Configuration Register          | PARLIO Clock Gating Configuration Register          |
| PARL_IO_CLK_REG                                     | PARLIO clock configuration register                 | 0x0120                                              | R/W                                                 |
| PARLIO Version Register                             | PARLIO Version Register                             | PARLIO Version Register                             | PARLIO Version Register                             |
| PARL_IO_VERSION_REG                                 | Version control register                            | 0x03FC                                              | R/W                                                 |

## 38.10 Registers

The addresses in this section are relative to Parallel IO Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

## Register 38.1. PARL\_IO\_RX\_CFG0\_REG (0x0000)

![Image](images/38_Chapter_38_img008_077df3ae.png)

PARL\_IO\_RX\_EOF\_GEN\_SEL Configures the generating mechanism of GDMA SUC EOF.

- 0: Generate GDMA SUC EOF by the configured data byte length
- 1: Generate GDMA SUC EOF by the external enable signal

(R/W)

PARL\_IO\_RX\_START Configures whether to start RX global data sampling.

0: No effect

1: Start

(R/W)

PARL\_IO\_RX\_DATA\_BYTELEN Configures data byte length received by RX. (R/W)

PARL\_IO\_RX\_SW\_EN Configures whether to enable software data sampling.

0: Disable

1: Enable

(R/W)

## PARL\_IO\_RX\_PULSE\_SUBMODE\_SEL Configures Pulse Enable sub-mode.

- 0: Positive pulse start (data bit included) &amp; Positive pulse end (data bit included)
- 1: Positive pulse start (data bit included) &amp; Positive pulse end (data bit excluded)
- 2: Positive pulse start (data bit excluded) &amp; Positive pulse end (data bit included)
- 3: Positive pulse start (data bit excluded) &amp; Positive pulse end (data bit excluded)
- 4: Positive pulse start (data bit included) &amp; Length end
- 5: Positive pulse start (data bit excluded) &amp; Length end
- 6: Negative pulse start (data bit included) &amp; Negative pulse end(data bit included)
- 7: Negative pulse start (data bit included) &amp; Negative pulse end (data bit excluded)
- 8: Negative pulse start (data bit excluded) &amp; Negative pulse end (data bit included)
- 9: Negative pulse start (data bit excluded) &amp; Negative pulse end (data bit excluded)
- 10: Negative pulse start (data bit included) &amp; Length end
- 11: Negative pulse start (data bit excluded) &amp; Length end

(R/W)

Continued on the next page...

## Register 38.1. PARL\_IO\_RX\_CFG0\_REG (0x0000)

## Continued from the previous page...

PARL\_IO\_RX\_LEVEL\_SUBMODE\_SEL Configures whether to sample data at high or low level of the external enable signal.

- 0: At high level
- 1: At low level

(R/W)

- PARL\_IO\_RX\_SMP\_MODE\_SEL Configures RX data sampling mode.
- 0: External Level Enable mode
- 1: External Pulse Enable mode
- 2: Internal Software Enable mode

(R/W)

- PARL\_IO\_RX\_CLK\_EDGE\_SEL Configures whether to invert the RX input clock.
- 0: Not invert
- 1: Invert

(R/W)

## PARL\_IO\_RX\_BIT\_PACK\_ORDER Configures the packing order to pack bits into 1 byte when data

bus width is 4/2/1 bit.

- 0: Pack from MSB
- 1: Pack from LSB

(R/W)

- PARL\_IO\_RX\_BUS\_WID\_SEL Configures RX data bus width.
- 0: 16 bit
- 1: 8 bit
- 2: 4 bit
- 3: 2 bit
- 4: 1 bit

(R/W)

- PARL\_IO\_RX\_FIFO\_SRST Configures whether to enable soft reset of async FIFO in the RX unit.
- 0: Disable
- 1: Enable

(R/W)

## Register 38.2. PARL\_IO\_RX\_CFG1\_REG (0x0004)

![Image](images/38_Chapter_38_img009_e5b42ba6.png)

PARL\_IO\_RX\_REG\_UPDATE Configures whether to update RX register configuration signals.

0: No effect

1: Update

(WT)

PARL\_IO\_RX\_TIMEOUT\_EN Configures whether to enable timeout counter to generate GDMA ERR

EOF.

0: Disable

1: Enable

(R/W)

PARL\_IO\_RX\_EXT\_EN\_SEL Configures RX external enable signal from one of the 16 IO pins. (R/W)

PARL\_IO\_RX\_TIMEOUT\_THRESHOLD Configures RX threshold of timeout counter.

Measurement unit: AHB clock cycle

(R/W)

## Register 38.3. PARL\_IO\_TX\_CFG0\_REG (0x0008)

![Image](images/38_Chapter_38_img010_f28a0486.png)

PARL\_IO\_TX\_BYTELEN Configures the byte length of the data sent by TX. (R/W)

PARL\_IO\_TX\_START Configures whether to start TX global data output.

0: No effect

1: Start

(R/W)

PARL\_IO\_TX\_HW\_VALID\_EN Configures whether to enable TX hardware data valid signal.

0: Disable

1: Enable

(R/W)

PARL\_IO\_TX\_SMP\_EDGE\_SEL Configures whether to invert the TX output clock

0: Not invert

1: Invert (R/W)

PARL\_IO\_TX\_BIT\_UNPACK\_ORDER Configures the unpacking order to unpack bits from 1 byte when

data bus width is 4/2/1 bit.

0: Unpack from MSB

1: Unpack from LSB

(R/W)

PARL\_IO\_TX\_BUS\_WID\_SEL Configures TX data bus width.

0: 16 bit

1: 8 bit

2: 4 bit

3: 2 bit

4: 1 bit

(R/W)

Continued on the next page...

## Register 38.3. PARL\_IO\_TX\_CFG0\_REG (0x0008)

## Continued from the previous page...

PARL\_IO\_TX\_FIFO\_SRST Configures whether to enable soft reset of async FIFO in the TX unit.

0: Disable

1: Enable

(R/W)

## Register 38.4. PARL\_IO\_TX\_CFG1\_REG (0x000C)

![Image](images/38_Chapter_38_img011_28693827.png)

PARL\_IO\_TX\_IDLE\_VALUE Configures the data value on TX bus when in idle state. (R/W)

## Register 38.5. PARL\_IO\_ST\_REG (0x0010)

![Image](images/38_Chapter_38_img012_ee1a8213.png)

PARL\_IO\_TX\_READY Represents the status of TX.

0: Not ready

1: Ready

(RO)

![Image](images/38_Chapter_38_img013_05430f6b.png)

Register 38.8. PARL\_IO\_INT\_ST\_REG (0x001C)

![Image](images/38_Chapter_38_img014_5e48c1d9.png)

PARL\_IO\_TX\_FIFO\_REMPTY\_INT\_ST The masked interrupt status of TX\_FIFO\_REMPTY\_INT. (RO) PARL\_IO\_RX\_FIFO\_WFULL\_INT\_ST The masked interrupt status of RX\_FIFO\_WFULL\_INT. (RO) PARL\_IO\_TX\_EOF\_INT\_ST The masked interrupt status of TX\_EOF\_INT. (RO)

Register 38.9. PARL\_IO\_INT\_CLR\_REG (0x0020)

![Image](images/38_Chapter_38_img015_245126ec.png)

PARL\_IO\_TX\_FIFO\_REMPTY\_INT\_CLR Write 1 to clear TX\_FIFO\_REMPTY\_INT. (WT) PARL\_IO\_RX\_FIFO\_WFULL\_INT\_CLR Write 1 to clear RX\_FIFO\_WFULL\_INT. (WT)

PARL\_IO\_TX\_EOF\_INT\_CLR Write 1 to clear TX\_EOF\_INT. (WT)

Submit Documentation Feedback

## Register 38.10. PARL\_IO\_CLK\_REG (0x0120)

![Image](images/38_Chapter_38_img016_a093ca1c.png)

PARL\_IO\_CLK\_EN Configures whether to force clock on for this register file.

0: No effect

1: Force clock on

(R/W)

## Register 38.11. PARL\_IO\_VERSION\_REG (0x03FC)

![Image](images/38_Chapter_38_img017_bbade6d6.png)

PARL\_IO\_DATE Version control register. (R/W)

## Part VI

## Analog Signal Processing

This part describes components related to analog-to-digital conversion, on-chip sensors, and features such as temperature sensing, demonstrating the system's capabilities in handling analog signals.
