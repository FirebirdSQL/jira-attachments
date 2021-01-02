package it.prodata.sql;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.concurrent.ThreadLocalRandom;

/**
 * This class demonstrates a bug in ResultSet.updateRow: BLOB fields are automatically set to NULL.
 */
public class ResultSetUpdateRowTest {

	private static final String TEST_DRIVER	= "org.firebirdsql.jdbc.FBDriver";
	private static final String TEST_URL	= "jdbc:firebirdsql://localhost:3050/C:\\Temp\\Test.fdb";

	private static final String TEST_USER	= "SYSDBA";
	private static final String TEST_PWD	= "masterkey";

	private static final String TEST_TABLE	= "TEST";

	private Connection con;

	public ResultSetUpdateRowTest(Connection con) {
		this.con = con;
	}

	private void execute(String sql) throws SQLException {
		try (Statement stmt = con.createStatement()) {
			stmt.executeUpdate(sql);
		}
		catch (SQLException e) {
			System.out.println("Error executing:");
			System.out.println(sql);
			throw e;
		}
	}

	private boolean tableExists(String tableName) throws SQLException {
		boolean exists = false;
		try (ResultSet rs = con.getMetaData().getTables(null, null, tableName, null)) {
			exists = rs != null && rs.next();
		}
		return exists;
	}

	private void dropExistingTable(String tableName) throws SQLException {
		if (!con.getAutoCommit())
			con.setAutoCommit(true);
		if (tableExists(tableName)) {
			System.out.println();
			System.out.println("Dropping table " + tableName + " ...");
			execute("DROP TABLE " + tableName);
		}
	}

	private void createTable(String tableName) throws SQLException {
		System.out.println();
		System.out.println("Creating table " + tableName + " ...");
		if (!con.getAutoCommit())
			con.setAutoCommit(true);

		String sql = new StringBuilder(200)
			.append("CREATE TABLE ")
			.append(tableName)
			.append(" (\n"
				+ "ID INTEGER NOT NULL,\n"
				+ "NR INTEGER NOT NULL,\n"
				+ "X1 VARCHAR(50),\n"
				+ "X2 VARCHAR(50),\n"
				+ "X3 VARCHAR(50),\n"
				+ "XL BLOB SUB_TYPE 1,\n"
			)
			.append("CONSTRAINT PK_")
			.append(tableName)
			.append(" PRIMARY KEY (ID))")
			.toString();
		execute(sql);
	}

	private void populateTable(String tableName, int rowCount) throws SQLException {
		boolean autoCommit = con.getAutoCommit();
		if (autoCommit)
			con.setAutoCommit(false);
		System.out.println();
		System.out.println("Populating table " + tableName + " ...");
		ThreadLocalRandom random = ThreadLocalRandom.current();
		String sql = "INSERT INTO " + tableName + " (ID,NR,X1,X2,X3,XL) VALUES (?,?,?,?,?,?)";
		try (PreparedStatement stmt = con.prepareStatement(sql)) {
			for (int row = 1; row <= rowCount; row++) {
				int rndValue = random.nextInt(1000);
				stmt.setInt(1, row);
				stmt.setInt(2, rndValue);
				stmt.setString(3, "X1." + row + "." + rndValue);
				stmt.setString(4, "X2." + row + "." + rndValue);
				stmt.setString(5, "X3." + row + "." + rndValue);
				stmt.setString(6, "XL." + row + "." + rndValue + "\n\t--------------\n\tbla bla bla");
				stmt.executeUpdate();
			}
		}
		con.commit();
		if (autoCommit)
			con.setAutoCommit(true);
	}

	private void changeSomeValue(String tableName, int inRow) throws SQLException {
		System.out.println();
		System.out.println("Changing some value of table " + tableName + " in row " + inRow + " ...");
		boolean autoCommit = con.getAutoCommit();
		if (autoCommit)
			con.setAutoCommit(false);
		try (Statement stmt = con.createStatement(ResultSet.TYPE_SCROLL_SENSITIVE, ResultSet.CONCUR_UPDATABLE)) {
			try (ResultSet rs = stmt.executeQuery("SELECT * FROM " + tableName)) {
				// Scrolling to some row
				for (int row = 0; row < inRow; row++)
					rs.next();

				// Change the value of column "NR"
				rs.updateInt("NR", 999);

				// BUG: Updating the row the column XL will be set to NULL !!!
				rs.updateRow();
			}
		}
		con.commit();
		if (autoCommit)
			con.setAutoCommit(true);
	}

	private void dumpTable(String tableName) throws SQLException {
		try (Statement stmt = con.createStatement()) {
			try (ResultSet rs = stmt.executeQuery("SELECT * FROM " + tableName)) {
				ResultSetMetaData md = rs.getMetaData();
				int cols = md.getColumnCount();
				System.out.println();
				System.out.println(tableName);
				System.out.println("------------------------------------------------------------");
				for (int i = 1; i <= cols; i++) {
					if (i > 1)
						System.out.print('\t');
					System.out.print(md.getColumnLabel(i));
				}
				System.out.println();
				System.out.println("------------------------------------------------------------");
				while (rs.next()) {
					for (int i = 1; i <= cols; i++) {
						if (i > 1)
							System.out.print('\t');
						System.out.print(rs.getString(i));
					}
					System.out.println();
				}
				System.out.println();
			}
		}
	}

	private void run() throws Exception {
		dropExistingTable(TEST_TABLE);
		createTable(TEST_TABLE);
		populateTable(TEST_TABLE, 5);
		dumpTable(TEST_TABLE);
		changeSomeValue(TEST_TABLE, 3);
		dumpTable(TEST_TABLE);
	}

	private static Connection openConnection() throws SQLException {
		Connection con = DriverManager.getConnection(TEST_URL, TEST_USER, TEST_PWD);
		con.setTransactionIsolation(Connection.TRANSACTION_READ_COMMITTED);
		con.setAutoCommit(true);
		return con;
	}

	public static void main(String[] args) {
		try {
			Class.forName(TEST_DRIVER);
			try (Connection con = openConnection()) {
				ResultSetUpdateRowTest test = new ResultSetUpdateRowTest(con);
				test.run();
			}
		}
		catch (Exception e) {
			e.printStackTrace(System.out);
		}
	}
}
