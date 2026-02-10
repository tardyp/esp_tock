---
chapter: 25
title: "Chapter 25"
document: "ESP32-C3 Technical Reference Manual"
version: "v1.3"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C3"
manufacturer: "Espressif"
---
## Chapter 25

## Clock Glitch Detection

## 25.1 
时钟毛 Overview
刺检测 25.1 Over
时钟毛刺检测

The Clock Glitch Detection module on ESP32-C3 detects glitches in external crystal XTAL\_CLK signals, and
1概述 generates a system reset signal when detecting glitches to reset the whole digital circuit including RTC. By
1. 概述 doing so, it prevents attackers from injecting glitches on external crystal XTAL\_CLK clock to compromise
为提升 ESP32-S2 的安全性能，防止攻击者通过给外部晶振 XTAL 附加毛刺，使芯片进入异常 ESP32-C3 and thus strengthens chip security.
从而实施对芯片的攻击，ESP32-S2 搭载了毛 generates 
1. 概述 g so, it prevents attackers from injecting glitches on external crystal XTAL\_CLK clock to compromise
为提升 ESP32-S2 的安全性能，防止攻击者通过给外部晶振 XTAL 附加毛刺，使芯片进入异常状态， ESP32-C3 and thus strengthens chip security.
从而实施对芯片的攻击，ESP32-S2 搭载了毛刺检测模块,Glitch\_Detect)，用于检测从外部晶振输入的

XTAL\_CLK 是否携带毛刺，并在检测到毛刺后，发送中断或者产生系统复位信号。

## 25.2 Functional Description
描述

2. 功能描述

## 25.2.1 Clock Glitch Detection

2.1 毛刺检测

The Clock Glitch Detection module on ESP32-C3 monitors input clock signals from XTAL\_CLK. If it detects a glitch, namely a clock pulse (a or b in the figure below) with a width shorter than 3 ns, input clock signals from
ESP32-S2 的毛刺检测模块将对输入芯片的 XTAL\_CLK 时钟信号进行检测，当时钟的脉宽,a 或 :) XTAL\_CLK are blocked.
于 3ns 时，将认为检测 hnamely a clock pulse (a or b in the figure below) with a width shorter than 3 nsinput clock signals from
ESP32-S2 的毛刺检测模块将对输入芯片的 XTAL\_CLK 时钟信号进行检测，当时钟的脉宽,a 或 :)小 XTALCLK are blocked
于 3ns 时，将认为检测到毛刺，触发毛刺检测信号 , 屏蔽输入的 XTAL\_CLK 时钟信号。

Figure 25.2-1. XTAL\_CLK Pulse Width

![Image](images/25_Chapter_25_img001_d3c9dce6.png)

2.2 中断及复位

## 当毛刺
25.2.2 检测信号
Reset

当毛刺检测信号触发后，毛刺检测模块将向系统发送中断,GLITCH\_DET\_INT)，如果
2.2 Reset

RTC\_CNTL\_GLITCH\_RST\_EN 使能，将触发系统级复位。
Once detecting a glitch on XTAL\_CLK that affects the circuit's no RTCCNTLGLITCHRSTEN 使能，将触发系统级复位。
Once detecting a glitch on XTAL\_CLK that affects the circuit's normal operation, the Clock Glitch Detection module triggers a system reset if RTC\_CNTL\_GLITCH\_RST\_EN bit is enabled. By default, this bit is set to enable a reset.

## Part V

## Connectivity Interface

This part addresses the connectivity aspects of the system, describing components related to various communication interfaces like I2C, I2S, SPI, UART, USB, and more. The part also covers interfaces to generate signals used in remote control, motor control, LED control, etc.
