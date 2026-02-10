---
chapter: 20
title: "Chapter 20"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 20

## ECC Accelerator (ECC)

## 20.1 Introduction

Elliptic Curve Cryptography (ECC) is an approach to public-key cryptography based on the algebraic structure of elliptic curves. ECC allows smaller keys compared to RSA cryptography while providing equivalent security.

ESP32-C6's ECC Accelerator can complete various calculations based on different elliptic curves, thus accelerating the ECC algorithm and ECC-derived algorithms (such as ECDSA).

## 20.2 Features

ESP32-C6’s ECC Accelerator has the following features:

- Two different elliptic curves, namely P-192 and P-256 defined in FIPS 186-3
- Six working modes
- Interrupt upon completion of calculation

## 20.3 Terminology

This section covers terminology used to describe ECC Accelerator.

## 20.3.1 ECC Basics

## 20.3.1.1 Elliptic Curve and Points on the Curves

The ECC algorithm is based on elliptic curves over prime fields, which can be represented as:

<!-- formula-not-decoded -->

where,

- p is a prime number,
- a and b are two non-negative integers smaller than p ,
- and (x, y) is a point on the curve satisfying the representation.

## 20.3.1.2 Affine Coordinates and Jacobian Coordinates

An elliptic curve can be represented as below:

- In affine coordinates:
- In a Jacobian coordinates:

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

To convert affine coordinates (x, y) to/from Jacobian coordinates (X, Y, Z):

- From Jacobian to Affine coordinates
- From Affine to Jacobian coordinates

<!-- formula-not-decoded -->

<!-- formula-not-decoded -->

X = x

Y = y

Z = 1

## 20.3.2 Definitions of ESP32-C6's ECC

## 20.3.2.1 Memory Blocks

ECC’s memory blocks store input data and output data of the ECC operation.

Table 20.3-1. ECC Accelerator Memory Blocks

| Memory          |   Size (byte) | Starting Address *   | Ending Address   | Access   |
|-----------------|---------------|----------------------|------------------|----------|
| ECC_MULT_Mem_k  |            32 | 0x100                | 0x11F            | R/W      |
| ECC_MULT_Mem_Px |            32 | 0x120                | 0x13F            | R/W      |
| ECC_MULT_Mem_Py |            32 | 0x140                | 0x15F            | R/W      |

## 20.3.2.2 Data and Data Block

ESP32-C6's ECC operates on data of 256 bits. This data (D[255 : 0]) can be divided into eight 32-bit data blocks D[n][31 : 0](n = 0 , 1 , · · · , 7). Data blocks with the smaller serial number correspond to the lower binary bits. To be specific:

<!-- formula-not-decoded -->

## 20.3.2.3 Write Data

Write data means writing data to an ECC memory block and using this data as the input to the ECC algorithm. To be specific, write data to an ECC memory block means writing D[n][31 : 0](n = 0 , 1 , · · · , 7) to the "starting address of this ECC memory block + 4 × n" successively:

- write D[0] to "starting address"
- write D[1] to "starting address + 4"

- · · ·
- write D[7] to "starting address + 28"

## Note:

When the key size of 192 bits is used, you need to append 0 before 192 bits of data and write 256 bits of data.

## 20.3.2.4 Read Data

Read data means reading data from the starting address of an ECC memory block and using this data as the output from the ECC algorithm. To be specific, read data from an ECC memory block means reading D[n][31 : 0](n = 0 , 1 , · · · , 7) from the "starting address of this ECC memory block + 4 × n" successively:

- read D[0] from "starting address"
- read D[1] from "starting address + 4"
- · · ·
- read D[7] from "starting address + 28"

## Note:

When the key size of 192 bits is used, only read the low 192 bits (6 blocks) of data.

## 20.3.2.5 Standard Calculation and Jacobian Calculation

ESP32-C6's ECC performs Base Point Calculation (including Base Point Verification and Base Point Multiplication) using the affine coordinates and Jacobian Calculation (including Jacobian Point Verification and Jacobian Point Multiplication) using the Jacobian coordinates.

## 20.4 Function Description

## 20.4.1 Key Size

ESP32-C6's ECC supports acceleration based on two key sizes (corresponding to two different elliptic curves). By configuring the ECC\_MULT\_KEY\_LENGTH field, users can select the desired key size. For details, see Table 20.4-1 below.

Table 20.4-1. ECC Accelerator Key Size Selection

| ECC_MULT_KEY_LENGTH   | Elliptic Curves   |
|-----------------------|-------------------|
| 1’b0                  | FIPS P-192        |
| 1’b1                  | FIPS P-256        |

![Image](images/20_Chapter_20_img001_cdeebe32.png)

## 20.4.2 Working Modes

ESP32-C6's ECC accelerator supports six working modes based on two elliptic curves described in the above section. By configuring the ECC\_MULT\_WORK\_MODE field, users can choose the desired working mode. For details, see Table 20.4-2 .

Table 20.4-2. ECC Accelerator’s Working Modes

| ECC_MULT_WORK_MODE   | Working Modes       | ECC_MULT_WORK_MODE   | Working Modes                      |
|----------------------|---------------------|----------------------|------------------------------------|
| 3’d0                 | Point Multi         | 3’d4                 | Jacobian Point Multi               |
| 3’d1                 | Reserved            | 3’d5                 | Reserved                           |
| 3’d2                 | Point Verif         | 3’d6                 | Jacobian Point Verif               |
| 3’d3                 | Point Verif + Multi | 3’d7                 | Point Verif + Jacobian Point Multi |

Detailed descriptions about different working modes are provided in the following sections.

## 20.4.2.1 Base Point Multiplication (Point Multi Mode)

Base Point Multiplication can be represented as:

<!-- formula-not-decoded -->

where,

- Input: Px Px, Py Py , and k are stored in ECC\_MULT\_Mem\_Px , ECC\_MULT\_Mem\_Py, and ECC\_MULT\_Mem\_k respectively.
- Output: Q x and Q y are stored in ECC\_MULT\_Mem\_Px and ECC\_MULT\_Mem\_Py respectively.

## 20.4.2.2 Base Point Verification (Point Verif Mode)

Base Point Verification can be used to verify if a point (Px Px , Py Py ) is on a selected elliptic curve.

- Input: Px Px and Py Py are stored in ECC\_MULT\_Mem\_Px and ECC\_MULT\_Mem\_Py respectively.
- Output: the verification result is stored in the ECC\_MULT\_VERIFICATION\_RESULT field.

## 20.4.2.3 Base Point Verification + Base Point Multiplication (Point Verif + Multi Mode)

In this working mode, ECC first verifies if Point (Px Px , Py Py ) is on the selected elliptic curve. If so, the following multiplication is performed:

<!-- formula-not-decoded -->

where,

- Input: Px Px, Py Py , and k are stored in ECC\_MULT\_Mem\_Px , ECC\_MULT\_Mem\_Py, and ECC\_MULT\_Mem\_k respectively.
- Output:
- – the verification result is stored in the ECC\_MULT\_VERIFICATION\_RESULT field.
- – Q x and Q y are stored in ECC\_MULT\_Mem\_Px and ECC\_MULT\_Mem\_Py respectively.

![Image](images/20_Chapter_20_img002_eb2f9051.png)

## 20.4.2.4 Jacobian Point Multiplication (Jacobian Point Multi Mode)

Jacobian Point Multiplication can be represented as:

<!-- formula-not-decoded -->

where,

- (Q x , Q y , Q z ) is a Jacobian point on the selected elliptic curve.
- 1 in the point's Jacobian coordinates is auto completed by hardware.
- Input: Px Px, Py Py , and k are stored in ECC\_MULT\_Mem\_Px , ECC\_MULT\_Mem\_Py, and ECC\_MULT\_Mem\_k respectively.
- Output: Q x, Q y , and Q z are stored in ECC\_MULT\_Mem\_Px , ECC\_MULT\_Mem\_Py, and ECC\_MULT\_Mem\_k respectively.

## 20.4.2.5 Jacobian Point Verification (Jacobian Point Verif Mode)

Jacobian Point Verification can be used to verify if a point (Q x , Q y , Q z ) is on a selected elliptic curve.

- (Q x , Q y , Q z ) is the point in Jacobian Coordinates.
- Input: Q x, Q y , and Q z are stored in ECC\_MULT\_Mem\_Px , ECC\_MULT\_Mem\_Py, and ECC\_MULT\_Mem\_k respectively.
- Output: the verification result is stored in the ECC\_MULT\_VERIFICATION\_RESULT field.

## 20.4.2.6 Base Point Verification + Jacobian Point Multiplication (Point Verif + Jacobian Point Multi Mode)

In this working mode, ECC first verifies if Point (Px Px , Py Py ) is on the selected elliptic curve. If so, the following multiplication is performed:

<!-- formula-not-decoded -->

where,

- (Q x , Q y , Q z ) is a Jacobian point on the selected elliptic curve.
- 1 in the point's Jacobian coordinates is auto completed by hardware.
- Input: Px Px, Py Py , and k are stored in ECC\_MULT\_Mem\_Px , ECC\_MULT\_Mem\_Py, and ECC\_MULT\_Mem\_k .
- Output:
- – the verification result is stored in the ECC\_MULT\_VERIFICATION\_RESULT field.
- – Q x, Q y , and Q z are stored in ECC\_MULT\_Mem\_Px , ECC\_MULT\_Mem\_Py, and ECC\_MULT\_Mem\_k .

## 20.5 Clocks and Resets

ESP32-C6's ECC only has one clock module (CRYPTO\_ECC\_CLK) and one reset module (CRYPTO\_ECC\_RST). Users should enable the ECC clock and disable the ECC reset before starting the ECC accelerator. For details on how to configure the ECC clock and reset, please refer to Chapter 8 Reset and Clock .

## 20.6 Interrupts

ESP32-C6's ECC accelerator can generate one interrupt signal ECC\_INTR and send it to Interrupt Matrix .

## Note:

Each interrupt signal is generated by any of its interrupt sources, i.e., any of its interrupt sources triggered can generate the interrupt signal.

ECC\_INTR has only one interrupt source, i.e., ECC\_MULT\_CALC\_DONE\_INT, which is triggered on the completion of an ECC calculation. This ECC\_MULT\_CALC\_DONE\_INT interrupt source is configured by the following registers:

- ECC\_MULT\_CALC\_DONE\_INT\_RAW: stores the raw interrupt status of ECC\_MULT\_CALC\_DONE\_INT.
- ECC\_MULT\_CALC\_DONE\_INT\_ST: indicates the status of the ECC\_MULT\_CALC\_DONE\_INT interrupt. This field is generated by enabling/disabling the ECC\_MULT\_CALC\_DONE\_INT\_RAW field via ECC\_MULT\_CALC\_DONE\_INT\_ENA .
- ECC\_MULT\_CALC\_DONE\_INT\_ENA: enables/disables the ECC\_MULT\_CALC\_DONE\_INT interrupt.
- ECC\_MULT\_CALC\_DONE\_INT\_CLR: set this bit to clear the ECC\_MULT\_CALC\_DONE\_INT interrupt status. By setting this bit to 1, fields ECC\_MULT\_CALC\_DONE\_INT\_RAW and ECC\_MULT\_CALC\_DONE\_INT\_ST will be cleared.

## 20.7 Programming Procedures

The programming procedure for configuring ECC is described below:

1. Configure the ECC clock and reset.
2. Choose the key size and working mode as described in Section 20.4 .
3. Enable the ECC\_MULT\_CALC\_DONE\_INT interrupt as described in Section 20.6 .
4. Set the ECC\_MULT\_START field to start ECC calculation.
5. Wait for the ECC\_MULT\_CALC\_DONE\_INT interrupt, which indicates the completion of the ECC calculation.
6. Check the result as described in Section 20.4 .

![Image](images/20_Chapter_20_img003_ffd4a858.png)

## 20.8 Register Summary

The addresses in this section are relative to ECC Accelerator base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                   | Description                          | Address                | Access                 |
|------------------------|--------------------------------------|------------------------|------------------------|
| Interrupt Registers    | Interrupt Registers                  | Interrupt Registers    | Interrupt Registers    |
| ECC_MULT_INT_RAW_REG   | ECC raw interrupt status register    | 0x000C                 | RO/WTC/SS              |
| ECC_MULT_INT_ST_REG    | ECC masked interrupt status register | 0x0010                 | RO                     |
| ECC_MULT_INT_ENA_REG   | ECC interrupt enable register        | 0x0014                 | R/W                    |
| ECC_MULT_INT_CLR_REG   | ECC interrupt clear register         | 0x0018                 | WT                     |
| Configuration Register | Configuration Register               | Configuration Register | Configuration Register |
| ECC_MULT_CONF_REG      | ECC configuration register           | 0x001C                 | varies                 |
| Version Register       | Version Register                     | Version Register       | Version Register       |
| ECC_MULT_DATE_REG      | Version control register             | 0x00FC                 | R/W                    |

## 20.9 Registers

The addresses in this section are relative to ECC Accelerator base address provided in Table 5.3-2 in Chapter 5 System and Memory .

![Image](images/20_Chapter_20_img004_c7fd8d6c.png)

![Image](images/20_Chapter_20_img005_1af7687a.png)

## Register 20.5. ECC\_MULT\_CONF\_REG (0x001C)

![Image](images/20_Chapter_20_img006_1d34c99b.png)

- ECC\_MULT\_START Configures whether to start calculation of ECC Accelerator. This bit will be selfcleared after the calculation is done.
- 0: No effect
- 1: Start calculation of ECC Accelerator

(R/W/SC)

- ECC\_MULT\_RESET Configures whether to reset ECC Accelerator.
- 0: No effect
- 1: Reset

(WT)

- ECC\_MULT\_KEY\_LENGTH Configures the key length mode bit of ECC Accelerator.
- 0: P-192
- 1: P-256

(R/W)

ECC\_MULT\_SECURITY\_MODE Reserved. (R/W)

- ECC\_MULT\_CLK\_EN Configures whether to force on register clock gate.
- 0: No effect
- 1: Force on

(R/W)

- ECC\_MULT\_WORK\_MODE Configures the work mode of ECC Accelerator.
- 0: Point Multi mode
- 1: Reserved
- 2: Point Verif mode
- 3: Point Verif + Multi mode
- 4: Jacobian Point Multi mode
- 5: Reserved
- 6: Jacobian Point Verif mode
- 7: Point Verif + Jacobian Point Multi mode
- (R/W)
- ECC\_MULT\_VERIFICATION\_RESULT Represents the verification result of ECC Accelerator, valid only

when calculation is done. (R/SS)

Continued on the next page...

## Register 20.5. ECC\_MULT\_CONF\_REG (0x001C)

## Continued from the previous page...

ECC\_MULT\_MEM\_CLOCK\_GATE\_FORCE\_ON Configures whether to force on ECC memory clock gate.

0: No effect

1: Force on

(R/W)

## Register 20.6. ECC\_MULT\_DATE\_REG (0x00FC)

![Image](images/20_Chapter_20_img007_bd957099.png)

ECC\_MULT\_DATE Version control register. (R/W)
