; this is for demonstrating macro, I learn macro ok. and also apparently conversion and stuff
;
; a macro is defined as a single instruction which expands into a set of predefined set of instructions to perform a particular task.
;
;Macro Structure (at least in NASM)
;------------------------------------
;%macro <name> <argc>
;    ...
;    <macro body/definition>
;    ...
;%endmacro
;------------------------------------
; argc = amt of inputs/arguments which the macro takes (think in C)
; "%1" means first input, "%2" means second input...
; if you use a label within a macro, make sure to use TWO percent signs to designate it, e.g., %%loop.
; EQU is also used for defining constans for future use.
;
; Let's implement some (multi-argument) macros and some constants.
;===================================================================================================================================

;------------------------------------------------
; divideDigit macro; takes 2 arguments, outputs 1.
;------------------------------------------------
%macro divideDigit 2
	mov rax, %1
	cmp qword %2, 0		; check if dividing by 0
	je %%undefined		; handle rax/0 gracefully in %%undefined label

	xor rdx, rdx		; zero out rdx since div works on RDX:RAX, operand 
	div qword  %2 		; RAX = RDX:RAX / %2, RDX = remainder.
	mov [result], rax	; store the result		

	jmp %%done		; finished: skip error block
	
%%undefined: 			; prints out dividing by 0 error message
	mov rax, 1
	mov rdi, 1
	mov rsi, undef_error
	mov rdx, 22
	syscall
	exit			; skip to end of program
%%done:				; skip to end of macro
%endmacro

;--------------------------------
; exit macro; takes no arguments.
;--------------------------------
%macro exit 0		; exit macro (0 inputs)
	mov rax, 60
	xor rdi, rdi
	syscall
%endmacro		; end exit macro

;--------------------------------
section .data
prompt		db "please enter your number followed by what you want it divided by. ",10 ; user input prompt
num1_prompt	db "enter your numerator: " 
num2_prompt	db "enter your denominator: "

undef_error 	db "Error: Dividing by 0!",10	; undefined error msg
result_text	db "your result is "		; result msg	

;--------------------------------------------------------
section .bss
numerator 	resq 1 	; number to divide
denominator 	resq 1 	; that which divides the other number
result		resq 1	; the dividend to be output to user
itoa_result	resb 20	; result of int-to-ascii
;----------------------------------
section .text
global _start

_start:
	call _print_prompt
	
	call _num1_prompt
	call _numerator_in
	call _ascii_to_digit
	mov [numerator], rax
	
	call _num2_prompt
	call _denominator_in	
	call _ascii_to_digit
	mov [denominator], rax

	divideDigit [numerator], [denominator]
	
	call _print_result_text
	call _digit_to_ascii
	call _print_result
	exit

_num1_prompt:
        mov rax, 1
        mov rdi, 1
        mov rsi, num1_prompt
        mov rdx, 22 
        syscall
        ret

_num2_prompt:
        mov rax, 1
        mov rdi, 1
        mov rsi, num2_prompt
        mov rdx, 24
        syscall
        ret

_print_prompt:
	mov rax, 1
	mov rdi, 1
	mov rsi, prompt 
	mov rdx, 66
	syscall
	ret

_numerator_in:
	mov rax, 0
	mov rdi, 0	
	mov rsi, numerator
	mov rdx, 16
	syscall
	ret

_denominator_in:
        mov rax, 0
        mov rdi, 0
        mov rsi, denominator
       	mov rdx, 16
	syscall
	ret

_print_result_text:
	mov rax, 1
	mov rdi, 1
	mov rsi, result_text
	mov rdx, 15
	syscall
	ret

_print_result:
	mov rax, 1
	mov rdi, 1
	mov rsi, itoa_result
	; rdx already holds the length
	syscall
	ret

; (atoi routine): converts the user's ASCII input into digits to be divided.
_ascii_to_digit:
	xor rax, rax	;reset rax
.loop:
	movzx	rcx, byte [rsi]	; rsi i- source pointer for string/memory manipulation
	cmp	rcx, '0'	; error checks: rcx<0 and rcx>9 for each digit
	jb	.done	
	cmp	rcx, '9'
	ja	.done
	
	sub	rcx, '0'	; convert char to value 0-9
	imul 	rax, rax, 10	; total *= 10
	add 	rax, rcx	; total += new digit
	inc	rsi		; advance to next character
	jmp 	.loop		; perform loop on next character
.done:		
	ret


; (itoa): converts the digit result to ASCII for user output.
; this turned out to be a pain in the ass because it was basically one giant learning curve for me. 
; I say that as if assewmbly isn't one giant learning curve
_digit_to_ascii:
	mov	eax, [result]	; load the number to convert into eax
	mov	ebx, 10
	xor	rcx, rcx	; flush counter register

.loop:				; here we need to reverse the conversions from atoi, above.
	xor	edx, edx	; flush edx for the next char 
	div	ebx	   	; divides EDX:EAX by EBX
	
	add	dl, '0'		; give it an ASCII digit
	push 	rdx		; stach char (comes out reversed)
	inc 	rcx		; increment counter	
	test	eax, eax 	; is quotient zero?
	jnz	.loop		; if not, loop

	lea	rsi, [itoa_result]	; destination buffer
	mov	rdx, rcx	; save count to return as length
.rebuild:
	pop	rax		; digits pop off in correct order
	mov 	[rsi], al	; store th char byte
	inc	rsi		; increment counter
	loop	.rebuild	; dec rcx to loop until 0
	ret
