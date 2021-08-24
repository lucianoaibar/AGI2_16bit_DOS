# Adventure Game Interpreter (AGI) v2.440 for DOS (16-bit)

This is a custom & fully working version of **AGI 2.440** for DOS (16-bit).\
The assembly source code is the result of the debugging, decryption, decompilation, analysis and refactoring of the following files from "Leisure Suit Larry in the Land of the Lounge Lizards":

* Play.com
* Larry.exe
* Agidata.ovl
* hgc_font
* EGA video driver
* IBM sound driver

![screenshot](https://github.com/lucianoaibar/AGI2_16bit_DOS/blob/main/screenshot.png?raw=true)

## Game engine

The Adventure Game Interpreter (AGI) is a game engine developed by Sierra On-Line.
The company originally developed the engine for King's Quest (1984), an adventure game which Sierra and IBM wished to market in order to attract consumers to IBM's lower-cost home computer, the IBM PCjr.

AGI was capable of running animated, color adventure games with music and sound effects.

The player controls the game with a keyboard and, optionally, a joystick.
After the launch of King's Quest, Sierra continued to develop and improve the Adventure Game Interpreter.
They employed it in 14 of their games between 1984 and 1989, before replacing it with a more sophisticated engine, Sierra's Creative Interpreter.

## More info

* [Adventure Game Interpreter - Wikipedia](https://en.wikipedia.org/wiki/Adventure_Game_Interpreter)
* [AGI - ScummVM wiki](https://wiki.scummvm.org/index.php?title=AGI)
* [AGI Studio Documents - Sierra Help](http://agi.sierrahelp.com/Documentation/index.html)

## Setup

* [NASM](https://nasm.us) and [OpenWatcom](http://www.openwatcom.org/) are required to compile
* Copy **build_config.cmd.template** to **build_config.cmd**
* Edit build_config.cmd and set the NASM and WATCOM variables to the root directories for each compiler

## Build process

Execute **build.cmd** to build agi2.asm.\
The generated executable is "build\C\AGI2.EXE"

## Run

Execute **run.cmd** to load AGI2.EXE in DOSBox.

## Having fun

To create your own game that uses this engine you can use [AGI Studio](http://agi.sierrahelp.com/IDEs/AGIStudio.html).\
AGI Studio is a complete IDE for Windows with scripting support.

![screenshot](http://agi.sierrahelp.com/Assets/AGIStudio/AGIStudio.gif)

## Additional credits
* *Sierra On-line* for its wonderful games
* *DOSBox* for the best DOS emulator
