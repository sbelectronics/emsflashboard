        org 100h

section .text

start:
        JMP     main

%include "romvar.asm"

main:   CALL    find_ramvars
        CALL    banner
        CALL    enable_page
        CALL    install_int13_handler

        LEA     SI, [msg_int13_1]
        CALL    printstr
        MOV     AX, [RAMVARS.int13_old]
        CALL    print_hex_word
        MOV     AL, ':'
        CALL    print_char
        MOV     AX, [RAMVARS.int13_old+2]
        CALL    print_hex_word
        CALL    newline

        CALL    test_chs_to_block

        LEA     SI, [msg_installed]
        CALL    printstr
        JMP     tsr
        ;JMP     retdos

test_chs_to_block:
        MOV     CH, 1   ; cyl
        MOV     CL, 3   ; sector
        MOV     DH, 1   ; head
        CALL    chs_to_blk
        MOV     AX, DX
        CALL    print_hex_word       ; print block
        CALL    newline
        CALL    blk_to_page
        CALL    print_hex_word       ; print page
        CALL    newline
        MOV     AX, SI
        CALL    print_hex_word       ; print byte offset
        CALL    newline
        RET

banner: LEA     SI,[title]
        CALL    printstr
        LEA     SI, [banner_pagereg]
        CALL    printstr
        MOV     AX, [CS:page_reg]
        CALL    print_hex_word
        LEA     SI, [banner_frame]
        CALL    printstr
        MOV     AX, [CS:page_frame_seg]
        CALL    print_hex_word
        LEA     SI, [banner_ramvars]
        CALL    printstr
        MOV     AX, DS
        CALL    print_hex_word
        CALL    newline
        RET

%include "ramvar.asm"
%include "display.asm"
%include "page.asm"
%include "util.asm"
%include "int13.asm"
%include "handlers.asm"

section .data

title   DB      'FlashBios^'
	DB      'by Scott M Baker, http://www.smbaker.com/^$'
banner_pagereg:
        DB      'page register: $'
banner_frame:
        DB      ' frame seg: $'
banner_ramvars:
        DB      ' ramvars seg: $'
msg_int13_1:
        DB      'saved int13 handler: $'
msg_installed:
        DB      'int13 handler installed^$'
