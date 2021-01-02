#include <Windows.h>
#include <string>

#include "ibase.h"

#pragma comment(lib, "fbclient_ms.lib")

const std::string server_and_path = "d:\\DATABASE.FDB";
const std::string process = "C:\\Windows\\System32\\calc.exe";
const unsigned StatusLen = 20;

void connect1()
{
	isc_db_handle db_handle = nullptr;
	ISC_STATUS status_vect[StatusLen] = {};
	char pdb[1] = { isc_dpb_version1 };

	// connect 
	isc_attach_database(
		status_vect,
		server_and_path.size(),
		server_and_path.c_str(),
		&db_handle,
		sizeof(pdb),
		pdb
	);

	// start process

	STARTUPINFOA si = {};
	si.cb = sizeof(si);
	PROCESS_INFORMATION pi = {};
	int res = CreateProcessA(
		process.c_str(),  // lpApplicationName
		NULL,             // lpCommandLine
		NULL,             // lpProcessAttributes
		NULL,             // lpThreadAttributes
		TRUE,             // bInheritHandles
		DETACHED_PROCESS, // dwCreationFlags
		NULL,             // lpEnvironment
		NULL,             // lpCurrentDirectory
		&si,              // lpStartupInfo
		&pi               // lpProcessInformation
	);

	// disconnect
	isc_detach_database(status_vect, &db_handle);
}


void connect2()
{
	isc_db_handle db_handle = nullptr;
	char pdb[1] = { isc_dpb_version1 };

	ISC_STATUS status_vect[StatusLen] = {};

	// connect
	isc_attach_database( // <- HANGS HERE
		status_vect,
		server_and_path.size(),
		server_and_path.c_str(),
		&db_handle,
		sizeof(pdb),
		pdb
	);

	isc_detach_database(status_vect, &db_handle);
}


int main(int argc, char* argv[])
{
	connect1();
	connect2();
	return 0;
}
