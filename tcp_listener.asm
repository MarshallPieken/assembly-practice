; this is for showing how I can make a basic tcp socket in assembly.
; steps:
;	1. Create socket rax 41
;	2. bind socket rax 49
; 	3. Listen for connections rax 50
;	4. Accept connections rax 43 
; 	5. Close client socket rax 3
;	6. Close server socket rax 3
; 	note There is no error checking for connections - this is quite vulnerable.
;
; IPv4 Addr is 16 chars max

section		.data
	sockaddr_in:	; 
		dw 2	; INET addr family
		dw 0x98FF ; port 65432 (in little endian)
		dd 0 	; 4-byte value for IP address	
	msg db 129 dup(0)	; buffer for client message in recv()

section		.bss
	socket_fd resq 1 ; resq = reserve quadqord (8 bytes/64 bits)
	client_fd resq 1 ; also reserved quadword

section		.text
	global	_start
_start:
; 1. Create socket
	mov	rax, 41
	mov	rdi, 2	; AF_INET
	mov 	rsi, 1	; SOCK_STREAM
	mov	rdx, 0	; DEFAULT TCP
			; can also xor rdx, rdx or other fancy shit if you want
	syscall
	mov 	[socket_fd], rax ; move the socket to socket_fd 

; 2. bind socket
	mov	rax, 49 ; syscall for bind
	mov	rdi, [socket_fd] ; move the socket to rdi
	lea	rsi, [sockaddr_in] ; pointer to sockaddr_in
	mov 	rdx, 16	;sockaddr_in size 
	syscall

; 3. listen for connections (sys_listen)
	mov	rax, 50	; man listen
	mov	rdi, [socket_fd] ; stdin file descriptor
	mov 	rsi, 10	; backlog
	syscall

; 4. accept connections
	mov	rax, 43 ; sys_accept (man accept)
	mov 	rdi, [socket_fd] ; file descriptor
	xor 	rsi, rsi ; set sockaddr to 0  
	xor	rdx, rdx ; sockaddr length (int)
	syscall
	mov 	[client_fd], rax ; 

; 5. Receive message (rax 45 AKA man recv)
	mov	rax, 45 ; recv
	mov	rdi, [client_fd] ; client file descriptor
	lea	rsi, [msg] ; buffer for message
	mov	rdx, 128 ; length can be up to 128 bytes
	syscall 
	; null terminate
	mov	rcx, rax ; copy # of bytes from rax to rcx
	mov	byte [msg + rcx], 0 ; write 0 at end of last byte of received data

; 6. Write to a file descriptor (man 2 write)
	mov	rax, 1 ; stdout syscall
	mov	rdi, 1 ; stdout	
	lea	rsi, [msg] ; pass msg address to rsi as the buffer
	mov 	rdx, rcx ; length of message (seee null terminate up there)
	syscall

; close sockets
	mov 	rax, 3 ; close syscall
	mov	rdi, [client_fd] ; client file descriptor
	syscall
	
	; our socket
	mov 	rax, 3 ; close it
	mov	rdi, [socket_fd]; our socket's file descriptor
	syscall
	
	; exit the program
	mov 	rax, 60 ; syscall for exit
	mov 	rdi, 0 ; no error
	syscall
