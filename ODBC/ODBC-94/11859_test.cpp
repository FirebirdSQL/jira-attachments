#include <stdio.h>
#include <string.h>
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
//    const char *connectString = "ODBC;DSN=Test;UID=SYSDBA;PWD=masterkey;DBNAME=/OdbcJdbc/employee.gdb";
    const char *connectString = "Test";

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
    HDBC connection1 = testConnect (connectString);
    
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
//    int ret = SQLAllocEnv (&env);
    if (!OdbcCheckCode (ret, env, "SQLSetEnvAttr", SQL_HANDLE_ENV))
        return NULL;

    ret = SQLSetEnvAttr (env, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, SQL_IS_UINTEGER);
    if (!OdbcCheckCode (ret, env, "SQLSetEnvAttr", SQL_HANDLE_ENV))
        return NULL;

    HDBC connection;
//    ret = SQLAllocConnect (env, &connection);
    ret = SQLAllocHandle (SQL_HANDLE_DBC, env, &connection);
    if (!OdbcCheckCode (ret, env, "SQLAllocHandle", SQL_HANDLE_ENV))
        return NULL;


/*    Для Linux не нужно
    ret = SQLSetConnectAttr (connection, SQL_ATTR_ODBC_CURSORS, (SQLPOINTER) SQL_CUR_USE_ODBC, 0);
    if (!OdbcCheckCode (ret, connection, "SQLConnectAttr", SQL_HANDLE_DBC))
        return NULL;
*/
/*    
    UCHAR buffer [128];
    SWORD bufferLength;
    ret = SQLDriverConnect (connection, hWnd, 
                            (UCHAR*) connectString, SQL_NTS,
                            buffer, sizeof (buffer), &bufferLength,
                            SQL_DRIVER_NOPROMPT);
    if (!OdbcCheckCode (ret, connection, "SQLDriverConnect", SQL_HANDLE_DBC))
        return NULL;
*/
    
    ret = SQLConnect (connection, (UCHAR*)connectString, SQL_NTS, NULL, SQL_NTS, NULL, SQL_NTS);		
    if (!OdbcCheckCode (ret, connection, "SQLConnect", SQL_HANDLE_DBC))
       return NULL;
/*
    ret = SQLSetConnectAttr (connection, SQL_ATTR_AUTOCOMMIT, (SQLPOINTER) SQL_AUTOCOMMIT_OFF, 0);
    if (!OdbcCheckCode (ret, connection, "SQLSetConnectAttr", SQL_HANDLE_DBC))
        return NULL;
*/    
    return connection;

}


void test1 (HDBC connection)
{

    printf("\n\nTest1\n\n");

    HSTMT statement;
    int ret = SQLAllocHandle (SQL_HANDLE_STMT, connection, &statement);
    if (!OdbcCheckCode (ret, connection, "SQLAllocHandle", SQL_HANDLE_DBC))
        return;

    Print print (statement);
    /*
     * Try a ordinary retrieval
     */

//    ret = SQLCloseCursor (statement);
//    if (!OdbcCheckCode (ret, statement, "SQLCloseCursor"))
//        return;

    ret = SQLSetStmtAttr (statement, SQL_ATTR_CURSOR_SCROLLABLE, (void*) SQL_SCROLLABLE, 0);
    if (!OdbcCheckCode (ret, statement, "SQLSetStmtAttr SQL_ATTR_CURSOR_SCROLLABLE, SQL_SCROLLABLE"))
        return;

    ret = SQLSetStmtAttr (statement, SQL_ATTR_CURSOR_TYPE, (void*) SQL_CURSOR_STATIC, 0);
    if (!OdbcCheckCode (ret, statement, "SQLSetStmtAttr SQL_ATTR_CURSOR_TYPE, SQL_CURSOR_STATIC"))
        return;

    ret = SQLPrepare (statement, (UCHAR*) 
                "SELECT first_name FROM EMPLOYEE "
                "WHERE (1=1) or FIRST_NAME=?", SQL_NTS);

    if (!OdbcCheckCode (ret, statement, "SQLPrepare"))
        return;

/* bill lam */
/* get 2 rows */
    ret = SQLSetStmtAttr (statement, SQL_ATTR_ROW_BIND_TYPE, (void*) SQL_BIND_BY_COLUMN, 0);
    if (!OdbcCheckCode (ret, statement, "SQLSetStmtAttr SQL_ATTR_ROW_BIND_TYPE, (void*) SQL_BIND_BY_COLUMN"))
        return;

    ret = SQLSetStmtAttr (statement, SQL_ATTR_ROW_ARRAY_SIZE, (void*) 2, 0);
    if (!OdbcCheckCode (ret, statement, "SQLSetStmtAttr SQL_ATTR_ROW_ARRAY_SIZE, (void*) 2"))
        return;

int stname;
    ret = SQLSetStmtAttr (statement, SQL_ATTR_ROW_STATUS_PTR, &stname , 0);
    if (!OdbcCheckCode (ret, statement, "SQLSetStmtAttr "))
        return;

int rfname;
    ret = SQLSetStmtAttr (statement, SQL_ATTR_ROWS_FETCHED_PTR, rfname , 0);
    if (!OdbcCheckCode (ret, statement, "SQLSetStmtAttr "))
        return;

    SWORD   type;
    UDWORD  precision;
    SWORD   scale;
    SWORD   nullable;

    ret = SQLDescribeParam (statement, 1, &type, &precision, &scale, &nullable);
    if (!OdbcCheckCode (ret, statement, "SQLDescribeParam"))
        return;

    char  robert[] = "Robert";
    ret = SQLBindParameter (statement, 1, SQL_PARAM_INPUT, 
                            SQL_C_CHAR, type, precision, scale, robert, 0, NULL);
    if (!OdbcCheckCode (ret, statement, "SQLBindParameter"))
        return;

    ret = SQLExecute (statement);
    if (!OdbcCheckCode (ret, statement, "SQLExecute"))
        return;
 
    UCHAR firstName [300]="My";
    SQLLEN firstNameLength[2];

    ret = SQLBindCol (statement, 1, SQL_C_CHAR, firstName, 30, &firstNameLength[0]);
    if (!OdbcCheckCode (ret, statement, "SQLBindCol"))
        return;

//    UDWORD rowCount;
//    UWORD rowStatusArray;

    print.printHeaders();


    for (;;)
    {
        //SQLUINTEGER rowCount;
        //SQLUSMALLINT rowStatusArray;

        ret = SQLFetch (statement);
	
//        ret = SQLExtendedFetch (statement, SQL_FETCH_NEXT, 0, &rowCount, &rowStatusArray);
        //ret = SQLFetchScroll (statement, SQL_FETCH_NEXT, 0);
        if (ret == SQL_NO_DATA_FOUND)
            break;
        if (!OdbcCheckCode (ret, statement, "SQLFetch"))
            break;

/* bill lam */
/* also print firstNameLength[0] and firstNameLength[1] to verify the issue of SQLLEN vs SQLINTEGER*/

        print.printLine();
	
    }

    ret = SQLFreeHandle (SQL_HANDLE_STMT, statement);
    if (!OdbcCheckCode (ret, statement, "SQLFreeHandle (statement"))
        return;

}

void testDisconnect (HDBC connection)
    {
    int ret;


    ret = SQLEndTran (SQL_HANDLE_DBC, connection, SQL_COMMIT);
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
