#include <stdio.h>
#include <ibase.h>
#include <malloc.h>
#include <unistd.h>

ISC_STATUS_ARRAY st;

void check(ISC_STATUS s) 
{
	if (s) 
	{
		isc_print_status(st); 
		throw 1;
	}
}

int main(int ac, char** av)
{
	char* sDatabase = av[1];
	try
	{
		isc_db_handle db1 = 0;
		isc_tr_handle tr1 = 0;
		char buf[1024];
		sprintf(buf, "Create Database '%s' page_size 1024", sDatabase);
	
		check(isc_dsql_execute_immediate(st, &db1, &tr1, 0, buf, 3, 0));

		check(isc_start_transaction(st, &tr1, 1, &db1, 0, 0));
		check(isc_dsql_execute_immediate(st, &db1, &tr1, 0, "CREATE TABLE T (ID INT)", 3, 0));
		check(isc_commit_transaction(st, &tr1));

		char tpb[] = {isc_tpb_version3, isc_tpb_read_committed, isc_tpb_rec_version, isc_tpb_nowait, isc_tpb_read};
		check(isc_start_transaction(st, &tr1, 1, &db1, sizeof(tpb), tpb));


		isc_db_handle db2 = 0;
		check(isc_attach_database(st, 0, sDatabase, &db2, 0, 0));

		isc_tr_handle tr2 = 0;
		int i;
		for (i=0; i<4016; ++i)
		{
			check(isc_start_transaction(st, &tr2, 1, &db2, 0, 0));
			check(isc_commit_transaction(st, &tr2));
		}

		check(isc_start_transaction(st, &tr2, 1, &db2, 0, 0));
		check(isc_dsql_execute_immediate(st, &db2, &tr2, 0, "INSERT INTO T VALUES (CURRENT_TRANSACTION)", 3, 0));
		check(isc_commit_transaction(st, &tr2));

		for (i=0; i<4016; ++i)
		{
			check(isc_start_transaction(st, &tr2, 1, &db2, 0, 0));
			check(isc_commit_transaction(st, &tr2));
		}

		check(isc_detach_database(st, &db2));

		isc_stmt_handle st1 = 0;
		check(isc_dsql_alloc_statement2(st, &db1, &st1));
		XSQLDA* xsqlda = (XSQLDA*)malloc(XSQLDA_LENGTH(1));
		xsqlda->version = SQLDA_VERSION1;
		xsqlda->sqln = 1;
		check(isc_dsql_prepare(st, &tr1, &st1, 0, "SELECT ID FROM T", 1, xsqlda));
		XSQLVAR* var = &(xsqlda->sqlvar[0]);
		int result = 0;
		var->sqldata = (char*) &result;
		var->sqltype = SQL_LONG;
		check(isc_dsql_execute2(st, &tr1, &st1, 1, 0, xsqlda));
		printf("ID = %d\n", result);

		check(isc_commit_transaction(st, &tr1));

		check(isc_drop_database(st, &db1));
	}
	catch(int)
	{
		unlink(sDatabase);
		return 1;
	}
	return 0;
}
