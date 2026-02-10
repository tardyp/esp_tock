---
chapter: 26
title: "Chapter 26"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 26

## Random Number Generator (RNG)

## 26.1 Introduction

The ESP32-C6 contains a true random number generator, which generates 32-bit random numbers that can be used for cryptographical operations, among other things.

## 26.2 Features

The random number generator in ESP32-C6 generates true random numbers, which means random numbers generated from a physical process, rather than by means of an algorithm. No number generated within the specified range is more or less likely to appear than any other number.

## 26.3 Functional Description

Every 32-bit value that the system reads from the LPPERI\_RNG\_DATA\_REG register of the random number generator is a true random number. These true random numbers are generated based on the thermal noise in the system and the asynchronous clock mismatch .

- Thermal noise comes from the high-speed ADC or SAR ADC or both. Whenever the high-speed ADC or SAR ADC is enabled, bit streams will be generated and fed into the random number generator through an XOR logic gate as random seeds.
- RC\_FAST\_CLK is an asynchronous clock source and it increases the RNG entropy by introducing circuit metastability.

Figure 26.3-1. Noise Source

![Image](images/26_Chapter_26_img001_c4a829ee.png)

When there is noise coming from the SAR ADC, the random number generator is fed with a 2-bit entropy in one clock cycle of RC\_FAST\_CLK, which is generated from an internal RC oscillator (see Chapter 8 Reset and

![Image](images/26_Chapter_26_img002_e4390afe.png)

Clock for details). Thus, it is advisable to read the LPPERI\_RNG\_DATA\_REG register at a maximum rate of 1 MHz to obtain the maximum entropy.

When there is noise coming from the high-speed ADC, the random number generator is fed with a 2-bit entropy in one APB clock cycle, which is normally 80 MHz. Thus, it is advisable to read the LPPERI\_RNG\_DATA\_REG register at a maximum rate of 5 MHz to obtain the maximum entropy.

A data sample of 2 GB, which is read from the random number generator at a rate of 5 MHz with only the high-speed ADC being enabled, has been tested using the Dieharder Random Number Testsuite (version 3.31.1). The sample passed all tests.

## 26.4 Programming Procedure

When using the random number generator, make sure at least either the SAR ADC, high-speed ADC 1 is enabled. Otherwise, pseudo-random numbers will be returned.

- SAR ADC can be enabled by using the DIG ADC controller. For details, please refer to Chapter 39 On-Chip Sensor and Analog Signal Processing .
- High-speed ADC is enabled automatically when the Wi-Fi or Bluetooth module is enabled.

## Note:

Note that, when the Wi-Fi module is enabled, the value read from the high-speed ADC can be saturated in some extreme cases, which lowers the entropy. Thus, it is advisable to also enable the SAR ADC as the noise source for the random number generator for such cases.

When using the random number generator, read the LPPERI\_RNG\_DATA\_REG register multiple times until sufficient random numbers have been generated. Ensure the rate at which the register is read does not exceed the frequencies described in section 26.3 above.

## 26.5 Register Summary

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                | Description        | Address     | Access   |
|---------------------|--------------------|-------------|----------|
| LPPERI_RNG_DATA_REG | Random number data | 0x600B_2808 | RO       |

## 26.6 Register

![Image](images/26_Chapter_26_img003_770eb30d.png)

## Part V

## Connectivity Interface

This part addresses the connectivity aspects of the system, describing components related to various communication interfaces like I2C, I2S, SPI, UART, USB, and more. The part also covers interfaces to generate signals used in remote control, motor control, LED control, etc.
