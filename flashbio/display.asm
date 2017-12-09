;; display.asm
;; Scott M Baker, http://www.smbaker.com/
;;
;; display utility functions.

printstr:
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     BH,0            ; page number
        MOV     AH,3 		; get cursor position
        INT     10H

        MOV     BL,7            ; color: grey on black
        MOV     CX,1            ; times to output char
.NEXT:  MOV     AH,2            ; set cursor position
        INT     10H
        MOV     AL,[CS:SI]
	INC     SI
	CMP     AL,'^'
	JNE     .NOTNEWLINE
	CALL    inline_newline
        JMP     SHORT .NEXT
.NOTNEWLINE:
        CMP     AL,'$'
        JE      .DONE
        MOV     AH,9 		; output character
        INT     10H
	INC     DX              ; increment cursor position
        JMP     SHORT .NEXT
.DONE:
	POP     DX
	POP     CX
	POP     BX
	POP     AX
        RET

inline_newline:
	;; assumes cursor position is in DX

	MOV     DL, 0
	INC	DH
	CMP     DH, 25
	JNE     .NOSCROLL

	PUSH    AX
	PUSH    BX
	PUSH    CX
	PUSH    DX
	MOV     AH,6     	; scroll
	MOV     AL,1
	MOV     BH,7            ; grey on black
        MOV     CH, 0           ; upper column
	MOV     CL, 0           ; upper row
	MOV     DH, 24          ; lower column
	MOV     DL, 79          ; lower row
	INT     10H
	POP     DX
	POP     CX
	POP     BX
	POP     AX

	MOV     DH, 24
.NOSCROLL:
	;; returns cursor position in DX
	RET

newline:
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX
        MOV     BH,0            ; page number
        MOV     AH,3 		; get cursor position
        INT     10H
        call    inline_newline
        MOV     AH,2            ; set cursor position
        INT     10H
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET

print_char:
        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX

        MOV     BH,0            ; page number

        MOV     BL,7            ; color: grey on black
        MOV     CX,1            ; times to output char
        MOV     AH,9 		; output character
        INT     10H

        MOV     AH,3 		; get cursor position
        INT     10H
	INC     DX              ; increment cursor position
        MOV     AH,2            ; set cursor position
        INT     10H
.DONE:
	POP     DX
	POP     CX
	POP     BX
	POP     AX
        RET

print_hex_byte:
        push    BX
        rol     al, 4
        mov     bl, al
        and     bl, 0Fh
        add     bl, 30h
        cmp     bl, 39h
        jna     short .P2
        add     bl, 7
.P2:
        xchg    bl, al
        call    print_char
        xchg    bl, al

        rol     al, 4
        mov     bl, al
        and     bl, 0Fh
        add     bl, 30h
        cmp     bl, 39h
        jna     short .P3
        add     bl, 7
.P3:
        xchg    bl, al
        call    print_char
        xchg    bl, al

        pop     BX
        ret

print_hex_word:
        xchg    ah, al
        call    print_hex_byte
        xchg    ah, al
        call    print_hex_byte
        ret

printregs_enter:
        PUSH    AX
        PUSH    SI
        PUSHF
        LEA     SI, [debug_enter]
        CALL    printstr
        CALL    print_hex_word
        ;
        LEA     SI, [debug_bx]
        CALL    printstr
        MOV     AX, BX
        CALL    print_hex_word
        ;
        LEA     SI, [debug_cx]
        CALL    printstr
        MOV     AX, CX
        CALL    print_hex_word
        ;
        LEA     SI, [debug_dx]
        CALL    printstr
        MOV     AX, DX
        CALL    print_hex_word
%ifdef PRINTREGS_PRINTSEGS
        ;
        LEA     SI, [debug_ds]
        CALL    printstr
        MOV     AX, DS
        CALL    print_hex_word
        ;
        LEA     SI, [debug_es]
        CALL    printstr
        MOV     AX, ES
        CALL    print_hex_word
        ;
        LEA     SI, [debug_ss]
        CALL    printstr
        MOV     AX, SS
        CALL    print_hex_word
        CALL    newline
%endif
        POPF
        POP     SI
        POP     AX
        RET

printregs_exit:
        PUSH    AX
        PUSH    SI
        PUSHF
        LEA     SI, [debug_exit]
        CALL    printstr
        CALL    print_hex_word
        ;
        LEA     SI, [debug_bx]
        CALL    printstr
        MOV     AX, BX
        CALL    print_hex_word
        ;
        LEA     SI, [debug_cx]
        CALL    printstr
        MOV     AX, CX
        CALL    print_hex_word
        ;
        LEA     SI, [debug_dx]
        CALL    printstr
        MOV     AX, DX
        CALL    print_hex_word
%ifdef PRINTREGS_PRINTSEGS
        ;
        LEA     SI, [debug_ds]
        CALL    printstr
        MOV     AX, DS
        CALL    print_hex_word
        ;
        LEA     SI, [debug_es]
        CALL    printstr
        MOV     AX, ES
        CALL    print_hex_word
        ;
        LEA     SI, [debug_ss]
        CALL    printstr
        MOV     AX, SS
        CALL    print_hex_word
%endif
        POPF
        PUSHF
        JNC     .nocarry
        LEA     SI, [debug_car]
        CALL    printstr
.nocarry:
        CALL    newline
        POPF
        POP     SI
        POP     AX
        RET

debug_enter  DB      'ent A: $'
debug_exit  DB      ' > A: $'
debug_bx  DB      ' B: $'
debug_cx  DB      ' C: $'
debug_dx  DB      ' D: $'
debug_es  DB      ' es: $'
debug_ds  DB      ' ds: $'
debug_ss  DB      ' ss: $'
debug_car DB      ' CF$'
