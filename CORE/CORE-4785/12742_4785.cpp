#include <stdlib.h>
#include <string.h>
#include <ibase.h>
#include <stdio.h>

#define    DEPTLEN        3
#define    PROJLEN        5
#define    BUFLEN        256

void ERREXIT (ISC_STATUS* s, int code)
{
	isc_print_status(s);
	exit(code);
}

int main (int argc, char** argv)
{
    isc_db_handle       DB = 0;              /* Database handle */
    isc_tr_handle       trans = 0;           /* transaction handle */
    isc_stmt_handle		stmt = 0;
    ISC_STATUS_ARRAY    status;                 /* status vector */
    char                empdb[128];

    if (argc > 1)
        strcpy(empdb, argv[1]);
    else
        strcpy(empdb, "employee.fdb");

	setenv("ISC_USER", "sysdba", 0);
	setenv("ISC_PASSWORD", "masterkey", 0);

	XSQLDA bsqlda;
	XSQLDA* sqlda = &bsqlda;
	memset(sqlda, 0, sizeof bsqlda);
    sqlda->sqln = 1;
    sqlda->sqld = 1;
    sqlda->version = 1;

    if (isc_attach_database(status, 0, empdb, &DB, 0, NULL))
    {
        ERREXIT(status, 1);
    }

    if (isc_start_transaction(status, &trans, 1, &DB, 0, NULL))
    {
        ERREXIT(status, 3);
    }

	if (isc_dsql_allocate_statement(status, &DB, &stmt))
    {
        ERREXIT(status, 2);
    }

	const char* sql = "Insert into NUM (N_1_0) values (?)";

	unsigned int xparam0_value = 5;
	short xparam0_ind = 0;

    sqlda->sqlvar[0].sqldata = (char *) &xparam0_value;
    sqlda->sqlvar[0].sqltype = SQL_LONG | 1;
    sqlda->sqlvar[0].sqllen  = sizeof(xparam0_value);
    sqlda->sqlvar[0].sqlind  = &xparam0_ind;

	if (isc_dsql_prepare(status, &trans, &stmt, 0, sql, 1, NULL))
    {
        ERREXIT(status, 4);
    }

	if (isc_dsql_execute(status, &trans, &stmt, 1, sqlda))
    {
        ERREXIT(status, 6);
    }

    if (isc_commit_transaction(status, &trans))
    {
        ERREXIT(status, 14);
    }

    if (isc_detach_database(status, &DB))
    {
        ERREXIT(status, 16);
    }

    return 0;
}
