package firebird.reproduction;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 *
 * @author Mark
 */
public class ColumnLabelGetTest {
    
    // Standard 'EMPLOYEE' example database
    private static final String JDBC_URL = "jdbc:firebirdsql://localhost/D:/data/DB/EMPLOYEE.FDB";
    private static final String USER = "sysdba";
    private static final String PASSWORD = "masterke";

    @BeforeClass
    public static void prepareTest() throws ClassNotFoundException {
        Class.forName("org.firebirdsql.jdbc.FBDriver");
    }

    /**
     * Tests if the specified column in the query can be found with its alias (label).
     *
     * @throws SQLException
     */
    @Test
    public void testFindColumnUseAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER AS CST_NAME FROM CUSTOMER");

            int idx = rs.findColumn("CST_NAME");
            Assert.assertEquals("Unexpected column index for column label 'CST_NAME", 1, idx);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Tests if the specified column in the query can be found with its column name if no alias is specified.
     *
     * @throws SQLException
     */
    @Test
    public void testFindColumnUseNameNoAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER FROM CUSTOMER");

            int idx = rs.findColumn("CUSTOMER");
            Assert.assertEquals("Unexpected column index for column name 'CUSTOMER", 1, idx);

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Tests if searching for a non-existent column name or alias throws SQLException
     *
     * @throws SQLException
     */
    @Test(expected=java.sql.SQLException.class)
    public void testFindColumnNonExistent() throws SQLException {
                Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER FROM CUSTOMER");

            int idx = rs.findColumn("NON_EXISTENT");

            // We should not get here

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Tests if searching for a column by name if it has an alias throws SQLException
     * <p>
     * See JDBC 4.0 spec, section 15.2.3 and javadoc for {@link ResultSet#findColumn(String)}
     * <p>
     *
     * @throws SQLException
     */
    @Test(expected=java.sql.SQLException.class)
    public void testFindColumnUseNameWithAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = null;
            rs = stmt.executeQuery("SELECT CUSTOMER AS CST_NAME FROM CUSTOMER");

            int idx = rs.findColumn("CUSTOMER");

            // We should not get here

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Tests if a value can be retrieved by column name if no alias is specified.
     *
     * @throws SQLException
     */
    @Test
    public void testGetStringUseNameNoAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER FROM CUSTOMER");

            if (rs.next()) {
                rs.getString("CUSTOMER");
            } else {
                Assert.fail("Expected a result, got none");
            }

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Tests if a value can be retrieved by alias (label)
     *
     * @throws SQLException
     */
    @Test
    public void testGetStringUseAlias() throws SQLException {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER AS CST_NAME FROM CUSTOMER");

            if (rs.next()) {
                rs.getString("CST_NAME");
            } else {
                Assert.fail("Expected a result, got none");
            }

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Test if retrieving value by column name if an alias is specified throws SQLException
     * <p>
     * See JDBC 4.0 spec, section 15.2.3 and javadoc for {@link ResultSet#findColumn(String)}
     * <p>
     * @throws SQLException
     */
    @Test(expected=java.sql.SQLException.class)
    public void testGetStringUseNameWithAlias() throws SQLException {
                Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER AS CST_NAME FROM CUSTOMER");

            if (rs.next()) {
                rs.getString("CUSTOMER");
            }

            // We should not get here

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

    /**
     * Test if retrieving value by non-existent column or alias name throws SQLException
     *
     * @throws SQLException
     */
    @Test(expected=java.sql.SQLException.class)
    public void testGetStringUseNonExistent() throws SQLException {
                Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = DriverManager.getConnection(JDBC_URL, USER, PASSWORD);
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT CUSTOMER AS CST_NAME FROM CUSTOMER");

            if (rs.next()) {
                rs.getString("NON_EXISTENT");
            }

            // We should not get here

        } finally {
            try {
                rs.close();
            } catch (Exception e) { }
            try {
                stmt.close();
            } catch (Exception e) { }
            try {
                con.close();
            } catch (Exception e) { }
        }
    }

}
