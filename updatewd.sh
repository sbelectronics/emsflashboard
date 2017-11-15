#! /bin/bash
losetup /dev/loop0 workdisk.img
mount -t msdos /dev/loop0 /mnt/msdos
rm -f /mnt/msdos/flashbio.com
cp flashbio/flashbio.com /mnt/msdos
umount /mnt/msdos
losetup -d /dev/loop0
