---
chapter: 17
title: "Chapter 17"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 17

## Debug Assistant (ASSIST\_DEBUG)

## 17.1 Overview

Debug Assistant is an auxiliary module that features a set of functions to help locate bugs and issues during software debugging.

## 17.2 Features

- Read/write monitoring: Monitors whether the CPU bus has read from or written to a specified address space. A detected read or write will trigger an interrupt.
- Stack pointer (SP) monitoring: Monitors whether the SP exceeds the specified address space. A bounds violation will trigger an interrupt.
- Program counter (PC) logging: Records PC value. The developer can get the last PC value at the most recent CPU reset.
- Bus access logging: Records the information about bus access. When the CPU or DMA writes a specified value, the Debug Assistant module will record the address and PC value of this write operation, and push the data to the SRAM.

## 17.3 Functional Description

## 17.3.1 Region Read/Write Monitoring

The Debug Assistant module can monitor reads/writes performed by the CPU's Data bus and Peripheral bus in a certain address space, i.e., memory region. Whenever the Data bus reads or writes in the specified address space, an interrupt will be triggered. The Data bus can monitor two memory regions (assuming they are region 0 and region 1, defined by developer's needs) at the same time, so can the Peripheral bus.

## 17.3.2 SP Monitoring

The Debug Assistant module can monitor the SP so as to prevent stack overflow or erroneous push/pop. When the stack pointer exceeds the minimum or maximum threshold, Debug Assistant will record the PC pointer and generate an interrupt. The threshold is configured by software.

## 17.3.3 PC Logging

In some cases, software developers want to know the PC at the last CPU reset. For instance, when the program is stuck and can only be reset, the developer may want to know where the program got stuck in order to debug. The Debug Assistant module can record the PC at the last CPU reset, which can be then read for software debugging.

## 17.3.4 CPU/DMA Bus Access Logging

The Debug Assistant module can record the information about the CPU Data bus's and DMA bus's write behaviors in real time. When a write operation occurs in or a specific value is written to a specified address space, the Debug Assistant will record the bus type, PC, and the address, and then store the data in the SRAM in a certain format.

## 17.4 Recommended Operation

## 17.4.1 Region Monitoring and SP Monitoring Configuration Process

The Debug Assistant module can monitor reads and writes performed by the CPU's Data bus and Peripheral bus. Two memory regions on each bus can be monitored at the same time. All the monitoring modes supported by the Debug Assistant module are listed below:

- Monitoring of the read/write operations on Data bus
- – Data bus reads in region 0
- – Data bus writes in region 0
- – Data bus reads in region 1
- – Data bus writes in region 1
- Monitoring of the read/write operations on Peripheral bus
- – Peripheral bus reads in region 0
- – Peripheral bus writes in region 0
- – Peripheral bus reads in region 1
- – Peripheral bus writes in region 1
- Monitoring of exceeding the SP bounds
- – SP exceeds the upper bound address
- – SP exceeds the lower bound address

The configuration process for region monitoring and SP monitoring is as follows:

1. Configure monitored region and SP threshold.
- Configure Data bus region 0 with ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MIN\_REG and ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MAX\_REG .

- Configure Data bus region 1 with ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MIN\_REG and ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MAX\_REG .
- Configure Peripheral bus region 0 with ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_MIN\_REG and ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_MAX\_REG .
- Configure Peripheral bus region 1 with ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_MIN\_REG and ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_MAX\_REG .
- Configure SP threshold with ASSIST\_DEBUG\_CORE\_0\_SP\_MIN\_REG and ASSIST\_DEBUG\_CORE\_0\_SP\_MAX\_REG .

## 2. Configure interrupts.

- Configure ASSIST\_DEBUG\_CORE\_0\_INTR\_ENA\_REG to enable the interrupt of a monitoring mode.
- Configure ASSIST\_DEBUG\_CORE\_0\_INTR\_RAW\_REG to get the interrupt status of a monitoring mode.
- Configure ASSIST\_DEBUG\_CORE\_0\_INTR\_CLR\_REG to clear the interrupt of a monitoring mode.
3. Configure ASSIST\_DEBUG\_CORE\_0\_MONTR\_ENA\_REG to enable the monitoring mode(s). Various monitoring modes can be enabled at the same time.

Assuming that Debug Assistant needs to monitor whether Data bus has written to [A ~ B] address space, the user can enable monitoring in either Data bus region 0 or region 1. The following configuration process is based on region 0:

1. Configure ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MIN\_REG to A.
2. Configure ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MAX\_REG to B.
3. Configure ASSIST\_DEBUG\_CORE\_0\_INTR\_ENA\_REG bit[1] to enable the interrupt for write operations by Data bus in region 0.
4. Configure ASSIST\_DEBUG\_CORE\_0\_MONTR\_ENA\_REG bit[1] to enable monitoring write operations by Data bus in region 0.
5. Configure interrupt matrix to map ASSIST\_DEBUG\_INT into CPU interrupt (please refer to Chapter 8 Interrupt Matrix (INTERRUPT)).
6. After the interrupt is triggered:
- Read ASSIST\_DEBUG\_CORE\_0\_INTR\_RAW\_REG to learn which operation triggered interrupt.
- If the interrupt is triggered by region monitoring, read ASSIST\_DEBUG\_CORE\_0\_AREA\_PC\_REG for the PC value, and ASSIST\_DEBUG\_CORE\_0\_AREA\_SP\_REG for the SP.
- If the interrupt is triggered by stack monitoring, read ASSIST\_DEBUG\_CORE\_0\_SP\_PC\_REG for the PC value.
- Write '1' to the corresponding bits of ASSIST\_DEBUG\_CORE\_0\_INTR\_RAW\_REG to clear the interrupts.

## 17.4.2 PC Logging Configuration Process

The CPU sends PC signals to Debug Assistant. Only when ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGEN is 1, the PC signal is valid, otherwise, it is always 0.

Only when ASSIST\_DEBUG\_CORE\_0\_RCD\_RECORDEN is 1, ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC\_REG samples the CPU's PC signals, otherwise, it keeps the original value.

The description of ASSIST\_DEBUG\_CORE\_0\_RCD\_EN\_REG and ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC\_REG can be found in section 17.18 and 17.19 .

When the CPU resets, ASSIST\_DEBUG\_CORE\_0\_RCD\_EN\_REG will reset, while ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC\_REG will not. Therefore, the latter will keep the PC value at the CPU reset.

## 17.4.3 CPU/DMA Bus Access Logging Configuration Process

The configuration process for CPU/DMA bus access logging is described below.

1. Configure monitored address space.
- Configure ASSIST\_DEBUG\_LOG\_MIN\_REG and ASSIST\_DEBUG\_LOG\_MAX\_REG to specify monitored address space.
2. Configure monitoring mode with ASSIST\_DEBUG\_LOG\_MODE:
- write monitoring (whether the bus has write operations)
- word monitoring (whether the bus writes a specific word)
- halfword monitoring (whether the bus writes a specific halfword)
- byte monitoring (whether the bus writes a specific byte)
3. Configure the specific values to be monitored.
- In word monitoring mode, ASSIST\_DEBUG\_LOG\_DATA\_0\_REG specifies the monitored word.
- In halfword monitoring mode, ASSIST\_DEBUG\_LOG\_DATA\_0\_REG[15:0] specifies the monitored halfword.
- In byte monitoring mode, ASSIST\_DEBUG\_LOG\_DATA\_0\_REG[7:0] specifies the monitored byte.
- ASSIST\_DEBUG\_LOG\_DATA\_MASK\_REG is used to mask the byte specified in ASSIST\_DEBUG\_LOG\_DATA\_0\_REG. A masked byte can be any value. For example, in word monitoring, ASSIST\_DEBUG\_LOG\_DATA\_0\_REG is configured to 0x01020304, and ASSIST\_DEBUG\_LOG\_DATA\_MASK\_REG is configured to 0x1, then bus writes with data matching to 0x010203XX pattern will be recorded.
4. Configure the storage space for recorded data.
- ASSIST\_DEBUG\_LOG\_MEM\_START\_REG and ASSIST\_DEBUG\_LOG\_MEM\_END\_REG specify the storage space for recorded data. The storage space must be in the range of 0x3FCC\_0000 ~ 0x3FCD\_FFFF.
- Configure the permission for the Debug Assistant module to access the internal SRAM. Only if the access permission is enabled, the Debug Assistant module is able to access the internal SRAM. For more information please refer to Chapter 14 Permission Control (PMS)).
5. Configure the writing mode for recorded data: loop mode and non-loop mode.

- In loop mode, writing to specified address space is performed in loops. When writing reaches the end address, it will return to the starting address and continue, overwriting the previously recorded data.

For example, 10 writes (1 ~ 10) write to address space 0 ~ 4. After the 5th write writes to address 4, the 6th write will start writing from address 0. The 6th to 10th writes will overwrite the previous data written by 0 ~ 4 writes.

- In non-loop mode, when writing reaches the end address, it will stop at the end address, not overwriting the previously recorded data.
- For example, 10 writes (1 ~ 10) write to address space 0 ~ 4. After the 5th write writes to address 4, the 6th to 10th writes will write at address 4. Only the data written by the last (10th) write will be retained at address 4.
6. Configure bus enable registers.
- Enable CPU or DMA bus access logging with ASSIST\_DEBUG\_LOG\_ENA. CPU and DMA bus access logging can be enabled at the same time.

When bus access logging is finished, the recorded data can be read from memory for decoding. The recorded data is in two packet formats, namely CPU packet (corresponding to CPU bus) and DMA packet (corresponding to DMA bus). The packet formats are shown in Table 17.4-1 and 17.4-2:

Table 17.4-1. CPU Packet Format

| Bit[49:29]   | Bit[28:2]   | Bit[1:0]   |
|--------------|-------------|------------|
| addr_offset  | pc_offset   | format     |

Table 17.4-2. DMA Packet Format

| Bit[24:6]   | Bit[5:2]   | Bit[1:0]   |
|-------------|------------|------------|
| addr_offset | dma_source | format     |

It can be seen from the data packet formats that the CPU packet size is 50 bits and DMA packet size 25 bits. The packet formats contain the following fields:

- format – the packet type. 1: CPU packet; 3: DMA packet; other values: reserved.
- pc\_offset – the offset of the PC register at time of access. Actual PC = pc\_offset + 0x4000\_0000.
- addr\_offset – the address offset of a write operation. Actual adddress = addr\_offset + ASSIST\_DEBUG\_LOG\_MIN\_REG .
- dma\_source – the source of DMA access. Refer to Table 17.4-3 .

Table 17.4-3. DMA Source

|   Value | Source   |
|---------|----------|
|       1 | SPI2     |
|       2 | reserved |
|       3 | reserved |
|       4 | AES      |

|   Value | Source   |
|---------|----------|
|       5 | SHA      |
|       6 | ADC      |
|       7 | I2S      |
|       8 | reserved |
|       9 | reserved |
|      10 | reserved |
|      11 | UHCI0    |
|      12 | reserved |
|      13 | reserved |
|      14 | reserved |
|      15 | reserved |

The packets are stored in the internal buffer first. When the buffered data reaches 125 bits, it will be expanded to 128 bits and written to the internal SRAM. The written data format is shown in Table 17.4-4 .

Table 17.4-4. Written Data Format

| Bit[127:3]    | Bit[2:0]   |
|---------------|------------|
| Valid packets | START_FLAG |

Since the CPU packet size is 50 bits and the DMA packet size 25 bits, the recorded data in each record is at least 25 bits and at most 75 bits. When the data stored in the internal buffer reaches 125 bits, it will be popped into memory. There are cases where a packet is divided into two portions: the first portion is written to memory, and the second portion is left in the buffer and will be popped into memory in the next write. The data left in the buffer is called residual data. The value of START\_FLAG records the number of residual bits left from the last write to memory. The number of residual bits is START\_FLAG * 25. START\_FLAG also indicates the starting bit of the first valid packet in the current write. As an example: Assume that four DMA writes have generated four DMA packets to be stored in the buffer with a total of 100-bit data. Then, one CPU write occurs and generates one 50-bit CPU packet. The buffer will pop the previously-recorded 100-bit data plus the first 25 bits in the CPU packet into SRAM. The remaining 25 bits in the CPU packet is left in the buffer, waiting for the next write. START\_FLAG in the next write will indicate that 25 bits in this write is from the last write.

In loop writing mode, if data is looped several times in the storage memory, the residual data will interfere with packet parsing. Therefore, users need to filter out the residual data in order to determine the starting position of the first valid packet with START\_FLAG and ASSIST\_DEBUG\_LOG\_MEM\_CURRENT\_ADDR\_REG. Once the starting position of the packet is identified, the subsequent data is continuous and users do not need to care about the value of START\_FLAG.

Note that if data in the buffer does not reach 125 bits, it will not be written to memory. All data should be written to memory for packet parsing. This can be done by disabling bus access logging. When ASSIST\_DEBUG\_LOG\_ENA is set to 0, if there is data in the buffer, it will be padded with zeros from the left until it becomes 128 bits long and written to the memory.

The process of packet parsing is described below:

- Determine whether there is a data overflow with ASSIST\_DEBUG\_LOG\_MEM\_FULL\_FLAG. If there is no overflow, ASSIST\_DEBUG\_LOG\_MEM\_START\_REG is the starting address of the first packet. If there is an

overflow and loop mode is enabled, ASSIST\_DEBUG\_LOG\_MEM\_CURRENT\_ADDR\_REG is the starting address of the first packet.

- Read and parse data from the starting address. Read 128 bits each time.
- Use START\_FLAG to determine the starting bit of the first packet. Starting bit = START\_FLAG * 25 + 3.

Note that START\_FLAG is only used to locate the starting bit of the first packet. Once the starting bit is located, START\_FLAG should be filtered out in the subsequent data.

After packet parsing is completed, clear the ASSIST\_DEBUG\_LOG\_MEM\_FULL\_FLAG flag bit by setting ASSIST\_DEBUG\_CLR\_LOG\_MEM\_FULL\_FLAG .

![Image](images/17_Chapter_17_img001_3157057d.png)

## 17.5 Register Summary

The addresses in this section are relative to Debug Assistant base address provided in Table 3.3-3 in Chapter 3 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                                     | Description                                                             | Address   | Access   |
|------------------------------------------|-------------------------------------------------------------------------|-----------|----------|
| Monitor configuration registers          |                                                                         |           |          |
| ASSIST_DEBUG_CORE_0_MONTR_ENA_REG        | Monitoring enable register                                              | 0x0000    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_DRAM0_0_MIN_REG | Configures boundary ad dress of region 0 moni tored on Data bus       | 0x0010    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_DRAM0_0_MAX_REG | Configures boundary ad dress of region 0 moni tored on Data bus       | 0x0014    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_DRAM0_1_MIN_REG | Configures boundary ad dress of region 1 moni tored on Data bus       | 0x0018    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_DRAM0_1_MAX_REG | Configures boundary ad dress of region 1 moni tored on Data bus       | 0x001C    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PIF_0_MIN_REG   | Configures boundary ad dress of region 0 moni tored on Peripheral bus | 0x0020    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PIF_0_MAX_REG   | Configures boundary ad dress of region 0 moni tored on Peripheral bus | 0x0024    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PIF_1_MIN_REG   | Configures boundary ad dress of region 1 moni tored on Peripheral bus | 0x0028    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PIF_1_MAX_REG   | Configures boundary ad dress of region 1 moni tored on Peripheral bus | 0x002C    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PC_REG          | Region monitoring PC sta tus register                                  | 0x0030    | RO       |
| ASSIST_DEBUG_CORE_0_AREA_SP_REG          | Region monitoring SP sta tus register                                  | 0x0034    | RO       |
| ASSIST_DEBUG_CORE_0_SP_MIN_REG           | Configures stack monitor ing boundary address                          | 0x0038    | R/W      |
| ASSIST_DEBUG_CORE_0_SP_MAX_REG           | Configures stack monitor ing boundary address                          | 0x003C    | R/W      |
| ASSIST_DEBUG_CORE_0_SP_PC_REG            | Stack monitoring PC sta tus register                                   | 0x0040    | RO       |
| Interrupt configuration registers        |                                                                         |           |          |
| ASSIST_DEBUG_CORE_0_INTR_RAW_REG         | Interrupt status register                                               | 0x0004    | RO       |

| Name                                            | Description                                                             | Address   | Access   |
|-------------------------------------------------|-------------------------------------------------------------------------|-----------|----------|
| ASSIST_DEBUG_CORE_0_INTR_ENA_REG                | Interrupt enable register                                               | 0x0008    | R/W      |
| ASSIST_DEBUG_CORE_0_INTR_CLR_REG                | Interrupt clear register                                                | 0x000C    | R/W      |
| PC logging configuration register               |                                                                         |           |          |
| ASSIST_DEBUG_CORE_0_RCD_EN_REG                  | PC logging enable register                                              | 0x0044    | R/W      |
| PC logging status registers                     |                                                                         |           |          |
| ASSIST_DEBUG_CORE_0_RCD_PDEBUGPC_REG            | PC logging register                                                     | 0x0048    | RO       |
| ASSIST_DEBUG_CORE_0_RCD_PDEBUGSP_REG            | PC logging register                                                     | 0x004C    | RO       |
| Bus access logging configuration registers      |                                                                         |           |          |
| ASSIST_DEBUG_LOG_SETTING_REG                    | Bus access logging con figuration register                             | 0x0070    | R/W      |
| ASSIST_DEBUG_LOG_DATA_0_REG                     | Configures monitored data in Bus access log ging                       | 0x0074    | R/W      |
| ASSIST_DEBUG_LOG_DATA_MASK_REG                  | Configures masked data in Bus access logging                            | 0x0078    | R/W      |
| ASSIST_DEBUG_LOG_MIN_REG                        | Configures monitored ad dress space in Bus ac cess logging            | 0x007C    | R/W      |
| ASSIST_DEBUG_LOG_MAX_REG                        | Configures monitored ad dress space in Bus ac cess logging            | 0x0080    | R/W      |
| ASSIST_DEBUG_LOG_MEM_START_REG                  | Configures the starting address of the storage memory for recorded data | 0x0084    | R/W      |
| ASSIST_DEBUG_LOG_MEM_END_REG                    | Configures the end ad dress of the storage mem ory for recorded data  | 0x0088    | R/W      |
| ASSIST_DEBUG_LOG_MEM_CURRENT_ADDR_REG           | The current address of the storage memory for recorded data             | 0x008C    | RO       |
| ASSIST_DEBUG_LOG_MEM_FULL_FLAG_REG              | Logging overflow status register                                        | 0x0090    | varies   |
| CPU status registers                            |                                                                         |           |          |
| ASSIST_DEBUG_CORE_0_LASTPC_BEFORE_EXCEPTION_REG | PC of the last command before CPU enters excep tion                    | 0x0094    | RO       |
| ASSIST_DEBUG_CORE_0_DEBUG_MODE_REG              | CPU debug mode status register                                          | 0x0098    | RO       |
| Version register                                |                                                                         |           |          |
| ASSIST_DEBUG_DATE_REG                           | Version control register                                                | 0x01FC    | R/W      |

## 17.6 Registers

The addresses in this section are relative to Debug Assistant base address provided in Table 3.3-3 in Chapter 3 System and Memory .

Register 17.1. ASSIST\_DEBUG\_CORE\_0\_MONTR\_ENA\_REG (0x0000)

![Image](images/17_Chapter_17_img002_de6b6fe6.png)

- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_RD\_ENA Monitoring enable bit for read operations in region 0 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_WR\_ENA Monitoring enable bit for write operations in region 0 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_RD\_ENA Monitoring enable bit for read operations in region 1 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_WR\_ENA Monitoring enable bit for write operations in region 1 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_RD\_ENA Monitoring enable bit for read operations in region 0 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_WR\_ENA Monitoring enable bit for write operations in region 0 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_RD\_ENA Monitoring enable bit for read operations in region 1 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_WR\_ENA Monitoring enable bit for write operations in region 1 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MIN\_ENA Monitoring enable bit for SP exceeding the lower bound address of SP monitored region. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MAX\_ENA Monitoring enable bit for SP exceeding the upper bound address of SP monitored region. (R/W)

Register 17.2. ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MIN\_REG (0x0010)

![Image](images/17_Chapter_17_img003_4687d95d.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MIN The lower bound address of Data bus region 0. (R/W)

Register 17.3. ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MAX\_REG (0x0014)

![Image](images/17_Chapter_17_img004_506e79aa.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MAX The upper bound address of Data bus region 0. (R/W)

Register 17.4. ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MIN\_REG (0x0018)

![Image](images/17_Chapter_17_img005_617e0ed5.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MIN The lower bound address of Data bus region 1. (R/W)

![Image](images/17_Chapter_17_img006_b15f2ef3.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MAX The upper bound address of Data bus region 1. (R/W)

Register 17.6. ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_MIN\_REG (0x0020)

![Image](images/17_Chapter_17_img007_36519f82.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_MIN The lower bound address of Peripheral bus region 0. (R/W)

Register 17.7. ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_MAX\_REG (0x0024)

![Image](images/17_Chapter_17_img008_7e7534fe.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_MAX The upper bound address of Peripheral bus region 0. (R/W)

31

Register 17.8. ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_MIN\_REG (0x0028)

![Image](images/17_Chapter_17_img009_c92bed64.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_MIN The lower bound address of Peripheral bus region 1. (R/W)

Register 17.9. ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_MAX\_REG (0x002C)

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_MAX

0

Reset

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_MAX The upper bound address of Peripheral bus region 1. (R/W)

## Register 17.10. ASSIST\_DEBUG\_CORE\_0\_AREA\_PC\_REG (0x0030)

![Image](images/17_Chapter_17_img010_be2a7ca5.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_PC Records the PC value when interrupt triggers during region monitoring. (RO)

0

## Register 17.11. ASSIST\_DEBUG\_CORE\_0\_AREA\_SP\_REG (0x0034)

![Image](images/17_Chapter_17_img011_ebf49052.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_SP Records SP when interrupt triggers during region monitoring. (RO)

## Register 17.12. ASSIST\_DEBUG\_CORE\_0\_SP\_MIN\_REG (0x0038)

![Image](images/17_Chapter_17_img012_28d2e3e2.png)

ASSIST\_DEBUG\_CORE\_0\_SP\_MIN The lower bound address of SP. (R/W)

Register 17.13. ASSIST\_DEBUG\_CORE\_0\_SP\_MAX\_REG (0x003C)

![Image](images/17_Chapter_17_img013_880f539b.png)

ASSIST\_DEBUG\_CORE\_0\_SP\_MAX The upper bound address of SP. (R/W)

## Register 17.14. ASSIST\_DEBUG\_CORE\_0\_SP\_PC\_REG (0x0040)

![Image](images/17_Chapter_17_img014_ff6a1428.png)

ASSIST\_DEBUG\_CORE\_0\_SP\_PC Records the PC value during stack monitoring. (RO)

## Register 17.15. ASSIST\_DEBUG\_CORE\_0\_INTR\_RAW\_REG (0x0004)

![Image](images/17_Chapter_17_img015_45cd7006.png)

- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_RD\_RAW Interrupt status bit for read operations in region 0 by the Data bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_WR\_RAW Interrupt status bit for write operations in region 0 by the Data bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_RD\_RAW Interrupt status bit for read operations in region 1 by the Data bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_WR\_RAW Interrupt status bit for write operations in region 1 by the Data bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_RD\_RAW Interrupt status bit for read operations in region 0 by the Peripheral bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_WR\_RAW Interrupt status bit for write operations in region 0 by the Peripheral bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_RD\_RAW Interrupt status bit for read operations in region 1 by the Peripheral bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_WR\_RAW Interrupt status bit for write operations in region 1 by the Peripheral bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MIN\_RAW Interrupt status bit for SP exceeding the lower bound address of SP monitored region. (RO)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MAX\_RAW Interrupt status bit for SP exceeding the upper bound address of SP monitored region. (RO)

![Image](images/17_Chapter_17_img016_54e224b3.png)

## Register 17.16. ASSIST\_DEBUG\_CORE\_0\_INTR\_ENA\_REG (0x0008)

![Image](images/17_Chapter_17_img017_aff748d6.png)

- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_RD\_INTR\_ENA Interrupt enable bit for read operations in region 0 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_WR\_INTR\_ENA Interrupt enable bit for write operations in region 0 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_RD\_INTR\_ENA Interrupt enable bit for read operations in region 1 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_WR\_INTR\_ENA Interrupt enable bit for write operations in region 1 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_RD\_INTR\_ENA Interrupt enable bit for read operations in region 0 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_WR\_INTR\_ENA Interrupt enable bit for write operations in region 0 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_RD\_INTR\_ENA Interrupt enable bit for read operations in region 1 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_WR\_INTR\_ENA Interrupt enable bit for write operations in region 1 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MIN\_INTR\_ENA Interrupt enable bit for SP exceeding the lower bound address of SP monitored region. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MAX\_INTR\_ENA Interrupt enable bit for SP exceeding the upper bound address of SP monitored region. (R/W)

## Register 17.17. ASSIST\_DEBUG\_CORE\_0\_INTR\_CLR\_REG (0x000C)

![Image](images/17_Chapter_17_img018_6f6512bf.png)

- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_RD\_CLR Interrupt clear bit for read operations in region 0 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_WR\_CLR Interrupt clear bit for write operations in region 0 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_RD\_CLR Interrupt clear bit for read operations in region 1 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_WR\_CLR Interrupt clear bit for write operations in region 1 by the Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_RD\_CLR Interrupt clear bit for read operations in region 0 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_WR\_CLR Interrupt clear bit for write operations in region 0 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_RD\_CLR Interrupt clear bit for read operations in region 1 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_WR\_CLR Interrupt clear bit for write operations in region 1 by the Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MIN\_CLR Interrupt clear bit for SP exceeding the lower bound address of SP monitored region. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MAX\_CLR Interrupt clear bit for SP exceeding the upper bound address of SP monitored region. (R/W)

## Register 17.18. ASSIST\_DEBUG\_CORE\_0\_RCD\_EN\_REG (0x0044)

![Image](images/17_Chapter_17_img019_bd6c540d.png)

ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC Records the PC value at CPU reset. (RO)

## Register 17.20. ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGSP\_REG (0x004C)

![Image](images/17_Chapter_17_img020_5dfda7bb.png)

ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGSP Records SP. (RO)

## Register 17.21. ASSIST\_DEBUG\_LOG\_SETTING\_REG (0x0070)

![Image](images/17_Chapter_17_img021_2a61ad65.png)

ASSIST\_DEBUG\_LOG\_ENA Enables the CPU bus or DMA bus access logging. bit[0]: CPU bus access logging; bit[1]: reserved; bit[2]: DMA bus access logging. (R/W)

ASSIST\_DEBUG\_LOG\_MODE Configures monitoring mode. bit[0]: write monitoring; bit[1]: word monitoring; bit[2]: halfword monitoring; bit[3]: byte monitoring. (R/W)

ASSIST\_DEBUG\_LOG\_MEM\_LOOP\_ENABLE Configures the writing mode for recorded data. 1: loop mode; 0: non-loop mode. (R/W)

![Image](images/17_Chapter_17_img022_c211b72c.png)

## Register 17.25. ASSIST\_DEBUG\_LOG\_MAX\_REG (0x0080)

ASSIST\_DEBUG\_LOG\_MAX

![Image](images/17_Chapter_17_img023_f64836e5.png)

ASSIST\_DEBUG\_LOG\_MAX Configures the upper bound address of monitored address space.

(R/W)

## Register 17.26. ASSIST\_DEBUG\_LOG\_MEM\_START\_REG (0x0084)

ASSIST\_DEBUG\_LOG\_MEM\_START

![Image](images/17_Chapter_17_img024_9a4d068a.png)

ASSIST\_DEBUG\_LOG\_MEM\_START Configures the starting address of the storage space for recorded data. (R/W)

## Register 17.27. ASSIST\_DEBUG\_LOG\_MEM\_END\_REG (0x0088)

ASSIST\_DEBUG\_LOG\_MEM\_END

![Image](images/17_Chapter_17_img025_a52e052f.png)

ASSIST\_DEBUG\_LOG\_MEM\_END Configures the end address of the storage space for recorded data. (R/W)

## Register 17.28. ASSIST\_DEBUG\_LOG\_MEM\_CURRENT\_ADDR\_REG (0x008C)

![Image](images/17_Chapter_17_img026_66416258.png)

ASSIST\_DEBUG\_LOG\_MEM\_WRITING\_ADDR Indicates the address of the next write. (RO)

Register 17.29. ASSIST\_DEBUG\_LOG\_MEM\_FULL\_FLAG\_REG (0x0090)

![Image](images/17_Chapter_17_img027_9d67ba4a.png)

![Image](images/17_Chapter_17_img028_7019ac64.png)

Register 17.32. ASSIST\_DEBUG\_DATE\_REG (0x01FC)

![Image](images/17_Chapter_17_img029_4077108f.png)

ASSIST\_DEBUG\_\_DATE Version control register. (R/W)

## Part IV

## Cryptography/Security Component

Dedicated to security features, this part explores cryptographic accelerators like SHA and AES. It also covers digital signatures, random number generation, and encryption/decryption algorithms, showcasing the SoC's capabilities in cryptography and secure data processing.
