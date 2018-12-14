;-- ZONA NYAMAN BERADA W. TROJAN --

MOV	AH,AL		;Flag is kept in AH
	MOV	[UNDEF],0
	MOV	AL,[SYM]
	CALL	EXPRESSION
	MOV	[CON],DX
	MOV	AL,AH
	MOV	CH,0		;Initial mode
	TEST	AL,10H		;Test INDEX bit
	RCL	AL		;BASE bit (zero flag not affected)
	JZ	NOIND		;Jump if not indexed, with BASE bit in carry
	CMC
	RCL	CH		;Rotate in BASE bit
	RCL	AL		;BP bit
	RCL	CH
	RCL	AL		;DI bit
	RCL	CH		;The low 3 bits now have indexing mode
MODE:
	OR	CH,080H		;If undefined label, force 16-bit displacement
	TEST	[UNDEF],-1
	JNZ	RET
	MOV	BX,[CON]
	MOV	AL,BL
	CBW			;Extend sign
	CMP	AX,BX		;Is it a signed 8-bit number?
	JNZ	RET		;If not, use 16-bit displacement
	AND	CH,07FH		;Reset 16-bit displacement
	OR	CH,040H		;Set 8-bit displacement
	OR	BX,BX
	JNZ	RET		;Use it if not zero displacement
	AND	CH,7		;Specify no displacement
	CMP	CH,6		;Check for BP+0 addressing mode
	JNZ	RET
	OR	CH,040H		;If BP+0, use 8-bit displacement
	RET

NOIND:
	MOV	CH,6		;Try direct address mode
	JNC	RET		;If no base register, that's right
	RCL	AL		;Check BP bit
	JC	MODE
	INC	CH		;If not, must be BX
	JP	MODE

EXPRESSION:
;Analyze arbitrary expression. Flag byte in AH.
;On exit, AL has type byte: 0=register or undefined label
	MOV	CH,-1		;Initial type
	MOV	DI,DX
	XOR	DX,DX		;Initial value
	CMP	AL,'+'
	JZ	PLSMNS
	CMP	AL,'-'
	JZ	PLSMNS
	MOV	CL,'+'
	PUSH	DX
	PUSH	CX
	MOV	DX,DI
	JP	OPERATE
PLSMNS:
	MOV	CL,AL
	PUSH	DX
	PUSH	CX
	OR	AH,4		;Flag that a sign was found
	CALL	GETSYM
OPERATE:
	CALL	TERM
	POP	CX		;Recover operator
	POP	BX		;Recover current value
	XCHG	DX,BX
	AND	CH,AL
	OR	AL,AL		;Is it register or undefined label?
	JZ	NOCON		;If so, then no constant part
	CMP	CL,"-"		;Subtract it?
	JNZ	ADD
	NEG	BX
ADD:
	ADD	DX,BX
NEXTERM:
	MOV	AL,[SYM]
	CMP	AL,'+'
	JZ	PLSMNS
	CMP	AL,'-'
	JZ	PLSMNS
	MOV	AL,CH
	RET
NOCON:
	CMP	CL,"-"
	JNZ	NEXTERM
BADOP:
	MOV	CL,5
	JMP	ERROR

TERM:
	CALL	FACTOR
MULOP:
	PUSH	DX		;Save value
	PUSH	AX		;Save type
	CALL	GETSYM
	POP	CX
	CMP	AL,"*"
	JZ	GETFACT
	CMP	AL,"/"
	JNZ	ENDTERM
GETFACT:
	OR	CL,CL		;Can we operate on this type?
	JZ	BADOP
	PUSH	AX		;Save operator
	CALL	GETSYM		;Get past operator
	CALL	FACTOR
	OR	AL,AL
	JZ	BADOP
	POP	CX		;Recover operator
	POP	BP		;And current value
	XCHG	AX,BP		;Save AH in BP
	CMP	CL,"/"		;Do we divide?
	JNZ	DOMUL
	OR	DX,DX		;Dividing by zero?
	MOV	CL,29H
	JZ	ERR2
	MOV	BX,DX
	XOR	DX,DX		;Make 32-bit dividend
	DIV	AX,BX
	JMPS	NEXFACT
DOMUL:
	MUL	AX,DX
NEXFACT:
	MOV	DX,AX		;Result in DX
	XCHG	AX,BP		;Restore flags to AH
	MOV	AL,-1		;Indicate a number
	JMPS	MULOP
ENDTERM:
	POP	DX
	MOV	AL,CL
	RET

FACTOR:
	MOV	AL,[SYM]
	CMP	AL,CONST
	JZ	RET
	CMP	AL,UNDEFID
	JZ	UVAL
	CMP	AL,"("
	JZ	PAREN
	CMP	AL,'"'
	JZ	STRING
	CMP	AL,"'"
	JZ	STRING
	CMP	AL,XREG		;Only 16-bit register may index
	MOV	CL,20
	JNZ	ERR2
	TEST	AH,1		;Check to see if indexing is OK
	MOV	CL,1
	JZ	ERR2
	MOV	AL,DL
	MOV	CL,3
	SUB	AL,3		;Check for BX
	JZ	BXJ
	SUB	AL,2		;Check for BP
	JZ	BPJ
	DEC	AL		;Check for SI
	MOV	CL,4
	JZ	SIJ
	DEC	AL		;Check for DI
	JZ	DIJ
	MOV	CL,2		;Invalid base/index register
ERR2:	JMP	ERROR

DIJ:
	OR	AH,20H		;Flag seeing index register DI
SIJ:
	TEST	AH,10H		;Check if already seen index register
	JNZ	


;--------------------------------
; berfungsi untuk scan port port
; terbuka pada windows XP
;--------------------------------
