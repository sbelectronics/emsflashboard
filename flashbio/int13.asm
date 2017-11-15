install_int13_handler:
        ;; assumes RAMVARS segment is in DS
        PUSH    SI
        MOV     SI, int13_handler
        MOV     [RAMVARS.int13_old], SI
        MOV     [RAMVARS.int13_old+2], CS
        POP     SI
        JMP     exchange_int13_handler

exchange_int13_handler:
        ;; assumes RAMVARS segment is in DS
        PUSH    ES
        PUSH    SI
        CALL    find_ramvars
        XOR     SI, SI
        MOV     ES, SI
        MOV     SI, [RAMVARS.int13_old]
        CLI
        XCHG    SI, [ES:13h*4]
        MOV     [RAMVARS.int13_old], SI
        MOV     SI, [RAMVARS.int13_old+2]
        XCHG    SI, [ES:13h*4+2]
        STI
        MOV     [RAMVARS.int13_old+2], SI
        POP     SI
        POP     ES
        RET

int13_handler:
        PUSH    DS
        CALL    find_ramvars
        CMP     DL, [CS:drive_num]
        JE      .ourdrive
        CALL    exchange_int13_handler
        INT     13h
        CALL    exchange_int13_handler
        POP     DS
        IRET
.ourdrive:
        PUSH    BX
        XOR     BX, BX
        MOV     BL, AH
        SHL     BX, 1
        CMP     AH, 25h
        JA      unsupported_function
        JMP     [cs:bx+int13_jumptable]

unsupported_function:
        MOV     AH, 01h
        JMP     int13_error_return

int13_error_return:
        POP     BX
        POP     DS
        STC                       ; set carry
        IRET

int13_success_return:
        POP     BX
        POP     DS
        CLC                       ; clear carry
        IRET

int13_success_return_bx:
        POP     DS                ; get BX off the stack; we'll overwrite DX in a moment
        POP     DS
        CLC                       ; clear carry
        IRET

int13_jumptable:
        dw      AH0h_HandlerForDiskControllerReset                      ; 00h, Disk Controller Reset (All)
        dw      AH1h_HandlerForReadDiskStatus                           ; 01h, Read Disk Status (All)
        dw      AH2h_HandlerForReadDiskSectors                          ; 02h, Read Disk Sectors (All)
        dw      AH3h_HandlerForWriteDiskSectors                         ; 03h, Write Disk Sectors (All)
        dw      AH4h_HandlerForVerifyDiskSectors                        ; 04h, Verify Disk Sectors (All)
        dw      unsupported_function                                                     ; 05h, Format Disk Track (XT, AT, EISA)
        dw      unsupported_function                                                     ; 06h, Format Disk Track with Bad Sectors (XT)
        dw      unsupported_function                                                     ; 07h, Format Multiple Cylinders (XT)
        dw      AH8h_HandlerForReadDiskDriveParameters                                  ; 08h, Read Disk Drive Parameters (All)
        dw      AH9h_HandlerForInitializeDriveParameters                                ; 09h, Initialize Drive Parameters (All)
        dw      unsupported_function                                                     ; 0Ah, Read Disk Sectors with ECC (XT, AT, EISA)
        dw      unsupported_function                                                     ; 0Bh, Write Disk Sectors with ECC (XT, AT, EISA)
        dw      AHCh_HandlerForSeek                                                     ; 0Ch, Seek (All)
        dw      AH9h_HandlerForInitializeDriveParameters                                ; 0Dh, Alternate Disk Reset (All)
        dw      unsupported_function                                                     ; 0Eh, Read Sector Buffer (XT, PS/1), ESDI Undocumented Diagnostic (PS/2)
        dw      unsupported_function                                                     ; 0Fh, Write Sector Buffer (XT, PS/1), ESDI Undocumented Diagnostic (PS/2)
        dw      AH10h_HandlerForCheckDriveReady                                         ; 10h, Check Drive Ready (All)
        dw      AH11h_HandlerForRecalibrate                                             ; 11h, Recalibrate (All)
        dw      unsupported_function                                                     ; 12h, Controller RAM Diagnostic (XT)
        dw      unsupported_function                                                     ; 13h, Drive Diagnostic (XT)
        dw      unsupported_function                                                     ; 14h, Controller Internal Diagnostic (All)
        dw      AH15h_HandlerForReadDiskDriveSize                                       ; 15h, Read Disk Drive Size (AT+)
        dw      unsupported_function                                                     ; 16h,
        dw      unsupported_function                                                     ; 17h,
        dw      unsupported_function                                                     ; 18h,
        dw      unsupported_function                                                     ; 19h, Park Heads (PS/2)
        dw      unsupported_function                                                     ; 1Ah, Format ESDI Drive (PS/2)
        dw      unsupported_function                                                     ; 1Bh, Get ESDI Manufacturing Header (PS/2)
        dw      unsupported_function                                                     ; 1Ch, ESDI Special Functions (PS/2)
        dw      unsupported_function                                                     ; 1Dh,
        dw      unsupported_function                                                     ; 1Eh,
        dw      unsupported_function                                                     ; 1Fh,
        dw      unsupported_function                                                     ; 20h,
        dw      unsupported_function                                                     ; 21h, Read Disk Sectors, Multiple Blocks (PS/1)
        dw      unsupported_function                                                     ; 22h, Write Disk Sectors, Multiple Blocks (PS/1)
        dw      AH23h_HandlerForSetControllerFeatures                                   ; 23h, Set Controller Features Register (PS/1)
        dw      AH24h_HandlerForSetMultipleBlocks                                       ; 24h, Set Multiple Blocks (PS/1)
        dw      AH25h_HandlerForGetDriveInformation                                     ; 25h, Get Drive Information (PS/1)




