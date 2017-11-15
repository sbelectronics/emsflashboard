set_page1:
	;; set page register to value in AL
	
	PUSH	DX
	MOV	DX, [CS:page_reg]
        INC     DX
	OUT	DX, AL
	POP	DX
	RET

enable_page:
	;; enable page register
	
	PUSH    AX
	PUSH	DX
	MOV	DX, [CS:page_enable]
	MOV     AL, 1
	OUT	DX, AL
	POP     DX
	POP	AX
	RET
