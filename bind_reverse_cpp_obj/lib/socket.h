
#ifndef SOCKET_OBJ
#define SOCKET_OBJ

#include "windows.h"
#include "winsock2.h"

class Socket{
	
	private:
		SOCKET sock = NULL;
		SOCKADDR_IN * sin;
	
	public:
		int Errorno = 0;
		
		Socket( SOCKET sock );
		Socket( SOCKADDR_IN * sin );
		
		bool valid( );
		SOCKET get();
		int Bind( );
		int Listen( int nbUsers );
		int Connect( );
		Socket * Accept( SOCKADDR_IN * sin );
		void Close( );
		void Clean( );

	
};

SOCKET Socket::get( ){
return this->sock;
}

Socket::Socket( SOCKET sin ){
	this->sock = sock; 
}
Socket::Socket( SOCKADDR_IN * sin ){
	
	WSAData wsa;
	
	this->sin = sin;
	
	memset(&wsa, 0, sizeof(wsa));
	if( WSAStartup( (WORD)0x0202, &wsa ) != 0 )
	this->Errorno = WSAGetLastError();;
	 
	if( (this->sock= WSASocket( 
		this->sin->sin_family, 
		1, 6,
		NULL, (unsigned int )NULL, (unsigned int )NULL
	 ) ) == INVALID_SOCKET )
	 this->Errorno = WSAGetLastError();
	 
	
}

int Socket::Bind( ){
return bind(
	this->sock,
	( SOCKADDR * )this->sin,
	sizeof( SOCKADDR_IN ) 
	);
}
int Socket::Listen( int nbUser ){
return listen( this->sock, nbUser );
}

int Socket::Connect(){
return connect( this->sock, ( SOCKADDR *)this->sin, sizeof(SOCKADDR_IN)  );
}

Socket * Socket::Accept( SOCKADDR_IN * sin ){
	SOCKET sok;
	sock =accept( this->sock, NULL, NULL ) ;
return new Socket( sock );	
}

bool Socket::valid( ){
return this->sock == NULL || this->sock != INVALID_SOCKET;
}
void Socket::Clean( ){
	WSACleanup();
}
void Socket::Close(){
	
	if( this->valid() ){
	
		closesocket(
			this->sock
		);
		WSACleanup();
	}
	
}

#endif
