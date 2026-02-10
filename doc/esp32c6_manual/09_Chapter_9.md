---
chapter: 9
title: "Chapter 9"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 9

## Chip Boot Control

## 9.1 Overview

Chip boot process and some chip functions are determined on power-on or hardware reset using strapping pins and eFuses. The following functionality can be determined:

- chip boot mode
- enable or disable of ROM messages printing to UART0
- source of JTAG signals
- SDIO input sampling edge and output driving edge

ESP32-C6 has five strapping pins:

- MTMS
- MTDI
- GPIO8
- GPIO9
- GPIO15

During Chip Reset (see Chapter 8 Reset and Clock), hardware captures samples and stores the voltage level of strapping pins as strapping bit of "0" or "1" in latches, and holds these bits until the chip is powered down or the next chip reset. Software can read the latch status (strapping value) from GPIO\_STRAPPING .

## 9.2 Functional Description

This section provides description of the chip functions and the patterns of the strapping pins and eFuse values to invoke each function.

## Notice:

Only documented patterns should be used. If an undocumented pattern is used, it may trigger unexpected behaviors.

## 9.2.1 Default Configuration

By default, GPIO9 is connected to the chip's internal pull-up resistor. If GPIO9 is not connected or is connected to an external high-impedance circuit, the internal weak pull-up determines the default input level of this strapping pin (see Table 9.2-1).

Table 9.2-1. Default Configuration of Strapping Pins

| Strapping Pin   | Default Configuration   |
|-----------------|-------------------------|
| MTMS            | Floating                |
| MTDI            | Floating                |
| GPIO8           | Floating                |
| GPIO9           | Pull-up                 |
| GPIO15          | Floating                |

To change the strapping bit values, users can apply external pull-down/pull-up resistors, or use host MCU GPIOs to control the voltage level of these pins when powering on ESP32-C6. After the reset is released, the strapping pins work as normal-function pins.

## 9.2.2 Boot Mode Control

The values of GPIO8 and GPIO9 at reset determine the boot mode after the reset is released. Table 9.2-2 shows the strapping pin values of GPIO8 and GPIO9, and the associated boot modes.

Table 9.2-2. Boot Mode Control

| Boot Mode     |   GPIO9 | GPIO8   |
|---------------|---------|---------|
| SPI Boot      |       1 | x       |
| Download Boot |       0 | 1       |

In SPI Boot mode, the ROM bootloader loads and executes the program from SPI flash to boot the system. SPI Boot mode can be further classified as follows:

- Normal Flash Boot: supports Secure Boot. The ROM bootloader loads the program from flash into SRAM and executes it. In most practical scenarios, this program is the 2nd stage bootloader, which later boots the target application.
- Direct Boot: does not support Secure Boot and programs run directly from flash. To enable this mode, make sure that the first two words of the bin file downloaded to flash are 0xaedb041d. For more detailed process, see Figure 9.2-1 .

In Download Boot mode, users can download code into flash using UART0 or USB interface. It is also possible to load a program into SRAM and execute it from SRAM.

Figure 9.2-1 shows the detailed boot flow of the chip.

![Image](images/09_Chapter_9_img001_c789835f.png)

*Note: The strapping values "1x" and "01" are the combination of GPIO9 and GPIO8 pins, see Table 9.2-2 .

Figure 9.2-1. Chip Boot Flow

The following eFuses allows controlling boot mode behaviors:

- EFUSE\_DIS\_FORCE\_DOWNLOAD
- – If this eFuse is 0 (default), software can force switch the chip from SPI Boot mode to Download Boot mode by setting register LP\_AON\_FORCE\_DOWNLOAD\_BOOT and triggering a CPU reset. In this case, hardware overwrites GPIO\_STRAPPING[3:2] from "1x" to "01".
- – If this eFuse is 1, LP\_AON\_FORCE\_DOWNLOAD\_BOOT is disabled. GPIO\_STRAPPING can not be overwritten.
- EFUSE\_DIS\_DOWNLOAD\_MODE

If this eFuse is 1, Download Boot mode is permanently disabled. GPIO\_STRAPPING will not be overwritten by LP\_AON\_FORCE\_DOWNLOAD\_BOOT .

- EFUSE\_ENABLE\_SECURITY\_DOWNLOAD

If this eFuse is 1, Download Boot mode only allows reading, writing, and erasing plaintext flash and does not support any SRAM or register operations. Ignore this eFuse if Download Boot mode is disabled.

- EFUSE\_DIS\_DIRECT\_BOOT

If this eFuse is 1, Direct Boot mode is disabled.

USB Serial/JTAG Controller can also force switch the chip to Download Boot mode from SPI Boot mode, and vice versa. For detailed information, please refer to Chapter 32 USB Serial/JTAG Controller (USB\_SERIAL\_JTAG) .

## 9.2.3 ROM Messages Printing Control

During early SPI Boot process the messages by the ROM code can be printed to:

- (Default) UART0 and USB Serial/JTAG controller
- USB Serial/JTAG controller
- UART0

EFUSE\_UART\_PRINT\_CONTROL and GPIO8 control ROM messages printing to UART0 as shown in Table 9.2-3 ROM Message Printing Control .

Table 9.2-3. ROM Message Printing Control

|   eFuse 1 | GPIO8   | ROM Code Printing   |
|-----------|---------|---------------------|
|         0 | x       | Always enabled      |
|         1 | 0       | Enabled             |
|         1 | 1       | Disabled            |
|         2 | 0       | Disabled            |
|         2 | 1       | Enabled             |
|         3 | x       | Always disabled     |

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_ROM\_PRINT controls the printing to USB Serial/JTAG controller. When this bit is 1, printing to USB Serial/JTAG controller is disabled. When this bit is 0, and USB Serial/JTAG controller is enabled via EFUSE\_DIS\_USB\_SERIAL\_JTAG, ROM messages can be printed to USB Serial/JTAG controller.

Note that if EFUSE\_DIS\_USB\_SERIAL\_JTAG\_ROM\_PRINT is set to 0 to print to USB, but USB Serial/JTAG Controller has been disabled, then ROM messages will not be printed to USB Serial/JTAG Controller.

## 9.2.4 JTAG Signal Source Control

GPIO15 controls the source of JTAG signals during the early boot process. This GPIO is used together with EFUSE\_DIS\_PAD\_JTAG , EFUSE\_DIS\_USB\_JTAG, and EFUSE\_JTAG\_SEL\_ENABLE. See Table 9.2-4 .

Table 9.2-4. JTAG Signal Source Control

|   eFuse 1 a |   eFuse 2 b | eFuse 3 c   | GPIO15   | Signal Source                                      |
|-------------|-------------|-------------|----------|----------------------------------------------------|
|           0 |           0 | 0           | x        | JTAG signals come from USB Serial/JTAG Controller. |
|           0 |           0 | 1           | 0        | JTAG signals come from corresponding pins d .      |
|           0 |           0 | 1           | 1        | JTAG signals come from USB Serial/JTAG Controller. |
|           0 |           1 | x           | x        | JTAG signals come from corresponding pins d .      |
|           1 |           0 | x           | x        | JTAG signals come from USB Serial/JTAG Controller. |
|           1 |           1 | x           | x        | JTAG is disabled.                                  |

a

eFuse 1: EFUSE\_DIS\_PAD\_JTAG

b

eFuse 2: EFUSE\_DIS\_USB\_JTAG

c

eFuse 3: EFUSE\_JTAG\_SEL\_ENABLE

d

JTAG pins: MTDI, MTCK, MTMS, and MTDO

## 9.2.5 SDIO Sampling Input Edge and Output Driving Edge Control

The strapping pin MTMS and MTDI can be used to control the input sampling edge and the output driving edge. See Table 9.2-5 SDIO Input Sampling Edge/Output Driving Edge Control. For more information about SDIO sampling control, see Chapter 34 SDIO Slave Controller (SDIO) .

Table 9.2-5. SDIO Input Sampling Edge/Output Driving Edge Control

|   MTMS |   MTDI | Edge behavior                              |
|--------|--------|--------------------------------------------|
|      0 |      0 | Falling edge sampling, falling edge output |
|      0 |      1 | Falling edge sampling, rising edge output  |
|      1 |      0 | Rising edge sampling, falling edge output  |
|      1 |      1 | Rising edge sampling, rising edge output   |
