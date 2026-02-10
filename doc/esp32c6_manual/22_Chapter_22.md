---
chapter: 22
title: "Chapter 22"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 22

## RSA Accelerator (RSA)

## 22.1 Introduction

The RSA accelerator provides hardware support for high-precision computation used in various RSA asymmetric cipher algorithms, significantly improving their run time and reducing their software complexity. Compared with RSA algorithms implemented solely in software, this hardware accelerator can speed up RSA algorithms significantly. The RSA accelerator also supports operands of different lengths, which provides more flexibility during the computation.

## 22.2 Features

The following functionality is supported:

- Large-number modular exponentiation with two optional acceleration options
- Large-number modular multiplication
- Large-number multiplication
- Operands of different lengths
- Interrupt on completion of computation

## 22.3 Functional Description

The RSA accelerator is activated by setting the PCR\_RSA\_CLK\_EN bit and clearing the PCR\_RSA\_RST\_EN bit in the PCR\_RSA\_CONF\_REG register. Additionally, users also need to clear PCR\_DS\_RST\_EN bit to reset Digital Signature (DS) .

The RSA accelerator is only available after the RSA-related memories are initialized. The content of the RSA\_QUERY\_CLEAN\_REG register is 0 during initialization and will become 1 after the initialization is done.

Therefore, wait until RSA\_QUERY\_CLEAN\_REG becomes 1 before using the RSA accelerator.

The RSA\_INT\_ENA\_REG register is used to control the interrupt triggered on completion of computation. Write 1 or 0 to this field to enable or disable the interrupt. By default, the interrupt function of the RSA accelerator is enabled.

## Notice:

ESP32-C6's Digital Signature (DS) module also calls the RSA accelerator when working. Therefore, users cannot access the RSA accelerator when the Digital Signature (DS) module is working.

## 22.3.1 Large-number Modular Exponentiation

Large-number modular exponentiation performs Z = X Y mod M. The computation is based on Montgomery multiplication. Therefore, aside from the X , Y , and M arguments, two additional ones are needed — r and M ′ , which need to be calculated in advance by software.

The RSA accelerator supports operands of length N = 32 × x, where x ∈ {1 , 2 , 3 , . . . , 96}. The bit lengths of arguments Z , X , Y , M, and r can be arbitrary N, but all numbers in a calculation must be of the same length. The bit length of M ′ must be 32.

To represent the numbers used as operands, let us define a base-b positional notation, as follows:

<!-- formula-not-decoded -->

Using this notation, each number is represented by a sequence of base-b digits:

<!-- formula-not-decoded -->

Each of the values in Zn Zn − 1 · · · Z0 Z0, X n − 1 · · · X 0, Yn Yn − 1 · · · Y0 Y0, Mn Mn − 1 · · · M0 M0, rn − 1 · · · r0 represents one base-b digit (a 32-bit word).

Zn Zn − 1, X n − 1, Yn Yn − 1, Mn Mn − 1 and r n − 1 are the most significant bits of Z , X , Y , M, while Z0 Z0, X 0, Y0 Y0, M0 M0 and r 0 are the least significant bits.

If we define R = b
n, the additional argument r can be calculated as r = R 2 mod M .

Also, argument M ′ can be calculated using the formula below:

<!-- formula-not-decoded -->

where, M − 1 is the modular multiplicative inverse of M, and it can be calculated with the extended binary GCD algorithm.

Large-number modular exponentiation on the ESP32-C6 can be implemented as follows:

1. Write 1 or 0 to the RSA\_INT\_ENA field to enable or disable the interrupt function.
2. Configure relevant registers:
3. (a) Write ( N 32 − 1) to the RSA\_MODE\_REG register.
4. (b) Write M ′ to the RSA\_M\_PRIME\_REG register.
5. (c) Configure registers related to the acceleration options, which are described later in Section 22.3.4 .
3. Write X i

Users need to write data to each memory block only according to the length of the number; data beyond this length is ignored.

4. Write 1 to the RSA\_SET\_START\_MODEXP field of the RSA\_SET\_START\_MODEXP\_REG register to start computation.
5. Wait for the completion of computation, which happens when the content of RSA\_QUERY\_IDLE becomes 1 or the RSA interrupt occurs.
6. Read the result Zi Zi for i ∈ {0 , 1, . . . , n − 1} from RSA\_Z\_MEM .
7. Write 1 to RSA\_CLEAR\_INTERRUPT to clear the interrupt, if you have the interrupt enabled.

After the computation, the RSA\_MODE\_REG register, memory blocks RSA\_Y\_MEM and RSA\_M\_MEM, as well as the RSA\_M\_PRIME\_REG remain unchanged. However, Xiin RSA\_X\_MEM and riin RSA\_Z\_MEM computation are overwritten, and only these overwritten memory blocks need to be re-initialized before starting another computation.

## 22.3.2 Large-number Modular Multiplication

Large-number modular multiplication performs Z = X × Y mod M. This computation is based on Montgomery multiplication. Therefore, similar to the large-number modular exponentiation, two additional arguments are needed – r and M ′ , which need to be calculated in advance by software.

The RSA accelerator supports large-number modular multiplication with operands of 96 different lengths.

The computation can be executed as follows:

1. Write 1 or 0 to the RSA\_INT\_ENA\_REG register to enable or disable the interrupt function.
2. Configure relevant registers:
3. (a) Write ( N 32 − 1) to the RSA\_MODE\_REG register.
4. (b) Write M ′ to the RSA\_M\_PRIME\_REG register.
3. Write X i

Users need to write data to each memory block only according to the length of the number; data beyond this length are ignored.

4. Write 1 to the RSA\_SET\_START\_MODMULT field.
5. Wait for the completion of computation, which happens when the content of RSA\_QUERY\_IDLE becomes 1 or the RSA interrupt occurs.
6. Read the result Zi Zi for i ∈ {0 , 1, . . . , n − 1} from RSA\_Z\_MEM .
7. Write 1 to RSA\_CLEAR\_INTERRUPT to clear the interrupt, if you have the interrupt enabled.

After the computation, the length of operands in RSA\_MODE\_REG, the Xiin memory RSA\_X\_MEM, the Yiin memory RSA\_Y\_MEM, the Miin memory RSA\_M\_MEM, and the M ′ in memory RSA\_M\_PRIME\_REG remain

unchanged. However, the riin memory RSA\_Z\_MEM has already been overwritten, and only this overwritten memory block needs to be re-initialized before starting another computation.

## 22.3.3 Large-number Multiplication

Large-number multiplication performs Z = X × Y . The length of result Z is twice that of operand X and operand Y . Therefore, the RSA accelerator only supports large-number multiplication with operand length N = 32 × x, where x ∈ {1 , 2 , 3 , . . . , 48}. The length N ˆ of result Z is 2 × N .

The computation can be executed as follows:

1. Write 1 or 0 to the RSA\_INT\_ENA\_REG register to enable or disable the interrupt function.
2. Write ( N ˆ 32 − 1), i.e. ( N 16 − 1) to the RSA\_MODE\_REG register.
3. Write X i and Yi Yi for ∈ {0 , 1, . . . , n − 1} to memory blocks RSA\_X\_MEM and RSA\_Z\_MEM. Each word of each memory block can store one base-b digit. The memory blocks use the little endian format for storage, i.e. the least significant digit of each number is in the lowest address. n is N 32 .
4. Write X i for i ∈ {0 , 1, . . . , n − 1} to the address of the i words of the RSA\_X\_MEM memory block. Note that Yi Yi for i ∈ {0 , 1, . . . , n − 1} will not be written to the address of the i words of the RSA\_Z\_MEM register, but the address of the n + i words, i.e. the base address of the RSA\_Z\_MEM memory plus the address offset 4 × (n + i) .

Users need to write data to each memory block only according to the length of the number; data beyond this length is ignored.

4. Write 1 to the RSA\_SET\_START\_MULT register.
5. Wait for the completion of computation, which happens when the content of RSA\_QUERY\_IDLE becomes 1 or the RSA interrupt occurs.
6. Read the result Zi Zi for i ∈ {0 , 1 , . . . , n ˆ − 1} from the RSA\_Z\_MEM register. nˆ ˆ is 2 × n .
7. Write 1 to RSA\_CLEAR\_INTERRUPT to clear the interrupt, if you have the interrupt enabled.

After the computation, the length of operands in RSA\_MODE\_REG and the Xiin memory RSA\_X\_MEM remain unchanged. However, the Yiin memory RSA\_Z\_MEM has already been overwritten, and only this overwritten memory block needs to be re-initialized before starting another computation.

## 22.3.4 Options for Additional Acceleration

The ESP32-C6 RSA accelerator also provides SEARCH and CONSTANT\_TIME options that can be configured to further accelerate the large-number modular exponentiation. By default, both options are configured as no additional acceleration.

Users can choose to use one or two of these options to further accelerate the computation. Note that, even when none of these two options is configured, using the hardware RSA accelerator is still much faster than implementing the RSA algorithm in software.

To be more specific, when neither of these two options are configured for additional acceleration, the time required to calculate Z = X Y mod M is solely determined by the lengths of operands. When either or both of these two options are configured for additional acceleration, the time required is also correlated with the 0/1 distribution of Y .

To better illustrate how these two options work, first assume Y is represented in binaries as

<!-- formula-not-decoded -->

where,

- N is the length of Y ,
- Y
- Y
- and Y

When either of these two options is configured for additional acceleration:

- SEARCH Option (Configuring RSA\_SEARCH\_ENABLE to 1 for additional acceleration)

e

- – The accelerator ignores the bit positions of Y
i Y
i , where i &gt; α. Search position α is set by configuring the RSA\_SEARCH\_POS\_REG register. Set α to a number smaller than N-1, which otherwise leads to the same result as if this option is not used for additional acceleration. The best acceleration performance can be achieved by setting α to t, in which case all the Y
N e Y
N − 1, Y
N e Y
N − 2, …, Y
t e Y
t+1 of 0s are ignored during the calculation. Note that if you set α to be less than t, then the result of the modular exponentiation Z = X Y mod M will be incorrect.
- – Note that this option compromises the security because it ignores some bits, which essentially shortens the key length, thus should not be enabled for applications with high security requirement.
- CONSTANT\_TIME Option (Configuring RSA\_CONSTANT\_TIME\_REG to 0 for additional acceleration)
- – The accelerator speeds up the calculation by simplifying the calculation concerning the 0 bits of Y . Therefore, the higher the proportion of bits 0 against bits 1, the better is the acceleration performance.
- – Note that this option also compromises the security because its time cost correlates with the 0/1 distribution of the key, which can be used in a Side Channel Attack (SCA), thus should not be enabled for applications with high security requirement.

Below is an example to demonstrate the performance of the RSA accelerator under different combinations of SEARCH and CONSTANT\_TIME configuration. Here we perform Z = X Y mod M with N = 3072 and Y = 65537. Table 22.3-1 below demonstrates the time costs under different combinations of SEARCH and CONSTANT\_TIME configuration. Here, we should also mention that, α is set to 16 when the SEARCH option is enabled.

Table 22.3-1. Acceleration Performance

| SEARCH Option   | CONSTANT_TIME Option   |   Time Cost (ms) |
|-----------------|------------------------|------------------|
| No acceleration | No acceleration        |           752.81 |
| Accelerated     | No acceleration        |             4.52 |
| No acceleration | Acceleration           |             2.41 |
| Acceleration    | Acceleration           |             2.33 |

![Image](images/22_Chapter_22_img001_f9ae5d95.png)

## It is obvious that:

- The time cost is biggest when none of these two options is configured for additional acceleration.
- The time cost is smallest when both of these two options are configured for additional acceleration.
- The time cost can be dramatically reduced when either or both option(s) are configured for additional acceleration.

![Image](images/22_Chapter_22_img002_17e052ac.png)

## 22.4 Memory Summary

The addresses in this section are relative to the RSA accelerator base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

Table 22.4-1. RSA Accelerator Memory Blocks

| Name      | Description   |   Size (byte) | Starting Address   | Ending Address   | Access   |
|-----------|---------------|---------------|--------------------|------------------|----------|
| RSA_M_MEM | Memory M      |           384 | 0x0000             | 0x017F           | R/W      |
| RSA_Z_MEM | Memory Z      |           384 | 0x0200             | 0x037F           | R/W      |
| RSA_Y_MEM | Memory Y      |           384 | 0x0400             | 0x057F           | R/W      |
| RSA_X_MEM | Memory X      |           384 | 0x0600             | 0x077F           | R/W      |

## 22.5 Register Summary

The addresses in this section are relative to the RSA accelerator base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                              | Description                         | Address                           | Access                            |
|-----------------------------------|-------------------------------------|-----------------------------------|-----------------------------------|
| Control / Configuration Registers | Control / Configuration Registers   | Control / Configuration Registers | Control / Configuration Registers |
| RSA_M_PRIME_REG                   | Represents M’                       | 0x0800                            | R/W                               |
| RSA_MODE_REG                      | Configures RSA length               | 0x0804                            | R/W                               |
| RSA_SET_START_MODEXP_REG          | Starts modular exponentiation       | 0x080C                            | WT                                |
| RSA_SET_START_MODMULT_REG         | Starts modular multiplication       | 0x0810                            | WT                                |
| RSA_SET_START_MULT_REG            | Starts multiplication               | 0x0814                            | WT                                |
| RSA_QUERY_IDLE_REG                | Represents the RSA status           | 0x0818                            | RO                                |
| RSA_CONSTANT_TIME_REG             | Configures the constant_time option | 0x0820                            | R/W                               |
| RSA_SEARCH_ENABLE_REG             | Configures the search option        | 0x0824                            | R/W                               |
| RSA_SEARCH_POS_REG                | Configures the search position      | 0x0828                            | R/W                               |
| Status Register                   | Status Register                     | Status Register                   | Status Register                   |
| RSA_QUERY_CLEAN_REG               | RSA initialization status           | 0x0808                            | RO                                |
| Interrupt Registers               | Interrupt Registers                 | Interrupt Registers               | Interrupt Registers               |
| RSA_INT_CLR_REG                   | Clears RSA interrupt                | 0x081C                            | WT                                |
| RSA_INT_ENA_REG                   | Enables the RSA interrupt           | 0x082C                            | R/W                               |
| Version Control Register          | Version Control Register            | Version Control Register          | Version Control Register          |
| RSA_DATE_REG                      | Version control register            | 0x0830                            | R/W                               |

## 22.6 Registers

The addresses in this section are relative to the RSA accelerator base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 22.1. RSA\_M\_PRIME\_REG (0x0800)

![Image](images/22_Chapter_22_img003_92f55e4b.png)

RSA\_M\_PRIME Represents M'. (R/W)

Register 22.2. RSA\_MODE\_REG (0x0804)

![Image](images/22_Chapter_22_img004_13dce485.png)

RSA\_MODE Configures the RSA length. (R/W)

Register 22.3. RSA\_SET\_START\_MODEXP\_REG (0x080C)

![Image](images/22_Chapter_22_img005_c2bbb94b.png)

RSA\_SET\_START\_MODEXP Configures whether or not to starts the modular exponentiation.

- 0: No effect
- 1: Start

(WT)

## Register 22.4. RSA\_SET\_START\_MODMULT\_REG (0x0810)

![Image](images/22_Chapter_22_img006_758e9c08.png)

RSA\_SET\_START\_MODMULT Configures whether or not to start the modular multiplication.

- 0: No effect
- 1: Start
- (WT)

## Register 22.5. RSA\_SET\_START\_MULT\_REG (0x0814)

![Image](images/22_Chapter_22_img007_d6f89da1.png)

RSA\_SET\_START\_MULT Configures whether or not to start the multiplication.

- 0: No effect
- 1: Start
- (WT)

## Register 22.6. RSA\_QUERY\_IDLE\_REG (0x0818)

![Image](images/22_Chapter_22_img008_4ddbc42e.png)

## RSA\_QUERY\_IDLE Represents the RSA status.

- 0: Busy
- 1: Idle
- (RO)

Register 22.7. RSA\_CONSTANT\_TIME\_REG (0x0820)

![Image](images/22_Chapter_22_img009_bf03550d.png)

RSA\_CONSTANT\_TIME Configures the constant\_time option.

- 0: Acceleration
- 1: No acceleration (default)

(R/W)

Register 22.8. RSA\_SEARCH\_ENABLE\_REG (0x0824)

![Image](images/22_Chapter_22_img010_877a5414.png)

## RSA\_SEARCH\_ENABLE Configures the search option.

- 0: No acceleration (default)
- 1: Acceleration

This option should be used together with RSA\_SEARCH\_POS\_REG. (R/W)

Register 22.9. RSA\_SEARCH\_POS\_REG (0x0828)

![Image](images/22_Chapter_22_img011_5f4cc7c5.png)

RSA\_SEARCH\_POS Configures the starting address to start search. This field should be used together with RSA\_SEARCH\_ENABLE\_REG. The field is only valid when RSA\_SEARCH\_ENABLE is high. (R/W)

## Register 22.10. RSA\_QUERY\_CLEAN\_REG (0x0808)

![Image](images/22_Chapter_22_img012_9944d250.png)
