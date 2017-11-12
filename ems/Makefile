all:

genpatch:
	diff -c LTEMM-ORIG.ASM SBEMM.ASM > SBEMM.diff; [ $$? -eq 1 ]

applypatch:
	rm -f SBEMM.ASM
	patch -i SBEMM.diff -o tempfile
	mv tempfile SBEMM.ASM
