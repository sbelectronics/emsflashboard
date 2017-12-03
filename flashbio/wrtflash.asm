;; wrtflash.asm
;; Scott M Baker, http://www.smbaker.com/
;;
;; Code for writing to flash.
;;
;;  * * * UNTESTED * * *

;; write_flash
;;    DS:SI = source data
;;    AL    = page number
;;    DI    = dest offset within page
;;    CX    = byte count
;; destroys:
;;    AX, BX, CX, DX, SI, ES, DI

write_flash:
        MOV     BX, [CS:page_frame_seg]
        MOV     ES, BX                 ; ES = page frame dest segment

        MOV     DX, [CS:page_reg]
        INC     DX                     ; DX = port number of page 1 reg

        ADD     DI, 4000h              ; bank 1 is at 4000

.NEXT_BYTE:
        MOV     AH, AL                 ; save AL into AH
        AND     AL, 0E0h               ; mask off the lower 5 bits

        INC     AL
        OUT     DX, AL
        MOV     [ES:5555h], byte 0AAh  ; bank1+5555 = AA

        DEC     AL
        OUT     DX, AL
        MOV     [ES:6AAAh], byte 055h  ; bank1+2AAA = 55

        INC     AL
        OUT     DX, AL
        MOV     [ES:5555h], byte 0A0h  ; bank1+5555 = A0

        MOV     AL, AH                 ; restore AL from AH
        OUT     DX, AL                 ; set desired page number

        MOVSB                          ; move byte in [DS:SI] to [ES:DI]

        ;; Wait for the write operation to complete. The chip will toggle the
        ;; sixth bit during reads while the operation is in progress. If we
        ;; read an address twice and the sixth bit is the same, then we know
        ;; we are complete.

        MOV     BL, [ES:4000h]
        AND     BL, 40h
.WAIT:
        CMP     BH, [ES:4000h]
        AND     BH, 40h
        XCHG    BL, BH
        CMP     BL, BH
        JNE     .WAIT

        DEC     CX
        JNZ     .NEXT_BYTE

        RET

;; erase_flash_sector
;;    AL    = page number
;;    DI    = dest offset within page (lower 12 bits ignored)
;; destroys:
;;    AX, BX, DX, ES

erase_flash_sector:
        MOV     BX, [CS:page_frame_seg]
        MOV     ES, BX                 ; ES = page frame dest segment

        MOV     DX, [CS:page_reg]
        INC     DX                     ; DX = port number of page 1 reg

        ADD     DI, 4000h              ; bank 1 is at 4000

        MOV     AH, AL                 ; save AL into AH
        AND     AL, 0E0h               ; mask off the lower 5 bits

        INC     AL
        OUT     DX, AL
        MOV     [ES:5555h], byte 0AAh  ; bank1+5555 = AA

        DEC     AL
        OUT     DX, AL
        MOV     [ES:6AAAh], byte 055h  ; bank1+2AAA = 55

        INC     AL
        OUT     DX, AL
        MOV     [ES:5555h], byte 080h  ; bank1+5555 = 80

        OUT     DX, AL
        MOV     [ES:5555h], byte 0AAh  ; bank1+5555 = AA

        DEC     AL
        OUT     DX, AL
        MOV     [ES:6AAAh], byte 055h  ; bank1+2AAA = 55

        MOV     AL, AH                 ; restore AL from AH
        OUT     DX, AL                 ; set desired page number

        MOV     [ES:DI], byte 30h      ; bank1+secaddr = 30

        ;; Wait for the write operation to complete. The chip will toggle the
        ;; sixth bit during reads while the operation is in progress. If we
        ;; read an address twice and the sixth bit is the same, then we know
        ;; we are complete.

        MOV     BL, [ES:4000h]
        AND     BL, 40h
.WAIT:
        CMP     BH, [ES:4000h]
        AND     BH, 40h
        XCHG    BL, BH
        CMP     BL, BH
        JNE     .WAIT

        SUB     DI, 4000h              ; restore DI

        RET

