// FBlob.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"
#include <Windows.h>
#include <sql.h>
#include <sqlext.h>

#define BLOB_LENGTH 2147483647

void OneBlob ( SQLHANDLE hdbc );
void TwoBlobs ( SQLHANDLE hdbc );
void ThreeBlobs ( SQLHANDLE hdbc );

int _tmain(int argc, _TCHAR* argv[])
{
    SQLHANDLE henv = SQL_NULL_HANDLE;
    SQLHANDLE hdbc = SQL_NULL_HANDLE;
    SQLHANDLE hstmt = SQL_NULL_HANDLE;
    SQLRETURN rc =  SQL_ERROR;

	// Initialize and Connect
    rc = ::SQLAllocHandle ( SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv );
    rc = ::SQLSetEnvAttr ( henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, 0 );
    rc = ::SQLAllocHandle ( SQL_HANDLE_DBC, henv, &hdbc );
    rc = ::SQLConnect ( hdbc, _T("FBTEST"), SQL_NTS, _T("SYSDBA"), SQL_NTS, _T("masterke"), SQL_NTS );

	// OneBlob works as expected
	OneBlob ( hdbc );
	// TwoBlob and ThreeBlobs exhibit the problem
	TwoBlobs ( hdbc );
	ThreeBlobs ( hdbc );

	//	Disconnect and Cleanup
    rc = ::SQLDisconnect ( hdbc );
    rc = ::SQLFreeHandle ( SQL_HANDLE_DBC, hdbc );
    rc = ::SQLFreeHandle ( SQL_HANDLE_ENV, henv );

	return 0;
}

void OneBlob ( SQLHANDLE hdbc )
{
	SQLRETURN rc = SQL_ERROR;
	SQLHANDLE hstmt = SQL_NULL_HANDLE;

	rc = ::SQLAllocHandle ( SQL_HANDLE_STMT, hdbc, &hstmt );
    rc = ::SQLExecDirect ( hstmt, _T("drop table ONE_BLOB"), SQL_NTS );
    rc = ::SQLExecDirect ( hstmt, _T("create table ONE_BLOB ( BLOB_A BLOB )") , SQL_NTS );
    rc = ::SQLPrepare ( hstmt, _T("insert into ONE_BLOB ( BLOB_A ) values ( ? )") , SQL_NTS );
    
    SQLPOINTER BlobA = (SQLPOINTER) 1;
    SQLLEN BlobAInd = SQL_LEN_DATA_AT_EXEC ( 0 );
    
    // bind the BLOB column
    rc = ::SQLBindParameter ( hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_LONGVARBINARY, BLOB_LENGTH, 0, BlobA, 0, &BlobAInd );
    rc = ::SQLExecute ( hstmt );
    
    SQLPOINTER ParamData = NULL;
    rc = ::SQLParamData ( hstmt, &ParamData );
    rc = ::SQLPutData ( hstmt, NULL, SQL_NULL_DATA );
    rc = ::SQLParamData ( hstmt, &ParamData );

    rc = ::SQLCancel ( hstmt );
    rc = ::SQLFreeHandle ( SQL_HANDLE_STMT, hstmt );
}

void TwoBlobs ( SQLHANDLE hdbc )
{
	SQLRETURN rc = SQL_ERROR;
	SQLHANDLE hstmt = SQL_NULL_HANDLE;

	/*
	**	With two blobs
	*/
	rc = ::SQLAllocHandle ( SQL_HANDLE_STMT, hdbc, &hstmt );
    rc = ::SQLExecDirect ( hstmt, _T("drop table TWO_BLOBS"), SQL_NTS );
    rc = ::SQLExecDirect ( hstmt, _T("create table TWO_BLOBS ( BLOB_A BLOB, BLOB_B BLOB)") , SQL_NTS );
    rc = ::SQLPrepare ( hstmt, _T("insert into TWO_BLOBS ( BLOB_A, BLOB_B ) values ( ?, ? )") , SQL_NTS );
    
    SQLPOINTER BlobA = (SQLPOINTER) 1;
    SQLPOINTER BlobB = (SQLPOINTER) 2;
    SQLLEN BlobAInd = SQL_LEN_DATA_AT_EXEC ( 0 );
    SQLLEN BlobBInd = SQL_LEN_DATA_AT_EXEC ( 0 );
    
    // bind the blob columns
    rc = ::SQLBindParameter ( hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_LONGVARBINARY, BLOB_LENGTH, 0, BlobA, 0, &BlobAInd );
    rc = ::SQLBindParameter ( hstmt, 2, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_LONGVARBINARY, BLOB_LENGTH, 0, BlobB, 0, &BlobBInd );
    rc = ::SQLExecute ( hstmt );
    
    SQLPOINTER ParamData = NULL;
    rc = ::SQLParamData ( hstmt, &ParamData );
    rc = ::SQLPutData ( hstmt, NULL, SQL_NULL_DATA );
    rc = ::SQLParamData ( hstmt, &ParamData );
    rc = ::SQLPutData ( hstmt, NULL, SQL_NULL_DATA );
    rc = ::SQLParamData ( hstmt, &ParamData );          // rc should be SQL_SUCCESS

    rc = ::SQLCancel ( hstmt );
    rc = ::SQLFreeHandle ( SQL_HANDLE_STMT, hstmt );
}

void ThreeBlobs ( SQLHANDLE hdbc )
{
	SQLRETURN rc = SQL_ERROR;
	SQLHANDLE hstmt = SQL_NULL_HANDLE;

	/*
	**	With two blobs
	*/
	rc = ::SQLAllocHandle ( SQL_HANDLE_STMT, hdbc, &hstmt );
    rc = ::SQLExecDirect ( hstmt, _T("drop table THREE_BLOBS"), SQL_NTS );
    rc = ::SQLExecDirect ( hstmt, _T("create table THREE_BLOBS ( BLOB_A BLOB, BLOB_B BLOB, BLOB_C BLOB)") , SQL_NTS );
    rc = ::SQLPrepare ( hstmt, _T("insert into THREE_BLOBS ( BLOB_A, BLOB_B, BLOB_C ) values ( ?, ?, ? )") , SQL_NTS );
    
    SQLPOINTER BlobA = (SQLPOINTER) 1;
    SQLPOINTER BlobB = (SQLPOINTER) 2;
	SQLPOINTER BlobC = (SQLPOINTER) 3;
    SQLLEN BlobAInd = SQL_LEN_DATA_AT_EXEC ( 0 );
    SQLLEN BlobBInd = SQL_LEN_DATA_AT_EXEC ( 0 );
	SQLLEN BlobCInd = SQL_LEN_DATA_AT_EXEC ( 0 );
    
    // bind the blob columns
    rc = ::SQLBindParameter ( hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_LONGVARBINARY, BLOB_LENGTH, 0, BlobA, 0, &BlobAInd );
    rc = ::SQLBindParameter ( hstmt, 2, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_LONGVARBINARY, BLOB_LENGTH, 0, BlobB, 0, &BlobBInd );
	rc = ::SQLBindParameter ( hstmt, 3, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_LONGVARBINARY, BLOB_LENGTH, 0, BlobC, 0, &BlobCInd );
    rc = ::SQLExecute ( hstmt );
    
    SQLPOINTER ParamData = NULL;
    rc = ::SQLParamData ( hstmt, &ParamData );
    rc = ::SQLPutData ( hstmt, NULL, SQL_NULL_DATA );
	//rc = ::SQLPutData ( hstmt, NULL, 0 );
    rc = ::SQLParamData ( hstmt, &ParamData );
    rc = ::SQLPutData ( hstmt, NULL, SQL_NULL_DATA );
	//rc = ::SQLPutData ( hstmt, NULL, 0 );
	rc = ::SQLParamData ( hstmt, &ParamData );			// ParamData should be 3 after this
    rc = ::SQLPutData ( hstmt, NULL, SQL_NULL_DATA );
	//rc = ::SQLPutData ( hstmt, NULL, 0 );
    rc = ::SQLParamData ( hstmt, &ParamData );          // rc should be SQL_SUCCESS not SQL_NEED_DATA after this

    rc = ::SQLCancel ( hstmt );
    rc = ::SQLFreeHandle ( SQL_HANDLE_STMT, hstmt );
}