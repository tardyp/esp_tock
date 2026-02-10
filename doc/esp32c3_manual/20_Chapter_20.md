---
chapter: 20
title: "Chapter 20"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 20

## RSA Accelerator (RSA)

## 20.1 Introduction

The RSA Accelerator provides hardware support for high precision computation used in various RSA asymmetric cipher algorithms by significantly reducing their software complexity. Compared with RSA algorithms implemented solely in software, this hardware accelerator can speed up RSA algorithms significantly. Besides, the RSA Accelerator also supports operands of different lengths, which provides more flexibility during the computation.

## 20.2 Features

The following functionality is supported:

- Large-number modular exponentiation with two optional acceleration options
- Large-number modular multiplication
- Large-number multiplication
- Operands of different lengths
- Interrupt on completion of computation

## 20.3 Functional Description

The RSA Accelerator is activated by setting the SYSTEM\_CRYPTO\_RSA\_CLK\_EN bit in the SYSTEM\_PERIP\_CLK

\_EN1\_REG register and clearing the SYSTEM\_RSA\_MEM\_PD bit in the SYSTEM\_RSA\_PD\_CTRL\_REG register. This releases the RSA Accelerator from reset.

The RSA Accelerator is only available after the RSA-related memories are initialized. The content of the RSA\_CLEAN

\_REG register is 0 during initialization and will become 1 after the initialization is done. Therefore, it is advised to wait until RSA\_CLEAN\_REG becomes 1 before using the RSA Accelerator.

The RSA\_INTERRUPT\_ENA\_REG register is used to control the interrupt triggered on completion of computation. Write 1 or 0 to this register to enable or disable interrupt. By default, the interrupt function of the RSA Accelerator is enabled.

## Notice:

ESP32-C3’s Digital Signature (DS) module also calls the RSA accelerator. Therefore, users cannot access the RSA

accelerator when Digital Signature (DS) is working.

## 20.3.1 Large Number Modular Exponentiation

Large-number modular exponentiation performs Z = X Y mod M. The computation is based on Montgomery multiplication. Therefore, aside from the X , Y , and M arguments, two additional ones are needed — r and M ′ , which need to be calculated in advance by software.

RSA Accelerator supports operands of length N = 32 × x, where x ∈ {1 , 2 , 3 , . . . , 96}. The bit lengths of arguments Z , X , Y , M, and r can be arbitrary N, but all numbers in a calculation must be of the same length. The bit length of M ′ must be 32.

To represent the numbers used as operands, let us define a base-b positional notation, as follows:

<!-- formula-not-decoded -->

Using this notation, each number is represented by a sequence of base-b digits:

<!-- formula-not-decoded -->

Each of the n values in Zn Zn − 1 · · · Z0 Z0, X n − 1 · · · X 0, Yn Yn − 1 · · · Y0 Y0, Mn Mn − 1 · · · M0 M0, rn − 1 · · · r0 represents one base-b digit (a 32-bit word).

Zn Zn − 1, X n − 1, Yn Yn − 1, Mn Mn − 1 and r n − 1 are the most significant bits of Z , X , Y , M, while Z0 Z0, X 0, Y0 Y0, M0 M0 and r 0 are the least significant bits.

If we define R = b
n, the additional arguments can be calculated as r = R 2 mod M .

The following equation in the form compatible with the extended binary GCD algorithm can be written as:

<!-- formula-not-decoded -->

Large-number modular exponentiation can be implemented as follows:

1. Write 1 or 0 to the RSA\_INTERRUPT\_ENA\_REG register to enable or disable the interrupt function.
2. Configure relevant registers:
3. (a) Write ( N 32 − 1) to the RSA\_MODE\_REG register.
4. (b) Write M ′ to the RSA\_M\_PRIME\_REG register.

- (c) Configure registers related to the acceleration options, which are described later in Section 20.3.4 .
3. Write X i

Users need to write data to each memory block only according to the length of the number; data beyond this length are ignored.

4. Write 1 to the RSA\_MODEXP\_START\_REG register to start computation.
5. Wait for the completion of computation, which happens when the content of RSA\_IDLE\_REG becomes 1 or the RSA interrupt occurs.
6. Read the result Zi Zi for i ∈ {0 , 1, . . . , n − 1} from RSA\_Z\_MEM .
7. Write 1 to RSA\_CLEAR\_INTERRUPT\_REG to clear the interrupt, if you have enabled the interrupt function.

After the computation, the RSA\_MODE\_REG register, memory blocks RSA\_Y\_MEM and RSA\_M\_MEM, as well as the RSA\_M\_PRIME\_REG remain unchanged. However, Xiin RSA\_X\_MEM and riin RSA\_Z\_MEM computation are overwritten, and only these overwritten memory blocks need to be re-initialized before starting another computation.

## 20.3.2 Large Number Modular Multiplication

Large-number modular multiplication performs Z = X × Y mod M. This computation is based on Montgomery multiplication. Therefore, similar to the large number modular exponentiation, two additional arguments are needed – r and M ′ , which need to be calculated in advance by software.

The RSA Accelerator supports large-number modular multiplication with operands of 96 different lengths.

The computation can be executed as follows:

1. Write 1 or 0 to the RSA\_INTERRUPT\_ENA\_REG register to enable or disable the interrupt function.
2. Configure relevant registers:
3. (a) Write ( N 32 − 1) to the RSA\_MODE\_REG register.
4. (b) Write M ′ to the RSA\_M\_PRIME\_REG register.
3. Write X i

Users need to write data to each memory block only according to the length of the number; data beyond this length are ignored.

4. Write 1 to the RSA\_MODMULT\_START\_REG register.
5. Wait for the completion of computation, which happens when the content of RSA\_IDLE\_REG becomes 1 or the RSA interrupt occurs.
6. Read the result Zi Zi for i ∈ {0 , 1, . . . , n − 1} from RSA\_Z\_MEM .

7. Write 1 to RSA\_CLEAR\_INTERRUPT\_REG to clear the interrupt, if you have enabled the interrupt function.

After the computation, the length of operands in RSA\_MODE\_REG, the Xiin memory RSA\_X\_MEM, the Yiin memory RSA\_Y\_MEM, the Miin memory RSA\_M\_MEM, and the M ′ in memory RSA\_M\_PRIME\_REG remain unchanged. However, the riin memory RSA\_Z\_MEM has already been overwritten, and only this overwritten memory block needs to be re-initialized before starting another computation.

## 20.3.3 Large Number Multiplication

Large-number multiplication performs Z = X × Y . The length of result Z is twice that of operand X and operand Y . Therefore, the RSA Accelerator only supports Large Number Multiplication with operand length N = 32 × x, where x ∈ {1 , 2 , 3 , . . . , 48}. The length N ˆ of result Z is 2 × N .

The computation can be executed as follows:

1. Write 1 or 0 to the RSA\_INTERRUPT\_ENA\_REG register to enable or disable the interrupt function.
2. Write ( N ˆ 32 − 1), i.e. ( N 16 − 1) to the RSA\_MODE\_REG register.
3. Write X i and Yi Yi for ∈ {0 , 1, . . . , n − 1} to memory blocks RSA\_X\_MEM and RSA\_Z\_MEM. Each word of each memory block can store one base-b digit. The memory blocks use the little endian format for storage, i.e. the least significant digit of each number is in the lowest address. n is N 32 .
4. Write X i for i ∈ {0 , 1, . . . , n − 1} to the address of the i words of the RSA\_X\_MEM memory block. Note that Yi Yi for i ∈ {0 , 1, . . . , n − 1} will not be written to the address of the i words of the RSA\_Z\_MEM register, but the address of the n + i words, i.e. the base address of the RSA\_Z\_MEM memory plus the address offset 4 × (n + i) .

Users need to write data to each memory block only according to the length of the number; data beyond this length are ignored.

4. Write 1 to the RSA\_MULT\_START\_REG register.
5. Wait for the completion of computation, which happens when the content of RSA\_IDLE\_REG becomes 1 or the RSA interrupt occurs.
6. Read the result Zi Zi for i ∈ {0 , 1 , . . . , n ˆ − 1} from the RSA\_Z\_MEM register. nˆ ˆ is 2 × n .
7. Write 1 to RSA\_CLEAR\_INTERRUPT\_REG to clear the interrupt, if you have enabled the interrupt function.

After the computation, the length of operands in RSA\_MODE\_REG and the Xiin memory RSA\_X\_MEM remain unchanged. However, the Yiin memory RSA\_Z\_MEM has already been overwritten, and only this overwritten memory block needs to be re-initialized before starting another computation.

## 20.3.4 Options for Acceleration

The ESP32-C3 RSA accelerator also provides SEARCH and CONSTANT\_TIME options that can be configured to accelerate the large-number modular exponentiation. By default, both options are configured for no acceleration. Users can choose to use one or two of these options to accelerate the computation.

To be more specific, when neither of these two options are configured for acceleration, the time required to calculate Z = XY mod M is solely determined by the lengths of operands. When either or both of these two options are configured for acceleration, the time required is also correlated with the 0/1 distribution of Y .

To better illustrate how these two options work, first assume Y is represented in binaries as

<!-- formula-not-decoded -->

where,

- N is the length of Y ,
- Y
- Y
- and Y

When either of these two options is configured for acceleration:

- SEARCH Option (Configuring RSA\_SEARCH\_ENABLE to 1 for acceleration)
- – The accelerator ignores the bit positions of Y
i e Y
i , where i &gt; α. Search position α is set by configuring the RSA\_SEARCH\_POS\_REG register. The maximum value of α is N-1, which leads to the same result when this option is not used for acceleration. The best acceleration performance can be achieved by setting α to t, in which case, all the Y
N e Y
N − 1, Y
N e Y
N − 2, …, Y
t e Y
t+1 of 0s are ignored during the calculation. Note that if you set α to be less than t, then the result of the modular exponentiation Z = X Y mod M will be incorrect.
- CONSTANT\_TIME Option (Configuring RSA\_CONSTANT\_TIME\_REG to 0 for acceleration)
- – The accelerator speeds up the calculation by simplifying the calculation concerning the 0 bits of Y . Therefore, the higher the proportion of bits 0 against bits 1, the better the acceleration performance is.

We provide an example to demonstrate the performance of the RSA Accelerator under different combinations of SEARCH and CONSTANT\_TIME configuration. Here we perform Z = X Y mod M with N = 3072 and Y = 65537. Table 20.3-1 below demonstrates the time costs under different combinations of SEARCH and CONSTANT\_TIME configuration. Here, we should also mention that, α is set to 16 when the SEARCH option is enabled.

Table 20.3-1. Acceleration Performance

| SEARCH Option   | CONSTANT_TIME Option   |   Time Cost (ms) |
|-----------------|------------------------|------------------|
| No acceleration | No acceleration        |          752.81  |
| Accelerated     | No acceleration        |            4.52  |
| No acceleration | Acceleration           |            2.406 |
| Acceleration    | Acceleration           |            2.33  |

It’s obvious that:

- The time cost is the biggest when none of these two options is configured for acceleration.
- The time cost is the smallest when both of these two options are configured for acceleration.
- The time cost can be dramatically reduced when either or both option(s) are configured for acceleration.

![Image](images/20_Chapter_20_img001_7d2e6da7.png)

## 20.4 Memory Summary

The addresses in this section are relative to the RSA accelerator base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

Table 20.4-1. RSA Accelerator Memory Blocks

| Name      | Description   |   Size (byte) | Starting Address   | Ending Address   | Access   |
|-----------|---------------|---------------|--------------------|------------------|----------|
| RSA_M_MEM | Memory M      |           384 | 0x0000             | 0x017F           | R/W      |
| RSA_Z_MEM | Memory Z      |           384 | 0x0200             | 0x037F           | R/W      |
| RSA_Y_MEM | Memory Y      |           384 | 0x0400             | 0x057F           | R/W      |
| RSA_X_MEM | Memory X      |           384 | 0x0600             | 0x077F           | R/W      |

## 20.5 Register Summary

The addresses in this section are relative to the RSA accelerator base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                     | Description                         | Address                  | Access                   |
|--------------------------|-------------------------------------|--------------------------|--------------------------|
| Configuration Registers  | Configuration Registers             | Configuration Registers  | Configuration Registers  |
| RSA_M_PRIME_REG          | Register to store M’                | 0x0800                   | R/W                      |
| RSA_MODE_REG             | RSA length mode                     | 0x0804                   | R/W                      |
| RSA_CONSTANT_TIME_REG    | The constant_time option            | 0x0820                   | R/W                      |
| RSA_SEARCH_ENABLE_REG    | The search option                   | 0x0824                   | R/W                      |
| RSA_SEARCH_POS_REG       | The search position                 | 0x0828                   | R/W                      |
| Status/Control Registers | Status/Control Registers            | Status/Control Registers | Status/Control Registers |
| RSA_CLEAN_REG            | RSA clean register                  | 0x0808                   | RO                       |
| RSA_MODEXP_START_REG     | Modular exponentiation starting bit | 0x080C                   | WO                       |
| RSA_MODMULT_START_REG    | Modular multiplication starting bit | 0x0810                   | WO                       |
| RSA_MULT_START_REG       | Normal multiplication starting bit  | 0x0814                   | WO                       |
| RSA_IDLE_REG             | RSA idle register                   | 0x0818                   | RO                       |
| Interrupt Registers      | Interrupt Registers                 | Interrupt Registers      | Interrupt Registers      |
| RSA_CLEAR_INTERRUPT_REG  | RSA clear interrupt register        | 0x081C                   | WO                       |
| RSA_INTERRUPT_ENA_REG    | RSA interrupt enable register       | 0x082C                   | R/W                      |
| Version Register         | Version Register                    | Version Register         | Version Register         |
| RSA_DATE_REG             | Version control register            | 0x0830                   | R/W                      |

## 20.6 Registers

The addresses in this section are relative to the RSA accelerator base address provided in Table 3.3-3 in Chapter 3 System and Memory .

## Register 20.1. RSA\_M\_PRIME\_REG (0x0800)

RSA\_CLEAN The content of this bit is 1 when memories complete initialization. (RO)

![Image](images/20_Chapter_20_img002_5baf117a.png)

![Image](images/20_Chapter_20_img003_79c8c6ab.png)

## Register 20.8. RSA\_CLEAR\_INTERRUPT\_REG (0x081C)

![Image](images/20_Chapter_20_img004_4ca56367.png)

Register 20.11. RSA\_SEARCH\_POS\_REG (0x0828)

![Image](images/20_Chapter_20_img005_5816001f.png)

RSA\_SEARCH\_POS Is used to configure the starting address when the acceleration option of search is used. (R/W)

Register 20.12. RSA\_INTERRUPT\_ENA\_REG (0x082C)

![Image](images/20_Chapter_20_img006_a70909d2.png)

RSA\_INTERRUPT\_ENA Set this bit to 1 to enable the RSA interrupt. This option is enabled by default. (R/W)

## Register 20.13. RSA\_DATE\_REG (0x0830)

![Image](images/20_Chapter_20_img007_d3a35d19.png)

RSA\_DATE Version control register. (R/W)
