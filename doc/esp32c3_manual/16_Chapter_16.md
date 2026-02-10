---
chapter: 16
title: "Chapter 16"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 16

## System Registers (SYSREG)

## 16.1 Overview

The ESP32-C3 integrates a large number of peripherals, and enables the control of individual peripherals to achieve optimal characteristics in performance-vs-power-consumption scenarios. Specifically, ESP32-C3 has various system configuration registers that can be used for the chip's clock management (clock gating), power management, and the configuration of peripherals and core-system modules. This chapter lists all these system registers and their functions.

## 16.2 Features

ESP32-C3 system registers can be used to control the following peripheral blocks and core modules:

- System and memory
- Clock
- Software Interrupt
- Low-power management
- Peripheral clock gating and reset

## 16.3 Function Description

## 16.3.1 System and Memory Registers

## 16.3.1.1 Internal Memory

The following registers can be used to control ESP32-C3’s internal memory:

- In register SYSCON\_CLKGATE\_FORCE\_ON\_REG:
- – Setting different bits of the SYSCON\_ROM\_CLKGATE\_FORCE\_ON field forces on the clock gates of different blocks of Internal ROM 0 and Internal ROM 1.
- – Setting different bits of the SYSCON\_SRAM\_CLKGATE\_FORCE\_ON field forces on the clock gates of different blocks of Internal SRAM.
- – This means when the respective bits of this register are set to 1, the clock gate of the corresponding ROM or SRAM blocks will always be on. Otherwise, the clock gate will turn on automatically when the corresponding ROM or SRAM blocks are accessed and turn off

automatically when the corresponding ROM or SRAM blocks are not accessed. Therefore, it's recommended to configure these bits to 0 to lower power consumption.

- In register SYSCON\_MEM\_POWER\_DOWN\_REG:
- – Setting different bits of the SYSCON\_ROM\_POWER\_DOWN field sends different blocks of Internal ROM 0 and Internal ROM 1 into retention state.
- – Setting different bits of the SYSCON\_SRAM\_POWER\_DOWN field sends different blocks of Internal SRAM into retention state.
- – The "Retention" state is a low-power state of a memory block. In this state, the memory block still holds all the data stored but cannot be accessed, thus reducing the power consumption. Therefore, you can send a certain block of memory into the retention state to reduce power consumption if you know you are not going to use such memory block for some time.
- In register SYSCON\_MEM\_POWER\_UP\_REG:
- – By default, all memory enters low-power state when the chip enters the Light-sleep mode.
- – Setting different bits of the SYSCON\_ROM\_POWER\_UP field forces different blocks of Internal ROM 0 and Internal ROM 1 to work as normal (do not enter the retention state) when the chip enters Light-sleep.
- – Setting different bits of the SYSCON\_SRAM\_POWER\_UP field forces different blocks of Internal SRAM to work as normal (do not enter the retention state) when the chip enters Light-sleep.

For detailed information about the controlling bits of different blocks, please see Table 16.3-1 below.

Table 16.3-1. Memory Controlling Bit

| Memory       | Lowest Address1   | Highest Address1   | Lowest Address2   | Highest Address2   | Controlling Bit   |
|--------------|-------------------|--------------------|-------------------|--------------------|-------------------|
| ROM 0        | 0x4000_0000       | 0x4003_FFFF        | -                 | -                  | Bit0              |
| ROM 1        | 0x4004_0000       | 0x4005_FFFF        | 0x3FF0_0000       | 0x3FF1_FFFF        | Bit1              |
| SRAM Block 0 | 0x4037_C000       | 0x4037_FFFF        | -                 | -                  | Bit0              |
| SRAM Block 1 | 0x4038_0000       | 0x4039_FFFF        | 0x3FC8_0000       | 0x3FC9_FFFF        | Bit1              |
| SRAM Block 2 | 0x403A_0000       | 0x403B_FFFF        | 0x3FCA_0000       | 0x3FCB_FFFF        | Bit2              |
| SRAM Block 3 | 0x403C_0000       | 0x403D_FFFF        | 0x3FCC_0000       | 0x3FCD_FFFF        | Bit3              |

For more information, please refer to Chapter 3 System and Memory .

## 16.3.1.2 External Memory

SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG configures encryption and decryption options of the external memory. For details, please refer to Chapter 23 External Memory Encryption and Decryption (XTS\_AES) .

## 16.3.1.3 RSA Memory

SYSTEM\_RSA\_PD\_CTRL\_REG controls the SRAM memory in the RSA accelerator.

- Setting the SYSTEM\_RSA\_MEM\_PD bit to send the RSA memory into retention state. This bit has the lowest priority, meaning it can be masked by the SYSTEM\_RSA\_MEM\_FORCE\_PU field. This bit is invalid when the Digital Signature (DS) occupies the RSA.

- Setting the SYSTEM\_RSA\_MEM\_FORCE\_PU bit to force the RSA memory to work as normal when the chip enters light sleep. This bit has the second highest priority, meaning it overrides the SYSTEM\_RSA\_MEM\_PD field.
- Setting the SYSTEM\_RSA\_MEM\_FORCE\_PD bit to send the RSA memory into retention state. This bit has the highest priority, meaning it sends the RSA memory into retention state regardless of the SYSTEM\_RSA\_MEM\_FORCE\_PU field.

## 16.3.2 Clock Registers

The following registers are used to set clock sources and frequency. For more information, please refer to Chapter 6 Reset and Clock .

- SYSTEM\_CPU\_PER\_CONF\_REG
- SYSTEM\_SYSCLK\_CONF\_REG
- SYSTEM\_BT\_LPCK\_DIV\_FRAC\_REG

## 16.3.3 Interrupt Signal Registers

The following registers are used for generating the interrupt signals (software interrupt), which then can be routed to the CPU peripheral interrupts via the interrupt matrix. To be more specific, writing 1 to any of the following registers generates an interrupt signal. Therefore, these registers can be used by software to control interrupts. The following registers correspond to the interrupt source SW\_INTR\_0/1/2/3. For more information, please refer to Chapter 8 Interrupt Matrix (INTERRUPT) .

- SYSTEM\_CPU\_INTR\_FROM\_CPU\_0\_REG
- SYSTEM\_CPU\_INTR\_FROM\_CPU\_1\_REG
- SYSTEM\_CPU\_INTR\_FROM\_CPU\_2\_REG
- SYSTEM\_CPU\_INTR\_FROM\_CPU\_3\_REG

## 16.3.4 Low-power Management Registers

The following registers are used for low-power management. For more information, please refer to Chapter 9 Low-power Management .

- SYSTEM\_RTC\_FASTMEM\_CONFIG\_REG: configures the RTC CRC check.
- SYSTEM\_RTC\_FASTMEM\_CRC\_REG: configures the CRC check value.

## 16.3.5 Peripheral Clock Gating and Reset Registers

The following registers are used for controlling the clock gating and reset of different peripherals. Details can be seen in Table 16.3-2 .

- SYSTEM\_CACHE\_CONTROL\_REG
- SYSTEM\_PERIP\_CLK\_EN0\_REG
- SYSTEM\_PERIP\_RST\_EN0\_REG

- SYSTEM\_PERIP\_CLK\_EN1\_REG
- SYSTEM\_PERIP\_RST\_EN1\_REG

ESP32-C3 features low power consumption. This is why some peripheral clocks are gated (disabled) by default. Before using any of these peripherals, it is mandatory to enable the clock for the given peripheral and release the peripheral from reset state. For details, see the table below:

Table 16.3-2. Clock Gating and Reset Bits

| Component          | Clock Enabling Bit  1      | Reset Controlling Bit  2 3   |
|--------------------|----------------------------|------------------------------|
| CACHE Control      | SYSTEM_CACHE_CONTROL_REG   | SYSTEM_CACHE_CONTROL_REG     |
| DCACHE             | SYSTEM_DCACHE_CLK_ON       | SYSTEM_DCACHE_RESET          |
| ICACHE             | SYSTEM_ICACHE_CLK_ON       | SYSTEM_ICACHE_RESET          |
| CPU                | SYSTEM_CPU_PERI_CLK_EN_REG | SYSTEM_CPU_PERI_RST_EN_REG   |
| DEBUG_ASSIST       | SYSTEM_CLK_EN_ASSIST_DEBUG | SYSTEM_RST_EN_ASSIST_DEBUG   |
| Peripherals        | SYSTEM_PERIP_CLK_EN0_REG   | SYSTEM_PERIP_RST_EN0_REG     |
| TIMER              | SYSTEM_TIMERS_CLK_EN       | SYSTEM_TIMERS_RST            |
| SPI0 / SPI1        | SYSTEM_SPI01_CLK_EN        | SYSTEM_SPI01_RST             |
| UART0              | SYSTEM_UART_CLK_EN         | SYSTEM_UART_RST              |
| UART1              | SYSTEM_UART1_CLK_EN        | SYSTEM_UART1_RST             |
| I2S                | SYSTEM_I2S0_CLK_EN         | SYSTEM_I2S0_RST              |
| SPI2               | SYSTEM_SPI2_CLK_EN         | SYSTEM_SPI2_RST              |
| I2C0               | SYSTEM_EXT0_CLK_EN         | SYSTEM_EXT0_RST              |
| UHCI0              | SYSTEM_UHCI0_CLK_EN        | SYSTEM_UHCI0_RST             |
| RMT                | SYSTEM_RMT_CLK_EN          | SYSTEM_RMT_RST               |
| LED PWM Controller | SYSTEM_LEDC_CLK_EN         | SYSTEM_LEDC_RST              |
| Timer Group0       | SYSTEM_TIMERGROUP_CLK_EN   | SYSTEM_TIMERGROUP_RST        |
| Timer Group1       | SYSTEM_TIMERGROUP1_CLK_EN  | SYSTEM_TIMERGROUP1_RST       |
| TWAI Controller    | SYSTEM_CAN_CLK_EN          | SYSTEM_CAN_RST               |
| USB_DEVICE         | SYSTEM_USB_DEVICE_CLK_EN   | SYSTEM_USB_DEVICE_RST        |
| UART MEM           | SYSTEM_UART_MEM_CLK_EN  4  | SYSTEM_UART_MEM_RST          |
| APB SARADC         | SYSTEM_APB_SARADC_CLK_EN   | SYSTEM_APB_SARADC_RST        |
| ADC Controller     | SYSTEM_ADC2_ARB_CLK_EN     | SYSTEM_ADC2_ARB_RST          |
| System Timer       | SYSTEM_SYSTIMER_CLK_EN     | SYSTEM_SYSTIMER_RST          |
| Accelerators       | SYSTEM_PERIP_CLK_EN1_REG   | SYSTEM_PERIP_RST_EN1_REG     |
| TSENS              | SYSTEM_TSENS_CLK_EN        | SYSTEM_TSENS_RST             |
| DMA                | SYSTEM_DMA_CLK_EN          | SYSTEM_DMA_RST 5             |
| HMAC               | SYSTEM_CRYPTO_HMAC_CLK_EN  | SYSTEM_CRYPTO_HMAC_RST  6    |
| Digital Signature  | SYSTEM_CRYPTO_DS_CLK_EN    | SYSTEM_CRYPTO_DS_RST  7      |
| RSA Accelerator    | SYSTEM_CRYPTO_RSA_CLK_EN   | SYSTEM_CRYPTO_RSA_RST        |
| SHA Accelerator    | SYSTEM_CRYPTO_SHA_CLK_EN   | SYSTEM_CRYPTO_SHA_RST        |
| AES Accelerator    | SYSTEM_CRYPTO_AES_CLK_EN   | SYSTEM_CRYPTO_AES_RST        |

Cont’d on next page

## Component

## Table 16.3-2 – cont’d from previous page

## Clock Enabling Bit

1

## Reset Controlling Bit 2 3

- 1 Set the clock enable bit to 1 to enable the clock, and to 0 to disable the clock;
- 2 Set the reset enabling bit to 1 to reset a peripheral, and to 0 to disable the reset.
- 3 Reset registers cannot be cleared by hardware. Therefore, SW reset clear is required after setting the reset registers.
- 4 UART memory is shared by all UART peripherals, meaning having any active UART peripherals will prevent the UART memory from entering the clock-gated state.
- 5 When DMA is required for periphral communications, for example, UCHI0, SPI2, I2S, AES, SHA, and ADC, DMA clock should also be enabled.
- 6 Resetting this bit also resets the SHA accelerator.
- 7 Resetting this bit also resets the AES, SHA, and RSA accelerators.

ESP32-C3 TRM (Version 1.3)

## 16.4 Register Summary

The addresses in this section are relative to the base address of system registers provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                                | Description                                                  | Address   | Access   |
|-----------------------------------------------------|--------------------------------------------------------------|-----------|----------|
| Peripheral Clock Control Registers                  |                                                              |           |          |
| SYSTEM_CPU_PERI_CLK_EN_REG                          | CPU peripheral clock enable register                         | 0x0000    | R/W      |
| SYSTEM_CPU_PERI_RST_EN_REG                          | CPU peripheral clock reset register                          | 0x0004    | R/W      |
| SYSTEM_PERIP_CLK_EN0_REG                            | System peripheral clock enable register 0                    | 0x0010    | R/W      |
| SYSTEM_PERIP_CLK_EN1_REG                            | System peripheral clock enable register 1                    | 0x0014    | R/W      |
| SYSTEM_PERIP_RST_EN0_REG                            | System peripheral clock reset register 0                     | 0x0018    | R/W      |
| SYSTEM_PERIP_RST_EN1_REG                            | System peripheral clock reset register 1                     | 0x001C    | R/W      |
| SYSTEM_CACHE_CONTROL_REG                            | Cache clock control register                                 | 0x0040    | R/W      |
| Clock Configuration Registers                       |                                                              |           |          |
| SYSTEM_CPU_PER_CONF_REG                             | CPU clock configuration register                             | 0x0008    | R/W      |
| SYSTEM_SYSCLK_CONF_REG                              | System clock configuration register                          | 0x0058    | varies   |
| Low-power Management Registers                      |                                                              |           |          |
| SYSTEM_BT_LPCK_DIV_FRAC_REG                         | Low-power clock configuration register 1                     | 0x0024    | R/W      |
| SYSTEM_RTC_FASTMEM_CONFIG_REG                       | Fast memory CRC configuration register                       | 0x0048    | varies   |
| SYSTEM_RTC_FASTMEM_CRC_REG                          | Fast memory CRC result register                              | 0x004C    | RO       |
| CPU Interrupt Control Registers                     |                                                              |           |          |
| SYSTEM_CPU_INTR_FROM_CPU_0_REG                      | CPU interrupt control register 0                             | 0x0028    | R/W      |
| SYSTEM_CPU_INTR_FROM_CPU_1_REG                      | CPU interrupt control register 1                             | 0x002C    | R/W      |
| SYSTEM_CPU_INTR_FROM_CPU_2_REG                      | CPU interrupt control register 2                             | 0x0030    | R/W      |
| SYSTEM_CPU_INTR_FROM_CPU_3_REG                      | CPU interrupt control register 3                             | 0x0034    | R/W      |
| System and Memory Control Registers                 |                                                              |           |          |
| SYSTEM_RSA_PD_CTRL_REG                              | RSA memory power control register                            | 0x0038    | R/W      |
| SYSTEM_EXTERNAL_DEVICE_ENCRYPT_ DECRYPT_CONTROL_REG | External memory encryption and decryp tion control register | 0x0044    | R/W      |
| Clock Gate Control Register                         |                                                              |           |          |
| SYSTEM_CLOCK_GATE_REG                               | Clock gate control register                                  | 0x0054    | R/W      |
| Date Register                                       |                                                              |           |          |
| SYSTEM_DATE_REG                                     | Version register                                             | 0x0FFC    | R/W      |

The addresses below are relative to the base address of apb control provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                        | Description                                | Address   | Access   |
|-----------------------------|--------------------------------------------|-----------|----------|
| Configuration Register      |                                            |           |          |
| SYSCON_CLKGATE_FORCE_ON_REG | Internal memory clock gate enable register | 0x00A4    | R/W      |
| SYSCON_MEM_POWER_DOWN_REG   | Internal memory control register           | 0x00A8    | R/W      |

| Name                    | Description                      | Address   | Access   |
|-------------------------|----------------------------------|-----------|----------|
| SYSCON_MEM_POWER_UP_REG | Internal memory control register | 0x00AC    | R/W      |

## 16.5 Registers

The addresses below are relative to the base address of system register provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 16.1. SYSTEM\_CPU\_PERI\_CLK\_EN\_REG (0x0000)

![Image](images/16_Chapter_16_img001_8b0e48e5.png)

SYSTEM\_CLK\_EN\_ASSIST\_DEBUG Set this bit to enable the ASSIST\_DEBUG clock. Please see Chapter 17 Debug Assistant (ASSIST\_DEBUG) for more information about ASSIST\_DEBUG. (R/W)

Register 16.2. SYSTEM\_CPU\_PERI\_RST\_EN\_REG (0x0004)

![Image](images/16_Chapter_16_img002_f90112dd.png)

SYSTEM\_RST\_EN\_ASSIST\_DEBUG Set this bit to reset the ASSIST\_DEBUG clock. Please see Chapter 17 Debug Assistant (ASSIST\_DEBUG) for more information about ASSIST\_DEBUG. (R/W)

Register 16.3. SYSTEM\_PERIP\_CLK\_EN0\_REG (0x0010)

![Image](images/16_Chapter_16_img003_fd31f2dd.png)

SYSTEM\_TIMERS\_CLK\_EN Set this bit to enable TIMERS clock. (R/W)

SYSTEM\_SPI01\_CLK\_EN Set this bit to enable SPI0 / SPI1 clock. (R/W)

SYSTEM\_UART\_CLK\_EN Set this bit to enable UART clock. (R/W)

SYSTEM\_UART1\_CLK\_EN Set this bit to enable UART1 clock. (R/W)

SYSTEM\_SPI2\_CLK\_EN Set this bit to enable SPI2 clock. (R/W)

SYSTEM\_EXT0\_CLK\_EN Set this bit to enable I2C\_EXT0 clock. (R/W)

SYSTEM\_UHCI0\_CLK\_EN Set this bit to enable UHCI0 clock. (R/W)

SYSTEM\_RMT\_CLK\_EN Set this bit to enable RMT clock. (R/W)

SYSTEM\_LEDC\_CLK\_EN Set this bit to enable LEDC clock. (R/W)

SYSTEM\_TIMERGROUP\_CLK\_EN Set this bit to enable TIMER GROUP clock. (R/W)

SYSTEM\_TIMERGROUP1\_CLK\_EN Set this bit to enable TIMERGROUP1 clock. (R/W)

SYSTEM\_CAN\_CLK\_EN Set this bit to enable TWAI clock. (R/W)

SYSTEM\_I2S0\_CLK\_EN Set this bit to enable I2S clock. (R/W)

SYSTEM\_USB\_DEVICE\_CLK\_EN Set this bit to enable USB DEVICE clock. (R/W)

SYSTEM\_UART\_MEM\_CLK\_EN Set this bit to enable UART\_MEM clock. (R/W)

SYSTEM\_SPI3\_DMA\_CLK\_EN Set this bit to enable SPI3 DMA clock. (R/W)

SYSTEM\_APB\_SARADC\_CLK\_EN Set this bit to enable APB\_SARADC clock. (R/W)

SYSTEM\_SYSTIMER\_CLK\_EN Set this bit to enable SYSTEMTIMER clock. (R/W)

SYSTEM\_ADC2\_ARB\_CLK\_EN Set this bit to enable ADC2\_ARB clock. (R/W)

Register 16.4. SYSTEM\_PERIP\_CLK\_EN1\_REG (0x0014)

![Image](images/16_Chapter_16_img004_82c99980.png)

SYSTEM\_CRYPTO\_AES\_CLK\_EN Set this bit to enable AES clock. (R/W)

SYSTEM\_CRYPTO\_SHA\_CLK\_EN Set this bit to enable SHA clock. (R/W)

SYSTEM\_CRYPTO\_RSA\_CLK\_EN Set this bit to enable RSA clock. (R/W)

SYSTEM\_CRYPTO\_DS\_CLK\_EN Set this bit to enable DS clock. (R/W)

SYSTEM\_CRYPTO\_HMAC\_CLK\_EN Set this bit to enable HMAC clock. (R/W)

SYSTEM\_DMA\_CLK\_EN Set this bit to enable DMA clock. (R/W)

SYSTEM\_TSENS\_CLK\_EN Set this bit to enable TSENS clock. (R/W)

## Register 16.5. SYSTEM\_PERIP\_RST\_EN0\_REG (0x0018)

![Image](images/16_Chapter_16_img005_bccf0df7.png)

SYSTEM\_TIMERS\_RST Set this bit to reset TIMERS. (R/W)

SYSTEM\_SPI01\_RST Set this bit to reset SPI0 / SPI1. (R/W)

SYSTEM\_UART\_RST Set this bit to reset UART. (R/W)

SYSTEM\_UART1\_RST Set this bit to reset UART1. (R/W)

SYSTEM\_SPI2\_RST Set this bit to reset SPI2. (R/W)

SYSTEM\_EXT0\_RST Set this bit to reset I2C\_EXT0. (R/W)

SYSTEM\_UHCI0\_RST Set this bit to reset UHCI0. (R/W)

SYSTEM\_RMT\_RST Set this bit to reset RMT. (R/W)

SYSTEM\_LEDC\_RST Set this bit to reset LEDC. (R/W)

SYSTEM\_TIMERGROUP\_RST Set this bit to reset TIMERGROUP. (R/W)

SYSTEM\_TIMERGROUP1\_RST Set this bit to reset TIMERGROUP1. (R/W)

SYSTEM\_CAN\_RST Set this bit to reset CAN. (R/W)

SYSTEM\_I2S0\_RST Set this bit to reset I2S. (R/W)

SYSTEM\_USB\_DEVICE\_RST Set this bit to reset USB DEVICE. (R/W)

SYSTEM\_UART\_MEM\_RST Set this bit to reset UART\_MEM. (R/W)

SYSTEM\_SPI3\_DMA\_RST Set this bit to reset SPI3. (R/W)

SYSTEM\_APB\_SARADC\_RST Set this bit to reset APB\_SARADC. (R/W)

SYSTEM\_SYSTIMER\_RST Set this bit to reset SYSTIMER. (R/W)

SYSTEM\_ADC2\_ARB\_RST Set this bit to reset ADC2\_ARB. (R/W)

Register 16.6. SYSTEM\_PERIP\_RST\_EN1\_REG (0x001C)

![Image](images/16_Chapter_16_img006_13fc070e.png)

SYSTEM\_CRYPTO\_AES\_RST Set this bit to reset CRYPTO\_AES. (R/W)

SYSTEM\_CRYPTO\_SHA\_RST Set this bit to reset CRYPTO\_SHA. (R/W) SYSTEM\_CRYPTO\_RSA\_RST Set this bit to reset CRYPTO\_RSA. (R/W) SYSTEM\_CRYPTO\_DS\_RST Set this bit to reset CRYPTO\_DS. (R/W) SYSTEM\_CRYPTO\_HMAC\_RST Set this bit to reset CRYPTO\_HMAC. (R/W)

SYSTEM\_DMA\_RST Set this bit to reset DMA. (R/W)

SYSTEM\_TSENS\_RST Set this bit to reset TSENS. (R/W)

Register 16.7. SYSTEM\_CACHE\_CONTROL\_REG (0x0040)

![Image](images/16_Chapter_16_img007_8fdfc951.png)

SYSTEM\_ICACHE\_CLK\_ON Set this bit to enable i-cache clock. (R/W)

SYSTEM\_ICACHE\_RESET Set this bit to reset i-cache. (R/W)

SYSTEM\_DCACHE\_CLK\_ON Set this bit to enable d-cache clock. (R/W)

SYSTEM\_DCACHE\_RESET Set this bit to reset d-cache. (R/W)

## Register 16.8. SYSTEM\_CPU\_PER\_CONF\_REG (0x0008)

![Image](images/16_Chapter_16_img008_e9c2d709.png)

SYSTEM\_CPUPERIOD\_SEL Set this field to select the CPU clock frequency. For details, please refer to Table 6.2-3 in Chapter 6 Reset and Clock.(R/W)

SYSTEM\_PLL\_FREQ\_SEL Set this bit to select the PLL clock frequency. For details, please refer to Table 6.2-3 in Chapter 6 Reset and Clock. (R/W)

SYSTEM\_CPU\_WAIT\_MODE\_FORCE\_ON Set this bit to force on the clock gate of CPU wait mode. Usually, after executing the WFI instruction, CPU enters the wait mode, during which the clock gate of CPU is turned off until any interrupts occur. In this way, power consumption is saved. However, if this bit is set, the clock gate of CPU is always on and will not be turned off by the WFI instruction. (R/W)

SYSTEM\_CPU\_WAITI\_DELAY\_NUM Sets the number of delay cycles to turn off the CPU clock gate after the CPU enters the wait mode because of a WFI instruction. (R/W)

## Register 16.9. SYSTEM\_BT\_LPCK\_DIV\_FRAC\_REG (0x0024)

![Image](images/16_Chapter_16_img009_937f83c9.png)

SYSTEM\_LPCLK\_SEL\_RTC\_SLOW Set this bit to select RTC\_SLOW\_CLK as the low-power clock. (R/W)

SYSTEM\_LPCLK\_SEL\_8M Set this bit to select RC\_FAST\_CLK div n clock as the low-power clock. (R/W)

SYSTEM\_LPCLK\_SEL\_XTAL Set this bit to select XTAL clock as the low-power clock. (R/W)

SYSTEM\_LPCLK\_SEL\_XTAL32K Set this bit to select xtal32k clock as the low-power clock. (R/W)

SYSTEM\_LPCLK\_RTC\_EN Set this bit to enable the LOW\_POWER\_CLK clock. (R/W)

## Register 16.10. SYSTEM\_SYSCLK\_CONF\_REG (0x0058)

![Image](images/16_Chapter_16_img010_be928dc8.png)

SYSTEM\_PRE\_DIV\_CNT This field is used to set the count of prescaler of XTAL\_CLK. For details, please refer to Table 6.2-3 in Chapter 6 Reset and Clock. (R/W)

SYSTEM\_SOC\_CLK\_SEL This field is used to select SOC clock. For details, please refer to Table 6.2-1 in Chapter 6 Reset and Clock. (R/W)

SYSTEM\_CLK\_XTAL\_FREQ This field is used to read XTAL frequency in MHz. (RO)

## Register 16.11. SYSTEM\_RTC\_FASTMEM\_CONFIG\_REG (0x0048)

![Image](images/16_Chapter_16_img011_6f8e1762.png)

SYSTEM\_RTC\_MEM\_CRC\_START Set this bit to start the CRC of RTC memory. (R/W)

SYSTEM\_RTC\_MEM\_CRC\_ADDR This field is used to set address of RTC memory for CRC. (R/W)

SYSTEM\_RTC\_MEM\_CRC\_LEN This field is used to set length of RTC memory for CRC based on start address. (R/W)

SYSTEM\_RTC\_MEM\_CRC\_FINISH This bit stores the status of RTC memory CRC. High level means finished while low level means not finished. (RO)

![Image](images/16_Chapter_16_img012_643947d6.png)

![Image](images/16_Chapter_16_img013_a0a1474c.png)

## Register 16.17. SYSTEM\_RSA\_PD\_CTRL\_REG (0x0038)

![Image](images/16_Chapter_16_img014_149cdbe1.png)

SYSTEM\_RSA\_MEM\_PD Set this bit to send the RSA memory into retention state. This bit has the lowest priority, meaning it can be masked by the SYSTEM\_RSA\_MEM\_FORCE\_PU field. When Digital Signature occupies the RSA, this bit is invalid. (R/W)

SYSTEM\_RSA\_MEM\_FORCE\_PU Set this bit to force the RSA memory to work as normal when the chip enters light sleep. This bit has the second highest priority, meaning it overrides the SYSTEM\_RSA\_MEM\_PD field. (R/W)

SYSTEM\_RSA\_MEM\_FORCE\_PD Set this bit to send the RSA memory into retention state. This bit has the highest priority, meaning it sends the RSA memory into retention state regardless of the SYSTEM\_RSA\_MEM\_FORCE\_PU field. (R/W)

## Register 16.18. SYSTEM\_EXTERNAL\_DEVICE\_ENCRYPT\_DECRYPT\_CONTROL\_REG (0x0044)

![Image](images/16_Chapter_16_img015_ee3b0dae.png)

- SYSTEM\_ENABLE\_SPI\_MANUAL\_ENCRYPT Set this bit to enable Manual Encryption under SPI Boot mode. (R/W)

SYSTEM\_ENABLE\_DOWNLOAD\_DB\_ENCRYPT Set this bit to enable Auto Encryption under Download Boot mode. (R/W)

SYSTEM\_ENABLE\_DOWNLOAD\_G0CB\_DECRYPT Set this bit to enable Auto Decryption under Download Boot mode. (R/W)

SYSTEM\_ENABLE\_DOWNLOAD\_MANUAL\_ENCRYPT Set this bit to enable Manual Encryption under Download Boot mode. (R/W)

## Register 16.19. SYSTEM\_CLOCK\_GATE\_REG (0x0054)

![Image](images/16_Chapter_16_img016_f78c9285.png)

The addresses below are relative to the base address of apb control provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 16.21. SYSCON\_CLKGATE\_FORCE\_ON\_REG (0x00A4)

![Image](images/16_Chapter_16_img017_c83f127a.png)

SYSCON\_ROM\_CLKGATE\_FORCE\_ON Set 1 to configure the ROM clock gate to be always on; Set 0 to configure the clock gate to turn on automatically when ROM is accessed and turn off automatically when ROM is not accessed. (R/W)

SYSCON\_SRAM\_CLKGATE\_FORCE\_ON Set 1 to configure the SRAM clock gate to be always on; Set 0 to configure the clock gate to turn on automatically when SRAM is accessed and turn off automatically when SRAM is not accessed. (R/W)

## Register 16.22. SYSCON\_MEM\_POWER\_DOWN\_REG (0x00A8)

![Image](images/16_Chapter_16_img018_2d2904b1.png)

SYSCON\_ROM\_POWER\_DOWN Set this field to send the internal ROM into retention state. (R/W) SYSCON\_SRAM\_POWER\_DOWN Set this field to send the internal SRAM into retention state. (R/W)

Register 16.23. SYSCON\_MEM\_POWER\_UP\_REG (0x00AC)

![Image](images/16_Chapter_16_img019_908a31c5.png)

SYSCON\_ROM\_POWER\_UP Set this field to force the internal ROM to work as normal (do not enter the retention state) when the chip enters light sleep. (R/W)

SYSCON\_SRAM\_POWER\_UP Set this field to force the internal SRAM to work as normal (do not enter the retention state) when the chip enters light sleep. (R/W)
