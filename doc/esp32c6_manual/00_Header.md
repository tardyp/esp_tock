## ESP32-C6

## Technical Reference Manual Version 1.1

![Image](images/00_Header_img001_9a5d5692.png)

## About This Document

The ESP32-C6 Technical Reference Manual is targeted at developers working on low level software projects that use the ESP32-C6 SoC. It describes the hardware modules listed below for the ESP32-C6 SoC and other products in ESP32-C6 series. The modules detailed in this document provide an overview, list of features, hardware architecture details, any necessary programming procedures, as well as register descriptions.

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

Note that this manual in still work in progress. See our release progress below:

| No.                                      | Chapter                                             | Progress                                 |
|------------------------------------------|-----------------------------------------------------|------------------------------------------|
| Part I. Microprocessor and Master        | Part I. Microprocessor and Master                   | Part I. Microprocessor and Master        |
| 1                                        | High-Performance CPU                                | Published                                |
| 2                                        | RISC-V Trace Encoder (TRACE)                        | Published                                |
| 3                                        | Low-Power CPU                                       | Published                                |
| 4                                        | GDMA Controller (GDMA)                              | Published                                |
| Part II. Memory Organization             | Part II. Memory Organization                        | Part II. Memory Organization             |
| 5                                        | System and Memory                                   | Published                                |
| 6                                        | eFuse Controller                                    | Published                                |
| Part III. System Component               | Part III. System Component                          | Part III. System Component               |
| 7                                        | IO MUX and GPIO Matrix (GPIO, IO MUX)               | Published                                |
| 8                                        | Reset and Clock                                     | Published                                |
| 9                                        | Chip Boot Control                                   | Published                                |
| 10                                       | Interrupt Matrix (INTMTX)                           | Published                                |
| 11                                       | Event Task Matrix (SOC_ETM)                         | Published                                |
| 12                                       | Low-Power Management                                | Published                                |
| 13                                       | System Timer (SYSTIMER)                             | Published                                |
| 14                                       | Timer Group (TIMG)                                  | Published                                |
| 15                                       | Watchdog Timers (WDT)                               | Published                                |
| 16                                       | Permission Control (PMS)                            | Published                                |
| 17                                       | System Registers                                    | Published                                |
| 18                                       | Debug Assistant (ASSIST_DEBUG)                      | Published                                |
| Part IV. Cryptography/Security Component | Part IV. Cryptography/Security Component            | Part IV. Cryptography/Security Component |
| 19                                       | AES Accelerator (AES)                               | Published                                |
| 20                                       | ECC Accelerator (ECC)                               | Published                                |
| 21                                       | HMAC Accelerator (HMAC)                             | Published                                |
| 22                                       | RSA Accelerator (RSA)                               | Published                                |
| 23                                       | SHA Accelerator (SHA)                               | Published                                |
| 24                                       | Digital Signature (DS)                              | Published                                |
| 25                                       | External Memory Encryption and Decryption (XTS_AES) | Published                                |
| 26                                       | Random Number Generator (RNG)                       | Published                                |
| Part V. Connectivity Interface           | Part V. Connectivity Interface                      | Part V. Connectivity Interface           |
| 27                                       | UART Controller (UART, LP_UART, UHCI)               | Published                                |
| 28                                       | SPI Controller (SPI)                                | Published                                |
| 29                                       | I2C Controller (I2C)                                | Published                                |
| 30                                       | I2S Controller (I2S)                                | Published                                |
| 31                                       | Pulse Count Controller (PCNT)                       | Published                                |
| 32                                       | USB Serial/JTAG Controller (USB_SERIAL_JTAG)        | Published                                |
| 33                                       | Two-wire Automotive Interface (TWAI)                | Published                                |
| 34                                       | SDIO Slave Controller (SDIO)                        | Published                                |
| 35                                       | LED PWM Controller (LEDC)                           | Published                                |

| No.                               | Chapter                                     | Progress                          |
|-----------------------------------|---------------------------------------------|-----------------------------------|
| 36                                | Motor Control PWM (MCPWM)                   | Published                         |
| 37                                | Remote Control Peripheral (RMT)             | Published                         |
| 38                                | Parallel IO Controller (PARL_IO)            | Published                         |
| Part VI. Analog Signal Processing | Part VI. Analog Signal Processing           | Part VI. Analog Signal Processing |
| 39                                | On-Chip Sensor and Analog Signal Processing | Published                         |

## Note:

Check the link or the QR code to make sure that you use the latest version of this document:

https://www.espressif.com/documentation/esp32-c6\_technical\_reference\_manual\_en.pdf

![Image](images/00_Header_img002_8cf7b40e.png)

## Contents

|                                               | I Microprocessor and Master                   | 38   |
|-----------------------------------------------|-----------------------------------------------|------|
| 1 High-Performance CPU                        | 1 High-Performance CPU                        | 39   |
| 1.1 Overview                                  | 1.1 Overview                                  | 39   |
| 1.2 Features                                  | 1.2 Features                                  | 39   |
| 1.3 Terminology                               | 1.3 Terminology                               | 40   |
| 1.4 Address Map                               | 1.4 Address Map                               | 40   |
| 1.5 Configuration and Status Registers (CSRs) | 1.5 Configuration and Status Registers (CSRs) | 41   |
|                                               | 1.5.1 Register Summary                        | 41   |
|                                               | 1.5.2 Register Description                    | 43   |
| 1.6 Interrupt Controller                      | 1.6 Interrupt Controller                      | 55   |
|                                               | 1.6.1 Features                                | 55   |
|                                               | 1.6.2 Functional Description                  | 55   |
|                                               | 1.6.3 Suggested Operation                     | 57   |
|                                               | 1.6.3.1 Latency Aspects                       | 57   |
|                                               | 1.6.3.2 Configuration Procedure               | 58   |
| 1.6.4 Registers                               | 1.6.4 Registers                               | 59   |
| 1.7 Core Local Interrupts (CLINT)             | 1.7 Core Local Interrupts (CLINT)             | 60   |
| 1.7.1 Overview                                | 1.7.1 Overview                                | 60   |
| 1.7.2 Features                                | 1.7.2 Features                                | 60   |
| 1.7.3 Software Interrupt                      | 1.7.3 Software Interrupt                      | 60   |
| 1.7.4 Timer Counter and Interrupt             | 1.7.4 Timer Counter and Interrupt             | 61   |
| 1.7.5 Register Summary                        | 1.7.5 Register Summary                        | 61   |
| 1.7.6 Register Description                    | 1.7.6 Register Description                    | 61   |
| 1.8 Physical Memory Protection                | 1.8 Physical Memory Protection                | 65   |
| 1.8.1 Overview                                | 1.8.1 Overview                                | 65   |
| 1.8.2 Features                                | 1.8.2 Features                                | 65   |
| 1.8.3 Functional Description                  | 1.8.3 Functional Description                  | 65   |
| 1.8.4 Register Summary                        | 1.8.4 Register Summary                        | 66   |
| 1.8.5 Register Description                    | 1.8.5 Register Description                    | 66   |
| 1.9 Physical Memory Attribute (PMA) Checker   | 1.9 Physical Memory Attribute (PMA) Checker   | 67   |
| 1.9.1 Overview                                | 1.9.1 Overview                                | 67   |
| 1.9.2 Features                                | 1.9.2 Features                                | 67   |
| 1.9.3 Functional Description                  | 1.9.3 Functional Description                  | 67   |
| 1.9.4 Register Summary                        | 1.9.4 Register Summary                        | 68   |
| 1.9.5 Register Description                    | 1.9.5 Register Description                    | 71   |
| 1.10 Debug                                    | 1.10 Debug                                    |      |
|                                               |                                               | 71   |
| 1.10.1 Overview                               | 1.10.2 Features                               | 72   |
| 1.10.3 Functional Description                 | 1.10.3 Functional Description                 | 72   |
| 1.10.4 JTAG Control                           | 1.10.4 JTAG Control                           | 72   |
| 1.10.5 Register Summary                       | 1.10.5 Register Summary                       | 73   |

| 1.10.6 Register Description                         | 1.10.6 Register Description                         | 73   |
|-----------------------------------------------------|-----------------------------------------------------|------|
| 1.11 Hardware Trigger                               | 1.11 Hardware Trigger                               | 76   |
|                                                     | 1.11.1 Features                                     | 76   |
|                                                     | 1.11.2 Functional Description                       | 76   |
|                                                     | 1.11.3 Trigger Execution Flow                       | 77   |
|                                                     | 1.11.4 Register Summary                             | 77   |
|                                                     | 1.11.5 Register Description                         | 78   |
| 1.12 Trace                                          | 1.12 Trace                                          | 82   |
|                                                     | 1.12.1 Overview                                     | 82   |
|                                                     | 1.12.2 Features                                     | 82   |
|                                                     | 1.12.3 Functional Description                       | 82   |
| 1.13 Debug Cross-Triggering                         | 1.13 Debug Cross-Triggering                         | 83   |
|                                                     | 1.13.1 Overview                                     | 83   |
|                                                     | 1.13.2 Features                                     | 83   |
|                                                     | 1.13.3 Functional Description                       | 83   |
|                                                     | 1.13.4 Register Summary                             | 84   |
|                                                     | 1.13.5 Register Description                         | 84   |
| 1.14 Dedicated IO                                   |                                                     | 85   |
|                                                     | 1.14.1 Overview                                     | 85   |
|                                                     | 1.14.2 Features                                     | 85   |
|                                                     | 1.14.3 Functional Description                       | 85   |
|                                                     | 1.14.4 Register Summary                             | 86   |
|                                                     | 1.14.5 Register Description                         | 86   |
|                                                     | 1.15 Atomic (A) Extension                           | 88   |
|                                                     | 1.15.1 Overview                                     | 88   |
|                                                     | 1.15.2 Functional Description                       | 88   |
|                                                     | 1.15.2.1 Load Reserve (LR.W) Instruction            | 88   |
|                                                     | 1.15.2.2 Store Conditional (SC.W) Instruction       | 88   |
|                                                     | 1.15.2.3 AMO Instructions                           | 89   |
| 2 RISC-V Trace Encoder (TRACE)                      | 2 RISC-V Trace Encoder (TRACE)                      | 90   |
| 2.1 Terminology                                     | 2.1 Terminology                                     | 90   |
| 2.2 Introduction                                    | 2.2 Introduction                                    | 91   |
| 2.3 Features                                        | 2.3 Features                                        | 91   |
| 2.4 Architectural Overview                          | 2.4 Architectural Overview                          | 93   |
| 2.5 Functional Description                          | 2.5 Functional Description                          |      |
| 2.5.1 Synchronization                               | 2.5.1 Synchronization                               | 93   |
|                                                     | 2.5.2 Anchor Tag                                    | 93   |
|                                                     | 2.5.3 Memory Writing Mode                           | 94   |
| 2.5.4 Automatic Restart  2.6 Encoder Output Packets | 2.5.4 Automatic Restart  2.6 Encoder Output Packets |      |
|                                                     |                                                     | 94   |
|                                                     |                                                     | 95   |
| 2.6.1 Header  2.6.2 Index                           | 2.6.1 Header  2.6.2 Index                           | 95   |
| 2.6.3 Payload                                       | 2.6.3 Payload                                       | 95   |
| 2.6.3.1 Format 3 Packets                            | 2.6.3.1 Format 3 Packets                            | 95   |
| 2.6.3.2 Format 2 Packets                            | 2.6.3.2 Format 2 Packets                            | 97   |

|                                               | 2.6.3.3 Format 1 Packets                      | 97   |
|-----------------------------------------------|-----------------------------------------------|------|
| 2.7 Interrupt                                 | 2.7 Interrupt                                 | 98   |
| 2.8 Programming Procedures                    | 2.8 Programming Procedures                    | 99   |
|                                               | 2.8.1 Enable Encoder                          | 99   |
|                                               | 2.8.2 Disable Encoder                         | 99   |
|                                               | 2.8.3 Decode Data Packets                     | 99   |
| 2.9 Register Summary                          | 2.9 Register Summary                          | 101  |
| 2.10 Registers                                | 2.10 Registers                                | 102  |
| 3 Low-Power CPU                               | 3 Low-Power CPU                               | 107  |
| 3.1 Features                                  | 3.1 Features                                  | 107  |
| 3.2 Configuration and Status Registers (CSRs) | 3.2 Configuration and Status Registers (CSRs) | 108  |
|                                               | 3.2.1 Register Summary                        | 108  |
|                                               | 3.2.2 Registers                               | 109  |
| 3.3 Interrupts and Exceptions                 | 3.3 Interrupts and Exceptions                 | 116  |
|                                               | 3.3.1 Interrupts                              | 117  |
|                                               | 3.3.2 Interrupt Handling                      | 117  |
|                                               | 3.3.3 Exceptions                              | 117  |
| 3.4 Debugging                                 |                                               | 118  |
|                                               | 3.4.1 Features                                | 118  |
|                                               | 3.4.2 Functional Description                  | 118  |
|                                               | 3.4.3 Register Summary                        | 118  |
|                                               | 3.4.4 Registers                               | 119  |
| 3.5 Hardware Trigger                          | 3.5 Hardware Trigger                          | 121  |
|                                               | 3.5.1 Features                                | 121  |
|                                               | 3.5.2 Functional Description                  | 121  |
|                                               | 3.5.3 Trigger Execution Flow                  | 122  |
|                                               | 3.5.4 Register Summary                        | 122  |
|                                               | 3.5.5 Registers                               | 122  |
| 3.6 Performance Counter                       | 3.6 Performance Counter                       | 125  |
| 3.7 System Access                             | 3.7 System Access                             | 126  |
|                                               | 3.7.1 Memory Access                           | 126  |
| 3.7.2 Peripheral Access                       | 3.7.2 Peripheral Access                       | 126  |
| 3.8 Event Task Matrix Feature                 | 3.8 Event Task Matrix Feature                 | 126  |
| 3.9 Sleep and Wake-Up Process                 | 3.9 Sleep and Wake-Up Process                 | 127  |
|                                               | 3.9.1 Features                                | 127  |
|                                               | 3.9.2 Process                                 | 127  |
| 3.9.3 Wake-Up Sources                         | 3.9.3 Wake-Up Sources                         | 129  |
| 3.10 Register Summary                         | 3.10 Register Summary                         |      |
| 3.11 Registers                                | 3.11 Registers                                | 129  |
| 4 GDMA Controller (GDMA)                      | 4 GDMA Controller (GDMA)                      | 131  |
|                                               |                                               | 131  |
| 4.1 Overview  4.2 Features                    | 4.1 Overview  4.2 Features                    | 131  |
| 4.3 Architecture                              | 4.3 Architecture                              | 132  |
| 4.4 Functional Description                    | 4.4 Functional Description                    | 133  |

|                                                          | 4.4.1 Linked List                                                 | 133   |
|----------------------------------------------------------|-------------------------------------------------------------------|-------|
|                                                          | 4.4.2 Peripheral-to-Memory and Memory-to-Peripheral Data Transfer | 134   |
|                                                          | 4.4.3 Memory-to-Memory Data Transfer                              | 135   |
|                                                          | 4.4.4 Enabling GDMA                                               | 135   |
|                                                          | 4.4.5 Linked List Reading Process                                 | 136   |
| 4.4.6 EOF                                                |                                                                   | 136   |
|                                                          | 4.4.7 Accessing Internal RAM                                      | 137   |
|                                                          | 4.4.8 Arbitration                                                 | 137   |
|                                                          | 4.4.9 Event Task Matrix Feature                                   | 137   |
|                                                          | 4.5 GDMA Interrupts                                               | 138   |
|                                                          | 4.6 Programming Procedures                                        | 139   |
| 4.6.1 Programming Procedures for GDMA’s Transmit Channel | 4.6.1 Programming Procedures for GDMA’s Transmit Channel          | 139   |
|                                                          | 4.6.2 Programming Procedures for GDMA’s Receive Channel           | 140   |
|                                                          | 4.6.3 Programming Procedures for Memory-to-Memory Transfer        | 140   |
|                                                          | 4.7 Register Summary                                              | 141   |
| 4.8 Registers                                            | 4.8 Registers                                                     | 145   |
| II Memory Organization                                   | II Memory Organization                                            | 168   |
| 5 System and Memory  5.1 Overview                        | 5 System and Memory  5.1 Overview                                 | 169   |
| 5.2 Features                                             | 5.2 Features                                                      |       |
|                                                          |                                                                   | 169   |
| 5.3 Functional Description                               | 5.3 Functional Description                                        | 170   |
|                                                          | 5.3.1 Address Mapping                                             | 170   |
|                                                          | 5.3.2 Internal Memory                                             | 171   |
|                                                          | 5.3.3 External Memory                                             | 172   |
|                                                          | 5.3.3.1 External Memory Address Mapping                           | 172   |
|                                                          | 5.3.3.2 Cache                                                     | 173   |
|                                                          | 5.3.3.3 Cache Operations                                          | 173   |
| 5.3.4 GDMA Address Space                                 | 5.3.4 GDMA Address Space                                          | 174   |
| 5.3.5 Modules/Peripherals Address Mapping                | 5.3.5 Modules/Peripherals Address Mapping                         | 175   |
| 6 eFuse Controller                                       | 6 eFuse Controller                                                | 178   |
| 6.1 Overview  6.2 Features                               | 6.1 Overview  6.2 Features                                        | 178   |
| 6.3 Functional Description                               | 6.3 Functional Description                                        | 178   |
|                                                          | 6.3.1.1 EFUSE_WR_DIS                                              | 185   |
|                                                          | 6.3.1.2 EFUSE_RD_DIS                                              | 185   |
|                                                          | 6.3.1.3 Data Storage                                              | 185   |
|                                                          | 6.3.2 Programming of Parameters                                   |       |
|                                                          |                                                                   | 187   |
| 6.3.3 Reading of Parameters by Users                     | 6.3.3 Reading of Parameters by Users                              | 189   |
| 6.3.4 eFuse VDDQ Timing                                  | 6.3.4 eFuse VDDQ Timing                                           | 190   |
| 6.3.5 Parameters Used by Hardware Modules                | 6.3.5 Parameters Used by Hardware Modules                         | 190   |
| 6.4 Register Summary                                     | 6.4 Register Summary                                              | 192   |

| 6.5 Registers                                   | 6.5 Registers                                       | 196     |
|-------------------------------------------------|-----------------------------------------------------|---------|
| III System Component                            | III System Component                                | 243     |
| 7 IO MUX and GPIO Matrix (GPIO, IO MUX)         | 7 IO MUX and GPIO Matrix (GPIO, IO MUX)             | 244     |
| 7.1 Overview                                    | 7.1 Overview                                        | 244     |
| 7.2 Features                                    | 7.2 Features                                        | 244     |
| 7.3 Architectural Overview                      | 7.3 Architectural Overview                          | 245     |
| 7.4 Peripheral Input via GPIO Matrix            | 7.4 Peripheral Input via GPIO Matrix                | 246     |
|                                                 | 7.4.1 Overview                                      | 247     |
|                                                 | 7.4.2 Signal Synchronization                        | 247     |
|                                                 | 7.4.3 Functional Description                        | 247     |
|                                                 | 7.4.4 Simple GPIO Input                             | 249     |
| 7.5 Peripheral Output via GPIO Matrix           | 7.5 Peripheral Output via GPIO Matrix               | 250     |
|                                                 | 7.5.1 Overview                                      | 250     |
|                                                 | 7.5.2 Functional Description                        | 250     |
|                                                 | 7.5.3 Simple GPIO Output                            | 251     |
|                                                 | 7.5.4 Sigma Delta Modulated Output (SDM)            | 251     |
|                                                 | 7.5.4.1 Functional Description                      | 251     |
|                                                 | 7.5.4.2 SDM Configuration                           | 252     |
| 7.6 Direct Input and Output via IO MUX          | 7.6 Direct Input and Output via IO MUX              | 252     |
|                                                 | 7.6.1 Overview                                      | 252     |
|                                                 | 7.6.2 Functional Description                        | 253     |
|                                                 | 7.7 LP IO MUX for Low Power and Analog Input/Output | 253     |
|                                                 | 7.7.1 Overview                                      | 253     |
|                                                 | 7.7.2 Low Power Capabilities                        | 253     |
| 7.7.3 Analog Functions                          | 7.7.3 Analog Functions                              | 253     |
| 7.8 Pin Functions in Light-sleep                | 7.8 Pin Functions in Light-sleep                    | 254     |
| 7.9 Pin Hold Feature                            | 7.9 Pin Hold Feature                                | 254     |
| 7.10 Power Supplies and Management of GPIO Pins | 7.10 Power Supplies and Management of GPIO Pins     | 255     |
|                                                 | 7.10.1 Power Supplies of GPIO Pins                  | 255     |
| 7.10.2 Power Supply Management                  | 7.10.2 Power Supply Management                      | 255     |
| 7.11 Peripheral Signal List                     | 7.11 Peripheral Signal List                         | 255     |
| 7.12 IO MUX Functions List                      | 7.12 IO MUX Functions List                          | 262     |
| 7.13 LP IO MUX Functions List                   | 7.13 LP IO MUX Functions List                       | 263     |
| 7.14 Event Task Matrix Function                 | 7.14 Event Task Matrix Function                     | 264     |
|                                                 | 7.15.1 GPIO Matrix Register Summary                 | 265     |
|                                                 | 7.15.2 IO MUX Register Summary                      | 267     |
|                                                 | 7.15.3 GPIO_EXT Register Summary                    | 268     |
| 7.16 Registers                                  | 7.16 Registers                                      | 270     |
|                                                 |                                                     | 270     |
|                                                 | 7.16.1 GPIO Matrix Registers                        |         |
|                                                 | 7.16.2 IO MUX Registers  7.16.3 GPIO_EXT Registers  | 281 284 |
|                                                 | 7.16.4 LP IO MUX Registers                          | 294     |

| 8 Reset and Clock                                                       |   304 |
|-------------------------------------------------------------------------|-------|
| 8.1 Reset                                                               |   304 |
| 8.1.1 Overview                                                          |   304 |
| 8.1.2 Architectural Overview                                            |   304 |
| 8.1.3 Features                                                          |   304 |
| 8.1.4 Functional Description                                            |   305 |
| 8.1.5 Peripheral Reset                                                  |   306 |
| 8.2 Clock                                                               |   306 |
| 8.2.1 Overview                                                          |   307 |
| 8.2.2 Architectural Overview                                            |   307 |
| 8.2.3 Features                                                          |   307 |
| 8.2.4 Functional Description                                            |   308 |
| 8.2.4.1 HP System Clock                                                 |   308 |
| 8.2.4.2 LP System Clock                                                 |   309 |
| 8.2.4.3 Peripheral Clocks                                               |   310 |
| 8.2.4.4 Wi-Fi and Bluetooth LE Clock                                    |   313 |
| 8.2.5 HP System Clock Gating Controlled by PMU                          |   313 |
| 8.3 Programming Procedures                                              |   315 |
| 8.3.1 HP System Clock Configuration                                     |   315 |
| 8.3.2 LP System Clock Configuration                                     |   316 |
| 8.3.3 Peripheral Clock Reset and Configuration                          |   316 |
| 8.4 Register Summary                                                    |   317 |
| 8.4.1 PCR Registers                                                     |   317 |
| 8.4.2 LP System Clock Registers                                         |   319 |
| 8.5 Registers                                                           |   320 |
| 8.5.1 PCR Registers                                                     |   320 |
| 8.5.2 LP Registers                                                      |   365 |
| 9 Chip Boot Control                                                     |   374 |
| 9.1 Overview                                                            |   374 |
| 9.2 Functional Description                                              |   374 |
| 9.2.1 Default Configuration                                             |   374 |
| 9.2.2 Boot Mode Control                                                 |   375 |
| 9.2.3 ROM Messages Printing Control                                     |   377 |
| 9.2.4 JTAG Signal Source Control                                        |   377 |
| 9.2.5 SDIO Sampling Input Edge and Output Driving Edge Control          |   378 |
| 10 Interrupt Matrix (INTMTX)                                            |   379 |
| 10.1 Overview                                                           |   379 |
| 10.2 Features                                                           |   379 |
| 10.3 Functional Description                                             |   380 |
| 10.3.1 Peripheral Interrupt Sources                                     |   380 |
| 10.3.2 CPU Interrupts                                                   |   384 |
| 10.3.3.1 Assign One Peripheral Interrupt Source (Source_X) to CPU       |   384 |
| 10.3.3.2 Assign Multiple Peripheral Interrupt Sources (Source_X) to CPU |   384 |

|                                                    | 10.3.3.3 Disable CPU Peripheral Interrupt Source (Source_X)          | 384   |
|----------------------------------------------------|----------------------------------------------------------------------|-------|
|                                                    | 10.3.4 Query Current Interrupt Status of Peripheral Interrupt Source | 385   |
|                                                    | 10.4 Register Summary                                                | 386   |
|                                                    | 10.4.1 Interrupt Matrix Register Summary                             | 386   |
|                                                    | 10.4.2 Interrupt Priority Register Summary                           | 388   |
| 10.5 Registers                                     | 10.5 Registers                                                       | 391   |
|                                                    | 10.5.1 Interrupt Matrix Registers                                    | 391   |
|                                                    | 10.5.2 Interrupt Priority Registers                                  | 394   |
| 11 Event Task Matrix (SOC_ETM)                     | 11 Event Task Matrix (SOC_ETM)                                       | 398   |
| 11.1 Overview                                      | 11.1 Overview                                                        | 398   |
| 11.2 Features                                      | 11.2 Features                                                        | 398   |
| 11.3 Functional Description                        | 11.3 Functional Description                                          | 398   |
|                                                    | 11.3.1 Architecture                                                  | 399   |
|                                                    | 11.3.2 Events                                                        | 400   |
| 11.3.3 Tasks                                       |                                                                      | 403   |
|                                                    | 11.3.4 Timing Considerations                                         | 406   |
| 11.3.5 Channel Control                             | 11.3.5 Channel Control                                               | 407   |
| 11.4 Register Summary                              | 11.4 Register Summary                                                | 412   |
| 11.5 Registers                                     | 11.5 Registers                                                       |       |
| 12 Low-Power Management                            | 12 Low-Power Management                                              | 416   |
| 12.1 Overview                                      | 12.1 Overview                                                        | 416   |
| 12.2 Terminology                                   | 12.2 Terminology                                                     | 416   |
| 12.3 Features                                      | 12.3 Features                                                        | 416   |
| 12.4 Functional Description                        | 12.4 Functional Description                                          | 417   |
| 12.4.1 Power Scheme                                | 12.4.1 Power Scheme                                                  | 418   |
|                                                    | 12.4.1.1 Regulators                                                  | 418   |
|                                                    | 12.4.1.2 Digital Power Domains                                       | 419   |
|                                                    | 12.4.1.3 Analog Power Domains                                        | 419   |
| 12.4.2 PMU                                         |                                                                      | 419   |
|                                                    | 12.4.2.1 PMU Main State Machine                                      | 420   |
|                                                    | 12.4.2.2 Sleep/Wake-up Controller                                    | 422   |
|                                                    | 12.4.2.3 Analog Power Controller                                     | 422   |
|                                                    | 12.4.2.4 Digital Power Controller                                    | 423   |
|                                                    | 12.4.2.5 Clock Controller                                            | 425   |
|                                                    | 12.4.2.6 Backup Controller                                           | 427   |
|                                                    | 12.4.2.7 System Controller                                           | 428   |
| 12.4.4 Brownout Detector                           | 12.4.4 Brownout Detector                                             | 429   |
| 12.5 Power Modes  12.6 RTC Boot                    | 12.5 Power Modes  12.6 RTC Boot                                      | 430   |
| 12.7 Event Task Matrix Feature                     | 12.7 Event Task Matrix Feature                                       |       |
|                                                    |                                                                      | 432   |
| 12.8 Interrupts                                    | 12.8 Interrupts                                                      | 433   |
| 12.9 Register Summary  12.9.1 PMU Register Summary | 12.9 Register Summary  12.9.1 PMU Register Summary                   | 435   |

|                                                                  | 12.9.2 Always-on Register Summary                                |   437 |
|------------------------------------------------------------------|------------------------------------------------------------------|-------|
|                                                                  | 12.9.3 RTC Timer Register Summary                                |   438 |
|                                                                  | 12.9.4 Brownout Detector Register Summary                        |   438 |
| 12.10 Registers                                                  | 12.10 Registers                                                  |   440 |
|                                                                  | 12.10.1 PMU Registers                                            |   440 |
|                                                                  | 12.10.2 Always-on Registers                                      |   479 |
|                                                                  | 12.10.3 RTC Timer Registers                                      |   482 |
|                                                                  | 12.10.4 Brownout Detector Registers                              |   490 |
| 13 System Timer (SYSTIMER)                                       | 13 System Timer (SYSTIMER)                                       |   496 |
| 13.1 Overview                                                    | 13.1 Overview                                                    |   496 |
| 13.2 Features                                                    | 13.2 Features                                                    |   496 |
| 13.3 Clock Source Selection                                      | 13.3 Clock Source Selection                                      |   497 |
| 13.4 Functional Description                                      | 13.4 Functional Description                                      |   497 |
|                                                                  | 13.4.1 Counter                                                   |   498 |
|                                                                  | 13.4.2 Comparator and Alarm                                      |   498 |
|                                                                  | 13.4.3 Event Task Matrix                                         |   499 |
|                                                                  | 13.4.4 Synchronization Operation                                 |   500 |
|                                                                  | 13.4.5 Interrupt                                                 |   501 |
| 13.5 Programming Procedure                                       | 13.5 Programming Procedure                                       |   501 |
|                                                                  | 13.5.1 Read Current Count Value                                  |   501 |
|                                                                  | 13.5.2 Configure One-Time Alarm in Target Mode                   |   501 |
|                                                                  | 13.5.3 Configure Periodic Alarms in Period Mode                  |   502 |
| 13.5.4 Update After Light-sleep                                  | 13.5.4 Update After Light-sleep                                  |   502 |
| 13.6 Register Summary                                            | 13.6 Register Summary                                            |   503 |
| 13.7 Registers                                                   | 13.7 Registers                                                   |   505 |
| 14 Timer Group (TIMG)                                            | 14 Timer Group (TIMG)                                            |   520 |
| 14.1 Overview                                                    | 14.1 Overview                                                    |   520 |
| 14.2 Features                                                    | 14.2 Features                                                    |   520 |
| 14.3 Functional Description                                      | 14.3 Functional Description                                      |   521 |
|                                                                  | 14.3.1 16-bit Prescaler and Clock Selection                      |   521 |
|                                                                  | 14.3.2 54-bit Time-base Counter                                  |   522 |
|                                                                  | 14.3.3 Alarm Generation                                          |   522 |
|                                                                  | 14.3.4 Timer Reload                                              |   523 |
|                                                                  | 14.3.5 Event Task Matrix Feature                                 |   523 |
|                                                                  | 14.3.6 RTC_SLOW_CLK Frequency Calculation                        |   524 |
| 14.3.7 Interrupts  14.4 Configuration and Usage                  | 14.3.7 Interrupts  14.4 Configuration and Usage                  |   525 |
|                                                                  | 14.4.1 Timer as a Simple Clock                                   |   525 |
|                                                                  | 14.4.2 Timer as One-shot Alarm                                   |   526 |
|                                                                  | 14.4.3 Timer as Periodic Alarm by APB                            |   526 |
|                                                                  | 14.4.4 Timer as Periodic Alarm by ETM                            |   527 |
| 14.4.5 RTC_SLOW_CLK Frequency Calculation  14.5 Register Summary | 14.4.5 RTC_SLOW_CLK Frequency Calculation  14.5 Register Summary |   529 |

| 15 Watchdog Timers (WDT)           | 15 Watchdog Timers (WDT)                           | 15 Watchdog Timers (WDT)                           |   545 |
|------------------------------------|----------------------------------------------------|----------------------------------------------------|-------|
| 15.1 Overview                      | 15.1 Overview                                      | 15.1 Overview                                      |   545 |
| 15.2 Digital Watchdog Timers       | 15.2 Digital Watchdog Timers                       | 15.2 Digital Watchdog Timers                       |   547 |
|                                    | 15.2.1 Features                                    | 15.2.1 Features                                    |   547 |
|                                    | 15.2.2 Functional Description                      | 15.2.2 Functional Description                      |   548 |
|                                    |                                                    | 15.2.2.1 Clock Source and 32-Bit Counter           |   548 |
|                                    |                                                    | 15.2.2.2 Stages and Timeout Actions                |   549 |
|                                    |                                                    | 15.2.2.3 Write Protection                          |   550 |
|                                    |                                                    | 15.2.2.4 Flash Boot Protection                     |   550 |
| 15.3 Super Watchdog                | 15.3 Super Watchdog                                | 15.3 Super Watchdog                                |   550 |
|                                    | 15.3.1 Features                                    | 15.3.1 Features                                    |   550 |
|                                    | 15.3.2 Super Watchdog Controller                   | 15.3.2 Super Watchdog Controller                   |   551 |
|                                    |                                                    | 15.3.2.1 Structure                                 |   551 |
|                                    |                                                    | 15.3.2.2 Workflow                                  |   551 |
| 15.4 Interrupts                    | 15.4 Interrupts                                    | 15.4 Interrupts                                    |   551 |
| 15.5 Register Summary              | 15.5 Register Summary                              | 15.5 Register Summary                              |   552 |
| 15.6 Registers                     | 15.6 Registers                                     | 15.6 Registers                                     |   552 |
| 16 Permission Control (PMS)        | 16 Permission Control (PMS)                        | 16 Permission Control (PMS)                        |   561 |
| 16.1 Overview                      | 16.1 Overview                                      | 16.1 Overview                                      |   561 |
| 16.2 Features                      | 16.2 Features                                      | 16.2 Features                                      |   562 |
| 16.3 Functional Description        | 16.3 Functional Description                        | 16.3 Functional Description                        |   563 |
|                                    | 16.3.1 TEE Controller Functional Description       | 16.3.1 TEE Controller Functional Description       |   563 |
|                                    | 16.3.2 APM Controller Functional Description       | 16.3.2 APM Controller Functional Description       |   563 |
|                                    |                                                    | 16.3.2.1 Architecture                              |   563 |
|                                    |                                                    | 16.3.2.2 Address Ranges                            |   565 |
|                                    |                                                    | 16.3.2.3 Access Permissions of Address Ranges      |   565 |
| 16.4 Programming Procedure         | 16.4 Programming Procedure                         | 16.4 Programming Procedure                         |   566 |
| 16.5 Illegal access and interrupts | 16.5 Illegal access and interrupts                 | 16.5 Illegal access and interrupts                 |   567 |
| 16.6 Register Summary              | 16.6 Register Summary                              | 16.6 Register Summary                              |   568 |
|                                    | 16.6.1 High Performance APM Registers (HP_APM_REG) | 16.6.1 High Performance APM Registers (HP_APM_REG) |   568 |
|                                    | 16.6.2 Low Power APM Registers (LP_APM_REG)        | 16.6.2 Low Power APM Registers (LP_APM_REG)        |   569 |
|                                    | 16.6.3 Low Power APM0 Registers (LP_APM0_REG)      | 16.6.3 Low Power APM0 Registers (LP_APM0_REG)      |   570 |
|                                    | 16.6.4 High Performance TEE Registers              | 16.6.4 High Performance TEE Registers              |   571 |
|                                    | 16.6.5 Low Power TEE Registers                     | 16.6.5 Low Power TEE Registers                     |   571 |
| 16.7 Registers                     | 16.7 Registers                                     | 16.7 Registers                                     |   573 |
|                                    | 16.7.1 High Performance APM Registers (HP_APM_REG) | 16.7.1 High Performance APM Registers (HP_APM_REG) |   573 |
|                                    | 16.7.2 Low Power APM Registers (LP_APM_REG)        | 16.7.2 Low Power APM Registers (LP_APM_REG)        |   581 |
|                                    | 16.7.3 Low Power APM0 Registers (LP_APM0_REG)      | 16.7.3 Low Power APM0 Registers (LP_APM0_REG)      |   588 |
|                                    | 16.7.4 High Performance TEE Registers              | 16.7.4 High Performance TEE Registers              |   592 |
|                                    | 16.7.5 Low Power TEE Registers                     | 16.7.5 Low Power TEE Registers                     |   593 |
| 17 System Registers                | 17 System Registers                                | 17 System Registers                                |   595 |
| 17.1 Overview                      | 17.1 Overview                                      | 17.1 Overview                                      |   595 |
| 17.2 Features                      | 17.2 Features                                      | 17.2 Features                                      |   595 |
| 17.3 Function Description          | 17.3 Function Description                          | 17.3 Function Description                          |   595 |

| Contents                                                   |                                                            |                                                            | GoBack   |
|------------------------------------------------------------|------------------------------------------------------------|------------------------------------------------------------|----------|
| 17.3.1 External Memory Encryption/Decryption Configuration | 17.3.1 External Memory Encryption/Decryption Configuration | 17.3.1 External Memory Encryption/Decryption Configuration | 595      |
| 17.3.2 Anti-DPA Attack Security Control                    | 17.3.2 Anti-DPA Attack Security Control                    | 17.3.2 Anti-DPA Attack Security Control                    | 595      |
| 17.3.3 HP Core/LP Core Debug Control                       | 17.3.3 HP Core/LP Core Debug Control                       | 17.3.3 HP Core/LP Core Debug Control                       | 596      |
| 17.3.4 Bus Timeout Protection                              | 17.3.4 Bus Timeout Protection                              | 17.3.4 Bus Timeout Protection                              | 596      |
|                                                            |                                                            | 17.3.4.1 CPU Peripheral Timeout Protection Register        | 596      |
|                                                            |                                                            | 17.3.4.2 HP Peripheral Timeout Protection Register         | 597      |
| 17.3.4.3 LP Peripheral Timeout Protection Register         | 17.3.4.3 LP Peripheral Timeout Protection Register         | 17.3.4.3 LP Peripheral Timeout Protection Register         | 597      |
| 17.4 Register Summary                                      | 17.4 Register Summary                                      | 17.4 Register Summary                                      | 598      |
| 17.5 Registers                                             | 17.5 Registers                                             | 17.5 Registers                                             | 599      |
| 18 Debug Assistant (ASSIST_DEBUG)                          | 18 Debug Assistant (ASSIST_DEBUG)                          | 18 Debug Assistant (ASSIST_DEBUG)                          | 606      |
| 18.1 Overview                                              | 18.1 Overview                                              | 18.1 Overview                                              | 606      |
| 18.2 Features                                              | 18.2 Features                                              | 18.2 Features                                              | 606      |
| 18.3 Functional Description                                | 18.3 Functional Description                                | 18.3 Functional Description                                | 606      |
| 18.3.1 Region Read/Write Monitoring                        | 18.3.1 Region Read/Write Monitoring                        | 18.3.1 Region Read/Write Monitoring                        | 606      |
|                                                            | 18.3.2 SP Monitoring                                       | 18.3.2 SP Monitoring                                       | 606      |
|                                                            | 18.3.3 PC Logging                                          | 18.3.3 PC Logging                                          | 607      |
|                                                            | 18.3.4 CPU/DMA Bus Access Logging                          | 18.3.4 CPU/DMA Bus Access Logging                          | 607      |
| 18.4 Recommended Operation                                 | 18.4 Recommended Operation                                 | 18.4 Recommended Operation                                 | 607      |
|                                                            | 18.4.1 Region Monitoring and SP Monitoring Configuration   | 18.4.1 Region Monitoring and SP Monitoring Configuration   | 607      |
|                                                            | 18.4.2 PC Logging Configuration                            | 18.4.2 PC Logging Configuration                            | 609      |
|                                                            | 18.4.3 CPU/DMA Bus Access Logging Configuration            | 18.4.3 CPU/DMA Bus Access Logging Configuration            | 609      |
| 18.5 Register Summary                                      | 18.5 Register Summary                                      | 18.5 Register Summary                                      | 613      |
|                                                            | 18.5.1 Summary of Bus Logging Configuration Registers      | 18.5.1 Summary of Bus Logging Configuration Registers      | 613      |
|                                                            | 18.5.2 Summary of Other Registers                          | 18.5.2 Summary of Other Registers                          | 613      |
| 18.6 Registers                                             | 18.6 Registers                                             | 18.6 Registers                                             | 616      |
|                                                            | 18.6.1 Bus Logging Configuration Registers                 | 18.6.1 Bus Logging Configuration Registers                 | 617      |
|                                                            | 18.6.2 Other Registers                                     | 18.6.2 Other Registers                                     | 623      |
| IV Cryptography/Security Component                         | IV Cryptography/Security Component                         | IV Cryptography/Security Component                         | 638      |
| 19 AES Accelerator (AES)                                   | 19 AES Accelerator (AES)                                   | 19 AES Accelerator (AES)                                   | 639      |
| 19.1 Introduction                                          | 19.1 Introduction                                          | 19.1 Introduction                                          | 639      |
| 19.2 Features                                              | 19.2 Features                                              | 19.2 Features                                              | 639      |
| 19.3 AES Working Modes                                     | 19.3 AES Working Modes                                     | 19.3 AES Working Modes                                     | 639      |
| 19.4 Typical AES Working Mode                              | 19.4 Typical AES Working Mode                              | 19.4 Typical AES Working Mode                              | 641      |
| 19.4.2 Endianness                                          | 19.4.1 Key, Plaintext, and Ciphertext                      | 19.4.1 Key, Plaintext, and Ciphertext                      | 641      |
|                                                            | 19.4.3 Operation Process                                   | 19.4.3 Operation Process                                   | 643      |
| 19.5 DMA-AES Working Mode                                  | 19.5 DMA-AES Working Mode                                  | 19.5 DMA-AES Working Mode                                  | 643      |
|                                                            | 19.5.1 Key, Plaintext, and Ciphertext                      | 19.5.1 Key, Plaintext, and Ciphertext                      | 645      |
|                                                            | 19.5.2 Endianness                                          | 19.5.2 Endianness                                          | 645      |
|                                                            | 19.5.3 Standard Incrementing Function                      | 19.5.3 Standard Incrementing Function                      | 646      |
| 19.5.5 Initialization Vector                               |                                                            |                                                            | 646 646  |
|                                                            | 19.5.4 Block Number                                        | 19.5.4 Block Number                                        |          |
|                                                            | 19.5.6 Block Operation Process                             | 19.5.6 Block Operation Process                             | 647      |

| 19.6 Memory Summary                             |                                                                           |                                                                                          | 647   |
|-------------------------------------------------|---------------------------------------------------------------------------|------------------------------------------------------------------------------------------|-------|
| 19.7 Register Summary                           | 19.7 Register Summary                                                     | 19.7 Register Summary                                                                    | 648   |
| 19.8 Registers                                  | 19.8 Registers                                                            | 19.8 Registers                                                                           | 649   |
| 20 ECC Accelerator (ECC)                        | 20 ECC Accelerator (ECC)                                                  | 20 ECC Accelerator (ECC)                                                                 | 654   |
| 20.1 Introduction                               | 20.1 Introduction                                                         | 20.1 Introduction                                                                        | 654   |
| 20.2 Features                                   | 20.2 Features                                                             | 20.2 Features                                                                            | 654   |
| 20.3 Terminology                                | 20.3 Terminology                                                          | 20.3 Terminology                                                                         | 654   |
|                                                 | 20.3.1 ECC Basics                                                         | 20.3.1 ECC Basics                                                                        | 654   |
|                                                 |                                                                           | 20.3.1.1 Elliptic Curve and Points on the Curves                                         | 654   |
|                                                 |                                                                           | 20.3.1.2 Affine Coordinates and Jacobian Coordinates                                     | 654   |
|                                                 | 20.3.2 Definitions of ESP32-C6’s ECC                                      | 20.3.2 Definitions of ESP32-C6’s ECC                                                     | 655   |
|                                                 |                                                                           | 20.3.2.1 Memory Blocks                                                                   | 655   |
|                                                 |                                                                           | 20.3.2.2 Data and Data Block                                                             | 655   |
|                                                 |                                                                           | 20.3.2.3 Write Data                                                                      | 655   |
|                                                 |                                                                           | 20.3.2.4 Read Data                                                                       | 656   |
|                                                 |                                                                           | 20.3.2.5 Standard Calculation and Jacobian Calculation                                   | 656   |
| 20.4 Function Description                       | 20.4 Function Description                                                 | 20.4 Function Description                                                                | 656   |
| 20.4.1 Key Size                                 |                                                                           |                                                                                          | 656   |
|                                                 | 20.4.2 Working Modes                                                      | 20.4.2 Working Modes                                                                     | 657   |
|                                                 |                                                                           | 20.4.2.1 Base Point Multiplication (Point Multi Mode)                                    | 657   |
|                                                 |                                                                           | 20.4.2.2 Base Point Verification (Point Verif Mode)                                      | 657   |
|                                                 |                                                                           | 20.4.2.3 Base Point Verification + Base Point Multiplication (Point Verif + Multi Mode)  | 657   |
|                                                 |                                                                           | 20.4.2.4 Jacobian Point Multiplication (Jacobian Point Multi Mode)                       | 658   |
|                                                 |                                                                           | 20.4.2.5 Jacobian Point Verification (Jacobian Point Verif Mode)                         | 658   |
|                                                 |                                                                           | 20.4.2.6 Base Point Verification + Jacobian Point Multiplication (Point Verif + Jacobian |       |
|                                                 |                                                                           | Point Multi Mode)                                                                        | 658   |
| 20.5 Clocks and Resets                          | 20.5 Clocks and Resets                                                    | 20.5 Clocks and Resets                                                                   | 658   |
| 20.6 Interrupts                                 | 20.6 Interrupts                                                           | 20.6 Interrupts                                                                          | 659   |
| 20.7 Programming Procedures                     | 20.7 Programming Procedures                                               | 20.7 Programming Procedures                                                              | 659   |
| 20.8 Register Summary                           | 20.8 Register Summary                                                     | 20.8 Register Summary                                                                    | 660   |
| 20.9 Registers                                  | 20.9 Registers                                                            | 20.9 Registers                                                                           |       |
| 21 HMAC Accelerator (HMAC)                      | 21 HMAC Accelerator (HMAC)                                                | 21 HMAC Accelerator (HMAC)                                                               | 665   |
| 21.1 Main Features  21.2 Functional Description | 21.1 Main Features  21.2 Functional Description                           | 21.1 Main Features  21.2 Functional Description                                          | 665   |
|                                                 | 21.2.1 Upstream Mode                                                      | 21.2.1 Upstream Mode                                                                     | 665   |
|                                                 | 21.2.2 Downstream JTAG Enable Mode                                        | 21.2.2 Downstream JTAG Enable Mode                                                       | 666   |
|                                                 | 21.2.3 Downstream Digital Signature Mode  21.2.4 HMAC eFuse Configuration | 21.2.3 Downstream Digital Signature Mode  21.2.4 HMAC eFuse Configuration                | 666   |
|                                                 |                                                                           |                                                                                          | 667   |
|                                                 | 21.2.5 HMAC Process (Detailed)                                            | 21.2.5 HMAC Process (Detailed)                                                           | 668   |
| 21.3 HMAC Algorithm Details                     | 21.3 HMAC Algorithm Details                                               | 21.3 HMAC Algorithm Details                                                              | 669   |
|                                                 | 21.3.1 Padding Bits                                                       | 21.3.1 Padding Bits                                                                      | 670   |
|                                                 | 21.3.2 HMAC Algorithm Structure                                           | 21.3.2 HMAC Algorithm Structure                                                          | 670   |
| 21.4 Register Summary                           | 21.4 Register Summary                                                     | 21.4 Register Summary                                                                    | 673   |
| 21.5 Registers                                  | 21.5 Registers                                                            | 21.5 Registers                                                                           | 675   |

| 22 RSA Accelerator (RSA)                                   | 22 RSA Accelerator (RSA)                                   | 22 RSA Accelerator (RSA)                                   | 682   |
|------------------------------------------------------------|------------------------------------------------------------|------------------------------------------------------------|-------|
| 22.1 Introduction                                          | 22.1 Introduction                                          | 22.1 Introduction                                          | 682   |
| 22.2 Features                                              | 22.2 Features                                              | 22.2 Features                                              | 682   |
| 22.3 Functional Description                                | 22.3 Functional Description                                | 22.3 Functional Description                                | 682   |
| 22.3.1 Large-number Modular Exponentiation                 | 22.3.1 Large-number Modular Exponentiation                 | 22.3.1 Large-number Modular Exponentiation                 | 683   |
| 22.3.2 Large-number Modular Multiplication                 | 22.3.2 Large-number Modular Multiplication                 | 22.3.2 Large-number Modular Multiplication                 | 684   |
| 22.3.3 Large-number Multiplication                         | 22.3.3 Large-number Multiplication                         | 22.3.3 Large-number Multiplication                         | 685   |
| 22.3.4 Options for Additional Acceleration                 | 22.3.4 Options for Additional Acceleration                 | 22.3.4 Options for Additional Acceleration                 | 685   |
| 22.4 Memory Summary                                        | 22.4 Memory Summary                                        | 22.4 Memory Summary                                        | 688   |
| 22.5 Register Summary                                      | 22.5 Register Summary                                      | 22.5 Register Summary                                      | 688   |
| 22.6 Registers                                             | 22.6 Registers                                             | 22.6 Registers                                             | 689   |
| 23 SHA Accelerator (SHA)                                   | 23 SHA Accelerator (SHA)                                   | 23 SHA Accelerator (SHA)                                   | 693   |
| 23.1 Introduction                                          | 23.1 Introduction                                          | 23.1 Introduction                                          | 693   |
| 23.2 Features                                              | 23.2 Features                                              | 23.2 Features                                              | 693   |
| 23.3 Working Modes                                         | 23.3 Working Modes                                         | 23.3 Working Modes                                         | 693   |
| 23.4 Function Description                                  | 23.4 Function Description                                  | 23.4 Function Description                                  | 695   |
| 23.4.1 Preprocessing                                       | 23.4.1 Preprocessing                                       | 23.4.1 Preprocessing                                       | 695   |
|                                                            |                                                            | 23.4.1.1 Padding the Message                               | 695   |
|                                                            |                                                            | 23.4.1.2 Parsing the Message                               | 695   |
|                                                            |                                                            | 23.4.1.3 Setting the Initial Hash Value                    | 696   |
|                                                            | 23.4.2 Hash Operation                                      | 23.4.2 Hash Operation                                      | 696   |
|                                                            |                                                            | 23.4.2.1 Typical SHA Mode Process                          | 696   |
|                                                            |                                                            | 23.4.2.2 DMA-SHA Mode Process                              | 697   |
| 23.4.3 Message Digest                                      | 23.4.3 Message Digest                                      | 23.4.3 Message Digest                                      | 698   |
| 23.5 Register Summary                                      | 23.5 Register Summary                                      | 23.5 Register Summary                                      | 700   |
| 23.6 Registers                                             | 23.6 Registers                                             | 23.6 Registers                                             | 701   |
| 24 Digital Signature (DS)                                  | 24 Digital Signature (DS)                                  | 24 Digital Signature (DS)                                  | 705   |
| 24.2 Features                                              | 24.2 Features                                              | 24.2 Features                                              | 705   |
|                                                            |                                                            |                                                            | 705   |
| 24.3 Functional Description                                | 24.3 Functional Description                                | 24.3 Functional Description                                | 705   |
|                                                            | 24.3.1 Overview                                            | 24.3.1 Overview                                            | 705   |
|                                                            | 24.3.2 Private Key Operands                                | 24.3.2 Private Key Operands                                | 706   |
|                                                            | 24.3.3 Software Prerequisites                              | 24.3.3 Software Prerequisites                              |       |
|                                                            | 24.3.4 DS Operation at the Hardware Level                  | 24.3.4 DS Operation at the Hardware Level                  | 708   |
|                                                            |                                                            |                                                            | 711   |
| 24.4 Memory Summary                                        | 24.4 Memory Summary                                        | 24.4 Memory Summary                                        | 712   |
| 24.5 Register Summary                                      | 24.5 Register Summary                                      | 24.5 Register Summary                                      |       |
| 24.6 Registers                                             | 24.6 Registers                                             | 24.6 Registers                                             | 713   |
| 25 External Memory Encryption and Decryption (XTS_AES) 716 | 25 External Memory Encryption and Decryption (XTS_AES) 716 | 25 External Memory Encryption and Decryption (XTS_AES) 716 |       |
| 25.1 Overview                                              | 25.1 Overview                                              | 25.1 Overview                                              | 716   |
| 25.3 Module Structure                                      | 25.3 Module Structure                                      | 25.3 Module Structure                                      | 716   |

| 25.4 Functional Description               | 25.4 Functional Description               | 717   |
|-------------------------------------------|-------------------------------------------|-------|
| 25.4.1 XTS Algorithm                      | 25.4.1 XTS Algorithm                      | 717   |
| 25.4.2 Key                                | 25.4.2 Key                                | 718   |
| 25.4.3 Target Memory Space                | 25.4.3 Target Memory Space                | 718   |
| 25.4.4 Data Writing                       | 25.4.4 Data Writing                       | 719   |
| 25.4.5 Manual Encryption Block            | 25.4.5 Manual Encryption Block            | 719   |
| 25.4.6 Auto Decryption Block              | 25.4.6 Auto Decryption Block              | 720   |
| 25.5 Software Process                     | 25.5 Software Process                     | 720   |
| 25.6 Anti-DPA                             | 25.6 Anti-DPA                             | 721   |
| 25.7 Register Summary                     | 25.7 Register Summary                     | 723   |
| 25.8 Registers                            | 25.8 Registers                            | 724   |
| 26 Random Number Generator (RNG)          | 26 Random Number Generator (RNG)          | 729   |
| 26.1 Introduction                         | 26.1 Introduction                         | 729   |
| 26.2 Features                             | 26.2 Features                             | 729   |
| 26.3 Functional Description               | 26.3 Functional Description               | 729   |
| 26.4 Programming Procedure                | 26.4 Programming Procedure                | 730   |
| 26.5 Register Summary                     | 26.5 Register Summary                     | 730   |
| 26.6 Register                             | 26.6 Register                             | 731   |
| V Connectivity Interface                  | V Connectivity Interface                  | 732   |
| 27 UART Controller (UART, LP_UART, UHCI)  | 27 UART Controller (UART, LP_UART, UHCI)  | 733   |
| 27.1 Overview                             | 27.1 Overview                             | 733   |
| 27.2 Features                             | 27.2 Features                             | 733   |
| 27.3 UART Structure                       | 27.3 UART Structure                       | 734   |
| 27.4 Functional Description               | 27.4 Functional Description               | 735   |
| 27.4.1 Clock and Reset                    | 27.4.1 Clock and Reset                    | 735   |
| 27.4.2 UART FIFO                          | 27.4.2 UART FIFO                          | 736   |
| 27.4.3 Baud Rate Generation and Detection | 27.4.3 Baud Rate Generation and Detection | 737   |
|                                           | 27.4.3.1 Baud Rate Generation             | 737   |
|                                           | 27.4.3.2 Baud Rate Detection              | 738   |
| 27.4.4 UART Data Frame                    | 27.4.4 UART Data Frame                    | 739   |
| 27.4.5 AT_CMD Character Structure         | 27.4.5 AT_CMD Character Structure         | 739   |
| 27.4.6 RS485                              | 27.4.6 RS485                              | 740   |
|                                           | 27.4.6.1 Driver Control                   | 740   |
|                                           | 27.4.6.2 Turnaround Delay                 | 741   |
|                                           | 27.4.6.3 Bus Snooping                     | 741   |
| 27.4.7 IrDA                               | 27.4.7 IrDA                               | 741   |
|                                           | 27.4.8 Wake-up                            | 742   |
| 27.4.9 Flow Control                       | 27.4.9 Flow Control                       |       |
| 27.4.9.1 Hardware Flow Control            | 27.4.9.1 Hardware Flow Control            | 744   |
|                                           | 27.4.9.2 Software Flow Control            | 745   |
| 27.4.10 GDMA Mode                         | 27.4.10 GDMA Mode                         | 746   |
| 27.4.11 UART Interrupts                   | 27.4.11 UART Interrupts                   | 747   |

|                                                                | 27.5 Programming Procedures                                    |   748 |
|----------------------------------------------------------------|----------------------------------------------------------------|-------|
| 27.5.1 Register Type                                           | 27.5.1 Register Type                                           |   748 |
| 27.5.2 Detailed Steps                                          | 27.5.2 Detailed Steps                                          |   748 |
| 27.5.2.1 Initializing UARTn                                    | 27.5.2.1 Initializing UARTn                                    |   749 |
| 27.5.2.2 Configuring UARTn Communication                       | 27.5.2.2 Configuring UARTn Communication                       |   749 |
| 27.5.2.3 Enabling UARTn                                        | 27.5.2.3 Enabling UARTn                                        |   750 |
|                                                                | 27.6 Register Summary                                          |   751 |
| 27.6.1 UART Register Summary                                   | 27.6.1 UART Register Summary                                   |   751 |
| 27.6.2 LP UART Register Summary                                | 27.6.2 LP UART Register Summary                                |   752 |
| 27.6.3 UHCI Register Summary                                   | 27.6.3 UHCI Register Summary                                   |   753 |
|                                                                | 27.7 Registers                                                 |   755 |
| 27.7.1 UART Registers                                          | 27.7.1 UART Registers                                          |   755 |
| 27.7.2 LP UART Registers                                       | 27.7.2 LP UART Registers                                       |   777 |
| 27.7.3 UHCI Registers                                          | 27.7.3 UHCI Registers                                          |   797 |
|                                                                | 28 SPI Controller (SPI)                                        |   820 |
|                                                                | 28.1 Overview                                                  |   820 |
|                                                                | 28.2 Glossary                                                  |   820 |
|                                                                | 28.3 Features                                                  |   821 |
|                                                                | 28.4 Architectural Overview                                    |   822 |
|                                                                | 28.5 Functional Description                                    |   823 |
| 28.5.1 Data Modes                                              | 28.5.1 Data Modes                                              |   823 |
| 28.5.2 Introduction to FSPI Bus Signals                        | 28.5.2 Introduction to FSPI Bus Signals                        |   824 |
| 28.5.3 Bit Read/Write Order Control                            | 28.5.3 Bit Read/Write Order Control                            |   826 |
| 28.5.4 Transfer Types                                          | 28.5.4 Transfer Types                                          |   828 |
| 28.5.5 CPU-Controlled Data Transfer                            | 28.5.5 CPU-Controlled Data Transfer                            |   828 |
| 28.5.5.1 CPU-Controlled Master Transfer                        | 28.5.5.1 CPU-Controlled Master Transfer                        |   828 |
| 28.5.5.2 CPU-Controlled Slave Transfer                         | 28.5.5.2 CPU-Controlled Slave Transfer                         |   831 |
| 28.5.6 DMA-Controlled Data Transfer                            | 28.5.6 DMA-Controlled Data Transfer                            |   831 |
| 28.5.6.1 GDMA Configuration                                    | 28.5.6.1 GDMA Configuration                                    |   832 |
| 28.5.6.2 GDMA TX/RX Buffer Length Control                      | 28.5.6.2 GDMA TX/RX Buffer Length Control                      |   832 |
|                                                                | 28.5.7 Data Flow Control                                       |   833 |
| 28.5.7.1 GP-SPI2 Functional Blocks                             | 28.5.7.1 GP-SPI2 Functional Blocks                             |   833 |
| 28.5.7.2 Data Flow Control as Master                           | 28.5.7.2 Data Flow Control as Master                           |   834 |
| 28.5.7.3 Data Flow Control as Slave                            | 28.5.7.3 Data Flow Control as Slave                            |   835 |
|                                                                | 28.5.8 GP-SPI2 as a Master                                     |   836 |
| 28.5.8.1 State Machine                                         | 28.5.8.1 State Machine                                         |   836 |
| 28.5.8.2 Register Configuration for State and Bit Mode Control | 28.5.8.2 Register Configuration for State and Bit Mode Control |   838 |
| 28.5.8.3 Full-Duplex Communication (1-bit Mode Only)           | 28.5.8.3 Full-Duplex Communication (1-bit Mode Only)           |   841 |
| 28.5.8.4 Half-Duplex Communication (1/2/4-bit Mode)            | 28.5.8.4 Half-Duplex Communication (1/2/4-bit Mode)            |   842 |
| 28.5.8.5 DMA-Controlled Configurable Segmented Transfer        | 28.5.8.5 DMA-Controlled Configurable Segmented Transfer        |   844 |
|                                                                | 28.5.9 GP-SPI2 Works as a Slave                                |   847 |
|                                                                | 28.5.9.1 Communication Formats                                 |   848 |
|                                                                | 28.5.9.2 Supported CMD Values in Half-Duplex Communication     |   849 |
|                                                                | 28.5.9.3 Slave Single Transfer and Slave Segmented Transfer    |   851 |
|                                                                | 28.5.9.4 Configuration of Slave Single Transfer                |   852 |

|                                                                                         |                                                                                         | 28.5.9.5 Configuration of Slave Segmented Transfer in Half-Duplex                       | 852   |
|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------|-------|
|                                                                                         |                                                                                         | 28.5.9.6 Configuration of Slave Segmented Transfer in Full-Duplex                       | 853   |
| 28.6 CS Setup Time and Hold Time Control                                                | 28.6 CS Setup Time and Hold Time Control                                                | 28.6 CS Setup Time and Hold Time Control                                                | 853   |
| 28.7 GP-SPI2 Clock Control                                                              | 28.7 GP-SPI2 Clock Control                                                              | 28.7 GP-SPI2 Clock Control                                                              | 854   |
|                                                                                         | 28.7.1 Clock Phase and Polarity                                                         | 28.7.1 Clock Phase and Polarity                                                         | 855   |
|                                                                                         | 28.7.2 Clock Control as Master                                                          | 28.7.2 Clock Control as Master                                                          | 857   |
|                                                                                         | 28.7.3 Clock Control as Slave                                                           | 28.7.3 Clock Control as Slave                                                           | 857   |
| 28.8 GP-SPI2 Timing Compensation                                                        | 28.8 GP-SPI2 Timing Compensation                                                        | 28.8 GP-SPI2 Timing Compensation                                                        | 857   |
| 28.9 Interrupts                                                                         | 28.9 Interrupts                                                                         | 28.9 Interrupts                                                                         | 859   |
| 28.10 Register Summary                                                                  | 28.10 Register Summary                                                                  | 28.10 Register Summary                                                                  | 862   |
| 28.11 Registers                                                                         | 28.11 Registers                                                                         | 28.11 Registers                                                                         | 863   |
| 29 I2C Controller (I2C)                                                                 | 29 I2C Controller (I2C)                                                                 | 29 I2C Controller (I2C)                                                                 | 893   |
| 29.1 Overview                                                                           | 29.1 Overview                                                                           | 29.1 Overview                                                                           | 893   |
| 29.2 Features                                                                           | 29.2 Features                                                                           | 29.2 Features                                                                           | 893   |
| 29.3 I2C Architecture                                                                   | 29.3 I2C Architecture                                                                   | 29.3 I2C Architecture                                                                   | 894   |
| 29.4 Functional Description                                                             | 29.4 Functional Description                                                             | 29.4 Functional Description                                                             | 896   |
| 29.4.1 Clock Configuration                                                              | 29.4.1 Clock Configuration                                                              | 29.4.1 Clock Configuration                                                              | 896   |
|                                                                                         | 29.4.2 SCL and SDA Noise Filtering                                                      | 29.4.2 SCL and SDA Noise Filtering                                                      | 897   |
|                                                                                         | 29.4.3 SCL Clock Stretching                                                             | 29.4.3 SCL Clock Stretching                                                             | 897   |
|                                                                                         | 29.4.4 Generating SCL Pulses in Idle State                                              | 29.4.4 Generating SCL Pulses in Idle State                                              | 897   |
|                                                                                         | 29.4.5 Synchronization                                                                  | 29.4.5 Synchronization                                                                  | 898   |
|                                                                                         | 29.4.6 Open-Drain Output                                                                | 29.4.6 Open-Drain Output                                                                | 899   |
|                                                                                         | 29.4.7 Timing Parameter Configuration                                                   | 29.4.7 Timing Parameter Configuration                                                   | 900   |
|                                                                                         | 29.4.8 Timeout Control                                                                  | 29.4.8 Timeout Control                                                                  | 902   |
|                                                                                         | 29.4.9 Command Configuration                                                            | 29.4.9 Command Configuration                                                            | 902   |
|                                                                                         | 29.4.10 TX/RX RAM Data Storage                                                          | 29.4.10 TX/RX RAM Data Storage                                                          | 903   |
|                                                                                         | 29.4.11 Data Conversion                                                                 | 29.4.11 Data Conversion                                                                 | 904   |
|                                                                                         | 29.4.12 Addressing Mode                                                                 | 29.4.12 Addressing Mode                                                                 | 904   |
|                                                                                         | 29.4.13 R/W Bit Check in 10-bit Addressing Mode                                         | 29.4.13 R/W Bit Check in 10-bit Addressing Mode                                         | 905   |
| 29.4.14 To Start the I2C Controller  29.5 Functional differences between LP_I2C and I2C | 29.4.14 To Start the I2C Controller  29.5 Functional differences between LP_I2C and I2C | 29.4.14 To Start the I2C Controller  29.5 Functional differences between LP_I2C and I2C | 905   |
|                                                                                         |                                                                                         |                                                                                         | 905   |
| 29.6 Programming Example                                                                | 29.6 Programming Example                                                                | 29.6 Programming Example                                                                | 906   |
|                                                                                         |                                                                                         | 29.6.1.1 Introduction                                                                   | 906   |
|                                                                                         | 29.6.2 I2C master                                                                       | Writes to I2C slave  with a 10-bit Address in One Command Sequence                      | 908   |
|                                                                                         |                                                                                         | 29.6.2.1 Introduction                                                                   | 908   |
|                                                                                         |                                                                                         | 29.6.2.2 Configuration Example                                                          | 908   |
| 29.6.3 I2C                                                                              | master                                                                                  | Writes to I2C slave  with Two 7-bit Addresses in One Command Sequence                   | 909   |
|                                                                                         |                                                                                         | 29.6.3.1 Introduction                                                                   | 910   |
|                                                                                         |                                                                                         | 29.6.3.2 Configuration Example                                                          | 910   |
|                                                                                         |                                                                                         |                                                                                         | 912   |
|                                                                                         |                                                                                         | 29.6.4.1 Introduction                                                                   | 913   |
|                                                                                         |                                                                                         | 29.6.4.2 Configuration Example                                                          |       |
| 29.6.5 I2C master                                                                       | Reads I2C slave                                                                         | with a 7-bit Address in One Command Sequence                                            | 914   |

|                                              | 29.6.5.1 Introduction                                                       |   914 |
|----------------------------------------------|-----------------------------------------------------------------------------|-------|
|                                              | 29.6.5.2 Configuration Example                                              |   915 |
| 29.6.6 I2C master                            | Reads I2C slave  with a 10-bit Address in One Command Sequence              |   916 |
|                                              | 29.6.6.1 Introduction                                                       |   917 |
|                                              | 29.6.6.2 Configuration Example                                              |   917 |
| 29.6.7 I2C master                            | Reads I2C slave  with Two 7-bit Addresses in One Command Sequence           |   919 |
|                                              | 29.6.7.1 Introduction                                                       |   919 |
|                                              | 29.6.7.2 Configuration Example                                              |   920 |
| 29.6.8 I2C                                   | master  Reads I2C slave  with a 7-bit Address in Multiple Command Sequences |   921 |
|                                              | 29.6.8.1 Introduction                                                       |   922 |
|                                              | 29.6.8.2 Configuration Example                                              |   923 |
| 29.7 Interrupts                              | 29.7 Interrupts                                                             |   925 |
| 29.8 Register Summary                        | 29.8 Register Summary                                                       |   926 |
| 29.9 I2C Register Summary                    | 29.9 I2C Register Summary                                                   |   926 |
| 29.10 LP_I2C Register Summary                | 29.10 LP_I2C Register Summary                                               |   927 |
| 29.11 I2C Registers                          | 29.11 I2C Registers                                                         |   929 |
| 29.11.1 LP_I2C Register                      | 29.11.1 LP_I2C Register                                                     |   952 |
| 30 I2S Controller (I2S)                      | 30 I2S Controller (I2S)                                                     |   974 |
| 30.1 Overview                                | 30.1 Overview                                                               |   974 |
| 30.2 Terminology                             | 30.2 Terminology                                                            |   974 |
| 30.3 Features                                | 30.3 Features                                                               |   975 |
| 30.4 System Architecture                     | 30.4 System Architecture                                                    |   976 |
| 30.5 Supported Audio Standards               | 30.5 Supported Audio Standards                                              |   977 |
| 30.5.1 TDM Philips Standard                  | 30.5.1 TDM Philips Standard                                                 |   978 |
| 30.5.2 TDM MSB Alignment Standard            | 30.5.2 TDM MSB Alignment Standard                                           |   978 |
| 30.5.3 TDM PCM Standard                      | 30.5.3 TDM PCM Standard                                                     |   979 |
| 30.5.4 PDM Standard                          | 30.5.4 PDM Standard                                                         |   979 |
| 30.6 I2S TX/RX Clock                         | 30.6 I2S TX/RX Clock                                                        |   980 |
| 30.7 I2S Reset                               | 30.7 I2S Reset                                                              |   982 |
| 30.8 I2S Master/Slave Mode                   | 30.8 I2S Master/Slave Mode                                                  |   982 |
| 30.8.1 Master/Slave TX Mode                  | 30.8.1 Master/Slave TX Mode                                                 |   982 |
| 30.8.2 Master/Slave RX Mode                  | 30.8.2 Master/Slave RX Mode                                                 |   983 |
| 30.9 Transmitting Data                       | 30.9 Transmitting Data                                                      |   983 |
| 30.9.1 Data Format Control                   | 30.9.1 Data Format Control                                                  |   983 |
|                                              | 30.9.1.1 Bit Width Control of Channel Valid Data                            |   983 |
|                                              | 30.9.1.2 Endian Control of Channel Valid Data                               |   984 |
|                                              | 30.9.1.3 A-law/µ-law Compression and Decompression                          |   984 |
|                                              | 30.9.1.4 Bit Width Control of Channel TX Data                               |   985 |
|                                              | 30.9.1.5 Bit Order Control of Channel Data                                  |   985 |
| 30.9.2 Channel Mode Control                  |                                                                             |   986 |
|                                              | 30.9.2.1 I2S Channel Control in TDM TX Mode                                 |   986 |
|                                              | 30.9.2.2 I2S Channel Control in PDM TX Mode                                 |   987 |
| 30.10 Receiving Data                         | 30.10 Receiving Data                                                        |   990 |
| 30.10.1 Channel Mode Control                 | 30.10.1 Channel Mode Control                                                |   990 |
| 30.10.1.1 I2S Channel Control in TDM RX Mode | 30.10.1.1 I2S Channel Control in TDM RX Mode                                |   990 |

|                                                                                                              | 30.10.1.2 I2S Channel Control in PDM RX Mode                                                                 | 991       |
|--------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------|-----------|
| 30.10.2 Data Format Control                                                                                  |                                                                                                              | 991       |
|                                                                                                              | 30.10.2.1 Bit Order Control of Channel Data                                                                  | 991       |
|                                                                                                              | 30.10.2.2 Bit Width Control of Channel Storage (Valid) Data                                                  | 991       |
|                                                                                                              | 30.10.2.3 Bit Width Control of Channel RX Data                                                               | 992       |
|                                                                                                              | 30.10.2.4 Endian Control of Channel Storage Data                                                             | 992       |
|                                                                                                              | 30.10.2.5 A-law/µ-law Compression and Decompression                                                          | 992       |
| 30.11 Software Configuration Process                                                                         | 30.11 Software Configuration Process                                                                         | 993       |
| 30.11.1 Configure I2S as TX Mode                                                                             | 30.11.1 Configure I2S as TX Mode                                                                             | 993       |
| 30.11.2 Configure I2S as RX Mode                                                                             | 30.11.2 Configure I2S as RX Mode                                                                             | 993       |
| 30.12 I2S Interrupts                                                                                         | 30.12 I2S Interrupts                                                                                         | 994       |
| 30.13 Event Task Matrix Feature                                                                              | 30.13 Event Task Matrix Feature                                                                              | 994       |
| 30.14 Register Summary                                                                                       | 30.14 Register Summary                                                                                       | 996       |
| 30.15 Registers                                                                                              | 30.15 Registers                                                                                              | 997       |
| 31 Pulse Count Controller (PCNT)                                                                             | 31 Pulse Count Controller (PCNT)                                                                             | 1014      |
| 31.1 Features                                                                                                | 31.1 Features                                                                                                | 1014      |
| 31.2 Functional Description                                                                                  | 31.2 Functional Description                                                                                  | 1015      |
| 31.3 Applications                                                                                            | 31.3 Applications                                                                                            | 1017      |
|                                                                                                              | 31.3.1 Channel 0 Incrementing Independently                                                                  | 1018      |
|                                                                                                              | 31.3.2 Channel 0 Decrementing Independently                                                                  | 1018      |
|                                                                                                              | 31.3.3 Channel 0 and Channel 1 Incrementing Together                                                         | 1019      |
| 31.4 Register Summary                                                                                        | 31.4 Register Summary                                                                                        | 1020      |
| 31.5 Registers                                                                                               | 31.5 Registers                                                                                               | 1021      |
| 32 USB Serial/JTAG Controller (USB_SERIAL_JTAG)                                                              | 32 USB Serial/JTAG Controller (USB_SERIAL_JTAG)                                                              | 1029      |
| 32.1 Overview                                                                                                | 32.1 Overview                                                                                                | 1029      |
| 32.2 Features                                                                                                | 32.2 Features                                                                                                | 1029      |
| 32.3 Functional Description  32.3.1 CDC-ACM USB Interface Functional Description                             | 32.3 Functional Description  32.3.1 CDC-ACM USB Interface Functional Description                             | 1031 1031 |
|                                                                                                              | 32.3.2 CDC-ACM Firmware Interface Functional Description                                                     | 1032      |
| 32.3.3 USB-to-JTAG Interface: JTAG Command Processor                                                         | 32.3.3 USB-to-JTAG Interface: JTAG Command Processor                                                         |           |
|                                                                                                              |                                                                                                              | 1033      |
| 32.3.4 USB-to-JTAG Interface: CMD_REP Usage Example                                                          | 32.3.4 USB-to-JTAG Interface: CMD_REP Usage Example                                                          | 1035      |
| 32.3.5 USB-to-JTAG Interface: Response Capture Unit  32.3.6 USB-to-JTAG Interface: Control Transfer Requests | 32.3.5 USB-to-JTAG Interface: Response Capture Unit  32.3.6 USB-to-JTAG Interface: Control Transfer Requests | 1035      |
| 32.5 Interrupts                                                                                              | 32.5 Interrupts                                                                                              | 1037      |
| 32.6 Register Summary                                                                                        | 32.6 Register Summary                                                                                        | 1039      |
| 32.7 Registers                                                                                               | 32.7 Registers                                                                                               | 1041      |
| 33 Two-wire Automotive Interface (TWAI)                                                                      | 33 Two-wire Automotive Interface (TWAI)                                                                      | 1065      |
| 33.1 Features                                                                                                | 33.1 Features                                                                                                | 1065      |
| 33.2 Protocol Overview                                                                                       | 33.2 Protocol Overview                                                                                       | 1066      |
| 33.2.2 TWAI Messages                                                                                         | 33.2.2.1 Data Frames and Remote Frames                                                                       | 1067 1067 |

| 33.2.2.2 Error and Overload Frames                    | 1069      |
|-------------------------------------------------------|-----------|
| 33.2.2.3 Interframe Space                             | 1071      |
| 33.2.3 TWAI Errors                                    | 1071      |
| 33.2.3.1 Error Types                                  | 1071      |
| 33.2.3.2 Error States                                 | 1072      |
| 33.2.3.3 Error Counters                               | 1072      |
| 33.2.4 TWAI Bit Timing                                | 1073      |
| 33.2.4.1 Nominal Bit                                  | 1073      |
| 33.2.4.2 Hard Synchronization and Resynchronization   | 1074      |
| 33.3 Architectural Overview                           | 1075      |
| 33.3.1 Registers Block                                | 1075      |
| 33.3.2 Bit Stream Processor                           | 1076      |
| 33.3.3 Error Management Logic                         | 1076      |
| 33.3.4 Bit Timing Logic                               | 1077      |
| 33.3.5 Acceptance Filter                              | 1077      |
| 33.3.6 Receive FIFO                                   | 1077      |
| 33.4 Functional Description                           | 1077      |
| 33.4.1 Modes                                          | 1077      |
| 33.4.1.1 Reset Mode                                   | 1077      |
| 33.4.1.2 Operation Mode                               | 1077      |
| 33.4.2 Bit Timing                                     | 1078      |
| 33.4.3 Interrupt Management                           | 1079      |
| 33.4.3.1 Receive Interrupt (RXI)                      | 1079      |
| 33.4.3.2 Transmit Interrupt (TXI)                     | 1079      |
| 33.4.3.3 Error Warning Interrupt (EWI)                | 1080      |
| 33.4.3.4 Data Overrun Interrupt (DOI)                 | 1080      |
| 33.4.3.5 Error Passive Interrupt (TXI)                | 1080      |
| 33.4.3.6 Arbitration Lost Interrupt (ALI)             | 1080      |
| 33.4.3.7 Bus Error Interrupt (BEI)                    | 1080      |
| 33.4.3.8 Bus Idle Status Interrupt (BISI)             | 1081      |
| 33.4.4 Transmit and Receive Buffers                   | 1081      |
| 33.4.4.1 Overview of Buffers                          | 1081      |
| 33.4.4.2 Frame Information                            | 1082      |
| 33.4.4.3 Frame Identifier                             | 1082      |
| 33.4.4.4 Frame Data                                   | 1083      |
| 33.4.5 Receive FIFO and Data Overruns                 | 1083      |
| 33.4.6 Acceptance Filter  33.4.6.1 Single Filter Mode | 1084 1085 |
| 33.4.6.2 Dual Filter Mode                             | 1085      |
| 33.4.7 Error Management                               | 1086      |
| 33.4.7.1 Error Warning Limit                          | 1087      |
| 33.4.7.2 Error Passive                                | 1087      |
| 33.4.7.3 Bus-Off and Bus-Off Recovery                 | 1087      |
| 33.4.8 Error Code Capture                             | 1088      |
| 33.4.9 Arbitration Lost Capture                       | 1089      |
| 33.4.10 Transceiver Auto-Standby                      | 1090      |

| 33.5 Register Summary           | 33.5 Register Summary                       | 33.5 Register Summary                             | 1091      |
|---------------------------------|---------------------------------------------|---------------------------------------------------|-----------|
| 33.6 Registers                  | 33.6 Registers                              | 33.6 Registers                                    | 1092      |
| 34 SDIO Slave Controller (SDIO) | 34 SDIO Slave Controller (SDIO)             | 34 SDIO Slave Controller (SDIO)                   | 1107      |
| 34.1 Overview                   | 34.1 Overview                               | 34.1 Overview                                     | 1107      |
| 34.2 Features                   | 34.2 Features                               | 34.2 Features                                     | 1107      |
| 34.3 Architecture Overview      | 34.3 Architecture Overview                  | 34.3 Architecture Overview                        | 1107      |
| 34.4 Standards Compliance       | 34.4 Standards Compliance                   | 34.4 Standards Compliance                         | 1108      |
| 34.5 Functional Description     | 34.5 Functional Description                 | 34.5 Functional Description                       | 1108      |
|                                 | 34.5.1 Physical Bus                         | 34.5.1 Physical Bus                               | 1108      |
|                                 | 34.5.2 Supported Commands                   | 34.5.2 Supported Commands                         | 1109      |
|                                 | 34.5.3 I/O Function 0 Address Space         | 34.5.3 I/O Function 0 Address Space               | 1109      |
|                                 | 34.5.4 I/O Function 1/2 Address Space Map   | 34.5.4 I/O Function 1/2 Address Space Map         | 1112      |
|                                 |                                             | 34.5.4.1 Accessing SLC HOST Register Space        | 1112      |
|                                 |                                             | 34.5.4.2 Transferring Incremental-Address Packets | 1112      |
|                                 |                                             | 34.5.4.3 Transferring Fixed-Address Packets       | 1113      |
| 34.5.5 DMA                      |                                             |                                                   | 1113      |
|                                 |                                             | 34.5.5.1 Linked List                              | 1113      |
|                                 |                                             | 34.5.5.2 Write-Back of Linked List                | 1115      |
|                                 |                                             | 34.5.5.3 Data Padding and Discarding              | 1116      |
|                                 | 34.5.6 SDIO Bus Timing                      |                                                   | 1117      |
| 34.6 Interrupt                  | 34.6 Interrupt                              | 34.6 Interrupt                                    | 1118      |
| 34.6.1 Host Interrupt           |                                             |                                                   | 1118      |
|                                 | 34.6.2 Slave Interrupt                      | 34.6.2 Slave Interrupt                            | 1118      |
|                                 | 34.7 Packet Sending and Receiving Procedure | 34.7 Packet Sending and Receiving Procedure       | 1119      |
|                                 | 34.7.1 Sending Packets to SDIO Host         | 34.7.1 Sending Packets to SDIO Host               | 1119      |
|                                 | 34.7.2 Receiving Packets from SDIO Host     | 34.7.2 Receiving Packets from SDIO Host           | 1120      |
| 34.8 Register Summary           | 34.8 Register Summary                       | 34.8 Register Summary                             | 1123      |
|                                 | 34.8.1 HINF Register Summary                | 34.8.1 HINF Register Summary                      | 1123      |
|                                 | 34.8.2 SLC Register Summary                 | 34.8.2 SLC Register Summary                       | 1123      |
|                                 | 34.8.3 SLC Host Register Summary            | 34.8.3 SLC Host Register Summary                  | 1124      |
| 34.9 Registers                  | 34.9 Registers                              | 34.9 Registers                                    | 1126      |
| 34.9.1 HINF Registers           |                                             |                                                   | 1126      |
|                                 | 34.9.2 SLC Registers                        | 34.9.2 SLC Registers                              | 1131      |
|                                 | 34.9.3 SLC Host Registers                   | 34.9.3 SLC Host Registers                         | 1153      |
| 35 LED PWM Controller (LEDC)    | 35 LED PWM Controller (LEDC)                | 35 LED PWM Controller (LEDC)                      | 1163      |
| 35.1 Overview                   | 35.1 Overview                               | 35.1 Overview                                     | 1163      |
| 35.2 Features                   | 35.2 Features                               | 35.2 Features                                     | 1163      |
| 35.3 Functional Description     | 35.3 Functional Description                 | 35.3 Functional Description                       | 1164      |
|                                 | 35.3.1 Architecture                         | 35.3.1 Architecture                               | 1164      |
|                                 | 35.3.2 Timers                               | 35.3.2 Timers                                     | 1165      |
|                                 |                                             | 35.3.2.1 Clock Source                             | 1165      |
|                                 |                                             | 35.3.2.2 Clock Divider Configuration              | 1165      |
|                                 |                                             | 35.3.2.3 20-Bit Counter                           | 1166 1168 |
|                                 | 35.3.3 PWM Generators                       |                                                   |           |

| 35.3.4 Duty Cycle Fading                                       | 1169      |
|----------------------------------------------------------------|-----------|
| 35.3.4.1 Linear Duty Cycle Fading                              | 1169      |
| 35.3.4.2 Gamma Curve Fading                                    | 1170      |
| 35.3.4.3 Suspend and Resume Duty Cycle Fading                  | 1172      |
| 35.3.5 Event Task Matrix Feature                               | 1173      |
| 35.3.6 Interrupts                                              | 1174      |
| 35.4 Register Summary                                          | 1175      |
| 35.5 Registers                                                 | 1178      |
| 36 Motor Control PWM (MCPWM)                                   | 1191      |
| 36.1 Overview                                                  | 1191      |
| 36.2 Features                                                  | 1191      |
| 36.3 Modules                                                   | 1194      |
| 36.3.1 Overview                                                | 1194      |
| 36.3.1.1 Prescaler Module                                      | 1194      |
| 36.3.1.2 Timer Module                                          |           |
|                                                                | 1194      |
| 36.3.1.3 Operator Module                                       | 1195      |
| 36.3.1.4 Fault Detection Module                                | 1196      |
| 36.3.1.5 Capture Module                                        | 1197      |
| 36.3.1.6 ETM Module                                            | 1197      |
| 36.3.2 PWM Timer Module                                        | 1197 1197 |
| 36.3.2.1 Configurations of the PWM Timer Module                |           |
| 36.3.2.2 PWM Timer’s Working Modes and Timing Event Generation | 1198      |
| 36.3.2.3 Shadow Register of PWM Timer                          | 1203      |
| 36.3.2.4 PWM Timer Synchronization and Phase Locking           | 1203      |
| 36.3.3 PWM Operator Module                                     |           |
| 36.3.3.1 PWM Generator Module                                  | 1205      |
| 36.3.3.2 Dead Time Generator Module                            | 1216      |
| 36.3.3.3 PWM Carrier Module                                    | 1220      |
| 36.3.3.4 Fault Detection Module                                | 1222      |
| 36.3.4 Capture Module                                          | 1223      |
| 36.3.4.1 Introduction  36.3.4.2 Capture Timer                  | 1223      |
|                                                                | 1224      |
| 36.3.4.3 Capture Channel                                       | 1224      |
| 36.3.5 ETM Module                                              | 1224      |
| 36.3.5.1 Overview                                              | 1224      |
| 36.3.5.2 MCPWM-Related ETM Events                              | 1224      |
| 36.3.5.3 MCPWM-Related ETM Tasks                               | 1225      |
| 36.4 Register Summary                                          | 1227      |
| 36.5 Registers                                                 | 1230      |
| 37 Remote Control Peripheral (RMT)                             | 1303      |
| 37.1 Overview                                                  | 1303      |
| 37.2 Features                                                  | 1303      |
| 37.3 Functional Description                                    | 1305      |

| 37.3.2 RMT RAM                                                          | 37.3.2 RMT RAM                                                          | 1306                        |
|-------------------------------------------------------------------------|-------------------------------------------------------------------------|-----------------------------|
|                                                                         | 37.3.2.1 Structure of RAM                                               | 1306                        |
|                                                                         | 37.3.2.2 Use of RAM                                                     | 1306                        |
|                                                                         | 37.3.2.3 RAM Access                                                     | 1307                        |
| 37.3.3 Clock                                                            | 1307                                                                    |                             |
| 37.3.4 Transmitter                                                      | 37.3.4 Transmitter                                                      | 1307                        |
|                                                                         | 37.3.4.1 Normal TX Mode                                                 | 1308                        |
|                                                                         | 37.3.4.2 Wrap TX Mode                                                   | 1308                        |
|                                                                         | 37.3.4.3 TX Modulation                                                  | 1308                        |
|                                                                         | 37.3.4.4 Continuous TX Mode                                             | 1309                        |
|                                                                         | 37.3.4.5 Simultaneous TX Mode                                           | 1309                        |
|                                                                         | 37.3.5 Receiver                                                         | 1309                        |
|                                                                         | 37.3.5.1 Normal RX Mode                                                 | 1309                        |
|                                                                         | 37.3.5.2 Wrap RX Mode                                                   | 1310                        |
|                                                                         | 37.3.5.3 RX Filtering                                                   | 1310                        |
|                                                                         | 37.3.5.4 RX Demodulation                                                | 1310                        |
| 37.3.6 Configuration Update                                             |                                                                         | 1310                        |
| 37.3.7 Interrupts                                                       | 37.3.7 Interrupts                                                       | 1311                        |
| 37.4 Register Summary                                                   | 37.4 Register Summary                                                   | 1312                        |
| 37.5 Registers                                                          | 37.5 Registers                                                          | 1314                        |
| 38 Parallel IO Controller (PARL_IO)                                     | 38 Parallel IO Controller (PARL_IO)                                     | 1329                        |
| 38.1 Introduction                                                       | 38.1 Introduction                                                       | 1329                        |
| 38.2 Glossary                                                           | 38.2 Glossary                                                           | 1329                        |
| 38.3 Features                                                           | 38.3 Features                                                           | 1329                        |
| 38.4 Architectural Overview                                             | 38.4 Architectural Overview                                             | 1331 1331                   |
| 38.5 Functional Description                                             | 38.5 Functional Description                                             | 38.5 Functional Description |
| 38.5.1 Clock Generator                                                  | 38.5.1 Clock Generator                                                  | 1331                        |
| 38.5.2 Clock & Reset Restriction  38.5.3 Master-Slave Mode              | 38.5.2 Clock & Reset Restriction  38.5.3 Master-Slave Mode              | 1333                        |
| 38.5.4 Receive Modes of the RX Unit                                     |                                                                         | 1334                        |
| 38.5.4.1 Level Enable Mode                                              | 38.5.4.1 Level Enable Mode                                              | 1334                        |
|                                                                         | 38.5.4.2 Pulse Enable Mode                                              | 1335                        |
| 38.5.4.3 Software Enable Mode  38.5.5 RX Unit GDMA SUC EOF Generation   | 38.5.4.3 Software Enable Mode  38.5.5 RX Unit GDMA SUC EOF Generation   | 1337                        |
|                                                                         |                                                                         | 1336                        |
|                                                                         |                                                                         | 1337                        |
| 38.5.6 RX Unit Timeout                                                  | 38.5.6 RX Unit Timeout                                                  | 38.5.6 RX Unit Timeout      |
| 38.5.7 Valid Signal Output of TX Unit  38.5.8 Bus Idle Value of TX Unit | 38.5.7 Valid Signal Output of TX Unit  38.5.8 Bus Idle Value of TX Unit | 1337                        |
| 38.5.9 Data Transfer in a Single Frame                                  | 38.5.9 Data Transfer in a Single Frame                                  | 1338                        |
| 38.5.10 Bit Reordering in One Byte                                      | 38.5.10 Bit Reordering in One Byte                                      | 1338                        |
| 38.6 Programming Procedures                                             | 38.6 Programming Procedures                                             | 1338                        |
| 38.6.1 Data Receiving Operation Process                                 | 38.6.1 Data Receiving Operation Process                                 | 1338                        |
| 38.6.2 Data Transmitting Operation Process                              | 38.6.2 Data Transmitting Operation Process                              | 1339                        |
| 38.7 Application Examples                                               | 38.7 Application Examples                                               | 1340                        |
| 38.7.1 Co-working with SPI                                              | 38.7.1 Co-working with SPI                                              | 1340                        |
| 38.7.2 Co-working with I2S                                              | 38.7.2 Co-working with I2S                                              | 1341                        |

| Contents                                                               | Contents                                                               | GoBack    |
|------------------------------------------------------------------------|------------------------------------------------------------------------|-----------|
|                                                                        | 38.7.3 Co-working with LCD                                             | 1342      |
|                                                                        | 38.8 Interrupts                                                        | 1343      |
|                                                                        | 38.9 Register Summary                                                  | 1344      |
| 38.10 Registers                                                        |                                                                        | 1345      |
|                                                                        | VI Analog Signal Processing                                            | 1354      |
|                                                                        | 39 On-Chip Sensor and Analog Signal Processing                         | 1355      |
| 39.1 Overview                                                          |                                                                        | 1355      |
| 39.2 SAR ADC                                                           |                                                                        | 1355      |
|                                                                        | 39.2.1 Overview                                                        | 1355      |
|                                                                        | 39.2.2 Features                                                        | 1355      |
|                                                                        | 39.2.3 Functional Description                                          | 1355      |
|                                                                        | 39.2.3.1 Input Signals                                                 | 1357      |
|                                                                        | 39.2.3.2 ADC Conversion and Attenuation                                | 1357      |
|                                                                        | 39.2.3.3 DIG ADC Controller                                            | 1357      |
|                                                                        | 39.2.3.4 DMA Support                                                   | 1358      |
|                                                                        | 39.2.3.5 DIG ADC FSM                                                   | 1358      |
|                                                                        | 39.2.3.6 ADC Filters                                                   | 1361      |
|                                                                        | 39.2.3.7 Threshold Monitoring                                          | 1361      |
|                                                                        | 39.3 Temperature Sensor  39.3.1 Overview                               | 1362 1362 |
|                                                                        | 39.3.2 Features                                                        | 1362      |
|                                                                        | 39.3.3 Functional Description                                          | 1362      |
|                                                                        | 39.4 Event Task Matrix Feature                                         | 1364      |
|                                                                        | 39.4.1 SAR ADC’s ETM Feature                                           | 1364      |
|                                                                        | 39.4.2 Temperature Sensor’s ETM Feature                                | 1364      |
| 39.5 Interrupts                                                        |                                                                        | 1365      |
|                                                                        | 39.6 Register Summary                                                  | 1366      |
| 39.7 Registers                                                         |                                                                        | 1367      |
|                                                                        | VII Appendix                                                           | 1383      |
| Related Documentation and Resources                                    | Related Documentation and Resources                                    | 1384      |
| Glossary                                                               | Glossary                                                               | 1385      |
| Abbreviations for Peripherals                                          | Abbreviations for Peripherals                                          | 1385      |
| Abbreviations Related to Registers                                     | Abbreviations Related to Registers                                     | 1385      |
| Access Types for Registers                                             | Access Types for Registers                                             | 1387      |
| Introduction                                                           | Introduction                                                           | 1389      |
| Programming Reserved Register Field  Interrupt Configuration Registers | Programming Reserved Register Field  Interrupt Configuration Registers | 1390      |

## Revision History

![Image](images/00_Header_img003_a499ab5e.png)

1391

## List of Tables

| 1.4-1 CPU Address Map                                                                                  |   40 |
|--------------------------------------------------------------------------------------------------------|------|
| 1.7-1 Core Local Interrupt (CLINT) Sources                                                             |   60 |
| 1.11-1 NAPOT encoding for maddress                                                                     |   77 |
| 2.3-1 Trace Encoder Parameters                                                                         |   92 |
| 2.6-1 Header Format                                                                                    |   95 |
| 2.6-2 Index Format                                                                                     |   95 |
| 2.6-3 Packet format 3 subformat 0                                                                      |   95 |
| 2.6-4 Packet format 3 subformat 1                                                                      |   96 |
| 2.6-5 Packet format 3 subformat 3                                                                      |   96 |
| 2.6-6 Packet format 2                                                                                  |   97 |
| 2.6-7 Packet format 1 with address                                                                     |   97 |
| 2.6-8 Packet format 1 without address                                                                  |   98 |
| 3.3-1 LP CPU Exception Causes                                                                          |  117 |
| 3.6-1 Performance Counter                                                                              |  125 |
| 3.9-1 Wake Sources                                                                                     |  129 |
| 4.4-1 Selecting Peripherals via Register Configuration                                                 |  134 |
| 4.4-2 Descriptor Field Alignment Requirements                                                          |  137 |
| 5.3-1 Memory Address Mapping                                                                           |  171 |
| 5.3-2 Module/Peripheral Address Mapping                                                                |  175 |
| 6.3-1 Parameters in eFuse BLOCK0                                                                       |  180 |
| 6.3-2 Secure Key Purpose Values                                                                        |  183 |
| 6.3-3 Parameters in BLOCK1 to BLOCK10                                                                  |  184 |
| 6.3-4 Registers Information                                                                            |  189 |
| 6.3-5 Configuration of Default VDDQ Timing Parameters                                                  |  190 |
| 7.8-1 Bit Used to Control IO MUX Functions in Light-sleep Mode                                         |  254 |
| 7.11-1 Peripheral Signals via GPIO Matrix                                                              |  257 |
| 7.12-1 IO MUX Functions List                                                                           |  262 |
| 7.13-1 LP IO MUX Functions List                                                                        |  263 |
| 7.13-2 Analog Functions of IO MUX Pins                                                                 |  264 |
| 8.1-1 Reset Source                                                                                     |  306 |
| 8.2-1 CPU_CLK Clock Source                                                                             |  308 |
| 8.2-2 Frequency of CPU_CLK, AHB_CLK and HP_ROOT_CLK                                                    |  309 |
| 8.2-3 Derived Clock Source                                                                             |  311 |
| 8.2-4 HP Clocks Used by Each Peripheral                                                                |  311 |
| 8.2-5 LP Clocks Used by Each Peripheral                                                                |  312 |
| 8.2-6 Mapping Between PMU Register Bits and the Clock Gating of Peripherals’ Register R/W Op erations |  314 |
| 8.2-7 Mapping Between PMU Register Bits and the Gating of Peripherals’ Operating Clock                 |  315 |

| 9.2-1 Default Configuration of Strapping Pins                                                    |   375 |
|--------------------------------------------------------------------------------------------------|-------|
| 9.2-2 Boot Mode Control                                                                          |   375 |
| 9.2-3 ROM Message Printing Control                                                               |   377 |
| 9.2-4 JTAG Signal Source Control                                                                 |   378 |
| 9.2-5 SDIO Input Sampling Edge/Output Driving Edge Control                                       |   378 |
| 10.3-1 CPU Peripheral Interrupt Source Mapping/Status Registers and Peripheral Interrupt Sources |   381 |
| 11.3-1 Selectable Events for ETM Channeln                                                        |   400 |
| 11.3-2 Mappable Tasks for ETM Channeln                                                           |   403 |
| 12.4-1 Wake-up Sources                                                                           |   422 |
| 12.4-2 HP System Peripherals’ Function Clocks                                                    |   425 |
| 12.4-3 HP System Peripherals’ APB Clocks                                                         |   426 |
| 12.4-4 Trigger Conditions for the RTC Timer                                                      |   428 |
| 12.5-1 Preset Power Modes                                                                        |   431 |
| 13.4-1 UNITn Configuration Bits                                                                  |   498 |
| 13.4-2 Trigger Point                                                                             |   499 |
| 13.4-3 Synchronization Operation for Configuration Registers                                     |   501 |
| 14.3-1 Alarm Generation When Up-Down Counter Increments                                          |   522 |
| 14.3-2 Alarm Generation When Up-Down Counter Decrements                                          |   523 |
| 15.2-1 Timeout Actions                                                                           |   549 |
| 16.1-1 Management Area of PMP and APM                                                            |   561 |
| 16.3-1 Configuring Access Path                                                                   |   564 |
| 17.3-1 Security Level                                                                            |   596 |
| 18.4-1 HP CPU Packet Format                                                                      |   610 |
| 18.4-2 LP CPU Packet Format                                                                      |   610 |
| 18.4-3 DMA Packet Format                                                                         |   610 |
| 18.4-4 LOST Packet Format                                                                        |   611 |
| 18.4-5 DMA Access Source                                                                         |   611 |
| 19.3-1 AES Accelerator Working Mode                                                              |   640 |
| 19.3-2 Key Length and Encryption/Decryption                                                      |   640 |
| 19.4-1 Working Status under Typical AES Working Mode                                             |   641 |
| 19.4-2 Text Endianness Type for Typical AES                                                      |   641 |
| 19.4-3 Key Endianness Type for AES-128 Encryption and Decryption                                 |   642 |
| 19.4-4 Key Endianness Type for AES-256 Encryption and Decryption                                 |   642 |
| 19.5-1 Block Cipher Mode                                                                         |   643 |
| 19.5-2 Working Status under DMA-AES Working mode                                                 |   645 |
| 19.5-3 TEXT-PADDING                                                                              |   645 |
| 20.3-1 ECC Accelerator Memory Blocks                                                             |   655 |
| 20.4-1 ECC Accelerator Key Size Selection                                                        |   656 |

| 20.4-2 ECC Accelerator’s Working Modes                                           |   657 |
|----------------------------------------------------------------------------------|-------|
| 21.2-1 HMAC Purposes and Configuration Value                                     |   667 |
| 22.3-1 Acceleration Performance                                                  |   686 |
| 22.4-1 RSA Accelerator Memory Blocks                                             |   688 |
| 23.3-1 SHA Accelerator Working Mode                                              |   694 |
| 23.3-2 SHA Hash Algorithm Selection                                              |   695 |
| 23.4-1 The Storage and Length of Message Digest from Different Algorithms        |   699 |
| 25.4-1  Key generated based on KeyA                                              |   718 |
| 25.4-2 Mapping Between Offsets and Registers                                     |   719 |
| 27.2-1 UART and LP UART Feautre Comparison                                       |   733 |
| 27.4-1 UART_CHAR_WAKEUP Mode Configuration                                       |   743 |
| 28.5-1 Data Modes Supported by GP-SPI2                                           |   824 |
| 28.5-2 Functional Description of FSPI Bus Signals                                |   824 |
| 28.5-3 Signals Used in Various SPI Modes                                         |   825 |
| 28.5-4 Bit Order Control in GP-SPI2                                              |   827 |
| 28.5-5 Supported Transfer Types as Master or Slave                               |   828 |
| 28.5-6 Interrupt Trigger Condition on GP-SPI2 Data Transfer as Slave             |   832 |
| 28.5-7 Registers Used for State Control in 1/2/4-bit Modes                       |   838 |
| 28.5-7 Registers Used for State Control in 1/2/4-bit Modes                       |   839 |
| 28.5-8 Sending Sequence of Command Value                                         |   840 |
| 28.5-9 Sending Sequence of Address Value                                         |   841 |
| 28.5-10 BM Table for CONF State                                                  |   846 |
| 28.5-11 An Example of CONF bufferi in Segmenti                                   |   847 |
| 28.5-12 BM Bit Value v.s. Register to Be Updated in This Example                 |   847 |
| 28.5-13 Supported CMD Values in SPI Mode                                         |   850 |
| 28.5-13 Supported CMD Values in SPI Mode                                         |   851 |
| 28.5-14 Supported CMD Values in QPI Mode                                         |   851 |
| 28.7-1 Clock Phase and Polarity Configuration as Master                          |   857 |
| 28.7-2 Clock Phase and Polarity Configuration as Slave                           |   857 |
| 28.9-1 GP-SPI2 Interrupts as Master                                              |   861 |
| 28.9-2 GP-SPI2 Interrupts as Slave                                               |   861 |
| 29.4-1 I2C Synchronous Registers                                                 |   899 |
| 30.4-1 I2S Signal Description                                                    |   977 |
| 30.9-1 Bit Width of Channel Valid Data                                           |   984 |
| 30.9-2 Endian of Channel Valid Data                                              |   984 |
| 30.9-3 The Matching Between Valid Data Width and Number of TX Channel Supported  |   986 |
| 30.9-4 Data-Fetching Control in PDM Mode                                         |   988 |
| 30.9-5 I2S Channel Control in Normal PDM TX Mode                                 |   988 |
| 30.9-6 PCM-to-PDM TX Mode                                                        |   988 |
| 30.10-1 The Matching Between Valid Data Width and Number of RX Channel Supported |   990 |
| 30.10-2 Channel Storage Data Width                                               |   992 |

| 30.10-3 Channel Storage Data Endian                                                    |   992 |
|----------------------------------------------------------------------------------------|-------|
| 31.2-1 Counter Mode. Positive Edge of Input Pulse Signal. Control Signal in Low State  |  1016 |
| 31.2-2 Counter Mode. Positive Edge of Input Pulse Signal. Control Signal in High State |  1016 |
| 31.2-3 Counter Mode. Negative Edge of Input Pulse Signal. Control Signal in Low State  |  1016 |
| 31.2-4 Counter Mode. Negative Edge of Input Pulse Signal. Control Signal in High State |  1017 |
| 32.3-1 Standard CDC-ACM Control Requests                                               |  1031 |
| 32.3-2 CDC-ACM Settings with RTS and DTR                                               |  1032 |
| 32.3-3 Commands of a Nibble                                                            |  1034 |
| 32.3-4 USB-to-JTAG Control Requests                                                    |  1035 |
| 32.3-5 JTAG Capability Descriptors                                                     |  1036 |
| 32.4-1 Reset SoC into Download Mode                                                    |  1037 |
| 32.4-2 Reset SoC into Booting from flash                                               |  1037 |
| 33.2-1 Data Frames and Remote Frames in SFF and EFF                                    |  1068 |
| 33.2-2 Error Frame                                                                     |  1070 |
| 33.2-3 Overload Frame                                                                  |  1070 |
| 33.2-4 Interframe Space                                                                |  1071 |
| 33.2-5 Segments of a Nominal Bit Time                                                  |  1074 |
| 33.4-1 Bit Information of TWAI_BUS_TIMING_0_REG (0x18)                                 |  1078 |
| 33.4-2 Bit Information of TWAI_BUS_TIMING_1_REG (0x1c)                                 |  1078 |
| 33.4-3 Buffer Layout for Standard Frame Format and Extended Frame Format               |  1081 |
| 33.4-4 TX/RX Frame Information (SFF/EFF)fiTWAI Address 0x40                            |  1082 |
| 33.4-5 TX/RX Identifier 1 (SFF); TWAI Address 0x44                                     |  1082 |
| 33.4-6 TX/RX Identifier 2 (SFF); TWAI Address 0x48                                     |  1082 |
| 33.4-7 TX/RX Identifier 1 (EFF); TWAI Address 0x44                                     |  1082 |
| 33.4-8 TX/RX Identifier 2 (EFF); TWAI Address 0x48                                     |  1083 |
| 33.4-9 TX/RX Identifier 3 (EFF); TWAI Address 0x4c                                     |  1083 |
| 33.4-10 TX/RX Identifier 4 (EFF); TWAI Address 0x50                                    |  1083 |
| 33.4-11 Bit Information of TWAI_ERR_CODE_CAP_REG (0x30)                                |  1088 |
| 33.4-12 Bit Information of Bits SEG.4 - SEG.0                                          |  1088 |
| 33.4-13 Bit Information of TWAI_ARB_LOST_CAP_REG (0x2c)                                |  1089 |
| 34.5-1 SDIO Slave CCCR Configuration                                                   |  1110 |
| 34.5-2 SDIO Slave FBR Configuration                                                    |  1111 |
| 35.3-1 Commonly-used Frequencies and Resolutions                                       |  1168 |
| 36.3-1 Configuration Parameters of the Operator Submodule                              |  1195 |
| 36.3-2 Timing Events Used in PWM Generator                                             |  1206 |
| 36.3-3 Timing Events Priority When PWM Timer Increments                                |  1206 |
| 36.3-4 Timing Events Priority when PWM Timer Decrements                                |  1207 |
| 36.3-5 Dead Time Generator Switches Control Fields                                     |  1217 |
| 36.3-6 Typical Dead Time Generator Operating Modes                                     |  1217 |
| 36.3-7 MCPWM-Related ETM Events                                                        |  1224 |

| 37.3-1 Configuration Update                  |   1311 |
|----------------------------------------------|--------|
| 39.2-1 SAR ADC Input Signals                 |   1357 |
| 39.3-1 Temperature Offset                    |   1363 |
| 39.7-4 Configuration of ENA/RAW/ST Registers |   1390 |

## List of Figures

| 1.1-1 CPU Block Diagram                                                                   |   39 |
|-------------------------------------------------------------------------------------------|------|
| 1.10-1 Debug System Overview                                                              |   71 |
| 2.0-1 Trace Encoder Overview                                                              |   90 |
| 2.2-1 Trace Overview                                                                      |   91 |
| 2.6-1 Trace packet Format                                                                 |   94 |
| 3.0-1 LP CPU Overview                                                                     |  107 |
| 3.9-1 Wake-Up and Sleep Flow of LP CPU                                                    |  127 |
| 4.1-1 Modules with GDMA Feature and GDMA Channels                                         |  131 |
| 4.3-1 GDMA controller Architecture                                                        |  132 |
| 4.4-1 Structure of a Linked List                                                          |  133 |
| 4.4-2 Relationship among Linked Lists                                                     |  136 |
| 5.2-1 System Structure and Address Mapping                                                |  170 |
| 5.3-1 Cache Structure                                                                     |  173 |
| 5.3-2 Modules/peripherals that can work with GDMA                                         |  174 |
| 6.3-1 Data Flow in eFuse                                                                  |  179 |
| 6.3-2 Shift Register Circuit (first 32 output)                                            |  186 |
| 6.3-3 Shift Register Circuit (last 12 output)                                             |  186 |
| 7.3-1 Architecture of IO MUX, LP IO MUX, and GPIO Matrix                                  |  245 |
| 7.3-2 Internal Structure of a Pad                                                         |  246 |
| 7.4-1 GPIO Input Synchronized on Rising Edge or on Falling Edge of IO MUX Operating Clock |  247 |
| 7.4-2 GPIO Filter Timing of GPIO Input Signals                                            |  248 |
| 7.4-3 Glitch Filter Timing Example                                                        |  249 |
| 8.1-1 Reset Types                                                                         |  304 |
| 8.2-1 System Clock                                                                        |  307 |
| 8.3-1 Clock Configuration Example                                                         |  317 |
| 9.2-1 Chip Boot Flow                                                                      |  376 |
| 10.2-1 Interrupt Matrix Structure                                                         |  380 |
| 11.3-1 Event Task Matrix Architecture                                                     |  399 |
| 11.3-2 ETM Channeln Architecture                                                          |  399 |
| 11.3-3 Event Task Matrix Clock Architecture                                               |  406 |
| 12.4-1 ESP32-C6 Power Scheme                                                              |  418 |
| 12.4-2 PMU Workflow                                                                       |  420 |
| 12.4-3 Brownout Reset Workflow                                                            |  430 |
| 12.6-1 ESP32-C6 Boot Flow                                                                 |  432 |
| 13.1-1 System Timer Structure                                                             |  496 |
|                                                                                           |  497 |

13.4-1 System Timer Alarm Generation

Submit Documentation Feedback

| 14.1-1 Timer Group Overview                                           |   520 |
|-----------------------------------------------------------------------|-------|
| 14.3-1 Timer Group Architecture                                       |   521 |
| 15.1-1 Watchdog Timers Overview                                       |   545 |
| 15.2-1 Digital Watchdog Timers in ESP32-C6                            |   548 |
| 15.3-1 Super Watchdog Controller Structure                            |   551 |
| 16.1-1 PMP-APM Management Relation                                    |   562 |
| 16.3-1 APM Controller Structure                                       |   564 |
| 21.3-1 HMAC SHA-256 Padding Diagram                                   |   670 |
| 21.3-2 HMAC Structure Schematic Diagram                               |   671 |
| 24.3-1 Software Preparations and Hardware Working Process             |   707 |
| 25.3-1 Architecture of the External Memory Encryption and Decryption  |   717 |
| 26.3-1 Noise Source                                                   |   729 |
| 27.3-1 UART Structure                                                 |   734 |
| 27.4-1 UART Controllers Division                                      |   737 |
| 27.4-2 The Timing Diagram of Weak UART Signals Along Falling Edges    |   738 |
| 27.4-3 Structure of UART Data Frame                                   |   739 |
| 27.4-4 AT_CMD Character Structure                                     |   739 |
| 27.4-5 Driver Control Diagram in RS485 Mode                           |   740 |
| 27.4-6 The Timing Diagram of Encoding and Decoding in SIR mode        |   742 |
| 27.4-7 IrDA Encoding and Decoding Diagram                             |   742 |
| 27.4-8 Hardware Flow Control Diagram                                  |   744 |
| 27.4-9 Connection between Hardware Flow Control Signals               |   745 |
| 27.4-10 Data Transfer in GDMA Mode                                    |   746 |
| 27.5-1 UART Programming Procedures                                    |   749 |
| 28.4-1 SPI Module Overview                                            |   822 |
| 28.5-1 Data Buffer Used in CPU-Controlled Transfer                    |   828 |
| 28.5-2 GP-SPI2 Block Diagram                                          |   833 |
| 28.5-3 Data Flow Control in GP-SPI2 as Master                         |   834 |
| 28.5-4 Data Flow Control in GP-SPI2 as Slave                          |   835 |
| 28.5-5 GP-SPI2 State Machine as Master                                |   837 |
| 28.5-6 Full-Duplex Communication Between GP-SPI2 Master and a Slave   |   841 |
| 28.5-7 Connection of GP-SPI2 to Flash and External RAM in 4-bit Mode  |   843 |
| 28.5-8 SPI Quad I/O Read Command Sequence Sent by GP-SPI2 to Flash    |   844 |
| 28.5-9 Configurable Segmented Transfer as Master                      |   844 |
| 28.6-1 Recommended CS Timing and Settings When Accessing External RAM |   854 |
| 28.6-2 Recommended CS Timing and Settings When Accessing Flash        |   854 |
| 28.7-1 SPI Clock Mode 0 or 2                                          |   856 |
| 28.7-2 SPI Clock Mode 1 or 3                                          |   856 |
| 28.8-1 Timing Compensation Control Diagram in GP-SPI2 as Master       |   858 |

| 29.3-1 I2C Master Architecture                                                             |   894 |
|--------------------------------------------------------------------------------------------|-------|
| 29.3-2 I2C Slave Architecture                                                              |   894 |
| 29.3-3 I2C Protocol Timing (Cited from Fig.31 in The I2C-bus specification Version 2.1)    |   895 |
| 29.3-4 I2C Timing Parameters (Cited from Table 5 in The I2C-bus specification Version 2.1) |   896 |
| 29.4-1 I2C Timing Diagram                                                                  |   900 |
| 29.4-2 Structure of I2C Command Registers                                                  |   902 |
| 29.6-1 I2C master  Writing to I2Cslave with a 7-bit Address                                |   906 |
| 29.6-2 I2C master  Writing to a Slave with a 10-bit Address                                |   908 |
| 29.6-3 I2C master  Writing to I2Cslave with Two 7-bit Addresses                            |   910 |
| 29.6-4 I2C master  Writing to I2Cslave with a 7-bit Address in Multiple Sequences          |   912 |
| 29.6-5 I2C master  Reading I2Cslave with a 7-bit Address                                   |   914 |
| 29.6-6 I2C master  Reading I2Cslave with a 10-bit Address                                  |   917 |
| 29.6-7 I2C master  Reading N Bytes of Data from addrM of I2Cslave with a 7-bit Address     |   919 |
| 29.6-8 I2C master  Reading I2Cslave with a 7-bit Address in Segments                       |   922 |
| 30.4-1 ESP32-C6 I2S System Diagram                                                         |   976 |
| 30.5-1 TDM Philips Standard Timing Diagram                                                 |   978 |
| 30.5-2 TDM MSB Alignment Standard Timing Diagram                                           |   979 |
| 30.5-3 TDM PCM Standard Timing Diagram                                                     |   979 |
| 30.5-4 PDM Standard Timing Diagram                                                         |   980 |
| 30.6-1 I2S Clock Generator                                                                 |   980 |
| 30.9-1 TX Data Format Control                                                              |   986 |
| 30.9-2 TDM Channel Control                                                                 |   987 |
| 30.9-3 PDM Channel Control Example                                                         |   990 |
| 31.0-1 PCNT Block Diagram                                                                  |  1014 |
| 31.2-1 PCNT Unit Architecture                                                              |  1015 |
| 31.3-1 Channel 0 Up Counting Diagram                                                       |  1018 |
| 31.3-2 Channel 0 Down Counting Diagram                                                     |  1018 |
| 31.3-3 Two Channels Up Counting Diagram                                                    |  1019 |
| 32.2-1 USB Serial/JTAG High Level Diagram                                                  |  1030 |
| 32.2-2 USB Serial/JTAG Block Diagram                                                       |  1031 |
| 33.2-1 Bit Fields in Data Frames and Remote Frames                                         |  1068 |
| 33.2-2 Fields of an Error Frame                                                            |  1070 |
| 33.2-3 Fields of an Overload Frame                                                         |  1070 |
| 33.2-4 The Fields within an Interframe Space                                               |  1071 |
| 33.2-5 Layout of a Bit                                                                     |  1074 |
| 33.3-1 TWAI Overview Diagram                                                               |  1075 |
| 33.4-1 Acceptance Filter                                                                   |  1084 |
| 33.4-2 Single Filter Mode                                                                  |  1085 |
| 33.4-3 Dual Filter Mode                                                                    |  1086 |
| 33.4-4 Error State Transition                                                              |  1087 |
| 33.4-5 Positions of Arbitration Lost Bits                                                  |  1089 |
| 34.3-1 SDIO Slave Block Diagram                                                            |  1108 |
| 34.5-1 CMD52 Content                                                                       |  1109 |

Submit Documentation Feedback

| 34.5-2 CMD53 Content                                                                                                |   1109 |
|---------------------------------------------------------------------------------------------------------------------|--------|
| 34.5-3 Function 0 Address Space                                                                                     |   1109 |
| 34.5-4 Function 1/2 Address Space Map                                                                               |   1112 |
| 34.5-5 DMA Linked List Descriptor Structure of the SDIO Slave                                                       |   1113 |
| 34.5-6 DMA Linked List of the SDIO Slave                                                                            |   1115 |
| 34.5-7 Data Flow of Sending Incremental-address Packets From Host to Slave                                          |   1116 |
| 34.5-8 Sampling Timing Diagram                                                                                      |   1117 |
| 34.5-9 Output Timing Diagram                                                                                        |   1117 |
| 34.7-1 Procedure of Slave Sending Packets to Host                                                                   |   1119 |
| 34.7-2 Procedure of Slave Receiving Packets from Host                                                               |   1121 |
| 34.7-3 Loading Receiving Buffer                                                                                     |   1122 |
| 35.2-1 LED PWM Architecture                                                                                         |   1164 |
| 35.3-1 Timer and PWM Generator Block Diagram                                                                        |   1164 |
| 35.3-2 Frequency Division When LEDC_CLK_DIV is a Non-Integer Value                                                  |   1166 |
| 35.3-3 Relationship Between Counter And Resolution                                                                  |   1166 |
| 35.3-4 LED PWM Output Signal Diagram                                                                                |   1169 |
| 35.3-5 Output Signal of Linear Duty Cycle Fading                                                                    |   1171 |
| 35.3-6 Output Signal of Gamma Curve Fading                                                                          |   1172 |
| 36.2-1 MCPWM Module Overview                                                                                        |   1192 |
| 36.3-1 Prescaler Module                                                                                             |   1194 |
| 36.3-2 Timer Module                                                                                                 |   1194 |
| 36.3-3 Operator Module                                                                                              |   1195 |
| 36.3-4 Fault Detection Module                                                                                       |   1196 |
| 36.3-5 Capture Module                                                                                               |   1197 |
| 36.3-6 ETM Module                                                                                                   |   1197 |
| 36.3-7 Count-Up Mode Waveform                                                                                       |   1198 |
| 36.3-8 Count-Down Mode Waveforms                                                                                    |   1199 |
| 36.3-9 Count-Up-Down Mode Waveforms, Count-Down at Synchronization Event                                            |   1199 |
| 36.3-10 Count-Up-Down Mode Waveforms, Count-Up at Synchronization Event                                             |   1199 |
| 36.3-11 UTEP and UTEZ Generation in Count-Up Mode                                                                   |   1200 |
| 36.3-12 DTEP and DTEZ Generation in Count-Down Mode                                                                 |   1201 |
| 36.3-13 DTEP and UTEZ Generation in Count-Up-Down Mode                                                              |   1201 |
| 36.3-14 Block Diagram of A PWM Operator                                                                             |   1204 |
| 36.3-15 Symmetrical Waveform in Count-Up-Down Mode                                                                  |   1208 |
| 36.3-16 Count-Up, Single Edge Asymmetric Waveform, with Independent Modulation on PWMxA and PWMxB — Active High     |   1209 |
| 36.3-17 Count-Up, Pulse Placement Asymmetric Waveform with Independent Modulation on PWMxA                          |   1210 |
| 36.3-18 Count-Up-Down, Dual Edge Symmetric Waveform, with Independent Modulation on PWMxA and PWMxB — Active High   |   1211 |
| 36.3-19 Count-Up-Down, Dual Edge Symmetric Waveform, with Independent Modulation on PWMxA and PWMxB — Complementary |   1212 |
| 36.3-20 Count-Up-Down, Fault or Synchronization Events, with Same Modulation on PWMxA and PWMxB                     |   1213 |
| 36.3-21 Example of an NCI Software-Force Event on PWMxA                                                             |   1214 |
| 36.3-22 Example of a CNTU Software-Force Event on PWMxB                                                             |   1215 |

| 36.3-23 Options for Setting up the Dead Time Generator Module                                            | 1217   |
|----------------------------------------------------------------------------------------------------------|--------|
| 36.3-24 Active High Complementary (AHC) Dead Time Waveforms                                              | 1218   |
| 36.3-25 Active Low Complementary (ALC) Dead Time Waveforms                                               | 1219   |
| 36.3-26 Active High (AH) Dead Time Waveforms                                                             | 1219   |
| 36.3-27 Active Low (AL) Dead Time Waveforms                                                              | 1219   |
| 36.3-28 Example of Waveforms Showing PWM Carrier Action                                                  | 1220   |
| 36.3-29 Example of the First Pulse and the Subsequent Sustaining Pulses of the PWM Carrier Submodule1221 |        |
| 36.3-30 Possible Duty Cycle Settings for Sustaining Pulses in the PWM Carrier Submodule                  | 1222   |
| 37.3-1 RMT Architecture                                                                                  | 1305   |
| 37.3-2 Format of Pulse Code in RAM                                                                       | 1306   |
| 38.4-1 PARLIO Architecture                                                                               | 1331   |
| 38.5-1 PARLIO Clock Generation                                                                           | 1332   |
| 38.5-2 Master Clock Positive Waveform                                                                    | 1334   |
| 38.5-3 Master Clock Negative Waveform                                                                    | 1334   |
| 38.5-4 Sub-Modes of Level Enable Mode for RX Unit                                                        | 1335   |
| 38.5-5 Sub-Modes of Pulse Enable Mode for RX Unit                                                        | 1336   |
| 38.5-6 Sub-Mode of Software Enable Mode for RX Unit                                                      | 1337   |
| 39.2-1 SAR ADCs Function Overview                                                                        | 1356   |
| 39.2-2 Diagram of DIG ADC FSM                                                                            | 1358   |
| 39.2-3 APB_SARADC_SAR_PATT_TAB1_REG and Pattern Table Entry 0 - Entry 3                                  | 1359   |
| 39.2-4 APB_SARADC_SAR_PATT_TAB2_REG and Pattern Table Entry 4 - Entry 7                                  | 1359   |
| 39.2-5 Pattern Table Entry                                                                               | 1360   |
| 39.2-6 cmd1 configuration                                                                                | 1360   |
| 39.2-7 cmd0 Configuration                                                                                | 1360   |
| 39.2-8 DMA Data Format                                                                                   | 1361   |
| 39.3-1 Temperature Sensor Structure                                                                      | 1362   |

![Image](images/00_Header_img004_3c5733f0.png)

## Part I

## Microprocessor and Master

This part covers the essential processing elements of the system, diving into the microprocessor architecture with both high-performance and low-power CPUs. Details include RISC-V Trace Encoder and controllers for Direct Memory Access (DMA).

## Chapter 1

---

# ESP32-C6 Technical Reference Manual - Split Edition

This document has been split into individual chapters for easier navigation.

**Processed:** 2026-02-10 16:19

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
- [Chapter 35: Chapter 35](35_Chapter_35.md)
- [Chapter 36: Chapter 36](36_Chapter_36.md)
- [Chapter 37: Chapter 37](37_Chapter_37.md)
- [Chapter 38: Chapter 38](38_Chapter_38.md)
- [Chapter 39: Chapter 39](39_Chapter_39.md)
