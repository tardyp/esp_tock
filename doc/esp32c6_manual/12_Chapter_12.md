---
chapter: 12
title: "Chapter 12"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 12

## Low-Power Management

## 12.1 Overview

ESP32-C6 features an advanced low-power management system that can optimize the chip's power consumption while maintaining its high performance.

The low-power management system employs various power-saving techniques such as sleep modes, dynamic voltage and frequency scaling, and peripheral power gating to minimize the chip's power consumption.

The power management unit (PMU) is a hardware component that is the core part of the low-power management system and is responsible for powering up and down different power domains of the chip, to achieve the best balance among chip performance, power consumption, and wake-up latency.

## 12.2 Terminology

The following terms related to low-power management are defined in the context of the ESP32-C6 Technical Reference Manual to help readers better understand this document:

| Low-power management        | Refers to the whole system that manages the chip’s power con sumption.                                                                                 |
|-----------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| Power management unit (PMU) | Refers to the specific hardware module that controls power up and down for the power domains, clocks, and power-related logic.                          |
| Power domain                | Refers to the smallest unit that can be independently powered up or down. A power domain can contain one or multiple modules within the chip.           |
| PMU states                  | Refers to four states of the PMU’s state machine. Users can con figure the clock gating and power gating of a power domain in each of the four states. |
| Power modes                 | Refers to the five preset power modes that power up different domains for typical application scenarios.                                                |

## 12.3 Features

The PMU has the following features:

- Supports four configurable PMU states. Software can flexibly configure them according to the needs.
- – HP\_ACTIVE
- – HP\_MODEM

- – HP\_SLEEP
- – LP\_SLEEP
- Supports five preset power modes that suit various typical usage scenarios:
- – Active
- – Modem-sleep
- – Light-sleep0
- – Light-sleep1
- – Deep-sleep
- 16 KB SRAM
- 10 always-on (AON) registers
- RTC fast boot
- Programmable retention DMA to backup and restore the status of the CPU and peripherals when the chip switches between PMU states
- Supports a power controller that controls the power and clocks depending on the power modes

## 12.4 Functional Description

ESP32-C6’s low-power management involves the following components:

- Power scheme: The power scheme of ESP32-C6 includes power regulators, digital power domains, analog power domains, etc.
- PMU controller: It is the core part of PMU that controls the power up and down of the power domains, clocks, etc.
- One RTC timer
- 10 always-on registers (LP\_AON\_STORE0\_REG ∼ LP\_AON\_STORE9\_REG): These registers are always powered up and are not affected by any low-power modes, thus can be used for storing data that cannot be lost.
- Eight LP GPIO pins (GPIO0 ∼ GPIO7): These pins are always powered up and are not affected by any low-power modes, which makes them suitable for working as wake-up sources when the chip is in low-power modes. These pins can also work as regular GPIOs. For more information about the LP GPIOs, please refer to Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) .
- 16 KB SRAM: The 16 KB SRAM is accessible to both HP CPU and LP CPU. It works under the HP CPU clock when accessed by the HP CPU and under the LP CPU clock when accessed by the LP CPU.
- Brownout detector: It monitors the power of the supply voltage pins, ensuring stable chip operation and preventing the SoC from potential malfunction if subject to glitches or under voltage.

The following sections provide a detailed description of the components mentioned above.

LP sys regulator

## 12.4.1 Power Scheme

Analog xpd\_Ip\_reg

Figure 12.4-1 shows the power scheme of ESP32-C6 that mainly includes:

- Two regulators
- Analog power domains
- Digital power domains

xpd\_ex\_crystyal

Xpd\_rc\_oscillator xpd\_bbli

xpd\_hp\_reg\_mem xpd\_modem

xpd\_Ip\_peri

PMU

LP always-on peripherals

LP always-on

## 12.4.1.1 Regulators

As shown in Figure 12.4-1, the analog part of ESP32-C6 contains two regulators that regulate the power supply to different power domains. The two regulators are:

- One HP sys regulator, used for regulating the power supply to high-performance modules. It features high drive strength, high power consumption, and regulated output power.
- One LP sys regulator, used for regulating the power supply to low-power modules. It also features regulated output power.

![Image](images/12_Chapter_12_img001_40648a3d.png)

–→

: Control signals ––: Power lines

Figure 12.4-1. ESP32-C6 Power Scheme

HP sys regulator

• External Main Clock

Fast RC Oscillator

PLL

RF Circuit

## 12.4.1.2 Digital Power Domains

ESP32-C6 has digital power domains as listed below. The HP sys regulator powers the HP system, and there is an independent power switch between the regulator and each power domain, enabling up/down control of the digital power domain. The LP sys regulator powers the LP system.

- The HP system contains the following digital power domains:
- – CPU: It mainly includes the CPU and its supporting peripherals (such as TRACE).
- – Modem: It consists of wireless MAC and baseband.
- – Peripherals + ROM: It mainly includes bus, HP peripherals.
- – Internal SRAMx: It is divided into four sub-power domains, as shown in Figure 12.4-1, where each of SRAM0/1/2 has an independent power switch, while SRAM3 is directly connected to the regulator without a power switch.
- – Modem Power: It mainly includes modules that control the operating of the wireless section.
- The LP system contains the following digital power domains:
- – LP PD peripherals: It mainly includes LP CPU, LP peripherals.
- – LP always-on: It mainly includes LP always-on peripherals (e.g., RTC timer), PMU controller. This power domain keeps powered on all the time.

## 12.4.1.3 Analog Power Domains

As Figure 12.4-1 shows, ESP32-C6 contains the following analog power domains, among which PLL belongs to the HP system while the other domains belong to the LP system:

- External Main Clock
- Fast RC Oscillator
- PLL
- RF circuit

## 12.4.2 PMU

The PMU of ESP32-C6 controls power consumption-related components of each power domain, such as power and clock. PMU consists of the following major parts:

- PMU main state machine: It records and switches the PMU states.
- Sleep/wake-up controller: It sends sleep or wake-up requests to the PMU main state machine.
- Power controllers: They control the power and clock signals depending on the power modes of the chip. The power controllers include:
- – Digital power controller: It powers up or down the digital power domains.
- – Analog power controller: It enables the analog modules, such as the regulators, analog clocks, etc.
- – Clock controller: It manages the clock gating of peripherals and selects analog clock sources for digital clocks.

- – Data backup controller: It controls the data backup and restore process when the chip switches between PMU states.
- – System controller: It controls some system-level modules, such as suspending watchdog functionality in sleep mode (when the CPU is unavailable).

The PMU workflow involves the sleep/wake-up controller sending sleep or wake-up requests to the PMU main state machine, which then generates power gating, clock gating, and reset signals. The power controllers and clock controller will then power up or down different power domains and clocks based on the signals generated by the PMU main state machine, allowing the chip to enter or exit different low-power modes. The PMU workflow is shown in Figure 12.4-2 .

Figure 12.4-2. PMU Workflow

![Image](images/12_Chapter_12_img002_5349118b.png)

The following sections describe the main parts of PMU.

## 12.4.2.1 PMU Main State Machine

The PMU main state machine can receive sleep and wake-up signals, change the state of power and clock through the power controllers, thereby switching PMU states, and achieving a balance between performance and power consumption of the chip.

![Image](images/12_Chapter_12_img003_411ad234.png)

The PMU main state machine supports four PMU states, each controlled by different sleep and wake-up signals, supporting software customization of power and clocks. These four PMU states allow the software to expand power modes for various application scenarios. The four PMU states are:

- HP\_ACTIVE: PMU state where the circuits on the chip are powered up to a maximum, supporting the HP system and LP system operation.
- HP\_MODEM: PMU state where Modem (wireless MAC and baseband) can operate independently of the CPU.
- HP\_SLEEP: PMU state where the HP system is in sleep, supporting LP peripherals operation.
- LP\_SLEEP: PMU state where HP system and LP peripherals are in sleep, while the always-on circuits remain operational.

## Note:

The division of HP and LP system is as follows:

- LP system (peripherals): LP RISC-V 32-bit Microprocessor, LP Memory, LP IO, LP UART, LP I2C
- LP system (always-on circuits): PMU, RTC Watchdog Timer, Super Watchdog
- HP system: This includes all peripherals (including Modem) except those belonging to LP system.

For more details, please refer to ESP32-C6 Datasheet &gt; Functional Block Diagram .

HP\_ACTIVE, HP\_MODEM, HP\_SLEEP are the states of the HP system, while LP\_SLEEP is the state of the LP system.

- If a module belongs to the HP system, its power up/down can be configured in the HP\_ACTIVE/HP\_MODEM/HP\_SLEEP states, but not in the LP\_SLEEP state. It will reuse the HP\_SLEEP state in the LP\_SLEEP state.
- If a module belongs to the LP system, its power up/down can be configured in the LP\_SLEEP state and will reuse the HP\_SLEEP configuration in the HP\_ACTIVE/HP\_MODEM/HP\_SLEEP states.

Take the HP CPU as an example. The HP CPU belongs to the HP system, so it can be configured to power up/down in the HP\_ACTIVE/HP\_MODEM/HP\_SLEEP states through the following registers and reuse the HP\_SLEEP configuration in LP\_SLEEP.

- HP\_ACTIVE: PMU\_HP\_ACTIVE\_PD\_HP\_CPU\_PD\_EN
- HP\_MODEM: PMU\_HP\_MODEM\_PD\_HP\_CPU\_PD\_EN
- HP\_SLEEP: PMU\_HP\_SLEEP\_PD\_HP\_CPU\_PD\_EN

Similarly, users can define other power domains' power up and down in different PMU states. For specific registers, please refer to Section 12.9 .

## Note:

In the following text, all such registers will be collectively referred to as PMU\_n1\_PD\_POWERDOMAIN\_PD\_EN, where n1 represents the four PMU states.

Once the configuration is done, PMU will use various controllers to make these configurations effective, as

described in the sections below.

## 12.4.2.2 Sleep/Wake-up Controller

The sleep/wake-up controller is responsible for initiating sleep and wake-up requests to the PMU main state machine. ESP32-C6 supports multiple wake sources to wake the CPU from different power modes that can be enabled through PMU\_WAKEUP\_ENA .

Table 12.4-1. Wake-up Sources

| PMU_WAKEUP_ENA   | Wake-up Sources   | Light-sleep   | Deep-sleep   |
|------------------|-------------------|---------------|--------------|
| 0x4              | GPIO 1            | Y             | Y            |
| 0x8              | Wi-Fi beacon      | Y             | Y            |
| 0x10             | RTC Timer         | Y             | Y            |
| 0x20             | Wi-Fi 2           | Y             | –            |
| 0x40             | UART03            | Y             | –            |
| 0x80             | UART1 3           | Y             | –            |
| 0x100            | SDIO              | Y             | –            |
| 0x400            | Bluetooth         | Y             | –            |
| 0x800            | LP CPU            | Y             | Y            |

- 3 A wake-up is triggered when the number of RX pulses received exceeds the threshold set in UART\_ACTIVE\_THRESHOLD. For details, please refer to Chapter 27 UART Controller (UART, LP\_UART, UHCI) .

ESP32-C6 provides a hardware mechanism that can reject sleep, meaning if some peripherals are in an uninterruptible working state and the CPU tries to sleep, the peripherals will send a wake-up signal to prevent the CPU from sleeping, thus ensuring the peripherals work normally.

The wake-up sources in Table 12.4-1 can all be configured as events to reject sleep. Users can configure the following registers to implement sleep rejection. The configuration values of PMU\_SLEEP\_REJECT\_ENA and PMU\_SLP\_REJECT\_CAUSE\_REG and the corresponding wake-up sources are the same as shown in Table 12.4-1 .

- Enable sleep rejection feature:
- – Set PMU\_SLP\_REJECT\_EN to 1 to enable the sleep rejection feature.
- – Configure PMU\_SLEEP\_REJECT\_ENA to enable the sleep rejection signal source.
- Read PMU\_SLP\_REJECT\_CAUSE\_REG for the source of sleep rejection event.

## 12.4.2.3 Analog Power Controller

The analog power controller controls the power up and down of the analog circuits (including voltage regulators, high-speed clocks, and slow-speed clocks) in PMU states.

The configuration of the regulators is as follows:

- Configure PMU\_n1\_HP\_REGULATOR\_XPD or PMU\_n1\_LP\_REGULATOR\_XPD to enable or disable the output voltage of the HP/LP sys regulator in the target PMU state. Turning off the LP sys regulator is not recommended, as it may cause the PMU itself to power down, resulting in chip malfunction.

The configuration of the high-speed clocks (XTAL\_CLK and PLL\_CLK) is as follows:

- XTAL\_CLK: Configure PMU\_HP\_SLEEP\_XPD\_XTAL to 1 to enable XTAL\_CLK when the chip switches PMU state to HP\_SLEEP.

Note: To avoid the instability in XTAL\_CLK during startup, users have the option to configure PMU\_WAIT\_XTAL\_STABLE to delay the gate opening for XTAL\_CLK. This delay ensures that the gate opening is enabled after PMU\_WAIT\_XTAL\_STABLE CLK\_DYN\_FAST\_CLK cycles following the power-up of XTAL\_CLK.

- PLL\_CLK: PMU can enable PLL\_CLK in different PMU states by configuring PMU\_n1\_XPD\_BBPLL to 1. For example, configuring PMU\_HP\_ACTIVE\_XPD\_BBPLL to 1 will enable the PLL\_CLK clock when the chip is in HP\_ACTIVE state.

Note:

- – Before enabling PLL\_CLK please ensure that XTAL\_CLK is stable.
- – To avoid the instability in PLL\_CLK during startup, users have the option to configure PMU\_WAIT\_PLL\_STABLE to delay the gate opening for PLL\_CLK. This delay ensures that the gate opening is enabled after PMU\_WAIT\_PLL\_STABLE CLK\_DYN\_FAST\_CLK cycles following the power-up of PLL\_CLK.

Slow-speed clocks operate with low power. The power up and down of the slow-speed clocks in HP\_ACTIVE, HP\_MODEM, and HP\_SLEEP states are controlled by PMU\_HP\_SLEEP\_XPD\_FOSC\_CLK. In LP\_SLEEP state, the power up and down of the slow-speed clocks are controlled by PMU\_LP\_SLEEP\_XPD\_FOSC\_CLK. For example, PMU\_LP\_SLEEP\_XPD\_FOSC\_CLK controls power up and down of RC\_FAST\_CLK clock in LP\_SLEEP state. The following slow-speed clocks can be configured in LP\_SLEEP:

- RC\_FAST\_CLK
- XTAL32K\_CLK

## 12.4.2.4 Digital Power Controller

The digital power controller controls the power up and down of digital power domains in different PMU states. Unlike the analog power controller, the digital power controller does not directly control the regulator but instead controls the power switch connected to the regulator to power up and down the digital power domains.

Among the digital power domains, the LP PD Peripherals domain can only be powered up and down during the PMU state switch between HP\_SLEEP and LP\_SLEEP PMU, while the other power domains can be powered up and down during the PMU states switch between HP\_SLEEP, HP\_ACTIVE, and HP\_MODEM.

When the chip switches between PMU states, if the power configuration of a power domain in the current PMU state does not match the power configuration it is about to switch to, then the power up-down process will be activated. Take the power up-to-down process of the CPU power domain as an example. Configure

PMU\_HP\_MODEM\_PD\_HP\_CPU\_PD\_EN to 1 or 0 to indicate that the CPU power domain is powered down or up in the HP\_MODEM state. PMU will perform the following configurations:

- Enable the digital isolation unit to ensure that the powered-down modules do not output unstable voltage levels to the powered-up modules. When a power domain loses power, the output of this module will be clamped to a fixed value.
- Enable reset. When the CPU power domain loses power, its global reset signal is set to a reset state, which persists for a period after the CPU power domain is re-powered. This mechanism guarantees a reset-to-release process for the CPU power domain during power-up, effectively mitigating any instability caused by power up-down transitions.

The following will explain the power up and down of each digital power domain:

- Internal SRAMx

The power up and down of the Internal SRAMx domain is not controlled by a dedicated register. The Internal SRAMx domain shares the PMU\_n1\_PD\_TOP\_PD\_EN register with the Peripherals domain. If PMU\_PD\_HP\_MEMn\_PD\_MASK (n=0,1,2) is 0, both the Internal SRAMx and Peripherals power domains are turned up or down simultaneously. If PMU\_PD\_HP\_MEMn\_PD\_MASK is configured as 1, the Internal SRAMx can remain powered up when the Peripherals domain is powered down.

## · Modem Power

Modem Power is connected to the HP sys regulator through a power switch. The power up and down of Modem Power in the HP\_ACTIVE state is determined by PMU\_HP\_ACTIVE\_PD\_HP\_AON\_PD\_EN. From Figure 12.4-1, it can be seen that if any of the CPU, Modem, or Peripherals + ROM power domains needs to be powered up, the Modem Power domain must also be powered up. Such a design meets functional requirements.

- Peripherals + ROM/Modem/CPU:

Each of the three power domains can be powered up and down in different PMU states using the PMU\_n1\_PD\_n\_PD\_EN register (n=TOP/HP\_WIFI/HP\_CPU). "WIFI" in the register represents the Modem Power domain.

When the Peripherals domain is powered down, the following features are configurable:

- – Powering down the Peripherals domain may cause instability in GPIOs. This can be addressed by maintaining the state of the GPIOs (excluding eight LP GPIOs) through PMU. For example, configuring PMU\_HP\_SLEEP\_HP\_PAD\_HOLD\_ALL can keep GPIOs in the same state as before Peripherals was powered down in HP\_SLEEP.
- – In HP\_ACTIVE and HP\_MODEM states, the Internal SRAMx domain can be powered down or put into Deep-sleep mode. In Deep-sleep, the memory cannot be read or written to, but data can be retained. Configure PMU\_n1\_HP\_MEM\_DSLP to enable Memory Deep-sleep mode.
- LP PD Peripherals

The LP PD Peripherals power domain remains powered up when the chip is in HP\_ACTIVE and HP\_MODEM states. The power state of LP PD Peripherals is configurable only in HP\_SLEEP and LP\_SLEEP states. The LP PD Peripherals power domain has an independent digital power switch, and its power control is not dependent on the power state of other digital power domains.

## 12.4.2.5 Clock Controller

The clock controller is mainly used to control high-performance system clocks and lp system clocks when the chip switches between PMU states.

High-performance system clocks include HP\_ROOT\_CLK and high-performance system peripherals clocks. When the chip switches between HP\_ACTIVE, HP\_MODEM, and HP\_SLEEP states, PMU can switch, power up/down, and divide the frequency of HP\_ROOT\_CLK, as well as power up/down high-performance system peripherals clocks.

- HP\_ROOT\_CLK can be controlled as follows:
- – Configure PMU\_n1\_SYS\_CLK\_SLP\_SEL to 1 to indicate that when the chip enters the corresponding PMU state, the clock source is controlled by PMU.
- – Configure PMU\_n1\_ICG\_SYS\_CLOCK\_EN to 0 to disable HP\_ROOT\_CLK in the corresponding PMU state.
- – Configure PMU\_n1\_DIG\_SYS\_CLK\_SEL to select the clock source after the chip enters the corresponding PMU state. For details, please refer to Chapter 8 Reset and Clock &gt; Table 8.2-1 .
- High-performance system peripheral clocks can be controlled as follows:
- – Configure PMU\_n1\_ICG\_SLP\_SEL to 1 so that the clock gating in the target state will be controlled by PMU. Configure this register to 0 so that the clock gating is controlled by PCR registers.
- – Configure PMU\_n1\_DIG\_ICG\_FUNC\_EN to power up/down the function clock in the target PMU state. For detailed configuration please see Table 12.4-2 .

Table 12.4-2. HP System Peripherals’ Function Clocks

| PMU_n1_DIG_ICG_FUNC_EN Bit   | Clock        |
|------------------------------|--------------|
| bit 0                        | GDMA_CLK     |
| bit 1                        | SPI2_CLK     |
| bit 2                        | I2S_RX_CLK   |
| bit 3                        | UART0_CLK    |
| bit 4                        | UART1_CLK    |
| bit 5                        | UHCI_CLK     |
| bit 6                        | USB_CLK      |
| bit 7                        | I2S_TX_CLK   |
| bit 8                        | N/A          |
| bit 9                        | N/A          |
| bit 10                       | N/A          |
| bit 11                       | N/A          |
| bit 12                       | N/A          |
| bit 13                       | TG1_CLK      |
| bit 14                       | TG0_CLK      |
| bit 15                       | N/A          |
| bit 16                       | SOC_ETM_CLK  |
| bit 17                       | N/A          |
| bit 18                       | SYSTIMER_CLK |

| PMU_n1_DIG_ICG_FUNC_EN Bit   | Clock         |
|------------------------------|---------------|
| bit 19                       | N/A           |
| bit 20                       | SARADC_CLK    |
| bit 21                       | RMT_CLK       |
| bit 22                       | MCPWM_CLK     |
| bit 23                       | N/A           |
| bit 24                       | PARLIO_TX_CLK |
| bit 25                       | PARLIO_RX_CLK |
| bit 26                       | N/A           |
| bit 27                       | LEDC_CLK      |
| bit 28                       | IOMUX_CLK     |
| bit 29                       | I2C_CLK       |
| bit 30                       | TWAI1_CLK     |
| bit 31                       | TWAI0_CLK     |

- – Configure PMU\_n1\_DIG\_ICG\_APB\_EN to power up/down the APB clock in the target PMU state. For detailed configuration please see Table 12.4-3 .

Table 12.4-3. HP System Peripherals’ APB Clocks

| PMU_n1_DIG_ICG_APB_EN Bit   | Clock               |
|-----------------------------|---------------------|
| bit 0                       | SEC_APB_CLK         |
| bit 1                       | GMDA_APB_CLK        |
| bit 2                       | API2_APB_CLK        |
| bit 3                       | INTMTX_APB_CLK      |
| bit 4                       | I2S_APB_CLK         |
| bit 5                       | MSPI_APB_CLK        |
| bit 6                       | UART0_APB_CLK       |
| bit 7                       | UART1_APB_TX_CLK    |
| bit 8                       | UHCI_APB_CLK        |
| bit 9                       | SARADC_APB_CLK      |
| bit 10                      | N/A                 |
| bit 11                      | TimerGroup0_APB_CLK |
| bit 12                      | TimerGroup1_APB_CLK |
| bit 13                      | I2C_APB_CLK         |
| bit 14                      | LEDC_APB_CLK        |
| bit 15                      | RMT_APB_CLK         |
| bit 16                      | SYSTIMER_APB_CLK    |
| bit 17                      | USB_DEVICE_APB_CLK  |
| bit 18                      | TWAI0_APB_CLK       |
| bit 19                      | TWAI1_APB_CLK       |
| bit 20                      | PCNT_APB_CLK        |
| bit 21                      | PWM_APB_CLK         |
| bit 22                      | SOC_ETM_CLK         |
| bit 23                      | PARLIO_APB_CLK      |

| PMU_n1_DIG_ICG_APB_EN Bit   | Clock                  |
|-----------------------------|------------------------|
| bit 24                      | REGDMA_APB_CLK         |
| bit 25                      | MEMORY_MONITOR_APB_CLK |
| bit 26                      | IOMUX_APB_CLK          |
| bit 27                      | PVT_APB_CLK            |
| bit 28                      | N/A                    |
| bit 29                      | N/A                    |
| bit 30                      | N/A                    |
| bit 31                      | N/A                    |

LP system clocks are mainly used in the low-power system and include the following four clocks:

- LP\_SLOW\_CLK
- LP\_FAST\_CLK
- LP\_DYN\_SLOW\_CLK
- LP\_DYN\_FAST\_CLK

The clock frequency of LP\_DYN\_FAST\_CLK is controlled by hardware as follows, depending on the PMU state (and cannot be changed by the user):

- LP\_SLEEP: The LP\_DYN\_FAST\_CLK frequency is the same as LP\_SLOW\_CLK.
- HP\_ACTIVE, HP\_MODEM, HP\_SLEEP: The LP\_DYN\_FAST\_CLK frequency is the same as LP\_FAST\_CLK.

## 12.4.2.6 Backup Controller

ESP32-C6 has a Retention DMA module that can transfer data between memory and peripherals when the chip switches between PMU states, so that the data is backed up when the power domain is powered down and restored when the power domain is powered up again.

Data transfer is implemented in the Peripherals power domain. PMU only generates relevant control signals. It is important to note that the data transfer control registers are directional, as unlike other control registers, these control behaviors are determined by both the original PMU state and the target PMU state.

Taking the HP\_SLEEP target PMU state as an example, the control registers for transitioning from HP\_ACTIVE to HP\_SLEEP and from HP\_MODEM to HP\_SLEEP are different. The possible PMU state switches are listed below, collectively represented by n2 in the register names:

- HP\_SLEEP2ACTIVE
- HP\_SLEEP2MODEM
- HP\_MODEM2ACTIVE
- HP\_MODEM2SLEEP
- HP\_ACTIVE2SLEEP

The following will introduce how PMU controls the Retention DMA:

- Enable data transfer: Configure PMU\_n2\_BACKUP\_EN to 1 to enable data transfer when the corresponding PMU state switch is performed.

- Enable corresponding clocks: Before data transfer starts, configure PMU\_n2\_BACKUP\_CLK\_SEL to select the clock source of the Retention DMA, and configure PMU\_n1\_BACKUP\_ICG\_FUNC\_EN to enable the clock.

After the data transfer is completed, the value of PMU\_n1\_BACKUP\_ICG\_FUNC\_EN is determined by the configuration of PMU\_n1\_DIG\_ICG\_FUNC\_EN in the target PMU state.

- Configure data transfer direction: Configure the highest bit of PMU\_n2\_BACKUP\_MODE:
- – 1: From peripheral to memory
- – 0: From memory to peripheral
- Select linked list pointer: Configure the lower two bits of PMU\_n2\_BACKUP\_MODE to select the linked list pointer, specifically:
- – 0: PAU\_LINK\_ADDR\_0
- – 1: PAU\_LINK\_ADDR\_1
- – 2: PAU\_LINK\_ADDR\_2
- – 3: PAU\_LINK\_ADDR\_3

## 12.4.2.7 System Controller

The system controller controls some functional modules when the chip switches PMU states, to achieve stable and low-power chip performance. Specifically, the system controller supports:

- Pausing the watchdog function: Configuring PMU\_n1\_DIG\_PAUSE\_WDT to 1 can disable the RTC watchdog timer (RWDT) function when the chip switches to the corresponding target PMU state. Note that if this register is configured to 0 in any sleep mode, the watchdog function is not disabled, and RWDT will reset as the CPU does not feed the watchdog.
- Switching GPIO to sleep mode, where the configuration of the GPIO holds. Consider a GPIO pin working in low-drive mode as an input and a wake-up pin. Setting PMU\_n1\_HP\_PAD\_HOLD\_ALL to 1 can latch the current configuration of the GPIO pin as the sleep configuration when the chip transitions to the corresponding PMU state. For more information about GPIO's hold function, please refer to Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) &gt; Section 7.9 .
- Disabling UART wake-up function: Configuring PMU\_n1\_UART\_WAKEUP\_EN to 0 can disable the four UART wake-up modes in the corresponding PMU state. For more information on UART wake-up modes, please refer to Chapter 27 UART Controller (UART, LP\_UART, UHCI) .
- Pausing CPU: Setting PMU\_n1\_DIG\_CPU\_STALL to 1 can suspend the CPU in the corresponding PMU state.

## 12.4.3 RTC Timer

ESP32-C6's low-power management system features an RTC timer. The 48-bit RTC timer is a real-time counter that logs time when certain events occur, working at RTC\_SLOW\_CLK. For the trigger conditions for the RTC timers, see Table 12.4-4 .

Table 12.4-4. Trigger Conditions for the RTC Timer

| Triggering Conditions          | Description                                                                                                       |
|--------------------------------|-------------------------------------------------------------------------------------------------------------------|
| RTC_TIMER_MAIN_TIMER_XTAL_OFF  | Triggered when PMU powers up or down the 40 MHz crys tal.                                                        |
| RTC_TIMER_MAIN_TIMER_SYS_STALL | Triggered when the CPU enters or exits the stall state. This is to ensure the system timer is continuous in time. |
| RTC_TIMER_MAIN_TIMER_SYS_RST   | Triggered upon system reset.                                                                                      |
| RTC_TIMER_UPDATE               | Triggered when RTC_TIMER_UPDATE is configured by the CPU (e.g., users).                                           |

The RTC timer updates two groups of registers upon any new trigger.

- Register group 0 records the count value of the RTC timer under the current trigger, with the counting unit being LP\_SLOW\_CLK.
- – RTC\_TIMER\_MAIN\_BUF0\_HIGH
- – RTC\_TIMER\_MAIN\_BUF0\_LOW
- Register group 1 records the count value of the RTC timer under the previous trigger.
- – RTC\_TIMER\_MAIN\_BUF1\_HIGH
- – RTC\_TIMER\_MAIN\_BUF1\_LOW

Each time there is a new trigger, the record from the previous trigger will be moved from register group 0 to register group 1 (the record in register group 1 will be overwritten), and the record of the current trigger will be stored in register group 0. Therefore, the RTC timer can record up to two trigger values simultaneously.

It is worth noting that any reset or sleep state other than the chip's power-up reset will not stop or reset the RTC timer. Additionally, the RTC timer can also be used as a wake-up source (see Table 12.4-1).

## 12.4.4 Brownout Detector

The brownout detector periodically checks the voltage of pins VDDA3P3, VDDA1, and VDDA2, about every 280 µ s. If the voltage of these pins drops below the predefined threshold (2.7 V by default), the detector triggers a signal to power down some power-consuming modules (such as RF circuits) to allow extra time for the digital system to save and transfer important data. The brownout detector has ultra-low-power consumption and remains enabled whenever the chip is powered up.

LP\_ANA\_BOD\_MODE0\_LP\_INT\_RAW indicates the output level of the brownout detector. This register is low level by default and outputs a high level when the voltage of the detected pin drops below the predefined threshold.

When a brownout signal is detected, the brownout detector can handle it in one of the following two modes (Mode 1 is the default):

- Mode 0: Triggers an interrupt when the counter counts to the thresholds pre-defined in Int Comparer
- (LP\_ANA\_BOD\_MODE0\_INTR\_WAIT) and Rst Comparer (LP\_ANA\_BOD\_MODE0\_RESET\_WAIT), then resets the chip based on the configuration of bod\_mode0\_rst\_sel
- (LP\_ANA\_BOD\_MODE0\_RESET\_SEL). This method can be enabled by setting the bod\_mode0\_en (LP\_ANA\_BOD\_MODE0\_INTR\_ENA) signal.

- Mode 1: Resets the system directly.

The brownout reset workflow is illustrated in the diagram below:

Figure 12.4-3. Brownout Reset Workflow

![Image](images/12_Chapter_12_img004_0c022af5.png)

Registers for controlling related signals are described below:

- bod\_mode0\_en: LP\_ANA\_BOD\_MODE0\_INTR\_ENA
- bod\_mode0\_rst\_en: LP\_ANA\_BOD\_MODE0\_RESET\_ENA
- bod\_mode0\_rst\_sel: LP\_ANA\_BOD\_MODE0\_RESET\_SEL configures the reset type:
- – 0: chip reset
- – 1: system reset

For more information regarding chip reset and system reset, please refer to Chapter 8 Reset and Clock .

- bod\_mode1\_sel: The first bit of LP\_ANA\_ANA\_FIB\_ENA .
- bod\_mode1\_rst\_en: LP\_ANA\_BOD\_MODE1\_RESET\_ENA

## 12.5 Power Modes

ESP32-C6 has four configurable PMU states. Based on the four PMU states, five power modes have been defined for the most commonly seen application scenarios. For the details, please see Table 12.5-1 .

Table 12.5-1. Preset Power Modes

|              | Power Domain   | Power Domain      | Power Domain   | Power Domain   | Power Domain   | Power Domain   | Power Domain   | Power Domain   | Power Domain   |
|--------------|----------------|-------------------|----------------|----------------|----------------|----------------|----------------|----------------|----------------|
| Power Modes  | LP always-on   | LP PD peripherals | Peripherals    | Modem          | CPU            | RC_FAST_CLK    | XTAL_CLK       | PLL            | RF circuit     |
| Active       | ON             | ON                | ON             | ON             | ON             | ON             | ON             | ON             | ON             |
| Modem-sleep  | ON             | ON                | ON             | OFF            | ON             | ON             | ON             | ON/OFF         | OFF            |
| Light-sleep0 | ON             | ON                | ON             | ON/OFF         | OFF            | ON             | ON/OFF         | ON/OFF         | ON/OFF         |
| Light-sleep1 | ON             | ON/OFF            | ON/OFF         | ON/OFF         | OFF            | ON/OFF         | ON/OFF         | ON/OFF         | ON/OFF         |
| Deep-sleep   | ON             | OFF               | OFF            | OFF            | OFF            | OFF            | OFF            | OFF            | OFF            |

## Note:

1. For power consumption data, please refer to ESP32-C6 Datasheet &gt; Section Current Consumption .
2. For supported wake-up sources, please refer to Table 12.4-1 .

## 12.6 RTC Boot

In Deep-sleep mode, both the ROM and RAM of the chip are powered down, so the time required for SPI Boot (copying data from flash) upon waking up is long. Therefore, compared to Light-sleep and Modem-sleep modes, the wake-up from Deep-sleep mode takes longer time. However, in Deep-sleep mode, the 16 KB SRAM can remain powered up. Therefore, users can put small-sized code (i.e., less than 8 KB "deep sleep wake stubs") into the 16 KB SRAM to avoid the delay caused by SPI boot, thus speeding up the chip wake-up process.

To enable RTC boot, follow the steps below:

1. Set LP\_AON\_CORE0\_STAT\_VECTOR\_SEL to 1 to start up the chip from the RTC fast memory.
2. Calculate CRC for the RTC fast memory and save the result in LP\_AON\_STORE7\_REG .
3. Set LP\_AON\_STORE6\_REG to the entry address of the RTC fast memory.
4. Configure sleep mode for the chip.
5. When the CPU is powered up, it begins unpacking the ROM and performing initialization. Then, recalculate the CRC code of the RTC fast memory. If it matches the result stored in LP\_AON\_STORE7\_REG, the CPU will jump to the entry address of the RTC fast memory.

The boot flow after the chip's wake-up is shown in Figure 12.6-1 .

-==-

'Running in ROM|

reset\_vector@

0x40000400

Initialization

Call CRC in RTC fast memory

CRC right

Yes

Jump to entry point in

RTC fast memory

Running in RTC fast memory

Figure 12.6-1. ESP32-C6 Boot Flow

![Image](images/12_Chapter_12_img005_089a0a2e.png)

## 12.7 Event Task Matrix Feature

The low-power management system on ESP32-C6 supports the Event Task Matrix (ETM) function, which allows the low-power management system's ETM tasks to be triggered by any peripherals' ETM events, or the low-power management system's ETM events to trigger any peripherals' ETM tasks. This section introduces the ETM tasks and events related to the low-power management system. For more information, please refer to Chapter 11 Event Task Matrix (SOC\_ETM) .

The low-power management system can receive the following ETM tasks:

- PMU\_TASK\_SLEEP\_REQ: Triggers PMU's sleep process.

The low-power management system can generate the following ETM events:

- PMU\_EVT\_SLEEP\_WAKEUP: Indicates that PMU is woken up to the HP\_ACTIVE state.
- RTC\_EVT\_TICK: Indicates that the RTC timer increments by 1.

## 12.8 Interrupts

ESP32-C6’s low-power management system can generate the following interrupt signals:

- PMU\_INTR
- PMU\_LP\_INT
- LP\_RTC\_TIMER\_INTR
- LP\_RTC\_TIMER\_LP\_INT

Among these interrupt signals, PMU\_INTR and LP\_RTC\_TIMER\_INTR are sent to the Interrupt Matrix, while PMU\_LP\_INT and LP\_RTC\_TIMER\_LP\_INT are sent to the LP CPU.

The interrupt signals are generated by the internal interrupt sources of each module, specifically:

## PMU\_INTR:

- PMU\_SOC\_WAKEUP\_INT: Triggered when the chip is woken up to the HP\_ACTIVE state.
- PMU\_SOC\_SLEEP\_REJECT\_INT: Triggered when a sleep-rejection source rejects a sleep request.
- PMU\_SW\_INT: Triggered when LP CPU is used as a wake-up source and wakes up the chip to HP\_ACTIVE state.
- PMU\_SDIO\_IDLE\_INT: Triggered when SDIO is in idle state.
- PMU\_LP\_CPU\_EXC\_INT: Triggered when there are LP CPU exceptions.

## PMU\_LP\_INT:

- PMU\_HP\_SW\_TRIGGER\_INT: Triggered when HP CPU wakes up LP CPU.
- PMU\_ACTIVE\_SWITCH\_SLEEP\_START\_INT: Triggered when the PMU state starts to switch from HP\_ACTIVE to HP\_SLEEP.
- PMU\_MODEM\_SWITCH\_SLEEP\_START\_INT: Triggered when the PMU state starts to switch from HP\_MODEM to HP\_SLEEP.
- PMU\_SLEEP\_SWITCH\_MODEM\_START\_INT: Triggered when the PMU state starts to switch from HP\_SLEEP to HP\_MODEM.
- PMU\_SLEEP\_SWITCH\_ACTIVE\_START\_INT: Triggered when the PMU state starts to switch from HP\_SLEEP to HP\_ACTIVE.
- PMU\_MODEM\_SWITCH\_ACTIVE\_START\_INT: Triggered when the PMU state starts to switch from HP\_MODEM to HP\_ACTIVE.
- PMU\_ACTIVE\_SWITCH\_SLEEP\_END\_INT: Triggered when the PMU state has switched from HP\_MODEM to HP\_ACTIVE.
- PMU\_MODEM\_SWITCH\_SLEEP\_END\_INT: Triggered when the PMU state has switched from HP\_MODEM to HP\_ACTIVE.
- PMU\_SLEEP\_SWITCH\_MODEM\_END\_INT: Triggered when the PMU state has switched from HP\_SLEEP to HP\_MODEM.
- PMU\_SLEEP\_SWITCH\_ACTIVE\_END\_INT: Triggered when the PMU state has switched from HP\_SLEEP to HP\_ACTIVE.

- PMU\_MODEM\_SWITCH\_ACTIVE\_END\_INT: Triggered when the PMU state has switched from HP\_MODEM to HP\_ACTIVE.
- PMU\_LP\_CPU\_WAKEUP\_INT: Triggered when LP CPU is woken up.

## LP\_RTC\_TIMER\_INTR:

- RTC\_TIMER\_MAIN\_TIMER\_INT: Triggered when the count value of the RTC timer reaches the target value RTC\_TIMER\_MAIN\_TIMER\_TAR\_LOW0 or RTC\_TIMER\_MAIN\_TIMER\_TAR\_HIGH0 .
- RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT: Triggered when the count value of the RTC timer reaches the maximum value.
- LP\_ANA\_BOD\_MODE0\_INT: Triggered when the brownout detector detects that the voltage is below the threshold.

```
MAX = (RT C _ T IMER _ MAIN _ T IMER _ T AR _ HIGH0 << 32) + RT C _ T IMER _ MAIN _ T IMER _ T AR _ LOW0
```

## LP\_RTC\_TIMER\_LP\_INT:

- RTC\_TIMER\_MAIN\_TIMER\_LP\_INT: Triggered when the count value of the RTC timer reaches the target value RTC\_TIMER\_MAIN\_TIMER\_TAR\_LOW1 or RTC\_TIMER\_MAIN\_TIMER\_TAR\_HIGH1 .
- RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_LP\_INT: Triggered when the count value of the RTC timer reaches the maximum value.
- LP\_ANA\_BOD\_MODE0\_LP\_INT: Triggered when the brownout detector detects that the voltage is below the threshold.

```
MAX = (RT C _ T IMER _ MAIN _ T IMER _ T AR _ HIGH1 << 32) + RT C _ T IMER _ MAIN _ T IMER _ T AR _ LOW1
```

Each interrupt source can be configured by a common set of registers that are described in Section Interrupt Configuration Registers. The specific registers can be found in Section 12.9 Register Summary .

## 12.9 Register Summary

## 12.9.1 PMU Register Summary

The addresses in this section are relative to the PMU base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                            | Description                                                               | Address   | Access   |
|---------------------------------|---------------------------------------------------------------------------|-----------|----------|
| Configuration Registers         |                                                                           |           |          |
| PMU_HP_ACTIVE_DIG_POWER_REG     | Digital power domain control register in HP_ACTIVE state                  | 0x0000    | R/W      |
| PMU_HP_ACTIVE_ICG_HP_FUNC_REG   | HP system peripheral’s function clock control register in HP_ACTIVE state | 0x0004    | R/W      |
| PMU_HP_ACTIVE_ICG_HP_APB_REG    | HP system peripheral’s APB clock con trol register in HP_ACTIVE state    | 0x0008    | R/W      |
| PMU_HP_ACTIVE_HP_SYS_CNTL_REG   | System control register in HP_ACTIVE state                                | 0x0010    | R/W      |
| PMU_HP_ACTIVE_HP_CK_POWER_REG   | Clock source power control register in HP_ACTIVE state                    | 0x0014    | R/W      |
| PMU_HP_ACTIVE_BACKUP_REG        | Backup module control register in HP_ACTIVE state                         | 0x001C    | R/W      |
| PMU_HP_ACTIVE_BACKUP_CLK_REG    | Backup module’s function clock control register in HP_ACTIVE state        | 0x0020    | R/W      |
| PMU_HP_ACTIVE_SYSCLK_REG        | System clock control register in HP_ACTIVE state                          | 0x0024    | R/W      |
| PMU_HP_ACTIVE_HP_REGULATOR0_REG | Regulator power control register in HP_ACTIVE state                       | 0x0028    | R/W      |
| PMU_HP_ACTIVE_XTAL_REG          | XTAL_CLK power control register in HP_ACTIVE state                        | 0x0030    | R/W      |
| PMU_HP_MODEM_DIG_POWER_REG      | Digital power domain control register in HP_MODEM state                   | 0x0034    | R/W      |
| PMU_HP_MODEM_ICG_HP_FUNC_REG    | HP system peripheral’s function clock control register in HP_MODEM state  | 0x0038    | R/W      |
| PMU_HP_MODEM_ICG_HP_APB_REG     | HP system peripheral’s APB clock con trol register in HP_MODEM state     | 0x003C    | R/W      |
| PMU_HP_MODEM_HP_SYS_CNTL_REG    | System control register in HP_MODEM state                                 | 0x0044    | R/W      |
| PMU_HP_MODEM_HP_CK_POWER_REG    | Clock source power control register in HP_MODEM state                     | 0x0048    | R/W      |
| PMU_HP_MODEM_BACKUP_REG         | Backup module control register in HP_MODEM state                          | 0x0050    | R/W      |
| PMU_HP_MODEM_BACKUP_CLK_REG     | Backup module’s function clock control register in HP_MODEM state         | 0x0054    | R/W      |

| Name                           | Description                                                                     | Address   | Access   |
|--------------------------------|---------------------------------------------------------------------------------|-----------|----------|
| PMU_HP_MODEM_SYSCLK_REG        | System clock control register in HP_MODEM state                                 | 0x0058    | R/W      |
| PMU_HP_MODEM_HP_REGULATOR0_REG | Regulator power control register in HP_MODEM state                              | 0x005C    | R/W      |
| PMU_HP_MODEM_XTAL_REG          | XTAL_CLK power control register in HP_MODEM state                               | 0x0064    | R/W      |
| PMU_HP_SLEEP_DIG_POWER_REG     | Digital power domain control register in HP_SLEEP state                         | 0x0068    | R/W      |
| PMU_HP_SLEEP_ICG_HP_FUNC_REG   | HP system peripheral’s function clock control register in HP_SLEEP state        | 0x006C    | R/W      |
| PMU_HP_SLEEP_ICG_HP_APB_REG    | HP system peripheral’s APB clock con trol register in HP_SLEEP state           | 0x0070    | R/W      |
| PMU_HP_SLEEP_HP_SYS_CNTL_REG   | System control register in HP_SLEEP state                                       | 0x0078    | R/W      |
| PMU_HP_SLEEP_HP_CK_POWER_REG   | Clock source power control register in HP_SLEEP state                           | 0x007C    | R/W      |
| PMU_HP_SLEEP_BACKUP_REG        | Backup module control register in HP_SLEEP state                                | 0x0084    | R/W      |
| PMU_HP_SLEEP_BACKUP_CLK_REG    | Backup flow ICG control register in HP_SLEEP state                              | 0x0088    | R/W      |
| PMU_HP_SLEEP_SYSCLK_REG        | System clock control register in HP_SLEEP state                                 | 0x008C    | R/W      |
| PMU_HP_SLEEP_HP_REGULATOR0_REG | Regulator power control register in HP_SLEEP state                              | 0x0090    | R/W      |
| PMU_HP_SLEEP_XTAL_REG          | XTAL_CLK power control register in HP_SLEEP state                               | 0x0098    | R/W      |
| PMU_HP_SLEEP_LP_DIG_POWER_REG  | LP system digital power domains con trol register in HP_SLEEP state            | 0x00A8    | R/W      |
| PMU_HP_SLEEP_LP_CK_POWER_REG   | Low-speed  clock  power control  register  in HP_ACTIVE/HP_MODEM/HP_SLEEP state | 0x00AC    | R/W      |
| PMU_LP_SLEEP_XTAL_REG          | XTAL_CLK power control register in LP_SLEEP state                               | 0x00BC    | R/W      |
| PMU_LP_SLEEP_LP_DIG_POWER_REG  | Digital power domain control register in LP_SLEEP state                         | 0x00C0    | R/W      |
| PMU_LP_SLEEP_LP_CK_POWER_REG   | Low-speed clock power control regis ter in LP_SLEEP state                      | 0x00C4    | R/W      |
| PMU_IMM_PAD_HOLD_ALL_REG       | Hold signal configuration register                                              | 0x00E4    | WT       |
| PMU_POWER_PD_MEM_MASK_REG      | Internal SRAMx domain force power up register                                   | 0x0110    | R/W      |
| PMU_POWER_CK_WAIT_CNTL_REG     | Wait cycle for stable XTAL_CLK and PLL_CLK configuration register               | 0x011C    | R/W      |
| PMU_SLP_WAKEUP_CNTL0_REG       | Sleep request register                                                          | 0x0120    | WT       |

| Name                       | Description                                    | Address   | Access   |
|----------------------------|------------------------------------------------|-----------|----------|
| PMU_SLP_WAKEUP_CNTL1_REG   | Sleep reject register                          | 0x0124    | R/W      |
| PMU_SLP_WAKEUP_CNTL2_REG   | Wake up source enable register                 | 0x0128    | R/W      |
| PMU_SLP_WAKEUP_CNTL4_REG   | Sleep reject cause clear register              | 0x0130    | WT       |
| PMU_SLP_WAKEUP_STATUS0_REG | Wake up cause register                         | 0x0140    | RO       |
| PMU_SLP_WAKEUP_STATUS1_REG | Reset reject cause register                    | 0x0144    | RO       |
| PMU_INT_RAW_REG            | PMU sleep/wake-up raw interrupt                | 0x015C    | R/WTC/SS |
| PMU_HP_INT_ST_REG          | PMU sleep/wake-up state interrupt              | 0x0160    | RO       |
| PMU_HP_INT_ENA_REG         | PMU sleep/wake-up interrupt enable register    | 0x0164    | R/W      |
| PMU_HP_INT_CLR_REG         | PMU sleep/wake-up raw interrupt clear register | 0x0168    | WT       |
| PMU_LP_INT_RAW_REG         | Low-power system raw interrupt                 | 0x016C    | R/WTC/SS |
| PMU_LP_INT_ST_REG          | PMU state switch interrupt state register      | 0x0170    | RO       |
| PMU_LP_INT_ENA_REG         | PMU state switch interrupt enable reg ister   | 0x0174    | R/W      |
| PMU_LP_INT_CLR_REG         | PMU state switch interrupt clear register      | 0x0178    | WT       |
| PMU_LP_CPU_PWR0_REG        | LP CPU control register                        | 0x017C    | R/W      |
| PMU_LP_CPU_PWR1_REG        | LP CPU sleep request register                  | 0x0180    | varies   |
| PMU_HP_LP_CPU_COMM_REG     | Software interrupt register                    | 0x0184    | WT       |
| PMU_DATE_REG               | Version control register                       | 0x03FC    | R/W      |

## 12.9.2 Always-on Register Summary

The addresses in this section are relative to the Always-on Registers base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                    | Description                                | Address                 | Access                  |
|-------------------------|--------------------------------------------|-------------------------|-------------------------|
| Configuration Registers | Configuration Registers                    | Configuration Registers | Configuration Registers |
| LP_AON_STORE0_REG       | Always-on register0                        | 0x0000                  | R/W                     |
| LP_AON_STORE1_REG       | Always-on register1                        | 0x0004                  | R/W                     |
| LP_AON_STORE2_REG       | Always-on register2                        | 0x0008                  | R/W                     |
| LP_AON_STORE3_REG       | Always-on register3                        | 0x000C                  | R/W                     |
| LP_AON_STORE4_REG       | Always-on register4                        | 0x0010                  | R/W                     |
| LP_AON_STORE5_REG       | Always-on register5                        | 0x0014                  | R/W                     |
| LP_AON_STORE6_REG       | Always-on register6                        | 0x0018                  | R/W                     |
| LP_AON_STORE7_REG       | Always-on register7                        | 0x001C                  | R/W                     |
| LP_AON_STORE8_REG       | Always-on register8                        | 0x0020                  | R/W                     |
| LP_AON_STORE9_REG       | Always-on register9                        | 0x0024                  | R/W                     |
| LP_AON_GPIO_MUX_REG     | LP IO MUX configuration register           | 0x0028                  | R/W                     |
| LP_AON_GPIO_HOLD0_REG   | Hold enable signal configuration register  | 0x002C                  | R/W                     |
| LP_AON_SYS_CFG_REG      | Software system reset                      | 0x0034                  | varies                  |
| LP_AON_CPUCORE0_CFG_REG | CPU startup address configuration register | 0x0038                  | varies                  |

| Name             | Description                                | Address   | Access   |
|------------------|--------------------------------------------|-----------|----------|
| LP_AON_LPBUS_REG | LP SRAM access mode configuration register | 0x0048    | varies   |

## 12.9.3 RTC Timer Register Summary

The addresses in this section are relative to the RTC Timer base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                         | Description                                                               | Address   | Access   |
|------------------------------|---------------------------------------------------------------------------|-----------|----------|
| Configuration Registers      |                                                                           |           |          |
| RTC_TIMER_TAR0_LOW_REG       | Configures the low 32 bits of the target count value 0 of the RTC timer.  | 0x0000    | R/W      |
| RTC_TIMER_TAR0_HIGH_REG      | Configures the high 16 bits of the target count value 0 of the RTC timer. | 0x0004    | R/W      |
| RTC_TIMER_TAR1_LOW_REG       | Configures the low 32 bits of the target count value 1 of the RTC timer.  | 0x0008    | R/W      |
| RTC_TIMER_TAR1_HIGH_REG      | Configures the high 16 bits of the target count value 1 of the RTC timer. | 0x000C    | R/W      |
| RTC_TIMER_UPDATE_REG         | RTC timer value record register                                           | 0x0010    | R/W      |
| RTC_TIMER_MAIN_BUF0_LOW_REG  | RTC timer register group0, bit0 - bit31                                   | 0x0014    | RO       |
| RTC_TIMER_MAIN_BUF0_HIGH_REG | RTC timer register group0, bit32 - bit47                                  | 0x0018    | RO       |
| RTC_TIMER_MAIN_BUF1_LOW_REG  | RTC timer register group1, bit0 - bit31                                   | 0x001C    | RO       |
| RTC_TIMER_MAIN_BUF1_HIGH_REG | RTC timer register group1, bit32 - bit47                                  | 0x0020    | RO       |
| RTC_TIMER_INT_RAW_REG        | LP_RTC_TIMER_INT raw interrupt                                            | 0x0028    | RO       |
| RTC_TIMER_INT_ST_REG         | LP_RTC_TIMER_INT state interrupt                                          | 0x002C    | RO       |
| RTC_TIMER_INT_ENA_REG        | LP_RTC_TIMER_INT interrupt enable register                                | 0x0030    | R/W      |
| RTC_TIMER_INT_CLR_REG        | LP_RTC_TIMER_INT interrupt clear reg ister                               | 0x0034    | WT       |
| RTC_TIMER_LP_INT_RAW_REG     | LP_RTC_TIMER_LP_INT raw interrupt                                         | 0x0038    | RO       |
| RTC_TIMER_LP_INT_ST_REG      | LP_RTC_TIMER_LP_INT state interrupt                                       | 0x003C    | RO       |
| RTC_TIMER_LP_INT_ENA_REG     | LP_RTC_TIMER_LP_INT interrupt en able register                           | 0x0040    | R/W      |
| RTC_TIMER_LP_INT_CLR_REG     | LP_RTC_TIMER_LP_INT interrupt clear register                              | 0x0044    | WT       |

## 12.9.4 Brownout Detector Register Summary

The addresses in this section are relative to the Low-power Analog Peripheral (LP\_ANA\_PERI) base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                      | Description                                       | Address                 | Access                  |
|---------------------------|---------------------------------------------------|-------------------------|-------------------------|
| Configuration Registers   | Configuration Registers                           | Configuration Registers | Configuration Registers |
| LP_ANA_BOD_MODE0_CNTL_REG | Brownout detector mode 0 configuration regis ter | 0x0000                  | R/W                     |
| LP_ANA_BOD_MODE1_CNTL_REG | Brownout detector mode 1 configuration regis ter | 0x0004                  | R/W                     |
| LP_ANA_FIB_ENABLE_REG     | FIB selection register                            | 0x000C                  | R/W                     |
| LP_ANA_INT_RAW_REG        | LP_ANA_BOD_MODE0_INT raw interrupt                | 0x0010                  | R/WTC/SS                |
| LP_ANA_INT_ST_REG         | LP_ANA_BOD_MODE0_INT state interrupt              | 0x0014                  | RO                      |
| LP_ANA_INT_ENA_REG        | LP_ANA_BOD_MODE0_INT enable register              | 0x0018                  | R/W                     |
| LP_ANA_INT_CLR_REG        | LP_ANA_BOD_MODE0_INT clear register               | 0x001C                  | WT                      |
| LP_ANA_LP_INT_RAW_REG     | LP_ANA_BOD_MODE0_LP_INT raw interrupt             | 0x0020                  | R/WTC/SS                |
| LP_ANA_LP_INT_ST_REG      | LP_ANA_BOD_MODE0_LP_INT state interrupt           | 0x0024                  | RO                      |
| LP_ANA_LP_INT_ENA_REG     | LP_ANA_BOD_MODE0_LP_INT enable register           | 0x0028                  | R/W                     |
| LP_ANA_LP_INT_CLR_REG     | LP_ANA_BOD_MODE0_LP_INT clear register            | 0x002C                  | WT                      |
| LP_ANA_DATE_REG           | Version control register                          | 0x03FC                  | R/W                     |

## 12.10 Registers

## 12.10.1 PMU Registers

The addresses in this section are relative to the PMU base address provided in Table 5.3-2 in Chapter 5 System and Memory .

For how to program reserved fields, please refer to Section Programming Reserved Register Field .

## Register 12.1. PMU\_HP\_ACTIVE\_DIG\_POWER\_REG (0x0000)

![Image](images/12_Chapter_12_img006_56ed37b1.png)

PMU\_HP\_ACTIVE\_VDD\_SPI\_PD\_EN Configures whether to power down external flash in HP\_ACTIVE

state.

- 0: Power up
- 1: Power down
- (R/W)
- PMU\_HP\_ACTIVE\_HP\_MEM\_DSLP Configures whether to put Internal SRAMx into Deep-sleep mode in HP\_ACTIVE state.
- 0: Do not put Internal SRAMx into Deep-sleep
- 1: Put Internal SRAMx into Deep-sleep
- (R/W)
- PMU\_HP\_ACTIVE\_PD\_HP\_WIFI\_PD\_EN Configures whether to power down Modem domain in HP\_ACTIVE state.
- 0: Power up
- 1: Power down
- (R/W)
- PMU\_HP\_ACTIVE\_PD\_HP\_CPU\_PD\_EN Configures whether to power down CPU domain in HP\_ACTIVE state.
- 0: Power up
- 1: Power down
- (R/W)
- PMU\_HP\_ACTIVE\_PD\_HP\_AON\_PD\_EN Configures whether to power down Modem power domain in HP\_ACTIVE state.
- 0: Power up
- 1: Power down
- (R/W)
- PMU\_HP\_ACTIVE\_PD\_TOP\_PD\_EN Configures whether to power down Peripherals domain in

HP\_ACTIVE state.

- 0: Power up
- 1: Power down

(R/W)

Register 12.2. PMU\_HP\_ACTIVE\_ICG\_HP\_FUNC\_REG (0x0004)

![Image](images/12_Chapter_12_img007_3b02ccd6.png)

PMU\_HP\_ACTIVE\_DIG\_ICG\_FUNC\_EN Configures whether to enable HP system peripheral's function clock in HP\_ACTIVE state. For detailed configuration please see Table 12.4-2 .

0: Disable

1: Enable

(R/W)

Register 12.3. PMU\_HP\_ACTIVE\_ICG\_HP\_APB\_REG (0x0008)

![Image](images/12_Chapter_12_img008_0d5ec9a6.png)

PMU\_HP\_ACTIVE\_DIG\_ICG\_APB\_EN Configures whether to enable HP system peripheral's APB clock in HP\_ACTIVE state. For detailed configuration please see Table 12.4-3 .

0: Disable

1: Enable

(R/W)

## Register 12.4. PMU\_HP\_ACTIVE\_HP\_SYS\_CNTL\_REG (0x0010)

![Image](images/12_Chapter_12_img009_07629793.png)

PMU\_HP\_ACTIVE\_UART\_WAKEUP\_EN Configures whether to enable UART wake up function in

HP\_ACTIVE state.

0: Disable wake-up function

1: Enable wake-up function

(R/W)

PMU\_HP\_ACTIVE\_LP\_PAD\_HOLD\_ALL Configures whether to hold LP GPIO's configuration in HP\_ACTIVE state.

0: Do not hold

1: Hold

(R/W)

PMU\_HP\_ACTIVE\_HP\_PAD\_HOLD\_ALL Configures whether to hold GPIO‘s configuration in

HP\_ACTIVE state.

0: Do not hold

1: Hold

(R/W)

PMU\_HP\_ACTIVE\_DIG\_PAD\_SLP\_SEL Configures whether to use Light-sleep mode configuration for GPIO in HP\_ACTIVE state.

0: Use normal configuration

1: Use Light-sleep mode configuration. For details please refer to Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) &gt; Section 7.8 Pin Functions in Light-sleep .

(R/W)

PMU\_HP\_ACTIVE\_DIG\_PAUSE\_WDT Configures whether to pause watchdog in HP\_ACTIVE state.

0: Do not pause

1: Pause

(R/W)

PMU\_HP\_ACTIVE\_DIG\_CPU\_STALL Configures whether to stall HP CPU in HP\_ACTIVE state.

0: Do not stall

1: Stall

(R/W)

Register 12.5. PMU\_HP\_ACTIVE\_HP\_CK\_POWER\_REG (0x0014)

![Image](images/12_Chapter_12_img010_3e713ce0.png)

PMU\_HP\_ACTIVE\_XPD\_BBPLL Configures whether to enable PLL\_CLK in HP\_ACTIVE state.

0: Disable PLL\_CLK

1: Enable PLL\_CLK

(R/W)

## Register 12.6. PMU\_HP\_ACTIVE\_BACKUP\_REG (0x001C)

![Image](images/12_Chapter_12_img011_c3d5cc20.png)

PMU\_HP\_SLEEP2ACTIVE\_BACKUP\_CLK\_SEL Configures the backup module's function clock source when PMU state switches from HP\_SLEEP to HP\_ACTIVE.

0: Select XTAL

1: Select PLL\_CLK

2: Select RC\_FAST\_CLK

3: Invalid value

(R/W)

PMU\_HP\_MODEM2ACTIVE\_BACKUP\_CLK\_SEL Configures the backup module's function clock source when PMU state switches from HP\_MODEM to HP\_ACTIVE. The configuration is the same as the register above. (R/W)

PMU\_HP\_SLEEP2ACTIVE\_BACKUP\_MODE Configures the backup direction and link list when PMU state switches switch from HP\_SLEEP to HP\_ACTIVE.

Highest bit:

0: From peripheral to memory

1: From memory to peripheral

Lower two bits:

0: PAU\_LINK\_ADDR\_0

1: PAU\_LINK\_ADDR\_1

2: PAU\_LINK\_ADDR\_2

3: PAU\_LINK\_ADDR\_3

(R/W)

PMU\_HP\_MODEM2ACTIVE\_BACKUP\_MODE Configures the backup direction and link list when PMU state switches from HP\_MODEM to HP\_ACTIVE. The configuration is the same as the register above. (R/W)

PMU\_HP\_SLEEP2ACTIVE\_BACKUP\_EN Configures whether to enable the backup flow when PMU state switches from HP\_SLEEP to HP\_ACTIVE.

0: Disable backup

1: Enable backup

(R/W)

Continued on the next page...

## Register 12.6. PMU\_HP\_ACTIVE\_BACKUP\_REG (0x001C)

## Continued from the previous page...

PMU\_HP\_MODEM2ACTIVE\_BACKUP\_EN Configures whether to enable the backup flow when PMU state switches from HP\_MODEM to HP\_ACTIVE.

0: Disable backup

1: Enable backup

(R/W)

Register 12.7. PMU\_HP\_ACTIVE\_BACKUP\_CLK\_REG (0x0020)

![Image](images/12_Chapter_12_img012_a96d1f82.png)

PMU\_HP\_ACTIVE\_BACKUP\_ICG\_FUNC\_EN Configures whether to enable each peripheral's function clock when the target state is HP\_ACTIVE. For details, please refer to Chapter 8 Reset and Clock .

0: Disable

1: Enable

(R/W)

## Register 12.8. PMU\_HP\_ACTIVE\_SYSCLK\_REG (0x0024)

![Image](images/12_Chapter_12_img013_5591adc9.png)

- PMU\_HP\_ACTIVE\_ICG\_SYS\_CLOCK\_EN Configures whether to enable HP\_ROOT\_CLK in

HP\_ACTIVE state.

- 0: Disable
- 1: Enable

(R/W)

PMU\_HP\_ACTIVE\_SYS\_CLK\_SLP\_SEL Configures whether to allow PMU to control clock source in

- HP\_ACTIVE state.
- 0: Controlled by PCR registers
- 1: Controlled by PMU
- (R/W)
- PMU\_HP\_ACTIVE\_ICG\_SLP\_SEL Configures whether to allow PMU to control the clock gating in
- HP\_ACTIVE state.
- 0: Controlled by PCR registers
- 1: Controlled by PMU
- (R/W)

PMU\_HP\_ACTIVE\_DIG\_SYS\_CLK\_SEL Configures the source of HP\_ROOT\_CLK in HP\_ACTIVE state.

- 0: XTAL
- 1: PLL\_CLK
- 2: RC\_FAST\_CLK
- 3: Invalid value
- (R/W)

## Register 12.9. PMU\_HP\_ACTIVE\_HP\_REGULATOR0\_REG (0x0028)

![Image](images/12_Chapter_12_img014_414e1e20.png)

PMU\_HP\_ACTIVE\_HP\_REGULATOR\_XPD Configures whether to enable the HP sys regulator in

HP\_ACTIVE state.

- 0: Disable the HP sys regulator
- 1: Enable the HP sys regulator

(R/W)

## Register 12.10. PMU\_HP\_ACTIVE\_XTAL\_REG (0x0030)

![Image](images/12_Chapter_12_img015_bf8d7fd1.png)

PMU\_HP\_ACTIVE\_XPD\_XTAL Configures whether to enable XTAL\_CLK analog source in HP\_ACTIVE state.

0: Disable

- 1: Enable

(R/W)

## Register 12.11. PMU\_HP\_MODEM\_DIG\_POWER\_REG (0x0034)

![Image](images/12_Chapter_12_img016_89a7f5b9.png)

PMU\_HP\_MODEM\_VDD\_SPI\_PD\_EN Configures whether to power down external flash in

- HP\_MODEM state.
- 0: Power up
- 1: Power down
- (R/W)
- PMU\_HP\_MODEM\_HP\_MEM\_DSLP Configures whether to put Internal SRAMx into Deep-sleep mode in HP\_MODEM state.
- 0: Do not put Internal SRAMx into Deep-sleep
- 1: Put Internal SRAMx into Deep-sleep
- (R/W)
- PMU\_HP\_MODEM\_PD\_HP\_WIFI\_PD\_EN Configures whether to power down Modem domain in

HP\_MODEM state.

- 0: Power up
- 1: Power down
- (R/W)
- PMU\_HP\_MODEM\_PD\_HP\_CPU\_PD\_EN Configures whether to power down CPU domain in

HP\_MODEM state.

- 0: Power up
- 1: Power down
- (R/W)
- PMU\_HP\_MODEM\_PD\_HP\_AON\_PD\_EN Configures whether to power down Modem power domain in HP\_MODEM state.
- 0: Power up
- 1: Power down
- (R/W)
- PMU\_HP\_MODEM\_PD\_TOP\_PD\_EN Configures whether to power down Peripherals domain in

HP\_MODEM state.

- 0: Power up
- 1: Power down
- (R/W)

## Register 12.12. PMU\_HP\_MODEM\_ICG\_HP\_FUNC\_REG (0x0038)

![Image](images/12_Chapter_12_img017_ec5a5ed2.png)

PMU\_HP\_MODEM\_DIG\_ICG\_FUNC\_EN Configures whether to enable HP system peripheral’s func-

tion clock in HP\_MODEM state. For detailed configuration please see Table 12.4-2 .

0: Disable

1: Enable

(R/W)

## Register 12.13. PMU\_HP\_MODEM\_ICG\_HP\_APB\_REG (0x003C)

![Image](images/12_Chapter_12_img018_c7e38f37.png)

PMU\_HP\_MODEM\_DIG\_ICG\_APB\_EN Configures whether to enable HP system peripheral's APB clock in HP\_MODEM state. For detailed configuration please see Table 12.4-3 .

0: Disable

1: Enable

(R/W)

## Register 12.14. PMU\_HP\_MODEM\_HP\_SYS\_CNTL\_REG (0x0044)

![Image](images/12_Chapter_12_img019_1981899c.png)

PMU\_HP\_MODEM\_UART\_WAKEUP\_EN Configures whether to enable UART wake up function in

HP\_MODEM state.

0: Disable wake-up function

1: Enable wake-up function

(R/W)

PMU\_HP\_MODEM\_LP\_PAD\_HOLD\_ALL Configures whether to hold LP GPIO‘s configuration in

HP\_MODEM state.

0: Do not hold

1: Hold

(R/W)

PMU\_HP\_MODEM\_HP\_PAD\_HOLD\_ALL Configures whether to hold GPIO's configuration in HP\_MODEM state.

0: Do not hold

1: Hold

(R/W)

PMU\_HP\_MODEM\_DIG\_PAD\_SLP\_SEL Configures whether to use Light-sleep mode configuration for GPIO in HP\_MODEM state.

0: Use normal configuration

1: Use Light-sleep mode configuration. For details please refer to Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) &gt; Section 7.8 Pin Functions in Light-sleep . (R/W)

PMU\_HP\_MODEM\_DIG\_PAUSE\_WDT Configures whether to pause watchdog in HP\_MODEM state.

0: Do not pause

1: Pause

(R/W)

PMU\_HP\_MODEM\_DIG\_CPU\_STALL Configures whether to stall HP CPU in HP\_MODEM state.

0: Do not stall

1: Stall

(R/W)

## Register 12.15. PMU\_HP\_MODEM\_HP\_CK\_POWER\_REG (0x0048)

![Image](images/12_Chapter_12_img020_39fbea34.png)

PMU\_HP\_MODEM\_XPD\_BBPLL Configures whether to enable PLL\_CLK in HP\_MODEM state.

0: Disable

1: Enable

(R/W)

## Register 12.16. PMU\_HP\_MODEM\_BACKUP\_REG (0x0050)

![Image](images/12_Chapter_12_img021_854dc92e.png)

PMU\_HP\_SLEEP2MODEM\_BACKUP\_CLK\_SEL Configures the backup module's function clock source when PMU state switches from HP\_SLEEP to HP\_MODEM.

0: Select XTAL

1: Select PLL\_CLK

2: Select RC\_FAST\_CLK

3: Invalid value

(R/W)

PMU\_HP\_SLEEP2MODEM\_BACKUP\_MODE Configures the backup direction and link list when PMU state switches switch from HP\_SLEEP to HP\_MODEM.

Highest bit:

0: From peripheral to memory

1: From memory to peripheral

Lower two bits:

0: PAU\_LINK\_ADDR\_0

1: PAU\_LINK\_ADDR\_1

2: PAU\_LINK\_ADDR\_2

3: PAU\_LINK\_ADDR\_3

(R/W)

PMU\_HP\_SLEEP2MODEM\_BACKUP\_EN Configures whether to enable the backup flow when PMU state switches from HP\_SLEEP to HP\_MODEM.

0: Disable backup

1: Enable backup

(R/W)

## Register 12.17. PMU\_HP\_MODEM\_BACKUP\_CLK\_REG (0x0054)

![Image](images/12_Chapter_12_img022_4c29250e.png)

PMU\_HP\_MODEM\_BACKUP\_ICG\_FUNC\_EN Configures whether to enable each peripheral's function clock when the target state is HP\_MODEM. For details, please refer to Chapter 8 Reset and Clock .

0: Disable

1: Enable

(R/W)

## Register 12.18. PMU\_HP\_MODEM\_SYSCLK\_REG (0x0058)

![Image](images/12_Chapter_12_img023_1e6b826c.png)

- PMU\_HP\_MODEM\_ICG\_SYS\_CLOCK\_EN Configures whether to enable HP\_ROOT\_CLK in HP\_MODEM state.
- 0: Disable
- 1: Enable
- (R/W)
- PMU\_HP\_MODEM\_SYS\_CLK\_SLP\_SEL Configures whether to allow PMU to control the clock source in HP\_MODEM state.
- 0: Controlled by PCR registers
- 1: Controlled by PMU
- (R/W)
- PMU\_HP\_MODEM\_ICG\_SLP\_SEL Configures whether to allow PMU to control the clock gating in HP\_MODEM state.
- 0: Controlled by PCR registers
- 1: Controlled by PMU
- (R/W)
- PMU\_HP\_MODEM\_DIG\_SYS\_CLK\_SEL Configures the source of HP\_ROOT\_CLK in HP\_MODEM

state.

- 0: XTAL
- 1: PLL\_CLK
- 2: RC\_FAST\_CLK
- 3: Invalid value
- (R/W)

## Register 12.19. PMU\_HP\_MODEM\_HP\_REGULATOR0\_REG (0x005C)

![Image](images/12_Chapter_12_img024_af71361b.png)

PMU\_HP\_MODEM\_HP\_REGULATOR\_XPD Configures whether to enable the HP sys regulator in

HP\_MODEM state.

0: Disable

1: Enable

(R/W)

## Register 12.20. PMU\_HP\_MODEM\_XTAL\_REG (0x0064)

![Image](images/12_Chapter_12_img025_b695018d.png)

PMU\_HP\_MODEM\_XPD\_XTAL Configures whether to enable XTAL\_CLK analog source in

HP\_MODEM state.

0: Disable

1: Enable

(R/W) (R/W)

## Register 12.21. PMU\_HP\_SLEEP\_DIG\_POWER\_REG (0x0068)

![Image](images/12_Chapter_12_img026_dd7e5186.png)

- PMU\_HP\_SLEEP\_VDD\_SPI\_PD\_EN Configures whether to power down external flash in HP\_SLEEP state.
- 0: Power up
- 1: Power down

(R/W)

- PMU\_HP\_SLEEP\_HP\_MEM\_DSLP Configures whether to put Internal SRAMx into Deep-sleep mode

in HP\_SLEEP state.

- 0: Do not put Internal SRAMx into Deep-sleep
- 1: Put Internal SRAMx into Deep-sleep

(R/W)

- PMU\_HP\_SLEEP\_PD\_HP\_WIFI\_PD\_EN Configures whether to power down Modem domain in

HP\_SLEEP state.

- 0: Power up
- 1: Power down

(R/W)

- PMU\_HP\_SLEEP\_PD\_HP\_CPU\_PD\_EN Configures whether to power down CPU domain in HP\_SLEEP state.
- 0: Power up
- 1: Power down

(R/W)

- PMU\_HP\_SLEEP\_PD\_HP\_AON\_PD\_EN Configures whether to power down Modem power domain in HP\_SLEEP state.
- 0: Power up
- 1: Power down

(R/W)

PMU\_HP\_SLEEP\_PD\_TOP\_PD\_EN Configures whether to power down Peripherals domain in

HP\_SLEEP state.

- 0: Power up
- 1: Power down

(R/W)

Register 12.22. PMU\_HP\_SLEEP\_ICG\_HP\_FUNC\_REG (0x006C)

![Image](images/12_Chapter_12_img027_becd5b76.png)

PMU\_HP\_SLEEP\_DIG\_ICG\_FUNC\_EN Configures whether to enable HP system peripheral's function clock in HP\_SLEEP state. For detailed configuration please see Table 12.4-2 .

0: Disable

1: Enable

(R/W)

Register 12.23. PMU\_HP\_SLEEP\_ICG\_HP\_APB\_REG (0x0070)

![Image](images/12_Chapter_12_img028_4082ac32.png)

PMU\_HP\_SLEEP\_DIG\_ICG\_APB\_EN Configures whether to enable HP system peripheral's APB clock in HP\_SLEEP state. For detailed configuration please see Table 12.4-3 .

0: Disable

1: Enable

(R/W)

## Register 12.24. PMU\_HP\_SLEEP\_HP\_SYS\_CNTL\_REG (0x0078)

![Image](images/12_Chapter_12_img029_fcc06576.png)

PMU\_HP\_SLEEP\_UART\_WAKEUP\_EN Configures whether to enable UART wake up function in

HP\_SLEEP state.

0: Disable wake-up function

1: Enable wake-up function

(R/W)

PMU\_HP\_SLEEP\_LP\_PAD\_HOLD\_ALL Configures whether to hold LP GPIO's configuration in HP\_SLEEP state.

0: Do not hold

1: Hold

(R/W)

PMU\_HP\_SLEEP\_HP\_PAD\_HOLD\_ALL Configures whether to hold GPIO‘s configuration in

HP\_SLEEP state.

0: Do not hold

1: Hold

(R/W)

PMU\_HP\_SLEEP\_DIG\_PAD\_SLP\_SEL Configures whether to use Light-sleep mode configuration for GPIO in HP\_SLEEP state.

0: Use normal configuration

1: Use Light-sleep mode configuration. For details please refer to Chapter 7 IO MUX and GPIO Matrix (GPIO, IO MUX) &gt; Section 7.8 Pin Functions in Light-sleep .

(R/W)

PMU\_HP\_SLEEP\_DIG\_PAUSE\_WDT Configures whether to pause watchdog in HP\_SLEEP state.

0: Do not pause

1: Pause

(R/W)

PMU\_HP\_SLEEP\_DIG\_CPU\_STALL Configures whether to stall HP CPU in HP\_SLEEP state.

0: Do not stall

1: Stall

(R/W)

## Register 12.25. PMU\_HP\_SLEEP\_HP\_CK\_POWER\_REG (0x007C)

![Image](images/12_Chapter_12_img030_41c0dbcf.png)

PMU\_HP\_SLEEP\_XPD\_BBPLL Configures whether to enable PLL\_CLK in HP\_SLEEP state.

0: Disable

1: Enable

(R/W)

## Register 12.26. PMU\_HP\_SLEEP\_BACKUP\_REG (0x0084)

![Image](images/12_Chapter_12_img031_2a42e6e2.png)

PMU\_HP\_MODEM2SLEEP\_BACKUP\_CLK\_SEL Configures the backup module's function clock source when PMU state switches from HP\_MODEM to HP\_SLEEP.

0: Select XTAL

1: Select PLL\_CLK

2: Select RC\_FAST\_CLK

3: Invalid value

(R/W)

PMU\_HP\_ACTIVE2SLEEP\_BACKUP\_CLK\_SEL Configures the backup module function clock source when PMU state switches from HP\_ACTIVE to HP\_SLEEP. The configuration is the same as the register above. (R/W)

PMU\_HP\_MODEM2SLEEP\_BACKUP\_MODE Configures the backup direction and link list when PMU state switches switch from HP\_MODEM to HP\_SLEEP.

Highest bit:

0: From memory to peripheral

1: From peripheral to memory

Lower two bits:

0: PAU\_LINK\_ADDR\_0

1: PAU\_LINK\_ADDR\_1

- 2: PAU\_LINK\_ADDR\_2

3: PAU\_LINK\_ADDR\_3

(R/W)

PMU\_HP\_ACTIVE2SLEEP\_BACKUP\_MODE Configures the backup direction and link list when PMU state switches from HP\_ACTIVE to HP\_SLEEP. The configuration is the same as the register above. (R/W)

PMU\_HP\_MODEM2SLEEP\_BACKUP\_EN Configures whether to enable the backup flow when PMU state switches from HP\_MODEM to HP\_SLEEP.

0: Disable backup

1: Enable backup

(R/W)

Continued on the next page...

## Register 12.26. PMU\_HP\_SLEEP\_BACKUP\_REG (0x0084)

## Continued from the previous page...

PMU\_HP\_ACTIVE2SLEEP\_BACKUP\_EN Configures whether to enable the backup flow when PMU state switches from HP\_ACTIVE to HP\_SLEEP.

0: Disable backup

1: Enable backup

(R/W)

## Register 12.27. PMU\_HP\_SLEEP\_BACKUP\_CLK\_REG (0x0088)

![Image](images/12_Chapter_12_img032_ef2542c3.png)

PMU\_HP\_SLEEP\_BACKUP\_ICG\_FUNC\_EN Configures whether to enable each peripheral's function clock when the target state is HP\_SLEEP. For details, please refer to Chapter 8 Reset and Clock .

0: Disable

- 1: Enable

(R/W)

## Register 12.28. PMU\_HP\_SLEEP\_SYSCLK\_REG (0x008C)

![Image](images/12_Chapter_12_img033_dd3d7b5f.png)

PMU\_HP\_SLEEP\_ICG\_SYS\_CLOCK\_EN Configures whether to enable HP\_ROOT\_CLK in HP\_SLEEP

state.

- 0: Disable
- 1: Enable

(R/W)

PMU\_HP\_SLEEP\_SYS\_CLK\_SLP\_SEL Configures whether to allow PMU to control the clock source in HP\_SLEEP state.

- 0: Controlled by PCR registers
- 1: Controlled by PMU

(R/W)

- PMU\_HP\_SLEEP\_ICG\_SLP\_SEL Configures whether to allow PMU to control the clock gating in HP\_SLEEP state.
- 0: Controlled by PCR registers
- 1: Controlled by PMU

(R/W)

PMU\_HP\_SLEEP\_DIG\_SYS\_CLK\_SEL Configures the source of HP\_ROOT\_CLK in HP\_SLEEP state.

- 0: XTAL
- 1: PLL\_CLK
- 2: RC\_FAST\_CLK
- 3: Invalid value

(R/W)

ESP32-C6 TRM (Version 1.1)

## Register 12.29. PMU\_HP\_SLEEP\_HP\_REGULATOR0\_REG (0x0090)

![Image](images/12_Chapter_12_img034_61d5c83a.png)

PMU\_HP\_SLEEP\_HP\_REGULATOR\_XPD Configures whether to enable the HP sys regulator in

HP\_SLEEP state.

0: Disable

1: Enable

(R/W)

## Register 12.30. PMU\_HP\_SLEEP\_XTAL\_REG (0x0098)

![Image](images/12_Chapter_12_img035_729930a5.png)

PMU\_HP\_SLEEP\_XPD\_XTAL Configures whether to enable XTAL\_CLK analog source in HP\_SLEEP

state.

0: Disable

1: Enable

(R/W)

ESP32-C6 TRM (Version 1.1)

## Register 12.31. PMU\_HP\_SLEEP\_LP\_DIG\_POWER\_REG (0x00A8)

![Image](images/12_Chapter_12_img036_fcff0dec.png)

PMU\_HP\_SLEEP\_LP\_MEM\_DSLP Configures whether to enable Memory Deep-sleep mode for the 16 KB SRAM in HP\_ACTIVE/HP\_MODEM/HP\_SLEEP state.

- 0: Disable
- 1: Enable

(R/W)

PMU\_HP\_SLEEP\_PD\_LP\_PERI\_PD\_EN Configures whether to power down LP PD Peripherals domain in HP\_ACTIVE/HP\_MODEM/HP\_SLEEP state.

- 0: Power up
- 1: Power down

(R/W)

## Register 12.32. PMU\_HP\_SLEEP\_LP\_CK\_POWER\_REG (0x00AC)

![Image](images/12_Chapter_12_img037_3fc04219.png)

PMU\_HP\_SLEEP\_XPD\_XTAL32K Configures whether to power up XTAL32K\_CLK analog part circuit in HP\_ACTIVE/HP\_MODEM/HP\_SLEEP state.

- 0: Power down
- 1: Power up

(R/W)

PMU\_HP\_SLEEP\_XPD\_FOSC\_CLK Configures whether to power up RC\_FAST\_CLK analog part circuit in HP\_ACTIVE/HP\_MODEM/HP\_SLEEP state.

- 0: Power down
- 1: Power up

(R/W)

## Register 12.33. PMU\_LP\_SLEEP\_XTAL\_REG (0x00BC)

![Image](images/12_Chapter_12_img038_9b257d60.png)

PMU\_LP\_SLEEP\_XPD\_XTAL Configures whether to enable XTAL\_CLK analog source in LP\_SLEEP

state.

0: Disable

- 1: Enable

(R/W)

## Register 12.34. PMU\_LP\_SLEEP\_LP\_DIG\_POWER\_REG (0x00C0)

![Image](images/12_Chapter_12_img039_7491e152.png)

PMU\_LP\_SLEEP\_LP\_MEM\_DSLP Configures whether to enable Memory Deep-sleep mode for the

- 16 KB SRAM in LP\_SLEEP state.
- 0: Disable
- 1: Enable

(R/W)

- PMU\_LP\_SLEEP\_PD\_LP\_PERI\_PD\_EN Configures whether to power down the LP PD Peripherals domain in LP\_SLEEP state.
- 0: Power up
- 1: Power down

(R/W)

## Register 12.35. PMU\_LP\_SLEEP\_LP\_CK\_POWER\_REG (0x00C4)

![Image](images/12_Chapter_12_img040_1420714e.png)

- PMU\_LP\_SLEEP\_XPD\_XTAL32K Configures whether to power up XTAL32K\_CLK analog part circuit

in LP\_SLEEP state.

- 0: Power down
- 1: Power up

(R/W)

- PMU\_LP\_SLEEP\_XPD\_FOSC\_CLK Configures whether to power up RC\_FAST\_CLK analog part circuit in LP\_SLEEP state.
- 0: Power down
- 1: Power up

(R/W)

## Register 12.36. PMU\_IMM\_PAD\_HOLD\_ALL\_REG (0x00E4)

![Image](images/12_Chapter_12_img041_e33d691e.png)

PMU\_TIE\_HIGH\_LP\_PAD\_HOLD\_ALL Enables the global Hold signal for the LP pads. (WT)

PMU\_TIE\_LOW\_LP\_PAD\_HOLD\_ALL Disables the global Hold signal for the LP pads. (WT)

PMU\_TIE\_HIGH\_HP\_PAD\_HOLD\_ALL Enables the global Hold signal for the digital pads. (WT)

PMU\_TIE\_LOW\_HP\_PAD\_HOLD\_ALL Disables the global Hold signal for the digital pads. (WT)

## Register 12.37. PMU\_POWER\_PD\_MEM\_MASK\_REG (0x0110)

![Image](images/12_Chapter_12_img042_c33ba800.png)

- PMU\_PD\_HP\_MEM2\_PD\_MASK Configures whether the Internal SRAM2 domain follows the power

up/down state of the Peripherals domain.

- 0: Follows Peripherals domain
- 1: Does not follow Peripherals domain.

(R/W)

- PMU\_PD\_HP\_MEM1\_PD\_MASK Configures whether the Internal SRAM1 domain follows the power up/down state of the Peripherals domain.
- 0: Follows Peripherals domain
- 1: Does not follow Peripherals domain.

(R/W)

- PMU\_PD\_HP\_MEM0\_PD\_MASK Configures whether the Internal SRAM0 domain follows the power up/down state of the Peripherals domain.
- 0: Follows Peripherals domain
- 1: Does not follow Peripherals domain.

(R/W)

PMU\_PD\_HP\_MEM2\_MASK Configures whether to force power up Internal SRAM2.

- 0: Do not force power up
- 1: Force power up

(R/W)

PMU\_PD\_HP\_MEM1\_MASK Configures whether to to force power up Internal SRAM1.

- 0: Do not force power up

1: Force power up

(R/W)

PMU\_PD\_HP\_MEM0\_MASK Configures whether to force power up Internal SRAM0.

- 0: Do not force power up

1: Force power up

(R/W)

## Register 12.38. PMU\_POWER\_CK\_WAIT\_CNTL\_REG (0x011C)

![Image](images/12_Chapter_12_img043_9ae448a7.png)

PMU\_WAIT\_PLL\_STABLE Configures the number of CLK\_DYN\_FAST\_CLK cycles after which PLL\_CLK gate opening is enabled. (R/W)

PMU\_WAIT\_XTAL\_STABLE Configures the number of CLK\_DYN\_FAST\_CLK cycles after which XTAL\_CLK gate opening is enabled. (R/W)

## Register 12.39. PMU\_SLP\_WAKEUP\_CNTL0\_REG (0x0120)

![Image](images/12_Chapter_12_img044_1d048c36.png)

PMU\_SLEEP\_REQ Configures whether to switch the chip’s PMU state to HP\_SLEEP or LP\_SLEEP.

- 0: Do not switch

1: Switch to HP\_SLEEP or LP\_SLEEP, depending on the state of the LP CPU.

(WT)

## Register 12.40. PMU\_SLP\_WAKEUP\_CNTL1\_REG (0x0124)

![Image](images/12_Chapter_12_img045_9b10e8e8.png)

PMU\_SLEEP\_REJECT\_ENA Configures the sleep rejection source. For the mapping between values and sources please refer to Table 12.4-1. (R/W)

PMU\_SLP\_REJECT\_EN Configures whether to enable sleep rejection function.

0: Disable

1: Enable

(R/W)

Register 12.41. PMU\_SLP\_WAKEUP\_CNTL2\_REG (0x0128)

PMU\_WAKEUP\_ENA

![Image](images/12_Chapter_12_img046_2ac1293e.png)

PMU\_WAKEUP\_ENA Configures wake-up source. For the mapping between values and sources please refer to Table 12.4-1. (R/W)

![Image](images/12_Chapter_12_img047_c1ed5443.png)

PMU\_SLP\_REJECT\_CAUSE\_CLR Write 1 to clear PMU\_REJECT\_CAUSE. (WT)

Register 12.43. PMU\_SLP\_WAKEUP\_STATUS0\_REG (0x0140)

![Image](images/12_Chapter_12_img048_9cd22be3.png)

PMU\_WAKEUP\_CAUSE Indicates the wake-up source. For the mapping between values and sources please refer to Table 12.4-1. (RO)

## Register 12.44. PMU\_SLP\_WAKEUP\_STATUS1\_REG (0x0144)

![Image](images/12_Chapter_12_img049_7b279f47.png)

![Image](images/12_Chapter_12_img050_a5a992c9.png)

PMU\_REJECT\_CAUSE Indicates the wake-up rejection source. For the mapping between values and sources please refer to Table 12.4-1. (RO)

## Register 12.45. PMU\_INT\_RAW\_REG (0x015C)

![Image](images/12_Chapter_12_img051_9942a7da.png)

PMU\_LP\_CPU\_EXC\_INT\_RAW The raw interrupt status of PMU\_LP\_CPU\_EXC\_INT. (R/WTC/SS)

PMU\_SDIO\_IDLE\_INT\_RAW The raw interrupt status of PMU\_SDIO\_IDLE\_INT. (R/WTC/SS)

PMU\_SW\_INT\_RAW The raw interrupt status of PMU\_SW\_INT. (R/WTC/SS)

PMU\_SOC\_SLEEP\_REJECT\_INT\_RAW The raw interrupt status of PMU\_SOC\_SLEEP\_REJECT\_INT . (R/WTC/SS)

PMU\_SOC\_WAKEUP\_INT\_RAW The raw interrupt status of PMU\_SOC\_WAKEUP\_INT. (R/WTC/SS)

## Register 12.46. PMU\_HP\_INT\_ST\_REG (0x0160)

![Image](images/12_Chapter_12_img052_5942f789.png)

PMU\_LP\_CPU\_EXC\_INT\_ST The masked interrupt status of PMU\_LP\_CPU\_EXC\_INT. (RO)

PMU\_SDIO\_IDLE\_INT\_ST The masked interrupt status of PMU\_SDIO\_IDLE\_INT. (RO)

PMU\_SW\_INT\_ST The masked interrupt status of PMU\_SW\_INT. (RO)

PMU\_SOC\_SLEEP\_REJECT\_INT\_ST The masked interrupt status of PMU\_SOC\_SLEEP\_REJECT\_INT . (RO)

PMU\_SOC\_WAKEUP\_INT\_ST The masked interrupt status of PMU\_SOC\_WAKEUP\_INT. (RO)

## Register 12.47. PMU\_HP\_INT\_ENA\_REG (0x0164)

![Image](images/12_Chapter_12_img053_289f9bbd.png)

PMU\_LP\_CPU\_EXC\_INT\_ENA Write 1 to enable PMU\_LP\_CPU\_EXC\_INT. (R/W)

PMU\_SDIO\_IDLE\_INT\_ENA Write 1 to enable PMU\_SDIO\_IDLE\_INT. (R/W)

PMU\_SW\_INT\_ENA Write 1 to enable PMU\_SW\_INT. (R/W)

PMU\_SOC\_SLEEP\_REJECT\_INT\_ENA Write 1 to enable PMU\_SOC\_SLEEP\_REJECT\_INT. (R/W)

PMU\_SOC\_WAKEUP\_INT\_ENA Write 1 to enable PMU\_SOC\_WAKEUP\_INT. (R/W)

## Register 12.48. PMU\_HP\_INT\_CLR\_REG (0x0168)

![Image](images/12_Chapter_12_img054_e9a53509.png)

PMU\_LP\_CPU\_EXC\_INT\_CLR Write 1 to clear PMU\_LP\_CPU\_EXC\_INT. (WT) PMU\_SDIO\_IDLE\_INT\_CLR Write 1 to clear PMU\_SDIO\_IDLE\_INT. (WT) PMU\_SW\_INT\_CLR Write 1 to clear PMU\_SW\_INT. (WT) PMU\_SOC\_SLEEP\_REJECT\_INT\_CLR Write 1 to clear PMU\_SOC\_SLEEP\_REJECT\_INT. (WT) PMU\_SOC\_WAKEUP\_INT\_CLR Write 1 to clear PMU\_SOC\_WAKEUP\_INT. (WT)

## Register 12.49. PMU\_LP\_INT\_RAW\_REG (0x016C)

![Image](images/12_Chapter_12_img055_977a0495.png)

| PMU_LP_CPU_WAKEUP_INT_RAW The raw interrupt status of  . (R/WTC/SS)                                             | PMU_LP_CPU_WAKEUP_INT   |
|-----------------------------------------------------------------------------------------------------------------|-------------------------|
| PMU_MODEM_SWITCH_ACTIVE_END_INT_RAW The raw interrupt status of PMU_MODEM_SWITCH_ACTIVE_END_INT. (R/WTC/SS)     |                         |
| PMU_SLEEP_SWITCH_ACTIVE_END_INT_RAW The raw interrupt status of PMU_SLEEP_SWITCH_ACTIVE_END_INT. (R/WTC/SS)     |                         |
| PMU_SLEEP_SWITCH_MODEM_END_INT_RAW The raw interrupt status of PMU_SLEEP_SWITCH_MODEM_END_INT. (R/WTC/SS)       |                         |
| PMU_MODEM_SWITCH_SLEEP_END_INT_RAW The raw interrupt status of PMU_MODEM_SWITCH_SLEEP_END_INT. (R/WTC/SS)       |                         |
| PMU_ACTIVE_SWITCH_SLEEP_END_INT_RAW The raw interrupt status of PMU_ACTIVE_SWITCH_SLEEP_END_INT. (R/WTC/SS)     |                         |
| PMU_MODEM_SWITCH_ACTIVE_START_INT_RAW The raw interrupt status of PMU_MODEM_SWITCH_ACTIVE_START_INT. (R/WTC/SS) |                         |
| PMU_SLEEP_SWITCH_ACTIVE_START_INT_RAW The raw interrupt status of PMU_SLEEP_SWITCH_ACTIVE_START_INT. (R/WTC/SS) |                         |
| PMU_SLEEP_SWITCH_MODEM_START_INT_RAW The raw interrupt status of PMU_SLEEP_SWITCH_MODEM_START_INT. (R/WTC/SS)   |                         |
| PMU_MODEM_SWITCH_SLEEP_START_INT_RAW The raw interrupt status of PMU_MODEM_SWITCH_SLEEP_START_INT. (R/WTC/SS)   |                         |
| PMU_ACTIVE_SWITCH_SLEEP_START_INT_RAW The raw interrupt status of PMU_ACTIVE_SWITCH_SLEEP_START_INT. (R/WTC/SS) |                         |

PMU\_HP\_SW\_TRIGGER\_INT\_RAW The raw interrupt status of PMU\_HP\_SW\_TRIGGER\_INT . (R/WTC/SS)

## Register 12.50. PMU\_LP\_INT\_ST\_REG (0x0170)

![Image](images/12_Chapter_12_img056_b941986f.png)

PMU\_LP\_CPU\_WAKEUP\_INT\_ST The masked interrupt status of PMU\_LP\_CPU\_WAKEUP\_INT. (RO)

| PMU_MODEM_SWITCH_ACTIVE_END_INT_ST The masked interrupt status of PMU_MODEM_SWITCH_ACTIVE_END_INT. (RO)     |
|-------------------------------------------------------------------------------------------------------------|
| PMU_SLEEP_SWITCH_ACTIVE_END_INT_ST The masked interrupt status of PMU_SLEEP_SWITCH_ACTIVE_END_INT. (RO)     |
| PMU_SLEEP_SWITCH_MODEM_END_INT_ST The masked interrupt status of PMU_SLEEP_SWITCH_MODEM_END_INT. (RO)       |
| PMU_MODEM_SWITCH_SLEEP_END_INT_ST The masked interrupt status of PMU_MODEM_SWITCH_SLEEP_END_INT. (RO)       |
| PMU_ACTIVE_SWITCH_SLEEP_END_INT_ST The masked interrupt status of PMU_ACTIVE_SWITCH_SLEEP_END_INT. (RO)     |
| PMU_MODEM_SWITCH_ACTIVE_START_INT_ST The masked interrupt status of PMU_MODEM_SWITCH_ACTIVE_START_INT. (RO) |
| PMU_SLEEP_SWITCH_ACTIVE_START_INT_ST The masked interrupt status of PMU_SLEEP_SWITCH_ACTIVE_START_INT. (RO) |
| PMU_SLEEP_SWITCH_MODEM_START_INT_ST The masked interrupt status of PMU_SLEEP_SWITCH_MODEM_START_INT. (RO)   |
| PMU_MODEM_SWITCH_SLEEP_START_INT_ST The masked interrupt status of PMU_MODEM_SWITCH_SLEEP_START_INT. (RO)   |
| PMU_ACTIVE_SWITCH_SLEEP_START_INT_ST The masked interrupt status of PMU_ACTIVE_SWITCH_SLEEP_START_INT. (RO) |

PMU\_HP\_SW\_TRIGGER\_INT\_ST The masked interrupt status of PMU\_HP\_SW\_TRIGGER\_INT. (RO)

## Register 12.51. PMU\_LP\_INT\_ENA\_REG (0x0174)

![Image](images/12_Chapter_12_img057_fbae2f1b.png)

PMU\_LP\_CPU\_WAKEUP\_INT\_ENA Write 1 to enable PMU\_LP\_CPU\_WAKEUP\_INT. (R/W)

PMU\_MODEM\_SWITCH\_ACTIVE\_END\_INT\_ENA Write

PMU\_MODEM\_SWITCH\_ACTIVE\_END\_INT. (R/W)

- PMU\_SLEEP\_SWITCH\_ACTIVE\_END\_INT\_ENA Write 1 to enable PMU\_SLEEP\_SWITCH\_ACTIVE\_END\_INT . (R/W)
- PMU\_SLEEP\_SWITCH\_MODEM\_END\_INT\_ENA Write 1 to enable PMU\_SLEEP\_SWITCH\_MODEM\_END\_INT . (R/W)
- PMU\_MODEM\_SWITCH\_SLEEP\_END\_INT\_ENA Write 1 to enable PMU\_MODEM\_SWITCH\_SLEEP\_END\_INT . (R/W)
- PMU\_ACTIVE\_SWITCH\_SLEEP\_END\_INT\_ENA Write 1 to enable PMU\_ACTIVE\_SWITCH\_SLEEP\_END\_INT . (R/W)

| PMU_MODEM_SWITCH_ACTIVE_START_INT_ENA Write  PMU_MODEM_SWITCH_ACTIVE_START_INT. (R/W)   |   1 | to   | enable   |
|-----------------------------------------------------------------------------------------|-----|------|----------|
| PMU_SLEEP_SWITCH_ACTIVE_START_INT_ENA Write  PMU_SLEEP_SWITCH_ACTIVE_START_INT. (R/W)   |   1 | to   | enable   |
| PMU_SLEEP_SWITCH_MODEM_START_INT_ENA Write  PMU_SLEEP_SWITCH_MODEM_START_INT. (R/W)     |   1 | to   | enable   |
| PMU_MODEM_SWITCH_SLEEP_START_INT_ENA Write  PMU_MODEM_SWITCH_SLEEP_START_INT. (R/W)     |   1 | to   | enable   |
| PMU_ACTIVE_SWITCH_SLEEP_START_INT_ENA Write  PMU_ACTIVE_SWITCH_SLEEP_START_INT. (R/W)   |   1 | to   | enable   |

PMU\_HP\_SW\_TRIGGER\_INT\_ENA Write 1 to enable PMU\_HP\_SW\_TRIGGER\_INT. (R/W)

1

to enable

## Register 12.52. PMU\_LP\_INT\_CLR\_REG (0x0178)

![Image](images/12_Chapter_12_img058_226e8cce.png)

PMU\_LP\_CPU\_WAKEUP\_INT\_CLR Write 1 to clear PMU\_LP\_CPU\_WAKEUP\_INT. (WT)

- PMU\_MODEM\_SWITCH\_ACTIVE\_END\_INT\_CLR Write 1 to clear PMU\_MODEM\_SWITCH\_ACTIVE\_END\_INT . (WT)
- PMU\_SLEEP\_SWITCH\_ACTIVE\_END\_INT\_CLR Write 1 to clear PMU\_SLEEP\_SWITCH\_ACTIVE\_END\_INT . (WT)
- PMU\_SLEEP\_SWITCH\_MODEM\_END\_INT\_CLR Write 1 to clear PMU\_SLEEP\_SWITCH\_MODEM\_END\_INT . (WT)
- PMU\_MODEM\_SWITCH\_SLEEP\_END\_INT\_CLR Write 1 to clear PMU\_MODEM\_SWITCH\_SLEEP\_END\_INT . (WT)
- PMU\_ACTIVE\_SWITCH\_SLEEP\_END\_INT\_CLR Write 1 to clear PMU\_ACTIVE\_SWITCH\_SLEEP\_END\_INT . (WT)
- PMU\_MODEM\_SWITCH\_ACTIVE\_START\_INT\_CLR Write 1 to clear PMU\_MODEM\_SWITCH\_ACTIVE\_START\_INT. (WT)
- PMU\_SLEEP\_SWITCH\_ACTIVE\_START\_INT\_CLR Write 1 to clear PMU\_SLEEP\_SWITCH\_ACTIVE\_START\_INT . (WT)
- PMU\_SLEEP\_SWITCH\_MODEM\_START\_INT\_CLR Write 1 to clear PMU\_SLEEP\_SWITCH\_MODEM\_START\_INT . (WT)
- PMU\_MODEM\_SWITCH\_SLEEP\_START\_INT\_CLR Write 1 to clear PMU\_MODEM\_SWITCH\_SLEEP\_START\_INT . (WT)
- PMU\_ACTIVE\_SWITCH\_SLEEP\_START\_INT\_CLR Write 1 to clear PMU\_ACTIVE\_SWITCH\_SLEEP\_START\_INT . (WT)
- PMU\_HP\_SW\_TRIGGER\_INT\_CLR Write 1 to clear PMU\_HP\_SW\_TRIGGER\_INT. (WT)

## Register 12.53. PMU\_LP\_CPU\_PWR0\_REG (0x017C)

![Image](images/12_Chapter_12_img059_00f5dd38.png)

PMU\_LP\_CPU\_SLP\_STALL\_WAIT Configures the time to wait for the stall to take effect after enabling stall state when the LP CPU enters sleep mode. The unit is LP\_DYN\_FAST\_CLK. (R/W)

PMU\_LP\_CPU\_SLP\_STALL\_EN Configures whether to stall LP CPU when it goes into sleep mode.

0: Do not stall

1: Stall

(R/W)

- PMU\_LP\_CPU\_SLP\_RESET\_EN Configures whether to reset LP CPU when it goes into sleep mode.
- 0: Do not reset

1: Reset

(R/W)

- PMU\_LP\_CPU\_SLP\_BYPASS\_INTR\_EN Configures whether to enable interrupt enable signal when LP CPU is in sleep mode.
- 0: Disable all interrupt signals to LP CPU
- 1: Enable interrupt signals to LP CPU

(R/W)

Register 12.54. PMU\_LP\_CPU\_PWR1\_REG (0x0180)

![Image](images/12_Chapter_12_img060_faa4bf90.png)

PMU\_LP\_CPU\_WAKEUP\_EN Configures the wake-up source for LP CPU. For details please refer to Chapter 3 Low-Power CPU &gt; Table 3.9-1 Wake Sources. (R/W)

PMU\_LP\_CPU\_SLEEP\_REQ Configures whether to put LP CPU into sleep.

0: Do not put LP CPU into sleep.

```
1: Put LP CPU into sleep. (WT)
```

Register 12.55. PMU\_HP\_LP\_CPU\_COMM\_REG (0x0184)

![Image](images/12_Chapter_12_img061_1058f1bb.png)

PMU\_LP\_TRIGGER\_HP When LP CPU configures this register to 1, the chip is woken up. (WT)

PMU\_HP\_TRIGGER\_LP When HP CPU configures this register to 1, LP CPU is woken up. (WT)

## Register 12.56. PMU\_DATE\_REG (0x03FC)

![Image](images/12_Chapter_12_img062_5a1494b7.png)

PMU\_PMU\_DATE Version control register. (R/W)

## 12.10.2 Always-on Registers

The addresses in this section are relative to the Always-on registers base address provided in Table 5.3-2 in Chapter 5 System and Memory .

For how to program reserved fields, please refer to Section Programming Reserved Register Field .

![Image](images/12_Chapter_12_img063_825541b2.png)

LP\_AON\_GPIO\_HOLD0 Selects the Hold enable signal for each digital pad. (R/W)

## Register 12.60. LP\_AON\_SYS\_CFG\_REG (0x0034)

![Image](images/12_Chapter_12_img064_a146279b.png)

- LP\_AON\_FORCE\_DOWNLOAD\_BOOT Configures whether to trigger a CPU reset and switch the chip boot mode.
- 0: No effect.
- 1: If EFUSE\_DIS\_FORCE\_DOWNLOAD is 0, software can force switch the chip from SPI Boot mode to Joint Download Boot mode and trigger a CPU reset.

(R/W)

- LP\_AON\_HPSYS\_SW\_RESET Configures System Reset.
- 0: No effect
- 1: Enable reset

(WT)

## Register 12.61. LP\_AON\_CPUCORE0\_CFG\_REG (0x0038)

![Image](images/12_Chapter_12_img065_6b9e357b.png)

- LP\_AON\_CPU\_CORE0\_SW\_RESET Configures CPU Reset.
- 0: No effect
- 1: Enable reset

(WT)

- LP\_AON\_CORE0\_STAT\_VECTOR\_SEL Configures whether to start up the CPU from the RTC fast memory.
- 0: Do not start up from the RTC fast memory.
- 1: Start up from the RTC fast memory.
- (R/W)

## Register 12.62. LP\_AON\_LPBUS\_REG (0x0048)

![Image](images/12_Chapter_12_img066_e8b9409b.png)

- LP\_AON\_FAST\_MEM\_MUX\_SEL\_STATUS Indicates whether the LP SRAM access mode switch has succeeded or not. (RO)

LP\_AON\_FAST\_MEM\_MUX\_SEL\_UPDATE Set this bit to 1 to switch the access mode. (WT)

- LP\_AON\_FAST\_MEM\_MUX\_SEL Configures the access mode to the LP SRAM.

0: Low-speed mode

1: High-speed mode

(R/W)

## 12.10.3 RTC Timer Registers

The addresses in this section are relative to the RTC Timer base address provided in Table 5.3-2 in Chapter 5 System and Memory .

For how to program reserved fields, please refer to Section Programming Reserved Register Field .

Register 12.63. RTC\_TIMER\_TAR0\_LOW\_REG (0x0000)

![Image](images/12_Chapter_12_img067_d9315654.png)

RTC\_TIMER\_MAIN\_TIMER\_TAR\_LOW0 Configures the low 32 bits of the target count value 0 (48 bits total) of the RTC timer. (R/W)

Register 12.64. RTC\_TIMER\_TAR0\_HIGH\_REG (0x0004)

![Image](images/12_Chapter_12_img068_583e1518.png)

RTC\_TIMER\_MAIN\_TIMER\_TAR\_EN0 Configures whether to generate interrupts for the target count value 0 of the RTC timer.

- 0: Do not generate interrupts
- 1: Generate interrupts

(R/W)

RTC\_TIMER\_MAIN\_TIMER\_TAR\_HIGH0 Configures the high 16 bits of the target count value 0 (48 bits total) of the RTC timer. (R/W)

## Register 12.65. RTC\_TIMER\_TAR1\_LOW\_REG (0x0008)

![Image](images/12_Chapter_12_img069_48858197.png)

RTC\_TIMER\_MAIN\_TIMER\_TAR\_LOW1 Configures the low 32 bits of the target count value 1 (48 bits total) of the RTC timer. (R/W)

Register 12.66. RTC\_TIMER\_TAR0\_HIGH\_REG (0x000C)

![Image](images/12_Chapter_12_img070_16a47cae.png)

RTC\_TIMER\_MAIN\_TIMER\_TAR\_EN1 Configures whether to generate interrupts for the target count value 1 of the RTC timer.

0: Do not generate interrupts

1: Generate interrupts

(R/W)

RTC\_TIMER\_MAIN\_TIMER\_TAR\_HIGH1 Configures the high 16 bits of the target count value 1 (48

bits total) of the RTC timer. (R/W)

## Register 12.67. RTC\_TIMER\_UPDATE\_REG (0x0010)

![Image](images/12_Chapter_12_img071_98a398af.png)

RTC\_TIMER\_MAIN\_TIMER\_SYS\_RST Configures whether to trigger RTC timer upon system reset.

0: Do not trigger

1: Trigger

(R/W)

RTC\_TIMER\_MAIN\_TIMER\_SYS\_STALL Configures whether to trigger RTC timer when the CPU en- ters or exits stall state.

0: Do not trigger

1: Trigger

(R/W)

- RTC\_TIMER\_MAIN\_TIMER\_XTAL\_OFF Configures whether to trigger RTC timer when PMU powers up or down the 40 MHz crystal.

0: Do not trigger

1: Trigger

(R/W)

RTC\_TIMER\_UPDATE Configures whether to trigger RTC timer by software.

0: Do not trigger

1: Trigger

(R/W)

## Register 12.68. RTC\_TIMER\_MAIN\_BUF0\_LOW\_REG (0x0014)

![Image](images/12_Chapter_12_img072_5e6b6b48.png)

RTC\_TIMER\_MAIN\_BUF0\_LOW Register group 0 records the count value of the RTC timer, bit0 to bit31. (RO)

Register 12.69. RTC\_TIMER\_MAIN\_BUF0\_HIGH\_REG (0x0018)

RTC\_TIMER\_MAIN\_BUF0\_HIGH

![Image](images/12_Chapter_12_img073_d46f29ce.png)

RTC\_TIMER\_MAIN\_BUF0\_HIGH Register group 0 records the count value of the RTC timer, bit32 to bit47, corresponding to bit[0:15]. (RO)

## Register 12.70. RTC\_TIMER\_MAIN\_BUF1\_LOW\_REG (0x001C)

RTC\_TIMER\_MAIN\_BUF1\_LOW

![Image](images/12_Chapter_12_img074_6e436439.png)

RTC\_TIMER\_MAIN\_BUF1\_LOW Register group 1 records the count value of the RTC timer, bit0 to bit31. (RO)

## Register 12.71. RTC\_TIMER\_MAIN\_BUF1\_HIGH\_REG (0x0020)

![Image](images/12_Chapter_12_img075_ad16717f.png)

![Image](images/12_Chapter_12_img076_a3a148f9.png)

RTC\_TIMER\_MAIN\_BUF1\_HIGH Register group 1 records the count value of the RTC timer, bit32 to bit47, corresponding to bit[0:15]. (RO)

## Register 12.72. RTC\_TIMER\_INT\_RAW\_REG (0x0028)

![Image](images/12_Chapter_12_img077_342cb971.png)

RTC\_TIMER\_MAIN\_TIMER\_INT\_RAW The raw interrupt status of RTC\_TIMER\_MAIN\_TIMER\_INT . (RO)

RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT\_RAW The raw interrupt status of RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT. (RO)

## Register 12.73. RTC\_TIMER\_INT\_ST\_REG (0x002C)

![Image](images/12_Chapter_12_img078_06170764.png)

RTC\_TIMER\_MAIN\_TIMER\_INT\_ST The masked interrupt status of RTC\_TIMER\_MAIN\_TIMER\_INT . (RO)

RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT\_ST The masked interrupt status of RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT. (RO)

## Register 12.74. RTC\_TIMER\_INT\_ENA\_REG (0x0030)

![Image](images/12_Chapter_12_img079_63bcc183.png)

RTC\_TIMER\_MAIN\_TIMER\_INT\_ENA Write 1 to enable RTC\_TIMER\_MAIN\_TIMER\_INT. (RO) RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT\_ENA Write 1 to enable

RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT. (RO)

## Register 12.75. RTC\_TIMER\_INT\_CLR\_REG (0x0034)

![Image](images/12_Chapter_12_img080_09afba1c.png)

RTC\_TIMER\_MAIN\_TIMER\_INT\_CLR Write 1 to clear RTC\_TIMER\_MAIN\_TIMER\_INT. (RO) RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT\_CLR Write 1 to clear RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_INT . (RO)

## Register 12.76. RTC\_TIMER\_LP\_INT\_RAW\_REG (0x0038)

\_TIMER\_MAIN\_TIMER\_LP\_INT\_RAW
RTC\_TIMER\_MAIN\_TIMER\_LP\_OVERFLOW\_INT\_RAW

RTC\_TIMER\_MAIN\_TIMER\_LP\_INT\_RAW
RTC\_TIMER\_MAIN\_TIMER\_LP\_OVER

31

30

29

0x0

0x0

RTC\_TIMER\_MAIN\_TIMER\_LP\_INT\_RAW The

RTC\_TIMER\_MAIN\_TIMER\_LP\_INT. (RO)

RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_LP\_INT\_RAW The raw interrupt status of

RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_LP\_INT. (RO)

## Register 12.77. RTC\_TIMER\_LP\_INT\_ST\_REG (0x003C)

![Image](images/12_Chapter_12_img081_603a2981.png)

reserved

0x0

raw interrupt

status

0

Reset of

## Register 12.78. RTC\_TIMER\_LP\_INT\_ENA\_REG (0x0040)

![Image](images/12_Chapter_12_img082_d083c883.png)

RTC\_TIMER\_MAIN\_TIMER\_LP\_INT\_ENA Write 1 to enable RTC\_TIMER\_MAIN\_TIMER\_LP\_INT. (RO) RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_LP\_INT\_ENA Write 1 to enable RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_LP\_INT. (RO)

![Image](images/12_Chapter_12_img083_f48bb44f.png)

RTC\_TIMER\_MAIN\_TIMER\_LP\_INT\_CLR Write 1 to clear RTC\_TIMER\_MAIN\_TIMER\_LP\_INT. (RO) RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_LP\_INT\_CLR Write 1 to clear

RTC\_TIMER\_MAIN\_TIMER\_OVERFLOW\_LP\_INT. (RO)

## 12.10.4 Brownout Detector Registers

The addresses in this section are relative to the Low-power Analog Peripheral (LP\_ANA\_PERI) base address provided in Table 5.3-2 in Chapter 5 System and Memory .

For how to program reserved fields, please refer to Section Programming Reserved Register Field .

## Register 12.80. LP\_ANA\_BOD\_MODE0\_CNTL\_REG (0x0000)

![Image](images/12_Chapter_12_img084_40837d40.png)

- LP\_ANA\_BOD\_MODE0\_CLOSE\_FLASH\_ENA Configures whether to enable the brownout detector
- to trigger flash suspend.
- 0: Disable
- 1: Enable
- (R/W)
- LP\_ANA\_BOD\_MODE0\_PD\_RF\_ENA Configures whether to enable the brownout detector to close the RF module.
- 0: Disable
- 1: Enable

(R/W)

- LP\_ANA\_BOD\_MODE0\_INTR\_WAIT Configures the time to generate an interrupt after the brownout signal is valid. The unit is LP\_FAST\_CLK. (R/W)
- LP\_ANA\_BOD\_MODE0\_RESET\_WAIT Configures the time to generate a reset after the brownout signal is valid. The unit is LP\_FAST\_CLK. (R/W)
- LP\_ANA\_BOD\_MODE0\_CNT\_CLR Configures whether to clear the count value of the brownout detector.
- 0: Do not clear
- 1: Clear
- (R/W)
- LP\_ANA\_BOD\_MODE0\_INTR\_ENA Enables the interrupts for the brownout detector mode 0. LP\_ANA\_BOD\_MODE0\_INT\_RAW and LP\_ANA\_BOD\_MODE0\_LP\_INT\_RAW are valid only when this field is set to 1. (R/W)
- LP\_ANA\_BOD\_MODE0\_RESET\_SEL Configures the reset type when the brownout detector is triggered.
- 0: Chip reset
- 1: System reset

(R/W)

- LP\_ANA\_BOD\_MODE0\_RESET\_ENA Configures whether to enable reset for the brownout detector.
- 0: Disable
- 1: Enable
- (R/W)

Register 12.81. LP\_ANA\_BOD\_MODE1\_CNTL\_REG (0x0004)

![Image](images/12_Chapter_12_img085_df8f287d.png)

LP\_ANA\_BOD\_MODE1\_RESET\_ENA Configures whether to enable brownout detector mode 1.

0: Disable

1: Enable

(R/W)

Register 12.82. LP\_ANA\_FIB\_ENABLE\_REG (0x000C)

![Image](images/12_Chapter_12_img086_722217b3.png)

LP\_ANA\_ANA\_FIB\_ENA FIB (Focused Ion Beam) selection register. (R/W)

![Image](images/12_Chapter_12_img087_85c4ae4d.png)

![Image](images/12_Chapter_12_img088_7b0815ce.png)

![Image](images/12_Chapter_12_img089_0b573dfd.png)

Register 12.90. LP\_ANA\_LP\_INT\_CLR\_REG (0x002C)

![Image](images/12_Chapter_12_img090_9519f7cd.png)

LP\_ANA\_BOD\_MODE0\_LP\_INT\_CLR Write 1 to clear LP\_ANA\_BOD\_MODE0\_LP\_INT. (WT)

## Register 12.91. LP\_ANA\_DATE\_REG (0x03FC)

![Image](images/12_Chapter_12_img091_6787d9f7.png)

LP\_ANA\_LP\_ANA\_DATE Version control register. (R/W)

- LP\_ANA\_CLK\_EN Configures whether to force enable register clock.
- 0: Automatic clock gating
- 1: Force enable register clock

The configuration of this field does not effect the access of registers. (R/W)
