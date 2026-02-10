---
chapter: 19
title: "Chapter 19"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 19

## HMAC Accelerator (HMAC)

The Hash-based Message Authentication Code (HMAC) module computes Message Authentication Codes (MACs) using Hash algorithm and keys as described in RFC 2104. The hash algorithm is SHA-256, the 256-bit HMAC key is stored in an eFuse key block and can be set as read-protected, i. e., the key is not accessible from outside the HMAC accelerator itself.

## 19.1 Main Features

- Standard HMAC-SHA-256 algorithm
- Hash result only accessible by configurable hardware peripheral (in downstream mode)
- Compatible to challenge-response authentication algorithm
- Generates required keys for the Digital Signature (DS) peripheral (in downstream mode)
- Re-enables soft-disabled JTAG (in downstream mode)

## 19.2 Functional Description

The HMAC module operates in two modes: upstream mode and downstream mode. In upstream mode, the HMAC message is provided by users and the calculation result is read back by them; in downstream mode, the HMAC module is used as a Key Derivation Function (KDF) for other internal hardware. For instance, the JTAG can be temporarily disabled by burning odd number bits of EFUSE\_SOFT\_DIS\_JTAG in eFuse. In this case, users can temporarily re-enable JTAG using the HMAC module in downstream mode.

After the reset signal being released, the HMAC module will check whether the DS key exists in the eFuse. If the key exists, the HMAC module will enter downstream digital signature mode and finish the DS key calculation automatically.

## 19.2.1 Upstream Mode

Common use cases for the upstream mode are challenge-response protocols supporting HMAC-SHA-256. Assume the two entities in the challenge-response protocol are A and B respectively, and the data message they expect to exchange is M. The general process of this protocol is as follows:

- A calculates a unique random number M
- A sends M to B
- B calculates the HMAC (through M and KEY) and sends the result to A
- A calculates the HMAC (through M and KEY) internally

- A compares the two results. If they are the same, then the identity of B is authenticated

To calculate the HMAC value (the following steps should be done by the user):

1. Initialize the HMAC module, and enter upstream mode.
2. Write the correctly padded message to the HMAC, one block at a time.
3. Read back the result from HMAC.

For details of this process, please see Section 19.2.5 .

## 19.2.2 Downstream JTAG Enable Mode

JTAG debugging can be disabled in a way which allows later re-enabling using the HMAC module. The HMAC module will expect the user to supply the HMAC result for one of the eFuse keys. The HMAC module will check whether the supplied HMAC matches the one calculated from the chosen key. If both HMACs are the same, JTAG will be enabled until the user calls the HMAC module to clear the results and consequently disable JTAG again.

There are two parameters in eFuse memory to disable JTAG: EFUSE\_HARD\_DIS\_JTAG and EFUSE\_SOFT\_DIS\_JTAG. Write 1 to EFUSE\_DIS\_PAD\_JTAG to disable JTAG permanently, and write odd numbers of 1 to EFUSE\_SOFT\_DIS\_JTAG to disable JTAG temporarily. For more details, please see Chapter 4 eFuse Controller (EFUSE). After bit EFUSE\_SOFT\_DIS\_JTAG is set, the key to re-enable JTAG can be calculated in HMAC module's downstream mode. JTAG is re-enabled when the result configured by the user is the same as the HMAC result.

To re-enable JTAG:

1. Users enable the HMAC module by initializing clock and reset signals of HMAC, and enter downstream JTAG enable mode by configuring HMAC\_SET\_PARA\_PURPOSE\_REG, then Wait for the calculation to complete. Please see Section 19.2.5 for more details.
2. Users write 1 to the HMAC\_SOFT\_JTAG\_CTRL\_REG register to enter JTAG re-enable compare mode.
3. Users write the 256-bit HMAC value which is calculated locally from the 32-byte 0x00 using SHA-256 and the generated key to register HMAC\_WR\_JTAG\_REG by writing 8 times and 32-bit each time in big-endian word order.
4. If the HMAC result matches the value that users calculated locally, then JTAG is re-enabled. Otherwise, JTAG remains disabled.
5. After writing 1 to HMAC\_SET\_INVALIDATE\_JTAG\_REG or resetting the chip, JTAG will be disabled. If users want to re-enable JTAG again, they need to repeat the above steps again.

## 19.2.3 Downstream Digital Signature Mode

The Digital Signature (DS) module encrypts its parameters using the AES-CBC algorithm. The HMAC module is used as a Key Derivation Function (KDF) to derive the AES key to decrypt these parameters (parameter decryption key). The key used for the HMAC as KDF is stored in one of the eFuse key blocks.

Before starting the DS module, users need to obtain the parameter decryption key for the DS module through HMAC calculation. For more information, please see Chapter 22 Digital Signature (DS). After the chip is powered on, the HMAC module will check whether the key required to calculate the parameter decryption key

has been burned in the eFuse block. If the key has been burned, HMAC module will automatically enter the downstream digital signature mode and complete the HMAC calculation based on the chosen key.

## 19.2.4 HMAC eFuse Configuration

Each HMAC key burned into an eFuse block has a key purpose, also burned into the eFuse section. This purpose specifies for which functionality the key can be used. The HMAC module will not accept a key with a non-matching purpose for any functionality. The HMAC module provides three different functionalities: re-enabling JTAG and serving as DS KDF in downstream mode as well as pure HMAC calculation in upstream mode. For each functionality, there exists a corresponding key purpose, listed in Table 19.2-1. Additionally, another purpose specifies a key which may be used for re-enabling JTAG as well as for serving as DS KDF.

Before enabling HMAC to do calculations, user should make sure the key to be used has been burned in eFuse by reading EFUSE\_KEY\_PURPOSE\_x (We totally have 6 keys in eFuse, so x = 0,1,2,..,5), registers from 4 eFuse Controller (EFUSE). Take upstream as example, if there is no EFUSE\_KEY\_PURPOSE\_HMAC\_UP in EFUSE\_KEY\_PURPOSE\_0~5, means there is no upstream used key in efuse. You can burn key to efuse as follows:

1. Prepare a secret 256-bit HMAC key and burn the key to an empty eFuse block y (there are six blocks for storing a key in eFuse. The numbers of those blocks range from 4 to 9, so y = 4,5,..,9. Hence, if we are talking about key0, we mean eFuse block4), and then program the purpose to EFUSE\_KEY\_PURPOSE\_(y − 4). Take upstream mode as an example: after programming the key, the user should program EFUSE\_KEY\_PURPOSE\_HMAC\_UP (corresponding value is 6) to EFUSE\_KEY\_PURPOSE\_(y − 4). Please see Chapter 4 eFuse Controller (EFUSE) on how to program eFuse keys.
2. Configure this eFuse key block to be read protected, so that users cannot read its value. A copy of this key should be kept by any party who needs to verify this device.

Please note that the key whose purpose is EFUSE\_KEY\_PURPOSE\_HMAC\_DOWN\_ALL can be used for both re-enabling JTAG or DS.

Table 19.2-1. HMAC Purposes and Configuration Value

| Purpose                        | Mode       |   Value | Description                                   |
|--------------------------------|------------|---------|-----------------------------------------------|
| JTAG Re-enable                 | Downstream |       6 | EFUSE_KEY_PURPOSE_HMAC_DOWN_JTAG              |
| DS Key Derivation              | Downstream |       7 | EFUSE_KEY_PURPOSE_HMAC_DOWN_DIGITAL_SIGNATURE |
| HMAC Calculation               | Upstream   |       8 | EFUSE_KEY_PURPOSE_HMAC_UP                     |
| Both JTAG Re-enable and DS KDF | Downstream |       5 | EFUSE_KEY_PURPOSE_HMAC_DOWN_ALL               |

## Configure HMAC Purposes

The correct purpose has to be written to register HMAC\_SET\_PARA\_PURPOSE\_REG (see Section 19.2.5). If there is no valid value in efuse purpose section, HMAC will terminate calculation.

## Select eFuse Key Blocks

The eFuse controller provides six key blocks, i.e., KEY0 ~ 5. To select a particular KEYn for an HMAC calculation, write the key number n to register HMAC\_SET\_PARA\_KEY\_REG .

Note that the purpose of the key has also been programmed to eFuse memory. Only when the configured HMAC purpose matches the defined purpose of KEYn, will the HMAC module execute the configured calculation. Otherwise, it will return a matching error and stop the current calculation. For example, suppose a user selects KEY3 for HMAC calculation, and the value programmed to KEY\_PURPOSE\_3 is 6 (EFUSE\_KEY\_PURPOSE\_HMAC\_DOWN\_JTAG). Based on Table 19.2-1, KEY3 can be used to re-enable JTAG. If the value written to register HMAC\_SET\_PARA\_PURPOSE\_REG is also 6, then the HMAC module will start the process to re-enable JTAG.

## 19.2.5 HMAC Process (Detailed)

The process to call HMAC is as follows:

1. Enable HMAC module
2. (a) Set the peripheral clock bits for HMAC and SHA peripherals in register SYSTEM\_PERIP\_CLK\_EN1\_REG, and clear the corresponding peripheral reset bits in register SYSTEM\_PERIP\_RST\_EN1\_REG. For information on those registers, please see Chapter 3 System and Memory .
3. (b) Write 1 to register HMAC\_SET\_START\_REG .
2. Configure HMAC keys and key purposes
5. (a) Write the key purpose m to register HMAC\_SET\_PARA\_PURPOSE\_REG. The possible key purpose values are shown in Table 19.2-1. For more information, please refer to Section 19.2.4 .
6. (b) Select KEYn in eFuse memory as the key by writing n (ranges from 0 to 5) to register HMAC\_SET\_PARA\_KEY\_REG. For more information, please refer to Section 19.2.4 .
7. (c) Write 1 to register HMAC\_SET\_PARA\_FINISH\_REG to complete the configuration.
8. (d) Read register HMAC\_QUERY\_ERROR\_REG. If its value is 1, it means the purpose of the selected block does not match the configured key purpose and the calculation will not proceed. If its value is 0, it means the purpose of the selected block matches the configured key purpose, and then the calculation can proceed.
9. (e) When the value of HMAC\_SET\_PARA\_PURPOSE\_REG is not 8, it means the HMAC module is in downstream mode, proceed with step 3. When the value is 8, it means the HMAC module is in upstream mode, proceed with step 4.
3. Downstream mode
11. (a) Poll Status register HMAC\_QUERY\_BUSY\_REG until it reads 0.
12. (b) To clear the result and make further usage of the dependent hardware (JTAG or DS) impossible, write 1 to either register HMAC\_SET\_INVALIDATE\_JTAG\_REG to clear the result generated by the JTAG key; or to register HMAC\_SET\_INVALIDATE\_DS\_REG to clear the result generated by DS key. Afterwards, the HMAC Process needs to be restarted to re-enable any of the dependent peripherals.
4. Transmit message block Block\_n (n &gt;= 1) in upstream mode
14. (a) Poll Status register HMAC\_QUERY\_BUSY\_REG until it reads 0.
15. (b) Write the 512-bit Block\_n to register HMAC\_WDATA0~15\_REG. Write 1 to register HMAC\_SET\_MESSAGE\_ONE\_REG, to trigger the processing of this message block.

- (c) Poll Status register HMAC\_QUERY\_BUSY\_REG until it reads 0.
- (d) Different message blocks will be generated, depending on whether the size of the to-be-processed message is a multiple of 512 bits.
- If the bit length of the message is a multiple of 512 bits, there are three possible options:
- i. If Block\_n+1 exists, write 1 to register HMAC\_SET\_MESSAGE\_ING\_REG to make n = n + 1 , and then jump to step 4.(b).
- ii. If Block\_n is the last block of the message and users expects to apply SHA padding in hardware, write 1 to register HMAC\_SET\_MESSAGE\_END\_REG, and then jump to step 6.
- iii. If Block\_n is the last block of the padded message and SHA padding has been applied by users, write 1 to register HMAC\_SET\_MESSAGE\_PAD\_REG, and then jump to step 5.
- If the bit length of the message is not a multiple of 512 bits, there are three possible options as follows. Note that in this case, the user is required to apply SHA padding to the message, after which the padded message length should be a multiple of 512 bits.
- i. If there is only one message block in total which has included all padding bits, write 1 to register HMAC\_ONE\_BLOCK\_REG, and then jump to step 6.
- ii. If Block\_n is the second last padded block, write 1 to register HMAC\_SET\_MESSAGE\_PAD\_REG, and then jump to step 5.
- iii. If Block\_n is neither the last nor the second last message block, write 1 to register HMAC\_SET\_MESSAGE\_ING\_REG and define n = n + 1, and then jump to step 4.(b).
5. Apply SHA padding to message
- (a) Users apply SHA padding to the last message block as described in Section 19.3.1, write this block to register HMAC\_WDATA0 ~ 15\_REG, and then write 1 to register HMAC\_SET\_MESSAGE\_ONE\_REG . Then the HMAC module will process this message block.
- (b) Jump to step 6.
6. Read hash result in upstream mode
- (a) Poll Status register HMAC\_QUERY\_BUSY\_REG until it reads 0.
- (b) Read hash result from register HMAC\_RDATA0~7\_REG.
- (c) Write 1 to register HMAC\_SET\_RESULT\_FINISH\_REG to finish calculation. The result will be cleared at the same time.
- (d) Upstream mode operation is completed.

## Note:

The SHA accelerator can be called directly, or used internally by the DS module and the HMAC module. However, they can not share the hardware resources simultaneously. Therefore, the SHA module must not be called neither by the CPU nor by the DS module when the HMAC module is in use.

## 19.3 HMAC Algorithm Details

## 19.3.1 Padding Bits

The HMAC module uses SHA-256 as hash algorithm. If the input message is not a multiple of 512 bits, the user must apply a SHA-256 padding algorithm in software. The SHA-256 padding algorithm is the same as described in Section Padding the Message of FIPS PUB 180-4. In downstream mode, users do not need to input any message or apply padding. The HMAC module uses a default 32-byte pattern of 0x00 for re-enabling JTAG and a 32-byte pattern of 0xff for deriving the AES key for the DS module.

As shown in Figure 19.3-1, suppose the length of the unpadded message is m bits. Padding steps are as follows:

1. Append one bit of value “1” to the end of the unpadded message;
2. Append k bits of value "0", where k is the smallest non-negative number which satisfies m + 1 + k≡448(mod512);
3. Append a 64-bit integer value as a binary block. This block consists of the length of the unpadded message as a big-endian binary integer value m .

Figure 19.3-1. HMAC SHA-256 Padding Diagram

![Image](images/19_Chapter_19_img001_11de013c.png)

In upstream mode, if the length of the unpadded message is a multiple of 512 bits, users can configure hardware to apply SHA padding by writing 1 to HMAC\_SET\_MESSGAE\_END\_REG or do padding work themselves by writing 1 to HMAC\_SET\_MESSAGE\_PAD\_REG. If the length is not a multiple of 512 bits, SHA padding must be manually applied by the user. After the user prepared the padding data, they should complete the subsequent configuration according to the Section 19.2.5 .

## 19.3.2 HMAC Algorithm Structure

The structure of the implemented algorithm in the HMAC module is shown in Figure 19.3-2. This is the standard HMAC algorithm as described in RFC 2104.

![Image](images/19_Chapter_19_img002_1b2069f2.png)

![Image](images/19_Chapter_19_img003_bad38350.png)

Figure 19.3-2. HMAC Structure Schematic Diagram

![Image](images/19_Chapter_19_img004_0defd472.png)

## In Figure 19.3-2:

1. ipad is a 512-bit message block composed of 64 bytes of 0x36.
2. opad is a 512-bit message block composed of 64 bytes of 0x5c.

The HMAC module appends a 256-bit 0 sequence after the bit sequence of the 256-bit key k in order to get a 512-bit K 0 . Then, the HMAC module XORs K 0 with ipad to get the 512-bit S1. Afterwards, the HMAC module appends the input message (multiple of 512 bits) after the 512-bit S1, and exercises the SHA-256 algorithm to get the 256-bit H1.

The HMAC module appends the 256-bit SHA-256 hash result H1 to the 512-bit S2 value, which is calculated using the XOR operation of K0 and opad. A 768-bit sequence will be generated. Then, the HMAC module uses the SHA padding algorithm described in Section 19.3.1 to pad the 768-bit sequence to a 1024-bit sequence, and applies the SHA-256 algorithm to get the final hash result (256-bit).

## 19.4 Register Summary

The addresses in this section are relative to HMAC Accelerator base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                         | Description                                                                          | Address   | Access   |
|------------------------------|--------------------------------------------------------------------------------------|-----------|----------|
| Control/Status Registers     |                                                                                      |           |          |
| HMAC_SET_START_REG           | HMAC start control register                                                          | 0x0040    | WO       |
| HMAC_SET_PARA_FINISH_REG     | HMAC configuration completion register                                               | 0x004C    | WO       |
| HMAC_SET_MESSAGE_ONE_REG     | HMAC message control register                                                        | 0x0050    | WO       |
| HMAC_SET_MESSAGE_ING_REG     | HMAC message continue register                                                       | 0x0054    | WO       |
| HMAC_SET_MESSAGE_END_REG     | HMAC message end register                                                            | 0x0058    | WO       |
| HMAC_SET_RESULT_FINISH_REG   | HMAC result reading finish register                                                  | 0x005C    | WO       |
| HMAC_SET_INVALIDATE_JTAG_REG | Invalidate JTAG result register                                                      | 0x0060    | WO       |
| HMAC_SET_INVALIDATE_DS_REG   | Invalidate digital signature result register                                         | 0x0064    | WO       |
| HMAC_QUERY_ERROR_REG         | Stores matching results between keys gener ated by users and corresponding purposes | 0x0068    | RO       |
| HMAC_QUERY_BUSY_REG          | Busy state of HMAC module                                                            | 0x006C    | RO       |
| configuration Registers      |                                                                                      |           |          |
| HMAC_SET_PARA_PURPOSE_REG    | HMAC parameter configuration register                                                | 0x0044    | WO       |
| HMAC_SET_PARA_KEY_REG        | HMAC parameters configuration register                                               | 0x0048    | WO       |
| HMAC_SOFT_JTAG_CTRL_REG      | Re-enable JTAG register 0                                                            | 0x00F8    | WO       |
| HMAC_WR_JTAG_REG             | Re-enable JTAG register 1                                                            | 0x00FC    | WO       |
| HMAC Message Block           |                                                                                      |           |          |
| HMAC_WR_MESSAGE_0_REG        | Message register 0                                                                   | 0x0080    | WO       |
| HMAC_WR_MESSAGE_1_REG        | Message register 1                                                                   | 0x0084    | WO       |
| HMAC_WR_MESSAGE_2_REG        | Message register 2                                                                   | 0x0088    | WO       |
| HMAC_WR_MESSAGE_3_REG        | Message register 3                                                                   | 0x008C    | WO       |
| HMAC_WR_MESSAGE_4_REG        | Message register 4                                                                   | 0x0090    | WO       |
| HMAC_WR_MESSAGE_5_REG        | Message register 5                                                                   | 0x0094    | WO       |
| HMAC_WR_MESSAGE_6_REG        | Message register 6                                                                   | 0x0098    | WO       |
| HMAC_WR_MESSAGE_7_REG        | Message register 7                                                                   | 0x009C    | WO       |
| HMAC_WR_MESSAGE_8_REG        | Message register 8                                                                   | 0x00A0    | WO       |
| HMAC_WR_MESSAGE_9_REG        | Message register 9                                                                   | 0x00A4    | WO       |
| HMAC_WR_MESSAGE_10_REG       | Message register 10                                                                  | 0x00A8    | WO       |
| HMAC_WR_MESSAGE_11_REG       | Message register 11                                                                  | 0x00AC    | WO       |
| HMAC_WR_MESSAGE_12_REG       | Message register 12                                                                  | 0x00B0    | WO       |
| HMAC_WR_MESSAGE_13_REG       | Message register 13                                                                  | 0x00B4    | WO       |
| HMAC_WR_MESSAGE_14_REG       | Message register 14                                                                  | 0x00B8    | WO       |
| HMAC_WR_MESSAGE_15_REG       | Message register 15                                                                  | 0x00BC    | WO       |
| HMAC Upstream Result         |                                                                                      |           |          |
| HMAC_RD_RESULT_0_REG         | Hash result register 0                                                               | 0x00C0    | RO       |
| HMAC_RD_RESULT_1_REG         | Hash result register 1                                                               | 0x00C4    | RO       |

| Name                     | Description                | Address   | Access   |
|--------------------------|----------------------------|-----------|----------|
| HMAC_RD_RESULT_2_REG     | Hash result register 2     | 0x00C8    | RO       |
| HMAC_RD_RESULT_3_REG     | Hash result register 3     | 0x00CC    | RO       |
| HMAC_RD_RESULT_4_REG     | Hash result register 4     | 0x00D0    | RO       |
| HMAC_RD_RESULT_5_REG     | Hash result register 5     | 0x00D4    | RO       |
| HMAC_RD_RESULT_6_REG     | Hash result register 6     | 0x00D8    | RO       |
| HMAC_RD_RESULT_7_REG     | Hash result register 7     | 0x00DC    | RO       |
| Control/Status Registers |                            |           |          |
| HMAC_SET_MESSAGE_PAD_REG | Software padding register  | 0x00F0    | WO       |
| HMAC_ONE_BLOCK_REG       | One block message register | 0x00F4    | WO       |
| Version Register         |                            |           |          |
| HMAC_DATE_REG            | Version control register   | 0x00F8    | R/W      |

## 19.5 Registers

The addresses in this section are relative to HMAC Accelerator base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 19.1. HMAC\_SET\_START\_REG (0x0040)

![Image](images/19_Chapter_19_img005_a64875ac.png)

Register 19.4. HMAC\_SET\_MESSAGE\_ING\_REG (0x0054)

![Image](images/19_Chapter_19_img006_d467beea.png)

![Image](images/19_Chapter_19_img007_ed2c2c72.png)

## Register 19.10. HMAC\_QUERY\_BUSY\_REG (0x006C)

![Image](images/19_Chapter_19_img008_576f3e71.png)

HMAC\_BUSY\_STATE Indicates whether HMAC is in busy state. Before configuring HMAC, please make sure HMAC is in IDLE state. (RO)

- 0: idle.
- 1: HMAC is still working on calculation.

## Register 19.11. HMAC\_SET\_PARA\_PURPOSE\_REG (0x0044)

![Image](images/19_Chapter_19_img009_e561ff75.png)

HMAC\_PURPOSE\_SET Determines the HMAC purpose, refer to the Table 19.2-1. (WO)

## Register 19.12. HMAC\_SET\_PARA\_KEY\_REG (0x0048)

![Image](images/19_Chapter_19_img010_2f71569a.png)

HMAC\_KEY\_SET Selects HMAC key. There are six keys with index 0 ~ 5. Write the index of the selected key to this field. (WO)

![Image](images/19_Chapter_19_img011_f73a1382.png)

![Image](images/19_Chapter_19_img012_3ce70c7f.png)
