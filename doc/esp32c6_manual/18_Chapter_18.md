---
chapter: 18
title: "Chapter 18"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 18

## Debug Assistant (ASSIST\_DEBUG)

## 18.1 Overview

Debug Assistant is an auxiliary module that features a set of functions to help locate bugs and issues during software debugging.

## 18.2 Features

- Read/write monitoring: Monitors whether the High-Performance CPU (HP CPU) bus reads from or writes to a specified memory address space. A detected read or write in the monitored address space will trigger an interrupt.
- Stack pointer (SP) monitoring: Monitors whether the SP exceeds the specified address space. A bounds violation will trigger an interrupt.
- Program counter (PC) logging: Records PC value. The developer can get the last PC value at the most recent HP CPU reset.
- Bus access logging: Records the information about bus access. When the HP CPU, LP CPU, or Direct Memory Access controller (DMA) writes a specified value, the Debug Assistant module will record the data type, address of this write operation, and additionally the PC value when the write is performed by the HP CPU, and push such information to the HP SRAM.

## 18.3 Functional Description

## 18.3.1 Region Read/Write Monitoring

The Debug Assistant module can monitor reads/writes performed by the HP CPU over Data bus and Peripheral bus in a certain address space, i.e., memory region. Whenever the bus reads or writes in the specified address space, an interrupt will be triggered. The Data bus can monitor two memory regions (assuming they are region 0 and region 1, defined by developers' needs) at the same time, and so can Peripheral Bus.

## 18.3.2 SP Monitoring

The Debug Assistant module can monitor the SP so as to prevent stack overflow or erroneous push/pop. When the stack pointer exceeds the minimum or maximum threshold, the module will record the PC pointer and generate an interrupt. The threshold is configured by software.

## 18.3.3 PC Logging

In some cases, software developers want to know the PC at the last HP CPU reset. For instance, when the program is stuck and can only be reset, the developer may want to know where the program got stuck in order to debug. The Debug Assistant module can record the PC at the last HP CPU reset, which can be then read for software debugging.

## 18.3.4 CPU/DMA Bus Access Logging

The Debug Assistant module can record the information about the HP CPU Data bus's, LP CPU bus's, and DMA bus's write behaviors in real time. When a write operation occurs in or a specific value is written to a specified address space, the module will record the bus type, the address, PC (only when the write is performed by the HP CPU will PC be recorded), and other information, and then store the data in the HP SRAM in a certain format.

## 18.4 Recommended Operation

## 18.4.1 Region Monitoring and SP Monitoring Configuration

The Debug Assistant module can monitor reads and writes performed by the HP CPU's Data bus and Peripheral bus. Two memory regions on each bus can be monitored at the same time. All the monitoring modes supported by the Debug Assistant module are listed below:

- Monitoring of the read/write operations performed by Data bus
- – Data bus reads in region 0
- – Data bus writes in region 0
- – Data bus reads in region 1
- – Data bus writes in region 1
- Monitoring of the read/write operations performed by Peripheral bus
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

Assuming that Debug Assistant module needs to monitor whether Data bus has written to [A ~ B] address space, the user can enable monitoring in either Data bus region 0 or region 1. The following configuration process is based on region 0:

1. Configure ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGEN to 1 to enable HP CPU to update the PC signals to the Debug Assistant module.
2. Configure ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MIN\_REG to Address A.
3. Configure ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MAX\_REG to Address B.
4. Configure ASSIST\_DEBUG\_CORE\_0\_INTR\_ENA\_REG bit[1] to enable the interrupt for write operations by Data bus in region 0.
5. Configure ASSIST\_DEBUG\_CORE\_0\_MONTR\_ENA\_REG bit[1] to enable monitoring write operations by Data bus in region 0.
6. Configure interrupt matrix to map ASSIST\_DEBUG\_INT into HP CPU interrupt (please refer to Chapter 10 Interrupt Matrix (INTMTX)).
7. After the interrupt is triggered:
- Read ASSIST\_DEBUG\_CORE\_0\_INTR\_RAW\_REG to learn which operation triggered the interrupt.
- If the interrupt is triggered by region monitoring, read ASSIST\_DEBUG\_CORE\_0\_AREA\_PC\_REG for the PC value, and ASSIST\_DEBUG\_CORE\_0\_AREA\_SP\_REG for the SP.
- If the interrupt is triggered by stack monitoring, read ASSIST\_DEBUG\_CORE\_0\_SP\_PC\_REG for the PC value.
- Write 1 to the corresponding bits of ASSIST\_DEBUG\_CORE\_0\_INTR\_RAW\_REG to clear the interrupts.

## 18.4.2 PC Logging Configuration

Configure ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGEN to 1 to enable HP CPU to update the PC signals to the Debug Assistant module. If ASSIST\_DEBUG\_CORE\_0\_RCD\_RECORDEN is also configured to 1, ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC\_REG will record the HP CPU's PC signal and ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGSP\_REG will record the SP value. Otherwise, the two registers keep the original values.

When the CPU resets, ASSIST\_DEBUG\_CORE\_0\_RCD\_EN\_REG will reset, while ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC\_REG and ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGSP\_REG will not. Therefore, the two registers will keep the PC value and SP value at the CPU reset.

## 18.4.3 CPU/DMA Bus Access Logging Configuration

The configuration process for CPU/DMA bus access logging is described below.

1. Configure monitored address space.
- Configure MEM\_MONITOR\_LOG\_MIN\_REG and MEM\_MONITOR\_LOG\_MAX\_REG to specify monitored address space.
2. Configure the monitoring mode with MEM\_MONITOR\_LOG\_MODE:
- write monitoring (whether the bus has write operations)
- word monitoring (whether the bus writes a specific word)
- halfword monitoring (whether the bus writes a specific halfword)
- byte monitoring (whether the bus writes a specific byte)
3. Configure the specific values to be monitored.
- In word monitoring mode, MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG specifies the monitored word.
- In halfword monitoring mode, MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG[15:0] specifies the monitored halfword.
- In byte monitoring mode, MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG[7:0] specifies the monitored byte.
- MEM\_MONITOR\_LOG\_DATA\_MASK\_REG is used to mask the byte specified in MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG. A masked byte can be any value. For example, in word monitoring, if MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG is configured to 0x01020304 and MEM\_MONITOR\_LOG\_DATA\_MASK\_REG is configured to 0x1, then any writes of the data matching the 0x010203XX pattern by the bus will be recorded.
4. Configure the storage space for recorded data.
- MEM\_MONITOR\_LOG\_MEM\_START\_REG and MEM\_MONITOR\_LOG\_MEM\_END\_REG specify the storage space for recorded data. The storage space must be in the range of 0x4080\_0000 ~ 0x4087\_FFFF.
- Set MEM\_MONITOR\_LOG\_MEM\_ADDR\_UPDATE\_REG to update the value in MEM\_MONITOR\_LOG\_MEM\_START\_REG to MEM\_MONITOR\_LOG\_MEM\_ CURRENT\_ADDR\_REG .

- Configure the permission for the Debug Assistant module to access the internal HP SRAM. Only when the access permission is enabled can the Debug Assistant module access the internal HP SRAM. For more information, please refer to Chapter 16 Permission Control (PMS) .
5. Configure the writing mode for the recorded data: loop mode or non-loop mode.
- In loop mode, writing to the specified address space is performed in loops. When writing reaches the end address, it will return to the starting address and continue, overwriting the previously recorded data. Set MEM\_MONITOR\_LOG\_MEM\_LOOP\_ENABLE to enable loop mode. For example, there are 10 write operations (1 ~ 10) to address space 0 ~ 4 during bus access. After the 5th operation writes to address 4, the 6th operation will start writing from address 0. The 6th to 10th operations will overwrite the previous data written by the 1th to 5th operations.
- In non-loop mode, when writing reaches the end address, it will stop at the end address and dump the remaining data, not overwriting the previously recorded data. Clear MEM\_MONITOR\_LOG\_MEM\_LOOP\_ENABLE to use non-loop mode.
- For example, there are 10 write operations (1 ~ 10) to address space 0 ~ 4 during bus access. After the 5th operation writes to address 4, the 6th to 10th write operations will stop at address 4 and will not be performed any more. Therefore, the address 0 ~ 4 stores the values written by the 1 ~ 5 ~
- operations and the values of the 6 10 operations are dumped.
6. Configure bus enable registers.
- Enable HP CPU, LP CPU, or DMA bus access logging with MEM\_MONITOR\_LOG\_ENA. They can be enabled at the same time.

The Debug Assistant module first writes the recorded data to an internal buffer, and then fetches the data from the buffer and writes it to the configured memory space. When the monitored behaviors are triggered continuously, the generated recording packets may fully occupy the buffer, making it unable to take any incoming packets. At this time, the module dumps these incoming packets and buffers a LOST packet instead before the buffer reaches its capacity. However, the bus type and the number of these dumped packets are unknown.

When bus access logging is finished, the recorded data can be read from memory for decoding. The recorded data is in four packet formats, namely HP CPU packet (corresponding to HP CPU Data bus), LP CPU packet (corresponding to LP CPU bus), DMA packet (corresponding to DMA bus), and LOST packet. The packet formats are shown in Table 18.4-1 , 18.4-2 , 18.4-3, and 18.4-4 .

Table 18.4-1. HP CPU Packet Format

| Bit[63:34]   | Bit[33:32]   | Bit[31:4]   | Bit[3:2]   | Bit[1:0]    |
|--------------|--------------|-------------|------------|-------------|
| pc_offset    | anchored(2)  | addr_offset | format     | anchored(1) |

Table 18.4-2. LP CPU Packet Format

Table 18.4-3. DMA Packet Format

| Bit[31:4]   | Bit[3:2]   | Bit[1:0]    |
|-------------|------------|-------------|
| addr_offset | format     | anchored(1) |

| Bit[31:9]   | Bit[8:4]   | Bit[3:2]   | Bit[1:0]    |
|-------------|------------|------------|-------------|
| addr_offset | dma_source | format     | anchored(1) |

Table 18.4-4. LOST Packet Format

| Bit[31:4]   | Bit[3:2]   | Bit[1:0]    |
|-------------|------------|-------------|
| reserved    | format     | anchored(1) |

It can be seen from the data packet formats that the HP CPU packet size is 64 bits, LP CPU packet 32 bits, DMA packet size 32 bits, and LOST packet 32 bits. These packets contain the following fields:

- format – the packet type. 0: HP CPU packet; 1: DMA packet; 2: LP CPU packet; 3: LOST packet.
- pc\_offset - the offset of the PC register at the time of access. Actual PC = pc\_offset + 0x4000\_0000.
- addr\_offset - the address offset of a write operation. Actual address = addr\_offset + MEM\_MONITOR\_LOG\_MIN\_REG .
- dma\_source - the source of DMA access. Refer to Table 18.4-5. For more information on the values 16 ~ 31 in the table, please refer to 4 GDMA Controller (GDMA) .
- anchored - the location of the 32 bits in the data packet. 1 indicates the lower 32 bits. 2 indicates the higher 32 bits.

Table 18.4-5. DMA Access Source

| Value   | Source                                                                                                                                                                                                                                                                                                                                                                        |
|---------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| 0       | HP CPU                                                                                                                                                                                                                                                                                                                                                                        |
| 1       | LP CPU                                                                                                                                                                                                                                                                                                                                                                        |
| 2       | reserved                                                                                                                                                                                                                                                                                                                                                                      |
| 3       | SDIO_SLV                                                                                                                                                                                                                                                                                                                                                                      |
| 4       | reserved                                                                                                                                                                                                                                                                                                                                                                      |
| 5       | MEM_MONITOR                                                                                                                                                                                                                                                                                                                                                                   |
| 6       | TRACE                                                                                                                                                                                                                                                                                                                                                                         |
| 7 ~ 15  | reserved                                                                                                                                                                                                                                                                                                                                                                      |
| 16 ~ 31 | See the peripherals corresponding to the values 0 ~  15 in Chapter 4 GDMA Controller (GDMA) > Table 4.4-1 Selecting Peripherals via Register Configura tion. For example, the source corresponding to the value 16 is the peripheral corresponding to the value 0 in that table, the source corresponding to 17 is the peripheral corresponding to 1 in that table, and etc. |

The internal buffer of the module is 32 bits wide. When the HP CPU, LP CPU, or DMA bus access logging are all enabled at the same time and the record data is generated at the same time, the DMA data packets are first buffered, then the HP CPU packets, and finally the LP CPU packets. This priority of buffering packets also applies to the case where only two types of packets are generated at the same time. The Debug Assistant will automatically fetch the buffered data and store it in 32-bit data width into the specified memory space.

In loop mode, data looping several times in the storage memory may cause residual data, which can interfere with packet parsing. For example, the lower 32 bits of a HP CPU packet are overwritten, thus making its higher 32 bits residual data. Therefore, users need to filter out the possible residual data in order to determine the starting position of the first valid packet with MEM\_MONITOR\_LOG\_MEM\_CURRENT\_ADDR\_REG. Once the starting position of the packet is identified, check the anchored bit value of the packet. If it is 1, the data will be retained. If it is 2, it will be dumped.

The process of packet parsing is described below:

- Determine whether there is a data overflow with MEM\_MONITOR\_LOG\_MEM\_FULL\_FLAG. If no, the address space to read is MEM\_MONITOR\_LOG\_MEM\_START\_REG ~ MEM\_MONITOR\_LOG\_MEM\_ CURRENT\_ADDR\_REG - 4. If yes and the loop mode is enabled, the address space is MEM\_MONITOR\_ LOG\_MEM\_CURRENT\_ADDR\_REG ~ MEM\_MONITOR\_LOG\_MEM\_END\_REG and MEM\_MONITOR\_ LOG\_MEM\_START\_REG ~ MEM\_MONITOR\_LOG\_MEM\_CURRENT\_ADDR\_REG - 4. If yes and loop mode is not enabled, the address space is MEM\_MONITOR\_LOG\_MEM\_START\_REG ~ MEM\_MONITOR\_ LOG\_MEM\_END\_REG .
- Read and parse data from the starting address. Read 32 bits each time.

After packet parsing is completed, clear the MEM\_MONITOR\_LOG\_MEM\_FULL\_FLAG flag bit by setting MEM\_MONITOR\_CLR\_LOG\_MEM\_FULL\_FLAG .

![Image](images/18_Chapter_18_img001_6866fc22.png)

## 18.5 Register Summary

The addresses of bus logging configuration registers (see 18.5.1) in this section are relative to the MEM\_MONITOR base address. The addresses of other registers (see 18.5.2) are relative to the ASSIST\_DEBUG base address. Both base addresses are provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

## 18.5.1 Summary of Bus Logging Configuration Registers

| Name                                       | Description                                                                            | Address                                    | Access                                     |
|--------------------------------------------|----------------------------------------------------------------------------------------|--------------------------------------------|--------------------------------------------|
| Bus access logging configuration registers | Bus access logging configuration registers                                             | Bus access logging configuration registers | Bus access logging configuration registers |
| MEM_MONITOR_LOG_SETTING_REG                | Bus access logging configura tion register                                            | 0x0000                                     | R/W                                        |
| MEM_MONITOR_LOG_CHECK_DATA_REG             | Configures monitored data in Bus access logging                                        | 0x0004                                     | R/W                                        |
| MEM_MONITOR_LOG_DATA_MASK_REG              | Configures masked data in Bus access logging                                           | 0x0008                                     | R/W                                        |
| MEM_MONITOR_LOG_MIN_REG                    | Configures monitored address space in Bus access logging                               | 0x000C                                     | R/W                                        |
| MEM_MONITOR_LOG_MAX_REG                    | Configures monitored address space in Bus access logging                               | 0x0010                                     | R/W                                        |
| MEM_MONITOR_LOG_MEM_START_REG              | Configures the starting address of the storage memory for recorded data                | 0x0014                                     | R/W                                        |
| MEM_MONITOR_LOG_MEM_END_REG                | Configures the end address of the storage memory for recorded data                     | 0x0018                                     | R/W                                        |
| MEM_MONITOR_LOG_MEM_CURRENT_ADDR_REG       | Represents the address for the next write                                              | 0x001C                                     | RO                                         |
| MEM_MONITOR_LOG_MEM_ADDR_UPDATE_REG        | Updates the address for the next write with the starting address for the recorded data | 0x0020                                     | R/W                                        |
| MEM_MONITOR_LOG_MEM_FULL_FLAG_REG          | Logging overflow status register                                                       | 0x0024                                     | varies                                     |
| Clock control register                     | Clock control register                                                                 | Clock control register                     | Clock control register                     |
| MEM_MONITOR_CLOCK_GATE_REG                 | Register clock control                                                                 | 0x0028                                     | R/W                                        |
| Version control register                   | Version control register                                                               | Version control register                   | Version control register                   |
| MEM_MONITOR_DATE_REG                       | Version control register                                                               | 0x03FC                                     | R/W                                        |

## 18.5.2 Summary of Other Registers

| Name                            | Description   | Address   | Access   |
|---------------------------------|---------------|-----------|----------|
| Monitor configuration registers |               |           |          |

| Name                                     | Description                                                                 | Address   | Access   |
|------------------------------------------|-----------------------------------------------------------------------------|-----------|----------|
| ASSIST_DEBUG_CORE_0_MONTR_ENA_REG        | Monitoring enable register                                                  | 0x0000    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_DRAM0_0_MIN_REG | Configures lower bound ary address of region 0 monitored on Data bus       | 0x0010    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_DRAM0_0_MAX_REG | Configures upper bound ary address of region 0 monitored on Data bus       | 0x0014    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_DRAM0_1_MIN_REG | Configures lower bound ary address of region 1 monitored on Data bus       | 0x0018    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_DRAM0_1_MAX_REG | Configures upper bound ary address of region 1 monitored on Data bus       | 0x001C    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PIF_0_MIN_REG   | Configures lower bound ary address of region 0 monitored on Peripheral bus | 0x0020    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PIF_0_MAX_REG   | Configures upper bound ary address of region 0 monitored on Peripheral bus | 0x0024    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PIF_1_MIN_REG   | Configures lower bound ary address of region 1 monitored on Peripheral bus | 0x0028    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PIF_1_MAX_REG   | Configures upper bound ary address of region 1 monitored on Peripheral bus | 0x002C    | R/W      |
| ASSIST_DEBUG_CORE_0_AREA_PC_REG          | Region monitoring HP CPU PC status register                                 | 0x0030    | RO       |
| ASSIST_DEBUG_CORE_0_AREA_SP_REG          | Region monitoring HP CPU SP status register                                 | 0x0034    | RO       |
| ASSIST_DEBUG_CORE_0_SP_MIN_REG           | Configures stack monitor ing lower boundary ad dress                      | 0x0038    | R/W      |
| ASSIST_DEBUG_CORE_0_SP_MAX_REG           | Configures stack monitor ing upper boundary ad dress                      | 0x003C    | R/W      |
| ASSIST_DEBUG_CORE_0_SP_PC_REG            | Stack monitoring HP CPU PC status register                                  | 0x0040    | RO       |
| Interrupt configuration registers        |                                                                             |           |          |
| ASSIST_DEBUG_CORE_0_INTR_RAW_REG         | Interrupt status register                                                   | 0x0004    | RO       |
| ASSIST_DEBUG_CORE_0_INTR_ENA_REG         | Interrupt enable register                                                   | 0x0008    | R/W      |

| Name                                            | Description                                             | Address   | Access   |
|-------------------------------------------------|---------------------------------------------------------|-----------|----------|
| ASSIST_DEBUG_CORE_0_INTR_CLR_REG                | Interrupt clear register                                | 0x000C    | R/W      |
| PC logging configuration register               |                                                         |           |          |
| ASSIST_DEBUG_CORE_0_RCD_EN_REG                  | HP CPU PC logging en able register                     | 0x0044    | R/W      |
| PC logging status registers                     |                                                         |           |          |
| ASSIST_DEBUG_CORE_0_RCD_PDEBUGPC_REG            | PC logging register                                     | 0x0048    | RO       |
| ASSIST_DEBUG_CORE_0_RCD_PDEBUGSP_REG            | PC logging register                                     | 0x004C    | RO       |
| CPU status registers                            |                                                         |           |          |
| ASSIST_DEBUG_CORE_0_LASTPC_BEFORE_EXCEPTION_REG | PC of the last command before HP CPU enters ex ception | 0x0070    | RO       |
| ASSIST_DEBUG_CORE_0_DEBUG_MODE_REG              | HP CPU debug mode sta tus register                     | 0x0074    | RO       |
| Clock control register                          |                                                         |           |          |
| ASSIST_DEBUG_CLOCK_GATE_REG                     | Register clock control                                  | 0x0078    | R/W      |
| Version register                                |                                                         |           |          |
| ASSIST_DEBUG_DATE_REG                           | Version control register                                | 0x03FC    | R/W      |

![Image](images/18_Chapter_18_img002_b9b74098.png)

## 18.6 Registers

The addresses of bus logging configuration registers (see 18.6.1) in this section are relative to MEM\_MONITOR base address. The addresses of other registers (see 18.6.2) are relative to the ASSIST\_DEBUG base address. Both base addresses are provided in Table 5.3-2 in Chapter 5 System and Memory .

## 18.6.1 Bus Logging Configuration Registers

## Register 18.1. MEM\_MONITOR\_LOG\_SETTING\_REG (0x0000)

![Image](images/18_Chapter_18_img003_08381481.png)

MEM\_MONITOR\_LOG\_ENA Configures whether to enable CPU or DMA bus access logging.

bit[0]: Configures whether to enable HP CPU bus access logging.

0: Disable

1: Enable

bit[1]: Configures whether to enable LP CPU bus access logging.

0: Disable

1: Enable

bit[2]: Configures whether to enable DMA bus access logging.

0: Disable

1: Enable

(R/W)

## MEM\_MONITOR\_LOG\_MODE Configures monitoring modes.

bit[0]: Configures write monitoring.

0: Disable

1: Enable

bit[1]: Configures word monitoring.

0: Disable

1: Enable

bit[2]: Configures halfword monitoring.

0: Disable

1: Enable

bit[3]: Configures byte monitoring.

0: Disable

1: Enable

(R/W)

MEM\_MONITOR\_LOG\_MEM\_LOOP\_ENABLE Configures the writing mode for recorded data.

1: Loop mode

0: Non-loop mode

(R/W)

Register 18.2. MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG (0x0004)

![Image](images/18_Chapter_18_img004_236597bf.png)

MEM\_MONITOR\_LOG\_CHECK\_DATA Configures the data to be monitored during bus accessing. (R/W)

Register 18.3. MEM\_MONITOR\_LOG\_DATA\_MASK\_REG (0x0008)

![Image](images/18_Chapter_18_img005_a36ec1a9.png)

## MEM\_MONITOR\_LOG\_DATA\_MASK Configures which byte(s) in

MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG to mask.

bit[0]: Configures whether to mask the least significant byte of MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG .

0: Not mask

1: Mask bit[1]: Configures whether to mask the second least significant byte of MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG .

0: Not mask

1: Mask bit[2]: Configures whether to mask the second most significant byte of MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG .

0: Not mask

1: Mask bit[3]: Configures whether to mask the most significant byte of MEM\_MONITOR\_LOG\_CHECK\_DATA\_REG .

0: Not mask

1: Mask

(R/W)

ESP32-C6 TRM (Version 1.1)

Register 18.4. MEM\_MONITOR\_LOG\_MIN\_REG (0x000C)

![Image](images/18_Chapter_18_img006_52bf59f2.png)

MEM\_MONITOR\_LOG\_MIN Configures the lower bound address of the monitored address space. (R/W)

Register 18.5. MEM\_MONITOR\_LOG\_MAX\_REG (0x0010)

MEM\_MONITOR\_LOG\_MAX

![Image](images/18_Chapter_18_img007_ffc61be5.png)

MEM\_MONITOR\_LOG\_MAX Configures the upper bound address of the monitored address space. (R/W)

Register 18.6. MEM\_MONITOR\_LOG\_MEM\_START\_REG (0x0014)

![Image](images/18_Chapter_18_img008_2b91a87e.png)

MEM\_MONITOR\_LOG\_MEM\_START Configures the starting address of the storage space for recorded data. (R/W)

Register 18.7. MEM\_MONITOR\_LOG\_MEM\_END\_REG (0x0018)

![Image](images/18_Chapter_18_img009_65ff7203.png)

MEM\_MONITOR\_LOG\_MEM\_END Configures the ending address of the storage space for recorded data. (R/W)

Register 18.8. MEM\_MONITOR\_LOG\_MEM\_CURRENT\_ADDR\_REG (0x001C)

![Image](images/18_Chapter_18_img010_e01c4237.png)

MEM\_MONITOR\_LOG\_MEM\_CURRENT\_ADDR Represents the address of the next write. (RO)

## Register 18.9. MEM\_MONITOR\_LOG\_MEM\_ADDR\_UPDATE\_REG (0x0020)

![Image](images/18_Chapter_18_img011_b2fc06e6.png)

MEM\_MONITOR\_LOG\_MEM\_ADDR\_UPDATE Configures whether to update the value in MEM\_MONITOR\_LOG\_MEM\_START\_REG to MEM\_MONITOR\_LOG\_MEM\_CURRENT\_ADDR\_REG . 1: Update 0: Not update (default) (R/W)

Register 18.10. MEM\_MONITOR\_LOG\_MEM\_FULL\_FLAG\_REG (0x0024)

![Image](images/18_Chapter_18_img012_1ce72ac9.png)

MEM\_MONITOR\_LOG\_MEM\_FULL\_FLAG Represents whether data overflows the storage space

- 0: Not Overflow
- 1: Overflow

(RO)

MEM\_MONITOR\_CLR\_LOG\_MEM\_FULL\_FLAG Configures whether to clear the MEM\_MONITOR\_LOG\_MEM\_FULL\_FLAG flag bit.

- 0: Not clear
- 1: Clear
- (R/W)

## Register 18.11. MEM\_MONITOR\_CLOCK\_GATE\_REG (0x0028)

MEM\_MONITOR\_DATE Version control register. (R/W)

![Image](images/18_Chapter_18_img013_1b11c786.png)

![Image](images/18_Chapter_18_img014_d3af92f4.png)

## 18.6.2 Other Registers

Register 18.13. ASSIST\_DEBUG\_CORE\_0\_MONTR\_ENA\_REG (0x0000)

![Image](images/18_Chapter_18_img015_ad2df4ab.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_RD\_ENA Configures whether to monitor read opera- tions in region 0 by the Data bus.

- 0: Not monitor
- 1: Monitor

(R/W)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_WR\_ENA Configures whether to monitor write opera- tions in region 0 by the Data bus.

- 0: Not monitor
- 1: Monitor

(R/W)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_RD\_ENA Configures whether to monitor read opera- tions in region 1 by the Data bus.

- 0: Not Monitor
- 1: Monitor

(R/W)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_WR\_ENA Configures whether to monitor write opera- tions in region 1 by the Data bus.

- 0: Not Monitor
- 1: Monitor

(R/W)

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_RD\_ENA Configures whether to monitor read operations in region 0 by the Peripheral bus.

0: Not Monitor

- 1: Monitor

(R/W)

Continued on the next page...

## Register 18.13. ASSIST\_DEBUG\_CORE\_0\_MONTR\_ENA\_REG (0x0000)

## Continued from the previous page...

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_WR\_ENA Configures whether to monitor write operations

in region 0 by the Peripheral bus.

0: Not Monitor

1: Monitor

(R/W)

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_RD\_ENA Configures whether to monitor read operations in region 1 by the Peripheral bus.

0: Not Monitor

1: Monitor

(R/W)

- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_WR\_ENA Configures whether to monitor write operations in region 1 by the Peripheral bus.

0: Not Monitor

1: Monitor

(R/W)

- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MIN\_ENA Configures whether to monitor SP exceeding the lower bound address of SP monitored region.

0: Not Monitor

1: Monitor

(R/W)

- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MAX\_ENA Configures whether to monitor SP exceeding the upper bound address of SP monitored region.

0: Not Monitor

1: Monitor

(R/W)

Register 18.14. ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MIN\_REG (0x0010)

![Image](images/18_Chapter_18_img016_9009fad0.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MIN Configures the lower bound address of Data bus region 0. (R/W)

Register 18.15. ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MAX\_REG (0x0014)

![Image](images/18_Chapter_18_img017_402a53fa.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_MAX Configures the upper bound address of Data bus region 0. (R/W)

## Register 18.16. ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MIN\_REG (0x0018)

![Image](images/18_Chapter_18_img018_e014116d.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MIN Configures the lower bound address of Data bus region 1. (R/W)

## Register 18.17. ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MAX\_REG (0x001C)

ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_MAX Configures the upper bound address of Data bus region 1. (R/W)

![Image](images/18_Chapter_18_img019_9dc178a5.png)

ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_MAX Configures the upper bound address of Peripheral bus region 0. (R/W)

![Image](images/18_Chapter_18_img020_b8213a5b.png)

![Image](images/18_Chapter_18_img021_5da1a28a.png)

![Image](images/18_Chapter_18_img022_12d688f0.png)

Register 18.26. ASSIST\_DEBUG\_CORE\_0\_SP\_PC\_REG (0x0040)

![Image](images/18_Chapter_18_img023_2ef47d54.png)

ASSIST\_DEBUG\_CORE\_0\_SP\_PC Represents the PC value during stack monitoring. (RO)

## Register 18.27. ASSIST\_DEBUG\_CORE\_0\_INTR\_RAW\_REG (0x0004)

![Image](images/18_Chapter_18_img024_45cd7006.png)

- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_RD\_RAW The raw interrupt status of read operations in region 0 by Data bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_WR\_RAW The raw interrupt status of write operations in region 0 by Data bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_RD\_RAW The raw interrupt status of read operations in region 1 by Data bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_WR\_RAW The raw interrupt status of write operations in region 1 by Data bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_RD\_RAW The raw interrupt status of read operations in region 0 by Peripheral bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_WR\_RAW The raw interrupt status of write operations in region 0 by Peripheral bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_RD\_RAW The raw interrupt status of read operations in region 1 by Peripheral bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_WR\_RAW The raw interrupt status of write operations in region 1 by Peripheral bus. (RO)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MIN\_RAW The raw interrupt status of SP exceeding the lower bound address of SP monitored region. (RO)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MAX\_RAW The raw interrupt status of SP exceeding the upper bound address of SP monitored region. (RO)

## Register 18.28. ASSIST\_DEBUG\_CORE\_0\_INTR\_ENA\_REG (0x0008)

![Image](images/18_Chapter_18_img025_3fd7a5ed.png)

- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_RD\_INTR\_ENA Write 1 to enable the interrupt for read operations in region 0 by Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_WR\_INTR\_ENA Write 1 to enable the interrupt for write operations in region 0 by Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_RD\_INTR\_ENA Write 1 to enable the interrupt for read operations in region 1 by Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_WR\_INTR\_ENA Write 1 to enable the interrupt for write operations in region 1 by Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_RD\_INTR\_ENA Write 1 to enable the interrupt for read operations in region 0 by Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_WR\_INTR\_ENA Write 1 to enable the interrupt for write operations in region 0 by Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_RD\_INTR\_ENA Write 1 to enable the interrupt for read operations in region 1 by Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_WR\_INTR\_ENA Write 1 to enable the interrupt for write operations in region 1 by Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MIN\_INTR\_ENA Write 1 to enable the interrupt for SP exceeding the lower bound address of SP monitored region. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MAX\_INTR\_ENA Write 1 to enable the interrupt for SP exceeding the upper bound address of SP monitored region. (R/W)

![Image](images/18_Chapter_18_img026_f15635d2.png)

## Register 18.29. ASSIST\_DEBUG\_CORE\_0\_INTR\_CLR\_REG (0x000C)

![Image](images/18_Chapter_18_img027_aae19257.png)

- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_RD\_CLR Write 1 to clear the interrupt for read operations in region 0 by Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_0\_WR\_CLR Write 1 to clear the interrupt for write operations in region 0 by Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_RD\_CLR Write 1 to clear the interrupt for read operations in region 1 by Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_DRAM0\_1\_WR\_CLR Write 1 to clear the interrupt for write operations in region 1 by Data bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_RD\_CLR Write 1 to clear the interrupt for read operations in region 0 by Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_0\_WR\_CLR Write 1 to clear the interrupt for write operations in region 0 by Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_RD\_CLR Write 1 to clear the interrupt for read operations in region 1 by Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_AREA\_PIF\_1\_WR\_CLR Write 1 to clear the interrupt for write operations in region 1 by Peripheral bus. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MIN\_CLR Write 1 to clear the interrupt for SP exceeding the lower bound address of SP monitored region. (R/W)
- ASSIST\_DEBUG\_CORE\_0\_SP\_SPILL\_MAX\_CLR Write 1 to clear the interrupt for SP exceeding the upper bound address of SP monitored region. (R/W)

## Register 18.30. ASSIST\_DEBUG\_CORE\_0\_RCD\_EN\_REG (0x0044)

![Image](images/18_Chapter_18_img028_a54f3bb6.png)

ASSIST\_DEBUG\_CORE\_0\_RCD\_RECORDEN Configures whether to enable PC logging.

- 0: Disable
- 1: ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC\_REG starts to record PC in real time (R/W)

ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGEN Configures whether to enable HP CPU debugging.

- 0: Disable
- 1: HP CPU outputs PC

(R/W)

Register 18.31. ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC\_REG (0x0048)

![Image](images/18_Chapter_18_img029_0124d542.png)

ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGPC Represents the PC value at HP CPU reset. (RO)

Register 18.32. ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGSP\_REG (0x004C)

![Image](images/18_Chapter_18_img030_8cb705c1.png)

ASSIST\_DEBUG\_CORE\_0\_RCD\_PDEBUGSP Represents SP. (RO)

Register 18.33. ASSIST\_DEBUG\_CORE\_0\_LASTPC\_BEFORE\_EXCEPTION\_REG (0x0070)

![Image](images/18_Chapter_18_img031_67aa0c2f.png)

ASSIST\_DEBUG\_CORE\_0\_LASTPC\_BEFORE\_EXC Represents the PC of the last command before the HP CPU enters exception. (RO)

## Register 18.34. ASSIST\_DEBUG\_CORE\_0\_DEBUG\_MODE\_REG (0x0074)

![Image](images/18_Chapter_18_img032_2593eda9.png)

Register 18.36. ASSIST\_DEBUG\_DATE\_REG (0x03FC)

![Image](images/18_Chapter_18_img033_a3cb682b.png)

ASSIST\_DEBUG\_DATE Version control register. (R/W)

## Part IV

## Cryptography/Security Component

Dedicated to security features, this part explores cryptographic accelerators like SHA and ECC. It also covers digital signatures, random number generation, and encryption/decryption algorithms, showcasing the SoC's capabilities in cryptography and secure data processing.
