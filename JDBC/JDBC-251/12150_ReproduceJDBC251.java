package jdbc251;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class ReproduceJDBC251 {
	public static void main(String[] args) throws SQLException {
		final String databaseURL = "localhost:D:\\Data\\db\\WIN1251DB.FDB";
		final String jdbcUrl = "jdbc:firebirdsql:" + databaseURL
				+ "?lc_ctype=WIN1251&isc_dpb_process_name=АИС ФССП России";
		
		System.out.println(jdbcUrl);

		final Connection c = DriverManager.getConnection(jdbcUrl, "sysdba",
				"masterkey");
		final Statement st = c.createStatement();
		final ResultSet rs = st.executeQuery("select * from mon$attachments");
		while (rs.next()) {
			System.out.println(rs.getString("mon$remote_process"));
		}
	}
}
