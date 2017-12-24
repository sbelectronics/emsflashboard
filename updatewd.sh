#! /bin/bash
rm -f workdisk.img
cp bootdisks/workdisk.orig workdisk.img
losetup /dev/loop0 workdisk.img
mount -t msdos /dev/loop0 /mnt/msdos
rm -f /mnt/msdos/FIND.EX /mnt/msdos/PRINT.COM /mnt/msdos/GRAFTABL.COM /mnt/msdos/GRAPHICS.COM
cp flashbio/flashbio.com /mnt/msdos/
cp flashbio/FLASHUTL.EXE /mnt/msdos/
umount /mnt/msdos
losetup -d /dev/loop0
