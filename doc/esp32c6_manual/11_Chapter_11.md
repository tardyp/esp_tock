---
chapter: 11
title: "Chapter 11"
document: "ESP32-C6 Technical Reference Manual"
version: "v1.1"
type: "reference"
source: "docling-pdf-to-markdown"
device: "ESP32-C6"
manufacturer: "Espressif"
---
## Chapter 11

## Event Task Matrix (SOC\_ETM)

## 11.1 Overview

The Event Task Matrix (ETM) peripheral contains 50 configurable channels. Each channel can map an event of any specified peripheral to a task of any specified peripheral. In this way, peripherals can be triggered to execute specified tasks without CPU intervention.

## 11.2 Features

The Event Task Matrix has the following features:

- Receive various events from multiple peripherals
- Generate various tasks for multiple peripherals
- 50 independently configurable ETM channels
- An ETM channel can be set up to receive any event, and map it to any task
- Each ETM channel can be enabled independently. If not enabled, the channel will not respond to the configured event and generate the task mapped to that event
- Peripherals supporting ETM include GPIO, LED PWM, general-purpose timers, RTC Timer, system timer, MCPWM, temperature sensor, ADC, I2S, LP CPU, GDMA, and PMU

Note that the 50 ETM channels are identical regarding their features and operations. Thus, in the following sections ETM channels are collectively referred to as channeln (where n ranges from 0 to 49).

## 11.3 Functional Description

## 11.3.1 Architecture

Figure 11.3-1. Event Task Matrix Architecture

![Image](images/11_Chapter_11_img001_10920806.png)

Figure 11.3-1 shows the architecture of the Event Task Matrix.

The Event Task Matrix has 50 independent channels. A channel can choose any event as input, and map the event to any task as output (For configuration procedures, refer to Section 11.3.2 and Section 11.3.3 respectively). Each channel has an individual enable bit (For configuration procedures, refer to Section 11.3.5).

Figure 11.3-2. ETM Channeln Architecture

![Image](images/11_Chapter_11_img002_a1ecde1d.png)

Figure 11.3-2 illustrates the structure of an ETM channel. The SOC\_ETM\_CHn\_EVT\_ID field configures the MUX (multiplexer) to select one of the events as the input of channeln. The SOC\_ETM\_CHn\_TASK\_ID field configures the DEMUX (demultiplexer) to map the event selected by channeln to one of the tasks.

SOC\_ETM\_CH\_ENABLEn and SOC\_ETM\_CH\_DISABLEn are used to enable or disable channeln . SOC\_ETM\_CH\_ENABLEDn is used to indicate the status of the channeln .

## 11.3.2 Events

An ETM channel can be set up to choose which event to receive by configuring the SOC\_ETM\_CHn\_EVT\_ID field. Table 11.3-1 shows the configuration values of SOC\_ETM\_CHn\_EVT\_ID and their corresponding events.

Table 11.3-1. Selectable Events for ETM Channeln

| SOC_ETM_CHn_EVT_ID   | Selected Event             | Peripheral Generating This Event   |
|----------------------|----------------------------|------------------------------------|
| 1                    | GPIO_EVT_CH0_RISE_EDGE     | GPIO                               |
| 2                    | GPIO_EVT_CH1_RISE_EDGE     |                                    |
| 3                    | GPIO_EVT_CH2_RISE_EDGE     |                                    |
| 4                    | GPIO_EVT_CH3_RISE_EDGE     |                                    |
| 5                    | GPIO_EVT_CH4_RISE_EDGE     |                                    |
| 6                    | GPIO_EVT_CH5_RISE_EDGE     |                                    |
| 7                    | GPIO_EVT_CH6_RISE_EDGE     |                                    |
| 8                    | GPIO_EVT_CH7_RISE_EDGE     |                                    |
| 9                    | GPIO_EVT_CH0_FALL_EDGE     |                                    |
| 10                   | GPIO_EVT_CH1_FALL_EDGE     |                                    |
| 11                   | GPIO_EVT_CH2_FALL_EDGE     |                                    |
| 12                   | GPIO_EVT_CH3_FALL_EDGE     |                                    |
| 13                   | GPIO_EVT_CH4_FALL_EDGE     |                                    |
| 14                   | GPIO_EVT_CH5_FALL_EDGE     |                                    |
| 15                   | GPIO_EVT_CH6_FALL_EDGE     |                                    |
| 16                   | GPIO_EVT_CH7_FALL_EDGE     |                                    |
| 17                   | GPIO_EVT_CH0_ANY_EDGE      |                                    |
| 18                   | GPIO_EVT_CH1_ANY_EDGE      |                                    |
| 19                   | GPIO_EVT_CH2_ANY_EDGE      |                                    |
| 20                   | GPIO_EVT_CH3_ANY_EDGE      |                                    |
| 21                   | GPIO_EVT_CH4_ANY_EDGE      |                                    |
| 22                   | GPIO_EVT_CH5_ANY_EDGE      |                                    |
| 23                   | GPIO_EVT_CH6_ANY_EDGE      |                                    |
| 24                   | GPIO_EVT_CH7_ANY_EDGE      |                                    |
| 25                   | LEDC_EVT_DUTY_CHNG_END_CH0 | LED PWM Controller (LEDC)          |
| 26                   | LEDC_EVT_DUTY_CHNG_END_CH1 | LED PWM Controller (LEDC)          |
| 27                   | LEDC_EVT_DUTY_CHNG_END_CH2 | LED PWM Controller (LEDC)          |
| 29                   | LEDC_EVT_DUTY_CHNG_END_CH4 | LED PWM Controller (LEDC)          |
|                      | LEDC_EVT_DUTY_CHNG_END_CH5 | LED PWM Controller (LEDC)          |
| 30  31               | LEDC_EVT_OVF_CNT_PLS_CH0   | LED PWM Controller (LEDC)          |
| 32                   | LEDC_EVT_OVF_CNT_PLS_CH1   | LED PWM Controller (LEDC)          |
| 33                   | LEDC_EVT_OVF_CNT_PLS_CH2   | LED PWM Controller (LEDC)          |
| 34                   | LEDC_EVT_OVF_CNT_PLS_CH3   | LED PWM Controller (LEDC)          |
| 35                   | LEDC_EVT_OVF_CNT_PLS_CH4   | LED PWM Controller (LEDC)          |
|                      |                            | LED PWM Controller (LEDC)          |

|   SOC_ETM_CHn_EVT_ID | Selected Event            | Peripheral Generating This Event   |
|----------------------|---------------------------|------------------------------------|
|                   36 | LEDC_EVT_OVF_CNT_PLS_CH5  |                                    |
|                   37 | LEDC_EVT_TIME_OVF_TIMER0  |                                    |
|                   38 | LEDC_EVT_TIME_OVF_TIMER1  |                                    |
|                   39 | LEDC_EVT_TIME_OVF_TIMER2  |                                    |
|                   40 | LEDC_EVT_TIME_OVF_TIMER3  |                                    |
|                   41 | LEDC_EVT_TIMER0_CMP       |                                    |
|                   42 | LEDC_EVT_TIMER1_CMP       |                                    |
|                   43 | LEDC_EVT_TIMER2_CMP       |                                    |
|                   44 | LEDC_EVT_TIMER3_CMP       |                                    |
|                   48 | TIMER0_EVT_CNT_CMP_TIMER0 | General-purpose timer 0            |
|                   49 | TIMER1_EVT_CNT_CMP_TIMER0 | General-purpose timer 1            |
|                   50 | SYSTIMER_EVT_CNT_CMP0     | System Timer (SYSTIMER)            |
|                   51 | SYSTIMER_EVT_CNT_CMP1     |                                    |
|                   52 | SYSTIMER_EVT_CNT_CMP2     |                                    |
|                   58 | MCPWM_EVT_TIMER0_STOP     | Motor Control PWM (MCPWM)          |
|                   59 | MCPWM_EVT_TIMER1_STOP     |                                    |
|                   60 | MCPWM_EVT_TIMER2_STOP     |                                    |
|                   61 | MCPWM_EVT_TIMER0_TEZ      |                                    |
|                   62 | MCPWM_EVT_TIMER1_TEZ      |                                    |
|                   63 | MCPWM_EVT_TIMER2_TEZ      |                                    |
|                   64 | MCPWM_EVT_TIMER0_TEP      |                                    |
|                   65 | MCPWM_EVT_TIMER1_TEP      |                                    |
|                   66 | MCPWM_EVT_TIMER2_TEP      |                                    |
|                   67 | MCPWM_EVT_OP0_TEA         |                                    |
|                   68 | MCPWM_EVT_OP1_TEA         |                                    |
|                   69 | MCPWM_EVT_OP2_TEA         |                                    |
|                   70 | MCPWM_EVT_OP0_TEB         |                                    |
|                   71 | MCPWM_EVT_OP1_TEB         |                                    |
|                   72 | MCPWM_EVT_OP2_TEB         |                                    |
|                   73 | MCPWM_EVT_F0              |                                    |
|                   74 | MCPWM_EVT_F1              |                                    |
|                   75 | MCPWM_EVT_F2              |                                    |
|                   76 | MCPWM_EVT_F0_CLR          |                                    |
|                   77 | MCPWM_EVT_F1_CLR          |                                    |
|                   78 | MCPWM_EVT_F2_CLR          |                                    |
|                   79 | MCPWM_EVT_TZ0_CBC         |                                    |
|                   80 | MCPWM_EVT_TZ1_CBC         |                                    |
|                   81 | MCPWM_EVT_TZ2_CBC         |                                    |
|                   82 | MCPWM_EVT_TZ0_OST         |                                    |
|                   83 | MCPWM_EVT_TZ1_OST         |                                    |
|                   84 | MCPWM_EVT_TZ2_OST         |                                    |
|                   85 | MCPWM_EVT_CAP0            |                                    |
|                   86 | MCPWM_EVT_CAP1            |                                    |
|                   87 | MCPWM_EVT_CAP2            |                                    |
|                   88 | ADC_EVT_CONV_CMPLT0       | ADC                                |

| SOC_ETM_CHn_EVT_ID   | Selected Event                                  | Peripheral Generating This Event   |
|----------------------|-------------------------------------------------|------------------------------------|
| 89                   | ADC_EVT_EQ_ABOVE_THRESH0                        |                                    |
| 90                   | ADC_EVT_EQ_ABOVE_THRESH1                        |                                    |
| 91                   | ADC_EVT_EQ_BELOW_THRESH0                        |                                    |
| 92                   | ADC_EVT_EQ_BELOW_THRESH1                        |                                    |
| 94                   | ADC_EVT_STOPPED0                                |                                    |
| 95                   | ADC_EVT_STARTED0                                |                                    |
| 110                  | TMPSNSR_EVT_OVER_LIMIT                          | Temperature Sensor                 |
| 126                  | I2S_EVT_RX_DONE                                 | I2S Controller (I2S)               |
| 127                  | I2S_EVT_TX_DONE                                 | I2S Controller (I2S)               |
| 128                  | I2S_EVT_X_WORDS_RECEIVED                        | I2S Controller (I2S)               |
| 129                  | I2S_EVT_X_WORDS_SENT                            | I2S Controller (I2S)               |
| 133                  | ULP_EVT_ERR_INTR                                | Low-Power CPU                      |
| 134                  | ULP_EVT_START_INTR                              | Low-Power CPU                      |
| 135                  | RTC_EVT_TICK                                    | RTC Timer                          |
| 136                  | RTC_EVT_OVF                                     | RTC Timer                          |
| 137                  | RTC_EVT_CMP                                     | RTC Timer                          |
| 138                  | GDMA_EVT_IN_DONE_CH0                            | GDMA Controller (GDMA)             |
| 139                  | GDMA_EVT_IN_DONE_CH1                            |                                    |
| 140                  | GDMA_EVT_IN_DONE_CH2                            |                                    |
| 141                  | GDMA_EVT_IN_SUC_EOF_CH0                         |                                    |
| 142                  | GDMA_EVT_IN_SUC_EOF_CH1                         |                                    |
| 143                  | GDMA_EVT_IN_SUC_EOF_CH2                         |                                    |
| 144                  | GDMA_EVT_IN_FIFO_EMPTY_CH0                      |                                    |
| 145                  | GDMA_EVT_IN_FIFO_EMPTY_CH1                      |                                    |
| 146                  | GDMA_EVT_IN_FIFO_EMPTY_CH2                      |                                    |
| 147                  | GDMA_EVT_IN_FIFO_FULL_CH0                       |                                    |
| 148                  | GDMA_EVT_IN_FIFO_FULL_CH1                       |                                    |
| 149                  | GDMA_EVT_IN_FIFO_FULL_CH2                       |                                    |
| 150                  | GDMA_EVT_OUT_DONE_CH0                           |                                    |
| 151                  | GDMA_EVT_OUT_DONE_CH1                           |                                    |
| 152                  | GDMA_EVT_OUT_DONE_CH2                           |                                    |
| 153                  | GDMA_EVT_OUT_EOF_CH0                            |                                    |
| 154                  | GDMA_EVT_OUT_EOF_CH1                            |                                    |
| 155                  | GDMA_EVT_OUT_EOF_CH2                            |                                    |
| 156                  | GDMA_EVT_OUT_TOTAL_EOF_CH0                      |                                    |
| 157                  | GDMA_EVT_OUT_TOTAL_EOF_CH1                      |                                    |
| 158                  | GDMA_EVT_OUT_TOTAL_EOF_CH2                      |                                    |
| 159                  | GDMA_EVT_OUT_FIFO_EMPTY_CH0                     |                                    |
| 160                  | GDMA_EVT_OUT_FIFO_EMPTY_CH1                     |                                    |
| 161                  | GDMA_EVT_OUT_FIFO_EMPTY_CH2                     |                                    |
| 162                  | GDMA_EVT_OUT_FIFO_FULL_CH0                      |                                    |
| 163                  | GDMA_EVT_OUT_FIFO_FULL_CH1                      |                                    |
| 164  165             | GDMA_EVT_OUT_FIFO_FULL_CH2 PMU_EVT_SLEEP_WEEKUP | PMU                                |

Each event corresponds to a pulse signal generated by the corresponding peripheral. When the pulse signal is valid, the corresponding event is considered as received.

For more detailed descriptions of an event, please refer to the chapter for the peripheral generating this event.

## 11.3.3 Tasks

An ETM channel can be set up to map its event to one of the tasks by configuring the SOC\_ETM\_CHn\_TASK\_ID field. Table11.3-2 shows the configuration values of SOC\_ETM\_CHn\_TASK\_ID and their corresponding tasks.

Table 11.3-2. Mappable Tasks for ETM Channeln

|   SOC_ETM_CHn_TASK_ID | Mapped Task                     | Peripheral Receiving This Task   |
|-----------------------|---------------------------------|----------------------------------|
|                     1 | GPIO_TASK_CH0_SET               | GPIO                             |
|                     2 | GPIO_TASK_CH1_SET               |                                  |
|                     3 | GPIO_TASK_CH2_SET               |                                  |
|                     4 | GPIO_TASK_CH3_SET               |                                  |
|                     5 | GPIO_TASK_CH4_SET               |                                  |
|                     6 | GPIO_TASK_CH5_SET               |                                  |
|                     7 | GPIO_TASK_CH6_SET               |                                  |
|                     8 | GPIO_TASK_CH7_SET               |                                  |
|                     9 | GPIO_TASK_CH0_CLEAR             |                                  |
|                    10 | GPIO_TASK_CH1_CLEAR             |                                  |
|                    11 | GPIO_TASK_CH2_CLEAR             |                                  |
|                    12 | GPIO_TASK_CH3_CLEAR             |                                  |
|                    13 | GPIO_TASK_CH4_CLEAR             |                                  |
|                    14 | GPIO_TASK_CH5_CLEAR             |                                  |
|                    15 | GPIO_TASK_CH6_CLEAR             |                                  |
|                    16 | GPIO_TASK_CH7_CLEAR             |                                  |
|                    17 | GPIO_TASK_CH0_TOGGLE            |                                  |
|                    18 | GPIO_TASK_CH1_TOGGLE            |                                  |
|                    19 | GPIO_TASK_CH2_TOGGLE            |                                  |
|                    20 | GPIO_TASK_CH3_TOGGLE            |                                  |
|                    21 | GPIO_TASK_CH4_TOGGLE            |                                  |
|                    22 | GPIO_TASK_CH5_TOGGLE            |                                  |
|                    23 | GPIO_TASK_CH6_TOGGLE            |                                  |
|                    24 | GPIO_TASK_CH7_TOGGLE            |                                  |
|                    25 | LEDC_TASK_TIMER0_RES_UPDATE     | LED PWM Controller (LEDC)        |
|                    26 | LEDC_TASK_TIMER1_RES_UPDATE     | LED PWM Controller (LEDC)        |
|                    27 | LEDC_TASK_TIMER2_RES_UPDATE     | LED PWM Controller (LEDC)        |
|                    28 | LEDC_TASK_TIMER3_RES_UPDATE     | LED PWM Controller (LEDC)        |
|                    31 | LEDC_TASK_DUTY_SCALE_UPDATE_CH0 | LED PWM Controller (LEDC)        |
|                    32 | LEDC_TASK_DUTY_SCALE_UPDATE_CH1 | LED PWM Controller (LEDC)        |
|                    33 | LEDC_TASK_DUTY_SCALE_UPDATE_CH2 | LED PWM Controller (LEDC)        |
|                    34 | LEDC_TASK_DUTY_SCALE_UPDATE_CH3 | LED PWM Controller (LEDC)        |

|   SOC_ETM_CHn_TASK_ID | Mapped Task                     | Peripheral Receiving This Task   |
|-----------------------|---------------------------------|----------------------------------|
|                    35 | LEDC_TASK_DUTY_SCALE_UPDATE_CH4 |                                  |
|                    36 | LEDC_TASK_DUTY_SCALE_UPDATE_CH5 |                                  |
|                    37 | LEDC_TASK_TIMER0_CAP            |                                  |
|                    38 | LEDC_TASK_TIMER1_CAP            |                                  |
|                    39 | LEDC_TASK_TIMER2_CAP            |                                  |
|                    40 | LEDC_TASK_TIMER3_CAP            |                                  |
|                    41 | LEDC_TASK_SIG_OUT_DIS_CH0       |                                  |
|                    42 | LEDC_TASK_SIG_OUT_DIS_CH1       |                                  |
|                    43 | LEDC_TASK_SIG_OUT_DIS_CH2       |                                  |
|                    44 | LEDC_TASK_SIG_OUT_DIS_CH3       |                                  |
|                    45 | LEDC_TASK_SIG_OUT_DIS_CH4       |                                  |
|                    46 | LEDC_TASK_SIG_OUT_DIS_CH5       |                                  |
|                    47 | LEDC_TASK_OVF_CNT_RST_CH0       |                                  |
|                    48 | LEDC_TASK_OVF_CNT_RST_CH1       |                                  |
|                    49 | LEDC_TASK_OVF_CNT_RST_CH2       |                                  |
|                    50 | LEDC_TASK_OVF_CNT_RST_CH3       |                                  |
|                    51 | LEDC_TASK_OVF_CNT_RST_CH4       |                                  |
|                    52 | LEDC_TASK_OVF_CNT_RST_CH5       |                                  |
|                    53 | LEDC_TASK_TIMER0_RST            |                                  |
|                    54 | LEDC_TASK_TIMER1_RST            |                                  |
|                    55 | LEDC_TASK_TIMER2_RST            |                                  |
|                    56 | LEDC_TASK_TIMER3_RST            |                                  |
|                    57 | LEDC_TASK_TIMER0_RESUME         |                                  |
|                    58 | LEDC_TASK_TIMER1_RESUME         |                                  |
|                    59 | LEDC_TASK_TIMER2_RESUME         |                                  |
|                    60 | LEDC_TASK_TIMER3_RESUME         |                                  |
|                    61 | LEDC_TASK_TIMER0_PAUSE          |                                  |
|                    62 | LEDC_TASK_TIMER1_PAUSE          |                                  |
|                    63 | LEDC_TASK_TIMER2_PAUSE          |                                  |
|                    64 | LEDC_TASK_TIMER3_PAUSE          |                                  |
|                    65 | LEDC_TASK_GAMMA_RESTART_CH0     |                                  |
|                    66 | LEDC_TASK_GAMMA_RESTART_CH1     |                                  |
|                    67 | LEDC_TASK_GAMMA_RESTART_CH2     |                                  |
|                    68 | LEDC_TASK_GAMMA_RESTART_CH3     |                                  |
|                    69 | LEDC_TASK_GAMMA_RESTART_CH4     |                                  |
|                    70 | LEDC_TASK_GAMMA_RESTART_CH5     |                                  |
|                    71 | LEDC_TASK_GAMMA_PAUSE_CH0       |                                  |
|                    72 | LEDC_TASK_GAMMA_PAUSE_CH1       |                                  |
|                    73 | LEDC_TASK_GAMMA_PAUSE_CH2       |                                  |
|                    74 | LEDC_TASK_GAMMA_PAUSE_CH3       |                                  |
|                    75 | LEDC_TASK_GAMMA_PAUSE_CH4       |                                  |
|                    76 | LEDC_TASK_GAMMA_PAUSE_CH5       |                                  |
|                    77 | LEDC_TASK_GAMMA_RESUME_CH0      |                                  |
|                    78 | LEDC_TASK_GAMMA_RESUME_CH1      |                                  |
|                    79 | LEDC_TASK_GAMMA_RESUME_CH2      |                                  |

|   SOC_ETM_CHn_TASK_ID | Mapped Task                    | Peripheral Receiving This Task   |
|-----------------------|--------------------------------|----------------------------------|
|                    80 | LEDC_TASK_GAMMA_RESUME_CH3     |                                  |
|                    81 | LEDC_TASK_GAMMA_RESUME_CH4     |                                  |
|                    82 | LEDC_TASK_GAMMA_RESUME_CH5     |                                  |
|                    88 | TIMER0_TASK_CNT_START_TIMER0   | General-purpose timer 0          |
|                    90 | TIMER0_TASK_ALARM_START_TIMER0 |                                  |
|                    92 | TIMER0_TASK_CNT_STOP_TIMER0    |                                  |
|                    94 | TIMER0_TASK_CNT_RELOAD_TIMER0  |                                  |
|                    96 | TIMER0_TASK_CNT_CAP_TIMER0     |                                  |
|                    89 | TIMER1_TASK_CNT_START_TIMER0   | General-purpose timer 1          |
|                    91 | TIMER1_TASK_ALARM_START_TIMER0 |                                  |
|                    93 | TIMER1_TASK_CNT_STOP_TIMER0    |                                  |
|                    95 | TIMER1_TASK_CNT_RELOAD_TIMER0  |                                  |
|                    97 | TIMER1_TASK_CNT_CAP_TIMER0     |                                  |
|                   102 | MCPWM_TASK_CMPR0_A_UP          | Motor Control PWM (MCPWM)        |
|                   103 | MCPWM_TASK_CMPR1_A_UP          |                                  |
|                   104 | MCPWM_TASK_CMPR2_A_UP          |                                  |
|                   105 | MCPWM_TASK_CMPR0_B_UP          |                                  |
|                   106 | MCPWM_TASK_CMPR1_B_UP          |                                  |
|                   107 | MCPWM_TASK_CMPR2_B_UP          |                                  |
|                   108 | MCPWM_TASK_GEN_STOP            |                                  |
|                   109 | MCPWM_TASK_TIMER0_SYN          |                                  |
|                   110 | MCPWM_TASK_TIMER1_SYN          |                                  |
|                   111 | MCPWM_TASK_TIMER2_SYN          |                                  |
|                   112 | MCPWM_TASK_TIMER0_PERIOD_UP    |                                  |
|                   113 | MCPWM_TASK_TIMER1_PERIOD_UP    |                                  |
|                   114 | MCPWM_TASK_TIMER2_PERIOD_UP    |                                  |
|                   115 | MCPWM_TASK_TZ0_OST             |                                  |
|                   116 | MCPWM_TASK_TZ1_OST             |                                  |
|                   117 | MCPWM_TASK_TZ2_OST             |                                  |
|                   118 | MCPWM_TASK_CLR0_OST            |                                  |
|                   119 | MCPWM_TASK_CLR1_OST            |                                  |
|                   120 | MCPWM_TASK_CLR2_OST            |                                  |
|                   121 | MCPWM_TASK_CAP0                |                                  |
|                   122 | MCPWM_TASK_CAP1                |                                  |
|                   123 | MCPWM_TASK_CAP2                |                                  |
|                   124 | ADC_TASK_SAMPLE0               | ADC                              |
|                   126 | ADC_TASK_START0                |                                  |
|                   127 | ADC_TASK_STOP0                 |                                  |
|                   135 | TMPSNSR_TASK_START_SAMPLE      | Temperature Sensor               |
|                   136 | TMPSNSR_TASK_STOP_SAMPLE       |                                  |
|                   148 | I2S_TASK_START_RX              | I2S Controller (I2S)             |
|                   149 | I2S_TASK_START_TX              |                                  |
|                   150 | I2S_TASK_STOP_RX               |                                  |
|                   151 | I2S_TASK_STOP_TX               |                                  |

|   SOC_ETM_CHn_TASK_ID | Mapped Task             | Peripheral Receiving This Task   |
|-----------------------|-------------------------|----------------------------------|
|                   154 | ULP_TASK_WEAKUP_CPU     | Low-Power CPU                    |
|                   159 | GDMA_TASK_IN_START_CH0  | GDMA Controller (GDMA)           |
|                   160 | GDMA_TASK_IN_START_CH1  | GDMA Controller (GDMA)           |
|                   161 | GDMA_TASK_IN_START_CH2  | GDMA Controller (GDMA)           |
|                   162 | GDMA_TASK_OUT_START_CH0 | GDMA Controller (GDMA)           |
|                   163 | GDMA_TASK_OUT_START_CH1 | GDMA Controller (GDMA)           |
|                   164 | GDMA_TASK_OUT_START_CH2 | GDMA Controller (GDMA)           |
|                   165 | PMU_TASK_SLEEP_REQ      | PMU                              |

When a channel receives a valid event pulse signal, it generates the mapped task pulse signal.

For more detailed descriptions of a task, please refer to the chapter for the peripheral receiving this task.

Events from different channels can be optionally mapped to the same task (For example, field SOC\_ETM\_CHn\_TASK\_ID of multiple channels can be configured with the same value, and field SOC\_ETM\_CHn\_EVT\_ID can be configured with the same or different values). In this case, when the event received by any of the channels is valid, the task is generated. If events received by multiple channels are valid at the same time, the task will be generated only once.

## 11.3.4 Timing Considerations

Figure 11.3-3 shows the structure of clocks that drive received events, sent tasks, and ETM channels.

Figure 11.3-3. Event Task Matrix Clock Architecture

![Image](images/11_Chapter_11_img003_31139a77.png)

\_

ETM is running at the AHB\_CLK domain (see Chapter 8 Reset and Clock). Each event corresponds to a pulse signal generated by the corresponding peripheral in its clock domain, while each task is mapped by the ETM to a pulse signal under its corresponding peripheral clock domain. The peripherals generating events, the Event Task Matrix, and peripherals receiving tasks are not necessarily running off the same clock and as such need to be synchronized. Therefore, there must be a minimum interval between two consecutive events to avoid event loss: to make sure the Event Task Matrix receives every event successfully, for peripherals generating event pulses, the interval between two consecutive pulses must be greater than one ETM clock cycle, namely ceil( peripheral \_ clock \_ f requency ETM clock f requency ) in the unit of peripheral clock cycles.

\_

For example, assuming that event 1 generated by peripheral A is in the 80 MHz clock domain (PLL\_F80M\_CLK), and the ETM runs in the 40 MHz clock domain (AHB\_CLK). To receive each event 1 successfully, the interval between two consecutive event 1 must be greater than two peripheral A clock cycles (i.e. one ETM clock cycle).

Likewise, to make sure the Event Task Matrix maps the received event (i.e. event synchronized to the ETM's clock domain) successfully to a task, the interval between two consecutive event pulses in the ETM clock domain must be greater than one peripheral clock cycle, namely ceil( ETM \_ clock \_ f requency peripheral \_ clock \_ f requency ) in the unit of ETM clock cycles.

For example, assuming that task 1 received by peripheral B is in the 20 MHz clock domain (RC\_FAST\_CLK), and the ETM runs in the 40 MHz clock domain (AHB\_CLK). To map each received event successfully to task 1, the interval between two consecutive events must be greater than two ETM clock cycles (i.e. one peripheral B clock cycle).

As a result, to map two consecutive events generated by peripheral A to peripheral B, the interval between these two events must be ceil( peripheral \_ A \_ clock \_ f requency ETM \_ clock \_ f requency ) ∗ ceil( ETM \_ clock \_ f requency peripheral \_ B \_ clock \_ f requency ) in the unit of peripheral A clock cycles.

For example, assuming that event 1 generated by peripheral A is in the 80 MHz clock domain (PLL\_F80M\_CLK), task 1 received by peripheral B is in the 20 MHz clock domain (RC\_FAST\_CLK), and the ETM runs in the 40 MHz clock domain (AHB\_CLK). To successfully map each event 1 (generated by peripheral A) to task 1 (received by peripheral B), the interval between two consecutive event 1 must be greater than 2 ∗ 2 = 4 peripheral A clock cycles.

## 11.3.5 Channel Control

Each ETM channel can be independently configured to be enabled or disabled. When channeln is enabled and receives the event configured via SOC\_ETM\_CHn\_EVT\_ID, it maps the event to the task configured via SOC\_ETM\_CHn\_TASK\_ID. When channeln is disabled, even if it receives the configured via SOC\_ETM\_CHn\_EVT\_ID, no task will be generated.

To enable ETM channeln:

1. Write 1 to SOC\_ETM\_CH\_ENABLEn
2. Read SOC\_ETM\_CH\_ENABLEDn. 1 indicates that channeln has been enabled, and 0 indicates disabled

To disable ETM channeln:

1. Write 1 to SOC\_ETM\_CH\_DISABLEn
2. Read SOC\_ETM\_CH\_ENABLEDn. 0 indicates that channeln is disabled, and 1 indicates enabled

If SOC\_ETM\_CHn\_EVT\_ID or SOC\_ETM\_CHn\_TASK\_ID is configured to 0, ETM channeln will also be disabled.

The complete procedure to configure ETM channeln is as follows:

1. Enable the ETM’s clock by writing 1 to PCR\_ETM\_CLK\_EN
2. Select the event to be received by channeln via SOC\_ETM\_CHn\_EVT\_ID
3. Select the task mapped to the received event via SOC\_ETM\_CHn\_TASK\_ID
4. Write 1 to field SOC\_ETM\_CH\_ENABLEn

5. When channeln no longer needs to map the selected event to the selected task, disable channeln by setting SOC\_ETM\_CH\_DISABLEn. To configure a new event and task mapping, repeat Steps 1 to 3. If no configurations, channeln will remain disabled
6. The ETM module can be reset by writing 1 and then 0 to the PCR\_ETM\_RST\_EN field

ESP32-C6 TRM (Version 1.1)

## 11.4 Register Summary

The addresses in this section are relative to Event Task Matrix base address provided in Table 5.3-2 in Chapter 5 System and Memory .

The abbreviations given in Column Access are explained in Section Access Types for Registers .

| Name                       | Description                 | Address                | Access                 |
|----------------------------|-----------------------------|------------------------|------------------------|
| Configuration Register     | Configuration Register      | Configuration Register | Configuration Register |
| SOC_ETM_CH_ENA_AD0_REG     | Channel status register     | 0x0000                 | R/WTC/WTS              |
| SOC_ETM_CH_ENA_AD0_SET_REG | Channel enable register     | 0x0004                 | WT                     |
| SOC_ETM_CH_ENA_AD0_CLR_REG | Channel disable register    | 0x0008                 | WT                     |
| SOC_ETM_CH_ENA_AD1_REG     | Channel status register     | 0x000C                 | R/WTC/WTS              |
| SOC_ETM_CH_ENA_AD1_SET_REG | Channel enable register     | 0x0010                 | WT                     |
| SOC_ETM_CH_ENA_AD1_CLR_REG | Channel disable register    | 0x0014                 | WT                     |
| SOC_ETM_CH0_EVT_ID_REG     | Channel0 event ID register  | 0x0018                 | R/W                    |
| SOC_ETM_CH0_TASK_ID_REG    | Channel0 task ID register   | 0x001C                 | R/W                    |
| SOC_ETM_CH1_EVT_ID_REG     | Channel1 event ID register  | 0x0020                 | R/W                    |
| SOC_ETM_CH1_TASK_ID_REG    | Channel1 task ID register   | 0x0024                 | R/W                    |
| SOC_ETM_CH2_EVT_ID_REG     | Channel2 event ID register  | 0x0028                 | R/W                    |
| SOC_ETM_CH2_TASK_ID_REG    | Channel2 task ID register   | 0x002C                 | R/W                    |
| SOC_ETM_CH3_EVT_ID_REG     | Channel3 event ID register  | 0x0030                 | R/W                    |
| SOC_ETM_CH3_TASK_ID_REG    | Channel3 task ID register   | 0x0034                 | R/W                    |
| SOC_ETM_CH4_EVT_ID_REG     | Channel4 event ID register  | 0x0038                 | R/W                    |
| SOC_ETM_CH4_TASK_ID_REG    | Channel4 task ID register   | 0x003C                 | R/W                    |
| SOC_ETM_CH5_EVT_ID_REG     | Channel5 event ID register  | 0x0040                 | R/W                    |
| SOC_ETM_CH5_TASK_ID_REG    | Channel5 task ID register   | 0x0044                 | R/W                    |
| SOC_ETM_CH6_EVT_ID_REG     | Channel6 event ID register  | 0x0048                 | R/W                    |
| SOC_ETM_CH6_TASK_ID_REG    | Channel6 task ID register   | 0x004C                 | R/W                    |
| SOC_ETM_CH7_EVT_ID_REG     | Channel7 event ID register  | 0x0050                 | R/W                    |
| SOC_ETM_CH7_TASK_ID_REG    | Channel7 task ID register   | 0x0054                 | R/W                    |
| SOC_ETM_CH8_EVT_ID_REG     | Channel8 event ID register  | 0x0058                 | R/W                    |
| SOC_ETM_CH8_TASK_ID_REG    | Channel8 task ID register   | 0x005C                 | R/W                    |
| SOC_ETM_CH9_EVT_ID_REG     | Channel9 event ID register  | 0x0060                 | R/W                    |
| SOC_ETM_CH9_TASK_ID_REG    | Channel9 task ID register   | 0x0064                 | R/W                    |
| SOC_ETM_CH10_EVT_ID_REG    | Channel10 event ID register | 0x0068                 | R/W                    |
| SOC_ETM_CH10_TASK_ID_REG   | Channel10 task ID register  | 0x006C                 | R/W                    |
| SOC_ETM_CH11_EVT_ID_REG    | Channel11 event ID register | 0x0070                 | R/W                    |
| SOC_ETM_CH11_TASK_ID_REG   | Channel11 task ID register  | 0x0074                 | R/W                    |
| SOC_ETM_CH12_EVT_ID_REG    | Channel12 event ID register | 0x0078                 | R/W                    |
| SOC_ETM_CH12_TASK_ID_REG   | Channel12 task ID register  | 0x007C                 | R/W                    |
| SOC_ETM_CH13_EVT_ID_REG    | Channel13 event ID register | 0x0080                 | R/W                    |
| SOC_ETM_CH13_TASK_ID_REG   | Channel13 task ID register  | 0x0084                 | R/W                    |
| SOC_ETM_CH14_EVT_ID_REG    | Channel14 event ID register | 0x0088                 | R/W                    |
| SOC_ETM_CH14_TASK_ID_REG   | Channel14 task ID register  | 0x008C                 | R/W                    |

| Name                                              | Description                 | Address   | Access   |
|---------------------------------------------------|-----------------------------|-----------|----------|
| SOC_ETM_CH15_EVT_ID_REG                           | Channel15 event ID register | 0x0090    | R/W      |
| SOC_ETM_CH15_TASK_ID_REG                          | Channel15 task ID register  | 0x0094    | R/W      |
| SOC_ETM_CH16_EVT_ID_REG                           | Channel16 event ID register | 0x0098    | R/W      |
| SOC_ETM_CH16_TASK_ID_REG                          | Channel16 task ID register  | 0x009C    | R/W      |
| SOC_ETM_CH17_EVT_ID_REG                           | Channel17 event ID register | 0x00A0    | R/W      |
| SOC_ETM_CH17_TASK_ID_REG                          | Channel17 task ID register  | 0x00A4    | R/W      |
| SOC_ETM_CH18_EVT_ID_REG                           | Channel18 event ID register | 0x00A8    | R/W      |
| SOC_ETM_CH18_TASK_ID_REG                          | Channel18 task ID register  | 0x00AC    | R/W      |
| SOC_ETM_CH19_EVT_ID_REG                           | Channel19 event ID register | 0x00B0    | R/W      |
| SOC_ETM_CH19_TASK_ID_REG                          | Channel19 task ID register  | 0x00B4    | R/W      |
| SOC_ETM_CH20_EVT_ID_REG                           | Channel20 event ID register | 0x00B8    | R/W      |
| SOC_ETM_CH20_TASK_ID_REG                          | Channel20 task ID register  | 0x00BC    | R/W      |
| SOC_ETM_CH21_EVT_ID_REG                           | Channel21 event ID register | 0x00C0    | R/W      |
| SOC_ETM_CH21_TASK_ID_REG                          | Channel21 task ID register  | 0x00C4    | R/W      |
| SOC_ETM_CH22_EVT_ID_REG                           | Channel22 event ID register | 0x00C8    | R/W      |
| SOC_ETM_CH22_TASK_ID_REG                          | Channel22 task ID register  | 0x00CC    | R/W      |
| SOC_ETM_CH23_EVT_ID_REG                           | Channel23 event ID register | 0x00D0    | R/W      |
| SOC_ETM_CH23_TASK_ID_REG                          | Channel23 task ID register  | 0x00D4    | R/W      |
| SOC_ETM_CH24_EVT_ID_REG                           | Channel24 event ID register | 0x00D8    | R/W      |
| SOC_ETM_CH24_TASK_ID_REG                          | Channel24 task ID register  | 0x00DC    | R/W      |
| SOC_ETM_CH25_EVT_ID_REG                           | Channel25 event ID register | 0x00E0    | R/W      |
| SOC_ETM_CH25_TASK_ID_REG                          | Channel25 task ID register  | 0x00E4    | R/W      |
| SOC_ETM_CH26_EVT_ID_REG                           | Channel26 event ID register | 0x00E8    | R/W      |
| SOC_ETM_CH26_TASK_ID_REG                          | Channel26 task ID register  | 0x00EC    | R/W      |
| SOC_ETM_CH27_EVT_ID_REG                           | Channel27 event ID register | 0x00F0    | R/W      |
| SOC_ETM_CH27_TASK_ID_REG                          | Channel27 task ID register  | 0x00F4    | R/W      |
| SOC_ETM_CH28_EVT_ID_REG                           | Channel28 event ID register | 0x00F8    | R/W      |
| SOC_ETM_CH28_TASK_ID_REG                          | Channel28 task ID register  | 0x00FC    | R/W      |
| SOC_ETM_CH29_EVT_ID_REG                           | Channel29 event ID register | 0x0100    | R/W      |
| SOC_ETM_CH29_TASK_ID_REG                          | Channel29 task ID register  | 0x0104    | R/W      |
| SOC_ETM_CH30_EVT_ID_REG                           | Channel30 event ID register | 0x0108    | R/W      |
| SOC_ETM_CH30_TASK_ID_REG                          | Channel30 task ID register  | 0x010C    | R/W      |
| SOC_ETM_CH31_EVT_ID_REG                           | Channel31 event ID register | 0x0110    | R/W      |
| SOC_ETM_CH31_TASK_ID_REG                          | Channel31 task ID register  | 0x0114    | R/W      |
| SOC_ETM_CH32_EVT_ID_REG                           | Channel32 event ID register | 0x0118    | R/W      |
| SOC_ETM_CH32_TASK_ID_REG                          | Channel32 task ID register  | 0x011C    | R/W      |
| SOC_ETM_CH33_EVT_ID_REG                           | Channel33 event ID register | 0x0120    | R/W      |
| SOC_ETM_CH33_TASK_ID_REG                          | Channel33 task ID register  | 0x0124    | R/W      |
| SOC_ETM_CH34_EVT_ID_REG                           | Channel34 event ID register | 0x0128    | R/W      |
| SOC_ETM_CH34_TASK_ID_REG                          | Channel34 task ID register  | 0x012C    | R/W      |
| SOC_ETM_CH35_EVT_ID_REG                           | Channel35 event ID register | 0x0130    | R/W      |
| SOC_ETM_CH35_TASK_ID_REG  SOC_ETM_CH36_EVT_ID_REG | Channel35 task ID register  | 0x0134    | R/W      |
|                                                   | Channel36 event ID register | 0x0138    | R/W      |

| Name                     | Description                 | Address   | Access   |
|--------------------------|-----------------------------|-----------|----------|
| SOC_ETM_CH36_TASK_ID_REG | Channel36 task ID register  | 0x013C    | R/W      |
| SOC_ETM_CH37_EVT_ID_REG  | Channel37 event ID register | 0x0140    | R/W      |
| SOC_ETM_CH37_TASK_ID_REG | Channel37 task ID register  | 0x0144    | R/W      |
| SOC_ETM_CH38_EVT_ID_REG  | Channel38 event ID register | 0x0148    | R/W      |
| SOC_ETM_CH38_TASK_ID_REG | Channel38 task ID register  | 0x014C    | R/W      |
| SOC_ETM_CH39_EVT_ID_REG  | Channel39 event ID register | 0x0150    | R/W      |
| SOC_ETM_CH39_TASK_ID_REG | Channel39 task ID register  | 0x0154    | R/W      |
| SOC_ETM_CH40_EVT_ID_REG  | Channel40 event ID register | 0x0158    | R/W      |
| SOC_ETM_CH40_TASK_ID_REG | Channel40 task ID register  | 0x015C    | R/W      |
| SOC_ETM_CH41_EVT_ID_REG  | Channel41 event ID register | 0x0160    | R/W      |
| SOC_ETM_CH41_TASK_ID_REG | Channel41 task ID register  | 0x0164    | R/W      |
| SOC_ETM_CH42_EVT_ID_REG  | Channel42 event ID register | 0x0168    | R/W      |
| SOC_ETM_CH42_TASK_ID_REG | Channel42 task ID register  | 0x016C    | R/W      |
| SOC_ETM_CH43_EVT_ID_REG  | Channel43 event ID register | 0x0170    | R/W      |
| SOC_ETM_CH43_TASK_ID_REG | Channel43 task ID register  | 0x0174    | R/W      |
| SOC_ETM_CH44_EVT_ID_REG  | Channel44 event ID register | 0x0178    | R/W      |
| SOC_ETM_CH44_TASK_ID_REG | Channel44 task ID register  | 0x017C    | R/W      |
| SOC_ETM_CH45_EVT_ID_REG  | Channel45 event ID register | 0x0180    | R/W      |
| SOC_ETM_CH45_TASK_ID_REG | Channel45 task ID register  | 0x0184    | R/W      |
| SOC_ETM_CH46_EVT_ID_REG  | Channel46 event ID register | 0x0188    | R/W      |
| SOC_ETM_CH46_TASK_ID_REG | Channel46 task ID register  | 0x018C    | R/W      |
| SOC_ETM_CH47_EVT_ID_REG  | Channel47 event ID register | 0x0190    | R/W      |
| SOC_ETM_CH47_TASK_ID_REG | Channel47 task ID register  | 0x0194    | R/W      |
| SOC_ETM_CH48_EVT_ID_REG  | Channel48 event ID register | 0x0198    | R/W      |
| SOC_ETM_CH48_TASK_ID_REG | Channel48 task ID register  | 0x019C    | R/W      |
| SOC_ETM_CH49_EVT_ID_REG  | Channel49 event ID register | 0x01A0    | R/W      |
| SOC_ETM_CH49_TASK_ID_REG | Channel49 task ID register  | 0x01A4    | R/W      |
| SOC_ETM_CLK_EN_REG       | ETM clock enable register   | 0x01A8    | R/W      |
| Version Register         |                             |           |          |
| SOC_ETM_DATE_REG         | Version control register    | 0x01AC    | R/W      |

## 11.5 Registers

The addresses in this section are relative to Event Task Matrix base address provided in Table 5.3-2 in Chapter 5 System and Memory .

Register 11.1. SOC\_ETM\_CH\_ENA\_AD0\_REG (0x0000)

![Image](images/11_Chapter_11_img004_80b5b9e2.png)

SOC\_ETM\_CH\_ENABLEDn (n: 0-31) Represents the status of channeln .

0: Disabled 1: Enabled (R/WTC/SS)

Register 11.2. SOC\_ETM\_CH\_ENA\_AD0\_SET\_REG (0x0004)

![Image](images/11_Chapter_11_img005_b1c2a20f.png)

SOC\_ETM\_CH\_ENABLEn (n: 0-31) Configures whether to enable channeln .

0: Invalid. No effect 1: Enable (WT)

Submit Documentation Feedback

![Image](images/11_Chapter_11_img006_1d1a6424.png)

## Register 11.6. SOC\_ETM\_CH\_ENA\_AD1\_CLR\_REG (0x0014)

![Image](images/11_Chapter_11_img007_b4e51f16.png)

SOC\_ETM\_CH\_DISABLEn (n: 32-49) Configures whether to disable channeln .

0: Invalid. No effect

1: Disable

(WT)

Register 11.7. SOC\_ETM\_CHn\_EVT\_ID\_REG (n: 0-49) (0x0018+0x8*n)

![Image](images/11_Chapter_11_img008_3dc04f11.png)

SOC\_ETM\_CHn\_EVT\_ID (n: 0-49) Configures the event ID of channeln. See Table 11.3-1. (R/W)

Register 11.8. SOC\_ETM\_CHn\_TASK\_ID\_REG (n: 0-49) (0x001C+0x8*n)

![Image](images/11_Chapter_11_img009_19e3252d.png)

## Register 11.9. SOC\_ETM\_CLK\_EN\_REG (0x01A8)

![Image](images/11_Chapter_11_img010_d9d1c68e.png)

## SOC\_ETM\_CLK\_EN Configures resister clock gating.

- 0: Support clock only when application writes registers
- 1: Force on clock gating for registers

(R/W)

## Register 11.10. SOC\_ETM\_DATE\_REG (0x01AC)

![Image](images/11_Chapter_11_img011_f7136fc8.png)

SOC\_ETM\_DATE Version control register. (R/W)
