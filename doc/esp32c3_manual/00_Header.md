## ESP32-C3

## Technical Reference Manual Version 1.3

![Image](images/00_Header_img001_9a5d5692.png)

## About This Document

The ESP32-C3 Technical Reference Manual is targeted at developers working on low level software projects that use the ESP32-C3 SoC. It describes the hardware modules listed below for the ESP32-C3 SoC and other products in ESP32-C3 series. The modules detailed in this document provide an overview, list of features, hardware architecture details, any necessary programming procedures, as well as register descriptions.

## Navigation in This Document

Here are some tips on navigation through this extensive document:

- Release Status at a Glance on the very next page is a minimal list of all chapters from where you can directly jump to a specific chapter.
- Use the Bookmarks on the side bar to jump to any specific chapters or sections from anywhere in the document. Note this PDF document is configured to automatically display Bookmarks when open, which is necessary for an extensive document like this one. However, some PDF viewers or browsers ignore this setting, so if you don't see the Bookmarks by default, try one or more of the following methods:
- – Install a PDF Reader Extension for your browser;
- – Download this document, and view it with your local PDF viewer;
- – Set your PDF viewer to always automatically display the Bookmarks on the left side bar when open.
- Use the native Navigation function of your PDF viewer to navigate through the documents. Most PDF viewers support to go Up , Down , Previous , Next , Back , Forward and Page with buttons, menu, or hot keys.
- You can also use the built-in GoBack button on the upper right corner on each and every page to go back to the previous place before you click a link within the document. Note this feature may only work with some Acrobat-specific PDF viewers (for example, Acrobat Reader and Adobe DC) and browsers with built-in Acrobat-specific PDF viewers or extensions (for example, Firefox).

## Release Status at a Glance

| No.                                     | Chapter                                             | Progress                                |
|-----------------------------------------|-----------------------------------------------------|-----------------------------------------|
| Part I. Microprocessor and Master       | Part I. Microprocessor and Master                   | Part I. Microprocessor and Master       |
| 1                                       | ESP-RISC-V CPU                                      | Published                               |
| 2                                       | GDMA Controller (GDMA)                              | Published                               |
| Part II. Memory Organization            | Part II. Memory Organization                        | Part II. Memory Organization            |
| 3                                       | System and Memory                                   | Published                               |
| 4                                       | eFuse Controller (EFUSE)                            | Published                               |
| Part III. System Component              | Part III. System Component                          | Part III. System Component              |
| 5                                       | IO MUX and GPIO Matrix (GPIO, IO MUX)               | Published                               |
| 6                                       | Reset and Clock                                     | Published                               |
| 7                                       | Chip Boot Control                                   | Published                               |
| 8                                       | Interrupt Matrix (INTERRUPT)                        | Published                               |
| 9                                       | Low-power Management                                | Published                               |
| 10                                      | System Timer (SYSTIMER)                             | Published                               |
| 11                                      | Timer Group (TIMG)                                  | Published                               |
| 12                                      | Watchdog Timers (WDT)                               | Published                               |
| 13                                      | XTAL32K Watchdog Timers (XTWDT)                     | Published                               |
| 14                                      | Permission Control (PMS)                            | Published                               |
| 15                                      | World Controller (WCL)                              | Published                               |
| 16                                      | System Registers (SYSREG)                           | Published                               |
| 17                                      | Debug Assistant (ASSIST_DEBUG)                      | Published                               |
| Part V. Cryptography/Security Component | Part V. Cryptography/Security Component             | Part V. Cryptography/Security Component |
| 18                                      | SHA Accelerator (SHA)                               | Published                               |
| 19                                      | AES Accelerator (AES)                               | Published                               |
| 20                                      | RSA Accelerator (RSA)                               | Published                               |
| 21                                      | HMAC Accelerator (HMAC)                             | Published                               |
| 22                                      | Digital Signature (DS)                              | Published                               |
| 23                                      | External Memory Encryption and Decryption (XTS_AES) | Published                               |
| 24                                      | Clock Glitch Detection                              | Published                               |
| 25                                      | Random Number Generator (RNG)                       | Published                               |
| Part VII. Connectivity Interface        | Part VII. Connectivity Interface                    | Part VII. Connectivity Interface        |
| 26                                      | UART Controller (UART)                              | Published                               |
| 27                                      | SPI Controller (SPI)                                | Published                               |
| 28                                      | I2C Controller (I2C)                                | Published                               |
| 29                                      | I2S Controller (I2S)                                | Published                               |
| 30                                      | USB Serial/JTAG Controller (USB_SERIAL_JTAG)        | Published                               |
| 31                                      | Two-wire Automotive Interface (TWAI)                | Published                               |
| 32                                      | LED PWM Controller (LEDC)                           | Published                               |
| 33                                      | Remote Control Peripheral (RMT)                     | Published                               |
| Part VIII. Analog Signal Processing     | Part VIII. Analog Signal Processing                 | Part VIII. Analog Signal Processing     |
| 34                                      | On-Chip Sensor and Analog Signal Processing         | Published                               |

## Note:

Check the link or the QR code to make sure that you use the latest version of this document: https://www.espressif.com/sites/default/files/documentation/esp32-c3\_technical\_reference\_ manual\_en.pdf

![Image](images/00_Header_img002_e673c51b.png)

![Image](images/00_Header_img003_b362ff4d.png)

ESP32-C3 TRM (Version 1.3)

## Contents

| I Microprocessor and Master                   | I Microprocessor and Master                   |   30 |
|-----------------------------------------------|-----------------------------------------------|------|
| 1 ESP-RISC-V CPU                              | 1 ESP-RISC-V CPU                              |   31 |
| 1.1 Overview                                  | 1.1 Overview                                  |   31 |
| 1.2 Features                                  | 1.2 Features                                  |   31 |
| 1.3 Address Map                               | 1.3 Address Map                               |   32 |
| 1.4 Configuration and Status Registers (CSRs) | 1.4 Configuration and Status Registers (CSRs) |   32 |
|                                               | 1.4.1 Register Summary                        |   32 |
| 1.4.2 Register Description                    | 1.4.2 Register Description                    |   34 |
| 1.5 Interrupt Controller                      | 1.5 Interrupt Controller                      |   42 |
|                                               | 1.5.1 Features                                |   42 |
|                                               | 1.5.2 Functional Description                  |   42 |
|                                               | 1.5.3 Suggested Operation                     |   44 |
|                                               | 1.5.3.1 Latency Aspects                       |   44 |
|                                               | 1.5.3.2 Configuration Procedure               |   45 |
|                                               | 1.5.4 Register Summary                        |   46 |
|                                               | 1.5.5 Register Description                    |   46 |
| 1.6 Debug                                     |                                               |   47 |
|                                               | 1.6.2 Features                                |   48 |
|                                               | 1.6.3 Functional Description                  |   48 |
|                                               | 1.6.4 Register Summary                        |   48 |
|                                               | 1.6.5 Register Description                    |   48 |
| 1.7 Hardware Trigger                          | 1.7 Hardware Trigger                          |   51 |
|                                               | 1.7.1 Features                                |   51 |
|                                               | 1.7.2 Functional Description                  |   51 |
|                                               | 1.7.3 Trigger Execution Flow                  |   52 |
|                                               | 1.7.4 Register Summary                        |   52 |
|                                               | 1.7.5 Register Description                    |   53 |
|                                               | 1.8 Memory Protection                         |   57 |
|                                               | 1.8.1 Overview                                |   57 |
|                                               | 1.8.2 Features                                |   57 |
|                                               | 1.8.3 Functional Description                  |   57 |
|                                               | 1.8.4 Register Summary                        |   59 |
|                                               | 1.8.5 Register Description                    |   59 |
| 2 GDMA Controller (GDMA)                      | 2 GDMA Controller (GDMA)                      |   60 |
| 2.1 Overview                                  | 2.1 Overview                                  |   60 |
| 2.2 Features                                  | 2.2 Features                                  |   60 |
| 2.3 Architecture                              |                                               |   61 |
| 2.4 Functional Description                    | 2.4 Functional Description                    |   61 |
| 2.4.1 Linked List                             | 2.4.1 Linked List                             |   62 |

| 2.4.2 Peripheral-to-Memory and Memory-to-Peripheral Data Transfer   | 2.4.2 Peripheral-to-Memory and Memory-to-Peripheral Data Transfer   |   63 |
|---------------------------------------------------------------------|---------------------------------------------------------------------|------|
| 2.4.3 Memory-to-Memory Data Transfer                                | 2.4.3 Memory-to-Memory Data Transfer                                |   63 |
| 2.4.4 Enabling GDMA                                                 | 2.4.4 Enabling GDMA                                                 |   64 |
| 2.4.5 Linked List Reading Process                                   | 2.4.5 Linked List Reading Process                                   |   64 |
| 2.4.6 EOF                                                           | 2.4.6 EOF                                                           |   65 |
| 2.4.7 Accessing Internal RAM                                        | 2.4.7 Accessing Internal RAM                                        |   65 |
| 2.4.8 Arbitration                                                   | 2.4.8 Arbitration                                                   |   66 |
| 2.5 GDMA Interrupts                                                 | 2.5 GDMA Interrupts                                                 |   66 |
| 2.6 Programming Procedures                                          | 2.6 Programming Procedures                                          |   67 |
| 2.6.1 Programming Procedure for GDMA Clock and Reset                | 2.6.1 Programming Procedure for GDMA Clock and Reset                |   67 |
|                                                                     | 2.6.2 Programming Procedures for GDMA’s Transmit Channel            |   67 |
| 2.6.3 Programming Procedures for GDMA’s Receive Channel             | 2.6.3 Programming Procedures for GDMA’s Receive Channel             |   67 |
| 2.6.4 Programming Procedures for Memory-to-Memory Transfer          | 2.6.4 Programming Procedures for Memory-to-Memory Transfer          |   68 |
| 2.7 Register Summary                                                | 2.7 Register Summary                                                |   69 |
| 2.8 Registers                                                       | 2.8 Registers                                                       |   73 |
| II Memory Organization                                              | II Memory Organization                                              |   90 |
|                                                                     |                                                                     |   91 |
| 3 System and Memory  3.1 Overview                                   | 3 System and Memory  3.1 Overview                                   |   91 |
| 3.2 Features                                                        | 3.2 Features                                                        |   91 |
| 3.3 Functional Description                                          | 3.3 Functional Description                                          |   92 |
| 3.3.1 Address Mapping                                               | 3.3.1 Address Mapping                                               |   92 |
|                                                                     | 3.3.2 Internal Memory                                               |   93 |
|                                                                     | 3.3.3 External Memory                                               |   94 |
|                                                                     | 3.3.3.1 External Memory Address Mapping                             |   95 |
|                                                                     | 3.3.3.2 Cache                                                       |   95 |
|                                                                     | 3.3.3.3 Cache Operations                                            |   96 |
|                                                                     | 3.3.4 GDMA Address Space                                            |   96 |
|                                                                     | 3.3.5 Modules/Peripherals                                           |   97 |
|                                                                     | 3.3.5.1 Module/Peripheral Address Mapping                           |   98 |
| 4 eFuse Controller (EFUSE)                                          | 4 eFuse Controller (EFUSE)                                          |  100 |
| 4.1 Overview                                                        | 4.1 Overview                                                        |  100 |
| 4.2 Features                                                        | 4.2 Features                                                        |  100 |
| 4.3 Functional Description                                          | 4.3 Functional Description                                          |  100 |
| 4.3.1 Structure                                                     |                                                                     |  100 |
|                                                                     | 4.3.1.1 EFUSE_WR_DIS                                                |  106 |
|                                                                     | 4.3.1.2 EFUSE_RD_DIS                                                |  106 |
|                                                                     | 4.3.1.3 Data Storage                                                |  106 |
| 4.3.2 Programming of Parameters                                     | 4.3.2 Programming of Parameters                                     |  107 |
| 4.3.3 User Read of Parameters                                       | 4.3.3 User Read of Parameters                                       |  109 |
| 4.3.4 eFuse VDDQ Timing                                             | 4.3.4 eFuse VDDQ Timing                                             |  111 |
| 4.3.5 The Use of Parameters by Hardware Modules                     | 4.3.5 The Use of Parameters by Hardware Modules                     |  111 |
| 4.4 Register Summary                                                | 4.4 Register Summary                                                |  112 |

| 4.5 Registers                                   | 4.5 Registers                                   | 116     |
|-------------------------------------------------|-------------------------------------------------|---------|
| III System Component                            | III System Component                            | 158     |
| 5 IO MUX and GPIO Matrix (GPIO, IO MUX)         | 5 IO MUX and GPIO Matrix (GPIO, IO MUX)         | 159     |
| 5.1 Overview                                    | 5.1 Overview                                    | 159     |
| 5.2 Features                                    | 5.2 Features                                    | 159     |
| 5.3 Architectural Overview                      | 5.3 Architectural Overview                      | 159     |
| 5.4 Peripheral Input via GPIO Matrix            | 5.4 Peripheral Input via GPIO Matrix            | 161     |
|                                                 | 5.4.1 Overview                                  | 161     |
|                                                 | 5.4.2 Signal Synchronization                    | 162     |
|                                                 | 5.4.3 Functional Description                    | 162     |
|                                                 | 5.4.4 Simple GPIO Input                         | 163     |
| 5.5 Peripheral Output via GPIO Matrix           | 5.5 Peripheral Output via GPIO Matrix           | 163     |
|                                                 | 5.5.1 Overview                                  | 163     |
|                                                 | 5.5.2 Functional Description                    | 164     |
|                                                 | 5.5.3 Simple GPIO Output                        | 165     |
|                                                 | 5.5.4 Sigma Delta Modulated Output (SDM)        | 165     |
|                                                 | 5.5.4.1 Functional Description                  | 165     |
|                                                 | 5.5.4.2 SDM Configuration                       | 166     |
| 5.6 Direct Input and Output via IO MUX          | 5.6 Direct Input and Output via IO MUX          | 166     |
|                                                 | 5.6.1 Overview                                  | 166     |
|                                                 | 5.6.2 Functional Description                    | 166     |
| 5.7 Analog Functions of GPIO Pins               | 5.7 Analog Functions of GPIO Pins               | 166     |
| 5.8 Pin Functions in Light-sleep                | 5.8 Pin Functions in Light-sleep                | 167     |
| 5.9 Pin Hold Feature                            | 5.9 Pin Hold Feature                            | 167     |
| 5.10 Power Supplies and Management of GPIO Pins | 5.10 Power Supplies and Management of GPIO Pins | 167     |
|                                                 | 5.10.1 Power Supplies of GPIO Pins              | 167     |
|                                                 | 5.10.2 Power Supply Management                  | 168     |
| 5.11 Peripheral Signal List                     | 5.11 Peripheral Signal List                     | 168     |
| 5.12 IO MUX Functions List                      | 5.12 IO MUX Functions List                      | 174     |
| 5.13 Analog Functions List                      | 5.13 Analog Functions List                      | 175     |
| 5.14 Register Summary                           | 5.14 Register Summary                           | 176     |
|                                                 | 5.14.1 GPIO Matrix Register Summary             | 176     |
|                                                 | 5.14.2 IO MUX Register Summary                  | 178     |
|                                                 | 5.14.3 SDM Register Summary                     | 178     |
| 5.15 Registers                                  | 5.15 Registers                                  | 179     |
|                                                 | 5.15.1 GPIO Matrix Registers                    | 179     |
|                                                 | 5.15.2 IO MUX Registers                         | 186     |
|                                                 | 5.15.3 SDM Output Registers                     | 188     |
| 6 Reset and Clock                               | 6 Reset and Clock                               | 191     |
| 6.1 Reset                                       | 6.1 Reset                                       | 191     |
|                                                 | 6.1.1 Overview                                  | 191     |
|                                                 | 6.1.2 Architectural Overview  6.1.3 Features    | 191 191 |

|                                                                     | 6.1.4 Functional Description                                              |   192 |
|---------------------------------------------------------------------|---------------------------------------------------------------------------|-------|
| 6.2 Clock                                                           |                                                                           |   193 |
|                                                                     | 6.2.1 Overview                                                            |   193 |
|                                                                     | 6.2.2 Architectural Overview                                              |   194 |
| 6.2.3 Features                                                      |                                                                           |   194 |
|                                                                     | 6.2.4 Functional Description                                              |   194 |
|                                                                     | 6.2.4.1 CPU Clock                                                         |   195 |
|                                                                     | 6.2.4.2 Peripheral Clock                                                  |   195 |
|                                                                     | 6.2.4.3 Wi-Fi and Bluetooth LE Clock                                      |   197 |
|                                                                     | 6.2.4.4 RTC Clock                                                         |   197 |
| 7 Chip Boot Control                                                 | 7 Chip Boot Control                                                       |   198 |
| 7.1 Overview                                                        | 7.1 Overview                                                              |   198 |
| 7.2 Boot Mode Control                                               | 7.2 Boot Mode Control                                                     |   199 |
| 7.3 ROM Messages Printing Control                                   | 7.3 ROM Messages Printing Control                                         |   200 |
| 8 Interrupt Matrix (INTERRUPT)                                      | 8 Interrupt Matrix (INTERRUPT)                                            |   202 |
| 8.1 Overview                                                        | 8.1 Overview                                                              |   202 |
| 8.2 Features                                                        | 8.2 Features                                                              |   202 |
| 8.3 Functional Description                                          | 8.3 Functional Description                                                |   203 |
|                                                                     | 8.3.1 Peripheral Interrupt Sources                                        |   203 |
|                                                                     | 8.3.2 CPU Interrupts                                                      |   207 |
|                                                                     | 8.3.3 Allocate Peripheral Interrupt Source to CPU Interrupt               |   207 |
|                                                                     | 8.3.3.1 Allocate one peripheral interrupt source (Source_X) to CPU        |   207 |
|                                                                     | 8.3.3.2 Allocate multiple peripheral interrupt sources (Source_Xn) to CPU |   207 |
|                                                                     | 8.3.3.3 Disable CPU peripheral interrupt source (Source_X)                |   207 |
| 8.3.4 Query Current Interrupt Status of Peripheral Interrupt Source | 8.3.4 Query Current Interrupt Status of Peripheral Interrupt Source       |   207 |
| 8.4 Register Summary                                                | 8.4 Register Summary                                                      |   209 |
| 8.5 Registers                                                       | 8.5 Registers                                                             |   213 |
| 9 Low-power Management                                              | 9 Low-power Management                                                    |   219 |
| 9.1 Introduction                                                    | 9.1 Introduction                                                          |   219 |
| 9.2 Features                                                        | 9.2 Features                                                              |   219 |
| 9.3 Functional Description                                          | 9.3 Functional Description                                                |   219 |
|                                                                     | 9.3.1 Power Management Unit (PMU)                                         |   221 |
|                                                                     | 9.3.2 Low-Power Clocks                                                    |   222 |
|                                                                     | 9.3.3 Timers                                                              |   223 |
|                                                                     | 9.3.4 Voltage Regulators                                                  |   224 |
|                                                                     | 9.3.4.1 Digital System Voltage Regulator                                  |   224 |
|                                                                     | 9.3.4.2 Low-power Voltage Regulator                                       |   225 |
|                                                                     | 9.3.4.3 Brownout Detector                                                 |   225 |
| 9.4 Power Modes Management                                          | 9.4 Power Modes Management                                                |   226 |
|                                                                     | 9.4.1 Power Domain                                                        |   226 |
|                                                                     | 9.4.2 Pre-defined Power Modes                                             |   227 |
|                                                                     | 9.4.3 Wakeup Source                                                       |   227 |
| 9.4.4 Reject Sleep                                                  | 9.4.4 Reject Sleep                                                        |   228 |

| 9.5 Retention DMA             | 9.5 Retention DMA                               | 228   |
|-------------------------------|-------------------------------------------------|-------|
| 9.6 RTC Boot                  | 9.6 RTC Boot                                    | 229   |
| 9.7 Register Summary          | 9.7 Register Summary                            | 231   |
| 9.8 Registers                 | 9.8 Registers                                   | 233   |
| 10 System Timer (SYSTIMER)    | 10 System Timer (SYSTIMER)                      | 270   |
| 10.1 Overview                 | 10.1 Overview                                   | 270   |
| 10.2 Features                 | 10.2 Features                                   | 270   |
| 10.3 Clock Source Selection   | 10.3 Clock Source Selection                     | 271   |
| 10.4 Functional Description   | 10.4 Functional Description                     | 271   |
|                               | 10.4.1 Counter                                  | 271   |
|                               | 10.4.2 Comparator and Alarm                     | 272   |
|                               | 10.4.3 Synchronization Operation                | 273   |
|                               | 10.4.4 Interrupt                                | 274   |
| 10.5 Programming Procedure    | 10.5 Programming Procedure                      | 274   |
|                               | 10.5.1 Read Current Count Value                 | 274   |
|                               | 10.5.2 Configure One-Time Alarm in Target Mode  | 274   |
|                               | 10.5.3 Configure Periodic Alarms in Period Mode | 274   |
|                               | 10.5.4 Update After Light-sleep                 | 275   |
| 10.6 Register Summary         | 10.6 Register Summary                           | 275   |
| 10.7 Registers                | 10.7 Registers                                  | 277   |
| 11 Timer Group (TIMG)         | 11 Timer Group (TIMG)                           | 288   |
| 11.1 Overview                 | 11.1 Overview                                   | 288   |
| 11.2 Functional Description   | 11.2 Functional Description                     | 289   |
|                               | 11.2.1 16-bit Prescaler and Clock Selection     | 289   |
|                               | 11.2.2 54-bit Time-base Counter                 | 289   |
|                               | 11.2.3 Alarm Generation                         | 290   |
|                               | 11.2.4 Timer Reload                             | 291   |
|                               | 11.2.5 RTC_SLOW_CLK Frequency Calculation       | 291   |
|                               | 11.2.6 Interrupts                               | 291   |
| 11.3 Configuration and Usage  | 11.3 Configuration and Usage                    | 292   |
|                               | 11.3.1 Timer as a Simple Clock                  | 292   |
|                               | 11.3.2 Timer as One-shot Alarm                  | 292   |
|                               | 11.3.3 Timer as Periodic Alarm                  | 293   |
| 11.4 Register Summary         | 11.4 Register Summary                           | 294   |
|                               |                                                 | 295   |
| 11.5 Registers                | 11.5 Registers                                  |       |
| 12 Watchdog Timers (WDT)      | 12 Watchdog Timers (WDT)                        | 305   |
| 12.1 Overview                 | 12.1 Overview                                   | 305   |
| 12.2 Digital Watchdog Timers  | 12.2 Digital Watchdog Timers                    | 306   |
| 12.2.1 Features               | 12.2.1 Features                                 | 306   |
| 12.2.2 Functional Description | 12.2.2 Functional Description                   | 307   |
|                               | 12.2.2.2 Stages and Timeout Actions             | 308   |

|                                                          |                                                                       | 12.2.2.3 Write Protection                                             |   308 |
|----------------------------------------------------------|-----------------------------------------------------------------------|-----------------------------------------------------------------------|-------|
|                                                          |                                                                       | 12.2.2.4 Flash Boot Protection                                        |   309 |
| 12.3 Super Watchdog                                      | 12.3 Super Watchdog                                                   | 12.3 Super Watchdog                                                   |   309 |
|                                                          | 12.3.1 Features                                                       | 12.3.1 Features                                                       |   309 |
|                                                          | 12.3.2 Super Watchdog Controller                                      | 12.3.2 Super Watchdog Controller                                      |   309 |
|                                                          |                                                                       | 12.3.2.1 Structure                                                    |   310 |
|                                                          |                                                                       | 12.3.2.2 Workflow                                                     |   310 |
| 12.4 Interrupts                                          | 12.4 Interrupts                                                       | 12.4 Interrupts                                                       |   310 |
| 12.5 Registers                                           | 12.5 Registers                                                        | 12.5 Registers                                                        |   311 |
| 13 XTAL32K Watchdog Timers (XTWDT)                       | 13 XTAL32K Watchdog Timers (XTWDT)                                    | 13 XTAL32K Watchdog Timers (XTWDT)                                    |   312 |
| 13.1 Overview                                            | 13.1 Overview                                                         | 13.1 Overview                                                         |   312 |
| 13.2 Features                                            | 13.2 Features                                                         | 13.2 Features                                                         |   312 |
|                                                          | 13.2.1 Interrupt and Wake-Up                                          | 13.2.1 Interrupt and Wake-Up                                          |   312 |
|                                                          | 13.2.2 BACKUP32K_CLK                                                  | 13.2.2 BACKUP32K_CLK                                                  |   313 |
| 13.3 Functional Description                              | 13.3 Functional Description                                           | 13.3 Functional Description                                           |   313 |
|                                                          | 13.3.1 Workflow                                                       | 13.3.1 Workflow                                                       |   313 |
|                                                          | 13.3.2 BACKUP32K_CLK Working Principle                                | 13.3.2 BACKUP32K_CLK Working Principle                                |   313 |
|                                                          | 13.3.3 Configuring the Divisor Component of BACKUP32K_CLK             | 13.3.3 Configuring the Divisor Component of BACKUP32K_CLK             |   313 |
| 14 Permission Control (PMS)                              | 14 Permission Control (PMS)                                           | 14 Permission Control (PMS)                                           |   315 |
| 14.1 Overview                                            | 14.1 Overview                                                         | 14.1 Overview                                                         |   315 |
| 14.2 Features                                            | 14.2 Features                                                         | 14.2 Features                                                         |   316 |
| 14.3 Privileged Environment and Unprivileged Environment | 14.3 Privileged Environment and Unprivileged Environment              | 14.3 Privileged Environment and Unprivileged Environment              |   316 |
| 14.4 Internal Memory                                     | 14.4 Internal Memory                                                  | 14.4 Internal Memory                                                  |   317 |
|                                                          | 14.4.1 ROM                                                            | 14.4.1 ROM                                                            |   317 |
|                                                          | 14.4.2 SRAM                                                           | 14.4.2 SRAM                                                           |   318 |
|                                                          |                                                                       | 14.4.2.1 Internal SRAM0 Access Configuration                          |   318 |
|                                                          |                                                                       | 14.4.2.2 Internal SRAM1 Access Configuration                          |   319 |
|                                                          |                                                                       | 14.4.3 RTC FAST Memory                                                |   322 |
| 14.5 Peripherals                                         | 14.5 Peripherals                                                      | 14.5 Peripherals                                                      |   323 |
|                                                          | 14.5.1 Access Configuration                                           | 14.5.1 Access Configuration                                           |   323 |
|                                                          | 14.5.2 Split Peripheral Regions into Split Regions                    | 14.5.2 Split Peripheral Regions into Split Regions                    |   324 |
| 14.6 External Memory                                     | 14.6 External Memory                                                  | 14.6 External Memory                                                  |   325 |
| 14.6.1 SPI and Cache’s Access to External Flash          | 14.6.1 SPI and Cache’s Access to External Flash                       | 14.6.1 SPI and Cache’s Access to External Flash                       |   325 |
|                                                          |                                                                       | 14.6.1.1 Address                                                      |   326 |
|                                                          |                                                                       | 14.6.1.2 Access Configuration                                         |   326 |
|                                                          | 14.6.2 CPU’s Access to Cache                                          | 14.6.2 CPU’s Access to Cache                                          |   327 |
|                                                          | 14.6.2.1 Split Regions                                                | 14.6.2.1 Split Regions                                                |   327 |
| 14.6.3 Access Configuration                              | 14.6.3 Access Configuration                                           | 14.6.3 Access Configuration                                           |   327 |
| 14.7 Unauthorized Access and Interrupts                  | 14.7 Unauthorized Access and Interrupts                               | 14.7 Unauthorized Access and Interrupts                               |   328 |
|                                                          | 14.7.2 Interrupt upon Unauthorized DBUS Access                        | 14.7.2 Interrupt upon Unauthorized DBUS Access                        |   329 |
|                                                          | 14.7.3 Interrupt upon Unauthorized Access to External Memory          | 14.7.3 Interrupt upon Unauthorized Access to External Memory          |   330 |
|                                                          | 14.7.4 Interrupt upon Unauthorized Access to Internal Memory via GDMA | 14.7.4 Interrupt upon Unauthorized Access to Internal Memory via GDMA |   330 |
|                                                          | 14.7.5 Interrupt upon Unauthorized peripheral bus (PIF) Access        | 14.7.5 Interrupt upon Unauthorized peripheral bus (PIF) Access        |   330 |

| 14.7.6 Interrupt upon Unauthorized PIF Access Alignment          |   331 |
|------------------------------------------------------------------|-------|
| 14.8 Register Locks                                              |   332 |
| 14.9 Register Summary                                            |   335 |
| 14.10 Registers                                                  |   338 |
| 15 World Controller (WCL)                                        |   413 |
| 15.1 Introduction                                                |   413 |
| 15.2 Features                                                    |   413 |
| 15.3 Functional Description                                      |   413 |
| 15.4 CPU’s World Switch                                          |   415 |
| 15.4.1 From Secure World to Non-secure World                     |   415 |
| 15.4.2 From Non-secure World to Secure World                     |   416 |
| 15.5 World Switch Log                                            |   417 |
| 15.5.1 Structure of World Switch Log Register                    |   417 |
| 15.5.2 How World Switch Log Registers are Updated                |   418 |
| 15.5.3 How to Read World Switch Log Registers                    |   420 |
| 15.5.4 Nested Interrupts                                         |   420 |
| 15.5.4.1 Programming Procedure                                   |   420 |
| 15.6 Register Summary                                            |   422 |
| 15.7 Registers                                                   |   423 |
| 16 System Registers (SYSREG)                                     |   427 |
| 16.1 Overview                                                    |   427 |
| 16.2 Features                                                    |   427 |
| 16.3 Function Description                                        |   427 |
| 16.3.1 System and Memory Registers                               |   427 |
| 16.3.1.1 Internal Memory                                         |   427 |
| 16.3.1.2 External Memory                                         |   428 |
| 16.3.1.3 RSA Memory                                              |   428 |
| 16.3.2 Clock Registers                                           |   429 |
| 16.3.3 Interrupt Signal Registers                                |   429 |
| 16.3.4 Low-power Management Registers                            |   429 |
| 16.3.5 Peripheral Clock Gating and Reset Registers               |   429 |
| 16.5 Registers                                                   |   434 |
| 17 Debug Assistant (ASSIST_DEBUG)                                |   446 |
| 17.1 Overview                                                    |   446 |
| 17.3 Functional Description                                      |   446 |
| 17.3.1 Region Read/Write Monitoring                              |   446 |
| 17.3.2 SP Monitoring                                             |   446 |
| 17.3.3 PC Logging                                                |   447 |
| 17.4 Recommended Operation                                       |   447 |
| 17.4.1 Region Monitoring and SP Monitoring Configuration Process |   447 |

|                                            | Contents                                                | GoBack   |
|--------------------------------------------|---------------------------------------------------------|----------|
|                                            | 17.4.2 PC Logging Configuration Process                 | 448      |
|                                            | 17.4.3 CPU/DMA Bus Access Logging Configuration Process | 449      |
|                                            | 17.5 Register Summary                                   | 453      |
| 17.6 Registers                             | 17.6 Registers                                          | 455      |
| IV Cryptography/Security Component         | IV Cryptography/Security Component                      | 472      |
| 18 AES Accelerator (AES)                   | 18 AES Accelerator (AES)                                | 473      |
| 18.1 Introduction                          | 18.1 Introduction                                       | 473      |
| 18.2 Features                              | 18.2 Features                                           | 473      |
| 18.3 AES Working Modes                     | 18.3 AES Working Modes                                  | 473      |
| 18.4 Typical AES Working Mode              | 18.4 Typical AES Working Mode                           | 475      |
|                                            | 18.4.1 Key, Plaintext, and Ciphertext                   | 475      |
|                                            | 18.4.2 Endianness                                       | 475      |
|                                            | 18.4.3 Operation Process                                | 477      |
| 18.5 DMA-AES Working Mode                  | 18.5 DMA-AES Working Mode                               | 477      |
|                                            | 18.5.1 Key, Plaintext, and Ciphertext                   | 478      |
|                                            | 18.5.2 Endianness                                       | 479      |
|                                            | 18.5.3 Standard Incrementing Function                   | 479      |
|                                            | 18.5.4 Block Number                                     | 479      |
|                                            | 18.5.5 Initialization Vector                            | 479      |
|                                            | 18.5.6 Block Operation Process                          | 480      |
| 18.6 Memory Summary                        | 18.6 Memory Summary                                     | 480      |
| 18.7 Register Summary                      | 18.7 Register Summary                                   | 481      |
| 18.8 Registers                             | 18.8 Registers                                          | 482      |
| 19 HMAC Accelerator (HMAC)                 | 19 HMAC Accelerator (HMAC)                              | 486      |
| 19.1 Main Features                         | 19.1 Main Features                                      | 486      |
| 19.2 Functional Description                | 19.2 Functional Description                             | 486      |
| 19.2.1 Upstream Mode                       | 19.2.1 Upstream Mode                                    | 486      |
|                                            | 19.2.2 Downstream JTAG Enable Mode                      | 487      |
|                                            | 19.2.3 Downstream Digital Signature Mode                | 487      |
|                                            | 19.2.4 HMAC eFuse Configuration                         | 488      |
|                                            | 19.2.5 HMAC Process (Detailed)                          | 489      |
| 19.3 HMAC Algorithm Details                | 19.3 HMAC Algorithm Details                             | 490      |
|                                            | 19.3.1 Padding Bits                                     | 491      |
| 19.3.2 HMAC Algorithm Structure            | 19.3.2 HMAC Algorithm Structure                         | 491      |
| 19.4 Register Summary                      | 19.4 Register Summary                                   | 494      |
| 19.5 Registers                             | 19.5 Registers                                          | 496      |
| 20 RSA Accelerator (RSA)                   | 20 RSA Accelerator (RSA)                                | 502      |
|                                            | 20.1 Introduction                                       | 502      |
| 20.2 Features                              | 20.2 Features                                           | 502      |
| 20.3 Functional Description                | 20.3 Functional Description                             |          |
| 20.3.1 Large Number Modular Exponentiation | 20.3.1 Large Number Modular Exponentiation              | 503      |
| 20.3.2 Large Number Modular Multiplication | 20.3.2 Large Number Modular Multiplication              | 504      |

| Contents                                                   |                                                            | GoBack   |
|------------------------------------------------------------|------------------------------------------------------------|----------|
|                                                            | 20.3.3 Large Number Multiplication                         | 505      |
|                                                            | 20.3.4 Options for Acceleration                            | 505      |
| 20.4 Memory Summary                                        |                                                            | 507      |
| 20.5 Register Summary                                      |                                                            | 508      |
| 20.6 Registers                                             |                                                            | 509      |
| 21 SHA Accelerator (SHA)                                   |                                                            | 513      |
| 21.1 Introduction                                          |                                                            | 513      |
| 21.2 Features                                              |                                                            | 513      |
| 21.3 Working Modes                                         | 21.3 Working Modes                                         | 513      |
| 21.4 Function Description                                  | 21.4 Function Description                                  | 514      |
|                                                            | 21.4.1 Preprocessing                                       | 514      |
|                                                            | 21.4.1.1 Padding the Message                               | 514      |
|                                                            | 21.4.1.2 Parsing the Message                               | 514      |
|                                                            | 21.4.1.3 Setting the Initial Hash Value                    | 515      |
|                                                            | 21.4.2 Hash Operation                                      | 515      |
|                                                            | 21.4.2.1 Typical SHA Mode Process                          | 515      |
|                                                            | 21.4.2.2 DMA-SHA Mode Process                              | 517      |
| 21.4.3 Message Digest                                      |                                                            | 517      |
|                                                            | 21.4.4 Interrupt                                           | 518      |
| 21.5 Register Summary                                      | 21.5 Register Summary                                      | 518      |
| 21.6 Registers                                             | 21.6 Registers                                             | 519      |
| 22 Digital Signature (DS)                                  | 22 Digital Signature (DS)                                  | 523      |
| 22.1 Overview                                              | 22.1 Overview                                              | 523      |
| 22.2 Features                                              | 22.2 Features                                              | 523      |
| 22.3 Functional Description                                | 22.3 Functional Description                                | 523      |
|                                                            | 22.3.1 Overview                                            | 523      |
|                                                            | 22.3.2 Private Key Operands                                | 524      |
|                                                            | 22.3.3 Software Prerequisites                              | 524      |
|                                                            | 22.3.4 DS Operation at the Hardware Level                  | 526      |
| 22.3.5 DS Operation at the Software Level                  | 22.3.5 DS Operation at the Software Level                  | 526      |
| 22.4 Memory Summary                                        | 22.4 Memory Summary                                        | 529      |
| 22.5 Register Summary                                      | 22.5 Register Summary                                      | 530      |
| 22.6 Registers                                             | 22.6 Registers                                             | 531      |
| 23 External Memory Encryption and Decryption (XTS_AES) 534 | 23 External Memory Encryption and Decryption (XTS_AES) 534 |          |
| 23.1 Overview                                              | 23.1 Overview                                              | 534      |
| 23.2 Features                                              |                                                            | 534      |
| 23.3 Module Structure                                      | 23.3 Module Structure                                      | 534      |
| 23.4 Functional Description                                | 23.4 Functional Description                                | 535      |
| 23.4.1 XTS Algorithm                                       | 23.4.1 XTS Algorithm                                       | 535      |
| 23.4.2 Key                                                 |                                                            | 536      |
|                                                            | 23.4.3 Target Memory Space                                 | 536      |
|                                                            | 23.4.4 Data Writing                                        | 537      |
|                                                            | 23.4.5 Manual Encryption Block                             | 537      |

| 23.4.6 Auto Decryption Block      | 23.4.6 Auto Decryption Block              | 538   |
|-----------------------------------|-------------------------------------------|-------|
| 23.5 Software Process             | 23.5 Software Process                     | 538   |
| 23.6 Register Summary             | 23.6 Register Summary                     | 540   |
| 23.7 Registers                    | 23.7 Registers                            | 541   |
| 24 Random Number Generator (RNG)  | 24 Random Number Generator (RNG)          | 544   |
| 24.1 Introduction                 | 24.1 Introduction                         | 544   |
|                                   | 24.2 Features                             | 544   |
| 24.3 Functional Description       | 24.3 Functional Description               | 544   |
| 24.4 Programming Procedure        | 24.4 Programming Procedure                | 545   |
| 24.5 Register Summary             | 24.5 Register Summary                     | 545   |
| 24.6 Register                     | 24.6 Register                             | 546   |
| 25 Clock Glitch Detection         | 25 Clock Glitch Detection                 | 547   |
| 25.1 Overview                     | 25.1 Overview                             | 547   |
| 25.2 Functional Description       | 25.2 Functional Description               | 547   |
| 25.2.1 Clock Glitch Detection     | 25.2.1 Clock Glitch Detection             | 547   |
| 25.2.2 Reset                      | 25.2.2 Reset                              | 547   |
| V Connectivity Interface          | V Connectivity Interface                  | 548   |
| 26.1 Overview                     | 26.1 Overview                             | 549   |
| 26.2 Features                     | 26.2 Features                             | 549   |
| 26.3 UART Structure               | 26.3 UART Structure                       | 550   |
| 26.4 Functional Description       | 26.4 Functional Description               | 551   |
| 26.4.1 Clock and Reset            | 26.4.1 Clock and Reset                    | 551   |
|                                   | 26.4.2 UART RAM                           | 552   |
|                                   | 26.4.3 Baud Rate Generation and Detection | 553   |
|                                   | 26.4.3.1 Baud Rate Generation             | 553   |
|                                   | 26.4.3.2 Baud Rate Detection              | 554   |
| 26.4.4 UART Data Frame            | 26.4.4 UART Data Frame                    | 555   |
| 26.4.5 AT_CMD Character Structure | 26.4.5 AT_CMD Character Structure         | 556   |
| 26.4.6 RS485                      | 26.4.6 RS485                              | 556   |
|                                   | 26.4.6.1 Driver Control                   | 556   |
|                                   | 26.4.6.2 Turnaround Delay                 | 557   |
|                                   | 26.4.6.3 Bus Snooping                     | 557   |
| 26.4.7 IrDA                       | 26.4.7 IrDA                               | 557   |
| 26.4.8 Wake-up                    | 26.4.8 Wake-up                            | 558   |
| 26.4.9 Flow Control               | 26.4.9 Flow Control                       | 559   |
|                                   | 26.4.9.1 Hardware Flow Control            | 559   |
| 26.4.9.2 Software Flow Control    | 26.4.9.2 Software Flow Control            | 561   |
| 26.4.10 GDMA Mode                 | 26.4.10 GDMA Mode                         |       |
| 26.4.11 UART Interrupts           | 26.4.11 UART Interrupts                   | 561   |

| 26.5.1 Register Type                                              |   563 |
|-------------------------------------------------------------------|-------|
| 26.5.1.1 Synchronous Registers                                    |   563 |
| 26.5.1.2 Static Registers                                         |   564 |
| 26.5.1.3 Immediate Registers                                      |   565 |
| 26.5.2 Detailed Steps                                             |   565 |
| 26.5.2.1 Initializing UARTn                                       |   566 |
| 26.5.2.2 Configuring UARTn Communication                          |   566 |
| 26.5.2.3 Enabling UARTn                                           |   566 |
| 26.6 Register Summary                                             |   568 |
| 26.7 Registers                                                    |   571 |
| 27 SPI Controller (SPI)                                           |   608 |
| 27.1 Overview                                                     |   608 |
| 27.2 Glossary                                                     |   608 |
| 27.3 Features                                                     |   609 |
| 27.4 Architectural Overview                                       |   610 |
| 27.5 Functional Description                                       |   610 |
| 27.5.1 Data Modes                                                 |   611 |
| 27.5.2 FSPI Bus Signal Mapping                                    |   611 |
| 27.5.3 Bit Read/Write Order Control                               |   614 |
| 27.5.4 Transfer Modes                                             |   614 |
| 27.5.5 CPU-Controlled Data Transfer                               |   614 |
| 27.5.5.1 CPU-Controlled Master Mode                               |   615 |
| 27.5.5.2 CPU-Controlled Slave Mode                                |   616 |
| 27.5.6 DMA-Controlled Data Transfer                               |   616 |
| 27.5.6.1 GDMA Configuration                                       |   617 |
| 27.5.6.2 GDMA TX/RX Buffer Length Control                         |   618 |
| 27.5.7 Data Flow Control in GP-SPI2 Master and Slave Modes        |   618 |
| 27.5.7.1 GP-SPI2 Functional Blocks                                |   618 |
| 27.5.7.2 Data Flow Control in Master Mode                         |   619 |
| 27.5.7.3 Data Flow Control in Slave Mode                          |   620 |
| 27.5.8 GP-SPI2 Works as a Master                                  |   621 |
| 27.5.8.1 State Machine                                            |   621 |
| 27.5.8.2 Register Configuration for State and Bit Mode Control    |   623 |
| 27.5.8.3 Full-Duplex Communication (1-bit Mode Only)              |   626 |
| 27.5.8.4 Half-Duplex Communication (1/2/4-bit Mode)               |   627 |
| 27.5.8.5 DMA-Controlled Configurable Segmented Transfer           |   629 |
| 27.5.9 GP-SPI2 Works as a Slave                                   |   633 |
| 27.5.9.1 Communication Formats                                    |   633 |
| 27.5.9.2 Supported CMD Values in Half-Duplex Communication        |   634 |
| 27.5.9.3 Slave Single Transfer and Slave Segmented Transfer       |   637 |
| 27.5.9.4 Configuration of Slave Single Transfer                   |   637 |
| 27.5.9.5 Configuration of Slave Segmented Transfer in Half-Duplex |   638 |
| 27.5.9.6 Configuration of Slave Segmented Transfer in Full-Duplex |   638 |
| 27.7 GP-SPI2 Clock Control                                        |   640 |

| 27.7.1 Clock Phase and Polarity                                                  |                                                                                  |                                                                                  | 640     |
|----------------------------------------------------------------------------------|----------------------------------------------------------------------------------|----------------------------------------------------------------------------------|---------|
|                                                                                  | 27.7.2 Clock Control in Master Mode                                              | 27.7.2 Clock Control in Master Mode                                              | 642     |
|                                                                                  | 27.7.3 Clock Control in Slave Mode                                               | 27.7.3 Clock Control in Slave Mode                                               | 642     |
| 27.8 GP-SPI2 Timing Compensation                                                 | 27.8 GP-SPI2 Timing Compensation                                                 | 27.8 GP-SPI2 Timing Compensation                                                 | 642     |
| 27.9 Interrupts                                                                  | 27.9 Interrupts                                                                  | 27.9 Interrupts                                                                  | 644     |
| 27.10 Register Summary                                                           | 27.10 Register Summary                                                           | 27.10 Register Summary                                                           | 647     |
| 27.11 Registers                                                                  | 27.11 Registers                                                                  | 27.11 Registers                                                                  | 648     |
| 28 I2C Controller (I2C)                                                          | 28 I2C Controller (I2C)                                                          | 28 I2C Controller (I2C)                                                          | 676     |
| 28.1 Overview                                                                    | 28.1 Overview                                                                    | 28.1 Overview                                                                    | 676     |
| 28.2 Features                                                                    | 28.2 Features                                                                    | 28.2 Features                                                                    | 676     |
| 28.3 I2C Architecture                                                            | 28.3 I2C Architecture                                                            | 28.3 I2C Architecture                                                            | 677     |
| 28.4 Functional Description                                                      | 28.4 Functional Description                                                      | 28.4 Functional Description                                                      | 679     |
|                                                                                  | 28.4.1 Clock Configuration                                                       | 28.4.1 Clock Configuration                                                       | 679     |
|                                                                                  | 28.4.2 SCL and SDA Noise Filtering                                               | 28.4.2 SCL and SDA Noise Filtering                                               | 679     |
|                                                                                  | 28.4.3 SCL Clock Stretching                                                      | 28.4.3 SCL Clock Stretching                                                      | 680     |
|                                                                                  | 28.4.4 Generating SCL Pulses in Idle State                                       | 28.4.4 Generating SCL Pulses in Idle State                                       | 680     |
|                                                                                  | 28.4.5 Synchronization                                                           | 28.4.5 Synchronization                                                           | 680     |
|                                                                                  | 28.4.6 Open-Drain Output                                                         | 28.4.6 Open-Drain Output                                                         | 681     |
|                                                                                  | 28.4.7 Timing Parameter Configuration                                            | 28.4.7 Timing Parameter Configuration                                            | 682     |
|                                                                                  | 28.4.8 Timeout Control                                                           | 28.4.8 Timeout Control                                                           | 683     |
|                                                                                  | 28.4.9 Command Configuration                                                     | 28.4.9 Command Configuration                                                     | 684     |
|                                                                                  | 28.4.10 TX/RX RAM Data Storage                                                   | 28.4.10 TX/RX RAM Data Storage                                                   | 685     |
|                                                                                  | 28.4.11 Data Conversion                                                          | 28.4.11 Data Conversion                                                          | 686     |
|                                                                                  | 28.4.12 Addressing Mode                                                          | 28.4.12 Addressing Mode                                                          | 686     |
|                                                                                  | 28.4.13 R/W Bit Check in 10-bit Addressing Mode                                  | 28.4.13 R/W Bit Check in 10-bit Addressing Mode                                  | 687     |
|                                                                                  | 28.4.14 To Start the I2C Controller                                              | 28.4.14 To Start the I2C Controller                                              | 687     |
| 28.5 Programming Example                                                         | 28.5 Programming Example                                                         | 28.5 Programming Example                                                         | 687     |
| 28.5.1 I2C                                                                       | master                                                                           | Writes to I2C slave  with a 7-bit Address in One Command Sequence                | 687     |
|                                                                                  |                                                                                  | 28.5.1.1 Introduction                                                            | 688     |
|                                                                                  |                                                                                  | 28.5.1.2 Configuration Example                                                   | 688     |
| 28.5.2 I2C                                                                       | master  Writes to I2C slave                                                      | with a 10-bit Address in One Command Sequence                                    | 689     |
|                                                                                  |                                                                                  | 28.5.2.1 Introduction                                                            | 690     |
|                                                                                  |                                                                                  | 28.5.2.2 Configuration Example                                                   | 690     |
| 28.5.3 I2C                                                                       | master                                                                           | Writes to I2C slave  with Two 7-bit Addresses in One Command Sequence            | 692     |
|                                                                                  |                                                                                  | 28.5.3.1 Introduction                                                            | 692     |
|                                                                                  |                                                                                  | 28.5.3.2 Configuration Example                                                   | 692     |
| 28.5.4 I2C                                                                       | master                                                                           | Writes to I2C slave  with a 7-bit Address in Multiple Command Sequences          | 694     |
|                                                                                  |                                                                                  | 28.5.4.1 Introduction                                                            | 694     |
|                                                                                  |                                                                                  | 28.5.4.2 Configuration Example                                                   | 695     |
| 28.5.5 I2C master  Reads I2C slave  with a 7-bit Address in One Command Sequence | 28.5.5 I2C master  Reads I2C slave  with a 7-bit Address in One Command Sequence | 28.5.5 I2C master  Reads I2C slave  with a 7-bit Address in One Command Sequence | 696     |
|                                                                                  |                                                                                  | 28.5.5.1 Introduction                                                            | 696     |
|                                                                                  |                                                                                  | 28.5.5.2 Configuration Example                                                   | 697     |
| 28.5.6 I2C 28.5.6.1 Introduction                                                 | master                                                                           | Reads I2C slave  with a 10-bit Address in One Command Sequence                   | 698 698 |
|                                                                                  |                                                                                  |                                                                                  | 699     |
|                                                                                  |                                                                                  | 28.5.6.2 Configuration Example                                                   |         |

| 28.5.7 I2C master  Reads I2C slave   | with Two 7-bit Addresses in One Command Sequence                    |   700 |
|--------------------------------------|---------------------------------------------------------------------|-------|
|                                      | 28.5.7.1 Introduction                                               |   701 |
|                                      | 28.5.7.2 Configuration Example                                      |   701 |
| 28.5.8 I2C master                    | Reads I2C slave  with a 7-bit Address in Multiple Command Sequences |   704 |
|                                      | 28.5.8.1 Introduction                                               |   704 |
|                                      | 28.5.8.2 Configuration Example                                      |   705 |
| 28.6 Interrupts                      | 28.6 Interrupts                                                     |   707 |
| 28.7 Register Summary                | 28.7 Register Summary                                               |   708 |
| 28.8 Registers                       | 28.8 Registers                                                      |   710 |
| 29 I2S Controller (I2S)              | 29 I2S Controller (I2S)                                             |   730 |
| 29.1 Overview                        | 29.1 Overview                                                       |   730 |
| 29.2 Terminology                     | 29.2 Terminology                                                    |   730 |
| 29.3 Features                        |                                                                     |   731 |
| 29.4 System Architecture             | 29.4 System Architecture                                            |   732 |
| 29.5 Supported Audio Standards       | 29.5 Supported Audio Standards                                      |   733 |
| 29.5.1 TDM Philips Standard          | 29.5.1 TDM Philips Standard                                         |   734 |
| 29.5.2 TDM MSB Alignment Standard    | 29.5.2 TDM MSB Alignment Standard                                   |   734 |
| 29.5.3 TDM PCM Standard              | 29.5.3 TDM PCM Standard                                             |   735 |
| 29.5.4 PDM Standard                  | 29.5.4 PDM Standard                                                 |   735 |
| 29.6 I2S TX/RX Clock                 | 29.6 I2S TX/RX Clock                                                |   736 |
| 29.7 I2S Reset                       | 29.7 I2S Reset                                                      |   738 |
| 29.8 I2S Master/Slave Mode           | 29.8 I2S Master/Slave Mode                                          |   738 |
| 29.8.1 Master/Slave TX Mode          | 29.8.1 Master/Slave TX Mode                                         |   738 |
| 29.8.2 Master/Slave RX Mode          | 29.8.2 Master/Slave RX Mode                                         |   739 |
| 29.9 Transmitting Data               | 29.9 Transmitting Data                                              |   739 |
| 29.9.1 Data Format Control           | 29.9.1 Data Format Control                                          |   739 |
|                                      | 29.9.1.1 Bit Width Control of Channel Valid Data                    |   739 |
|                                      | 29.9.1.2 Endian Control of Channel Valid Data                       |   740 |
|                                      | 29.9.1.3 A-law/µ-law Compression and Decompression                  |   740 |
|                                      | 29.9.1.4 Bit Width Control of Channel TX Data                       |   741 |
|                                      | 29.9.1.5 Bit Order Control of Channel Data                          |   741 |
| 29.9.2 Channel Mode Control          |                                                                     |   742 |
|                                      | 29.9.2.1 I2S Channel Control in TDM TX Mode                         |   742 |
|                                      | 29.9.2.2 I2S Channel Control in PDM TX Mode                         |   743 |
| 29.10 Receiving Data                 | 29.10 Receiving Data                                                |   745 |
| 29.10.1 Channel Mode Control         | 29.10.1 Channel Mode Control                                        |   745 |
|                                      | 29.10.1.1 I2S Channel Control in TDM RX Mode                        |   746 |
|                                      | 29.10.1.2 I2S Channel Control in PDM RX Mode                        |   746 |
| 29.10.2 Data Format Control          |                                                                     |   746 |
|                                      | 29.10.2.1 Bit Order Control of Channel Data                         |   746 |
|                                      | 29.10.2.2 Bit Width Control of Channel Storage (Valid) Data         |   747 |
|                                      | 29.10.2.3 Bit Width Control of Channel RX Data                      |   747 |
|                                      | 29.10.2.4 Endian Control of Channel Storage Data                    |   747 |
|                                      | 29.10.2.5 A-law/µ-law Compression and Decompression                 |   748 |
| 29.11 Software Configuration Process | 29.11 Software Configuration Process                                |   748 |

|                                                 | 29.11.1 Configure I2S as TX Mode                         | 748   |
|-------------------------------------------------|----------------------------------------------------------|-------|
|                                                 | 29.11.2 Configure I2S as RX Mode                         | 749   |
| 29.12 I2S Interrupts                            | 29.12 I2S Interrupts                                     | 749   |
| 29.13 Register Summary                          | 29.13 Register Summary                                   | 749   |
| 29.14 Registers                                 | 29.14 Registers                                          | 751   |
| 30 USB Serial/JTAG Controller (USB_SERIAL_JTAG) | 30 USB Serial/JTAG Controller (USB_SERIAL_JTAG)          | 764   |
| 30.1 Overview                                   | 30.1 Overview                                            | 764   |
| 30.2 Features                                   | 30.2 Features                                            | 764   |
| 30.3 Functional Description                     | 30.3 Functional Description                              | 765   |
|                                                 | 30.3.1 CDC-ACM USB Interface Functional Description      | 765   |
|                                                 | 30.3.2 CDC-ACM Firmware Interface Functional Description | 767   |
|                                                 | 30.3.3 USB-to-JTAG Interface                             | 767   |
|                                                 | 30.3.4 JTAG Command Processor                            | 767   |
|                                                 | 30.3.5 USB-to-JTAG Interface: CMD_REP usage example      | 768   |
|                                                 | 30.3.6 USB-to-JTAG Interface: Response Capture Unit      | 769   |
|                                                 | 30.3.7 USB-to-JTAG Interface: Control Transfer Requests  | 770   |
| 30.4 Recommended Operation                      | 30.4 Recommended Operation                               | 770   |
| 30.5 Register Summary                           | 30.5 Register Summary                                    | 773   |
| 30.6 Registers                                  | 30.6 Registers                                           | 774   |
| 31 Two-wire Automotive Interface (TWAI)         | 31 Two-wire Automotive Interface (TWAI)                  | 788   |
| 31.1 Features                                   | 31.1 Features                                            | 788   |
| 31.2 Functional Protocol                        | 31.2 Functional Protocol                                 | 789   |
|                                                 | 31.2.1 TWAI Properties                                   | 789   |
|                                                 | 31.2.2 TWAI Messages                                     | 790   |
|                                                 | 31.2.2.1 Data Frames and Remote Frames                   | 790   |
|                                                 | 31.2.2.2 Error and Overload Frames                       | 792   |
|                                                 | 31.2.2.3 Interframe Space                                | 794   |
|                                                 | 31.2.3 TWAI Errors                                       | 794   |
|                                                 | 31.2.3.1 Error Types                                     | 794   |
|                                                 | 31.2.3.2 Error States                                    | 795   |
|                                                 | 31.2.3.3 Error Counters                                  | 795   |
| 31.2.4 TWAI Bit Timing                          |                                                          | 796   |
|                                                 | 31.2.4.1 Nominal Bit                                     |       |
|                                                 | 31.2.4.2 Hard Synchronization and Resynchronization      | 797   |
| 31.3 Architectural Overview                     | 31.3 Architectural Overview                              | 798   |
| 31.3.1 Registers Block                          | 31.3.1 Registers Block                                   | 798   |
|                                                 | 31.3.2 Bit Stream Processor                              | 799   |
|                                                 | 31.3.3 Error Management Logic                            | 799   |
|                                                 | 31.3.4 Bit Timing Logic                                  | 800   |
|                                                 | 31.3.5 Acceptance Filter                                 | 800   |
|                                                 | 31.3.6 Receive FIFO                                      | 800   |
| 31.4 Functional Description                     | 31.4 Functional Description                              | 800   |
| 31.4.1 Modes  31.4.1.1 Reset Mode               | 31.4.1 Modes  31.4.1.1 Reset Mode                        | 800   |

|                                                        | 31.4.1.2 Operation Mode                                     | 800            |
|--------------------------------------------------------|-------------------------------------------------------------|----------------|
| 31.4.2 Bit Timing                                      |                                                             | 801            |
| 31.4.3 Interrupt Management                            |                                                             | 802            |
|                                                        | 31.4.3.1 Receive Interrupt (RXI)                            | 802            |
|                                                        | 31.4.3.2 Transmit Interrupt (TXI)                           | 802            |
|                                                        | 31.4.3.3 Error Warning Interrupt (EWI)                      | 802            |
|                                                        | 31.4.3.4 Data Overrun Interrupt (DOI)                       | 803            |
|                                                        | 31.4.3.5 Error Passive Interrupt (TXI)                      | 803            |
|                                                        | 31.4.3.6 Arbitration Lost Interrupt (ALI)                   | 803            |
|                                                        | 31.4.3.7 Bus Error Interrupt (BEI)                          | 803            |
|                                                        | 31.4.3.8 Bus Status Interrupt (BSI)                         | 804            |
| 31.4.4 Transmit and Receive Buffers                    |                                                             | 804            |
|                                                        | 31.4.4.1 Overview of Buffers                                | 804            |
|                                                        | 31.4.4.2 Frame Information                                  | 805            |
|                                                        | 31.4.4.3 Frame Identifier                                   | 805            |
|                                                        | 31.4.4.4 Frame Data                                         | 806            |
| 31.4.5 Receive FIFO and Data Overruns                  |                                                             | 806            |
| 31.4.6 Acceptance Filter                               |                                                             | 807            |
|                                                        | 31.4.6.1 Single Filter Mode                                 | 808            |
|                                                        | 31.4.6.2 Dual Filter Mode                                   | 808            |
|                                                        | 31.4.7.1 Error Warning Limit                                | 810            |
|                                                        | 31.4.7.2 Error Passive                                      | 810            |
|                                                        | 31.4.7.3 Bus-Off and Bus-Off Recovery                       | 810            |
| 31.4.8 Error Code Capture                              |                                                             | 811 812        |
| 31.4.9 Arbitration Lost Capture  31.5 Register Summary | 31.4.9 Arbitration Lost Capture  31.5 Register Summary      | 813            |
|                                                        |                                                             | 814            |
| 31.6 Registers                                         | 31.6 Registers                                              | 31.6 Registers |
| 32 LED PWM Controller (LEDC)  32.1 Overview            | 32 LED PWM Controller (LEDC)  32.1 Overview                 | 827            |
| 32.2 Features                                          | 32.2 Features                                               | 827            |
| 32.3 Functional Description                            | 32.3 Functional Description                                 | 828            |
| 32.3.1 Architecture                                    | 32.3.1 Architecture                                         | 828            |
| 32.3.2 Timers                                          |                                                             | 828            |
|                                                        |                                                             | 828            |
|                                                        | 32.3.2.1 Clock Source  32.3.2.2 Clock Divider Configuration | 829            |
|                                                        | 32.3.2.3 14-bit Counter                                     |                |
|                                                        |                                                             | 830            |
| 32.3.3 PWM Generators                                  |                                                             | 831            |
| 32.3.4 Duty Cycle Fading                               |                                                             | 832            |
| 32.3.5 Interrupts                                      | 32.3.5 Interrupts                                           | 833            |
| 32.4 Register Summary                                  | 32.4 Register Summary                                       | 836            |
| 32.5 Registers                                         | 32.5 Registers                                              | 32.5 Registers |
| 33 Remote Control Peripheral (RMT)                     | 33 Remote Control Peripheral (RMT)                          | 843            |

| 33.2 Features                                         | 33.2 Features                                  | 843                         |
|-------------------------------------------------------|------------------------------------------------|-----------------------------|
| 33.3 Functional Description                           | 33.3 Functional Description                    | 843                         |
| 33.3.1 RMT Architecture                               |                                                | 844                         |
| 33.3.2 RMT RAM                                        |                                                | 844                         |
| 33.3.3 Clock                                          |                                                | 845                         |
| 33.3.4 Transmitter                                    |                                                | 846                         |
|                                                       | 33.3.4.1 Normal TX Mode                        | 846                         |
|                                                       | 33.3.4.2 Wrap TX Mode                          | 846                         |
|                                                       | 33.3.4.3 TX Modulation                         | 846                         |
|                                                       | 33.3.4.4 Continuous TX Mode                    | 847                         |
|                                                       | 33.3.4.5 Simultaneous TX Mode                  | 847                         |
| 33.3.5 Receiver                                       |                                                | 847                         |
|                                                       | 33.3.5.1 Normal RX Mode                        | 848                         |
|                                                       | 33.3.5.2 Wrap RX Mode                          | 848                         |
|                                                       | 33.3.5.3 RX Filtering                          | 848                         |
|                                                       | 33.3.5.4 RX Demodulation                       | 849                         |
| 33.3.6 Configuration Update                           |                                                | 849                         |
| 33.3.7 Interrupts                                     | 33.3.7 Interrupts                              | 850                         |
| 33.4 Register Summary                                 | 33.4 Register Summary                          | 851                         |
| 33.5 Registers                                        | 33.5 Registers                                 | 852                         |
| VI Analog Signal Processing                           | VI Analog Signal Processing                    | VI Analog Signal Processing |
| 34 On-Chip Sensor and Analog Signal Processing        | 34 On-Chip Sensor and Analog Signal Processing | 868                         |
| 34.1 Overview                                         | 34.1 Overview                                  | 868                         |
| 34.2 SAR ADCs                                         | 34.2 SAR ADCs                                  | 868                         |
| 34.2.1 Overview                                       | 34.2.1 Overview                                | 868                         |
| 34.2.2 Features                                       | 34.2.2 Features                                | 868                         |
| 34.2.3 Functional Description  34.2.3.1 Input Signals | 34.2.3.2 ADC Conversion and Attenuation        | 870 870                     |
|                                                       |                                                | 870                         |
|                                                       | 34.2.3.3 DIG ADC Controller                    |                             |
|                                                       | 34.2.3.4 DIG ADC Clock                         | 871                         |
|                                                       | 34.2.3.5 DMA Support                           | 872                         |
|                                                       | 34.2.3.6 DIG ADC FSM  34.2.3.7 ADC Filters     | 872                         |
|                                                       |                                                | 875                         |
|                                                       | 34.2.3.8 Threshold Monitoring                  | 875                         |
|                                                       | 34.2.3.9 SAR ADC2 Arbiter                      | 875                         |
| 34.3 Temperature Sensor                               | 34.3 Temperature Sensor                        | 876                         |
| 34.3.1 Overview                                       | 34.3.1 Overview                                | 876                         |
| 34.3.2 Features  34.3.3 Functional Description        | 34.3.2 Features  34.3.3 Functional Description | 876                         |
|                                                       |                                                | 876                         |
| 34.4 Interrupts                                       | 34.4 Interrupts                                | 877 877                     |
| 34.5 Register Summary  34.6 Register                  | 34.5 Register Summary  34.6 Register           | 878                         |

|                                     | VII Appendix                        |   890 |
|-------------------------------------|-------------------------------------|-------|
| Related Documentation and Resources | Related Documentation and Resources |   891 |
| Glossary                            | Glossary                            |   892 |
| Abbreviations for Peripherals       | Abbreviations for Peripherals       |   892 |
| Abbreviations Related to Registers  | Abbreviations Related to Registers  |   892 |
| Access Types for Registers          | Access Types for Registers          |   892 |
| Programming Reserved Register Field | Programming Reserved Register Field |   895 |
| Introduction                        | Introduction                        |   895 |
| Programming Reserved Register Field | Programming Reserved Register Field |   895 |
| Interrupt Configuration Registers   | Interrupt Configuration Registers   |   896 |
| Revision History                    | Revision History                    |   897 |

![Image](images/00_Header_img004_e279f386.png)

## List of Tables

| 1.3-1 CPU Address Map                                                                          |   32 |
|------------------------------------------------------------------------------------------------|------|
| 1.5-1 ID wise map of Interrupt Trap-Vector Addresses                                           |   43 |
| 1.7-1 NAPOT encoding for maddress                                                              |   52 |
| 2.4-1 Selecting Peripherals via Register Configuration                                         |   63 |
| 2.4-2 Descriptor Field Alignment Requirements                                                  |   65 |
| 3.3-1 Internal Memory Address Mapping                                                          |   93 |
| 3.3-2 External Memory Address Mapping                                                          |   95 |
| 3.3-3 Module/Peripheral Address Mapping                                                        |   98 |
| 4.3-1 Parameters in eFuse BLOCK0                                                               |  101 |
| 4.3-2 Secure Key Purpose Values                                                                |  104 |
| 4.3-3 Parameters in BLOCK1 to BLOCK10                                                          |  105 |
| 4.3-4 Registers Information                                                                    |  109 |
| 4.3-5 Configuration of Default VDDQ Timing Parameters                                          |  111 |
| 5.8-1 Bits Used to Control IO MUX Functions in Light-sleep Mode                                |  167 |
| 5.11-1 Peripheral Signals via GPIO Matrix                                                      |  169 |
| 5.12-1 IO MUX Pin Functions                                                                    |  174 |
| 5.12-2 Power-Up Glitches on Pins                                                               |  175 |
| 5.13-1 Analog Functions of IO MUX Pins                                                         |  175 |
| 6.1-1 Reset Sources                                                                            |  193 |
| 6.2-1 CPU Clock Source                                                                         |  195 |
| 6.2-2 CPU Clock Frequency                                                                      |  195 |
| 6.2-3 Peripheral Clocks                                                                        |  196 |
| 6.2-4 APB_CLK Clock Frequency                                                                  |  197 |
| 6.2-5 CRYPTO_CLK Frequency                                                                     |  197 |
| 7.1-1 Default Configuration of Strapping Pins                                                  |  198 |
| 7.2-1 Boot Mode Control                                                                        |  199 |
| 7.3-1 ROM Message Printing Control                                                             |  200 |
| 8.3-1 CPU Peripheral Interrupt Configuration/Status Registers and Peripheral Interrupt Sources |  204 |
| 9.3-1 Low-power Clocks                                                                         |  223 |
| 9.3-2 The Triggering Conditions for the RTC Timer                                              |  223 |
| 9.4-1 Predefined Power Modes                                                                   |  227 |
| 9.4-2 Wakeup Source                                                                            |  228 |
| 10.4-1 UNITn Configuration Bits                                                                |  272 |
| 10.4-2 Trigger Point                                                                           |  273 |
| 10.4-3 Synchronization Operation                                                               |  273 |
| 11.2-1 Alarm Generation When Up-Down Counter Increments                                        |  290 |
| 11.2-2 Alarm Generation When Up-Down Counter Decrements                                        |  290 |

Submit Documentation Feedback

| 14.4-1 ROM Address                                                             |   317 |
|--------------------------------------------------------------------------------|-------|
| 14.4-2 Access Configuration to ROM (ROM0 and ROM1)                             |   318 |
| 14.4-3 SRAM Address                                                            |   318 |
| 14.4-4 Access Configuration to Internal SRAM0                                  |   319 |
| 14.4-5 Internal SRAM1 Split Regions                                            |   320 |
| 14.4-6 Access Configuration to the Instruction Region of Internal SRAM1        |   322 |
| 14.4-7 Access Configuration to the Data Region of Internal SRAM1               |   322 |
| 14.4-8 RTC FAST Memory Address                                                 |   322 |
| 14.4-9 Split RTC FAST Memory into the Higher Region and the Lower Region       |   323 |
| 14.4-10 Access Configuration to the RTC FAST Memory                            |   323 |
| 14.5-1 Access Configuration of the Peripherals                                 |   324 |
| 14.5-2 Access Configuration of Peri Regions                                    |   325 |
| 14.6-1 Split the External Memory into Split Regions                            |   326 |
| 14.6-2 Access Configuration of Flash Regions                                   |   326 |
| 14.6-3 Cache Virtual Address Region                                            |   327 |
| 14.6-4 Split IBUS Cache Virtual Address into 4 Regions                         |   327 |
| 14.6-5 Split DBUS Cache Virtual Address into 4 Regions                         |   327 |
| 14.6-6 Access Configuration of IBUS to Split Regions                           |   328 |
| 14.6-7 Access Configuration of DBUS to Split Regions                           |   328 |
| 14.7-1 Interrupt Registers for Unauthorized IBUS Access                        |   329 |
| 14.7-2 Interrupt Registers for Unauthorized DBUS Access                        |   329 |
| 14.7-3 Interrupt Registers for Unauthorized Access to External Memory          |   330 |
| 14.7-4 Interrupt Registers for Unauthorized Access to Internal Memory via GDMA |   330 |
| 14.7-5 Interrupt Registers for Unauthorized PIF Access                         |   331 |
| 14.7-6 All Possible Access Alignment and their Results                         |   331 |
| 14.7-7 Interrupt Registers for Unauthorized Access Alignment                   |   332 |
| 14.8-1 Lock Registers and Related Permission Control Registers                 |   332 |
| 16.3-1 Memory Controlling Bit                                                  |   428 |
| 16.3-2 Clock Gating and Reset Bits                                             |   430 |
| 17.4-1 CPU Packet Format                                                       |   450 |
| 17.4-2 DMA Packet Format                                                       |   450 |
| 17.4-3 DMA Source                                                              |   450 |
| 17.4-4 Written Data Format                                                     |   451 |
| 18.3-1 AES Accelerator Working Mode                                            |   474 |
| 18.3-2 Key Length and Encryption/Decryption                                    |   474 |
| 18.4-1 Working Status under Typical AES Working Mode                           |   475 |
| 18.4-2 Text Endianness Type for Typical AES                                    |   475 |
| 18.4-3 Key Endianness Type for AES-128 Encryption and Decryption               |   476 |
| 18.4-4 Key Endianness Type for AES-256 Encryption and Decryption               |   476 |
| 18.5-1 Block Cipher Mode                                                       |   477 |
| 18.5-2 Working Status under DMA-AES Working mode                               |   478 |
| 18.5-3 TEXT-PADDING                                                            |   478 |

| 19.2-1 HMAC Purposes and Configuration Value                              |   488 |
|---------------------------------------------------------------------------|-------|
| 20.3-1 Acceleration Performance                                           |   506 |
| 20.4-1 RSA Accelerator Memory Blocks                                      |   507 |
| 21.3-1 SHA Accelerator Working Mode                                       |   513 |
| 21.3-2 SHA Hash Algorithm Selection                                       |   514 |
| 21.4-1 The Storage and Length of Message Digest from Different Algorithms |   518 |
| 23.4-1  Key generated based on KeyA                                       |   536 |
| 23.4-2 Mapping Between Offsets and Registers                              |   537 |
| 26.5-1 UARTn Synchronous Registers                                        |   563 |
| 26.5-2 UARTn Static Registers                                             |   564 |
| 27.5-1 Data Modes Supported by GP-SPI2                                    |   611 |
| 27.5-2 Mapping of FSPI Bus Signals                                        |   611 |
| 27.5-3 Functional Description of FSPI Bus Signals                         |   611 |
| 27.5-4 Signals Used in Various SPI Modes                                  |   613 |
| 27.5-5 Bit Order Control in GP-SPI2 Master and Slave Modes                |   614 |
| 27.5-6 Supported Transfers in Master and Slave Modes                      |   614 |
| 27.5-7 Registers Used for State Control in 1/2/4-bit Modes                |   623 |
| 27.5-7 Registers Used for State Control in 1/2/4-bit Modes                |   624 |
| 27.5-8 GP-SPI2 Master BM Table for CONF State                             |   631 |
| 27.5-9 An Example of CONF bufferi in Segmenti                             |   632 |
| 27.5-10 BM Bit Value v.s. Register to Be Updated in This Example          |   632 |
| 27.5-11 Supported CMD Values in SPI Mode                                  |   635 |
| 27.5-11 Supported CMD Values in SPI Mode                                  |   636 |
| 27.5-12 Supported CMD Values in QPI Mode                                  |   636 |
| 27.7-1 Clock Phase and Polarity Configuration in Master Mode              |   642 |
| 27.7-2 Clock Phase and Polarity Configuration in Slave Mode               |   642 |
| 27.9-1 GP-SPI2 Master Mode Interrupts                                     |   645 |
| 27.9-1 GP-SPI2 Master Mode Interrupts                                     |   646 |
| 27.9-2 GP-SPI2 Slave Mode Interrupts                                      |   646 |
| 28.4-1 I2C Synchronous Registers                                          |   681 |
| 29.4-1 I2S Signal Description                                             |   733 |
| 29.9-1 Bit Width of Channel Valid Data                                    |   740 |
| 29.9-2 Endian of Channel Valid Data                                       |   740 |
| 29.9-3 Data-Fetching Control in PDM TX Mode                               |   743 |
| 29.9-4 I2S Channel Control in Normal PDM TX Mode                          |   744 |
| 29.9-5 PCM-to-PDM TX Mode                                                 |   744 |
| 29.10-1 Channel Storage Data Width                                        |   747 |
| 29.10-2 Channel Storage Data Endian                                       |   747 |
| 30.3-1 Standard CDC-ACM Control Requests                                  |   766 |
| 30.3-2 CDC-ACM Settings with RTS and DTR                                  |   766 |

| 30.3-4 USB-to-JTAG Control Requests                                      |   770 |
|--------------------------------------------------------------------------|-------|
| 30.3-5 JTAG Capabilities Descriptor                                      |   770 |
| 30.4-1 Reset SoC into Download Mode                                      |   771 |
| 30.4-2 Reset SoC into Booting                                            |   772 |
| 31.2-1 Data Frames and Remote Frames in SFF and EFF                      |   791 |
| 31.2-2 Error Frame                                                       |   793 |
| 31.2-3 Overload Frame                                                    |   793 |
| 31.2-4 Interframe Space                                                  |   794 |
| 31.2-5 Segments of a Nominal Bit Time                                    |   797 |
| 31.4-1 Bit Information of TWAI_BUS_TIMING_0_REG (0x18)                   |   801 |
| 31.4-2 Bit Information of TWAI_BUS_TIMING_1_REG (0x1c)                   |   801 |
| 31.4-3 Buffer Layout for Standard Frame Format and Extended Frame Format |   804 |
| 31.4-4 TX/RX Frame Information (SFF/EFF); TWAI Address 0x40              |   805 |
| 31.4-5 TX/RX Identifier 1 (SFF); TWAI Address 0x44                       |   805 |
| 31.4-6 TX/RX Identifier 2 (SFF); TWAI Address 0x48                       |   805 |
| 31.4-7 TX/RX Identifier 1 (EFF); TWAI Address 0x44                       |   806 |
| 31.4-8 TX/RX Identifier 2 (EFF); TWAI Address 0x48                       |   806 |
| 31.4-9 TX/RX Identifier 3 (EFF); TWAI Address 0x4c                       |   806 |
| 31.4-10 TX/RX Identifier 4 (EFF); TWAI Address 0x50                      |   806 |
| 31.4-11 Bit Information of TWAI_ERR_CODE_CAP_REG (0x30)                  |   811 |
| 31.4-12 Bit Information of Bits SEG.4 - SEG.0                            |   811 |
| 31.4-13 Bit Information of TWAI_ARB LOST CAP_REG (0x2c)                  |   812 |
| 32.3-1 Commonly-used Frequencies and Resolutions                         |   830 |
| 32.3-1 Commonly-used Frequencies and Resolutions                         |   831 |
| 33.3-1 Configuration Update                                              |   849 |
| 34.2-1 SAR ADC Input Signals                                             |   870 |
| 34.3-1 Temperature Offset                                                |   877 |
| 34.6-4 Configuration of ENA/RAW/ST Registers                             |   896 |

## List of Figures

| 1.1-1 CPU Block Diagram                                                   |   31 |
|---------------------------------------------------------------------------|------|
| 1.6-1 Debug System Overview                                               |   47 |
| 2.1-1 Modules with GDMA Feature and GDMA Channels                         |   60 |
| 2.3-1 GDMA Engine Architecture                                            |   61 |
| 2.4-1 Structure of a Linked List                                          |   62 |
| 2.4-2 Relationship among Linked Lists                                     |   64 |
| 3.2-1 System Structure and Address Mapping                                |   92 |
| 3.3-1 Cache Structure                                                     |   96 |
| 3.3-2 Peripherals/modules that can work with GDMA                         |   97 |
| 4.3-1 Shift Register Circuit (first 32 output)                            |  107 |
| 4.3-2 Shift Register Circuit (last 12 output)                             |  107 |
| 5.3-1 Diagram of IO MUX and GPIO Matrix                                   |  160 |
| 5.3-2 Architecture of IO MUX and GPIO Matrix                              |  160 |
| 5.3-3 Internal Structure of a Pad                                         |  161 |
| 5.4-1 GPIO Input Synchronized on APB Clock Rising Edge or on Falling Edge |  162 |
| 5.4-2 Filter Timing of GPIO Input Signals                                 |  162 |
| 6.1-1 Reset Types                                                         |  191 |
| 6.2-1 System Clock                                                        |  194 |
| 8.2-1 Interrupt Matrix Structure                                          |  202 |
| 9.3-1 Low-power Management Schematics                                     |  220 |
| 9.3-2 Power Management Unit Workflow                                      |  221 |
| 9.3-3 RTC Clocks                                                          |  222 |
| 9.3-4 Wireless Clock                                                      |  223 |
| 9.3-5 Digital System Regulator                                            |  225 |
| 9.3-6 Low-power voltage regulator                                         |  225 |
| 9.3-7 Brown-out detector                                                  |  226 |
| 9.6-1 ESP32-C3 Boot Flow                                                  |  230 |
| 10.1-1 System Timer Structure                                             |  270 |
| 10.4-1 System Timer Alarm Generation                                      |  271 |
| 11.1-1 Timer Units within Groups                                          |  288 |
| 11.2-1 Timer Group Architecture                                           |  289 |
| 12.1-1 Watchdog Timers Overview                                           |  305 |
| 12.2-1 Watchdog Timers in ESP32-C3                                        |  307 |
| 12.3-1 Super Watchdog Controller Structure                                |  310 |
| 13.1-1 XTAL32K Watchdog Timer                                             |  312 |
| 14.1-1 Permission Control Overview                                        |  316 |

| 14.4-1 Split Lines for Internal SRAM1                                 |   319 |
|-----------------------------------------------------------------------|-------|
| 14.4-2 An illustration of Configuring the Category fields             |   321 |
| 14.6-1 Two Ways to Access External Memory                             |   326 |
| 15.4-1 Switching From Secure World to Non-secure World                |   415 |
| 15.4-2 Switching From Non-secure World to Secure World                |   416 |
| 15.5-1 World Switch Log Register                                      |   417 |
| 15.5-2 Nested Interrupts Handling - Entry 9                           |   418 |
| 15.5-3 Nested Interrupts Handling - Entry 1                           |   419 |
| 15.5-4 Nested Interrupts Handling - Entry 4                           |   419 |
| 19.3-1 HMAC SHA-256 Padding Diagram                                   |   491 |
| 19.3-2 HMAC Structure Schematic Diagram                               |   492 |
| 22.3-1 Software Preparations and Hardware Working Process             |   525 |
| 23.3-1 Architecture of the External Memory Encryption and Decryption  |   535 |
| 24.3-1 Noise Source                                                   |   544 |
| 25.2-1 XTAL_CLK Pulse Width                                           |   547 |
| 26.3-1 UART Architecture Overview                                     |   550 |
| 26.3-2 UART Structure                                                 |   550 |
| 26.4-1 UART Controllers Sharing RAM                                   |   552 |
| 26.4-2 UART Controllers Division                                      |   554 |
| 26.4-3 The Timing Diagram of Weak UART Signals Along Falling Edges    |   554 |
| 26.4-4 Structure of UART Data Frame                                   |   555 |
| 26.4-5 AT_CMD Character Structure                                     |   556 |
| 26.4-6 Driver Control Diagram in RS485 Mode                           |   557 |
| 26.4-7 The Timing Diagram of Encoding and Decoding in SIR mode        |   558 |
| 26.4-8 IrDA Encoding and Decoding Diagram                             |   558 |
| 26.4-9 Hardware Flow Control Diagram                                  |   559 |
| 26.4-10 Connection between Hardware Flow Control Signals              |   560 |
| 26.4-11 Data Transfer in GDMA Mode                                    |   561 |
| 26.5-1 UART Programming Procedures                                    |   565 |
| 27.4-1 SPI Module Overview                                            |   610 |
| 27.5-1 Data Buffer Used in CPU-Controlled Transfer                    |   615 |
| 27.5-2 GP-SPI2 Block Diagram                                          |   618 |
| 27.5-3 Data Flow Control in GP-SPI2 Master Mode                       |   619 |
| 27.5-4 Data Flow Control in GP-SPI2 Slave Mode                        |   620 |
| 27.5-5 GP-SPI2 State Machine in Master Mode                           |   622 |
| 27.5-6 Full-Duplex Communication Between GP-SPI2 Master and a Slave   |   626 |
| 27.5-7 Connection of GP-SPI2 to Flash and External RAM in 4-bit Mode  |   629 |
| 27.5-8 SPI Quad I/O Read Command Sequence Sent by GP-SPI2 to Flash    |   629 |
| 27.5-9 Configurable Segmented Transfer in DMA-Controlled Master Mode  |   630 |
| 27.6-1 Recommended CS Timing and Settings When Accessing External RAM |   639 |

| 27.7-1 SPI Clock Mode 0 or 2                                                               |   641 |
|--------------------------------------------------------------------------------------------|-------|
| 27.7-2 SPI Clock Mode 1 or 3                                                               |   641 |
| 27.8-1 Timing Compensation Control Diagram in GP-SPI2 Master Mode                          |   643 |
| 27.8-2 Timing Compensation Example in GP-SPI2 Master Mode                                  |   644 |
| 28.3-1 I2C Master Architecture                                                             |   677 |
| 28.3-2 I2C Slave Architecture                                                              |   677 |
| 28.3-3 I2C Protocol Timing (Cited from Fig.31 in The I2C-bus specification Version 2.1)    |   678 |
| 28.3-4 I2C Timing Parameters (Cited from Table 5 in The I2C-bus specification Version 2.1) |   679 |
| 28.4-1 I2C Timing Diagram                                                                  |   682 |
| 28.4-2 Structure of I2C Command Registers                                                  |   684 |
| 28.5-1 I2C master  Writing to I2Cslave with a 7-bit Address                                |   688 |
| 28.5-2 I2C master  Writing to a Slave with a 10-bit Address                                |   690 |
| 28.5-3 I2C master  Writing to I2Cslave with Two 7-bit Addresses                            |   692 |
| 28.5-4 I2C master  Writing to I2Cslave with a 7-bit Address in Multiple Sequences          |   694 |
| 28.5-5 I2C master  Reading I2Cslave with a 7-bit Address                                   |   696 |
| 28.5-6 I2C master  Reading I2Cslave with a 10-bit Address                                  |   698 |
| 28.5-7 I2C master  Reading N Bytes of Data from addrM of I2Cslave with a 7-bit Address     |   701 |
| 28.5-8 I2C master  Reading I2Cslave with a 7-bit Address in Segments                       |   704 |
| 29.4-1 ESP32-C3 I2S System Diagram                                                         |   732 |
| 29.5-1 TDM Philips Standard Timing Diagram                                                 |   734 |
| 29.5-2 TDM MSB Alignment Standard Timing Diagram                                           |   735 |
| 29.5-3 TDM PCM Standard Timing Diagram                                                     |   735 |
| 29.5-4 PDM Standard Timing Diagram                                                         |   736 |
| 29.6-1 I2S Clock                                                                           |   736 |
| 29.9-1 TX Data Format Control                                                              |   741 |
| 29.9-2 TDM Channel Control                                                                 |   743 |
| 29.9-3 PDM Channel Control Example                                                         |   745 |
| 30.2-1 USB Serial/JTAG High Level Diagram                                                  |   765 |
| 30.2-2 USB Serial/JTAG Block Diagram                                                       |   766 |
| 31.2-1 Bit Fields in Data Frames and Remote Frames                                         |   791 |
| 31.2-2 Fields of an Error Frame                                                            |   793 |
| 31.2-3 Fields of an Overload Frame                                                         |   793 |
| 31.2-4 The Fields within an Interframe Space                                               |   794 |
| 31.2-5 Layout of a Bit                                                                     |   797 |
| 31.3-1 TWAI Overview Diagram                                                               |   798 |
| 31.4-1 Acceptance Filter                                                                   |   807 |
| 31.4-2 Single Filter Mode                                                                  |   808 |
| 31.4-3 Dual Filter Mode                                                                    |   809 |
| 31.4-4 Error State Transition                                                              |   810 |
| 31.4-5 Positions of Arbitration Lost Bits                                                  |   812 |
| 32.2-1 LED PWM Architecture                                                                |   827 |
| 32.3-1 LED PWM Generator Diagram                                                           |   828 |
| 32.3-2 Frequency Division When LEDC_CLK_DIV is a Non-Integer Value                         |   829 |

| 32.3-3 LED_PWM Output Signal Diagram                                    |   832 |
|-------------------------------------------------------------------------|-------|
| 32.3-4 Output Signal Diagram of Fading Duty Cycle                       |   832 |
| 33.3-1 RMT Architecture                                                 |   844 |
| 33.3-2 Format of Pulse Code in RAM                                      |   844 |
| 34.2-1 SAR ADCs Function Overview                                       |   869 |
| 34.2-2 Diagram of DIG ADC FSM                                           |   872 |
| 34.2-3 APB_SARADC_SAR_PATT_TAB1_REG and Pattern Table Entry 0 - Entry 3 |   873 |
| 34.2-4 APB_SARADC_SAR_PATT_TAB2_REG and Pattern Table Entry 4 - Entry 7 |   873 |
| 34.2-5 Pattern Table Entry                                              |   873 |
| 34.2-6 cmd0 Configuration                                               |   874 |
| 34.2-7 cmd1 configuration                                               |   874 |
| 34.2-8 DMA Data Format                                                  |   874 |

![Image](images/00_Header_img005_f43d4c8f.png)

## Part I

## Microprocessor and Master

This part covers the essential processing elements of the system. Details include controllers for Direct Memory Access (DMA) and RISC-V CPU.

---

# ESP32-C3 Technical Reference Manual - Split Edition

This document has been split into individual chapters for easier navigation.

**Processed:** 2026-02-10 16:17

## Quick Navigation

- [Chapter 1: Chapter 1](01_Chapter_1.md)
- [Chapter 2: Chapter 2](02_Chapter_2.md)
- [Chapter 3: Chapter 3](03_Chapter_3.md)
- [Chapter 4: Chapter 4](04_Chapter_4.md)
- [Chapter 5: Chapter 5](05_Chapter_5.md)
- [Chapter 6: Chapter 6](06_Chapter_6.md)
- [Chapter 7: Chapter 7](07_Chapter_7.md)
- [Chapter 8: Chapter 8](08_Chapter_8.md)
- [Chapter 9: Chapter 9](09_Chapter_9.md)
- [Chapter 10: Chapter 10](10_Chapter_10.md)
- [Chapter 11: Chapter 11](11_Chapter_11.md)
- [Chapter 12: Chapter 12](12_Chapter_12.md)
- [Chapter 13: Chapter 13](13_Chapter_13.md)
- [Chapter 14: Chapter 14](14_Chapter_14.md)
- [Chapter 15: Chapter 15](15_Chapter_15.md)
- [Chapter 16: Chapter 16](16_Chapter_16.md)
- [Chapter 17: Chapter 17](17_Chapter_17.md)
- [Chapter 18: Chapter 18](18_Chapter_18.md)
- [Chapter 19: Chapter 19](19_Chapter_19.md)
- [Chapter 20: Chapter 20](20_Chapter_20.md)
- [Chapter 21: Chapter 21](21_Chapter_21.md)
- [Chapter 22: Chapter 22](22_Chapter_22.md)
- [Chapter 23: Chapter 23](23_Chapter_23.md)
- [Chapter 24: Chapter 24](24_Chapter_24.md)
- [Chapter 25: Chapter 25](25_Chapter_25.md)
- [Chapter 26: Chapter 26](26_Chapter_26.md)
- [Chapter 27: Chapter 27](27_Chapter_27.md)
- [Chapter 28: Chapter 28](28_Chapter_28.md)
- [Chapter 29: Chapter 29](29_Chapter_29.md)
- [Chapter 30: Chapter 30](30_Chapter_30.md)
- [Chapter 31: Chapter 31](31_Chapter_31.md)
- [Chapter 32: Chapter 32](32_Chapter_32.md)
- [Chapter 33: Chapter 33](33_Chapter_33.md)
- [Chapter 34: Chapter 34](34_Chapter_34.md)
