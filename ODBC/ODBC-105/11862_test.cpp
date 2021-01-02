/*
 first create a blank database with characterset=utf8
 and connect to this database using odbc
*/

#include <stdio.h>
#include "Odbc.h"
#include "Print.h"


static HENV env;
static SQLHWND hWnd;

static HDBC testConnect (const char *);
static void test1 (HDBC);
static void testDisconnect (HDBC);


int main (int argc, const char **argv)
    {
    const char **end = argv + argc;
//    const char *connectString = "ODBC;DSN=FireBirdOdbc;DRIVER=OdbcJdbc;ROLE=cinnamon";
    const char *connectString = "DSN=FireBirdOdbc";

    for (++argv; argv < end;)
        {
        const char *p = *argv++;
        if (p [0] == '-')
            switch (p [1])
                {
                case 'i':
                    //install();
                    break;

                case 'c':
                    connectString = *argv++;
                    break;

                default:
                    printf ("Don't understand switch '%s'\n", p);
                    return 1;
                }
        }
    if (HDBC connection = testConnect (connectString))
	{
	test1 (connection);

	testDisconnect (connection);
	}

    return 0;
    }



HDBC testConnect (const char *connectString)
    {
    int ret = SQLAllocHandle (SQL_HANDLE_ENV, NULL, &env);
    ret = SQLSetEnvAttr (env, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, SQL_IS_UINTEGER);
    if (!OdbcCheckCode (ret, env, "SQLSetEnvAttr", SQL_HANDLE_ENV))
        return NULL;

    HDBC connection;
    ret = SQLAllocHandle (SQL_HANDLE_DBC, env, &connection);
    if (!OdbcCheckCode (ret, env, "SQLAllocHandle", SQL_HANDLE_ENV))
        return NULL;

    //ret = SQLAllocConnect (env, &connection);
    ret = SQLSetConnectAttr (connection, SQL_ATTR_ODBC_CURSORS, (SQLPOINTER) SQL_CUR_USE_ODBC, 0);
    if (!OdbcCheckCode (ret, connection, "SQLConnectAttr", SQL_HANDLE_DBC))
        return NULL;
    
    UCHAR buffer [128];
    SWORD bufferLength;
    ret = SQLDriverConnect (connection, hWnd, 
                            (UCHAR*) connectString, SQL_NTS,
                            buffer, sizeof (buffer), &bufferLength,
                            SQL_DRIVER_NOPROMPT);

    if (!OdbcCheckCode (ret, connection, "SQLDriverConnect", SQL_HANDLE_DBC))
        return NULL;

//    ret = SQLConnect (connection, (UCHAR*) "FireBird", SQL_NTS, NULL, SQL_NTS, NULL, SQL_NTS);
    if (!OdbcCheckCode (ret, connection, "SQLConnect", SQL_HANDLE_DBC))
       return NULL;

    ret = SQLSetConnectAttr (connection, SQL_ATTR_AUTOCOMMIT, (SQLPOINTER) SQL_AUTOCOMMIT_OFF, 0);
    if (!OdbcCheckCode (ret, connection, "SQLSetConnectAttr", SQL_HANDLE_DBC))
        return NULL;
    
    return connection;

    }



void test1 (HDBC connection)
    {
    HSTMT statement;
    int ret = SQLAllocHandle (SQL_HANDLE_STMT, connection, &statement);
    if (!OdbcCheckCode (ret, connection, "SQLAllocHandle", SQL_HANDLE_DBC))
        return;

    Print print (statement);
    /*
     * store integers using sqlbindparameter
     */

    ret = SQLExecDirect (statement, (UCHAR*) "drop table test1", SQL_NTS);
    ret = SQLExecDirect (statement, (UCHAR*) "create table test1 (c1 integer, c2 integer, c3 varchar(9) null)", SQL_NTS);
    if (!OdbcCheckCode (ret, statement, "SQLExecDirect"))
        return;

/* the long is 8-byte in linux */
/* if test in window, please use a 8-byte integer too */
    long ac1=1; SQLLEN alc1=sizeof(ac1);
    ret = SQLBindParameter (statement, 1, SQL_PARAM_INPUT, SQL_C_SLONG, SQL_INTEGER, 10, 0, ac1, 8, &alc1);
    long ac2=2; SQLLEN alc2=sizeof(ac2);
    ret = SQLBindParameter (statement, 2, SQL_PARAM_INPUT, SQL_C_SLONG, SQL_INTEGER, 10, 0, ac2, 8, &alc2);
    char *String1 = "a1";
    SQLLEN strlen1 = strlen (String1) + 1;
    ret = SQLBindParameter (statement, 3, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_VARCHAR, 10, 0, String1, strlen (String1) + 1, &strlen1);

    ret = SQLExecDirect (statement, (UCHAR*) "insert into test1(c1,c2,c3) values (?,?,?)", SQL_NTS);
    if (!OdbcCheckCode (ret, statement, "SQLExecDirect"))
        return;

    ac1=3; alc1=sizeof(ac1);
    ret = SQLBindParameter (statement, 1, SQL_PARAM_INPUT, SQL_C_SLONG, SQL_INTEGER, 10, 0, ac1, 8, &alc1);
    char *String2 = "b1";
    SQLLEN strlen2 = strlen (String2) + 1;
    ret = SQLBindParameter (statement, 2, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_VARCHAR, 10, 0, String2, strlen (String2) + 1, &strlen2);

    ret = SQLExecDirect (statement, (UCHAR*) "insert into test1(c1,c3) values (?,?)", SQL_NTS);
    if (!OdbcCheckCode (ret, statement, "SQLExecDirect"))
        return;

/* no error returned but values inserted are incorrect, 
   this can be demonstrated by select * from test1 in isql
*/

    ret = SQLFreeStmt (statement, SQL_RESET_PARAMS);
    if (!OdbcCheckCode (ret, statement, "SQLFreeStmt SQL_RESET_PARAMS"))
        return;

    print.printAll();

    }



void testDisconnect (HDBC connection)
    {

    int ret = SQLEndTran (SQL_HANDLE_DBC, connection, SQL_COMMIT);
	if (!OdbcCheckCode (ret, connection, "SQLEndTrans"))
		return;

    ret = SQLDisconnect (connection);
    if (!OdbcCheckCode (ret, connection, "SQLDisconnect", SQL_HANDLE_DBC))
    	return;

    ret = SQLFreeHandle (SQL_HANDLE_DBC, connection);
    if (!OdbcCheckCode (ret, connection, "SQLFreeHandle (connection)", SQL_HANDLE_DBC))
    	return;

    ret = SQLFreeHandle (SQL_HANDLE_ENV, env);
    if (!OdbcCheckCode (ret, env, "SQLFreeHandle (env)", SQL_HANDLE_ENV))
	return;


    }
