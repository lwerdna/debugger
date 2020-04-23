; Demonstrate runtime information informing analysis.
;
; The switch statement has 4 legitimate cases and 4 secret cases.
; Analysis will statically find the 4 legitimate.
; Analysis will learn the other 4 while stepping through the table dispatch at runtime.

default rel

	global start
	section .text

start:
	; get pointer past switch constraint
	lea		rbx, [function_with_switch]
	mov		edi, 14
	call	mapper ; returns 7
	add		rbx, rax

	; call secret cases
	mov		rcx, 4
	call	rbx
	mov		rcx, 5 
	call	rbx
	mov		rcx, 6
	call	rbx
	mov		rcx, 7
	call	rbx

	; call legit cases
	mov		rdi, 0
	call	function_with_switch
	mov		rdi, 1
	call	function_with_switch
	mov		rdi, 2
	call	function_with_switch
	mov		rdi, 3
	call	function_with_switch

	; done
	mov		rax, 0x2000001 ; exit
	mov		rdi, 0
	syscall
	ret

function_with_switch:
	; 00000000: 0x48, 0x89, 0xf9
	mov		rcx, rdi				; arg0: 0,1,2,3
	; 00000003: 0x48, 0x83, 0xe1, 0x03
	and		rcx, 0x3
	; 00000007: <--- jumping here bypasses the constraint

	lea		rax, [.jump_table]
	movsx	rdx, dword[rax+rcx*4]
	add		rdx, rax
	jmp		rdx

.case0:
	add		rax, 0
	jmp		.switch_end

.case1:
	add		rax, 1
	jmp		.switch_end

.case2:
	add		rax, 2
	jmp		.switch_end

.case3:
	add		rax, 3
	jmp		.switch_end

.case4:
	add		rax, 4
	jmp		.switch_end

.case5:
	add		rax, 5
	jmp		.switch_end

.case6:
	add		rax, 6
	jmp		.switch_end

.case7:
	add		rax, 7
	jmp		.switch_end

.switch_end:
	ret

.jump_table:
	dd		function_with_switch.case0 - .jump_table
	dd		function_with_switch.case1 - .jump_table
	dd		function_with_switch.case2 - .jump_table
	dd		function_with_switch.case3 - .jump_table
	; these entries should be invisible/illegal to binja because of the "and 3" constraint
	dd		function_with_switch.case4 - .jump_table
	dd		function_with_switch.case5 - .jump_table
	dd		function_with_switch.case6 - .jump_table
	dd		function_with_switch.case7 - .jump_table

; evade data flow: return given number integer divided by 2
mapper:
	mov		rax, rdi
	shr		rax, 1
	ret
