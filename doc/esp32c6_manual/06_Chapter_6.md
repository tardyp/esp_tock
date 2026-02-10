---
chapter: 6
title: "Chapter 6"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 6

## eFuse Controller

## 6.1 Overview

ESP32-C6 contains a 4096-bit eFuse memory to store parameters and user data. The parameters include control parameters for some hardware modules, system data parameters and keys used for the decryption module. Once an eFuse bit is programmed to 1, it can never be reverted to 0. The eFuse controller programs individual bits of parameters in eFuse according to user configurations. From outside the chip, eFuse data can only be read via the eFuse controller. For some data, such as some keys stored in eFuse for internal use by hardware cryptography modules (e.g., digital signature, HMAC), if read protection is not enabled, the data can be read from outside the chip; if read protection is enabled, the data cannot be read from outside the chip.

## 6.2 Features

- 4096-bit one-time programmable storage including 1792 bits reserved for custom use
- Configurable write protection
- Configurable read protection
- Various hardware encoding schemes against data corruption

## 6.3 Functional Description

## 6.3.1 Structure

The eFuse system consists of the eFuse controller and eFuse memory. Data flow in this system is shown in Figure 6.3-1 .

Users can program bits in the eFuse memory via the eFuse controller by writing the data to be programmed to the programming register and executing the programming instruction. For detailed programming steps, please refer to Section 6.3.2 .

Users cannot directly read the data programmed in the eFuse memory, so they need to read the programmed data into the Reading Data Register of the corresponding address segment through the eFuse controller. During the reading process, if the data is inconsistent with that in the eFuse memory, the eFuse controller can automatically correct it through the hardware encoding mechanism (see Section 6.3.1.3 for details), and send the error message to the error report register. For detailed steps to read parameters, please refer to the Section 6.3.3 .

Figure 6.3-1. Data Flow in eFuse

![Image](images/06_Chapter_6_img001_9cf341d6.png)

Data in eFuse memory is organized in 11 blocks (BLOCK0 ~ BLOCK10).

BLOCK0 holds most parameters for software and hardware uses.

Table 6.3-1 lists all the parameters accessible (readable and usable) to users in BLOCK0 and their offsets, bit widths, accessibility by hardware, write protection, and brief function description. For more description on the parameters, please click the link of the corresponding parameter in the table.

The EFUSE\_WR\_DIS parameter is used to disable write protection of other parameters. EFUSE\_RD\_DIS is used to disable read protection of BLOCK4 ~ BLOCK10. For more information on these two parameters, please see Section 6.3.1.1 and Section 6.3.1.2 .

Chapter 6 eFuse Controller

Represents whether writing of eFuse bits by eFuse con-

Table 6.3-1. Parameters in eFuse BLOCK0

Description

Parameters

Espressif Systems

10 in

~

Represents whether reading data from BLOCK4

troller is disabled.

eFuse memory by users is disabled.

Represents whether the pads of UART and SDIO are swapped or not.

Represents whether iCache is disabled.

Represents whether the USB-to-JTAG function in the USB

module is disabled.

Represents whether iCache is disabled in Download mode.

Represents whether the USB\_Serial\_JTAG module is dis-

Represents whether the function to force the chip into

Download mode is disabled.

Represents whether the SPI0 controller is disabled in

180

Submit Documentation Feedback boot\_mode\_download.

Represents whether the TWAI controller is disabled.

EFUSE\_DIS\_USB\_JTAG

and

EFUSE\_DIS\_PAD\_JTAG

| N/A  0  2                                 | 2                        | 17  2                       | 2 both  31                                 | 2                  |
|-------------------------------------------|--------------------------|-----------------------------|--------------------------------------------|--------------------|
| Write Protection  EFUSE_WR_DIS Bit Number |                          |                             |                                            |                    |
| by                                        |                          |                             |                                            |                    |
| Accessible by Hardware  Y                 |                          | Y                           | Y                                          | Y                  |
| Y  Y                                      | Y                        | Y                           | Y                                          |                    |
| Bit  Width  32 7  1                       | 1                        | 1  1                        | 1  3                                       | 1                  |
| EFUSE_SWAP_UART_SDIO_EN                   |                          |                             | EFUSE_JTAG_SEL_ENABLE  EFUSE_SOFT_DIS_JTAG | EFUSE_DIS_PAD_JTAG |
|                                           | EFUSE_DIS_FORCE_DOWNLOAD | EFUSE_SPI_DOWNLOAD_MSPI_DIS |                                            |                    |
| EFUSE_WR_DIS  EFUSE_RD_DIS                |                          | EFUSE_DIS_TWAI              |                                            |                    |

are configured to 0.

GoBack

Represents whether the selection of a JTAG signal sourcethrough the strapping value of GPIO15 is enabled when

Represents whether JTAG is disabled in the soft way.

Represents whether JTAG is disabled in the hard way (per- manently).

ESP32-C6 TRM (Version 1.1)

Cont’d on next page

Chapter 6 eFuse Controller

Table 6.3-1 – cont’d from previous page

Description

Represents whether flash encryption is disabled (except in

SPI boot mode).

Represents whether the D+ and D- pins are exchanged.

Represents whether the VDD\_SPI pin is used as a regular

Espressif Systems

Represents whether RTC watchdog timeout threshold is selected at startup.

Represents whether SPI boot encryption/decryption is en-

Represents whether revoking the first Secure Boot key is

Represents whether revoking the second Secure Boot key is enabled.

Represents whether revoking the third Secure Boot key is

.

6.3-2

Represents Key0 purpose. See Table

181

Submit Documentation Feedback

.

6.3-2

Represents Key1 purpose. See Table

.

6.3-2

Represents Key2 purpose. See Table

.

6.3-2

Represents Key3 purpose. See Table

.

6.3-2

.

6.3-2

GoBack

Represents the security level of anti-DPA (differential power

Cont’d on next page

Represents Key4 purpose. See Table

Represents Key5 purpose. See Table analysis) attack.

Represents whether defense against DPA attack is en-

Represents whether Secure Boot is enabled or disabled.

ESP32-C6 TRM (Version 1.1)

| GPIO.                                                                        | enabled.                      |                     | abled.              |                                              |
|------------------------------------------------------------------------------|-------------------------------|---------------------|---------------------|----------------------------------------------|
| Write Protection  EFUSE_WR_DIS Bit Number  2  30  30  3                      | 7                             | 9                   | 14                  | 15  16                                       |
| by                                                                           |                               |                     |                     |                                              |
| Accessible by Hardware  Y Y  Y  Y                                            | N                             | Y                   | Y                   | Y  N                                         |
| Bit  Width  1  1  1  2                                                       | 1                             | 4                   | 2 1                 | 1                                            |
| EFUSE_DIS_DOWNLOAD_MANUAL_ENCRYPT                                            |                               |                     |                     |                                              |
|                                                                              |                               | EFUSE_KEY_PURPOSE_1 |                     |                                              |
|                                                                              | EFUSE_SECURE_BOOT_KEY_REVOKE2 |                     | EFUSE_SEC_DPA_LEVEL |                                              |
| Parameters  EFUSE_USB_EXCHG_PINS  EFUSE_VDD_SPI_AS_GPIO  EFUSE_WDT_DELAY_SEL |                               |                     |                     | EFUSE_CRYPT_DPA_ENABLE  EFUSE_SECURE_BOOT_EN |

Chapter 6 eFuse Controller

Table 6.3-1 – cont’d from previous page

GoBack

|               | ture.   |                                                                   |
|---------------|---------|-------------------------------------------------------------------|
| 18  18        | 18      | Write Protection  EFUSE_WR_DIS Bit Number  16  18  18  18  18  18 |
| by            |         |                                                                   |
| N  N          | N       | Accessible by Hardware  N  N  N  N  N  N                          |
| 1  1  1  1  2 |         | 1  4 1                                                            |
| Bit  Width    | 16      |                                                                   |

Description

Represents whether aggressive revocation of Secure Boot is enabled.

Represents the flash waiting time after power-up.

Represents whether all download modes are disabled.

Represents whether direct boot mode is disabled.

Parameters

EFUSE\_SECURE\_BOOT\_AGGRESSIVE\_REVOKE

Espressif Systems

EFUSE\_FLASH\_TPUW

EFUSE\_DIS\_DOWNLOAD\_MODE

EFUSE\_DIS\_DIRECT\_BOOT

Represents the version used by ESP-IDF anti-rollback fea-

EFUSE\_SECURE\_VERSION

Represents whether the USB-Serial-JTAG download func- tion is disabled.

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_DOWNLOAD\_MODE

Represents whether security download is enabled.

EFUSE\_ENABLE\_SECURITY\_DOWNLOAD

Represents the type of UART printing.

EFUSE\_UART\_PRINT\_CONTROL

Represents whether ROM code is forced to send a resume command during SPI boot.

EFUSE\_FORCE\_SEND\_RESUME

Represents whether FAST VERIFY ON WAKE is disabled or enabled when Secure Boot is enabled.

EFUSE\_SECURE\_BOOT\_DISABLE\_FAST\_WAKE

182

Submit Documentation Feedback

Represents whether print from USB-Serial-JTAG during

ROM boot is disabled.

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_ROM\_PRINT

ESP32-C6 TRM (Version 1.1)

Table 6.3-2 lists all key purposes and their values. Setting the eFuse parameter EFUSE\_KEY\_PURPOSE\_n declares the purpose of KEYn (n: 0 ~ 5).

Table 6.3-2. Secure Key Purpose Values

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

Table 6.3-3 provides the details of parameters in BLOCK1 ~ BLOCK10.

Chapter 6 eFuse Controller

Table 6.3-3. Parameters in BLOCK1 to BLOCK10

Description

MAC address

Extended MAC address

System data

System data

User data

KEY0 or user data

KEY1 or user data

KEY2 or user data

KEY3 or user data

KEY4 or user data

KEY5 or user data

System data

| EFUSE_RD_DIS Bit Number   | N/A  N/A  N/A  N/A  N/A  0  1  2   | 4  5   |
|---------------------------|------------------------------------|--------|
| Read Protection  by       |                                    |        |
| Read Protection  by       | 20  20  20  21  22  23 24  25      | 27 28  |
| Read Protection  by       |                                    |        |
| Accessible by Hardware    | N  N  N  N  N  Y  Y  Y             | Y  Y   |

Bit Width

Parameters

48

EFUSE\_MAC

BLOCK

BLOCK1

Espressif Systems

16

EFUSE\_MAC\_EXT

69

EFUSE\_SYS\_DATA\_PART0

256

EFUSE\_SYS\_DATA\_PART1

BLOCK2

256

EFUSE\_USR\_DATA

BLOCK3

256

EFUSE\_KEY0\_DATA

BLOCK4

256

EFUSE\_KEY1\_DATA

BLOCK5

256

EFUSE\_KEY2\_DATA

BLOCK6

256

EFUSE\_KEY3\_DATA

BLOCK7

256

EFUSE\_KEY4\_DATA

BLOCK8

256

EFUSE\_KEY5\_DATA

256

EFUSE\_SYS\_DATA\_PART2

BLOCK9

BLOCK10

184

Submit Documentation Feedback

GoBack

ESP32-C6 TRM (Version 1.1)

Among these blocks, BLOCK4 ~ 9 can be used to store KEY0 ~ 5. Up to six 256-bit keys can be written into eFuse. Whenever a key is written, its purpose value should also be written (see table 6.3-2). For example, when a key for the JTAG function in HMAC Downstream mode is written to KEY3 (i.e., BLOCK7), its key purpose value 6 should also be written to EFUSE\_KEY\_PURPOSE\_3 .

## Note:

Do not program the XTS-AES key into the KEY5 block, i.e., BLOCK9. Otherwise, the key may be unreadable. Instead, program it into the preceding blocks, i.e., BLOCK4 ~ BLOCK8. The last block, BLOCK9, is used to program other keys.

BLOCK1 ~ BLOCK10 use the RS coding scheme, so there are some limitations on writing to these parameters. For more detailed information, please refer to Section 6.3.1.3 and Section 6.3.2 .

## 6.3.1.1 EFUSE\_WR\_DIS

Parameter EFUSE\_WR\_DIS determines whether individual eFuse parameters are write-protected. After EFUSE\_WR\_DIS has been programmed, execute an eFuse read operation so the new values would take effect.

Column "Write Protection by EFUSE\_WR\_DIS Bit Number" in Table 6.3-1 and Table 6.3-3 list the specific bits in EFUSE\_WR\_DIS that disable writing.

When the write protection bit of a parameter is set to 0, it means that this parameter is not write-protected and can be programmed, unless it has been programmed before.

When the write protection bit of a parameter is set to 1, it means that this parameter is write-protected and none of its bits can be modified, with non-programmed bits always remaining 0 and programmed bits always remaining 1. That is to say, if a parameter is write-protected, it will always remain in this state and cannot be changed.

## 6.3.1.2 EFUSE\_RD\_DIS

Only the parameters in BLOCK4 ~ BLOCK10 can be set to be read-protected from users, as shown in column "Read Protection by EFUSE\_RD\_DIS Bit Number" of Table 6.3-3. After EFUSE\_RD\_DIS has been programmed, execute an eFuse read operation so the new values would take effect.

If the corresponding EFUSE\_RD\_DIS bit is 0, the parameter controlled by this bit is not read-protected from users. If it is 1, the parameter controlled by it is read-protected from users.

Other parameters that are not in BLOCK4 ~ BLOCK10 can always be read by users.

When BLOCK4 ~ BLOCK10 are set to be read-protected, the data in them can still be read by hardware cryptography modules if the EFUSE\_KEY\_PURPOSE\_n bit is set accordingly.

## 6.3.1.3 Data Storage

Internally, eFuse uses the hardware encoding scheme to protect data from corruption. The scheme and the encoding process are invisible to users.

All BLOCK0 parameters except for EFUSE\_WR\_DIS are stored with four backups, meaning each bit is stored four times. This backup scheme is not visible to users.

In BLOCK0, EFUSE\_WR\_DIS occupies 32 bits, and other parameters takes 152 bits each. So, the eFuse memory space occupied by BLOCK0 is 32 + 152 * 4 = 640 bits.

BLOCK1 ~ BLOCK10 use RS (44, 32) coding scheme that supports up to 6 bytes of automatic error correction. The primitive polynomial of RS (44, 32) is p(x) = x 8 + x 4 + x 3 + x 2 + 1 .

Figure 6.3-2. Shift Register Circuit (first 32 output)

![Image](images/06_Chapter_6_img002_fe343d42.png)

Figure 6.3-3. Shift Register Circuit (last 12 output)

![Image](images/06_Chapter_6_img003_947ef118.png)

The shift register circuit shown in Figure 6.3-2 and 6.3-3 processes 32 data bytes using RS (44, 32). This coding scheme encodes 32 bytes of data into 44 bytes:

- Bytes [0:31] are the data bytes itself
- Bytes [32:43] are the encoded parity bytes stored in 8-bit flip-flops DFF1, DFF2, ..., DFF12 (gf\_mul\_n is the result of multiplying a byte of data in GF(2 8 ) by α n , where n is an integer).

After that, the hardware programs into eFuse the 44-byte codeword consisting of the data bytes and the parity bytes. When the eFuse block is read, the eFuse controller automatically decodes the codeword and applies error correction if needed.

Because the RS check codes are generated on the entire 32-byte eFuse block, each block can only be written once.

Since the size of BLOCK1 is less than 32 bytes, the unused bits will be treated as 0 by hardware during the RS (44, 32) encoding. Thus, the final coding result will not be affected.

Among blocks using the RS (44, 32) coding scheme, the parameters in BLOCK1 is 24 bytes, and the RS check code is 12 bytes, so BLOCK1 occupies 24 + 12 = 36 bytes in eFuse memory.

The parameter in other blocks (Block2 ~ 10) is 32 bytes respectively, and the RS check code is 12 bytes, so they occupy (32 + 12) * 9 = 396 bytes in eFuse memory.

## 6.3.2 Programming of Parameters

The eFuse controller can only program eFuse parameters in one block at a time. BLOCK0 ~ BLOCK10 share the same address range to store the parameters to be programmed. Configure parameter EFUSE\_BLK\_NUM to indicate which block should be programmed.

Since there is a one-to-one correspondence between the reading data registers and the programming data registers (see table 6.3-4 for details), users can find out where the data to be programmed is located in programming registers by checking the parameter description and the parameter location in the corresponding read registers.

For example, if the user wants to program the parameter EFUSE\_DIS\_ICACHE in BLOCK0 to 1, they can first search the reading data registers EFUSE\_RD\_REPEAT\_DATA0 ~ 4\_REG in BLOCK0 for where the parameter is located, namely, the 8th bit in EFUSE\_RD\_REPEAT\_DATA0\_REG. So, the user can set the 8th bit of EFUSE\_PGM\_DATA1\_REG to 1 and follow the programming steps below. After the steps are completed, the corresponding bit in the eFuse memory will be programmed to 1.

## Programming preparation

## · Programming BLOCK0

1. Set EFUSE\_BLK\_NUM to 0.
2. Write into EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA5\_REG the data to be programmed to BLOCK0.

The data in EFUSE\_PGM\_DATA6\_REG ~ EFUSE\_PGM\_DATA7\_REG and EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG does not affect the programming of BLOCK0.

## · Programming BLOCK1

1. Set EFUSE\_BLK\_NUM to 1.
2. Write into EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA5\_REG the data to be programmed to BLOCK1. Write into EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG the corresponding RS check code.
3. The data in EFUSE\_PGM\_DATA6\_REG ~ EFUSE\_PGM\_DATA7\_REG does not affect the programming of BLOCK1. When calculating RS check of BLOCK1 using software, please treat the 8 bytes as 0.

## · Programming BLOCK2 ~ 10

1. Set EFUSE\_BLK\_NUM to the block number.
2. Write into EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA7\_REG the data to be programmed. Write into EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG the corresponding RS code.

## Programming process

The process of programming parameters is as follows:

1. Configure the value of parameter EFUSE\_BLK\_NUM to determine the block to be programmed.
2. Write parameters to be programmed to registers EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA7\_REG and EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG .
3. Make sure the eFuse programming voltage VDDQ is configured correctly as described in Section 6.3.4 .
4. Configure the field EFUSE\_OP\_CODE of register EFUSE\_CONF\_REG to 0x5A5A.
5. Configure the field EFUSE\_PGM\_CMD of register EFUSE\_CMD\_REG to 1.
6. Poll register EFUSE\_CMD\_REG until it is 0x0, or wait for a PGM\_DONE interrupt. For more information on how to identify a PGM\_DONE or READ\_DONE interrupt, please see the end of Section 6.3.3 .
7. Clear the parameters in EFUSE\_PGM\_DATA0\_REG ~ EFUSE\_PGM\_DATA7\_REG and EFUSE\_PGM\_CHECK\_VALUE0\_REG ~ EFUSE\_PGM\_CHECK\_VALUE2\_REG .
8. Trigger an eFuse read operation (see Section 6.3.3) to update eFuse registers with the new values.
9. Check error record registers. If the values read in error record registers are not 0, the programming process should be performed again following above steps 1 ~ 7. Please check the following error record registers for different eFuse blocks:
- BLOCK0: EFUSE\_RD\_REPEAT\_ERR0\_REG ~ EFUSE\_RD\_REPEAT\_ERR4\_REG
- BLOCK1: EFUSE\_MAC\_SPI\_8M\_ERR\_NUM , EFUSE\_MAC\_SPI\_8M\_FAIL
- BLOCK2: EFUSE\_SYS\_PART1\_ERR\_NUM , EFUSE\_SYS\_PART1\_FAIL
- BLOCK3: EFUSE\_USR\_DATA\_ERR\_NUM , EFUSE\_USR\_DATA\_FAIL
- BLOCK4: EFUSE\_KEY0\_ERR\_NUM , EFUSE\_KEY0\_FAIL
- BLOCK5: EFUSE\_KEY1\_ERR\_NUM , EFUSE\_KEY1\_FAIL
- BLOCK6: EFUSE\_KEY2\_ERR\_NUM , EFUSE\_KEY2\_FAIL
- BLOCK7: EFUSE\_KEY3\_ERR\_NUM , EFUSE\_KEY3\_FAIL
- BLOCK8: EFUSE\_KEY4\_ERR\_NUM , EFUSE\_KEY4\_FAIL
- BLOCK9: EFUSE\_KEY5\_ERR\_NUM , EFUSE\_KEY5\_FAIL
- BLOCK10: EFUSE\_SYS\_PART2\_ERR\_NUM , EFUSE\_SYS\_PART2\_FAIL

## Limitations

In BLOCK0, each bit can be programmed separately. However, we recommend to minimize programming cycles and program all the bits of a parameter in one programming action. In addition, after all parameters controlled by a certain bit of EFUSE\_WR\_DIS are programmed, that bit should be immediately programmed. The programming of parameters controlled by a certain bit of EFUSE\_WR\_DIS, and the programming of the bit itself can even be completed at the same time in one programming action.

BLOCK1 cannot be programmed by users as it has been programmed at manufacturing.

BLOCK2 ~ 10 can only be programmed once. Repeated programming is not allowed.

## 6.3.3 Reading of Parameters by Users

Users cannot read eFuse bits directly. The eFuse controller hardware reads all eFuse bits and stores the results to their corresponding registers in its memory space. Then, users can read eFuse bits by reading the registers that start with EFUSE\_RD\_. Details are provided in Table 6.3-4 .

Table 6.3-4. Registers Information

| BLOCK   | Read Registers                         | Registers When Programming This Block   |
|---------|----------------------------------------|-----------------------------------------|
| 0       | EFUSE_RD_WR_DIS_REG                    | EFUSE_PGM_DATA0_REG                     |
| 0       | EFUSE_RD_REPEAT_DATA0 ~ 4_REG          | EFUSE_PGM_DATA1 ~ 5_REG                 |
| 1       | EFUSE_RD_MAC_SPI_SYS_0 ~ 5_REG         | EFUSE_PGM_DATA0 ~ 5_REG                 |
| 2       | EFUSE_RD_SYS_DATA_PART1_0 ~ 7_REG      | EFUSE_PGM_DATA0 ~ 7_REG                 |
| 3       | EFUSE_RD_USR_DATA0 ~ 7_REG             | EFUSE_PGM_DATA0 ~ 7_REG                 |
| 4-9     | EFUSE_RD_KEYn_DATA0 ~ 7_REG (n: 0 ~ 5) | EFUSE_PGM_DATA0 ~ 7_REG                 |
| 10      | EFUSE_RD_SYS_DATA_PART2_0 ~ 7_REG      | EFUSE_PGM_DATA0 ~ 7_REG                 |

## Updating reading data registers

The eFuse controller reads eFuse memory to update corresponding registers. This read operation happens at system reset and can also be triggered manually by users as needed (e.g., if new eFuse values have been programmed). The process of triggering a read operation by users is as follows:

1. Configure the field EFUSE\_OP\_CODE in register EFUSE\_CONF\_REG to 0x5AA5.
2. Configure the field EFUSE\_READ\_CMD in register EFUSE\_CMD\_REG to 1.
3. Poll register EFUSE\_CMD\_REG until it is 0x0, or wait for a READ\_DONE interrupt. Information on how to identify a PGM\_DONE or READ\_DONE interrupt is provided below in this section.
4. Read the values of each parameter from eFuse memory.

The eFuse read registers will hold all values until the next read operation.

## Error detection

Error record registers allow users to detect if there is any inconsistency between the parameter read by eFuse controller and that in eFuse memory.

Registers EFUSE\_RD\_REPEAT\_ERR0 ~ 3\_REG indicate if there are any errors in programming parameters (except EFUSE\_WR\_DIS) to BLOCK0. The value 1 indicates an error is detected in programming the corresponding bit. The value 0 indicates no error.

Registers EFUSE\_RD\_RS\_ERR0 ~ 1\_REG store the number of corrected bytes as well as the result of RS decoding when eFuse controller reads BLOCK1 ~ BLOCK10.

The values of the above registers will be updated every time the reading data registers of eFuse controller have been updated.

## Identifying program/read operation

The methods to identify the completion of a program/read operation are described below. Please note that bit 1 corresponds to a program operation, and bit 0 corresponds to a read operation.

- Method one: Poll bit 1/0 in register EFUSE\_INT\_RAW\_REG until it becomes 1, which represents the completion of a program/read operation.
- Method two:
1. Set bit 1/0 in register EFUSE\_INT\_ENA\_REG to 1 to enable the eFuse controller to post a PGM\_DONE or READ\_DONE interrupt.
2. Configure the Interrupt Matrix to enable the CPU to respond to eFuse interrupt signals. See Chapter 10 Interrupt Matrix (INTMTX) .
3. Wait for the PGM\_DONE or READ\_DONE interrupt.
4. Set bit 1/0 in register EFUSE\_INT\_CLR\_REG to 1 to clear the PGM\_DONE or READ\_DONE interrupt.

## Note

When eFuse controller is updating its registers, it will use EFUSE\_PGM\_DATAn\_REG (n=0, 1, ... ,7) again to store data. So please do not write important data into these registers before this updating process is initiated.

During the chip boot process, eFuse controller will automatically update data from eFuse memory into the registers that can be accessed by users. Users can get programmed eFuse data by reading corresponding registers. Thus, there is no need to update the reading data registers in such case.

## 6.3.4 eFuse VDDQ Timing

The eFuse controller operates at the clock frequency of 20 MHz, and its programming voltage VDDQ should be configured as follows:

- EFUSE\_DAC\_NUM (the rising period of VDDQ): The default value of VDDQ is 2.5 V and the voltage increases by 0.01 V in each clock cycle. The default value of this parameter is 255.
- EFUSE\_DAC\_CLK\_DIV (the clock divisor of VDDQ): The clock period to program VDDQ should be larger than 1 µs.
- EFUSE\_PWR\_ON\_NUM (the power-up time for VDDQ): The programming voltage should be stabilized after this time, which means the value of this parameter should be configured to exceed the result of EFUSE\_DAC\_CLK\_DIV times EFUSE\_DAC\_NUM .
- EFUSE\_PWR\_OFF\_NUM (the power-out time for VDDQ): The value of this parameter should be larger than 10 µs.

Table 6.3-5. Configuration of Default VDDQ Timing Parameters

| EFUSE_DAC_NUM   | EFUSE_DAC_CLK_DIV   | EFUSE_PWR_ON_NUM   | EFUSE_PWR_OFF_NUM   |
|-----------------|---------------------|--------------------|---------------------|
| 0xFF            | 0x28                | 0x3000             | 0x190               |

## 6.3.5 Parameters Used by Hardware Modules

Some hardware modules are directly connected to the eFuse peripheral in order to use the parameters that are marked with "Y" in columns "Accessible by Hardware" of Table 6.3-1 and Table 6.3-3. Users cannot intervene in this process.

## 6.3.6 Interrupts

- PGM\_DONE interrupt: Triggered when eFuse programming has finished. To enable this interrupt, set the EFUSE\_PGM\_DONE\_INT\_ENA field of register EFUSE\_INT\_ENA\_REG to 1.
- READ\_DONE interrupt: Triggered when eFuse reading has finished. To enable this interrupt, set the EFUSE\_READ\_DONE\_INT\_ENA field of register EFUSE\_INT\_ENA\_REG to 1.

## 6.4 Register Summary

The addresses in this section are relative to eFuse controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                         | Description                                           | Address   | Access   |
|------------------------------|-------------------------------------------------------|-----------|----------|
| Programming Data Register    |                                                       |           |          |
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
| Reading Data Register        |                                                       |           |          |
| EFUSE_RD_WR_DIS_REG          | Register 0 of BLOCK0                                  | 0x002C    | RO       |
| EFUSE_RD_REPEAT_DATA0_REG    | Register 1 of BLOCK0                                  | 0x0030    | RO       |
| EFUSE_RD_REPEAT_DATA1_REG    | Register 2 of BLOCK0                                  | 0x0034    | RO       |
| EFUSE_RD_REPEAT_DATA2_REG    | Register 3 of BLOCK0                                  | 0x0038    | RO       |
| EFUSE_RD_REPEAT_DATA3_REG    | Register 4 of BLOCK0                                  | 0x003C    | RO       |
| EFUSE_RD_REPEAT_DATA4_REG    | Register 5 of BLOCK0                                  | 0x0040    | RO       |
| EFUSE_RD_MAC_SPI_SYS_0_REG   | Register 0 of BLOCK1                                  | 0x0044    | RO       |
| EFUSE_RD_MAC_SPI_SYS_1_REG   | Register 1 of BLOCK1                                  | 0x0048    | RO       |
| EFUSE_RD_MAC_SPI_SYS_2_REG   | Register 2 of BLOCK1                                  | 0x004C    | RO       |
| EFUSE_RD_MAC_SPI_SYS_3_REG   | Register 3 of BLOCK1                                  | 0x0050    | RO       |
| EFUSE_RD_MAC_SPI_SYS_4_REG   | Register 4 of BLOCK1                                  | 0x0054    | RO       |
| EFUSE_RD_MAC_SPI_SYS_5_REG   | Register 5 of BLOCK1                                  | 0x0058    | RO       |
| EFUSE_RD_SYS_PART1_DATA0_REG | Register 0 of BLOCK2 (system)                         | 0x005C    | RO       |
| EFUSE_RD_SYS_PART1_DATA1_REG | Register 1 of BLOCK2 (system)                         | 0x0060    | RO       |
| EFUSE_RD_SYS_PART1_DATA2_REG | Register 2 of BLOCK2 (system)                         | 0x0064    | RO       |
| EFUSE_RD_SYS_PART1_DATA3_REG | Register 3 of BLOCK2 (system)                         | 0x0068    | RO       |
| EFUSE_RD_SYS_PART1_DATA4_REG | Register 4 of BLOCK2 (system)                         | 0x006C    | RO       |
| EFUSE_RD_SYS_PART1_DATA5_REG | Register 5 of BLOCK2 (system)                         | 0x0070    | RO       |
| EFUSE_RD_SYS_PART1_DATA6_REG | Register 6 of BLOCK2 (system)                         | 0x0074    | RO       |
| EFUSE_RD_SYS_PART1_DATA7_REG | Register 7 of BLOCK2 (system)                         | 0x0078    | RO       |
| EFUSE_RD_USR_DATA0_REG       | Register 0 of BLOCK3 (user)                           | 0x007C    | RO       |

| Name                    | Description                 | Address   | Access   |
|-------------------------|-----------------------------|-----------|----------|
| EFUSE_RD_USR_DATA1_REG  | Register 1 of BLOCK3 (user) | 0x0080    | RO       |
| EFUSE_RD_USR_DATA2_REG  | Register 2 of BLOCK3 (user) | 0x0084    | RO       |
| EFUSE_RD_USR_DATA3_REG  | Register 3 of BLOCK3 (user) | 0x0088    | RO       |
| EFUSE_RD_USR_DATA4_REG  | Register 4 of BLOCK3 (user) | 0x008C    | RO       |
| EFUSE_RD_USR_DATA5_REG  | Register 5 of BLOCK3 (user) | 0x0090    | RO       |
| EFUSE_RD_USR_DATA6_REG  | Register 6 of BLOCK3 (user) | 0x0094    | RO       |
| EFUSE_RD_USR_DATA7_REG  | Register 7 of BLOCK3 (user) | 0x0098    | RO       |
| EFUSE_RD_KEY0_DATA0_REG | Register 0 of BLOCK4 (KEY0) | 0x009C    | RO       |
| EFUSE_RD_KEY0_DATA1_REG | Register 1 of BLOCK4 (KEY0) | 0x00A0    | RO       |
| EFUSE_RD_KEY0_DATA2_REG | Register 2 of BLOCK4 (KEY0) | 0x00A4    | RO       |
| EFUSE_RD_KEY0_DATA3_REG | Register 3 of BLOCK4 (KEY0) | 0x00A8    | RO       |
| EFUSE_RD_KEY0_DATA4_REG | Register 4 of BLOCK4 (KEY0) | 0x00AC    | RO       |
| EFUSE_RD_KEY0_DATA5_REG | Register 5 of BLOCK4 (KEY0) | 0x00B0    | RO       |
| EFUSE_RD_KEY0_DATA6_REG | Register 6 of BLOCK4 (KEY0) | 0x00B4    | RO       |
| EFUSE_RD_KEY0_DATA7_REG | Register 7 of BLOCK4 (KEY0) | 0x00B8    | RO       |
| EFUSE_RD_KEY1_DATA0_REG | Register 0 of BLOCK5 (KEY1) | 0x00BC    | RO       |
| EFUSE_RD_KEY1_DATA1_REG | Register 1 of BLOCK5 (KEY1) | 0x00C0    | RO       |
| EFUSE_RD_KEY1_DATA2_REG | Register 2 of BLOCK5 (KEY1) | 0x00C4    | RO       |
| EFUSE_RD_KEY1_DATA3_REG | Register 3 of BLOCK5 (KEY1) | 0x00C8    | RO       |
| EFUSE_RD_KEY1_DATA4_REG | Register 4 of BLOCK5 (KEY1) | 0x00CC    | RO       |
| EFUSE_RD_KEY1_DATA5_REG | Register 5 of BLOCK5 (KEY1) | 0x00D0    | RO       |
| EFUSE_RD_KEY1_DATA6_REG | Register 6 of BLOCK5 (KEY1) | 0x00D4    | RO       |
| EFUSE_RD_KEY1_DATA7_REG | Register 7 of BLOCK5 (KEY1) | 0x00D8    | RO       |
| EFUSE_RD_KEY2_DATA0_REG | Register 0 of BLOCK6 (KEY2) | 0x00DC    | RO       |
| EFUSE_RD_KEY2_DATA1_REG | Register 1 of BLOCK6 (KEY2) | 0x00E0    | RO       |
| EFUSE_RD_KEY2_DATA2_REG | Register 2 of BLOCK6 (KEY2) | 0x00E4    | RO       |
| EFUSE_RD_KEY2_DATA3_REG | Register 3 of BLOCK6 (KEY2) | 0x00E8    | RO       |
| EFUSE_RD_KEY2_DATA4_REG | Register 4 of BLOCK6 (KEY2) | 0x00EC    | RO       |
| EFUSE_RD_KEY2_DATA5_REG | Register 5 of BLOCK6 (KEY2) | 0x00F0    | RO       |
| EFUSE_RD_KEY2_DATA6_REG | Register 6 of BLOCK6 (KEY2) | 0x00F4    | RO       |
| EFUSE_RD_KEY2_DATA7_REG | Register 7 of BLOCK6 (KEY2) | 0x00F8    | RO       |
| EFUSE_RD_KEY3_DATA0_REG | Register 0 of BLOCK7 (KEY3) | 0x00FC    | RO       |
| EFUSE_RD_KEY3_DATA1_REG | Register 1 of BLOCK7 (KEY3) | 0x0100    | RO       |
| EFUSE_RD_KEY3_DATA2_REG | Register 2 of BLOCK7 (KEY3) | 0x0104    | RO       |
| EFUSE_RD_KEY3_DATA3_REG | Register 3 of BLOCK7 (KEY3) | 0x0108    | RO       |
| EFUSE_RD_KEY3_DATA4_REG | Register 4 of BLOCK7 (KEY3) | 0x010C    | RO       |
| EFUSE_RD_KEY3_DATA5_REG | Register 5 of BLOCK7 (KEY3) | 0x0110    | RO       |
| EFUSE_RD_KEY3_DATA6_REG | Register 6 of BLOCK7 (KEY3) | 0x0114    | RO       |
| EFUSE_RD_KEY3_DATA7_REG | Register 7 of BLOCK7 (KEY3) | 0x0118    | RO       |
| EFUSE_RD_KEY4_DATA0_REG | Register 0 of BLOCK8 (KEY4) | 0x011C    | RO       |
| EFUSE_RD_KEY4_DATA1_REG | Register 1 of BLOCK8 (KEY4) | 0x0120    | RO       |
| EFUSE_RD_KEY4_DATA3_REG |                             | 0x0128    | RO       |
|                         | Register 3 of BLOCK8 (KEY4) |           |          |

| Name                         | Description                                          | Address                                              | Access                 |
|------------------------------|------------------------------------------------------|------------------------------------------------------|------------------------|
| EFUSE_RD_KEY4_DATA4_REG      | Register 4 of BLOCK8 (KEY4)                          | 0x012C                                               | RO                     |
| EFUSE_RD_KEY4_DATA5_REG      | Register 5 of BLOCK8 (KEY4)                          | 0x0130                                               | RO                     |
| EFUSE_RD_KEY4_DATA6_REG      | Register 6 of BLOCK8 (KEY4)                          | 0x0134                                               | RO                     |
| EFUSE_RD_KEY4_DATA7_REG      | Register 7 of BLOCK8 (KEY4)                          | 0x0138                                               | RO                     |
| EFUSE_RD_KEY5_DATA0_REG      | Register 0 of BLOCK9 (KEY5)                          | 0x013C                                               | RO                     |
| EFUSE_RD_KEY5_DATA1_REG      | Register 1 of BLOCK9 (KEY5)                          | 0x0140                                               | RO                     |
| EFUSE_RD_KEY5_DATA2_REG      | Register 2 of BLOCK9 (KEY5)                          | 0x0144                                               | RO                     |
| EFUSE_RD_KEY5_DATA3_REG      | Register 3 of BLOCK9 (KEY5)                          | 0x0148                                               | RO                     |
| EFUSE_RD_KEY5_DATA4_REG      | Register 4 of BLOCK9 (KEY5)                          | 0x014C                                               | RO                     |
| EFUSE_RD_KEY5_DATA5_REG      | Register 5 of BLOCK9 (KEY5)                          | 0x0150                                               | RO                     |
| EFUSE_RD_KEY5_DATA6_REG      | Register 6 of BLOCK9 (KEY5)                          | 0x0154                                               | RO                     |
| EFUSE_RD_KEY5_DATA7_REG      | Register 7 of BLOCK9 (KEY5)                          | 0x0158                                               | RO                     |
| EFUSE_RD_SYS_PART2_DATA0_REG | Register 0 of BLOCK10 (system)                       | 0x015C                                               | RO                     |
| EFUSE_RD_SYS_PART2_DATA1_REG | Register 1 of BLOCK10 (system)                       | 0x0160                                               | RO                     |
| EFUSE_RD_SYS_PART2_DATA2_REG | Register 2 of BLOCK10 (system)                       | 0x0164                                               | RO                     |
| EFUSE_RD_SYS_PART2_DATA3_REG | Register 3 of BLOCK10 (system)                       | 0x0168                                               | RO                     |
| EFUSE_RD_SYS_PART2_DATA4_REG | Register 4 of BLOCK10 (system)                       | 0x016C                                               | RO                     |
| EFUSE_RD_SYS_PART2_DATA5_REG | Register 5 of BLOCK10 (system)                       | 0x0170                                               | RO                     |
| EFUSE_RD_SYS_PART2_DATA6_REG | Register 6 of BLOCK10 (system)                       | 0x0174                                               | RO                     |
| EFUSE_RD_SYS_PART2_DATA7_REG | Register 7 of BLOCK10 (system)                       | 0x0178                                               | RO                     |
| Report Register              | Report Register                                      | Report Register                                      | Report Register        |
| EFUSE_RD_REPEAT_ERR0_REG     | Programming error record register 0 of BLOCK0        | 0x017C                                               | RO                     |
| EFUSE_RD_REPEAT_ERR1_REG     | Programming error record register 1 of BLOCK0        | 0x0180                                               | RO                     |
| EFUSE_RD_REPEAT_ERR2_REG     | Programming error record register 2 of BLOCK0        | 0x0184                                               | RO                     |
| EFUSE_RD_REPEAT_ERR3_REG     | Programming error record register 3 of BLOCK0        | 0x0188                                               | RO                     |
| EFUSE_RD_REPEAT_ERR4_REG     | Programming error record register 4 of BLOCK0        | 0x0190                                               | RO                     |
| EFUSE_RD_RS_ERR0_REG         | Programming error record register 0 of BLOCK1-10     | 0x01C0                                               | RO                     |
| EFUSE_RD_RS_ERR1_REG         | Programming error record register 1 of BLOCK1-10     | 0x01C4                                               | RO                     |
| Configuration Register       | Configuration Register                               | Configuration Register                               | Configuration Register |
| EFUSE_CLK_REG                | eFuse clock configuration register  0x01C8           | eFuse clock configuration register  0x01C8           | R/W                    |
| EFUSE_CONF_REG               | eFuse operation mode configuration register  0x01CC  | eFuse operation mode configuration register  0x01CC  | R/W                    |
| EFUSE_CMD_REG                | eFuse command register  0x01D4                       | eFuse command register  0x01D4                       | varies                 |
| EFUSE_DAC_CONF_REG           | Controls the eFuse programming voltage  0x01E8       | Controls the eFuse programming voltage  0x01E8       | R/W                    |
| EFUSE_RD_TIM_CONF_REG        | Configures read timing parameters  0x01EC            | Configures read timing parameters  0x01EC            | R/W                    |
| EFUSE_WR_TIM_CONF1_REG       | Configuration register 1 of eFuse programming 0x01F0 | Configuration register 1 of eFuse programming 0x01F0 | R/W                    |

![Image](images/06_Chapter_6_img004_f038d899.png)

| Name                     | Description                                                       | Address   | Access   |
|--------------------------|-------------------------------------------------------------------|-----------|----------|
| EFUSE_WR_TIM_CONF2_REG   | Configuration register 2 of eFuse program ming timing parameters | 0x01F4    | R/W      |
| EFUSE_WR_TIM_CONF0_REG   | Configuration register 0 of eFuse program ming timing parameters | 0x01F8    | varies   |
| Status Register          |                                                                   |           |          |
| EFUSE_STATUS_REG         | eFuse status register                                             | 0x01D0    | RO       |
| Interrupt Register       |                                                                   |           |          |
| EFUSE_INT_RAW_REG        | eFuse raw interrupt register                                      | 0x01D8    | R/SS/WTC |
| EFUSE_INT_ST_REG         | eFuse interrupt status register                                   | 0x01DC    | RO       |
| EFUSE_INT_ENA_REG        | eFuse interrupt enable register                                   | 0x01E0    | R/W      |
| EFUSE_INT_CLR_REG        | eFuse interrupt clear register                                    | 0x01E4    | WO       |
| Version Control Register |                                                                   |           |          |
| EFUSE_DATE_REG           | Version control register                                          | 0x01FC    | R/W      |

![Image](images/06_Chapter_6_img005_e2a5f33d.png)

## 6.5 Registers

The addresses in this section are relative to eFuse controller base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 6.1. EFUSE\_PGM\_DATA0\_REG (0x0000)

EFUSE\_PGM\_DATA\_2 Configures the 2nd 32-bit data to be programmed. (R/W)

![Image](images/06_Chapter_6_img006_825c7a6a.png)

![Image](images/06_Chapter_6_img007_8b7e9a20.png)

Register 6.8. EFUSE\_PGM\_DATA7\_REG (0x001C)

![Image](images/06_Chapter_6_img008_157d6089.png)

EFUSE\_PGM\_RS\_DATA\_1 Configures the 1st 32-bit RS code to be programmed. (R/W)

## Register 6.11. EFUSE\_PGM\_CHECK\_VALUE2\_REG (0x0028)

![Image](images/06_Chapter_6_img009_8357084d.png)

![Image](images/06_Chapter_6_img010_2f8d6080.png)

EFUSE\_PGM\_RS\_DATA\_2 Configures the 2nd 32-bit RS code to be programmed. (R/W)

## Register 6.12. EFUSE\_RD\_WR\_DIS\_REG (0x002C)

![Image](images/06_Chapter_6_img011_1ea5b75c.png)

![Image](images/06_Chapter_6_img012_70dc07a5.png)

EFUSE\_WR\_DIS Represents whether programming of individual eFuse memory bit is disabled.

1: Disabled

0: Enabled

(RO)

Register 6.13. EFUSE\_RD\_REPEAT\_DATA0\_REG (0x0030)

![Image](images/06_Chapter_6_img013_ea813b63.png)

EFUSE\_RD\_DIS Represents whether reading of individual eFuse block (BLOCK4 ~ BLOCK10) is dis- abled.

1: Disabled

0: Enabled

(RO)

EFUSE\_SWAP\_UART\_SDIO\_EN Represents whether the pads of UART and SDIO are swapped or not.

- 1: Swapped

0: Not swapped

(RO)

EFUSE\_DIS\_ICACHE Represents whether icache is disabled.

- 1: Disabled
- 0: Enabled

(RO)

EFUSE\_DIS\_USB\_JTAG Represents whether the USB-to-JTAG function is disabled.

- 1: Disabled

0: Enabled

(RO)

EFUSE\_DIS\_DOWNLOAD\_ICACHE Represents whether iCache is disabled in Download mode.

- 1: Disabled

0: Enabled

(RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG Represents whether USB-Serial-JTAG is disabled.

- 1: Disabled
- 0: Enabled

(RO)

EFUSE\_DIS\_FORCE\_DOWNLOAD Represents whether the function that forces chip into download mode is disabled.

1: Disabled

0: Enabled

(RO)

## Register 6.13. EFUSE\_RD\_REPEAT\_DATA0\_REG (0x0030)

## Continued from the previous page...

EFUSE\_SPI\_DOWNLOAD\_MSPI\_DIS Represents whether SPI0 controller is disabled during

boot\_mode\_download.

1: Disabled

0: Enabled

(RO)

EFUSE\_DIS\_TWAI Represents whether TWAI function is disabled.

1: Disabled

0: Enabled

(RO)

EFUSE\_JTAG\_SEL\_ENABLE Represents whether the selection of a JTAG signal source through the strapping value of GPIO15 is enabled when both EFUSE\_DIS\_PAD\_JTAG and EFUSE\_DIS\_USB\_JTAG are configured to 0.

1: Enabled

0: Disabled

(RO)

EFUSE\_SOFT\_DIS\_JTAG Represents whether JTAG is disabled in the soft way. It can be restarted via HMAC.

Odd count of bits with a value of 1: Disabled

Even count of bits with a value of 1: Enabled

(RO)

EFUSE\_DIS\_PAD\_JTAG Represents whether JTAG is disabled in the hard way (permanently).

- 1: Disabled

0: Enabled

(RO)

EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT Represents whether flash encryption is disabled (except in SPI boot mode).

1: Disabled

0: Enabled

(RO)

EFUSE\_USB\_EXCHG\_PINS Represents whether the D+ and D- pins are exchanged.

- 1: Exchanged
- 0: Not exchanged

(RO)

EFUSE\_VDD\_SPI\_AS\_GPIO Represents whether the VDD\_SPI pin is used as a regular GPIO.

- 1: Used as a regular GPIO
- 0: Not used as a regular GPIO

(RO)

Continued on the next page...

## Register 6.13. EFUSE\_RD\_REPEAT\_DATA0\_REG (0x0030)

Continued from the previous page... EFUSE\_RPT4\_RESERVED0\_2 Reserved. (RO) EFUSE\_RPT4\_RESERVED0\_1 Reserved. (RO)

EFUSE\_RPT4\_RESERVED0\_0 Reserved. (RO)

Submit Documentation Feedback

Register 6.14. EFUSE\_RD\_REPEAT\_DATA1\_REG (0x0034)

![Image](images/06_Chapter_6_img014_9af62991.png)

EFUSE\_RPT4\_RESERVED1\_0 Reserved. (RO)

EFUSE\_WDT\_DELAY\_SEL Represents whether RTC watchdog timeout threshold is selected at startup.

1: Selected.

0: Not selected

(RO)

EFUSE\_SPI\_BOOT\_CRYPT\_CNT Represents whether SPI boot encryption/decryption is enabled.

Odd count of bits with a value of 1: Enabled

Even count of bits with a value of 1: Disabled

(RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE0 Represents whether revoking the first Secure Boot key is enabled.

1: Enabled

0: Disabled

(RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE1 Represents whether revoking the second Secure Boot key

is enabled.

1: Enabled

0: Disabled

(RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE2 Represents whether revoking the third Secure Boot key is enabled.

1: Enabled

0: Disabled

(RO)

EFUSE\_KEY\_PURPOSE\_0 Represents the purpose of Key0. (RO)

EFUSE\_KEY\_PURPOSE\_1 Represents the purpose of Key1. (RO)

Register 6.15. EFUSE\_RD\_REPEAT\_DATA2\_REG (0x0038)

![Image](images/06_Chapter_6_img015_70fafc3e.png)

EFUSE\_KEY\_PURPOSE\_2 Represents the purpose of Key2. (RO)

EFUSE\_KEY\_PURPOSE\_3 Represents the purpose of Key3. (RO)

EFUSE\_KEY\_PURPOSE\_4 Represents the purpose of Key4. (RO)

EFUSE\_KEY\_PURPOSE\_5 Represents the purpose of Key5. (RO)

EFUSE\_SEC\_DPA\_LEVEL Represents the security level of anti-DPA attack.

0: Security level is SEC\_DPA\_OFF

1: Security level is SEC\_DPA\_LOW

2: Security level is SEC\_DPA\_MIDDLE

3: Security level is SEC\_DPA\_HIGH

For more information, please refer to Chapter 17 System Registers &gt; Section 17.3.2 .

(RO)

EFUSE\_CRYPT\_DPA\_ENABLE Represents whether defense against DPA attack is enabled.

1: Enabled

0: Disabled

(RO)

EFUSE\_RPT4\_RESERVED2\_1 Reserved. (RO)

EFUSE\_SECURE\_BOOT\_EN Represents whether Secure Boot is enabled.

1: Enabled

0: Disabled

(RO)

EFUSE\_SECURE\_BOOT\_AGGRESSIVE\_REVOKE Represents whether aggressive revocation of Se- cure Boot is enabled.

1: Enabled

0: Disabled

(RO)

EFUSE\_RPT4\_RESERVED2\_0 Reserved. (RO)

EFUSE\_FLASH\_TPUW Represents the flash waiting time after power-up. Measurement unit: ms.

When the value is less than 15, the waiting time is the programmed value. Otherwise, the waiting time is a fixed value, i.e. 30 ms. (RO)

Register 6.16. EFUSE\_RD\_REPEAT\_DATA3\_REG (0x003C)

![Image](images/06_Chapter_6_img016_46a289a7.png)

EFUSE\_DIS\_DOWNLOAD\_MODE Represents whether all download modes are disabled.

- 1: Disabled
- 0: Enabled

(RO)

EFUSE\_DIS\_DIRECT\_BOOT Represents whether direct boot mode is disabled.

- 1: Disabled
- 0: Enabled

(RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_ROM\_PRINT Represents whether print from USB-Serial-JTAG dur- ing ROM boot is disabled.

- 1: Disabled
- 0: Enabled

(RO)

EFUSE\_RPT4\_RESERVED3\_5 Reserved. (RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_DOWNLOAD\_MODE Represents whether the USB-Serial-JTAG download function is disabled.

- 1: Disabled
- 0: Enabled

(RO)

- EFUSE\_ENABLE\_SECURITY\_DOWNLOAD Represents whether security download is enabled. Only UART is supported for download. Reading/writing RAM or registers is not supported (i.e. Stub download is not supported).
- 1: Enabled
- 0: Disabled

(RO)

Continued on the next page...

Register 6.16. EFUSE\_RD\_REPEAT\_DATA3\_REG (0x003C)

## Continued from the previous page...

EFUSE\_UART\_PRINT\_CONTROL Represents the type of UART printing.

0: Force enable printing.

1: Enable printing when GPIO8 is reset at low level.

2: Enable printing when GPIO8 is reset at high level.

3: Force disable printing. (RO)

EFUSE\_RPT4\_RESERVED3\_4 Reserved. (RO)

EFUSE\_RPT4\_RESERVED3\_3 Reserved. (RO)

EFUSE\_RPT4\_RESERVED3\_2 Reserved. (RO)

EFUSE\_RPT4\_RESERVED3\_1 Reserved. (RO)

EFUSE\_FORCE\_SEND\_RESUME Represents whether ROM code is forced to send a resume command during SPI boot.

1: Forced.

0: Not forced.

(RO)

EFUSE\_SECURE\_VERSION Represents the security version used by ESP-IDF anti-rollback feature. (RO)

EFUSE\_SECURE\_BOOT\_DISABLE\_FAST\_WAKE Represents whether FAST VERIFY ON WAKE is dis- abled when Secure Boot is enabled.

1: Disabled

0: Enabled

(RO)

EFUSE\_RPT4\_RESERVED3\_0 Reserved. (RO)

## Register 6.17. EFUSE\_RD\_REPEAT\_DATA4\_REG (0x0040)

![Image](images/06_Chapter_6_img017_e763e9f1.png)

EFUSE\_RPT4\_RESERVED4\_1 Reserved. (RO)

EFUSE\_RPT4\_RESERVED4\_0 Reserved. (RO)

Register 6.18. EFUSE\_RD\_MAC\_SPI\_SYS\_0\_REG (0x0044)

![Image](images/06_Chapter_6_img018_c413c81d.png)

EFUSE\_MAC\_0 Represents the low 32 bits of MAC address. (RO)

## Register 6.19. EFUSE\_RD\_MAC\_SPI\_SYS\_1\_REG (0x0048)

![Image](images/06_Chapter_6_img019_73c30e17.png)

EFUSE\_MAC\_1 Represents the high 16 bits of MAC address. (RO)

EFUSE\_MAC\_EXT Represents the extended bits of MAC address. (RO)

Register 6.20. EFUSE\_RD\_MAC\_SPI\_SYS\_2\_REG (0x004C)

![Image](images/06_Chapter_6_img020_947516a6.png)

EFUSE\_MAC\_SPI\_RESERVED Reserved. (RO)

EFUSE\_SPI\_PAD\_CONF\_1 Represents the first part of SPI\_PAD\_CONF. (RO)

Register 6.21. EFUSE\_RD\_MAC\_SPI\_SYS\_3\_REG (0x0050)

![Image](images/06_Chapter_6_img021_2674dcc5.png)

EFUSE\_SPI\_PAD\_CONF\_2 Represents the second part of SPI\_PAD\_CONF. (RO)

EFUSE\_SYS\_DATA\_PART0\_0 Represents the first 14 bits of the zeroth part of system data. (RO)

Register 6.22. EFUSE\_RD\_MAC\_SPI\_SYS\_4\_REG (0x0054)

![Image](images/06_Chapter_6_img022_2aad1f36.png)

EFUSE\_SYS\_DATA\_PART0\_1 Represents the first 32 bits of the zeroth part of system data. (RO)

Register 6.23. EFUSE\_RD\_MAC\_SPI\_SYS\_5\_REG (0x0058)

![Image](images/06_Chapter_6_img023_4ed8df20.png)

EFUSE\_SYS\_DATA\_PART0\_2 Represents the second 32 bits of the zeroth part of system data. (RO)

Register 6.24. EFUSE\_RD\_SYS\_PART1\_DATA0\_REG (0x005C)

EFUSE\_SYS\_DATA\_PART1\_2 Represents the second 32 bits of the first part of system data. (RO)

![Image](images/06_Chapter_6_img024_1ab5f993.png)

Register 6.27. EFUSE\_RD\_SYS\_PART1\_DATA3\_REG (0x0068)

![Image](images/06_Chapter_6_img025_d6aabca0.png)

![Image](images/06_Chapter_6_img026_89261446.png)

EFUSE\_USR\_DATA0 Represents the zeroth 32 bits of BLOCK3 (user). (RO)

![Image](images/06_Chapter_6_img027_b16d4d26.png)

![Image](images/06_Chapter_6_img028_81949e5e.png)

Register 6.41. EFUSE\_RD\_KEY0\_DATA1\_REG (0x00A0)

![Image](images/06_Chapter_6_img029_f0447ac8.png)

EFUSE\_KEY0\_DATA1 Represents the first 32 bits of KEY0. (RO)

Register 6.42. EFUSE\_RD\_KEY0\_DATA2\_REG (0x00A4)

![Image](images/06_Chapter_6_img030_f9a8d094.png)

EFUSE\_KEY0\_DATA2 Represents the second 32 bits of KEY0. (RO)

Register 6.43. EFUSE\_RD\_KEY0\_DATA3\_REG (0x00A8)

EFUSE\_KEY0\_DATA3

![Image](images/06_Chapter_6_img031_6fb1a189.png)

EFUSE\_KEY0\_DATA3 Represents the third 32 bits of KEY0. (RO)

Register 6.44. EFUSE\_RD\_KEY0\_DATA4\_REG (0x00AC)

![Image](images/06_Chapter_6_img032_8b025915.png)

EFUSE\_KEY0\_DATA4 Represents the fourth 32 bits of KEY0. (RO)

Register 6.45. EFUSE\_RD\_KEY0\_DATA5\_REG (0x00B0)

EFUSE\_KEY0\_DATA5

![Image](images/06_Chapter_6_img033_f42bf901.png)

EFUSE\_KEY0\_DATA5 Represents the fifth 32 bits of KEY0. (RO)

Register 6.46. EFUSE\_RD\_KEY0\_DATA6\_REG (0x00B4)

EFUSE\_KEY0\_DATA6

![Image](images/06_Chapter_6_img034_1201c3cb.png)

EFUSE\_KEY0\_DATA6 Represents the sixth 32 bits of KEY0. (RO)

Register 6.47. EFUSE\_RD\_KEY0\_DATA7\_REG (0x00B8)

EFUSE\_KEY0\_DATA7

![Image](images/06_Chapter_6_img035_048028cb.png)

EFUSE\_KEY0\_DATA7 Represents the seventh 32 bits of KEY0. (RO)

Register 6.48. EFUSE\_RD\_KEY1\_DATA0\_REG (0x00BC)

![Image](images/06_Chapter_6_img036_408691d9.png)

EFUSE\_KEY1\_DATA0 Represents the zeroth 32 bits of KEY1. (RO)

Register 6.49. EFUSE\_RD\_KEY1\_DATA1\_REG (0x00C0)

![Image](images/06_Chapter_6_img037_da08bfae.png)

EFUSE\_KEY1\_DATA1 Represents the first 32 bits of KEY1. (RO)

Register 6.50. EFUSE\_RD\_KEY1\_DATA2\_REG (0x00C4)

EFUSE\_KEY1\_DATA2

![Image](images/06_Chapter_6_img038_94dbf5a0.png)

EFUSE\_KEY1\_DATA2 Represents the second 32 bits of KEY1. (RO)

Register 6.51. EFUSE\_RD\_KEY1\_DATA3\_REG (0x00C8)

EFUSE\_KEY1\_DATA3

![Image](images/06_Chapter_6_img039_1031df40.png)

EFUSE\_KEY1\_DATA3 Represents the third 32 bits of KEY1. (RO)

Register 6.52. EFUSE\_RD\_KEY1\_DATA4\_REG (0x00CC)

![Image](images/06_Chapter_6_img040_eac535f2.png)

EFUSE\_KEY1\_DATA4 Represents the fourth 32 bits of KEY1. (RO)

Register 6.53. EFUSE\_RD\_KEY1\_DATA5\_REG (0x00D0)

![Image](images/06_Chapter_6_img041_a92cd8c8.png)

EFUSE\_KEY1\_DATA5 Represents the fifth 32 bits of KEY1. (RO)

Register 6.54. EFUSE\_RD\_KEY1\_DATA6\_REG (0x00D4)

![Image](images/06_Chapter_6_img042_491ee202.png)

EFUSE\_KEY1\_DATA6 Represents the sixth 32 bits of KEY1. (RO)

Register 6.55. EFUSE\_RD\_KEY1\_DATA7\_REG (0x00D8)

![Image](images/06_Chapter_6_img043_df30a519.png)

EFUSE\_KEY1\_DATA7 Represents the seventh 32 bits of KEY1. (RO)

Register 6.56. EFUSE\_RD\_KEY2\_DATA0\_REG (0x00DC)

![Image](images/06_Chapter_6_img044_520d79a0.png)

EFUSE\_KEY2\_DATA0 Represents the zeroth 32 bits of KEY2. (RO)

Register 6.57. EFUSE\_RD\_KEY2\_DATA1\_REG (0x00E0)

![Image](images/06_Chapter_6_img045_56958aa2.png)

EFUSE\_KEY2\_DATA1 Represents the first 32 bits of KEY2. (RO)

Register 6.58. EFUSE\_RD\_KEY2\_DATA2\_REG (0x00E4)

![Image](images/06_Chapter_6_img046_3b8b9274.png)

EFUSE\_KEY2\_DATA2 Represents the second 32 bits of KEY2. (RO)

Register 6.59. EFUSE\_RD\_KEY2\_DATA3\_REG (0x00E8)

EFUSE\_KEY2\_DATA3

![Image](images/06_Chapter_6_img047_78e29ce0.png)

EFUSE\_KEY2\_DATA3 Represents the third 32 bits of KEY2. (RO)

Register 6.60. EFUSE\_RD\_KEY2\_DATA4\_REG (0x00EC)

![Image](images/06_Chapter_6_img048_8320ae6c.png)

EFUSE\_KEY2\_DATA4 Represents the fourth 32 bits of KEY2. (RO)

Register 6.61. EFUSE\_RD\_KEY2\_DATA5\_REG (0x00F0)

EFUSE\_KEY2\_DATA5

![Image](images/06_Chapter_6_img049_c1f9930c.png)

EFUSE\_KEY2\_DATA5 Represents the fifth 32 bits of KEY2. (RO)

Register 6.62. EFUSE\_RD\_KEY2\_DATA6\_REG (0x00F4)

EFUSE\_KEY2\_DATA6

![Image](images/06_Chapter_6_img050_64c469be.png)

EFUSE\_KEY2\_DATA6 Represents the sixth 32 bits of KEY2. (RO)

Register 6.63. EFUSE\_RD\_KEY2\_DATA7\_REG (0x00F8)

EFUSE\_KEY2\_DATA7

![Image](images/06_Chapter_6_img051_e86bf78e.png)

EFUSE\_KEY2\_DATA7 Represents the seventh 32 bits of KEY2. (RO)

Register 6.64. EFUSE\_RD\_KEY3\_DATA0\_REG (0x00FC)

![Image](images/06_Chapter_6_img052_5aeb1132.png)

EFUSE\_KEY3\_DATA0 Represents the zeroth 32 bits of KEY3. (RO)

Register 6.65. EFUSE\_RD\_KEY3\_DATA1\_REG (0x0100)

![Image](images/06_Chapter_6_img053_348f960d.png)

EFUSE\_KEY3\_DATA1 Represents the first 32 bits of KEY3. (RO)

Register 6.66. EFUSE\_RD\_KEY3\_DATA2\_REG (0x0104)

![Image](images/06_Chapter_6_img054_79d9a97e.png)

EFUSE\_KEY3\_DATA2 Represents the second 32 bits of KEY3. (RO)

## Register 6.67. EFUSE\_RD\_KEY3\_DATA3\_REG (0x0108)

EFUSE\_KEY3\_DATA3

![Image](images/06_Chapter_6_img055_041c8e88.png)

EFUSE\_KEY3\_DATA3 Represents the third 32 bits of KEY3. (RO)

Register 6.68. EFUSE\_RD\_KEY3\_DATA4\_REG (0x010C)

![Image](images/06_Chapter_6_img056_3ec25b80.png)

EFUSE\_KEY3\_DATA4 Represents the fourth 32 bits of KEY3. (RO)

Register 6.69. EFUSE\_RD\_KEY3\_DATA5\_REG (0x0110)

![Image](images/06_Chapter_6_img057_cac0f837.png)

EFUSE\_KEY3\_DATA5 Represents the fifth 32 bits of KEY3. (RO)

Register 6.70. EFUSE\_RD\_KEY3\_DATA6\_REG (0x0114)

EFUSE\_KEY3\_DATA6

![Image](images/06_Chapter_6_img058_54ca092c.png)

EFUSE\_KEY3\_DATA6 Represents the sixth 32 bits of KEY3. (RO)

Register 6.71. EFUSE\_RD\_KEY3\_DATA7\_REG (0x0118)

EFUSE\_KEY3\_DATA7

![Image](images/06_Chapter_6_img059_cbe9cbf3.png)

EFUSE\_KEY3\_DATA7 Represents the seventh 32 bits of KEY3. (RO)

Register 6.72. EFUSE\_RD\_KEY4\_DATA0\_REG (0x011C)

![Image](images/06_Chapter_6_img060_6a7c6a45.png)

EFUSE\_KEY4\_DATA0 Represents the zeroth 32 bits of KEY4. (RO)

Register 6.73. EFUSE\_RD\_KEY4\_DATA1\_REG (0x0120)

![Image](images/06_Chapter_6_img061_c7904824.png)

EFUSE\_KEY4\_DATA1 Represents the first 32 bits of KEY4. (RO)

Register 6.74. EFUSE\_RD\_KEY4\_DATA2\_REG (0x0124)

EFUSE\_KEY4\_DATA2

![Image](images/06_Chapter_6_img062_03770983.png)

EFUSE\_KEY4\_DATA2 Represents the second 32 bits of KEY4. (RO)

## Register 6.75. EFUSE\_RD\_KEY4\_DATA3\_REG (0x0128)

EFUSE\_KEY4\_DATA3

![Image](images/06_Chapter_6_img063_3e47009d.png)

EFUSE\_KEY4\_DATA3 Represents the third 32 bits of KEY4. (RO)

## Register 6.76. EFUSE\_RD\_KEY4\_DATA4\_REG (0x012C)

![Image](images/06_Chapter_6_img064_f750bbce.png)

EFUSE\_KEY4\_DATA4 Represents the fourth 32 bits of KEY4. (RO)

Register 6.77. EFUSE\_RD\_KEY4\_DATA5\_REG (0x0130)

![Image](images/06_Chapter_6_img065_f3ff2fc2.png)

EFUSE\_KEY4\_DATA5 Represents the fifth 32 bits of KEY4. (RO)

Register 6.78. EFUSE\_RD\_KEY4\_DATA6\_REG (0x0134)

![Image](images/06_Chapter_6_img066_bde47d3e.png)

EFUSE\_KEY4\_DATA6 Represents the sixth 32 bits of KEY4. (RO)

## Register 6.79. EFUSE\_RD\_KEY4\_DATA7\_REG (0x0138)

![Image](images/06_Chapter_6_img067_b7a41379.png)

EFUSE\_KEY4\_DATA7 Represents the seventh 32 bits of KEY4. (RO)

Register 6.80. EFUSE\_RD\_KEY5\_DATA0\_REG (0x013C)

![Image](images/06_Chapter_6_img068_d83dba75.png)

EFUSE\_KEY5\_DATA0 Represents the zeroth 32 bits of KEY5. (RO)

Register 6.81. EFUSE\_RD\_KEY5\_DATA1\_REG (0x0140)

![Image](images/06_Chapter_6_img069_1e1b1f3b.png)

EFUSE\_KEY5\_DATA1 Represents the first 32 bits of KEY5. (RO)

Register 6.82. EFUSE\_RD\_KEY5\_DATA2\_REG (0x0144)

![Image](images/06_Chapter_6_img070_b68821c8.png)

EFUSE\_KEY5\_DATA2 Represents the second 32 bits of KEY5. (RO)

Register 6.83. EFUSE\_RD\_KEY5\_DATA3\_REG (0x0148)

EFUSE\_KEY5\_DATA3

![Image](images/06_Chapter_6_img071_e9a22bd0.png)

EFUSE\_KEY5\_DATA3 Represents the third 32 bits of KEY5. (RO)

Register 6.84. EFUSE\_RD\_KEY5\_DATA4\_REG (0x014C)

![Image](images/06_Chapter_6_img072_42b18514.png)

EFUSE\_KEY5\_DATA4 Represents the fourth 32 bits of KEY5. (RO)

Register 6.85. EFUSE\_RD\_KEY5\_DATA5\_REG (0x0150)

![Image](images/06_Chapter_6_img073_c476bd21.png)

EFUSE\_KEY5\_DATA5 Represents the fifth 32 bits of KEY5. (RO)

Register 6.86. EFUSE\_RD\_KEY5\_DATA6\_REG (0x0154)

![Image](images/06_Chapter_6_img074_73a5fb11.png)

EFUSE\_KEY5\_DATA6 Represents the sixth 32 bits of KEY5. (RO)

## Register 6.87. EFUSE\_RD\_KEY5\_DATA7\_REG (0x0158)

EFUSE\_KEY5\_DATA7

![Image](images/06_Chapter_6_img075_7975991b.png)

EFUSE\_KEY5\_DATA7 Represents the seventh 32 bits of KEY5. (RO)

Register 6.88. EFUSE\_RD\_SYS\_PART2\_DATA0\_REG (0x015C)

![Image](images/06_Chapter_6_img076_7af84bcf.png)

EFUSE\_SYS\_DATA\_PART2\_0 Represents the 0th 32 bits of the 2nd part of system data. (RO)

Register 6.89. EFUSE\_RD\_SYS\_PART2\_DATA1\_REG (0x0160)

![Image](images/06_Chapter_6_img077_16f7167a.png)

EFUSE\_SYS\_DATA\_PART2\_1 Represents the 1st 32 bits of the 2nd part of system data. (RO)

![Image](images/06_Chapter_6_img078_265dc090.png)

EFUSE\_SYS\_DATA\_PART2\_2 Represents the 2nd 32 bits of the 2nd part of system data. (RO)

Register 6.91. EFUSE\_RD\_SYS\_PART2\_DATA3\_REG (0x0168)

![Image](images/06_Chapter_6_img079_becd38db.png)

EFUSE\_SYS\_DATA\_PART2\_3 Represents the 3rd 32 bits of the 2nd part of system data. (RO)

Register 6.92. EFUSE\_RD\_SYS\_PART2\_DATA4\_REG (0x016C)

EFUSE\_SYS\_DATA\_PART2\_6 Represents the 6th 32 bits of the 2nd part of system data. (RO)

![Image](images/06_Chapter_6_img080_37d58029.png)

Register 6.95. EFUSE\_RD\_SYS\_PART2\_DATA7\_REG (0x0178)

![Image](images/06_Chapter_6_img081_b9779d1f.png)

EFUSE\_SYS\_DATA\_PART2\_7 Represents the 7th 32 bits of the 2nd part of system data. (RO)

Register 6.96. EFUSE\_RD\_REPEAT\_ERR0\_REG (0x017C)

![Image](images/06_Chapter_6_img082_29caf10c.png)

EFUSE\_RD\_DIS\_ERR Any bit of this field being 1 represents a programming error of RD\_DIS. (RO)

EFUSE\_SWAP\_UART\_SDIO\_EN\_ERR This bit being 1 represents a programming error of SWAP\_UART\_SDIO\_EN. (RO)

EFUSE\_DIS\_ICACHE\_ERR This bit being 1 represents a programming error of DIS\_ICACHE. (RO)

EFUSE\_DIS\_USB\_JTAG\_ERR This bit being 1 represents a programming error of DIS\_USB\_JTAG. (RO)

EFUSE\_DIS\_DOWNLOAD\_ICACHE\_ERR This bit being 1 represents a programming error of DIS\_DOWNLOAD\_ICACHE. (RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_ERR This bit being 1 represents a programming error of DIS\_USB\_DEVICE. (RO)

EFUSE\_DIS\_FORCE\_DOWNLOAD\_ERR This bit being 1 represents a programming error of DIS\_FORCE\_DOWNLOAD. (RO)

EFUSE\_SPI\_DOWNLOAD\_MSPI\_DIS\_ERR This bit being 1 represents a programming error of SPI\_DOWNLOAD\_MSPI\_DIS. (RO)

EFUSE\_DIS\_TWAI\_ERR This bit being 1 represents a programming error of DIS\_TWAI. (RO)

EFUSE\_JTAG\_SEL\_ENABLE\_ERR This bit being 1 represents a programming error of JTAG\_SEL\_ENABLE. (RO)

EFUSE\_SOFT\_DIS\_JTAG\_ERR Any bit of this field being 1 represents a programming error of SOFT\_DIS\_JTAG. (RO)

EFUSE\_DIS\_PAD\_JTAG\_ERR This bit being 1 represents a programming error of DIS\_PAD\_JTAG. (RO)

EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT\_ERR This bit being 1 represents a programming error of DIS\_DOWNLOAD\_MANUAL\_ENCRYPT. (RO)

Continued on the next page...

## Register 6.96. EFUSE\_RD\_REPEAT\_ERR0\_REG (0x0080)

## Continued from the previous page...

EFUSE\_USB\_EXCHG\_PINS\_ERR This bit being 1 represents a programming error of USB\_EXCHG\_PINS. (RO)

EFUSE\_VDD\_SPI\_AS\_GPIO\_ERR This bit being 1 represents a programming error of VDD\_SPI\_AS\_GPIO. (RO)

EFUSE\_RPT4\_RESERVED0\_ERR\_2 Reserved. (RO)

EFUSE\_RPT4\_RESERVED0\_ERR\_1 Reserved. (RO)

EFUSE\_RPT4\_RESERVED0\_ERR\_0 Reserved. (RO)

Register 6.97. EFUSE\_RD\_REPEAT\_ERR1\_REG (0x0180)

![Image](images/06_Chapter_6_img083_3451bdfc.png)

EFUSE\_RPT4\_RESERVED1\_ERR\_0 Reserved. (RO)

EFUSE\_WDT\_DELAY\_SEL\_ERR Any bit of this field being 1 represents a programming error of WDT\_DELAY\_SEL. (RO)

EFUSE\_SPI\_BOOT\_CRYPT\_CNT\_ERR Any bit of this field being 1 represents a programming error of SPI\_BOOT\_CRYPT\_CNT. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE0\_ERR This bit being 1 represents a programming error of SE-CURE\_BOOT\_KEY\_REVOKE0. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE1\_ERR This bit being 1 represents a programming error of SE-CURE\_BOOT\_KEY\_REVOKE1. (RO)

EFUSE\_SECURE\_BOOT\_KEY\_REVOKE2\_ERR This bit being 1 represents a programming error of SE-CURE\_BOOT\_KEY\_REVOKE2. (RO)

EFUSE\_KEY\_PURPOSE\_0\_ERR Any bit of this field being 1 represents a programming error of KEY\_PURPOSE\_0. (RO)

EFUSE\_KEY\_PURPOSE\_1\_ERR Any bit of this field being 1 represents a programming error of KEY\_PURPOSE\_1. (RO)

Register 6.98. EFUSE\_RD\_REPEAT\_ERR2\_REG (0x0184)

![Image](images/06_Chapter_6_img084_a5eab41c.png)

- EFUSE\_KEY\_PURPOSE\_2\_ERR Any bit of this field being 1 represents a programming error of KEY\_PURPOSE\_2. (RO)

EFUSE\_KEY\_PURPOSE\_3\_ERR Any bit of this field being 1 represents a programming error of KEY\_PURPOSE\_3. (RO)

EFUSE\_KEY\_PURPOSE\_4\_ERR Any bit of this field being 1 represents a programming error of KEY\_PURPOSE\_4. (RO)

EFUSE\_KEY\_PURPOSE\_5\_ERR Any bit of this field being 1 represents a programming error of KEY\_PURPOSE\_5. (RO)

EFUSE\_SEC\_DPA\_LEVEL\_ERR This bit being 1 represents a programming error of SEC\_DPA\_LEVEL. (RO)

EFUSE\_RPT4\_RESERVED2\_ERR\_1 Reserved. (RO)

EFUSE\_CRYPT\_DPA\_ENABLE\_ERR This bit being 1 represents a programming error of CRYPT\_DPA\_ENABLE. (RO)

EFUSE\_SECURE\_BOOT\_EN\_ERR This bit being 1 represents a programming error of SE-CURE\_BOOT\_EN. (RO)

EFUSE\_SECURE\_BOOT\_AGGRESSIVE\_REVOKE\_ERR This bit being 1 represents a programming error of SECURE\_BOOT\_AGGRESSIVE\_REVOKE. (RO)

EFUSE\_RPT4\_RESERVED2\_ERR\_0 Reserved. (RO)

EFUSE\_FLASH\_TPUW\_ERR Any bit of this field being 1 represents a programming error of FLASH\_TPUW. (RO)

Register 6.99. EFUSE\_RD\_REPEAT\_ERR3\_REG (0x0188)

![Image](images/06_Chapter_6_img085_01219a11.png)

EFUSE\_DIS\_DOWNLOAD\_MODE\_ERR This bit being 1 represents a programming error of DIS\_DOWNLOAD\_MODE. (RO)

EFUSE\_DIS\_DIRECT\_BOOT\_ERR This bit being 1 represents a programming error of DIS\_DIRECT\_BOOT. (RO)

EFUSE\_USB\_PRINT\_ERR This bit being 1 represents a programming error of UART\_PRINT\_CHANNEL. (RO)

EFUSE\_RPT4\_RESERVED3\_ERR\_5 Reserved. (RO)

EFUSE\_DIS\_USB\_SERIAL\_JTAG\_DOWNLOAD\_MODE\_ERR This bit being 1 represents a programming error of DIS\_USB\_SERIAL\_JTAG\_DOWNLOAD\_MODE. (RO)

EFUSE\_ENABLE\_SECURITY\_DOWNLOAD\_ERR This bit being 1 represents a programming error of ENABLE\_SECURITY\_DOWNLOAD. (RO)

EFUSE\_UART\_PRINT\_CONTROL\_ERR Any bit of this field being 1 represents a programming error of UART\_PRINT\_CONTROL. (RO)

EFUSE\_RPT4\_RESERVED3\_ERR\_4 Reserved. (RO)

EFUSE\_RPT4\_RESERVED3\_ERR\_3 Reserved. (RO)

EFUSE\_RPT4\_RESERVED3\_ERR\_2 Reserved. (RO)

EFUSE\_RPT4\_RESERVED3\_ERR\_1 Reserved. (RO)

EFUSE\_FORCE\_SEND\_RESUME\_ERR This bit being 1 represents a programming error of FORCE\_SEND\_RESUME. (RO)

EFUSE\_SECURE\_VERSION\_ERR Any bit of this field being 1 represents a programming error of SE-CURE\_VERSION. (RO)

EFUSE\_RPT4\_RESERVED3\_ERR\_0 Reserved. (RO)

Register 6.100. EFUSE\_RD\_REPEAT\_ERR4\_REG (0x0190)

![Image](images/06_Chapter_6_img086_35490f67.png)

EFUSE\_RPT4\_RESERVED4\_ERR\_1 Reserved. (RO)

EFUSE\_RPT4\_RESERVED4\_ERR\_0 Reserved. (RO)

Submit Documentation Feedback

## Register 6.101. EFUSE\_RD\_RS\_ERR0\_REG (0x01C0)

![Image](images/06_Chapter_6_img087_6f35c414.png)

EFUSE\_MAC\_SPI\_8M\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_MAC\_SPI\_8M\_FAIL Represents whether programming MAC\_SPI\_8M failed.

- 0: No failure and the data of MAC\_SPI\_8M is reliable.
- 1: Programming user data failed and the number of error bytes is over 6. (RO)

EFUSE\_SYS\_PART1\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_SYS\_PART1\_FAIL Represents whether programming system part1 data failed.

- 0: No failure and the data of system part1 is reliable.
- 1: Programming user data failed and the number of error bytes is over 6. (RO)

EFUSE\_USR\_DATA\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_USR\_DATA\_FAIL Represents whether programming user data failed.

- 0: No failure and the user data is reliable.
- 1: Programming user data failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY0\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_KEY0\_FAIL Represents whether programming key0 data failed.

- 0: No failure and the data of key0 is reliable.
- 1: Programming key0 failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY1\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_KEY1\_FAIL Represents whether programming key1 data failed.

- 0: No failure and the data of key1 is reliable.
- 1: Programming key1 failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY2\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_KEY2\_FAIL Represents whether programming key2 data failed.

- 0: No failure and the data of key2 is reliable.
- 1: Programming key2 failed and the number of error bytes is over 6. (RO)

Continued on the next page...

## Register 6.101. EFUSE\_RD\_RS\_ERR0\_REG (0x01C0)

## Continued from the previous page...

EFUSE\_KEY3\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_KEY3\_FAIL Represents whether programming key3 data failed.

- 0: No failure and the data of key3 is reliable.
- 1: Programming key3 failed and the number of error bytes is over 6. (RO)

EFUSE\_KEY4\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_KEY4\_FAIL Represents whether programming key4 data failed.

- 0: No failure and the data of key4 is reliable.
- 1: Programming key4 failed and the number of error bytes is over 6. (RO)

## Register 6.102. EFUSE\_RD\_RS\_ERR1\_REG (0x01C4)

![Image](images/06_Chapter_6_img088_07fa6c4d.png)

EFUSE\_KEY5\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_KEY5\_FAIL Represents whether programming key5 data failed.

- 0: No failure and the data of key5 is reliable.
- 1: Programming key5 failed and the number of error bytes is over 6. (RO)

EFUSE\_SYS\_PART2\_ERR\_NUM Represents the number of error bytes. (RO)

EFUSE\_SYS\_PART2\_FAIL Represents whether programming system part2 data failed.

- 0: No failure and the data of system part2 is reliable.
- 1: Programming user data failed and the number of error bytes is over 6.

(RO)

## Register 6.103. EFUSE\_CLK\_REG (0x01C8)

![Image](images/06_Chapter_6_img089_c9be2a7f.png)

EFUSE\_MEM\_FORCE\_PD Configures whether or not to force eFuse SRAM into power-saving mode.

- 1: Force

0: No effect

(R/W)

EFUSE\_MEM\_CLK\_FORCE\_ON Configures whether or not to force activate clock signal of eFuse SRAM.

- 1: Force activate

0: No effect

(R/W)

EFUSE\_MEM\_FORCE\_PU Configures whether or not to force eFuse SRAM into working mode.

- 1: Force

0: No effect

(R/W)

EFUSE\_CLK\_EN Configures whether or not to force enable eFuse register configuration clock sig- nal.

- 1: Force
- 0: The clock is enabled only during the reading and writing of registers

(R/W)

## Register 6.104. EFUSE\_CONF\_REG (0x01CC)

![Image](images/06_Chapter_6_img090_eaf11408.png)

EFUSE\_OP\_CODE Configures operation command type.

0x5A5A: Pprogramming operation command

0x5AA5: Read operation command

Other values: No effect

(R/W)

## Register 6.105. EFUSE\_STATUS\_REG (0x01D0)

![Image](images/06_Chapter_6_img091_eaae6bed.png)

EFUSE\_STATE Represents the state of the eFuse state machine. (RO)

EFUSE\_BLK0\_VALID\_BIT\_CNT Represents the number of block valid bit. (RO)

## Register 6.106. EFUSE\_CMD\_REG (0x01D4)

![Image](images/06_Chapter_6_img092_de976b9d.png)

EFUSE\_READ\_CMD Configures whether or not to send read command.

1: Send

0: No effect

(R/W/SC)

EFUSE\_PGM\_CMD Configures whether or not to send programming command.

- 1: Send

0: No effect

(R/W/SC)

EFUSE\_BLK\_NUM Represents the serial number of the block to be programmed. Value 0-10 corresponds to block number 0-10, respectively. (R/W)

![Image](images/06_Chapter_6_img093_3a1c3bfa.png)

## Register 6.110. EFUSE\_INT\_CLR\_REG (0x01E4)

![Image](images/06_Chapter_6_img094_10d22d86.png)

## Register 6.111. EFUSE\_DAC\_CONF\_REG (0x01E8)

![Image](images/06_Chapter_6_img095_9a89ea7e.png)

EFUSE\_DAC\_CLK\_DIV Configures the division factor of the rising clock of the programming voltage. (R/W)

EFUSE\_DAC\_CLK\_PAD\_SEL Don’t care. (R/W)

EFUSE\_DAC\_NUM Configures the rising period of the programming voltage. Measurement unit: Divided clock frequency by EFUSE\_DAC\_CLK\_DIV. (R/W)

EFUSE\_OE\_CLR Reduces the power supply of the programming voltage. (R/W)

Register 6.112. EFUSE\_RD\_TIM\_CONF\_REG (0x01EC)

![Image](images/06_Chapter_6_img096_4cf21a8b.png)

EFUSE\_THR\_A Configures the read hold time. Measurement unit: One cycle of the eFuse core clock. (R/W)

EFUSE\_TRD Configures the read time. Measurement unit: One cycle of the eFuse core clock. (R/W)

EFUSE\_TSUR\_A Configures the read setup time. Measurement unit: One cycle of the eFuse core clock. (R/W)

EFUSE\_READ\_INIT\_NUM Configures the waiting time of reading eFuse memory. Measurement unit: One cycle of the eFuse core clock. (R/W)

## Register 6.113. EFUSE\_WR\_TIM\_CONF1\_REG (0x01F0)

![Image](images/06_Chapter_6_img097_095e5d5a.png)

- EFUSE\_TSUP\_A Configures the programming setup time. Measurement unit: One cycle of the eFuse core clock.(R/W)

EFUSE\_PWR\_ON\_NUM Configures the power up time for VDDQ. Measurement unit: One cycle of the eFuse core clock. (R/W)

EFUSE\_THP\_A Configures the programming hold time. Measurement unit: One cycle of the eFuse core clock. (R/W)

## Register 6.114. EFUSE\_WR\_TIM\_CONF2\_REG (0x01F4)

![Image](images/06_Chapter_6_img098_d21117fa.png)

EFUSE\_PWR\_OFF\_NUM Configures the power outage time for VDDQ. Measurement unit: One cycle of the eFuse core clock. (R/W)

EFUSE\_TPGM Configures the active programming time. Measurement unit: One cycle of the eFuse core clock. (R/W)

## Register 6.115. EFUSE\_WR\_TIM\_CONF0\_REG (0x01F8)

![Image](images/06_Chapter_6_img099_954c55f2.png)

EFUSE\_UPDATE Configures whether to update multi-bit register signals.

1: Update

0: No effect

(WT)

EFUSE\_TPGM\_INACTIVE Configures the inactive programming time. Measurement unit: One cycle of the eFuse core clock. (R/W)

## Register 6.116. EFUSE\_DATE\_REG (0x01FC)

![Image](images/06_Chapter_6_img100_49dabc35.png)

EFUSE\_DATE Version control register. (R/W)

## Part III

## System Component

Encompassing a range of system-level functionalities, this part describes components related to system boot, clocks, GPIO, timers, watchdogs, interrupt handling, debug assistance, low-power management, and various system registers.
