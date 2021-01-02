package app.core;

import java.sql.Connection;

import app.core.AppDb;

public class HelloJaybird  {
	public static final AppDb db = AppDb.getAppDb();

	public static void main(String[] args) throws Exception {
		Connection Conn = db.getDbConnection();
	}
}
