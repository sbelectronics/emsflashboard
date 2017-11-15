retdos:
        MOV     ah, 04Ch
        MOV     al, 0
        int     21h

tsr:
        mov     ah, 31h
        mov     al, 0
        mov     dx, 200h ; reserve 8k
        int     21h
