---
chapter: 18
title: "Chapter 18"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 18

## AES Accelerator (AES)

## 18.1 Introduction

ESP32-C3 integrates an Advanced Encryption Standard (AES) Accelerator, which is a hardware device that speeds up AES Algorithm significantly, compared to AES algorithms implemented solely in software. The AES Accelerator integrated in ESP32-C3 has two working modes, which are Typical AES and DMA-AES .

## 18.2 Features

The following functionality is supported:

- Typical AES working mode
- – AES-128/AES-256 encryption and decryption
- DMA-AES working mode
- – AES-128/AES-256 encryption and decryption
- – Block cipher mode
* ECB (Electronic Codebook)
* CBC (Cipher Block Chaining)
* OFB (Output Feedback)
* CTR (Counter)
* CFB8 (8-bit Cipher Feedback)
* CFB128 (128-bit Cipher Feedback)
- – Interrupt on completion of computation

## 18.3 AES Working Modes

The AES Accelerator integrated in ESP32-C3 has two working modes, which are Typical AES and DMA-AES .

- Typical AES Working Mode:
- – Supports encryption and decryption using cryptographic keys of 128 and 256 bits, specified in NIST FIPS 197 .

In this working mode, the plaintext and ciphertext is written and read via CPU directly.

- DMA-AES Working Mode:
- – Supports encryption and decryption using cryptographic keys of 128 and 256 bits, specified in NIST FIPS 197;
- – Supports block cipher modes ECB/CBC/OFB/CTR/CFB8/CFB128 under NIST SP 800-38A .

In this working mode, the plaintext and ciphertext are written and read via DMA. An interrupt will be generated when operation completes.

Users can choose the working mode for AES accelerator by configuring the AES\_DMA\_ENABLE\_REG register according to Table 18.3-1 below.

Table 18.3-1. AES Accelerator Working Mode

|   AES_DMA_ENABLE_REG | Working Mode   |
|----------------------|----------------|
|                    0 | Typical AES    |
|                    1 | DMA-AES        |

Users can choose the length of cryptographic keys and encryption / decryption by configuring the AES\_MODE\_REG register according to Table 18.3-2 below.

Table 18.3-2. Key Length and Encryption/Decryption

|   AES_MODE_REG[2:0] | Key Length and Encryption / Decryption   |
|---------------------|------------------------------------------|
|                   0 | AES-128 encryption                       |
|                   1 | reserved                                 |
|                   2 | AES-256 encryption                       |
|                   3 | reserved                                 |
|                   4 | AES-128 decryption                       |
|                   5 | reserved                                 |
|                   6 | AES-256 decryption                       |
|                   7 | reserved                                 |

For detailed introduction on these two working modes, please refer to Section 18.4 and Section 18.5 below.

## Notice:

ESP32-C3's Digital Signature (DS) module will call the AES accelerator. Therefore, users cannot access the AES accelerator when Digital Signature (DS) module is working.

## 18.4 Typical AES Working Mode

In the Typical AES working mode, users can check the working status of the AES accelerator by inquiring the AES\_STATE\_REG register and comparing the return value against the Table 18.4-1 below.

Table 18.4-1. Working Status under Typical AES Working Mode

|   AES_STATE_REG | Status   | Description                                           |
|-----------------|----------|-------------------------------------------------------|
|               0 | IDLE     | The AES accelerator is idle or completed operation.   |
|               1 | WORK     | The AES accelerator is in the middle of an operation. |

## 18.4.1 Key, Plaintext, and Ciphertext

The encryption or decryption key is stored in AES\_KEY\_n\_REG, which is a set of eight 32-bit registers.

- For AES-128 encryption/decryption, the 128-bit key is stored in AES\_KEY\_0\_REG ~ AES\_KEY\_3\_REG .
- For AES-256 encryption/decryption, the 256-bit key is stored in AES\_KEY\_0\_REG ~ AES\_KEY\_7\_REG .

The plaintext and ciphertext are stored in AES\_TEXT\_IN\_m\_REG and AES\_TEXT\_OUT\_m\_REG, which are two sets of four 32-bit registers.

- For AES-128/AES-256 encryption, the AES\_TEXT\_IN\_m\_REG registers are initialized with plaintext. Then, the AES Accelerator stores the ciphertext into AES\_TEXT\_OUT\_m\_REG after operation.
- For AES-128/AES-256 decryption, the AES\_TEXT\_IN\_m\_REG registers are initialized with ciphertext. Then, the AES Accelerator stores the plaintext into AES\_TEXT\_OUT\_m\_REG after operation.

## 18.4.2 Endianness

## Text Endianness

In Typical AES working mode, the AES Accelerator uses cryptographic keys to encrypt and decrypt data in blocks of 128 bits. When filling data into AES\_TEXT\_IN\_m\_REG register or reading result from AES\_TEXT\_OUT\_m\_REG registers, users should follow the text endianness type specified in Table 18.4-2 .

Table 18.4-2. Text Endianness Type for Typical AES

| Plaintext/Ciphertext   | Plaintext/Ciphertext    | Plaintext/Ciphertext    | Plaintext/Ciphertext    | Plaintext/Ciphertext    |
|------------------------|-------------------------|-------------------------|-------------------------|-------------------------|
| State 1                | c 2                     | c 2                     | c 2                     | c 2                     |
| 0                      | 0                       |                         | 1  2                    | 3                       |
| 0                      | AES_TEXT_x_0_REG[7:0]   | AES_TEXT_x_1_REG[7:0]   | AES_TEXT_x_2_REG[7:0]   | AES_TEXT_x_3_REG[7:0]   |
| 1                      | AES_TEXT_x_0_REG[15:8]  | AES_TEXT_x_1_REG[15:8]  | AES_TEXT_x_2_REG[15:8]  | AES_TEXT_x_3_REG[15:8]  |
| 2                      | AES_TEXT_x_0_REG[23:16] | AES_TEXT_x_1_REG[23:16] | AES_TEXT_x_2_REG[23:16] | AES_TEXT_x_3_REG[23:16] |
| 3                      | AES_TEXT_x_0_REG[31:24] | AES_TEXT_x_1_REG[31:24] | AES_TEXT_x_2_REG[31:24] | AES_TEXT_x_3_REG[31:24] |

Key Endianness

and Table

18.4-3

registers, users should follow the key endianness type specified in Table

\_REG

m

AES\_KEY\_

In Typical AES working mode, when filling key into

|                                                         | w[2]                   |         |
|---------------------------------------------------------|------------------------|---------|
|                                                         |                        | [31:24] |
| AES_KEY_0_REG AES_KEY_0_REG AES_KEY_0_REG AES_KEY_0_REG | [7:0]  [15:8]  [23:16] |         |

Chapter 18 AES Accelerator (AES)

[7:0]

[31:24]

[23:16]

[15:8]

Table 18.4-3. Key Endianness Type for AES-128 Encryption and Decryption

2

w[3]

w[2]

w[1]

w[0]

AES\_KEY\_3\_REG

AES\_KEY\_2\_REG

[7:0]

AES\_KEY\_1\_REG

[7:0]

AES\_KEY\_3\_REG

AES\_KEY\_2\_REG

[15:8]

AES\_KEY\_1\_REG

[15:8]

AES\_KEY\_3\_REG

AES\_KEY\_2\_REG

[23:16]

AES\_KEY\_1\_REG

[23:16]

AES\_KEY\_3\_REG

AES\_KEY\_2\_REG

[23:16]

AES\_KEY\_7\_REG

[23:16]

AES\_KEY\_6\_REG

[31:24]

AES\_KEY\_7\_REG

[31:24]

AES\_KEY\_6\_REG

[15:8]

AES\_KEY\_7\_REG

[15:8]

AES\_KEY\_6\_REG

[7:0]

AES\_KEY\_7\_REG

[7:0]

AES\_KEY\_6\_REG

2

w[7]

w[6]

FIPS

NIST

w[3] are “the first Nk words of the expanded key” as specified in Section 5.2 Key Expansion in

Table 18.4-4. Key Endianness Type for AES-256 Encryption and Decryption

[23:16]

[15:8]

[31:24]

[7:0]

[7:0] [15:8] [23:16] [31:24] w[5] AES\_KEY\_5\_REG AES\_KEY\_5\_REG AES\_KEY\_5\_REG AES\_KEY\_5\_REG NIST FIPS

[7:0] [15:8] [23:16] [31:24]

AES\_KEY\_4\_REG

AES\_KEY\_4\_REG

AES\_KEY\_4\_REG

AES\_KEY\_4\_REG

AES\_KEY\_1\_REG w[3] AES\_KEY\_3\_REG AES\_KEY\_3\_REG AES\_KEY\_3\_REG AES\_KEY\_3\_REG w[7].

[31:24]

| ~  w[3].   | w[4]   |                          |
|------------|--------|--------------------------|
| [31:24]    | [7:0]  | [15:8]  [23:16]  [31:24] |

[7:0]

[31:24]

[23:16]

[15:8]

AES\_KEY\_2\_REG AES\_KEY\_2\_REG AES\_KEY\_2\_REG AES\_KEY\_2\_REG

~

Bit 1 [31:24] [23:16] [15:8] [7:0] 1 2 197 [7:0] [15:8] [23:16] [31:24]

w[0] . w[1] AES\_KEY\_1\_REG AES\_KEY\_1\_REG AES\_KEY\_1\_REG AES\_KEY\_1\_REG

w[0]

1

Bit

AES\_KEY\_0\_REG

AES\_KEY\_0\_REG

[31:24]

[23:16]

AES\_KEY\_0\_REG

[15:8]

AES\_KEY\_0\_REG

[7:0]

~

Column “Bit” specifies the bytes of each word stored in w[0]

1

476

Submit Documentation Feedback

Column “Bit” specifies the bytes of each word stored in w[0]

w[7] are “the first Nk words of the expanded key” as specified in Chapter 5.2 Key Expansion in

~

w[0]

2

.

18.4-4

Espressif Systems

.

197

GoBack

ESP32-C3 TRM (Version 1.3)

## 18.4.3 Operation Process

## Single Operation

1. Write 0 to the AES\_DMA\_ENABLE\_REG register.
2. Initialize registers AES\_MODE\_REG , AES\_KEY\_n\_REG , AES\_TEXT\_IN\_m\_REG .
3. Start operation by writing 1 to the AES\_TRIGGER\_REG register.
4. Wait till the content of the AES\_STATE\_REG register becomes 0, which indicates the operation is completed.
5. Read results from the AES\_TEXT\_OUT\_m\_REG register.

## Consecutive Operations

In consecutive operations, primarily the input AES\_TEXT\_IN\_m\_REG and output AES\_TEXT\_OUT\_m\_REG registers are being written and read, while the content of AES\_DMA\_ENABLE\_REG , AES\_MODE\_REG , AES\_KEY\_n\_REG is kept unchanged. Therefore, the initialization can be simplified during the consecutive operation.

1. Write 0 to the AES\_DMA\_ENABLE\_REG register before starting the first operation.
2. Initialize registers AES\_MODE\_REG and AES\_KEY\_n\_REG before starting the first operation.
3. Update the content of AES\_TEXT\_IN\_m\_REG .
4. Start operation by writing 1 to the AES\_TRIGGER\_REG register.
5. Wait till the content of the AES\_STATE\_REG register becomes 0, which indicates the operation completes.
6. Read results from the AES\_TEXT\_OUT\_m\_REG register, and return to Step 3 to continue the next operation.

## 18.5 DMA-AES Working Mode

In the DMA-AES working mode, the AES accelerator supports six block cipher modes including ECB/CBC/OFB/CTR/CFB8/CFB128. Users can choose the block cipher mode by configuring the AES\_BLOCK\_MODE\_REG register according to Table 18.5-1 below.

Table 18.5-1. Block Cipher Mode

|   AES_BLOCK_MODE_REG[2:0] | Block Cipher Mode                |
|---------------------------|----------------------------------|
|                         0 | ECB (Electronic Codebook)        |
|                         1 | CBC (Cipher Block Chaining)      |
|                         2 | OFB (Output Feedback)            |
|                         3 | CTR (Counter)                    |
|                         4 | CFB8 (8-bit Cipher Feedback)     |
|                         5 | CFB128 (128-bit Cipher Feedback) |
|                         6 | reserved                         |
|                         7 | reserved                         |

Users can check the working status of the AES accelerator by inquiring the AES\_STATE\_REG register and comparing the return value against the Table 18.5-2 below.

Table 18.5-2. Working Status under DMA-AES Working mode

|   AES_STATE_REG[1:0] | Status   | Description                                           |
|----------------------|----------|-------------------------------------------------------|
|                    0 | IDLE     | The AES accelerator is idle.                          |
|                    1 | WORK     | The AES accelerator is in the middle of an operation. |
|                    2 | DONE     | The AES accelerator completed operations.             |

When working in the DMA-AES working mode, the AES accelerator supports interrupt on the completion of computation. To enable this function, write 1 to the AES\_INT\_ENA\_REG register. By default, the interrupt function is disabled. Also, note that the interrupt should be cleared by software after use.

## 18.5.1 Key, Plaintext, and Ciphertext

## Block Operation

During the block operations, the AES Accelerator reads source data from DMA, and write result data to DMA after the computation.

- For encryption, DMA reads plaintext from memory, then passes it to AES as source data. After computation, AES passes ciphertext as result data back to DMA to write into memory.
- For decryption, DMA reads ciphertext from memory, then passes it to AES as source data. After computation, AES passes plaintext as result data back to DMA to write into memory.

During block operations, the lengths of the source data and result data are the same. The total computation time is reduced because the DMA data operation and AES computation can happen concurrently.

The length of source data for AES Accelerator under DMA-AES working mode must be 128 bits or the integral multiples of 128 bits. Otherwise, trailing zeros will be added to the original source data, so the length of source data equals to the nearest integral multiples of 128 bits. Please see details in Table 18.5-3 below.

```
Function : TEXT-PADDING( ) Input : X, bit string. Output : Y = TEXT-PADDING(X), whose length is the nearest integral multiples of 128 bits. Steps Let us assume that X is a data-stream that can be split into n parts as following: X = X 1 ||X2|| · · · ||X n − 1 ||X n Here, the lengths of X1, X2 , · · · , X n − 1 all equal to 128 bits, and the length of X n is t (0<=t<=127). If t = 0, then TEXT-PADDING(X) = X; If 0 < t <= 127, define a 128-bit block, X ∗ n , and let X ∗ n = X n ||0 128 − t , then TEXT-PADDING(X) = X1||X2|| · · · ||X n − 1 ||X ∗ n = X||0 128 − t
```

Table 18.5-3. TEXT-PADDING

## 18.5.2 Endianness

Under the DMA-AES working mode, the transmission of source data and result data for AES Accelerator is solely controlled by DMA. Therefore, the AES Accelerator cannot control the Endianness of the source data and result data, but does have requirement on how these data should be stored in memory and on the length of the data.

For example, let us assume DMA needs to write the following data into memory at address 0x0280.

- Data represented in hexadecimal:
- – 0102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F20
- Data Length:
- – Equals to 2 blocks.

Then, this data will be stored in memory as shown in Table 18.5-4 below.

Table 18.5-4. Text Endianness for DMA-AES

| Address   | Byte   | Address   | Byte   | Address   | Byte   | Address   | Byte   |
|-----------|--------|-----------|--------|-----------|--------|-----------|--------|
| 0x0280    | 0x01   | 0x0281    | 0x02   | 0x0282    | 0x03   | 0x0283    | 0x04   |
| 0x0284    | 0x05   | 0x0285    | 0x06   | 0x0286    | 0x07   | 0x0287    | 0x08   |
| 0x0288    | 0x09   | 0x0289    | 0x0A   | 0x028A    | 0x0B   | 0x028B    | 0x0C   |
| 0x028C    | 0x0D   | 0x028D    | 0x0E   | 0x028E    | 0x0F   | 0x028F    | 0x10   |
| 0x0290    | 0x11   | 0x0291    | 0x12   | 0x0292    | 0x13   | 0x0293    | 0x14   |
| 0x0294    | 0x15   | 0x0295    | 0x16   | 0x0296    | 0x17   | 0x0297    | 0x18   |
| 0x0298    | 0x19   | 0x0299    | 0x1A   | 0x029A    | 0x1B   | 0x029B    | 0x1C   |
| 0x029C    | 0x1D   | 0x029D    | 0x1E   | 0x029E    | 0x1F   | 0x029F    | 0x20   |

## 18.5.3 Standard Incrementing Function

AES accelerator provides two Standard Incrementing Functions for the CTR block operation, which are INC32 and INC 128 Standard Incrementing Functions. By setting the AES\_INC\_SEL\_REG register to 0 or 1, users can choose the INC 32 or INC 128 functions respectively. For details on the Standard Incrementing Function, please see Chapter B.1 The Standard Incrementing Function in NIST SP 800-38A .

## 18.5.4 Block Number

Register AES\_BLOCK\_NUM\_REG stores the Block Number of plaintext P or ciphertext C. The length of this register equals to length(TEXT-PADDING(P))/128 or length(TEXT-PADDING(C))/128. The AES Accelerator only uses this register when working in the DMA-AES mode.

## 18.5.5 Initialization Vector

AES\_IV\_MEM is a 16-byte memory, which is only available for AES Accelerator working in block operations. For CBC/OFB/CFB8/CFB128 operations, the AES\_IV\_MEM memory stores the Initialization Vector (IV). For the CTR operation, the AES\_IV\_MEM memory stores the Initial Counter Block (ICB).

Both IV and ICB are 128-bit strings, which can be divided into Byte0, Byte1, Byte2 · · · Byte15 (from left to right). AES\_IV\_MEM stores data following the Endianness pattern presented in Table 18.5-4, i.e. the most significant (i.e., left-most) byte Byte0 is stored at the lowest address while the least significant (i.e., right-most) byte Byte15 at the highest address.

For more details on IV and ICB, please refer to NIST SP 800-38A .

## 18.5.6 Block Operation Process

1. Select one of DMA channels to connect with AES, configure the DMA chained list, and then start DMA. For details, please refer to Chapter 2 GDMA Controller (GDMA) .
2. Initialize the AES accelerator-related registers:
- Write 1 to the AES\_DMA\_ENABLE\_REG register.
- Configure the AES\_INT\_ENA\_REG register to enable or disable the interrupt function.
- Initialize registers AES\_MODE\_REG and AES\_KEY\_n\_REG .
- Select block cipher mode by configuring the AES\_BLOCK\_MODE\_REG register. For details, see Table 18.5-1 .
- Initialize the AES\_BLOCK\_NUM\_REG register. For details, see Section 18.5.4 .
- Initialize the AES\_INC\_SEL\_REG register (only needed when AES Accelerator is working under CTR block operation).
- Initialize the AES\_IV\_MEM memory (This is always needed except for ECB block operation).
3. Start operation by writing 1 to the AES\_TRIGGER\_REG register.
4. Wait for the completion of computation, which happens when the content of AES\_STATE\_REG becomes 2 or the AES interrupt occurs.
5. Check if DMA completes data transmission from AES to memory. At this time, DMA had already written the result data in memory, which can be accessed directly. For details on DMA, please refer to Chapter 2 GDMA Controller (GDMA) .
6. Clear interrupt by writing 1 to the AES\_INT\_CLR\_REG register, if any AES interrupt occurred during the computation.
7. Release the AES Accelerator by writing 0 to the AES\_DMA\_EXIT\_REG register. After this, the content of the AES\_STATE\_REG register becomes 0. Note that, you can release DMA earlier, but only after Step 4 is completed.

## 18.6 Memory Summary

The addresses in this section are relative to the AES accelerator base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name       | Description   | Size (byte)   | Starting Address   | Ending Address   | Access   |
|------------|---------------|---------------|--------------------|------------------|----------|
| AES_IV_MEM | Memory IV     | 16 bytes      | 0x0050             | 0x005F           | R/W      |

## 18.7 Register Summary

The addresses in this section are relative to the AES accelerator base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                           | Description                                       | Address   | Access   |
|--------------------------------|---------------------------------------------------|-----------|----------|
| Key Registers                  |                                                   |           |          |
| AES_KEY_0_REG                  | AES key data register 0                           | 0x0000    | R/W      |
| AES_KEY_1_REG                  | AES key data register 1                           | 0x0004    | R/W      |
| AES_KEY_2_REG                  | AES key data register 2                           | 0x0008    | R/W      |
| AES_KEY_3_REG                  | AES key data register 3                           | 0x000C    | R/W      |
| AES_KEY_4_REG                  | AES key data register 4                           | 0x0010    | R/W      |
| AES_KEY_5_REG                  | AES key data register 5                           | 0x0014    | R/W      |
| AES_KEY_6_REG                  | AES key data register 6                           | 0x0018    | R/W      |
| AES_KEY_7_REG                  | AES key data register 7                           | 0x001C    | R/W      |
| TEXT_IN Registers              |                                                   |           |          |
| AES_TEXT_IN_0_REG              | Source text data register 0                       | 0x0020    | R/W      |
| AES_TEXT_IN_1_REG              | Source text data register 1                       | 0x0024    | R/W      |
| AES_TEXT_IN_2_REG              | Source text data register 2                       | 0x0028    | R/W      |
| AES_TEXT_IN_3_REG              | Source text data register 3                       | 0x002C    | R/W      |
| TEXT_OUT Registers             |                                                   |           |          |
| AES_TEXT_OUT_0_REG             | Result text data register 0                       | 0x0030    | RO       |
| AES_TEXT_OUT_1_REG             | Result text data register 1                       | 0x0034    | RO       |
| AES_TEXT_OUT_2_REG             | Result text data register 2                       | 0x0038    | RO       |
| AES_TEXT_OUT_3_REG             | Result text data register 3                       | 0x003C    | RO       |
| Configuration Registers        |                                                   |           |          |
| AES_MODE_REG                   | Defines key length and encryption / de cryption  | 0x0040    | R/W      |
| AES_DMA_ENABLE_REG             | Selects the working mode of the AES ac celerator | 0x0090    | R/W      |
| AES_BLOCK_MODE_REG             | Defines the block cipher mode                     | 0x0094    | R/W      |
| AES_BLOCK_NUM_REG              | Block number configuration register               | 0x0098    | R/W      |
| AES_INC_SEL_REG                | Standard incrementing function register           | 0x009C    | R/W      |
| Controlling / Status Registers |                                                   |           |          |
| AES_TRIGGER_REG                | Operation start controlling register              | 0x0048    | WO       |
| AES_STATE_REG                  | Operation status register                         | 0x004C    | RO       |
| AES_DMA_EXIT_REG               | Operation exit controlling register               | 0x00B8    | WO       |
| Interruption Registers         |                                                   |           |          |
| AES_INT_CLR_REG                | DMA-AES interrupt clear register                  | 0x00AC    | WO       |
| AES_INT_ENA_REG                | DMA-AES interrupt enable register                 | 0x00B0    | R/W      |

## 18.8 Registers

The addresses in this section are relative to the AES accelerator base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 18.1. AES\_KEY\_n\_REG (n: 0-7) (0x0000+4*n)

![Image](images/18_Chapter_18_img001_62c0fda3.png)

AES\_KEY\_n\_REG (n: 0-7) Stores AES key data. (R/W)

![Image](images/18_Chapter_18_img002_8f6893dd.png)

AES\_TEXT\_IN\_m\_REG (m: 0-3) Stores the source text data when the AES Accelerator operates in the Typical AES working mode. (R/W)

![Image](images/18_Chapter_18_img003_3c24560e.png)

## Register 18.4. AES\_MODE\_REG (0x0040)

![Image](images/18_Chapter_18_img004_91622608.png)

AES\_MODE Defines the key length and encryption / decryption of the AES Accelerator. For details, see Table 18.3-2. (R/W)

Register 18.5. AES\_DMA\_ENABLE\_REG (0x0090)

![Image](images/18_Chapter_18_img005_084843aa.png)

AES\_DMA\_ENABLE Defines the working mode of the AES Accelerator. 0: Typical AES, 1: DMA-AES. For details, see Table 18.3-1. (R/W)

Register 18.6. AES\_BLOCK\_MODE\_REG (0x0094)

![Image](images/18_Chapter_18_img006_b3371162.png)

AES\_BLOCK\_MODE Defines the block cipher mode of the AES Accelerator operating under the DMA-AES working mode. For details, see Table 18.5-1. (R/W)

## Register 18.7. AES\_BLOCK\_NUM\_REG (0x0098)

![Image](images/18_Chapter_18_img007_c1b84654.png)

AES\_BLOCK\_NUM Stores the Block Number of plaintext or ciphertext when the AES Accelerator operates under the DMA-AES working mode. For details, see Section 18.5.4. (R/W)

## Register 18.8. AES\_INC\_SEL\_REG (0x009C)

![Image](images/18_Chapter_18_img008_13e41d19.png)

AES\_INC\_SEL Defines the Standard Incrementing Function for CTR block operation. Set this bit to 0 or 1 to choose INC 32 or INC 128 . (R/W)

## Register 18.9. AES\_TRIGGER\_REG (0x0048)

![Image](images/18_Chapter_18_img009_5a6fa429.png)

AES\_TRIGGER Set this bit to 1 to start AES operation. (WO)

## Register 18.10. AES\_STATE\_REG (0x004C)

![Image](images/18_Chapter_18_img010_c04f8ab6.png)

AES\_STATE Stores the working status of the AES Accelerator. For details, see Table 18.4-1 for Typical AES working mode and Table 18.5-2 for DMA AES working mode. (RO)

## Register 18.11. AES\_DMA\_EXIT\_REG (0x00B8)

![Image](images/18_Chapter_18_img011_5b34db44.png)

AES\_DMA\_EXIT Set this bit to 1 to exit AES operation. This register is only effective for DMA-AES operation. (WO)

## Register 18.12. AES\_INT\_CLR\_REG (0x00AC)

AES\_INT\_ENA Set this bit to 1 to enable AES interrupt and 0 to disable interrupt. (R/W)

![Image](images/18_Chapter_18_img012_d6c0a32a.png)
