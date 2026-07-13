;learned mainly from horaskis' x86_64 Linux Assembly Series on youtube.
;https://www.youtube.com/playlist?list=PLetF-YjXm-sCH6FrTz4AQhfH6INDQvQSn
;
; The purpose of this program is to practice calling subroutines in an asm program for I/O.
;
; Program flow:
; 	Print "what is your name?"
; 	User inserts input
; 	Prints "Hello, {name}"
; Feel free to figure out how to execute arbitrary code with this program.

	section .data
	text1 	db "What is your name? ", 10	; prompt
	text2	db "Hello, "			; response from machine

	section .bss				; undefined data
	name	resb 16				; resb= reserve (16) bytes.

	section .text
; basically the main function
_start:
	call _printText1
	call _getName
	call _printText2
	call _printName
	call _exit

; Prompt the user for their name
_printText1: 
	mov rax, 1
	mov rdi, 1
	mov rsi, text1
	mov rdx, 20
	syscall
	ret

; print the "Hello, " portion before the user's stored name
_printText2:
	mov rax, 1
	mov rdi, 1
	mov rsi, text2
	mov rdx, 7
	syscall
	ret

; receive the user's name
_getName:
	mov rax, 0 	;input ID is 0
	mov rdi, 0	; rdi is 0 (input), 1 (output), or 2 (error)
	mov rsi, name
	syscall
	ret

;print the stored user's name
_printName:
	mov rax, 1
	mov rdi, 1
	mov rsi, name
	mov rdx, 16	;allocate 16 bytes for the name input
			; eventually use jo for jumping if overflow to error message
	syscall
	ret

; gracegully exit the program
_exit:
	mov rax, 60 ; exit
	mov rdi, 0
	syscall
