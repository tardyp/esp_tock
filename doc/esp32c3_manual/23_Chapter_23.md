---
chapter: 23
title: "Chapter 23"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 23

## External Memory Encryption and Decryption (XTS\_AES)

## 23.1 Overview

The ESP32-C3 integrates an External Memory Encryption and Decryption module that complies with the XTS\_AES standard algorithm specified in IEEE Std 1619-2007, providing security for users' application code and data stored in the external memory (flash). Users can store proprietary firmware and sensitive data (e.g., credentials for gaining access to a private network) to the external flash.

## 23.2 Features

- General XTS\_AES algorithm, compliant with IEEE Std 1619-2007
- Software-based manual encryption
- High-speed auto decryption, without software's participation
- Encryption and decryption functions jointly determined by registers configuration, eFuse parameters, and boot mode

## 23.3 Module Structure

The External Memory Encryption and Decryption module consists of two blocks, namely the Manual Encryption block and Auto Decryption block. The module architecture is shown in Figure 23.3-1 .

System

![Image](images/23_Chapter_23_img001_3cd12692.png)

Register

Figure 23.3-1. Architecture of the External Memory Encryption and Decryption

The Manual Encryption block can encrypt instructions/data which will then be written to the external flash as ciphertext via SPI1.

In the System Registers (SYSREG) peripheral (see 16 System Registers (SYSREG)), the following four bits in register SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG are relevant to the external memory encryption and decryption:

- SYSTEM\_ENABLE\_DOWNLOAD\_MANUAL\_ENCRYPT
- SYSTEM\_ENABLE\_DOWNLOAD\_G0CB\_DECRYPT
- SYSTEM\_ENABLE\_DOWNLOAD\_DB\_ENCRYPT
- SYSTEM\_ENABLE\_SPI\_MANUAL\_ENCRYPT

The XTS\_AES module also fetches two parameters from the peripheral eFuse Controller, which are: EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT and EFUSE\_SPI\_BOOT\_CRYPT\_CNT. For detailed information, please see 4 eFuse Controller (EFUSE) .

## 23.4 Functional Description

## 23.4.1 XTS Algorithm

The manual encryption and auto decryption use the XTS algorithm. During implementation, the XTS algorithm is characterized by a "data unit" of 1024 bits, defined in the Section XTS-AES encryption procedure of XTS-AES Tweakable Block Cipher Standard. For more information about XTS-AES algorithm, please refer to IEEE Std 1619-2007 .

## 23.4.2 Key

The Manual Encryption block and Auto Decryption block share the same Key when implementing XTS algorithm. The Key is provided by the eFuse hardware and cannot be accessed by users.

The Key is 256-bit long. The value of the Key is determined by the content in one eFuse block from BLOCK4 ~ BLOCK9. For easier description, we define:

- Block A : the block whose key purpose is EFUSE\_KEY\_PURPOSE\_XTS\_AES\_128\_KEY (please refer to Table 4.3-2 Secure Key Purpose Values). The 256-bit KeyA is stored in it.

There are two possibilities of how the Key is generated depending on whether BlockA exists or not, as shown in Table 23.4-1. In each case, the Key can be uniquely determined by BlockA .

Table 23.4-1. Key generated based on KeyA

| Block A   | Key   |   Key Length (bit) |
|-----------|-------|--------------------|
| Yes       | KeyA  |                256 |
| No        | 0 256 |                256 |

## Notes:

"YES" indicates that the block exists; "NO" indicates that the block does not exist; "0 256 " indicates a bit string that consists of 256-bit zeros. Note that using 0 256 as Key is not secure. We strongly recommend to configure a valid key.

For more information of key purposes, please refer to Table 4.3-2 Secure Key Purpose Values in Chapter 4 eFuse Controller (EFUSE) .

## 23.4.3 Target Memory Space

The target memory space refers to a continuous address space in the external memory (flash) where the ciphertext is stored. The target memory space can be uniquely determined by two relevant parameters: size and base address, whose definitions are listed below.

- Size: the size of the target memory space, indicating the number of bytes encrypted in one encryption operation, which supports 16 or 32 bytes.
- Base address: the base \_ addr of the target memory space. It is a 24-bit physical address, with range of 0x0000\_0000 ~ 0x00FF\_FFFF. It should be aligned to size, i.e., base \_ addr%size == 0 .

For example, if there are 16 bytes of instruction data need to be encrypted and written to address 0x130 ~ 0x13F in the external flash, then the target space is 0x130 ~ 0x13F, size is 16 (bytes), and base address is 0x130.

The encryption of any length (must be multiples of 16 bytes) of plaintext instruction/data can be completed separately in multiple operations, and each operation has its individual target memory space and the relevant parameters.

For Auto Decryption blocks, these parameters are automatically determined by hardware. For Manual Encryption blocks, these parameters should be configured by users.

## Note:

The “tweak” defined in Section Data units and tweaks of IEEE Std 1619-2007 is a 128-bit non-negative integer

(tweak), which can be generated according to tweak = (base \_ addr &amp; 0x00FFFF80). The lowest 7 bits and the highest 97 bits in tweak are always zero.

## 23.4.4 Data Writing

For Auto Decryption blocks, data writing is automatically applied in hardware. For Manual Encryption blocks, data writing should be applied by users. The Manual Encryption block has a register block which consists of 8 registers, i.e., XTS\_AES\_PLAIN\_n\_REG (n: 0 ~ 7), that are dedicated to data writing and can store up to 256 bits of plaintext at a time.

Actually, the Manual Encryption block does not care where the plaintext comes from, but only where the ciphertext will be stored. Because of the strict correspondence between plaintext and ciphertext, in order to better describe how the plaintext is stored in the register block, we assume that the plaintext is stored in the target memory space in the first place and replaced by ciphertext after encryption. Therefore, the following description no longer has the concept of "plaintext", but uses "target memory space" instead. Please note that the plaintext can come from everywhere in actual use, but users should understand how the plaintext is stored in the register block.

## How mapping between target memory space and registers works:

Assume a word in the target memory space is stored in address, define offset = address%32 , n = of f set 4 , then the word will be stored in register XTS\_AES\_PLAIN\_n\_REG.

The mapping between offset and registers is shown in Table 23.4-2 .

Table 23.4-2. Mapping Between Offsets and Registers

| offset   | Register            | offset   | Register            |
|----------|---------------------|----------|---------------------|
| 0x00     | XTS_AES_PLAIN_0_REG | 0x10     | XTS_AES_PLAIN_4_REG |
| 0x04     | XTS_AES_PLAIN_1_REG | 0x14     | XTS_AES_PLAIN_5_REG |
| 0x08     | XTS_AES_PLAIN_2_REG | 0x18     | XTS_AES_PLAIN_6_REG |
| 0x0C     | XTS_AES_PLAIN_3_REG | 0x1C     | XTS_AES_PLAIN_7_REG |

## 23.4.5 Manual Encryption Block

The Manual Encryption block is a peripheral module. It is equipped with registers and can be accessed by the CPU directly. Registers embedded in this block, the System Registers (SYSREG) peripheral, eFuse parameters, and boot mode jointly configure and use this module. Please note that the Manual Encryption block can only encrypt for storage in external flash.

The Manual Encryption block is operational only under certain conditions. The operating conditions are:

- •

If bit SYSTEM\_ENABLE\_SPI\_MANUAL\_ENCRYPT in register SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG is 1, the Manual Encryption block can

- In SPI Boot mode be enabled. Otherwise, it is not operational.
- In Download Boot mode

If bit SYSTEM\_ENABLE\_DOWNLOAD\_MANUAL\_ENCRYPT in register SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG is 1 and the eFuse parameter EFUSE\_DIS\_DOWNLOAD\_MANUAL\_ENCRYPT is 0, the Manual Encryption block can be enabled.

Otherwise, it is not operational.

## Note:

- Even though the CPU can skip cache and get the encrypted instruction/data directly by reading the external memory, users can by no means access Key .

## 23.4.6 Auto Decryption Block

The Auto Decryption block is not a conventional peripheral, so it does not have any registers and cannot be accessed by the CPU directly. The System Registers (SYSREG) peripheral, eFuse parameters, and boot mode jointly configure and use this block.

The Auto Decryption block is operational only under certain conditions. The operating conditions are:

- •
- In SPI Boot mode

If the first bit or the third bit in parameter SPI\_BOOT\_CRYPT\_CNT (3 bits) is set to 1, then the Auto Decryption block can be enabled. Otherwise, it is not operational.

- In Download Boot mode

If bit SYSTEM\_ENABLE\_DOWNLOAD\_G0CB\_DECRYPT in register SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG is 1, the Auto Decryption block can be enabled. Otherwise, it is not operational.

## Note:

- When the Auto Decryption block is enabled, it will automatically decrypt the ciphertext if the CPU reads instructions/data from the external memory via cache to retrieve the instructions/data. The entire decryption process does not need software participation and is transparent to the cache. Users can by no means obtain the decryption Key during the process.
- When the Auto Decryption block is disabled, it does not have any effect on the contents stored in the external memory, no matter if they are encrypted or not. Therefore, what the CPU reads via cache is the original information stored in the external memory.

## 23.5 Software Process

When the Manual Encryption block operates, software needs to be involved in the process. The steps are as follows:

1. Configure XTS\_AES:
- Set register XTS\_AES\_PHYSICAL\_ADDRESS\_REG to base \_ addr .
- Set register XTS\_AES\_LINESIZE\_REG to size 32 .

For definitions of base \_ addr and size, please refer to Section 23.4.3 .

2. Write plaintext data to the registers block XTS\_AES\_PLAIN\_n\_REG (n: 0-7). For detailed information, .
2. please refer to Section 23.4.4 Please write data to registers according to your actual needs, and the unused ones could be set to
3. arbitrary values.
3. Wait for Manual Encryption block to be idle. Poll register XTS\_AES\_STATE\_REG until it reads 0 that indicates the Manual Encryption block is idle.
4. Trigger manual encryption by writing 1 to register XTS\_AES\_TRIGGER\_REG.
5. Wait for the encryption process completion. Poll register XTS\_AES\_STATE\_REG until it reads 2. Step 1 to 5 are the steps of encrypting plaintext instructions with the Manual Encryption block using the Key .
6. Write 1 to register XTS\_AES\_RELEASE\_REG to grant SPI1 the access to the encrypted ciphertext. After this, the value of register XTS\_AES\_STATE\_REG will become 3.
7. Call SPI1 to write the ciphertext in the external flash (see Chapter 27 SPI Controller (SPI)).
8. Write 1 to register XTS\_AES\_DESTROY\_REG to destroy the ciphertext. After this, the value of register XTS\_AES\_STATE\_REG will become 0.

Repeat above steps according to the amount of plaintext instructions/data that need to be encrypted.

## 23.6 Register Summary

The addresses in this section are relative to External Memory Encryption and Decryption base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                         | Description                                | Address   | Access   |
|------------------------------|--------------------------------------------|-----------|----------|
| Plaintext Register Heap      |                                            |           |          |
| XTS_AES_PLAIN_0_REG          | Plaintext register 0                       | 0x0000    | R/W      |
| XTS_AES_PLAIN_1_REG          | Plaintext register 1                       | 0x0004    | R/W      |
| XTS_AES_PLAIN_2_REG          | Plaintext register 2                       | 0x0008    | R/W      |
| XTS_AES_PLAIN_3_REG          | Plaintext register 3                       | 0x000C    | R/W      |
| XTS_AES_PLAIN_4_REG          | Plaintext register 4                       | 0x0010    | R/W      |
| XTS_AES_PLAIN_5_REG          | Plaintext register 5                       | 0x0014    | R/W      |
| XTS_AES_PLAIN_6_REG          | Plaintext register 6                       | 0x0018    | R/W      |
| XTS_AES_PLAIN_7_REG          | Plaintext register 7                       | 0x001C    | R/W      |
| Configuration Registers      |                                            |           |          |
| XTS_AES_LINESIZE_REG         | Configures the size of target memory space | 0x0040    | R/W      |
| XTS_AES_DESTINATION_REG      | Configures the type of the external memory | 0x0044    | R/W      |
| XTS_AES_PHYSICAL_ADDRESS_REG | Physical address                           | 0x0048    | R/W      |
| Control/Status Registers     |                                            |           |          |
| XTS_AES_TRIGGER_REG          | Activates AES algorithm                    | 0x004C    | WO       |
| XTS_AES_RELEASE_REG          | Release control                            | 0x0050    | WO       |
| XTS_AES_DESTROY_REG          | Destroys control                           | 0x0054    | WO       |
| XTS_AES_STATE_REG            | Status register                            | 0x0058    | RO       |
| Version Register             |                                            |           |          |
| XTS_AES_DATE_REG             | Version control register                   | 0x005C    | RO       |

## 23.7 Registers

The addresses in this section are relative to External Memory Encryption and Decryption base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 23.1. XTS\_AES\_PLAIN\_n\_REG (n: 0-15) (0x0000+4*n)

![Image](images/23_Chapter_23_img002_48990d4e.png)

XTS\_AES\_PLAIN\_n Stores nth 32-bit piece of plain text. (R/W)

Register 23.2. XTS\_AES\_LINESIZE\_REG (0x0040)

![Image](images/23_Chapter_23_img003_2eb2a3e6.png)

XTS\_AES\_LINESIZE Configures the data size of one encryption operation.

- 0: 16 bytes;
- 1: 32 bytes. (R/W)

Register 23.3. XTS\_AES\_DESTINATION\_REG (0x0044)

![Image](images/23_Chapter_23_img004_9316f593.png)

XTS\_AES\_DESTINATION Configures the type of the external memory. Currently, it must be set to 0, as the Manual Encryption block only supports flash encryption. Errors may occur if users write 1.

- 0: flash;
- 1: external RAM. (R/W)

Register 23.4. XTS\_AES\_PHYSICAL\_ADDRESS\_REG (0x0048)

![Image](images/23_Chapter_23_img005_8c42b9ce.png)

XTS\_AES\_PHYSICAL\_ADDRESS Physical address. (Note that its value should be within the range between 0x0000\_0000 and 0x00FF\_FFFF). (R/W)

Register 23.5. XTS\_AES\_TRIGGER\_REG (0x004C)

![Image](images/23_Chapter_23_img006_625d74f6.png)

XTS\_AES\_TRIGGER Write 1 to enable manual encryption. (WO)

Register 23.6. XTS\_AES\_RELEASE\_REG (0x0050)

![Image](images/23_Chapter_23_img007_13ba50f5.png)

XTS\_AES\_RELEASE Write 1 to grant SPI1 access to the encrypted result. (WO)

## Register 23.7. XTS\_AES\_DESTROY\_REG (0x0054)

![Image](images/23_Chapter_23_img008_512a6faa.png)

XTS\_AES\_DESTROY Write 1 to destroy encrypted result. (WO)

Register 23.8. XTS\_AES\_STATE\_REG (0x0058)

![Image](images/23_Chapter_23_img009_217334e1.png)

XTS\_AES\_STATE Indicates the status of the Manual Encryption block.

- 0x0 (XTS\_AES\_IDLE): idle;
- 0x1 (XTS\_AES\_BUSY): busy with encryption;
- 0x2 (XTS\_AES\_DONE): encryption is completed, but the encrypted result is not accessible to SPI;
- 0x3 (XTS\_AES\_RELEASE): encrypted result is accessible to SPI. (RO)

## Register 23.9. XTS\_AES\_DATE\_REG (0x005C)

![Image](images/23_Chapter_23_img010_9611582a.png)

XTS\_AES\_DATE Version control register. (R/W)
