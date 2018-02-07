; Free-kernel sample
; TAB=4

[BITS 16]
[INSTRSET "i486p"]

		ORG		0x0000

		;MOV		AH,0x05		;INT 0x21 ah=0x05:clear screen
		;INT		0x21
		
		MOV		AH,0x01		;INT 0x21 ah=0x01,si=string addres:put string
		MOV		BX,0x0003
		MOV		SI,exanple
		INT		0x21
		;MOV		BX,0x0000
		;MOV		AH,0x00
		;MOV		AL,0x11
		;INT		0x10
		;MOV		AX,0xa000
		;MOV		DS,AX
		;MOV		BX,0x0000

loop:
		;MOV		AH,0x06		;INT 0x21 ah=0x06:get key
		;INT		0x21
		;MOV		AH,0x02		;INT 0x21 ah=0x02:put char
		;INT		0x21
		;MOV		BX,0x0003
		HLT
		;MOV		AH,0x01		;INT 0x21 ah=0x01,si=string addres:put string
		;ADD		BX,0x01
		;AND		BX,0x0f
		;MOV		SI,exanple
		;INT		0x21
		;MOV		[DS:BX],BYTE 0xcc
		;ADD		BX,0x0001
		JMP		loop

exanple:
		DB		"16color test"
		DB		0x0d,0x0a
