all: flashbio.bin

flashbio.bin: flashbio.com pcjrcart
	./pcjrcart flashbio.com

flashbio.com: flashbio.asm
	nasm flashbio.asm -fbin -o flashbio.com

pcjrcart:
	gcc -o pcjrcart pcjrcart.c

clean:
	rm -f pcjrcart flashbio.bin flashbio.com

dos330: flashbio.bin ../bootdisks/dos330_1.img
	rm -f ../images/dos330.rom
	cp flashbio.bin ../images/dos330.rom
	dd if=../bootdisks/dos330_1.img of=../images/dos330.rom bs=1024 seek=16

dos330-nb: ../bootdisks/dos330_1.img
	rm -f ../images/dos330-nb.rom
	dd if=../bootdisks/dos330_1.img of=../images/dos330-nb.rom bs=1024 seek=16

dos331: flashbio.bin ../bootdisks/dos331_144.img
	rm -f ../images/dos331_144.rom*
	cp flashbio.bin ../images/dos331_144.rom
	dd if=../bootdisks/dos331_144.img of=../images/dos331_144.rom bs=1024 seek=16
	python ./patchrom.py ../images/dos331_144.rom num_cyl=80 num_head=2 num_sec=18 floppy_type=4
	split --bytes 512K --numeric-suffixes --suffix-length=1 ../images/dos331_144.rom ../images/dos331_144.rom.
	rm -f ../images/dos331_144.rom

dos331_smb: flashbio.bin ../bootdisks/dos331_smb.img
	rm -f ../images/dos331_smb.rom*
	cp flashbio.bin ../images/dos331_smb.rom
	dd if=../bootdisks/dos331_smb.img of=../images/dos331_smb.rom bs=1024 seek=16
	python ./patchrom.py ../images/dos331_smb.rom num_cyl=80 num_head=2 num_sec=18 floppy_type=4
	split --bytes 512K --numeric-suffixes --suffix-length=1 ../images/dos331_smb.rom ../images/dos331_smb.rom.
	rm -f ../images/dos331_smb.rom

dos331_krynn: flashbio.bin ../bootdisks/dos331_krynn.img
	rm -f ../images/dos331_krynn.rom*
	cp flashbio.bin ../images/dos331_krynn.rom
	dd if=../bootdisks/dos331_krynn.img of=../images/dos331_krynn.rom bs=1024 seek=16
	python ./patchrom.py ../images/dos331_krynn.rom num_cyl=80 num_head=2 num_sec=18 floppy_type=4 write_mode=1
	split --bytes 512K --numeric-suffixes --suffix-length=1 ../images/dos331_krynn.rom ../images/dos331_krynn.rom.
	rm -f ../images/dos331_krynn.rom