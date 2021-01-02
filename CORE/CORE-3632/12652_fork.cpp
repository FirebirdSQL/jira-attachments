#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#include <ibase.h>
#include <firebird/Interface.h>

using namespace Firebird;

typedef FirebirdApi<class FirebirdPolicy> Api;
FB_USE_API(Api, I)

class FirebirdPolicy
{
public:
	template <unsigned V, typename T>
	static inline bool checkVersion(T*, IStatus*) { return true; }
	static void checkException(Api::Status*) { }
	static void catchException(Api::Status*) { }
	typedef Api::Status* Status;
};

DECLARE_GET_MASTER(FirebirdPolicy)
static IMaster* master = fb_get_master_interface();

static void check(IStatus* s, const char* text)
{
	unsigned res = s->getStatus();
	if (res & IStatus::FB_HAS_ERRORS)
		throw text;

	if (res & IStatus::FB_HAS_WARNINGS)
	{
		isc_print_status(s->getWarnings());
		s->init();
	}
}

static void sysfork(const char* command)
{
	if (fork() == 0)
	{
		printf("%s %d %d\n", command, getpid(), getppid());
		// emulate exec failure
		//execlp("sh", "sh", "-c", command, NULL);
		//perror("execlp");
		exit(1);
	}
}

int main()
{
	printf("%s %d %d\n", "forker", getpid(), getppid());
	int rc = 0;

	// set default password if none specified in environment
	setenv("ISC_USER", "sysdba", 0);
	setenv("ISC_PASSWORD", "masterkey", 0);

	// declare pointers to required interfaces
	IStatus* st = NULL;
	IProvider* prov = NULL;
	IAttachment* att = NULL;
	ITransaction* tra = NULL;

	try
	{
		// status vector and main dispatcher
		st = master->getStatus();
		prov = master->getDispatcher();

		// attach employee db
		att = prov->attachDatabase(st, "employee", 0, NULL);
		check(st, "attachDatabase");

		// start transaction
		tra = att->startTransaction(st, 0, NULL);

		att->execute(st, tra, 0, "update country set currency = 'rub'", 3,
	        NULL, NULL, NULL, NULL);
		check(st, "execute");

		// now perform some forks
		sysfork("echo abcd>efg");
		sysfork("cat efg");
		sysfork("rm efg");

		// close interfaces
		tra->rollback(st);
		check(st, "rollback");
		tra = NULL;
		att->detach(st);
		check(st, "detach");
		att = NULL;
	}
	catch (const char* text)
	{
		// handle error
		rc = 1;
		fprintf(stderr, "%s:\n", text);
		if (st)
			isc_print_status(st->getErrors());
	}

	// release interfaces after error caught
	if (tra)
		tra->release();
	if (att)
		att->release();

	if (prov)
		prov->release();
	if (st)
		st->dispose();

	return rc;
}
