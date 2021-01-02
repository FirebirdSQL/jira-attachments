void LxTraceOdbcErrors(SQLSMALLINT iHandleType, SQLHANDLE hHandle, SQLRETURN SQLret)
{
   SQLWCHAR SqlState[6];
   SQLWCHAR Msg[SQL_MAX_MESSAGE_LENGTH];
   SQLINTEGER NativeError;
   SQLSMALLINT i; 
   lx_int32 a = SQL_MAX_MESSAGE_LENGTH;
   SQLSMALLINT MsgLen;
   SQLRETURN rc;

   i = 1;
   while ((rc = SQLGetDiagRec(iHandleType, hHandle, i, SqlState, &NativeError, Msg,
                              sizeof(Msg) / sizeof(SQLWCHAR), &MsgLen)) != SQL_NO_DATA) 
   {
      if (rc == SQL_ERROR || rc == SQL_INVALID_HANDLE)
      {
         LX_TRACE_DETAIL(L"DBSQL:SQLGetDiagRec failed");
         break;
      }
      bool bTrace = true;

      if (bTrace)
      {
         LX_TRACE_DETAIL(L"DBSQL:ODBC: \'%s\'; %d; \'%s\'", SqlState, NativeError, Msg);
        
      }
      i++;

   }
   if (i == 1)
      LX_TRACE_DETAIL(L"DBSQL:ODBC: error %d without info", SQLret);
}

//------------------------------------------------------------------------------------------------
void Test()
{
   #define ALIGNSIZE 4
   #define ALIGNBUF(Length) Length % ALIGNSIZE ? Length + ALIGNSIZE - (Length % ALIGNSIZE) : Length
 
    HENV env;
    int ret = SQLAllocHandle (SQL_HANDLE_ENV, NULL, &env);
    LxTraceOdbcErrors(SQL_HANDLE_ENV, env, ret);

    ret = SQLSetEnvAttr (env, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, SQL_IS_UINTEGER);
    LxTraceOdbcErrors(SQL_HANDLE_ENV, env, ret);
    HDBC connection;
    ret = SQLAllocHandle (SQL_HANDLE_DBC, env, &connection);
    LxTraceOdbcErrors(SQL_HANDLE_ENV, env, ret);
    
    SQLWCHAR buffer_error[1024];
    SQLSMALLINT textlength;
    CLxStringW sConnStr = L"DRIVER=test_fb_odbc; UID=MyUser; PWD=MyPassword; DBNAME=192.168.11.111:c:\\databases\\demo.FDB; CHARSET=UTF8";
    ret = SQLDriverConnect(connection, NULL, (lx_wchar*) sConnStr.GetString(), (SQLSMALLINT)sConnStr.GetLength(), buffer_error, 1023, &textlength, SQL_DRIVER_NOPROMPT);
    LxTraceOdbcErrors(SQL_HANDLE_DBC, connection, ret);
    HSTMT statement;
    ret = SQLAllocHandle (SQL_HANDLE_STMT, connection, &statement);
    ret = SQLExecDirect(statement, L"SELECT first_name FROM EMPLOYEE", 31);
 
    lx_uint32 uiFetchBufferLength = 100;
    lx_uint32 uiDBDataSize = ALIGNBUF((31*4));
    lx_uint32 uiX = ALIGNBUF(sizeof(SQLUSMALLINT));
    lx_uint32 uiRowSize = uiDBDataSize + uiX;
    ret = SQLSetStmtAttr(statement, SQL_ATTR_ROW_BIND_TYPE, (SQLPOINTER)uiRowSize, 0);

    void*  pData = CLxAlloc::Alloc(LX_GMEM_ZEROINIT, 1 + sizeof(SQLULEN) + uiFetchBufferLength * (sizeof(SQLUSMALLINT) + uiRowSize));
   
    ret = SQLSetStmtAttr(statement, SQL_ATTR_ROW_ARRAY_SIZE, (void*)uiFetchBufferLength, 0);

    SQLULEN* pNumRowsFetchedInStep = (SQLULEN*)((char*)pData + 1);
    ret = SQLSetStmtAttr(statement, SQL_ATTR_ROWS_FETCHED_PTR, pNumRowsFetchedInStep, 0);
    
    SQLUSMALLINT* pRowStatusArray = (SQLUSMALLINT*)((char*)pNumRowsFetchedInStep + sizeof(SQLULEN));
    ret = SQLSetStmtAttr(statement, SQL_ATTR_ROW_STATUS_PTR, pRowStatusArray, 0);

    char* pODBCFetchDataBlock = (char*)pRowStatusArray + uiFetchBufferLength * sizeof(SQLUSMALLINT);

    ret = SQLBindCol(statement,  1, SQL_C_WCHAR,
                                pODBCFetchDataBlock, uiDBDataSize,
                               (SQLLEN*)((lx_uint8*)pODBCFetchDataBlock + uiDBDataSize));

   LxTraceOdbcErrors(SQL_HANDLE_STMT, statement, ret);

   ret = SQLSetStmtAttr(statement, SQL_ATTR_ROW_ARRAY_SIZE, (void*)uiFetchBufferLength, 0);
  
   ret = SQLFetchScroll (statement, SQL_FETCH_NEXT,0);
   MessageBox((HWND)m_hWnd, n20(L"now stop or restart server"), n20(L""), MB_OK);
 
   ret = SQLFreeStmt(statement, SQL_UNBIND);
   ret = SQLFreeStmt(statement, SQL_RESET_PARAMS);
   ret = SQLFreeStmt(statement, SQL_CLOSE);
   CLxAlloc::Free(pData);
   pData = NULL;
   pNumRowsFetchedInStep = NULL;
   pRowStatusArray = NULL;
   pODBCFetchDataBlock = NULL;


   //exception will be raised on next line
   ret= SQLFreeHandle(SQL_HANDLE_STMT, statement);

   ret = SQLFreeHandle (SQL_HANDLE_DBC, connection);

   ret = SQLFreeHandle (SQL_HANDLE_ENV, env);
}