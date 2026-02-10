---
chapter: 7
title: "Chapter 7"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 7

## Chip Boot Control

## 7.1 Overview

ESP32-C3 has three strapping pins:

- GPIO2
- GPIO8
- GPIO9

These strapping pins are used to control the following functions during chip power-on or hardware reset:

- control chip boot mode
- ROM code printing

During power-on reset, RTC watchdog reset, brownout reset, analog super watchdog reset, and crystal clock glitch detection reset (see Chapter 6 Reset and Clock), hardware captures samples and stores the voltage level of strapping pins as strapping bit of "0" or "1" in latches, and holds these bits until the chip is powered down or shut down. Software can read the latch status (strapping value) from GPIO\_STRAPPING .

By default, GPIO9 is connected to the chip's internal pull-up resistor. If GPIO9 is not connected or connected to an external high-impedance circuit, the internal weak pull-up determines the default input level of this strapping pin (see Table 7.1-1).

Table 7.1-1. Default Configuration of Strapping Pins

| Strapping Pin   | Defualt Configuration   |
|-----------------|-------------------------|
| GPIO2           | N/A                     |
| GPIO8           | N/A                     |
| GPIO9           | Pull-up                 |

To change the strapping bit values, users can apply external pull-down/pull-up resistors, or use host MCU GPIOs to control the voltage level of these pins when powering on ESP32-C3. After the reset is released, the strapping pins work as normal-function pins.

## Note:

The following section provides description of the chip functions and the pattern of the strapping pins values to invoke each function. Only documented patterns should be used. If some pattern is not documented, it may trigger unexpected behavior.

## 7.2 Boot Mode Control

The values of GPIO2, GPIO3, GPIO8, and GPIO9 at reset determine the boot mode after the reset is released. Table 7.2-1 shows the strapping pin values of GPIO9, GPIO8, GPIO3, and GPIO2, and the associated boot modes.

Table 7.2-1. Boot Mode Control

| Boot Mode                 |   GPIO9 | GPIO8   | GPIO3   | GPIO2   |
|---------------------------|---------|---------|---------|---------|
| SPI Boot mode             |       1 | x
 1    | x       | x       |
| Joint Download Boot mode2 |       0 | 1       | x       | x       |
| SPI Download Boot mode3   |       0 | 0       | 0       | 1       |
| Invalid Combination4      |       0 | 0       | x       | 0       |

- USB-Serial-JTAG Download Boot
- UART Download Boot
- 3 SPI Download Boot mode: GPIO3 and GPIO2 need to be reserved only when using SPI Download Boot mode. GPIO3 and GPIO2 are floating by default and are in a high-impedance state at reset.

4 Invalid Combination: This combination can trigger unexpected behavior and should be avoided.

In SPI Boot mode, the ROM bootloader loads and executes the program from SPI flash to boot the system. SPI Boot mode can be further classified as follows:

- Normal Flash Boot: supports Security Boot. The ROM bootloader loads the program from flash into SRAM and executes it. In most practical scenarios, this program is the 2nd stage bootloader, which later boots the target application.
- Direct Boot: does not support Security Boot and programs run directly from flash. To enable this mode, make sure that the first two words of the bin file downloaded to flash (address: 0x42000000) are 0xaedb041d.

In Joint Download Boot mode, users can download binary files into flash using UART0 or USB interface. It is also possible to download binary files into SRAM and execute it in this mode.

In SPI Download Boot mode, users can download binary files into flash using SPI interface. It is also possible to download binary files into SRAM and execute it from SRAM.

The following eFuses control boot mode behaviors:

- EFUSE\_DIS\_FORCE\_DOWNLOAD
- – If this eFuse is 0 (default), software can force switch the chip from SPI Boot mode to Joint Download Boot mode by setting RTC\_CNTL\_FORCE\_DOWNLOAD\_BOOT and triggering a CPU reset. In this case, hardware overwrites GPIO\_STRAPPING[3:2] from "1x" to "01".

- – If this eFuse is 1, RTC\_CNTL\_FORCE\_DOWNLOAD\_BOOT is disabled. GPIO\_STRAPPING can not be overwritten.
- EFUSE\_DIS\_DOWNLOAD\_MODE

If this eFuse is 1, Joint Download Boot mode is disabled. GPIO\_STRAPPING will not be overwritten by RTC\_CNTL\_FORCE\_DOWNLOAD\_BOOT .

- EFUSE\_ENABLE\_SECURITY\_DOWNLOAD

If this eFuse is 1, Joint Download Boot mode only allows reading, writing, and erasing plaintext flash and does not support any SRAM or register operations. Ignore this eFuse if Joint Download Boot mode is disabled.

- EFUSE\_DIS\_DIRECT\_BOOT

If this eFuse is 1, Direct Boot mode is disabled.

USB Serial/JTAG Controller can also force the chip into Joint Download Boot mode from SPI Boot mode, as well as force the chip into SPI Boot mode from Joint Download Boot mode. For detailed information, please refer to Chapter 30 USB Serial/JTAG Controller (USB\_SERIAL\_JTAG) .

## 7.3 ROM Messages Printing Control

During early SPI Boot process, the messages by the ROM code can be printed to:

- (Default) UART0 and USB Serial/JTAG controller
- UART0
- USB Serial/JTAG controller

EFUSE\_UART\_PRINT\_CONTROL and GPIO8 control ROM messages printing to UART0 as shown in Table 7.3-1 .

Table 7.3-1. ROM Message Printing Control

|   eFuse 1 | GPIO8   | ROM Code Printing                                                               |
|-----------|---------|---------------------------------------------------------------------------------|
|         0 | x       | ROM code is always printed to UART0 during boot. The value of GPIO8 is ignored. |
|         1 | 0       | Print is enabled during boot.                                                   |
|         1 | 1       | Print is disabled during boot.                                                  |
|         2 | 0       | Print is disabled during boot.                                                  |
|         2 | 1       | Print is enabled during boot.                                                   |
|         3 | x       | Print is always disabled during boot. The value of GPIO8 is ignored.            |

1

eFuse: EFUSE\_UART\_PRINT\_CONTROL

EFUSE\_USB\_PRINT\_CHANNEL controls the printing to USB Serial/JTAG controller. When this bit is 1, printing to USB Serial/JTAG controller is disabled. When this bit is 0 and the USB Serial/JTAG controller is enabled via EFUSE\_DIS\_USB\_SERIAL\_JTAG, ROM messages can be printed to USB Serial/JTAG controller.

Note that if EFUSE\_USB\_PRINT\_CHANNEL is set to 0 to print ROM messages to USB, but USB Serial/JTAG controller has been disabled, then ROM messages will not be printed to USB Serial/JTAG controller.

Please note that ROM message printing to UART0 and to the USB Serial/JTAG Controller is controlled independently.
