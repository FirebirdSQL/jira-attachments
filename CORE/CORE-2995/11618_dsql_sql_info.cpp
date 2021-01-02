#include <stdio.h>
#include <stdlib.h>
#include <ibase.h>
#include <string.h>
#include <unistd.h>

void inline ERREXIT(ISC_STATUS* status, int rc) 
{
	fprintf(stderr, "Step %d\n", rc);
	isc_print_status(status); 
	exit(rc);
}

int main(int ac, char** av)
{
	ISC_STATUS_ARRAY status;

	putenv("ISC_USER=sysdba");
	putenv("ISC_PASSWORD=masterkey");

	isc_db_handle db = 0;
	if (isc_attach_database(status, 0, "localhost:employee", &db, 0, NULL)) 
	{
		ERREXIT(status, 1); 
	}

    isc_tr_handle tr = 0;
	if (isc_start_transaction(status, &tr, 1, &db, 0, NULL))
	{ 
		ERREXIT(status, 2); 
	}

	XSQLDA* sqlda = (XSQLDA*) malloc(XSQLDA_LENGTH(20));
	memset(sqlda, 0, XSQLDA_LENGTH(20));
	sqlda->version = SQLDA_VERSION1;
	sqlda->sqln = 20;

	isc_stmt_handle st = 0;
	if (isc_dsql_allocate_statement(status, &db, &st))
	{ 
		ERREXIT(status, 201); 
	}

	// 1. select cast('--2' as integer) from rdb$database

	if (isc_dsql_prepare(status, &tr, &st, 0, "select cast('--2' as integer) from rdb$database",
						 SQL_DIALECT_V6, sqlda))
	{ 
		ERREXIT(status, 3); 
	}

	const char sqlda_info[] = { isc_info_sql_stmt_type, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
	char info_buffer[16];
	if (isc_dsql_sql_info (status, &st, sizeof (sqlda_info), sqlda_info,
						   sizeof (info_buffer), info_buffer))
	{
		ERREXIT(status, 4); 
	}

	if (isc_dsql_execute(status, &tr, &st, SQL_DIALECT_V6, NULL))
	{
		ERREXIT(status, 5);
	}

	if (isc_dsql_set_cursor_name(status, &st, "CURS", 0))
	{
		ERREXIT(status, 6);
	}

	isc_dsql_fetch(status, &st, SQLDA_VERSION1, sqlda);
	isc_print_status(status);

	if (isc_dsql_free_statement(status, &st, DSQL_close))
	{
		ERREXIT(status, 8);
	}

	// 2. select ** from rdb$database
	isc_dsql_prepare(status, &tr, &st, 0, "select ** from rdb$database",
					 SQL_DIALECT_V6, sqlda);
	isc_print_status(status);
	isc_dsql_prepare(status, &tr, &st, 0, "select ** from rdb$database",
					 SQL_DIALECT_V6, sqlda);
	isc_print_status(status);

	// 3. execute procedure tmp
	if (isc_dsql_prepare(status, &tr, &st, 0, "execute procedure tmp",
						 SQL_DIALECT_V6, sqlda))
	{ 
		ERREXIT(status, 9); 
	}

	if (isc_dsql_sql_info (status, &st, sizeof (sqlda_info), sqlda_info,
						   sizeof (info_buffer), info_buffer))
	{
		isc_print_status(status); 
	}
	else
	{
		printf("First OK\n");
	}
	if (isc_dsql_sql_info (status, &st, sizeof (sqlda_info), sqlda_info,
						   sizeof (info_buffer), info_buffer))
	{
		isc_print_status(status); 
	}
	else
	{
		printf("Second OK\n");
	}
}
