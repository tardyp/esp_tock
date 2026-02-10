---
chapter: 29
title: "Chapter 29"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 29

## I2C Controller (I2C)

The I2C (Inter-Integrated Circuit) bus allows ESP32-C6 to communicate with multiple external devices. These external devices can share one I2C bus. ESP32-C6 has two I2C controllers: one in the main system and another one in the low-power system. The I2C controller in the main system can act as a master or a slave (referred to as I2C below). The I2C controller in the low-power system can only act as a master (referred to as LP\_I2C below), and it can still work when the main system sleeps.

## 29.1 Overview

The I2C bus has two lines, namely a serial data line (SDA) and a serial clock line (SCL). Both SDA and SCL lines are open-drain. The I2C bus can be connected to a single or multiple master devices and a single or multiple slave devices. However, only one master device can access a slave at a time via the bus.

The master initiates communication by generating a START condition: pulling the SDA line low while SCL is high. Then it issues nine clock pulses via SCL. The first eight pulses are used to transmit a 7-bit address followed by a read/write (R/W) bit. If the address of an I2C slave matches the 7-bit address transmitted, this matching slave can respond by pulling SDA low on the ninth clock pulse. The master and the slave can send or receive data according to the R/W bit. Whether to terminate the data transfer or not is determined by the logic level of the acknowledge (ACK) bit. During data transfer, SDA changes only when SCL is low. Once the communication has finished, the master sends a STOP condition: pulling SDA up while SCL is high. If a master both reads and writes data in one transfer, then it should send a RSTART condition, a slave address and a R/W bit before changing its operation. The RSTART condition is used to change the transfer direction and the mode of the devices (master mode or slave mode).

## 29.2 Features

The I2C controller of ESP32-C6 has the following features:

- Master mode and slave mode
- Communication between multiple masters and slaves
- Standard mode (100 Kbit/s)
- Fast mode (400 Kbit/s)
- 7-bit addressing and 10-bit addressing
- Continuous data transfer achieved by pulling SCL low in slave mode
- Programmable digital noise filtering
- Dual address mode, which uses slave address and slave memory or register address

## 29.3 I2C Architecture

Figure 29.3-1. I2C Master Architecture

![Image](images/29_Chapter_29_img001_5791203a.png)

Figure 29.3-2. I2C Slave Architecture

![Image](images/29_Chapter_29_img002_af46326a.png)

The I2C controller runs either in master mode or slave mode, which is determined by I2C\_MS\_MODE. Figure 29.3-1 shows the architecture of a master, while Figure 29.3-2 shows that of a slave. The I2C controller has the following main parts:

- Transmit and receive memory (TX/RX RAM): store data to be transmitted and data received respectively.
- Command controller (CMD\_Controller): generate (R)START, STOP, WRITE, READ and END commands

- SCL clock controller (SCL\_FSM): generate the timing sequence conforming to the I2C protocol. Figure 29.3-3 and Figure 29.3-4 are the timing diagram and corresponding parameters of the I2C protocol.
- SDA data controller (SCL\_MAIN\_FSM): control the execution of I2C commands and the data sequence of the SDA line. It also controls the ACK\_deal module to generate the ACK bit and detect the level of the ACK bit on the SDA line.
- Serial/parallel data converter (DATA\_Shifter): shift data between serial and parallel form
- Filter for SCL (SCL\_Filter): remove noises on SCL input signals
- Filter for SDA (SDA\_Filter): remove noises on SDA input signals
- ACK bit controller (ack\_deal): generate the ACK bit and detect the level of the ACK bit on the SDA line under the control of SCL\_MAIN\_FSM.

Besides, the I2C controller also has a clock module which generates I2C clocks, and a synchronization module which synchronizes the APB bus and the I2C controller.

The clock module is used to select clock sources, turn on and off clocks, and divide clocks. The synchronization module synchronizes signal transfer between different clock domains.

![Image](images/29_Chapter_29_img003_02e904f8.png)

Figure 29.3-3. I2C Protocol Timing (Cited from Fig.31 in The I2C-bus specification Version 2.1)

![Image](images/29_Chapter_29_img004_69e71c74.png)

following sections describe the operations of the ESP32-C6 I2C controller. Note that operations may differ

PCR

equation:

| 29.4.1 Clock Configuration                                                                                                                                                                             |
|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Registers, TX RAM, and RX RAM are configured and accessed in the APB_CLK clock domain. The main logic                                                                                                  |
| of the I2C controller, including SCL_FSM, SCL_MAIN_FSM, SCL_FILTER, SDA_FILTER, and DATA_ SHIFTER, are in the I2C_SCLK clock domain.                                                                   |
| You can choose the clock source for 12G_SCLK from XTAL_CLK or RC_FAST_CLK via                                                                                                                          |
| _12G_SCLK_SEL:                                                                                                                                                                                         |
| • Enable the clock source for I2G_SCLK by configuring PCR_I2C_SCLK_EN to 1. • When PCR_I2C_SCLK_SEL is O, the clock source is XTAL_CLK. • When PCR_12C_SCLK_SEL is 1, the clock source is RC_FAST_CLK. |
| The clock source then passes through a fractional divider to generate I2C_SCLK according to the following                                                                                              |

Divisor = PCR\_I2C\_SCLK\_DIV\_NUM + 1 +

PCR\_I2C\_SCLK\_DIV\_B

Figure 29.3-4. I2C Timing Parameters (Cited from Table 5 in The I2C-bus specification Version 2.1)

SCL's frequency.

## 29.4 Functional Description

896

Submit Documentation Feedback

As mentioned above, one or more masters and one or more slaves can be connected on the I2C bus. The following sections describe the operations of the ESP32-C6 I2C controller. Note that operations may differ between the I2C controller in ESP32-C6 and other masters or slaves on the bus. Please refer to datasheets of individual I2C devices for specific information.

## 29.4.1 Clock Configuration

Registers, TX RAM, and RX RAM are configured and accessed in the APB\_CLK clock domain. The main logic of the I2C controller, including SCL\_FSM, SCL\_MAIN\_FSM, SCL\_FILTER, SDA\_FILTER, and DATA\_SHIFTER, are in the I2C\_SCLK clock domain.

You can choose the clock source for I2C\_SCLK from XTAL\_CLK or RC\_FAST\_CLK via PCR\_I2C\_SCLK\_SEL:

- Enable the clock source for I2C\_SCLK by configuring PCR\_I2C\_SCLK\_EN to 1.
- When PCR\_I2C\_SCLK\_SEL is 0, the clock source is XTAL\_CLK.
- When PCR\_I2C\_SCLK\_SEL is 1, the clock source is RC\_FAST\_CLK.

The clock source then passes through a fractional divider to generate I2C\_SCLK according to the following equation:

<!-- formula-not-decoded -->

Limited by timing parameters, the derived clock I2C\_SCLK should operate at a frequency 20 times larger than SCL's frequency.

ESP32-C6 TRM (Version 1.1)

## 29.4.2 SCL and SDA Noise Filtering

SCL\_Filter and SDA\_Filter modules are identical and are used to filter signal noise on SCL and SDA, respectively. These filters can be enabled or disabled by configuring I2C\_SCL\_FILTER\_EN and I2C\_SDA\_FILTER\_EN .

Take SCL\_Filter as an example. When enabled, SCL\_Filter samples input signals on the SCL line continuously. These input signals are valid only if they remain unchanged for consecutive I2C\_SCL\_FILTER\_THRES I2C\_SCLK clock cycles. Given that only valid input signals can pass through the filter, SCL\_Filter can remove glitches whose pulse width is shorter than I2C\_SCL\_FILTER\_THRES I2C\_SCLK clock cycles, while SDA\_Filter can remove glitches whose pulse width is shorter than I2C\_SDA\_FILTER\_THRES I2C\_SCLK clock cycles.

## 29.4.3 SCL Clock Stretching

The I2C controller in slave mode (i.e. slave) can realize the function called clock stretching by holding the SCL line low to suspend data transmission in exchange for more time to process data. This function is enabled by setting the I2C\_SLAVE\_SCL\_STRETCH\_EN bit. The time period to release the SCL line from stretching is configured by setting the I2C\_STRETCH\_PROTECT\_NUM field, in order to avoid timing sequence errors. The slave can choose to achieve clock stretching by holding the SCL line low when one of the following four events occurs:

1. Address match: The address of the slave matches the address sent by the master via the SDA line, and the R/W bit is 1.
2. RAM being full: RX RAM of the slave is full. Note that when the slave receives less than the FIFO depth, which is 32 bytes in ESP32-C6 I2C , it is not necessary to enable clock stretching; when the slave receives FIFO depth bytes or more, you may interrupt data transmission to wrapped around RAM via the FIFO threshold, or enable clock stretching for more time to process data. When clock stretching is enabled, I2C\_RX\_FULL\_ACK\_LEVEL must be cleared, otherwise there will be unpredictable consequences.
3. RAM being empty: The slave is sending data, but its TX RAM is empty.
4. Sending an ACK: If I2C\_SLAVE\_BYTE\_ACK\_CTL\_EN is set, the slave pulls SCL low when sending an ACK bit. At this stage, software validates data and configures I2C\_SLAVE\_BYTE\_ACK\_LVL to control the level of the ACK bit. Note that when RX RAM of the slave is full, the level of the ACK bit to be sent is determined by I2C\_RX\_FULL\_ACK\_LEVEL, instead of I2C\_SLAVE\_BYTE\_ACK\_LVL. In this case, I2C\_RX\_FULL\_ACK\_LEVEL should also be cleared to ensure proper functioning of clock stretching.

When clock stretching occurs, the cause of stretching can be read from the I2C\_STRETCH\_CAUSE bit. Clock stretching can be disabled by setting the I2C\_SLAVE\_SCL\_STRETCH\_CLR bit.

## 29.4.4 Generating SCL Pulses in Idle State

Usually when the I2C bus is idle, the SCL line is held high. The I2C controller in ESP32-C6 can be programmed to generate SCL pulses in idle state. This function only works when the I2C controller is configured as master. If the I2C\_SCL\_RST\_SLV\_EN bit is set, hardware will send I2C\_SCL\_RST\_SLV\_NUM SCL pulses, and then automatically clear I2C\_SCL\_RST\_SLV\_EN bit.

## 29.4.5 Synchronization

I2C registers are configured in APB\_CLK domain, whereas the I2C controller is configured in asynchronous I2C\_SCLK domain. Therefore, before being used by the I2C controller, register values should be synchronized by first writing configuration registers and then writing 1 to I2C\_CONF\_UPGATE. Registers that need synchronization are listed in Table 29.4-1 .

Table 29.4-1. I2C Synchronous Registers

| Register                     | Field                      | Address   |
|------------------------------|----------------------------|-----------|
| I2C_CTR_REG                  | I2C_SLV_TX_AUTO_START_EN   | 0x0004    |
| I2C_CTR_REG                  | I2C_ADDR_10BIT_RW_CHECK_EN | 0x0004    |
| I2C_CTR_REG                  | I2C_ADDR_BROADCASTING_EN   | 0x0004    |
| I2C_CTR_REG                  | I2C_SDA_FORCE_OUT          | 0x0004    |
| I2C_CTR_REG                  | I2C_SCL_FORCE_OUT          | 0x0004    |
| I2C_CTR_REG                  | I2C_SAMPLE_SCL_LEVEL       | 0x0004    |
| I2C_CTR_REG                  | I2C_RX_FULL_ACK_LEVEL      | 0x0004    |
| I2C_CTR_REG                  | I2C_MS_MODE                | 0x0004    |
| I2C_CTR_REG                  | I2C_TX_LSB_FIRST           | 0x0004    |
| I2C_CTR_REG                  | I2C_RX_LSB_FIRST           | 0x0004    |
| I2C_CTR_REG                  | I2C_ARBITRATION_EN         | 0x0004    |
| I2C_TO_REG                   | I2C_TIME_OUT_EN            | 0x000C    |
| I2C_TO_REG                   | I2C_TIME_OUT_VALUE         | 0x000C    |
| I2C_SLAVE_ADDR_REG           | I2C_ADDR_10BIT_EN          | 0x0010    |
| I2C_SLAVE_ADDR_REG           | I2C_SLAVE_ADDR             | 0x0010    |
| I2C_FIFO_CONF_REG            | I2C_FIFO_ADDR_CFG_EN       | 0x0018    |
| I2C_SCL_SP_CONF_REG          | I2C_SDA_PD_EN              | 0x0080    |
| I2C_SCL_SP_CONF_REG          | I2C_SCL_PD_EN              | 0x0080    |
| I2C_SCL_SP_CONF_REG          | I2C_SCL_RST_SLV_NUM        | 0x0080    |
| I2C_SCL_SP_CONF_REG          | I2C_SCL_RST_SLV_EN         | 0x0080    |
| I2C_SCL_STRETCH_CONF_REG     | I2C_SLAVE_BYTE_ACK_CTL_EN  | 0x0084    |
| I2C_SCL_STRETCH_CONF_REG     | I2C_SLAVE_BYTE_ACK_LVL     | 0x0084    |
| I2C_SCL_STRETCH_CONF_REG     | I2C_SLAVE_SCL_STRETCH_EN   | 0x0084    |
| I2C_SCL_LOW_PERIOD_REG       | I2C_SCL_LOW_PERIOD         | 0x0000    |
| I2C_SCL_HIGH_PERIOD_REG      | I2C_WAIT_HIGH_PERIOD       | 0x0038    |
| I2C_SCL_HIGH_PERIOD_REG      | I2C_HIGH_PERIOD            | 0x0038    |
| I2C_SDA_HOLD_REG             | I2C_SDA_HOLD_TIME          | 0x0030    |
| I2C_SDA_SAMPLE_REG           | I2C_SDA_SAMPLE_TIME        | 0x0034    |
| I2C_SCL_START_HOLD_REG       | I2C_SCL_START_HOLD_TIME    | 0x0040    |
| I2C_SCL_RSTART_SETUP_REG     | I2C_SCL_RSTART_SETUP_TIME  | 0x0044    |
| I2C_SCL_STOP_HOLD_REG        | I2C_SCL_STOP_HOLD_TIME     | 0x0048    |
| I2C_SCL_STOP_SETUP_REG       | I2C_SCL_STOP_SETUP_TIME    | 0x004C    |
| I2C_SCL_ST_TIME_OUT_REG      | I2C_SCL_ST_TO_I2C          | 0x0078    |
| I2C_SCL_MAIN_ST_TIME_OUT_REG | I2C_SCL_MAIN_ST_TO_I2C     | 0x007C    |
| I2C_FILTER_CFG_REG           | I2C_SCL_FILTER_EN          | 0x0050    |
| I2C_FILTER_CFG_REG           | I2C_SCL_FILTER_THRES       |           |
| I2C_FILTER_CFG_REG           | I2C_SDA_FILTER_EN          |           |
| I2C_FILTER_CFG_REG           | I2C_SDA_FILTER_THRES       |           |

## 29.4.6 Open-Drain Output

SCL and SDA output drivers must be configured as open-drain. There are two ways to achieve this:

1. Set I2C\_SCL\_FORCE\_OUT and I2C\_SDA\_FORCE\_OUT, and configure GPIO\_PINn\_PAD\_DRIVER for corresponding SCL and SDA pads as open-drain.
2. Clear I2C\_SCL\_FORCE\_OUT and I2C\_SDA\_FORCE\_OUT .

Because these lines are configured as open-drain, the low-to-high transition time of each line is longer, determined together by the pull-up resistor and line capacitance. The output duty cycle of I2C is limited by the SDA and SCL line's pull-up speed, mainly SCL's speed.

In addition, when I2C\_SCL\_FORCE\_OUT and I2C\_SCL\_PD\_EN are set to 1, SCL can be forced low; when I2C\_SDA\_FORCE\_OUT and I2C\_SDA\_PD\_EN are set to 1, SDA can be forced low.

## 29.4.7 Timing Parameter Configuration

Figure 29.4-1. I2C Timing Diagram

![Image](images/29_Chapter_29_img005_c7fcf624.png)

Figure 29.4-1 shows the timing diagram of an I2C master. This figure also specifies registers used to configure the START bit, STOP bit, data hold time, data sample time, waiting time on the rising SCL edge, etc. Timing parameters are calculated as follows in I2C\_SCLK clock cycles:

1. tLOW = (I2C \_ SCL \_ LOW \_ P ERIOD + 1) · TI2C \_ SCLK
2. t HIGH = (I2C \_ SCL \_ HIGH \_ P ERIOD + 1) · TI2C \_ SCLK
3. tSU : ST A = (I2C \_ SCL \_ RST ART \_ SET UP \_ T IME + 1) · TI2C \_ SCLK
4. t HD:ST A = (I2C \_ SCL \_ ST ART \_ HOLD \_ T IME + 1) · TI2C \_ SCLK
5. t r = (I2C \_ SCL \_ W AIT \_ HIGH \_ P ERIOD + 1) · TI2C \_ SCLK
6. tSU : ST O = (I2C \_ SCL \_ ST OP \_ SET UP \_ T IME + 1) · TI2C \_ SCLK
7. t BUF = (I2C \_ SCL \_ ST OP \_ HOLD \_ T IME + 1) · TI2C \_ SCLK
8. t HD:DAT = (I2C \_ SDA \_ HOLD \_ T IME + 1) · TI2C \_ SCLK
9. tSU : DAT = (I2C \_ SCL \_ LOW \_ P ERIOD − I2C \_ SDA \_ HOLD \_ T IME) · TI2C \_ SCLK

Timing registers below are divided into two groups, depending on the mode in which these registers are active:

- Master mode only:

1. I2C\_SCL\_START\_HOLD\_TIME: Specifies the interval between the moment SDA is pulled low and the moment SCL is pulled low when the master generates a START condition. This interval is (I2C\_SCL\_START\_HOLD\_TIME +1) in I2C\_SCLK cycles. This register is active only when the I2C controller works in master mode.
2. I2C\_SCL\_LOW\_PERIOD: Specifies the low period of SCL. This period lasts (I2C\_SCL\_LOW\_PERIOD +1) in I2C\_SCLK cycles. This register is active only when the I2C controller works in master mode. However, this period could be extended in the following scenarios:
3. – SCL is pulled low by peripheral devices when I2C acts as a master.
4. – SCL is pulled low by an END command executed by the I2C controller.
5. – SCL is pulled low by clock stretching when I2C acts as a slave.
3. I2C\_SCL\_WAIT\_HIGH\_PERIOD: Specifies time for SCL to switch from low to high in I2C\_SCLK cycles. Please make sure that SCL can be pulled high within this time period. Otherwise, the high period of SCL may be incorrect. This register is active only when the I2C controller works in master mode.
4. I2C\_SCL\_HIGH\_PERIOD: Specifies the high period of SCL in I2C\_SCLK cycles. This register is active only when the I2C controller works in master mode. When SCL goes high within (I2C\_SCL\_WAIT\_HIGH\_PERIOD + 1) in I2C\_SCLK cycles, its frequency is:
8. fscl = fI2C\_SCLK I2C\_SCL\_LOW\_PERIOD + I2C\_SCL\_HIGH\_PERIOD + I2C\_SCL\_WAIT\_HIGH\_PERIOD + 3 + I2C\_SCL\_FILTER\_THRES where 3 represents the amount of clock cycles required to synchronize the SCL. If the SCL filtering function is turned on, the delay caused by I2C\_SCL\_FILTER\_THRES needs to be added. As the SCL low-to-high transition time represented by I2C\_SCL\_WAIT\_HIGH\_PERIOD + 1 module clock can be affected by the pull-up resistor, IO drive capability, SCL line capacitance, etc., deviation may occur between the actual frequency of the test and the theoretical frequency. At this point, deviations can be reduced by adjusting the value of I2C\_SCL\_WAIT\_HIGH\_PERIOD .
- Master mode and slave mode:
1. I2C\_SDA\_SAMPLE\_TIME: Specifies the interval between the rising edge of SCL and the level sampling time of SDA. It is advised to set a value in the middle of SCL's high period, so as to correctly sample the level of SCL. This register is active both in master mode and slave mode.
2. I2C\_SDA\_HOLD\_TIME: Specifies the interval between changing the SDA output level and the falling edge of SCL. This register is active both in master mode and slave mode.

Timing parameters limits corresponding register configuration.

1. fI2C \_ SCLK fSCL &gt; 20
2. 3 × fI2C \_ SCLK ≤ (I2C \_ SDA \_ HOLD \_ T IME − 4) × fAP B \_ CLK
3. I2C\_SDA\_HOLD\_TIME + I2C\_SCL\_START\_HOLD\_TIME &gt; SDA\_FILTER\_THRES + 3
4. I2C\_SCL\_WAIT\_HIGH\_PERIOD &lt; I2C\_SDA\_SAMPLE\_TIME &lt; I2C\_SCL\_HIGH\_PERIOD
5. I2C\_SDA\_SAMPLE\_TIME &lt; I2C\_SCL\_WAIT\_HIGH\_PERIOD + I2C\_SCL\_START\_HOLD\_TIME + I2C\_SCL\_RSTART\_SETUP\_TIME
6. I2C\_STRETCH\_PROTECT\_NUM + I2C\_SDA\_HOLD\_TIME &gt; I2C\_SCL\_LOW\_PERIOD

## 29.4.8 Timeout Control

The I2C controller has three types of timeout control, namely timeout control for SCL\_FSM, for SCL\_MAIN\_FSM, and for the SCL line. The first two are always enabled, while the third is configurable.

When SCL\_FSM remains unchanged for more than 2 I2C \_ SCL \_ ST \_ T O \_ I2C clock cycles, an I2C\_SCL\_ST\_TO\_INT interrupt is triggered, and then SCL\_FSM goes to idle state. The value of I2C\_SCL\_ST\_TO\_I2C should be less than or equal to 22, which means SCL\_FSM could remain unchanged for 2 22 I2C\_SCLK clock cycles at most before the interrupt is generated.

When SCL\_MAIN\_FSM remains unchanged for more than 2 I2C \_ SCL \_ MAIN \_ ST \_ T O \_ I2C I2C\_SCLK clock cycles, an I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt is triggered, and then SCL\_MAIN\_FSM goes to idle state. The value of I2C\_SCL\_MAIN\_ST\_TO\_I2C should be less than or equal to 22, which means SCL\_MAIN\_FSM could remain unchanged for 2 22 clock cycles at most before the interrupt is generated.

Timeout control for SCL is enabled by setting I2C\_TIME\_OUT\_EN. When the level of SCL remains unchanged for more than 2I2C \_ T IME \_ OUT \_ V ALUE clock cycles, an I2C\_TIME\_OUT\_INT interrupt is triggered, and then the I2C bus goes to idle state.

## 29.4.9 Command Configuration

When the I2C controller works in master mode, CMD\_Controller reads commands from 8 sequential command registers and controls SCL\_FSM and SCL\_MAIN\_FSM accordingly.

Figure 29.4-2. Structure of I2C Command Registers

![Image](images/29_Chapter_29_img006_84a06c24.png)

Command registers, whose structure is illustrated in Figure 29.4-2, are active only when the I2C controller works in master mode. Fields of command registers are:

1. CMD\_DONE: Indicates that a command has been executed. After each command has been executed, the CMD\_DONE bit in the corresponding command register is set to 1 by hardware. By reading this bit, software can tell if the command has been executed. When writing new commands, this bit must be cleared by software.
2. op\_code: Indicates the command. The I2C controller supports five commands:
- WRITE: op\_code = 1. The I2C controller sends a slave address, a register address (only in dual address mode) and data to the slave.
- STOP: op\_code = 2. The I2C controller sends a STOP bit defined by the I2C protocol. This code also indicates that the command sequence has been executed, and the CMD\_Controller stops reading commands. After restarted by software, the CMD\_Controller resumes reading commands from command register 0.

- READ: op\_code = 3. The I2C controller reads data from the slave.
- END: op\_code = 4. The I2C controller pulls the SCL line down and suspends I2C communication. This code also indicates that the command sequence has completed, and the CMD\_Controller stops executing commands. Once software refreshes data in command registers and the RAM, the CMD\_Controller can be restarted to execute commands from command register 0 again.
- RSTART: op\_code = 6. The I2C controller sends a START bit or a RSTART bit defined by the I2C protocol.
3. ack\_value: Used to configure the level of the ACK bit sent by the I2C controller during a read operation. This bit is ignored in RSTART, STOP, END and WRITE conditions.
4. ack\_exp: Used to configure the level of the ACK bit expected by the I2C controller during a write operation. This bit is ignored during RSTART, STOP, END and READ conditions.
5. ack\_check\_en: Used to enable the I2C controller during a write operation to check whether the ACK level sent by the slave matches ack\_exp in the command. If this bit is set and the level received does not match ack\_exp in the WRITE command, the master will generate an I2C\_NACK\_INT interrupt and a STOP condition for data transfer. If this bit is cleared, the controller will not check the ACK level sent by the slave. This bit is ignored during RSTART, STOP, END and READ conditions.
6. byte\_num: Specifies the length of data (in bytes) to be read or written. Can range from 1 to 255 bytes. This bit is ignored during RSTART, STOP and END conditions.

Each command sequence is executed starting from command register 0 and terminated by a STOP or an END. Therefore, there must be a STOP or an END command in the eight command registers.

A complete data transfer on the I2C bus should be initiated by a START and terminated by a STOP. The transfer process may be completed using multiple sequences, separated by END commands. Each sequence may differ in the direction of data transfer, clock frequency, slave addresses, data length, etc. This allows efficient use of available peripheral RAM and also achieves more flexible I2C communication.

## 29.4.10 TX/RX RAM Data Storage

Both TX RAM and RX RAM are 32 × 8 bits, and can be accessed in FIFO or non-FIFO mode. If I2C\_NONFIFO\_EN bit is cleared, both RAMs are accessed in FIFO mode; if I2C\_NONFIFO\_EN bit is set, both RAMs are accessed in non-FIFO mode.

TX RAM stores data that the I2C controller needs to send. During communication, when the I2C controller needs to send data (except acknowledgement bits), it reads data from TX RAM and sends them sequentially via SDA. When the I2C controller works in master mode, all data must be stored in TX RAM in the order they need to be sent to slaves. The data stored in TX RAM include slave addresses, read/write bits, register addresses (only in dual address mode) and data to be sent. When the I2C controller works in slave mode, TX RAM only stores data to be sent.

TX RAM can be read and written by the CPU. The CPU writes to TX RAM either in FIFO mode or in non-FIFO mode (direct address). In FIFO mode, the CPU writes to TX RAM via the fixed address I2C\_DATA\_REG, with addresses for writing in TX RAM incremented automatically by hardware. In non-FIFO mode, the CPU accesses TX RAM directly via address fields (I2C Base Address + 0x100) ~(I2C Base Address + 0x17C). Each byte in TX RAM occupies an entire word in the address space. Therefore, the address of the first byte is I2C Base Address + 0x100, the second byte is I2C Base Address + 0x104, the third byte is I2C Base Address + 0x108,

and so on. The CPU can only read TX RAM via direct addresses. Bytes written to the TX RAM can be read back by the CPU, via the direct addresses. Addresses for reading TX RAM are the same with addresses for writing TX RAM.

RX RAM stores data the I2C controller receives during communication. When the I2C controller works in slave mode, neither slave addresses sent by the master nor register addresses (only in dual address mode) will be stored into RX RAM. Values of RX RAM can be read by software after I2C communication completes.

RX RAM can only be read by the CPU. The CPU reads RX RAM either in FIFO mode or in non-FIFO mode (direct address). In FIFO mode, the CPU reads RX RAM via the fixed address I2C\_DATA\_REG, with addresses for reading RX RAM incremented automatically by hardware. In non-FIFO mode, the CPU accesses TX RAM directly via address fields (I2C Base Address + 0x180) ~(I2C Base Address + 0x1FC). Each byte in RX RAM occupies an entire word in the address space. Therefore, the address of the first byte is I2C Base Address + 0x180, the second byte is I2C Base Address + 0x184, the third byte is I2C Base Address + 0x188 and so on.

In FIFO mode, TX RAM of a master may wrap around to send data larger than the FIFO depth. Set I2C\_FIFO\_PRT\_EN. If the size of data to be sent is smaller than I2C\_TXFIFO\_WM\_THRHD (master), an I2C\_TXFIFO\_WM\_INT (master) interrupt is generated. After receiving the interrupt, software continues writing to I2C\_DATA\_REG (master). Please ensure that software writes to or refreshes TX RAM before the master sends data, otherwise it may result in unpredictable consequences.

In FIFO mode, RX RAM of a slave may also wrap around to receive data larger than the FIFO depth. Set I2C\_FIFO\_PRT\_EN and clear I2C\_RX\_FULL\_ACK\_LEVEL. If data already received (to be overwritten) is larger than I2C\_RXFIFO\_WM\_THRHD (slave), an I2C\_RXFIFO\_WM\_INT (slave) interrupt is generated. After receiving the interrupt, software continues reading from I2C\_DATA\_REG (slave).

## 29.4.11 Data Conversion

DATA\_Shifter is used for serial/parallel conversion, converting byte data in TX RAM to an outgoing serial bitstream or an incoming serial bitstream to byte data in RX RAM. I2C\_RX\_LSB\_FIRST and I2C\_TX\_LSB\_FIRST can be used to select LSB- or MSB-first storage and transmission of data.

## 29.4.12 Addressing Mode

The ESP32-C6 I2C controller supports 7-bit and 10-bit addressing. 10-bit addressing can be mixed with 7-bit addressing. Besides, the ESP32-C6 I2C controller also supports dual address mode.

Define the slave address as SLV\_ADDR. In 7-bit addressing mode, the slave address is SLV\_ADDR[6:0]; in 10-bit addressing mode, the slave address is SLV\_ADDR[9:0].

In 7-bit addressing mode, the master only needs to send one byte of address, which comprises SLV\_ADDR[6:0] and a R/W bit. In 7-bit addressing mode, there is a special case called general call addressing (broadcast). It is enabled by setting I2C\_ADDR\_BROADCASTING\_EN in a slave. When the slave receives the general call address (0x00) from the master and the R/W bit followed is 0, it responds to the master regardless of its own address.

In 10-bit addressing mode, the master needs to send two bytes of address. The first byte is slave\_addr\_first\_7bits followed by a R/W bit, and slave\_addr\_first\_7bits should be configured as (0x78 | SLV\_ADDR[9:8]). The second byte is slave\_addr\_second\_byte, which should be configured as SLV\_ADDR[7:0].

The slave can enable 10-bit addressing by configuring I2C\_ADDR\_10BIT\_EN . I2C\_SLAVE\_ADDR is used to configure I2C slave address. Specifically, I2C\_SLAVE\_ADDR[14:7] should be configured as SLV\_ADDR[7:0], and I2C\_SLAVE\_ADDR[6:0] should be configured as (0x78 | SLV\_ADDR[9:8]). Since a 10-bit slave address has one more byte than a 7-bit address, byte\_num of the WRITE command and the number of bytes in the RAM increase by one. Please refer to Programming Example for detailed descriptions.

When working in slave mode, the I2C controller supports dual address mode, where the first address is the address of an I2C slave, and the second one is the slave's memory address. When using dual address mode, RAM must be accessed in non-FIFO mode. Dual address mode is enabled by setting I2C\_FIFO\_ADDR\_CFG\_EN. When the slave address received by the slave is inconsistent with the internally configured slave address, the I2C\_SLAVE\_ADDR\_UNMATCH interrupt will be generated.

## 29.4.13 R/W Bit Check in 10-bit Addressing Mode

In 10-bit addressing mode, when I2C\_ADDR\_10BIT\_RW\_CHECK\_EN is set to 1, the I2C controller performs a check on the first byte, which consists of slave\_addr\_first\_7bits and a R/W bit. When the R/W bit does not indicate a WRITE operation, i.e. not in line with the I2C protocol, the data transfer ends. If the check feature is not enabled, when the R/W bit does not indicate a WRITE, the data transfer still continues, but transfer failure may occur.

## 29.4.14 To Start the I2C Controller

To start the I2C controller in master mode, after configuring the controller to master mode and command registers, write 1 to I2C\_TRANS\_START in order to let the master starts to parse and execute command sequences. The master always executes a command sequence starting from command register 0 to a STOP or an END. To execute another command sequence starting from command register 0, refresh commands by writing 1 again to I2C\_TRANS\_START .

There are two ways to start the I2C controller in slave mode:

- Set I2C\_SLV\_TX\_AUTO\_START\_EN, and the slave starts automatic transfer upon an address match;
- Clear I2C\_SLV\_TX\_AUTO\_START\_EN, and always set I2C\_TRANS\_START before accepting any transfer.

## 29.5 Functional differences between LP\_I2C and I2C

LP\_I2C can be used as a master to communicate with external devices when the main system sleeps. LP\_I2C includes all the functions of the ESP32-C6 I2C master , but doesn't include any functions of ESP32-C6 I2Cslave. It does not contain any registers related to the I2Cslave. For detailed register list, see 29.10 LP\_I2C Register Summary .

The design differences between LP\_I2C and I2C master are as follows:

- The size of TX/RX RAM in LP\_I2C is 16*8 bit, which means the TXfiRX FIFO depth is 16 bytes.
- The clock source of APB\_CLK in LP\_I2C is CLK\_AON\_FAST. Configure LP\_I2C\_SCLK\_SEL to select the clock source for I2C\_SCLK. When LP\_I2C\_SCLK\_SEL is 0, select CLK\_ROOT\_FAST as clock source, and when LP\_I2C\_SCLK\_SEL is 1, select CLK \_XTALD2 as the clock source. Configure LP\_EXT\_I2C\_CK\_EN high to enable the clock source of I2C\_SCLK. Adjust the timing registers accordingly when the clock frequency changes.

See the programming examples of ESP32-C6 I2Cslave in 29.6 for that of LP\_I2C.

## 29.6 Programming Example

This sections provides programming examples for typical communication scenarios. ESP32-C6 has two I2C controllers. For the convenience of description, I2C masters and slaves in all subsequent figures are ESP32-C6 I2C controllers. I2C master is referred to as I2C master , and I2C slave is referred to as I2Cslave .

## 29.6.1 I2C master Writes to I2C slave with a 7-bit Address in One Command Sequence

## 29.6.1.1 Introduction

Figure 29.6-1. I2Cmaster Writing to I2Cslave with a 7-bit Address

![Image](images/29_Chapter_29_img007_6f5b8b45.png)

Figure 29.6-1 shows how I2Cmaster writes N bytes of data to I2Cslave registers or RAM using 7-bit addressing. As shown in figure 29.6-1 , the first byte in the RAM of I2Cmaster is a 7-bit I2Cslave address followed by a R/W bit. When the R/W bit is 0, it indicates a WRITE operation. The remaining bytes are used to store data ready for transfer. The cmd box contains related command sequences.

After the command sequence is configured and data in RAM is ready, I2Cmaster enables the controller and initiates data transfer by setting the I2C\_TRANS\_START bit. The controller has four steps to take:

1. Wait for SCL to go high, to avoid SCL being used by other masters or slaves.
2. Execute a RSTART command by sending a START bit.
3. Execute a WRITE command by taking N+1 bytes from the RAM in order and send them to I2Cslave in the same order. The first byte is the address of I2Cslave .
4. Execute a STOP command. Once the I2C master transfers a STOP bit, an I2C\_TRANS\_COMPLETE\_INT interrupt is generated.

## 29.6.1.2 Configuration Example

1. Configure the timing parameter registers of I2Cmaster and I2Cslave according to Section 29.4.7 .
2. Set I2C\_MS\_MODE (master) to 1, and I2C\_MS\_MODE (slave) to 0.
3. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
4. Configure command registers of I2Cmaster .
5. Write the address of I2C slave and data to be sent to TX RAM of I2C master in either FIFO mode or non-FIFO mode according to Section 29.4.10 .
6. Write the address of I2C slave to I2C\_SLAVE\_ADDR (slave) in I2C\_SLAVE\_ADDR\_REG (slave) register.
7. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
8. Write 1 to I2C\_TRANS\_START (master) and I2C\_TRANS\_START (slave) to start transfer.
9. I2C slave compares the slave address sent by I2Cmaster with its own address in I2C\_SLAVE\_ADDR (slave). When ack\_check\_en (master) in I2Cmaster's WRITE command is 1, I2Cmaster checks ACK value each time it sends a byte. When ack\_check\_en (master) is 0, I2Cmaster does not check ACK value and take I2Cslave as a matching slave by default.
- Match: If the received ACK value matches ack\_exp (master) (the expected ACK value), I2Cmaster continues data transfer.
- Not match: If the received ACK value does not match ack\_exp, I2Cmaster generates an I2C\_NACK\_INT (master) interrupt and stops data transfer.
10. I2C master sends data, and determines whether to check ACK value according to ack\_check\_en (master).
11. If data to be sent (N) is larger than TX FIFO depth, TX RAM of I2Cmaster may wrap around in FIFO mode. For details, please refer to Section 29.4.10 .
12. If data to be received (N) is larger than RX FIFO depth, RX RAM of I2Cslave may wrap around in FIFO mode. For details, please refer to Section 29.4.10 .
15. If data to be received (N) is larger than RX FIFO depth, the other way is to enable clock stretching by setting the I2C\_SLAVE\_SCL\_STRETCH\_EN (slave), and clearing I2C\_RX\_FULL\_ACK\_LEVEL. When RX RAM is full, an I2C\_SLAVE\_STRETCH\_INT (slave) interrupt is generated. In this way, I2Cslave can hold SCL low, in exchange for more time to read data. After software has finished reading, you can set I2C\_SLAVE\_STRETCH\_INT\_CLR (slave) to 1 to clear interrupt, and set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to release the SCL line.
13. After data transfer completes, I2Cmaster executes the STOP command, and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.

| Command register         | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |     |
|--------------------------|-----------|-------------|-----------|-------------------------|-----|
| I2C_COMMAND0  (mas ter) | RSTART    | —           | —         | —                       | —   |
| I2C_COMMAND1 (master)    | WRITE     | ack_value   | ack_exp   | 1                       | N+1 |
| I2C_COMMAND2  (mas ter) | STOP      | —           | —         | —                       | —   |

## 29.6.2 I2C master Writes to I2C slave with a 10-bit Address in One Command Sequence

## 29.6.2.1 Introduction

Figure 29.6-2. I2Cmaster Writing to a Slave with a 10-bit Address

![Image](images/29_Chapter_29_img008_cf75eee5.png)

Figure 29.6-2 shows how I2Cmaster writes N bytes of data using 10-bit addressing to an I2C slave. The configuration and transfer process is similar to what is described in 29.6.1, except that a 10-bit I2Cslave address is formed from two bytes. Since a 10-bit I2Cslave address has one more byte than a 7-bit I2Cslave address, byte\_num and length of data in TX RAM increase by 1 accordingly.

## 29.6.2.2 Configuration Example

1. Set I2C\_MS\_MODE (master) to 1, and I2C\_MS\_MODE (slave) to 0.
2. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
3. Configure command registers of I2Cmaster .
4. Configure I2C\_SLAVE\_ADDR (slave) in I2C\_SLAVE\_ADDR\_REG (slave) as I2Cslave's 10-bit address, and set I2C\_ADDR\_10BIT\_EN (slave) to 1 to enable 10-bit addressing.
5. Write the address of I2C slave and data to be sent to TX RAM of I2C master . The first byte of the address of I2C slave comprises ((0x78 | I2C\_SLAVE\_ADDR[9:8])«1) and a R/W bit. The second byte of the address of

| Command registers        | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |     |
|--------------------------|-----------|-------------|-----------|-------------------------|-----|
| I2C_COMMAND0  (mas ter) | RSTART    | —           | —         | —                       | —   |
| I2C_COMMAND1 (master)    | WRITE     | ack_value   | ack_exp   | 1                       | N+2 |
| I2C_COMMAND2  (mas ter) | STOP      | —           | —         | —                       | —   |

I2C slave is I2C\_SLAVE\_ADDR[7:0]. These two bytes are followed by data to be sent in FIFO or non-FIFO mode.

6. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
7. Write 1 to I2C\_TRANS\_START (master) and I2C\_TRANS\_START (slave) to start transfer.
8. I2C slave compares the slave address sent by I2Cmaster with its own address in I2C\_SLAVE\_ADDR (slave). When ack\_check\_en (master) in I2Cmaster's WRITE command is 1, I2Cmaster checks ACK value each time it sends a byte. When ack\_check\_en (master) is 0, I2Cmaster does not check ACK value and take I2Cslave as matching slave by default.
- Match: If the received ACK value matches ack\_exp (master) (the expected ACK value), I2Cmaster continues data transfer.
- Not match: If the received ACK value does not match ack\_exp, I2Cmaster generates an I2C\_NACK\_INT (master) interrupt and stops data transfer.
9. I2C master sends data, and determines whether to check ACK value according to ack\_check\_en (master).
10. If data to be sent is larger than TX FIFO depth, TX RAM of I2Cmaster may wrap around in FIFO mode. For details, please refer to Section 29.4.10 .
11. If data to be received is larger than RX FIFO depth, RX RAM of I2Cslave may wrap around in FIFO mode. For details, please refer to Section 29.4.10 .
9. If data to be received is larger than RX FIFO depth, the other way is to enable clock stretching by setting I2C\_SLAVE\_SCL\_STRETCH\_EN (slave), and clearing I2C\_RX\_FULL\_ACK\_LEVEL to 0. When RX RAM is full, an I2C\_SLAVE\_STRETCH\_INT (slave) interrupt is generated. In this way, I2Cslave can hold SCL low, in exchange for more time to read data. After software has finished reading, you can set I2C\_SLAVE\_STRETCH\_INT\_CLR (slave) to 1 to clear interrupt, and set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to release the SCL line.
12. After data transfer completes, I2Cmaster executes the STOP command, and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.

## 29.6.3 I2C master Writes to I2C slave with Two 7-bit Addresses in One Command Sequence

## 29.6.3.1 Introduction

Figure 29.6-3. I2Cmaster Writing to I2Cslave with Two 7-bit Addresses

![Image](images/29_Chapter_29_img009_e09e6c2a.png)

Figure 29.6-3 shows how I2Cmaster writes N bytes of data to I2Cslave registers or RAM using 7-bit double addressing. The configuration and transfer process is similar to what is described in Section 29.6.1, except that in 7-bit dual address mode I2C master sends two 7-bit addresses. The first address is the address of an I2C slave, and the second one is I2Cslave's memory address (i.e. addrM in Figure 29.6-3). When using double addressing, RAM must be accessed in non-FIFO mode. The I2C slave put received byte0 ~ byte(N-1) into its RAM in an order staring from addrM. The RAM is overwritten every 32 bytes.

## 29.6.3.2 Configuration Example

1. Set I2C\_MS\_MODE (master) to 1, and I2C\_MS\_MODE (slave) to 0.
2. Set I2C\_FIFO\_ADDR\_CFG\_EN (slave) to 1 to enable dual address mode.
3. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
4. Configure command registers of I2Cmaster .
5. Write the address of I2C slave and data to be sent to TX RAM of I2C master in FIFO or non-FIFO mode.
6. Write the address of I2C slave to I2C\_SLAVE\_ADDR (slave) in I2C\_SLAVE\_ADDR\_REG (slave) register.
7. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
8. Write 1 to I2C\_TRANS\_START (master) and I2C\_TRANS\_START (slave) to start transfer.

| Command registers        | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |     |
|--------------------------|-----------|-------------|-----------|-------------------------|-----|
| I2C_COMMAND0  (mas ter) | RSTART    | —           | —         | —                       | —   |
| I2C_COMMAND1 (master)    | WRITE     | ack_value   | ack_exp   | 1                       | N+2 |
| I2C_COMMAND2  (mas ter) | STOP      | —           | —         | —                       | —   |

9. I2C slave compares the slave address sent by I2Cmaster with its own address in I2C\_SLAVE\_ADDR (slave). When ack\_check\_en (master) in I2Cmaster's WRITE command is 1, I2Cmaster checks ACK value each time it sends a byte. When ack\_check\_en (master) is 0, I2Cmaster does not check ACK value and take I2Cslave as matching slave by default.
- Match: If the received ACK value matches ack\_exp (master) (the expected ACK value), I2Cmaster continues data transfer.
- Not match: If the received ACK value does not match ack\_exp, I2Cmaster generates an I2C\_NACK\_INT (master) interrupt and stops data transfer.
10. I2C slave receives the RX RAM address sent by I2Cmaster and adds the offset.
11. I2C master sends data, and determines whether to check ACK value according to ack\_check\_en (master).
12. If data to be sent is larger than TX FIFO depth, TX RAM of I2Cmaster may wrap around in FIFO mode. For details, please refer to Section 29.4.10 .
13. If data to be received is larger than RX FIFO depth, you may enable clock stretching by setting I2C\_SLAVE\_SCL\_STRETCH\_EN (slave), and clearing I2C\_RX\_FULL\_ACK\_LEVEL to 0. When RX RAM is full, an I2C\_SLAVE\_STRETCH\_INT (slave) interrupt is generated. In this way, I2Cslave can hold SCL low, in exchange for more time to read data. After software has finished reading, you can set I2C\_SLAVE\_STRETCH\_INT\_CLR (slave) to 1 to clear interrupt, and set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to release the SCL line.
14. After data transfer completes, I2Cmaster executes the STOP command, and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.

## 29.6.4 I2C master Writes to I2C slave with a 7-bit Address in Multiple Command Sequences

## 29.6.4.1 Introduction

Figure 29.6-4. I2Cmaster Writing to I2Cslave with a 7-bit Address in Multiple Sequences

![Image](images/29_Chapter_29_img010_72e5b620.png)

Given that the I2C Controller RAM holds only the size of TX/RX FIFO depth, when data are too large to be processed, it is advised to transmit them in multiple command sequences. At the end of every command sequence is an END command. When the controller executes this END command, SCL will be pulled low, and the software can refresh command sequence registers and the RAM for next the transfer.

Figure 29.6-4 shows how I2Cmaster writes to an I2C slave in two or three segments as an example. For the first segment, the CMD\_Controller registers are configured as shown in Segment0. Once data in I2Cmaster's RAM is ready and I2C\_TRANS\_START is set, I2Cmaster initiates data transfer. After executing the END command, I2C master turns off the SCL clock and pulls SCL low to reserve the bus. Meanwhile, the controller generates an

I2C\_END\_DETECT\_INT interrupt.

For the second segment, after detecting the I2C\_END\_DETECT\_INT interrupt, software refreshes the CMD\_Controller registers, reloads the RAM and clears this interrupt, as shown in Segment1. If cmd1 in the second segment is a STOP, then data is transmitted to I2Cslave in two segments. I2Cmaster resumes data transfer after I2C\_TRANS\_START is set, and terminates the transfer by sending a STOP bit.

For the third segment, after the second data transfer finishes and an I2C\_END\_DETECT\_INT is detected, the

CMD\_Controller registers of I2Cmaster are configured as shown in Segment2. Once I2C\_TRANS\_START is set, I2C master generates a STOP bit and terminates the transfer.

Note that other I2C master s will not transact on the bus between two segments. The bus is only released after a STOP command is sent. The I2C controller can be reset by setting I2C\_FSM\_RST field at any time. This field will later be cleared automatically by hardware.

## 29.6.4.2 Configuration Example

1. Set I2C\_MS\_MODE (master) to 1, and I2C\_MS\_MODE (slave) to 0.
2. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
3. Configure command registers of I2Cmaster .
4. Write the address of I2C slave and data to be sent to TX RAM of I2C master in either FIFO mode or non-FIFO mode according to Section 29.4.10 .
5. Write the address of I2C slave to I2C\_SLAVE\_ADDR (slave) in I2C\_SLAVE\_ADDR\_REG (slave) register
6. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
7. Write 1 to I2C\_TRANS\_START (master) and I2C\_TRANS\_START (slave) to start transfer.
8. I2C slave compares the slave address sent by I2Cmaster with its own address in I2C\_SLAVE\_ADDR (slave). When ack\_check\_en (master) in I2Cmaster's WRITE command is 1, I2Cmaster checks ACK value each time it sends a byte. When ack\_check\_en (master) is 0, I2Cmaster does not check ACK value and take I2Cslave as matching slave by default.
- Match: If the received ACK value matches ack\_exp (master) (the expected ACK value), I2Cmaster continues data transfer.
- Not match: If the received ACK value does not match ack\_exp, I2Cmaster generates an I2C\_NACK\_INT (master) interrupt and stops data transfer.
9. I2C master sends data, and checks ACK value or not according to ack\_check\_en (master).
10. After the I2C\_END\_DETECT\_INT (master) interrupt is generated, set I2C\_END\_DETECT\_INT\_CLR (master) to 1 to clear this interrupt.
11. Update I2Cmaster’s command registers.

| Command registers        | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |     |
|--------------------------|-----------|-------------|-----------|-------------------------|-----|
| I2C_COMMAND0  (mas ter) | RSTART    | —           | —         | —                       | —   |
| I2C_COMMAND1 (master)    | WRITE     | ack_value   | ack_exp   | 1                       | N+1 |
| I2C_COMMAND2  (mas ter) | END       | —           | —         | —                       | —   |

| Command registers        | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |    |
|--------------------------|-----------|-------------|-----------|-------------------------|----|
| I2C_COMMAND0  (mas ter) | WRITE     | ack_value   | ack_exp   | 1                       | M  |
| I2C_COMMAND1 (master)    | END/STOP  | —           | —         | —                       | —  |

12. Write M bytes of data to be sent to TX RAM of I2Cmaster in FIFO or non-FIFO mode.
13. Write 1 to I2C\_TRANS\_START (master) bit to start transfer and repeat step 9.
14. If the command is a STOP, I2C stops transfer and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.
15. If the command is an END, repeat step 10.
16. Update I2Cmaster’s command registers.
17. Write 1 to I2C\_TRANS\_START (master) bit to start transfer.
18. I2C master executes the STOP command and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.

| Command registers of I2C master   | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |    |
|-----------------------------------|-----------|-------------|-----------|-------------------------|----|
| I2C_COMMAND1 (master)             | STOP      | —           | —         | —                       | —  |

## 29.6.5 I2C master Reads I2C slave with a 7-bit Address in One Command Sequence

## 29.6.5.1 Introduction

Figure 29.6-5. I2Cmaster Reading I2Cslave with a 7-bit Address

![Image](images/29_Chapter_29_img011_14177eee.png)

Figure 29.6-5 shows how I2Cmaster reads N bytes of data from an I2C slave using 7-bit addressing. cmd1 is a WRITE command, and when this command is executed I2C master sends the address of I2C slave . The byte sent comprises a 7-bit I2Cslave address and a R/W bit. When the R/W bit is 1, it indicates a READ operation. If the

address of an I2C slave matches the sent address, this matching slave starts sending data to I2Cmaster . I2C master generates acknowledgements according to ack\_value defined in the READ command upon receiving a byte.

As illustrated in Figure 29.6-5, I2Cmaster executes two READ commands: it generates ACKs for (N-1) bytes of data in cmd2, and a NACK for the last byte of data in cmd 3. This configuration may be changed as required. I2C master writes received data into the controller RAM from addr0, whose original content (a the address of I2C slave and a R/W bit) is overwritten by byte0 marked red in Figure 29.6-5 .

## 29.6.5.2 Configuration Example

1. Set I2C\_MS\_MODE (master) to 1, and I2C\_MS\_MODE (slave) to 0.
2. We recommend setting I2C\_SLAVE\_SCL\_STRETCH\_EN (slave) to 1, so that SCL can be held low for more processing time when I2Cslave needs to send data. If this bit is not set, software should write data to be sent to I2C slave 's TX RAM before I2C master initiates transfer. Configuration below is applicable to scenario where I2C\_SLAVE\_SCL\_STRETCH\_EN (slave) is 1.
3. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
4. Configure command registers of I2Cmaster .
5. Write the address of I2C slave to TX RAM of I2C master in either FIFO mode or non-FIFO mode according to Section 29.4.10 .
6. Write the address of I2C slave to I2C\_SLAVE\_ADDR (slave) in I2C\_SLAVE\_ADDR\_REG (slave) register.
7. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
8. Write 1 to I2C\_TRANS\_START (master) bit to start I2Cmaster’s transfer.
9. Start I2C slave 's transfer according to Section 29.4.14 .
10. I2C slave compares the slave address sent by I2Cmaster with its own address in I2C\_SLAVE\_ADDR (slave). When ack\_check\_en (master) in I2Cmaster's WRITE command is 1, I2Cmaster checks ACK value each time it sends a byte. When ack\_check\_en (master) is 0, I2Cmaster does not check ACK value and take I2Cslave as matching slave by default.
- Match: If the received ACK value matches ack\_exp (master) (the expected ACK value), I2Cmaster continues data transfer.

| Command registers of I2C master   | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |     |
|-----------------------------------|-----------|-------------|-----------|-------------------------|-----|
| I2C_COMMAND0  (mas ter)          | RSTART    | —           | —         | —                       | —   |
| I2C_COMMAND1 (master)             | WRITE     | 0           | 0         | 1                       | 1   |
| I2C_COMMAND2  (mas ter)          | READ      | 0           | 0         | 1                       | N-1 |
| I2C_COMMAND3  (mas ter)          | READ      | 1           | 0         | 1                       | 1   |
| I2C_COMMAND4 (master)             | STOP      | —           | —         | —                       | —   |

- Not match: If the received ACK value does not match ack\_exp, I2Cmaster generates an I2C\_NACK\_INT (master) interrupt and stops data transfer.
11. After I2C\_SLAVE\_STRETCH\_INT (slave) is generated, the I2C\_STRETCH\_CAUSE bit is 0. The address of I2C slave matches the address sent over SDA, and I2Cslave needs to send data.
12. Write data to be sent to TX RAM of I2C slave in either FIFO mode or non-FIFO mode according to Section 29.4.10 .
13. Set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to 1 to release SCL.
14. I2C slave sends data, and I2C master checks ACK value or not according to ack\_check\_en (master) in the READ command.
15. If data to be read by I2Cmaster is larger than the TX FIFO depth of I2Cslave, an I2C\_SLAVE\_STRETCH\_INT (slave) interrupt will be generated when TX RAM of I2Cslave becomes empty. In this way, I2Cslave can hold SCL low, so that software has more time to pad data in TX RAM of I2Cslave and read data in RX RAM of I2C master . After software has finished reading, you can set I2C\_SLAVE\_STRETCH\_INT\_CLR (slave) to 1 to clear interrupt, and set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to release the SCL line.
16. After I2C master has received the last byte of data, set ack\_value (master) to 1. I2Cslave will stop transfer once receiving the I2C\_NACK\_INT interrupt.
17. After data transfer completes, I2Cmaster executes the STOP command, and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.

## 29.6.6 I2C master Reads I2C slave with a 10-bit Address in One Command Sequence

## 29.6.6.1 Introduction

Figure 29.6-6. I2Cmaster Reading I2Cslave with a 10-bit Address

![Image](images/29_Chapter_29_img012_fb1c227c.png)

Figure 29.6-6 shows how I2Cmaster reads data from an I2C slave using 10-bit addressing. Unlike 7-bit addressing, in 10-bit addressing the WRITE command of the I2Cmaster is formed from two bytes, and correspondingly TX RAM of this master stores a 10-bit address of two bytes. The R/W bit in the first byte is 0, which indicates a WRITE operation. After a RSTART condition, I2Cmaster sends the first byte of address again to read data from I2C slave , but the R/W bit is 1, which indicates a READ operation. The two address bytes can be configured as described in Section 29.6.2 .

## 29.6.6.2 Configuration Example

1. Set I2C\_MS\_MODE (master) to 1, and I2C\_MS\_MODE (slave) to 0.
2. We recommend setting I2C\_SLAVE\_SCL\_STRETCH\_EN (slave) to 1, so that SCL can be held low for more processing time when I2Cslave needs to send data. If this bit is not set, software should write data to be sent to I2C slave 's TX RAM before I2C master initiates transfer. Configuration below is applicable to scenario where I2C\_SLAVE\_SCL\_STRETCH\_EN (slave) is 1.
3. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
4. Configure command registers of I2Cmaster .

| Command registers of I2C master   | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |    |
|-----------------------------------|-----------|-------------|-----------|-------------------------|----|
| I2C_COMMAND0  (mas ter)          | RSTART    | —           | —         | —                       | —  |
| I2C_COMMAND1 (master)             | WRITE     | 0           | 0         | 1                       | 2  |

| I2C_COMMAND2  (mas ter)   | RSTART   | —   | —   | —   | —   |
|----------------------------|----------|-----|-----|-----|-----|
| I2C_COMMAND3  (mas ter)   | WRITE    | 0   | 0   | 1   | 1   |
| I2C_COMMAND4 (master)      | READ     | 0   | 0   | 1   | N-1 |
| I2C_COMMAND5  (mas ter)   | READ     | 1   | 0   | 1   | 1   |
| I2C_COMMAND6  (mas ter)   | STOP     | —   | —   | —   | —   |

5. Configure I2C\_SLAVE\_ADDR (slave) in I2C\_SLAVE\_ADDR\_REG (slave) as I2Cslave's 10-bit address, and set
2. I2C\_ADDR\_10BIT\_EN (slave) to 1 to enable 10-bit addressing.
6. Write the address of I2C slave and data to be sent to TX RAM of I2C master in either FIFO or non-FIFO mode. The first byte of address comprises ((0x78 | I2C\_SLAVE\_ADDR[9:8])«1) and a R/W bit, which is 1 and indicates a WRITE operation. The second byte of address is I2C\_SLAVE\_ADDR[7:0]. The third byte is ((0x78 | I2C\_SLAVE\_ADDR[9:8])«1) and a R/W bit, which is 1 and indicates a READ operation.
7. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
8. Write 1 to I2C\_TRANS\_START (master) to start I2Cmaster’s transfer.
9. Start I2C slave 's transfer according to Section 29.4.14 .
10. I2C slave compares the slave address sent by I2Cmaster with its own address in I2C\_SLAVE\_ADDR (slave). When ack\_check\_en (master) in I2Cmaster's WRITE command is 1, I2Cmaster checks ACK value each time it sends a byte. When ack\_check\_en (master) is 0, I2Cmaster does not check ACK value and take I2Cslave as matching slave by default.
- Match: If the received ACK value matches ack\_exp (master) (the expected ACK value), I2Cmaster continues data transfer.
- Not match: If the received ACK value does not match ack\_exp, I2Cmaster generates an I2C\_NACK\_INT (master) interrupt and stops data transfer.
11. I2C master sends a RSTART and the third byte in TX RAM, which is ((0x78 | I2C\_SLAVE\_ADDR[9:8])«1) and a R/W bit that indicates READ.
12. I2C slave repeats step 10. If its address matches the address sent by I2Cmaster, I2Cslave proceed on to the next steps.
13. After I2C\_SLAVE\_STRETCH\_INT (slave) is generated, the I2C\_STRETCH\_CAUSE bit is 0. The address of I2C slave matches the address sent over SDA, and I2Cslave needs to send data.
14. Write data to be sent to TX RAM of I2C slave in either FIFO mode or non-FIFO mode according to Section 29.4.10 .
15. Set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to 1 to release SCL.
16. I2C slave sends data, and I2C master checks ACK value or not according to ack\_check\_en (master) in the READ command.

17. If data to be read by I2Cmaster is larger than the TX FIFO depth of I2Cslave, an I2C\_SLAVE\_STRETCH\_INT (slave) interrupt will be generated when TX RAM of I2Cslave becomes empty. In this way, I2Cslave can hold SCL low, so that software has more time to pad data in TX RAM of I2Cslave and read data in RX RAM of I2C master . After software has finished reading, you can set I2C\_SLAVE\_STRETCH\_INT\_CLR (slave) to 1 to clear interrupt, and set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to release the SCL line.
18. After I2C master has received the last byte of data, set ack\_value (master) to 1. I2Cslave will stop transfer once receiving the I2C\_NACK\_INT interrupt.
19. After data transfer completes, I2Cmaster executes the STOP command, and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.

## 29.6.7 I2C master Reads I2C slave with Two 7-bit Addresses in One Command Sequence

## 29.6.7.1 Introduction

Figure 29.6-7. I2Cmaster Reading N Bytes of Data from addrM of I2Cslave with a 7-bit Address

![Image](images/29_Chapter_29_img013_65ef8871.png)

Figure 29.6-7 shows how I2Cmaster reads data from specified addresses in an I2C slave. I2Cmaster sends two bytes of addresses: the first byte is a 7-bit I2Cslave address followed by a R/W bit, which is 0 and indicates a WRITE; the second byte is I2Cslave's memory address. After a RSTART condition, I2Cmaster sends the first byte of address again, but the R/W bit is 1 which indicates a READ. Then, I2Cmaster reads data starting from addrM.

![Image](images/29_Chapter_29_img014_86b6f492.png)

## 29.6.7.2 Configuration Example

1. Set I2C\_MS\_MODE (master) to 1, and I2C\_MS\_MODE (slave) to 0.
2. We recommend setting I2C\_SLAVE\_SCL\_STRETCH\_EN (slave) to 1, so that SCL can be held low for more processing time when I2Cslave needs to send data. If this bit is not set, software should write data to be sent to I2C slave 's TX RAM before I2C master initiates transfer. Configuration below is applicable to scenario where I2C\_SLAVE\_SCL\_STRETCH\_EN (slave) is 1.
3. Set I2C\_FIFO\_ADDR\_CFG\_EN (slave) to 1 to enable dual address mode.
4. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
5. Configure command registers of I2Cmaster .
6. Configure I2C\_SLAVE\_ADDR (slave) in I2C\_SLAVE\_ADDR\_REG (slave) register as I2Cslave's 7-bit address, and set I2C\_ADDR\_10BIT\_EN (slave) to 0 to enable 7-bit addressing.
7. Write the address of I2C slave and data to be sent to TX RAM of I2C master in either FIFO or non-FIFO mode according to Section 29.4.10. The first byte of address comprises ( I2C\_SLAVE\_ADDR[6:0])«1) and a R/W bit, which is 0 and indicates a WRITE. The second byte of address is memory address M of I2C slave . The third byte is ( I2C\_SLAVE\_ADDR[6:0])«1) and a R/W bit, which is 1 and indicates a READ.
8. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
9. Write 1 to I2C\_TRANS\_START (master) to start I2Cmaster’s transfer.
10. Start I2C slave 's transfer according to Section 29.4.14 .
11. I2C slave compares the slave address sent by I2Cmaster with its own address in I2C\_SLAVE\_ADDR (slave). When ack\_check\_en (master) in I2Cmaster's WRITE command is 1, I2Cmaster checks ACK value each time it sends a byte. When ack\_check\_en (master) is 0, I2Cmaster does not check ACK value and take I2Cslave as matching slave by default.
- Match: If the received ACK value matches ack\_exp (master) (the expected ACK value), I2Cmaster continues data transfer.

| Command registers of I2C master   | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |     |
|-----------------------------------|-----------|-------------|-----------|-------------------------|-----|
| I2C_COMMAND0  (mas ter)          | RSTART    | —           | —         | —                       | —   |
| I2C_COMMAND1 (master)             | WRITE     | 0           | 0         | 1                       | 2   |
| I2C_COMMAND2  (mas ter)          | RSTART    | —           | —         | —                       | —   |
| I2C_COMMAND3  (mas ter)          | WRITE     | 0           | 0         | 1                       | 1   |
| I2C_COMMAND4 (master)             | READ      | 0           | 0         | 1                       | N-1 |
| I2C_COMMAND5  (mas ter)          | READ      | 1           | 0         | 1                       | 1   |
| I2C_COMMAND6  (mas ter)          | STOP      | —           | —         | —                       | —   |

- Not match: If the received ACK value does not match ack\_exp, I2Cmaster generates an I2C\_NACK\_INT (master) interrupt and stops data transfer.
12. I2C slave receives memory address sent by I2Cmaster and adds the offset.
13. I2C master sends a RSTART and the third byte in TX RAM, which is ((0x78 | I2C\_SLAVE\_ADDR[9:8])«1) and a R bit.
14. I2C slave repeats step 11. If its address matches the address sent by I2Cmaster, I2Cslave proceed on to the next steps.
15. After I2C\_SLAVE\_STRETCH\_INT (slave) is generated, the I2C\_STRETCH\_CAUSE bit is 0. The address of I2C slave matches the address sent over SDA, and I2Cslave needs to send data.
16. Write data to be sent to TX RAM of I2C slave in either FIFO mode or non-FIFO mode according to Section 29.4.10 .
17. Set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to 1 to release SCL.
18. I2C slave sends data, and I2C master checks ACK value or not according to ack\_check\_en (master) in the READ command.
19. If data to be read by I2Cmaster is larger than the TX FIFO depth of I2Cslave, an I2C\_SLAVE\_STRETCH\_INT (slave) interrupt will be generated when TX RAM of I2Cslave becomes empty. In this way, I2Cslave can hold SCL low, so that software has more time to pad data in TX RAM of I2Cslave and read data in RX RAM of I2C master . After software has finished reading, you can set I2C\_SLAVE\_STRETCH\_INT\_CLR (slave) to 1 to clear interrupt, and set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to release the SCL line.
20. After I2C master has received the last byte of data, set ack\_value (master) to 1. I2Cslave will stop transfer once receiving the I2C\_NACK\_INT interrupt.
21. After data transfer completes, I2Cmaster executes the STOP command, and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.

## 29.6.8 I2C master Reads I2C slave with a 7-bit Address in Multiple Command Sequences

## 29.6.8.1 Introduction

Figure 29.6-8. I2Cmaster Reading I2Cslave with a 7-bit Address in Segments

![Image](images/29_Chapter_29_img015_1c3fc360.png)

Figure 29.6-8 shows how I2Cmaster reads (N+M) bytes of data from an I2C slave in two/three segments separated by END commands. Configuration procedures are described as follows:

1. The procedures for Segment0 is similar to 29.6-5, except that the last command is an END.
2. Prepare data in the TX RAM of I2Cslave, and set I2C\_TRANS\_START to start data transfer. After executing the END command, I2C master refreshes command registers and the RAM as shown in Segment1, and clears the corresponding I2C\_END\_DETECT\_INT interrupt. If cmd2 in Segment1 is a STOP, then data is read from I2C slave in two segments. I2Cmaster resumes data transfer by setting I2C\_TRANS\_START and terminates the transfer by sending a STOP bit.
3. If cmd2 in Segment1 is an END, then data is read from I2Cslave in three segments. After the second data

![Image](images/29_Chapter_29_img016_8e77bbd6.png)

transfer finishes and an I2C\_END\_DETECT\_INT interrupt is detected, the cmd box is configured as shown in Segment2. Once I2C\_TRANS\_START is set, I2Cmaster terminates the transfer by sending a STOP bit.

## 29.6.8.2 Configuration Example

1. Set I2C\_MS\_MODE (master) to 1, and I2C\_MS\_MODE (slave) to 0.
2. We recommend setting I2C\_SLAVE\_SCL\_STRETCH\_EN (slave) to 1, so that SCL can be held low for more processing time when I2Cslave needs to send data. If this bit is not set, software should write data to be sent to I2C slave 's TX RAM before I2C master initiates transfer. Configuration below is applicable to scenario where I2C\_SLAVE\_SCL\_STRETCH\_EN (slave) is 1.
3. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
4. Configure command registers of I2Cmaster .
5. Write the address of I2C slave to TX RAM of I2C master in FIFO or non-FIFO mode.
6. Write the address of I2C slave to I2C\_SLAVE\_ADDR (slave) in I2C\_SLAVE\_ADDR\_REG (slave) register.
7. Write 1 to I2C\_CONF\_UPGATE (master) and I2C\_CONF\_UPGATE (slave) to synchronize registers.
8. Write 1 to I2C\_TRANS\_START (master) to start I2Cmaster’s transfer.
9. Start I2C slave 's transfer according to Section 29.4.14 .
10. I2C slave compares the slave address sent by I2Cmaster with its own address in I2C\_SLAVE\_ADDR (slave). When ack\_check\_en (master) in I2Cmaster's WRITE command is 1, I2Cmaster checks ACK value each time it sends a byte. When ack\_check\_en (master) is 0, I2Cmaster does not check ACK value and take I2Cslave as matching slave by default.
- Match: If the received ACK value matches ack\_exp (master) (the expected ACK value), I2Cmaster continues data transfer.
- Not match: If the received ACK value does not match ack\_exp, I2Cmaster generates an I2C\_NACK\_INT (master) interrupt and stops data transfer.
11. After I2C\_SLAVE\_STRETCH\_INT (slave) is generated, the I2C\_STRETCH\_CAUSE bit is 0. The address of I2C slave matches the address sent over SDA, and I2Cslave needs to send data.
12. Write data to be sent to TX RAM of I2C slave in either FIFO mode or non-FIFO mode according to Section 29.4.10 .
13. Set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to 1 to release SCL.

| Command registers of I2C master   | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |    |
|-----------------------------------|-----------|-------------|-----------|-------------------------|----|
| I2C_COMMAND0  (mas ter)          | RSTART    | —           | —         | —                       | —  |
| I2C_COMMAND1 (master)             | WRITE     | 0           | 0         | 1                       | 1  |
| I2C_COMMAND2  (mas ter)          | READ      | 0           | 0         | 1                       | N  |
| I2C_COMMAND3  (mas ter)          | END       | —           | —         | —                       | —  |

14. I2C slave sends data, and I2C master checks ACK value or not according to ack\_check\_en (master) in the READ command.
15. If data to be read by I2Cmaster in one READ command (N or M) is larger than the TX FIFO depth of I2Cslave , an I2C\_SLAVE\_STRETCH\_INT (slave) interrupt will be generated when TX RAM of I2Cslave becomes empty. In this way, I2Cslave can hold SCL low, so that software has more time to pad data in TX RAM of I2C slave and read data in RX RAM of I2C master . After software has finished reading, you can set I2C\_SLAVE\_STRETCH\_INT\_CLR (slave) to 1 to clear interrupt, and set I2C\_SLAVE\_SCL\_STRETCH\_CLR (slave) to release the SCL line.
16. Once finishing reading data in the first READ command, I2Cmaster executes the END command and triggers an I2C\_END\_DETECT\_INT (master) interrupt, which is cleared by setting I2C\_END\_DETECT\_INT\_CLR (master) to 1.
17. Update I2Cmaster’s command registers using one of the following two methods:

| Command registers of I2C master   | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |    |
|-----------------------------------|-----------|-------------|-----------|-------------------------|----|
| I2C_COMMAND0  (mas ter)          | READ      | ack_value   | ack_exp   | 1                       | M  |
| I2C_COMMAND1 (master)             | END       | —           | —         | —                       | —  |

Or

| Command registers of I2C master   | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |     |
|-----------------------------------|-----------|-------------|-----------|-------------------------|-----|
| I2C_COMMAND0  (mas ter)          | READ      | 0           | 0         | 1                       | M-1 |
| I2C_COMMAND0  (mas ter)          | READ      | 1           | 0         | 1                       | 1   |
| I2C_COMMAND1 (master)             | STOP      | —           | —         | —                       | —   |

18. Write M bytes of data to be sent to TX RAM of I2Cslave. If M is larger than the TX FIFO depth, then repeat step 12 in FIFO or non-FIFO mode.
19. Write 1 to I2C\_TRANS\_START (master) bit to start transfer and repeat step 14.
20. If the last command is a STOP, then set ack\_value (master) to 1 after I2Cmaster has received the last byte of data. I2C slave stops transfer upon the I2C\_NACK\_INT interrupt. I2Cmaster executes the STOP command to stop transfer and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.
21. If the last command is an END, then repeat step 16 and proceed on to the next steps.
22. Update I2Cmaster’s command registers.
23. Write 1 to I2C\_TRANS\_START (master) bit to start transfer.

| Command registers of I2C master   | op_code   | ack_value   | ack_exp   | ack_check_en byte_num   |    |
|-----------------------------------|-----------|-------------|-----------|-------------------------|----|
| I2C_COMMAND1 (master)             | STOP      | —           | —         | —                       | —  |

24. I2C master executes the STOP command to stop transfer, and generates an I2C\_TRANS\_COMPLETE\_INT (master) interrupt.

## 29.7 Interrupts

- I2C\_SLAVE\_STRETCH\_INT: Generated when one of the four stretching events occurs in slave mode.
- I2C\_DET\_START\_INT: Triggered when the master or the slave detects a START signal.
- I2C\_SCL\_MAIN\_ST\_TO\_INT: Triggered when the main state machine SCL\_MAIN\_FSM remains unchanged for over I2C\_SCL\_MAIN\_ST\_TO\_I2C[23:0] clock cycles.
- I2C\_SCL\_ST\_TO\_INT: Triggered when the state machine SCL\_FSM remains unchanged for over I2C\_SCL\_ST\_TO\_I2C[23:0] clock cycles.
- I2C\_RXFIFO\_UDF\_INT: Triggered when the I2C controller reads RX FIFO via the APB bus, but RX FIFO is empty.
- I2C\_TXFIFO\_OVF\_INT: Triggered when the I2C controller writes TX FIFO via the APB bus, but TX FIFO is full.
- I2C\_NACK\_INT: Triggered when the ACK value received by the master is not as expected, or when the ACK value received by the slave is 1.
- I2C\_TRANS\_START\_INT: Triggered when the I2C controller sends a START bit.
- I2C\_TIME\_OUT\_INT: Triggered when SCL stays high or low for more than 2 I2C \_ T IME \_ OUT \_ V ALUE clock cycles during data transfer.
- I2C\_TRANS\_COMPLETE\_INT: Triggered when the I2C controller detects a STOP bit.
- I2C\_MST\_TXFIFO\_UDF\_INT: Triggered when TX FIFO of the master underflows.
- I2C\_ARBITRATION\_LOST\_INT: Triggered when the SDA's output value does not match its input value while the master's SCL is high.
- I2C\_BYTE\_TRANS\_DONE\_INT: Triggered when the I2C controller sends or receives a byte.
- I2C\_END\_DETECT\_INT: Triggered when op\_code of the master indicates an END command and an END condition is detected.
- I2C\_RXFIFO\_OVF\_INT: Triggered when RX FIFO of the I2C controller overflows.
- I2C\_TXFIFO\_WM\_INT: I2C TX FIFO watermark interrupt. Triggered when I2C\_FIFO\_PRT\_EN is 1 and the pointers of TX FIFO are less than I2C\_TXFIFO\_WM\_THRHD[4:0].
- I2C\_RXFIFO\_WM\_INT: I2C RX FIFO watermark interrupt. Triggered when I2C\_FIFO\_PRT\_EN is 1 and the pointers of RX FIFO are greater than I2C\_RXFIFO\_WM\_THRHD[4:0].
- I2C\_SLAVE\_ADDR\_UNMATCH\_INT: Triggered when the received slave address is inconsistent with the internally configured slave address in slave mode.

## 29.8 Register Summary

## 29.9 I2C Register Summary

The addresses in this section are relative to I2C Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

R/SS/WTC

| Name                         | Description                                                                                                | Address   | Access   |
|------------------------------|------------------------------------------------------------------------------------------------------------|-----------|----------|
| Timing registers             |                                                                                                            |           |          |
| I2C_SCL_LOW_PERIOD_REG       | Configures the low level width of the SCL Clock                                                            | 0x0000    | R/W      |
| I2C_SDA_HOLD_REG             | Configures the hold time after a negative SCL edge                                                         | 0x0030    | R/W      |
| I2C_SDA_SAMPLE_REG           | Configures the sample time after a positive SCL edge                                                       | 0x0034    | R/W      |
| I2C_SCL_HIGH_PERIOD_REG      | Configures the high level width of SCL                                                                     | 0x0038    | R/W      |
| I2C_SCL_START_HOLD_REG       | Configures the delay between the SDA and SCL negative edge for a start condition                           | 0x0040    | R/W      |
| I2C_SCL_RSTART_SETUP_REG     | Configures the delay between the positive edge of SCL and the negative edge of SDA                         | 0x0044    | R/W      |
| I2C_SCL_STOP_HOLD_REG        | Configures the delay after the SCL clock edge for a stop condition                                         | 0x0048    | R/W      |
| I2C_SCL_STOP_SETUP_REG       | Configures the delay between the SDA and SCL rising edge for a stop condition Measure ment unit: i2c_sclk | 0x004C    | R/W      |
| I2C_SCL_ST_TIME_OUT_REG      | SCL status time out register                                                                               | 0x0078    | R/W      |
| I2C_SCL_MAIN_ST_TIME_OUT_REG | SCL main status time out register                                                                          | 0x007C    | R/W      |
| Configuration registers      |                                                                                                            |           |          |
| I2C_CTR_REG                  | Transmission setting                                                                                       | 0x0004    | varies   |
| I2C_TO_REG                   | Setting time out control for receiving data                                                                | 0x000C    | R/W      |
| I2C_SLAVE_ADDR_REG           | Local slave address setting                                                                                | 0x0010    | R/W      |
| I2C_FIFO_CONF_REG            | FIFO configuration register                                                                                | 0x0018    | R/W      |
| I2C_FILTER_CFG_REG           | SCL and SDA filter configuration register                                                                  | 0x0050    | R/W      |
| I2C_SCL_SP_CONF_REG          | Power configuration register                                                                               | 0x0080    | varies   |
| I2C_SCL_STRETCH_CONF_REG     | Set SCL stretch of I2C slave                                                                               | 0x0084    | varies   |
| Status registers             |                                                                                                            |           |          |
| I2C_SR_REG                   | Describe I2C work status                                                                                   | 0x0008    | RO       |
| I2C_FIFO_ST_REG              | FIFO status register                                                                                       | 0x0014    | RO       |
| I2C_DATA_REG                 | Rx FIFO read data                                                                                          | 0x001C    | HRO      |
| Interrupt registers          |                                                                                                            |           |          |
| I2C_INT_RAW_REG              | Raw interrupt status                                                                                       | 0x0020    |          |
| I2C_INT_CLR_REG              | Interrupt clear bits                                                                                       | 0x0024    | WT       |
| I2C_INT_ENA_REG              | Interrupt enable bits                                                                                      | 0x0028    | R/W      |

![Image](images/29_Chapter_29_img017_1258e9ef.png)

| Name                      | Description                                 | Address           | Access            |
|---------------------------|---------------------------------------------|-------------------|-------------------|
| I2C_INT_STATUS_REG        | Status of captured I2C communication events | 0x002C            | RO                |
| Command registers         | Command registers                           | Command registers | Command registers |
| I2C_COMD0_REG             | I2C command register 0                      | 0x0058            | varies            |
| I2C_COMD1_REG             | I2C command register 1                      | 0x005C            | varies            |
| I2C_COMD2_REG             | I2C command register 2                      | 0x0060            | varies            |
| I2C_COMD3_REG             | I2C command register 3                      | 0x0064            | varies            |
| I2C_COMD4_REG             | I2C command register 4                      | 0x0068            | varies            |
| I2C_COMD5_REG             | I2C command register 5                      | 0x006C            | varies            |
| I2C_COMD6_REG             | I2C command register 6                      | 0x0070            | varies            |
| I2C_COMD7_REG             | I2C command register 7                      | 0x0074            | varies            |
| Version register          | Version register                            | Version register  | Version register  |
| I2C_DATE_REG              | Version register                            | 0x00F8            | R/W               |
| Address register          | Address register                            | Address register  | Address register  |
| I2C_TXFIFO_START_ADDR_REG | I2C TXFIFO base address register            | 0x0100            | HRO               |
| I2C_RXFIFO_START_ADDR_REG | I2C RXFIFO base address register            | 0x0180            | HRO               |

## 29.10 LP\_I2C Register Summary

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                            | Description                                                                        | Address   | Access   |
|---------------------------------|------------------------------------------------------------------------------------|-----------|----------|
| Timing registers                |                                                                                    |           |          |
| LP_I2C_SCL_LOW_PERIOD_REG       | Configures the low level width of the SCL Clock                                    | 0x0000    | R/W      |
| LP_I2C_SDA_HOLD_REG             | Configures the hold time after a negative SCL edge                                 | 0x0030    | R/W      |
| LP_I2C_SDA_SAMPLE_REG           | Configures the sample time after a positive SCL edge                               | 0x0034    | R/W      |
| LP_I2C_SCL_HIGH_PERIOD_REG      | Configures the high level width of SCL                                             | 0x0038    | R/W      |
| LP_I2C_SCL_START_HOLD_REG       | Configures the delay between the SDA and SCL negative edge for a start condition   | 0x0040    | R/W      |
| LP_I2C_SCL_RSTART_SETUP_REG     | Configures the delay between the positive edge of SCL and the negative edge of SDA | 0x0044    | R/W      |
| LP_I2C_SCL_STOP_HOLD_REG        | Configures the delay after the SCL clock edge for a stop condition                 | 0x0048    | R/W      |
| LP_I2C_SCL_STOP_SETUP_REG       | Configures the delay between the SDA and SCL positive edge for a stop condition    | 0x004C    | R/W      |
| LP_I2C_SCL_ST_TIME_OUT_REG      | SCL status time out register                                                       | 0x0078    | R/W      |
| LP_I2C_SCL_MAIN_ST_TIME_OUT_REG | SCL main status time out register                                                  | 0x007C    | R/W      |
| Configuration registers         |                                                                                    |           |          |
| LP_I2C_CTR_REG                  | Transmission setting                                                               | 0x0004    | varies   |
| LP_I2C_TO_REG                   | Setting time out control for receiving data                                        | 0x000C    | R/W      |
| LP_I2C_FIFO_CONF_REG            | FIFO configuration register                                                        | 0x0018    | R/W      |
| LP_I2C_FILTER_CFG_REG           | SCL and SDA filter configuration register                                          | 0x0050    | R/W      |

R/SS/WTC

| Name                         | Description                                 | Address   | Access   |
|------------------------------|---------------------------------------------|-----------|----------|
| LP_I2C_SCL_SP_CONF_REG       | Power configuration register                | 0x0080    | varies   |
| Status registers             |                                             |           |          |
| LP_I2C_SR_REG                | Describe I2C work status                    | 0x0008    | RO       |
| LP_I2C_FIFO_ST_REG           | FIFO status register                        | 0x0014    | RO       |
| LP_I2C_DATA_REG              | Rx FIFO read data                           | 0x001C    | RO       |
| Interrupt registers          |                                             |           |          |
| LP_I2C_INT_RAW_REG           | Raw interrupt status                        | 0x0020    |          |
| LP_I2C_INT_CLR_REG           | Interrupt clear bits                        | 0x0024    | WT       |
| LP_I2C_INT_ENA_REG           | Interrupt enable bits                       | 0x0028    | R/W      |
| LP_I2C_INT_STATUS_REG        | Status of captured I2C communication events | 0x002C    | RO       |
| Command registers            |                                             |           |          |
| LP_I2C_COMD0_REG             | I2C command register 0                      | 0x0058    | varies   |
| LP_I2C_COMD1_REG             | I2C command register 1                      | 0x005C    | varies   |
| LP_I2C_COMD2_REG             | I2C command register 2                      | 0x0060    | varies   |
| LP_I2C_COMD3_REG             | I2C command register 3                      | 0x0064    | varies   |
| LP_I2C_COMD4_REG             | I2C command register 4                      | 0x0068    | varies   |
| LP_I2C_COMD5_REG             | I2C command register 5                      | 0x006C    | varies   |
| LP_I2C_COMD6_REG             | I2C command register 6                      | 0x0070    | varies   |
| LP_I2C_COMD7_REG             | I2C command register 7                      | 0x0074    | varies   |
| Version register             |                                             |           |          |
| LP_I2C_DATE_REG              | Version register                            | 0x00F8    | R/W      |
| Address register             |                                             |           |          |
| LP_I2C_TXFIFO_START_ADDR_REG | I2C TXFIFO base address register            | 0x0100    | HRO      |
| LP_I2C_RXFIFO_START_ADDR_REG | I2C RXFIFO base address register            | 0x0180    | HRO      |

## 29.11 I2C Registers

The addresses in this section are relative to I2C Controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 29.1. I2C\_SCL\_LOW\_PERIOD\_REG (0x0000)

![Image](images/29_Chapter_29_img018_da7e7644.png)

I2C\_SCL\_LOW\_PERIOD Configures the low level width of the SCL Clock in master mode.

Measurement unit: i2c\_sclk

(R/W)

Register 29.2. I2C\_SDA\_HOLD\_REG (0x0030)

![Image](images/29_Chapter_29_img019_311488e3.png)

I2C\_SDA\_HOLD\_TIME Configures the time to hold the data after the falling edge of SCL.

Measurement unit: i2c\_sclk

(R/W)

Register 29.3. I2C\_SDA\_SAMPLE\_REG (0x0034)

![Image](images/29_Chapter_29_img020_1e53015f.png)

Register 29.4. I2C\_SCL\_HIGH\_PERIOD\_REG (0x0038)

![Image](images/29_Chapter_29_img021_807b19f6.png)

- I2C\_SCL\_HIGH\_PERIOD Configures for how long SCL remains high in master mode.
- I2C\_SCL\_WAIT\_HIGH\_PERIOD Configures the SCL\_FSM’s waiting period for SCL high level in mas-

Measurement unit: i2c\_sclk

(R/W)

ter mode.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.5. I2C\_SCL\_START\_HOLD\_REG (0x0040)

![Image](images/29_Chapter_29_img022_9f617b5b.png)

- I2C\_SCL\_START\_HOLD\_TIME Configures the time between the falling edge of SDA and the falling edge of SCL for a START condition.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.6. I2C\_SCL\_RSTART\_SETUP\_REG (0x0044)

![Image](images/29_Chapter_29_img023_b4ceaba3.png)

I2C\_SCL\_RSTART\_SETUP\_TIME Configures the time between the positive edge of SCL and the negative edge of SDA for a RESTART condition.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.7. I2C\_SCL\_STOP\_HOLD\_REG (0x0048)

![Image](images/29_Chapter_29_img024_67db3dae.png)

I2C\_SCL\_STOP\_HOLD\_TIME Configures the delay after the STOP condition.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.8. I2C\_SCL\_STOP\_SETUP\_REG (0x004C)

![Image](images/29_Chapter_29_img025_89605066.png)

I2C\_SCL\_STOP\_SETUP\_TIME Configures the time between the rising edge of SCL and the rising edge of SDA.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.9. I2C\_SCL\_ST\_TIME\_OUT\_REG (0x0078)

![Image](images/29_Chapter_29_img026_af0047d4.png)

I2C\_SCL\_ST\_TO\_I2C Configures the threshold value of SCL\_FSM state unchanged period. It should be no more than 23.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.10. I2C\_SCL\_MAIN\_ST\_TIME\_OUT\_REG (0x007C)

![Image](images/29_Chapter_29_img027_065e8585.png)

- I2C\_SCL\_MAIN\_ST\_TO\_I2C Configures the threshold value of SCL\_MAIN\_FSM state unchanged period. It should be no more than 23.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.11. I2C\_CTR\_REG (0x0004)

![Image](images/29_Chapter_29_img028_f733aacf.png)

- I2C\_SDA\_FORCE\_OUT Configures the SDA output mode.
- 0: Open drain output
- 1: Direct output

(R/W)

- I2C\_SCL\_FORCE\_OUT Configures the SCL output mode.
- 0: Open drain output
- 1: Direct output
- (R/W)
- I2C\_SAMPLE\_SCL\_LEVEL Configures the sample mode for SDA.
- 0: Sample SDA data on the SCL high level
- 1: Sample SDA data on the SCL low level

(R/W)

- I2C\_RX\_FULL\_ACK\_LEVEL Configures the ACK value that needs to be sent by master when the
- rx\_fifo\_cnt has reached the threshold.
- (R/W)
- I2C\_MS\_MODE Configures the module as an I2C Master or Slave.
- 0: Slave
- 1: Master
- (R/W)
- I2C\_TRANS\_START Configures whether the slave starts sending the data in txfifo.
- 0: No effect
- 1: Start (WT)
- I2C\_TX\_LSB\_FIRST Configures to control the sending order for data needing to be sent.
- 0: send data from the most significant bit
- 1: send data from the least significant bit
- (R/W)
- I2C\_RX\_LSB\_FIRST Configures to control the storage order for received data.
- 0: receive data from the most significant bit
- 1: receive data from the least significant bit (R/W)

## Continued on the next page...

## Register 29.11. I2C\_CTR\_REG (0x0004)

## Continued from the previous page...

- I2C\_CLK\_EN Configures whether to gate clock signal for registers.
- 0: Support clock only when registers are read or written to by software
- 1: Force clock on for registers

(R/W)

- I2C\_ARBITRATION\_EN Configures to enable I2C bus arbitration detection.
- 0: No effect
- 1: Enable

(R/W)

- I2C\_FSM\_RST Configures to reset the SCL\_FSM.
- 0: No effect
- 1: Reset (WT)
- I2C\_CONF\_UPGATE Configures this bit for synchronization.
- 0: No effect
- 1: Synchronize (WT)
- I2C\_SLV\_TX\_AUTO\_START\_EN Configures to enable slave to send data automatically
- 0: Disable

1: Enable

(R/W)

- I2C\_ADDR\_10BIT\_RW\_CHECK\_EN Configures to check if the r/w bit of 10bit addressing consists

with I2C protocol.

- 0: Not check
- 1: Check (R/W)
- I2C\_ADDR\_BROADCASTING\_EN Configures to support the 7 bit general call function.
- 0: Not support
- 1: Support

(R/W)

## Register 29.12. I2C\_TO\_REG (0x000C)

![Image](images/29_Chapter_29_img029_6bf07c3f.png)

I2C\_TIME\_OUT\_VALUE Configures the timeout threshold period for SCL stucking at high or low level.

The actual period is 2^(reg\_time\_out\_value).

Measurement unit: i2c\_sclk

(R/W)

## I2C\_TIME\_OUT\_EN Configures to enable time out control.

- 0: No effect
- 1: Enable

(R/W)

## Register 29.13. I2C\_SLAVE\_ADDR\_REG (0x0010)

![Image](images/29_Chapter_29_img030_86c5f40e.png)

I2C\_SLAVE\_ADDR Configure the slave address of I2C Slave.

(R/W)

- I2C\_ADDR\_10BIT\_EN Configures to enable the slave 10-bit addressing mode in master mode.
- 0: No effect
- 1: Enable

(R/W)

## Register 29.14. I2C\_FIFO\_CONF\_REG (0x0018)

![Image](images/29_Chapter_29_img031_3a5f98b3.png)

- I2C\_RXFIFO\_WM\_THRHD Configures the water mark threshold of RXFIFO in nonfifo access mode. When I2C\_FIFO\_PRT\_EN is 1 and RX FIFO counter is bigger than I2C\_RXFIFO\_WM\_THRHD[4:0], I2C\_RXFIFO\_WM\_INT\_RAW bit will be valid. (R/W)
- I2C\_TXFIFO\_WM\_THRHD Configures the water mark threshold of TXFIFO in nonfifo access mode. When I2C\_FIFO\_PRT\_EN is 1 and TC FIFO counter is bigger than I2C\_TXFIFO\_WM\_THRHD[4:0], I2C\_TXFIFO\_WM\_INT\_RAW bit will be valid. (R/W)
- I2C\_NONFIFO\_EN Configures to enable APB nonfifo access. (R/W)
- I2C\_FIFO\_ADDR\_CFG\_EN Configures the slave to enable dual address mode. When this mode is enabled, the byte received after the I2C address byte represents the offset address in the I2C Slave RAM.
- 0: Disable
- 1: Enable
- (R/W)
- I2C\_RX\_FIFO\_RST Configures to reset RXFIFO.
- 0: No effect
- 1: Reset (R/W)
- I2C\_TX\_FIFO\_RST Configures to reset TXFIFO.
- 0: No effect
- 1: Reset (R/W)
- I2C\_FIFO\_PRT\_EN Configures to enable FIFO pointer in non-fifo access mode. This bit controls the valid bits and the TX/RX FIFO overflow, underflow, full and empty interrupts.
- 0: No effect
- 1: Enable
- (R/W)

## Register 29.15. I2C\_FILTER\_CFG\_REG (0x0050)

![Image](images/29_Chapter_29_img032_f36d4fb1.png)

- I2C\_SCL\_FILTER\_THRES Configures the threshold pulse width to be filtered on SCL. When a pulse on the SCL input has smaller width than this register value, the I2C controller will ignore that pulse. Measurement unit: i2c\_sclk (R/W)
- I2C\_SDA\_FILTER\_THRES Configures the threshold pulse width to be filtered on SDA. When a pulse on the SDA input has smaller width than this register value, the I2C controller will ignore that pulse. Measurement unit: i2c\_sclk (R/W)
- I2C\_SCL\_FILTER\_EN Configures to enable the filter function for SCL.
- 0: No effect
- 1: Enable

(R/W)

- I2C\_SDA\_FILTER\_EN Configures to enable the filter function for SDA.
- 0: No effect
- 1: Enable
- (R/W)

## Register 29.16. I2C\_SCL\_SP\_CONF\_REG (0x0080)

![Image](images/29_Chapter_29_img033_9d2c4512.png)

I2C\_SCL\_RST\_SLV\_EN Configures to send out SCL pulses when I2C master is IDLE. The number of pulses equals to I2C\_SCL\_RST\_SLV\_NUM[4:0]. (R/W/SC)

- I2C\_SCL\_RST\_SLV\_NUM Configure the pulses of SCL generated in I2C master mode.

Valid when I2C\_SCL\_RST\_SLV\_EN is 1.

Measurement unit: i2c\_sclk

(R/W)

- I2C\_SCL\_PD\_EN Configures to power down the I2C output SCL line.
- 0: Not power down.
- 1: Not work and power down.

Valid only when I2C\_SCL\_FORCE\_OUT is 1. (R/W)

- I2C\_SDA\_PD\_EN Configures to power down the I2C output SDA line.
- 0: Not power down.
- 1: Not work and power down.

Valid only when I2C\_SDA\_FORCE\_OUT is 1. (R/W)

## Register 29.17. I2C\_SCL\_STRETCH\_CONF\_REG (0x0084)

![Image](images/29_Chapter_29_img034_74d0a6a4.png)

- I2C\_STRETCH\_PROTECT\_NUM Configures the time period to release the SCL line from stretching to avoid timing violation. Usually it should be larger than the SDA setup time.

Measurement unit: i2c\_sclk

(R/W)

- I2C\_SLAVE\_SCL\_STRETCH\_EN Configures to enable slave SCL stretch function. The SCL output line will be stretched low when I2C\_SLAVE\_SCL\_STRETCH\_EN is 1 and stretch event happens.

The stretch cause can be seen in I2C\_STRETCH\_CAUSE.

0: Disable

1: Enable

(R/W)

- I2C\_SLAVE\_SCL\_STRETCH\_CLR Configures to clear the I2C slave SCL stretch function.
- 0: No effect
- 1: Clear

(WT)

- I2C\_SLAVE\_BYTE\_ACK\_CTL\_EN Configures to enable the function for slave to control ACK level.
- 0: Disable

1: Enable

(R/W)

- I2C\_SLAVE\_BYTE\_ACK\_LVL Set the ACK level when slave controlling ACK level function enables.
- 0: Low level

1: High level

(R/W)

## Register 29.18. I2C\_SR\_REG (0x0008)

![Image](images/29_Chapter_29_img035_011be4d8.png)

I2C\_RESP\_REC Represents the received ACK value in master mode or slave mode.

0: ACK

- 1: NACK. (RO)
- I2C\_SLAVE\_RW Represents the transfer direction in slave mode.
- 1: Master reads from slave
- 0: Master writes to slave. (RO)
- I2C\_ARB\_LOST Represents whether the I2C controller loses control of SCL line.
- 0: No arbitration lost
- 1: Arbitration lost

(RO)

- I2C\_BUS\_BUSY Represents the I2C bus state.
- 1: The I2C bus is busy transferring data
- 0: The I2C bus is in idle state.

(RO)

I2C\_SLAVE\_ADDRESSED Represents whether the address sent by the master is equal to the ad- dress of the slave.

Valid only when the module is configured as an I2C Slave.

- 0: Not equal

1: Equal

(RO)

I2C\_RXFIFO\_CNT Represents the number of data bytes received in RAM. (RO)

I2C\_STRETCH\_CAUSE Represents the cause of SCL clocking stretching in slave mode.

- 0: Stretching SCL low when the master starts to read data.
- 1: Stretching SCL low when I2C TX FIFO is empty in slave mode.
- 2: Stretching SCL low when I2C RX FIFO is full in slave mode. (RO)

I2C\_TXFIFO\_CNT Represents the number of data bytes to be sent. (RO)

Continued on the next page...

## Register 29.18. I2C\_SR\_REG (0x0008)

## Continued from the previous page...

I2C\_SCL\_MAIN\_STATE\_LAST Represents the states of the I2C module state machine.

- 0: Idle
- 1: Address shift
- 2: ACK address
- 3: Rx data
- 4: Tx data
- 5: Send ACK
- 6: Wait ACK (RO)
- I2C\_SCL\_STATE\_LAST Represents the states of the state machine used to produce SCL.
- 0: Idle
- 1: Start
- 2: Negative edge
- 3: Low
- 4: Positive edge
- 5: High
- 6: Stop (RO)

## Register 29.19. I2C\_FIFO\_ST\_REG (0x0014)

![Image](images/29_Chapter_29_img036_b5b11256.png)

- I2C\_RXFIFO\_RADDR Represents the offset address of the APB reading from RXFIFO. (RO)
- I2C\_RXFIFO\_WADDR Represents the offset address of i2c module receiving data and writing to RXFIFO. (RO)
- I2C\_TXFIFO\_RADDR Represents the offset address of i2c module reading from TXFIFO. (RO)
- I2C\_TXFIFO\_WADDR Represents the offset address of APB bus writing to TXFIFO. (RO)
- I2C\_SLAVE\_RW\_POINT Represents the offset address in the I2C Slave RAM addressed by I2C Master when in I2C slave mode. (RO)

## Register 29.20. I2C\_DATA\_REG (0x001C)

![Image](images/29_Chapter_29_img037_a92ac68b.png)

I2C\_FIFO\_RDATA Represents the value of RXFIFO read data. (RO)

## Register 29.21. I2C\_INT\_RAW\_REG (0x0020)

![Image](images/29_Chapter_29_img038_0137c55b.png)

- I2C\_RXFIFO\_WM\_INT\_RAW The raw interrupt status of I2C\_RXFIFO\_WM\_INT interrupt. (R/SS/WTC)
- I2C\_TXFIFO\_WM\_INT\_RAW The raw interrupt status of I2C\_TXFIFO\_WM\_INT interrupt. (R/SS/WTC)
- I2C\_RXFIFO\_OVF\_INT\_RAW The raw interrupt status of I2C\_RXFIFO\_OVF\_INT interrupt. (R/SS/WTC)
- I2C\_END\_DETECT\_INT\_RAW The raw interrupt status of the I2C\_END\_DETECT\_INT interrupt. (R/SS/WTC)
- I2C\_BYTE\_TRANS\_DONE\_INT\_RAW The raw interrupt status of the I2C\_BYTE\_TRANS\_DONE\_INT interrupt. (R/SS/WTC)
- I2C\_ARBITRATION\_LOST\_INT\_RAW The raw interrupt status of the I2C\_ARBITRATION\_LOST\_INT interrupt. (R/SS/WTC)
- I2C\_MST\_TXFIFO\_UDF\_INT\_RAW The raw interrupt status of I2C\_MST\_TXFIFO\_UDF\_INT interrupt. (R/SS/WTC)
- I2C\_TRANS\_COMPLETE\_INT\_RAW The raw interrupt status of the I2C\_TRANS\_COMPLETE\_INT interrupt. (R/SS/WTC)
- Continued on the next page...

## Register 29.21. I2C\_INT\_RAW\_REG (0x0020)

## Continued from the previous page...

- I2C\_TIME\_OUT\_INT\_RAW The raw interrupt status of the I2C\_TIME\_OUT\_INT interrupt. (R/SS/WTC)
- I2C\_TRANS\_START\_INT\_RAW The raw interrupt status of the I2C\_TRANS\_START\_INT interrupt. (R/SS/WTC)
- I2C\_NACK\_INT\_RAW The raw interrupt status of I2C\_NACK\_INT interrupt. (R/SS/WTC)
- I2C\_TXFIFO\_OVF\_INT\_RAW The raw interrupt status of I2C\_TXFIFO\_OVF\_INT interrupt. (R/SS/WTC)
- I2C\_RXFIFO\_UDF\_INT\_RAW The raw interrupt status of I2C\_RXFIFO\_UDF\_INT interrupt. (R/SS/WTC)
- I2C\_SCL\_ST\_TO\_INT\_RAW The raw interrupt status of I2C\_SCL\_ST\_TO\_INT interrupt. (R/SS/WTC)
- I2C\_SCL\_MAIN\_ST\_TO\_INT\_RAW The raw interrupt status of I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt. (R/SS/WTC)
- I2C\_DET\_START\_INT\_RAW The raw interrupt status of I2C\_DET\_START\_INT interrupt. (R/SS/WTC)
- I2C\_SLAVE\_STRETCH\_INT\_RAW The raw interrupt status of I2C\_SLAVE\_STRETCH\_INT interrupt. (R/SS/WTC)
- I2C\_GENERAL\_CALL\_INT\_RAW The raw interrupt status of I2C\_GENARAL\_CALL\_INT interrupt. (R/SS/WTC)
- I2C\_SLAVE\_ADDR\_UNMATCH\_INT\_RAW The raw interrupt status of I2C\_SLAVE\_ADDR\_UNMATCH\_INT\_RAW interrupt. (R/SS/WTC)

![Image](images/29_Chapter_29_img039_85e3427e.png)

Register 29.22. I2C\_INT\_CLR\_REG (0x0024)

![Image](images/29_Chapter_29_img040_c8e53f8f.png)

I2C\_RXFIFO\_WM\_INT\_CLR Write 1 to clear I2C\_RXFIFO\_WM\_INT interrupt. (WT) I2C\_TXFIFO\_WM\_INT\_CLR Write 1 to clear I2C\_TXFIFO\_WM\_INT interrupt. (WT) I2C\_RXFIFO\_OVF\_INT\_CLR Write 1 to clear I2C\_RXFIFO\_OVF\_INT interrupt. (WT) I2C\_END\_DETECT\_INT\_CLR Write 1 to clear the I2C\_END\_DETECT\_INT interrupt. (WT) I2C\_BYTE\_TRANS\_DONE\_INT\_CLR Write 1 to clear the I2C\_BYTE\_TRANS\_DONE\_INT interrupt. (WT) I2C\_ARBITRATION\_LOST\_INT\_CLR Write 1 to clear the I2C\_ARBITRATION\_LOST\_INT interrupt. (WT) I2C\_MST\_TXFIFO\_UDF\_INT\_CLR Write 1 to clear I2C\_MST\_TXFIFO\_UDF\_INT interrupt. (WT) I2C\_TRANS\_COMPLETE\_INT\_CLR Write 1 to clear the I2C\_TRANS\_COMPLETE\_INT interrupt. (WT) I2C\_TIME\_OUT\_INT\_CLR Write 1 to clear the I2C\_TIME\_OUT\_INT interrupt. (WT) I2C\_TRANS\_START\_INT\_CLR Write 1 to clear the I2C\_TRANS\_START\_INT interrupt. (WT) I2C\_NACK\_INT\_CLR Write 1 to clear I2C\_NACK\_INT interrupt. (WT) I2C\_TXFIFO\_OVF\_INT\_CLR Write 1 to clear I2C\_TXFIFO\_OVF\_INT interrupt. (WT) I2C\_RXFIFO\_UDF\_INT\_CLR Write 1 to clear I2C\_RXFIFO\_UDF\_INT interrupt. (WT) I2C\_SCL\_ST\_TO\_INT\_CLR Write 1 to clear I2C\_SCL\_ST\_TO\_INT interrupt. (WT) I2C\_SCL\_MAIN\_ST\_TO\_INT\_CLR Write 1 to clear I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt. (WT) I2C\_DET\_START\_INT\_CLR Write 1 to clear I2C\_DET\_START\_INT interrupt. (WT) I2C\_SLAVE\_STRETCH\_INT\_CLR Write 1 to clear I2C\_SLAVE\_STRETCH\_INT interrupt. (WT) I2C\_GENERAL\_CALL\_INT\_CLR Write 1 to clear I2C\_GENARAL\_CALL\_INT interrupt. (WT) I2C\_SLAVE\_ADDR\_UNMATCH\_INT\_CLR Write 1 to clear I2C\_SLAVE\_ADDR\_UNMATCH\_INT\_RAW interrupt. (WT)

Register 29.23. I2C\_INT\_ENA\_REG (0x0028)

![Image](images/29_Chapter_29_img041_36a78cef.png)

I2C\_RXFIFO\_WM\_INT\_ENA Write 1 to enable I2C\_RXFIFO\_WM\_INT interrupt. (R/W) I2C\_TXFIFO\_WM\_INT\_ENA Write 1 to enable I2C\_TXFIFO\_WM\_INT interrupt. (R/W) I2C\_RXFIFO\_OVF\_INT\_ENA Write 1 to enable I2C\_RXFIFO\_OVF\_INT interrupt. (R/W) I2C\_END\_DETECT\_INT\_ENA Write 1 to enable the I2C\_END\_DETECT\_INT interrupt. (R/W) I2C\_BYTE\_TRANS\_DONE\_INT\_ENA Write 1 to enable the I2C\_BYTE\_TRANS\_DONE\_INT interrupt. (R/W) I2C\_ARBITRATION\_LOST\_INT\_ENA Write 1 to enable the I2C\_ARBITRATION\_LOST\_INT interrupt. (R/W) I2C\_MST\_TXFIFO\_UDF\_INT\_ENA Write 1 to enable I2C\_MST\_TXFIFO\_UDF\_INT interrupt. (R/W) I2C\_TRANS\_COMPLETE\_INT\_ENA Write 1 to enable the I2C\_TRANS\_COMPLETE\_INT interrupt. (R/W) I2C\_TIME\_OUT\_INT\_ENA Write 1 to enable the I2C\_TIME\_OUT\_INT interrupt. (R/W) I2C\_TRANS\_START\_INT\_ENA Write 1 to enable the I2C\_TRANS\_START\_INT interrupt. (R/W) I2C\_NACK\_INT\_ENA Write 1 to enable I2C\_NACK\_INT interrupt. (R/W) I2C\_TXFIFO\_OVF\_INT\_ENA Write 1 to enable I2C\_TXFIFO\_OVF\_INT interrupt. (R/W) I2C\_RXFIFO\_UDF\_INT\_ENA Write 1 to enable I2C\_RXFIFO\_UDF\_INT interrupt. (R/W) I2C\_SCL\_ST\_TO\_INT\_ENA Write 1 to enable I2C\_SCL\_ST\_TO\_INT interrupt. (R/W) I2C\_SCL\_MAIN\_ST\_TO\_INT\_ENA Write 1 to enable I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt. (R/W) I2C\_DET\_START\_INT\_ENA Write 1 to enable I2C\_DET\_START\_INT interrupt. (R/W) I2C\_SLAVE\_STRETCH\_INT\_ENA Write 1 to enable I2C\_SLAVE\_STRETCH\_INT interrupt. (R/W) I2C\_GENERAL\_CALL\_INT\_ENA Write 1 to enable I2C\_GENARAL\_CALL\_INT interrupt. (R/W) I2C\_SLAVE\_ADDR\_UNMATCH\_INT\_ENA Write 1 to enable I2C\_SLAVE\_ADDR\_UNMATCH\_INT inter-

- rupt. (R/W)

Submit Documentation Feedback

## Register 29.24. I2C\_INT\_STATUS\_REG (0x002C)

![Image](images/29_Chapter_29_img042_c652883e.png)

- I2C\_RXFIFO\_WM\_INT\_ST The masked interrupt status status of I2C\_RXFIFO\_WM\_INT interrupt. (RO)
- I2C\_TXFIFO\_WM\_INT\_ST The masked interrupt status status of I2C\_TXFIFO\_WM\_INT interrupt. (RO)
- I2C\_RXFIFO\_OVF\_INT\_ST The masked interrupt status status of I2C\_RXFIFO\_OVF\_INT interrupt. (RO)
- I2C\_END\_DETECT\_INT\_ST The masked interrupt status status of the I2C\_END\_DETECT\_INT interrupt. (RO)
- I2C\_BYTE\_TRANS\_DONE\_INT\_ST The masked interrupt status status of the I2C\_BYTE\_TRANS\_DONE\_INT interrupt. (RO)
- I2C\_ARBITRATION\_LOST\_INT\_ST The masked interrupt status status of the I2C\_ARBITRATION\_LOST\_INT interrupt. (RO)
- I2C\_MST\_TXFIFO\_UDF\_INT\_ST The masked interrupt status status of I2C\_MST\_TXFIFO\_UDF\_INT interrupt. (RO)
- I2C\_TRANS\_COMPLETE\_INT\_ST The masked interrupt status status of the I2C\_TRANS\_COMPLETE\_INT interrupt. (RO)
- I2C\_TIME\_OUT\_INT\_ST The masked interrupt status status of the I2C\_TIME\_OUT\_INT interrupt. (RO)
- I2C\_TRANS\_START\_INT\_ST The masked interrupt status status of the I2C\_TRANS\_START\_INT interrupt. (RO)
- I2C\_NACK\_INT\_ST The masked interrupt status status of I2C\_NACK\_INT interrupt. (RO)
- I2C\_TXFIFO\_OVF\_INT\_ST The masked interrupt status status of I2C\_TXFIFO\_OVF\_INT interrupt. (RO)

Continued on the next page...

## Register 29.24. I2C\_INT\_STATUS\_REG (0x002C)

## Continued from the previous page...

- I2C\_RXFIFO\_UDF\_INT\_ST The masked interrupt status status of I2C\_RXFIFO\_UDF\_INT interrupt. (RO)
- I2C\_SCL\_ST\_TO\_INT\_ST The masked interrupt status status of I2C\_SCL\_ST\_TO\_INT interrupt. (RO)
- I2C\_SCL\_MAIN\_ST\_TO\_INT\_ST The masked interrupt status status of I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt. (RO)
- I2C\_DET\_START\_INT\_ST The masked interrupt status status of I2C\_DET\_START\_INT interrupt. (RO)
- I2C\_SLAVE\_STRETCH\_INT\_ST The masked interrupt status status of I2C\_SLAVE\_STRETCH\_INT interrupt. (RO)
- I2C\_GENERAL\_CALL\_INT\_ST The masked interrupt status status of I2C\_GENARAL\_CALL\_INT interrupt. (RO)
- I2C\_SLAVE\_ADDR\_UNMATCH\_INT\_ST The masked interrupt status status of I2C\_SLAVE\_ADDR\_UNMATCH\_INT interrupt. (RO)

![Image](images/29_Chapter_29_img043_b74a9d8d.png)

ESP32-C6 TRM (Version 1.1)

## Register 29.25. I2C\_COMD0\_REG (0x0058)

![Image](images/29_Chapter_29_img044_2723235f.png)

## I2C\_COMMAND0 Configures command 0.

It consists of three parts:

op\_code is the command

1: WRITE

2: STOP

3fiREAD

4fiEND

6fiRSTART

Byte\_num represents the number of bytes that need to be sent or received.

ack\_check\_en, ack\_exp and ack are used to control the ACK bit. See I2C cmd structure 29.4-2

for more information.

(R/W)

I2C\_COMMAND0\_DONE Represents whether command 0 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

Register 29.26. I2C\_COMD1\_REG (0x005C)

![Image](images/29_Chapter_29_img045_a0490e68.png)

## I2C\_COMMAND1 Configures command 1.

See details in I2C\_CMD0\_REG[13:0]. (R/W)

- I2C\_COMMAND1\_DONE Represents whether command 1 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.27. I2C\_COMD2\_REG (0x0060)

![Image](images/29_Chapter_29_img046_8c5a6fea.png)

I2C\_COMMAND2 Configures command 2. See details in I2C\_CMD0\_REG[13:0]. (R/W)

I2C\_COMMAND2\_DONE Represents whether command 2 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.28. I2C\_COMD3\_REG (0x0064)

![Image](images/29_Chapter_29_img047_e0a777b4.png)

I2C\_COMMAND3 Configures command 3. See details in I2C\_CMD0\_REG[13:0]. (R/W)

I2C\_COMMAND3\_DONE Represents whether command 3 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.29. I2C\_COMD4\_REG (0x0068)

![Image](images/29_Chapter_29_img048_36de8acc.png)

I2C\_COMMAND4 Configures command 4. See details in I2C\_CMD0\_REG[13:0]. (R/W)

I2C\_COMMAND4\_DONE Represents whether command 4 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.30. I2C\_COMD5\_REG (0x006C)

![Image](images/29_Chapter_29_img049_07356e7a.png)

I2C\_COMMAND5 Configures command 5. See details in I2C\_CMD0\_REG[13:0]. (R/W)

I2C\_COMMAND5\_DONE Represents whether command 5 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.31. I2C\_COMD6\_REG (0x0070)

![Image](images/29_Chapter_29_img050_636b13dd.png)

I2C\_COMMAND6 Configures command 6. See details in I2C\_CMD0\_REG[13:0]. (R/W)

I2C\_COMMAND6\_DONE Represents whether command 6 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.32. I2C\_COMD7\_REG (0x0074)

![Image](images/29_Chapter_29_img051_bab76d4e.png)

I2C\_COMMAND7 Configures command 7. See details in I2C\_CMD0\_REG[13:0]. (R/W)

I2C\_COMMAND7\_DONE Represents whether command 7 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.33. I2C\_DATE\_REG (0x00F8)

![Image](images/29_Chapter_29_img052_59fcfa68.png)

I2C\_DATE Version control register. (R/W)

Register 29.34. I2C\_TXFIFO\_START\_ADDR\_REG (0x0100)

I2C\_TXFIFO\_START\_ADDR

![Image](images/29_Chapter_29_img053_b7920bd7.png)

I2C\_TXFIFO\_START\_ADDR Represents the I2C txfifo first address. (HRO)

Register 29.35. I2C\_RXFIFO\_START\_ADDR\_REG (0x0180)

![Image](images/29_Chapter_29_img054_4c7d9ee9.png)

I2C\_RXFIFO\_START\_ADDR Represents the I2C rxfifo first address. (HRO)

## 29.11.1 LP\_I2C Register

Register 29.36. LP\_I2C\_SCL\_LOW\_PERIOD\_REG (0x0000)

![Image](images/29_Chapter_29_img055_44fd84e9.png)

LP\_I2C\_SCL\_LOW\_PERIOD Configures the low level width of the SCL Clock in master mode.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.37. LP\_I2C\_SDA\_HOLD\_REG (0x0030)

![Image](images/29_Chapter_29_img056_a96f1c9b.png)

LP\_I2C\_SDA\_HOLD\_TIME Configures the time to hold the data after the falling edge of SCL.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.38. LP\_I2C\_SDA\_SAMPLE\_REG (0x0034)

![Image](images/29_Chapter_29_img057_4bac55bb.png)

LP\_I2C\_SDA\_SAMPLE\_TIME Configures the time for sampling SDA.

Measurement unit: i2c\_sclk

(R/W)

Register 29.39. LP\_I2C\_SCL\_HIGH\_PERIOD\_REG (0x0038)

![Image](images/29_Chapter_29_img058_e42f0df9.png)

LP\_I2C\_SCL\_HIGH\_PERIOD Configures for how long SCL remains high in master mode.

Measurement unit: i2c\_sclk

(R/W)

- LP\_I2C\_SCL\_WAIT\_HIGH\_PERIOD Configures the SCL\_FSM’s waiting period for SCL high level in

master mode.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.40. LP\_I2C\_SCL\_START\_HOLD\_REG (0x0040)

![Image](images/29_Chapter_29_img059_b2627546.png)

- LP\_I2C\_SCL\_START\_HOLD\_TIME Configures the time between the falling edge of SDA and the

falling edge of SCL for a START condition.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.41. LP\_I2C\_SCL\_RSTART\_SETUP\_REG (0x0044)

![Image](images/29_Chapter_29_img060_f74697b6.png)

- LP\_I2C\_SCL\_RSTART\_SETUP\_TIME Configures the time between the positive edge of SCL and the negative edge of SDA for a RESTART condition.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.42. LP\_I2C\_SCL\_STOP\_HOLD\_REG (0x0048)

![Image](images/29_Chapter_29_img061_5c5af888.png)

- LP\_I2C\_SCL\_STOP\_HOLD\_TIME Configures the delay after the STOP condition.

Measurement unit: i2c\_sclk (R/W)

Register 29.43. LP\_I2C\_SCL\_STOP\_SETUP\_REG (0x004C)

![Image](images/29_Chapter_29_img062_0427199b.png)

LP\_I2C\_SCL\_STOP\_SETUP\_TIME Configures the time between the rising edge of SCL and the rising edge of SDA.

Measurement unit: i2c\_sclk

(R/W)

Register 29.44. LP\_I2C\_SCL\_ST\_TIME\_OUT\_REG (0x0078)

![Image](images/29_Chapter_29_img063_2ab8911f.png)

- LP\_I2C\_SCL\_ST\_TO\_I2C Configures the threshold value of SCL\_FSM state unchanged period. It should be no more than 23.

Measurement unit: i2c\_sclk

(R/W)

Register 29.45. LP\_I2C\_SCL\_MAIN\_ST\_TIME\_OUT\_REG (0x007C)

![Image](images/29_Chapter_29_img064_2227aa21.png)

- LP\_I2C\_SCL\_MAIN\_ST\_TO\_I2C Configures the threshold value of SCL\_MAIN\_FSM state unchanged period. It should be no more than 23.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.46. LP\_I2C\_CTR\_REG (0x0004)

![Image](images/29_Chapter_29_img065_7a1c62e1.png)

- LP\_I2C\_SAMPLE\_SCL\_LEVEL Configures the sample mode for SDA.
- 1: Sample SDA data on the SCL low level.
- 0: Sample SDA data on the SCL high level.

(R/W)

- LP\_I2C\_RX\_FULL\_ACK\_LEVEL Configures the ACK value that needs to be sent by master when the rx\_fifo\_cnt has reached the threshold. (R/W)
- LP\_I2C\_TRANS\_START Configures to start sending the data in txfifo for slave.
- 0: No effect
- 1: Start

(WT)

- LP\_I2C\_TX\_LSB\_FIRST Configures to control the sending order for data to be sent.
- 1: send data from the least significant bit
- 0: send data from the most significant bit
- (R/W)
- LP\_I2C\_RX\_LSB\_FIRST Configures to control the storage order for received data.
- 1: receive data from the least significant bit
- 0: receive data from the most significant bit
- (R/W)
- LP\_I2C\_CLK\_EN Configures whether to gate clock signal for registers.
- 0: Support clock only when registers are read or written to by software
- 1: Force clock on for registers.

(R/W)

- LP\_I2C\_ARBITRATION\_EN Configures to enable I2C bus arbitration detection.
- 0: No effect
- 1: Enable

(R/W)

- LP\_I2C\_FSM\_RST Configures to reset the SCL\_FSM.
- 0: No effect
- 1: Reset

(WT)

- LP\_I2C\_CONF\_UPGATE Configures this bit for synchronization.
- 0: No effect
- 1: Synchronize

ESP32-C6 TRM (Version 1.1)

## Register 29.47. LP\_I2C\_TO\_REG (0x000C)

![Image](images/29_Chapter_29_img066_59ceae09.png)

- LP\_I2C\_TIME\_OUT\_VALUE Configures the timeout threshold period for SCL stucking at high or low level. The actual period is 2^(reg\_time\_out\_value).

Measurement unit: i2c\_sclk.

(R/W)

- LP\_I2C\_TIME\_OUT\_EN Configures to enable time out control.
- 0: No effect
- 1: Enable
- (R/W)

## Register 29.48. LP\_I2C\_FIFO\_CONF\_REG (0x0018)

![Image](images/29_Chapter_29_img067_f4634af7.png)

- LP\_I2C\_RXFIFO\_WM\_THRHD Configures the water mark threshold of RXFIFO in nonfifo access mode. When LP\_I2C\_FIFO\_PRT\_EN is 1 and rx FIFO counter is bigger than LP\_I2C\_RXFIFO\_WM\_THRHD[4:0], LP\_I2C\_RXFIFO\_WM\_INT\_RAW bit will be valid. (R/W)
- LP\_I2C\_TXFIFO\_WM\_THRHD Configures the water mark threshold of TXFIFO in nonfifo access mode. When LP\_I2C\_FIFO\_PRT\_EN is 1 and rx FIFO counter is bigger than LP\_I2C\_TXFIFO\_WM\_THRHD[4:0], LP\_I2C\_TXFIFO\_WM\_INT\_RAW bit will be valid. (R/W)
- LP\_I2C\_NONFIFO\_EN Configures to enable APB nonfifo access. (R/W)
- LP\_I2C\_RX\_FIFO\_RST Configures to reset RXFIFO.

0: No effect

1: Reset

(R/W)

- LP\_I2C\_TX\_FIFO\_RST Configures to reset TXFIFO. 0: No effect

1: Reset

(R/W)

- LP\_I2C\_FIFO\_PRT\_EN Configures to enable FIFO pointer in non-fifo access mode. This bit controls the valid bits and the TX/RX FIFO overflow, underflow, full and empty interrupts.

0: No effect

1: Enable

(R/W)

## Register 29.49. LP\_I2C\_FILTER\_CFG\_REG (0x0050)

![Image](images/29_Chapter_29_img068_30cb5e6f.png)

- LP\_I2C\_SCL\_FILTER\_THRES Configures the threshold pulse width to be filtered on SCL. When a pulse on the SCL input has smaller width than this value, the I2C controller will ignore that pulse. Measurement unit: i2c\_sclk

(R/W)

- LP\_I2C\_SDA\_FILTER\_THRES Configures the threshold pulse width to be filtered on SDA. When a pulse on the SDA input has smaller width than this value, the I2C controller will ignore that pulse. Measurement unit: i2c\_sclk (R/W)
- LP\_I2C\_SCL\_FILTER\_EN Configures to enable the filter function for SCL.
- 0: No effect
- 1: Enable

(R/W)

- LP\_I2C\_SDA\_FILTER\_EN Configures to enable the filter function for SDA.
- 0: No effect
- 1: Enable

(R/W)

## Register 29.50. LP\_I2C\_SCL\_SP\_CONF\_REG (0x0080)

![Image](images/29_Chapter_29_img069_24a9bd9a.png)

- LP\_I2C\_SCL\_RST\_SLV\_EN Configures to send out SCL pulses when I2C master is IDLE. The number of pulses equals to LP\_I2C\_SCL\_RST\_SLV\_NUM[4:0]. (R/W/SC)
- LP\_I2C\_SCL\_RST\_SLV\_NUM Configure the pulses of SCL generated in I2C master mode.

Valid when LP\_I2C\_SCL\_RST\_SLV\_EN is 1.

Measurement unit: i2c\_sclk

(R/W)

## Register 29.51. LP\_I2C\_SR\_REG (0x0008)

![Image](images/29_Chapter_29_img070_f1a90abf.png)

- LP\_I2C\_RESP\_REC Represents the received ACK value in master mode or slave mode.
- 0: ACK
- 1: NACK
- (RO)
- LP\_I2C\_ARB\_LOST Represents whether the I2C controller loses control of SCL line.
- 0: No arbitration lost
- 1: Arbitration lost
- (RO)
- LP\_I2C\_BUS\_BUSY Represents the I2C bus state.
- 1: The I2C bus is busy transferring data
- 0: The I2C bus is in idle state
- (RO)

LP\_I2C\_RXFIFO\_CNT Represents the number of data bytes received in RAM. (RO)

LP\_I2C\_TXFIFO\_CNT Represents the number of data bytes to be sent. (RO)

LP\_I2C\_SCL\_MAIN\_STATE\_LAST Represents the states of the I2C module state machine.

- 0: Idle
- 1: Address shift
- 2: ACK address
- 3: Rx data
- 4: Tx data
- 5: Send ACK
- 6: Wait ACK
- (RO)
- LP\_I2C\_SCL\_STATE\_LAST Represents the states of the state machine used to produce SCL.
- 0: Idle
- 1: Start
- 2: Negative edge
- 3: Low
- 4: Positive edge
- 5: High
- 6: Stop
- (RO)

Register 29.52. LP\_I2C\_FIFO\_ST\_REG (0x0014)

![Image](images/29_Chapter_29_img071_5038c1f9.png)

LP\_I2C\_RXFIFO\_RADDR Represents the offset address of the APB reading from RXFIFO (RO)

LP\_I2C\_RXFIFO\_WADDR Represents the offset address of i2c module receiving data and writing to RXFIFO. (RO)

LP\_I2C\_TXFIFO\_RADDR Represents the offset address of i2c module reading from TXFIFO. (RO)

LP\_I2C\_TXFIFO\_WADDR Represents the offset address of APB bus writing to TXFIFO. (RO)

Register 29.53. LP\_I2C\_DATA\_REG (0x001C)

![Image](images/29_Chapter_29_img072_eac405f4.png)

LP\_I2C\_FIFO\_RDATA Represents the value of RXFIFO read data. (RO)

## Register 29.54. LP\_I2C\_INT\_RAW\_REG (0x0020)

![Image](images/29_Chapter_29_img073_ab614723.png)

- LP\_I2C\_RXFIFO\_WM\_INT\_RAW The raw interrupt status of LP\_I2C\_RXFIFO\_WM\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_TXFIFO\_WM\_INT\_RAW The raw interrupt status of LP\_I2C\_TXFIFO\_WM\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_RXFIFO\_OVF\_INT\_RAW The raw interrupt status of LP\_I2C\_RXFIFO\_OVF\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_END\_DETECT\_INT\_RAW The raw interrupt status of the LP\_I2C\_END\_DETECT\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_BYTE\_TRANS\_DONE\_INT\_RAW The raw interrupt status of the LP\_I2C\_END\_DETECT\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_ARBITRATION\_LOST\_INT\_RAW The raw interrupt status of the LP\_I2C\_ARBITRATION\_LOST\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_MST\_TXFIFO\_UDF\_INT\_RAW The raw interrupt status of LP\_I2C\_TRANS\_COMPLETE\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_TRANS\_COMPLETE\_INT\_RAW The raw interrupt status of the LP\_I2C\_TRANS\_COMPLETE\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_TIME\_OUT\_INT\_RAW The raw interrupt status of the LP\_I2C\_TIME\_OUT\_INT interrupt. (R/SS/WTC)

## Continued on the next page...

## Register 29.54. LP\_I2C\_INT\_RAW\_REG (0x0020)

## Continued from the previous page...

- LP\_I2C\_TRANS\_START\_INT\_RAW The raw interrupt status of the LP\_I2C\_TRANS\_START\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_NACK\_INT\_RAW The raw interrupt status of LP\_I2C\_SLAVE\_STRETCH\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_TXFIFO\_OVF\_INT\_RAW The raw interrupt status of LP\_I2C\_TXFIFO\_OVF\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_RXFIFO\_UDF\_INT\_RAW The raw interrupt status of LP\_I2C\_RXFIFO\_UDF\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_SCL\_ST\_TO\_INT\_RAW The raw interrupt status of LP\_I2C\_SCL\_ST\_TO\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_SCL\_MAIN\_ST\_TO\_INT\_RAW The raw interrupt status of LP\_I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt. (R/SS/WTC)
- LP\_I2C\_DET\_START\_INT\_RAW The raw interrupt status of LP\_I2C\_DET\_START\_INT interrupt. (R/SS/WTC)

![Image](images/29_Chapter_29_img074_7cf4ec57.png)

## Register 29.55. LP\_I2C\_INT\_CLR\_REG (0x0024)

![Image](images/29_Chapter_29_img075_a58a083f.png)

LP\_I2C\_RXFIFO\_WM\_INT\_CLR Write 1 to clear LP\_I2C\_RXFIFO\_WM\_INT interrupt. (WT) LP\_I2C\_TXFIFO\_WM\_INT\_CLR Write 1 to clear LP\_I2C\_TXFIFO\_WM\_INT interrupt. (WT) LP\_I2C\_RXFIFO\_OVF\_INT\_CLR Write 1 to clear LP\_I2C\_RXFIFO\_OVF\_INT interrupt. (WT) LP\_I2C\_END\_DETECT\_INT\_CLR Write 1 to clear the LP\_I2C\_END\_DETECT\_INT interrupt. (WT)

- LP\_I2C\_BYTE\_TRANS\_DONE\_INT\_CLR Write 1 to clear the LP\_I2C\_END\_DETECT\_INT interrupt. (WT)
- LP\_I2C\_ARBITRATION\_LOST\_INT\_CLR Write 1 to clear the LP\_I2C\_ARBITRATION\_LOST\_INT interrupt. (WT)
- LP\_I2C\_MST\_TXFIFO\_UDF\_INT\_CLR Write 1 to clear LP\_I2C\_TRANS\_COMPLETE\_INT interrupt. (WT)
- LP\_I2C\_TRANS\_COMPLETE\_INT\_CLR Write 1 to clear the LP\_I2C\_TRANS\_COMPLETE\_INT interrupt. (WT)
- LP\_I2C\_TIME\_OUT\_INT\_CLR Write 1 to clear the LP\_I2C\_TIME\_OUT\_INT interrupt. (WT)
- LP\_I2C\_TRANS\_START\_INT\_CLR Write 1 to clear the LP\_I2C\_TRANS\_START\_INT interrupt. (WT)
- LP\_I2C\_NACK\_INT\_CLR Write 1 to clear LP\_I2C\_SLAVE\_STRETCH\_INT interrupt. (WT)
- LP\_I2C\_TXFIFO\_OVF\_INT\_CLR Write 1 to clear LP\_I2C\_TXFIFO\_OVF\_INT interrupt. (WT)
- LP\_I2C\_RXFIFO\_UDF\_INT\_CLR Write 1 to clear LP\_I2C\_RXFIFO\_UDF\_INT interrupt. (WT)
- LP\_I2C\_SCL\_ST\_TO\_INT\_CLR Write 1 to clear LP\_I2C\_SCL\_ST\_TO\_INT interrupt. (WT)
- LP\_I2C\_SCL\_MAIN\_ST\_TO\_INT\_CLR Write 1 to clear LP\_I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt. (WT)
- LP\_I2C\_DET\_START\_INT\_CLR Write 1 to clear LP\_I2C\_DET\_START\_INT interrupt. (WT)

## Register 29.56. LP\_I2C\_INT\_ENA\_REG (0x0028)

![Image](images/29_Chapter_29_img076_f9530401.png)

LP\_I2C\_RXFIFO\_WM\_INT\_ENA Write 1 to enable LP\_I2C\_RXFIFO\_WM\_INT interrupt. (R/W)

- LP\_I2C\_TXFIFO\_WM\_INT\_ENA Write 1 to enable LP\_I2C\_TXFIFO\_WM\_INT interrupt. (R/W)
- LP\_I2C\_RXFIFO\_OVF\_INT\_ENA Write 1 to enable LP\_I2C\_RXFIFO\_OVF\_INT interrupt. (R/W)
- LP\_I2C\_END\_DETECT\_INT\_ENA Write 1 to enable the LP\_I2C\_END\_DETECT\_INT interrupt. (R/W)
- LP\_I2C\_BYTE\_TRANS\_DONE\_INT\_ENA Write 1 to enable the LP\_I2C\_END\_DETECT\_INT interrupt. (R/W)
- LP\_I2C\_ARBITRATION\_LOST\_INT\_ENA Write 1 to enable the LP\_I2C\_ARBITRATION\_LOST\_INT interrupt. (R/W)
- LP\_I2C\_MST\_TXFIFO\_UDF\_INT\_ENA Write 1 to enable LP\_I2C\_TRANS\_COMPLETE\_INT interrupt. (R/W)
- LP\_I2C\_TRANS\_COMPLETE\_INT\_ENA Write 1 to enable the LP\_I2C\_TRANS\_COMPLETE\_INT interrupt. (R/W)
- LP\_I2C\_TIME\_OUT\_INT\_ENA Write 1 to enable the LP\_I2C\_TIME\_OUT\_INT interrupt. (R/W)
- LP\_I2C\_TRANS\_START\_INT\_ENA Write 1 to enable the LP\_I2C\_TRANS\_START\_INT interrupt. (R/W)
- LP\_I2C\_NACK\_INT\_ENA Write 1 to enable LP\_I2C\_SLAVE\_STRETCH\_INT interrupt. (R/W)
- LP\_I2C\_TXFIFO\_OVF\_INT\_ENA Write 1 to enable LP\_I2C\_TXFIFO\_OVF\_INT interrupt. (R/W)
- LP\_I2C\_RXFIFO\_UDF\_INT\_ENA Write 1 to enable LP\_I2C\_RXFIFO\_UDF\_INT interrupt. (R/W)
- LP\_I2C\_SCL\_ST\_TO\_INT\_ENA Write 1 to enable LP\_I2C\_SCL\_ST\_TO\_INT interrupt. (R/W)
- LP\_I2C\_SCL\_MAIN\_ST\_TO\_INT\_ENA Write 1 to enable LP\_I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt. (R/W)
- LP\_I2C\_DET\_START\_INT\_ENA Write 1 to enable LP\_I2C\_DET\_START\_INT interrupt. (R/W)

![Image](images/29_Chapter_29_img077_ef8d8410.png)

## Register 29.57. LP\_I2C\_INT\_STATUS\_REG (0x002C)

![Image](images/29_Chapter_29_img078_65c6a9c7.png)

- LP\_I2C\_RXFIFO\_WM\_INT\_ST The masked interrupt status status of LP\_I2C\_RXFIFO\_WM\_INT interrupt. (RO)
- LP\_I2C\_TXFIFO\_WM\_INT\_ST The masked interrupt status status of LP\_I2C\_TXFIFO\_WM\_INT interrupt. (RO)
- LP\_I2C\_RXFIFO\_OVF\_INT\_ST The masked interrupt status status of LP\_I2C\_RXFIFO\_OVF\_INT interrupt. (RO)
- LP\_I2C\_END\_DETECT\_INT\_ST The masked interrupt status status of the LP\_I2C\_END\_DETECT\_INT interrupt. (RO)
- LP\_I2C\_BYTE\_TRANS\_DONE\_INT\_ST The masked interrupt status status of the LP\_I2C\_END\_DETECT\_INT interrupt. (RO)
- LP\_I2C\_ARBITRATION\_LOST\_INT\_ST The masked interrupt status status of the LP\_I2C\_ARBITRATION\_LOST\_INT interrupt. (RO)
- LP\_I2C\_MST\_TXFIFO\_UDF\_INT\_ST The masked interrupt status status of LP\_I2C\_TRANS\_COMPLETE\_INT interrupt. (RO)
- LP\_I2C\_TRANS\_COMPLETE\_INT\_ST The masked interrupt status status of the LP\_I2C\_TRANS\_COMPLETE\_INT interrupt. (RO)
- LP\_I2C\_TIME\_OUT\_INT\_ST The masked interrupt status status of the LP\_I2C\_TIME\_OUT\_INT interrupt. (RO)
- LP\_I2C\_TRANS\_START\_INT\_ST The masked interrupt status status of the LP\_I2C\_TRANS\_START\_INT interrupt. (RO)

## Continued on the next page...

![Image](images/29_Chapter_29_img079_4224922c.png)

## Register 29.57. LP\_I2C\_INT\_STATUS\_REG (0x002C)

## Continued from the previous page...

- LP\_I2C\_NACK\_INT\_ST The masked interrupt status status of LP\_I2C\_SLAVE\_STRETCH\_INT interrupt. (RO)
- LP\_I2C\_TXFIFO\_OVF\_INT\_ST The masked interrupt status status of LP\_I2C\_TXFIFO\_OVF\_INT interrupt. (RO)
- LP\_I2C\_RXFIFO\_UDF\_INT\_ST The masked interrupt status status of LP\_I2C\_RXFIFO\_UDF\_INT interrupt. (RO)
- LP\_I2C\_SCL\_ST\_TO\_INT\_ST The masked interrupt status status of LP\_I2C\_SCL\_ST\_TO\_INT interrupt. (RO)
- LP\_I2C\_SCL\_MAIN\_ST\_TO\_INT\_ST The masked interrupt status status of LP\_I2C\_SCL\_MAIN\_ST\_TO\_INT interrupt. (RO)
- LP\_I2C\_DET\_START\_INT\_ST The masked interrupt status status of LP\_I2C\_DET\_START\_INT interrupt. (RO)

![Image](images/29_Chapter_29_img080_6e648a2d.png)

ESP32-C6 TRM (Version 1.1)

## Register 29.58. LP\_I2C\_COMD0\_REG (0x0058)

![Image](images/29_Chapter_29_img081_54f0969f.png)

## LP\_I2C\_COMMAND0 Configures command 0.

It consists of three parts:

op\_code is the command

- 0: RSTART
- 1: WRITE
- 2: READ
- 3: STOP
- 4: END.

Byte\_num represents the number of bytes that need to be sent or received. ack\_check\_en, ack\_exp and ack are used to control the ACK bit. See I2C cmd structure 29.4-2 for more information. (R/W)

- LP\_I2C\_COMMAND0\_DONE Represents whether command 0 is done in I2C Master mode.
- 0: Not done
- 1: Done

(R/W/SS)

## Register 29.59. LP\_I2C\_COMD1\_REG (0x005C)

![Image](images/29_Chapter_29_img082_c353f1eb.png)

## LP\_I2C\_COMMAND1 Configures command 1.

See details in I2C\_CMD0\_REG[13:0]. (R/W)

- LP\_I2C\_COMMAND1\_DONE Represents whether command 1 is done in I2C Master mode.
- 0: Not done
- 1: Done
- (R/W/SS)

## Register 29.60. LP\_I2C\_COMD2\_REG (0x0060)

![Image](images/29_Chapter_29_img083_0d0d40ca.png)

LP\_I2C\_COMMAND2 Configures command 2. See details in I2C\_CMD0\_REG[13:0]. (R/W)

LP\_I2C\_COMMAND2\_DONE Represents whether command 2 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.61. LP\_I2C\_COMD3\_REG (0x0064)

![Image](images/29_Chapter_29_img084_54f18d87.png)

LP\_I2C\_COMMAND3 Configures command 3. See details in I2C\_CMD0\_REG[13:0]. (R/W)

LP\_I2C\_COMMAND3\_DONE Represents whether command 3 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

Register 29.62. LP\_I2C\_COMD4\_REG (0x0068)

![Image](images/29_Chapter_29_img085_202f4354.png)

LP\_I2C\_COMMAND4 Configures command 4. See details in I2C\_CMD0\_REG[13:0]. (R/W)

LP\_I2C\_COMMAND4\_DONE Represents whether command 4 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.63. LP\_I2C\_COMD5\_REG (0x006C)

![Image](images/29_Chapter_29_img086_eb6cc5bb.png)

LP\_I2C\_COMMAND5 Configures command 5. See details in I2C\_CMD0\_REG[13:0]. (R/W)

LP\_I2C\_COMMAND5\_DONE Represents whether command 5 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

Register 29.64. LP\_I2C\_COMD6\_REG (0x0070)

![Image](images/29_Chapter_29_img087_e9d9010d.png)

LP\_I2C\_COMMAND6 Configures command 6. See details in I2C\_CMD0\_REG[13:0]. (R/W)

LP\_I2C\_COMMAND6\_DONE Represents whether command 6 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.65. LP\_I2C\_COMD7\_REG (0x0074)

![Image](images/29_Chapter_29_img088_ce33ccb8.png)

LP\_I2C\_COMMAND7 Configures command 7. See details in I2C\_CMD0\_REG[13:0]. (R/W)

LP\_I2C\_COMMAND7\_DONE Represents whether command 7 is done in I2C Master mode.

0: Not done

1: Done

(R/W/SS)

## Register 29.66. LP\_I2C\_DATE\_REG (0x00F8)

![Image](images/29_Chapter_29_img089_fabbc721.png)

![Image](images/29_Chapter_29_img090_f990f1ec.png)

LP\_I2C\_DATE Version control register. (R/W)

## Register 29.67. LP\_I2C\_TXFIFO\_START\_ADDR\_REG (0x0100)

LP\_I2C\_TXFIFO\_START\_ADDR

![Image](images/29_Chapter_29_img091_2617044e.png)

LP\_I2C\_TXFIFO\_START\_ADDR Represents the I2C txfifo first address. (HRO)

## Register 29.68. LP\_I2C\_RXFIFO\_START\_ADDR\_REG (0x0180)

![Image](images/29_Chapter_29_img092_65bec3b3.png)

LP\_I2C\_RXFIFO\_START\_ADDR Represents the I2C rxfifo first address. (HRO)
