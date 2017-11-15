#! /bin/bash
losetup /dev/loop0 workdisk.img
mount -t msdos /dev/loop0 /mnt/msdos
rm -f /mnt/msdos/FIND.EX /mnt/msdos/PRINT.COM /mnt/msdos/GRAFTABL.COM /mnt/msdos/GRAPHICS.COM
cp flashbio/flashbio.com /mnt/msdos/
cp flashbio/TESTBRD.EXE /mnt/msdos/
cp flashbio/TESTSZ.EXE /mnt/msdos/
cp flashbio/TESTPAR.EXE /mnt/msdos/
umount /mnt/msdos
losetup -d /dev/loop0
