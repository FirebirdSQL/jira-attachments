#include <stdio.h>
#include <tchar.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdexcept>
#include <iostream>
#include <functional>
#include <string>
#include <vector>
#include <assert.h>

#ifdef _WIN32
#include <windows.h>
#endif

#include <sql.h>
#include <sqlext.h>

// ---------------------------------------------------------------------
void reportErrors(SQLSMALLINT type, SQLHANDLE handle);

// ---------------------------------------------------------------------

std::string to_string(TIME_STRUCT ts) {
	std::string s(16,0);
	int n = sprintf_s((char*)(s.data()), s.size(), "%02d:%02d:%02d", ts.hour, ts.minute, ts.second);
	if (n >= 0) s.resize(n);
	return s;
}
std::string to_string(TIMESTAMP_STRUCT ts) {
	std::string s(32, 0);
	int n = sprintf_s((char*)(s.data()), s.size(), "%04d-%02d-%02d %02d:%02d:%02d.%04ld", ts.year, ts.month, ts.day, ts.hour, ts.minute, ts.second, ts.fraction / 100000);
	if (n >= 0) s.resize(n);
	return s;
}

// ---------------------------------------------------------------------

std::string nullValue("NULL");

template<typename T>
std::string readCommon(HSTMT hstmt, SQLUSMALLINT col, SQLSMALLINT type) {
	using std::to_string;
	T val;
	SQLLEN ind = SQL_NULL_DATA;
	RETCODE rc = SQLGetData(hstmt, col, type, (SQLPOINTER)(&val), sizeof(val), &ind);
	if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_STMT, hstmt); }
	return (ind != SQL_NULL_DATA) ? to_string(val) : nullValue;
}
std::string readInt(HSTMT hstmt, SQLUSMALLINT col) {
	return readCommon<int32_t>(hstmt, col, SQL_C_SLONG); 
}
std::string readTime(HSTMT hstmt, SQLUSMALLINT col) {
	return readCommon<TIME_STRUCT>(hstmt, col, SQL_C_TIME); 
}
std::string readTimestamp(HSTMT hstmt, SQLUSMALLINT col) {
	return readCommon<TIMESTAMP_STRUCT>(hstmt, col, SQL_C_TIMESTAMP); 
}
std::string readString(HSTMT hstmt, SQLUSMALLINT col) {
	SQLLEN ind;
	std::string val(1024, 0);
	RETCODE rc = SQLGetData(hstmt, col, SQL_C_CHAR, (SQLPOINTER)(val.data()), val.size(), &ind);
	if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_STMT, hstmt); }
	return (ind != SQL_NULL_DATA) ? std::string(val.c_str()) : nullValue;
}

typedef std::string (*reader)(HSTMT, SQLUSMALLINT);

struct command {
	std::string sql;
	std::vector<reader> readers;
};
std::vector<command> commands = {
	{ "CREATE TABLE test_time (id int, val time);", {} },
	{ "INSERT INTO test_time VALUES (0, NULL);", {} },
	{ "INSERT INTO test_time VALUES (1, '00:00:00');", {} },
	{ "INSERT INTO test_time VALUES (2, '00:00:00.1');", {} },
	{ "INSERT INTO test_time VALUES (3, '00:00:00.01');", {} },
	{ "INSERT INTO test_time VALUES (4, '00:00:00.001');", {} },
	{ "INSERT INTO test_time VALUES (5, '00:00:00.0001');", {} },
	{ "SELECT id, val FROM test_time ORDER BY id;", { &readInt, &readTime } },
	{ "SELECT id, val FROM test_time ORDER BY id;", { &readInt, &readString } },
	{ "SELECT id, val FROM test_time ORDER BY id;", { &readInt, readTimestamp } },
	{ "DELETE FROM test_time;", {} },
	{ "DROP TABLE test_time;", {} },
};

int _tmain(int argc, _TCHAR* argv[])
{
	RETCODE rc;
	HENV henv = nullptr;
	HDBC hdbc = nullptr;


	std::string user = "altova_admin";
	std::string pass = "admin";
	std::string dsn = "Firebird25-DBDiff";


	rc = SQLAllocEnv(&henv);
	if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_ENV, henv); }

	rc = SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER)SQL_OV_ODBC3, SQL_IS_INTEGER);
	if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_ENV, henv); }

	rc = SQLAllocConnect(henv, &hdbc);
	if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_ENV, henv); }

	rc = SQLConnectA(hdbc, (UCHAR *)dsn.c_str(), SQL_NTS, (SQLCHAR*)user.c_str(), SQL_NTS, (SQLCHAR*)pass.c_str(), SQL_NTS);
	if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_DBC, hdbc); }

	HSTMT hstmt = SQL_NULL_HSTMT;
	rc = SQLAllocStmt(hdbc, &hstmt);
	if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_DBC, hdbc); }

	for (auto& cmd : commands)
	{
		std::cout << cmd.sql.c_str() << std::endl;
		rc = SQLExecDirectA(hstmt, (SQLCHAR*)cmd.sql.c_str(), SQL_NTS);
		if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_STMT, hstmt); }

		SQLSMALLINT columns = 0;
		rc = SQLNumResultCols(hstmt, &columns);
		if (!SQL_SUCCEEDED(rc)) { reportErrors(SQL_HANDLE_STMT, hstmt); }
		if (columns > 0)
		{
			assert(columns == cmd.readers.size());
			while (SQL_SUCCEEDED(rc=SQLFetch(hstmt)))
			{
				for (auto column = 0; column < columns; ++column)
				{
					assert(cmd.readers[column] && "no reader defined");
					auto val = (*cmd.readers[column])(hstmt, column+1);
					if (column > 0) std::cout << ",";
					std::cout << "'" << val << "'";
				}

				std::cout << std::endl;
			}
		}
	}

	rc = SQLFreeStmt(hstmt, SQL_DROP);
	rc = SQLDisconnect(hdbc);
	rc = SQLFreeConnect(hdbc);
	rc = SQLFreeEnv(henv);
	return 0;
}

// ---------------------------------------------------------------------

struct error {
	SQLINTEGER	code;
	SQLCHAR		states[6];
	std::string	message;
};

std::vector<error> getErrors(SQLSMALLINT type, SQLHANDLE handle)
{
	std::vector<error> errors;

	SQLSMALLINT recordNumber = 1;
	while (1)
	{
		error e;
		e.message.resize(SQL_MAX_MESSAGE_LENGTH, 0);

		SQLSMALLINT len = 0;
		SQLRETURN rc = SQLGetDiagRecA(
			type, handle, recordNumber,
			e.states, &e.code,
			(SQLCHAR*)(e.message.data()), (SQLSMALLINT)(e.message.size()),
			&len);

		if (rc == SQL_SUCCESS_WITH_INFO && len > 0)
		{// buffer too small - resize and try again
			e.message.resize(len + 1, 0);
			continue;
		}
		if (rc == SQL_NO_DATA || rc == SQL_ERROR || rc == SQL_INVALID_HANDLE)
			break; // no more records

		errors.push_back(e);
		++recordNumber;
	}
	return errors;
}

void reportErrors(const std::vector<error>& errors)
{
	for (const error& e : errors) {
		std::string states(e.states, e.states + 6);
		std::cerr << "Error...: " << e.code << std::endl;
		std::cerr << "State...: " << states.c_str() << std::endl;
		std::cerr << "Message.: " << e.message.c_str() << std::endl;
	}
}

void reportErrors(SQLSMALLINT type, SQLHANDLE handle) {
	reportErrors(getErrors(type, handle));
}
