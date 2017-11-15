RAMVARS_SIGNATURE equ  "Sb"

steal_ram:
        ;; The idea comes from XT-IDE. Steal some RAM from the BIOS. Store a
        ;; signature so we can find it again.
	PUSH    DS
	PUSH    AX
	XOR     AX, AX
        MOV     DS, AX
	MOV	AX, [DS:413h]
	DEC	AX
        DEC     AX
        DEC     AX
	MOV	[DS:413h], AX

	SHL     AX, 6 		; AX holds segment of RAMVARS
        MOV	DS, AX
	MOV     WORD [DS:RAMVARS.signature], RAMVARS_SIGNATURE

	POP     AX
	POP     DS
        RET

find_ramvars:
        JMP     find_ramvars_dos

find_ramvars_bios:
        ;; Stolen from XT-IDE
        ;; Returns
        ;;     DS - RamVars Segment
        XOR     AX, AX
        MOV     DS, AX
        MOV     DI, [DS:413h]                  ; Load available base memory size in kB
        SHL     DI, 6
.LoopStolenKBs:
        mov             ds, di                                  ; EBDA segment to DS
        add             di, BYTE 64                             ; DI to next stolen kB
        cmp             WORD [RAMVARS.signature], RAMVARS_SIGNATURE
        jne             SHORT .LoopStolenKBs    ; Loop until sign found (always found eventually)
        ret

find_ramvars_dos:
        ;; For developing in DOS. Just assume that RAMVARS are at CS plus
        ;; 7K
        ;; Returns:
        ;;     DS - RamVars Segment
        PUSH    AX
        MOV     AX, CS
        ADD     AX, (7*1024/16)
        MOV     DS, AX
        POP     AX
        RET

struc   RAMVARS
	.signature  resb 2
        .int13_old  resb 4
endstruc
