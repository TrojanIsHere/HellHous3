;--------------------------
; Berfungsi untuk mendebug
; Windows XP dari jarak jauh
;--------------------------

NOPRN:
	MOV	[LSTFCB],AL
	MOV	[LSTDEV],AH	;Flag device for list ouput
	MOV	SI,EXTEND
	MOV	DI,FCB+9
	MOVW
	MOVB			;Set extension to ASM
	MOVW			;Zero extent field
	MOV	DX,FCB
	MOV	AH,OPEN
	INT	33
	MOV	BX,NOFILE
	OR	AL,AL
	JZ	$+5
	JMP	PRERR
	MOV	DX,HEXFCB
	CALL	MAKFIL
	MOV	DX,LSTFCB
	CALL	MAKFIL
	XOR	AX,AX
	MOV	[FCB+12],AX	;Zero CURRENT BLOCK field
	MOV	[FCB+32],AL	;Zero Next Record field
	MOV	[FCB+14],BUFSIZ	;Set record size
	MOV	[BUFPT],SRCBUF	;Initialize buffer pointer
	MOV	[CODE],START+1	;POINTER TO NEXT BYTE OF INTERMEDIATE CODE
	MOV	[IY],START	;POINTER TO CURRENT RELOCATION BYTE
	XOR	AX,AX
	MOV	[PC],AX		;DEFAULT PROGRAM COUNTER
	MOV	[BASE],AX	;POINTER TO ROOT OF ID TREE=NIL
	MOV	[RETPT],AX	;Pointer to last RET record
	MOV	[IFFLG],AL	;NOT WITHIN IF/ENDIF
	MOV	[CHKLAB],AL	;LOOKUP ALL LABELS
	DEC	AX
	MOV	[LSTRET],AX	;Location of last RET
	MOV	AX,[6]		;HL=END OF MEMORY
	MOV	[HEAP],AX	;BACK END OF SYMBOL TABLE SPACE
	MOV	[BCOUNT],4	;CODE BYTES PER RELOCATION BYTE

;Assemble each line of code

LOOP:
	CALL	NEXTCHR		;Get first character on line
	CMP	AL,1AH
	JZ	ENDJ
	MOV	AL,-1		;Flag that no tokens have been read yet
	MOV	[SYM],AL
	CALL	ASMLIN		;Assemble the line
	MOV	AL,[SYM]
	CMP	AL,-1		;Any tokens found on line?
	JNZ	L0002
	CALL	GETSYM		;If no tokens read yet, read first one
L0002:	
	CMP	AL,';'
	JZ	ENDLN
	CMP	AL,EOL
	JZ	ENDLN
	MOV	AL,14H		;Garbage at end of line error
	JP	ENDLIN
ENDJ:	JMP	END

ENDLN:
	XOR	AL,AL		;Flag no errors on line
ENDLIN:
;AL = error code for line. Stack depth unknown
	MOV	SP,STACK
	CALL	NEXLIN
	JP	LOOP

NEXLIN:
	MOV	CH,0C0H		;Put end of line marker and error code (AL)
	CALL	PUTCD
	CALL	GEN1
	MOV	AL,[CHR]
GETEOL:
	CMP	AL,10
	JZ	RET
	CMP	AL,1AH
	JZ	ENDJ
	CALL	NEXTCHR		;Scan over comments for linefeed
	JP	GETEOL

ABORT:
	MOV	BX,NOMEM
PRERR:
	MOV	DX,BX
	MOV	AH,PRINTMES
	INT	33
	INT	32

MAKFIL:
	MOV	SI,DX
	LODB			;Get drive select byte
	CMP	AL,20H		;If not valid, don't make file
	JNC	RET
	MOV	CX,4
	MOV	DI,SI
	MOV	SI,FCB+1
	REP
	MOVW			;Copy source file name
	MOV	AH,MAKE
	INT	33
	MOV	[DI-9+14],1	;Set record length to 1 byte
	MOV	BX,NOSPAC
	OR	AL,AL		;Success?
	JNZ	PRERR
	RET
