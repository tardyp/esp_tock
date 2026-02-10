---
chapter: 25
title: "Chapter 25"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 25

## External Memory Encryption and Decryption (XTS\_AES)

## 25.1 Overview

The ESP32-C6 integrates an External Memory Encryption and Decryption module that complies with the XTS-AES standard algorithm specified in IEEE Std 1619-2007, providing security for users' application code and data stored in the external memory (flash). Users can store proprietary firmware and sensitive data (e.g., credentials for gaining access to a private network) to the external flash.

## 25.2 Features

- General XTS-AES algorithm, compliant with IEEE Std 1619-2007
- Software-based manual encryption
- High-speed auto decryption without software's participation
- Encryption and decryption functions jointly enabled/disabled by registers configuration, eFuse parameters, and boot mode
- Configurable Anti-DPA

## 25.3 Module Structure

The External Memory Encryption and Decryption module consists of two blocks, namely the Manual Encryption block and Auto Decryption block. The module architecture is shown in Figure 25.3-1 .

System

![Image](images/25_Chapter_25_img001_03b3bd9e.png)

Registers

Figure 25.3-1. Architecture of the External Memory Encryption and Decryption

The Manual Encryption block can encrypt instructions/data which will then be written to the external flash as ciphertext via SPI1.

In the System Registers (HP\_SYS) peripheral (see 17 System Registers), the following three bits in register HP\_SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG are relevant to the external memory encryption and decryption:

- HP\_SYSTEM\_ENABLE\_DOWNLOAD\_MANUAL\_ENCRYPT
- HP\_SYSTEM\_ENABLE\_DOWNLOAD\_G0CB\_DECRYPT
- HP\_SYSTEM\_ENABLE\_SPI\_MANUAL\_ENCRYPT

The XTS\_AES module also fetches two parameters from the peripheral eFuse Controller, which are: EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT and EFUSE\_SPI\_BOOT\_CRYPT\_CNT. For detailed information, please see Chapter 6 eFuse Controller .

## 25.4 Functional Description

## 25.4.1 XTS Algorithm

Both manual encryption and auto decryption use the XTS algorithm. During implementation, the XTS algorithm is characterized by a "data unit" of 1024 bits, defined in the Section XTS-AES encryption procedure of XTS-AES Tweakable Block Cipher Standard. For more information about the XTS-AES algorithm, please refer to IEEE Std 1619-2007 .

## 25.4.2 Key

The Manual Encryption block and Auto Decryption block share the same Key when implementing the XTS algorithm. The Key is provided by the eFuse hardware and cannot be accessed by users.

The Key is 256-bit long. The value of the Key is determined by the content in one eFuse block from BLOCK4 ~ BLOCK9. For easier description, we define:

- Block A : the block whose key purpose is EFUSE\_KEY\_PURPOSE\_XTS\_AES\_128\_KEY (please refer to Table 6.3-2 Secure Key Purpose Values). If BlockA exists, a 256-bit KeyA is stored in it.

There are two possibilities of how the Key is generated depending on whether BlockA exists or not, as shown in Table 25.4-1. In each case, the Key can be uniquely determined by KeyA .

Table 25.4-1. Key generated based on KeyA

| Block A   | Key   |   Key Length (bit) |
|-----------|-------|--------------------|
| Yes       | KeyA  |                256 |
| No        | 0 256 |                256 |

## Notes:

"YES" indicates that the block exists; "NO" indicates that the block does not exist; "0 256 " indicates a bit string that consists of 256-bit zeros. Note that using 0 256 as Key is not secure. We strongly recommend to configure a valid key.

For more information on key purposes, please refer to Table 6.3-2 Secure Key Purpose Values in Chapter 6 eFuse Controller .

## 25.4.3 Target Memory Space

The target memory space refers to a continuous address space in the external memory (flash) where the ciphertext is stored. The target memory space can be uniquely determined by two relevant parameters: size and base address, whose definitions are listed below.

- Size: the size of the target memory space, indicating the number of bytes encrypted in one encryption operation, which supports 16, 32, or 64 bytes.
- Base address: the base \_ addr of the target memory space. It is a 24-bit physical address, with a range of 0x0000\_0000 ~ 0x00FF\_FFFF. It should be aligned to size, i.e., base \_ addr%size == 0 .

For example, if there are 16 bytes of instruction data that need to be encrypted and written to address 0x130 ~ 0x13F in the external flash, then the target space is 0x130 ~ 0x13F, size is 16 (bytes), and the base address is 0x130.

The encryption of any length (must be multiples of 16 bytes) of plaintext instruction/data can be completed separately in multiple operations, and each operation has its individual target memory space and the relevant parameters.

For Auto Decryption blocks, these parameters are automatically determined by hardware. For Manual Encryption blocks, these parameters should be configured by users.

## Note:

The “tweak” defined in Section Data units and tweaks of IEEE Std 1619-2007 is a 128-bit non-negative integer

(tweak), which can be generated according to tweak = (base \_ addr &amp; 0x00FFFF80). The lowest 7 bits and the highest 97 bits in tweak are always zero.

## 25.4.4 Data Writing

For Auto Decryption blocks, data writing is automatically applied in hardware. For Manual Encryption blocks, data writing should be applied by users. The Manual Encryption block has a register block which consists of 16 registers, i.e., XTS\_AES\_PLAIN\_n\_REG (n: 0 ~ 15), that are dedicated to data writing and can store up to 256 bits of plaintext at a time.

Actually, the Manual Encryption block does not care where the plaintext comes from, but only where the ciphertext will be stored. Because of the strict correspondence between plaintext and ciphertext, in order to better describe how the plaintext is stored in the register block, we assume that the plaintext is stored in the target memory space in the first place and replaced by ciphertext after encryption. Therefore, the following description in this section no longer has the concept of "plaintext", but uses "target memory space" instead.

## How mapping between target memory space and registers works:

Assume a word in the target memory space is stored in address, define offset = address%64 , n = offset/4 , then the word will be stored in register XTS\_AES\_PLAIN\_n\_REG.

For example, when the size is 32, all registers in the register block will be used. The mapping between offset and registers now is shown in Table 25.4-2 .

Table 25.4-2. Mapping Between Offsets and Registers

| offset   | Register            | offset   | Register             |
|----------|---------------------|----------|----------------------|
| 0x00     | XTS_AES_PLAIN_0_REG | 0x20     | XTS_AES_PLAIN_8_REG  |
| 0x04     | XTS_AES_PLAIN_1_REG | 0x24     | XTS_AES_PLAIN_9_REG  |
| 0x08     | XTS_AES_PLAIN_2_REG | 0x28     | XTS_AES_PLAIN_10_REG |
| 0x0C     | XTS_AES_PLAIN_3_REG | 0x2C     | XTS_AES_PLAIN_11_REG |
| 0x10     | XTS_AES_PLAIN_4_REG | 0x30     | XTS_AES_PLAIN_12_REG |
| 0x14     | XTS_AES_PLAIN_5_REG | 0x34     | XTS_AES_PLAIN_13_REG |
| 0x18     | XTS_AES_PLAIN_6_REG | 0x38     | XTS_AES_PLAIN_14_REG |
| 0x1C     | XTS_AES_PLAIN_7_REG | 0x3C     | XTS_AES_PLAIN_15_REG |

## 25.4.5 Manual Encryption Block

The Manual Encryption block is a peripheral module. It is equipped with registers and can be accessed by the CPU directly. Registers embedded in this block, the System Registers (HP\_SYS) peripheral, eFuse parameters, and boot mode jointly configure and use this module.

The Manual Encryption block is operational only under certain conditions. The operating conditions are:

- In SPI Boot mode:

If bit HP\_SYSTEM\_ENABLE\_SPI\_MANUAL\_ENCRYPT in register

HP\_SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG is 1, the Manual Encryption block can be enabled. Otherwise, it is not operational.

- In Download Boot mode:

If bit HP\_SYSTEM\_ENABLE\_DOWNLOAD\_MANUAL\_ENCRYPT in register HP\_SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG is 1 and the eFuse parameter EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT is 0, the Manual Encryption block can be enabled. Otherwise, it is not operational.

## Note:

Even though the CPU can skip cache and get the encrypted instruction/data directly by reading the external memory, users can by no means access Key .

## 25.4.6 Auto Decryption Block

The Auto Decryption block is not a conventional peripheral, so it does not have any registers and cannot be accessed by the CPU directly. The System Registers (HP\_SYS) peripheral, eFuse parameters, and boot mode jointly configure and use this block.

The Auto Decryption block is operational only under certain conditions. The operating conditions are:

- In SPI Boot mode

If the first bit or the third bit in parameter SPI\_BOOT\_CRYPT\_CNT (3 bits) is set to 1, then the Auto Decryption block can be enabled. Otherwise, it is not operational.

- In Download Boot mode

If bit HP\_SYSTEM\_ENABLE\_DOWNLOAD\_G0CB\_DECRYPT in register HP\_SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG is 1, the Auto Decryption block can be enabled. Otherwise, it is not operational.

## Note:

- When the Auto Decryption block is enabled, it will automatically decrypt the ciphertext if the CPU reads instructions/data from the external memory via cache to retrieve the instructions/data. The entire decryption process does not need software participation and is transparent to the cache. Users can by no means obtain the decryption Key during the process.
- When the Auto Decryption block is disabled, it does not have any effect on the contents stored in the external memory, no matter if they are encrypted or not. Therefore, what the CPU reads via cache is the original information stored in the external memory.

## 25.5 Software Process

When the Manual Encryption block operates, software needs to be involved in the process. The steps are as follows:

1. Configure XTS\_AES:

- Set register XTS\_AES\_PHYSICAL\_ADDRESS\_REG to base \_ addr .
- Set register XTS\_AES\_LINESIZE\_REG to size 32 .

For definitions of base \_ addr and size, please refer to Section 25.4.3 .

2. Write plaintext instructions/data to the registers block XTS\_AES\_PLAIN\_n\_REG (n: 0-15). For detailed
2. information, please refer to Section 25.4.4 . Please write data to registers according to your actual needs, and the unused ones could be set to arbitrary values.
3. Wait for Manual Encryption block to be idle. Poll register XTS\_AES\_STATE\_REG until it reads 0 that indicates the Manual Encryption block is idle.
4. Trigger manual encryption by writing 1 to register XTS\_AES\_TRIGGER\_REG .
5. Wait for the encryption process completion. Poll register XTS\_AES\_STATE\_REG until it reads 2. Step 1 to 5 are the steps of encrypting plaintext instructions/data with the Manual Encryption block using the Key .
6. Write 1 to register XTS\_AES\_RELEASE\_REG to grant SPI1 the access to the encrypted ciphertext. After this, the value of register XTS\_AES\_STATE\_REG will become 3.
7. Call SPI1 to write the ciphertext in the external flash (see Section API Reference Flash Encrypt in ESP-IDF Programming Guide).
8. Write 1 to register XTS\_AES\_DESTROY\_REG to destroy the ciphertext. After this, the value of register XTS\_AES\_STATE\_REG will become 0.

Repeat above steps according to the amount of plaintext instructions/data that need to be encrypted.

## 25.6 Anti-DPA

ESP32-C6 XTS\_AES supports Anti-DPA.

The XTS-AES algorithm can be divided into two steps, according to IEEE Std 1619-2007:

- Step 1: Calculating T value. In this section, we define this step as "calculating T".
- Step 2: Calculating Cipher/Plain text. In this section, we define this step as "calculating D".

Different security levels can be configured through registers:

- First we define the below parameters for a better description:
- – select \_ reg = XTS\_AES\_CRYPT\_DPA\_SELECT\_REGISTER
- – reg \_ d \_ dpa \_ en = XTS\_AES\_CRYPT\_CALC\_D\_DPA\_EN
- – efuse \_ dpa \_ en = EFUSE\_CRYPT\_DPA\_ENABLE
- – reg \_ anti \_ dpa \_ level = XTS\_AES\_CRYPT\_SECURITY\_LEVEL
- – efuse \_ anti \_ dpa \_ level = 3
- Configure the security level of Anti-DPA for the XTS\_AES module:

Anti \_ DP A \_ level = select \_ reg ? (reg \_ anti \_ dpa \_ level) : (efuse \_ dpa \_ en ∗ efuse \_ anti \_ dpa \_ level)

When Anti \_ DP A \_ level equals to 0, Anti-DPA is disabled. The higher the value of Anti \_ DP A \_ level is, the stronger the Anti-DPA ability is.

- Configure whether or not to enable Anti-DPA when the XTS-AES algorithm is calculating D:

<!-- formula-not-decoded -->

If Anti \_ DP A \_ level is not 0, when Anti \_ DP A \_ enabled \_ in \_ calc \_ D equals to 1, Anti-DPA is enabled when XTS-AES algorithm is calculating D.

If Anti \_ DP A \_ level is not 0, Anti-DPA is always enabled when the XTS-AES algorithm is calculating T.

## Note:

Configuring whether or not to enable Anti-DPA will have an impact on the external storage access bandwidth:

- When Anti-DPA is enabled during the calculation of D, the read and write bandwidth will be significantly impacted when the Anti-Attack level &gt;= 4.
- When Anti-DPA is disabled during the calculation of D, the read and write bandwidth will be significantly impacted when the Anti-Attack level &gt;= 6.

## 25.7 Register Summary

The addresses in this section are relative to External Memory Encryption and Decryption base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                         | Description                                | Address   | Access   |
|------------------------------|--------------------------------------------|-----------|----------|
| Plaintext Register Heap      |                                            |           |          |
| XTS_AES_PLAIN_0_REG          | Plaintext register 0                       | 0x0300    | R/W      |
| XTS_AES_PLAIN_1_REG          | Plaintext register 1                       | 0x0304    | R/W      |
| XTS_AES_PLAIN_2_REG          | Plaintext register 2                       | 0x0308    | R/W      |
| XTS_AES_PLAIN_3_REG          | Plaintext register 3                       | 0x030C    | R/W      |
| XTS_AES_PLAIN_4_REG          | Plaintext register 4                       | 0x0310    | R/W      |
| XTS_AES_PLAIN_5_REG          | Plaintext register 5                       | 0x0314    | R/W      |
| XTS_AES_PLAIN_6_REG          | Plaintext register 6                       | 0x0318    | R/W      |
| XTS_AES_PLAIN_7_REG          | Plaintext register 7                       | 0x031C    | R/W      |
| XTS_AES_PLAIN_8_REG          | Plaintext register 8                       | 0x0320    | R/W      |
| XTS_AES_PLAIN_9_REG          | Plaintext register 9                       | 0x0324    | R/W      |
| XTS_AES_PLAIN_10_REG         | Plaintext register 10                      | 0x0328    | R/W      |
| XTS_AES_PLAIN_11_REG         | Plaintext register 11                      | 0x032C    | R/W      |
| XTS_AES_PLAIN_12_REG         | Plaintext register 12                      | 0x0330    | R/W      |
| XTS_AES_PLAIN_13_REG         | Plaintext register 13                      | 0x0334    | R/W      |
| XTS_AES_PLAIN_14_REG         | Plaintext register 14                      | 0x0338    | R/W      |
| XTS_AES_PLAIN_15_REG         | Plaintext register 15                      | 0x033C    | R/W      |
| Configuration Registers      |                                            |           |          |
| XTS_AES_LINESIZE_REG         | Configures the size of target memory space | 0x0340    | R/W      |
| XTS_AES_DESTINATION_REG      | Configures the type of the external memory | 0x0344    | R/W      |
| XTS_AES_PHYSICAL_ADDRESS_REG | Physical address                           | 0x0348    | R/W      |
| XTS_AES_DPA_CTRL_REG         | Configures the Anti-DPA function           | 0x0388    | R/W      |
| Control/Status Registers     |                                            |           |          |
| XTS_AES_TRIGGER_REG          | Activates AES algorithm                    | 0x034C    | WO       |
| XTS_AES_RELEASE_REG          | Release control                            | 0x0350    | WO       |
| XTS_AES_DESTROY_REG          | Destroy control                            | 0x0354    | WO       |
| XTS_AES_STATE_REG            | Status register                            | 0x0358    | RO       |
| Version Register             |                                            |           |          |
| XTS_AES_DATE_REG             | Version control register                   | 0x035C    | R/W      |

## 25.8 Registers

The addresses in this section are relative to External Memory Encryption and Decryption base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 25.1. XTS\_AES\_PLAIN\_n\_REG (n: 0-15) (0x0300+4*n)

![Image](images/25_Chapter_25_img002_aefbf6e8.png)

XTS\_AES\_PLAIN\_n Configures the nth 32-bit piece of plain text. (R/W)

Register 25.2. XTS\_AES\_LINESIZE\_REG (0x0340)

![Image](images/25_Chapter_25_img003_c13bdbde.png)

XTS\_AES\_LINESIZE Configures the data size of one encryption operation.

0: 16 bytes

1: 32 bytes

2: 64 bytes

3: Invalid

(R/W)

## Register 25.3. XTS\_AES\_DESTINATION\_REG (0x0344)

![Image](images/25_Chapter_25_img004_ec89e3a2.png)

XTS\_AES\_DESTINATION Configures the type of external memory. Currently, it must be set to 0, as the Manual Encryption block only supports flash encryption. Errors may occur if users write 1.

0: flash

1: external RAM (may cause error)

(R/W)

Register 25.4. XTS\_AES\_PHYSICAL\_ADDRESS\_REG (0x0348)

![Image](images/25_Chapter_25_img005_7990eee2.png)

XTS\_AES\_PHYSICAL\_ADDRESS Configures physical address. Note that its value should be within the range between 0x0000\_0000 and 0x00FF\_FFFF). (R/W)

## Register 25.5. XTS\_AES\_DPA\_CTRL\_REG (0x0388)

![Image](images/25_Chapter_25_img006_ad728c22.png)

- XTS\_AES\_CRYPT\_DPA\_SELECT\_REGISTER Configures whether the Anti-DPA function is controlled by eFuse or register.
- 0: The Anti-DPA function is configured by the register.
- 1: The Anti-DPA function is configured by eFuse. (R/W)
- XTS\_AES\_CRYPT\_CALC\_D\_DPA\_EN Configures whether to enable Anti-DPA in the XTS\_AES algorithm.
- 0: Enable Anti-DPA only when calculating T
- 1: Enable Anti-DPA both when calculating T and D
- Note that this field is only effective when XTS\_AES\_CRYPT\_SECURITY\_LEVEL is not 0. (R/W)
- XTS\_AES\_CRYPT\_SECURITY\_LEVEL Configures the security level of external memory encryption and decryption.
- 0: Disable the Anti-DPA function
- 1-7: The bigger the number is, the more secure the encryption and decryption are (R/W)

## Register 25.6. XTS\_AES\_TRIGGER\_REG (0x034C)

![Image](images/25_Chapter_25_img007_1dca8fb2.png)

XTS\_AES\_TRIGGER Configures whether or not to enable manual encryption.

- 0: Disable manual encryption
- 1: Enable manual encryption

(WO)

## Register 25.7. XTS\_AES\_RELEASE\_REG (0x0350)

![Image](images/25_Chapter_25_img008_1051b762.png)

XTS\_AES\_RELEASE Configures whether or not to grant SPI1 access to the encrypted result.

- 0: No effect
- 1: Grant SPI1 access

(WO)

## Register 25.8. XTS\_AES\_DESTROY\_REG (0x0354)

![Image](images/25_Chapter_25_img009_c7a0ca71.png)

XTS\_AES\_DESTROY Configures whether or not to destroy the encrypted result.

- 0: No effect
- 1: Destroy encrypted result

(WO)

## Register 25.9. XTS\_AES\_STATE\_REG (0x0358)

![Image](images/25_Chapter_25_img010_545e5395.png)

XTS\_AES\_STATE Represents the status of the Manual Encryption block. 0 (XTS\_AES\_IDLE): Idle

- 1 (XTS\_AES\_BUSY): Busy with encryption
- 2 (XTS\_AES\_DONE): Encryption completed, but the encrypted result is not accessible to SPI
- 3 (XTS\_AES\_RELEASE): Encrypted result is accessible to SPI

(RO)

## Register 25.10. XTS\_AES\_DATE\_REG (0x035C)

![Image](images/25_Chapter_25_img011_a9cbec08.png)

XTS\_AES\_DATE Version control register. (R/W)
