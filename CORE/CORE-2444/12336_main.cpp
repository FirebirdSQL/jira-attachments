#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include <process.h>
#include "..\jrd\ibase.h"

void check(const ISC_STATUS *status)
{
	if (status[1] == 0)
		return;

	char msg[256];
	while (fb_interpret(msg, sizeof(msg), &status))
		printf("\n%s", msg);

	abort();
}

const int NUM_THREADS = 16;
volatile long thd_num = 0;
volatile long thd_cnt = 0;

const char* USER = "SYSDBA";
const char* PWD = "masterkey";

//#define ONE_DB
#ifdef ONE_DB
char fileName[255];
#endif

void event_callback(void*, ISC_USHORT, const ISC_UCHAR*)
{
}

RTL_CRITICAL_SECTION attach_mtx;

unsigned int WINAPI worker(void*)
{
	const int num = InterlockedIncrement(&thd_num);
	InterlockedIncrement(&thd_cnt);
	
#ifndef ONE_DB
	char fileName[255];
	sprintf(fileName, "events_%d.fdb", num);
	DeleteFile(fileName);
#endif

	ISC_STATUS_ARRAY status = {0};

	EnterCriticalSection(&attach_mtx);
	isc_db_handle hDB = NULL;

#ifdef ONE_DB
	if (isc_attach_database(status, strlen(fileName), fileName, &hDB, 0, NULL))
#else
	if (isc_create_database(status, strlen(fileName), fileName, &hDB, 0, NULL, 0))
#endif
		check(status);
	LeaveCriticalSection(&attach_mtx);

	long id = 0;
	for (int i = 0; i < 1024; i++)
	{
		char event_name[255];
		sprintf(event_name, "event_%032d_%032i", num, i+1);

		unsigned char *ev, *res;
		const int cnt_evt = isc_event_block(&ev, &res, 1, event_name);

		if (isc_que_events(status, &hDB, &id, cnt_evt, ev, event_callback, res))
			check(status);
	}

	EnterCriticalSection(&attach_mtx);
#ifdef ONE_DB
	isc_detach_database(status, &hDB);
#else
	isc_drop_database(status, &hDB);
#endif
	LeaveCriticalSection(&attach_mtx);

	InterlockedDecrement(&thd_cnt);
	return 0;
}

int main()
{
	SetEnvironmentVariable("ISC_USER", USER);
	SetEnvironmentVariable("ISC_PASSWORD", PWD);

	InitializeCriticalSection(&attach_mtx);

#ifdef ONE_DB
	sprintf(fileName, "events.fdb");
	DeleteFile(fileName);

	ISC_STATUS_ARRAY status = {0};
	isc_db_handle hDB = NULL;
	if (isc_create_database(status, strlen(fileName), fileName, &hDB, 0, NULL, 0))
		check(status);
	isc_detach_database(status, &hDB);
#endif

	for (int i=0; i < NUM_THREADS; i++) 
		_beginthreadex(NULL, 0, &worker, NULL, 1, NULL);

	Sleep(100);
	while (thd_cnt > 0) 
		Sleep(100);

#ifdef ONE_DB
	DeleteFile(fileName);
#endif

	return 1;
}
