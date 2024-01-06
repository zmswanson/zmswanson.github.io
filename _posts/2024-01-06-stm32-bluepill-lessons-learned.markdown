---
layout: post
title:  "STM32 Bluepill Lessons Learned"
date:   2024-01-06 13:17:00 -0600
categories: stm32 embedded development
---
![image tooltip here](/assets/bluepill.jpg)

The STM32-based "Blue Pill" development board was a board I came across while working on my senior
design project at UNL in 2017-2018. The board was selected because we were required to develop our
project using non-Arduino, 32-bit microcontrollers. This was cheap so we rolled with it. We ran into
a number of headaches getting things off the ground but eventually built our Design Showcase winning
project around the STM32F103C8T6 controller on the board.

The dev boards sat in a box for some years  until I decided to work on a little plant watering
project and came across them. I should have remembered the headaches but decided to prototype with
the bluepill dev boards anyway.

It didn't take long for the headaches to arise. Time apparently wasn't kind to my knock-off ST-Link
V2 programmer which proved unusable. I should throw it away but I usually don't.. a headache for
another day. I found that I was able to use the embedded ST-Link programmer from another STM32 Disco
board to program and debug the STM32 on the bluepill. I removed both CN2 jumpers from the Disco
board and connected the Disco's CN4 header to the bluepill's SWD header.

When working with System Workbench for STM32, I had to change the Run/Debug configuration "Reset
Mode" option to "Software system restart". I don't have to worry about pressing reset on the 
Bluepill when I do this. I also ran into issues with programming the device when I had the 
"Shareable ST-Link" option selected in the Run/Debug configuration.

I developed firmware using System Workbench for STM32 on Macbook Pro. Depending on the project, I
sometimes like to use the Standard Peripheral Library (SPL), so I get very low-level control and
avoid the bloat of ST Cube. However, ST doesn't support the SPL anymore leading to more difficulties
getting dependencies and other build tools pulled in. On this particular project I ran issues trying
to download the target firmwares. The solution was to modify the file located at the following on my
system "Applications/AC6/SystemWorkbench.app/Contents/Eclipse/plugins/..."
".../fr.ac6.mcu.ide_2.9.0.201904120827/resources/board_def/stm32targets.xml" to include a new server
https://www.st.com/resource/en/firmware2/ near the top of the file. This url was found in a
HTTP redirect message via WireShark that the download function obviously doesn't handle well.

## Bluepill Jumper Configurations
STM32 Bluepill boot pin jumpers: If you are using SWD for programming, then Boot 0 = 0 and 
Boot 1 = 0 (this directly programs flash memory). If you are using USART1 for programming, then 
Boot 0 = 1 and Boot 1 = 0 (loads the bootloader on boot enabling programming via USART). For
whatever reason, it took a lot of google searches to find a clear answer on that. Even then I had to
reference the manual to really understand.
