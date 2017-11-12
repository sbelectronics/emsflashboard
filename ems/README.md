EMS driver for smbaker's flashboard

Based on Lo-Tech's LTEMM driver. 

The sole difference this that this driver writes a 1 to PORT+$04 to
enable the banking on smbaker's ems board.

To build, first obtain the lo-tech source
files and copy them to this directory. Then run "make applypatch". This
will generate SBEMM.ASM. Finally, run "BUILD.BAT".

Note that "make applypatch" needs to be run on a linux machine, whereas
"BUILD.BAT" needs to be run from a DOS machine with TASM and TLINK
in the path.
