import java.sql.*;

/**
 * This class demonstrates the ability to execute a PreparedStatement whose
 * parameters have not all be correctly set (exception while setting a 
 * string that is too long). Additionally, the overly long string can cause
 * the Firebird server to lock-up
 *
 * Database 'test' contains the following table:
 *
 * <pre>
 * CREATE TABLE test (
 *      a varchar(5) not null primary key,
 *      b varchar(5)
 * );
 * insert into test values ('zzz', 'yyy');
 * </pre>
 */
public class BindParameterBug {
    public static void main(String [] args) throws Exception {
        Class.forName("org.firebirdsql.jdbc.FBDriver");
        Connection conn = DriverManager.getConnection("jdbc:firebirdsql:localhost:/tmp/test.gdb", "sysdba", "masterkey");
        conn.setAutoCommit(false);
        PreparedStatement ps = conn.prepareStatement("update test set b = ? where a = ?");
        try {
            ps.setString(1, "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
        } catch (Exception e1){
            System.err.println("Caught bind exception: " + e1.getMessage());
        }
        ps.setString(2, "zzz");
        try {
            System.out.println("About to exec");
            ps.executeUpdate();
            System.out.println("Done executing, Firebird 1.5 gets here");
            conn.commit();
            System.out.println("Done committing");
        } catch (Exception e2){
            System.err.println("Caught e2: " + e2.getMessage());
            System.err.println("About to rollback");
            conn.rollback();
            System.err.println("Done rollback");
        }
        System.out.println("About to close");
        conn.close();
        System.out.println("Done closing");
    }
}
