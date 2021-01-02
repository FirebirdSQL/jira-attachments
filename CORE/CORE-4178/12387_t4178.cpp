#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <ibase.h>
#include <firebird/Provider.h>

using namespace Firebird;

static IMaster* master = fb_get_master_interface();

static void check(IStatus* s, const char* text)
{
	if (!s->isSuccess())
		throw text;
}

int main()
{
	int rc = 0;

	// set default password if none specified in environment
	setenv("ISC_USER", "sysdba", 0);
	setenv("ISC_PASSWORD", "masterkey", 0);

	// declare pointers to required interfaces
	IStatus* st = NULL;
	IProvider* prov = NULL;
	IAttachment* att = NULL;
	ITransaction* tra = NULL;
	IStatement* stmt = NULL;
	IMessageMetadata* meta = NULL;

	try
	{
		// status vector and main dispatcher
		st = master->getStatus();
		prov = master->getDispatcher();

		// attach employee db
		att = prov->attachDatabase(st, "t4178.fdb", 0, NULL);
		check(st, "attachDatabase");

		// start default transaction
		tra = att->startTransaction(st, 0, NULL);
		check(st, "startTransaction");

		// prepare statement
		stmt = att->prepare(st, tra, 0, "select * from tt",
			3, IStatement::PREPARE_PREFETCH_METADATA);
		check(st, "prepare");

		// get list of columns
		meta = stmt->getOutputMetadata(st);
		check(st, "getOutputMetadata");
		unsigned cols = meta->getCount(st);
		check(st, "getCount");

		// parse columns list & coerce datatype(s)
		for (unsigned j = 0; j < cols; ++j)
		{
			const char* name = meta->getField(st, j);
			check(st, "getField");
			unsigned t = meta->getType(st, j);
			check(st, "getType");
			unsigned sub = meta->getSubType(st, j);
			check(st, "getSubType");
			unsigned l = meta->getLength(st, j);
			check(st, "getLength");
			unsigned s = meta->getScale(st, j);
			check(st, "getScale");
			unsigned cs = meta->getCharSet(st, j);
			check(st, "getCharSet");

			printf("Field %s, Type %d, SubType %d, Length %d, Scale %d, CharSet %d\n",
				name, t, sub, l, s, cs);
		}

		// close interfaces
		stmt->free(st);
		check(st, "free");
		stmt = NULL;

		meta->release();
		meta = NULL;

		tra->commit(st);
		check(st, "commit");
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
			isc_print_status(st->get());
	}

	// release interfaces after error caught
	if (meta)
		meta->release();
	if (stmt)
		stmt->release();
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
