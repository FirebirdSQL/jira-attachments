package test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class TestConnection {

	public static Connection getConnection() throws Exception {
		try {
			Class.forName("org.firebirdsql.jdbc.FBDriver");
		} catch (ClassNotFoundException cnfe) {
			throw new Exception("Could not find JDBC driver class.", cnfe);
		}

		java.util.Properties connectionProperties = new java.util.Properties();
		connectionProperties.put("user", "SYSDBA");
		connectionProperties.put("password", "masterkey");
		connectionProperties.put("encoding", "WIN1251");

		Connection con = null;
		try {
			con = DriverManager.getConnection("jdbc:firebirdsql:embedded:C:/database/some.fdb", connectionProperties);
			con.setAutoCommit(false);

			return con;
		} catch (SQLException e) {
			throw new Exception("Cannot create source connection.", e);
		}
	}

	public static void main() {
		try {
			getConnection();
			
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
