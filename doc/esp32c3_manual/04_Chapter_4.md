---
chapter: 4
title: "Chapter 4"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 4

## eFuse Controller (EFUSE)

## 4.1 Overview

ESP32-C3 contains a 4096-bit eFuse controller to store parameters. Once an eFuse bit is programmed to 1, it can never be reverted to 0. The eFuse controller programs individual bits of parameters in eFuse according to user configurations. From outside the chip, eFuse data can only be read via the eFuse Controller. If read-protection for some data is not enabled, that data is readable from outside the chip. If read-protection is enabled, that data can not be read from outside the chip. In all cases, however, some keys stored in eFuse can still be used internally by hardware cryptography modules such as Digital Signature, HMAC, etc., without exposing this data to the outside world.

## 4.2 Features

- 4096-bit One-time programmable storage
- Configurable write protection
- Configurable read protection
- Various hardware encoding schemes against data corruption

## 4.3 Functional Description

## 4.3.1 Structure

eFuse data is organized in 11 blocks (BLOCK0 ~ BLOCK10).

BLOCK0, which holds most parameters, has 9 bits that are readable but useless to users, and 60 further bits are reserved for future use.

Table 4.3-1 lists all the parameters accessible (readable and usable) to users in BLOCK0 and their offsets, bit widths, as well as information on whether their configuration is directly accessible by hardware, and whether they are protected from programming.

The EFUSE\_WR\_DIS parameter is used to disable the writing of other parameters, while EFUSE\_RD\_DIS is used to disable users from reading BLOCK4 ~ BLOCK10. For more information on these two parameters, please see Section 4.3.1.1 and Section 4.3.1.2 .

Chapter 4 eFuse Controller (EFUSE)

Represents whether writing of individual eFuses is dis-

Description

Table 4.3-1. Parameters in eFuse BLOCK0

Espressif Systems abled.

10 is

~

Represents whether users’ reading from BLOCK4

disabled.

Represents whether iCache is disabled.

Represents whether the USB-to-JTAG function is disabled.

Represents whether iCache is disabled in Download mode.

Represents whether the usb\_serial\_jtag peripheral is dis- abled.

Represents whether the function to force the chip into

Download mode is disabled.

Represents whether the TWAI controller is disabled.

Represents whether to use JTAG directly.

Represents whether JTAG is disabled in the soft way.

Represents whether JTAG is disabled in the hard way (per- manently).

Represents whether flash encryption is disabled in Down- load boot mode.

Represents whether the D+ and D- pins are exchanged.

Represents whether the VDD\_SPI pin is used as a regular

GoBack

Represents whether SPI boot encryption/decryption is en-

Cont’d on next page

GPIO. selected. abled.

Represents whether RTC watchdog timeout threshold is

| 2  2  2  2  2                  | 31                  | 2  2                               | 30  30  3  4                                                     | N/A  0                                                                       |
|--------------------------------|---------------------|------------------------------------|------------------------------------------------------------------|------------------------------------------------------------------------------|
|                                |                     |                                    |                                                                  | Programming-Protection  EFUSE_WR_DIS Bit Number                              |
|                                |                     |                                    |                                                                  | by                                                                           |
| Accessible by Hardware  Y  Y Y | Y                   | Y Y                                | Y  N  Y Y                                                        | Y Y Y Y                                                                      |
| 32 7  1  1  1                  | 3                   | 1  1                               | 1  1  2 3                                                        | Bit  Width  1  1                                                             |
| EFUSE_DIS_FORCE_DOWNLOAD       |                     | EFUSE_DIS_DOWNLOAD_ MANUAL_ENCRYPT |                                                                  | EFUSE_DIS_DOWNLOAD_ICACHE  EFUSE_DIS_USB_SERIAL_JTAG                         |
|                                |                     |                                    | EFUSE_SPI_BOOT_CRYPT_CNT                                         |                                                                              |
|                                | EFUSE_SOFT_DIS_JTAG | EFUSE_DIS_PAD_JTAG                 | EFUSE_USB_EXCHG_PINS  EFUSE_VDD_SPI_AS_GPIO  EFUSE_WDT_DELAY_SEL | Parameters  EFUSE_WR_DIS  EFUSE_RD_DIS  EFUSE_DIS_ICACHE  EFUSE_DIS_USB_JTAG |

101

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Chapter 4 eFuse Controller (EFUSE)

Represents whether revoking the first Secure Boot key is

Description enabled.

Represents whether revoking the second Secure Boot key

Represents whether revoking the third Secure Boot key is

Table 4.3-1 – cont’d from previous page

.

4.3-2

Represents Key0 purpose, see Table

.

4.3-2

Represents Key1 purpose, see Table

.

4.3-2

Represents Key2 purpose, see Table

.

4.3-2

Represents Key3 purpose, see Table

.

4.3-2

Represents Key4 purpose, see Table

.

4.3-2

Represents Key5 purpose, see Table

GoBack

Represents whether UART secure download mode is en-

Cont’d on next page

is enabled. abled.

| 5  7  8  9  10  11  12  13  15                                                   | 16                                  | 18  18  18              | 18  18  18  18                                   | 6                                                                                                                                                                       |
|----------------------------------------------------------------------------------|-------------------------------------|-------------------------|--------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|                                                                                  |                                     |                         |                                                  | Programming-Protection  EFUSE_WR_DIS Bit Number                                                                                                                         |
| by                                                                               |                                     |                         |                                                  |                                                                                                                                                                         |
| Y Y Y  Y  Y  Y  N                                                                |                                     | N  N                    | N  N  N                                          | Accessible by Hardware                                                                                                                                                  |
| N                                                                                | N                                   | N                       | N                                                | N N                                                                                                                                                                     |
| Bit  Width  1  1  1  4 4 4 4 4 4 1                                               | 1                                   | 4 1  1                  | 1  1  2 1                                        |                                                                                                                                                                         |
|                                                                                  |                                     | EFUSE_DIS_DOWNLOAD_MODE |                                                  |                                                                                                                                                                         |
| EFUSE_KEY_PURPOSE_3 EFUSE_KEY_PURPOSE_4 EFUSE_KEY_PURPOSE_5 EFUSE_SECURE_BOOT_EN |                                     | EFUSE_FLASH_TPUW        |                                                  |                                                                                                                                                                         |
|                                                                                  |                                     |                         | EFUSE_UART_PRINT_CONTROL EFUSE_FORCE_SEND_RESUME |                                                                                                                                                                         |
|                                                                                  | EFUSE_SECURE_BOOT_AGGRESSIVE_REVOKE |                         | EFUSE_DIS_USB_SERIAL_JTAG_DOWNLOAD_MODE          |                                                                                                                                                                         |
|                                                                                  |                                     | EFUSE_USB_PRINT_CHANNEL | EFUSE_ENABLE_SECURITY_DOWNLOAD                   | Parameters  EFUSE_SECURE_BOOT_KEY_ REVOKE0  EFUSE_SECURE_BOOT_KEY_ REVOKE1  EFUSE_SECURE_BOOT_KEY_ REVOKE2  EFUSE_KEY_PURPOSE_0 EFUSE_KEY_PURPOSE_1 EFUSE_KEY_PURPOSE_2 |

Espressif Systems

102

Submit Documentation Feedback tion is disabled.

Represents the UART boot message output mode.

Represents whether ROM code is forced to send a resume command during SPI boot.

ESP32-C3 TRM (Version 1.3)

is enabled..

enabled.

Represents whether Secure Boot is enabled.

Represents whether aggressive revocation of Secure Boot

Represents the flash waiting time after power-up.

Represents whether all download modes are disabled.

Represents whether USB printing is disabled.

Represents whether the USB-Serial-JTAG download func-

Chapter 4 eFuse Controller (EFUSE)

Description

Represents the version used by ESP-IDF anti-rollback fea- ture.

Represents whether to use BLOCK0 to check error record registers.

Table 4.3-1 – cont’d from previous page

GoBack

| 18   |                         |
|------|-------------------------|
|      | EFUSE_WR_DIS Bit Number |
| by   | Programming-Protection  |

Accessible by Hardware

Bit

Width

N

16

Parameters

EFUSE\_SECURE\_VERSION

Espressif Systems

N

1

EFUSE\_ERR\_RST\_ENABLE

103

Submit Documentation Feedback

ESP32-C3 TRM (Version 1.3)

Table 4.3-2 lists all key purpose and their values. Setting the eFuse parameter EFUSE\_KEY\_PURPOSE\_n declares the purpose of KEYn (n: 0 ~ 5).

Table 4.3-2. Secure Key Purpose Values

|   Key Purpose Values | Purposes                                               |
|----------------------|--------------------------------------------------------|
|                    0 | User purposes                                          |
|                    1 | Reserved                                               |
|                    2 | Reserved                                               |
|                    3 | Reserved                                               |
|                    4 | XTS_AES_128_KEY (flash/SRAM encryption and decryption) |
|                    5 | HMAC Downstream mode (both JTAG and DS)                |
|                    6 | JTAG in HMAC Downstream mode                           |
|                    7 | Digital Signature peripheral in HMAC Downstream mode   |
|                    8 | HMAC Upstream mode                                     |
|                    9 | SECURE_BOOT_DIGEST0 (secure boot key digest)           |
|                   10 | SECURE_BOOT_DIGEST1 (secure boot key digest)           |
|                   11 | SECURE_BOOT_DIGEST2 (secure boot key digest)           |

Table 4.3-3 provides the details of parameters in BLOCK1 ~ BLOCK10.

Chapter 4 eFuse Controller (EFUSE)

Description

MAC address

CLK

Q (D1)

D (D0)

Read Protection

EFUSE\_RD\_DIS Bit Number by

Write Protection by EFUSE\_WR\_DIS Bit Number

Accessible by Hardware

Bit Width

Parameters

N/A

20

N

48

EFUSE\_MAC

BLOCK

BLOCK1

Espressif Systems

N/A

20

N

[0:5]

EFUSE\_SPI\_PAD\_

N/A

20

N/A

20

CS

N/A

20

HD (D3)

N/A

20

Table 4.3-3. Parameters in BLOCK1 to BLOCK10

WP (D2)

N/A

20

DQS

N/A

20

D4

N/A

20

D5

N/A

20

D6

N/A

D7

N/A

20

System data

N/A

21

| [6:11] N  [12:17] N  [18:23] N   |                                                                |                                 |                 |
|----------------------------------|----------------------------------------------------------------|---------------------------------|-----------------|
| [6:11] N  [12:17] N  [18:23] N   | N  N  N  N  N  N  N  N                                         | N  Y  Y                         | Y  Y            |
| [6:11] N  [12:17] N  [18:23] N   | [24:29] [30:35] [36:41] [42:47] [48:53] [54:59] [60:65] 78 256 | 256 256 256                     | 256 256         |
| [6:11] N  [12:17] N  [18:23] N   |                                                                | EFUSE_USR_DATA  EFUSE_KEY0_DATA |                 |
| [6:11] N  [12:17] N  [18:23] N   | EFUSE_SYS_DATA_PART1                                           | EFUSE_KEY1_DATA                 |                 |
| [6:11] N  [12:17] N  [18:23] N   | EFUSE_SYS_DATA_PART0                                           |                                 |                 |
| [6:11] N  [12:17] N  [18:23] N   |                                                                |                                 | EFUSE_KEY4_DATA |
| [6:11] N  [12:17] N  [18:23] N   |                                                                |                                 | EFUSE_KEY3_DATA |
| [6:11] N  [12:17] N  [18:23] N   |                                                                | BLOCK3  BLOCK4  BLOCK5          | BLOCK7  BLOCK8  |
| [6:11] N  [12:17] N  [18:23] N   |                                                                |                                 |                 |
| [6:11] N  [12:17] N  [18:23] N   |                                                                |                                 |                 |
| [6:11] N  [12:17] N  [18:23] N   |                                                                |                                 |                 |
| [6:11] N  [12:17] N  [18:23] N   |                                                                |                                 |                 |

20

105

Submit Documentation Feedback

KEY3 or user data

3

KEY4 or user data

4

KEY5 or user data

5

System data

6

26

27

28

29

ESP32-C3 TRM (Version 1.3)

System data

N/A

20

User data

N/A

22

KEY0 or user data

0

23

KEY1 or user data

1

24

KEY2 or user data

2

25

GoBack

Among these blocks, BLOCK4 ~ 9 stores KEY0 ~ 5, respectively. Up to six 256-bit keys can be written into eFuse. Whenever a key is written, its purpose value should also be written (see table 4.3-2). For example, when a key for the JTAG function in HMAC Downstream mode is written to KEY3 (i.e., BLOCK7), its key purpose value 6 should also be written to EFUSE\_KEY\_PURPOSE\_3 .

## Note:

Do not program the XTS-AES key into the KEY5 block, i.e., BLOCK9. Otherwise, the key may be unreadable. Instead, program it into the preceding blocks, i.e., BLOCK4 ~ BLOCK8. The last block, BLOCK9, is used to program other keys.

BLOCK1 ~ BLOCK10 use the RS coding scheme, so there are some restrictions on writing to these parameters. For more detailed information, please refer to Section 4.3.1.3 and Section 4.3.2 .

## 4.3.1.1 EFUSE\_WR\_DIS

Parameter EFUSE\_WR\_DIS determines whether individual eFuse parameters are write-protected. After EFUSE\_WR\_DIS has been programmed, execute an eFuse read operation so the new values would take effect.

Column "Write Protection by EFUSE\_WR\_DIS Bit Number" in Table 4.3-1 and Table 4.3-3 list the specific bits in EFUSE\_WR\_DIS that disable writing.

When the write protection bit of a parameter is set to 0, it means that this parameter is not write-protected and can be programmed, unless it has been programmed before.

When the write protection bit of a parameter is set to 1, it means that this parameter is write-protected and none of its bits can be modified, with non-programmed bits always remaining 0 while programmed bits always remain 1.

## 4.3.1.2 EFUSE\_RD\_DIS

Only the eFuse blocks in BLOCK4 ~ BLOCK10 can be individually read protected to prevent any access from outside the chip, as shown in column "Read Protection by EFUSE\_RD\_DIS Bit Number" of Table 4.3-3. After EFUSE\_RD\_DIS has been programmed, execute an eFuse read operation so the new values would take effect.

If the corresponding EFUSE\_RD\_DIS bit is 0, then the eFuse block can be read by users; if the corresponding EFUSE\_RD\_DIS bit is 1, then the parameter controlled by this bit is user protected.

Other parameters that are not in BLOCK4 ~ BLOCK10 can always be read by users.

When BLOCK4 ~ BLOCK10 are set to be read-protected, the data in these blocks are not readable by users, but they can still be read by hardware cryptography modules, if the EFUSE\_KEY\_PURPOSE\_n bit is set accordingly.

## 4.3.1.3 Data Storage

Internally, eFuses use hardware encoding schemes to protect data from corruption, which are invisible for users.

All BLOCK0 parameters except for EFUSE\_WR\_DIS are stored with four backups, meaning each bit is stored four times. This backup scheme is not visible to users.

BLOCK1 ~ BLOCK10 use RS (44, 32) coding scheme that supports up to 6 bytes of automatic error correction. The primitive polynomial of RS (44, 32) is p(x) = x 8 + x 4 + x 3 + x 2 + 1 .

Figure 4.3-1. Shift Register Circuit (first 32 output)

![Image](images/04_Chapter_4_img001_5d8c2094.png)

Figure 4.3-2. Shift Register Circuit (last 12 output)

![Image](images/04_Chapter_4_img002_4d4f6bfd.png)

The shift register circuit shown in Figure 4.3-1 and 4.3-2 processes 32 data bytes using RS (44, 32). This coding scheme encodes 32 bytes of data into 44 bytes:

- Bytes [0:31] are the data bytes itself
- Bytes [32:43] are the encoded parity bytes stored in 8-bit flip-flops DFF1, DFF2, ..., DFF12 (gf\_mul\_n, where n is an integer, is the result of multiplying a byte of data ...)

After that, the hardware burns into eFuse the 44-byte codeword consisting of the data bytes followed by the parity bytes.

When the eFuse block is read back, the eFuse controller automatically decodes the codeword and applies error correction if needed.

Because the RS check codes are generated on the entire 256-bit eFuse block, each block can only be written once.

## 4.3.2 Programming of Parameters

The eFuse controller can only program eFuse parameters in one block at a time. BLOCK0 ~ BLOCK10 share the same address range to store the parameters to be programmed. Configure parameter EFUSE\_BLK\_NUM

to indicate which block should be programmed.

## Programming BLOCK0

When EFUSE\_BLK\_NUM is set to 0, BLOCK0 will be programmed. Register EFUSE\_PGM\_DATA0\_REG stores EFUSE\_WR\_DIS. Registers EFUSE\_PGM\_DATA1\_REG ~ EFUSE\_PGM\_DATA5\_REG store the information of parameters to be programmed. Note that 9 BLOCK0 bits are readable but useless to users and must always be set to 0 in the programming registers. The specific bits are:

- EFUSE\_PGM\_DATA1\_REG[24:21]
- EFUSE\_PGM\_DATA1\_REG[31:27]

Data in registers EFUSE\_PGM\_DATA6\_REG ~ EFUSE\_PGM\_DATA7\_REG and EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG are ignored when programming BLOCK0.

## Programming BLOCK1

When EFUSE\_BLK\_NUM is set to 1, registers EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA5\_REG store the BLOCK1 parameters to be programmed. Registers EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_DATA2\_REG store the corresponding RS check codes. Data in registers EFUSE\_PGM\_DATA6\_REG ~ EFUSE\_PGM\_DATA7\_REG are ignored when programming BLOCK1, and the RS check codes will be calculated with these bits all treated as 0.

## Programming BLOCK2 ~ 10

When EFUSE\_BLK\_NUM is set to 2 ~ 10, registers EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA7\_REG store the parameters to be programmed to this block. Registers EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG store the corresponding RS check codes.

## Programming process

The process of programming parameters is as follows:

1. Configure the value of parameter EFUSE\_BLK\_NUM to determine the block to be programmed.
2. Write parameters to be programmed to registers EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA7\_REG and EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG .
3. Make sure the eFuse programming voltage VDDQ is configured correctly as described in Section 4.3.4 .
4. Configure the field EFUSE\_OP\_CODE of register EFUSE\_CONF\_REG to 0x5A5A.
5. Configure the field EFUSE\_PGM\_CMD of register EFUSE\_CMD\_REG to 1.
6. Poll register EFUSE\_CMD\_REG until it is 0x0, or wait for a PGM\_DONE interrupt. For more information on how to identify a PGM/READ\_DONE interrupt, please see the end of Section 4.3.3 .
7. Clear the parameters in EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA7\_REG and EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG .
8. Trigger an eFuse read operation (see Section 4.3.3) to update eFuse registers with the new values.
9. Check error record registers. If the values read in error record registers are not 0, the programming process should be performed again following above steps 1 ~ 7. Please check the following error record registers for different eFuse blocks:

- BLOCK0: EFUSE\_RD\_REPEAT\_ERR0\_REG ~ EFUSE\_RD\_REPEAT\_ERR4\_REG
- BLOCK1: EFUSE\_RD\_RS\_ERR0\_REG[2:0], EFUSE\_RD\_RS\_ERR0\_REG[7]
- BLOCK2: EFUSE\_RD\_RS\_ERR0\_REG[6:4], EFUSE\_RD\_RS\_ERR0\_REG[11]
- BLOCK3: EFUSE\_RD\_RS\_ERR0\_REG[10:8], EFUSE\_RD\_RS\_ERR0\_REG[15]
- BLOCK4: EFUSE\_RD\_RS\_ERR0\_REG[14:12], EFUSE\_RD\_RS\_ERR0\_REG[19]
- BLOCK5: EFUSE\_RD\_RS\_ERR0\_REG[18:16], EFUSE\_RD\_RS\_ERR0\_REG[23]
- BLOCK6: EFUSE\_RD\_RS\_ERR0\_REG[22:20], EFUSE\_RD\_RS\_ERR0\_REG[27]
- BLOCK7: EFUSE\_RD\_RS\_ERR0\_REG[26:24], EFUSE\_RD\_RS\_ERR0\_REG[31]
- BLOCK8: EFUSE\_RD\_RS\_ERR0\_REG[30:28], EFUSE\_RD\_RS\_ERR1\_REG[3]
- BLOCK9: EFUSE\_RD\_RS\_ERR1\_REG[2:0], EFUSE\_RD\_RS\_ERR1\_REG[2:0][7]
- BLOCK10: EFUSE\_RD\_RS\_ERR1\_REG[2:0][6:4]

## Limitations

In BLOCK0, each bit can be programmed separately. However, we recommend to minimize programming cycles and program all the bits of a parameter in one programming action. In addition, after all parameters controlled by a certain bit of EFUSE\_WR\_DIS are programmed, that bit should be immediately programmed. The programming of parameters controlled by a certain bit of EFUSE\_WR\_DIS, and the programming of the bit itself can even be completed at the same time. Repeated programming of already programmed bits is strictly forbidden, otherwise, programming errors will occur.

BLOCK1 cannot be programmed by users as it has been programmed at manufacturing.

BLOCK2 ~ 10 can only be programmed once. Repeated programming is not allowed.

## 4.3.3 User Read of Parameters

Users cannot read eFuse bits directly. The eFuse Controller hardware reads all eFuse bits and stores the results to their corresponding registers in its memory space. Then, users can read eFuse bits by reading the registers that start with EFUSE\_RD\_. Details are provided in Table 4.3-4 .

Table 4.3-4. Registers Information

| BLOCK   | Read Registers                         | Registers When Programming This Block   |
|---------|----------------------------------------|-----------------------------------------|
| 0       | EFUSE_RD_WR_DIS_REG                    | EFUSE_PGM_DATA0_REG                     |
| 0       | EFUSE_RD_REPEAT_DATA0 ~ 4_REG          | EFUSE_PGM_DATA1 ~ 5_REG                 |
| 1       | EFUSE_RD_MAC_SPI_SYS_0 ~ 5_REG         | EFUSE_PGM_DATA0 ~ 5_REG                 |
| 2       | EFUSE_RD_SYS_DATA_PART1_0 ~ 7_REG      | EFUSE_PGM_DATA0 ~ 7_REG                 |
| 3       | EFUSE_RD_USR_DATA0 ~ 7_REG             | EFUSE_PGM_DATA0 ~ 7_REG                 |
| 4-9     | EFUSE_RD_KEYn_DATA0 ~ 7_REG (n: 0 ~ 5) | EFUSE_PGM_DATA0 ~ 7_REG                 |
| 10      | EFUSE_RD_SYS_DATA_PART2_0 ~ 7_REG      | EFUSE_PGM_DATA0 ~ 7_REG                 |

## Updating eFuse read registers

The eFuse Controller reads internal eFuses to update corresponding registers. This read operation happens on system reset and can also be triggered manually by users as needed (e.g., if new eFuse values have been programmed). The process of triggering a read operation by users is as follows:

1. Configure the field EFUSE\_OP\_CODE in register EFUSE\_CONF\_REG to 0x5AA5.
2. Configure the field EFUSE\_READ\_CMD in register EFUSE\_CMD\_REG to 1.
3. Poll register EFUSE\_CMD\_REG until it is 0x0, or wait for a READ\_DONE interrupt. Information on how to identify a PGM/READ\_DONE interrupt is provided below in this section.
4. Read the values of each parameter from memory.

The eFuse read registers will hold all values until the next read operation.

## Error detection

Error record registers allow users to detect if there are any inconsistencies in the stored backup eFuse parameters.

Registers EFUSE\_RD\_REPEAT\_ERR0 ~ 3\_REG indicate if there are any errors of programmed parameters (except for EFUSE\_WR\_DIS) in BLOCK0 (value 1 indicates an error is detected, and the bit becomes invalid; value 0 indicates no error).

Registers EFUSE\_RD\_RS\_ERR0 ~ 1\_REG store the number of corrected bytes as well as the result of RS decoding during eFuse reading BLOCK1 ~ BLOCK10.

The values of above registers will be updated every time after the eFuse read registers have been updated.

## Identifying program/read operation

The methods to identify the completion of a program/read operation are described below. Please note that bit 1 corresponds to a program operation, and bit 0 corresponds to a read operation.

- Method one:
1. Poll bit 1/0 in register EFUSE\_INT\_RAW\_REG until it becomes 1, which represents the completion of a program/read operation.
- Method two:
1. Set bit 1/0 in register EFUSE\_INT\_ENA\_REG to 1 to enable the eFuse Controller to post a PGM/READ\_DONE interrupt.
2. Configure the Interrupt Matrix to enable the CPU to respond to eFuse interrupt signals, see Chapter 8 Interrupt Matrix (INTERRUPT) .
3. Wait for the PGM/READ\_DONE interrupt.
4. Set bit 1/0 in register EFUSE\_INT\_CLR\_REG to 1 to clear the PGM/READ\_DONE interrupt.

## Note

When eFuse controller updating its registers, it will use EFUSE\_PGM\_DATAn\_REG (n=0, 1, .., 7) again to store data. So please do not write important data into these registers before this updating process initiated. During the chip boot process, eFuse controller will update eFuse data into registers which can be accessed by users automatically. Users can get programmed eFuse data by reading corresponding registers. Thus, it is no need to update eFuse read registers in such case.

## 4.3.4 eFuse VDDQ Timing

The eFuse Controller operates with 20 MHz of clock frequency, and its programming voltage VDDQ should be configured as follows:

- EFUSE\_DAC\_NUM (the rising period of VDDQ): The default value of VDDQ is 2.5 V and the voltage increases by 0.01 V in each clock cycle. Thus, the default value of this parameter is 255;
- EFUSE\_DAC\_CLK\_DIV (the clock divisor of VDDQ): The clock period to program VDDQ should be larger than 1 µs;
- EFUSE\_PWR\_ON\_NUM (the power-up time for VDDQ): The programming voltage should be stabilized after this time, which means the value of this parameter should be configured to exceed the result of EFUSE\_DAC\_CLK\_DIV times EFUSE\_DAC\_NUM;
- EFUSE\_PWR\_OFF\_NUM (the power-out time for VDDQ): The value of this parameter should be larger than 10 µs.

Table 4.3-5. Configuration of Default VDDQ Timing Parameters

| EFUSE_DAC_NUM   | EFUSE_DAC_CLK_DIV   | EFUSE_PWR_ON_NUM   | EFUSE_PWR_OFF_NUM   |
|-----------------|---------------------|--------------------|---------------------|
| 0xFF            | 0x28                | 0x3000             | 0x190               |

## 4.3.5 The Use of Parameters by Hardware Modules

Some hardware modules are directly connected to the eFuse peripheral in order to use the parameters listed in Table 4.3-1 and Table 4.3-3, specifically those marked with "Y" in columns "Accessible by Hardware". Users cannot intervene in this process.

## 4.3.6 Interrupts

- PGM\_DONE interrupt: Triggered when eFuse programming has finished. To enable this interrupt, set the EFUSE\_PGM\_DONE\_INT\_ENA field of register EFUSE\_INT\_ENA\_REG to 1;
- READ\_DONE interrupt: Triggered when eFuse reading has finished. To enable this interrupt, set the EFUSE\_READ\_DONE\_INT\_ENA field of register EFUSE\_INT\_ENA\_REG to 1.

## 4.4 Register Summary

The addresses in this section are relative to eFuse Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                         | Description                                           | Address   | Access   |
|------------------------------|-------------------------------------------------------|-----------|----------|
| PGM Data Register            |                                                       |           |          |
| EFUSE_PGM_DATA0_REG          | Register 0 that stores data to be programmed          | 0x0000    | R/W      |
| EFUSE_PGM_DATA1_REG          | Register 1 that stores data to be programmed          | 0x0004    | R/W      |
| EFUSE_PGM_DATA2_REG          | Register 2 that stores data to be programmed          | 0x0008    | R/W      |
| EFUSE_PGM_DATA3_REG          | Register 3 that stores data to be programmed          | 0x000C    | R/W      |
| EFUSE_PGM_DATA4_REG          | Register 4 that stores data to be programmed          | 0x0010    | R/W      |
| EFUSE_PGM_DATA5_REG          | Register 5 that stores data to be programmed          | 0x0014    | R/W      |
| EFUSE_PGM_DATA6_REG          | Register 6 that stores data to be programmed          | 0x0018    | R/W      |
| EFUSE_PGM_DATA7_REG          | Register 7 that stores data to be programmed          | 0x001C    | R/W      |
| EFUSE_PGM_CHECK_VALUE0_REG   | Register 0 that stores the RS code to be pro grammed | 0x0020    | R/W      |
| EFUSE_PGM_CHECK_VALUE1_REG   | Register 1 that stores the RS code to be pro grammed | 0x0024    | R/W      |
| EFUSE_PGM_CHECK_VALUE2_REG   | Register 2 that stores the RS code to be pro grammed | 0x0028    | R/W      |
| Read Data Register           |                                                       |           |          |
| EFUSE_RD_WR_DIS_REG          | BLOCK0 data register 0                                | 0x002C    | RO       |
| EFUSE_RD_REPEAT_DATA0_REG    | BLOCK0 data register 1                                | 0x0030    | RO       |
| EFUSE_RD_REPEAT_DATA1_REG    | BLOCK0 data register 2                                | 0x0034    | RO       |
| EFUSE_RD_REPEAT_DATA2_REG    | BLOCK0 data register 3                                | 0x0038    | RO       |
| EFUSE_RD_REPEAT_DATA3_REG    | BLOCK0 data register 4                                | 0x003C    | RO       |
| EFUSE_RD_REPEAT_DATA4_REG    | BLOCK0 data register 5                                | 0x0040    | RO       |
| EFUSE_RD_MAC_SPI_SYS_0_REG   | BLOCK1 data register 0                                | 0x0044    | RO       |
| EFUSE_RD_MAC_SPI_SYS_1_REG   | BLOCK1 data register 1                                | 0x0048    | RO       |
| EFUSE_RD_MAC_SPI_SYS_2_REG   | BLOCK1 data register 2                                | 0x004C    | RO       |
| EFUSE_RD_MAC_SPI_SYS_3_REG   | BLOCK1 data register 3                                | 0x0050    | RO       |
| EFUSE_RD_MAC_SPI_SYS_4_REG   | BLOCK1 data register 4                                | 0x0054    | RO       |
| EFUSE_RD_MAC_SPI_SYS_5_REG   | BLOCK1 data register 5                                | 0x0058    | RO       |
| EFUSE_RD_SYS_PART1_DATA0_REG | Register 0 of BLOCK2 (system)                         | 0x005C    | RO       |
| EFUSE_RD_SYS_PART1_DATA1_REG | Register 1 of BLOCK2 (system)                         | 0x0060    | RO       |
| EFUSE_RD_SYS_PART1_DATA2_REG | Register 2 of BLOCK2 (system)                         | 0x0064    | RO       |
| EFUSE_RD_SYS_PART1_DATA3_REG | Register 3 of BLOCK2 (system)                         | 0x0068    | RO       |
| EFUSE_RD_SYS_PART1_DATA4_REG | Register 4 of BLOCK2 (system)                         | 0x006C    | RO       |
| EFUSE_RD_SYS_PART1_DATA5_REG | Register 5 of BLOCK2 (system)                         | 0x0070    | RO       |
| EFUSE_RD_SYS_PART1_DATA6_REG | Register 6 of BLOCK2 (system)                         | 0x0074    | RO       |
| EFUSE_RD_SYS_PART1_DATA7_REG | Register 7 of BLOCK2 (system)                         | 0x0078    | RO       |
| EFUSE_RD_USR_DATA0_REG       | Register 0 of BLOCK3 (user)                           | 0x007C    | RO       |

| Name                    | Description                 | Address        | Access   |
|-------------------------|-----------------------------|----------------|----------|
| EFUSE_RD_USR_DATA1_REG  | Register 1 of BLOCK3 (user) | 0x0080         | RO       |
| EFUSE_RD_USR_DATA2_REG  | Register 2 of BLOCK3 (user) | 0x0084         | RO       |
| EFUSE_RD_USR_DATA3_REG  | Register 3 of BLOCK3 (user) | 0x0088         | RO       |
| EFUSE_RD_USR_DATA4_REG  | Register 4 of BLOCK3 (user) | 0x008C         | RO       |
| EFUSE_RD_USR_DATA5_REG  | Register 5 of BLOCK3 (user) | 0x0090         | RO       |
| EFUSE_RD_USR_DATA6_REG  | Register 6 of BLOCK3 (user) | 0x0094         | RO       |
| EFUSE_RD_USR_DATA7_REG  | Register 7 of BLOCK3 (user) | 0x0098         | RO       |
| EFUSE_RD_KEY0_DATA0_REG | Register 0 of BLOCK4 (KEY0) | 0x009C         | RO       |
| EFUSE_RD_KEY0_DATA1_REG | Register 1 of BLOCK4 (KEY0) | 0x00A0         | RO       |
| EFUSE_RD_KEY0_DATA2_REG | Register 2 of BLOCK4 (KEY0) | 0x00A4         | RO       |
| EFUSE_RD_KEY0_DATA3_REG | Register 3 of BLOCK4 (KEY0) | 0x00A8         | RO       |
| EFUSE_RD_KEY0_DATA4_REG | Register 4 of BLOCK4 (KEY0) | 0x00AC         | RO       |
| EFUSE_RD_KEY0_DATA5_REG | Register 5 of BLOCK4 (KEY0) | 0x00B0         | RO       |
| EFUSE_RD_KEY0_DATA6_REG | Register 6 of BLOCK4 (KEY0) | 0x00B4         | RO       |
| EFUSE_RD_KEY0_DATA7_REG | Register 7 of BLOCK4 (KEY0) | 0x00B8         | RO       |
| EFUSE_RD_KEY1_DATA0_REG | Register 0 of BLOCK5 (KEY1) | 0x00BC         | RO       |
| EFUSE_RD_KEY1_DATA1_REG | Register 1 of BLOCK5 (KEY1) | 0x00C0         | RO       |
| EFUSE_RD_KEY1_DATA2_REG | Register 2 of BLOCK5 (KEY1) | 0x00C4         | RO       |
| EFUSE_RD_KEY1_DATA3_REG | Register 3 of BLOCK5 (KEY1) | 0x00C8         | RO       |
| EFUSE_RD_KEY1_DATA4_REG | Register 4 of BLOCK5 (KEY1) | 0x00CC         | RO       |
| EFUSE_RD_KEY1_DATA5_REG | Register 5 of BLOCK5 (KEY1) | 0x00D0         | RO       |
| EFUSE_RD_KEY1_DATA6_REG | Register 6 of BLOCK5 (KEY1) | 0x00D4         | RO       |
| EFUSE_RD_KEY1_DATA7_REG | Register 7 of BLOCK5 (KEY1) | 0x00D8         | RO       |
| EFUSE_RD_KEY2_DATA0_REG | Register 0 of BLOCK6 (KEY2) | 0x00DC         | RO       |
| EFUSE_RD_KEY2_DATA1_REG | Register 1 of BLOCK6 (KEY2) | 0x00E0         | RO       |
| EFUSE_RD_KEY2_DATA2_REG | Register 2 of BLOCK6 (KEY2) | 0x00E4         | RO       |
| EFUSE_RD_KEY2_DATA3_REG | Register 3 of BLOCK6 (KEY2) | 0x00E8         | RO       |
| EFUSE_RD_KEY2_DATA4_REG | Register 4 of BLOCK6 (KEY2) | 0x00EC         | RO       |
| EFUSE_RD_KEY2_DATA5_REG | Register 5 of BLOCK6 (KEY2) | 0x00F0         | RO       |
| EFUSE_RD_KEY2_DATA6_REG | Register 6 of BLOCK6 (KEY2) | 0x00F4         | RO       |
| EFUSE_RD_KEY2_DATA7_REG | Register 7 of BLOCK6 (KEY2) | 0x00F8         | RO       |
| EFUSE_RD_KEY3_DATA0_REG | Register 0 of BLOCK7 (KEY3) | 0x00FC         | RO       |
| EFUSE_RD_KEY3_DATA1_REG | Register 1 of BLOCK7 (KEY3) | 0x0100         | RO       |
| EFUSE_RD_KEY3_DATA2_REG | Register 2 of BLOCK7 (KEY3) | 0x0104         | RO       |
| EFUSE_RD_KEY3_DATA3_REG | Register 3 of BLOCK7 (KEY3) | 0x0108         | RO       |
| EFUSE_RD_KEY3_DATA4_REG | Register 4 of BLOCK7 (KEY3) | 0x010C         | RO       |
| EFUSE_RD_KEY3_DATA5_REG | Register 5 of BLOCK7 (KEY3) | 0x0110         | RO       |
| EFUSE_RD_KEY3_DATA6_REG | Register 6 of BLOCK7 (KEY3) | 0x0114         | RO       |
| EFUSE_RD_KEY3_DATA7_REG | Register 7 of BLOCK7 (KEY3) | 0x0118         | RO       |
| EFUSE_RD_KEY4_DATA0_REG | Register 0 of BLOCK8 (KEY4) | 0x011C         | RO       |
| EFUSE_RD_KEY4_DATA1_REG | Register 1 of BLOCK8 (KEY4) | 0x0120         | RO       |
| EFUSE_RD_KEY4_DATA2_REG | Register 2 of BLOCK8 (KEY4) | 0x0124  0x0128 | RO RO    |
| EFUSE_RD_KEY4_DATA3_REG | Register 3 of BLOCK8 (KEY4) |                |          |

| Name                         | Description                                                     | Address                | Access                 |
|------------------------------|-----------------------------------------------------------------|------------------------|------------------------|
| EFUSE_RD_KEY4_DATA4_REG      | Register 4 of BLOCK8 (KEY4)                                     | 0x012C                 | RO                     |
| EFUSE_RD_KEY4_DATA5_REG      | Register 5 of BLOCK8 (KEY4)                                     | 0x0130                 | RO                     |
| EFUSE_RD_KEY4_DATA6_REG      | Register 6 of BLOCK8 (KEY4)                                     | 0x0134                 | RO                     |
| EFUSE_RD_KEY4_DATA7_REG      | Register 7 of BLOCK8 (KEY4)                                     | 0x0138                 | RO                     |
| EFUSE_RD_KEY5_DATA0_REG      | Register 0 of BLOCK9 (KEY5)                                     | 0x013C                 | RO                     |
| EFUSE_RD_KEY5_DATA1_REG      | Register 1 of BLOCK9 (KEY5)                                     | 0x0140                 | RO                     |
| EFUSE_RD_KEY5_DATA2_REG      | Register 2 of BLOCK9 (KEY5)                                     | 0x0144                 | RO                     |
| EFUSE_RD_KEY5_DATA3_REG      | Register 3 of BLOCK9 (KEY5)                                     | 0x0148                 | RO                     |
| EFUSE_RD_KEY5_DATA4_REG      | Register 4 of BLOCK9 (KEY5)                                     | 0x014C                 | RO                     |
| EFUSE_RD_KEY5_DATA5_REG      | Register 5 of BLOCK9 (KEY5)                                     | 0x0150                 | RO                     |
| EFUSE_RD_KEY5_DATA6_REG      | Register 6 of BLOCK9 (KEY5)                                     | 0x0154                 | RO                     |
| EFUSE_RD_KEY5_DATA7_REG      | Register 7 of BLOCK9 (KEY5)                                     | 0x0158                 | RO                     |
| EFUSE_RD_SYS_PART2_DATA0_REG | Register 0 of BLOCK10 (system)                                  | 0x015C                 | RO                     |
| EFUSE_RD_SYS_PART2_DATA1_REG | Register 1 of BLOCK10 (system)                                  | 0x0160                 | RO                     |
| EFUSE_RD_SYS_PART2_DATA2_REG | Register 2 of BLOCK10 (system)                                  | 0x0164                 | RO                     |
| EFUSE_RD_SYS_PART2_DATA3_REG | Register 3 of BLOCK10 (system)                                  | 0x0168                 | RO                     |
| EFUSE_RD_SYS_PART2_DATA4_REG | Register 4 of BLOCK10 (system)                                  | 0x016C                 | RO                     |
| EFUSE_RD_SYS_PART2_DATA5_REG | Register 5 of BLOCK10 (system)                                  | 0x0170                 | RO                     |
| EFUSE_RD_SYS_PART2_DATA6_REG | Register 6 of BLOCK10 (system)                                  | 0x0174                 | RO                     |
| EFUSE_RD_SYS_PART2_DATA7_REG | Register 7 of BLOCK10 (system)                                  | 0x0178                 | RO                     |
| Report Register              | Report Register                                                 | Report Register        | Report Register        |
| EFUSE_RD_REPEAT_ERR0_REG     | Programming error record register 0 of BLOCK0                   | 0x017C                 | RO                     |
| EFUSE_RD_REPEAT_ERR1_REG     | Programming error record register 1 of BLOCK0                   | 0x0180                 | RO                     |
| EFUSE_RD_REPEAT_ERR2_REG     | Programming error record register 2 of BLOCK0                   | 0x0184                 | RO                     |
| EFUSE_RD_REPEAT_ERR3_REG     | Programming error record register 3 of BLOCK0                   | 0x0188                 | RO                     |
| EFUSE_RD_REPEAT_ERR4_REG     | Programming error record register 4 of BLOCK0                   | 0x0190                 | RO                     |
| EFUSE_RD_RS_ERR0_REG         | Programming error record register 0 of BLOCK1- 10               | 0x01C0                 | RO                     |
| EFUSE_RD_RS_ERR1_REG         | Programming error record register 1 of BLOCK1- 10               | 0x01C4                 | RO                     |
| Configuration Register       | Configuration Register                                          | Configuration Register | Configuration Register |
| EFUSE_CLK_REG                | eFuse clock configuration register                              | 0x01C8                 | R/W                    |
| EFUSE_CONF_REG               | eFuse operation mode configuration register                     | 0x01CC                 | R/W                    |
| EFUSE_CMD_REG                | eFuse command register                                          | 0x01D4                 | varies                 |
| EFUSE_DAC_CONF_REG           | Controls the eFuse programming voltage                          | 0x01E8                 | R/W                    |
| EFUSE_RD_TIM_CONF_REG        | Configures read timing parameters                               | 0x01EC                 | R/W                    |
| EFUSE_WR_TIM_CONF1_REG       | Configuration register 1 of eFuse programming timing parameters | 0x01F0                 | R/W                    |
| EFUSE_WR_TIM_CONF2_REG       | Configuration register 2 of eFuse programming timing parameters | 0x01F4                 | R/W                    |
| Status Register              | Status Register                                                 | Status Register        | Status Register        |
| EFUSE_STATUS_REG             | eFuse status register                                           | 0x01D0                 | RO                     |
| Interrupt Register           |                                                                 |                        |                        |

| Name              | Description                     | Address   | Access   |
|-------------------|---------------------------------|-----------|----------|
| EFUSE_INT_RAW_REG | eFuse raw interrupt register    | 0x01D8    | R/WC/SS  |
| EFUSE_INT_ST_REG  | eFuse interrupt status register | 0x01DC    | RO       |
| EFUSE_INT_ENA_REG | eFuse interrupt enable register | 0x01E0    | R/W      |
| EFUSE_INT_CLR_REG | eFuse interrupt clear register  | 0x01E4    | WO       |
| Version Register  |                                 |           |          |
| EFUSE_DATE_REG    | Version control register        | 0x01FC    | R/W      |

## 4.5 Registers

The addresses in this section are relative to eFuse Controller base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 4.1. EFUSE\_PGM\_DATA0\_REG (0x0000)

![Image](images/04_Chapter_4_img003_23ade84d.png)

EFUSE\_PGM\_DATA\_2 The content of the 2nd 32-bit data to be programmed. (R/W)

![Image](images/04_Chapter_4_img004_86a87257.png)

Register 4.8. EFUSE\_PGM\_DATA7\_REG (0x001C)

EFUSE\_PGM\_RS\_DATA\_1 The content of the 1st 32-bit RS code to be programmed. (R/W)

![Image](images/04_Chapter_4_img005_7fff7977.png)

Register 4.11. EFUSE\_PGM\_CHECK\_VALUE2\_REG (0x0028)

![Image](images/04_Chapter_4_img006_8357084d.png)

![Image](images/04_Chapter_4_img007_3a7b0688.png)

EFUSE\_PGM\_RS\_DATA\_2 The content of the 2nd 32-bit RS code to be programmed. (R/W)

## Register 4.12. EFUSE\_RD\_WR\_DIS\_REG (0x002C)

![Image](images/04_Chapter_4_img008_1ea5b75c.png)

![Image](images/04_Chapter_4_img009_90f7fa3d.png)

EFUSE\_WR\_DIS Represents whether programming of corresponding eFuse part is disabled or enabled. 1: Disabled. 0: Enabled. (RO)

Register 4.13. EFUSE\_RD\_REPEAT\_DATA0\_REG (0x0030)

![Image](images/04_Chapter_4_img010_165a2969.png)

EFUSE\_RD\_DIS Represents whether users' reading from BLOCK4 ~ 10 is disabled or enabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_DIS\_RTC\_RAM\_BOOT Reserved (used for four backups method). (RO)

EFUSE\_DIS\_ICACHE Represents whether iCache is disabled or enabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_DIS\_USB\_JTAG Represents whether the USB-to-JTAG function is disabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_DIS\_DOWNLOAD\_ICACHE Represents whether iCache is disabled in download mode (boot\_mode[3:0] is 0, 1, 2, 3, 6, 7). 1: Disabled. 0: Enabled. (RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG Represents whether USB-Serial-JTAG is disabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_DIS\_FORCE\_DOWNLOAD Represents whether the function that forces chip into download mode is disabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_RPT4\_RESERVED6 Reserved (used for four backups method). (RO)

EFUSE\_DIS\_TWAI Represents whether TWAI function is disabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_JTAG\_SEL\_ENABLE Represents whether to use JTAG directly. 1: Use directly. 0: Not use directly. (RO)

EFUSE\_SOFT\_DIS\_JTAG Represents whether JTAG is disabled in the soft way. Odd count of bits with a value of 1: Disabled. It can still be restarted via HMAC. Even count of bits with a value of 1: Enabled. (RO)

EFUSE\_DIS\_PAD\_JTAG Represents whether JTAG is disabled in the hard way (permanently). 1: Disabled. 0: Enabled. (RO)

Continued on the next page...

## Register 4.13. EFUSE\_RD\_REPEAT\_DATA0\_REG (0x0030)

## Continued from the previous page...

EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT Represents whether flash encryption is disabled (except in SPI boot mode). 1: Disabled. 0: Enabled. (RO)

EFUSE\_USB\_EXCHG\_PINS Represents whether or not USB D+ and D- pins are swapped. 1: Swapped. 0: Not swapped. (RO)

Note: The eFuse has a design flaw and does not move the pullup (needed to detect USB speed), resulting in the PC thinking the chip is a low-speed device, which stops communication. For detailed information, please refer to Chapter 30 USB Serial/JTAG Controller (USB\_SERIAL\_JTAG) .

EFUSE\_VDD\_SPI\_AS\_GPIO Represents whether the VDD\_SPI pin is used as a regular GPIO. 1: Used as a regular GPIO. 0: Not used as a regular GPIO. (RO)

Register 4.14. EFUSE\_RD\_REPEAT\_DATA1\_REG (0x0034)

![Image](images/04_Chapter_4_img011_3e7bf886.png)

EFUSE\_RPT4\_RESERVED2 Reserved (used for four backups method). (RO)

EFUSE\_WDT\_DELAY\_SEL Represents RTC watchdog timeout threshold. Measurement unit: slow clock cycle. 00: 40000, 01: 80000, 10: 160000, 11:320000. (RO)

EFUSE\_SPI\_BOOT\_CRYPT\_CNT Represents whether SPI boot encrypt/decrypt is disabled or enabled. Odd count of bits with a value of 1: Enabled. Even count of bits with a value of 1: Disabled. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE0 Represents whether or not the first secure boot key is revoked. 1: Revoked. 0: Not revoked. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE1 Represents whether or not the second secure boot key is revoked. 1: Revoked. 0: Not revoked. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE2 Represents whether or not the third secure boot key is revoked. 1: Revoked. 0: Not revoked. (RO)

EFUSE\_KEY\_PURPOSE\_0 Represents purpose of Key0. (RO)

EFUSE\_KEY\_PURPOSE\_1 Represents purpose of Key1. (RO)

![Image](images/04_Chapter_4_img012_33cb9e11.png)

Register 4.15. EFUSE\_RD\_REPEAT\_DATA2\_REG (0x0038)

![Image](images/04_Chapter_4_img013_584e61fd.png)

EFUSE\_KEY\_PURPOSE\_2 Represents purpose of Key2. (RO)

EFUSE\_KEY\_PURPOSE\_3 Represents purpose of Key3. (RO)

EFUSE\_KEY\_PURPOSE\_4 Represents purpose of Key4. (RO)

EFUSE\_KEY\_PURPOSE\_5 Represents purpose of Key5. (RO)

EFUSE\_RPT4\_RESERVED3 Reserved (used for four backups method). (RO)

EFUSE\_SECURE\_BOOT\_EN Represents whether secure boot is enabled or disabled. 1: Enabled. 0: Disabled. (RO)

EFUSE\_SECURE\_BOOT\_AGGRESSIVE\_REVOKE Represents whether aggressive revoke of secure boot keys is enabled or disabled. 1: Enabled. 0: Disabled. (RO)

EFUSE\_RPT4\_RESERVED0 Reserved (used for four backups method). (RO)

EFUSE\_FLASH\_TPUW Represents flash waiting time after power-up. Measurement unit: ms. If the value is less than 15, the waiting time is the configurable value. Otherwise, the waiting time is always 30 ms. (RO)

Register 4.16. EFUSE\_RD\_REPEAT\_DATA3\_REG (0x003C)

![Image](images/04_Chapter_4_img014_8ee39ec3.png)

EFUSE\_DIS\_DOWNLOAD\_MODE Represents whether download mode (boot\_mode[3:0] = 0, 1, 2, 3, 6, 7) is disabled or enabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_RPT4\_RESERVED8 Reserved (used for four backups method). (RO)

EFUSE\_USB\_PRINT\_CHANNEL Represents whether USB printing is disabled or enabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_RPT4\_RESERVED7 Reserved (used for four backups method). (RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_DOWNLOAD\_MODE Represents whether download through USBSerial-JTAG is disabled or enabled. 1: Disabled. 0: Enabled. (RO)

EFUSE\_ENABLE\_SECURITY\_DOWNLOAD Represents whether secure UART download mode is enabled or disabled (read/write flash only). 1: Enabled. 0: Disabled. (RO)

EFUSE\_UART\_PRINT\_CONTROL Represents the UART boot message output mode. 00: Enabled. 01: Enabled when GPIO8 is low at reset. 10: Enabled when GPIO8 is high at reset. 11: Disabled. (RO)

EFUSE\_RPT4\_RESERVED5 Reserved (used for four backups method). (RO)

EFUSE\_FORCE\_SEND\_RESUME Represents whether or not to force ROM code to send a resume command during SPI boot. 1: Send. 0: Not send. (RO)

EFUSE\_SECURE\_VERSION Represents the values of version control register (used by ESP-IDF antirollback feature). (RO)

EFUSE\_RPT4\_RESERVED1 Reserved (used for four backups method). (RO)

EFUSE\_ERR\_RST\_ENABLE Represents whether to enable the check for error registers of block0. 1: Enabled. 0: Disabled. (RO)

Register 4.17. EFUSE\_RD\_REPEAT\_DATA4\_REG (0x0040)

![Image](images/04_Chapter_4_img015_75657da0.png)

EFUSE\_RPT4\_RESERVED4 Reserved (used for four backups method). (RO)

Register 4.18. EFUSE\_RD\_MAC\_SPI\_SYS\_0\_REG (0x0044)

![Image](images/04_Chapter_4_img016_e3e1d9f9.png)

![Image](images/04_Chapter_4_img017_00ab51b3.png)

EFUSE\_MAC\_0 Stores the low 32 bits of MAC address. (RO)

## Register 4.19. EFUSE\_RD\_MAC\_SPI\_SYS\_1\_REG (0x0048)

![Image](images/04_Chapter_4_img018_51a41349.png)

EFUSE\_MAC\_1 Stores the high 16 bits of MAC address. (RO)

EFUSE\_SPI\_PAD\_CONF\_0 Stores the zeroth part of SPI\_PAD\_CONF. (RO)

Register 4.20. EFUSE\_RD\_MAC\_SPI\_SYS\_2\_REG (0x004C)

EFUSE\_SPI\_PAD\_CONF\_1

![Image](images/04_Chapter_4_img019_44bc8afb.png)

EFUSE\_SPI\_PAD\_CONF\_1 Stores the first part of SPI\_PAD\_CONF. (RO)

## Register 4.21. EFUSE\_RD\_MAC\_SPI\_SYS\_3\_REG (0x0050)

![Image](images/04_Chapter_4_img020_3b24ca3e.png)

EFUSE\_SPI\_PAD\_CONF\_2 Stores the second part of SPI\_PAD\_CONF. (RO)

EFUSE\_SYS\_DATA\_PART0\_0 Stores the first 14 bits of the zeroth part of system data. (RO)

Register 4.22. EFUSE\_RD\_MAC\_SPI\_SYS\_4\_REG (0x0054)

![Image](images/04_Chapter_4_img021_5e24311b.png)

EFUSE\_SYS\_DATA\_PART0\_1 Stores the fist 32 bits of the zeroth part of system data. (RO)

![Image](images/04_Chapter_4_img022_2d31dce1.png)

![Image](images/04_Chapter_4_img023_2319e654.png)

Register 4.29. EFUSE\_RD\_SYS\_PART1\_DATA5\_REG (0x0070)

![Image](images/04_Chapter_4_img024_dd7adcd3.png)

EFUSE\_SYS\_DATA\_PART1\_5 Stores the fifth 32 bits of the first part of system data. (RO)

Register 4.30. EFUSE\_RD\_SYS\_PART1\_DATA6\_REG (0x0074)

![Image](images/04_Chapter_4_img025_52d11408.png)

EFUSE\_SYS\_DATA\_PART1\_6 Stores the sixth 32 bits of the first part of system data. (RO)

Register 4.31. EFUSE\_RD\_SYS\_PART1\_DATA7\_REG (0x0078)

![Image](images/04_Chapter_4_img026_2a2e66ef.png)

EFUSE\_SYS\_DATA\_PART1\_7 Stores the seventh 32 bits of the first part of system data. (RO)

![Image](images/04_Chapter_4_img027_b3b908e0.png)

![Image](images/04_Chapter_4_img028_35ecc4e2.png)

Register 4.40. EFUSE\_RD\_KEY0\_DATA0\_REG (0x009C)

EFUSE\_KEY0\_DATA0

![Image](images/04_Chapter_4_img029_c87238e8.png)

EFUSE\_KEY0\_DATA0 Stores the zeroth 32 bits of KEY0. (RO)

Register 4.41. EFUSE\_RD\_KEY0\_DATA1\_REG (0x00A0)

EFUSE\_KEY0\_DATA1

![Image](images/04_Chapter_4_img030_2f59ad06.png)

EFUSE\_KEY0\_DATA1 Stores the first 32 bits of KEY0. (RO)

Register 4.42. EFUSE\_RD\_KEY0\_DATA2\_REG (0x00A4)

EFUSE\_KEY0\_DATA2

![Image](images/04_Chapter_4_img031_b6533bb2.png)

EFUSE\_KEY0\_DATA2 Stores the second 32 bits of KEY0. (RO)

Register 4.43. EFUSE\_RD\_KEY0\_DATA3\_REG (0x00A8)

![Image](images/04_Chapter_4_img032_3bd82545.png)

EFUSE\_KEY0\_DATA3 Stores the third 32 bits of KEY0. (RO)

Register 4.44. EFUSE\_RD\_KEY0\_DATA4\_REG (0x00AC)

EFUSE\_KEY0\_DATA4

![Image](images/04_Chapter_4_img033_8cb0369e.png)

EFUSE\_KEY0\_DATA4 Stores the fourth 32 bits of KEY0. (RO)

Register 4.45. EFUSE\_RD\_KEY0\_DATA5\_REG (0x00B0)

EFUSE\_KEY0\_DATA5

![Image](images/04_Chapter_4_img034_4445ad43.png)

EFUSE\_KEY0\_DATA5 Stores the fifth 32 bits of KEY0. (RO)

Register 4.46. EFUSE\_RD\_KEY0\_DATA6\_REG (0x00B4)

EFUSE\_KEY0\_DATA6

![Image](images/04_Chapter_4_img035_ae8720b8.png)

EFUSE\_KEY0\_DATA6 Stores the sixth 32 bits of KEY0. (RO)

Register 4.47. EFUSE\_RD\_KEY0\_DATA7\_REG (0x00B8)

![Image](images/04_Chapter_4_img036_48dac7a3.png)

EFUSE\_KEY0\_DATA7 Stores the seventh 32 bits of KEY0. (RO)

![Image](images/04_Chapter_4_img037_239392b9.png)

![Image](images/04_Chapter_4_img038_956d7b74.png)

Register 4.56. EFUSE\_RD\_KEY2\_DATA0\_REG (0x00DC)

EFUSE\_KEY2\_DATA0

![Image](images/04_Chapter_4_img039_5587c399.png)

EFUSE\_KEY2\_DATA0 Stores the zeroth 32 bits of KEY2. (RO)

Register 4.57. EFUSE\_RD\_KEY2\_DATA1\_REG (0x00E0)

EFUSE\_KEY2\_DATA1

![Image](images/04_Chapter_4_img040_774556c6.png)

EFUSE\_KEY2\_DATA1 Stores the first 32 bits of KEY2. (RO)

Register 4.58. EFUSE\_RD\_KEY2\_DATA2\_REG (0x00E4)

EFUSE\_KEY2\_DATA2

![Image](images/04_Chapter_4_img041_0f631b07.png)

EFUSE\_KEY2\_DATA2 Stores the second 32 bits of KEY2. (RO)

Register 4.59. EFUSE\_RD\_KEY2\_DATA3\_REG (0x00E8)

![Image](images/04_Chapter_4_img042_d8f5cc49.png)

EFUSE\_KEY2\_DATA3 Stores the third 32 bits of KEY2. (RO)

Register 4.60. EFUSE\_RD\_KEY2\_DATA4\_REG (0x00EC)

EFUSE\_KEY2\_DATA4

![Image](images/04_Chapter_4_img043_097ce7c7.png)

EFUSE\_KEY2\_DATA4 Stores the fourth 32 bits of KEY2. (RO)

Register 4.61. EFUSE\_RD\_KEY2\_DATA5\_REG (0x00F0)

EFUSE\_KEY2\_DATA5

![Image](images/04_Chapter_4_img044_92807da3.png)

EFUSE\_KEY2\_DATA5 Stores the fifth 32 bits of KEY2. (RO)

Register 4.62. EFUSE\_RD\_KEY2\_DATA6\_REG (0x00F4)

EFUSE\_KEY2\_DATA6

![Image](images/04_Chapter_4_img045_e26d756b.png)

EFUSE\_KEY2\_DATA6 Stores the sixth 32 bits of KEY2. (RO)

Register 4.63. EFUSE\_RD\_KEY2\_DATA7\_REG (0x00F8)

![Image](images/04_Chapter_4_img046_0558c689.png)

EFUSE\_KEY2\_DATA7 Stores the seventh 32 bits of KEY2. (RO)

Register 4.64. EFUSE\_RD\_KEY3\_DATA0\_REG (0x00FC)

EFUSE\_KEY3\_DATA0

![Image](images/04_Chapter_4_img047_e27b465c.png)

EFUSE\_KEY3\_DATA0 Stores the zeroth 32 bits of KEY3. (RO)

Register 4.65. EFUSE\_RD\_KEY3\_DATA1\_REG (0x0100)

![Image](images/04_Chapter_4_img048_2f98d7e2.png)

![Image](images/04_Chapter_4_img049_09a3b701.png)

EFUSE\_KEY3\_DATA1 Stores the first 32 bits of KEY3. (RO)

Register 4.66. EFUSE\_RD\_KEY3\_DATA2\_REG (0x0104)

EFUSE\_KEY3\_DATA2

![Image](images/04_Chapter_4_img050_feb391bc.png)

EFUSE\_KEY3\_DATA2 Stores the second 32 bits of KEY3. (RO)

Register 4.67. EFUSE\_RD\_KEY3\_DATA3\_REG (0x0108)

![Image](images/04_Chapter_4_img051_8888da74.png)

![Image](images/04_Chapter_4_img052_5798c2b9.png)

EFUSE\_KEY3\_DATA3 Stores the third 32 bits of KEY3. (RO)

Register 4.68. EFUSE\_RD\_KEY3\_DATA4\_REG (0x010C)

![Image](images/04_Chapter_4_img053_1d5bf615.png)

EFUSE\_KEY3\_DATA4 Stores the fourth 32 bits of KEY3. (RO)

Register 4.69. EFUSE\_RD\_KEY3\_DATA5\_REG (0x0110)

EFUSE\_KEY3\_DATA5

![Image](images/04_Chapter_4_img054_6bad427f.png)

EFUSE\_KEY3\_DATA5 Stores the fifth 32 bits of KEY3. (RO)

Register 4.70. EFUSE\_RD\_KEY3\_DATA6\_REG (0x0114)

EFUSE\_KEY3\_DATA6

![Image](images/04_Chapter_4_img055_9e0d5047.png)

EFUSE\_KEY3\_DATA6 Stores the sixth 32 bits of KEY3. (RO)

Register 4.71. EFUSE\_RD\_KEY3\_DATA7\_REG (0x0118)

![Image](images/04_Chapter_4_img056_5753e2d2.png)

EFUSE\_KEY3\_DATA7 Stores the seventh 32 bits of KEY3. (RO)

Register 4.72. EFUSE\_RD\_KEY4\_DATA0\_REG (0x011C)

EFUSE\_KEY4\_DATA0

![Image](images/04_Chapter_4_img057_b04b4a7b.png)

EFUSE\_KEY4\_DATA0 Stores the zeroth 32 bits of KEY4. (RO)

Register 4.73. EFUSE\_RD\_KEY4\_DATA1\_REG (0x0120)

EFUSE\_KEY4\_DATA1

![Image](images/04_Chapter_4_img058_13597f85.png)

EFUSE\_KEY4\_DATA1 Stores the first 32 bits of KEY4. (RO)

Register 4.74. EFUSE\_RD\_KEY4\_DATA2\_REG (0x0124)

EFUSE\_KEY4\_DATA2

![Image](images/04_Chapter_4_img059_a2e736c1.png)

EFUSE\_KEY4\_DATA2 Stores the second 32 bits of KEY4. (RO)

Register 4.75. EFUSE\_RD\_KEY4\_DATA3\_REG (0x0128)

![Image](images/04_Chapter_4_img060_079ebf5a.png)

![Image](images/04_Chapter_4_img061_5611f09e.png)

EFUSE\_KEY4\_DATA3 Stores the third 32 bits of KEY4. (RO)

Register 4.76. EFUSE\_RD\_KEY4\_DATA4\_REG (0x012C)

EFUSE\_KEY4\_DATA4

![Image](images/04_Chapter_4_img062_171b770e.png)

EFUSE\_KEY4\_DATA4 Stores the fourth 32 bits of KEY4. (RO)

Register 4.77. EFUSE\_RD\_KEY4\_DATA5\_REG (0x0130)

EFUSE\_KEY4\_DATA5

![Image](images/04_Chapter_4_img063_0c6db283.png)

EFUSE\_KEY4\_DATA5 Stores the fifth 32 bits of KEY4. (RO)

Register 4.78. EFUSE\_RD\_KEY4\_DATA6\_REG (0x0134)

EFUSE\_KEY4\_DATA6

![Image](images/04_Chapter_4_img064_fb42d2c9.png)

EFUSE\_KEY4\_DATA6 Stores the sixth 32 bits of KEY4. (RO)

Register 4.79. EFUSE\_RD\_KEY4\_DATA7\_REG (0x0138)

![Image](images/04_Chapter_4_img065_92c8ea43.png)

![Image](images/04_Chapter_4_img066_764bed3f.png)

EFUSE\_KEY4\_DATA7 Stores the seventh 32 bits of KEY4. (RO)

Register 4.80. EFUSE\_RD\_KEY5\_DATA0\_REG (0x013C)

EFUSE\_KEY5\_DATA0

![Image](images/04_Chapter_4_img067_d9309a87.png)

EFUSE\_KEY5\_DATA0 Stores the zeroth 32 bits of KEY5. (RO)

Register 4.81. EFUSE\_RD\_KEY5\_DATA1\_REG (0x0140)

![Image](images/04_Chapter_4_img068_26abe26a.png)

![Image](images/04_Chapter_4_img069_932153ec.png)

EFUSE\_KEY5\_DATA1 Stores the first 32 bits of KEY5. (RO)

Register 4.82. EFUSE\_RD\_KEY5\_DATA2\_REG (0x0144)

EFUSE\_KEY5\_DATA2

![Image](images/04_Chapter_4_img070_da37dec8.png)

EFUSE\_KEY5\_DATA2 Stores the second 32 bits of KEY5. (RO)

Register 4.83. EFUSE\_RD\_KEY5\_DATA3\_REG (0x0148)

![Image](images/04_Chapter_4_img071_7c0bd227.png)

EFUSE\_KEY5\_DATA3 Stores the third 32 bits of KEY5. (RO)

Register 4.84. EFUSE\_RD\_KEY5\_DATA4\_REG (0x014C)

EFUSE\_KEY5\_DATA4

![Image](images/04_Chapter_4_img072_a0e38a55.png)

EFUSE\_KEY5\_DATA4 Stores the fourth 32 bits of KEY5. (RO)

Register 4.85. EFUSE\_RD\_KEY5\_DATA5\_REG (0x0150)

EFUSE\_KEY5\_DATA5

![Image](images/04_Chapter_4_img073_675a5680.png)

EFUSE\_KEY5\_DATA5 Stores the fifth 32 bits of KEY5. (RO)

Register 4.86. EFUSE\_RD\_KEY5\_DATA6\_REG (0x0154)

EFUSE\_KEY5\_DATA6

![Image](images/04_Chapter_4_img074_ea3f82ce.png)

EFUSE\_KEY5\_DATA6 Stores the sixth 32 bits of KEY5. (RO)

Register 4.87. EFUSE\_RD\_KEY5\_DATA7\_REG (0x0158)

![Image](images/04_Chapter_4_img075_c582377c.png)

EFUSE\_KEY5\_DATA7 Stores the seventh 32 bits of KEY5. (RO)

Register 4.88. EFUSE\_RD\_SYS\_PART2\_DATA0\_REG (0x015C)

![Image](images/04_Chapter_4_img076_0d5d0768.png)

EFUSE\_SYS\_DATA\_PART2\_0 Stores the 0th 32 bits of the 2nd part of system data. (RO)

Register 4.89. EFUSE\_RD\_SYS\_PART2\_DATA1\_REG (0x0160)

![Image](images/04_Chapter_4_img077_bf5b6a3b.png)

EFUSE\_SYS\_DATA\_PART2\_1 Stores the 1st 32 bits of the 2nd part of system data. (RO)

Register 4.90. EFUSE\_RD\_SYS\_PART2\_DATA2\_REG (0x0164)

![Image](images/04_Chapter_4_img078_1b447332.png)

EFUSE\_SYS\_DATA\_PART2\_2 Stores the 2nd 32 bits of the 2nd part of system data. (RO)

Register 4.91. EFUSE\_RD\_SYS\_PART2\_DATA3\_REG (0x0168)

![Image](images/04_Chapter_4_img079_f088a59c.png)

![Image](images/04_Chapter_4_img080_540c6a19.png)

Register 4.96. EFUSE\_RD\_REPEAT\_ERR0\_REG (0x017C)

![Image](images/04_Chapter_4_img081_2dcdea6e.png)

EFUSE\_RD\_DIS\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_RD\_DIS. (RO)

EFUSE\_DIS\_RTC\_RAM\_BOOT\_ERR Reserved. (RO)

EFUSE\_DIS\_ICACHE\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_ICACHE. (RO)

EFUSE\_DIS\_USB\_JTAG\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_USB\_JTAG. (RO)

EFUSE\_DIS\_DOWNLOAD\_ICACHE\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_DOWNLOAD\_ICACHE. (RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_USB\_SERIAL\_JTAG. (RO)

EFUSE\_DIS\_FORCE\_DOWNLOAD\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_FORCE\_DOWNLOAD. (RO)

EFUSE\_RPT4\_RESERVED6\_ERR Reserved. (RO)

EFUSE\_DIS\_TWAI\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_TWAI. (RO)

EFUSE\_JTAG\_SEL\_ENABLE\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_JTAG\_SEL\_ENABLE. (RO)

EFUSE\_SOFT\_DIS\_JTAG\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_SOFT\_DIS\_JTAG. (RO)

EFUSE\_DIS\_PAD\_JTAG\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_PAD\_JTAG. (RO)

EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT. (RO)

EFUSE\_USB\_EXCHG\_PINS\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_USB\_EXCHG\_PINS. (RO)

EFUSE\_VDD\_SPI\_AS\_GPIO\_ERR Any bit in this filed set to 1 indicates that an error occurs in pro-

ESP32-C3 TRM (Version 1.3)

Register 4.97. EFUSE\_RD\_REPEAT\_ERR1\_REG (0x0180)

![Image](images/04_Chapter_4_img082_d0a5d4a1.png)

EFUSE\_RPT4\_RESERVED2\_ERR Reserved. (RO)

EFUSE\_WDT\_DELAY\_SEL\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_WDT\_DELAY\_SEL. (RO)

EFUSE\_SPI\_BOOT\_CRYPT\_CNT\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_SPI\_BOOT\_CRYPT\_CNT. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE0\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_SECURE\_BOOT\_KEY\_REVOKE0. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE1\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_SECURE\_BOOT\_KEY\_REVOKE1. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE2\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_SECURE\_BOOT\_KEY\_REVOKE2. (RO)

EFUSE\_KEY\_PURPOSE\_0\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_KEY\_PURPOSE\_0. (RO)

EFUSE\_KEY\_PURPOSE\_1\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_KEY\_PURPOSE\_1. (RO)

Register 4.98. EFUSE\_RD\_REPEAT\_ERR2\_REG (0x0184)

![Image](images/04_Chapter_4_img083_925991e2.png)

EFUSE\_KEY\_PURPOSE\_2\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_KEY\_PURPOSE\_2. (RO)

EFUSE\_KEY\_PURPOSE\_3\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_KEY\_PURPOSE\_3. (RO)

EFUSE\_KEY\_PURPOSE\_4\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_KEY\_PURPOSE\_4. (RO)

EFUSE\_KEY\_PURPOSE\_5\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_KEY\_PURPOSE\_5. (RO)

EFUSE\_RPT4\_RESERVED3\_ERR Reserved. (RO)

EFUSE\_SECURE\_BOOT\_EN\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_SECURE\_BOOT\_EN. (RO)

EFUSE\_SECURE\_BOOT\_AGGRESSIVE\_REVOKE\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_SECURE\_BOOT\_AGGRESSIVE\_REVOKE. (RO)

EFUSE\_RPT4\_RESERVED0\_ERR Reserved. (RO)

EFUSE\_FLASH\_TPUW\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_FLASH\_TPUW. (RO)

## Register 4.99. EFUSE\_RD\_REPEAT\_ERR3\_REG (0x0188)

![Image](images/04_Chapter_4_img084_56a83480.png)

EFUSE\_DIS\_DOWNLOAD\_MODE\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_DOWNLOAD\_MODE. (RO)

EFUSE\_RPT4\_RESERVED8\_ERR Reserved. (RO)

EFUSE\_USB\_PRINT\_CHANNEL\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_DOWNLOAD\_MODE. (RO)

EFUSE\_RPT4\_RESERVED7\_ERR Reserved. (RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_DOWNLOAD\_MODE\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_DIS\_USB\_SERIAL\_JTAG\_DOWNLOAD\_MODE. (RO)

EFUSE\_ENABLE\_SECURITY\_DOWNLOAD\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_ENABLE\_SECURITY\_DOWNLOAD. (RO)

EFUSE\_UART\_PRINT\_CONTROL\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_UART\_PRINT\_CONTROL. (RO)

EFUSE\_RPT4\_RESERVED5\_ERR Reserved. (RO)

EFUSE\_FORCE\_SEND\_RESUME\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_FORCE\_SEND\_RESUME (RO)

EFUSE\_SECURE\_VERSION\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_SECURE\_VERSION. (RO)

EFUSE\_RPT4\_RESERVED1\_ERR Reserved. (RO)

EFUSE\_ERR\_RST\_ENABLE\_ERR Any bit in this filed set to 1 indicates that an error occurs in programming EFUSE\_ERR\_RST\_ENABLE. (RO)

![Image](images/04_Chapter_4_img085_7b4cb7a3.png)

Register 4.100. EFUSE\_RD\_REPEAT\_ERR4\_REG (0x018C)

![Image](images/04_Chapter_4_img086_6b89fa9d.png)

EFUSE\_RPT4\_RESERVED4\_ERR Reserved. (RO)

Register 4.101. EFUSE\_RD\_RS\_ERR0\_REG (0x01C0)

![Image](images/04_Chapter_4_img087_d95b8d7d.png)

EFUSE\_MAC\_SPI\_8M\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_SYS\_PART1\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_MAC\_SPI\_8M\_FAIL 0: Means no failure and that the data of MAC\_SPI\_8M is reliable 1: Means that programming data of MAC\_SPI\_8M failed and the number of error bytes is over 6. (RO)

EFUSE\_USR\_DATA\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_SYS\_PART1\_FAIL 0: Means no failure and that the data of system part1 is reliable 1: Means that programming data of system part1 failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY0\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_USR\_DATA\_FAIL 0: Means no failure and that the user data is reliable 1: Means that programming user data failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY1\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_KEY0\_FAIL 0: Means no failure and that the data of key0 is reliable 1: Means that programming key0 failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY2\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_KEY1\_FAIL 0: Means no failure and that the data of key1 is reliable 1: Means that programming key1 failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY3\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_KEY2\_FAIL 0: Means no failure and that the data of key2 is reliable 1: Means that programming key2 failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY4\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_KEY3\_FAIL 0: Means no failure and that the data of key3 is reliable 1: Means that programming key3 failed and the number of error bytes is over 6. (RO)

![Image](images/04_Chapter_4_img088_3bb98d31.png)

## Register 4.102. EFUSE\_RD\_RS\_ERR1\_REG (0x01C4)

![Image](images/04_Chapter_4_img089_42001b60.png)

EFUSE\_KEY5\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_KEY4\_FAIL 0: Means no failure and that the data of KEY4 is reliable 1: Means that programming KEY4 data failed and the number of error bytes is over 6. (RO)

EFUSE\_SYS\_PART2\_ERR\_NUM The value of this signal means the number of error bytes. (RO)

EFUSE\_KEY5\_FAIL 0: Means no failure and that the data of KEY5 is reliable 1: Means that programming KEY5 data failed and the number of error bytes is over 6. (RO)

## Register 4.103. EFUSE\_CLK\_REG (0x01C8)

![Image](images/04_Chapter_4_img090_57a6d521.png)

EFUSE\_EFUSE\_MEM\_FORCE\_PD Set this bit to force eFuse SRAM into power-saving mode. (R/W)

EFUSE\_MEM\_CLK\_FORCE\_ON Set this bit and force to activate clock signal of eFuse SRAM. (R/W)

EFUSE\_EFUSE\_MEM\_FORCE\_PU Set this bit to force eFuse SRAM into working mode. (R/W)

EFUSE\_CLK\_EN Set this bit and force to enable clock signal of eFuse memory. (R/W)

Register 4.104. EFUSE\_CONF\_REG (0x01CC)

![Image](images/04_Chapter_4_img091_ab9c221e.png)

EFUSE\_OP\_CODE 0x5A5A: Operate programming command 0x5AA5: Operate read command. (R/W)

## Register 4.105. EFUSE\_CMD\_REG (0x01D4)

![Image](images/04_Chapter_4_img092_fa9a3873.png)

EFUSE\_READ\_CMD Set this bit to send read command. (R/WS/SC)

EFUSE\_PGM\_CMD Set this bit to send programming command. (R/WS/SC)

EFUSE\_BLK\_NUM The serial number of the block to be programmed. Value 0-10 corresponds to block number 0-10, respectively. (R/W)

Register 4.106. EFUSE\_DAC\_CONF\_REG (0x01E8)

![Image](images/04_Chapter_4_img093_51b0d946.png)

EFUSE\_DAC\_CLK\_DIV Controls the division factor of the rising clock of the programming voltage. (R/W)

EFUSE\_DAC\_CLK\_PAD\_SEL Don’t care. (R/W)

EFUSE\_DAC\_NUM Controls the rising period of the programming voltage. (R/W)

EFUSE\_OE\_CLR Reduces the power supply of the programming voltage. (R/W)

Register 4.107. EFUSE\_RD\_TIM\_CONF\_REG (0x01EC)

EFUSE\_PWR\_OFF\_NUM Configures the power outage time for VDDQ. (R/W)

![Image](images/04_Chapter_4_img094_a965a333.png)

![Image](images/04_Chapter_4_img095_8be11183.png)

![Image](images/04_Chapter_4_img096_71909d70.png)

## Register 4.113. EFUSE\_INT\_ENA\_REG (0x01E0)

![Image](images/04_Chapter_4_img097_86f29057.png)

## Register 4.114. EFUSE\_INT\_CLR\_REG (0x01E4)

![Image](images/04_Chapter_4_img098_af1811c3.png)

## Register 4.115. EFUSE\_DATE\_REG (0x01FC)

![Image](images/04_Chapter_4_img099_1059bd4a.png)

EFUSE\_DATE Stores eFuse version. (R/W)

![Image](images/04_Chapter_4_img100_6f5aac7f.png)

## Part III

## System Component

Encompassing a range of system-level functionalities, this part describes components related to system boot, clocks, GPIO, timers, watchdogs, debug assistance, low-power management, and various system registers.
