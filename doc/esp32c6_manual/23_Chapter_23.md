---
chapter: 23
title: "Chapter 23"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 23

## SHA Accelerator (SHA)

## 23.1 Introduction

ESP32-C6 integrates an SHA accelerator, which is a hardware device that speeds up the SHA algorithm significantly, compared to a SHA algorithm implemented solely in software. The SHA accelerator integrated in ESP32-C6 has two working modes, which are Typical SHA and DMA-SHA .

## 23.2 Features

The following functionality is supported:

- The following hash algorithms introduced in FIPS PUB 180-4 Spec .
- – SHA-1
- – SHA-224
- – SHA-256
- Two working modes
- – Typical SHA
- – DMA-SHA
- Interleaved function when working in Typical SHA working mode
- Interrupt function when working in DMA-SHA working mode

## 23.3 Working Modes

The SHA accelerator integrated in ESP32-C6 has two working modes.

- Typical SHA Working Mode: all the data is written and read via CPU directly.
- DMA-SHA Working Mode: all the data is read via DMA. That is, users can configure the DMA controller to read all the data needed for hash operation, thus releasing CPU for completing other tasks.

The SHA accelerator is activated by setting the PCR\_SHA\_CLK\_EN bit and clearing the PCR\_SHA\_RST\_EN bit in the PCR\_SHA\_CONF\_REG register. Additionally, users also need to clear PCR\_DS\_RST\_EN and PCR\_HMAC\_RST\_EN bits to reset Digital Signature (DS) and HMAC Accelerator (HMAC) .

Users can start the SHA accelerator with different working modes by configuring registers SHA\_START\_REG and SHA\_DMA\_START\_REG. For details, please see Table 23.3-1 .

Table 23.3-1. SHA Accelerator Working Mode

| Working Mode   | Configuration Method       |
|----------------|----------------------------|
| Typical SHA    | Set SHA_START_REG to 1     |
| DMA-SHA        | Set SHA_DMA_START_REG to 1 |

ESP32-C6 TRM (Version 1.1)

Users can choose hash algorithms by configuring the SHA\_MODE\_REG register. For details, please see Table 23.3-2 .

Table 23.3-2. SHA Hash Algorithm Selection

| Hash Algorithm   |   SHA_MODE_REG Configuration |
|------------------|------------------------------|
| SHA-1            |                            0 |
| SHA-224          |                            1 |
| SHA-256          |                            2 |

## Notice:

ESP32-C6's Digital Signature (DS) and HMAC Accelerator (HMAC) modules also call the SHA accelerator. Therefore, users cannot access the SHA accelerator when these modules are working.

## 23.4 Function Description

The SHA accelerator generates the message digest via two steps: Preprocessing and Hash operation .

## 23.4.1 Preprocessing

Preprocessing consists of three steps: padding the message , parsing the message into message blocks and setting the initial hash value .

## 23.4.1.1 Padding the Message

The SHA accelerator can only process message blocks of 512 bits. Thus, all the messages should be padded to a multiple of 512 bits before the hash operation.

Suppose that the length of the message M is m bits. Then M shall be padded as introduced below:

1. First, append the bit “1” to the end of the message;
2. Second, append k bits of zeros, where k is the smallest, non-negative solution to the equation m + 1 + k ≡ 448 mod 512;
3. Last, append the 64-bit block of value equal to the number m expressed using a binary representation.

For more details, please refer to FIPS PUB 180-4 Spec &gt; Section “Padding the Message”.

## 23.4.1.2 Parsing the Message

The message and its padding must be parsed into N 512-bit blocks, M(1) , M(2) , …, M(N). Since the 512 bits of the input block may be expressed as sixteen 32-bit words, the first 32 bits of message block i are denoted M
(i)
0 0 , the next 32 bits are M (i) 1 , and so on up to M (i) 15 .

During the task, all the message blocks are written into the SHA\_M\_n\_REG: M (i) 0 is stored in SHA\_M\_0\_REG , M
(i)
1 1 stored in SHA\_M\_1\_REG, …, and M (i) 15 stored in SHA\_M\_15\_REG .

## Note:

For more information about "message block", please refer to FIPS PUB 180-4 Spec &gt; Section "Glossary of Terms and Acronyms".

## 23.4.1.3 Setting the Initial Hash Value

Before hash operation begins for any secure hash algorithms, the initial Hash value H(0) must be set based on different algorithms. However, the SHA accelerator uses the initial Hash values (constant C) stored in the hardware for hash tasks.

## 23.4.2 Hash Operation

After the preprocessing, the ESP32-C6 SHA accelerator starts to hash a message M and generates message digest of different lengths, depending on different hash algorithms. As described above, the ESP32-C6 SHA accelerator supports two working modes, which are Typical SHA and DMA-SHA. The operation process for the SHA accelerator under two working modes is described in the following subsections.

## 23.4.2.1 Typical SHA Mode Process

Usually, the SHA accelerator will process all blocks of a message and produce a message digest before starting the computation of the next message digest.

However, ESP32-C6 SHA also supports optional "interleaved" message digest calculation in Typical SHA mode, which means before SHA completes all blocks of the current message, users are given a chance to insert new computation of another message digest upon the completion of each individual block of the current message.

Specifically, users can read out the message digest from registers SHA\_H\_n\_REG after completing part of a message digest calculation, and use the SHA accelerator for a different calculation. After the different calculation completes, users can restore the previous message digest to registers SHA\_H\_n\_REG, and resume the accelerator with the previously paused calculation.

## Typical SHA Process

1. Select a hash algorithm.
- Configure the SHA\_MODE\_REG register based on Table 23.3-2 .
2. Process the current message block.
- Write the message block in registers SHA\_M\_n\_REG .
3. Start the SHA accelerator1 .
- If this is the first time to execute this step, set the SHA\_START\_REG register to 1 to start the SHA accelerator. In this case, the accelerator uses the initial hash value stored in hardware for a given algorithm configured in Step 1 to start the calculation;
- If this is not the first time to execute this step 2 , set the SHA\_CONTINUE\_REG register to 1 to start the SHA accelerator. In this case, the accelerator uses the hash value stored in the SHA\_H\_n\_REG register to start calculation.

4. Check the progress of the current message block.
- Poll register SHA\_BUSY\_REG until the content of this register becomes 0, indicating the accelerator has completed the calculation for the current message block and now is in the "idle" status 3 .
5. Decide if you have more message blocks to process:
- If yes, please go back to Step 2 .
- Otherwise, please continue.
6. Obtain the message digest.
- Read the message digest from registers SHA\_H\_n\_REG .

## Note:

1. In this step, the software can also write the next message block (to be processed) in registers SHA\_M\_n\_REG , if any, while the hardware starts SHA calculation, to save time.
2. You are resuming the SHA accelerator with the previously paused calculation.
3. Here you can decide if you want to insert other calculations. If yes, please go to the process for interleaved calculations for details.

As mentioned above, ESP32-C6 SHA accelerator supports "interleaving" calculation under the Typical SHA working mode .

The process to implement interleaved calculation is described below.

1. Prepare to hand the SHA accelerator over for an interleaved calculation by storing the following data of the previous calculation.
- The selected hash algorithm configured in the SHA\_MODE\_REG register.
- The message digest stored in registers SHA\_H\_n\_REG .
2. Perform the interleaved calculation. For the detailed process of the interleaved calculation, please refer to Typical SHA process or DMA-SHA process, depending on the working mode of your interleaved calculation.
3. Prepare to hand the SHA accelerator back to the previously paused calculation by restoring the following data of the previous calculation.
- Write the previously stored hash algorithm back to register SHA\_MODE\_REG .
- Write the previously stored message digest back to registers SHA\_H\_n\_REG .
4. Write the next message block from the previous paused calculation in registers SHA\_M\_n\_REG, and set the SHA\_CONTINUE\_REG register to 1 to restart the SHA accelerator with the previously paused calculation.

## 23.4.2.2 DMA-SHA Mode Process

ESP32-C6 SHA accelerator does not support "interleaving" message digest calculation at the level of individual message blocks when using DMA, which means you cannot insert new calculation before a complete DMA-SHA process (of one or more message blocks) completes. In this case, users who need

interleaved operation are recommended to divide the message blocks and perform several DMA-SHA calculations, instead of trying to compute all the messages in one go.

Single DMA-SHA calculation supports up to 63 data blocks.

In contrast to the Typical SHA working mode, when the SHA accelerator is working under the DMA-SHA mode, all data read are completed via DMA. Therefore, users are required to configure the DMA controller following the description in Chapter 4 GDMA Controller (GDMA) .

## DMA-SHA process

1. Select a hash algorithm.
- Select a hash algorithm by configuring the SHA\_MODE\_REG register. For details, please refer to Table 23.3-2 .
2. Configure the SHA\_IRQ\_ENA\_REG register to enable or disable interrupt (Set 1 to enable).
3. Configure the number of message blocks.
- Write the number of message blocks M to the SHA\_DMA\_BLOCK\_NUM\_REG register.
4. Start the DMA-SHA calculation.
- If the current DMA-SHA calculation follows a previous calculation, firstly write the message digest from the previous calculation to registers SHA\_H\_n\_REG, then write 1 to register SHA\_DMA\_CONTINUE\_REG to start SHA accelerator;
- Otherwise, write 1 to register SHA\_DMA\_START\_REG to start the accelerator.
5. Wait till the completion of the DMA-SHA calculation, which happens when:
- The content of SHA\_BUSY\_REG register becomes 0, or
- An SHA interrupt occurs. In this case, please clear interrupt by writing 1 to the SHA\_CLEAR\_IRQ\_REG register.
6. Obtain the message digest:
- Read the message digest from registers SHA\_H\_n\_REG .

## 23.4.3 Message Digest

After the hash task completes, the SHA accelerator writes the message digest from the task to registers SHA\_H\_n\_REG(n: 0~7). The lengths of the generated message digest are different depending on different hash algorithms. For details, see Table 23.4-1 below:

![Image](images/23_Chapter_23_img001_257253bb.png)

Table 23.4-1. The Storage and Length of Message Digest from Different Algorithms

| Hash Algorithm   |   Length of Message Digest (in bits) | Storage 1                   |
|------------------|--------------------------------------|-----------------------------|
| SHA-1            |                                  160 | SHA_H_0_REG  ~  SHA_H_4_REG |
| SHA-224          |                                  224 | SHA_H_0_REG  ~  SHA_H_6_REG |
| SHA-256          |                                  256 | SHA_H_0_REG  ~  SHA_H_7_REG |

## 23.4.4 Interrupt

When working in the DMA-SHA mode, SHA supports interrupt on the completion of message digest calculation.

- To enable this function: write 1 to register SHA\_IRQ\_ENA\_REG .
- Note that the interrupt should be cleared by software after use via setting the SHA\_CLEAR\_IRQ\_REG register to 1.

When working in the Typical SHA mode, SHA completes the calculation quick fast, so interrupt is not necessary. Therefore, SHA does not support interrupt in the Typical SHA mode.

## 23.5 Register Summary

The addresses in this section are relative to the SHA accelerator base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                            | Description                                                  | Address                         | Access                          |
|---------------------------------|--------------------------------------------------------------|---------------------------------|---------------------------------|
| Control/Configuration Registers | Control/Configuration Registers                              | Control/Configuration Registers | Control/Configuration Registers |
| SHA_MODE_REG                    | Configures SHA algorithm                                     | 0x0000                          | R/W                             |
| SHA_CONTINUE_REG                | Continues SHA operation (only effective in Typical SHA mode) | 0x0014                          | WO                              |
| SHA_DMA_START_REG               | Starts the SHA accelerator for DMA-SHA operation             | 0x001C                          | WO                              |
| SHA_START_REG                   | Starts the SHA accelerator for Typical SHA operation         | 0x0010                          | WO                              |
| SHA_DMA_CONTINUE_REG            | Continues SHA operation (only effective in DMA-SHA mode)     | 0x0020                          | WO                              |
| SHA_DMA_BLOCK_NUM_REG           | Block number register (only effective for DMA-SHA)           | 0x000C                          | R/W                             |
| Status Registers                | Status Registers                                             | Status Registers                | Status Registers                |
| SHA_BUSY_REG                    | Represents if SHA Accelerator is busy or not                 | 0x0018                          | RO                              |
| Interrupt Registers             | Interrupt Registers                                          | Interrupt Registers             | Interrupt Registers             |
| SHA_CLEAR_IRQ_REG               | DMA-SHA interrupt clear register                             | 0x0024                          | WO                              |
| SHA_IRQ_ENA_REG                 | DMA-SHA interrupt enable register                            | 0x0028                          | R/W                             |
| Data Registers                  | Data Registers                                               | Data Registers                  | Data Registers                  |
| SHA_H_0_REG                     | Hash value                                                   | 0x0040                          | R/W                             |
| SHA_H_1_REG                     | Hash value                                                   | 0x0044                          | R/W                             |
| SHA_H_2_REG                     | Hash value                                                   | 0x0048                          | R/W                             |
| SHA_H_3_REG                     | Hash value                                                   | 0x004C                          | R/W                             |
| SHA_H_4_REG                     | Hash value                                                   | 0x0050                          | R/W                             |
| SHA_H_5_REG                     | Hash value                                                   | 0x0054                          | R/W                             |
| SHA_H_6_REG                     | Hash value                                                   | 0x0058                          | R/W                             |
| SHA_H_7_REG                     | Hash value                                                   | 0x005C                          | R/W                             |
| SHA_M_0_REG                     | Message                                                      | 0x0080                          | R/W                             |
| SHA_M_1_REG                     | Message                                                      | 0x0084                          | R/W                             |
| SHA_M_2_REG                     | Message                                                      | 0x0088                          | R/W                             |
| SHA_M_3_REG                     | Message                                                      | 0x008C                          | R/W                             |
| SHA_M_4_REG                     | Message                                                      | 0x0090                          | R/W                             |
| SHA_M_5_REG                     | Message                                                      | 0x0094                          | R/W                             |
| SHA_M_6_REG                     | Message                                                      | 0x0098                          | R/W                             |
| SHA_M_7_REG                     | Message                                                      | 0x009C                          | R/W                             |
| SHA_M_8_REG                     | Message                                                      | 0x00A0                          | R/W                             |
| SHA_M_9_REG                     | Message                                                      | 0x00A4                          | R/W                             |
| SHA_M_10_REG                    | Message                                                      | 0x00A8                          | R/W                             |
| SHA_M_11_REG                    | Message                                                      | 0x00AC                          | R/W                             |
| SHA_M_12_REG                    | Message                                                      | 0x00B0                          | R/W                             |
| SHA_M_13_REG                    | Message                                                      | 0x00B4                          | R/W                             |
| SHA_M_14_REG                    | Message                                                      | 0x00B8                          | R/W                             |
| SHA_M_15_REG                    | Message                                                      | 0x00BC                          | R/W                             |

![Image](images/23_Chapter_23_img002_2ff81bb8.png)

| Name             | Description              | Address   | Access   |
|------------------|--------------------------|-----------|----------|
| Version Register |                          |           |          |
| SHA_DATE_REG     | Version control register | 0x002C    | R/W      |

## 23.6 Registers

![Image](images/23_Chapter_23_img003_fc1239ee.png)

![Image](images/23_Chapter_23_img004_4f410d5d.png)

## Register 23.8. SHA\_DATE\_REG (0x002C)

![Image](images/23_Chapter_23_img005_8cb24742.png)

Register 23.12. SHA\_M\_n\_REG (n: 0-15) (0x0080+4*n)

![Image](images/23_Chapter_23_img006_7b3018cf.png)

![Image](images/23_Chapter_23_img007_c4ec3070.png)

SHA\_M\_n Represents the nth 32-bit piece of the message. (R/W)
