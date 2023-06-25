# livingworlds
This is a color cycling demo based on Mark Ferrari's "Living Worlds" found here: http://www.effectgames.com/demos/worlds/. This is ported to the Foenix F256 platform for educational purposes.

How to run it on F256k or F256 Jr:
  * Use an F256 system with a 6502-based or 65816-based CPU.
  * Build the vcproj accordingly.
  * Use a tool like the 'F256 Uploader', distributed by the hardware vendor, or FoenixMgr available [here](https://github.com/pweingar/FoenixMgr) to transmit the binary over COM3 (USB) interface. 
  * Choose "Boot from RAM" and load it at 0x0000, or the offset in the filename for already-released binaries (e.g., if the release is called livingworlds.0800.bin, load it at 0800).

How to run it on FoenixIDE emulator:
  * Use the latest emulator.
  * Build the vcproj accordingly.
  * Launch the emulator, and ensure that it's on F256 board mode (see the indicator in the lower left), not Rev U or Rev C or so forth.
  * Go to File -> Open Executable File and choose the .hex file.
  * Hit "Run".

See the note under 'Controls' about keyboard with the emulator.

-----
## Controls
The application responds to F256k arrow keys.

**Left arrow** - Move to the previous scene.

**Right arrow** - Move to the next scene.

If you are on emulator, keyboard support has been added recently. To get it, please use the latest version of [this fork](https://github.com/clandrew/fnxide) where I added it there.

-----

## Build

This demo is set up using Visual Studio 2019 which calls [64tass](https://tass64.sourceforge.net) assembler.

There are Visual Studio custom build steps which call into [64tass](https://tass64.sourceforge.net). You may need to update these build steps to point to wherever the 64tass executable lives on your machine. I noticed good enough integration with the IDE, for example if there is an error when assembling, the message pointing to the line number gets conveniently reported through to the Errors window that way.

For a best experience, consider using [this Visual Studio extension](https://github.com/clandrew/vscolorize65c816) for 65c816-based syntax highlighting.
