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
