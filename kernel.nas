; Free-kernel
; TAB=4


[BITS 16]
[INSTRSET "i486p"]

		ORG		0xc200			; Ç±ÇÃÉvÉçÉOÉâÉÄÇ™Ç«Ç±Ç…ì«Ç›çûÇ‹ÇÍÇÈÇÃÇ©

		MOV		AX,0x0003
		INT		0x10

		MOV		SI,bootmsg
		CALL	puts
		
		MOV		SI,fontmsg
		CALL	puts
		CALL	msg_ok
		
		CALL	init_ivt
		MOV		SI,ivtmsg
		CALL	puts
		CALL	msg_ok
		
		MOV		SI,memmsg
		CALL	puts
		CALL	msg_ok
		MOV		SI,cr_lf
		CALL	puts
		
		MOV		SI,execmsg
		CALL	puts
		
		CALL	start_exec

fin:
		HLT
		JMP		fin

malloc:
		MOV		DI,memory_table
		MOV		BP,memory_table+4
search_loop:
		CMP		BYTE [BP],0
		JE		alloc
		ADD		BP,1
		JMP		search_loop
alloc:
		MOV		BYTE [BP],1
		SUB		BP,memory_table+4
		IMUL	BP,256
		MOV		DX,BP
		ADD		DX,[DI]
alloc_loop:
		SUB		AX,1
		ADD		BP,1
		CMP		AX,0
		JE		alloc_end
		MOV		BYTE [BP],1
		JMP		alloc_loop
alloc_end:
		RET

free:
		ADD		DX,memory_table+4
		MOV		BX,DX
		MOV		BYTE [BX],0
free_loop:
		SUB		AX,1
		ADD		BX,1
		CMP		AX,0
		JE		free_end
		MOV		BYTE [BX],0
		JMP		free_loop
free_end:
		RET

start_exec:
		MOV		BX,0x8000+0x2600
exec_find:
		MOV		DI,BX
		CALL	namecmp
		CMP		DX,0x01
		JE		exec_cpy
		ADD		BX,0x20
		CMP		BX,0xff00
		JE		exec_err
		JMP		exec_find
exec_cpy:
		ADD		BX,0x1a
		MOV		AX,[BX]
		IMUL	AX,512
		ADD		AX,0x3e00
		ADD		AX,0x8000
		MOV		DX,0x4500
		MOV		GS,DX
		MOV		SI,AX
		MOV		DI,0
		MOV		CX,0x1000
		CALL	memcpy
exec_jmp:
		MOV		AX,0x4500
		MOV		DS,AX
		MOV		ES,AX
		MOV		FS,AX
		MOV		GS,AX
		MOV		SS,AX
		JMP		0x4500:0x0000
exec_err:
		MOV		SI,execerrmsg
		CALL	puts
		JMP		fin

memcpy:
		MOV		AL,[SI]
		ADD		SI,1
		MOV		[GS:DI],AL
		ADD		DI,1
		SUB		CX,1
		JNZ		memcpy			; à¯Ç´éZÇµÇΩåãâ Ç™0Ç≈Ç»ÇØÇÍÇŒmemcpyÇ÷
		RET

namecmp:
cmp_1:
		CMP		DWORD [DI],'AUTO'
		JE		cmp_2
		MOV		DX,0x00
		RET
cmp_2:
		ADD		DI,4
		CMP		DWORD [DI],'EXEC'
		JE		cmp_3
		MOV		DX,0x00
		RET
cmp_3:
		ADD		DI,4
		CMP		DWORD [DI],'BIN '
		JE		cmp_end
		MOV		DX,0x00
		RET
cmp_end:
		MOV		DX,0x01
		RET

msg_ok:
		MOV		SI,okmsg
		CALL	puts_ok
		MOV		SI,msg_end
		CALL	puts
		RET

msg_ng:
		MOV		SI,ngmsg
		CALL	puts_ng
		MOV		SI,msg_end
		CALL	puts
		RET


puts_col:
		MOV		AX,DS
		MOV		ES,AX
		MOV		DI,SI
		XOR		CX,CX
		NOT		CX
		XOR		AL,AL
		CLD
		REPNE
		SCASB
		NOT		CX
		DEC		CX
		PUSH	CX
		
		MOV		AX,0x0300
		PUSH	BX
		MOV		BX,0x0000
		INT		0x10
		POP		BX
		
		POP		CX
		MOV		AX,0x1301
		MOV		BP,SI
		INT		0x10
		RET

puts:
		MOV		BX,0x0007
		CALL	puts_col
		RET

puts_ok:
		MOV		BX,0x0002
		CALL	puts_col
		RET

puts_ng:
		MOV		BX,0x0004
		CALL	puts_col
		RET

ret:
		RET

init_ivt:
		CLI
		MOV		AX,[int21h]
		MOV		[4*0x21],AX
		MOV		AX,[int21h+2]
		MOV		[4*0x21+2],AX
		STI
		RET
		

call_kernel_api:
		CALL	kernel_api
		IRET

;+----------------------+
;|     section  API     |
;+----------------------+

kernel_api:
		CMP		AH,0x00
		JE		api_getver
		
		CMP		AH,0x01
		JE		api_puts
		
		CMP		AH,0x02
		JE		api_putc
		
		CMP		AH,0x03
		JE		api_malloc
		
		CMP		AH,0x04
		JE		api_free
		
		CMP		AH,0x05
		JE		api_clear
		
		CMP		AH,0x06
		JE		api_getc
api_end:
		RET


api_getver:
		MOV		DX,100
		JMP		api_end

api_puts:
		CALL	puts_col
		JMP		api_end

api_putc:
		PUSHAD
		MOV		AH,0x0e
		MOV		BX,0x07
		INT		0x10
		POPAD
		JMP		api_end

api_malloc:
		CALL	malloc
		JMP		api_end

api_free:
		CALL	free
		JMP		api_end

api_clear:
		PUSHAW
		MOV		AX,0x0003
		INT		0x10
		POPAW
		JMP		api_end

api_getc:
		MOV		AH,0x00
		INT		0x16
		JMP		api_end

;+----------------------+
;|    end section API   |
;+----------------------+

bootmsg:
		DB		"FreeKernel 0.01 build 0004 build date:2014/10/03"
		DB		0x0d,0x0a
		DB		0x0d,0x0a
		DB		0x00

fontmsg:
		DB		"font init               ["
		DB		0x00

ivtmsg:
		DB		"ivt init                ["
		DB		0x00


memmsg:
		DB		"memory_table init       ["
		DB		0x00

okmsg:
		DB		" OK "
		DB		0x00

ngmsg:
		DB		" NG "
		DB		0x00

msg_end:
		DB		"]"
		DB		0x0d,0x0a
		DB		0x00

cr_lf:
		DB		0x0d,0x0a
		DB		0x00

execmsg:
		DB		"exec file : AUTOEXEC.BIN"
		DB		0x0d,0x0a
		DB		"starting AUTOEXEC.BIN..."
		DB		0x0d,0x0a
		DB		0x00

execerrmsg:
		DB		"fatal : AUTOEXEC.BIN not found"
		DB		0x0d,0x0a
		DB		0x00

memory_table:
		DW		0x4600
		DW		0x0000
		RESB	0xba

keyboard_buf:
		DB		0x00

keyboard_mode:
		DB		0x00		;L shift
		DB		0x00		;R shift
		DB		0x00		;capslock
		DB		0x00		;numlock

int21h:
		DW		call_kernel_api
		DW		0x0000
