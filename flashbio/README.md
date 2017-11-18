# smbaker's Flash / EMS board - Flash BIOS Extension #
## Scott Baker, http://www.smbaker.com/ ##

When configured as a Flash drive, the board supports 512KB to 2MB of flash storage. The flash BIOS is currently read only. I haven't yet decided whether I will add read/write support (there are concerns about flash wear, considering that DOS is likely to write certain sectors over and over again where the FAT table and other data structures reside).

The board uses a 64 KB frame, typically located at segment E000 divided into four 16 KB banks that may be paged individually into the 2 MB address space. The first bank is reserved for the flash bios extension, allowing the PC to boot from flash. The second bank is used for accessing the disk. The third and fourth banks are unused. The board is designed to optionally use a 32 KB frame with only two 16 KB banks, though that reduced frame size is currently untested.

As configured, the board will assume the role of the first floppy disk in the computer (drive 0 aka A:). Drive geometry is stored in the file romvars.asm, and defaults to emulating a 360 KB floppy disk, which fits nicely within a single 39SF040 512KB flash chip. It should be possible to increase the drive geometry to emulate larger floppy drives, and use multiple flash chips. My immediately plan is to emulate a 1.44 MB floppy using three flash chips. 

There is a Makefile which will use NASM to build a binary of the flash bios extension. It's suggested that you then combine this binary with a floppy disk image (see the dos330 Make target) to produce a ROM image that contains both the BIOS and the boot floppy image. The floppy image should begin at offset 16384 in the ROM image. 

This has been tested using a 360 KB DOS 3.30 image.

