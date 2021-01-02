package jdbc132;

import java.sql.Connection;
import java.sql.DataTruncation;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * Reproduction case for <a href="http://tracker.firebirdsql.org/browse/JDBC-132">JDBC-132</a>.
 *
 * Preconditions for run: existence of table in database as described in JDBC-132
 *
 * @author Mark Rotteveel
 */
public class JDBC132Reproduction {

    public static void main(String[] args) throws SQLException {
        Connection con = null;
        try {
            con = DriverManager.getConnection("jdbc:firebirdsql://localhost/D:/data/DB/testDB.fdb", "sysdba", "masterke");
            PreparedStatement pstmt = con.prepareStatement("select id from tmptable where myblob like ?");

            StringBuffer buf = new StringBuffer('a');
            boolean repeat = true;
            do {
                try {
                    pstmt.setString(1, buf.toString());
                } catch (DataTruncation ex) {
                    System.err.printf("Failed at %d characters\n", buf.length());
                    System.err.println("Data length " + ex.getDataSize() + ", field size " + ex.getTransferSize());
                    ex.printStackTrace();
                    repeat = false;
                }
                buf.append('a');
            } while(repeat);
        } finally {
            if (con != null) {
                try {
                    con.close();
                } catch (Exception ex) {
                    // swallow exception
                }
            }
        }

    }

}
