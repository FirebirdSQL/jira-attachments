import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;


public class TestDrop {

	public static Connection getFBConnection() throws Exception {
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
			con = DriverManager.getConnection("jdbc:firebirdsql:embedded:C:/database/somedb.fdb", connectionProperties);
			con.setAutoCommit(false);

			return con;
		} catch (SQLException e) {
			throw new Exception("Cannot create source connection.", e);
		}
	}

	/**
	 * @param args
	 */
	public static void main(String[] args) throws Exception {
		Connection con = null;
		try {
			con = getFBConnection();

			test2(con);
			
		} catch (Exception e) {
			e.printStackTrace();

		} finally {
			try {
				if (con != null && !con.isClosed())
					con.close();
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public static void statement(Connection connection, String sql) throws SQLException {
		Statement statement = connection.createStatement();
		statement.execute(sql);
		statement.close();
		connection.commit();
	}

	public static void test2(Connection connection) throws SQLException {
		try {
			statement(connection, "DROP TABLE X_TEST");
		} catch (Exception e) {
		}
		statement(connection, "CREATE TABLE X_TEST (ID bigint, st bigint)");
		statement(connection, "INSERT INTO X_TEST VALUES(null, 10)");

		int max = 0;
		Statement s = connection.createStatement(ResultSet.TYPE_FORWARD_ONLY, ResultSet.CONCUR_UPDATABLE);
		ResultSet rs = s.executeQuery("SELECT ID, RDB$DB_KEY FROM X_TEST");
		int column = rs.findColumn("ID");
		while (rs.next()) {
			rs.updateLong(column, ++max);
			rs.updateRow();
		}
		rs.close();
		s.close();
		connection.commit();

		statement(connection, "DROP TABLE X_TEST");
	}

}
