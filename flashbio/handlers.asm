AH0h_HandlerForDiskControllerReset:
        MOV     AH, 0h
	JMP	int13_success_return

AH1h_HandlerForReadDiskStatus:
        MOV     AH, 0h
        JMP     int13_success_return

AH2h_HandlerForReadDiskSectors:
        POP     BX                     ; restore BX which was lost in the jump
        PUSH    BX

        PUSH    AX
        PUSH    CX
        PUSH    DX
        PUSH    SI
        PUSH    DI

        MOV     DI, BX                 ; ES:DI = destination

        PUSH    AX
        CALL    chs_to_blk             ; DX = block number, AX/BX/CX=wrecked
        POP     AX

        MOV     BX, [CS:page_frame_seg]
        MOV     DS, BX                 ; DS = page frame source segment

        MOV     BH, 0
        MOV     BL, AL                 ; BX = number of sectors to transfer

.next_sector:
        CALL    blk_to_page            ; AX = page, SI = offset, CX=wrecked
        INC     AL                     ; inc page number because page0 = BIOS ext
        CALL    set_page1

        ADD     SI, 0x4000             ; DS:SI = source; use window 1

        CLD                            ; clear direction flag
        MOV     CX, 0200h              ; copy 512 bytes
        REP     MOVSB

        INC     DX                     ; increment block count
        DEC     BX                     ; decrement blocks remaining
        JNZ     .next_sector

        POP     DI
        POP     SI
        POP     DX
        POP     CX
        POP     AX

        MOV     AH, 0h
        JMP     int13_success_return

AH3h_HandlerForWriteDiskSectors:
        MOV     AH, 3h                 ; write protected
        JMP     int13_error_return

AH4h_HandlerForVerifyDiskSectors:
        MOV     AH, 0h
        JMP     int13_success_return

AH8h_HandlerForReadDiskDriveParameters:
        MOV     AH, 0h
        MOV     AL, 0h
        MOV     BL, [CS:floppy_type]
        MOV     CH, [CS:num_cyl]
        DEC     CH                     ; number of cyls - 1
        MOV     CL, [CS:num_sec]
        MOV     DH, [CS:num_head]
        DEC     DH                     ; number of heads - 1
        MOV     DL, 1h
        PUSH    CS                     ; ES:DI = dpt
        POP     ES
        MOV     DI, [dpt]
        JMP     int13_success_return_bx

AH9h_HandlerForInitializeDriveParameters:
        MOV     AH, 0h
        JMP     int13_success_return

AHCh_HandlerForSeek:
        MOV     AH, 0h
        JMP     int13_success_return

AH10h_HandlerForCheckDriveReady:
        MOV     AH, 0h
        JMP     int13_success_return

AH11h_HandlerForRecalibrate:
        MOV     AH, 0h
        JMP     int13_success_return

AH15h_HandlerForReadDiskDriveSize:
        MOV     AH, 0
        MOV     AL, [CS:num_sec]
        MOV     CH, 0
        MOV     CL, [CS:num_head]
        MUL     CX                     ; AX = sec * head
        MOV     CH, 0
        MOV     CL, [CS:num_cyl]
        MUL     CX                     ; DX:AX = cyl * sec * head

        MOV     CX, DX
        MOV     DX, AX                 ; CX:DX = num of sectors

        MOV     AL, 0
        MOV     AH, [CS:drive_type]
        JMP     int13_success_return

AH23h_HandlerForSetControllerFeatures:
        MOV     AH, 1h
        JMP     int13_error_return

AH24h_HandlerForSetMultipleBlocks:
        MOV     AH, 1h
        JMP     int13_error_return

AH25h_HandlerForGetDriveInformation:
        MOV     AH, 1h
        JMP     int13_error_return

chs_to_blk:
        ;; input:
        ;;   CH = track number
        ;;   CL = sector number
        ;;   DH = head number
        ;; output:
        ;;   DX = block number
        ;; destroys:
        ;;   AX, BX, CX
        MOV     BX, CX                 ; BH=c, BL=s
        MOV     AH, 0
        MOV     AL, [CS:num_head]      ; AX = nHeads
        MOV     CH, 0
        MOV     CL, BH                 ; CX = c
        MOV     BH, DH                 ; BH = h
        MUL     CX                     ; AX = (c * nHeads), DX=0
        MOV     DL, BH
        MOV     DH, 0                  ; DX = h
        ADD     AX, DX                 ; AX = (c * nHeads + h)
        MOV     CH, 0
        MOV     CL, [CS:num_sec]
        MUL     CX                     ; AX = (c * nHeads + h) * nSectors
        MOV     BH, 0
        DEC     BL                     ; BL = (s-1)
        ADD     AX, BX                 ; AX = (c * nHeads + h) * nSectors + (s-1)
        MOV     DX, AX
        RET

blk_to_page:
        ;; input
        ;;   DX = block number
        ;; output
        ;;   AX = bank number
        ;;   SI = offset
        ;; destroys
        ;;   CX
        MOV     AX, DX
        SHR     AX, 5                  ; divide by 32 sectors per bank
        MOV     CX, DX
        AND     CX, 0xFFE0             ; CX = bank * 32
        MOV     SI, DX
        SUB     SI, CX                 ; SI = block number within bank
        SHL     SI, 9                  ; SI = byte offset within bank
        RET


